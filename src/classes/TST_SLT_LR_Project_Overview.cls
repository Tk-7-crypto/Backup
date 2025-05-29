@istest
public class TST_SLT_LR_Project_Overview {
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
        insert lrRec;
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
        List<LR_Project_Overview__c> lrProjectOverView = new SLT_LR_Project_Overview().getLRProjectOverViews(fieldSet);
        LR_Project_Overview__c lrProjOV = new SLT_LR_Project_Overview().getLRProjectOverViewFROMlRProjectOverViewId(lrProjectOverView[0].Id, fieldSet);
        Test.stopTest();

        System.assertNotEquals(0,lrProjectOverView.size());
    }
    
    @isTest
    static void testGetLRProjectOverViewFROMProjectId() {
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        pse__Proj__c projectRec = [Select Id from pse__Proj__c where recordTypeId =:recTypeId limit 1];
        Set<Id> projectIdSet = new Set<Id>();
        projectIdSet.add(projectRec.Id);
        Set<String> fieldSet=new Set<String>{'Id'};
        Test.startTest();
        List<LR_Project_Overview__c> lrProjectOverView = new SLT_LR_Project_Overview().getLRProjectOverViewFROMProjectId(projectIdSet, fieldSet);
        Test.stopTest();
        
    }
    
    @isTest
    static void testgetLRProjectOverviewFromLRID() {
        //Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        LR_Project_Overview__c lrRec = [Select Id from LR_Project_Overview__c limit 1];
        Set<Id> LRIdSet = new Set<Id>();
        LRIdSet.add(LRRec.Id);
        Set<String> fieldSet=new Set<String>{'Id'};
        Test.startTest();
        List<LR_Project_Overview__c> lrProjectOverView = new SLT_LR_Project_Overview().getLRProjectOverviewFromLRID(LRIdSet, fieldSet);
        Test.stopTest(); 
    }
    
    @isTest
    static void testGetLRDataOnCriteria() {
        //Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        Set<String> lrTypeSet = new Set<String>();
        Set<String> lrStatus = new Set<String>{CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED, CON_PSA.LR_PROJECT_REVIEW_STATUS_CANCELLED};
        LR_Project_Overview__c lrRec = [Select Id, Account__c, Product__c, Project__c, LR_Type__c from LR_Project_Overview__c limit 1];
        projectIdSet.add(lrRec.Project__c);
        accountIdSet.add(lrRec.Account__c);
        productIdSet.add(lrRec.Product__c);
        lrTypeSet.add(lrRec.LR_Type__c);
        Set<String> fieldSet=new Set<String>{'Id'};
        Test.startTest();
        List<LR_Project_Overview__c> lrProjectOverView = new SLT_LR_Project_Overview().getLRDataOnCriteria(accountIdSet, projectIdSet, productIdSet, lrTypeSet, fieldSet, lrStatus);
        Test.stopTest(); 
    }
    
    @isTest
    static void testGetLRProjectOverViewFromProjectIdsForPagination() {
        Set<String> lrFieldSet = new Set<String> {'Id', 'Name'};
        Set<Id> projectIdSet = new Set<Id>();
        Integer pageSize = 5;
        Integer pageNumber = 1;
        Integer offset = (pageNumber - 1) * pageSize;
        LR_Project_Overview__c lrRec = [Select Id, Account__c, Product__c, Project__c, LR_Type__c from LR_Project_Overview__c limit 1];
        projectIdSet.add(lrRec.Project__c);
        Test.startTest();
        List<LR_Project_Overview__c> lrProjectOverviews = new SLT_LR_Project_Overview().getLRProjectOverViewFromProjectIdsForPagination(projectIdSet, lrFieldSet, pageSize, offset);
        System.assertEquals(lrProjectOverviews.size(), 1);
        Test.stopTest(); 
    }
}
