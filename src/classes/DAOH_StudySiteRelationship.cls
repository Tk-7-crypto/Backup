public class DAOH_StudySiteRelationship {
    /**
    * This method is used for create a new Data Audit Trail when the new case record is created.
    * @params  newList List<Study_Contact_Relationship__c>
    * @return  void
    */
    
    public static void saveAuditLogAfterInsertStudySiteRelationship(List<Study_Site_Relationship__c> newList){
        CSM_QI_Data_Audit_Trail__c auditTrail = null;
        Map<ID,Schema.RecordTypeInfo> rt_Map   =  Study_Contact_Relationship__c.sObjectType.getDescribe().getRecordTypeInfosById();
        List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
        for(Study_Site_Relationship__c c : newList) {
            if(newList.size()>0)
            {
                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CREATED,Name = CON_CSM.S_STUDY_SITE_RELATIONSHIP,Study_Site_Relationship__c   =  c.Id);
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
    * @params  newList List<Study_Site_Relationship__c>,oldMap Map<Id, Study_Site_Relationship__c> 
    * @return  void
    */
    public static void saveAuditLogAfterUpdateStudySiteRelationshipFields(List<Study_Site_Relationship__c> newList, Map<Id, Study_Site_Relationship__c> oldMap,List<FieldDefinition> fields) {
        
        if(fields != null && fields.size() > 0){
            
            CSM_QI_Data_Audit_Trail__c auditTrail = null;
            List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
            Map<ID,Schema.RecordTypeInfo> rt_Map   =  Study__c.sObjectType.getDescribe().getRecordTypeInfosById();
            EXT_CSM_CaseRelatedToObject studyRelatedTo = null;
            List<EXT_CSM_CaseRelatedToObject> studyRelatedToList = new List<EXT_CSM_CaseRelatedToObject>(); 
            
            for(Study_Site_Relationship__c c : newList) {
                
                if(fields.size() > 0 ) 
                {
                    for( FieldDefinition fd: fields){
                        
                        if(String.isBlank(fd.ExtraTypeInfo) && ((fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PICKLIST) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_NUMBER) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_DOUBLE)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_URL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PHONE) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_EMAIL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_CHECKBOX) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_BOOLEAN)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_FORMULA) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_TEXT)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATETIME)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATE)))){
                            if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Study_Site_Relationship__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Study_Site_Relationship__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Study_Site_Relationship__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }else if(String.isBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_LOOKUP) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_ID)){
                            if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                studyRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_DELETED,fd.RelationshipName,CON_CSM.S_STUDY_SITE_RELATIONSHIP,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),null,c.Id);
                                studyRelatedToList.add(studyRelatedTo);
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                studyRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_ADDED,fd.RelationshipName,CON_CSM.S_STUDY_SITE_RELATIONSHIP,fd.MasterLabel,null,(Id)c.get(fd.QualifiedApiName),c.Id);
                                studyRelatedToList.add(studyRelatedTo);    
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                studyRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_CHANGED,fd.RelationshipName,CON_CSM.S_STUDY_SITE_RELATIONSHIP,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),(Id)c.get(fd.QualifiedApiName),c.Id);
                                studyRelatedToList.add(studyRelatedTo);
                            }
                        }else if(String.isNotBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)){
                            if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = fd.MasterLabel,Old_Text_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),Study_Site_Relationship__c   =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }
                        
                    }
                }
            }
            
            if(studyRelatedToList.size() > 0)
            {
                Set<Id> accSet = new Set<Id>(),studySet = new Set<Id>(),conSet = new Set<Id>();
                
                for(EXT_CSM_CaseRelatedToObject obj : studyRelatedToList){
                    if(CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        conSet.add(obj.oldId);
                        conSet.add(obj.newId);
                    }
                }
                Set<String> fieldSet   =  new Set<String> {CON_CSM.s_id, CON_CSM.s_name};
                Map<Id, Contact> conMap  = null;
                if(conSet.size() > 0) conMap   =  new SLT_Contact().selectByContactId(conSet, fieldSet);
                for(EXT_CSM_CaseRelatedToObject obj : studyRelatedToList){
                    
                    if(conMap != null && conMap.size() > 0 && CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Study_Site_Relationship__c   =  obj.objectId,Old_Value__c = conMap.containsKey(obj.oldId)?conMap.get(obj.oldId).Name :'',New_Value__c = conMap.containsKey(obj.newId)?conMap.get(obj.newId).Name:'');
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
}