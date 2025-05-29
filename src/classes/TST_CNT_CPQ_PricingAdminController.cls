@IsTest
Private class TST_CNT_CPQ_PricingAdminController {
    
    /**
	* This method used to set up testdata
	**/
    @TestSetup    
    static void dataSetup() {

        CPQ_Pricing_Admin_Settings__c customTestSetting = new CPQ_Pricing_Admin_Settings__c(Name = 'CPQ-TS-AMESA', Group_Attribute__c = 'Eligible_Countries__c', Partial_Last_Stored_Migration_Id__c = 'CAPPPAT-00000',
                                                                                            Attribute_List__c = 'Eligible_Countries__c;Data_Delivery_Frequency__c;With_CD_DVD_Deliveries__c;No_of_Lines__c;Number_of_Repos__c;No_Of_Territories__c;Market_Share__c;Type__c;Subscription_Type__c', 
                                                                                            Last_Stored_Migration_Id__c = 'PLIP-0000000;PMP-0000000;PMEP-0000000', Pricing_Tool__c = 'AMESA',Permission_Set_Name__c = 'CPQ_TS_AMESA_Data_ReadWrite', Partial_Pricing_Required__c = true, 
                                                                                           Attribute_Label_List__c = 'Country;Data Delivery Frequency;With CD/DVD Deliveries;No of Lines;Number of Repos;No. of Territories;Market Share %;Type;Subscription Type', Base_Currency__c = 'CHF');
        insert customTestSetting;
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.No_of_Installment_for_Schedule_Creation__c = 1;
        insert cpqSetting;

        CPQ_Proposal_Create_Settings__c cpqProposalCreateSettings  = new CPQ_Proposal_Create_Settings__c();
        cpqProposalCreateSettings.Name = 'CPQ TS Proposal';
        cpqProposalCreateSettings.Available_Pricing_Tools__c = 'AMESA';
        cpqProposalCreateSettings.Price_List__c = 'Test PriceList';
        cpqProposalCreateSettings.Permission_Set_Name__c = 'CPQ_TS_AMESA_Read_Write';
        cpqProposalCreateSettings.Proposal_Record_Type_Name__c = 'Tech_Solution';
        cpqProposalCreateSettings.Master_Price_List__c = 'AMESA Price List - USD';
        insert cpqProposalCreateSettings;
        
        Apttus_Config2__PriceList__c priceList = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
        priceList.Name = cpqProposalCreateSettings.Master_Price_List__c;
        insert priceList;
                
        Product2 product1 = TST_TestGeneratorClass.buildTestProduct('LC9', 'Option','CPQ-TS-AMESA-Data-PI-KLPO', 'US', 'Go Blue');
        insert product1;
        Product2 product2 = TST_TestGeneratorClass.buildTestProduct('LC9', 'Bundle','CPQ-TS-AMESA-Data-PI-KLPO', 'US', 'Go Blue');
        insert product2;
        Apttus_Config2__PriceListItem__c priceListItem = TST_TestGeneratorClass.buildTestPriceListItem(priceList.id, product1.id,'PLI-011');  
        priceListItem.Apttus_Config2__Criteria__c = '{ "sObjectName" : "Apttus_Config2__LineItem__c", "sObjectLabel" : "Line Item", "searchText" : null, "filter" : { "predicates" : [ { "RowNum" : 1, "RHSSObjectName" : null, "RHSFieldType" : null, "RHSFieldName" : null, "RHSFieldLabel" : null, "RHSChildFilterName" : null, "RefFieldName" : null, "OffsetValue" : null, "LHSSObjectName" : null, "LHSChildFilterName" : null, "FieldValue" : "2023", "FieldType" : "DOUBLE", "FieldName" : "Start_Date_Year__c", "FieldLabel" : "Start Date Year", "CompOper" : "equal to", "BoolOper" : null } ], "hasRHSFields" : false, "condExpr" : "1", "childFilter" : null }, "fields" : [ "Start_Date_Year__c" ], "extFields" : [ ], "exprStr" : "(Start Date Year = 2023)" }';
        insert priceListItem;
        Apttus_Config2__PriceListItem__c priceListItem1 = TST_TestGeneratorClass.buildTestPriceListItem(priceList.id, product2.id,'PLI-012');  
        priceListItem1.Apttus_Config2__Criteria__c = '{ "sObjectName" : "Apttus_Config2__LineItem__c", "sObjectLabel" : "Line Item", "searchText" : null, "filter" : { "predicates" : [ { "RowNum" : 1, "RHSSObjectName" : null, "RHSFieldType" : null, "RHSFieldName" : null, "RHSFieldLabel" : null, "RHSChildFilterName" : null, "RefFieldName" : null, "OffsetValue" : null, "LHSSObjectName" : null, "LHSChildFilterName" : null, "FieldValue" : "2023", "FieldType" : "DOUBLE", "FieldName" : "Start_Date_Year__c", "FieldLabel" : "Start Date Year", "CompOper" : "equal to", "BoolOper" : null } ], "hasRHSFields" : false, "condExpr" : "1", "childFilter" : null }, "fields" : [ "Start_Date_Year__c" ], "extFields" : [ ], "exprStr" : "(Start Date Year = 2023)" }';
        insert priceListItem1;
        
        List<Apttus_Config2__PriceMatrix__c> pmList = new List<Apttus_Config2__PriceMatrix__c>();
        Apttus_Config2__PriceMatrix__c priceMatrix1 = new Apttus_Config2__PriceMatrix__c(Apttus_Config2__PriceListItemId__c = priceListItem.id, 
                                                                                         Apttus_Config2__EnableDateRange__c = false, 
                                                                                         Apttus_Config2__EnableUsageIndexing__c = false, 
                                                                                         Apttus_Config2__IsCumulativeRange__c = false, 
                                                                                         Apttus_Config2__Sequence__c = 1, 
                                                                                         Apttus_Config2__StopProcessingMoreMatrices__c = false,
                                                                                         Migration_Id__c = 'PM-011');
        pmList.add(priceMatrix1);
        insert pmList;
        
        List<Apttus_Config2__PriceMatrixEntry__c> pmeList = new List<Apttus_Config2__PriceMatrixEntry__c>();
        Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry1 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix1.id, 
                                                                                                        Apttus_Config2__IsIncluded__c = false, 
                                                                                                        Apttus_Config2__Sequence__c = 1,
                                                                                                        Migration_Id__c = 'PME-011',
                                                                                                        Apttus_Config2__Dimension1Value__c = 'KW', 
                                                                                                        Apttus_Config2__AdjustmentAmount__c = 100);
        pmeList.add(priceMatrixEntry1);
        Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry2 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix1.id, 
                                                                                                        Apttus_Config2__IsIncluded__c = false, 
                                                                                                        Apttus_Config2__Sequence__c = 1,
                                                                                                        Migration_Id__c = 'PME-012',
                                                                                                        Apttus_Config2__Dimension1Value__c = 'KW', 
                                                                                                        Apttus_Config2__AdjustmentAmount__c = 200);
        pmeList.add(priceMatrixEntry2);
        insert pmeList;
		
		List<CPQ_AMESA_Partial_Product_Pricings__c> partialProductPricingList = new List<CPQ_AMESA_Partial_Product_Pricings__c>();
        
        CPQ_AMESA_Partial_Product_Pricings__c partialProductPricing1 = new CPQ_AMESA_Partial_Product_Pricings__c(CPQ_Product_Code__c = 'CPQ-TS-AMESA-Data-CH-PECN-1',
                                                                                                                 CPQ_ProductName__c = 'PEC (National)',
                                                                                                                 Country__c = 'KW',
                                                                                                                 Market_Type__c = 'Total market',
                                                                                                                 Data_Delivery_Frequency__c = 'Monthly',
                                                                                                                 Final_Price__c = 99,
                                                                                                                 Final_Price_with_molecule__c = 99,
                                                                                                                 Key__c = 'CPQ-TS-AMESA-Data-CH-PECN-1:KW:test 24/03 - 1:2023',
                                                                                                                 Product_Name__c = 'test 24/03 - 1',
                                                                                                                 Type__c = 'ATC',
                                                                                                                 Year__c = '2023',
                                                                                                                 isActive__c = true, Migration_Id__c = 'CAPPPPAT-00001');
        
        CPQ_AMESA_Partial_Product_Pricings__c partialProductPricing2 = new CPQ_AMESA_Partial_Product_Pricings__c(CPQ_Product_Code__c = 'CPQ-TS-AMESA-Data-CH-PECN-2',
                                                                                                                 CPQ_ProductName__c = 'PEC (National)',
                                                                                                                 Country__c = 'KW',
                                                                                                                 Market_Type__c = 'Total market',
                                                                                                                 Data_Delivery_Frequency__c = 'Monthly',
                                                                                                                 Final_Price__c = 999,
                                                                                                                 Final_Price_with_molecule__c = 999,
                                                                                                                 Key__c = 'CPQ-TS-AMESA-Data-CH-PECN-2:KW:test 24/03 - 2:2023',
                                                                                                                 Product_Name__c = 'test 24/03 - 2',
                                                                                                                 Type__c = 'ATC',
                                                                                                                 Year__c = '2023',
                                                                                                                 isActive__c = true, Migration_Id__c = 'CAPPPPAT-00002');
        
        partialProductPricingList.add(partialProductPricing1);
        partialProductPricingList.add(partialProductPricing2);
        insert partialProductPricingList;
    }
    
    @isTest
    static void testGetPricingDetails() {
        CNT_CPQ_PricingAdminController.WPR_CPQ_PricingWrapper pricingObj = CNT_CPQ_PricingAdminController.getPricingDetails('AMESA');
        System.assertNotEquals(null, pricingObj, 'Pricing Detail Wrapper fetched successfully');
    }
    
    @isTest
    static void testSavePriceMatrixEntries() {
        List<Apttus_Config2__PriceMatrixEntry__c> pmeList = retrievePriceMatrixEntryList();

        String pmJSON = JSON.serialize(new Map<Id, Apttus_Config2__PriceMatrix__c>{pmeList[0].Apttus_Config2__PriceMatrixId__c => pmeList[0].Apttus_Config2__PriceMatrixId__r,
                                                                                   pmeList[1].Apttus_Config2__PriceMatrixId__c => pmeList[1].Apttus_Config2__PriceMatrixId__r});
        String idToPLI = JSON.serialize(new Map<Id, Apttus_Config2__PriceListItem__c>{pmeList[0].Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Id => pmeList[0].Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r});
        String attributePercentMap = JSON.serialize(new Map<String, String>{'KW' => '1'});
        Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__r = new Apttus_Config2__PriceMatrix__c(Migration_Id__c = 'PM-011'), 
                                                                                                       Apttus_Config2__IsIncluded__c = false, 
                                                                                                       Apttus_Config2__Sequence__c = 1,
                                                                                                       Migration_Id__c = 'PME-015');
        String MapStringPME = JSON.serialize(new Map<Id, Apttus_Config2__PriceMatrixEntry__c>{pmeList[0].Id => priceMatrixEntry});
        
        Test.startTest();
            CNT_CPQ_PricingAdminController.WPR_CPQ_ParentRecordWrapper insertStatus1 = CNT_CPQ_PricingAdminController.savePriceMatrixEntries(new List<Apttus_Config2__PriceMatrixEntry__c>{pmeList[0]}, null, '2024', '2023', pmJSON, attributePercentMap, 'AMESA', null, null);
            CNT_CPQ_PricingAdminController.WPR_CPQ_ParentRecordWrapper insertStatus2 = CNT_CPQ_PricingAdminController.savePriceMatrixEntries(new List<Apttus_Config2__PriceMatrixEntry__c>{pmeList[1]}, null, '2024', '2023', pmJSON, attributePercentMap, 'AMESA', JSON.serialize(insertStatus1.IdToPLIMap), JSON.serialize(insertStatus1.IdToPMMap));
            CNT_CPQ_PricingAdminController.WPR_CPQ_ParentRecordWrapper updateStatus = CNT_CPQ_PricingAdminController.savePriceMatrixEntries(null, pmeList, null, '2023', null, attributePercentMap, 'AMESA', idToPLI, pmJSON);
            String processbatch1 = CNT_CPQ_PricingAdminController.processBatchItems(MapStringPME, JSON.serialize(null), JSON.serialize(null), '2024', 'AMESA', 2, 2);
            CNT_CPQ_PricingAdminController.getBatchJobResult('AMESA');
            pmeList = CNT_CPQ_PricingAdminController.getInactivePriceMatrixEntries('2024', 'KW', 'AMESA');
            CNT_CPQ_PricingAdminController.updatePriceMatrixEntries(pmeList);
            CNT_CPQ_PricingAdminController.activatePriceBookEntries('2024', 'AMESA');
        Test.stopTest();
       
        System.assertEquals('Insert', insertStatus1.Status, 'Insert Operation called successfully');
        System.assertEquals('Update', updateStatus.Status, 'Update Operation called successfully');
    }
	
    @isTest
    static void testSavePartialPricing(){
        List<CPQ_AMESA_Partial_Product_Pricings__c> partialPricingList = [SELECT ID, Migration_Id__c, Final_Price_with_LMPT__c, Standard_Type__c, CurrencyIsoCode, CPQ_Product_Code__c, CPQ_ProductName__c, Country__c, Market_Type__c, Data_Delivery_Frequency__c, Final_Price__c, Final_Price_with_molecule__c, Key__c, Product_Name__c, Type__c, Year__c, isActive__c FROM CPQ_AMESA_Partial_Product_Pricings__c];
        
        Test.startTest();
            String insertStatus = CNT_CPQ_PricingAdminController.savePartialPricing(partialPricingList, null, '2024', '2023', 'AMESA');
            String updateStatus = CNT_CPQ_PricingAdminController.savePartialPricing(null, partialPricingList, null, '2023', 'AMESA');
        Test.stopTest();
        
        System.assertEquals('Insert', insertStatus, 'Insert Operation called successfully');
        System.assertEquals('Update', updateStatus, 'Update Operation called successfully');
        
        
    }
    private static List<Apttus_Config2__PriceMatrixEntry__c> retrievePriceMatrixEntryList(){
        List<Apttus_Config2__PriceMatrixEntry__c> pmeList = [SELECT Id, Local_Currency_Code__c,
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ProductId__c,
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c,
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Frequency__c,
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceMethod__c,
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceType__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ListPrice__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__EnablePriceRamp__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__MatrixType__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension1Id__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension2Id__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension3Id__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension4Id__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension5Id__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension1ValueType__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension2ValueType__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension3ValueType__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension4ValueType__c,
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension5ValueType__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Sequence__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Id, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Criteria__c, 
                                                             Apttus_Config2__Dimension1Value__c, Apttus_Config2__Dimension2Value__c, 
                                                             Apttus_Config2__Dimension3Value__c, Apttus_Config2__Dimension4Value__c, 
                                                             Apttus_Config2__Dimension5Value__c, Apttus_Config2__Dimension6Value__c, 
                                                             Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__AdjustmentType__c, 
                                                             Apttus_Config2__PriceOverride__c, Apttus_Config2__Sequence__c, Partial_Save__c, Migration_Id__c
                                                             FROM Apttus_Config2__PriceMatrixEntry__c];
        return pmeList;
    }
    
    @isTest
    static void testGetAvailablePricingTool(){
        Map<String, String> result = CNT_CPQ_PricingAdminController.getAvailablePricingTool();
        System.assertNotEquals(null, result, 'Available Pricing tool fetched successfully');
    }
}
