/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for ProposalLineItems
 */public class SLT_ProposalLineItems extends fflib_SObjectSelector{

     /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_ProposalLineItems() {
        super(false, true, false);
    }
     
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_ProposalLineItems(Boolean enforceFLS) {
        super(false, true, enforceFLS);
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
        return Apttus_Proposal__Proposal_Line_Item__c.sObjectType;
    }
          
    /**
     * This method used to get AgreementLineItem Records by quote Id
     * @return  List<Apttus_Proposal__Proposal_Line_Item__c>
     */
    public List<Apttus_Proposal__Proposal_Line_Item__c> selectByQuoteId(Id quoteID) {
        return [Select id from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c = : quoteID];
    }
     
    /**
     * This method used to get LineItem Records by proposal Id and Unit Names
     * @return  List<Apttus_Proposal__Proposal_Line_Item__c>
     */
    public List<Apttus_Proposal__Proposal_Line_Item__c> selectByProposalIdsAndUnitNames(Set<Id> parentIdsSet, Set<String> fieldSet, Set<String> onsiteUnits, Set<String> remoteUnits, Set<String> pharmacyUnits, String constant_CRA) {
        return (List<Apttus_Proposal__Proposal_Line_Item__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(' (Unit_Name__c IN : onsiteUnits OR Unit_Name__c IN : remoteUnits OR Unit_Name__c IN : pharmacyUnits) AND Role__c = :constant_CRA AND Apttus_Proposal__Proposal__c IN :parentIdsSet ').toSOQL());
    }
    
    /**
     * This method used to get LineItem Records by proposal Id and Unit Name Site Management
     * @return  List<Apttus_Proposal__Proposal_Line_Item__c>
     */
    public List<Apttus_Proposal__Proposal_Line_Item__c> selectByProposalIdsAndUnitName(Set<Id> parentIdsSet, Set<String> fieldSet) {
        return (List<Apttus_Proposal__Proposal_Line_Item__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(' (Unit_Name__c like \'Site Management -%\' OR Unit_Name__c like \'%Site Management\' OR Unit_Name__c = \'Remote EDC Review\') AND Apttus_Proposal__Proposal__c IN :parentIdsSet ').toSOQL());
    }
     
    /**
     * This method used to get LineItem Records by proposal Id and Phases
     * @return  List<Apttus_Proposal__Proposal_Line_Item__c>
     */
    public List<Apttus_Proposal__Proposal_Line_Item__c> selectByProposalIdsAndPhases(Set<Id> parentIdsSet, Set<String> fieldSet) {
        return (List<Apttus_Proposal__Proposal_Line_Item__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(' (Closeout_Phase__c = true OR Conduct_Phase__c = true OR Startup_Phase__c = true) AND Apttus_Proposal__Proposal__c IN :parentIdsSet ').toSOQL());
    }
     
    /**
    * This method used to get LineItem Records by proposal Id and IQVIA Type
    * @return  List<Apttus_Proposal__Proposal_Line_Item__c>
    */
    public List<Apttus_Proposal__Proposal_Line_Item__c> selectByProposalIdsAndIQVIAType(Set<ID> parentIdsSet, Set<String> fieldSet, String IQVIAType) {
        return (List<Apttus_Proposal__Proposal_Line_Item__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Apttus_Proposal__Proposal__c in :parentIdsSet AND  IQVIA_Line_Type__c = :IQVIAType ').toSOQL());
    }
    
    /**
     * This method used to get LineItem Records by proposal Id and Unit Codes
     * @return  List<Apttus_Proposal__Proposal_Line_Item__c>
     */
    public List<Apttus_Proposal__Proposal_Line_Item__c> selectByProposalIdsAndUnitCodes(Set<Id> parentIdsSet, Set<String> fieldSet, Set<String> unitCodes, String condition) {
        return (List<Apttus_Proposal__Proposal_Line_Item__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
    
    /**
     * This method used to get LineItem Counts by proposal Id
     * @return  List<AggregateResult>
     */
    public List<AggregateResult> getLineItemCountByBudgetId(Set<ID> budgetIdSet) 
    {
        return [SELECT Apttus_Proposal__Proposal__c, COUNT(Id) lineItemCount From Apttus_Proposal__Proposal_Line_Item__c 
            	WHERE Apttus_Proposal__Proposal__c IN :budgetIdSet
            	GROUP BY Apttus_Proposal__Proposal__c];
    }
	/**
     * This method used to get LineItem Records with Apttus_QPConfig__ProductAttributeValues__c by proposal Id 
     * @return  List<Apttus_Proposal__Proposal_Line_Item__c>
     */
    public List<Apttus_Proposal__Proposal_Line_Item__c> getProposalLineItemsWithAttributesByQuoteId(Set<Id> parentIdsSet, Set<String> fieldSet, Set<String> optionCodes, Set<String> bundleCodes) {
         fflib_QueryFactory proposalLineItemQF = newQueryFactory()
             .selectFields(fieldSet)
             .setCondition('Apttus_Proposal__Proposal__c IN :parentIdsSet AND (Apttus_QPConfig__OptionId__r.ProductCode IN :optionCodes OR (Apttus_Proposal__Product__r.ProductCode IN :bundleCodes AND Apttus_QPConfig__OptionId__c = null))'); 
         return Database.query(proposalLineItemQF.toSOQL()); 
     }
     /**
     * This method used to get LineItem Records by proposal Id 
     * @return  List<Apttus_Proposal__Proposal_Line_Item__c>
     */
    public List<Apttus_Proposal__Proposal_Line_Item__c> getProposalLineItemsByQuoteId(Set<Id> parentIdsSet, Set<String> fieldSet) {
        return (List<Apttus_Proposal__Proposal_Line_Item__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Apttus_Proposal__Proposal__c IN :parentIdsSet AND (Apttus_QPConfig__LineType__c = \'' + CON_CPQ.OPTION + '\' OR (Apttus_QPConfig__HasOptions__c = false  AND Apttus_QPConfig__ParentBundleNumber__c = null))').toSOQL());
    }

    public List<Apttus_Proposal__Proposal_Line_Item__c> getPLI(Set<String> quoteLineItemFieldSet, Id proposalId) {
        return(List<Apttus_Proposal__Proposal_Line_Item__c>)Database.query(newQueryFactory(true).selectFields(quoteLineItemFieldSet).setCondition('Apttus_Proposal__Proposal__c =: proposalId').setOrdering('Apttus_QPConfig__LineNumber__c', fflib_QueryFactory.SortOrder.ASCENDING, false).toSOQL());
    }
    public Apttus_Proposal__Proposal_Line_Item__c getPLIByCreatedDateDescending(Set<String> quoteLineItemFieldSet, Id proposalId) {
        return(Apttus_Proposal__Proposal_Line_Item__c)Database.query(newQueryFactory(true).selectFields(quoteLineItemFieldSet).setCondition('Apttus_Proposal__Proposal__c =: proposalId').setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true).setLimit(1).toSOQL());
    }
    
}
