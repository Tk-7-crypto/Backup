global class BCH_CSM_ChatterGroupInsert implements Database.Batchable<sObject> {
    global String[] errors = new List<String>();
    global String query ;
    global string groupName = CON_CSM.S_ChatterGroup;
    global set<id> idSet = new set<id>();
    global Id groupId;
    public  BCH_CSM_ChatterGroupInsert() {
        if(Test.isRunningTest()) {
            groupName = 'Test Group1';
        }
        List<CollaborationGroupMember> collGroupMembersList =  [Select MemberId,CollaborationGroupId from CollaborationGroupMember where CollaborationGroup.Name =:groupName];
        for(CollaborationGroupMember groupMember :collGroupMembersList){
            idSet.add(groupMember.MemberId);
            if(groupId == null) groupId = groupMember.CollaborationGroupId;
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
       set<string> permissionsetName = new set<string>();
       permissionsetName.add(CON_CSM.S_CSM_SmartSolve);
       permissionsetName.add(CON_CSM.S_TECHNO_Case_Record_Type_Contact_Fields_Access);
       permissionsetName.add(CON_CSM.S_DATA_Case_Record_Type_Non_US_Service_Prod_Fields_Access);
       permissionsetName.add(CON_CSM.S_R_D_Case_Record_Type_Study_Activity_Objects_Access);
       permissionsetName.add(CON_CSM.S_CSM_SmartSolve_Cloud);
       permissionsetName.add(CON_CSM.S_CSM_HCP_Onekey_Case_Record_Type_Fields_access);
      return Database.getQueryLocator([SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name in :permissionsetName and Assignee.IsActive =true and AssigneeId not in :idSet LIMIT :Test.isRunningTest()?1:50000000]);
    }
    
    global void execute(Database.BatchableContext BC, List<PermissionSetAssignment> permissionsetList) {
        List<CollaborationGroupMember> collGroupMembers = new List<CollaborationGroupMember>();
        Set<Id> assigneeIds = new Set<Id>();
        if(groupId == null){
            List<CollaborationGroup> qaGroup = [SELECT id,OwnerId FROM CollaborationGroup WHERE Name=:groupName limit 1];
            if(qaGroup != null && !qaGroup.isEmpty()) groupId = qaGroup[0].Id;
        }
        for(PermissionSetAssignment pSetAssign : permissionsetList) {
            assigneeIds.add(pSetAssign.AssigneeId);
        }  
        CollaborationGroupMember member = null;
        if(assigneeIds != null && !assigneeIds.isEmpty()){
            for(Id asId : assigneeIds){
                member = new CollaborationGroupMember();
                member.MemberId = asId;
                member.CollaborationGroupId = groupId;
                collGroupMembers.add(member);    
            }
        }
        try {
            if(collGroupMembers != null && !collGroupMembers.isEmpty()){
                insert collGroupMembers;
            }
        } 
        catch(Exception e) {
            errors.add(e.getLineNumber()+' - ' + e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
         if(!errors.isEmpty() || Test.isRunningTest()) {
            string allstring = string.join(errors,',');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Errors occurred during BCH_CSM_ChatterGroupInsert batch process.');
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(allstring);
            
            try{
                Messaging.sendEmail(new Messaging.Email[] { mail });
            } catch(Exception e) {
                
            }
        }
    }
}