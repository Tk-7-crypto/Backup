public class SLT_APTS_Agreement_History extends fflib_SObjectSelector{

    public String orderByField = 'CreatedDate';
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_APTS_Agreement_History () {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_APTS_Agreement_History (Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    public SLT_APTS_Agreement_History(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceFLS, enforceCRUD);
    }

    /**
     * Method to override OrderBy
     */
     
    public override String getOrderBy() {
        return orderByField;
    } 

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList () {
        return new List<Schema.SObjectField>();
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType () {
        return Apttus__APTS_Agreement__History.sObjectType;
    }
    
    /**
     * This method retrieves lr history records
     */
    public List<Apttus__APTS_Agreement__History> getHistoryRecByParentId(Set<Id> parentIdSet, Set<String> fieldSet, String condition){
        orderByField = 'CreatedDate DESC';
        fflib_QueryFactory hstryQueryFactory = newQueryFactory(true);
        String queryString = hstryQueryFactory.selectFields(fieldSet).setCondition(condition).toSOQL();
        return (List<Apttus__APTS_Agreement__History>) Database.query(queryString);
    }
}