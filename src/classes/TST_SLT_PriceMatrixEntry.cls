@IsTest
public class TST_SLT_PriceMatrixEntry {
    @TestSetup    
    static void dataSetup() {
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.Key_Generation_Org__c = UserInfo.getOrganizationId();
        insert cpqSetting;
        
        Apttus_Config2__PriceList__c priceList = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
        insert priceList;
                
        Product2 product1 = TST_TestGeneratorClass.buildTestProduct('LC9', 'Option','CPQ-TS-AMESA-Data-PI-KLPO', 'US', 'Go Blue');
        insert product1;
        
        Apttus_Config2__PriceListItem__c priceListItem = TST_TestGeneratorClass.buildTestPriceListItem(priceList.id, product1.id,'PLI-011');  
        priceListItem.Apttus_Config2__Criteria__c = '{ "sObjectName" : "Apttus_Config2__LineItem__c", "sObjectLabel" : "Line Item", "searchText" : null, "filter" : { "predicates" : [ { "RowNum" : 1, "RHSSObjectName" : null, "RHSFieldType" : null, "RHSFieldName" : null, "RHSFieldLabel" : null, "RHSChildFilterName" : null, "RefFieldName" : null, "OffsetValue" : null, "LHSSObjectName" : null, "LHSChildFilterName" : null, "FieldValue" : "2023", "FieldType" : "DOUBLE", "FieldName" : "Start_Date_Year__c", "FieldLabel" : "Start Date Year", "CompOper" : "equal to", "BoolOper" : null } ], "hasRHSFields" : false, "condExpr" : "1", "childFilter" : null }, "fields" : [ "Start_Date_Year__c" ], "extFields" : [ ], "exprStr" : "(Start Date Year = 2023)" }';
        insert priceListItem;
        
        List<Apttus_Config2__PriceMatrix__c> pmList = new List<Apttus_Config2__PriceMatrix__c>();
        Apttus_Config2__PriceMatrix__c priceMatrix1 = new Apttus_Config2__PriceMatrix__c(Apttus_Config2__PriceListItemId__c = priceListItem.id, 
                                                                                         Apttus_Config2__EnableDateRange__c = false, 
                                                                                         Apttus_Config2__EnableUsageIndexing__c = false, 
                                                                                         Apttus_Config2__IsCumulativeRange__c = false, 
                                                                                         Apttus_Config2__Sequence__c = 1, 
                                                                                         Apttus_Config2__StopProcessingMoreMatrices__c = false,
                                                                                         Migration_Id__c = 'PM-011');
        pmList.add(priceMatrix1);
        
        Apttus_Config2__PriceMatrix__c priceMatrix2 = new Apttus_Config2__PriceMatrix__c(Apttus_Config2__PriceListItemId__c = priceListItem.id, 
                                                                                         Apttus_Config2__EnableDateRange__c = false, 
                                                                                         Apttus_Config2__EnableUsageIndexing__c = false, 
                                                                                         Apttus_Config2__IsCumulativeRange__c = false, 
                                                                                         Apttus_Config2__Sequence__c = 1, 
                                                                                         Apttus_Config2__StopProcessingMoreMatrices__c = false,
                                                                                         Migration_Id__c = 'PM-012');
        pmList.add(priceMatrix2);
        insert pmList;
        
        List<Apttus_Config2__PriceMatrixEntry__c> pmeList = new List<Apttus_Config2__PriceMatrixEntry__c>();
        Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry1 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix1.id, 
                                                                                                        Apttus_Config2__IsIncluded__c = false, 
                                                                                                        Apttus_Config2__Sequence__c = 1,
                                                                                                        Migration_Id__c = 'PME-011',
                                                                                                        Apttus_Config2__Dimension1Value__c = 'KW');
        pmeList.add(priceMatrixEntry1);
        Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry2 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix1.id, 
                                                                                                        Apttus_Config2__IsIncluded__c = false, 
                                                                                                        Apttus_Config2__Sequence__c = 1,
                                                                                                        Migration_Id__c = 'PME-012',
                                                                                                        Apttus_Config2__Dimension1Value__c = 'KW');
        pmeList.add(priceMatrixEntry2);
        Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry3 = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixId__c = priceMatrix2.id, 
                                                                                                        Apttus_Config2__IsIncluded__c = false, 
                                                                                                        Apttus_Config2__Sequence__c = 1,
                                                                                                        Migration_Id__c = 'PME-013',
                                                                                                        Apttus_Config2__Dimension1Value__c = 'KW');
        pmeList.add(priceMatrixEntry3);
        insert pmeList;
    }
    
    @IsTest
    private static void testGetPriceMatrixEntriesByPriceList() {
        String condition = 'Migration_Id__c != null';
        Test.startTest();
        List<Apttus_Config2__PriceMatrixEntry__c> pmeList =  new SLT_PriceMatrixEntry().
            getPriceMatrixEntriesByPriceList(new Set<String>{CON_CPQ.ID, CON_CPQ.NAME}, condition, 'Test PriceList');
        Test.stopTest();

        System.assertEquals(true, pmeList.size() > 0, 'Price Matrix fetched successfully');
    }

}
