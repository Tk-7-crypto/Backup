public with sharing class CNT_OWF_CreatePrismQuote {
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getOpportunityFields(Id recordId) {
        Map<String,String> bidOpportunityReturnMap = new Map<String,String>();
        Map<Id, Bid_History__c> bidHistoryToOpportunityMap = new Map<Id, Bid_History__c>(new SLT_Bid_History(false,false).getBidHistoriesById(new Set<Id>{recordId},new Set<String>{'id','OwnerId','Bid_History_Related_Opportunity__r.LQ_Opportunity_Id__c'}));
        Map<Id, User> lqOwnerIdMap = new Map<Id, User>(new SLT_User().selectByUserId(new Set<Id>{bidHistoryToOpportunityMap.get(recordId).OwnerId},new Set<String>{'id','LQ_User_Id__c'}));
        List<Legacy_Org_Link__c> lqLegacyOrgLinkUrlList = new List<Legacy_Org_Link__c>([SELECT Legacy_Quintiles_URL__c FROM Legacy_Org_Link__c ]);
        if(bidHistoryToOpportunityMap.size()>0 ){
            bidOpportunityReturnMap.put('lqOpportunityId',bidHistoryToOpportunityMap.get(recordId).Bid_History_Related_Opportunity__r.LQ_Opportunity_Id__c);
            bidOpportunityReturnMap.put('lqLegacyOrgLink',lqLegacyOrgLinkUrlList[0].Legacy_Quintiles_URL__c);
            bidOpportunityReturnMap.put('lqOwnerId',lqOwnerIdMap.get(bidHistoryToOpportunityMap.get(recordId).OwnerId).LQ_User_Id__c);
        }
        return bidOpportunityReturnMap;
        
    }
}