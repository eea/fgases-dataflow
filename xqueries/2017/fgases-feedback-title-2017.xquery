
declare variable $source_url as xs:string external;

declare function local:execute($sourceUrl as xs:string)
as xs:string
{
    let $report := doc($sourceUrl)
    let $envelope := local:get-envelope-metadata($sourceUrl)
    let $reportedTransactionYear := xs:integer($report/FGasesReporting/GeneralReportData/TransactionYear)
    let $submissionDate := xs:dateTime($envelope/date)
    return
        local:generate-feedback-text($reportedTransactionYear, $submissionDate)
};

declare function local:get-envelope-metadata($sourceUrl as xs:string)
as element(envelope)
{
    let $envelopeUrl := local:_source-url-to-envelope-url($sourceUrl)
    return 
        doc($envelopeUrl)/envelope
};

declare function local:_source-url-to-envelope-url($sourceUrl as xs:string)
as xs:string
{
    let $sourceUrlParts := fn:tokenize($sourceUrl, "/")
    let $envelopeUrlParts := fn:remove($sourceUrlParts, fn:count($sourceUrlParts))
    return concat(string-join($envelopeUrlParts, "/"), "/xml")
};

declare function local:generate-feedback-text(
    $reportedTransactionYear as xs:integer,
    $submissionDate as xs:dateTime
) as xs:string
{
    if ($reportedTransactionYear < 2016 or $submissionDate > xs:dateTime("2017-03-31T23:59:59.9Z")) then
        "approval pending"
    else
        "report accepted"
};

local:execute($source_url)
