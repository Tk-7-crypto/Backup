public class DAOH_Topic {
    public static void stopCreateEditDeleteForServiceSalesProfile(List<Topic> newList){
        String userId = userInfo.getUserId();
        boolean flag = true;
        List<PermissionSetAssignment> permissionSetList = Database.query('select PermissionSet.Name from PermissionSetAssignment where Assignee.Id = :userId');
        for(PermissionSetAssignment psa : permissionSetList){
            if(psa.PermissionSet.Name == 'KB_Article_Manager' || psa.PermissionSet.Name == 'Advanced_Administrator'){
                flag = false;
            }
        }
        for(Topic ta : newList){
            if(flag){
                ta.addError('You don\'t have permission to update Topics. Please contact the KB author if you require any topic modification.');
            }
        }
    }
}
