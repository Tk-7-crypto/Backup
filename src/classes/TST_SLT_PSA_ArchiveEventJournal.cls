@isTest(isParallel = false)
private class TST_SLT_PSA_ArchiveEventJournal {
    @testSetup
    static void dataSetup() {
        UTL_PSA_TestData.createPermissionControls();
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
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
        parentproject.pse__Account__c = acct2.id;
        insert parentproject;
        
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = CON_PSA.PROJ_STAGE_STARTUP;
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Program__c = program.id;
        project.pse__Account__c = acct2.id;
        insert project;
        
        Drug__c product = new Drug__c(Name = 'testProduct', Program__c = program.id, Active__c = true, Service_Lines__c = CON_PSA.LITERATURE);
        insert product;
        
        LR_Project_Overview__c lrRecord = UTL_PSA_TestData.createLRProjectOverview();
        lrRecord.Program__c = program.id;
        lrRecord.Project__c = project.id;
        lrRecord.Product__c = product.id;
        lrRecord.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert lrRecord;
        
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
        LR_Project_Overview__c lrRecord = [Select Id from  LR_Project_Overview__c limit 1];
        List<Archive_Event_Journal__c> archiveEJList = new List<Archive_Event_Journal__c>();
        Archive_Event_Journal__c archiveEJ = [Select Id from Archive_Event_Journal__c limit 1];
        Set<Id> archiveEJIdList = new Set<Id>();
        archiveEJIdList.add(archiveEJ.id);
        
        Set<String> archiveEJFieldSet = new Set<String>{'Id', 'Name', 'Country__c', 'Journal_Name__c', 'URL__c', 'Frequency_of_Journal__c','Date_Initial_Search_Started__c', 'Date_Last_Journal_Search_was_Performed__c', 'Date_Next_Journal_Search_is_Due__c', 'Inactive__c'};
        String whereClause = 'Inactive__c = false';
        String orderByField = 'CreatedDate';
        Test.startTest();
        SLT_PSA_ArchiveEventJournal aej = new SLT_PSA_ArchiveEventJournal();
        aej.getSObjectFieldList();
        aej.getSObjectType();
        archiveEJList = aej.getArchiveEJ(archiveEJFieldSet);
        aej.getArchiveEJRecordsFromLRIdForListView(lrRecord.Id, archiveEJFieldSet);
        aej.getTotalNumberOfRecords(archiveEJIdList);
        aej.getArchiveEJByIdsForPagination(archiveEJIdList, archiveEJFieldSet, 1, 1);
        aej.getArchiveEJByLRIDS(new Set<Id>{lrRecord.Id}, archiveEJFieldSet, whereClause, orderByField);
        System.assertEquals(1, archiveEJList.size(), 'Assert archiveEJList');
        Test.stopTest();
    }
}
