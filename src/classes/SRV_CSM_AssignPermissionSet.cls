global class SRV_CSM_AssignPermissionSet {
    @future 
    public static void AssignPermissionSetToUsers (String[] lstUsers,Id psId) {
        PermissionSetAssignment psa =null;
        List<PermissionSetAssignment> listPSAList = new List<PermissionSetAssignment>(); 
                for (String sUser : lstUsers){
                    psa = new PermissionSetAssignment (PermissionSetId = psId, AssigneeId = (ID)sUser);
                    listPSAList.add(psa);
                }
                try {
                    if(listPSAList.isEmpty() == false ){
                        insert listPSAList; 
                    }
                } catch (DmlException e) {
                    System.debug('Failed due to : '+e);
                }
        
    }
    
    @future 
    public static void DeletePermissionSetToUsers (String[] sDeleteUsers,Id psId) {
        List<PermissionSetAssignment> deletePSAList= [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN : sDeleteUsers AND PermissionSetId = : psId];
        try {
            if(deletePSAList.isEmpty() == false ){
                delete deletePSAList;
            }
        } catch (DmlException e) {
            System.debug('Failed due to : '+e);
        }
    }
    
    @future
    public static void createActivityFromEmailMessage(String activityList) {
        List<Activity__c> newList = (List<Activity__c>)JSON.deserialize(activityList, List<Activity__c>.Class);
        System.debug('newList : '+newList.size());
        try{
            insert newList;
        }catch (DmlException e) {
            System.debug('Failed due to : '+e);
        }
        
    }
    
    @future
    public static void updateMilestoneVilotaion(List<Id> newList) {  
        List<Case> caseList = [select Id,Milestone_Violation__c,RecordTypeName__c,CaseOriginatorName__c,TaskMilestone__c from Case where Id in :newList];
        boolean updateCheck = false;
        if(!caseList.isEmpty()) {
            for (Case c : caseList){
                if(c.Milestone_Violation__c) {
                    c.Milestone_Violation__c = false;
                    updateCheck = true;
                }
                if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.CaseOriginatorName__c != null){
                    if(CON_CSM.S_RESOLUTION_FAILD == c.CaseOriginatorName__c){
                        if(c.TaskMilestone__c != null && !c.TaskMilestone__c.contains(CON_CSM.S_RESOLUTION_FAILD)){
                            c.TaskMilestone__c += ';' + CON_CSM.S_RESOLUTION_FAILD;
                        }else if(c.TaskMilestone__c == null){
                            c.TaskMilestone__c = CON_CSM.S_RESOLUTION_FAILD;
                        }    
                    }else if(c.CaseOriginatorName__c == CON_CSM.S_INITIAL_RES_FAIL){
                        if(c.TaskMilestone__c != null && !c.TaskMilestone__c.contains(CON_CSM.S_INITIAL_RES_FAIL)){
                            c.TaskMilestone__c += ';' + CON_CSM.S_INITIAL_RES_FAIL;
                        }else if(c.TaskMilestone__c == null){
                            c.TaskMilestone__c = CON_CSM.S_INITIAL_RES_FAIL;
                        }    
                    }
                    c.CaseOriginatorName__c = null;
                    updateCheck = true;
                }
            }
            try {
                if(updateCheck) {
                    update caseList;
                }
                
            } catch (DmlException e) {
                System.debug('Failed due to : '+e);
            }
            
        }
    }
    
    @future
    public static void completeMilestone(List<Id> caseIds,List<String> milestoneNames, DateTime complDate) {
        Map<String,CaseMilestone> taskMap = new Map<String,CaseMilestone>();
        List<CaseMilestone> cmsToUpdate = Database.query('select Id, completionDate,case.ContactId, caseId,MilestoneType.Name from CaseMilestone cm where caseId in :caseIds and cm.MilestoneType.Name in :milestoneNames and completionDate = null');
        if (cmsToUpdate.isEmpty() == false){
            List<Task> taskList = new List<Task>();
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
                taskMap.put(cm.MilestoneType.Name,cm);
            }
            try {
                if(cmsToUpdate.isEmpty() == false && cmsToUpdate.size() > 0){
                    update cmsToUpdate;
                    if(taskMap.containsKey(CON_CSM.S_RESOLUTION_PLAN)){
                       taskList.add(new Task(WhatId = taskMap.get(CON_CSM.S_RESOLUTION_PLAN).caseId , WhoId = taskMap.get(CON_CSM.S_RESOLUTION_PLAN).Case.ContactId, subject = CON_CSM.S_RESOLUTION_PLAN, type = CON_CSM.S_RESOLUTION_PLAN, status = CON_CSM.S_COMPLETED, ActivityDate= System.today(), recordtypeid = '0126A000000hDGpQAM'));
                            
                    }
                    if(taskMap.containsKey(CON_CSM.S_COMMUNICATION_UPD)){
                      taskList.add(new Task(WhatId = taskMap.get(CON_CSM.S_COMMUNICATION_UPD).caseId , WhoId = taskMap.get(CON_CSM.S_COMMUNICATION_UPD).Case.ContactId, subject = CON_CSM.S_COMMUNICATION_UPD, type = CON_CSM.S_COMMUNICATION_UPD, status = CON_CSM.S_COMPLETED, ActivityDate= System.today(), recordtypeid = '0126A000000hDGpQAM'));
                    }
                    if(taskList != null && !taskList.isEmpty()){
                        insert taskList;
                    }
                }
            } catch (DmlException e) {
                System.debug('Failed due to : '+e);
            }
        }
    }

    @future
    public static void createQueueUserRelationshipToActiveUser(List<String> groupIdList) {
        Group g = new Group();
        if (!groupIdList.isEmpty()){
            for (String gid : groupIdList){
                try {
                    g.Id = gid;
                    DAOH_User.manageUserQueuesRelations(new List<Group>{g});
                } catch (DmlException e) {
                    System.debug('Failed due to : '+e);
                }
            }
        }
    }
    
    @future (callout = true)
    public static void oneStepNotificationOpMIR3(String caseId,String caseNumber,String subject,String message,boolean is24_7) {
        CSM_ExternalClient_info__c eci = CSM_ExternalClient_info__c.getValues('Mir3');
        String apiVersion = '4.0';
        WSC_CSM_Mir3ComWs.authorizationType authorization = new WSC_CSM_Mir3ComWs.authorizationType();
        authorization.username = eci.UserName__c;
        authorization.password =eci.Password__c;
        WSC_CSM_Mir3ComWs.dynamicRecipientsType dynamicRecipients = new WSC_CSM_Mir3ComWs.dynamicRecipientsType();
        WSC_CSM_Mir3ComWs.notificationDetailType notificationDetail = new WSC_CSM_Mir3ComWs.notificationDetailType();
        notificationDetail.contactCycleDelay = 120;
        notificationDetail.contactAttemptCycles = 2;
        notificationDetail.textDeviceDelay = 300;
        notificationDetail.division = '/';
        notificationDetail.title = 'CSM-'+caseNumber;
        notificationDetail.message = message;
        String[] listStr = new String[1];
        WSC_CSM_Mir3ComWs.verbiagePerMessageType verbiage = new WSC_CSM_Mir3ComWs.verbiagePerMessageType();
        WSC_CSM_Mir3ComWs.stringWithMessageTypeAndLocale[] strList = new WSC_CSM_Mir3ComWs.stringWithMessageTypeAndLocale[1];
        WSC_CSM_Mir3ComWs.stringWithMessageTypeAndLocale strLo = new WSC_CSM_Mir3ComWs.stringWithMessageTypeAndLocale();
        /*strLo.text = 'Test Message sub';
        strLo.locale='en_US';
        strLo.messageType = 'Default';*/
        listStr[0] = message;
        verbiage.text = listStr;
        notificationDetail.verbiage = verbiage;
        String[] verbiageAccStr = new String[1];
        String[] verbiageNoAccStr = new String[1];
        WSC_CSM_Mir3ComWs.verbiagePerMessageType verbiageAcc = new WSC_CSM_Mir3ComWs.verbiagePerMessageType();
        WSC_CSM_Mir3ComWs.verbiagePerMessageType verbiageNoAcc = new WSC_CSM_Mir3ComWs.verbiagePerMessageType();
        WSC_CSM_Mir3ComWs.notificationResponseOptionsType nros = new WSC_CSM_Mir3ComWs.notificationResponseOptionsType();
        WSC_CSM_Mir3ComWs.responseOptionType[] responseOptions = new WSC_CSM_Mir3ComWs.responseOptionType[1];
        WSC_CSM_Mir3ComWs.responseOptionType responseOptionAcc = new WSC_CSM_Mir3ComWs.responseOptionType();
        responseOptionAcc.responseText = 'Acknowledge';
        verbiageAccStr[0] = 'Acknowledge';
        verbiageAcc.text = verbiageAccStr;
        responseOptionAcc.verbiage = verbiageAcc;
        responseOptionAcc.success = true;
        responseOptions[0] = responseOptionAcc;
       /* WSC_CSM_Mir3ComWs.responseOptionType responseOptionNAcc = new WSC_CSM_Mir3ComWs.responseOptionType();
        responseOptionNAcc.responseText = 'No Acknowledge';
        verbiageNoAccStr[0] = 'No Acknowledge';
        verbiageNoAcc.text = verbiageNoAccStr;
        responseOptionNAcc.verbiage = verbiageNoAcc;
        responseOptionNAcc.success = false;
        responseOptions[1] = responseOptionNAcc;*/
        nros.responseOption = responseOptions;
        notificationDetail.responseOptions = nros;
        WSC_CSM_Mir3ComWs.calloutInfoType calloutInfo = new WSC_CSM_Mir3ComWs.calloutInfoType();
        calloutInfo.callOutSuccessTotal = 1;
        calloutInfo.contactAll = true;
        WSC_CSM_Mir3ComWs.notificationEscalationsType escalationT = new WSC_CSM_Mir3ComWs.notificationEscalationsType();
        WSC_CSM_Mir3ComWs.escalationType[] escalations = new WSC_CSM_Mir3ComWs.escalationType[1];
        WSC_CSM_Mir3ComWs.escalationType escalation = new WSC_CSM_Mir3ComWs.escalationType();
        String[] grp = new String[1];
        grp[0] = eci.Client_Certificate__c;
        escalation.recipientGroup = grp;
        escalations[0] = escalation;
        escalationT.escalation = escalations;
        calloutInfo.escalations = escalationT;
        notificationDetail.calloutInfo = calloutInfo;
        notificationDetail.strictDeviceDelay = true;
        notificationDetail.textDevicesOnce = false;
        WSC_CSM_Mir3ComWs.locationOverrideType locationOverride = new  WSC_CSM_Mir3ComWs.locationOverrideType();
        locationOverride.overrideDefaultStatusOnly = false;
        WSC_CSM_Mir3ComWs.locationOverrideDevicesType devices = new WSC_CSM_Mir3ComWs.locationOverrideDevicesType();
        WSC_CSM_Mir3ComWs.overrideType[] overrides = new WSC_CSM_Mir3ComWs.overrideType[5];
        WSC_CSM_Mir3ComWs.overrideType overrideM = new WSC_CSM_Mir3ComWs.overrideType();
        overrideM.deviceType = 'Mobile App';
        overrideM.priority = '1';
        overrides[0] = overrideM;
        WSC_CSM_Mir3ComWs.overrideType overrideSms = new WSC_CSM_Mir3ComWs.overrideType();
        overrideSms.deviceType = 'SMS';
        overrideSms.priority = '2';
        overrides[1] = overrideSms;
        WSC_CSM_Mir3ComWs.overrideType overrideW = new WSC_CSM_Mir3ComWs.overrideType();
        overrideW.deviceType = 'Work Email';
        overrideW.priority = '1';
        overrides[2] = overrideW;
        WSC_CSM_Mir3ComWs.overrideType overrideWp = new WSC_CSM_Mir3ComWs.overrideType();
        overrideWp.deviceType = 'Work Phone';
        overrideWp.priority = '1';
        overrides[3] = overrideWp;
        WSC_CSM_Mir3ComWs.overrideType override_x = new WSC_CSM_Mir3ComWs.overrideType();
        override_x.deviceType = 'Mobile Phone';
        override_x.priority = '1';
        overrides[4] = override_x;
        devices.override_x = overrides;
        WSC_CSM_Mir3ComWs.oneStepAttachmentType oneStepAttachment = new WSC_CSM_Mir3ComWs.oneStepAttachmentType();
        WSC_CSM_Mir3ComWs.verbiageOverrideType verbiageOverrides = new WSC_CSM_Mir3ComWs.verbiageOverrideType();
        WSC_CSM_Mir3ComWs.placeholderValuesType placeholderValues = new WSC_CSM_Mir3ComWs.placeholderValuesType();
        Map<String,String> head = new Map<String,String>();
        WSC_CSM_Mir3ComWs.mir3 mir3 = new WSC_CSM_Mir3ComWs.mir3();
        try { 
            mir3.endpoint_x = eci.Client_Url__c;
            WSC_CSM_Mir3ComWs.responseType res = mir3.oneStepNotificationOp(apiVersion,authorization,true,null,null,notificationDetail,oneStepAttachment,verbiageOverrides, placeholderValues);
            System.debug('res : '+res);
            Schema.RecordTypeInfo rtByName =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('CSM Task');
            Task task = new Task(RecordTypeId = rtByName.getRecordTypeId(),Subject = 'SMS', WhatId = caseId, ActivityDate= System.today(), Type = 'Other',Status ='Completed', OwnerId = UserInfo.getUserId(), Description = 'SMS notification sent to group '+grp);
            if(!res.success){
                task.Description += '. But Received Error: '+res.error;
            }
            insert task;
        } catch ( CalloutException ce) {
            System.debug('Exce : '+ce.getCause());
            
        } catch ( Exception e) {
            System.debug('Stack : '+ e.getMessage());
        }
    }
}
