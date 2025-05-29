/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Project_Target__c
 */
public class SLT_Project_Target extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Project_Target () {
        super(false, true, true);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList () {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }

    /**
     * This method used to get field set of field names for the sobject
     * @return  Set<String>
     */
    public Set<String> getSObjectFieldSet () {
        Set<String> fieldNames = new Set<String>();
        List<Schema.SObjectField> fields = getSObjectFieldList();
        if (fields != null && fields.size() > 0) {
            for (Schema.SObjectField sobjField : fields) {
                fieldNames.add(String.valueof(sobjField));
            }
        }        
        return fieldNames;
    }    
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType () {
        return Project_Target__c.sObjectType;
    }

    /**
     * This method used to get Project Target by Project 
     * @return  List<Project_Target__c>
     */
    public List<Project_Target__c> getProjectTargetByProject(Set<Id> projectIds, Set<String> fieldSet) {
        return (List<Project_Target__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Project__c IN :projectIds').toSOQL());
    }

    /**
     * This method used to get Project Target by Service Line Project 
     * @return  List<Project_Target__c>
     */
    public List<Project_Target__c> getProjectTargetByServiceLineProject(Set<Id> projectIds, Set<String> fieldSet) {
        return (List<Project_Target__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Service_Line_Project__c IN :projectIds').toSOQL());
    }
}