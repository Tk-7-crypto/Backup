@isTest
public class TST_SRV_CPQ_MappingGateway {
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
	@isTest static void testOperateRecord() {
        Quote__c quote = [SELECT Id, Approval_Stage__c FROM Quote__c LIMIT 1];
        quote.Approval_Stage__c = 'In-Progress';
        List<sObject> sList = new List<sObject>();
        sList.add(quote);
        Test.startTest();
            SRV_CPQ_MappingGateway.updateRecords(sList);
            SRV_CPQ_MappingGateway.deleteRecords(sList);
        Test.stopTest();
    }
}