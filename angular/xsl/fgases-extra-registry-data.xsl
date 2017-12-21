<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <xsl:param name="companyId"/>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="count(/child::*/child::*[@companyId=$companyId]) = 0">
                <registryData companyId="{$companyId}">
                    <stocks />
                    <quota />
                    <large>false</large>
                    <ner>false</ner>
                </registryData>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="/child::*/child::*[@companyId=$companyId][1]" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>