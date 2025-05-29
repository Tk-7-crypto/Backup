public class DAO_IQ_QuoteRequisites extends fflib_SObjectDomain {
    
    public DAO_IQ_QuoteRequisites(List<Quote_Requisites__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new DAO_IQ_QuoteRequisites(sObjectList);
        }
    }
    
    public override void onApplyDefaults() {}
    
    public override void onBeforeInsert() {
        Map<String, List<Quote_Requisites__c>> quoteRequistesByTypeMap = DAOH_IQ_QuoteRequisites.getQuoteRequisitesByType((list<Quote_Requisites__c>) Records);
        if (quoteRequistesByTypeMap.containsKey(CON_CPQ.COUNTRY_INPUT) && quoteRequistesByTypeMap.get(CON_CPQ.COUNTRY_INPUT).size() > 0) {
            DAOH_IQ_QuoteRequisites.populateFields(quoteRequistesByTypeMap.get(CON_CPQ.COUNTRY_INPUT), null);
        }
    }
    
    public override void onAfterInsert() {
        Map<String, List<Quote_Requisites__c>> quoteRequistesByTypeMap = DAOH_IQ_QuoteRequisites.getQuoteRequisitesByType((list<Quote_Requisites__c>) Records);
        if (quoteRequistesByTypeMap.containsKey(CON_CPQ.COUNTRY_INPUT) && quoteRequistesByTypeMap.get(CON_CPQ.COUNTRY_INPUT).size() > 0) {
            DAOH_IQ_QuoteRequisites.calculateAndUpdateTotalSiteCount(quoteRequistesByTypeMap.get(CON_CPQ.COUNTRY_INPUT), null);
        }
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        Map<String, List<Quote_Requisites__c>> quoteRequistesByTypeMap = DAOH_IQ_QuoteRequisites.getQuoteRequisitesByType((list<Quote_Requisites__c>) Records);
        if (quoteRequistesByTypeMap.containsKey(CON_CPQ.COUNTRY_INPUT) && quoteRequistesByTypeMap.get(CON_CPQ.COUNTRY_INPUT).size() > 0) {
            DAOH_IQ_QuoteRequisites.populateFields(quoteRequistesByTypeMap.get(CON_CPQ.COUNTRY_INPUT), (Map<Id, Quote_Requisites__c>) existingRecords);
        }
    }
    
    public override void onAfterUpdate(Map<Id, SObject> existingRecord) {
        Map<String, List<Quote_Requisites__c>> quoteRequistesByTypeMap = DAOH_IQ_QuoteRequisites.getQuoteRequisitesByType((list<Quote_Requisites__c>) Records);
        if (quoteRequistesByTypeMap.containsKey(CON_CPQ.COUNTRY_INPUT) && quoteRequistesByTypeMap.get(CON_CPQ.COUNTRY_INPUT).size() > 0) {
            DAOH_IQ_QuoteRequisites.calculateAndUpdateTotalSiteCount(quoteRequistesByTypeMap.get(CON_CPQ.COUNTRY_INPUT), (Map<Id, Quote_Requisites__c>)existingRecord);
        }
    }
    
    public override void onBeforeDelete() {}
    
    public override void onAfterDelete() {}
}