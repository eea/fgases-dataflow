xquery version "1.0" encoding "UTF-8";

module namespace regdm = 'http://eionet.europa.eu/dataflows/fgases/conversions/registryDataMerger';

declare function regdm:merge-registry-data(
    $stocksDataUri as xs:string,
    $quotaAuthDataUri as xs:string,
    $quota09A_impDataUri as xs:string,
    $largeCompaniesListDataUri as xs:string,
    $nerListDataUri as xs:string
) as element(dataRoot)
{
    regdm:merge-registry-data-core(
        doc($stocksDataUri)/*, 
        doc($quotaAuthDataUri)/*, 
        doc($quota09A_impDataUri)/*, 
        doc($largeCompaniesListDataUri)/*, 
        doc($nerListDataUri)/*
    ) 
}; 

declare function regdm:merge-registry-data-core(
    $stocksData as element(),
    $quotaAuthData as element(),
    $quota09A_impData as element(),
    $largeCompaniesListData as element(),
    $nerListData as element()
) as element(dataRoot)
{
    let $companyIds := distinct-values((
        $stocksData/*/xs:integer(./portal_code), 
        $quotaAuthData/*/xs:integer(./CompanyID),
        $quota09A_impData/*/xs:integer(./@companyId),
        $largeCompaniesListData/*/xs:integer(./CompanyID),
        $nerListData/*/xs:integer(./CompanyID)
    ))
    return
        <dataRoot>
        {
            for $companyId in $companyIds
            order by $companyId
            return
                <registryData companyId="{ $companyId }">
                    <stocks>
                    {
                        for $srcStock in $stocksData/*[portal_code = $companyId]
                        return
                            <stock>
                                <transactionCode>{ string($srcStock/transaction_code) }</transactionCode>
                                <gasId>{ xs:integer($srcStock/gas_id) }</gasId>
                                <gasName>{ string($srcStock/gas_name_IA) }</gasName>
                                <amount>{ xs:decimal($srcStock/amount_mix) }</amount>
                            </stock>
                    }
                    </stocks>
                    <quota>
                    {
                        let $srcQuota := $quotaAuthData/*[CompanyID = $companyId]
                        return (
                            <allocatedQuota>{ $srcQuota/xs:decimal(./AllocatedQuota) }</allocatedQuota>,
                            <availableQuota>{ $srcQuota/xs:decimal(./AvailableQuota) }</availableQuota>,
                            <allocatedQuotaDate>{ $srcQuota/xs:string(./allocatedQuotaDate) }</allocatedQuotaDate>,
                            <availableQuotaDate>{ $srcQuota/xs:string(./availableQuotaDate) }</availableQuotaDate>
                        )
                    }
                    {
                        for $srcQuota9_imp in $quota09A_impData/Quota[@companyId = $companyId]
                        return
                            <quota9A_imp>
                                <tradePartner>{ $srcQuota9_imp/TradePartner/* }</tradePartner>
                                <amount>{ $srcQuota9_imp/xs:decimal(./Amount) }</amount>
                            </quota9A_imp>
                    }
                    </quota>
                    <large>{ not(empty($largeCompaniesListData/Company[CompanyID = $companyId])) }</large>
                    <ner>{ not(empty($nerListData/Company[CompanyID = $companyId])) }</ner>
                </registryData>
        }
        </dataRoot>
};
