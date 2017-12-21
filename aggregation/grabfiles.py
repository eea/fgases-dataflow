# -*- coding: utf-8 -*-

import os, sys, getopt, datetime, urllib2, urllib, base64, json, re
import ConfigParser

FGASES_OBLIGATION = 'http://rod.eionet.europa.eu/obligations/713'
#FGASES_SCHEMA = 'http://webq2test.eionet.europa.eu/download/project/fgases2016-test/file/FGasesReporting2015.xsd'
FGASES_SCHEMA = 'http://dd.eionet.europa.eu/schemas/fgases-2015/FGasesReporting.xsd'
FGASES_XSL = 'fgases-sql.xsl'
ODS_OBLIGATION = 'http://rod.eionet.europa.eu/obligations/213'
ODS_SCHEMA = 'http://dd.eionet.europa.eu/schemas/ods/ODSReport.xsd'
#ODS_SCHEMA = "https://svn.eionet.europa.eu/repositories/Reportnet/Dataflows/OzoneDepletingSubstances/schema/ODSReporting.xsd"
ODS_XSL = 'ods-sql.xsl'
NIL_REPORT_SCHEMA = 'http://dd.eionet.europa.eu/schemas/bdr/NILReporting.xsd'
#NIL_REPORT_SCHEMA = "https://svn.eionet.europa.eu/repositories/Reportnet/Dataflows/OzoneDepletingSubstances/nilreport/schema/NILReporting.xsd"
NIL_XSL = 'nil-sql.xsl'
REPORTING_YEAR = ['2017']
IGNORE_ENVELOPES = ['/10086/', '/fgas30000/', '/ods30000/', '/fgases/ro/colvnm0fa']
#IGNORE_ENVELOPES = []
SELECTED_ENVELOPES = []
SKIP_COMPANIES_HARVEST = False
# BLOCKING_INCLUDED = "1" fetches also envelopes that have blocking feedback. BLOCKING_INCLUDED = "0" fetches only envelopes that have no blocking feedback
BLOCKING_INCLUDED = "0"

def usage():
    sys.stderr.write("""Usage: Obligation is not specified!\n""" % sys.argv[0])

def set_authentication(cdrserver, cdruser, cdrpass):
    auth_handler = urllib2.HTTPBasicAuthHandler()
    auth_handler.add_password("Zope", cdrserver, cdruser, cdrpass)
    opener = urllib2.build_opener(auth_handler)
    urllib2.install_opener(opener)

def downloadfile(fileurl, tmpfile, cdruser, cdrpass):
    tempFd = open(tmpfile, 'wb')
    req = urllib2.Request(urllib.quote(fileurl, '/:'))
    base64string = base64.encodestring('%s:%s' % (cdruser, cdrpass)).replace('\n', '')
    req.add_header("Authorization", "Basic %s" % base64string)
    conn = urllib2.urlopen(req)
    data = conn.read(8192)
    while data:
        tempFd.write(data)
        data = conn.read(8192)
    conn.close()
    tempFd.close()
def is_envelope_ignored(envelopeurl):
    for e in IGNORE_ENVELOPES:
        if e in envelopeurl:
            return True
    return False
def envelope_selected(envelopeurl):
    if not SELECTED_ENVELOPES:
        return True
    for e in SELECTED_ENVELOPES:
        if e in envelopeurl:
            return True
    return False
def escapesql(s):
    if s is None:
        s = '';
    return str(s.encode('utf-8').strip()).replace("'", "''").replace("\n", " ")

def clearData():
    sys.stdout.write("""
    DELETE FROM db_info;
    DELETE FROM data_report;
    DELETE FROM data_company_contacts;
    DELETE FROM data_report_values;""")

    if obligation == FGASES_OBLIGATION:
        sys.stdout.write("""
    DELETE FROM data_companies;
    DELETE FROM data_report_contacts;
    DELETE FROM data_affiliations;
    DELETE FROM data_blend_components;
    DELETE FROM data_report_drafts;
    DELETE FROM data_report_rejected;
            """)
        tmpfilename = 'downloadtmp-fgases.xml'
    elif obligation == ODS_OBLIGATION:
        tmpfilename = 'downloadtmp-ods.xml'

    sys.stdout.flush()

def importCompanies():
    # import FGases companies from BDR registry
    if obligation == FGASES_OBLIGATION and not SKIP_COMPANIES_HARVEST:
        registry_url = cdrserver + "fgases_registry/organisations_json"
        req = urllib2.Request(registry_url)
        base64string = base64.encodestring('%s:%s' % (cdruser, cdrpass)).replace('\n', '')
        req.add_header("Authorization", "Basic %s" % base64string)
        f = urllib2.urlopen(req)
        response = json.loads(f.read().decode(f.info().getparam('charset') or 'utf-8'))

        for org in response:
            if org['domain'] == 'FGAS':
                org_id = str(org['id'])
                if testdata == 1 and org_id != '10086':
                    continue
                if testdata == 0 and org_id == '10086':
                    continue
                businessProfile = '' if org['businessProfile'] is None else '' + org['businessProfile'].get(
                    'highLevelUses', '')
                businessProfile = ',' + businessProfile if len(businessProfile) > 0 and len(
                    escapesql(org.get('types', ''))) > 0 else businessProfile
                euLegalRepresentativeProperties = ('', '', '', '', '', '', '', '', '', '', '', '', '') if org[
                                                                                                              'euLegalRepresentativeCompany'] is None else \
                    (escapesql(org['euLegalRepresentativeCompany'].get('name', '')),
                     escapesql(org['euLegalRepresentativeCompany']['address'].get('street', '')),
                     escapesql(org['euLegalRepresentativeCompany']['address'].get('number', '')),
                     escapesql(org['euLegalRepresentativeCompany']['address'].get('zipCode', '')), \
                     escapesql(org['euLegalRepresentativeCompany']['address'].get('city', '')),
                     escapesql(org['euLegalRepresentativeCompany']['address']['country'].get('code', '')),
                     escapesql(org['euLegalRepresentativeCompany']['address']['country'].get('type', '')), \
                     escapesql(org['euLegalRepresentativeCompany'].get('website', '')),
                     escapesql(org['euLegalRepresentativeCompany'].get('contactPersonFirstName', '')),
                     escapesql(org['euLegalRepresentativeCompany'].get('contactPersonLastName', '')), \
                     escapesql(org['euLegalRepresentativeCompany'].get('contactPersonTelephone', '')),
                     escapesql(org['euLegalRepresentativeCompany'].get('contactPersonEmailAddress', '')),
                     escapesql(org['euLegalRepresentativeCompany'].get('vatNumber', '')))

                sys.stdout.write("""
    INSERT INTO data_companies (company_id, name, street, house_no, postcode, city, country, country_type, telephone, website, VAT_no, Former_Company_no_2007_2010, types, status, portal_registration_date, \
    OR_name, OR_street, OR_house_no, OR_postcode, OR_city, OR_country, OR_country_type, OR_website, OR_firstname, OR_lastname, OR_telephone, OR_email, OR_VAT_no) \
    VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');""" \
                                 % ((escapesql(org_id), escapesql(org.get('name', '')),
                                     escapesql(org['address'].get('street', '')),
                                     escapesql(org['address'].get('number', '')),
                                     escapesql(org['address'].get('zipCode', '')), \
                                     escapesql(org['address'].get('city', '')),
                                     escapesql(org['address']['country'].get('code', '')),
                                     escapesql(org['address']['country'].get('type', '')),
                                     escapesql(org.get('phone', '')), \
                                     escapesql(org.get('website', '')), escapesql(org.get('vat', '')),
                                     escapesql(org.get('Former_Company_no_2007-2010', '')),
                                     escapesql(org.get('types', '') + businessProfile), \
                                     escapesql(org.get('status')),
                                     escapesql(org.get('portal_registration_date'))) + euLegalRepresentativeProperties)
                                 )
                if org['contactPersons'] is not None:
                    for person in org['contactPersons']:
                        sys.stdout.write("""
    INSERT INTO data_company_contacts (company_id, UserName, FirstName, LastName, Email) VALUES (%s, '%s', '%s', '%s', '%s');""" \
                                         % (escapesql(org_id), escapesql(person.get('userName', '')),
                                            escapesql(person.get('firstName', '')),
                                            escapesql(person.get('lastName', '')),
                                            escapesql(person.get('emailAddress', ''))))

        f.close()
        sys.stdout.flush()

def harvestFiles():
    # Create auth handler
    try:
        set_authentication(cdrserver, cdruser, cdrpass)
        isReleased = "1" if released else "0"
        envelopes_url = cdrserver + "api/envelopes?obligations=" + obligation.rsplit("/", 1)[
            1] + "&isReleased=" + isReleased + "&reportingDateStart=" + REPORTING_YEAR[
                            0] + "-01-01&isBlockedByQCError=" + BLOCKING_INCLUDED + "&fields=companyId,url,countryCode,files,isReleased,reportingDate"
        req2 = urllib2.Request(envelopes_url)
        base64string = base64.encodestring('%s:%s' % (cdruser, cdrpass)).replace('\n', '')
        req2.add_header("Authorization", "Basic %s" % base64string)
        f2 = urllib2.urlopen(req2)
        r2 = json.loads(f2.read().decode(f2.info().getparam('charset') or 'utf-8'))
    except Exception as ex:
        print >> sys.stderr, "Exception" + str(ex)
    finally:
        try:
            f2.close()
        except NameError:
            pass
    for envelope in r2['envelopes']:
        # reportingdate = envelope['released']
        envelopeurl = envelope['url']

        # if reportingdate[:4] not in (REPORTING_YEAR):
        #    continue

        #ignore test accounts, unless not included through "t" argument
        if testdata == 0 and is_envelope_ignored(envelopeurl):
            continue
        if testdata == 1 and not(is_envelope_ignored(envelopeurl)):
            continue

        print >> sys.stderr, "-- ++++++++++++++++++++++ Envelope %s ++++++++++++++++++++" % envelope['url']

        # check if feedback contains "Data delivery was not acceptable"
        # hasBlockerFeedback = False
        # try:
        # this delay fixes the bug that would make has_blocker_feedback fail
        #    time.sleep(.500)
        #    hasBlockerFeedback = xmlrpclib.ServerProxy(envelopeurl).has_blocker_feedback()
        # except:
        #    print >>sys.stderr, "-- Failed to call has_blocker_feedback --"

        # feedbacks = xmlrpclib.ServerProxy(envelopeurl).feedback_objects_details()
        # for feedback in feedbacks['feedbacks']:
        #    if feedback['title'] == "Data delivery was not acceptable":
        #        hasBlockerFeedback = True
        #        continue
        # if hasBlockerFeedback:
        #    print >>sys.stderr, "-- HAS BLOCKER FEEDBACK --"
        #    continue

        files = envelope['files']
        # ignore envelope if it contains more than 1 xml
        xmlCount = 0
        for f in files:
            if f['contentType'] == "text/xml":
                xmlCount += 1;

        if xmlCount > 1:
            print >> sys.stderr, "Envelope contains more than 1 XML file"
            continue

        for f in files:
            if f['schemaURL'] == FGASES_SCHEMA:
                xsl = FGASES_XSL
            elif f['schemaURL'] == ODS_SCHEMA:
                xsl = ODS_XSL
            elif f['schemaURL'] == NIL_REPORT_SCHEMA:
                xsl = NIL_XSL
            else:
                continue

            scriptargs = {
                'cdruser': cdruser,
                'cdrpass': cdrpass,
                'fileurl': f['url'],
                'countrycode': envelope['countryCode'],
                'envelopeurl': envelope['url'],
                'envelope': envelope['url'].rsplit("/", 1)[1],
                'companyId' : envelope['companyId'],
                'isreleased': envelope['isReleased'],
                'filename': f['url'].rsplit("/", 1)[1],
                'uploadtime': f['uploadDate'],
                # 'accepttime': f[],
                'reportingtime': envelope['reportingDate'],
                'xsl': xsl,
                'tmpfile': 'tmp' + os.sep + tmpfilename

            }

            if (f['schemaURL'] == FGASES_SCHEMA and obligation == FGASES_OBLIGATION) or (
                    f['schemaURL'] == ODS_SCHEMA and obligation == ODS_OBLIGATION) or (
                f['schemaURL'] == NIL_REPORT_SCHEMA):
                fileurl = f['url']
                tmpfile = 'tmp' + os.sep + tmpfilename
                try:
                    downloadfile(fileurl, tmpfile, cdruser, cdrpass)
                    #os.system("""wget -nv -O %(tmpfile)s --http-user=%(cdruser)s --http-passwd=%(cdrpass)s '%(fileurl)s'  --ca-certificate=rapidssl.crt """ % scriptargs )
                    os.system("""xsltproc --stringparam envelopeurl '%(envelopeurl)s' --stringparam filename '%(filename)s' --stringparam envelope '%(envelope)s' --stringparam companyId '%(companyId)s' --stringparam releasetime '%(reportingtime)s' --stringparam isreleased '%(isreleased)s' %(xsl)s %(tmpfile)s """ % scriptargs)
                    os.unlink(tmpfile)
                except:
                    print >> sys.stderr, "-- Storage error for file --"

def importDraft():
    # import draft envelopes
    if obligation == FGASES_OBLIGATION:
        set_authentication(cdrserver, cdruser, cdrpass)
        unreleased_envelopes_api_url = cdrserver + "api/unreleased_envelopes?obligation=" + obligation
        req = urllib2.Request(unreleased_envelopes_api_url)
        base64string = base64.encodestring('%s:%s' % (cdruser, cdrpass)).replace('\n', '')
        req.add_header("Authorization", "Basic %s" % base64string)
        f = urllib2.urlopen(req)
        response = json.loads(f.read().decode(f.info().getparam('charset') or 'utf-8'))
        f.close()

        for envelope in response:
            company_id = envelope['id']
            url = envelope['url']
            creation_date = envelope['released']

            #ignore test accounts, unless not included through "t" argument
            if testdata == 0 and is_envelope_ignored(url):
                continue
            if testdata == 1 and not(is_envelope_ignored(url)):
                continue
            if creation_date[:4] not in (REPORTING_YEAR):
                continue
            sys.stdout.write("""
    INSERT INTO data_report_drafts (creation_date, company_id, envelope_url) VALUES ('%s', '%s', '%s');""" \
                             % ((escapesql(re.sub('T|Z', ' ', creation_date)), escapesql(company_id), escapesql(url))))

        sys.stdout.flush()

def importRejected():
    # import rejected envelopes
    if obligation == FGASES_OBLIGATION:
        set_authentication(cdrserver, cdruser, cdrpass)
        unreleased_envelopes_api_url = cdrserver + "api/rejected_envelopes?obligation=" + obligation
        req = urllib2.Request(unreleased_envelopes_api_url)
        base64string = base64.encodestring('%s:%s' % (cdruser, cdrpass)).replace('\n', '')
        req.add_header("Authorization", "Basic %s" % base64string)
        f = urllib2.urlopen(req)
        response = json.loads(f.read().decode(f.info().getparam('charset') or 'utf-8'))
        f.close()

        for envelope in response:
            company_id = envelope['id']
            url = envelope['url']
            creation_date = envelope['released']

            #ignore test accounts, unless not included through "t" argument
            if testdata == 0 and is_envelope_ignored(url):
                continue
            if testdata == 1 and not(is_envelope_ignored(url)):
                continue
            if creation_date[:4] not in (REPORTING_YEAR):
                continue

            sys.stdout.write("""
    INSERT INTO data_report_rejected (submission_date, company_id, envelope_url) VALUES ('%s', '%s', '%s');""" \
                             % ((escapesql(re.sub('T|Z', ' ', creation_date)), escapesql(company_id), escapesql(url))))

        sys.stdout.flush()
    sys.stdout.write("""
    INSERT INTO db_info (last_modified) VALUES ('%s'); """ % (datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
    sys.stdout.flush()

if __name__ == '__main__':
    config = ConfigParser.SafeConfigParser()
    config.read('accounts.conf')

    cdrserver = config.get('cdr', 'server')
    cdruser = config.get('cdr', 'username')
    cdrpass = config.get('cdr', 'password')
    released = config.getboolean('cdr', 'released')
    #obligation = config.get('cdr', 'obligation')
    testdata = 0
#    opts = ["-d"]
#    args = [FGASES_OBLIGATION]
    try:
        opts, args = getopt.getopt(sys.argv[1:], "rdt", ["--released","--draft","--testdata" ])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for o, a in opts:
        if o in ("-r", "--released"):
            released = 1
        if o in ("-d", "--draft"):
            released = 0
        if o in ("-t", "--testdata"):
            testdata = 1

    if len(args) == 0:
        usage()
        sys.exit(2)
    obligation = args[0]
    if obligation == FGASES_OBLIGATION:
        tmpfilename = 'downloadtmp-fgases.xml'
    elif obligation == ODS_OBLIGATION:
        tmpfilename = 'downloadtmp-ods.xml'
    clearData()
    importCompanies()
    harvestFiles()
    importDraft()
    importRejected()