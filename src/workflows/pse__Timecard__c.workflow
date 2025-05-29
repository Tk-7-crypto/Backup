<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PSA_TC_Split_Set_Exclude_From_Billing</fullName>
        <field>pse__Exclude_from_Billing__c</field>
        <literalValue>1</literalValue>
        <name>PSA TC Split Set Exclude From Billing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_TC_Split_Unset_Exclude_From_Billing</fullName>
        <field>pse__Exclude_from_Billing__c</field>
        <literalValue>0</literalValue>
        <name>PSA TC Split Unset Exclude From Billing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PSA TC Split Total Billable Not Equal to Zero</fullName>
        <actions>
            <name>PSA_TC_Split_Unset_Exclude_From_Billing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>pse__Timecard__c.pse__Total_Billable_Amount__c</field>
            <operation>notEqual</operation>
            <value>USD 0</value>
        </criteriaItems>
        <description>This rule will unset Exclude from billing if the timecard split total billable amount is not equal to zero.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PSA Timecard Split Total Billable Equals Zero</fullName>
        <actions>
            <name>PSA_TC_Split_Set_Exclude_From_Billing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>pse__Timecard__c.pse__Total_Billable_Amount__c</field>
            <operation>equals</operation>
            <value>USD 0</value>
        </criteriaItems>
        <description>This rule will set Exclude from billing if the timecard split total billable amount is equal to zero.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
