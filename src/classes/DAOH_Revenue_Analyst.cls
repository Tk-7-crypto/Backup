/*
 * Author		: 
 * Purpose		: Service Class for Revenue_Analyst__c Trigger
 */
public class DAOH_Revenue_Analyst {
    List<String>  revenueAnalystFieldList = new List<String>{'User__c','User_2__c','User_3__c','User_4__c','User_5__c','User_6__c','User_7__c','User_8__c','User_9__c','User_10__c'};
    Static String ERROR_RA_EMAIL_MANDATORY = 'RA email is mandatory';
    Static String ERROR_RA_MAX_USER = 'Only 10 users can be assigned to a RA';
    Static String ERROR_RA_MIN_USER = 'Must only have one user on RA';
    Static String NAME_QUEUE_OBJECT = 'Group';
    Static String NAME_USER_OBJECT = 'User';
    Static String EMPTY_STRING = '';
    
   /**
    * To maintain Revenue_Analyst__c object according to owner 
    * Issue-10709
    */
    public void syncRevenueAnalystWithSBSQueue() {
        if (Trigger.isExecuting) {
            Set<Id> OwnerIdSet = new Set<Id>();
            for(Revenue_Analyst__c revenueAnalyst : (List<Revenue_Analyst__c>) Trigger.new) {
                OwnerIdSet.add(revenueAnalyst.OwnerId);
            }
            List<GroupMember> groupMemberList = [Select UserOrGroupId, Group.Type From GroupMember where GroupId in :OwnerIdSet and Group.Type = 'Queue'];
            Map<Id,List<GroupMember>> OwnerToGroupMemberMap = new Map<Id,List<GroupMember>>();
            for(GroupMember groupMember : groupMemberList){ 
                if(OwnerToGroupMemberMap.containsKey(groupMember.UserOrGroupId))  {
                    OwnerToGroupMemberMap.get(groupMember.UserOrGroupId).add(groupMember);
                }
                else { 
                    OwnerToGroupMemberMap.put(groupMember.UserOrGroupId, new List<GroupMember>{groupMember});
                }                         
            }

            for(Revenue_Analyst__c revenueAnalyst : (List<Revenue_Analyst__c>) Trigger.new) {              
                String objectName = revenueAnalyst.OwnerId.getSObjectType().getDescribe().getName();
                if(objectName!=null && objectName.equalsIgnoreCase(NAME_QUEUE_OBJECT)) {
                    if(revenueAnalyst.Revenue_Analyst_Email__c == null ||revenueAnalyst.Revenue_Analyst_Email__c == EMPTY_STRING) {
                        revenueAnalyst.addError(ERROR_RA_EMAIL_MANDATORY);
                    }
                    groupMemberList = OwnerToGroupMemberMap.get(revenueAnalyst.OwnerId);
                    List<Id> userList = new List<Id>();
                    if(groupMemberList != null) {
                        for(GroupMember objId : groupMemberList) {
                            if(objId.UserOrGroupId.getSObjectType().getDescribe().getName().contains(NAME_USER_OBJECT)) {
                                userList.add(objId.UserOrGroupId);
                            }
                        }
                        if(userList.size() > 10) {
                            revenueAnalyst.addError(ERROR_RA_MAX_USER);
                        } else {
                            for(Integer i = 0 ; i < 10; i++) {
                                revenueAnalyst.put(revenueAnalystFieldList.get(i), userList.size() > i ? userList.get(i) : null);
                            }
                        }
                    }
                } else if(objectName!=null && objectName.equalsIgnoreCase(NAME_USER_OBJECT)) {
                    Integer userCount = 0;
                    Id userId;
                    for(Integer i = 0 ; i < 10; i++) {
                        if(revenueAnalyst.get(revenueAnalystFieldList.get(i)) != null && revenueAnalyst.get(revenueAnalystFieldList.get(i)) != EMPTY_STRING) {
                            userCount++;
                            userId = (Id)revenueAnalyst.get(revenueAnalystFieldList.get(i));
                        }
                    }
                    if(userCount != 1) {
                        revenueAnalyst.addError(ERROR_RA_MIN_USER);
                    } else {
                        User user = [select email from User where id =: userId];
                        revenueAnalyst.Revenue_Analyst_Email__c = user.Email;
                    }
                }             
            }            
        }
    }
}