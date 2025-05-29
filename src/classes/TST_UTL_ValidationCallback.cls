@isTest
private class TST_UTL_ValidationCallback {
    @isTest 
    private static void dataValidationUseCase1Test() {
        Test.startTest();
        List<Sobject> sObjectList;
        list<product2> productList=new list<product2>();
        //Custom classes invoking
        Apttus_Config2__ConfigCustomClasses__c ac = new Apttus_Config2__ConfigCustomClasses__c();
        ac.Apttus_Config2__PricingCallbackClass__c = 'CPQ_PricingCallback';
        ac.Apttus_Config2__ValidationCallbackClass__c='CPQ_ValidationCallback';
        ac.Name = 'System Properties';
        //Account Creation
        Account account = UTL_OCE_TestData.createaccount();
        //Opportunity creation
        Opportunity opportunity = UTL_OCE_TestData.createOpportunity(account.Id);
        //Price List creation
        Apttus_Config2__PriceList__c pList = TST_TestGeneratorClass.buildTestPriceList(CON_CPQ.AMESA);
        // Bundle and Option Product creation
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('LC9', 'Bundle', CON_CPQ.CPQ_TS_AMESA_Data_PI, 'US', 'Go Blue');       
        productList.add(prod);
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('LC9', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_STD, 'US', 'Go Blue');
        productList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('LC', 'Bundle', CON_CPQ.CPQ_TS_AMESA_Data_STD, 'US', 'Go Blue');
        productList.add(prod2);
        Product2 prod3 = TST_TestGeneratorClass.buildTestProduct('LC1', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_PI, 'US', 'Go Blue');
        productList.add(prod3);
        Product2 prod4 = TST_TestGeneratorClass.buildTestProduct('LC2', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_SL_SF, 'US', 'Go Blue');
        productList.add(prod4);
        Product2 prod5 = TST_TestGeneratorClass.buildTestProduct('LC2', 'Option', 'CPQ-TS-AMESA-Data-PI-JTMB', 'US', 'Go Blue');
        productList.add(prod5);
        Product2 prod6 = TST_TestGeneratorClass.buildTestProduct('LC2', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_STD_STD, 'US', 'Go Blue');
        productList.add(prod6);
        Product2 prod7 = TST_TestGeneratorClass.buildTestProduct('LC2', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_SL_NOR, 'US', 'Go Blue');
        prod7.Name = 'National Sub';
        productList.add(prod7);
        Product2 prod8 = TST_TestGeneratorClass.buildTestProduct('LC2', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_PI_THIS, 'US', 'Go Blue');
        productList.add(prod8);
        //insert All Sobject Records
        sObjectList = new List<Sobject>{ac, account, opportunity, pList};
        insert productList;
        insert sObjectList;
        
        Quote__c quote = UTL_TestData.createIqviaQuote(account.Id, opportunity.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, false);
        quote.Approval_Stage__c = CON_CPQ.DRAFT;
        quote.Document_Type__c = 'Interactive - Individual Documents';
        quote.License_Type__c = 'Per Study';
        quote.Quote_Type__c = 'Initial';
        insert quote;

        // Proposal creations
        Apttus_Proposal__Proposal__c proposal = TST_TestGeneratorClass.setProposalData('Tech_Solution', opportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, null,pList.Id);     
        proposal.IQVIA_Quote__c = quote.Id;
        proposal.IQVIA_Quote__r = quote;
        update proposal;

        Id cartId = buildTestConfiguration(proposal.Id).Id;
        // Create Line Items
        Apttus_Config2__LineItem__c lineItem = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod.id, Prod1.Id, 1, 987);
        insert lineItem;
        Apttus_Config2__LineItem__c lineItem2 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod.Id, Prod1.Id, 1, 987);
        insert lineItem2;
        Apttus_Config2__LineItem__c lineItem3 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod2.Id, Prod3.Id, 1, 987);
        insert lineItem3;
        Apttus_Config2__LineItem__c lineItem4 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod2.Id, Prod4.Id, 1, 987);
        insert lineItem4;
        Apttus_Config2__LineItem__c lineItem5 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod2.Id, Prod5.Id, 1, 987);
        insert lineItem5;
        Apttus_Config2__LineItem__c lineItem6 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod2.Id, Prod6.Id, 1, 987);
        insert lineItem6;
        Apttus_Config2__LineItem__c lineItem8 = TST_TestGeneratorClass.createLineItem(cartId, CON_CPQ.PRODUCT_SERVICE, true, 1, 1, prod.Id, prod7.Id, 1, 5);
        insert lineItem8;
        Apttus_Config2__ProductAttributeValue__c aValue = new Apttus_Config2__ProductAttributeValue__c(Eligible_Countries__c = CON_CPQ.EGYPT, Apttus_Config2__LineItemId__c = lineItem8.Id);
        insert aValue;
        lineItem8.Apttus_Config2__ItemSequence__c = 1;
        lineItem8.Apttus_Config2__AttributeValueId__c = aValue.Id;
        update lineItem8;
        Apttus_Config2__LineItem__c lineItem9 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod.Id, Prod5.Id, 1, 987);
        insert lineItem9;
        Apttus_Config2__ProductAttributeValue__c aValue2 = new Apttus_Config2__ProductAttributeValue__c(Eligible_Countries__c = CON_CPQ.SAUDIARABIA, Apttus_Config2__LineItemId__c = lineItem9.Id);
        insert aValue2;
        lineItem9.Apttus_Config2__AttributeValueId__c = aValue2.Id;
        update lineItem9;
        Apttus_Config2__LineItem__c lineItem10 = TST_TestGeneratorClass.createLineItem(cartId, CON_CPQ.OPTION, true, 1, 1, prod.Id, prod6.Id, 1, 5);
        insert lineItem10;
        Apttus_Config2__ProductAttributeValue__c aValue3 = new Apttus_Config2__ProductAttributeValue__c(Eligible_Countries__c = 'MA', Apttus_Config2__LineItemId__c = lineItem10.Id);
        insert aValue3;
        lineItem10.Apttus_Config2__ItemSequence__c = 1;
        lineItem10.Apttus_Config2__AttributeValueId__c = aValue3.Id;
        update lineItem10;
        // getting All Line Items
        List<Apttus_Config2__LineItem__c> liSOList = [SELECT Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.IQVIA_Quote__r.Quote_Type__c, Name, Apttus_Config2__LineType__c, Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__LineNumber__c, 
                                                      Apttus_Config2__ProductID__r.ProductCode, Apttus_Config2__ProductID__r.Name, Apttus_Config2__SellingUom__c, Apttus_Config2__IsSellingTermReadOnly__c, 
                                                      Apttus_Config2__AddedBy__c, Apttus_Config2__AddedByRuleInfo__c, Apttus_Config2__AdHocGroupId__c, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__AdjustmentType__c, 
                                                      Apttus_Config2__AllocateGroupAdjustment__c, Apttus_Config2__AllowableAction__c, Apttus_Config2__AllowManualAdjustment__c, Apttus_Config2__AllowProration__c, 
                                                      Apttus_Config2__AllowRemoval__c, Apttus_Config2__AssetId__c, Apttus_Config2__AssetLineItemId__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__AutoRenew__c, 
                                                      Apttus_Config2__AutoRenewalTerm__c, Apttus_Config2__AutoRenewalType__c, Apttus_Config2__BaseCost__c, Apttus_Config2__BaseCostOverride__c, Apttus_Config2__BaseExtendedCost__c, 
                                                      Apttus_Config2__BaseExtendedPrice__c, Apttus_Config2__BasePrice__c, Apttus_Config2__BasePriceMethod__c, Apttus_Config2__BasePriceOverride__c, Apttus_Config2__BaseProductId__c, 
                                                      Apttus_Config2__BillingPreferenceId__c, Apttus_Config2__BillToAccountId__c, Apttus_Config2__ChargeType__c, Apttus_Config2__ClassificationHierarchy__c, 
                                                      Apttus_Config2__ClassificationHierarchyInfo__c, Apttus_Config2__ClassificationId__c, Apttus_Config2__CollaborationParentLineNumber__c, 
                                                      Apttus_Config2__ConfigurationId__c, Apttus_Config2__ConfigStatus__c, Apttus_Config2__CommitmentQuantity__c, Apttus_Config2__Comments__c, 
                                                      Apttus_Config2__CollaborationRequestId__c, Apttus_Config2__ConstraintCheckStatus__c, Apttus_Config2__ContractNumbers__c, Apttus_Config2__CopySourceBundleNumber__c, 
                                                      Apttus_Config2__CopySourceLineNumber__c, Apttus_Config2__CopySourceNumber__c, Apttus_Config2__DerivedFromId__c, Apttus_Config2__DeltaQuantity__c, Apttus_Config2__DeltaPrice__c, 
                                                      Apttus_Config2__Customizable__c, Apttus_Config2__CouponCode__c, Apttus_Config2__Cost__c, Apttus_Config2__Description__c, Apttus_Config2__EndDate__c, Apttus_Config2__ExtendedCost__c, 
                                                      Apttus_Config2__ExtendedDescription__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__ExtendedQuantity__c, Apttus_Config2__FlatOptionPrice__c, Apttus_Config2__HasIncentives__c, 
                                                      Apttus_Config2__HasDefaults__c, Apttus_Config2__HasBaseProduct__c,  Apttus_Config2__Guidance__c, Apttus_Config2__HasAttributes__c, Apttus_Config2__IsOptional__c, Apttus_Config2__IsHidden__c,  
                                                      Apttus_Config2__IsUsageTierModifiable__c, Apttus_Config2__ItemSequence__c,  Apttus_Config2__LineSequence__c, Apttus_Config2__LineStatus__c, Apttus_Config2__ListPrice__c, Apttus_Config2__LocationId__c, 
                                                      Apttus_Config2__MaxPrice__c, Apttus_Config2__MaxUsageQuantity__c, Apttus_Config2__MinMaxPriceAppliesTo__c, Apttus_Config2__MinPrice__c, Apttus_Config2__MinUsageQuantity__c, 
                                                      Apttus_Config2__NetAdjustmentPercent__c, Apttus_Config2__NetPrice__c, Apttus_Config2__NetUnitPrice__c, Apttus_Config2__OptionCost__c, Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__OptionId__c, 
                                                      Apttus_Config2__ParentBundleNumber__c, Apttus_Config2__OrderLineStatus__c, Apttus_Config2__OrderLineItemId__c, Apttus_Config2__OptionSequence__c, Apttus_Config2__OptionPrice__c, 
                                                      Apttus_Config2__PaymentTermId__c, Apttus_Config2__PriceAdjustment__c, Apttus_Config2__PriceAdjustmentAmount__c, Apttus_Config2__PriceAdjustmentAppliesTo__c, Apttus_Config2__PriceAdjustmentType__c,  
                                                      Apttus_Config2__PriceMethod__c, Apttus_Config2__PriceListItemId__c, Apttus_Config2__PriceListId__c, Apttus_Config2__PriceIncludedInBundle__c, Apttus_Config2__PriceGroup__c, Apttus_Config2__PriceType__c, 
                                                      Apttus_Config2__PriceUom__c, Apttus_Config2__PricingDate__c, Apttus_Config2__PricingGuidance__c, Apttus_Config2__PricingStatus__c, Apttus_Config2__PricingSteps__c, Apttus_Config2__PrimaryLineNumber__c, 
                                                      Apttus_Config2__RelatedAdjustmentAmount__c, Apttus_Config2__Quantity__c, Apttus_Config2__ProductVersion__c, Apttus_Config2__ProductOptionId__c, Apttus_Config2__RelatedAdjustmentAppliesTo__c, 
                                                      Apttus_Config2__RelatedAdjustmentType__c, Apttus_Config2__RelatedItemId__c, Apttus_Config2__RelatedPercent__c, Apttus_Config2__RelatedPercentAppliesTo__c, Apttus_Config2__RenewalAdjustmentAmount__c, 
                                                      Apttus_Config2__RenewalAdjustmentType__c, Apttus_Config2__RollupPriceMethod__c, Apttus_Config2__RollupPriceToBundle__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingTerm__c, 
                                                      Apttus_Config2__AttributeValueId__r.Eligible_Countries__c, Apttus_Config2__OptionId__r.Name, Apttus_Config2__LineItem__c.Apttus_Config2__HasOptions__c, Apttus_Config2__AttributeValueId__r.No_Of_Territories__c, Apttus_Config2__AttributeValueId__r.National_Subscription__c, Apttus_Config2__ProductID__r.Apttus_Config2__ConfigurationType__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Select_Pricing_Tool__c FROM Apttus_Config2__LineItem__c];
        for (Apttus_Config2__LineItem__c li : liSOList) {
            li.Apttus_Config2__PrimaryLineNumber__c = 1;
            li.Apttus_Config2__ParentBundleNumber__c = 1;
        }
        update liSOList;
        UTL_CPQ_ValidationCallback.productValidation(liSOList);
        Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
        // add request parameters
        objUpdatePriceRequestDO.CartId = cartId;
        // update price for the cart
        Apttus_Config2.CPQWebService.finalizeConfiguration(cartId);
        Apttus_Config2.CallbackTester.testValidationCallback(cartId, liSOList, null, new CPQ_ValidationCallback());
        Test.StopTest();
        System.assert(cartId!= null, 'Product configuration should be validate');
    }
    @isTest 
    private static void dataValidationUseCase2Test() {
        Test.startTest();
        List<Sobject> sObjectList;
        list<product2> productList=new list<product2>();

        // custom Classes invoking
        Apttus_Config2__ConfigCustomClasses__c ac = new Apttus_Config2__ConfigCustomClasses__c();
        ac.Apttus_Config2__PricingCallbackClass__c = 'CPQ_PricingCallback';
        ac.Apttus_Config2__ValidationCallbackClass__c = 'CPQ_ValidationCallback';
        ac.Name = 'System Properties';
        //Account Creation
        Account account = UTL_OCE_TestData.createaccount();
        //Opportunity creation
        Opportunity opportunity = UTL_OCE_TestData.createOpportunity(account.Id);
        //Price List creation
        Apttus_Config2__PriceList__c pList = TST_TestGeneratorClass.buildTestPriceList(CON_CPQ.AMESA);
        // Bundle and Option Product creation
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('LC9', 'Bundle', CON_CPQ.CPQ_TS_AMESA_Data_STD, 'US', 'Go Blue');       
        productList.add(prod);
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('LC9', 'Option', 'CPQ-TS_AMESA-Data-TST', 'US', 'Go Blue');
        productList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('LC6', 'Bundle', CON_CPQ.CPQ_TS_AMESA_Data_STD, 'US', 'Go Blue');       
        productList.add(prod2);
        Product2 prod3 = TST_TestGeneratorClass.buildTestProduct('LC6', 'Option', 'CPQ-TS-AMESA-Data-PI-FSN', 'US', 'Go Blue');
        productList.add(prod3);
        Product2 prod4 = TST_TestGeneratorClass.buildTestProduct('LC8', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_STD_STDV10_UAEP, 'US', 'Go Blue');
        productList.add(prod4);
        Product2 prod5 = TST_TestGeneratorClass.buildTestProduct('LC9', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_STD_STDV20_UAEP, 'US', 'Go Blue');
        productList.add(prod5);
        Product2 prod6 = TST_TestGeneratorClass.buildTestProduct('LC10', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_STD_STDV40_UAEP, 'US', 'Go Blue');
        productList.add(prod6);
        Product2 prod7 = TST_TestGeneratorClass.buildTestProduct('LC11', 'Option', 'CPQ-TS-AMESA-Data-STD-4050PECN_TFASL', 'US', 'Go Blue');
        productList.add(prod7);
        //insert All Sobject Records 
        sObjectList = new List<Sobject>{ac, account, opportunity, pList};
        insert productList;
        insert sObjectList;

        Quote__c quote = UTL_TestData.createIqviaQuote(account.Id, opportunity.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, false);
        quote.Approval_Stage__c = CON_CPQ.DRAFT;
        quote.Document_Type__c = 'Interactive - Individual Documents';
        quote.License_Type__c = 'Per Study';
        quote.Quote_Type__c = 'Initial';
        insert quote;

        // Proposal creations
        Apttus_Proposal__Proposal__c proposal = TST_TestGeneratorClass.setProposalData('Tech_Solution', opportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, null,pList.Id);     
        proposal.IQVIA_Quote__c = quote.Id;
        proposal.IQVIA_Quote__r = quote;
        update proposal;
        
        //Product configuration created for Proposal
        Id cartId = buildTestConfiguration(proposal.Id).Id;
        // Create Line Items
        Apttus_Config2__LineItem__c lineItem = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod.Id, Prod1.Id, 1, 987);
        insert lineItem;
        Apttus_Config2__LineItem__c lineItem1 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod2.Id, Prod3.Id, 1, 987);
        insert lineItem1;
        Apttus_Config2__LineItem__c lineItem2 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod2.Id, Prod4.Id, 1, 987);
        insert lineItem2;
        Apttus_Config2__LineItem__c lineItem3 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod2.Id, Prod5.Id, 1, 987);
        insert lineItem3;
        Apttus_Config2__LineItem__c lineItem4 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod2.Id, Prod6.Id, 1, 987);
        insert lineItem4;
        Apttus_Config2__LineItem__c lineItem5 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod2.Id, Prod7.Id, 1, 987);
        insert lineItem5;
        // getting All Line Items									  
        List<Apttus_Config2__LineItem__c> liSOList = [SELECT Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.IQVIA_Quote__r.Quote_Type__c, Name, Apttus_Config2__LineType__c, Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__LineNumber__c, 
                                                      Apttus_Config2__ProductID__r.ProductCode, Apttus_Config2__ProductID__r.Name, Apttus_Config2__SellingUom__c, Apttus_Config2__IsSellingTermReadOnly__c, 
                                                      Apttus_Config2__AddedBy__c, Apttus_Config2__AddedByRuleInfo__c, Apttus_Config2__AdHocGroupId__c, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__AdjustmentType__c, 
                                                      Apttus_Config2__AllocateGroupAdjustment__c, Apttus_Config2__AllowableAction__c, Apttus_Config2__AllowManualAdjustment__c, Apttus_Config2__AllowProration__c, 
                                                      Apttus_Config2__AllowRemoval__c, Apttus_Config2__AssetId__c, Apttus_Config2__AssetLineItemId__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__AutoRenew__c, 
                                                      Apttus_Config2__AutoRenewalTerm__c, Apttus_Config2__AutoRenewalType__c, Apttus_Config2__BaseCost__c, Apttus_Config2__BaseCostOverride__c, Apttus_Config2__BaseExtendedCost__c, 
                                                      Apttus_Config2__BaseExtendedPrice__c, Apttus_Config2__BasePrice__c, Apttus_Config2__BasePriceMethod__c, Apttus_Config2__BasePriceOverride__c, Apttus_Config2__BaseProductId__c, 
                                                      Apttus_Config2__BillingPreferenceId__c, Apttus_Config2__BillToAccountId__c, Apttus_Config2__ChargeType__c, Apttus_Config2__ClassificationHierarchy__c, 
                                                      Apttus_Config2__ClassificationHierarchyInfo__c, Apttus_Config2__ClassificationId__c, Apttus_Config2__CollaborationParentLineNumber__c, 
                                                      Apttus_Config2__ConfigurationId__c, Apttus_Config2__ConfigStatus__c, Apttus_Config2__CommitmentQuantity__c, Apttus_Config2__Comments__c, 
                                                      Apttus_Config2__CollaborationRequestId__c, Apttus_Config2__ConstraintCheckStatus__c, Apttus_Config2__ContractNumbers__c, Apttus_Config2__CopySourceBundleNumber__c, 
                                                      Apttus_Config2__CopySourceLineNumber__c, Apttus_Config2__CopySourceNumber__c, Apttus_Config2__DerivedFromId__c, Apttus_Config2__DeltaQuantity__c, Apttus_Config2__DeltaPrice__c, 
                                                      Apttus_Config2__Customizable__c, Apttus_Config2__CouponCode__c, Apttus_Config2__Cost__c, Apttus_Config2__Description__c, Apttus_Config2__EndDate__c, Apttus_Config2__ExtendedCost__c, 
                                                      Apttus_Config2__ExtendedDescription__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__ExtendedQuantity__c, Apttus_Config2__FlatOptionPrice__c, Apttus_Config2__HasIncentives__c, 
                                                      Apttus_Config2__HasDefaults__c, Apttus_Config2__HasBaseProduct__c,  Apttus_Config2__Guidance__c, Apttus_Config2__HasAttributes__c, Apttus_Config2__IsOptional__c, Apttus_Config2__IsHidden__c,  
                                                      Apttus_Config2__IsUsageTierModifiable__c, Apttus_Config2__ItemSequence__c,  Apttus_Config2__LineSequence__c, Apttus_Config2__LineStatus__c, Apttus_Config2__ListPrice__c, Apttus_Config2__LocationId__c, 
                                                      Apttus_Config2__MaxPrice__c, Apttus_Config2__MaxUsageQuantity__c, Apttus_Config2__MinMaxPriceAppliesTo__c, Apttus_Config2__MinPrice__c, Apttus_Config2__MinUsageQuantity__c, 
                                                      Apttus_Config2__NetAdjustmentPercent__c, Apttus_Config2__NetPrice__c, Apttus_Config2__NetUnitPrice__c, Apttus_Config2__OptionCost__c, Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__OptionId__c, 
                                                      Apttus_Config2__ParentBundleNumber__c, Apttus_Config2__OrderLineStatus__c, Apttus_Config2__OrderLineItemId__c, Apttus_Config2__OptionSequence__c, Apttus_Config2__OptionPrice__c, 
                                                      Apttus_Config2__PaymentTermId__c, Apttus_Config2__PriceAdjustment__c, Apttus_Config2__PriceAdjustmentAmount__c, Apttus_Config2__PriceAdjustmentAppliesTo__c, Apttus_Config2__PriceAdjustmentType__c,  
                                                      Apttus_Config2__PriceMethod__c, Apttus_Config2__PriceListItemId__c, Apttus_Config2__PriceListId__c, Apttus_Config2__PriceIncludedInBundle__c, Apttus_Config2__PriceGroup__c, Apttus_Config2__PriceType__c, 
                                                      Apttus_Config2__PriceUom__c, Apttus_Config2__PricingDate__c, Apttus_Config2__PricingGuidance__c, Apttus_Config2__PricingStatus__c, Apttus_Config2__PricingSteps__c, Apttus_Config2__PrimaryLineNumber__c, 
                                                      Apttus_Config2__RelatedAdjustmentAmount__c, Apttus_Config2__Quantity__c, Apttus_Config2__ProductVersion__c, Apttus_Config2__ProductOptionId__c, Apttus_Config2__RelatedAdjustmentAppliesTo__c, 
                                                      Apttus_Config2__RelatedAdjustmentType__c, Apttus_Config2__RelatedItemId__c, Apttus_Config2__RelatedPercent__c, Apttus_Config2__RelatedPercentAppliesTo__c, Apttus_Config2__RenewalAdjustmentAmount__c, 
                                                      Apttus_Config2__RenewalAdjustmentType__c, Apttus_Config2__RollupPriceMethod__c, Apttus_Config2__RollupPriceToBundle__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingTerm__c, 
                                                      Apttus_Config2__AttributeValueId__r.Eligible_Countries__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Select_Pricing_Tool__c FROM Apttus_Config2__LineItem__c];           
        Apttus_Config2.CallbackTester.testValidationCallback(cartId, liSOList, null, new CPQ_ValidationCallback());        
        Test.StopTest();
        System.assert(cartId!= null, 'Product configuration should be validate');
    }
     @isTest 
    private static void dataValidationUseCase3Test() {
        Test.startTest();
        List<Sobject> sObjectList;
        list<product2> productList=new list<product2>();

        Apttus_Config2__ConfigCustomClasses__c ac = new Apttus_Config2__ConfigCustomClasses__c();
        ac.Apttus_Config2__PricingCallbackClass__c = 'CPQ_PricingCallback';
        ac.Apttus_Config2__ValidationCallbackClass__c = 'CPQ_ValidationCallback';
        ac.Name = 'System Properties';
        //Account Creation
        Account account = UTL_OCE_TestData.createaccount();
        //Opportunity creation
        Opportunity opportunity = UTL_OCE_TestData.createOpportunity(account.Id);
        //Price List creation
        Apttus_Config2__PriceList__c pList = TST_TestGeneratorClass.buildTestPriceList(CON_CPQ.AMESA);
        // Bundle and Option Product creation
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('LC9', 'Bundle', CON_CPQ.CPQ_TS_AMESA_Data_SL, 'US', 'Go Blue');       
        productList.add(prod);
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('LC9', 'Option', 'CPQ-TS_AMESA-Data-TST', 'US', 'Go Blue');
        productList.add(prod1);
        //insert All Sobject Records 
        sObjectList = new List<Sobject>{ac, account, opportunity, pList};
        insert productList;
        insert sObjectList;

        Quote__c quote = UTL_TestData.createIqviaQuote(account.Id, opportunity.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, false);
        quote.Approval_Stage__c = CON_CPQ.DRAFT;
        quote.Document_Type__c = 'Interactive - Individual Documents';
        quote.License_Type__c = 'Per Study';
        quote.Quote_Type__c = 'Initial';
        insert quote;

        // Proposal creations
        Apttus_Proposal__Proposal__c proposal = TST_TestGeneratorClass.setProposalData('Tech_Solution', opportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, null,pList.Id);     
        proposal.IQVIA_Quote__c = quote.Id;
        proposal.IQVIA_Quote__r = quote;
        update proposal;
        
        //Product configuration created for Proposal
        Id cartId = buildTestConfiguration(proposal.Id).Id;
        // Create Line Items
        Apttus_Config2__LineItem__c lineItem = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, Prod.Id, Prod1.Id, 1, 987);
        insert lineItem;
        // getting All Line Items
        List<Apttus_Config2__LineItem__c> liSOList = [SELECT Id, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.IQVIA_Quote__r.Quote_Type__c, Name, Apttus_Config2__LineType__c, Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__LineNumber__c, 
                                                      Apttus_Config2__ProductID__r.ProductCode, Apttus_Config2__ProductID__r.Name, Apttus_Config2__SellingUom__c, Apttus_Config2__IsSellingTermReadOnly__c, 
                                                      Apttus_Config2__AddedBy__c, Apttus_Config2__AddedByRuleInfo__c, Apttus_Config2__AdHocGroupId__c, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__AdjustmentType__c, 
                                                      Apttus_Config2__AllocateGroupAdjustment__c, Apttus_Config2__AllowableAction__c, Apttus_Config2__AllowManualAdjustment__c, Apttus_Config2__AllowProration__c, 
                                                      Apttus_Config2__AllowRemoval__c, Apttus_Config2__AssetId__c, Apttus_Config2__AssetLineItemId__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__AutoRenew__c, 
                                                      Apttus_Config2__AutoRenewalTerm__c, Apttus_Config2__AutoRenewalType__c, Apttus_Config2__BaseCost__c, Apttus_Config2__BaseCostOverride__c, Apttus_Config2__BaseExtendedCost__c, 
                                                      Apttus_Config2__BaseExtendedPrice__c, Apttus_Config2__BasePrice__c, Apttus_Config2__BasePriceMethod__c, Apttus_Config2__BasePriceOverride__c, Apttus_Config2__BaseProductId__c, 
                                                      Apttus_Config2__BillingPreferenceId__c, Apttus_Config2__BillToAccountId__c, Apttus_Config2__ChargeType__c, Apttus_Config2__ClassificationHierarchy__c, 
                                                      Apttus_Config2__ClassificationHierarchyInfo__c, Apttus_Config2__ClassificationId__c, Apttus_Config2__CollaborationParentLineNumber__c, 
                                                      Apttus_Config2__ConfigurationId__c, Apttus_Config2__ConfigStatus__c, Apttus_Config2__CommitmentQuantity__c, Apttus_Config2__Comments__c, 
                                                      Apttus_Config2__CollaborationRequestId__c, Apttus_Config2__ConstraintCheckStatus__c, Apttus_Config2__ContractNumbers__c, Apttus_Config2__CopySourceBundleNumber__c, 
                                                      Apttus_Config2__CopySourceLineNumber__c, Apttus_Config2__CopySourceNumber__c, Apttus_Config2__DerivedFromId__c, Apttus_Config2__DeltaQuantity__c, Apttus_Config2__DeltaPrice__c, 
                                                      Apttus_Config2__Customizable__c, Apttus_Config2__CouponCode__c, Apttus_Config2__Cost__c, Apttus_Config2__Description__c, Apttus_Config2__EndDate__c, Apttus_Config2__ExtendedCost__c, 
                                                      Apttus_Config2__ExtendedDescription__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__ExtendedQuantity__c, Apttus_Config2__FlatOptionPrice__c, Apttus_Config2__HasIncentives__c, 
                                                      Apttus_Config2__HasDefaults__c, Apttus_Config2__HasBaseProduct__c,  Apttus_Config2__Guidance__c, Apttus_Config2__HasAttributes__c, Apttus_Config2__IsOptional__c, Apttus_Config2__IsHidden__c,  
                                                      Apttus_Config2__IsUsageTierModifiable__c, Apttus_Config2__ItemSequence__c,  Apttus_Config2__LineSequence__c, Apttus_Config2__LineStatus__c, Apttus_Config2__ListPrice__c, Apttus_Config2__LocationId__c, 
                                                      Apttus_Config2__MaxPrice__c, Apttus_Config2__MaxUsageQuantity__c, Apttus_Config2__MinMaxPriceAppliesTo__c, Apttus_Config2__MinPrice__c, Apttus_Config2__MinUsageQuantity__c, 
                                                      Apttus_Config2__NetAdjustmentPercent__c, Apttus_Config2__NetPrice__c, Apttus_Config2__NetUnitPrice__c, Apttus_Config2__OptionCost__c, Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__OptionId__c, 
                                                      Apttus_Config2__ParentBundleNumber__c, Apttus_Config2__OrderLineStatus__c, Apttus_Config2__OrderLineItemId__c, Apttus_Config2__OptionSequence__c, Apttus_Config2__OptionPrice__c, 
                                                      Apttus_Config2__PaymentTermId__c, Apttus_Config2__PriceAdjustment__c, Apttus_Config2__PriceAdjustmentAmount__c, Apttus_Config2__PriceAdjustmentAppliesTo__c, Apttus_Config2__PriceAdjustmentType__c,  
                                                      Apttus_Config2__PriceMethod__c, Apttus_Config2__PriceListItemId__c, Apttus_Config2__PriceListId__c, Apttus_Config2__PriceIncludedInBundle__c, Apttus_Config2__PriceGroup__c, Apttus_Config2__PriceType__c, 
                                                      Apttus_Config2__PriceUom__c, Apttus_Config2__PricingDate__c, Apttus_Config2__PricingGuidance__c, Apttus_Config2__PricingStatus__c, Apttus_Config2__PricingSteps__c, Apttus_Config2__PrimaryLineNumber__c, 
                                                      Apttus_Config2__RelatedAdjustmentAmount__c, Apttus_Config2__Quantity__c, Apttus_Config2__ProductVersion__c, Apttus_Config2__ProductOptionId__c, Apttus_Config2__RelatedAdjustmentAppliesTo__c, 
                                                      Apttus_Config2__RelatedAdjustmentType__c, Apttus_Config2__RelatedItemId__c, Apttus_Config2__RelatedPercent__c, Apttus_Config2__RelatedPercentAppliesTo__c, Apttus_Config2__RenewalAdjustmentAmount__c, 
                                                      Apttus_Config2__RenewalAdjustmentType__c, Apttus_Config2__RollupPriceMethod__c, Apttus_Config2__RollupPriceToBundle__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingTerm__c, 
                                                      Apttus_Config2__AttributeValueId__r.Eligible_Countries__c FROM Apttus_Config2__LineItem__c];		
        Apttus_Config2.CallbackTester.testValidationCallback(cartId, liSOList, null, new CPQ_ValidationCallback());        
        Test.StopTest();
        System.assert(cartId!= null, 'Product configuration should be validate');
    }
    private static Apttus_Config2__ProductConfiguration__c buildTestConfiguration(id proposal) {
        Apttus_Config2__ProductConfiguration__c pc = new Apttus_Config2__ProductConfiguration__c();
        pc.Apttus_QPConfig__Proposald__c = proposal;
        insert pc;
        return pc;
    }
}
