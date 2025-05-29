public class UserConfigWrapper {
    
    public List<UserPackageLicense> userlicenseList;
    public List<PermissionSetAssignment> permissionSetList;
    public List<GroupMember> groupMemberList;
    public List<UserTerritory2Association> territoryList;
    public Date deactivationDate;
	
    public UserConfigWrapper() {
        userlicenseList = new List<UserPackageLicense>();
        permissionSetList = new List<PermissionSetAssignment>();
        groupMemberList = new List<GroupMember>();
        territoryList = new List<UserTerritory2Association>();
        deactivationDate = NULL;
    }
}