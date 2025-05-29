public class SLT_PermissionSetAssignment extends fflib_SObjectSelector {
    
    public String orderByField = 'AssigneeId';
    
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
        return new List<Schema.SObjectField> {
            PermissionSetAssignment.Id
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return PermissionSetAssignment.sObjectType;
    }
    
    /**
    * This method used to get PermissionSetAssignment by user Id
    * @param - Set<String> field set
    * @param - Set<Id> - user ids
    * @return  List<PermissionSetAssignment>
    */
    public List<PermissionSetAssignment> selectByUserIds(Set<String> fieldSet,Set<Id> userIds) {
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        new SLT_PermissionSet().configureQueryFactoryFields(queryFactory, 
            PermissionSetAssignment.PermissionSetId.getDescribe().getRelationShipName());
        return  Database.query(queryFactory.selectFields(fieldSet).setCondition('AssigneeId in :userIds').toSOQL());
    }
    
    /**
    * This method used to check if PermissionSetAssignment by user Id for a specific permission set
    * @param - Set<String> field set
    * @param - Set<Id> - user ids
    * @return  List<PermissionSetAssignment>
    */
    public List<PermissionSetAssignment> selectByPermissionSetForUserId(Set<String> fieldSet,Set<Id> userIds, String permissionSetName) {
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        new SLT_PermissionSet().configureQueryFactoryFields(queryFactory, 
            PermissionSetAssignment.PermissionSetId.getDescribe().getRelationShipName());
        return  Database.query(queryFactory.selectFields(fieldSet).setCondition('AssigneeId in :userIds and Permissionset.Name = :permissionSetName').toSOQL());
    }
    
    /**
    * This method used to check if PermissionSetAssignment by user Id for a list of permission sets
    * @param - Set<String> field set
    * @param - Set<Id> - user ids
    * @param - Set<String> - Permission Set names
    * @return  List<PermissionSetAssignment>
    */
    public List<PermissionSetAssignment> selectByPermissionSetsForUserId(Set<String> fieldSet,Set<Id> userIds, Set<String> permissionSetNames) {
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        new SLT_PermissionSet().configureQueryFactoryFields(queryFactory, 
            PermissionSetAssignment.PermissionSetId.getDescribe().getRelationShipName());
        return  Database.query(queryFactory.selectFields(fieldSet).setCondition('AssigneeId in :userIds and Permissionset.Name IN :permissionSetNames').toSOQL());
    }
}