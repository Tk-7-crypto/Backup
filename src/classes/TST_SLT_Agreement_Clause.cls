@isTest
private class TST_SLT_Agreement_Clause {

    @isTest
    private static void testGetAgreementClauseDetailsShouldReturnMap() {
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.RecordTypeForStatusAutomation__c = 'PSA;MSA';
        insert clmConfiguration;

        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        Apttus__Agreement_Clause__c agreementClause = TST_CLM_TestDataFactory.createAgreementClause(agreement.Id, true);
        Set<Id> idSet = new Set<Id>{agreementClause.Id};
        Set<String> fields = new Set<String>{'Id'};
        String condition = 'Id =\'' + agreementClause.Id + '\'';
        Set<Id> recordTypeIdSet = new Set<Id>{CON_CLM.PSA_RECORDTYPEID};

        Test.startTest();
            Map<Id, Apttus__Agreement_Clause__c> result = new SLT_Agreement_Clause().getAgreementClauseDetails(
                idSet, fields, condition, recordTypeIdSet);
        Test.stopTest();

        System.assertNotEquals(null, result.get(agreementClause.Id), 'Requested agreement clause is not fetched.');
    }
}