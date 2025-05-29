public class DAOH_Study {
    /**
    * This method is used for create a new Data Audit Trail when the new case record is created.
    * @params  newList List<Study__c>
    * @return  void
    */
    
    public static void saveAuditLogAfterInsertStudy(List<Study__c> newList){
        CSM_QI_Data_Audit_Trail__c auditTrail = null;
        Map<ID,Schema.RecordTypeInfo> rt_Map  =  Study__c.sObjectType.getDescribe().getRecordTypeInfosById();
        List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
        for(Study__c c : newList) {
            if(newList.size() > 0)
            {
                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CREATED,Name = CON_CSM.S_STUDYC,Study__c  =  c.Id);
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
    * This method is used for create a new Data Audit Trail when the case record fields are updated.
    * @params  newList List<Study__c>,oldMap Map<Id, Study__c> 
    * @return  void
    */
    public static void saveAuditLogAfterUpdateStudyFields(List<Study__c> newList, Map<Id, Study__c> oldMap,List<FieldDefinition> fields) {
      
        if(fields != null && fields.size() > 0){
            
            CSM_QI_Data_Audit_Trail__c auditTrail = null;
            List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
            Map<ID,Schema.RecordTypeInfo> rt_Map  =  Study__c.sObjectType.getDescribe().getRecordTypeInfosById();
            EXT_CSM_CaseRelatedToObject studyRelatedTo = null;
            List<EXT_CSM_CaseRelatedToObject> studyRelatedToList = new List<EXT_CSM_CaseRelatedToObject>(); 
            
            for(Study__c c : newList) {
                
                if(fields.size() > 0 ) 
                {
                    for( FieldDefinition fd: fields){
                        
                        if(String.isBlank(fd.ExtraTypeInfo) && ((fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PICKLIST) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_NUMBER) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_DOUBLE)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_URL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PHONE) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_EMAIL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_CHECKBOX) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_BOOLEAN)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_FORMULA) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_TEXT)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATETIME)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATE)))){
                            if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Study__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Study__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Study__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }else if(String.isBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_LOOKUP) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_ID)){
                            if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                studyRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_DELETED,fd.RelationshipName,CON_CSM.S_STUDYC,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),null,c.Id);
                                studyRelatedToList.add(studyRelatedTo);
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                studyRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_ADDED,fd.RelationshipName,CON_CSM.S_STUDYC,fd.MasterLabel,null,(Id)c.get(fd.QualifiedApiName),c.Id);
                                studyRelatedToList.add(studyRelatedTo);    
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                studyRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_CHANGED,fd.RelationshipName,CON_CSM.S_STUDYC,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),(Id)c.get(fd.QualifiedApiName),c.Id);
                                studyRelatedToList.add(studyRelatedTo);
                            }
                        }else if(String.isNotBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)){
                            if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = fd.MasterLabel,Old_Text_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),Study__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }
                        
                    }
                }
            }
            
            if(studyRelatedToList.size() > 0)
            {
                Set<Id> accSet = new Set<Id>(),userSet = new Set<Id>(),conSet = new Set<Id>();
                
                for(EXT_CSM_CaseRelatedToObject obj : studyRelatedToList){
                    if(CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        accSet.add(obj.oldId);
                        accSet.add(obj.newId);
                    }else if(CON_CSM.S_USER.equals(obj.objRelName)){
                        userSet.add(obj.oldId);
                        userSet.add(obj.newId);
                    }else if(CON_CSM.S_USER.equals(obj.objRelName)){
                        userSet.add(obj.oldId);
                        userSet.add(obj.newId);
                    }else if(CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        conSet.add(obj.oldId);
                        conSet.add(obj.newId);
                    }
                }
                Set<String> fieldSet  =  new Set<String> {CON_CSM.s_id, CON_CSM.s_name};
                Map<Id, Account> accountMap  = null;
                Map<Id, User> userMap  = null;
                Map<Id, Contact> conMap = null;
                if(accSet.size() > 0) accountMap  =  new SLT_Account().selectByAccountId(accSet, fieldSet);
                if(userSet.size() > 0) userMap  =  new SLT_User().selectByUserId(userSet, fieldSet);
                if(conSet.size() > 0)  conMap  =  new SLT_Contact().selectByContactId(conSet, fieldSet);
                for(EXT_CSM_CaseRelatedToObject obj : studyRelatedToList){
                    
                    if(accountMap != null && accountMap.size() > 0 && CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Study__c  =  obj.objectId,Old_Value__c = accountMap.containsKey(obj.oldId) ? accountMap.get(obj.oldId).Name : '',New_Value__c = accountMap.containsKey(obj.newId) ? accountMap.get(obj.newId).Name : '');
                        auditTrailList.add(auditTrail);
                    }else if(userMap != null && userMap.size() > 0 && CON_CSM.S_USER.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Study__c  =  obj.objectId,Old_Value__c = userMap.containsKey(obj.oldId) ? userMap.get(obj.oldId).Name : '',New_Value__c = userMap.containsKey(obj.newId) ? userMap.get(obj.newId).Name : '');
                        auditTrailList.add(auditTrail);
                    }else if(conMap != null && conMap.size() > 0 && CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Study__c  =  obj.objectId,Old_Value__c = conMap.containsKey(obj.oldId) ? conMap.get(obj.oldId).Name : '',New_Value__c = conMap.containsKey(obj.newId) ? conMap.get(obj.newId).Name : ''); 
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
    public static void updateCaseWithStudyFields(List<Study__c> newList, Map<Id, Study__c> oldMap){
        Study__c value=null;
        Map<Id,Study__c> stringMap=new Map<Id,Study__c>();
        for(Study__c c : newList) {
            value = new Study__c();
            value.StudyID__c = String.valueOf(c.get(CON_CSM.S_STUDYID_C));
            value.Name = String.valueOf(c.get(CON_CSM.S_NAME));
            value.LabProjectCode__c = String.valueOf(c.get(CON_CSM.S_LABPROJECTCODE_C));
            stringMap.put(c.Id, value); 
            
        }
        if(stringMap.isEmpty() == false){
            List<Case> caseList = new SLT_Case().selectByStudyIdList(stringMap.keySet(), new Set<String>{CON_CSM.S_ID,CON_CSM.CS_STUDYPROTOCOLNAME_C,CON_CSM.CS_LABPROJECTCODE_C,CON_CSM.CS_PROJECTCODE_C,CON_CSM.S_STUDYC});
            for(Case c: caseList)
            {
                if(stringMap.containsKey(c.Study__c))
                {
                    if(c.ProjectCode__c != stringMap.get(c.Study__c).StudyID__c){
                        c.ProjectCode__c = stringMap.get(c.Study__c).StudyID__c;  
                    }
                    if(c.StudyProtocolName__c != stringMap.get(c.Study__c).Name){
                        c.StudyProtocolName__c = stringMap.get(c.Study__c).Name;  
                    }
                    /* if(c.LabProjectCode__c != stringMap.get(c.Study__c).LabProjectCode__c){
                        c.LabProjectCode__c = stringMap.get(c.Study__c).LabProjectCode__c;  
                    } */
                    
                }
                
            }
            try{
                if(caseList.isEmpty() == false){ 
                    update caseList; 
                }
            } catch (DmlException e) {
                System.debug('Failed due to : '+e);
            }
        }
    }
    public static void DuplicateCheck(List<Study__c> newList){
        string removeSpecialChar;
        ID profileID = userinfo.getProfileId();
        List<Profile> profileName =new List<Profile>();
        profileName = [SELECT Name FROM profile WHERE id = :profileID LIMIT 1];
        string removeSpecialCharOneChar;
        List<string> removeSpecialCharForAllData = new List<String>();
        List<Study__c> allData = new SLT_StudyC().selectAllStudies(new Set<String>{CON_CSM.S_NAME});
        if(profileName.size()>0 && profileName[0].Name == CON_CSM.S_PROFILENAME){
           for(integer i=0;i< allData.size();i++){
               removeSpecialCharOneChar = allData[i].Name.replaceAll('-','');
               removeSpecialCharOneChar = removeSpecialCharOneChar.replaceAll(' ','');
               removeSpecialCharOneChar = removeSpecialCharOneChar.replaceAll('_','');
               removeSpecialCharForAllData.add(removeSpecialCharOneChar);
           }
           for(Study__c studyVar : newList){
               removeSpecialChar = studyVar.Name.replaceAll('-','');
               removeSpecialChar = removeSpecialChar.replaceAll(' ','');
               removeSpecialChar = removeSpecialChar.replaceAll('_','');
               for(integer var=0 ;var<removeSpecialCharForAllData.size();var++){
                   if(removeSpecialCharForAllData[var]==removeSpecialChar){
                       studyVar.addError(System.Label.Protocol_name_already_Exists_please_use_other_one);
                   }
               }
           }
        }
    }
}