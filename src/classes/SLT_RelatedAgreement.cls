/**
* This is a selector class for Apttus__APTS_Related_Agreement__c
*/
public class SLT_RelatedAgreement extends fflib_SObjectSelector {

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_RelatedAgreement() {
        super(false, true, true);
    }

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_RelatedAgreement(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
    * This method used to set up type of sobject.
    */
    public Schema.SObjectType getSObjectType() {
        return Apttus__APTS_Related_Agreement__c.sObjectType;
    }

    /**
    * This method gives the list of SObjectFields
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Apttus__APTS_Related_Agreement__c.Id, Apttus__APTS_Related_Agreement__c.Apttus__APTS_Contract_To__c, Apttus__APTS_Related_Agreement__c.Apttus__APTS_Contract_From__c
        };
    }     
    
    /**
    * This method is used to get related agreements by condition
    * @param Set<Id> idSet
    * @param Set<String> fieldSet
    * @param String condition
    * @return List<Apttus__APTS_Related_Agreement__c>
    */
    public List<Apttus__APTS_Related_Agreement__c> getRelatedAgreementsByCondition(Set<Id> idSet, Set<String> fieldSet, String condition) {      
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fieldSet);
        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return (List<Apttus__APTS_Related_Agreement__c>) Database.query(factory.toSOQL());        
    }
}