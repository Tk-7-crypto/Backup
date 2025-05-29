public class SLT_Workflow_Email_Alert extends fflib_SObjectSelector{
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Workflow_Email_Alert () {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Workflow_Email_Alert (Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    public SLT_Workflow_Email_Alert(Boolean enforceFLS,Boolean enforceCRUD) {
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
        return Workflow_Email_Record__c.sObjectType;
    }

    /**
     * This method used to get workflow email records
     */
    public Map<Id, Workflow_Email_Record__c> selectWorkflowsByIdSet(Set<ID> sObjectIdset, Set<String> wrkflwFieldSet) {
        fflib_QueryFactory wrkflwQueryFactory = newQueryFactory(true);
        String queryString = wrkflwQueryFactory.selectFields(wrkflwFieldSet).setCondition('Id in :sObjectIdset').toSOQL();
        return new Map<Id, Workflow_Email_Record__c>((List<Workflow_Email_Record__c>) Database.query(queryString));
    }

}