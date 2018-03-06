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
        margin: 0 0 10px 0;
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
                <h1>F-Gas Regulation - Verification and submission of the verification document for importers of equipment</h1>
                <xsl:apply-templates select="Company"/>
                <xsl:apply-templates select="Year"/>
                <br/>
                <xsl:apply-templates select="EV_3.1"/>
                <p>The data report pursuant to Article 19 of Regulation (EU) No 517/2014 to which the verification report refers.<br/>
                    (report URL in the EEA’s business data repository, submission date and time):
                </p>
                <div>
                    <xsl:apply-templates select="URL"/>
                    <xsl:apply-templates select="ReportedDate"/>
                </div>
                <h2>(2) Substance of Verification</h2>
                <p>Independent auditor’s statement about the importer of the equipment:</p>
                <table>
                    <tr>
                        <th>Code</th>
                        <th>Auditor’s statement on the level of accuracy</th>
                        <th/>
                    </tr>
                    <xsl:apply-templates select="EV_3.2_a" mode="EV_3_row"/>
                    <xsl:apply-templates select="EV_3.2_b" mode="EV_3_row"/>
                    <xsl:apply-templates select="EV_3.2_c" mode="EV_3_row"/>
                    <xsl:apply-templates select="EV_3.2_d" mode="EV_3_row"/>
                </table>
                <xsl:apply-templates select="ReportFiles"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="Company">
        <h2>(1) Identification of company, year and relevant Article 19 report</h2>
        <p>The verified declaration(s) of conformity were drawn up by the following importer of equipment:</p>
        <div>
            <p>CompanyName:
                        <span><xsl:value-of select="CompanyName"/></span>
            </p>
            <p>Registration ID in the HFC Registry:
                <span><xsl:value-of select="CompanyId"/></span>
            </p>
            <p style="font-weight:bold">For undertakings established within the EU:</p>
            <p>VAT-No.:
                <span><xsl:value-of select="VATNumber"/></span>
            </p>
            <xsl:variable name="isOutsideEU" select="EuLegalRepresentativeCompany/VATNumber[text()]"/>
            <p style="font-weight:bold">For undertakings established outside the EU:</p>
            <p>Country of establishment:
                <span>
                    <xsl:choose>
                        <xsl:when test="$isOutsideEU">
                            <xsl:value-of select="Country/Name"/>
                        </xsl:when>
                        <xsl:otherwise> - </xsl:otherwise>
                    </xsl:choose>
                </span>
            </p>
            <p>Name of mandated only representative established within the EU for the
            purpose of compliance with the requirements of Regulation (EU) No 517/2014:
                <span>
                    <xsl:choose>
                        <xsl:when test="$isOutsideEU">
                            <xsl:value-of select="EuLegalRepresentativeCompany/CompanyName"/>
                        </xsl:when>
                        <xsl:otherwise> - </xsl:otherwise>
                    </xsl:choose>
                </span>
            </p>
            <p>VAT-No. of only representative:
                <span>
                    <xsl:choose>
                        <xsl:when test="$isOutsideEU">
                            <xsl:value-of select="EuLegalRepresentativeCompany/VATNumber"/>
                        </xsl:when>
                        <xsl:otherwise> - </xsl:otherwise>
                    </xsl:choose>
                </span>
            </p>
        </div>
    </xsl:template>
    <xsl:template match="Year">
        <p>The verified declaration(s) of conformity refer to the following calendar year: </p>
        <div>
            <p>
                Year:
                <span><xsl:value-of select="."/></span>
            </p>
        </div>
    </xsl:template>
    <xsl:template match="EV_3.1">
        <table>
            <tr>
                <td>EV_3.1</td>
                <td>A report pursuant to Article 19 of Regulation (EU) No 517/2014 covering Sections 11, 12, and 13 of the Annex to Implementing Regulation (EU) No 1191/2014 for the calendar year specified above was submitted by the importer of equipment</td>
                <td>
                    <xsl:choose>
                        <xsl:when test=". = 'EV_3.1_1'">Yes</xsl:when>
                        <xsl:when test=". = 'EV_3.1_2'">No</xsl:when>
                    </xsl:choose>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="URL">
        <p>
            URL:
            <a>
                <xsl:attribute name="href">
                    <span><xsl:value-of select="."/></span>
                </xsl:attribute>
                <span><xsl:value-of select="."/></span>
            </a>
        </p>
    </xsl:template>
    <xsl:template match="ReportedDate">
        <p>
            Reported:
            <span><xsl:value-of select="concat(substring(., 1, 10), ' ', substring(., 12, 5))"/></span>
        </p>
    </xsl:template>
    <xsl:template match="*" mode="EV_3_row">
        <tr>
            <td>
                <xsl:value-of select="name(.)"/>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="name(.) = 'EV_3.2_a'">
                        (a) The information contained in the declaration(s) of conformity and the related documents is consistent with the report pursuant to Article 19 of Regulation (EU) No 517/2014
                    </xsl:when>
                    <xsl:when test="name(.) = 'EV_3.2_b'">
                        (b) The information contained in the declaration(s) of conformity and the related documents is accurate and complete on the basis of the undertaking's records of relevant transactions, with a reasonable level of assurance
                    </xsl:when>
                    <xsl:when test="name(.) = 'EV_3.2_c'">
                        (c) In the HFC registry, there was by 31 December of the calendar year specified above sufficient availability of authorisations for all cases where option A was chosen in the declaration(s) of conformity
                    </xsl:when>
                    <xsl:when test="name(.) = 'EV_3.2_d'">
                        (d) There is a declaration by the undertaking placing the hydrofluorocarbons on the market in accordance with Article 2(2)(d) of Commission Implementing Regulation (EU) No 879/2016 for all cases where option B was chosen in the declaration(s) of conformity, covering the relevant quantities
                    </xsl:when>
                </xsl:choose>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test=". = concat(name(.), '_1')">Yes</xsl:when>
                    <xsl:when test=". = concat(name(.), '_2')">No</xsl:when>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="*">
    </xsl:template>
    <xsl:template match="ReportFiles">
        <h2>(3) Verification report files</h2>
        <ul>
            <xsl:for-each select="./ReportFile">
                <li>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat(normalize-space(.), '/manage_document')"/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>

</xsl:stylesheet>