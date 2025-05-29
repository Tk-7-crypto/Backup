public class DAOH_COE_Quality_Check {
    public static void checkOverallCompliance(List<CSM_QI_Tech_COE_QualityCheck__c> qualityRecordList){
        for(CSM_QI_Tech_COE_QualityCheck__c qualityRecordObj : qualityRecordList){
            if(qualityRecordObj.Overall_Compliance__c != null){
                qualityRecordObj.Case_Checked__c = true;
            }
            else if(qualityRecordObj.Overall_Compliance__c == null){
                    qualityRecordObj.Case_Checked__c = false;
                }
            if(qualityRecordObj.Overall_Compliance__c == 'C' || qualityRecordObj.Overall_Compliance__c == 'CWF'){
                qualityRecordObj.Case_Compliant__c = true; 
            }
            else if(qualityRecordObj.Overall_Compliance__c == null || qualityRecordObj.Overall_Compliance__c == 'NC' ){
                    qualityRecordObj.Case_Compliant__c = false;
                }
        }
    }
    
    public static void UpdateFromCaseFields(List<CSM_QI_Tech_COE_QualityCheck__c> qualityRecordList){
        set<Id> caseIds = new Set<Id>();
        Map<Id,Id> mapFormCase = new Map<Id,Id>();
        Map<Id, Case> caseMap = new Map<Id,Case>();
        for(CSM_QI_Tech_COE_QualityCheck__c qualityRecordObj : qualityRecordList){
            if(qualityRecordObj.Form_Request_Type__c == 'FCR Quality Check'){
                mapFormCase.put(qualityRecordObj.Id,qualityRecordObj.Case__c);
                caseIds.add(qualityRecordObj.Case__c);                
            } 
        }
        if( caseIds != null && !caseIds.isEmpty()){
            caseMap = new Map<Id,Case>([SELECT ID, First_Escalated_By__c FROM CASE WHERE ID in : caseIds]);
            if(caseMap!= null && !caseMap.isEmpty()){
                for(CSM_QI_Tech_COE_QualityCheck__c qualityRecordObj : qualityRecordList){
                    if(caseMap.containsKey(mapFormCase.get(qualityRecordObj.Id)) && caseMap.get(mapFormCase.get(qualityRecordObj.Id)) != null && qualityRecordObj.First_Escalated_by__c == null){
                            qualityRecordObj.First_Escalated_by__c= caseMap.get(mapFormCase.get(qualityRecordObj.Id)).First_Escalated_by__c;
                    }
                }
            }
        }
    }
    
    public static void AddCSATAnswers(List<CSM_QI_Tech_COE_QualityCheck__c> qualityRecordList){
        CSM_case_Trigger_Handler__c csmCustomsetting = CSM_case_Trigger_Handler__c.getOrgDefaults();
        set<Id> caseIds =  new set<Id>();
        for(CSM_QI_Tech_COE_QualityCheck__c qualityRecordObj : qualityRecordList){
            if(qualityRecordObj.Form_Request_Type__c == 'CSAT Quality Check'){
                caseIds.add(qualityRecordObj.Case__c);                
            } 
        }
        
        LIST<CSAT_Responses__c> answers = [SELECT Case__c,Question__c,ANSWER__C FROM CSAT_Responses__c  where Case__C in : caseIds ];
        
        string soslFindClause = csmCustomsetting.CSAT_Quality_Check_Question_1__c + ' OR ' + csmCustomsetting.CSAT_Quality_Check_Question_2__c;   
        if(caseIds != null && !caseIds.IsEmpty() && answers.size() > 0){
            /*List<List<SObject>> lstObject = [FIND :soslFindClause IN ALL FIELDS
                                             RETURNING CSAT_Responses__c(Case__c, Question__c,Answer__c where Case__c in : caseIds)];
            List<CSAT_Responses__c> csatResponses = (List<CSAT_Responses__c>)lstObject[0];*/
            Map<Id, List<CSAT_Responses__c>> lstResponse = PopulateQuestionsAnswers(answers,csmCustomsetting);
            
            for(CSM_QI_Tech_COE_QualityCheck__c qualityRecordObj : qualityRecordList){
                if(lstResponse.containsKey(qualityRecordObj.Case__c)){
                    for(CSAT_Responses__c response : lstResponse.get(qualityRecordObj.Case__c)){
                        if(response.Question__c == csmCustomsetting.CSAT_Quality_Check_Question_1__c){
                            qualityRecordObj.Agreed__c = (response.Answer__c == '1') ? 'Yes' : (response.Answer__c == '0') ? 'No' : (response.Answer__c == null)?'Not Applicable':null;
                        }
                        if(response.Question__c == csmCustomsetting.CSAT_Quality_Check_Question_2__c){
                            qualityRecordObj.CSAT_overall_satisfaction__c = (response.Answer__c == null) ?'Not Applicable': response.Answer__c;
                        }
                        if(response.Question__c == csmCustomSetting.CSAT_Quality_Check_Question_3__c){
                            qualityRecordObj.CSAT_Comments__c = (response.Answer__c == null)?'Not Applicable':response.Answer__c;
                        }
                    }
                }
            }
        }
    }
    
    public static Map<Id, List<CSAT_Responses__c>>  PopulateQuestionsAnswers(List<CSAT_Responses__c> csatResponses, CSM_case_Trigger_Handler__c csmCustomsetting){
        Map<Id, List<CSAT_Responses__c>> mapToReturn = new Map<Id,List<CSAT_Responses__c>>();
        for(CSAT_Responses__c res : csatResponses){
            
            if(mapToReturn.containsKey(res.Case__c)){
                mapToReturn.get(res.Case__c).Add(res); 
            }
            else{
                mapToReturn.put(res.Case__c,new List<CSAT_Responses__c>{res});
            }
            
        }
        return mapToReturn;
    }
    
    public static void UpdateCaseFields(List<CSM_QI_Tech_COE_QualityCheck__c> qualityRecordList){
        set<Id> caseIds = new Set<Id>();
        set<Id> userIds = new Set<Id>();
        map<Id,string> mapReviewEscalation= new map<id,string>();
        map<Id,Id> mapIRTCaseUserId = new map<Id,Id>();
        map<Id,Id> mapCSATCaseUserId = new map<Id,Id>();
        map<Id,string> mapUserIdName = new map<Id,String>();
        for(CSM_QI_Tech_COE_QualityCheck__c qualityRecordObj : qualityRecordList){
            if(qualityRecordObj.Form_Request_Type__c =='IRT Quality Check' ||qualityRecordObj.Form_Request_Type__c =='FCR Quality Check' || qualityRecordObj.Form_Request_Type__c == 'CSAT Quality Check' ){
                caseIds.Add(qualityRecordObj.Case__c);
                userIds.Add(qualityRecordObj.CreatedById);
                if(qualityRecordObj.FCR_Review_Escalation_Lst__c!= null){
                    mapReviewEscalation.put(qualityRecordObj.Case__c,qualityRecordObj.FCR_Review_Escalation_Lst__c + '::'+qualityRecordObj.CreatedById);
                }
                if(qualityRecordObj.Form_Request_Type__c == 'IRT Quality Check'){
                    mapIRTCaseUserId.put(qualityRecordObj.Case__c,qualityRecordObj.CreatedById);
                }
                if(qualityRecordObj.Form_Request_Type__c == 'CSAT Quality Check'){
                    mapCSATCaseUserId.put(qualityRecordObj.Case__c,qualityRecordObj.CreatedById);
                }
            }
        }
        if( caseIds != null && !caseIds.isEmpty()){
            List<Case> caseToUpdate = new List<Case>();
            List<Case> cases = [SELECT ID, SLA_IRT_Reviewed__c,SLA_IRT_Reviewed_By__c,FCR_Review_Escalation__c,CSAT_Reviewed__c,CSAT_Reviewed_by__c From Case where Id in : caseIds];
            if(userIds != null && !userIds.isEmpty()){
                List<User> users = [SELECT Id,Name from User where Id in : userIds limit 1];
                for(User u : users){
                    if(!mapUserIdName.containsKey(u.Id)){
                        mapUserIdName.put(u.Id,u.Name  + ', ' +  DateTime.now().format('dd/MM/yyyy hh:mm'));
                    }
                }
                if(mapIRTCaseUserId !=null && !mapIRTCaseUserId.isEmpty()){
                    for(Case c : cases){
                        if(c.SLA_IRT_Reviewed__c == false && c.SLA_IRT_Reviewed_By__c == null){
                            if(mapIRTCaseUserId.containsKey(c.Id) && mapUserIdName.containsKey(mapIRTCaseUserId.get(c.Id))){
                                c.SLA_IRT_Reviewed_By__c = mapUserIdName.get(mapIRTCaseUserId.get(c.Id)); 
                                c.SLA_IRT_Reviewed__c = true;                           
                            }
                            caseToUpdate.add(c);
                        }
                    }
                }
                if(mapReviewEscalation !=null && !mapReviewEscalation.isEmpty()){
                    for(Case c : cases){
                        if(mapReviewEscalation.containsKey(c.id) && c.FCR_Review_Escalation__c == null 
                           && mapReviewEscalation.containsKey(c.Id) && mapUserIdName.containsKey(mapReviewEscalation.get(c.id).substringAfter('::'))){
                               c.FCR_Review_Escalation__c = mapReviewEscalation.get(c.id).substringBefore('::');
                               //c.SLA_FCR_Reviewed__c  = true;
                               c.SLA_FCR_Reviewed_By__c = mapUserIdName.get(mapReviewEscalation.get(c.id).substringAfter('::'));
                               caseToUpdate.add(c);
                           }
                    }
                }
                if(mapCSATCaseUserId!= null && !mapCSATCaseUserId.isEmpty()){
                    for(Case c : cases){
                        if(c.CSAT_Reviewed__c == false && c.CSAT_Reviewed_by__c == null){
                            if(mapCSATCaseUserId.containsKey(c.Id) && mapUserIdName.containsKey(mapCSATCaseUserId.get(c.Id)) ){
                                c.CSAT_Reviewed_by__c = mapUserIdName.get(mapCSATCaseUserId.get(c.Id));
                                c.CSAT_Reviewed__c = true;
                            }
                            caseToUpdate.add(c);
                        }
                    }
                }
                
                if(caseToUpdate != Null && !caseToUpdate.isEmpty())
                    update caseToUpdate;
            }
            
            if(caseToUpdate != Null && !caseToUpdate.isEmpty())
                update caseToUpdate;
        }
    }
}
