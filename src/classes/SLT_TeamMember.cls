public class SLT_TeamMember extends fflib_SObjectSelector{
       
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_TeamMember() {
        super(false, true, true);
    }
    
    /**
    * constructor to initialise CRUD and FLS with a parameter for FLS.
    */
    public SLT_TeamMember(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    public SLT_TeamMember(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
    
    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Team_Member__c.Id,
            Team_Member__c.Name,
            Team_Member__c.Proposal__c,
            Team_Member__c.Member_Role__c,
            Team_Member__c.User__c  
        };
    }
    
    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return Team_Member__c.sObjectType;
    }
    
    public List<Team_Member__c> getTeamMemberById(Set<Id> idSet, Set<String> fieldSet) {
        return new List<Team_Member__c>((List<Team_Member__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    public List<Team_Member__c> getTeamMemberByProposalIdANDMemberRole(Set<Id> idSet, Set<String> fieldSet, List<String> roleList) {
        return new List<Team_Member__c>((List<Team_Member__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Proposal__c in :idSet AND Member_Role__c IN: roleList').toSOQL()));
    }
    public List<Team_Member__c> getTeamMemberByProposalIdANDRoleORMemberRole(Set<Id> idSet, Set<String> fieldSet, List<String> memberRoleList, List<String> roleList) {
        return new List<Team_Member__c>((List<Team_Member__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Proposal__c in :idSet AND (Member_Role__c IN: memberRoleList OR Role_from_RR__c IN: roleList)').setOrdering('Role_from_RR__c', fflib_QueryFactory.SortOrder.DESCENDING, true).toSOQL()));
    }
}