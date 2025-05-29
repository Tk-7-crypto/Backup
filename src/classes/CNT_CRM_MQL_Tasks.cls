public with sharing class CNT_CRM_MQL_Tasks {
    
    @AuraEnabled(cacheable=true)
    public static TasksWrapper getTasks(){
        TasksWrapper tasksWrapper = new TasksWrapper();
        CRM_Config__c crmConfigSetting = CRM_Config__c.getInstance();
        if(crmConfigSetting != null){
            tasksWrapper.insideSalesUserId = crmConfigSetting.Inside_Sales_User_Id__c;
        }
        tasksWrapper.tasks = [SELECT Id, Subject, Campaign_Name2__r.Name, Priority, ActivityDate, Status, OwnerId, Owner.Name, MQL_Triaged_By__c from Task where RecordTypeId = :CON_CRM.MQL_TASK_RECORD_TYPE_ID AND IsClosed = false AND (OwnerId = :UserInfo.getUserId() OR OwnerId = :crmConfigSetting.Inside_Sales_User_Id__c OR MQL_Triaged_By__c = :UserInfo.getName())];
        return tasksWrapper;
    }
    
    public class TasksWrapper{
        @AuraEnabled
        public List<Task> tasks;
        
        @AuraEnabled
        public String insideSalesUserId;
    }
}