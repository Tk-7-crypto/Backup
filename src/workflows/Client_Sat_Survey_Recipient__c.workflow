<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CS_Notify_Reciepent_Customer_Reponse</fullName>
        <description>ESPCRMINT-68 - CS Notify Reciepent Customer Reponse</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_EM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Survey_PIC_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Sat_Survey_Folder/CS_Notify_Reciepent_Custom_Response</template>
    </alerts>
    <rules>
        <fullName>CS Notice Response  Customer Satisfaction Survey Received</fullName>
        <actions>
            <name>CS_Notify_Reciepent_Customer_Reponse</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>ESPCRMINT-68</description>
        <formula>AND(ISCHANGED(Survey_Results__c),OR(ISNULL(PRIORVALUE(Survey_Results__c)),ISBLANK(PRIORVALUE(Survey_Results__c))),NOT(ISNULL(Survey_Results__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
