/**
 * This class used for constants used in OWF project.
 * version : 1.0
 */
public class CON_OWF {
    public static final String SEMI_COLON = ';';
    public static final Integer DEFAULT_BATCH_SIZE = 200;
    
    // This is all for query record type
    public static final String SOBJECT_TYPE_APTS_AGREEMENT = 'Apttus__APTS_Agreement__c';
    public static final String SOBJECT_TYPE_Bid_History = 'Bid_History__c';
    public static final String OPPORTUNITY_AGREEMENTS = 'Apttus__R00N50000001Xl0FEAS__r';
    public static final String OPPORTUNITY_Bid_History = 'Bid_Histories_Opportunity__r';
    public static final String OPPORTUNITY_GLOBAL_PROJECT_UNIT_MEDTECH = 'MedTech';
    public static final String BID_TYPE_CHANGE_ORDER = 'Change Order';
    public static final String AGREEMENT_PROJECTS = 'Projects__r';
    public static final String BID_HISTORY_PROJECTS = 'Bid_History__r';
    public static final String BID_HISTORY_STAGE_SENT = 'Sent';
    public static final String BID_HISTORY_STAGE_SIGNED_FINALIZED = 'Signed/Finalized';
    public static final String BID_HISTORY_STAGE_TERMINATED = 'Terminated';
    
    public static final String AGREEMENT_RESOURCE_REQUESTS = 'Resource_Requests__r';
    public static final String Bid_HISTORY_RESOURCE_REQUESTS = 'Bid_History_Resource_Requests__r';
    
    public static final String AGREEMENT_ASSIGNMENTS = 'Assignments__r';
    public static final String Bid_HISTORY_ASSIGNMENTS = 'Bid_History_Assignments__r';
    public static final String ASSIGNMENT_STATUS = 'pse__Status__c';
    public static final String RESOURCE_REQUEST_ASSIGNMENTS = 'pse__Assignments__r';
    public static final String RR_RESOURCE_SKILL_REQUESTS = 'pse__Resource_Skill_Requests__r';
    public static final String RESOURCE_SKILL_CERTIFICATION_RATINGS = 'pse__Skill_Certification_Ratings__r';
    
    public static final String OWF_STATUS_COMPLETE = 'Complete';
    public static final String OWF_STATUS_ACCEPTED = 'Accepted';
    public static final String OWF_STATUS_COMPLETED = 'Completed';
    public static final String OWF_STATUS_ASSIGNED = 'Assigned';
    public static final String OWF_STATUS_PENDING = 'Pending';
    public static final String OWF_STATUS_CANCELLED = 'Cancelled';
    public static final String OWF_STATUS_CLOSED = 'Closed';
    public static final String OWF_STATUS_REJECTED = 'Rejected';
    public static final String OWF_STATUS_READYTOSTAFF= 'Ready to Staff';
    public static final String OWF_BID_HISTORY_STATUS_IN_AWAITING_APPROVAL	 = 'Awaiting approval';
    public static final String OWF_BID_HISTORY_STATUS_IN_PROGRESS_ASSIGNED = 'In Progress - Assigned';
    public static final String OWF_BID_HISTORY_STATUS_AWAITING_CUSTOMER_FEEDBACK = 'Awaiting Customer Feedback';
    public static final String OWF_BID_HISTORY_STATUS_IN_PROGRESS_TRIAGE = 'In Progress - Triage';
    public static final String BHR_OWF_NotificationToGCCBidHistoryOnStatusUpdate  = 'Notification_To_GCCOnBHRStatusUpdate';
    public static final String OWF_NotificationToGCCForStatusUpdate = 'OWF_25_NotificationToGCC';   

    public static final String OWF_ASSIGNMENT_STATUS_ACCEPTED = 'Accepted';
    public static final String OWF_ASSIGNMENT_STATUS_COMPLETED = 'Completed';
    public static final String OWF_ASSIGNMENT_STATUS_CANCELLED = 'Cancelled';
    
    public static final String OWF_RESOURCE_REQUEST_RECORD_TYPE_NAME = 'OWF_Resource_Request';
    public static final String OWF_ASSIGNMENT_RECORD_TYPE_NAME = 'OWF_Assignment';
    public static final String BUDGET_TOOL_Q2_BIO='Q2 Bio';
    public static final String BUDGET_TOOL_VACCINES='Vaccines';
    public static final String Q2_BUDGET_TOOLS_RNPS_NURSE = 'RNPS (Nurse)';
    public static final String BID_PRE_POST_AWARD = 'Post Award';
    public static final String OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM = 'IQVIA RBM';
    public static final String OWF_BID_HISTORY_DTE_STUDY_NO = 'No';
    
    public static final String OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE = 'True';
    
    public static final String OWF_BID_HISTORY_RFP_DELIVERABLES_HIGH_LEVEL_COST = 'High level cost';
    public static final String OWF_BID_HISTORY_RFP_DELIVERABLES_SUMM_OF_GCC_CAP = 'Summary of GCC capabilities';
    public static final String OWF_BID_HISTORY_RFP_DELIVERABLES_ABBR_RFP_COST_BRK_AND_SUMM = 'Abbreviated RFP cost breakdown and summary';
    public static final String OWF_BID_HISTORY_RFP_DELIVERABLES_FULL_RFP_COMP_TXT_AND_COST_BRK = 'Full RFP comprehensive text and cost breakdown';
    
    public static final String OWF_BID_HISTORY_RFP_RANKING_LEVEL1 = 'Level 1';
    public static final String OWF_BID_HISTORY_RFP_RANKING_LEVEL2 = 'Level 2';
    public static final String OWF_BID_HISTORY_RFP_RANKING_LEVEL3 = 'Level 3';
    
    public static final String OWF_BID_HISTORY_STANDARD_TURNAROUND_TIME_BD_5_BUSINESS_DAYS = '5 Business Days';
    public static final String OWF_BID_HISTORY_STANDARD_TURNAROUND_TIME_BD_7_BUSINESS_DAYS = '7 Business Days';
    public static final String OWF_BID_HISTORY_STANDARD_TURNAROUND_TIME_BD_10_BUSINESS_DAYS = '10 Business Days';
    
    public static final String OWF_BID_HISTORY_OPPORTUNITY_TYPE_RFP = 'RFP';
    public static final String OWF_BID_HISTORY_OPPORTUNITY_TYPE_RFP_ONLY = 'RFI Only (no Pricing)';
    public static final String OWF_BID_HISTORY_OPPORTUNITY_TYPE_RFP_AND_RFI = 'RFP & RFI';
    public static final String OWF_BID_HISTORY_OPPORTUNITY_TYPE_INTERNAL = 'Internal';
    
    public static boolean runFutureJob = true;
    public static boolean allowDaysOffStatusUpdate = false;
    
    public static final String OPPORTUNITY_PHASE_4 = 'Phase 4';
    
    public static final Integer MAX_USER_IDS_COUNT = 35;
    public static final Integer MAX_EMAILS_COUNT = 50;
    //public static Id OWF_CLINICAL_BID_AGREEMENT_RECORD_TYPE_ID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId();
    public static Id OWF_NON_RFP_BID_AGREEMENT_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Non_RFP_Bid').getRecordTypeId();
    //public static Id OWF_EARLY_ENGAGEMENT_BID_AGREEMENT_RECORD_TYPE_ID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId();
    public static Id OWF_ASSIGNMENT_RECORD_TYPE_ID = Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByName().get('OWF Assignment').getRecordTypeId();
    public static Id OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Contract_Post_Award').getRecordTypeId();
    public static Id OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId();
    public static Id OWF_NON_RFP_BID_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Non_RFP_Bid').getRecordTypeId();
    public static Id OWF_RFI_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('RFI_Request').getRecordTypeId();
    public static Id OWF_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Post_Award_Bid').getRecordTypeId();
    public static Id OWF_EARLY_ENGAGEMENT_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId();
    public static Id OWF_OCT_RFX_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('OCT_RFx_Bid').getRecordTypeId();
    public static Id OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('CSS_Bid').getRecordTypeId();
    public static Id OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID =Schema.SObjectType.Bid_History__c.getRecordTypeInfosByName().get('Q² Solutions').getRecordTypeId();
    public static Id OWF_TECH_SOLUTIONS_SUPPORT_REQUEST_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Tech_Solutions_Support_Request').getRecordTypeId();
    public static Id OWF_GCC_SHORT_FORM_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('GCC_Short_Form').getRecordTypeId();
    public static Id OWF_COLLECTIONTOOL_IQVIA_TECHNOLOGIES_RECORD_TYPE_ID = Schema.SObjectType.CollectionTool__c.getRecordTypeInfosByDeveloperName().get('IQVIA_Technologies').getRecordTypeId();
    public static Id OWF_GCC_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('GCC').getRecordTypeId();
    public static Id OWF_COLLECTIONTOOL_Q2_SOLUTIONS_RECORD_TYPE_ID = Schema.SObjectType.CollectionTool__c.getRecordTypeInfosByDeveloperName().get('Q2_Solutions').getRecordTypeId();
    public static boolean isUpdatedFromContact = false;
    public static boolean isUpdatedViaPresentationDate = false; //IQVIAPSA-1852
    public static Set<Id> BIDS_DIRECTLY_CREATED_WITH_DEPENDING_ON_OPP_STAGE = new set<Id>{ Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Contract_Post_Award').getRecordTypeId()};
    /*public static final Set<Id> OWF_AGREEMENT_RECORD_TYPE_IDS_SET
     = new Set<Id>{Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId(),
     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('CSMS_Bid').getRecordTypeId(),
     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId(),
     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Non_RFP_Bid').getRecordTypeId(),
     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Post_Award_Bid').getRecordTypeId(),
     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('CSS_Bid').getRecordTypeId(),
     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('PPA_Agreement').getRecordTypeId(),
     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Prelim_Agreement').getRecordTypeId(), 
     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('RFI_Request').getRecordTypeId()};*/
    
     public static final Set<Id> OWF_AGREEMENT_RECORD_TYPE_BID_HISTORY
     = new Set<Id>{Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Clinical_Short_Form').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('CSMS_Short_Form').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('CSMS_Bid').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('CSS_Short_Form').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('CSS_Bid').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Non_RFP_Bid').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Post_Award_Bid').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('PPA_Agreement').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Prelim_Agreement').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('RFI_Short_Form').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('RFI_Request').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('GCC').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Tech_Solutions_Support_Request').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('OCT_RFx_Short_Form').getRecordTypeId(),
         Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Contract_Post_Award').getRecordTypeId(),
		 Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('OCT_RFx_Bid').getRecordTypeId()
         
         };
         
    public static final Id OWF_BID_PROJECT_RECORD_TYPE_ID = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Bid').getRecordTypeId();

    /*public static final Set<Id> RESOURCES_NEEEDED_FIELD_BASED_RR_AGR_RECORDTYPE_SET
     = new Set<Id>{
     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId(),
     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Post_Award_Bid').getRecordTypeId(),
     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Non_RFP_Bid').getRecordTypeId()};*/
         
    public static final Set<Id> RESOURCES_NEEEDED_FIELD_BASED_RR_BID_HISTORY_RECORDTYPE_SET
     = new Set<Id>{
     Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId(),
     Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Post_Award_Bid').getRecordTypeId(),
     Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Non_RFP_Bid').getRecordTypeId()};
     
   // public static Id OWF_RFI_AGREEMENT_RECORD_TYPE_ID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('RFI_Request').getRecordTypeId();
    public static Id OWF_RR_RECORD_TYPE_ID = Schema.SObjectType.pse__Resource_Request__c.getRecordTypeInfosByDeveloperName().get('OWF_Resource_Request').getRecordTypeId();
    //public static Id OWF_CLINICAL_BID_RECORD_TYPE_ID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId();
    //public static Id OWF_NON_RFP_BID_RECORD_TYPE_ID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Non_RFP_Bid').getRecordTypeId();
    //public static Id OWF_POST_AWARD_BID_RECORD_TYPE_ID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Post_Award_Bid').getRecordTypeId();
    //public static Id OWF_EARLY_ENGAGEMENT_BID_RECORD_TYPE_ID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId();
    public static Id OWF_CSMS_Bid_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('CSMS_Bid').getRecordTypeId();
    
    //Contact Record Type
    public static Id IQVIA_User_Contact_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IQVIA_User_Contact').getRecordTypeId();
	
    public static final Set<String> CONTRACT_POST_AWARD_AGREEMENT_PATHWAY_Set = new Set<String>{CON_OWF.AGREEMENT_PATHWAY_LATEPHASE, CON_OWF.AGREEMENT_PATHWAY_CLINICAL, CON_OWF.AGREEMENT_PATHWAY_OSA};
	
    //This is all for batch class names
    public static final String BCH_OWF_UPDATEASSIGNMENTSSTATUS = 'BCH_OWF_UpdateAssignmentsStatus';
    public static final String BCH_OWF_UPDATERESOURCEREQUESTSTATUS = 'BCH_OWF_UpdateResourceRequestStatus';
    public static final String BCH_OWF_ACCEPTUNASSIGNEDASSIGNMENTS = 'BCH_OWF_AcceptUnassignedAssignments';
    public static final String BCH_OWF_ASYNCBISDEFENCECREATION = 'BCH_OWF_AsyncBidDefenseCreation';
    public static final String BCH_OWF_UPDATEASSIGNMENTSCHEDULE = 'BCH_OWF_UpdateAssignmentSchedule';
    public static final String BCH_OWF_UPDATEASSIGNMENTESTEFFORT = 'BCH_OWF_UpdateAssignmentEstEffort';
    public static final String BCH_OWF_UPDATESUGGESTEDFTE = 'BCH_OWF_UpdateSuggestedFTE';
    public static final String QUEUEAGREEMENTDELETION = 'QueueAgreementDeletion';
    public static final String QUEUEPROJECTDELETION = 'QueueProjectDeletion';
    public static final String QUEUERESOURCEREQUESTDELETION = 'QueueResourceRequestDeletion';
    public static final String QUEUEOPPORTUNITYDELETION = 'QueueOpportunityDeletion';
    public static final String QUEUEASSIGNMENTDELETION = 'QueueAssignmentDeletion';
    public static final String BCH_OWF_Clean_AGR_Related_Projects = 'BCH_OWF_Clean_AGR_Related_Projects';
    public static final String BCH_OWF_Generate_Triage_Users_Report = 'BCH_OWF_Generate_Triage_Users_Report';
    public static final String BCH_ACCEPTING_MODE = 'Accepting_Records';
    public static final String BCH_COMPLETING_MODE = 'Completing_Records';
    public static final String DIVISION_BUSINESS_UNIT_OUTCOME = 'Outcome';
    public static final String DIVISION_BUSINESS_UNIT_RWLP = 'RWLP';
    public static final String DELIVER_UNIT_RWE = 'RWE';
    //
    public static final String RES_REQ_TYPE_BID_DEFENCE = 'Bid Defense';
    public static final String RES_REQ_TYPE_GBO_LEAD_PD = 'GBO-Lead PD';
    public static final String RES_REQ_TYPE_GBO_BID_GRID = 'GBO-Bid Grid';
    public static final String RES_REQ_TYPE_GBO_SUPPORT_PD = 'GBO-Support PD';
    public static final String RES_REQ_TYPE_GBO_OVERSIGHT = 'GBO-Oversight';
    public static final String RES_REQ_TYPE_Feasibility_Analytics = 'Feasibility Analytics';
    public static final String RES_REQ_TYPE_TSL = 'TSL';
    public static final String RES_REQ_TYPE_ADSC_CONSULTING = 'ADSC Consulting';
    public static final String RES_REQ_TYPE_AIML_SOLUTIONS = 'AIML Solutions';
    public static final String RES_REQ_TYPE_JAPAN = 'TSL-Japan';
    public static final String RES_REQ_TYPE_THERAPEUTIC_ANALYTICS_LEAD ='TAL';
	public static final String RES_REQ_ASL ='Analytics Strategy Lead';
    //public static final String RES_REQ_TYPE_SSI = 'CP&A-SSI Lead';
    public static final String RES_REQ_TYPE_Site_Analytics = 'Site Analytics';
    public static final String RES_REQ_TYPE_MEDICAL = 'Medical-MSL';
    public static final String RES_REQ_TYPE_SNP_PRODUCT_SPECIALIST = 'SPN Product Specialist';
    public static final String RES_REQ_TYPE_DSB = 'DSB-Clinical';
    public static final String RES_REQ_TYPE_TSL_BID_Defence = 'TSL BID Defence';
    public static final String RES_REQ_TYPE_MEDICAL_MSL_BID_Defence = 'Medical-MSL BID Defence';
    public static final String RES_REQ_TYPE_LCS_BID_Defence = 'LCS Bid Defense';
    public static final String RES_REQ_TYPE_DSB_LCS ='DSB-LCS';
    public static final String RES_REQ_TYPE_DSB_CEVA ='DSB-CEVA';
    public static final String RES_REQ_TYPE_DSB_MW ='DSB-MW';
    public static final String RES_REQ_TYPE_DSB_Bios ='DSB-Bios';
    public static final String RES_REQ_TYPE_DSB_DM ='DSB-DM';
    public static final String RES_REQ_TYPE_DSB_GSA ='DSB-GSA';
    public static final String RES_REQ_TYPE_DSB_ISS = 'DSB-ISS';
    public static final String RES_REQ_TYPE_DSB_PM ='DSB-PM';
    public static final String RES_REQ_TYPE_IG_LEAD ='IG-Lead';
    public static final String RES_REQ_TYPE_ECD_COE ='ECD-COE';
    public static final String RES_REQ_TYPE_ECD_COE_BID_Defence ='ECD-COE BID Defence';
    public static final String RES_REQ_TYPE_LCS_PRODUCT_SPECIALIST ='LCS Product Specialist';
    public static final String RES_REQ_TYPE_DESIGN_ANALYTICS ='Design Analytics';
    public static final String RES_REQ_TYPE_DESIGN_ANALYTICS_BID_Defence ='Design Analytics BID Defence';
    public static final String RES_REQ_TYPE_BIOSIMILAR_COE ='Biosimilar-COE';
    public static final String RES_REQ_TYPE_PRD_COE ='PRD-COE';
    public static final String RES_REQ_TYPE_PRD_COE_BID_DEFENCE ='PRD-COE BID Defence';
    public static final String RES_REQ_TYPE_Clinical_Coding ='Clinical Coding';
    public static final String RES_REQ_TYPE_GLOBAL_ANALYTICS ='Global Analytics';
    public static final String RES_REQ_TYPE_STS_LEAD ='STS-Lead';
    public static final String RES_REQ_TYPE_CTE_LEAD ='CTE-Lead';
    public static final String RES_REQ_TYPE_CTS_LEAD = 'CTS-Lead';
    public static final String RES_REQ_TYPE_STRATEGIC_PRICING_LEAD = 'Strategic Pricing Lead';
    public static final String RES_REQ_TYPE_BIOSIMILAR_COE_BID_Defence ='Biosimilar-COE BID Defence';
    public static final String RES_REQ_TYPE_SSL = 'SSL';
    public static final String RES_REQ_TYPE_GBO_STRATEGIC_WRITER = 'GBO-Strategic Writer';
    public static final String RES_REQ_TYPE_CMSVC = 'CMSVC';
    public static final String RES_REQ_TYPE_CMSVC_BID_Defence ='CMSVC BID Defence';
    public static final String RES_REQ_TYPE_DSB_DCT = 'DSB-DCT';
    public static final String RES_REQ_TYPE_DSB_RNPS = 'DSB-RNPS';
    public static final String RES_REQ_TYPE_RW_AIM = 'RW AIM';
    public static final String RES_REQ_TYPE_DSB_LCS_POST = 'DSB-LCS Post';
    public static final String RES_REQ_TYPE_DSB_CLINICAL_POST = 'DSB-Clinical Post';
    public static final String RES_REQ_TYPE_DSB_CEVA_POST = 'DSB-CEVA Post';
    public static final String RES_REQ_TYPE_DSB_DCT_POST = 'DSB-DCT Post';
    public static final String RES_REQ_TYPE_DSB_DM_POST = 'DSB-DM Post';
    public static final String RES_REQ_TYPE_DSB_ISS_POST = 'DSB-ISS Post';
    public static final String RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST = 'GBO-Lead Contracts Analyst';
    public static final String RES_REQ_TYPE_GBO_SUPPORT_CA = 'GBO-Support CA';
    public static final String RES_REQ_TYPE_DSB_RNPS_POST = 'DSB-RNPS Post';
    public static final String RES_REQ_TYPE_DSB_MW_POST = 'DSB-MW Post';
    public static final String RES_REQ_TYPE_DSB_PM_POST = 'DSB-PM Post';
    public static final String RES_REQ_TYPE_DSB_GSA_POST = 'DSB-GSA Post';
    public static final String RES_REQ_TYPE_DSB_RADDS_POST = 'DSB-RADDS Post';
    public static final String RES_REQ_TYPE_DSB_BIOS_POST = 'DSB-Bios Post';
    public static final String RES_REQ_TYPE_CAGT_COE_BID_Defence ='CAGT-COE BID Defence';
    public static final String RES_REQ_TYPE_DSB_RADDS = 'DSB-RADDS';
    public static final String RES_REQ_TYPE_RADDS_PRODUCT_SPECIALIST = 'RADDS Product Specialist';
    public static final String RES_REQ_TYPE_MBR_LEAD = 'MBR - Lead';
    public static final String REQ_SER_MEDICAL_AND_SCIENTIFIC = 'Medical & Scientific';
    public static final String REQ_SER_SAFETY_TECH = 'Safety Tech';
    public static final String RES_REQ_TYPE_IQVIA_TECH ='IQVIA Tech';
    public static final String RES_REQ_TYPE_MEDTECH_STRATEGY_LEAD = 'MedTech Strategy Lead';
    public static final String RES_REQ_TYPE_DSB_PK_PD = 'DSB-PK/PD';
    public static final String RES_REQ_TYPE_DSB_PK_PD_POST = 'DSB-PK/PD Post';
    public static final String RES_REQ_TYPE_DSB_SPN = 'DSB-SPN';
    public static final String RES_REQ_TYPE_DSB_CTE = 'DSB-CTE';
    public static final String RES_REQ_TYPE_DSB_DDRS = 'DSB-DDRS';
    public static final String RES_REQ_TYPE_DSB_DDRS_POST = 'DSB-DDRS Post';
    public static final String RES_REQ_TYPE_DSB_SPN_POST = 'DSB-SPN Post'; 
    public static final Set<String> RES_REQ_GBO_SET = new Set<String> {'GBO-Lead PD','GBO-RFI','GBO-Support PD','GBO-Strategic Writer'};
    public static final String RES_REQ_TYPE_CLINICAL ='Clinical';
    public static final String RES_REQ_TYPE_CLINICAL_BALLPARK ='Clinical - Ballpark';
    public static final String RES_REQ_TYPE_CONNECTED_DEVICES_PD ='Connected Devices PD';
    public static final String AGREEMENT_PATHWAY_OSA = 'Other Special Agreement';
    public static final String AGREEMENT_PATHWAY_LATEPHASE = 'Late Phase';
    public static final String AGREEMENT_PATHWAY_CLINICAL = 'Clinical';
    public static final String SKILL_TYPE_LINE_OF_BUSINESS = 'Line of Business';
    public static final String SKILL_TYPE_OPPORTUNITY_TYPE = 'Opportunity Type';
    public static final String SKILL_TYPE_INDICATION = 'Indication';
    public static final String SKILL_TYPE_THERAPY_AREA = 'Therapy Area';
    public static final String SKILL_TYPE_POTENTIAL_REGION = 'User Regional Geographic Working Scope';
    public static final String SKILL_TYPE_GRADE_LEVEL = 'Grade Level';
    public static final String SKILL_TYPE_GLOBAL_PROJECT_UNIT = 'Global Project Unit';
    public static final String SKILL_TYPE_TRIAGE_LEVEL = 'Triage Level';
    public static final String SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY = 'Global Analytics Country'; 
    public static final String SKILL_TYPE_OPPORTUNITY_LEVEL = 'Opportunity Level';
    public static final String SKILL_NAME_STRATEGIC_ANALYTICS = 'Strategic Analytics';
    public static final String PSE_SALESFORCE_USER = 'pse__Salesforce_User__c';
    public static final String RFI_RR = 'RFI';
    public static final String LINE_OF_BUSINESS_CLINICAL = 'Clinical';
    public static final String LINE_OF_BUSINESS_OUTCOME = 'Outcome';
    public static final String LINE_OF_BUSINESS_DATA_SCIENCES = 'Data Sciences';
    public static final String LINE_OF_BUSINESS_HEALTH_ENGAGEMENT_COMMUNICATION = 'Health Engagement & Communication';
    public static final String LINE_OF_BUSINESS_SAFETY_AND_MED_INFO = 'Safety & Med Info';
    public static final String LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT = 'Early Clinical Development';
    public static final String LINE_OF_BUSINESS_PATIENT_AND_DCT_SOLUTIONS = 'Patient & DCT Solutions';
    public static final String LINE_OF_BUSINESS_RDDS = 'Regulatory & Drug Development Solutions';
    public static final String LINE_OF_BUSINESS_CLINICAL_TECHNOLOGY = 'Clinical Technology';
    public static final String LINE_OF_BUSINESS_OTHER = 'Other';
    public static final String LINE_OF_BUSINESS_CONSULTING = 'Consulting';
    public static final String LINE_OF_BUSINESS_MEDICAL_AFFAIRS = 'Medical Affairs';
    public static final String LEAD_BUSINESS_GROUP_INTEGRATED_HEALTH_SERVICES = 'Integrated Health Services';
    public static final String OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING = 'Clinical Monitoring';
    public static final String REQUESTED_INTERNAL_SERVICES_ECD_CLINICAL_MONITORING = 'ECD - Clinical Monitoring';
    public static final String REQUESTED_INTERNAL_SERVICES_ECD_CLINICAL_PROJECT_MANAGER = 'ECD - Clinical Project Manager';
    public static final String REQUESTED_INTERNAL_SERVICES_INVESTIGATOR_GRANT_ESTIMATES = 'Investigator Grant Estimates';
    public static final String REQUESTED_INTERNAL_SERVICES_IQB_ISSC = 'IQB Integrated Site Services (Start-up)';
    public static final String REQUESTED_INTERNAL_SERVICES_IQB_MEDICAL_MONITORING = 'IQB Medical Monitoring';
    public static final String REQUESTED_INTERNAL_SERVICES_IQB_PROJECT_MANAGEMENT = 'IQB Project Management';
    public static final String REQUESTED_INTERNAL_SERVICES_IQB_SITE_CONTRACTS = 'IQB Site Contracts';
    public static final String REQUESTED_INTERNAL_SERVICES_IQB_SITE_PAYMENTS = 'IQB Site Payments';
    public static final String REQUESTED_INTERNAL_SERVICES_GSA_REGULATORY = 'GSA Regulatory';
    public static final String REQUESTED_INTERNAL_SERVICES_GSA_SITE_ID_START_UP = 'GSA Site ID/Start-up';
    public static final String REQUESTED_INTERNAL_SERVICES_PROJECT_MANAGEMENT = 'Project Management';
    public static final String REQUESTED_INTERNAL_SERVICES_FULL_SERVICE_FEASIBILITY = 'Full-Service Feasibility';
    public static final String REQUESTED_INTERNAL_SERVICES_ADSC_STANDALONE_FEASIBILITY_OUTREACH_SITE_INSITES = 'ADSC Standalone: Feasibility, Outreach, Site Insights';
    public static final String REQUESTED_INTERNAL_SERVICES_ADSC_AIML_SOLUTIONS = 'ADSC AIML Solutions';
    public static final String REQUESTED_INTERNAL_SERVICES_ADSC_CONSULTING = 'ADSC Consulting';
    public static final String REQUESTED_INTERNAL_SERVICES_LP_PROJECT_MANAGEMENT = 'LP Project Management';
    public static final String REQUESTED_INTERNAL_SERVICES_KIT_SUPPLY_ONLY = 'Kit Supply only';
    public static final String REQUESTED_INTERNAL_SERVICES_SPEC_MANAGEMENT_BASIC = 'Spec Management Basic';
    public static final String REQUESTED_INTERNAL_SERVICES_STANDARD_SAFETY_TESTING = 'Standard Safety Testing';
    public static final String REQUESTED_INTERNAL_SERVICES_ANATOMIC_PATHOLOGY_ANALYTICAL = 'Anatomic Pathology Analytical';    
    public static final String REQUESTED_INTERNAL_SERVICES_ANATOMIC_PATHOLOGY_PROCESSING = 'Anatomic Pathology Processing';
    public static final String REQUESTED_INTERNAL_SERVICES_COMPANION_DIAGNOSTICS = 'Companion Diagnostics';
    public static final String REQUESTED_INTERNAL_SERVICES_COMPLEX_3RD_PARTY_LOGISTICS = 'Complex 3rd Party Logistics';
    public static final String REQUESTED_INTERNAL_SERVICES_COMPLEX_SAMPLE_STORAGE = 'Complex Sample Storage (volume/duration)';
    public static final String REQUESTED_INTERNAL_SERVICES_GENOMICS_EA = 'Genomics (EA)';
    public static final String REQUESTED_INTERNAL_SERVICES_LOCAL_LAB_DATA_ENTRY = 'Local Lab Data Entry';
    public static final String REQUESTED_INTERNAL_SERVICES_POTENTIAL_VALIDATION_TRANSLATIONAL = 'Potential Validation/Translational Scien';
    public static final String REQUESTED_INTERNAL_SERVICES_NON_STANDARD_TESTING = 'Non Standard Testing';
    public static final String REQUESTED_INTERNAL_SERVICES_PATIENT_RECRUITMENT = 'Patient Recruitment';
    public static final String REQUESTED_INTERNAL_SERVICES_PHARMACOVIGILANCE_LIFECYCLE_SAFETY = 'Pharmacovigilance LifeCycle Safety';
    public static final String REQUESTED_INTERNAL_SERVICES_IQB_SAFETY_PROCESSING = 'IQB Safety Processing';
    public static final String REQUESTED_INTERNAL_SERVICES_IQB_SAFETY_REPORTING = 'IQB Safety Reporting';
    public static final String REQUESTED_INTERNAL_SERVICES_CEVA = 'CEVA';
    public static final String REQUESTED_INTERNAL_SERVICES_PPS ='Pharmacokinetics/Pharmacodynamics Stats';
    public static final String REQUESTED_INTERNAL_SERVICES_PK_SUPPORT_FOR_IND ='PK Support for IND';
    public static final String REQUESTED_INTERNAL_SERVICES_POPULATION_PK_PD ='Population PK/PD';
    public static final String REQUESTED_INTERNAL_SERVICES_PK_SUPPORT_FOR_NDA_ECTD ='PK support for NDA/eCTD';
    public static final String REQUESTED_INTERNAL_SERVICES_BIOSTATISTICAL = 'Biostatistical';
    public static final String REQUESTED_INTERNAL_SERVICES_DATA_MANAGEMENT = 'Data Management';
    public static final String REQUESTED_INTERNAL_SERVICES_IQB_MEDICAL_WRITING = 'IQB Medical Writing';
    public static final String REQUESTED_INTERNAL_SERVICES_MEDICAL_WRITING = 'Medical Writing';
    public static final String REQUESTED_INTERNAL_SERVICES_RNPS = 'RNPS';
    public static final String REQUESTED_INTERNAL_SERVICES_IQB_BIOSTATS = 'IQB Biostats';
    public static final String REQUESTED_INTERNAL_SERVICES_RADDS_DDPRR = 'RADDS Drug Dev/Pre Registration/Registration';
    public static final String REQUESTED_INTERNAL_SERVICES_RADDS_LCM_REGULATORY_OPERATION = 'RADDS LCM/Regulatory Operation';
    public static final String REQUESTED_INTERNAL_SERVICES_MEDTECH_SOULTIONS = 'MedTech Solutions';
    public static final String REQUESTED_INTERNAL_SERVICES_ADSC_DESIGN_ANALYTICS_SELECT_ANALYTICS_FOR_PRE_AWARD = 'ADSC Design Analytics: Select Analytics for Pre-Award';
    public static final String REQUESTED_INTERNAL_SERVICES_ADSC_DESIGN_ANALYTICS_DIPA_EDSD_ETC = 'ADSC Design Analytics: DIPA, EDSD, etc.';
    public static final String GPU_MEDTECH_CLINICAL_SOULTIONS = 'IQVIA Biotech Medtech Clinical Solutions';
    
    public static final String REQUESTED_AGREEMENT_TYPE_ATP = 'ATP';
    public static final String REQUESTED_AGREEMENT_TYPE_SUWO = 'SUWO';
    public static final String REQUESTED_AGREEMENT_TYPE_LOI = 'Letter of Intent';
    public static final String REQUESTED_AGREEMENT_TYPE_WORK_ORDER = 'Work Order';
    public static final String REQUESTED_AGREEMENT_TYPE_GENRERAL_CONSULTING_AGREEMENT = 'General Consulting Agreement';
    public static final String REQUESTED_AGREEMENT_TYPE_GENRERAL_SERVICE_AGREEMENT_SMALL_PROJECT = 'General Services Agreement - Small Projects';
    public static final String REQUESTED_AGREEMENT_TYPE_GENRERAL_SERVICE_AGREEMENT = 'General Services Agreement';
    public static final String REQUESTED_AGREEMENT_TYPE_OTHER_AGREEMENT = 'Other Agreements';
    public static final String REQUESTED_AGREEMENT_TYPE_NEW_CHANGE_ORDER = 'New Change Order';
    public static final String REQUESTED_AGREEMENT_TYPE_CNF = 'CNF';
    public static final String REQUESTED_AGREEMENT_TYPE_CHANGE_ORDER_BALLPARK = 'Change Order Ballpark';
    public static final String REQUESTED_AGREEMENT_TYPE_LRA = 'LRA';
    public static final String REQUESTED_AGREEMENT_TYPE_PRELIMINARY_AGREEMENT_AMENDMENT = 'Preliminary Agreement Amendment';
    public static final String REQUESTED_AGREEMENT_TYPE_LOCAL_REPRESENTATIVE_AGREEMENT = 'Local Representative Agreement';
    public static final String REQUESTED_AGREEMENT_TYPE_LEGAL_REPRESENTATIVE_AGREEMENT = 'Legal Representative Agreement';
    public static final String REQUESTED_AGREEMENT_TYPE_LRA_AMENDMENT = 'LRA Amendment';
    public static final String REQUESTED_AGREEMENT_TYPE_MISCELLANEOUS_AGREEMENT = 'Miscellaneous Agreement';
    public static final String POTENTIAL_REGION_JAPAN = 'Japan';
    public static final String POTENTIAL_REGION_ASIA_PACIFIC = 'Asia Pacific';
    public static final String POTENTIAL_REGION_INDIA_ONLY = 'India Only';
    public static final String POTENTIAL_REGION_GLOBAL = 'Global';
    public static final String POTENTIAL_REGION_USA_CANADA = 'USA/Canada';
    public static final String POTENTIAL_REGION_EMEA = 'Europe/Middle East/Africa EMEA';
    public static final String OPPORTUNITY_TYPE_FULL_SERVICE_RFP = 'Full service RFP';
    public static final String OPPORTUNITY_TYPE_PROGRAM_OR_STRATEGIC_PARTERNERSHIP = 'Program or Strategic Partnership';
    public static Final String OPPORTUNITY_TYPE_FSP_SKILL = 'FSP_Skill';
    public static Final String OPPORTUNITY_TYPE_PRICE_PER_PT = 'Price per Pt';
    public static Final String OPPORTUNITY_TYPE_BTS_BALLPARK = 'BTS Ballpark';
    public static final String ESTIMATED_FEES_GREATER_THAN_50_M = 'Greater than $50M';
    public static final String ESTIMATED_FEES_GREATER_THAN_10_M = 'Greater than $10M';
    public static final String RA_COUNTRY_TYPE_STRATEGIC_ANALYTICS = 'Strategic Analytics';
    public static final String RECORD_TYPE_CSS = 'CSS';
    public static final String RECORD_TYPE_GCC = 'GCC';
    public static final String RECORD_TYPE_Q2_SOLUTION = 'Q² Solutions';
    public static final String RECORD_TYPE_CSS_BID = 'CSS Bid';
    public static final String Q2_BUSINESS_AREA = 'Central Labs';
    public static final String BID_TYPE_INITIAL = 'Initial';
    public static final String BID_TYPE_RE_BID = 'Re-Bid';
    public static final String Q2_BUSINESS_AREA_BIOSCIENCE = 'BioSciences';
    public static final String Q2_BUSINESS_AREA_VACCINES = 'Vaccines';
    public static final String Q2_BUSINESS_AREA_DISCOVERY = 'Discovery';
    public static final String BUDGET_TOOL_IMMUN_XPERTS = 'ImmunXperts';
    public static final String BUDGET_TOOL_SPECIFICA = 'Specifica';
    public static final String BUDGET_TOOL_PROTEIN_SCIENCES = 'Protein Sciences';
    //BELOW CONSTANT IS BEING USED TO IMPLEMENT THE LOGICS/FUNCTIONALITIES for Q2 related business areas. Before adding a values in this 
    //Please check all the refrences in the code.  
    public static final Set<String> Q2_BUSINESS_AREA_LIST = new Set<String>{Q2_BUSINESS_AREA_BIOSCIENCE, Q2_BUSINESS_AREA_VACCINES, Q2_BUSINESS_AREA_DISCOVERY};
    public static final Set<String> DISCOVERY_BUDGET_TOOLS_LIST = new Set<String>{BUDGET_TOOL_IMMUN_XPERTS,BUDGET_TOOL_SPECIFICA,BUDGET_TOOL_PROTEIN_SCIENCES};
    public static String Q2_BUSINESS_AREA_LIST_SOQL {
        get{
            return '(\'' + String.join(new List<String>(Q2_BUSINESS_AREA_LIST), '\',\'') + '\')';
        }
    }
    public static final String Q2_BUSINESS_AREA_CHANGE_ORDER = 'Change Order';
    public static final String SCIENTIFIC_REVIEW_YES_POST_AWARD_REBID_WITH_SR= 'Yes-Post Award Rebid with SR';
    public static final String SCIENTIFIC_REVIEW_CLS = 'China Local Solution';    
    public static final String STRATEGIC_PROPOSAL_WRITER_TEXT = 'Strategic Proposal Writer Text';
    public static final String REQUESTED_INTERNAL_SERVICES_BIOFORTIS = 'BioFortis';
    public static final String SUBMIT_TO_PROPOSALS_TRUE = 'True';
    public static final String Q2_Budget_TOOLS_PRISM = 'PRISM';
    public static final String LINE_OF_BUSINESS_RWLP = 'RWLP';
    public static final String BUDGET_DELIVERABLE_BALLPARK = 'Ballpark';
    public static final String BUDGET_DELIVERABLE_BUDGET = 'Budget';
    public static final String BUDGET_DELIVERABLE_BUDGET_BID_GRID = 'Budget + Bid Grid'; 
    public static final String ESTIMATED_FEE_LESS_THAN_5M = 'Less than $5M';
    public static final String ESTIMATED_FEE_GREATER_THAN_5M = 'Greater than $5M';
    public static final String ASSIGN_PROPOSAL_RANKING_LEVEL_1 = 'Level - 1';
    public static final String ASSIGN_PROPOSAL_RANKING_LEVEL_2 = 'Level - 2';
    public static final String ASSIGN_PROPOSAL_RANKING_LEVEL_3 = 'Level - 3';
    public static final String ASSIGN_PROPOSAL_RANKING_LEVEL_4 = 'Level - 4'; 
    public static final String VIRTUAL_TRIAL_STUDY_YES_FULLY_HYBRID = 'Yes Fully Hybrid';
    public static final String VIRTUAL_TRIAL_STUDY_YES_HYBRID = 'Yes Hybrid';
    public static final String VIRTUAL_TRIAL_STUDY_YES_FULLY_VIRTUAL = 'Yes Fully Virtual';
    public static final Set<String> DSB_POST_SUBGROUP_OF_CONTRACT_POST_AWARD_BID = new Set<String>{'DSB-LCS Post','DSB-Clinical Post',
        'DSB-CEVA Post','DSB-DCT Post','DSB-DM Post','DSB-Bios Post','DSB-MW Post','DSB-GSA Post','DSB-RNPS Post','DSB-PM Post','DSB-RADDS Post',
        'DSB-MM Post','DSB-ISS Post','DSB-PK/PD Post'};
    public static final Set<String> BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET = new Set<String>{'Work Order', 'General Consulting Agreement',
        'General Consulting Agreement - Small Projects', 'General Services Agreement - Small Projects', 'General Services Agreement', 'Other Agreements'};
    public static final String IS_STUDY_AWARDED_YES = 'Yes';
    
    /*public static final Map<Id,String> recordIdToBidCategoryMap = new Map<Id,String>
                     {Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId() => 'Clinical',
                     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId() => 'Early Engagement',
                     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Post_Award_Bid').getRecordTypeId() => 'Post Award',
                     Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('RFI_Request').getRecordTypeId() => 'RFI'}; */
    
    public static final String CREATED_DATE = 'CreatedDate';
    public static final String PRESENTATION_DATE = 'Presentation_Date';
    public static final String BID_DUE_DATE = 'Bid_Due_Date';
    public static final String REQUESTING_DATE = 'RequestingDate';
    
    public static final Map<String, Double> skillRatingValueMap = new Map<String, Double>{
                                                                                    'None' => 0,
                                                                                    '1 - Limited Exposure' => 20,
                                                                                    '2 - Some Familiarity' => 40,
                                                                                    '3 - Comfortable' => 60,
                                                                                    '4 - Strong' => 80,
                                                                                    '5 - Expert' => 100};
    
    
    
    public static final Map<String,String> triageLevelToRatingMap = new Map<String,String>{
                                        'Level E Strategic Requests for Information' => '1 - Limited Exposure',
                                        'Level D Requests for Information as part of an RFP' => '2 - Some Familiarity',
                                        'Level C Standalone Requests for Information' => '3 - Comfortable',
                                        'Level A Experience or Staffing'  => '5 - Expert',
                                        'Level B Supplier Qualification Audit' => '4 - Strong'};
    public static final String RFI_SUBGROUP = 'GBO-RFI';            
    public static final String CAGT_COE_SUBGROUP = 'CAGT-COE';   
    public static final String CSMS_LEAD_PD = 'CSMS-Lead PD';
    public static final Set<String> LP_RESOURCES_SET = new Set<String>{'LP MSL','LP Project Management','LP Epi','LP Regulatory','LP PCS CoE','LP Medical Affairs CoE','LP Safety Evidence for Regulators','LP ESL','LP MedSci','LP RSSI (Regulatory Science and Strategy Innovation)'};
    public static final Set<String> GBO_RESOURCES_SET = new Set<String>{'GBO-Lead PD','GBO-Bid Grid','GBO-RFI','GBO-Strategic Writer','GBO-Support PD','GBO-Lead Contracts Analyst'};
    
    public static final Set<String> TSSU_Subgroup = new Set<String>{'Global Analytics','TSL','Medical-MSL','TAL','Site Analytics','Feasibility Analytics','SPN Product Specialist','IQB Strategy Lead','CMSVC','DSB-DCT','RW AIM'};
    public static final Set<String> REBID_NON_CLONABLE_SUBGROUP_SET = new Set<String>{'Design Analytics', 'IQB Strategy Lead'};
    public static final Set<String> REBID_NON_CLONABLE_ANALYTICS_SET = new Set<String>{'Site Analytics','Feasibility Analytics'};
    //GRID RANKING CRITERIA FOR GBO-BID GRID
    public static final Decimal GRID_RANKING_LEVEL_1 = 0.5;
    public static final Decimal GRID_RANKING_LEVEL_2 = 0.62;
    public static final Decimal GRID_RANKING_LEVEL_3 = 0.75;
    public static final Decimal GRID_RANKING_LEVEL_4 = 0.87;
    public static final Decimal GRID_RANKING_LEVEL_5 = 1.0;
    public static final Decimal GRID_RANKING_REBID_MEDIUM = 0.5;
    public static final Decimal GRID_RANKING_REBID_HIGH = 1.0;
    
    public static final Set<String> SUBGROUPS_ELIGIBLE_FOR_CREATING_AGREEMENT_ON_CONTRACT_POST_AWARD_BID = new Set<String>{'GBO-Lead PD','GBO-Lead Contracts Analyst', 'GBO-Support CA'};
    public static final Set<String> SUBGROUPS_ELIGIBLE_FOR_CREATING_QUOTE_ON_CONTRACT_POST_AWARD_BID = new Set<String>{'GBO-Lead Contracts Analyst','GBO-Lead PD','GBO-Support PD', 'GBO-Support CA'};
    
    public static boolean  BYPASS_VALIDATION_RULE_RR = false;
	public static final String SKILL_JAPAN_REGIONAL_ANALYTICS = 'Japan Regional Analytics';
    public static final Set<String> OCT_RFx_LOB_SET = new Set<String>{'Clinical Technology'};
    public static final Set<String> GCC_LOB_SET = new Set<String>{'Clinical', 'Data Sciences', 'Regulatory & Drug Development Solutions', 
        'Safety & Med Info', 'Patient & DCT Solutions', 'Early Clinical Development', 'Connected Devices', 'DrugDev', 'Q2 Solutions',
        'Clinical Technology'};    
    public static final Set<String> CSS_LOB_SET = new Set<String>{'Regulatory & Drug Development Solutions', 'Safety & Med Info',
        'Connected Devices', 'Consulting', 'IT Services','Other', 'Clinical Technology'};    
    public static final Set<String> Q2_SOLUTION_LOB_SET = new Set<String>{'Q2 Solutions'};
	public static final String CONTACT_TYPE = 'Employee';
    public static final String BHR_CSS_REQUESTED_PRODUCT_CONNECTED_DEVICES = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('Connected_Devices__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_PRODUCT_ECOA = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('eCOA__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_PRODUCT_CENDUILT_IRT = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('IRT__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_PRODUCT_PCS = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('PCS__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_PRODUCT_COMPLETE_CONSENT = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('Complete_Consent__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_PRODUCT_GRANT_PLAN = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('Grant_Plan__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_PRODUCT_STUDY_OPTIMIZER = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('Study_Optimizer__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_PRODUCT_SITE_PORTAL = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('Site_Portal__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_PRODUCT_ETMF = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('eTMF__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_CLINICAL_TRIAL_PAYMENTS = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('Clinical_Trial_Payments__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_CDAS = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('CDAS__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_DQS = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('DQS__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_ONE_HOME_FOR_SITES = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('One_Home_for_Sites__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_RISK_BASED_MONITORIING = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('Risk_Based_Monitoring__c').getDescribe().getLabel();
    public static final String BHR_CSS_REQUESTED_PARTICIPANT_PAYMENTS = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('Participant_Payments__c').getDescribe().getLabel();
	public static final String BHR_CSS_REQUESTED_PAYMENTS_FORECASTING = Schema.Bid_History__c.SObjectType.getDescribe().fields.getMap().get('Payments_Forecasting__c').getDescribe().getLabel();
    public static final String CLINICAL_TECHNOLOGY_OPP_TYPE_CROPT ='CROPT';
    public static final String CLINICAL_TECHNOLOGY_OPP_TYPE_DIRECT ='DIRECT';
    public static final String BHR_OWF_04_BIOANALYTICALBD = 'OWF_04_BioanalyticalBD';
    public static final String BHR_OWF_Q2LAB_Bid_History_Scientific_Review = 'Q2LAB Bid History Scientific Review';
    public static final String BHR_OWF_05_STRATEGICPRICING = 'OWF_05_StrategicPricing';
    public static final String BHR_OWF_06_Q2CONTRACTREQUESTS = 'OWF_06_q2ContractRequests';
    public static final String BHR_OWF_07_Q2PROPOSALREQUEST = 'OWF_07_Q2ProposalRequest';
    public static final String BHR_OWF_07_Q2_BUDGET_TOOL = 'OWF_07_Q2_Budget_Tool';
    public static final String BHR_OWF_07_Q2STRATEGIC_PROPOSAL_WRITER_TEXT = 'OWF_07_Q2_StrategicProposalWriterText';
    public static final String BHR_OWF_12_Q2BIOFORTISALERT = 'Q2BioFortisAlert';
    public static final String BHR_OWF_13_Q2CHINALOCALSOLUTIONALERT = 'Q2ChinaLocalSolutionAlert';
    public static final String BHR_OWF_Q2SOLUTIONSLEVEL4RANKINGEMAIL1 = 'Q2_Solutions_Level_4_Ranking_Emails_1';
    public static final String BHR_OWF_Q2SOLUTIONSLEVEL4RANKINGEMAIL2 = 'Q2_Solutions_Level_4_Ranking_Emails_2';
    public static final String BHR_OWF_Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX  = 'Q2_Solutions_BioSciences_RFP_Mailbox';
    public static final String BHR_OWF_Q2SOLUTIONS_DISCOVERY_SPECIFICA_RFP_MAILBOX  = 'Q2_Discovery_Specifica_RFP_Mail';
    public static final String BHR_OWF_Q2SOLUTIONS_DISCOVERY_PROTEIN_SCIENCES_RFP_MAILBOX  = 'Q2_Discovery_Protein_Sciences_RFP_Mail';
    public static final String BHR_OWF_Q2SOLUTIONS_DISCOVERY_IMMUN_XPERTS_RFP_MAILBOX = 'Q2_Discovery_IMMUN_XPERTS_RFP_Mail';
    public static final String BHR_OWF_Q2SOLUTIONS_VACCINES_RFP_MAILBOX  = 'Q2_Solutions_Vaccines_RFP_Mailbox';
    public static final String BHR_OWF_AwardBidWithStatusReadyToAward = 'OWF_AwardBidWithStatusReadyToAward';
	public static final String BHR_OWF_NotificationToGCCBidHistoryOnFieldUpdate  = 'Notification_To_GCCOnBHRFieldUpdate';
    public static final String BHR_OWF_NotificationToGCCOnCollectionToolFieldUpdate  = 'Notification_To_GCCOnCTFieldUpdate';
    public static final String BHR_OWF_NotificationToTechSolutionOnCreate= 'Notification_To_TechSolutionOnCreate';
    public static final String BHR_OWF_NotificationFromRFIToIQVIATeam= 'Notification_from_RFI_To_IQVIA_Team';
    public static final String BHR_OWF_NotificationFromRFIIQVIALABSSPWSupport= 'Notification_from_RFI_IQVIA_LABS';
    public static final String BHR_OWF_NotificationToTechSolutionOnCreateWithSafetyTechnologies= 'Notification_To_TechSolutionOnCreateST';
    public static final String BHR_OWF_22_NotificationToTechSolutionOnCreate= 'OWF_22_NotificationOnTechSolutionRecordOnCreate';
    public static final String BHR_OWF_24_NotificationFromRFIToIQVIATeam= 'OWF_24_NotificationFromRFIToIQVIATeam';
    public static final String BHR_OWF_26_NotificationRFIIQVIALABSSPWSupport= 'OWF_26_NotificationRFIIQVIALABSSPWSupport';
    public static final String BHR_OWF_AWARDED_YES = 'Yes';
    public static final String BHR_OWF_RELATED_QUOTE_STATUS_NO_QUOTE_CREATED = 'No Quote Created';
    public static final String BHR_OWF_RELATED_QUOTE_STATUS_NO_QUOTE_REQUIRED = 'No Quote Required';
    public static final String BHR_OWF_RELATED_QUOTE_STATUS_NOT_READY_TO_AWARD = 'Not Ready to Award';
    public static final String BHR_OWF_RELATED_QUOTE_STATUS_READY_TO_AWARD = 'Ready to Award';
    public static final String BHR_OWF_BUDGET_TOOLS_UNIT_PRICING_TOOL = 'Unit Pricing Tool';
    public static final String BHR_OWF_BUDGET_TOOLS_LCS_UPT = 'LCS UPT';
    public static final String OPP_LINE_OF_BUSINESS_CONNECTED_DEVICES = 'Connected Devices';
    public static final String OPPORTUNITY_TYPE = 'BTS Ballpark';
    public static final String BUDGET_DELIVERABLE = 'Rounded Ballpark';
    public static final Set<String> FUNCTION_SET_FOR_TSL_RR = new Set<String>{'COE Lead / Category Lead / SME'};
    public static final Set<String> TSL_RR_SET = new Set<String>{'TSL'};
    public static final Map<String,List<String>> regionMap =new Map<String,List<String>>{
        'United States of America' => new List<String>{'USA/Canada;Latin America','Europe/Middle East/Africa EMEA'},
        'Australia & NZ' => new List<String>{'Asia Pacific',null}, 
        'Western Europe' => new List<String>{'Europe/Middle East/Africa EMEA','USA/Canada;Latin America'}, 
        'India Region' => new List<String>{'Asia Pacific',null}, 
        'Southeast Asia' => new List<String>{'Asia Pacific',null}, 
        'Eastern Europe/Middle East' => new List<String>{'Europe/Middle East/Africa EMEA','USA/Canada;Latin America'}, 
        'Africa' => new List<String>{'Europe/Middle East/Africa EMEA','USA/Canada;Latin America'}, 
        'China Region' => new List<String>{'Asia Pacific',null}, 
        'Canada' => new List<String>{'USA/Canada;Latin America','Europe/Middle East/Africa EMEA'}, 
        'South America' => new List<String>{'USA/Canada;Latin America','Europe/Middle East/Africa EMEA'}, 
        'Central America' => new List<String>{'USA/Canada;Latin America','Europe/Middle East/Africa EMEA'}
        };
     public static final Map<Boolean, Double> AlignedWithAccount = new Map<Boolean, Double>{
                                                                                    True => 4,
                                                                                    False => 2
                                                                                    };      
     public static final Map<String, Integer> oppTypeToTATMap = new Map<String, Integer>{
                                                                                    'Price per Pt' => 2,
                                                                                    'BTS Ballpark' => 5,
                                                                                    'Ballpark requiring IQVIA-defined C/S/P strategy' => 7,
                                                                                    'Limited service RFP (non-Clinical, non-FSP)' => 7,
                                                                                    'Full service RFP' => 10,
                                                                                    'Program or Strategic Partnership' => 14,
                                                                                    'FSP_Skill' => 10};
                                                                                        
    public static final Integer daysForClientBidGrid = 2;
    public static final Integer daysForDCT = 10;
	
    public static final String OWF_YES= 'Yes';
    public static final String BID_SENT= 'Yes';
    public static final String OWF_NO= 'No';
    public static final String OWF_NOT_SURE= 'Not Sure';
    public static final String OWF_MODULE_NAME= 'OWF';
    public static final String CSS_BID_REQUESTED_PRODUCTS_EMAIL_ACTION= 'OWF_01_SendEmailForCSSBidBasedOnProductsSelected';
    public static final String Q2LAB_BID_HISTORY_SCIENTIFIC_REVIEW_EMAIL_ACTION = 'OWF_02_Q2LAB_Bid_History_Scientific_Review';
    public static final String Q2LAB_STRATEGIC_PRICING_LEAD_ASSIGNED_EMAIL_ACTION = 'OWF_03_Q2lab_Strategic_pricing_lead_assigned';
	public static final String Q2_SOLUTIONS_BIDHISTORY_ADVION_QUOTE_REQUESTED_EMAIL_ACTION = 'OWF_04_SendEmailForQ2SolutionsBidHistoryAdvionQuoterequested';
	public static final String Q2_SOLUTIONS_STRATEGIC_PRICING_INVOLVED_EMAIL_ACTION = 'OWF_05_SendEmailForQ2SolutionsStrategicPricingInvolved';
	public static final String Q2_SUBMIT_TO_CONTRACTS_EMAIL_ACTION = 'OWF_06_SendEmailForQ2SubmitToContracts';
	public static final String Q2_SOLUTIONS_BIDHISTORY_TRIAGE_NOTIFICATION_EXCLUDING_MERCK_KGAA_EMAIL_ACTION = 'OWF_07_SendEmailForQ2SolutionsBidHistoryTriageNotificationExcludingMerckKGaA';
    public static final String Q2_SOLUTIONS_LEVEL_1_RANKING_ALERT_EMAIL_ACTION = 'OWF_08_SendEmailForQ2SolutionsLevel1RankingAlert';
    public static final String Q2_SOLUTIONS_LEVEL_2_RANKING_ALERT_EMAIL_ACTION = 'OWF_09_SendEmailForQ2SolutionsLevel2RankingAlert';
    public static final String Q2_SOLUTIONS_LEVEL_3_RANKING_ALERT_EMAIL_ACTION = 'OWF_10_SendEmailForQ2SolutionsLevel3RankingAlert';
    public static final String Q2_SOLUTIONS_LEVEL_4_RANKING_ALERT_EMAIL_ACTION = 'OWF_11_SendEmailForQ2SolutionsLevel4RankingAlert';
    public static final String Q2_SOLUTIONS_STRATEGIC_PRICING_LEAD_ALERT_EMAIL_ACTION = 'OWF_12_SendEmailForStrategicPricingLeadAlert';
    public static final String Q2_SOLUTIONS_BIO_FORTIS_ALERT_EMAIL_ACTION = 'OWF_13_SendEmailForQ2BioFortisEmailAction';
    public static final String Q2_SOLUTIONS_CHINA_LOCAL_SOLUTIONS_ALERT_EMAIL_ACTION = 'OWF_14_SendEmailForQ2ChinaLocalSolutionEmailAction';
    public static final String Q2_SOLUTIONS_BID_OWNER_CHANGE_ALERT_EMAIL_ACTION = 'OWF_15_SendEmailForQ2BidOwnerChangeAction';
    public static final String BUDGET_TOOLS_ALERT_EMAIL_ACTION = 'OWF_16_SendEmailForBudgetToolsEmailAction';
    public static final String BUDGET_TOOLS_BIDHISTORY_ALERT_EMAIL_ACTION = 'OWF_17_AwardBidWithStatusReadyToAward';
    public static final String OWF_NotificationToGCCForFieldUpdate = 'OWF_20_NotificationToGCC';
    public static final String OWF_NotificationOnCountriesOfScopeFieldUpdate = 'OWF_21_NotificationOnCountriesOfScopeFieldUpdate';
    public static final String OWF_NotificationToTechSolutionOnCreateWithSafetyTechnologies = 'OWF_23_NotificationOnTechSolutionRecordOnCreateWithSafetyTechnologies';
    public static final String CONTRACT_POST_AWARD_BID_PATHWAY_EMAIL_ACTION = 'OWF_18_SendEmailForContractPostAwardBidPathway';
    public static final String CONTRACT_POST_AWARD_BID_CREATION_EMAIL_ACTION = 'OWF_19_SendEmailForContractPostAwardBidCreationBasedOnPathway';
    public static final String Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION = 'Q2BioScienceRFPMailboxEmailAlert';
    public static final Set<String> RR_TYPE_FOR_LEAD_SUPPORT_FLAG = new Set<String>{'Clinical - Ballpark','Clinical','Re-Clinical','Bid Defense','Post Award'};
    public static Final String SUPPORT_FLAG = 'Support';
    public static Final String FSP = 'FSP';
    public static Final String IQVIA_BIOTECH_SKILL = 'IQVIA Biotech';
    public static Final String CORE_SKILL = 'Core';
    
    public static final Map<String, String> rankingValueMap = new Map<String, String>{
        'Change Does Not Impact Budget (ie: text changes only, Local/Legal Rep Agreement) or a Consultancy Agreement' => '1.1',
        'Change Impacts 1 Service Only / No Third Party Vendors(TPV)' => '2.1',
        'Change Impacts 2-3 Services / Several CNF\'S or CO Log/ < 2 TPV' => '3.1',
        'Change Impacts > 4 Services / >= 3 TPV' => '4.1',
        'Award Has Service Fees > USD $50M / Program With Multiple Studies / Study Has Multiple QIP Budgets' => '5.1'};
        
    public static final Map<String, String> contractRankingValueMap = new Map<String, String>{
            'Single service/Fees <$1M/No TPV' => '1.1',
            'Full service/Fees $1M-$4M/<2 TPVs' => '2.1',
            'New customer (no MSA)/Fees $4M-$50M/≥3 TPVs' => '4.1',
            'RFP 5/>$50M/>1 study program/>1 QIP budget' => '5.1',
            'Single service' => '1.1',
            'Multi service' => '2.1',
            'Full Service/Pull through' => '4.1',
            'New Customer (no MSA)' => '4.1'};

    public static final Map<String,Integer> requestedAgreementMapToBidDueDateMap = new Map<String,Integer>{
            CON_OWF.REQUESTED_AGREEMENT_TYPE_ATP => 30,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_SUWO => 30,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_LOI => 30,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_WORK_ORDER => 45,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_GENRERAL_CONSULTING_AGREEMENT => 45,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_GENRERAL_SERVICE_AGREEMENT_SMALL_PROJECT => 45,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_GENRERAL_SERVICE_AGREEMENT => 45,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_OTHER_AGREEMENT => 45,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_NEW_CHANGE_ORDER => 75,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_CNF => 36,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_CHANGE_ORDER_BALLPARK => 33,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_PRELIMINARY_AGREEMENT_AMENDMENT => 60,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_LOCAL_REPRESENTATIVE_AGREEMENT => 45,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_LEGAL_REPRESENTATIVE_AGREEMENT => 45,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_MISCELLANEOUS_AGREEMENT => 45,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_LRA => 60,
            CON_OWF.REQUESTED_AGREEMENT_TYPE_LRA_AMENDMENT => 60};

    public static final Map<String, List<String>> GBO_BD_LEAD_REGION_TO_RESOURCE_REGION_MAP = new Map<String, List<String>>{
        'United States of America' => new List<String>{'USA/Canada;Latin America','Europe/Middle East/Africa EMEA','Asia Pacific'},
        'Australia & NZ' => new List<String>{'Asia Pacific','Europe/Middle East/Africa EMEA','USA/Canada;Latin America'}, 
        'Western Europe' => new List<String>{'Europe/Middle East/Africa EMEA','USA/Canada;Latin America','Asia Pacific'}, 
        'India Region' => new List<String>{'Asia Pacific','Europe/Middle East/Africa EMEA','USA/Canada;Latin America'}, 
        'Southeast Asia' => new List<String>{'Asia Pacific','Europe/Middle East/Africa EMEA','USA/Canada;Latin America'}, 
        'Eastern Europe/Middle East' => new List<String>{'Europe/Middle East/Africa EMEA','USA/Canada;Latin America','Asia Pacific'}, 
        'Africa' => new List<String>{'Europe/Middle East/Africa EMEA','USA/Canada;Latin America','Asia Pacific'}, 
        'China Region' => new List<String>{'Asia Pacific','Europe/Middle East/Africa EMEA','USA/Canada;Latin America'}, 
        'Canada' => new List<String>{'USA/Canada;Latin America','Europe/Middle East/Africa EMEA','Asia Pacific'}, 
        'South America' => new List<String>{'USA/Canada;Latin America','Europe/Middle East/Africa EMEA','Asia Pacific'}, 
        'Central America' => new List<String>{'USA/Canada;Latin America','Europe/Middle East/Africa EMEA','Asia Pacific'},
        'Japan' => new List<String>{'Asia Pacific','Europe/Middle East/Africa EMEA','USA/Canada;Latin America'}
        };
       public static final Set<String> GBO_LEAD_OPPORTUNITY_SET = new Set<String>{'Clinical','Early Clinical Development','Outcome','Data Sciences','Safety & Med Info'};
       public static Final Set<String> PROFILES_HAVING_BID_CREATION_ACCESS = new Set<String>{'System Administrator','System Administrator Module','System Administrator Integration','System Administrator Package Support','IQVIA Salesforce Platform Support'};
}
