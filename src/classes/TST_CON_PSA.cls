/**
 * This test class is used to test all methods in CON_PSA.
 * CON_PSA has no lines that needs to be tested.
 * version : 1.0
 */
@isTest
private class TST_CON_PSA {

    static testMethod void testAllPSAConstant() {
        Test.startTest();
        	CON_PSA con = new CON_PSA();
            String constant0 = CON_PSA.ASSIGNMENT_STATUS_TENTATIVE;
            String constant1 = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
            String constant2 = CON_PSA.ASSIGNMENT_STATUS_CLOSED;
            String constant3 = CON_PSA.ASSIGNMENT_REC_TYPE_RDS;
            String constant4 = CON_PSA.BUDGET_STATUS_DRAFT;
            String constant5 = CON_PSA.BUDGET_STATUS_OPEN;
            String constant6 = CON_PSA.BUDGET_STATUS_APPROVED;
            String constant7 = CON_PSA.BUDGET_STATUS_REJECTED;
            String constant8 = CON_PSA.BUDGET_TYPE_FIXED;
            String constant9 = CON_PSA.BUDGET_TYPE_FEE_FOR_SERVICE;
            String constant10 = CON_PSA.BUDGET_TYPE_FEE_FOR_SERVICECAP;
            String constant11 = CON_PSA.BUDGET_TYPE_FIXED_UNIT_PRICE;
            String constant12 = CON_PSA.BUDGET_TYPE_COMBINATION;
            String constant13 = CON_PSA.BILLING_EVENT_STATUS_DRAFT;
            String constant14 = CON_PSA.BILLING_EVENT_STATUS_RELEASED;
            String constant15 = CON_PSA.MILESTONE_REC_TYPE_BILLING;
            String constant16 = CON_PSA.MILESTONE_REC_TYPE_SERVICE;
            String constant17 = CON_PSA.MILESTONE_STATUS_PLANNED;
            String constant18 = CON_PSA.MILESTONE_STATUS_APPROVED;
            String constant19 = CON_PSA.MILESTONE_STATUS_COMPLETED;
            String constant20 = CON_PSA.MILESTONE_STATUS_CANCELED;
            String constant21 = CON_PSA.MILESTONE_BILLING_TYPE_UNIT_BASED;
            String constant22 = CON_PSA.MILESTONE_BILLING_TYPE_FEE_FOR_SERVICE;
            String constant23 = CON_PSA.MILESTONE_BILLING_TYPE;
            String constant24 = CON_PSA.MILESTONE_NON_BILLABLE;
            String constant25 = CON_PSA.OPPORTUNITY_STAGE_IDENTIFYING;
            String constant26 = CON_PSA.OPPORTUNITY_STAGE_QUALIFYING;
            String constant27 = CON_PSA.OPPORTUNITY_STAGE_DEVELOPING_PROPOSAL;
            String constant28 = CON_PSA.OPPORTUNITY_STAGE_DELIVERING_PROPOSAL;
            String constant29 = CON_PSA.OPPORTUNITY_STAGE_FINALIZING_DEAL;
            String constant30 = CON_PSA.OPPORTUNITY_STAGE_RECEIVED_ATP_LOI;
            String constant31 = CON_PSA.OPPORTUNITY_RECORD_TYPE_MANUAL;
            String constant32 = CON_PSA.OPPORTUNITY_RECORD_TYPE_CS_UPSELL;
            String constant33 = CON_PSA.OPPORTUNITY_RECORD_TYPE_RENEWAL;
            String constant34 = CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO;
            String constant35 = CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS;
        	String constant36 = CON_PSA.AGG_REPORT_REC_TYPE_GENERAL;
    		String constant37 = CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA;
    		String constant38 = CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE;
            String constant39 = CON_PSA.PROJ_NAME_SUFFIX;
            String constant40 = CON_PSA.PROJ_REC_TYPE_RDS_PROJECT;
            String constant41 = CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE;
            String constant42 = CON_PSA.PROJ_REC_TYPE_RDS_TEMPLATE;
            String constant43 = CON_PSA.PROJ_REC_TYPE_RDS_INTERNAL;
            String constant44 = CON_PSA.PROJ_TYPE_CUSTOMER;
            String constant45 = CON_PSA.PROJ_TYPE_INTERNAL;
            String constant46 = CON_PSA.PROJ_TYPE_ABSENCE;
            String constant47 = CON_PSA.PROJ_BILL_TYPE_FIXED;
            String constant48 = CON_PSA.PROJ_BUDGET_TYPE_FIXED;
            String constant49 = CON_PSA.PROJ_BUDGET_TYPE_FEE_FOR_SERVICE;
            String constant50 = CON_PSA.PROJ_BUDGET_TYPE_FEE_FOR_SERVICECAP;
            String constant51 = CON_PSA.PROJ_BUDGET_TYPE_FIXED_UNIT_PRICE;
            String constant52 = CON_PSA.PROJ_BUDGET_TYPE_COMBINATION;
            String constant53 = CON_PSA.PROJ_STAGE_STARTUP;
            String constant54 = CON_PSA.PROJ_STAGE_CONDUCT;
            String constant55 = CON_PSA.PROJ_STAGE_CLOSE_OUT;
            String constant56 = CON_PSA.PROJ_STAGE_COMPLETED;
            String constant57 = CON_PSA.PROJ_STAGE_ON_HOLD;
            String constant58 = CON_PSA.PROJ_STAGE_CANCELED;
            String constant59 = CON_PSA.PROJ_STAGE_Active;
            String constant60 = CON_PSA.PROJ_STAGE_Not_Active;
            String constant61 = CON_PSA.RESOURCE_ROLE_COORDINATOR;
            String constant62 = CON_PSA.RESOURCE_ROLE_FUNCTIONAL_LEAD;
            String constant63 = CON_PSA.RESOURCE_ROLE_LINE_MANAGER;
            String constant64 = CON_PSA.RESOURCE_ROLE_MEDICAL_SAFETY_ADVISOR;
            String constant65 = CON_PSA.RESOURCE_ROLE_PROJECT_MANAGER;
            String constant66 = CON_PSA.RESOURCE_ROLE_SPECIALIST_SENIOR;
            String constant67 = CON_PSA.RESOURCE_ROLE_SPECIALIST;
            String constant68 = CON_PSA.RESOURCE_ROLE_SPECIALIST_JUNIOR;
            String constant69 = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
            String constant70 = CON_PSA.RESOURCE_ROLE_QPPV_OR_DEPUTY;
            String constant71 = CON_PSA.RESOURCE_REQUEST_STATUS_DRAFT;
            String constant72 = CON_PSA.RESOURCE_REQUEST_STATUS_READY;
            String constant73 = CON_PSA.RESOURCE_REQUEST_STATUS_HOLD;
            String constant74 = CON_PSA.RESOURCE_REQUEST_STATUS_TENTATIVE;
            String constant75 = CON_PSA.RESOURCE_REQUEST_STATUS_ASSIGNED;
            String constant76 = CON_PSA.RESOURCE_REQUEST_STATUS_CANCELLED;
            String constant77 = CON_PSA.RESOURCE_REQUEST_REC_TYPE_RDS_REQUEST;
            String constant78 = CON_PSA.RDS_DELIVERABLE;
            String constant79 = CON_PSA.RDS_DELIVERABLE_TASK;
            String constant80 = CON_PSA.RDS_PROJECT_TASK;
            String constant81 = CON_PSA.RDS_DELIVERABLE_GENERAL;
            String constant82 = CON_PSA.RDS_TASK_AR;
            String constant83 = CON_PSA.RDS_TASK_CMC;
            String constant84 = CON_PSA.RDS_TEMPLATE_TASK;
            String constant85 = CON_PSA.TARGET_REC_TYPE_RDS_COUNTRY;
            String constant86 = CON_PSA.TARGET_REC_TYPE_RDS_PRODUCT_LINE;
            String constant87 = CON_PSA.TARGET_REC_TYPE_RDS_PROTOCOL;
            String constant88 = CON_PSA.TARGET_REC_TYPE_RDS_PV_AGREEMENT;
            String constant89 = CON_PSA.REGION_CORPORATE;
            String constant90 = CON_PSA.GROUP_CORPORATE;
            String constant91 = CON_PSA.TIME_PERIOD_TYPE_PERPETUAL;
            String constant92 = CON_PSA.TIME_PERIOD_TYPE_YEAR;
            String constant93 = CON_PSA.TIME_PERIOD_TYPE_QUARTER;
            String constant94 = CON_PSA.TIME_PERIOD_TYPE_CLAENDAR_QUARTER;
            String constant95 = CON_PSA.TIME_PERIOD_TYPE_MONTH;
            String constant96 = CON_PSA.TIME_PERIOD_TYPE_CLAENDAR_MONTH;
            String constant97 = CON_PSA.TIME_PERIOD_TYPE_WEEK;        
        	String constant98 = CON_PSA.AGG_REPORT_SECTION_REPORT_WRITING;
        	String constant99 = CON_PSA.AGG_REPORT_SECTION_LITR_REVIEW;
        	String constant100 = CON_PSA.AGG_REPORT_SECTION_MEETINGS;
        	String constant101 = CON_PSA.AGG_REPORT_SECTION_QC;
        	String constant102 = CON_PSA.AGG_REPORT_SECTION_BRM;
        	String constant103 = CON_PSA.AGG_REPORT_SECTION_MED_REVIEW;
        	String constant104 = CON_PSA.AGG_REPORT_SECTION_CLIENT_REG;
        	String constant105 = CON_PSA.AGG_REPORT_SECTION_REPORT_TAKEDA;
        	String constant106 = CON_PSA.AGG_REPORT_SECTION_LL;
        	String constant107 = CON_PSA.AGG_REPORT_SECTION_GENERAL;
        	String constant108 = CON_PSA.AGG_REPORT_SECTION_TAKEDA_RA_RESP_ONLY;
        	String constant109 = CON_PSA.AGG_REPORT_SECTION_SANOFI_PVS;
        	String constant110 = CON_PSA.AGG_REPORT_SECTION_SANOFI_GSO;
        	String constant111 = CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR;
        Test.stopTest();
        
    }
}