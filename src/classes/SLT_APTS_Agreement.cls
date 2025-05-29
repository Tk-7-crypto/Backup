/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OpportunitySplit
 */
public class SLT_APTS_Agreement extends fflib_SObjectSelector {
    
    public String orderByField = 'CreatedDate';
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_APTS_Agreement() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_APTS_Agreement(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    /**
      */
    public SLT_APTS_Agreement(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
    
    /**
     * Method to override OrderBy
     */
     
    public override String getOrderBy() {
        return orderByField;
    } 
    
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
        return Apttus__APTS_Agreement__c.sObjectType;
    }
    
    /**
     * This method used to get Agreements by Id
     * @return  Map<Id, Apttus__APTS_Agreement__c>
     */
    public Map<Id, Apttus__APTS_Agreement__c> getAgreementsById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Apttus__APTS_Agreement__c>((List<Apttus__APTS_Agreement__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method used to get Agreements by with Project, Resource Requests and Assigments
     * @params  Set<Id> agreementIdset
     * @params  Set<String> agreementFieldSet
     * @params  Set<String> projectFieldSet
     * @params  Set<String> resRequestFieldSet
     * @params  Set<String> assignmentFieldSet
     * @return  Map<Id, Apttus__APTS_Agreement__c>

    public Map<Id, Apttus__APTS_Agreement__c> selectByIdWithAgreementAndProjsResReqsAssignments(Set<ID> agreementIdset, Set<String> agreementFieldSet, Set<String> projectFieldSet, 
                                                                                    Set<String> resRequestFieldSet, Set<String> assignmentFieldSet) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
        new SLT_Project(false,false).addQueryFactorySubselect(agreementQueryFactory, CON_OWF.AGREEMENT_PROJECTS, true).selectFields(projectFieldSet);
        new SLT_Resource_Request(false,false).addQueryFactorySubselect(agreementQueryFactory, CON_OWF.AGREEMENT_RESOURCE_REQUESTS, true).selectFields(resRequestFieldSet);
        new SLT_Assignment(false,false).addQueryFactorySubselect(agreementQueryFactory, CON_OWF.AGREEMENT_ASSIGNMENTS, true).selectFields(assignmentFieldSet);
        String queryString = agreementQueryFactory.selectFields(agreementFieldSet).setCondition('Id in :agreementIdset').toSOQL();
        return new Map<Id, Apttus__APTS_Agreement__c>((List<Apttus__APTS_Agreement__c>) Database.query(queryString));
    }
     */
    /**
     * This method used to get Agreements by with Resource Requests
     * @params  Set<Id> agreementIdset
     * @params  Set<String> agreementFieldSet
     * @params  Set<String> resRequestFieldSet
     * @return  Map<Id, Apttus__APTS_Agreement__c>

    public Map<Id, Apttus__APTS_Agreement__c> selectByIdWithAgreementResourceRequests(Set<ID> agreementIdset, Set<String> agreementFieldSet, Set<String> resRequestFieldSet) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
        new SLT_Resource_Request(false,false).addQueryFactorySubselect(agreementQueryFactory, CON_OWF.AGREEMENT_RESOURCE_REQUESTS, true).selectFields(resRequestFieldSet);
        String queryString = agreementQueryFactory.selectFields(agreementFieldSet).setCondition('Id in :agreementIdset').toSOQL();
        return new Map<Id, Apttus__APTS_Agreement__c>((List<Apttus__APTS_Agreement__c>) Database.query(queryString));
    }
     */
    /**
     * This method used to get Agreements and related ResourceRequests
     * @return  Map<Id, Opportunity>

    public Map<Id, Apttus__APTS_Agreement__c> getAgreementAndResReqsByOppId(Set<ID> sObjectIdSet, Set<String> fieldSet, Set<String> resReqFieldSet, String agrCond, String resReqCond) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
        new SLT_Resource_Request(false,false).addQueryFactorySubselect(agreementQueryFactory, CON_OWF.AGREEMENT_RESOURCE_REQUESTS, true).selectFields(resReqFieldSet).setCondition(resReqCond);
        String queryString = agreementQueryFactory.selectFields(fieldSet).setCondition(agrCond).toSOQL();
        return new Map<Id, Apttus__APTS_Agreement__c>((List<Apttus__APTS_Agreement__c>) Database.query(queryString));
    }
     */
    /**
     * This method used to get Agreement by with Opportunity
     * @params  Set<Id> agreementIdset
     * @params  Set<String> agreementFieldSet
     * @return  Map<Id, Apttus__APTS_Agreement__c>
     */
    public Map<Id, Apttus__APTS_Agreement__c> getAgreementByOppID(Set<ID> opportunityIdset, Set<String> agreementFieldSet) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        String queryString = agreementQueryFactory.selectFields(agreementFieldSet).setCondition('Apttus__Related_Opportunity__c in :opportunityIdset').toSOQL();
        system.debug('Query-->' + queryString);
        return new Map<Id, Apttus__APTS_Agreement__c>((List<Apttus__APTS_Agreement__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get Agreement by with Opportunity
     * @params  Set<Id> agreementIdset
     * @params  Set<String> agreementFieldSet
     * @return  Map<Id, Apttus__APTS_Agreement__c>
     */
    public Map<Id, Apttus__APTS_Agreement__c> getAgreementByOppIDSortByCreatedDateDesc(Set<ID> opportunityIdset, Set<String> agreementFieldSet) {
        orderByField = 'CreatedDate DESC';
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        String queryString = agreementQueryFactory.selectFields(agreementFieldSet).setCondition('Apttus__Related_Opportunity__c in :opportunityIdset').toSOQL();
        system.debug('Query-->' + queryString);
        return new Map<Id, Apttus__APTS_Agreement__c>((List<Apttus__APTS_Agreement__c>) Database.query(queryString));
    }
	
    public Map<Id, Apttus__APTS_Agreement__c> getBudgetsRelatedToOpportunity(Set<Id> opportunityIdSet, Set<String> agreementFieldSet, String conditon) {
        orderByField = 'CreatedDate ASC';
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        String queryString = agreementQueryFactory.selectFields(agreementFieldSet).setCondition(conditon).toSOQL();
        return new Map<Id, Apttus__APTS_Agreement__c>((List<Apttus__APTS_Agreement__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get Agreement by  Opportunity Id order by createdDate Desc
     * @params  Set<Id> oppIdSet
     * @params  Set<String> agreementFieldSet
     * @return  List<Apttus__APTS_Agreement__c>
     */
    public List<Apttus__APTS_Agreement__c> getAgreementsByOppIds(Set<ID> oppIdSet, Set<String> agreementFieldSet, Set<String> LOB1Set, Set<String> LOB2Set) {
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        queryFactory.selectFields(agreementFieldSet);
        queryFactory.setCondition('Apttus__Related_Opportunity__c IN :oppIdSet AND ( ( RecordType.DeveloperName = \'PSA\' AND Apttus__Related_Opportunity__r.Line_of_Business__c IN :LOB1Set AND Apttus__Subtype__c IN (\'Work Order\', \'Change Order\') ) OR ( RecordType.DeveloperName = \'RWLP\' AND Apttus__Related_Opportunity__r.Line_of_Business__c IN :LOB2Set AND  Apttus__Subtype__c IN ( \'Change Order\', \'ATP\', \'SUWO\', \'Amendment\') ))');
        queryFactory.setOrdering(new fflib_QueryFactory.Ordering('Apttus__APTS_Agreement__c', 'CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING));
        system.debug(queryFactory.toSOQL());
        return (List<Apttus__APTS_Agreement__c>) Database.query(queryFactory.toSOQL());
    }
    
}