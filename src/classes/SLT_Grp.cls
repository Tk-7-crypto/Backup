public class SLT_Grp extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Grp() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Grp(Boolean enforceFLS) {
        super(false, true, enforceFLS);
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
        return pse__Grp__c.sObjectType;
    }

    /**
    * Method to get a single group by name
    * @return pse__Grp__c
    */
    public pse__Grp__c selectSingleGroupByName(String groupName, Set<String> groupFieldSet){
        fflib_QueryFactory groupQueryFactory = newQueryFactory(true);
        String queryString = groupQueryFactory.selectFields(groupFieldSet).setCondition('Name = :groupName').toSOQL();
        List<pse__Grp__c> groups = (List<pse__Grp__c>) Database.query(queryString);
        return (groups.size() > 0) ? groups.get(0) : null;
    }
}