/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CRM_Show_Address_Message
 */
@isTest
public class TST_CNT_CRM_Show_Address_Message {
	/**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup(){
        Account acc = UTL_TestData.createAccount();
        acc.Name = 'Test Account for Validated Add';
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        for(Integer index = 0; index < addressList.size(); index++) {
            addressList[index].MDM_Validation_Status__c = 'Validated';
            addressList[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId(); 
        }
        insert addressList;
    }
    
   /**
     * test method for testing the getValidatedAddress Method.
     */  
   @isTest
   static void testgetValidatedAddress(){
        List<Account> account = [SELECT id,Name FROM Account WHERE Name = 'Test Account for Validated Add'];
        Opportunity Opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        Boolean actual;
        Boolean expected = false;
		String result;
        Test.startTest();
        actual = CNT_CRM_Show_Address_Message.getValidatedAddress(account[0].id);
		result = CNT_CRM_Show_Address_Message.getOpportunityDetails(Opp.id);
        Test.stopTest();
        System.assertEquals(expected,actual);
    }
}