public class SLT_IQVIA_Quote extends fflib_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
	
    public Schema.SObjectType getSObjectType() {
        return Quote__c.sObjectType;
    }
    
    public Quote__c getQuoteId(Id quoteId, Set<String> fieldSet) {
        return (Quote__c) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Id = :quoteId').toSOQL());
    }
	
    public Quote__c getQuoteDetails(Id recordId) {
        return[SELECT Id, Name, Related_Bid__c, Primary__c, Approval_Stage__c, Pricing_Tools__c, GBU__c, Related_Opportunity__c, Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c, Approver_5__c, OwnerId, Selected_Languages__c, CurrencyIsoCode, Conversion_Rate__c FROM Quote__c WHERE ID =: recordId];
    }
    
    public List<Quote__c> getQuoteIdslist(Set<Id> IdSet, Set<String> fieldSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        queryFactory.selectFields(fieldSet);
        queryFactory.setCondition('id = :IdSet');
        return (List<Quote__c>) Database.query(queryFactory.toSOQL());
    }

    public List<Quote__c> getQuotesByCondition(Set<String> fieldSet, String condition, Set<Id> relatedOpportunityIdSet) {
        return new List<Quote__c>((List<Quote__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL()));
    }

    public List<Quote__c> getQuotesByConditionOrderByAcceptedDate(Set<String> fieldSet, String condition, String orderByField, String sortOrder, Set<Id> relatedOpportunityIdSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        if (!fieldSet.isEmpty()) {
            queryFactory.selectFields(fieldSet);
        }
        if (!String.isBlank(condition)) {
            queryFactory.setCondition(condition);
        }
        if (sortOrder == CON_CPQ.SORT_ASC) {
            queryFactory.setOrdering(orderByField, fflib_QueryFactory.SortOrder.ASCENDING);
        }
        else if (sortOrder == CON_CPQ.SORT_DESC) {
            queryFactory.setOrdering(orderByField, fflib_QueryFactory.SortOrder.DESCENDING);
        }
        return (List<Quote__c>) Database.query(queryFactory.toSOQL());
    }

    public Map<Id, Quote__c> getQuoteMap(Set<Id> quoteIds, Set<String> fieldSet) {
        return new Map<Id, Quote__c>((List<Quote__c>)Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :quoteIds').toSOQL()));
    }
}