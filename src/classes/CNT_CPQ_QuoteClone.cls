/*
* Version       : 0.0.1
* Description   : This Apex class is use clone quotes with related
* Created By    : Noorulain Ashrafi
*/  
public class CNT_CPQ_QuoteClone {

    @AuraEnabled
    public static WPR_CPQ_WrapperClassToBeReturn cloneQuoteWithDetails(String quoteRecordId, Boolean isFreshData, String bidScenario, Id bidId, String isGbu, String isTSOption) {
        WPR_CPQ_WrapperClassToBeReturn result = new WPR_CPQ_WrapperClassToBeReturn();
        Savepoint sp ;
        try {
            if (!String.isBlank(quoteRecordId)) {
                Set<String> quoteFieldSet = CON_CPQ.QUOTE_FIELDSET_FOR_COMMON_CLONE;
                Set<String> quoteRequisiteFieldSet = new Set<String>{CON_CPQ.ID};
                for (PermissionSetAssignment psa: [SELECT Id, PermissionSet.name FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId()]) {
                    if (psa.PermissionSet.name == CON_CPQ.DPS_Permission_Set) {
                        quoteFieldSet.addAll(CON_CPQ.QUOTE_FIELDSET_FOR_DPS_CLONE);
                        quoteRequisiteFieldSet.addAll(CON_CPQ.QUOTE_REQUISITE_FIELDSET_FOR_DPS_CLONE);
                    } 
                    if (psa.PermissionSet.name == CON_CPQ.Q2_Permission_Set) {
                        quoteFieldSet.addAll(CON_CPQ.QUOTE_FIELDSET_FOR_Q2_CLONE);
                        quoteRequisiteFieldSet.addAll(CON_CPQ.QUOTE_REQUISITE_FIELDSET_FOR_Q2_CLONE);
                    }
                    if (psa.PermissionSet.name == CON_CPQ.EMEA_PERMISSION_SET) {
                        quoteFieldSet.add(CON_CPQ.DISCOUNT_REASON);
                    }
                }
                sp = Database.setSavepoint();
                Set<Id> quoteIdSet = new Set<Id>{quoteRecordId};
                Map<String, Apttus_Proposal__Proposal__c> mapOfProposal = new Map<String, Apttus_Proposal__Proposal__c>();
                List<String> availableCongaToolList = new List<String>();
                
                fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
                    Quote__c.SobjectType,
                    Quote_Requisites__c.SobjectType,
                    Apttus_Proposal__Proposal__c.SobjectType
                });
                fflib_SObjectUnitOfWork uowProposal2 = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] { Quote__c.SobjectType });

                Quote__c cloneIqQuote = new Quote__c();
                Quote__c oldIQQuoteRecord = new SLT_IQVIA_Quote().getQuoteId(quoteRecordId, quoteFieldSet);
                if (oldIQQuoteRecord.Related_Opportunity__r.Account.AccountStatus__c == CON_CPQ.INACTIVE) {
                    throw createAuraHandledException(null, CON_CPQ.INACTIVE_ACCOUNT_VALIDATION);
                }
                cloneIqQuote = oldIQQuoteRecord.clone();
                cloneIqQuote.Related_Quote__c = quoteRecordId;
                cloneIqQuote.Is_Cloned__c = true;
                cloneIqQuote.Approval_Stage__c = CON_CPQ.DRAFT;
                for (CPQ_Proposal_Create_Settings__c customSetting : [SELECT GBU__c, Available_Pricing_Tools__c, Permission_Set_Name__c, Conga_Setup__c, Flow_Name__c, Pathway__c FROM CPQ_Proposal_Create_Settings__c WHERE Available_Pricing_Tools__c IN: cloneIqQuote.Pricing_Tools__c.split(';')]) {
                    if (customSetting.Available_Pricing_Tools__c != null) {
                        if (customSetting.Conga_Setup__c) {
                            availableCongaToolList.add(customSetting.Available_Pricing_Tools__c);
                        }
                    }
                }
                String checkPathway = CPQ_QuoteUtility.checkPathway(availableCongaToolList);
                if (checkPathway == CON_CPQ.NEEDCONGAACCESS || (availableCongaToolList.size() > 0 && !Schema.sObjectType.Apttus_QPConfig__ProposalProductAttributeValue__c.isAccessible())) {
                    throw createAuraHandledException(null, CON_CPQ.CONGA_LICENSE_PERMISSION_ERROR_FOR_CLONE);
                }																																																																						
                if (isGbu != CON_CPQ.RECORD_TYPE_TECH_SOLUTION) {
                    cloneIqQuote.Related_Bid__c = bidId != null ? bidId : cloneIqQuote.Related_Bid__c;
                    cloneIqQuote.Quote_Type__c = CPQ_Utility.getQuoteType(cloneIqQuote.Related_Bid__c, cloneIqQuote.Pricing_Tools__c);
                    if (cloneIqQuote.Quote_Type__c == CON_CPQ.CHANGE_ORDER) {
                        String condition = 'Related_Opportunity__c =: relatedOpportunityIdSet AND Approval_Stage__c = ' + '\'' + CON_CPQ.ACCEPTED + '\'';
                        List<Quote__c> lastAcceptedQuote = new SLT_IQVIA_Quote().getQuotesByConditionOrderByAcceptedDate(new Set<String>{CON_CPQ.ID, CON_CPQ.CURRENCYISOCODE, CON_CPQ.CONVERSION_RATE, CON_CPQ.CONVERSION_DATE, CON_CPQ.CHNAGE_ORDER_NUMBER, CON_CPQ.TOTAL_NET_AMOUNT}, condition, CON_CPQ.ACCEPTED_DATE, CON_CPQ.SORT_DESC, new Set<Id>{oldIQQuoteRecord.Related_Opportunity__c});
                        if (cloneIqQuote.Pricing_Tools__c.contains(CON_CPQ.Q2_Solutions)) {
                            cloneIqQuote.currencyISOCode = lastAcceptedQuote.size() > 0 ? lastAcceptedQuote[0].currencyISOCode != null ? lastAcceptedQuote[0].currencyISOCode : null : null;
                            cloneIqQuote.Conversion_Rate__c = lastAcceptedQuote.size() > 0 ? lastAcceptedQuote[0].Conversion_Rate__c != null ? lastAcceptedQuote[0].Conversion_Rate__c : null : null;
                            cloneIqQuote.Conversion_Date__c = lastAcceptedQuote.size() > 0 ? lastAcceptedQuote[0].Conversion_Date__c != null ? lastAcceptedQuote[0].Conversion_Date__c : null : null;
                            cloneIqQuote.Upfront_Payment_Amount__c = null;
                            cloneIqQuote.Upfront_Payment_Term_Conditions__c = null;
                        } 
                        if (lastAcceptedQuote.size() > 0 && lastAcceptedQuote[0].Id == quoteRecordId) {
                            cloneIqQuote.Total_Net_Amount_Last_Accepted__c = lastAcceptedQuote[0].TotalNetAmount__c;
                            cloneIqQuote.Change_Order_Number__c = lastAcceptedQuote[0].Change_Order_Number__c == null ? 1 : Integer.valueOf(lastAcceptedQuote[0].Change_Order_Number__c) + 1;
                        } else {
                            throw createAuraHandledException(null, CON_CPQ.IQVIA_CHANGE_ORDER_VALIDATION);
                        }
                    }
                }               
                if (cloneIqQuote.Related_Opportunity__r.StageName == CON_CPQ.OPPORTUNITY_7B_CLOSED_LOST_STAGE) {
                    throw createAuraHandledException(null, CON_CPQ.NOT_CREATE_QUOTE_ON_7_STAGE_ERROR);
                }
                if (isGbu == CON_CPQ.RECORD_TYPE_TECH_SOLUTION && CNT_CPQ_QuoteCreation.checkPricingAssistant((String)cloneIqQuote.Related_Opportunity__c)) {
                    throw createAuraHandledException(null, CON_CPQ.NOT_CREATE_QUOTE_PRICING_ASSISTANT_EXITS_ERROR);  
                }
                uowProposal2.registerNew(cloneIqQuote); 
                uowProposal2.commitWork();
                result.clonedQuote = cloneIqQuote;
                if (isGbu == CON_CPQ.RECORD_TYPE_TECH_SOLUTION) {
                    if (isTSOption == CON_CPQ.CANCELLED_STATUS) {
                        CNT_CPQ_QuoteWorkflow.updateQuoteStage(quoteRecordId, CON_CPQ.CANCELLED_STATUS);
                    }
                    cloneQuoteLineItem((ID)quoteRecordId, cloneIqQuote.Id);
                    CNT_CPQ_QuoteWorkflow.markQuoteAsPrimary(cloneIqQuote.Id, cloneIqQuote.Related_Opportunity__c);
                }
                if (isGbu != CON_CPQ.RECORD_TYPE_TECH_SOLUTION) {
                    if (cloneIqQuote.Pricing_Tools__c.contains(CON_CPQ.Q2_Solutions)) {
                        CNT_CPQ_QuoteWorkflow.markQuoteAsPrimary(cloneIqQuote.Id, cloneIqQuote.Related_Opportunity__c);
                    }
                    if (isFreshData == true) {
                        if (cloneIqQuote.Pricing_Tools__c != null) {
                            String res = CON_CPQ.BLANK;
                            if (cloneIqQuote.Pricing_Tools__c.contains(CON_CPQ.Complete_Consent)) {
                                res = CNT_CPQ_QuoteCreation.processCollectionTool(cloneIqQuote.Related_Bid__c, cloneIqQuote, uowProposal, double.valueOf(bidScenario), true);
                            }
                            if (cloneIqQuote.Pricing_Tools__c.contains(CON_CPQ.Q2_Solutions)) {
                                CPQ_Proposal_Create_Settings__c customSetting = [SELECT Identified_Business__c FROM CPQ_Proposal_Create_Settings__c WHERE Available_Pricing_Tools__c = :CON_CPQ.Q2_Solutions LIMIT 1];
                                String identifiedBusiness = customSetting != null && customSetting.Identified_Business__c != null ? customSetting.Identified_Business__c : null;
                                String condition = identifiedBusiness != null ? 'AND Type__c IN (\'' + String.join(identifiedBusiness.split(';'), '\',\'') + '\')' : '';
                                Set<String> collectionToolFieldSet = new Set<String>{CON_CPQ.ID, 'Bid_History__r.Study_Number__c'};
                                List<CollectionTool__c> collectionToolList = new SLT_CollectionTool(false, false).getCollectionToolsByCondition(cloneIqQuote.Related_Bid__c, collectionToolFieldSet, condition);
                                if (collectionToolList.size() > 0 ) {
                                    String collectionToolCount = collectionToolList[0].Bid_History__r.Study_Number__c;
                                    if (integer.valueof(collectionToolCount) != collectionToolList.size()) {
                                        throw createAuraHandledException(null, CON_CPQ.REQUIRED_QUOTE_SECTIONS_ERORR);
                                    }
                                } else if (collectionToolList.size() == 0 ) {
                                    throw createAuraHandledException(null, CON_CPQ.REQUIRED_QUOTE_SECTIONS_ERORR);
                                }
                                res = CNT_CPQ_QuoteCreation.collectionToolToQuoteRequisites(cloneIqQuote.Related_Bid__c, cloneIqQuote, uowProposal, true, identifiedBusiness);
                            }
                            if (res != CON_CPQ.SUCCESS && String.isNotBlank(res)) {
                                throw createAuraHandledException(null, CON_CPQ.FAILED + ': ' + 'The selected Country ' + res + ' on Collection Tool, doesn not exist in the CPQ Workflow, Please Contact Support.');
                            }
                                                                                                                                                                                            
                        }
                    } else {
                        DAOH_IQ_QuoteRequisites.isSkipUpdateLanguagesOnQuote = true;
                        DAOH_IQ_QuoteRequisites.skipPopulateFieldsOnQuoteRequisite = true;
                        String condition = 'Quote__c IN: quoteIdSet';
                        for (Quote_Requisites__c qReq: new SLT_QuoteRequisites().getQuoteRequisitesByQuoteId(quoteIdSet, quoteRequisiteFieldSet, condition)) {
                            if (qReq.Quote__r.Pricing_Tools__c.contains(CON_CPQ.Q2_Solutions) && (String.isBlank(qReq.Service_Line_Product__c) || String.isBlank(qReq.Site__c) || String.isBlank(qReq.Study_Type__c) ||
                                String.isBlank(qReq.Species_Global__c) || String.isBlank(qReq.Matrix__c) || String.isBlank(qReq.Analyte_ID__c) ||
                                String.isBlank(String.valueOf(qReq.Study_Number__c)) || String.isBlank(qReq.Specimen_Type__c) || String.isBlank(qReq.Number_of_Analyte_Global__c) ||
                                String.isBlank(qReq.Clinical_Type__c))) {
                                    throw new CPQ_CustomException(CON_CPQ.REQUIRED_QUOTE_SECTIONS_ERORR);
                            } else {
                                Quote_Requisites__c quoteRequi = qReq.clone();
                                quoteRequi.Quote__c = cloneIqQuote.Id;
                                uowProposal.registerNew(quoteRequi, Quote_Requisites__c.Quote__c, cloneIqQuote);
                            }
                        }
                    }
                
                    if (checkPathway == CON_CPQ.HASCONGAACCESS) {
                        String condition = 'IQVIA_Quote__c IN :quoteIdSet';
                        for (Apttus_Proposal__Proposal__c pro: new SLT_Proposal().getProposalByQuoteIds(CON_CPQ.PROPOSAL_FIELDSET_FORCLONE, condition, quoteIdSet)) {
                            Apttus_Proposal__Proposal__c cloneProposal = new Apttus_Proposal__Proposal__c();
                            cloneProposal = Apttus_Proposal.ProposalWebService.cloneProposal(pro.Id);
                            cloneProposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
                            cloneProposal.IQVIA_Quote__c = cloneIqQuote.Id;
                            uowProposal.registerNew(cloneProposal, Apttus_Proposal__Proposal__c.IQVIA_Quote__c, cloneIqQuote);
                            mapOfProposal.put(pro.Id, cloneProposal);
                        }
                    }
                    uowProposal.commitWork();

                    if (!mapOfProposal.isEmpty()) {
                        boolean isSuccess = false;
                        for (String key: mapOfProposal.keySet()) {
                            isSuccess = Apttus_qpconfig.QPConfigWebService.copyProductConfiguration(key, mapOfProposal.get(key).Id);
                            if (!isSuccess) {
                                throw createAuraHandledException(null, CON_CPQ.CART_CLONE_FAIL_ERROR);
                            } else {
                                Set<String> lineItemFieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.CHANGE_FROM_PREVIOUS}; 
                                String lineItemCondition = 'Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.IQVIA_Quote__c = '+ '\'' + cloneIqQuote.Id + '\'';  
                                List<Apttus_Config2__LineItem__c> lineItemList = new SLT_LineItem().getLineItemsByCondtion(lineItemCondition, lineItemFieldSet);
                                if (lineItemList.size() > 0) {
                                    for (Apttus_Config2__LineItem__c lineItem: lineItemList) {
                                        lineItem.Change_From_Previous__c = null;
                                    }
                                    fflib_SObjectUnitOfWork uowLineItem = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] { Apttus_Config2__LineItem__c.SobjectType });
                                    uowLineItem.registerDirty(lineItemList); 
                                    uowLineItem.commitWork();
                                }
                            }   
                        }
                    }
                } 
            } else {
                throw createAuraHandledException(null, CON_CPQ.SOMETHING_WENT_WRONG_ERROR);
            }
        } catch (DmlException e) {
            Database.rollback(sp);
            result = new WPR_CPQ_WrapperClassToBeReturn();
            for (Integer i = 0; i < e.getNumDml(); i++) {
                throw new AuraHandledException('Error: ' + e.getDmlMessage(i));
            }
        } catch (Exception e) {
            Database.rollback(sp);
            result = new WPR_CPQ_WrapperClassToBeReturn();
            throw new AuraHandledException(e.getMessage());
        }
        result.isSuccess = true;
        result.message = CON_CPQ.QUOTE_CLONE_SUCCESS_MSG;
        return result;
    }

    public static AuraHandledException createAuraHandledException(String methodName, String message) {
        AuraHandledException e = new AuraHandledException(message);
        if (String.isNotBlank(methodName)) {
            e.setMessage('Method Name: '+ methodName +' Error: '+ message);
        } else {
            e.setMessage(message);
        }
        return e; 
    }
    @AuraEnabled
    public static WPR_CPQ_WrapperClassToBeReturn getQuotesList(Id bidRecordId){
        WPR_CPQ_WrapperClassToBeReturn wrapData = new WPR_CPQ_WrapperClassToBeReturn();
        try {
            if (bidRecordId != null || bidRecordId != '') {
                List<Quote__c> quoteList = new List<Quote__c>();
                Bid_History__c bid = new SLT_Bid_History().getClinicalBidDetails(bidRecordId, CON_CPQ.BID_HISTORY_FIELDSET_FOR_VALIDATE);
                if (bid != null && bid.Bid_History_Related_Opportunity__c != null) {
                    Set<Id> relatedOpportunityIdSet = new Set<Id>{bid.Bid_History_Related_Opportunity__c};
                    String condition = 'Related_Opportunity__c IN: relatedOpportunityIdSet';
                    if (CON_CPQ.OPPORTUNITY_7A_ONWARDS_STAGE.contains(bid.Bid_History_Related_Opportunity__r.StageName)) {
                        condition = 'Related_Opportunity__c =: relatedOpportunityIdSet AND Approval_Stage__c = ' + '\'' + CON_CPQ.ACCEPTED + '\'';
                        quoteList = new SLT_IQVIA_Quote().getQuotesByConditionOrderByAcceptedDate(CON_CPQ.QUOTE_FIELDSET_FOR_POPUP, condition, CON_CPQ.ACCEPTED_DATE, CON_CPQ.SORT_DESC, relatedOpportunityIdSet);
                        wrapData.listOfQuotes = quoteList.size() > 0 ? new List<Quote__c>{quoteList[0]} : quoteList;
                    } else {
                        quoteList = new SLT_IQVIA_Quote().getQuotesByCondition(CON_CPQ.QUOTE_FIELDSET_FOR_POPUP, condition, relatedOpportunityIdSet);
                        wrapData.listOfQuotes = quoteList;
                    }
                } else {
                    throw createAuraHandledException(null, CON_CPQ.RELATED_OPP_NOT_FOUND_ERROR);
                } 
            } else {
                throw createAuraHandledException(null, CON_CPQ.RELATED_BID_NOT_FOUND_ERROR);
            }   
        } catch (Exception e) {
            wrapData = new WPR_CPQ_WrapperClassToBeReturn();
            throw new AuraHandledException(e.getMessage());
        }
        wrapData.isSuccess = true;
        wrapData.message = CON_CPQ.SUCCESS;
        return wrapData;
    }
    @AuraEnabled
    public static String getValidateData(Quote__c quoteRecord) {
        String lineOfBusiness;
        String identifiedBusiness;

        for (CPQ_Proposal_Create_Settings__c customSetting : [SELECT Available_Pricing_Tools__c, Line_of_Business__c, Identified_Business__c FROM CPQ_Proposal_Create_Settings__c WHERE Available_Pricing_Tools__c IN :quoteRecord.Pricing_Tools__c.split(';')]) {
            if (customSetting.Available_Pricing_Tools__c == CON_CPQ.Q2_Solutions && customSetting.Line_of_Business__c != null && customSetting.Identified_Business__c != null) {
                lineOfBusiness = customSetting.Line_of_Business__c;
                identifiedBusiness = customSetting.Identified_Business__c;
            }
        }

        List<String> allowedBusinessesList = identifiedBusiness != null ? identifiedBusiness.split(';') : new List<String>();
        SObject opportunityRecord = new SLT_Opportunity().getOpportunityDetails(quoteRecord.Related_Opportunity__c, CON_CPQ.OPPORTUNITY_FIELDSET_FOR_CLONE);
        if (quoteRecord.Pricing_Tools__c.contains(CON_CPQ.Q2_Solutions) && (opportunityRecord.get(CON_CPQ.LINE_OF_BUSINESS) != lineOfBusiness || !allowedBusinessesList.contains((String)opportunityRecord.get(CON_CPQ.IDENTIFIED_BUSINESS)))) {
            return CON_CPQ.FAILED;
        }
        return CON_CPQ.SUCCESS;
    }

    public class WPR_CPQ_WrapperClassToBeReturn {
        @AuraEnabled
        public Quote__c clonedQuote {get;set;}
        @AuraEnabled
        public boolean isSuccess {get;set;}
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public List<Quote__c> listOfQuotes {get;set;}

        public WPR_CPQ_WrapperClassToBeReturn() {
            this.clonedQuote = new Quote__c();
            this.isSuccess = false;
            this.message = '';
            this.listOfQuotes = new List<Quote__c>();
        }
    }

    public static void cloneQuoteLineItem(Id oldQuoteId, Id newQuoteId) {
        fflib_SObjectUnitOfWork uowQuoteLineItem = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] { Quote_Line_Item__c.SObjectType });
        List<Quote_Line_Item__c> quoteLineItemList = new SLT_QuoteLineItem().getQuoteLineItemByQuoteId(new Set<Id>{oldQuoteId}, CON_CPQ.QUOTE_LINE_ITEM_FIELDSET_FOR_CLONE);
        if (!quoteLineItemList.isEmpty()) {
            List<Quote_Line_Item__c> clonedItems = new List<Quote_Line_Item__c>();
            for (Quote_Line_Item__c item : quoteLineItemList) {
                Quote_Line_Item__c clonedItem = item.clone();
                clonedItem.Quote__c = newQuoteId;
                clonedItems.add(clonedItem);
            }
            try {
                uowQuoteLineItem.registerNew(clonedItems);
                uowQuoteLineItem.commitWork();
            } catch (DmlException e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
}
