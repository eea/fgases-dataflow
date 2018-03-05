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
declare variable $source_report as xs:string external;


declare variable $SCHEMA as xs:string := "http://dd.eionet.europa.eu/schemas/fgases-2017/f-gases-bulk-verification-2018.xsd";
declare variable $xmlconv:SOURCE_URL_PARAM := "source_url=";
declare variable $xmlconv:OBLIGATION := "764";

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
    if ( contains($url, $xmlconv:SOURCE_URL_PARAM)) then
        fn:substring-after($url, $xmlconv:SOURCE_URL_PARAM)
    else
        $url
};

declare function xmlconv:validateEnvelope($url-env as xs:string, $url-report as xs:string)
as element(div)
{
    let $files := fn:doc($url-env)//file[string-length(@link)>0]
    let $report := doc($url-report)//Verification

    let $obligation := concat('http://rod.eionet.europa.eu/obligations/', $xmlconv:OBLIGATION)
    let $envelopeObligation := fn:doc($url-env)//obligation/data()

    let $filesCountReport := count($report/ReportFiles/ReportFile)
    let $filesCountAll := count($files)
    let $filesCountCorrectSchema := count($files[@schema = $SCHEMA])
    let $filesCountXml := count($files[@type="text/xml"])

    let $fileNames := $files/@link
    let $okFiles :=
        for $file in $report//ReportFiles/ReportFile
        (:let $asd := trace($file, "file: "):)
        return if($file/data() = $fileNames)
            then $file/data()
            else ()

    let $errorLevel := if (
        count($okFiles) = $filesCountReport
                and $filesCountCorrectSchema = 1 and $filesCountXml = 1
                and $obligation = $envelopeObligation
    )
    then "INFO"
    else "BLOCKER"

    let $description :=
        if (count($okFiles) != $filesCountReport) then
            <span>
                <span i18n:translate="">
                    Your delivery cannot be accepted as you have not provided all the Report Files.
                </span>
            </span>
        else if ($filesCountCorrectSchema != 1 or $filesCountXml != 1) then
            <span>
                <span i18n:translate="">
                    Your delivery cannot be accepted as you have not provided an XML file with correct scheme.
                </span>
            </span>
        else if ($obligation != $envelopeObligation) then
            <span>
                <span i18n:translate="">
                    Your delivery cannot be accepted as you have not provided the correct obligation.
                </span>
            </span>
        else
            <span i18n:translate="">Your data report has been completed correctly using the online questionnaire.</span>
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

    let $sourceDocAvailable := doc-available($source_url)
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
