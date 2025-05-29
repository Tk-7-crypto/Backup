public class DAOH_Proposal_Line_Item {
    /**
    * This method is used to set Currency of PLI as per proposal's currency
    * @params  newProposalLineItemList List<Apttus_Proposal__Proposal_Line_Item__c>
    * @params  Map<Id, Apttus_Proposal__Proposal_Line_Item__c> oldMap
    * @return  void
    */
    public static void setLineItemCurrency(List<Apttus_Proposal__Proposal_Line_Item__c> newProposalLineItemList, Map<Id, Apttus_Proposal__Proposal_Line_Item__c> oldMap) {
        Set<Id> proposalIdSet = new Set<Id>();
        List<Apttus_Proposal__Proposal_Line_Item__c> updatedList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for (Apttus_Proposal__Proposal_Line_Item__c pli : newProposalLineItemList) {
            proposalIdSet.add(pli.Apttus_Proposal__Proposal__c);
            updatedList.add(pli);
        }
        if(proposalIdSet.size() > 0) {
            Map<Id,Apttus_Proposal__Proposal__c> relatedProposalMap = new SLT_Proposal().selectByProposalIds(proposalIdSet, new Set<String> {CON_CPQ.ID, CON_CPQ.CURRENCYISOCODE, CON_CPQ.RECORD_TYPE_ID});
            for (Apttus_Proposal__Proposal_Line_Item__c lineItem : updatedList) {
                if(relatedProposalMap != null && relatedProposalMap.containsKey(lineItem.Apttus_Proposal__Proposal__c) 
                   && (relatedProposalMap.get(lineItem.Apttus_Proposal__Proposal__c).RecordType.Id == CPQ_Utility.proposalRDSNonSFRecordTypeId 
                       || relatedProposalMap.get(lineItem.Apttus_Proposal__Proposal__c).RecordType.Id == CPQ_Utility.proposalBudgetRecordTypeId))
                    lineItem.CurrencyIsoCode = relatedProposalMap.get(lineItem.Apttus_Proposal__Proposal__c).CurrencyIsoCode; 
            }
        }
    }
    
    public static void setPLICountry(List<Apttus_Proposal__Proposal_Line_Item__c> newProposalLineItemList, Map<Id, Apttus_Proposal__Proposal_Line_Item__c> oldRecordsMap) {
        for (Apttus_Proposal__Proposal_Line_Item__c pli : newProposalLineItemList) {
            if (pli.BidGrid_Country__c == CON_CPQ.MACEDONIA) {
                pli.BidGrid_Country__c = CON_CPQ.REPUBLIC_OF_NORTH_MACEDONIA;
            }
            if (pli.Pricing_Country__c == CON_CPQ.MACEDONIA) {
                 pli.Pricing_Country__c = CON_CPQ.REPUBLIC_OF_NORTH_MACEDONIA;
            }
        }
    }
}