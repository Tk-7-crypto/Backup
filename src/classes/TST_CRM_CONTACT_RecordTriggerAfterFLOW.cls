/**
 * This test class is used to cover the record triggered flow on account in after context.
 * version : 1.0
 */
@isTest
public class TST_CRM_CONTACT_RecordTriggerAfterFLOW {

    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup(){
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        
        Contact testContact1 = UTL_TestData.createContact(newAccount.id);
        testContact1.Disposition__c = 'Test Disposition';
        insert testContact1;
    }
    
    @isTest
    public static void testCRMSubflowInvalidEmailInactiveReason() {
        Account newAccount = [SELECT id FROM Account LIMIT 1];
        Contact newContact = UTL_TestData.createContact(newAccount.Id);
        insert newContact;
        Test.startTest();
             newContact.Inactive_Reason__c = 'Invalid Email Address';
       		 update newContact;	
        Test.stopTest();
    }  
    
}