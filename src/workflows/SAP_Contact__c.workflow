<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Notification</fullName>
        <description>Approval Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SAP_ET02_CRM_MDM_APPROVED</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Notification</fullName>
        <description>Rejection Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SAP_ET03_CRM_MDM_REJECTED</template>
    </alerts>
    <alerts>
        <fullName>SAPContact_Submitter_Notification</fullName>
        <description>SAPContact Submitter Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SAP_ET04_CRM_SAPContactSubmitterEmailTemplate</template>
    </alerts>
    <fieldUpdates>
        <fullName>MDM_Unvalidated</fullName>
        <field>MDM_Validation_Status__c</field>
        <literalValue>Unvalidated</literalValue>
        <name>MDM Unvalidated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MDM_Date</fullName>
        <field>MDM_Latest_Submission_Date__c</field>
        <formula>NOW()</formula>
        <name>Update MDM Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MDM_Date3</fullName>
        <field>MDM_Latest_Submission_Date__c</field>
        <name>Update MDM Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MDM_Date4</fullName>
        <field>MDM_Latest_Submission_Date__c</field>
        <name>Update MDM Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MDM_Status</fullName>
        <field>MDM_Validation_Status__c</field>
        <literalValue>Pending Validation</literalValue>
        <name>Update MDM Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MDM_Status1</fullName>
        <field>MDM_Validation_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update MDM Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MDM_Status4</fullName>
        <field>MDM_Validation_Status__c</field>
        <literalValue>Validated</literalValue>
        <name>Update MDM Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
