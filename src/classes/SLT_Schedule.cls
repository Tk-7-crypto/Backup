/*
* Version       : 1.0
* Description   : This Apex class is selector layer for Schedule
*/
public class SLT_Schedule extends fflib_SObjectSelector {
    
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Schedule() {
        super(false, true, true);
    }
     /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Schedule(Boolean enforceFLS) {
        super(false, false, enforceFLS);
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
        return pse__Schedule__c.sObjectType;
    }
     /**
    * This method used to get Schedule by with Schedule Ids
    * @params  Set<Id> idSet
    * @params  Set<String> fieldSet
    * @return  Map<Id, pse__Schedule__c>
    */
    public Map<Id, pse__Schedule__c> selectScheduleById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, pse__Schedule__c>((List<pse__Schedule__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }    
}