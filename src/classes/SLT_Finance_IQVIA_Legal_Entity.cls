/**
* Selector class for Finance IQVIA Legal Entity object 
*/
public class SLT_Finance_IQVIA_Legal_Entity extends fflib_SObjectSelector {
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Finance_IQVIA_Legal_Entity() {
        super(false, true, true);
    }
    
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Finance_IQVIA_Legal_Entity(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }
    
    /**
    * This method used to set up type of sobject.
    */
    public Schema.SObjectType getSObjectType() {
        return Finance_IQVIA_Legal_Entity__c.sObjectType;
    }
    
    /**
    * overriding getOrderBy
    */    
    public override String getOrderBy() {
        return 'Name ASC';
    }
    
    /**
    * This method gives the list of SObjectField of Finance_IQVIA_Legal_Entity__c object.
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Finance_IQVIA_Legal_Entity__c.Id,
            Finance_IQVIA_Legal_Entity__c.Name,
            Finance_IQVIA_Legal_Entity__c.Legacy_Entity_Code__c,
            Finance_IQVIA_Legal_Entity__c.Address_Line_1__c,
            Finance_IQVIA_Legal_Entity__c.Country_Description__c,
            Finance_IQVIA_Legal_Entity__c.Effective_Status__c,
            Finance_IQVIA_Legal_Entity__c.Incorporation__c,
            Finance_IQVIA_Legal_Entity__c.CurrencyIsoCode 
        };
    }

    /** 
    * This method used to get Finance_IQVIA_Legal_Entity__c by Name (To be deleted later)
    * @param List<String> nameSet
    * @param Set<String> fieldSet
    * @param Set<Id> recordTypeIDs
    * @return  List<Finance_IQVIA_Legal_Entity__c>
    */
    public List<Finance_IQVIA_Legal_Entity__c> getFinanceIQVIALegalEntityDetailsByName(Set<String> nameSet, Set<String> fieldSet, Set<Id> recordTypeIDs){
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        return (List<Finance_IQVIA_Legal_Entity__c>) Database.query(queryFactory.selectFields(fieldSet)
            .setCondition('Name IN: nameSet AND RecordTypeId IN: recordTypeIDs').toSOQL());
    }

    /**
    * This method is used to get Finance_IQVIA_Legal_Entity__c by Legacy code
    * @param Set<String> codeSet
    * @param Set<String> fieldSet
    * @param Set<Id> recordTypeIDs
    * @return  List<Finance_IQVIA_Legal_Entity__c>
    */
    public List<Finance_IQVIA_Legal_Entity__c> getFinanceIQVIALegalEntityDetailsByCode(Set<String> codeSet, Set<String> fieldSet, Set<Id> recordTypeIDs){
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        return (List<Finance_IQVIA_Legal_Entity__c>) Database.query(queryFactory.selectFields(fieldSet)
            .setCondition('Legacy_Entity_Code__c IN: codeSet AND RecordTypeId IN: recordTypeIDs').toSOQL());
    }

    /**
     * This method is used to get Finance_IQVIA_Legal_Entity__c by Id.
     * @param Set<String> parentFieldSet
     * @param Set<String> childFieldSet
     * @param String parentCondition
     * @param String childCondition
     * @param Set<Id> recordTypeIDs
     * @param Set<String> therapyArea
     */
    public List<Finance_IQVIA_Legal_Entity__c> getFinanceIQVIALegalEntityDetails(Set<Id> ids, Set<String> parentFieldSet, Set<String> childFieldSet, String parentCondition, String childCondition, Set<Id> recordTypeIDs, Set<String> therapyArea) { 
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        new SLT_Finance_IQVIA_Legal_Entity_Extension().addQueryFactorySubselect(queryFactory, 'Finance_Legal_Entity_Extensions__r').selectFields(childFieldSet).setCondition(childCondition)
        .setOrdering('Therapy_Area__c', fflib_QueryFactory.SortOrder.ASCENDING, true);
        queryFactory.selectFields(parentFieldSet);
        if(String.isNotBlank(parentCondition)) {
            queryFactory.setCondition(parentCondition);
        }
        return (List<Finance_IQVIA_Legal_Entity__c>) Database.query(queryFactory.toSOQL());
    }
}