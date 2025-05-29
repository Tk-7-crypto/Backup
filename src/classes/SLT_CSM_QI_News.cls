public class SLT_CSM_QI_News extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_CSM_QI_News() {
        super(false, true, true);
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
        return CSM_QI_News__c.sObjectType;
    }
    
    /**
     * Method to override OrderBy
     */
    public override String getOrderBy() {
        return 'Lastmodifieddate DESC';
    }
    
    /**
     * This method used to get all CSM_QI_News__c
     * @params  fieldSet
     * @return  List<CSM_QI_News__c>
     */
    public List<CSM_QI_News__c> selectAllNews(Set<String> fieldSet) {
        return (List<CSM_QI_News__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
    
    /**
     * This method used to get all CSM_QI_News__c
     * @params  fieldSet Set<String> 
     * @params  module String
     * @return  List<CSM_QI_News__c>
     */
    public List<CSM_QI_News__c> selectNewsByModule(Set<String> fieldSet, String module, String type) {
        return (List<CSM_QI_News__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Module__c =:module and Profile__c = null AND Type__c =:type').toSOQL());
    }
}