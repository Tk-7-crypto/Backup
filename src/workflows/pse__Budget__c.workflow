<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PSA_Budget_Set_Approved_Flag</fullName>
        <description>Set Approved Flag to true</description>
        <field>pse__Approved__c</field>
        <literalValue>1</literalValue>
        <name>PSA Budget Set Approved Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Budget_Set_Include_in_Financials</fullName>
        <description>Set Include In Financials to true</description>
        <field>pse__Include_In_Financials__c</field>
        <literalValue>1</literalValue>
        <name>PSA Budget Set Include in Financials</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Budget_Unset_Approved_Flag</fullName>
        <description>Set Approved to false</description>
        <field>pse__Approved__c</field>
        <literalValue>0</literalValue>
        <name>PSA Budget Unset Approved Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Budget_Unset_Include_In_Financials</fullName>
        <description>Set Include in Financial to false</description>
        <field>pse__Include_In_Financials__c</field>
        <literalValue>0</literalValue>
        <name>PSA Budget Unset Include In Financials</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BGT_WR01_PSA_CLD_StatusSetToDraftRejected</fullName>
        <actions>
            <name>PSA_Budget_Unset_Approved_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Budget_Unset_Include_In_Financials</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>pse__Budget__c.pse__Status__c</field>
            <operation>equals</operation>
            <value>Draft,Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Budget__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RDS Budget</value>
        </criteriaItems>
        <description>USNONE - When the Budget is set to Draft or Rejected the workflow will un-check the include in financials and approved flag</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BGT_WR02_PSA_CLD_BudgetStatusSetToOpenApproved</fullName>
        <actions>
            <name>PSA_Budget_Set_Approved_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Budget_Set_Include_in_Financials</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>pse__Budget__c.pse__Status__c</field>
            <operation>equals</operation>
            <value>Open,Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Budget__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RDS Budget</value>
        </criteriaItems>
        <description>USNONE - When the Budget is set to Open or Approved the workflow will check the include in financials flag and the Approved flag</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
