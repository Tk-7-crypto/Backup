// Test class for controller class CNT_PSA_My_LR_Project_Overviews_ListView

@isTest(isParallel=false)
private class TST_CNT_PSA_My_LR_Project_Overviews {
    
    @testSetup
    static void dataSetup() 
    {
        //Permission Control
        UTL_PSA_TestData.createPermissionControls();
        
        //Contact
        Id contactTypeId = UTL_PSA_TestData.lookupRecordTypeId('Contact', CON_PSA.CONTACT_REC_TYPE_IQVIA_USER_CONTACT);
        Contact contact = UTL_PSA_TestData.createResources(1,false)[0];
        contact.RecordTypeId = contactTypeId;
        insert contact;
        
        //Program
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        //Service Line [Literature]
        Service_Line__c serviceline = UTL_PSA_TestData.createServiceLine(1, false)[0];
        serviceline.Name = CON_PSA.LITERATURE;
        serviceline.Service_Line_Code__c = CON_PSA.SERVICE_LINE_CODE_LIT;
        insert serviceline;
        
        //Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        parentproject.Program__c = program.id;
        insert parentproject;
        
        //Account
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct2;
        
        //Service Line Project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Program__c = program.id;
        project.pse__Account__c = acct2.Id;
        insert project;     
        
        //LR Project Overview
        LR_Project_Overview__c lrProjectOverview = UTL_PSA_TestData.createLRProjectOverview();
        lrProjectOverview.Program__c = program.id;
        lrProjectOverview.Project__c = project.id;
        lrProjectOverview.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert lrProjectOverview;
        
        //Assignment
        List<Contact> resList = new List<Contact>();
        resList.add(contact);
        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(resList, project, false)[0];
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.Active__c = true;
        assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        insert assignment;
    }
    
    
    //This is method used to get logged in user's LR Project Overviews who have active logged in user's assignment on project of LR Project Overview
    @IsTest
    static void testGetMyLRProjectOverviews() {
        Integer pageSize = 5;
        Integer pageNumber = 1;
        Integer totalRecords = 0;
        Test.startTest();
        String resultData = CNT_PSA_My_LR_Project_Overviews_ListView.getMyLRProjectOverviews(pageSize, pageNumber, totalRecords, false);
        Test.stopTest();
    }
}
 
