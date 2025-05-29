public class SLT_Bid_History extends fflib_SObjectSelector{
   
   public String orderByField ='Bid_Number__c'; 
    
    public SLT_Bid_History(){
        super(false, true, true);
    }
    
    public SLT_Bid_History(Boolean enforceCRUD,Boolean enforceFLS){
        super(true, enforceCRUD, enforceFLS);
    }
    
     /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Bid_History(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    /**
     * Method to override OrderBy
     */
     
    public override String getOrderBy() {
        return orderByField;
    }
    
    /**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList(){

        return new List<Schema.SObjectField>();
    }
    
    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){

        return Bid_History__c.sObjectType;
    }
    
     /**
     * This method used to get Agreement by with Opportunity
     * @params  Set<Id> agreementIdset
     * @params  Set<String> agreementFieldSet
     * @return  Map<Id, Bid_History__c>
     */
    public Map<Id, Bid_History__c> getBidHistoriesByOppID(Set<ID> opportunityIdset, Set<String> agreementFieldSet) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        String queryString = agreementQueryFactory.selectFields(agreementFieldSet).setCondition('Bid_History_Related_Opportunity__c in :opportunityIdset').toSOQL();
        return new Map<Id, Bid_History__c>((List<Bid_History__c>) Database.query(queryString));
    }

    /**
     * This method used to get Bid Histories by Id
     * @return  Map<Id, Bid_History__c>
     */
    public Map<Id, Bid_History__c> getBidHistoriesById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Bid_History__c>((List<Bid_History__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }

    
    
    /**
     * This method used to get Agreement by with Opportunity
     * @params  Set<Id> agreementIdset
     * @params  Set<String> agreementFieldSet
     * @return  Map<Id, Bid_History__c>
     */
    public Map<Id, Bid_History__c> getAgreementByOppIDSortByCreatedDateDesc(Set<ID> opportunityIdset, Set<String> agreementFieldSet) {
        orderByField = 'CreatedDate DESC';
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        String queryString = agreementQueryFactory.selectFields(agreementFieldSet).setCondition('Bid_History_Related_Opportunity__c in :opportunityIdset').toSOQL();
        return new Map<Id, Bid_History__c>((List<Bid_History__c>) Database.query(queryString));
    }
    
    
    /**
     * This method used to get Agreements by with Project, Resource Requests and Assigments
     * @params  Set<Id> agreementIdset
     * @params  Set<String> agreementFieldSet
     * @params  Set<String> projectFieldSet
     * @params  Set<String> resRequestFieldSet
     * @params  Set<String> assignmentFieldSet
     * @return  Map<Id, Apttus__APTS_Agreement__c>
     */
    public Map<Id, Bid_History__c> selectByIdWithAgreementAndProjsResReqsAssignments(Set<ID> agreementIdset, Set<String> agreementFieldSet, Set<String> projectFieldSet, 
                                                                                    Set<String> resRequestFieldSet, Set<String> assignmentFieldSet) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
        new SLT_Project(false,false).addQueryFactorySubselect(agreementQueryFactory, CON_OWF.BID_HISTORY_PROJECTS, true).selectFields(projectFieldSet);
        new SLT_Resource_Request(false,false).addQueryFactorySubselect(agreementQueryFactory, CON_OWF.Bid_HISTORY_RESOURCE_REQUESTS, true).selectFields(resRequestFieldSet);
        new SLT_Assignment(false,false).addQueryFactorySubselect(agreementQueryFactory, CON_OWF.Bid_HISTORY_ASSIGNMENTS, true).selectFields(assignmentFieldSet);
        String queryString = agreementQueryFactory.selectFields(agreementFieldSet).setCondition('Id in :agreementIdset').toSOQL();
        return new Map<Id, Bid_History__c>((List<Bid_History__c>) Database.query(queryString));
    }
    
    
    
    
    /**
     * This method used to get Agreement by Id
     * @return  List<Apttus__APTS_Agreement__c>
     */
    public List<Bid_History__c> getBidHistoryFieldsById(Set<ID> idSet, Set<String> fieldSet) {
        return (List<Bid_History__c>) Database.query(
            									 newQueryFactory(true).
               									 selectFields(fieldSet).
               									 setCondition('Id in: idSet').
               									 toSOQL());
    }
    
    
     	public List<Bid_History__c> getBidHistoryByOpportunitesAll(Set<Id> oppIdset, Set<String> agreementFieldSet) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        String queryString = agreementQueryFactory.selectFields(agreementFieldSet).setCondition('Bid_History_Related_Opportunity__c in: oppIdset AND Bid_Due_Date__c >= TODAY').toSOQL();
        return ((List<Bid_History__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get Agreements and related ResourceRequests
     * @return  Map<Id, Opportunity>
     */
    public Map<Id, Bid_History__c> getAgreementAndResReqsByOppId(Set<ID> sObjectIdSet, Set<String> fieldSet, Set<String> resReqFieldSet, String agrCond, String resReqCond) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
        new SLT_Resource_Request(false,false).addQueryFactorySubselect(agreementQueryFactory, CON_OWF.Bid_HISTORY_RESOURCE_REQUESTS, true).selectFields(resReqFieldSet).setCondition(resReqCond);
        String queryString = agreementQueryFactory.selectFields(fieldSet).setCondition(agrCond).toSOQL();

        return new Map<Id, Bid_History__c>((List<Bid_History__c>) Database.query(queryString));
    }
    
    public List<Bid_History__c> getBidHistoriesByCondition(Set<String> fieldSet,String condition,Set<Id> sObjectIdSet){
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        String queryString = agreementQueryFactory.selectFields(fieldSet).setCondition(condition).toSOQL();
        return (List<Bid_History__c>) Database.query(queryString);
    }
    
    /*
    * This method is use to query agreement on the basis of id to get the required details
    *
    */
    public Bid_History__c getBidHistoryDetails(Id bidHistoryId, Set<String> fieldSet){
        return (Bid_History__c) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('ID = :bidHistoryId').toSOQL());
	}


    /*
    * This method is use to query latest clinical Bid on the basis of opportunity id and condition
    *
    */
    public Map<Id, Bid_History__c> getLatestClinicalBidOnOpportunity(Set<Id> opportunityIdSet, Set<String> clinicalBidFieldSet, String conditon) {
        orderByField = 'CreatedDate DESC';
        fflib_QueryFactory clinicalBidQueryFactory = newQueryFactory(true);
        String queryString = clinicalBidQueryFactory.selectFields(clinicalBidFieldSet).setCondition(conditon).setLimit(1).toSOQL();
        return new Map<Id, Bid_History__c>((List<Bid_History__c>) Database.query(queryString));
    }
    /*
    * This method is use to query clinical Bid on the basis of id to get the required details
    *
    */
    public Bid_History__c getClinicalBidDetails(Id clinicalBidId, Set<String> fieldSet){
        return (Bid_History__c) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('ID = :clinicalBidId').toSOQL());
    }
    
    public Bid_History__c getRecordById(String recId){
        return Database.query('SELECT Bid_History_Account__c, Regions__c, Therapy_Area__c,Indication__c, Intervention_Type__c,'+
                              ' Drug_Name__c, RFP_Ranking__c, Phase__c, Targeted_Countries__c, Line_of_Business__c, IQVIA_biotech__c, Opportunity_Account__c,'+
                              ' Is_there_a_Client_Bid_Grid__c,Full_Service__c, Bid_Number__c,Requested_Services__c, Bid_History_Related_Opportunity__r.Potential_Regions__c, '+
                              ' Bid_History_Related_Opportunity__r.Rare_Disease__c,Bid_History_Related_Opportunity__c, Bid_History_Related_Opportunity__r.InterventionType__c, '+
                              ' Bid_History_Related_Opportunity__r.AccountId FROM Bid_History__c '+
                              ' WHERE Id =: recId');
    }
    
    /*
    * This method is use to query All Clinical Bid on the basis of opportunity id
    *
    */
    public List<Bid_History__c> getAwardedClinicalBidOnOpportunity(Set<Id> opportunityId, Set<String> clinicalBidFieldSet) {
        Id clinicalBidRecordTypeId = CON_CRM.CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID;
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        String queryString = agreementQueryFactory.selectFields(clinicalBidFieldSet).setCondition('Bid_History_Related_Opportunity__c in: opportunityId AND RecordTypeId = :clinicalBidRecordTypeId').toSOQL();
        return (List<Bid_History__c>) Database.query(queryString);
    }
    public Map<Id, Bid_History__c> getAgreementAndResReqsByBidId(Set<ID> sObjectIdSet, Set<String> fieldSet, Set<String> resReqFieldSet, String bidHistoryCond, String resReqCond) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
        new SLT_Resource_Request(false,false).addQueryFactorySubselect(agreementQueryFactory, CON_OWF.Bid_HISTORY_RESOURCE_REQUESTS, true).selectFields(resReqFieldSet).setCondition(resReqCond);
        String queryString = agreementQueryFactory.selectFields(fieldSet).setCondition(bidHistoryCond).toSOQL();

        return new Map<Id, Bid_History__c>((List<Bid_History__c>) Database.query(queryString));
    }
    
    public List<Bid_History__c> getBidHistoryByOppOrderByField(Set<Id> sObjectIdSet, Set<String> bhrFieldSet, String condition,String orderField) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        String queryString = agreementQueryFactory.selectFields(bhrFieldSet).setCondition(condition).setOrdering(orderField, fflib_QueryFactory.SortOrder.DESCENDING, true).toSOQL();
        return ((List<Bid_History__c>) Database.query(queryString));
    }

    public List<Bid_History__c> getLatestBidHistory(Set<String> fieldSet, String condition){
        orderByField = 'CreatedDate DESC';
        return (List<Bid_History__c>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
    public List<Bid_History__c> getBidHistoryWithCollectionTools(Set<Id> bidIds){
        return [SELECT Id, Study_Number__c, (SELECT Id, Bid_history__c from Collection_Tools__r) from Bid_History__c WHERE Id IN :bidIds ];
    }

    public Map<Id, Bid_History__c> selectByIdWithBidsResReqsAssignments(Set<ID> agreementIdset, Set<String> agreementFieldSet, 
                                                                        Set<String> resRequestFieldSet,
                                                                        String resourceRequestCondition) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
        new SLT_Resource_Request(false,false).addQueryFactorySubselect(agreementQueryFactory, CON_OWF.Bid_HISTORY_RESOURCE_REQUESTS, true).selectFields(resRequestFieldSet).setCondition(resourceRequestCondition).setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING, true).setLimit(1);
        String queryString = agreementQueryFactory.selectFields(agreementFieldSet).setCondition('Id in :agreementIdset').toSOQL();
        return new Map<Id, Bid_History__c>((List<Bid_History__c>) Database.query(queryString));
                                                                        }


                                                                        
}