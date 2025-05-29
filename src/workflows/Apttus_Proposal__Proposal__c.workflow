<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CPQ_Send_Email_On_CO_Quote_Acceptance</fullName>
        <description>CPQ-Send Email On CO Quote Acceptance</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CPQ/CPQ_Send_Email_On_CO_Quote_Acceptance</template>
    </alerts>
    <alerts>
        <fullName>Final_Approval_Email</fullName>
        <description>Final Approval Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_Dynamic_Approval_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Final_Rejection_Email</fullName>
        <description>Final Rejection Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_Dynamic_Approval_Reject_Notification</template>
    </alerts>
    <alerts>
        <fullName>CPQ_Send_Email_for_sync_fail_to_Opportunity_Owner</fullName>
        <ccEmails>QIP.Submission@Quintiles.com</ccEmails>
        <description>CPQ Send Email for sync fail to Opportunity Owner</description>
        <protected>false</protected>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CPQ/CPQ_Send_Email_for_Sync_Fail</template>
    </alerts>
    <alerts>
        <fullName>CPQ_Send_Email_to_Budget_Owner_for_Review_Approval</fullName>
        <description>CPQ Send Email to Budget Owner for Review Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_Send_Review_Approval_Notification_Email_to_Budget_Owner</template>
    </alerts>
    <alerts>
        <fullName>CPQ_Send_Email_to_Budget_Owner_for_Review_Rejection</fullName>
        <description>CPQ Send Email to Budget Owner for Review Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_Send_Review_Rejection_Email_notification_to_Budget_Owner</template>
    </alerts>
    <alerts>
        <fullName>CPQ_TSL_Review_Quote_Rejection_Email</fullName>
        <description>CPQ TSL Review Quote Rejection Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_TSL_Review_Quote_Reject_Budget</template>
    </alerts>
    <alerts>
        <fullName>CPQ_TSL_Review_Quote_approval_Email</fullName>
        <description>CPQ TSL Review Quote approval Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_TSL_Review_Quote_Approve_Budget</template>
    </alerts>
    <alerts>
        <fullName>JapanTS_CSS_Approved_Notification_New</fullName>
        <description>JapanTS CSS Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/Japan_TS_CSS_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Japan_TS_CSS_Approval_Request_To_Notifiers</fullName>
        <description>Japan TS CSS Approval Request To Notifiers</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/Japan_TS_CSS_Approval_Request_Notification</template>
    </alerts>
    <alerts>
        <fullName>Japan_TS_CSS_CFO_Rejected_Notification_Alert</fullName>
        <description>Japan TS CSS - CFO Rejected Notification Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/Japan_TS_CSS_Rejected_Notification</template>
    </alerts>
    <alerts>
        <fullName>Japan_TS_CSS_Head_CFO_Approval_Notification</fullName>
        <description>Japan TS CSS - Head CFO Approval Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/Japan_TS_CSS_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Japan_TS_CSS_Head_TSJP_Approved_Notification</fullName>
        <description>Japan TS CSS - Head TSJP Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/Japan_TS_CSS_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Japan_TS_CSS_Rejected_Notification_New</fullName>
        <description>Japan TS CSS Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/Japan_TS_CSS_Rejected_Notification</template>
    </alerts>
    <alerts>
        <fullName>Japan_TS_CSS_Service_line_lead_Approved_Notification_Alert</fullName>
        <description>Japan TS CSS - Service line lead Approved Notification Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/Japan_TS_CSS_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Japan_TS_CSS_Service_line_lead_Rejected_Notification_Alert</fullName>
        <description>Japan TS CSS - Service line lead Rejected Notification Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/Japan_TS_CSS_Rejected_Notification</template>
    </alerts>
	<alerts>
        <fullName>Japan_TS_CSS_TSJP_Rejected_Notification_Alert</fullName>
        <description>Japan TS CSS - TSJP Rejected Notification Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/Japan_TS_CSS_Rejected_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Budget_Owner_to_Unlock_Budget_First_Second</fullName>
        <description>Notify Budget Owner to Unlock Budget First Second</description>
        <protected>false</protected>
        <recipients>
            <field>Budget_Checked_Out_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_Notification_To_Budget_Owner_About_Budget_Locing</template>
    </alerts>
    <alerts>
        <fullName>Notify_Budget_Owner_to_Unlock_Budget_Last</fullName>
        <description>Notify Budget Owner to Unlock Budget Last</description>
        <protected>false</protected>
        <recipients>
            <field>Budget_Checked_Out_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_Last_Notification_To_Budget_Owner_For_Unlocking</template>
    </alerts>
    <alerts>
        <fullName>RDS_Budget_Quote_Creation_Alert</fullName>
        <description>RDS Budget Quote Creation Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/RDS_Budget_Creation_From_Clinical</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Pending</fullName>
        <field>Apttus_Proposal__Approval_Stage__c</field>
        <literalValue>Approved</literalValue>
        <name>Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Stage_Update_TSL_Approval</fullName>
        <field>Apttus_Proposal__Approval_Stage__c</field>
        <literalValue>Sign Off</literalValue>
        <name>Approval Stage Update TSL Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Stage_Update_TSL_Rejection</fullName>
        <field>Apttus_Proposal__Approval_Stage__c</field>
        <literalValue>Draft</literalValue>
        <name>Approval Stage Update TSL Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval Status- Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Approval Status- Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Update_TSL_Approval</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Review Approved and Submitted for Final SignOff</literalValue>
        <name>Approval Status Update TSL Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Update_TSL_Rejection</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Ready for Functional Review</literalValue>
        <name>Approval Status Update TSL Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approve_and_Submit_again_if_required</fullName>
        <field>Apttus_QPConfig__IsAutoAccepted__c</field>
        <literalValue>1</literalValue>
        <name>Approve and Submit again if required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Budget_Checked_Out_By</fullName>
        <field>Budget_Checked_Out_By__c</field>
        <name>Clear Budget Checked Out By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_XAE_Lock_Timestamp</fullName>
        <field>XAE_Lock_Timestamp__c</field>
        <name>Clear XAE Lock Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_Approval_Pending</fullName>
        <field>Apttus_Proposal__Approval_Stage__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Field Update -Approval Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
	<fieldUpdates>
        <fullName>Rejected</fullName>
        <field>Apttus_Proposal__Approval_Stage__c</field>
        <literalValue>Rejected</literalValue>
        <name>Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_CFO_Approver_Name</fullName>
        <field>MedDRA_Classification__c</field>
        <formula>&apos;Kazunobu Takeuchi&apos;</formula>
        <name>Set CFO Approver Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_GM_Approver_Name</fullName>
        <field>MedDRA_Classification__c</field>
        <formula>&apos;Fumihiko Ugajin&apos;</formula>
        <name>Set GM Approver Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_TSJP_Head_Approver_Name</fullName>
        <field>MedDRA_Classification__c</field>
        <formula>&apos;Hiroshi Nishi&apos;</formula>
        <name>Set TSJP Head Approver Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unlock_the_Pricing_Tool</fullName>
        <field>Pricing_Tool_Locked__c</field>
        <literalValue>0</literalValue>
        <name>Unlock the Pricing Tool</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver1</fullName>
        <field>Approver_1__c</field>
        <name>Update Approver1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver2</fullName>
        <field>Approver_2__c</field>
        <name>Update Approver2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver3</fullName>
        <field>Approver_3__c</field>
        <name>Update Approver3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver4</fullName>
        <field>Approver_4__c</field>
        <name>Update Approver4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver5</fullName>
        <field>Approver_5__c</field>
        <name>Update Approver5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver_Level</fullName>
        <field>Approver_Level__c</field>
        <formula>0</formula>
        <name>Update Approver Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CPQ Notify Budget Owner for Approval</fullName>
        <actions>
            <name>CPQ_TSL_Review_Quote_approval_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>The owner of the Budget record will receive an email notification for Review Approval.</description>
        <formula>AND( OR( AND(ISPICKVAL(PRIORVALUE(Approval_Status__c),&quot;PS Approval Pending&quot;), OR(ISPICKVAL(Approval_Status__c,&apos;SP Approval Pending&apos;), ISPICKVAL(Approval_Status__c,&apos;Review Approved and Submitted for Final SignOff&apos;))), AND(ISPICKVAL(PRIORVALUE(Approval_Status__c),&quot;SP Approval Pending&quot;), ISPICKVAL(Approval_Status__c,&apos;Review Approved and Submitted for Final SignOff&apos;)) ), RecordType.Name == &apos;RDS Budget&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CPQ Notify Budget Owner for Review Approval</fullName>
        <actions>
            <name>CPQ_Send_Email_to_Budget_Owner_for_Review_Approval</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>The owner of the Budget record will receive an email notification for Review Approval.</description>
        <formula>AND(OR(AND(ISPICKVAL(PRIORVALUE(Approval_Status__c),&quot;Draft Review&quot;), ISPICKVAL(Approval_Status__c,&apos;Ready for Functional Review&apos;)),             AND(ISPICKVAL(PRIORVALUE(Approval_Status__c),&quot;Final Review&quot;), ISPICKVAL(Approval_Status__c,&apos;Final Review Approved&apos;)))             , RecordType.Name == &apos;RDS Budget&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CPQ Notify Budget Owner for Rejection</fullName>
        <actions>
            <name>CPQ_TSL_Review_Quote_Rejection_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>The owner of the Budget record will receive an email notification for Approval Rejection.</description>
        <formula>AND( OR( AND(OR(ISPICKVAL(PRIORVALUE(Approval_Status__c),&quot;PS Approval Pending&quot;), ISPICKVAL(PRIORVALUE(Approval_Status__c),&quot;SP Approval Pending&quot;)), ISPICKVAL(Approval_Status__c,&apos;None&apos;)) ), RecordType.Name == &apos;RDS Budget&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CPQ Notify Budget Owner for Review Rejection</fullName>
        <actions>
            <name>CPQ_Send_Email_to_Budget_Owner_for_Review_Rejection</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>The owner of the Budget record will receive an email notification for Review Rejection.</description>
        <formula>AND(OR(AND(ISPICKVAL(PRIORVALUE(Approval_Status__c),&quot;Draft Review&quot;), ISPICKVAL(Approval_Status__c,&apos;Self Check Draft&apos;)),             AND(ISPICKVAL(PRIORVALUE(Approval_Status__c),&quot;Final Review&quot;), ISPICKVAL(Approval_Status__c,&apos;Self Check Final&apos;)))             , RecordType.Name == &apos;RDS Budget&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CPQ Notify Opportunity Owner for Sync fail</fullName>
        <actions>
            <name>CPQ_Send_Email_for_sync_fail_to_Opportunity_Owner</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>The owner of the Budget record and the Opportunity owner will receive an email notification for Sync failure with error message.</description>
        <formula>Record_Type_Name__c = &apos;RDS Budget&apos; &amp;&amp; (TEXT(Apttus_Proposal__Approval_Stage__c) = &apos;Generated&apos;  ||  TEXT(Apttus_Proposal__Approval_Stage__c) = &apos;Presented&apos;) &amp;&amp; TEXT(Execution_Status__c) = &apos;Failed&apos; &amp;&amp;  PRIORVALUE(Execution_Status__c)  &lt;&gt; &apos;Failed&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CPQ- Send Email On CO Quote Acceptance</fullName>
        <actions>
            <name>CPQ_Send_Email_On_CO_Quote_Acceptance</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c</field>
            <operation>equals</operation>
            <value>Accepted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Apttus_Proposal__Proposal__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RDS Non-SF,RDS Budget</value>
        </criteriaItems>
        <criteriaItems>
            <field>Apttus_Proposal__Proposal__c.Apttus_Proposal__Proposal_Category__c</field>
            <operation>equals</operation>
            <value>Change Order</value>
        </criteriaItems>
        <description>Send email to Quote Owner when a Change Order quote is accepted.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Budget Owner to Unlock Budget</fullName>
        <active>false</active>
        <formula>AND(RecordType.Name == &apos;RDS Budget&apos;,   Budget_Checked_Out_By__c &lt;&gt; NULL,  Pricing_Tool_Locked__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Budget_Owner_to_Unlock_Budget_First_Second</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Apttus_Proposal__Proposal__c.XAE_Lock_Timestamp__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Budget_Owner_to_Unlock_Budget_First_Second</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Apttus_Proposal__Proposal__c.XAE_Lock_Timestamp__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Budget_Owner_to_Unlock_Budget_Last</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Apttus_Proposal__Proposal__c.XAE_Lock_Timestamp__c</offsetFromField>
            <timeLength>6</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Clear_Budget_Checked_Out_By</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Clear_XAE_Lock_Timestamp</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Unlock_the_Pricing_Tool</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Apttus_Proposal__Proposal__c.XAE_Unlock_Timestamp__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send Email on RDS Budget Quote Creation</fullName>
        <actions>
            <name>RDS_Budget_Quote_Creation_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(ISPICKVAL(Clinical_Bid__r.Is_there_a_Client_Bid_Grid__c,&apos;Yes&apos;) , RecordType.Name == &apos;RDS Budget&apos;, 
            NOT(ISBLANK(TEXT(Apttus_Proposal__Proposal_Category__c))), OR (ISNEW(), ISBLANK(TEXT(PRIORVALUE(Apttus_Proposal__Proposal_Category__c)))) , OR(ISPICKVAL(Apttus_Proposal__Proposal_Category__c, &apos;Initial&apos;) , ISPICKVAL(Apttus_Proposal__Proposal_Category__c, &apos;Rebid&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
