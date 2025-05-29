public class CNT_CSM_FieldHistoryTracking {
    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getObjNameList(){
        List<EXT_CSM_CheckboxDetails> objNameList = new List<EXT_CSM_CheckboxDetails>();
        EXT_CSM_CheckboxDetails dtls = null;
        List<EntityDefinition> entity = new SLT_EntityDefinition().selectNameByEntityName(new Set<String>{CON_CSM.S_CASE,CON_CSM.S_ACCOUNT,CON_CSM.S_CONTACT,CON_CSM.S_ACTIVITYC,CON_CSM.S_STUDYC,CON_CSM.S_TASK,CON_CSM.S_STUDY_CONTACT_RELATIONSHIP,CON_CSM.S_STUDY_SITE_RELATIONSHIP,CON_CSM.S_STUDY_SITE_CON_RELATIONSHIP});
        
        for(EntityDefinition ed : entity){
            dtls=new EXT_CSM_CheckboxDetails(ed.QualifiedApiName,ed.Label,true);
            objNameList.add(dtls);
        }
        
        return objNameList;
    }
    @AuraEnabled
    public static EXT_CSM_CheckboxGroupDetails showFieldGroupCheckboxData(String selectedObject){
        
        List<FieldDefinition> fieldList = new SLT_FieldDefinition().selectshowFieldGroupCheckboxData(selectedObject);
        List<String> value = new List<String>();
        List<EXT_CSM_CheckboxDetails> checkboxList = new List<EXT_CSM_CheckboxDetails>();
        EXT_CSM_CheckboxGroupDetails checkboxGroup = null;
        
        
        for(FieldDefinition fd : fieldList){
            value.add(fd.QualifiedApiName);
            checkboxList.add(new EXT_CSM_CheckboxDetails(fd.QualifiedApiName,fd.Label,fd.IsFieldHistoryTracked));
            
        }
        checkboxGroup=new EXT_CSM_CheckboxGroupDetails(checkboxList,String.join(value, CON_CSM.S_COMMA));
        
        
        return checkboxGroup;
    }
    
    @AuraEnabled
    public static EXT_CSM_CheckboxGroupDetails showFieldGroupCheckboxCustomData(String selectedObject){
        
        List<FieldDefinition> fieldList = new SLT_FieldDefinition().showFieldGroupCheckboxCustomData(selectedObject);
        List<String> value=new List<String>();
        List<EXT_CSM_CheckboxDetails> checkboxList = new List<EXT_CSM_CheckboxDetails>();
        EXT_CSM_CheckboxGroupDetails checkboxGroup = null;
        
        CSM_QI_Field_Tracking__c[]  fieldTracking = new SLT_CSMQIFieldTrackingC().selectByObjectName(new Set<String>{selectedObject},new Set<String>{CON_CSM.S_ID, CON_CSM.S_NAME, CON_CSM.S_FIELDSC});
        
        for(FieldDefinition fd : fieldList){
            
            if(fieldTracking != null && fieldTracking.size() > 0 && (CON_CSM.S_QUOTE + String.join(fieldTracking[0].Fields__c.split(CON_CSM.S_COMMA), CON_CSM.S_QCOMAQ) + CON_CSM.S_QUOTE).contains(CON_CSM.s_quote + fd.QualifiedApiName + CON_CSM.S_QUOTE)){
                checkboxList.add(new EXT_CSM_CheckboxDetails(fd.QualifiedApiName,fd.Label,true));
                value.add(fd.QualifiedApiName);
            }else{
                checkboxList.add(new EXT_CSM_CheckboxDetails(fd.QualifiedApiName,fd.Label,fd.IsFieldHistoryTracked));     
            }
            
        }
        checkboxGroup = new EXT_CSM_CheckboxGroupDetails(checkboxList,String.join(value, CON_CSM.S_COMMA));
        
        return checkboxGroup;
    }
    
    
    @AuraEnabled
    public static EXT_CSM_Message saveFields(String selectedObject,String fields){
        
        EXT_CSM_Message message;
        List<CSM_QI_Field_Tracking__c>  fieldTrackingList = null;
        CSM_QI_Field_Tracking__c fieldTracking=null;
        Boolean check=false;
        fieldTrackingList = new SLT_CSMQIFieldTrackingC().selectByObjectName(new Set<String>{selectedObject},new Set<String>{CON_CSM.S_ID, CON_CSM.S_NAME, CON_CSM.S_FIELDSC});
        
        if(String.isEmpty(fields)){
            message = new EXT_CSM_Message('Error!','error','Please select the at least one checkbox'); 
            check=true;
        }else if(fieldTrackingList.size() > 0 && fieldTrackingList[0].Fields__c.equals(fields)){
            message = new EXT_CSM_Message('Error!','error','you have not checked any new checkbox'); 
            check = true;
        }
        
        if(check){
            return  message;  
            
        }else{
            
            if(fieldTrackingList.isEmpty()){
                fieldTracking = new CSM_QI_Field_Tracking__c(Name = selectedObject, Fields__c = fields);
                
            }else{
                fieldTracking = fieldTrackingList[0];
                fieldTracking.Fields__c = fields; 
            }
            
            
            try {
                if(fieldTracking != null){
                    upsert fieldTracking;  
                    message = new EXT_CSM_Message('Success!','success',selectedObject + ' Object Fields Saved Success.');
                }else{
                    message = new EXT_CSM_Message('Error!','error','Please Select Object');  
                }
                
                
            } catch (DmlException e) {
                message = new EXT_CSM_Message('Error!','error','Failed due to : '+e);
            }
        }
        
        return message;
    }
}