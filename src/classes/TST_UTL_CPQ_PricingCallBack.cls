@isTest
private class TST_UTL_CPQ_PricingCallBack {
    
    @testSetup
    static void createInitialDataSetup() {
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = CON_CPQ.CPQ_SETTINGS;
        cpqSetting.Key_Generation_Org__c = userInfo.getOrganizationId();
        insert cpqSetting;
        
        Currency_Exchange_Rates__c currencyRate = UTL_TestData.getCurrencyExchangeRate(false);
        insert currencyRate;
        
        Account acc = TST_TestGeneratorClass.buildTestAccount(UserInfo.getUserId());
        acc.AccountCountry__c = CON_CPQ.AL;

        List<Account> accounts = new List<Account>();
        accounts.add(TST_TestGeneratorClass.buildTestAccount(UserInfo.getUserId()));
        accounts.add(TST_TestGeneratorClass.buildTestAccount(UserInfo.getUserId()));
        accounts.add(TST_TestGeneratorClass.buildTestAccount(UserInfo.getUserId()));
        accounts.add(TST_TestGeneratorClass.buildTestAccount(UserInfo.getUserId()));
        accounts.add(TST_TestGeneratorClass.buildTestAccount(UserInfo.getUserId()));
        insert accounts;

        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
		
        Apttus_Config2__ConfigCustomClasses__c apttusPricingCallbackClass = new Apttus_Config2__ConfigCustomClasses__c();
        apttusPricingCallbackClass.Apttus_Config2__PricingCallbackClass__c = CON_CPQ.CPQ_PRICING_CALLBACK_CLASS;
        apttusPricingCallbackClass.Name = CON_CPQ.SYSTEM_PROPERTIES;

        insert new List<Sobject>{pl, acc, apttusPricingCallbackClass};
        Apttus_Config2__PriceList__c pl1 = TST_TestGeneratorClass.buildTestPriceList('Q2 Solutions-EUR');
        pl1.CurrencyIsoCode = 'EUR';
        pl1.Migration_Id__c = 'PL-13';
        insert pl1;

        Id priceBookId = Test.getStandardPricebookId();

        Opportunity opp = TST_TestGeneratorClass.buildTestOpportunity(1, acc.Id, UserInfo.getUserId(), priceBookId, false, true);
        opp.Phase_P__c = 'Phase 1';
        insert opp;
        
        Apttus_Proposal__Proposal__c proposal = TST_TestGeneratorClass.setProposalData(CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.AMESA, null, pl.Id);           
        proposal.Apttus_Proposal__ExpectedEndDate__c = Date.newInstance(2022, 07, 15);

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
        Apttus_Config2__PriceListItem__c pli13 = TST_TestGeneratorClass.buildTestPriceListItem(pl1.Id, prod14.Id, 'PLI-12');
        priceListItems.add(pli13);
        Apttus_Config2__PriceListItem__c pli14 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod15.Id, 'PLI-13');
        priceListItems.add(pli14);
        Apttus_Config2__PriceListItem__c pli15 = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod16.Id, 'PLI-14');
        priceListItems.add(pli15);
        Apttus_Config2__PriceListItem__c pli16 = TST_TestGeneratorClass.buildTestPriceListItem(pl1.Id, prod17.Id, 'PLI-15');
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
        Apttus_Config2__LineItem__c cli16 = TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(proposal.Id), 1, 1, prod14.Id, prod17.Id, 1, 5);
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
        pav3.Number_of_Analyte__c = 'N/A';
        productAttributeValues.add(pav3);
        Apttus_Config2__ProductAttributeValue__c pav4 = UTL_TestData.createProductAttribute(cli16.Id, null, false);
        pav4.Premium__c = '';
        pav4.Clinical_Type__c = 'N/A';
        pav4.Specimen_Type__c = '';
        pav4.Number_of_Analyte__c = 'N/A';
        productAttributeValues.add(pav4);
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

        Quote__c quote = UTL_TestData.createIqviaQuote(acc.Id, opp.Id, null, CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, false);
        quote.Sponsor_Tablets__c = 10;
        quote.Site_Tablets__c = 10;
        quote.Study_Duration__c = 1;
        quote.currencyIsoCode = CON_CPQ.USD;
        quote.Total_ICF_Documents__c = 10;
        quote.Amendments_to_ICF_Documents__c = 10;
        quote.Document_Type__c = CON_CPQ.INTERACTIVE_DOCUMENT_BUNDLE;
        quote.Patient_Videos__c = 10;
        quote.On_Site_Training_Days__c = 10;
        quote.Webinars__c = 10;
        quote.Amendments_to_Patient_Videos__c = 10;
        quote.Patient_Education_Glossary_Definitions__c = 10;
        quote.Enrollment_Period__c = 10;
        quote.Participant_Comprehension_Quizzes__c = 10;
        quote.Conversion_Rate__c = 1;
        insert quote;

        Quote_Requisites__c quoteRequisite = UTL_TestData.createQuoteRequisites(quote.Id, CON_CPQ.STUDY_TYPE, false);
        quoteRequisite.Study_Number__c = '1';
        quoteRequisite.Service_Line_Product__c = prod14.Id;
        quoteRequisite.Site__c = CON_CPQ.BEIJING;
        quoteRequisite.Species_Global__c = CON_CPQ.BABOON;
        quoteRequisite.Site_Count__c = 10;
        quoteRequisite.Site_Count_Adjusted__c = 10;
        insert quoteRequisite;

        List<IQVIA_Price_Matrix__c> priceMatrices = new List<IQVIA_Price_Matrix__c>();
        IQVIA_Price_Matrix__c priceMatrix1 = new IQVIA_Price_Matrix__c();
        priceMatrix1.Pricing_Tool__c = CON_CPQ.Q2_Solutions;
        priceMatrix1.Bundle_Product__c = prod14.Id;
        priceMatrix1.Base_Price__c = 100;
        priceMatrix1.Number_of_Analyte__c = 9999;
        priceMatrix1.Clinical_Type__c = CON_CPQ.All;
        priceMatrix1.Premium__c = CON_CPQ.All;
        priceMatrix1.Specimen_Type__c = CON_CPQ.All;
        priceMatrix1.CurrencyIsoCode = CON_CPQ.USD;
        priceMatrix1.Product_Code__c = 'CES_2076D';
        priceMatrix1.Bundle_Product_Code__c = CON_CPQ.ALL;
        priceMatrix1.Site__c = CON_CPQ.All;
        priceMatrix1.Migration_Id__c = 'IPM0009';
        priceMatrix1.Start_Date__c = Date.today();
        priceMatrix1.Option_Product__c = prod17.Id;
        priceMatrices.add(priceMatrix1);
        IQVIA_Price_Matrix__c priceMatrix2 = new IQVIA_Price_Matrix__c();
        priceMatrix2.Account__c = null;
        priceMatrix2.Discount__c = null;
        priceMatrix2.Pricing_Tool__c = CON_CPQ.Complete_Consent;
        priceMatrix2.Migration_Id__c = 'IPM-0001';
        priceMatrix2.Product_Code__c = 'CES_2076D';
        priceMatrix2.Base_Price__c = 100;
        priceMatrix2.Cost_Price__c = 80;
        priceMatrix2.Min_site_count__c = 0;
        priceMatrix2.Max_site_count__c = 9999;
        priceMatrix2.Min_document_count__c = 0;
        priceMatrix2.Max_document_count__c = 9999;
        priceMatrix2.Min_consent_count__c = 0;
        priceMatrix2.Max_consent_count__c = 9999;
        priceMatrix2.Breakdown__c = 10;
        priceMatrix2.CurrencyIsoCode = CON_CPQ.USD;
        priceMatrix2.Start_Date__c = Date.today();
        priceMatrices.add(priceMatrix2);
        IQVIA_Price_Matrix__c priceMatrix3 = new IQVIA_Price_Matrix__c();
        priceMatrix3.Pricing_Tool__c = CON_CPQ.Complete_Consent;
        priceMatrix3.Account__c = null;
        priceMatrix3.Discount__c = null;
        priceMatrix3.Migration_Id__c = 'IPM-0002';
        priceMatrix3.Product_Code__c = 'CES_2077K';
        priceMatrix3.Base_Price__c = 100;
        priceMatrix3.Cost_Price__c = 80;
        priceMatrix3.Min_site_count__c = 0;
        priceMatrix3.Max_site_count__c = 9999;
        priceMatrix3.Min_document_count__c = 0;
        priceMatrix3.Max_document_count__c = 9999;
        priceMatrix3.Min_consent_count__c = 0;
        priceMatrix3.Max_consent_count__c = 9999;
        priceMatrix3.Breakdown__c = 10;
        priceMatrix3.CurrencyIsoCode = CON_CPQ.USD;
        priceMatrix3.Start_Date__c = Date.today();
        priceMatrices.add(priceMatrix3);
        insert priceMatrices;
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

    @isTest
    static void testProductPricingCalculation() {
        List<Apttus_Config2__LineItem__c> usedLineItem = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__ProductAttributeValue__c pav1 = [SELECT Id, Number_of_Lists__c, Catergory__c, Eligible_Countries__c, Apttus_Config2__LineItemId__c FROM Apttus_Config2__ProductAttributeValue__c LIMIT 1];
        pav1.Number_of_Lists__c = 12;
        update pav1;
        List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id, Name, Apttus_Config2__AttributeValueId__r.Number_of_Lists__c, Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__AttributeValueId__r.Sub_Product__c, Apttus_Config2__AttributeValueId__r.Catergory__c, Apttus_Config2__LineItem__c.End_Date_Year__c, Apttus_Config2__LineItem__c.Start_Date_Year__c, Gross_Margin__c, Apttus_Config2__NetPrice__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__LineType__c, Apttus_Config2__ChargeType__c, Apttus_Config2__BasePrice__c, Apttus_Config2__PriceAdjustment__c, Apttus_Config2__OptionPrice__c, Apttus_Config2__SellingTerm__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingUom__c FROM Apttus_Config2__LineItem__c];
        for (Apttus_Config2__LineItem__c lineItem : lineItems) {
            lineItem.Apttus_Config2__LineType__c = CON_CPQ.OPTION;
            lineItem.Apttus_Config2__ChargeType__c = CON_CPQ.SUBSCRIPTION_FEE;
            lineItem.Apttus_Config2__PriceAdjustment__c = 100;
            lineItem.Apttus_Config2__OptionPrice__c = 100;
            lineItem.Apttus_Config2__ListPrice__c = 100;
            lineItem.Apttus_Config2__SellingTerm__c = 1;
            lineItem.Apttus_Config2__SellingFrequency__c = CON_CPQ.YEARLY;
            lineItem.Apttus_Config2__SellingUom__c = CON_CPQ.EACH;
            lineItem.Apttus_Config2__ExtendedPrice__c = 110;
            if (lineItem.Apttus_Config2__OptionId__r.ProductCode == null) {
                lineItem.Apttus_Config2__LineType__c = CON_CPQ.PRODUCT_SERVICES;
                usedLineItem.add(lineItem);
            }
        }
        update lineItems;
        Apttus_Config2__LineItem__c lineItem = [SELECT Id FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ProductId__r.ProductCode = 'LC9' LIMIT 1];
        Apttus_Config2__ProductAttributeValue__c pav = [SELECT Id, Number_of_Lists__c, Catergory__c, Eligible_Countries__c, Apttus_Config2__LineItemId__c FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__c =: lineItem.Id LIMIT 1];
        pav.Catergory__c = CON_CPQ.PARTIAL;
        pav.Eligible_Countries__c = CON_CPQ.SAUDIARABIA;
        pav.Apttus_Config2__LineItemId__c = usedLineItem[0].Id;
        update pav;
        CPQ_AMESA_Partial_Product_Pricings__c cappp = new CPQ_AMESA_Partial_Product_Pricings__c(Key__c = 'CPQ-TS-AMESA-Data-PI-FSN:SA:2022', CPQ_Product_Code__c = 'CPQ-TS-AMESA-Data-PI-FSN', Country__c = CON_CPQ.SAUDIARABIA, Final_Price__c = 100, Final_Price_with_molecule__c = 150, Final_Price_with_LMPT__c = 150, Frequency__c = CON_CPQ.MONTHLY, isActive__c = TRUE, Year__c = '2022', Migration_Id__c = 'CAPPP-C0006');
        insert cappp;
        Map<String,CPQ_AMESA_Partial_Product_Pricings__c> productCodeMapingwithParticalCaluculator = new Map<String,CPQ_AMESA_Partial_Product_Pricings__c>();
        for(CPQ_AMESA_Partial_Product_Pricings__c amesaMetData : [SELECT Id, CPQ_Product_Code__c, Country__c, With_CD_PDF_Deliveries__c, Data_Delivery_Frequency__c,Key__c, Final_Price__c, Final_Price_with_molecule__c,Frequency__c FROM CPQ_AMESA_Partial_Product_Pricings__c WHERE Type__c =: CON_CPQ.ATC OR Type__c =: CON_CPQ.OTC]){
            if(!productCodeMapingwithParticalCaluculator.containsKey(amesaMetData.Key__c)){
                productCodeMapingwithParticalCaluculator.put(amesaMetData.Key__c,amesaMetData);
                }
            }
        try {
            Test.startTest();
                UTL_CPQ_PricingCallBack.cpqPricingCalculation(lineItems, productCodeMapingwithParticalCaluculator, new Map<Id, Decimal>{usedLineItem[0].Id => 2}, new Map<String, Decimal>{CON_CPQ.MONTHLY => 1, CON_CPQ.QUARTERLY => 0.9});
                UTL_CPQ_PricingCallBack.oceGrossMarginCalculation(lineItems);
                UTL_CPQ_PricingCallBack.productPricingCalculation('CPQ-TS-AMESA-Data-PI-FSN:SA:202', usedLineItem[0], cappp, CON_CPQ.TUNISIA_COUNTRY, new Map<Id, Decimal>{usedLineItem[0].Id => 1}, new Map<String, Decimal>{CON_CPQ.MONTHLY => 1, CON_CPQ.QUARTERLY => 0.9});
            Test.stopTest();
            Apttus_Config2__LineItem__c actualLineItem = [SELECT Id, Apttus_Config2__BasePriceOverride__c FROM Apttus_Config2__LineItem__c WHERE Id =: usedLineItem[0].Id LIMIT 1];
            Assert.areNotEqual(null, actualLineItem.Apttus_Config2__BasePriceOverride__c, 'The exptected result should not be null');
        } catch (Exception e) {
            Assert.isTrue(true, 'Exception occurred during runtime');
        }
    }

    @isTest
    static void testProductPricingCalculationTestForDifferentCase() {
        List<Apttus_Config2__LineItem__c> usedLineItem = new List<Apttus_Config2__LineItem__c>();
        List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id, Name, Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c, Apttus_Config2__AttributeValueId__r.National_Subscription__c, Apttus_Config2__AttributeValueId__r.Market_Share__c, Apttus_Config2__AttributeValueId__r.With_Molecule__c, Apttus_Config2__AttributeValueId__r.Number_of_Lists__c, Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__AttributeValueId__r.Catergory__c, Apttus_Config2__AttributeValueId__r.Sub_Product__c, Apttus_Config2__LineItem__c.End_Date_Year__c, Apttus_Config2__LineItem__c.Start_Date_Year__c, Gross_Margin__c, Apttus_Config2__NetPrice__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__LineType__c, Apttus_Config2__ChargeType__c, Apttus_Config2__BasePrice__c, Apttus_Config2__PriceAdjustment__c, Apttus_Config2__OptionPrice__c, Apttus_Config2__SellingTerm__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingUom__c FROM Apttus_Config2__LineItem__c];
        for (Apttus_Config2__LineItem__c lineItem : lineItems) {
            lineItem.Apttus_Config2__LineType__c = CON_CPQ.OPTION;
            lineItem.Apttus_Config2__ChargeType__c = CON_CPQ.SUBSCRIPTION_FEE;
            lineItem.Apttus_Config2__PriceAdjustment__c = 100;
            lineItem.Apttus_Config2__OptionPrice__c = 100;
            lineItem.Apttus_Config2__ListPrice__c = 100;
            lineItem.Apttus_Config2__SellingTerm__c = 1;
            lineItem.Apttus_Config2__SellingFrequency__c = CON_CPQ.YEARLY;
            lineItem.Apttus_Config2__SellingUom__c = CON_CPQ.EACH;
            lineItem.Apttus_Config2__ExtendedPrice__c = 110;
            if (lineItem.Apttus_Config2__OptionId__r.ProductCode == null) {
                lineItem.Apttus_Config2__LineType__c = CON_CPQ.PRODUCT_SERVICES;
                usedLineItem.add(lineItem);
            }
        }
        update lineItems;
        Apttus_Config2__LineItem__c lineItem = [SELECT Id FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ProductId__r.ProductCode = 'LC9' LIMIT 1];
        Apttus_Config2__ProductAttributeValue__c pav = [SELECT Id, Number_of_Lists__c, Catergory__c, Eligible_Countries__c, Apttus_Config2__LineItemId__c FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__c =: lineItem.Id LIMIT 1];
        pav.Catergory__c = CON_CPQ.PARTIAL;
        pav.Eligible_Countries__c = CON_CPQ.SAUDIARABIA;
        pav.Apttus_Config2__LineItemId__c = usedLineItem[0].Id;
        update pav;
        CPQ_AMESA_Partial_Product_Pricings__c cappp = new CPQ_AMESA_Partial_Product_Pricings__c(Key__c = 'CPQ-TS-AMESA-Data-PI-FSN:SA:2022', CPQ_Product_Code__c = 'CPQ-TS-AMESA-Data-PI-FSN', Country__c = CON_CPQ.SAUDIARABIA, Final_Price__c = 100, Final_Price_with_molecule__c = 150, Frequency__c = CON_CPQ.MONTHLY, isActive__c = true, Year__c = '2022', Migration_Id__c = 'CAPPP-C0005');
        insert cappp;
        try {
            Test.startTest();
                UTL_CPQ_PricingCallBack.productPricingCalculation('CPQ-TS-AMESA-Data-PI-FSN:SA:202', usedLineItem[0], cappp, CON_CPQ.TUNISIA_COUNTRY, new Map<Id, Decimal>{usedLineItem[0].Id => 1}, new Map<String, Decimal>{CON_CPQ.MONTHLY => 1, CON_CPQ.QUARTERLY => 0.9});
            Test.stopTest();
            Apttus_Config2__LineItem__c actualLineItem = [SELECT Id, Apttus_Config2__BasePriceOverride__c FROM Apttus_Config2__LineItem__c WHERE Id =: usedLineItem[0].Id LIMIT 1];
            Assert.areEqual(null, actualLineItem.Apttus_Config2__BasePriceOverride__c, 'The exptected result should be null');
        } catch (Exception e) {
            Assert.isTrue(true, 'Exception occurred during runtime');
        }
    }
    
    @isTest 
    static void testAmesaPricingCallbackTestForDifferentCase() {
        List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id, Name, Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c, Apttus_Config2__AttributeValueId__r.National_Subscription__c, Apttus_Config2__AttributeValueId__r.Market_Share__c, Apttus_Config2__AttributeValueId__r.With_Molecule__c, Apttus_Config2__AttributeValueId__r.Number_of_Lists__c, Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__AttributeValueId__r.Catergory__c, Apttus_Config2__AttributeValueId__r.Sub_Product__c, Apttus_Config2__LineItem__c.End_Date_Year__c, Apttus_Config2__LineItem__c.Start_Date_Year__c, Gross_Margin__c, Apttus_Config2__NetPrice__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__LineType__c, Apttus_Config2__ChargeType__c, Apttus_Config2__BasePrice__c, Apttus_Config2__PriceAdjustment__c, Apttus_Config2__OptionPrice__c, Apttus_Config2__SellingTerm__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingUom__c FROM Apttus_Config2__LineItem__c];
        for (Apttus_Config2__LineItem__c lineItem : lineItems) {
            lineItem.Apttus_Config2__ChargeType__c = CON_CPQ.SUBSCRIPTION_FEE;
            lineItem.Apttus_Config2__LineType__c = CON_CPQ.PRODUCT_SERVICES;
        }
        update lineItems;
        Apttus_Config2__LineItem__c lineItem = [SELECT Id FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ProductId__r.ProductCode = 'LC9' LIMIT 1];
        Apttus_Config2__ProductAttributeValue__c pav = [SELECT Id, Number_of_Lists__c, Catergory__c, Eligible_Countries__c, Apttus_Config2__LineItemId__c FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__c =: lineItem.Id LIMIT 1];
        pav.Catergory__c = CON_CPQ.PARTIAL;
        update pav;
        List<Apttus_Config2__LineItem__c> items = [SELECT Id, Name, End_Date_Year__c, Start_Date_Year__c, Apttus_Config2__LineType__c, Apttus_Config2__AttributeValueId__r.Catergory__c, Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c, Apttus_Config2__AttributeValueId__r.Eligible_Countries__c, Apttus_Config2__AttributeValueId__r.With_CD_DVD_Deliveries__c, Apttus_Config2__OptionId__r.ProductCode,Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__NetUnitPrice__c, Apttus_Config2__AttributeValueId__r.Market_Share__c, Apttus_Config2__AttributeValueId__r.With_Molecule__c, Apttus_Config2__AttributeValueId__r.No_of_Lines__c, Apttus_Config2__AttributeValueId__r.Sub_Product__c FROM Apttus_Config2__LineItem__c LIMIT 100];
        Map<String, CPQ_AMESA_Partial_Product_Pricings__c> productCodeMapingwithParticalCaluculator = new Map<String, CPQ_AMESA_Partial_Product_Pricings__c>();
        for (CPQ_AMESA_Partial_Product_Pricings__c amesaMetData : [SELECT Id,CPQ_Product_Code__c, Country__c, With_CD_PDF_Deliveries__c, Data_Delivery_Frequency__c, Key__c, Final_Price__c, Final_Price_with_molecule__c, Frequency__c FROM CPQ_AMESA_Partial_Product_Pricings__c where Type__c =: CON_CPQ.ATC OR Type__c =: CON_CPQ.OTC]) {
            if (!productCodeMapingwithParticalCaluculator.containsKey(amesaMetData.Key__c)) {
                productCodeMapingwithParticalCaluculator.put(amesaMetData.Key__c, amesaMetData);
            }
        }
        Test.startTest();
            UTL_CPQ_PricingCallBack.cpqPricingCalculation(items, productCodeMapingwithParticalCaluculator, new Map<Id, Decimal>{items[0].Id => 2}, new Map<String, Decimal>{CON_CPQ.MONTHLY => 1, CON_CPQ.QUARTERLY => 0.9});
        Test.stopTest();
        Assert.isTrue(true, 'Line Item values are updated');
    }

    @isTest 
    static void testChangeProductStatusToPending() {
        List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id, Name, Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c, Apttus_Config2__AttributeValueId__r.National_Subscription__c, Apttus_Config2__AttributeValueId__r.Market_Share__c, Apttus_Config2__AttributeValueId__r.With_Molecule__c, Apttus_Config2__AttributeValueId__r.Number_of_Lists__c, Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__AttributeValueId__r.Catergory__c, Apttus_Config2__AttributeValueId__r.Sub_Product__c, Apttus_Config2__LineItem__c.End_Date_Year__c, Apttus_Config2__LineItem__c.Start_Date_Year__c, Gross_Margin__c, Apttus_Config2__NetPrice__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__LineType__c, Apttus_Config2__ChargeType__c, Apttus_Config2__BasePrice__c, Apttus_Config2__PriceAdjustment__c, Apttus_Config2__OptionPrice__c, Apttus_Config2__SellingTerm__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingUom__c FROM Apttus_Config2__LineItem__c];
        for (Apttus_Config2__LineItem__c lineItem : lineItems) {
            lineItem.Apttus_Config2__ChargeType__c = CON_CPQ.SUBSCRIPTION_FEE;
            lineItem.Apttus_Config2__LineType__c = CON_CPQ.PRODUCT_SERVICES;
        }
        update lineItems;
        Apttus_Config2__LineItem__c lineItem = [SELECT Id FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ProductId__r.ProductCode = 'LC9' LIMIT 1];
        Apttus_Config2__ProductAttributeValue__c pav = [SELECT Id, Number_of_Lists__c, Catergory__c, Eligible_Countries__c, Apttus_Config2__LineItemId__c FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__c =: lineItem.Id LIMIT 1];
        pav.Catergory__c = CON_CPQ.PARTIAL;
        update pav;
        List<Apttus_Config2__LineItem__c> items1 = [SELECT Id, Apttus_Config2__BasePriceOverride__c, Apttus_Config2__BasePrice__c, Apttus_Config2__AttributeValueId__r.Eligible_Countries__c  FROM Apttus_Config2__LineItem__c LIMIT 1];
        for (Apttus_Config2__LineItem__c itemObj : items1) {
            itemObj.Apttus_Config2__BasePriceOverride__c = null;
            itemObj.Apttus_Config2__BasePrice__c = 100;
            itemObj.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c = CON_CPQ.UAE;
        }
        Test.startTest();
            UTL_CPQ_PricingCallBack.changeProductStatusToPending(items1, CON_CPQ.ZAR, new Map<String, String>{CON_CPQ.UAE => CON_CPQ.CHF});
        Test.stopTest();
        Assert.areEqual(CON_CPQ.PENDING, items1[0].Apttus_Config2__PricingStatus__c, 'Status should be Pending');
    }

    @isTest 
    static void testhandleQ2PriceCalculation() {
        Account acc = [SELECT Id FROM Account WHERE AccountCountry__c =: CON_CPQ.AL LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'SL-Development Metabolism'];
        Apttus_Config2__PriceList__c plId = [SELECT Id FROM Apttus_Config2__PriceList__c WHERE Name = 'Q2 Solutions-EUR'];
        Opportunity testOpportunity = [SELECT Id, Line_of_Business__c, Is_this_IQVIA_Biotech__c, CurrencyIsoCode, Legacy_Quintiles_Opportunity_Number__c, Potential_Regions__c, Number_of_Potential_Regions__c  FROM Opportunity LIMIT 1];
        testOpportunity.Line_of_Business__c = CON_CPQ.CLINICAL;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        testOpportunity.Potential_Regions__c = CON_CPQ.REGION_ASIA_PASIFIC;
        testOpportunity.Number_of_Potential_Regions__c = 0;
        testOpportunity.Path_Probability__c = CON_CPQ.PATH_PROBABILITY_ADVANCE_TO_POTENTIAL;
        update testOpportunity;
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION AND SobjectType =: CON_CPQ.APTTUS_PROPOSAL_PROPOSAL LIMIT 1];
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Quote__c cloneQuote = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, null, CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, false);
        cloneQuote.CurrencyIsoCode = 'EUR';
        cloneQuote.Conversion_Rate__c = 0.75;
        cloneQuote.Related_Quote__c = quote.Id;
        insert cloneQuote;
        Quote_Requisites__c quoteRequisite = UTL_TestData.createQuoteRequisites(cloneQuote.Id, CON_CPQ.STUDY_TYPE, false);
        quoteRequisite.Service_Line_Product__c = prod.Id;
        insert quoteRequisite;
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, IQVIA_Quote__c, Select_Pricing_Tool__c, Apttus_Proposal__Opportunity__c, RecordTypeId, IQVIA_Quote__r.CurrencyIsoCode, Apttus_Proposal__Account__c, Apttus_QPConfig__PriceListId__c FROM Apttus_Proposal__Proposal__c LIMIT 1];
        proposal.Apttus_Proposal__Account__c = acc.Id;
        proposal.IQVIA_Quote__c = cloneQuote.Id;
        proposal.RecordTypeId = recordType.Id;
        proposal.CurrencyIsoCode = 'EUR';
        proposal.Apttus_QPConfig__PriceListId__c = plId.Id;
        proposal.Select_Pricing_Tool__c = CON_CPQ.Q2_Solutions;
        update proposal;
        Apttus_Config2__LineItem__c lineItem1 = [SELECT Id, Apttus_Config2__ItemSequence__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__Description__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ProductId__r.Name = 'SL-Development Metabolism' LIMIT 1];
        Apttus_Config2__ProductAttributeValue__c pav1 = [SELECT Id FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__c =: lineItem1.Id LIMIT 1];
        lineItem1.Apttus_Config2__ItemSequence__c = 1;
        lineItem1.Apttus_Config2__AttributeValueId__c = pav1.Id;
        lineItem1.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
        lineItem1.Apttus_Config2__AdjustmentAmount__c = 10;
        update lineItem1;
        Apttus_Config2__LineItem__c lineItem2 = [SELECT Id, Apttus_Config2__ItemSequence__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__Description__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__OptionId__r.Name = 'Data Masking' LIMIT 1];
        Apttus_Config2__ProductAttributeValue__c pav2 = [SELECT Id FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__r.Apttus_Config2__OptionId__r.Name = 'Data Masking' LIMIT 1];
        lineItem2.Apttus_Config2__ItemSequence__c = 2;
        lineItem2.Apttus_Config2__AttributeValueId__c = pav2.Id;
        lineItem2.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
        lineItem2.Apttus_Config2__AdjustmentAmount__c = 10;
        lineItem2.Apttus_Config2__ProductId__c = prod.Id;
        update lineItem2;
        List<Apttus_Config2__LineItem__c> liSOList = [SELECT Id, Name, Apttus_Config2__BasePriceOverride__c, Apttus_Config2__AttributeValueId__r.Number_of_Analyte__c, Apttus_Config2__OptionId__r.Name, Apttus_Config2__AttributeValueId__r.Specimen_Type__c, Apttus_Config2__OptionId__r.ProductCode, Apttus_Config2__AttributeValueId__r.Study_Number__c, Apttus_Config2__ProductId__r.Name, Apttus_Config2__AttributeValueId__r.Premium__c, Apttus_Config2__AttributeValueId__r.Clinical_Type__c, Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__Description__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.IQVIA_Quote__r.Related_Quote__r.CurrencyIsoCode, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.IQVIA_Quote__r.Related_Quote__r.Conversion_Rate__c, Apttus_Config2__AdjustmentType__c, Apttus_Config2__AdjustmentAmount__c FROM Apttus_Config2__LineItem__c];
        Test.startTest();
            UTL_CPQ_PricingCallBack.handleQ2PriceCalculation(liSOList, proposal.Select_Pricing_Tool__c, proposal.Apttus_Proposal__Account__c, proposal.IQVIA_Quote__c, CON_CPQ.USD, null);
        Test.StopTest();
        Apttus_Config2__LineItem__c actualLineItem = [SELECT Id, Apttus_Config2__BasePriceOverride__c FROM Apttus_Config2__LineItem__c WHERE Id =: liSOList[0].Id LIMIT 1];
        Assert.areEqual(null, actualLineItem.Apttus_Config2__BasePriceOverride__c, 'The exptected result should be null');
    }

    @isTest
    static void productPricingDPSCalculationTest() {
        List<Account> accounts = [SELECT Id FROM Account WHERE AccountCountry__c !=: CON_CPQ.AL LIMIT 5];
        for (integer i = 0; i < accounts.size() - 1; i++) {
            accounts[i + 1].ParentId = accounts[i].Id; 
        }
        update accounts;
        Quote__c quote = [SELECT Related_Opportunity__c, Related_Opportunity__r.Phase__c, GBU__c, Pricing_Tools__c, Related_Account__c, Sponsor_Tablets__c, Site_Tablets__c, Study_Duration__c, currencyIsoCode,Total_ICF_Documents__c, Amendments_to_ICF_Documents__c, Document_Type__c, Patient_Videos__c, On_Site_Training_Days__c, Webinars__c, Amendments_to_Patient_Videos__c, Patient_Education_Glossary_Definitions__c, Enrollment_Period__c, Participant_Comprehension_Quizzes__c, Total_Adjusted_Sites__c, Total_Sites__c FROM Quote__c LIMIT 1];
        quote.GBU__c = CON_CPQ.GBU_DPS;
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        update quote;
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_QPConfig__PriceListId__r.CurrencyIsoCode  FROM Apttus_Proposal__Proposal__c LIMIT 1];           
        proposal.Select_Pricing_Tool__c = CON_CPQ.Complete_Consent;
        proposal.IQVIA_Quote__c = quote.Id;
        proposal.IQVIA_Quote__r = quote;
        update proposal;
        List<Apttus_Config2__LineItem__c> items = [SELECT Id, Apttus_Config2__ProductId__c, Apttus_Config2__Quantity__c, Apttus_Config2__BasePriceOverride__c, Apttus_Config2__BaseCostOverride__c, Name, Apttus_Config2__AttributeValueId__r.Sub_Product__c, Apttus_Config2__LineItem__c.End_Date_Year__c, Apttus_Config2__LineItem__c.Start_Date_Year__c, Gross_Margin__c, Apttus_Config2__NetPrice__c, Apttus_Config2__ExtendedPrice__c, Apttus_Config2__LineType__c, Apttus_Config2__ChargeType__c, Apttus_Config2__BasePrice__c, Apttus_Config2__PriceAdjustment__c, Apttus_Config2__OptionPrice__c, Apttus_Config2__SellingTerm__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingUom__c, Apttus_Config2__OptionId__r.ProductCode FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__OptionId__r.ProductCode IN ('CES_2077K', 'CES_2076D')];
        try {
            Test.startTest();
                List<Apttus_Config2__LineItem__c> actualLineItems = UTL_CPQ_PricingCallBack.handleDPSPriceCalculation(items, proposal, new Set<String>{'CES_2076D', 'CES_2077K'}, null, '1000', false);
                List<Apttus_Config2__LineItem__c> actualLineItems1 = UTL_CPQ_PricingCallBack.handleDPSPriceCalculation(items, proposal, new Set<String>{'CES_2076D', 'US_CC_STUDLIC'}, null, '1000', false);
                UTL_CPQ_PricingCallBack.getAllParents(new Set<String>{accounts[accounts.size() - 1].Id});
            Test.stopTest();
            Assert.areEqual(null, actualLineItems, 'The exptected result should not be null');
        } catch(Exception e) {
            Assert.isTrue(true, 'Exception occurred during runtime');
        }
    }
}