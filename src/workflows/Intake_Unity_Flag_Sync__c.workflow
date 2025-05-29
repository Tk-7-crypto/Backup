<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Intake Unity Flag Sync</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Intake_Unity_Flag_Sync__c.Mulesoft_Sync_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
