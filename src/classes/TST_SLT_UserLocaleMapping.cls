@isTest
public class TST_SLT_UserLocaleMapping {
	/**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        upsert new Delivery_Country_Mapping__c(ISOCODE__c='IN',Name='India');
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        
        Contact testContact1 = UTL_TestData.createContact(newAccount.id);
        testContact1.Disposition__c = 'Test Disposition';
        testContact1.LastName = 'test name';
        testContact1.RecordtypeId = CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT;
        testContact1.EmployeeNumber__c = '8876767';
        testContact1.Country__c = 'IN';
        testContact1.Email = 'test2@metacube.com';
        testContact1.Create_Chatter_user__c = true;
        testContact1.SN_Ticket__c = 'Test';
        insert testContact1;
        Contact testContact2 = UTL_TestData.createContact(newAccount.id);
        testContact2.Disposition__c = 'Test Disposition';
        testContact2.LastName = 'Test Emp';
        testContact2.RecordtypeId = CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT;
        testContact2.EmployeeNumber__c = '876767';
        testContact2.Country__c = 'IN';
        testContact2.Email = 'test2@metacube.com';
        testContact2.SN_Ticket__c = 'Test';
        insert testContact2;
    }
    static testMethod void testM1() {   
        Contact cnt = [SELECT Id, AccountId FROM Contact where LastName = 'Test Emp' LIMIT 1];
        Test.startTest();
        cnt.Create_Chatter_user__c = true;
        update cnt;
        CNT_CRM_ContactToUser.fetchRecords('Contact','Country__c','','1');
        CNT_CRM_ContactToUser.fetchObjectsRecords('Contact',new List<String>{'Name'},'','1');
        CNT_CRM_ContactToUser.getPicklistValues('Contact','Country__c');
        CNT_CRM_ContactToUser.fetchUserAdditionalMapping(new List<String>{'IN'});
        CNT_CRM_ContactToUser.fetchPicklistValues('Contact','Country__c');
        Test.stopTest();
    }
}