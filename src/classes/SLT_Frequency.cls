public class SLT_Frequency extends fflib_SObjectSelector {

    public SLT_Frequency() {
        super(false, true, false);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CSM_QI_Frequency__c.Id,
            CSM_QI_Frequency__c.Name,
            CSM_QI_Frequency__c.Frequency__c,
            CSM_QI_Frequency__c.Month_Date__c,
            CSM_QI_Frequency__c.Month_Interval__c,
            CSM_QI_Frequency__c.Week__c,
            CSM_QI_Frequency__c.Weekday__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return CSM_QI_Frequency__c.sObjectType;
    }
    
    public List<CSM_QI_Frequency__c> selectById(Set<ID> idSet) {
        return (List<CSM_QI_Frequency__c>) selectSObjectsById(idSet);
    }
}