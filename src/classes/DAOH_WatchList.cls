public class DAOH_WatchList {

    public static void onAfterInsert(List<Watch_List__c> newRecords) {
        // Assign values of trigger new list to helper class variable
        TGRH_WatchList.newWatchLists = newRecords;
        
        // Call helper class method to create history
        //TGRH_WatchList.createHistoryOfApprove();
    }
    
    public static void onAfterUpdate(List<Watch_List__c> newRecords, List<Watch_List__c> oldRecords, Map<Id, Watch_List__c> newMap, Map<Id, Watch_List__c> oldMap) {
        // Assign values of trigger new list to helper class variable
        TGRH_WatchList.newWatchLists = newRecords;
        // Assign values of trigger old map to helper class variable
        TGRH_WatchList.oldWatchListMap = oldMap;
        
        // Call helper class method to create history
        //TGRH_WatchList.createHistoryOfApprove();
    }
}
