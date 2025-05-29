/**
 * This test class is used to test SRV_PSA_LR_Synch cls.
 * version : 1.0
*/
@isTest
public class TST_SRV_PSA_LR_Synch {
    @testSetup
    static void dataSetup(){
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
        
        Drug__c prod = new Drug__c(
            Name = 'testProduct', 
            Program__c = program.id,
            Active__c = true,
            Service_Lines__c = 'Literature');
        	insert prod;
        
        LR_Project_Overview__c lrRec = UTL_PSA_TestData.createLRProjectOverview();
        lrRec.Program__c = program.id;
        //lrRec.Account__c = acct2.id;
        lrRec.Project__c = project.id;
        lrRec.Product__c = prod.id;
        lrRec.LR_Type__c = 'Local';
        //lrRec.Account__c = acct2.id;
        insert lrRec;
        
        Search_Strategy__c searchStrategy = UTL_PSA_TestData.createSeachStrategyOverview();
        Account account = UTL_PSA_TestData.accounts[0];
        searchStrategy.Account__c = acct2.id;
        searchStrategy.Project__c = project.id;
        searchStrategy.Product__c = prod.id;
        searchStrategy.LR_Type__c = 'Local';
        searchStrategy.LR_Project_Overview__c = lrRec.Id;
        insert searchStrategy;
        
        Event_Journals__c eventJournal = UTL_PSA_TestData.createEventJournal();
        eventJournal.LR_Project_Overview__c = lrRec.Id;
        eventJournal.Active__c = 'Yes';
        eventJournal.Inactive_since__c = Null;
        eventJournal.Account__c = acct2.id;
        eventJournal.Project__c = project.id;
        eventJournal.Product__c = prod.id;
        eventJournal.LR_Type__c = 'Local';
        eventJournal.LR_Project_Overview__c = lrRec.Id;
        insert eventJournal;
    }
    
    @IsTest
    static void testDeleteDataofSearchStrategy(){
        List<Search_Strategy__c> ssRecList = [Select Id from Search_Strategy__c limit 2];
        Test.startTest();
            SRV_PSA_LR_Synch.deleteDataofSearchStrategy(ssRecList);
        Test.stopTest();
    }
    
    @IsTest
    static void testDeleteDataofLRSS(){
        List<LR_Search_Strategy_Relationship__c> lrssRecList = [Select Id from LR_Search_Strategy_Relationship__c limit 2];
        Test.startTest();
            SRV_PSA_LR_Synch.deleteDataofLRSS(lrssRecList);
        Test.stopTest();
    }
    
    @IsTest
    static void testDeleteDataofEventJournal(){
        List<Event_Journals__c> ejRecList = [Select Id from Event_Journals__c limit 2];
        Test.startTest();
            SRV_PSA_LR_Synch.deleteDataofEventJournal(ejRecList);
        Test.stopTest();
    }
    
    @IsTest
    static void testDeleteDataofLREJ(){
        List<LR_Event_Journals_Relationship__c> lrejRecList = [Select Id from LR_Event_Journals_Relationship__c limit 2];
        Test.startTest();
            SRV_PSA_LR_Synch.deleteDataofLREJ(lrejRecList);
        Test.stopTest();
    }
}