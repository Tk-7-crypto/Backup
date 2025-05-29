/*
 * Version       : 1.0
 * Description   : Selector Class for SLT_Template_Selection_Criteria__c
 */
public class SLT_Template_Selection_Criteria extends fflib_SObjectSelector {
    public SLT_Template_Selection_Criteria() {}
    
    public SLT_Template_Selection_Criteria(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
	
	/**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }

    public Schema.SObjectType getSObjectType(){
        return Template_Selection_Criteria__c.sObjectType;
    }

    public List<Template_Selection_Criteria__c> getTemplateSelectionCriteriaList(Set<String> fields, String condition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
}