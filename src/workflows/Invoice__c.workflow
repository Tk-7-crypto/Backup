<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>INV_CRM_WEA01_Send_email_notification_to_opp_owner_and_PIC_when_initial_invoice</fullName>
        <description>INV_CRM_WEA01_Send email notification to opp owner and PIC when initial invoice is sent to customer</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>PIC__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/INV_CRM_ET01_IMS_Support_CRM_First_Invoice_Sent</template>
    </alerts>
    <rules>
        <fullName>INV_CRM_WR01_Send initial invoice notification</fullName>
        <actions>
            <name>INV_CRM_WEA01_Send_email_notification_to_opp_owner_and_PIC_when_initial_invoice</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Initial_Invoice__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Invoice__c.Billing_Date__c</field>
            <operation>greaterOrEqual</operation>
            <value>YESTERDAY</value>
        </criteriaItems>
        <description>ESPSFDCQI-5680</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
