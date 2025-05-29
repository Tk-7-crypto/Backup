public class SLT_FieldDefinition extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_FieldDefinition() {
        super(false, true, true);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return FieldDefinition.sObjectType;
    }
    
      
    /**
     * This method used to get the FieldDefinition data
     * @return  List<FieldDefinition>
     */
    public List<FieldDefinition> selectFieldByEntityId(String selectedObject,String fieldString) {
        return (List<FieldDefinition>) Database.query('SELECT QualifiedApiName,MasterLabel,Label,DataType,ValueTypeId,ExtraTypeInfo,IsNameField,IsFieldHistoryTracked,RelationshipName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = :selectedObject and  QualifiedApiName In ('+ fieldString +') and IsFieldHistoryTracked =false and IsNameField=false order by QualifiedApiName');
    }
    
    public List<FieldDefinition> selectFieldByEntityIdAndDefaultField(String selectedObject) {
        
        return (List<FieldDefinition>) Database.query('SELECT QualifiedApiName,MasterLabel,Label,DataType,ValueTypeId,ExtraTypeInfo,IsNameField,IsFieldHistoryTracked,RelationshipName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = :selectedObject and IsFieldHistoryTracked =true and IsNameField=false order by QualifiedApiName');  
    }
    
    public List<FieldDefinition> selectshowFieldGroupCheckboxData(String selectedObject) {
        
        return (List<FieldDefinition>) Database.query('SELECT QualifiedApiName,MasterLabel,Label,DataType,ValueTypeId,ExtraTypeInfo,IsNameField,IsFieldHistoryTracked FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = :selectedObject and IsNameField=false and IsFieldHistoryTracked =true order by QualifiedApiName');  
    }
    
    public List<FieldDefinition> showFieldGroupCheckboxCustomData(String selectedObject) {
        String query='SELECT QualifiedApiName,MasterLabel,Label,DataType,ValueTypeId,ExtraTypeInfo,IsNameField,IsFieldHistoryTracked'+
            ' FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = :selectedObject and IsNameField=false'+
            ' and IsFieldHistoryTracked =false'+
            ' and QualifiedApiName not in (\'IsDeleted\',\'IsClosed\',\'ClosedDate\',\'IsEscalated\',\'CreatedDate\',\'SystemModstamp\',\'LastModifiedDate\',\'LastModifiedById\',\'CreatedById\',\'LastReferencedDate\',\'LastViewedDate\') ';
          if(CON_CSM.S_ACTIVITYC.equals(selectedObject) || CON_CSM.S_STUDYC.equals(selectedObject)){
         	query+= ' and DataType not in(\'Lookup()\',\'Lookup(User Record Access)\',\'Lookup(Business Hours)\')';    
          }else{
        	 query+= ' and DataType not in(\'Lookup()\',\'Lookup(User Record Access)\')';    
          }
        if(CON_CSM.S_TASK.equals(selectedObject)){
             query+=' order by MasterLabel';
        }else{
             query+=' order by QualifiedApiName';
        }
         
        return (List<FieldDefinition>) Database.query(query);  
    }
    
    
    
}