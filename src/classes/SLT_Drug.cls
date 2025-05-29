public class SLT_Drug extends fflib_SObjectSelector{
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Drug() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Drug(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    public SLT_Drug(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
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
        return Drug__c.sObjectType;
    }
    
    /**
     * This method used to get Drug by Id
     * @return  Map<Id, Drug__c>
     */
    public Map<Id, Drug__c> getDrugById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Drug__c>((List<Drug__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    } 
    
    /**
     * This method used to get Drug by ProgramId
     * @return  List<Drug__c>
     */
    public List<Drug__c> getActiveDrugByProgramId(Set<ID> idSet, Set<String> fieldSet) {
        return ((List<Drug__c>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Program__c IN :idSet AND Active__c = true').toSOQL()));
    } 

}
