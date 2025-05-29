public class EXT_CSM_FieldDefination {
    public List<FieldDefinition> fields {get;private set;}
    public String selectedObject {get;private set;}
    public String fieldString {get;private set;}
    
    public List<FieldDefinition> getFieldDetails(String selectedObject){
        
        if(selectedObject!=null){
            
            Set<String> fieldSet= new Set<String>{CON_CSM.S_QAPINAME,CON_CSM.S_MASTERLABEL,CON_CSM.S_LABEL,CON_CSM.S_DATATYPE,CON_CSM.S_VALUETYPEID,CON_CSM.S_EXTRATYPEINFO,CON_CSM.S_ISNAMEFIELD,CON_CSM.S_ISFIELDHISTORYTRACKED,CON_CSM.S_RELATIONSHIPNAME};
            List<CSM_QI_Field_Tracking__c> fieldList=new SLT_CSMQIFieldTrackingC().selectByObjectName(new Set<String>{selectedObject}, new Set<String>{CON_CSM.S_ID, CON_CSM.S_NAME, CON_CSM.S_FIELDSC});
            
            if(fieldList!=null && fieldList.size()>0){
                fieldString=CON_CSM.S_QUOTE+String.join(fieldList[0].Fields__c.split(CON_CSM.S_COMMA), CON_CSM.S_QCOMAQ)+CON_CSM.S_QUOTE;
                fields =new SLT_FieldDefinition().selectFieldByEntityId(selectedObject, fieldString);
                if(fields==null) fields=new List<FieldDefinition>(); 
                List<FieldDefinition> defaultFields=new SLT_FieldDefinition().selectFieldByEntityIdAndDefaultField(selectedObject);
                if(defaultFields!=null && defaultFields.size()>0) fields.addAll(defaultFields);  
            }else{
                fields =new SLT_FieldDefinition().selectFieldByEntityIdAndDefaultField(selectedObject);
            }
        }
        
        return fields;
    }
}