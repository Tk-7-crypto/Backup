@isTest
public class TST_DAOH_PSA_Event_Journals {
@testsetup
    static void dataSetup() {
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
        project.pse__Account__c = acct2.Id;
        insert project;
        
        Drug__c prod = new Drug__c(Name = 'testProduct',
                                        Program__c = program.id,
                                   		Active__c = true,
                                        Service_Lines__c = 'Literature');
        insert prod;
        
        LR_Project_Overview__c lrRec = UTL_PSA_TestData.createLRProjectOverview();
        lrRec.Program__c = program.id;
        lrRec.Project__c = project.id;
        lrRec.Product__c = prod.id;
        lrRec.LR_Type__c = 'Local';
        insert lrRec;
        
        Event_Journals__c eventJournal = UTL_PSA_TestData.createEventJournal();
        eventJournal.LR_Project_Overview__c = lrRec.Id;
        eventJournal.Active__c = 'Yes';
        eventJournal.Inactive_since__c = Null;
        eventJournal.Account__c = acct2.id;
        eventJournal.Project__c = project.id;
        eventJournal.Product__c = prod.id;
        eventJournal.LR_Type__c = 'Local';
        eventJournal.LR_Project_Overview__c = lrRec.Id;
        
        eventJournal.Date_Last_Journal_Search_was_Performed__c = System.today();
        eventJournal.Review_Dates__c ='2022-01-01,2022-01-08,2022-01-15,2022-01-22,2022-01-29,2022-02-05,2022-02-12,2022-02-19,2022-02-26,2022-03-05,2022-03-12,2022-03-19,2022-03-26,2022-04-02,2022-04-09,2022-04-16,2022-04-23,2022-04-30,2022-05-07,2022-05-14,2022-05-21,2022-05-28,2022-06-04,2022-06-11,2022-06-18,2022-06-25,2022-07-02,2022-07-12,2022-08-06,2022-08-13,2022-08-20,2022-08-27,2022-09-03,2022-09-10,2022-09-17,2022-09-24,2022-10-01,2022-10-08,2022-10-15,2022-10-22,2022-10-29,2022-11-05,2022-11-12,2022-11-19,2022-11-26,2022-12-03,2022-12-10,2022-12-17,2022-12-24,2022-12-31,2023-01-07,2023-01-14,2023-01-21,2023-01-28,2023-02-04,2023-02-11,2023-02-18,2023-02-25,2023-03-04,2023-03-11,2023-03-18,2023-03-25,2023-04-01';
        insert eventJournal;
    }
    
    @istest
    static void testStrategy_testUpdate(){
        
        Test.startTest();
        try{
            Event_Journals__c TestForPast = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
            TestForPast.Frequency_of_Journal__c = 'Weekly';
            update TestForPast;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Date Next Journal Search is Due cannot be in the past') ? true : false;
        }
    }
    
    @istest
    static void testDeleteLREJRelationshipRecord(){
        Event_Journals__c newData = [Select Id,Name from Event_Journals__c WHERE Name = '123'];
        Test.startTest();
        delete newData;
        Test.stopTest();
    }
}
