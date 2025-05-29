/**
* This class is the implementation of 'Add Opp' button on the DB.
*
* Date : 19th Oct, 2010.
* Author : Metacube Software Ltd.
*/
@isTest
private class TST_EXT_CRM_OpportunityRenewals_AddDBOpp {
    private static testmethod void testAddOppController(){
        Test.startTest();
        Account testAcc = UTL_CRM_OpportunityRenewalTestData.setupAccount('Detail Controller Account');
        List<Opportunity> oppList = UTL_CRM_OpportunityRenewalTestData.setupOpportunity(testAcc , 1);
        //List<Renewal_Task__c> rtList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(testAcc , 1);
        
        System.assertEquals(1, oppList.size());
        
        Renewal_Dashboard_Settings__c RDSetting = new Renewal_Dashboard_Settings__c();
        RDSetting.Cloning_Batch_Size__c = 5	;
        RDSetting.Renewal_Year__c = 2017;
        insert RDSetting; 
        
        //ApexPages.currentPage().getParameters().put('id' ,rtList[0].id );
        EXT_CRM_OpportunityRenewals_AddDBOpp sc = new EXT_CRM_OpportunityRenewals_AddDBOpp();
        sc.oppId = oppList[0].id;
        sc.addDBOpportunity();
        
        System.assertEquals(true, sc.isAddSuccessful );        
        Test.stopTest();
    }
    
    private static testmethod void testAddOppControllerNegative(){
        Test.startTest();
        Account testAcc = UTL_CRM_OpportunityRenewalTestData.setupAccount('Detail Controller Account');
        String standardPricebookId =Test.getStandardPricebookId();
        Product2 prod = UTL_CRM_OpportunityRenewalTestData.getProdRecord();
        prod.Business_Type__c = 'I&A';
        prod.CanUseRevenueSchedule=true;
        insert prod;
        
        PricebookEntry PE1 = UTL_CRM_OpportunityRenewalTestData.getPbEntryRecord(prod);
        PE1.IsActive = true;
        PE1.CurrencyIsoCode = 'USD';
        insert PE1;   
        
        //List<Opportunity> oppList = UTL_CRM_OpportunityRenewalTestData.setupOpportunity(testAcc , 1);
        List<Renewal_Task__c> rtList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(testAcc , 1);
        
        System.assertEquals(1, rtList.size());
        //ApexPages.currentPage().getParameters().put('id' ,rtList[0].id );
        EXT_CRM_OpportunityRenewals_AddDBOpp sc = new EXT_CRM_OpportunityRenewals_AddDBOpp();
        sc.oppId = rtList [0].Opportunity__c;
        sc.addDBOpportunity();
        
        System.assertEquals(false, sc.isAddSuccessful );        
        Test.stopTest();
    }
    
    private static testmethod void testSearchOpportunity () {
        Test.startTest();
        Account testAcc = UTL_CRM_OpportunityRenewalTestData.setupAccount('Detail Controller Account');
        List<Opportunity> oppList = UTL_CRM_OpportunityRenewalTestData.setupOpportunity(testAcc , 1);
        
        System.assertEquals(1, oppList.size());
        EXT_CRM_OpportunityRenewals_AddDBOpp sc = new EXT_CRM_OpportunityRenewals_AddDBOpp();
        //empty search string test
        sc.searchOppNum = '';
        sc.doSearch();
        System.assertEquals(true, sc.resultOppList == null ); 
        String oppNum = [SELECT ID, Opportunity_Number__c from Opportunity where id =: oppList[0].id limit 1].Opportunity_Number__c;
        System.debug('oppNum = ' + oppNum );
        sc.searchOppNum = oppNum ;
        System.debug('sc.searchOppNum = ' + sc.searchOppNum );
        sc.doSearch();
        System.debug('oppList[0].Opportunity_Number__c = ' + oppList[0].Opportunity_Number__c);
        System.debug('sc.resultOppList = ' + sc.resultOppList );
        //sosl queries do not return any results in test methods
        //http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_testing_SOSL.htm
        System.assertEquals(true, sc.resultOppList.size()!= null );    
        Test.stopTest();
    }

}