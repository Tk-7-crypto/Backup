@isTest
private class TST_EXT_CRM_OpportunityRenewal_PDetail {
    private static testmethod void testRenewalTaskDetailWrapper(){
        EXT_CRM_OpportunityRenewal_PDetail.RenewalTaskDetailWrapper wr = new EXT_CRM_OpportunityRenewal_PDetail.RenewalTaskDetailWrapper(null, null);
        System.assert(wr.isShown == false);
    
    }
    
    private static testmethod void testDetailController(){
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
        
        List<Renewal_Task__c> rtList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(testAcc , 1);
        
        System.assertEquals(1, rtList.size());
        ApexPages.currentPage().getParameters().put('id' ,rtList[0].id );
        ApexPages.StandardController sc = new ApexPages.StandardController(rtList[0]);
        
        EXT_CRM_OpportunityRenewal_PDetail detailController = new EXT_CRM_OpportunityRenewal_PDetail(sc);
        
        System.assertEquals(1, detailController.rtdWrappperList.size());
        detailController.saveProducts();
        
        System.assertEquals(detailController.rt.Cloning_Status__c, CON_CRM_OpportunityRenewals.QUEUED_STATUS_STR);
        
    }
    
    private static testmethod void testDropAllProductsForlone(){
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
        
        List<Renewal_Task__c> rtList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(testAcc , 1);
        
        System.assertEquals(1, rtList.size());
        ApexPages.currentPage().getParameters().put('id' ,rtList[0].id );
        ApexPages.StandardController sc = new ApexPages.StandardController(rtList[0]);
        
        EXT_CRM_OpportunityRenewal_PDetail detailController = new EXT_CRM_OpportunityRenewal_PDetail(sc);    
        //set rtdWrappperList with empty list.
        List<EXT_CRM_OpportunityRenewal_PDetail.RenewalTaskDetailWrapper> ob = new List<EXT_CRM_OpportunityRenewal_PDetail.RenewalTaskDetailWrapper > ();
        detailController.saveProducts();       
        try{
            detailController.rt.Cloned_Opportunity__c =null;
            detailController.rt.Opportunity__c = null ;
            detailController.saveProducts();
        }catch(Exception e){
            
        }
        
    }
    
    private static testmethod void testDetailControllerException(){
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
        
        List<Renewal_Task__c> rtList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(testAcc , 1);
     
        System.assertEquals(1, rtList.size());
        ApexPages.currentPage().getParameters().put('id' ,rtList[0].id );
        ApexPages.StandardController sc = new ApexPages.StandardController(rtList[0]);
        
        EXT_CRM_OpportunityRenewal_PDetail detailController = new EXT_CRM_OpportunityRenewal_PDetail(sc);  
        detailController.rtdWrappperList.clear();
        //set rtdWrappperList with empty list.
        //List<EXT_CRM_OpportunityRenewal_PDetail.RenewalTaskDetailWrapper> ob = new List<EXT_CRM_OpportunityRenewal_PDetail.RenewalTaskDetailWrapper > ();
        detailController.saveProducts();
        
        System.assertEquals(detailController.rt.Cloning_Status__c, CON_CRM_OpportunityRenewals.QUEUED_STATUS_STR); 
    }
}