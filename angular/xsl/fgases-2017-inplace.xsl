<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  >

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*" />

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="TransactionYear">
    <xsl:copy>2017</xsl:copy>
  </xsl:template>

  <xsl:template match="@*[name() = 'xsi:noNamespaceSchemaLocation']">
    <xsl:attribute name="{name()}">http://dd.eionet.europa.eu/schemas/fgases-2017/FGasesReporting.xsd</xsl:attribute>
  </xsl:template>

</xsl:stylesheet>

