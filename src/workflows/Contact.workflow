<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CNT_WEA01_CRM_Inactive_contact_notification_due_to_invalid_email</fullName>
        <description>CRM-MC-ESPSFDCQI-390 - Inactive contact notification due to invalid email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/Inactive_Contact_Notification_due_to_Invalid_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>CAS_WFU06_CSM_PopulateSourceWithSalesfor</fullName>
        <description>CSM - ACN - S0062 - Populate Source with Salesforce</description>
        <field>Source__c</field>
        <formula>IF( ISBLANK( Source__c ) , &quot;Salesforce&quot;,  Source__c )</formula>
        <name>CAS_WFU06_CSM_PopulateSourceWithSalesfor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CAS_WR12_CSM_PopulateSourceWithSalesforce</fullName>
        <actions>
            <name>CAS_WFU06_CSM_PopulateSourceWithSalesfor</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>CSM - ACN - S0062 - Populate Source With Salesforce</description>
        <formula>ISBLANK( Source__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CNT_WR01_CRM_Outbound_Invalid_Contact_Notification</fullName>
        <actions>
            <name>CNT_WEA01_CRM_Inactive_contact_notification_due_to_invalid_email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Inactive_Reason__c</field>
            <operation>equals</operation>
            <value>Invalid Email Address</value>
        </criteriaItems>
        <description>CRM-MC-ESPSFDCQI-390 -  Alert to contact owner when contact inactive due to invalid email</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTC_WR01_CRM_InsertUpdate_Outbound</fullName>
        <actions>
            <name>CTC_OB01_CRM_InsertUpdate</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>CRM-QI-ESPSFDCQI-502 - Workflow to send outbound message when Contact record is inserted or updated.</description>
        <formula>$Setup.Mulesoft_Integration_Control__c.Suppress_Outbound_Messages__c == false &amp;&amp; RecordType.DeveloperName != &apos;IQVIA_User_Contact&apos; &amp;&amp; Send_Mulesoft_Outbound_Msg__c == true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CTC_WR01_CRM_LeadScoreTransitionsContact</fullName>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-392 - This workflow rule will be used to alert sales when lead score transitions occur favorably</description>
        <formula>OR( AND( PRIORVALUE(Lead_Score__c) = &quot;A2&quot;, Lead_Score__c = &quot;A1&quot; ), AND( PRIORVALUE(Lead_Score__c) = &quot;A3&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ), AND( PRIORVALUE(Lead_Score__c) = &quot;A4&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ), AND( PRIORVALUE(Lead_Score__c) = &quot;B3&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ), AND( PRIORVALUE(Lead_Score__c) = &quot;B4&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ), AND( PRIORVALUE(Lead_Score__c) = &quot;C1&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ), AND( PRIORVALUE(Lead_Score__c) = &quot;C2&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ), AND( PRIORVALUE(Lead_Score__c) = &quot;C3&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ), AND( PRIORVALUE(Lead_Score__c) = &quot;C4&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ), AND( PRIORVALUE(Lead_Score__c) = &quot;D1&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ), AND( PRIORVALUE(Lead_Score__c) = &quot;D2&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ), AND( PRIORVALUE(Lead_Score__c) = &quot;D3&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ), AND( PRIORVALUE(Lead_Score__c) = &quot;D4&quot;, OR( Lead_Score__c = &quot;A1&quot;, Lead_Score__c = &quot;A2&quot;, Lead_Score__c = &quot;B1&quot;, Lead_Score__c = &quot;B2&quot; ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
