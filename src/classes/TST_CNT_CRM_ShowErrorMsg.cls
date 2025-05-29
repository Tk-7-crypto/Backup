@isTest
public class TST_CNT_CRM_ShowErrorMsg {
    
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
    
    @isTest
    public static void testGetQueryResult(){
        String recordId = String.valueOf([SELECT Id FROM Opportunity][0].Id);
        String queryText = 'SELECT Id FROM Proxy_Project__c WHERE Record_Type_Name__c = \'Project\' AND Opportunity__c =:recordId AND QI_OpportunityLineItem_Id__c =null';
        
        Test.startTest();
        Boolean result = CNT_CRM_ShowErrorMsg.getQueryResult(recordId, queryText);
        System.assertEquals(true,result);
        Test.stopTest();
    }
}