@IsTest
public class TST_SLT_PriceList {

    private static Apttus_Config2__PriceList__c createPriceList(String migrationId) {
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        priceList.Name = CON_OCE.TEST_PRICELIST_NAME;
        priceList.CurrencyIsoCode = CON_CPQ.USD;
        priceList.Migration_Id__c = migrationId;
        insert priceList;
        return priceList;
    }

    @IsTest
    private static void testPriceListById() {

        Apttus_Config2__PriceList__c testPriceList = createPriceList('PL-002');

        Test.startTest();
        List<Apttus_Config2__PriceList__c> resultPriceLists =  new SLT_PriceList().
            selectById(new Set<Id>{testPriceList.Id});
        Test.stopTest();

        System.assertEquals(1, resultPriceLists.size());
        System.assertEquals(testPriceList.Id, resultPriceLists.get(0).Id );
    }

    @IsTest
    private static void testPriceListByCurrency() {

        Apttus_Config2__PriceList__c testPriceList = createPriceList('PL-003');

        Test.startTest();
        List<Apttus_Config2__PriceList__c> resultPriceLists =  new SLT_PriceList()
            .selectByCurrency(new Set<String>{CON_CPQ.USD});
        Test.stopTest();

        System.assertEquals(1, resultPriceLists.size());
        System.assertEquals(testPriceList.Id, resultPriceLists.get(0).Id );
    }
    
    @IsTest
    private static void testPriceListByName() {

        Apttus_Config2__PriceList__c testPriceList = createPriceList('PL-004');

        Test.startTest();
        List<Apttus_Config2__PriceList__c> resultPriceLists =  new SLT_PriceList()
            .selectByName(CON_OCE.TEST_PRICELIST_NAME, new Set<String>{CON_CPQ.ID, CON_CPQ.NAME});
        Test.stopTest();

        System.assertEquals(1, resultPriceLists.size());
    }
    
    @IsTest
    private static void testPriceListByNames() {

        Apttus_Config2__PriceList__c testPriceList = UTL_TestData.createPriceList(CON_CPQ.TECH_SOLUTION_JAPAN);

        Test.startTest();
        List<Apttus_Config2__PriceList__c> resultPriceLists =  new SLT_PriceList()
            .selectByNames(new Set<String>{CON_CPQ.TECH_SOLUTION_JAPAN}, new Set<String>{CON_CPQ.ID, CON_CPQ.NAME});
        Test.stopTest();

        System.assertEquals(1, resultPriceLists.size(), 'Price List size mis-match');
        System.assertEquals(testPriceList.Id, resultPriceLists.get(0).Id, 'Price List Id mis-match');
    }
}
