public with sharing class DAOH_CBEx_Bid_History {
    
	/** IQVIA CBEX 339 start updated IQVIACBEX-1199
    * @description : Method to create folder on box
    * @author Anup Kage  | 4/16/2020 updated by Yash Sharma
    * @param newBidHistoryList 
    * @return void 
    **/
    public static void reParentFilesToAgreement(List<Bid_History__c> newBidHistoryList){
        Set<Id> opportunityIdSet = new Set<Id>();
        for(Bid_History__c objBidHistory : newBidHistoryList){
            opportunityIdSet.add(objBidHistory.Bid_History_Related_Opportunity__c);
        }
        Map<Id, String> opportunityById = new Map<Id,String>();
        for(Opportunity objOpp: new SLT_Opportunity().getLegacyQuintilesByOpportunityById(opportunityIdSet, new Set<String>{'Id','Legacy_Quintiles_Opportunity_Number__c'})){
            opportunityById.put(objOpp.id, objOpp.Legacy_Quintiles_Opportunity_Number__c);
        }  
        for(Bid_History__c objBidHistory : newBidHistoryList){  
            Id clinicalBidRecordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByName().get('Clinical Bid').getRecordTypeId();       
            if( objBidHistory.recordTypeId == clinicalBidRecordTypeId){
                // Calling method to create nested folder
                if(!Test.isRunningTest()){
                    System.enqueueJob(new CNT_BOX_QueuableFolderCreation(objBidHistory.Id, objBidHistory.Bid_History_Related_Opportunity__c, 'Bid History'));
                }
                //When the record type is initial then we have to reparent the folder from opportunity to agreement
            }
        }
    }
    //IQVIA CBEX 339

    /**  IQVIA CBEX 578  // IQVIACBEX-1200
    * @description : To create Unity link on Agreement while creating agreement
    * @param newAgreementList 
    **/
    public static void createUnityLink(List<Bid_History__c> newBidHistory){
        Set<Id> bidHistoryIdSet = new Set<Id>();
        for(Bid_History__c objAgreement : newBidHistory){ 
            bidHistoryIdSet.add(objAgreement.Id);  
        }
        //IQVIACBEX-3015 Call Synchronous method to update unity Link before making a callout
        CNT_CLP_CallOut.getAgreementForCallout(bidHistoryIdSet, true, false);
        CNT_CLP_CallOut.getAgreementDetails(bidHistoryIdSet);
    }
	
	/**********************************************************************************************
    * @Author:      Razia Khan
    * @Date:        11/03/2022
    * @Description: IQVIACBEX-1804:This method is responsible for sending the new and old field values for further
    *               implementation of sync logic between Salesforce and Unity using mulesoft as 
    *               middleware.
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
    public static void setUnityFlagSyncMechanism(Map<Id, Bid_History__c> newMap, Map<Id, Bid_History__c> oldMap) {
        CNT_RFP_IntakeUnityFlagSync.processSyncLogic(CON_CBEx.BIDHISTORY_OBJECT, newMap, oldMap);
    }
}