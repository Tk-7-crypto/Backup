/*
* Version       : 1.0
* Description   : This Apex class is selector layer for Group
*/
public class SLT_Groups extends fflib_SObjectSelector{
    /**
* constructor to initialize CRUD and FLS
*/
    public SLT_Groups() {
        super(false, true, false);
    }

    /**
     * This Method is used to get the Groups records by this list of group Names.
     * @params :  List<String> groupNamesList
     * @returns : returns the List of group records.
     */
    public static List<Group> getGroupsByNameList(List<String> groupNamesList) {
        return (List<Group>) Database.query('SELECT Id,Name FROM Group where Name In: groupNamesList ORDER BY Name DESC');
    }
    
    /**
* constructor to initialize CRUD and FLS
*/
    public SLT_Groups(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }
    
    /**
* This method used to get field list of sobject
*/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Group.Id,
            Group.Developername,
            Group.RelatedId,
            Group.Type,
            Group.Name,
            Group.OwnerId,
            Group.QueueRoutingConfigId
        };
    }
    
    /**
* This method used to set up type of sobject
* @return  Schema.SObjectType
*/
    public Schema.SObjectType getSObjectType() {
        return Group.sObjectType;
    }
    
    /**
* This method is used to get Group with Developername
* @return List<Group>
*/
    public List<Group> getGroupByDevelopername(Set<String> fieldSet, String variable1) {
        return (List<Group>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(variable1).toSOQL());
    }
    
    /**
* This method is used to get Group with Developername set
* @return List<Group>
*/
    public List<Group> getGroupByDevelopernameSet(Set<String> fieldSet, Set<String> developerNameSet) {
        return (List<Group>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('developername in :developerNameSet').toSOQL());
    }
    
    /**
* This method is used to get Group with Developername set
* @params Set<String> fieldSet
* @params Set<String> groupNameSet
* @return List<Group>	
*/
    public List<Group> getGroupByNameSet(Set<String> fieldSet, Set<String> groupNameSet) {
        return (List<Group>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name IN :groupNameSet').toSOQL());
    }
    
    /**
* This method is used to get Group with type and RelatedId
* @return List<Group>
*/
    public List<Group> getGroupByTypeAndRelatedId(Set<String> fieldSet, String variable, Set<Id> relatedIdSet) {
        return (List<Group>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Type = :variable').toSOQL());
    }
    
    
    
    /**
* This method is used to get Groups with group members
* @params Set<Id> grpNameSet
* @return List<Group> 
*/
    public List<Group> getGroupsWithGroupMembersByGroupName(Set<String> grpNameSet) {
        return [SELECT Id, Name, (SELECT UserOrGroupId 
                                  FROM GroupMembers)
                FROM Group g 
                WHERE Name IN : grpNameSet
               ];
    }
    
     /**
     * This method is used to get Group members by group name.
     * @params Set<Id> grpNameSet
     * @return List<GroupMember> 
     */
    public List<GroupMember> getGroupMembersByGroupName(Set<String> grpNameSet) {
        return [SELECT Id, UserOrGroupId  FROM GroupMember where group.name IN : grpNameSet];
    }
    
    public List<Group> selectById(Set<ID> idSet) {
        return (List<Group>) selectSObjectsById(idSet);
    }
     /**
     * This method is used to get GroupName with Type
     * @params Set<Id> grpNameSet
     * @return List<Group> 
     */
    public List<Group> getGroupWithGroupName(Set<String> grpNameSet,String variable) {
        return new List<Group>([SELECT Id, Name, Type FROM Group WHERE Type =:variable AND Name IN :grpNameSet LIMIT 1]);
    }
}