<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TGT_WFU01_PSA_SetName</fullName>
        <description>PSA-CLD-USNONE- Target Set Name</description>
        <field>Name</field>
        <formula>IF(RecordType.DeveloperName = &apos;RDS_Protocol&apos;,
LEFT(Protocol_Number__c + &apos; &apos; + TEXT(Single_Country__c) + &apos; &apos; + TEXT(Therapeutic_Area__c),255),
IF( RecordType.DeveloperName = &apos;RDS_Country&apos;, TEXT(Single_Country__c) + &apos; &apos; + TEXT(Location__c),
IF( RecordType.DeveloperName = &apos;PV_Agreement&apos;,
LEFT( Program__r.Name  +&apos; &apos; + PVA_ID__c, 80),Name)))</formula>
        <name>TGT_WFU01_PSA_SetName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>TGT_WR01_PSA_CLD_TargetNamingConvention</fullName>
        <actions>
            <name>TGT_WFU01_PSA_SetName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sets the name of the Target based on record type.</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
