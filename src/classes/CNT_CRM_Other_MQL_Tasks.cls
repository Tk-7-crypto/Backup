/**
 * Version : 1.0
 * An apex controller that exposes the MQL Task related methods.
 * ESPSFDCQI-10006
 */
public without sharing class CNT_CRM_Other_MQL_Tasks {
    @AuraEnabled(cacheable=true)
    public static List<Task> getTaskDetails(String recordId){
        Task task =  [SELECT Id, WhoId from Task where Id = :recordId];
        if(task.whoId == null)
            return new List<Task>();
        
        return getTasksForWhoId(task.WhoId, recordId);
    }
    
     /**
     * This method returns OpportunitySplit Records for any opportunity.
     * @params  String whoId To retrieve all mql task for the given whoId
     * @params  String recordId to exclude from result
     * @return  List<OpportunitySplit>
     */
    @AuraEnabled(cacheable=true)
    public static List<Task> getTasksForWhoId(String whoId, String recordId){
        return [SELECT Id, OwnerId, Owner.Name, Campaign_Name2__c, Campaign_Name2__r.Name, Status, ActivityDate, Subject from Task where whoId = :whoId AND RecordType.DeveloperName = 'MQL_Task' AND Id != :recordId ORDER BY ActivityDate ASC];
    }
}