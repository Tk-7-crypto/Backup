/**
* This test class is used to test all methods in SAP Contact Domain class.
* version : 1.0
*/
@isTest
public class TST_TGRH_Address {
    
    /**
    * This test method used is test Address method.
    */ 
    static testMethod void testMethodForAddress() {
        CON_GLOBAL.RELEASE_MAY_2021 = UTL_GLOBAL.getCurrentReleaseVersion();
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        Test.startTest();
        Address__c TempAddress = new Address__c();
        TempAddress.Name = 'Test Address';
        TempAddress.Enabled_Sales_Orgs__c='IHA, IMS Health Rotkreuz [CH03]';
        TempAddress.Account__c=newAccount.Id;
        TempAddress.SAP_Reference__c = String.valueOf(495000);
        TempAddress.International_Name__c = 'Test Address Name';
        insert TempAddress;
        TempAddress.SAP_Reference__c = '123';
        TempAddress.MDM_Validation_Status__c = 'Validated';
        update TempAddress;
        Address__c TempAddress1 = new Address__c();
        TempAddress1.Name = 'Test Address 1';
        TempAddress1.Enabled_Sales_Orgs__c='IHA, IMS Health Rotkreuz [CH03]';
        TempAddress1.Account__c=newAccount.Id;
        TempAddress1.SAP_Reference__c = String.valueOf(4950000);
        TempAddress1.International_Name__c = 'Test Address Name 1';
        insert TempAddress1;
        TempAddress1.MDM_Validation_Status__c = 'Rejected';
        update TempAddress1;
        Test.stopTest();
    }
    
}