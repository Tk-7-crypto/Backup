<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASN_EA01_OWF_MC_Pending_Assignment_Notification</fullName>
        <description>ASN_EA01_OWF_MC_Pending_Assignment_Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>OWF/ASN_ET02_OWF_NEW_Assign_Pending_Review</template>
    </alerts>
    <alerts>
        <fullName>ASN_EA02_OWF_PendingAssignmentNotificationForContractPostAward</fullName>
        <description>ASN_EA02_OWF_PendingAssignmentNotificationForContractPostAward</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>gbocontractstriage@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OWF/ASN_ET03_OWF_Pending_Asn_ReviewPostAward</template>
    </alerts>
    <alerts>
        <fullName>ASN_WEA01_PSA_CLD_Creation_Email_Alert</fullName>
        <description>ASN_WEA01_PSA_CLD-PSA Assignment Creation Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>pse__Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Assignment_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>ASN_WEA02_PSA_CLD_Scheduled_and_Activated_Email_Alert</fullName>
        <description>ASN_WEA02_PSA_CLD - PSA Assignment Scheduled and Activated Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>pse__Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/PSA_Assignment_Scheduled_and_Active</template>
    </alerts>
    <rules>
        <fullName>ASN_WR01_PSA_CLD_AssnCreationNotification_Mail</fullName>
        <actions>
            <name>ASN_WEA01_PSA_CLD_Creation_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-USNONE-Sends a notification email to the assigned resource when criteria is met.</description>
        <formula>And(!$Setup.PSA_RDS_Settings__c.Disable_Assignment_Notification__c, pse__Resource__r.pse__Salesforce_User__c &lt;&gt; CreatedById,  Action_Notify_Assignee__c = True)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASN_WR02_PSA_CLD_AssnScheduledActivated</fullName>
        <actions>
            <name>ASN_WEA02_PSA_CLD_Scheduled_and_Activated_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-USNONE-Fires when an assignment has a status of scheduled and is active</description>
        <formula>AND(!$Setup.PSA_RDS_Settings__c.Disable_Assignment_Notification__c,  RecordType.DeveloperName = &apos;RDS_Assignment&apos;,   Active__c = TRUE,   TEXT(pse__Status__c) = &apos;Scheduled&apos;,   NOT(ISPICKVAL(pse__Role__c, &apos;External&apos;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
