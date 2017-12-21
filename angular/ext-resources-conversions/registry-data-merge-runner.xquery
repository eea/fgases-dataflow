xquery version "1.0" encoding "UTF-8";

import module namespace regdm = 'http://eionet.europa.eu/dataflows/fgases/conversions/registryDataMerger' at './registry-data-merger.xquery';

(: declare option saxon:output "method=html"; :)

declare variable $stocksDataUri as xs:string external;
declare variable $quotaAuthDataUri as xs:string external;
declare variable $quota09A_impDataUri as xs:string external;
declare variable $largeCompaniesListDataUri as xs:string external;
declare variable $nerListDataUri as xs:string external;

regdm:merge-registry-data(
    $stocksDataUri,
    $quotaAuthDataUri,
    $quota09A_impDataUri,
    $largeCompaniesListDataUri,
    $nerListDataUri
)
