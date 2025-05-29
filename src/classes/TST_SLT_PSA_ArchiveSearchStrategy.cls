@isTest(isParallel=false)
private class TST_SLT_PSA_ArchiveSearchStrategy {
    @testSetup
    static void dataSetup() {
        UTL_PSA_TestData.createPermissionControls();
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1', RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct2;
        
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        Service_Line__c serviceline = new Service_Line__c(
            Name = CON_PSA.LITERATURE,
            Active__c=true,
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
        
        Archive_Search_Strategy__c archiveSearchStrategy = UTL_PSA_TestData.createArchiveSeachStrategy();
        archiveSearchStrategy.Account__c = acct2.id;
        archiveSearchStrategy.Project__c = project.id;
        archiveSearchStrategy.Product__c = product.id;
        archiveSearchStrategy.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        archiveSearchStrategy.Date_Annual_Search_Strategy_Due__c = System.today()-1;
        insert archiveSearchStrategy;
    }
    
    
    @istest
    static void testGetProjectMetricData(){
        LR_Project_Overview__c lrRecord = [Select Id from  LR_Project_Overview__c limit 1];
        List<Archive_Search_Strategy__c> archiveSSList= new List<Archive_Search_Strategy__c>();
        Archive_Search_Strategy__c archiveSS = [Select Id from Archive_Search_Strategy__c limit 1];
        Set<Id> archiveSSIdList = new Set<Id>();
        archiveSSIdList.add(archiveSS.id);
        
        Set<String> archiveSSFieldSet = new Set<String>{'Id', 'Name', 'Version_of_Search_Strategy__c', 'Date_Search_Strategy_got_Client_Approval__c','Date_Annual_Search_Strategy_Due__c', 'Comments__c','Inactive__c'};
        String whereClause = 'Inactive__c = false';
        String orderByField = 'CreatedDate';
        
        //test started
        Test.startTest();
        SLT_PSA_ArchiveSearchStrategy ass = new SLT_PSA_ArchiveSearchStrategy();
        ass.getSObjectFieldList();
        ass.getSObjectType();
        archiveSSList = ass.getArchiveSearchStrategies(archiveSSFieldSet);
        ass.getArchiveSSRecordsFromLRIdForListView(lrRecord.Id, archiveSSFieldSet);
        ass.getTotalNumberOfRecords(archiveSSIdList);
        ass.getArchiveSSByIdsForPagination(archiveSSIdList, archiveSSFieldSet, 1, 1);
        ass.getArchiveSSByLRIDS(new Set<Id>{lrRecord.Id}, archiveSSFieldSet, whereClause, orderByField);
        ass.getArchiveSSByLRID(new Set<Id>{lrRecord.Id}, archiveSSFieldSet);
        System.assertEquals(1, archiveSSList.size(), 'Assert archiveSSList');
        Test.stopTest();
    }
}
