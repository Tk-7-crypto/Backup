/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Line Item
 */
public class SLT_LineItem extends fflib_SObjectSelector {

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Apttus_Config2__LineItem__c.Id,
            Apttus_Config2__LineItem__c.Name,
            Apttus_Config2__LineItem__c.Apttus_Config2__ProductId__c,
            Apttus_Config2__LineItem__c.Apttus_Config2__OptionId__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Apttus_Config2__LineItem__c.SObjectType;
    }

    /**
    * This method used to get Line Item by Id
    * @return  List<Apttus_Config2__LineItem__c>
    */
    public List<Apttus_Config2__LineItem__c> selectById(Set<Id> idSet) {
        return (List<Apttus_Config2__LineItem__c>) selectSObjectsById(idSet);
    }

    /**
     * This method used to get LineItems by Product Configuration Id
     * @return List<Apttus_Config2__LineItem__c>
     */
    public List<Apttus_Config2__LineItem__c> selectByProductConfigId(Set<Id> prodConfigIdSet, Set<String> fieldSet) {
        return (List<Apttus_Config2__LineItem__c>) Database.query(
            newQueryFactory(true)
            .selectFields(fieldSet)
            .setCondition('Apttus_Config2__ConfigurationId__c IN :prodConfigIdSet')
            .toSOQL());
    }
	
    /**
     * This method used to get LineItems by Product Configuration Id
     * @return Apttus_Config2__LineItem__c
     */
    public Apttus_Config2__LineItem__c selectByLineItemID(Id lineItemId, Set<String> fieldSet) {
        return (Apttus_Config2__LineItem__c) Database.query(
            newQueryFactory(true)
            .selectFields(fieldSet)
            .setCondition('Id =: lineItemId')
            .toSOQL());
    }
    public List<Apttus_Config2__LineItem__c> getLineItems(Set<String> fieldSet) {
        return (List<Apttus_Config2__LineItem__c>) Database.query(
            newQueryFactory(true)
            .selectFields(fieldSet)
            .setLimit(100)
            .toSOQL());
    }
    public List<Apttus_Config2__LineItem__c> getLineItemsWithAttributesByQuoteId(Set<Id> parentIdsSet, Set<String> fieldSet, Set<String> optionCodes, Set<String> bundleCodes) {
         fflib_QueryFactory LineItemQF = newQueryFactory()
             .selectFields(fieldSet)
             .setCondition('Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c IN :parentIdsSet AND (Apttus_Config2__OptionId__r.ProductCode IN :optionCodes OR (Apttus_Config2__ProductId__r.ProductCode IN :bundleCodes AND Apttus_Config2__OptionId__c = null))'); 
         return Database.query(LineItemQF.toSOQL()); 
    }
    public List<Apttus_Config2__LineItem__c> getCLIWithAttributesByQuoteId(Set<Id> parentIdsSet, Set<String> fieldSet, Set<String> optionSet, Set<String> bundleSet, Set<String> productSyncType) {
        String subCondition = '(Apttus_Config2__OptionId__r.ProductCode IN :optionSet OR Apttus_Config2__ProductId__r.ProductCode IN :bundleSet)';
        if (productSyncType.size() == 1) {
            subCondition = productSyncType.contains('Option')  ? ' Apttus_Config2__OptionId__r.ProductCode IN :optionSet' : ' Apttus_Config2__ProductId__r.ProductCode IN :bundleSet AND Apttus_Config2__OptionId__r.ProductCode = NULL';
        }
        fflib_QueryFactory LineItemQF = newQueryFactory()
             .selectFields(fieldSet)
             .setCondition('Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.IQVIA_Quote__c IN :parentIdsSet AND ' + subCondition); 
         return Database.query(LineItemQF.toSOQL()); 
    }

    public List<Apttus_Config2__LineItem__c> getLineItemsByProposalId(Set<Id> proposalIdSet, Set<String> fieldSet) {
        fflib_QueryFactory LineItemQF = newQueryFactory()
             .selectFields(fieldSet)
             .setCondition('Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c IN :proposalIdSet'); 
         return Database.query(LineItemQF.toSOQL()); 
    }

    public List<Apttus_Config2__LineItem__c> getLineItemsByCondtion(String condition, Set<String> fieldSet) {
        fflib_QueryFactory LineItemQF = newQueryFactory()
             .selectFields(fieldSet)
             .setCondition(condition); 
         return Database.query(LineItemQF.toSOQL()); 
    }
}
