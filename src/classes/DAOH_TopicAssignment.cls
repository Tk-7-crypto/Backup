public class DAOH_TopicAssignment {
    public static void stopCreateEditDeleteForServiceSalesProfile(List<TopicAssignment> newList){
        String userId = userInfo.getUserId();
        boolean flag = true;
        List<PermissionSetAssignment> permissionSetList = Database.query('select PermissionSet.Name from PermissionSetAssignment where Assignee.Id = :userId');
        for(PermissionSetAssignment psa : permissionSetList){
            if(psa.PermissionSet.Name == 'KB_Article_Manager' || psa.PermissionSet.Name == 'Advanced_Administrator'){
                flag = false;
            }
        }
        for(TopicAssignment ta : newList){
            String linkid = String.valueof(ta.EntityId);
            if(linkid.startsWith('ka0') && flag){
                ta.addError('You don\'t have permission to update Topics. Please contact the KB author if you require any topic modification.');
            }
        }
    }
}
