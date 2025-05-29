/**
* This test class is used to test all methods in IQVIA trigger helper.
* version : 1.0
*/
@IsTest
private class TST_SLT_IQVIA_Agreement {
	@TestSetup
    private static void testIQAgreementInsert() {

        Account account = new Account(Name = 'IMS Health Global',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '1. Identifying Opportunity';
        oppList.add(newOpportunity);
        insert oppList;

        List<IQVIA_Agreement__c> lstAgreement = new List<IQVIA_Agreement__c>();
        IQVIA_Agreement__c agreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        agreement.Name = 'Test IQVIA Agreement';
        agreement.Related_Opportunity__c = oppList.get(0).Id;
        agreement.Account__c = account.Id;
        agreement.Services__c = 'FMV Navigator';
        lstAgreement.add(agreement);
        insert lstAgreement;
    }
    
    @isTest
    private static void testSetIQVIAAgreementNumber() {
        IQVIA_Agreement__c agreement = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement'];
        
        Test.startTest();
        List<IQVIA_Agreement__c> lstAgr = new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(new Set<Id>{agreement.Id}, 
         		new Set<String>{'Id', 'Name', 'Conga_Agreement_Id__c', 'Contract_Auto_Number__c','Version_Number__c'});
        Test.stopTest();
        
        System.assertEquals(1, lstAgr.size(), 'List of agreement should be returned from the method');
    }

    @isTest
    private static void testGetIQVIAAgreementDetails() {
        IQVIA_Agreement__c agreement = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement'];
        
        Test.startTest();
        IQVIA_Agreement__c agr = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreement.Id, 
         		new Set<String>{'Id', 'Name', 'Conga_Agreement_Id__c', 'Contract_Auto_Number__c','Version_Number__c'});
        Test.stopTest();
        
        System.assertEquals('Test IQVIA Agreement', agr.Name, 'Agreement Name should be return');
    }

    @isTest
    private static void testselectById() {
        IQVIA_Agreement__c agreement = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement'];
        
        Test.startTest();
        List<IQVIA_Agreement__c> lstAgr = new SLT_IQVIA_Agreement().selectById(new Set<Id>{agreement.Id});
        Test.stopTest();
        
        System.assertEquals(1, lstAgr.size(), 'List of agreement should be returned from the method');
    }
	
    @isTest
    private static void testGetAgreementListByConditions() {
        IQVIA_Agreement__c agreement = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement'];
        String condition = 'Id IN: agrIds';
        
        Test.startTest();
            List<IQVIA_Agreement__c> agreementList = new SLT_IQVIA_Agreement().getAgreementListByConditions(
                new Set<String>{'Id'}, null, new Set<Id>{agreement.Id},condition);
        Test.stopTest();
        
        System.assertNotEquals(0, agreementList.size(), 'The size must not be 0');         
    }
}