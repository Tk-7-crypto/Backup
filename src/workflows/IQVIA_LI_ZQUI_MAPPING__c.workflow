<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>IQL WR01 CRM mulesoft sync pending</fullName>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>IQVIA_LI_ZQUI_MAPPING__c.Mulesoft_Sync_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>ESPSFDCQI-4422</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
