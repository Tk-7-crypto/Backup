/*
* Name              : TST_CNT_PSA_CREATE_BD_PROJECT_OPP_SCREEN
* Created By        : Mahima Gupta
* Created Date      : 15 April, 2019
* Revision          : 
* Description       : Test Class for CNT_PSA_CREATE_BD_PROJECT_OPP_SCREEN apex class
*/
@isTest
private class TST_CNT_PSA_CREATE_BD_PROJECT_OPP_SCREEN {
    
    @testSetup
    static void setupTestData(){
        
        Opportunity NewOpportunityStage1 = new Opportunity (Name='Test Opp');
        NewOpportunityStage1.StageName = '1. Identifying Opportunity';
        NewOpportunityStage1.CloseDate = System.today()+1;
        NewOpportunityStage1.Budget_Available__c = 'Yes';
        NewOpportunityStage1.CurrencyIsoCode = 'USD';
        NewOpportunityStage1.LI_Opportunity_Id__c = 'gfGvhgb457Khdhnsh';
        insert NewOpportunityStage1;
        
        Opportunity NewOpportunityStage2 = new Opportunity (Name='Test Opp');
        NewOpportunityStage2.StageName = '2 - Verify Opportunity';
        NewOpportunityStage2.CloseDate = System.today();
        NewOpportunityStage2.Budget_Available__c = 'Yes';
        NewOpportunityStage2.CurrencyIsoCode = 'USD';
        NewOpportunityStage2.LI_Opportunity_Id__c = 'gfGhsgb7Kfdbhnsh';
        insert NewOpportunityStage2;
        
        Opportunity NewOpportunity2 = new Opportunity (Name='Test Opp 2');
        NewOpportunity2.StageName = '2 - Verify Opportunity';
        NewOpportunity2.CloseDate = System.today();
        NewOpportunity2.Budget_Available__c = 'Yes';
        NewOpportunity2.CurrencyIsoCode = 'USD';
        insert NewOpportunity2;
        
        List<Product2> prodList= new list<Product2>();
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZREP';
        prodList.add(product);
        Product2 product1 = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZREP';
        prodList.add(product1);
        insert prodList;
        
        list<PricebookEntry> pbEntryList = new list<PricebookEntry>();
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        PricebookEntry pbEntry1 = UTL_TestData.createPricebookEntry(product1.Id);
        pbEntryList.add(pbEntry);
        pbEntryList.add(pbEntry1);
        insert pbEntryList;
        
        list<OpportunityLineItem> oppLineItemList = new list<OpportunityLineItem>();
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(NewOpportunityStage2.Id, pbEntry.Id);
        OpportunityLineItem oppLineItem1 = UTL_TestData.createOpportunityLineItem(NewOpportunity2.Id, pbEntry1.Id);
        oppLineItem.PSA_Budget__c = null;
        oppLineItem1.PSA_Budget__c = '123asderfres';
        oppLineItemList.add(oppLineItem);
        oppLineItemList.add(oppLineItem1);
        insert oppLineItemList;
        
        list<OpportunityLineItemSchedule> oppLineItemssList = new list<OpportunityLineItemSchedule>();
        OpportunityLineItemSchedule olis =UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id); 
        OpportunityLineItemSchedule olis1 =UTL_TestData.createOpportunityLineItemSchedule(oppLineItem1.Id); 
        oppLineItemssList.add(olis);
        oppLineItemssList.add(olis1);
        insert oppLineItemssList; 
        
        list<Proxy_Project__c> projList = new list<Proxy_Project__c>();
        Proxy_Project__c  proj1 =UTL_TestData.createProxyProject(NewOpportunity2.Id);
        Proxy_Project__c  proj2 =UTL_TestData.createProxyProject(NewOpportunityStage2.Id);
        proj2.Record_Type_Name__c='BD_Project';
        projList.add(proj1);
        insert projList;
        
    }
    
    testmethod static void testValidateOppForProjectCreationForStage1() {
        Opportunity testOpportunity = [select id from opportunity where CloseDate != : System.today() limit 1];
        Test.startTest();
        List<String> validateOppForProjectCreation = CNT_PSA_CREATE_BD_PROJECT_OPP_SCREEN.validateOppForProjectCreation(testOpportunity.id);
        Test.stopTest();
        System.assertEquals('Opportunity stage is not valid for creating BD projects.BD Project can only be created between stage 2 , 3 and 4.', validateOppForProjectCreation[0]);
    }
    
    testmethod static void testValidateOppForProjectCreationForExternalId() {
        Opportunity testOpportunity = [select id, LI_Opportunity_Id__c from opportunity where CloseDate =: System.today() limit 1];
        Test.startTest();
        List<String> validateOppForProjectCreation = CNT_PSA_CREATE_BD_PROJECT_OPP_SCREEN.validateOppForProjectCreation(testOpportunity.id);
        Test.stopTest();
        //System.assertEquals(testOpportunity.LI_Opportunity_Id__c, validateOppForProjectCreation[0]);
    }
    
    testmethod static void testValidateOppForProjectCreationForComponentNull() {
        Opportunity testOpportunity = [select id from opportunity where LI_Opportunity_Id__c = null limit 1];     
        Test.startTest();
        List<String> validateOppForProjectCreation = CNT_PSA_CREATE_BD_PROJECT_OPP_SCREEN.validateOppForProjectCreation(testOpportunity.id);
        Test.stopTest();
        //System.assertEquals('Component is required to create BD  Project.', validateOppForProjectCreation[0]);
    }
       
    testmethod static void testGetComponentListData() {
        Opportunity testOpportunity = [select id from opportunity where CloseDate =: System.today() limit 1];  
        Test.startTest();
        Id componentListData = CNT_PSA_CREATE_BD_PROJECT_OPP_SCREEN.getComponentListData(testOpportunity.id);
        Test.stopTest();
        System.assertNotEquals(null, componentListData);
    }
    
    testmethod static void testGetLegacyOrgLink(){
        Test.startTest();
        Legacy_Org_Link__c legacyOrgLink = CNT_PSA_CREATE_BD_PROJECT_OPP_SCREEN.getLegacyOrgLink();
        Test.stopTest();
        System.assertNotEquals(null, legacyOrgLink.SetupOwnerId);
    }
    
    testmethod static void testSAPValidatedAddr(){
        Opportunity testOpportunity = [select id, LI_Opportunity_Id__c from opportunity where CloseDate =: System.today() limit 1];
        Test.startTest();
        List<String> validateOppForProjectCreation = CNT_PSA_CREATE_BD_PROJECT_OPP_SCREEN.validateOppForProjectCreation(testOpportunity.id);
        CNT_PSA_CREATE_BD_PROJECT_OPP_SCREEN.covering_method();
        Test.stopTest();
    }   
    
}