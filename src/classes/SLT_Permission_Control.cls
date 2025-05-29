/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OpportunitySplit
 */
public class SLT_Permission_Control extends fflib_SObjectSelector {
    
    public String orderByField = 'pse__User__c';
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Permission_Control() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Permission_Control(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_Permission_Control(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }
    
    /**
     * Method to override OrderBy
     */
     
    public override String getOrderBy() {
        return orderByField;
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
        return pse__Permission_Control__c.sObjectType;
    }
    
    /**
     * This method used to get Agreements by Id
     * @return  Map<Id, Apttus__APTS_Agreement__c>
     */
    public Map<Id, pse__Permission_Control__c> getPermissionControlId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, pse__Permission_Control__c>((List<pse__Permission_Control__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Group__c != null AND pse__User__c in :idSet').toSOQL()));
    }
    
}