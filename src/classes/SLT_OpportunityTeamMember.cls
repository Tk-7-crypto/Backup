/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Account
 */
public class SLT_OpportunityTeamMember extends fflib_SObjectSelector {

    /**
     * constructor
     */    
    public SLT_OpportunityTeamMember() {
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
        return OpportunityTeamMember.sObjectType;
    }
    
    /**
     * This method to get opportunity team member by opportunityId
     * @return  List<OpportunityTeamMember>
     */
    public List<OpportunityTeamMember> selectByOpportunityId(Set<Id> oppIdSet, Set<String> fieldSet) {
        return (List<OpportunityTeamMember>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('OpportunityId IN :oppIdSet').toSOQL());
    }
    
    /**
     * This method is used to get Opportunity Team Member by Opportunity Id and User Id
     * @params Set<Id> oppIdSet, Set<String> fieldSet, Set<Id> paGroupMembersSet
     * @return List<OpportunityTeamMember>
     */
    public List<OpportunityTeamMember> selectByOpportunityIdAndUserId(Set<Id> oppIdSet, Set<String> fieldSet, Set<Id> paGroupMembersSet) {
        return (List<OpportunityTeamMember>)Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('OpportunityId IN :oppIdSet And UserId IN :paGroupMembersSet').toSOQL());
    }
}