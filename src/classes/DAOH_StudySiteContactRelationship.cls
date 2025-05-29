public class DAOH_StudySiteContactRelationship {
    /**
    * This method is used for create a new Data Audit Trail when the new case record is created.
    * @params  newList List<StudySiteContactRelationship__c>
    * @return  void
    */
    
    public static void saveAuditLogAfterInsertStudySiteContactRelationship(List<StudySiteContactRelationship__c> newList){
        CSM_QI_Data_Audit_Trail__c auditTrail = null;
        Map<ID,Schema.RecordTypeInfo> rt_Map  =  StudySiteContactRelationship__c.sObjectType.getDescribe().getRecordTypeInfosById();
        List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
        for(StudySiteContactRelationship__c c : newList) {
            if(newList.size() > 0)
            {
                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CREATED,Name = CON_CSM.S_STUDY_SITE_CON_RELATIONSHIP,StudySiteContactRelationship__c  =  c.Id);
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
    * @params  newList List<StudySiteContactRelationship__c>,oldMap Map<Id, StudySiteContactRelationship__c> 
    * @return  void
    */
    public static void saveAuditLogAfterUpdateStudySiteContactRelationshipFields(List<StudySiteContactRelationship__c> newList, Map<Id, StudySiteContactRelationship__c> oldMap,List<FieldDefinition> fields) {
        
        if(fields != null && fields.size() > 0){
            
            CSM_QI_Data_Audit_Trail__c auditTrail = null;
            List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
            EXT_CSM_CaseRelatedToObject studyRelatedTo = null;
            List<EXT_CSM_CaseRelatedToObject> studyRelatedToList = new List<EXT_CSM_CaseRelatedToObject>(); 
            for(StudySiteContactRelationship__c c : newList) {
                
                if(fields.size() > 0 ) 
                {
                    for( FieldDefinition fd: fields){
                        if(String.isBlank(fd.ExtraTypeInfo) && ((fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PICKLIST) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_NUMBER) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_DOUBLE)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_URL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PHONE) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_EMAIL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_CHECKBOX) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_BOOLEAN)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_FORMULA) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_TEXT)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATETIME)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATE)))){
                            if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),StudySiteContactRelationship__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),StudySiteContactRelationship__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),StudySiteContactRelationship__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }else if(String.isBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_LOOKUP) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_ID)){
                            if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                studyRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_DELETED,fd.RelationshipName,CON_CSM.S_STUDY_CONTACT_RELATIONSHIP,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),null,c.Id);
                                studyRelatedToList.add(studyRelatedTo);
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                studyRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_ADDED,fd.RelationshipName,CON_CSM.S_STUDY_SITE_CON_RELATIONSHIP,fd.MasterLabel,null,(Id)c.get(fd.QualifiedApiName),c.Id);
                                studyRelatedToList.add(studyRelatedTo);    
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                studyRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_CHANGED,fd.RelationshipName,CON_CSM.S_STUDY_SITE_CON_RELATIONSHIP,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),(Id)c.get(fd.QualifiedApiName),c.Id);
                                studyRelatedToList.add(studyRelatedTo);
                            }
                        }else if(String.isNotBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)){
                            if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = fd.MasterLabel,Old_Text_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),StudySiteContactRelationship__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }
                    }
                }
            }
            
            
            if(studyRelatedToList.size() > 0)
            {
                Set<Id> studySet = new Set<Id>(),accSet = new Set<Id>(),conSet = new Set<Id>();
                
                for(EXT_CSM_CaseRelatedToObject obj : studyRelatedToList){
                    if(CON_CSM.S_STUDYC.equals(obj.objRelName)){
                        studySet.add(obj.oldId);
                        studySet.add(obj.newId);
                    }else if(CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        accSet.add(obj.oldId);
                        accSet.add(obj.newId);
                    }else if(CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        conSet.add(obj.oldId);
                        conSet.add(obj.newId);
                    }
                }
                Set<String> fieldSet  =  new Set<String> {CON_CSM.s_id, CON_CSM.s_name};
                Map<Id, Study__c> studyMap  = null;
                Map<Id, Account> accMap  = null;
                Map<Id, Contact> conMap  = null;
                if(studySet.size() > 0) studyMap  =  new SLT_StudyC().selectByStudyId(studySet, fieldSet);
                if(accSet.size() > 0) accMap  =  new SLT_Account().selectByAccountId(accSet, fieldSet);
                if(conSet.size() > 0) conMap  =  new SLT_Contact().selectByContactId(conSet, fieldSet);
                for(EXT_CSM_CaseRelatedToObject obj : studyRelatedToList){
                    
                    if(studyMap != null && studyMap.size() > 0 && CON_CSM.S_STUDYC.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,StudySiteContactRelationship__c = obj.objectId,Old_Value__c = studyMap.containsKey(obj.oldId) ? studyMap.get(obj.oldId).Name : '',New_Value__c = studyMap.containsKey(obj.newId) ? studyMap.get(obj.newId).Name : '');
                        auditTrailList.add(auditTrail);
                    }else if(accMap != null && accMap.size() > 0 && CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,StudySiteContactRelationship__c = obj.objectId,Old_Value__c = accMap.containsKey(obj.oldId) ? accMap.get(obj.oldId).Name : '',New_Value__c = accMap.containsKey(obj.newId) ? accMap.get(obj.newId).Name : '');
                        auditTrailList.add(auditTrail);
                    }else if(conMap != null && conMap.size() > 0 && CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,StudySiteContactRelationship__c = obj.objectId,Old_Value__c = conMap.containsKey(obj.oldId) ? conMap.get(obj.oldId).Name : '',New_Value__c = conMap.containsKey(obj.newId) ? conMap.get(obj.newId).Name : '');
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
    
    public static void updateCaseWithSiteContactFields(List<StudySiteContactRelationship__c> newList, Map<Id, StudySiteContactRelationship__c> oldMap){
        StudySiteContactRelationship__c value=null;
        Map<Id,String> accountMap = new Map<Id,String>();
        List<Account> accountList = null;
        Map<Id,Id> siteAccountMap =new Map<Id,Id>();
        Map<Id,StudySiteContactRelationship__c> stringMap=new Map<Id,StudySiteContactRelationship__c>();
        for(StudySiteContactRelationship__c c : newList) {
            value = new StudySiteContactRelationship__c();
            value.SiteNumber__c = String.valueOf(c.get(CON_CSM.S_SITENUM_C));
            value.Lab_Site_Number__c = String.valueOf(c.get(CON_CSM.S_LABSITENUM_C));
            siteAccountMap.put(c.Site_Name__c, c.Id);
            stringMap.put(c.Id, value); 
            
        }
        if(siteAccountMap.size() > 0){
            accountList  =  new SLT_Account().selectById( siteAccountMap.keySet());
            if(accountList != null){
                for(Account acc : accountList){
                    accountMap.put(siteAccountMap.get(acc.Id),acc.Name);
                }
            }
            
        } 
        if(stringMap.isEmpty() == false){
            List<Case> caseList = new SLT_Case().selectByStudyStudySiteContactIdList(stringMap.keySet(),new Set<String>{CON_CSM.S_ID,CON_CSM.S_CASENUM,CON_CSM.CS_SITENUM_C,CON_CSM.CS_LABSITENUM_C,CON_CSM.S_STUDY_SITE_RELATED_TO_STUDY_C,'Case_SiteName__c'});
            for(Case c: caseList){
                if(stringMap.containsKey(c.Site_Related_to_the_Study__c)){
                    if(c.LabSiteNumber__c != stringMap.get(c.Site_Related_to_the_Study__c).Lab_Site_Number__c){
                        c.LabSiteNumber__c = stringMap.get(c.Site_Related_to_the_Study__c).Lab_Site_Number__c;  
                    }
                    
                }
                if(c.get(CON_CSM.S_STUDY_SITE_RELATED_TO_STUDY_C) != null && accountMap.containsKey(c.Site_Related_to_the_Study__c)){
                    if(c.Case_SiteName__c != accountMap.get(c.Site_Related_to_the_Study__c)){
                        c.Case_SiteName__c = accountMap.get(c.Site_Related_to_the_Study__c);  
                    }
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
}