/*
* @author Hammad Siddiqui
* REST Service to Implement Bid Defense
*
* ----------------------------------------------------------------------------
* Date Modified     Modified By        Description of the update
* ----------------------------------------------------------------------------
* 13 Oct 2020       OWF                
*                                      *
*                                      *
*                                      *
*
*/


@RestResource(urlMapping='/OWFServices/RRSerevices')
global with sharing class SRV_OWF_RST_RRSerevices {
    
    @HttpPost
    global static String doPost(String doPostCase, List<String> reuqiredParams)
    {
        
        String httpResponseString = '';
        Switch on doPostCase
        {
            when 'createBDRR'
            {
                List<Id> updatedAssingmentIdList= new List<Id>();
                for(String idAsString: reuqiredParams)
                {
                    updatedAssingmentIdList.add(Id.valueOf(idAsString)); 
                }
                httpResponseString = createBidDefenseRR(updatedAssingmentIdList);
                if(RestContext.response.statusCode!=200)
                {
                    RestRequest req = RestContext.request;
                    Apex_Error_Log__c errorLogInstance = new Apex_Error_Log__c();
                    errorLogInstance.Source_Module__c = 'OWF (Create Bid Defence RR from Webservice)';
                    errorLogInstance.Failed_Job_Type__c = 'WebService (REST)';
                    if(RestContext.request.requestBody!=null)
                    	errorLogInstance.Job_Request_JSON__c = RestContext.request.requestBody.toString();
                    else
                        errorLogInstance.Job_Request_JSON__c = doPostCase + ';' + reuqiredParams;
                	errorLogInstance.Job_Response_JSON__c = httpResponseString;
                    errorLogInstance.Running_User__c = UserInfo.getUserId();
                    errorLogInstance.Record_Processed_Date__c = system.today();
                    errorLogInstance.Object__c = 'pse__Assignment__c';
                    errorLogInstance.Record_Processed__c = false;
                    errorLogInstance.Error_Message__c = 'Service Response: '+RestContext.response.statusCode+ '; /n' + httpResponseString ;
                    insert errorLogInstance;
                }
                return httpResponseString;
            }
            when else {		  
                return 'Other Option';
            }
        }
        
    }
    
    
    
    private static String createBidDefenseRR(List<Id> updatedAssignmentList)
    {
        @TestVisible Map<Id, String> agreementIdToErrorMessageMap  = new Map<Id,String>();
        String errorMsgString = '';
        if(updatedAssignmentList.size()>0)
        {

            List<pse__Assignment__c> records = [SELECT Id, pse__Status__c,RecordTypeId, createdDate,Bid_History__c 
                                                FROM pse__Assignment__c 
                                                WHERE Id in:updatedAssignmentList];
            Set<Id> agreementIdsSet = new Set<Id>();
            Set<String> agreementFieldSet = new Set<String>{'Bid_History_Related_Opportunity__r.id'};
            Set<Id> OppIdSet = new Set<Id>();
            List<pse__Resource_Request__c> reqRequestsInsertList = new List<pse__Resource_Request__c>();
            SLT_Bid_History sltAgreement = new SLT_Bid_History(false,false);
            for(pse__Assignment__c newAssignment : records)
            {
                if(newAssignment.recordTypeId == CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID && (newAssignment.pse__Status__c == 'Accepted' ||
                                                                                           newAssignment.pse__Status__c == 'Completed'))
                {
                    agreementIdsSet.add(newAssignment.Bid_History__c);
                }           
            }
            List<Bid_History__c> agrList = new List<Bid_History__c>();
            if(agreementIdsSet.size() > 0){
                agrList = sltAgreement.getBidHistoryFieldsById(agreementIdsSet,agreementFieldSet);
            }
            if(agrList.size() > 0)
            {
                for(Bid_History__c agg : agrList)
                {
                    OppIdSet.add(agg.Bid_History_Related_Opportunity__c);
                }
                if(UTL_OWF.isLoginUserhasPermissionControl())
                {
                    String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
                        ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
                    reqRequestsInsertList = UTL_OWF.processResRequestForInitialBids(OppIdSet, agrCondition, null, null);
                }
                else
                {
                    RestContext.response.statusCode = 404;
                	RestContext.response.responseBody = Blob.valueOf('The User does not have the necessary Permissions');
                    return errorMsgString;
                }
            }
            
            if(reqRequestsInsertList.size()>0)
            {
                Database.SaveResult[] results;
                results = Database.Insert(reqRequestsInsertList, false);
                if (results.size() > 0){
                    for (Integer i=0; i< results.size(); i++){
                        if (!results[i].isSuccess()){
                            agreementIdToErrorMessageMap.put(reqRequestsInsertList[i].Bid_History__c, 'Error in Bid Defence Creation: '+reqRequestsInsertList[i].SubGroup__c + ': Error:' + results[i].getErrors()[0].getMessage());
                        }
                    }
                }
            }
            if(agreementIdToErrorMessageMap.keySet().size()>0)
            {
                String commitResultResponseString = JSON.serialize(agreementIdToErrorMessageMap);
                RestContext.response.statusCode = 500;
                return commitResultResponseString;
            }
            else
            {
                RestContext.response.statusCode = 200;
                RestContext.response.responseBody = Blob.valueOf('Bid Defence: Bid Defence Resource Request Created');
                return 'Bid Defence: Bid Defence Resource Request Created';
            }
            
            
        }
        else
        {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Bad  Request: updateAssignmentList was empty');
            return 'Bad  Request: updateAssignmentList was empty';
        }
    }
    
}
