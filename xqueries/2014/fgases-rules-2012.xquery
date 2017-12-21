xquery version "1.0" encoding "UTF-8";
(:
 : Module Name: Fluorinated Greenhouse Gas Rules methods (Library module)
 :
 : Version:     $Id: fgases-rules-2012.xquery 17234 2014-11-26 17:41:45Z kasperen $
 : Created:     15 October 2012
 : Copyright:   European Environment Agency
 :)
(:~
 : Rule definitions used by F-Gases (2012) scripts.
 :
 : Reporting obligation: http://rod.eionet.europa.eu/obligations/669
 :
 : @author Kaido Laine
 :)
module namespace rules = "http://converters.eionet.europa.eu/fgases/rules";
import module namespace cutil = "http://converters.eionet.europa.eu/fgases/cutil" at "fgases-common-util.xquery";

declare variable $rules:FGASES_COMMON_ID as xs:string := "common";

declare variable $rules:FGASES_SCHEMA as xs:string := "http://dd.eionet.europa.eu/schemas/fgases/FGasesReporting.xsd";
declare variable $rules:NIL_SCHEMA as xs:string := "http://dd.eionet.europa.eu/schemas/bdr/NILReporting.xsd";
(:
declare variable $rules:FGASES_CONSISTENCYRULE_ID as xs:string := "consistency";
declare variable $rules:FGASES_COMPLETNESSRULE_ID := "completeness";
declare variable $rules:FGASES_PLAUSIBILITYRULE_ID as xs:string := "plausibility";
:)
declare variable $rules:FGASES_WARNINGRULE_ID  as xs:string := "plausibility_warning";

declare variable $rules:FGASES_FINAL_STATUS as xs:string := "submitted";
declare variable $rules:FGASES_ROUNDING_TOLERANCE as xs:decimal := 0.01;
declare variable $rules:FGASES_MIN_YEAR as xs:integer := 2007;

declare variable $rules:FGASES_PRODUCER_FIELDS as xs:string* := ('Amount_purchased_other_EC_source', 'Production_EC');
declare variable $rules:FGASES_OTHER_TRANSTYPE as xs:string := "App_Other_or_unknown";
(: ------------------------- :)
declare variable $rules:CONSISTENCY_PRODSPECIAL_SUBID as xs:string      := "c1";
declare variable $rules:CONSISTENCY_OTHER_SUBID as xs:string            := "c2";

declare variable $rules:CONSISTENCY_EXPTOTAL_SUBID as xs:string         := "c3";
declare variable $rules:CONSISTENCY_EXPCROSSCHECKING_SUBID as xs:string := "c4";
declare variable $rules:CONSISTENCY_COPRODNAME_SUBID as xs:string       := "c5";
declare variable $rules:CONSISTENCY_BLENDCONTENTS_SUBID as xs:string    := "c6";
declare variable $rules:CONSISTENCY_BLENDEXISTING_SUBID as xs:string    := "c7";
declare variable $rules:CONSISTENCY_STOCKPREVYEAR_SUBID as xs:string    := "c8";
declare variable $rules:CONSISTENCY_STOCKINCREASE_SUBID as xs:string    := "c9";
declare variable $rules:CONSISTENCY_STOCKMISSING_SUBID as xs:string     := "c10";
declare variable $rules:CONSISTENCY_TOTALS_SUBID as xs:string           := "c11";
declare variable $rules:CONSISTENCY_TOTALS_HFCPREPIMP_SUBID as xs:string := "c12";

declare variable $rules:CROSSCHECK_NONPRODUCER_1T_SUBID as xs:string    := "x1";
declare variable $rules:CROSSCHECK_NONIMPORTER_1T_SUBID as xs:string    := "x2";
declare variable $rules:CROSSCHECK_NONEXPORTER_1T_SUBID as xs:string    := "x3";

declare variable $rules:COMPLETNESS_WRONGSTATUS_SUBID as xs:string  := "m1";
declare variable $rules:COMPLETNESS_WRONGYEAR_SUBID as xs:string    := "m2";
declare variable $rules:COMPLETNESS_NOACTIVITIES_SUBID as xs:string := "m3";
declare variable $rules:COMPLETNESS_NILACTIVITY_SUBID as xs:string  := "m4";
declare variable $rules:COMPLETNESS_PRODUCER_SUBID as xs:string     := "m5";
declare variable $rules:COMPLETNESS_IMPORTER_SUBID as xs:string     := "m6";
declare variable $rules:COMPLETNESS_EXPORTER_SUBID as xs:string     := "m7";

declare variable $rules:PLAUSIBILITY_WRONGNUMBER_SUBID as xs:string     := "p1";
declare variable $rules:PLAUSIBILITY_NEGATIVENUMBER_SUBID as xs:string  := "p2";
declare variable $rules:WARNING_DECIMALS_SUBID as xs:string             := "w1";
declare variable $rules:WARNING_PREVSTOCK_SUBID as xs:string            := "w2";
declare variable $rules:WARNING_STOCKINCREASE_SUBID  as xs:string       := "w3";
declare variable $rules:EXPORTER_TABLE_ID as xs:string              := "exporter";
declare variable $rules:PRODIMP_TABLE_ID as xs:string               := "producerimporter";
declare variable $rules:GENERAL_TABLE_ID as xs:string               := "general";
declare variable $rules:COPRODUCER_TABLE_ID as xs:string            := "coproducer";
declare variable $rules:MISSING_TABLE_ID as xs:string               := "missing";
declare variable $rules:FGASES_CROSSCHECKRULE_ID  as xs:string      := "crosscheck";

declare variable $rules:GASNAME_TAG as xs:string := "[gasname]";
declare variable $rules:FORMTYPE_TAG as xs:string := "[formtype]";
(: ----------------------------------- :)

declare variable $rules:FGASES_ERROR_ID as xs:string := "rule_error";

declare variable $rules:TRANSACTION_LABEL_XML as element(Labels) :=
(
<Labels id="HFC">
    <Transaction name="Production_EC" labelId="transaction-1" allowNegative="false"/>
    <Transaction name="Import_into_EC" labelId="transaction-2"  allowNegative="false"/>
    <Transaction name="Export_(I-P-Form)_from_EC" labelId="transaction-3"  allowNegative="false"/>
    <Transaction name="Other_amounts_reclam_destruc_within_EC" labelId="transaction-4"  allowNegative="false"/>
    <Transaction name="Amount_purchased_other_EC_source" labelId="transaction-7"  allowNegative="false"/>
    <Transaction name="Stocks_held_1_January" labelId="transaction-8"  allowNegative="false"/>
    <Transaction name="Stocks_held_31_December" labelId="transaction-9"  allowNegative="false"/>
    <Transaction name="Reclamation_own" labelId="transaction-10"  allowNegative="false"/>
    <Transaction name="Destruction_own" labelId="transaction-11" allowNegative="false"/>
    <Transaction name="Destruction_on_behalf_in_EC" labelId="transaction-12"  allowNegative="false"/>
    <Transaction name="Feedstock_own_use" labelId="transaction-13" allowNegative="false"/>
    <Transaction name="App_Refrigeraration_air_cond" labelId="transaction-15" allowNegative="true"/>
    <Transaction name="App_Fire_protection" labelId="transaction-16" allowNegative="true"/>
    <Transaction name="App_Aerosols" labelId="transaction-17" allowNegative="true"/>
    <Transaction name="App_Solvents" labelId="transaction-18" allowNegative="true"/>
    <Transaction name="App_Foams" labelId="transaction-19" allowNegative="true"/>
    <Transaction name="App_Feedstock" labelId="transaction-20" allowNegative="true"/>
    <Transaction name="App_Other_or_unknown" labelId="transaction-21" allowNegative="true"/>
    <Transaction name="App_Semiconductor_manufacture" labelId="transaction-23" allowNegative="true"/>
    <Transaction name="App_Electrical_equipment" labelId="transaction-25" allowNegative="true"/>
    <Transaction name="App_Magnesium_die_casting_Operations" labelId="transaction-26" allowNegative="true"/>

</Labels>
);

declare variable $rules:SUM_FORMULAS_XML as element(Labels) :=
(
<Labels>
    <!-- avail for sale -->
    <Total id="availableForSale">
        <Formula gasGroup="HFC" transactionId="transaction-22">A+B-C+D+E-F+G+H-I-K-L-M</Formula>
        <Formula gasGroup="HFC-preparations" transactionId="transaction-22">A-B+C+D-E-F-G-H</Formula>
        <Formula gasGroup="PFC" transactionId="transaction-22">A+B-C+D+E-F+G+H-I-K-L</Formula>
        <Formula gasGroup="SF6" transactionId="transaction-22">A+B-C+D+E-F+G+H-I-K-L</Formula>
    </Total>
    <!-- POM -->
    <Total id="placedOnMarket">
        <Formula gasGroup="HFC" transactionId="transaction-38">O+P+Q+R+S+T+U</Formula>
        <Formula gasGroup="HFC-preparations" transactionId="transaction-38">K+L+M+N+O+P+Q</Formula>
        <Formula gasGroup="PFC" transactionId="transaction-38">N+O+P</Formula>
        <Formula gasGroup="SF6" transactionId="transaction-38">N+O+P+Q</Formula>
    </Total>
    <!-- Total Sold -->
    <Total id="totalSold">
        <Formula gasGroup="HFC" transactionId="transaction-39">C+F+N</Formula>
        <Formula gasGroup="HFC-preparations" transactionId="transaction-39">B+J</Formula>
        <Formula gasGroup="PFC" transactionId="transaction-39">C+F+M</Formula>
        <Formula gasGroup="SF6" transactionId="transaction-39">C+F+M</Formula>
    </Total>


</Labels>
);

declare variable $rules:ERROR_RULES_XML as element(group) :=
    <group id="general" label="Perform blocking error checks">
        <rule code="{$rules:FGASES_ERROR_ID}">
          <title>Blocking errors:</title>
            <descr>The quality check found important inconsistencies and/or errors in the reported data which need to be fixed.</descr>
            <rulefine>No blocking errors have been found.</rulefine>
            <subrule id="{$rules:CROSSCHECK_NONPRODUCER_1T_SUBID}">
                <ruletext>The check has calculated the sum across all gases of 'Total new production from your facility/ies' as reported in the questionnaire and has found it to be above one tonne. In such a case your company must report as a producer. If the reported data are correct,please tick on the producer box for your respective gas group(s) under the tab 'Company Information', else change your reported data as appropriate.</ruletext>
                <ruletable id="{$rules:GENERAL_TABLE_ID}" supId="8"/>
            </subrule>
            <subrule id="{$rules:CROSSCHECK_NONIMPORTER_1T_SUBID}">
                <ruletext>The check has calculated the sum across all gases of 'Amount imported into the Community' and has found it to be above one tonne. In such a case you must report as an importer. Please tick on the importer box for your respective gas group(s) under the tab 'Company information', else change your reported data as appropriate.</ruletext>
                <ruletable id="{$rules:GENERAL_TABLE_ID}" supId="9"/>
            </subrule>
            <subrule id="{$rules:CROSSCHECK_NONEXPORTER_1T_SUBID}">
                <ruletext>The check has calculated the sum across all gases of 'Amount exported for sale outside the Community' and has found it to be above one tonne. In such a case you must report as an exporter. Please tick on the exporter box under the tab 'company information', else change your reported data, as appropriate.</ruletext>
                <ruletable id="{$rules:GENERAL_TABLE_ID}" supId="10"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_EXPTOTAL_SUBID}">
                <ruletext>Please check the total amounts exported for recycling, reclamation and /or destruction. It must be smaller than or equal to the exported totals of the respective gas.</ruletext>
                <ruletable id="{$rules:EXPORTER_TABLE_ID}" supId="4"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_EXPCROSSCHECKING_SUBID}">
                <ruletext role="exporter">The amount reported for export of this gas in the 'Exporter Form' does not match the amount reported for export of this gas in the respective 'Producer/Importer Form'. Please, modify your data where appropriate in order to ensure that both amounts are equal.</ruletext>
                <ruletext role="producer">The amount reported for export of this gas in this form does not match the amount reported for total export of this gas in the 'Exporter Form'. Please, modify your data where appropriate in order to ensure that both amounts are equal.</ruletext>
                <ruletext role="nonproducer">The amount reported for export of this gas in this form does not match the amount reported for total export of this gas in the 'Exporter Form'. Please, modify your data where appropriate in order to ensure that both amounts are equal.</ruletext>
                <ruletable id="{$rules:EXPORTER_TABLE_ID}" supId="5"/>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="13"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_PRODSPECIAL_SUBID}">
                <ruletext>You did not tick to be a producer in this gas group under the tab 'Company Information'. Thus you cannot report on production. If you want to report on production, please first revisit the 'Company Information' tab and modify your settings on your production activities there.</ruletext>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="4"/>
                <ruletable id="{$rules:COPRODUCER_TABLE_ID}" supId="3"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_OTHER_SUBID}">
                <ruletext>You report on "other or unknown" intended applications. Please, provide an explanation in this box.</ruletext>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="5"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_COPRODNAME_SUBID}">
                <ruletext>Please complete the name of Co-producer.</ruletext>
                <ruletable id="{$rules:COPRODUCER_TABLE_ID}" supId="4"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_BLENDCONTENTS_SUBID}">
                <ruletext>You added a new preparation. The sum of the percentages does not equal 100 %. Please correct the figures.</ruletext>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="6"/>
                <ruletable id="{$rules:COPRODUCER_TABLE_ID}" supId="5"/>
                <ruletable id="{$rules:EXPORTER_TABLE_ID}" supId="6"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_BLENDEXISTING_SUBID}">
                <ruletext>You added a new preparation. The new preparation is identical with another preparation on the list. Please, select the preparation from the drop-down list.</ruletext>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="7"/>
                <ruletable id="{$rules:COPRODUCER_TABLE_ID}" supId="6"/>
                <ruletable id="{$rules:EXPORTER_TABLE_ID}" supId="7"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_STOCKPREVYEAR_SUBID}">
                <ruletext role="producer">The amounts of the reported gas as stocks on the 1 January in your present report should be consistent with the amounts reported as stocks on the 31 December in your previous year's report. Please change your reported data accordingly or provide an explanation (in the comment field below the reported data under relevant tab of the questionnaire) for the difference in the reported stock amounts.</ruletext>
                <ruletext role="nonproducer">The amounts of the reported gas as stocks 1 January in your present report should be consistent with the amounts reported as stocks 31 December in your previous year's report. Please note that you should not report on your full stocks but only on that share that was previously imported by your own company. Please change your reported data accordingly or provide an explanation why your reported data is in fact plausible.</ruletext>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="8"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_STOCKINCREASE_SUBID}">
                <ruletext role="producer">Your stock increase between 1 January and 31 December for the gas appears to be implausibly high. It should be smaller than or equal to the sum of Production, Import, Collection for reclamation and destruction, Purchases from Co-producers and Other EU purchases. Please change your reported data accordingly or provide an explanation (in the comment field below the reported data in the webform) why your reported data is in fact plausible.</ruletext>
                <ruletext role="nonproducer">Your stock increase between 1 January and 31 December for the gas appears to be implausibly high. It should be smaller than or equal to your Imports. Please note that you as a non-producing company should report only only those stockpiled quantitites which were previously imported by your company. Please change your reported data accordingly or provide an explanation (in the comment field below the reported data in the webform) why your reported data is in fact plausible.</ruletext>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="9"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_TOTALS_SUBID}">
                <ruletext role="producer">Your 'Calculated total' for this gas is lower than the 'Total amount placed on the EU market'. It should be higher or equal to the total amount placed on the market. Please change your reported primary data to make both sums fit accordingly.</ruletext>
                <ruletext role="nonproducer">Your 'Calculated total' for this gas differs from the 'Total amount placed on the EU market'. It should be equal to the total amount placed on the market. Please change your reported primary data accordingly to make both sums fit.</ruletext>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="11"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_TOTALS_HFCPREPIMP_SUBID}">
                <ruletext>Your 'Calculated total' for this gas differs from the 'Total amount placed on the EU market'. It should be equal to the total amount placed on the market. Please change your reported primary data accordingly to make both sums fit.</ruletext>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="14"/>
            </subrule>
           <subrule id="{$rules:COMPLETNESS_WRONGSTATUS_SUBID}">
                <ruletext>Please click the 'Certify correctness' button in the sheet 'finish' before submitting.</ruletext>
                <ruletable id="{$rules:GENERAL_TABLE_ID}" supId="1"/>
            </subrule>
            <subrule id="{$rules:COMPLETNESS_WRONGYEAR_SUBID}">
                <ruletext>The allowed range of years is 2007 until current year.</ruletext>
                <ruletable id="{$rules:GENERAL_TABLE_ID}" supId="2"/>
            </subrule>
            <subrule id="{$rules:COMPLETNESS_NOACTIVITIES_SUBID}">
                <ruletext>At least one activity must be selected.</ruletext>
                <ruletable id="{$rules:GENERAL_TABLE_ID}" supId="3"/>
            </subrule>
            <subrule id="{$rules:COMPLETNESS_NILACTIVITY_SUBID}">
                <ruletext>If NIL report is selected, then no other activities can be selected.</ruletext>
                <ruletable id="{$rules:GENERAL_TABLE_ID}" supId="4"/>
            </subrule>
            <subrule id="{$rules:COMPLETNESS_PRODUCER_SUBID}">
                <ruletext>In the tab 'Company information' you ticked that you are a producer in this gas group but in the tab referring to this gas group you did not report any production quantities. Please report the produced quantities or un-tick the producer box for this gas group.</ruletext>
                <ruletable id="{$rules:GENERAL_TABLE_ID}" supId="5"/>
            </subrule>
            <subrule id="{$rules:COMPLETNESS_IMPORTER_SUBID}">
                <ruletext>In the tab 'Company information' you ticked to be an importer in this gas group but in the tab referring to this gas group you did not report any imported quantities. Please check the imported quantities or un-tick the importer box for this gas group.</ruletext>
                <ruletable id="{$rules:GENERAL_TABLE_ID}" supId="6"/>
            </subrule>
            <subrule id="{$rules:COMPLETNESS_EXPORTER_SUBID}">
                <ruletext>You ticked to be an exporter in the sheet 'company information' but no amount of export is considered. Please check the data or untick the export box.</ruletext>
                <ruletable id="{$rules:GENERAL_TABLE_ID}" supId="7"/>
            </subrule>
               <subrule id="{$rules:PLAUSIBILITY_WRONGNUMBER_SUBID}">
                <ruletext>Please enter only plain figures into the cells.</ruletext>
                <ruletable id="{$rules:EXPORTER_TABLE_ID}" supId="1"/>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="1"/>
            </subrule>
            <subrule id="{$rules:PLAUSIBILITY_NEGATIVENUMBER_SUBID}">
                <ruletext>Please enter only positive figures into the cells.</ruletext>
                <ruletable id="{$rules:EXPORTER_TABLE_ID}" supId="2"/>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="2"/>
                <ruletable id="{$rules:COPRODUCER_TABLE_ID}" supId="1"/>
            </subrule>

            <error_level>0</error_level>
            <show_missing>true</show_missing>
        </rule>
    </group>
;


declare variable $rules:WARNING_RULES_XML as element(group) :=
    <group id="general" label="Check if data is correct">
        <rule code="{$rules:FGASES_WARNINGRULE_ID}">
            <title>Potential errors:</title>
            <descr>The quality check found some issues that may need to be followed-up with your company at a later stage. You don't have to change your data at present.</descr>
            <rulefine>No potential errors have been found.</rulefine>
            <additional_descr></additional_descr>
            <message></message>
            <subrule id="{$rules:WARNING_DECIMALS_SUBID}">
                <ruletext>Please do not use more than three decimal places for your entry in metric tons.</ruletext>
                <ruletable id="{$rules:EXPORTER_TABLE_ID}" supId="3"/>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="3"/>
                <ruletable id="{$rules:COPRODUCER_TABLE_ID}" supId="2"/>
            </subrule>
            <subrule id="{$rules:WARNING_PREVSTOCK_SUBID}">
                <ruletext>The amounts of the reported gas as stocks 1 January in your present report is not consistent with the amounts reported as stocks 31 December in your previous year's report. (Explanation provided)</ruletext>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="10"/>
            </subrule>
            <subrule id="{$rules:WARNING_STOCKINCREASE_SUBID}">
                <ruletext role="producer">Your stock increase between 1 January and 31 December for the gas appears to be implausibly high. It should be smaller than or equal to the sum of Production, Import, Collection for reclamation and destruction, Purchases from Co-producers and Other EU purchases. (Explanation provided)</ruletext>
                <ruletext role="nonproducer">Your stock increase between 1 January and 31 December for the gas appears to be implausibly high. It should be smaller than or equal to your Imports. Please note that you as a non-producing company should report only only those stockpiled quantitites which were previously imported by your company. (Explanation provided)</ruletext>
                <ruletable id="{$rules:PRODIMP_TABLE_ID}" supId="12"/>
            </subrule>
            <subrule id="{$rules:CONSISTENCY_STOCKMISSING_SUBID}">
                <ruletext>In your last year's submission you reported on 31 December stocks of the gases listed above. That's why these gases were expected in your present report as well. In case you are still an importer or producer in the respective gas group(s) (HFCs/PFCs/SF6), please add these gases to your selection and complete the reporting.</ruletext>
                <ruletable id="{$rules:MISSING_TABLE_ID}" supId="1"/>
            </subrule>

            <error_level>1</error_level>
            <show_missing>true</show_missing>
        </rule>
    </group>
;


declare variable $rules:RULES_XML as element(root) :=
<root>
<rules title="F-Gases Compliance Checks" id="{$rules:FGASES_COMMON_ID}">

    { $rules:ERROR_RULES_XML }
    { $rules:WARNING_RULES_XML }

</rules>
</root>
;

(:~
 : Get error messages for sub rules.
 : @param $ruleCode Parent rule code
 : @param $subRuleCodes List of sub rule codes.
 : @return xs:string
 :)
declare function rules:getSubRuleMessages($schemaId as xs:string, $ruleCode as xs:string, $subRuleCodes as xs:string*)
as xs:string
{
    let $rules := rules:getRules($schemaId)//group[rule/@code = $ruleCode]
    let $subRuleMessages :=
         for $subRuleCode in fn:reverse($subRuleCodes)
         let $rule := $rules//rule[@code = concat($ruleCode, ".", $subRuleCode)]
         return
             fn:concat($rule/@code, " ", $rule/message)
    return
        if (count($subRuleMessages) > 1) then string-join($subRuleMessages, "; ") else fn:string($subRuleMessages)
};
(:~
 : Get error message for given rule Code from the rules XML.
 : @param $ruleCode Rule code in rules XML.
 : @return xs:string
 :)
declare function rules:getRuleMessage($schemaId as xs:string, $ruleCode as xs:string)
as xs:string
{
    let $rule := rules:getRules($schemaId)//rule[@code = $ruleCode][1]
    return
        fn:concat($rule/@code, " ", $rule/message)
};
(:~
 : Get rule element for given rule Code from the rules XML.
 : @param $ruleCode Rule code in rules XML.
 : @return rule element.
 :)
declare function rules:getRule($schemaId as xs:string, $ruleCode as xs:string)
as element(rule)
{
    rules:getRules($schemaId)//child::rule[@code = $ruleCode][1]
(:$mandatoryElements: {fn:replace(fn:string-join(rules:getMandatoryElements(),", "),$rules:ELEM_SCHEMA_NS_PREFIX,"")}:)

};


declare function rules:getRules($schemaId as xs:string)
as element(rules){

    $rules:RULES_XML/child::rules[@id = $schemaId][1]

};
(:~
 : Get rule element for given rule Code from the rules XML.
 : @param $ruleCode Rule code in rules XML.
 : @return rule element.
 :)
declare function rules:getRulesByCode($ruleCodes as xs:string*)
as element(rule)*
{
    for $ruleCode in $ruleCodes
    let $additionalMessage := if (contains($ruleCode, $cutil:LIST_ITEM_SEP)) then substring-after($ruleCode, $cutil:LIST_ITEM_SEP) else ""
    let $additionalMessageUrl := if (contains($additionalMessage, $cutil:LIST_ITEM_SEP)) then substring-after($additionalMessage, $cutil:LIST_ITEM_SEP) else ""
    let $additionalMessageUrlName :=  $additionalMessage


    let $additionalMessage := if (contains($additionalMessage, $cutil:LIST_ITEM_SEP)) then substring-before($additionalMessage, $cutil:LIST_ITEM_SEP) else $additionalMessage
    let $ruleCode := if (contains($ruleCode, $cutil:LIST_ITEM_SEP)) then substring-before($ruleCode, $cutil:LIST_ITEM_SEP) else $ruleCode
    let $rules := rules:getRules($rules:FGASES_COMMON_ID)//rule[@code = $ruleCode]
    return
        if (string-length($additionalMessage) > 0) then
            for $rule in $rules
            return
                <rule code="{ $ruleCode}">{
                    for  $ruleElem in $rule/*
                    return
                        $ruleElem
                    }<additional_message><span>{ $additionalMessage }{
                        if ( string-length($additionalMessageUrl) > 0) then
                            <a href="{ $additionalMessageUrl }">{ $additionalMessageUrlName }</a>
                        else
                            ()
                    }</span></additional_message>
                </rule>
        else
            $rules
};


declare function rules:getSubRulesForTable($tableId)
as element(ruletable)* {

    let $elems :=
        $rules:RULES_XML//rule/subrule/ruletable[@id=$tableId]

    return
    for $tbl in $elems order by number($tbl/@supId)
        return $tbl

};

declare function rules:getRuleBySubId($subRuleId as xs:string)
as element(rule) {
    $rules:RULES_XML//rule[exists(subrule[@id=$subRuleId])]
};


declare function rules:getRulesBySubIds($subRuleIds as xs:string*)
as element(rule)* {
    let $allRuleDefCodes :=
    for $subId in $subRuleIds
    return
        rules:getRuleBySubId($subId)/@code



    return
    for $ruleCode in distinct-values($allRuleDefCodes)
    return
        rules:getRulesByCode($ruleCode)
};

