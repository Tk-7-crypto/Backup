@IsTest
public class TST_BCH_CPQ_CreatePriceMatrixEntry {
	@testSetup
    static void dataSetup() {

        Apttus_Config2__PriceList__c priceList = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
        insert priceList;
   
        Product2 product = TST_TestGeneratorClass.buildTestProduct('LC9', 'Option','CPQ-TS-AMESA-Data-PI-KLPO', 'US', 'Go Blue');
        insert product;  
    }

    @isTest
    static void testCreatePriceMatrixEntry() {
        
        ID priceListiId = [SELECT ID FROM Apttus_Config2__PriceList__c LIMIT 1].ID;
        ID productId = [SELECT ID FROM Product2 LIMIT 1].ID;
        
        Apttus_Config2__PriceListItem__c priceListItem = new Apttus_Config2__PriceListItem__c();
        priceListItem.Apttus_Config2__Active__c = true;
        priceListItem.Apttus_Config2__PriceListId__c = priceListiId;
        priceListItem.Apttus_Config2__ProductId__c = productId;
        priceListItem.Apttus_Config2__RollupPriceToBundle__c = true; 
        priceListItem.Apttus_Config2__AllowManualAdjustment__c = true;
        priceListItem.Apttus_Config2__AllocateGroupAdjustment__c = true; 
        priceListItem.Migration_Id__c = 'PLI-011'; 
        insert priceListItem;
        
        Apttus_Config2__PriceMatrix__c priceMatrix = new Apttus_Config2__PriceMatrix__c(Apttus_Config2__PriceListItemID__c = priceListItem.ID, 
                                                                                        Apttus_Config2__EnableDateRange__c=false, 
                                                                                        Apttus_Config2__EnableUsageIndexing__c=false, 
                                                                                        Apttus_Config2__IsCumulativeRange__c=false, 
                                                                                        Apttus_Config2__Sequence__c=1, 
                                                                                        Apttus_Config2__StopProcessingMoreMatrices__c=false,
                                                                                        Migration_Id__c = 'PM-012');
        insert priceMatrix;
 
        Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry = new Apttus_Config2__PriceMatrixEntry__c(Apttus_Config2__PriceMatrixID__c = priceMatrix.ID, 
                                                                                                       Apttus_Config2__IsIncluded__c = false, 
                                                                                                       Apttus_Config2__Sequence__c = 1,
                                                                                                       Migration_Id__c = 'PME-013');
        
        List<Apttus_Config2__PriceMatrixEntry__c> pmeList = new List<Apttus_Config2__PriceMatrixEntry__c>();
        pmeList.add(priceMatrixEntry);
        
        Test.startTest();
            BCH_CPQ_CreatePriceMatrixEntry objBatch = new BCH_CPQ_CreatePriceMatrixEntry(pmeList, '2024', 'AMESA', 1, 2);
            Database.executeBatch(objBatch);
        Test.stopTest();

        Apttus_Config2__PriceMatrixEntry__c createdPME = [SELECT ID FROM Apttus_Config2__PriceMatrixEntry__c LIMIT 1];
        System.assertNotEquals(null, createdPME, 'Price Matrix Entry created successfully');
    }
}
