/**
* This test class is used to test Opportunity Product record triggered flow - CRM_Opp_Product_RecordTriggeredAfter
* version : 1.0
*/
@isTest
public class TST_CRM_Opp_Product_RecordTriggeredAfter {
    
     /**
* This method used to set up testdata
*/ 
    @testSetup
    static void dataSetup() {
        
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.id);
        insert opp;
        
        List<Contact> createContactsList = UTL_TestData.createContacts(acc.id,2);
        createContactsList[0].recordtypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        createContactsList[0].Salesforce_User__c = UserInfo.getUserId();
        createContactsList[1].recordtypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        createContactsList[1].Salesforce_User__c = UserInfo.getUserId();
        insert createContactsList;
        
        Product2 prod = UTL_TestData.createProduct();
        insert prod;
        
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(prod.id);
        insert pbe;
        
        
    }
    
    @isTest
    static void testCRMOppProduct(){
        
        List<Contact> con = [Select id from Contact Limit 2];
        Opportunity opp = [Select id from Opportunity Limit 1];
        PricebookEntry pbe = [Select id from PricebookEntry Limit 1];
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(opp.id , pbe.id);
        oli.SalesEngineer__c = con[0].Id;
        oli.Product_SalesLead__c = con[1].Id;
        Test.startTest();
        Insert oli;
        Test.stopTest();
        
    }
}