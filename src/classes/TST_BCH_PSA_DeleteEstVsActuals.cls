@isTest
public with sharing class TST_BCH_PSA_DeleteEstVsActuals {
    
    @testSetup
    static void setupTestData(){
        //contact
        Contact contact = UTL_PSA_TestData.createResources(1,false)[0];
        insert contact;
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        insert parentproject;
        
        // project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        project.pse__Project_Manager__c = contact.id;
        project.Service_Line_Lead__c = contact.id;
        insert project;
        
        //permission control
        List<Id> userIds = new List<Id>();
        userIds.add(UserInfo.getUserId());
        pse__region__c rgn = [SELECT Id, Name from pse__region__c WHERE Id = :project.pse__region__c LIMIT 1];
        
        pse__Permission_Control__c pc = UTL_PSA_TestData.createPermissionControls(userIds, rgn, false)[0]; 
        pc.CurrencyIsoCode = project.CurrencyIsoCode;
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
        
        //resource request
        pse__Resource_Request__c resourcerequest = UTL_PSA_TestData.createResourceRequests(1,false)[0];
        resourcerequest.CurrencyIsoCode = project.CurrencyIsoCode;
        resourcerequest.pse__Resource_Request_Name__c = 'Test request 1';
        resourcerequest.pse__Project__c = project.id;
        resourcerequest.pse__Start_Date__c = project.pse__start_date__c;
        resourcerequest.pse__End_Date__c = project.pse__start_date__c.addDays(1);
        resourcerequest.pse__Region__c = project.pse__Region__c;
        resourcerequest.pse__Group__c = project.pse__Group__c;
        resourcerequest.pse__Resource_Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        resourcerequest.pse__Requested_Bill_Rate__c = 200.0;
        resourcerequest.pse__SOW_Hours__c = 500;
        resourcerequest.pse__Planned_Bill_Rate__c = 200.0;
        resourcerequest.pse__Notes__c = 'Test';
        resourcerequest.pse__Status__c = CON_PSA.RESOURCE_REQUEST_STATUS_DRAFT;
        resourcerequest.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Resource_Request__c', CON_PSA.RESOURCE_REQUEST_REC_TYPE_RDS_REQUEST); 
        insert resourcerequest;
        
        //assignment
        List<Contact> resList = new List<Contact>();
        resList.add(contact);
        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(resList, project, false)[0];
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        insert assignment;
        
        pse__Est_Vs_Actuals__c act = new pse__Est_Vs_Actuals__c();
        act.Name = 'Test EVA';
        act.pse__Start_Date__c = Date.newInstance(2020, 07, 25);
        act.pse__End_Date__c = Date.newInstance(2022, 07, 22);
        act.pse__Actual_Hours__c = 8;
        act.pse__Estimated_Hours__c = 5;
        act.pse__Resource_Request__c = resourcerequest.Id;
        insert act;
    }
    
    @isTest
    static void testExecuteBatch(){
        Test.startTest();
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'RDS_Admin'];
        List<PermissionSetAssignment> psaList = [Select id from PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() AND PermissionSetId =:ps.Id];
        if(psaList.size() == 0){
            insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
        }
        
        List<User> userList = UTL_TestData.createUser('Sales User', 2);
        userList[0].FirstName = 'TestRunner';
        userList[0].SUBREGION__c = 'United States of America';
        userList[0].IsActive = true;
        userList[1].FirstName = 'Test2';
        userList[1].SUBREGION__c = 'United States of America';
        userList[1].IsActive = true;
        insert userList;
        insert new PermissionSetAssignment(AssigneeId =userList[0].Id,PermissionSetId = ps.Id);
        User testRunner = userList[0];
        System.runAs(testRunner) 
        {
            List<pse__Resource_Request__c> rr = [SELECT Id, Name FROM pse__Resource_Request__c LIMIT 100];
            delete rr;
            Database.executeBatch(new BCH_PSA_DeleteEstVsActuals(), 1);
            test.stopTest();
            List<pse__Est_Vs_Actuals__c> acAfter = [SELECT Id, Name, pse__Assignment__c, pse__Resource_Request__c, pse__Start_Date__c FROM pse__Est_Vs_Actuals__c LIMIT 1];
            System.assertEquals(1, acAfter.size(), 'Tested');
        }
    }
} 
