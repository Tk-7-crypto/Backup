@isTest
public class TST_SLT_MappingGateway {
    @TestSetup
    static void dataSetup() {
        Template_Data__c tempData = UTL_TestData.tempDataCreation('Quote', 'Quote__c', 'Quote_Line_Item__c');
        tempData.Migration_Id__c = 'TD-01';
        update tempData;
        
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = CON_CPQ.AL;
        insert acc;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunityData(acc.id, CON_CPQ.CLINICAL, null, CON_CPQ.REGION_ASIA_PASIFIC, CON_CPQ.USD, false);
        insert testOpportunity;
        
        Quote__c quote = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, false);
        quote.Approval_Stage__c = CON_CPQ.DRAFT;
        quote.Document_Type__c = CON_CPQ.PDF_INDIVIDUAL_DOCUMENTS;
        quote.License_Type__c = 'Per Study';
        insert quote;
    }

    @isTest static void testSelectSObjectByCondition() {
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get('Quote__c');
        String result;
        Test.startTest();
            result = new SLT_MappingGateway().selectSObjectByCondition(sObjType, 'Id != null', new Set<String>{'Approval_Stage__c', 'Document_Type__c'}, 'Approval_Stage__c', '1', new List<UTL_CPQ_MappingGateway.WPR_CPQ_SubSOQLConstructor>());
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
}
