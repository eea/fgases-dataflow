xquery version "1.0" encoding "UTF-8";
(:
 : Module Name: FGases dataflow (Main module)
 :
 : Version:     $Id: fgases-2017.xquery 22084 2017-03-10 13:31:33Z katsanas $
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
                for $actualYear in 2017 to fn:year-from-date(fn:current-date()) - 1
                return string($actualYear)
            let $year_err_flag := not($transactionYear = $actualTransactionYears)
            let $year_err_msg_template := "The data in the submitted envelope refers to a year for which reporting is no longer possible ([year]). If you loaded your previous year's report in order to use it this year, please open the form in order to adjust the year and revise the values, even if your numbers may be identical to last year."  
            let $year_err_msg := replace($year_err_msg_template, "\[year\]", $transactionYear)
            return uiutil:buildRuleResult("status", "", $year_err_msg, $xmlconv:BLOCKER, $year_err_flag, (), "")
};

declare function xmlconv:qc2002($report as element())
as element(div) ?
{
    let $errorText := 'You selected "HFC producer"in the activity selection. Please report on production of HFCs in section 1A or unselect the activity.'
    return
        if(not(fgases:is-P-HFC($report))) then
            ()
        else
            let $gasAmounts1A := fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_01A")
            let $gases:=
                for $gas in $gasAmounts1A
                    let $reportedGas := fgases:get-reported-gas-by-id($report, $gas/gasId)
                    let $amount := fgases:get-amount-of-gas-amount($gas)
                where not(fgases:is-blend($reportedGas)) and not(fgases:is-unspecified-mix($reportedGas)) and fgases:contains-HFC($reportedGas) and $amount > 0
                return $gas
            return
                if (count($gases) > 0) then
                    ()
                else
                    uiutil:buildRuleResult("2002", "1A", $errorText, $xmlconv:BLOCKER, true(), (), "")
};

declare function xmlconv:qc2003($report as element())
as element(div) ?
{
    let $errorText := 'You selected "non-HFC producer" in the activity selection. Please report on production of non-HFCs in section 1A or unselect the activity.'
    return
        if(not(fgases:is-P-other($report))) then
            ()
        else
            let $gasAmounts1A := fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_01A")
            let $gases:=
                for $gas in $gasAmounts1A
                    let $reportedGas := fgases:get-reported-gas-by-id($report, $gas/gasId)
                    let $amount := fgases:get-amount-of-gas-amount($gas)
                    where not(fgases:is-blend($reportedGas)) and not(fgases:is-unspecified-mix($reportedGas)) and not(fgases:contains-HFC($reportedGas)) and $amount > 0
                    return $gas
            return
                if (count($gases) > 0) then
                    ()
                else
                    uiutil:buildRuleResult("2003", "1A", $errorText, $xmlconv:BLOCKER, true(), (), "")
};


declare function xmlconv:qc2004($report as element())
as element(div)*
{
    let $errorText := 'You selected "HFC importer" in the activity selection. Please report on import of HFCs or HFC-conatining mixtures in section 2A or unselect the activity.'
    return
        if(not(fgases:is-I-HFC($report))) then
            ()
        else
            let $gasAmounts2A := fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_02A")
            let $gases:=
                for $gas in $gasAmounts2A
                    let $reportedGas := fgases:get-reported-gas-by-id($report, $gas/gasId)
                    let $amount := fgases:get-amount-of-gas-amount($gas)
                    where not(fgases:is-blend($reportedGas)) and not(fgases:is-unspecified-mix($reportedGas)) and (fgases:contains-HFC($reportedGas)) and $amount > 0
                    return $gas
            return
                if (count($gases) > 0) then
                    ()
                else
                    let $gasAmounts4 := ( fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_04A") , fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_04B") , fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_04C") )
                    let $gases:=
                        for $gas in $gasAmounts4
                        let $reportedGas := fgases:get-reported-gas-by-id($report, $gas/gasId)
                        let $amount := fgases:get-amount-of-gas-amount($gas)
                            where not(fgases:is-blend($reportedGas)) and not(fgases:is-unspecified-mix($reportedGas)) and (fgases:contains-HFC($reportedGas)) and ( $amount > 0 or $gas/amount = '0' )
                        return $gas

                    return
                        if ( count($gases) > 0 ) then
                            ()
                        else
                            uiutil:buildRuleResult("2004", "2A", $errorText, $xmlconv:BLOCKER, true(), (), "")
};


declare function xmlconv:qc2005($report as element())
as element(div)*
{
    let $errorText := 'You selected "non-HFC importer" in the activity selection. Please report in section 2A on import of non-HFCs or mixtures not containing HFCs or unselect the activity.'
    return
        if(not(fgases:is-I-other($report))) then
            ()
        else
            let $gasAmounts2A := fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_02A")
            let $gases:=
                for $gas in $gasAmounts2A
                    let $reportedGas := fgases:get-reported-gas-by-id($report, $gas/gasId)
                    let $amount := fgases:get-amount-of-gas-amount($gas)
                    where not(fgases:is-blend($reportedGas)) and not(fgases:is-unspecified-mix($reportedGas)) and not(fgases:contains-HFC($reportedGas)) and $amount > 0
                    return $gas
            return
                if (count($gases) > 0) then
                    ()
                else
                    let $gasAmounts4 := ( fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_04A") , fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_04B") , fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_04C") )
                    let $gases:=
                        for $gas in $gasAmounts4
                        let $reportedGas := fgases:get-reported-gas-by-id($report, $gas/gasId)
                        let $amount := fgases:get-amount-of-gas-amount($gas)
                        where not(fgases:is-blend($reportedGas)) and not(fgases:is-unspecified-mix($reportedGas)) and not(fgases:contains-HFC($reportedGas)) and ($amount > 0 or $gas/amount = '0' )
                        return $gas

                    return
                        if ( count($gases) > 0 ) then
                            ()
                        else
                            uiutil:buildRuleResult("2005", "2A", $errorText, $xmlconv:BLOCKER, true(), (), "")
};


declare function xmlconv:qc2006($report as element())
as element(div)*
{
    let $errorText := 'You selected "Exporter" in the activity selection. Please report on export in section 3A or unselect the activity.'

    let $sum_tr03A:= fgases:sum-of-gas-for-transaction($report/F1_S1_4_ProdImpExp, "tr_03A")
    let $authIsSelected := cutil:is-activity-selected($report/GeneralReportData/Activities/E)

    return
        if($sum_tr03A > 0) then
            ()
        else
            if($authIsSelected and  $sum_tr03A = 0) then
                uiutil:buildRuleResult("2006", "3A", $errorText, $xmlconv:BLOCKER, true(), (), "")
            else
                ()
};

(:declare function xmlconv:qc2007($doc as element()) as element(div)* {:)
    (: apply to QC 2007 :)
    (:let $errorText := 'You selected "Provider of authorisations to other companies" in the activity selection. Please report on authorisations that were given out in section 9A or unselect the activity.':)
    (:let $authIsSelected := cutil:is-activity-selected($doc/GeneralReportData/Activities/auth):)
    (:let $amounts := $doc/F4_S9_IssuedAuthQuata/tr_09A/TradePartner/amount:)
    (:return:)
        (:if(not(count($amounts) > 0)) then:)
            (:():)
        (:else:)
            (:let $sumOfPartnerAmounts := cutil:sum-numbers($amounts):)
            (:return:)
                (:if($authIsSelected and  $sumOfPartnerAmounts = 0) then:)
                    (:uiutil:buildRuleResult("2007", "09A", $errorText, $xmlconv:BLOCKER, true(), (), ""):)
                (:else:)
                    (:():)
(:};:)

declare function xmlconv:qc2008($report as element())
as element(div)*
{
    let $errorText := 'You selected "Feedstock user" in the activity selection. Please report on feedstock use in section 7A or unselect the activity.'

    let $sum_tr07A:= fgases:sum-of-gas-for-transaction($report/F6_FUDest, "tr_07A")
    let $authIsSelected := cutil:is-activity-selected($report/GeneralReportData/Activities/FU)
    return
        if($sum_tr07A > 0) then
            ()
        else
            if($authIsSelected and  $sum_tr07A = 0) then
                uiutil:buildRuleResult("2008", "7A", $errorText, $xmlconv:BLOCKER, true(), (), "")
            else
                ()
};


declare function xmlconv:qc2009($report as element())
as element(div)*
{
    let $errorText := 'You selected "Destruction company" in the activity selection. Please report on destruction in section 8 or unselect the activity.'

    let $sum_tr08D:= fgases:sum-of-gas-for-transaction($report/F6_FUDest, "tr_08D")
    let $authIsSelected := cutil:is-activity-selected($report/GeneralReportData/Activities/D)

    return
        if($sum_tr08D > 0) then
            ()
        else
            if($authIsSelected and  $sum_tr08D = 0) then
                uiutil:buildRuleResult("2009", "8D", $errorText, $xmlconv:BLOCKER, true(), (), "")
            else
                ()
};

declare function xmlconv:qc2010($report as element())
as element(div)*
{
    let $errorText := 'You selected "Importer of refrigeration, air conditioning or heat pump equipment pre-charged with HFCs or HFC-containing mixtures" in the activity selection. Please report on HFCs or HFC-containing mixtures in section 11A-11F or unselect the activity.'
    return
        if(not(fgases:is-Eq-I-RACHP-HFC($report))) then
            ()
        else
            let $gases := fgases:get-gas-amounts($report/F7_s11EquImportTable, "tr_11G")
            let $total :=
                for $gas in $gases
                    let $reportedGas := fgases:get-reported-gas-by-id($report, $gas/gasId)

                where fgases:contains-HFC($reportedGas)
                return $gas/amount
            return
                if(sum($total) > 0) then
                    ()
                else
                    uiutil:buildRuleResult("2010", "11G", $errorText, $xmlconv:BLOCKER, true(), (), "")

};

declare function xmlconv:qc2011($report as element())
as element(div)*
{

    let $errorText := 'You selected "Importer of other products or equipment" in the activity selection. Please report on section 11H-11P or on non-HFCs or mixtures not containing HFCs in section 11A-11F or unselect the activity.'

    return
        if(not(fgases:is-Eq-I-other($report))) then
            ()
        else
            let $sum11G :=  fgases:sum-gas-amounts-of-non-HFC-gases($report, $report/F7_s11EquImportTable, "tr_11G")
            let $sum11H1 := fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11H1")
            let $sum11H2 := fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11H2")
            let $sum11H3 := fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11H3")
            let $sum11H4 := fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11H4")
            let $sum11I :=  fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11I")
            let $sum11J :=  fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11J")
            let $sum11K :=  fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11K")
            let $sum11L :=  fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11L")
            let $sum11M :=  fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11M")
            let $sum11N :=  fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11N")
            let $sum11O :=  fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11O")
            let $sum11P :=  fgases:sum-of-gas-for-transaction($report/F7_s11EquImportTable, "tr_11P")
            return
                if($sum11G > 0 or $sum11H1 > 0 or $sum11H2 > 0 or $sum11H3 > 0 or $sum11H4 > 0 or $sum11I > 0 or $sum11J > 0 or $sum11K > 0 or $sum11L > 0 or $sum11M > 0 or $sum11N > 0 or $sum11O > 0 or $sum11P > 0) then
                    ()
                else
                    uiutil:buildRuleResult("2011", "11G", $errorText, $xmlconv:BLOCKER, true(), (), "")


};

declare function xmlconv:qc2016($doc as element())
as element(div)* {

  (: apply to rule 2016 :)

  let $err_text := "You reported on own destruction in section 1B. Please accordingly select to
      be a destruction company in the activity selection and report subsequently in section 8."

  let $err_flag :=
      sum($doc/F1_S1_4_ProdImpExp/Gas/tr_01B/cutil:getZeroIfNotNumber(Amount)) > 1000
    and $doc/GeneralReportData/Activities/D != 'true'

  return uiutil:buildRuleResult("2016", "1B", $err_text, $xmlconv:BLOCKER, $err_flag, (), "")
};


declare function xmlconv:qc2017($doc as element(), $tran as xs:string)
as element(div)* {

  (: apply to rule 2017 :)

  let $err_text := "A negative amount here is implausible, please revise your data."

  let $err_flag :=
    for $gas in $doc/F1_S1_4_ProdImpExp/Gas
    where $gas/*[name()=concat('tr_0', $tran)][Amount castable as xs:decimal and number(Amount) < 0]
    return
      data($doc/ReportedGases[GasId = $gas/GasCode]/Name)

  return uiutil:buildRuleResult("2017", $tran, $err_text, $xmlconv:BLOCKER, count($err_flag)>0, $err_flag, "Invalid gases are: ")
};


declare function xmlconv:qc2018($report as element())
as element(div)* {

    let $err_text := "The partial amounts reported for export in section 3 must not exceed the total reported in section 3A. Please revise your data."

    return
        for $gas in $report/F1_S1_4_ProdImpExp/Gas
            let $tr_3A := cutil:numberIfEmpty($gas/tr_03A/Amount, 0)
            let $tr_3D := cutil:numberIfEmpty($gas/tr_03D/Amount, 0)
            let $tr_3E := cutil:numberIfEmpty($gas/tr_03E/Amount, 0)
            let $tr_3F := cutil:numberIfEmpty($gas/tr_03F/Amount, 0)
        where not($tr_3A >= sum(($tr_3D, $tr_3E, $tr_3F)))
        return uiutil:buildRuleResult("2018", "3A" , $err_text, $xmlconv:BLOCKER, true(), (),"")
};

declare function xmlconv:qc2020($report as element())
as element(div)* {

    let $isD := $report/GeneralReportData/Activities/D = 'true'
    let $isP := $report/GeneralReportData/Activities/P = 'true'
    let $isI := $report/GeneralReportData/Activities/I = 'true'

    let $err_text := "The stocks of [gas] awaiting destruction on 1 Jan (section 8E) exceed the total stocks reported in section 4A."
    return
        if(not($isD and ($isP or $isI))) then
            ()
        else
            for $gas in $report/F1_S1_4_ProdImpExp/Gas
                let $gasCode := $gas/GasCode
                let $reportedGas := fgases:get-reported-gas-by-id($report, $gasCode)
                let $tr_4A := cutil:numberIfEmpty($gas/tr_04A/Amount, 0)
                let $tr_08EAmount := cutil:numberIfEmpty($report/F6_FUDest/Gas[GasCode=$gasCode]/tr_08E/Amount, 0)
            return
                if($tr_4A >= $tr_08EAmount) then
                    ()
                else
                let $err_text := replace($err_text, "\[gas\]", string($reportedGas/Name))
                return
                    uiutil:buildRuleResult("2020", "4A" , $err_text, $xmlconv:BLOCKER, true(), (),"")
};

declare function xmlconv:qc2023($report as element())
as element(div)* {

    let $isD := $report/GeneralReportData/Activities/D = 'true'
    let $isP := $report/GeneralReportData/Activities/P = 'true'
    let $isI := $report/GeneralReportData/Activities/I = 'true'

    let $err_text := "The stocks of [gas] awaiting destruction on 31 Dec (section 8F) exceed the total stocks reported in section 4F."
    return
        if( not($isD and ($isP or $isI))) then
            ()
        else
            for $gas in $report/F1_S1_4_ProdImpExp/Gas
                let $gasCode := $gas/GasCode
                let $reportedGas := fgases:get-gas-by-id($gasCode)
                let $tr04F := cutil:numberIfEmpty($gas/tr_04F/Amount, 0)
                let $tr08F := cutil:numberIfEmpty($report/F6_FUDest/Gas[GasCode=$gasCode]/tr_08F/Amount, 0)
            where fgases:is-P($report) or fgases:is-I($report) or not(fgases:contains-HFC($reportedGas))
            return
                if($tr04F >= $tr08F) then
                    ()
                else
                    let $err_text := replace($err_text, "\[gas\]", string($reportedGas/Name))
                return
                    uiutil:buildRuleResult("2023", "4F" , $err_text, $xmlconv:BLOCKER, true(), (),"")
};

declare function xmlconv:qc2024($report as element())
as element(div)* {
    let $err_text := "The increase in stocks between 1st January and 31st December appears to be implausibly high. Please revise data or add an explanation to the 31st December value."
    return
        for $gas in $report/F1_S1_4_ProdImpExp/Gas
            let $reportedGas := fgases:get-reported-gas-by-id($report, $gas/GasCode)
            let $tr_4G := cutil:numberIfEmpty($gas/tr_04G/Amount, 0)
            let $tr_1E := cutil:numberIfEmpty($gas/tr_01E/Amount, 0)
            let $tr_2A := cutil:numberIfEmpty($gas/tr_02A/Amount, 0)
            let $tr_4B := cutil:numberIfEmpty($gas/tr_04B/Amount, 0)
            let $errorType := if(fn:string-length($gas/tr_04G/Comment) > 0) then $xmlconv:WARNING else $xmlconv:BLOCKER
        where
            fgases:is-section-4-applicable-gas($report, $reportedGas)
            and $tr_4G > 0
            and not($tr_4G <= round-half-to-even(sum(($tr_1E, $tr_2A, $tr_4B)), 3))
        return uiutil:buildRuleResult("2024", "4G" , $err_text, $errorType, true(), (),"")
};

declare function xmlconv:qc2025($report as element())
as element(div)* {
    let $err_text := "The increase in stocks between 1st January and 31st December appears to be implausibly high. Please revise data or add an explanation toi the 31st December value."

    return
        for $gas in $report/F1_S1_4_ProdImpExp/Gas
            let $tr_4H := cutil:numberIfEmpty($gas/tr_04H/Amount, 0)
            let $tr_1E := cutil:numberIfEmpty($gas/tr_01E/Amount, 0)
            let $tr_2A := cutil:numberIfEmpty($gas/tr_02A/Amount, 0)
            let $tr_4C := cutil:numberIfEmpty($gas/tr_04C/Amount, 0)
            let $errorType := if(fn:string-length($gas/tr_04H/Comment) > 0) then $xmlconv:WARNING else $xmlconv:BLOCKER
        where
            $tr_4H > 0 and $tr_4H > sum( ($tr_1E, $tr_2A, $tr_4C) )
        return uiutil:buildRuleResult("2025", "4H" , $err_text, $errorType, true(), (),"")
};


declare function xmlconv:qc2026($doc as element())
as element(div)* {

    (: apply to rule 2026 :)

    let $err_text := "It is not plausible that the amount in section 4M (amount placed on the market, determined from reported values) is smaller than the increase of stocks that are already placed on the market during the reporting year (determined from 4I and 4D). Please double-check and revise your data reported in sections 1 – 4."

    let $err_flag :=
        for $gas in $doc/F1_S1_4_ProdImpExp/Gas
        where not ( cutil:getZeroIfNotNumber($gas/*[name()='tr_04M']/Amount)  >=
                cutil:getZeroIfNotNumber($gas/*[name()='tr_04I']/Amount) - cutil:getZeroIfNotNumber($gas/*[name()='tr_04D']/Amount) )
    return
        data($doc/ReportedGases[GasId = $gas/GasCode]/Name)

    return uiutil:buildRuleResult("2026", "4M", $err_text, $xmlconv:BLOCKER, count($err_flag)>0, $err_flag, "Invalid gases are: ")
};

declare function xmlconv:qc2028 ($doc as element())
as element(div)*
{
(: apply to rule 2028 :)
    let $errorText := "You reported import for own destruction in section 5A. Please accordingly select to be a destruction company in the activity selection and report subsequently in section 8 or add an explanation in section 5A."
    let $isD := $doc/GeneralReportData/Activities/D = 'true'
    let $sumThreshold := 1
    let $sumOfAllCO2EqThreshold := 1000
    return
        if($isD) then
            ()
        else
            let $companyData := $doc/GeneralReportData/Company
            let $partnerId :=
                for $tradePartnerData in $doc/F2_S5_exempted_HFCs/tr_05A_TradePartners/Partner
                where cutil:isOnwCompany($companyData, $tradePartnerData)
                return $tradePartnerData/PartnerId
            let $companyId := distinct-values($partnerId)
            return
                if(empty($companyId)) then
                    ()
                else
                    let $gasAmounts := $doc/F2_S5_exempted_HFCs/Gas/tr_05A/TradePartner[TradePartnerID=$companyId]
                    return
                        if(count($gasAmounts) = 0) then
                            ()
                        else
                            let $total := for $item in $gasAmounts return cutil:numberIfEmpty($item/amount, 0)
                            let $sum := sum($total)
                            return
                                let $erroLevel := if(count($gasAmounts[not(cutil:isMissingOrEmpty(Comment))]) > 0) then
                                    $xmlconv:WARNING
                                else
                                    $xmlconv:BLOCKER
                                return
                                    if ($sum > $sumThreshold) then
                                        uiutil:buildRuleResult("2028", "05A", $errorText, $erroLevel, true(), (), "")
                                    else
                                        let $sumOfAllCO2Eq := cutil:calculateSumOfAllCO2Eq($doc/ReportedGases, $gasAmounts)
                                        return
                                            if($sumOfAllCO2Eq > $sumOfAllCO2EqThreshold) then
                                                uiutil:buildRuleResult("2028", "05A", $errorText, $erroLevel, true(), (), "")
                                            else
                                                ()

};

declare function xmlconv:qc2029($report)
as element(div)*
{
    let $errorText := "It appears implausible that your import for own destruction reported in 5A exceeds total destruction reported in section 8. Please revise your data or add an explanation in section 5A."
    let $isD := $report/GeneralReportData/Activities/D = 'true'
    return
        if (not($isD)) then
            ()
        else
            let $partners := $report/F2_S5_exempted_HFCs/tr_05A_TradePartners/Partner
            let $ownTradePartnerId := fgases:get-own-tradepartner-id($report, $report/GeneralReportData/Company, $partners)
            return
                if ( string-length($ownTradePartnerId) = 0) then
                    ()
                else
                    for $gas in $report/F2_S5_exempted_HFCs/Gas
                        let $gasCode := $gas/GasCode
                        let $ownTr05AReported := $gas/tr_05A/TradePartner[TradePartnerID = $ownTradePartnerId]
                        let $tr08DAmount := cutil:numberIfEmpty($report/F6_FUDest/Gas[GasCode = $gasCode]/tr_08D/Amount, 0)
                    where not(empty($ownTr05AReported))
                    return
                        let $ownTr05AreportedAmount := cutil:numberIfEmpty($ownTr05AReported/amount, 0)
                        let $errorType :=
                            if(string-length($ownTr05AReported/comment) > 0) then
                                $xmlconv:WARNING
                            else
                                $xmlconv:BLOCKER
                        return
                            if ($ownTr05AreportedAmount <= $tr08DAmount) then
                                ()
                            else
                                uiutil:buildRuleResult("2029", "5A", $errorText, $errorType, true(), (), "")
};

declare function xmlconv:qc2031($doc) as element(div)*
{
(: QC 2031 :)
    let $errorText := "You reported supply for own feedstock use in section 5B. Please accordingly select to be a destruction company in the activity selection and report subsequently in section 7."
    let $isFU := $doc/GeneralReportData/Activities/FU = 'true'
    let $threshold := 1000
    return
        if($isFU) then
            ()
        else
            let $companyData := $doc/GeneralReportData/Company
            let $partnerId :=
                for $tradePartnerData in $doc/F2_S5_exempted_HFCs/tr_05B_TradePartners/Partner
                where cutil:isOnwCompany($companyData, $tradePartnerData)
                return $tradePartnerData/PartnerId
            let $companyId := distinct-values($partnerId)
            return
                if(cutil:isEmptyString($companyId)) then
                    ()
                else
                    let $ownTradePartner := $doc/F2_S5_exempted_HFCs/Gas/tr_05B/TradePartner[TradePartnerID=$companyId]

                    let $gasCode := $ownTradePartner/../../GasCode
                    let $reportedGas := $doc/ReportedGases[GasId=$gasCode]
                    return
                        if(empty($ownTradePartner) or empty($reportedGas)) then
                            ()
                        else
                            let $total :=
                                for $item in $ownTradePartner
                                let $amount := cutil:numberIfEmpty($item/amount, 0)
                                let $co2eq := cutil:calculateSumOfAllCO2Eq($reportedGas, $item)
                                return $co2eq
                            let $sum := sum($total)
                            return
                                if ($sum > $threshold) then
                                    uiutil:buildRuleResult("2031", "05B", $errorText, $xmlconv:BLOCKER, true(), (), "")
                                else
                                    ()

};



declare function xmlconv:qc2040($doc as element())
as element(div)* {

  (: apply to rule 2040 :)

  let $err_text := "Please explain the 'other' intended application
    / why the application is unknown."

  let $err_flag :=
    for $gas in $doc/F3A_S6A_IA_HFCs/Gas
    where $gas/tr_06T[Amount castable as xs:decimal and number(Amount) > 0]
    return
      if (cutil:isEmpty($gas/tr_06T/Comment))
        then data($doc/ReportedGases[GasId = $gas/GasCode]/Name)
        else ()

  return uiutil:buildRuleResult("2040", "6T", $err_text, $xmlconv:BLOCKER, count($err_flag)>0, $err_flag, "Invalid gases are: ")
};


declare function xmlconv:qc2041($doc as element())
as element(div)* {

  (: apply to rule 2041 :)

  let $err_text := "Please provide an explanation for accountancy adjustments."

  let $err_flag :=
    for $gas in $doc/F3A_S6A_IA_HFCs/Gas
    where $gas/tr_06V[Amount castable as xs:decimal and number(Amount) != 0]
    return
      if (cutil:isEmpty($gas/tr_06V/Comment))
        then data($doc/ReportedGases[GasId = $gas/GasCode]/Name)
        else ()

  return uiutil:buildRuleResult("2041", "6V", $err_text, $xmlconv:BLOCKER, count($err_flag)>0, $err_flag, "Invalid gases are: ")
};


declare function xmlconv:qc2042($doc as element())
as element(div)* {

    (: apply to rule 2042 :)

    let $err_text := "The totals reported for intended applications (6W)
    should match the totals reported as placed on the Union market (6X).
    Please revise your data."

    let $err_flag :=
        for $gas in $doc/F3A_S6A_IA_HFCs/Gas
            return
                if(not($gas/tr_06W/Amount castable as xs:double) or not($gas/tr_06X/Amount castable as xs:double)) then
                    ()
                else
                    let $tr06W_Amount := xs:double($gas/tr_06W/Amount)
                    let $tr06X_Amount := xs:double($gas/tr_06X/Amount)
                    return
                        if ($tr06X_Amount != $tr06W_Amount) then
                            data($doc/ReportedGases[GasId = $gas/GasCode]/Name)
                        else
                            ()
    return if(count($err_flag)>0) then
        uiutil:buildRuleResult("2042", "6W", $err_text, $xmlconv:BLOCKER, count($err_flag)>0, $err_flag, "Invalid gases are: ")
    else
        ()
};


declare function xmlconv:qc2043($doc as element())
as element(div)* {

  (: apply to rule 2043 :)

  let $err_text := "The totals calculated in 6X must not be negative.
    Please check amounts reported for production, imports, exports,
    and stocks (sections 1 to 4)."

  let $err_flag :=
    for $gas in $doc/F3A_S6A_IA_HFCs/Gas
    where $gas/tr_06X[Amount castable as xs:decimal and number(Amount) < 0]
    return data($doc/ReportedGases[GasId = $gas/GasCode]/Name)

  return uiutil:buildRuleResult("2043", "6X", $err_text, $xmlconv:BLOCKER, count($err_flag)>0, $err_flag, "Invalid gases are: ")
};

declare function xmlconv:qc20601($doc as element())
as element(div)* {
    let $err_text := "The totals calculated in 6X must match the formula 6x=1E+2A-2B-3B+4B-4G+4K.
    Please check amounts reported for production, imports, exports,
    and stocks (sections 1 to 4)."

    let $err_flag :=
        for $gas in $doc/F3A_S6A_IA_HFCs/Gas
        let $tr_01E_amount := cutil:numberIfEmpty(data($doc/F1_S1_4_ProdImpExp/Gas[GasCode = $gas/GasCode]/tr_01E/Amount), 0)
        let $tr_02A_amount := cutil:numberIfEmpty(data($doc/F1_S1_4_ProdImpExp/Gas[GasCode = $gas/GasCode]/tr_02A/Amount), 0)
        let $tr_02B_amount := cutil:numberIfEmpty(data($doc/F1_S1_4_ProdImpExp/Gas[GasCode = $gas/GasCode]/tr_02B/Amount), 0)
        let $tr_03B_amount := cutil:numberIfEmpty(data($doc/F1_S1_4_ProdImpExp/Gas[GasCode = $gas/GasCode]/tr_03B/Amount), 0)
        let $tr_04B_amount := cutil:numberIfEmpty(data($doc/F1_S1_4_ProdImpExp/Gas[GasCode = $gas/GasCode]/tr_04B/Amount), 0)
        let $tr_04G_amount := cutil:numberIfEmpty(data($doc/F1_S1_4_ProdImpExp/Gas[GasCode = $gas/GasCode]/tr_04G/Amount), 0)
        let $tr_04K_amount := cutil:numberIfEmpty(data($doc/F1_S1_4_ProdImpExp/Gas[GasCode = $gas/GasCode]/tr_04K/Amount), 0)
        where $gas/tr_06X/Amount != $tr_01E_amount + $tr_02A_amount - $tr_02B_amount - $tr_03B_amount +
                $tr_04B_amount - $tr_04G_amount + $tr_04K_amount
        return data($doc/ReportedGases[GasId = $gas/GasCode]/Name)

    return uiutil:buildRuleResult("20430", "6X", $err_text, $xmlconv:BLOCKER,
            count($err_flag) > 0, $err_flag, "Invalid gases are: ")
};

declare function xmlconv:qc2048($report as element())
as element(div)* {
    let $errorText := "Please explain the equipment category."
    let $transactions := ("11A03", "11A09", "11A12", "11B03", "11B05", "11B07", "11B09", "11D01", "11D02", "11D03", "11E04", "11F09")
    for $transaction in $transactions
        let $comment := $report/F7_s11EquImportTable/Category/*[name() = concat("tr_", $transaction)]
        let $hasSelectedCategory := $report/F7_s11EquImportTable/UISelectedTransactions/*[name()=concat("tr_", $transaction)]= 'true'
        let $total :=
            for $item in  fgases:get-gas-amounts($report/F7_s11EquImportTable, concat("tr_", $transaction))
            return  cutil:numberIfEmpty($item/amount, 0)
        let $sum := sum($total)
    where
        $hasSelectedCategory and $sum > 0 and string-length($comment) < 2
    return uiutil:buildRuleResult("2048", $transaction, $errorText, $xmlconv:BLOCKER, true(), (), "")
};

declare function xmlconv:qc2050($doc as element(), $tran as xs:string, $tran_unit as xs:string)
as element(div)* {

  (: apply to rule 2050 :)

  let $err_text := "Please specify a measurement unit for the
    amount of products/equipment imported."

  let $err_flag :=
    if ($doc/F7_s11EquImportTable/UISelectedTransactions/*[name()=concat('tr_', $tran)] = 'true')
      then
        for $gas in $doc/F7_s11EquImportTable/Gas
        where ($gas/*[name()=concat('tr_', $tran)][Amount castable as xs:decimal and number(Amount) > 0])
          return
            if (cutil:isMissingOrEmpty($doc/F7_s11EquImportTable/*[name()=concat('TR_', $tran_unit, '_Unit')]))
              then data($doc/ReportedGases[GasId = $gas/GasCode]/Name)
              else ()
      else ()

  return uiutil:buildRuleResult("2050", $tran, $err_text, $xmlconv:BLOCKER, count($err_flag)>0, $err_flag, "Invalid gases are: ")
};


declare function xmlconv:qc2051($doc as element(), $tran as xs:string)
as element(div)* {

    (: apply to rule 2051 :)

    let $err_text := "You reported on the amount of imported products/equipment. Please report on the amount of contained gases, as well (unit: metric tonnes of gases)."

    let $transactionIsSelected := $doc/F7_s11EquImportTable/UISelectedTransactions/*[name()=concat('tr_', $tran)] = 'true'
    let $amount := $doc/F7_s11EquImportTable/AmountOfImportedEquipment/*[name()=concat('tr_', $tran)]/Amount
    let $invalidGasNames :=
        if ($transactionIsSelected = true() and cutil:isPositiveNumber($amount)) then
            let $sum :=
                for $gas in $doc/F7_s11EquImportTable/Gas/*[name() = concat("tr_", $tran)]
                return cutil:numberIfEmpty($gas/Amount, 0)
            return
                if($sum > 0) then
                    ()
                else
                    let $gasCodes := $doc/F7_s11EquImportTable/Gas[*/name() = concat("tr_", $tran)]/GasCode
                    return
                        for $gasCode in $gasCodes
                        let $gasName := cutil:getGasNameByGasCode($doc, $gasCode)
                        return $gasName

          else
                ()
    return
        if(count($invalidGasNames) > 0) then
            uiutil:buildRuleResult("2051", $tran, $err_text, $xmlconv:BLOCKER, true(), $invalidGasNames, "Invalid gases are: ")
        else
            ()
};

declare function xmlconv:qc2071($report as element())
as element(div)*
{
    let $errorText := "It appears implausible that your supply for own feedstock use reported in 5B exceeds total feedstock use reported in section 7A.
        Please revise your data or add an explanation to your comment in section 5B."
    return
        if(not(fgases:is-FU($report))) then
            ()
        else
            let $ownTradePartnerId := fgases:get-own-tradepartner-id($report,
                    $report/GeneralReportData/Company,
                    $report/F2_S5_exempted_HFCs/tr_05B_TradePartners/Partner)
            return
                if(string-length($ownTradePartnerId) = 0) then
                    ()
                else
                    let $tr05B := fgases:get-gas-amounts-of-trade-partner($report/F2_S5_exempted_HFCs/Gas/tr_05B, $ownTradePartnerId)
                    for $gas in $tr05B
                        let $tr07Amount :=  cutil:numberIfEmpty($report/F6_FUDest/Gas[GasCode=$gas/gasId]/tr_07A/Amount, 0)
                        let $tr05BAmount := cutil:numberIfEmpty($gas/amount, 0)
                        let $errorType := if(fn:string-length($gas/Comment) > 0) then $xmlconv:WARNING else $xmlconv:BLOCKER
                    where $tr05BAmount > 0
                    return
                        if($tr05BAmount <= $tr07Amount ) then
                            ()
                        else
                            uiutil:buildRuleResult("2071", "5B", $errorText, $errorType, true(), (), "")
};

declare function xmlconv:qc2072($report)
as element(div)*
{
    let $errorText := "It appears implausible that destruction of your own by-production (1B) exceeds total destruction reported in section 8. Please revise your data or add an explanation in section 1B."
    return
        if(not(fgases:is-D($report))) then
            ()
        else
            let $tr01BGases := fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_01B" )
            let $tr08DGases := fgases:get-gas-amounts($report/F6_FUDest, "tr_08D" )
            for $gas in $tr01BGases
                let $tr08DSameGas := $tr08DGases[gasId=$gas/gasId]
                let $errorType := if(fn:string-length($gas/Comment) > 0) then $xmlconv:WARNING else $xmlconv:BLOCKER
            where not(empty($tr08DSameGas))
            return
                if(cutil:numberIfEmpty($gas/amount, 0) <= cutil:numberIfEmpty($tr08DSameGas/amount, 0)) then
                    ()
                else
                    uiutil:buildRuleResult("2072", "1B", $errorText, $errorType, true(), (), "")
};

declare function xmlconv:qc2073($report)
as element(div)*
{
    let $errorText := "It appears implausible that destruction of your own by-production (1B) exceeds total destruction reported in section 8. Please revise your data or add an explanation in section 1B."
    let $ownTradePartnerId :=
        fgases:get-own-tradepartner-id($report, $report/GeneralReportData/Company, $report/F2_S5_exempted_HFCs/tr_05A_TradePartners/Partner)
    return
        if(string-length($ownTradePartnerId) = 0) then
            ()
        else
            if(fgases:is-D($report) and fgases:is-I-HFC($report)) then
                let $tr01BGases := fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_01B" )
                let $tr08DGases := fgases:get-gas-amounts($report/F6_FUDest, "tr_08D" )
                for $gas in $tr01BGases
                    let $tr08DSameGas := $tr08DGases[gasId=$gas/gasId]
                    let $tr05AGas := fgases:get-gas-amounts-of-trade-partner($report/F2_S5_exempted_HFCs/Gas/tr_05A, $ownTradePartnerId)
                where $gas/amount > 0
                return
                    let $tr01BAmount := cutil:numberIfEmpty($gas/amount, 0)
                    let $tr08DAmount := cutil:numberIfEmpty($tr08DSameGas/amount, 0)
                    let $tr05AAmount :=
                        if(empty($tr05AGas[gasId=$gas/gasId])) then
                            0
                        else
                            cutil:numberIfEmpty($tr05AGas[gasId=$gas/gasId]/amount, 0)
                    return
                        if( sum($tr01BAmount, $tr05AAmount) <= $tr08DAmount ) then
                            ()
                        else
                            uiutil:buildRuleResult("2073", "1B", $errorText, $xmlconv:BLOCKER, true(), (), "")
            else
                ()
};

declare function xmlconv:rule_09($doc as element(), $tran as xs:string,
                                   $exempt_tran as xs:string, $rule as xs:string)
as element(div)* {

  (: apply to rules 2091, 2092, 2093, 2094, 2095, 2096 :)

  let $err_text := "The amount reported for exempted supply for export in 5C_exempted must
    not exceed the amount reported for the intended application 'export' in 6A.
    Please revise your data."

  let $gases :=
    for $gas in $doc/ReportedGases
    where $gas/IsBlend = 'true'
    return $gas/GasId

  let $err_flag :=
    for $gas in $gases

    let $node_gas := $doc/F3A_S6A_IA_HFCs/Gas[GasCode=$gas]/*[name()=concat('tr_0', $tran)]/Amount
    let $node_exempted := $doc/F2_S5_exempted_HFCs/Gas[GasCode=$gas]/*[name()=concat('tr_0', $exempt_tran)]/SumOfPartnerAmounts

    return
      if (fn:not(cutil:isMissingOrEmpty($node_exempted) or cutil:isMissingOrEmpty($node_gas))
        and $node_gas castable as xs:decimal and $node_exempted castable as xs:decimal and fn:number($node_gas) lt fn:number($node_exempted))
          then data($doc/ReportedGases[GasId eq $gas]/Name)
          else ()

  return uiutil:buildRuleResult($rule, $tran, $err_text, $xmlconv:BLOCKER,
         count($err_flag)>0, $err_flag, "Invalid gases are: ")
};

declare function xmlconv:validateTransactionAmountRange($doc as element(),
                                        $tran as xs:string,
                                        $range_min as xs:decimal,
                                        $range_max as xs:decimal,
                                        $range_unit as xs:string,
                                        $rule as xs:string)
as element(div)* {

    (: apply to rules 2300 :)

    let $err_text := concat("The calculated specific charge of F-gases is not in the expected range
        (", $range_min," and ", $range_max, " ", $range_unit, "). Please make sure you correctly reported the amounts of gases in
        units of tonnes, not in kilograms. Please revise your data or provide an explanation to the
        calculated specific charge.")

    let $warning_text := concat("The calculated specific charge of F-gases per ",$range_unit ," in section ", $tran," is outside the expected range (", $range_min," ",$range_unit," - ",$range_max," ",$range_unit,"). The explanation provided will be taken into account when evaluating the report.")
    let $err_text := concat("The calculated specific charge of F-gases per ",$range_unit," in section ",$tran," is outside the expected range (",$range_min," ",$range_unit," - ",$range_max," ",$range_unit,"). Please make sure you correctly reported the amounts of gases (in units of tonnes, not in kilograms). Please revise your data or provide an explanation to the calculated specific charge.")
    let $transaction := concat('tr_', $tran)
    let $hasValues := cutil:atLeastOneNumber($doc/F7_s11EquImportTable/Gas/*[name()=$transaction])
    return
        if($hasValues) then
                if ($doc/F7_s11EquImportTable/UISelectedTransactions/*[name()= $transaction] = 'true' and
                        fn:not(cutil:isMissingOrEmpty($doc/F7_s11EquImportTable/AmountOfImportedEquipment))) then
                    let $gasAmounts := $doc/F7_s11EquImportTable/Gas/*[name()=$transaction]
                    let $pieces := $doc/F7_s11EquImportTable/AmountOfImportedEquipment/*[name()=$transaction]/Amount
                    return
                        if($pieces castable as xs:double and $pieces > 0) then
                            let $num := cutil:average($gasAmounts, $pieces)
                            let $inRange := cutil:checkInRange($num, $range_min, $range_max)
                            return
                                if($num = 0) then
                                    ()
                                else
                                    if ($inRange) then
                                        ()
                                    else
                                        if (cutil:isMissingOrEmpty($doc/F7_s11EquImportTable/Comment/*[name()=$transaction])) then
                                            uiutil:buildRuleResult($rule, $tran, $err_text, $xmlconv:BLOCKER, true(), (), "")
                                        else
                                            uiutil:buildRuleResult($rule, $tran, $warning_text, $xmlconv:WARNING, true(), (), "")
                        else
                            ()
                else
                    ()
        else
            ()
};

declare function xmlconv:sumForm7GasesPerTransaction($doc, $transaction)
{
    let $elems := $doc/F7_s11EquImportTable/F7_s11EquImportTable/Gas/*[name()=$transaction]
    let $items := for $item in $elems return if($item/Amount castable as xs:decimal) then number($item/Amount) else 0
    return sum($items)
};

declare function xmlconv:qc2065($doc as element(), $tran as xs:string)
as element(div)* {

  (: apply to rule 2065 :)

  let $err_text := "You reported on the amount of contained gases in imported products/equipment.
      Please report on the amount of imported products/equipment, as well."

  let $gases :=
    if ($doc/F7_s11EquImportTable/UISelectedTransactions/*[name()=concat('tr_', $tran)] = 'true')
      then
        for $gas in $doc/F7_s11EquImportTable/Gas
        where $gas/*[name()=concat('tr_', $tran)][Amount castable as xs:decimal and number(Amount) > 0]
        return $gas/GasCode
      else ()

  let $amount := $doc/F7_s11EquImportTable/AmountOfImportedEquipment/*[name()=concat('tr_', $tran)]/Amount

  let $err_flag :=
    if (fn:count($gases) > 0 and (cutil:isMissingOrEmpty($amount) or ($amount castable as xs:decimal and number($amount) = 0)))
      then fn:true()
      else fn:false()

  return uiutil:buildRuleResult(
    "2065", $tran, $err_text, $xmlconv:BLOCKER, $err_flag, (), "")
};


declare function xmlconv:qc2079($doc as element())
as element(div)* {

  (: apply to rule 2079 :)

  let $err_text := "Please explain the category of imported products/equipment."

  let $err_flag :=
    if ($doc/F7_s11EquImportTable/UISelectedTransactions/tr_11P = 'true'
      and $doc/F7_s11EquImportTable/SumOfAllGasesS1/tr_11P[Amount castable as xs:decimal and number(Amount) > 0]
      and cutil:isMissingOrEmpty($doc/F7_s11EquImportTable/Category/tr_11P))
      then fn:true()
      else fn:false()

  return uiutil:buildRuleResult("2079", "11P", $err_text, $xmlconv:BLOCKER, $err_flag, (), "")
};


declare function xmlconv:qc2078($doc as element())
as element(div)* {

  (: apply to rule 2078 :)

  let $err_text := "A negative amount here is implausible, please revise your data."

  let $gases :=
    for $gas in $doc/ReportedGases
    where $gas/IsBlend = 'true'
    return $gas/GasId

  let $err_flag :=
    for $gas in $gases
    return
      if ($doc/F1_S1_4_ProdImpExp/Gas[GasCode=$gas]/tr_01H[Amount castable as xs:decimal and number(Amount) < 0])
        then data($doc/ReportedGases[GasId eq $gas]/Name)
        else ()

  return uiutil:buildRuleResult("2078", "1H", $err_text, $xmlconv:BLOCKER,
         count($err_flag)>0, $err_flag, "Invalid gases are: ")
};

declare function xmlconv:qc2087($doc as element())
as element(div)?
{
    let $errorText := "Please explain the category of imported foam products."
    let $gasAmounts := for $item in $doc/F7_s11EquImportTable/Gas/tr_11H04 return cutil:numberIfEmpty($item/Amount, 0)
    let $sum11H04 := sum($gasAmounts)
    return
        if($sum11H04 > 0) then
                let $tr11H04Category := $doc/F7_s11EquImportTable/Category/tr_11H04
                return
                    if(fn:string-length($tr11H04Category) < 2) then
                        uiutil:buildRuleResult("2087", "11H04", $errorText, $xmlconv:BLOCKER, true(), (), "")
                    else
                        ()
            else
                ()
};

declare function xmlconv:qc2039($doc as element())
as element(div)* {

  (: apply to rule 2080 ?? 2039:)

  let $err_text := "The totals reported for exempted uses in sections 5A - 5F cannot exceed the amount reported as physically placed on the market in sections 1–3, taking changes in stocks (section 4) into account. Please review your data."

  let $err_flag :=
    for $gas in $doc/ReportedGases

      let $sum_4 :=
        cutil:getZeroIfNotNumber($doc/F1_S1_4_ProdImpExp/Gas[GasCode=$gas/GasId]/tr_04M/Amount) +
                cutil:getZeroIfNotNumber($doc/F1_S1_4_ProdImpExp/Gas[GasCode=$gas/GasId]/tr_04D/Amount)

      let $sum_5 :=
          cutil:getZeroIfNotNumber($doc/F2_S5_exempted_HFCs/Gas[GasCode=$gas/GasId]/tr_05G/Amount) +
                  cutil:getZeroIfNotNumber($doc/F2_S5_exempted_HFCs/Gas[GasCode=$gas/GasId]/tr_05R/Amount) +
                  cutil:getZeroIfNotNumber($doc/F1_S1_4_ProdImpExp/Gas[GasCode=$gas/GasId]/tr_04I/Amount)

      where ($sum_5 > $sum_4)
        return data($gas/Name)

  return uiutil:buildRuleResult("2039", "5A", $err_text, $xmlconv:BLOCKER,
         count($err_flag)>0, $err_flag, "Invalid gases are: ")
};

declare function xmlconv:qc2098($doc as element())
as element(div)* {

    (: apply to rule 2098 :)

    let $err_text := "Re-exports in products/equipment (2B) must not exceed the sum of your total imports and 1st January stocks from own import/production not placed on the market (2A + 4C). Please revise your data."

    let $err_flag :=
        for $gas in $doc/ReportedGases
        let $sum := cutil:getZeroIfNotNumber($doc/F1_S1_4_ProdImpExp/Gas[GasCode=$gas/GasId]/tr_02A/Amount) + cutil:getZeroIfNotNumber($doc/F1_S1_4_ProdImpExp/Gas[GasCode=$gas/GasId]/tr_04C/Amount)
        where (cutil:getZeroIfNotNumber($doc/F1_S1_4_ProdImpExp/Gas[GasCode=$gas/GasId]/tr_02B/Amount) > $sum)
        return data($gas/Name)

    return uiutil:buildRuleResult("2098", "2B", $err_text, $xmlconv:BLOCKER, count($err_flag)>0, $err_flag, "Invalid gases are: ")
};

declare function xmlconv:qc2099($report)
as element(div)*
{
    let $errorText := "Destroyed own production (1D) must not exceed the sum of your total production and 1st January stocks from own import/production not placed on the market (1A + 4C). Please revise your data."
    let $tr01DGases := fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_01D" )
    let $tr01AGases := fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_01A" )
    let $tr04CGases := fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, "tr_04C" )
    for $gas in $tr01AGases
        let $gasCode := $gas/gasId
        let $tr01DAmount := cutil:numberIfEmpty($gas/amount, 0)
        let $tr01AAmount := cutil:numberIfEmpty($tr01AGases[gasId=$gasCode]/amount, 0)
        let $tr04CAmount := cutil:numberIfEmpty($tr04CGases[gasId=$gasCode]/amount, 0)
    where
        $tr01DAmount > sum(($tr01AAmount, $tr04CAmount))
    return
        uiutil:buildRuleResult("2099", "1D", $errorText, $xmlconv:BLOCKER, true(), (), "")
};

declare function xmlconv:qc2044($doc as element()) as element(div)* {
    (: apply to QC 2044 :)
    let $errorText := "According to your figures, you placed more than 10000 t CO2eq of HFCs on the market (9C) or specified quota-exempt supplies to third parties for direct export in bulk (5C_exempted). Note that you are therefore obliged to have this reporting verified. Please tick the box under section 9 to acknowledge this obligation. You also have the option to upload a verification document along with your report."
    let $threshold := 10000
    let $tr09C := cutil:if-number($doc/F4_S9_IssuedAuthQuata/tr_09C/Amount, 0)
    let $tr05CSum := cutil:sum-numbers($doc/F2_S5_exempted_HFCs/Gas/tr_05C/TradePartner/amount)
    let $documentIsVerified := $doc/F4_S9_IssuedAuthQuata/Verified
    return 
        let $condition :=
            if($tr09C >= $threshold or $tr05CSum > 0 ) then
                true()
            else
                false()
        return 
            if($condition and not(xmlconv:Section9DocumentIsVerified($doc))) then 
                uiutil:buildRuleResult("2044", "09A", $errorText, $xmlconv:BLOCKER, true(), (), "")
            else
                ()
};


declare function xmlconv:qc2403($doc as element()) as element(div)* {
    (: QC_2403 :)
    let $err_text := "Based on the reported numbers, your available HFC quota (9G) may not suffice to cover the amount of HFCs that was placed on the market. Please check your reported data in order to avoid erroneous reporting. Note that the European Commission (DG CLIMA) will assess your company’s quota compliance in co-operation with your Member State’s competent authorities. Failure to comply may result in reductions in future quota allocation and in penalties according to national law of the Member State concerned."
    return
        let $tr09F := cutil:if-number($doc/F4_S9_IssuedAuthQuata/tr_09F/Amount, 0)
        let $tr09G := cutil:if-number($doc/F4_S9_IssuedAuthQuata/tr_09G/Amount, 0)
        return
            if(
                $tr09F <= $tr09G
                and
                (
                    $tr09F >= 100
                    or
                    $tr09F = 0
                )
            )
            then
                ()
            else
                uiutil:buildRuleResult("2403", "09F", $err_text, $xmlconv:WARNING, true(), (), "")
};

declare function xmlconv:qc24031($doc as element()) as element(div)* {
(: QC_24031 :)
    let $err_text := "The need of quota for HFCs placed on the market (section 9F) is calculated to be negative for the sum of all reported HFCs. This is not likely to be plausible. Please double check your data reported in sections 1, 2, 3, 4, 5 and/or 9A. "
    return
        let $tr09F := cutil:if-number($doc/F4_S9_IssuedAuthQuata/tr_09F/Amount, 0)
        return
            if($tr09F >= 0) then
                ()
            else
                uiutil:buildRuleResult("24031", "09F", $err_text, $xmlconv:COMPLIANCE, true(), (), "")
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
            uiutil:buildRuleResult("24041", "09A_add", $errorText, $xmlconv:BLOCKER, true(), (), "")
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

declare function xmlconv:qc2407($doc as element()) as element(div)* {
    (: QC-2407 :)
    let $errorText := "Please upload one file, separately for each company in receipt of physical supplies, containing proof (e.g. invoices) for all physical supplies reported here."
    let $tradePartners := data($doc/F5_S10_Auth_NER/SumOfAllHFCsS2/tr_10A/TradePartnerID)
    let $isAuthNERSelected := cutil:is-activity-selected($doc/GeneralReportData/Activities/auth-NER)
    return if($isAuthNERSelected) then
        let $invalidCompanyNames := for $tradePartnerId in $tradePartners
            let $check1 := count($doc/F5_S10_Auth_NER/SumOfAllHFCsS2/tr_10A[TradePartnerID=$tradePartnerId and xmlconv:getInt(Amount) > 0]) > 0
            let $check2 := count($doc/F5_S10_Auth_NER/SupportingDocuments/tr_10A[TradePartnerID=$tradePartnerId and empty(Document/*)]) > 0
                where ($check1 and $check2)  
                return string($doc/F5_S10_Auth_NER/tr_10A_TradePartners/Partner[PartnerId = $tradePartnerId]/CompanyName)
        return 
            if(count($invalidCompanyNames)>0) then
                uiutil:buildRuleResult("2407", "10A", $errorText, $xmlconv:BLOCKER, true(), $invalidCompanyNames, "Invalid companies are : ")
            else
                ()
    else
        ()
};

(:declare function xmlconv:qc2408($report as element()) as element(div)* :)
(:{:)
    (: QC-2408 :)
    (:let $gasAmounts06A := fgases:get-gas-amounts-with-values($report/F3A_S6A_IA_HFCs, 'tr_06A'):)
    (:let $gasAmounts03A := fgases:get-gas-amounts-with-values($report/F1_S1_4_ProdImpExp, 'tr_03A'):)
    (:let $invalidGasIds := :)
        (:for $gasAmount06A in $gasAmounts06A:)
        (:let $matching03A :=:)
            (:for $gasAmount03A in $gasAmounts03A:)
            (:where fgases:get-gas-id-of-gas-amount($gasAmount03A) = fgases:get-gas-id-of-gas-amount($gasAmount06A):)
            (:return $gasAmount03A:)
        (:return:)
            (:if (empty($matching03A)) then () else fgases:get-gas-id-of-gas-amount($gasAmount06A):)
    (:return:)
        (:for $invalidGasId in $invalidGasIds:)
        (:let $invalidGas := fgases:get-gas-by-id($invalidGasId):)
        (:let $errorMsg := xmlconv:qc2408-error-text($invalidGas):)
        (:return uiutil:buildRuleResult("2408", "6A", $errorMsg, $xmlconv:WARNING, true(), (), ""):)
(:};:)

declare function xmlconv:qc2408-error-text($gas as element(Gas)) as xs:string
{
    let $msgTemplate := "You have reported both bulk exports (section 3A) and non-bulk exports (intended application 6A) for [gas]. Please make sure your exports are separately reported as bulk (3A) and non-bulk (6A), but not double-counted. Your reporting may be followed up in order to make sure that the reporting is correct."
    return replace($msgTemplate, "\[gas\]", string($gas/Name))
};

declare function xmlconv:qc2409TradePartner2($transactionCode, $partnerDefinition as element()*, $partnerTransactionData as element()*) as element(div)* {
    (: QC-2409 :)

    let $errorText := "Feedstock use has repeatedly been subject to erroneous reporting. Please provide a brief explanation of the process where the reported gas is used as a feedstock."
    let $partnerIds := $partnerDefinition/Partner/PartnerId
    let $invalidTradePartners := 
        for $partnerId in $partnerIds
            for $partnerData in $partnerTransactionData[TradePartnerID=$partnerId]
                let $amount := cutil:if-number($partnerData/amount, 0)
                let $comment := data($partnerData/Comment)
                where $amount > 0 and string-length($comment) = 0
            return string($partnerDefinition/Partner[PartnerId = $partnerId]/CompanyName)
    return 
        if(count($invalidTradePartners) > 0) then
            let $tradePartnerNames := distinct-values($invalidTradePartners)
            return uiutil:buildRuleResult("2409", $transactionCode, $errorText, $xmlconv:BLOCKER, true(), $tradePartnerNames, "Invalid companies are : ")
        else
            ()
};

declare function xmlconv:qc2409TradePartner($reportedData as element(FGasesReporting), $partnerDefinition as element()*,
        $transactionCode as xs:string, $gases as element(Gas)*, $sectionName as xs:string)
as element(div)*
{
    let $transactionName := concat("tr_", $transactionCode)
    let $totalErrors :=
        for $gas in $gases
            let $gasCode := $gas/GasCode
            let $gasName := cutil:getGasNameByGasCode($reportedData, $gasCode)
            let $tradePartnerData := $gas/*[local-name()=$transactionName]/TradePartner
            let $errors :=
                for $tradePartner in $tradePartnerData
                    let $tradePartnerName := cutil:getTransactionPartnerName($partnerDefinition, $tradePartner/TradePartnerID)
                    let $errorText := xmlconv:getQC2409ErrorMessageTradePartner($tradePartnerName, $gasName, $sectionName)
                    where not(cutil:transactionHasMandatoryCommentTradePartner($tradePartner))
                return uiutil:buildRuleResult("2409", $transactionCode, $errorText, $xmlconv:BLOCKER, true(), (), "")
        return $errors
    return $totalErrors
};



declare function xmlconv:qc2409($reportedData as element(FGasesReporting), $transactionCode as xs:string,
        $gases as element(Gas)*, $sectionName as xs:string)
as element(div)*
{
    let $invalidGasTransactions :=
        for $gas in $gases
            let $transactionName := concat("tr_", $transactionCode)
            let $transactionData := $gas/*[fn:local-name()=$transactionName]
        where not(cutil:transactionHasMandatoryComment($transactionData))
        return
            let $gasName := cutil:getGasNameByGasCode($reportedData, $gas/GasCode)
            let $errorText := xmlconv:getQC2409ErrorMessage($gasName, $sectionName)
            return uiutil:buildRuleResult("2409", $transactionCode, $errorText, $xmlconv:BLOCKER, true(), (), "")
    return $invalidGasTransactions
};

declare function xmlconv:getQC2409ErrorMessage($gasName as xs:string, $section as xs:string )
as xs:string{
    let $msgTemplate := "Reporting on feedstock use has been erroneous in the past. Please provide a comment for [gas] in section [section]"
    let $msg1 := replace($msgTemplate, "\[gas\]", $gasName)
    return replace($msg1, "\[section\]", $section)
};

declare function xmlconv:getQC2409ErrorMessageTradePartner($tradePartnerName as xs:string, $gasName as xs:string, $section as xs:string )
as xs:string{
    let $msgTemplate := "Reporting on feedstock use has been erroneous in the past. Please provide a comment for [gas] in section [section] - supplied by [partner]"
    let $msg1 := replace($msgTemplate, "\[gas\]", $gasName)
    let $msg2 := replace($msg1, "\[section\]", $section)
    return replace($msg2, "\[partner\]", $tradePartnerName)
};

declare function xmlconv:qc2410($transactionCode as xs:string, $transactionData as node()? )
as element(div)*
{
    let $errorText := "Reporting on re-exports (2B) has been erroneous in the past. Please provide a brief comment for 'gas' in section 2B explaining the nature of the re-exports."
    let $ReportedGases := $transactionData/../ReportedGases

    let $result :=
        for $GasReport in $transactionData/Gas
            let $amount := cutil:if-number($GasReport/tr_02B/Amount, 0)
            let $comment := data($GasReport/tr_02B/Comment)
            let $gasName := $ReportedGases[GasId = $GasReport/GasCode]/Name
            let $errorMsg := fn:replace( $errorText , 'gas', $gasName)
            
            return
                if($amount > 0 and string-length($comment) = 0) then
                    uiutil:buildRuleResult("2410", $transactionCode, $errorMsg, $xmlconv:BLOCKER, true(), (), "")
                else
                    ()

    return $result
};

declare function xmlconv:qc2411($report as element()) as element(div)* 
{
    (: QC-2411 :)
    let $gasAmounts02A := fgases:get-gas-amounts-with-values($report/F1_S1_4_ProdImpExp, 'tr_02A')
    let $gasAmounts11Q := fgases:get-gas-amounts-with-values($report/F7_s11EquImportTable, 'tr_11Q')
    let $invalidGasIds := 
        for $gasAmount02A in $gasAmounts02A
            let $matching11Q :=
                for $gasAmount11Q in $gasAmounts11Q
                where fgases:get-gas-id-of-gas-amount($gasAmount11Q) = fgases:get-gas-id-of-gas-amount($gasAmount02A)
                return $gasAmount11Q
            return
                if (empty($matching11Q)) then
                    ()
                else
                    let $amount02A := fgases:get-amount-of-gas-amount($gasAmount02A)
                    let $amount11Q := fgases:get-amount-of-gas-amount($matching11Q)
                    return
                        if (abs($amount02A - $amount11Q) > 1) then
                            ()
                        else
                            fgases:get-gas-id-of-gas-amount($gasAmount02A)

    return
        for $invalidGasId in $invalidGasIds
          let $invalidGas := fgases:get-gas-by-id-or-name($invalidGasId ,  $report//ReportedGases[GasId = $invalidGasId]/Name )
          let $errorMsg := xmlconv:qc2411-error-text($invalidGas)
          return uiutil:buildRuleResult("2411", "2A", $errorMsg, $xmlconv:WARNING, true(), (), "")
};

declare function xmlconv:qc2411-error-text($gas as element(Gas)) as xs:string
{
    let $msgTemplate := "The values reported for equipment imports (11Q) and bulk imports (2A) of [gas] are very close to each other. Please note that 2A should only contain imports in bulk and not those F-gases that are contained in imported equipment. Your report may be followed up to avoid any issues of double counting."
    return replace($msgTemplate, "\[gas\]", string($gas/Name))
};

declare function xmlconv:qc2015($report as element(FGasesReporting))
as element(div)?
{ 
    if (empty($report/attachedCompanyData/nerStatus)) then
        ()
    else
        let $isNer := not(empty($report/attachedCompanyData[nerStatus = 'true']))
        let $isAuth := not(empty($report/GeneralReportData/Activities[auth = 'true']))
        let $isAuthNer := $isAuth and not(empty($report/GeneralReportData/Activities[auth-NER = 'true']))
        return
            if ($isNer) then
                if ($isAuth and not($isAuthNer)) then
                    let $errorText := 'According to the HFC Registry, your company received its HFC quota through a declaration for the New Entrants Reserve (NER). Please select the corresponding option just below the &quot;Authorisations provider&quot; section of the Year &amp; Activities page.'
                    return uiutil:buildRuleResult("2015", "auth-NER", $errorText, $xmlconv:BLOCKER, true(), (), "")
                else
                    ()
            else
                if ($isAuthNer) then
                    let $errorText := 'According to the HFC Registry, your company did not receive its HFC quota through a declaration for the New Entrants Reserve (NER). Please unselect the corresponding option just below the &quot;Authorisations provider&quot; section of the Year &amp; Activities page.'
                    return uiutil:buildRuleResult("2015", "auth-NER", $errorText, $xmlconv:BLOCKER, true(), (), "")
                else
                    ()
};

declare function xmlconv:qc2055($report as element(FGasesReporting))
as element(div)*
{
    for $transaction in xmlconv:_get-qc2055-transactions()
    return xmlconv:_qc2055($report, $transaction)
};

declare function xmlconv:_get-qc2055-transactions()
as element(transaction)*
{
    let $transactions := 
        <transactions>
            <transaction>
                <id>tr_04A</id>
                <label>04A</label>
                <code>4A</code>
                <stockCode>4F</stockCode>
            </transaction>
            <transaction>
                <id>tr_04B</id>
                <label>04B</label>
                <code>4B</code>
                <stockCode>4G</stockCode>
            </transaction>
            <transaction>
                <id>tr_04C</id>
                <label>04C</label>
                <code>4C</code>
                <stockCode>4H</stockCode>
            </transaction>
        </transactions>
    return $transactions/transaction
};

declare function xmlconv:_qc2055($report as element(FGasesReporting), $transaction as element(transaction))
as element(div)*
{
    if (empty($report/F1_S1_4_ProdImpExp)) then
        ()
    else
        let $isP := cutil:is-activity-selected($report/GeneralReportData/Activities/P)
        let $isI := cutil:is-activity-selected($report/GeneralReportData/Activities/I)
        let $isE := cutil:is-activity-selected($report/GeneralReportData/Activities/E)
        let $transactionId := string($transaction/id)
        let $stockTransactionCode := string($transaction/stockCode)
        let $gasAmounts := fgases:get-gas-amounts($report/F1_S1_4_ProdImpExp, $transactionId)
        return
            for $gasAmount in $gasAmounts
            let $gasId := fgases:get-gas-id-of-gas-amount($gasAmount)
            let $stock := fgases:get-gas-stock-by-transaction($report, $gasId, $stockTransactionCode)
            return
                if (empty($stock)) then
                    ()
                else
                    let $amount := fgases:get-amount-of-gas-amount($gasAmount)
                    let $stockAmount := xs:decimal($stock/amount)
                    return
                        if ( cutil:getZeroIfNotNumber(string($amount)) < $stockAmount - 0.5) then
                            let $errorLevel :=
                                if(
                                    fgases:has-comment-of-gas-amount($gasAmount)
                                    or
                                    $isE
                                )
                                then $xmlconv:WARNING else $xmlconv:BLOCKER
                            let $errorMsg := xmlconv:_compose-qc2055-error-message($report, $transaction, $stock, $errorLevel)
                            return uiutil:buildRuleResult("2055", string($transaction/label), $errorMsg, $errorLevel, true(), (), "")
                        else
                            ()
};

declare function xmlconv:_compose-qc2055-error-message(
    $report as element(FGasesReporting), 
    $transaction as element(transaction), 
    $stock as element(stock),
    $errorLevel as xs:string
)
as xs:string
{
    let $msgTemplate :=
        if ($errorLevel = $xmlconv:BLOCKER) then
            'Stocks reported for [gas] on 1 Jan [transaction_year] (field [field_code]) are significantly below the corresponding stocks reported on 31 Dec of the previous year ([stock_value]; refer to [stock_field_code] in report on [previous_year]). Please revise your data or provide an explanation in section [field_code]. You may need to select "Importer" in the activity selection in order to access section 4.'
        else
            "Stocks reported for [gas] on 1 Jan [transaction_year] (field [field_code]) are significantly below the corresponding stocks reported on 31 Dec of the previous year ([stock_value]; refer to [stock_field_code] in report on [previous_year]). The comment provided will be considered during quality control."
    let $gasName := string(fgases:get-reported-gas-by-id($report, string($stock/gasId))/Name)
    let $transactionYear := fgases:get-transaction-year($report)
    let $previousYear := $transactionYear - 1
    let $msg1 := replace($msgTemplate, "\[gas\]", $gasName)
    let $msg2 := replace($msg1, "\[transaction_year\]", string($transactionYear))
    let $msg1 := replace($msg2, "\[previous_year\]", string($previousYear))
    let $msg2 := replace($msg1, "\[stock_value\]", string($stock/amount))
    let $msg1 := replace($msg2, "\[field_code\]", string($transaction/code))
    return replace($msg1, "\[stock_field_code\]", string($transaction/stockCode))
};

declare function xmlconv:qc2056($report as element(FGasesReporting))
as element(div)*
{
    let $stockTransactionCodes := ('4F', '4G', '4H', '8F')
    let $stocks := $report/attachedCompanyData/stocks/stock[transactionCode = $stockTransactionCodes]
    return
        for $stock in $stocks
          let $gas := fgases:get-reported-gas-by-id($report, string($stock/gasId))
          return
              if (empty($gas)) then
                  let $errorMsg := xmlconv:_compose-qc2056-error-message($report, $stock)
                  return uiutil:buildRuleResult("2056", "Gas selection", $errorMsg, $xmlconv:WARNING, true(), (), "")
              else
                  ()
};
(: 1C_a should be <= 1A :)
declare function xmlconv:qc20101($report as element(FGasesReporting))
as element(div)*
{
    let $err_text := "The amount reported in (1C_a)
    cannot be greater than the amount reported in (1A).
    Please revise your data."
    let $err_flag :=
        for $gas in $report/F1_S1_4_ProdImpExp/Gas
            let $tr01Ca_amount := cutil:numberIfEmpty($gas/tr_01Ca/Amount, 0)
            let $tr01A_amount := cutil:numberIfEmpty($gas/tr_01A/Amount, 0)
            let $ok := if (
                $tr01Ca_amount castable as xs:double
                and
                $tr01A_amount castable as xs:double)
                then
                    xs:double($tr01Ca_amount) <= xs:double($tr01A_amount)
                else
                    false()
            where not($ok)
                return data($report/ReportedGases[GasId = $gas/GasCode]/Name)
    return uiutil:buildRuleResult("20101", "1Ca", $err_text,
            $xmlconv:BLOCKER, count($err_flag)>0, $err_flag, "Invalid gases are: ")
};

declare function xmlconv:qc21200($report as element(FGasesReporting))
as element(div)*
{
    let $err_text := "The amount reported in (12B)
    should be equal with amount reported in (11G).
    Please revise your data."

    let $err_flag :=
        for $elem in $report/F8_S12/Gas
        let $tr_12B_amount := cutil:numberIfEmpty(data($elem/Totals/tr_12B), 0)
        let $tr_11G_amount := cutil:numberIfEmpty(
                data($report/F7_s11EquImportTable/Gas[GasCode = $elem/GasCode]/tr_11G/Amount),
                0)
        let $ok := if (
            $tr_12B_amount castable as xs:double
            and
            $tr_11G_amount castable as xs:double)
            then
                xs:double($tr_12B_amount) = xs:double($tr_11G_amount)
            else
                false()
        return
            if($ok)
            then ()
            else data($report/ReportedGases[GasId = $elem/GasCode]/Name)

    return uiutil:buildRuleResult("21200", "12B", $err_text,
            $xmlconv:BLOCKER, count($err_flag)>0,
            $err_flag, "Invalid gases are: "
    )
};

declare function xmlconv:qc21201($report as element(FGasesReporting))
as element(div)*
{
    let $err_text := "The amount reported in (12C)
    should be equal with amount reported in (12B) minus sum of (12A).
    Please revise your data."

    let $err_flag :=
        for $elem in $report/F8_S12/Gas
        let $tr_12C_amount := cutil:numberIfEmpty(data($elem/Totals/tr_12C), 0)
        let $tr_12B_amount := cutil:numberIfEmpty(data($elem/Totals/tr_12B), 0)
        let $tr_12A_amount := cutil:numberIfEmpty(data($elem/tr_12A/SumOfPartnersAmount), 0)
        let $ok := if (
            $tr_12C_amount castable as xs:double
            and
            $tr_12B_amount castable as xs:double
            and
            $tr_12A_amount castable as xs:double)
            then
                xs:double($tr_12C_amount) = xs:double($tr_12B_amount) - xs:double($tr_12A_amount)
            else
                false()
        return
            if($ok)
            then ()
            else data($report/ReportedGases[GasId = $elem/GasCode]/Name)
    return uiutil:buildRuleResult("21201", "12C", $err_text,
           $xmlconv:BLOCKER, count($err_flag)>0,
            $err_flag, "Invalid gases are: "
    )
};

declare function xmlconv:qc21303($report as element(FGasesReporting))
as element(div)*
{
    let $err_text := "The amount reported in (13B)
    should be equal with amount reported in (12B).
    Please revise your data."
    let $tr_13B_amount := cutil:numberIfEmpty(data($report/F9_S13/Totals/tr_13B/Amount), 0)
    let $tr_12B_total_amount := sum($report/F8_S12/Gas/Totals/cutil:numberIfEmpty(tr_12B, 0))
    let $ok := if (
        $tr_13B_amount castable as xs:double
        and
        $tr_12B_total_amount castable as xs:double)
        then
            xs:double($tr_13B_amount) = xs:double($tr_12B_total_amount)
        else
            false()
    return uiutil:buildRuleResult("21303", "13B", $err_text,
            $xmlconv:BLOCKER, not($ok),
            ("13B = " || $tr_13B_amount || ", 12B = " || $tr_12B_total_amount),
            "Formula expected 13B=SUM(12B)"
    )
};
declare function xmlconv:qc21301($report as element(FGasesReporting))
as element(div)*
{
    let $err_text := "The amount reported in (13C)
    should be equal with amount reported in (12A).
    Please revise your data."
    let $tr_13C_amount := cutil:numberIfEmpty(data($report/F9_S13/Totals/tr_13C/Amount), 0)
    let $tr_12A_total_amount := sum($report/F8_S12/Gas/tr_12A/cutil:numberIfEmpty(SumOfPartnersAmount, 0))
    let $ok := if (
        $tr_13C_amount castable as xs:double
        and
        $tr_12A_total_amount castable as xs:double)
        then
            xs:double($tr_13C_amount) = xs:double($tr_12A_total_amount)
        else
            false()
    return uiutil:buildRuleResult("21301", "13C", $err_text,
            $xmlconv:BLOCKER, not($ok),
            ("13C = " || $tr_13C_amount || ", 12A = " || $tr_12A_total_amount),
            "Formula expected 13C=SUM(12A) "
    )
};
declare function xmlconv:qc21304($report as element(FGasesReporting))
as element(div)*
{
    let $err_text := "The amount reported in (13D)
    should be equal with amount reported in (12C).
    Please revise your data."
    let $tr_13D_total_amount := cutil:numberIfEmpty(data($report/F9_S13/Totals/tr_13D/Amount), 0)
    let $tr_12C_amount := sum($report/F8_S12/Gas/Totals/cutil:numberIfEmpty(tr_12C, 0))
    let $ok := if (
        $tr_13D_total_amount castable as xs:double
        and
        $tr_12C_amount castable as xs:double)
        then
            xs:double($tr_13D_total_amount) = xs:double($tr_12C_amount)
        else
            false()
    return uiutil:buildRuleResult("21304", "13D", $err_text,
            $xmlconv:BLOCKER, not($ok),
            ("13D = " || $tr_13D_total_amount || ", 12C = " || $tr_12C_amount),
            "Formula expected 13D=SUM(12C) "
    )
};

declare function xmlconv:_compose-qc2056-error-message($report as element(FGasesReporting), $stock as element(stock))
as xs:string
{
    let $stockTransactionCode := string($stock/transactionCode)
    let $msgTemplate := 
        if ($stockTransactionCode = "8F") then
            "Stocks were reported as waiting for destruction for [gas] on 31 Dec [previous_year] ([stock_value]; refer to [stock_field_code] in report on [previous_year]), but [gas] is not included in this report. Please make sure that your gas selection for activities in [transaction_year] is complete before submitting your report."
        else
            "Stocks were reported for [gas] on 31 Dec [previous_year] ([stock_value]; refer to [stock_field_code] in report on [previous_year]), but [gas] is not included in this report. Please make sure that your gas selection for activities in [transaction_year] is complete before submitting your report."
    let $gasName := (fgases:get-gas-by-id-or-name($stock/gasId , $stock/gasName ) )/ Name
    let $transactionYear := fgases:get-transaction-year($report)
    let $previousYear := $transactionYear - 1
    let $msg1 := replace($msgTemplate, "\[gas\]", $gasName)
    let $msg2 := replace($msg1, "\[transaction_year\]", string($transactionYear))
    let $msg1 := replace($msg2, "\[previous_year\]", string($previousYear))
    let $msg2 := replace($msg1, "\[stock_value\]", string($stock/amount))
    return replace($msg2, "\[stock_field_code\]", $stockTransactionCode)
};

declare function xmlconv:Section9DocumentIsVerified($doc) as xs:boolean {
    let $verified := $doc/F4_S9_IssuedAuthQuata/Verified
    return if(cutil:verifyType($verified, "boolean")) then xs:boolean($verified) else false()
};



declare function xmlconv:getInt($elem) as xs:integer {
    if ($elem castable as xs:integer) then
      xs:integer($elem)
    else
      0
};
declare function xmlconv:getDouble($elem) as xs:double {
    if ($elem castable as xs:double) then
      xs:double($elem)
    else
      0
};

(:
    End of rules
:)

declare function xmlconv:validateReport($url as xs:string)
as element(div)
{
    let $doc := fn:doc($url)/FGasesReporting

    let $rStatus := xmlconv:rule_ReportStatus($doc)


    let $r2002 := xmlconv:qc2002($doc)
    let $r2003 := xmlconv:qc2003($doc)
    let $r2004 := xmlconv:qc2004($doc)
    let $r2005 := xmlconv:qc2005($doc)
    let $r2006 := xmlconv:qc2006($doc)
    (:let $r2007 := xmlconv:qc2007($doc):)
    let $r2008 := xmlconv:qc2008($doc)
    let $r2009 := xmlconv:qc2009($doc)
    let $r2010 := xmlconv:qc2010($doc)
    (:let $r2011 := xmlconv:qc2011($doc):)
    let $r2016 := xmlconv:qc2016($doc)
    let $r2017 :=
        for $tran in ('3C', '4D', '4E', '4I', '4J')
            return xmlconv:qc2017($doc, $tran)
    let $r2018 := xmlconv:qc2018($doc)
    let $r2020 := xmlconv:qc2020($doc)
    let $r2023 := xmlconv:qc2023($doc)
    let $r2024 := xmlconv:qc2024($doc)
    let $r2025 := xmlconv:qc2025($doc)
    let $r2026 := xmlconv:qc2026($doc)
    let $r2028 := xmlconv:qc2028($doc)
    let $r2029 := xmlconv:qc2029($doc)
    let $r2031 := xmlconv:qc2031($doc)
    let $r2039 := xmlconv:qc2039($doc)
    let $r2040 := xmlconv:qc2040($doc)
    let $r2041 := xmlconv:qc2041($doc)
    let $r2042 := xmlconv:qc2042($doc)
    let $r2043 := xmlconv:qc2043($doc)
    let $r2048 := xmlconv:qc2048($doc)

    let $r2050 :=
        xmlconv:qc2050($doc, '11P', '11P') | xmlconv:qc2050($doc, '11H04', '11H4')

    let $r2051 :=
        for $tran in ('11A01', '11A02', '11A03', '11A04', '11A05', '11A06', '11A07',
                      '11A08', '11A09', '11A10', '11A11', '11A12', '11A13', '11A14',
                      '11B01', '11B02', '11B03', '11B04', '11B05', '11B06', '11B07',
                      '11B08', '11B09', '11B10', '11B11', '11B12', '11B13', '11B14',
                      '11C', '11D01', '11D02', '11D03', '11E01', '11E02', '11E03',
                      '11E04', '11F01', '11F02', '11F03', '11F04', '11F05', '11F06',
                      '11F07', '11F08', '11F09', '11H01', '11H02', '11H03', '11H04',
                      '11I', '11J', '11K', '11L', '11M', '11N', '11O', '11P')
            return xmlconv:qc2051($doc, $tran)

    let $r2065 :=
        for $tran in ('11A01', '11A02', '11A03', '11A04', '11A05', '11A06', '11A07',
                      '11A08', '11A09', '11A10', '11A11', '11A12', '11A13', '11A14',
                      '11B01', '11B02', '11B03', '11B04', '11B05', '11B06', '11B07',
                      '11B08', '11B09', '11B10', '11B11', '11B12', '11B13', '11B14',
                      '11C', '11D01', '11D02', '11D03', '11E01', '11E02', '11E03',
                      '11E04', '11F01', '11F02', '11F03', '11F04', '11F05', '11F06',
                      '11F07', '11F08', '11F09', '11H01', '11H02', '11H03', '11H04',
                      '11I', '11J', '11K', '11L', '11M', '11N', '11O', '11P')
            return xmlconv:qc2065($doc, $tran)


    let $r2071 := xmlconv:qc2071($doc)
    let $r2072 := xmlconv:qc2072($doc)
    let $r2073 := xmlconv:qc2073($doc)
    let $r2078 := xmlconv:qc2078($doc)
    let $r2079 := xmlconv:qc2079($doc)
    let $r2087 := xmlconv:qc2087($doc)
    let $r2091 := xmlconv:rule_09($doc, "6A", "5C", "2091")
    let $r2092 := xmlconv:rule_09($doc, "6B", "5A", "2092")
    let $r2093 := xmlconv:rule_09($doc, "6C", "5D", "2093")
    let $r2094 := xmlconv:rule_09($doc, "6I", "5F", "2094")
    let $r2095 := xmlconv:rule_09($doc, "6L", "5B", "2095")
    let $r2096 := xmlconv:rule_09($doc, "6M", "5E", "2096")
    let $r2098 := xmlconv:qc2098($doc)
    let $r2099 := xmlconv:qc2099($doc)
    let $r2301_11A1 := xmlconv:validateTransactionAmountRange($doc, "11A01", 0.15, 10.0, "kg/piece", "2300")
    let $r2301_11A2 := xmlconv:validateTransactionAmountRange($doc, "11A02", 1, 100.0, "kg/piece", "2300")
    let $r2301_11A3 := xmlconv:validateTransactionAmountRange($doc, "11A03", 0.15, 10.0, "kg/piece", "2300")
    let $r2301_11A4 := xmlconv:validateTransactionAmountRange($doc, "11A04", 3, 100.0, "kg/piece", "2300")
    let $r2301_11A5 := xmlconv:validateTransactionAmountRange($doc, "11A05", 0.5, 3.0, "kg/piece", "2300")
    let $r2301_11A6 := xmlconv:validateTransactionAmountRange($doc, "11A06", 1.5, 100.0, "kg/piece", "2300")
    let $r2301_11A7 := xmlconv:validateTransactionAmountRange($doc, "11A07", 0.2, 10.0, "kg/piece", "2300")
    let $r2301_11A8 := xmlconv:validateTransactionAmountRange($doc, "11A08", 0.2, 300.0, "kg/piece", "2300")
    let $r2301_11A9 := xmlconv:validateTransactionAmountRange($doc, "11A09", 0.2, 300.0, "kg/piece", "2300")
    let $r2301_11A10 := xmlconv:validateTransactionAmountRange($doc, "11A10", 0.5, 10.0, "kg/piece", "2300")
    let $r2301_11A11 := xmlconv:validateTransactionAmountRange($doc, "11A11", 0.2, 300.0, "kg/piece", "2300")
    let $r2301_11A12 := xmlconv:validateTransactionAmountRange($doc, "11A12", 0.2, 300.0, "kg/piece", "2300")
    let $r2301_11A13 := xmlconv:validateTransactionAmountRange($doc, "11A13", 0.2, 100.0, "kg/piece", "2300")
    let $r2301_11A14 := xmlconv:validateTransactionAmountRange($doc, "11A14", 0.2, 1000.0, "kg/piece", "2300")
    let $r2301_11B1 := xmlconv:validateTransactionAmountRange($doc, "11B01", 0.04, 2.0, "kg/piece", "2300")
    let $r2301_11B2 := xmlconv:validateTransactionAmountRange($doc, "11B02", 0.04, 10.0, "kg/piece", "2300")
    let $r2301_11B3 := xmlconv:validateTransactionAmountRange($doc, "11B03", 0.04, 10.0, "kg/piece", "2300")
    let $r2301_11B4 := xmlconv:validateTransactionAmountRange($doc, "11B04", 1, 1000.0, "kg/piece", "2300")
    let $r2301_11B5 := xmlconv:validateTransactionAmountRange($doc, "11B05", 1, 1000.0, "kg/piece", "2300")
    let $r2301_11B6 := xmlconv:validateTransactionAmountRange($doc, "11B06", 1, 1000.0, "kg/piece", "2300")
    let $r2301_11B7 := xmlconv:validateTransactionAmountRange($doc, "11B07", 1, 1000.0, "kg/piece", "2300")
    let $r2301_11B8 := xmlconv:validateTransactionAmountRange($doc, "11B08", 1, 1000.0, "kg/piece", "2300")
    let $r2301_11B9 := xmlconv:validateTransactionAmountRange($doc, "11B09", 1, 1000.0, "kg/piece", "2300")
    let $r2301_11B10 := xmlconv:validateTransactionAmountRange($doc, "11B10", 1, 1000.0, "kg/piece", "2300")
    let $r2301_11B11 := xmlconv:validateTransactionAmountRange($doc, "11B11", 1, 1000.0, "kg/piece", "2300")
    let $r2301_11B12 := xmlconv:validateTransactionAmountRange($doc, "11B12", 1, 800.0, "kg/piece", "2300")
    let $r2301_11B13 := xmlconv:validateTransactionAmountRange($doc, "11B13", 1, 400.0, "kg/piece", "2300")
    let $r2301_11B14 := xmlconv:validateTransactionAmountRange($doc, "11B14", 1, 800.0, "kg/piece", "2300")
    let $r2301_11C := xmlconv:validateTransactionAmountRange($doc, "11C", 0.15, 0.5, "kg/piece", "2300")
    let $r2301_11D1 := xmlconv:validateTransactionAmountRange($doc, "11D01", 0.1, 100.0, "kg/piece", "2300")
    let $r2301_11D2 := xmlconv:validateTransactionAmountRange($doc, "11D02", 0.1, 100.0, "kg/piece", "2300")
    let $r2301_11D3 := xmlconv:validateTransactionAmountRange($doc, "11D03", 0.1, 100.0, "kg/piece", "2300")
    let $r2301_11E1 := xmlconv:validateTransactionAmountRange($doc, "11E01", 0.7, 13.0, "kg/piece", "2300")
    let $r2301_11E2 := xmlconv:validateTransactionAmountRange($doc, "11E02", 0.8, 1.6, "kg/piece", "2300")
    let $r2301_11E3 := xmlconv:validateTransactionAmountRange($doc, "11E03", 10.0, 5000.0, "kg/piece", "2300")
    let $r2301_11E4 := xmlconv:validateTransactionAmountRange($doc, "11E04", 0.035, 1.0, "kg/piece", "2300")
    let $r2301_11F1 := xmlconv:validateTransactionAmountRange($doc, "11F01", 0.3, 1.5, "kg/piece", "2300")
    let $r2301_11F2 := xmlconv:validateTransactionAmountRange($doc, "11F02", 7.0, 20.0, "kg/piece", "2300")
    let $r2301_11F3 := xmlconv:validateTransactionAmountRange($doc, "11F03", 0.45, 1.5, "kg/piece", "2300")
    let $r2301_11F4 := xmlconv:validateTransactionAmountRange($doc, "11F04", 0.7, 1.5, "kg/piece", "2300")
    let $r2301_11F5 := xmlconv:validateTransactionAmountRange($doc, "11F05", 0.7, 2.5, "kg/piece", "2300")
    let $r2301_11F6 := xmlconv:validateTransactionAmountRange($doc, "11F06", 5.0, 35.0, "kg/piece", "2300")
    let $r2301_11F7 := xmlconv:validateTransactionAmountRange($doc, "11F07", 0.3, 100.0, "kg/piece", "2300")
    let $r2301_11F8 := xmlconv:validateTransactionAmountRange($doc, "11F08", 2.0, 10.0, "kg/piece", "2300")
    let $r2301_11F9 := xmlconv:validateTransactionAmountRange($doc, "11F09", 0.1, 100.0, "kg/piece", "2300")
    let $r2301_11H1 := xmlconv:validateTransactionAmountRange($doc, "11H01", 10.0, 100.0, "kg/t", "2300")
    let $r2301_11H2 := xmlconv:validateTransactionAmountRange($doc, "11H02", 1.0, 10.0, "kg/m3", "2300")
    let $r2301_11H3 := xmlconv:validateTransactionAmountRange($doc, "11H03", 1.0, 10.0, "kg/piece", "2300")
    let $r2301_11H4 :=
        if($doc/F7_s11EquImportTable/TR_11H4_Unit="metrictonnes") then
            xmlconv:validateTransactionAmountRange($doc, "11H04", 10.0, 100.0, "kg/t", "2300")
        else if($doc/F7_s11EquImportTable/TR_11H4_Unit="cubicmetres") then
            xmlconv:validateTransactionAmountRange($doc, "11H04", 1.0, 100.0, "kg/m3", "2300")
        else if($doc/F7_s11EquImportTable/TR_11H4_Unit="pieces") then
                xmlconv:validateTransactionAmountRange($doc, "11H04", 1.0, 100.0, "kg/pieces", "2300")
            else
                ()
    let $r2301_11I := xmlconv:validateTransactionAmountRange($doc, "11I", 3.0, 500.0, "kg/piece", "2300")
    let $r2301_11J := xmlconv:validateTransactionAmountRange($doc, "11J", 0.007, 0.02, "kg/container", "2300")
    let $r2301_11K := xmlconv:validateTransactionAmountRange($doc, "11K", 0.05, 0.5, "kg/container", "2300")
    let $r2301_11L := xmlconv:validateTransactionAmountRange($doc, "11L", 0.01, 100.0, "kg/piece", "2300")
    let $r2301_11M := xmlconv:validateTransactionAmountRange($doc, "11M", 1.0, 100.0, "kg/piece", "2300")
    let $r2301_11N := xmlconv:validateTransactionAmountRange($doc, "11N", 0.5, 500.0, "kg/piece", "2300")
    let $r2301_11O := xmlconv:validateTransactionAmountRange($doc, "11O", 0.2, 1000.0, "kg/piece", "2300")
    let $r2301_11P :=
        if($doc/F7_s11EquImportTable/TR_11P_Unit="metrictonnes") then
            xmlconv:validateTransactionAmountRange($doc, "11P", 0.2, 1000.0, "kg/t", "2300")
        else if($doc/F7_s11EquImportTable/TR_11P_Unit="cubicmetres") then
            xmlconv:validateTransactionAmountRange($doc, "11P", 0.2, 1000.0, "kg/m3", "2300")
        else if($doc/F7_s11EquImportTable/TR_11P_Unit="pieces") then
                xmlconv:validateTransactionAmountRange($doc, "11P", 0.2, 1000.0, "kg/pieces", "2300")
            else
                ()
    let $r2044 := xmlconv:qc2044($doc)
    let $r2403 := xmlconv:qc2403($doc)
    let $r24031 := xmlconv:qc24031($doc)
    let $r2404 := xmlconv:qc2404($doc)
    let $r24041 := xmlconv:qc24041($doc)
    let $r24042 := xmlconv:qc24042($doc)
    let $r24043 := xmlconv:qc24043($doc)
    let $r2405 := xmlconv:qc2405($doc)
    let $r2406 := xmlconv:qc2406($doc)
    let $r2407 := xmlconv:qc2407($doc)
    (:let $r2408 := xmlconv:qc2408($doc):)
    let $r2409_05B := xmlconv:qc2409TradePartner($doc,$doc/F2_S5_exempted_HFCs/tr_05B_TradePartners/Partner,"05B", $doc/F2_S5_exempted_HFCs/Gas, "5B")
    let $r2409_07A := xmlconv:qc2409($doc, "07A", $doc/F6_FUDest/Gas, "7A")
    let $r2409_06L := xmlconv:qc2409($doc, "06L", $doc/F3A_S6A_IA_HFCs/Gas, "6L")
    let $r2410_02B := xmlconv:qc2410("02B", $doc/F1_S1_4_ProdImpExp)
    let $r2411 := xmlconv:qc2411($doc)
    let $r2015 := xmlconv:qc2015($doc)
    let $r2055 := xmlconv:qc2055($doc)
    let $r2056 := xmlconv:qc2056($doc)
    let $r20601 := xmlconv:qc20601($doc)
    (: for NIL reports disable the following checks :)
    let $nilReport := fgases:is-NIL-Report($doc)
    let $r20101 := if(not($nilReport)) then xmlconv:qc20101($doc) else ()
    let $r21200 := if(not($nilReport)) then xmlconv:qc21200($doc) else ()
    let $r21201 := if(not($nilReport)) then xmlconv:qc21201($doc) else ()
    let $r21303 := if(not($nilReport)) then xmlconv:qc21303($doc) else ()
    let $r21301 := if(not($nilReport)) then xmlconv:qc21301($doc) else ()
    let $r21304 := if(not($nilReport)) then xmlconv:qc21304($doc) else ()




    return
    <div class="errors">
        {$rStatus}
        {$r2002}
        {$r2003}
        {$r2004}
        {$r2005}
        {$r2006}
        {$r2008}
        {$r2009}
        {$r2010}
        {$r2016}
        {$r2017}
        {$r2018}
        {$r2020}
        {$r2023}
        {$r2024}
        {$r2025}
        {$r2026}
        {$r2028}
        {$r2029}
        {$r2031}
        {$r2039}
        {$r2040}
        {$r2041}
        {$r2042}
        {$r2043}
        {$r2044}
        {$r2048}
        {$r2050}
        {$r2051}
        {$r2065}
        {$r2071}
        {$r2072}
        {$r2073}
        {$r2078}
        {$r2079}
        {$r2087}
        {$r2091}
        {$r2092}
        {$r2093}
        {$r2094}
        {$r2095}
        {$r2096}
        {$r2098}
        {$r2099}
        {$r2301_11A1}
        {$r2301_11A2}
        {$r2301_11A3}
        {$r2301_11A4}
        {$r2301_11A5}
        {$r2301_11A6}
        {$r2301_11A7}
        {$r2301_11A8}
        {$r2301_11A9}
        {$r2301_11A10}
        {$r2301_11A11}
        {$r2301_11A12}
        {$r2301_11A13}
        {$r2301_11A14}
        {$r2301_11B1}
        {$r2301_11B2}
        {$r2301_11B3}
        {$r2301_11B4}
        {$r2301_11B5}
        {$r2301_11B6}
        {$r2301_11B7}
        {$r2301_11B8}
        {$r2301_11B9}
        {$r2301_11B10}
        {$r2301_11B11}
        {$r2301_11B12}
        {$r2301_11B13}
        {$r2301_11B14}
        {$r2301_11C}
        {$r2301_11D1}
        {$r2301_11D2}
        {$r2301_11D3}
        {$r2301_11E1}
        {$r2301_11E2}
        {$r2301_11E3}
        {$r2301_11E4}
        {$r2301_11F1}
        {$r2301_11F2}
        {$r2301_11F3}
        {$r2301_11F4}
        {$r2301_11F5}
        {$r2301_11F6}
        {$r2301_11F7}
        {$r2301_11F8}
        {$r2301_11F9}
        {$r2301_11H1}
        {$r2301_11H2}
        {$r2301_11H3}
        {$r2301_11H4}
        {$r2301_11I}
        {$r2301_11J}
        {$r2301_11K}
        {$r2301_11L}
        {$r2301_11M}
        {$r2301_11N}
        {$r2301_11O}
        {$r2301_11P}
        {$r2044}
        {$r2403}
        {$r24031}
        {$r2404}
        {$r24041}
        {$r24042}
        {$r24043}
        {$r2405}
        {$r2406}
        {$r2407}
        {$r2409_05B}
        {$r2409_07A}
        {$r2409_06L}
        {$r2410_02B}
        {$r2411}
        {$r2015}
        {$r2055}
        {$r2056}
        {$r20101}
        {$r21200}
        {$r21201}
        {$r21303}
        {$r21301}
        {$r21304}
        {$r20601}
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

    let $results := xmlconv:validateReport($source_url)

    let $class := xmlconv:getMostCriticalErrorClass($results)
    let $errorText := xmlconv:getErrorText($class)

    let $resultErrors := uiutil:getResultErrors($results)

    (: Display all QC messages for maximum possible feedback to the user #68660 :)
    let $hasOnlyStatusError := false()

    return
            uiutil:buildScriptResult($results, $class, $errorText, $hasOnlyStatusError, $xmlconv:cssStyle)
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


xmlconv:proceed( $source_url )


