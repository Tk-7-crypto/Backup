<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>BEV_WFU01_PSA_SetProjectCode</fullName>
        <description>Sets the project code on the billing event</description>
        <field>Project_Code__c</field>
        <formula>pse__Project__r.Project_Code__c</formula>
        <name>BEV_WFU01_PSA_SetProjectCode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BEV_WFR01_PSA_SetProjectCode</fullName>
        <actions>
            <name>BEV_WFU01_PSA_SetProjectCode</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sets the project code on the billing event when the project value changes.</description>
        <formula>ISNEW() ||  ISCHANGED( pse__Project__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
