public class SLT_BusinessHours extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_BusinessHours() {
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
        return BusinessHours.sObjectType;
    }
    
    /**
     * This method used to get BusinessHours by Id
     * @return  Map<Id, User>
     */
    public Map<Id, BusinessHours> selectByBusinessHoursId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, BusinessHours>((List<BusinessHours>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
}