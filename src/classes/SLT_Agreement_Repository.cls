/**
* Selector class for Agreement_Repository__c object
*/
public class SLT_Agreement_Repository extends fflib_SObjectSelector {
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Agreement_Repository() {
        super(false, true, true);
    }

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Agreement_Repository(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
    * This method used to set up type of sobject.
    */
    public Schema.SObjectType getSObjectType() {
        return Agreement_Repository__c.sObjectType;
    }

    /**
    * This method gives the list of SObjectField.
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Agreement_Repository__c.Id, Agreement_Repository__c.Name, Agreement_Repository__c.Account__c, 
            Agreement_Repository__c.IQVIA_Agreement__c, Agreement_Repository__c.Related_Opportunity__c, Agreement_Repository__c.AR_Number__c
        };
    }
    
    /**
     * This method used to get Agreement Repository by Ids and a condition
     * @param String condition
     * @param Set<Id> docIds
     * @return  List<Agreement_Repository__c>
     */
    public List<Agreement_Repository__c> getAgreementRepository(String condition, Set<Id> docIds) {
        fflib_QueryFactory factory = newQueryFactory(true);
        if(String.isNotBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    } 
    
    /**
     * This method used to get Agreement Repository by AR_Number__c.
     * @param String condition
     * @param Set<String> arNumber
     * @param Set<String> fieldset
     * @return List<Agreement_Repository__c>
     */
    public List<Agreement_Repository__c> getAgreementRepositoryByARNumbers(String condition, Set<String> arNumbers, Set<String> fieldSet) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fieldSet);
        if(String.isNotBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
}