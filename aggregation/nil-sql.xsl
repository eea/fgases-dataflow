<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="common.xsl"/>

<xsl:output method="text" />

<xsl:param name="envelopeurl" />
<xsl:param name="filename" />
<xsl:param name="isreleased"/>
<xsl:param name="releasetime"/>
<!--
For testing:
<xsl:param name="isreleased"/>
<xsl:param name="releasetime"/>
<xsl:param name="isreleased" select="'1'"/>
<xsl:param name="releasetime" select="substring-before(current-date(), '+')"/>
-->

<xsl:variable name="reportid" select="concat($envelopeurl, '/', $filename , '#', $releasetime)"/>

<xsl:template match="Reporting">
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
    <!-- Activities -->
        <xsl:text>0,</xsl:text>
        <xsl:text>0,</xsl:text>
        <xsl:text>0,</xsl:text>
        <xsl:text>0,</xsl:text>
        <xsl:text>0,</xsl:text>
        <xsl:text>0,</xsl:text>
        <xsl:text>' ',</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Company/NoReporting"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Comments"/></xsl:call-template>
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
<xsl:template match="text()"/>

</xsl:stylesheet>
