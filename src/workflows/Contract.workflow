<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CTR_WEA01_CRM_Contract_Bid_Grid_QC_budget_analyst_alert</fullName>
        <description>CTR_WEA01_CRM_Contract Bid Grid - QC budget analyst alert</description>
        <protected>false</protected>
        <recipients>
            <field>Grid_QC_Assigned_to__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET03_CRM_Contract_Bid_Grid_QC_assigned_alert</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA02_CRM_Cardiac_Safety_contract_status_change</fullName>
        <description>CTR_WEA02_CRM_Cardiac Safety contract status change</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>CSS_CD_Contract_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>csscontractrequest@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET24_CRM_Cardiac_Safety_contract_stage_change</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA03_CRM_Cardiac_Safety_Contract_Involvement</fullName>
        <description>CTR_WEA03_CRM_Cardiac Safety Contract Involvement</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>csscontractrequest@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET25_CRM_Cardiac_Safety_contract_involvement</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA06_CRM_alerts_PFM_and_PM_when_Global_P_U_field_is_populated_on_a_contra</fullName>
        <description>CTR_WEA06_CRM_alerts Contract Owner when Global P/U field is populated on a contract</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET04_CRM_Contracts_PFM_and_PM_alert_for_Global_P_U_field</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA07_CRM_Contract_signed_alert</fullName>
        <description>CTR_WEA07_CRM_Contract signed alert</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Project_Manager_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>IQVIA_Project_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET05_CRM_Contract_signed_alert</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA08_CRM_CRO_LOI_SUWO_expiration_alerts_30_day_prior</fullName>
        <description>CTR_WEA08_CRM_CRO LOI/SUWO expiration alerts 30 day prior</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET06_CRM_CRO_Preliminary_LOI_SUWO_expiration_alerts_30_days</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA09_CRM_CRO_LOI_SUWO_expiration_alerts_15_day_prior</fullName>
        <description>CTR_WEA09_CRM_CRO LOI/SUWO expiration alerts 15 day prior</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET07_CRM_CRO_Preliminary_LOI_SUWO_expiration_alerts_15_days</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA10_CRM_CRO_LOI_SUWO_expiration_alerts_5_day_prior</fullName>
        <description>CTR_WEA10_CRM_CRO LOI/SUWO expiration alerts 5 day prior</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET08_CRM_CRO_Preliminary_LOI_SUWO_expiration_alerts_5_days</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA11_CRM_CRO_ATP_Expiry_Date</fullName>
        <description>CTR_WEA11_CRM_CRO: ATP Expiry Date</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Project_Manager_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET09_CRM_CRO_ATP_expiry_alert</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA12_CRM_ECD_contract_status_change</fullName>
        <ccEmails>sandi.befort-coffelt@IQVIA.com</ccEmails>
        <description>CTR_WEA12_CRM_ECD contract status change</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET27_CRM_ECD_contract_stage_change</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA13_CRM_Email_Alert_to_BD_on_Auto_Contract_Creation</fullName>
        <description>CTR_WEA13_CRM_Email Alert to BD on Auto Contract Creation</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Requestor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gbocontractstriage@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET10_CRM_Auto_Contract_Creation_Alert_to_BD</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA14_CRM_PFM_and_PM_alert_when_unsigned_status_populated</fullName>
        <description>CTR_WEA14_CRM_PFM and PM alert when unsigned status populated</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Project_Manager_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_Project_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET13_CRM_Contracts_PFM_and_PM_alert</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA15_CRM_PFM_and_PM_alert_when_contract_status_is_changed</fullName>
        <description>CTR_WEA15_CRM_PFM and PM alert when contract status is changed</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Project_Manager_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_Project_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET13_CRM_Contracts_PFM_and_PM_alert</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA16_CRM_PFM_and_PM_alert_when_contract_status_is_moved_to_Contract_Execute</fullName>
        <description>CTR_WEA16_CRM_PFM and PM alert when contract status is moved to Contract Executed</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Project_Manager_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_Project_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET14_CRM_Contracts_PFM_and_PM_alert_for_contract_executed</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA19_CRM_Reminder_to_Upload_QIP_24_Hours</fullName>
        <description>CTR_WEA19_CRM_Reminder to Upload QIP - 24 Hours</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET20_CRM_QIP_Not_Loaded_Contract_at_Budget_for_Customer_Review_24_Hours</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA20_CRM_Triage_Assignment_BD_Email_Alert</fullName>
        <description>CTR_WEA20_CRM_Triage Assignment BD Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Requestor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gbocontractstriage@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET22_CRM_Triage_Assignment_BD_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA21_CRM_Contract_Bid_Grid_assigned_budget_analyst_alert</fullName>
        <description>CTR_WEA21_CRM_Contract Bid Grid - assigned budget analyst alert</description>
        <protected>false</protected>
        <recipients>
            <field>Budget_Analyst_Assigned__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET01_CRM_Contract_Bid_Grid_Assigned_Budget_Analyst_Alert</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA22_CRM_Contract_Bid_Grid_budget_analyst_assigned</fullName>
        <description>CTR_WEA22_CRM_Contract Bid Grid - budget analyst assigned</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Contract_Manager_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET02_CRM_Contract_Bid_Grid_Budget_Analyst_Assigned</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA22_CRM_PFM_and_PM_alert_when_contract_status_is_moved_to_Contract_Execute</fullName>
        <description>CTR_WEA22_CRM_PFM and PM alert when contract status is moved to Contract Executed</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Project_Manager_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_Project_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET15_CRM_Contracts_PFM_and_PM_alert_for_contract_executed</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA23_CRM_Reminder_to_Upload_QIP_48_Hours</fullName>
        <description>CTR_WEA23_CRM_Reminder to Upload QIP - 48 Hours</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET21_CRM_QIP_Not_Loaded_Contract_at_Budget_for_Customer_Review_48_Hours</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA24_CRM_Triage_Assignment_CA_Email_Alert</fullName>
        <description>CTR_WEA24_CRM_Triage Assignment CA Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Supporting_Contract_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>IQVIA_Business_Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Line_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>gbocontractstriage@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET33_CRM_Triage_Assignment_CA_Alert</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA25_CRM_Triage_Assignment_CA_Email_Alert</fullName>
        <description>CTR_WEA25_CRM_Triage Assignment CA Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Supporting_Contract_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Project_Leader_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Requestor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>IQVIA_Business_Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Line_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>gbocontractstriage@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET33_CRM_Triage_Assignment_CA_Alert</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA27_CRM_Contract_renewal_expiry_1_month_out</fullName>
        <description>CTR_WEA27_CRM_Contract renewal expiry 1 month out</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Supporting_Contract_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>IQVIA_Contract_Manager_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Line_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET17_CRM_Contract_Renewal_expiry_date_1_month</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA28_CRM_Contract_renewal_expiry_14_days_out</fullName>
        <description>CTR_WEA28_CRM_Contract renewal expiry 14 days out</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Supporting_Contract_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>IQVIA_Contract_Manager_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Line_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET18_CRM_Contract_Renewal_expiry_date_14_days</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA29_CRM_Contract_renewal_expiry_14_days_past</fullName>
        <description>CTR_WEA29_CRM_Contract renewal expiry 14 days past</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Supporting_Contract_Manager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>IQVIA_Contract_Manager_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Line_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET19_CRM_Contract_Renewal_expiry_date_14_days_past</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA30_CRM_MSA_Consolidation_new_MSA</fullName>
        <ccEmails>sfdc_automation@imshealth.com</ccEmails>
        <description>CTR_WEA30_CRM_MSA Consolidation - new MSA</description>
        <protected>false</protected>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET11_CRM_New_MSA_Created</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA30_CRM_Third_Party_Vendor_Contract_Requests</fullName>
        <description>CTR_WEA30_CRM_Third_Party_Vendor_Contract_Requests</description>
        <protected>false</protected>
        <recipients>
            <field>Requestor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>vendoragreementsupportlcn@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET34_CRM_Third_Party_Vendor_Contract_Requests</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA31_CRM_MSA_Moved_to_Executed</fullName>
        <ccEmails>sfdc_automation@imshealth.com</ccEmails>
        <description>CTR_WEA31_CRM_MSA Moved to Executed</description>
        <protected>false</protected>
        <senderAddress>request.proposal.global@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET12_CRM_MSA_moved_to_Executed</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA32_CRM_QIP_is_now_SMART_Ready</fullName>
        <description>CTR_WEA32_CRM_QIP is now SMART Ready</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>IQVIA_Project_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET29_CRM_QIP_is_now_SMART_Ready</template>
    </alerts>
    <alerts>
        <fullName>CTR_WEA34_CRM_Notification_to_contract_owner_and_PFM_when_contract_QIP_has_been</fullName>
        <description>CTR_WEA34_CRM_Notification to contract owner and PFM when contract QIP has been loaded</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>qip.submission@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET28_CRM_QIP_Loaded_Contract</template>
    </alerts>
    <alerts>
        <fullName>If_Planned_Execution_Date_is_between_0_to_30_days_earlier_than_1st_SIV_date</fullName>
        <ccEmails>GBODeliveryExcellence@iqvia.com</ccEmails>
        <description>If Planned Execution Date is between 0 to 30 days earlier than 1st SIV date</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Project_Manager_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>IQVIA_Business_Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Line_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET31_CRM_D30_to_SIV_Alert</template>
    </alerts>
    <alerts>
        <fullName>If_Planned_Execution_Date_is_between_31_to_45_days_earlier_than_1st_SIV_date</fullName>
        <ccEmails>GBODeliveryExcellence@iqvia.com</ccEmails>
        <description>If Planned Execution Date is between 31 to 45 days earlier than 1st SIV date</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Project_Manager_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>IQVIA_Business_Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Line_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET30_CRM_D45_to_SIV_Alert</template>
    </alerts>
    <alerts>
        <fullName>If_Site_Activation_requested_is_Yes</fullName>
        <ccEmails>GBODeliveryExcellence@iqvia.com</ccEmails>
        <description>If Site Activation requested is Yes</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Project_Manager_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>IQVIA_Business_Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Line_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/CTR_ET32_CRM_Site_Activation_requested_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>CTR_WFU01_CRM_Triage_Assignment_BD_Statu</fullName>
        <field>Status</field>
        <literalValue>Assigned - Not Started</literalValue>
        <name>CTR_WFU01_CRM_Triage Assignment BD Statu</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CTR_WFU01_PRM_RenewalDate</fullName>
        <description>PRM - ACN - Update renewal date on contract</description>
        <field>Renewal_date__c</field>
        <formula>IF(CONTAINS(Product__r.Name, &quot;OCE Sales&quot;), EndDate - 60 , EndDate - 30)</formula>
        <name>CTR_WFU01_PRM_RenewalDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CTR_WFU2_CRM_Field_Update_Global_PU</fullName>
        <description>3233</description>
        <field>Date_Global_P_U_entered__c</field>
        <formula>TODAY()</formula>
        <name>CTR_WFU2_CRM_Field Update Global PU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRM_Update_EndDate</fullName>
        <field>EndDate</field>
        <formula>ADDMONTHS(StartDate,Agency_Program__r.Duration_in_month__c)-1</formula>
        <name>PRM Update EndDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRM_Update_First_Notification_Date</fullName>
        <field>First_Notification_Date__c</field>
        <formula>ADDMONTHS(StartDate,Agency_Program__r.Duration_in_month__c)-Agency_Program__r.First_Notification__c -1</formula>
        <name>PRM Update First Notification Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRM_Update_Renewal_Date</fullName>
        <field>Renewal_date__c</field>
        <formula>ADDMONTHS(StartDate,Agency_Program__r.Duration_in_month__c)-Agency_Program__r.First_Notification__c -1</formula>
        <name>PRM Update Renewal Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRM_Update_Second_Notification_Date</fullName>
        <field>Second_Notification_Date__c</field>
        <formula>ADDMONTHS(StartDate,Agency_Program__r.Duration_in_month__c)-Agency_Program__r.Second_Notification__c -1</formula>
        <name>PRM Update Second Notification Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PRM_Update_Third_Notification_Date</fullName>
        <field>Third_Notification_Date__c</field>
        <formula>ADDMONTHS(StartDate,Agency_Program__r.Duration_in_month__c)-Agency_Program__r.Third_Notification__c -1</formula>
        <name>PRM Update Third Notification Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContractName</fullName>
        <field>Name</field>
        <formula>Agency_Program__r.Name</formula>
        <name>UpdateContractName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_BudgetField</fullName>
        <description>To update budget field from Agency Program.</description>
        <field>Budget__c</field>
        <formula>Agency_Program__r.Price__c</formula>
        <name>Update_BudgetField</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_FirstNotificationDate</fullName>
        <field>First_Notification_Date__c</field>
        <formula>EndDate-Agency_Program__r.First_Notification__c</formula>
        <name>Update_FirstNotificationDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_FirstNotificationDateNSC</fullName>
        <field>First_Notification_Date__c</field>
        <formula>EndDate-Agency_Program__r.First_Notification__c -1</formula>
        <name>Update_FirstNotificationDateNSC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_RenewalDateNSC</fullName>
        <field>Renewal_date__c</field>
        <formula>EndDate-Agency_Program__r.First_Notification__c-1</formula>
        <name>Update_RenewalDateNSC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SecondNotificationDate</fullName>
        <field>Second_Notification_Date__c</field>
        <formula>EndDate-Agency_Program__r.Second_Notification__c</formula>
        <name>Update_SecondNotificationDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SecondNotificationDateNSC</fullName>
        <field>Second_Notification_Date__c</field>
        <formula>EndDate-Agency_Program__r.Second_Notification__c -1</formula>
        <name>Update_SecondNotificationDateNSC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_ThirdNotificationDate</fullName>
        <field>Third_Notification_Date__c</field>
        <formula>EndDate-Agency_Program__r.Third_Notification__c</formula>
        <name>Update_ThirdNotificationDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_ThirdNotificationDateNSC</fullName>
        <field>Third_Notification_Date__c</field>
        <formula>EndDate-Agency_Program__r.Third_Notification__c -1</formula>
        <name>Update_ThirdNotificationDateNSC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CTR_WR01_CRM_Bid Grid - QC Budget Analyst Assigned</fullName>
        <actions>
            <name>CTR_WEA01_CRM_Contract_Bid_Grid_QC_budget_analyst_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM- ESPSFDCQI-3233, Email sent to the budget analyst assigned to QC</description>
        <formula>AND(   OR(     $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,      !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c   ),   !(ISBLANK(Grid_QC_Assigned_to__c ))    )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR01_PRM_UpdateRenewalDate</fullName>
        <actions>
            <name>CTR_WFU01_PRM_RenewalDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PRM - ACN - Workflow to update the renewal date as the formula field (renewal date) cannot be used in process builder</description>
        <formula>AND(RecordType.DeveloperName == &apos;PRM_Contract&apos;, NOT(ISNULL(Product__c)),NOT(ISNULL(EndDate)),  OR(ISNEW(),ISCHANGED(Product__c) , ISCHANGED(EndDate)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR02_CRM_Cardiac safety contract stage change</fullName>
        <actions>
            <name>CTR_WEA02_CRM_Cardiac_Safety_contract_status_change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM- ESPSFDCQI-3233,  sends email to CSS mailbox and contract analyst only if contract has been identified as a CSS contract and the analyst field has been populated.</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  !(ISBLANK( CSS_CD_Contract_Analyst__c )),  ISPICKVAL( CSS_CD_Contract_Involvement__c , &apos;Yes&apos;),  OR(  ISPICKVAL( Status,&apos;Contract Executed&apos;),  ISPICKVAL( Status,&apos;Negotiation Terminated&apos;),  ISPICKVAL( Status,&apos;On Hold&apos;),  ISPICKVAL( Status,&apos;Under Review - PM&apos;),  ISPICKVAL( Status,&apos;Under Review - Client&apos;),  ISPICKVAL( Status,&apos;Under Review - Legal&apos;),  ISPICKVAL( Status,&apos;Under Review - Finance&apos;),  ISPICKVAL( Status,&apos;Insufficient Information Received/Waiting ICOF from PM&apos;)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR03_CRM_Cardiac Safety involvement alert</fullName>
        <actions>
            <name>CTR_WEA03_CRM_Cardiac_Safety_Contract_Involvement</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, alert sent to CSS-Contract CRM notices mailbox when a contract has been identified as having Cardiac Safety involvement</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  ISPICKVAL( CSS_CD_Contract_Involvement__c , &apos;Yes&apos;),  !(ISBLANK( CSS_CD_Contract_Analyst__c )),  OR(  ISPICKVAL( Status,&apos;Contract Executed&apos;),  ISPICKVAL( Status,&apos;Negotiation Terminated&apos;),  ISPICKVAL( Status,&apos;On Hold&apos;),  ISPICKVAL( Status,&apos;Under Review - PM&apos;),  ISPICKVAL( Status,&apos;Under Review - Client&apos;),  ISPICKVAL( Status,&apos;Under Review - Legal&apos;),  ISPICKVAL( Status,&apos;Under Review - Finance&apos;),  ISPICKVAL( Status,&apos;Insufficient Information Received/Waiting ICOF from PM&apos;)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR04_CRM_Contract QIP loaded notification</fullName>
        <actions>
            <name>CTR_WEA34_CRM_Notification_to_contract_owner_and_PFM_when_contract_QIP_has_been</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM- ESPSFDCQI-3233, email sent when QIP loaded field checked</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),   ISPICKVAL(QIP_Loaded__c , &apos;Yes&apos;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR05_CRM_ECD %28Ph 1%2FPK-PD%29 involvement alert</fullName>
        <active>true</active>
        <description>CRM- ESPSFDCQI-3233, alert sent to ECD_Ph1_PKPD_Global Contracts-Change_Orders mailbox when a contract has been identified as having ECD (Ph1/PK-PD)involvement</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),   ISPICKVAL(ECD_PK_PD_Stats_Contract_Involvement__c, &apos;Yes&apos;),  !(ISBLANK( ECD_ph_1_PK_PD_Contract_Analyst__c)),  OR(   ISPICKVAL(Status, &apos;Contract Executed&apos;), ISPICKVAL(Status, &apos;Negotiation Terminated&apos;), ISPICKVAL(Status, &apos;On Hold&apos;), ISPICKVAL(Status, &apos;In Development&apos;), ISPICKVAL(Status, &apos;Under Review - PM&apos;), ISPICKVAL(Status, &apos;Under Review - Client&apos;), ISPICKVAL(Status, &apos;Under Review - Legal&apos;), ISPICKVAL(Status, &apos;Under Review - Finance&apos;), ISPICKVAL(Status, &apos;Insufficient Information Received/Waiting ICOF from PM&apos;) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR06_CRM_Contract alert when Global P%2FU Field populated</fullName>
        <actions>
            <name>CTR_WEA06_CRM_alerts_PFM_and_PM_when_Global_P_U_field_is_populated_on_a_contra</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, email sent to the contract owner when the Global P/U field is populated by the PFM for the first time. Also populated the &apos;Date Global p/U entered&apos; field</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  !(ISBLANK( Total_Pick_up__c))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR07_CRM_Contract signed alert</fullName>
        <actions>
            <name>CTR_WEA07_CRM_Contract_signed_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233,email sent to Contract Owner, Q Project Manager - Contact and Q Project Finance Manager when the customer signed date has been entered</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  !(ISBLANK(CustomerSignedDate)),  !ISPICKVAL( Division_Business_Unit__c,&apos;Lab&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR08_CRM_CRO Preliminary LOI%2FSUWO expiration alerts</fullName>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, sends email to Q contract manager 30 days, 15 days and 5 days prior to contract end date - only on CRM Preliminary contracts</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  if( RecordType.Name == &apos;Preliminary Agreement - GBO&apos;,true,false) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CTR_WR09_CRM_CRO%3A ATP expiry alert</fullName>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, email sent to PL, CA and PFM when expiry within 30 days</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  if( RecordType.Name == &apos;Preliminary Agreement - GBO&apos;,true,false) , OR( ISPICKVAL( Original_signed_agreement_location__c,&apos;QAHM&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QBAN&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QBEJ&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QBKK&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QDLN&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QHAN&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QHCM&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QHKG&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QJKT&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QKUL&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QMEL&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QMNL&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QSEL&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QSHN&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QSNG&apos;),  ISPICKVAL( Original_signed_agreement_location__c,&apos;QSYD&apos;), ISPICKVAL( Original_signed_agreement_location__c,&apos;QTPE&apos;) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CTR_WR10_CRM_ECD contract stage change</fullName>
        <actions>
            <name>CTR_WEA12_CRM_ECD_contract_status_change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, sends email to ECD mailbox and contract analyst only if contract has been identified as a ECD contract and the analyst field has been populated</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),   !(ISBLANK( ECD_ph_1_PK_PD_Contract_Analyst__c )),  ISPICKVAL(ECD_PK_PD_Stats_Contract_Involvement__c, &apos;Yes&apos;)   )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR11_CRM_Email Alert on Auto Contract Creation</fullName>
        <actions>
            <name>CTR_WEA13_CRM_Email_Alert_to_BD_on_Auto_Contract_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, Email Alert on Auto Contract Creation</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  AND( ISNEW(), (RecordType.Name = &quot;Generic Contract&quot;), ISPICKVAL(Status, &quot;Pending Assignment&quot;) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR12_CRM_Email Alert to Project Finance Manager</fullName>
        <actions>
            <name>CTR_WEA32_CRM_QIP_is_now_SMART_Ready</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, Alert when the Status is changed to = Budget at Customer for the first time with Confidence at High and QIP Loaded? = YES .</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  AND( ISCHANGED(Status), ISPICKVAL(Status, &apos;Budget at Customer for Review&apos;), ISPICKVAL(QIP_Loaded__c,&quot;Yes&quot;), ISPICKVAL(Confidence_in_Approval_of_Budget_Draft__c,&quot;High&quot;), Entered_Budget_at_Customer_Review__c = FALSE ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR13_CRM_PFM and PM alert when a contract unsigned status field is populated</fullName>
        <actions>
            <name>CTR_WEA14_CRM_PFM_and_PM_alert_when_unsigned_status_populated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, email sent to the PFM and PM when the contract is either created or updated and the unsigned status is populated.</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  !ISPICKVAL(Unsigned_Status__c, &apos;&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR14_CRM_PFM and PM alert when contract status changes</fullName>
        <actions>
            <name>CTR_WEA15_CRM_PFM_and_PM_alert_when_contract_status_is_changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, email sent to the PFM and PM when the contract status is - In development, Under Review, ready to execute, contract executed,on hold, negotiation terminated</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  OR(  ISPICKVAL( Status,&apos;Contract Executed&apos;),  ISPICKVAL( Status,&apos;Negotiation Terminated&apos;),  ISPICKVAL( Status,&apos;On Hold&apos;),  ISPICKVAL( Status,&apos;Under Review - PM&apos;),  ISPICKVAL( Status,&apos;Under Review - Client&apos;),  ISPICKVAL( Status,&apos;Under Review - Legal&apos;),  ISPICKVAL( Status,&apos;Under Review - Finance&apos;), ISPICKVAL( Status,&apos;In Development&apos;),  ISPICKVAL( Status,&apos;Ready to Execute&apos;),  ISPICKVAL( Status,&apos;Insufficient Information Received/Waiting ICOF from PM&apos;)  ) , !ISPICKVAL( Unsigned_Status__c,&apos;&apos;), !(ISBLANK( IQVIA_Project_Finance_Manager__c))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR15_CRM_Contracts - PFM and PM alert</fullName>
        <actions>
            <name>CTR_WEA16_CRM_PFM_and_PM_alert_when_contract_status_is_moved_to_Contract_Execute</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, email sent to the PFM and PM when the contract status is - contract executed</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  ISPICKVAL( Status,&apos;Contract Executed&apos;),  !ISPICKVAL( Unsigned_Status__c,&apos;&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR16_CRM_Third party vendor PM alert</fullName>
        <actions>
            <name>CTR_WEA17_CRM_Third_Party_Vendor_PM_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, sends an email to the PM when third party vendors involved</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  ISPICKVAL( Third_Party_Vendors_Involved__c,&apos;Yes&apos;), if( Owner.Full_User_Name__c == &apos;Global Sales Operations&apos;,false,true)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR17_CRM_Third party vendor PM alert when PM named added</fullName>
        <actions>
            <name>CTR_WEA18_CRM_Third_Party_Vendor_PM_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, sends an email to the PM when third party vendors involved and the PM name is added restrospecitvely</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  ISPICKVAL( Third_Party_Vendors_Involved__c,&apos;Yes&apos;),  !ISBLANK(IQVIA_Project_Finance_Manager__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR18_CRM_Time Based - Reminder Email to Upload QIP</fullName>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, Email to be sent to the Contract Analyst when a Contract enters the &quot;Budget at Customer Review&quot; stage for the first time, and when the QIP has not been loaded.</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  !Entered_Budget_at_Customer_Review__c, !ISPICKVAL( QIP_Loaded__c,&apos;Yes&apos;),  ISPICKVAL( Status,&apos;Budget at Customer for Review&apos;),  if( RecordType.Name == &apos;Change Order&apos;,true,false), ISPICKVAL( Budget_Tool__c,&apos;QIP&apos;),  !ISPICKVAL( Is_this_Contract_a_Ballpark__c,&apos;Yes&apos;),  ISPICKVAL( Confidence_in_Approval_of_Budget_Draft__c,&apos;High&apos;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CTR_WR19_CRM_Triage Assignment Complete</fullName>
        <actions>
            <name>CTR_WEA20_CRM_Triage_Assignment_BD_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CTR_WEA24_CRM_Triage_Assignment_CA_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CTR_WFU01_CRM_Triage_Assignment_BD_Statu</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233,  Triage Assignment Complete</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  AND( ISCHANGED(OwnerId), Owner.Full_User_Name__c &lt;&gt; &quot;Global Sales Operations&quot;, ISPICKVAL(Status, &quot;Pending Assignment&quot;), NOT(RecordType.Name = &apos;Third Party Agreement&apos; )) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR20_CRM_Bid Grid - Budget Analyst Assigned</fullName>
        <actions>
            <name>CTR_WEA21_CRM_Contract_Bid_Grid_assigned_budget_analyst_alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CTR_WEA22_CRM_Contract_Bid_Grid_budget_analyst_assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, Email Sent to the Contract Owner to Notify them of the BA assigned and the grid due date</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  !ISBLANK(Budget_Analyst_Assigned__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR21_CRM_PFM and PM alert when contract status changes to Contract Executed</fullName>
        <actions>
            <name>CTR_WEA22_CRM_PFM_and_PM_alert_when_contract_status_is_moved_to_Contract_Execute</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, email sent to the PFM and PM when the contract status is - contract executed</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  ISPICKVAL( Status,&apos;Contract Executed&apos;),  !ISPICKVAL( Unsigned_Status__c,&apos;&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR22_CRM_MSA Consolidation - new MSA</fullName>
        <actions>
            <name>CTR_WEA30_CRM_MSA_Consolidation_new_MSA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM- ESPSFDCQI-3233, email sent to Paula Foster whenever a new MSA is created</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),   BEGINS (RecordType.Name, &apos;Master Service Agreement&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR23_CRM_MSA Moved to Executed</fullName>
        <actions>
            <name>CTR_WEA31_CRM_MSA_Moved_to_Executed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233, email sent to Paula Foster for MSA consolidation</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  ISPICKVAL( Status,&apos;Contract Executed&apos;),  (RecordType.Name == &apos;Master Service Agreement&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR24_CRM_Time based - Contract expiry date reminder</fullName>
        <active>true</active>
        <description>CRM-ESPSFDCQI-3233,sends reminder 1 month prior, 14 days prior and 14 days past contract end date - requested by Natasha Raina</description>
        <formula>AND(OR($Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c, !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), OR(RecordType.DeveloperName == &apos;Change_Order&apos;, RecordType.DeveloperName == &apos;General_Client_Agreement_GBO&apos;,RecordType.DeveloperName == &apos;Master_Service_Agreement&apos;,RecordType.DeveloperName == &apos;Preliminary_Agreement_GBO&apos;,RecordType.DeveloperName == &apos;Work_Order_GBO&apos;), Business_Line_Grouping__c == &apos;Clinical&apos;, OR(ISPICKVAL(Status, &apos;Contract Executed&apos;),  ISPICKVAL(Status, &apos;Contract Executed - Ready to Lock&apos;), ISPICKVAL(Status, &apos;Contract Executed - Locked&apos;)), OR(Owner.Full_User_Name__c == &apos;Natasha Raina&apos;, Owner.Full_User_Name__c == &apos;April Fitzpatrick&apos;, Owner.Full_User_Name__c == &apos;Luba Lazarova&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CTR_WR25_CRM_Project finance alert when MSA marked as executed</fullName>
        <active>false</active>
        <description>CRM-ESPSFDCQI-3233,email sent to project finance global and Julie Meeder when a Master/PPA - MSA record is marked as executed</description>
        <formula>AND(  OR(  $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c,  !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c  ),  ISPICKVAL( Status,&apos;Contract Executed&apos;),   (RecordType.Name == &apos;Master Service Agreement&apos;), ISPICKVAL( Specific_Contract_Type__c,&apos;Master Services Agreement&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR26_CRM-Email Alert%3A Contract Triage Assignment</fullName>
        <actions>
            <name>CTR_WEA25_CRM_Triage_Assignment_CA_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-MC-ESPSFDCQI-2970</description>
        <formula>AND(OR($Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c, !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c), ISCHANGED(IQVIA_Contract_Manager_Contact__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR27_CRM-Email Alert%3A D45 to SIV Alert</fullName>
        <actions>
            <name>If_Planned_Execution_Date_is_between_31_to_45_days_earlier_than_1st_SIV_date</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-MC-ESPSFDCQI-4366</description>
        <formula>AND( !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c, 	 OR(ISCHANGED(Anticipated_date_for_1st_SIV__c),ISNew()),      	 ( Anticipated_date_for_1st_SIV__c - TODAY() &lt;= 45 ),( Anticipated_date_for_1st_SIV__c - TODAY() &gt;= 31 ), 	 NOT(OR(ISPICKVAL( Status , &apos;Ready to Execute&apos; ), ISPICKVAL( Status , &apos;Contract Executed&apos; ), ISPICKVAL( Status , &apos;Contract Executed - Ready to Lock&apos; ),      ISPICKVAL( Status , &apos;Activated&apos; ), ISPICKVAL( Status , &apos;Negotiation Terminated&apos;), ISPICKVAL( Status , &apos;On Hold&apos;),ISPICKVAL( Status , &apos;Closed for Internal Purposes&apos;) )) 	 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR28_CRM-Email Alert%3A D30 to SIV Alert</fullName>
        <actions>
            <name>If_Planned_Execution_Date_is_between_0_to_30_days_earlier_than_1st_SIV_date</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>CRM-MC-ESPSFDCQI-4366</description>
        <formula>AND( !$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c, 	 OR(ISCHANGED(Anticipated_date_for_1st_SIV__c),ISNew()),      	 ( Anticipated_date_for_1st_SIV__c - TODAY() &lt;= 30 ),( Anticipated_date_for_1st_SIV__c - TODAY() &gt;= 0 ), 	 NOT(OR(ISPICKVAL( Status , &apos;Ready to Execute&apos; ), ISPICKVAL( Status , &apos;Contract Executed&apos; ), ISPICKVAL( Status , &apos;Contract Executed - Ready to Lock&apos; ),      ISPICKVAL( Status , &apos;Activated&apos; ), ISPICKVAL( Status , &apos;Negotiation Terminated&apos;), ISPICKVAL( Status , &apos;On Hold&apos;),ISPICKVAL( Status , &apos;Closed for Internal Purposes&apos;) )) 	 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR29_CRM-Email Alert On Site Activation requested</fullName>
        <actions>
            <name>If_Site_Activation_requested_is_Yes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.Lead_Business_Group__c</field>
            <operation>equals</operation>
            <value>Contract Research Organization</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Division_Business_Unit__c</field>
            <operation>equals</operation>
            <value>Core Clinical</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Site_Activation_requested__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Status</field>
            <operation>notEqual</operation>
            <value>Activated,Contract Executed,Negotiation Terminated,On Hold,Ready to Execute,Closed for Internal Purposes,Contract Executed - Ready to Lock</value>
        </criteriaItems>
        <description>CRM-MC-ESPSFDCQI-4366</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CTR_WR30_CRM_Third_Party_Vendor_Contract_Requests</fullName>
        <actions>
            <name>CTR_WEA30_CRM_Third_Party_Vendor_Contract_Requests</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CTR_WFU01_CRM_Triage_Assignment_BD_Statu</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>ESPSFDCQI-11738</description>
        <formula>AND(
    ISCHANGED(OwnerId),
    RecordType.Name == &apos;Third Party Agreement&apos;
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PRM_UpdateContractName</fullName>
        <actions>
            <name>UpdateContractName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
		<description>PRM-987 Workflow Migrated to flow.</description>
        <booleanFilter>1 AND (2 OR 3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Contract.Non_Standard_Contract__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.PRM_Contract_type__c</field>
            <operation>equals</operation>
            <value>Agency Program SOW</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.PRM_Contract_type__c</field>
            <operation>equals</operation>
            <value>Sandbox Agreement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.PRM_Contract_type__c</field>
            <operation>equals</operation>
            <value>Data Program</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PRM_UpdateEndDate</fullName>
        <actions>
            <name>PRM_Update_EndDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PRM_Update_First_Notification_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PRM_Update_Renewal_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PRM_Update_Second_Notification_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PRM_Update_Third_Notification_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
		<description>PRM-987 Workflow Migrated to flow.</description>
        <booleanFilter>(1 OR 4 OR 5) AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Contract.PRM_Contract_type__c</field>
            <operation>equals</operation>
            <value>Agency Program SOW</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.StartDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Non_Standard_Contract__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.PRM_Contract_type__c</field>
            <operation>equals</operation>
            <value>Sandbox Agreement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.PRM_Contract_type__c</field>
            <operation>equals</operation>
            <value>Data Program</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PRM_UpdateNonStandardContract</fullName>
        <actions>
            <name>Update_FirstNotificationDateNSC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_RenewalDateNSC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_SecondNotificationDateNSC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_ThirdNotificationDateNSC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
		<description>PRM-987 Workflow Migrated to flow.</description>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND (8 OR 9 OR 10)</booleanFilter>
        <criteriaItems>
            <field>Contract.Non_Standard_Contract__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.EndDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.First_Notification_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Second_Notification_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Third_Notification_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Renewal_date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.StartDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.PRM_Contract_type__c</field>
            <operation>equals</operation>
            <value>Agency Program SOW</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.PRM_Contract_type__c</field>
            <operation>equals</operation>
            <value>Sandbox Agreement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.PRM_Contract_type__c</field>
            <operation>equals</operation>
            <value>Data Program</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PRM_UpdateNotificationDates</fullName>
        <actions>
            <name>Update_FirstNotificationDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_SecondNotificationDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_ThirdNotificationDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contract.EndDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
