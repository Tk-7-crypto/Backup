@isTest(SeeAllData = false)
public with sharing class TST_TestGeneratorClass {
    public static Account buildtestAccount(Id userId) {
        Account acc = new Account();
        acc.Name = 'TAccount' ;
        acc.ownerId = userId; 
        acc.BillingStreet = 'test street';
        acc.BillingCity = 'test city';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode = '34534';
        acc.CustomerSegment__c = 'GOVERNMENT';
        acc.Sub_Industry__c = 'STATE';
        return acc;
    }
    public static Apttus_Config2__PriceList__c buildTestPriceList(String priceListName) {
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        priceList.Apttus_Config2__Active__c = true;
        priceList.Name = priceListName;
        priceList.Migration_Id__c = 'PL-12';
        return PriceList;
    }
    public static Product2 buildTestProduct(String productName, String type, String code, String modality, String salesFunction) {
        Product2 product = new Product2();
        product.IsActive = true;
        product.Name = productName;
        product.ProductCode = code;
        product.Apttus_Config2__ConfigurationType__c = type;
        return product;
    }
    
    public static Apttus_Config2__PriceListItem__c buildTestPriceListItem(Id priceListid, Id productId, String migrationId) {
        Apttus_Config2__PriceListItem__c priceListItem = new Apttus_Config2__PriceListItem__c();
        PriceListItem.Apttus_Config2__Active__c = true;
        PriceListItem.Apttus_Config2__PriceListId__c = PriceListid;
        PriceListItem.Apttus_Config2__ProductId__c = Productid;
        PriceListItem.Apttus_Config2__PriceType__c = 'One Time';
        PriceListItem.Apttus_Config2__PriceMethod__c = 'Per Unit';
        PriceListItem.Apttus_Config2__ListPrice__c = 0;
        PriceListItem.Apttus_Config2__PriceUom__c = 'Each';
        PriceListItem.Apttus_Config2__RollupPriceToBundle__c = true; 
        PriceListItem.Apttus_Config2__AllowManualAdjustment__c = true;
        PriceListItem.Apttus_Config2__AllocateGroupAdjustment__c = true; 
        PriceListItem.Migration_Id__c = migrationId;
        return PriceListItem;
    }

    public static Id buildTestConfiguration(Id proposalId) {
        Apttus_Config2__ProductConfiguration__c pc = new Apttus_Config2__ProductConfiguration__c();
        pc.Apttus_QPConfig__Proposald__c = proposalId;
        insert pc;
        return pc.Id;
    }

    public static boolean buildTestFinalizeCart(Id proposalId, Id bundleProductId, Map<String,String> childProductIds) {
        Id configId;
        if(proposalId != null){
            configId= buildTestConfiguration(proposalId); 
        }
        Apttus_CPQApi.CPQ.AddBundleRequestDO request=new Apttus_CPQApi.CPQ.AddBundleRequestDO();
        request.CartId= configId;         
        Apttus_CPQApi.CPQ.SelectedBundleDO selectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();
        Apttus_CPQApi.CPQ.SelectedProductDO selectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
        SelectedProduct.ProductId = bundleProductId;
        SelectedProduct.Quantity = 1;
        SelectedProduct.StartDate = system.today();
        SelectedProduct.EndDate = system.today().addMonths(2);
        SelectedBundle.SelectedProduct = selectedProduct;
        List<Apttus_CPQApi.CPQ.SelectedOptionDO> selectedOptionDoList = new list<Apttus_CPQApi.CPQ.SelectedOptionDO>();
        
        for(String productId : childProductIds.keySet()){
            String componentId = childProductIds.get(productId);
            Apttus_CPQApi.CPQ.SelectedOptionDO option = new Apttus_CPQApi.CPQ.SelectedOptionDO();
            option.ComponentId = componentId ;
            option.ComponentProductId =productId;
            option.Quantity = 1;
            selectedOptionDoList.add(option);
        }
        SelectedBundle.SelectedOptions = selectedOptionDoList;
        request.SelectedBundle = selectedBundle;
        Apttus_CPQApi.CPQ.AddBundleResponseDO addBundleRespons = Apttus_CPQApi.CPQWebService.addBundle(request); 
        List<Apttus_Config2__LineItem__c> items = [Select Id From Apttus_Config2__LineItem__c];
        for (Apttus_Config2__LineItem__c item: items) {
            item.Apttus_Config2__ChargeType__c = 'Subscription Fee';
        }
        update items;
        // Create Adjustments
        Apttus_Config2.PricingWebService.updatePriceForCart(configId);
        // Edit Adjustments
        Apttus_Config2.PricingWebService.updatePriceForCart(configId);
        return true;
    }
    
    public static Apttus_Proposal__Proposal__c setProposalData(String recordTypeName, Id opportunityId, String pricingTool, Id bidId,id pricelist) {
        Id recordTypeId = SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'test proposal');
        testProposal.Apttus_Proposal__Opportunity__c = opportunityId;
        testProposal.RecordTypeId = recordTypeId;
        testProposal.Apttus_QPConfig__PriceListId__c = pricelist;
        testProposal.Select_Pricing_Tool__c = CON_CPQ.AMESA;      
        testProposal.Scenario_Number__c = 123.0;
        testProposal.Budget_Iteration__c = 1;
        testProposal.Apttus_Proposal__Primary__c = true;
        testProposal.Apttus_QPConfig__PriceListId__c  = pricelist;
        insert testProposal;
        return testProposal;
    }
    // Create Option Line Item
    public static Apttus_Config2__LineItem__c createOptionConfigLineItem(Id configId, Integer lineNumber, Integer itemSequence, Id productId, Id optionId, Decimal quantity, Decimal price) {
        return createLineItem(configId, CON_OCE.PRODUCT_OPTION, false, lineNumber, itemSequence, productId, optionId, quantity, price);
    }
    
    public static Apttus_Config2__LineItem__c createLineItem( Id configId, String lineType, Boolean isPrimary, Integer lineNumber, Integer itemSequence, Id productId, Id optionId, Decimal quantity, Decimal price) {
        Apttus_Config2__LineItem__c lineItem = new Apttus_Config2__LineItem__c();
        lineItem.Apttus_Config2__ConfigurationId__c = configId;
        lineItem.Apttus_Config2__LineNumber__c = lineNumber;
        lineItem.Apttus_Config2__PrimaryLineNumber__c = lineNumber;
        lineItem.Apttus_Config2__ItemSequence__c = itemSequence;
        lineItem.Apttus_Config2__LineType__c = lineType;
        lineItem.Apttus_Config2__IsPrimaryLine__c = isPrimary;
        lineItem.Apttus_Config2__ProductId__c = productId;
        lineItem.Apttus_Config2__OptionId__c = optionId;
        lineItem.Apttus_Config2__Quantity__c = quantity;
        lineItem.Apttus_Config2__NetPrice__c = price;
        lineItem.Apttus_Config2__ExtendedPrice__c = 1000;
        return lineItem;
    }
    
    public static Opportunity buildTestOpportunity(Integer i, Id accId, Id ownerId, Id priceBookId, Boolean isOpen, Boolean isClosed) {
        Opportunity opp = new Opportunity();
        opp.AccountId = accId;
        opp.OwnerId = OwnerId;
        opp.Name = 'TOpportunity' + i;
        if(isOpen){
            opp.CloseDate = System.today() + 5;
            opp.StageName = 'test';
        }      
        else if(isClosed){
            opp.CloseDate = System.today() - 5;      
            opp.StageName = 'test';
        }
        if(priceBookId != null){
            opp.Pricebook2Id = priceBookId;
        }
        //opp.CurrencyIsoCode = 'USD';
        return opp;
    }

}
