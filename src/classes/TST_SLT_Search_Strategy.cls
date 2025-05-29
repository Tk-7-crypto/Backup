@istest
public with sharing class TST_SLT_Search_Strategy {
    @testSetup
    static void dataSetup() {
        UTL_PSA_TestData.createPermissionControls();
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct2;

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
        parentproject.pse__Account__c = acct2.id;
        insert parentproject;
       
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
        lrRec.Program__c = program.id;
        lrRec.Project__c = project.id;
        lrRec.Product__c = prod.id;
        lrRec.LR_Type__c = 'Local';
        insert lrRec;
        
        Search_Strategy__c searchStrategy = UTL_PSA_TestData.createSeachStrategyOverview();
        Account account = UTL_PSA_TestData.accounts[0];
        searchStrategy.Account__c = acct2.id;
        searchStrategy.Project__c = project.id;
        searchStrategy.Product__c = prod.id;
        searchStrategy.LR_Type__c = 'Local';
        //searchStrategy.LR_Project_Overview__c = lrRec.Id;
        insert searchStrategy;
    }
	@isTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_Search_Strategy(true,true).getSObjectFieldList();
        Test.stopTest();
        System.assertNotEquals(0,fields.size());
    }
    @isTest
    static void testGetSearchStrategies() {
        Set<String> fieldSet = new Set<String>{'Id','Product__c','Project__c'};
        Test.startTest();
        LR_Project_Overview__c lrRec = [SELECT Id FROM LR_Project_Overview__c LIMIT 1];
        List<Search_Strategy__c> searchStrategies = new SLT_Search_Strategy().getSearchStrategiesBylRProjectOverViewIds( new Set<String>{ lrRec.Id }, fieldSet);
        List<Search_Strategy__c> searchStrategies1 = new SLT_Search_Strategy().getSearchStrategies( fieldSet );
        Test.stopTest();

        System.assertNotEquals(0,searchStrategies1.size());
    }
    
    @isTest
    static void testGetSearchStrategiesByIds() {
        Set<String> fieldSet = new Set<String>{'Id'};
        Search_Strategy__c ssRec = [SELECT Id FROM Search_Strategy__c LIMIT 1];
        Set<Id> ssIdToDelete = new Set<Id>();
        ssIdToDelete.add(ssRec.Id);
        Test.startTest();        
        List<Search_Strategy__c> ssListToDelete = new SLT_Search_Strategy().getSearchStrategiesByIds(ssIdToDelete, fieldSet);
        Test.stopTest();

        System.assertNotEquals(0,ssListToDelete.size());
    }
}
