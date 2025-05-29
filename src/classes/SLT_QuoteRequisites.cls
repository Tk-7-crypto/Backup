public class SLT_QuoteRequisites extends fflib_SObjectSelector {
    public String orderByField = 'Name';

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_QuoteRequisites() {
        super(false, true, true);
    }
    
    /**
    * constructor to initialise CRUD and FLS with a parameter for FLS.
    */
    public SLT_QuoteRequisites(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    /**
    */
    public SLT_QuoteRequisites(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
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
        return Quote_Requisites__c.sObjectType;
    }
    
    /**
     * Method to override OrderBy
     */
    public override String getOrderBy() {
        return orderByField;
    }

    public List<Quote_Requisites__c> getQuoteRequisitesByQuoteId(Set<Id> quoteIdSet, Set<String> fieldSet, String condition) {
        return new List<Quote_Requisites__c>((List<Quote_Requisites__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL()));
    }

    public List<Quote_Requisites__c> getQuoteRequisitesByStudyNumber(String studyNumber, Id quoteId, Set<String> fieldSet, String condition) {
        return new List<Quote_Requisites__c>((List<Quote_Requisites__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL()));
    }

    public List<Quote_Requisites__c> getQuoteRequisitesById(Set<Id> idSet, Set<String> fieldSet) {
        return new List<Quote_Requisites__c>((List<Quote_Requisites__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }

    public List<Quote_Requisites__c> getQuoteRequisitesByQuoteIdAndCartParams(Set<String> fieldSet, String condition, Set<String> StudyNumberSet, Set<String> serviceLineNameSet) {
        return new List<Quote_Requisites__c>((List<Quote_Requisites__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL()));
    }
    
    public List<Quote_Requisites__c> getQuoteRequisitesRecord(Set<Id> quoteIdSet, Set<String> fieldSet, String condition) {
        return new List<Quote_Requisites__c>((List<Quote_Requisites__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).setOrdering('Study_Number__c',  fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL()));
    }
}