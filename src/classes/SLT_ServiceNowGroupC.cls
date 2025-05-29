public class SLT_ServiceNowGroupC extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_ServiceNowGroupC() {
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
        return ServiceNow_Group__c.sObjectType;
    }
    
    /**
     * This method used to get ServiceNow_Group__c by Id
     * @return  Map<Id, User>
     */
    public Map<Id, ServiceNow_Group__c> selectByServiceNowId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, ServiceNow_Group__c>((List<ServiceNow_Group__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
}