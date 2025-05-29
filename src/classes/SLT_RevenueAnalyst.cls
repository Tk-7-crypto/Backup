public class SLT_RevenueAnalyst extends fflib_SObjectSelector  {
    /**
     * constructor to initialise CRUD and FLS 
     */
    public SLT_RevenueAnalyst() {
        super(false, false, false); 
    }
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Revenue_Analyst__c.Id,
            Revenue_Analyst__c.Name,
            Revenue_Analyst__c.OwnerId    
        };
    }
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Revenue_Analyst__c.sObjectType;
    }
    
    /**
     * This method used to get Revenue_Analyst__c by Id
     * @return  List<User>
     */
    public List<Revenue_Analyst__c> selectById(Set<ID> idSet) {
        return (List<Revenue_Analyst__c>) selectSObjectsById(idSet);
    }
    /**
     * This method used to get Revenue_Analyst__c by Id
     * @return  Map<Id, Account>
     */
    public Map<Id, Revenue_Analyst__c> selectByRevAnalystId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Revenue_Analyst__c>((List<Revenue_Analyst__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
}