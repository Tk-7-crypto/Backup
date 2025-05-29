/**
* This test class is used to test all methods in IQVIA trigger helper.
* version : 1.0
*/
@IsTest
private class TST_DAO_IQVIA_Agreement {
	@isTest
    private static void testIQAgreementInsert() {

        Account account = new Account(Name = 'IMS Health Global',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        Contact contact = new Contact(FirstName='test', Email='test@example.com', LastName ='lastname');
        contact.Account = account;
        insert contact;

        List<IQVIA_Agreement__c> lstAgreement = new List<IQVIA_Agreement__c>();
        IQVIA_Agreement__c agreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        agreement.Name = 'Test IQVIA Agreement';
        agreement.Primary_Contact__c = contact.Id;
        agreement.Account__c = account.Id;
        agreement.Services__c = 'FMV Navigator';
        lstAgreement.add(agreement);
        
        Test.startTest();
        	insert lstAgreement;
        	update lstAgreement;
        Test.stopTest();
    }
}