<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:s="http://soap.sforce.com/2006/04/metadata" version="1.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" xslt:indent-amount="4" xmlns:xslt="http://xml.apache.org/xslt"/>

    <xsl:template match="s:Profile">
	    <xsl:copy>
	        <xsl:apply-templates select="s:applicationVisibilities">
				<xsl:sort select="s:application"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="s:classAccesses">
				<xsl:sort select="s:apexClass"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="s:custom">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:customPermissions">
				<xsl:sort select="s:name"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="s:fieldPermissions">
				<xsl:sort select="s:field"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="s:layoutAssignments">
				<xsl:sort select="s:layout"/>
				<xsl:sort select="s:recordType"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="s:objectPermissions">
				<xsl:sort select="s:object"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="s:pageAccesses">
				<xsl:sort select="s:apexPage"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="s:recordTypeVisibilities">
				<xsl:sort select="s:recordType"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="s:tabVisibilities">
				<xsl:sort select="s:tab"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="s:userLicense">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:userPermissions">
				<xsl:sort select="s:name"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>