@isTest
public class TST_CNT_CRM_Pricing_Tool_Recommendation {
    
    @testSetup
    static void setUpTestData() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity Opp = UTL_TestData.createOpportunity(acc.Id);
        Opp.Line_of_Business__c = 'Outcome';
        insert opp;
    }
    
    @IsTest
    public static void testGetPricingToolS1() {
        Opportunity Opp = [SELECT Id FROM Opportunity];
        opp.Main_Delivery_Country__c = 'Kenya';
        update opp;
        
        Product2 product = UTL_TestData.createProduct();
        product.Name = 'LP Studies';
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        insert product;
        
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        List < OpportunityLineItem > olis= new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem1.Delivery_Country__c = 'JAPAN';
        olis.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem2.Delivery_Country__c = 'USA';
        olis.add(oppLineItem2);
        insert olis;
        
        Map < String, Object > mapOfReturnMap = new Map<String, Object>();
        Test.startTest();
            mapOfReturnMap = CNT_CRM_Pricing_Tool_Recommendation.getPricingTool(Opp.Id);
        Test.stopTest();
        System.assertEquals(mapOfReturnMap.get('OtherPricingTool') == new Set < String > { 'Pricing Assistant', 'Pricing Template'}, true);
    }
    
    @IsTest
    public static void testGetPricingToolS2() {
        Account acc = [SELECT Id FROM Account];
        acc.Name = 'TAKEDA [JP]';
        update acc;
        Opportunity Opp = [SELECT Id FROM Opportunity];
        opp.Main_Delivery_Country__c = 'Latin America Regional';
        opp.PA_Required__c = true;
        update opp;
        
        Product2 product = UTL_TestData.createProduct();
        product.Name = 'LP Studies';
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        insert product;
        
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        List < OpportunityLineItem > olis= new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem1.Delivery_Country__c = 'JAPAN';
        insert oppLineItem1;
        
        Map < String, Object > mapOfReturnMap = new Map<String, Object>();
        Test.startTest();
            mapOfReturnMap = CNT_CRM_Pricing_Tool_Recommendation.getPricingTool(Opp.Id);
        Test.stopTest();
        System.assertEquals(mapOfReturnMap.get('RecommenedPricingTool') == 'Pricing Assistant', true);
        System.assertEquals(mapOfReturnMap.get('OtherPricingTool') == new Set < String > { 'Pricing Template'}, true);
    }
    
    @IsTest
    public static void testGetPricingToolS3() {
        Opportunity Opp = [SELECT Id FROM Opportunity];
        opp.PA_Required__c = false;
        opp.Main_Delivery_Country__c = 'Latin America Regional';
        update opp;
        
        Product2 product = UTL_TestData.createProduct();
        product.Name = 'LP Studies';
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        insert product;
        
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        List < OpportunityLineItem > olis= new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem1.Delivery_Country__c = 'JAPAN';
        insert oppLineItem1;
        
        Map < String, Object > mapOfReturnMap = new Map<String, Object>();
        Test.startTest();
            mapOfReturnMap = CNT_CRM_Pricing_Tool_Recommendation.getPricingTool(Opp.Id);
        Test.stopTest();
        System.assertEquals(mapOfReturnMap.get('RecommenedPricingTool') == 'Pricing Template', true);
        System.assertEquals(mapOfReturnMap.get('OtherPricingTool') == new Set < String > { 'Pricing Assistant'}, true);
    }
    
    @IsTest
    public static void testGetPricingToolS4() {
        Opportunity Opp = [SELECT Id FROM Opportunity];
        opp.Name = 'PMS opp';
        opp.PA_Required__c = false;
        opp.Main_Delivery_Country__c = 'Latin America Regional';
        update opp;
        Product2 product = UTL_TestData.createProduct();
        product.Name = 'LP Studies';
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.Offering_Type__c = 'Commercial Engagement Services';
        product.ProductCode = 'Test01';
        insert product;
        
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        
        Map < String, Object > mapOfReturnMap = new Map<String, Object>();
        Test.startTest();
            mapOfReturnMap = CNT_CRM_Pricing_Tool_Recommendation.getPricingTool(Opp.Id);
        Test.stopTest();
        System.assertEquals(mapOfReturnMap.get('OtherPricingTool') == new Set < String > { 'Pricing Assistant', 'Pricing Template'}, true);
    }
    
    @IsTest
    public static void testSetPricingTool() {
        String pricingToolLink;
        Pricing_Tool_Links__c ptl = new Pricing_Tool_Links__c(Name = 'Pricing Template', Pricing_Tool_Name__c = 'Pricing Template', Pricing_Tool_URL__c = 'https://www.google.com/');
        insert ptl;
        
        Opportunity opp = [SELECT Id FROM Opportunity];
        Test.startTest();
            pricingToolLink = CNT_CRM_Pricing_Tool_Recommendation.setPricingTool(Opp.Id, 'Pricing Template');
        Test.stopTest();
        System.assertEquals(pricingToolLink == 'https://www.google.com/', true);
    }
}