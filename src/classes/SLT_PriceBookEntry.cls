/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OpportunityLineItems
 */
public class SLT_PriceBookEntry extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_PriceBookEntry() {
        super(false, true, true);
    }

    /**
     * Method to override OrderBy
     */
    public override String getOrderBy() {
        return 'Product2.Name';
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
        return PriceBookEntry.sObjectType;
    }
    
    /**
     * selector method used to get PriceBookEntries By filter params
     * @param   Product2 filterProductObj
     * @param   Set<String> pbEntryFieldSet
     * @param   List<String> filterFieldsApiList
     * @param   Integer recordLimit
     * @return  List<PriceBookEntry>
     */
    public List<PriceBookEntry> getPbEntriesByFilterParams(String condition, PriceBookEntryWrapper pbeWrapper, Set<String> pbeFieldSet, Integer recordLimit) {
        List<String> productIds = pbeWrapper.productIds;
        string queryString = newQueryFactory(false).selectFields(pbeFieldSet).setCondition(condition).setLimit(recordLimit).toSOQL();
        return (List<PriceBookEntry>) Database.query(queryString);
    }
    
    public Integer getPbEntriesCountByFilterParams(String condition, PriceBookEntryWrapper pbeWrapper) {
        List<String> productIds = pbeWrapper.productIds;
        string queryString = 'SELECT Count(Id) FROM PriceBookEntry where '+ condition;
        List<AggregateResult> ar = Database.query(queryString);
        return (Integer)ar[0].get('expr0');
    }
    
    /**
     * selector method used to get PriceBookEntries By product id. 
     * @param   Set<Id> productIdSet
     * @param   Set<String> pbeFieldSet
     * @return  List<PriceBookEntry>
     */
    public List<PriceBookEntry> getPbEntriesByProductIds(Set<Id> productIdSet, Set<String> pbeFieldSet, String currencyIsoCode) {
        return ((List<PriceBookEntry>) Database.query(newQueryFactory(true).selectFields(pbeFieldSet).setCondition('Product2.id in :productIdSet AND CurrencyIsoCode = :currencyIsoCode').toSOQL()));
    }
    
    /**
     * selector method used to get PriceBookEntries By product id. 
     * @param   Set<Id> pbeIdSet
     * @return  Map<Id, PriceBookEntry>
     */
    public Map<Id, PriceBookEntry> getMapOfPbEntriesByProductIdSet(Set<Id> pbeIdSet) {
        return new Map<Id, PriceBookEntry>([SELECT Id, Product2.Offering_Type__c, Product2.Offering_Segment__c FROM PriceBookEntry WHERE Id In: pbeIdSet]);
    }
    
    /**
     * selector method used to get PriceBookEntries By product id.
     * @param   Set<Id> productIdSet
     * @param   Set<String> fieldSet
     * @param   Id Pricebook2Id
     * @param   List<String> currencyCode
     * @return  List<PriceBookEntry>
     */
    public List<PriceBookEntry> getStandardPriceBookByName(Set<String> fieldSet, Set<Id> productIdSet, Id priceBookID, List<String> currencyCode) {
        return (List<PriceBookEntry>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Product2.id in :productIdSet AND Pricebook2Id =: priceBookID AND CurrencyIsoCode =: currencyCode').toSOQL());
    }

    /**
     * selector method used to get PriceBookEntries By product id.
     * @param   Id Pricebook2Id
     * @param   Set<Id> productIdSet
     * @param   Set<String> fieldSet
     * @param   Set<String> currencyCode
     * @return  List<PriceBookEntry>
     */
    public List<PricebookEntry> getPricebookEntriesForProducts(Id priceBookID, Set<Id> productIdSet, Set<String> currencyCodes, Set<String> fieldSet) {
        return (List<PricebookEntry>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet)
            .setCondition('Pricebook2Id = :priceBookID ' +
                'AND Product2.Id in :productIdSet ' +
                'AND CurrencyIsoCode in :currencyCodes')
            .toSOQL());
    }
    /**
     * selector method used to get PriceBookEntries By product code.
     * @param   Set<String> productCodeSet
     * @param   Set<String> fieldSet
     * @param   List<String> currencyCode
     * @return  List<PriceBookEntry>
     */
    public List<PricebookEntry> getPricebookEntriesForProductList(Set<String> productCodeSet, Set<String> fieldSet, List<String> currencyCodes) {
        return (List<PricebookEntry>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet)
            .setCondition(
                'ProductCode in :productCodeSet ' +
                'AND CurrencyIsoCode in :currencyCodes')
            .toSOQL());
    }
}