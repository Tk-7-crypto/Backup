/*
* Version       : 0.0.1
* Description   : This Apex class is selector layer for QuoteLineItem
* Created By    : Danish khan
* Created For   : CPQ_QuoteUtitlity
*/  
public class SLT_QuoteLineItem extends fflib_SObjectSelector {
    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Quote_Line_Item__c.Id
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return Quote_Line_Item__c.SObjectType;
    }

    /**
     * This method used to get Line Item by Id
     * @return  Quote Line Item
     */
    public Quote_Line_Item__c selectedQuoteLineItemRecords(String condition , Set<String> fieldSet) {
        return (Quote_Line_Item__c) Database.query(
            newQueryFactory(true)
            .selectFields(fieldSet)
            .setCondition(condition)
            .toSOQL());
    }

    public List<Quote_Line_Item__c> getQuoteLineItemByPricingTools(String condition, Set<String> fieldSet, Set<String> optionSet, Set<String> bundleSet, List<String> pricingToolSet) {
        return (List<Quote_Line_Item__c>) Database.query(
            newQueryFactory(true)
            .selectFields(fieldSet)
            .setCondition(condition)
            .toSOQL());
    }
    
    public Map<Id, Quote_Line_Item__c> getQuoteLineItemRecords(Set<Id> recordIds, Set<String> fieldSet) {
        return new Map<Id, Quote_Line_Item__c>((List<Quote_Line_Item__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :recordIds').toSOQL()));
    }
    
    public Integer getPricingToolByQuoteLineItemRecords(Id recordId, List<String> pricingToolSet) {
        String congaTools =  pricingToolSet.isEmpty() ? '' : ' AND Pricing_Tool__c NOT IN :pricingToolSet';
        return Database.Query(
            'SELECT Pricing_Tool__c FROM Quote_Line_Item__c WHERE Quote__c = :recordId' + congaTools + ' GROUP BY Pricing_Tool__c').size();
    }

    public List<Quote_Line_Item__c> selectedQuoteLineItemList(String condition , Set<String> fieldSet) {
        return (List<Quote_Line_Item__c>) Database.query(
           newQueryFactory(true)
           .selectFields(fieldSet)
           .setCondition(condition)
           .toSOQL());
    }
    
    public List<Quote_Line_Item__c> getQuoteLineItemByQuoteId(Set<Id> quoteIds, Set<String> fieldSet) {
        return (List<Quote_Line_Item__c>) Database.query(
           newQueryFactory(true)
           .selectFields(fieldSet)
           .setCondition('Quote__c IN: quoteIds')
           .toSOQL());
   }
}