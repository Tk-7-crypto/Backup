@isTest
public class TST_CNT_PSA_Search_Strategy_ListView {
	@testsetup
    static void dataSetup(){
        UTL_PSA_TestData.createPermissionControls();
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
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
        parentproject.pse__Account__c = acct2.Id;
        insert parentproject;
      
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
        lrRec.Account__c = acct2.id;
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
        searchStrategy.LR_Project_Overview__c = lrRec.Id;
        insert searchStrategy;
    }
    
    @istest
    static void testGetSearchStrategyData(){
        LR_Project_Overview__c lrRec = [Select Id from LR_Project_Overview__c  limit 1];
        String recordId = lrRec.id;
        List<Search_Strategy__c> searchStrategyList= new List<Search_Strategy__c>();
        List<Search_Strategy__c> searchStrategyList1= new List<Search_Strategy__c>();
        Test.startTest();
        searchStrategyList = CNT_PSA_Search_Strategy_ListView.getSearchStrategyData(recordId);
        String Data = CNT_PSA_Search_Strategy_ListView.getFilterData(lrRec.Id, 10,10,1);
        Test.stopTest();
        List<Search_Strategy__c> searchStrategy= new List<Search_Strategy__c>();
        Search_Strategy__c s1 = [Select id, Name, Version_of_Search_Strategy__c, Date_Search_Strategy_got_Client_Approval__c, Comments__c From Search_Strategy__c limit 1];
        searchStrategy.add(s1);
    }
    @isTest
    static void testGetLRData(){
        LR_Project_Overview__c lrRec = [Select Id from LR_Project_Overview__c limit 1];
        String recordId = lrRec.id;
        Test.startTest();
        LR_Project_Overview__c lrRec1 = new LR_Project_Overview__c();
        lrRec1 = CNT_PSA_Search_Strategy_ListView.getLRData(recordId);
        Test.stopTest();
        System.assertEquals(lrRec1.id, recordId);
    }
    
    @isTest
    static void testlrProjectOverviewValidation(){
        LR_Project_Overview__c lrRec = [Select Id from LR_Project_Overview__c  limit 1];
        String recordId = lrRec.id;
        Test.startTest();
        string result;
        result = CNT_PSA_Search_Strategy_ListView.lrProjectOverviewValidation(recordId);
        Test.stopTest();
        //System.assertEquals(lrRec1.id, recordId);
    }
}
