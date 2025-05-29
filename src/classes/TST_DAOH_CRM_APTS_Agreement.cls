@isTest
public class TST_DAOH_CRM_APTS_Agreement {

    @isTest
    static void testUpdateEarlyEngagementCOE(){
        Test.startTest();
        	DAOH_CRM_APTS_Agreement.updateRfpReceivedDate(new List<Apttus__APTS_Agreement__c>(),new Map<Id,Apttus__APTS_Agreement__c>());
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateSurveyPIC(){
        Contact testContact = new Contact(FirstName = 'TestFirstName', LastName = 'Test', Email = 'test@test.com', RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT, pse__Salesforce_User__c = UserInfo.getUserId(), Salesforce_User__c = UserInfo.getUserId());
        insert testContact;
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Apttus__Subtype__c = 'Work Order';
        agreement.IQVIA_Project_Manager_Con__c = testContact.Id;
        insert agreement;
    }
}