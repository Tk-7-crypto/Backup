/*
* Version       : 1.0
* Description   : This Apex class is selector layer for standard Quote
*/
public class SLT_Quote extends fflib_SObjectSelector {
    
    public String orderByField = 'Name';

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Quote() {
        super(false, true, true);
    }
    
    /**
    * constructor to initialise CRUD and FLS with a parameter for FLS.
    */
    public SLT_Quote(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    /**
    */
    public SLT_Quote(Boolean enforceCRUD,Boolean enforceFLS) {
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
        return Quote.sObjectType;
    }
    
    /**
     * Method to override OrderBy
     */
    public override String getOrderBy() {
        return orderByField;
    }
    /**
     * Get Quote by Ids
     */
    public List<Quote> getQuotesById(Set<Id> idSet, Set<String> fieldSet) {
        return new List<Quote>((List<Quote>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    /**
     * Get Quote by Contract Ids
     */
    public List<Quote> getQuotesByCondition(Set<String> fieldSet,String condition, Set<Id> IdSet) {
        return new List<Quote>((List<Quote>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL()));
    }
}