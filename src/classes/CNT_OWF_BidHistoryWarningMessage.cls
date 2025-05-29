public with sharing class CNT_OWF_BidHistoryWarningMessage {
    @AuraEnabled
    public static Boolean getBidHistoryData(Id recordId) {        
        List<Bid_History__c> bidHistories = new SLT_Bid_History().getBidHistoryWithCollectionTools(new Set<Id>{recordId}); 
        if(bidHistories.size() > 0) {
            Bid_History__c bidHistory = bidHistories[0];
            Integer studyNumber = Integer.valueOf(bidHistory.Study_Number__c);
            Integer collectionToolRows = bidHistory.Collection_Tools__r.Size();
            return studyNumber != collectionToolRows;
        } else {
            return false; 
        }
    }
}