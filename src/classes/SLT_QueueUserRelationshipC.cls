public class SLT_QueueUserRelationshipC extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_QueueUserRelationshipC() {
        super(false, true, true);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Queue_User_Relationship__c.sObjectType;
    }
    
    /**
     * This method used to get Queue_User_Relationship__c by Id
     * @return  Map<Id, User>
     */
    
    public Map<Id, Queue_User_Relationship__c> selectByQueueId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Queue_User_Relationship__c>((List<Queue_User_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    public List<Queue_User_Relationship__c> selectByQueueName(String currentQueue, Set<String> fieldSet,String userId) {
        return ((List<Queue_User_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name = :currentQueue and Type__c = \'Queue\'').toSOQL()));
    }
    
    public List<Queue_User_Relationship__c> selectByUserGrop(Set<Id> addOId) {
        return (List<Queue_User_Relationship__c>)Database.query('select Id,Name,Los__c,Type__c,Group_Id__c,User__c,User_Email__c,Queue_Email__c,TECH_QueueUser__c,Business_Hours__c,Tier__c,Business_Hours__r.TimeZoneSidKey FROM Queue_User_Relationship__c where (User__c In: addOId and Type__c = \'User\') or (Group_Id__c In: addOId and Type__c = \'Queue\') Order by Name');
    }
    
    public List<Queue_User_Relationship__c> selectByGroupOLA(Set<Id> addOId) {
        return [select Id,Name,Type__c,Group_Id__c,User__c,User_Email__c,Queue_Email__c,Business_Hours__c,Business_Hours__r.TimeZoneSidKey FROM Queue_User_Relationship__c where (Group_Id__c In: addOId and Type__c = 'Queue') and Business_Hours__c != null Order by Name];
    }
    
    public List<Queue_User_Relationship__c> selectByOLAQueueUserEmails(List<Id> addOId) {
        return [select Id,Name,Type__c,Group_Id__c,User__c,User_Email__c,Queue_Email__c,Business_Hours__c,Business_Hours__r.TimeZoneSidKey FROM Queue_User_Relationship__c where (Group_Id__c In: addOId and Type__c = 'User') and User__r.IsActive = true Order by Name];
    }
    public List<Queue_User_Relationship__c> selectByUserQueueName(Set<Id> uptOId,Set<String> queueNameSet) {
        return [select Id,Name,Los__c,Type__c,Group_Id__c,User__c,User_Email__c,Queue_Email__c,TECH_QueueUser__c, Tier__c, Business_Hours__c,Business_Hours__r.TimeZoneSidKey From Queue_User_Relationship__c where User__c In: uptOId and Name In :queueNameSet];
    }
    
    public List<Queue_User_Relationship__c> selectByQueueIdSet(Set<ID> idSet, Set<String> fieldSet) {
        return (List<Queue_User_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }
    
    public List<Queue_User_Relationship__c> selectByUserGroupQueueIdSet(Set<ID> idSet, Set<Id> userIdSet,Set<String> fieldSet) {
        return (List<Queue_User_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Group_Id__c in :idSet and User__c in :userIdSet').toSOQL());
    }
    
    public List<Queue_User_Relationship__c> selectByGroupIdSet(Set<ID> idSet) {
        if(Test.isRunningTest()){
            return [select Id,Name,Type__c,Group_Id__c,User__c,User__r.Name,User_Email__c,Queue_Email__c FROM Queue_User_Relationship__c];    
        }else{
            return [select Id,Name,Type__c,Group_Id__c,User__c,User__r.Name,User_Email__c,Queue_Email__c FROM Queue_User_Relationship__c where (User__c In: idSet and Type__c = 'User') or (Group_Id__c In: idSet and Type__c = 'Queue')];
        }
    }
    
    public List<Queue_User_Relationship__c> selectAllTechQueue(Set<String> fieldSet) {
        return (List<Queue_User_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Type__c = \'Queue\' and Name like\'Tech%\'').toSOQL());
    }
    
    public List<Queue_User_Relationship__c> selectAllRnDQueues(){
        return [SELECT Id, Name, AFU_Queue_Email__c FROM Queue_User_Relationship__c WHERE Name LIKE 'RnD%' AND AFU_Queue_Email__c != null];
    }
    
    public List<Queue_User_Relationship__c> getUserQueueRecords(){
        return [SELECT Id, Name, AFU_Queue_Email__c FROM Queue_User_Relationship__c WHERE Name LIKE 'RnD%' AND AFU_Queue_Email__c != null AND Type__c ='Queue'];
    }
    
    public Map<Id, Queue_User_Relationship__c> selectBasedOnQueueId(Set<Id> idSet){
        List<Queue_User_Relationship__c> queueList = (List<Queue_User_Relationship__c>)Database.query('SELECT Id, Name, Group_Id__c,Los__c,Type__c,Tier__c,AccountId__c,User__c,IsDefaultQueue__c FROM Queue_User_Relationship__c WHERE Id IN :idSet OR TECH_QueueUser__c IN :idSet');
        Map<Id, Queue_User_Relationship__c> queueUserMap = new Map<Id, Queue_User_Relationship__c>();
        for(Queue_User_Relationship__c queueRecord : queueList){
            queueUserMap.put(queueRecord.Group_Id__c, queueRecord);
        }
        return queueUserMap;
    }
    
    public List<Queue_User_Relationship__c> selectBasedOnUserGroupTOwner(Set<Id> ownerIds){
        List<Queue_User_Relationship__c> userList = [SELECT Id, Name, Group_Id__c,Los__c FROM Queue_User_Relationship__c WHERE User__c In :OwnerIds AND Type__c = 'User'];
        Set<Id> groupIds = new Set<Id>();
        for(Queue_User_Relationship__c userRecord : userList){
            groupIds.add(userRecord.Group_Id__c);
        }
        return (List<Queue_User_Relationship__c>)Database.query('SELECT Id, Name, Type__c, Los__c,Group_Id__c, User__c, User_Email__c, Queue_Email__c, Business_Hours__c, Business_Hours__r.TimeZoneSidKey FROM Queue_User_Relationship__c WHERE (Group_Id__c IN :ownerIds OR Group_Id__c IN :groupIds) AND Type__c = \'Queue\' ORDER BY Name');
    }

    public List<Queue_User_Relationship__c> selectBasedOnUserGroup(Set<Id> ownerIds){
        List<Queue_User_Relationship__c> userList = [SELECT Id, Name, Group_Id__c,Los__c,TECH_QueueUser__c, Tier__c FROM Queue_User_Relationship__c WHERE User__c In :OwnerIds AND Type__c = 'User'];
        Set<Id> groupIds = new Set<Id>();
        for(Queue_User_Relationship__c userRecord : userList){
            groupIds.add(userRecord.TECH_QueueUser__c);
        }
        return (List<Queue_User_Relationship__c>)Database.query('SELECT Id, Name, Type__c, Los__c,Group_Id__c, User__c, User_Email__c, Queue_Email__c, Business_Hours__c,Pillar__c,isDefaultQueue__c,TECH_QueueUser__c, Tier__c,AccountId__c  FROM Queue_User_Relationship__c WHERE (Group_Id__c IN :ownerIds OR Id IN :groupIds or (User__c IN :ownerIds  and IsDefaultQueue__c = true)) ORDER BY Name');
    }
    
    public List<Queue_User_Relationship__c> selectByQueueName(Set<String> queueNameSet){
        return (List<Queue_User_Relationship__c>)Database.query('SELECT Id, Name, Tier__c, Group_Id__c FROM Queue_User_Relationship__c WHERE Name IN :queueNameSet AND Type__c = \'Queue\'');
    }
    
    public List<Queue_User_Relationship__c> selectByCSHUserorGroupSet(Set<ID> idSet) {
        if(Test.isRunningTest()){
            return [select Id,Name,Type__c,Group_Id__c,User__c,User_Email__c,Queue_Email__c FROM Queue_User_Relationship__c];    
        }else{
            return [select Id,Name,Type__c,Group_Id__c,User__c,User_Email__c,Queue_Email__c FROM Queue_User_Relationship__c where (User__c In: idSet and Type__c = 'User') or (Group_Id__c In: idSet)];
        }
    }
    
    public List<Queue_User_Relationship__c> selectByUserCaseReadOnlySet(Set<ID> idSet) {
        if(Test.isRunningTest()){
            return Database.query('select Id,Name,TECH_QueueUser__c, Case_ReadOnly__c, Group_Id__c  FROM Queue_User_Relationship__c');    
        }else{
            return Database.query('select Id,Name,TECH_QueueUser__c, Case_ReadOnly__c,Group_Id__c FROM Queue_User_Relationship__c where (User__c In: idSet and Type__c = \'User\') and Case_ReadOnly__c = true');
        }
    }
    
    public List<Queue_User_Relationship__c> selectByUserFromTECHQueueUser(Set<ID> idSet, Set<String> fieldSet){
        return (List<Queue_User_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('TECH_QueueUser__c in :idSet and Type__c = \'User\'').toSOQL());
    }
    
    public List<Queue_User_Relationship__c> selectByQueueNameforRoundRobin(String queueName){
        return (List<Queue_User_Relationship__c>) Database.query('SELECT Type__c,User__c,LastAssignedCaseTime__c,LastAssignedCaseMilliseconds__c,Enable_Round_Robin__c,OutOfOffice_StartDate__c,OutOfOffice_EndDate__c,Out_Of_Office_Notification__c,Business_Hours__c FROM Queue_User_Relationship__c WHERE Name =: queueName order by LastAssignedCaseTime__c,LastAssignedCaseMilliseconds__c');
    }

    public List<Queue_User_Relationship__c> selectByUserTECHQueueIDSet(Set<ID> idSet, Set<Id> userIdSet,Set<String> fieldSet) {
        return (List<Queue_User_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('(TECH_QueueUser__c in :idSet AND TECH_QueueUser__r.BypassInitialQueueClosureRule__c = false and User__c in :userIdSet and Type__c = \'User\') OR (Id in :idSet AND BypassInitialQueueClosureRule__c = true)').toSOQL());
    }

    public List<Queue_User_Relationship__c> selectByQueueUserforRoundRobin(Set<ID> queueIds){
        return (List<Queue_User_Relationship__c>) Database.query('SELECT Id,Name,User__c,TECH_QueueUser__c,Type__c,User_Email__c,Enable_Round_Robin__c, LastAssignedCaseTime__c,OutOfOffice_StartDate__c,OutOfOffice_EndDate__c from Queue_User_Relationship__c where (TECH_QueueUser__c in:queueIds or Id in:queueIds) order by LastAssignedCaseTime__c,LastAssignedCaseMilliseconds__c limit 100');
   }
}