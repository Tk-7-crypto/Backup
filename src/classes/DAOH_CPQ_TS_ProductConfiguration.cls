/**
 * This is Product Configuration handler class for "Tech Solution" Proposal record type.
 * version : 1.0 
 */
public class DAOH_CPQ_TS_ProductConfiguration 
{
    // Set Proposal attributes after Cart gets finalized 
    public static void setProposalFieldsFromFinalizedCart(Map<Id, Apttus_Config2__ProductConfiguration__c> newConfigurations,
                                                          Map<Id, Apttus_Config2__ProductConfiguration__c> oldConfigurations) {
        
        if (trigger.isAfter && trigger.isUpdate) {
            Set<Id> prodConfigIdSet = new Set<Id>();
            for (Apttus_Config2__ProductConfiguration__c config : newConfigurations.values()) {
                if (config.Apttus_Config2__Status__c != oldConfigurations.get(config.Id).Apttus_Config2__Status__c) {
                    prodConfigIdSet.add(config.Id);
                }
            }
            if (prodConfigIdSet.size() > 0) {
                // Get Config record related to Tech Solution proposal
                Map<Id, Apttus_Config2__ProductConfiguration__c> configs = new SLT_ProductConfiguration()
                    .selectProposalConfigsWithLineItemsForRecordType(
                        prodConfigIdSet, 
                        new Set<Id>{CPQ_Utility.proposalTechSolutionRecordTypeId},
                        new Set<String> {CON_CPQ.PROPOSAL_ID, CON_CPQ.PRODUCT_CONFIG_STATUS, CON_CPQ.PRODUCT_CONFIG_BUSINESS_OBJ_ID, CON_CPQ.PRODUCT_CONFIG_TO_QUOTE_PRICING_TOOL},
                        new Set<String> {
                            CON_CPQ.QUOTE_LINE_ITEM_START_DATE,
                            CON_CPQ.QUOTE_LINE_ITEM_END_DATE,
                            CON_CPQ.QUOTE_LINE_ITEM_GROSS_MARGIN,
                            CON_CPQ.QUOTE_LINE_ITEM_PASS_THROUGH
                        }
                    );
                
                List<Apttus_Proposal__Proposal__c> proposalsToUpdate = new List<Apttus_Proposal__Proposal__c>();
                Apttus_Proposal__Proposal__c proposal;
                
                // Check old status of Config record should not be Finalized
                for (Apttus_Config2__ProductConfiguration__c config : configs.values()){
                    
                    proposal = new Apttus_Proposal__Proposal__c();
                    
                    if (config.Apttus_Config2__Status__c == CON_CPQ.PRODUCT_CONFIG_STATUS_SAVED) {
                        proposal.Id = config.Apttus_QPConfig__Proposald__c;
                        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.IN_PROGRESS_STATUS;
                        
                    } else if (config.Apttus_Config2__Status__c == CON_CPQ.FINALIZED && config.Apttus_Config2__BusinessObjectId__c == config.Apttus_QPConfig__Proposald__c) {
                        proposal.Id = config.Apttus_QPConfig__Proposald__c;
                        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.FINALIZED;
                        
                        if (config.Apttus_QPConfig__Proposald__r.Select_Pricing_Tool__c == CON_CPQ.TS_JAPAN) {
                        
                            Date minStartDate;	
                            Date maxEndDate;
                            Decimal minGrossMargin = 9999999; // Upper value
                            
                            for(Apttus_Config2__LineItem__c lineItem : config.Apttus_Config2__LineItems__r){
                            
                                // Set earliest start date
                                if(minStartDate == null || minStartDate > lineItem.Apttus_Config2__StartDate__c){
                                    minStartDate = lineItem.Apttus_Config2__StartDate__c;
                                }
                                
                                // Set latest end date
                                if(maxEndDate == null || maxEndDate < lineItem.Apttus_Config2__EndDate__c){
                                    maxEndDate = lineItem.Apttus_Config2__EndDate__c;
                                }
                                
                                // Set Min Gross Margin without PT
                                if(!lineItem.Pass_Through__c){
                                    if(lineItem.Gross_Margin__c == null || lineItem.Gross_Margin__c < minGrossMargin){
                                        minGrossMargin = lineItem.Gross_Margin__c;
                                    }
                                }
                            }
                            
                            proposal.Apttus_Proposal__ExpectedStartDate__c = minStartDate;
                            proposal.Apttus_Proposal__ExpectedEndDate__c = maxEndDate;
                            proposal.Min_Gross_Margin__c = minGrossMargin != null && minGrossMargin != 9999999 ? minGrossMargin : null;
                        }
                    }
                    
                    if(proposal.Id != null){
                        proposalsToUpdate.add(proposal);
                    }
                }
                update proposalsToUpdate;
            }
        }
    }
}
