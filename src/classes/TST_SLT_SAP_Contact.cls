/*
 * Version       : 1.0
 * Description   : Test Class for SLT_SAP_Contact
 */
@isTest
public class TST_SLT_SAP_Contact {
    
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() {
    	Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        Address__c TempAddress = new Address__c();
        TempAddress.Name = 'Test Address';
        TempAddress.Enabled_Sales_Orgs__c='IHA, IMS Health Rotkreuz [CH03]';
        TempAddress.Account__c=newAccount.Id;
        TempAddress.SAP_Reference__c = String.valueOf(495000);
        TempAddress.International_Name__c = 'Test Address Name';
        insert TempAddress;
        SAP_Contact__c newSAPContact = New SAP_Contact__c();
        newSAPContact.Name= 'Test SAPContact 1';
        newSAPContact.Address__c = TempAddress.Id;
        newSAPContact.SAP_Contact_Number__c = String.valueOf(999999);
        insert newSAPContact;
    }
    
     /**
     * This method used to get SAP Contact by ID
     */    
    @IsTest
    static void testSelectBySapContactId() {
    	Map<Id, SAP_Contact__c> sapContactMap = new Map<Id, SAP_Contact__c>();
    	SAP_Contact__c sapContact = [SELECT Id FROM SAP_Contact__c WHERE Name = 'Test SAPContact 1'];
        Test.startTest();
        sapContactMap = new SLT_SAP_Contact().selectBySapContactId(new Set<Id> {sapContact.Id},new Set<String>{'Name'});
        Test.stopTest();
    }
   
}