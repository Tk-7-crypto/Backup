/**
* This test class is used to test all methods in selector class for Agreement Team object.
* version : 1.0
*/
@isTest
public class TST_SLT_Agreement_Team {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() 
	{
        Account acc = UTL_TestData.createAccount();
        insert acc;

        Contact tlContact = UTL_TestData.createContact(acc.Id);
        tlContact.RecordTypeId = CON_CLM.CONTACT_IQVIA_USER_CONTACT_RECORDTYPEID;
        tlContact.FirstName = 'Test';
        tlContact.LastName = 'Team Lead Contact';
        tlContact.Email = 'testlead@example.com';
        tlContact.EmployeeNumber__c = '123456';
        insert tlContact;
        
        IQVIA_Agreement__c iqagreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqagreement.Name = 'Test USBU';
        iqagreement.Status_Category__c = 'Request';
        iqagreement.Status__c = 'Request';
        iqagreement.Subtype__c = 'SOW';
        insert iqagreement;
        
        IQVIA_Agreement_Team__c teamLead = new IQVIA_Agreement_Team__c();
        teamLead.Role__c = 'Team Lead';
        teamLead.Type__c = CON_CLM.IQVIA_USER_CONTACT_TYPE;
        teamLead.Agreement__c = iqagreement.Id;
        teamLead.Contact__c = tlContact.Id;
        insert teamLead;
    }
    
    @isTest
    static void testGetAgreementTeamListByAgreementId(){
        IQVIA_Agreement__c iqagreement = [SELECT ID FROM IQVIA_Agreement__c LIMIT 1][0];
        Set<Id> idSet = new Set<Id>{iqagreement.Id};
        Set<String> fieldSet = new Set<String>{'Id'};
        List<IQVIA_Agreement_Team__c> agreementTeamList = new SLT_Agreement_Team().getAgreementTeamListByAgreementId(idSet, fieldSet, 'Role__c =:firstParam', 'Team Lead', 'Name', 'ASC');
        
        System.assertEquals(1, agreementTeamList.size(), 'No Agreement Team Record Found.');
    }

    @isTest
    static void testGetAgreementTeamByCondition(){
        Set<String> emailSet = new Set<String>{'test@example.com'};
        String condition = 'Email__c =: firstParam';
        
        Test.startTest();
            List<IQVIA_Agreement_Team__c> result = new SLT_Agreement_Team().getAgreementTeamByCondition(emailSet, condition, new Set<String>{'Id'});
        Test.stopTest();   
        
        System.assertNotEquals(null, result, 'The result should not be null');
    }

}