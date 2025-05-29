@isTest
private class TST_CNT_CLM_AgreementHeader {
    @TestSetup
    static void dataSetup() {
        Account account = new Account(Name = 'IMS Health Global', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert account;

        Contact contact = new Contact(FirstName = 'firstNameTest', LastName = 'lastNameTest', Email = 'test@example.com');
        contact.recordTypeId = CON_CLM.IQVIA_USER_CONTACT_RECORDTYPEID;
        contact.EmployeeNumber__c = '1112222';
        insert contact;

        Apttus__APTS_Agreement__c agreementPSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreementPSA.Name = 'Test Agreement PSA';
        agreementPSA.IQVIA_Project_Manager_Con__c = contact.Id;
        agreementPSA.Apttus__Account__c = account.Id;
        insert agreementPSA;
    }
    
    @isTest
    private static void testSetAgreementWrapperShouldSetWrapper(){
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement PSA' LIMIT 1];
        
        Test.startTest();
            AgreementWrapper agreementWrapper = CNT_CLM_AgreementHeader.setAgreementWrapper(agreement.Id);
        Test.stopTest();

        System.assertNotEquals(null, agreementWrapper, 'Agreement Wrapper is null when not expected');
    }

    @isTest
    private static void testShowProjectManagerPromptShouldReturnFalse(){
        Apttus__APTS_Agreement__c agreement = [SELECT Id, IQVIA_Project_Manager_Con__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement PSA' LIMIT 1];
        
        Test.startTest();
            Boolean showPrompt = CNT_CLM_AgreementHeader.showProjectManagerPrompt(agreement.IQVIA_Project_Manager_Con__c);
        Test.stopTest();

        System.assertEquals(false,showPrompt, 'The prompt message should not appear.');
    }

    @isTest
    private static void testShowProjectManagerPromptShouldReturnTrue(){
        
        Test.startTest();
            Boolean showPrompt = CNT_CLM_AgreementHeader.showProjectManagerPrompt('');
        Test.stopTest();

        System.assertEquals(true,showPrompt, 'Not showing the prompt message when expected');
    }

    @isTest
    private static void testSetAgreementPSAWrapperShouldSetWrapper(){
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement PSA' LIMIT 1];
        
        Test.startTest();
            AgreementWrapper agreementWrapper = CNT_CLM_AgreementHeader.setAgreementWrapper(agreement.Id);
        Test.stopTest();

        System.assertNotEquals(null, agreementWrapper, 'Agreement Wrapper is null when not expected');
    }
}