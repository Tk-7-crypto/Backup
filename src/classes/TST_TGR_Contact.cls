/**
* This test class is used to test Contact Trigger.
* version : 1.0
*/
@isTest
private class TST_TGR_Contact {
    
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() {
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        /*CSM Start*/
        Account acc = CSM_Util.createAccount();
          insert acc;
          Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
          insert cnt; 
        /*CSM End*/
    }
    
    /**
    * This test method used for insert Contact record
    */ 
    static testMethod void testInsertContact() {
        Account newAccount = [SELECT id FROM Account LIMIT 1];
        test.startTest();
        Contact newContact = UTL_TestData.createContact(newAccount.Id);
        insert newContact;
        test.stopTest();
        Contact existingContact = [SELECT Id, Invalid_Email_Address__c, Consented_to_Marketing_Emails__c FROM Contact LIMIT 1];
        System.assertEquals(true, existingContact.Invalid_Email_Address__c);
        System.assertEquals(null, existingContact.Consented_to_Marketing_Emails__c);
    }
    /**
    * This test method used for insert and update Case record for CSM Data Audit Log
    */ 
    static testMethod void testAuditforContact() {
     
        CNT_CSM_FieldHistoryTracking.saveFields('Contact','AccessToAllCasesOfTheAccou__c,AccountId,AssistantName,AssistantPhone,Birthdate,FlashAlertMessage__c,PreferredChannel__c,JobRole__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(null,'CaseTestContact2');
        insert cnt2;
        cnt2.JobRole__c = 'Analyst';
        cnt2.PreferredChannel__c = 'Email';
        cnt2.FlashAlertMessage__c = 'Message Test';
        cnt2.AccountId = acc.Id;
        update cnt2;
        Test.startTest();
        cnt2.JobRole__c = 'Director';
        update cnt2;
        cnt2.JobRole__c = null;
        update cnt2;
        CNT_CSM_FieldHistoryTracking.saveFields('Contact','AccessToAllCasesOfTheAccou__c,AccountId,AssistantName,AssistantPhone,JobRole__c,ReportsToId');
        cnt.ReportsToId = cnt2.Id;
        update cnt;
        Contact cnt3 = CSM_Util.createContact(null,'CaseTestContact3');
        insert cnt3;
        cnt.ReportsToId = cnt3.Id;
        update cnt;
        cnt.ReportsToId = null;
        update cnt;
        CNT_CSM_FieldHistoryTracking.saveFields('Contact','AccessToAllCasesOfTheAccou__c,AccountId,AssistantName,AssistantPhone,ReportsToId,MailingAddress');
        cnt.MailingCity = 'Bangalore';
        cnt.MailingCountry = 'India';
        cnt.MailingPostalCode = '560016';
        cnt.MailingState = 'Karnataka';
        cnt.MailingStreet = 'KB-11';
        update cnt;
        cnt.MailingCity = 'Paris';
        cnt.MailingCountry = 'France';
        cnt.MailingPostalCode = '500016';
        cnt.MailingState = 'Telangana';
        cnt.MailingStreet = 'TH-11';
        update cnt;
        cnt.MailingCity = null;
        cnt.MailingCountry = null;
        cnt.MailingPostalCode = null;
        cnt.MailingState = null;
        cnt.MailingStreet = null;
        update cnt;
        Test.stopTest();
    }
}