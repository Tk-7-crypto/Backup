/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Project Related System
 */
public class SLT_Project_Related_System extends fflib_SObjectSelector{
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Project_Related_System() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Project_Related_System(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_Project_Related_System(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Project_Related_System__c.sObjectType;
    }

    /**
     * This method returns a list of all Project Related Systems for one ore more Projects
     */
    public List<Project_Related_System__c> getRelatedSystemsByProject(Set<Id> projectIds){
        return getRelatedSystemsByProject(projectIds, getDefaultFields());
    }

    public List<Project_Related_System__c> getRelatedSystemsByProject(Set<Id> projectIds, Set<String> fields){
        return ((List<Project_Related_System__c>) Database.query(newQueryFactory(false).selectFields(fields).setCondition('Project__c IN :projectIds').toSOQL()));
    }

    /**
     * This method gets all Project Related Systems on a single Project that match a list of PSA Related Systems
     */
    public List<Project_Related_System__c> getProjectRelatedSystemsByPSASystem(Set<Id> psaSystems, Id projectId){
        return getProjectRelatedSystemsByPSASystem(psaSystems,projectId,getDefaultFields());
    }

    public List<Project_Related_System__c> getProjectRelatedSystemsByPSASystem(Set<Id> psaSystems, Id projectId, Set<String> fields){
        return ((List<Project_Related_System__c>) Database.query(newQueryFactory(false).selectFields(fields).setCondition('PSA_Related_System__c IN :psaSystems AND Project__c = :projectId').toSOQL()));
    }

    private Set<String> getDefaultFields(){
        return new Set<String>{'Id','Name','Project__c','PSA_Related_System__c','Type__c','Client_System_Name__c','Hosted_By__c','Service_Lines__c','Additional_Info__c'};
    }
}