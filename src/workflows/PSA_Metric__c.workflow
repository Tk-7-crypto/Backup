<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PMT_WFU02_PSA_Set_NonStandard</fullName>
        <field>Non_Standard__c</field>
        <literalValue>1</literalValue>
        <name>PMT WFU02 PSA Set NonStandard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PMT_WR01_PSA_NewRecord</fullName>
        <active>false</active>
        <description>Fires when a new PSA Metric is created.</description>
        <formula>ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PSA_Metric%5F%5Fc%2EPMT_WR02_PSA_Set_Non_Standard</fullName>
        <actions>
            <name>PMT_WFU02_PSA_Set_NonStandard</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Fires when Account is not -null and sets Non-Standard field.</description>
        <formula>NOT(ISBLANK(Account__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
