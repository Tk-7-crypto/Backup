public class DAOH_Proposal 
{
    public static void setSharing(List<Apttus_Proposal__Proposal__c> newProposalList, Map<Id, Apttus_Proposal__Proposal__c> oldMap) {
        UTL_Sharing.setSharing(newProposalList, oldMap, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
    }

    public static void setDummyCreatorAccess(List<Apttus_Proposal__Proposal__c> newProposalList) {
        UTL_Sharing.setDummyCreatorAccess(newProposalList, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL_SHARE, CON_CPQ.PROPOSAL_TERRITORY);
    }
	
    public static void setAccountCountry(List<Apttus_Proposal__Proposal__c> newProposalList, Map<Id, Apttus_Proposal__Proposal__c> oldMap) {
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        List<Apttus_Proposal__Proposal__c> updatedList = new List<Apttus_Proposal__Proposal__c>();
        Map<Id, Quote__c> quoteIdMap = new Map<Id, Quote__c>();
        Boolean isIQVIAQuoteAccessible = Schema.sObjectType.Apttus_Proposal__Proposal__c.fields.IQVIA_Quote__c.isAccessible();
        if (isIQVIAQuoteAccessible) {
            for (Apttus_Proposal__Proposal__c apts : newProposalList) {
                quoteIdSet.add(apts.IQVIA_Quote__c);
            }
        }
        if (!quoteIdSet.isEmpty()) {
            for (Quote__c quote : new SLT_IQVIA_Quote().getQuoteIdslist(quoteIdSet, new Set<String>{CON_CPQ.ID, CON_CPQ.IQVIA_QUOTE_ACCOUNT, CON_CPQ.IQVIA_QUOTE_PRICING_TOOL})) {
                quoteIdMap.put(quote.Id, quote);
            }
        }
        for (Apttus_Proposal__Proposal__c apts : newProposalList) {
            if ((Trigger.isInsert || Trigger.isUpdate)) {
                if (isIQVIAQuoteAccessible && apts.IQVIA_Quote__c != null && (quoteIdMap != null && quoteIdMap.get(apts.IQVIA_Quote__c).Pricing_Tools__c == CON_CPQ.Q2_Solutions)) {
                    apts.Account_Country__c = CON_CPQ.CLINICAL_RESEARCH;
                } else {
                    if (apts.Apttus_Proposal__Account__c != null) {
                        accountIdSet.add(apts.Apttus_Proposal__Account__c);
                        updatedList.add(apts);
                    } else if (isIQVIAQuoteAccessible && apts.IQVIA_Quote__c != null && (quoteIdMap != null && quoteIdMap.get(apts.IQVIA_Quote__c).Related_Account__c != null)) {
                        accountIdSet.add(quoteIdMap.get(apts.IQVIA_Quote__c).Related_Account__c);
                        updatedList.add(apts);
                    } else {
                        apts.Account_Country__c = null;
                    }
                }
            }
        }
        if (accountIdSet.size() > 0) {
            Map<Id, Account> accountIdMap = new SLT_Account().selectByAccountId(accountIdSet, new Set<String> {CON_CPQ.ID, CON_CPQ.ACCOUNT_COUNTRY, CON_CPQ.RECORD_TYPE_ID});
            for (Apttus_Proposal__Proposal__c apts : updatedList) {
                Id accId = apts.Apttus_Proposal__Account__c != null ? apts.Apttus_Proposal__Account__c : (isIQVIAQuoteAccessible && apts.IQVIA_Quote__c != null && (quoteIdMap != null && quoteIdMap.get(apts.IQVIA_Quote__c).Related_Account__c != null)) ? quoteIdMap.get(apts.IQVIA_Quote__c).Related_Account__c : null;
                if (!apts.Contingency__c && accountIdMap.containsKey(accId) && accountIdMap.get(accId).RecordType.Id != CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID) {
                    apts.Account_Country__c = accountIdMap.get(accId).AccountCountry__c;    
                } else {
                    apts.Account_Country__c = null;
                }
            }   
        }
    }

    public static void setLastSharingCalculationTimestamp(List<Apttus_Proposal__Proposal__c> newProposalList, Map<Id, Apttus_Proposal__Proposal__c> oldMap) {
        Boolean isFieldToUpdate = true;
        Set<Id> recordIdSet = new Set<Id>();
        if (Trigger.isUpdate) {
            recordIdSet = UTL_Sharing.checkFieldSetValueChange(newProposalList, oldMap, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL, CON_CPQ.SHR_PARENT_FIELDSET);
            if (recordIdSet.size() == 0) {
                isFieldToUpdate = false;
            }
        }
        if (isFieldToUpdate) {
            for(Apttus_Proposal__Proposal__c apts :newProposalList) {
                if (Trigger.isInsert || recordIdSet.contains(apts.Id)) {
                    apts.Last_Sharing_Calculation_Timestamp__c = System.Now();    
                }
            }   
        }
    }
    
    public static void setLastManualSharingFieldUpdate(List<Apttus_Proposal__Proposal__c> newProposalList, Map<Id, Apttus_Proposal__Proposal__c> oldMap) {
        for (Apttus_Proposal__Proposal__c apts : newProposalList) {
            if (apts.Run_Sharing__c) {
                apts.Run_Sharing__c = false;
                apts.Last_Manual_Sharing_Execution__c = System.now();
            }
        }
    }
	
    public static void setXAELockTimeStamp(List<Apttus_Proposal__Proposal__c> newBudgetList, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        Map<Id, Id> lockedUserMap = new Map<Id, Id>();
        Map<Id, Id> clinicalBudgetMap = new Map<Id, Id>();
        Map<String, String> clinicalAssignmentMap = new Map<String, String>();
        
        for (Apttus_Proposal__Proposal__c budget : newBudgetList) {
            if (budget.Pricing_Tool_Locked__c == true && 
                budget.Pricing_Tool_Locked__c != oldRecordsMap.get(budget.Id).Pricing_Tool_Locked__c && budget.Budget_Checked_Out_By__c != null) {
                    lockedUserMap.put(budget.Id, budget.Budget_Checked_Out_By__c);
                    clinicalBudgetMap.put(budget.Id, budget.Clinical_Bid__c);
            }
        }
        if (clinicalBudgetMap.size()> 0) {
            List<pse__Assignment__c> assignmentList = new SLT_Assignment().getAssignmentClinicalBidAndUser(clinicalBudgetMap.values(), lockedUserMap.values());
            
            for (pse__Assignment__c assignment : assignmentList) { 
                if (clinicalAssignmentMap.containsKey(assignment.pse__Resource__r.pse__Salesforce_User__c + CON_CPQ.SEPARATOR + assignment.Bid_History__c)) {
                    String subGroup = clinicalAssignmentMap.get(assignment.pse__Resource__r.pse__Salesforce_User__c + CON_CPQ.SEPARATOR + assignment.Bid_History__c);
                    clinicalAssignmentMap.put(assignment.pse__Resource__r.pse__Salesforce_User__c + CON_CPQ.SEPARATOR + assignment.Bid_History__c, subGroup + CON_CPQ.COMMA + assignment.pse__Resource_Request__r.SubGroup__c);
                } else {
                    clinicalAssignmentMap.put(assignment.pse__Resource__r.pse__Salesforce_User__c + CON_CPQ.SEPARATOR + assignment.Bid_History__c, assignment.pse__Resource_Request__r.SubGroup__c);
                }
            }
        }
        
        for (Apttus_Proposal__Proposal__c budget :  newBudgetList) {
            if (budget.Pricing_Tool_Locked__c == true && 
                budget.Pricing_Tool_Locked__c != oldRecordsMap.get(budget.Id).Pricing_Tool_Locked__c && budget.Budget_Checked_Out_By__c != null) {
                    budget.XAE_Lock_Timestamp__c = System.now();
                    if (clinicalAssignmentMap != null && clinicalAssignmentMap.containsKey(budget.Budget_Checked_Out_By__c + CON_CPQ.SEPARATOR + budget.Clinical_Bid__c)) {
                        budget.User_Group__c = clinicalAssignmentMap.get(budget.Budget_Checked_Out_By__c + CON_CPQ.SEPARATOR + budget.Clinical_Bid__c);
                    }
            }
			 
            if (budget.Budget_Checked_Out_By__c == null && 
                budget.Budget_Checked_Out_By__c != oldRecordsMap.get(budget.Id).Budget_Checked_Out_By__c) {
                    budget.User_Group__c = '';
            }
        }
    }
    /**
     * Set the Proposal Fields based on 2 fields
     * @param budgets List of Proposal records
     * @param oldRecordsMap old map from trigger 
     * @return none
     */
    public static void setBudgetFields(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
            budget.Approval_Status__c = CON_CPQ.NONE;
            /* Commented under LC-11450 
            budget.Approval_Status__c = CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW;
            */
            /* Commented under LC-9356
            if(budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC || budget.Apttus_Proposal__Proposal_Category__c == 
               CON_CPQ.PRELIMINARY || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF || 
               budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER || 
               budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK) {
                   budget.Approval_Status__c = CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW;
               } 
            else {
                budget.Approval_Status__c = CON_CPQ.NONE;
            }*/	
        }
    }

    /**
     * Set the Proposal Status Field
     * @param budgets List of Proposal records
     * @param oldRecordsMap old map from trigger 
     * @return none
     */
    public static void setBudgetStatus(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if(budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.DRAFT && budget.Approval_Status__c == CON_CPQ.NONE && 
               (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC || budget.Apttus_Proposal__Proposal_Category__c == 
                CON_CPQ.PRELIMINARY || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF || 
                budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER || 
                budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK)) {
                    budget.Approval_Status__c = CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW;
                }
        }
    }
    
    /**
     * Set the Proposal Name based on 2 fields
     * @param budgets List of Proposal records
     * @return none
    */
    public static void setBudgetName(List<Apttus_Proposal__Proposal__c> budgets) {
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> opportunityIdSet = new Set<Id>();
        Map<Id, Contract> contractIdMap = new Map<Id,Contract>();
        Map<Id, Bid_History__c> postAwardBidIdMap = new Map<Id,Bid_History__c>();
        Map<Id, Opportunity> opportunityIdMap = new Map<Id,Opportunity>();
        String postFix;
        
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            
            if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC ||
                budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY ||
                budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF ||
                budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER ||
                budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK) {
                    budget.OwnerId = UserInfo.getUserId();
                }
            
            postFix = '';
            if (budget.Budget_Iteration__c != null) {
                postFix = postFix + CON_CPQ.HYPHEN + budget.Budget_Iteration__c;
            }							   
            if (budget.Scenario_Number__c != null) {
                postFix = postFix + CON_CPQ.HYPHEN + budget.Scenario_Number__c;
            }							   
            if (budget.Apttus_Proposal__Opportunity__c != null) {
                budget.Apttus_Proposal__Proposal_Name__c = budget.Bid_Name__c.left(80 - postFix.length()) + postFix;
            }
            if (budget.Clinical_Bid__c != null && 
                (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF ||
                 budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER ||
                 budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK)) {
                     contractIdSet.add(budget.Clinical_Bid__c);
            }
            
            if (budget.Apttus_Proposal__Opportunity__c  != null) {
                opportunityIdSet.add(budget.Apttus_Proposal__Opportunity__c );
            } 
        }
        if (contractIdSet.size() > 0) {
            postAwardBidIdMap = new SLT_Bid_History().getBidHistoriesById(contractIdSet, new Set<String>{CON_CPQ.ID, CON_CPQ.PROJECT_LEADER_REGION, CON_CPQ.CONTRACT_RANKING, CON_CPQ.RECORDTYPE, CON_CPQ.CREATED_BY_FORMASSEMBLY});
        }
        if (opportunityIdSet.size() > 0) {
            opportunityIdMap = new SLT_Opportunity().getOpportunityById(opportunityIdSet, new Set<String>{CON_CPQ.ID, CON_CPQ.LEGACY_QUINTILES_OPPORTUNITY_NUMBER, CON_CPQ.OWNER_NAME});
        }
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Contract__c != null && contractIdMap.containsKey(budget.Contract__c)) {
                if(budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.Ballpark) {
                    budget.Contract_Ranking__c = contractIdMap.get(budget.Contract__c).Contract_Ranking__c;
                }
                budget.Project_Leader_Region__c = contractIdMap.get(budget.Contract__c).Project_Leader_Region__c;
            } else if (budget.Clinical_Bid__c != null && postAwardBidIdMap.containsKey(budget.Clinical_Bid__c) && postAwardBidIdMap.get(budget.Clinical_Bid__c).Record_Type__c == CON_CPQ.CONTRACT_POST_AWARD_BID &&
                      postAwardBidIdMap.get(budget.Clinical_Bid__c).Created_by_FormAssembly__c == true) {
                if(budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.Ballpark) {
                    budget.Contract_Ranking__c = postAwardBidIdMap.get(budget.Clinical_Bid__c).Contract_Ranking__c;
                }
                budget.Project_Leader_Region__c = postAwardBidIdMap.get(budget.Clinical_Bid__c).Project_Leader_Region__c;
            }
            if (budget.Apttus_Proposal__Opportunity__c != null && opportunityIdMap.containsKey(budget.Apttus_Proposal__Opportunity__c)) {
                budget.Project_Number__c = opportunityIdMap.get(budget.Apttus_Proposal__Opportunity__c).Legacy_Quintiles_Opportunity_Number__c;
                budget.Opportunity_Number__c = opportunityIdMap.get(budget.Apttus_Proposal__Opportunity__c).Legacy_Quintiles_Opportunity_Number__c;
                budget.Opportunity_Owner__c = opportunityIdMap.get(budget.Apttus_Proposal__Opportunity__c).Owner.Name;
            }	
        }
    }
	
    public static void cloneBudgetAttachment(List<Apttus_Proposal__Proposal__c> budgets) {
        Map<Id, Id> attachmentMap = new Map<Id, Id>();
        
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            attachmentMap.put(budget.Apttus_Proposal__RelatedProposalId__c, budget.Id);
        }
        if (attachmentMap.size() > 0) {
            Attachment attachment;
            String conditionForAttachment = ' ParentId IN :parentIds Order By LastModifiedDate Desc LIMIT 1';
            List<Attachment> attachmentList = new SLT_Attachment().getLatestAttachments(conditionForAttachment, attachmentMap.keySet());
            if (attachmentList.size() != 0) {  
                List<Attachment> attachments = new List<Attachment>();
                
                for (Attachment oldAttachment : attachmentList) {
                    if (attachmentMap != null && attachmentMap.containsKey(oldAttachment.ParentId)) {
                        attachment = new Attachment();
                        attachment.Body = oldAttachment.Body;
                        attachment.Name = CON_CPQ.CLONE_AGREEMENT_ATTACHMENT_PREFIX + attachmentMap.get(oldAttachment.ParentId) + CON_CPQ.UPT_TEMPLATE_EXTENSION;
                        attachment.ContentType = oldAttachment.ContentType;
                        attachment.ParentId = attachmentMap.get(oldAttachment.ParentId);
                        attachments.add(attachment);
                    }
                }
                if (!attachments.IsEmpty()){
                    insert attachments;
                }
            }
							   
        }
    }
    
    public static void validateLineItemCount(List<Apttus_Proposal__Proposal__c> newBudgetList, Map<Id, Apttus_Proposal__Proposal__c> oldBudgetMap)
    {
        List<Apttus_Proposal__Proposal__c> finalizedRDSBudget = new List<Apttus_Proposal__Proposal__c>();        
        for (Apttus_Proposal__Proposal__c budget : newBudgetList)
        {
            if (budget.Apttus_QPConfig__ConfigurationFinalizedDate__c != null
               && oldBudgetMap.get(budget.Id).Apttus_QPConfig__ConfigurationFinalizedDate__c == null)
            {
                finalizedRDSBudget.add(budget);
            }
        }
        
        Map<Id, Integer> lineItemCountMap = new Map<Id, Integer>();        
        List<AggregateResult> aggResList = new SLT_ProposalLineItems().getLineItemCountByBudgetId(new Map<Id, Apttus_Proposal__Proposal__c>(finalizedRDSBudget).keySet());
        for (AggregateResult aggRes : aggResList) 
        {
            Id budgetId = (Id) aggRes.get(CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
            Integer lineItemCount = (Integer) aggRes.get(CON_CPQ.LINEITEMCOUNT);
            lineItemCountMap.put(budgetId, lineItemCount);
        }
        
        for (Apttus_Proposal__Proposal__c budget : finalizedRDSBudget)
        {
            if (budget.Number_of_Line_Items__c == null || budget.Number_of_Line_Items__c != lineItemCountMap.get(budget.Id))
            {
                budget.addError(CON_CPQ.ERROR_MSG_WHEN_LINE_ITEM_COUNT_DO_NOT_MATCH);
            }
        }
    }
    

    public static void moveToPresentedStage(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) 
    {
        Set<Id> clinicalBidIdSet = new Set<Id>();
        Set<Id> opportunityIdSet = new Set<Id>();
        List<Apttus_Proposal__Proposal__c> existingProposalList = new List<Apttus_Proposal__Proposal__c>();
        Map<Id, Opportunity> opportunityIdMap = new Map<Id,Opportunity>();
        Map<Id, Set<Id>> bidHistoryToProposalIdMap = new Map<Id, Set<Id>>();
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID) {
                if ((budget.Bid_Sent_Date__c != oldRecordsMap.get(budget.Id).Bid_Sent_Date__c && budget.Bid_Sent_Date__c != null) ||
                    (budget.Apttus_Proposal__Primary__c != oldRecordsMap.get(budget.Id).Apttus_Proposal__Primary__c &&
                     budget.Apttus_Proposal__Primary__c == true &&
                     budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.PRESENTED)) {

                    if (budget.Clinical_Bid__c != null) {
                        clinicalBidIdSet.add(budget.Clinical_Bid__c);
                    }
                    if (budget.Apttus_Proposal__Opportunity__c != null) {
                        opportunityIdSet.add(budget.Apttus_Proposal__Opportunity__c);
                    }
                } else if ((budget.RFP_Scenario__c != CON_CPQ.INACTIVE && oldRecordsMap.get(budget.Id).RFP_Scenario__c == CON_CPQ.INACTIVE) || (budget.RFP_Scenario__c == CON_CPQ.INACTIVE && oldRecordsMap.get(budget.Id).RFP_Scenario__c != CON_CPQ.INACTIVE)) {
                    if (budget.Clinical_Bid__c != null) {
                        clinicalBidIdSet.add(budget.Clinical_Bid__c);
                    }
                }
            }
        }
        if (clinicalBidIdSet.size() > 0) {
            String conditon = 'Clinical_Bid__c IN : clinicalBidIds AND RFP_Scenario__c != \''+CON_CPQ.INACTIVE+ '\' AND Apttus_Proposal__Proposal_Category__c IN (\'' + CON_CPQ.INITIAL + '\',\'' + CON_CPQ.REBID + '\')';
            existingProposalList = new SLT_Proposal().getQuoteByParentClinicalBid(clinicalBidIdSet, new Set<String> {CON_CPQ.ID, CON_CPQ.PROPOSAL_CATEGORY, CON_CPQ.APTTUS_PROPOSAL_PARENT_BID}, conditon);
        }
        if (opportunityIdSet.size() > 0) {
            opportunityIdMap = new SLT_Opportunity().getOpportunityById(opportunityIdSet, new Set<String>{CON_CPQ.ID, CON_CPQ.OPPORTUNITY_STAGENAME});
        }
        for (Apttus_Proposal__Proposal__c budget : existingProposalList) {
            if (bidHistoryToProposalIdMap.containsKey(budget.Clinical_Bid__c)) {
                Set<Id> temp = bidHistoryToProposalIdMap.get(budget.Clinical_Bid__c);
                temp.add(budget.Id);
                bidHistoryToProposalIdMap.put(budget.Clinical_Bid__c, temp);
            } else {
                bidHistoryToProposalIdMap.put(budget.Clinical_Bid__c, new Set<Id>{budget.Id});
            }
        }
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.RFP_Scenario__c != CON_CPQ.INACTIVE && oldRecordsMap.get(budget.Id).RFP_Scenario__c == CON_CPQ.INACTIVE && bidHistoryToProposalIdMap.containsKey(budget.Clinical_Bid__c) && 
                bidHistoryToProposalIdMap.get(budget.Clinical_Bid__c).size() > 0 && (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID)) {
                budget.addError(CON_CPQ.MESSAGE_ACTIVE_QUOTE_ALREADY_EXIST);
            }
            if (((budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.PRESENTED && budget.Apttus_Proposal__Primary__c != oldRecordsMap.get(budget.Id).Apttus_Proposal__Primary__c) && budget.Apttus_Proposal__Primary__c == true )||
                (budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.GENERATED && budget.Bid_Sent_Date__c != oldRecordsMap.get(budget.Id).Bid_Sent_Date__c && budget.Bid_Sent_Date__c != null)) {
                if (budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.GENERATED) {
                    budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.PRESENTED;
                    budget.Approval_Status__c = CON_CPQ.DOCUMENT_PRESENTED;
                }
                    if(budget.Apttus_QPConfig__ConfigurationFinalizedDate__c == null) {
                        budget.addError(CON_CPQ.MESSAGE_PLEASE_FINALIZE_THE_BUDGET);
                    } else if(budget.Number_of_Line_Items__c == null || budget.Number_of_Line_Items__c <= 0) {
                        budget.addError(CON_CPQ.MESSAGE_PLI_SHOULD_EXIST_BEFORE_SYNC);
                    } else if(budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID) {
                        if (budget.Select_Pricing_Tool__c == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT) {
                            for (Schema.FieldSetMember fields : Schema.SObjectType.Apttus_Proposal__Proposal__c.fieldSets.getMap().get(CON_CPQ.QUOTE_FIELDSET_BUDGET_TO_CLINICAL_BID_SYNC_LCS).getFields()) {
                                if (budget.get(fields.getFieldPath()) == null) {
                                    budget.addError(fields.getFieldPath(), CON_CPQ.MESSAGE_COMPLETE_THIS_FIELD);
                                }
                            }
                        } else {
                            for (Schema.FieldSetMember fields : Schema.SObjectType.Apttus_Proposal__Proposal__c.fieldSets.getMap().get(CON_CPQ.QUOTE_FIELDSET_BUDGET_TO_CLINICAL_BID_SYNC_UPT).getFields()) {
                                if (budget.get(fields.getFieldPath()) == null) {
                                    budget.addError(fields.getFieldPath(), CON_CPQ.MESSAGE_COMPLETE_THIS_FIELD);
                                }
                            }
                        }
                        if(!budget.hasErrors() && opportunityIdMap != null && opportunityIdMap.containsKey(budget.Apttus_Proposal__Opportunity__c) && CON_CPQ.OPPORTUNITY_STAGES.contains(opportunityIdMap.get(budget.Apttus_Proposal__Opportunity__c).StageName) && budget.Apttus_Proposal__Primary__c == true) {
                            budget.Execution_Status__c = CON_CPQ.IN_PROGRESS_STATUS;
                        }
                    }
                }
        }
    } 
    public static void updateBidHistoryAndOLI(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) 
    {
        Set<Id> clinicalBidIdSet = new Set<Id>();
        Map<Id, Bid_History__c> clinicalBidIdMap = new Map<Id,Bid_History__c>();
        Set<Id> opportunityIdSet = new Set<Id>();
        Map<Id, Opportunity> opportunityIdMap = new Map<Id,Opportunity>();
        List<Apttus_Proposal__Proposal__c> existingProposalList = new List<Apttus_Proposal__Proposal__c>();
        Map<Id, Set<Id>> bidHistoryToProposalIdMap = new Map<Id, Set<Id>>();
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID) {
                if ((budget.Bid_Sent_Date__c != oldRecordsMap.get(budget.Id).Bid_Sent_Date__c && budget.Bid_Sent_Date__c != null) ||
                    (((budget.Apttus_Proposal__Primary__c != oldRecordsMap.get(budget.Id).Apttus_Proposal__Primary__c && budget.Apttus_Proposal__Primary__c == true)
                    || (budget.Bid_Sent_Date__c != oldRecordsMap.get(budget.Id).Bid_Sent_Date__c && budget.Bid_Sent_Date__c != null) 
                    || (budget.Bid_Sent__c != oldRecordsMap.get(budget.Id).Bid_Sent__c && budget.Bid_Sent__c != null)) &&
                    budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.PRESENTED)) {
                    
                    if (budget.Clinical_Bid__c != null) {
                        clinicalBidIdSet.add(budget.Clinical_Bid__c);
                    }
                    if (budget.Apttus_Proposal__Opportunity__c != null) {
                        opportunityIdSet.add(budget.Apttus_Proposal__Opportunity__c);
                    }
                } else if ((budget.RFP_Scenario__c != CON_CPQ.INACTIVE && oldRecordsMap.get(budget.Id).RFP_Scenario__c == CON_CPQ.INACTIVE) || (budget.RFP_Scenario__c == CON_CPQ.INACTIVE && oldRecordsMap.get(budget.Id).RFP_Scenario__c != CON_CPQ.INACTIVE)) {
                    if (budget.Clinical_Bid__c != null) {
                        clinicalBidIdSet.add(budget.Clinical_Bid__c);
                    }
                }
            }
        }
        if (clinicalBidIdSet.size() > 0) {
            clinicalBidIdMap = new SLT_Bid_History().getBidHistoriesById(clinicalBidIdSet, new Set<String>{CON_CPQ.ID, CON_CPQ.CURRENCYISOCODE});
            String conditon = 'Clinical_Bid__c IN : clinicalBidIds AND RFP_Scenario__c != \''+CON_CPQ.INACTIVE+ '\' AND Apttus_Proposal__Proposal_Category__c IN (\'' + CON_CPQ.INITIAL + '\',\'' + CON_CPQ.REBID + '\')';
            existingProposalList = new SLT_Proposal().getQuoteByParentClinicalBid(clinicalBidIdSet, new Set<String> {CON_CPQ.ID, CON_CPQ.PROPOSAL_CATEGORY, CON_CPQ.APTTUS_PROPOSAL_PARENT_BID}, conditon);
        }
        if (opportunityIdSet.size() > 0) {
            opportunityIdMap = new SLT_Opportunity().getOpportunityById(opportunityIdSet, new Set<String>{CON_CPQ.ID, CON_CPQ.OPPORTUNITY_STAGENAME});
        }
        
        for (Apttus_Proposal__Proposal__c budget : existingProposalList) {
            if (bidHistoryToProposalIdMap.containsKey(budget.Clinical_Bid__c)) {
                Set<Id> temp = bidHistoryToProposalIdMap.get(budget.Clinical_Bid__c);
                temp.add(budget.Id);
                bidHistoryToProposalIdMap.put(budget.Clinical_Bid__c, temp);
            } else {
                bidHistoryToProposalIdMap.put(budget.Clinical_Bid__c, new Set<Id>{budget.Id});
            }
        }
        Set<String> budgetToClinicalSyncFieldSet = new Set<String>();
        Set<String> budgetToClinicalSyncCurrencyFieldSet = new Set<String>();
        
        for (Schema.FieldSetMember fields : Schema.SObjectType.Apttus_Proposal__Proposal__c.fieldSets.getMap().get(CON_CPQ.QUOTE_FIELDSET_BUDGET_TO_CLINICAL_BID_SYNC).getFields()) {
            budgetToClinicalSyncFieldSet.add(fields.getFieldPath());
            if (fields.getType() == Schema.DisplayType.Currency) {
                budgetToClinicalSyncCurrencyFieldSet.add(fields.getFieldPath());
            }
        }
        Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new SLT_CurrencyType().getAllCurrencyTypeByIsoCode();

        List<Bid_History__c> clinicalBidList = new List<Bid_History__c>();
        fflib_SObjectUnitOfWork uowBidHistory = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Bid_History__c.SobjectType
            }
        );
        Boolean flag;
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            Bid_History__c clinicalBid = new Bid_History__c(Id = budget.Clinical_Bid__c);
            flag = false;
            if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID) {
                if (budget.RFP_Scenario__c != CON_CPQ.INACTIVE && oldRecordsMap.get(budget.Id).RFP_Scenario__c == CON_CPQ.INACTIVE) {
                    flag = true;
                    if (budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.ACCEPTED && budget.Apttus_QPConfig__ConfigurationFinalizedDate__c != null) {
                        clinicalBid.Related_Quote_Status__c = CON_CPQ.READY_TO_AWARD;
                    } else {
                        clinicalBid.Related_Quote_Status__c = CON_CPQ.NOT_READY_TO_AWARD;
                    }
                    clinicalBid.Related_Quote_Id__c = budget.Id;
                } else if (budget.RFP_Scenario__c == CON_CPQ.INACTIVE && oldRecordsMap.get(budget.Id).RFP_Scenario__c != CON_CPQ.INACTIVE) {
                    flag = true;
                    clinicalBid.Related_Quote_Id__c = '';
                    if (bidHistoryToProposalIdMap.containsKey(budget.Clinical_Bid__c) && bidHistoryToProposalIdMap.get(budget.Clinical_Bid__c).size() > 0) {
                        clinicalBid.Related_Quote_Status__c = CON_CPQ.NOT_READY_TO_AWARD;
                        if (bidHistoryToProposalIdMap.get(budget.Clinical_Bid__c).size() == 1) {
                            clinicalBid.Related_Quote_Id__c = bidHistoryToProposalIdMap.get(budget.Clinical_Bid__c).iterator().next();
                        }
                    } else {
                        clinicalBid.Related_Quote_Status__c = 'No Quote Created';
                    }
                }
                
                if ((budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.PRESENTED && ((budget.Apttus_Proposal__Primary__c != oldRecordsMap.get(budget.Id).Apttus_Proposal__Primary__c && budget.Apttus_Proposal__Primary__c == true)
                    || (budget.Bid_Sent_Date__c != oldRecordsMap.get(budget.Id).Bid_Sent_Date__c && budget.Bid_Sent_Date__c != null) 
                    || (budget.Bid_Sent__c != oldRecordsMap.get(budget.Id).Bid_Sent__c && budget.Bid_Sent__c != null)))  ||
                    (oldRecordsMap.get(budget.Id).Apttus_Proposal__Approval_Stage__c == CON_CPQ.GENERATED && budget.Bid_Sent_Date__c != oldRecordsMap.get(budget.Id).Bid_Sent_Date__c && budget.Bid_Sent_Date__c != null)) {
                        
                    flag = true;
                    String clinicalBidCurrency = CON_CPQ.USD;
                    if (clinicalBidIdMap != null && clinicalBidIdMap.containsKey(budget.Clinical_Bid__c)) {
                        clinicalBidCurrency = clinicalBidIdMap.get(budget.Clinical_Bid__c).CurrencyIsoCode;
                    }
                    for(string fieldName: budgetToClinicalSyncFieldSet) {
                        if(fieldName == CON_CPQ.BOTTOM_LINE_DISCOUNT_AMOUNT) {  
                            clinicalBid.put(CON_CPQ.BOTTOM_LINE_LABOUR_DISCOUNT,
                                Math.abs(CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(clinicalBidCurrency).conversionRate, 
                                isoCodeTocurrencyTypeMap.get(budget.CurrencyIsoCode).conversionRate, (double)budget.get(fieldName))));
                        } else if (fieldName == CON_CPQ.NUMBER_OF_SCENARIO) {
                            clinicalBid.put(CON_CPQ.FINAL_NUMBER_OF_SCENARIO, budget.get(fieldName));
                        } else {
                            if(budgetToClinicalSyncCurrencyFieldSet.contains(fieldName)) {
                                clinicalBid.put(fieldName,
                                    CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(clinicalBidCurrency).conversionRate, 
                                    isoCodeTocurrencyTypeMap.get(budget.CurrencyIsoCode).conversionRate, (double)budget.get(fieldName)));
                            } else {
                                clinicalBid.put(fieldName, budget.get(fieldName));
                            }
                        }
                    }
                    if (bidHistoryToProposalIdMap.containsKey(budget.Clinical_Bid__c) && bidHistoryToProposalIdMap.get(budget.Clinical_Bid__c).size() == 1) {
                        clinicalBid.Related_Quote_Status__c = CON_CPQ.READY_TO_AWARD;
                    }
                    
                    if(opportunityIdMap != null && opportunityIdMap.containsKey(budget.Apttus_Proposal__Opportunity__c) && CON_CPQ.OPPORTUNITY_STAGES.contains(opportunityIdMap.get(budget.Apttus_Proposal__Opportunity__c).StageName) && budget.Apttus_Proposal__Primary__c == true) {
                        try {
                            QUE_CPQ_SyncBudgetWithOpportunity syncBudgetWithOpportunityJob = new QUE_CPQ_SyncBudgetWithOpportunity(budget.Id, True);
                            Id jobId = System.enqueueJob(syncBudgetWithOpportunityJob);
                        }
                        catch(Exception ex) {
                            String errorMessage = ex.getMessage() + '\n' + ex.getStackTraceString();
                            CPQ_Utility.createApexErrorLogRecord(budget.Id, errorMessage, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
                        }
                    }
                }
            }
            if (flag) {
                clinicalBidList.add(clinicalBid);
            }
        }
        if(clinicalBidList.size() > 0) {
            uowBidHistory.registerDirty(clinicalBidList);
            uowBidHistory.commitWork();
        } 
    }
    
    public static void createAdminTimeEntryData(List<Apttus_Proposal__Proposal__c> newList, Map<Id, Apttus_Proposal__Proposal__c> oldMap) {
        Set<Id> budgetIdSet = new Set<Id>();
        Map<Id, Apttus_Proposal__Proposal__c> proposalMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        Map<Id, Opportunity> opportunityIdMap = new Map<Id, Opportunity>();
        Set<Id> oppIdSet = new Set<Id>();
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Set<String> opp5To8StageSet = new Set<String>();
        opp5To8StageSet.add(CON_CRM.FINALIZING_DEAL_STAGE);
        opp5To8StageSet.add(CON_CRM.RECEIVED_ATP_STAGE);
        opp5To8StageSet.add(CON_CRM.CLOSED_WON_STAGE);
        opp5To8StageSet.add(CON_CRM.IN_HAND_STAGE);
        
        for (Apttus_Proposal__Proposal__c budget : newList) {
            if ((budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL 
                || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID 
                    || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC
                    || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER 
                    || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY)
                    && budget.Select_Pricing_Tool__c == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT 
                    && budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.ACCEPTED 
                    && oldMap.get(budget.Id).Apttus_Proposal__Approval_Stage__c != budget.Apttus_Proposal__Approval_Stage__c) {
                proposalMap.put(budget.Id, budget);
                    
                if (budget.Apttus_Proposal__Opportunity__c != null && (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL
                    || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID
                        || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC
                        || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER)) {
                    oppIdSet.add(budget.Apttus_Proposal__Opportunity__c); 
                    proposalList.add(budget);
                }
            }
        }
        
        if (oppIdSet.size() > 0) {
            opportunityIdMap = new SLT_Opportunity().getOpportunityById(oppIdSet, new Set<String>{CON_CPQ.ID, CON_CPQ.OPPORTUNITY_STAGENAME});
            
            for (Apttus_Proposal__Proposal__c budget : proposalList) {
                if (opportunityIdMap.containsKey(budget.Apttus_Proposal__Opportunity__c)) {
                    Opportunity opp = opportunityIdMap.get(budget.Apttus_Proposal__Opportunity__c);
                    
                    if (((opp.StageName == CON_CRM.CLOSED_WON_STAGE || opp.StageName == CON_CRM.IN_HAND_STAGE) && (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC
                        || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER)) || ((budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL
                            || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID) && opp5To8StageSet.contains(opp.StageName))) {
                        opp.RM_Sync_Date__c = System.now();
                        oppList.add(opp);
                    }
                }
            }
        }
        if (oppList.size() > 0) {
            UTL_ExecutionControl.stopTriggerExecution = true;
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<SObjectType> { Opportunity.SObjectType }
            );
            uow.registerDirty(oppList);
            uow.commitWork();
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
        budgetIdSet = proposalMap.keySet();
        
        if (budgetIdSet.size() > 0) {
            if (System.isBatch()) {
                CPQ_RMUtility.createAdminTimeEntryQuoteData(proposalMap);
                CPQ_RMUtility.createTimelineAndPhaseQuoteData(budgetIdSet, true, true);
                CPQ_RMUtility.createClinicalVisitFrequencyQuoteData(budgetIdSet);
            } else {
                System.enqueueJob(new QUE_CPQ_TimelineDataJob(budgetIdSet));
            }
        }
    }
    
    /**
     * Set the Related Agreement field of Initial/Rebid quote blank if project specific quote exists.
     * @param budgets List of Proposal records
     * @return none
     */
    public static void removeInitialOrRebidRelatedAgreement(List<Apttus_Proposal__Proposal__c> budgets) {
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal__c> updatedProposalList = new List<Apttus_Proposal__Proposal__c>();
        Set<Id> clinicalBidId = new Set<Id>();
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC) {
																																								 
                clinicalBidId.add(budget.Clinical_Bid__c);
            }
        }
        if (clinicalBidId.size() > 0) {
            proposalList = new SLT_Proposal().getProposalByParentClinicalBidAndBudgetType(clinicalBidId, new Set<String> {CON_CPQ.INITIAL, CON_CPQ.REBID, CON_CPQ.PRELIMINARY},
                               new Set<String> {CON_CPQ.ID, CON_CPQ.PROPOSAL_CATEGORY, CON_CPQ.REALTED_AGREEMENT});
            if (proposalList.size() > 0) {
                for (Apttus_Proposal__Proposal__c proposal : proposalList) {
                    if (proposal.Apttus_QPComply__MasterAgreementId__c != null) {
                        proposal.Apttus_QPComply__MasterAgreementId__c = null;
                        updatedProposalList.add(proposal);
                    }
                }                
                if (updatedProposalList.size() >0) {
                    update updatedProposalList;
                }
            }
        }
    }
    
    public static void setNumberFormatForBudget(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (oldRecordsMap == null ||
                (oldRecordsMap != null &&
                (budget.Total_IQVIA_Fees__c != oldRecordsMap.get(budget.Id).Total_IQVIA_Fees__c 
                || budget.Total_Expenses_Other__c != oldRecordsMap.get(budget.Id).Total_Expenses_Other__c
                || budget.Total_IQVIA_Fees_Bottom_Line_Discount__c != oldRecordsMap.get(budget.Id).Total_IQVIA_Fees_Bottom_Line_Discount__c 
                || budget.Total_IQVIA_Fees_BID__c != oldRecordsMap.get(budget.Id).Total_IQVIA_Fees_BID__c 
                || budget.Includes_Estimated_Inflation_of__c != oldRecordsMap.get(budget.Id).Includes_Estimated_Inflation_of__c ))) {
                            
                    budget.Total_IQVIA_Fees_BID__c = budget.Total_IQVIA_Fees_BID__c == null ? 0 : budget.Total_IQVIA_Fees_BID__c.setScale(2);
                    budget.Total_IQVIA_Fees__c = budget.Total_IQVIA_Fees__c == null ? 0 : budget.Total_IQVIA_Fees__c.setScale(2);
                    budget.Total_INV_Grants__c = budget.Total_INV_Grants__c == null ? 0 : budget.Total_INV_Grants__c.setScale(2);
                    budget.Total_Expenses_Other__c = budget.Total_Expenses_Other__c == null ? 0 : budget.Total_Expenses_Other__c.setScale(2);
                    budget.Total_IQVIA_Fees_Bottom_Line_Discount__c = budget.Total_IQVIA_Fees_Bottom_Line_Discount__c == null ? 0 : budget.Total_IQVIA_Fees_Bottom_Line_Discount__c.setScale(2);
                    budget.Includes_Estimated_Inflation_of__c = budget.Includes_Estimated_Inflation_of__c == null ? 0 : budget.Includes_Estimated_Inflation_of__c.setScale(2);
            } 
        }
    }
    
    public static void createTeamMemberForPL(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap)
    {
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        Set<Id> agreementIds = new Set<Id>();
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if ((budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC
                 || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER
                 || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY)
                 && budget.Apttus_QPComply__MasterAgreementId__c != null) {
                    agreementIds.add(budget.Apttus_QPComply__MasterAgreementId__c);
                    proposalList.add(budget);
            }
        }
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.IQVIA_PROJECT_MANAGER, CON_CPQ.RELATED_SALESFORCE_USER_IQVIA_PROJECT_MANAGER};
        Map<Id, Apttus__APTS_Agreement__c> agrmtMap = new Map<Id, Apttus__APTS_Agreement__c>(new SLT_Agreement().selectAgreementById(agreementIds, fieldSet));
        List<Team_Member__c> teamMembers  = new List<Team_Member__c>();
        for(Apttus_Proposal__Proposal__c proposal : proposalList) {
            Apttus__APTS_Agreement__c agrmt = agrmtMap.get(proposal.Apttus_QPComply__MasterAgreementId__c);
            if(agrmt != null && agrmt.IQVIA_Project_Manager_Con__c!= null) {
                Team_Member__c teamMember = new Team_Member__c(Member_Role__c = CON_CPQ.APPROVER,
                                                               Contact__c = agrmt.IQVIA_Project_Manager_Con__c, 
                                                               User__c = agrmt.IQVIA_Project_Manager_Con__r.pse__Salesforce_User__c, 
                                                               Proposal__c = proposal.Id, Role_From_RR__c = CON_CPQ.APPROVER_GROUP_PL);
                teamMembers.add(teamMember);
            }
        }
        if (teamMembers.size() > 0) {
            try {
                insert teamMembers; 
            }
            catch (DmlException ex) {
                String errorMessage = ex.getDmlMessage(0) + '\n' + ex.getStackTraceString();
                throw new AuraHandledException('Error Exception happend' + ex.getDmlMessage(0));
            }
        }
    }
    
    public static List<Apttus_Proposal__Proposal__c> getRDSProposalRecords(List<Apttus_Proposal__Proposal__c> budgets) {
        List<Apttus_Proposal__Proposal__c> proposalRecords = new List<Apttus_Proposal__Proposal__c>();
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (CPQ_Utility.proposalBudgetRecordTypeId == budget.RecordTypeId) {
                proposalRecords.add(budget);
            }
        }
        return proposalRecords;
    }
    public static List<Apttus_Proposal__Proposal__c> getRDSNonSFProposalRecords(List<Apttus_Proposal__Proposal__c> budgets) {
        List<Apttus_Proposal__Proposal__c> proposalRecords = new List<Apttus_Proposal__Proposal__c>();
        for(Apttus_Proposal__Proposal__c budget : budgets) {
            if (CPQ_Utility.proposalRDSNonSFRecordTypeId == budget.RecordTypeId) {
                proposalRecords.add(budget);
            }
        }
        return proposalRecords;
    }
    public static List<Apttus_Proposal__Proposal__c> getTSProposalRecords(List<Apttus_Proposal__Proposal__c> budgets) {
        List<Apttus_Proposal__Proposal__c> proposalRecords = new List<Apttus_Proposal__Proposal__c>();
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (CPQ_Utility.proposalTechSolutionRecordTypeId == budget.RecordTypeId) {
                proposalRecords.add(budget);
            }
        }
        return proposalRecords;
    }
    
    /**
     * Update the Prelim or Project Specific CLM Agreement on SF/Non SF Quote/Proposal
     * @param budgets List of Proposal records
     * @param oldRecordsMap old map from trigger 
     * @return List of Quote/Proposal
     */
    public static void updateRelatedAgreement(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        Set<Id> oppertunityIdSet = new Set<Id>();
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC) {
                oppertunityIdSet.add(budget.Apttus_Proposal__Opportunity__c);
            }
        }
        if (oppertunityIdSet.size() > 0) {
            String whereClouse = 'Apttus__Related_Opportunity__c in :opportunityIdSet AND Apttus__Status_Category__c IN  (\'' + CON_CPQ.REQUEST + '\',\'' + CON_CPQ.CATEGORY_IN_BUDGETING + '\',\'' + CON_CPQ.IN_AUTHORING + '\',\'' + CON_CPQ.IN_APPROVAL + '\',\'' + CON_CPQ.IN_SIGNATURES+ '\')';
            Map<Id, Apttus__APTS_Agreement__c> relatedAgreementMap = new SLT_APTS_Agreement().getBudgetsRelatedToOpportunity(oppertunityIdSet, 
                                                                                                                             new Set<String>{ CON_CPQ.Id,CON_CPQ.Name, CON_CPQ.RELATED_OPPORTUNITY, CON_CPQ.RECORD_TYPE_ID, CON_CPQ.AGREEMENT_STATUS_CATEGORY, CON_CPQ.AGREEMENT_STATUS}, whereClouse);
            Map<Id, List<Apttus__APTS_Agreement__c>> opportunityIdToAgreementMap = new Map<Id, List<Apttus__APTS_Agreement__c>>();
            for (Id agreementId : relatedAgreementMap.keySet()) {
                Apttus__APTS_Agreement__c agreement = relatedAgreementMap.get(agreementId);
                if (opportunityIdToAgreementMap.containsKey(agreement.Apttus__Related_Opportunity__c)) {
                    opportunityIdToAgreementMap.get(agreement.Apttus__Related_Opportunity__c).add(agreement);
                } else {
                    opportunityIdToAgreementMap.put(agreement.Apttus__Related_Opportunity__c, new List<Apttus__APTS_Agreement__c>{agreement});
                }
            }
            
            for (Apttus_Proposal__Proposal__c budget : budgets) {
                if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC) {
                    List<Apttus__APTS_Agreement__c> agreementList = opportunityIdToAgreementMap.get(budget.Apttus_Proposal__Opportunity__c);
                    if (agreementList!=null && !agreementList.isEmpty()) {
                        for (Apttus__APTS_Agreement__c relatedAgreement : agreementList) {
                            if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY && relatedAgreement.RecordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID) {
                                budget.Apttus_QPComply__MasterAgreementId__c = relatedAgreement.Id;
                                break;
                            } else if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC && relatedAgreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID) {
                                budget.Apttus_QPComply__MasterAgreementId__c = relatedAgreement.Id;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
	/**
     * Update Budget amount fields based on formula
     * @param budgets List of Proposal records
     * @param oldRecordsMap old map from trigger 
     */
    public static void setBudgetAmountFields(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if ((budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL 
                 || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID 
                 || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC) &&
                (Trigger.isUpdate 
                 && (oldRecordsMap.get(budget.Id).Total_IQVIA_Fees_Bottom_Line_Discount__c != budget.Total_IQVIA_Fees_Bottom_Line_Discount__c ||
                     oldRecordsMap.get(budget.Id).Total_IQVIA_Fees__c != budget.Total_IQVIA_Fees__c ||
                     oldRecordsMap.get(budget.Id).Professional_Fees_Variance__c != budget.Professional_Fees_Variance__c ||
                     oldRecordsMap.get(budget.Id).Q2_Sol_Prof_Fees__c != budget.Q2_Sol_Prof_Fees__c))) {
                         budget.Actual_Quote_Amount__c = (budget.Total_IQVIA_Fees_Bottom_Line_Discount__c == null ? 0 : budget.Total_IQVIA_Fees_Bottom_Line_Discount__c)
                             + (budget.Total_IQVIA_Fees__c == null ? 0 : budget.Total_IQVIA_Fees__c)
                             + (budget.Professional_Fees_Variance__c == null ? 0 : budget.Professional_Fees_Variance__c)
                             - (budget.Q2_Sol_Prof_Fees__c == null ? 0 : budget.Q2_Sol_Prof_Fees__c );
            }
            if ((budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL 
                 || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID 
                 || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC) 
                && (Trigger.isUpdate 
                    && (oldRecordsMap.get(budget.Id).Total_INV_Grants__c != budget.Total_INV_Grants__c ||
                        oldRecordsMap.get(budget.Id).Total_Expenses_Other__c != budget.Total_Expenses_Other__c ||
                        oldRecordsMap.get(budget.Id).Expenses_Variance__c != budget.Expenses_Variance__c ||
                        oldRecordsMap.get(budget.Id).Q2_Sol_Expenses__c != budget.Q2_Sol_Expenses__c))) {
                            budget.Project_Expense__c = (budget.Total_INV_Grants__c == null ? 0 : budget.Total_INV_Grants__c)
                                + (budget.Total_Expenses_Other__c == null ? 0 : budget.Total_Expenses_Other__c)
                                + (budget.Expenses_Variance__c == null ? 0 : budget.Expenses_Variance__c)
                                - (budget.Q2_Sol_Expenses__c == null ? 0 : budget.Q2_Sol_Expenses__c );
                        }
        }
    }
    /**
     * Update Generic Contract status if quote created from it
     * @param budgets List of Proposal records
     */
    
    public static void updateGenericContract(List<Apttus_Proposal__Proposal__c> budgets) {
        Set<Id> relatedContractIdSet = new Set<Id>();
        List<Contract> relatedContractList = new List<Contract>();
        
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if(budget.Contract__c != null) {
                relatedContractIdSet.add(budget.Contract__c);
            }
        }
        if(relatedContractIdSet.size() > 0) {
            relatedContractList = new SLT_Contract().fetchContract(relatedContractIdSet, new Set<String> {CON_CPQ.STATUS});             
            for (Contract contract : relatedContractList) {
                contract.Status = CON_CPQ.CLOSED_FOR_INTERNAL_PURPOSES;
            }
        }
        if(relatedContractList.size() > 0) {
            update relatedContractList;
        }
    }
    
    public static void validationOnInactiveBudgets(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap){
        List<GroupMember> groupMemberList = new SLT_GroupMember().getGroupMemberByUserAndGroupDeveloperName(UserInfo.getUserId(), CON_CPQ.CPQ_ADMIN_USERS_FOR_INACTIVE_QUOTES);
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (oldRecordsMap.get(budget.Id).RFP_Scenario__c == CON_CPQ.INACTIVE && oldRecordsMap.get(budget.Id).RFP_Scenario__c == budget.RFP_Scenario__c) {
                if((oldRecordsMap.get(budget.Id).Apttus_Proposal__Approval_Stage__c != CON_CPQ.DRAFT && budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.DRAFT) 
                    || (oldRecordsMap.get(budget.Id).Approval_Status__c != CON_CPQ.NONE && budget.Approval_Status__c == CON_CPQ.NONE)) {
                    // do nothing
                } else {
                    budget.addError(CON_CPQ.ERROR_MSG_FOR_INACTIVE_BUDGET);
                }
            }
            else if (groupMemberList.isEmpty() &&
                    ((oldRecordsMap.get(budget.Id).RFP_Scenario__c == CON_CPQ.INACTIVE 
                    && oldRecordsMap.get(budget.Id).RFP_Scenario__c != budget.RFP_Scenario__c)
                    || (budget.RFP_Scenario__c == CON_CPQ.INACTIVE 
                    && oldRecordsMap.get(budget.Id).RFP_Scenario__c != budget.RFP_Scenario__c)))
            {
                budget.addError(CON_CPQ.ERROR_MSG_FOR_INACTIVE_BUDGET);
            }
        }
    }
    
    public static void resetCNFBudgetStatus(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        Set<Id> rejectedBudgetIdSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, Opportunity> idToOpp = new Map<Id, Opportunity>();
        for(Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Apttus_Proposal__Opportunity__c != null && (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK)) {
                oppIdSet.add(budget.Apttus_Proposal__Opportunity__c);
            }
        }
        if (oppIdSet.size() > 0) {
            idToOpp = new SLT_Opportunity().getOpportunityById(oppIdSet, new Set<String>{CON_CPQ.ID, CON_CPQ.OPPORTUNITY_STAGENAME});
        }
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if ((budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK) && budget.CNF_Status__c != oldRecordsMap.get(budget.Id).CNF_Status__c) {
                if (budget.CNF_Status__c == CON_CPQ.REJECTED || budget.CNF_Status__c == CON_CPQ.ON_HOLD) {
                    if(CPQ_Utility.proposalRDSNonSFRecordTypeId == budget.RecordTypeId) {
                        budget.Approval_Status__c = CON_CPQ.NONE;
                    }
                    else {
                        /* Commented Under LC-11450
                        budget.Approval_Status__c = CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW;
                        */
                        budget.Approval_Status__c = CON_CPQ.NONE;
                    }
                    budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
                    rejectedBudgetIdSet.add(budget.Id);
                } else if (budget.CNF_Status__c == CON_CPQ.ACCEPTED) {
                    if (idToOpp.containsKey(budget.Apttus_Proposal__Opportunity__c) && (CON_CPQ.OPPORTUNITY_STAGES.contains(idToOpp.get(budget.Apttus_Proposal__Opportunity__c).StageName) || idToOpp.get(budget.Apttus_Proposal__Opportunity__c).StageName == CON_CPQ.OPPORTUNITY_STAGE_7B_CLOSED_LOST)) {
                        budget.addError('The Opportunity is either at stage 7b-lost or stage should be 5 or higher to Accept the Budget.');
                    } else if (CPQ_Utility.proposalBudgetRecordTypeId == budget.RecordTypeId && budget.Apttus_QPConfig__ConfigurationFinalizedDate__c == null) {
                        budget.addError('Please Finalize the Budget');
                    } else if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK && budget.CNF_Approval_Date__c == null) {
                        budget.addError('Note!!! Please enter the Approval/Rejected/Completion Date and Status(Accepted) to move to Accepted stage.');
                    } else if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF && (budget.CNF_Approval_Date__c == null || budget.Change_Order_Number__c == null)) {
                        budget.addError('Please enter the Approval/Rejected/Completion Date, Status(Accepted) and Change Order Number to move to Accepted stage.');
                    } else {
                        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.ACCEPTED;
                    }
                }
            }
        }
        ProcessInstanceWorkitem[] workItems = new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemByTargetIdAndStatus(rejectedBudgetIdSet,CON_CPQ.PENDING, new Set<String>{CON_CPQ.Id});
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
		for (ProcessInstanceWorkitem workItem: workItems) 
        {
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setAction(CON_CPQ.REMOVED);
            pwr.setWorkItemId(workItem.id);
            requests.add(pwr);
        }
        Approval.ProcessResult[] results = Approval.process(requests,false);
    }
	
    public static void setBudgetLink(List<Apttus_Proposal__Proposal__c> newProposalList, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        Map<Id, Apttus_Proposal__Proposal__c> boxFolderRecordIdMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        Map<Apttus_Proposal__Proposal__c, String> boxFolderPathQuoteMap = new Map<Apttus_Proposal__Proposal__c, String>();
        CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
        String boxDefaultPath = cpqSetting.Box_Path__c;
        for (Apttus_Proposal__Proposal__c budget : newProposalList) {
            // set Status change date with respect to Budget Type and Status
            if ((Trigger.isInsert && (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.Ballpark) )
                || (Trigger.isUpdate && (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.Ballpark) 
                    && oldRecordsMap.get(budget.Id).CNF_Status__c != budget.CNF_Status__c )) {
                        budget.Status_Change_Date__c = System.today();
                    }
            if (oldRecordsMap == null || (budget.Budget_Tool_Version_Date__c != null && budget.Budget_Tool_Version_Date__c != oldRecordsMap.get(budget.Id).Budget_Tool_Version_Date__c)) {
                if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL
                    || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID)
                {
                    boxFolderRecordIdMap.put(budget.Clinical_Bid__c, budget);
                }
                else if(budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC
                        || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER
                        || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY)
                {
                    boxFolderRecordIdMap.put(budget.Apttus_QPComply__MasterAgreementId__c, budget);
                }
                else {
                    boxFolderRecordIdMap.put(budget.Id, budget);
                }
                boxFolderPathQuoteMap.put(budget, boxDefaultPath);
            }
        }
        if (boxFolderRecordIdMap.size() > 0) {
            List<box__FRUP__c> boxFolderList = new SLT_FRUP().getFRUPRecordsByBoxRecordId(boxFolderRecordIdMap.keySet(),new Set<String>{CON_CPQ.BOX_FOLDER_ID, CON_CPQ.BOX_RECORD_ID},
                'box__Record_ID__c IN: boxRecordIds');
            for(box__FRUP__c boxFolder : boxFolderList){
                boxFolderPathQuoteMap.put(boxFolderRecordIdMap.get(boxFolder.box__Record_ID__c), boxDefaultPath.replace('0', boxFolder.box__Folder_ID__c));
            }
        }
        for (Apttus_Proposal__Proposal__c quote : boxFolderPathQuoteMap.keySet()) {
            if (quote.Budget_Tool_Version_Date__c >= cpqSetting.SFC_Template_Date__c) {
                quote.External_Link__c = boxFolderPathQuoteMap.get(quote);
            }
            else {
                quote.External_Link__c = CON_CPQ.BLANK;
            }
        }
    }
    
    // Reset CO linking from rejected CNF budget
    public static void resetCOLinkingFromRejectedCNF(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF
                && budget.CNF_Status__c != oldRecordsMap.get(budget.Id).CNF_Status__c
                && budget.CNF_Status__c == CON_CPQ.REJECTED) {
                    budget.Related_Change_Order__c = null;
                }
        }
    }
    
    // Update Amount on Budget
    public static void setAmount(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        Set<Id> budgetIds = new Set<Id>();
        
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.FINALIZED 
                && (budget.Select_Pricing_Tool__c == CON_CPQ.OCE || budget.Select_Pricing_Tool__c == CON_CPQ.AMESA)) {
                    budgetIds.add(budget.Id);
                }
        }
        
        if (budgetIds.size() > 0) {
            Map<Id, Decimal> proposalAmountMap = new Map<Id, Decimal>();
            Map<Id, Decimal> proposalBaseAmountMap = new Map<Id, Decimal>();
            Map<Id, Decimal> proposalProductCostMap = new Map<Id, Decimal>();
            Set<String> fieldSet = new Set<String> {CON_CPQ.APTTUS_PROPOSAL_PROPOSAL, CON_CPQ.QUOTE_LINE_ITEM_NETPRICE, CON_CPQ.QUOTE_LINE_ITEM_EXTENDEDPRICE, CON_CPQ.PROPOSAL_LINE_TYPE, CON_CPQ.CHARGE_TYPE};
            List<Apttus_Proposal__Proposal_Line_Item__c> proposallineItems = new SLT_ProposalLineItems().getProposalLineItemsByQuoteId(budgetIds, fieldSet);
            if (proposallineItems.size() > 0) {
                for (Apttus_Proposal__Proposal_Line_Item__c lineItem : proposallineItems) {
                    Decimal OCE_ProdutCost = 0.0;
                    if (lineItem.Apttus_QPConfig__ChargeType__c == CON_CPQ.SUBSCRIPTION_FEE) {
                        OCE_ProdutCost = lineItem.Apttus_QPConfig__ExtendedPrice__c *0.3;
                    }
                    else if (lineItem.Apttus_QPConfig__ChargeType__c == CON_CPQ.ADD_ON_PRICE) {
                        OCE_ProdutCost = lineItem.Apttus_QPConfig__ExtendedPrice__c *0.8;
                    }
                    else if (lineItem.Apttus_QPConfig__ChargeType__c == CON_CPQ.IMPLEMENTATION_FEE) {
                        OCE_ProdutCost = lineItem.Apttus_QPConfig__ExtendedPrice__c/2.5;
                    }
                    else if (lineItem.Apttus_QPConfig__ChargeType__c == CON_CPQ.SERVICE_FEE) {
                        OCE_ProdutCost = lineItem.Apttus_QPConfig__ExtendedPrice__c/2.5;
                    }
                    else {
                        OCE_ProdutCost = 0;
                    }
                    if (proposalAmountMap.containsKey(lineItem.Apttus_Proposal__Proposal__c)) {
                        
                        Decimal amount = proposalAmountMap.get(lineItem.Apttus_Proposal__Proposal__c);
                        Decimal baseAmount = proposalBaseAmountMap.get(lineItem.Apttus_Proposal__Proposal__c);
                        Decimal productCost = proposalProductCostMap.get(lineItem.Apttus_Proposal__Proposal__c);
                        amount += (lineItem.Apttus_QPConfig__NetPrice__c != null ? lineItem.Apttus_QPConfig__NetPrice__c : 0); 
                        baseAmount += (lineItem.Apttus_QPConfig__ExtendedPrice__c != null ? lineItem.Apttus_QPConfig__ExtendedPrice__c : 0);
                        productCost += OCE_ProdutCost;
                        proposalAmountMap.put(lineItem.Apttus_Proposal__Proposal__c, amount.setScale(2, RoundingMode.HALF_UP));
                        proposalBaseAmountMap.put(lineItem.Apttus_Proposal__Proposal__c, baseAmount.setScale(2, RoundingMode.HALF_UP));
                        proposalProductCostMap.put(lineItem.Apttus_Proposal__Proposal__c, productCost);
                        
                    } else {
                        proposalProductCostMap.put(lineItem.Apttus_Proposal__Proposal__c, OCE_ProdutCost);
                        proposalAmountMap.put(lineItem.Apttus_Proposal__Proposal__c, (lineItem.Apttus_QPConfig__NetPrice__c != null ? lineItem.Apttus_QPConfig__NetPrice__c : 0).setScale(2, RoundingMode.HALF_UP));
                        proposalBaseAmountMap.put(lineItem.Apttus_Proposal__Proposal__c, (lineItem.Apttus_QPConfig__ExtendedPrice__c != null ? lineItem.Apttus_QPConfig__ExtendedPrice__c : 0).setScale(2, RoundingMode.HALF_UP)); 
                    }
                }
            }
            
            if (proposalAmountMap.size() > 0) {
                
                for (Apttus_Proposal__Proposal__c budget : budgets) {
                    if (proposalAmountMap.containsKey(budget.Id)) {
                        budget.Total_Amount__c = (proposalAmountMap.get(budget.Id)).setScale(2, RoundingMode.HALF_UP);
                        budget.Total_Extended_Price__c = (proposalBaseAmountMap.get(budget.ID)).setScale(2, RoundingMode.HALF_UP);
                        budget.Apttus_Proposal__Discount_Percent__c = (((budget.Total_Extended_Price__c - budget.Total_Amount__c) / budget.Total_Extended_Price__c ) * 100).setScale(2, RoundingMode.HALF_UP);
                        budget.Actual_Discount_Value__c = (budget.Total_Extended_Price__c - budget.Total_Amount__c).setScale(2, RoundingMode.HALF_UP);
                    }
                    if (proposalProductCostMap.containsKey(budget.Id)) {
                        budget.Average_Gross_Margin__c = (((proposalAmountMap.get(budget.ID)-proposalProductCostMap.get(budget.ID))/proposalAmountMap.get(budget.ID)) * 100).setScale(2, RoundingMode.HALF_UP);
                    }
                }
            }
        }
    }
    
    public static void setUSDAmount(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        Set<Id> budgetIds = new Set<Id>();
        
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.FINALIZED && budget.Total_Amount__c != oldRecordsMap.get(budget.Id).Total_Amount__c
                && (budget.Select_Pricing_Tool__c == CON_CPQ.OCE || budget.Select_Pricing_Tool__c == CON_CPQ.AMESA)) {
                    budgetIds.add(budget.Id);
                }
        }
        
        if (budgetIds.size() > 0) {
           getPCGRIDRateCurrency(budgetIds); 
        }
    }
	
    @future
    public static void getPCGRIDRateCurrency(Set<Id> budgetIds) {
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.CURRENCYISOCODE, CON_CPQ.TOTAL_AMOUNT, CON_CPQ.TOTAL_AMOUNT_USD, CON_CPQ.TOTAL_BASE_AMOUNT_USD, CON_CPQ.TOTAL_BASE_AMOUNT, CON_CPQ.CONVERSION_DATE};
        List<Apttus_Proposal__Proposal__c> budgetRecords = new SLT_Proposal().getProposalsById(budgetIds, fieldSet);
        List<Apttus_Proposal__Proposal__c> budgetToUpdate = new List<Apttus_Proposal__Proposal__c>();
        Set<String> budgetCurrencyIsoCodeSet = new Set<String>();
        Set<Date> budgetConversionDateSet = new Set<Date>();
        
        for(Apttus_Proposal__Proposal__c budget : budgetRecords) {
            budgetCurrencyIsoCodeSet.add(budget.CurrencyIsoCode);
            budgetConversionDateSet.add(budget.Conversion_Date__c);
        }
        if (budgetCurrencyIsoCodeSet.contains(CON_CPQ.USD)) {
            budgetCurrencyIsoCodeSet.remove(CON_CPQ.USD);
        }
        if (!budgetCurrencyIsoCodeSet.contains(CON_CPQ.USD)) {    
            Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCodeBulk(budgetCurrencyIsoCodeSet, budgetConversionDateSet);       
            for (Apttus_Proposal__Proposal__c budget: budgetRecords) {
                if (isoCodeTocurrencyTypeMap != null && isoCodeTocurrencyTypeMap.containsKey(budget.CurrencyIsoCode + '&&&' + budget.Conversion_Date__c)) {
                    Currency_Exchange_Rates__c pcGridRate = isoCodeTocurrencyTypeMap.get(budget.CurrencyIsoCode + '&&&' + budget.Conversion_Date__c);
                    Currency_Exchange_Rates__c pcGridRateUSD = isoCodeTocurrencyTypeMap.get(CON_CPQ.USD + '&&&' + budget.Conversion_Date__c);
                    budget.Total_Amount_USD__c = CPQ_Utility.getCurrencyConvertedValue(pcGridRateUSD.Conversion_rate__c, pcGridRate.Conversion_rate__c, (double)budget.Total_Amount__c);
                    budget.Total_Base_Amount_USD__c = CPQ_Utility.getCurrencyConvertedValue(pcGridRateUSD.Conversion_rate__c, pcGridRate.Conversion_rate__c, (double)budget.Total_Extended_Price__c);
                    budgetToUpdate.add(budget);
                }  
            }
        } else {
            for (Apttus_Proposal__Proposal__c budget: budgetRecords) {
                budget.Total_Amount_USD__c = budget.Total_Amount__c;
                budget.Total_Base_Amount_USD__c = budget.Total_Extended_Price__c;
                budgetToUpdate.add(budget);
            }  
        }
        if (budgetToUpdate.size() > 0) {
             update budgetToUpdate;
        }
    }
	
    public static void setStageGeneratedToApproved(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.GENERATED &&
             oldRecordsMap.get(budget.Id).Apttus_Proposal__Approval_Stage__c == CON_CPQ.APPROVED) {
				budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.APPROVED;
				budget.Approval_Status__c = CON_CPQ.DOCUMENT_GENERATED;
            }
        }
    }
    
    // SetAccepted Date
    public static void setAcceptedDate(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.ACCEPTED &&
                oldRecordsMap.get(budget.Id).Apttus_Proposal__Approval_Stage__c != budget.Apttus_Proposal__Approval_Stage__c) {
                    budget.Accepted_Date__c = System.now();
            }
        }
    }
    
    public static void setProposalAddress(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        Set<Id> amesaBudgetIds = new Set<Id>();
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Select_Pricing_Tool__c == CON_CPQ.AMESA) {
                amesaBudgetIds.add(budget.Id);
            }
        }  
        if (amesaBudgetIds.size() > 0) {
            Map<String, Id> priceListNameToIdMap = new Map<String, Id>();
            List<Apttus_Config2__PriceList__c> priceLists = new SLT_PriceList().selectByNames(new Set<String>{CON_CPQ.MIDDLE_EAST_PRICE_LIST_EGP, CON_CPQ.AMESA_PRICE_LIST_TND, CON_CPQ.AMESA_PRICE_LIST_DZD, CON_CPQ.AMESA_PRICE_LIST_ZAR}, new Set<String>{CON_CPQ.ID, CON_CPQ.NAME});
            for(Apttus_Config2__PriceList__c priceList : priceLists){
                priceListNameToIdMap.put(priceList.Name, priceList.Id);
            }
            
            for (Apttus_Proposal__Proposal__c budget : budgets) {
                if (budget.Select_Pricing_Tool__c == CON_CPQ.AMESA && ( oldRecordsMap == null || budget.Apttus_QPConfig__PriceListId__c != oldRecordsMap.get(budget.Id).Apttus_QPConfig__PriceListId__c)) {
                    if(priceListNameToIdMap != null && priceListNameToIdMap.size() > 0){
                        if(priceListNameToIdMap.get(CON_CPQ.MIDDLE_EAST_PRICE_LIST_EGP) == budget.Apttus_QPConfig__PriceListId__c){
                            budget.Special_Pricing_Explanation_Comments__c = 'IQVIA Solutions Egypt Ltd.' + '\n' + 'Building S2B, Downtown Kattameya ' + '\n' + 'Road 90, 5th Settlement' + '\n' + 'New Cairo, Cairo' + '\n' + 'Egypt';
                        }
                        else if(priceListNameToIdMap.get(CON_CPQ.AMESA_PRICE_LIST_TND) == budget.Apttus_QPConfig__PriceListId__c){
                            budget.Special_Pricing_Explanation_Comments__c = 'IQVIA TECHNOLOGY Tunisia' + '\n' + 'RESIDENCE LA BAIE DU LAC ' + '\n' + 'CITE LES PINS - 1053' + '\n' + 'LES BERGES DU LAC 2 - TUNIS';
                        }
                        else if(priceListNameToIdMap.get(CON_CPQ.AMESA_PRICE_LIST_DZD) == budget.Apttus_QPConfig__PriceListId__c){
                            budget.Special_Pricing_Explanation_Comments__c = 'SARL PRA' + '\n' + 'CITE SELLIER ' + '\n' + 'COOPERATIVE IMMOBILIERE' + '\n' + 'MOHAMED BOUDIAF' + '\n' + 'N°18 - ETAGE1 - HYDRA - ALGER';
                        }
                        else if(priceListNameToIdMap.get(CON_CPQ.AMESA_PRICE_LIST_ZAR) == budget.Apttus_QPConfig__PriceListId__c){
                            budget.Special_Pricing_Explanation_Comments__c = 'IQVIA Solutions Pty Ltd' + '\n' + 'South Africa ' + '\n' + 'BCX building' + '\n' + 'Cnr John Vorster and Lenchen Rds' + '\n' + 'Centurion';
                        }
                        else {
                            budget.Special_Pricing_Explanation_Comments__c = 'I&A DATA PROPOSAL' + '\n' + 'IQVIA AG (“IQVIA”)' + '\n' + 'Erlenstrasse 4, 6343 Rotkreuz, Switzerland';
                        }
                    }
                }
            }
        }
    }
    
    //Update price list based on currency on proposal for OCE & AMESA
    public static void setPriceList(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        Set<String> setSelectedPricingTools = new Set<String>();   
        for (Apttus_Proposal__Proposal__c budgetNew : budgets) {
            if ((budgetNew.Select_Pricing_Tool__c == CON_CPQ.OCE || budgetNew.Select_Pricing_Tool__c == CON_CPQ.AMESA || budgetNew.Select_Pricing_Tool__c == CON_CPQ.Complete_Consent || budgetNew.Select_Pricing_Tool__c == CON_CPQ.Q2_Solutions) && oldRecordsMap.get(budgetNew.Id).CurrencyIsoCode != budgetNew.CurrencyIsoCode) {
                setSelectedPricingTools.add(budgetNew.Select_Pricing_Tool__c);
            }
        }
        if (setSelectedPricingTools.size() > 0) {
            Set<String> priceListNames = new Set<String>();
            Map<String, CPQ_Currency_PriceList_Mapping__mdt> mapCurrPriceLstByPricingTool = new Map<String, CPQ_Currency_PriceList_Mapping__mdt>();
            for(CPQ_Currency_PriceList_Mapping__mdt currencyPricelistMTDObj : [SELECT Id, CurrencyIsoCode__c, Price_List_Name__c, Pricing_Tool__c FROM CPQ_Currency_PriceList_Mapping__mdt WHERE Pricing_Tool__c IN :setSelectedPricingTools AND CurrencyIsoCode__c != null]) {
                priceListNames.add(currencyPricelistMTDObj.Price_List_Name__c);
                mapCurrPriceLstByPricingTool.put(currencyPricelistMTDObj.CurrencyIsoCode__c + '&&' +currencyPricelistMTDObj.Pricing_Tool__c, currencyPricelistMTDObj);
            }
            List<Apttus_Config2__PriceList__c> priceListNew = new SLT_PriceList().selectByNames(priceListNames, new Set<String> {CON_CPQ.ID, CON_CPQ.NAME});
            Map<String, Id> priceListMap = new Map<String, Id>();
            for (Apttus_Config2__PriceList__c priceObj : priceListNew) {
                priceListMap.put(priceObj.Name, priceObj.Id);
            }
            for (Apttus_Proposal__Proposal__c budgetNew : budgets) {
                if (oldRecordsMap.get(budgetNew.Id).CurrencyIsoCode != budgetNew.CurrencyIsoCode && setSelectedPricingTools.contains(budgetNew.Select_Pricing_Tool__c)) {
                    if (mapCurrPriceLstByPricingTool.containsKey(budgetNew.CurrencyIsoCode + '&&' + budgetNew.Select_Pricing_Tool__c) && priceListMap.containsKey(mapCurrPriceLstByPricingTool.get(budgetNew.CurrencyIsoCode + '&&' + budgetNew.Select_Pricing_Tool__c).Price_List_Name__c)) {
                        budgetNew.Apttus_QPConfig__PriceListId__c = priceListMap.get(mapCurrPriceLstByPricingTool.get(budgetNew.CurrencyIsoCode + '&&' + budgetNew.Select_Pricing_Tool__c).Price_List_Name__c);
                    } else {
                        budgetNew.addError('There is no respective price list exist for selected currency.');
                    }
                }
            }
        }
    }

    public static void setPriceListOnCartAndLineItems(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        Map<Id, Apttus_Proposal__Proposal__c> proposalIdsToUpdateCartAndLineItemsMap = new Map<Id, Apttus_Proposal__Proposal__c> ();
        for (Apttus_Proposal__Proposal__c budgetNew : budgets) {
            if ((budgetNew.Select_Pricing_Tool__c == CON_CPQ.Complete_Consent || budgetNew.Select_Pricing_Tool__c == CON_CPQ.Q2_Solutions) && oldRecordsMap.get(budgetNew.Id).CurrencyIsoCode != budgetNew.CurrencyIsoCode) {
                proposalIdsToUpdateCartAndLineItemsMap.put(budgetNew.Id, budgetNew);
            }
        }
        if (proposalIdsToUpdateCartAndLineItemsMap.size() > 0) {
            Map<Id, List<Apttus_Config2__LineItem__c>> lineItemListByProposalIdMap = new Map<Id, List<Apttus_Config2__LineItem__c>>();
            List<Apttus_Config2__LineItem__c> cliList = new SLT_LineItem().getLineItemsByProposalId(proposalIdsToUpdateCartAndLineItemsMap.keySet(), new Set<String>{CON_CPQ.ID, 'Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c'});
            for (Apttus_Config2__LineItem__c cli: cliList) {
                List<Apttus_Config2__LineItem__c> cliTempList = new List<Apttus_Config2__LineItem__c>();
                if (!lineItemListByProposalIdMap.containsKey(cli.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)) {
                    lineItemListByProposalIdMap.put(cli.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, cliTempList);
                }
                cliTempList = lineItemListByProposalIdMap.get(cli.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c);
                cliTempList.add(cli);
                lineItemListByProposalIdMap.put(cli.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, cliTempList);
            }
            List<Apttus_Config2__LineItem__c> cliToUpdateList = new List<Apttus_Config2__LineItem__c>();
            List<Apttus_Config2__ProductConfiguration__c> productCartToUpdateList = new List<Apttus_Config2__ProductConfiguration__c>();
            for (Id proposalId: lineItemListByProposalIdMap.keySet()) {
                Apttus_Config2__ProductConfiguration__c productCon = null;
                for (Apttus_Config2__LineItem__c cli: lineItemListByProposalIdMap.get(proposalId)) {
                    cli.CurrencyIsoCode = proposalIdsToUpdateCartAndLineItemsMap.get(proposalId).CurrencyIsoCode;
                    cli.Apttus_Config2__PricingStatus__c = CON_CPQ.PENDING;
                    cliToUpdateList.add(cli);
                    if (productCon == null) {
                        productCon = new Apttus_Config2__ProductConfiguration__c(Id = cli.Apttus_Config2__ConfigurationId__c);
                        productCon.Apttus_Config2__EffectivePriceListId__c = proposalIdsToUpdateCartAndLineItemsMap.get(proposalId).Apttus_QPConfig__PriceListId__c;
                        productCon.CurrencyIsoCode = proposalIdsToUpdateCartAndLineItemsMap.get(proposalId).CurrencyIsoCode;
                        productCartToUpdateList.add(productCon);
                    }
                }
            }
            if (productCartToUpdateList.size() > 0 && cliToUpdateList.size() > 0) {
                fflib_SObjectUnitOfWork uowCartAndLineItem = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus_Config2__LineItem__c.SobjectType, Apttus_Config2__ProductConfiguration__c.SobjectType
                    }
                );
                List<SObject> sObjectList = new List<SObject>();
                sObjectList.addAll(productCartToUpdateList);
                sObjectList.addAll(cliToUpdateList);

                uowCartAndLineItem.registerDirty(sObjectList);
                uowCartAndLineItem.commitWork();
            }
        }
    }

    public static void handleCNFLinking(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        
        Set<Id> oppIds = new Set<Id>();
        Set<String> coScenarios = new Set<String>();
        Set<String> cnfCONumbers = new Set<String>();
        Set<String> changeOrderIds = new Set<String>();
        
        Map<String, Id> scenarioToCOId = new Map<String, Id>();
        Map<Id, Set<String>> oppToCOs = new Map<Id, Set<String>>();
        Set<String> oppCoStage = new Set<String>(); 
        Map<String, List<Apttus_Proposal__Proposal__c>> cnfRecordsByScenario = new Map<String, List<Apttus_Proposal__Proposal__c>>();
        
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER && budget.RFP_Scenario__c != null) {
                if (Trigger.isUpdate && budget.RFP_Scenario__c != oldRecordsMap.get(budget.Id).RFP_Scenario__c) {
                    changeOrderIds.add(budget.Id);
                }
                if (budget.RFP_Scenario__c != null) {
                    coScenarios.add(budget.RFP_Scenario__c.replace((CON_CPQ.CHNAGE_ORDER + ' '), ''));
                }
            } else if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF) {
                cnfCONumbers.add((CON_CPQ.CHNAGE_ORDER + ' ') + budget.Change_Order_Number__c);
            }
            if ((budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER) && budget.Apttus_Proposal__Opportunity__c != null) {
                oppIds.add(budget.Apttus_Proposal__Opportunity__c);
            }
        }

        try {
            if (oppIds.size() > 0) {
                List<Apttus_Proposal__Proposal__c> recordsToUpdate = new List<Apttus_Proposal__Proposal__c>();

                for (Apttus_Proposal__Proposal__c budget : [SELECT Id, RFP_Scenario__c, Apttus_Proposal__Approval_Stage__c, Apttus_Proposal__Proposal_Category__c, Apttus_Proposal__Opportunity__c, Change_Order_Number__c, Related_Change_Order__c FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Proposal_Category__c IN ('Change Order', 'CNF') AND Apttus_Proposal__Opportunity__c IN: oppIds ORDER BY CreatedDate]) {
                    if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER) {
                        if ((cnfCONumbers.contains(budget.RFP_Scenario__c) || budget.Change_Order_Number__c != null) && budget.RFP_Scenario__c != null && !scenarioToCOId.containsKey(budget.Apttus_Proposal__Opportunity__c + ':' + budget.RFP_Scenario__c.replace((CON_CPQ.CHNAGE_ORDER + ' '), '')) && budget.Apttus_Proposal__Approval_Stage__c != CON_CPQ.CANCELLED_STATUS && budget.RFP_Scenario__c != CON_CPQ.INACTIVE) {
                            scenarioToCOId.put(budget.Apttus_Proposal__Opportunity__c + ':' + budget.RFP_Scenario__c.replace((CON_CPQ.CHNAGE_ORDER + ' '), ''), budget.Id);
                        }
                        if (budget.RFP_Scenario__c != null && budget.Apttus_Proposal__Approval_Stage__c != CON_CPQ.CANCELLED_STATUS && budget.RFP_Scenario__c != CON_CPQ.INACTIVE) {
                            if (oppToCOs.containsKey(budget.Apttus_Proposal__Opportunity__c)) {
                                oppToCOs.get(budget.Apttus_Proposal__Opportunity__c).add(budget.RFP_Scenario__c);
                            } else {
                                oppToCOs.put(budget.Apttus_Proposal__Opportunity__c, new Set<String>{budget.RFP_Scenario__c});
                            }
                        }
                        if (budget.Apttus_Proposal__Approval_Stage__c == CON_CPQ.ACCEPTED) {
                            if (budget.RFP_Scenario__c != null && !oppCoStage.contains(budget.Apttus_Proposal__Opportunity__c + ':' + budget.RFP_Scenario__c.replace((CON_CPQ.CHNAGE_ORDER + ' '), ''))) {
                                oppCoStage.add(budget.Apttus_Proposal__Opportunity__c + ':' + budget.RFP_Scenario__c.replace((CON_CPQ.CHNAGE_ORDER + ' '), ''));
                            } 
                            if (!oppCoStage.contains(budget.Apttus_Proposal__Opportunity__c + ':' + budget.Id)) {
                                oppCoStage.add(budget.Apttus_Proposal__Opportunity__c + ':' + budget.Id);
                            }
                        }
                    } else if ((cnfCONumbers.contains(budget.RFP_Scenario__c) || budget.Change_Order_Number__c != null) && budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF) {
                        if (!cnfRecordsByScenario.containsKey(budget.Apttus_Proposal__Opportunity__c + (':' + CON_CPQ.CHNAGE_ORDER + ' ') + budget.Change_Order_Number__c)) {
                            cnfRecordsByScenario.put(budget.Apttus_Proposal__Opportunity__c + (':' + CON_CPQ.CHNAGE_ORDER + ' ') + budget.Change_Order_Number__c, new List<Apttus_Proposal__Proposal__c>{budget});
                        } else {
                            cnfRecordsByScenario.get(budget.Apttus_Proposal__Opportunity__c + (':' + CON_CPQ.CHNAGE_ORDER + ' ') + budget.Change_Order_Number__c).add(budget);
                        }
                        if (budget.Related_Change_Order__c != null && changeOrderIds.contains(budget.Related_Change_Order__c)) {
                            budget.Related_Change_Order__c = null;
                            recordsToUpdate.add(budget);
                        }
                    }
                }

                for (Apttus_Proposal__Proposal__c budget : budgets) {
                    if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER) {
                        if (Trigger.isInsert || (Trigger.isUpdate && budget.RFP_Scenario__c != oldRecordsMap.get(budget.Id).RFP_Scenario__c)) {
                            if (Trigger.isBefore && oppToCOs != null && oppToCOs.containsKey(budget.Apttus_Proposal__Opportunity__c) && oppToCOs?.get(budget.Apttus_Proposal__Opportunity__c)?.contains(budget.RFP_Scenario__c)) {
                                budget.addError('A Change Order Quote already exists with the same scenario (change order number). Please select a different scenario.');
                            } else if (Trigger.isAfter && budget.RFP_Scenario__c != null && cnfRecordsByScenario.containsKey(budget.Apttus_Proposal__Opportunity__c + ':' + budget.RFP_Scenario__c)) {
                                for (Apttus_Proposal__Proposal__c prop : cnfRecordsByScenario.get(budget.Apttus_Proposal__Opportunity__c + ':' + budget.RFP_Scenario__c)) {
                                    if (prop.Related_Change_Order__c == null) {
                                        prop.Related_Change_Order__c = budget.Id;
                                        recordsToUpdate.add(prop);
                                    }
                                }
                            }
                        }
                    } else if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF && Trigger.isBefore) {
                        if (Trigger.isInsert || (Trigger.isUpdate && (budget.Change_Order_Number__c != oldRecordsMap.get(budget.Id).Change_Order_Number__c || (budget.CNF_Status__c != oldRecordsMap.get(budget.Id).CNF_Status__c && budget.CNF_Status__c == CON_CPQ.ACCEPTED)))) {
                            if (oppCoStage.contains(budget.Apttus_Proposal__Opportunity__c + ':' + budget.Related_Change_Order__c) || oppCoStage.contains(budget.Apttus_Proposal__Opportunity__c + ':' + budget.Change_Order_Number__c)) {
                                budget.addError('This CNF is linked to a CO Quote that has been accepted. You cannot update the link now. Please contact the CPQ team through VIA.');
                            } else {
                                if (scenarioToCOId.containsKey(budget.Apttus_Proposal__Opportunity__c + ':' + budget.Change_Order_Number__c) && scenarioToCOId.get(budget.Apttus_Proposal__Opportunity__c + ':' + budget.Change_Order_Number__c) != null) {
                                    budget.Related_Change_Order__c = scenarioToCOId.get(budget.Apttus_Proposal__Opportunity__c + ':' + budget.Change_Order_Number__c);
                                } else {
                                    budget.Related_Change_Order__c = null;
                                }
                            }
                        }      
                    }
                }
                if (!recordsToUpdate.isEmpty()) {
                    update recordsToUpdate;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error Exception happend' + e.getMessage());
        }
    }
    
    public static void updateContractPostAwardBidDate(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldRecordsMap) {
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (budget.CNF_Approval_Date__c != oldRecordsMap.get(budget.Id).CNF_Approval_Date__c && budget.CNF_Approval_Date__c != null && budget.Clinical_Bid__c != null && (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF) && (budget.CNF_Status__c == CON_CPQ.ACCEPTED || budget.CNF_Status__c == CON_CPQ.REJECTED_STATUS || budget.CNF_Status__c == CON_CPQ.CLOSED_FOR_INTERNAL_PURPOSES)) {
                List<BidHistoryWrapper> bidWrapperList = new List<BidHistoryWrapper>();
                
                BidHistoryWrapper wrapper = new BidHistoryWrapper();
                wrapper.SObjectName = CON_CPQ.APTTUS_PROPOSAL_PROPOSAL;
                wrapper.CNFApprovalDate = budget.CNF_Approval_Date__c;
                wrapper.bidHistoryId = budget.Clinical_Bid__c;
                
                bidWrapperList.add(wrapper);
                UTL_OWF.updateContractPostAwardbidFromOtherObject(bidWrapperList);
            }
        }
    }
}
