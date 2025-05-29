/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CRM_OpportunityProducts
 */
@isTest
private class TST_CNT_CRM_OpportunityProductSearch {
    
    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        upsert bs;
        String profileName = CON_CRM.SYSTEM_ADMIN_PROFILE;
        UTL_ExecutionControl.stopTriggerExecution = true;
        List<User> userList = UTL_TestData.createUser(profileName, 1);
        insert userList;
        UTL_ExecutionControl.stopTriggerExecution = false;
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZREP';
        product.Item_Category_Group__c = 'test';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        OpportunityLineItemSchedule olis =UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id); 
        insert olis;
    }
    
    /**
     * test method to get field Details of Product Object
     */  
    static testmethod void testGetProductFieldsDetail() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> oppFields = new String [] {'Id', 'Name' };
        String objectName = CON_CRM.PRODUCT_OBJECT;
        List<String> fieldAPINameList = new List<String>{'Name', 'ProductCode'};
        User userRecord = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        Default_Product_Search__c defaultSearch = UTL_TestData.createDefaultProductSearch(userRecord.Id);
        insert defaultSearch;
        List<String> fieldList = new List<String>{'Id', 'User__c'};
        Test.startTest();
            List<OpportunityWrapper> fieldWrapperList = CNT_CRM_OpportunityProductSearch.getProductSearchInitData(objectName, fieldAPINameList, opp.Id, oppFields, fieldList, 'Opportunity');
        Test.stopTest();
        Integer expected = 1    ;
        Integer actual = fieldWrapperList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to get field Details of Product Object with exception
     */  
    static testmethod void testGetProductFieldsDetailException() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> oppFields = new String [] {'Id', 'Name' };
        String objectName = CON_CRM.PRODUCT_OBJECT;
        List<String> fieldAPINameList = new List<String>{'Name', 'ProductCod'};
        Test.startTest();
            try {
                List<OpportunityWrapper> fieldWrapperList = CNT_CRM_OpportunityProductSearch.getProductSearchInitData(objectName, fieldAPINameList, opp.Id, oppFields, null, 'Opportunity');
                system.assert(false);
            } catch(Exception ex) {
                System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
            }
        Test.stopTest();
    }
    
    /**
     * test method to get filter products
     */  
    static testmethod void testGetProductsBySearchFilter() {
        PriceBookEntry pbe = [SELECT Id, Product2.Name FROM PriceBookEntry LIMIT 1];
        PriceBookEntryWrapper pbWrapper = new PriceBookEntryWrapper(pbe.Product2, pbe);
        String fiterObjString = JSON.serialize(pbWrapper);
        Test.startTest();
        List<PriceBookEntryWrapper> wrapperList = CNT_CRM_OpportunityProductSearch.getPriceBookEntriesBySearchFilter(fiterObjString, new List<String>{'Product2.Name'}, new List<String>(), new List<String>(), 50, 'AND');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = wrapperList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to get favorite products
     */  
    static testmethod void testGetFavoriteProducts() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = :CON_CRM.TEST_PRODUCT_NAME LIMIT 1];
        Favorite_Product__c favoriteProduct = UTL_TestData.createFavoriteProduct(prod);
        insert favoriteProduct;
        Test.startTest();
            List<PriceBookEntryWrapper> wrapperList = CNT_CRM_OpportunityProductSearch.getFavoriteProducts(opp.Id, 'Opportunity');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = wrapperList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to get favorite product Exception
     */  
    static testmethod void testGetFavoriteProductException() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = :CON_CRM.TEST_PRODUCT_NAME LIMIT 1];
        Favorite_Product__c favoriteProduct = UTL_TestData.createFavoriteProduct(prod);
        insert favoriteProduct;
        try{
            Test.startTest();
            List<PriceBookEntryWrapper> wrapperList = CNT_CRM_OpportunityProductSearch.getFavoriteProducts(opp.Id, 'Opportunity');
            //System.assert(false);
        } catch(Exception ex) {
            System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
        } finally {
            Test.stopTest();
        }
    }
    
    /**
     * test method to get filter products with exception
     */  
    static testmethod void testGetProductsBySearchFilterException() {
        PriceBookEntry pbe = new PriceBookEntry();
        PriceBookEntryWrapper pbWrapper = new PriceBookEntryWrapper(new Product2(), pbe);
        String fiterObjString = JSON.serialize(pbWrapper);
        List<String> fieldsAPIList = new List<String>{'I'};
        List<String> productFieldList = new List<String> {'Nam'};
        Test.startTest();
            try {
                List<PriceBookEntryWrapper> wrapperList = CNT_CRM_OpportunityProductSearch.getPriceBookEntriesBySearchFilter(fiterObjString, fieldsAPIList, productFieldList, new List<String>(), 50, 'AND');
                system.assert(false);
            } catch(Exception ex) {
                System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
            }
        Test.stopTest();
    }
    
    /**
     * test method to get List of OLI Object
     */  
    static testmethod void testGetListOfOLI() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> oliFields = new String [] {'Id', 'OpportunityId', 'Name','Hierarchy_Level__c', 'Delivery_Country__c', 'Product_Start_Date__c', 
                'Product_End_Date__c', 'CurrencyISOCode', 'Description', 'UnitPrice', 'Product2.Name'
                };
        Test.startTest();
             List<OpportunityWrapper> wrpList = CNT_CRM_OpportunityProductSearch.getListOfOLI(opp.Id, oliFields);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = wrpList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to get List of OLI Object Exception
     */  
    static testmethod void testGetListOfOLIException() {
        Test.startTest();
            try {
                List<OpportunityWrapper> wrpList = CNT_CRM_OpportunityProductSearch.getListOfOLI(null, null);
                system.assert(false);
            } catch(Exception ex) {
                System.assertEquals('System.JSONException', ex.getTypeName());
            }
        Test.stopTest();
    }
    
    /**
     * test method to delete OLI record
     */  
    static testmethod void testCrudOliRecord() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oli = [SELECT Id, OpportunityId, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId =: opp.Id LIMIT 1];
        List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>();
        OpportunityLineItemWrapper oliWrapper = new OpportunityLineItemWrapper(oli[0], 'Delete');
        oliWrapperList.add(oliWrapper);
        String oliJSON = JSON.serialize(oliWrapperList);
        Test.startTest();
             CNT_CRM_OpportunityProductSearch.crudOliRecord(oliJSON);
             oli = [SELECT Id, OpportunityId, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId =: opp.Id LIMIT 1];
        Test.stopTest();
        Integer expected = 0;
        Integer actual = oli.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to delete oli record Exception
     */  
    static testmethod void testCrudOliRecordException() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oli = [SELECT Id, OpportunityId, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId =: opp.Id LIMIT 1];
        String oliJSON = JSON.serialize(oli);
        Test.startTest();
            try {
                CNT_CRM_OpportunityProductSearch.crudOliRecord(null);
                system.assert(false);
            } catch(Exception ex) {
                System.assertEquals('System.JSONException', ex.getTypeName());
            }
        Test.stopTest();
    }
    
    /**
     * test method to get field Details of OLI Object
     */  
    static testmethod void testGetOLIFieldDetail() {
        String fieldData = 'Id,Name';
        List<ObjectFieldsWrapper> objectSelectedFieldList = new List<ObjectFieldsWrapper>();
        Test.startTest();
             objectSelectedFieldList = CNT_CRM_OpportunityProductSearch.getOLIFieldDetail(fieldData);
        Test.stopTest();
        Integer expected = 2;
        Integer actual = objectSelectedFieldList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to get field Details of OLI Object Exception
     */  
    static testmethod void testGetOLIFieldDetailException() {
        String fieldData = 'Id,Nam';
        List<ObjectFieldsWrapper> objectSelectedFieldList = new List<ObjectFieldsWrapper>();
        Test.startTest();
            try {
                objectSelectedFieldList = CNT_CRM_OpportunityProductSearch.getOLIFieldDetail(fieldData);
                system.assert(false);
            } catch(Exception ex) {
                System.assertEquals('System.JSONException', ex.getTypeName());
            }
        Test.stopTest();
    }
    
    /**
     * test method to create favorite product record
     */  
    static testmethod void testCrudFavoriteProductRecord() {
        List<Favorite_Product__c> favoriteProductList = new List<Favorite_Product__c>();
        Product2 product = [SELECT Id FROM Product2 WHERE Name = :CON_CRM.TEST_PRODUCT_NAME LIMIT 1];
        Favorite_Product__c favoriteProduct = new Favorite_Product__c(Product__c = product.Id);
        favoriteProductList.add(favoriteProduct);
        String productJSON = JSON.serialize(favoriteProductList);
        String action = CON_CRM.CREATE_LABEL;
        Test.startTest();
             CNT_CRM_OpportunityProductSearch.crudFavoriteProductRecord(action, productJSON);
             favoriteProductList = [SELECT id FROM Favorite_Product__c WHERE Product__c = :product.Id and User__c = :UserInfo.getUserId()];
        Test.stopTest();
        Integer expected = 1;
        Integer actual = favoriteProductList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to create favorite product record Exception
     */  
    static testmethod void testCrudFavoriteProductRecordException() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oli = [SELECT Id, OpportunityId, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId =: opp.Id LIMIT 1];
        String productJSON = JSON.serialize(oli);
        String action = CON_CRM.CREATE_LABEL;
        Test.startTest();
        try{
            CNT_CRM_OpportunityProductSearch.crudFavoriteProductRecord(action, productJSON);
            System.assert(false);
        } catch(Exception ex) {
            System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
        } finally {
            Test.stopTest();
        }
    }

    /**
     * test method for updateDefaultProductSearchFilter
     */
    static testmethod void testUpdateDefaultProductSearchFilter() {
        User userRecord = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        Default_Product_Search__c defaultSearch = UTL_TestData.createDefaultProductSearch(userRecord.Id);
        defaultSearch.Default_Offering_Group__c = 'Test';
        String defaultSearchString = JSON.serialize(defaultSearch);
        Test.startTest();
            CNT_CRM_OpportunityProductSearch.updateDefaultProductSearchFilter(defaultSearchString);
        Test.stopTest();
        defaultSearch = [SELECT id FROM Default_Product_Search__c WHERE Default_Offering_Group__c = 'Test'];
        System.assertNotEquals(null, defaultSearch);
    }
    
    /**
     * test method for updateDefaultProductSearchFilter with Exception
     */
    static testmethod void testUpdateDefaultProductSearchFilterException() {
        User userRecord = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        Default_Product_Search__c defaultSearch = UTL_TestData.createDefaultProductSearch(userRecord.Id);
        insert defaultSearch;
        String  offeringGroup = '';
        Integer i = 0;
        while(i < 500) {
            offeringGroup += 'Test';
            i++;
        }
        defaultSearch.Default_Offering_Group__c = offeringGroup;
        String defaultSearchString = JSON.serialize(defaultSearch);
        Test.startTest();
            try {
                CNT_CRM_OpportunityProductSearch.updateDefaultProductSearchFilter(defaultSearchString);
                System.assert(false);
            } catch(Exception ex) {
                System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
            }
        Test.stopTest();
    }
    
    /**
     * test method for getDefaultProductSearchFilter
     *//*
    static testmethod void testGetDefaultProductSearchFilter() {
        User userRecord = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        Default_Product_Search__c defaultSearch = UTL_TestData.createDefaultProductSearch(userRecord.Id);
        insert defaultSearch;
        List<String> fieldList = new List<String>{'Id', 'User__c'};
        Test.startTest();
            System.runAs(userRecord) {
                Set<Id> userIdSet = new Set<Id>{ UserInfo.getUserId() };
                defaultSearch = SRV_CRM_Default_Product_Search.getDefaultProductSearchFilter(userIdSet, fieldList);
            }
        Test.stopTest();
        System.assertNotEquals(Null, defaultSearch);
    }*/
    
    /**
     * test method for getDefaultProductSearchFilter with Exception
     *//*
    static testmethod void testGetDefaultProductSearchFilterException() {
        User userRecord = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        List<String> fieldList = new List<String>{'Id', 'User__'};
        Default_Product_Search__c defaultSearch = null;
        Test.startTest();
        try {
            System.runAs(userRecord) {   
                defaultSearch = CNT_CRM_OpportunityProductSearch.getDefaultProductSearchFilter(fieldList);
                System.assert(false);
            }
        } catch(Exception ex) {
            System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
        }   
        Test.stopTest();
    }*/
    
    /**
     * test method for getOpportunityDetails
     */
    static testmethod void testgetOpportunityDetails() {
        List<String> fieldSet = new List<String>{'Amount','Name', 'Id'}; 
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.Name = 'Test';
        update opp;
        Test.startTest();
            opp = CNT_CRM_OpportunityProductSearch.getOpportunityDetails(opp.Id, fieldSet);
        Test.stopTest();
        String expected = 'Test';
        String actual = opp.Name;
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method for getOpportunityDetails with Exception
     */
    static testmethod void testgetOpportunityDetailsException() {
        List<String> fieldSet = new List<String>{'Name', 'I'}; 
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        try {   
            opp = CNT_CRM_OpportunityProductSearch.getOpportunityDetails(opp.Id, fieldSet);
            System.assert(false);
        } catch(Exception ex) {
            System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
        }   
        Test.stopTest();
    }
    
    /**
     * test method for getOpportunityLineItemSchedule
     */
    static testmethod void testGetOpportunityLineItemSchedule() {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<String> oliFields = new List<String>{'Id'};
        List<String> schFields = new List<String>{'Id'};
        Test.startTest();
            OpportunityWrapper opp = CNT_CRM_OpportunityProductSearch.getOpportunityLineItemSchedule(oli.Id, oliFields, schFields);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = opp.oliWrapperList[0].revSchWrapperList.size();
        system.assertEquals(expected, actual);
    }
    
    /**
     * test method for getOpportunityLineItemSchedule with Exception
     */
    static testmethod void testGetOpportunityLineItemScheduleException() {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<String> oliFields = new List<String>{'Id', 'Nam'};
        List<String> schFields = new List<String>{'Id'};
        Test.startTest();
        try {   
            OpportunityWrapper opp = CNT_CRM_OpportunityProductSearch.getOpportunityLineItemSchedule(oli.Id, oliFields, schFields);
            System.assert(false);
        } catch(Exception ex) {
            System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
        }   
        Test.stopTest();
    }
    
    /**
     * test method for establishSchedule
     */
    static testmethod void testEstablishSchedule() {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        Date startDate = system.today();
        Decimal revenue = 100;
        String scheduleType = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_DIVIDE_SCHEDULE;
        String installmentPeriod = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_QUARTERLY;
        Integer noOfInstallment = 10;
        String type = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_TYPE;
        OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper establishWrapper = new OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper(oli.Id, startDate, revenue, scheduleType, installmentPeriod, noOfInstallment, type);
        Test.startTest();
            OpportunityWrapper opp = CNT_CRM_OpportunityProductSearch.establishSchedule(JSON.serialize(establishWrapper));
            List<OpportunityLineItemSchedule> olisList = [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId =: oli.Id];
        Test.stopTest();
        Integer expected = 10;
        Integer actual = olisList.size();
        system.assertEquals(expected, actual);
    }
    
    /**
     * test method for establishSchedule with Exception
     */
    static testmethod void testEstablishScheduleException() {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        Date startDate = system.today();
        Decimal revenue = 100;
        String scheduleType = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_DIVIDE_SCHEDULE;
        String installmentPeriod = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_QUARTERLY;
        Integer noOfInstallment = -10;
        String type = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_TYPE;
        OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper establishWrapper = new OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper(oli.Id, startDate, revenue, scheduleType, installmentPeriod, noOfInstallment, type);
        Test.startTest();
        try {   
            OpportunityWrapper opp = CNT_CRM_OpportunityProductSearch.establishSchedule(JSON.serialize(establishWrapper));
            System.assert(false);
        } catch(Exception ex) {
            System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
        }   
        Test.stopTest();
    }
    
    /**
     * test method for getUserDetails
     */
    static testmethod void testGetUserDetails() {
        Test.startTest();
            CNT_CRM_OpportunityProductSearch.getUserDetails();
        Test.stopTest();
    }
    
    /**
     * test method for decimalPlaceValue 
     */
    static testmethod void testDecimalPlaceValue() {
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.VFP_CRM_NavigateToAddProducts;
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        CNT_CRM_OpportunityProductSearch.decimalPlaceValue();
        Test.stopTest();
    }
    
    /**
     * test method for decimalPlaceValue exception
     
    static testmethod void testDecimalPlaceValueException() {
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        Id oppId = opp.Id;
        Test.startTest();
        Delete opp;
        PageReference pageRef = Page.VFP_CRM_NavigateToAddProducts;
        pageRef.getParameters().put('id', String.valueOf(oppId));
        Test.setCurrentPage(pageRef);
        CNT_CRM_OpportunityProductSearch.decimalPlaceValue();
        Test.stopTest();
    }*/
    
    /**
     * test method for getMulesoftOpportunitySyncByOppIds 
     */
    static testmethod void testGetMulesoftOpportunitySyncByOppIds() {
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        List<Id> oppIdList = new List<Id>{opp.Id};
        Test.startTest();
        CNT_CRM_OpportunityProductSearch.getMulesoftOpportunitySyncByOppIds(oppIdList);
        CNT_CRM_OpportunityProductSearch.getErrorIfLQMaterialProducts(opp.Id);
        Test.stopTest();
    }
    
    /**
     * test method for getMulesoftOpportunitySyncByOppIds exception
     
    static testmethod void testGetMulesoftOpportunitySyncByOppIdsException() {
        List<Id> oppIdList = new List<Id>();
        Test.startTest();
        CNT_CRM_OpportunityProductSearch.getMulesoftOpportunitySyncByOppIds(oppIdList);
        Test.stopTest();
    }*/
	
    @isTest
    static void testMassUpdateBNF(){
        Opportunity opp = [select id, AccountId from Opportunity limit 1][0];
        List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, Quantity, TotalPrice, UnitPrice, HasRevenueSchedule, Product_Material_Type_Text__c FROM OpportunityLineItem WHERE OpportunityId =: opp.Id LIMIT 1];
        Account acc = [select id from Account where id =:opp.AccountId limit 1][0];
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        Revenue_Analyst__c testRA = UTL_TestData.createRevenueAnalyst();
        insert testRA;
        
        MIBNF2__c mibnf = UTL_TestData.createMIBNF(opp, testRA);
        insert mibnf;
        
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        
        Billing_Schedule__c sche = new Billing_Schedule__c(name = 'textSchedule', OLIId__c = oliList[0].id);
        insert sche;
        Billing_Schedule_Item__c schItem = new Billing_Schedule_Item__c(name = 'textScheduleItem', Billing_Amount__c = 2000,Billing_Date__c = system.today(),Billing_Schedule__c = sche.id);
        insert schItem;
        
        List<MIBNF_Component__c> mibnfComponentList = new List<MIBNF_Component__c>();
        MIBNF_Component__c mibnfComponent1 =  UTL_TestData.createMIBNF_Comp(mibnf, addressList); 
        mibnfComponent1.BNF_Status__c = 'New';
        mibnfComponentList.add(mibnfComponent1);
        insert mibnfComponentList;
        
        List<MI_BNF_LineItem__c> mibnfLineItemList = new List<MI_BNF_LineItem__c>();
        MI_BNF_LineItem__c mibnfLineItem = new MI_BNF_LineItem__c();
        mibnfLineItem.MIBNF_Component__c = mibnfComponentList[0].id;
        mibnfLineItem.Opportunity_Line_Itemid__c = oliList[0].id;
        mibnfLineItem.MIBNFComponent_OLI_ID__c = String.valueOf(mibnfComponentList[0].id) + String.valueOf(oliList[0].id);
        mibnfLineItemList.add(mibnfLineItem);
        insert mibnfLineItemList;
        UTL_ExecutionControl.stopTriggerExecution = false;

        Test.startTest();
        Map<Id,Date> billingMap = new Map<Id,Date>();
        billingMap.put(schItem.Id, schItem.Billing_Date__c);
        CNT_CRM_OpportunityProductSearch.massUpdateBNF(JSON.serialize(new set<String>{mibnfComponent1.id}),'invoice header test class',JSON.serialize(billingMap),'5');
        Test.stopTest(); 
    }
    
     @isTest
    static void testgetMiBNF(){
        Opportunity opp = [select id, AccountId from Opportunity limit 1][0];
        List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, Quantity, TotalPrice, UnitPrice, HasRevenueSchedule, Product_Material_Type_Text__c FROM OpportunityLineItem WHERE OpportunityId =: opp.Id LIMIT 1];
        Account acc = [select id from Account where id =:opp.AccountId limit 1][0];
        Test.startTest();
        Revenue_Analyst__c testRA = UTL_TestData.createRevenueAnalyst();
        insert testRA;
        MIBNF2__c mibnf = UTL_TestData.createMIBNF(opp, testRA);
        insert mibnf;
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        
        List<MIBNF_Component__c> mibnfComponentList = new List<MIBNF_Component__c>();
        MIBNF_Component__c mibnfComponent1 =  UTL_TestData.createMIBNF_Comp(mibnf, addressList); 
        mibnfComponent1.BNF_Status__c = 'New';
        mibnfComponentList.add(mibnfComponent1);
        insert mibnfComponentList;
        
        List<MI_BNF_LineItem__c> mibnfLineItemList = new List<MI_BNF_LineItem__c>();
        MI_BNF_LineItem__c mibnfLineItem = new MI_BNF_LineItem__c();
        mibnfLineItem.MIBNF_Component__c = mibnfComponentList[0].id;
        mibnfLineItem.Opportunity_Line_Itemid__c = oliList[0].id;
        mibnfLineItem.MIBNFComponent_OLI_ID__c = String.valueOf(mibnfComponentList[0].id) + String.valueOf(oliList[0].id);
        mibnfLineItemList.add(mibnfLineItem);

        insert mibnfLineItemList;
        system.debug(Limits.getQueries());
        Billing_Schedule__c sche = new Billing_Schedule__c(name = 'textSchedule', OLIId__c = oliList[0].id);
        insert sche;
        Billing_Schedule_Item__c schItem = new Billing_Schedule_Item__c(name = 'textScheduleItem', Billing_Amount__c = 2000,Billing_Date__c = system.today(),Billing_Schedule__c = sche.id);
        insert schItem;
        system.debug(schItem.Id);
        system.debug(Limits.getQueries());
        Map<Id,Date> billingMap = new Map<Id,Date>();
        billingMap.put(schItem.Id, schItem.Billing_Date__c);
        system.debug(Limits.getQueries());
        CNT_CRM_OpportunityProductSearch.getMIBNFComponent(mibnf.id);
        Test.stopTest(); 
    }
    
    @isTest
    static void testgetTextFieldValues(){
        
        List<PermissionSet> permissionSetList = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Sales_with_BNF'];
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), 
                PermissionSetId = permissionSetList[0].Id);
        insert permissionSetAssignment;
        
		Map<String,String> returnMap = CNT_CRM_OpportunityProductSearch.getTextFieldValues('ProductCode');
        Test.startTest();
        	System.assertEquals('true', returnMap.get('Sales_with_BNF'));
        Test.stopTest();
    }
    
    @isTest
    static void testgetRecentProductList(){
        PriceBookEntry pbe = [SELECT Id, Product2.Name FROM PriceBookEntry LIMIT 1];
        PriceBookEntryWrapper pbWrapper = new PriceBookEntryWrapper(pbe.Product2, pbe);
        String fiterObjString = JSON.serialize(pbWrapper);
        Test.startTest();
        List<PriceBookEntryWrapper> wrapperList = CNT_CRM_OpportunityProductSearch.getRecentProductList(fiterObjString, new List<String>{'Product2.Name'}, new List<String>(), new List<String>(),50, 'AND');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = wrapperList.size();
        System.assertEquals(expected, actual);
    }
    
    @isTest
    static void testEditFavoriteProductRecord(){
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = :CON_CRM.TEST_PRODUCT_NAME LIMIT 1];
        Favorite_Product__c favoriteProduct = UTL_TestData.createFavoriteProduct(prod);
        insert favoriteProduct;
        Test.startTest();
        CNT_CRM_OpportunityProductSearch.editFavoriteProductRecord(prod.Id,'Test Comment','Test Category');
        Test.stopTest();
        String comment = [SELECT Id,User_Comment__c from Favorite_Product__c WHERE Product__r.Name = :CON_CRM.TEST_PRODUCT_NAME LIMIT 1].User_Comment__c;
        System.assertEquals('Test Comment', comment);
    }
    
    @isTest
    static void testCodeCoverage(){
        Id OpportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        List<OpportunityLineItem> olis = [SELECT Id From OpportunityLineItem];
        List<Id> oliIds = new List<Id>();
        for(OpportunityLineItem oli: olis){
            oliIds.add(oli.Id);
        }
        Test.startTest();
        CNT_CRM_OpportunityProductSearch.fetchContactRecordTypeId();
        CNT_CRM_OpportunityProductSearch.getSobjectFieldDetail('Product2',new List<String>{'Name','ProductCode'});
        CNT_CRM_OpportunityProductSearch.getOpportunityLineItemsDetail(oliIds, new List<String>{'Id','Name'});
        Product2 pro = [SELECT Id FROM Product2 LIMIT 1];
        pro.isActive = false;
        update pro;
        CNT_CRM_OpportunityProductSearch.getInactiveOpportunityProducts(OpportunityId);
        Test.stopTest();
    }
}