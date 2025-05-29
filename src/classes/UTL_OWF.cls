/**
* This is Utility class for OWF
* version : 1.0
*/

public class UTL_OWF {
    public static boolean oppUpdateViaRestService = false;
    public static boolean agreementUpdateViaRestService = false;
    public static boolean ratingUpdateViaTrigger = false;
    public static boolean isAssignmentStatusUpdateAsCancelledBySystem = false;
    public static String MODULE_NAME = CON_OWF.OWF_MODULE_NAME;
    public static Integer EMAIL_ALERT_CONTENT_LENGTH = 131072;
    public static Boolean bidUpdatedFromAgreement = false;

/*
* Method to send emails 	
*/
    public static void sendMailOnException(String batchName, Map<Id, String> sObjectIdToErrorMessageMap, String emailSubject) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        OWF_Batch_Config__c batchConfig = OWF_Batch_Config__c.getInstance(batchName);
        List<String> userIdList = new List<String>();
        if(batchConfig != null && batchConfig.User_Ids__c != null && batchConfig.User_Ids__c != ''){
            userIdList = batchConfig.User_Ids__c.split(',');
        }
        else{
            userIdList.add(userInfo.getUserId());
        }
        
        String errorList = '';
        Integer counter = 0;
        for (Id k : sObjectIdToErrorMessageMap.keySet() ) {
            errorList += ++counter+'. '+k+'----> ';
            errorList += sObjectIdToErrorMessageMap.get(k)+'\n\n  ';
        }
        Messaging.SingleEmailMessage mail;
        for (Id userId : userIdList){
            mail = new Messaging.SingleEmailMessage();
            mail.setSubject(emailSubject + 'Failed'); 
            mail.setPlainTextBody('Following errors occured during batch process : \n\n'+ errorList);  
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(userId);
            emailList.add(mail);
        }
        Messaging.sendEmail(emailList);
    }
    
    /*
* Method to create Apex Error logs if any exception occurs during the process
* @params  objectName String
* @params  errorMessage String
* @params  sObjectIdToErrorMessageMap Map<Id, String>
*/
    public static void createApexErrorLogs(String objectName, String errorMessage, Map<Id, String> sObjectIdToErrorMessageMap) {
        Apex_Error_Log__c apexErrorLog = new Apex_Error_Log__c();
        apexErrorLog.Running_User__c = UserInfo.getUserId();
        apexErrorLog.Object__c = objectName;
        
        String errorList = '';
        Integer counter = 0;
        for (Id k : sObjectIdToErrorMessageMap.keySet() ) {
            errorList += ++counter+'. '+k+'----> ';
            errorList += sObjectIdToErrorMessageMap.get(k)+'\n\n  ';
        }
        
        apexErrorLog.Error_Message__c = errorMessage + '\n\n' + errorList;
        insert apexErrorLog;
    }
  
    
      
/**
* This is Utility method which is used to create Resource Requests on update of LineItemGroup, Opportunity & Agreement and on insert of Projects.
* @params  sObjectIdSet Set<Id>
* @params  agrCondition String
* @params  initialAgrmtIdToProjectMap Map<Id, pse__Proj__c>
* @params  oppIdToBidsProjectsMap Map<Id, List<pse__Proj__c>>
* @params    List<pse__Resource_Request__c>
*/
    public static List<pse__Resource_Request__c> processResRequestForInitialBids(Set<Id> sObjectIdSet, String agrCondition, Map<Id, pse__Proj__c> initialAgrmtIdToProjectMap, Map<Id, List<pse__Proj__c>> oppIdToReBidsProjectsMap) {
        List<pse__Resource_Request__c> reqRequestsInsertList = new List<pse__Resource_Request__c>();
        Map<Id, List<Bid_History__c>> oppIdAndAgreementsMap = new Map<Id, List<Bid_History__c>>();
        Map<Id, Bid_History__c> oppIdToInitialBidMap = new Map<Id, Bid_History__c>();
        Map<Id, Bid_History__c> oppIdToInitialBidMapToCloneReBid = new Map<Id, Bid_History__c>();
        Map<Id, Map<String, pse__Resource_Request__c>> initialBidIdToSubGroupResRequestsMap = new Map<Id, Map<String, pse__Resource_Request__c>>();
        Map<Id, Map<String, List<pse__Resource_Request__c>>> initialBidIdToBidDefenseSubGroupResRequestsMap = new Map<Id, Map<String, List<pse__Resource_Request__c>>>();
        
        String resReqCondition = 'pse__Opportunity__c != NULL And SubGroup__c != NULL And Bid_History__c != NULL And Bid_History__r.Bid_Number__c = 1 ';
        Set<String> agrFieldSet = new Set<String>{'Id', 'RFP_Ranking__c', 'Bid_History_Related_Opportunity__c', 
            'Bid_History_Related_Opportunity__r.Phase_P__c', 'Bid_History_Related_Opportunity__r.Line_of_Business__c',
            'Bid_History_Related_Opportunity__r.Potential_Regions__c','Bid_History_Related_Opportunity__r.InterventionType__c',
            'Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c', 'Bid_History_Related_Opportunity__r.Bid_Defense_Date__c',
            'Bid_History_Related_Opportunity__r.Amount','Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c','RecordTypeId',
            'Bid_Due_Date__c', 'Requested_Services__c', 'Targeted_Countries__c', 'Budget_Deliverable__c', 'Bid_Number__c', 'Bid_Due_Date__c', 'CurrencyIsoCode','Is_there_a_Client_Bid_Grid__c','Grid_Ranking_Level__c',
            'Bid_History_Related_Opportunity__r.Rare_Disease__c','Bid_History_Related_Opportunity__r.Population_Age_Group__c','Estimated_Fees__c','Win_Probability__c','Opportunity_Type__c',
            'Bid_History_Related_Opportunity__r.Identified_Business__c','Additional_Services_Requested__c','Bid_History_Related_Opportunity__r.pse__Parent_Opportunity__c','Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c','Bid_History_Related_Opportunity__r.Global_project_unit__c'};              
        //(IQVIAPSA-2285 == Start)
        Set<String> resReqFieldSet = new Set<String>{'Id', 'Bid_History__r.RecordTypeId','pse__Opportunity__c', 'Bid_History__c', 'Is_Bid_Defense__c', 'pse__Project__c', 'SubGroup__c', 'Potential_Regions__c', 'pse__Start_Date__c', 'pse__End_Date__c','pse__Status__c','pse__Assignment__c','pse__Assignment__r.pse__Status__c', 'CurrencyIsoCode', 'pse__Staffer_Resource__c','Is_Created_Automatically__c','Suggested_FTE__c','Is_Created_Automatically_Initial_Bid__c','LeadSupportFlag__c', 'Regional_Analytics_Country__c'};
        //(IQVIAPSA-2285 == Stop)
        Map<Id, Bid_History__c> agreementByIdMap = new SLT_Bid_History(false,false).getAgreementAndResReqsByOppId(sObjectIdSet, agrFieldSet, resReqFieldSet, agrCondition, resReqCondition);
        Set<Bid_History__c> agrmtToRRCancelSet = new Set<Bid_History__c>();
        
        for(Bid_History__c agrmt : agreementByIdMap.values()) {
            if(!oppIdAndAgreementsMap.containsKey(agrmt.Bid_History_Related_Opportunity__c)) {
                oppIdAndAgreementsMap.put(agrmt.Bid_History_Related_Opportunity__c, new List<Bid_History__c>());
            }
            oppIdAndAgreementsMap.get(agrmt.Bid_History_Related_Opportunity__c).add(agrmt);
            if(agrmt.Bid_Number__c == 1) {
                oppIdToInitialBidMap.put(agrmt.Bid_History_Related_Opportunity__c, agrmt);
                oppIdToInitialBidMapToCloneReBid.put(agrmt.Bid_History_Related_Opportunity__c, agrmt);
                for(pse__Resource_Request__c resReq : agrmt.Bid_History_Resource_Requests__r) {
                    if(!initialBidIdToSubGroupResRequestsMap.containsKey(resReq.Bid_History__c)) {
                        initialBidIdToSubGroupResRequestsMap.put(resReq.Bid_History__c, new Map<String, pse__Resource_Request__c>());
                        initialBidIdToBidDefenseSubGroupResRequestsMap.put(resReq.Bid_History__c, new Map<String, List<pse__Resource_Request__c>>());
                    }
                    if(resReq.Is_Bid_Defense__c && resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL && (resReq.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED && resReq.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)) {
                        initialBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(CON_OWF.RES_REQ_TYPE_TSL_BID_Defence, resReq);
                    }
                    else if(resReq.Is_Bid_Defense__c && resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_MEDICAL && (resReq.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED && resReq.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)) {
                        initialBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(CON_OWF.RES_REQ_TYPE_MEDICAL_MSL_BID_Defence, resReq);
                    }
                    else if(resReq.Is_Bid_Defense__c && resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_LCS_BID_Defence && (resReq.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED && resReq.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)) {
                        initialBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(CON_OWF.RES_REQ_TYPE_LCS_BID_Defence, resReq);
                    }
                    else if(resReq.Is_Bid_Defense__c && resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_DESIGN_ANALYTICS && (resReq.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED && resReq.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)) {
                        initialBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(CON_OWF.RES_REQ_TYPE_DESIGN_ANALYTICS_BID_Defence, resReq);
                    }
                    else if(resReq.Is_Bid_Defense__c && resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE && (resReq.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED && resReq.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)) {
                        initialBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE_BID_Defence, resReq);
                    }
                    else if(resReq.Is_Bid_Defense__c && resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_CMSVC && (resReq.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED && resReq.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)) {
                        initialBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(CON_OWF.RES_REQ_TYPE_CMSVC_BID_Defence, resReq);
                    }
                    else if(resReq.Is_Bid_Defense__c && resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_ECD_COE && (resReq.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED && resReq.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)) {
                        initialBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(CON_OWF.RES_REQ_TYPE_ECD_COE_BID_Defence, resReq);
                    }
                    else if(resReq.Is_Bid_Defense__c && resReq.SubGroup__c == CON_OWF.CAGT_COE_SUBGROUP && (resReq.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED && resReq.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)) {
                        initialBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(CON_OWF.RES_REQ_TYPE_CAGT_COE_BID_Defence, resReq);
                    }
                    else if(resReq.Is_Bid_Defense__c && resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_PRD_COE && (resReq.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED && resReq.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)) {
                        initialBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(CON_OWF.RES_REQ_TYPE_PRD_COE_BID_DEFENCE, resReq);
                    }
                    else if(!resReq.Is_Bid_Defense__c) {
                        if((resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_MEDICAL || resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL) && initialBidIdToBidDefenseSubGroupResRequestsMap.get(resReq.Bid_History__c).containsKey(resReq.SubGroup__c)){
                            initialBidIdToBidDefenseSubGroupResRequestsMap.get(resReq.Bid_History__c).get(resReq.SubGroup__c).add(resReq);
                        }
                        else if(resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_MEDICAL || resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL){
                            initialBidIdToBidDefenseSubGroupResRequestsMap.get(resReq.Bid_History__c).put(resReq.SubGroup__c,new List<pse__Resource_Request__c>{resReq});
                        }
                        initialBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(resReq.SubGroup__c, resReq);
                    }
                }   
            }
            //IQVIAPSA-1852
            if(agrmt.Bid_History_Related_Opportunity__c != null && agrmt.Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c != null && agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c != null)
            {
                if(!agrmtToRRCancelSet.contains(agrmt))
                {
                    agrmtToRRCancelSet.add(agrmt);
                }
            } 
            
        }
        
        if(!oppIdAndAgreementsMap.IsEmpty() && !oppIdToInitialBidMap.IsEmpty()) {
            Map<Id, pse__Proj__c> initAgrmtIdToProjectMap = new Map<Id, pse__Proj__c>();
            if(initialAgrmtIdToProjectMap != NULL && !initialAgrmtIdToProjectMap.IsEmpty()) {
                initAgrmtIdToProjectMap = initialAgrmtIdToProjectMap;
            }else {
                Set<Id> agreementIdsSet = new Set<Id>();
                for(Bid_History__c agrmt : oppIdToInitialBidMap.values()) {
                    agreementIdsSet.add(agrmt.Id);
                }
                Set<String> projectFieldSet = new Set<String>{'Id', 'Bid_History__c', 'pse__Group__c', 'CurrencyIsoCode','pse__Start_Date__c'};
                    for(pse__Proj__c project : new SLT_Project(false,false).getProjectByBidHistoryID(agreementIdsSet, projectFieldSet).values()) {
                        if(project.Bid_History__c != null) {
                            initAgrmtIdToProjectMap.put(project.Bid_History__c, project);
                        }
                    }
            }
            if(!initAgrmtIdToProjectMap.IsEmpty()) {
                
                reqRequestsInsertList.addAll(validateAndCreateBDResRequests(oppIdToInitialBidMap, initAgrmtIdToProjectMap, initialBidIdToSubGroupResRequestsMap, initialBidIdToBidDefenseSubGroupResRequestsMap));
                for(Id oppId : oppIdAndAgreementsMap.keySet()) {
                    if(oppIdAndAgreementsMap.get(oppId).size() > 1) {
                        oppIdToInitialBidMap.remove(oppId);
                    }
                }
                if(!oppIdToInitialBidMap.IsEmpty()) {
                    reqRequestsInsertList.addAll(validateAndCreateResRequests(oppIdToInitialBidMap, initAgrmtIdToProjectMap, initialBidIdToSubGroupResRequestsMap));    
                }
            }
        }
        
        if(!oppIdAndAgreementsMap.IsEmpty() && oppIdToReBidsProjectsMap != NULL && !oppIdToReBidsProjectsMap.IsEmpty()) {
            reqRequestsInsertList.addAll(createReBidResourceRequests(oppIdToInitialBidMapToCloneReBid, oppIdToReBidsProjectsMap));    
        }
        if(agrmtToRRCancelSet.size() > 0)
        {
            updateAssignment(agrmtToRRCancelSet);
        } 
        return reqRequestsInsertList;
    }
    
    
    
    
    
    
    

    
    /**
* This is Utility method which is used to create Resource Requests on update of LineItemGroup, Opportunity & Agreement and on insert of Projects.
* For Rebids only
* @params  sObjectIdSet Set<Id>
* @params  agrCondition String
* @params    List<pse__Resource_Request__c>
*/
    public static List<pse__Resource_Request__c> processResRequestForClinicalReBids(Set<Id> sObjectIdSet, String agrCondition,List<pse__Resource_Request__c> preparedRRList) 
    {
        List<pse__Resource_Request__c> reqRequestsInsertList = new List<pse__Resource_Request__c>();
        Map<String,pse__Resource_Request__c> cancelledRROnInitialMap = new Map<String,pse__Resource_Request__c>();
        Map<Id, List<Bid_History__c>> oppIdAndAgreementsMap = new Map<Id, List<Bid_History__c>>();
        Map<Id, Bid_History__c> oppIdToRebidMap = new Map<Id, Bid_History__c>();
        Map<Id, Map<String, pse__Resource_Request__c>> reBidIdToSubGroupResRequestsMap = new Map<Id, Map<String, pse__Resource_Request__c>>();
        
        String resReqCondition = 'pse__Opportunity__c != NULL And SubGroup__c != NULL And Bid_History__c != NULL And Bid_History__r.Bid_Number__c >= 1';

        Set<String> agrFieldSet = new Set<String>{'Id', 'RFP_Ranking__c', 'Bid_History_Related_Opportunity__c',
            'Bid_History_Related_Opportunity__r.Phase_P__c', 'Bid_History_Related_Opportunity__r.Line_of_Business__c',
            'Bid_History_Related_Opportunity__r.Potential_Regions__c','Bid_History_Related_Opportunity__r.InterventionType__c','Win_Probability__c','Opportunity_Type__c',
            'Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c', 'Bid_History_Related_Opportunity__r.Bid_Defense_Date__c','Is_there_a_Client_Bid_Grid__c',
            'Bid_History_Related_Opportunity__r.Amount','RecordTypeId','Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c','Grid_Ranking_Level__c',
            'Bid_Due_Date__c', 'Requested_Services__c', 'Targeted_Countries__c', 'Budget_Deliverable__c', 'Bid_Number__c', 'Bid_Due_Date__c', 'CurrencyIsoCode','Bid_History_Related_Opportunity__r.Rare_Disease__c','Bid_History_Related_Opportunity__r.Population_Age_Group__c',
            'Bid_History_Related_Opportunity__r.Identified_Business__c','Additional_Services_Requested__c','Estimated_Fees__c','Bid_History_Related_Opportunity__r.pse__Parent_Opportunity__c','Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c','Bid_History_Related_Opportunity__r.Global_project_unit__c'};
        Set<String> resReqFieldSet = new Set<String>{'Id','Bid_History__r.RecordTypeId', 'pse__Opportunity__c', 'Bid_History__c', 'Is_Bid_Defense__c', 'pse__Project__c', 'SubGroup__c', 'Potential_Regions__c', 'pse__Start_Date__c', 'pse__End_Date__c','pse__Status__c','pse__Assignment__c','pse__Assignment__r.pse__Status__c', 'CurrencyIsoCode', 'pse__Staffer_Resource__c'}; 
        Map<Id, Bid_History__c> agreementByIdMap = new SLT_Bid_History(false,false).getAgreementAndResReqsByOppId(sObjectIdSet, agrFieldSet, resReqFieldSet, agrCondition, resReqCondition);
        
        for(Bid_History__c agrmt : agreementByIdMap.values()) {
            if(!oppIdAndAgreementsMap.containsKey(agrmt.Bid_History_Related_Opportunity__c)) {
                oppIdAndAgreementsMap.put(agrmt.Bid_History_Related_Opportunity__c, new List<Bid_History__c>());
            }
            oppIdAndAgreementsMap.get(agrmt.Bid_History_Related_Opportunity__c).add(agrmt);
            if(agrmt.Bid_Number__c == 1)
            {
                // system.assert(false,agrmt.Bid_History_Resource_Requests__r.size());
                if(agrmt.Bid_History_Resource_Requests__r.size() > 0)
                {
                    for(pse__Resource_Request__c resReq : agrmt.Bid_History_Resource_Requests__r) {
                        if((resReq.pse__Status__c == CON_OWF.OWF_STATUS_CANCELLED && resReq.SubGroup__c != CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD) || resReq.pse__Status__c == CON_OWF.OWF_STATUS_CLOSED){
                            cancelledRROnInitialMap.put(resReq.SubGroup__c, resReq); 
                        }
                        //system.debug('cancelledRROnInitialMap' + cancelledRROnInitialMap.keySet());	
                    }
                }
            }
            if(agrmt.Bid_Number__c >1 ) {
                oppIdToRebidMap.put(agrmt.Bid_History_Related_Opportunity__c, agrmt);
                
                if(agrmt.Bid_History_Resource_Requests__r.size() == 0 && !reBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id)) {
                    reBidIdToSubGroupResRequestsMap.put(agrmt.Id, new Map<String, pse__Resource_Request__c>());
                }
                
                for(pse__Resource_Request__c resReq : agrmt.Bid_History_Resource_Requests__r) {
                    if(!reBidIdToSubGroupResRequestsMap.containsKey(resReq.Bid_History__c)) {
                        reBidIdToSubGroupResRequestsMap.put(resReq.Bid_History__c, new Map<String, pse__Resource_Request__c>());
                    }
                    if(resReq.Is_Bid_Defense__c && resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL && (resReq.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED && resReq.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)) {
                        reBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(CON_OWF.RES_REQ_TYPE_TSL_BID_Defence, resReq);
                    }
                    else if(resReq.Is_Bid_Defense__c && resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_MEDICAL && (resReq.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED && resReq.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)) {
                        reBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(CON_OWF.RES_REQ_TYPE_MEDICAL_MSL_BID_Defence, resReq);
                    }
                    else if(!resReq.Is_Bid_Defense__c) {
                        reBidIdToSubGroupResRequestsMap.get(resReq.Bid_History__c).put(resReq.SubGroup__c, resReq);    
                    }
                }
                if(cancelledRROnInitialMap.size()>0)
                {
                    reBidIdToSubGroupResRequestsMap.get(agrmt.Id).putAll(cancelledRROnInitialMap);
                    //system.debug('reBidIdToSubGroupResRequestsMap' + reBidIdToSubGroupResRequestsMap.get(agrmt.Id).keySet());
                }
            }
        }
        
        for(pse__Resource_Request__c rrInstance: preparedRRList)
        {
            if(reBidIdToSubGroupResRequestsMap.containsKey(rrInstance.Bid_History__c) && 
               !reBidIdToSubGroupResRequestsMap.get(rrInstance.Bid_History__c).containsKey(rrInstance.SubGroup__c)
              )
            {
                reBidIdToSubGroupResRequestsMap.get(rrInstance.Bid_History__c).put(rrInstance.SubGroup__c, rrInstance);
            }
        }
        
        if(!oppIdAndAgreementsMap.IsEmpty() && !oppIdToRebidMap.IsEmpty()) {
            Map<Id, pse__Proj__c> reBidIdToProjectMap = new Map<Id, pse__Proj__c>();
            if(reBidIdToProjectMap != NULL && !reBidIdToProjectMap.IsEmpty()) {
                reBidIdToProjectMap = reBidIdToProjectMap;
            }else {
                Set<Id> agreementIdsSet = new Set<Id>();
                for(Bid_History__c agrmt : oppIdToRebidMap.values()) {
                    agreementIdsSet.add(agrmt.Id);
                }
                Set<String> projectFieldSet = new Set<String>{'Id', 'Bid_History__c', 'pse__Group__c', 'CurrencyIsoCode','pse__Start_Date__c'};
                    for(pse__Proj__c project : new SLT_Project(false,false).getProjectByBidHistoryID(agreementIdsSet, projectFieldSet).values()) {
                        if(project.Bid_History__c != null) {
                            reBidIdToProjectMap.put(project.Bid_History__c, project);
                        }
                    }
            }
            if(!oppIdAndAgreementsMap.IsEmpty() && !reBidIdToProjectMap.IsEmpty()) {
                reqRequestsInsertList.addAll(validateAndCreateResRequests(oppIdToRebidMap, reBidIdToProjectMap, reBidIdToSubGroupResRequestsMap));
            }
        }
        return reqRequestsInsertList;
    }    
    
    
    
    /** This method updates assignment of bid defence to cancelled if related opportunity does not meet criteria
* 
* 
*/
    private static void updateAssignment(Set<Bid_History__c> agrSet){
        Set<id> assignmentIdSet = new Set<id>();
        Map<Id, pse__Assignment__c> assignmentMap = new Map<Id, pse__Assignment__c>();
        for(Bid_History__c agrmt : agrSet)
        {    
            if(agrmt.Bid_History_Resource_Requests__r.size() > 0) 
            {
                for(pse__Resource_Request__c resReq : agrmt.Bid_History_Resource_Requests__r) {
                    if(resReq.Is_Bid_Defense__c && !assignmentIdSet.contains(resReq.pse__Assignment__c))
                    {
                        assignmentIdSet.add(resReq.pse__Assignment__c);
                    }
                }
            }
        }
        SLT_Assignment sltAssignment = new SLT_Assignment(false,false);
        String condition = 'Id in :sObjectIdset and Lookup_Opportunity_Name__r.QI_Invited_to_Present__c = \'No\'';
        Set<String> assignmentFieldSet = new Set<String>{'Id','pse__Status__c','pse__Start_Date__c','Cancellation_Date__c','Lookup_Opportunity_Name__r.QI_Invited_to_Present__c',
            'Lookup_Opportunity_Name__r.Bid_Defense_Date__c','pse__Resource_Request__c'};
                assignmentMap = sltAssignment.selectAssignmentsByIdSet(assignmentIdSet,condition,assignmentFieldSet);
        for(pse__Assignment__c assignment : assignmentMap.values())
        {
            //IQVIAPSA-1852
            if(assignment.Lookup_Opportunity_Name__r.QI_Invited_to_Present__c == 'No')
            {
                if(assignment.pse__Start_Date__c > Date.today() && assignment.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)
                {
                    assignment.pse__Status__c = CON_OWF.OWF_STATUS_CANCELLED;
                    UTL_OWF.isAssignmentStatusUpdateAsCancelledBySystem = true;
                    assignment.Cancellation_Date__c = Date.today();
                }
                else if(assignment.pse__Start_Date__c <= Date.today() && assignment.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED)
                {
                    assignment.pse__Status__c = CON_OWF.OWF_STATUS_CLOSED;
                    assignment.Original_Resource_Request__c = assignment.pse__Resource_Request__c;
                }
            }
            /*else if(assignment.Lookup_Opportunity_Name__r.QI_Invited_to_Present__c == 'No')
            {
                if(assignment.pse__Start_Date__c > Date.today() && assignment.pse__Status__c != CON_OWF.OWF_STATUS_CLOSED)
                {
                    assignment.pse__Status__c = CON_OWF.OWF_STATUS_CANCELLED;
                    UTL_OWF.isAssignmentStatusUpdateAsCancelledBySystem = true;
                    assignment.Cancellation_Date__c = Date.today();
                }
                else if(assignment.pse__Start_Date__c <= Date.today()  && assignment.pse__Status__c != CON_OWF.OWF_STATUS_CANCELLED)
                {
                    assignment.pse__Status__c = CON_OWF.OWF_STATUS_CLOSED;
                    assignment.Original_Resource_Request__c = assignment.pse__Resource_Request__c;
                }
            }
            else if (assignment.Lookup_Opportunity_Name__r.QI_Invited_to_Present__c == 'Not sure' 
                     && assignment.Lookup_Opportunity_Name__r.Bid_Defense_Date__c == null)
            {
                if(assignment.pse__Start_Date__c <= Date.today() && 
                   assignment.pse__Status__c == CON_OWF.OWF_STATUS_ACCEPTED && CON_OWF.isUpdatedViaPresentationDate)
                {
                    assignment.pse__Status__c = CON_OWF.OWF_STATUS_CLOSED;
                    assignment.Original_Resource_Request__c = assignment.pse__Resource_Request__c;
                }
            }*/
            //IQVIAPSA-1852 
        }
        if(assignmentMap.size() > 0)
        {
            update assignmentMap.values();
        }
    }
    
    
    private static List<pse__Resource_Request__c> validateAndCreateBDResRequests(Map<Id, Bid_History__c> oppIdToInitialBidMap, Map<Id, pse__Proj__c> initAgrmtIdToProjectMap, Map<Id, Map<String, pse__Resource_Request__c>> initialBidIdToSubGroupResRequestsMap,  Map<Id, Map<String, List<pse__Resource_Request__c>>> initialBidIdToBidDefenseSubGroupResRequestsMap)
    {
        List<pse__Resource_Request__c> clinicalBidResourceRequestsInsertList = new List<pse__Resource_Request__c>(); 
        for(Bid_History__c agrmt : oppIdToInitialBidMap.values())
        {
            //Validating for 'Bid Defence For TSL / MSL / Biosimilar-COE/CMSVC/ ECD-COE/ IQB Strategy Lead / CAGT-COE' Resource Request
            if(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id)) {

                
                if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c) 
                   && (agrmt.Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c == 'Yes' || agrmt.Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c == 'Not Sure') 
                   && agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c != NULL && agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c > system.today() ) {
                       
                       if(initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE)
                          && (!initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE_BID_Defence) || (initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE_BID_Defence).pse__Assignment__c != null && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE_BID_Defence).pse__Assignment__r.pse__Status__c == 'Completed'
                                                                                                                                                   && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE_BID_Defence).pse__End_Date__c < agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c ))
                          && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE).pse__Assignment__c != null
                          && (initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE).pse__Assignment__r.pse__Status__c == 'Accepted' || initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE).pse__Assignment__r.pse__Status__c == 'Completed')){
                           clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE_BID_Defence));
                       }
                       if(initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_CMSVC)
                          && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_CMSVC_BID_Defence)
                          && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_CMSVC).pse__Assignment__c != null
                          && (initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_CMSVC).pse__Assignment__r.pse__Status__c == 'Accepted' || initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_CMSVC).pse__Assignment__r.pse__Status__c == 'Completed')){
                           clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_CMSVC_BID_Defence));
                       }
                       if(initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_ECD_COE)
                          && (!initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_ECD_COE_BID_Defence) || (initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_ECD_COE_BID_Defence).pse__Assignment__c != null && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_ECD_COE_BID_Defence).pse__Assignment__r.pse__Status__c == 'Completed'
                                                                                                                                           && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_ECD_COE_BID_Defence).pse__End_Date__c < agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c))
                          && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_ECD_COE).pse__Assignment__c != null
                          && (initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_ECD_COE).pse__Assignment__r.pse__Status__c == 'Accepted' || initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_ECD_COE).pse__Assignment__r.pse__Status__c == 'Completed')){
                           clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_ECD_COE_BID_Defence));
                       }
                       if(initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.CAGT_COE_SUBGROUP)
                          && (!initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_CAGT_COE_BID_Defence) || (initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_CAGT_COE_BID_Defence).pse__Assignment__c != null && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_CAGT_COE_BID_Defence).pse__Assignment__r.pse__Status__c == 'Completed'
                                                                                                                                            && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_CAGT_COE_BID_Defence).pse__End_Date__c < agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c))
                          && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.CAGT_COE_SUBGROUP).pse__Assignment__c != null
                          && (initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.CAGT_COE_SUBGROUP).pse__Assignment__r.pse__Status__c == 'Accepted' || initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.CAGT_COE_SUBGROUP).pse__Assignment__r.pse__Status__c == 'Completed')){
                           clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_CAGT_COE_BID_Defence));
                       }
                       if(initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_PRD_COE)
                          && (!initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_PRD_COE_BID_DEFENCE) || (initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_PRD_COE_BID_DEFENCE).pse__Assignment__c != null && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_PRD_COE_BID_DEFENCE).pse__Assignment__r.pse__Status__c == 'Completed'
                                                                                                                                            && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_PRD_COE_BID_DEFENCE).pse__End_Date__c < agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c))
                          && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_PRD_COE).pse__Assignment__c != null
                          && (initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_PRD_COE).pse__Assignment__r.pse__Status__c == 'Accepted' || initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_PRD_COE).pse__Assignment__r.pse__Status__c == 'Completed')){
                           clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_PRD_COE_BID_DEFENCE));
                       }
                   }
            }
            
            
            //Validatin 'LCS Bid Defence' sub group resource request IQVIAPSA-1318
            if(!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                                                                               && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_LCS_BID_Defence))) {
                                                                                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                                                                                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Safety & Med Info') &&
                                                                                      (agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == Null 
                                                                                       || (agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c != Null
                                                                                           && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c =='No' ))
                                                                                      && (agrmt.Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c!=Null && agrmt.Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c == 'Yes')
                                                                                      && (agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c!=Null &&agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c>=System.today())){
                                                                                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_LCS_BID_Defence));                                                                               
                                                                                      }
                                                                               } 
            if(initialBidIdToBidDefenseSubGroupResRequestsMap.containsKey(agrmt.Id) && (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c) 
                                                                                        && (agrmt.Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c == CON_OWF.OWF_YES || agrmt.Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c == CON_OWF.OWF_NOT_SURE) 
                                                                                        && agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c != NULL && agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c > system.today() )) {
                                                                                            if(initialBidIdToBidDefenseSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_TSL)
                                                                                               && (!initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_TSL_BID_Defence) || (initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_TSL_BID_Defence).pse__Assignment__c != null && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_TSL_BID_Defence).pse__Assignment__r.pse__Status__c == 'Completed'
                                                                                                                                                                                                            && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_TSL_BID_Defence).pse__End_Date__c < agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c))){
                                                                                                for(pse__Resource_Request__c resRequest:initialBidIdToBidDefenseSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_TSL)) {
                                                                                                    if(resRequest.pse__Assignment__c != null && (resRequest.pse__Assignment__r.pse__Status__c == CON_OWF.OWF_STATUS_ACCEPTED || resRequest.pse__Assignment__r.pse__Status__c == CON_OWF.OWF_STATUS_COMPLETED)){
                                                                                                        clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_TSL_BID_Defence));                             
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                            if(initialBidIdToBidDefenseSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_MEDICAL)
                                                                                               && (!initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_MEDICAL_MSL_BID_Defence) || (initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_MEDICAL_MSL_BID_Defence).pse__Assignment__c != null && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_MEDICAL_MSL_BID_Defence).pse__Assignment__r.pse__Status__c == 'Completed'
                                                                                                                                                                                                                    && initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_MEDICAL_MSL_BID_Defence).pse__End_Date__c < agrmt.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c))){
                                                                                                for(pse__Resource_Request__c resRequest:initialBidIdToBidDefenseSubGroupResRequestsMap.get(agrmt.Id).get(CON_OWF.RES_REQ_TYPE_MEDICAL)) {
                                                                                                    if(resRequest.pse__Assignment__c != null && (resRequest.pse__Assignment__r.pse__Status__c == CON_OWF.OWF_STATUS_ACCEPTED || resRequest.pse__Assignment__r.pse__Status__c == CON_OWF.OWF_STATUS_COMPLETED)){
                                                                                                        clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_MEDICAL_MSL_BID_Defence));                             
                                                                                                    }
                                                                                                }   
                                                                                            }    
                                                                                        }
        }
        return clinicalBidResourceRequestsInsertList;
    }
    
   
    
    /**
* This method is used to valdiate criteria and create Clinical Bid record type Resource_Requests for Agreements having Bid_Number = 1
* @params    oppIdToInitialBidMap Map<Id, Bid_History__c>
* @params  initAgrmtIdToProjectMap Map<Id, pse__Proj__c>
* @params    initialBidIdToSubGroupResRequestsMap Map<Id, Map<String, pse__Resource_Request__c>>
* @params    List<pse__Resource_Request__c>
*/
    private static List<pse__Resource_Request__c> validateAndCreateResRequests(Map<Id, Bid_History__c> oppIdToInitialBidMap, Map<Id, pse__Proj__c> initAgrmtIdToProjectMap, Map<Id, Map<String, pse__Resource_Request__c>> initialBidIdToSubGroupResRequestsMap) {
        List<pse__Resource_Request__c> clinicalBidResourceRequestsInsertList = new List<pse__Resource_Request__c>();
        for(Bid_History__c agrmt : oppIdToInitialBidMap.values()) {
            List<String> requestedinternalServicesList = new List<String>();
            if(agrmt.Requested_Services__c != Null){
                requestedinternalServicesList.addAll(agrmt.Requested_Services__c.split(';'));
            }
            List<String> identifiedBusinessList = new List<String>();
            if(agrmt.Bid_History_Related_Opportunity__r.Identified_Business__c != null){
                identifiedBusinessList.addAll(agrmt.Bid_History_Related_Opportunity__r.Identified_Business__c.split(';'));
            }
            List<String> additionalServicesRequestList = new List<String>();
            if(agrmt.Additional_Services_Requested__c != null){
                additionalServicesRequestList.addAll(agrmt.Additional_Services_Requested__c.split(';'));
            }
            // count num of potential regions
            Integer numOfPotentialRegions = agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c == null? 0: agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.split(';').size();
            
            //Validating for 'GBO-Lead PD' Resource Request
            if(!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD))) {
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL 
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                          || (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes')
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES 
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_PATIENT_AND_DCT_SOLUTIONS) 
                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()) {
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD));
                      }
               }
            
            //Validating for 'GBO-Bid Grid' Resource Request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_GBO_BID_GRID)))
              && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY) {
                   if(agrmt.Is_there_a_Client_Bid_Grid__c == 'Yes'
                      &&(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' 
                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome'
                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                         || (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes')
                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Data Sciences' 
                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Safety & Med Info'
                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development')
                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()) {
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_GBO_BID_GRID));
                      }
               }
            
            //Validating for 'Biosimilars COE' Resource Request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE)))
              && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY) {
                    if(agrmt.Bid_History_Related_Opportunity__r.InterventionType__c  == 'Biosimilar' && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()) {
                        clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE));
                    }
            }
            
            //IQVIAPSA-2144 (Sub group CP&A-Global Feasibility Changes) == Start
            //Validating for 'Feasibility Analytics' Resource Request
            /*if(!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_Feasibility_Analytics))) {
                   if((requestedinternalServicesList.size() > 0) && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)) {
                      /* if((agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome' 
                           && (String.IsBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                               ||(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                                  && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Japan') 
                                  && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Asia Pacific'))) 
                           && String.IsNotBlank(agrmt.Budget_Deliverable__c) 
                           && (agrmt.Budget_Deliverable__c == 'Price per patient' || agrmt.Budget_Deliverable__c == 'Ballpark' || agrmt.Budget_Deliverable__c == 'Awardable')
                           && ((requestedinternalServicesList.contains('Clinical Monitoring') && requestedinternalServicesList.contains('Project Management')) || requestedinternalServicesList.contains('Feasibility'))
                           && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())
                          || (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Core Clinical' && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes' 
                              &&  (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                                   && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Asia Pacific')
                                   && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Global')
                                   && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Japan') 
                                   && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Latin America') 
                                   && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('USA/Canada') 
                                   && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Europe/Middle East/Africa EMEA'))
                              && String.IsNotBlank(agrmt.Budget_Deliverable__c) 
                              && (agrmt.Budget_Deliverable__c == 'Price per patient' || agrmt.Budget_Deliverable__c == 'Ballpark' || agrmt.Budget_Deliverable__c == 'Awardable')
                              && (requestedinternalServicesList.contains('Clinical Monitoring') && requestedinternalServicesList.contains('Project Management'))
                              && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())
                          || (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome' 
                              && (String.IsBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                                  || (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                                      && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Japan') 
                                      && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Asia Pacific'))) 
                              && requestedinternalServicesList.contains('LP Site Strategy'))) */
                       /*if(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Core Clinical' 
                          &&  (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Asia Pacific')
                               && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Global')
                               && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Japan') 
                               && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Latin America') 
                               && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('USA/Canada') 
                               && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Europe/Middle East/Africa EMEA'))
                          && String.IsNotBlank(agrmt.Budget_Deliverable__c) 
                          && (agrmt.Budget_Deliverable__c == 'Price per patient' || agrmt.Budget_Deliverable__c == 'Ballpark' || agrmt.Budget_Deliverable__c == 'Awardable')
                          && ((requestedinternalServicesList.contains('Clinical Monitoring') && requestedinternalServicesList.contains('Project Management')) || requestedinternalServicesList.contains('Feasibility'))
                          && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())
                       {
                           clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_Feasibility_Analytics));
                       }
                   }
               }*/
            //IQVIAPSA-2144 (Sub group CP&A-Global Feasibility Changes) == stop
            
            
            //Validating for 'TSL' Resource Request

            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_TSL)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if((requestedinternalServicesList.size() > 0) && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                      && ((requestedinternalServicesList.contains('Clinical Monitoring')  && requestedinternalServicesList.contains('Project Management')) 
                          || (requestedinternalServicesList.contains('ECD - Clinical Monitoring') && requestedinternalServicesList.contains('ECD - Clinical Project Manager')) 
                          || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_FULL_SERVICE_FEASIBILITY) || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_PROJECT_MANAGEMENT))
                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()) {
                          if(((agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' 
                               && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'No'
                               && (String.IsBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) || 
                                   (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                                    && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != 'Japan' 
                                    && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != 'Asia Pacific')) 
                               && agrmt.Bid_History_Related_Opportunity__r.Phase_P__c != CON_OWF.OPPORTUNITY_PHASE_4)
                              || (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'
                                  && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'No'
                                  && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c == 'Asia Pacific'
                                  && agrmt.Bid_History_Related_Opportunity__r.InterventionType__c != 'Device')) 
                             || (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' 
                                && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes'
                                && (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c)
                                    && (numOfPotentialRegions > 1 || (numOfPotentialRegions == 1 && !(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c == CON_OWF.POTENTIAL_REGION_JAPAN))))
                                && (String.IsBlank(agrmt.Bid_History_Related_Opportunity__r.Global_project_unit__c) 
                                     || !(agrmt.Bid_History_Related_Opportunity__r.Global_project_unit__c.contains(CON_OWF.OPPORTUNITY_GLOBAL_PROJECT_UNIT_MEDTECH))))
                             ||(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c ==  'Early Clinical Development' 
                                && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != 'Japan' 
                                && requestedinternalServicesList.contains('ECD - Clinical Monitoring') && requestedinternalServicesList.contains('ECD - Clinical Project Manager'))){
                                    clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_TSL));
                                }
                      }
               }
            
            //Validatiing for 'CMSVC' Resource Request
            
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_CMSVC))) 
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY)
            {
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                      && agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'
                       && (requestedinternalServicesList.size() > 0)
                      && requestedinternalServicesList.contains ('Clinical Monitoring')
                      && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'No'
                      && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c == 'Global'
                      && agrmt.Bid_Due_Date__c >= system.today()) 
                       {
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_CMSVC));
                          
                      }   
               }
            
            //IQVIAPSA - 4433 Validating for 'DSB-DCT'&& IQVIAPSA--5191 validating for 'DSB-RNPS' Resource Request -- Start
            
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_DCT)
                   )) && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY) {
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' 
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                          ||(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes'))
                      &&(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c))
                      &&(agrmt.Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c == 'Yes Fully Virtual'
                        ||agrmt.Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c == 'Yes Hybrid')
                      && agrmt.Bid_Due_Date__c >= system.today())
                   {
                       clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_DCT));
                     
                  }    
               }
             // IQVIAPSA - 4433  --End
            //IQVIAPSA-5191 validating for 'DSB-RNPS' Resource Request -- Start
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id)  && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_RNPS)
                  )) && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY) {
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' 
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                          ||(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes'))
                      &&(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c))
                      &&(agrmt.Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c == 'Yes Fully Virtual'
                        ||agrmt.Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c == 'Yes Hybrid'||requestedinternalServicesList.contains('RNPS'))
                      && agrmt.Bid_Due_Date__c >= system.today())
                   {
                       clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_RNPS));
                   }    
               }
           // IQVIAPSA - 5191  --End
            
            //Validating for 'Japan' Resource Request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_JAPAN)))
              && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if(((String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                        && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c == 'Japan') || (String.IsNotBlank(agrmt.Targeted_Countries__c) && agrmt.Targeted_Countries__c == 'JP'))
                      && (requestedinternalServicesList.size() > 0) && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                      && requestedinternalServicesList.contains('Clinical Monitoring') && requestedinternalServicesList.contains('Project Management')
                      && agrmt.Bid_Due_Date__c != NULL
                      && agrmt.Bid_Due_Date__c >= system.today() 
                      && agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' 
                      && agrmt.Bid_History_Related_Opportunity__r.Phase_P__c != CON_OWF.OPPORTUNITY_PHASE_4) {
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_JAPAN));    
                      }    
               }
             //Validating for 'Analytics Strategy Lead 'convert into Therapeutic Analytics Lead Resource Request IQVIAPSA-5338
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) &&
                   (!initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_THERAPEUTIC_ANALYTICS_LEAD ))))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                       if((requestedinternalServicesList.size() > 0)
                          && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                          && agrmt.Bid_Due_Date__c != NULL
                          && agrmt.Bid_Due_Date__c >= system.today()
                          && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Regulatory & Drug Development Solutions') 
                          && ((requestedinternalServicesList.contains('Project Management')
                               && requestedinternalServicesList.contains('Clinical Monitoring'))|| 
                              requestedinternalServicesList.contains('ADSC Standalone: Feasibility, Outreach, Site Insights')
                              || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_PROJECT_MANAGEMENT)
                              || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_FULL_SERVICE_FEASIBILITY))
                          && (agrmt.RFP_Ranking__c == '3' || agrmt.RFP_Ranking__c =='4' || agrmt.RFP_Ranking__c =='5' )){
                              clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_THERAPEUTIC_ANALYTICS_LEAD ));
                          }
                   }
            
            //Validating for Global Analytics subGroup Resource Request IQVIAPSA-5911
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) &&
                   (!initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS ))))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                       if((requestedinternalServicesList.size() > 0)
                          && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                          && agrmt.Bid_Due_Date__c != NULL
                          && agrmt.Bid_Due_Date__c >= system.today()
                          && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Regulatory & Drug Development Solutions') 
                          && ((requestedinternalServicesList.contains('Project Management')
                               && requestedinternalServicesList.contains('Clinical Monitoring'))
                              || requestedinternalServicesList.contains('ADSC Standalone: Feasibility, Outreach, Site Insights')
                              || requestedinternalServicesList.contains('IQB Project Management')
                              || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_FULL_SERVICE_FEASIBILITY)) 
                          && !((numOfPotentialRegions == 2 && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains(CON_OWF.POTENTIAL_REGION_ASIA_PACIFIC) && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains(CON_OWF.POTENTIAL_REGION_JAPAN))
                          || ((numOfPotentialRegions == 1) && (agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c == CON_OWF.POTENTIAL_REGION_ASIA_PACIFIC || agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c == CON_OWF.POTENTIAL_REGION_JAPAN)))
                          && (agrmt.RFP_Ranking__c == '3' || agrmt.RFP_Ranking__c =='4' || agrmt.RFP_Ranking__c =='5' )){
                              clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS));
                          }
                   }
            //Validating for DSB-DDRS Resource Request IQVIAPSA-9993
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id)
               && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_DDRS))) 
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY) {
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                       && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RDDS 
                       || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)){
                           if((requestedinternalServicesList.size() > 0) && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_RADDS_DDPRR))
                           && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                               clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_DDRS));
                          } 
                  }							  	                         
            }
            //Validating for Feasibility Analytics Updated  Resource Request IQVIAPSA-5338
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) &&
                   (!initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_Feasibility_Analytics))))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                       if((requestedinternalServicesList.size() > 0)
                          && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                          && agrmt.bid_Number__c==1
                          && agrmt.Bid_Due_Date__c != NULL
                          && agrmt.Bid_Due_Date__c >= system.today()
                          && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome'
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP) 
                          && ((requestedinternalServicesList.contains('Project Management')
                               && requestedinternalServicesList.contains('Clinical Monitoring')) ||  
                              requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_FULL_SERVICE_FEASIBILITY)|| 
                              requestedinternalServicesList.contains('IQB Project Management')|| 
                              requestedinternalServicesList.contains('LP Site Strategy'))
                          && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Asia Pacific') 
                          && (agrmt.RFP_Ranking__c == '3' || agrmt.RFP_Ranking__c =='4' || agrmt.RFP_Ranking__c =='5' )){
                              clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_Feasibility_Analytics));
                          }
                   }
            //Validating for ' Site Analytics'  Resource Request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) &&
                   ( !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_Site_Analytics))))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                       if((requestedinternalServicesList.size() > 0)
                          && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                          && agrmt.Bid_Due_Date__c != NULL
                          && agrmt.Bid_Due_Date__c >= system.today()
                          && agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' 
                          && ((requestedinternalServicesList.contains('Project Management')
                          && requestedinternalServicesList.contains('Clinical Monitoring')) 
                          || requestedinternalServicesList.contains('IQB Project Management'))
                          && (agrmt.RFP_Ranking__c == '3' || agrmt.RFP_Ranking__c =='4' || agrmt.RFP_Ranking__c =='5' )){
                              clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_Site_Analytics));
                          }
                   }
            /*if(!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && (!initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_THERAPEUTIC_ANALYTICS_LEAD ) || !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_CA_S) || !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_Site_Analytics)))) {
                   if((requestedinternalServicesList.size() > 0)
                      && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) && agrmt.Bid_Due_Date__c != NULL
                      && agrmt.Bid_Due_Date__c >= system.today()) {
                          if((agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome' 
                              && requestedinternalServicesList.contains('Clinical Monitoring') && requestedinternalServicesList.contains('Project Management')) 
                             || (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome' && requestedinternalServicesList.contains('LP Site Strategy'))) {
                                 
                                 if(!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_THERAPEUTIC_ANALYTICS_LEAD ))){
                                     clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_THERAPEUTIC_ANALYTICS_LEAD ));
                                 }
                                 
                                 if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_Site_Analytics)))
                                    && !(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome' && requestedinternalServicesList.contains('LP Site Strategy'))){
                                        clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_Site_Analytics));
                                    }
                             }
                          if(!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_Site_Analytics))) {
                              if (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Core Clinical' 
                      			  && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes'
                                  && (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                                      && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c == 'Asia Pacific' 
                                      && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != 'Global' 
                                      && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != 'Japan' 
                                      && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != 'Latin America' 
                                      && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != 'USA/Canada'
                                      && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != 'Europe/Middle East/Africa EMEA') 
                                  && (requestedinternalServicesList.contains('Clinical Monitoring')  && requestedinternalServicesList.contains('Project Management'))) {
                                      clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_Site_Analytics));    
                                  }
                          }
                          
                      }
               }*/
            
            //Validating for 'Medical Resource Request' Resource Request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_MEDICAL)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if((requestedinternalServicesList.size() > 0)
                      && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) && agrmt.Bid_Due_Date__c != NULL
                      && agrmt.Bid_Due_Date__c >= system.today()) {
                          if(((agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL 
                               || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT 
                               || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME 
                               || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP)
                              && (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                                  && !((numOfPotentialRegions == 2 && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains(CON_OWF.POTENTIAL_REGION_INDIA_ONLY) && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains(CON_OWF.POTENTIAL_REGION_JAPAN))
                                       || ((numOfPotentialRegions == 1) && (agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c == CON_OWF.POTENTIAL_REGION_INDIA_ONLY || agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c == CON_OWF.POTENTIAL_REGION_JAPAN))))
                              && (String.IsNotBlank(agrmt.Opportunity_Type__c) && agrmt.Opportunity_Type__c != CON_OWF.OPPORTUNITY_TYPE_PRICE_PER_Pt 
                                  && agrmt.Opportunity_Type__c != CON_OWF.OPPORTUNITY_TYPE_BTS_BALLPARK)
                              &&((requestedinternalServicesList.contains(CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING) 
                                  && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PROJECT_MANAGEMENT))  
                                 || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_FULL_SERVICE_FEASIBILITY) 
                                 || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_PROJECT_MANAGEMENT) 
                                 || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_LP_PROJECT_MANAGEMENT)))){
                                     clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_MEDICAL));
                                 }        
                         }
               }
            
            //Validating for 'SNP-Product Specialist Resource Request' Resource Request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_SNP_PRODUCT_SPECIALIST)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      &&(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL 
                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_PATIENT_AND_DCT_SOLUTIONS)
                      && (requestedinternalServicesList.size() > 0) 
                      && (requestedinternalServicesList.contains(CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING) 
                          || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PROJECT_MANAGEMENT)
                          || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PATIENT_RECRUITMENT)
                          || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_PROJECT_MANAGEMENT)
                          || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_LP_PROJECT_MANAGEMENT))
                      && (String.IsBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                          || !(numOfPotentialRegions == 1 && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains(CON_OWF.POTENTIAL_REGION_JAPAN)))
                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()) {
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_SNP_PRODUCT_SPECIALIST));    
                      }
               }
            
            //Validating for 'DSB-Clinical' Resource Request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'
                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development')
                      && agrmt.Bid_Due_Date__c != NULL 
                      && agrmt.Bid_Due_Date__c >= system.today()) {
                          if((String.IsBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                              || (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                                  && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != 'Japan')))
                          {
                              //System.debug(LoggingLevel.INFO, '******* DSB Clinical RR ADDED *************');
                              clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB));
                          }        
                      }
               }
            
            //Validating for 'CAGT-COE' Resource Request' Resource Request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id)
                || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.CAGT_COE_SUBGROUP)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if((String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.InterventionType__c) && agrmt.Bid_History_Related_Opportunity__r.InterventionType__c == 'Cell and Gene Therapy')
                       && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                       && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                           || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                           || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                           || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                       && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()
                       && (requestedinternalServicesList.size() > 0)
                       && ((requestedinternalServicesList.contains(CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING) 
                            && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PROJECT_MANAGEMENT))
                           || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_PROJECT_MANAGEMENT)
                           || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ECD_CLINICAL_PROJECT_MANAGER)
                           || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_LP_PROJECT_MANAGEMENT))
                     ){
                         clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.CAGT_COE_SUBGROUP));
                     }        
               }
            
            //Validatin 'DSB-CEVA' sub group resource request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_CEVA)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Safety & Med Info'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Data Sciences')
                      && (requestedinternalServicesList.size() > 0)
                      && (requestedinternalServicesList.contains('CEVA') 
                          || (requestedinternalServicesList.contains('Clinical Monitoring') && requestedinternalServicesList.contains('Project Management'))
                          || requestedinternalServicesList.contains('Biostatistical')
                          || requestedinternalServicesList.contains('Data Management')
                          || requestedinternalServicesList.contains('Pharmacovigilance LifeCycle Safety'))
                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_CEVA));                                                                               
                      }
               }
            
            //Validatin 'ECD-COE' sub group resource request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 	
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_ECD_COE)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if((String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'))
                      && (requestedinternalServicesList.size() > 0)
                      && (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c))
                      && (agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains(CON_OWF.POTENTIAL_REGION_GLOBAL)
                          || agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains(CON_OWF.POTENTIAL_REGION_USA_CANADA)
                          || agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains(CON_OWF.POTENTIAL_REGION_EMEA))
                      && ((requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ECD_CLINICAL_MONITORING) && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ECD_CLINICAL_PROJECT_MANAGER))
                          || (requestedinternalServicesList.contains(CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING) && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PROJECT_MANAGEMENT))
                          || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_PROJECT_MANAGEMENT))
                      && agrmt.Bid_History_Related_Opportunity__r.Phase_P__c == 'Phase 1'
                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_ECD_COE));                                                                               
                      }
               }
            
             //Validatin 'PRD-COE' sub group resource request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 	
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_PRD_COE)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome'
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                          ||(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes'))
                      && (agrmt.Bid_History_Related_Opportunity__r.Rare_Disease__c == true
                          || (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Population_Age_Group__c) &&
                              (agrmt.Bid_History_Related_Opportunity__r.Population_Age_Group__c.contains('Neonates - Newborn to 1 Month')
                              || agrmt.Bid_History_Related_Opportunity__r.Population_Age_Group__c.contains('Infants - 1 Month to 2 Years')
                              || agrmt.Bid_History_Related_Opportunity__r.Population_Age_Group__c.contains('Children - 2 Years to 12 Years')
                              || agrmt.Bid_History_Related_Opportunity__r.Population_Age_Group__c.contains('Adolescents - 12 Years to 16 Years')
                              || agrmt.Bid_History_Related_Opportunity__r.Population_Age_Group__c.contains('Preterm Infant born at <37 wks gestation'))))
                      && (requestedinternalServicesList.size() > 0)
                      && (agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != 'Japan')
                      && ((requestedinternalServicesList.contains('Clinical Monitoring') 
                           && requestedinternalServicesList.contains('Project Management')) 
                          || requestedinternalServicesList.contains('IQB Medical Monitoring') 
                          || requestedinternalServicesList.contains('LP Project Management'))
                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_PRD_COE));                                                                               
                      }
               }
            
                        
            
            //Validatin 'DSB-MW' sub group resource request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_MW)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Safety & Med Info'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Data Sciences')
                      && (requestedinternalServicesList.size() > 0)
                      && ((agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'No' && requestedinternalServicesList.contains('Medical Writing')) 
                      || (agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes' && requestedinternalServicesList.contains('IQB Medical Writing'))) 
                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_MW));                                                                               
                      }
               }
            
            //Validatin 'DSB-Bios' sub group resource request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_Bios)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Safety & Med Info'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Data Sciences')
                      && (requestedinternalServicesList.size() > 0)
                      && ((agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'No' && requestedinternalServicesList.contains('Biostatistical') )
                         || (agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes' && requestedinternalServicesList.contains('IQB Biostats') ))
                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_Bios));                                                                               
                      }
               }
            
            //Validatin 'DSB-DM' sub group resource request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_DM)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Safety & Med Info'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Data Sciences')
                      && (requestedinternalServicesList.size() > 0)
                      && ((agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'No' && requestedinternalServicesList.contains('Data Management') )
                         || (agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes' && requestedinternalServicesList.contains('IQB Ongoing DM') ))
                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_DM));                                                                               
                      }
               }
            
            //Validatin 'DSB-LCS' sub group resource request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_LCS)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Safety & Med Info'
                          ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Data Sciences')
                      && (requestedinternalServicesList.size() > 0)
                      && ((agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'No' && requestedinternalServicesList.contains('Pharmacovigilance LifeCycle Safety') )
                         || (agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes' && requestedinternalServicesList.contains('IQB Safety Processing') && requestedinternalServicesList.contains('IQB Safety Reporting')))
                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_LCS));                                                                               
                      }
               }
            
            //Validatin 'DSB-GSA' sub group resource request
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id)
               || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                   && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_GSA)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                       if((String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                           && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                           && (requestedinternalServicesList.size() > 0)
                           && ((agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'No' && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_GSA_REGULATORY) 
                                                                                                              || (requestedinternalServicesList.contains(CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING) && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PROJECT_MANAGEMENT)) 
                                                                                                              || (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_GSA_SITE_ID_START_UP)))))
                           && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())
                          || 
                          (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                           && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT)
                           && (requestedinternalServicesList.size() > 0)
                           && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_GSA_REGULATORY) 
                               || (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ECD_CLINICAL_MONITORING) && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ECD_CLINICAL_PROJECT_MANAGER)) 
                               || (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_GSA_SITE_ID_START_UP)))
                           && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())){
                               clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_GSA));                                                                               
                           }
                   }
            
            
            //Validatin 'LCS Product Specialist' sub group resource request IQVIAPSA-1318
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                                                                               && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_LCS_PRODUCT_SPECIALIST)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                                                                                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                                                                                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Safety & Med Info') &&
                                                                                      (agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == Null 
                                                                                       || (agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c != Null
                                                                                           && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c =='No' )
                                                                                       && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())){
                                                                                           clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_LCS_PRODUCT_SPECIALIST));                                                                               
                                                                                       }
                                                                               }
            
            //Validatin STS Lead
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                                                                               && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_STS_LEAD)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                                                                                   
                                                                                   if((String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                                                                                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome'
                                                                                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                                                                                         ||(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes')
                                                                                         ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                                                                                         ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical')) 
                                                                                      	 &&(requestedinternalServicesList.size() > 0 
                                                                                       		&&(requestedinternalServicesList.contains('Clinical Monitoring') 
                                                                                            &&requestedinternalServicesList.contains('Clinical Monitoring')
                                                                                            &&requestedinternalServicesList.contains('RBM - Central Monitoring') 
                                                                                           )||(requestedinternalServicesList.contains('ECD - Clinical Monitoring') 
                                                                                            || requestedinternalServicesList.contains('ECD - Project Management')
                                                                                            || requestedinternalServicesList.contains('IQB Project Management')
                                                                                            || requestedinternalServicesList.contains('IQB Site Management')
                                                                                            || requestedinternalServicesList.contains('LP Project Management')
                                                                                           ))
                                                                                      && agrmt.RFP_Ranking__c != NULL && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c)
                                                                                      && (agrmt.Estimated_Fees__c == 'Less than $1M'|| agrmt.Estimated_Fees__c == 'Less than $500k')
                                                                                      && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                                                                                           clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_STS_LEAD));                                                                               

                                                                                      }
                                                                               }
            //Validatin CTE Lead
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                                                                               && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_CTE_LEAD)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                                                                                  
                                                                                   if((String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                                                                                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome'
                                                                                         || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                                                                                         ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                                                                                         ||(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes')
                                                                                         ||agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical')) 
                                                                                      	 &&(requestedinternalServicesList.size() > 0 &&(requestedinternalServicesList.contains('CTE')))
                                                                                         && agrmt.RFP_Ranking__c != NULL && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c)
                                                                                      	 && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                                                                                           clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_CTE_LEAD));                                                                               

                                                                                      }
                                                                               }

            /*Validating for 'Medical Analytics' Resource Request
            if(!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
              || (initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
              && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_MEDICAL_ANALYTICS))){
                if((requestedinternalServicesList.size() > 0)
                    && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                    && agrmt.Bid_Due_Date__c != NULL
                    && agrmt.Bid_Due_Date__c >= system.today()){
                        if(((agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome') 
                        && requestedinternalServicesList.contains('Clinical Monitoring') && requestedinternalServicesList.contains('Project Management')) 
                        || (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome' && requestedinternalServicesList.contains('LP Site Strategy'))){
                            clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_MEDICAL_ANALYTICS));
                        }
                }
            }*/
            
 
            //Validation for CTS Lead
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_CTS_LEAD)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                    if(((String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                            && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Early Clinical Development'
                            || (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical' && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'Yes') 
                            || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Clinical'
                            || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome'
                            || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP)
                        && identifiedBusinessList.size() > 0 && identifiedBusinessList.contains('Cenduit'))
                            || (requestedinternalServicesList.size() > 0 && requestedinternalServicesList.contains('CTS'))
                            || (additionalServicesRequestList.size() > 0 && additionalServicesRequestList.contains('Drug Supply and Distribution')
                        && numOfPotentialRegions > 0 && agrmt.RFP_Ranking__c != null))
                        && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                            clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_CTS_LEAD));
                    }
            }
            
            //Validating for SSL Subgroup
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                   && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_SSL)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                       if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                          &&( agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == 'Outcome'
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP) 
                          && (String.IsBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                               ||(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                                  && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Japan') 
                                  && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains('Asia Pacific')))
                          && (requestedinternalServicesList.size()> 0 && 
                              (requestedinternalServicesList.contains('LP Site ID') || requestedinternalServicesList.contains('LP Site Strategy')
                              || requestedinternalServicesList.contains('LP Regulatory') || requestedinternalServicesList.contains('Patient Centered Endpoints (COA/PRO Consulting)')
                              || requestedinternalServicesList.contains('Patient Recruitment') || requestedinternalServicesList.contains('GSA Site ID/Start-up')))
                          && (agrmt.Bid_History_Related_Opportunity__r.Phase_P__c == 'Phase 3b' 
                              || agrmt.Bid_History_Related_Opportunity__r.Phase_P__c == 'Phase 4' 
                              || agrmt.Bid_History_Related_Opportunity__r.Phase_P__c == 'N/A')
                          && (agrmt.RFP_Ranking__c == '2' || agrmt.RFP_Ranking__c == '3' || agrmt.RFP_Ranking__c == '4' || agrmt.RFP_Ranking__c == '5')
                          && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == 'No'
                          && agrmt.Bid_Due_Date__c >= system.today() 
                         ){
                             clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_SSL));
                         }
                   }
            
            
            //Validating for DSB-ISS Subgroup
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                  && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_ISS)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                      if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                         && agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL 
                         && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES
                         && (requestedinternalServicesList.size() > 0 && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_ISSC)
                                                                          || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_SITE_CONTRACTS)))
                         && (agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())){
                             clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_ISS));
                         }
                  }
          //Validating for DSB-PM Subgroup
           if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                  && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_PM)))
              && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                      if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                         && agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL 
                         && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES
                         && (requestedinternalServicesList.size()> 0 && 
                             (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_PROJECT_MANAGEMENT)  ))
                         && (agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()))
                      {
                            clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_PM));
                        }
                  }  
            //Validating for IG-Lead Subgroup
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                  && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_IG_LEAD)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                      if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                         && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL ||
                             agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT ||
                             agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP ) 
                         && agrmt.RFP_Ranking__c != '1' && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                         && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_JAPAN
                         && requestedinternalServicesList.size()> 0
                         && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_INVESTIGATOR_GRANT_ESTIMATES)						 
                         && (agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()))
                      {
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_IG_LEAD));
                      }
                  } 
            //Validating for GBO Strategic Writer Subgroup
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                  && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_GBO_STRATEGIC_WRITER)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                      if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                         && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL ||
                             agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME 
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP ||
                             agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT ||
                             agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES ||
                             agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
                            ) 
                         && (((agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_NO || agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES)
                              && ((String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c)) 
                                  && (!agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains(CON_OWF.POTENTIAL_REGION_JAPAN) && !agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains(CON_OWF.POTENTIAL_REGION_ASIA_PACIFIC)))
                              && (agrmt.Opportunity_Type__c != null && (agrmt.Opportunity_Type__c == CON_OWF.OPPORTUNITY_TYPE_FULL_SERVICE_RFP || agrmt.Opportunity_Type__c == CON_OWF.OPPORTUNITY_TYPE_PROGRAM_OR_STRATEGIC_PARTERNERSHIP || agrmt.Opportunity_Type__c == CON_OWF.OPPORTUNITY_TYPE_FSP_SKILL))
                              && (agrmt.Estimated_Fees__c != null && agrmt.Estimated_Fees__c == CON_OWF.ESTIMATED_FEES_GREATER_THAN_50_M))
                             || 
                             ((agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_NO || agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES)
                              && (((String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c)) 
                                   && (agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c.contains(CON_OWF.POTENTIAL_REGION_ASIA_PACIFIC))))
                              && (agrmt.Estimated_Fees__c != null && agrmt.Estimated_Fees__c == CON_OWF.ESTIMATED_FEES_GREATER_THAN_10_M)
                              && agrmt.Win_Probability__c >= 50))
                         && (agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()))
                      {
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_GBO_STRATEGIC_WRITER));
                      }
                  }
                  
            //Validating for DSB-RADDS Subgroup
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                    && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_RADDS)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                        if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                        && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL
                            || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RDDS)
                        && (requestedinternalServicesList.size()> 0 
                             && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_RADDS_LCM_REGULATORY_OPERATION))
                        && (agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())){
                                clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_RADDS));
                        }
                    }
            
            //Validating for DSB-SPN Subgroup
            if(!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id)
               ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                  && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_SPN))){
                      if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                         && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL 
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_PATIENT_AND_DCT_SOLUTIONS)
                         && (requestedinternalServicesList.size()> 0 
                             && (requestedinternalServicesList.contains(CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING)
                                 || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PROJECT_MANAGEMENT)
                                 || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PATIENT_RECRUITMENT)
                                 || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_PROJECT_MANAGEMENT)
                                 || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_LP_PROJECT_MANAGEMENT)))
                         && (String.IsBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c)
                             || agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_JAPAN)
                         && (agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())){
                             clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_SPN));
                         }
                  }

            //Validating for DSB-CTE Subgroup
		    if(!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id)
                ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                    && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_CTE))){
                        if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                            && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL 
                            || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                            || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                            || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT)
                            &&(requestedinternalServicesList.size() > 0 &&(requestedinternalServicesList.contains('CTE')))
                            && agrmt.RFP_Ranking__c != NULL && String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c)
                            && agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today()){
                                clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_CTE));
            
                        }           
            }

            //Validating for MedTech Strategy Lead Subgroup           
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                  && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_MEDTECH_STRATEGY_LEAD)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                      if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                         && agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL
                         && ((requestedinternalServicesList.size()> 0
                              && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_MEDTECH_SOULTIONS))
                             || agrmt.Bid_History_Related_Opportunity__r.Global_project_unit__c.contains(CON_OWF.OPPORTUNITY_GLOBAL_PROJECT_UNIT_MEDTECH))
                         && (agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())){
                             clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_MEDTECH_STRATEGY_LEAD));
                         }
                  }
            //Validating for RADDS Product Specialist Subgroup
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                  && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_RADDS_PRODUCT_SPECIALIST)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                      if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                         && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RDDS)
                         && agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_NO
                         && (String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c)
                             && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_JAPAN)
                         && (requestedinternalServicesList.size()> 0
                            && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_RADDS_DDPRR))
                         && agrmt.Bid_Due_Date__c >= system.today()){
                                 clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_RADDS_PRODUCT_SPECIALIST));
                        }
                    }
            //Validating for ADSC Consulting Subgroup           
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                   && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_ADSC_CONSULTING)))){
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT)
                      && (requestedinternalServicesList.size()> 0 
                          && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ADSC_STANDALONE_FEASIBILITY_OUTREACH_SITE_INSITES)
                             || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ADSC_CONSULTING)))
                      && (agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())){
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_ADSC_CONSULTING));
                      }
               }
            
            //Validating for AIML Solutions Subgroup           
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                   && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_AIML_SOLUTIONS)))){
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                          || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT)
                      && (requestedinternalServicesList.size()> 0 
                          && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ADSC_STANDALONE_FEASIBILITY_OUTREACH_SITE_INSITES)
                             || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ADSC_AIML_SOLUTIONS)))
                      && (agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())){
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_AIML_SOLUTIONS));
                      }
               }
            //Validating for DSB PK/PD Subgroup           
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                  && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DSB_PK_PD)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                      if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                         && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.OPP_LINE_OF_BUSINESS_CONNECTED_DEVICES
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL_TECHNOLOGY
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_PATIENT_AND_DCT_SOLUTIONS
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RDDS
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OTHER)
                         && (requestedinternalServicesList.size()> 0 
                             && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PPS)
                                 || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PK_SUPPORT_FOR_IND)
                                 || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_POPULATION_PK_PD)
                                 || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PK_SUPPORT_FOR_NDA_ECTD)))
                         && (agrmt.Bid_Due_Date__c != NULL && agrmt.Bid_Due_Date__c >= system.today())){
                             clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_PK_PD));
                         }
                  }

            //Validating for MBR-LEAD Subgroup    
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
               ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                	&& !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_MBR_LEAD)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                      if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                         && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL
                        	 || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT 
                        	 || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
                        	 || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES
                        	 || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME 
                             || agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP )
                   		 && ((agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_NO 
                        	 && String.IsNotBlank(agrmt.Requested_Services__c) && agrmt.Requested_Services__c.contains(CON_OWF.REQ_SER_MEDICAL_AND_SCIENTIFIC)) 
                    	 || (agrmt.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES 
                        	 && String.IsNotBlank(agrmt.Requested_Services__c) && agrmt.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_MEDICAL_MONITORING)))		
                         && (agrmt.Bid_Due_Date__c >= system.today())){
                           	 clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_MBR_LEAD));
                    	 }
            }
            //Validating for Design Analytics Subgroup 
            //
            if((!initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id)     
                ||(initialBidIdToSubGroupResRequestsMap.containsKey(agrmt.Id) 
                   && !initialBidIdToSubGroupResRequestsMap.get(agrmt.Id).containsKey(CON_OWF.RES_REQ_TYPE_DESIGN_ANALYTICS)))
               && agrmt.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_INDIA_ONLY){
                   if(String.IsNotBlank(agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                      && (agrmt.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                      && (String.IsNotBlank(agrmt.Requested_Services__c) && ((agrmt.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ADSC_DESIGN_ANALYTICS_SELECT_ANALYTICS_FOR_PRE_AWARD)) 
                          || (agrmt.Requested_Services__c.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_ADSC_DESIGN_ANALYTICS_DIPA_EDSD_ETC))))
                      && (agrmt.RFP_Ranking__c == '3' || agrmt.RFP_Ranking__c == '4' || agrmt.RFP_Ranking__c == '5')
                      && (agrmt.Bid_Due_Date__c >= system.today())){
                          clinicalBidResourceRequestsInsertList.add(createResourceRequestByAgreement(agrmt, initAgrmtIdToProjectMap, CON_OWF.RES_REQ_TYPE_DESIGN_ANALYTICS));
                      }
               }
        }
        return clinicalBidResourceRequestsInsertList;
    }
    
        /**
* This method is used to create ReBid Clinical Bid type Resource_Requests for Agreements having Bid_Number > 1
* @params    oppIdToInitialBidMapToCloneReBid Map<Id, Bid_History__c>
* @params  oppIdToReBidsProjectsMap Map<Id, List<pse__Proj__c>>
* @params    List<pse__Resource_Request__c>
*/
    private static List<pse__Resource_Request__c> createReBidResourceRequests(Map<Id, Bid_History__c> oppIdToInitialBidMapToCloneReBid, Map<Id, List<pse__Proj__c>> oppIdToReBidsProjectsMap) {
        List<pse__Resource_Request__c> clonedClinicalBidResRequestsInsertList = new List<pse__Resource_Request__c>();
        for(Id oppId  : oppIdToReBidsProjectsMap.keySet()) {
            if(oppIdToInitialBidMapToCloneReBid.containsKey(oppId)) {
                for(pse__Proj__c project : oppIdToReBidsProjectsMap.get(oppId)) {
                    for(pse__Resource_Request__c resReq : oppIdToInitialBidMapToCloneReBid.get(oppId).Bid_History_Resource_Requests__r) {
                        if((!CON_OWF.REBID_NON_CLONABLE_SUBGROUP_SET.contains(resReq.SubGroup__c) && !(resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS && resReq.Regional_Analytics_Country__c != CON_OWF.RA_COUNTRY_TYPE_STRATEGIC_ANALYTICS) &&
                            (resReq.pse__Status__c == CON_OWF.OWF_STATUS_ASSIGNED || resReq.pse__Status__c == CON_OWF.OWF_STATUS_COMPLETED) && resReq.pse__Assignment__c != null && (resReq.pse__Assignment__r.pse__Status__c == CON_OWF.OWF_ASSIGNMENT_STATUS_ACCEPTED || resReq.pse__Assignment__r.pse__Status__c == CON_OWF.OWF_ASSIGNMENT_STATUS_COMPLETED) && !resReq.Is_Bid_Defense__c)
                           && (!((resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD || resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_BID_GRID || resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_Clinical_Coding) && resReq.Is_Created_Automatically__c == false))
                           && (!(resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_BID_GRID && oppIdToInitialBidMapToCloneReBid.get(oppId).Is_there_a_Client_Bid_Grid__c == 'Yes'))
                           && (!(CON_OWF.REBID_NON_CLONABLE_ANALYTICS_SET.contains(resReq.SubGroup__c) && oppIdToInitialBidMapToCloneReBid.get(oppId).Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL))
                           && ((resReq.SubGroup__c != CON_OWF.RES_REQ_ASL && resReq.SubGroup__c != CON_OWF.RES_REQ_TYPE_RW_AIM) ||(resReq.SubGroup__c == CON_OWF.RES_REQ_TYPE_RW_AIM && (oppIdToInitialBidMapToCloneReBid.get(oppId).Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                           || oppIdToInitialBidMapToCloneReBid.get(oppId).Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP)))){
                               clonedClinicalBidResRequestsInsertList.add(cloneReBidResourceRequest(project, resReq));
                           }
                    }
                }    
            }
        }
        return clonedClinicalBidResRequestsInsertList;
    }
    
    /**
* This method is used to create Resource Request record by Agreement
* @params    agreement Apttus__APTS_Agreement__c
* @params    initAgrmtIdToProjectMap Map<Id, pse__Proj__c>
* @params    subGroup String
* @params    pse__Resource_Request__c
*/
  /*  private static pse__Resource_Request__c createResourceRequestByAgreement(Apttus__APTS_Agreement__c agreement, Map<Id, pse__Proj__c> initAgrmtIdToProjectMap, String subGroup) {
        pse__Resource_Request__c resRequest = new pse__Resource_Request__c();
        resRequest.recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
        resRequest.pse__Opportunity__c = agreement.Apttus__Related_Opportunity__c;
        resRequest.Agreement__c = agreement.Id;
        if(initAgrmtIdToProjectMap.containsKey(agreement.Id)) {
            resRequest.pse__Project__c  = initAgrmtIdToProjectMap.get(agreement.Id).Id;
            resRequest.pse__Group__c = initAgrmtIdToProjectMap.get(agreement.Id).pse__Group__c;
        }
        resRequest.Potential_Regions__c = agreement.Apttus__Related_Opportunity__r.Potential_Regions__c;
        if(subGroup == CON_OWF.RES_REQ_TYPE_TSL_BID_Defence) {
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_TSL;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_MEDICAL_MSL_BID_Defence)
        {
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_MEDICAL;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_LCS_BID_Defence)
        {
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_LCS_BID_Defence;
        }
        else if(subGroup == 'CP&A-DIPA BID Defence')
        {
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_CPandA_DIPA ;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE_BID_Defence)
        {
            //System.debug('is bid defense');
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE ;
        }
        else {
            resRequest.SubGroup__c  = subGroup;
        }
        resRequest.pse__Start_Date__c = initAgrmtIdToProjectMap.get(agreement.Id).pse__Start_Date__c;
        resRequest.pse__End_Date__c = agreement.Bid_Due_Date__c;
        resRequest.pse__SOW_Hours__c = 0.01;
        resRequest.CurrencyIsoCode = agreement.CurrencyIsoCode;
        resRequest.Is_Created_Automatically_Initial_Bid__c = true;
        resRequest.Is_Created_Automatically__c = true;
        return resRequest;
    }
*/


    /**
* This method is used to create Resource Request record by Agreement
* @params    agreement Bid_History__c
* @params    initAgrmtIdToProjectMap Map<Id, pse__Proj__c>
* @params    subGroup String
* @params    pse__Resource_Request__c
*/
    @TestVisible
    private static pse__Resource_Request__c createResourceRequestByAgreement(Bid_History__c agreement, Map<Id, pse__Proj__c> initAgrmtIdToProjectMap, String subGroup) {
        pse__Resource_Request__c resRequest = new pse__Resource_Request__c();
        resRequest.recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
        resRequest.pse__Opportunity__c = agreement.Bid_History_Related_Opportunity__c;
        resRequest.Bid_History__c = agreement.Id;
        if(initAgrmtIdToProjectMap.containsKey(agreement.Id)) {
            resRequest.pse__Project__c  = initAgrmtIdToProjectMap.get(agreement.Id).Id;
            resRequest.pse__Group__c = initAgrmtIdToProjectMap.get(agreement.Id).pse__Group__c;
        }
        resRequest.Potential_Regions__c = agreement.Bid_History_Related_Opportunity__r.Potential_Regions__c;
        if(subGroup == CON_OWF.RES_REQ_TYPE_TSL_BID_Defence) {
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_TSL;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_MEDICAL_MSL_BID_Defence)
        {
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_MEDICAL;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_LCS_BID_Defence)
        {
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_LCS_BID_Defence;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_DESIGN_ANALYTICS_BID_Defence)
        {
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_DESIGN_ANALYTICS ;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE_BID_Defence)
        {
            //System.debug('is bid defense');
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_BIOSIMILAR_COE ;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_CMSVC_BID_Defence)
        {
            
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_CMSVC ;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_ECD_COE_BID_Defence)
        {
            
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_ECD_COE ;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_CAGT_COE_BID_Defence)
        {
            
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.CAGT_COE_SUBGROUP ;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_PRD_COE_BID_DEFENCE)
        {
            resRequest.Is_Bid_Defense__c  = true;
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_PRD_COE ;
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS)
        {
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS;
            resRequest.Regional_Analytics_Country__c = CON_OWF.RA_COUNTRY_TYPE_STRATEGIC_ANALYTICS;  
        }
        else if(subGroup == CON_OWF.RES_REQ_TYPE_IG_LEAD) 
        {
            resRequest.pse__End_Date__c =  UTL_OWF.subtractBusinessDays(agreement.Bid_Due_Date__c, 2);
            resRequest.SubGroup__c  = CON_OWF.RES_REQ_TYPE_IG_LEAD;
        }
        else {
            resRequest.SubGroup__c  = subGroup;
        }
        resRequest.pse__Start_Date__c = initAgrmtIdToProjectMap.get(agreement.Id).pse__Start_Date__c;
        if(subGroup != CON_OWF.RES_REQ_TYPE_IG_LEAD)
        {
            resRequest.pse__End_Date__c = agreement.Bid_Due_Date__c;
        }
        resRequest.pse__SOW_Hours__c = 0.01;
        resRequest.CurrencyIsoCode = agreement.CurrencyIsoCode;
        resRequest.Is_Created_Automatically_Initial_Bid__c = true;
        resRequest.Is_Created_Automatically__c = true;
        return resRequest;
    }



    
    /**
* This method is used to clone all resource requests of Agreement having Bid_Number =1 for other Agreements
* @params    project pse__Proj__c
* @params  resReq pse__Resource_Request__c
* @params    pse__Resource_Request__c
*/
    public static pse__Resource_Request__c cloneReBidResourceRequest(pse__Proj__c project, pse__Resource_Request__c resReq) {
        pse__Resource_Request__c resRequest = resReq.clone(false);
        if(resRequest.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_BID_GRID){
            resRequest.Suggested_FTE__c = 0.0;
		}
        resRequest.recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
        resRequest.pse__Project__c = project.Id;
        resRequest.pse__Group__c = project.pse__Group__c;
        resRequest.Bid_History__c = project.Bid_History__c;
        resRequest.pse__Start_Date__c = project.pse__Start_Date__c;
        resRequest.pse__End_Date__c = project.pse__End_Date__c;
        resRequest.pse__SOW_Hours__c = 0.01;
        resRequest.pse__Assignment__c = null;
        resRequest.pse__Status__c ='Ready to Staff';
        resRequest.LeadSupportFlag__c= resReq.LeadSupportFlag__c;
        resRequest.CurrencyIsoCode = project.CurrencyIsoCode;
        resRequest.pse__Staffer_Resource__c= null;
        resRequest.Original_Assignee__c = resReq.pse__Staffer_Resource__c;
        resRequest.Is_Created_Automatically__c = true;
        return resRequest;
    }
    
    /**
* This is Utility method is usedd to calculate Complexity Score Total on Resource Requests
* @params  Map<Id, Apttus__APTS_Agreement__c> agrIdToAgreementMap
* @params  agrCondition String
* @params  List<pse__Resource_Request__c> rrList
* @return  List<pse__Resource_Request__c> toBeUpdatedRRList
*/
   /* public static List<pse__Resource_Request__c> calculateComplexityScoreTotal(Map<Id, Apttus__APTS_Agreement__c> agrIdToAgreementMap,
                                                                               Map<String,OWF_Resource_Setting__mdt> resSettingIdToResSettingMap,
                                                                               List<pse__Resource_Request__c> rrList) {
                                                                                   List<pse__Resource_Request__c> toBeUpdatedRRList = new List<pse__Resource_Request__c>();   
                                                                                   Decimal complexityScoreTotal = 0.00;                                                                                    
                                                                                   
                                                                                   for(pse__Resource_Request__c rr : rrList) {
                                                                                       complexityScoreTotal = 0.00;
                                                                                       if((rr.SubGroup__c != '' && rr.SubGroup__c != null) && resSettingIdToResSettingMap.containsKey(rr.SubGroup__c)) {
                                                                                           
                                                                                           //Contributing Factor = RFP_Ranking__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Agreement__c).RFP_Ranking__c == '5') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).RFP_Ranking__c == '4') {
                                                                                                   complexityScoreTotal += 0.75*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).RFP_Ranking__c == '3') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).RFP_Ranking__c == '2') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).RFP_Ranking__c == '1') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Number_of_Potential_Regions__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Potential_Regions__c != 0.00
                                                                                              && agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__c != null) {
                                                                                                  if(agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__r.Potential_Regions__c == 'Global') {
                                                                                                      complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Potential_Regions__c;
                                                                                                  }
                                                                                                  else if(agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__r.Number_of_Potential_Regions__c == 1) {
                                                                                                      complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Potential_Regions__c;
                                                                                                  }
                                                                                                  else if(agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__r.Number_of_Potential_Regions__c > 1) {
                                                                                                      complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Potential_Regions__c;                            
                                                                                                  }
                                                                                                  else {
                                                                                                      complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Potential_Regions__c;
                                                                                                  }
                                                                                              }
                                                                                           //Contributing Factor = Number_of_Sites__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Number_of_Sites__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Agreement__c).Number_of_Sites__c >= 100) {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Number_of_Sites__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Number_of_Sites__c >= 10) {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Number_of_Sites__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Number_of_Sites__c >= 0) {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Number_of_Sites__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Number_of_Sites__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Re_Bid_Complexity__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Agreement__c).Re_Bid_Complexity__c == 'Low') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Re_Bid_Complexity__c == 'Medium') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Re_Bid_Complexity__c == 'High') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Re_Bid_Complexity__c == 'Moderate') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Re_Bid_Complexity__c == 'Complex') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Estimated_Fees__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Agreement__c).Estimated_Fees__c == 'Less than $1M') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Estimated_Fees__c == 'Greater than $1M') {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Estimated_Fees__c == 'Less than $10M') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Estimated_Fees__c == 'Greater than $10M') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Estimated_Fees__c == 'Greater than $20M') {
                                                                                                   complexityScoreTotal += 0.75*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }                    
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Estimated_Fees__c == 'Greater than $25M - GFR') {
                                                                                                   complexityScoreTotal += 0.75*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Estimated_Fees__c == 'Greater than $50M') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Estimated_Fees__c == 'N/A') {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Is_there_a_Client_Bid_Grid__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Is_there_a_Client_Bid_Grid__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Agreement__c).Is_there_a_Client_Bid_Grid__c == 'Yes') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Is_there_a_Client_Bid_Grid__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Requested_Services__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Requested_Services__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Agreement__c).Number_of_Requested_Services__c >= 5) {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Requested_Services__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Number_of_Requested_Services__c > 2) {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Requested_Services__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Number_of_Requested_Services__c > 0) {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Requested_Services__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Requested_Services__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Staffing_Number_of_Unique_Tables__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Staffing_Number_of_Unique_Tables__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Agreement__c).Staffing_Number_of_Unique_Tables__c == '<5') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Staffing_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Staffing_Number_of_Unique_Tables__c == '>5') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Staffing_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Staffing_Number_of_Unique_Tables__c == '>10') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Staffing_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Staffing_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Project_Ex_Number_of_Unique_Tables__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Project_Ex_Number_of_Unique_Tables__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Agreement__c).Project_Ex_Number_of_Unique_Tables__c == '<5') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Project_Ex_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Project_Ex_Number_of_Unique_Tables__c == '>5') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Project_Ex_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Agreement__c).Project_Ex_Number_of_Unique_Tables__c == '>10') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Project_Ex_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Project_Ex_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                           }
                                                                                           
                                                                                             //Contributing Factor = Country__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Country__c != 0.00){
                                                                                               if(rr.Regional_Analytics_Country__c != null) {
                                                                                                    complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Country__c;
                                                                                               }                                                                                             
                                                                                           }
                                                                                           rr.Complexity_Score_Total__c = complexityScoreTotal;
                                                                                           toBeUpdatedRRList.add(rr);
                                                                                       }
                                                                                       
                                                                                   }                                                                            
                                                                                   
                                                                                   return toBeUpdatedRRList;        
                                                                               }*/



    /**
* This is Utility method is usedd to calculate Complexity Score Total on Resource Requests
* @params  Map<Id, Bid_History__c> agrIdToAgreementMap
* @params  agrCondition String
* @params  List<pse__Resource_Request__c> rrList
* @return  List<pse__Resource_Request__c> toBeUpdatedRRList
*/
    
    public static List<pse__Resource_Request__c> calculateComplexityScoreTotal(Map<Id, Bid_History__c> agrIdToAgreementMap,
                                                                               Map<String,OWF_Resource_Setting__mdt> resSettingIdToResSettingMap,
                                                                               List<pse__Resource_Request__c> rrList) {
                                                                                   List<pse__Resource_Request__c> toBeUpdatedRRList = new List<pse__Resource_Request__c>();   
                                                                                   Decimal complexityScoreTotal = 0.00;                                                                                    
                                                                                   
                                                                                   for(pse__Resource_Request__c rr : rrList) {
                                                                                       complexityScoreTotal = 0.00;
                                                                                       if((rr.SubGroup__c != '' && rr.SubGroup__c != null) && resSettingIdToResSettingMap.containsKey(rr.SubGroup__c)) {
                                                                                           
                                                                                           //Contributing Factor = RFP_Ranking__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Bid_History__c).RFP_Ranking__c == '5') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).RFP_Ranking__c == '4') {
                                                                                                   complexityScoreTotal += 0.75*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).RFP_Ranking__c == '3') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).RFP_Ranking__c == '2') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).RFP_Ranking__c == '1') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).RFP_Ranking__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Number_of_Potential_Regions__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Potential_Regions__c != 0.00
                                                                                              && agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__c != null) {
                                                                                                  if(agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__r.Potential_Regions__c == 'Global') {
                                                                                                      complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Potential_Regions__c;
                                                                                                  }
                                                                                                  else if(agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__r.Number_of_Potential_Regions__c == 1) {
                                                                                                      complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Potential_Regions__c;
                                                                                                  }
                                                                                                  else if(agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__r.Number_of_Potential_Regions__c > 1) {
                                                                                                      complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Potential_Regions__c;                            
                                                                                                  }
                                                                                                  else {
                                                                                                      complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Potential_Regions__c;
                                                                                                  }
                                                                                              }
                                                                                           //Contributing Factor = Number_of_Sites__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Number_of_Sites__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Bid_History__c).Number_of_Sites__c >= 100) {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Number_of_Sites__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Number_of_Sites__c >= 10) {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Number_of_Sites__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Number_of_Sites__c >= 0) {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Number_of_Sites__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Number_of_Sites__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Re_Bid_Complexity__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Bid_History__c).Re_Bid_Complexity__c == 'Low') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Re_Bid_Complexity__c == 'Medium') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Re_Bid_Complexity__c == 'High') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Re_Bid_Complexity__c == 'Moderate') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Re_Bid_Complexity__c == 'Complex') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Re_Bid_Complexity__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Estimated_Fees__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Bid_History__c).Estimated_Fees__c == 'Less than $1M') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Estimated_Fees__c == 'Greater than $1M') {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Estimated_Fees__c == 'Less than $10M') {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Estimated_Fees__c == 'Greater than $10M') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Estimated_Fees__c == 'Greater than $20M') {
                                                                                                   complexityScoreTotal += 0.75*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }                    
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Estimated_Fees__c == 'Greater than $25M - GFR') {
                                                                                                   complexityScoreTotal += 0.75*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Estimated_Fees__c == 'Greater than $50M') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Estimated_Fees__c == 'N/A') {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Is_there_a_Client_Bid_Grid__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Is_there_a_Client_Bid_Grid__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Bid_History__c).Is_there_a_Client_Bid_Grid__c == 'Yes') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Is_there_a_Client_Bid_Grid__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Estimated_Fees__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Requested_Services__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Requested_Services__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Bid_History__c).Number_of_Requested_Services__c >= 5) {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Requested_Services__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Number_of_Requested_Services__c > 2) {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Requested_Services__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Number_of_Requested_Services__c > 0) {
                                                                                                   complexityScoreTotal += 0.25*resSettingIdToResSettingMap.get(rr.SubGroup__c).Requested_Services__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Requested_Services__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Staffing_Number_of_Unique_Tables__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Staffing_Number_of_Unique_Tables__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Bid_History__c).Staffing_Number_of_Unique_Tables__c == '<5') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Staffing_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Staffing_Number_of_Unique_Tables__c == '>5') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Staffing_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Staffing_Number_of_Unique_Tables__c == '>10') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Staffing_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Staffing_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                           }
                                                                                           //Contributing Factor = Project_Ex_Number_of_Unique_Tables__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Project_Ex_Number_of_Unique_Tables__c != 0.00) {
                                                                                               if(agrIdToAgreementMap.get(rr.Bid_History__c).Project_Ex_Number_of_Unique_Tables__c == '<5') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Project_Ex_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Project_Ex_Number_of_Unique_Tables__c == '>5') {
                                                                                                   complexityScoreTotal += 0.50*resSettingIdToResSettingMap.get(rr.SubGroup__c).Project_Ex_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else if(agrIdToAgreementMap.get(rr.Bid_History__c).Project_Ex_Number_of_Unique_Tables__c == '>10') {
                                                                                                   complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Project_Ex_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                               else {
                                                                                                   complexityScoreTotal += 0.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Project_Ex_Number_of_Unique_Tables__c;
                                                                                               }
                                                                                           }
                                                                                           
                                                                                             //Contributing Factor = Country__c
                                                                                           if(resSettingIdToResSettingMap.get(rr.SubGroup__c).Country__c != 0.00){
                                                                                               if(rr.Regional_Analytics_Country__c != null) {
                                                                                                    complexityScoreTotal += 1.00*resSettingIdToResSettingMap.get(rr.SubGroup__c).Country__c;
                                                                                               }                                                                                             
                                                                                           }
                                                                                           rr.Complexity_Score_Total__c = complexityScoreTotal;
                                                                                           toBeUpdatedRRList.add(rr);
                                                                                       }
                                                                                       
                                                                                   }                                                                            
                                                                                   return toBeUpdatedRRList;        
                                                                               }


    
  /*  public static List<pse__Resource_Request__c> calculateWRandSuggestedFTE(Map<Id, Apttus__APTS_Agreement__c> agrIdToAgreementMap, List<pse__Resource_Request__c> rrList) {        
        Set<pse__Resource_Request__c> rrSet = new Set<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> resourceRequestList = new List<pse__Resource_Request__c>();
        Map<String, List<OWF_Assignment_Setting__mdt>> oasIdToOasMap = new Map<String, List<OWF_Assignment_Setting__mdt>>();
        //IQVIAPSA-2165 (start) 
        Map<String,OWF_Assignment_Setting__mdt> gboRFIMap = new Map<String,OWF_Assignment_Setting__mdt>();
        Map<String,OWF_Assignment_Setting__mdt> gboBidGridMap = new Map<String,OWF_Assignment_Setting__mdt>();
        Set<String> oasFieldSet = new Set<String>{'Id','Complexity_Score__c','Triage_Level__c','Resource_Request_Type__c','Suggested_FTE__c','Workload_Ranking__c','Field_Start_Date__c','Field_End_Date__c','Sub_Group__c',
            'Value_Adjusted_Start_Days__c','Value_Adjusted_End_Days__c','RFP_Ranking__c','Grid_Ranking_Level__c'};
                for(OWF_Assignment_Setting__mdt oasCMT : new SLT_OWF_Assignment_Setting(false, false).getOWFAssignmentSettingRecords(oasFieldSet)) {           
                    if(!oasIdToOasMap.containsKey(oasCMT.Resource_Request_Type__c)) 
                    {
                        if(oasCMT.Sub_Group__c == 'GBO-RFI' && oasCMT.Resource_Request_Type__c =='RFI' && oasCMT.Triage_Level__c!=null)
                        {
                            gboRFIMap.put(oasCMT.Triage_Level__c,oasCMT);
                        }
                        else if(oasCMT.Sub_Group__c == CON_OWF.RES_REQ_TYPE_GBO_BID_GRID && oasCMT.Grid_Ranking_Level__c!=null)
                        {
                            gboBidGridMap.put(oasCMT.Grid_Ranking_Level__c,oasCMT);
                        }
                        oasIdToOasMap.put(oasCMT.Resource_Request_Type__c,new List<OWF_Assignment_Setting__mdt>()); 
                        oasIdToOasMap.get(oasCMT.Resource_Request_Type__c).add(oasCMT); 
                    } 
                    else{
                        if(oasCMT.Sub_Group__c == 'GBO-RFI' && oasCMT.Resource_Request_Type__c =='RFI' && oasCMT.Triage_Level__c!=null)
                        {
                            gboRFIMap.put(oasCMT.Triage_Level__c,oasCMT);
                        }
                        else if(oasCMT.Sub_Group__c == CON_OWF.RES_REQ_TYPE_GBO_BID_GRID && oasCMT.Grid_Ranking_Level__c!=null)
                        {
                            gboBidGridMap.put(oasCMT.Grid_Ranking_Level__c,oasCMT);
                        }
                        oasIdToOasMap.get(oasCMT.Resource_Request_Type__c).add(oasCMT); 
                    }  
                }
        if(oasIdToOasMap.size() > 0 ){            
            for(pse__Resource_Request__c rr : rrList) {
                //Updating pse__Resource_Request_Name__c for Resource_Request records 
                if(rr.pse__Status__c != 'Cancelled' && rr.pse__Status__c != 'Completed' && rr.pse__Status__c != 'Closed'){
                    if(rr.SubGroup__c != NULL && rr.Resource_Request_Type__c != NULL) {
                        rr.pse__Resource_Request_Name__c = rr.Resource_Request_Type__c + '/' + rr.SubGroup__c;
                        if(rr.Is_Bid_Defense__c) {
                            rr.pse__Resource_Request_Name__c += '/' + CON_OWF.RES_REQ_TYPE_BID_DEFENCE;
                        }
                    }
                    if(oasIdToOasMap.containsKey(rr.Resource_Request_Type__c) ) {
                        for(OWF_Assignment_Setting__mdt oas : oasIdToOasMap.get(rr.Resource_Request_Type__c)) {
                            //Updating data on RRs based on custom metadata                            
                            if(rr.Complexity_Score_Total__c >= oas.Complexity_Score__c && rr.SubGroup__c == oas.Sub_Group__c 
                               && (agrIdToAgreementMap.get(rr.Agreement__c).RFP_Ranking__c == '' ||
                                   (oas.RFP_Ranking__c != '*' && agrIdToAgreementMap.get(rr.Agreement__c).RFP_Ranking__c == oas.RFP_Ranking__c) 
                                   || oas.RFP_Ranking__c == '*') ) {
                                       
                                       if(oas.Sub_Group__c == 'GBO-RFI' && oas.Resource_Request_Type__c =='RFI' && oas.Triage_Level__c != ''){
                                           rr.Suggested_FTE__c = gboRFIMap.get(agrIdToAgreementMap.get(rr.Agreement__c).Triage_Level__c).Suggested_FTE__c;
                                           rr.Workload_Ranking__c = gboRFIMap.get(agrIdToAgreementMap.get(rr.Agreement__c).Triage_Level__c).Workload_Ranking__c;
                                       }
                                       else if(oas.Sub_Group__c == CON_OWF.RES_REQ_TYPE_GBO_BID_GRID){
                                           	if(agrIdToAgreementMap.get(rr.Agreement__c).Grid_Ranking_Level__c != null)
                                            {
                                            	rr.Suggested_FTE__c = gboBidGridMap.get(agrIdToAgreementMap.get(rr.Agreement__c).Grid_Ranking_Level__c).Suggested_FTE__c;    
                                            }
                                                      
                                       }
                                       else{
                                           rr.Suggested_FTE__c = oas.Suggested_FTE__c;
                                           rr.Workload_Ranking__c = oas.Workload_Ranking__c; 
                                       }
                                       //IQVIAPSA-2165 (stop) 
                                       
                                       String startDateFieldValue = oas.Field_Start_Date__c;
                                       String endDateFieldValue = oas.Field_End_Date__c;       
                                       //system.debug(startDateFieldValue + ':' + endDateFieldValue +' : '+ rr.SubGroup__c);
                                       if(agrIdToAgreementMap != null && agrIdToAgreementMap.containsKey(rr.Agreement__c) && agrIdToAgreementMap.get(rr.Agreement__c) != null ){      
                                           if(startDateFieldValue.equals(CON_OWF.CREATED_DATE)){                                  
                                               if(oas.Value_Adjusted_Start_Days__c != null){
                                                   Date startDate;
                                                   startDate = date.valueOf(agrIdToAgreementMap.get(rr.Agreement__c).createdDate);
                                                   
                                                   rr.pse__Start_Date__c = startDate.addDays(Integer.valueof(oas.Value_Adjusted_Start_Days__c));
                                               }else{
                                                   rr.pse__Start_Date__c = date.valueOf(agrIdToAgreementMap.get(rr.Agreement__c).createdDate);
                                               }
                                           }else if(startDateFieldValue.equals(CON_OWF.PRESENTATION_DATE) && agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__c != null && agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__r.Bid_Defense_Date__c != null){
                                               if(oas.Value_Adjusted_Start_Days__c != null){
                                                   Date startDate = agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__r.Bid_Defense_Date__c;
                                                   
                                                   //rr.pse__Start_date__c = startDate.addDays(Integer.valueof(oas.Value_Adjusted_Start_Days__c));
                                                   rr.pse__Start_date__c = getAdjustedDateAccToWorkingDays(startDate,Math.abs(Integer.valueOf(oas.Value_Adjusted_Start_Days__c)));
                                               
                                               }else{
                                                   rr.pse__Start_date__c = agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__r.Bid_Defense_Date__c;
                                               }
                                               //rr.pse__Start_Date__c = agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__r.Bid_Defense_Date__c;
                                               //System.debug('Integer Values 2:'+rr.pse__Start_Date__c);
                                           }
/*IQVIAPSA-2243*/                        
    /*else if(startDateFieldValue.equals(CON_OWF.REQUESTING_DATE) && agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__c != null && agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__r.Bid_Defense_Date__c != null){
                                               if(rr.Id == Null)
                                               {
                                                   if(oas.Value_Adjusted_Start_Days__c != null){
                                                       Date startDate = system.today();        
                                                       rr.pse__Start_Date__c = startDate.addDays(Integer.valueof(oas.Value_Adjusted_Start_Days__c));
                                                   }else{
                                                       rr.pse__Start_Date__c = system.today();
                                                   }
                                               }
                                           }
                                           
                                           if(endDateFieldValue.equals(CON_OWF.BID_DUE_DATE) && agrIdToAgreementMap.get(rr.Agreement__c).Bid_Due_Date__c != null)    
                                               if(oas.Value_Adjusted_End_Days__c != null){
                                                   Date endDate = agrIdToAgreementMap.get(rr.Agreement__c).Bid_Due_Date__c;
                                                   rr.pse__End_Date__c = endDate.addDays(Integer.valueof(oas.Value_Adjusted_End_Days__c));
                                               }else{
                                                   rr.pse__End_Date__c = agrIdToAgreementMap.get(rr.Agreement__c).Bid_Due_Date__c;
                                               }
                                           else if(endDateFieldValue.equals(CON_OWF.PRESENTATION_DATE) && agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__c != null && agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__r.Bid_Defense_Date__c != null )
                                               if(oas.Value_Adjusted_End_Days__c != null){
                                                   Date endDate = agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__r.Bid_Defense_Date__c;
                                                   rr.pse__End_Date__c = endDate.addDays(Integer.valueof(oas.Value_Adjusted_End_Days__c));
                                               }else{
                                                   rr.pse__End_Date__c = agrIdToAgreementMap.get(rr.Agreement__c).Apttus__Related_Opportunity__r.Bid_Defense_Date__c;
                                               }    
                                       }
                                       /*if(agrIdToAgreementMap.containsKey(rr.Agreement__c) && agrIdToAgreementMap.get(rr.Agreement__c).RFP_Ranking__c != null){
                                           Integer rfpRanking = Integer.valueOf(agrIdToAgreementMap.get(rr.Agreement__c).RFP_Ranking__c);
                                           Integer n = 0;
                                           for(Integer i=0; i <= 8; i++)
                                           {
                                               if(DateTime.newInstance(rr.pse__Start_Date__c.addDays(i), Time.newInstance(0, 0, 0, 0)).format('EEEE') == 'Saturday')
                                               {
                                                   n = 1;
                                               }
                                               else if(DateTime.newInstance(rr.pse__Start_Date__c.addDays(i), Time.newInstance(0, 0, 0, 0)).format('EEEE') == 'Sunday')
                                               {                                   
                                                   n = 2; 
                                               }
                                               else if(DateTime.newInstance(rr.pse__Start_Date__c.addDays(i), Time.newInstance(0, 0, 0, 0)).format('EEEE') == 'Monday')
                                               {
                                                   n = 3;
                                               }
                                           }
                                           /*IQVIAPSA-1318*/      /*                    if(rr.Is_Bid_Defense__c == True && rr.SubGroup__c!='LCS Bid Defense'){   
                                               Datetime endDt = DateTime.newInstance(rr.pse__End_Date__c, Time.newInstance(0, 0, 0, 0));
                                               rr.pse__Start_Date__c = rr.pse__Start_Date__c.addDays(-n);
                                               //System.assert(false, 'Integer Values : '+rr.pse__Start_Date__c);
                                           }
                                       }*/
                                   /*    if(rr.pse__Start_Date__c == null) {
                                           rr.pse__Start_Date__c = date.valueOf(agrIdToAgreementMap.get(rr.Agreement__c).createdDate);
                                       }  
                                       
                                       resourceRequestList.add(rr);
                                       break;
                                   }
                        }
                    }
                } 
            }
        }                 
        return resourceRequestList;
    }
    
    */
    
        public static List<pse__Resource_Request__c> calculateWRandSuggestedFTE(Map<Id, Bid_History__c> agrIdToAgreementMap, List<pse__Resource_Request__c> rrList) {        
        List<pse__Resource_Request__c> resourceRequestList = new List<pse__Resource_Request__c>();
        Map<String, List<OWF_Assignment_Setting__mdt>> oasIdToOasMap = new Map<String, List<OWF_Assignment_Setting__mdt>>();
        //IQVIAPSA-2165 (start) 
        Map<String,OWF_Assignment_Setting__mdt> gboRFIMap = new Map<String,OWF_Assignment_Setting__mdt>();
        Map<String,OWF_Assignment_Setting__mdt> gboBidGridMap = new Map<String,OWF_Assignment_Setting__mdt>();
        Set<String> oasFieldSet = new Set<String>{'Id','Complexity_Score__c','Triage_Level__c','Resource_Request_Type__c','Suggested_FTE__c','Workload_Ranking__c','Field_Start_Date__c','Field_End_Date__c','Sub_Group__c',
            'Value_Adjusted_Start_Days__c','Value_Adjusted_End_Days__c','RFP_Ranking__c','Grid_Ranking_Level__c'};
                for(OWF_Assignment_Setting__mdt oasCMT : new SLT_OWF_Assignment_Setting(false, false).getOWFAssignmentSettingRecords(oasFieldSet)) {           
                    if(!oasIdToOasMap.containsKey(oasCMT.Resource_Request_Type__c)) 
                    {
                        if(oasCMT.Sub_Group__c == 'GBO-RFI' && oasCMT.Resource_Request_Type__c =='RFI' && oasCMT.Triage_Level__c!=null)
                        {
                            gboRFIMap.put(oasCMT.Triage_Level__c,oasCMT);
                        }
                        else if(oasCMT.Sub_Group__c == CON_OWF.RES_REQ_TYPE_GBO_BID_GRID && oasCMT.Grid_Ranking_Level__c!=null)
                        {
                            gboBidGridMap.put(oasCMT.Grid_Ranking_Level__c,oasCMT);
                        }
                        oasIdToOasMap.put(oasCMT.Resource_Request_Type__c,new List<OWF_Assignment_Setting__mdt>()); 
                        oasIdToOasMap.get(oasCMT.Resource_Request_Type__c).add(oasCMT); 
                    } 
                    else{
                        if(oasCMT.Sub_Group__c == 'GBO-RFI' && oasCMT.Resource_Request_Type__c =='RFI' && oasCMT.Triage_Level__c!=null)
                        {
                            gboRFIMap.put(oasCMT.Triage_Level__c,oasCMT);
                        }
                        else if(oasCMT.Sub_Group__c == CON_OWF.RES_REQ_TYPE_GBO_BID_GRID && oasCMT.Grid_Ranking_Level__c!=null)
                        {
                            gboBidGridMap.put(oasCMT.Grid_Ranking_Level__c,oasCMT);
                        }
                        oasIdToOasMap.get(oasCMT.Resource_Request_Type__c).add(oasCMT); 
                    }  
                }
        if(oasIdToOasMap.size() > 0 ){             
            String startDateFieldValue;
            String endDateFieldValue;   
            Date startDate;  
            Date endDate;	
            Set<Id> rrIdSet = new Set<Id>();
            Set<String> rrFieldSet = new Set<String>{'Id','pse__Assignment__r.pse__Status__c','pse__Assignment__c'};
            Map<Id,pse__Resource_Request__c> rrIdToResReqMap = new Map<Id,pse__Resource_Request__c>();
            for(pse__Resource_Request__c rr : rrList) {
                if(rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_Clinical_Coding || rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_GBO_BID_GRID || (rr.SubGroup__c == CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS &&
                                                                              rr.Regional_Analytics_Country__c != CON_OWF.RA_COUNTRY_TYPE_STRATEGIC_ANALYTICS)){
                                                                                  rrIdSet.add(rr.id);
                                                                              }
                
            }
            if(!rrIdSet.isEmpty()){
                rrIdToResReqMap = new SLT_Resource_Request().selectResReqsById(rrIdSet,rrFieldSet);
            }
            for(pse__Resource_Request__c rr : rrList) {
                //Updating pse__Resource_Request_Name__c for Resource_Request records 
                if(rr.pse__Status__c != 'Cancelled' && rr.pse__Status__c != 'Completed' && rr.pse__Status__c != 'Closed'){
                    if(rr.SubGroup__c != NULL && rr.Resource_Request_Type__c != NULL) {
                        rr.pse__Resource_Request_Name__c = rr.Resource_Request_Type__c + '/' + rr.SubGroup__c;
                        if(rr.Is_Bid_Defense__c) {
                            rr.pse__Resource_Request_Name__c += '/' + CON_OWF.RES_REQ_TYPE_BID_DEFENCE;
                        }
                    }
                    if(oasIdToOasMap.containsKey(rr.Resource_Request_Type__c) ) {
                        for(OWF_Assignment_Setting__mdt oas : oasIdToOasMap.get(rr.Resource_Request_Type__c)) {
                            //Updating data on RRs based on custom metadata                            
                            if(rr.Complexity_Score_Total__c >= oas.Complexity_Score__c && rr.SubGroup__c == oas.Sub_Group__c 
                               && (agrIdToAgreementMap.get(rr.Bid_History__c).RFP_Ranking__c == '' ||
                                   (oas.RFP_Ranking__c != '*' && agrIdToAgreementMap.get(rr.Bid_History__c).RFP_Ranking__c == oas.RFP_Ranking__c) 
                                   || oas.RFP_Ranking__c == '*') ) {
                                       
                                       if(oas.Sub_Group__c == 'GBO-RFI' && oas.Resource_Request_Type__c =='RFI' && oas.Triage_Level__c != ''){
                                           rr.Suggested_FTE__c = gboRFIMap.get(agrIdToAgreementMap.get(rr.Bid_History__c).Triage_Level__c).Suggested_FTE__c;
                                           rr.Workload_Ranking__c = gboRFIMap.get(agrIdToAgreementMap.get(rr.Bid_History__c).Triage_Level__c).Workload_Ranking__c;
                                       }
                                       else if(oas.Sub_Group__c == CON_OWF.RES_REQ_TYPE_GBO_BID_GRID){
                                           	if(agrIdToAgreementMap.get(rr.Bid_History__c).Grid_Ranking_Level__c != null)
                                            {
                                            	rr.Suggested_FTE__c = gboBidGridMap.get(agrIdToAgreementMap.get(rr.Bid_History__c).Grid_Ranking_Level__c).Suggested_FTE__c;    
                                            }
                                                      
                                       }
                                       else{
                                           rr.Suggested_FTE__c = oas.Suggested_FTE__c;
                                           rr.Workload_Ranking__c = oas.Workload_Ranking__c; 
                                       }
                                       //IQVIAPSA-2165 (stop) 
                                       
                                       startDateFieldValue = oas.Field_Start_Date__c;
                                       endDateFieldValue = oas.Field_End_Date__c;       
                                       //system.debug(startDateFieldValue + ':' + endDateFieldValue +' : '+ rr.SubGroup__c);
                                       if(agrIdToAgreementMap != null && agrIdToAgreementMap.containsKey(rr.Bid_History__c) && agrIdToAgreementMap.get(rr.Bid_History__c) != null &&
                                          (Trigger.isInsert || (Trigger.isUpdate && ((rr.SubGroup__c != CON_OWF.RES_REQ_TYPE_Clinical_Coding && rr.SubGroup__c != CON_OWF.RES_REQ_TYPE_GBO_BID_GRID &&
                                                                                      (rr.SubGroup__c != CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS ||
                                                                                      rr.Regional_Analytics_Country__c == CON_OWF.RA_COUNTRY_TYPE_STRATEGIC_ANALYTICS)) 
                                                                                     || (rr.pse__Assignment__c == Null || (rr.pse__Assignment__c != null
                                                                                     && rrIdToResReqMap.containsKey(rr.id) && rrIdToResReqMap.get(rr.id).pse__Assignment__r.pse__Status__c != CON_OWF.OWF_ASSIGNMENT_STATUS_ACCEPTED
                                                                                     && rrIdToResReqMap.get(rr.id).pse__Assignment__r.pse__Status__c != CON_OWF.OWF_ASSIGNMENT_STATUS_COMPLETED)))))){   

                                           if(startDateFieldValue.equals(CON_OWF.CREATED_DATE) && (rr.pse__Start_Date__c < agrIdToAgreementMap.get(rr.Bid_History__c).createdDate || rr.pse__Start_Date__c > agrIdToAgreementMap.get(rr.Bid_History__c).Bid_Due_Date__c)){                                  
                                               if(oas.Value_Adjusted_Start_Days__c != null){
                                                   startDate = date.valueOf(agrIdToAgreementMap.get(rr.Bid_History__c).createdDate);
                                                   rr.pse__Start_Date__c = startDate.addDays(Integer.valueof(oas.Value_Adjusted_Start_Days__c));
                                               }else{
                                                   rr.pse__Start_Date__c = date.valueOf(agrIdToAgreementMap.get(rr.Bid_History__c).createdDate);
                                               }
                                           }else if(startDateFieldValue.equals(CON_OWF.PRESENTATION_DATE) && agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__c != null && agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__r.Bid_Defense_Date__c != null){
                                               if(oas.Value_Adjusted_Start_Days__c != null){
                                                   startDate = agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__r.Bid_Defense_Date__c;
                                                   //rr.pse__Start_date__c = startDate.addDays(Integer.valueof(oas.Value_Adjusted_Start_Days__c));
                                                   rr.pse__Start_date__c = getAdjustedDateAccToWorkingDays(startDate,Math.abs(Integer.valueOf(oas.Value_Adjusted_Start_Days__c)));
                                               }else{
                                                   rr.pse__Start_date__c = agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__r.Bid_Defense_Date__c;
                                               }
                                               //rr.pse__Start_Date__c = agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__r.Bid_Defense_Date__c;
                                               //System.debug('Integer Values 2:'+rr.pse__Start_Date__c);
                                           }
/*IQVIAPSA-2243*/                          else if(startDateFieldValue.equals(CON_OWF.REQUESTING_DATE) && agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__c != null && agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__r.Bid_Defense_Date__c != null && (rr.pse__Start_Date__c < agrIdToAgreementMap.get(rr.Bid_History__c).createdDate || rr.pse__Start_Date__c > agrIdToAgreementMap.get(rr.Bid_History__c).Bid_Due_Date__c)){
                                               if(rr.Id == Null)
                                               {
                                                   if(oas.Value_Adjusted_Start_Days__c != null){
                                                       startDate = system.today();        
                                                       rr.pse__Start_Date__c = startDate.addDays(Integer.valueof(oas.Value_Adjusted_Start_Days__c));
                                                   }else{
                                                       rr.pse__Start_Date__c = system.today();
                                                   }
                                               }
                                           }
                                           
                                           if(endDateFieldValue.equals(CON_OWF.BID_DUE_DATE) && agrIdToAgreementMap.get(rr.Bid_History__c).Bid_Due_Date__c != null && (rr.pse__End_Date__c < agrIdToAgreementMap.get(rr.Bid_History__c).createdDate || rr.pse__End_Date__c > agrIdToAgreementMap.get(rr.Bid_History__c).Bid_Due_Date__c)){   
                                               if(oas.Value_Adjusted_End_Days__c != null){
                                                   endDate = agrIdToAgreementMap.get(rr.Bid_History__c).Bid_Due_Date__c;
                                                   rr.pse__End_Date__c = endDate.addDays(Integer.valueof(oas.Value_Adjusted_End_Days__c));
                                               }else{
                                                   rr.pse__End_Date__c = agrIdToAgreementMap.get(rr.Bid_History__c).Bid_Due_Date__c;
                                               }
                                           }
                                           else if(endDateFieldValue.equals(CON_OWF.PRESENTATION_DATE) && agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__c != null && agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__r.Bid_Defense_Date__c != null){
                                               if(oas.Value_Adjusted_End_Days__c != null){
                                                   endDate = agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__r.Bid_Defense_Date__c;
                                                   rr.pse__End_Date__c = endDate.addDays(Integer.valueof(oas.Value_Adjusted_End_Days__c));
                                               }else{
                                                   rr.pse__End_Date__c = agrIdToAgreementMap.get(rr.Bid_History__c).Bid_History_Related_Opportunity__r.Bid_Defense_Date__c;
                                               } 
                                           }
                                       }
                                       /*if(agrIdToAgreementMap.containsKey(rr.Bid_History__c) && agrIdToAgreementMap.get(rr.Bid_History__c).RFP_Ranking__c != null){
                                           Integer rfpRanking = Integer.valueOf(agrIdToAgreementMap.get(rr.Bid_History__c).RFP_Ranking__c);
                                           Integer n = 0;
                                           for(Integer i=0; i <= 8; i++)
                                           {
                                               if(DateTime.newInstance(rr.pse__Start_Date__c.addDays(i), Time.newInstance(0, 0, 0, 0)).format('EEEE') == 'Saturday')
                                               {
                                                   n = 1;
                                               }
                                               else if(DateTime.newInstance(rr.pse__Start_Date__c.addDays(i), Time.newInstance(0, 0, 0, 0)).format('EEEE') == 'Sunday')
                                               {                                   
                                                   n = 2; 
                                               }
                                               else if(DateTime.newInstance(rr.pse__Start_Date__c.addDays(i), Time.newInstance(0, 0, 0, 0)).format('EEEE') == 'Monday')
                                               {
                                                   n = 3;
                                               }
                                           }
                                           /*IQVIAPSA-1318*/      /*                    if(rr.Is_Bid_Defense__c == True && rr.SubGroup__c!='LCS Bid Defense'){   
                                               Datetime endDt = DateTime.newInstance(rr.pse__End_Date__c, Time.newInstance(0, 0, 0, 0));
                                               rr.pse__Start_Date__c = rr.pse__Start_Date__c.addDays(-n);
                                               //System.assert(false, 'Integer Values : '+rr.pse__Start_Date__c);
                                               //System.debug('Integer Values:'+rr.pse__Start_Date__c);
                                           }
                                       }*/
                                       if(rr.pse__Start_Date__c == null) {
                                           rr.pse__Start_Date__c = date.valueOf(agrIdToAgreementMap.get(rr.Bid_History__c).createdDate);
                                       }  
                                       
                                       resourceRequestList.add(rr);
                                       break;
                                   }
                        }
                    }
                } 
            }
        }
        return resourceRequestList;
    }
    
    private static Date getAdjustedDateAccToWorkingDays(Date dateToAdjust, Integer valueAdjustedDays){
        Integer n = 0;
        for(Integer i = 0; i < valueAdjustedDays; i++){
            n++;
            if(DateTime.newInstance(dateToAdjust.addDays(-n), Time.newInstance(0, 0, 0, 0)).format('EEEE') == 'Saturday')
            {
                n++;
            }
            else if(DateTime.newInstance(dateToAdjust.addDays(-n), Time.newInstance(0, 0, 0, 0)).format('EEEE') == 'Sunday')
            {
             	n = n+2;   
            }
        }
        return dateToAdjust.addDays(-n);		
    }
    
    public static List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> calculateNWTimePercentage(List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> rrContactIdToMatchScoreList) {
        Set<Id> resourceIdSet = new Set<Id>();
        Set<Id> rrIdSet = new Set<Id>();
        Boolean isProjectDateisOfToday =true;
        Map<Id, pse__Resource_Request__c> rrIdToRrMap = new Map<Id, pse__Resource_Request__c>();
        Set<String> rrFieldSet = new Set<String>{'Id','pse__Project__r.pse__Start_Date__c','pse__Project__r.pse__End_Date__c','Suggested_FTE__c','SubGroup__c','Resource_Request_Type__c'};
            Set<String> assignmentFieldSet = new Set<String>{'Id','pse__Start_Date__c','pse__End_Date__c','pse__Resource__r.Available_for_Triage_Flag__c',
                'Assignment_Type__c','pse__Resource__c'};
                    for(DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore rcm : rrContactIdToMatchScoreList) {
                        resourceIdSet.add(rcm.contactId);      
                        rrIdSet.add(rcm.resourceRequestId);
                         if(rcm.projectStartDate!=System.today()){
                            isProjectDateisOfToday = false;
                        }
                    } 
        if(rrIdSet.size() > 0) {
            rrIdToRrMap = new SLT_Resource_Request(false,false).selectResReqsById(rrIdSet,rrFieldSet);
        }
        String assignmentCondition = 'pse__Resource__c in: sObjectIdset and Assignment_Type__c =\'Days Off\' and pse__Resource__r.Available_for_Triage_Flag__c = TRUE and pse__Status__c =\'Days Off - Approved\'' ;
        if(isProjectDateisOfToday){
            assignmentCondition += ' AND pse__End_Date__c >= TODAY';
        }
        List<pse__Assignment__c> daysOffAssignmentList = new List<pse__Assignment__c>();
        Map<Id, Contact> idToContactMap; 
        
        Set<String> resourceFieldSet = new Set<String>{'Id','Available_FTE__c', 'pse__Is_Resource__c', 'pse__Is_Resource_Active__c'};
            if(resourceIdSet.size() > 0) {
                //contactList = new SLT_Contact(false, false).selectByContactIdList(resourceIdSet,resourceFieldSet);
                String conCondition = 'pse__Is_Resource__c=true and pse__Is_Resource_Active__c = true';
                idToContactMap = new SLT_Contact(false, false).selectByContactCondition(resourceIdSet,conCondition,resourceFieldSet);
            }                 
        if(resourceIdSet.size() > 0) {
            daysOffAssignmentList = new SLT_Assignment(false,false).getAssignmentByResource(resourceIdSet,assignmentCondition,assignmentFieldSet);
            Integer totalNwtDays = 0;
            Integer nwtDaysPerAssignment = 0;
            Integer bidDays = 0;
            for(DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore rrContactWrapper : rrContactIdToMatchScoreList) {
                totalNwtDays = 0;
                //Iterate over list of days off assignments of related Contact to calculate Non-Working time of a resource.
                for(pse__Assignment__c assign : daysOffAssignmentList) {
                    if(assign.pse__Resource__c == rrContactWrapper.contactId && rrIdToRrMap.containsKey(rrContactWrapper.resourceRequestId)) {
                        
                        nwtDaysPerAssignment = 0;
                        if(assign.pse__Start_Date__c >= rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__Start_Date__c
                           && assign.pse__End_Date__c <= rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__End_Date__c){
                               nwtDaysPerAssignment = assign.pse__Start_Date__c.daysBetween(assign.pse__End_Date__c) + 1;        
                           }
                        else if(assign.pse__Start_Date__c <= rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__Start_Date__c
                                && assign.pse__End_Date__c >= rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__End_Date__c){
                                    
                                    nwtDaysPerAssignment = rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__Start_Date__c.daysBetween(rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__End_Date__c) + 1;        
                                    
                                }
                        else if(assign.pse__Start_Date__c < rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__Start_Date__c
                                && assign.pse__End_Date__c <= rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__End_Date__c
                                && assign.pse__End_Date__c >= rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__Start_Date__c) {
                                    
                                    nwtDaysPerAssignment = rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__Start_Date__c.daysBetween(assign.pse__End_Date__c) + 1;                           
                                }
                        else if(assign.pse__Start_Date__c >= rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__Start_Date__c
                                && assign.pse__End_Date__c > rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__End_Date__c
                                && assign.pse__Start_Date__c < rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__End_Date__c) {
                                    
                                    nwtDaysPerAssignment = assign.pse__Start_Date__c.daysBetween(rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__End_Date__c) + 1;                           
                                } 
                        totalNwtDays += nwtDaysPerAssignment;
                    }                    
                }
                bidDays = rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__Start_Date__c.daysBetween(rrIdToRrMap.get(rrContactWrapper.resourceRequestId).pse__Project__r.pse__End_Date__c) + 1;
                if(bidDays != 0) {
                    Double nwtPercentage = (totalNwtDays*100)/bidDays;
                    rrContactWrapper.nwtPercentage = nwtPercentage;    
                }
                if(idToContactMap.containsKey(rrContactWrapper.contactId) &&
                   rrIdToRrMap.containsKey(rrContactWrapper.resourceRequestId) &&
                   !rrContactWrapper.assignmentSettingRecord.Ignore_FTE_Threshold__c &&
                   idToContactMap.get(rrContactWrapper.contactId).Available_FTE__c >= rrIdToRrMap.get(rrContactWrapper.resourceRequestId).Suggested_FTE__c ) {
                       
                       if(rrIdToRrMap.get(rrContactWrapper.resourceRequestId).SubGroup__c == CON_OWF.RES_REQ_TYPE_TSL && (rrIdToRrMap.get(rrContactWrapper.resourceRequestId).Resource_Request_Type__c == 'Clinical' || rrIdToRrMap.get(rrContactWrapper.resourceRequestId).Resource_Request_Type__c == 'Clinical - Ballpark') && idToContactMap.get(rrContactWrapper.contactId).Available_FTE__c>0.2){
                           rrContactWrapper.availableFTE = true; 
                       }
                       else{
                           rrContactWrapper.availableFTE = true; 
                       }
                   }
                else if(rrContactWrapper.assignmentSettingRecord.Ignore_FTE_Threshold__c)
                {
                    rrContactWrapper.availableFTE = true;
                }
            }             
        }
        return rrContactIdToMatchScoreList;
    }
    //Refactor code IQVIAPSA-2236  start
    public static Set<Id> isOPPhasOWFAgreementReturnSet(Set<Id> opportunitiesSet)
    {
        Set<Id> oppIdExistAgrmt=new Set<Id>();
        Set<String> agreementFieldSet = new Set<String>{'Id','recordtype.DeveloperName','recordTypeId','Bid_Due_Date__c','Bid_Number__c','Bid_History_Related_Opportunity__r.Bid_Defense_Date__c'};   
        Map<Id, Bid_History__c> agrIdToAgreementMap = new SLT_Bid_History(false,false).getBidHistoriesByOppID(opportunitiesSet,agreementFieldSet);  

        for(Bid_History__c agreement : agrIdToAgreementMap.values())
        {
            if((agreement.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID) && 
               (agreement.Bid_Number__c >= 1 && (agreement.Bid_Due_Date__c >= System.TODAY() ||
                                                 (agreement.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c!=Null && agreement.Bid_History_Related_Opportunity__r.Bid_Defense_Date__c
                                                  >=System.today()))))
            {
                
                oppIdExistAgrmt.add(agreement.Bid_History_Related_Opportunity__c);
                //  isOWFAgreement = true;
                break;
            }                   
        }
        return oppIdExistAgrmt;
        
    }
    //Refactor code IQVIAPSA-2236 End
    
    public static Boolean isLoginUserhasPermissionControl()
    {
        Set<String> pcFieldSet = new Set<String>{'Id','pse__Group__c'};
            boolean isPCExist = false;
        Map<Id, pse__Permission_Control__c> pcIdToPCMap = new SLT_Permission_Control(false,false).getPermissionControlId(new Set<Id>{UserInfo.getUserId()},pcFieldSet);
        if(!pcIdToPCMap.IsEmpty())
        {
            isPCExist = true;
        }
        return isPCExist;
    }
    
    
    
    public static Map<Id,boolean> calculateDaysOffForRebid(Map<Id, Id> rrIdtoContactIdMap) 
    {
        Map<Id,Boolean> rrIdToStatusMap = new Map<Id,Boolean>();
        Set<Id> contactIdsSet = new Set<Id>();
        contactIdsSet.addAll(rrIdtoContactIdMap.values());
        
        
        String daysOffAssignmentCondition = 'pse__Resource__c in: sObjectIdset and Assignment_Type__c =\'Days Off\' and pse__Resource__r.Available_for_Triage_Flag__c = TRUE and pse__Status__c =\'Days Off - Approved\'';
        Set<String> assignmentFieldSet = new Set<String>{'Id','pse__Start_Date__c','pse__End_Date__c','pse__Resource__r.Available_for_Triage_Flag__c','Assignment_Type__c','pse__Resource__c'};
            List<pse__Assignment__c> daysOffAssignmentList = new SLT_Assignment(false,false).getAssignmentByResource(contactIdsSet,daysOffAssignmentCondition,assignmentFieldSet);
        
        Set<String> rrFieldSet = new Set<String>{'Id','pse__Start_Date__c','pse__End_Date__c'};
            List<pse__Resource_Request__c> rrList = new SLT_Resource_Request(false,false).selectResReqsById(rrIdtoContactIdMap.keySet(),rrFieldSet).values();
        
        
        
        for(pse__Resource_Request__c rrFromMapInstance:rrList)
        {
            rrIdToStatusMap.put(rrFromMapInstance.Id,true);
            Integer totalNwtDays = 0;
            Integer nwtDaysPerAssignment = 0;
            Integer bidDays = 0;
            for(pse__Assignment__c daysOffAssignment: daysOffAssignmentList)
            {
                if(daysOffAssignment.pse__Resource__c == rrIdtoContactIdMap.get(rrFromMapInstance.Id))
                {    
                    //system.debug('nwtDaysPerAssignment->' + nwtDaysPerAssignment);
                    if(daysOffAssignment.pse__Start_Date__c >= rrFromMapInstance.pse__Start_Date__c
                       && daysOffAssignment.pse__End_Date__c <= rrFromMapInstance.pse__End_Date__c){
                           nwtDaysPerAssignment = daysOffAssignment.pse__Start_Date__c.daysBetween(daysOffAssignment.pse__End_Date__c) + 1;        
                       }
                    else if(daysOffAssignment.pse__Start_Date__c <= rrFromMapInstance.pse__Start_Date__c
                            && daysOffAssignment.pse__End_Date__c >= rrFromMapInstance.pse__End_Date__c){
                                
                                nwtDaysPerAssignment = rrFromMapInstance.pse__Start_Date__c.daysBetween(rrFromMapInstance.pse__End_Date__c) + 1;        
                                //system.debug('nwtDaysPerAssignment->))))' + nwtDaysPerAssignment);
                            }
                    else if(daysOffAssignment.pse__Start_Date__c < rrFromMapInstance.pse__Start_Date__c
                            && daysOffAssignment.pse__End_Date__c <= rrFromMapInstance.pse__End_Date__c
                            && daysOffAssignment.pse__End_Date__c >= rrFromMapInstance.pse__Start_Date__c) {
                                
                                nwtDaysPerAssignment = rrFromMapInstance.pse__Start_Date__c.daysBetween(daysOffAssignment.pse__End_Date__c) + 1;                           
                            }
                    else if(daysOffAssignment.pse__Start_Date__c >= rrFromMapInstance.pse__Start_Date__c
                            && daysOffAssignment.pse__End_Date__c > rrFromMapInstance.pse__End_Date__c
                            && daysOffAssignment.pse__Start_Date__c < rrFromMapInstance.pse__End_Date__c) {
                                
                                nwtDaysPerAssignment = daysOffAssignment.pse__Start_Date__c.daysBetween(rrFromMapInstance.pse__End_Date__c) + 1;                           
                            }
                    else if (daysOffAssignment.pse__Start_Date__c <= rrFromMapInstance.pse__Start_Date__c
                             && daysOffAssignment.pse__End_Date__c >=rrFromMapInstance.pse__End_Date__c
                             && daysOffAssignment.pse__Start_Date__c < rrFromMapInstance.pse__End_Date__c){
                                 
                                 nwtDaysPerAssignment = daysOffAssignment.pse__Start_Date__c.daysBetween(rrFromMapInstance.pse__End_Date__c) + 1;   
                             }
                    //system.debug('totalNwtDays->' + totalNwtDays + ':' +  nwtDaysPerAssignment);
                    totalNwtDays += nwtDaysPerAssignment;
                }
            }
            bidDays = rrFromMapInstance.pse__Start_Date__c.daysBetween( rrFromMapInstance.pse__End_Date__c) + 1;
            Double nwtPercentage = (totalNwtDays*100)/bidDays;
            if(nwtPercentage > 20){
                rrIdToStatusMap.put(rrFromMapInstance.Id,false);
            }
            
            
        }
        return rrIdToStatusMap;
    }
    
    public static boolean validateResourceGroup(Id resourceId)
    {
        Set<String> contactFieldSet = new Set<String>{'pse__Group__r.Name'};
            Set<Id> userIdSet = new Set<Id>{resourceId};    
                OWF_Config__c owfDefaultConfig = OWF_Config__c.getInstance();
        List<String> compatibleOWFGroupList1 = new List<String>();
        List<String> compatibleOWFGroupList2 = new List<String>();
        List<String> compatibleOWFGroupList3 = new List<String>();
        List<String> compatibleOWFGroupList4 = new List<String>();
        List<String> compatibleOWFGroupList5 = new List<String>();
        List<String> compatibleOWFGroupList6 = new List<String>();
        List<String> compatibleOWFGroupList7 = new List<String>();

        
        if(owfDefaultConfig.OWF_Compatible_Group_Set_1__c != Null){
            compatibleOWFGroupList1 = owfDefaultConfig.OWF_Compatible_Group_Set_1__c.split(',');
        }
        if(owfDefaultConfig.OWF_Compatible_Group_Set_2__c != Null){
            compatibleOWFGroupList2 = owfDefaultConfig.OWF_Compatible_Group_Set_2__c.split(',');
        }
        if(owfDefaultConfig.OWF_Compatible_Group_Set_3__c != Null){
            compatibleOWFGroupList3 = owfDefaultConfig.OWF_Compatible_Group_Set_3__c.split(',');
        }
        if(owfDefaultConfig.OWF_Compatible_Group_Set_4__c != Null){
            compatibleOWFGroupList4 = owfDefaultConfig.OWF_Compatible_Group_Set_4__c.split(',');
        }
        if(owfDefaultConfig.OWF_Compatible_Group_Set_5__c != Null){
            compatibleOWFGroupList5 = owfDefaultConfig.OWF_Compatible_Group_Set_5__c.split(',');
        }
        if(owfDefaultConfig.OWF_Compatible_Group_Set_6__c != Null){
            compatibleOWFGroupList6 = owfDefaultConfig.OWF_Compatible_Group_Set_6__c.split(',');
        }
        if(owfDefaultConfig.OWF_Compatible_Group_Set_7__c != Null){
            compatibleOWFGroupList7 = owfDefaultConfig.OWF_Compatible_Group_Set_7__c.split(',');
        }
        if(compatibleOWFGroupList1 != Null)
        {
            if(compatibleOWFGroupList2 != Null){
                compatibleOWFGroupList1.addAll(compatibleOWFGroupList2);
            }
            if(compatibleOWFGroupList3 != Null){
                compatibleOWFGroupList1.addAll(compatibleOWFGroupList3);
            }
            if(compatibleOWFGroupList4 != Null){
                compatibleOWFGroupList1.addAll(compatibleOWFGroupList4);
            }
            if(compatibleOWFGroupList5 != Null){
                compatibleOWFGroupList1.addAll(compatibleOWFGroupList5);
            }
            if(compatibleOWFGroupList6 != Null){
                compatibleOWFGroupList1.addAll(compatibleOWFGroupList6);
            }
            if(compatibleOWFGroupList7 != Null){
                compatibleOWFGroupList1.addAll(compatibleOWFGroupList7);
            }
        }
        List<Contact> contactList = new SLT_Contact(false,false).selectByPseSalesforceUserIdList(userIdSet,contactFieldSet);
        if(contactList.size()==0){
            return false;
        }
        if((contactList[0].pse__Group__r.Name == null) ||((contactList[0].pse__Group__r.Name != null && !compatibleOWFGroupList1.contains(contactList[0].pse__Group__r.Name)))){
            return false;
        }
        return true;
    }
    
    public static List<String> validateLIGForClinicalAgreement(Id opportunityId, String recordTypeName)
    {
        
        Set<String> ligFieldSet = new Set<String>{'Indication_List__c','Phase_P__c','Verbatim_Indication_Term__c','Drug_Product_Name__c',
            'FSP__c','Global_project_unit__c','FPI_Date__c','RFP_ReceivedDate__c','Potential_Services__c','Population_Age_Group__c',
            'TherapyArea__c','Is_this_IQVIA_Biotech__c','Line_of_Business__c','Owner.Region__c','Owner.User_Country__c','StageName'};
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opportunityId);
        Map<Id, Opportunity> oppMap = new SLT_Opportunity().getOpportunityById(new Set<Id>{opportunityId}, ligFieldSet);
        Opportunity tagetedOpportunity = oppMap.get(opportunityId);  
        List<String> errorMessageList = new List<String>();        
        if((recordTypeName =='Clinical' || recordTypeName == 'Clinical Bid') && tagetedOpportunity.StageName.substring(0,1) == '6'){
              errorMessageList.add(tagetedOpportunity.StageName.substring(0,1));
        }
        
        OWF_Config__c owfDefaultConfig = OWF_Config__c.getInstance();
        
        List<String> incompatibleLOBList1 = new List<String>();
        List<String> incompatibleLOBList2 = new List<String>();
        
        if(owfDefaultConfig.Incompatible_LOB_Set_1__c!=Null){
            incompatibleLOBList1 = owfDefaultConfig.Incompatible_LOB_Set_1__c.split(',');
        }
        if(owfDefaultConfig.Incompatible_LOB_Set_2__c!=Null){
            incompatibleLOBList2 = owfDefaultConfig.Incompatible_LOB_Set_2__c.split(',');
        }
        if(incompatibleLOBList1!=Null && incompatibleLOBList2!=Null){
            incompatibleLOBList1.addAll(incompatibleLOBList2);
        }
        
        String errorMessage1 = '';
        
        if(oppMap!=null && oppMap.size()>0)
        {
            if( (recordTypeName =='Clinical' || recordTypeName == 'Clinical Bid') && incompatibleLOBList1!=Null && incompatibleLOBList1.contains(tagetedOpportunity.Line_of_Business__c))
            {
                return new List<String>{'Not able to create a Clinical Bid with the current Line of Business selection\nPlease revise the Line of Business on Opportunity'};
            }
            else if((recordTypeName =='CSMS' || recordTypeName == 'CSMS Bid'))
            {
                if(tagetedOpportunity.Line_of_Business__c != 'Commercial Solutions'){
                    return new List<String>{'Not able to create a CSMS Bid with the current Line of Business selection\nPlease revise the Line of Business on Opportunity'};
                }
                else
                {
                    Set<String> productCodeFieldSet = new Set<String>{'ProductCode'};
                    List<String> productCodeList = new List<String>();     
                    Map<Id, OpportunityLineItem> oppLineItemMap = new SLT_OpportunityLineItems().selectByOpportunityId(new Set<Id>{opportunityId},productCodeFieldSet);   
                    for(OpportunityLineItem oppLineItem : oppLineItemMap.values())
                    {
                        productCodeList.add(oppLineItem.ProductCode);   
                    }
                    if(!productCodeList.contains('CES_1062A_CS1') && !productCodeList.contains('Q_100047') 
                       && !productCodeList.contains('CES_1842A') && !productCodeList.contains('CES_1841A')){
                           return new List<String>{'Not able to create a CSMS Bid with the current list of Products bound with Opportunity'};
                       }								
                    
                    if(tagetedOpportunity.Owner.Region__c == null || tagetedOpportunity.Owner.Region__c != 'Asia Pacific'){
                        return new List<String>{'Not able to create a CSMS Bid with the current Opportunity Owner\'s Region / Country'};
                    }       									
                    
                    else If(tagetedOpportunity.Owner.Region__c == 'Asia Pacific' 
                            && (tagetedOpportunity.Owner.User_Country__c == Null || tagetedOpportunity.Owner.User_Country__c == 'Japan' || tagetedOpportunity.Owner.User_Country__c == 'India' || 
                                tagetedOpportunity.Owner.User_Country__c == 'Australia')){
                                    return new List<String>{'Not able to create a CSMS Bid with the current Opportunity owner\'s Region / Country'}; 
                                }										
                    
                    
                }
                return new List<String>();
            }
            //IQVIAPSA-5186 Validation to create GCC only when LOB=specific set  for -- Start
            if( (recordTypeName =='GCC' ) && !(CON_OWF.GCC_LOB_SET.contains(tagetedOpportunity.Line_of_Business__c)) ){
                return new List<String>{'An incorrect LOB is selected when attempting to create a GCC Bid'};
            }
            //IQVIAPSA-5186 Validation to create GCC only when LOB=specific set  -- End
            
            //IQVIAPSA-4538 Validation to create OCT RFx only when LOB=Clinical technology -- Start
            if( (recordTypeName =='OCT RFx' || recordTypeName == 'OCT RFx Bid') && !(CON_OWF.OCT_RFx_LOB_SET.contains(tagetedOpportunity.Line_of_Business__c)) ){
                return new List<String>{'Line of Business must equal Clinical Technology to create an OCT RFX record.'};
            }
            //IQVIAPSA-4538 Validation to create OCT RFx only when LOB=Clinical technology -- End
            if((recordTypeName == CON_OWF.RECORD_TYPE_CSS || recordTypeName == CON_OWF.RECORD_TYPE_CSS_BID ) && !(CON_OWF.CSS_LOB_SET.contains(tagetedOpportunity.Line_of_Business__c))){
                return new List<String>{'Not able to create a IQVIA Technologies Bid with the current Line of Business selection\nPlease revise the Line of Business on Opportunity'};
                    }
            if(tagetedOpportunity.Indication_List__c == null){
                errorMessage1 = errorMessage1 + 'Indication' + '\n';
            }
            
            if(tagetedOpportunity.Verbatim_Indication_Term__c == null && (tagetedOpportunity.Line_of_Business__c != 'Outcome' || tagetedOpportunity.Line_of_Business__c != CON_OWF.LINE_OF_BUSINESS_RWLP)){
                errorMessage1 = errorMessage1 + 'Verbatim Indication Term' + '\n';
            }
            
            if(tagetedOpportunity.Drug_Product_Name__c == null){
                errorMessage1 = errorMessage1 + 'Drug Classification' + '\n';
            }
            
            if(tagetedOpportunity.Phase_P__c == null){
                errorMessage1 = errorMessage1 + 'Phase' + '\n';
            }
            
            if(tagetedOpportunity.FSP__c == null){
                errorMessage1 = errorMessage1 + 'FSP' + '\n';
            }
            
            if(tagetedOpportunity.Global_project_unit__c == null) {   
                errorMessage1 = errorMessage1 + 'Global Project Unit' + '\n';
            }
            
            if(tagetedOpportunity.FPI_Date__c  == null){
                errorMessage1 = errorMessage1 + 'FPI Date' + '\n';
            }
            
            if(tagetedOpportunity.Population_Age_Group__c == null){
                errorMessage1 = errorMessage1 + 'Population Age Group' + '\n';
            }
            
            if(tagetedOpportunity.TherapyArea__c == null){  
                errorMessage1 = errorMessage1 + 'Therapy Area' + '\n';
            }
            
            if(tagetedOpportunity.Is_this_IQVIA_Biotech__c == null){
                errorMessage1 = errorMessage1 + 'Is this IQVIA Biotech' + '\n';
            }
            
            if(errorMessage1 !='')
            {
                errorMessage1 = 'Required fields in Opportunity: \n' + errorMessage1;
                errorMessageList.add(errorMessage1);
            }
            
            return errorMessageList;            
        }
        
        return new List<String>();
    }
    public static List<String> validateLQOppForBidHistory(Id opportunityId, String recordTypeName)
    { 
        Set<String> ligFieldSet = new Set<String>{'Line_of_Business__c','Identified_Business__c','Q2_Budget_Tool__c'};
        Map<Id, Opportunity> oppMap = new SLT_Opportunity().getOpportunityById(new Set<Id>{opportunityId}, ligFieldSet);
        if(oppMap!=null && oppMap.size()>0){
            Opportunity tagetedOpportunity = oppMap.get(opportunityId);  
            if(!(CON_OWF.Q2_SOLUTION_LOB_SET.contains(tagetedOpportunity.Line_of_Business__c))){
                return new List<String>{'Not able to create Q2 Solutions Bid with current Line of Business selection\nPlease revise the Line of Business on Opportunity'};
            }
            if((CON_OWF.Q2_SOLUTION_LOB_SET.contains(tagetedOpportunity.Line_of_Business__c)) && (tagetedOpportunity.Q2_Budget_Tool__c == CON_OWF.BUDGET_TOOL_Q2_BIO || tagetedOpportunity.Q2_Budget_Tool__c == CON_OWF.BUDGET_TOOL_VACCINES ||CON_OWF.DISCOVERY_BUDGET_TOOLS_LIST.contains(tagetedOpportunity.Q2_Budget_Tool__c)) && String.isBlank(tagetedOpportunity.Identified_Business__c)) {
                return new List<String>{'Not able to create Q2 Solutions Bid as the Identified Business is not having any value selected. Please review the Identified Business on opportunity'};     
            }
        }    
       return new List<String>();
    }

    public static Map<Id, Quote__c> getLastAcceptedQuote(Set<Id> relatedOpportunityIdSet){
        Map<Id, Quote__c> latestAcceptedQuote= new  Map<Id,Quote__c>();
        String condition = 'Related_Opportunity__c IN : relatedOpportunityIdSet  AND Approval_Stage__c = ' + '\'' + CON_CPQ.ACCEPTED + '\'';
        List<Quote__c> quotes = new SLT_IQVIA_Quote().getQuotesByConditionOrderByAcceptedDate(new Set<String>{CON_CPQ.ID,CON_CPQ.CONVERSION_RATE,'Related_Opportunity__c',CON_CPQ.TOTAL_NET_AMOUNT,'Approval_Stage__c'}, condition, CON_CPQ.ACCEPTED_DATE, CON_CPQ.SORT_DESC, relatedOpportunityIdSet);
            for(Quote__c quote : quotes){
                if(!latestAcceptedQuote.containskey(quote.Related_Opportunity__c)){
                    latestAcceptedQuote.put(quote.Related_Opportunity__c , quote);
                } 
                
            }
        return latestAcceptedQuote;
    }
    public static  Map<String, Map<Id,Quote__c>> getLastAcceptedAndFinalizeQuote(Set<Id> relatedOpportunityIdSet){
        Map<Id, Quote__c> latestAcceptedQuote = new  Map<Id,Quote__c>();
        Map<Id,Quote__c> latestFinializeQuote =  new  Map<Id,Quote__c>();
        Map<String, Map<Id,Quote__c>> approvalStageToQuoteMap =  new Map<String, Map<Id,Quote__c>>();
        String condition = 'Related_Opportunity__c IN : relatedOpportunityIdSet  AND (Approval_Stage__c = ' + '\'' + CON_CPQ.ACCEPTED + '\'OR(Approval_Stage__c = ' + '\'' + CON_CPQ.APPROVED + '\'AND Primary__c = TRUE))';
        List<Quote__c> quotes = new SLT_IQVIA_Quote().getQuotesByConditionOrderByAcceptedDate(new Set<String>{CON_CPQ.ID,CON_CPQ.CONVERSION_RATE,'Related_Opportunity__c',CON_CPQ.TOTAL_NET_AMOUNT,'Approval_Stage__c'}, condition, CON_CPQ.ACCEPTED_DATE, CON_CPQ.SORT_DESC, relatedOpportunityIdSet);
        for(Quote__c quote : quotes){
            if(quote.Approval_Stage__c== CON_CPQ.APPROVED &&(!latestFinializeQuote.containskey(quote.Related_Opportunity__c) )){
                latestFinializeQuote.put(quote.Related_Opportunity__c , quote);
            }
            else if(quote.Approval_Stage__c== CON_CPQ.ACCEPTED &&!latestAcceptedQuote.containskey(quote.Related_Opportunity__c) ){
                latestAcceptedQuote.put(quote.Related_Opportunity__c , quote); 
            }
         }
        approvalStageToQuoteMap.put(CON_CPQ.APPROVED,latestFinializeQuote);
        approvalStageToQuoteMap.put(CON_CPQ.ACCEPTED,latestAcceptedQuote);        
        return approvalStageToQuoteMap;
    }
    
    public static Decimal getConversionQuoteTotalNetAmount(String OppCurrency , Quote__c latestAcceptedQuote){
        Decimal convertedTotalNetAmount ; 
        if(OppCurrency != latestAcceptedQuote.CurrencyIsoCode && OppCurrency == CON_CPQ.USD){
            convertedTotalNetAmount = latestAcceptedQuote.TotalNetAmount__c/latestAcceptedQuote.Conversion_Rate__c;
        }
        else{
            convertedTotalNetAmount = latestAcceptedQuote.TotalNetAmount__c;
        }
        return convertedTotalNetAmount;
    }
    
    public static Integer findNoOfDays_exclude_weekend(Date startDate,Date endDate, Integer numOfHolidays) {
        
        Decimal noOfDays    = (5*(Math.FLOOR(DATE.newInstance(1900,1,8).daysBetween(endDate)/7)) + Math.MIN( 5, Math.MOD(DATE.newInstance(1900,1,8).daysBetween(endDate),7) ))  - (5 * ( Math.FLOOR( DATE.newInstance( 1900, 1, 8).daysBetween(startDate)/ 7 )) + Math.MIN( 5, Math.MOD(DATE.newInstance(1900,1,8).daysBetween(startDate), 7  ) ) ) ;
        Boolean isWeekend   = (Math.MOD(DATE.newInstance(1900,1,6).daysBetween(endDate),7) == 0 || Math.MOD(DATE.newInstance(1900,1,6).daysBetween(endDate),7) == 1) ? true : false;
        
        //add an extra day if it doesn't end on a weekend
        noOfDays = !isweekend ? noOfDays += 1 : noOfDays;
        noOfDays -= numOfHolidays;
        
        return (Integer)noOfDays;
    }
    
        
        
        public static String redirectUserOnRTSelection(String recordTypeId)
        {
             if(recordTypeId != null)
            {
                
                String name = String.valueOf(Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName());
                Map<String, APTS_Agreement_New_button_Override__c> recordTypeToRedirectMap = new Map<String,APTS_Agreement_New_button_Override__c>();
                
                recordTypeToRedirectMap = APTS_Agreement_New_button_Override__c.getAll();
                //system.debug(recordTypeToRedirectMap);
                if(recordTypeToRedirectMap.keySet().contains(name)){
                    return recordTypeToRedirectMap.get(name).Redirect__c;
                }
            }
            
            return 'Not Found';
        }
        
        public static String getGovernorLimits(String className)
        {
            String govLimitDebugs = 'OWF Context Governor Limit: className: ' + className+  
                '\nSOQL Limit:' +Limits.getQueries() +
                '\nHeap Limit:' +Limits.getHeapSize()+
                '\nCPU Limit:' +Limits.getCpuTime()+
                '\nEnd';
            //system.debug(govLimitDebugs);
            return govLimitDebugs;
        }
        
        public static void sendEmailByWorkflowEmailRecord(List<workflowEmailRecordWrapper> messageList){
            List<workflowEmailRecordWrapper> messages = new List<workflowEmailRecordWrapper>();
            
            for(workflowEmailRecordWrapper message : messageList){
                if((message.toEmails!=null && message.toEmails.size()>0) || (message.ccEmails!=null && message.ccEmails.size()>0)
                   || (message.toUserIds!=null && message.toUserIds.size()>0) || (message.ccUserIds!=null && message.ccUserIds.size()>0) ){
                       messages.add(message);
                   }
            }
            
            if(messages.size() == 0){
                return;
            }
            
            List<Workflow_Email_Record__c> workflowRecordList = new List<Workflow_Email_Record__c>();
            Workflow_Email_Record__c objWorkFlowEmail;
            String content = '';
            for(workflowEmailRecordWrapper message : messages){
                objWorkFlowEmail = new Workflow_Email_Record__c();
                objWorkFlowEmail.Email_Action__c = message.emailAction;
                content ='';
                if(message.ownerId != null){
                    objWorkFlowEmail.ownerId = message.ownerId;
                }
                if(message.staticContent!=null){
                    content = message.staticContent;
                    objWorkFlowEmail.Email_Subject__c = message.subject;
                }else{
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(message.templateId, message.targetObjectId, message.whatId);
                    content = email.getHTMLBody()!=null?email.getHTMLBody():email.getPlainTextBody();
                    objWorkFlowEmail.Email_Subject__c = email.getSubject();
                }
                
                if(content !=null && content.length() > EMAIL_ALERT_CONTENT_LENGTH){
                    objWorkFlowEmail.content_1__c = content.substring(0, EMAIL_ALERT_CONTENT_LENGTH);
                    objWorkFlowEmail.content_2__c = content.substring(EMAIL_ALERT_CONTENT_LENGTH, content.length());
                }else{
                    objWorkFlowEmail.content_1__c = content;
                }
                setWorkflowParameter(objWorkFlowEmail, message);
                workflowRecordList.add(objWorkFlowEmail);
            }
            
            try{
                insert workflowRecordList;
            }
            catch(Exception ex) {
                system.debug('workFlowException:::'+ex.getMessage());
            }
        }
        
        /**
* This method maps the properties from email object to objworkFlwoEmail object.
* @param objWorkFlowEmail Workflow_Email_Record__c
* @param message Messagewrapper
* @return void
*/
    public static void setWorkflowParameter(Workflow_Email_Record__c objWorkFlowEmail, workflowEmailRecordWrapper message){
        if(message.whatId != null && message.whatId != '') {
            objWorkFlowEmail.Related_To_Object_Id__c = message.whatId;
            Id objId = message.whatId;
            objWorkFlowEmail.Related_To_Object_Api__c = objId.getSObjectType().getDescribe().getName();
        }else if(message.targetObjectId != null && message.targetObjectId != ''){
            objWorkFlowEmail.Related_To_Object_Id__c = message.targetObjectId;
            Id objId = message.targetObjectId;
            objWorkFlowEmail.Related_To_Object_Api__c = objId.getSObjectType().getDescribe().getName();
        }
        
        objWorkFlowEmail.Module_Name__c = MODULE_NAME;
        
        List<Id> allUserIds = new List<Id>();
        List<Id> idsToInsert = new List<Id>(); // size() should not exceed #CON_OWF.MAX_USER_IDS_COUNT
        List<String> allEmails = new List<String>();
        
        if(message.toUserIds!=null && message.toUserIds.size()>0){
           allUserIds.addAll(message.toUserIds);
        }
        if(message.ccUserIds!=null && message.ccUserIds.size()>0){
            allUserIds.addAll(message.ccUserIds);
        }

        if(allUserIds.size() > CON_OWF.MAX_USER_IDS_COUNT){
            List<User> users = [Select Id, Email from User where IsActive = true AND Id in :allUserIds];
            for(Integer user = 0; user<users.size(); user++){
                if(user >= CON_OWF.MAX_USER_IDS_COUNT){
                    allEmails.add(users.get(user).Email);
                }else{
                    idsToInsert.add(users.get(user).Id);
                }
            }
        }else{
            idsToInsert =  allUserIds;
        }
        
        if(message.toEmails != null && message.toEmails.size() > 0) {
            allEmails.addAll(message.toEmails);
        }
        if(message.ccEmails != null && message.ccEmails.size() > 0) {
            allEmails.addAll(message.ccEmails);
        }
        
        Integer toEmailCounter = 1;
        Integer toUserCounter = 1;
        
        for(String userId: idsToInsert) {
            objWorkFlowEmail.put('To_User_'+toUserCounter+'__c', userId);
            toUserCounter++;
        }
        
        for(string email: allEmails) {
                objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', email);
                toEmailCounter++;
            if(toEmailCounter==(CON_OWF.MAX_EMAILS_COUNT+1)){
                break;
            }
        }
    }

    public static Map<Id, Set<Id>> calculateDaysOffForClinicalBidRR(Map<Id, Set<Id>> rrIdtoContactsIdMap) 
    {
        Map<Id, Set<Id>> rrIdToStatusMap = new Map<Id, Set<Id>>();
        Set<Id> contactIdsSet = new Set<Id>();
        Date minimumProjectStartDate;
        String minimumProjectStartDateStr;
        Integer totalNwtDays = 0;
        Integer nwtDaysPerAssignment = 0;
        Integer bidDays = 0;
        Double nwtPercentage;
        Map<Id,List<pse__Assignment__c>> contactIdToDaysOffAssignmentsMap = new Map<Id,List<pse__Assignment__c>>();
        for(Id rrId : rrIdtoContactsIdMap.keySet()){
            contactIdsSet.addAll(rrIdtoContactsIdMap.get(rrId));
        }
        Set<String> rrFieldSet = new Set<String>{'Id','pse__Start_Date__c','pse__End_Date__c','pse__Project__r.pse__Start_Date__c'};
        List<pse__Resource_Request__c> rrList = new SLT_Resource_Request(false,false).selectResReqsById(rrIdtoContactsIdMap.keySet(), rrFieldSet).values();
        if(rrList != null && rrList.size() > 0 && minimumProjectStartDate == Null){
            minimumProjectStartDate = rrList[0].pse__Project__r.pse__Start_Date__c;
        }
        for(pse__Resource_Request__c rr:rrList){
        	if(rr.pse__Project__r.pse__Start_Date__c < minimumProjectStartDate){
                minimumProjectStartDate = rr.pse__Project__r.pse__Start_Date__c;
            }
        }
        if(minimumProjectStartDate != null){
            minimumProjectStartDateStr = DateTime.newInstance(minimumProjectStartDate.addDays(-1), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        }
        
        String daysOffAssignmentCondition = 'pse__Resource__c in: sObjectIdset and Assignment_Type__c =\'Days Off\' and pse__Resource__r.Available_for_Triage_Flag__c = TRUE and pse__Status__c =\'Days Off - Approved\'  AND pse__End_Date__c >= ' + minimumProjectStartDateStr;
        Set<String> assignmentFieldSet = new Set<String>{'Id','pse__Start_Date__c','pse__End_Date__c','pse__Resource__r.Available_for_Triage_Flag__c','Assignment_Type__c','pse__Resource__c'};
        List<pse__Assignment__c> daysOffAssignmentList = new SLT_Assignment(false,false).getAssignmentByResource(contactIdsSet,daysOffAssignmentCondition,assignmentFieldSet);
        for(pse__Assignment__c daysOffAssignment: daysOffAssignmentList){
            if(!contactIdToDaysOffAssignmentsMap.containskey(daysOffAssignment.pse__Resource__c)){
                contactIdToDaysOffAssignmentsMap.put(daysOffAssignment.pse__Resource__c,new List<pse__Assignment__c>{daysOffAssignment});
            }else{
                    contactIdToDaysOffAssignmentsMap.get(daysOffAssignment.pse__Resource__c).add(daysOffAssignment);    
            }
        }
        
        for(pse__Resource_Request__c rrFromMapInstance:rrList)
        {
            bidDays = rrFromMapInstance.pse__Start_Date__c.daysBetween( rrFromMapInstance.pse__End_Date__c) + 1;        
            for(Id contactId : rrIdtoContactsIdMap.get(rrFromMapInstance.Id)){
                totalNwtDays = 0;
                nwtDaysPerAssignment = 0;
                if(!rrIdToStatusMap.containskey(rrFromMapInstance.Id) && contactIdToDaysOffAssignmentsMap.containsKey(contactId)){
                    for(pse__Assignment__c daysOffAssignment : contactIdToDaysOffAssignmentsMap.get(contactId))
                    {
                        if(daysOffAssignment.pse__Start_Date__c >= rrFromMapInstance.pse__Start_Date__c
                           && daysOffAssignment.pse__End_Date__c <= rrFromMapInstance.pse__End_Date__c){
                               nwtDaysPerAssignment = daysOffAssignment.pse__Start_Date__c.daysBetween(daysOffAssignment.pse__End_Date__c) + 1;        
                           }
                        else if(daysOffAssignment.pse__Start_Date__c <= rrFromMapInstance.pse__Start_Date__c
                                && daysOffAssignment.pse__End_Date__c >= rrFromMapInstance.pse__End_Date__c){
                                    nwtDaysPerAssignment = rrFromMapInstance.pse__Start_Date__c.daysBetween(rrFromMapInstance.pse__End_Date__c) + 1;
                                }
                        else if(daysOffAssignment.pse__Start_Date__c < rrFromMapInstance.pse__Start_Date__c
                                && daysOffAssignment.pse__End_Date__c <= rrFromMapInstance.pse__End_Date__c
                                && daysOffAssignment.pse__End_Date__c >= rrFromMapInstance.pse__Start_Date__c) {
                                    nwtDaysPerAssignment = rrFromMapInstance.pse__Start_Date__c.daysBetween(daysOffAssignment.pse__End_Date__c) + 1;                           
                                }
                        else if(daysOffAssignment.pse__Start_Date__c >= rrFromMapInstance.pse__Start_Date__c
                                && daysOffAssignment.pse__End_Date__c > rrFromMapInstance.pse__End_Date__c
                                && daysOffAssignment.pse__Start_Date__c < rrFromMapInstance.pse__End_Date__c) {  
                                    nwtDaysPerAssignment = daysOffAssignment.pse__Start_Date__c.daysBetween(rrFromMapInstance.pse__End_Date__c) + 1;                           
                                }
                        totalNwtDays += nwtDaysPerAssignment;   
                    }  
                    nwtPercentage = (totalNwtDays*100)/bidDays;
                    if(nwtPercentage <= 20){
                        rrIdToStatusMap.put(rrFromMapInstance.Id,new Set<Id>{contactId});  
                    }
                }
            }
        }
        return rrIdToStatusMap;
    }
    
    /**
* This method determines whether a given email id is valid or not.
* @param emailId String
* @return boolean
*/
    public static boolean isValidEmailId(String emailId) {
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(emailId);
        
        if (!emailMatcher.matches()){
            res = false;
        }
        return res;
    }

    public static List<pse__Resource_Request__c> createRRForContractPostAwardBid(Set<Id> bidHistoryIdsSet, Map<Id,pse__Proj__c> bidHistoryIdToProjectMap){
        List<pse__Resource_Request__c> resReqsToBeInserted = new List<pse__Resource_Request__c>();
        String bhrCondition = 'Id IN :sObjectIdSet And RecordTypeId = \'' + CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID + '\'';
        String resReqCondition = 'pse__Opportunity__c != NULL And SubGroup__c != NULL And Bid_History__c != NULL';
        Set<String> bhrFieldSet = new Set<String>{'Id', 'RFP_Ranking__c', 'Bid_History_Related_Opportunity__c','Agreement_Pathway__c',
            'Bid_History_Related_Opportunity__r.Phase_P__c', 'Bid_History_Related_Opportunity__r.Line_of_Business__c',
            'Bid_History_Related_Opportunity__r.Potential_Regions__c','Bid_History_Related_Opportunity__r.InterventionType__c',
            'Bid_History_Related_Opportunity__r.QI_Invited_to_Present__c', 'Bid_History_Related_Opportunity__r.Bid_Defense_Date__c',
            'Bid_History_Related_Opportunity__r.Amount','Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c','RecordTypeId', 'Requested_Agreement_Type__c', 
            'Bid_Due_Date__c', 'Requested_Services__c', 'Targeted_Countries__c', 'Budget_Deliverable__c', 'Bid_Number__c', 'Start_Date__c', 'CurrencyIsoCode','Is_there_a_Client_Bid_Grid__c','Grid_Ranking_Level__c',
            'Bid_History_Related_Opportunity__r.Rare_Disease__c','Bid_History_Related_Opportunity__r.Population_Age_Group__c','Estimated_Fees__c','Win_Probability__c','Opportunity_Type__c',
            'Bid_History_Related_Opportunity__r.Identified_Business__c','Additional_Services_Requested__c','Bid_History_Related_Opportunity__r.pse__Parent_Opportunity__c','Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c',
            'Bid_History_Related_Opportunity__r.Global_project_unit__c'};
        Set<String> resReqFieldSet = new Set<String>{'Id', 'Bid_History__r.RecordTypeId','pse__Opportunity__c', 'Bid_History__c', 'Is_Bid_Defense__c', 'pse__Project__c', 'SubGroup__c', 'Potential_Regions__c', 'pse__Start_Date__c', 'pse__End_Date__c','pse__Status__c','pse__Assignment__c','pse__Assignment__r.pse__Status__c', 'CurrencyIsoCode', 'pse__Staffer_Resource__c','Is_Created_Automatically__c','Suggested_FTE__c','Is_Created_Automatically_Initial_Bid__c','LeadSupportFlag__c', 'Regional_Analytics_Country__c'};
        Map<Id, Bid_History__c> bidHistoryByIdMap = new SLT_Bid_History(false,false).getAgreementAndResReqsByBidId(bidHistoryIdsSet, bhrFieldSet, resReqFieldSet, bhrCondition, resReqCondition);
        Map<Id, Set<String>>  bidHistoryToResourceRequestsSubgroupNameMap = new  Map<Id, Set<String>>();  
        for(Bid_History__c bhr : bidHistoryByIdMap.values()){
            for(pse__Resource_Request__c resReq : bhr.Bid_History_Resource_Requests__r){
                if(bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bhr.Id)){
                        bidHistoryToResourceRequestsSubgroupNameMap.get(bhr.Id).add(resReq.SubGroup__c);
                }
                else{
                    bidHistoryToResourceRequestsSubgroupNameMap.put(bhr.Id,new Set<String>{resReq.SubGroup__c});
                }
            }
        }
        List<String> requestedinternalServicesList;  
        Set<String> resourceRequestsSubgroupNameList = new Set<String>();
        for(Bid_History__c bidHistory : bidHistoryByIdMap.values()){
            requestedinternalServicesList = new List<String>();
            if(bidHistory.Requested_Services__c != null){
                requestedinternalServicesList.addAll(bidHistory.Requested_Services__c.split(';'));
            }
            resourceRequestsSubgroupNameList = bidHistoryToResourceRequestsSubgroupNameMap.get(bidHistory.Id);
            if(bidHistory.Agreement_Pathway__c != 'RBU'){
            // Criteria for DSB-LCS Post
            if(!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
               ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_LCS_POST))){
                   if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                      && (requestedinternalServicesList.size() > 0)
                      && ((bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_NO && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PHARMACOVIGILANCE_LIFECYCLE_SAFETY))
                          || (bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_SAFETY_PROCESSING)
                              && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_SAFETY_REPORTING)))
                      && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                          resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_LCS_POST));                                                                               
                      }
               }
            // Criteria for DSB-Clinical Post
            if(!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
               || (resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_CLINICAL_POST))) {
                   if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                      && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                          || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                      && bidHistory.Bid_Due_Date__c != NULL 
                      && (String.IsBlank(bidHistory.Bid_History_Related_Opportunity__r.Potential_Regions__c) 
                          || (String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Potential_Regions__c)
                              && bidHistory.Bid_History_Related_Opportunity__r.Potential_Regions__c != CON_OWF.POTENTIAL_REGION_JAPAN))
                      && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                                  resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory,bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_CLINICAL_POST));
                   }
               }
            
            //Criteria for DSB-CEVA Post
            if(!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
               || (resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_CEVA_POST))) {
                   if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                      && (requestedinternalServicesList.size() > 0)
                      && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_CEVA) 
                          || (requestedinternalServicesList.contains(CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING) && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PROJECT_MANAGEMENT))
                          || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_BIOSTATISTICAL)
                          || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_DATA_MANAGEMENT)
                          || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PHARMACOVIGILANCE_LIFECYCLE_SAFETY))
                      && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                          resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_CEVA_POST));                                                                               
                    }
               }
            // Criteria for DSB-DCT Post
            if(!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
               || (resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_DCT_POST))) {
                   if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                      && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL
                          || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                          ||(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL && bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES))
                      &&(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Potential_Regions__c))
                      &&(bidHistory.Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c == CON_OWF.VIRTUAL_TRIAL_STUDY_YES_FULLY_VIRTUAL
                         || bidHistory.Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c == CON_OWF.VIRTUAL_TRIAL_STUDY_YES_HYBRID)
                      && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                             resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_DCT_POST));
                    }
               }
            
            //Criteria for DSB-DM Post
            if(!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
               || (resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_DM_POST))) {
                   if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                      && (requestedinternalServicesList.size() > 0)
                      && ((bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_NO && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_DATA_MANAGEMENT) )
                          || (bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES && requestedinternalServicesList.contains('IQB Ongoing DM')))
                      && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                          resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_DM_POST));                                                                               
                    }
               }

            // Criteria for DSB-ISS Post
            if((!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_ISS_POST)))){
                if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                   && bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL
                   && bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES
                   && (requestedinternalServicesList.size() > 0
                       && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_ISSC)
                           && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_SITE_CONTRACTS)))
                   && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                       resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_ISS_POST));
                }
        	}
            
            // Criteria for GBO-Lead PD
            if((!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD)))){
                if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                   && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
				   || (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL && bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES)
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_PATIENT_AND_DCT_SOLUTIONS     
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
				   && (bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_ATP
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_SUWO
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_LOI)){
                       resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD));
                }
            }
            // Criteria for GBO-Lead Contracts Analyst
	        if((!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST)))){
                if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                   && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
				   || (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL && bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES)
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.OPP_LINE_OF_BUSINESS_CONNECTED_DEVICES
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL_TECHNOLOGY
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_PATIENT_AND_DCT_SOLUTIONS
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RDDS
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OTHER
                         || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CONSULTING
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
				   && (bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_GENRERAL_CONSULTING_AGREEMENT
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_GENRERAL_SERVICE_AGREEMENT_SMALL_PROJECT
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_GENRERAL_SERVICE_AGREEMENT
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_OTHER_AGREEMENT
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_NEW_CHANGE_ORDER
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_CNF
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_CHANGE_ORDER_BALLPARK
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_LRA
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_PRELIMINARY_AGREEMENT_AMENDMENT
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_WORK_ORDER
				   || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_LRA_AMENDMENT)){
                       resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST));
                }
            }
            // Criteria for DSB-RADDS Post
            if((!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_RADDS_POST)))){
                if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                   && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RDDS
                      || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                   && (requestedinternalServicesList.size() > 0
                       && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_RADDS_LCM_REGULATORY_OPERATION))
                   && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                       resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_RADDS_POST));
                }
        	}
            // Criteria for DSB-PM Post
            if((!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_PM_POST)))){
                if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                   && bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL
                   && bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES
                   && (requestedinternalServicesList.size() > 0
                       && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_PROJECT_MANAGEMENT))
                   && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                       resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_PM_POST));
                }
        	}
            // Criteria for DSB-RNPS Post
            if((!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_RNPS_POST)))){
                if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                   && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL
                       || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT 
                       || (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL && bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES))
				   && String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Potential_Regions__c)
                   && (bidHistory.Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c == CON_OWF.VIRTUAL_TRIAL_STUDY_YES_FULLY_VIRTUAL
                       ||bidHistory.Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c == CON_OWF.VIRTUAL_TRIAL_STUDY_YES_HYBRID ||
                       (requestedinternalServicesList.size() > 0 && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_RNPS)))
                   && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                       resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_RNPS_POST));
                }
        	}
            
            // Criteria for DSB-GSA Post
            if((!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_GSA_POST)))){
                if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                   && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT ||
                       (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL && bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_NO))
                   && (requestedinternalServicesList.size() > 0
                       && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_GSA_REGULATORY)
                           || (requestedinternalServicesList.contains(CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING) && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PROJECT_MANAGEMENT))
                           || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_GSA_SITE_ID_START_UP)))
                   && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                       resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_GSA_POST));
                }
        	}
            // Criteria for DSB-MW Post
            if((!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_MW_POST)))){
                if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                   && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
				   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                   || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                   && requestedinternalServicesList.size() > 0
                   && (((bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES &&requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_MEDICAL_WRITING))
                        || (bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_NO &&requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_MEDICAL_WRITING))))
                   && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                       resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_MW_POST));
                }
        	}
            //Criteria for DSB-Bios Post
            if(!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
               ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_BIOS_POST))) {
                if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                   && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                       ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
                       ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES
                       ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                   && (requestedinternalServicesList.size() > 0)
                   && ((bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_NO && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_BIOSTATISTICAL) )
                       || (bidHistory.Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c == CON_OWF.OWF_YES && requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_BIOSTATS)))
                   && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                             resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_BIOS_POST));
                }
            }
            //Criteria for DSB-PK/PD Post
            if(!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
               ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_PK_PD_POST))) {
                   if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                      && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO
                          ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_DATA_SCIENCES
                          || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_EARLY_CLINICAL_DEVELOPMENT
                          || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.OPP_LINE_OF_BUSINESS_CONNECTED_DEVICES
                          || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL_TECHNOLOGY
                          || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_PATIENT_AND_DCT_SOLUTIONS
                          || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RDDS
                          || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OTHER
                          || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                      && (requestedinternalServicesList.size() > 0
                          && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PPS) 
                              || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PK_SUPPORT_FOR_IND) 
                              || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_POPULATION_PK_PD) 
                              || requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_PK_SUPPORT_FOR_NDA_ECTD)))
                      && bidHistory.Bid_Due_Date__c >= system.today() 
                      && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                          resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_PK_PD_POST));
                      }
               }

                // Criteria for DSB-DDRS-POST 
                if(!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                    ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_DSB_DDRS_POST))) {
                        if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c) 
                           && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RDDS
                               ||bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL)
                           && (requestedinternalServicesList.size() > 0)
                           && (requestedinternalServicesList.contains(CON_OWF.REQUESTED_INTERNAL_SERVICES_RADDS_DDPRR))
                           && CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)){
                               resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_DSB_DDRS_POST));
                           }
                }

               //Criteria for IQVIA Tech
               if((!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                  ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_IQVIA_TECH)))){
                    if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c) && 
                        (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL ||
                        bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_SAFETY_AND_MED_INFO )
                        && String.IsNotBlank(bidHistory.Requested_Services__c) && bidHistory.Requested_Services__c.contains(CON_OWF.REQ_SER_SAFETY_TECH)
                        && String.IsNotBlank(bidHistory.Requested_Agreement_Type__c) && (
                        CON_OWF.BID_HISTORY_REQUESTED_AGREEMENT_TYPE_SET.contains(bidHistory.Requested_Agreement_Type__c)
                        )) {
                            resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_IQVIA_TECH));
                           }
                    }
            }
            else {
                // Criteria for GBO-Lead Contracts Analyst for RBU Pathway
                if((!bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                    ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST)))){
                        if(String.IsNotBlank(bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c)
                           && (bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OUTCOME
                               || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_RWLP
                               || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CONSULTING
                               || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_OTHER
                               || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_MEDICAL_AFFAIRS
                               || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_HEALTH_ENGAGEMENT_COMMUNICATION)
                           && (bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_GENRERAL_CONSULTING_AGREEMENT
                               || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_GENRERAL_SERVICE_AGREEMENT_SMALL_PROJECT
                               || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_GENRERAL_SERVICE_AGREEMENT
                               || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_NEW_CHANGE_ORDER
                               || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_PRELIMINARY_AGREEMENT_AMENDMENT
                               || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_WORK_ORDER
                               || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_SUWO
                               || bidHistory.Requested_Agreement_Type__c == CON_OWF.REQUESTED_AGREEMENT_TYPE_ATP)){
                                   resReqsToBeInserted.add(createResourceRequestByContractPostAwardAgreement(bidHistory, bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST));
                    }
                }
            }
        }
        return resReqsToBeInserted;
     }
    private static pse__Resource_Request__c createResourceRequestByContractPostAwardAgreement(Bid_History__c bhr, Map<Id,pse__Proj__c> bidHistoryIdToProjectMap, String subGroup){
        pse__Resource_Request__c resRequest = new pse__Resource_Request__c();
        resRequest.recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
        resRequest.pse__Opportunity__c = bhr.Bid_History_Related_Opportunity__c;
        resRequest.Bid_History__c = bhr.Id;
        if(bidHistoryIdToProjectMap.containsKey(bhr.Id)) {
            resRequest.pse__Project__c  = bidHistoryIdToProjectMap.get(bhr.Id).Id;
            resRequest.pse__Group__c = bidHistoryIdToProjectMap.get(bhr.Id).pse__Group__c;
        }
        resRequest.SubGroup__c  = subGroup;
        resRequest.pse__Start_Date__c = bhr.Start_Date__c;
        resRequest.pse__End_Date__c = bhr.Bid_Due_Date__c;
        resRequest.pse__SOW_Hours__c = 0.01;
        resRequest.CurrencyIsoCode = bhr.CurrencyIsoCode;
        resRequest.Is_Created_Automatically_Initial_Bid__c = true;
        resRequest.Is_Created_Automatically__c = true;
        return resRequest;
    }
    public static List<pse__Resource_Request__c> createRRForCSSBid(Set<Id> bidHistoryIdsSet, Map<Id,pse__Proj__c> bidHistoryIdToProjectMap){
        List<pse__Resource_Request__c> resReqsToBeInserted = new List<pse__Resource_Request__c>();
        String bhrCondition = 'Id IN :sObjectIdSet And RecordTypeId = \'' + CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        String resReqCondition = 'pse__Opportunity__c != NULL And SubGroup__c != NULL And Bid_History__c != NULL';
        Set<String> bhrFieldSet = new Set<String>{'Id','Bid_History_Related_Opportunity__r.Line_of_Business__c','Connected_Devices__c','Bid_Due_Date__c','Start_Date__c','CurrencyIsoCode'};
        Set<String> resReqFieldSet = new Set<String>{'Id', 'Bid_History__r.RecordTypeId','pse__Opportunity__c', 'Bid_History__c', 'SubGroup__c', 'Is_Created_Automatically__c','Suggested_FTE__c','Is_Created_Automatically_Initial_Bid__c'};
                    Map<Id, Bid_History__c> bidHistoryByIdMap = new SLT_Bid_History(false,false).getAgreementAndResReqsByBidId(bidHistoryIdsSet, bhrFieldSet, resReqFieldSet, bhrCondition, resReqCondition);
        Map<Id, Set<String>>  bidHistoryToResourceRequestsSubgroupNameMap = new  Map<Id, Set<String>>();  
        for(Bid_History__c bhr : bidHistoryByIdMap.values()){
            for(pse__Resource_Request__c resReq : bhr.Bid_History_Resource_Requests__r){
                if(bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bhr.Id)){
                    bidHistoryToResourceRequestsSubgroupNameMap.get(bhr.Id).add(resReq.SubGroup__c);
                }
                else{
                    bidHistoryToResourceRequestsSubgroupNameMap.put(bhr.Id,new Set<String>{resReq.SubGroup__c});
                }
            }
        }
        Set<String> resourceRequestsSubgroupNameList = new Set<String>();
        for(Bid_History__c bidHistory : bidHistoryByIdMap.values()){
            resourceRequestsSubgroupNameList = bidHistoryToResourceRequestsSubgroupNameMap.get(bidHistory.Id);
                if((bidHistoryToResourceRequestsSubgroupNameMap != null && !bidHistoryToResourceRequestsSubgroupNameMap.containsKey(bidHistory.Id) 
                    ||(resourceRequestsSubgroupNameList != null && !resourceRequestsSubgroupNameList.contains(CON_OWF.RES_REQ_TYPE_CONNECTED_DEVICES_PD)))){
                    if((bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.LINE_OF_BUSINESS_CLINICAL_TECHNOLOGY
                       || bidHistory.Bid_History_Related_Opportunity__r.Line_of_Business__c == CON_OWF.OPP_LINE_OF_BUSINESS_CONNECTED_DEVICES)
                       && bidHistory.Bid_Due_Date__c >= system.today() && bidHistory.Connected_Devices__c){
                           resReqsToBeInserted.add(createResourceRequestByCSSBid(bidHistory,bidHistoryIdToProjectMap, CON_OWF.RES_REQ_TYPE_CONNECTED_DEVICES_PD));
                       }
                }
        }
        return resReqsToBeInserted;
    }
    private static pse__Resource_Request__c createResourceRequestByCSSBid(Bid_History__c bhr,Map<Id,pse__Proj__c> bidHistoryIdToProjectMap, String subGroup){
        pse__Resource_Request__c resRequest = new pse__Resource_Request__c();
        resRequest.recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
        resRequest.pse__Opportunity__c = bhr.Bid_History_Related_Opportunity__c;
        resRequest.Bid_History__c = bhr.Id;
        if(bidHistoryIdToProjectMap.containsKey(bhr.Id)) {
            resRequest.pse__Project__c  = bidHistoryIdToProjectMap.get(bhr.Id).Id;
            resRequest.pse__Group__c = bidHistoryIdToProjectMap.get(bhr.Id).pse__Group__c;
        }
        resRequest.SubGroup__c  = subGroup;
        resRequest.pse__Start_Date__c = bhr.Start_Date__c;
        resRequest.pse__End_Date__c = bhr.Bid_Due_Date__c;
        resRequest.pse__SOW_Hours__c = 0.01;
        resRequest.CurrencyIsoCode = bhr.CurrencyIsoCode;
        resRequest.Is_Created_Automatically_Initial_Bid__c = true;
        resRequest.Is_Created_Automatically__c = true;
        return resRequest;
    }
    public static  pse__Schedule__c createScheduleFromResourceRequest(pse__Resource_Request__c rr){
        pse__Schedule__c objSchedule = new pse__Schedule__c();
        objSchedule.pse__Start_Date__c = (rr.pse__End_Date__c < Date.today() || rr.pse__Start_Date__c > Date.today()) ? rr.pse__Start_Date__c : Date.today();
        objSchedule.pse__End_Date__c = rr.pse__End_Date__c;
        objSchedule.pse__Monday_Hours__c = 0;
        objSchedule.pse__Tuesday_Hours__c = 0;
        objSchedule.pse__Wednesday_Hours__c = 0;
        objSchedule.pse__Thursday_Hours__c = 0;
        objSchedule.pse__Friday_Hours__c = 0;
        objSchedule.pse__Saturday_Hours__c = 0;
        objSchedule.pse__Sunday_Hours__c = 0;
        objSchedule.pse__Scheduled_Hours__c = 0;
        return objSchedule;
    }
    
    public static String updateContractPostAwardbidFromOtherObject(List<BidHistoryWrapper> bidWrapperList){
        List<Bid_History__c> bidHistoriesToBeUpdated = new List<Bid_History__c>();
        Set<Id> bidIdSet = new Set<Id>();
        for(BidHistoryWrapper bid : bidWrapperList){
            bidIdSet.add(bid.bidHistoryId);
        }
        Set<String> bidFieldSet = new Set<String>{'Id','Record_Type_Developer_Name__c'};
        Map<Id,Bid_History__c> bidHistoryMap = new SLT_Bid_History().getBidHistoriesById(bidIdSet,bidFieldSet);
        For(ID bidID:bidHistoryMap.keySet()){
            if(bidHistoryMap.get(bidID).Record_Type_Developer_Name__c != 'Contract_Post_Award'){
                return 'Selected Bid with id '+bidID+' is not of Contract Post Award';
            }
        }
        for(BidHistoryWrapper bid : bidWrapperList){
            if(bid.SObjectName == 'Apttus__APTS_Agreement__c'){
                if(bid.statusCategory == CON_OWF.OWF_STATUS_CANCELLED){
                    bidUpdatedFromAgreement = true;
                    bidHistoriesToBeUpdated.add(new Bid_History__c(id = bid.bidHistoryId,Bid_Due_Date__c = System.today()));
                }
                else{
                    bidUpdatedFromAgreement = true;
                    bidHistoriesToBeUpdated.add(new Bid_History__c(id = bid.bidHistoryId,Bid_Due_Date__c = bid.agreementPlannedExecutionDate));
                }
            }
            else if(bid.SObjectName == 'Quote'){
                bidUpdatedFromAgreement = true;
                bidHistoriesToBeUpdated.add(new Bid_History__c(id = bid.bidHistoryId,Bid_Due_Date__c = bid.plannedExecutionDate));
            }
            else if(bid.SObjectName == 'Apttus_Proposal__Proposal__c'){
                bidUpdatedFromAgreement = true;
                bidHistoriesToBeUpdated.add(new Bid_History__c(id = bid.bidHistoryId,Bid_Due_Date__c = bid.CNFApprovalDate));
            }
            
            if(!bidHistoriesToBeUpdated.isEmpty()){
                update bidHistoriesToBeUpdated;
            }
        }
        return 'Records updated successfully';
    }
    
    public static Map<Id,Date> getAnalystStartDateforAgreement(Set<Id> bidHistoryIds){
        Map<Id,Date> bidIdtoRRStartDateMap = new Map<Id,Date>();
        Set<String> bidHistoryFieldSet = new Set<String>{'Id'};
        Set<String> resourceRequestFieldSet = new Set<String>{'pse__Start_Date__c','pse__Status__c','SubGroup__c'};
        String resourceRequestCondition = 'pse__Status__c =\''+CON_OWF.OWF_STATUS_ASSIGNED+'\' AND (SubGroup__c =\'' +CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD+'\' OR SubGroup__c =\''+CON_OWF.RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST+'\')'+' and pse__Assignment__c!= null and pse__Assignment__r.pse__Status__c =\''+CON_OWF.OWF_STATUS_ACCEPTED+'\'';
        Map<Id,Bid_History__c> bidIdtoBidMap = new SLT_Bid_History().selectByIdWithBidsResReqsAssignments(bidHistoryIds,bidHistoryFieldSet,resourceRequestFieldSet,resourceRequestCondition);
        for(Id bidId:bidHistoryIds){
            if(!bidIdtoBidMap.get(bidId).Bid_History_Resource_Requests__r.isEmpty()){
                bidIdtoRRStartDateMap.put(bidId,bidIdtoBidMap.get(bidId).Bid_History_Resource_Requests__r[0].pse__Start_Date__c);
            }
        }
        return bidIdtoRRStartDateMap;
        
    }
    public static Date addBusinessDays(Date startDate,Integer businessDays){
        Integer daysAdded = 0;
        Integer fullWeeks = businessDays / 5;
        Integer extraDays = Math.mod(businessDays,5);
        Date endDate = startDate.addDays(fullWeeks * 7);
        while(extraDays > 0){
            endDate = endDate.addDays(1);
            if(DateTime.newInstance(endDate, Time.newInstance(0, 0, 0, 0)).format('EEEE') != 'Saturday' && DateTime.newInstance(endDate, Time.newInstance(0, 0, 0, 0)).format('EEEE') != 'Sunday'){
                extraDays--;
            } 
        }
        return endDate;
    }
    
    public static Date subtractBusinessDays(Date startDate, Integer daysToSubtract) {
        Integer daysSubtracted = 0;
        Date currentDate = startDate;    
        while (daysSubtracted < daysToSubtract) {
            currentDate = currentDate.addDays(-1);
            String dayName = DateTime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0)).format('EEEE');
            if (dayName != 'Saturday' && dayName != 'Sunday') {
                daysSubtracted++;
            }
        }
        return currentDate;
    }
    
    public static List<Timezone__c> fetchTimezone(String moduleName, String batchName){
        DateTime currentTime = System.now();
        List<Timezone__c> timeZoneList = [Select id,Module__c,OffSet__c, Name, CutOffUTCTime__c  from Timezone__c where (CutOffUTCTime__c <= : currentTime ) and
                                          Module__c =: moduleName and Batch_Name__c =: batchName ];
        return timeZoneList;
    }
    
    public static Map<String,List<String>> createTimezoneMap(List<Timezone__c> timeZoneList){
        Map<String,List<String>> eligibleTimeZones = new Map<String,List<String>>();
        String currentDate = '';
        for(Timezone__c timezone : timeZoneList){
             currentDate = (timezone.CutOffUTCTime__c.addMinutes(Integer.valueOf(60*timezone.OffSet__c))).formatGMT('yyyy-MM-dd');
            if(eligibleTimeZones.containsKey(currentDate)){
                 eligibleTimeZones.get(currentDate).add(timezone.Name);
            }
            else{
                eligibleTimeZones.put(currentDate,new List<String>{timezone.Name});
            }
        }
        return eligibleTimeZones;
    }
    
    public class workflowEmailRecordWrapper{
        public List<String> toEmails{get; set;}
        public List<String> ccEmails{get; set;}
        public List<String> toUserIds{get; set;}
        public List<String> ccUserIds{get; set;}
        public String templateId{get; set;}
        public String whatId{get; set;}
        public String subject{get; set;}
        public String staticContent{get; set;}
        public String targetObjectId{get; set;}
        public boolean isTargetObjectAsRecipient{get; set;}
        public String emailAction{get; set;}
        public id ownerId{get;set;}
    }
    
}
