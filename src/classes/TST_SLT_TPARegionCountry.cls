@isTest(seeAllData = false)
public class TST_SLT_TPARegionCountry {
    @isTest
    static void testSLT_TPARegionCountry() {
        String testId = 'asedhnwaedqw345';
        SLT_TPARegionCountry.instance.getTPARegionCountryDataByConditionAndLimit(new Set<String>(), 'Country__c = \'test\' ', 1);
    }
}