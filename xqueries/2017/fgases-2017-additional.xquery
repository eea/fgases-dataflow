xquery version "1.0" encoding "UTF-8";
(:
 : Module Name: FGases dataflow (Main module)
 :
 : Version:     $Id: fgases-2017.xquery 20266 2016-01-27 09:18:28Z zykaerv $
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
.general-message {
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

(:
  Change it for testing locally:
declare variable $source_url as xs:string external;
declare variable $source_url as xs:string external;
declare variable $source_url := "http://cdrtest.eionet.europa.eu/de/colt_cs2a/colt_ctda/envt_cyoq/questionnaire_fgases.xml";
:)
(:
 : ======================================================================
 :     QA rules
 : ======================================================================
 :)

declare function xmlconv:rule_ReportStatus($doc as element())
as element(div)? {

(: check webform status, it has to be completed - click "Close report" button on Finish tab :)

    let $err_text := "For a successful submission, the result of automatic validation of consistency must be acknowledged in the Finish tab of the reporting form by clicking the ‘Close web form and proceed to BDR’ button which is green if your reporting has passed the automatic validation.
    If any blocking errors are displayed on that page, they must be corrected first before the report can be successfully submitted."

    let $err_flag := lower-case(data($doc/GeneralReportData/@status)) != "completed"

    return
        if ($err_flag) then
            uiutil:buildRuleResult("status", "", $err_text, $xmlconv:BLOCKER, $err_flag, (), "")
        else 
            let $transactionYear := string(data($doc/GeneralReportData/TransactionYear))
            let $actualTransactionYears :=
                for $actualYear in 2015 to fn:year-from-date(fn:current-date()) - 1
                return string($actualYear)
            let $year_err_flag := not($transactionYear = $actualTransactionYears)
            let $year_err_msg_template := "The data in the submitted envelope refers to a year for which reporting is no longer possible ([year]). If you loaded your previous year's report in order to use it this year, please open the form in order to adjust the year and revise the values, even if your numbers may be identical to last year."  
            let $year_err_msg := replace($year_err_msg_template, "\[year\]", $transactionYear)
            return uiutil:buildRuleResult("status", "", $year_err_msg, $xmlconv:BLOCKER, $year_err_flag, (), "")
};

declare function xmlconv:qc2403($doc as element()) as element(div)* {
    (: QC_2403 :)
    let $err_text := "Based on the reported numbers, your available HFC quota (9G) may not suffice to cover the non-exempted HFC amounts that were placed on the market (9F). Please check your reported data in order to avoid erroneous reporting. Note that the European Commission (DG CLIMA) will assess your company’s quota compliance in co-operation with your Member State’s competent authorities. Failure to comply may result in reductions in future quota allocation and in penalties according to national law of the Member State concerned."
    let $threshold := 100
    return 
        let $tr09F := cutil:if-number($doc/F4_S9_IssuedAuthQuata/tr_09F/Amount, 0)
        let $tr09G := cutil:if-number($doc/F4_S9_IssuedAuthQuata/tr_09G/Amount, 0)
        return
            if($tr09F >= $threshold) then 
                if($tr09F <= $tr09G) then
                    ()
                else 
                    uiutil:buildRuleResult("2403", "09F", $err_text, $xmlconv:COMPLIANCE, true(), (), "")
            else
                ()
};

declare function xmlconv:qc2404($doc as element()) as element(div)* {
(: QC-2404 :)
    let $errorText := "According to the HFC Registry, authorisations have been issued to equipment importers by your undertaking (see section 9), but not included in this report. Please select the Auth activity (Supplier of Authorisations) on the Activities page and review the values in section 9. Keep in mind that incomplete reporting on authorisations may distort the preliminary quota assessment based on this report."
    let $tr09ARegistry := cutil:if-number($doc/F4_S9_IssuedAuthQuata/tr_09A_Registry/Amount,0)
    let $isAuth := cutil:is-activity-selected($doc/GeneralReportData/Activities/auth)
    return
        if($tr09ARegistry > 0) then
            if( $isAuth  ) then
                ()
            else
                uiutil:buildRuleResult("2404", "09A", $errorText, $xmlconv:COMPLIANCE, true(), (), "")
        else
            ()
};

declare function xmlconv:qc24041($doc as element()) as element(div)* {
(: QC-24041 :)
    let $errorText := "By adding data in section 9A_add you are trying to report an authorisation that is not registered in the HFC registry. Please do not repeat in 9A_add authorisations that are covered in the HFC registry and contained in the data of section 9A_imp.
    There should be no need for reporting authorisations outside the scope of 9A_imp, as authorisations can only be used by the recipient to cover their equipment imports in case the authorisation was duly registered in the HFC registry by 31 December.
If you are sure that your report should deviate in section 9A from the data as given in 9A_imp, please add a comment to explain why your authorisations were not registered in the HFC registry. You must be able to provide proof during quota compliance checking at a later time."


    let $qcStatus :=
        for  $TradePartner in $doc/F4_S9_IssuedAuthQuata/tr_09A_add/TradePartner
        return
            if ( cutil:if-number($TradePartner/amount, 0 ) != 0 and  fn:string-length($TradePartner/Comment) < 2 ) then
                1
            else
                ()
    return
        if ( exists($qcStatus) ) then
            uiutil:buildRuleResult("24041", "09A_add", $errorText, $xmlconv:COMPLIANCE, true(), (), "")
        else
            ()

};

declare function xmlconv:qc24042($doc as element()) as element(div)* {
(: QC-24042 :)
    let $errorText := "In section 9A you are reporting on authorisations that deviate from those registered in the HFC Registry. Please note that the European Commission will decide on a case by case basis whether such deviations from the Registry are acceptable. Keep in mind that incorrect reporting on authorisations may distort the automatic preliminary calculation of quota demand based on this report."
    let $qcStatus :=
        for $TradePartner in $doc/F4_S9_IssuedAuthQuata/tr_09A_add/TradePartner
        return
            if ( cutil:if-number($TradePartner/amount, 0 ) != 0 and  fn:string-length($TradePartner/Comment) > 2 ) then
                1
            else
                ()
    return
        if ( exists($qcStatus) ) then
            uiutil:buildRuleResult("24042", "09A_add", $errorText, $xmlconv:COMPLIANCE, true(), (), "")
        else
            ()

};

declare function xmlconv:qc24043($doc as element()) as element(div)* {
(: QC-2404 :)
    let $errorText := "You have reported authorisations in section 9A_add in addition to those registered in the HFC Registry. Your additions are negative in sum, which means that the total sum of authorisations in your report will not completely account for your authorisations registered in the HFC registry. Please check whether the data reported in section 9A_add are complete before submitting. Keep in mind that incomplete reporting on authorisations may distort the automatic preliminary calculation of quota demand based on this report."
    let $tr09A_Add_Sum := cutil:sum-numbers($doc/F4_S9_IssuedAuthQuata/tr_09A_add/TradePartner/amount)
    return
        if ( $tr09A_Add_Sum >= 0 ) then
            ()
        else
            uiutil:buildRuleResult("24043", "09A_add", $errorText, $xmlconv:COMPLIANCE, true(), (), "")
};

declare function xmlconv:qc2405($doc as element()) as element(div)* {
(: QC-2405 :)
    let $err_text := "Please note that authorisations issued to your own company are not deemed acceptable by the European Commission. Thus, the use of such self-authorisations to cover equipment imports charged with HFCs may be rejected during quota compliance checks."
    let $partners := $doc/F4_S9_IssuedAuthQuata/tr_09A_add_TradePartners/Partner
    let $reportingCompany := $doc/GeneralReportData/Company
    let $companyId := fgases:get-own-tradepartner-id($doc, $reportingCompany, $partners)
    return
        if(string-length($companyId) =0 ) then
            ()
        else
            let $ownAmount := $doc/F4_S9_IssuedAuthQuata/tr_09A/TradePartner[TradePartnerID=$companyId and amount castable as xs:integer and xs:integer(amount) > 0]
            let $condition := count($ownAmount) > 0
            return
                if($condition) then
                    uiutil:buildRuleResult("2405", "09A", $err_text, $xmlconv:COMPLIANCE, true(), (), "")
                else
                    ()
};

declare function xmlconv:qc2406($doc as element()) as element(div)* {
(: QC-2406 :)
    let $errorText := "The physical supplies reported in section 10A do not suffice to cover the given authorisations as reported in section 9A. This would imply that you may have given away more authorisations than you were entitled. This may be followed up by the European Commission or Member State authorities in the context of quota compliance checks. Please revisit your data reported in sections 9A and 10A in order to avoid erroneous reporting."
    let $sumOfS2 := cutil:sum-numbers($doc/F5_S10_Auth_NER/SumOfAllHFCsS2/tr_10A/Amount)
    let $sumOfS3 := cutil:sum-numbers($doc/F4_S9_IssuedAuthQuata/tr_09A_add/TradePartner/amount) +
            cutil:sum-numbers($doc/F4_S9_IssuedAuthQuata/tr_09A_imp/TradePartner/amount)
    let $isAuthNERSelected := cutil:is-activity-selected($doc/GeneralReportData/Activities/auth-NER)
    return
        if($isAuthNERSelected and $sumOfS2 < $sumOfS3) then
            uiutil:buildRuleResult("2406", "09A", $errorText, $xmlconv:COMPLIANCE, true(), (), "")
        else
            ()
};

(:
    End of rules
:)

declare function xmlconv:validateReport($url as xs:string)
as element(div)
{
    let $doc := fn:doc($url)/FGasesReporting
    let $rStatus := xmlconv:rule_ReportStatus($doc)
    let $r2403 := xmlconv:qc2403($doc)
    let $r2404 := xmlconv:qc2404($doc)
    let $r24041 := xmlconv:qc24041($doc)
    let $r24042 := xmlconv:qc24042($doc)
    let $r24043 := xmlconv:qc24043($doc)
    let $r2405 := xmlconv:qc2405($doc)
    let $r2406 := xmlconv:qc2406($doc)
    return
        <div class="errors">
            {$rStatus}
            {$r2403}
            {$r2404}
            {$r24041}
            {$r24042}
            {$r24043}
            {$r2405}
            {$r2406}
        </div>
};

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
(:
 : ======================================================================
 : Main function
 : ======================================================================
 :)
declare function xmlconv:proceed($source_url as xs:string)
as element(div){
    let $sourceDocAvailable := doc-available($source_url)

    let $results := if ($sourceDocAvailable) then xmlconv:validateReport($source_url) else ()

    let $class := if ($sourceDocAvailable) then  xmlconv:getMostCriticalErrorClass($results) else ()
    let $errorText :=  if ($sourceDocAvailable) then  xmlconv:getErrorText($class) else ""

    let $resultErrors :=  if ($sourceDocAvailable) then  uiutil:getResultErrors($results) else ()

    (: Display all QC messages for maximum possible feedback to the user #68660 :)
    let $hasOnlyStatusError := false()

    return
        if ($sourceDocAvailable) then
            xmlconv:buildScriptResult($results, $class, $errorText, $hasOnlyStatusError, $xmlconv:cssStyle)
        else
            uiutil:buildDocNotAvailableError($source_url)
};

(:
Return report validation message depending on the num and type of error items.
:)
declare function xmlconv:getReportValidationMessage($blockerItems as element()*, 
    $warningItems as element()*, $infoItems as element()*) as xs:string {
    
    if (count($blockerItems) > 0 ) then
        "The delivery is not acceptable. Please see the QA output."
    else if (count($warningItems) > 0 ) then
        "The delivery is acceptable but some of the information has to be checked. Please see the QA output."
    else if (count($infoItems) > 0 ) then
        "The delivery is acceptable."
    else
        "The delivery status is unknown."
    
};
declare function xmlconv:buildScriptResult($ruleResults as element(div)*, $highestErrorClass as xs:string, $errText as xs:string,
        $onlyStatusError as xs:boolean, $css as element(style))
as element(div)
{
    let $resultErrors := uiutil:getResultErrors($ruleResults)
    let $reportCount := count($ruleResults/@key)
    let $errorCount := count($resultErrors)
    let $hasErrors := $errorCount > 0

    let $blockingItems := uiutil:getBlockingItems($ruleResults)
    let $warningItems := uiutil:getWarningItems($ruleResults)
    let $complianceItems := uiutil:getComplianceItems($ruleResults)
    let $infoItems := uiutil:getInfoItems($ruleResults)
    let $blockingItemCaption := if(count($blockingItems) > 0) then <h4 class="error-caption">Blocking errors details</h4> else ()
    let $warningItemCaption := if(count($warningItems) > 0) then <h4 class="warning-caption">Other potential errors details</h4> else ()
    let $complianceItemCaption := if(count($complianceItems) > 0) then <h4 class="compliance-caption">HFC quota compliance warnings details</h4> else ()
    return
        <div class="feedbacktext">
            {$css}
            {uiutil:buildFBStatusSpan($highestErrorClass, $errText)}
            <h2 class="general-message" i18n:translate="">Validation report for Quota Compliance Checks</h2>

            <div id="feedBackDiv" style="display:{if ($hasErrors or $onlyStatusError) then 'block' else 'none'}">
                {
                    if ( count($resultErrors) < 0 ) then
                        uiutil:buildValidMessage("The validation is passed successfully.")
                    else

                        <div class="errors">
                            {xmlconv:buildTableOfContents($resultErrors)}
                            {$complianceItemCaption}
                            {$complianceItems}
                        </div>

                }
            </div>
        </div>

};


declare function xmlconv:buildTableOfContents($resultErrors as element(span)*)
as element(ul)
{
    let $rules :=
        <rules>
            <rule code="COMPLIANCE">
                <title>HFC quota compliance warnings:</title>
                <descr>Data reported implies that your company might not be in compliance with the HFC quota/authorisation requirements laid down in the F-Gas Regulation 517/2014. Please check the detailed warning messages below and consider a resubmission.</descr>
                <rulefine>No HFC quota compliance warnings</rulefine>
                <error_level>2</error_level>
            </rule>
        </rules>

    return
        <ul>{
            for $rule at $pos in $rules//rule
            let $countErrors := count($resultErrors[@errorLevel = data($rule/@code)])
            return
                <li style="list-style-type:none;list-style-image: none;">{ uiutil:buildErrorBullet($countErrors, $rule/title, $rule/@code) }&#32;&#32;<span style="font-weight:bold"><span i18n:translate="">{ data($rule/title) }</span></span>&#32;<span i18n:translate="">{ if ($countErrors = 0) then data($rule/rulefine) else data($rule/descr) }</span>&#32;
                </li>
        }</ul>
};


xmlconv:proceed( $source_url )


