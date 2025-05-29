@isTest
public class TST_SLT_LR_Event_Journals_Relationship {
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
        project.pse__Account__c = acct2.Id;
        insert project;
        
        Drug__c prod = new Drug__c(Name = 'testProduct',
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
        insert eventJournal;
    }
    
    @IsTest
    static void testGetLREJRelationshipFromLrId(){
        LR_Project_Overview__c lrRec = [SELECT Id, Account__c, Project__c, Product__c, LR_Type__c, Program__c FROM LR_Project_Overview__c LIMIT 1];
        Set<String> lrEJFieldSet = new Set<String>{'Id', 'Event_Journals_M__c', 'LR_Project_Overview_M__c'};
        Set<Id> lrIdSet = new Set<Id>();
        lrIdSet.add(lrRec.Id);
        List<LR_Event_Journals_Relationship__c> leEjList = [Select Id From LR_Event_Journals_Relationship__c Where LR_Project_Overview_M__c IN :lrIdSet];
        Test.startTest();
        List<LR_Event_Journals_Relationship__c> lrEjRec = new SLT_LR_Event_Journals_Relationship().getLREJRelationshipFromLrId(lrIdSet, lrEJFieldSet);
        List<LR_Event_Journals_Relationship__c> lrEjRec2 = new SLT_LR_Event_Journals_Relationship().getLRSSRelationshipDataWhereLRIdNull(lrEJFieldSet);
        Test.stopTest();
        System.assertEquals(leEjList.size(), lrEjRec.size());
        System.assertEquals(0, lrEjRec2.size());
    }
    
    @IsTest
    static void testGetLREJRelationshipFromEJId(){
        Event_Journals__c ejRec = [Select Id from Event_Journals__c where Name = '123' limit 1];
        Set<String> lrEJFieldSet = new Set<String>{'Id', 'Event_Journals_M__c', 'LR_Project_Overview_M__c'};
        Set<Id> ejIdSet = new Set<Id>();
        ejIdSet.add(ejRec.Id);
        List<LR_Event_Journals_Relationship__c> leEjList = [Select Id From LR_Event_Journals_Relationship__c Where Event_Journals_M__c IN :ejIdSet];
        Test.startTest();
        List<LR_Event_Journals_Relationship__c> lrEjRec = new SLT_LR_Event_Journals_Relationship().getLREJRelationshipFromEJId(ejIdSet, lrEJFieldSet);
        List<LR_Event_Journals_Relationship__c> lrEjRec2 = new SLT_LR_Event_Journals_Relationship().getLREJRelationshipDataWhereEJIdNull(lrEJFieldSet);
        Test.stopTest();
        System.assertEquals(leEjList.size(), lrEjRec.size());
        System.assertEquals(0, lrEjRec2.size());
    }
    
    @IsTest
    static void testGetLREJRelationshipData(){
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        Set<String> lrTypeSet = new Set<String>();
        List<LR_Project_Overview__c> lrRec = [SELECT Id, Name, Account__c, Product__c, Project__c,LR_Type__c FROM LR_Project_Overview__c LIMIT 1];
        accountIdSet.add( lrRec[0].Account__c );
        projectIdSet.add( lrRec[0].Project__c );
        productIdSet.add( lrRec[0].Product__c );
        lrTypeSet.add( lrRec[0].LR_Type__c );
        Set<String> lrEJFieldSet = new Set<String>{'Id', 'Event_Journals_M__c', 'LR_Project_Overview_M__c'};
        Set<Id> ejIdSet = new Set<Id>();
        Test.startTest();
        Set<String> lrStatus = new Set<String>{'Completed', 'Cancelled'};
        List<LR_Event_Journals_Relationship__c> lrEjRec = new SLT_LR_Event_Journals_Relationship().getLREJRelationshipData(accountIdSet, projectIdSet, productIdSet, lrTypeSet, lrEJFieldSet, lrStatus);
        Test.stopTest();
    }

}
