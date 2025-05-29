<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CSM_TECH_EN_Case_Status_Change_CSH_Follower</fullName>
        <description>CSM TECH EN Case Status Change CSH Follower</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>English_Templates/ET_TECH_EN_Case_Status_Change_CSH_Follower</template>
    </alerts>
    <alerts>
        <fullName>CSM_TECH_FI_Case_Status_Change_CSH_Case_Follower</fullName>
        <description>CSM_TECH_FI_Case_Status_Change_CSH_Case_Follower</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Finnish_Templates/ET_TECH_FI_Case_Status_Change_CSH_Case_Follower</template>
    </alerts>
    <alerts>
        <fullName>CSM_TECH_JP_Case_Status_Change_CSH_Case_Follower</fullName>
        <description>CSM TECH JP Case Status Change CSH Case Follower</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tech_Japan_Templates/ET_TECH_JP_Case_Status_Change_CSH_Case_Follower</template>
    </alerts>
</Workflow>
