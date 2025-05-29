<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Internal_notification_to_Revenue_Analyst_to_begin_MIBNF_Approval_process</fullName>
        <description>Internal notification to Revenue Analyst to begin MIBNF Approval process</description>
        <protected>false</protected>
        <recipients>
            <field>Current_RA_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BNF_Templates/MI_BNF_Approvals_submitted_notification</template>
    </alerts>
    <alerts>
        <fullName>MIBNF_Approval_Notification</fullName>
        <description>MIBNF Approval  Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Current_RA_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>First_RA_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Submitter_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BNFs/MIBNFApprovedBNFrecordrejected</template>
    </alerts>
    <alerts>
        <fullName>Send_notification_of_MIBNF_SAP_rejection</fullName>
        <description>Send_notification_of_MIBNF_SAP_rejection</description>
        <protected>false</protected>
        <recipients>
            <field>First_RA_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Last_RA_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BNFs/MIBNF_Rejected_VF_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_notification_of_MIBNF_rejection</fullName>
        <description>Send notification of MIBNF rejection</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>First_RA_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Last_RA_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Submitter_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BNFs/MIBNF_Rejected_VF_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Rejection_Reason</fullName>
        <field>Rejection_Reasons__c</field>
        <name>Clear Rejection Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LO_Accepted</fullName>
        <field>BNF_Status__c</field>
        <literalValue>LO Accepted</literalValue>
        <name>LO Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LO_Rejected</fullName>
        <field>BNF_Status__c</field>
        <literalValue>LO Rejected</literalValue>
        <name>LO Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RA_Accepted</fullName>
        <field>BNF_Status__c</field>
        <literalValue>RA Accepted</literalValue>
        <name>RA Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RA_Rejected</fullName>
        <field>BNF_Status__c</field>
        <literalValue>RA Rejected</literalValue>
        <name>RA Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Submitter_Email</fullName>
        <field>Last_Submitter_Email__c</field>
        <formula>$User.Email</formula>
        <name>Update Last Submitter Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Accepted</fullName>
        <field>BNF_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>Update Status : Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_New</fullName>
        <field>BNF_Status__c</field>
        <literalValue>New</literalValue>
        <name>Update Status : New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Rejected</fullName>
        <field>BNF_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status : Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_SAP_Contract_Confirmed</fullName>
        <field>BNF_Status__c</field>
        <literalValue>SAP Contract Confirmed</literalValue>
        <name>Update Status : SAP Contract Confirmed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_SAP_Contract_Confirmedv1</fullName>
        <field>BNF_Status__c</field>
        <literalValue>SAP Contract Confirmed</literalValue>
        <name>Update Status : SAP Contract Confirmed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Submitted</fullName>
        <field>BNF_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Update Status : Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Submitter_Email</fullName>
        <description>Store email address of user who submitted the BNF</description>
        <field>Submitter_Email__c</field>
        <formula>$User.Email</formula>
        <name>Update Submitter Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IBNF is stuck in SAP PENDING Status</fullName>
        <active>false</active>
		<description>ESPSFDCQI-16145</description>
        <criteriaItems>
            <field>MIBNF_Component__c.BNF_Status__c</field>
            <operation>equals</operation>
            <value>SAP Pending</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>BNF_stuck_in_SAP_PENDING_status_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>MIBNF_Component__c.LastModifiedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MIBNF_WR01_Send_Mail_To_RA</fullName>
        <actions>
            <name>Internal_notification_to_Revenue_Analyst_to_begin_MIBNF_Approval_process</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-6100,ESPSFDCQI-16145</description>
        <formula>AND( OR( ISPICKVAL( BNF_Status__c , &apos;Submitted&apos;), ISPICKVAL(BNF_Status__c, &apos;LO Accepted&apos;), ISPICKVAL(BNF_Status__c, &apos;SAP Rejected&apos;), ISPICKVAL(BNF_Status__c, &apos;SAP Contract Rejected&apos;)), NOT(ISBLANK( Comp_Revenue_Analyst__r.Owner:Queue.Id )), ISCHANGED(BNF_Status__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
