/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Contract_Milestone__c Object.
 */
public class SLT_ContractMilestone extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_ContractMilestone() {
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
        return Contract_Milestone__c.sObjectType;
    }
    
    /**
     * This method used to get Contract_Milestone__c
     * @return List<Contract_Milestone__c>
     */
    public List<Contract_Milestone__c> selectByIdFilter(Set<ID> idSet, Set<String> fieldSet) {
        return (List<Contract_Milestone__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }
}