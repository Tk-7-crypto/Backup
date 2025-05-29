@isTest
public class TST_CNT_CLM_ActionPanelIQVIA {
    
    @testSetup
    static void dataSetup() {
        Contact tlContact = new Contact();
        tlContact.FirstName = 'Test';
        tlContact.LastName = 'Team Lead Contact';
        tlContact.Email = 'testlead@example.com';
        tlContact.EmployeeNumber__c = '1234567';
        tlContact.RecordTypeId = CON_CLM.CONTACT_IQVIA_USER_CONTACT_RECORDTYPEID;
        insert tlContact;
        
        IQVIA_Agreement__c iqagreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqagreement.Name = 'Test USBU';
        iqagreement.Status_Category__c = 'Request';
        iqagreement.Status__c = 'Request';
        iqagreement.Subtype__c = 'SOW';
        insert iqagreement;
        
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.GENERIC_RECORDTYPEID, false);
        agreement.Name = 'Test Generic';
        agreement.Apttus__Status_Category__c = 'Request';
        agreement.Apttus__Status__c = 'Request';
        agreement.Apttus__Subtype__c = 'SOW';
        agreement.IQVIA_Agreement__c = iqagreement.Id;
        insert agreement;
        
        IQVIA_Agreement_Team__c teamLead = new IQVIA_Agreement_Team__c();
        teamLead.Role__c = 'Team Lead';
        teamLead.Type__c = CON_CLM.IQVIA_USER_CONTACT_TYPE;
        teamLead.Agreement__c = iqagreement.Id;
        teamLead.Contact__c = tlContact.Id;
        insert teamLead;
        
    }
    
    @isTest
    private static void testGetAgreementDetails() {
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            IQVIA_Agreement__c resultAgreement = CNT_CLM_ActionPanelIQVIA.getAgreementDetails(agreement.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, resultAgreement, 'The agreement should not be null');
    }
}