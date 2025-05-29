<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CPQ_IQVIA_Quote_Final_Approval_EmailAlert</fullName>
        <description>CPQ IQVIA Quote Final Approval EmailAlert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_IQVIA_Quote_Final_Approval_Email</template>
    </alerts>
    <alerts>
        <fullName>CPQ_IQVIA_Quote_Final_Rejection_EmailAlert</fullName>
        <description>CPQ IQVIA Quote Final Rejection EmailAlert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_IQVIA_Quote_Final_Rejection_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Stage_Approved</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval Stage-Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Stage_Rejected</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Rejected</literalValue>
        <name>Approval Stage-Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_Approval_Pending</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Field Update -Approval Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Level</fullName>
        <field>Approver_Level__c</field>
        <formula>0</formula>
        <name>Update Approval Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver_1</fullName>
        <field>Approver_1__c</field>
        <name>Update Approver 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver_2</fullName>
        <field>Approver_2__c</field>
        <name>Update Approver 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver_3</fullName>
        <field>Approver_3__c</field>
        <name>Update Approver 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver_4</fullName>
        <field>Approver_4__c</field>
        <name>Update Approver 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver_5</fullName>
        <field>Approver_5__c</field>
        <name>Update Approver 5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Priority</fullName>
        <field>Priority__c</field>
        <formula>Priority__c+2</formula>
        <name>Update Priority</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
