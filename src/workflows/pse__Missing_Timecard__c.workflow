<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PSA_Missing_Timecard_Email_Alert</fullName>
        <description>PSA Missing Timecard Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>pse__Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Missing_Timecard_Notification</template>
    </alerts>
    <rules>
        <fullName>PSA Missing Timecard Notification</fullName>
        <actions>
            <name>PSA_Missing_Timecard_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>pse__Missing_Timecard__c.pse__Date_Timecard_Entered__c</field>
            <operation>lessThan</operation>
            <value>1/1/2011</value>
        </criteriaItems>
        <description>PSA - Notifies resource on Tuesday if a timecard has is not in submitted or approved status for previous week.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
