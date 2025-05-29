public class SLT_UserRole {

    public UserRole getUserRoleByName(String roleName){
        return  Database.query('SELECT Id,Name FROM UserRole WHERE Name =: roleName LIMIT 1');
    }

    public List<UserRole> getUserRolesByName(List<String> roleName){
        return  Database.query('SELECT Id,Name FROM UserRole WHERE Name In :roleName');
    }
}