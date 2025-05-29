@isTest
public class TST_UTL_CPQ_MappingGateway {
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

	@isTest static void testHandleGetRequest() {
        UTL_CPQ_MappingGateway.WPR_CPQ_SubSOQLConstructor wpr = new UTL_CPQ_MappingGateway.WPR_CPQ_SubSOQLConstructor(null, null, null);
        UTL_CPQ_MappingGateway.WPR_CPQ_SOQLConstructor tokens = new UTL_CPQ_MappingGateway.WPR_CPQ_SOQLConstructor('Quote__c', 'Id != null', new List<String>{'Approval_Stage__c'}, 'Approval_Stage__c', '1', new List<UTL_CPQ_MappingGateway.WPR_CPQ_SubSOQLConstructor>());
        UTL_CPQ_MappingGateway.WPR_CPQ_ReturnItems result;
        Test.startTest();
            UTL_CPQ_MappingGateway.getSubRequest(null);
            result = UTL_CPQ_MappingGateway.handleGetRequest(tokens);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess);
    }
    
	@isTest static void testHandlePostRequest() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        UTL_CPQ_MappingGateway.WPR_CPQ_ReturnItems result;
        Test.startTest();
            result = UTL_CPQ_MappingGateway.handlePostRequest('{"Quote_Line_Item__c" : [{ "Pricing_Tool__c" : "EMEA", "Quote" : "' + quote.Id + '"}]}');
        Test.stopTest();
        System.assertEquals(true, result.isSuccess);
    }

	@isTest static void testHandlePutRequest() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        UTL_CPQ_MappingGateway.WPR_CPQ_ReturnItems result;
        Test.startTest();
            result = UTL_CPQ_MappingGateway.handlePutRequest('{"Quote__c" : [{ "Id" : "' + quote.Id + '", "Iteration__c": "3"}]}');
        Test.stopTest();
        System.assertEquals(true, result.isSuccess);
    }

    @isTest static void testHandleGetRequestNegative() {
        UTL_CPQ_MappingGateway.WPR_CPQ_SOQLConstructor tokens = new UTL_CPQ_MappingGateway.WPR_CPQ_SOQLConstructor('', 'Id != null', new List<String>{'Approval_Stage__c'}, 'Approval_Stage__c', '1', new List<UTL_CPQ_MappingGateway.WPR_CPQ_SubSOQLConstructor>());
        UTL_CPQ_MappingGateway.WPR_CPQ_ReturnItems result;
        Test.startTest();
            result = UTL_CPQ_MappingGateway.handleGetRequest(tokens);
            tokens.entity = 'Quote123';
            result = UTL_CPQ_MappingGateway.handleGetRequest(tokens);
            tokens.entity = 'Quote__c';
            tokens.fields = new List<String>();
            result = UTL_CPQ_MappingGateway.handleGetRequest(tokens);
        Test.stopTest();
        System.assertEquals(false, result.isSuccess);
    }
}
