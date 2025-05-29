/*
* Version       : 1.0
* Description   : This Apex class is selector layer for Price Matrix Entry
*/
public class SLT_PriceMatrixEntry extends fflib_SObjectSelector {
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
        return Apttus_Config2__PriceMatrixEntry__c.SObjectType;
    }
    
    public List<Apttus_Config2__PriceMatrixEntry__c> getPriceMatrixEntriesByPriceList(Set<String> fieldSet, 
        String condition, String priceList) {
        return (List<Apttus_Config2__PriceMatrixEntry__c>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet).setCondition(condition).toSOQL());
    }
}