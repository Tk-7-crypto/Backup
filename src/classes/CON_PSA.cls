/*************************************************************************************
Apex Class Name : CON_PSA 
Purpose         : Constants for use throughout PSA classes (to avoid hard-coding values)
                                                           
             
***************************************************************************************/
public with sharing class CON_PSA 
{
    public static final String IQVIA_NO_REPLY_SUPPORT_EMAIL ='no.reply.support@iqvia.com';
    /************************************************************************************************************
    // Contact
    *************************************************************************************************************/
    public static final string CONTACT_REC_TYPE_IQVIA_USER_CONTACT = 'IQVIA User Contact';
    
    /************************************************************************************************************
    // Permission Sets
    *************************************************************************************************************/
    public static final string PERMISSION_SET_RDS_ADMIN = 'RDS_Admin';
    public static final string PERMISSION_SET_RDS_LR_READ_AND_EDIT = 'RDS_LR_Read_And_Edit';
    
    /************************************************************************************************************
    // Assignments
    *************************************************************************************************************/
    public static final string ASSIGNMENT_STATUS_TENTATIVE = 'Tentative';
    static public final string ASSIGNMENT_STATUS_SCHEDULED = 'Scheduled';
    static public final string ASSIGNMENT_STATUS_CLOSED = 'Closed';
    static public final string ASSIGNMENT_STATUS_CANCELLED = 'Cancelled';
    static public final string ASSIGNMENT_STATUS_COMPLETED = 'Completed';
    static public final string ASSIGNMENT_STATUS_REJECTED = 'Rejected';
    static public final string ASSIGNMENT_REC_TYPE_RDS = 'RDS Assignment';    
    static public final string ASSIGNMENT_REC_TYPE_ID_RDS = Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByName().get('RDS Assignment').getRecordTypeId();
	
    public static boolean isSkipValidationFieldValidationsRDS = false;
    public static final String SKILL_TYPE_LANGUAGE = 'Language';
    /************************************************************************************************************
    // Budgets
    *************************************************************************************************************/
    static public final string BUDGET_STATUS_DRAFT = 'Draft';
    static public final string BUDGET_STATUS_OPEN = 'Open';
    static public final string BUDGET_STATUS_APPROVED = 'Approved';
    static public final string BUDGET_STATUS_REJECTED = 'Rejected';
    static public final string BUDGET_REC_TYPE_ID_RDS = Schema.SObjectType.pse__Budget__c.getRecordTypeInfosByName().get('RDS Budget').getRecordTypeId();

    //static public final string BUDGET_TYPE_PO = 'Customer Purchase Order';
    //static public final string BUDGET_TYPE_PO_CR = 'Customer Purchase Order Change Request';
    //static public final string BUDGET_NAME_SUFFIX = ' Initial Budget';
    static public final string BUDGET_TYPE_FIXED = 'Fixed Price';
    static public final string BUDGET_TYPE_FEE_FOR_SERVICE = 'Fee for Service';
    static public final string BUDGET_TYPE_FEE_FOR_SERVICECAP = 'Fee for Service w/Cap';
    static public final string BUDGET_TYPE_FIXED_UNIT_PRICE = 'Fixed Unit Price';
    static public final string BUDGET_TYPE_COMBINATION = 'Combination';
    
    /************************************************************************************************************
    // Miscellaneous Adjustment
    *************************************************************************************************************/
    static public final String MISCELLANEOUS_ADJUSTMENT_STATUS_APPROVED = 'Approved';
    

    /************************************************************************************************************
    // Billing Events
    *************************************************************************************************************/
    static public final String BILLING_EVENT_STATUS_DRAFT = 'Draft'; // per billing/rev rec design doc
    static public final String BILLING_EVENT_STATUS_RELEASED = 'Released'; // per billing/rev rec design doc
    //static public final String BILLING_EVENT_STATUS_INVOICED = 'Invoiced'; // per billing/rev rec design doc


    // static public final String BILLING_EVENT_INTEGRATION_STATUS_ELIGIBLE = 'Eligible'; 
    //static public final String BILLING_EVENT_INTEGRATION_STATUS_INELIGIBLE = 'Ineligible'; 
    //static public final String BILLING_EVENT_INTEGRATION_STATUS_PROCESSING = 'Processing'; 
    //static public final String BILLING_EVENT_INTEGRATION_STATUS_COMPLETED = 'Completed'; 
    //static public final String BILLING_EVENT_INTEGRATION_STATUS_ERROR = 'Error'; 

    /************************************************************************************************************
    // Billing Event Items
    *************************************************************************************************************/
    //static public final String BILLING_EVENT_ITEM_CATEGORY_EXPENSE = 'Expense';
    //static public final String BILLING_EVENT_ITEM_CATEGORY_MILESTONE = 'Milestone';
    //static public final String BILLING_EVENT_ITEM_CATEGORY_TIMECARD = 'Timecard';
    //static public final String BILLING_EVENT_ITEM_CATEGORY_MISC_ADJ = 'Miscellaneous Adjustment';
    //static public final String BILLING_EVENT_ITEM_CATEGORY_BUDGET = 'Budget';

    /************************************************************************************************************
    // Expense Reports
    *************************************************************************************************************/
    //static public final String EXPENSE_REPORT_STATUS_DRAFT = 'Draft'; // ff_onboarding
   // static public final String EXPENSE_REPORT_STATUS_SUBMITTED = 'Submitted'; // ff_onboarding
    //static public final String EXPENSE_REPORT_STATUS_REJECTED = 'Rejected'; // ff_onboarding
   // static public final String EXPENSE_REPORT_STATUS_APPROVED = 'Approved'; // ff_onboarding
   
   /***********************************************************************************************
   //Frequency of Journal
   ***********************************************************************************************/
    static public final String FREQUENCY_OF_JOURNAL_BI_ANNUAL = 'Bi-Annual (Twice a year)';
    static public final String FREQUENCY_OF_JOURNAL_BI_MONTHLY = 'Bi-Monthly (Every two months)';
    static public final String FREQUENCY_OF_JOURNAL_BI_WEEKLY = 'Bi-Weekly (Every two weeks)';
    static public final String FREQUENCY_OF_JOURNAL_EVERY_9_MONTHS = 'Every 9 Months';
    static public final String FREQUENCY_OF_JOURNAL_MONTHLY = 'Monthly';
    static public final String FREQUENCY_OF_JOURNAL_QUARTERLY = 'Quarterly';
    static public final String FREQUENCY_OF_JOURNAL_WEEKLY = 'Weekly';
    static public final String FREQUENCY_OF_JOURNAL_NA = 'N/A';
    static public final String FREQUENCY_OF_JOURNAL_YEARLY = 'Yearly (Annual)';
    static public final String FREQUENCY_OF_JOURNAL_OTHER = 'Other';
    
    /************************************************************************************************************
    // Week Days
    *************************************************************************************************************/
    static public final String MONDAY = 'Monday';
    static public final String TUESDAY = 'Tuesday';
    static public final String WEDNESDAY = 'Wednesday';
    static public final String THURSDAY = 'Thursday';
    static public final String FRIDAY = 'Friday';
    static public final String SATURDAY = 'Saturday';
    static public final String SUNDAY = 'Sunday';

    /************************************************************************************************************
    // Milestones
    *************************************************************************************************************/
    //static public final string MILESTONE_REC_TYPE_BILLING = 'Billing';  // record type
    //static public final string MILESTONE_REC_TYPE_LABOR = 'Labor';      // record type
    static public final string MILESTONE_REC_TYPE_BILLING = 'RDS Billing';  // record type
    static public final string MILESTONE_REC_TYPE_SERVICE = 'RDS Service';      // record type
    static public final string MILESTONE_REC_TYPE_ID_RDS_BILLING = Schema.SObjectType.pse__Milestone__c.getRecordTypeInfosByName().get('RDS Billing').getRecordTypeId();
    static public final string MILESTONE_REC_TYPE_ID_RDS_SERVICE = Schema.SObjectType.pse__Milestone__c.getRecordTypeInfosByName().get('RDS Service').getRecordTypeId();
	static public final string MILESTONE_STATUS_CANCELLED = 'Cancelled';

    static public final string MILESTONE_STATUS_PLANNED = 'Planned';
    //static public final string MILESTONE_STATUS_OPEN = 'Open';
    static public final string MILESTONE_STATUS_APPROVED = 'Approved';
    static public final string MILESTONE_STATUS_COMPLETED = 'Completed';
    static public final string MILESTONE_STATUS_CANCELED = 'Canceled';

    //static public final string MILESTONE_TYPE_BILLABLE_FF = 'Billable - Fixed Fee';
    //static public final string MILESTONE_TYPE_BILLABLE_TM = 'Billable - T&M';
    //static public final string MILESTONE_TYPE_NON_BILLABLE = 'Non-Billable';
    //static public final string MILESTONE_TYPE_PRE_BILL = 'Pre-Bill';
    //static public final string MILESTONE_TYPE_BILLABLE_EXPENSE = 'Billable - Expenses'; 

    static public final string MILESTONE_BILLING_TYPE_UNIT_BASED = 'Unit-based';
    static public final string MILESTONE_BILLING_TYPE_FEE_FOR_SERVICE = 'Fee-for-Service';
    static public final string MILESTONE_BILLING_TYPE = 'Milestone';
    static public final string MILESTONE_NON_BILLABLE = 'Non-Billable';
    static public final string MILESTONE_Name_Signal_Validation = 'Signal Validation';
    static public final string MILESTONE_Name_Signal_Evaluation = 'Signal Evaluation';
    
       
    //static public final string MILESTONE_TYPE_BILLABLE_TM = 'Billable - T&M';
    //static public final string MILESTONE_TYPE_NON_BILLABLE = 'Non-Billable';
    //static public final string MILESTONE_TYPE_PRE_BILL = 'Pre-Bill';
    //static public final string MILESTONE_TYPE_BILLABLE_EXPENSE = 'Billable - Expenses'; 

   
    //static public final string MILESTONE_UTILIZATION_TYPE_TIME_CREDITED = 'Time Credited';
    //static public final string MILESTONE_UTILIZATION_TYPE_TIME_EXCLUDED = 'Time Excluded';
    //static public final string MILESTONE_UTILIZATION_TYPE_NOT_UTILIZED = 'Not Utilized';
    //static public final string MILESTONE_UTILIZATION_TYPE_BILLABLE = 'Billable';

    /************************************************************************************************************
    // Miscellaneous Adjustments
    *************************************************************************************************************/
    /*static public final string MISC_ADJ_CATEGORY_BOOKED_REV = 'Booked Revenue';
    static public final string MISC_ADJ_CATEGORY_BUDGETED_COST = 'Budgeted Cost';
    static public final string MISC_ADJ_CATEGORY_BUDGETED_EXP_COST = 'Budgeted Expense Cost';
    static public final string MISC_ADJ_CATEGORY_EXP_BUDGET = 'Expense Budget';
    static public final string MISC_ADJ_CATEGORY_EXP_COST = 'Expense Cost';
    static public final string MISC_ADJ_CATEGORY_EXTERNAL_COST = 'External Cost';
    static public final string MISC_ADJ_CATEGORY_INTERNAL_BUDGET = 'Internal Budget';
    static public final string MISC_ADJ_CATEGORY_INTERNAL_COST = 'Internal Cost';
    static public final string MISC_ADJ_CATEGORY_OTHER_COST = 'Other Cost';
    static public final string MISC_ADJ_CATEGORY_PASS_THRU_RTB_REV = 'Pass-Through Ready-to-Bill Revenue';
    static public final string MISC_ADJ_CATEGORY_PRE_BILL_REV = 'Pre-Billed Revenue';
    static public final string MISC_ADJ_CATEGORY_RTB_REV = 'Ready-to-Bill Revenue';
    static public final string MISC_ADJ_CATEGORY_REV = 'Revenue';

    static public final string MISC_ADJ_STATUS_DRAFT = 'Draft';
    static public final string MISC_ADJ_STATUS_SUBMITTED = 'Submitted';
    static public final string MISC_ADJ_STATUS_APPROVED = 'Approved';
    static public final string MISC_ADJ_STATUS_REJECTED = 'Rejected';

    /************************************************************************************************************
    // Opportunity
    *************************************************************************************************************/
    //static public final string OPPORTUNITY_STAGE_CLOSED_LOST = 'Closed Lost';
    //static public final string OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    // Need to add the 5 stages
    static public final string OPPORTUNITY_STAGE_IDENTIFYING = 'Identifying Opportunity';
    static public final string OPPORTUNITY_STAGE_QUALIFYING = 'Qualifying Opportunity';
    static public final string OPPORTUNITY_STAGE_DEVELOPING_PROPOSAL= 'Developing Proposal';
    static public final string OPPORTUNITY_STAGE_DELIVERING_PROPOSAL= 'Delivering Proposal';
    static public final string OPPORTUNITY_STAGE_FINALIZING_DEAL= 'Finalizing Deal';
    static public final string OPPORTUNITY_STAGE_RECEIVED_ATP_LOI= 'Received ATP/LOI';

    //static public final string OPPORTUNITY_RECORD_TYPE_NEW = 'New';
    static public final string OPPORTUNITY_RECORD_TYPE_MANUAL = 'Manual';
    static public final string OPPORTUNITY_RECORD_TYPE_CS_UPSELL = 'CS Upsell';
    static public final string OPPORTUNITY_RECORD_TYPE_RENEWAL = 'Renewal';

    /************************************************************************************************************
    // Aggregate Reports
    *************************************************************************************************************/
    static public final string AGG_REPORT_TYPE_ID_SANDOZ = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosByName().get('Sandoz Report').getRecordTypeId();
    static public final string AGG_REPORT_REC_TYPE_SANOFI_GSO = 'Sanofi_GSO_Report';
    static public final string AGG_REPORT_REC_TYPE_SANOFI_PVS = 'Sanofi_PVS_Report';
    static public final string AGG_REPORT_REC_TYPE_GENERAL = 'General_Report';
    static public final string AGG_REPORT_REC_TYPE_TAKEDA = 'Takeda_Report';
    static public final string AGG_REPORT_REC_TYPE_RA_RESPONSE = 'RA_Response';
    static public final string AGG_REPORT_REC_TYPE_SANDOZ = 'Sandoz_Report';
    
    static public final string AGG_REPORT_SECTION_REPORT_WRITING = 'Report_Writing_Section';
    static public final string AGG_REPORT_SECTION_LITR_REVIEW = 'Literature_POC_Section';
    static public final string AGG_REPORT_SECTION_MEETINGS = 'Meetings_Section';
    static public final string AGG_REPORT_SECTION_QC = 'QC_Section';
    static public final string AGG_REPORT_SECTION_BRM = 'BRM_Section';
    static public final string AGG_REPORT_SECTION_MED_REVIEW = 'Med_Review_Section';
    static public final string AGG_REPORT_SECTION_CLIENT_REG = 'Client_Reg_Section';
    static public final string AGG_REPORT_SECTION_REPORT_TAKEDA = 'Takeda_Section';
    static public final string AGG_REPORT_SECTION_LL = 'LL_Section';
    static public final string AGG_REPORT_SECTION_GENERAL = 'General_Section';
    static public final string AGG_REPORT_SECTION_TAKEDA_RA_RESP_ONLY = 'Takeda_RA_Resp_Only_Section';
    static public final string AGG_REPORT_SECTION_SANOFI_PVS = 'SANOFI_PVS_Section';
    static public final string AGG_REPORT_SECTION_SANOFI_GSO = 'SANOFI_GSO_Section';
    static public final string AGG_REPORT_SECTION_COMMA_SEPARATOR = ',';
    static public final string AGG_REPORT_Status_Completed = 'Completed';
    static public final string AGG_REPORT_SECTION_REQUIRED_EQUALS_NA = 'NA';
    static public final string AGG_REPORT_SECTION_REQUIRED_EQUALS_Client = 'Client';
    static public final string AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA = 'IQVIA';
    static public final string AGG_REPORT_PLANNED_DATE_FOR_MEDICAL_REVIEW_COMPLETION = 'Planned Date for Medical Review Completion';
    static public final string AGG_REPORT_PLANNED_DATE_FOR_MEDICAL_REVIEW_SENT = 'Planned Date for Medical Review Sent';
    static public final string AGG_REPORT_PLANNED_DATE_FOR_MEDICAL_REVIEW_COMPLETION_AND_PLANNED_DATE_FOR_MEDICAL_REVIEW_SENT = 'Planned Date for Medical Review Completion & Planned Date for Medical Review Sent';
    static public final string AGG_REPORT_SEND_PRIMARY_RESOURCE ='PSA_03_SendMailToPrimaryResource';
    
    static public final string AGG_REPORT_NA_FIELD_VALUE_EQUALS_YES = 'Yes';
    static public final string AGG_REPORT_NA_FIELD_VALUE_EQUALS_NO = 'No';
    /************************************************************************************************************
    // Projects
    *************************************************************************************************************/
    static public final string PROJ_NAME_SUFFIX = '-Project';

    static public final string PROJ_REC_TYPE_RDS_PROJECT = 'RDS Project';  // record type
    static public final string PROJ_REC_TYPE_RDS_SERVICELINE = 'RDS Service Line';      // record type
    static public final string PROJ_REC_TYPE_RDS_TEMPLATE = 'RDS Template';      // record type
    static public final string PROJ_REC_TYPE_RDS_INTERNAL = 'RDS Internal';      // record type

    static public final string PROJ_REC_TYPE_ID_RDS_PROJECT = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Project').getRecordTypeId();  // record type id
    static public final string PROJ_REC_TYPE_ID_RDS_SERVICELINE = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Service Line').getRecordTypeId();     // record type id
    static public final string PROJ_REC_TYPE_ID_RDS_INTERNAL = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Internal').getRecordTypeId();     // record type id

    //static public final string PROJ_TYPE_PTO = 'Paid Time Off';
    static public final string PROJ_TYPE_CUSTOMER = 'Customer Project';
    static public final string PROJ_TYPE_INTERNAL = 'Internal';  
    static public final string PROJ_TYPE_ABSENCE = 'Absence';

    static public final string PROJ_BILL_TYPE_FIXED = 'Fixed Price';
    //static public final string PROJ_BILL_TYPE_TM = 'Time and Materials';

    static public final string PROJ_BUDGET_TYPE_FIXED = 'Fixed Price';
    static public final string PROJ_BUDGET_TYPE_FEE_FOR_SERVICE = 'Fee for Service';
    static public final string PROJ_BUDGET_TYPE_FEE_FOR_SERVICECAP = 'Fee for Service w/Cap';
    static public final string PROJ_BUDGET_TYPE_FIXED_UNIT_PRICE = 'Fixed Unit Price';
    static public final string PROJ_BUDGET_TYPE_COMBINATION = 'Combination';
    
    static public final string PROJ_STAGE_STARTUP = 'Start-up';
    static public final string PROJ_STAGE_CONDUCT = 'Conduct';
    static public final string PROJ_STAGE_CLOSE_OUT = 'Close-out';
    static public final string PROJ_STAGE_COMPLETED = 'Completed';
    static public final string PROJ_STAGE_ON_HOLD = 'On Hold';
    static public final string PROJ_STAGE_CANCELED = 'Cancelled';
    static public final string PROJ_STAGE_Active = 'Active';
    static public final string PROJ_STAGE_Not_Active = 'Not Active';
    
    static public final string PROJ_SERVICELINE_SIGNAL_MANAGEMENT = 'Signal Management';
    static public final string PROJ_SERVICELINE_CEVA = 'CEVA';
    
    static public final string PROJ_END_DATE_EMAIL_TO_PROJECT_MANAGER_EMAIL_ACTION_VAL = 'PSA_04_ProjectEndDateAlertToProjectManager';
    static public final string PROJ_GROUP_RADDS = 'RADDS';
    

    //static public final string PROJ_TIME_APPROVAL_METHOD_AUTO = 'Auto-Approve';
    //static public final string PROJ_TIME_APPROVAL_METHOD_PM = 'Project Manager';
    //static public final string PROJ_TIME_APPROVAL_METHOD_RM = 'Resource Manager';

    //static public final string PROJ_EXPENSE_APPROVAL_METHOD_PM = 'Project Manager';
    //static public final string PROJ_EXPENSE_APPROVAL_METHOD_RM = 'Resource Manager';

    /************************************************************************************************************
    // Products
    *************************************************************************************************************/
   /* static public final string PROD_SERVICES_BILL_TYPE_FIXED = 'Billable - Fixed Fee';
    static public final string PROD_SERVICES_BILL_TYPE_TM = 'Billable - T&M';
    static public final string PROD_SERVICES_BILL_TYPE_EXPENSE = 'Billable - Expenses';
    static public final string PROD_SERVICES_BILL_TYPE_NB = 'Non-Billable';
    static public final string PROD_PROJECT_CATEGORY_IMPL = 'Implementation';
    static public final string PROD_PROJECT_CATEGORY_PS = 'Professional Services';
    static public final string PROD_PROJECT_CATEGORY_LIC = 'Licensing';
    static public final string PROD_PROJECT_CATEGORY_PM = 'Project Management';*/

    /************************************************************************************************************
    // PSA Resources
    *************************************************************************************************************/
    //static public final string RESOURCE_ROLE_CONSULTANT = 'Consultant';
    static public final string RESOURCE_ROLE_COORDINATOR = 'Coordinator';
    static public final string RESOURCE_ROLE_FUNCTIONAL_LEAD = 'Fuctional Lead';
    static public final string RESOURCE_ROLE_LINE_MANAGER = 'Line Manager';
    static public final string RESOURCE_ROLE_MEDICAL_SAFETY_ADVISOR = 'Medical Safety Advisor';
    static public final string RESOURCE_ROLE_PROJECT_MANAGER = 'Project Manager';
    static public final string RESOURCE_ROLE_SPECIALIST_SENIOR = 'Specialist - Senior';
    static public final string RESOURCE_ROLE_SPECIALIST = 'Specialist';
    static public final string RESOURCE_ROLE_SPECIALIST_JUNIOR= 'Specialist - Junior';
    static public final string RESOURCE_ROLE_SERVICELINE_LEAD = 'Service Line Lead';
    static public final string RESOURCE_ROLE_QPPV_OR_DEPUTY = 'QPPV or Deputy';
    

    /************************************************************************************************************
    // PSA Resource Requests
    *************************************************************************************************************/
    public static final string RESOURCE_REQUEST_STATUS_DRAFT = 'Draft';
    public static final string RESOURCE_REQUEST_STATUS_READY = 'Ready to Staff';
    public static final string RESOURCE_REQUEST_STATUS_HOLD = 'Hold';
    public static final string RESOURCE_REQUEST_STATUS_TENTATIVE = 'Tentative';
    public static final string RESOURCE_REQUEST_STATUS_ASSIGNED = 'Assigned';
    public static final string RESOURCE_REQUEST_STATUS_CANCELLED = 'Cancelled';
    public static final string RESOURCE_REQUEST_REC_TYPE_RDS_REQUEST = 'RDS Request';
    public static final string RESOURCE_REQUEST_REC_TYPE_ID_RDS_REQUEST = Schema.SObjectType.pse__Resource_Request__c.getRecordTypeInfosByName().get('RDS Request').getRecordTypeId();     // record type id

     /************************************************************************************************************
    // PSA Metric
    *************************************************************************************************************/
    public static final string PSA_METRIC_Frequency_Monthly = 'Monthly';
    public static final string PSA_METRIC_Frequency_Quarterly = 'Quarterly';
    public static final string PSA_METRIC_Frequency_Semi_Annual = 'Semi_Annual';
    public static final string PSA_METRIC_Frequency_Rolling_12 = 'Rolling_12';

     /************************************************************************************************************
    // Project Tasks
    *************************************************************************************************************/
    public static final string RDS_DELIVERABLE = 'RDS Deliverable';
    public static final string RDS_DELIVERABLE_TASK = 'RDS Deliverable Task';
    public static final string RDS_PROJECT_TASK = 'RDS Project Task';
    public static final string RDS_DELIVERABLE_GENERAL = 'RDS Deliverable-General';
    public static final string RDS_TASK_AR = 'RDS Task-AR';
    public static final string RDS_TASK_CMC = 'RDS Task-CMC';
    public static final string RDS_TEMPLATE_TASK= 'RDS Template Task';
    public static final string RECORD_TYPE_RDS_DELIVERABLE = 'RDS_Deliverable';
    public static final string RECORD_TYPE_RDS_PROJECT_TASK = 'RDS_Project_Task';
    public static final string RECORD_TYPE_RDS_DELIVERABLE_TASK = 'RDS_Deliverable_Task';
    
    static public final string PROJ_TASK_STATUS_NOT_APPLICABLE = 'Not Applicable';
    static public final string PROJ_TASK_STATUS_COMPLETE = 'Complete';
    static public final string PROJ_TASK_STATUS_CANCELLED = 'Cancelled';
    static public final string PROJ_TASK_STATUS_IN_PROGRESS = 'In Progress';
    static public final string PROJ_TASK_STATUS_PLANNED = 'Planned';
    static public final string PROJ_TASK_STATUS_NOT_STARTED = 'Not Started';
    
    public static final string PROJ_TASK_EMAIL_TO_SERVICE_LINE_LEAD_EMAIL_ACTION_VAL = 'PSA_02_ProjectTaskMailToServiceLineLead';
    public static final string SD_RUN_SEND_EMAIL_NOTIFICATION = 'PSA_05_SdRunSendEmailNotification';
    public static final string SIGNAL_SEND_EMAIL_NOTIFICATION = 'PSA_06_SignalSendEmailNotification';
    public static final string AGGREGATE_REPORT_SEND_EMAIL_NOTIFICATION = 'PSA_07_AggregateReportSendEmailNotification';
    
    static public final string PROJ_TYPE_START_UP = 'Start-up';
    static public final string PROJ_TYPE_CLOSE_OUT = 'Close-out';
    static public final string PROJ_TYPE_MAINTENANCE = 'Maintenance';
    static public final string PROJ_Resource_SER_Specialist = 'SER Specialist';
    static public final string PROJ_Resource_SVF_Specialist = 'SVF Specialist';
    static public final string PROJ_ServiceCode_SM3 = 'SM3';
    static public final string PROJ_ServiceCode_SM4 = 'SM4';
    static public final string PROJ_Frequency_YEARLY = 'Yearly';
    static public boolean PROJ_TASK_FLAG = true;
    public static final string RDS_DELIVERABLE_TASK_RECORD_TYPE_ID = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable_Task').getRecordTypeId();
    public static final string RDS_PROJECT_TASK_RECOR_TYPE_ID = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Project_Task').getRecordTypeId();
    public static final string RDS_DELIVERABLE_RECORD_TYPE_ID = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable').getRecordTypeId();

    /************************************************************************************************************
    // Targets 
    *************************************************************************************************************/
    public static final string TARGET_REC_TYPE_RDS_COUNTRY = 'RDS Country';
    public static final string TARGET_REC_TYPE_RDS_PRODUCT_LINE = 'RDS Product Line';
    public static final string TARGET_REC_TYPE_RDS_PROTOCOL = 'RDS Protocol';
    public static final string TARGET_REC_TYPE_RDS_PV_AGREEMENT = 'PV Agreement';
    public static final string TARGET_RECORD_TYPE_ID_PV_AGREEMENT = Schema.SObjectType.Target__c.getRecordTypeInfosByName().get('PV Agreement').getRecordTypeId(); 
    public static final string TARGET_RECORD_TYPE_ID_RDS_PROTOCAL = Schema.SObjectType.Target__c.getRecordTypeInfosByName().get('RDS Protocol').getRecordTypeId(); 
    public static final string TARGET_RECORD_TYPE_ID_RDS_COUNTRY = Schema.SObjectType.Target__c.getRecordTypeInfosByName().get('RDS Country').getRecordTypeId(); 
    public static final string TARGET_REC_TYPE_ID_RDS_PRODUCT_LINE = Schema.SObjectType.Target__c.getRecordTypeInfosByName().get('RDS Product Line').getRecordTypeId();     // record type id


    /************************************************************************************************************
    // Region
    *************************************************************************************************************/
    public static final String REGION_CORPORATE = 'Corporate';

    /************************************************************************************************************
    // GROUP
    *************************************************************************************************************/
    public static final String GROUP_CORPORATE = 'Corporate';


    /************************************************************************************************************
    // Time Periods
    *************************************************************************************************************/
    public static final string TIME_PERIOD_TYPE_PERPETUAL = 'Perpetual';
    public static final string TIME_PERIOD_TYPE_YEAR = 'Year';
    public static final string TIME_PERIOD_TYPE_QUARTER = 'Quarter';
    public static final string TIME_PERIOD_TYPE_CLAENDAR_QUARTER = 'Calendar Quarter';
    public static final string TIME_PERIOD_TYPE_MONTH = 'Month';
    public static final string TIME_PERIOD_TYPE_CLAENDAR_MONTH = 'Calendar Month';
    public static final string TIME_PERIOD_TYPE_WEEK = 'Week';

    /************************************************************************************************************
    // Timecards
    *************************************************************************************************************/
   /* static public final string TIMECARD_STATUS_SAVED = 'Saved';
    static public final string TIMECARD_STATUS_SUBMITTED = 'Submitted';
    static public final string TIMECARD_STATUS_APPROVED = 'Approved';
    static public final string TIMECARD_STATUS_REJECTED = 'Rejected';*/
    
    public static boolean runSubProjectUpdate = true;
    
    /************************************************************************************************************
    // LR Project Overview
    *************************************************************************************************************/
    public static final string LR_PROJECT_OVERVIEW_OBJECT_API_NAME = 'LR_Project_Overview__c';
    public static final string LR_PROJECT_REVIEW_STATUS_COMPLETED = 'Completed';
    public static final string LR_PROJECT_REVIEW_STATUS_ASSIGNED = 'Assigned - Not Yet Started';
    public static final string LR_PROJECT_REVIEW_STATUS_CANCELLED = 'Cancelled';
    public static final string LR_PROJECT_REVIEW_AGGREGATE_REPORT_YES = 'Yes';
    public static final string LR_PROJECT_REVIEW_SEARCH_STRATEGY_YES = 'Yes';
    public static final string LR_PROJECT_REVIEW_SEARCH_STRATEGY_PENDING = 'Pending';
    /************************************************************************************************************
    // SIGNAL
    *************************************************************************************************************/
    public static final string SIGNAL_STATUS_CLOSED = 'Closed';
    public static final string SIGNAL_STATUS_NOT_VALIDATED = 'Not Validated';
    public static final string SIGNAL_STATUS_ONGOING = 'Ongoing';
    public static final string SIGNAL_STATUS_TO_BE_VALIDATED = 'To Be Validated';
    public static final string SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_YES = 'Yes';
    public static final string SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NO = 'No';
    public static final string SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NO_SPECIFY_REASON = 'No (Specify Reason)';
    public static final string SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_ADMINISTRATIVE = 'Administrative';
    public static final string SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NOT_APPLICABLE = 'Not Applicable';
    public static final string SIGNAL_PICKLIST_FIELD_VALUE_SIGNAL_VALIDATED = 'Signal Validated';
    
    /************************************************************************************************************
    // SD RUNS
    *************************************************************************************************************/
    public static final string SD_RUNS_STATUS_COMPLETED = 'Completed';
    
    /************************************************************************************************************
    // LR Project Overview
    *************************************************************************************************************/
    public static final string LR_PROJECT_OVERVIEW_STATUS_COMPLETED = 'Completed';
    public static final string LR_PROJECT_OVERVIEW_STATUS_CANCELLED = 'Cancelled';
    public static final string LR_PROJECT_OVERVIEW_LR_Type_LOCAL = 'Local';
    public static final string LR_PROJECT_OVERVIEW_LR_Type_GLOBAL = 'Global';
    public static final string LR_PROJECT_OVERVIEW_AGG_REP_NA = 'NA';
    
    /************************************************************************************************************
    // LR DLP Email
    ************************************************************************************************************/
    public static final string LR_PROJECT_DLP_APPROACHING_EMAIL_30_DAYS = 'DLP 30 days approaching email trigger';
    public static final string LR_PROJECT_DLP_APPROACHING_EMAIL_60_DAYS = 'DLP 60 days approaching email trigger';
    public static final string LR_PROJECT_LBI_PERIOD_APPROACHING_EMAIL_07_DAYS = 'LR LBI period stop date field email trigger';
    public static final string LR_PROJECT_REVIEW_STATUS_INPROGRESS = 'In Progress';
    public static final string LR_DLP_LBI_SRCH_STRGY_EMAIL_ACTION_VAL = 'PSA_01_LR_DLP_LBI_SRCH_STGY_EMAILS';
    public static final string PSA_MODULE_NAME = 'PSA';
    public static final string LITERATURE = 'Literature';
    public static final string PV_SOLN_SRVC_NAME = 'PV Solutions';
    public static final string SRVC_LINE_LEAD_ROLE = 'Service Line Lead';
    public static final string SPECIALIST_JUNIOR_ROLE = 'Specialist - Junior';
    public static final string SPECIALIST_SENIOR_ROLE = 'Specialist - Senior';
    public static final string LIT_SARA_SUB_ROLE = 'LIT-SARA LR Back-Up Lead, Reviewer, QC';
    public static final string LIT_SARA_LEAD_SUB_ROLE = 'LIT-SARA LR Lead, Reviewer, QC';
    public static final string LIT_PVS_LEAD = 'PVS-Lead';
    public static final string ASSIGNMENTS_GRT_50 = 'Assignments for more than 50 distinct resources found';
    public static final string LR_SIX_MONTHLY_FREQ = 'Six (6)-Monthly';
    public static final string LR_ANNUAL_FREQ = 'Annual (Yearly)';
    public static final string MEDICAL_INFORMATION_SERVICE_LINE = 'Medical Information';
    public static final string MEDICAL_INFORMATION_SERVICE_LINE_CODE = 'MI';
    
    /************************************************************************************************************
    // JOURNAL CALENDARS
    ************************************************************************************************************/
    public static final string JOURNAL_CALENDAR_VAR_FUTURE = 'FUTURE';
    public static final string JOURNAL_CALENDAR_VAR_PRESENT = 'PRESENT';
    public static final string JOURNAL_CALENDAR_VAR_PAST = 'PAST';
    
    /************************************************************************************************************
    // Service Line field map
    ************************************************************************************************************/
	
    public static final string SRVC_LINE = 'Service Line';
    public static Map<String, List<string>> srvcLineToFieldMap = new Map<String, List<string>>{
        'CMC34'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c'},
        'LM41'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Planned_Submission_Date__c','Submitted__c','Submitted_Date__c','HA_Response_Received__c','Approved__c','HA_Approval_Date__c',
            'Date_HA_Approval_Notified__c','Rejected__c','HA_Rejection_Date__c','Client_Notification_Date__c','Was_client_notification_within_10_days__c','Tracking_system_updated__c',
            'eCTD_Submission_Ready_docs__c','eCTD_met_Publishing_deadlines__c','Submission_sent_to_Publishing_on_time__c','Submission_passing_first_time_validation__c','Submission_Procedure__c',
            'HA_Question_due_to_IQVIA_error__c','No_of_docs_rejected_by_client__c','Reason_for_documents_rejected_at_client__c','No_of_critical_errors_in_IQVIA_doc__c','Reason_for_critical_errors_in_IQVIA__c',
            'No_of_non_critical_errors_in_IQVIA_doc__c','Reason_for_non_critical_errors_in_IQVIA__c','Dependency_for_Critical_Errors__c','Dependency_for_Non_Critical_Errors__c','Critical_or_Non_Critical_Deadline__c',
            'Late_Responsibility__c','Late_Reason_Text__c'},
        'PREM10'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Planned_Submission_Date__c','Submitted__c','Submitted_Date__c','HA_Response_Received__c','Approved__c','HA_Approval_Date__c',
            'Date_HA_Approval_Notified__c','Rejected__c','HA_Rejection_Date__c','Client_Notification_Date__c','Was_client_notification_within_10_days__c','Tracking_system_updated__c',
            'eCTD_Submission_Ready_docs__c','eCTD_met_Publishing_deadlines__c','Submission_sent_to_Publishing_on_time__c','Submission_passing_first_time_validation__c','Submission_Procedure__c',
            'HA_Question_due_to_IQVIA_error__c','Late_Responsibility__c','Late_Reason_Text__c','pse__Actual_Hours__c'},
        'PREM11'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Planned_Submission_Date__c','Submitted__c','Submitted_Date__c','HA_Response_Received__c','Approved__c','HA_Approval_Date__c',
            'Date_HA_Approval_Notified__c','Rejected__c','HA_Rejection_Date__c','Client_Notification_Date__c','Was_client_notification_within_10_days__c','Tracking_system_updated__c',
            'eCTD_Submission_Ready_docs__c','eCTD_met_Publishing_deadlines__c','Submission_sent_to_Publishing_on_time__c','Submission_passing_first_time_validation__c','Submission_Procedure__c',
            'HA_Question_due_to_IQVIA_error__c','Late_Responsibility__c','Late_Reason_Text__c','pse__Actual_Hours__c'},
        'PUB20'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Planned_Submission_Date__c','Submitted__c','Submitted_Date__c','Was_client_notification_within_10_days__c','Tracking_system_updated__c',
            'eCTD_Submission_Ready_docs__c','eCTD_met_Publishing_deadlines__c','Submission_sent_to_Publishing_on_time__c','Submission_passing_first_time_validation__c','Submission_Procedure__c',
            'Late_Responsibility__c','Late_Reason_Text__c'},
        'PUB21'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Planned_Submission_Date__c','Submitted__c','Submitted_Date__c','Was_client_notification_within_10_days__c','Tracking_system_updated__c',
            'Submission_Procedure__c','Late_Responsibility__c','Late_Reason_Text__c'},
        'IND01'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Late_Responsibility__c','Late_Reason_Text__c'},
        'IND02'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Late_Responsibility__c','Late_Reason_Text__c'},
        'IND03'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','eCTD_Submission_Ready_docs__c','Late_Responsibility__c','Late_Reason_Text__c','pse__Actual_Hours__c'},
        'IND04'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Late_Responsibility__c','Late_Reason_Text__c','pse__Actual_Hours__c'},
        'IND05'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','eCTD_Submission_Ready_docs__c','Late_Responsibility__c','Late_Reason_Text__c','pse__Actual_Hours__c'},
        'IND07'=> new List<String>{'Health_Authority_Mandatory_Submission__c','Health_Authority_Deadline__c','Planned_Dispatch_Date__c','Dispatch_Date__c','Planned_Submission_Date__c','Submitted__c','Submitted_Date__c','HA_Response_Received__c','Approved__c','HA_Approval_Date__c',
            'Date_HA_Approval_Notified__c','Rejected__c','HA_Rejection_Date__c','Client_Notification_Date__c','Was_client_notification_within_10_days__c','Tracking_system_updated__c',
            'eCTD_Submission_Ready_docs__c','eCTD_met_Publishing_deadlines__c','Submission_sent_to_Publishing_on_time__c','Submission_passing_first_time_validation__c','Submission_Procedure__c',
            'HA_Question_due_to_IQVIA_error__c','Late_Responsibility__c','Late_Reason_Text__c'},
        'DD01'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Late_Responsibility__c','Late_Reason_Text__c'},
        'DD02'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Late_Responsibility__c','Late_Reason_Text__c'},
        'DD03'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Late_Responsibility__c','Late_Reason_Text__c'},
        'CTS01'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Planned_Submission_Date__c','Submitted__c','Submitted_Date__c','HA_Response_Received__c','Approved__c','HA_Approval_Date__c',
            'Date_HA_Approval_Notified__c','Rejected__c','HA_Rejection_Date__c','Client_Notification_Date__c','Was_client_notification_within_10_days__c','Tracking_system_updated__c',
            'eCTD_Submission_Ready_docs__c','eCTD_met_Publishing_deadlines__c','Submission_sent_to_Publishing_on_time__c','Submission_passing_first_time_validation__c',
            'HA_Question_due_to_IQVIA_error__c','No_of_docs_rejected_by_client__c','Reason_for_documents_rejected_at_client__c','No_of_critical_errors_in_IQVIA_doc__c','Reason_for_critical_errors_in_IQVIA__c',
            'No_of_non_critical_errors_in_IQVIA_doc__c','Reason_for_non_critical_errors_in_IQVIA__c','Dependency_for_Critical_Errors__c','Dependency_for_Non_Critical_Errors__c','Critical_or_Non_Critical_Deadline__c',
            'Late_Responsibility__c','Late_Reason_Text__c'},
        'CTS02'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Late_Responsibility__c','Late_Reason_Text__c'},
        'CTS03'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Late_Responsibility__c','Late_Reason_Text__c'},
        'CTS04'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Late_Responsibility__c','Late_Reason_Text__c'},
        'CTS05'=> new List<String>{'Planned_Dispatch_Date__c','Dispatch_Date__c','Late_Responsibility__c','Late_Reason_Text__c'}
        
    };
        
    /************************************************************************************************************
    // Service Line
    ************************************************************************************************************/
    public static final string SERVICE_LINE_CODE_LIT = 'LIT';
    
    /************************************************************************************************************
    // Map of month number to month name (3 letters) [medium month name format]
    ************************************************************************************************************/
    public static Map<Integer, String> monthNumberToMonthNameMediumFormatMap = (new Map<Integer, String>{ 1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'});
    
    /************************************************************************************************************
    // Map of frequency Repeat
    ************************************************************************************************************/    
    public static Map<String, Integer>  frequencyToRepeatMap = new Map<String, Integer>{
             'Bi-Annual (Twice a year)' => 10,
             'Bi-Monthly (Every two months)' => 30,
             'Bi-Weekly (Every two weeks)' => 120,
             'Every 9 Months' => 7,
             'Monthly' => 60,
             'Quarterly' => 20,
             'Weekly' => 260,
             'Yearly (Annual)' => 5,
             'N/A' => 0,
             'Other' => 0
        };
    /************************************************************************************************************
    Constant for IQVIAPSA-6864, IQVIAPSA-6865
    ************************************************************************************************************/  
    public static final string CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_QC = 'Date Draft Sent for QC';
    public static final string CONSTANT_SD_RUN_DATE_QC_COMPLETED = 'Date QC Completed';
    public static final string CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_MEDICAL_REVIEW = 'Date Draft sent for Medical Review';
    public static final string CONSTANT_SD_RUN_DATE_MEDICAL_REVIEW_COMPLETED = 'Date Medical Review completed';
    public static final string CONSTANT_SD_RUN_DATE_FINAL_DARFT_READY_FOR_SMT_REVIEW = 'Date Draft sent for SMT review';
    
    /************************************************************************************************************
    Constant for IQVIAPSA-6569, IQVIAPSA-6570, IQVIAPSA-6574
    ************************************************************************************************************/  
    public static final string CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_QC = 'Date_SVF_Draft_Sent_for_QC';
    public static final string CONSTANT_SIGNAL_DATE_QC_COMPLETED_SVF = 'Date_QC_Completed_SVF';
    public static final string CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_MEDICAL_REVIEW = 'Date_SVF_Draft_sent_for_Medical_Review';
    public static final string CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SVF = 'Date_Medical_Review_Completed_SVF';
    public static final string CONSTANT_SIGNAL_DATE_SVF_FINAL_DARFT_READY_FOR_SMT_REVIEW = 'Date_SVF_Final_DraftReady_for_SMT_Review';
    public static final string CONSTANT_SIGNAL_DATE_SER_DRAFT_FOR_QC = 'Date_SER_Draft_Sent_for_QC';
    public static final string CONSTANT_SIGNAL_DATE_QC_COMPLETED_SER = 'Date_QC_Completed_SER';
    public static final string CONSTANT_SIGNAL_DATE_SER_DRAFT_SENT_FOR_MEDICAL_REVIEW = 'Date_SER_Draft_sent_for_Medical_Review';
    public static final string CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SER = 'Date_Medical_Review_Completed_SER';
    public static final string CONSTANT_SIGNAL_DATE_SER_FINAL_DARFT_READY_FOR_SMT_REVIEW = 'Date_SER_Final_DraftReady_for_SMT_Review';
    /************************************************************************************************************
    // Map of frequency Days
    ************************************************************************************************************/   
    public static Map<String, Integer>  frequencyToDaysMap = new Map<String, Integer>{
            'Bi-Annual (Twice a year)' => 180,
            'Bi-Monthly (Every two months)' => 60,
            'Bi-Weekly (Every two weeks)' => 14,
            'Every 9 Months' => 270,
            'Monthly' => 30,
            'Quarterly' => 90,
            'Weekly' => 7,
            'Yearly (Annual)' => 365,
            'N/A' => 0,
            'Other' => 0
        };      
    /************************************************************************************************************
    // Map of Week Days
    ************************************************************************************************************/         
    public static Map<Integer, String> weekDayNumberToWeekDayMap= new Map<Integer, String>{ 0 => 'Sunday',1 =>'Monday',2 => 'Tuesday', 3 => 'Wednesday', 4 => 'Thursday', 5 =>'Friday', 6 => 'Saturday'};
        
    /************************************************************************************************************
    // Permission sets
    *************************************************************************************************************/
    static public final String RDS_ADMIN = 'RDS_ADMIN';
    static public final String RDS_SM_Edit = 'RDS_SM_Edit';
    static public final String RDS_Project_Manager_and_Functional_Lead = 'RDS_Project_Manager_and_Functional_Lead';
    
    /************************************************************************************************************
    // PSSF 
    *************************************************************************************************************/
    static public final String PSSF_OBJECT_API_NAME = 'PSSF__c';
    static public final String STATUS_DRAFT = 'Draft';
    static public final String STATUS_DRAFT_CHILD = 'Draft Child';
    static public final String NO_PROJECT = 'No Project';
            
    /************************************************************************************************************
    // QC Tracker form Vals for Gen and Takeda
    ************************************************************************************************************/
    public static Map<String, List<string>> aggRepValToQCFormTypeMap = new Map<String, List<string>>{
        'DSUR'=> new List<String>{'DSUR - Draft QC','DSUR - Appendices','DSUR - Review QC','DSUR-Line Listing QC (SARA Specialist)-Draft','DSUR - Final Draft QC','DSUR-Line Listing QC (SARA Specialist)-Final'},
        'ACO'=>  new List<String>{'ACO First Draft QC','ACO First Draft Appendices','ACO Review QC','ACO Line Listing QC-Draft','ACO line listing QC-Final','ACO Final Draft QC'},
        'PADER'=> new List<String>{'PADER - Draft (AR QC Reviewer)','PADER - Final Draft and Submission (AR QC Reviewer)','PADER - Line Listings/Tabulations/Databases-Draft','PADER - Line Listings/Tabulations/Databases-Final'},
        'PADER Annual'=> new List<String>{'PADER - Draft (AR QC Reviewer)','PADER - Final Draft and Submission (AR QC Reviewer)','PADER - Line Listings/Tabulations/Databases-Draft','PADER - Line Listings/Tabulations/Databases-Final'},
        'PADER Quaterly'=> new List<String>{'PADER - Draft (AR QC Reviewer)','PADER - Final Draft and Submission (AR QC Reviewer)','PADER - Line Listings/Tabulations/Databases-Draft','PADER - Line Listings/Tabulations/Databases-Final'},
        'PSUR'=> new List<String>{'PSUR - Draft (AR QC Reviewer)','PSUR - Appendices','PSUR - Line Listings/Tabulations/Databases-Draft','PSUR - Final Draft and Submission (AR QC Reviewer)','PSUR - Line Listings/Tabulations/Databases-Final'},
        'PSUR Addendum'=> new List<String>{'PSUR - Draft (AR QC Reviewer)','PSUR - Appendices','PSUR - Line Listings/Tabulations/Databases-Draft','PSUR - Final Draft and Submission (AR QC Reviewer)','PSUR - Line Listings/Tabulations/Databases-Final'},
        'RMP'=> new List<String>{'RMP First Draft Review QC','RMP Line Listings QC-Draft','RMP Review QC','RMP Final Review QC','RMP Line Listings QC- Final'},
        'RMP Update'=> new List<String>{'RMP First Draft Review QC','RMP Line Listings QC-Draft','RMP Review QC','RMP Final Review QC','RMP Line Listings QC- Final'},
        'Monthly LL'=> new List<String>{'Adhoc/6/3/2/Monthly/Weekly Line listing -Draft','Adhoc/6/3/2/Monthly/Weekly Line listing-Final'},
        'Monthly sPSUR LL'=> new List<String>{'Adhoc/6/3/2/Monthly/Weekly Line listing -Draft','Adhoc/6/3/2/Monthly/Weekly Line listing-Final'},
        'Weekly LLs'=> new List<String>{'Adhoc/6/3/2/Monthly/Weekly Line listing -Draft','Adhoc/6/3/2/Monthly/Weekly Line listing-Final'},
        '2 mo LL'=> new List<String>{'Adhoc/6/3/2/Monthly/Weekly Line listing -Draft','Adhoc/6/3/2/Monthly/Weekly Line listing-Final'},
        '3 mo LL'=> new List<String>{'Adhoc/6/3/2/Monthly/Weekly Line listing -Draft','Adhoc/6/3/2/Monthly/Weekly Line listing-Final'},
        '6 mo LL'=> new List<String>{'Adhoc/6/3/2/Monthly/Weekly Line listing -Draft','Adhoc/6/3/2/Monthly/Weekly Line listing-Final'},
        'IDE Progress Report'=> new List<String>{'IDE DEVICE - Draft (AR QC Reviewer)','IDE DEVICE - Appendices','IDE DEVICE- Final Draft and Submission (AR QC Reviewer)','IDE DEVICE - Review QC','IDE- Line listing QC (SARA specialist) - Draft','IDE- Line listing QC (SARA specialist) Final'},
        'Ad-hoc'=> new List<String>{'Adhoc/6/3/2/Monthly/Weekly Line listing -Draft','Adhoc/6/3/2/Monthly/Weekly Line listing-Final','Ad hoc final submission QC','Ad hoc draft QC'},
        'PBRER'=> new List<String>{'PBRER - Draft Appendices','PBRER - Draft General','PBRER - Draft QC of Sections 1-14, 19','PBRER - Draft QC of Sections 15-18','PBRER - Final Draft QC','PBRER - Review QC','PBRER-Line Listing QC (SARA Specialist)-Draft','PBRER-Line Listing QC (SARA Specialist)-Final'},
        'PBRER > 12 months'=> new List<String>{'PBRER - Draft Appendices','PBRER - Draft General','PBRER - Draft QC of Sections 1-14, 19','PBRER - Draft QC of Sections 15-18','PBRER - Final Draft QC','PBRER - Review QC','PBRER-Line Listing QC (SARA Specialist)-Draft','PBRER-Line Listing QC (SARA Specialist)-Final'},
        'PBRER 6 monthly'=> new List<String>{'PBRER - Draft Appendices','PBRER - Draft General','PBRER - Draft QC of Sections 1-14, 19','PBRER - Draft QC of Sections 15-18','PBRER - Final Draft QC','PBRER - Review QC','PBRER-Line Listing QC (SARA Specialist)-Draft','PBRER-Line Listing QC (SARA Specialist)-Final'},
        'PBRER annual'=> new List<String>{'PBRER - Draft Appendices','PBRER - Draft General','PBRER - Draft QC of Sections 1-14, 19','PBRER - Draft QC of Sections 15-18','PBRER - Final Draft QC','PBRER - Review QC','PBRER-Line Listing QC (SARA Specialist)-Draft','PBRER-Line Listing QC (SARA Specialist)-Final'}};

    /************************************************************************************************************
    // QC Tracker form Vals for Sandoz
    ************************************************************************************************************/      
    public static Map<String, List<string>> aggRepValToQCFormTypeMapForSandoz = new Map<String, List<string>>{
        'RMM Line-listing'=> new List<String>{'Adhoc/6/3/2/Monthly/Weekly Line listing-Final','Adhoc/6/3/2/Monthly/Weekly Line listing -Draft'},
        'Expert Statement'=>  new List<String>{'Expert Statement final draft QC','Expert Statement first draft QC'},
        'Declaration no RMP'=> new List<String>{'Declaration for renewal or new submission final draft QC ','Declaration for renewal or new submission first draft QC'},
        'Declaration no update or RMP Update'=> new List<String>{'Declaration for renewal or new submission final draft QC','Declaration for renewal or new submission first draft QC'},
        'LoC Query Response Response'=> new List<String>{'HA Response Final draft QC','HA Response First draft QC'},
        'RMP'=> new List<String>{'RMP First Draft Review QC','RMP Final Draft QC','HAB70901 Independent RMP QC'},
        'RMP Update'=> new List<String>{'RMP First Draft Review QC','RMP Final Draft QC','HAB70901 Independent RMP QC'},
        'Local RMP Update'=> new List<String>{'RMP First Draft Review QC','RMP Final Draft QC','HAB70901 Independent RMP QC'},
        'New Local RMP'=> new List<String>{'RMP First Draft Review QC','RMP Final Draft QC','HAB70901 Independent RMP QC'},
        'Targeted follow up Questionnaire'=> new List<String>{'Ad hoc final submission QC','Ad hoc draft QC'},
        'BR Assessment'=> new List<String>{'Ad hoc final submission QC','Ad hoc draft QC'},
        'License partner RMP Review'=> new List<String>{'Ad hoc final submission QC','Ad hoc draft QC'}
        };
          
    /************************************************************************************************************
    // Novasyte CRM
    ************************************************************************************************************/
	static public final String NOVASYTE_CRM = 'Novasyte CRM';
    
    /************************************************************************************************************
    // Variable for BCH_PSA_SendEmailForAR
    ************************************************************************************************************/
	static public final String PLANNED_STARTING_DATE = 'Planned Starting Date';
    static public final String PLANNED_DATE_FOR_QC_SENT = 'Planned Date for QC Sent';
    static public final String PLANNED_DATE_FOR_QC_COMPLETION = 'Planned Date for QC Completion';
    static public final String PLANNED_DATE_FOR_BRM_SENT = 'Planned Date for BRM Sent';
    static public final String PLANNED_DATE_FOR_MEDICAL_REVIEW_SENT = 'Planned Date for Medical Review Sent';
    static public final String PLANNED_DATE_FOR_MEDICAL_REVIEW_COMPLETION = 'Plnnd Date for Medical Review Cmpltn';
    static public final String REPORT_DUE_TO_IQVIA_OR_CLIENT_REG = 'Report Due to IQVIA or Client Reg';
    static public final String PLANNED_DATE_TO_REQUEST_DRAFT_LL = 'Planned Date to Request Draft LL';
    static public final String PLANNED_DATE_DRAFT_LL_TO_AUTHOR_CLIENT = 'Plnnd Date Draft LL to Author/Client';
    static public final String PRE_STRATRGY_PLANNED_DATE = 'Pre-Strategy Planned Date';
    static public final String STRATRGY_PLANNING_MTG_PLANNED_DATE = 'Strategy / Planning Mtg Planned Date';
    static public final String PRE_DRAFT_QC_REVIEW_PLANNED_DATE = 'Pre-draft QC Review Planned date';
    static public final String PRE_DRAFT_QC_DUE_DATE = 'Pre-draft QC due date';
    static public final String PRE_DRAFT_CLIENT_REVIEW_PLANNED_DATE = 'Pre-draft Client Review Planned date';
    static public final String PRE_DRAFT_CLIENT_REVIEW_DUE_DATE = 'Pre-draft Client Review due date';
    static public final String PLANNED_DATE_FINAL_LL_TO_AUTHOR_CLIENT = 'Plnnd Date: Final LL to Author/Client';
    static public final String LL_REVIEW_DUE = 'LL Review Due';
    static public final String LL_QC_DUE_DATE = 'LL QC Due Date';
    static public final String CLIENT_FIRST_DRAFT_DUE = 'Client First Draft Due';
    static public final String PLANNED_FIRST_DRAFT_COMMENTS_DUE = 'Planned First Draft Comments Due';
    static public final String FIRST_RTR_PLANNED_DATE = 'First RTR Planned Date';
    static public final String CLIENT_FINAL_DRAFT_DUE = 'Client Final Draft Due';
    static public final String PLANNED_FINAL_DRAFT_COMMENTS_DUE = 'Planned Final Draft Comments Due';
    static public final String SECOND_RTR_PLANNED_DATE = 'Second RTR Planned Date';
    static public final String INDEPENDENT_QC_PLANNED_DATE = 'Independent QC Planned date';
    static public final String INDEPENDENT_QC_DUE_DATE = 'Independent QC due date';
    static public final String EU_QPPV_DESIGNEE_REVIEW_PLANNED_DATE = 'EU QPPV/designee review Planned date';
    static public final String EU_QPPV_DESIGNEE_REVIEW_DUE_DATE = 'EU QPPV/designee review due date';
    static public final String IQVIA_PLANNED_DATE_FOR_SIGN_APPROVAL = 'IQVIA Planned Date for Sign/Approval';
    static public final String REPORT_DUE_TO_REG_AGENCY = 'Report Due to Reg Agency';
    static public final String PLANNED_DATE_FOR_BRM_COMPLETION = 'Planned Date for BRM Completion';
}
