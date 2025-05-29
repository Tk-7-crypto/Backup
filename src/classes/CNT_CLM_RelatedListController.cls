/**
 * @description Controller for LXC_GBL_RelatedListCmp Lightning Component
 */
public with sharing class CNT_CLM_RelatedListController {
    /**
     * @description Method to fetch Data when lightning component init method called.
     * @param  recordId String 
     * @return list of task
     */
    @AuraEnabled
    public static List<Task> getRecords(String recordId) {
        Set<String> fieldSet = new Set<String>{'Id','Subject','Status','ActivityDate','CompletedDateTime','Owner.Name', 'Description','Task_Owner_Name__c'};
        List<Task> taskList = new SLT_Task().getTasks(fieldSet, ' WhatId = \''+recordId+'\' AND Type = \''+CON_CLM.TASK_TYPE_REVIEW_APPROVAL+'\'', null, 'CreatedDate');
        return taskList;
    }

    /**
     * @description Method to update records when lightning component update method called.
     * @param  jsonString String with updated rows 
     * @exception throws AuraHandledException On Exception occur to Notify Ligthning Component
     */
    @AuraEnabled
    public static void updateRecords(String jsonString){
        try{
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Task.SObjectType
                }
            );
            List<Task> records = (List<Task>) JSON.deserialize(jsonString,List<Task>.class);
            uow.registerDirty(records);
            uow.commitWork();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Method to get picklist values.
     * @param  objectAPIName String to store object api name 
     * @param fieldAPIName String to store picklist field api name
     * @return map of task picklist values
     */
    @AuraEnabled
    public static Map<String,String> getPicklistValues(String objectAPIName, String fieldAPIName){
        String recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Standard_Task').getRecordTypeId();
        Map<String,String> pickListValuesMap = UTL_CLM.getPicklistOptionsByRecordTypeId(objectAPIName,recordTypeId,fieldAPIName);
        return pickListValuesMap;
    }
}