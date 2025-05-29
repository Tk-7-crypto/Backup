/*This BatchCreated Bid Defence RR*/
public class BCH_OWF_AsyncBidDefenseRRCreation implements Database.Batchable<Sobject> , Database.Stateful,Database.AllowsCallouts{
    
    @TestVisible Map<Id, String> agreementIdToErrorMessageMap;
    @TestVisible List<Id> updatedAssignmentList = new List<Id>();
    @TestVisible String asyncBatchMode = ''; 
    private static boolean runOnceFlag = true;
    
    
    public BCH_OWF_AsyncBidDefenseRRCreation(List<Id> incomingAssignmentIdList,String batchMode) {
        agreementIdToErrorMessageMap = new Map<Id, String>();
        updatedAssignmentList = incomingAssignmentIdList;
        asyncBatchMode = batchMode;
        system.debug('asyncBatchMode' + agreementIdToErrorMessageMap);
        system.debug('updatedAssignmentList' + updatedAssignmentList);
        system.debug('agreementIdToErrorMessageMap' + agreementIdToErrorMessageMap);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        //list of all assignments for updating status
        system.debug('updatedAssignmentList'+ updatedAssignmentList);
        return Database.getQueryLocator([SELECT Id, pse__Status__c,RecordTypeId, createdDate,Bid_History__c 
                                         FROM pse__Assignment__c 
                                         WHERE Id in:updatedAssignmentList]);
    }
    
    public void execute(Database.BatchableContext context, List<pse__Assignment__c> records)
    {
        if(runOnceFlag)
        {
            UTL_OWF_SRVUtility.createBDRR(updatedAssignmentList);
            runOnceFlag = false;
        }
        
        /*Set<Id> agreementIdsSet = new Set<Id>();
        Set<String> agreementFieldSet = new Set<String>{'Apttus__Related_Opportunity__r.id'};
        Set<Id> OppIdSet = new Set<Id>();
        List<pse__Resource_Request__c> reqRequestsInsertList = new List<pse__Resource_Request__c>();
        SLT_Agreement sltAgreement = new SLT_Agreement(false,false);
        for(pse__Assignment__c newAssignment : records)
        {
            if(newAssignment.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID && (newAssignment.pse__Status__c == 'Accepted' ||
                                                                                      newAssignment.pse__Status__c == 'Completed'))
            {
                agreementIdsSet.add(newAssignment.Agreement__c);
            }           
        }
        List<Apttus__APTS_Agreement__c> agrList = new List<Apttus__APTS_Agreement__c>();
        if(agreementIdsSet.size() > 0){
            agrList = sltAgreement.getAgreementFieldsById(agreementIdsSet,agreementFieldSet);
        }
        if(agrList.size() > 0)
        {
            for(Apttus__APTS_Agreement__c agg : agrList)
            {
                OppIdSet.add(agg.Apttus__Related_Opportunity__c);
            }
            if(UTL_OWF.isLoginUserhasPermissionControl())
            {
                String agrCondition = 'Apttus__Related_Opportunity__c != NULL And Apttus__Related_Opportunity__c IN :sObjectIdSet ' +
                    ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_AGREEMENT_RECORD_TYPE_ID + '\'';
                reqRequestsInsertList = UTL_OWF.processResRequestForInitialBids(OppIdSet, agrCondition, null, null);
            }
            else
            {
                system.debug('The User does not have the necessary Permissions');
            }
        }
        
        if(reqRequestsInsertList.size()>0)
        {
            system.debug('results');
            Database.SaveResult[] results = Database.Insert(reqRequestsInsertList, false);
            system.debug('results');
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        agreementIdToErrorMessageMap.put(reqRequestsInsertList[i].Agreement__c, 'Error in Bid Defence Creation: '+reqRequestsInsertList[i].SubGroup__c + ': Error:' + results[i].getErrors()[0].getMessage());
                    }
                }
            }
        }
*/
  
    
    }
    public void finish(Database.BatchableContext context)
    {
       if(asyncBatchMode==CON_OWF.BCH_COMPLETING_MODE)
       {
        //Run batch after to update Current FTE on Contact
        OWF_Batch_Config__c batchConfig = OWF_Batch_Config__c.getInstance('BCH_OWF_UpdateCurrentFTEOnContact');
        Integer batchSize;
        if(batchConfig != null && batchConfig.Batch_Size__c != null)
            batchSize = (Integer)batchConfig.Batch_Size__c;
        else
            batchSize = CON_OWF.DEFAULT_BATCH_SIZE;
        BCH_OWF_UpdateCurrentFTEOnContact batch = new BCH_OWF_UpdateCurrentFTEOnContact();
        database.executeBatch(batch, batchSize);
       }
        
        
    }
}