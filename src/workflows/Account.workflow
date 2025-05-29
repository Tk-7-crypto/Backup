<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ACC_WEA01_CRM_MC_UpdateRiskRatingNotification</fullName>
        <description>ACC_WEA01_CRM_MC_UpdateRiskRatingNotification</description>
        <protected>false</protected>
        <recipients>
            <recipient>credit.assessments-na@iqvia.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ACC_ET03_CRM_Descartes_RiskRating_Notification</template>
    </alerts>
    <alerts>
        <fullName>Approval_Notification</fullName>
        <description>Approval Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Approval_Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDM_Email_Templates/MDM_Validation_Confirmed_for_SFDC_Account</template>
    </alerts>
    <alerts>
        <fullName>MDM_Approval_Notification</fullName>
        <description>MDM Approval Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Approval_Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDM_Email_Templates/MDM_Validation_Confirmed_for_SFDC_Account</template>
    </alerts>
    <alerts>
        <fullName>MDM_Approved_Notification</fullName>
        <description>MDM Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Approval_Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Address_Sap_Contact/ACC_ET02_CRM_MDM_APPROVED</template>
    </alerts>
    <alerts>
        <fullName>MDM_Rejected_Notification</fullName>
        <description>MDM Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Approval_Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Address_Sap_Contact/ACC_ET02_CRM_MDM_REJECTED</template>
    </alerts>
    <alerts>
        <fullName>MDM_Rejection_Notification</fullName>
        <description>MDM Rejection Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Approval_Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDM_Email_Templates/MDM_Validation_Rejected_for_SFDC_Account</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Notification</fullName>
        <description>Rejection Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Approval_Requester_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDM_Email_Templates/MDM_Validation_Rejected_for_SFDC_Account</template>
    </alerts>
    <fieldUpdates>
        <fullName>MDM_Unvalidated</fullName>
        <field>MDM_Validation_Status__c</field>
        <literalValue>Unvalidated</literalValue>
        <name>MDM Unvalidated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pending_for_Descartes</fullName>
        <description>ESPSFDCQI-12068</description>
        <field>MDM_Validation_Status__c</field>
        <literalValue>Pending for Descartes</literalValue>
        <name>Pending for Descartes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MDM_Status</fullName>
        <field>MDM_Validation_Status__c</field>
        <literalValue>Pending Validation</literalValue>
        <name>Update MDM Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Requested_By_Email_Address</fullName>
        <field>Approval_Requester_Email__c</field>
        <formula>$User.Email</formula>
        <name>Update Requested By Email Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ACC_WR01_CRM_InsertUpdate_Outbound</fullName>
        <actions>
            <name>ACC_OB01_CRM_InsertUpdate</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>CRM-QI-ESPSFDCQI-501 - Workflow to send outbound message when Account record is inserted or updated.</description>
        <formula>$Setup.Mulesoft_Integration_Control__c.Suppress_Outbound_Messages__c == false &amp;&amp; Exclude_from_Mulesoft_Sync__c == FALSE &amp;&amp; Send_Mulesoft_Outbound_Msg__c == true &amp;&amp; (RecordType.DeveloperName == &quot;MDM_Validated_Account&quot; || RecordType.DeveloperName == &quot;Unvalidated_Account&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACC_WR02_CRM_Descartes_RiskRating</fullName>
        <actions>
            <name>ACC_WEA01_CRM_MC_UpdateRiskRatingNotification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.DPS_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>ESPSFDCQI-12068</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
