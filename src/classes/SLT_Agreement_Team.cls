/**
* Selector class for IQVIA_Agreement_Team__c object
*/
public class SLT_Agreement_Team extends fflib_SObjectSelector {
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Agreement_Team() {
        super(false, true, true);
    }

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Agreement_Team(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
    * This method used to set up type of sobject.
    */
    public Schema.SObjectType getSObjectType() {
        return IQVIA_Agreement_Team__c.sObjectType;
    }

    /**
    * This method gives the list of SObjectField of SCM Master Question object.
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            IQVIA_Agreement_Team__c.Id, IQVIA_Agreement_Team__c.Role__c, IQVIA_Agreement_Team__c.Contact__c, 
            IQVIA_Agreement_Team__c.Agreement__c, IQVIA_Agreement_Team__c.Type__c
        };
    }
    
    /**
    * getAgreementTeamListByAgreementId method gets the detail of Agreement_Contacts__c object on the basis of agreement id.
    * @param  agreementIds is the set of Ids of agreement records.
    * @param  fieldSet is the set of Ids of fields.
    * @param  String condition 
    * @param  String firstParam
    * @param  String orderField
    * @param  String sortOrder
    * @return List<IQVIA_Agreement_Team__c> 
    */
    public List<IQVIA_Agreement_Team__c> getAgreementTeamListByAgreementId(Set<Id> agreementIds, 
        Set<String> fieldSet, String condition, String firstParam, String orderField, String sortOrder) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        new SLT_Contact().configureQueryFactoryFields(queryFactory, IQVIA_Agreement_Team__c.Contact__c.getDescribe().getRelationShipName());
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
        return (List<IQVIA_Agreement_Team__c>) Database.query(queryFactory.toSOQL());
    }

    /**
    * This method is used to get agreement team details with based on condition
    * @param Set<String> firstParam
    * @param String condition
    * @param Set<String> fieldSet
    * @return List<IQVIA_Agreement_Team__c>
    */
    public List<IQVIA_Agreement_Team__c> getAgreementTeamByCondition(Set<String> firstParam, String condition, Set<String> fieldSet) {
        return Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    } 
}