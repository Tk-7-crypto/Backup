<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>COM_WEA01_Competitive_Intelligence_Request_is_Create</fullName>
        <ccEmails>RDSCompetitiveIntelligence@iqvia.com</ccEmails>
        <description>COM_WEA01_Competitive Intelligence Request is Create</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/COM_ET01_NewCompetitiveIntelligenceRep</template>
    </alerts>
    <alerts>
        <fullName>COM_WEA02_Estimated_Completion_Date_is_populated</fullName>
        <description>COM_WEA02_Estimated Completion Date is populated</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/COM_ET02_For_Estimated_completion_Date</template>
    </alerts>
    <rules>
        <fullName>COM_WR01_CRM-Email Alert %3A Competitive Request is Created</fullName>
        <actions>
            <name>COM_WEA01_Competitive_Intelligence_Request_is_Create</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-MC-ESPSFDCQI-5125</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>COM_WR02_CRM-Email Alert %3A Estimated Completion Date is populated</fullName>
        <actions>
            <name>COM_WEA02_Estimated_Completion_Date_is_populated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-MC-ESPSFDCQI-5125</description>
        <formula>Not(ISBLANK( Estimated_Completion_Date__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
