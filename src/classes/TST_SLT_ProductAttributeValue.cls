@isTest(SeeAllData=false)
public class TST_SLT_ProductAttributeValue {
    @testSetup
    static void dataSetup(){
        Account testAccount = UTL_TestData.createAccount();
        testAccount.Name = 'Test Acc1';
        insert testAccount;
        
        Opportunity testOpportunity = UTL_TestData.createOpportunity(testAccount.Id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert testOpportunity;
        
        Product2 product1 = new Product2();
        product1.IsActive = true;
        product1.Name = 'Test Bundle';
        product1.ProductCode = 'CPQ-Bundle';
        product1.Apttus_Config2__ConfigurationType__c = 'Bundle';
        insert product1;
        Product2 product11 = new Product2();
        product11.IsActive = true;
        product11.Name = 'Test Option';
        product11.ProductCode = 'CPQ-TS-AMESA-Data-PI-KLPO';
        product11.Apttus_Config2__ConfigurationType__c = CON_CPQ.OPTION;
        insert product11;
        
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.Key_Generation_Org__c = UserInfo.getOrganizationId();
        insert cpqSetting; 
        
        ATC_OTC_Classification__c atcClass = new ATC_OTC_Classification__c();
        atcClass.Hierarchy1_Code__c = 'A0';
        atcClass.Hierarchy1_Name__c = 'A0 ALIMENTARY T.& METABOLISM';
        atcClass.Hierarchy2_Code__c = 'A01';
        atcClass.Hierarchy2_Name__c = 'A01 STOMATOLOGICALS';
        atcClass.Hierarchy3_Code__c = 'A01A';
        atcClass.Hierarchy3_Name__c = 'A01A STOMATOLOGICALS';
        atcClass.Hierarchy4_Code__c = 'A01A0';
        atcClass.Hierarchy4_Name__c = 'A01A0 STOMATOLOGICALS';
        atcClass.Country_Code__c = 'KW';
        atcClass.Market_Share__c = 0.24;
        atcClass.Market_Type__c = 'LPO';
        atcClass.Standard_Type__c = CON_CPQ.EPHMRA;
        atcClass.Type__c = CON_CPQ.ATC;
        atcClass.Migration_Id__c = 'TD-20';
        insert atcClass;
    }
    
    static Product2 buildTestProduct(String productName, string type, String code) {
        Product2 product = new Product2();
        product.IsActive = true;
        product.Name = productName;
        product.ProductCode = code;
        return product;
    }
    
    
    @isTest(SeeAllData=false)
    static void testSaveMarketShare() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Acc1'];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE AccountId =: testAccount.Id ];
        Apttus_Config2__PriceList__c testPriceList = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
        Apttus_Proposal__Proposal__c testProposal = TST_TestGeneratorClass.setProposalData(CON_CPQ.TECH_SOLUTION, testOpportunity.Id, CON_CPQ.AMESA, null,testPriceList.Id);
        
        Product2 testBundleProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Bundle' AND ProductCode = 'CPQ-Bundle'];
        Product2 testOptionProduct =  [SELECT Id FROM Product2 WHERE Name = 'Test Option' AND ProductCode = 'CPQ-TS-AMESA-Data-PI-KLPO'];
        
        insert  TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(testProposal.Id), 1, 1, testBundleProduct.Id, testOptionProduct.Id, 1, 0);
        Apttus_Config2__LineItem__c lineItem = [SELECT Id, Name,Apttus_Config2__ConfigurationId__r.Id From Apttus_Config2__LineItem__c Limit 1];
        
        Apttus_Config2__ProductAttributeValue__c pav= new Apttus_Config2__ProductAttributeValue__c();
        pav.Catergory__c = CON_CPQ.PARTIAL;
        pav.Data_Delivery_Frequency__c = CON_CPQ.QUARTERLY;
        pav.Eligible_Countries__c = 'KW';
        pav.Apttus_Config2__LineItemId__c = lineItem.Id;
        insert pav;
        Apttus_Config2__LineItem__c itemObj = new Apttus_Config2__LineItem__c();
        itemObj.Id = lineItem.Id;
        itemObj.Apttus_Config2__AttributeValueId__c = pav.Id;
        update itemObj;
        
        Apttus_Config2__TempObject__c tempObj = new Apttus_Config2__TempObject__c();
        tempObj.Apttus_Config2__ConfigurationId__c = lineItem.Apttus_Config2__ConfigurationId__r.Id;
        insert tempObj;
        Decimal marketShare = 23.91;
        String selectedAtcOtcCodes = 'A01';
        String quarter = '2023 Q1';
        Map<String, Decimal> aggregateATCOTCMap = new Map<String, Decimal>();
        aggregateATCOTCMap.put('Count', 1);
        Test.startTest();
        String cartLink = CNT_CPQ_ATCClassesController.saveMarketShare(lineItem.Id, marketShare, selectedAtcOtcCodes, quarter, json.serialize(aggregateATCOTCMap));
        String cartLinkGenerate = CNT_CPQ_ATCClassesController.handleCancle(lineItem.Id);
        Test.stopTest();
        System.assert( cartLink != null, 'Cart link fetched Successfully');
        System.assert( cartLinkGenerate != null, 'CartLink generated Successfully');        
    }
    
    @IsTest
    static void testgetAttributeRecords() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1 ];
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setTSProposalData(true, CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.OCE);
        Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c();
        prodConfig.Apttus_QPConfig__Proposald__c = quote.Id;
        insert prodConfig;
        Set<String> attributeSet = new Set<String>{'O_Country__c'}; 
            
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
        
        Test.startTest();
            Map<Id, Apttus_Config2__ProductAttributeValue__c> attributeValue = new SLT_ProductAttributeValue().getProductAttributeRecords(new Set<Id>{attributeList[0].Id}, attributeSet);
            Map<Id, Apttus_Config2__ProductAttributeValue__c> attributeValue1 = new SLT_ProductAttributeValue().getProductAttributeRecords(new Set<Id>{attributeList[1].Id}, attributeSet);
        Test.stopTest();
		
        System.assertEquals(attributeValue.size()>0, true, 'Proposal Product Attribute Value record exists');
        System.assertEquals(attributeValue1.size()>0, true, 'Proposal Product Attribute Value record exists');
    }
}
