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
        <template>unfiled$public/ADD_ET02_CRM_MDM_APPROVED</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Notification</fullName>
        <description>Rejection Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ADD_ET03_CRM_MDM_REJECTED</template>
    </alerts>
    <alerts>
        <fullName>Submitter_Notification</fullName>
        <description>Address Submitter Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ADD_ET04_CRM_AddressSubmitterEmailTemplate</template>
    </alerts>
    <fieldUpdates>
        <fullName>Desc</fullName>
        <field>Description__c</field>
        <formula>&quot;Temp Value&quot;</formula>
        <name>Desc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
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
        <fullName>Update_MDM_Date1</fullName>
        <field>MDM_Latest_Submission_Date__c</field>
        <name>Update MDM Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MDM_Date2</fullName>
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
        <fullName>Update_MDM_Status3</fullName>
        <field>MDM_Validation_Status__c</field>
        <literalValue>Validated</literalValue>
        <name>Update MDM Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Remove Temp Address</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Address__c.Marked_For_Deletion__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Address__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>MDM Validated</value>
        </criteriaItems>
        <description>Remove Temp Address</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Desc</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Address__c.CreatedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
