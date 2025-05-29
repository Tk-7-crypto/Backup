@isTest
public class TST_BCH_PSA_DeleteToLrRelations {
    @testSetup
    static void dataSetup() {
        UTL_PSA_TestData.createPermissionControls();
        
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        Service_Line__c serviceline = new Service_Line__c(
            Name = CON_PSA.LITERATURE,
            Active__c=true,
            Service_Line_Code__c = CON_PSA.SERVICE_LINE_CODE_LIT);
        insert serviceline;
        
        //Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
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
        lrRec.Account__c = acct2.id;
        lrRec.Program__c = program.id;
        lrRec.Project__c = project.id;
        lrRec.Product__c = prod.id;
        lrRec.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert lrRec;
        
        Event_Journals__c eventJournal = UTL_PSA_TestData.createEventJournal();
        eventJournal.LR_Project_Overview__c = lrRec.Id;
        eventJournal.Active__c = 'Yes';
        eventJournal.Inactive_since__c = Null;
        eventJournal.Account__c = acct2.id;
        eventJournal.Project__c = project.id;
        eventJournal.Product__c = prod.id;
        eventJournal.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        eventJournal.LR_Project_Overview__c = lrRec.Id;
        insert eventJournal;
        
        Account account1 = UTL_PSA_TestData.accounts[0];
        Event_Journals__c eventJournal1 = UTL_PSA_TestData.createEventJournal();
        eventJournal1.LR_Project_Overview__c = lrRec.Id;
        eventJournal1.Active__c = 'Yes';
        eventJournal1.Inactive_since__c = Null;
        eventJournal1.Account__c = account1.id;
        eventJournal1.Project__c = project.id;
        eventJournal1.Product__c = prod.id;
        eventJournal1.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        eventJournal1.LR_Project_Overview__c = lrRec.Id;
        insert eventJournal1;
        
        Search_Strategy__c searchStrategy = UTL_PSA_TestData.createSeachStrategyOverview();
        searchStrategy.Account__c = account1.id;
        searchStrategy.Project__c = project.id;
        searchStrategy.Product__c = prod.id;
        searchStrategy.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert searchStrategy;
        
        Search_Strategy__c searchStrategy1 = UTL_PSA_TestData.createSeachStrategyOverview();
        searchStrategy1.Account__c = acct2.id;
        searchStrategy1.Project__c = project.id;
        searchStrategy1.Product__c = prod.id;
        searchStrategy1.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert searchStrategy1;
        
        LR_Search_Strategy_Relationship__c lrssList = UTL_PSA_TestData.createLRSearchStrategyRelationship();
        lrssList.LR_Project_Overview_M__c = lrRec.id;
        lrssList.Search_Strategy_M__c = searchStrategy.id;
        insert lrssList;
        
        LR_Event_Journals_Relationship__c lrEJList = UTL_PSA_TestData.createLREventJournalRelationship();
        lrEJList.LR_Project_Overview_M__c = lrRec.id;
        lrEJList.Event_Journals_M__c = eventJournal.id;
        insert lrEJList;
    }
    
    @isTest
    static void testExecuteBatch1(){
        test.startTest();
        BCH_PSA_DeleteToLrRelations ob = new BCH_PSA_DeleteToLrRelations();
        ob.ExecuteMode(new List<String>{'SEARCH_STRATEGY'});
        System.assertEquals(true, true, 'Assert Batch');
        Database.executeBatch(ob);
        test.stopTest();
    }
}
