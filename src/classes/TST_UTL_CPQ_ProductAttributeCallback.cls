@isTest
private class TST_UTL_CPQ_ProductAttributeCallback {
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.Id);
        insert testOpportunity;
        
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('Q2 Solutions - USD');
        pl.CurrencyIsoCode = 'USD';
        insert pl;
        
        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.Q2_Solutions;
        quote.Approval_Stage__c = 'Draft';
        quote.GBU__c = CON_CPQ.GBU_RDS;
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.Related_Account__c = acc.Id;
        insert quote; 
        
        
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('SL-Development Metabolism', 'Bundle', 'Q_111813', 'US', 'Go Blue');
        prod.Apttus_Config2__HasOptions__c = true;
        prod.Apttus_Config2__HasAttributes__c = true;
        insert prod;
        
        List<Quote_Requisites__c> quoteRequisiteList = new List<Quote_Requisites__c>();
        Quote_Requisites__c quoteRequisite = new Quote_Requisites__c();
        quoteRequisite.Type__c = 'Quote Sections';
        quoteRequisite.Matrix__c = 'N/A';
        quoteRequisite.Study_Number__c = '1';
        quoteRequisite.Service_Line_Product__c = prod.Id;
        quoteRequisite.Site__c = 'Indianapolis - ADME';
        quoteRequisite.Species_Global__c = 'Baboon';
        quoteRequisite.Analyte_ID__c = 'dummy Molecule';
        quoteRequisite.Quote__c = quote.Id;
        quoteRequisiteList.add(quoteRequisite);
        insert quoteRequisiteList;     
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.createQuote();
        proposal.Apttus_Proposal__Account__c = acc.Id;
        proposal.RecordTypeId = recordType.Id;
        proposal.IQVIA_Quote__c = quote.Id;
        proposal.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
        proposal.Select_Pricing_Tool__c = CON_CPQ.Complete_Consent; 
        proposal.CountryCode__c = 'India';
        proposal.Apttus_Proposal__Approval_Stage__c = 'Draft';
        proposal.Apttus_QPConfig__PriceListId__c = pl.Id;
        insert proposal;
       
        Apttus_Config2__PriceListItem__c pli = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, Prod.Id, 'PLI-011');  
        insert pli;
    }
    @isTest
    static void testAutoSelectAttributeForQ2Solution() {
        Test.startTest();
        Apttus_Config2__ConfigCustomClasses__c apttusPricingCallbackClass = new Apttus_Config2__ConfigCustomClasses__c();
        apttusPricingCallbackClass.Apttus_Config2__PricingCallbackClass__c = 'CPQ_ProductAttributeCallback';
        apttusPricingCallbackClass.Name = 'System Properties'; 
        insert apttusPricingCallbackClass;

        Apttus_Proposal__Proposal__c proposal = [SELECT ID, NAME, IQVIA_Quote__c FROM Apttus_Proposal__Proposal__c LIMIT 1]; 
        Product2 prod = [SELECT ID FROM Product2 LIMIT 1];
        List<Quote_Requisites__c> quoteRequisiteList = [SELECT ID, Service_Line_Product__c, Study_Number__c, Number_of_Analyte_Global__c, Specimen_Type__c, Clinical_Type__c  FROM Quote_Requisites__c LIMIT 1];

        Apttus_Config2__LineItem__c lineItem = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, prod.Id, prod.Id, 1, 987);
        lineItem.Apttus_Config2__HasAttributes__c = true;
        insert lineItem;
        Apttus_Config2__ProductAttributeValue__c pav = new Apttus_Config2__ProductAttributeValue__c();
        pav.Study_Number__c = '1';
        pav.Apttus_Config2__LineItemId__c = lineItem.Id;
        upsert pav;
        lineItem.Apttus_Config2__AttributeValueId__c = pav.Id;
        update lineItem;
        UTL_CPQ_ProductAttributeCallback.autoSelectAttributeForQ2Solution(lineItem, pav, quoteRequisiteList);
        Test.stopTest();
    }
}