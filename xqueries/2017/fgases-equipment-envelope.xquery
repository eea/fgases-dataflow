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


declare variable $SCHEMA as xs:string := "http://dd.eionet.europa.eu/schemas/fgases-2017/f-gases-equipment-verification-2018.xsd";
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

declare function xmlconv:validateEnvelope($url-env as xs:string, $url-report as xs:string)
as element(div)
{
    let $files := fn:doc($url-env)//file[fn:string-length(@link)>0]
    (:let $report := fn:doc($url-report)//Verification:)


    let $obligation := fn:concat('http://rod.eionet.europa.eu/obligations/', $xmlconv:OBLIGATION)
    let $envelopeObligation := fn:doc($url-env)//obligation/fn:data()

    let $filesCountCorrectSchema := fn:count($files[@schema = $SCHEMA])
    let $filesCountXml := fn:count($files[@type="text/xml"])
    let $filesCountAll := fn:count($files)
    let $fileXML := if($filesCountCorrectSchema = 1 and $filesCountXml = 1)
        then
            fn:concat(
                fn:doc($url-env)//link,
                '/',
                $files[@type="text/xml"]/@name
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

    let $errorLevel := if (
        fn:count($okFiles) = $filesCountReport
                and $filesCountCorrectSchema = 1 and $filesCountXml = 1
                and $obligation = $envelopeObligation
                and $filesCountAll > 1
    )
    then "INFO"
    else "BLOCKER"

    let $description :=
        if (fn:empty($report)) then
            <span>
                <span i18n:translate="">
                    Report file is not available.
                </span>
            </span>
        else if (fn:count($okFiles) != $filesCountReport) then
            <span>
                <span i18n:translate="">
                    Your delivery cannot be accepted as you have not provided all the Report Files.
                </span>
            </span>
        else if ($filesCountCorrectSchema != 1 or $filesCountXml != 1) then
            <span>
                <span i18n:translate="">
                    Your delivery cannot be accepted because your envelope must contain only one XML file with correct scheme.
                </span>
            </span>
        else if ($obligation != $envelopeObligation) then
            <span>
                <span i18n:translate="">
                    Your delivery cannot be accepted as you have not provided the correct obligation.
                </span>
            </span>
        else if ($filesCountAll < 2) then
            <span>
                <span i18n:translate="">
                    Your delivery cannot be accepted as you need at least one additional file in the envelope.
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
