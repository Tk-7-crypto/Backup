<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CPQ_TSL_Offline_Alert</fullName>
        <description>CPQ TSL Offline Alert</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_TSL_Offline_Approval_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>TSL_FLAG_CHECK</fullName>
        <description>Once email alert is send make this field value as blank</description>
        <field>TSL_Approve_Offline__c</field>
        <literalValue>0</literalValue>
        <name>TSL FLAG CHECK</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CPQ-TSL Offline Approval Notification</fullName>
        <actions>
            <name>CPQ_TSL_Offline_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>TSL_FLAG_CHECK</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Team_Member__c.TSL_Approve_Offline__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c</field>
            <operation>equals</operation>
            <value>Sign Off</value>
        </criteriaItems>
        <criteriaItems>
            <field>Apttus_Proposal__Proposal__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Review Approved and Submitted for Final SignOff</value>
        </criteriaItems>
        <description>CPQ- LC-7407 -Send email notification to TSL approval that requested record is approved offline by PD</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
