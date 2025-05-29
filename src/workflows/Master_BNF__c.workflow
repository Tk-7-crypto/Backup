<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Master_BNF_Approved_Notification_From_JP01</fullName>
        <description>Master BNF Approved Notification From JP01</description>
        <protected>false</protected>
        <recipients>
            <recipient>JP01_Billing_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Master_BNF_Approval_Notification1</template>
    </alerts>
    <alerts>
        <fullName>Master_BNF_Approved_Notification_From_JP71_JP72</fullName>
        <description>Master BNF Approved Notification From JP71&amp;JP72</description>
        <protected>false</protected>
        <recipients>
            <recipient>JP71_JP72_Billing_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Master_BNF_Approval_Notification1</template>
    </alerts>
    <alerts>
        <fullName>Master_BNF_Rejection_Notification_From_Japan_Finance_JP01</fullName>
        <description>Master BNF Rejection Notification From Japan Finance JP01</description>
        <protected>false</protected>
        <recipients>
            <recipient>JP01_Billing_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/MasterBNFRejectedBNFrecordrejected</template>
    </alerts>
    <alerts>
        <fullName>Master_BNF_Rejection_Notification_From_Japan_Finance_JP71_JP72</fullName>
        <description>Master BNF Rejection Notification From Japan Finance JP71&amp;JP72</description>
        <protected>false</protected>
        <recipients>
            <recipient>JP71_JP72_Billing_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/MasterBNFRejectedBNFrecordrejected</template>
    </alerts>
    <alerts>
        <fullName>Master_BNF_Rejection_Notification_From_SBS</fullName>
        <description>Master BNF Rejection Notification From SBS</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <recipient>JP01_Billing_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/MasterBNFRejectedBNFrecordrejected</template>
    </alerts>
    <alerts>
        <fullName>Master_BNF_Submit_Notification_Japan</fullName>
        <description>Master BNF Submit Notification Japan</description>
        <protected>false</protected>
        <recipients>
            <recipient>JP01_Billing_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Master_BNF_Approvals_New_BNF_record_submitted_notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_BNF_Status_To_Accepted</fullName>
        <field>BNF_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>Update BNF Status To Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_BNF_Status_To_Rejected</fullName>
        <field>BNF_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update BNF Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_BNF_Status_on_New</fullName>
        <field>BNF_Status__c</field>
        <literalValue>New</literalValue>
        <name>Update BNF Status on New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Master_BNF_Status</fullName>
        <field>BNF_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Update Master BNF Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
