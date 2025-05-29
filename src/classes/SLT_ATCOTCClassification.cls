/*
* Version       : 1.0
* Description   : This Apex class is selector layer for ATCOTCClasssification
*/
public class SLT_ATCOTCClassification extends fflib_SObjectSelector {
    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ATC_OTC_Classification__c.Id,
            ATC_OTC_Classification__c.Hierarchy1_Code__c,
            ATC_OTC_Classification__c.Hierarchy1_Name__c,
            ATC_OTC_Classification__c.Hierarchy2_Code__c,
            ATC_OTC_Classification__c.Hierarchy2_Name__c
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return ATC_OTC_Classification__c.SObjectType;
    }

    /**
    * This method used to get Line Item by Id
    * @return  List<ATC_OTC_Classification__c>
    */
    public List<ATC_OTC_Classification__c> selectById(Set<Id> idSet) {
        return (List<ATC_OTC_Classification__c>) selectSObjectsById(idSet);
    }
    
    public List<ATC_OTC_Classification__c> selectedATCOTCrecoreds(String productMarketType, String eligibleCountry, String atcOTC, String subProduct, Set<String> fieldSet, String standardType) {
        return (List<ATC_OTC_Classification__c>) Database.query(
            newQueryFactory(true)
            .selectFields(fieldSet)
            .setCondition('Market_Type__c=: productMarketType AND Country_Code__c =: eligibleCountry AND Type__c =: atcOTC AND Sub_Product__c =: subProduct AND Standard_Type__c =: standardType')
            .addOrdering('Hierarchy2_Name__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL());
    }
}