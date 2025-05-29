@isTest 
public with sharing class TST_DAOH_PSA_Search_Strategy {
    @testsetup
    static void dataSetup() {        
        Date newDate2 = Date.newInstance(2021, 2,22);
        UTL_PSA_TestData.createPermissionControls();

        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Literature',
            Active__c=true,
            Service_Line_Code__c = 'LIT');
        insert serviceline;
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct2;

        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Program__c = program.id;
        project.pse__Account__c = acct2.id;
        insert project;
        
        Drug__c prod = new Drug__c(Name = 'testProduct',
                                        Program__c = program.id,
                                   		Active__c = true,
                                        Service_Lines__c = 'Literature');
        insert prod;
        
        LR_Project_Overview__c lrRec = UTL_PSA_TestData.createLRProjectOverview();
        lrRec.Account__c = acct2.id;
        lrRec.Program__c = program.id;
        lrRec.Project__c = project.id;
        lrRec.Product__c = prod.id;
        lrRec.LR_Type__c = 'Local';
        lrRec.Search_Strategy_Created__c ='Yes';
        insert lrRec;
        
        Search_Strategy__c searchStrategy = UTL_PSA_TestData.createSeachStrategyOverview();
        Account account = UTL_PSA_TestData.accounts[0];
        searchStrategy.Account__c = acct2.id;
        searchStrategy.Project__c = project.id;
        searchStrategy.Product__c = prod.id;
        searchStrategy.LR_Type__c = 'Local';
        searchStrategy.Date_Annual_Search_Strategy_Due__c = System.today();
        searchStrategy.Date_Search_Strategy_got_Client_Approval__c = newDate2;
        searchStrategy.LR_Project_Overview__c = lrRec.Id;
        insert searchStrategy;
        
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.Object__c = 'Search_Strategy__c';
        psaEvent.Planned_Date_Field__c = 'Date_Annual_Search_Strategy_Due__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'Test Event';
        insert psaEvent;
    }
    
    @istest
    static void testStrategy_testUpdate(){
        Search_Strategy__c newData = [Select Name,Date_Search_Strategy_got_Client_Approval__c,Date_Annual_Search_Strategy_Due__c from Search_Strategy__c LIMIT 1];
        Date newDate = Date.newInstance(2022, 2, 21);
        Test.startTest();
        newData.Date_Annual_Search_Strategy_Due__c = newDate;
        update newData;
        Test.stopTest();
        Search_Strategy__c newData1 = [Select Name,Date_Search_Strategy_got_Client_Approval__c,Date_Annual_Search_Strategy_Due__c from Search_Strategy__c LIMIT 1];
        //System.assertEquals(Date.newInstance(2023,2,22),newData1.Date_Annual_Search_Strategy_Due__c);
    }
    
    @istest
    static void testStrategy_testDeleteLRSSRelationshipRecord(){
        Search_Strategy__c newData = [Select Name,Date_Search_Strategy_got_Client_Approval__c,Date_Annual_Search_Strategy_Due__c from Search_Strategy__c LIMIT 1];
        Test.startTest();
        delete newData;
        Test.stopTest();
    }
}
