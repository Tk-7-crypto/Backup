public class DAO_Product extends fflib_SObjectDomain {
    
    /**
* Constructor of this class
* @params sObjectList List<Product>
*/
    public DAO_Product(List<Product2> sObjectList) {
        super(sObjectList);
    }
    
    /**
* Constructor Class for construct new Instance of This Class
*/
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Product(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        Profile profile = DAOH_Case.getCSMProfile(UserInfo.getProfileId());
        Id userId = UserInfo.getUserId();
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        permissionSetList =  Database.query('select PermissionSet.Name from PermissionSetAssignment where Assignee.Id = :userId and PermissionSet.Name =\'Advanced_Administrator\'');
        
        if((profile != null && profile.Name != null && !profile.Name.containsIgnoreCase(CON_CSM.S_P_SYS_ADMIN)) && permissionSetList.size()==0)
            DAOH_Product.checkForDuplicacy((List<Product2>) Records);
    }
       
    /**
     * This method is used for before update of the case trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        Profile profile = DAOH_Case.getCSMProfile(UserInfo.getProfileId());
        Id userId = UserInfo.getUserId();
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        permissionSetList =  Database.query('select PermissionSet.Name from PermissionSetAssignment where Assignee.Id = :userId and PermissionSet.Name =\'Advanced_Administrator\'');
        
        if((profile != null && profile.Name != null && !profile.Name.containsIgnoreCase(CON_CSM.S_P_SYS_ADMIN)) && permissionSetList.size()==0)
            DAOH_Product.checkForDuplicacy((List<Product2>) Records);
    }
}