global class BCH_CSM_ChatterGroupDelete implements Database.Batchable<sObject> {
    global String query;
    global string groupName = CON_CSM.S_ChatterGroup;
    global String[] errors = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(Test.isRunningTest()) {
            groupName = 'Test Group1';
        }
        set<id> idSet = new set<id>();
        List<CollaborationGroupMember> collGroupMembersList =  [Select MemberId,CollaborationGroupId from CollaborationGroupMember where CollaborationGroup.Name =:groupName];
        for(CollaborationGroupMember groupMember :collGroupMembersList){
            idSet.add(groupMember.MemberId);
        }
        set<string> permissionsetName = new set<string>();
        return Database.getQueryLocator([Select AssigneeId from PermissionSetAssignment Where AssigneeId in :idSet LIMIT :Test.isRunningTest()?1:50000000]
    );
    }
     
    global void execute(Database.BatchableContext BC, List<PermissionSetAssignment> accList) {
        if(Test.isRunningTest()) {
            groupName = 'Test Group1';
        }
        set<id> deleteuserId = new set<id>();
        set<string> permissionsetName = new set<string>();
        permissionsetName.add(CON_CSM.S_CSM_SmartSolve);
        permissionsetName.add(CON_CSM.S_TECHNO_Case_Record_Type_Contact_Fields_Access);
        permissionsetName.add(CON_CSM.S_DATA_Case_Record_Type_Non_US_Service_Prod_Fields_Access);
        permissionsetName.add(CON_CSM.S_R_D_Case_Record_Type_Study_Activity_Objects_Access);
        permissionsetName.add(CON_CSM.S_CSM_SmartSolve_Cloud);
        permissionsetName.add(CON_CSM.S_CSM_HCP_Onekey_Case_Record_Type_Fields_access);
        set<id> permissionIDSet = new set<id>();
        List<PermissionSetAssignment> queryData = [SELECT AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSet.Name in :permissionsetName and Assignee.IsActive =true]; 
        for(PermissionSetAssignment permissionAssigned : queryData ){
            permissionIDSet.add(permissionAssigned.AssigneeId);
        }
        List<CollaborationGroupMember> CollGroupMembers = new List<CollaborationGroupMember>();
        List<CollaborationGroup> qaGroup = [SELECT id,Owner.Name,OwnerId FROM CollaborationGroup WHERE Name=:groupName limit 1];
        for(PermissionSetAssignment acc : accList)
        {  
            if(qaGroup!=null && qaGroup.size() > 0 && qaGroup[0].OwnerId != acc.AssigneeId){
                if(permissionIDSet!=null && !permissionIDSet.contains(acc.AssigneeId)) {                      
                    deleteuserId.add(acc.AssigneeId); 
                } 
            }
        }                             
        try {
            if(deleteUserId.size()>0){    
               List<CollaborationGroupMember> listGM = [ Select Id,CollaborationGroupId, Member.Name,Member.id  from CollaborationGroupMember where Member.id in :deleteuserId and CollaborationGroup.Name =:groupName ];
               delete listGM;
            }
        }catch(Exception e) {
            errors.add(e.getLineNumber()+' - ' + e.getMessage());
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        if(!errors.isEmpty() || Test.isRunningTest()) {
            string allstring = string.join(errors,',');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Errors occurred during BCH_CSM_ChatterGroupDelete batch process.');
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