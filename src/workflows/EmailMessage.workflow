<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CAS_WFU16_CSM_CaseStatusInProgress</fullName>
        <description>CSM - ACN - S-0006 - Case status In Progress when email received</description>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>CAS_WFU16_CSM_CaseStatusInProgress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAS_WFU44_CSM_UpdateCaseAFUToFalse</fullName>
        <field>AFU_TECH__c</field>
        <literalValue>0</literalValue>
        <name>CAS WFU44 CSM UpdateCaseAFUToFalse</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EME_WFU01_CSM_EmailNotificationCount</fullName>
        <description>CSM-ACN-S-0001 - Immediate action that will update number of messages sent.</description>
        <field>NumberOfNotifications__c</field>
        <formula>IF(ISBLANK( Parent.NumberOfNotifications__c ), 1,  Parent.NumberOfNotifications__c + 1)</formula>
        <name>EME_WFU01_CSM_EmailNotificationCount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updateCaseRecordStatus</fullName>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>updateCaseRecordStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>CAS_WR71_CSM_TrackIncomingCaseEmail</fullName>
        <actions>
            <name>CAS_WFU44_CSM_UpdateCaseAFUToFalse</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseNumber</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.AFU_TECH__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Track incoming case email that validate record type = &apos;TechnologyCase&apos; and AFU_TECH = &apos;True&apos;
then uncheck Automated follow up</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EME WR03 CSM ReopenClosedCase</fullName>
        <actions>
            <name>updateCaseRecordStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>CSM-US-0352-Reopen case if within 3 days of closure</description>
        <formula>AND(IF(Incoming, TRUE, FALSE),                 IF(Parent.IsClosed, TRUE, FALSE),                 Parent.CurrentQueue__r.Name = &quot;Data GLOBAL E-SERVICE&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EME_WR01_CSM_EmailNotificationWorkflow</fullName>
        <actions>
            <name>EME_WFU01_CSM_EmailNotificationCount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <description>CSM-ACN-S-0001 - Gives count for email sent</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EME_WR02_CSM_StatusInProgressWhenEmailReceived</fullName>
        <actions>
            <name>CAS_WFU16_CSM_CaseStatusInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>New</value>
        </criteriaItems>
        <description>CSM - ACN - S-0006 - Status change to in progress when email received</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
