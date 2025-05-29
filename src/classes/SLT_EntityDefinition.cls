public class SLT_EntityDefinition extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_EntityDefinition() {
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
        return EntityDefinition.sObjectType;
    }
    
      
    /**
     * This method used to get Casse by Id
     * @return  List<EntityDefinition>
     */
    public List<EntityDefinition> selectNameByEntityName( Set<String> objNames) {
        
        return (List<EntityDefinition>) Database.query('SELECT QualifiedApiName,Label FROM EntityDefinition WHERE QualifiedApiName  In:objNames');
    }
    
    
}