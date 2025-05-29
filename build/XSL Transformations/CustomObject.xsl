<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:s="http://soap.sforce.com/2006/04/metadata" version="1.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" xslt:indent-amount="4" xmlns:xslt="http://xml.apache.org/xslt"/>
	<xsl:strip-space elements="CustomObject *"/>
	<xsl:template match="s:CustomObject">
	    <xsl:copy>
			<xsl:apply-templates select="s:actionOverrides">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:allowInChatterGroups">
			</xsl:apply-templates>
	        <xsl:apply-templates select="s:businessProcesses">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:compactLayoutAssignment">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:compactLayouts">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:customHelp">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:customHelpPage">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:customSettingsType">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:customSettingsVisibility">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:dataStewardGroup">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:dataStewardUser">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:deploymentStatus">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:deprecated">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:description">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:enableActivities">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:enableBulkApi">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:enableDivisions">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:enableEnhancedLookup">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:enableFeeds">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:enableHistory">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:enableLicensing">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:enableReports">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:enableSearch">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:enableSharing">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:enableStreamingApi">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:eventType">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:externalDataSource">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:externalName">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:externalRepository">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:externalSharingModel">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:fields">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:fieldSets">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:fullName">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:gender">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:household">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:historyRetentionPolicy">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:indexes">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:label">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:namedFilter">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:nameField">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:pluralLabel">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:profileSearchLayouts">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:publishBehavior">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:recordTypes">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:recordTypeTrackFeedHistory">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:recordTypeTrackHistory">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:searchLayouts">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:sharingModel">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:sharingReasons">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:sharingRecalculations">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:startsWith">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:validationRules">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:visibility">
			</xsl:apply-templates>
			<xsl:apply-templates select="s:webLinks">
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>