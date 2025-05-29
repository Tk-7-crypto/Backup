public with sharing class SLT_Template_Data extends fflib_SObjectSelector {
    
    public SLT_Template_Data() {
        super(false, false, false);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Template_Data__c.Id,
            Template_Data__c.Name,
            Template_Data__c.DML_Type__c,
            Template_Data__c.Field_Name__c,
            Template_Data__c.Package_Name__c,
            Template_Data__c.Object_Name__c,
            Template_Data__c.version__c,
            Template_Data__c.Cell_Reference__c
        };
    }    													  
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Template_Data__c.sObjectType;
    }
   
    /**
     * This method used to get Template Data by Name
     * @return  List<Template_Data__c>
     */
    public List<Template_Data__c> selectTemplateDataByName(String templateName) {
        return [SELECT Id, Cell_Reference__c, Version__c, Object_Name__c, Package_Name__c, Field_Name__c, DML_Type__c FROM Template_Data__c where Name = :templateName ORDER BY Object_Name__c];
    }
    
    public List<Template_Data__c> getTemplateDataByCondition(String condition, Set<String> fieldSet) {
        return (List<Template_Data__c>) Database.query(
           newQueryFactory(true)
           .selectFields(fieldSet)
           .setCondition(condition)
           .toSOQL());
    }
}
