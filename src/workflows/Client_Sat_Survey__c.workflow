<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CS_Creation_Notification</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS_Creation Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_EM_Email1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Survey_PIC_Email1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>CS_Creation_Notification_14_Days</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS_Creation Notification 14 Days</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_EM_Email1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Survey_PIC_Email1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Creation_Notification_14_Day</template>
    </alerts>
    <alerts>
        <fullName>CS_Creation_Notification_14_Days_Engagment</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS_Creation Notification 14 Days</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_EM_Email1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Survey_PIC_Email1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Creation_Notification_14_Day</template>
    </alerts>
    <alerts>
        <fullName>CS_Creation_Notification_21_Days</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS_Creation Notification 21 Days</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_EM_Email1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Survey_PIC_Email1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Creation_Notification_21_Day</template>
    </alerts>
    <alerts>
        <fullName>CS_Creation_Notification_21_Days_Engagment</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS_Creation Notification 21 Days</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_EM_Email1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Survey_PIC_Email1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Creation_Notification_21_Day</template>
    </alerts>
    <alerts>
        <fullName>CS_Creation_Notification_7_Days</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS_Creation Notification 7 Days</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_EM_Email1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Survey_PIC_Email1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Creation_Notification_7_Day</template>
    </alerts>
    <alerts>
        <fullName>CS_Creation_Notification_7_Days_Engagment</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS_Creation Notification 7 Days</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_EM_Email1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Survey_PIC_Email1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Creation_Notification_7_Day</template>
    </alerts>
    <alerts>
        <fullName>CS_Creation_Notification_Engagment</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS_Creation Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_EM_Email1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Survey_PIC_Email1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>CS_Decline_Rejection_Notification</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS_Decline Rejection</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_EM__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Survey_PIC_Email1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Process_Denial_Rejection_Notification_HTML</template>
    </alerts>
    <alerts>
        <fullName>CS_Declined_Survey_Approval_Alert</fullName>
        <description>CS Declined Survey Approval Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Declined_SurveyApprover_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Declined_SurveyApprover_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Declined_SurveyApprover_3__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Decline_Survey_Approver_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Process_Denial_Approval_Notification</template>
    </alerts>
    <alerts>
        <fullName>CS_Reassign_Decline_Survey_Approval_Request</fullName>
        <description>CS Reassign Decline Survey Approval Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>Decline_Survey_Reassign_Group</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>Decline_Survey_Approver_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Process_Denial_Approval_Notification</template>
    </alerts>
    <alerts>
        <fullName>CS_Reminder_Pending_Survey_Denial</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS Reminder Pending Survey Denial</description>
        <protected>false</protected>
        <recipients>
            <field>Declined_Survey_Approver_1__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Declined_Survey_Approver_2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Declined_Survey_Approver_3__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Process_Denial_Approval_Notification</template>
    </alerts>
    <alerts>
        <fullName>CS_Reminder_Pending_Survey_Denial_1</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS Reminder Pending Survey Denial</description>
        <protected>false</protected>
        <recipients>
            <field>Declined_Survey_Approver_1__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Declined_Survey_Approver_2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Declined_Survey_Approver_3__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Process_Denial_Approval_Notification</template>
    </alerts>
    <alerts>
        <fullName>CS_Reminder_Pending_Survey_Denial_2</fullName>
        <ccEmails>imsconsultingclientsatisfaction@us.imshealth.com</ccEmails>
        <description>CS Reminder Pending Survey Denial</description>
        <protected>false</protected>
        <recipients>
            <recipient>Decline_Survey_Reassign_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Process_Denial_Approval_Notification</template>
    </alerts>
    <alerts>
        <fullName>CS_Survey_Initiation_Decline_Or_Pending_Alert</fullName>
        <description>CS Survey Initiation Decline Or Pending Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Declined_SurveyApprover_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Declined_SurveyApprover_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Declined_SurveyApprover_3__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Decline_Survey_Approver_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Process_Denial_Approval_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>CS_Update_Send_Survey_After_21_Days</fullName>
        <field>Send_Survey__c</field>
        <literalValue>Yes</literalValue>
        <name>CS_Update Send Survey After 21 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CS_Update_Send_Survey_Date_After_21_Day</fullName>
        <description>Update Send Survey to today&apos;s data after 21 days</description>
        <field>Survey_Send_Date__c</field>
        <formula>TODAY()</formula>
        <name>CS_Update Send Survey Date After 21 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CS_Update_Send_Survey_Date_After_21_Days</fullName>
        <description>Update Send Survey to today&apos;s data after 21 days</description>
        <field>Survey_Send_Date__c</field>
        <formula>TODAY()</formula>
        <name>CS_Update Send Survey Date After 21 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CS_Update_Send_Survey_Field_After_21_Day</fullName>
        <description>Update Send Survey to Yes After 21 Days</description>
        <field>Send_Survey__c</field>
        <literalValue>Yes</literalValue>
        <name>CS_Update Send Survey After 21 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CS_Update_Send_Survey_Update_After_21_Da</fullName>
        <field>Send_Survey__c</field>
        <literalValue>Yes</literalValue>
        <name>CS_Update Send Survey After 21 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CS_Update_Status_After_21_Day</fullName>
        <description>Update Send Survey to today&apos;s data after 21 days</description>
        <field>Survey_Initiation_Status__c</field>
        <literalValue>Survey Approved</literalValue>
        <name>CS_Update Status After 21 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CS_Update_Status_After_21_Days</fullName>
        <description>Update Send Survey to today&apos;s data after 21 days</description>
        <field>Survey_Initiation_Status__c</field>
        <literalValue>Survey Approved</literalValue>
        <name>CS_Update Status After 21 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CS_Update_Status_When_Approved</fullName>
        <field>Survey_Initiation_Status__c</field>
        <literalValue>Survey Declined w/Mgr Approval</literalValue>
        <name>CS Update Status When Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Need_Escalation_After_14_Days</fullName>
        <description>ESPCRMINT-229,ESPSFDCQI-14335</description>
        <field>Need_Escalation__c</field>
        <literalValue>1</literalValue>
        <name>Update_Need_Escalation_After_14_Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Need_Escalation_After_21_Days</fullName>
        <description>ESPCRMINT-122</description>
        <field>Need_Escalation__c</field>
        <literalValue>1</literalValue>
        <name>Update Need Escalation After 21 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_for_Send_Survey_Yes</fullName>
        <field>Survey_Initiation_Status__c</field>
        <literalValue>Survey Approved</literalValue>
        <name>Update Status for Send Survey Yes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>gdfgdfg</fullName>
        <field>Survey_Send_Date__c</field>
        <formula>today()</formula>
        <name>gdfg</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CS Send Rejection Mail</fullName>
        <actions>
            <name>CS_Decline_Rejection_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>ESPCRMINT-226.Updated 503.</description>
        <formula>AND(  OR(ISPICKVAL(PRIORVALUE(Survey_Initiation_Status__c) , &apos;Survey Declined, Pending Mgr Approval&apos;), ISPICKVAL(PRIORVALUE(Survey_Initiation_Status__c) , &apos;Survey Delayed, Pending Approval&apos;)) ,  ISPICKVAL(Survey_Initiation_Status__c, &apos;Survey Approved&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CS Send Repeated Approval Notification</fullName>
        <active>false</active>
        <description>This workflow is used to send reminder to the approver every 7 days that survey denial is pending.</description>
        <formula>AND( ISPICKVAL(Send_Survey__c , &apos;No&apos;), NOT( ISPICKVAL(Survey_Initiation_Status__c, &apos;Survey Declined w/Mgr Approval&apos;)), NOT( ISPICKVAL(Survey_Initiation_Status__c, &apos;Survey Approved&apos;)), NOT( ISPICKVAL(Survey_Initiation_Status__c, &apos;New&apos;)), OR( ISPICKVAL(Opportunity__r.StageName, &apos;7a. Closed Won&apos;), ISPICKVAL(Opportunity__r.StageName, &apos;In-Hand&apos;) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Reminder_Pending_Survey_Denial</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Reminder_Pending_Survey_Denial_1</name>
                <type>Alert</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Reminder_Pending_Survey_Denial_2</name>
                <type>Alert</type>
            </actions>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CS Survey Initiation Decline Or Pending</fullName>
        <actions>
            <name>CS_Declined_Survey_Approval_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>ESPCRMINT-225, 228, 229</description>
        <formula>AND( ISPICKVAL(Send_Survey__c , &apos;No&apos;), NOT( ISPICKVAL(Survey_Initiation_Status__c, &apos;Survey Declined w/Mgr Approval&apos;)), NOT( ISPICKVAL(Survey_Initiation_Status__c, &apos;Survey Delayed w/Mgr Approval&apos;)), NOT( ISPICKVAL(Survey_Initiation_Status__c, &apos;Survey Approved&apos;)), NOT( ISPICKVAL(Survey_Initiation_Status__c, &apos;New&apos;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Reassign_Decline_Survey_Approval_Request</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Update_Need_Escalation_After_14_Days</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Survey_Initiation_Decline_Or_Pending_Alert</name>
                <type>Alert</type>
            </actions>
            <timeLength>12</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Survey_Initiation_Decline_Or_Pending_Alert</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CSAT_Survey_to_Qualtrics</fullName>
        <active>true</active>
        <description>ESPCRMINT-72, Send an Outbound Message to Qualtrics when a Survey record is created.Updated ESPCRMINT-289,ESPSFDCQI-13433.</description>
        <formula>OR( AND( ISCHANGED(Retrigger_Outbound__c), Retrigger_Outbound__c ), AND( NOT( ISBLANK(Survey_PIC_Email__c) ), OR( ISCHANGED(Survey_PIC_Email__c), ISBLANK(TEXT(Send_Survey__c)) ), Survey_Send_Date__c &gt;= TODAY(), AND( NOT(ISPICKVAL(Send_Survey__c, &apos;Yes&apos;)), NOT(ISPICKVAL(Survey_Initiation_Status__c,&apos;Approved&apos;))) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CS_Send Notification</fullName>
        <actions>
            <name>CS_Creation_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Send notification starting 10 days later in case of end of engagement, and alert for 21 days before survey is sent.</description>
        <formula>AND( NOT( ISPICKVAL(Send_Survey__c, &apos;Yes&apos;)), NOT(ISPICKVAL(Send_Survey__c, &apos;No&apos;)),NOT(ISPICKVAL( Survey_Type__c , &apos;End of Engagement&apos;)), OR( ISPICKVAL(Opportunity__r.StageName, &apos;7a. Closed Won&apos;), ISPICKVAL(Opportunity__r.StageName, &apos;In-Hand&apos;) ) )</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Creation_Notification_7_Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Client_Sat_Survey__c.CreatedDate</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Creation_Notification_14_Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Client_Sat_Survey__c.CreatedDate</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Creation_Notification_21_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>CS_Update_Send_Survey_Date_After_21_Days</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>CS_Update_Send_Survey_Field_After_21_Day</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>CS_Update_Status_After_21_Days</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Client_Sat_Survey__c.CreatedDate</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CS_Send Notification End of Engagement</fullName>
        <active>false</active>
        <description>5.Send notification starting 10 days later in case of end of engagement, and alert for 21 days before survey is sent.</description>
        <formula>AND( NOT( ISPICKVAL(Send_Survey__c, &apos;Yes&apos;)), NOT(ISPICKVAL(Send_Survey__c, &apos;No&apos;)), ISPICKVAL( Survey_Type__c , &apos;End of Engagement&apos;), OR( ISPICKVAL(Opportunity__r.StageName, &apos;7a. Closed Won&apos;), ISPICKVAL(Opportunity__r.StageName, &apos;In-Hand&apos;) ) )</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Creation_Notification_7_Days_Engagment</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Client_Sat_Survey__c.CreatedDate</offsetFromField>
            <timeLength>17</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Creation_Notification_14_Days_Engagment</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Client_Sat_Survey__c.CreatedDate</offsetFromField>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Creation_Notification_Engagment</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Client_Sat_Survey__c.CreatedDate</offsetFromField>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>CS_Creation_Notification_21_Days_Engagment</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>CS_Update_Send_Survey_Date_After_21_Day</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>CS_Update_Send_Survey_Update_After_21_Da</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>CS_Update_Status_After_21_Day</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Client_Sat_Survey__c.CreatedDate</offsetFromField>
            <timeLength>31</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
