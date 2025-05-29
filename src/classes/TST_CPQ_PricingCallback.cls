@isTest
private class TST_CPQ_PricingCallback {

    @testSetup
    static void createInitialDataSetup() {
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = CON_CPQ.CPQ_SETTINGS;
        cpqSetting.Key_Generation_Org__c = userInfo.getOrganizationId();
        insert cpqSetting;
        
        CPQ_Partial_Frequency_Price_Settings__c cpfps = new CPQ_Partial_Frequency_Price_Settings__c();
        cpfps.Name = CON_CPQ.MONTHLY;
        cpfps.Frequency__c = CON_CPQ.MONTHLY;
        cpfps.Discounted_Price__c = 1;
        insert cpfps;
        
        Account acc = TST_TestGeneratorClass.buildTestAccount(UserInfo.getUserId());
        acc.AccountCountry__c = CON_CPQ.AL;

        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
		
        Apttus_Config2__ConfigCustomClasses__c apttusPricingCallbackClass = new Apttus_Config2__ConfigCustomClasses__c();
        apttusPricingCallbackClass.Apttus_Config2__PricingCallbackClass__c = CON_CPQ.CPQ_PRICING_CALLBACK_CLASS;
        apttusPricingCallbackClass.Name = CON_CPQ.SYSTEM_PROPERTIES;

        insert new List<Sobject>{pl, acc, apttusPricingCallbackClass};

        Id priceBookId = Test.getStandardPricebookId();

        Opportunity opp = TST_TestGeneratorClass.buildTestOpportunity(1, acc.Id, UserInfo.getUserId(), priceBookId, false, true);
        opp.Phase_P__c = 'Phase 1';
        insert opp;
        
        Apttus_Proposal__Proposal__c proposal = TST_TestGeneratorClass.setProposalData(CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.AMESA, null, pl.Id);

        list<Product2> productList = new list<Product2>();
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('LC9', CON_CPQ.BUNDLE, 'LC9', 'US', 'Go Blue');
        productList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('LC9', CON_CPQ.OPTION, 'CPQ-TS-AMESA-Data-PI-KLPO', 'US', 'Go Blue');
        productList.add(prod2);
        Product2 prod3 = TST_TestGeneratorClass.buildTestProduct('Calendar Connector Integration', CON_CPQ.OPTION, 'OCEP_AO_CI', 'US', 'Go Blue');
        productList.add(prod3);
        Product2 prod4 = TST_TestGeneratorClass.buildTestProduct('Data Masking', CON_CPQ.OPTION, 'OCEP_AO_SF_DATAM', 'US', 'Go Blue');
        productList.add(prod4);
        Product2 prod5 = TST_TestGeneratorClass.buildTestProduct('Architect', CON_CPQ.OPTION, 'OCE_Architect', 'US', 'Go Blue');
        productList.add(prod5);
        Product2 prod6 = TST_TestGeneratorClass.buildTestProduct('Concur Integration', CON_CPQ.OPTION, 'OCEP_AO_CONCUR_INT', 'US', 'Go Blue');
        productList.add(prod6);
        Product2 prod7 = TST_TestGeneratorClass.buildTestProduct('OCE Sales Subscription', CON_CPQ.BUNDLE, 'CE1447', 'US', 'Go Blue');
        productList.add(prod7);
        Product2 prod8 = TST_TestGeneratorClass.buildTestProduct('Concur Integration', CON_CPQ.OPTION,'', 'US', 'Go Blue');
        productList.add(prod8);
        Product2 prod9 = TST_TestGeneratorClass.buildTestProduct('Calendar Connector Integration', CON_CPQ.OPTION,'CPQ-TS-AMESA-Data-PI-FSN', 'US', 'Go Blue');
        productList.add(prod9);
        Product2 prod10 = TST_TestGeneratorClass.buildTestProduct('Data Masking', CON_CPQ.OPTION,'CPQ-TS-AMESA-Data-PI-FSN', 'US', 'Go Blue');
        productList.add(prod10);
        Product2 prod11 = TST_TestGeneratorClass.buildTestProduct('Architect', CON_CPQ.OPTION,'CPQ-TS-AMESA-Data-PI-FSN', 'US', 'Go Blue');
        productList.add(prod11);
        Product2 prod12 = TST_TestGeneratorClass.buildTestProduct('OCE Sales Subscription', CON_CPQ.BUNDLE,'CPQ-TS-AMESA-Data-PI-FSN', 'US', 'Go Blue');
        productList.add(prod12);
        Product2 prod13 = TST_TestGeneratorClass.buildTestProduct('LC9', CON_CPQ.PRODUCT_SERVICES, 'CPQ-TS-AMESA-Data-PI-KLPO', 'US', 'Go Blue');
        productList.add(prod13);
        Product2 prod14 = TST_TestGeneratorClass.buildTestProduct('SL-Development Metabolism', CON_CPQ.BUNDLE, 'Q_123', 'US', 'Go Blue');       
        productList.add(prod14);
        Product2 prod15 = TST_TestGeneratorClass.buildTestProduct('SL-InVitro', CON_CPQ.OPTION, 'Q_123', 'US', 'Go Blue');       
        productList.add(prod15);
        Product2 prod16 = TST_TestGeneratorClass.buildTestProduct('Concur Integration', CON_CPQ.OPTION, 'CES_2077K', 'US', 'Go Blue');
        productList.add(prod16);
        Product2 prod17 = TST_TestGeneratorClass.buildTestProduct('Data Masking', CON_CPQ.OPTION, 'CES_2076D', 'US', 'Go Blue');
        productList.add(prod17);
        insert productList;
        
        List<Apttus_Config2__PriceListItem__c> priceListItems = new List<Apttus_Config2__PriceListItem__c>();
        Apttus_Config2__PriceListItem__c pli1 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod1.Id, 'PLI-006');  
        priceListItems.add(pli1);
        Apttus_Config2__PriceListItem__c pli2 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod3.Id, 'PLI-01');
        priceListItems.add(pli2);
        Apttus_Config2__PriceListItem__c pli3 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod4.Id, 'PLI-02');
        priceListItems.add(pli3);
        Apttus_Config2__PriceListItem__c pli4 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod5.Id, 'PLI-03');
        priceListItems.add(pli4);
        Apttus_Config2__PriceListItem__c pli5 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod6.Id, 'PLI-04');
        priceListItems.add(pli5);
        Apttus_Config2__PriceListItem__c pli6 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod7.Id, 'PLI-05');
        priceListItems.add(pli6);
        Apttus_Config2__PriceListItem__c pli7 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod8.Id, 'PLI-06');
        priceListItems.add(pli7);
        Apttus_Config2__PriceListItem__c pli8 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod9.Id, 'PLI-07');
        priceListItems.add(pli8);
        Apttus_Config2__PriceListItem__c pli9 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod10.Id, 'PLI-08');
        priceListItems.add(pli9);
        Apttus_Config2__PriceListItem__c pli10 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod11.Id, 'PLI-09');
        priceListItems.add(pli10);
        Apttus_Config2__PriceListItem__c pli11 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod12.Id, 'PLI-10');
        priceListItems.add(pli11);
        Apttus_Config2__PriceListItem__c pli12 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod13.Id, 'PLI-11');
        priceListItems.add(pli12);
        Apttus_Config2__PriceListItem__c pli13 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod14.Id, 'PLI-12');
        priceListItems.add(pli13);
        Apttus_Config2__PriceListItem__c pli14 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod15.Id, 'PLI-13');
        priceListItems.add(pli14);
        Apttus_Config2__PriceListItem__c pli15 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod16.Id, 'PLI-14');
        priceListItems.add(pli15);
        Apttus_Config2__PriceListItem__c pli16 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod17.Id, 'PLI-15');
        priceListItems.add(pli16);
        insert priceListItems;
        
        List<Apttus_Config2__LineItem__c> optionConfigLineItems = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c cli1 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, prod1.Id, prod2.Id, 1, 987);
        optionConfigLineItems.add(cli1);
        Apttus_Config2__LineItem__c cli2 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, null, prod3.Id, 1, 987);
        optionConfigLineItems.add(cli2);
        Apttus_Config2__LineItem__c cli3 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, null, prod4.Id, 1, 987);
        optionConfigLineItems.add(cli3);
        Apttus_Config2__LineItem__c cli4 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, null, prod5.Id, 1, 987);
        optionConfigLineItems.add(cli4);
        Apttus_Config2__LineItem__c cli5 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, null, prod6.Id, 1, 987);
        optionConfigLineItems.add(cli5);
        Apttus_Config2__LineItem__c cli6 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, null, prod7.Id, 1, 987);
        optionConfigLineItems.add(cli6);
        Apttus_Config2__LineItem__c cli7 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, null, prod8.Id, 1, 987);
        optionConfigLineItems.add(cli7);
        Apttus_Config2__LineItem__c cli8 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, null, prod9.Id, 1, 987);
        optionConfigLineItems.add(cli8);
        Apttus_Config2__LineItem__c cli9 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, null, prod10.Id, 1, 987);
        optionConfigLineItems.add(cli9);
        Apttus_Config2__LineItem__c cli10 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, null, prod11.Id, 1, 987);
        optionConfigLineItems.add(cli10);
        Apttus_Config2__LineItem__c cli11 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, null, prod12.Id, 1, 987);
        optionConfigLineItems.add(cli11);
        Apttus_Config2__LineItem__c cli12 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, null, prod13.Id, 1, 987);
        optionConfigLineItems.add(cli12);
        Apttus_Config2__LineItem__c cli13 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, prod14.Id, prod15.Id, 1, 987);
        optionConfigLineItems.add(cli13);
        Apttus_Config2__LineItem__c cli14 = TST_TestGeneratorClass.createLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), CON_CPQ.PRODUCT_SERVICE, true, 1, 1, prod14.Id, prod15.Id, 1, 5);
        optionConfigLineItems.add(cli14);
        Apttus_Config2__LineItem__c cli15 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, prod14.Id, prod16.Id, 1, 987);
        optionConfigLineItems.add(cli15);
        Apttus_Config2__LineItem__c cli16 = TST_TestGeneratorClass.createLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), CON_CPQ.PRODUCT_SERVICE, true, 1, 1, prod14.Id, prod17.Id, 1, 5);
        optionConfigLineItems.add(cli16);
        insert optionConfigLineItems;

        List<Apttus_Config2__ProductGroup__c> productGrouplist = new List<Apttus_Config2__ProductGroup__c>();											
        Apttus_Config2__ProductGroup__c subscriptionprodGrp = new Apttus_Config2__ProductGroup__c();
        subscriptionprodGrp.Name = CON_CPQ.OCE_SUBS_PROD_GRP;		 
        subscriptionprodGrp.Migration_Id__c = 'PG-00001';
        productGrouplist.add(subscriptionprodGrp);
        Apttus_Config2__ProductGroup__c addOnproductGroup = new Apttus_Config2__ProductGroup__c();
        addOnproductGroup.Name = CON_CPQ.OCE_ADD_ON_PROD_GRP;
        addOnproductGroup.Migration_Id__c = 'PG-00002';
        productGrouplist.add(addOnproductGroup);
        Apttus_Config2__ProductGroup__c implementprdgroup = new Apttus_Config2__ProductGroup__c();
        implementprdgroup.Name = CON_CPQ.OCE_IMPLEM_PROD_GRP;
        implementprdgroup.Migration_Id__c = 'PG-00003';
        productGrouplist.add(implementprdgroup);
        insert productGrouplist;								 
															 
        List<Apttus_Config2__ProductGroupMember__c> productGrpmemberlist = new List<Apttus_Config2__ProductGroupMember__c>();
        Apttus_Config2__ProductGroupMember__c subscriptionprdGrpmember = new Apttus_Config2__ProductGroupMember__c();
        subscriptionprdGrpmember.Apttus_Config2__ProductId__c = prod7.Id;
        subscriptionprdGrpmember.Apttus_Config2__ProductGroupId__c = subscriptionprodGrp.Id;
        subscriptionprdGrpmember.Apttus_Config2__Sequence__c = 2;
        subscriptionprdGrpmember.Migration_Id__c = 'PGM-001';
        productGrpmemberlist.add(subscriptionprdGrpmember);
        Apttus_Config2__ProductGroupMember__c addOnproductGrpmember = new Apttus_Config2__ProductGroupMember__c();
        addOnproductGrpmember.Apttus_Config2__ProductId__c = prod6.Id;
        addOnproductGrpmember.Apttus_Config2__ProductGroupId__c = addOnproductGroup.Id;
        addOnproductGrpmember.Apttus_Config2__Sequence__c = 1;
        addOnproductGrpmember.Migration_Id__c = 'PGM-002';
        productGrpmemberlist.add(addOnproductGrpmember);
        Apttus_Config2__ProductGroupMember__c impleprodGrpmember = new Apttus_Config2__ProductGroupMember__c();
        impleprodGrpmember.Apttus_Config2__ProductId__c = prod5.Id;
        impleprodGrpmember.Apttus_Config2__ProductGroupId__c = implementprdgroup.Id;
        impleprodGrpmember.Apttus_Config2__Sequence__c = 3;
        impleprodGrpmember.Migration_Id__c = 'PGM-003';
        productGrpmemberlist.add(impleprodGrpmember);
        insert productGrpmemberlist;
        
        List<Apttus_Config2__LineItem__c> itemsObj = new List<Apttus_Config2__LineItem__c>();
        for (Apttus_Config2__LineItem__c item : [SELECT Id, Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__OptionId__r.ProductCode FROM Apttus_Config2__LineItem__c LIMIT 100]) {
            Apttus_Config2__LineItem__c itemObj = new Apttus_Config2__LineItem__c();
            itemObj.Id = item.Id;
            itemObj.Apttus_Config2__ChargeType__c = CON_CPQ.SUBSCRIPTION_FEE;
            itemObj.Apttus_Config2__LineType__c = CON_CPQ.OPTION;
            itemsObj.add(itemObj);
        }    
        update itemsObj;
        
        List<Apttus_Config2__ProductAttributeValue__c> productAttributeValues = new List<Apttus_Config2__ProductAttributeValue__c>();
        Apttus_Config2__ProductAttributeValue__c pav1 = UTL_TestData.createProductAttribute(cli1.Id, null, false);
        pav1.Market_Share__c = 16;
        pav1.Data_Delivery_Frequency__c = CON_CPQ.QUARTERLY;
        pav1.Eligible_Countries__c = 'KW';
        productAttributeValues.add(pav1);
        Apttus_Config2__ProductAttributeValue__c pav2 = UTL_TestData.createProductAttribute(cli13.Id, null, false);
        pav2.Number_of_Analyte__c = '1';
        pav2.Study_Number__c = '1';
        productAttributeValues.add(pav2);
        Apttus_Config2__ProductAttributeValue__c pav3 = UTL_TestData.createProductAttribute(cli14.Id, null, false);
        pav3.Premium__c = CON_CPQ.BIOMARKER;
        pav3.Clinical_Type__c = CON_CPQ.CLINICAL;
        pav3.Specimen_Type__c = CON_CPQ.PLASMA;
        productAttributeValues.add(pav3);
        insert productAttributeValues;
        
        List<Apttus_Config2__LineItem__c> itemsObj1 = new  List<Apttus_Config2__LineItem__c>();
        for (Apttus_Config2__LineItem__c item : itemsObj) {
            Apttus_Config2__LineItem__c itemObj = new Apttus_Config2__LineItem__c();
            itemObj.Id = item.Id;
            itemObj.Apttus_Config2__AttributeValueId__c = pav1.Id;
            itemObj.Apttus_Config2__AttributeValueId__r = pav1;
            itemsObj1.add(itemObj);  
        } 
        update itemsObj1;

        CPQ_AMESA_Partial_Product_Pricings__c cappp = new CPQ_AMESA_Partial_Product_Pricings__c();
        cappp.CPQ_Product_Code__c = 'CPQ-TS-AMESA-Data-PI-KLPO';
        cappp.Country__c = 'KW';
        cappp.Type__c = CON_CPQ.ATC;
        cappp.Market_Type__c = CON_CPQ.LPO;
        cappp.With_CD_PDF_Deliveries__c = true; 
        cappp.Data_Delivery_Frequency__c = CON_CPQ.MONTHLY;
        cappp.Key__c = 'CPQ-TS-AMESA-Data-PI-KLPO:KW:2022';
        cappp.Final_Price__c = 100;
        cappp.Final_Price_with_molecule__c = 150;
        cappp.Frequency__c = CON_CPQ.LPO;
        cappp.Year__c = '2022';
        cappp.isActive__c = true;
        cappp.Migration_Id__c = 'CAPPP-C0002';
        insert cappp;
    }

	@isTest
    static void testAmesaPricingCallback() {
        Apttus_Config2__LineItem__c lineItem = [SELECT Id FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ProductId__r.ProductCode = 'LC9' LIMIT 1];
        Apttus_Config2__ProductAttributeValue__c pav = [SELECT Id, Catergory__c FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__c =: lineItem.Id LIMIT 1];
        pav.Catergory__c = CON_CPQ.PARTIAL;
        update pav;
        List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id, Name, End_Date_Year__c, Start_Date_Year__c, Apttus_Config2__LineType__c, Apttus_Config2__AttributeValueId__r.Catergory__c, Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c, Apttus_Config2__AttributeValueId__r.Eligible_Countries__c, Apttus_Config2__AttributeValueId__r.With_CD_DVD_Deliveries__c, Apttus_Config2__OptionId__r.ProductCode,Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__NetUnitPrice__c, Apttus_Config2__AttributeValueId__r.Market_Share__c, Apttus_Config2__AttributeValueId__r.With_Molecule__c, Apttus_Config2__AttributeValueId__r.No_of_Lines__c, Apttus_Config2__AttributeValueId__r.Sub_Product__c FROM Apttus_Config2__LineItem__c LIMIT 100];
        Map<String, CPQ_AMESA_Partial_Product_Pricings__c> productCodeMapingwithParticalCaluculator = new Map<String, CPQ_AMESA_Partial_Product_Pricings__c>();
        for (CPQ_AMESA_Partial_Product_Pricings__c amesaMetData : [SELECT Id, CPQ_Product_Code__c, Country__c, With_CD_PDF_Deliveries__c, Data_Delivery_Frequency__c, Key__c, Final_Price__c, Final_Price_with_molecule__c, Frequency__c FROM CPQ_AMESA_Partial_Product_Pricings__c WHERE Type__c =: CON_CPQ.ATC OR Type__c =: CON_CPQ.OTC]) {
            if (!productCodeMapingwithParticalCaluculator.containsKey(amesaMetData.Key__c)) {
                productCodeMapingwithParticalCaluculator.put(amesaMetData.Key__c, amesaMetData);
            }
        }
        Test.startTest();
            UTL_CPQ_PricingCallBack.cpqPricingCalculation(lineItems, productCodeMapingwithParticalCaluculator, new Map<Id, Decimal>{lineItems[0].Id => 2}, new Map<String, Decimal>{CON_CPQ.MONTHLY => 1, CON_CPQ.QUARTERLY => 0.9});
        Test.stopTest();
        Assert.areEqual(CON_CPQ.OPTION, lineItems[0].Apttus_Config2__LineType__c, 'Line Items fetched successfully');
    }

	@isTest
    static void testProductNonOptionAmesaPricingCallback() {
        Product2 product = [SELECT Id, Apttus_Config2__ConfigurationType__c FROM Product2 WHERE ProductCode = 'CPQ-TS-AMESA-Data-PI-KLPO' LIMIT 1];
        product.Apttus_Config2__ConfigurationType__c = CON_CPQ.STANALONE;
        update product;
        Apttus_Config2__LineItem__c lineItem = [SELECT Id FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ProductId__r.ProductCode = 'LC9' LIMIT 1];
        Apttus_Config2__ProductAttributeValue__c pav = [SELECT Id, Number_of_Lists__c, No_of_Deliveries__c FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__c =: lineItem.Id LIMIT 1];
        pav.Number_of_Lists__c = 12;
        pav.No_of_Deliveries__c = 10;
        update pav;
        List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id, Name, Apttus_Config2__LineType__c, Apttus_Config2__AttributeValueId__r.No_of_Deliveries__c, Apttus_Config2__AttributeValueId__r.Number_of_Lists__c, Apttus_Config2__AttributeValueId__r.Catergory__c, Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c, Apttus_Config2__AttributeValueId__r.Eligible_Countries__c, Apttus_Config2__AttributeValueId__r.With_CD_DVD_Deliveries__c, Apttus_Config2__OptionId__r.ProductCode,Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__BasePriceOverride__c, Apttus_Config2__BasePrice__c, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__NetUnitPrice__c, Apttus_Config2__AttributeValueId__r.Market_Share__c, Apttus_Config2__AttributeValueId__r.With_Molecule__c, Apttus_Config2__AttributeValueId__r.No_of_Lines__c, Apttus_Config2__AttributeValueId__r.Sub_Product__c, Apttus_Config2__LineItem__c.End_Date_Year__c, Apttus_Config2__LineItem__c.Start_Date_Year__c, Apttus_Config2__AttributeValueId__r.Number_of_product_Line__c, Apttus_Config2__AttributeValueId__r.Number_of_Repos_SA__c FROM Apttus_Config2__LineItem__c LIMIT 100];
        lineItems.get(0).Apttus_Config2__AttributeValueId__r.Catergory__c = CON_CPQ.FULL_CATEGORY;
        lineItems.get(0).Apttus_Config2__AttributeValueId__r.Number_of_Lists__c = 1;
        Map<String, CPQ_AMESA_Partial_Product_Pricings__c> productCodeMapingwithParticalCaluculator = new Map<String, CPQ_AMESA_Partial_Product_Pricings__c>();
        for (CPQ_AMESA_Partial_Product_Pricings__c amesaMetData : [SELECT Id, CPQ_Product_Code__c, Country__c, With_CD_PDF_Deliveries__c, Data_Delivery_Frequency__c, Key__c, Final_Price__c, Final_Price_with_molecule__c, Frequency__c FROM CPQ_AMESA_Partial_Product_Pricings__c WHERE Type__c =: CON_CPQ.ATC OR Type__c =: CON_CPQ.OTC]) {
            if (!productCodeMapingwithParticalCaluculator.containsKey(amesaMetData.Key__c)) {
                productCodeMapingwithParticalCaluculator.put(amesaMetData.Key__c, amesaMetData);
            }
        }
        Test.startTest();
            UTL_CPQ_PricingCallBack.cpqPricingCalculation(lineItems, productCodeMapingwithParticalCaluculator, new Map<Id, Decimal>{lineItems[0].Id => 2}, new Map<String, Decimal>{CON_CPQ.MONTHLY => 1, CON_CPQ.QUARTERLY => 0.9});
            lineItems.get(0).Apttus_Config2__AttributeValueId__r.Number_of_Lists__c = null;
            lineItems.get(0).Apttus_Config2__AttributeValueId__r.No_of_Deliveries__c = null;
            lineItems.get(0).Apttus_Config2__AttributeValueId__r.Number_of_product_Line__c = null;
            lineItems.get(0).Apttus_Config2__AttributeValueId__r.Number_of_Repos_SA__c = null;
            lineItems.get(0).Apttus_Config2__AttributeValueId__r.No_of_Lines__c = null;
            UTL_CPQ_PricingCallBack.cpqPricingCalculation(lineItems, productCodeMapingwithParticalCaluculator, new Map<Id, Decimal>{lineItems[0].Id => 2}, new Map<String, Decimal>{CON_CPQ.MONTHLY => 1, CON_CPQ.QUARTERLY => 0.9});
        Test.stopTest();
        Assert.areEqual(CON_CPQ.OPTION, lineItems[0].Apttus_Config2__LineType__c, 'Line Items fetched successfully');
    }

	@isTest
    static void testProductNoofDeliveriesAmesaPricingCallback() {
        Product2 product = [SELECT Id, Apttus_Config2__ConfigurationType__c FROM Product2 WHERE ProductCode = 'CPQ-TS-AMESA-Data-PI-KLPO' LIMIT 1];
        product.Apttus_Config2__ConfigurationType__c = CON_CPQ.STANALONE;
        update product;
        Apttus_Config2__LineItem__c lineItem = [SELECT Id FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ProductId__r.ProductCode = 'LC9' LIMIT 1];
        Apttus_Config2__ProductAttributeValue__c pav = [SELECT Id, No_of_Deliveries__c FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__c =: lineItem.Id LIMIT 1];
        pav.No_of_Deliveries__c = 10;
        update pav;
        List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id, Name, Apttus_Config2__LineType__c, Apttus_Config2__NetPrice__c, Apttus_Config2__ListPrice__c, Apttus_Config2__AttributeValueId__r.No_of_Deliveries__c, Apttus_Config2__AttributeValueId__r.Number_of_Lists__c, Apttus_Config2__AttributeValueId__r.Catergory__c ,Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c,Apttus_Config2__AttributeValueId__r.Eligible_Countries__c,Apttus_Config2__AttributeValueId__r.With_CD_DVD_Deliveries__c,Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__NetUnitPrice__c, Apttus_Config2__AttributeValueId__r.Market_Share__c, Apttus_Config2__AttributeValueId__r.With_Molecule__c, Apttus_Config2__AttributeValueId__r.No_of_Lines__c, Apttus_Config2__AttributeValueId__r.Sub_Product__c, Apttus_Config2__AttributeValueId__r.Number_of_product_Line__c, Apttus_Config2__AttributeValueId__r.Number_of_Repos_SA__c, Apttus_Config2__BasePrice__c, Apttus_Config2__BasePriceOverride__c FROM Apttus_Config2__LineItem__c LIMIT 100];
        Map<String, CPQ_AMESA_Partial_Product_Pricings__c> productCodeMapingwithParticalCaluculator = new Map<String, CPQ_AMESA_Partial_Product_Pricings__c>();
        for (CPQ_AMESA_Partial_Product_Pricings__c amesaMetData : [SELECT Id, CPQ_Product_Code__c, Country__c, With_CD_PDF_Deliveries__c, Data_Delivery_Frequency__c, Key__c, Final_Price__c, Final_Price_with_molecule__c, Frequency__c FROM CPQ_AMESA_Partial_Product_Pricings__c WHERE Type__c =: CON_CPQ.ATC OR Type__c =: CON_CPQ.OTC]) {
            if (!productCodeMapingwithParticalCaluculator.containsKey(amesaMetData.Key__c)) {
                productCodeMapingwithParticalCaluculator.put(amesaMetData.Key__c, amesaMetData);
            }
        }
        Test.startTest();
            UTL_CPQ_PricingCallBack.cpqPricingCalculation(lineItems, productCodeMapingwithParticalCaluculator, new Map<Id, Decimal>{lineItems[0].Id => 2}, new Map<String, Decimal>{CON_CPQ.MONTHLY => 1, CON_CPQ.QUARTERLY => 0.9});
        Test.stopTest();
        Assert.areEqual(CON_CPQ.OPTION, lineItems[0].Apttus_Config2__LineType__c, 'Line Items fetched successfully');
    }
    
    @isTest
    static void testOCEPricingCallback() {
        Apttus_Config2__PriceList__c pl = [SELECT Id, Name FROM Apttus_Config2__PriceList__c LIMIT 1];
        pl.Name = CON_CPQ.AMESA;
        update pl;
        Product2 prod = [SELECT Id, ProductCode FROM Product2 WHERE Apttus_Config2__ConfigurationType__c =: CON_CPQ.BUNDLE AND ProductCode = 'LC9' LIMIT 1];
        Product2 product = [SELECT Id, ProductCode FROM Product2 WHERE Apttus_Config2__ConfigurationType__c =: CON_CPQ.OPTION LIMIT 1];
        product.ProductCode = 'LC9 Option';
        Test.startTest();
		    TST_TestGeneratorClass.buildTestFinalizeCart([SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1].Id, prod.Id, new Map<String, String>());
        Test.stopTest();
    }
    
    @isTest
    static void testOceGrossMarginCalculation() {
        List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id, Name, Apttus_Config2__AttributeValueId__r.Sub_Product__c, Apttus_Config2__OptionId__c, Apttus_Config2__LineItem__c.End_Date_Year__c, Apttus_Config2__LineItem__c.Start_Date_Year__c, Gross_Margin__c, Apttus_Config2__NetPrice__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__LineType__c, Apttus_Config2__ChargeType__c, Apttus_Config2__BasePrice__c, Apttus_Config2__PriceAdjustment__c, Apttus_Config2__OptionPrice__c, Apttus_Config2__SellingTerm__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingUom__c FROM Apttus_Config2__LineItem__c LIMIT 5];
        for (Apttus_Config2__LineItem__c lineItem : lineItems) {
            lineItem.Apttus_Config2__LineType__c = CON_CPQ.OPTION;
            lineItem.Apttus_Config2__PriceAdjustment__c = 100;
            lineItem.Apttus_Config2__OptionPrice__c = 100;
            lineItem.Apttus_Config2__ListPrice__c = 100;
            lineItem.Apttus_Config2__SellingTerm__c = 1;
            lineItem.Apttus_Config2__SellingFrequency__c = CON_CPQ.YEARLY;
            lineItem.Apttus_Config2__SellingUom__c = CON_CPQ.EACH;
            lineItem.Apttus_Config2__ExtendedPrice__c = 110;
        }
        Product2 prod1 = [SELECT Id, ProductCode FROM Product2 WHERE Apttus_Config2__ConfigurationType__c =: CON_CPQ.BUNDLE AND ProductCode = 'CE1447' LIMIT 1];
        lineItems[0].Apttus_Config2__OptionId__c = prod1.Id;
        Product2 prod2 = [SELECT Id, ProductCode FROM Product2 WHERE Apttus_Config2__ConfigurationType__c =: CON_CPQ.OPTION AND ProductCode = 'OCEP_AO_CONCUR_INT' LIMIT 1];
        lineItems[1].Apttus_Config2__OptionId__c = prod2.Id;
        Product2 prod3 = [SELECT Id, ProductCode FROM Product2 WHERE Apttus_Config2__ConfigurationType__c =: CON_CPQ.OPTION AND ProductCode = 'OCE_Architect' LIMIT 1];
        lineItems[2].Apttus_Config2__OptionId__c = prod3.Id;
        update lineItems;
        Test.startTest();
		    UTL_CPQ_PricingCallBack.oceGrossMarginCalculation(lineItems);
        Test.stopTest();
        List<Apttus_Config2__LineItem__c> actualLineItems = [SELECT Id, Gross_Margin__c FROM Apttus_Config2__LineItem__c LIMIT 5];
        Assert.areEqual(96.66, actualLineItems[0].Gross_Margin__c.setScale(2), 'Updated Gross Margin for Subscription Fee');
        Assert.areEqual(91.08, actualLineItems[1].Gross_Margin__c.setScale(2), 'Updated Gross Margin for Add-on Price');
        Assert.areEqual(95.54, actualLineItems[2].Gross_Margin__c.setScale(2), 'Updated Gross Margin for Implementation Fee');
    }
}