@isTest
public class TST_SLT_LR_Search_Strategy_Relationship {
    @testSetup
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
        lrRec.Status__c = CON_PSA.LR_PROJECT_REVIEW_STATUS_ASSIGNED;
        lrRec.LR_Review_Period_Frequency__c = CON_PSA.LR_SIX_MONTHLY_FREQ;
        insert lrRec;
        
        
        Search_Strategy__c searchStrategy = UTL_PSA_TestData.createSeachStrategyOverview();
        Account account = UTL_PSA_TestData.accounts[0];
        searchStrategy.Account__c = acct2.id;
        searchStrategy.Project__c = project.id;
        searchStrategy.Product__c = prod.id;
        searchStrategy.LR_Type__c = 'Local';
        //searchStrategy.LR_Project_Overview__c = lrRec.Id;
        insert searchStrategy;
        
        LR_Search_Strategy_Relationship__c lrssList = UTL_PSA_TestData.createLRSearchStrategyRelationship();
        lrssList.LR_Project_Overview_M__c = lrRec.id;
        lrssList.Search_Strategy_M__c = searchStrategy.id;
        insert lrssList;
    }
    @isTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_LR_Project_Overview(true,true).getSObjectFieldList();
        Test.stopTest();
        System.assertNotEquals(0,fields.size());
    }
    @isTest
    static void testgetLrProjectOverView() {
        Set<String> fieldSet=new Set<String>{'Product__c','Project__c'};
            Test.startTest();
        set<Id> lrIds = new set<Id>();
        Set<Id> ssIds = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        Set<String> lrTypeSet = new Set<String>();
        List<LR_Project_Overview__c> lrRec = [SELECT Id, Account__c, Name, Product__c, Project__c, LR_Type__c FROM LR_Project_Overview__c LIMIT 1];
        lrIds.add(lrRec[0].id);
        accountIdSet.add( lrRec[0].Account__c );
        projectIdSet.add( lrRec[0].Project__c );
        productIdSet.add( lrRec[0].Product__c );
        lrTypeSet.add( lrRec[0].LR_Type__c );
        List< Search_Strategy__c> ssList = [ SELECT Id,Account__c, Project__c, Product__c,
                                                    LR_Type__c 
                                             FROM Search_Strategy__c 
                                             WHERE Account__c IN : accountIdSet
                                             AND Project__c IN : projectIdSet
                                             AND Product__c IN : productIdSet
                                             AND LR_Type__c IN : lrTypeSet
                                           ];
        ssIds.add(ssList[0].id);
        List<LR_Search_Strategy_Relationship__c> lrProjectOverView = new SLT_LR_Search_Strategy_Relationship().getLRSearchStrategyRelationship(fieldSet);
        List<LR_Search_Strategy_Relationship__c> lrProjOV = new SLT_LR_Search_Strategy_Relationship().getLRSSRelationshipFromLrId(lrIds, fieldSet);
        List<LR_Search_Strategy_Relationship__c> lrProjOVSS = new SLT_LR_Search_Strategy_Relationship().getLRSSRelationshipFromSsId(ssIds, fieldSet);
        Set<String> lrStatus = new Set<String>{'Completed', 'Cancelled'};
        List<LR_Search_Strategy_Relationship__c> lrSSRJunctionRecords = new SLT_LR_Search_Strategy_Relationship().getLRSSRelationshipData(accountIdSet, projectIdSet, productIdSet,lrTypeSet, fieldSet, lrStatus);
        List<LR_Search_Strategy_Relationship__c> lrSSRJunctionRecordsForLR = new SLT_LR_Search_Strategy_Relationship().getLRSSRelationshipDataWhereLRIdNull( fieldSet );
        List<LR_Search_Strategy_Relationship__c> lrSSRJunctionRecordsForss = new SLT_LR_Search_Strategy_Relationship().getLRSSRelationshipDataWhereSSIdNull( fieldSet);
        List<LR_Search_Strategy_Relationship__c> lrProjOVSSLR = new SLT_LR_Search_Strategy_Relationship().getLRSSRelationshipDataForEmailBatch(ssIds, fieldSet);
        Test.stopTest();
        System.assertNotEquals(0,lrProjectOverView.size());
    }
}
