public with sharing class CNT_OWF_AwardBidHistory {
    
    @AuraEnabled(cacheable = true)
    public static List<WPR_OWF_BidHistoryWrapper> getBidHistoryRelatedToOpportunity(String opportunityId) {
        if (opportunityId != null) {
            Set<String> bhrFieldSet = (new Set<String>{'Id', 'Bid_Type__c', 'Name', 'Is_Study_Awarded__c', 'Total_Bid_Value_Labor_Direct_Discount__c',
                'Bid_Number__c', 'Scenario_Number__c', 'RFP_Scenario__c', 'Number_of_Scenarios__c', 'Bid_Due_Date__c', 'Bid_Sent_Date__c', 'Comments__c', 'Related_Quote_Status__c'});
            String whereclause = 'Bid_History_Related_Opportunity__c IN :sObjectIdSet AND RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
            List<WPR_OWF_BidHistoryWrapper> bidHistoryWrapperList = new List<WPR_OWF_BidHistoryWrapper>();
            List<Bid_History__c> bidHistoryRecordsList = new List<Bid_History__c>();
            
            bidHistoryRecordsList = new SLT_Bid_History(false, false).getBidHistoriesByCondition(bhrFieldSet, whereClause, new Set<Id>{opportunityId});
            for(Bid_History__c bidHistoryRecord: bidHistoryRecordsList){
                bidHistoryWrapperList.add(new WPR_OWF_BidHistoryWrapper(bidHistoryRecord));
            }
            return bidHistoryWrapperList;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static void awardBidHistoryRecord(String bidHistoryIdToAward, Boolean isCommentsUpdated, String updatedComments) {
        if(bidHistoryIdToAward != null){
            Set<String> bhrFieldSet = (new Set<String>{'Id', 'Bid_History_Related_Opportunity__c', 'Is_Study_Awarded__c', 'Awarded_Date__c', 'Comments__c'});
            String whereclause = 'Id IN :sObjectIdSet';
            List<Bid_History__c> bidHistoryRecordsListToAward = new SLT_Bid_History(false, false).getBidHistoriesByCondition(bhrFieldSet, whereClause, new Set<Id>{bidHistoryIdToAward});
            String errorMessage = '';
            
            if(bidHistoryRecordsListToAward != null && bidHistoryRecordsListToAward.size() > 0){
                bidHistoryRecordsListToAward[0].Is_Study_Awarded__c = 'Yes';
                bidHistoryRecordsListToAward[0].Awarded_Date__c = Datetime.now();
                bidHistoryRecordsListToAward[0].Comments__c = isCommentsUpdated ? updatedComments : bidHistoryRecordsListToAward[0].Comments__c;
                if(bidHistoryRecordsListToAward[0].Bid_History_Related_Opportunity__c != null) {
                    Set<Id> sObjectIdSet = new Set<Id>();
                    sObjectIdSet.add(bidHistoryRecordsListToAward[0].Bid_History_Related_Opportunity__c);
                    String condition = 'Bid_History_Related_Opportunity__c in : sObjectIdSet '+' AND (Record_Type__c = \'' + CON_CPQ.CONTRACT_POST_AWARD_BID  +'\') '+' AND Bid_Due_Date__c >= TODAY';
                    Set<String> fieldSet = new Set<String>{'Latest_Awarded_Bid__c'};
                    List<Bid_History__c> bidHistoryList = new SLT_Bid_History().getBidHistoriesByCondition(fieldSet, condition, sObjectIdSet);
                    if (bidHistoryList.size () > 0) {
                        for(Bid_History__c bid : bidHistoryList) {
                            bid.Latest_Awarded_Bid__c = bidHistoryRecordsListToAward[0].Id;
                            bidHistoryRecordsListToAward.add(bid);
                        }
                    }
                }
                try{
                    update bidHistoryRecordsListToAward;
                }catch(DmlException e){
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        errorMessage = + e.getDmlMessage(i) + '\n';
                    }
                    throw new AuraHandledException(errorMessage);
                    
                }catch(Exception e){
                    throw new AuraHandledException(e.getMessage());
                }
            }
        }
    }
    
    public class WPR_OWF_BidHistoryWrapper {
        @auraEnabled
        public String id {get; set;}
        @auraEnabled
        public String bidType {get; set;}
        @auraEnabled
        public String bidHistoryName {get; set;}
        @AuraEnabled
        public String bidHistoryRecordUrl {get {return this.id != null ? '/lightning/r/' + this.id + '/view' : '';}}
        @auraEnabled
        public String awarded {get; set;}
        @auraEnabled
        public String totalValue {get; set;}
        @auraEnabled
        public String bidNumber {get; set;}
        @auraEnabled
        public String scenarioNumber {get; set;}
        @auraEnabled
        public String scenario {get; set;}
        @auraEnabled
        public String numberOfScenarios {get; set;}
        @auraEnabled
        public String bidDueDate {get; set;}
        @auraEnabled
        public String bidSentDate {get; set;}
        @auraEnabled
        public String comments {get; set;}
        @auraEnabled
        public Boolean isCommentsEditable {get; set;}
        @auraEnabled
        public String relatedQuoteStatus {get; set;}
        
        public WPR_OWF_BidHistoryWrapper(Bid_History__c bidHistoryRecord) {
            id = bidHistoryRecord.Id != null ? bidHistoryRecord.Id : '';
            bidType = bidHistoryRecord.Bid_Type__c != null ? bidHistoryRecord.Bid_Type__c : '';
            bidHistoryName = bidHistoryRecord.Name != null ? bidHistoryRecord.Name : '';
            awarded = bidHistoryRecord.Is_Study_Awarded__c != null ? bidHistoryRecord.Is_Study_Awarded__c : '';
            totalValue = bidHistoryRecord.Total_Bid_Value_Labor_Direct_Discount__c != null ? String.valueOf(bidHistoryRecord.Total_Bid_Value_Labor_Direct_Discount__c.setScale(2)) : '';
            bidNumber = bidHistoryRecord.Bid_Number__c != null ? String.valueOf(bidHistoryRecord.Bid_Number__c) : '';
            scenarioNumber = bidHistoryRecord.Scenario_Number__c != null ? String.valueOf(bidHistoryRecord.Scenario_Number__c) : '';
            scenario = bidHistoryRecord.RFP_Scenario__c != null ? bidHistoryRecord.RFP_Scenario__c : '';
            numberOfScenarios = bidHistoryRecord.Number_of_Scenarios__c != null ? String.valueOf(bidHistoryRecord.Number_of_Scenarios__c) : '';
            bidDueDate = bidHistoryRecord.Bid_Due_Date__c != null ? String.valueOf((bidHistoryRecord.Bid_Due_Date__c).day()) +'/' + String.valueOf((bidHistoryRecord.Bid_Due_Date__c).month()) +'/' + String.valueOf((bidHistoryRecord.Bid_Due_Date__c).year()) : '';
            bidSentDate = bidHistoryRecord.Bid_Sent_Date__c != null ? String.valueOf((bidHistoryRecord.Bid_Sent_Date__c).day()) +'/' + String.valueOf((bidHistoryRecord.Bid_Sent_Date__c).month()) +'/' + String.valueOf((bidHistoryRecord.Bid_Sent_Date__c).year()) : '';
            comments = bidHistoryRecord.Comments__c != null ? bidHistoryRecord.Comments__c : '';
            isCommentsEditable = false;
            relatedQuoteStatus = bidHistoryRecord.Related_Quote_Status__c != null ? bidHistoryRecord.Related_Quote_Status__c : '';
        }
    }
}