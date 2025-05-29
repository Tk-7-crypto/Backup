@isTest
public class TST_CNT_CLM_ActionPanel {
    
    @testSetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        agreement.Name = 'Test RWS';
        agreement.Apttus__Status_Category__c = 'Request';
        agreement.Apttus__Status__c = 'Request';
        agreement.Apttus__Subtype__c = 'ATP';
        insert agreement;
    }
    
    @isTest
    private static void testGetAgreementDetails() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
        
        Test.startTest();
            Apttus__APTS_Agreement__c resultAgreement = CNT_CLM_ActionPanel.getAgreementDetails(agreement.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, resultAgreement, 'The agreement should not be null');
    }

    @isTest
    private static void testGetSectionData() {
        Map<String, List<String>> sectionNameToFieldsMap = new Map<String, List<String>>();         
        
        Test.startTest();
            sectionNameToFieldsMap = CNT_CLM_ActionPanel.getSectionData();
        Test.stopTest();
          
        System.assertEquals(true, !sectionNameToFieldsMap.isEmpty(), 'The value should not be empty');
    }

    @isTest
    private static void testGetAgreementFieldsForValidation() {
        List<String> resultList = new List<String>();
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
         
        Test.startTest();
            resultList = CNT_CLM_ActionPanel.getAgreementFieldsForValidation(agreement.Id, 'generate');
        Test.stopTest();
         
        System.assertEquals(true, !resultList.isEmpty(), 'The value should not be empty');
    }
}