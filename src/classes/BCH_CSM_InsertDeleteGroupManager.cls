global class BCH_CSM_InsertDeleteGroupManager implements Database.Batchable<sObject>{
    String[] errors = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        
       String query='SELECT Id,User__c,Queue_Id__c,Action__c,Status__c,DeleteGroupMemberId__c  FROM CSM_Admin_Management__c where Status__c = \'New\'';
    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CSM_Admin_Management__c> ams){
        List<GroupMember> insertList = new List<GroupMember>();
        GroupMember gm = null;
        Set<Id> delSet = new Set<Id>();
        Map<Id,Id> groupM = new Map<Id,Id>();
        List<CSM_Admin_Management__c> updateList = new List<CSM_Admin_Management__c>();
        
 
        if(ams != null && !ams.isEmpty()){
            for(CSM_Admin_Management__c am : ams){
                 if('Add'.equalsIgnoreCase(am.Action__c) ) {
                    gm = new GroupMember();
                    gm.GroupId = am.Queue_Id__c;
                    gm.UserOrGroupId = am.User__c;
                    insertList.add(gm); 
                }else if('Delete'.equalsIgnoreCase(am.Action__c) && am.DeleteGroupMemberId__c != null){
                    delSet.add(am.DeleteGroupMemberId__c); 
                }
                
            }    
        }
        
        try {
            if(!insertList.isEmpty()){
              insert insertList;  
            }
            
        } catch(Exception e) {
            errors.add(e.getLineNumber()+' - ' + e.getMessage());
        }
        
        if(delSet != null && !delSet.isEmpty()){
            try{
               List<GroupMember> gList = Database.query('select Id,GroupId,UserOrGroupId From GroupMember where Id IN :delSet'); 
                delete gList;
            }catch(DmlException e){
                
            }
        }
        
    }
    global void finish(Database.BatchableContext BC){
        BCH_CSM_AdminManagement adminBatch = new BCH_CSM_AdminManagement();
        Id batchProcessId = Database.executeBatch(adminBatch);
    }
    
}