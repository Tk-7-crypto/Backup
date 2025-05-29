/**
* Selector class for Agreement_Contacts__c object
*/
public class SLT_Agreement_Contacts extends fflib_SObjectSelector {

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Agreement_Contacts() {
        super(false, true, true);
    }

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Agreement_Contacts(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
    * This method used to set up type of sobject.
    */
    public Schema.SObjectType getSObjectType() {
        return Agreement_Contacts__c.sObjectType;
    }

    /**
    * This method gives the list of SObjectField of SCM Master Question object.
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Agreement_Contacts__c.Id, Agreement_Contacts__c.Role__c, Agreement_Contacts__c.Contact__c, 
            Agreement_Contacts__c.Agreement__c, Agreement_Contacts__c.User__c, Agreement_Contacts__c.Type__c
        };
    }

    /**
     * getAgreementContactListByAgreementId method gets the detail of Agreement_Contacts__c object on the basis of agreement id.
     * @param  agreementIds is the set of Ids of agreement records.
     * @return             List<Agreement_Contacts__c> 
     */
    public List<Agreement_Contacts__c> getAgreementContactListByAgreementId(Set<Id> agreementIds, Set<String> fieldSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        new SLT_Contact().configureQueryFactoryFields(queryFactory, Agreement_Contacts__c.Contact__c.getDescribe().getRelationShipName());
        new SLT_User().configureQueryFactoryFields(queryFactory, Agreement_Contacts__c.User__c.getDescribe().getRelationShipName());
        if (!fieldSet.isEmpty()) {
            queryFactory.selectFields(fieldSet);
        }
        queryFactory.setCondition('Agreement__c IN :agreementIds AND (Docusign_Role__c != null OR Docusign_Role__c != \'\')');
        return (List<Agreement_Contacts__c>) Database.query(queryFactory.toSOQL());
    }

    /**
    * getAgreementAccountContactListByAgreementId method gets the detail of Agreement_Contacts__c object on the basis of agreement id.
    * @param  agreementIds is the set of Ids of agreement records.
    * @param  fieldSet is the set of Ids of fields.
    * @param String firstParam
    * @return  List<Agreement_Contacts__c> 
    */
    public List<Agreement_Contacts__c> getAgreementContactListByAgreementId(Set<Id> agreementIds, 
        Set<String> fieldSet, String condition, String firstParam) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        new SLT_Contact().configureQueryFactoryFields(queryFactory, Agreement_Contacts__c.Account_Contact__c.getDescribe().getRelationShipName());
        if (!fieldSet.isEmpty()) {
            queryFactory.selectFields(fieldSet);
        }
        if(!String.isBlank(condition)) {
            queryFactory.setCondition(condition);
        }
        return (List<Agreement_Contacts__c>) Database.query(queryFactory.toSOQL());
    } 
    
    /**
    * getAgreementAccountContactListByAgreementId method gets the detail of Agreement_Contacts__c object on the basis of agreement id.
    * @param  agreementIds is the set of Ids of agreement records.
    * @param  fieldSet is the set of Ids of fields.
    * @param  String condition 
    * @param  String firstParam
    * @param  String orderField
    * @param  String sortOrder
    * @return List<Agreement_Contacts__c> 
    */
    public List<Agreement_Contacts__c> getAgreementContactListByAgreementId(Set<Id> agreementIds, 
        Set<String> fieldSet, String condition, String firstParam, String orderField, String sortOrder) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        new SLT_Contact().configureQueryFactoryFields(queryFactory, Agreement_Contacts__c.Contact__c.getDescribe().getRelationShipName());
        if (!fieldSet.isEmpty()) {
            queryFactory.selectFields(fieldSet);
        }
        if(!String.isBlank(condition)) {
            queryFactory.setCondition(condition);
        }
        if(sortOrder == 'ASC'){
            queryFactory.setOrdering(orderField, fflib_QueryFactory.SortOrder.ASCENDING);
            queryFactory.addOrdering('Contact__r.FirstName', fflib_QueryFactory.SortOrder.ASCENDING);
        }
        else if(sortOrder == 'DESC'){
            queryFactory.setOrdering(orderField, fflib_QueryFactory.SortOrder.DESCENDING);
            queryFactory.addOrdering('Contact__r.FirstName', fflib_QueryFactory.SortOrder.ASCENDING);
        }
        return (List<Agreement_Contacts__c>) Database.query(queryFactory.toSOQL());
    } 
}