/**
* This test class is used to test all methods in SAP Contact Domain class.
* version : 1.0
*/
@isTest
public class TST_DAOH_SAP_Contact {
    
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
        newSAPContact.SAP_External_KEY__c = '123';
        newSAPContact.MDM_Validation_Status__c = 'Validated';
        update newSAPContact;
        TempAddress.MDM_Validation_Status__c = 'Rejected';
        update TempAddress;
        SAP_Contact__c newSAPContact1 = New SAP_Contact__c();
        newSAPContact1.Name= 'Test SAPContact 2';
        newSAPContact1.Address__c = TempAddress.Id;
        newSAPContact1.SAP_Contact_Number__c = String.valueOf(9999999);
        insert newSAPContact1;
        newSAPContact1.MDM_Validation_Status__c = 'Rejected';
        update newSAPContact1;
        Test.stopTest();
    }
    
}