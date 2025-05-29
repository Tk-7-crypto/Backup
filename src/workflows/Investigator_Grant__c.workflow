<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ING_WEA01_CRM_Investigator_Grants_past_due_date_email</fullName>
        <description>ING_WEA01_CRM_Investigator Grants past due date email</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_Investigator_Grants_Developer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/ING_ET01_CRM_Investigator_Grants_past_due_date_email</template>
    </alerts>
    <alerts>
        <fullName>ING_WEA01_OWF_Investigator_IGDeveloper_Assigned</fullName>
        <description>ING_WEA01_OWF_Investigator_IGDeveloper_Assigned</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_Investigator_Grants_Developer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/ING_ET01_OWF_IGDeveloper_Assigned</template>
    </alerts>
    <alerts>
        <fullName>ING_WEA02_CRM_Investigator_Grant_uploaded_alert_email</fullName>
        <ccEmails>Request_Grant_estimates@quintiles.com.invalid</ccEmails>
        <description>ING_WEA02_CRM_Investigator Grant uploaded alert email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Final_Deliverable_Email_Recipient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/ING_ET02_CRM_Investigator_Grant_uploaded_alert_email</template>
    </alerts>
    <alerts>
        <fullName>ING_WEA02_OWF_Investigator_IGDeveloper_Modified</fullName>
        <description>ING_WEA02_OWF_Investigator_IGDeveloper_Modified</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/ING_ET02_OWF_IGDeveloper_Modified</template>
    </alerts>
    <alerts>
        <fullName>ING_WEA03_CRM_Investigator_grant_assigned_alert_email</fullName>
        <description>ING_WEA03_CRM_Investigator grant assigned alert email</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_Investigator_Grants_Developer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/ING_ET03_CRM_Investigator_grant_assigned_alert_email</template>
    </alerts>
    <alerts>
        <fullName>ING_WEA04_CRM_Investigator_grant_assigned_PD_alert_email</fullName>
        <description>ING_WEA04_CRM_Investigator grant assigned PD alert email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/ING_ET04_CRM_Investigator_grant_assigned_PD_alert_email</template>
    </alerts>
    <alerts>
        <fullName>ING_WEA05_CRM_New_investigator_Grants_request</fullName>
        <ccEmails>request_grant_estimates@quintiles.com.invalid</ccEmails>
        <description>ING_WEA05_CRM_New investigator Grants request</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/ING_ET05_CRM_Investigator_initial_request_alert_email</template>
    </alerts>
    <fieldUpdates>
        <fullName>CTR_WFU1_CRM_IG_Close_date</fullName>
        <description>Populates with todays date when status is closed</description>
        <field>Closed_Date__c</field>
        <formula>today()</formula>
        <name>CTR_WFU1_CRM_IG Close date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ING_WR01_CRM_Investigator Grants past due date email</fullName>
        <active>false</active>
        <description>ESPSFDCQI-3919, Sends email to grants developer if due date past</description>
        <formula>ISPICKVAL(Request_Status__c , &apos;OPEN&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ING_WEA01_CRM_Investigator_Grants_past_due_date_email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Investigator_Grant__c.Investigator_Grants_Due_Date_to_PD__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ING_WR01_OWF_Investigator_IGDeveloper_Assigned</fullName>
        <actions>
            <name>ING_WEA01_OWF_Investigator_IGDeveloper_Assigned</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IQVIAPSA-2714 - Investigator Grants Changes - Email Templates</description>
        <formula>AND( (!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), IF( ISNEW(), False, IF( ISBLANK( Assigned_Investigator_Grants_Developer__c ), False, IF( ISBLANK(PRIORVALUE(Assigned_Investigator_Grants_Developer__c)), False, IF( ISCHANGED( Assigned_Investigator_Grants_Developer__c ), True, False)))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ING_WR02_CRM_Investigator Grant uploaded alert email</fullName>
        <actions>
            <name>ING_WEA02_CRM_Investigator_Grant_uploaded_alert_email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CTR_WFU1_CRM_IG_Close_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>ESPSFDCQI-3919, Email sent when grant has been loaded to box</description>
        <formula>!ISBLANK(Box_Link_to_Quotes_Folder__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ING_WR02_OWF_Investigator_IGDeveloper_Modified</fullName>
        <actions>
            <name>ING_WEA02_OWF_Investigator_IGDeveloper_Modified</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IQVIAPSA-2714-Investigator Grants Changes - Email Templates</description>
        <formula>AND( (!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), IF( ISNEW(), False, IF( ISBLANK( Assigned_Investigator_Grants_Developer__c ), False, IF( ISBLANK(PRIORVALUE(Assigned_Investigator_Grants_Developer__c)), False, IF( ISCHANGED( Assigned_Investigator_Grants_Developer__c ), True, False)))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ING_WR03_CRM_Investigator grant assigned alert email</fullName>
        <actions>
            <name>ING_WEA03_CRM_Investigator_grant_assigned_alert_email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>ESPSFDCQI-3919, Email to Developer</description>
        <formula>!ISBLANK(Assigned_Investigator_Grants_Developer__c  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ING_WR04_CRM_Investigator grant assigned PD alert email</fullName>
        <actions>
            <name>ING_WEA04_CRM_Investigator_grant_assigned_PD_alert_email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>ESPSFDCQI-3919, Email to PD when developer Assigned</description>
        <formula>!ISBLANK(Assigned_Investigator_Grants_Developer__c  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ING_WR05_CRM_Investigator initial request alert email</fullName>
        <actions>
            <name>ING_WEA05_CRM_New_investigator_Grants_request</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>ESPSFDCQI-3919, Alert sent when request created</description>
        <formula>ISBLANK(Assigned_Investigator_Grants_Developer__c  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
