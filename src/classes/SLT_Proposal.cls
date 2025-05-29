/*
* Version       : 1.0
* Description   : This Apex class is selector layer for Quote
*/
public class SLT_Proposal extends fflib_SObjectSelector {
    
    public String orderByField = 'Name';

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Proposal() {
        super(false, true, true);
    }
    
    /**
    * constructor to initialise CRUD and FLS with a parameter for FLS.
    */
    public SLT_Proposal(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    /**
    */
    public SLT_Proposal(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
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
        return Apttus_Proposal__Proposal__c.sObjectType;
    }
    
    /**
     * Method to override OrderBy
     */
    public override String getOrderBy() {
        return orderByField;
    }
    
    public List<Apttus_Proposal__Proposal__c> getProposalsById(Set<Id> idSet, Set<String> fieldSet) {
        return new List<Apttus_Proposal__Proposal__c>((List<Apttus_Proposal__Proposal__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method is use to query Proposal on the basis of id to get the required details
     *
     */
    public Apttus_Proposal__Proposal__c getProposalDetails(Id proposalId, Set<String> fieldSet){
        return (Apttus_Proposal__Proposal__c) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Id = :proposalId').toSOQL());
    }
    
    public List<Apttus_Proposal__Proposal__c> getQuoteByParentClinicalBid(Set<Id> clinicalBidIds, Set<String> quoteFieldSet, String conditon) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(quoteFieldSet).setCondition(conditon).toSOQL();
        return new List<Apttus_Proposal__Proposal__c>((List<Apttus_Proposal__Proposal__c>) Database.query(queryString));
    }
    
    public List<Apttus_Proposal__Proposal__c> getQuoteByParentRelatedOpportunity(Set<ID> opportunityIdSet, Set<String> quoteFieldSet, String conditon) {
        orderByField = CON_CPQ.SCENARIO_NUMBER;
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(quoteFieldSet).setCondition(conditon).toSOQL();
        return new List<Apttus_Proposal__Proposal__c>((List<Apttus_Proposal__Proposal__c>) Database.query(queryString));
    }
    
    public List<Apttus_Proposal__Proposal__c> getQuoteByRelatedOpportunity(Set<ID> opportunityIdSet, Set<String> quoteFieldSet, String conditon) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(quoteFieldSet).setCondition(conditon).toSOQL();
        return new List<Apttus_Proposal__Proposal__c>((List<Apttus_Proposal__Proposal__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get quote by Id
     * @return  List<Apttus_Proposal__Proposal__c>
     */
    public List<Apttus_Proposal__Proposal__c> getProposalFieldsById(Set<ID> idSet, Set<String> fieldSet) {
        return (List<Apttus_Proposal__Proposal__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in: idSet').toSOQL());
    }
    
    public Map<Id, Apttus_Proposal__Proposal__c> selectByProposalIds(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Apttus_Proposal__Proposal__c>((List<Apttus_Proposal__Proposal__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    public Map<Id, Apttus_Proposal__Proposal__c> getQuoteMapByParentAgreementAndApprovalStage(Set<Id> agreementIdSet, Set<String> quoteFieldSet, String conditon, Set<String> approvalStageSet) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(quoteFieldSet).setCondition(conditon).toSOQL();
        return new Map<Id, Apttus_Proposal__Proposal__c>((List<Apttus_Proposal__Proposal__c>) Database.query(queryString));
    }

    public List<Apttus_Proposal__Proposal__c> getQuoteByParentRelatedOppIdOrIds(Set<Id> opportunityIdSet, Set<Id> proposalIds, Set<String> quoteFieldSet, String conditon) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(quoteFieldSet).setCondition(conditon).toSOQL();
        return new List<Apttus_Proposal__Proposal__c>((List<Apttus_Proposal__Proposal__c>) Database.query(queryString));
    }
    
    public List<Apttus_Proposal__Proposal__c> getProposalByParentClinicalBidAndBudgetType(Set<Id> clinicalBidIDs, 
        Set<String> budgetType, Set<String> fieldSet) {
        return (List<Apttus_Proposal__Proposal__c>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet).setCondition('Clinical_Bid__c IN :clinicalBidIDs ' +
            'AND Apttus_Proposal__Proposal_Category__c IN :budgetType').toSOQL());
    }
    
    public List<Apttus_Proposal__Proposal__c> getQuoteByOpportunityIdSet(Set<Id> opportunityIdSet) {
        return Database.query('SELECT Id, Clinical_Bid__c, RecordTypeId, Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Primary__c, Apttus_Proposal__Approval_Stage__c, ' + 
            'Apttus_Proposal__Opportunity__c, Apttus_Proposal__Proposal_Category__c, toLabel(Select_Pricing_Tool__c) FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c in :opportunityIdSet AND Apttus_Proposal__Opportunity__c != null AND RFP_Scenario__c != \'' + CON_CPQ.INACTIVE + '\'');
    }
    
    public List<Apttus_Proposal__Proposal__c> getQuoteWithLineItemsById(Set<Id> quoteIds, 
                                                                        Set<String> fieldSet, 
                                                                        Set<String> lineItemFields) {

        fflib_QueryFactory qf = new fflib_QueryFactory(Apttus_Proposal__Proposal__c.SObjectType)
            .selectFields(fieldSet)
            .setCondition('Id IN :quoteIds ');     
        qf.subselectQuery('Apttus_Proposal__R00N70000001yUfBEAU__r', true).selectFields(lineItemFields);
        return (List<Apttus_Proposal__Proposal__c>) Database.query(qf.toSOQL());
    }
	
	public List<Apttus_Proposal__Proposal__c> getRelatedProposalByRelatedOppIds(Set<String> proposalFieldSet, String conditionProposal, Set<Id> oppoSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        queryFactory.selectFields(proposalFieldSet);
        queryFactory.setCondition(conditionProposal);
        system.debug(queryFactory.toSOQL());
        return (List<Apttus_Proposal__Proposal__c>) Database.query(queryFactory.toSOQL());
    }
	
    public List<Apttus_Proposal__Proposal__c> getProposalByPricingToolIds(Set<String> pricingToolIds, String condition, Set<String> fieldSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        queryFactory.selectFields(fieldSet);
        queryFactory.setCondition(condition);
        return (List<Apttus_Proposal__Proposal__c>) Database.query(queryFactory.toSOQL());
    }

    public List<Apttus_Proposal__Proposal__c> getFinalizedProposals(Id recordId) {
        return (List<Apttus_Proposal__Proposal__c>) Database.query(
            'SELECT Id ' +
            'FROM Apttus_Proposal__Proposal__c ' +
            'WHERE Apttus_Proposal__Approval_Stage__c = \'Finalized\' ' +
            'AND IQVIA_Quote__c = :recordId'
        );
    }
    public List<Apttus_Proposal__Proposal__c> getProposalByQuoteIds(Set<String> fieldSet, String condition, Set<Id> quoteIdSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        queryFactory.selectFields(fieldSet);
        queryFactory.setCondition(condition);
        return (List<Apttus_Proposal__Proposal__c>) Database.query(queryFactory.toSOQL());
    }
}
