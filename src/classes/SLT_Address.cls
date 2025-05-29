/**
* Selector class for Address
*/
public class SLT_Address extends fflib_SObjectSelector{
    /**
    constructor
    */
    public SLT_Address()
    {
    }
  
    /**
    param constructor
    */
    public SLT_Address(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
    
    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Address__c.Id,
            Address__c.Name,
            Address__c.Street__c,
            Address__c.City__c,
            Address__c.Country__c,
            Address__c.PostalCode__c,
            Address__c.SAP_Reference__c
        };
    }
    
    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){
        return Address__c.sObjectType;
    }
    
    /**
    * This method used to get Address by Id
    * @return  List<Address__c>
    * @param Set<Id>
    */
    public List<Address__c> selectById(Set<Id> idSet){
        return (List<Address__c>) selectSObjectsById(idSet);
    }

    /**
     * This method used to get Address by Id
     * @return  Map<Id, Address>
     */
    public Map<Id, Address__c> selectByAddressId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Address__c>((List<Address__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method used to get SAP Validated Address 
     * 
     */
    public List<Address__c> getSAPValidatedAddress(String oppAccIdd , Set<String> fieldSet) {
        return (List<Address__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Account__r.id=:oppAccIdd AND  MDM_Validation_Status__c = \'Validated\' AND SAP_Reference__c != null').toSOQL());
    }
    
    /**
     * This Method to return address with their validated SAP Contact
     * @params Set<String> addFieldSet
     * @params String addCondition
     * @params Set<String> sapConFieldSet
     * @params String sapConCondition
     * @return List<Address__c>
     */
    public List<Address__c> getAddressWithValidateSapContact(Set<String> addFieldSet, String addCondition, Set<String> sapConFieldSet, String sapConCondition){
        fflib_QueryFactory addressQueryFactory = newQueryFactory(true);
        new SLT_SAP_Contact().addQueryFactorySubselect(addressQueryFactory, CON_CRM.ADDRESS_SAPCONTACT_RELATIONSHIP, true).selectFields(sapConFieldSet).setCondition(sapConCondition);
        String queryString = addressQueryFactory.selectFields(addFieldSet).setCondition(addCondition).toSOQL();
        return (List<Address__c>) Database.query(queryString);
    }
    
    /**
     * Method to query address by condition by given fieldset
     * @params Set<String> fieldSet
     * @params  String condition
     * @return List<Address__c>
     */
    public Map<Id,Address__c> getAddressByConditions(Set<String> fieldSet, String condition){
        return new Map<Id, Address__c>((List<Address__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING).toSOQL()));
    }
}