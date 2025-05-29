@isTest
public class TST_SLT_APTS_Agreement_History {
   
    @testSetup 
    static void setupData() {
        
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        insert testAgreement;
        
        Apttus__APTS_Agreement__History historyAGR = new Apttus__APTS_Agreement__History();
        historyAGR.ParentId = testAgreement.id;
        historyAGR.Field = 'Apttus__Status__c';
        insert historyAGR;
    }

    @isTest
    static void testSLTHistory() {
        List<Schema.SObjectField> historyList = new SLT_APTS_Agreement_History().getSObjectFieldList();
        Schema.SObjectType historyObj = new SLT_APTS_Agreement_History(true).getSObjectType();
        
        Integer expected = 0;
        System.assertEquals(expected, historyList.size());
    }

    @isTest
    static void testgetHistoryRecByParentId() {
        Map<Id, Apttus__APTS_Agreement__c> agreementMap  = new Map<Id, Apttus__APTS_Agreement__c>([Select Id From Apttus__APTS_Agreement__c LIMIT 1]);
        Set<String> agreementFieldSet = new Set<String>{'Id'};

        Test.startTest();
            List<Apttus__APTS_Agreement__History> historyList = new SLT_APTS_Agreement_History().getHistoryRecByParentId(agreementMap.keySet(),
                agreementFieldSet, 'ParentId != null');
        Test.stopTest();

        System.assertEquals(1, historyList.size());
    } 
}