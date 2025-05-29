public class DAOH_ActivityC {
    /**
    * This method is used for create a new Data Audit Trail when the new case record is created.
    * @params  newList List<Activity__c>
    * @return  void
    */
    
    public static void saveAuditLogAfterInsertActivityC(List<Activity__c> newList){
        CSM_QI_Data_Audit_Trail__c auditTrail = null;
        Map<ID,Schema.RecordTypeInfo> rt_Map = Activity__c.sObjectType.getDescribe().getRecordTypeInfosById();
        List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
        for(Activity__c c : newList) {
            
            if(newList.size() > 0)
            {
                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CREATED,Name = CON_CSM.S_ACTIVITYC,Activity__c = c.Id);
                auditTrailList.add(auditTrail);
            }
            
        }
        
        try {
            if(auditTrailList != null && auditTrailList.size()>0){
                insert auditTrailList;  
            }
        } catch (DmlException e) {
            System.debug('Failed due to : '+e);
        }
        
    }
    
    /**
    * This method is used for create a new Data Audit Trail when the case record fields are updated.
    * @params  newList List<Activity__c>,oldMap Map<Id, Activity__c> 
    * @return  void
    */
    public static void saveAuditLogAfterUpdateActivityCFields(List<Activity__c> newList, Map<Id, Activity__c> oldMap,List<FieldDefinition> fields) {
        
        if(fields != null && fields.size() > 0){
            
            CSM_QI_Data_Audit_Trail__c auditTrail = null;
            List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
            Map<ID,Schema.RecordTypeInfo> rt_Map = Activity__c.sObjectType.getDescribe().getRecordTypeInfosById();
            EXT_CSM_CaseRelatedToObject relatedTo = null;
            List<EXT_CSM_CaseRelatedToObject> relatedToList = new List<EXT_CSM_CaseRelatedToObject>(); 
            
            for(Activity__c c : newList) {
                if(fields.size() > 0 ) 
                {
                    for( FieldDefinition fd : fields){
                        
                        if(String.isBlank(fd.ExtraTypeInfo) && ((fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PICKLIST) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_NUMBER) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_DOUBLE)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATETIME)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATE)))){
                            if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                auditTrail =  new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Activity__c = c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Activity__c = c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Activity__c = c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }else if(String.isBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_LOOKUP) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_ID)){
                            if(c.get(fd.QualifiedApiName) ==  null && oldMap.get(c.Id).get(fd.QualifiedApiName) !=  null){
                                relatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_DELETED,fd.RelationshipName,CON_CSM.S_ACTIVITYC,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),null,c.Id);
                                relatedToList.add(relatedTo);
                            }else if(c.get(fd.QualifiedApiName) !=  null && oldMap.get(c.Id).get(fd.QualifiedApiName) ==  null){
                                relatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_ADDED,fd.RelationshipName,CON_CSM.S_ACTIVITYC,fd.MasterLabel,null,(Id)c.get(fd.QualifiedApiName),c.Id);
                                relatedToList.add(relatedTo);    
                            }else if(c.get(fd.QualifiedApiName) !=  null && oldMap.get(c.Id).get(fd.QualifiedApiName) !=  null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                relatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_CHANGED,fd.RelationshipName,CON_CSM.S_ACTIVITYC,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),(Id)c.get(fd.QualifiedApiName),c.Id);
                                relatedToList.add(relatedTo);
                            }
                        }else if(String.isNotBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)){
                            if(c.get(fd.QualifiedApiName) !=  null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = fd.MasterLabel,Old_Text_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),Activity__c = c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }
                        
                    }
                }
            }
            
            if(relatedToList.size()>0)
            {
                Set<Id> accSet = new Set<Id>(),cntSet = new Set<Id>(),studSet = new Set<Id>(),userSet = new Set<Id>(),csSet = new Set<Id>();
                
                for(EXT_CSM_CaseRelatedToObject obj : relatedToList){
                    if(CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        accSet.add(obj.oldId);
                        accSet.add(obj.newId);
                    }else if(CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        cntSet.add(obj.oldId);
                        cntSet.add(obj.newId);
                    }else if(CON_CSM.S_STUDYC.equals(obj.objRelName)){
                        studSet.add(obj.oldId);
                        studSet.add(obj.newId);
                    }else if(CON_CSM.S_USER.equals(obj.objRelName)){
                        userSet.add(obj.oldId);
                        userSet.add(obj.newId);
                    }
                    
                }
                Set<String> fieldSet = new Set<String> {CON_CSM.S_ID, CON_CSM.S_NAME};
                Map<Id, Account> accountMap  = null;
                Map<Id, Contact> contactMap  = null;
                Map<Id, User> userMap = null;
                Map<Id, Study__c> studyMap = null;
                Map<Id, Case> csMap = null;
                if(accSet.size() > 0) accountMap = new SLT_Account().selectByAccountId(accSet, fieldSet);
                if(cntSet.size() > 0) contactMap = new SLT_Contact().selectByContactId(cntSet, fieldSet);
                if(userSet.size() > 0)  userMap = new SLT_User().selectByUserId(userSet, fieldSet);
                if(studSet.size() > 0) studyMap = new SLT_StudyC().selectByStudyId(studSet, fieldSet);
                
                for(EXT_CSM_CaseRelatedToObject obj : relatedToList){
                    
                    if(accountMap !=  null && accountMap.size() > 0 && CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Activity__c  =  obj.objectId,Old_Value__c = accountMap.containsKey(obj.oldId)?accountMap.get(obj.oldId).Name :'',New_Value__c = accountMap.containsKey(obj.newId)?accountMap.get(obj.newId).Name:'');
                        auditTrailList.add(auditTrail);
                    }else if(contactMap !=  null && contactMap.size() > 0 && CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Activity__c  =  obj.objectId,Old_Value__c = contactMap.containsKey(obj.oldId) ? contactMap.get(obj.oldId).Name : '',New_Value__c = contactMap.containsKey(obj.newId) ? contactMap.get(obj.newId).Name : '');
                        auditTrailList.add(auditTrail);
                    }else if(userMap !=  null && userMap.size() > 0 && CON_CSM.S_USER.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Activity__c  =  obj.objectId,Old_Value__c = userMap.containsKey(obj.oldId) ? userMap.get(obj.oldId).Name : '',New_Value__c = userMap.containsKey(obj.newId) ? userMap.get(obj.newId).Name : '');
                        auditTrailList.add(auditTrail);
                    }else if(studyMap !=  null && studyMap.size() > 0 && CON_CSM.S_STUDYC.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Activity__c  =  obj.objectId,Old_Value__c = studyMap.containsKey(obj.oldId) ? studyMap.get(obj.oldId).Name : '',New_Value__c = studyMap.containsKey(obj.newId) ? studyMap.get(obj.newId).Name : '');
                        auditTrailList.add(auditTrail);
                    }
                    
                }
            }
            
            
            try {
                if(auditTrailList !=  null && auditTrailList.size() > 0){
                    insert auditTrailList;
                }
                
            } catch (DmlException e) {
                System.debug('Failed due to : '+e);
            }
        }
        
    }
    
    public static void updateCaseFields(List<Activity__c> newList, Map<Id, Activity__c> oldMap){
        Map<Id,String> caseTypeMap = new Map<Id,String>();
        String caseId = null;
        List<Case> caseList = null;
        List<Case> updateCases = new List<Case>();
        for(Activity__c a : newList){
            if(a.Case__c != null && (oldMap == null || (oldMap != null && oldMap.get(a.Id).Type__c != a.Type__c)) && (a.Type__c == 'Email - Outbound' || a.Type__c == 'Call - Outbound' || a.Type__c == 'IM Communication')){
                caseTypeMap.put(a.Case__c,a.Type__c);
            }  
        }
        if(!caseTypeMap.isEmpty()){
            caseList = new SLT_Case().selectByCaseIdList(caseTypeMap.keySet(),new Set<String> {'Id','Email_Outbound_Exists__c','Call_Outbound_Exists__c','IM_Communication_Exists__c'});
            for(Case cs : caseList){
                if(caseTypeMap.containsKey(cs.Id)){
                    if(caseTypeMap.get(cs.Id) == 'Email - Outbound' && !cs.Email_Outbound_Exists__c){
                        cs.Email_Outbound_Exists__c = true;
                        updateCases.add(cs);
                    }else if(caseTypeMap.get(cs.Id) == 'Call - Outbound' && !cs.Call_Outbound_Exists__c){
                        cs.Call_Outbound_Exists__c = true;
                        updateCases.add(cs);
                    }else if(caseTypeMap.get(cs.Id) == 'IM Communication' && !cs.IM_Communication_Exists__c){
                        cs.IM_Communication_Exists__c = true;
                        updateCases.add(cs);
                    }
                }
            }
            if(!updateCases.isEmpty()){
                update updateCases;
            }
        }
        
    }
    
	public static void addTimesheet(List<Activity__c> newList, Map<Id, Activity__c> oldMap){
         Set<Id> caseIds = new Set<Id>();
        Set<Id> tcaseIds = new Set<Id>();
        String caseId = null;
        List<Case> caseList = null;
        for(Activity__c a : newList){
            if(a.Case__c != null ){
                caseIds.add(a.Case__c);
            }  
        }
        if(!caseIds.isEmpty()){
            caseList = new SLT_Case().selectById(caseIds);
            for(Case cs : caseList){
                if(CON_CSM.S_ALLOWED_RT_TIMESHEET.contains(cs.RecordTypeName__c)){
                    tcaseIds.add(cs.Id); 
                    caseId = cs.Id;
                }
            }
        }
        if(!tcaseIds.isEmpty() && !System.isBatch() && !System.isFuture()){
            DAOH_Case.stopTechAutoTimer(tcaseIds,caseId,'Activity');
        }
    }
	
    /**
    * This method is used for create a new Data Audit Trail when the case record fields are updated.
    * @params  newList List<Activity__c>,oldMap Map<Id, Activity__c> 
    * @return  void
    */
    public static void updateActivityAutoFillSiteContactStudy(List<Activity__c> newList, Map<Id, Activity__c> oldMap){
        Set<Id> caseIds = new Set<Id>();
        Set<Activity__c> acts = new Set<Activity__c>();
        for(Activity__c a : newList){
            if(a.Case__c != null && (Trigger.isInsert || ( Trigger.isUpdate && oldMap != null && oldMap.get(a.Id) != null && 
              (a.Site__c != oldMap.get(a.Id).Site__c || a.Contact__c != oldMap.get(a.Id).Contact__c || a.Study__c != oldMap.get(a.Id).Study__c || a.Case__c != oldMap.get(a.Id).Case__c) ) )){
                   caseIds.add(a.Case__c);
                   acts.add(a);
               }
           
            if(Trigger.isInsert && 'Done' == a.Status__c){
                if(a.CloseDatetime__c == null && a.StartDatetime__c != null) a.CloseDatetime__c = System.now() + 0.000011;
                if(a.CloseDatetime__c == null && a.StartDatetime__c == null) {
                    a.StartDatetime__c = System.now();
                    a.CloseDatetime__c = System.now() + 0.000011;
                }
            }else if( a.Status__c != null && oldMap != null && 'Done' == a.Status__c && a.Status__c != oldMap.get(a.Id).Status__c){
                if(a.CloseDatetime__c == null ) a.CloseDatetime__c = System.now();
            }else if( a.Status__c != null && oldMap != null && 'Done' != a.Status__c && a.Status__c != oldMap.get(a.Id).Status__c){
                if(a.CloseDatetime__c != null ) a.CloseDatetime__c = null;
            }
            if(a.RecordTypeId == null) a.RecordTypeId = CON_CSM.S_ACTIVITY_RT;
        }
        
        if(caseIds != null && !caseIds.isEmpty()){
            Map<Id,Case> caseMap = new SLT_Case().getCaseById(caseIds, new Set<String>{'AccountId','Study__c','ContactId','LOS__c','RandD_Location__c'});
            if(caseMap != null && !caseMap.isEmpty() ){
                for(Activity__c ac : acts){
                    if(caseMap.containsKey(ac.Case__c)){
                        if((oldMap != null && ac.Case__c != oldMap.get(ac.Id).Case__c) || Trigger.isInsert){
                            if(caseMap.get(ac.Case__c).AccountId != null) ac.Site__c = caseMap.get(ac.Case__c).AccountId;
                            if(caseMap.get(ac.Case__c).Study__c != null) ac.Study__c = caseMap.get(ac.Case__c).Study__c;
                            if(caseMap.get(ac.Case__c).ContactId != null) ac.Contact__c = caseMap.get(ac.Case__c).ContactId;
                            if(caseMap.get(ac.Case__c).LOS__c != null){
                                ac.LOS__c = caseMap.get(ac.Case__c).LOS__c;
                                if(caseMap.get(ac.Case__c).LOS__c == 'LTMS Investigator Site Support' || caseMap.get(ac.Case__c).LOS__c == 'Q² Lab Investigator Services'){
                                    ac.LOS__c = 'Q² Investigator Site Support';
                                }
                            }
                            if(caseMap.get(ac.Case__c).RandD_Location__c != null) ac.RandD_Location__c = caseMap.get(ac.Case__c).RandD_Location__c;
                        }else{
                            if(ac.Site__c == null) ac.Site__c = caseMap.get(ac.Case__c).AccountId;
                            if(ac.Study__c == null) ac.Study__c = caseMap.get(ac.Case__c).Study__c;
                            if(ac.Contact__c == null) ac.Contact__c = caseMap.get(ac.Case__c).ContactId;
                            if(ac.LOS__c == null){
                                ac.LOS__c = caseMap.get(ac.Case__c).LOS__c;
                                if(caseMap.get(ac.Case__c).LOS__c == 'LTMS Investigator Site Support' || caseMap.get(ac.Case__c).LOS__c == 'Q² Lab Investigator Services'){
                                    ac.LOS__c = 'Q² Investigator Site Support';
                                }
                            }
                            if(ac.RandD_Location__c == null) ac.RandD_Location__c = caseMap.get(ac.Case__c).RandD_Location__c;
                        }
                    }
                    if(ac.ActivityOwner__c == null) ac.ActivityOwner__c = UserInfo.getUserId();
                }
            }
        }
    }
    
    public static void sendOutlookMeetingRequest(List<Activity__c> newList, Map<Id, Activity__c> oldMap) {
        for(Activity__c activity: newList) {
            if(activity.Case__c != null && activity.Contact__c != null && activity.Type__c == CON_CSM.S_APPOINTMENT && activity.EscalationType__c == CON_CSM.S_CALL 
               && activity.Appointment_Date_And_Time__c != null && activity.Appointment_Date_And_Time__c > System.now()
               && (Trigger.isInsert || (Trigger.isUpdate && oldMap != null && oldMap.get(activity.Id) != null && activity.Appointment_Date_And_Time__c != oldMap.get(activity.Id).Appointment_Date_And_Time__c ))){
                   List<Case> caseList = new SLT_Case().selectByCaseIdList(new Set<Id>{activity.Case__c}, new Set<String>{'RecordTypeName__c'});
                   Case caseRecord = caseList != null && caseList.size() > 0 ? caseList[0] : null;
                   if(caseRecord != null && caseRecord.RecordTypeName__c == CON_CSM.S_RDCASE || caseRecord.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) {
                       List<EmailTemplate> emailTempList = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(CON_CSM.S_CAS_ET_CSM_CALENDAR_APPOINTMENT, new Set<String> {'Id', 'Subject', 'Body'});
                       EmailTemplate emailTemplate = (emailTempList != null && emailTempList.size() > 0) ? emailTempList[0] : null;
                       List<CSM_LOS_Based_Distribution__c> losBasedDistributionList = CSM_LOS_Based_Distribution__c.getall().values();
                       String recipientEmail;
                       for(CSM_LOS_Based_Distribution__c losBasedDistribution: losBasedDistributionList) {
                           if(losBasedDistribution.LOS__c == activity.LOS__c) {
                               recipientEmail = losBasedDistribution.Distribution_List__c;
                               break;
                           }
                       }
                       if(recipientEmail != null && recipientEmail != '' && emailTemplate != null) {
                           String subject = activity.Name+' - '+ activity.Type__c+' - '+activity.EscalationType__c;
                           DateTime appointmentDateTime = activity.Appointment_Date_And_Time__c;
                           String[] toAddresses = new String[] {recipientEmail};
                           String description = emailTemplate.subject;
                           
                           Blob fileBody = EXT_CSM_CalendarEvent.ext_GenerateEvent(recipientEmail, subject, description, appointmentDateTime, appointmentDateTime, subject, 0);
                           
                           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                           mail.setTargetObjectId(activity.Contact__c);
                           mail.setTreatTargetObjectAsRecipient(false);
                           mail.setTemplateId(emailTemplate.Id);
                           mail.setWhatId(activity.Id);
                           mail.setSaveAsActivity(false);
                           mail.setToAddresses(toAddresses);
                           
                           Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                           attach.filename = 'invite.ics';
                           attach.ContentType = 'text/calendar; charset=utf-8; method=REQUEST;';
                           attach.inline = true;
                           attach.body = fileBody;
                           mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
                           Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] {mail});
                       }
                  }
              }
        }
    }
    
    public static void checkForAttachmentOnRDCaseActivities(List<Activity__c> activityList, Map<Id, Activity__c> oldActivities){
        Set<Id> activityIds = new Set<Id>();
        Map<Id, Integer> linkedIdEntityMap = new Map<Id, Integer>();
        Boolean hasCustomPermission = FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
        for(Activity__c actRecord : activityList){
            if(actRecord.Status__c == CON_CSM.S_STATUS_DONE && actRecord.LOS__c != null && actRecord.LOS__c == CON_CSM.S_ACCOUNT_MANAGEMENT && 
               actRecord.Type__c != null && actRecord.Type__c == CON_CSM.S_QUALITY_CHECK){
                activityIds.add(actRecord.Id);
                linkedIdEntityMap.put(actRecord.Id, 0);
            }
        }
        
        if(activityIds != null && !activityIds.isEmpty()){
            List<ContentDocumentLink> contentList = new SLT_ContentDocumentLink().getContentDocumentBasedOnLinkedEntity(activityIds);
            if(contentList != null && !contentList.isEmpty()){
                for(ContentDocumentLink cdlRecord : contentList){
                    Integer count = linkedIdEntityMap.get(cdlRecord.LinkedEntityId);
                    count = count+1;
                    linkedIdEntityMap.remove(cdlRecord.LinkedEntityId);
                    linkedIdEntityMap.put(cdlRecord.LinkedEntityId, count);
                }
            }
            
            for(Activity__c actRecord : activityList){
                if(linkedIdEntityMap.containsKey(actRecord.Id)){
                    if(linkedIdEntityMap.get(actRecord.Id) == 0 && hasCustomPermission == false){
                        actRecord.addError('Activity should contain an attachment');
                    }
                }
            }
        }
    }
}
