global class BCH_CSM_AdminManagement implements Database.Batchable<sObject>{
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
                am.Status__c = 'Completed';
                updateList.add(am);
            }    
        }
        
        try {
            if(!updateList.isEmpty()){
              update updateList;  
            }
            
        } catch(Exception e) {
            errors.add(e.getLineNumber()+' - ' + e.getMessage());
        }
        
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
    
}