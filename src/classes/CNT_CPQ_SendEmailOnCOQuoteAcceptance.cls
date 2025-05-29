public class CNT_CPQ_SendEmailOnCOQuoteAcceptance {
    public static Id coOpportunityId{get;set;}
    public static Id recordID{get;set;}
    public static List<Apttus_Proposal__Proposal__c> proposalList;

    public static void getAllCNFProposal() {
        proposalList = new List<Apttus_Proposal__Proposal__c>();
        Set<String> proposalFieldSet = new Set<String> {CON_CPQ.ID, 
            CON_CPQ.PROPOSAL_CATEGORY,
            CON_CPQ.RELATED_CHANGE_ORDER,
            CON_CPQ.APTTUS_PROPOSAL_OPPORTUNITY, 
            CON_CPQ.Name, 
            CON_CPQ.RFP_SCENARIO, 
            CON_CPQ.CHNAGE_ORDER_NUMBER,
            CON_CPQ.CNF_STATUS,
            CON_CPQ.CURRENCYISOCODE,
            CON_CPQ.ACTUAL_QUOTE_AMOUNT,
            CON_CPQ.CNF_APPROVAL_DATE};
                
        Set<Id> opportunityIdSet = new Set<Id>{coOpportunityId};
        String condition = 'Apttus_Proposal__Opportunity__c IN :opportunityIdSet AND Apttus_Proposal__Proposal_Category__c = \'' + CON_CPQ.CNF + '\'';
        proposalList = new SLT_Proposal().getQuoteByParentRelatedOpportunity(opportunityIdSet, proposalFieldSet, condition);     
    }
    
    public static List<Apttus_Proposal__Proposal__c> getAssociatedCNF() {
        getAllCNFProposal();
        List<Apttus_Proposal__Proposal__c> associatedCNFList = new List<Apttus_Proposal__Proposal__c>();
        if (proposalList.size()>0) {
            for (Apttus_Proposal__Proposal__c proposal : proposalList) {
                if (proposal.Related_Change_Order__c == recordID) {
                    associatedCNFList.add(proposal);
                }
            }  
        }
        return associatedCNFList;
    }
    
    public static List<Apttus_Proposal__Proposal__c> getNonAssociatedCNF() {
        getAllCNFProposal();
        List<Apttus_Proposal__Proposal__c> nonAssociatedCNFList = new List<Apttus_Proposal__Proposal__c>();
        if (proposalList.size()>0){
            for (Apttus_Proposal__Proposal__c proposal : proposalList){
                if(proposal.Related_Change_Order__c == null){
                    nonAssociatedCNFList.add(proposal);
                }
            }    
        }
        return nonAssociatedCNFList;
    }
}