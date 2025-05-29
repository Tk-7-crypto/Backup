/**
 * Test class for DAOH_CPQ_TS_ProductConfiguration
 */
@isTest
public class TST_DAOH_CPQ_TS_ProductConfiguration {
    
    static Account account;
    static Opportunity opportunity;
    static List<RecordType> recordType;
    static Apttus_Config2__PriceList__c priceList;
    
    @testSetup
    static void setUpTestData() {        
        // Create Account
        account = UTL_TestData.createAccount();
        account.AccountCountry__c = 'JP';
        insert account;
        
        // Create Opportunity
        opportunity = UTL_TestData.createOpportunity(account.Id);
        insert opportunity;
        
        // Create Apttus Price List
        priceList = UTL_TestData.createPriceList(CON_CPQ.TECH_SOLUTION_JAPAN);
        
        // Create Custom Settings record of "CPQ TS PriceList Selection"
        UTL_TestData.createCPQTSPriceListSelectionCustomSettings();
        
    }
    
    // Retrieve data created from setUpTestData method
    static void retrieveData(){
        account = [SELECT Id FROM Account Limit 1];
        opportunity = [SELECT Opportunity_Number__c FROM Opportunity Limit 1];
        recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                       AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        priceList = [Select Id From Apttus_Config2__PriceList__c LIMIT 1];
    }
    
    // Test Update Proposal fields on Cart finalization
    static testMethod void testProposalFieldsAfterCartFinalization(){
        
        retrieveData();
        
        // Create Config System Properties record
        Apttus_Config2__ConfigSystemProperties__c configSystemProperties = new Apttus_Config2__ConfigSystemProperties__c();
        configSystemProperties.Name = 'System Properties';
        configSystemProperties.Apttus_Config2__PricingBatchSize__c = 100;
        insert configSystemProperties;
        
        // Create Products
        Integer productCount = 3;
        List<Product2> products = new List<Product2>();
        for(Integer i=0; i<productCount; i++){
            Product2 product = UTL_TestData.createProduct();
            product.Name = 'Product ' + i;
            products.add(product);
        }
        insert products;
        
        // Create Price Book Entries
        List<PriceBookEntry> priceBookEntries = new List<PriceBookEntry>();
        for(Integer i=0; i<productCount; i++){
            priceBookEntries.add(UTL_TestData.createPricebookEntry(products[i].Id));
        }
        insert priceBookEntries;
        
        // Create Opportunity Line Items
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        for(Integer i=0; i<productCount; i++){
            oppLineItems.add(UTL_TestData.createOpportunityLineItem(opportunity.Id, priceBookEntries[i].Id));
        }
        insert oppLineItems;
        
        // Create Price List Entries of Opportunity Products. This step is required to create Cart Line Items
        List<Apttus_Config2__PriceListItem__c> priceListItems = new List<Apttus_Config2__PriceListItem__c>();
        for(Integer i=0; i<productCount; i++){
            priceListItems.add(UTL_TestData.createPriceListItem(products[i].id, priceList.Id, 'PLI-91' + i));
        }
        insert priceListItems;
        
        Test.startTest();
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.createQuote();
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.RecordTypeId = recordType[0].Id;
        proposal.Apttus_Proposal__Opportunity__c = opportunity.Id;
        proposal.Apttus_Proposal__Approval_Stage__c = 'In-Progress';
        proposal.Apttus_QPConfig__PriceListId__c = priceList.Id;
        proposal.Select_Pricing_Tool__c = CON_CPQ.TS_JAPAN;
        insert proposal;

        CPQ_Utility.syncOpportunityProductsIntoCartLineItems(JSON.serialize(proposal)); 

        Test.stopTest();
        
        List<Apttus_Config2__ProductConfiguration__c> productConfigurations = [Select Id, Apttus_Config2__Status__c From Apttus_Config2__ProductConfiguration__c Where Apttus_QPConfig__Proposald__c =: proposal.Id LIMIT 1];
        
        System.assertEquals(1, productConfigurations.size(), 'Product Configuration size mis-match');
        System.assertEquals('Saved', productConfigurations[0].Apttus_Config2__Status__c, 'Product Configuration status mis-match');
        
        // Verify Cart Line Items
        List<Apttus_Config2__LineItem__c> cartLineItems = [Select Apttus_Config2__ProductId__c,
                                                           Apttus_Config2__PriceListId__c,
                                                           Apttus_Config2__PriceListItemId__c,
                                                           Apttus_Config2__NetPrice__c
                                                           From Apttus_Config2__LineItem__c
                                                           Where Apttus_Config2__ConfigurationId__c =:productConfigurations[0].Id];
        System.assertEquals(3, cartLineItems.size(), 'Cart Line Item size mis-match');
        
        // Update Cart line Item attributes
        cartLineItems[0].Apttus_Config2__StartDate__c = Date.newInstance(2021, 5, 1);
        cartLineItems[0].Apttus_Config2__EndDate__c = Date.newInstance(2021, 12, 31);
        cartLineItems[0].Gross_Margin__c = 17.0;
        cartLineItems[1].Apttus_Config2__StartDate__c = Date.newInstance(2021, 3, 1);
        cartLineItems[1].Apttus_Config2__EndDate__c = Date.newInstance(2021, 11, 30);
        cartLineItems[1].Gross_Margin__c = 14.0;
        cartLineItems[2].Apttus_Config2__StartDate__c = Date.newInstance(2021, 1, 1);
        cartLineItems[2].Apttus_Config2__EndDate__c = Date.newInstance(2021, 10, 31);
        cartLineItems[2].Gross_Margin__c = 10.0;
        cartLineItems[2].Pass_Through__c = true;
        update cartLineItems;
        
        // Finalize the cart and generate the proposal line items
        Apttus_CPQApi.CPQ.FinalizeCartRequestDO request = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
        request.CartId= productConfigurations[0].Id;
        Apttus_CPQApi.CPQ.FinalizeCartResponseDO result = Apttus_CPQApi.CPQWebService.finalizeCart(request);
        
        // Verify Proposal fields populated after Cart finalization
        List<Apttus_Proposal__Proposal__c> proposals = [Select Apttus_Proposal__ExpectedStartDate__c,
                                                           Apttus_Proposal__ExpectedEndDate__c,
                                                           Apttus_Proposal__Approval_Stage__c,
                                                           Min_Gross_Margin__c
                                                        From Apttus_Proposal__Proposal__c Where Id =: proposal.Id];
                                                        
        System.assertEquals(Date.newInstance(2021, 1, 1), proposals[0].Apttus_Proposal__ExpectedStartDate__c, 'Expected start date mis-match');
        System.assertEquals(Date.newInstance(2021, 12, 31), proposals[0].Apttus_Proposal__ExpectedEndDate__c, 'Expected end date mis-match');
        System.assertEquals(CON_CPQ.FINALIZED, proposals[0].Apttus_Proposal__Approval_Stage__c, 'Approval stage mis-match');
        System.assertEquals(14.0, proposals[0].Min_Gross_Margin__c, 'Min Gross margin mis-match');
    }
}
