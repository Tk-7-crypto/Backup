/**
 * @description       : 
 * @author            : mallikarjuna.reddyb@iqvia.com
 * @group             : 
 * @last modified on  : 11-18-2022
 * @last modified by  : mallikarjuna.reddyb@iqvia.com
**/
public without sharing class DAOH_CaseComment {
    
    public static void updateStatusforLogAWorkNoteonCase(List<CaseComment> newList){
        List<Case> updateCase = new List<Case>();
        Map<Id,String> caseIds = new Map<Id,String>();
        boolean InitialResonseProdOpps = false;
        List<Id> technoCaseId = new List<Id>();
        List<Id> technoCaseIdProd = new List<Id>();
        List<Id> dataCaseOla = new List<Id>();
        List<Case> caseList = null;
        List<Case> ccMailCs = new List<Case>();
        Id userId = UserInfo.getProfileId();
        map<Id, CaseComment> mapOfCaseIdAndComment = new Map<Id, CaseComment>();
        Map<Id,Case> jscaseIds = new Map<Id,Case>();
        Map<Id,CaseComment> jscomments = new Map<Id,CaseComment>();
        String caseId = null;
        Set<Id> tcaseIds = new Set<Id>();
        List<String> statusList = CON_CSM.S_C_TECH_STATUS;
        String name = UserInfo.getName();
        String extSysType = null;
        Map<String,String> milestoneMap = new Map<String,String>();
		
        Set<Id> caseIdsOOO = new Set<Id>();
        Map<Id, Id> caseOwnerMap = new Map<Id, Id>();
        Map<Id, Id> queueCaseMap = new Map<Id, Id>();
        Set<Id> oooCurrentQueueIds = new Set<Id>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for (CaseComment cc : newList) {
            if (cc.ParentId != null) {
                caseIdsOOO.add(cc.ParentId);
            }
        }
        if (!caseIdsOOO.isEmpty()) {
            for (Case c : [SELECT Id, OwnerId, ContactId, ContactEmail, Origin,CurrentQueue__c FROM Case WHERE Id IN :caseIdsOOO]) {
                if(c.Origin == 'Partner Portal' && String.valueOf(c.ownerId).startsWith('005')) {
                caseOwnerMap.put(c.Id, c.OwnerId);
                } else if (c.Origin == 'Partner Portal' && String.valueOf(c.OwnerId).startsWith('00G')) {
                    queueCaseMap.put(c.Id, c.OwnerId);
                }
                if (c.CurrentQueue__c != null) {
                    oooCurrentQueueIds.add(c.CurrentQueue__c);
                }
            }
        }
        Set<Id> oooUserIds = new Set<Id>();
        Map<Id, String> oooMessages = new Map<Id, String>();
        if (!caseOwnerMap.isEmpty()) {
            for (OutOfOffice ooo : [SELECT UserId, Message FROM OutOfOffice WHERE UserId IN :caseOwnerMap.values()]) {
                oooUserIds.add(ooo.UserId);
                oooMessages.put(ooo.UserId, ooo.Message);
            }
        }
        Set<Id> oooQueueIds = new Set<Id>();
        if (!queueCaseMap.isEmpty()) {
            for (Queue_User_Relationship__c qurByGroupId : [SELECT Id,Group_Id__c,Business_Hours__c FROM Queue_User_Relationship__c WHERE Group_Id__c IN :queueCaseMap.values() AND Out_Of_Office_Notification__c = True]) {
                if (!BusinessHours.isWithin(qurByGroupId.Business_Hours__c, DateTime.now())) {
                    oooQueueIds.add(qurByGroupId.Group_Id__c);
                }
            }
        }
        Set<Id> oooQueuesFromCurrentQueue = new Set<Id>();
        if (!oooCurrentQueueIds.isEmpty()) {
            for (Queue_User_Relationship__c qurById : [SELECT Id,Group_Id__c,Business_Hours__c FROM Queue_User_Relationship__c WHERE Id IN :oooCurrentQueueIds AND Out_Of_Office_Notification__c = True]) {
                if (!BusinessHours.isWithin(qurById.Business_Hours__c, DateTime.now())) {
                    oooQueuesFromCurrentQueue.add(qurById.Id);
                }
            }
        }
        
        CSM_Case_Details_Global_Setting__c noReply = CSM_Case_Details_Global_Setting__c.getValues('Org Wide No-Reply PEP');
        CSM_Case_Details_Global_Setting__c tempPRM = CSM_Case_Details_Global_Setting__c.getValues('ET TECH EN PRM OOO Queue Message');
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, ContactEmail, ContactId,CurrentQueue__c FROM Case WHERE Id IN :caseOwnerMap.keySet() OR Id IN :queueCaseMap.keySet()]);
        for (Id caseIdOOO : caseMap.keySet()) {
            Case c = caseMap.get(caseIdOOO);
            Id ownerId = caseOwnerMap.containsKey(caseIdOOO) ? caseOwnerMap.get(caseIdOOO) : queueCaseMap.get(caseIdOOO);
            if ((oooUserIds.contains(ownerId) || oooQueueIds.contains(ownerId) || oooQueuesFromCurrentQueue.contains(c.CurrentQueue__c)) && c.ContactEmail != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{c.ContactEmail});
                email.setSaveAsActivity(false);
                email.setTemplateId(tempPRM.Component_Id__c);
                email.setTargetObjectId(c.ContactId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setWhatId(c.Id);
                email.setReferences(Cases.generateThreadingMessageId(c.Id));
                if (noReply != null && noReply.Component_Id__c != null && noReply.Component_Id__c.length() > 0) {
                    email.setOrgWideEmailAddressId(noReply.Component_Id__c);
                }
                emailsToSend.add(email);
            }
        }
        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend);
            } catch (Exception ex) {
                System.debug('Mail Exception: ' + ex.getMessage());
            }
        }
        List<String> milestoneList = new List<String>{CON_CSM.S_COMMUNICATION_UPD,CON_CSM.S_FIRST_RESPONSE_T,CON_CSM.S_PRODOPS_INITIAL_RESPONSE};
        for(CaseComment c : newList) {
            if(c.ParentId != null) {
                caseIds.put(c.ParentId,c.CommentBody);
                mapOfCaseIdAndComment.put(c.ParentId, c);
            }
        }
        if(!caseIds.isEmpty()){
            UTL_CSM_SendMail.updateCaseCommentMail(caseIds);
            caseList = new SLT_Case().selectAllById(caseIds.keySet()); 
            boolean checkUpdate = false;
            Map<Id,boolean> initialMap = new Map<Id,boolean>();
            for(Case cs : caseList){
                if((cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || cs.RecordTypeName__c == CON_CSM.S_DATACASE)){
                    initialMap.put(cs.id, false);
                    if(caseIds.containsKey(cs.Id) && caseIds.get(cs.Id) != null && caseIds.get(cs.Id).contains('Problem Statement:')){
                        milestoneList.add(CON_CSM.S_RESOLUTION_PLAN);
                    }
                }
            }
            if(!initialMap.isEmpty()){
                for(CaseMilestone cm : [select Id,caseId,completionDate,MilestoneType.Name from CaseMilestone where caseId in :initialMap.keySet() and MilestoneType.Name in :milestoneList and completionDate = null]){
                    initialMap.put(cm.caseId, true);
                    milestoneMap.put(cm.caseId +'~'+cm.MilestoneType.Name, cm.MilestoneType.Name);
                }    
            }
            for(Case cs : caseList){
                CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues(cs.External_System_Type__c);
                checkUpdate = false;
                if(ecc != null && UserInfo.getUserId() != ecc.Profile_Id__c && cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && cs.Service_Now_Incident_Number__c != null && mapOfCaseIdAndComment.get(cs.Id).IsPublished && !mapOfCaseIdAndComment.get(cs.Id).CommentBody.startsWith(CON_CSM.S_Case_Description)){
                    if(cs.External_System_Type__c == CON_CSM.S_ROCHE_SN){
                        jscaseIds.put(cs.Id,cs);
                        jscomments.put(cs.Id,mapOfCaseIdAndComment.get(cs.Id));
                        extSysType = CON_CSM.S_ROCHE_SN;
                    }else if((cs.ServiceNowSystemType__c == CON_CSM.S_BISM || cs.ServiceNowSystemType__c == CON_CSM.S_IQVIA)){
                        jscaseIds.put(cs.Id,cs);
                        jscomments.put(cs.Id,mapOfCaseIdAndComment.get(cs.Id));
                        extSysType = CON_CSM.S_BISM;
                    }
                }
                if(CON_CSM.S_BISM_PUB_CC != caseIds.get(cs.Id) && CON_CSM.S_BISM_CLCC != caseIds.get(cs.Id) && CON_CSM.S_BISM_CC != caseIds.get(cs.Id)){
                    if(String.isNotBlank(mapOfCaseIdAndComment.get(cs.Id).CommentBody) && !mapOfCaseIdAndComment.get(cs.Id).CommentBody.startsWith(CON_CSM.S_Case_Description)) {
                        if(mapOfCaseIdAndComment.get(cs.Id).IsPublished && (cs.RecordTypeName__c == CON_CSM.S_DATACASE ||  cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T) && (CON_PEP.S_PARTNER_PORTAL == cs.Origin)){
                            cs.LastCaseComment__c = caseIds.get(cs.Id);
                            checkUpdate = true;
                            cs.NewCaseComment__c = true;
                            ccMailCs.add(cs);
                        }else{
                            checkUpdate = true;
                            cs.NewCaseComment__c = false;
                        }
                        if(caseIds.get(cs.Id) != null && !caseIds.get(cs.Id).startsWith(CON_CSM.S_Case_Description)){
                            cs.LastCaseComment__c = caseIds.get(cs.Id);
                        }
                        if(cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && (CON_CSM.S_EMAIL == cs.Origin || CON_CSM.S_CUSTOMER_PORTAL == cs.Origin) && string.valueOf(cs.OwnerId).startsWith(CON_CSM.S_QUEUE_ID) && CON_CSM.S_NEW == cs.Status){
                            if(cs.LastCaseComment__c != null && !cs.LastCaseComment__c.startsWith(CON_CSM.S_Case_Description)){
                                cs.Status = CON_CSM.S_IN_PROGRESS;
                                checkUpdate = true;
                            }
                        }
                        if(cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && CON_CSM.S_CLOSED != cs.Status && (UserInfo.getUserType().contains('CustomerSuccess') || (cs.Status == CON_CSM.S_RESOLVED_WITH_C || (cs.Status == CON_CSM.S_AWAITING && (cs.SubStatus__c == CON_CSM.S_SS_CI || cs.SubStatus__c == CON_CSM.S_CUSTOMER_CONFIRMATION_CLOSE)) &&  UserInfo.getName() == 'ROCHE CSM API User' && cs.External_System_Type__c == CON_CSM.S_ROCHE_SN))){
                            if(cs.LastCaseComment__c != null && !cs.LastCaseComment__c.startsWith(CON_CSM.S_Case_Description)){
                                cs.Status = CON_CSM.S_IN_PROGRESS;
                                cs.SubStatus__c = CON_CSM.S_RESPONSE_RECEIVED;
                                checkUpdate = true;
                            }
                        }
                        if((cs.RecordTypeName__c == CON_CSM.S_RDCASE || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_R_D_CTP || cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || cs.RecordTypeName__c == CON_CSM.S_R_D_V_T) && !cs.IsClosed && cs.Service_Now_Incident_Number__c != null){
                            if(cs.LastCaseComment__c != null && UserInfo.getName() == 'Integration ServiceNow'){
                                cs.Status = CON_CSM.S_IN_PROGRESS;
                                cs.SubStatus__c = CON_CSM.S_RESPONSE_RECEIVED;
                                checkUpdate = true;
                            }
                        }
                        if(mapOfCaseIdAndComment.get(cs.Id).IsPublished && ((CON_CSM.S_CUSTOMER_PORTAL == cs.Origin && cs.RecordTypeName__c == CON_CSM.S_DATACASE) || cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T)){
                            cs.NewCaseComment__c = true;
                            if(cs.LastCaseComment__c != null && cs.LastCaseComment__c.startsWith('ServiceNow Comment')){
                                List<String> ccList = cs.LastCaseComment__c.split('--');
                                for(String snc : ccList){
                                    if(!snc.startsWith('ServiceNow Comment')){
                                        cs.LastCaseComment__c = snc;
                                    }
                                }
                            }

                            if(cs.LastCaseComment__c != null && !cs.LastCaseComment__c.startsWith(CON_CSM.S_Case_Description)){
                                if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) ){
                                    cs.Owner__c = UserInfo.getUserType();    
                                    checkUpdate = true;
                                    ccMailCs.add(cs);
                                }else{
                                    cs.Owner__c = UserInfo.getUserId();
                                    checkUpdate = true;
                                    if(UserInfo.getUserId() == cs.OwnerId || UserInfo.getName() == 'Integration ServiceNow'){
                                        ccMailCs.add(cs);
                                    }
                                }    
                            }
                            
                        }else{
                            checkUpdate = true;
                            cs.NewCaseComment__c = false;
                        }
                        if(mapOfCaseIdAndComment.get(cs.Id).IsPublished && CON_CSM.S_DATACASE == cs.RecordTypeName__c && (CON_CSM.S_O_ES == cs.Origin || CON_CSM.S_EMAIL == cs.Origin || CON_CSM.S_CUSTOMER_PORTAL == cs.Origin) && !UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)){
                            dataCaseOla.add(cs.Id);
                        }
                        //if((cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || cs.RecordTypeName__c == CON_CSM.S_DATACASE ) && ((cs.EntitlementId != null && cs.Entitlement.Type == 'TECH Dashboard & Reports') || cs.ProductName__c  == CON_CSM.S_TDR || (mapOfCaseIdAndComment.get(cs.Id).IsPublished && (CON_CSM.S_O_ES == cs.Origin || CON_CSM.S_EMAIL == cs.Origin || CON_CSM.S_CUSTOMER_PORTAL == cs.Origin))) && !UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)){
                        if(cs.EntitlementId != null && initialMap.containsKey(cs.Id) && (cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || cs.RecordTypeName__c == CON_CSM.S_DATACASE ) && (cs.Entitlement.Type == 'TECH Dashboard & Reports' || cs.ProductName__c  == CON_CSM.S_TDR || mapOfCaseIdAndComment.get(cs.Id).IsPublished) && !UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)){
                            DateTime completionDate = System.now();
                            if (((cs.SlaStartDate <= completionDate) && (cs.SlaExitDate == null))){
                                if((milestoneList.contains(CON_CSM.S_RESOLUTION_PLAN) || milestoneList.contains(CON_CSM.S_COMMUNICATION_UPD)) && (milestoneMap.containsKey(cs.Id +'~'+CON_CSM.S_COMMUNICATION_UPD) || milestoneMap.containsKey(cs.Id +'~'+CON_CSM.S_RESOLUTION_PLAN))){
                                    if(cs.TaskMilestone__c != null && !cs.TaskMilestone__c.contains(CON_CSM.S_RESOLUTION_PLAN)){
                                        cs.TaskMilestone__c += ';' + CON_CSM.S_RESOLUTION_PLAN_PROVID;
                                        checkUpdate = true;
                                    }else if(cs.TaskMilestone__c == null){
                                        cs.TaskMilestone__c = CON_CSM.S_RESOLUTION_PLAN_PROVID;
                                        checkUpdate = true;
                                    }
                                    if(cs.TaskMilestone__c != null && !cs.TaskMilestone__c.contains(CON_CSM.S_COMMUNICATION_UPD)){
                                        cs.TaskMilestone__c += ';' + CON_CSM.S_COMMUNICATION_UPD;
                                        checkUpdate = true;
                                    }else if(cs.TaskMilestone__c == null){
                                        cs.TaskMilestone__c = CON_CSM.S_COMMUNICATION_UPD;
                                        checkUpdate = true;
                                    }
                                    technoCaseId.add(cs.Id);
                                }
                                if(cs.TaskMilestone__c != null && !cs.TaskMilestone__c.contains(CON_CSM.S_FIRST_RESPONSE_T+';')){
                                    cs.TaskMilestone__c += ';' + CON_CSM.S_FIRST_RESPONSE_T;
                                    checkUpdate = true;
                                    technoCaseId.add(cs.Id);
                                }else if(cs.TaskMilestone__c == null){
                                    cs.TaskMilestone__c = CON_CSM.S_FIRST_RESPONSE_T; 
                                    checkUpdate = true;
                                    technoCaseId.add(cs.Id);
                                }else{
                                    technoCaseId.add(cs.Id);
                                }  
                            }
                        }else if(cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && !UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)){
                            technoCaseIdProd.add(cs.Id);
                            InitialResonseProdOpps = true;
                            checkUpdate = true;
                        }
                    }
                    if(cs.status == CON_CSM.S_AWAITING && cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) && mapOfCaseIdAndComment.get(cs.Id).CreatedDate <= System.now()) {
                        checkUpdate = true;
                        cs.status = CON_CSM.S_IN_PROGRESS;
                        cs.SubStatus__c = '';
                    }
                    if(CON_CSM.S_ALLOWED_RT_TIMESHEET.contains(cs.RecordTypeName__c) && !(name == CON_CSM.S_SYSTEM || name == CON_CSM.S_CSM_ADMIN  || UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || name == 'Integration ServiceNow' || name =='BISM CSM API User')){
                        tcaseIds.add(cs.Id);
                        if(!statusList.contains(cs.Status) || cs.Status == CON_CSM.S_RESOLVED_WITH_C){
                            caseId = cs.Id;
                        }
                    }
                    if(checkUpdate){
                        updateCase.add(cs);
                    }
                }
            }
            
            Map<Id,String> mapS = null;
            if(!technoCaseId.isEmpty()){
                mapS = completeOLA(technoCaseId);
            }else if(!technoCaseIdProd.isEmpty() && InitialResonseProdOpps){
                mapS = completeOLA(technoCaseIdProd); 
            }
            if(!dataCaseOla.isEmpty()){
               mapS = completeOLA(dataCaseOla);  
            }
            if(mapS != null && !mapS.isEmpty()){
                for(Case cc : updateCase){
                    if(mapS.containsKey(cc.Id)){
                      cc.OLA_Elapsedtime__c  = mapS.get(cc.Id);
                    } 
                }
            }
            if(!jscaseIds.isEmpty() && !System.isFuture() && !System.isBatch()){
                if(extSysType == CON_CSM.S_BISM){
                    WSC_CSM_BISMSOAPCallout.ActivityUpdateCSM2BISMComments(Json.serialize(jscaseIds),Json.serialize(jscomments));     
                }else if(extSysType == CON_CSM.S_ROCHE_SN){
                    WSC_CSM_ROCHERestCallout.addIncidentComment(Json.serialize(jscaseIds),Json.serialize(jscomments),'CaseComment');
                }
               
            }
            if(!updateCase.isEmpty()){
                try{
                    update updateCase;
                    if(!ccMailCs.isEmpty()){
                        sendCaseCommentCCEmails(updateCase);
                    }
                    if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)){
                        sendLatestCommenttoDataCaseOriginator(updateCase);
                    }
                }catch (DmlException e) {
                    System.debug('Failed due to : '+e);
                }
                
            }
            
            if(!technoCaseId.isEmpty() && !System.isFuture() && !System.isBatch()){
                SRV_CSM_AssignPermissionSet.completeMilestone(technoCaseId, milestoneList, System.now()); 
            }else if(!technoCaseIdProd.isEmpty() && InitialResonseProdOpps && !System.isFuture() && !System.isBatch()){
                SRV_CSM_AssignPermissionSet.completeMilestone(technoCaseIdProd, new List<String>{CON_CSM.S_PRODOPS_INITIAL_RESPONSE}, System.now());
            }
            if(tcaseIds != null && !tcaseIds.isEmpty() && !System.isBatch() && !System.isFuture()){
              DAOH_Case.stopTechAutoTimer(tcaseIds,caseId,'Log a Call added');
            }
        }
    }

    /* Added by Saurabh */
    
    public static boolean isCSMccEmailsHaveSent = false;
    public static void sendCaseCommentCCEmails(List<Case> newList){
        if(!isCSMccEmailsHaveSent) {
            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
            Boolean result = true;
            List<String> toAddresses;
            Pattern patt = null;
            Matcher match = null;
            List<Messaging.SingleEmailMessage> ccSendEmailList = new List<Messaging.SingleEmailMessage>();
            for(Case cs : newList){
                if(cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T){
                    toAddresses = new List<String>();
                    if(cs.Mail_CC_List__c != null && cs.Mail_CC_List__c != ''){
                        for(String mail : cs.Mail_CC_List__c.split(';')){
                            patt = Pattern.compile(emailRegex);
                            match = patt.matcher(mail.trim());
                            if(!match.matches()){
                                result = false;
                            }else{
                                toAddresses.add(mail);
                            }
                        }                        
                        if(result || (toAddresses != null && !toAddresses.isEmpty())){
                            Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
                            if(cs.Origin == CON_PEP.S_PARTNER_PORTAL && DAOH_Case.getCSMSettingData().get('PEP~CaseComment') != null) {
                                mailMessage.setTemplateId(DAOH_Case.getCSMSettingData().get('PEP~CaseComment').Component_Id__c);
                            }
                            else if(cs.Origin != CON_PEP.S_PARTNER_PORTAL && DAOH_Case.getCSMSettingData().get(cs.AccountCountry__c + '~CaseComment') != null) {
                                mailMessage.setTemplateId(DAOH_Case.getCSMSettingData().get(cs.AccountCountry__c + '~CaseComment').Component_Id__c);
                            }
                            else if(cs.Origin != CON_PEP.S_PARTNER_PORTAL && DAOH_Case.getCSMSettingData().get('Default~CaseComment') != null) {
                                mailMessage.setTemplateId(DAOH_Case.getCSMSettingData().get('Default~CaseComment').Component_Id__c);
                            }else{
                                continue;
                            }
                            String senderId = '';
                            if(CON_PEP.S_PARTNER_PORTAL == cs.Origin && DAOH_Case.getCSMSettingData().get(CON_PEP.S_PARTNER_PORTAL) != null) {
                                senderId = DAOH_Case.getCSMSettingData().get(CON_PEP.S_PARTNER_PORTAL).Component_Id__c;
                            }
                            else if(CON_CSM.S_CUSTOMER_PORTAL == cs.Origin && DAOH_Case.getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL) != null) {
                                senderId = DAOH_Case.getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL).Component_Id__c;
                            }
                            else if(CON_CSM.S_AGENT_INITIATED == cs.Origin && DAOH_Case.getCSMSettingData().get(CON_CSM.S_AGENT_INITIATED) != null) {
                                senderId = DAOH_Case.getCSMSettingData().get(CON_CSM.S_AGENT_INITIATED).Component_Id__c;
                            }
                            if(senderId != null && senderId.length() > 0) {
                                mailMessage.setOrgWideEmailAddressId(senderId);
                            }
                            mailMessage.setSaveAsActivity(false);
                            mailMessage.setTargetObjectId(cs.ContactId);
                            mailMessage.setTreatTargetObjectAsRecipient(false);
                            mailMessage.setToAddresses(toAddresses);
                            mailMessage.setReferences(Cases.generateThreadingMessageId(cs.Id));
                            mailMessage.setWhatId(cs.Id);
                            ccSendEmailList.add(mailMessage);
                        }
                        else
                        {
                            cs.addError('Invalid Email Address Format In Mail CC List');
                        }
                    }
                }
            }            
            if(ccSendEmailList != null && ccSendEmailList.size() > 0) {
                try{
                    Messaging.sendEmail(ccSendEmailList);
                }
                catch(Exception ex){
                    System.debug('Mail Exception: '+ex.getMessage());
                }
            }
            isCSMccEmailsHaveSent = true;
        }
    }
    
    /* Added by Saurabh */
    
    public static void sendLatestCommenttoDataCaseOriginator(List<Case> newList) {
        Map<Id,Id> userList = new Map<Id,Id>();
        Map<Id,Id> queueList = new Map<Id,Id>();
        List<String> toAddresses = new List<String>();
        for (Case c : newList) {
            if(c.CSM_QI_Data_Originator__c != null && (c.CSM_QI_Data_Originator__c.startsWith(CON_CSM.S_QUEUE_ID) || c.CSM_QI_Data_Originator__c.startsWith('005')) && c.RecordTypeName__c == CON_CSM.S_DATACASE && UserInfo.getUserType().contains('CustomerSuccess')) {
                queueList.put(c.CSM_QI_Data_Originator__c,c.Id); 
            }
        }
        if(!queueList.isEmpty()){
            List<Queue_User_Relationship__c> queueUser = new SLT_QueueUserRelationshipC().selectByCSHUserorGroupSet(queueList.keySet());
            if(!queueUser.isEmpty()){
                Pattern patt = Pattern.compile(CON_CSM.S_EMAIL_REGEXP);
                Matcher match = null;
                String emailId,queueemailId;
                for (Queue_User_Relationship__c c : queueUser) {
                    if(CON_CSM.S_QUEUE == c.Type__c && c.Queue_Email__c != null){
                        emailId = c.Queue_Email__c;
                        queueemailId = c.Queue_Email__c;
                        break;
                    }else{
                        emailId = c.User_Email__c;
                    }
                    if(emailId != null){
                        match = patt.matcher(emailId.trim());
                        if(match.matches()){
                            toAddresses.add(emailId);
                        }
                    }   
                }
                if(queueemailId != null){
                    toAddresses.clear();
                    toAddresses.add(queueemailId);
                }
            }
        }
        if(!toAddresses.isEmpty()){
            List<Messaging.SingleEmailMessage> dataSendEmailList = new List<Messaging.SingleEmailMessage>();
            for(Case cs : newList){
                Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
                if(DAOH_Case.getCSMSettingData().get(cs.AccountCountry__c + CON_CSM.SPC_TILDE + CON_CSM.S_ORG_CASECOMMENT) != null) {
                    mailMessage.setTemplateId(DAOH_Case.getCSMSettingData().get(cs.AccountCountry__c + CON_CSM.SPC_TILDE + CON_CSM.S_ORG_CASECOMMENT).Component_Id__c);
                }
                else if(DAOH_Case.getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + CON_CSM.S_ORG_CASECOMMENT) != null) {
                    mailMessage.setTemplateId(DAOH_Case.getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + CON_CSM.S_ORG_CASECOMMENT).Component_Id__c);
                }
                else{
                    continue;
                }
                String senderId = '';
                if(CON_CSM.S_CUSTOMER_PORTAL.equalsIgnoreCase(cs.Origin) && DAOH_Case.getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL) != null) {
                    senderId = DAOH_Case.getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL).Component_Id__c;
                }
                else if(CON_CSM.S_AGENT_INITIATED.equalsIgnoreCase(cs.Origin) && DAOH_Case.getCSMSettingData().get(CON_CSM.S_AGENT_INITIATED) != null) {
                    senderId = DAOH_Case.getCSMSettingData().get(CON_CSM.S_AGENT_INITIATED).Component_Id__c;
                }
                if(senderId != null && senderId.length() > 0) {
                    mailMessage.setOrgWideEmailAddressId(senderId);
                }
                mailMessage.setSaveAsActivity(false);
                mailMessage.setTargetObjectId(cs.ContactId);
                mailMessage.setTreatTargetObjectAsRecipient(false);
                mailMessage.setToAddresses(toAddresses);
                mailMessage.setReferences(Cases.generateThreadingMessageId(cs.Id));
                mailMessage.setWhatId(cs.Id);
                dataSendEmailList.add(mailMessage);                            
                
            }
            if(dataSendEmailList != null && dataSendEmailList.size() > 0) {
                try{
                    Messaging.sendEmail(dataSendEmailList);
                }
                catch(Exception ex){
                    System.debug('Mail Exception: '+ex.getMessage());
                }
            }
        }
    }
    
    public static void updateCSATInternalObject(List<CaseComment> newList) {
        List<Case> caseList = null;         
        Set<Id> commSet = new Set<Id>();
        List<CSM_QI_CSATInternal__c> crl = new List<CSM_QI_CSATInternal__c>();
        CSM_QI_CSATInternal__c cr;
        Map<Id,CSM_QI_CSATInternal__c> cMap = new Map<Id,CSM_QI_CSATInternal__c>();
        for(CaseComment comment : newList) {
            commSet.add(comment.Id);
        }
        crl = Database.query('SELECT Id,CommentId__c,CommentBody__c,CommentParentId__c,CommentIsPublished__c,CommentCreatedById__c,CommentCreatedDate__c,CommentLasModifiedById__c,CommentLastModified__c,CommentIsDeleted__c,Author_Current_Queue__c from CSM_QI_CSATInternal__c where CommentId__c in : commSet');
        for(CSM_QI_CSATInternal__c c : crl){
            cMap.put(c.CommentId__c, c);
        }
        for(CaseComment comment : newList) {
            if (!cMap.isEmpty() && cMap.containsKey(comment.Id)){
                cr = cMap.get(comment.Id);  
            }else{
                cr = new CSM_QI_CSATInternal__c();  
            } 
            cr.CommentId__c = comment.Id;
            cr.CommentBody__c = comment.CommentBody;
            cr.CommentParentId__c = comment.ParentId;
            cr.CommentIsPublished__c = comment.IsPublished;
            cr.CommentCreatedById__c = comment.CreatedById;
            cr.CommentCreatedDate__c = comment.CreatedDate;
            cr.CommentLasModifiedById__c = comment.LastModifiedById;
            cr.CommentLastModified__c = comment.LastModifiedDate;
            cr.CommentIsDeleted__c = comment.IsDeleted;
            caseList = new SLT_Case().selectById(new Set<ID> {comment.ParentId});
            cr.Author_Current_Queue__c = caseList[0].CurrentQueue__c;
        }
        try{
            upsert cr;    
        }catch(System.DmlException e){
            
        }
        
    }
    
    public static void deleteCSATInternalObject(List<CaseComment> newList) {
        List<CSM_QI_CSATInternal__c> crl = new List<CSM_QI_CSATInternal__c>();
        Set<Id> commSet = new Set<Id>();
        for(CaseComment comment : newList) {
            commSet.add(comment.Id);
        }   
        crl = [SELECT Id from CSM_QI_CSATInternal__c where CommentId__c in :commSet];
        if (crl.size() > 0){
            try{
                delete crl[0];      
            }catch (System.DmlException e){
                
            }
        } 
        
    }
    
    public static Map<Id,String> completeOLA(List<Id> ids) {
        List<CaseOLA__c> coList = Database.query('SELECT Id,Priority__c,Case__c,Case__r.RecordTypeName__c,IsActive__c,CreatedDate,QueueId__c,Previous_Queue__c,Current_Queue__c,CompletionOLADate__c,Elapsed_OLA_Time__c From CaseOLA__c Where Case__c in :ids and CompletionOLADate__c = null and IsActive__c = true');
        Map<Id,Id> qMap = new Map<Id,Id>();
        Set<Id> qSet = new Set<Id>();
        List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
        Map<Id,String> mapCase = new Map<Id,String>();
        String bhId = null; 
        DateTime dtStart,dtEnd;
        Map<String, CaseOLASettings__c> olaS = CNT_CSM_TechnoCaseOLA.getCSMSettingData();
        for(CaseOLA__c o : coList){
            qSet.add(o.QueueId__c);
        }
        
        List<CaseOLA__c> uLst = new List<CaseOLA__c>();
        if(coList != null && !coList.isEmpty()){
            queueList = new SLT_QueueUserRelationshipC().selectByGroupOLA(qSet);
            BusinessHours bhSoql = [select Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, TimeZoneSidKey from BusinessHours where IsActive = true and Name = 'Default' and IsDefault = true];
            for(Queue_User_Relationship__c q : queueList ){
                qMap.put(q.Group_Id__c, q.Business_Hours__c);
            }
            for(CaseOLA__c o : coList){
                if(qMap.containsKey(o.QueueId__c) ){
                    bhId = qMap.get(o.QueueId__c);
                }else{
                    bhId = bhSoql.Id; 
                }
                dtStart = o.CreatedDate;
                dtEnd = System.now();
                o.Elapsed_OLA_Time__c = BusinessHours.diff(bhId, dtStart, dtEnd)/1000/60;
                o.CompletionOLADate__c = dtEnd;
                decimal munites = o.Elapsed_OLA_Time__c/1000/60;
                String rtName = o.Case__r.RecordTypeName__c;
                if(olaS.containsKey(rtName + ' ' + o.priority__c)){
                    o.StandardOLAviolated__c = math.signum(olaS.get(rtName + ' ' + o.priority__c).Target_Time__c - munites) == -1 ? true : false;
                }
                decimal dhours = o.Elapsed_OLA_Time__c/1000/60/60;
                integer ihours = integer.valueOF(math.floor(dhours));
                decimal remainderHours = dhours- ihours;
                decimal dMinutes = math.round(remainderHours * 60);
                integer iMinutes = integer.valueOf(math.floor(dMinutes));
                mapCase.put(o.Case__c,CNT_CSM_TechnoCaseOLA.pad(ihours,2) +':'+  CNT_CSM_TechnoCaseOLA.pad(iMinutes,2));
                uLst.add(o);
            }
            if(!uLst.isEmpty()){
                try{
                    update uLst;    
                }catch(System.DmlException e){}
                
            }
        }
        return mapCase;
    }
    
    public static void updateTechAFUFlagOnNewComment(List<CaseComment> newCaseCommentList){
        Map<Id, CaseComment> userIdCommentMap = new Map<Id, CaseComment>();
        for(CaseComment commentRecord : newCaseCommentList){
            if(commentRecord.ParentId != null && commentRecord.IsPublished && commentRecord.CreatedById != CON_CSM.S_SYSTEM_USERID){
                userIdCommentMap.put(commentRecord.CreatedById, commentRecord);
            }
        }
        if(userIdCommentMap != null && !userIdCommentMap.isEmpty()){
            List<User> userList = new SLT_User().selectById(userIdCommentMap.keySet());
            if(userList != null && userList.size() > 0){
                Set<Id> caseIdSet = new Set<Id>();
                for(User userRecord : userList){
                    if(userRecord.UserType.contains(CON_CSM.S_CUSTOMER_SUCCCESS)){
                        caseIdSet.add(userIdCommentMap.get(userRecord.Id).ParentId);
                    }
                }
                if(caseIdSet != null && caseIdSet.size() > 0){
                    List<Case> caseList = new SLT_Case().selectById(caseIdSet);
                    if(caseList != null && caseList.size() > 0){
                        List<Case> casesToUpdate = new List<Case>();
                        for(Case caseRecord : caseList){
                            if(caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && caseRecord.AFU_TECH__c){
                                caseRecord.AFU_TECH__c = FALSE;
                                casesToUpdate.add(caseRecord);
                            }
                        }
                        if(casesToUpdate != null && casesToUpdate.size() > 0){
                            try{
                                update casesToUpdate;
                            }
                            catch(Exception ex){
                                ex.getStackTraceString();
                            }
                        }
                    }
                }
            }
        }
    }

    public static void sendNotificationBell(List<CaseComment> newCaseCommentList){
        id caseId;
        String caseComment;
        for(CaseComment cc : newCaseCommentList){
            if(cc.ParentId != null && cc.CommentBody != null && !cc.CommentBody.startsWith(CON_CSM.S_Case_Description)){
              caseId = cc.ParentId;
              caseComment = cc.CommentBody;  
            }   
        }
        if(caseId != null && caseComment != null){ sendNotify(caseId,caseComment);  }
    }
    
    public static void sendNotify(id caseId,String caseComment){
        String currQueueId = null, currQueueName = null;
        list<Case> listCases = [SELECT id,OrgURL__c , Account_Name_Article__c,CurrentQueue__c,CaseNumber,Status,Subject,AccountCountry__c,Description, ProductName__c ,Priority,Origin,LastCaseComment__c,RecordTypeName__c FROM Case WHERE id =:caseId];
        if(listCases != null && listCases[0].RecordTypeName__c =='TechnologyCase'){
            currQueueId = listCases[0].CurrentQueue__c;
            List<Queue_User_Relationship__c> queueUser = new SLT_QueueUserRelationshipC().selectByUserFromTECHQueueUser(new Set<Id>{currQueueId}, new Set<String> {'id','Name','user__c','User_Notification_Setup__c'});
            List<id> owneridd = new List<id>();
            List<id> emailUsers = new List<id>();
            for(Queue_User_Relationship__c dd :queueUser){
                if(dd.user__c !=null && dd.User_Notification_Setup__c != null && dd.User_Notification_Setup__c.contains('Comment - Bell')){
                    if(currQueueName == null){
                        currQueueName = dd.Name;
                    }
                    owneridd.add(dd.user__c);
                }
                if(dd.user__c !=null && dd.User_Notification_Setup__c != null && dd.User_Notification_Setup__c.contains('Comment - Email')){
                    emailUsers.add(dd.user__c);
                    caseComment = caseComment+'CaseComment';
                }
            }
            if(!System.isFuture() && !System.isBatch()){
                if(owneridd != null && owneridd.size() > 0){
                    CustomNotificationRESTAPI.sendCustomNotificationAfter21Winter('NotificationBellForCaseComment', JSON.serialize(listCases), JSON.serialize(owneridd),currQueueName ,'Worknote');
                    //CustomNotificationRESTAPI.sendCustomNotification('NotificationBellForCaseComment', JSON.serialize(listCases), JSON.serialize(owneridd),'Worknote');
                }
                if(emailUsers != null && emailUsers.size() > 0){
                    CNT_CSM_EmailNotification.sendEmailNotification(listCases,emailUsers,caseComment);   
                }
            }
        }
    }    
}