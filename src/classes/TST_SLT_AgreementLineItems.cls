/*
 * Version       : 1.0
 * Description   : This test class is used for Select AgreementLineItems
 */
@isTest
private class TST_SLT_AgreementLineItems {
     
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;        
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Related_Opportunity__c = opp.Id;
        insert agreement;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        Apttus__AgreementLineItem__c agreementLineItem = UTL_TestData.createAgreementLineItem(agreement.Id, product.Id);
        agreementLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        List<Apttus__AgreementLineItem__c> agreementLineItemList = UTL_TestData.createAgreementLineItems(agreement.Id);
        agreementLineItemList.add(agreementLineItem);									
        insert agreementLineItemList;
    }
     
       
    @isTest
    static void testSelectByIds() {
        
        Apttus__AgreementLineItem__c ali = [SELECT Id FROM Apttus__AgreementLineItem__c LIMIT 1];
        Set<String> aliFieldSet = new Set<String> {CON_CPQ.ID};
            
        Test.startTest();
            List<Apttus__AgreementLineItem__c> agreementLineItemList = new SLT_AgreementLineItems().selectByIds(new Set<Id> { ali.Id }, aliFieldSet);
        Test.stopTest();
        
        System.assertEquals(agreementLineItemList.size() > 0, true, 'agreementLineItem exists');
    }
    
    @isTest
    static void testSelectByAgreementIds() {
        
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
        Set<String> aliFieldSet = new Set<String> {CON_CPQ.ID};
            
        Test.startTest();
            List<Apttus__AgreementLineItem__c> agreementLineItemList = new SLT_AgreementLineItems().selectByAgreementIds(
                new Set<Id> {agreement.Id}, aliFieldSet);
        Test.stopTest();
        
        System.assertEquals(agreementLineItemList.size() > 0, true, 'agreementLineItem exists');
    }
    
    @isTest
    static void testSelectSchedule1ByAgreementIds() {
        
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
        Apttus__AgreementLineItem__c agreementLineItem = UTL_TestData.createAgreementLineItem(agreement.Id, null);
        agreementLineItem.Schedule1_Id__c = CON_CLM.FILE_NAME_SCHEDULE1;
        insert agreementLineItem;        
        Set<String> aliFieldSet = new Set<String> {CON_CPQ.ID};
            
        Test.startTest();
            List<Apttus__AgreementLineItem__c> agreementLineItemList = new SLT_AgreementLineItems().selectSchedule1ByAgreementIds(
                new Set<Id> {agreement.Id}, aliFieldSet);
        Test.stopTest();
        
        System.assertEquals(agreementLineItemList.size() == 1, true, 'agreementLineItem exists for schedule1');
    }
	
    @isTest
    static void testSelectByAgreementId() {
        
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
															   
            
        Test.startTest();
            List<Apttus__AgreementLineItem__c> agreementLineItemList = new SLT_AgreementLineItems().selectByAgreementId(agreement.ID);
																			 
        Test.stopTest();
        
        System.assertEquals(agreementLineItemList.size() > 0, true, 'agreementLineItem exists');
    }
    
}