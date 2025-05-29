/**
* This test class is used to test all methods in SAP Contact Domain class.
* version : 1.0
*/
@isTest
public class TST_TGR_SAP_Contact {
    
    /**
    * This test method used is test SAP Contact method.
    */ 
    static testMethod void testMethodForSapContact() {
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        Address__c TempAddress = new Address__c();
        TempAddress.Name = 'Test Address';
        TempAddress.Enabled_Sales_Orgs__c='IHA, IMS Health Rotkreuz [CH03]';
        TempAddress.Account__c=newAccount.Id;
        TempAddress.SAP_Reference__c = String.valueOf(495000);
        TempAddress.International_Name__c = 'Test Address Name';
        insert TempAddress;
        Test.startTest();
        SAP_Contact__c newSAPContact = New SAP_Contact__c();
        newSAPContact.Name= 'Test SAPContact 1';
        newSAPContact.Address__c = TempAddress.Id;
        newSAPContact.SAP_Contact_Number__c = String.valueOf(999999);
        insert newSAPContact;
        Test.stopTest();
    }
    
}