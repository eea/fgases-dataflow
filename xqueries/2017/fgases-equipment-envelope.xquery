xquery version "3.1";

(:~
: User: laszlo
: Date: 2/8/18
: Time: 1:28 PM
:)

declare namespace xmlconv = "http://converters.eionet.europa.eu/fgases";
(: namespace for BDR localisations :)
declare namespace i18n = "http://namespaces.zope.org/i18n";

(:===================================================================:)
(: Variable given as an external parameter by the QA service         :)
(:===================================================================:)
(:
declare variable $source_url as xs:string :='http://cdrtest.eionet.europa.eu/de/colt_cs2a/colt_ctda/envumtz_a/xml';
declare variable $source_url as xs:string external;
:)
declare variable $source_url as xs:string external;
declare variable $source_report as xs:string := "";


declare variable $SCHEMA as xs:string := "http://dd.eionet.europa.eu/schemas/fgases-2019/f-gases-equipment-verification-2019.xsd";
declare variable $xmlconv:SOURCE_URL_PARAM := "source_url=";
declare variable $xmlconv:OBLIGATION := "713";

(:==================================================================:)
(:==================================================================:)
(:==================================================================:)
(:					QA rules related functions				        :)
(:==================================================================:)
(:==================================================================:)
(:==================================================================:)

declare function xmlconv:getCleanUrl($url)
as xs:string
{
    if ( fn:contains($url, $xmlconv:SOURCE_URL_PARAM)) then
        fn:substring-after($url, $xmlconv:SOURCE_URL_PARAM)
    else
        $url
};

declare function xmlconv:getProxyUrl($url)
as xs:string
{
    if ( fn:contains($url, $xmlconv:SOURCE_URL_PARAM)) then
        fn:concat(fn:substring-before($url, $xmlconv:SOURCE_URL_PARAM),'source_url=')
    else
        ""
};

declare function xmlconv:validateEnvelope($url-env as xs:string, $url-report as xs:string)
as element(div)
{
    let $files := fn:doc($url-env)//file[fn:string-length(@link)>0]

    let $obligation := fn:concat('http://rod.eionet.europa.eu/obligations/', $xmlconv:OBLIGATION)

    let $filesCountCorrectSchema := fn:count($files[@schema = $SCHEMA])
    let $filesCountXml := fn:count($files[@type="text/xml" and @schema = $SCHEMA])
    let $filesCountXml2 := fn:count($files[@type="text/xml"])
    let $filesCountAll := fn:count($files)
    let $fileXML := if($filesCountCorrectSchema = 1 and $filesCountXml = 1)
    then
        fn:concat(
                xmlconv:getProxyUrl($url-env),
                fn:doc($url-env)//link,
                '/',
                $files[@type="text/xml" and @schema = $SCHEMA]/@name
        )
    else
        ()
    let $report-available := fn:doc-available($fileXML)
    let $report := if($report-available)
    then
        fn:doc($fileXML)//Verification
    else
        ()

    let $filesCountReport := if($report-available)
    then
        fn:count($report/ReportFiles/ReportFile)
    else 0

    let $fileNames := $files/@link
    let $okFiles := if($report-available)
    then
        for $file in $report//ReportFiles/ReportFile
        return if($file/fn:data() = $fileNames)
        then $file/fn:data()
        else ()
    else -1

    let $xml-url-available := if($report-available) then fn:concat(xmlconv:getProxyUrl($url-env), fn:doc($fileXML)//URL/data(), '/xml') else ""
    let $xml-url-option := fn:doc($fileXML)//EV_3.1/data()
    let $xml-url-value := fn:doc($fileXML)//URL/data()
    let $envelopeObligation := if(fn:doc-available($xml-url-available)) then fn:doc($xml-url-available)//obligation/data() else ""
    let $xml-nilreport-value := fn:doc($fileXML)//NILReport/data()
    let $xml-EV_3_2_a-value := fn:doc($fileXML)//EV_3.2_a/data()
    let $xml-EV_3_2_b-value := fn:doc($fileXML)//EV_3.2_b/data()
    let $xml-EV_3_2_c-value := fn:doc($fileXML)//EV_3.2_c/data()
    let $xml-EV_3_2_d-value := fn:doc($fileXML)//EV_3.2_d/data()

    let $errorLevel := if (
        (fn:count($okFiles) = $filesCountReport
                and $filesCountCorrectSchema = 1 and $filesCountXml2 = 1
                and ($obligation = $envelopeObligation or ($xml-url-option = "EV_3.1_2" and $xml-url-value = ""))
                and $filesCountAll > 1
                and ($xml-EV_3_2_a-value != "" and $xml-EV_3_2_b-value != "" and $xml-EV_3_2_c-value != "" and $xml-EV_3_2_d-value != "" and $xml-nilreport-value != "true"))
        or ($xml-nilreport-value = "true" and $filesCountCorrectSchema = 1 and $filesCountXml2 = 1 and $xml-url-option != "EV_3.1_1")
        or ($xml-nilreport-value = "true" and $filesCountCorrectSchema = 1 and $filesCountXml2 = 1 and $xml-url-option = "EV_3.1_1" and $xml-url-value != "")
    )
    then "INFO"
    else "BLOCKER"
(:<!--(($obligation != $envelopeObligation and $xml-url-option = "EV_3.1_1" and $xml-nilreport-value = "true" and  $xml-url-value = "") or ($obligation != $envelopeObligation  and $xml-nilreport-value != "true" and  $xml-url-value = ""))then-->:)
    let $description :=
        if ((fn:empty($report))and ($filesCountXml2 < 1 or $filesCountCorrectSchema<1)) then
            <span>
                <span i18n:translate="">
                    Your delivery cannot be accepted because no XML file was created using the online questionnaire.
                </span>
            </span>
        else if (fn:count($okFiles) != $filesCountReport and $xml-nilreport-value != "true") then
            <span>
                <span i18n:translate="">
                    Your delivery cannot be accepted because you have not provided at least one verification report file.
                </span>
            </span>
        else if ($filesCountCorrectSchema != 1 or $filesCountXml2 != 1) then
                <span>
                    <span i18n:translate="">
                        Your delivery cannot be accepted because your envelope must contain exactly one XML file with correct schema.
                    </span>
                </span>
            
            else if (($obligation != $envelopeObligation and $xml-url-option = "EV_3.1_1" and $xml-nilreport-value = "true" and  $xml-url-value = "") or ($obligation != $envelopeObligation  and $xml-nilreport-value != "true" and  $xml-url-value = "")) then
                    <span>
                        <span i18n:translate="">
                            Your delivery cannot be accepted because you did not reference a valid report envelope for the reporting obligation Fluorinated gases (F-gases) reporting by undertakings (Regulation 2014).                        

                        </span>
                    </span>
                else if ($filesCountAll < 2 and $xml-nilreport-value != "true") then
                        <span>
                            <span i18n:translate="">
                                Your delivery cannot be accepted because you need at least one additional file in the envelope.
                            </span>
                        </span>
                else if (($xml-EV_3_2_a-value = "" or $xml-EV_3_2_b-value = "" or $xml-EV_3_2_c-value = "" or $xml-EV_3_2_d-value = "") and $xml-nilreport-value != "true") then
                        <span>
                            <span i18n:translate="">
                                Your submission was not acceptable because the form was not fully completed. Please note that you need to enter information on the auditor&apos;s report on the second tab of the webform and check fields EV_3.2_a, EV_3.2_b, EV_3.2_c and EV_3.2_d.
                            </span>
                        </span>
                    else
                        <span i18n:translate="">Your delivery has been successfully completed using the online questionnaire.</span>
    return
        <div class="feedbacktext">
            <h2 i18n:translate="">Check contents of delivery</h2>
            <span id="feedbackStatus" class="{$errorLevel}" style="display:none">&#32;
                {$description}
            </span>
            {
                if ($errorLevel = "BLOCKER") then
                    <p><span style="color:red">{ $description }</span></p>
                else
                    <p style="color:blue;font-size:1.1em;">{ $description }</p>
            }
        </div>

};
(:===================================================================:)
(: Main function calls the different get function and returns the result:)
(:===================================================================:)

declare function xmlconv:proceed($source_url as xs:string, $source_report as xs:string) {

    let $sourceDocAvailable := fn:doc-available($source_url)
    let $results := if ($sourceDocAvailable) then xmlconv:validateEnvelope($source_url, $source_report) else ()

    return
        if ($sourceDocAvailable) then
            $results
        else
            <div class="feedbacktext" i18n:translate="">
                Could not execute the script because the source XML is not available: <span i18n:name="xml-url">{ xmlconv:getCleanUrl($source_url) }</span>
            </div>
}
;

xmlconv:proceed($source_url, $source_report)