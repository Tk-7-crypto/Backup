public class SLT_ActivityC extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_ActivityC() {
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
        return Activity__c.sObjectType;
    }
    
    /**
     * This method used to get Activity__c by Id
     * @return  Map<Id, Activity__c>
     */
    public Map<Id, Activity__c> selectByActivityId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Activity__c>((List<Activity__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    public List<Activity__c> selectByActivityCaseId(Set<ID> idSet) {
        return Database.query('Select Id,Description__c,CreatedDate,Status__c,Case__r.Id From Activity__c  where Case__c = :idSet  order by CreatedDate desc LIMIT 1');
    }
	
    /**
     * This method used to get set of Case Id
     * @return  List<Activity__c>
     */
    public List<Activity__c> selectActivityByCaseId(Set<ID> idSet, Set<String> fieldSet) {
        return (List<Activity__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Case__c in :idSet').toSOQL());
    }
    
    /**
     * This method used to get list of activities by condition
     * @return  List<Activity__c>
     */
    public List<Activity__c> selectActivityByCaseIdOrdered(Set<Id> caseIdSet) {
        return [SELECT Id, Case__c, Case__r.CaseNumber, Name, Description__c, Status__c, PassFail__c, LOS__c, Type__c, 
                EscalationType__c , RandD_Location__c, Email_Categorization__c
                FROM Activity__c 
                WHERE Case__c in: caseIdSet 
                ORDER BY Case__c, Name
               ];
    }
    
    public List<Activity__c> getActivityById(Set<Id> activityids){
        return [SELECT ID, Attachments__c from Activity__c where Id in : activityids];
    }
    
    public List<Activity__c> selectByEmailActivityCaseId(Set<ID> idSet) {
        return Database.query('Select Id,Name,Type__c,Description__c,CreatedDate,Status__c,Case__c,EmailMessageId__c,Email_Categorization__c From Activity__c  where Case__c = :idSet and EmailMessageId__c != null');
    }
    
}