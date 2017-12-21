# Registry data merger

## Introduction

There is a handful of company related data essential to each year's reporting, which are considered "registry data", however they do not derive from the BDR Fgases registry. Instead, this data is extracted each year from the FDB and are as follows:
- Gas stocks for section 4
- Aggregated authorization quota:
    -  allocated (9_registry)
    -  available (9G)
- Disaggregated authorization quota (9_imp)
- Company size (large or not)
- NER status

This data was typically exported into multiple files, specifically one file per data category (i.e. 1 file for stocks, quota etc). However, as per 2017 reporting round, it was decided to merge the data into a single file/format.

The purpose of the registry data merger script is to merge the separate files discussed above into a single convenient file, abiding by the format expected by the FGases webform.

## Expected input

The execution parameters of the script are the following:
- **$stocksDataUri**: The URI of the file containing gas stocks data
- **$quotaAuthDataUri**: The URI of the file containing the aggregated authorization quota
- **$quota09A_impDataUri**: The URI of the file containing the disaggregated authorization quota
- **$largeCompaniesListDataUri**: The URI of the file containing the list of large companies
- **$nerListDataUri**: The URI of the file containing the list of companies with a NER status

The data in each of these files must be related to a **SINGLE** year. The merger does not take into account year info, thus mixed year data is not acceptable.

### Expected input formats

**Gas stocks**
```xml
<dataroot>
    <qry_aggregation_stocks_anonymous>
        <portal_code>1111</portal_code>
        <transaction_code>4F</transaction_code>
        <gas_id>2</gas_id>
        <gas_name_IA>HFC-23</gas_name_IA>
        <amount_mix>1.91</amount_mix>
    </qry_aggregation_stocks_anonymous>
    <qry_aggregation_stocks_anonymous>
        <portal_code>1111</portal_code>
        <transaction_code>4G</transaction_code>
        <gas_id>2</gas_id>
        <gas_name_IA>HFC-23</gas_name_IA>
        <amount_mix>2.93</amount_mix>
    </qry_aggregation_stocks_anonymous>
    <qry_aggregation_stocks_anonymous>
        <portal_code>1112</portal_code>
        <transaction_code>4F</transaction_code>
        <gas_id>2</gas_id>
        <gas_name_IA>HFC-23</gas_name_IA>
        <amount_mix>0.605</amount_mix>
    </qry_aggregation_stocks_anonymous>
    <!-- more qry_aggregation_stocks_anonymous elements -->
</dataroot>
```

**Aggregated authorization quota**
```xml
<QuotasRoot>
   <Quotas>
      <CompanyID>1111</CompanyID>
      <AllocatedQuota>1292000</AllocatedQuota>
      <AvailableQuota>27016800</AvailableQuota>
      <allocatedQuotaDate>2016-12-30</allocatedQuotaDate>
      <availableQuotaDate>2016-12-30</availableQuotaDate>
   </Quotas>
   <Quotas>
      <CompanyID>1112</CompanyID>
      <AllocatedQuota>65004</AllocatedQuota>
      <AvailableQuota>65004</AvailableQuota>
      <allocatedQuotaDate>2016-12-30</allocatedQuotaDate>
      <availableQuotaDate>2016-12-30</availableQuotaDate>
   </Quotas>
   <Quotas>
      <CompanyID>1113</CompanyID>
      <AllocatedQuota>165004</AllocatedQuota>
      <AvailableQuota>195004</AvailableQuota> 
      <allocatedQuotaDate>2016-12-30</allocatedQuotaDate>
      <availableQuotaDate>2016-12-30</availableQuotaDate>
   </Quotas>
</QuotasRoot>
```

**Disaggregated authorization quota**

```xml
<QuotaRoot>
   <Quota companyId="1111"> <!-- Quota with EU based trade partner -->
      <TradePartner>
         <CompanyName>EU Company 1</CompanyName>
         <EUVAT>eu-1</EUVAT>
      </TradePartner>
      <Amount>25000</Amount>
   </Quota>
   <Quota companyId="1111"> <!-- Quota with NON-EU based trade partner -->
      <TradePartner>
         <CompanyName>Non EU Company 1</CompanyName>
         <NonEUCountryCodeOfEstablishment>US</NonEUCountryCodeOfEstablishment>
         <NonEUCountryOfEstablishment>United States</NonEUCountryOfEstablishment>
         <NonEUDgClimaRegCode>123456</NonEUDgClimaRegCode>
         <NonEURepresentativeName>Eu Company 28</NonEURepresentativeName>
         <NonEURepresentativeVAT>eu-28</NonEURepresentativeVAT>
      </TradePartner>
      <Amount>25000</Amount>
   </Quota>
</QuotaRoot>
```

**Company size**
```xml
<!-- List of companies that are large -->
<LargeCompanies>
   <Company>
      <CompanyID>1111</CompanyID>
   </Company>
   <Company>
      <CompanyID>1170</CompanyID>
   </Company>
</LargeCompanies>
```

**NER**
```xml
<!-- List of companies that are NER -->
<NER-List>
  <Company>
    <CompanyID>1129</CompanyID>
  </Company>
  <Company>
    <CompanyID>1234</CompanyID>
  </Company>
</NER-List>
```

### Expected output
```xml
<dataRoot>
   <registryData companyId="1111">
      <stocks>
         <stock>
            <transactionCode>4F</transactionCode>
            <gasId>2</gasId>
            <gasName>HFC-23</gasName>
            <amount>3.5</amount>
         </stock>
         <stock>
            <transactionCode>4G</transactionCode>
            <gasId>2</gasId>
            <gasName>HFC-23</gasName>
            <amount>3</amount>
         </stock>
         <stock>
            <transactionCode>4H</transactionCode>
            <gasId>3</gasId>
            <gasName>HFC-32</gasName>
            <amount>4.5</amount>
         </stock>
      </stocks>
      <quota>
         <allocatedQuota>120000</allocatedQuota>
         <availableQuota>140000</availableQuota>
         <allocatedQuotaDate>2016-12-30</allocatedQuotaDate>
         <availableQuotaDate>2016-12-30</availableQuotaDate>
         <quota9A_imp>
            <tradePartner>
               <CompanyName>EU Company 1</CompanyName>
               <EUVAT>eu-1</EUVAT>
            </tradePartner>
            <amount>60000</amount>
         </quota9A_imp>
         <quota9A_imp>
            <tradePartner>
               <CompanyName>EU Company 2</CompanyName>
               <EUVAT>eu-2</EUVAT>
            </tradePartner>
            <amount>50000</amount>
         </quota9A_imp>
         <quota9A_imp>
            <tradePartner>
               <CompanyName>Non EU Company 1</CompanyName>
               <NonEUCountryCodeOfEstablishment>US</NonEUCountryCodeOfEstablishment>
               <NonEUCountryOfEstablishment>United States</NonEUCountryOfEstablishment>
               <NonEUDgClimaRegCode>123456</NonEUDgClimaRegCode>
               <NonEURepresentativeName>Eu Company 28</NonEURepresentativeName>
               <NonEURepresentativeVAT>eu-28</NonEURepresentativeVAT>
            </tradePartner>
            <amount>10000</amount>
         </quota9A_imp>
      </quota>
      <large>false</large>
      <ner>true</ner>
   </registryData>
   <!-- more registryData entries, one per company -->
</dataRoot>
```

## Considerations

The input XML files must be generated by the dev team, as ETC export data in MS Excel format. Last year, Excel resources were converted using an MS Excel feature that converts spreadsheets to XML using an XSD. These XSD have been source controlled, and reside within the same directory as the merger script:
- fgases-ner-list.xsd
- fgases-company-size.xsd
- fgases-quotas-single.xsd
  - fgases-quotas-combine.xquery

The usage of the XSDs for NER and company size is straightforward. Regarding aggregated quota, the two values (allocated, available) were originally exported into two separate files. Hence, the XSD created intermediate XML files for both, that are expected to be combined with the _fgases-quotas-combine.xquery script_.

Finally, the stocks data was originally provided in XML *directly*, thus no XSD was required.
