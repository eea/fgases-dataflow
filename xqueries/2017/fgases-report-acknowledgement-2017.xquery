xquery version "1.0" encoding "UTF-8";
(:
 : Module Name: FGases dataflow (Main module)
 :
 : Version:     $Id: fgases-2017.xquery 21935 2017-01-10 14:07:35Z katsanas $
 : Created:     20 November 2014
 : Copyright:   European Environment Agency
 :)
(:~
 : Reporting Obligation: http://rod.eionet.europa.eu/obligations/713
 : XML Schema: http://dd.eionet.europa.eu/schemas/fgases-2015/FGasesReporting.xsd
 :
 : F-Gases QA Rules implementation
 :
 : @author Enriko Käsper
 :)


declare namespace xmlconv="http://converters.eionet.europa.eu/fgases";
(: namespace for BDR localisations :)
declare namespace i18n = "http://namespaces.zope.org/i18n";
(: Common utility methods :)

import module namespace cutil = "http://converters.eionet.europa.eu/fgases/cutil" at "fgases-common-util-2017.xquery";
(: UI utility methods for build HTML formatted QA result:)
import module namespace uiutil = "http://converters.eionet.europa.eu/fgases/ui" at "fgases-ui-util-2017.xquery";
import module namespace fgases = 'http://converters.eionet.europa.eu/fgases/helper' at "fgases-helper-2017.xquery";

declare variable $xmlconv:BLOCKER as xs:string := "BLOCKER";
declare variable $xmlconv:WARNING as xs:string := "WARNING";
declare variable $xmlconv:COMPLIANCE as xs:string := "COMPLIANCE";
declare variable $xmlconv:INFO as xs:string := "INFO";
declare variable $xmlconv:ERR_TEXT_2016 as xs:string := "You reported on own destruction in section 1B. Please accordingly select to be a destruction company in the activity selection and report subsequently in section 8.";


declare variable $xmlconv:cssStyle as element(style) :=

<style type="text/css">
  <![CDATA[

.red {
  color:red;
}

.red-bold {
  color:red;
  font-weight:bold;
}

.orange {
  color:orange;
}

.blue {
  color:blue;
  font-size:0.8em;
}

.block {
    display:block;
}

ul.items-list li {
  list-style-type:none;
}

ul.errors-list li span.error-red,
ul.errors-list li span.error-orange {
  font-size: 0.8em;
  color: white;
  padding-left:12px;
  padding-right:12px;
  text-align:center;
}

ul.errors-list li span.error-red {
  background-color: red;
}

ul.errors-list li span.error-orange {
  background-color: orange;
}

ul.errors-list li span.error-name {
  font-weight:bold;
}

.datatable {
  width:100%;
  text-align:left;
}

.datatable tr th {
  width:250px;
  font-weight:normal;
  text-align:left;
}

.datatable tr td sup {
  font-size:0.7em;
  color:blue;
}
.error-details {
    margin-left: 37px;
    padding-top: 5px;
}
.error-details ul {
    margin-top: 5px;
    padding-top: 0px;
}
.errors {
    width:100%;
    margin-top: 10px;
}
.errors h4 {
    font-weight: bold;
    padding: 0.2em 0.4em;
    background-color: rgb(240, 244, 245);
    color: #000000;
    border-top: 1px solid rgb(224, 231, 215);
}
      ]]>
</style>

;

declare variable $source_url as xs:string external;

declare function xmlconv:getMostCriticalErrorClass($ruleResults as element()?)
as xs:string {
        if (count($ruleResults//span[@errorLevel='BLOCKER']) > 0) then
            "BLOCKER"
        else if (count($ruleResults//span[@errorLevel='WARNING']) > 0) then
            "WARNING"
        else if (count($ruleResults//span[@errorLevel='COMPLIANCE']) > 0) then
                "WARNING"
        else
            "INFO"
};

declare function xmlconv:getErrorText($class as xs:string) as xs:string {
    if ($class = "BLOCKER") then
        "The delivery is not acceptable. Please see the QA output."
    else if ($class = "WARNING") then
        "The delivery is acceptable but some of the information has to be checked. Please see the QA output."
    else if ($class = "INFO") then
            "The delivery is acceptable."
        else
            "The delivery status is unknown."
};

declare function xmlconv:rule_ReportStatus($doc as element())
as element(div)? {

(: check webform status, it has to be completed - click "Close report" button on Finish tab :)

    let $err_text := "For a successful submission, the result of automatic validation of consistency must be acknowledged in the Finish tab of the reporting form by clicking the ‘Close web form and proceed to BDR’ button which is green if your reporting has passed the automatic validation.
    If any blocking errors are displayed on that page, they must be corrected first before the report can be successfully submitted."

    let $err_flag := lower-case(data($doc/GeneralReportData/@status)) != "completed"

    return
        uiutil:buildRuleResult("status", "", $err_text, $xmlconv:BLOCKER, $err_flag, (), "")
};

declare function xmlconv:validateReport($url as xs:string)
as element(div)
{
    let $doc := fn:doc($url)/FGasesReporting
    let $rStatus := xmlconv:rule_ReportStatus($doc)
    return
        <div class="errors">
            {$rStatus}
        </div>
};

(:
 : ======================================================================
 : Main function
 : ======================================================================
 :)
declare function xmlconv:proceed($source_url as xs:string)
as element(div){

    let $results := xmlconv:validateReport($source_url)

    let $class := xmlconv:getMostCriticalErrorClass($results)
    let $errorText := xmlconv:getErrorText($class)

    let $resultErrors := uiutil:getResultErrors($results)

    (: Display all QC messages for maximum possible feedback to the user #68660 :)
    let $hasOnlyStatusError := false()

    return
            uiutil:buildScriptResult($results, $class, $errorText, $hasOnlyStatusError, $xmlconv:cssStyle)
};

xmlconv:proceed( $source_url )
