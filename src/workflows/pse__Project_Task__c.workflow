<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PTS_WEA01_PSA_CLD_UpcomingTaskAlert</fullName>
        <description>PTS_WEA01_PSA_CLD - PSA Project Task Upcoming Task Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Project_Task_Upcoming_Task_Email</template>
    </alerts>
    <alerts>
        <fullName>PTS_WEA02_PSA_CLD_PastDueAlert</fullName>
        <description>PTS_WEA02_PSA_CLD- PSA Project Task Past Due Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Project_Task_Past_Due_Email</template>
    </alerts>
    <alerts>
        <fullName>PTS_WEA03_PSA_CLD_NewTaskAssignmentAlert</fullName>
        <description>PTS_WEA03_PSA_CLD - PSA Project New Task Assignment Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Project_Task_Assigned_Task_Email</template>
    </alerts>
    <alerts>
        <fullName>PTS_WEA04_PSA_CLD_PSA_ProjectTaskUpcomingAlert</fullName>
        <description>PTS_WEA04_PSA_CLD - PSA Project Task Upcoming Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/PSA_PVA_Project_Task_Upcoming_Task_Email</template>
    </alerts>
    <alerts>
        <fullName>PTS_WEA05_PSA_MC_PSA_Proj_Task_Due_Dt_Alert</fullName>
        <description>PTS-WEA05-PSA-MC-PSA_Proj_Task_Due_Dt_Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Service_Line_Lead__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/PSA_Srvc_Line_Mgr_Notification</template>
    </alerts>
    <alerts>
        <fullName>PTS_WEA06_PSA_StatusReminderToResource</fullName>
        <description>PTS_WEA06_PSA_StatusReminderToResource</description>
        <protected>false</protected>
        <recipients>
            <field>Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/PTS_ET06_PSA_Status_Reminder_To_Resource</template>
    </alerts>
    <fieldUpdates>
        <fullName>PTS_WFU01_SetTriggerPastDue</fullName>
        <description>PSA-CLD-USNONE- Set Trigger Past Due</description>
        <field>Trigger_Past_Due_Workflow__c</field>
        <literalValue>1</literalValue>
        <name>PTS_WFU01_SetTriggerPastDue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PTS_WFU02_PSA_UnsetTriggerPastDue</fullName>
        <description>PSA-CLD-USNONE- Unset Trigger Past Due</description>
        <field>Trigger_Past_Due_Workflow__c</field>
        <literalValue>0</literalValue>
        <name>PTS_WFU02_PSA_UnsetTriggerPastDue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PTS_WR01_PSA_DateUpcomingNotification_Mail</fullName>
        <active>false</active>
        <description>PSA-CLD-USNONE - This rule will send an email notification seven days prior to the task end date.</description>
        <formula>AND ( OR(RecordType.DeveloperName = &apos;RDS_Deliverable&apos;, RecordType.DeveloperName =&apos;RDS_Deliverable_Task&apos;), Service_Line_Code__c != &apos;PVA&apos;, OR(TEXT(pse__Status__c) == &apos;In Progress&apos;, TEXT(pse__Status__c) == &apos;Planned&apos;) , ISBLANK( pse__Actual_End_Date_Time__c ), NOT(ISBLANK(Resource__c)), VALUE(TEXT(pse__End_Date__c - DATEVALUE(CreatedDate))) &gt; 7 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PTS_WEA01_PSA_CLD_UpcomingTaskAlert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>pse__Project_Task__c.pse__End_Date__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PTS_WR02_PSA_NewTaskNotification_Mail</fullName>
        <actions>
            <name>PTS_WEA03_PSA_CLD_NewTaskAssignmentAlert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-USNONE - This rule will send an email notification to the resource when they are assigned to a Deliverable or related Task</description>
        <formula>AND (   OR   (     RecordType.DeveloperName = &apos;RDS_Deliverable&apos;,     RecordType.DeveloperName = &apos;RDS_Deliverable_Task&apos;   ),   TEXT(pse__Status__c) != &apos;Complete&apos;,   OR   (     (ISNEW() &amp;&amp; !ISBLANK(Resource__c)),     (ISCHANGED(Resource__c) &amp;&amp; !ISBLANK(Resource__c))   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PTS_WR03_PSA_RecurringPastDueNotification_Mail</fullName>
        <actions>
            <name>PTS_WFU02_PSA_UnsetTriggerPastDue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-USNONE - Sends daily reminder email that task is past due</description>
        <formula>OR(Trigger_Past_Due_Workflow__c &amp;&amp; TEXT(pse__Status__c) != &apos;Complete&apos; &amp;&amp; pse__End_Date__c &lt;= Today() &amp;&amp; !ISBLANK(Resource__c) &amp;&amp; OR(RecordType.DeveloperName = &apos;RDS_Deliverable_Task&apos;,RecordType.DeveloperName = &apos;RDS_Project_Task&apos;), Trigger_Past_Due_Workflow__c &amp;&amp; TEXT(pse__Status__c) != &apos;Complete&apos; &amp;&amp; End_Date_Planned__c &lt;= Today() &amp;&amp; !ISBLANK(Resource__c) &amp;&amp; RecordType.DeveloperName = &apos;RDS_Deliverable&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PTS_WEA02_PSA_CLD_PastDueAlert</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>PTS_WFU01_SetTriggerPastDue</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PTS_WR04_PSA_TriggerRecurringPastDue</fullName>
        <actions>
            <name>PTS_WFU01_SetTriggerPastDue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>pse__Project_Task__c.pse__Status__c</field>
            <operation>notEqual</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Project_Task__c.End_Date_Planned__c</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Project_Task__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RDS Deliverable</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Project_Task__c.Trigger_Past_Due_Workflow__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>PSA-CLD-USNONE - Workflow to set trigger field to trigger recurring time-based workflow</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PTS_WR05_PSA_PVA_DateUpcomingNotification_Mail</fullName>
        <active>false</active>
        <description>PSA-CLD-USNONE - This rule will send an email notification two days prior to the task end date.</description>
        <formula>AND(RecordType.DeveloperName = &apos;RDS_Deliverable&apos;, Service_Line__r.Name = &quot;PVA&quot;, NOT(OR(ISPICKVAL(pse__Status__c,&quot;Complete&quot;),ISPICKVAL(pse__Status__c,&quot;Cancelled&quot;))),  End_Date_Planned__c  &gt;= TODAY() )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PTS_WEA04_PSA_CLD_PSA_ProjectTaskUpcomingAlert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>pse__Project_Task__c.pse__End_Date__c</offsetFromField>
            <timeLength>-2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PTS_WR06_PSA_MC_PSA Project Task Upcoming Task Alert 3 Day</fullName>
        <active>false</active>
        <description>IQVIAPSA-MC- 610 - This rule will send an email notification three days prior to the task end date.</description>
        <formula>AND ( OR(RecordType.DeveloperName = &apos;RDS_Deliverable&apos;, RecordType.DeveloperName =&apos;RDS_Deliverable_Task&apos;), Service_Line_Code__c != &apos;PVA&apos;, OR(TEXT(pse__Status__c) == &apos;In Progress&apos;, TEXT(pse__Status__c) == &apos;Planned&apos;) , ISBLANK( pse__Actual_End_Date_Time__c ), NOT(ISBLANK(Resource__c)), VALUE(TEXT(pse__End_Date__c - DATEVALUE(CreatedDate))) &gt; 3 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PTS_WEA01_PSA_CLD_UpcomingTaskAlert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>pse__Project_Task__c.pse__End_Date__c</offsetFromField>
            <timeLength>-3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PTS_WR07_PSA_Date_SrvcLineLead_UpcomingNotification_Mail</fullName>
        <active>false</active>
        <description>IQVIAPSA-3865, IQVIAPSA-4697, IQVIAPSA-5640</description>
        <formula>AND( AND(RecordType.DeveloperName = &apos;RDS_Project_Task&apos;,  Trigger_Email_Notification__c = True), Service_Line_Lead__c != null, IF( ISBLANK(pse__Actual_End_Date__c), TRUE, FALSE), IF(pse__End_Date__c  &gt;  TODAY(), TRUE, FALSE),  NOT( AND(Service_Line__r.Name = &apos;PV Solutions&apos;, CONTAINS(Name, &apos;Complete Project Files Review&apos;))), Activate_Workflow_Rule_Conditionally__c = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PTS_WEA05_PSA_MC_PSA_Proj_Task_Due_Dt_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>pse__Project_Task__c.pse__End_Date_Time__c</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>PTS_WEA05_PSA_MC_PSA_Proj_Task_Due_Dt_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>pse__Project_Task__c.pse__End_Date_Time__c</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
