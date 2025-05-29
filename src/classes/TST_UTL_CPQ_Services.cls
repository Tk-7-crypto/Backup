@isTest
public class TST_UTL_CPQ_Services {
	
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
        quote.Start_Date__c = Date.today();
        quote.End_Date__c = Date.Today().addMonths(3);
        insert quote;
    }
    
    @isTest static void testInsertRecords() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Test.startTest();
        UTL_CPQ_Services.insertQLIs('[{"Quote" :"' + quote.Id + '"}]', '{"partialSave" : false, "internalCall" : false}');
        UTL_CPQ_Services.insertQLIs('[{"Quote" :"' + quote.Id + '", "Excluded_From_Pricing_Assistant__c" : false}]', '{"partialSave" : false, "internalCall" : false}');
        Test.stopTest();
    }
}
