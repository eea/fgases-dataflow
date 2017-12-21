xquery version "1.0" encoding "UTF-8";
(:
 : Module Name: Ozone Depleting Substances - Utility methods (Library module)
 :
 : Version:     $Id: fgases-util-2012.xquery 17234 2014-11-26 17:41:45Z kasperen $
 : Created:     15 October 2012
 : Copyright:   European Environment Agency
 :)
(:~
 : Common utility methods used by F-Gases (2012) scripts.
 : Reporting Obligation: http://rod.eionet.europa.eu/obligations/669
 :
 : This module contains common business rule implementations for all reports.
 :
 : @author Kaido Laine
 :)
module namespace xmlutil = "http://converters.eionet.europa.eu/fgases/xmlutil";

import module namespace cutil = "http://converters.eionet.europa.eu/fgases/cutil" at "fgases-common-util.xquery";

(: UI utility methods for build HTML formatted QA result:)
import module namespace uiutil = "http://converters.eionet.europa.eu/fgases/ui" at "fgases-ui-util.xquery";
(: Dataset rule definitions and utility methods:)
import module namespace rules = "http://converters.eionet.europa.eu/fgases/rules" at "fgases-rules-2012.xquery";

declare namespace sparql = "http://www.w3.org/2005/sparql-results#";
(:~ Constant used for invalid numeric values. :)
declare variable $xmlutil:ERR_NUMBER_VALUE as xs:integer :=  -99999;
(:~ declare Content Registry SPARQL endpoint:)
declare variable $xmlutil:CR_SPARQL_URL := "http://cr.eionet.europa.eu/sparql";

declare variable $xmlutil:EMPTY_DISPLAY_VALUE := "-empty-";
(:~ XML file folder path or url  :)
(:
declare variable $xmlutil:XML_PATH as xs:string := "../xml/";
:)
declare variable $xmlutil:XML_PATH as xs:string := "http://converters.eionet.europa.eu/xmlfile/";

declare variable $xmlutil:XML_PATH_PROD as xs:string := "https://bdr.eionet.europa.eu/xmlexports/fgases/";

declare variable $xmlutil:IS_PROD := fn:doc-available("bdr-production.xml");

declare variable $xmlutil:FGASES_LABELS_DOC := 'fgases-labels.xml';

declare variable $xmlutil:FGASES_GASES_DOC := 'fgases-gases.xml';

declare variable $xmlutil:FGASES_STOCKS_DOC := 'fgases-stocks.xml';

(:
declare variable $xmlutil:stocksDoc  :=
     fn:doc(concat("http://localhost:8080/xml/", $xmlutil:FGASES_STOCKS_DOC));
:)
declare variable $xmlutil:stocksDoc  :=
     fn:doc(concat($xmlutil:XML_PATH, $xmlutil:FGASES_STOCKS_DOC));


declare variable $xmlutil:LabelsDoc as element(label)* :=
     fn:doc(concat($xmlutil:XML_PATH, $xmlutil:FGASES_LABELS_DOC))//labels/labelSet[@xml:lang='en']/label;
(:
declare variable $xmlutil:BlendsDoc  :=
     "http://converterstest.eionet.europa.eu/xmlfile/fgases-gases.xml";
:)

declare variable $xmlutil:preDefinedBlends   :=
for $blend in fn:doc(concat($xmlutil:XML_PATH, $xmlutil:FGASES_GASES_DOC))//FGases/Gas[IsBlend='True']
        return
        string-join(
           for $component in $blend/BlendComponents/Component order by $component/Code
                return concat($component/Code,':', $component/Percentage)
                , ';')
;

declare function xmlutil:getSecureUrl($source_url as xs:string, $xmlFileName as xs:string){

    if ($xmlutil:IS_PROD) then
        fn:doc(cutil:replaceSourceUrl($source_url, concat($xmlutil:XML_PATH_PROD, $xmlFileName)))
    else
        fn:doc(concat($xmlutil:XML_PATH, $xmlFileName))

};

(:
 : ======================================================================
 :              SPARQL HELPER methods
 : ======================================================================
 :)
(:~ Function executes given SPARQL query and returns result elements in SPARQL result format.
 : URL parameters will be correctly encoded.
 : @param $sparql SPARQL query.
 : @return Zero or more result elements in SPARQL result format.
 :)
declare function xmlutil:executeSparqlQuery($sparql as xs:string)
as element(sparql:result)*
{
    let $uri := xmlutil:getSparqlEndpointUrl($sparql, "xml", fn:false())

    return
        fn:doc($uri)/sparql:sparql/sparql:results//sparql:result
};
(:~
 : Get the SPARQL endpoint URL.
 : @param $sparql SPARQL query.
 : @param $format SPARQL query.
 : @param $inference SPARQL query.
 : @return link to sparql endpoint
 :)
declare function xmlutil:getSparqlEndpointUrl($sparql as xs:string, $format as xs:string, $inference as xs:boolean)
as xs:string
{
    let $sparql := fn:encode-for-uri(fn:normalize-space($sparql))
    let $resultFormat :=
        if ($format = "xml") then
            "application/sparql-results+xml"
        else if ($format = "html") then
            "text/html"
        else
            $format
    let $useInferencing := if ($inference) then "&amp;useInferencing=true" else ""
    let $defaultGraph := "&amp;default_graph=http://rdfdata.eionet.europa.eu/noisedataflow/data_dump.rdf"
    let $uriParams := concat("format=", fn:encode-for-uri($resultFormat), $defaultGraph, "&amp;query=", $sparql, $useInferencing)
    let $uri := concat($xmlutil:CR_SPARQL_URL, "?", $uriParams)
    return $uri
};
(:~ Create SPARQL query for querying data defined in DD format.
 : If there are more than one DD table in query, then UNION statement is created.
 : @param $countryCode Country Code filter.
 : @param $tableIds List of table IDs.
 : @param $tableNames List of table identificators.
 : @param $fieldNames List of field names returned by the query.
 : @param $xmlFieldNames List of XML element names mapped to $fieldNames. Optional. If empty, then $fieldNames is used in where expression.
 : @param $includeSubject Show subject in query results.
 :)
declare function xmlutil:getCrSparqlQuery($countryCode as xs:string, $tableIds as xs:string*,
    $tableNames as xs:string*, $fieldNames as xs:string*, $includeSubject as xs:boolean,
    $xmlFieldNames as xs:string*)
as xs:string
{
    let $sparqlPrefixes := "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                    PREFIX cr: <http://cr.eionet.europa.eu/ontologies/contreg.rdf#>
                    PREFIX rod: <http://rod.eionet.europa.eu/schema.rdf#>
                    PREFIX noise: <http://rdfdata.eionet.europa.eu/noisedataflow/ontology/> "
    let $sparqlSelect :=  fn:concat("SELECT DISTINCT ", if ($includeSubject) then "?subject, " else "", "?", fn:string-join($fieldNames, ", ?"))
    let $sparqlWhereStart := " WHERE  "
    let $sparqlWhereBody := fn:string-join(xmlutil:getSparqlWhere($tableIds, $tableNames, $fieldNames, $xmlFieldNames), " ")
    let $sparqlWhereEnd := ""
    let $sparqlOrderBy := fn:concat("order by ?", if ($includeSubject) then "subject " else $fieldNames[1])
    let $sparql := fn:concat($sparqlPrefixes, $sparqlSelect,$sparqlWhereStart, $sparqlWhereBody, $sparqlWhereEnd, $sparqlOrderBy)

    return $sparql
};
declare function xmlutil:getSparqlWhere($tableIds as xs:string*, $tableNames as xs:string*,
    $fieldNames as xs:string*, $xmlFieldNames as xs:string*)
as xs:string*{
    for $tableId at $pos in $tableIds
    let $union := if ($pos > 1) then " UNION " else ""
    let $start := if (count($tableIds) > 1 and $pos = 1) then "{ " else " "
    let $end := if (count($tableIds) > 1 and $pos = count($tableIds)) then "}" else " "
    let $xmlFieldNamesList := if (fn:count($xmlFieldNames) = 0 or fn:count($xmlFieldNames) < $pos) then
            $fieldNames
        else
            fn:tokenize($xmlFieldNames[$pos], $cutil:LIST_ITEM_SEP)
    return
        fn:concat($union, $start, "{",
               "?subject rdf:type noise:", $tableId, " . ",
                fn:string-join(xmlutil:getSparqlFields($tableId, $fieldNames, $xmlFieldNamesList), " "),
                "}", $end)
};
(:~
 : Create sparql query expression which contains DD table element names used in SPARQL query WHERE statement.
 : @param $tableId DD table ID, used in namespace.
 : @param $fieldNames List of field names used in sparql query WHERE ?s ?p ?o statement.
 : @param $xmlFieldNames List of XML element names mapped to $fieldNames. Optional. If empty, then $fieldNames is used.
 : @return List ""?s ?p ?o ." statements.
 :)
declare function xmlutil:getSparqlFields($tableId as xs:string, $fieldNames as xs:string*, $xmlFieldNames as xs:string*)
as xs:string*
{
    for $fieldName at $pos in $fieldNames
    let $xmlFieldName := if (fn:count($xmlFieldNames) = 0 or fn:count($xmlFieldNames) < $pos) then $fieldName else $xmlFieldNames[$pos]
    return
            fn:concat("OPTIONAL {?subject noise:", $xmlFieldName, " ?", $fieldName, "} . ")
};

(:
 : ======================================================================
 :                 ART17       QA rules related HELPER methods
 : ======================================================================
 :)


(: Returns checklist file URL from envelope :)
declare function xmlutil:getEnvelopeCountryCode($url as xs:string)
as xs:string
{
    let $envelopeXmlUrl := cutil:getEnvelopeXML($url)
    return
        if ($envelopeXmlUrl != "") then
            let $country := fn:doc($envelopeXmlUrl)//countrycode
            return
                    $country
        else
             ""
}
;



(: compares child element values that do not have  children :)
(: returns string :)
declare function xmlutil:compareChildNodes($elem as element()?, $other as element()?, $ignoredElements as xs:string*)
as xs:string* {
    if (normalize-space($elem) != normalize-space($other)) then
    for $child in $elem/node()[empty(index-of($ignoredElements, ./name()))]
      let $nodeName := $child/name()
      let $otherNode := $other//*[name() = $nodeName]
        (:if ( not(cutil:isMissingOrEmpty($child/code)) ) then  $other//*[name() = $nodeName and code=$child/code] else :)
      let $result :=
           let $thisValue := if ( not(cutil:isMissingOrEmpty($child)) ) then normalize-space($child) else ""
           let $otherNodeValue := if ( not(cutil:isMissingOrEmpty($otherNode))  ) then normalize-space($otherNode[1]) else ""
           where ($nodeName != "" and count($child/child::*)=0  )
           return
            if ($thisValue != $otherNodeValue) then
               concat($nodeName, " value has been changed from '", $thisValue, "' to '", $otherNodeValue, "';")
            else
                ""

        return $result
    else
         ""
};
declare function xmlutil:getMostPopularValue($node as node()*, $defaultValue as xs:string)
as xs:string
{
    let $values :=
        for $value in distinct-values($node)
        let $valueCount := count($node[. = $value])
        order by $valueCount descending
        return
            $value
    let $result := if (count( $values)>0) then $values[1] else $defaultValue

    return
        $result
};

(:
: Builds a string of selected boolean element names of the node
: Example: for node "VAlues" below "Good, Long" is returned
: <Values>
:     <Good>true</Good>
:     <Bad>false</Bad>
:     <Medium>false</Medium>
:     <Long>true</Long>
:     <Short>false</Short>
: </Values>
:)
declare function xmlutil:buildSelectedElemNames($node as node(), $attrName as xs:string)
as xs:string
{
    let $names :=
    for $elem in $node/child::*
    where lower-case($elem/text()) = 'true'
        return
            concat($elem/@*[name()=$attrName], " ", $elem/name())

     return string-join($names, ", ")
};

(:
: Number has to be empty or csatable as decimal
:)
declare function xmlutil:isNumber($value as xs:string?)
as xs:boolean {
    if (cutil:isEmpty($value) or $value castable as xs:decimal) then
        fn:true()
    else
        fn:false()
};

(:
:    cannot have more than 3 decimals
:)
declare function xmlutil:hasCorrectDecimals($value as xs:string?)
as xs:boolean {

    let $value := replace($value, ",", ".")

    let $decimalsCount :=
    if (contains($value,".")) then
        string-length(substring-after($value, "."))
    else 0

    return
    if (cutil:isEmpty($value) or not($value castable as xs:decimal) or $decimalsCount <= 3) then
        fn:true()
    else
        fn:false()
};


declare function xmlutil:isPositiveNumber($value as xs:string?)
as xs:boolean {
    if (cutil:isEmpty($value) or ($value castable as xs:decimal and xs:decimal($value) >= 0)) then
        fn:true()
    else
        fn:false()
};

(:
declare function xmlutil:checkSubject($subjectNode as node(), $errDefs as element(rule)*, $tableNo as xs:string)
as element(div) {

  let $subjectLabel := xmlutil:getLabel(concat('p', $tableNo, '-',data($subjectNode/@usetype)),data($subjectNode/@usetype))
  let $dispValue := concat($subjectLabel, if(normalize-space($subjectNode/text()) != '' and $subjectNode/text() != $subjectLabel ) then
    concat(" (", $subjectNode/text(), ")") else "")

  let $hasError := ((lower-case($subjectNode/@usetype) = 'other' or lower-case($subjectNode/@usetype) = 'to eu re-packagers' or lower-case($subjectNode/@usetype) = 'to ods producers')
    and normalize-space($subjectNode/text()) = '' )
  return
    uiutil:buildResultElement($dispValue, if($hasError) then $errDefs else ())

};
:)

declare function xmlutil:valueExistsInCodelist($codeListUrl as xs:string, $elemName as xs:string, $value as xs:string)
as xs:boolean
{
    (: FIXME :)
    let $validCodes := if (doc-available($codeListUrl)) then data(doc($codeListUrl)//*[name() = $elemName]/@code) else ()

    let $lowerCaseCodes := for $code in $validCodes
        return lower-case($code)

    let $isValid := if (count($validCodes ) > 0) then  not(empty(index-of($lowerCaseCodes, lower-case($value)))) else fn:true()
    return
        $isValid
};


declare function xmlutil:getLabel($id as xs:string, $defaultValue as xs:string)
as xs:string {

    let $label :=
        $xmlutil:LabelsDoc[@id=$id]

    return
    if (cutil:isMissingOrEmpty($label)) then
        $defaultValue
    else
        $label/text()


};


declare function xmlutil:getDateText($date as xs:string)
as xs:string {
    if (ends-with($date, '01-01')) then
        'At 01 January '
    else if (ends-with($date, '12-31')) then
        'At 31 December '
    else
        $date
};


declare function xmlutil:getMostCriticalErrorClass($rules as element(rules)?, $ruleResults as element()?)
as xs:string {
   let $blockerErrorCount :=
   for $rule in $rules/group/rule[error_level='0']
      let $resultCount := count($ruleResults//*[@errorCode=$rule/@code])

      return
         $resultCount > 0

   let $hasBlockerErrors := xmlutil:resultHasErrorForLevel($rules, $ruleResults, '0')

   return
      if ($hasBlockerErrors) then
          "BLOCKER"
      else
        if (xmlutil:resultHasErrorForLevel($rules, $ruleResults, '1')) then
            "WARNING"
        else
            "INFO"
};


declare function xmlutil:resultHasErrorForLevel($rules as element(rules), $ruleResults as element(), $errLevel as xs:string)
as xs:boolean {

   let $errorCount :=
   for $rule in $rules/group/rule[error_level=$errLevel]
      let $resultCount := count($ruleResults//*[@errorCode=$rule/@code])

      return
         $resultCount > 0

   return
    not(empty(index-of($errorCount, fn:true())))

};

declare function xmlutil:getErrorText($class as xs:string) as xs:string {
    if ($class = "BLOCKER") then
        "The delivery is not acceptable. Please see the QA output."
    else if ($class = "WARNING") then
        "The delivery is acceptable but some of the information has to be checked. Please see the QA output."
    else if ($class = "INFO") then
        "The delivery is acceptable."
    else
        "The delivery status is unknown."
};



declare function xmlutil:getZeroIfNotNumber($value as xs:string?)
as xs:decimal {
    if ($value castable as xs:decimal) then xs:decimal($value) else 0
};


declare function xmlutil:getTransactionLabel($defsXml as element(Labels), $gasGroupId as xs:string, $transElemName as xs:string)
as xs:string {

    let $gasGroup := $defsXml

    (:
    [@id=$gasGroupId]
    :)

    let $transactionDef :=
        $gasGroup/Transaction[@name=$transElemName]

    return
    if (not(empty($transactionDef))) then
        xmlutil:getLabel(data($transactionDef/@labelId),$transElemName)
    else
        $transElemName

};


declare function xmlutil:isNegativeAllowed($defsXml as element(Labels), $gasGroupId as xs:string, $transElemName as xs:string)
as xs:boolean {

    let $gasGroup := $defsXml

    let $transactionDef :=
        $gasGroup/Transaction[@name=$transElemName]

    return
    if (not(empty($transactionDef))) then
        data($transactionDef/@allowNegative) = "true"
    else
        fn:true()

};


declare function xmlutil:isValidCompanyName($name as xs:string)
as xs:boolean {
    string-length($name) gt 1 and (matches($name, '[À-ÿ]') or matches(lower-case($name), '[a-z]'))
};

(:
: checks if sum of self-added components  is 100%
:)

declare function xmlutil:isValidBlend($gas as element(Gas))
as xs:boolean {
    (string($gas/IsBlend) = 'false' or string-length($gas/IsBlend) = 0)
    or
     (string($gas/IsBlend) = 'true' and (string($gas/IsNew) = 'false' or sum($gas/BlendComponents/Component/Percentage[. castable as xs:decimal]) = 100))
    (:

   let $b := string($blend/IsNew) = 'false'
    return $b
    :)
};


(:
: checks if such composition does not exist in the lookup
:)

declare function xmlutil:isNotExistingBlend($blend as element(Gas))
as xs:boolean {

let $isSelfDefined := string($blend/IsNew) = 'true'

(: Blends in predifned string are in format:   GasCode1:Percentage1;GasCode2:Percentage2; ... ;GasCodeN:PercentageN :)
let $blendStr :=
if ($isSelfDefined) then
string-join(
for $component in $blend/BlendComponents/Component order by $component/Code
    return concat($component/Code, ":", $component/Percentage)
    , ";")

else
    ""
return
    not($isSelfDefined) or empty(index-of($xmlutil:preDefinedBlends, $blendStr))
};


declare function xmlutil:getPrevYearStock($source_url as xs:string, $lastYear as xs:string, $gasCode as xs:string, $companyId as xs:string) {

    let $doc := xmlutil:getSecureUrl($source_url, $xmlutil:FGASES_STOCKS_DOC)

    return
        xmlutil:getZeroIfNotNumber($doc//stocks[Company_No=$companyId and Gas=$gasCode and Transaction_year=$lastYear]/Value_t)

};


