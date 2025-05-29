/**
* This test class is used to test all methods in ProxyProject trigger.
* version : 1.0
*/
@isTest
private class TST_DAOH_ProxyProject {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact con = UTL_TestData.createContact(acc.Id);
        insert con;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = 'Data Sciences';
        opp.Potential_Regions__c = 'Asia Pacific';
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        insert oppLineItem;  
    }
    
    static testMethod void testSetQIOLIId() { 
        Test.startTest();
        Opportunity opp = [Select id from Opportunity LIMIT 1];
        Proxy_Project__c proxyProject = UTL_TestData.createProxyProject(opp.id);
        insert proxyProject;
        proxyProject = [Select LI_OpportunityLineItem_Id__c from Proxy_Project__c LIMIT 1];
        proxyProject.LI_OpportunityLineItem_Id__c = opp.id;
        proxyProject.Project_Start_Date__c = System.today() - 2;
        proxyProject.Project_End_Date__c = System.today() + 2;
        update proxyProject;
        proxyProject = [Select QI_OpportunityLineItem_Id__c from Proxy_Project__c LIMIT 1];
        OpportunityLineItem oli = [Select id from OpportunityLineItem LIMIT 1];
        System.assertEquals(proxyProject.QI_OpportunityLineItem_Id__c, oli.id);
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateSurveyPIC() {
        Test.startTest();
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            Proxy_Project__c proxyProject = UTL_TestData.createProxyProject(opp.id);
            proxyProject.Record_Type_Name__c = 'Engagement';
            insert proxyProject;
            Client_Sat_Survey__c clientSatSurvey = new Client_Sat_Survey__c();
            clientSatSurvey.Opportunity__c = opp.Id;
            clientSatSurvey.Survey_Recipient_1__c = con.Id;
            insert clientSatSurvey;
            proxyProject.Delivery_PIC_Name__c = 'Test User';
            update proxyProject;
        Test.stopTest();
    }
}