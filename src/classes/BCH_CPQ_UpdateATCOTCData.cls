public class BCH_CPQ_UpdateATCOTCData implements Database.Batchable<sObject>{
    
    private Map<String, Decimal> migIdAndUpdatedMarketShareMap = new Map<String, Decimal>();
    String quarter;
    public BCH_CPQ_UpdateATCOTCData(Map<String, Decimal> idShareMap, String selectedQuarter) {
        this.migIdAndUpdatedMarketShareMap = idShareMap;
        this.quarter = selectedQuarter;
    }
    public Database.Querylocator start (Database.BatchableContext bc) {
        Set<String> migIdSet = migIdAndUpdatedMarketShareMap.keySet();
        return Database.getQueryLocator('SELECT Id, Quarter__c, Migration_Id__c, Market_Share__c FROM ATC_OTC_Classification__c WHERE Migration_Id__c IN :migIdSet'); 
    }
    
    public void execute (Database.BatchableContext bc, List<sObject> sObjectList) {
        List<ATC_OTC_Classification__c> updatedATCOTCRecords = new List<ATC_OTC_Classification__c>();
        for(ATC_OTC_Classification__c atcOTCRecord : (List<ATC_OTC_Classification__c>)sObjectList) {
            atcOTCRecord.Market_Share__c = migIdAndUpdatedMarketShareMap.get(atcOTCRecord.Migration_Id__c);
            atcOTCRecord.Quarter__c = this.quarter;
            updatedATCOTCRecords.add(atcOTCRecord);
        }
        update updatedATCOTCRecords;
    }
    
    public void finish(Database.BatchableContext bc) {}
}
