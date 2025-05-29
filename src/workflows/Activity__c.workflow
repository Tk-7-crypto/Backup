<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ACT_WFU01_CSM_EscalationTypePass</fullName>
        <description>CSM - ACN - S0127 - Escalation Type Pass</description>
        <field>EscalationType__c</field>
        <literalValue>Pass</literalValue>
        <name>ACT_WFU01_CSM_EscalationTypePass</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WFU02_CSM_ACN_UpdateEmailOutboundExist</fullName>
        <field>Email_Outbound_Exists__c</field>
        <literalValue>1</literalValue>
        <name>WFU02_CSM_ACN_UpdateEmailOutboundExist</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Case__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WFU03_CSM_ACT_UpdateCallOutboundExist</fullName>
        <description>CSM-625 R&amp;D - EDC Activity Validation Rule</description>
        <field>Call_Outbound_Exists__c</field>
        <literalValue>1</literalValue>
        <name>WFU03_CSM_ACT_UpdateCallOutboundExist</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Case__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WFU03_CSM_ACT_UpdateIMCommunicationExist</fullName>
        <description>CSM-625 R&amp;D - EDC Activity Validation Rule</description>
        <field>IM_Communication_Exists__c</field>
        <literalValue>1</literalValue>
        <name>WFU03_CSM_ACT_UpdateIMCommunicationExist</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Case__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>ACT_CSM_UpdateChkbxEmailOutboundExists</fullName>
        <actions>
            <name>WFU02_CSM_ACN_UpdateEmailOutboundExist</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Activity__c.Type__c</field>
            <operation>equals</operation>
            <value>Email - Outbound</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACT_WR01_CSM_EscalationTypePass</fullName>
        <actions>
            <name>ACT_WFU01_CSM_EscalationTypePass</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>CSM - ACN - S0127 - Escalation Type Pass</description>
        <formula>AND(  ISPICKVAL( Type__c , &apos;Quality Check&apos;) ,   ISPICKVAL( Case__r.Template__c , &apos;Alert Communication&apos;),  Case__r.Asset.Product2.Name  = &apos;Q² Lab Investigator Services&apos;,  ISPICKVAL( Case__r.Priority , &apos;Critical&apos;)   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACT_WR02_CSM_UpdateCheckboxCallOutboundExists</fullName>
        <actions>
            <name>WFU03_CSM_ACT_UpdateCallOutboundExist</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Activity__c.Type__c</field>
            <operation>equals</operation>
            <value>Call - Outbound</value>
        </criteriaItems>
        <description>CSM-625 R&amp;D - EDC Activity Validation Rule</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACT_WR02_CSM_UpdateCheckboxIMCommunicationExist</fullName>
        <actions>
            <name>WFU03_CSM_ACT_UpdateIMCommunicationExist</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Activity__c.Type__c</field>
            <operation>equals</operation>
            <value>IM Communication</value>
        </criteriaItems>
        <description>CSM-625 R&amp;D - EDC Activity Validation Rule</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
