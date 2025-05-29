/**
 * class which can contain permissions of a user.
 */
public class UserPermissionWrapper {
    @AuraEnabled public User userObj {get; set;}
    @AuraEnabled public String userPermission {get; set;}

    public UserPermissionWrapper(User userObj, String userPermission) {
        this.userObj = userObj;
        this.userPermission = userPermission;
    }
}