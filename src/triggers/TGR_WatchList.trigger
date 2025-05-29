trigger TGR_WatchList on Watch_List__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    //system.debug('watchlistTrigger');
    fflib_SObjectDomain.triggerHandler(DAO_WatchList.class);
    
    /*if(Trigger.isInsert && Trigger.isAfter) {system.debug('After Insert S:::');
        // Assign values of trigger new list to helper class variable
        TGRH_WatchList.newWatchLists = Trigger.New;
        
        // Call helper class method to create history
        TGRH_WatchList.createHistoryOfApprove();system.debug('After Insert E:::');
    }
    else if(Trigger.isUpdate &&  Trigger.isAfter) {system.debug('After Update S:::');
        // Assign values of trigger new list to helper class variable
        TGRH_WatchList.newWatchLists = Trigger.New;
        // Assign values of trigger old map to helper class variable
        TGRH_WatchList.oldWatchListMap = Trigger.oldMap;
        
        // Call helper class method to create history
        TGRH_WatchList.createHistoryOfApprove();system.debug('After Update E:::');
    }*/
}