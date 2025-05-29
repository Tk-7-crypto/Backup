/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for BNF Object.
 */
public class SLT_BNF extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_BNF() {
        super(false, false, false);
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
        return BNF2__c.sObjectType;
    }
    
    /**
     * This method used to get BNF by OpportunityId
     * @return List<BNF2__c>
     */
    public List<BNF2__c> selectByFilter(Set<ID> oppIdSet, Set<String> fieldSet ,String filterCondition) {
        return (List<BNF2__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(filterCondition).toSOQL());
    }
    
    /**
     * This method used to get BNF Details
     * @return List<BNF2__c>
     */
    public List<BNF2__c> selectById(Set<ID> idSet, Set<String> fieldSet ) {
        return (List<BNF2__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }
}