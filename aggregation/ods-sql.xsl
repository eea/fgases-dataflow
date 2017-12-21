<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="common.xsl"/>

<xsl:output method="text" />

<xsl:param name="envelopeurl" />
<xsl:param name="isreleased" />
<xsl:param name="filename" />
<xsl:param name="releasetime" />

<xsl:variable name="testing" select="true()"/>
<xsl:variable name="reportid" select="concat($envelopeurl, '/', $filename , '#', $releasetime)"/>

<xsl:variable name="usetypesUrl">
    <xsl:choose>
        <xsl:when test="$testing">
            "http://webq2test.eionet.europa.eu/download/project/ods-dev-2016/file/ods-usetypes.xml/Usetypes"
        </xsl:when>
        <xsl:otherwise>
            "http://webforms.eionet.europa.eu/download/project/ods/file/ods-usetypes.xml/Usetypes"
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:variable name="usetypes" select="document($usetypesUrl)"/>

<xsl:template match="FGasesReporting">
    <xsl:text></xsl:text>
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="GeneralReportData">
    <xsl:text>
INSERT INTO data_report VALUES (</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="$envelopeurl"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="$isreleased"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="datetime"><xsl:with-param name="value" select="$releasetime"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="$filename"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="@status"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/CompanyId"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/CompanyName"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/PostalAddress/StreetAddress"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/PostalAddress/City"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/PostalAddress/Region"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/PostalAddress/PostalCode"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/Country"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EoriCode"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/VatCode"/></xsl:call-template><xsl:text>,</xsl:text>		
        <xsl:call-template name="accessDate"><xsl:with-param name="value" select="SubmissionDate"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="TransactionYear"/></xsl:call-template><xsl:text>,</xsl:text>
    <!-- Activities not needed-->
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Company/Actor/Producer"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Company/Actor/Importer"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Company/Actor/Exporter"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Company/Actor/ProcessAgent"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Company/Actor/Feedstock"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Company/Actor/Destruction"/></xsl:call-template><xsl:text>,</xsl:text>
		<xsl:text>'' ,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Company/Actor/NoReporting"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="../Comments"/></xsl:call-template>
        <xsl:text>);</xsl:text>
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="ContactInfo">
    <xsl:text>
INSERT INTO data_company_contacts VALUES (</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Telephone"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="FaxNumber"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Email"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="ContactPerson"/></xsl:call-template>
        <xsl:text>);</xsl:text>
</xsl:template>

<!-- Table 3 & 5 & 13 & 14-->
<xsl:template match="ProductionQuantity|RecycledReclaimedQuantity|UsedQuantity|DestructionQuantity">

	<xsl:variable name="useType" select="Subject/@usetype"/>
	<xsl:variable name="usetypeIsInCodeList">
		<xsl:choose>
			<!-- TODO apply this check for all use types? -->
			<xsl:when test="local-name(../.) = 'ReporterUses' and count($usetypes/UsetypeGroup[@id = 'ReporterUses']/Usetype[@code = $useType]) = 0"><xsl:value-of select="'false'"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="'true'"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="subject">
		<xsl:choose>
			<xsl:when test="name(.)='DestructionQuantity'"><xsl:value-of select="'destruction'"/></xsl:when>
			<xsl:when test="$usetypeIsInCodeList ='false'"><xsl:value-of select="'other'"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="Subject/@usetype"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
			
	<xsl:variable name="subjectOther">
		<xsl:choose>
			<xsl:when test="$usetypeIsInCodeList ='false' and string-length(Subject) = 0"><xsl:value-of select="Subject/@usetype"/></xsl:when>
			<xsl:when test="$usetypeIsInCodeList ='false' and string-length(Subject) &gt; 0"><xsl:value-of select="concat(Subject/@usetype, '; ', Subject)"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="Subject"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
    <xsl:variable name="destructionCode" select="DestructionTechnology/@code"/>
    <xsl:variable name="destruction" select="DestructionTechnology"/>
    <xsl:for-each select="Quantity">
        <xsl:if test="string-length(Value) &gt; 0 and string-length(SubstanceCode) &gt; 0">
            <xsl:text>
INSERT INTO data_report_values VALUES (</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="name(../../.)"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value">
            	<xsl:call-template name="getSubstanceNameWithoutVirginSuffix"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            </xsl:with-param></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$subject"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$subjectOther"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="number"><xsl:with-param name="value" select="Value"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="Description"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$destruction"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$destructionCode"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="isSubstanceVirgin"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            <xsl:text>);</xsl:text>
        </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates/>
</xsl:template>

<!-- Table 4 & 6 & 10 -->
<xsl:template match="CompanyQuantity|SaleEUQuantity">
    <xsl:variable name="subject" select="Subject/@usetype"/>
    <xsl:variable name="subjectOther" select="Subject"/>
    <xsl:variable name="company" select="Company/CompanyName"/>
    <xsl:variable name="companyAddress" select="Company/CompanyAddress"/>
    <xsl:variable name="country" select="Company/Country"/>

    <xsl:for-each select="Quantity">
        <xsl:if test="string-length(Value) &gt; 0 and string-length(SubstanceCode) &gt; 0">
            <xsl:text>
INSERT INTO data_report_values VALUES (</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="name(../../.)"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value">
            	<xsl:call-template name="getSubstanceNameWithoutVirginSuffix"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            </xsl:with-param></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$subject"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$subjectOther"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="number"><xsl:with-param name="value" select="Value"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$company"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$companyAddress"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$country"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="isSubstanceVirgin"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            <xsl:text>);</xsl:text>
        </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates/>
</xsl:template>

<!-- Table 7 & 11 -->
<xsl:template match="ImportQuantity|ExportQuantity">
    <xsl:variable name="subject" select="Subject/@usetype"/>
    <xsl:variable name="subjectOther" select="Subject"/>
    <xsl:variable name="customsProcedure" select="CustomsProcedure"/>
    <xsl:variable name="country" select="Country"/>
    <xsl:for-each select="Quantity">
        <xsl:if test="string-length(Value) &gt; 0 and string-length(SubstanceCode) &gt; 0">
            <xsl:text>
INSERT INTO data_report_values VALUES (</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="name(../../.)"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string">
            	<xsl:with-param name="value">
            	<xsl:call-template name="getSubstanceNameWithoutVirginSuffix"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            </xsl:with-param></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$subject"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$subjectOther"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="number"><xsl:with-param name="value" select="Value"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$customsProcedure"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$country"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="isSubstanceVirgin"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            <xsl:text>);</xsl:text>
        </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates/>
</xsl:template>

<!-- Table 8 & 9 -->
<xsl:template match="StockQuantity">
    <xsl:variable name="subject" select="concat(Subject/@usetype,' ', @date)"/>
    <xsl:for-each select="Quantity">
        <xsl:if test="string-length(Value) &gt; 0 and string-length(SubstanceCode) &gt; 0">
            <xsl:text>
INSERT INTO data_report_values VALUES (</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="name(../../.)"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value">
            	<xsl:call-template name="getSubstanceNameWithoutVirginSuffix"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            </xsl:with-param></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$subject"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="number"><xsl:with-param name="value" select="Value"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="Description"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="isSubstanceVirgin"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            <xsl:text>);</xsl:text>
        </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates/>
</xsl:template>

<!-- Table 12-->
<xsl:template match="Emissions|MakeUp">
    <xsl:variable name="processCode" select="../Process/@code"/>
    <xsl:variable name="process" select="../Process"/>
	<xsl:variable name="subject" select="concat(name(.),' - current year - ', ../Process/@code)"/>
	<xsl:variable name="subjectNextYear" select="concat(name(.),' - estimation next year - ', ../Process/@code)"/>
    <xsl:for-each select="Quantity">
        <xsl:if test="string-length(Value) &gt; 0 and string-length(SubstanceCode) &gt; 0">
            <xsl:text>
INSERT INTO data_report_values VALUES (</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="name(../../../.)"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value">
            	<xsl:call-template name="getSubstanceNameWithoutVirginSuffix"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            </xsl:with-param></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$subject"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="number"><xsl:with-param name="value" select="Value"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="../../Process/@comment"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="../../Process/@containment"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$process"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$processCode"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="isSubstanceVirgin"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            <xsl:text>);</xsl:text>
        </xsl:if>
        <xsl:if test="string-length(EstimatedValue) &gt; 0 and string-length(SubstanceCode) &gt; 0">
            <xsl:text>
INSERT INTO data_report_values VALUES (</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="name(../../../.)"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value">
            	<xsl:call-template name="getSubstanceNameWithoutVirginSuffix"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            </xsl:with-param></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$subjectNextYear"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="number"><xsl:with-param name="value" select="EstimatedValue"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="../../Process/@comment"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="../../Process/@containment"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$process"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$processCode"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="isSubstanceVirgin"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            <xsl:text>);</xsl:text>
        </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="PauFdst">
        <xsl:if test="string-length(Comments) &gt; 0">
            <xsl:text>
INSERT INTO data_report_values VALUES (</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="name(.)"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="'comments'"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="number"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="Comments"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="''"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="isSubstanceVirgin"><xsl:with-param name="substance" select="SubstanceCode"/></xsl:call-template>
            <xsl:text>);</xsl:text>
        </xsl:if>
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>
