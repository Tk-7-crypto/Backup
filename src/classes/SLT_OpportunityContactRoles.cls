/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OpportunityContactRoles
 */
public class SLT_OpportunityContactRoles extends fflib_SObjectSelector{
    
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {OpportunityContactRole.Id, OpportunityContactRole.OpportunityId, OpportunityContactRole.isPrimary};
    }
    
    /**
     * This method used to set up type of sobject
     */
    public Schema.SObjectType getSObjectType() {
        return OpportunityContactRole.sObjectType;
    }
    
    /**
     * This method used to get OpportunityContactRoles by OpportunityId
     */
    public Map<Id, OpportunityContactRole> selectByOpportunityId(Set<ID> idSet) {
        return new Map<Id, OpportunityContactRole>((List<OpportunityContactRole>) Database.query(newQueryFactory().setCondition('OpportunityId in :idSet').toSOQL()));
    }
    
    /**
     * This method used to get OpportunityContactRoles by OpportunityId
     */
    public List<OpportunityContactRole> selectByOpportunityId(Set<ID> idSet, Set<String> fieldSet) {
        return (List<OpportunityContactRole>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('OpportunityId in :idSet').toSOQL());
    }
}