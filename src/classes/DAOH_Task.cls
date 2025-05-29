/**
* This is Task Domain handler class.
* version : 1.0
*/
public without sharing class DAOH_Task {
    
    private static final String MQL_TASK_DELETE_ERROR_MSG = 'MQL Tasks cannot be deleted. If this Task was created in error, please contact your supervisor.';
    /**
    * This method is used for create a new Data Audit Trail when the new task record is created.
    * @params  newList List<Task>
    * @return  void
    */
    
    public static void saveAuditLogAfterInsertTask(List<Task> newList){
        CSM_QI_Data_Audit_Trail__c auditTrail = null;
        Map<ID,Schema.RecordTypeInfo> rt_Map  =  Task.sObjectType.getDescribe().getRecordTypeInfosById();
        List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
        if(newList.size() > 0)
        {
            for(Task c : newList) {
                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CREATED,Name = CON_CSM.S_TASK,Task_Id__c  =  c.Id);
                auditTrailList.add(auditTrail);
            }
        }
        try {
            if(auditTrailList != null && auditTrailList.size() > 0){
                insert auditTrailList;
            }
        } catch (DmlException e) {
            System.debug('Failed due to : '+e);
        }
    }
    /**
    * This method is used for create a new Data Audit Trail when the task record fields are updated.
    * @params  newList List<Task>,oldMap Map<Id, Task> 
    * @return  void
    */
    public static void saveAuditLogAfterUpdateTaskFields(List<Task> newList, Map<Id, Task> oldMap,List<FieldDefinition> fields) {
        
        if(fields != null && fields.size() > 0){
            
            CSM_QI_Data_Audit_Trail__c auditTrail = null;
            List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
            Map<ID,Schema.RecordTypeInfo> rt_Map  =  Task.sObjectType.getDescribe().getRecordTypeInfosById();
            EXT_CSM_CaseRelatedToObject relatedTo = null;
            List<EXT_CSM_CaseRelatedToObject> relatedToList = new List<EXT_CSM_CaseRelatedToObject>(); 
            String objRelName = null;
            for(Task c : newList) {
                
                if(fields.size() > 0 ) 
                {
                    for( FieldDefinition fd: fields){
                        if(fd.QualifiedApiName.equals(CON_CSM.S_PHONE)) continue;
                        if(fd.QualifiedApiName.equals(CON_CSM.S_EMAIL)) continue;
                        
                        if(String.isBlank(fd.ExtraTypeInfo) && ((fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PICKLIST) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_NUMBER) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_DOUBLE)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_URL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PHONE) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_EMAIL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_CHECKBOX) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_BOOLEAN)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_FORMULA) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_TEXT)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATETIME)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATE)))){
                                if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                    auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Task_Id__c =  c.Id);
                                    auditTrailList.add(auditTrail);
                                }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                    auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Task_Id__c =  c.Id);
                                    auditTrailList.add(auditTrail);
                                }else if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                    auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Task_Id__c =  c.Id);
                                    auditTrailList.add(auditTrail);
                                }
                            }else if(String.isBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_LOOKUP) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_ID)){
                                if(c.WhatId != null && 'What' == fd.RelationshipName){
                                    objRelName =  String.valueOf(c.WhatId.getSObjectType()); 
                                }else if(c.WhoId != null && 'Who' == fd.RelationshipName){
                                    objRelName =  String.valueOf(c.WhoId.getSObjectType()); 
                                }else{
                                    objRelName =  fd.RelationshipName;   
                                }
                                if('Who' == objRelName || 'What' == objRelName){
                                    continue; 
                                }
                                if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                    relatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_DELETED,objRelName,CON_CSM.S_TASK,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),null,c.Id);
                                    relatedToList.add(relatedTo);
                                }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                    relatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_ADDED,objRelName,CON_CSM.S_TASK,fd.MasterLabel,null,(Id)c.get(fd.QualifiedApiName),c.Id);
                                    relatedToList.add(relatedTo);    
                                }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                    relatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_CHANGED,objRelName,CON_CSM.S_TASK,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),(Id)c.get(fd.QualifiedApiName),c.Id);
                                    relatedToList.add(relatedTo);
                                }
                            }else if(String.isNotBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)){
                                if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                    auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = fd.MasterLabel,Old_Text_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),Task_Id__c  =  c.Id);
                                    auditTrailList.add(auditTrail);
                                }
                            }
                    }
                }
            }
            
            if(relatedToList.size() > 0)
            {
                Set<Id> accSet = new Set<Id>(),assetSet = new Set<Id>(),csSet = new Set<Id>(),solSet = new Set<Id>(),conSet = new Set<Id>();
                
                for(EXT_CSM_CaseRelatedToObject obj : relatedToList){
                    if(CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        accSet.add(obj.oldId);
                        accSet.add(obj.newId);
                    }else if(CON_CSM.S_ASSET.equals(obj.objRelName)){
                        assetSet.add(obj.oldId);
                        assetSet.add(obj.newId);
                    }else if(CON_CSM.S_CASE.equals(obj.objRelName)){
                        csSet.add(obj.oldId);
                        csSet.add(obj.newId);
                    }else if(CON_CSM.S_SOLUTION.equals(obj.objRelName)){
                        solSet.add(obj.oldId);
                        solSet.add(obj.newId);
                    }else if(CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        conSet.add(obj.oldId);
                        conSet.add(obj.newId);
                    }
                    
                }
                Set<String> fieldSet  =  new Set<String> {CON_CSM.S_ID, CON_CSM.S_NAME};
                Map<Id, Account> accountMap  = null;
                Map<Id, Asset> assetMap  = null;
                Map<Id, Case> csMap = null;
                Map<Id, Solution> solMap = null;
                Map<Id, Contact> conMap = null;
                if(accSet.size() > 0) accountMap  =  new SLT_Account().selectByAccountId(accSet, fieldSet);
                if(assetSet.size() > 0) assetMap  =  new SLT_Asset().selectByAssetId(assetSet, fieldSet);
                if(csSet.size() > 0)  csMap  =  new SLT_Case().selectByCaseId(csSet, new Set<String>{CON_CSM.S_ID,CON_CSM.S_CASENUM});
                if(solSet.size() > 0)  solMap  =  new SLT_Solution().selectBySolutionId(solSet, fieldSet);
                if(conSet.size() > 0)  conMap  =  new SLT_Contact().selectByContactId(conSet, fieldSet);
                for(EXT_CSM_CaseRelatedToObject obj:relatedToList){
                    
                    if(accountMap != null && accountMap.size() > 0 && CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Task_Id__c  =  obj.objectId,Old_Value__c = accountMap.containsKey(obj.oldId)?accountMap.get(obj.oldId).Name :'',New_Value__c = accountMap.containsKey(obj.newId)?accountMap.get(obj.newId).Name:'');
                        auditTrailList.add(auditTrail);
                    }else if(assetMap != null && assetMap.size() > 0 && CON_CSM.S_ASSET.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Task_Id__c  =  obj.objectId,Old_Value__c = assetMap.containsKey(obj.oldId)?assetMap.get(obj.oldId).Name :'',New_Value__c = assetMap.containsKey(obj.newId)?assetMap.get(obj.newId).Name:'');
                        auditTrailList.add(auditTrail);
                    }else if(csMap != null && csMap.size() > 0 && CON_CSM.S_CASE.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Task_Id__c  =  obj.objectId,Old_Value__c = csMap.containsKey(obj.oldId)?csMap.get(obj.oldId).CaseNumber :'',New_Value__c = csMap.containsKey(obj.newId)?csMap.get(obj.newId).CaseNumber:''); 
                        auditTrailList.add(auditTrail);
                    }else if(solMap != null && solMap.size() > 0 && CON_CSM.S_SOLUTION.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Task_Id__c  =  obj.objectId,Old_Value__c = solMap.containsKey(obj.oldId)?solMap.get(obj.oldId).SolutionNumber :'',New_Value__c = solMap.containsKey(obj.newId)?solMap.get(obj.newId).SolutionNumber:''); 
                        auditTrailList.add(auditTrail);
                    }else if(conMap != null && conMap.size() > 0 && CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Task_Id__c  =  obj.objectId,Old_Value__c = conMap.containsKey(obj.oldId)?conMap.get(obj.oldId).Name :'',New_Value__c = conMap.containsKey(obj.newId)?conMap.get(obj.newId).Name:''); 
                        auditTrailList.add(auditTrail);
                    }
                    
                }
            }
            
            
            try {
                if(auditTrailList != null && auditTrailList.size() > 0){
                    insert auditTrailList;
                }
                
            } catch (DmlException e) {
                System.debug('Failed due to : '+e);
            }
        }
        
    }
    
    public static void updateStatusforLogACallonCase(List<Task> newList){
        Set<Id> caseIds = new Set<Id>();
        Set<Id> caseCallIds = new Set<Id>();
        List<Case> updateCase = new List<Case>();
        Id userId = UserInfo.getUserId();
        List<Id> technoCaseId = new List<Id>();
        boolean InitialResonseProdOpps = false;
        List<Id> technoCaseIdProd = new List<Id>();
        List<Case> caseList = null;
        boolean isOutboundCall = false;
        boolean checkUpdate = false;
        boolean taskCheck = true;
        String caseId = null;
        Set<Id> tcaseIds = new Set<Id>();
        List<String> statusList = CON_CSM.S_C_TECH_STATUS;
		String name = UserInfo.getName();
        Map<String,String> milestoneMap = new Map<String,String>();
        for(Task c : newList) {
            if(c.WhatId != null && 'Case' == String.valueOf(c.WhatId.getSObjectType())){
                if(CON_CSM.S_OUTBOUND_Call == c.Type || 'Call' == c.Type){
                    caseIds.add(c.WhatId);
                    caseCallIds.add(c.WhatId);
                    isOutboundCall = true;
                }else if(c.WhatId != null){
                    if(CON_CSM.S_TASK_SUBJECT == c.Subject) { 
                        taskCheck = false;  
                    }
                    caseIds.add(c.WhatId); 
                }
            }
        }
        if(!caseCallIds.isEmpty())
        	UTL_CSM_SendMail.updateTaskMail('Call',caseCallIds);
        
        if(!caseIds.isEmpty()){
            caseList = new SLT_Case().selectById(caseIds);
            Map<Id,boolean> initialMap = new Map<Id,boolean>();
            List<String> milestoneList = new List<String>{CON_CSM.S_COMMUNICATION_UPD,CON_CSM.S_FIRST_RESPONSE_T};
            for(Case cs : caseList){
                if((cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || cs.RecordTypeName__c == CON_CSM.S_DATACASE)){
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
                if(taskCheck && CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c && string.valueOf(cs.OwnerId).startsWith(CON_CSM.S_QUEUE_ID) && CON_CSM.S_NEW == cs.Status){
                    cs.Status = CON_CSM.S_IN_PROGRESS;
                    checkUpdate = true; 
                }
                //if(isOutboundCall && CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c && ((cs.EntitlementId != null && entMap != null && entMap.containsKey(cs.EntitlementId) && entMap.get(cs.EntitlementId).Type == 'TECH Dashboard & Reports') || cs.ProductName__c  == CON_CSM.S_TDR || CON_CSM.S_O_ES == cs.Origin || CON_CSM.S_EMAIL == cs.Origin || CON_CSM.S_CUSTOMER_PORTAL == cs.Origin)){
                if(isOutboundCall && initialMap.containsKey(cs.Id) && CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c && cs.EntitlementId != null){
                    if(taskCheck && CON_CSM.S_NEW == cs.Status && (CON_CSM.S_O_ES == cs.Origin || CON_CSM.S_EMAIL == cs.Origin || CON_CSM.S_CUSTOMER_PORTAL == cs.Origin)){
                        cs.Status = CON_CSM.S_IN_PROGRESS;
                        checkUpdate = true;
                    }
                    
                    if (((cs.SlaStartDate <= System.now()) && (cs.SlaExitDate == null))){
                        if(cs.TaskMilestone__c != null && !cs.TaskMilestone__c.contains(CON_CSM.S_FIRST_RESPONSE_T+';')){
                            cs.TaskMilestone__c += ';' + CON_CSM.S_FIRST_RESPONSE_T;
                            technoCaseId.add(cs.Id);
                            checkUpdate = true;
                        }else if(cs.TaskMilestone__c == null){
                            cs.TaskMilestone__c = CON_CSM.S_FIRST_RESPONSE_T; 
                            technoCaseId.add(cs.Id);
                            checkUpdate = true;
                        }
                        if(milestoneList.contains(CON_CSM.S_COMMUNICATION_UPD) && milestoneMap.containsKey(cs.Id +'~'+CON_CSM.S_COMMUNICATION_UPD)){
                            if(cs.TaskMilestone__c != null && !cs.TaskMilestone__c.contains(CON_CSM.S_COMMUNICATION_UPD)){
                                cs.TaskMilestone__c += ';' + CON_CSM.S_COMMUNICATION_UPD;
                            }else if(cs.TaskMilestone__c == null){
                                cs.TaskMilestone__c = CON_CSM.S_COMMUNICATION_UPD;
                            }
                            technoCaseId.add(cs.Id);
                            checkUpdate = true;
                        }
                    }
                }else if(isOutboundCall && CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c){
                    technoCaseIdProd.add(cs.Id);
                    InitialResonseProdOpps = true;
                    checkUpdate = true;
                }
                if(CON_CSM.S_ALLOWED_RT_TIMESHEET.contains(cs.RecordTypeName__c) && !(name == CON_CSM.S_SYSTEM || name == CON_CSM.S_CSM_ADMIN  || UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || name == 'Integration ServiceNow' || name =='BISM CSM API User')){
                    tcaseIds.add(cs.Id);
                    if(!statusList.contains(cs.Status) || cs.Status == CON_CSM.S_RESOLVED_WITH_C) caseId = cs.Id;
                }
                if(checkUpdate){
                    updateCase.add(cs);
                }
            }
            
            if(!updateCase.isEmpty()){
                try{
                    update updateCase;   
                }catch (DmlException e) {
                    System.debug('Failed due to : '+e);
                }
                
            }
            if(!technoCaseId.isEmpty()){
                DateTime completionDate = System.now();
                DAOH_Case.completeMilestone(technoCaseId, new List<String>{CON_CSM.S_COMMUNICATION_UPD,CON_CSM.S_FIRST_RESPONSE_T,CON_CSM.S_PRODOPS_INITIAL_RESPONSE}, completionDate);
            }else if(!technoCaseIdProd.isEmpty() && InitialResonseProdOpps){
                DateTime completionDate = System.now();
                DAOH_Case.completeMilestone(technoCaseIdProd, new List<String>{CON_CSM.S_FIRST_RESPONSE_T,CON_CSM.S_PRODOPS_INITIAL_RESPONSE}, completionDate);
            }
            
            if(!tcaseIds.isEmpty() && !System.isBatch() && !System.isFuture()){
                DAOH_Case.stopTechAutoTimer(tcaseIds,caseId,'Log a Call added');
            }
        }
        
    }
    
    /**
    * This method is used to set fields of task.
    * @params  newList List<Task>
    * @return  void
    */
    public static void setTaskFields(List<Task> newList, Map<Id, Task> oldMap) {
        Set<Id> userIdSet = new Set<Id>();
        Set<String> userFieldSet = new Set<String>{'Id','ManagerId','Manager.Email'};
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();
        Map<Id, Contact> idToContactMap;
        Map<Id, Lead> idToLeadMap;
        Set<String> fieldSet = new Set<String>{'id','Phone','Email'};
        Set<Id> mqlTaskGroupMemberIdSet = new Set<Id>();
        Set<Id> childUserIdSet = new Set<Id>();

        if(Trigger.isUpdate){
            for(GroupMember gm : [Select Id, UserOrGroupId From GroupMember Where Group.Name = :CON_CRM.GROUP_MQL_TASK_MANAGEMENT]){
            	mqlTaskGroupMemberIdSet.add(gm.UserOrGroupId);
        	}
        
            for(User user : new SLT_User().geUsersByManagerId(UserInfo.getUserId())){
                childUserIdSet.add(user.Id);
            }
        }
        
        
        for(Task tsk : newList) {
            /* CTI Post-Call Servey
            if(Trigger.isInsert && tsk.cnx__CTIInfo__c != null && tsk.cnx__UniqueId__c != null){
                List<String> phone =  tsk.cnx__CTIInfo__c.split(',');
                if(phone != null && !phone.isEmpty() && tsk.cnx__UniqueId__c.length() < 255){
                    tsk.CSM_QI_CTI_Phone__c = tsk.cnx__UniqueId__c +'.' +phone[0];
                }
            }*/
            if((Trigger.isInsert || tsk.WhoId != oldMap.get(tsk.id).WhoId) && tsk.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID) {
                String whoId = tsk.WhoId;
                if(!String.isBlank(WhoId) && WhoId.startsWith(CON_CRM.CONTACT_OBJECT_CODE)) {
                    contactIdSet.add(tsk.WhoId);
                }
                else if(!String.isBlank(WhoId) && whoId.startsWith(CON_CRM.LEAD_OBJECT_CODE)) {
                    leadIdSet.add(tsk.WhoId);
                }
            }
            if ( Trigger.isInsert && tsk.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID ){
                userIdSet.add(tsk.OwnerId);
        	}
            
            if(Trigger.isUpdate && tsk.OwnerId != oldMap.get(tsk.Id).OwnerId && tsk.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID){
                if(!(mqlTaskGroupMemberIdSet.contains(UserInfo.getUserId()) || UserInfo.getUserId() == oldMap.get(tsk.Id).OwnerId || childUserIdSet.contains(oldMap.get(tsk.Id).OwnerId))){
            		tsk.OwnerId.addError(System.Label.CRM_CL0033_Task_Owner);
                }
            }
            
            if(Trigger.isUpdate && tsk.MQL_Triaged_By__c == null){
                String insideSalesUserId = CRM_Config__c.getInstance().Inside_Sales_User_Id__c;
                if(insideSalesUserId != null && insideSalesUserId == oldMap.get(tsk.Id).OwnerId && tsk.OwnerId != oldMap.get(tsk.Id).OwnerId){
                    tsk.MQL_Triaged_By__c = UserInfo.getName();
                }
            }
            
            if(tsk.Attempt_1_Date__c == null && tsk.Status == 'Open - Attempt 1' && tsk.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID){
                tsk.Attempt_1_Date__c = System.today();
                
                /*if(tsk.Priority == 'Normal'){
                    tsk.ActivityDate = calculateDueDate(tsk.Attempt_1_Date__c, 9);
                }else if(tsk.Priority == 'High'){
                    tsk.ActivityDate = calculateDueDate(tsk.Attempt_1_Date__c, 5);
                }else if(tsk.Priority == 'Urgent'){
                    tsk.ActivityDate = calculateDueDate(tsk.Attempt_1_Date__c, 4);
                }*/
            }
        }
        Map<Id, User> idToUserMap = new SLT_User().selectByUserId(userIdSet, userFieldSet);
        if(contactIdSet != null && contactIdSet.size() > 0) {
            idToContactMap = new SLT_Contact().selectByContactId(contactIdSet, fieldSet);
        }
        if(leadIdSet != null && leadIdSet.size() > 0) {
            idToLeadMap = new SLT_Lead().selectByLeadId(leadIdSet, fieldSet);
        }
        for(Task tsk : newList) {
            if(idToContactMap != null && idToContactMap.size() > 0 && !String.isBlank(tsk.WhoId) && idToContactMap.containsKey(tsk.WhoId)) {
                tsk.Lead_Phone__c = idToContactMap.get(tsk.WhoId).Phone;
                tsk.Lead_Email__c = idToContactMap.get(tsk.WhoId).Email;
            }
            else if(idToLeadMap != null && idToLeadMap.size() > 0 && !String.isBlank(tsk.WhoId) && idToLeadMap.containsKey(tsk.WhoId)) {
                tsk.Lead_Email__c = idToLeadMap.get(tsk.WhoId).Email;
                tsk.Lead_Phone__c = idToLeadMap.get(tsk.WhoId).Phone;
            }
            if(idToUserMap.size() > 0 &&  idToUserMap.containsKey( tsk.OwnerId ) && idToUserMap.get(tsk.OwnerId).ManagerId != null && idToUserMap.get(tsk.OwnerId).Manager.Email != null){
                tsk.Email_Of_Manager__c = idToUserMap.get(tsk.OwnerId).Manager.Email;
            }
        }
    }
    
    /**
    * This method is used to change Lead Owner field .
    * @params  newList List<Task>
    * @params  oldMap Map<Id, Task>
    * @return  void
    */
    public static void changeLeadOwner(List<Task> newList, Map<Id, Task> oldMap) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Lead.SObjectType
            }
        );
        List<Lead> leadList = new List<Lead>();
        for(Task taskRecord : newList) {
            if(taskRecord.recordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID && taskRecord.WhoId != NULL && 'Lead'.equalsIgnoreCase(String.valueOf(taskRecord.WhoId.getSObjectType()))
               && taskRecord.OwnerId != oldMap.get(taskRecord.Id).OwnerId) {
                   leadList.add(new Lead(Id = taskRecord.WhoId, OwnerId = taskRecord.OwnerId));
               }
        }
        if(leadList.size() > 0) {
            uow.registerDirty(leadList);
            uow.commitWork();
        }
    }
    
    /**
    * This method is used to change Contact/Lead Disposition Details fields
    * @params  newList List<Task>
    * @params  oldMap Map<Id, Task>
    * @return  void
    */
    public static void changeDispositionDetailFields(List<Task> newList, Map<Id, Task> oldMap) {
        List<String> dispositionDetailFieldList = new List<String>{'Disposition__c', 'Not_Accept_Reason__c', 'Not_Accept_Reason_Detail__c', 
                                                                  'Nurture_Area__c', 'Nurture_Detail__c', 'Nurture_Detail_Other__c'};
        List<Sobject> leadOrContactList = new List<Sobject>();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Lead.SObjectType,
                Contact.SObjectType
            }
        );
        Boolean toCommit = false;
        for(Task taskRecord : newList) {
            if(taskRecord.recordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID && taskRecord.WhoId != NULL) {
                if('Lead'.equalsIgnoreCase(String.valueOf(taskRecord.WhoId.getSObjectType())) || 'Contact'.equalsIgnoreCase(String.valueOf(taskRecord.WhoId.getSObjectType()))) {    
                    Sobject leadorContactRecord = taskRecord.WhoId.getSobjectType().newSobject(taskRecord.WhoId);
                    Boolean isChanged = false;
                    for(String field : dispositionDetailFieldList) {
                        if(taskRecord.get(field) != oldMap.get(taskRecord.Id).get(field)) {
                            leadorContactRecord.put(field, taskRecord.get(field));
                            isChanged = true;
                        }
                    }
                    if(isChanged) {
                        toCommit = true;
                        uow.registerDirty(leadorContactRecord);
                    }
                }
            }
        }
        if(toCommit) {
            uow.commitWork();
        }
    }
 
    public static void setDisposationField(List<Task> newList,Map<Id, Task> oldMap){
        List<Lead> leadListToUpdate = new List<Lead>();
        List<Contact> contactListToUpdate = new List<Contact>();
        for(Task tsk : newList) {
            if(tsk.Disposition__c != null && tsk.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID && (Trigger.isInsert || (Trigger.isUpdate && tsk.Disposition__c != oldMap.get(tsk.id).Disposition__c))) {
                String whoId = tsk.WhoId;
                if(!String.isBlank(WhoId) && WhoId.startsWith(CON_CRM.CONTACT_OBJECT_CODE)) {
                    Contact con = new Contact();
                    con.Id = whoId;
                    con.Disposition__c = tsk.Disposition__c;
                    contactListToUpdate.add(con);
                }
                else if(!String.isBlank(WhoId) && whoId.startsWith(CON_CRM.LEAD_OBJECT_CODE)) {
                    Lead ld = new Lead();
                    ld.Id = whoId;
                    ld.Disposition__c = tsk.Disposition__c;
                    leadListToUpdate.add(ld);
                }
            }
        }
        if(leadListToUpdate.size() > 0){
            update leadListToUpdate;
        }
        if(contactListToUpdate.size() > 0){
            update contactListToUpdate;
        }
    }
    
     /**
     *  Method to count task which have same campaign.
     *  Method to updated the NoOfMql field on campaign.
     */
    public static void setNoOfMQLInCampaign(List<Task> newList, Map<Id, Task> oldMap){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType> { Campaign.SObjectType }
        );
        Set<String> campaignIdSet = new Set<String>();
        List<AggregateResult> taskRecord;
        Campaign campaign;
        List<Campaign> campaignListToUpdated = new List<Campaign>();
        String disposition = CON_CRM.TASK_Disposition_Accept;
        String recordTypeId = CON_CRM.MQL_TASK_RECORD_TYPE_ID;
        String newCampaign;
        String oldCampaign;
        String oldDisposition;
        String oldRecordTypeId;
        
        if( Trigger.isInsert || Trigger.isUpdate) {
            for(Task task : newList){
                newCampaign = task.Campaign_Name2__c;
                
                if(oldMap != Null){
                    oldCampaign = oldMap.get(task.Id).Campaign_Name2__c;
                    oldDisposition = oldMap.get(task.Id).Disposition__c;
                    oldRecordTypeId = oldMap.get(task.Id).RecordTypeId;
                }
                else{
                    oldCampaign = Null;
                    oldDisposition = NUll;
                    oldRecordTypeId = Null;
                }
                
                if( newCampaign != oldCampaign || task.Disposition__c == disposition || task.Disposition__c != oldDisposition || task.RecordTypeId == recordTypeId || task.RecordTypeId != oldRecordTypeId){ 
                    if(newCampaign != Null && task.Disposition__c == disposition && task.RecordTypeId == recordTypeId){
                        campaignIdSet.add(newCampaign);
                    }
                    if(oldCampaign != Null && oldDisposition == disposition && oldRecordTypeId == recordTypeId){
                        campaignIdSet.add(oldCampaign);
                    }
                } 
            }
            
            if(!campaignIdSet.isEmpty()) {
                taskRecord = new SLT_Task().getTasksByCampaign(campaignIdSet, disposition, recordTypeId );
                List<String> campaignInTaskList = new List<String>();
                for(AggregateResult task : taskRecord){
                    campaign = new Campaign();
                    campaign.Id = (Id)task.get('Campaign_Name2__c');
                    campaign.NoOfMQLs__c = (decimal)task.get('campaignCount');
                    
                    campaignInTaskList.add((String)task.get('Campaign_Name2__c'));
                    campaignListToUpdated.add(campaign);
                }
                
                if(campaignInTaskList.size() != campaignIdSet.size()){                   
                    for(String campaignId : campaignIdSet){
                        if(!campaignInTaskList.contains(campaignId)){
                            campaign = new Campaign();
                            campaign.Id = campaignId;
                            campaign.NoOfMQLs__c = 0;
                            campaignListToUpdated.add(campaign);
                        }
                    } 
                }
            }
            
            if(!campaignListToUpdated.isEmpty()){
                uow.registerDirty(campaignListToUpdated);
                uow.commitWork();
            }
        }
    }
    
    /**
     * This Method is used to count NoOfMql field when task is delete.
     * @params List<Task> newList
     * @return void
     */ 
    public static void countNoOfMqlAfterTaskDelete(List<Task> newList){
         fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType> { Campaign.SObjectType }
        );
        
        Map<Id, Integer> campaignCountMap = new Map<Id, Integer>();
        Map<Id,Campaign> campaignMap;
        List<Campaign> updateCampaignList;
        for(Task task : newList){
            if(task.Campaign_Name2__c != Null && task.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID &&  task.Disposition__c == CON_CRM.TASK_Disposition_Accept){
                if(campaignCountMap.containsKey((task.Campaign_Name2__c))){
                    campaignCountMap.Put(task.Campaign_Name2__c, campaignCountMap.get(task.Campaign_Name2__c) + 1);
                }
                else{
                    campaignCountMap.Put(task.Campaign_Name2__c, 1);
                }
            }
        }
        
        if(campaignCountMap.size() > 0){
            updateCampaignList = new List<Campaign>();
            campaignMap = new SLT_Campaign().selectById(campaignCountMap.keySet());
            for(Campaign campaign : campaignMap.values()){
                campaign.NoOfMQLs__c -= campaignCountMap.get(campaign.Id);
                updateCampaignList.add(campaign);
            }
            
            if(updateCampaignList.size() > 0){
                uow.registerDirty(updateCampaignList);
                uow.commitWork();
            }
        }
    }
    
    /**
     * This Method is used to set type field on Task those created from Outlook.
     * @params List<Task> newList
     * @return void
     */ 
    public static void setTypeFieldonTaskForOutlook(List<Task> newList){
        List<Task> taskToUpdateList = new List<Task>();
        for(Task tsk : newList){
            if(tsk.RecordTypeId == CON_CRM.Standard_TASK_RECORD_TYPE_ID && tsk.TaskSubtype == 'Email' && tsk.Type == null) {
                taskToUpdateList.add(new Task(Id = tsk.Id, Type = 'Email'));
            }
        }
        if(taskToUpdateList.size() > 0) {
            UTL_ExecutionControl.stopTriggerExecution = true;
            update taskToUpdateList;
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
    }
    
    /**
     * This method is used to verify whether the user has permission to edit the fields on specific conditions
     * @params newList List<Task>
     * @params oldMap Map<Id, Task>
     * @return  void
     */ 
    public static void verifyTaskFields(List<Task> newList, Map<Id, Task> oldMap) {
        List<GroupMember> groupMemberList = new SLT_GroupMember().getGroupMembersByUserAndGroupNameSet(UserInfo.getUserId(), new Set<String>{CON_CRM.GROUP_MQL_TASK_MANAGEMENT});
        Id profileId = UserInfo.getProfileId();
        Map<Id, Profile> profileIdToNameMap = new SLT_Profile().selectProfileById(new Set<Id>{profileId}, new Set<String>{'Id', 'Name'});
        if (profileIdToNameMap.containsKey(profileId)) {
            String profileName = profileIdToNameMap.get(profileId).Name;    
            if (groupMemberList.size() == 0 && !(profileName.contains(CON_CRM.SYS_ADMIN) || profileName == CON_CRM.IQVIA_SF_PLATFORM_PROFILE)) {
                for (Task task : newList) {
                    if (task.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID) {
                        if ((Trigger.IsInsert && task.Status == CON_CRM.REJECTED) || (Trigger.isUpdate && task.Status != oldMap.get(task.Id).Status && (task.Status == CON_CRM.REJECTED || oldMap.get(task.Id).Status == CON_CRM.REJECTED))) {
                            task.addError(System.Label.CRM_CL0037_Task_Status_Update_Error);
                        } else if (Trigger.isUpdate && task.Status == CON_CRM.REJECTED && task.Disposition__c != oldMap.get(task.Id).Disposition__c) {
                            task.addError(System.Label.CRM_CL0038_Task_Disposition_Update_Error);
                        }      
                    }
                }  
            }
        }
    }
    
    /**
     * This method is used to fill Campaign_Name2__c by Campaign_Name__c data.
     * @params newList List<Task>
     * @params oldMap Map<Id, Task>
     * @return  void
     */ 
    public static void populateCampaign(List<Task> newList, Map<Id, Task> oldMap) {
        Id campId;
        Set<String> campNameSet = new Set<String>();
        for(Task taskObj : newList) {
            if((Trigger.isInsert || (Trigger.isUpdate && taskObj.Campaign_Name__c != oldMap.get(taskObj.Id).Campaign_Name__c)) && taskObj.Campaign_Name__c != NULL && taskObj.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID) {
                campNameSet.add(taskObj.Campaign_Name__c);
            } else if(Trigger.isUpdate && oldMap.get(taskObj.Id).Campaign_Name__c != NULL && taskObj.Campaign_Name__c == NULL && taskObj.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID) {
                taskObj.Campaign_Name2__c = NULL;
            }
        }
        Map<String, Id> campNametoCampIdMap = new Map<String, Id>();
        if(campNameSet.size() > 0) {
            campNametoCampIdMap = new SLT_Campaign().getCampaignListByName(campNameSet, 'CreatedDate');
            for(Task taskObj : newList) {
                if(taskObj.Campaign_Name__c != NULL && taskObj.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID) {
                    String campName = taskObj.Campaign_Name__c;
                    campId = NULL;
                    if(campNametoCampIdMap.containsKey(campName)) {
                        campId = campNametoCampIdMap.get(campName);
                    }
                    taskObj.Campaign_Name2__c = NULL;
                    if(campId != NULL) {
                        taskObj.Campaign_Name2__c = campId;
                    }
                }
            }
        }
    }
    
    /**
     * This method is used to verify whether current user is able to Delete an MQL Task or not.
     * @params newList List<Task>
     * @return  void
     */ 
    public static void verifyMQLTasksDeletion(List<Task> tasks){
        MQL_Task_Delete_Setting__c mqlTaskDeleteSetting = MQL_Task_Delete_Setting__c.getInstance();

        Boolean isAllowed = false;
        String employeeNumber = UTL_GLOBAL.getUserWithProfile(new Set<Id>{UserInfo.getUserId()}).get(UserInfo.getUserId()).EmployeeNumber;
        if(mqlTaskDeleteSetting.Employee_Numbers__c != null){
            List<String> employeeNumbers = mqlTaskDeleteSetting.Employee_Numbers__c.split(',');
            if(employeeNumbers.contains(employeeNumber))
               isAllowed = true;
        }
        
        for(Task tsk: tasks){
            if(tsk.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID){
                if(!isAllowed){
                    tsk.addError(MQL_TASK_DELETE_ERROR_MSG);
                }    
            }
        }
    }
    
    /**
     * This method user to mark task as rejected if created by eloqua user
     * @params newList List<Task>
     * @params oldMap Map<Id, Task>
     * @return  void
     */ 
    public static void markMQLTaskRejected(List<Task> newList, Map<Id,Task> oldMap){
        String userName = 'Eloqua App User';
        CRM_Config__c crmConfig = CRM_Config__c.getOrgDefaults();
        String emailDomains = crmConfig.Lead_Email_Domains__c;
        List<String> leadEmailDomainList = new List<String>();
        if(String.isNotBlank(emailDomains)){
            leadEmailDomainList = emailDomains.split(':');
        }
        if(UserInfo.getName() == userName){
            for(Task tsk : newList){
                if(String.isNotBlank(tsk.Lead_Email__c) && tsk.RecordTypeId == CON_CRM.MQL_TASK_RECORD_TYPE_ID && leadEmailDomainList.contains((tsk.Lead_Email__c).substringAfter('@'))){
                    tsk.Status = 'Rejected';
                    tsk.Not_Accept_Reason__c = 'Junk/Spam/Phishing/Test Data';
                    tsk.Disposition__c = 'Not Accept';
                }
            }
        }
    }
    
    /**
     * This method calculate the due date from given date, after adding days and exlcluding Saturday and Sunday.
     * @params Date fromDate
     * @params Integer days
     * @return  Date
     */ 
    /*
    public static Date calculateDueDate(Date fromDate, Integer days){
        Integer index = 0;
        Date resultDate = fromDate;
        Date startDate = Date.newInstance(1970, 01, 04);
        while(index < days){
            Integer numberOfDays = startDate.daysBetween(resultDate + 1);
            Integer weekDay = Math.mod(numberOfDays,7);
            If(weekDay != 6 && weekDay != 0){
                index++;
            }
            resultDate = resultDate + 1;
        }
        return resultDate;
    }
*/
}