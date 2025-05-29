/*
 * Version       : 1.0
 * Description   : Selector Class for Apttus__APTS_Template__c
 */
public class SLT_Apttus_APTS_Template extends fflib_SObjectSelector {

    public SLT_Apttus_APTS_Template() {}
    
    public SLT_Apttus_APTS_Template(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
	
	/**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }

    public Schema.SObjectType getSObjectType() {
        return Apttus__APTS_Template__c.sObjectType;
    }

    public List<Apttus__APTS_Template__c> getTemplates(Set<String> fields, String condition, Integer recordLimit) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(String.isNotBlank(condition)) {
            factory.setCondition(condition);
        }
        if(recordLimit != -1) {
            factory.setLimit(recordLimit);
        }
        return Database.query(factory.toSOQL());
    }
}