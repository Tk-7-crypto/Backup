/*
 * Version       : 1.0
 * Description   : This test class is used for Select PriceBook2
 */
@isTest
public class TST_SLT_PriceBook2 {

    /**
     * This method used to Select OpportunityLineItems by opportunity id
     */    
    @IsTest
    static void testGetStandardPriceBook() {
        Set<String> fieldSet = new Set<String> {'Id'};
        Test.startTest();
            List<PriceBook2> pbList = new SLT_PriceBook2().getStandardPriceBook(fieldSet);
        Test.stopTest();
	}
}