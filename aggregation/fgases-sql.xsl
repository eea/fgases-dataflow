<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="common.xsl"/>

    <xsl:output method="text" />

    <!--<xsl:param name="envelopeurl" select="'http://cdr.test/test'" />
    <xsl:param name="filename" select ="'fgases.xml'"/>
    <xsl:param name="isreleased" select="'1'"/>
    <xsl:param name="releasetime" select="'2015-11-12'"/>
    <xsl:param name="commandline" select="'false'"/>-->

	<xsl:param name="envelopeurl" />
	<xsl:param name="filename" />
	<xsl:param name="companyId" />
	<xsl:param name="isreleased" select="'1'"/>
	<xsl:param name="releasetime" select="substring-before(current-dateTime(), '.')"/>
	<xsl:param name="commandline" select="'false'"/>

    <!--
    For testing:
    <xsl:param name="isreleased"/>
    <xsl:param name="releasetime"/>
    <xsl:param name="isreleased" select="'1'"/>
    <xsl:param name="releasetime" select="substring-before(current-date(), '+')"/>
    -->
	<xsl:variable name="transactionYear" select="//GeneralReportData/TransactionYear"/>
    <xsl:variable name="reportid" select="concat($transactionYear, '-', $companyId, '-', $envelope)"/>

    <xsl:template match="FGasesReporting"><xsl:apply-templates/></xsl:template>

    <xsl:template match="GeneralReportData"><xsl:call-template name="statementSeparator"/><xsl:text>INSERT INTO data_report VALUES (</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="$envelopeurl"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="$isreleased"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="datetime"><xsl:with-param name="value" select="$releasetime"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="$filename"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="@status"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="datetime"><xsl:with-param name="value" select="SubmissionDate"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="number"><xsl:with-param name="value" select="TransactionYear"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/CompanyId"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/CompanyName"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/PostalAddress/StreetAddress"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/PostalAddress/Number"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/PostalAddress/PostalCode"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/PostalAddress/City"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="getCountryCode"><xsl:with-param name="country" select="Company/Country/Code"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Company/Country/Type = 'EU_TYPE'"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/Telephone"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/Website"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/VATNumber"/></xsl:call-template><xsl:text>,</xsl:text>
        <!-- OR -->
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EuLegalRepresentativeCompany/CompanyName"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EuLegalRepresentativeCompany/PostalAddress/StreetAddress"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EuLegalRepresentativeCompany/PostalAddress/Number"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EuLegalRepresentativeCompany/PostalAddress/PostalCode"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EuLegalRepresentativeCompany//PostalAddress/City"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="getCountryCode"><xsl:with-param name="country" select="Company/EuLegalRepresentativeCompany/Country/Code"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EuLegalRepresentativeCompany/ContactPerson/FirstName"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EuLegalRepresentativeCompany/ContactPerson/LastName"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EuLegalRepresentativeCompany/ContactPerson/Email"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EuLegalRepresentativeCompany/Telephone"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EuLegalRepresentativeCompany/Website"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/EuLegalRepresentativeCompany/VATNumber"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="Company/Former_CompanyId_2104"/></xsl:call-template><xsl:text>,</xsl:text>
        <!-- Activities -->
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/P"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/P-HFC"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/P-other"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/I"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/I-HFC"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/I-other"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/E"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/FU"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/D"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/Eq-I"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/Eq-I-RACHP-HFC"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/Eq-I-other"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/auth"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/auth-NER"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="Activities/NIL-Report"/></xsl:call-template><xsl:text>,</xsl:text>
		<xsl:call-template name="boolean"><xsl:with-param name="value" select="count(../F2_S5_exempted_HFCs/SupportingDocuments/Document/Url[string-length(normalize-space(.))>0]) > 0"/></xsl:call-template><xsl:text>,</xsl:text>
		<xsl:call-template name="boolean"><xsl:with-param name="value" select="count(../F4_S9_IssuedAuthQuata/SupportingDocuments/Document/Url[string-length(normalize-space(.))>0]) > 0"/></xsl:call-template>

        <xsl:text>);</xsl:text><xsl:call-template name="statementSeparator"/><xsl:for-each select="Company/ContactPersons/ContactPerson"><xsl:call-template name="ContactPerson"/></xsl:for-each>
        <xsl:for-each select="Company/Affiliations/Affiliation"><xsl:call-template name="Affiliation"/></xsl:for-each>
    </xsl:template>
    <xsl:template name="ContactPerson"><xsl:text>INSERT INTO data_report_contacts VALUES (</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="UserName"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="FirstName"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="LastName"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="Email"/></xsl:call-template>
            <xsl:text>);</xsl:text><xsl:call-template name="statementSeparator"/></xsl:template>
    <xsl:template name="Affiliation"><xsl:text>INSERT INTO data_affiliations VALUES (</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="CompanyName"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="isEUBased"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="EUVAT"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="NonEURepresentativeName"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="NonEURepresentativeVAT"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="string"><xsl:with-param name="value" select="NonEUDgClimaRegCode"/></xsl:call-template><xsl:text>,</xsl:text>
        <xsl:call-template name="getCountryCode"><xsl:with-param name="country" select="NonEUCountryCodeOfEstablishment"/></xsl:call-template><xsl:text>,</xsl:text>
		<xsl:variable name="qcWarnings"><xsl:call-template name="join"><xsl:with-param name="valueList" select="QCWarning"/></xsl:call-template></xsl:variable>
		<xsl:call-template name="string"><xsl:with-param name="value" select="$qcWarnings"/></xsl:call-template>
        <xsl:text>);</xsl:text><xsl:call-template name="statementSeparator"/>
    </xsl:template>
    <xsl:template match="BlendComponents">
        <xsl:for-each select="Component"><xsl:text>INSERT INTO data_blend_components VALUES (</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="../../GasId"/></xsl:call-template><xsl:text>,</xsl:text>
			<xsl:call-template name="getGasName"><xsl:with-param name="gasId" select="../../GasId"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="ComponentId"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="string"><xsl:with-param name="value" select="Code"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="number"><xsl:with-param name="value" select="Percentage"/></xsl:call-template><xsl:text>,</xsl:text>
            <xsl:call-template name="boolean"><xsl:with-param name="value" select="IsOther"/></xsl:call-template><xsl:text>,</xsl:text>
			<xsl:call-template name="boolean"><xsl:with-param name="value" select="../../IsCustomComposition"/></xsl:call-template><xsl:text>,</xsl:text>
			<xsl:call-template name="string"><xsl:with-param name="value" select="GasGroupId"/></xsl:call-template><xsl:text>,</xsl:text>
			<xsl:call-template name="string"><xsl:with-param name="value" select="../../GWP_AR4_HFC"/></xsl:call-template><xsl:text>,</xsl:text>
			<xsl:call-template name="string"><xsl:with-param name="value" select="GWP_AR4_HFC"/></xsl:call-template>
			<xsl:text>);</xsl:text><xsl:call-template name="statementSeparator"/>
        </xsl:for-each>
    </xsl:template>
	<xsl:template name="unusualGas"><xsl:text>INSERT INTO data_unusualGas VALUES (</xsl:text>
		<xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
		<xsl:variable name="qcWarnings"><xsl:call-template name="join"><xsl:with-param name="valueList" select="QCWarning"/></xsl:call-template></xsl:variable>
		<xsl:call-template name="string"><xsl:with-param name="value" select="$qcWarnings"/></xsl:call-template>
		<xsl:text>);</xsl:text><xsl:call-template name="statementSeparator"/>
	</xsl:template>
<!--
    <xsl:template match="*[name(.)= 'F1_S1_4_ProdImpExp' or name(.)= 'F2_S5_exempted_HFCs' or name(.)= 'F3A_S6A_IA_HFCs'  or name(.)= 'F4_S9_IssuedAuthQuata'
     or name(.)= 'F6_FUDest'  or name(.)= 'F7_s11EquImportTable']/*[substring(name(.),1,5)= 'tr_09' or name(.) = 'Gas']">
-->
	<xsl:template match="Gas|F4_S9_IssuedAuthQuata|AmountOfImportedEquipment|SumOfAllGasesS2">
        <xsl:for-each select="./child::*[substring(name(.),1,3)= 'tr_']">
            <xsl:variable name="transactionCode" select="substring(name(.),4)"/>
            <xsl:if test="$transactionCode != ''">
            <xsl:choose>
                <xsl:when test="count(TradePartner)>0">
                    <xsl:if test="$transactionCode = '10A' or $transactionCode = '09A' or (SumOfPartnerAmounts != '' and string(number(SumOfPartnerAmounts)) != 'NaN' and string(number(SumOfPartnerAmounts)) != '-')">
						<xsl:variable name="gasCode" select="../GasCode"/>
                        <!-- Inserting trade partners related transaction-->
                        <xsl:for-each select="TradePartner">
                            <xsl:if test="(amount != '' and string(number(amount)) != 'NaN' and amount != '-')"><!-- or normalize-space(Comment) != ''">-->
                                <xsl:variable name="tradepartnerId" select="./TradePartnerID"/>
                                <xsl:variable name="partner" select="//*[contains(name(.), concat('tr_', $transactionCode, '_TradePartners'))]/Partner[./PartnerId= $tradepartnerId]"/>
								<xsl:text>INSERT INTO data_report_values (report_id,Transaction_code,gas_ID,Gas_name,trade_partner,trade_partner_EU,trade_partner_EU_VAT_no,trade_partner_nonEU_OR,trade_partner_nonEU_OR_VAT_no,trade_partner_nonEU_portal_code,trade_partner_nonEU_country,num_value,unit_name_short,description_reporter,description_reporter_transaction,qc_warning,qc_warning_trade_partner) VALUES ( </xsl:text>
                                <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
								<xsl:call-template name="code_2015"><xsl:with-param name="value" select="$transactionCode"/></xsl:call-template><xsl:text>,</xsl:text>

                                <xsl:call-template name="string"><xsl:with-param name="value" select="$gasCode"/></xsl:call-template><xsl:text>,</xsl:text>
								<xsl:call-template name="getGasName"><xsl:with-param name="gasId" select="$gasCode"/></xsl:call-template><xsl:text>,</xsl:text>

                                <xsl:variable name="tradepartnerName" select="$partner/CompanyName"/>
                                <xsl:call-template name="string"><xsl:with-param name="value" select="$tradepartnerName"/></xsl:call-template><xsl:text>,</xsl:text>

                                <xsl:variable name="isEUBased" select="$partner/isEUBased"/>
                                <xsl:call-template name="boolean"><xsl:with-param name="value" select="$isEUBased"/></xsl:call-template><xsl:text>,</xsl:text>

                                <xsl:variable name="EUVAT" select="$partner/EUVAT"/>
                                <xsl:call-template name="string"><xsl:with-param name="value" select="$EUVAT"/></xsl:call-template><xsl:text>,</xsl:text>

                                <xsl:variable name="NonEURepresentativeName" select="$partner/NonEURepresentativeName"/>
                                <xsl:call-template name="string"><xsl:with-param name="value" select="$NonEURepresentativeName"/></xsl:call-template><xsl:text>,</xsl:text>

                                <xsl:variable name="NonEURepresentativeVAT" select="$partner/NonEURepresentativeVAT"/>
                                <xsl:call-template name="string"><xsl:with-param name="value" select="$NonEURepresentativeVAT"/></xsl:call-template><xsl:text>,</xsl:text>

                                <xsl:variable name="NonEUDgClimaRegCode" select="$partner/NonEUDgClimaRegCode"/>
                                <xsl:call-template name="string"><xsl:with-param name="value" select="$NonEUDgClimaRegCode"/></xsl:call-template><xsl:text>,</xsl:text>

                                <xsl:call-template name="getCountryCode"><xsl:with-param name="country" select="$partner/NonEUCountryCodeOfEstablishment"/></xsl:call-template><xsl:text>,</xsl:text>

                                <xsl:call-template name="number"><xsl:with-param name="value" select="amount"/></xsl:call-template><xsl:text>,</xsl:text>
								<xsl:call-template name="getUnit"><xsl:with-param name="transactionCode" select="$transactionCode"/></xsl:call-template><xsl:text>,</xsl:text>
								<xsl:call-template name="getComment"><xsl:with-param name="transactionCode" select="$transactionCode"/></xsl:call-template><xsl:text>,</xsl:text>
								<xsl:call-template name="getTransactionComment"><xsl:with-param name="transactionCode" select="$transactionCode"/></xsl:call-template><xsl:text>,</xsl:text>

								<xsl:call-template name="getQCWarnings"><xsl:with-param name="gasId" select="$gasCode"/></xsl:call-template><xsl:text>,</xsl:text>
								<xsl:variable name="qcWarnings"><xsl:call-template name="join"><xsl:with-param name="valueList" select="$partner/QCWarning"/></xsl:call-template></xsl:variable>
								<xsl:call-template name="string"><xsl:with-param name="value" select="$qcWarnings"/></xsl:call-template>

                                <xsl:text>);</xsl:text><xsl:call-template name="statementSeparator"/>
							</xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="(Amount != '' and string(number(Amount)) != 'NaN' and Amount != '-')"><!-- or normalize-space(Comment) != ''">--><xsl:text>INSERT INTO data_report_values (report_id,Transaction_code,gas_ID,Gas_name,num_value,unit_name_short,description_reporter,description_reporter_transaction, calculated,qc_warning) VALUES (</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
						<xsl:call-template name="code_2015"><xsl:with-param name="value" select="$transactionCode"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="../GasCode"/></xsl:call-template><xsl:text>,</xsl:text>
						<xsl:call-template name="getGasName"><xsl:with-param name="gasId" select="../GasCode"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="number"><xsl:with-param name="value" select="Amount"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="getUnit"><xsl:with-param name="transactionCode" select="$transactionCode"/></xsl:call-template><xsl:text>,</xsl:text>
						<xsl:call-template name="getComment"><xsl:with-param name="transactionCode" select="$transactionCode"/></xsl:call-template><xsl:text>,</xsl:text>
						<xsl:call-template name="getTransactionComment"><xsl:with-param name="transactionCode" select="$transactionCode"/></xsl:call-template><xsl:text>,</xsl:text>
						<xsl:call-template name="boolean"><xsl:with-param name="value" select="local-name(../.) = 'SumOfAllGasesS2'"/></xsl:call-template><xsl:text>,</xsl:text>
						<xsl:call-template name="getQCWarnings"><xsl:with-param name="gasId" select="../GasCode"/></xsl:call-template>
                        <xsl:text>);</xsl:text><xsl:call-template name="statementSeparator"/>
					</xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="text()"/>
	<xsl:template name="statementSeparator">
		<xsl:text>
</xsl:text></xsl:template>

    <xsl:template name="code_2015">
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:choose>
					<xsl:when test="$value = '05C'"><xsl:text>'5C_exempted'</xsl:text></xsl:when>
					<xsl:when test="$value = '05R'"><xsl:text>'5C_voluntary'</xsl:text></xsl:when>
                    <xsl:when test="(substring($value,1,2)= '11' and string-length($value) > 3 and substring($value,4,1)='0')"> <xsl:text>'</xsl:text>
                        <xsl:call-template name="globalReplace">
                            <xsl:with-param name="text" select="concat(substring($value,1,3),substring($value,5))"/>
                        </xsl:call-template>
                        <xsl:text>'</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with($value, '0')"> <xsl:text>'</xsl:text>
                        <xsl:call-template name="globalReplace">
                            <xsl:with-param name="text" select="substring-after($value,'0')"/>
                        </xsl:call-template>
                        <xsl:text>'</xsl:text>
                    </xsl:when>

                    <xsl:otherwise> <xsl:text>'</xsl:text>
                        <xsl:call-template name="globalReplace">
                            <xsl:with-param name="text" select='$value'/>
                        </xsl:call-template>
                        <xsl:text>'</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>NULL</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	<xsl:template name="getGasName">
		<xsl:param name="gasId"/>

		<xsl:variable name="gasName">
			<xsl:choose>
				<xsl:when test="/FGasesReporting/ReportedGases[GasId=$gasId]/IsCustomComposition = 'true'">
					<xsl:value-of select="/FGasesReporting/ReportedGases[GasId=$gasId]/Code"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="/FGasesReporting/ReportedGases[GasId=$gasId]/Name"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="string"><xsl:with-param name="value" select="$gasName"/></xsl:call-template>
	</xsl:template>

	<xsl:template name="join" >
		<xsl:param name="valueList"/>
		<xsl:param name="separator" select="','"/>
		<xsl:for-each select="$valueList">
			<xsl:choose>
				<xsl:when test="position() = 1">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($separator, .) "/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="getCountryCode" >
		<xsl:param name="country"/>
		<xsl:variable name="countryCode">
			<xsl:choose>
				<xsl:when test="local-name(.) = 'NonEUCountryCodeOfEstablishment' and string-length(.) = 0">
					<xsl:choose>
						<xsl:when test="string-length($country/../NonEUCountryOfEstablishment) > 2 and contains($country/../NonEUCountryOfEstablishment, '[') and contains($country/../NonEUCountryOfEstablishment, ']')">
							<xsl:value-of select="substring-after(substring-before($country/../NonEUCountryOfEstablishment, ']'), '[')"/>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="$country/../NonEUCountryOfEstablishment"/></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$country"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="string"><xsl:with-param name="value" select="$countryCode"/></xsl:call-template>
	</xsl:template>
	<xsl:template name="getUnit" >
		<xsl:param name="transactionCode"/>
		<xsl:variable name="unit">
			<xsl:choose>
				<xsl:when test="starts-with($transactionCode, '9')">t_gwp_ar4</xsl:when>
				<xsl:when test="starts-with($transactionCode, '11') and (local-name(../.) = 'AmountOfImportedEquipment' or local-name(../.) = 'SumOfAllGasesS2')">
					<xsl:choose>
						<xsl:when test="$transactionCode = '11H01' or $transactionCode = '11H02'">m3</xsl:when>
						<xsl:when test="$transactionCode = '11H03' or $transactionCode = '11J' or $transactionCode = '11K'">container</xsl:when>
						<xsl:when test="$transactionCode = '11H04'"><xsl:call-template name="getUnitCodeProdEqu"><xsl:with-param name="webformCode"><xsl:value-of select="../../TR_11H4_Unit"/></xsl:with-param></xsl:call-template></xsl:when>
						<xsl:when test="$transactionCode = '11P'"><xsl:call-template name="getUnitCodeProdEqu"><xsl:with-param name="webformCode"><xsl:value-of select="../../TR_11P_Unit"/></xsl:with-param></xsl:call-template></xsl:when>
						<xsl:otherwise>piece</xsl:otherwise><!-- pieces of equipment -->
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>t</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="parsedUnit">
			<xsl:choose>
				<xsl:when test="local-name(../.) = 'SumOfAllGasesS2'"><xsl:value-of select="concat('kg/', $unit)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$unit"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="string"><xsl:with-param name="value" select="$parsedUnit"/></xsl:call-template>
	</xsl:template>
	<xsl:template name="getUnitCode">
		<xsl:param name="webformCode"/>
		<xsl:choose>
			<xsl:when test="$webformCode = 'cubicmetres'">m3</xsl:when>
			<xsl:when test="$webformCode = 'metrictonnes'">t</xsl:when>
			<xsl:when test="$webformCode = 'pieces'">pieces</xsl:when>
			<xsl:otherwise>pieces</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="getUnitCodeProdEqu">
		<xsl:param name="webformCode"/>
		<xsl:choose>
			<xsl:when test="$webformCode = 'cubicmetres'">m3</xsl:when>
			<xsl:when test="$webformCode = 'metrictonnes'">t</xsl:when>
			<xsl:when test="$webformCode = 'pieces'">piece</xsl:when>
			<xsl:otherwise>piece</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getComment">
		<xsl:param name="transactionCode"/>
		<xsl:variable name="transactionElemName" select="local-name()"/>
		<xsl:variable name="comment">
			<xsl:choose>
				<xsl:when test="starts-with($transactionCode, '11') and local-name(../.) = 'AmountOfImportedEquipment'">
					<xsl:value-of select="../../Category/*[local-name() = $transactionElemName]"/>
				</xsl:when>
				<xsl:when test="starts-with($transactionCode, '11') and local-name(../.) = 'SumOfAllGasesS2'">
					<xsl:value-of select="../../Comment/*[local-name() = $transactionElemName]"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="Comment"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="string"><xsl:with-param name="value" select="$comment"/></xsl:call-template>
	</xsl:template>

	<xsl:template name="getTransactionComment" >
		<xsl:param name="transactionCode"/>
		<xsl:variable name="transactionElemName" select="local-name()"/>
		<xsl:variable name="comment">
			<xsl:choose>
				<xsl:when test="starts-with($transactionCode, '11') and not(local-name(../.) = 'AmountOfImportedEquipment')">
					<xsl:value-of select="../../Category/*[local-name() = $transactionElemName]"/>
				</xsl:when>
				<!-- get tr 5A and 5B comments if they are inserted into 0 total fields -->
				<xsl:when test="$transactionCode='05A' and normalize-space(../Comment) = '' and count(//Gas/tr_05A[normalize-space(Comment) != '' and SumOfPartnerAmounts = 0]) > 0">
					<xsl:value-of select="//Gas/tr_05A[normalize-space(Comment) != '' and SumOfPartnerAmounts = 0]/Comment[1]"/>
				</xsl:when>
				<xsl:when test="$transactionCode='05B' and normalize-space(../Comment) = '' and count(//Gas/tr_05B[normalize-space(Comment) != '' and SumOfPartnerAmounts = 0]) > 0">
					<xsl:value-of select="//Gas/tr_05B[normalize-space(Comment) != '' and SumOfPartnerAmounts = 0]/Comment[1]"/>
				</xsl:when>
				<!-- Check if there are any other transaction based comments -->
				<xsl:otherwise><xsl:value-of select="../Comment"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="string"><xsl:with-param name="value" select="$comment"/></xsl:call-template>
	</xsl:template>

	<xsl:template name="getQCWarnings" >
		<xsl:param name="gasId"/>
		<xsl:variable name="transactionElemName" select="local-name()"/>
		<xsl:variable name="qcWarning">
			<xsl:call-template name="join">
				<xsl:with-param name="valueList" select="../../../unusualGasChoises/unusualGas[gasId = $gasId and transaction = $transactionElemName]/qc"/>
				<xsl:with-param name="separator" select="','"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="string"><xsl:with-param name="value" select="$qcWarning"/></xsl:call-template>
	</xsl:template>

	<xsl:template match="qcWarningFlags">
		<xsl:for-each select="flag">
			<xsl:text>INSERT INTO data_qc_warnings(report_id, transactionCode, qcCode, gasId, isEUBased, EUVAT, NonEUDgClimaRegCode, comment) VALUES (</xsl:text>
			<xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
			<xsl:variable name="transactionCode" select="transactionCode"/>
			<xsl:call-template name="string"><xsl:with-param name="value" select="$transactionCode"/></xsl:call-template><xsl:text>,</xsl:text>
			<xsl:call-template name="string"><xsl:with-param name="value" select="qcCode"/></xsl:call-template><xsl:text>,</xsl:text>
			<xsl:call-template name="string"><xsl:with-param name="value" select="gasId"/></xsl:call-template><xsl:text>,</xsl:text>
			<xsl:variable name="tradepartnerId" select="tradePartnerId"/>
			<xsl:variable name="partner" select="//*[contains(name(), concat($transactionCode, '_TradePartners'))]/Partner[./PartnerId = $tradepartnerId]"/>

			<xsl:variable name="isEUBased" select="$partner/isEUBased"/>
			<xsl:call-template name="boolean"><xsl:with-param name="value" select="$isEUBased"/></xsl:call-template><xsl:text>,</xsl:text>

			<xsl:variable name="EUVAT" select="$partner/EUVAT"/>
			<xsl:call-template name="string"><xsl:with-param name="value" select="$EUVAT"/></xsl:call-template><xsl:text>,</xsl:text>

			<xsl:variable name="NonEUDgClimaRegCode" select="$partner/NonEUDgClimaRegCode"/>
			<xsl:call-template name="string"><xsl:with-param name="value" select="$NonEUDgClimaRegCode"/></xsl:call-template><xsl:text>,</xsl:text>
			<xsl:call-template name="string"><xsl:with-param name="value" select="comment"/></xsl:call-template>
			<xsl:text>);</xsl:text><xsl:call-template name="statementSeparator"/>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>