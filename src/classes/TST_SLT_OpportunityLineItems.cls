/*
 * Version       : 1.0
 * Description   : This test class is used for Select OpportunityLineItems
 */
@isTest
public class TST_SLT_OpportunityLineItems {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        
    }
	
    /**
     * This method used to Select OpportunityLineItems by opportunity id
     */    
    @IsTest
    static void testSelectByOpportunityId() {
        Opportunity opp = [Select id from Opportunity where name = 'TestOpportunity'];
        Set<String> oliFieldSet = new Set<String> {'Id', 'OpportunityId', 'Hierarchy_Level__c', 'Offering_Group_Code__c'};
        Test.startTest();
		    Map<Id, OpportunityLineItem> oppLineItemMap = new SLT_OpportunityLineItems().selectByOpportunityId(new Set<Id> { opp.Id }, oliFieldSet);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = oppLineItemMap.size();
        System.assertEquals(expected, actual);
	}
    
    /**
     * This method used to Select OpportunityLineItems by opportunity id
     */    
    @IsTest
    static void testSelectListByOpportunityId() {
        Opportunity opp = [Select id from Opportunity where name = 'TestOpportunity'];
        Set<String> oliFieldSet = new Set<String> {'Id', 'OpportunityId', 'Hierarchy_Level__c', 'Offering_Group_Code__c'};
        Test.startTest();
            List<OpportunityLineItem> oppLineItemList = new SLT_OpportunityLineItems().selectByOpportunityIds(new Set<Id> { opp.Id }, oliFieldSet);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = oppLineItemList.size();
        System.assertEquals(expected, actual);
	}
    
    /**
     * This method used to Select OpportunityLineItems with schedules
     */    
    @IsTest
    static void testGetOliWithSchedules() {
        OpportunityLineItem oli = [SELECT id FROM OpportunityLineItem LIMIT 1];
        Set<String> oliFieldSet = new Set<String> {'Id', 'OpportunityId', 'Hierarchy_Level__c', 'Offering_Group_Code__c'};
        Set<String> schFieldSet = new Set<String> {'Id'};
        Test.startTest();
		    Map<Id, OpportunityLineItem> oppLineItemMap = new SLT_OpportunityLineItems().getOliWithSchedules(new Set<Id> { oli.Id }, oliFieldSet, schFieldSet);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = oppLineItemMap.size();
        System.assertEquals(expected, actual);
	}

    /**
     * This method used to Select OpportunityLineItems with schedules by Opportunity Id
     */    
    @IsTest
    static void testGetOlisWithSchedules() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<String> oliFieldSet = new Set<String> {'Id', 'OpportunityId', 'Hierarchy_Level__c', 'Offering_Group_Code__c'};
        Set<String> schFieldSet = new Set<String> {'Id'};
        Test.startTest();
		    Map<Id, OpportunityLineItem> oppLineItemMap = new SLT_OpportunityLineItems().getOlisWithSchedules(new Set<Id> { opp.Id }, oliFieldSet, schFieldSet);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = oppLineItemMap.size();
        System.assertEquals(expected, actual);
	}

    /**
     * This method used to Select OpportunityLineItems with schedules by Opportunity Id
     */    
    @IsTest
    static void testSelectOLIByOpportunityId() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        
        Test.startTest();
		    List<OpportunityLineItem> oppLineItemList = new SLT_OpportunityLineItems().selectOLIByOpportunityId(new Set<Id> { opp.Id });
        Test.stopTest();
        Integer expected = 1;
        Integer actual = oppLineItemList.size();
        System.assertEquals(expected, actual);
	}
    @isTest
    static void testSelectByOpportunityIdAndFilterCondition() {
        Set<String> oliFieldSet = new Set<String> {'Id','OpportunityId','Wbsrelementcode__c'};
        Opportunity opp = [Select id from Opportunity where name = 'TestOpportunity'];
        Set<Id> oppidSet = new Set<Id>{opp.id}; 
        String materialType = CON_CRM.PRODUCT_MATERIAL_TYPE_ZREP;
        String filterCondition = 'AND Product_Material_Type__c = \'' + CON_CRM.PRODUCT_MATERIAL_TYPE_ZREP + '\' AND Wbsrelementcode__c = null';
        Test.startTest();
        new SLT_OpportunityLineItems().selectByOpportunityIdandFilterCondition(oppidSet, oliFieldSet, filterCondition);
        Test.stopTest();
    }
    
    @IsTest
    static void testGetOLICountGroupByOpp() {
        User_Permissions__c up = User_Permissions__c.getInstance(UserInfo.getUserId());
        up.Is_ZQUI_Product_Access__c = true;
        upsert up;
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZQUI';
        product.ProductCode = 'Test01';
        Product.ZQUI_Product__c =true;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        Opportunity opp = [SELECT Id,Name FROM Opportunity LIMIT 1];
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        Test.startTest();
            List<AggregateResult> results = new SLT_OpportunityLineItems().getOLICountGroupByOpp(new Set<Id> { opp.Id });
        Test.stopTest();
        System.assertEquals(true, results.size() > 0);
    }
    
    @isTest
    static void testSelectByLIOLIId() {
        OpportunityLineItem oli = [SELECT Id, OpportunityId, LI_OpportunityLineItem_Id__c FROM OpportunityLineItem LIMIT 1];
        oli.LI_OpportunityLineItem_Id__c = oli.ID;
        update oli;
        Set<String> fieldSet = new Set<String>{'ID'};
            
        Test.startTest();       	
        	Map<Id, OpportunityLineItem> oliList = new SLT_OpportunityLineItems().selectByLIOLIId(new Set<Id> { oli.LI_OpportunityLineItem_Id__c }, fieldSet);
        	System.debug(oliList);
        	System.debug(oliList.size());
        Test.stopTest();
        
        System.assertEquals(oliList.size() > 0, true, 'opportunityLineItem exists');
    }
    
    @isTest
    static void testGetOLIByOppIdAndProductCode(){
        Opportunity opp = [Select id from Opportunity LIMIT 1];
        Set<ID> oppID = new Set<ID>{opp.ID};
        Set<String> fieldSet = new Set<String>{'Id', 'OpportunityId'};
        Product2 product = [Select ID, ProductCode from Product2 LIMIT 1];
        Set<String> productCodeSet = new Set<String>{product.ProductCode};
        Test.startTest();       	
        	List<OpportunityLineItem> oliList = new SLT_OpportunityLineItems().getOLIByOppIdAndProductCode(oppID, fieldSet, productCodeSet);
        Test.stopTest();
        
        System.assertEquals(oliList.size() > 0, true, 'opportunityLineItem exists');
        
    }
    
    
    @isTest
    static void testSelectByOpportunityIdProductCode(){
        Opportunity opp = [Select id from Opportunity LIMIT 1];
        Set<ID> oppID = new Set<ID>{opp.ID};
        Set<String> fieldSet = new Set<String>{'Id', 'OpportunityId'};
        Product2 product = [Select ID, ProductCode from Product2 LIMIT 1];
        Set<String> productCodeSet = new Set<String>{product.ProductCode};
        Set<ID> oliFieldSet = new Set<ID> {product.ID};
        Test.startTest();       	
        	List<OpportunityLineItem> oliList = new SLT_OpportunityLineItems().selectByOpportunityIdProductCode(oppID, productCodeSet, oliFieldSet, fieldSet);
        Test.stopTest();
        
        System.assertEquals(oliList.size() > 0, true, 'opportunityLineItem exists');
        
    }
    
    @isTest
    static void testgetRecentProductId(){
        Test.startTest();       	
        	List<AggregateResult> agrs = new SLT_OpportunityLineItems().getRecentProductId();
        Test.stopTest();
        System.assertEquals(1,agrs.size());
    }
    
    @isTest
    static void testGetComponentData(){
        Test.startTest();     
         Opportunity opp = [Select id from Opportunity LIMIT 1];
        	List<OpportunityLineItem> agrs = new SLT_OpportunityLineItems().getComponentData(opp.Id);
        Test.stopTest();
        System.assertEquals(0,agrs.size());
    }
}
