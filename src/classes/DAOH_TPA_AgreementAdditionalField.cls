public class DAOH_TPA_AgreementAdditionalField {
    static TGRH_TPA_AgreementAdditionalField triggerHelper = new TGRH_TPA_AgreementAdditionalField();

    public static void onBeforeInsert(List<TPA_Agreement_Additional_Field__c> newRecords) {
        triggerHelper.onBeforeInsert(newRecords);
    }

    public static void onBeforeUpdate(List<TPA_Agreement_Additional_Field__c> newRecords, List<TPA_Agreement_Additional_Field__c> oldRecords, Map<Id, TPA_Agreement_Additional_Field__c> newMap, Map<Id, TPA_Agreement_Additional_Field__c> oldMap) {
        triggerHelper.onBeforeUpdate(newRecords, oldRecords, newMap, oldMap);
    }
    
     public static void onAfterUpdate(List<TPA_Agreement_Additional_Field__c> newRecords, List<TPA_Agreement_Additional_Field__c> oldRecords, Map<Id, TPA_Agreement_Additional_Field__c> newMap, Map<Id, TPA_Agreement_Additional_Field__c> oldMap) {
        triggerHelper.onAfterUpdate(oldRecords, newRecords, oldMap, newMap);
    }
}