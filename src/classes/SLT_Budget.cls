public class SLT_Budget extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */ 
    public SLT_Budget() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Budget(Boolean enforceFLS) {
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
        return pse__Budget__c.sObjectType;
    }

    /**
    * Method to get budgets by project 
    * @return List<pse__Budget__c>
    */
    public List<pse__Budget__c> selectByProject(Set<Id> projectIdSet, Set<String> fieldSet){
        fflib_QueryFactory budgetQueryFactory = newQueryFactory(true);
        String queryString = budgetQueryFactory.selectFields(fieldSet).setCondition('pse__Project__c IN :projectIdSet').toSOQL();
        return (List<pse__Budget__c>) Database.query(queryString);
    }

}