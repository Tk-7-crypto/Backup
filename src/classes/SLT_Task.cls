/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Task
 */
public without sharing class SLT_Task extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Task() {
        super(false, false, false);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Task.Id,
            Task.Status,
            Task.WhatId,
            Task.OwnerId
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Task.sObjectType;
    }
    
    /**
     * This method used to get Task by Id
     * @return  List<Task>
     */
    public List<Task> selectById(Set<ID> idSet) {
        return (List<Task>) selectSObjectsById(idSet);
    }
   /**
     * This method used to get Task by WhatId and OwnerId
     * @return  Map<Id, User>
     */
    public List<Task> selectNonCompletedTaskByWhatIdAndOwnerId(Set<String> fieldSet, Id whatId, Id ownerId, Set<Id> recordTypeIds) {
        return new List<Task>((List<Task>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('WhatId =: whatId AND OwnerId =: ownerId AND Status != \'' + CON_CPQ.COMPLETED  + '\' AND RecordTypeId in: recordTypeIds').toSOQL()));
    }
    
    /**
     * This method used to get open Task by WhatId and OwnerId
     * @return  Map<Id, User>
     */
    public List<Task> selectOpenTaskByWhatIdAndOwnerId(Set<String> fieldSet, Id whatId, Id ownerId, Set<Id> recordTypeIds) {
        return new List<Task>((List<Task>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('WhatId =: whatId AND OwnerId =: ownerId AND Status != \'' + CON_CPQ.COMPLETED  + + '\' AND Status != \'Rejected\' AND Status != \'Waiting on someone else\' AND RecordTypeId in: recordTypeIds').toSOQL()));
    }
    
    /**
    * This method used to get Task by WhatIds
    * @return  Map<Id, User>
    */
    public List<Task> selectTaskNonCompletedTasForAgreements(Set<String> fieldSet, Set<Id> whatIds, Set<Id> recordTypeIds) {
        return new List<Task>((List<Task>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('WhatId in: whatIds AND Status != \'' + CON_CPQ.COMPLETED  + '\' AND Status != \'Rejected\' AND Status != \'Waiting on someone else\' AND RecordTypeId in: recordTypeIds').toSOQL()));
    }
    
    /**
    * This method used to get Tasks
    * @return  List
    */
    public List<Task> getTasks(Set<String> fields, String condition, Integer limitRecords, String OrderBy ) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        if (limitRecords>0) {
            factory.setLimit(limitRecords);
        }
        if(!String.isBlank(OrderBy)) {
            factory.addOrdering(OrderBy, fflib_QueryFactory.SortOrder.DESCENDING);
        }
        return Database.query(factory.toSOQL());
    }

     public List<AggregateResult> getTasksByCampaign(Set<String> campaignIdSet, String disposition, String recordTypeId){
        return new List<AggregateResult>((List<AggregateResult>) Database.query('SELECT COUNT_DISTINCT(Id) campaignCount, Campaign_Name2__c from Task where Disposition__c = :disposition AND RecordTypeId = :recordTypeId GROUP BY Campaign_Name2__c HAVING Campaign_Name2__c IN :campaignIdSet '));
    }

    /**
    * This method used to get Tasks by what id and condition
    * @param whatIds whatid
    * @param condition other condition if any
    * @return  List
    */
    public List<Task> selectTaskByWhatIds(Set<String> fieldSet, Set<Id> whatIds, String condition) {
        return new List<Task>((List<Task>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL()));
    }
}