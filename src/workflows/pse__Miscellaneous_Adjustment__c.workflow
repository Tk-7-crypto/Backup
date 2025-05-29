<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MSC_WFU01_PSA_SetApprovedFlag</fullName>
        <description>PSA-CLD-USNONE- Set Approved Flag on MSC</description>
        <field>pse__Approved__c</field>
        <literalValue>1</literalValue>
        <name>MSC_WFU01_PSA_SetApprovedFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MSC_WFU02_PSA_ExcludeFromBilling</fullName>
        <description>PSA-CLD-USNONE- Set Exclude from Billing to true</description>
        <field>pse__Exclude_from_Billing__c</field>
        <literalValue>1</literalValue>
        <name>MSC_WFU02_PSA_ExcludeFromBilling</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MSC_WFU03_PSA_SetIIFFlag</fullName>
        <description>PSA-CLD-USNONE- Set IIF Flag</description>
        <field>pse__Include_In_Financials__c</field>
        <literalValue>1</literalValue>
        <name>MSC_WFU03_PSA_SetIIFFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MSC_WFU04_PSA_UnsetApprovedFlag</fullName>
        <description>PSA-CLD-USNONE- Unset Approved Flag</description>
        <field>pse__Approved__c</field>
        <literalValue>0</literalValue>
        <name>MSC_WFU04_PSA_UnsetApprovedFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MSC_WFU05_PSA_UnsetExcludeBilling</fullName>
        <description>PSA-CLD-USNONE- Set Exclude from Billing to false</description>
        <field>pse__Exclude_from_Billing__c</field>
        <literalValue>0</literalValue>
        <name>MSC_WFU05_PSA_UnsetExcludeBilling</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MSC_WFU06_PSA_UnsetIIFFlag</fullName>
        <description>PSA-CLD-USNONE- Unset IIF Flag</description>
        <field>pse__Include_In_Financials__c</field>
        <literalValue>0</literalValue>
        <name>MSC_WFU06_PSA_UnsetIIFFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>MSC_WR01_PSA_CLD_StatusSettoApproved</fullName>
        <actions>
            <name>MSC_WFU01_PSA_SetApprovedFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MSC_WFU03_PSA_SetIIFFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>pse__Miscellaneous_Adjustment__c.pse__Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>PSA-CLD-USNONE-When the Miscellaneous Adjustment status is set to approved, the approved and IIF flag will get set.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MSC_WR02_PSA_CLD_StatusSettoNotApproved</fullName>
        <actions>
            <name>MSC_WFU04_PSA_UnsetApprovedFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MSC_WFU06_PSA_UnsetIIFFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>pse__Miscellaneous_Adjustment__c.pse__Status__c</field>
            <operation>notEqual</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>PSA-CLD-USNONE-When the Miscellaneous Adjustment status is set to Not Approved, the approved and IIF flag will get unset.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MSC_WR03_PSA_CLD_AmountNotEqualToZero</fullName>
        <actions>
            <name>MSC_WFU05_PSA_UnsetExcludeBilling</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-USNONE-If Amount is Not Equal to zero, set Exclude from Billing to false</description>
        <formula>pse__Amount__c &lt;&gt; 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MSC_WR04_PSA_CLD_AmountIsZero</fullName>
        <actions>
            <name>MSC_WFU02_PSA_ExcludeFromBilling</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-USNONE-If Amount is zero, set Exclude from Billing to true</description>
        <formula>pse__Amount__c = 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
