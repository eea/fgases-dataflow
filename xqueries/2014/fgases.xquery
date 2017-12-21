xquery version "1.0" encoding "UTF-8";
(:
 : Module Name: FGases dataflow (Main module)
 :
 : Version:     $Id: fgases.xquery 17234 2014-11-26 17:41:45Z kasperen $
 : Created:     3 July 2012
 : Copyright:   European Environment Agency
 :)
(:~
 : Reporting Obligation: http://rod.eionet.europa.eu/obligations/669
 : XML Schema: http://dd.eionet.europa.eu/schemas/fgases/FGasesReporting.xsd
 :
 : F-Gases QA Rules implementation
 :
 : @author Enriko Käsper
 :)


declare namespace xmlconv="http://converters.eionet.europa.eu/fgases";
(: namespace for BDR localisations :)
declare namespace i18n = "http://namespaces.zope.org/i18n";
(: Common utility methods :)
import module namespace cutil = "http://converters.eionet.europa.eu/fgases/cutil" at "fgases-common-util.xquery";
(: UI utility methods for build HTML formatted QA result:)
import module namespace uiutil = "http://converters.eionet.europa.eu/fgases/ui" at "fgases-ui-util.xquery";
(: Dataset specific utility methods for executing QA scripts:)
import module namespace xmlutil = "http://converters.eionet.europa.eu/fgases/xmlutil" at "fgases-util-2012.xquery";
(: Dataset rule definitions and utility methods:)
import module namespace rules = "http://converters.eionet.europa.eu/fgases/rules" at "fgases-rules-2012.xquery";

declare variable $xmlconv:jscript as element(script) :=

  <script language="javascript">
  <![CDATA[
    function toggle(divName, linkName) {{
        var elem = document.getElementById(divName);
        var text = document.getElementById(linkName);
        if(elem.style.display == "block") {{
            elem.style.display = "none";
            text.innerHTML = "Show details";
            }}
            else {{
              elem.style.display = "block";
              text.innerHTML = "Hide details";
            }}
      }}
      ]]>
     </script>
;

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

      ]]>
</style>

;

declare variable $xmlconv:rowletters as xs:string* := ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z')
;
(:===================================================================:)
(: Variable given as an external parameter by the QA service          :)
(:===================================================================:)
(:
declare variable $source_url as xs:string :='../test/empty_fgases.xml';
declare variable $source_url as xs:string :='../xml/fgases-empty-instance-test.xml';
declare variable $source_url as xs:string :='../test/empty_questionnaire_fgases.xml';
declare variable $source_url as xs:string :='../test/questionnaire_fgases.xml';
declare variable $source_url as xs:string :='../test/questionnaire_f-gases-1.xml';
declare variable $source_url as xs:string external;
declare variable $source_url as xs:string external;
:)
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

declare function xmlconv:validateReport($url as xs:string)
as element(div)
{
  let $doc := fn:doc($url)
  let $generalDataValidationResult := xmlconv:validateGeneralData($doc/FGasesReporting)

  let $hfcProdImpValidationResult := xmlconv:validateProdImp($doc/FGasesReporting, "HFC", "3")


  let $hfcCoProdImpValidationResult := xmlconv:validateCoProd($doc/FGasesReporting, "HFC", "4")
  let $hfcBlendImpValidationResult := xmlconv:validateProdImp($doc/FGasesReporting, "HFC-preparations", "5")
  let $pfcProdImpValidationResult := xmlconv:validateProdImp($doc/FGasesReporting, "PFC", "6")
  let $pfcCoProdImpValidationResult := xmlconv:validateCoProd($doc/FGasesReporting, "PFC", "7")

  let $sf6ProdImpValidationResult := xmlconv:validateProdImp($doc/FGasesReporting, "SF6", "8")
  let $sf6CoProdValidationResult := xmlconv:validateCoProd($doc/FGasesReporting, "SF6", "9")

  let $exportValidationResult := xmlconv:validateExport($doc/FGasesReporting)

  let $missingStocks := xmlconv:validateStocks($doc/FGasesReporting)
  let $missingInfo := uiutil:buildAdditionalInfoToTable($missingStocks,rules:getSubRulesForTable($rules:MISSING_TABLE_ID))

  return
    <div>

        {$generalDataValidationResult}
        {$hfcProdImpValidationResult}
        {$hfcCoProdImpValidationResult}
        {$hfcBlendImpValidationResult}
        {$pfcProdImpValidationResult}
        {$pfcCoProdImpValidationResult}
        {$sf6ProdImpValidationResult}
        {$sf6CoProdValidationResult}
        {$exportValidationResult}

        {if (not(empty($missingStocks))) then uiutil:buildTableHeader("Missing gases") else ()}
        {$missingStocks}
        {$missingInfo}

    </div>

};

(: missing gases table :)
declare function xmlconv:validateStocks($doc)
as element(table)? {

    let $transactionYear :=
    if ($doc/GeneralReportData/TransactionYear castable as xs:integer) then
        xs:integer($doc/GeneralReportData/TransactionYear)
      else
        0


    let $gasCodes := xmlconv:getGasesWithStockQuantity($transactionYear, $doc/GeneralReportData/Company/CompanyId)


    let $rows :=
    for $gasCode in $gasCodes
        return
        if (exists($doc//Report/Gas[Code=$gasCode])) then
            ()
        else
            <tr><td>{uiutil:buildResultElement( $gasCode, rules:getRulesByCode($rules:FGASES_WARNINGRULE_ID) ,$rules:CONSISTENCY_STOCKMISSING_SUBID,$rules:MISSING_TABLE_ID)}</td></tr>

   return
   if (count($rows) gt 0) then
    <table  class="datatable" style="{$uiutil:TABLE_STYLE}">{$rows}</table>
   else
    ()

};
declare function xmlconv:buildCoProdSubstanceRows($reports as element(CoProducerReport)*)
as element(tr)* {
    for $report in $reports
        where string-length($report/CoProducer) gt 0 or exists($report/Transactions/Transaction[string-length(ValueInTons) gt 0])

        return
            <tr>
            <td>&#32;
            {xmlconv:validateCoProducer($report/CoProducer)}
            </td>
               {xmlconv:validateCoProdSubstanceCols($report/Transactions)}
            </tr>
};

declare function xmlconv:validateCoProdSubstanceCols($transactions as element(Transactions))
as element(td)* {
    for $transaction in $transactions/Transaction
        return xmlconv:validateCoProdNumberCol($transaction)
};

declare function xmlconv:validateCoProducer($coProducer as element(CoProducer))
as element(div) {
    let $nameOk := xmlutil:isValidCompanyName($coProducer)

    let $errDef := if ($nameOk) then () else rules:getRulesByCode($rules:FGASES_ERROR_ID)
    let $subRuleId := if ($nameOk) then () else $rules:CONSISTENCY_COPRODNAME_SUBID

    return
        uiutil:buildResultElement($coProducer,$errDef,$subRuleId,$rules:COPRODUCER_TABLE_ID)


};

declare function xmlconv:validateCoProd($doc as element(FGasesReporting), $gasGroup as xs:string, $tableNo as xs:string)
as element(div) {
    let $reports := $doc/CoProducerReports[@gasGroup = $gasGroup]
    let $substancesTemplate := $reports/CoProducerReport[1]/Transactions/Transaction

    let $substHeaderCols :=
        uiutil:buildHeaderColumns($substancesTemplate,"GasCode")


    let $purchaceRows := xmlconv:buildCoProdSubstanceRows($reports/CoProducerReport[@type="purchase"])
    let $salesRows := xmlconv:buildCoProdSubstanceRows($reports/CoProducerReport[@type="sale"])

    let $coProdTable :=
    if (not(empty($purchaceRows)) or not(empty($salesRows))) then
        <table class="datatable" style="{$uiutil:TABLE_STYLE}">
            <tr>
                <th style="{$uiutil:TH_SUB_HEADING_STYLE}" i18n:translate="">Company name/(metric tonnes)</th>
                {$substHeaderCols}
            </tr>
            <tr>
                 <th style="background-color:grey" colspan="{count($substHeaderCols)+1}" i18n:translate="">Purchases from Community co-producers</th>
            </tr>
            {$purchaceRows}
            <tr>
                 <th style="background-color:grey" colspan="{count($substHeaderCols)+1}" i18n:translate="">Sales to Community co-producers</th>
            </tr>
            {$salesRows}
        </table>
    else
        ()
    let $additionalInfo := uiutil:buildAdditionalInfoToTable($coProdTable,rules:getSubRulesForTable($rules:COPRODUCER_TABLE_ID))

    return
        <div><span>&#32;</span>
            {if (empty($coProdTable)) then () else uiutil:buildTableHeader(xmlutil:getLabel(concat("p", $tableNo, "-h2"),"Producer And Importer Form"))}
            {$coProdTable}
            {$additionalInfo}
        </div>

};


(:
: Returns a table similar to prod/imp table in webform - if no data  returns ()
:)
declare function xmlconv:validateProdImp($doc as element(FGasesReporting), $gasGroup as xs:string, $tableNo as xs:string)
as element(div)? {

    let $reports := $doc/Reports[@gasGroup = $gasGroup]

    let $hasNumericData := count($doc/Reports[@gasGroup = $gasGroup]//Transactions[@type!='Exporter']//ValueInTons[string-length(.)>0])>0

    return
    if ($hasNumericData) then
        xmlconv:buildProdImpTable($doc, $gasGroup, $tableNo)
    else
        ()

};


declare function xmlconv:buildProdImpTable($doc as element(FGasesReporting), $gasGroup as xs:string, $tableNo as xs:string)
as element(div) {
    let $reports := $doc/Reports[@gasGroup = $gasGroup]

    let $hasNumericData := count($reports//ValueInTons[string-length(.)>0])>0

    let $isProducer :=  $doc/GeneralReportData/Company/Activities/Production[@gasGroup=(if ($gasGroup="HFC-preparations") then "HFC" else $gasGroup)]/text() = "true"
    let $gases :=
    for $report in $reports/Report
        return $report/Gas

    let $substanceCodes :=
    for $code in $gases/Code[string-length(.) >0]
        return $code

    let $sumData := xmlconv:getSubstanceSumRows($substanceCodes,$doc)

    let $transNamesSection1 := ('Production_EC', 'Import_into_EC', 'Export_(I-P-Form)_from_EC', 'Other_amounts_reclam_destruc_within_EC')
    let $transNamesSection2 := ('Amount_purchased_other_EC_source', 'Stocks_held_1_January', 'Stocks_held_31_December', 'Reclamation_own', 'Destruction_own', 'Destruction_on_behalf_in_EC', 'Feedstock_own_use')
    let $transNamesSection3 := ('App_Refrigeraration_air_cond', 'App_Fire_protection', 'App_Aerosols', 'App_Solvents', 'App_Foams', 'App_Feedstock', 'App_Other_or_unknown', 'App_Semiconductor_manufacture', 'App_Electrical_equipment', 'App_Magnesium_die_casting_Operations')


    let $substanceHeaderCols := xmlconv:validateSubstanceHeaderColumns($gases, $rules:PRODIMP_TABLE_ID)

    (: 1st Transaction element is used as a template for the 1st (header) column if building rows :)
    let $transactionsTemplate := $doc/Reports[@gasGroup = $gasGroup]/Report[1]/Transactions[@type="ProducerImporter" or @type="Importer"][1]

    let $rowPos := 0
    let $rows := xmlconv:buildProdImpSectionRows($transNamesSection1,$gasGroup,$reports,$substanceCodes, $rowPos)
    let $rowPos := count($rows)

    let $coProdPurchase := if ($gasGroup != "HFC-preparations") then
        xmlconv:buildSumRow("transaction-5", $sumData, 1, $rowPos+1, "")
    else ()

    let $rows := insert-before($rows, count($rows)+1, $coProdPurchase)
    let $rowPos := count($rows)

    let $coProdSales := if ($gasGroup != "HFC-preparations") then
        xmlconv:buildSumRow("transaction-6", $sumData, 2, $rowPos+1, "")
    else
        ()

    let $rows := insert-before($rows, count($rows)+1, $coProdSales)
    let $rowPos := count($rows)

    let $rows := insert-before($rows, count($rows)+1, xmlconv:buildProdImpSectionRows($transNamesSection2,$gasGroup,$reports,$substanceCodes, $rowPos))
    let $rowPos := count($rows)
    (: Exception : for HFC-preparations the sums must be equal : same as for non producer - qa for hfc-preparations is same that for non producers :)
    let $availForSale :=
        xmlconv:buildTotalSumRowRuleCheck("availableForSale", 3, $sumData, $isProducer, $rowPos+1, $gasGroup, lower-case($gasGroup)='hfc-preparations')
    (:
    xmlconv:buildTotalPOMSumRow($sumData, $isProducer and not(lower-case($gasGroup)='hfc-preparations'), $rowPos+1, $gasGroup)
    :)

    let $rows := insert-before($rows, count($rows)+1, $availForSale)
    let $rowPos := count($rows)

    let $rows := insert-before($rows, count($rows)+1, xmlconv:buildProdImpSectionRows($transNamesSection3,$gasGroup,$reports,$substanceCodes, $rowPos))
    let $rowPos := count($rows)

    let $placedForMarket :=
                    (:xmlconv:buildSumRow("transaction-38", $sumData, 4, $rowPos+1) :)
                    xmlconv:buildTotalSumRowRuleCheck("placedOnMarket", 4, $sumData, $isProducer, $rowPos+1, $gasGroup, lower-case($gasGroup)='hfc-preparations')
                            (:
                            xmlconv:buildSumRowWithID("placedOnMarket", $sumData, 4, $rowPos+1, $gasGroup)
                            :)
    let $totalSold :=
        (:xmlconv:buildSumRow("transaction-39", $sumData, 5, $rowPos+2):)
        xmlconv:buildSumRowWithID("totalSold", $sumData, 5, $rowPos+2, $gasGroup)

    let $rows := insert-before($rows, count($rows)+1, $placedForMarket)
    let $rows := insert-before($rows, count($rows)+1, $totalSold)

    let $prodImpTable :=
    <table class="datatable" style="{$uiutil:TABLE_STYLE}">
        <tr>
            <th i18n:translate="">Transactions/(metric tonnes)</th>
            {$substanceHeaderCols}
        </tr>
        {$rows}
    </table>

    let $additionalInfo := uiutil:buildAdditionalInfoToTable($prodImpTable,rules:getSubRulesForTable($rules:PRODIMP_TABLE_ID), if($isProducer) then "producer" else "nonproducer")

    (:
    let $missingStocks := xmlconv:validateStocks($doc,$gasGroup)
    let $missingInfo := uiutil:buildAdditionalInfoToTable($missingStocks,rules:getSubRulesForTable($rules:MISSING_TABLE_ID))
    :)
    return
        <div><span>&#32;</span>
            {uiutil:buildTableHeader(xmlutil:getLabel(concat("p", $tableNo, "-h2"),concat("Producer And Importer Form: ", $gasGroup)))}
            {$prodImpTable}
            {$additionalInfo}
        </div>

};

declare function xmlconv:buildProdImpSectionRows($transNames as xs:string*, $gasGroup as xs:string, $reports as element(Reports), $substanceCodes as xs:string*, $letterStartPos as xs:integer)
as element(tr)* {
    (: build existing transnames :)

    let $existingTransNames :=
    for $transName in $transNames
        where exists($reports/Report/Transactions/Transaction[Name=$transName])
        return
            $transName

    let $letters := $xmlconv:rowletters
    for $transName at $pos in $existingTransNames
        let $allowNegativeNumbers := xmlutil:isNegativeAllowed($rules:TRANSACTION_LABEL_XML, $gasGroup,  $transName)
        let $letter := $letters[$pos+$letterStartPos]
        let $commentsRow := xmlconv:buildSubstanceDescrsRow($substanceCodes, $transName, $reports)

        let $result := if (not(empty($commentsRow))) then
                            ($commentsRow)
                        else
                            ()
        let $result := insert-before($result, 0,
                <tr>
                    <td><span i18n:translate="">{$letter}</span>&#32;<span i18n:translate="">{xmlutil:getTransactionLabel($rules:TRANSACTION_LABEL_XML, $gasGroup,  $transName)}</span></td>
                    {xmlconv:validateSubstanceCols($substanceCodes, $transName, $reports, $allowNegativeNumbers, $rules:PRODIMP_TABLE_ID)}
                </tr>
            )
        return
            $result
};


(: sum row including TOTALS rule check :)
declare function xmlconv:buildTotalSumRowRuleCheck($transId as xs:string, $pos as xs:integer, $sumData as xs:string*,
    $isProducer as xs:boolean, $rowPos as xs:integer, $gasGroup as xs:string, $isHFCPrepImportForm as xs:boolean)
as element (tr)
{

  let $labelDef := $rules:SUM_FORMULAS_XML/Total[@id=$transId]/Formula[@gasGroup=$gasGroup]
  let $formula := $labelDef/text()
  let $labelId := $labelDef/@transactionId

  return
  <tr>
    <td><span i18n:translate="">{$xmlconv:rowletters[$rowPos]}</span>&#32;<span i18n:translate="">{xmlutil:getLabel($labelId, "")}</span>&#32;{if ($formula != "") then <span>(<span i18n:translate="">{$formula}</span>)</span> else ()}</td>
    {for $x in $sumData
        let $tokens := tokenize($x, '##')
        let $availForSale := xs:decimal($tokens[3])
        let $placedForMarket := xs:decimal($tokens[4])

    (: Exception : for HFC-preparations the sums must be equal : same as for non producer - qa for hfc-preparations is same that for non producers :)

        let $totalOk :=
            if ($isProducer and not($isHFCPrepImportForm)) then
                $availForSale >= $placedForMarket
            else
                $availForSale = $placedForMarket

            let $subErrorCodes := if ($totalOk) then () else if ($isHFCPrepImportForm) then $rules:CONSISTENCY_TOTALS_HFCPREPIMP_SUBID else $rules:CONSISTENCY_TOTALS_SUBID
            let $errorDefs :=     if ($totalOk) then () else rules:getRulesByCode($rules:FGASES_ERROR_ID)

            return
                <td style='background-color:grey; font-weight:bold'>{uiutil:buildResultElement($tokens[$pos],$errorDefs,$subErrorCodes,$rules:PRODIMP_TABLE_ID)}</td>
     }
  </tr>
};




(: sum row including TOTALS rule check obsolete :)
(:
declare function xmlconv:buildTotalPOMSumRow($sumData as xs:string*, $isProducer as xs:boolean, $rowPos as xs:integer, $gasGroup as xs:string)
as element (tr)
{

  let $labelDef := $rules:SUM_FORMULAS_XML/Total[@id="availableForSale"]/Formula[@gasGroup=$gasGroup]
  let $formula := $labelDef/text()
  let $labelId := $labelDef/@transactionId

  return
  <tr>
    <td>{concat($xmlconv:rowletters[$rowPos], ' ', concat( xmlutil:getLabel($labelId, ""), " (", $formula, ")"))}</td>
    {for $x in $sumData
        let $tokens := tokenize($x, '##')
        let $availForSale := xs:decimal($tokens[3])
        let $placedForMarket := xs:decimal($tokens[4])

        let $totalOk :=
            if ($isProducer) then
                $availForSale >= $placedForMarket
            else
                $availForSale = $placedForMarket

            let $subErrorCodes := if ($totalOk) then () else $rules:CONSISTENCY_TOTALS_SUBID
            let $errorDefs :=     if ($totalOk) then () else rules:getRulesByCode($rules:FGASES_ERROR_ID)

            return
                <td style='background-color:grey; font-weight:bold'>{uiutil:buildResultElement($tokens[3],$errorDefs,$subErrorCodes,$rules:PRODIMP_TABLE_ID)}</td>
     }
  </tr>
};
:)

declare function xmlconv:buildSumRowWithID($transId as xs:string, $sumData as xs:string*, $tokenPos as xs:integer, $letterPos as xs:integer, $gasGroup as xs:string) {
    let $labels := $rules:SUM_FORMULAS_XML

    let $labelDef := $labels/Total[@id=$transId]/Formula[@gasGroup=$gasGroup]

    let $formula := $labelDef/text()
    let $labelId := $labelDef/@transactionId

    return
        xmlconv:buildSumRow($labelId, $sumData, $tokenPos, $letterPos, $formula)


};

declare function xmlconv:buildSumRow($labelId as xs:string, $sumData as xs:string*, $tokenPos as xs:integer, $letterPos as xs:integer, $formula as xs:string) {
  <tr>
    <td><span i18n:translate="">{$xmlconv:rowletters[$letterPos]}</span>&#32;<span i18n:translate="">{xmlutil:getLabel($labelId, "")}</span>&#32;{if ($formula != "") then <span>(<span i18n:translate="">{$formula}</span>)</span> else ()}</td>
    {for $x in $sumData
        let $tokens := tokenize($x, '##')
            return <td style='background-color:grey; font-weight:bold'>&#32;{$tokens[$tokenPos]}</td>
    }
  </tr>
};



declare function xmlconv:buildSubstanceDescrsRow($substanceCodes, $transName, $reports) as element(tr)? {
    let $hasDescriptions := count($reports/Report/Transactions/Transaction[Name = $transName and string-length(normalize-space(Description)) gt 0]) gt 0

    let $descrCols :=
        if ($hasDescriptions) then
            for $substanceCode in $substanceCodes
                let $report := $reports/Report[Gas[1]/Code=$substanceCode]
                let $desc := normalize-space(data($report/Transactions/Transaction[Name = $transName]/Description))
                let $desc := if (string-length($desc) gt 100) then concat(substring($desc,1,100), "...") else $desc
                return
                    <td style="{$uiutil:TD_DESCR_STYLE}">&#32;{$desc}</td>
        else
            ()


  return
      if ($hasDescriptions) then
        <tr>
            <td>&#32;</td>
            {$descrCols}
        </tr>
      else
        ()
};

(:
:  Calculates sums requred in report and qa and returns them in sequence
:  each row has aggregated values of one gas, separated by '##' positions are: 1 - Co producer purhaces, 2 - Co Producer sales, 3 - available for sale, 4 - placed on market, 5 - Total Sale
:)
declare function xmlconv:getSubstanceSumRows($substanceCodes as xs:string*,  $reports as element(FGasesReporting)) {

 for $substanceCode in $substanceCodes
    let $report := $reports/Reports/Report[Gas/Code=$substanceCode]
    let $transactions := $report/Transactions
    let $coProdPurchases := sum($reports//CoProducerReport[@type="purchase"]//Transaction[GasCode=$substanceCode]/xmlutil:getZeroIfNotNumber(ValueInTons)[. castable as xs:decimal])
    let $coProdSales := sum($reports//CoProducerReport[@type="sale"]//Transaction[GasCode=$substanceCode]/xmlutil:getZeroIfNotNumber(ValueInTons)[. castable as xs:decimal])

    let $availForSale := xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='Production_EC']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='Import_into_EC']/ValueInTons) -
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='Export_(I-P-Form)_from_EC']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='Other_amounts_reclam_destruc_within_EC']/ValueInTons) +
                        $coProdPurchases -
                        $coProdSales +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='Amount_purchased_other_EC_source']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='Stocks_held_1_January']/ValueInTons) -
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='Stocks_held_31_December']/ValueInTons) -
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='Destruction_own']/ValueInTons) -
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='Destruction_on_behalf_in_EC']/ValueInTons) -
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='Feedstock_own_use']/ValueInTons)

   let $placedOnMarket :=
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='App_Refrigeraration_air_cond']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='App_Fire_protection']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='App_Aerosols']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='App_Solvents']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='App_Foams']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='App_Feedstock']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='App_Electrical_equipment']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='App_Magnesium_die_casting_Operations']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='App_Semiconductor_manufacture']/ValueInTons) +
                        xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='App_Other_or_unknown']/ValueInTons)

    let $totalSold :=  xmlutil:getZeroIfNotNumber($transactions/Transaction[Name='Export_(I-P-Form)_from_EC']/ValueInTons) +
                        $coProdSales +
                        $availForSale

    let $result := concat($coProdPurchases,'##', $coProdSales, '##', $availForSale,'##', $placedOnMarket,'##', $totalSold)

    return
        $result
};


declare function xmlconv:buildSubstanceCoProdCols($substanceCodes as xs:string*, $type as xs:string, $reports as element(FGasesReporting)) {
 for $substanceCode in $substanceCodes
    let $sum := sum($reports//CoProducerReport[@type=$type]//Transaction[GasCode=$substanceCode]/ValueInTons[. castable as xs:decimal])
    return
        <td style="background-color:grey; font-weight:bold">&#32;{$sum}</td>
};

declare function xmlconv:validateSubstanceCols($substanceCodes as xs:string*, $transactionName as xs:string, $reports as element(Reports), $allowNegativeNumbers as xs:boolean, $tableName as xs:string )
as element(td)*
{
    let $company := $reports/../GeneralReportData/Company

    for $substanceCode in $substanceCodes
        let $report := $reports/Report[Gas[1]/Code=$substanceCode]
        let $transaction := $report/Transactions/Transaction[Name = $transactionName]
        let $amount := $transaction/ValueInTons
        let $desc := normalize-space(data($report/Transactions/Transaction[Name = $transactionName]/Description))

        let $numberOk:= if ($allowNegativeNumbers) then xmlutil:isNumber($amount) else xmlutil:isPositiveNumber($amount)
        let $decimalsOk := xmlutil:hasCorrectDecimals($amount)

        let $subErrDefs :=
            if ($allowNegativeNumbers) then if ($numberOk) then () else ($rules:PLAUSIBILITY_WRONGNUMBER_SUBID)
            else if ($numberOk) then () else  ($rules:PLAUSIBILITY_NEGATIVENUMBER_SUBID)

        let $subErrDefs := if($decimalsOk) then $subErrDefs else insert-before ($subErrDefs, count($subErrDefs)+ 1, $rules:WARNING_DECIMALS_SUBID)

        (: special rules :)
        let $consistencyErrors := xmlconv:getSpecialConsistencyErrors($report,$transactionName,$transaction)

        (: other descr exists :)
        let $consistencyErrors :=
            if ($transactionName = $rules:FGASES_OTHER_TRANSTYPE and string-length($amount) gt 0 and string-length($desc) = 0) then
                insert-before($consistencyErrors, count($consistencyErrors)+1, $rules:CONSISTENCY_OTHER_SUBID)
             else
                $consistencyErrors

        let $subErrDefs :=  if(empty($consistencyErrors)) then $subErrDefs else insert-before ($subErrDefs, count($subErrDefs)+1, $consistencyErrors)
        let $errDef := rules:getRulesBySubIds($subErrDefs)

        return
            <td>{uiutil:buildResultElement(string($amount), if (empty($subErrDefs)) then () else $errDef, $subErrDefs, $tableName)}</td>
};

(: for certain columns there are special errors define. Hanlde them based on element name :)
declare function xmlconv:getSpecialConsistencyErrors($report as element(Report), $transactionName as xs:string, $transaction as element(Transaction))
as xs:string* {
    let $gasGroup := $report/../@gasGroup
    let $company := $report/../../GeneralReportData/Company

    let $lastYear := if ($report/../../GeneralReportData/TransactionYear castable as xs:integer) then xs:integer($report/../../GeneralReportData/TransactionYear) - 1 else 0

    let $value := data($transaction/ValueInTons)
    let $isProducer := $company/Activities/Production[@gasGroup=(if ($gasGroup="HFC-preparations") then "HFC" else $gasGroup)]/text() = "true"

    return
        if (not($isProducer) and not(empty(index-of($rules:FGASES_PRODUCER_FIELDS, $transactionName))) and string-length($value) gt 0) then
            ($rules:CONSISTENCY_PRODSPECIAL_SUBID)
        else if ($transactionName = 'Stocks_held_1_January') then
            if (xmlutil:getZeroIfNotNumber($value) != xmlutil:getPrevYearStock($source_url, string($lastYear), $report/Gas/Code, $company/CompanyId)) then
                if (empty($transaction/Description) or string-length($transaction/Description) = 0) then
                    ($rules:CONSISTENCY_STOCKPREVYEAR_SUBID)
                 else
                    ($rules:WARNING_PREVSTOCK_SUBID)
            else
                ()
        else if ($transactionName = 'Stocks_held_31_December') then
            if (not(xmlconv:isValidStockIncrease($report, $transaction, $isProducer, $gasGroup))) then

                if (cutil:isMissingOrEmpty($transaction/Description)) then
                    $rules:CONSISTENCY_STOCKINCREASE_SUBID
                else
                    $rules:WARNING_STOCKINCREASE_SUBID
            else
                ()

        (: check if quantity is also in Exporter form :)
        else if ($transactionName = "Export_(I-P-Form)_from_EC") then
            if (xmlconv:isValidExportInProdImp($report,$transaction)) then
                ()
            else
                $rules:CONSISTENCY_EXPCROSSCHECKING_SUBID
        else ()
};

(: checks if export form has same quantity than value in ProdImp form :)
declare function xmlconv:isValidExportInProdImp($report as element(Report),$transaction as element(Transaction))
as xs:boolean {
    let $exportFormSum := xmlutil:getZeroIfNotNumber($report/Transactions[@type="Exporter"]/Transaction[Name='Export_from_EC_Total_(Exp_Form)']/ValueInTons)

    let $prodImpFormSum := xmlutil:getZeroIfNotNumber($transaction/ValueInTons)

    return
         ($exportFormSum = $prodImpFormSum)

};

declare function xmlconv:isValidStockIncrease($report as element(Report), $transaction as element(Transaction), $isProducer as xs:boolean, $gasGroup as xs:string)
as xs:boolean {

    let $gasCode := data($report/Gas/Code)

    let $production := xmlutil:getZeroIfNotNumber($transaction/../Transaction[Name='Production_EC']/ValueInTons)
    let $imports := xmlutil:getZeroIfNotNumber($transaction/../Transaction[Name='Import_into_EC']/ValueInTons)
    let $reclamAndDestruction := xmlutil:getZeroIfNotNumber($transaction/../Transaction[Name='Other_amounts_reclam_destruc_within_EC']/ValueInTons)

    let $coProdPurchaces := sum($report/../../CoProducerReports[@gasGroup=$gasGroup]/CoProducerReport[@type='purchase']//Transaction[GasCode=$gasCode]/ValueInTons[. castable as xs:decimal])
    let $otherEuPurchaces := xmlutil:getZeroIfNotNumber(data($transaction/../Transaction[Name='Amount_purchased_other_EC_source']/ValueInTons))

    let $stockIncrease := xmlutil:getZeroIfNotNumber($transaction/ValueInTons) - xmlutil:getZeroIfNotNumber($transaction/../Transaction[Name='Stocks_held_1_January']/ValueInTons)

    return
        if ($isProducer) then
            $stockIncrease <= ($production + $imports + $reclamAndDestruction + $coProdPurchaces + $otherEuPurchaces)
        else
            $stockIncrease <= $imports

};


declare function xmlconv:validateGeneralData($doc as element(FGasesReporting))
as element(div) {
      let $generalData := $doc/GeneralReportData
      let $errDef := rules:getRulesByCode($rules:FGASES_ERROR_ID)

      (: status must be submitted :)
      let $statusCorrect := if (lower-case(data($generalData/@status)) = $rules:FGASES_FINAL_STATUS) then fn:true() else fn:false()
      (: year must be between 2007 and current year :)
      let $reportYear := if ($generalData/TransactionYear castable as xs:integer) then
        xs:decimal($generalData/TransactionYear)
      else
        ()

      let $currentYear := fn:year-from-date(current-date())
      let $yearCorrect :=        (not(empty($reportYear)) and $reportYear >= $rules:FGASES_MIN_YEAR and $reportYear <= $currentYear)

      (: at least one activity :)
      let $atLeastOneActivityOK := (count($generalData/Company/Activities/child::*[text()='true']) gt 0)
      (: if NIL then not other activities :)
      let $noOtherIfNilReportOK := not(count($generalData/Company/Activities/child::*[text()='true']) gt 1 and $generalData/Company/Activities/NoReporting = 'true')

      let $activitiesOK :=  $atLeastOneActivityOK and $noOtherIfNilReportOK
      (:let $activitiesLabel := xmlutil:buildSelectedElemNames($generalData/Company/Activities, "gasGroup"):)

      let $errorSubCode :=
          if ($activitiesOK) then
            ()
          else
             if (not($atLeastOneActivityOK)) then $rules:COMPLETNESS_NOACTIVITIES_SUBID else $rules:COMPLETNESS_NILACTIVITY_SUBID


     (: show certified as status if status is submitted for clearness :)
     let $statusText :=
        if (data($generalData/@status) = 'submitted') then
            "Certified"
        else if (data($generalData/@status) = 'confirmed') then
            "In progress"
        else
            data($generalData/@status)

    (: Activity selected but sum is 0 for the activity :)
    let $resultTable :=
    <div>
        {uiutil:buildTableHeader("Company Information")}
        <table class="datatable" style="{ $uiutil:TABLE_STYLE }">
            <tr>
                <th style="{$uiutil:TH_STYLE}" i18n:translate="">Report status</th>
                <td>{uiutil:buildResultElement($statusText, (if ($statusCorrect) then () else $errDef), $rules:COMPLETNESS_WRONGSTATUS_SUBID, $rules:GENERAL_TABLE_ID, true())}</td>
            </tr>
            <tr>
                <th style="{$uiutil:TH_STYLE}" i18n:translate="">Transaction year</th>
                <td>{uiutil:buildResultElement(string($reportYear), (if ($yearCorrect) then () else $errDef), $rules:COMPLETNESS_WRONGYEAR_SUBID, $rules:GENERAL_TABLE_ID)}</td>
            </tr>
            <tr>
                <th style="{$uiutil:TH_STYLE}" colspan="2" i18n:translate="">Fluorinated greenhouse gas transaction(s)</th>
            </tr>
            <tr>
                <th style="{$uiutil:TH_STYLE}" i18n:translate="">NIL report</th>
                <td>{uiutil:buildResultElement(if($generalData/Company/Activities/NoReporting="true") then "selected" else "not selected", if (empty($errorSubCode)) then () else $errDef, $errorSubCode, $rules:GENERAL_TABLE_ID, true())}</td>
            </tr>
            {xmlconv:validateActivitiesAndTotals($doc , "Production", ("Production_EC"), $errorSubCode, $rules:COMPLETNESS_PRODUCER_SUBID, $rules:CROSSCHECK_NONPRODUCER_1T_SUBID)}
            {xmlconv:validateActivitiesAndTotals($doc , "Import", ("Import_into_EC"), $errorSubCode, $rules:COMPLETNESS_IMPORTER_SUBID, $rules:CROSSCHECK_NONIMPORTER_1T_SUBID)}


            {xmlconv:validateActivitiesAndTotals($doc , "Export",  ("Export_from_EC_Total_(Exp_Form)", "Export_(I-P-Form)_from_EC"), $errorSubCode, $rules:COMPLETNESS_EXPORTER_SUBID, $rules:CROSSCHECK_NONEXPORTER_1T_SUBID)}
        </table>
        </div>
     let $additionalInfo := uiutil:buildAdditionalInfoToTable($resultTable,rules:getSubRulesForTable($rules:GENERAL_TABLE_ID))
     return
        <div><span>&#32;</span>
            {$resultTable}
            {$additionalInfo}
        </div>
};

(:
: completness and cross tables checks
:)
declare function xmlconv:validateActivitiesAndTotals($report as element(FGasesReporting), $activityName as xs:string, $fieldNames as xs:string*,  $existingSubRuleCode as xs:string*, $subRuleCode as xs:string, $crossSubRuleCode as xs:string)
as element(tr)*
{
    let $rows :=
    for $activity in $report/GeneralReportData/Company/Activities/node()[name() = $activityName]
       let $reports :=


       if (not(empty($activity/@gasGroup))) then
        (: this is because of HFC preparations that have to be counted as well :)
            $report/Reports[starts-with(@gasGroup, $activity/@gasGroup)]
       else
            $report/Reports

       let $totalsOk := xmlconv:isTransactionTypeSumOk($activity, $reports, $fieldNames[1] )
       let $fieldName2 := if(count($fieldNames) = 2) then $fieldNames[2] else $fieldNames[1]
       let $crossCheckOk := xmlconv:isCrossCheckOk($activity, $reports, $fieldName2 )

       let $subRuleCodes := if (not($totalsOk)) then insert-before($existingSubRuleCode, count($existingSubRuleCode) +1, $subRuleCode) else $existingSubRuleCode
       let $subRuleCodes := if (not($crossCheckOk)) then insert-before($subRuleCodes, count($subRuleCodes) +1, $crossSubRuleCode) else $subRuleCodes

       let $activityLabel := if ($activity = "true") then "selected" else "not selected"

       let $errDef := rules:getRulesBySubIds($subRuleCodes)
       return
        <tr>
            <th style="{$uiutil:TH_STYLE}" i18n:translate="">{concat($activity/@gasGroup, " ", $activity/name())}</th>
            <td>{uiutil:buildResultElement($activityLabel, (if (empty($subRuleCodes)) then () else $errDef), $subRuleCodes, $rules:GENERAL_TABLE_ID, true())}</td>
        </tr>

    return
        $rows
};

(:
: checks if not selected activity sum exceeds one tonne
:)
declare function xmlconv:isCrossCheckOk ($activity as element(), $reports as element(Reports)*, $totalElemName as xs:string)
as xs:boolean {

    let $selected := (data($activity) = "true")
    let $sumGreaterThanOne := xmlconv:totalSumMoreThanOne($reports, $totalElemName)

    return
        (not($selected) and not($sumGreaterThanOne)) or $selected

};

(:
: Checks if activity is selected but nothing reported in corresponding form and field
:)
declare function xmlconv:isTransactionTypeSumOk($activity as element(), $reports as element(Reports)*, $totalElemName as xs:string)
as xs:boolean {

    let $selected := (data($activity) = "true")
    let $sumGreaterThanZero := xmlconv:totalSumGreaterThanZero($reports, $totalElemName)

    return
        ($selected and $sumGreaterThanZero) or (not($selected))

};

declare function xmlconv:totalSumGreaterThanZero($reports as element(Reports)*, $totalElemName as xs:string)
as xs:boolean {
    sum($reports/Report/Transactions/Transaction[Name = $totalElemName and string-length(ValueInTons) gt 0 and ValueInTons castable as xs:decimal]/ValueInTons) gt 0
};

declare function xmlconv:totalSumMoreThanOne($reports as element(Reports)*, $totalElemName as xs:string)
as xs:boolean {
    sum($reports/Report/Transactions/Transaction[Name = $totalElemName and string-length(ValueInTons) gt 0 and ValueInTons castable as xs:decimal]/ValueInTons) gt 1
};



declare function xmlconv:validateExport($doc as element(FGasesReporting))
as element(div)? {

    let $hasExportNumericValues := exists($doc//Transactions[@type='Exporter']//Transaction[string-length(ValueInTons) >0])

    return
    if ($hasExportNumericValues) then
        xmlconv:buildExportTable($doc)
    else
        ()

};
(:
: Returns a table similar to Exporter table in webform
:)
declare function xmlconv:buildExportTable($doc as element(FGasesReporting))
as element(div) {

    let $exportTable :=
    <table class="datatable" style="{$uiutil:TABLE_STYLE}">
        <tr>
            <th colspan="2" i18n:translate="">Section 1. Export totals (metric tonnes)</th>
            <th colspan="3" i18n:translate="">Section 2. Total amount exported for recycling reclamation and/or destruction (metric tonnes)</th>
        </tr>
        <tr>
            <th>&#32;</th>
            <th i18n:translate="">Annual total exported from the European Community</th>
            <th i18n:translate="">Recycling</th>
            <th i18n:translate="">Reclamation</th>
            <th i18n:translate="">Destruction</th>
        </tr>
        {xmlconv:buildGasGroupExportTable($doc, 'SF6', 'SF6')}
        {xmlconv:buildGasGroupExportTable($doc, 'HFC', 'HFCs')}
        {xmlconv:buildGasGroupExportTable($doc, 'HFC-preparations', 'HFC preparations')}
        {xmlconv:buildGasGroupExportTable($doc, 'PFC', 'PFCs/PFC preparations')}
    </table>

    let $hasTotalErrors := count($exportTable//span[@errorCode=$rules:FGASES_ERROR_ID]) gt 0
    let $additionalInfo := uiutil:buildAdditionalInfoToTable($exportTable,rules:getSubRulesForTable($rules:EXPORTER_TABLE_ID), "exporter")

    return
        <div><span>&#32;</span>
            {uiutil:buildTableHeader(xmlutil:getLabel("p10-h2","Section 1. Export totals (metric tonnes)"))}
            {$exportTable}
            {$additionalInfo}
        </div>
};

declare function xmlconv:buildGasGroupExportTable($doc as element(FGasesReporting), $gasGroupId as xs:string, $groupLabel as xs:string)
as element(tr)* {
   let $company := $doc/GeneralReportData/Company

   let $isProducer := count($company/Activities/Production[@gasGroup=$gasGroupId and text() = 'true']) gt 0
   let $isImporter :=
    if ($gasGroupId = "HFC-preparations") then
        count($company/Activities/Import[@gasGroup="HFC" and text() = 'true']) gt 0
    else
        count($company/Activities/Import[@gasGroup=$gasGroupId and text() = 'true']) gt 0

   let $reports := $doc/Reports[@gasGroup = $gasGroupId]

   let $tableRows :=
   for $report in $reports/Report
      let $exportTrans := $report/Transactions[@type="Exporter"]

      let $isValidTotal := xmlconv:isValidExportTotal($exportTrans)
      let $isValidCrossCheck :=
      if ($isProducer or $isImporter) then
            xmlconv:isValidExportCrossCheck($exportTrans, $doc)
        else
            fn:true()

      let $subCodes := if ($isValidCrossCheck) then () else ($rules:CONSISTENCY_EXPCROSSCHECKING_SUBID)
      let $subCodes := if ($isValidTotal) then $subCodes else insert-before($subCodes,1,$rules:CONSISTENCY_EXPTOTAL_SUBID)

      let $totalDecimalsOk := xmlutil:hasCorrectDecimals($exportTrans/Transaction[Name='Export_from_EC_Total_(Exp_Form)']/ValueInTons)
      let $subCodes := if ($totalDecimalsOk) then ($subCodes) else insert-before($subCodes, 1, $rules:WARNING_DECIMALS_SUBID )

      let $totalNumberOk := xmlutil:isPositiveNumber($exportTrans/Transaction[Name='Export_from_EC_Total_(Exp_Form)']/ValueInTons)
      let $subCodes := if ($totalNumberOk) then ($subCodes) else insert-before($subCodes,1, $rules:PLAUSIBILITY_NEGATIVENUMBER_SUBID)

      let $totalErrDefs := rules:getRulesBySubIds($subCodes)

      return
        <tr>
            <td>{xmlconv:validateGas($report/Gas, $rules:EXPORTER_TABLE_ID)}</td>
            <td>{uiutil:buildResultElement($exportTrans/Transaction[Name='Export_from_EC_Total_(Exp_Form)']/ValueInTons, $totalErrDefs, $subCodes, $rules:EXPORTER_TABLE_ID)}</td>
            {xmlconv:validateExportNumberCol($exportTrans/Transaction[Name='Export_for_Recycling'])}
            {xmlconv:validateExportNumberCol($exportTrans/Transaction[Name='Export_for_Reclamation'])}
            {xmlconv:validateExportNumberCol($exportTrans/Transaction[Name='Export_for_Destruction'])}
        </tr>

   let $tableRows :=   insert-before($tableRows, 1,
        (<tr><th colspan="5">&#32;</th></tr>,
        <tr>
            <th align = "center" colspan="5" style="background-color:grey" i18n:translate="">&#32;{$groupLabel}</th>
        </tr>))

   return
        $tableRows

};

declare function  xmlconv:validateCoProdNumberCol($transaction as element(Transaction))
as element(td) {

   let $gasGroup := $transaction/../../../@gasGroup
   let $isProducer := $transaction/../../../../GeneralReportData/Company/Activities/Production[@gasGroup=$gasGroup] = "true"


   let $amount := $transaction/ValueInTons

   let $decimalsOk := xmlutil:hasCorrectDecimals($amount)
   let $subCodes := if ($decimalsOk) then () else $rules:WARNING_DECIMALS_SUBID

   let $numberOk := xmlutil:isPositiveNumber($amount)
   let $subCodes := if ($numberOk) then ($subCodes) else insert-before($subCodes,1, $rules:PLAUSIBILITY_NEGATIVENUMBER_SUBID)

   (:
   let $isNonProducerOk :=  not (not($isProducer) and string-length($amount) gt 0)
   let $subCodes := if ($isNonProducerOk) then ($subCodes) else insert-before($subCodes,count($subCodes) + 1, $rules:CONSISTENCY_PRODSPECIAL_SUBID)
   :)
   let $errDefs := rules:getRulesBySubIds($subCodes)

   return
        <td>{uiutil:buildResultElement($amount, $errDefs, $subCodes, $rules:COPRODUCER_TABLE_ID)}</td>

};

declare function  xmlconv:validateExportNumberCol($transaction as element(Transaction))
as element(td) {

   let $amount := $transaction/ValueInTons

   let $decimalsOk := xmlutil:hasCorrectDecimals($amount)
   let $errDefs:=  if ($decimalsOk) then () else rules:getRulesByCode($rules:FGASES_WARNINGRULE_ID)
   let $subCodes := if ($decimalsOk) then () else $rules:WARNING_DECIMALS_SUBID

   let $numberOk := xmlutil:isPositiveNumber($amount)
   let $errDefs:=  if ($numberOk) then $errDefs else insert-before($errDefs, 1, rules:getRulesByCode($rules:FGASES_ERROR_ID))
   let $subCodes := if ($numberOk) then ($subCodes) else insert-before($subCodes,1, $rules:PLAUSIBILITY_NEGATIVENUMBER_SUBID)

   return
        <td>{uiutil:buildResultElement($amount, $errDefs, $subCodes, $rules:EXPORTER_TABLE_ID)}</td>

};

declare function  xmlconv:isValidExportCrossCheck($exportTrans as element(Transactions), $doc as element(FGasesReporting))
{
    let $exportSum := xmlutil:getZeroIfNotNumber($exportTrans/Transaction[Name='Export_from_EC_Total_(Exp_Form)']/ValueInTons)
    let $report := $exportTrans/..

    let $otherSum := xmlutil:getZeroIfNotNumber($report/Transactions/Transaction[Name='Export_(I-P-Form)_from_EC']/ValueInTons)

    return
         ($exportSum = $otherSum)


};

declare function xmlconv:isValidExportTotal($exportTrans as element(Transactions))
as xs:boolean {
    let $total :=  xmlutil:getZeroIfNotNumber(data($exportTrans/Transaction[Name='Export_from_EC_Total_(Exp_Form)']/ValueInTons))
    let $recycling := xmlutil:getZeroIfNotNumber(data($exportTrans/Transaction[Name='Export_for_Recycling']/ValueInTons))
    let $reclamation := xmlutil:getZeroIfNotNumber(data($exportTrans/Transaction[Name='Export_for_Reclamation']/ValueInTons))
    let $destruction := xmlutil:getZeroIfNotNumber(data($exportTrans/Transaction[Name='Export_for_Destruction']/ValueInTons))


    return
        $total >= $recycling + $reclamation + $destruction
     (: rounding tolerance
       if ($total != 0) then
        fn:abs(($total - ($recycling + $reclamation + $destruction)) div $total) <= $rules:FGASES_ROUNDING_TOLERANCE
      else
        $recycling + $reclamation + $destruction = 0
     :)
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

    let $rules := rules:getRules($rules:FGASES_COMMON_ID)

    let $class := if ($sourceDocAvailable) then  xmlutil:getMostCriticalErrorClass($rules, $results) else ()
    let $errorText :=  if ($sourceDocAvailable) then  xmlutil:getErrorText($class) else ""

    let $resultErrors :=  if ($sourceDocAvailable) then  uiutil:getResultErrors($results) else ()
    let $hasOnlyStatusError := count($resultErrors) = 1 and $resultErrors/@subErrorCodes=$rules:COMPLETNESS_WRONGSTATUS_SUBID

    return
        if ($sourceDocAvailable) then
            uiutil:buildScriptResult($results, $class, $errorText, $rules, true(), $xmlconv:jscript, $hasOnlyStatusError, $xmlconv:cssStyle)
        else
            uiutil:buildDocNotAvailableError($source_url)
};


declare function xmlconv:validateSubstanceHeaderColumns($gases as element(Gas)*, $tableName as xs:string)
as element(th)* {
    for $gas in $gases
        return
            <th align="left">&#32;{xmlconv:validateGas($gas,$tableName)}</th>
};

(: Blend consistency and existance validation :)
declare function xmlconv:validateGas($gas as element(Gas), $tableName as xs:string)
as element(div) {
    let $contentsOk := xmlutil:isValidBlend($gas)
    let $subRuleCodes := if ($contentsOk) then () else $rules:CONSISTENCY_BLENDCONTENTS_SUBID

    let $newBlendOk := xmlutil:isNotExistingBlend($gas)
    let $subRuleCodes := if ($newBlendOk) then $subRuleCodes else insert-before($subRuleCodes, count($subRuleCodes)+1, $rules:CONSISTENCY_BLENDEXISTING_SUBID)

    let $errDef := if ($contentsOk and $newBlendOk) then () else rules:getRulesByCode($rules:FGASES_ERROR_ID)

    return
        uiutil:buildResultElement($gas/Code, $errDef,$subRuleCodes,$tableName)
};

declare function xmlconv:getGasesWithStockQuantity($transactionYear as xs:integer, $companyId as xs:string)
as xs:string* {

    let $lastYear := $transactionYear - 1
    let $doc := xmlutil:getSecureUrl($source_url, $xmlutil:FGASES_STOCKS_DOC)

    let $gases :=
        data($doc//stocks[Company_No=$companyId and Transaction_year = $lastYear and xs:decimal(Value_t) gt 0]/Gas)

(:
    let $positiveQuantities :=
    if (not(empty($stocks))) then
        $stocks/StockQuantities[@gasGroup = $gasGroup]/StockQuantity[xs:decimal(.) gt 0]
    else
        ()
    for $q in $positiveQuantities
      return data($q/@gasId)
:)
    return $gases
};

declare function xmlconv:test() {
let $a := ('a', 'b')
        (:
        let $name := "õõääõõüü"
        let $name := "öö 6"
        return matches($name, '[À-ÿ]') or matches(lower-case($name), '[a-z]')
let $x := $xmlutil:preDefinedBlends
return $x[3]
        :)



    return xmlconv:getGasesWithStockQuantity(2012,"test-fgas-1")
};

xmlconv:proceed( $source_url )
(:
xmlconv:test()
:)

