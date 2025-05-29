public class SLT_IQVIAPriceMatrix extends fflib_SObjectSelector {
    public String orderByField = 'Name';

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_IQVIAPriceMatrix() {
        super(false, true, true);
    }
    
    /**
    * constructor to initialise CRUD and FLS with a parameter for FLS.
    */
    public SLT_IQVIAPriceMatrix(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    /**
    */
    public SLT_IQVIAPriceMatrix(Boolean enforceCRUD,Boolean enforceFLS) {
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
        return IQVIA_Price_Matrix__c.sObjectType;
    }
    
    /**
     * Method to override OrderBy
     */
    public override String getOrderBy() {
        return orderByField;
    }

    public List<IQVIA_Price_Matrix__c> getIqviaPriceMatrixByCondition(Set<String> fieldSet, String condition, Set<String> productCodeSet, Set<String> serviceLineNameSet, Set<String> siteSet, Set<String> clinicalTypeSet, Set<Integer> analyteSet, Set<String> premiumSet, Set<String> specimenTypeSet, Set<String> bundleProductCodeSet) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(fieldSet).setCondition(condition).setOrdering('Account__c', fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL();
        return (List<IQVIA_Price_Matrix__c>)Database.query(queryString);
    }

    public List<IQVIA_Price_Matrix__c> getIqviaPriceMatrixByConditionOrderByStartDate(Set<String> fieldSet, String condition, Set<String> productCodeSet, Set<String> serviceLineNameSet, Set<String> siteSet, Set<String> clinicalTypeSet, Set<Integer> analyteSet, Set<String> premiumSet, Set<String> specimenTypeSet, Set<String> bundleProductCodeSet) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(fieldSet).setCondition(condition).setOrdering('Start_Date__c', fflib_QueryFactory.SortOrder.DESCENDING, true).toSOQL();
        return (List<IQVIA_Price_Matrix__c>)Database.query(queryString);
    }
    
    public List<IQVIA_Price_Matrix__c> getIQVIAPriceMatrix(Set<String> fieldSet, String condition) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(fieldSet).setCondition(condition).setOrdering('Account__c', fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL();
        return (List<IQVIA_Price_Matrix__c>)Database.query(queryString);
    }
}