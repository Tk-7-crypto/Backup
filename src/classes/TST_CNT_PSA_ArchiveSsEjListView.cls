@isTest
public class TST_CNT_PSA_ArchiveSsEjListView {
    
    @testsetup
    static void dataSetup(){
        UTL_PSA_TestData.createPermissionControls();
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct2;
        
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        Service_Line__c serviceline = new Service_Line__c(
            Name = CON_PSA.LITERATURE,
            Active__c = true,
            Service_Line_Code__c = CON_PSA.SERVICE_LINE_CODE_LIT);
        insert serviceline;
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = CON_PSA.PROJ_STAGE_STARTUP;
        parentproject.Program__c = program.id;
        parentproject.pse__Account__c = acct2.Id;
        insert parentproject;
        
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = CON_PSA.PROJ_STAGE_STARTUP;
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Program__c = program.id;
        project.pse__Account__c = acct2.Id;
        insert project;
        
        Drug__c product = new Drug__c(Name = 'testProduct',
                                      Program__c = program.id,
                                      Active__c = true,
                                      Service_Lines__c = CON_PSA.LITERATURE);
        insert product;
        
        LR_Project_Overview__c lrRecord = UTL_PSA_TestData.createLRProjectOverview();
        lrRecord.Program__c = program.id;
        lrRecord.Account__c = acct2.id;
        lrRecord.Project__c = project.id;
        lrRecord.Product__c = product.id;
        lrRecord.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert lrRecord;
        
        Archive_Search_Strategy__c archiveSearchStrategy = UTL_PSA_TestData.createArchiveSeachStrategy();
        archiveSearchStrategy.Account__c = acct2.id;
        archiveSearchStrategy.Project__c = project.id;
        archiveSearchStrategy.Product__c = product.id;
        archiveSearchStrategy.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        archiveSearchStrategy.LR_Project_Overview__c = lrRecord.Id;
        archiveSearchStrategy.Date_Annual_Search_Strategy_Due__c = System.today()-1;
        archiveSearchStrategy.Inactive__c = False;
        insert archiveSearchStrategy;
        
        Archive_Event_Journal__c archiveEventJournal = UTL_PSA_TestData.createArchiveEventJournal();
        archiveEventJournal.Active__c = 'Yes';
        archiveEventJournal.Inactive_since__c = Null;
        archiveEventJournal.Account__c = acct2.id;
        archiveEventJournal.Project__c = project.id;
        archiveEventJournal.Product__c = product.id;
        archiveEventJournal.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        archiveEventJournal.LR_Project_Overview__c = lrRecord.Id;
        archiveEventJournal.URL__c = 'Text';
        archiveEventJournal.Therapeutic_Area__c = 'Text2';
        archiveEventJournal.Subscription__c = 'Sub';
        archiveEventJournal.Regulatory_Requirement__c = 'Reg';
        archiveEventJournal.Periodicity__c = 'Ped';
        archiveEventJournal.Paper_Journal__c = 'Paper';
        archiveEventJournal.Country__c = 'AF';
        archiveEventJournal.Journal_Name__c = 'Journal';
        archiveEventJournal.Name = 'Name';
        archiveEventJournal.Inactive__c = False;
        insert archiveEventJournal;
    }
    
    @istest
    static void testGetArchiveEJData(){
        List<Archive_Event_Journal__c> archiveEventJournalList = new List<Archive_Event_Journal__c>();
        String sortBy = 'CreatedDate';
        String sortDirection = 'ASC';
        LR_Project_Overview__c lrRecord = [Select Id from LR_Project_Overview__c limit 1];
        String recordId = lrRecord.id;
        Test.startTest();
        archiveEventJournalList = CNT_PSA_ArchiveSsEjListView.getArchiveEJData(recordId);
        CNT_PSA_ArchiveSsEjListView.getAllArchiveEJRecordsForListView(recordId, 10,10,0,sortBy,sortDirection);
        System.assertEquals(1, archiveEventJournalList.size(), 'Assert archiveEjList');
        Test.stopTest();
    }
    
    @istest
    static void testGetArchiveSSData(){
        List<Archive_Search_Strategy__c> archiveSearchStrategyList= new List<Archive_Search_Strategy__c>();
        String sortBy = 'CreatedDate';
        String sortDirection = 'ASC';
        LR_Project_Overview__c lrRecord = [Select Id from LR_Project_Overview__c limit 1];
        String recordId = lrRecord.id;
        Test.startTest();
        archiveSearchStrategyList = CNT_PSA_ArchiveSsEjListView.getArchiveSSData(recordId);
        CNT_PSA_ArchiveSsEjListView.getAllArchiveSSRecordsForListView(recordId, 10,10,0,sortBy,sortDirection);
        System.assertEquals(1, archiveSearchStrategyList.size(), 'Assert archiveSsList');
        Test.stopTest();
    }
}
