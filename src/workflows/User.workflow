<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>USR_OB01_CRM_InsertUpdate</fullName>
        <apiVersion>42.0</apiVersion>
        <description>CRM-QI-ESPSFDCQI-1512 Outbound message when user is updated</description>
        <endpointUrl>https://espsfdciqviaprodproxy.cloudhub.io/mainapp?client_id=13cb49225e2a418e8fea3913f4b6fc24&amp;client_secret=1a2bf07f40D7475d909f625C27b04F29</endpointUrl>
        <fields>Id</fields>
        <fields>LI_User_Id__c</fields>
        <fields>LI_User_License_Type__c</fields>
        <fields>LQ_User_Id__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>sduncan@uk.imshealth.com.qi</integrationUser>
        <name>USR_OB01_CRM_InsertUpdate</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>USR_WR01_CRM_InsertUpdate_Outbound</fullName>
        <actions>
            <name>USR_OB01_CRM_InsertUpdate</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>CRM-QI-ESPSFDCQI-1512 Workflow to send outbound message when User record is updated</description>
        <formula>$Setup.Mulesoft_Integration_Control__c.Suppress_Outbound_Messages__c == FALSE &amp;&amp;  ( (ISNEW() &amp;&amp; (LQ_User_Id__c != null || LI_User_Id__c != null )) || ischanged(LQ_User_Id__c) || ischanged(LI_User_Id__c) || ischanged (ProfileId))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
