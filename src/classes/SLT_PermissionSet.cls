public class SLT_PermissionSet extends fflib_SObjectSelector  {
    
    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PermissionSet.Id,PermissionSet.Label,PermissionSet.Name
        };
    }
    
    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return PermissionSet.sObjectType;
    }
}