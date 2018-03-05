<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:template match="Verification">
        <html>
            <head>
                <title>Factsheet</title>
                <style type="text/css"><![CDATA[

    h1 {
        font-family: arial, verdana, sans-serif;
        font-size: 160%;
        border-bottom: 1px solid #999999;
    }
    h2 {
        font-size: 120%;
        padding-bottom: 0.5em;
        border-bottom: 1px solid #999999;
    }
    p {
        margin: 5px;
    }
    div {
        padding: 0px 5px 0px 5px;
        border-style: solid;
        border-width: 1px;
        width: 450px;
    }
    body {
        font-size: 80%;
        font-family: verdana, helvetica, arial, sans-serif;
        color: #333;
    }
    span {
        font-weight: bold;
    }
    th {
        background-color:#f6f6f6;
        text-align:left;
        vertical-align: top;
        font-weight: bold;
        color: black;
    }
    table {
        font-size: 100%;
        border: 1px solid #bbb;
        margin: 0 0 2em 0;
        border-collapse: collapse;

    }
    th, td {
        font-size: 100%;
        border: 1px solid #bbb;
        padding: 2px 2px 2px 2px;
        max-width: 500px;
    }
    ]]>
                </style>

            </head>
            <body>
                <h1>F-Gas Regulation - Verification and submission of the verification document for bulk importers and producers</h1>
                <h2>(1) Identification of company, year and relevant Article 19 report</h2>
                <p>The verified report was drawn up for the following undertaking:</p>
                <div>
                    <p>CompanyName:
                        <span><xsl:value-of select="Company/CompanyName"/></span>
                    </p>
                    <p>Registration ID in the HFC Registry:
                        <span><xsl:value-of select="Company/CompanyId"/></span>
                    </p>

                    <p style="font-weight:bold">For undertakings established within the EU:</p>
                    <p>VAT-No.:
                        <span><xsl:value-of select="Company/VATNumber"/></span>
                    </p>
                    <p style="font-weight:bold">For undertakings established outside the EU:</p>
                    <p>Country of establishment:
                        <span>
                            <xsl:choose>
                                <xsl:when test="Company/EuLegalRepresentativeCompany/VATNumber[text()]">
                                    <xsl:value-of select="Company/Country/Name"/>
                                </xsl:when>
                                <xsl:otherwise> - </xsl:otherwise>
                            </xsl:choose>
                        </span>
                    </p>
                    <p>Name of mandated only representative established within the EU for the
                    purpose of compliance with the requirements of Regulation (EU) No 517/2014:
                        <span>
                            <xsl:choose>
                                <xsl:when test="Company/EuLegalRepresentativeCompany/VATNumber[text()]">
                                    <xsl:value-of select="Company/EuLegalRepresentativeCompany/CompanyName"/>
                                </xsl:when>
                                <xsl:otherwise> - </xsl:otherwise>
                            </xsl:choose>
                        </span>
                    </p>
                    <p>VAT-No. of only representative:
                        <span>
                            <xsl:choose>
                                <xsl:when test="Company/EuLegalRepresentativeCompany/VATNumber[text()]">
                                    <xsl:value-of select="Company/EuLegalRepresentativeCompany/VATNumber"/>
                                </xsl:when>
                                <xsl:otherwise> - </xsl:otherwise>
                            </xsl:choose>
                        </span>
                    </p>
                </div>
                <p>The verified declaration(s) of conformity refer to the following calendar year: </p>
                <div>
                    <p>Year:
                        <span><xsl:value-of select="Year"/></span>
                    </p>
                </div>
                <p>The data report pursuant to Article 19 of Regulation (EU) No 517/2014 to which the verification report refers.<br/>
                    (report URL in the EEA’s business data repository, submission date and time):
                </p>
                <div>
                    <p>URL:
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="URL"/>
                            </xsl:attribute>
                            <xsl:value-of select="URL"/>
                        </a>
                    </p>
                    <p>Reported:
                        <span><xsl:value-of select="concat(substring(ReportedDate, 1, 10), ' ', substring(ReportedDate, 12, 5))"/></span>
                    </p>
                </div>
                <h2>(2) Substance of Verification</h2>
                <p>Independent auditor’s conclusions in the verification report:</p>
                <table>
                    <tr>
                        <th>Code</th>
                        <th>Element of the identified report</th>
                        <th>Auditor’s conclusion</th>
                    </tr>
                    <tr>
                        <td>BV_9F</td>
                        <td>Total calculated need of quota for hydrofluorocarbons placed on the market,
as given in <span>section 9F</span> of the Art. 19 data report identified above</td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="BV_9F='BV_9F_1'">The quota need as given in section 9F is fully confirmed.</xsl:when>
                                <xsl:when test="BV_9F='BV_9F_2'">The verification report concludes in a <span>higher</span> quota need than given in 9F.</xsl:when>
                                <xsl:when test="BV_9F='BV_9F_3'">The verification report concludes in a <span>lower</span> quota need than given in 9F.</xsl:when>
                                <xsl:when test="BV_9F='BV_9F_4'">The verification report does not make any statement as regards the quota need.</xsl:when>
                            </xsl:choose>
                        </td>
                    </tr>
                    <tr>
                        <td>BV_5C</td>
                        <td>Quantity supplied directly to undertakings <span>for export out of the Union</span>, where those quantities were not subsequently made available to another party within the Union prior to export,
 as given in <span>section 5C_exempted</span> of the Art. 19 data report identified above</td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="BV_5C='BV_5C_1'">No amounts were reported in section 5C_exempted.</xsl:when>
                                <xsl:when test="BV_5C='BV_5C_2'">The verification report fully confirms the amounts reported in section 5C_exempted.</xsl:when>
                                <xsl:when test="BV_5C='BV_5C_3'">The verification report does NOT fully confirm the amounts reported in section 5C_exempted.</xsl:when>
                                <xsl:when test="BV_5C='BV_5C_4'">The verification report does not make a statement as regards the amounts reported in section 5C_exempted.</xsl:when>
                            </xsl:choose>
                        </td>
                    </tr>
                    <tr>
                        <td>BV_10A</td>
                        <td>Amounts of <span>gas physically supplied</span> by a new entrant quota holder which are <span>linked to authorisations</span> given to importers of refrigeration, air conditioning and heat pump equipment charged with hydrofluorocarbons,
as given in <span>section 10A</span> of the Art. 19 data report identified above</td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="BV_10A='BV_10A_1'">No amounts were reported in section 10A.</xsl:when>
                                <xsl:when test="BV_10A='BV_10A_2'">The verification report fully confirms the amounts reported in section 10A.</xsl:when>
                                <xsl:when test="BV_10A='BV_10A_3'">The verification report does NOT fully confirm the amounts reported in section 10A. </xsl:when>
                                <xsl:when test="BV_10A='BV_10A_4'">The verification report does not make a statement as regards the amounts reported in section 10A.</xsl:when>
                            </xsl:choose>
                        </td>
                    </tr>
                </table>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>