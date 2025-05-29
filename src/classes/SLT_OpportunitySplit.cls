/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OpportunitySplit
 */
public class SLT_OpportunitySplit extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_OpportunitySplit() {
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
        return OpportunitySplit.sObjectType;
    }
    
    /**
     * This method used to get OpportunitySplits by OpportunityId
     * @return List<OpportunitySplit>
     */
    public List<OpportunitySplit> selectByOpportunityId(Set<ID> oppIdSet, String splitType, Set<String> fieldSet) {
        return (List<OpportunitySplit>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('OpportunityId IN :oppIdSet AND SplitType.DeveloperName = :splitType').toSOQL());
    }
}