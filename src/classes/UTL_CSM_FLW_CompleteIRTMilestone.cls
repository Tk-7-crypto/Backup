public class UTL_CSM_FLW_CompleteIRTMilestone {
    public class RequestEmailMessage{
        @InvocableVariable
        public EmailMessage emailMessage;
        
        @InvocableVariable
        public Id caseId;
    }
    
    @InvocableMethod(label = 'Update Case and IRTMilestone' description = 'Update the Case and IRT Case Milstone Comlete')
    public static void completeIRTMilestoneOutboundEmail(List<RequestEmailMessage> request){
        List<Id> RDCaseId = new List<Id>();
        List<Id> technoCaseId = new List<Id>();
        boolean InitialResonseProdOpps = false;
        List<Id> technoCaseIdProd = new List<Id>();
        Map<Id,Case> JsonCases = new Map<Id,Case>();
        Map<Id,String> jsonEmail = new Map<Id,String>();
        List<Activity__c> activityList = new List<Activity__c>();
        Set<Id> caseIds = new Set<Id>();
        Map<Id,EmailMessage> emMap = new Map<Id,EmailMessage>();
        Map<Id,boolean> initialMap = new Map<Id,boolean>();
        Map<String,String> milestoneMap = new Map<String,String>();
        String external = null;
        List<String> milestoneList = new List<String>{CON_CSM.S_COMMUNICATION_UPD,CON_CSM.S_FIRST_RESPONSE_T,CON_CSM.S_PRODOPS_INITIAL_RESPONSE};
        if(request != null && !request.isEmpty()){
            caseIds.add(request[0].caseId);
            if(request[0].emailMessage != null && request[0].emailMessage.HtmlBody != null && request[0].emailMessage.HtmlBody.contains('Problem Statement:')){
                milestoneList.add(CON_CSM.S_RESOLUTION_PLAN);
            }
        }
        List<Case> caseList = new SLT_Case().selectById(caseIds);
        if(caseIds != null && !caseIds.isEmpty()){
            UTL_CSM_SendMail.updateEmailMessageMail('Outgoing Email',caseList,null);
            emMap.put(request[0].emailMessage.ParentId,request[0].emailMessage);
            for(Case cs : caseList){
                if((cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || cs.RecordTypeName__c == CON_CSM.S_DATACASE || cs.RecordTypeName__c == CON_CSM.S_RDCASE)){
                    initialMap.put(cs.id, false);
                }
            }
            if(!initialMap.isEmpty()){
                for(CaseMilestone cm : [select Id,caseId,completionDate,MilestoneType.Name from CaseMilestone where caseId in :initialMap.keySet() and MilestoneType.Name in :milestoneList and completionDate = null]){
                    initialMap.put(cm.caseId, true);
                    milestoneMap.put(cm.caseId +'~'+cm.MilestoneType.Name, cm.MilestoneType.Name);
                }    
            }
            for(Case cs : caseList){
                external = '';
                if(cs.RecordTypeName__c == CON_CSM.S_R_D_CTP){
                    cs.Mail_CC_List__c = request[0].emailMessage.CcAddress;
                }
                if(cs.RecordTypeName__c == CON_CSM.S_DATACreateService){
                    cs.Owner__c = 'EmailQuickAction';
                }
                if(CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c && (CON_CSM.S_EMAIL == cs.Origin || CON_CSM.S_CUSTOMER_PORTAL == cs.Origin) && string.valueOf(cs.OwnerId).startsWith(CON_CSM.S_QUEUE_ID) && CON_CSM.S_NEW == cs.Status){
                    cs.Status = CON_CSM.S_IN_PROGRESS;
                }
                if(cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T && cs.template__c == CON_CSM.S_R_D_DATABASE_LOCK){
                    if (cs.SlaExitDate == null && cs.Subject.indexOf(CON_CSM.S_R_D_DATABASE_LOCK)!= -1){
                        RDCaseId.add(cs.id);
                    }      
                }
                if(cs.EntitlementId != null && initialMap.containsKey(cs.Id) && (CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c || CON_CSM.S_DATACASE == cs.RecordTypeName__c || cs.RecordTypeName__c == CON_CSM.S_RDCASE)){
                    DateTime completionDate = System.now();
                    if (((cs.SlaStartDate <= completionDate) && (cs.SlaExitDate == null))){
                        if(Test.isRunningTest() || ((milestoneList.contains(CON_CSM.S_RESOLUTION_PLAN) || milestoneList.contains(CON_CSM.S_COMMUNICATION_UPD)) && (milestoneMap.containsKey(cs.Id +'~'+CON_CSM.S_COMMUNICATION_UPD) || milestoneMap.containsKey(cs.Id +'~'+CON_CSM.S_RESOLUTION_PLAN)))){
                                if(cs.TaskMilestone__c != null && !cs.TaskMilestone__c.contains(CON_CSM.S_RESOLUTION_PLAN)){
                                    cs.TaskMilestone__c += ';' + CON_CSM.S_RESOLUTION_PLAN_PROVID;
                                }else if(cs.TaskMilestone__c == null){
                                    cs.TaskMilestone__c = CON_CSM.S_RESOLUTION_PLAN_PROVID;
                                }
                                if(cs.TaskMilestone__c != null && !cs.TaskMilestone__c.contains(CON_CSM.S_COMMUNICATION_UPD)){
                                    cs.TaskMilestone__c += ';' + CON_CSM.S_COMMUNICATION_UPD;
                                }else if(cs.TaskMilestone__c == null){
                                    cs.TaskMilestone__c = CON_CSM.S_COMMUNICATION_UPD;
                                }
                                technoCaseId.add(cs.Id);
                        }
                        if(cs.TaskMilestone__c != null && !cs.TaskMilestone__c.contains(CON_CSM.S_FIRST_RESPONSE_T)){
                            cs.TaskMilestone__c += ';' + CON_CSM.S_FIRST_RESPONSE_T;
                            technoCaseId.add(cs.Id);
                        }else if(cs.TaskMilestone__c == null){
                            cs.TaskMilestone__c = CON_CSM.S_FIRST_RESPONSE_T; 
                            technoCaseId.add(cs.Id);
                        }else{
                            technoCaseId.add(cs.Id);
                        } 
                    }
                }else if(CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c){
                    technoCaseIdProd.add(cs.Id);
                    InitialResonseProdOpps = true;
                }
                
                if(emMap != null && emMap.containsKey(cs.Id) && (cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE)){
                    activityList.add(DAOH_Emailmessage.createRndActivity(cs, false, false,emMap.get(cs.Id)));
                }
                /*CSM-1246 Moved updateCaseOnOutboundMail() code here*/
                if(cs.First_response_email_time__c == null){
                    if(cs.RecordTypeName__c == CON_CSM.S_DATACASE){
                        cs.First_response_email_time__c = Datetime.now();
                    }
                    cs.First_response_sent__c = True;
                }
                if(cs.NumberOfNotifications__c == null) {
                    cs.NumberOfNotifications__c = 1;
                }else{
                    cs.NumberOfNotifications__c += 1;
                }
                if(cs.Service_Now_Incident_Number__c != null && (cs.External_System_Type__c == CON_CSM.S_ROCHE_SN || cs.ServiceNowSystemType__c == CON_CSM.S_BISM || cs.ServiceNowSystemType__c == CON_CSM.S_IQVIA)){
                    JsonCases.put(cs.Id, cs);
                    external = cs.External_System_Type__c;
                    if(emMap!= null && emMap.containsKey(cs.Id)){
                        jsonEmail.put(cs.Id,emMap.get(cs.Id).TextBody);
                    }
                }
            }
        }
        if(caseList != null && !caseList.isEmpty()){
            update caseList;
        }
        if(!technoCaseId.isEmpty()){
            DateTime completionDate = System.now();
            SRV_CSM_AssignPermissionSet.completeMilestone(technoCaseId, milestoneList, completionDate);
        }else if(!technoCaseIdProd.isEmpty() && InitialResonseProdOpps){
            DateTime completionDate = System.now();
            SRV_CSM_AssignPermissionSet.completeMilestone(technoCaseIdProd, new List<String>{CON_CSM.S_PRODOPS_INITIAL_RESPONSE}, completionDate);
        }
        
        if(!RDCaseId.isEmpty()){
            DateTime completionDate = System.now();
            SRV_CSM_AssignPermissionSet.completeMilestone(RDCaseId, new List<String>{CON_CSM.S_R_D_DATABASE_LOCK} , completionDate);
        }
        if(external != null && !JsonCases.isEmpty() && !jsonEmail.isEmpty() && !System.isBatch() && !System.isFuture()){
            CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues(external);
            if(ecc != null && UserInfo.getUserId() != ecc.Profile_Id__c){
                if(ecc.Name == CON_CSM.S_BISM){
                    WSC_CSM_BISMSOAPCallout.ActivityUpdateCSM2BISMCommentsSendEmail(JSON.serialize(JsonCases) ,JSON.serialize(jsonEmail));    
                }else if(ecc.Name == CON_CSM.S_ROCHE_SN){
                    WSC_CSM_ROCHERestCallout.addIncidentComment(Json.serialize(JsonCases),Json.serialize(jsonEmail),'Email');
                }
                
            }    
        }
        if(!activityList.isEmpty()){
            SRV_CSM_AssignPermissionSet.createActivityFromEmailMessage(JSON.serialize(activityList));   
        }
    }
    
}