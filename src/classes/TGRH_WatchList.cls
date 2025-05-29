/**
 * Author: Neetu Bansal
 * Since: June 19, 2015
 * Name: TPA_WatchListTrgHelper
 * Description: Helper class of Watch List trigger
 *              Added by Neetu Bansal under Issue-07325
**/
public class TGRH_WatchList {
    // To store boolean value, whether to run trigger or not
    public static Boolean runTrigger = true;
    // List to store Watch Lists of trigger.new
    public static List<Watch_List__c> newWatchLists = new List<Watch_List__c>();
    // List to store Watch Lists of trigger.old
    public static List<Watch_List__c> oldWatchLists = new List<Watch_List__c>();
    // Map to store Watch Lists of trigger.newMap
    public static Map<Id, Watch_List__c> newWatchListMap = new Map<Id, Watch_List__c>();
    // Map to store Watch Lists of trigger.oldMap
    public static Map<Id, Watch_List__c> oldWatchListMap = new Map<Id, Watch_List__c>();
    
    /**
     * Method: createHistoryOfApprove
     * @param:
     * @return:
     * @Desc: Method to create history of Watch List if Approved or not
    **/
    /*public static void createHistoryOfApprove()
    {
        // List of Watch List History to be inserted
        List<Watch_List_History__c> watchHistoriesToBeInserted = new List<Watch_List_History__c>();
        
        // Iterate over all the Watch List
        for( Watch_List__c watch : newWatchLists )
        {
            // Check if insert or Approved value was edited
            if( trigger.isInsert
                || ( trigger.isUpdate && watch.Always_Approved__c != oldWatchListMap.get( watch.Id ).Always_Approved__c ) )
            {
                // Create Instance of Watch List History
                Watch_List_History__c watchHistory = new Watch_List_History__c( Watch_List__c = watch.Id, Approve__c = watch.Always_Approved__c );
                
                // Add into list
                watchHistoriesToBeInserted.add( watchHistory );
            }
        }
        
        // Check if size > 0, insert history
        if( watchHistoriesToBeInserted.size() > 0 )
            insert watchHistoriesToBeInserted;
    }*/

}
