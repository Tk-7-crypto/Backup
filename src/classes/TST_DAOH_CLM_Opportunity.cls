@isTest
private class TST_DAOH_CLM_Opportunity {

    @isTest
    private static void testUpdateIsStudyAwaredOfAgreementForNo() {
        Opportunity opp = TST_CLM_TestDataFactory.createOpportunity(false);
        opp.StageName = '1. Identifying Opportunity';
        insert opp;
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        oldMap.put(opp.Id, opp);

        Opportunity newOpp = opp.clone(true, false, false, false);
        newOpp.StageName = '2. Qualifying Opportunity';
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(
            CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        agreement.Is_Study_Awarded__c = 'Yes';
        insert agreement;

        agreement.Apttus__Related_Opportunity__c = opp.Id;
        update agreement;

        Test.startTest();
            DAOH_CLM_Opportunity.updateIsStudyAwaredOfAgreement(new List<Opportunity>{newOpp}, oldMap);
        Test.stopTest();

        Apttus__APTS_Agreement__c resultAgreement = [SELECT Id, Is_Study_Awarded__c FROM Apttus__APTS_Agreement__c 
            WHERE Id=:agreement.Id];
        System.assertEquals('No', resultAgreement.Is_Study_Awarded__c, 
            'Is_Study_Awarded__c field value must be updated to No but it is not.');
    }

    @isTest
    private static void testUpdateIsStudyAwaredOfAgreementForYes() {
        Opportunity opp = TST_CLM_TestDataFactory.createOpportunity(false);
        opp.StageName = '6. Received ATP/LOI';
        insert opp;
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        oldMap.put(opp.Id, opp);

        Opportunity newOpp = opp.clone(true, false, false, false);
        newOpp.StageName = '5. Finalizing Deal';
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(
            CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        agreement.Is_Study_Awarded__c = 'No';
        insert agreement;

        agreement.Apttus__Related_Opportunity__c = opp.Id;
        update agreement;

        Test.startTest();
            DAOH_CLM_Opportunity.updateIsStudyAwaredOfAgreement(new List<Opportunity>{newOpp}, oldMap);
        Test.stopTest();

        Apttus__APTS_Agreement__c resultAgreement = [SELECT Id, Is_Study_Awarded__c FROM Apttus__APTS_Agreement__c 
            WHERE Id=:agreement.Id];
        System.assertEquals('Yes', resultAgreement.Is_Study_Awarded__c, 
            'Is_Study_Awarded__c field value must be updated to Yes but it is not.');
    }

    @isTest
    private static void testCreateAgreement() {
        Opportunity opp = TST_CLM_TestDataFactory.createOpportunity(false);
        opp.Name = 'Test AGR Creation';
        opp.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
        opp.Is_this_IQVIA_Biotech__c = 'Yes';
        insert opp;
        sobjectPartnerSoapSforceCom.sObject_x sObj = null;

        Test.startTest();
            sObj = DAOH_CLM_Opportunity.createAgreement(opp);
        Test.stopTest();

        System.assertNotEquals(null, sObj, 'sObject not created when expected');
    }

    
}