/**
 * This class used for constants used in CRM project.
 * version : 1.0
 */
public class CON_CRM {
    // This is all stageName Constant
    public static final String IDENTIFYING_OPP_STAGE = '1. Identifying Opportunity';
    public static final String QUALIFYING_OPP_STAGE = '2. Qualifying Opportunity';
    public static final String DEVELOPING_PROP_STAGE = '3. Developing Proposal';
    public static final String DELIVERING_PROP_STAGE = '4. Delivering Proposal';
    public static final String FINALIZING_DEAL_STAGE = '5. Finalizing Deal';
    public static final String RECEIVED_ATP_STAGE = '6. Received ATP/LOI';
    public static final String CLOSED_WON_STAGE = '7a. Closed Won';
    public static final String CLOSED_LOST_STAGE = '7b. Closed Lost';
    public static final String IN_HAND_STAGE = 'In-Hand';
    
    // This is all offering group code  Constant
    public static final String OFFERING_GROUP_CODE_GLOBAL_RND = 'GPRDSX';
    public static final String OFFERING_SEGMENT_CODE_GLOBAL_RWS = 'GPRWSA';
    public static final String MATERIAL_LEVEL_HIERARCHY_OLI = 'Material';
    
    // This is all offering group Constant
    public static final String OFFERING_GROUP_GLOBAL_RND = 'Research & Development Solutions';
    
    // This is all Object Codes for Objects
    public static final String OPPORTUNITY_OBJECT_CODE = '006';
    public static final String CONTACT_OBJECT_CODE = '003';
    public static final String LEAD_OBJECT_CODE = '00Q';
    
    // This is all for query any object
    public static final String ROUND_BRACKET_OPEN = ' ( ';
    public static final String ROUND_BRACKET_CLOSE = ' ) ';
    public static final String ACTIVE_TRUE = 'isActive = true ';
    public static final String OR_LOGIC = ' OR ';
    public static final String AND_LOGIC = ' AND ';
    public static final String SINGLE_SPACE = ' ';
    public static final String EQUAL_LOGIC = ' = ';
    public static final String LIKE_LOGIC = ' like ';
    public static final String PERCENT_LOGIC = '%';
    public static final String BACKSLASH = '\'';
    public static final String FORWARDSLASH = '/';
    public static final String DOT_LOGIC = '.';
    public static final String PRODUCT_OBJECT = 'Product2';
    public static final String NAME_FIELD = 'name';
    public static final String USER_FIELD = 'user__c';
    public static final String AURA_EXCEPTION = 'System.AuraHandledException';
    public static final String COLON = ':';
    public static final String IN_LOGIC = ' IN ';
    public static final String USD = 'USD';
    
    public static final String OPPORTUNITYLINEITEM_OBJECT_API = 'OpportunityLineItem';
    public static final String OPPORTUNITYLINEITEMSCHEDULE_OBJECT_API = 'OpportunityLineItemSchedule';
    public static final String FAVORITEPRODUCT_OBJECT_API = 'Favorite_Product__c';
    public static final String EDIT_LABEL = 'edit';
    public static final String CREATE_LABEL = 'create';
    public static final String DELETE_LABEL = 'Delete';
    public static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';
    public static final String SYS_ADMIN = 'System Admin';
    public static final String MARKETING_INTEGRATION_USER_PROFILE = 'Marketing Integration User';
    public static final String COMMERCIAL_OPERATION_PROFILE = 'Commercial Operations User';
    public static final String MULESOFT_SYS_ADMIN_PROFILE = 'Mulesoft System Administrator';
    public static final String IQVIA_SF_PLATFORM_PROFILE = 'IQVIA Salesforce Platform Support';
    public static final String SYS_ADMIN_INTEGRATION_PROFILE = 'System Administrator Integration';
    public static final String SYS_ADMIN_MODULE_PROFILE = 'System Administrator Module';
    public static final String SYS_ADMIN_PKG_SUPPORT_PROFILE = 'System Administrator Package Support';
    public static final String TEST_PRODUCT_NAME = 'TestProduct';
    public static final String CAMPAIGN_STATUS_PLANNED = 'Planned';
    public static final Integer RECORD_LIMIT = 50;
    public static final String OPPORTUNITY_OBJECT = 'Opportunity';
    public static final String CONTACT_OBJECT = 'Contact';
    public static final String ACCOUNT_OBJECT = 'Account';
    public static final String SPLIT_TYPE_NAME = 'Overlay';
    public static final String OPPORTUNTIY_SPLITS = 'OpportunitySplits';
    public static final String OPPORTUNITY_TEAM_MEMBERS = 'OpportunityTeamMembers';
    public static final String OPPORTUNITY_LINE_ITEMS = 'OpportunityLineItems';
    public static final String ACCOUNT_TEAMMEMBER = 'AccountTeamMembers';
    public static final String ACCOUNT_TEAMROLE = 'Biotech Ad';
    public static final String OPPORTUNITY_BNF_RELATIONSHIP = 'Purchase_BNF_s1__r';
    public static final String OPPORTUNITYLINEITEMGROUP_RELATIONSHIP= 'Line_Item_Groups__r';
    public static final String OPPORTUNITY_MIBNF_RELATIONSHIP = 'MIBNFS__r';
    public static final String OPPORTUNITY_MIBNF_COMPONENT_RELATIONSHIP= 'BNF_s__r';
    public static final String ADDRESS_SAPCONTACT_RELATIONSHIP= 'SAP_Contacts__r';
    public static final String OPPORTUNITY_TERRITORY_FIELD_API = 'Territory__c';
    public static final String PIC_ROLE = 'Principal in Charge';
    public static final String PRODUCT_MATERIAL_TYPE_ZREP = 'ZREP';
    public static final String PRODUCT_MATERIAL_TYPE_ZQUI = 'ZQUI';
    public static final String PRODUCT_MATERIAL_TYPE_ZPUB = 'ZPUB';
    public static final String OLI_THERAPY_AREA_NONE_0 = 'None [0]';
    public static final String OLI_SALETYPE_REPEAT = 'Repeat';
    public static final String PRODUCT_OFFERING_GROUP_CODE = 'GPRDSX';
    public static final String LIG_ACTUAL_PROBABILITY = '<10';
    
    public static final String UNIT_NAME_FIELD = 'unit_name__c';
    public static final String PRODUCTCODE_FIELD = 'ProductCode';
    public static final String PRODUCTGROUP = 'ProductGroup__c';
    public static final String HIERARCHY_GLOBAL_CODE_DES = 'Hierarchy_Global_Code_Description__c';
    public static final String GLOBAL_PRODUCT_CODE_FIELD = 'Global_Product_Code__c';
    public static final String INTERFACEDWITHMDM_TRUE = 'InterfacedWithMDM__c = true ';
    public static final String GLOBAL_REGION = 'Global';
    
    // Account Approval Status
    public static final String WORKITEM_PROCESSINSTANCE_TARGETOBJECTID_FIELD_API = 'ProcessInstance.TargetObjectId';
    public static final String MDM_VALIDATION_STATUS_APPROVE = 'Approve';
    public static final String MDM_VALIDATION_COMMENT_APPROVE = 'MDM validation completed';
    public static final String MDM_VALIDATION_STATUS_REJECT = 'Reject';
    public static final String MDM_VALIDATION_COMMENT_REJECT = 'MDM rejected';
    public static final String MDM_VALIDATION_STATUS_VALIDATED = 'Validated';
    public static final String MDM_UNVALIDATION_STATUS_VALIDATED = 'Unvalidated';
    public static final String MDM_VALIDATION_STATUS_REJECTED = 'Rejected';    
    public static final String OPPORTUNITYLINEITEMSCHEDULE = 'OpportunityLineItemSchedules';
    public static final String SCHEDULE_ORDERING = 'ScheduleDate, Description';
    public static final String OPPORTUNITYLINEITEMSCHEDULE_TYPE = 'Revenue';
    public static final String OPPORTUNITYLINEITEMSCHEDULE_DIVIDE_SCHEDULE = 'Divide Amount into multiple installments';
    public static final String OPPORTUNITYLINEITEMSCHEDULE_REPEAT_SCHEDULE = 'Repeat Amount for each installment';
    public static final String OPPORTUNITYLINEITEMSCHEDULE_DAILY = 'Daily';
    public static final String OPPORTUNITYLINEITEMSCHEDULE_WEEKLY = 'Weekly';
    public static final String OPPORTUNITYLINEITEMSCHEDULE_MONTHLY = 'Monthly';
    public static final String OPPORTUNITYLINEITEMSCHEDULE_QUARTERLY = 'Quarterly';
    public static final String OPPORTUNITYLINEITEMSCHEDULE_YEARLY = 'Yearly';
    public static final String OPPORTUNITYLINEITEMSCHEDULE_SEMESTERLY = 'Semesterly';
    public static final String SRV_CRM_OPPORTUNITYLINEITEMSCHEDULE_EXCEPTION = 'SRV_CRM_OpportunityLineItemSchedule.OpportunityLineItemScheduleServiceException';
    public static final String VALIDATED_ACCOUNT_RECORD_TYPE_NAME = 'MDM_Validated_Account';
    public static final String UNVALIDATED_ACCOUNT_RECORD_TYPE_NAME = 'Unvalidated_Account';
    public static final String MARKETING_TO_NURTURE = 'Marketing to Nurture';
    public static final String THREE_MONTHS = '3 months';
    public static final String SIX_MONTHS = '6 months';
    public static final String NINE_MONTHS = '9 months';
    public static final String TWELVE_MONTHS = '12 months';
    public static final String FIFTEEN_MONTHS = '15 months';
    public static final String EIGHTEEN_MONTHS = '18 months';
    
    //Mulesoft Integration Fields
    public static final String MULESOFT_SYNC_STATUS_COMPLETED = 'Completed';
    public static final String MULESOFT_SYNC_STATUS_PENDING = 'Pending';
    public static final String MULESOFT_SYNC_STATUS_FAILED = 'Failed';
    public static final String UPDATE_TYPE_MULESOFT_SLAVE = 'MULESOFT_SLAVE';
    public static final String UPDATE_TYPE_MULESOFT_TALKBACK = 'MULESOFT_TALKBACK';
    public static final String UPDATE_TYPE_USER = 'USER';
    public static final String EMPTY_STRING = '';   
    public static final String UPDATE_TYPE_MULESOFT_SLAVE_LI = 'MULESOFT_SLAVE_LI';
    public static final String UPDATE_TYPE_MULESOFT_SLAVE_LQ = 'MULESOFT_SLAVE_LQ';
    public static final String UPDATE_TYPE_MULESOFT_TALKBACK_LI = 'MULESOFT_TALKBACK_LI';
    public static final String UPDATE_TYPE_MULESOFT_TALKBACK_LQ = 'MULESOFT_TALKBACK_LQ';
    public static Boolean MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
    public static Boolean MULESOFT_OLI_VALIDATION_TRIGGER_HAS_RUN = false;
    public static Boolean MULESOFT_OPP_SYNC_TRIGGER_HAS_RUN = false;
    public static Boolean MULESOFT_OLI_SYNC_TRIGGER_HAS_RUN = false;
    public static String TEMP_UPDATE_TYPE_MULESOFT_SLAVE = 'USER';
    public static String TEMP_UPDATE_TYPE_MULESOFT_SLAVE_OLI = 'USER';
    
    //Proxy BNF status
    public static final String SAP_SD_INTEGRATED = 'SAP SD Integrated';
    public static final String MANUAL_SETUP_IN_SAP = 'Manual Setup in SAP';
    public static final String MIBNF = 'MIBNF';
    public static final String STATUS_NEW = 'New';
    public static final String REJECTED = 'Rejected';
    public static final String SUBMITTED = 'Submitted';
    public static final String RA_REJECTED = 'RA Rejected';
    public static final String SAP_CONTRACT_CONFIRMED = 'SAP Contract Confirmed';
    public static final String BNF_STATUS_ACCEPTED = 'Accepted'; 
    public static final String BNF_STATUS_RA_ACCEPTED = 'RA Accepted';
    public static final String BNF_STATUS_LO_ACCEPTED = 'LO Accepted';
    public static final String BNF_STATUS_SAP_CONTRACT_PENDING = 'SAP Contract Pending'; 
    public static final String BNF_STATUS_SAP_PENDING = 'SAP Pending';
    public static final String LQ_REJECTEDQ = 'LO Rejected';
    public static final String OPPORTUNITY_API = 'Opportunity__c';
    public static final String RECORD_TYPE_NAME_API = 'Record_Type_Text__c';
    public static final String AGREEMENT_RECORD_TYPE_NAME_API = 'Record_Type_Name__c';
    public static final String BNF_STATUS_API = 'BNF_Status__c';
    public static final String MIBNF_API_R = 'MIBNF_Component__r.';
    public static final String PA_STATUS_APPROVED = 'Approved';
    
    //Proxy SCM Agreement record type and status
    public static final String ACTIVATED = 'Activated';
    public static final String SOW_AGREEMENT_RECORD_TYPE = 'SOW';
    public static final String AGREEMENT_STATUS_API = 'Apttus_Status_c__c';
    
    public static final String UPDATE_TYPE_MULESOFT_FORCE_UPDATE_LI = 'MULESOFT_FORCE_UPDATE_LI';    
    
    //LIG Probability
    public static final String VERBAL = 'Verbal';
    public static final String CONFIDENT = 'Confident';
    public static final String POTENTIAL = 'Potential';
    public static final String ADVANCE_TO_POTENTIAL = 'Advance to Potential';
    public static final String ON_HOLD_FUNDING = 'On Hold - Funding';
    public static final String ON_HOLD_DELAYED = 'On Hold - Delayed';
    public static final Integer PERCENTAGE_VERBAL = 100;
    public static final Integer PERCENTAGE_CONFIDENT = 90;
    public static final Integer PERCENTAGE_POTENTIAL = 50;
    public static final Integer PERCENTAGE_ADVANCE_TO_POTENTIAL = 25;
    public static final Integer PERCENTAGE_ON_HOLD_FUNDING = 0;
    public static final Integer PERCENTAGE_ON_HOLD_DELAYED = 0;
    
    public static final String ON_TRACK = 'On Track';
    public static final String BEST_CASE = 'Best Case';
    public static final String CLOSED_FORECAST_CATEGORY = 'Closed';
    public static final String OMITTED_FORECAST_CATEGORY = 'Omitted';
    public static final String PIPELINE_FORECAST_CATEGORY = 'Pipeline';
    
    public static Integer OLI_NEW_LIST_OLD_COUNT = 0;
    public static Integer OPP_NEW_LIST_OLD_COUNT = 0;
    public static Id GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Customer Account').getRecordTypeId();
    public static Id MQL_TASK_RECORD_TYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByName().get('MQL Task').getRecordTypeId();
    public static Id Standard_TASK_RECORD_TYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Standard Task').getRecordTypeId();
    public static Id MDM_VALIDATED_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
    public static Boolean IGNORE_PA_VALIDATION = false;
    public static Id IQVIA_USER_CONTACT_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IQVIA User Contact').getRecordTypeId();
    public static Id CONTACT_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
    public static final String USER_CONTACT_SYNC = 'User_Contact_Sync__c';
    public static final String RECORD_ACTIVE = 'Record_Active__c';
    public static final String RECORD_LICENSE_EXPIRY = 'Record_License_Expiry_Date__c';
    public static final String RECORD_HIRE_DATE = 'Record_Hire_Date__c';
    public static final String RECORD_EMPLOYEE_NO = 'Record_Employee_Number__c';
    public static final String RECORD_COUNTRY = 'Record_Country__c';
    public static final String UNDERSCORE_C = '__c';
    public static final String BOTH = 'Both';
    public static final String USER_TO_CONTACT = 'User To Contact';
    public static final String CONTACT_TO_USER = 'Contact To User';
    public static final String COMMA = ',';
    public static final String SALESFORCE_USER = 'Salesforce_User__c';
    public static final String RECORD_TYPE_ID = 'RecordTypeId';
    public static Boolean preventContactUpdate = false;
    
    public static final String SALESFORCE_LICENSE = 'Salesforce';
    public static final String SALESFORCE_PLATFORM_LICENSE = 'Salesforce Platform';
    public static final String CHATTER_FREE_LICENSE = 'Chatter Free';
    
    public static Boolean IS_CURRENCY_CHANGE_FLOW = false;
    public static Boolean IS_CLONE_OPPORTUNITY_FLOW = false;
    public static final String FAVOURITE_PRODUCT_LIMIT_ERROR = 'You can favourite products up to ' ;
    public static final Id GLOBAL_ACCOUNT_RECORD_TYPE_ID = '0126A000000hDGm';
    
    //Contract record type and status
    public static String CONTRACT_RECORD_TYPE_NAME_CHANGE_ORDER_GBO = 'Change Order - GBO';
    public static String CONTRACT_RECORD_TYPE_NAME_WORK_ORDER_GBO = 'Work Order - GBO';
    public static String CONTRACT_RECORD_TYPE_NAME_THIRD_PARTY_AGREEMENT = 'Third Party Agreement';
    public static String CONTRACT_RECORD_TYPE_NAME_CHANGE_ORDER = 'Change Order';
    public static String CONTRACT_RECORD_TYPE_NAME_WORK_ORDER_SALES_MEDICAL = 'Work Order - Contract Sales & Medical Solutions';
    public static Id CONTRACT_RECORD_TYPE_CNF_GBO  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('CNF - GBO').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_MASTER_SERVICE_AGREEMENT  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Service Agreement').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Change Order - GBO').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_GENERAL_CLIENT_AGREEMENT_GBO  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('General Client Agreement - GBO').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_GBO  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Preliminary Agreement - GBO').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_WORK_ORDER_GBO  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Work Order - GBO').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_THIRD_PARTY_AGREEMENT  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Third Party Agreement').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_SALES_MEDICAL  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Preliminary Agreement - Contract Sales & Medical Solutions').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_WORK_ORDER_SALES_MEDICAL  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Work Order - Contract Sales & Medical Solutions').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_CHANGE_ORDER  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Change Order').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_GENERIC_CONTRACT  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Generic Contract').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_CONFIDENTIAL_DISCLOSURE_AGREEMENT = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Confidential Disclosure Agreement').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_GENERAL_CLIENT_AGREEMENT_SALES_MEDICAL = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('General Client Agreement - Contract Sales & Medical Solutions').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_MSA_CONSOLIDATION = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MSA Consolidation').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_OTHER_SPECIAL_AGREEMENT = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Other Special Agreement').getRecordTypeId();
    public static Id CONTRACT_RECORD_TYPE_PRM_CONTRACT = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('PRM Contract').getRecordTypeId();
    public static Id BNF_RECORD_TYPE_SAP_INTEGRATED  = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('SAP SD Integrated').getRecordTypeId();
    public static String CONTRACT_STATUS_NEGOTIATION_TERMINATED = 'Negotiation Terminated';
    public static String CONTRACT_STATUS_CONTRACT_AMENDED = 'Contract Amended';
    public static String CONTRACT_STATUS_CONTRACT_EXECUTED = 'Contract Executed';  
    public static String CONTRACT_STATUS_EXECUTED = 'Executed';    
    public static String CONTRACT_STATUS_ON_HOLD = 'On Hold';
    public static String CONTRACT_STATUS_CONTRACT_TERMINATED = 'Contract Terminated';
    public static String CONTRACT_STATUS_BUDGET_AT_CUSTOMER_FOR_REVIEW = 'Budget at Customer for Review';  
    public static String CONTRACT_STATUS_BUDGET_WITH_ANALYST_FOR_CUSTOMER_EDITS = 'Budget with Analyst for Customer Edits';
    public static String CONTRACT_STATUS_CONTRACT_AT_CUSTOMER_FOR_REVIEW = 'Contract at Customer for Review';
    public static String CONTRACT_STATUS_CONTRACT_BEING_PREPARED_BY_CA = 'Contract Being Prepared by CA';
    public static String CONTRACT_STATUS_CONTRACT_AWAITING_INTERNAL_TEAM_REVIEW = 'Contract Awaiting Internal Team Review';
    public static String CONTRACT_STATUS_CONTRACT_WITH_ANALYST_FOR_OPERATIONAL_EDITS ='Contract with Analyst for Operational Edits';
    public static String CONTRACT_STATUS_CONTRACT_AWAITING_INTERNAL_APPROVAL ='Contract Awaiting Internal Approval';
    public static String CONTRACT_STATUS_CONTRACT_ANALYST_PREPARING_CUSTOMER_CONTRACT_DELIVERABLE ='Analyst Preparing Customer Contract Deliverable';
    public static String CONTRACT_STATUS_CONTRACT_WITH_ANALYST_FOR_CUSTOMER_EDITS ='Contract with Analyst for Customer Edits';
    public static String CONTRACT_STATUS_READY_TO_EXECUTE ='Ready to Execute';
    public static String CONTRACT_STATUS_ASSIGNED_NOT_STARTED ='Assigned - Not Started';
    public static String CONTRACT_STATUS_PENDING_ASSIGNMENT ='Pending Assignment';
    public static String CONTRACT_STATUS_CANCELLED_DUE_TO_COVID_19 = 'Cancelled due to COVID-19';
    public static String CONTRACT_STATUS_ON_HOLD_DUE_TO_COVID_19 = 'On Hold due to COVID-19';
    public static String CONTRACT_IS_A_BALLPARK_NO ='No';
    public static String CONTRACT_IS_A_BALLPARK_YES ='Yes';
    public static String CONTRACT_CONFIDENCE_IN_APPROVAL_OF_BUDGET_DRAFT = 'High';
    public static String CONTRACT_CONFIDENCE_IN_APPROVAL_OF_BUDGET_DRAFT_LOW = 'Low';
    public static Decimal CONTRACT_ACTUAL_CONTRACT_VALUE = 1.00;
    public static String CONTRACT_LEAD_BUSINESS_GROUP_PRODUCT_DEVELOPMENT_INITIATIVES = 'Product Development Initiatives';
    public static String CONTRACT_LEAD_BUSINESS_GROUP_CONTRACT_RESEARCH_ORGANIZATION = 'Contract Research Organization';
    public static String CONTRACT_LEAD_BUSINESS_GROUP_EARLY_CLINICAL_DEVELOPMENT = 'Early Clinical Development';
    public static String CONTRACT_LEAD_BUSINESS_GROUP_GLOBAL_LABS = 'Global Labs';
    public static String CONTRACT_LEAD_BUSINESS_GROUP_CONSULTING = 'Consulting';
    public static String CONTRACT_STATUS_START_PREPARING_BUDGET = 'Start Preparing Budget';
    public static String CONTRACT_DIVISION_BUSINESS_UNIT = 'Outcome';
    public static String CONTRACT_OWNER_ROLE = 'OGC:Clinical:Contract:Negotiations';
    public static String CONTRACT_BALLPARK = 'Ballpark';
    public static String CONTRACT_GLOBAL_CONTRACT_TRIAGE_APP = 'Global Contract Triage App';
    public static String CONTRACT_GLOBAL_SALES_OPERATIONS = 'Global Sales Operations';
    //commented as part of CPQ ageement cleanup LC-6767
    //public static Id AGREEMENT_RECORD_TYPE_RDS_BUDGET  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('RDS_Budget').getRecordTypeId();
    public static final String OPPORTUNITY_AGREEMENT_FIELD_API = 'Apttus__R00N50000001Xl0FEAS__r';
    public static final String AGR_ORDERING_DESC = 'CreatedDate DESC';
    public static String CONTRACT_STATUS_ACTIVATED = 'Activated';
    public static Id CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IQVIA User Contact').getRecordTypeId();
    
    public static Boolean updateAccountAddress = false;
    
    public static final String CONTRACT_OBJECT = 'Contract';
    public static final String CONTRACT_IN_OUT_LOG_OBJECT_API = 'Contract_In_Out_Log__c';
    public static final String CONTRACT_MILESTONE_OBJECT_API = 'Contract_Milestone__c';
    public static final String CONTRACT_LIFECYCLE_OBJECT_API = 'Contract_Lifecycle__c';
    public static final String CONTRACT_STAGE_DETAIL_OBJECT_API = 'Contract_Stage_Detail__c';
    public static final String GROUP_PLATFORM_ANALYTICS_SALES_GROUP = 'Platform Analytics Sales Group';
    public static final String GROUP_ACCOUNT_TEAM_MEMBERS_BIOTECH = 'BioTech AD';
    public static final String IQVIA_ACCOUNT_TEAMMEMBER_BIOTECH = 'IQVIA : Weekly Analysis of Duplicate Biotech Ad  TeamMember Role';
    public static final String ACCOUNT_MDM_CATEGORY_LARGE_PHARMA = 'Large Pharma';
    public static final String ACCOUNT_MDM_CATEGORY_NON_MID_SIZE_PHARMA = 'NON MID-SIZE PHARMA';
    public static final String UPSERT_LABEL = 'Upsert';
    public static final String OPPORTUNITY_HISTORY = 'OpportunityHistories';
    public static final String ACCOUNT_RISK_RATING_6_DO_NOT_SELL = '6- Do Not Sell';
    public static final String ACCOUNT_RISK_RATING_1_VERY_LOW = '1- Very Low'; 
    public static final String GLOBAL_ACC_CLOSED_TEMPLATE_DEV_NAME = 'ACC_CRM_Global_Account_Closed_to_New_Business';
    public static final String IMS_SALES_ORG_CH07 = '[CH07] IQVIA AG, Branch Basel';
    public static final String QUEUE = 'Queue';
    public static final String YES_STRING = 'Yes';
    public static final String No_String = 'No';
    public static Boolean updateSkipValidation = false;
    public static final String OPPORTUNITY_NEXT_GEN_STATUS_NOT_SUPPORTED = 'Not Supported';
    public static final String OPPORTUNITY_NEXT_GEN_REQUEST_TYPE_SALES_SUPPORT = 'Sales Support';
    public static final String IQVIA_INTERNAL_CONTACT_VALID_EMP_ERROR = 'IQVIA internal contact must have valid employee number';
    public static final String DO_NOT_ALLOW_RECORDTYPE_CHANGE_IQVIA_INTERNAL_CON = 'You cannot change record type from IQVIA internal contact to other.';
    public static final String AUDIT_EMPLOYEE_NUMBER_REQUIRED_MESSAGE = 'Audit Employee Number Reason cannot be blank when employee number is blank or N/A.'; 
    public static final String EMPLOYEE_NUMBER_VALID_ERROR_MSG = 'User should have valid and numeric employee number.';
    public static final String NA_STRING = 'N/A';
    public static final String NA_SLASH_STRING = 'N\\A';
    public static final String CHATTER_USER_CAN_CREATE_BY_IQVIA_INTERNAL_CON_ERROR = 'Chatter user can be created through IQVIA user contact only.';
    public static final String GROUP_MQL_TASK_MANAGEMENT = 'MQL Task Management';
    public static final String ACCOUNT_CATEGORY_LARGE_EBP = 'Large EBP';
    public static final String ACCOUNT_CATEGORY_SMALL_EBP = 'Small EBP';

    public static final String TASK_Disposition_Accept = 'Accept';
    //Product Delivery Country Constant
    public static final String Delivery_Country_Romania ='Romania';
    public static final String Delivery_Country_Germany ='Germany';
    
    public static final String admin = 'Admin';
    
    //Email Template
    public static final String etName = 'Opportunity_Win_Loss_Alert';
    public static final String ET_OPPORTUNITY_IS_FREEZE = 'OPP_ET13_CRM_Opportunity_Is_Freeze';
    
    // CollaborationGroup Name
    @testVisible public static String cgName ='Win/Loss Alert Romania';
    @testVisible public static String cgName2 ='Win/Loss Alert CSMS Germany';
    
    public static final String SUPER_CREDIT_CONTROL_ADMIN_GROUP = 'Super Credit Control Admins';
    public static final String SHARING_TYPE_DERIVED = 'Derived';
    public static final String BATCH_PROCESSING_NEW = 'New';
    public static final String BATCH_PROCESSING_IN_PROCESSING = 'In Processing'; 
    public static final String SHARING_PILLAR_GEOGRAPHY = 'SHR_TER';
    
    //Opportunity
    public static final String OPP_IS_FROZEN = 'Frozen';
    // Custom Email workflow
    public static final Integer MAX_USER_IDS_COUNT = 35;
    public static final Integer MAX_EMAILS_COUNT = 50;
    
    public static final String CP_COMMERCIAL_OPS_USER = 'Commercial_Ops_User';
    public static final String PRODUCT_GROUP_ECOA = 'eCOA';

    public static boolean isUpdateFromRevenueSchedule = false;
    
    public static String RWLP_SHADOW_PRODUCT_CODE = 'CES_2154A';
	
	public static final String Email_Status_Pending = 'Pending';
    
    public static Id Validated_Address_RecordId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
    public static Id Unvalidated_Address_RecordId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('Unvalidated').getRecordTypeId();
    public static Id TPA_Unvalidated_Address_RecordId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('TPA_Unvalidated_Addresses').getRecordTypeId();
    
    public static Id Validated_SAP_Contact_RecordId = Schema.SObjectType.SAP_Contact__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
    public static Id Unvalidated_SAP_Contact_RecordId = Schema.SObjectType.SAP_Contact__c.getRecordTypeInfosByDeveloperName().get('Unvalidated').getRecordTypeId();
    public static Id CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId();
    public static Id EARLY_ENGAGEMENT_BID_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId();
    public static Id PRELIMINARY_AGREEMENT_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Prelim_Agreement').getRecordTypeId();
    public static Id POST_AWARD_BID_HISTORY_RECORD_TYPE_ID = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Post_Award_Bid').getRecordTypeId();
    
    //Opportunity Line Of Business picklist Value
    public static final String LOB_Core_Clinical = 'Clinical';
    public static final String LOB_EarlyClinicalDevelopment = 'Early Clinical Development';
    public static final String LOB_RegulatoryDrugDevelopment = 'Regulatory & Drug Development Solutions';
    public static final String LOB_Clinical_Technology = 'Clinical Technology';
    public static final String LOB_Data_Science = 'Data Sciences';
    public static final String LOB_Q2_Solutions = 'Q2 Solutions';
    public static final String LOB_Avacare = 'Avacare';
    
    public static final String USER_TYPE_Avacare = 'Avacare';

    //Opportunity Global Project Unity Picklist Value
    public static final String GPU_AA_excluding_Japan = 'AA excluding Japan';
    public static final String GPU_ANZ_BDU = 'ANZ BDU';
    public static final String GPU_Biogen = 'Biogen';
    public static final String GPU_Cardiovascular_Renal_Metabolic = 'Cardiovascular Renal Metabolic';
    public static final String GPU_CentralNervousSystem = 'Central Nervous System';
    public static final String GPU_Gastroenterology = 'Gastroenterology';
    public static final String GPU_GI_IWH = 'GI-IWH';
    public static final String GPU_InternalMedicine = 'Internal Medicine';
    public static final String GPU_EarlyClinicalDevelopment = 'Early Clinical Development';
    public static final String GPU_RADDS = 'RADDS';
    public static final String GPU_MerckKGaA = 'Merck KGaA';
    public static final String GPU_Oncology = 'Oncology';
    public static final String GPU_Clinical_Technology = 'Clinical Technology';
    public static final String GPU_Johnson = 'Johnson & Johnson';
    public static final String GPU_Gilead = 'Gilead';
    public static final String GPU_Roche = 'Roche';
    public static final String GPU_BoehringerIngelheim = 'Boehringer Ingelheim';
    public static final String GPU_GlaxoSmithKline = 'GlaxoSmithKline';
    public static final String GPU_DaiichiSankyo = 'Daiichi Sankyo';
    public static final String GPU_BioNTech = 'BioNTech';
    public static final String GPU_NovoNordisk = 'Novo Nordisk';
	
    //Opportunity Currency Code
    public static final String opp_CurencyCode_JPY = 'JPY';
    
    //Therapy Area Picklist Value
    public static final String Therapy_Area_Endocrinology = 'Endocrinology';
    public static final String Therapy_Area_Cardiovascular = 'Cardiovascular';
    public static final String Therapy_Area_Nephrology = 'Nephrology';
    public static final String Therapy_Area_Oncology = 'Oncology';
    public static final String Therapy_Area_Hematology = 'Hematology';
    public static final String Therapy_Area_Neurology = 'Neurology';
    public static final String Therapy_Area_Psychiatry = 'Psychiatry';
    public static final String Therapy_Area_Transplantation = 'Transplantation';
	
	//credit-assesments risk alert FROM email 
    public static final String CREDIT_ASSESSMENT_EMAIL = 'credit.assessments-NA@iqvia.com';
    //ESPSFDCQI-15508
    public static final String APTTUS_APTS_AGREEMENT_KEY_PREFIX = 'a1F';
    
    public static final String EMEA = 'EMEA';
    public static final String EPG_IME = 'EPG IME';
    public static final String EPG = 'EPG';
    public static final String EPG_Collaborative = 'EPG Collaborative';
    public static final String USER_TYPE_EPG = 'EPG';
    public static final String USER_TYPE_EPG_IME = 'EPG IME';
    public static final String USER_TYPE_EPG_Collaborative = 'EPG Collaborative';
}