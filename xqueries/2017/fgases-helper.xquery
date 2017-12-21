xquery version "1.0" encoding "UTF-8";

module namespace fgases = 'http://converters.eionet.europa.eu/fgases/helper';

import module namespace cutil = "http://converters.eionet.europa.eu/fgases/cutil" at "fgases-common-util-2015.xquery";

declare variable $fgases:gas-list := doc('../angular/xml/fgases-gases-2015.xml');

declare function fgases:get-gas-by-id($gasId as xs:string)
as element(Gas)
{
    if ($fgases:gas-list/FGases/Gas[GasId = $gasId] ) then
        ($fgases:gas-list/FGases/Gas[GasId = $gasId] )
    else
        <Gas>
            <Code> { $gasId }</Code>
            <Name> { $gasId }</Name>
        </Gas>
};

declare function fgases:get-gas-by-id-or-name($gasId as xs:string, $name as xs:string )
as element(Gas)
{
    if ($fgases:gas-list/FGases/Gas[GasId = $gasId] ) then
        ($fgases:gas-list/FGases/Gas[GasId = $gasId] )
    else
        <Gas>
            <Code>{ $gasId }</Code>
            <Name>{ $name }</Name>
        </Gas>
};

declare function fgases:get-transaction-year($report as element(FGasesReporting))
as xs:integer
{
    let $yearFromReport := string($report/GeneralReportData/TransactionYear)
    return
        if ($yearFromReport castable as xs:integer) then
            xs:integer($yearFromReport)
        else
            year-from-date(current-date())
};

declare function fgases:get-reported-gas-by-id($report as element(FGasesReporting), $gasId as xs:string)
as element(ReportedGases)?
{
    let $matchingGases := $report/ReportedGases[GasId = $gasId]
    return if (empty($matchingGases)) then () else $matchingGases[1]
};

declare function fgases:get-gas-amounts($section, $transaction as xs:string)
as element(fgases:gasAmount)*
{
    for $transactionAmount in $section/Gas/*[local-name(.) = $transaction]
    let $gasId := string($transactionAmount/../GasCode)
    let $amount := string($transactionAmount/Amount)
    let $comment := string($transactionAmount/Comment)
    return fgases:_create-gas-amount($gasId, $amount, $comment)
};

declare function fgases:get-gas-amounts-with-values($section as element(), $transaction as xs:string)
as element(fgases:gasAmount)*
{
    for $gasAmount in fgases:get-gas-amounts($section, $transaction)
    let $value := fgases:get-amount-of-gas-amount($gasAmount)
    where not(empty($value)) and $value != 0
    return $gasAmount
};

declare function fgases:get-gas-stock-by-transaction($report as element(FGasesReporting), $gasId as xs:string, $transactionCode as xs:string)
as element(stock)?
{
    $report/attachedCompanyData/stocks/stock[gasId = $gasId and transactionCode = $transactionCode]
};

declare function fgases:get-gas-id-of-gas-amount($gasAmount as element(fgases:gasAmount))
as xs:string
{
    string($gasAmount/gasId)
};

declare function fgases:get-amount-of-gas-amount($gasAmount as element(fgases:gasAmount))
as xs:decimal?
{
    xs:decimal($gasAmount/amount)
};

declare function fgases:has-comment-of-gas-amount($gasAmount as element(fgases:gasAmount))
as xs:boolean
{
    not(empty($gasAmount/comment))
};

declare function fgases:_create-gas-amount($gasId as xs:string, $amount as xs:string, $comment as xs:string)
as element(fgases:gasAmount)
{
    <fgases:gasAmount>
        <gasId>{ $gasId }</gasId>
        { if ($amount castable as xs:decimal) then <amount>{ xs:decimal($amount) }</amount> else () }
        {
            let $trimmed := normalize-space($comment)
            return if ($trimmed = "") then () else <comment>{ $trimmed }</comment>
        }
    </fgases:gasAmount>
};

declare function fgases:get-own-tradepartner-id($report, $company as element(Company), $partners as element(Partner)*)
as xs:string?
{
    let $id :=
        for $partner in $partners
        where cutil:isOnwCompany($company, $partner)
        return $partner/PartnerId
    return if(empty($id)) then () else xs:string($id[1])
};

declare function fgases:is-blend($reportedGas as element()?) as xs:boolean
{
    if(empty($reportedGas)) then
        false()
    else
        $reportedGas/isBlend = 'true'
};

declare function fgases:is-unspecified-mix($reportedGas as element()?)
as xs:boolean
{
    (: Gases with ID 187 are considered unspecified mixes :)
    let $unspecifiedGasMixId := 187
    return
        if(empty($reportedGas) or not($reportedGas/GasId castable as xs:double)) then
            false()
        else
            xs:double($reportedGas/GasId) = $unspecifiedGasMixId
};

declare function fgases:contains-HFC($componentOrGas as element()?)
as xs:boolean
{
    let $gasContainsHFC :=
        not(empty($componentOrGas)) and $componentOrGas/GWP_AR4_HFC castable as xs:double and xs:double($componentOrGas/GWP_AR4_HFC) > 0
    return
        if($gasContainsHFC or fgases:is-unspecified-mix($componentOrGas)) then
            true()
        else
            false()
};

declare function fgases:sum-of-gas-for-transaction($data as element()?, $transaction as xs:string)
as xs:double {
    let $amounts := fgases:get-gas-amounts-with-values($data, $transaction)
    let $total := for $item in $amounts return cutil:numberIfEmpty($item/amount, 0)
    return sum($total)

};

declare function fgases:get-gas-amount-sum-of-tradepartner($tradePartnerTransaction, $tradeParnterId as xs:string?)
as xs:double
{
    if(empty($tradeParnterId)) then
        0
    else
        let $total := for $item in  $tradePartnerTransaction/TradePartner[TradePartnerID=$tradeParnterId] return $item/amount
        let $sum := sum($total)
        return cutil:numberIfEmpty($sum, 0)
};

declare function fgases:is-section-4-applicable-gas($report, $reportedGas as element(ReportedGases))
as xs:boolean
{
    fgases:is-I($report) or fgases:is-P($report) or not(fgases:contains-HFC($reportedGas))
};

declare function fgases:is-P($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/P = 'true'
};

declare function fgases:is-P-HFC($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/P-HFC = 'true'
};

declare function fgases:is-P-other($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/P-other = 'true'
};

declare function fgases:is-I($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/I = 'true'
};

declare function fgases:is-I-HFC($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/I-HFC = 'true'
};


declare function fgases:is-I-other($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/I-other = 'true'
};


declare function fgases:is-E($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/E = 'true'
};

declare function fgases:is-FU($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/FU = 'true'
};


declare function fgases:is-D($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/D = 'true'
};


declare function fgases:is-Eq-I($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/Eq-I = 'true'
};


declare function fgases:is-Eq-I-RACHP-HFC($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/Eq-I-RACHP-HFC = 'true'
};


declare function fgases:is-Eq-I-other($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/Eq-I-other = 'true'
};



declare function fgases:is-auth($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/auth = 'true'
};



declare function fgases:is-auth-NER($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/auth-NER = 'true'
};

declare function fgases:is-NIL-Report($report as element(FGasesReporting))
as xs:boolean
{
    $report/GeneralReportData/Activities/NIL-Report = 'true'
};

declare function fgases:get-gas-amounts-of-trade-partner($transaction, $tradePartnerId as xs:string)
as element(fgases:gasAmount)*
{

    for $item in $transaction
        let $gasId := string($item/../GasCode)
        let $amountObject :=
            for $tradepartner in $transaction/TradePartner
                let $amount := string($tradepartner/amount)
                let $comment := string($tradepartner/comment)
            where $tradepartner/TradePartnerID=$tradePartnerId and fn:string-length($amount) > 0
            return
                fgases:_create-gas-amount($gasId, $amount, $comment)
    return $amountObject
};

declare function fgases:sum-gas-amounts-of-non-HFC-gases($report, $section as element()?, $transaction as xs:string)
as xs:double
{
    let $amounts := fgases:get-gas-amounts($transaction, $transaction)
    let $total :=
        for $item in $amounts
            let $gasId := $item/gasId
            let $reportedGas := fgases:get-reported-gas-by-id($report, $gasId)
        where not(fgases:contains-HFC($reportedGas))
        return cutil:numberIfEmpty($item/amount, 0)
    return sum($total)
};