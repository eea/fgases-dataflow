<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
								xmlns:fgas="http://eionet.europa.eu/dataflows/fgas"
                version="2.0">
    <xsl:output method="xhtml" indent="yes"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                omit-xml-declaration="yes"/>
    <!--<xsl:variable name="schema" select="document('https://svn.eionet.europa.eu/repositories/Reportnet/Dataflows/FGases/angular/schema/FGasesReporting2015.xsd')/xs:schema"/>-->
    <!--<xsl:variable name="labels" select="document('http://converters.eionet.europa.eu/xmlfile/article17-labels.xml')/labels"/>-->
    <!--<xsl:variable name="codelists" select="document('http://converters.eionet.europa.eu/xmlfile/fgases-codelists-en.xml')/Article17Codelists"/>-->

    <!--<xsl:variable name="codelistsUrl">
        <xsl:choose>
            <xsl:when test="doc-available(concat($xmlPath, 'fgases-codelists-', $labelsLanguage ,'.xml'))">
                <xsl:value-of select="concat($xmlPath, 'fgases-codelists-', $labelsLanguage ,'.xml')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($xmlPath, 'fgases-codelists-en.xml')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="codelists" select="document($codelistsUrl)/LCPCodelists"/>
   -->
    <xsl:variable name="labelsLanguage" select="FGasesReporting/@xml:lang"/>
    <xsl:variable name="xmlPath" select="'../xmlfile/'"/>
    <xsl:variable name="labelsUrl">
        <xsl:choose>
            <xsl:when test="doc-available(concat($xmlPath, 'fgases-labels-', $labelsLanguage ,'.xml'))">
                <xsl:value-of select="concat($xmlPath, 'fgases-labels-', $labelsLanguage ,'.xml')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($xmlPath, 'fgases-labels-en.xml')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="labels" select="document($labelsUrl)/labels"/>


    <xsl:template name="getLabel" >
        <xsl:param name="labelName"/>
        <xsl:param name="labelPath" select="''"/>
        <!--<xsl:param name="lang" select="'en'"/>-->

        <xsl:variable name="labelValue" select="$labels/descendant-or-self::*[local-name() = $labelName]"/>

        <xsl:choose>
            <xsl:when test="string-length($labelPath) &gt; 0">
                <xsl:variable name="labelValue2" select="$labels/descendant-or-self::*[local-name() = $labelPath]/descendant-or-self::*[local-name() = $labelName]"/>
                <xsl:value-of disable-output-escaping="yes" select="$labelValue2"/>
            </xsl:when>
            <xsl:when test="string-length($labelValue) &gt; 0">
                <xsl:choose>
                    <xsl:when test="contains($labelValue,'{{reportingYear}}')">
                        <xsl:value-of select="replace($labelValue,'\{\{reportingYear\}\}', string(../@year))"/>
                    </xsl:when>

                    <xsl:otherwise><xsl:value-of disable-output-escaping="yes" select="$labelValue"/> </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of disable-output-escaping="yes" select="$labelName"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getGas">
        <xsl:param name="elem"/>
        <!--<xsl:variable name="gasNameParts" select="tokenize($elem, '\s+')"></xsl:variable>-->
        <xsl:variable name="replaceComma" select="replace($elem,',',', ')"/>

        <xsl:choose>
            <xsl:when test="contains($replaceComma, 'propane')">
                <xsl:value-of select="replace($replaceComma,'propane',' propane')"/>
            </xsl:when>
            <xsl:when test="contains($replaceComma, 'butane')">
                <xsl:value-of select="replace($replaceComma,'butane',' butane')"/>
            </xsl:when>
            <xsl:when test="contains($replaceComma, 'pentane')">
                <xsl:value-of select="replace($replaceComma,'pentane',' pentane')"/>
            </xsl:when>
            <xsl:when test="contains($replaceComma, 'methane')">
                <xsl:value-of select="replace($replaceComma,'methane',' methane')"/>
            </xsl:when>
            <xsl:when test="contains($replaceComma, 'ethane')">
                <xsl:value-of select="replace($replaceComma,'ethane',' ethane')"/>
            </xsl:when>
            <xsl:when test="contains($replaceComma, 'butane')">
                <xsl:value-of select="replace($replaceComma,'butane',' butane')"/>
            </xsl:when>
            <xsl:when test="contains($replaceComma, 'propanol')">
                <xsl:value-of select="replace($replaceComma,'propanol',' propanol')"/>
            </xsl:when>
            <xsl:when test="contains($replaceComma, 'isopropylether')">
                <xsl:value-of select="replace(replace($replaceComma,'isopropylether',' isopropylether'), 'polymethyl',' polymethyl')"/>
            </xsl:when>

            <xsl:otherwise><xsl:value-of select="$replaceComma"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getValue">
        <xsl:param name="elem"/>
        <xsl:param name="elementType" select="''"/>
        <xsl:param name="colspan" select="0"/>
        <xsl:param name="isLink" select="false()"/>
        <xsl:param name="codelistElement" select="''"/>
        <xsl:variable name="elemValue">
            <xsl:choose>
                <!-- <xsl:when test="string-length($codelistName) &gt; 0">
                     <xsl:value-of select="$schema/xs:simpleType[@name = $elementType]//xs:enumeration[@value = $elem]/xs:annotation/xs:documentation"/>
                 </xsl:when>-->
                <xsl:when test="$elem/text()='yes'">Yes</xsl:when>
                <xsl:when test="$elem/text()='no'">No</xsl:when>
                <!-- detect disabled fields -->
                <xsl:otherwise><xsl:value-of select="$elem"/></xsl:otherwise>

            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string($elemValue) = 'true'">
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'yes'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="string($elemValue) = 'false'">
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'no'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="break">
                    <xsl:with-param name="text" select="$elemValue"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="break">
        <xsl:param name="text" select="."/>
        <xsl:choose>

            <xsl:when test="contains($text, '&#10;')">
                <xsl:value-of select="substring-before($text, '&#10;')" />
                <br/>
                <xsl:call-template name="break">
                    <xsl:with-param name="text" select="substring-after($text, '&#10;')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--<xsl:template name="getLabelInCodelist" >
        <xsl:param name="labelName"/>

        <xsl:param name="schemaElementName" select="''"/>
        <xsl:param name="codelistElementName"  select="substring($schemaElementName,1,number(string-length($schemaElementName)-4))"/>
        --><!--<xsl:param name="lang" select="'en'"/>--><!--
        <xsl:variable name="codelistValue" select="$codelists/*[local-name() = $codelistElementName]/*/label[../code = $labelName]"/>
        <xsl:choose>
            <xsl:when test="string-length($codelistValue) &gt; 0">
                <xsl:value-of select="$codelistValue"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="labelValue" select="$schema/xs:simpleType[@name = $schemaElementName]//xs:enumeration[@value = $labelName]/xs:annotation/xs:documentation"/>
                <xsl:choose>
                    <xsl:when test="string-length($labelValue[1]) &gt; 0">
                        <xsl:value-of select="$labelValue"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$labelName"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->

    <xsl:function name="fgas:isHfcBased" as="xs:boolean">
    	<xsl:param name="gasId" />
			<xsl:param name="rootElm" as="item()" />
    	<xsl:value-of select="$gasId = '187' or not(empty($rootElm/ReportedGases[GasId = $gasId and GWP_AR4_HFC > 0]))" />
    </xsl:function>

    <xsl:template match="/">
        <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'Questionnaire-title'"/>
                    </xsl:call-template>
                </title>
                <meta content="text/html; charset=utf-8"/>
                <style type="text/css">
					/*@media print{@page {size: landscape}}*/
					@page {
						size: A4;
						/*margin: 0;*/
						margin-right: 5em;
						margin-left: 5em;
					}

					@media print {
						h1 {
							width: 50em;
						}

						html, body {
							width: 210mm;
							height: 297mm;
						}

						@page {
							/*-webkit-transform: rotate(-90deg); -moz-transform:rotate(-90deg);
							filter:progid:DXImageTransform.Microsoft.BasicImage(rotation=3) !important;*/

						}

						table {
							page: rotated
						}

						table {
							font-size: 6pt;
						}

						th {
							page-break-inside: avoid
						}

						td {
							page-break-inside: avoid;
							white-space: pre-line;
						}

						tr {
							page-break-inside: avoid
						}

						#table-5 {
							page-break-inside: avoid
						}

						#table-5 th span {
							text-align: left;
							float: left;
						}

						/*.table-2{ page-break-inside : avoid}*/
						/*#table-3 { display: none; !important}
						.table-3-print{display: inherit !important}*/
						/*.table-3-print{ page-break-inside : avoid !important;}*/
						/*.table-3-print, .table-3-print tr , .table-3-print tr td{width: 100% !important;padding-bottom: 1em;}
						.table-3-print-all, .table-3-print-all table {width: 100% !important; display: inherit !important; }
						#table-3-main-h2{display: none !important;}*/
						h2 {
							page-break-after: avoid
						}

						@page {
							orphans: 4;
							widows: 2;
						}

						/*#table-6 { display: none; !important}
						.table-6-print{display: inherit !important; padding-bottom: 1em;}*/
						th {
							text-align: center !important;
							padding: 0;
						}

						td {
							padding: 0;
						}

						/*@page {
							-webkit-transform: rotate(-90deg); -moz-transform:rotate(-90deg);
							filter:progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
						}*/
						.landScape {
							width: 100%;
							height: 100%;
							margin: 0% 0% 0% 0%;
							filter: progid:DXImageTransform.Microsoft.BasicImage(Rotation=3);
						}
					}

					@media print and (-webkit-min-device-pixel-ratio: 0) {
						/*@page {
							size: landscape;
						}*/
					}

					/*@media print{@page {
						-webkit-transform: rotate(-90deg); -moz-transform:rotate(-90deg);
						filter:progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
					}*/
					/*#table-3-main-h2{display: inherit;}
					.table-3-print-all{display: none;}
					.table-3-print{display: none;}
					.table-6-print{display: none;}*/
					h2 {
						font-family: arial, verdana, sans-serif;
					}

					h1 {
						font-size: 160%;
						padding-bottom: 0.5em;
						border-bottom: 1px solid #999999;
					}

					body {
						font-size: 80%;
						font-family: verdana, helvetica, arial, sans-serif;
						color: #333;
					}

					caption {
						display: none;
						font-family: vardana, verdana, helvetica, arial, sans-serif;
						text-align: left;
						font-size: 150%;
					}

					table {
						font-size: 100%;
						border: 1px solid #bbb;
						margin: 0 0 2em 0;
						border-collapse: collapse;
						max-width: 74em;
					}

					#table-4 {
						width: 10em !important;
					}

					.sub {
						font-size: 0.8em;
					}

					sup {
						font-size: 0.8em;
						font-style: italic;
						color: #777;
					}

					.datatable tr.th {
						text-align: left;

					}

					.datatable2 tr.th {
						text-align: left;

					}

					.datatable2 {
						margin: 0 0 0 0;
						border: 1px solid #bbb;
						border-collapse: collapse;
					}

					th, td {
						font-size: 100%;
						border: 1px solid #bbb;
					}

					th {
						background-color: #f6f6f6;
						text-align: left;
						vertical-align: top;
						font-weight: normal;
						color: black;
					}

					table {
						font-size: 100%;
						border: 1px solid #bbb;
						margin: 0 0 2em 0;
						border-collapse: collapse;
					}

					.left {
						text-align: left;
					}

					.bold {
						font-weight: bold;
					}

					.transactionColum {
						width: 15em;
					}

					.substanceColum {
						width: 5em;
						text-align: center;
					}

					.exportRow1 {

					}

					.exportRow2 {
						width: 7em;
					}

					.cellHeight {
						height: 1.4em;
					}

					.generalReportDataColum {
						width: 10em;
					}

					.metadata_table tr th:first-child {
						width: 15em;
					}

					.metadata_table td {
						width: 10em;
					}

					.footnote-b-tr td {
						word-wrap: break-word;
						width: 10em;
					}

					.footnote span, div.footnote {
						font-size: 0.9em;
						font-style: italic;
						color: #777;
					}
					.comment {
						font-style: italic;
						white-space: normal;
					}
					.commentTbl tr.th {
						width: 10em;
					}

					.commentTbl th.col-1 {
						width: 5em;
					}

					.commentTbl th.col-2 {
						width: 14.5em;
					}

					.commentTbl th.col-3 {
						width: 5em;
					}

					.commentTbl th.col-4 {
						width: 5em;
					}

					.section11-table th, .section11-table td {
						vertical-align: top;
						background-color: #f6f6f6;
					}

					.section11-table .code {
						font-weight:bold;
					}

					.floatRight {
						float: right;
					}

					.activitiesCheckbox .floatRight {
						float: right;
					}

					.activitiesCheckbox input.floatRight {
						width: 2em;
					}

					.floatLeft {
						float: left;
					}

					.bottom-border-bold {
						border-bottom: 2px solid rgb(182, 182, 182);
					}

					#affiliation-intro, #affiliation-intro td {
						border: 0;
					}

					.padding-right-1em {
						padding-right: 1em;
					}

					.padding-left-1-5em {
						padding-left: 1.5em;
					}

					.padding-left-1em {
						padding-left: 1em;
					}

					.padding-left-2em {
						padding-left: 2em;
					}

					.padding-left-3em {
						padding-left: 3em;
					}

					.padding-left-4em {
						padding-left: 4em;
					}

					.boldTh th {
						font-weight: bold;
					}

					.padding-top {
						padding-top: 3em;
					}

					.gasTh {
						width: 4em;
					}
					.sum-of-supplied-hfs {
						width: 8em;
						colspan: 2;
					}

					.boldSpan th span {
						font-weight: bold;
					}

					.boldHeading th {
						font-weight: bold;
					}

					.no-wrap {
						white-space: nowrap;
					}

					input:disabled, textarea:disabled {
						color: #000000;
					}

					#table-1 td, #table-1 th {
						padding: 0.5em;
					}

					#table-2 td, #table-2 th {
						padding: 0.5em;
					}

					#table-3 td, #table-3 th {
						padding: 0.5em;
					}

					#Affiliations td, #Affiliations th {
						padding: 0.5em;
					}

					#table-4 td, #table-4 th {
						padding: 0.5em;
					}

					.textCenter {
						text-align: center;
					}

					.sidePadding {
						padding-right: 1em;
						padding-left: 1em;
					}

					.tablePaginationNrColor {
						color: blue;
					}

					.tradingPartners div {
						float: left;
					}

					body {
						font-family: arial !important;
					}

					td {
						color: rgb(0, 0, 192);
					}

					.black {
						color: black !important;
					}

					.firstTh {
						width: 20em;
					}

					.tableSizeLimit {
						max-width: 79em;
						width: 48em;
					}

					.tdColorBlack td {
						color: black;
					}

					.tdColorBlue {
						color: rgb(0, 0, 192) !important;
					}

					.formula {
						font-weight: bold;
						font-style: italic;
						/*color: rgb(90, 90, 90); gray*/
						/*rgb(16, 152, 0); lighter green*/
						color: rgb(25, 102, 16); /*darker green */
					}

					.fontNormal {
						font-weight: normal !important;
					}

					.num_cell {
						text-align: right;
						background-color: #FFFFE0 !important;
						padding-right: 0.2em;
						white-space: nowrap;
						padding-left: 0.2em;
						vertical-align:top;
						color: rgb(0, 0, 192);
					}

					.total {
						/*
						font-weight:bold;
						*/
						color: black;
						background-color: #f6f6f6;
						text-align: right;
						padding-left: 0.2em;
						padding-right: 0.2em;
						white-space: nowrap;
						vertical-align:top;
						color: rgb(0, 0, 192);
					}

					.nowrap {
						white-space: nowrap;
					}

					.inputPadding span {
						padding-left: 0.5em;
					}

					.section11Amount {
						width: 6em;
					}

					.section11Explanation {
						width: 6em;
					}

					.section11Code {
						width: 3em;
					}

					.hidden {
						visibility: hidden;
						border-color: #fff;
					}

					.hidden td {
						border-color: #fff;
						border-bottom: 1px solid #bbb !important;
					}

					.word-break {
						word-break: normal;
					}
				</style>

            </head>
            <body>
                <h1>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'Questionnaire-title'"/>
                    </xsl:call-template>
                </h1>

                <xsl:apply-templates />
                <div class="padding-bottom"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="GeneralReportData">

<!-- Company Information tab -->
        <h2>
            <xsl:call-template name="getLabel">
                <xsl:with-param name="labelName" select="'info'"/>
            </xsl:call-template>
        </h2>
        <table id="table-1" class="table table-hover table-bordered">
            <tbody>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'name'"/>
                        </xsl:call-template>
                    </th>
                    <td colspan="3">
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/CompanyName"/></xsl:call-template>
                    </td>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'contact-tel'"/>
                        </xsl:call-template>
                    </th>
                    <td >
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/Telephone"/></xsl:call-template>
                    </td>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'website'"/>
                        </xsl:call-template>
                    </th>
                    <td colspan="3">
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/Website"/></xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'address-street'"/>
                        </xsl:call-template>
                    </th>
                    <td >
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/PostalAddress/StreetAddress"/></xsl:call-template>
                    </td>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'address-number'"/>
                        </xsl:call-template>
                    </th>
                    <td >
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/PostalAddress/Number"/></xsl:call-template>
                    </td>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'address-postcode'"/>
                        </xsl:call-template>
                    </th>
                    <td >
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/PostalAddress/PostalCode"/></xsl:call-template>
                    </td>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'address-city'"/>
                        </xsl:call-template>
                    </th>
                    <td >
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/PostalAddress/City"/></xsl:call-template>
                    </td>
                    <th>
						<xsl:choose>
							<xsl:when test="Company/Country/Type='EU_TYPE'">
								<xsl:call-template name="getLabel">
									<xsl:with-param name="labelName" select="'eu-country'"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="getLabel">
									<xsl:with-param name="labelName" select="'non-eu-country'"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
                    </th>
                    <td >
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/Country/Name"/></xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'vat'"/>
                    </xsl:call-template>
                    </th>
                    <td colspan="9">
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/VATNumber"/></xsl:call-template>
                    </td>
                </tr>
            </tbody>
        </table>


        <xsl:if test="string-length(Company/EuLegalRepresentativeCompany/CompanyName) > 0">
            <h2>
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'eu-legal-representative'"/>
                </xsl:call-template>
            </h2>
            <table id="table-2" class="table table-hover table-bordered">
                <tbody>
                    <tr>
                        <th colspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'eu-vat'"/>
                            </xsl:call-template>
                        </th>
                        <td colspan="8">
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/VATNumber"/></xsl:call-template>
                        </td>
                    </tr>
                    <tr>
                        <th>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'eu-legal-representative-name'"/>
                            </xsl:call-template>
                        </th>
                        <td  colspan="3">
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/CompanyName"/></xsl:call-template>
                        </td>
                        <th>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'contact-tel'"/>
                            </xsl:call-template>
                        </th>
                        <td >
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/Telephone"/></xsl:call-template>
                        </td>
                        <th>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'website'"/>
                            </xsl:call-template>
                        </th>
                        <td colspan="3">
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/Website"/></xsl:call-template>
                        </td>
                    </tr>
                    <tr>
                        <th>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'address-street'"/>
                            </xsl:call-template>
                        </th>
                        <td >
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/PostalAddress/StreetAddress"/></xsl:call-template>
                        </td>

                        <th>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'address-number'"/>
                            </xsl:call-template>
                        </th>
                        <td >
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/PostalAddress/number"/></xsl:call-template>
                        </td>

                        <th>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'address-postcode'"/>
                            </xsl:call-template>
                        </th>
                        <td >
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/PostalAddress/PostalCode"/></xsl:call-template>
                        </td>

                        <th>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'address-city'"/>
                            </xsl:call-template>
                        </th>
                        <td >
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/PostalAddress/City"/></xsl:call-template>
                        </td>

                        <th>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'eu-country'"/>
                            </xsl:call-template>
                        </th>
                        <td >
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/Country/Name"/></xsl:call-template>
                        </td>
                    </tr>
                    <tr>
                        <th colspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'eu-legal-representative-contact'"/>
                            </xsl:call-template>
                        </th>
                        <td colspan="3">
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/ContactPerson/FirstName"/></xsl:call-template>
                            <span style="padding-right:1em;"/>
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/ContactPerson/LastName"/></xsl:call-template>
                        </td>
                        <th colspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'eu-legal-representative-email'"/>
                            </xsl:call-template>
                        </th>
                        <td colspan="3">
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Company/EuLegalRepresentativeCompany/ContactPerson/Email"/></xsl:call-template>
                        </td>
                    </tr>
                </tbody>
            </table>
        </xsl:if>

        <h2>
            <xsl:call-template name="getLabel">
                <xsl:with-param name="labelName" select="'contact-info'"/>
            </xsl:call-template>
        </h2>
        <table  id="table-3" class="table table-hover table-bordered">
            <tbody>
                <xsl:for-each select="Company/ContactPersons/*">
                <tr>
                    <th colspan="">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'contact-first-name'"/>
                        </xsl:call-template>
                    </th>
                    <td colspan="">
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="./FirstName"/></xsl:call-template>
                    </td>
                    <th colspan="">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'contact-last-name'"/>
                        </xsl:call-template>
                    </th>
                    <td colspan="">
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="./LastName"/></xsl:call-template>
                    </td>
                    <th colspan="">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'contact-email'"/>
                        </xsl:call-template>
                    </th>
                    <td colspan="">
                        <xsl:call-template name="getValue"><xsl:with-param name="elem" select="./Email"/></xsl:call-template>
                    </td>
                </tr>
                </xsl:for-each>
            </tbody>
        </table>
        <h2>
            <xsl:call-template name="getLabel">
                <xsl:with-param name="labelName" select="'affiliation-header'"/>
            </xsl:call-template>
        </h2>
        <table  id="affiliation-intro" style="margin-top:1em;"  class="table table-hover table-bordered">
            <tr>
                <td class="black">
                        <span >
                            <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'affiliation-intro'"/>
                            </xsl:call-template>
                        </span>
                </td>
            </tr>
        </table>
        <xsl:if test="count(Company/Affiliations/*) = 0">
            <span>
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'affiliation-confirmed-nothing'"/>
                </xsl:call-template>
            </span>
        </xsl:if>
        <xsl:if test="count(Company/Affiliations/*) > 0">
            <table  id="Affiliations" style="margin-top:1em;"  class="table table-hover table-bordered">
                  <xsl:for-each select="Company/Affiliations/*">
                      <xsl:if test="position() > 1">
                          <tr>
                              <td colspan="4"/>
                          </tr>
                      </xsl:if>
                      <tr>
                          <th>
                              <xsl:call-template name="getLabel">
                                  <xsl:with-param name="labelName" select="'trading-partner-company-name'"/>
                              </xsl:call-template>
                          </th>
                          <td>
                              <xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template>
                          </td>

                          <th>
                              <xsl:call-template name="getLabel">
                                  <xsl:with-param name="labelName" select="'trading-partner-eu-based'"/>
                              </xsl:call-template>
                          </th>
                          <td>
                              <xsl:call-template name="getValue"><xsl:with-param name="elem" select="isEUBased"/></xsl:call-template>
                          </td>
                      </tr>

                        <xsl:if test="isEUBased = 'true'">
                            <tr class="bottom-border-bold">
                                <th>
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'trading-partner-vat-no'"/>
                                    </xsl:call-template>
                                </th>
                                <td colspan="3">
                                    <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template>
                                </td>
                            </tr>
                        </xsl:if>
                        <xsl:if test="isEUBased = 'false'">
                            <tr>
                                <th>
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                    </xsl:call-template>
                                </th>
                                <td colspan="1">
                                    <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                </td>
                                <th>
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'trading-partner-reg-code'"/>
                                    </xsl:call-template>
                                </th>
                                <td colspan="1">
                                    <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUDgClimaRegCode"/></xsl:call-template>
                                </td>
                            </tr>
                            <tr class="bottom-border-bold">
                                <th>
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                    </xsl:call-template>
                                </th>
                                <td colspan="1">
                                    <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                </td>
                                <th>
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'trading-partner-representative-vat'"/>
                                    </xsl:call-template>
                                </th>
                                <td colspan="1">
                                    <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeVAT"/></xsl:call-template>
                                </td>
                            </tr>
                        </xsl:if>

                  </xsl:for-each>


            </table>
        </xsl:if>
<!-- Year & Activities tab -->
        <table  id="table-4" style="margin-top:1em;"  class="table table-hover table-bordered">
            <tr>
                <th class="nowrap">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'reporting-year'"/>
                    </xsl:call-template>
                </th>
                <td>
                    <xsl:call-template name="getValue"><xsl:with-param name="elem" select="TransactionYear"/></xsl:call-template>
                </td>
            </tr>
        </table>


        <xsl:if test="count(Activities/*[. = 'true']) > 0">
        <table  id="table-5"  class="activitiesCheckbox table table-hover table-bordered">
                <tr style="border-top: 1px solid #fff;
                    border-left: 1px solid #fff;
                    border-right: 1px solid #fff;">
                    <td class="black" style="border-top: 1px solid #fff;
                    border-left: 1px solid #fff;
                    border-right: 1px solid #fff;" colspan="2">
                        <h2>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'heading'"/>
                            </xsl:call-template>
                        </h2>
                    </td>
                </tr>
            <xsl:if test="Activities/*[substring(name(.),1,1) = 'P'] = 'true'">
                <tr>
                    <th colspan="2" class="inputPadding">
                        <input class="floatLeft" type="checkbox" name="P-HFC"  checked="true" disabled="true"></input>
                        <span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'producer'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                </tr>
                <xsl:if test="Activities/P-HFC = 'true'">
                    <tr>
                        <td class="padding-left-1-5em">
                            <input class="floatRight" type="checkbox" name="P-HFC"  checked="true" disabled="true"></input>
                        </td>
                        <th>
                            <span>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'producer-hfc'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                    </tr>
                </xsl:if>
                <xsl:if test="Activities/P-other = 'true'">
                    <tr>
                        <td class="padding-left-1-5em">
                            <input class="floatRight" type="checkbox" name="P-other"  checked="true" disabled="true"></input>
                        </td>
                        <th>
                            <span>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'producer-other'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                    </tr>
                </xsl:if>
            </xsl:if>
            <xsl:if test="Activities/*[substring(name(.),1,1) = 'I'] = 'true'">
                <tr>
                    <th colspan="2" class="inputPadding">
                        <input class="floatLeft" type="checkbox" name="importer-bulk"  checked="true" disabled="true"></input>
                        <span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'importer-bulk'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                </tr>
                <xsl:if test="Activities/I-HFC = 'true'">
                    <tr>
                        <td class="padding-left-1-5em">
                            <input class="floatRight" type="checkbox" name="I-HFC"  checked="true" disabled="true"></input>
                        </td>
                        <th>
                            <span>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'importer-bulk-hfc'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                    </tr>
                </xsl:if>
                <xsl:if test="Activities/I-other = 'true'">
                    <tr>
                        <td class="padding-left-1-5em">
                            <input class="floatRight" type="checkbox" name="P-other"  checked="true" disabled="true"></input>
                        </td>
                        <th>
                            <span>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'importer-bulk-other'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                    </tr>
                </xsl:if>
            </xsl:if>
            <xsl:if test="Activities/E = 'true'">
                <tr>
                    <td>
                        <input type="checkbox" name="E"  checked="true" disabled="true"></input>
                    </td>
                    <th>
                        <span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'exporter-bulk'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                </tr>
            </xsl:if>
            <xsl:if test="Activities/FU = 'true'">
                <tr>
                    <td>
                        <input type="checkbox" name="E"  checked="true" disabled="true"></input>
                    </td>
                    <th>
                        <span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'feedstock-user'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                </tr>
            </xsl:if>
            <xsl:if test="Activities/D = 'true'">
                <tr>
                    <td>
                        <input type="checkbox" name="E"  checked="true" disabled="true"></input>
                    </td>
                    <th>
                        <span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'destruction-company'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                </tr>
            </xsl:if>
            <xsl:if test="Activities/*[substring(name(.),1,2) = 'Eq' or substring(name(.),1,4) = 'auth'] = 'true'">
                <tr>
                    <th class="bold" colspan="2">
                        <span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'manufacturer-containing-fgases'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                </tr>
                <!--<tr>
                    <th colspan="2">
                        <span style="padding-bottom:1em;">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'manufacturer-containing-fgases-info-text'"/>
                            </xsl:call-template>
                        </span>
                        <span>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'manufacturer-containing-fgases-info-text2'"/>
                            </xsl:call-template>
                        </span>
                    </th>
                </tr>-->
                <xsl:if test="Activities/*[substring(name(.),1,2) = 'Eq'] = 'true'">
                <tr>
                    <th colspan="2" class="inputPadding">
                        <input class="floatLeft" type="checkbox" name="importer-fgases"  checked="true" disabled="true"></input>
                        <span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'importer-fgases'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                </tr>
                </xsl:if>
                <xsl:if test="Activities/Eq-I-RACHP-HFC = 'true'">
                    <tr>
                        <td  class="padding-left-1-5em">
                            <input class="floatRight" type="checkbox" name="Eq-I-RACHP-HFC"  checked="true" disabled="true"></input>
                        </td>
                        <th>
                            <span>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'importer-fgases-hfc'"/>
                                </xsl:call-template>
                            </span>
                        </th>
                    </tr>
                </xsl:if>
                <xsl:if test="Activities/Eq-I-other = 'true'">
                    <tr>
                        <td  class="padding-left-1-5em">
                            <input class="floatRight" type="checkbox" name="Eq-I-other"  checked="true" disabled="true"></input>
                        </td>
                        <th>
                            <span>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'importer-fgases-other'"/>
                                </xsl:call-template>
                            </span>
                        </th>
                    </tr>
                </xsl:if>
                <xsl:if test="Activities/auth = 'true'">
                    <tr>
	                    <td>
	                        <input type="checkbox" name="auth"  checked="true" disabled="true"></input>
	                    </td>
                        <th colspan="2">

                            <span>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'undertaking-authorisation'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                    </tr>
                </xsl:if>
            </xsl:if>
            <xsl:if test="Activities/auth-NER = 'true'">
                <tr>
                    <td class="padding-left-1-5em">
                        <input type="checkbox" name="auth-NER"  checked="true" disabled="true"></input>
                    </td>
                    <th colspan="2">
                        <span>
                        
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'undertaking-authorisation-ner'"/>
                            </xsl:call-template>
                        </span>
                    </th>
                </tr>
            </xsl:if>
            <xsl:if test="Activities/NIL-Report = 'true'">
                <tr>
                    <th colspan="2" class="bold">
                        <span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'nil-report-desc'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                </tr>
                <tr>
                    <td>
                        <input type="checkbox" name="nil-report"  checked="true" disabled="true"></input>
                    </td>
                    <th>
                        <span>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'nil-report'"/>
                            </xsl:call-template>
                        </span>
                    </th>
                </tr>
            </xsl:if>
        </table>
    </xsl:if>
        <xsl:if test="count(../ReportedGases/GasGroup[string-length(.) > 0]) > 0">
            <h2>
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'selection'"/>
                </xsl:call-template>
            </h2>
            <xsl:call-template name="gases" />
        </xsl:if>
    </xsl:template>
    <xsl:template name="gases">

        <table id="table-2" class="table table-hover table-bordered">
        <tbody class="boldTh">
            <xsl:if test="count(../ReportedGases/GasGroup[.= 'HFCs']) > 0 ">
                <tr>
                    <th colspan="2">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'hfc-selection'"/>
                        </xsl:call-template>
                    </th>

                </tr>
                <xsl:for-each select="../ReportedGases[./GasGroup = 'HFCs']">
                    <tr>
                        <td/>
                        <td class="padding-left-1em">
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Name"/></xsl:call-template>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

			<xsl:if test="count(../ReportedGases/GasGroup[.= 'HFC mixtures']) > 0 ">
				<tr>
					<th colspan="2">
						<xsl:call-template name="getLabel">
							<xsl:with-param name="labelName" select="'mixtures-selection'"/>
						</xsl:call-template>
					</th>

				</tr>
				<xsl:for-each select="../ReportedGases[./GasGroup = 'HFC mixtures']">
					<tr>
						<td/>
						<td class="padding-left-1em">
							<xsl:call-template name="getValue"><xsl:with-param name="elem" select="Name"/></xsl:call-template>
						</td>
					</tr>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="count(../ReportedGases/GasGroup[.= 'Unsaturated HFCs and HCFCs']) > 0 ">
				<tr>
					<th colspan="2">
						<xsl:call-template name="getLabel">
							<xsl:with-param name="labelName" select="'unsaturated-hfc-selection'"/>
						</xsl:call-template>
					</th>

				</tr>
				<xsl:for-each select="../ReportedGases[./GasGroup = 'Unsaturated HFCs and HCFCs']">
					<tr>
						<td/>
						<td class="padding-left-1em">
							<xsl:call-template name="getValue"><xsl:with-param name="elem" select="Name"/></xsl:call-template>
						</td>
					</tr>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="count(../ReportedGases/GasGroup[.= 'PFCs']) > 0 ">
                <tr>
                    <th colspan="2">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'pfc-selection'"/>
                        </xsl:call-template>
                    </th>

                </tr>
                <xsl:for-each select="../ReportedGases[./GasGroup = 'PFCs']">
                    <tr>
                        <td/>
                        <td class="padding-left-1em">
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Name"/></xsl:call-template>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <xsl:if test="count(../ReportedGases/GasGroup[.= 'SF6']) > 0 ">
                <tr>
                    <th colspan="2">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'sf6-selection'"/>
                        </xsl:call-template>
                    </th>

                </tr>
                <xsl:for-each select="../ReportedGases[./GasGroup = 'SF6']">
                    <tr>
                        <td/>
                        <td class="padding-left-1em">
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Name"/></xsl:call-template>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <xsl:if test="count(../ReportedGases/GasGroup[.= 'HFEs and alcohols']) > 0 ">
                <tr>
                    <th colspan="2">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'fluorinated-ethers-alcohols-selection'"/>
                        </xsl:call-template>
                    </th>

                </tr>
                <xsl:for-each select="../ReportedGases[./GasGroup = 'HFEs and alcohols']">
                    <tr>
                        <td/>
                        <td class="padding-left-1em">
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Name"/></xsl:call-template>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <xsl:if test="count(../ReportedGases/GasGroup[.= 'Other perfluorinated compounds']) > 0 ">
                <tr>
                    <th colspan="2">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'other-prefluorinated-selection'"/>
                        </xsl:call-template>
                    </th>

                </tr>
                <xsl:for-each select="../ReportedGases[./GasGroup = 'Other perfluorinated compounds']">
                    <tr>
                        <td/>
                        <td class="padding-left-1em">
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Name"/></xsl:call-template>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <xsl:if test="count(../ReportedGases/GasGroup[.= 'CustomMixture']) > 0 ">
                <tr>
                    <th colspan="2">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'costume-mixtures'"/>
                        </xsl:call-template>
                    </th>

                </tr>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'mixture-name'"/>
                        </xsl:call-template>
                    </th>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'mixture-gas-name'"/>
                        </xsl:call-template>
                        <span> - </span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'mixture-gas-ratio'"/>
                        </xsl:call-template>
                    </th>
                </tr>
                <xsl:for-each select="../ReportedGases[./GasGroup = 'CustomMixture']">
                    <tr>
                        <td class="padding-left-1em">
                            <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Code"/></xsl:call-template>
                        </td>
                        <td >
                            <xsl:for-each select="./BlendComponents/Component">
                                <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Code"/></xsl:call-template>
                                    <span> - </span>
                                <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Percentage"/></xsl:call-template>
                                    <span>% </span>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>
        </tbody>
        </table>
    </xsl:template>
    <xsl:template match="ReportedGases"/>


<!-- Pagination -->
    <!--Test: http://stackoverflow.com/questions/12235060/pagination-in-xsl  -->

<!--################################# PAGINATION LIMIT NR ##################################-->
    <xsl:variable name="pagingLimit" select="10"/>
<!--########################################################################################-->

    <xsl:template name="tablePaging1">
        <xsl:copy>
            <xsl:apply-templates  select=".[name() = 'F1_S1_4_ProdImpExp']/Gas">
                <xsl:with-param name="section" select="1" />
            </xsl:apply-templates>

        </xsl:copy>
    </xsl:template>

    <xsl:template name="tablePaging2">
        <xsl:copy>
            <xsl:apply-templates  select=".[name() = 'F1_S1_4_ProdImpExp']/Gas">
                <xsl:with-param name="section" select="2" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="tablePaging3">
        <xsl:copy>
            <xsl:apply-templates  select=".[name() = 'F1_S1_4_ProdImpExp']/Gas">
                <xsl:with-param name="section" select="3" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="tablePaging4">
        <xsl:copy>
            <xsl:apply-templates  select=".[name() = 'F1_S1_4_ProdImpExp']/Gas">
                <xsl:with-param name="section" select="4" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="tablePaging5">
        <xsl:copy>
            <xsl:apply-templates  select=".[name() = 'F2_S5_exempted_HFCs']/Gas">
                <xsl:with-param name="section" select="5" />
            </xsl:apply-templates>

        </xsl:copy>
    </xsl:template>

    <xsl:template name="tablePaging6">
        <xsl:copy>
            <xsl:apply-templates  select=".[name() = 'F3A_S6A_IA_HFCs']/Gas">
                <xsl:with-param name="section" select="6" />
            </xsl:apply-templates>

        </xsl:copy>
    </xsl:template>


    <xsl:template name="tablePaging7">
        <xsl:copy>
            <xsl:apply-templates  select=".[name() = 'F6_FUDest']/Gas">
                <xsl:with-param name="section" select="7" />
            </xsl:apply-templates>

        </xsl:copy>
    </xsl:template>
    <xsl:template name="tablePaging8">
        <xsl:copy>
            <xsl:apply-templates  select=".[name() = 'F6_FUDest']/Gas">
                <xsl:with-param name="section" select="8" />
            </xsl:apply-templates>

        </xsl:copy>
    </xsl:template>

    <xsl:template name="tablePaging10">
        <xsl:copy>
            <xsl:apply-templates  select=".[name() = 'F5_S10_Auth_NER']/Gas">
                <xsl:with-param name="section" select="11" />
            </xsl:apply-templates>

        </xsl:copy>
    </xsl:template>


    <xsl:template name="tablePaging11">
        <xsl:copy>
            <xsl:apply-templates  select=".[name() = 'F7_s11EquImportTable']/Gas">
                <xsl:with-param name="section" select="11" />
            </xsl:apply-templates>

        </xsl:copy>
    </xsl:template>
    <!-- Cleans up leftovers -->
    <xsl:template match="Gas[position() mod $pagingLimit != 1]" />

<!-- ###################################################### Tables with pagination ######################################################################## -->
    <xsl:template match="Gas[position() mod $pagingLimit = 1]"  name="section">
        <xsl:param name="section" />

    <!-- Section 1 -->

        <xsl:if test="$section = 1">
        <span class="bold tablePaginationNrColor" >(<xsl:value-of select="ceiling(position() div $pagingLimit)" />/<xsl:value-of select="ceiling(count(../Gas) div $pagingLimit)" /> )</span>
        <table   class="tableSizeLimit table table-hover table-bordered">
            <tbody  class="boldSpan">
                <tr class="boldHeading">
                    <th class="firstTh"><xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'sheet-transactions-header'"/>
                    </xsl:call-template></th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <th class="gasTh">
                            <xsl:call-template name="getGas"><xsl:with-param name="elem" select="../../ReportedGases[./GasId = current()/GasCode]/Name"/></xsl:call-template>
                        </th>
                    </xsl:for-each>
                </tr>
                <tr class="boldHeading no-wrap">
                    <th/>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <th class="textCenter sidePadding">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit'"/>
                                <xsl:with-param name="labelPath" select="'common'"/>
                            </xsl:call-template>
                        </th>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th>
                        <span>1A : </span>

                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01a-desc'"/>
                        </xsl:call-template>

                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_01A/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th class="padding-left-1em">
                        <span>1B : </span>

                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01b-desc'"/>
                        </xsl:call-template>

                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="num_cell">
                            <span><xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_01B/Amount"/></xsl:call-template></span>
                            <br/>
                            <br/>
                            <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_01B/Comment"/></xsl:call-template></span>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th class="padding-left-1em">
                        <span>1C : </span>

                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01c-desc'"/>
                        </xsl:call-template>

                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_01C/SumOfPartnerAmounts"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <xsl:variable name="gases" select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]" />
                <xsl:for-each select="../tr_01C_TradePartners/*">
                    <xsl:variable name="partnerId" select="PartnerId"/>
                    <tr>
                        <td  class="padding-left-1em tradingPartners">
                                <div><li/></div>
                                <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>

                                <br/>
                                <xsl:if test="isEUBased">
                                    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
                                </xsl:if>
                                <xsl:if test="isEUBased = 'false'">
                                    <div class="padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                        -
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                    </div>
                                </xsl:if>

                        </td>
                        <xsl:for-each select="$gases/tr_01C/TradePartner[TradePartnerID = $partnerId ]">
                            <td  class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>

                    </tr>
                </xsl:for-each>
                <tr>
                    <th  class="padding-left-1em">
                        <span>1D : </span>

                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01d-desc'"/>
                        </xsl:call-template>
                        <br/><span class="formula">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01d-formula'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td  class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_01D/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th >
                        <span>1E : </span>

                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01e-desc'"/>
                        </xsl:call-template>
                        <br/><span class="formula">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01e-formula'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td  class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_01E/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th >
                        <span>1F : </span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01f-desc'"/>
                        </xsl:call-template>
                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_01F/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th  class="padding-left-1em">
                        <span>1G : </span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01g-desc'"/>
                        </xsl:call-template>
                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_01G/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th  class="padding-left-1em">
                        <span>1H : </span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01h-desc'"/>
                        </xsl:call-template>
                        <br/><span class="formula">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01h-formula'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_01H/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th >
                        <span>1I : </span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01i-desc'"/>
                        </xsl:call-template>
                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_01I/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th >
                        <span>1J : </span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01j-desc'"/>
                        </xsl:call-template>
                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td  class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_01J/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th >
                        <span>1K : </span>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01k-desc'"/>
                        </xsl:call-template>
                        <br/><span class="formula">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-01k-formula'"/>
                        </xsl:call-template>
                        </span>
                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td  class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_01K/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
            </tbody>
        </table>
        </xsl:if>

    <!-- Section 2 -->

        <xsl:if test="$section = 2">
            <span class="bold tablePaginationNrColor" >(<xsl:value-of select="ceiling(position() div $pagingLimit)" />/<xsl:value-of select="ceiling(count(../Gas) div $pagingLimit)" /> )</span>
            <table style="width: 37em;"  class="table table-hover table-bordered">
                <tbody  class="boldSpan">
                    <tr class="boldHeading">
                        <th class="firstTh"><xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'sheet-transactions-header'"/>
                        </xsl:call-template></th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th class="gasTh">
                                <xsl:call-template name="getGas"><xsl:with-param name="elem" select="../../ReportedGases[./GasId = current()/GasCode]/Name"/></xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <tr class="boldHeading no-wrap">
                        <th/>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th class="textCenter sidePadding">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'common'"/>
                                </xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th>
                            <span>2A : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-02a-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_02A/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th>
                            <span>2B : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-02b-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_02B/Amount"/></xsl:call-template>
                                <br/>
	                            <br/>
	                            <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_02B/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                </tbody>
            </table>
        </xsl:if>

    <!-- Section 3 -->

        <xsl:if test="$section = 3">
            <span class="bold tablePaginationNrColor" >(<xsl:value-of select="ceiling(position() div $pagingLimit)" />/<xsl:value-of select="ceiling(count(../Gas) div $pagingLimit)" /> )</span>
            <table  class="tableSizeLimit table table-hover table-bordered">
            <tbody  class="boldSpan">
                <tr class="boldHeading">
                    <th class="firstTh"><xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'sheet-transactions-header'"/>
                    </xsl:call-template></th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <th class="gasTh">
                            <xsl:call-template name="getGas"><xsl:with-param name="elem" select="../../ReportedGases[./GasId = current()/GasCode]/Name"/></xsl:call-template>
                        </th>
                    </xsl:for-each>
                </tr>
                <tr class="boldHeading no-wrap">
                    <th/>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <th class="textCenter sidePadding">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit'"/>
                                <xsl:with-param name="labelPath" select="'common'"/>
                            </xsl:call-template>
                        </th>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th>
                        <span>3A : </span>

                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-03a-desc'"/>
                        </xsl:call-template>

                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_03A/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th class="padding-left-1em">
                        <span>3B : </span>

                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-03b-desc'"/>
                        </xsl:call-template>

                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_03B/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th class="padding-left-1em">
                        <span>3C : </span>

                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-03c-desc'"/>
                        </xsl:call-template>
                        <br/><span class="formula">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param
                                    name="labelName" select="'tr-03c-formula'"/>
                        </xsl:call-template>
                        </span>

                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_03C/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th class="padding-left-1em">
                        <span>3D : </span>

                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-03d-desc'"/>
                        </xsl:call-template>

                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_03D/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th class="padding-left-1em">
                        <span>3E : </span>

                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-03e-desc'"/>
                        </xsl:call-template>

                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_03E/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
                <tr>
                    <th class="padding-left-1em">
                        <span>3F : </span>

                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'tr-03f-desc'"/>
                        </xsl:call-template>

                    </th>
                    <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        <td class="num_cell">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_03F/Amount"/></xsl:call-template>
                        </td>
                    </xsl:for-each>
                </tr>
            </tbody>
        </table>
        </xsl:if>

    <!-- Section 4 -->

        <xsl:if test="$section = 4">
            <span class="bold tablePaginationNrColor" >(<xsl:value-of select="ceiling(position() div $pagingLimit)" />/<xsl:value-of select="ceiling(count(../Gas) div $pagingLimit)" /> )</span>
            <table   class="tableSizeLimit table table-hover table-bordered">
                <tbody  class="boldSpan">
                    <tr class="boldHeading">
                        <th class="firstTh"><xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'sheet-transactions-header'"/>
                        </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th class="gasTh">
                                <xsl:call-template name="getGas"><xsl:with-param name="elem" select="../../ReportedGases[./GasId = current()/GasCode]/Name"/></xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <tr class="boldHeading no-wrap">
                        <th/>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th class="textCenter sidePadding">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'common'"/>
                                </xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>4A : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04a-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04A/Amount"/></xsl:call-template>
                                <br/>
                                <br/>
                                <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_04A/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th  class="padding-left-1em">
                            <span>4B : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04b-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04B/Amount"/></xsl:call-template>
                                <br/>
                                <br/>
                                <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_04B/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th  class="padding-left-2em">
                            <span>4C : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04c-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04C/Amount"/></xsl:call-template>
                                <br/>
	                            <br/>
	                            <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_04C/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th  class="padding-left-2em">
                            <span>4D : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04d-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04d-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="total">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04D/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th class="padding-left-1em">
                            <span>4E : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04e-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04e-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="total">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04E/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th>
                            <span>4F : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04f-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04F/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th  class="padding-left-1em">
                            <span>4G : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04g-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04G/Amount"/></xsl:call-template>
								<br/>
								<br/>
								<span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_04G/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th  class="padding-left-2em">
                            <span>4H : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04h-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04H/Amount"/></xsl:call-template>
								<br/>
								<br/>
								<span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_04H/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th  class="padding-left-2em">
                            <span>4I : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04i-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04i-formula'"/>
                            </xsl:call-template>
                            </span>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="total">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04I/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th  class="padding-left-1em">
                            <span>4J : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04j-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04j-formula'"/>
                            </xsl:call-template>
                            </span>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="total">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04J/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th>
                            <span>4K : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04k-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04K/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th>
                            <span>4L : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04l-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04L/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th>
                            <span>4M : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04m-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-04m-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="total">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_04M/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                </tbody>
            </table>
        </xsl:if>

    <!-- Section 5 -->

        <xsl:if test="$section = 5">
            <span class="bold tablePaginationNrColor" >(<xsl:value-of select="ceiling(position() div $pagingLimit)" />/<xsl:value-of select="ceiling(count(../Gas) div $pagingLimit)" /> )</span>
            <table  class="tableSizeLimit table table-hover table-bordered">
                <tbody  class="boldSpan">
                    <xsl:variable name="gases" select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]" />
                    <tr class="boldHeading">
                        <th class="firstTh"><xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'sheet-transactions-header'"/>
                        </xsl:call-template></th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
                        		<th class="gasTh">
	                                <xsl:call-template name="getGas"><xsl:with-param name="elem" select="../../ReportedGases[./GasId = current()/GasCode]/Name"/></xsl:call-template>
	                            </th>
                    		</xsl:if>
                        </xsl:for-each>
                    </tr>
                    <tr class="boldHeading no-wrap">
                        <th/>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <th class="textCenter sidePadding">
	                                <xsl:call-template name="getLabel">
	                                    <xsl:with-param name="labelName" select="'unit'"/>
	                                    <xsl:with-param name="labelPath" select="'common'"/>
	                                </xsl:call-template>
	                            </th>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th class="padding-left-1em">
                            <span>5A : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05a-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <td class="total">
	                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_05A/SumOfPartnerAmounts"/></xsl:call-template>
	                                <br/>
	                                <br/>
	                                <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_05A/Comment"/></xsl:call-template></span>
	                            </td>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>

                    <xsl:for-each select="../tr_05A_TradePartners/*">
                        <xsl:variable name="partnerId" select="PartnerId"/>
                        <tr>
                            <td  class="padding-left-1em tradingPartners">
                                <div><li/></div>
                                <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>

                                <br/>
                                <xsl:if test="isEUBased">
                                    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
                                </xsl:if>
                                <xsl:if test="isEUBased = 'false'">
                                    <div class="padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                        -
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                    </div>
                                </xsl:if>
                            </td>

                            <xsl:for-each select="$gases/tr_05A/TradePartner[TradePartnerID = $partnerId ]">
                            	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/../../GasCode, /FGasesReporting)" /></xsl:variable>
                        		<xsl:if test="$isHfc = true()">
	                                <td class="num_cell">
	                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="amount"/></xsl:call-template>
	                                    <br/>
	                                    <br/>
	                                    <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="Comment"/></xsl:call-template></span>
	                                </td>
                                </xsl:if>
                            </xsl:for-each>

                        </tr>
                    </xsl:for-each>
                    <tr>
                        <th class="padding-left-1em">
                            <span>5B : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05b-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <td class="total">
	                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_05B/SumOfPartnerAmounts"/></xsl:call-template>
	                                <br/>
	                                <br/>
	                                <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_05B/Comment"/></xsl:call-template></span>
	                            </td>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>

                    <xsl:for-each select="../tr_05B_TradePartners/*">
                        <xsl:variable name="partnerId" select="PartnerId"/>
                        <tr>
                            <td  class="padding-left-1em tradingPartners">
                               <div><li/></div>
                                <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>

                                <br/>
                                <xsl:if test="isEUBased">
                                    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
                                </xsl:if>
                                <xsl:if test="isEUBased = 'false'">
                                    <div class="padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                        -
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                    </div>
                                </xsl:if>

                            </td>

                            <xsl:for-each select="$gases/tr_05B/TradePartner[TradePartnerID = $partnerId ]">
                            	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/../../GasCode, /FGasesReporting)" /></xsl:variable>
                        		<xsl:if test="$isHfc = true()">
	                                <td class="num_cell">
	                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="amount"/></xsl:call-template>
	                                    <br/>
	                                    <br/>
	                                    <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="Comment"/></xsl:call-template></span>
	                                </td>
                                </xsl:if>
                            </xsl:for-each>

                        </tr>
                    </xsl:for-each>
                    <tr>
                        <th class="padding-left-1em">
                            <span>5C_exempted : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05c-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <td class="total">
	                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_05C/SumOfPartnerAmounts"/></xsl:call-template>
	                            </td>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>

                    <xsl:for-each select="../tr_05C_TradePartners/*">
                        <xsl:variable name="partnerId" select="PartnerId"/>
                        <tr>
                            <td  class="padding-left-1em tradingPartners">
                               <div><li/></div>
                                <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>

                                <br/>
                                <xsl:if test="isEUBased">
                                    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
                                </xsl:if>
                                <xsl:if test="isEUBased = 'false'">
                                    <div class="padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                        -
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                    </div>
                                </xsl:if>

                            </td>

                            <xsl:for-each select="$gases/tr_05C/TradePartner[TradePartnerID = $partnerId ]">
                            	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/../../GasCode, /FGasesReporting)" /></xsl:variable>
                        		<xsl:if test="$isHfc = true()">
	                                <td class="num_cell">
	                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="amount"/></xsl:call-template>
	                                </td>
                                </xsl:if>
                            </xsl:for-each>

                        </tr>
                    </xsl:for-each>
                    <tr>
                        <th class="padding-left-1em">
                            <span>5D : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05d-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <td class="total">
	                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_05D/SumOfPartnerAmounts"/></xsl:call-template>
	                            </td>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>
                    <xsl:for-each select="../tr_05D_TradePartners/*">
                        <xsl:variable name="partnerId" select="PartnerId"/>
                        <tr>
                            <td  class="padding-left-1em tradingPartners">
                                <div><li/></div>
                                <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>

                                <br/>
                                <xsl:if test="isEUBased">
                                    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
                                </xsl:if>
                                <xsl:if test="isEUBased = 'false'">
                                    <div class="padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                        -
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                    </div>
                                </xsl:if>

                            </td>

                            <xsl:for-each select="$gases/tr_05D/TradePartner[TradePartnerID = $partnerId ]">
                            	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/../../GasCode, /FGasesReporting)" /></xsl:variable>
                        		<xsl:if test="$isHfc = true()">
	                                <td class="num_cell">
	                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="amount"/></xsl:call-template>
	                                </td>
                                </xsl:if>
                            </xsl:for-each>

                        </tr>
                    </xsl:for-each>
                    <tr>
                        <th class="padding-left-1em">
                            <span>5E : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05e-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <td class="total">
	                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_05E/SumOfPartnerAmounts"/></xsl:call-template>
	                            </td>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>
                    <xsl:for-each select="../tr_05E_TradePartners/*">
                        <xsl:variable name="partnerId" select="PartnerId"/>
                        <tr>
                            <td  class="padding-left-1em tradingPartners">
                                <div><li/></div>
                                <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>

                                <br/>
                                <xsl:if test="isEUBased">
                                    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
                                </xsl:if>
                                <xsl:if test="isEUBased = 'false'">
                                    <div class="padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                        -
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                    </div>
                                </xsl:if>

                            </td>

                            <xsl:for-each select="$gases/tr_05E/TradePartner[TradePartnerID = $partnerId ]">
                            	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/../../GasCode, /FGasesReporting)" /></xsl:variable>
                        		<xsl:if test="$isHfc = true()">
	                                <td class="num_cell">
	                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="amount"/></xsl:call-template>
	                                </td>
                                </xsl:if>
                            </xsl:for-each>

                        </tr>
                    </xsl:for-each>
                    <tr>
                        <th class="padding-left-1em">
                            <span>5F : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05f-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <td class="total">
	                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_05F/SumOfPartnerAmounts"/></xsl:call-template>
	                            </td>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>
                    <xsl:for-each select="../tr_05F_TradePartners/*">
                        <xsl:variable name="partnerId" select="PartnerId"/>
                        <tr>
                            <td  class="padding-left-1em tradingPartners">
                               <div><li/></div>
                                <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>

                                <br/>
                                <xsl:if test="isEUBased">
                                    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
                                </xsl:if>
                                <xsl:if test="isEUBased = 'false'">
                                    <div class="padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                        -
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                    </div>
                                </xsl:if>

                            </td>

                            <xsl:for-each select="$gases/tr_05F/TradePartner[TradePartnerID = $partnerId ]">
                            	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/../../GasCode, /FGasesReporting)" /></xsl:variable>
                        		<xsl:if test="$isHfc = true()">
	                                <td class="num_cell">
	                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="amount"/></xsl:call-template>
	                                </td>
                                </xsl:if>
                            </xsl:for-each>

                        </tr>
                    </xsl:for-each>
                    <!-- 
                    <tr>
                        <th class="padding-left-1em">
                            <span>5G : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05g-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05g-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <td class="total">
	                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_05G/Amount"/></xsl:call-template>
	                            </td>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>
                     -->
                    <tr>
                        <th class="padding-left-1em">
                            <span>5H : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05h-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05h-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <td class="total">
	                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_05H/Amount"/></xsl:call-template>
	                            </td>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th class="padding-left-1em">
                            <span>5I : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05i-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05i-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <td class="total">
	                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_05I/Amount"/></xsl:call-template>
	                            </td>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th class="padding-left-1em">
                            <span>5J : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05j-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05j-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <td class="total">
	                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_05J/Amount"/></xsl:call-template>
	                            </td>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>

                    <tr>
                        <th>
                            <span>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'voluntary-reporting'"/>
                                    <xsl:with-param name="labelPath" select="'sheet2'"/>
                                </xsl:call-template>

                            </span>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
                            	<td/>
                        	</xsl:if>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th class="padding-left-1em">
                            <span>5C_voluntary : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-05r-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
	                            <td class="total">
	                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_05R/SumOfPartnerAmounts"/></xsl:call-template>
	                            </td>
                            </xsl:if>
                        </xsl:for-each>
                    </tr>
                    <xsl:for-each select="../tr_05R_TradePartners/*">
                        <xsl:variable name="partnerId" select="PartnerId"/>
                        <tr>
                            <td  class="padding-left-1em tradingPartners">
                                <div><li/></div>
                                <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>

                                <br/>
                                <xsl:if test="isEUBased">
                                    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
                                </xsl:if>
                                <xsl:if test="isEUBased = 'false'">
                                    <div class="padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                        -
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                    </div>
                                </xsl:if>

                            </td>
                            <xsl:for-each select="$gases/tr_05R/TradePartner[TradePartnerID = $partnerId ]">
                            	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/../../GasCode, /FGasesReporting)" /></xsl:variable>
                        		<xsl:if test="$isHfc = true()">
	                                <td class="num_cell">
	                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="amount"/></xsl:call-template>
	                                </td>
                                </xsl:if>
                            </xsl:for-each>

                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </xsl:if>

    <!-- Section 6 -->

        <xsl:if test="$section = 6">
            <span class="bold tablePaginationNrColor" >(<xsl:value-of select="ceiling(position() div $pagingLimit)" />/<xsl:value-of select="ceiling(count(../Gas) div $pagingLimit)" /> )</span>
            <table   class="tableSizeLimit table table-hover table-bordered">
                <tbody  class="boldSpan">
                    <tr class="boldHeading">
                        <th class="firstTh"><xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'sheet-transactions-header'"/>
                        </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th class="gasTh">
                                <xsl:call-template name="getGas"><xsl:with-param name="elem" select="../../ReportedGases[./GasId = current()/GasCode]/Name"/></xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <tr class="boldHeading no-wrap">
                        <th/>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th class="textCenter sidePadding">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'common'"/>
                                </xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6A : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06a-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06A/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th  class="padding-left-1em">
                            <span>6B : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06b-desc'"/>
                            </xsl:call-template>

                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06B/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6C : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06c-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06C/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6D : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06d-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06D/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6E : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06e-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06E/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6F : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06f-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06F/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6G : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06g-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06G/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6H : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06h-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06H/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6I : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06i-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06I/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6J : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06j-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06J/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6K : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06k-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06K/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6L : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06l-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06L/Amount"/></xsl:call-template>
                                <br/>
	                            <br/>
	                            <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_06L/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6K : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06k-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06K/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6L : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06l-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06L/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6M : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06m-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06M/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6N : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06n-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06N/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6O : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06o-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06O/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6P : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06p-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06P/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6Q : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06q-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06Q/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6R : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06r-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06R/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6S : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06s-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06S/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6T : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06t-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06T/Amount"/></xsl:call-template>
                                <br/>
                                <br/>
                                <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_06T/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6U : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06u-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06U/Amount"/></xsl:call-template>
                                <br/>
                                <br/>
                                <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_06U/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6V : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06v-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06V/Amount"/></xsl:call-template>
                                <br/>
                                <br/>
                                <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_06V/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6W : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06w-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06w-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="total">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06W/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>6X : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06x-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-06x-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="total">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_06X/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                </tbody>
            </table>
        </xsl:if>


    <!-- Section 7 -->

        <xsl:if test="$section = 7">
            <span class="bold tablePaginationNrColor" >(<xsl:value-of select="ceiling(position() div $pagingLimit)" />/<xsl:value-of select="ceiling(count(../Gas) div $pagingLimit)" /> )</span>
            <table   class="tableSizeLimit table table-hover table-bordered">
                <tbody  class="boldSpan">
                    <tr class="boldHeading">
                        <th class="firstTh"><xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'sheet-transactions-header'"/>
                        </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th class="gasTh">
                                <xsl:call-template name="getGas"><xsl:with-param name="elem" select="../../ReportedGases[./GasId = current()/GasCode]/Name"/></xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <tr class="boldHeading no-wrap">
                        <th/>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th  class="textCenter sidePadding">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'common'"/>
                                </xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>7A : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-07a-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_07A/Amount"/></xsl:call-template>
                                <br/>
	                            <br/>
	                            <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_07A/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                </tbody>
            </table>
        </xsl:if>

    <!-- Section 8 -->

        <xsl:if test="$section = 8">
            <span class="bold tablePaginationNrColor" >(<xsl:value-of select="ceiling(position() div $pagingLimit)" />/<xsl:value-of select="ceiling(count(../Gas) div $pagingLimit)" /> )</span>
            <table style="width: 33em;"  class="table table-hover table-bordered">
                <tbody  class="boldSpan">
                    <tr class="boldHeading">
                        <th class="firstTh"><xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'sheet-transactions-header'"/>
                        </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th class="gasTh">
                                <xsl:call-template name="getGas"><xsl:with-param name="elem" select="../../ReportedGases[./GasId = current()/GasCode]/Name"/></xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <tr class="boldHeading no-wrap">
                        <th/>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th  class="textCenter sidePadding">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'common'"/>
                                </xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>8A : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-08a-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_08A/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>8B : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-08b-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_08B/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>8C : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-08c-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_08C/Amount"/></xsl:call-template>
                                <br/>
                                <br/>
                                <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_08C/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>8D : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-08d-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-08d-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="total">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_08D/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>8E : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-08e-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_08E/Amount"/></xsl:call-template>
                                <br/>
                                <br/>
                                <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="tr_08E/Comment"/></xsl:call-template></span>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <th >
                            <span>8F : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-08f-desc'"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="num_cell">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_08F/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                </tbody>
            </table>
        </xsl:if>

    <!-- Section 11 -->

        <xsl:if test="$section = 11">

        <xsl:if test="(count((../UISelectedTransactions/child::*[. = 'true']) ) > 0)">
            <span class="bold tablePaginationNrColor" >(<xsl:value-of select="ceiling(position() div $pagingLimit)" />/<xsl:value-of select="ceiling(count(../Gas) div $pagingLimit)" /> )</span>
            <table  class="tdColorBlack tableSizeLimit table table-hover table-bordered section11-table">
                <tbody  class="boldSpan">
                    <tr class="hidden">
                        <td class="section11Code"/>
                        <td class="section11Code"/>

                        <td class="" style="width: 2em;"/>
                        <td class="section11Explanation"/>

                        <td class="section11Amount"/>

                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class=""/>
                        </xsl:for-each>
                    </tr>
                    <tr class="boldHeading">
                        <th rowspan="2" colspan="3" class=""><xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'code_and_reporting_parameter'"/>
                        </xsl:call-template>
                        </th>
                        <th rowspan="2" class=""><xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'reporter_specify_category'"/>
                        </xsl:call-template>
                        </th>
                        <th rowspan="2" class=" "><xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'amount_of_importer_equipment'"/>
                        </xsl:call-template>
                        </th>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th class="gasTh">
                                <xsl:call-template name="getGas"><xsl:with-param name="elem" select="../../ReportedGases[./GasId = current()/GasCode]/Name"/></xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <tr class="boldHeading no-wrap">
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <th  class="textCenter sidePadding">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'common'"/>
                                </xsl:call-template>
                            </th>
                        </xsl:for-each>
                    </tr>
                    <xsl:if test="count((../UISelectedTransactions/child::*[substring(name(.),1,6) = 'tr_11A' and . = 'true']) ) > 0">
                        <tr>
                            <td class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="3">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a'"/>
                                </xsl:call-template>
                                <br/><span class="formula">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'formula'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a'"/>
                                </xsl:call-template>
                                </span>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue total"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A/Amount"/></xsl:call-template> </div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit_for_amount'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue total">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A01= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a1'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a1'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A01/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a1'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A01/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A01/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em fontNormal">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a1'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A01) > 0">
                                    <br/>
                                    <br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A01"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A02= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a2'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a2'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A02/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a2'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A02/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A02/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em fontNormal">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a2'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A02) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A02"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A03= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a3'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a3'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11A03) > 0">
                                    <span class="bold padding-right-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11A03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A03/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a3'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A03/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A03/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a3'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A03) > 0">
                                    <br/> <br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A04= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a4'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a4'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A04/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a4'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A04/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A04/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a4'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A04) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A04"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A05= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a5'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a5'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A05/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a5'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A05/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A05/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a5'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A05) > 0">
                                    <br/> <br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A05"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A06= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a6'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a6'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A06/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a6'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A06/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A06/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a6'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A06) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A06"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A07= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a7'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a7'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A07/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a7'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A07/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A07/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a7'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A07) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A07"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A08= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a8'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a8'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A08/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a8'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A08/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A08/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a8'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A08) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A08"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A09= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a9'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a9'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11A09) > 0">
                                    <span class="bold padding-right-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11A09"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A09/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a9'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A09/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A09/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a9'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A09) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A09"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A10= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a10'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a10'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A10/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a10'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A10/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A10/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a10'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A10) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A10"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A11= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a11'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a11'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A11/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a11'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A11/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A11/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a11'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A11) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A11"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A12= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a12'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a12'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11A12) > 0">
                                    <span class="bold padding-right-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11A12"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A12/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a12'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A12/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A12/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a12'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A12) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A12"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>

                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A13= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a13'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a13'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A13/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a11'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A13/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A13/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a13'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A13) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A13"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11A14= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a14'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a14'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11A14/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11a14'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11A14/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11A14/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11a14'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11A14) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11A14"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <!-- B --><xsl:if test="count((../UISelectedTransactions/child::*[substring(name(.),1,6) = 'tr_11B' and . = 'true']) ) > 0">
                    <tr>
                        <td  class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11b'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11b'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'formula'"/>
                                <xsl:with-param name="labelPath" select="'tr_11b'"/>
                            </xsl:call-template>
                            </span>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue total"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B/Amount"/></xsl:call-template> </div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit_for_amount'"/>
                                <xsl:with-param name="labelPath" select="'tr_11b'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue total" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B01= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b1'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b1'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B01/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b1'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B01/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B01/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b1'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B01) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B01"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B02= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b2'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b2'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B02/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b2'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B02/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B02/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b2'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B02) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B02"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B03= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b3'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b3'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11B03) > 0">
                                    <span class="bold padding-right-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11B03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B03/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b3'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B03/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B03/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b3'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B03) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B04= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b4'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b4'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B04/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b4'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B04/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B04/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b4'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B04) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B04"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B05= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b5'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b5'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11B05) > 0">
                                    <span class="bold padding-right-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11B05"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B05/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b5'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B05/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B05/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b5'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B05) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B05"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B06= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b6'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b6'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B06/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b6'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B06/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B06/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b6'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B06) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B06"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B07= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b7'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b7'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11B07) > 0">
                                    <span class="bold padding-right-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11B07"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B07/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b7'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B07/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B07/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b7'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B07) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B07"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B08= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b8'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b8'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B08/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b8'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B08/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B08/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b8'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B08) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B08"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B09= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b9'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b9'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11A09) > 0">
                                    <span class="bold padding-right-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11B09"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B09/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b9'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B09/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B09/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b9'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B09) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B09"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B10= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b10'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b10'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B10/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b10'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B10/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B10/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b10'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B10) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B10"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B11= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b11'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b11'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B11/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b11'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B11/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B11/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b11'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B11) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B11"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B12= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b12'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b12'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B12/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b12'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B12/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B12/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b12'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B12) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B12"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B13= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b13'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b13'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B13/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b13'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B13/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B13/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b13'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B13) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B13"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11B14= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b14'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b14'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11B14/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11b14'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11B14/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11B14/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11b14'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11B14) > 0">
                                    <br/><br/>
                                    <span class="bold">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11B14"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <!-- C --><xsl:if test="../UISelectedTransactions/tr_11C= 'true'">
                    <tr>
                        <td rowspan="2" class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11c'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11c'"/>
                            </xsl:call-template>
                        </td>

                        <td>
                            <span class="padding-right-1em tdColorBlue num_cell" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11C/Amount"/></xsl:call-template>
                            </span>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit'"/>
                                <xsl:with-param name="labelPath" select="'tr_11c'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue num_cell" rowspan="2" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11C/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <span class="bold padding-right-1em" >
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'s2'"/>
                                </xsl:call-template>
                            </span>
                            <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11C/Amount"/></xsl:call-template></span>
                            <span class="padding-left-1em">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11c'"/>
                                </xsl:call-template>
                            </span>
                            <xsl:if test="string-length(../Comment/tr_11C) > 0">
                                <br/><br/>
                                <span class="bold">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                        <xsl:with-param name="labelPath" select="'form7'"/>
                                    </xsl:call-template>:
                                </span>
                                <br/>
                                <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11C"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:if>

                    <!-- D --><xsl:if test="count((../UISelectedTransactions/child::*[substring(name(.),1,6) = 'tr_11D' and . = 'true']) ) > 0">
                    <tr>
                        <td  class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11d'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11d'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'formula'"/>
                                <xsl:with-param name="labelPath" select="'tr_11d'"/>
                            </xsl:call-template>
                            </span>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue total"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11D/Amount"/></xsl:call-template> </div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit_for_amount'"/>
                                <xsl:with-param name="labelPath" select="'tr_11d'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue total" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11D/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11D01= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11d1'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11d1'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11D01) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11D01"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11D01/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11d1'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11D01/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11D01/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11d1'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11D01) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11D01"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11D02= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11d2'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11d2'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11D02) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11D02"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11D02/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11d2'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11D02/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11D02/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11d2'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11D02) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11D02"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11D03= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11d3'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11d3'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11D03) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11D03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11D03/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11d3'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11D03/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11D03/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11d3'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11D03) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11D03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <!-- E --><xsl:if test="count((../UISelectedTransactions/child::*[substring(name(.),1,6) = 'tr_11E' and . = 'true']) ) > 0">
                    <tr>
                        <td  class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11e'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11e'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'formula'"/>
                                <xsl:with-param name="labelPath" select="'tr_11e'"/>
                            </xsl:call-template>
                            </span>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue total"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11E/Amount"/></xsl:call-template> </div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit_for_amount'"/>
                                <xsl:with-param name="labelPath" select="'tr_11e'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue total" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11E/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11E01= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e1'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e1'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11E01) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11E01"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11E01/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e1'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11E01/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11E01/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11e1'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11E01) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11E01"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11E02= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e2'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e2'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11E02) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11E02"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11E02/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e2'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11E02/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11E02/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11e2'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11E02) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11E02"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11E03= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e3'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e3'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11E03) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11E03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11E03/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e3'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11E03/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11E03/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11e3'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11E03) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11E03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11E04= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e4'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e4'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11E04) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11E04"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11E04/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11e4'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11E04/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11E04/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11e4'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11E04) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11E04"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <!-- F --><xsl:if test="count((../UISelectedTransactions/child::*[substring(name(.),1,6) = 'tr_11F' and . = 'true']) ) > 0">
                    <tr>
                        <td  class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11f'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11f'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'formula'"/>
                                <xsl:with-param name="labelPath" select="'tr_11f'"/>
                            </xsl:call-template>
                            </span>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue total"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11F/Amount"/></xsl:call-template> </div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit_for_amount'"/>
                                <xsl:with-param name="labelPath" select="'tr_11f'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue total" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11F/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11F01= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f1'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f1'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11F01) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11F01"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11F01/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f1'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11F01/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11F01/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11f1'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11F01) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11F01"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11F02= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f2'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f2'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11F02) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11F02"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11F02/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f2'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11F02/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11F02/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11f2'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11F02) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11F02"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11F03= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f3'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f3'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11F03) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11F03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11F03/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f3'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11F03/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11F03/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11f3'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11F03) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11F03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11F04= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f4'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f4'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11F04) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11F04"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11F04/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f4'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11F04/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11F04/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11f4'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11F04) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11F04"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11F05= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f5'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f5'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11F05) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11F05"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11F05/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f5'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11F05/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11F05/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11f5'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11F05) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11F05"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11F06= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f6'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f6'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11F06) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11F06"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11F06/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f6'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11F06/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11F06/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11f6'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11F06) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11F06"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11F07= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f7'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f7'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11F07) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11F07"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11F07/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f7'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11F07/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11F07/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11f7'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11F07) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11F07"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11F08= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f8'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f8'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11F08) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11F08"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11F08/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f8'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11F08/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11F08/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11f8'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11F08) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11F08"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11F09= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f9'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f9'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11F09) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11F09"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11F09/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11f9'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11F09/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11F09/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11f9'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11F09) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11F09"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <!-- G -->
                    <xsl:variable name="trG" select="count((../UISelectedTransactions/child::*[(substring(name(.),1,6) = 'tr_11A' or substring(name(.),1,6) = 'tr_11B' or substring(name(.),1,6) = 'tr_11C' or substring(name(.),1,6) = 'tr_11D' or substring(name(.),1,6) = 'tr_11E' or substring(name(.),1,6) = 'tr_11F')  and . = 'true']) ) > 0"/>
                    <xsl:if test="$trG">
                    <tr>
                        <td  class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11g'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11g'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'formula'"/>
                                <xsl:with-param name="labelPath" select="'tr_11g'"/>
                            </xsl:call-template>
                            </span>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue total"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11G/Amount"/></xsl:call-template> </div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit_for_amount'"/>
                                <xsl:with-param name="labelPath" select="'tr_11g'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue total" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11G/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    </xsl:if>
                    <!-- H --><xsl:if test="count((../UISelectedTransactions/child::*[substring(name(.),1,7) = 'tr_11H0' and . = 'true']) ) > 0">
                    <tr>
                        <td  class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11h'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11h'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'formula'"/>
                                <xsl:with-param name="labelPath" select="'tr_11h'"/>
                            </xsl:call-template>
                            </span>
                        </td>
                        <td>

                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue total" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11H/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11H01= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11h1'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11h1'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11H01) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11H01"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11H01/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11h1'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11H01/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11H01/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11h1'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11H01) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11H01"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11H02= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11h2'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11h2'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11H02) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11H02"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11H02/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11h2'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11H02/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11H02/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11h2'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11H02) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11H02"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11H03= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11h3'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11h3'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11H03) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11H03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11H03/Amount"/></xsl:call-template></div>
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11h3'"/>
                                </xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11H03/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11H03/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11h3'"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11H03) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11H03"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="../UISelectedTransactions/tr_11H04= 'true'">
                        <tr>
                            <td  rowspan="2"/>
                            <td rowspan="2" class="code">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'code'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11h4'"/>
                                </xsl:call-template>
                            </td>
                            <td colspan="2">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'parameter'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11h4'"/>
                                </xsl:call-template>
                                <xsl:if test="string-length(../Category/tr_11H04) > 0">
                                    <span class="bold padding-right-1em padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'please_specify'"/>
                                        </xsl:call-template>:
                                    </span>
									<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11H04"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                            <td>
                                <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11H04/Amount"/></xsl:call-template></div>
								<xsl:variable name="unitName" select="../TR_11H4_Unit"/>
								<xsl:call-template name="getUnit">
									<xsl:with-param name="unit" select="$unitName"/>
								</xsl:call-template>
                            </td>
                            <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                                <td class="tdColorBlue num_cell" rowspan="2">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11H04/Amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <span class="bold padding-right-1em" >
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'s2'"/>
                                    </xsl:call-template>
                                </span>
                                <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11H04/Amount"/></xsl:call-template></span>
                                <span class="padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                        <xsl:with-param name="labelPath" select="'tr_11h4'"/>
                                    </xsl:call-template>
									<xsl:choose>
										<xsl:when test="../TR_11H4_Unit = 'pieces'">piece</xsl:when>
										<xsl:when test="../TR_11H4_Unit = 'cubicmetres'">cubic metre</xsl:when>
										<xsl:when test="../TR_11H4_Unit = 'metrictonnes'">metric tonne</xsl:when>
									</xsl:choose>
                                </span>
                                <xsl:if test="string-length(../Comment/tr_11H04) > 0">
                                    <br/><br/>
                                    <span class="bold ">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                            <xsl:with-param name="labelPath" select="'form7'"/>
                                        </xsl:call-template>:
                                    </span>
                                    <br/>
                                    <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11H04"/></xsl:call-template></div>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:if>
                    <!-- I --><xsl:if test="../UISelectedTransactions/tr_11I= 'true'">
                    <tr>

                        <td rowspan="2" class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11i'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11i'"/>
                            </xsl:call-template>
                            <xsl:if test="string-length(../Category/tr_11I) > 0">
                                <span class="bold padding-right-1em padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'please_specify'"/>
                                    </xsl:call-template>:
                                </span>
								<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11I"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11I/Amount"/></xsl:call-template></div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit'"/>
                                <xsl:with-param name="labelPath" select="'tr_11i'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue num_cell" rowspan="2" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11I/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <span class="bold padding-right-1em" >
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'s2'"/>
                                </xsl:call-template>
                            </span>
                            <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11I/Amount"/></xsl:call-template></span>
                            <span class="padding-left-1em">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11i'"/>
                                </xsl:call-template>
                            </span>
                            <xsl:if test="string-length(../Comment/tr_11I) > 0">
                                <br/><br/>
                                <span class="bold ">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                        <xsl:with-param name="labelPath" select="'form7'"/>
                                    </xsl:call-template>:
                                </span>
                                <br/>
                                <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11I"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:if>
                    <!-- J --><xsl:if test="../UISelectedTransactions/tr_11J= 'true'">
                    <tr>

                        <td rowspan="2" class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11j'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11j'"/>
                            </xsl:call-template>
                            <xsl:if test="string-length(../Category/tr_11J) > 0">
                                <span class="bold padding-right-1em padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'please_specify'"/>
                                    </xsl:call-template>:
                                </span>
								<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11J"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11J/Amount"/></xsl:call-template></div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit'"/>
                                <xsl:with-param name="labelPath" select="'tr_11j'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue num_cell" rowspan="2" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11J/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <span class="bold padding-right-1em" >
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'s2'"/>
                                </xsl:call-template>
                            </span>
                            <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11J/Amount"/></xsl:call-template></span>
                            <span class="padding-left-1em">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11j'"/>
                                </xsl:call-template>
                            </span>
                            <xsl:if test="string-length(../Comment/tr_11J) > 0">
                                <br/><br/>
                                <span class="bold ">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                        <xsl:with-param name="labelPath" select="'form7'"/>
                                    </xsl:call-template>:
                                </span>
                                <br/>
                                <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11J"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:if>
                    <!-- K --><xsl:if test="../UISelectedTransactions/tr_11K= 'true'">
                    <tr>

                        <td rowspan="2" class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11k'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11k'"/>
                            </xsl:call-template>
                            <xsl:if test="string-length(../Category/tr_11K) > 0">
                                <span class="bold padding-right-1em padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'please_specify'"/>
                                    </xsl:call-template>:
                                </span>
								<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11K"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11K/Amount"/></xsl:call-template></div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit'"/>
                                <xsl:with-param name="labelPath" select="'tr_11k'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue num_cell" rowspan="2">
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11K/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <span class="bold padding-right-1em" >
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'s2'"/>
                                </xsl:call-template>
                            </span>
                            <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11K/Amount"/></xsl:call-template></span>
                            <span class="padding-left-1em">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11k'"/>
                                </xsl:call-template>
                            </span>
                            <xsl:if test="string-length(../Comment/tr_11K) > 0">
                                <br/><br/>
                                <span class="bold ">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                        <xsl:with-param name="labelPath" select="'form7'"/>
                                    </xsl:call-template>:
                                </span>
                                <br/>
                                <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11K"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:if>
                    <!-- L --><xsl:if test="../UISelectedTransactions/tr_11L= 'true'">
                    <tr>

                        <td rowspan="2" class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11l'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11l'"/>
                            </xsl:call-template>
                            <xsl:if test="string-length(../Category/tr_11L) > 0">
                                <span class="bold padding-right-1em padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'please_specify'"/>
                                    </xsl:call-template>:
                                </span>
								<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11L"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11L/Amount"/></xsl:call-template></div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit'"/>
                                <xsl:with-param name="labelPath" select="'tr_11l'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue num_cell" rowspan="2" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11L/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <span class="bold padding-right-1em" >
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'s2'"/>
                                </xsl:call-template>
                            </span>
                            <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11L/Amount"/></xsl:call-template></span>
                            <span class="padding-left-1em">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11l'"/>
                                </xsl:call-template>
                            </span>
                            <xsl:if test="string-length(../Comment/tr_11L) > 0">
                                <br/><br/>
                                <span class="bold ">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                        <xsl:with-param name="labelPath" select="'form7'"/>
                                    </xsl:call-template>:
                                </span>
                                <br/>
                                <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11L"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:if>
                    <!-- M --><xsl:if test="../UISelectedTransactions/tr_11M= 'true'">
                    <tr>

                        <td rowspan="2" class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11m'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11m'"/>
                            </xsl:call-template>
                            <xsl:if test="string-length(../Category/tr_11M) > 0">
                                <span class="bold padding-right-1em padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'please_specify'"/>
                                    </xsl:call-template>:
                                </span>
								<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11M"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11M/Amount"/></xsl:call-template></div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit'"/>
                                <xsl:with-param name="labelPath" select="'tr_11m'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue num_cell" rowspan="2" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11M/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <span class="bold padding-right-1em" >
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'s2'"/>
                                </xsl:call-template>
                            </span>
                            <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11M/Amount"/></xsl:call-template></span>
                            <span class="padding-left-1em">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11m'"/>
                                </xsl:call-template>
                            </span>
                            <xsl:if test="string-length(../Comment/tr_11M) > 0">
                                <br/><br/>
                                <span class="bold ">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                        <xsl:with-param name="labelPath" select="'form7'"/>
                                    </xsl:call-template>:
                                </span>
                                <br/>
                                <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11M"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:if>
                    <!-- N --><xsl:if test="../UISelectedTransactions/tr_11N= 'true'">
                    <tr>

                        <td rowspan="2" class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11n'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11n'"/>
                            </xsl:call-template>
                            <xsl:if test="string-length(../Category/tr_11N) > 0">
                                <span class="bold padding-right-1em padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'please_specify'"/>
                                    </xsl:call-template>:
                                </span>
								<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11N"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11N/Amount"/></xsl:call-template></div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit'"/>
                                <xsl:with-param name="labelPath" select="'tr_11n'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue num_cell" rowspan="2" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11N/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <span class="bold padding-right-1em" >
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'s2'"/>
                                </xsl:call-template>
                            </span>
                            <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11N/Amount"/></xsl:call-template></span>
                            <span class="padding-left-1em">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11n'"/>
                                </xsl:call-template>
                            </span>
                            <xsl:if test="string-length(../Comment/tr_11N) > 0">
                                <br/><br/>
                                <span class="bold ">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                        <xsl:with-param name="labelPath" select="'form7'"/>
                                    </xsl:call-template>:
                                </span>
                                <br/>
                                <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11N"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:if>
                    <!-- O --><xsl:if test="../UISelectedTransactions/tr_11O= 'true'">
                    <tr>

                        <td rowspan="2" class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11o'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11o'"/>
                            </xsl:call-template>
                            <xsl:if test="string-length(../Category/tr_11O) > 0">
                                <span class="bold padding-right-1em padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'please_specify'"/>
                                    </xsl:call-template>:
                                </span>
								<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11O"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11O/Amount"/></xsl:call-template></div>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit'"/>
                                <xsl:with-param name="labelPath" select="'tr_11o'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue num_cell" rowspan="2" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11O/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <span class="bold padding-right-1em" >
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'s2'"/>
                                </xsl:call-template>
                            </span>
                            <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11O/Amount"/></xsl:call-template></span>
                            <span class="padding-left-1em">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11o'"/>
                                </xsl:call-template>
                            </span>
                            <xsl:if test="string-length(../Comment/tr_11O) > 0">
                                <br/><br/>
                                <span class="bold ">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                        <xsl:with-param name="labelPath" select="'form7'"/>
                                    </xsl:call-template>:
                                </span>
                                <br/>
                                <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11O"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:if>
                    <!-- P --><xsl:if test="../UISelectedTransactions/tr_11P= 'true'">
                    <tr>

                        <td rowspan="2" class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11p'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="3">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11p'"/>
                            </xsl:call-template>
                            <xsl:if test="string-length(../Category/tr_11P) > 0">
                                <span class="bold padding-right-1em padding-left-1em">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'please_specify'"/>
                                    </xsl:call-template>:
                                </span>
								<div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Category/tr_11P"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                        <td>
                            <div class="padding-right-1em tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../AmountOfImportedEquipment/tr_11P/Amount"/></xsl:call-template></div>

                            <xsl:variable name="unitName2" select="../TR_11P_Unit"/>
							<xsl:call-template name="getUnit">
								<xsl:with-param name="unit" select="$unitName2"/>
							</xsl:call-template>


                        </td>
                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue num_cell" rowspan="2" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11P/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <span class="bold padding-right-1em" >
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'s2'"/>
                                </xsl:call-template>
                            </span>
                            <span class="tdColorBlue num_cell"><xsl:call-template name="formatValue"><xsl:with-param name="num" select="../SumOfAllGasesS2/tr_11P/Amount"/></xsl:call-template></span>
                            <span class="padding-left-1em">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'unit_of_spec_charge'"/>
                                    <xsl:with-param name="labelPath" select="'tr_11p'"/>
                                </xsl:call-template>
                            </span>
							<xsl:choose>
								<xsl:when test="../TR_11P_Unit = 'pieces'">piece</xsl:when>
								<xsl:when test="../TR_11P_Unit = 'cubicmetres'">cubic metre</xsl:when>
								<xsl:when test="../TR_11P_Unit = 'metrictonnes'">metric tonne</xsl:when>
							</xsl:choose>
                            <xsl:if test="string-length(../Comment/tr_11P) > 0">
                                <br/><br/>
                                <span class="bold ">
                                    <xsl:call-template name="getLabel">
                                        <xsl:with-param name="labelName" select="'obligatory_comment'"/>
                                        <xsl:with-param name="labelPath" select="'form7'"/>
                                    </xsl:call-template>:
                                </span>
                                <br/>
                                <div class="tdColorBlue"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="../Comment/tr_11P"/></xsl:call-template></div>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:if>
                    <!-- Q -->
                    <xsl:if test="$trG or (count((../UISelectedTransactions/child::*[(substring(name(.),1,7) = 'tr_11H0' or substring(name(.),1,6) = 'tr_11I' or substring(name(.),1,6) = 'tr_11J' or substring(name(.),1,6) = 'tr_11K' or substring(name(.),1,6) = 'tr_11L' or substring(name(.),1,6) = 'tr_11M' or substring(name(.),1,6) = 'tr_11N' or substring(name(.),1,6) = 'tr_11O' or substring(name(.),1,6) = 'tr_11P') and . = 'true']) ) > 0)">
                    <tr>
                        <td  class="code">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'code'"/>
                                <xsl:with-param name="labelPath" select="'tr_11q'"/>
                            </xsl:call-template>
                        </td>
                        <td colspan="4">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'parameter'"/>
                                <xsl:with-param name="labelPath" select="'tr_11q'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'formula'"/>
                                <xsl:with-param name="labelPath" select="'tr_11q'"/>
                            </xsl:call-template>
                            </span>
                        </td>

                        <xsl:for-each select=".|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                            <td class="tdColorBlue total" >
                                <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_11Q/Amount"/></xsl:call-template>
                            </td>
                        </xsl:for-each>
                    </tr>
                    </xsl:if>
                </tbody>
            </table>
        </xsl:if>
        </xsl:if>

    </xsl:template>


<!-- ###################################################### Tables full content ######################################################################## -->

    <xsl:template match="F1_S1_4_ProdImpExp">
            <xsl:if test="../GeneralReportData/Activities/*[substring(name(.),1,1) = ('P' , 'I') ] = 'true'" >
                    <h2>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'section1-heading'"/>
                        </xsl:call-template>
                    </h2>
                    <xsl:call-template name="tablePaging1"/>
            </xsl:if>

            <xsl:if test="../GeneralReportData/Activities/I-HFC = 'true'
                    or ../GeneralReportData/Activities/I-other = 'true'  ">
                    <h2>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'section2-heading'"/>
                        </xsl:call-template>
                    </h2>
                    <xsl:call-template name="tablePaging2"/>
            </xsl:if>

            <xsl:if test=" ../GeneralReportData/Activities/E = 'true'">
                    <h2>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'section3-heading'"/>
                        </xsl:call-template>
                    </h2>
                    <xsl:call-template name="tablePaging3"/>
            </xsl:if>

            <xsl:if test="../GeneralReportData/Activities/*[substring(name(.),1,1) = 'P'] = 'true'
                            or ../GeneralReportData/Activities/I = 'true'  ">
                    <h2>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'section4-heading'"/>
                        </xsl:call-template>
                    </h2>
                    <xsl:call-template name="tablePaging4"/>
            </xsl:if>
    </xsl:template>

    <xsl:template match="F2_S5_exempted_HFCs">
        <xsl:if test="../GeneralReportData/Activities/P-HFC = 'true'  or ../GeneralReportData/Activities/I-HFC = 'true' ">
            <h2>
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'section5-heading'"/>
                </xsl:call-template>
            </h2>
            <xsl:call-template name="tablePaging5"/>
    <table style="border: 0 !important;">
        <tbody>
            <h2>
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'documents'"/>
                    <xsl:with-param name="labelPath" select="'sheet2'"/>
                </xsl:call-template>
            </h2>
            <tr>
                <xsl:if test="string-length(SupportingDocuments/Document/Url) = 0">
                    <td style="border: 0 !important;">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'no-documents'"/>
                        </xsl:call-template>
                    </td>
                </xsl:if>
                <xsl:if test="string-length(SupportingDocuments/Document[1]/Url) > 0">
                    <td style="border: 0 !important;">
                        <xsl:for-each select="SupportingDocuments/Document">
                            <li>
                                <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Url"/></xsl:call-template>
                            </li>
                        </xsl:for-each>
                    </td>
                </xsl:if>
            </tr>
        </tbody>
        </table>
        </xsl:if>

    </xsl:template>
    <xsl:template match="F3A_S6A_IA_HFCs">
        <xsl:if test="../GeneralReportData/Activities/P-HFC = 'true' or ../GeneralReportData/Activities/P-other = 'true'  or ../GeneralReportData/Activities/I-HFC = 'true'  or ../GeneralReportData/Activities/I-other = 'true'">
            <h2>
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'section6-heading'"/>
                </xsl:call-template>
            </h2>
            <xsl:call-template name="tablePaging6"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="F4_S9_IssuedAuthQuata">
        <xsl:if test="../GeneralReportData/Activities/P-HFC = 'true'  or ../GeneralReportData/Activities/I-HFC = 'true' or ../GeneralReportData/Activities/auth = 'true'">
            <h2>
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'section9-heading'"/>
                </xsl:call-template>
            </h2>
            <table class="tableSizeLimit table table-hover table-bordered">
                <tbody  class="boldSpan">
                    <tr class="boldHeading">
                        <th class="firstTh">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'sheet-transactions-header'"/>
                            </xsl:call-template>
                        </th>
                        <th class="gasTh">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'amount-of-hfcs'"/>
                            </xsl:call-template>
                        </th>

                    </tr>
                    <tr class="boldHeading no-wrap">
                        <th/>

                        <th>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'unit-co2eq'"/>
                                <xsl:with-param name="labelPath" select="'common'"/>
                            </xsl:call-template>
                        </th>

                    </tr>

                    <tr>
                        <th>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09a-head'"/>
                            </xsl:call-template>
                        <br/>
                        <xsl:variable name="tr-09a-desc-tail">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09a-desc-tail'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <i><xsl:value-of select="replace(string($tr-09a-desc-tail), '\{\{ date \}\}', string(tr_09A_Registry/Comment) )"/></i>
                    </th>
                        <td/>
                    </tr>

                    <tr>
                        <th class="padding-left-1em">
                            <span>9A_imp : </span>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09a_imp-desc'"/>
                            </xsl:call-template>

                        </th>

                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_09A_imp/SumOfPartnerAmounts"/></xsl:call-template>
                        </td>
                    </tr>
                    <xsl:for-each select="tr_09A_imp_TradePartners/*">
                        <xsl:variable name="partnerId" select="PartnerId"/>
                        <tr>
                            <td  class="padding-left-1em tradingPartners">
                                <div><li/></div>
                                <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>

                                <br/>
                                <xsl:if test="isEUBased">
                                    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
                                </xsl:if>
                                <xsl:if test="isEUBased = 'false'">
                                    <div class="padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                        -
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                    </div>
                                </xsl:if>

                            </td>
                            <xsl:for-each select="../../tr_09A_imp/TradePartner[TradePartnerID = $partnerId]">
                                <td class="num_cell">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>

                        </tr>
                    </xsl:for-each>

                    <tr>
                        <th class="padding-left-1em">
                            <span>9A_add : </span>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09a_add-desc'"/>
                            </xsl:call-template>

                        </th>

                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_09A_add/SumOfPartnerAmounts"/></xsl:call-template>
                        </td>
                    </tr>
                    <xsl:for-each select="tr_09A_add_TradePartners/*">
                        <xsl:variable name="partnerId" select="PartnerId"/>
                        <tr>
                            <td  class="padding-left-1em tradingPartners">
                                <div><li/></div>
                                <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>

                                <br/>
                                <xsl:if test="isEUBased">
                                    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
                                </xsl:if>
                                <xsl:if test="isEUBased = 'false'">
                                    <div class="padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                        -
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                    </div>
                                </xsl:if>

                            </td>
                            <xsl:for-each select="../../tr_09A_add/TradePartner[TradePartnerID = $partnerId]">
                                <td class="num_cell">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="amount"/></xsl:call-template>
                                    <br/>
                                    <br/>
                                    <span class="comment"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="Comment"/></xsl:call-template></span>
                                </td>
                            </xsl:for-each>

                        </tr>
                    </xsl:for-each>

                    <tr>
                        <th class="padding-left-1em">
                            <span>9A : </span>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09a-desc'"/>
                            </xsl:call-template>

                        </th>

                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_09A/SumOfPartnerAmounts"/></xsl:call-template>
                        </td>

                    </tr>

                    <tr>
                        <th colspan="2">
                            <strong>Disclaimer : </strong>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09b_f-disclaimer'"/>
                            </xsl:call-template>
                        </th>
                    </tr>
					<!-- 
                    <tr>
                        <th class="padding-left-1em">
                            <span>9A_registry : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09a-registry-description'"/>
                            </xsl:call-template>

                        </th>

                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_09A_Registry/Amount"/></xsl:call-template>
                        </td>

                    </tr>
					 -->
                    <xsl:for-each select="tr_09A_TradePartners/*">
                        <xsl:variable name="partnerId" select="PartnerId"/>
                        <tr>
                            <td  class="padding-left-1em tradingPartners">
                                <div><li/></div>
                                <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>

                                <br/>
                                <xsl:if test="isEUBased">
                                    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
                                </xsl:if>
                                <xsl:if test="isEUBased = 'false'">
                                    <div class="padding-left-1em">
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
                                        -
                                        <xsl:call-template name="getLabel">
                                            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
                                        </xsl:call-template>
                                        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>
                                    </div>
                                </xsl:if>

                            </td>
                            <xsl:for-each select="../../tr_09A/TradePartner[TradePartnerID = $partnerId]">
                                <td class="num_cell">
                                    <xsl:call-template name="formatValue"><xsl:with-param name="num" select="amount"/></xsl:call-template>
                                </td>
                            </xsl:for-each>

                        </tr>
                    </xsl:for-each>
                    <tr>
                        <th class="padding-left-1em">
                            <span>9B : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09b-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09b-formula'"/>
                            </xsl:call-template>
                            </span>

                        </th>

                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_09B/Amount"/></xsl:call-template>
                        </td>

                    </tr>
                    <tr>
                        <th class="padding-left-1em">
                            <span>9C : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09c-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09c-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>

                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_09C/Amount"/></xsl:call-template>
                        </td>

                    </tr>
                    <tr>
                        <th class="padding-left-1em">
                            <span>9D : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09d-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09d-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>

                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_09D/Amount"/></xsl:call-template>
                        </td>

                    </tr>
                    <tr>
                        <th class="padding-left-1em">
                            <span>9E : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09e-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09e-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>

                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_09E/Amount"/></xsl:call-template>
                        </td>

                    </tr>
                    <tr>
                        <th class="padding-left-1em">
                            <span>9F : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09f-desc'"/>
                            </xsl:call-template>
                            <br/><span class="formula">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09f-formula'"/>
                            </xsl:call-template>
                            </span>
                        </th>

                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_09F/Amount"/></xsl:call-template>
                        </td>

                    </tr>
                    <tr>
                        <th class="padding-left-1em">
                            <span>9G : </span>

                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'tr-09g-desc'"/>
                            </xsl:call-template>
                            <br/>
                            <xsl:variable name="tr-09g-desc-tail">
                                <xsl:call-template name="getLabel">
                                    <xsl:with-param name="labelName" select="'tr-09g-desc-tail'"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <i>
                                <xsl:value-of select="replace(string($tr-09g-desc-tail), '\{\{ date \}\}', string(tr_09G/Comment) )"/>
                            </i>
	                        <br/>
	                        <span class="formula">
		                        <xsl:call-template name="getLabel">
		                            <xsl:with-param name="labelName" select="'tr-09g-formula'"/>
		                        </xsl:call-template>
	                        </span>
	                    </th>

                        <td class="total">
                            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_09G/Amount"/></xsl:call-template>
                        </td>

                    </tr>                    
                </tbody>
            </table>

        <table style="border: 0 !important;">
        <tbody>
               <tr>
                   <td>
                       <xsl:if test="Verified = 'false' or Verified = ''">
                           <input type="checkbox" name="9checkbox"  disabled="true" ></input>
                       </xsl:if>
                       <xsl:if test="Verified = 'true'">
                            <input type="checkbox" name="9checkbox" value="$verified" checked="checked" disabled="true"/>
                       </xsl:if>

                   </td>
                   <td>
                       <xsl:call-template name="getLabel">
                           <xsl:with-param name="labelName" select="'verified-desc'"/>
                           <xsl:with-param name="labelPath" select="'sheet4'"/>
                       </xsl:call-template>
                   </td>
               </tr>
        </tbody>
        </table>
        <table style="border: 0 !important;">
            <tbody>
                <h2>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'documents'"/>
                        <xsl:with-param name="labelPath" select="'sheet4'"/>
                    </xsl:call-template>
                </h2>
                <tr>
                    <xsl:if test="count(SupportingDocuments/Document[ string-length( Url ) > 0 ]) =  0">
                        <td>
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'no-documents'"/>
                            </xsl:call-template>
                        </td>
                    </xsl:if>
                    <xsl:if test="string-length(SupportingDocuments/Document[1]/Url) > 0">
                        <td style="border: 0 !important;">
                            <xsl:for-each select="SupportingDocuments/Document">
                                <li>
                                    <xsl:call-template name="getValue"><xsl:with-param name="elem" select="Url"/></xsl:call-template>
                                </li>
                            </xsl:for-each>
                        </td>
                    </xsl:if>
                </tr>
            </tbody>
        </table>
        </xsl:if>
    </xsl:template>
    <xsl:template match="F5_S10_Auth_NER">
    	<xsl:if test="../GeneralReportData/Activities/auth-NER = 'true'">
            <h2>
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'section10-heading'"/>
                </xsl:call-template>
            </h2>      	
    		<table class="tableSizeLimit table table-hover table-bordered">
  				<thead  class="boldSpan">
					<tr class="boldHeading">
					    <th class="firstTh">
					        <xsl:call-template name="getLabel">
					            <xsl:with-param name="labelName" select="'sheet-transactions-header'"/>
					        </xsl:call-template>
					    </th>
					    <th colspan="2">
					        <xsl:call-template name="getLabel">
					            <xsl:with-param name="labelName" select="'sum-of-supplied-HFCS'"/>
					        </xsl:call-template>
					    </th>
					    <th class="gasTh">
					        <xsl:call-template name="getLabel">
					            <xsl:with-param name="labelName" select="'authorized-quota-amount'"/>
					        </xsl:call-template>
					    </th>
					    <!-- conditionally -->
					    <th class="gasTh">
					        <xsl:call-template name="getLabel">
					            <xsl:with-param name="labelName" select="'upload-proof-header'"/>
					        </xsl:call-template>
					    </th>
					    <!-- Iteration over gases -->
                        <xsl:for-each select="Gas|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
                        		<th class="gasTh">
	                                <xsl:call-template name="getGas"><xsl:with-param name="elem" select="../../ReportedGases[./GasId = current()/GasCode]/Name"/></xsl:call-template>
	                            </th>
                    		</xsl:if>
                        </xsl:for-each>
					</tr>
					<tr class="boldHeading no-wrap">
						<th />
					    <th>
					        <xsl:call-template name="getLabel">
					            <xsl:with-param name="labelName" select="'unit'"/>
					            <xsl:with-param name="labelPath" select="'common'"/>
					        </xsl:call-template>
					    </th>
					    <th>
					        <xsl:call-template name="getLabel">
					            <xsl:with-param name="labelName" select="'unit-co2eq'"/>
					            <xsl:with-param name="labelPath" select="'common'"/>
					        </xsl:call-template>
					    </th>
					    <th>
					        <xsl:call-template name="getLabel">
					            <xsl:with-param name="labelName" select="'unit-co2eq'"/>
					            <xsl:with-param name="labelPath" select="'common'"/>
					        </xsl:call-template>
					    </th>
					    <th />
                        <xsl:for-each select="Gas|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
                        		<th class="gasTh">
							        <xsl:call-template name="getLabel">
							            <xsl:with-param name="labelName" select="'unit'"/>
							            <xsl:with-param name="labelPath" select="'common'"/>
						        	</xsl:call-template>
						    	</th>
                    		</xsl:if>
                        </xsl:for-each>					    
					</tr>  				
  				</thead>
  				<tbody>
					<tr>
						<th class="padding-left-1em">
						    <span>10A : </span>
						    <xsl:call-template name="getLabel">
						        <xsl:with-param name="labelName" select="'tr-10a-desc'"/>
						    </xsl:call-template>
						</th>
						<td class="total">
							<xsl:call-template name="formatValue"><xsl:with-param name="num" select="xs:string( sum(./SumOfAllHFCsS1/tr_10A/Amount) )"/></xsl:call-template>
						</td>
						<td class="total">
							<xsl:call-template name="formatValue"><xsl:with-param name="num" select="xs:string( sum(./SumOfAllHFCsS2/tr_10A/Amount) )"/></xsl:call-template>
						</td>
						<td class="total">
							<xsl:call-template name="formatValue"><xsl:with-param name="num" select="xs:string( sum(./../F4_S9_IssuedAuthQuata//TradePartner[ amount castable as xs:double]/amount ))"/></xsl:call-template>
                        </td>
						<td />
                        <xsl:for-each select="Gas|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
                        	<xsl:if test="$isHfc = true()">
                        		<td />
                    		</xsl:if>
                        </xsl:for-each>		
					</tr>
					<xsl:for-each select="tr_10A_TradePartners/*">
					    <xsl:variable name="partnerIndex" select="position()"/>
					    <xsl:variable name="partnerId" select="PartnerId"/>
					    <tr>
					        <td  class="padding-left-1em tradingPartners">
					            <div><li/></div>
					            <div><span class="bold"><xsl:call-template name="getValue"><xsl:with-param name="elem" select="CompanyName"/></xsl:call-template> </span></div>
					
					            <br/>
					            <xsl:if test="isEUBased">
					                <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue"><xsl:with-param name="elem" select="EUVAT"/></xsl:call-template></div>
					            </xsl:if>
					            <xsl:if test="isEUBased = 'false'">
					                <div class="padding-left-1em">
					                    <xsl:call-template name="getLabel">
					                        <xsl:with-param name="labelName" select="'trading-partner-country'"/>
					                    </xsl:call-template>
					                    : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEUCountryOfEstablishment"/></xsl:call-template>
										<xsl:if test="string-length(NonEURepresentativeName) > 0">
											-
											<xsl:call-template name="getLabel">
												<xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
											</xsl:call-template>
											: <xsl:call-template name="getValue"><xsl:with-param name="elem" select="NonEURepresentativeName"/></xsl:call-template>										</xsl:if>
					                </div>
					            </xsl:if>
					        </td>
					        <td class="total">
					    		<xsl:call-template name="formatValue"><xsl:with-param name="num" select="../../SumOfAllHFCsS1/tr_10A[$partnerIndex]/Amount"/></xsl:call-template>
					    	</td>
					        <td class="total">
					    		<xsl:call-template name="formatValue"><xsl:with-param name="num" select="../../SumOfAllHFCsS2/tr_10A[$partnerIndex]/Amount"/></xsl:call-template>
					    	</td>
					        <td class="total">
					    		<xsl:call-template name="formatValue"><xsl:with-param name="num" select="xs:string (sum(../../../F4_S9_IssuedAuthQuata//TradePartner[TradePartnerID=$partnerId and amount castable as xs:double]/amount) )"/></xsl:call-template>
					    	</td>
					        <td>
					    		<xsl:call-template name="getValue"><xsl:with-param name="elem" select="../../SupportingDocuments/tr_10A[$partnerIndex]/Document/Url"/></xsl:call-template>
					    	</td>
					    	<xsl:for-each select="../../Gas|following-sibling::Gas[not(position()>($pagingLimit - 1))]">
	                        	<xsl:variable name="isHfc"><xsl:value-of select="fgas:isHfcBased(current()/GasCode, /FGasesReporting)" /></xsl:variable>
	                        	<xsl:variable name="gasIndex"><xsl:value-of select="position()" /></xsl:variable>
	                        	<xsl:if test="$isHfc = true()">
	                        		<td class="num_cell">
	                        			<xsl:call-template name="formatValue"><xsl:with-param name="num" select="tr_10A/TradePartner[$partnerIndex]/amount" /></xsl:call-template>
	                        		</td>
	                    		</xsl:if>
                        </xsl:for-each>	
					    </tr>
					</xsl:for-each>					
					
  				</tbody>
    		</table>
    	</xsl:if>
    </xsl:template>    
    <xsl:template match="F6_FUDest">
        <xsl:if test="../GeneralReportData/Activities/FU = 'true' ">
            <h2>
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'section7-heading'"/>

                </xsl:call-template>
            </h2>
            <xsl:call-template name="tablePaging7"/>
        </xsl:if>
        <xsl:if test=" ../GeneralReportData/Activities/D = 'true'">
            <h2>
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'section8-heading'"/>

                </xsl:call-template>
            </h2>
            <xsl:call-template name="tablePaging8"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="F7_s11EquImportTable">
       <xsl:if test="transactionsConfirmed = 'true' or ../GeneralReportData/Activities/Eq-I-RACHP-HFC = 'true'  or ../GeneralReportData/Activities/Eq-I-other = 'true'">
        <h2>
            <xsl:call-template name="getLabel">
                <xsl:with-param name="labelName" select="'header'"/>
                <xsl:with-param name="labelPath" select="'form7'"/>
            </xsl:call-template>
        </h2>

        <xsl:if test="(count((./UISelectedTransactions/child::*[. = 'true']) ) = 0)">
            <span class="tdColorBlue">
               <xsl:call-template name="getLabel">
                   <xsl:with-param name="labelName" select="'noCategoySelected'"/>
                   <xsl:with-param name="labelPath" select="'form7'"/>
               </xsl:call-template>
            </span>
        </xsl:if>

        <xsl:call-template name="tablePaging11"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="formatValue">
        <xsl:param name="num"/>
        <xsl:choose>
            <xsl:when test="string-length($num) &gt; 0 and (number($num) &gt; 0 or number($num) &lt;= 0)">
                <xsl:choose>
                    <xsl:when test="contains($num, '.') = false()"><xsl:value-of select="$num"/><span style="visibility:hidden">.000</span></xsl:when>
                    <xsl:when test="string-length(substring-after($num, '.')) = 0"><xsl:value-of select="$num"/><span style="visibility:hidden">000</span></xsl:when>
                    <xsl:when test="string-length(substring-after($num, '.')) = 1"><xsl:value-of select="$num"/><span style="visibility:hidden">00</span></xsl:when>
                    <xsl:when test="string-length(substring-after($num, '.')) = 2"><xsl:value-of select="$num"/><span style="visibility:hidden">0</span></xsl:when>
                    <xsl:when test="contains($num, '.') = true()"><xsl:value-of select="substring-before($num, '.')"/><span>.<xsl:value-of select="substring-after($num, '.')"/></span></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$num"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$num"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="totalValue">
        <xsl:param name="num"/>
        <td class="total">
            <xsl:call-template name="formatValue"><xsl:with-param name="num" select="$num"/></xsl:call-template><span class="sub" style="visibility:hidden;">*</span>
        </td>
    </xsl:template>
	<xsl:template name="getUnit">
		<xsl:param name="unit"/>
		<xsl:choose>
			<xsl:when test="$unit = 'cubicmetres' or $unit = 'metrictonnes'">
				<xsl:call-template name="getLabel">
					<xsl:with-param name="labelName" select="$unit"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$unit"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="getTradePartnerInfo">
		<xsl:param name="partner"></xsl:param>
		<xsl:if test="count(partner) > 0">
			<xsl:for-each select="partner/*">
				<div>
					<span class="bold">
						<xsl:call-template name="getValue"><xsl:with-param name="elem" select="./CompanyName"/></xsl:call-template> 
					</span>
				</div>
				<br/>
				<xsl:if test="isEUBased">
				    <div class="padding-left-1em"><span> </span> <xsl:call-template name="getValue">
				    	<xsl:with-param name="elem" select="./EUVAT"/></xsl:call-template>
				    </div>
				</xsl:if>
				<xsl:if test="isEUBased = 'false'">
				    <div class="padding-left-1em">
				        <xsl:call-template name="getLabel">
				            <xsl:with-param name="labelName" select="'trading-partner-country'"/>
				        </xsl:call-template>
				        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="./NonEUCountryOfEstablishment"/></xsl:call-template>
				        -
				        <xsl:call-template name="getLabel">
				            <xsl:with-param name="labelName" select="'trading-partner-representative-name'"/>
				        </xsl:call-template>
				        : <xsl:call-template name="getValue"><xsl:with-param name="elem" select="./NonEURepresentativeName"/></xsl:call-template>
				    </div>
				</xsl:if>	
			</xsl:for-each>
		</xsl:if>	
	</xsl:template>	
	<xsl:template match="text()"/>
</xsl:stylesheet>