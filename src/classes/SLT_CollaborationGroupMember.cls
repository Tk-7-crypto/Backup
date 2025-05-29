public without sharing class SLT_CollaborationGroupMember extends fflib_SObjectSelector{
    /**
    * constructor to initialise CRUD and FLS
    */
    public SLT_CollaborationGroupMember() {
        super(false, false, false);
    }

    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
        CollaborationGroupMember.Id,
        CollaborationGroupMember.MemberID
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return CollaborationGroupMember.sObjectType;
    }
    
    public List<CollaborationGroupMember> selectCollaborationGroupMemberByWhereCondtion(String condtion,Set<String> fieldSet){
        return (List<CollaborationGroupMember>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condtion).toSOQL());        
    }

}