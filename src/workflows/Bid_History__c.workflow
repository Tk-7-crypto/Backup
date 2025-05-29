<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BHR_EA01_CRM_Awarded_email_alert_Rob_Von_Alten</fullName>
        <ccEmails>rob.von.alten@quintiles.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-3949-CRM-MC-ESPSFDCQI-3284-Awarded email alert - Rob Von Alten</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET01_OWF_AwardedEmail_RobVonAlten_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA02_OWF_Bid_Auto_Alert_DD</fullName>
        <ccEmails>Proposals@DrugDev.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-3955-CRM-MC-ESPSFDCQI-3284-Bid Auto Alert - DD</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET02_OWF_Auto_Alert_Information</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA03_CRM_Bid_Grid_budget_analyst_assigned</fullName>
        <ccEmails>requestforbidgrids@quintiles.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-3949-CRM-MC-ESPSFDCQI-3284-Bid Grid - budget analyst assigned</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Supporting_Bid_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET03_OWF_BidGrdBugetAnlystAsigned_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA04_CRM_Bid_Grid_QC_budget_analyst_alert</fullName>
        <ccEmails>requestforbidgrids@quintiles.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-3949-CRM-MC-ESPSFDCQI-3284-Bid Grid - QC budget analyst alert</description>
        <protected>false</protected>
        <recipients>
            <field>Grid_QC_Assigned_to__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_OWF_ET04_BidGridQCasignedAlert_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA05_CRM_Bid_History_CSS_insufficient_information_alert</fullName>
        <description>OWF- IQVIAPSA-3955-CRM-MC-ESPSFDCQI-3284-Bid History - CSS insufficient information alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_OWF_ET06_BidHistoryInsufficientInfo</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA06_CRM_Bid_History_Exec_Review</fullName>
        <ccEmails>strategic.pricing@quintiles.com.invalid</ccEmails>
        <description>CRM-MC-ESPSFDCQI-3284-Bid History - Exec Review</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET05_OWF_Bid_History_Exec_Review_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA08_CRM_Pricing_considerations_alert</fullName>
        <description>CRM-MC-ESPSFDCQI-3284-Pricing considerations alert</description>
        <protected>false</protected>
        <recipients>
            <field>Strategic_Pricing_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET07_OWF_PricingConsiderationsAlert</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA09_CRM_BidHistoryClientBidGridTeamAlert</fullName>
        <ccEmails>requestforbidgrids@quintiles.com.invalid</ccEmails>
        <description>CRM-MC-ESPSFDCQI-3284-Bid History Client Bid Grid Team Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET08_OWF_BidHistryClientGridAlert_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA10_CRM_EBP_2_0</fullName>
        <ccEmails>RFPIntake@novellaclinical.com.Invalid</ccEmails>
        <ccEmails>request.proposal.global@quintiles.com.Invalid</ccEmails>
        <description>OWF-IQVIAPSA-3955-CRM-MC-ESPSFDCQI-3284-EBP 2.</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET11_OWF_EBP_2_0_alert_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA11_OWF_Clinical2RFP_Alert</fullName>
        <ccEmails>request.proposal.global@quintiles.com.invalid</ccEmails>
        <description>OWF-IQVIAPSA-3955-CRM-MC-ESPSFDCQI-3284-update OWF-ESPSFDCQI-4536-Clinical Bid alert to RFP mailbox</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET12_OWF_ClinicalBidAlert2RFP_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA11_OWF_EBP_2_0</fullName>
        <ccEmails>sfdc_automation@iqvia.com.invalid</ccEmails>
        <description>OWF-IQVIAPSA-3955-OWF-ESPSFDCQI-4480-EBP 2.0</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET11_OWF_EBP_2_0_alert_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA12_CRM_NotificationtoRebidownerwhenQIPhasbeenloaded</fullName>
        <ccEmails>QIP.Submission@Quintiles.com.invalid</ccEmails>
        <description>CRM-MC-ESPSFDCQI-3284-Notification to opp owner, creator, project finance, QIP submissions and bid owner when QIP has been loaded</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Supporting_Bid_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET13_OWF_QIPLoaded_Sep2015_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA13_CRM_NewQIPSubmitted</fullName>
        <ccEmails>QIP.submission@quintiles.com.invalid</ccEmails>
        <ccEmails>Sheila.Barber@Quintiles.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-3955-CRM-MC-ESPSFDCQI-3284-New QIP Submitted</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET14_CRM_QIP_submission_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA14_OWF_RFI_Bid_Owner_assigned</fullName>
        <ccEmails>request_for_information@iqvia.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-3955-CRM-MC-ESPSFDCQI-3284-RFI Bid Owner assigned</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET15_OWF_RFI_Bid_owner_assigned</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA15_OWF_RFI_Request_Alert</fullName>
        <ccEmails>Request_for_information@quintiles.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-3955-CRM-MC-ESPSFDCQI-3284- RFI Request Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Q_Requester__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Supporting_Bid_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET30_OWF_RFI_Request_Bid_History</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA16_OWF_RFI_Request_Completed</fullName>
        <description>OWF- IQVIAPSA-3955-CRM-MC-ESPSFDCQI-3284- RFI Request Completed</description>
        <protected>false</protected>
        <recipients>
            <field>Q_Requester__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET17_OWF_RFI_Request_Completed_Bid_History</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA16_OWF_StrategicPricingLead</fullName>
        <description>OWF - ESPSFDCQI-4931 - Q2 strategic pricing email alert to pricing lead</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Strategic_Pricing_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>strategic.pricing@quintiles.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET21_OWF_StrategicPricingLead_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA19_OWF_BiotechBidderNotification</fullName>
        <ccEmails>BiotechRFPnotification@novellaclinical.com.invalid</ccEmails>
        <description>OWF- ESPSFDCQI-4305 Biotech Bidder Notification - Sends email to Biotech bidders when agreement created.</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET12_OWF_ClinicalBidAlert2RFP_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA22_EarlyEngagementBid</fullName>
        <ccEmails>Tammy.Clemmer@quintiles.com.invalid</ccEmails>
        <ccEmails>Krista.Stephenson@quintiles.com.invalid</ccEmails>
        <ccEmails>Tanja.Wagner@quintiles.com.invalid</ccEmails>
        <ccEmails>RWRFPAssignments@iqvia.com.invalid</ccEmails>
        <description>OWF-IQVIAPSA-3955-BHR_EA22-EarlyEngagementBid</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET22_OWF_RWEEarlyEngagementBid</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA23_OWF_AgreementCreation</fullName>
        <description>OWF- IQVIAPSA-3955-BHR_EA23_OWF_AgreementCreation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET24_OWF_AgreementCreation_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA23_OWF_BudgetAnalystAssigned</fullName>
        <description>OWF - ESPSFDCQI-5837 - CRM Enhancement - RDS: Bid Grid Updates</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Budget_Analyst_Assigned__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET23_OWF_BudgetAnalystAssigned_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA23_OWF_Clinical2RFP_Alert_LOB_LCS</fullName>
        <description>OWF- IQVIAPSA-3955-Clinical Bid alert to RFP mailbox LOB=LCS and Requested service = LCS</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET12_OWF_ClinicalBidAlert2RFP_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA24_OWF_RiskBasedMonitoring</fullName>
        <ccEmails>Paula.Butler@iqvia.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-3955-BHR_EA24_OWF_RiskBasedMonitoring</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET25_OWF_RiskBasedMonitoring_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA25_OWF_Clinical2RFP_Alert_LOBIntervention_biosimilar</fullName>
        <description>OWF- IQVIAPSA-3955-Clinical Bid alert to LOB=Biosimilars and intervention type = Biosimilars</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET12_OWF_ClinicalBidAlert2RFP_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA26_OWF_AgreementCreationOCTRFx</fullName>
        <ccEmails>OCT_RFx@iqvia.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-4213-BHR_EA26_OWF_AgreementCreationOCTRFx</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET26_OWF_AgreementCreationOCT_RFx_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA27_OWF_LCSGRAServicesAlert</fullName>
        <ccEmails>globalregulatoryrfp@quintiles.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-4462-BHR_EA27_OWF_LCSGRAServicesAlert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET27_OWF_LCSGRA_Services_Alert_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA28_OWF_Clinical_Bid_Alert_To_CNS</fullName>
        <ccEmails>request.proposal.global@quintiles.com.invalid</ccEmails>
        <ccEmails>CNS_Opportunities_PL_Triage@iqvia.com.invalid</ccEmails>
        <description>BHR EA28 OWF Clinical Bid Alert To CNS</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET12_OWF_ClinicalBidAlert2RFP_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA28_OWF_bid_creation_of_RNPS_requested</fullName>
        <ccEmails>RNPSRequest@iqvia.com.invalid</ccEmails>
        <description>OWF IQVIAPSA 4959 BHR EA26 OWF bid creation of RNPS requested</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET28_OWF_RNPS_RIS_Alert_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA31_OWF_ClinicalBid_Alert</fullName>
        <ccEmails>RADDS_Triage_Proposals@iqvia.com.invalid</ccEmails>
        <description>OWF-IQVIAPSA-7372-Clinical Bid alert for Drug Dev/Pre Registration/ Registration services</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET12_OWF_ClinicalBidAlert2RFP_VF</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA32_OWF_GCC_Approval_Alert</fullName>
        <ccEmails>RequestforproposalGCC@iqvia.com.invalid</ccEmails>
        <description>IQVIAPSA-9922 GCC Approval Process- Approval- Alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET31_OWF_GCC_Approval_Required</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA33_OWF_GCC_Approval_Process_Approved_Alert</fullName>
        <ccEmails>RequestforproposalGCC@iqvia.com.invalid</ccEmails>
        <description>IQVIAPSA-9922 GCC Approval Process- Approved- Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET32_OWF_GCC_Approval_Approved</template>
    </alerts>
    <alerts>
        <fullName>BHR_EA34_OWF_GCC_Approval_Process_Approval_Rejected_Alert</fullName>
        <ccEmails>RequestforproposalGCC@iqvia.com.invalid</ccEmails>
        <description>IQVIAPSA-9922 GCC Approval Process-Approval Rejected Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET33_OWF_GCC_Approval_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Bid_History_OWF_CSS_Bid_alert_to_RFP_mailbox</fullName>
        <ccEmails>GlobalECGProposalRequest@quintiles.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-3955-Bid History - CSS Bid alert to RFP mailbox</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET20_CSS_Bid_alert_to_RFP_mailbox_VF</template>
    </alerts>
    <alerts>
        <fullName>OWF_IQVIAPSA_5186_BHR_EA30_OWF_AgreementCreationGCC</fullName>
        <ccEmails>RequestforproposalGCC@iqvia.com.invalid</ccEmails>
        <description>OWF- IQVIAPSA-5186-BHR_EA30_OWF_AgreementCreationGCC</description>
        <protected>false</protected>
	    <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Opportunity_Owner_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/BHR_ET29_OWF_AgreementCreationGCC_VF</template>
    </alerts>
    <alerts>
        <fullName>Q2LAB_scientific_review_level_1_escalation</fullName>
        <ccEmails>usatl-SBX-ScientificReview@quintiles.com.invalid</ccEmails>
        <ccEmails>ross.cubbon@q2labsolutions.com.invalid</ccEmails>
        <description>Q2LAB scientific review level 1 escalation</description>
        <protected>false</protected>
        <recipients>
            <recipient>christine.lonchampt@iqvia.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Q2_BD_Templates/Bid_History_Q2LAB_scientific_review_level_1_escalation</template>
    </alerts>
    <alerts>
        <fullName>Q2LAB_scientific_review_level_2_escalation</fullName>
        <ccEmails>usatl-SBX-ScientificReview@quintiles.com.invalid</ccEmails>
        <ccEmails>Patrice.hugo@q2labsolutions.com.invalid</ccEmails>
        <ccEmails>ross.cubbon@q2labsolutions.com.invalid</ccEmails>
        <description>Q2LAB scientific review level 2 escalation</description>
        <protected>false</protected>
        <recipients>
            <recipient>christine.lonchampt@iqvia.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Q2_BD_Templates/Bid_History_Q2LAB_scientific_review_level_2_escalation</template>
    </alerts>
    <alerts>
        <fullName>Q2_Notification_to_Opportunity_Owner_and_Proposal_developer</fullName>
        <description>Q2 Notification to Opportunity Owner and Proposal developer</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Q2_Approval_process/Q2_Final_Approval_Margin</template>
    </alerts>
    <alerts>
        <fullName>Q2_Notification_to_Opportunity_and_Bid_Owner_final_rejection</fullName>
        <description>Q2 Notification to Opportunity and Bid Owner final rejection</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Q2_Approval_process/Q2_Margin_rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Bid_History_Status_To_Approve</fullName>
        <field>Bid_History_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Bid History Status To Approve</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Bid_History_Status_To_Approved</fullName>
        <field>Bid_History_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Bid History Status To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Bid_History_Status_To_Rejected</fullName>
        <field>Bid_History_Status__c</field>
        <literalValue>Approval rejected</literalValue>
        <name>Bid History Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_Approved_Date</fullName>
        <field>Margin_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>Field Update: Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_Margin_Approved_No</fullName>
        <description>populates with No</description>
        <field>Margin_Approved__c</field>
        <literalValue>No</literalValue>
        <name>Field Update: Margin Approved No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_Margin_Approved_Yes</fullName>
        <field>Margin_Approved__c</field>
        <literalValue>Yes</literalValue>
        <name>Field Update: Margin Approved = Yes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_Q2_Margin_Appr_Date_NULL</fullName>
        <field>Margin_Approval_Date__c</field>
        <name>Field Update: Q2 Margin Appr Date NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_Q2_Margin_Approved_by_NULL</fullName>
        <field>Margin_Approved_By__c</field>
        <name>Field Update: Q2 Margin Approved by NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BGR-WR17-OWF-RFI Request Completed</fullName>
        <actions>
            <name>BHR_EA16_OWF_RFI_Request_Completed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3955-CRM-MC-ESPSFDCQI-3284 - email sent to requester and creator when status is moved to sent</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), RecordType.Name == &apos;RFI Request&apos;, ISPICKVAL(Bid_Sent__c, &apos;Yes&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR WR 30 OWF RNPS service added</fullName>
        <actions>
            <name>BHR_EA28_OWF_bid_creation_of_RNPS_requested</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-4959-Alert sent each time a new bid with RNPS service related is created for clinical  Record Type</description>
        <formula>AND(INCLUDES( Requested_Services__c , &apos;RNPS&apos;),(RecordType.DeveloperName == &apos;Clinical_Short_Form&apos; || RecordType.DeveloperName == &apos;Clinical_Bid&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR01-CRM-Awarded email alert - Rob Von Alten</fullName>
        <actions>
            <name>BHR_EA01_CRM_Awarded_email_alert_Rob_Von_Alten</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284- email sent when the following additional services are selected and opportunity awarded - eDiary
o IVR (Cenduit)
o Translation Services
o Other Services</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.By_Pass_Flow_Process__c|| $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), Opportunity_Stage__c == &apos;7a. Closed Won&apos;, OR(INCLUDES(Additional_Services_Requested__c, &quot;IVR (Cenduit)&quot;), INCLUDES(Additional_Services_Requested__c, &quot;eDiary&quot;),INCLUDES(Additional_Services_Requested__c, &quot;Translation Services&quot;),INCLUDES(Additional_Services_Requested__c, &quot;Other Services/Specific Vendor requested&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR02-CRM-Bid Auto Alert</fullName>
        <actions>
            <name>BHR_EA02_OWF_Bid_Auto_Alert_DD</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.By_Pass_Flow_Process__c|| $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), AND( OR( ISPICKVAL(Bid_History_Related_Opportunity__r.Line_of_Business__c, &apos;Novella&apos;), ISPICKVAL(Bid_History_Related_Opportunity__r.Line_of_Business__c, &apos;Clinical&apos;), ISPICKVAL(Bid_History_Related_Opportunity__r.Line_of_Business__c, &apos;Outcome&apos;)), OR( ISPICKVAL(Bid_Type__c, &apos;Initial&apos;), ISPICKVAL(Bid_Type__c, &apos;Re-bid&apos;)), OR( ISPICKVAL( RFP_Ranking__c , &apos;2&apos;), ISPICKVAL( RFP_Ranking__c , &apos;3&apos;), ISPICKVAL( RFP_Ranking__c , &apos;4&apos;), ISPICKVAL( RFP_Ranking__c , &apos;5&apos;)) ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR03-CRM-Bid Grid - Budget Analyst Assigned</fullName>
        <actions>
            <name>BHR_EA03_CRM_Bid_Grid_budget_analyst_assigned</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284 - email sent to the bid grid owner to notify them of the BA assigned and the grid due date</description>
        <formula>AND( (!$Setup.Mulesoft_Integration_Control__c.By_Pass_Flow_Process__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), Budget_Analyst_Assigned__c != null, OR(RecordType.Name == &apos;Preferred Provider&apos;, RecordType.Name == &apos;Prelim Agreement&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR04-CRM-Bid Grid - QC Budget Analyst Assigned</fullName>
        <actions>
            <name>BHR_EA04_CRM_Bid_Grid_QC_budget_analyst_alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-OWF- IQVIAPSA-3949-CRM-MC-ESPSFDCQI-3284 - email sent to the budget analyst assigned to QC</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.By_Pass_Flow_Process__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), Grid_QC_Assigned_to__c != null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR05-CRM-Bid History - Exec Review</fullName>
        <actions>
            <name>BHR_EA06_CRM_Bid_History_Exec_Review</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284 -email sent to strategic pricing when bid over $20</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.By_Pass_Flow_Process__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), ISPICKVAL(Estimated_Fees__c,&apos;Greater than $20M&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR07-CRM-Bid History - Pricing considerations alert</fullName>
        <actions>
            <name>BHR_EA08_CRM_Pricing_considerations_alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284 - sends email to pricing team when bid sent = yes</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.By_Pass_Flow_Process__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), ISPICKVAL(Bid_Sent__c, &apos;Yes&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR08-CRM-Bid History Client Bid Grid Alert</fullName>
        <actions>
            <name>BHR_EA09_CRM_BidHistoryClientBidGridTeamAlert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284 - Sends and email to the request for Bid Grids mailbox</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.By_Pass_Flow_Process__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), ISPICKVAL(Client_Bid_Grid_Team__c, &apos;Request for Bid Grids&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR09-CRM-Bid History CSS - Insufficient Information</fullName>
        <actions>
            <name>BHR_EA05_CRM_Bid_History_CSS_insufficient_information_alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284 - sends email to Bid history owner/creator when more information required</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.By_Pass_Flow_Process__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), NOT(ISBLANK(TEXT(Insufficient_Information__c))), RecordType.Name = &apos;CSS Bid&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR11-CRM-IQVIA Biotech</fullName>
        <actions>
            <name>BHR_EA11_OWF_EBP_2_0</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284 - sends and email to Rob Murray, Elli Ganas and RFPIntake@novellaclinical.com and request for proposals.update name and criteria owf-ESPSFDCQI-4480</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.By_Pass_Flow_Process__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), ISPICKVAL(IQVIA_biotech__c,&apos;Yes&apos;),ISPICKVAL(Bid_Type__c,&apos;Initial&apos;),RecordType.Name ==&apos;Clinical&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR12-OWF-Clinical2RFP_Alert</fullName>
        <actions>
            <name>BHR_EA11_OWF_Clinical2RFP_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF-IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284-update July 16 2019
OWF-ESPSFDCQI-4305-Replace Novella Bid History Alert With: Clinical Bid alert to RFP mailbox</description>
        <formula>AND( (!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), OR(Line_of_Business__c ==&apos;Clinical&apos;,  Line_of_Business__c ==&apos;Data Sciences&apos;, Line_of_Business__c ==&apos;Safety &amp; Med Info&apos;, Line_of_Business__c ==&apos;Early Clinical Development&apos;, Line_of_Business__c ==&apos;Outcome&apos;, Line_of_Business__c ==&apos;Novella&apos;), RecordType.DeveloperName == &apos;Clinical_Bid&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR13-CRM-QIP Loaded notification</fullName>
        <actions>
            <name>BHR_EA12_CRM_NotificationtoRebidownerwhenQIPhasbeenloaded</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284 - Email sent to opp owner, creator, finance and bid owner when the QIP has been loaded</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.By_Pass_Flow_Process__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), ISPICKVAL(QIP_Loaded__c,&apos;Yes&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR14-OWF-CRM-QIP Submission Alert</fullName>
        <actions>
            <name>BHR_EA13_CRM_NewQIPSubmitted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284 - Alert sent each time a new bid is created using QIP or QIP plus Others</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.By_Pass_Flow_Process__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), NOT(ISBLANK(Bid_Sent_Date__c)), NOT(ISBLANK(Budget_Tools__c)), ISPICKVAL(QIP_Loaded__c,&apos;No&apos;), NOT(ISBLANK(Link_to_Budget_Files__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR15-OWF-CRM-RFI Bid Owner assigned</fullName>
        <actions>
            <name>BHR_EA14_OWF_RFI_Bid_Owner_assigned</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284 - sends email when RFI assigned</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), RecordType.Name == &apos;RFI Request&apos;, Owner:User.Username != null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR16-OWF-RFI Request Alert</fullName>
        <actions>
            <name>BHR_EA15_OWF_RFI_Request_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-CRM-MC-ESPSFDCQI-3284 - email sent to RFI group</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), OR(RecordType.Name == &apos;RFI Request&apos;, RecordType.Name == &apos;RFI&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR20-Bid History-OWF-CSS Bid alert to RFP mailbox</fullName>
        <actions>
            <name>Bid_History_OWF_CSS_Bid_alert_to_RFP_mailbox</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), RecordType.Name = &apos;CSS Bid&apos;, Line_of_Business__c = &apos;Connected Devices&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR21-OWF-Biotech Bidder Notification</fullName>
        <actions>
            <name>BHR_EA19_OWF_BiotechBidderNotification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-OWF - ESPSFDCQI-4305 - Sends email to Biotech bidders when agreement created</description>
        <formula>AND( (!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), OR(Line_of_Business__c = &apos;Novella&apos;, AND(Line_of_Business__c = &apos;Clinical&apos;, ispickval(IQVIA_biotech__c, &apos;Yes&apos;))))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR22-OWF-Strategic Pricing Lead</fullName>
        <actions>
            <name>BHR_EA16_OWF_StrategicPricingLead</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-OWF - ESPSFDCQI-4931 - Email sent to the strategic pricing lead when name populated</description>
        <formula>AND( (!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c),RecordType.DeveloperName &lt;&gt; &apos;Q2_Solutions&apos;, IF( ISBLANK( Strategic_Pricing_Lead__c ), False, IF( ISNEW(), True, IF( ISCHANGED(Strategic_Pricing_Lead__c), True, False))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR23-OWF-EarlyEngagementBid</fullName>
        <actions>
            <name>BHR_EA22_EarlyEngagementBid</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-OWF - ESPSFDCQI-4363 - Send An email to &quot;LP Triage&quot;, &quot;Tamara, Clemmer&quot;, &quot;Wagner Tanja&quot;,&quot;Krista Stephenson&quot;</description>
        <formula>AND( RecordType.Name = &apos;Early Engagement Bid&apos;, INCLUDES(Type_of_Engagement_Activity__c, &apos;RW NmBRE&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR24-OWF-BudgetAnalystAssigned</fullName>
        <actions>
            <name>BHR_EA23_OWF_BudgetAnalystAssigned</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-ESPSFDCQI-5837 - CRM Enhancement - RDS: Bid Grid Updates</description>
        <formula>AND( (!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), (RecordType.Name == &apos;Clinical Bid&apos;), IF( ISBLANK( Budget_Analyst_Assigned__c ), False, IF( ISCHANGED(Budget_Analyst_Assigned__c), True, False)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR25-OWF-AgreementCreation</fullName>
        <actions>
            <name>BHR_EA23_OWF_AgreementCreation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-ESPSFDCQI-6635 - Cenduit Acquisition Alerts</description>
        <formula>AND( (!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), RecordType.Name == &apos;Clinical Bid&apos;, INCLUDES(Requested_Services__c, &apos;Clinical Monitoring&apos;), Opportunity_Stage__c == &apos;3. Developing Proposal&apos;, OR(Line_of_Business__c == &apos;Clinical&apos; || Line_of_Business__c == &apos;Novella&apos;), OR(Phase__c == &apos;Phase 2&apos; || Phase__c == &apos;Phase 3&apos;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR26-OWF-Clinical_Alert_LOB_LCS</fullName>
        <actions>
            <name>BHR_EA23_OWF_Clinical2RFP_Alert_LOB_LCS</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-OWF-IQVIAPSA-2182 send mail according to LOB and request service (23 july 2020)</description>
        <formula>AND( (!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), OR(Line_of_Business__c ==&apos;Safety &amp; Med Info&apos;, INCLUDES(Requested_Services__c,&apos;Lifecycle Safety&apos;)), RecordType.DeveloperName == &apos;Clinical_Bid&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR26-OWF-RiskBasedMonitoring</fullName>
        <actions>
            <name>BHR_EA24_OWF_RiskBasedMonitoring</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-IQVIAPSA-2801 - Risk Based Monitoring Field is changed from Yes to No or No to Yes to provide a notification</description>
        <formula>AND( (!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), IF(ISPICKVAL(DTE_Study__c, &apos;&apos;), False, IF(ISCHANGED(DTE_Study__c), True, False)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR27-OWF-Clinical_Alert_LOB%26intervention_Biosimilar</fullName>
        <actions>
            <name>BHR_EA25_OWF_Clinical2RFP_Alert_LOBIntervention_biosimilar</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-3960-IQVIAPSA-2553 send email on LOB and Intervention type is Biosimilar</description>
        <formula>AND( (!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c), OR(Intervention_Type__c == &apos;Biosimilar&apos; ), RecordType.DeveloperName == &apos;Clinical_Bid&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR28-OWF-OCTRFx-Agreement Creation</fullName>
        <actions>
            <name>BHR_EA26_OWF_AgreementCreationOCTRFx</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-4213- Alert sent each time a new bid is created for OCT RFx Record Type</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c),(RecordType.DeveloperName == &apos;OCT_RFx_Bid&apos; || RecordType.DeveloperName == &apos;OCT_RFx_Short_Form&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BHR-WR29-OWF-LCS GRA Services Alert</fullName>
        <actions>
            <name>BHR_EA27_OWF_LCSGRAServicesAlert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-4462- Alert sent when GRA is selected as a Service.</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c),(RecordType.DeveloperName = &apos;Clinical_Short_Form&apos; || RecordType.DeveloperName = &apos;Clinical_Bid&apos;),(AND(ISPICKVAL(Bid_History_Related_Opportunity__r.Line_of_Business__c,&quot;Clinical&quot;),INCLUDES(Requested_Services__c ,&apos;Global Regulatory Affairs&apos;))))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
	<rules>
        <fullName>BHR-WR30-OWF-GCC-Agreement Creation</fullName>
        <actions>
            <name>OWF_IQVIAPSA_5186_BHR_EA30_OWF_AgreementCreationGCC</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>OWF- IQVIAPSA-5186- Alert sent each time a new bid is created for GCC Record Type</description>
        <formula>AND((!$Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c || $Setup.Mulesoft_Integration_Control__c.Is_Mulesoft_User__c),(RecordType.DeveloperName == &apos;GCC&apos; ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
