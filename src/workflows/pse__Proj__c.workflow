<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PRJ_WEA01_PSA_CLD_ProjectCreationEmailAlertOpptyOwner</fullName>
        <description>PRJ_WEA01_PSA_CLD-PSA Project Creation Email Alert Oppty Owner</description>
        <protected>false</protected>
        <recipients>
            <field>pse__Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Project_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>PRJ_WEA02_PSA_CLD_ProjectCreationEmailAlertPM</fullName>
        <description>PRJ_WEA02_PSA_CLD-PSA Project Creation Email Alert PM</description>
        <protected>false</protected>
        <recipients>
            <field>pse__Project_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Project_Creation_Notification</template>
    </alerts>
    <rules>
        <fullName>PRJ_WR01_PSA_CLD_CreationWorkflowOpptyOwner_Mail</fullName>
        <actions>
            <name>PRJ_WEA01_PSA_CLD_ProjectCreationEmailAlertOpptyOwner</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>pse__Proj__c.pse__Stage__c</field>
            <operation>equals</operation>
            <value>Start-up</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Proj__c.PM_Oppty_Owner__c</field>
            <operation>equals</operation>
            <value>false</value>
        </criteriaItems>
        <description>PSA-CLD-USNONE - Workflow will send email alerts to notify of new project creation to Opportunity Owner assuming the opportunity owner does not equal the project manager.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PRJ_WR02_PSA_CLD_ProjectCreationWorkflowPM_Mail</fullName>
        <actions>
            <name>PRJ_WEA02_PSA_CLD_ProjectCreationEmailAlertPM</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>pse__Proj__c.pse__Stage__c</field>
            <operation>equals</operation>
            <value>Start-up</value>
        </criteriaItems>
        <description>PSA-CLD-USNONE-PSA - Workflow will send email alerts to notify of new project creation to PM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
