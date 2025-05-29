<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PLG_WEA_01_New_Project_Log_Notification</fullName>
        <description>PLG WEA 01 New Project Log Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/PLG_ET_01_New_Project_Log_Alert</template>
    </alerts>
    <rules>
        <fullName>PLG WR 01 New Project Log Notification</fullName>
        <actions>
            <name>PLG_WEA_01_New_Project_Log_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project_Log__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>GRA Metric Issue</value>
        </criteriaItems>
        <description>PSA-CLD-IQVIAPSA-1293</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
