@isTest
public class TST_WSC_CPQ_QLIServices {
	
    @TestSetup
    static void dataSetup() {
        Template_Data__c tempData = UTL_TestData.tempDataCreation('Quote', 'Quote__c', 'Quote_Line_Item__c');
	
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
    
    @isTest static void testInsertRecords() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Test.startTest();
            WSC_CPQ_QLIServices.insertQLIs('[{"Quote" :"' + quote.Id + '"}]', '{"partialSave" : false, "internalCall" : false}');
        Test.stopTest();
    }
}
