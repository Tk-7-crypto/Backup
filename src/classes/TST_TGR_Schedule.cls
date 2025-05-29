/**
 * This test class is used to test Assignment Trigger.
 * This is the main Test class for Assignment Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_Assignment.cls as well as TST_DAOH_PSA_Assignments.cls. 
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */

@isTest
private class TST_TGR_Schedule {
    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static pse__Proj__c anotherproject;
    static Service_Line__c serviceLine;
    static pse__Milestone__c milestones;
    static Contact contact;
    static Contact anothercontact;
    static pse__Resource_Request__c resourcerequest;
    static pse__Assignment__c assignment;
    
    @testSetup
    static void setupTestData (){
        
        List<sObject> toSave = new List<sObject>();    
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        System.debug('B:' + Limits.getQueries());
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        System.debug('C:' + Limits.getQueries());
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        insert project;
        
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.CurrencyIsoCode = project.CurrencyIsoCode;
        pc.pse__User__c = UserInfo.getUserId();
        pc.pse__Region__c = project.pse__region__c;
        pc.pse__Cascading_Permission__c = true;
        pc.Unit_Entry_Ops_Edit__c = true;
        pc.pse__Billing__c = true;
        pc.pse__Expense_Entry__c = true;
        pc.pse__Expense_Ops_Edit__c = true;
        pc.pse__Forecast_Edit__c = true;
        pc.pse__Forecast_View__c = true;
        pc.pse__Invoicing__c = true;
        pc.pse__Edit_Task_Manager__c = true;
        pc.pse__View_Task_Manager__c = true;
        pc.pse__Resource_Request_Entry__c = true;
        pc.pse__Skills_And_Certifications_Entry__c = true;
        pc.pse__Skills_And_Certifications_View__c = true;
        pc.pse__Staffing__c = true;
        pc.pse__Timecard_Entry__c = true;
        pc.pse__Timecard_Ops_Edit__c = true;
        pc.Unit_Entry_Ops_Edit__c = true;
        insert pc; 
        
        resourcerequest = new pse__resource_request__c();
        resourcerequest.CurrencyIsoCode = project.CurrencyIsoCode;
        resourcerequest.pse__Resource_Request_Name__c = 'Test request 1';
        resourcerequest.pse__Project__c = project.id;
    
        resourcerequest.pse__Start_Date__c = project.pse__start_date__c;
        resourcerequest.pse__End_Date__c = project.pse__start_date__c.addDays(1);
        resourcerequest.pse__Region__c = project.pse__Region__c;
        resourcerequest.pse__Group__c = project.pse__Group__c;
        resourcerequest.pse__Resource_Role__c = CON_PSA.RESOURCE_ROLE_PROJECT_MANAGER;
        resourcerequest.pse__Requested_Bill_Rate__c = 200.0;
        resourcerequest.pse__SOW_Hours__c = 500;
        resourcerequest.pse__Planned_Bill_Rate__c = 200.0;
        resourcerequest.pse__Notes__c = 'Test';
        resourcerequest.pse__Status__c = CON_PSA.RESOURCE_REQUEST_STATUS_DRAFT;
        resourcerequest.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Resource_Request__c', CON_PSA.RESOURCE_REQUEST_REC_TYPE_RDS_REQUEST); 
        insert resourcerequest;      
                                              
        pse__Schedule__c sch = new pse__Schedule__c();
        sch.pse__Start_Date__c = project.pse__Start_Date__c;
        sch.pse__End_Date__c = project.pse__End_Date__c;
        sch.pse__Monday_Hours__c = 8;
        sch.pse__Tuesday_Hours__c = 8;
        sch.pse__Wednesday_Hours__c = 8;
        sch.pse__Thursday_Hours__c = 8;
        sch.pse__Friday_Hours__c = 8;
        sch.pse__Saturday_Hours__c = 0;
        sch.pse__Sunday_Hours__c = 0;
        insert sch;
        resourcerequest.pse__Status__c = CON_PSA.RESOURCE_REQUEST_STATUS_HOLD;
        resourcerequest.pse__Preferred_Schedule__c = sch.id;
        update resourcerequest;
    }
    @IsTest
    static void testValidateDeletion() {
        pse__schedule__c sc = [select id from pse__schedule__c];
        delete sc;
    }

}