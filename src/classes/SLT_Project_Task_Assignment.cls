public class SLT_Project_Task_Assignment extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Project_Task_Assignment() {
        super(true, false, false);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{};
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return pse__Project_Task_Assignment__c.sObjectType;
    }

    public List<pse__Project_Task_Assignment__c> getTaskAssignmentsByTask(Set<Id> taskIdSet, Set<String> fieldSet){
        return new List<pse__Project_Task_Assignment__c>((List<pse__Project_Task_Assignment__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Project_Task__c IN :taskIdSet').toSOQL()));
    }
}