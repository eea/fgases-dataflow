
(: saxon specific directive 
declare option saxon:output "method=html";
:)
declare variable $source-quotas-9a-reg external;
declare variable $source-quotas-9g external;

declare function local:combine()
{
    let $quotas9aReg := doc($source-quotas-9a-reg)/QuotasRoot
    let $quotas9g := doc($source-quotas-9g)/QuotasRoot
    
    let $part1 :=
        for $item in $quotas9aReg/Quotas
        let $match := $quotas9g/Quotas[CompanyID = string($item/CompanyID)]
        let $availableQuota := if (empty($match)) then "0" else string($match/Quota)
        return 
            local:create-quotas-element(string($item/CompanyID), string($item/Quota), $availableQuota)
        
    let $part2 :=
        for $item in $quotas9g/Quotas
        let $match := $quotas9aReg/Quotas[CompanyID = string($item/CompanyID)]
        return
            if (empty($match)) then
                local:create-quotas-element(string($item/CompanyID), "0", string($item/Quota))
            else
                ()
    
    return
        <QuotasRoot>
            { $part1 }
            { $part2 }
        </QuotasRoot>
};

declare function local:create-quotas-element($companyId as xs:string, $allocatedQuota as xs:string, $availableQuota as xs:string)
as element(Quotas)
{
    <Quotas>
        <TransactionYear>{ fn:year-from-date(fn:current-date()) - 1 }</TransactionYear>
        <CompanyID>{ $companyId }</CompanyID>
        <AllocatedQuota>{ $allocatedQuota }</AllocatedQuota>
        <AvailableQuota>{ $availableQuota }</AvailableQuota>
    </Quotas>
};

local:combine()