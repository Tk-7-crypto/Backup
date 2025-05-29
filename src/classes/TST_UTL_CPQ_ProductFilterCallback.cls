@isTest
private class TST_UTL_CPQ_ProductFilterCallback {
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.Id);
        insert testOpportunity;
        
        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.COMPLETE_CONSENT;
        quote.Approval_Stage__c = 'Draft';
        quote.GBU__c = CON_CPQ.GBU_DPS;
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.Related_Account__c = acc.Id;
        quote.License_Type__c = 'Per Study';
        insert quote; 
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('Q2 Solutions - USD');
        pl.CurrencyIsoCode = 'USD';
        insert pl;
        
        Id recordTypeId = SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(CON_CPQ.TECH_SOLUTION).getRecordTypeId();
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.createQuote();
        proposal.Apttus_Proposal__Account__c = acc.Id;
        proposal.RecordTypeId = recordTypeId;
        proposal.IQVIA_Quote__c = quote.Id;
        proposal.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
        proposal.Select_Pricing_Tool__c = CON_CPQ.Complete_Consent;
        proposal.Apttus_Proposal__Approval_Stage__c = 'Draft';
        proposal.Apttus_QPConfig__PriceListId__c = pl.Id;
        insert proposal;
        
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('SL-Development Metabolism', 'Bundle', 'Q_111813', 'US', 'Go Blue');
        prod.Apttus_Config2__HasOptions__c = true;
        prod.Apttus_Config2__HasAttributes__c = true;
        insert prod;
        
        Apttus_Config2__PriceListItem__c pli = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod.Id, 'PLI-011');  
        insert pli;   
    }
    
    @isTest
    static void testProductsExcludeForDPS() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, IQVIA_Quote__r.License_Type__c, IQVIA_Quote__r.Document_Type__c FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Apttus_Config2__ConfigCustomClasses__c apttusPricingCallbackClass = new Apttus_Config2__ConfigCustomClasses__c();
        apttusPricingCallbackClass.Apttus_Config2__ProductFilterCallbackClass__c = 'CPQ_ProductFilterCallback';
        apttusPricingCallbackClass.Name = 'System Properties'; 
        insert apttusPricingCallbackClass;
        Apttus_Config2__ProductConfiguration__c pc = new Apttus_Config2__ProductConfiguration__c();
        pc.Apttus_QPConfig__Proposald__c = proposal.Id;
        insert pc;
        Test.startTest();
            Apttus_Config2.CustomClass.ActionParams params = new Apttus_Config2.CustomClass.ActionParams();
            params.ConfigurationId = pc.Id;
            String condition =  UTL_CPQ_ProductFilterCallback.productsExcludeForDPS(proposal.IQVIA_Quote__r.License_Type__c, proposal.IQVIA_Quote__r.Document_Type__c);
            String condition2 =  UTL_CPQ_ProductFilterCallback.productsExcludeForDPS(proposal.IQVIA_Quote__r.License_Type__c, CON_CPQ.PDF_DOCUMENT_BUNDLES);
            String condition3 =  UTL_CPQ_ProductFilterCallback.productsExcludeForDPS(proposal.IQVIA_Quote__r.License_Type__c, CON_CPQ.INTERACTIVE_INDIVIDUAL_DOCUMENT);
            String condition4 =  UTL_CPQ_ProductFilterCallback.productsExcludeForDPS(proposal.IQVIA_Quote__r.License_Type__c, CON_CPQ.INTERACTIVE_DOCUMENT_BUNDLE);
        Test.stopTest();
        system.assertEquals(True, condition.length() > 0 , 'Product code should not be null');
        system.assertEquals(True, condition2.length() > 0 , 'Product code should not be null');
        system.assertEquals(True, condition3.length() > 0 , 'Product code should not be null');
        system.assertEquals(True, condition4.length() > 0 , 'Product code should not be null');
    }
}