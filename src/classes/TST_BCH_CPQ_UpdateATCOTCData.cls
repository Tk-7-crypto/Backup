@isTest
public class TST_BCH_CPQ_UpdateATCOTCData {
    
    @testSetup
    static void dataSetup(){
        ATC_OTC_Classification__c atcClass = new ATC_OTC_Classification__c();
        atcClass.Hierarchy1_Code__c = 'A0';
        atcClass.Hierarchy1_Name__c = 'A0 ALIMENTARY T.& METABOLISM';
        atcClass.Hierarchy2_Code__c = 'A01';
        atcClass.Hierarchy2_Name__c = 'A01 STOMATOLOGICALS';
        atcClass.Hierarchy3_Code__c = 'A01A';
        atcClass.Hierarchy3_Name__c = 'A01A STOMATOLOGICALS';
        atcClass.Hierarchy4_Code__c = 'A01A0';
        atcClass.Hierarchy4_Name__c = 'A01A0 STOMATOLOGICALS';
        atcClass.Country_Code__c = 'KW';
        atcClass.Market_Share__c = 0.24;
        atcClass.Market_Type__c = 'LPO';
        atcClass.Standard_Type__c = CON_CPQ.EPHMRA;
        atcClass.Type__c = CON_CPQ.ATC;
        atcClass.Migration_Id__c = 'AO-001';
        insert atcClass;
    }
    
    @isTest
    static void testUpdateATCOTCData(){
        ATC_OTC_Classification__c testATCOTCData = [SELECT Id,Migration_Id__c FROM ATC_OTC_Classification__c WHERE Country_Code__c = 'KW' AND Market_Share__c = 0.24 AND Market_Type__c = 'LPO'];
        Map<String, Decimal> migIdAndUpdatedMarketShareMap = new Map<String, Decimal>();
        String quarter = '2023 Q1';
        migIdAndUpdatedMarketShareMap.put(testATCOTCData.Migration_Id__c, 0.5);
        
        Test.startTest();
        Database.executeBatch(new BCH_CPQ_UpdateATCOTCData(migIdAndUpdatedMarketShareMap, quarter));
        Test.stopTest();
        
        ATC_OTC_Classification__c atcOTCRecord = [SELECT Id, Quarter__c, Market_Share__c FROM ATC_OTC_Classification__c WHERE Id =:testATCOTCData.Id];
        System.assertEquals(0.5, atcOTCRecord.Market_Share__c, 'Market Share Updated');
        System.assertEquals('2023 Q1', atcOTCRecord.Quarter__c, 'Quarter Updated');
    }

}
