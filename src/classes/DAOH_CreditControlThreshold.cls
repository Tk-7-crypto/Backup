/**
 * This is Credit Control Threshold trigger handler class.
 * version : 1.0
 */
public class DAOH_CreditControlThreshold {
    
    public static void validateSuperCreditControlGroup(List<Credit_Control_Threshold__c> newList) {
        Set<String> groupNameSet = new Set<String>{CON_CRM.SUPER_CREDIT_CONTROL_ADMIN_GROUP};
        Id userId = UserInfo.getUserId();
        List<GroupMember> groupMemberList = new List<GroupMember>();
        groupMemberList = new SLT_GroupMember().getGroupMembersByUserAndGroupNameSet(userId, groupNameSet);
        if (groupMemberList.size() == 0) {
            for (Credit_Control_Threshold__c cct : newList) {
                cct.addError(System.Label.CRM_CL0039_Credit_Control_Update_Error);    
            }
        }
    }
}