/**
 * This test class is used to test all methods in ProxyProject trigger.
 * version : 1.0
 */
@isTest
private class TST_DAO_ProxyProject {

    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        insert product;
        
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        insert oppLineItem;
        
        Proxy_Project__c proxyProject = UTL_TestData.createProxyProject(opp.id);
        insert proxyProject;
    }
    
    /**
     * This test method used to test setQIOLIId
     */ 
    static testMethod void testsetQIOLIId() { 
        Proxy_Project__c proxyProj = [Select LI_OpportunityLineItem_Id__c from Proxy_Project__c LIMIT 1];
        Opportunity opp = [Select id from Opportunity LIMIT 1];
        Test.startTest();
            proxyProj.LI_OpportunityLineItem_Id__c = opp.id;
            update proxyProj;
            
            proxyProj = [Select QI_OpportunityLineItem_Id__c from Proxy_Project__c LIMIT 1];
            OpportunityLineItem oli = [Select id from OpportunityLineItem LIMIT 1];
            
            system.assertEquals(proxyProj.QI_OpportunityLineItem_Id__c, oli.id);
        Test.stopTest();
    }   
}