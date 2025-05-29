/**
 * This test class is used to test all methods in CNT_CRM_ChangeCurrency Controller.
 * version : 1.0
 */
@isTest
private class TST_CNT_CRM_ChangeCurrency {
    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        upsert bs;
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        OpportunityLineItemSchedule olis =UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id); 
        insert olis; 
    }
    
    /**
     * test method for getSobjectFieldDetail.
     */
    static testmethod void testGetSobjectFieldDetail() {
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'TestOpportunity'];
        List<String> fieldList = new List<String>{'CurrencyIsoCode'};
        Test.startTest();
        List<ObjectFieldsWrapper> objectSelectedFieldList = new List<ObjectFieldsWrapper>();
        objectSelectedFieldList = CNT_CRM_ChangeCurrency.getSobjectFieldDetail('Opportunity', fieldList);
        Test.stopTest();
        System.assertEquals(true, objectSelectedFieldList.size() > 0);
    }
    
    /**
     * test method for changeCurrencyOfOpportunity.
     */
    static testmethod void testChangeCurrencyOfOpportunity() {
        Opportunity opp = [SELECT Id, Name,CloseDate FROM Opportunity WHERE Name = 'TestOpportunity'];
        Test.startTest();
            String errorMsg = CNT_CRM_ChangeCurrency.validateProxyObjectRecords(opp.id);
            CNT_CRM_ChangeCurrency.changeCurrencyOfOpportunity(opp.id, 'USD');
        Test.stopTest();
        System.assertEquals('USD', [SELECT Id, Name, CloseDate, CurrencyIsoCode FROM Opportunity WHERE Name = 'TestOpportunity'].get(0).CurrencyIsoCode);
    }
    
    /**
     * test method for Exception On ChangeCurrencyOfOpportunity.
     */
    static testmethod void testExceptionOnChangeCurrencyOfOpportunity() {
        Opportunity opp = [SELECT Id, Name,CloseDate FROM Opportunity WHERE Name = 'TestOpportunity'];
        Test.startTest();
        try{
            String errorMsg = CNT_CRM_ChangeCurrency.validateProxyObjectRecords(opp.id);
            CNT_CRM_ChangeCurrency.changeCurrencyOfOpportunity(opp.id, 'EUR');
        } catch(Exception e) {
            
        }
        Test.stopTest();
        System.assertEquals('USD', [SELECT Id, Name, CloseDate, CurrencyIsoCode FROM Opportunity WHERE Name = 'TestOpportunity'].get(0).CurrencyIsoCode);
    }
    
    /**
     * test method for Exception On GetSobjectFieldDetail.
     */
    static testmethod void testExceptionOnGetSobjectFieldDetail() {
        Test.startTest();
        try{
            List<String> fieldList = new List<String>{'CurrencyIsoCode'};
            List<ObjectFieldsWrapper> objectSelectedFieldList = new List<ObjectFieldsWrapper>();
        	objectSelectedFieldList = CNT_CRM_ChangeCurrency.getSobjectFieldDetail('Opportunities', fieldList);
        } catch(Exception e) {
            
        }
        Test.stopTest();
        System.assertEquals('USD', [SELECT Id, Name, CloseDate, CurrencyIsoCode FROM Opportunity WHERE Name = 'TestOpportunity'].get(0).CurrencyIsoCode);
    }
    
    /**
     * test method for validateProxyObjectRecords
     */
    static testmethod void testvalidateProxyObjectRecords() {
        Opportunity opp = [SELECT Id, Name,CloseDate FROM Opportunity WHERE Name = 'TestOpportunity'];
        String errorMsg;
        Test.startTest();
        Proxy_Pricing_Assistant__c proxyPA = new Proxy_Pricing_Assistant__c();
        proxyPA.Opportunity__c = opp.Id;
        proxyPA.LI_Record_Id__c = opp.Id;
        insert proxyPA;
        Proxy_BNF__c proxyBNF = new Proxy_BNF__c();
        proxyBNF.Opportunity__c = opp.Id;
        proxyBNF.LI_Record_Id__c = opp.Id;
        insert proxyBNF;
        Proxy_Project__c proxyProject = new Proxy_Project__c();
        proxyProject.Opportunity__c = opp.Id;
        proxyProject.LI_Record_Id__c = opp.Id;
        proxyProject.Record_Type_Name__c = 'Project';
        insert proxyProject;
        Proxy_SCM_Agreement__c proxySCMAgreement = new Proxy_SCM_Agreement__c();
        proxySCMAgreement.Opportunity__c = opp.Id;
        proxySCMAgreement.LI_Record_Id__c = opp.Id;
        insert proxySCMAgreement;
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        CNT_CRM_ChangeCurrency cnt = new CNT_CRM_ChangeCurrency(controller);
        errorMsg = CNT_CRM_ChangeCurrency.validateProxyObjectRecords(opp.id);
        Test.stopTest();
        System.assertEquals(true, errorMsg.length() > 0);
    }
}