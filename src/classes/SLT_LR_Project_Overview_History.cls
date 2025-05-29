public class SLT_LR_Project_Overview_History extends fflib_SObjectSelector{

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_LR_Project_Overview_History () {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_LR_Project_Overview_History (Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    public SLT_LR_Project_Overview_History(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceFLS, enforceCRUD);
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
        return LR_Project_Overview__History.sObjectType;
    }
    
    /**
     * This method retrieves lr history records
     */
    public List<LR_Project_Overview__History> getHistoryRecByParentLRId(Set<Id> parentIdSet, Set<String> lrHstryFieldSet){
        fflib_QueryFactory lrHstryQueryFactory = newQueryFactory(true);
        String queryString = lrHstryQueryFactory.selectFields(lrHstryFieldSet).setCondition(' ParentId IN :parentIdSet').toSOQL();
        return (List<LR_Project_Overview__History>) Database.query(queryString);
    }
} 
