public class CNT_CPQ_AgreementSection {
    
    public class BudgetDetails {
        @AuraEnabled
        public Id recordId {get; set;}
        @AuraEnabled
        public String actionType {get; set;}
        @AuraEnabled
        public String signOffActionType {get; set;}
        @AuraEnabled
        public String ccEmails {get; set;}
        @AuraEnabled
        public String pdManager {get; set;}
        @AuraEnabled
        public List<String> tssuList {get; set;}
        @AuraEnabled
        public List<String> accountsAndSalesList {get; set;}
        @AuraEnabled
        public List<String> plList {get; set;}
        @AuraEnabled
        public List<String> accDirectoryList {get; set;}
    }
    
    @auraEnabled
    public static BudgetDetails getBudgetDetails(Id recordId, String objectName) {
        BudgetDetails budgetDetailObj = new BudgetDetails();
        String status = '';
        Id ownerId;
        String oppType = '';
        String isThisIQB = '';
        String cCEmailSet = '';
        Decimal winProbability;
        String accountCountry = '';
        String potentialRegion = '';
        
        Apttus_Proposal__Proposal__c proposal = getProposal(recordId);
        status = (proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.SIGN_OFF) ? CON_CPQ.FINAL_SIGN_OFF : proposal.Apttus_Proposal__Approval_Stage__c;
        ownerId = proposal.OwnerId;
        Decimal totalIqviaFeeCDS = proposal.Total_IQVIA_Fees_BID__c ; 
        
        if (proposal.CurrencyIsoCode != CON_CPQ.USD){
            Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCode(new Set<String>{proposal.CurrencyIsoCode,CON_CPQ.USD});
            totalIqviaFeeCDS = CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(CON_CPQ.USD).conversionRate, 
                                                                     isoCodeTocurrencyTypeMap.get(proposal.CurrencyIsoCode).conversionRate, (double)proposal.Total_IQVIA_Fees_BID__c);
        }
        oppType = proposal.Clinical_Bid__r.Opportunity_Type__c;
        isThisIQB = proposal.Apttus_Proposal__Opportunity__r.Is_this_IQVIA_Biotech__c;
        winProbability = proposal.Clinical_Bid__r.Win_Probability__c;
        accountCountry = proposal.Apttus_Proposal__Account__r.AccountCountry__c;
        potentialRegion = proposal.Apttus_Proposal__Opportunity__r.Potential_Regions__c;
        budgetDetailObj.signOffActionType = CPQ_Utility.getChallengeMatrixAction(ownerId, totalIqviaFeeCDS, oppType, CON_CPQ.FINAL_SIGN_OFF, isThisIQB, winProbability, accountCountry, potentialRegion);
        if(proposal.Owner.Email != null)
            cCEmailSet = proposal.Owner.Email;
        
        budgetDetailObj.recordId = recordId;
        budgetDetailObj.actionType = CPQ_Utility.getChallengeMatrixAction(ownerId, totalIqviaFeeCDS, oppType, status, isThisIQB, winProbability, accountCountry, potentialRegion);
        budgetDetailObj.ccEmails = cCEmailSet;
        return budgetDetailObj;
    }
    @testVisible
    private static Apttus_Proposal__Proposal__c getProposal(Id recordId) {
        Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(recordId, new Set<String> {CON_CPQ.ID, 
            CON_CPQ.NAME, CON_CPQ.TOTAL_IQVIA_FEES_BID, CON_CPQ.AGREEMENT_OWNER_EMAIL, 
            CON_CPQ.RELATED_CLINICAL_OPPORTUNITY_TYPE, CON_CPQ.APTTUS_PROPOSAL_OPPORTUNITY,
            CON_CPQ.APPROVAL_STAGE, CON_CPQ.OWNER, CON_CPQ.CURRENCYISOCODE, CON_CPQ.IS_THIS_IQVIA_BIOTECH, CON_CPQ.WIN_PROBABILITY, CON_CPQ.PROPOSAL_ACCOUNT_COUNTRY, CON_CPQ.POTENTIAL_REGION});
        return proposal;
    }
    
}