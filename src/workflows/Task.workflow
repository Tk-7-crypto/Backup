<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CRM_MC_ESPSFDCQI_2064_Notify_task_creator</fullName>
        <description>CRM-MC-ESPSFDCQI-2064 Notify task creator</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/TSK_ET03_CRM_TASK_EMAIL</template>
    </alerts>
    <alerts>
        <fullName>TSK_EA01_MQL_task_reminder</fullName>
        <description>TSK_EA01_MQL task reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/TSK_ET01_MQL_task_reminder</template>
    </alerts>
    <alerts>
        <fullName>TSK_EA02_MQL_task_reminder_including_manager</fullName>
        <description>TSK_EA02_MQL task reminder including manager</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Of_Manager__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/TSK_ET02_MQL_task_reminder_including_manager</template>
    </alerts>
    <alerts>
        <fullName>TSK_EA03_MQL_Task_Creation_Alert</fullName>
        <description>TSK_EA03 MQL Task Creation Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/TSK_ET03_MQL_Task_Creation_Alert</template>
    </alerts>
    <alerts>
        <fullName>TSK_WEA01_CRM_MC_MQL_Task_Reminder</fullName>
        <description>TSK_WEA01_CRM_MC - MQL Task Reminder.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/TSK_ET01_CRM_MQL_Task_Reminder</template>
    </alerts>
    <rules>
        <fullName>TSK_WR01_CRM_MQL_Task_Reminder</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Not Started</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.isMQL__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>CRM-MC-ESPSFDCQI-397 - Email sent to assignee when 4 days past due date / ESPSFDCQI-16423</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>TSK_WEA01_CRM_MC_MQL_Task_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Task.ActivityDate</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TSK_WR02_CRM_Task_Email_Alert</fullName>
        <actions>
            <name>CRM_MC_ESPSFDCQI_2064_Notify_task_creator</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-2064 / PRM-347 / ESPSFDCQI-16423</description>
        <formula>$RecordType.DeveloperName != &apos;CPQ_Task&apos; &amp;&amp; (!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c ||  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c) &amp;&amp;  CreatedById != LastModifiedById &amp;&amp; ISPICKVAL(Status , &apos;Completed&apos;)&amp;&amp; CreatedBy.Profile.Name != &apos;PRM Community User&apos; &amp;&amp;  CreatedBy.Full_User_Name__c != &apos;Eloqua Integration User&apos; &amp;&amp;  CreatedBy.Full_User_Name__c  != &apos;Eloqua App User&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TSK_WR03_MQL task reminder</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Task.OwnerId</field>
            <operation>notEqual</operation>
            <value>Global Marketing,Inside Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Not Started</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>MQL Task</value>
        </criteriaItems>
        <description>ESPSFDCQI-3532, Email sent to assignee when 2 days have past and still in Not Started status/ ESPSFDCQI-16423</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>TSK_EA01_MQL_task_reminder</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TSK_WR04_MQL task reminder including manager</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Task.OwnerId</field>
            <operation>notEqual</operation>
            <value>Global Marketing,Inside Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Not Started</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>MQL Task</value>
        </criteriaItems>
        <description>ESPSFDCQI-3532, Email sent to assignee and assignee&apos;s manager when 4 days have past and still in Not Started status/ ESPSFDCQI-16423</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>TSK_EA02_MQL_task_reminder_including_manager</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TSK_WR05_MQL_TASK_Creation_Reminder</fullName>
        <actions>
            <name>TSK_EA03_MQL_Task_Creation_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>MQL Task</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Priority</field>
            <operation>equals</operation>
            <value>Urgent</value>
        </criteriaItems>
        <description>CRM-MC-ESPSFDCQI-8464 / ESPSFDCQI-16423</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
