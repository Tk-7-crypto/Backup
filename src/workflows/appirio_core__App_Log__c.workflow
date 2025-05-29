<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PSA_Audit_Log_Alert</fullName>
        <description>PSA Audit Log Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Audit_Log_Error</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/PSA_AuditLogAlert</template>
    </alerts>
    <rules>
        <fullName>PSA Audit Log Alert</fullName>
        <actions>
            <name>PSA_Audit_Log_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>appirio_core__App_Log__c.appirio_core__Origin__c</field>
            <operation>equals</operation>
            <value>PSA_AuditLog</value>
        </criteriaItems>
        <description>Notification of PSA Audit Log app log entry</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
