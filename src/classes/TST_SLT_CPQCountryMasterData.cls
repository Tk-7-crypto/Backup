@isTest
public class TST_SLT_CPQCountryMasterData {
    @testSetup
    static void dataSetup() {
        CPQ_Country_Master_Data__c cpqData = new CPQ_Country_Master_Data__c();
        cpqData.Country__c = 'Albania';
        insert cpqData;
    }
    
    @isTest 
    static void testGetCountryMasterDataByNames() {
        CPQ_Country_Master_Data__c cpqData = [SELECT Id FROM CPQ_Country_Master_Data__c LIMIT 1];
        Set<String> fieldSet = new Set<String>{CON_CPQ.COUNTRY, CON_CPQ.LANGUAGE, CON_CPQ.SITE_ADOPTION_PROBABILITY};

        Test.startTest();
            List<CPQ_Country_Master_Data__c> countryMasterDataList = new SLT_CPQCountryMasterData().getCountryMasterDataByNames(new Set<String> {'Albania'}, fieldSet);
            SLT_CPQCountryMasterData sltCpq = new SLT_CPQCountryMasterData();
            sltCpq.getSObjectType();
            sltCpq.getOrderBy();
            sltCpq.getSObjectFieldList();
        Test.stopTest();
        
        System.assertNotEquals(0, countryMasterDataList.size(), 'Country Master Data list is empty.');
    }
}