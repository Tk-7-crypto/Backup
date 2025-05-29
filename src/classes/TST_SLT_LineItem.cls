/*
 * Version       : 1.0
 * Description   : Test Class for SLT_LineItem
 */
@IsTest
public class TST_SLT_LineItem {
    /**
     * This method used to set up testdata
     */ 
    @TestSetup
    static void dataSetup() {
        Account account = UTL_OCE_TestData.createaccount();
        insert account;
        Opportunity opportunity = UTL_OCE_TestData.createOpportunity(account.Id);
        insert opportunity;
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.OCE);
        proposal.Apttus_Proposal__Account__c = account.Id;
        insert proposal;

        Apttus_Config2__ProductConfiguration__c prodConfig;
        prodConfig = UTL_TestData.createProductConfiguration(proposal.Id, CON_CPQ.SALE_TYPE_NEW);
        insert prodConfig;
    }

    @IsTest
    static void testSelectById() {
        Set<Id> lineItemIdSet = new Set<Id>();
        Id prodConfigId = getProdConfigId();
        Product2 prod = UTL_OCE_TestData.createProduct(CON_OCE.TEST_PRODUCT1_NAME, null, null, null);
        insert prod;
        Apttus_Config2__LineItem__c lineItem = UTL_OCE_TestData.createPrimaryConfigLineItem(
            prodConfigId, 1, 1, prod.Id, 1, 0);
        insert lineItem;
        lineItem = UTL_OCE_TestData.createPrimaryConfigLineItem(
            prodConfigId, 1, 1, prod.Id, 1, 0);
        insert lineItem;
        lineItemIdSet.add(lineItem.Id);

        List<Apttus_Config2__LineItem__c> lineItemList;
        Test.startTest();
        lineItemList = new SLT_LineItem().selectById(lineItemIdSet);
        Test.stopTest();
        System.assertEquals(1, lineItemList.size(), '1 Apttus_Config2__LineItem__c Records' );
    }

    @IsTest
    static void testSelectByProductConfigId() {
        Id prodConfigId = getProdConfigId();
        Product2 prod = UTL_OCE_TestData.createProduct(CON_OCE.TEST_PRODUCT1_NAME, null, null, null);
        insert prod;
        Apttus_Config2__LineItem__c lineItem = UTL_OCE_TestData.createPrimaryConfigLineItem(
            prodConfigId, 1, 1, prod.Id, 1, 0);
        insert lineItem;
        lineItem = UTL_OCE_TestData.createPrimaryConfigLineItem(
            prodConfigId, 2, 1, prod.Id, 1, 0);
        insert lineItem;

        List<Apttus_Config2__LineItem__c> lineItemList;
		
        Apttus_Config2__LineItem__c individualLineItem;
        Test.startTest();
        lineItemList = new SLT_LineItem().selectByProductConfigId(new Set<Id>{prodConfigId}, new Set<String>{CON_OCE.LINE_ITEM_LINE_NUMBER});
        individualLineItem = new SLT_LineItem().selectByLineItemID(lineItem.Id, CON_CPQ.FIELDSET);
        Test.stopTest();
        System.assertEquals(2, lineItemList.size(), '2 Apttus_Config2__LineItem__c Records');
    }

    private static Id getProdConfigId() {
        Apttus_Config2__ProductConfiguration__c prodConfig = [
            SELECT Id FROM Apttus_Config2__ProductConfiguration__c
            WHERE Name = :CON_OCE.TEST_PRODUCT_CONFIG_NAME
            LIMIT 1
        ];
        return prodConfig.Id;
    }
    
    @IsTest
    static void testgetLineItemsWithAttributesByQuoteId() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID};
        Set<String> optionCodes = new Set<String>{CON_CPQ.CPQ_TS_AMESA_Data_STD, CON_CPQ.CPQ_TS_AMESA_Data_SL_SF};
        Set<String> bundleCodes = new Set<String>{CON_CPQ.CPQ_TS_AMESA_Data_PI};
        
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('LC9', 'Bundle', CON_CPQ.CPQ_TS_AMESA_Data_PI, 'US', 'Go Blue');       
        prod.CanUseRevenueSchedule = true;
        prodList.add(prod);
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('LC9', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_STD, 'US', 'Go Blue');
        prod1.CanUseRevenueSchedule = true;
        prodList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('LC1', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_SL_SF, 'US', 'Go Blue');
        prod2.CanUseRevenueSchedule = true;
        prodList.add(prod2);
        insert prodList;
        Apttus_Config2__PriceList__c pList = TST_TestGeneratorClass.buildTestPriceList(CON_CPQ.AMESA);
        
        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        quote.Approval_Stage__c = 'Draft';
        quote.GBU__c = CON_CPQ.GBU_DPS;
        quote.Related_Opportunity__c = opp.Id;
        quote.Related_Account__c = acc.Id;
        insert quote;       
        
        Apttus_Proposal__Proposal__c proposal = TST_TestGeneratorClass.setProposalData('Tech_Solution', opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, null,pList.Id);
        proposal.IQVIA_Quote__c = quote.Id;
        update proposal;
        
        Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c();
        prodConfig.Apttus_QPConfig__Proposald__c = proposal.Id;
        insert prodConfig;
        
        List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c lineItem = TST_TestGeneratorClass.createOptionConfigLineItem(prodConfig.Id, 1, 1, prod.id, prod1.Id, 1, 100);
        lineItemList.add(lineItem);
        Apttus_Config2__LineItem__c lineItem1 = TST_TestGeneratorClass.createOptionConfigLineItem(prodConfig.Id, 1, 1, prod.Id, prod2.Id, 1, 200);
        lineItemList.add(lineItem1);
        insert lineItemList;
        
        List<Apttus_Config2__ProductAttributeValue__c> attributeList = new List<Apttus_Config2__ProductAttributeValue__c>();
        attributeList.add(new Apttus_Config2__ProductAttributeValue__c(O_Country__c = 'India', Apttus_Config2__LineItemId__c = lineItemList[0].Id));
        attributeList.add(new Apttus_Config2__ProductAttributeValue__c(O_Country__c = 'India', Apttus_Config2__LineItemId__c = lineItemList[1].Id));
        insert attributeList;
        
        lineItemList[0].Apttus_Config2__AttributeValueId__c = attributeList[0].Id;
        lineItemList[1].Apttus_Config2__AttributeValueId__c = attributeList[1].Id;
        update lineItemList;
        Test.startTest();
            List<Apttus_Config2__LineItem__c> tstQLI = new SLT_LineItem().getCLIWithAttributesByQuoteId(new Set<Id> {quote.Id}, fieldSet, optionCodes, bundleCodes, new Set<String>{'Bundle', 'Option'});
        	List<Apttus_Config2__LineItem__c> quoteLineItem = new SLT_LineItem().getLineItemsWithAttributesByQuoteId(new Set<Id> {proposal.Id}, fieldSet, optionCodes, bundleCodes);
        Test.stopTest();
        System.assertEquals(quoteLineItem.size() > 0, true, 'Records Exists');
    }

    @IsTest
    static void testGetLineItemsByProposalId() {
        Set<Id> lineItemIdSet = new Set<Id>();
        Id prodConfigId = getProdConfigId();
        
        Product2 prod = UTL_OCE_TestData.createProduct(CON_OCE.TEST_PRODUCT1_NAME, null, null, null);
        insert prod;
        
        Apttus_Config2__LineItem__c lineItem = UTL_OCE_TestData.createPrimaryConfigLineItem(prodConfigId, 1, 1, prod.Id, 1, 0);
        insert lineItem;
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];

        List<Apttus_Config2__LineItem__c> lineItemList;
        String condition = 'Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c = ' + '\'' + proposal.Id + '\'';
        Test.startTest();
            lineItemList = new SLT_LineItem().getLineItemsByProposalId(new Set<Id>{proposal.Id}, new Set<String>{CON_CPQ.ID});
            List<Apttus_Config2__LineItem__c> lineItemListByCondition = new SLT_LineItem().getLineItemsByCondtion(condition, new Set<String>{CON_CPQ.ID});
        Test.stopTest();
        System.assertEquals(1, lineItemList.size(), '1 Apttus_Config2__LineItem__c Records' );
    }
}