/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Price List object
 */
public class SLT_PriceList extends fflib_SObjectSelector {
    
    static final Boolean INCLUDE_FIELDSETS  = false;
    static final Boolean ENFORCE_CRUD       = false;
    static final Boolean ENFORCE_FLS        = false;
    static final Boolean SORT_SELECT_FIELDS = true;
    
    public SLT_PriceList() {
        super(INCLUDE_FIELDSETS,ENFORCE_CRUD,ENFORCE_FLS,SORT_SELECT_FIELDS);  
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Apttus_Config2__PriceList__c.id, Apttus_Config2__PriceList__c.Name
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Apttus_Config2__PriceList__c.SObjectType;
    }

    /**
    * This method used to get PriceList by Id
    * @return  List<Apttus_Config2__PriceList__c>
    */
    public List<Apttus_Config2__PriceList__c> selectById(Set<Id> idSet) {
        return (List<Apttus_Config2__PriceList__c>) selectSObjectsById(idSet);
    }

    public List<Apttus_Config2__PriceList__c> selectByCurrency(Set<String> currencyCodes) {
        return (List<Apttus_Config2__PriceList__c>) Database.query(newQueryFactory(true)
            .setCondition('CurrencyIsoCode in :currencyCodes')
            .toSOQL());
    }
    
    public List<Apttus_Config2__PriceList__c> selectByName(String name, Set<String> fieldSet) {
        return (List<Apttus_Config2__PriceList__c>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet).setCondition('Name =:name').toSOQL());
    }

    // Retrieve list of price lists based on set of names and active as true
    public List<Apttus_Config2__PriceList__c> selectByNames(Set<String> names, Set<String> fieldSet) {
        return (List<Apttus_Config2__PriceList__c>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet).setCondition('Name IN:names AND Apttus_Config2__Active__c = true').toSOQL());
    }
}