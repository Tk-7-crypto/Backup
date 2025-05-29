<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:s="http://soap.sforce.com/2006/04/metadata" version="1.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" xslt:indent-amount="4" xmlns:xslt="http://xml.apache.org/xslt"/>

    <xsl:template match="s:LeadConvertSettings">
	    <xsl:copy>
	        <xsl:apply-templates select="s:allowOwnerChange">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:objectMapping">
				<xsl:sort select="s:outputObject"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="s:opportunityCreationOptions">
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="s:LeadConvertSettings/s:objectMapping">
		<xsl:copy>
			<xsl:apply-templates select="s:inputObject">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:mappingFields">
				<xsl:sort select="s:outputField"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="s:outputObject">
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>