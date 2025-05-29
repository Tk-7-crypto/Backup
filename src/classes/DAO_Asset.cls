public class DAO_Asset extends fflib_SObjectDomain {
    
    /**
* Constructor of this class
* @params sObjectList List<Asset>
*/
    public DAO_Asset(List<Asset> sObjectList) {
        super(sObjectList);
    }
    
    /**
* Constructor Class for construct new Instance of This Class
*/
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Asset(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        Profile profile = DAOH_Case.getCSMProfile(UserInfo.getProfileId());
        Id userId = UserInfo.getUserId();
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        permissionSetList =  Database.query('select PermissionSet.Name from PermissionSetAssignment where Assignee.Id = :userId and PermissionSet.Name =\'Advanced_Administrator\'');
        if(profile != null && profile.Name != null && permissionSetList.size()==0)
            DAOH_Asset.checkForDuplicacy((List<Asset>) Records);
    }
}
