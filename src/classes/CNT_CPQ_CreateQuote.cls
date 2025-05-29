public class CNT_CPQ_CreateQuote {
    
    /**
     *  get Opoortunity and Quote details from contract
     * @param Contract Id
     * @return clone budget and Opportunity details
     */
     
    @AuraEnabled
    public static AllQuoteDetails getRelatedQuotesDetails(Boolean isCreateQuoteFromOpportunity, Id contractId) {
        AllQuoteDetails allQuoteDetailsObj = new AllQuoteDetails();
        Set<ID> opportunityIdSet = new Set<Id>();
        if (isCreateQuoteFromOpportunity) {
            List<Opportunity> opportunityList = new SLT_Opportunity().selectById(new Set<Id> {contractId}, new Set<String> {CON_CPQ.Name, CON_CPQ.ACCOUNT_ID});
            for (Opportunity opp : opportunityList) {
                allQuoteDetailsObj.opportunityId = contractId;
                allQuoteDetailsObj.accountId = opp.AccountId;
                allQuoteDetailsObj.opportunityName = opp.Name;
                allQuoteDetailsObj.isOpportunityExist = true;
                opportunityIdSet.add(contractId);
            }
        } else {
            List<Contract> contractList = new SLT_Contract().selectByContractIdList(new Set<Id> {contractId}, new Set<String> {CON_CPQ.Opportunity_ID, CON_CPQ.STATUS, CON_CPQ.CONTRACT_OPPORTUNITY_NAME, CON_CPQ.ACCOUNT_ID, CON_CPQ.CONTRACT_OPPORTUNITY_NUMBER, CON_CPQ.CONTRACT_OPPORTUNITY_OWNER_NAME});
            allQuoteDetailsObj.isCreateQuoteFromGenericContract = contractList.size() > 0 ? true : false;
            for (Contract contract : contractList) {
                allQuoteDetailsObj.opportunityId = contract.Opportunity__c;
                allQuoteDetailsObj.opportunityName = contract.Opportunity__r.Name;
                allQuoteDetailsObj.accountId = contract.AccountId;
                allQuoteDetailsObj.isOpportunityExist = contract.Opportunity__c != null ? true : false;
                allQuoteDetailsObj.isStatusClosedForInternalPurposes = contract.Status == CON_CPQ.CLOSED_FOR_INTERNAL_PURPOSES;
                opportunityIdSet.add(contract.Opportunity__c);
            }
        }
        allQuoteDetailsObj.isPrimaryQuoteExist = false;
        allQuoteDetailsObj.isCancelled = false;
        Apttus_Proposal__Proposal__c newBudget = new Apttus_Proposal__Proposal__c();
        List<Apttus_Proposal__Proposal__c> proposalList = new SLT_Proposal().getQuoteByOpportunityIdSet(opportunityIdSet);
        allQuoteDetailsObj.isQuoteExist = proposalList.size() > 0 ? true : false;
        for (Apttus_Proposal__Proposal__c proposal : proposalList) {
            if (proposal.Apttus_Proposal__Primary__c == True) {
                allQuoteDetailsObj.isPrimaryQuoteExist = true;
                allQuoteDetailsObj.quoteId = proposal.Id;
                allQuoteDetailsObj.clinicalBidId = proposal.Clinical_Bid__c;
                allQuoteDetailsObj.quotePricingTool = proposal.Select_Pricing_Tool__c;
                if (proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.CANCELLED) {
                    allQuoteDetailsObj.isCancelled = true;
                }
            }
        }  
        if (allQuoteDetailsObj.quoteId != null){
            Set<String> fieldSet = new Set<String> {CON_CPQ.APPROVAL_STAGE, CON_CPQ.APPROVAL_STATUS,CON_CPQ.PROPOSAL_CATEGORY,
                CON_CPQ.RFP_SCENARIO,CON_CPQ.SCENARIO_DESCRIPTION,CON_CPQ.SCENARIO_NUMBER,CON_CPQ.BUDGET_ITERATION,CON_CPQ.TOTAL_QUOTE_VALUE,CON_CPQ.NAME};											   
            
            Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(allQuoteDetailsObj.quoteId, fieldSet);
            allQuoteDetailsObj.budgetName = proposal.name;
            allQuoteDetailsObj.budgetType = proposal.Apttus_Proposal__Proposal_Category__c;
            allQuoteDetailsObj.scenario = proposal.RFP_Scenario__c;
            allQuoteDetailsObj.scenarioDescription = proposal.Scenario_Description__c;
            allQuoteDetailsObj.scenarioNumber = proposal.Scenario_Number__c;
            allQuoteDetailsObj.budgetIteration = proposal.Budget_Iteration__c;
            allQuoteDetailsObj.approvalStage = proposal.Apttus_Proposal__Approval_Stage__c;
            allQuoteDetailsObj.totalQuoteAmount = proposal.Total_Quote_Amount__c;
        }
        allQuoteDetailsObj.pricingToolValues = CON_CPQ.BUDGET_TOOL_VALUES;
        return allQuoteDetailsObj;
    }
    
    /*
     * Description   : Wrapper Class
     */
     
    public class AllQuoteDetails {
        @AuraEnabled
        public Id quoteId {get; set;}
        @AuraEnabled
        public Id clinicalBidId {get; set;}
        @AuraEnabled
        public Id accountId {get; set;}
        @AuraEnabled
        public String quotePricingTool {get; set;}
        @AuraEnabled
        public Boolean isQuoteExist {get; set;}
        @AuraEnabled
        public Boolean isPrimaryQuoteExist {get; set;}
        @AuraEnabled
        public Boolean isOpportunityExist {get; set;}
        @AuraEnabled
        public List<String> pricingToolValues {get; set;}
        @AuraEnabled
        public Id opportunityId {get; set;}
        @AuraEnabled
        public String opportunityName {get; set;}
        @AuraEnabled
        public Boolean isStatusClosedForInternalPurposes {get; set;}
        @AuraEnabled
        public String budgetType {get; set;}
        @AuraEnabled
        public String scenario {get; set;}
        @AuraEnabled
        public String scenarioDescription {get; set;}
        @AuraEnabled
        public Decimal scenarioNumber {get; set;}
        @AuraEnabled
        public Decimal budgetIteration {get; set;}
        @AuraEnabled
        public String approvalStage {get; set;}
        @AuraEnabled
        public Decimal totalQuoteAmount {get; set;}
        @AuraEnabled
        public String budgetName {get; set;}
        @AuraEnabled
        public Boolean isCancelled {get; set;}
        @AuraEnabled
        public Id recordId {get; set;}
        @AuraEnabled
        public Boolean isCreateQuoteFromOpportunity {get; set;}
        @AuraEnabled
        public Boolean isCreateQuoteFromGenericContract {get; set;}
        
    }   
}