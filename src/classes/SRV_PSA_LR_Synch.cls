public without sharing class SRV_PSA_LR_Synch {
    
    public static void deleteDataofSearchStrategy(List<Search_Strategy__c> ssListToDelete){
        if(ssListToDelete.size() > 0){
            Delete ssListToDelete;        
        }    
    }
    public static void deleteDataofLRSS(List<LR_Search_Strategy_Relationship__c> lrSSListToDelete){
        // updated LRSS Releationship List send to be deleted 
        if(lrSSListToDelete.size() > 0){
            Delete lrSSListToDelete;         
        }        
    }
    
    public static void deleteDataofEventJournal(List<Event_Journals__c> ejListToDelete){
        // updated LRSS Releationship List send to be deleted 
        if(ejListToDelete.size() > 0){
            Delete ejListToDelete;         
        }        
    }
    
    public static void deleteDataofLREJ(List<LR_Event_Journals_Relationship__c> lrEJListToDelete){
        // updated LRSS Releationship List send to be deleted 
        if(lrEJListToDelete.size() > 0){
            Delete lrEJListToDelete;
        }        
    }
}