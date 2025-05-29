@isTest
public class TST_SLT_Agreement_Contacts {
    @testSetup
    public static void dataSetup() {
        Apttus__APTS_Agreement__c agreementPSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        Account account = new Account(Name = 'IMS Health Global',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        Contact contact = new Contact(FirstName='test', Email='test@example.com', LastName ='lastname');
        contact.Account = account;
        insert contact;

        List<Agreement_Contacts__c> agreementContactList = new List<Agreement_Contacts__c>();

        Agreement_Contacts__c agreementContactForPSA = TST_CLM_TestDataFactory.createAgreementContacts(agreementPSA.Id, false);
        agreementContactForPSA.Agreement__c = agreementPSA.Id;
        agreementContactForPSA.Contact__c = contact.Id;
        agreementContactForPSA.Type__c = 'Contact';
        agreementContactList.add(agreementContactForPSA);
        insert agreementContactList;
    }

    @isTest
    private static void testGetAgreementContactListByAgreementIdShouldReturnList() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        Agreement_Contacts__c agreementContact = TST_CLM_TestDataFactory.createAgreementContact(agreement, true, 'Account');
        Set<String> fieldSet = new Set<String>{'Id','Name'};
        
        Test.startTest();
            List<Agreement_Contacts__c> agreementContactsList = new SLT_Agreement_Contacts().getAgreementContactListByAgreementId(
                new Set<Id>{agreement.Id}, fieldSet);
        Test.stopTest();

        System.assertEquals(1, agreementContactsList.size(), 'Agreement Contact list is empty when not expected.');
    }

    @isTest
    private static void testGetAgreementContactListByAgreementId() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        Agreement_Contacts__c agreementContact = TST_CLM_TestDataFactory.createAgreementContact(agreement, true, 'Account');
        Set<String> fieldSet = new Set<String>{'Id','Name'};
        String condition = 'Agreement__c IN :agreementIds';
        
        Test.startTest();
            List<Agreement_Contacts__c> agreementContactsList = new SLT_Agreement_Contacts().getAgreementContactListByAgreementId(
                new Set<Id>{agreement.Id}, fieldSet, condition, null);
        Test.stopTest();

        System.assertEquals(1, agreementContactsList.size(), 'Agreement Contact list is empty when not expected.');
    }

    @isTest
    private static void testGetAgreementContactListByAgreementIdOrderByType() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, RecordType.Name, RecordTypeId, RecordType.DeveloperName
            FROM Apttus__APTS_Agreement__c WHERE RecordTypeId=:CON_CLM.PSA_RECORDTYPEID LIMIT 1];
        Agreement_Contacts__c agreementContact = [SELECT Id, Name, Contact__c, Agreement__c, Type__c 
            FROM Agreement_Contacts__c WHERE Agreement__c =: agreement.Id  LIMIT 1];
        Set<String> fieldSet = new Set<String>{'Id','Name'};
        Set<Id> agreementIds = new Set<Id>{agreement.Id};
        String condition = 'Agreement__c IN :agreementIds';
        String orderField = 'Type__c';
        String sortOrder = 'ASC';
        Test.startTest();
            List<Agreement_Contacts__c> agreementContactsList = new SLT_Agreement_Contacts().getAgreementContactListByAgreementId(
                agreementIds, fieldSet, condition, null, orderField, sortOrder);
        Test.stopTest();

        System.assertEquals(1, agreementContactsList.size(), 'Agreement Contact list is empty when not expected.');
    }
}