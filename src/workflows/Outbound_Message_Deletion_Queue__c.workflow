<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>OMDQ_WR01_CRM_Insert_Outbound</fullName>
        <actions>
            <name>OMDQ_OB01_CRM_Insert</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>CRM-QI-ESPSFDCQI-784 - Workflow to send outbound message when Outbound_Message_Deletion_queue__c record is inserted</description>
        <formula>$Setup.Mulesoft_Integration_Control__c.Suppress_Outbound_Messages__c == false &amp;&amp; ( LI_Id__c != null || LQ_Id__c != null)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
