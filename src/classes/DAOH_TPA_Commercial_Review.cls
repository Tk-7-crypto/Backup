public class DAOH_TPA_Commercial_Review {

	public static void onAfterUpdate(List<TPA_Commercial_Review__c> newRecords,List<TPA_Commercial_Review__c> existingRecords,Map<Id, TPA_Commercial_Review__c> newRecordsMap,Map<Id, TPA_Commercial_Review__c> oldRecordsMap) {
		TGRH_TPA_Commercial_Review.checkIfApproved(newRecords,existingRecords,newRecordsMap,oldRecordsMap);        
    }

	public static void onBeforeUpdate(List<TPA_Commercial_Review__c> newRecords,List<TPA_Commercial_Review__c> existingRecords,Map<Id, TPA_Commercial_Review__c> newRecordsMap,Map<Id, TPA_Commercial_Review__c> oldRecordsMap) {
		TGRH_TPA_Commercial_Review.validateRecordsBeforeUpdate(newRecords,existingRecords,newRecordsMap,oldRecordsMap);        
    }

    public static void onBeforeInsert(List<TPA_Commercial_Review__c> newRecords) {
        TGRH_TPA_Commercial_Review.validateRecordsBeforeUpdate(newRecords,null,null,null);
    }

}