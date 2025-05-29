@isTest
public class TST_SLT_RelatedAgreement {

    @testSetup
    static void dataSetup() {
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c testAgreementCO1 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementCO1.Name = 'Test PSA CO agreement 1';
        testAgreementCO1.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        testAgreementCO1.Apttus__Version_Number__c = 1;
        agreementList.add(testAgreementCO1);
        
        Apttus__APTS_Agreement__c testAgreementCO2 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementCO2.Name = 'Test PSA CO agreement 2';
        testAgreementCO2.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        testAgreementCO2.Apttus__Version_Number__c = 2;
        agreementList.add(testAgreementCO2);
        insert agreementList;
        
        Apttus__APTS_Related_Agreement__c relatedAgr = new Apttus__APTS_Related_Agreement__c();
        relatedAgr.Name = 'Current Agreement';
        relatedAgr.Apttus__Relationship_From_Type__c = 'Is Amended By';
        relatedAgr.Apttus__APTS_Contract_From__c = testAgreementCO1.Id; 
        relatedAgr.Apttus__Relationship_To_Type__c = 'Is Amendment For';
        relatedAgr.Apttus__APTS_Contract_To__c = testAgreementCO2.Id;
        insert relatedAgr;
    }
    
    @isTest
    private static void testGetRelatedAgreementsByCondition() {
        Apttus__APTS_Agreement__c agr = [SELECT Id, Name FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA CO agreement 1' LIMIT 1];
        String condition = 'Apttus__APTS_Contract_From__c IN: idSet';
        Set<String> fieldSet = new Set<String>{'Id', 'Name', 'Apttus__APTS_Contract_From__c'};
        
        Test.startTest();
            List<Apttus__APTS_Related_Agreement__c> result = new SLT_RelatedAgreement().getRelatedAgreementsByCondition(new Set<Id>{agr.Id}, fieldSet, condition);      
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'The result should not be null');
    }
}