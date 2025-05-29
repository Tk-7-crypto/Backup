<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AGR_EA01_CLM_Renewal_Notification</fullName>
        <description>AGR EA01 CLM Renewal Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET01_CLM_Renewal_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGR_EA02_CRM_Bid_Auto_Alert_DD</fullName>
        <ccEmails>Proposals@DrugDev.com</ccEmails>
        <description>CRM-MC-ESPSFDCQI-3284-Bid Auto Alert - DD</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>CRM_MC_Workflow_Templates/AGR_ET02_CRM_Auto_Alert_Information</template>
    </alerts>
    <alerts>
        <fullName>AGR_EA15_CRM_RFI_Request_Alert</fullName>
        <ccEmails>Request_for_information@quintiles.com</ccEmails>
        <description>CRM-MC-ESPSFDCQI-3284- RFI Request Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/AGR_ET16_CRM_RFI_Request_Bid_History</template>
    </alerts>
    <alerts>
        <fullName>AGR_EA16_CRM_RFI_Request_Completed</fullName>
        <description>CRM-MC-ESPSFDCQI-3284- RFI Request Completed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/AGR_ET17_CRM_RFI_Request_Completed_Bid_History</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA01_CLM_MC_ApttusContractActivationNotice</fullName>
        <description>AGR_WEA01_CLM_MC_ApttusContractActivationNotice</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Apttus__ApttusEmailTemplates/Apttus__ApttusContractActivationNotice</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA01_CLM_MC_Expiration_Notice</fullName>
        <description>AGR WEA01 CLM MC Expiration Notice</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET02_CLM_Expiration_Notice</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA01_CLM_MC_Fully_Signed_Notification</fullName>
        <description>AGR WEA01 CLM MC Fully Signed Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET11_CLM_AGR_Fully_Signed_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA01_CLM_MC_GSA_MSA_record_created</fullName>
        <description>AGR-WEA01-CLM-MC-PSA/MSA record created</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET01_CLM_Record_Creation</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA01_CLM_MC_MSA_Record_Activated</fullName>
        <description>AGR WEA01 CLM MC MSA Record Activated</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET12_CLM_MSA_Created_Activated_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA02_CLM_MC_GSA_Record_Created</fullName>
        <description>AGR-WEA02-CLM-MC-GSA Record Created</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET04_CLM_GSA_Created_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA02_CLM_MC_MSA_Record_Created</fullName>
        <description>AGR WEA02 CLM MC MSA Record Created</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET12_CLM_MSA_Created_Activated_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA02_CLM_MC_MSA_and_PSA_and_PA_Records_Rejected</fullName>
        <description>AGR WEA02 CLM MC MSA and PSA and PA Records Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET17_CLM_Agreement_Rejected_Mail</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA03_CLM_MC_CD_Contract_Agreement_Record_Created</fullName>
        <ccEmails>ConnectedDevicesContractRequest@iqvia.com</ccEmails>
        <description>AGR WEA03 CLM MC CD Contract Agreement Record Created</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET13_CLM_NOTIFICATION_TO_CSS_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA04_CLM_MC_CD_Contract_Agreement_Record_Activated</fullName>
        <ccEmails>ConnectedDevicesContractRequest@iqvia.com.invalid</ccEmails>
        <description>AGR WEA04 CLM MC CD Contract Agreement Record Activated</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET13_CLM_NOTIFICATION_TO_CSS_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA05_CLM_MC_Agreement_Owner_Updated</fullName>
        <description>AGR WEA05 CLM MC Agreement Owner Updated</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Business_Account_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_Supporting_Contract_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Line_Manager_1_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Apttus__Requestor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET03_CLM_Triage_Assignment_CA_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA06_CLM_MC_Is_Study_Awarded_Updated</fullName>
        <description>AGR WEA06 CLM MC Is Study Awarded Updated</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Business_Account_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_Supporting_Contract_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Line_Manager_1_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Apttus__Requestor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET10_CLM_Study_Awarded_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA07_CLM_MC_Third_Party_Vendor_As_Service</fullName>
        <description>AGR WEA07 CLM MC Third Party Vendor As Service</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Project_Manager_Con__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET07_CLM_Third_Party_Vendor_PM_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA10_CLM_MC_Agreement_Cancellation</fullName>
        <description>AGR WEA10 CLM MC Agreement Cancellation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET15_CLM_Cancellation_Notification_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA11_CLM_MC_Agreement_Expired</fullName>
        <description>AGR WEA11 CLM MC Agreement Expired</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET16_CLM_Agreement_Expired_Mail</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA12_CLM_Agreement_Is_Approved</fullName>
        <description>AGR WEA12 CLM Agreement Is Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/AGR_ET17_CLM_Agreement_Approved</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA13_CLM_MC_SendMailNotificationForAnticipatedDate45</fullName>
        <ccEmails>GBODeliveryExcellence@iqvia.com</ccEmails>
        <description>AGR WEA13 CLM MC SendMailNotificationForAnticipatedDate45</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Business_Account_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_Project_Manager_Con__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>clmintegration@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CLM_MC_Templates/AGR_ET05_CLM_D45_to_SIV_Alert</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA14_CLM_MC_SendMailNotificationForAnticipatedDate30</fullName>
        <ccEmails>GBODeliveryExcellence@iqvia.com</ccEmails>
        <description>AGR WEA14 CLM MC SendMailNotificationForAnticipatedDate30</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Business_Account_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_Project_Manager_Con__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>clmintegration@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CLM_MC_Templates/AGR_ET06_CLM_D30_to_SIV_Alert</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA15_CLM_MC_SendMailForGBOAssigned</fullName>
        <description>AGR WEA15 CLM MC SendMailForGBOAssigned</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>clmintegration@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CLM_MC_Templates/AGR_ET09_CLM_Triage_To_GBO_Assigned</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA16_CLM_MC_SendMailOnIQVIAManagerUpdate</fullName>
        <description>AGR WEA16 CLM MC SendMailOnIQVIAManagerUpdate</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Contract_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>clmintegration@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CLM_MC_Templates/AGR_ET11_CLM_Contract_Manager_Assignment_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA18_CLM_MC_SendMailNotificationForRescue</fullName>
        <ccEmails>GBODeliveryExcellence@iqvia.com</ccEmails>
        <description>AGR WEA18 CLM MC SendMailNotificationForRescue</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Business_Account_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_Project_Manager_Con__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>clmintegration@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CLM_MC_Templates/AGR_ET18_CLM_Rescue_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGR_WEA19_CLM_Agreement_Notification_NonGBO_TA</fullName>
        <ccEmails>RADDS_Contracts@iqvia.com</ccEmails>
        <description>AGR WEA19 CLM Agreement Notification to Non GBO Triage Analyst</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>clmintegration@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CLM_MC_Templates/AGR_ET23_CLM_Notification_of_Agreement_Creation_to_Non_GBO_Triage</template>
    </alerts>
    <alerts>
        <fullName>Apttus_Contract_Termination_Notice_Email_Alert</fullName>
        <description>Apttus Contract Termination Notice Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CLM_MC_Templates/Apttus_Contract_Termination_Notice</template>
    </alerts>
    <fieldUpdates>
        <fullName>Apttus__SearchFieldUpdate</fullName>
        <description>Update the account search field with Account Name</description>
        <field>Apttus__Account_Search_Field__c</field>
        <formula>Apttus__Account__r.Name  &amp;  Apttus__FF_Agreement_Number__c</formula>
        <name>Search Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Apttus__SetAgreementNumber</fullName>
        <description>Set agreement number from the auto generated contract number</description>
        <field>Apttus__Agreement_Number__c</field>
        <formula>Apttus__Contract_Number__c</formula>
        <name>Set Agreement Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Apttus__SetClonetriggertofalse</fullName>
        <description>Set Clone trigger to false</description>
        <field>Apttus__Workflow_Trigger_Created_From_Clone__c</field>
        <literalValue>0</literalValue>
        <name>Set Clone trigger to false</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AGR WR14 CLM SendMailForAnticipatedDate45</fullName>
        <actions>
            <name>AGR_WEA13_CLM_MC_SendMailNotificationForAnticipatedDate45</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-10546: Send email notification when the difference between Anticipated Date for 1st SIV and today`s date is 31 to 45 days.</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), OR(Record_Type_Developer_Name__c == &apos;PSA&apos;, Record_Type_Developer_Name__c == &apos;OSA&apos;), OR(ISPICKVAL( Apttus__Subtype__c, &apos;General Services Agreement&apos;), ISPICKVAL( Apttus__Subtype__c, &apos;Work Order&apos;)), OR(ISPICKVAL( Apttus__Status_Category__c, &apos;Request&apos;),  ISPICKVAL(Apttus__Status_Category__c, &apos;In Authoring&apos;)), NOT(OR(ISPICKVAL(Apttus__Status__c,&apos;On Hold&apos;),ISPICKVAL(Apttus__Status__c,&apos;Cancelled Request&apos;))), (Anticipated_Date_For_1st_SIV__c - TODAY()) &gt;= 31, (Anticipated_Date_For_1st_SIV__c - TODAY()) &lt;= 45)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR WR15 CLM SendMailForAnticipatedDate30</fullName>
        <actions>
            <name>AGR_WEA14_CLM_MC_SendMailNotificationForAnticipatedDate30</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-10546: Send email notification when the difference between  Anticipated Date for 1st SIV and Today`s date is 0 to 30.</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), OR(Record_Type_Developer_Name__c == &apos;PSA&apos;, Record_Type_Developer_Name__c == &apos;OSA&apos;), OR(ISPICKVAL( Apttus__Subtype__c, &apos;General Services Agreement&apos;), ISPICKVAL( Apttus__Subtype__c, &apos;Work Order&apos;)), OR(ISPICKVAL( Apttus__Status_Category__c, &apos;Request&apos;),  ISPICKVAL(Apttus__Status_Category__c, &apos;In Authoring&apos;)),NOT(OR(ISPICKVAL(Apttus__Status__c,&apos;On Hold&apos;),ISPICKVAL(Apttus__Status__c,&apos;Cancelled Request&apos;))),(Anticipated_Date_For_1st_SIV__c -  TODAY()) &gt;= 0, (Anticipated_Date_For_1st_SIV__c -  TODAY()) &lt;= 30)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR WR16 CLM SendMailForGBOAssigned</fullName>
        <actions>
            <name>AGR_WEA15_CLM_MC_SendMailForGBOAssigned</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-10813- Conversion of SendMailForGBOAssigned change to Workflow rule.</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), Record_Type_Developer_Name__c == &apos;GCE_SOW&apos;, ISCHANGED(OwnerId ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGR WR17 CLM MC SendMailOnIQVIAManagerUpdate</fullName>
        <actions>
            <name>AGR_WEA16_CLM_MC_SendMailOnIQVIAManagerUpdate</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-10813- Send mail to owner when Iqvia Contract Manager/Negotiator is updated</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), OR(Record_Type_Developer_Name__c == &apos;PSA&apos;, Record_Type_Developer_Name__c == &apos;OSA&apos;, Record_Type_Developer_Name__c == &apos;MSA&apos;, Record_Type_Developer_Name__c == &apos;Preliminary_Agreement&apos;), ISCHANGED(IQVIA_Contract_Manager__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGR WR18 CLM SendMailForRescue</fullName>
        <actions>
            <name>AGR_WEA18_CLM_MC_SendMailNotificationForRescue</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-10546: Send email notification “Site Activation Requested” = Yes on Prelim record type.</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), Record_Type_Developer_Name__c = &apos;Preliminary_Agreement&apos;,  ISPICKVAL(Site_Activation_Requested__c , &apos;Yes&apos;), OR(ISPICKVAL( Apttus__Status_Category__c, &apos;Request&apos;),  ISPICKVAL(Apttus__Status_Category__c, &apos;In Authoring&apos;)), NOT(OR(ISPICKVAL(Apttus__Status__c,&apos;On Hold&apos;),ISPICKVAL(Apttus__Status__c,&apos;Cancelled Request&apos;))))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR-WR01-CLM-GSA and MSA Creation Notification Mail</fullName>
        <actions>
            <name>AGR_WEA01_CLM_MC_GSA_MSA_record_created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-2026 - email sent to the record owner when record is created.</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), RecordType.DeveloperName == &apos;MSA&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AGR_WEA02_CLM_MC_MSA_Record_Created</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AGR-WR01-CLM-RenewalNotification</fullName>
        <active>false</active>
        <description>CLM-MC-CLMCMA-3086 Workflow Rule for Renewal notification of agreement.</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), NOT( ISNULL( Apttus__Contract_End_Date__c ) ),Apttus__Renewal_Notice_Days__c &gt; 0)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AGR_EA01_CLM_Renewal_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Apttus__APTS_Agreement__c.Apttus__Renewal_Notice_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AGR-WR02-CLM-GSA Record Creation Notification</fullName>
        <actions>
            <name>AGR_WEA02_CLM_MC_GSA_Record_Created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-4523 - Email sent to the record owner when PSA record is created.</description>
        <formula>AND(OR(CONTAINS($Setup.Organization_Default__c.UserID__c,$User.Id),NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c)), NOT(ISNULL(Apttus__Related_Opportunity__c)), OR(Record_Type_Developer_Name__c = &apos;PSA&apos;, Record_Type_Developer_Name__c = &apos;OSA&apos;,Record_Type_Developer_Name__c = &apos;Preliminary_Agreement&apos;,  Record_Type_Developer_Name__c = &apos;RWLP&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AGR-WR02-CRM-Bid Auto Alert</fullName>
        <actions>
            <name>AGR_EA02_CRM_Bid_Auto_Alert_DD</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-3284</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), AND( OR( ISPICKVAL(Apttus__Related_Opportunity__r.Line_of_Business__c, &apos;Novella&apos;), ISPICKVAL(Apttus__Related_Opportunity__r.Line_of_Business__c, &apos;Core Clinical&apos;), ISPICKVAL(Apttus__Related_Opportunity__r.Line_of_Business__c, &apos;Outcome&apos;)), OR(  ISPICKVAL(Bid_Type__c, &apos;Initial&apos;),  ISPICKVAL(Bid_Type__c, &apos;Re-bid&apos;))))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AGR-WR10-CLM- Fully Signed Notification Mail</fullName>
        <actions>
            <name>AGR_WEA01_CLM_MC_Fully_Signed_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Status__c</field>
            <operation>equals</operation>
            <value>Fully Signed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Status_Category__c</field>
            <operation>equals</operation>
            <value>In Signatures</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR-WR11-CLM-ApttusContractTerminationNotice</fullName>
        <actions>
            <name>Apttus_Contract_Termination_Notice_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-10389 Termination Notice Email to Owner for RDS users</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), OR(RecordType.DeveloperName == &apos;MSA&apos;, RecordType.DeveloperName == &apos;PSA&apos;,RecordType.DeveloperName == &apos;OSA&apos;, RecordType.DeveloperName == &apos;Preliminary_Agreement&apos;, RecordType.DeveloperName == &apos;AMESA&apos;, RecordType.DeveloperName == &apos;EMEA&apos;, RecordType.DeveloperName == &apos;Commercial&apos;, RecordType.DeveloperName == &apos;RWLP&apos;), ISPICKVAL(Apttus__Status_Category__c , &apos;Terminated&apos;), ISPICKVAL( Apttus__Status__c , &apos;Terminated&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR-WR13-CLM-AgreementRejectedRule</fullName>
        <actions>
            <name>AGR_WEA02_CLM_MC_MSA_and_PSA_and_PA_Records_Rejected</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-10483-Agreement Rejected Email to Owner for PSA and MSA and PA users</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), OR(RecordType.DeveloperName == &apos;MSA&apos;, RecordType.DeveloperName == &apos;PSA&apos;,RecordType.DeveloperName == &apos;OSA&apos;, RecordType.DeveloperName == &apos;Preliminary_Agreement&apos;), ISPICKVAL(Apttus__Status_Category__c, &quot;In Approval&quot;), ISPICKVAL(Apttus__Status__c, &quot;Rejected&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR-WR15-CRM-RFI Bid Owner assigned</fullName>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-3284 - sends email when RFI assigned</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), RecordType.Name == &apos;RFI Request&apos;,  Owner:User.Username != null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR-WR16-CRM-RFI Request Alert</fullName>
        <actions>
            <name>AGR_EA15_CRM_RFI_Request_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-3284 - email sent to RFI group</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), OR(RecordType.Name == &apos;RFI Request&apos;, RecordType.Name == &apos;RFI&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AGR-WR17-CRM-RFI Request Completed</fullName>
        <actions>
            <name>AGR_EA16_CRM_RFI_Request_Completed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-3284 - email sent to requester and creator when status is moved to sent</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), RecordType.Name == &apos;RFI Request&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR_WR01_CLM_ApttusContractActivationNotice</fullName>
        <actions>
            <name>AGR_WEA01_CLM_MC_ApttusContractActivationNotice</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM_MC_CLMCMA-3089 - When status category is in effect and status is activation for RDS</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), OR(RecordType.DeveloperName == &apos;MSA&apos;, RecordType.DeveloperName == &apos;PSA&apos;,RecordType.DeveloperName == &apos;OSA&apos;, RecordType.DeveloperName == &apos;Preliminary_Agreement&apos;, RecordType.DeveloperName == &apos;AMESA&apos;, RecordType.DeveloperName == &apos;EMEA&apos;, RecordType.DeveloperName == &apos;RWLP&apos;), ISPICKVAL(Apttus__Status_Category__c , &quot;In Effect&quot;), ISPICKVAL( Apttus__Status__c , &quot;Activated&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR_WR03_CLM_ExpirationNotification_Mail</fullName>
        <active>false</active>
        <description>CLM-MC-CLMCMA-3087- Workflow Rule for Expiration notification of Agreement</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), OR(RecordType.DeveloperName == &apos;AMESA&apos;,RecordType.DeveloperName == &apos;RWSSOW&apos;), NOT(ISNULL(Apttus__Contract_End_Date__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AGR_WEA01_CLM_MC_Expiration_Notice</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Apttus__APTS_Agreement__c.Expiration_Notice_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AGR_WR04_CLM_MSA_Activation_Notification_Mail</fullName>
        <actions>
            <name>AGR_WEA01_CLM_MC_MSA_Record_Activated</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-7812 - Workflow Rule for sending email on the activation of the MSA Agreement.</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), RecordType.DeveloperName == &apos;MSA&apos;, ISPICKVAL(Apttus__Status_Category__c , &quot;In Effect&quot;), ISPICKVAL(Apttus__Status__c , &quot;Activated&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR_WR05_CLM_CD_Contract_Agreement_Creation_Notification_Mail</fullName>
        <active>false</active>
        <description>CLM-MC-CLMCMA-7813 - Workflow Rule for sending email on the creation of the PSA, PA or MSA Agreement having CD Contract as the service.</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), OR(RecordType.DeveloperName == &apos;MSA&apos;, RecordType.DeveloperName == &apos;PSA&apos;,RecordType.DeveloperName == &apos;OSA&apos;, RecordType.DeveloperName == &apos;Preliminary_Agreement&apos;), INCLUDES(Services__c, &apos;CSS-CD Contract&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AGR_WEA03_CLM_MC_CD_Contract_Agreement_Record_Created</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AGR_WR06_CLM_CD_Contract_Agreement_Activation_Notification_Mail</fullName>
        <actions>
            <name>AGR_WEA04_CLM_MC_CD_Contract_Agreement_Record_Activated</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-7813 - Workflow Rule for sending email on the activation of the PSA, PA or MSA Agreement having CD Contract as the service.</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), OR(RecordType.DeveloperName == &apos;MSA&apos;, RecordType.DeveloperName == &apos;PSA&apos;,RecordType.DeveloperName == &apos;OSA&apos;, RecordType.DeveloperName == &apos;Preliminary_Agreement&apos;), ISPICKVAL(Apttus__Status_Category__c , &quot;In Effect&quot;), ISPICKVAL(Apttus__Status__c , &quot;Activated&quot;), INCLUDES(Services__c, &apos;CSS-CD Contract&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR_WR07_CLM_PA _PSA_Agreement_Owner_Update_Email_Alert</fullName>
        <actions>
            <name>AGR_WEA05_CLM_MC_Agreement_Owner_Updated</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-9898 - Workflow Rule for Sending an email when Agreement Owner gets updated</description>
        <formula>AND(             NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c),              NOT(ISNULL(PRIORVALUE(Id))),              NOT(ISNEW()),              ISCHANGED(OwnerId),             NOT(ISBLANK(OwnerId)),             OR(Record_Type_Developer_Name__c = &apos;PSA&apos;, Record_Type_Developer_Name__c = &apos;OSA&apos;,Record_Type_Developer_Name__c = &apos;Preliminary_Agreement&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGR_WR08_CLM_PA_Is_Study_Awared_From_No_To_Yes</fullName>
        <actions>
            <name>AGR_WEA06_CLM_MC_Is_Study_Awarded_Updated</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-9898 - Workflow Rule for Sending an email when the Is Study Awarded? Field is changed from No to Yes</description>
        <formula>AND(             NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c),             NOT(ISNULL(PRIORVALUE(Id))),             NOT(ISNEW()),             ISCHANGED(Is_Study_Awarded__c),             ISPICKVAL(PRIORVALUE(Is_Study_Awarded__c),&quot;No&quot;),             ISPICKVAL(Is_Study_Awarded__c, &quot;Yes&quot;), Record_Type_Developer_Name__c = &apos;Preliminary_Agreement&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGR_WR09_CLM_PSA_Third_Party_Vendor_Email_Alert</fullName>
        <actions>
            <name>AGR_WEA07_CLM_MC_Third_Party_Vendor_As_Service</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-9898 - Workflow Rule for Sending an email to Project Manager when Third party vendor added as a service</description>
        <formula>AND(             NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c),             NOT(ISNULL(PRIORVALUE(Id))),             NOT(ISNEW()),             NOT(ISNULL(Services__c)),             ISCHANGED(Services__c),             OR(             INCLUDES(PRIORVALUE(Services__c), &quot;&quot;),             NOT(INCLUDES(PRIORVALUE(Services__c),&quot;Third Party Vendors&quot;))),             INCLUDES(Services__c, &quot;Third Party Vendors&quot;),             OR(Record_Type_Developer_Name__c = &apos;PSA&apos;,Record_Type_Developer_Name__c = &apos;OSA&apos;, Record_Type_Developer_Name__c = &apos;Preliminary_Agreement&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGR_WR10_CLM_Agreement_Cancellation_Notification_Mail</fullName>
        <actions>
            <name>AGR_WEA10_CLM_MC_Agreement_Cancellation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-10384 - Workflow Rule for sending email on the cancellation of the PSA, PA, MSA and AMESA Agreement.</description>
        <formula>AND(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), OR(RecordType.DeveloperName == &apos;MSA&apos;, RecordType.DeveloperName == &apos;PSA&apos;,RecordType.DeveloperName == &apos;OSA&apos;, RecordType.DeveloperName == &apos;Preliminary_Agreement&apos;, RecordType.DeveloperName == &apos;AMESA&apos;, RecordType.DeveloperName == &apos;EMEA&apos;, RecordType.DeveloperName == &apos;Commercial&apos;, RecordType.DeveloperName == &apos;RWLP&apos;), ISPICKVAL(Apttus__Status_Category__c, &quot;Cancelled&quot;), ISPICKVAL(Apttus__Status__c, &quot;Cancelled Request&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGR_WR11_CLM_Agreement_Approved_Notification</fullName>
        <actions>
            <name>AGR_WEA12_CLM_Agreement_Is_Approved</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CLM-MC-CLMCMA-10482 - email sent to the agreement owner when agreement is approved.</description>
        <formula>And(NOT($Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c),OR(RecordType.DeveloperName = &apos;PSA&apos;,RecordType.DeveloperName = &apos;OSA&apos;, RecordType.DeveloperName = &apos;MSA&apos;,RecordType.DeveloperName = &apos;Preliminary_Agreement&apos;,RecordType.DeveloperName = &apos;AMESA&apos;),ISPICKVAL(Apttus__Status_Category__c, &apos;In Approval&apos;), ISPICKVAL(Apttus__Status__c, &apos;Approved&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Apttus__Reset Clone Trigger</fullName>
        <actions>
            <name>Apttus__SetClonetriggertofalse</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Workflow_Trigger_Created_From_Clone__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Reset Clone Trigger</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Apttus__Search Field Update</fullName>
        <actions>
            <name>Apttus__SearchFieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate an external Id search field with account name, so that side bar support can work with Account name search</description>
        <formula>or(not (isnull(Apttus__Account__r.Name)) ,not (isnull(Apttus__FF_Agreement_Number__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Apttus__Set Agreement Number</fullName>
        <actions>
            <name>Apttus__SetAgreementNumber</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Agreement_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set agreement number for new agreements. The agreement number is auto generated.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
