@isTest(SeeAllData=false)
public class TST_CNT_CPQ_ATCClassesController {
    
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
        atcClass.Quarter__c = '2022 Q4';
        insert atcClass;
        
        CPQ_AMESA_Partial_Product_Pricings__c cappp = new CPQ_AMESA_Partial_Product_Pricings__c();
        cappp.CPQ_Product_Code__c = 'CPQ-TS-AMESA-Data-PI-KLPO';
        cappp.Country__c = 'KW';
        cappp.Type__c = 'ATC';
        cappp.Market_Type__c = 'LPO';
        cappp.Standard_Type__c = CON_CPQ.EPHMRA;
        cappp.Migration_Id__c = 'CAPPP-C0003';
        insert cappp;
    }
    
    static Product2 buildTestProduct(String productName, string type, String code) {
        Product2 product = new Product2();
        product.IsActive = true;
        product.Name = productName;
        product.ProductCode = code;
        return product;
    }
    
    @isTest(SeeAllData=false)
    static void testGetATC_Classes() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Acc1'];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE AccountId =: testAccount.Id ];
        Apttus_Config2__PriceList__c testPriceList = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
        Apttus_Proposal__Proposal__c testProposal = TST_TestGeneratorClass.setProposalData(CON_CPQ.TECH_SOLUTION, testOpportunity.Id, CON_CPQ.AMESA, null,testPriceList.Id);
        
        Product2 testBundleProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Bundle' AND ProductCode = 'CPQ-Bundle'];
        Product2 testOptionProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Option' AND ProductCode = 'CPQ-TS-AMESA-Data-PI-KLPO'];
                
        insert  TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(testProposal.Id), 1, 1, testBundleProduct.Id, testOptionProduct.Id, 1, 0);
        
        Apttus_Config2__LineItem__c lineItem = [SELECT Id, Name From Apttus_Config2__LineItem__c Limit 1];

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
        
        Test.startTest();
        String atcOTCData = CNT_CPQ_ATCClassesController.getATC_Classes(lineItem.Id);
        Test.stopTest();
        System.assert( atcOTCData != null, 'ATC/OTC Data fetched Successfully');
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
        String quarter = '2022 Q4';
        String previousQuarter = 'December 2023';
        Map<String, Decimal> aggregateATCOTCMap = new Map<String, Decimal>();
        aggregateATCOTCMap.put('Count', 1);
        Test.startTest();
        CNT_CPQ_ATCClassesController.convertStringtoQuarter(previousQuarter);
        String cartLink = CNT_CPQ_ATCClassesController.saveMarketShare(lineItem.Id, marketShare, selectedAtcOtcCodes, quarter, json.serialize(aggregateATCOTCMap));
        String cartLinkGenerate = CNT_CPQ_ATCClassesController.handleCancle(lineItem.Id);
        Test.stopTest();
        System.assert( cartLink != null, 'Cart link fetched Successfully');
        System.assert( cartLinkGenerate != null, 'CartLink generated Successfully');
    }

}
