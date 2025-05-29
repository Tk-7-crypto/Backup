public class DAOH_CRM_Bid_History {
    
    public static void updateRfpReceivedDate(List<Bid_History__c> newList, Map < Id, Bid_History__c > oldMap) {
        Id clinicalBidRecordTypeId = CON_CRM.CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID;
        Id earlyEngagementBidRecordTypeId = CON_CRM.EARLY_ENGAGEMENT_BID_BID_HISTORY_RECORD_TYPE_ID;
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {Opportunity.SObjectType});
        Set<Id> opportunityIdSet = new Set<ID>();
        Map<Id, Bid_History__c> oppIdToBidHistoryMap = new Map<Id, Bid_History__c>();
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, Opportunity> oppIdtoOppMap = new Map<Id, Opportunity>();
        Set<String> oppFieldSet = new Set<String>{'Id','StageName','Proposal_Sent_Date__c','RFP_ReceivedDate__c'};
            if(trigger.isUpdate){
                for(Bid_History__c agr: newList){
                    if(agr.Bid_Number__c == 1 && agr.recordTypeId == clinicalBidRecordTypeId && 
                       (oldMap.get(agr.id).Bid_Sent_Date__c == null && agr.Bid_Sent_Date__c != null)){
                           oppIdSet.add(agr.Bid_History_Related_Opportunity__c);
                       }
                }
            }
        if(oppIdSet.size()>0){
            oppIdtoOppMap = new SLT_Opportunity().getOpportunityById(oppIdSet,oppFieldSet);
        }
        for (Bid_History__c agr: newList) {
            if(agr.Bid_Number__c == 1 && agr.recordTypeId == clinicalBidRecordTypeId){
                if(Trigger.isInsert){
                    Opportunity opp = new Opportunity(Id = agr.Bid_History_Related_Opportunity__c, RFP_ReceivedDate__c = agr.RFP_Received_Date__c);
                    uow.registerDirty(opp);
                }else if(Trigger.isUpdate && (agr.RFP_Received_Date__c != oldMap.get(agr.id).RFP_Received_Date__c ||
                    agr.Bid_Number__c != oldMap.get(agr.id).Bid_Number__c || agr.recordTypeId != oldMap.get(agr.id).recordTypeId )){
                        Opportunity opp = new Opportunity(Id = agr.Bid_History_Related_Opportunity__c, RFP_ReceivedDate__c = agr.RFP_Received_Date__c);
                        uow.registerDirty(opp);
                }
                if(Trigger.isUpdate && (agr.Bid_Sent_Date__c != null || 
                          agr.Bid_Number__c != oldMap.get(agr.id).Bid_Number__c || agr.recordTypeId != oldMap.get(agr.id).recordTypeId)){
                          Opportunity opp = oppIdtoOppMap.get(agr.Bid_History_Related_Opportunity__c);
                          if(oppIdtoOppMap.containsKey(agr.Bid_History_Related_Opportunity__c) && oppIdtoOppMap.get(agr.Bid_History_Related_Opportunity__c).Proposal_Sent_Date__c == null){
                          	opp.Proposal_Sent_Date__c = agr.Bid_Sent_Date__c;
                            uow.registerDirty(opp); 
                          }
                }
            } else if(agr.recordTypeId == earlyEngagementBidRecordTypeId) {
                if(Trigger.isInsert){
                    Opportunity opp = new Opportunity(Id = agr.Bid_History_Related_Opportunity__c, Early_Engagement_COE__c = agr.TSSU_Early_Engagement_COE__c);
                    uow.registerDirty(opp);
                } else if(Trigger.isUpdate && agr.TSSU_Early_Engagement_COE__c != oldMap.get(agr.Id).TSSU_Early_Engagement_COE__c){
                    opportunityIdSet.add(agr.Bid_History_Related_Opportunity__c);
                }
            }
        }
        if(opportunityIdSet != null && opportunityIdSet.size() > 0){
            Set<String> agrFieldSet = new Set<String>{'Id','Bid_History_Related_Opportunity__c', 'RecordTypeId'};
            Map<Id, Bid_History__c> agreementMap = new SLT_Bid_History(false, false).getAgreementByOppIDSortByCreatedDateDesc(opportunityIdSet, agrFieldSet); 
            for(Bid_History__c agr : agreementMap.values()){
                if(oppIdToBidHistoryMap != null && !oppIdToBidHistoryMap.containsKey(agr.Bid_History_Related_Opportunity__c)
                  && agr.RecordTypeId == earlyEngagementBidRecordTypeId){
                    oppIdToBidHistoryMap.put(agr.Bid_History_Related_Opportunity__c,agr);
                }
            }
        }
        for (Bid_History__c agr: newList){
            if(Trigger.isUpdate && agr.TSSU_Early_Engagement_COE__c != oldMap.get(agr.Id).TSSU_Early_Engagement_COE__c){
                if(oppIdToBidHistoryMap != null && oppIdToBidHistoryMap.containsKey(agr.Bid_History_Related_Opportunity__c) 
                   && oppIdToBidHistoryMap.get(agr.Bid_History_Related_Opportunity__c).Id == agr.Id){
                    	Opportunity opp = new Opportunity(Id = agr.Bid_History_Related_Opportunity__c, Early_Engagement_COE__c = agr.TSSU_Early_Engagement_COE__c);
                        uow.registerDirty(opp);
                }
            }
        }

        UTL_ExecutionControl.stopTriggerExecution = true;
        uow.commitWork();
        UTL_ExecutionControl.stopTriggerExecution = false;
    }

}