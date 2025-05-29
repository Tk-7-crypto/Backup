public class DAOH_AmaAgreementDetail {
    static TGRH_TPAAMAAgreement helper = new TGRH_TPAAMAAgreement(Trigger.isExecuting);
    
    public static void onBeforeUpdate(List<AMA_Agreement_Detail__c> newRecords, List<AMA_Agreement_Detail__c> oldRecords, Map<Id, AMA_Agreement_Detail__c> newMap, Map<Id, AMA_Agreement_Detail__c> oldMap) {
        helper.onBeforeUpdate(oldRecords, newRecords, oldMap, newMap);
    }
    
    public static void onAfterUpdate(List<AMA_Agreement_Detail__c> newRecords, List<AMA_Agreement_Detail__c> oldRecords, Map<Id, AMA_Agreement_Detail__c> newMap, Map<Id, AMA_Agreement_Detail__c> oldMap) {
        helper.onAfterUpdate(oldRecords, newRecords, oldMap, newMap);
    }

    
}
