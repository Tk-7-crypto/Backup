/**
 * Controller class for TS Proposal Quick Action component
 * version : 1.0 
 */
public with sharing class CNT_CPQ_TSJapanWorkflowController {

    public static Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap {get; set;}
    
    @AuraEnabled
    public static WPR_CPQ_ProposalDetails getProposalDetails(Id recordId) {
        WPR_CPQ_ProposalDetails proposalObj = new WPR_CPQ_ProposalDetails();
        Set<String> permissionSetsName = new Set<String>();
        for(CPQ_Proposal_Create_Settings__c customSetting : CPQ_Proposal_Create_Settings__c.getall().values()){
            permissionSetsName.add(customSetting.Permission_Set_Name__c);
        }
        List<User> users = new SLT_User().selectUserWithPermissionSetByUserId(
            new Set<Id>{UserInfo.getUserId()},
            new Set<String> {CON_CPQ.PROFILE_NAME},
            new Set<String> {CON_CPQ.ID},
            permissionSetsName
        );
        
        CPQ_TS_Admin_Profiles__c adminProfiles = CPQ_TS_Admin_Profiles__c.getInstance(users[0].Profile.Name);
        
        if(users[0].PermissionSetAssignments.size() >= 1 || adminProfiles != null){
			
            proposalObj.isAllowedToEditAction = true;
            
            List<PermissionSetAssignment> createaAgreementPermissionSetList = new SLT_PermissionSetAssignment().selectByPermissionSetForUserId(new Set<String>{CON_CPQ.ID}, new Set<Id>{UserInfo.getUserId()}, CON_CPQ.CPQ_CLM_Create_Agreement);
            if(createaAgreementPermissionSetList.size() > 0) {
            	proposalObj.canCreateAgreement = true;
            }
            
            try {
                Set<String> proposalFieldSet = new Set<String> {CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL, CON_CPQ.FIELD_FINALIZE_DATE};
                /*if (Schema.sObjectType.Apttus_Proposal__Proposal__c.fields.IQVIA_Quote__c.isAccessible()) {    
                    proposalFieldSet.add(CON_CPQ.IQVIA_QUOTE);
                }*/
                Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(recordId, proposalFieldSet);
                /*if (proposalFieldSet.contains(CON_CPQ.IQVIA_QUOTE) && proposal.IQVIA_Quote__c != null) {
                    proposalObj.iqviaQuoteId = proposal.IQVIA_Quote__c;
                    if (proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c != null) {
                        Datetime finalizedDate = proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c;
                        Datetime thirtyMinuteAgo = Datetime.now().addMinutes(-30);
                        if (finalizedDate >= thirtyMinuteAgo) {
                            CPQ_QuoteUtility.createQuoteLineItems(proposal.IQVIA_Quote__c, recordId, proposal.Select_Pricing_Tool__c, 'Conga');
                        }
                    }
                    return proposalObj;
                }*/                
                Set<String> fieldSet = null;
                if (proposal.Select_Pricing_Tool__c == 'TS Japan') {
                    fieldSet = new Set<String> {
                        CON_CPQ.APPROVAL_STAGE,
                        CON_CPQ.APPROVAL_STATUS,
                        CON_CPQ.APTTUS_PROPOSAL_PRIMARY, 
                        CON_CPQ.RECORDTYPEID, 
                        CON_CPQ.PRICELIST_ID,
                        CON_CPQ.VENDOR_USE,
                        CON_CPQ.MIN_GROSS_MARGIN,
                        CON_CPQ.SPECIAL_PRICING_EXPLANATION,
                        CON_CPQ.ACCOUNT_TIER_0_5,
                        CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL,
                        CON_CPQ.PRICE_LIST_NAME,
                        CON_CPQ.BUDGET_SYNC_STATUS,
                        CON_CPQ.EXPECTED_START_DATE,
                        CON_CPQ.EXPECTED_END_DATE,
                        CON_CPQ.BUDGET_SYNC_MESSAGE,
                        CON_CPQ.COUNTRY_CODE,
                        CON_CPQ.OWNER
                    };
                } else {
                    fieldSet = new Set<String> {
                        CON_CPQ.APPROVAL_STAGE,
                        CON_CPQ.APPROVAL_STATUS,
                        CON_CPQ.APTTUS_PROPOSAL_PRIMARY, 
                        CON_CPQ.RECORDTYPEID, 
                        CON_CPQ.PRICELIST_ID,
                        CON_CPQ.MIN_GROSS_MARGIN,
                        CON_CPQ.SPECIAL_PRICING_EXPLANATION,
                        CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL,
                        CON_CPQ.PRICE_LIST_NAME,
                        CON_CPQ.BUDGET_SYNC_STATUS,
                        CON_CPQ.EXPECTED_START_DATE,
                        CON_CPQ.EXPECTED_END_DATE,
                        CON_CPQ.BUDGET_SYNC_MESSAGE,
                        CON_CPQ.RECORD_TYPE_NAME,
                        CON_CPQ.COUNTRY_CODE,
                        CON_CPQ.ACTUAL_QUOTE_AMOUNT,
                        CON_CPQ.DISCOUNT_PERCENT,
                        CON_CPQ.DISCOUNT_AMOUNT,
                        CON_CPQ.AVERAGE_GROSS_MARGIN,
                        CON_CPQ.OWNER
                    };
                }
                if (proposal.Select_Pricing_Tool__c == CON_CPQ.AMESA && proposalObj.canCreateAgreement) {
                    fieldSet.add(CON_CPQ.REALTED_AGREEMENT);
                }
                proposal = new SLT_Proposal().getProposalDetails(recordId, fieldSet);
                proposalObj.proposalSObject = proposal;
                proposalObj.recordId = proposal.Id;
                proposalObj.approvalStage = proposal.Apttus_Proposal__Approval_Stage__c;
                proposalObj.approvalStatus = proposal.Approval_Status__c;
                proposalObj.pricingTool = proposal.Select_Pricing_Tool__c;
                proposalObj.isPrimary = proposal.Apttus_Proposal__Primary__c;
                proposalObj.isrecordTypeNameTechSolution = proposal.RECORDTYPEID == CPQ_Utility.proposalTechSolutionRecordTypeId ? true : false;
                proposalObj.isPriceListAttached = proposal.Apttus_QPConfig__PriceListId__c != null ? true : false;
                proposalObj.priceListName = proposal.Apttus_QPConfig__PriceListId__r.Name;
                proposalObj.syncStatus = proposal.Execution_Status__c;
                proposalObj.syncMessage = proposal.Execution_Message__c;
                proposalObj.country = proposal.CountryCode__c;
                proposalObj.quoteOwnerId = proposal.OwnerId;
                proposalObj.isAgreementCreated = false;
                if (proposalObj.quoteOwnerId == UserInfo.getUserId()) {
                    proposalObj.isOwner = true;
                }
                if (proposal.Select_Pricing_Tool__c == 'TS Japan') {
                    proposalObj.isSpecialPricingCommentRequired = (proposal.Min_Gross_Margin__c != null && 
                                                               proposal.Min_Gross_Margin__c < 20 && 
                                                               proposal.Special_Pricing_Explanation_Comments__c == null) ? true : false;
                	List<ContentDocumentLink> proposalRelatedFiles = new SLT_ContentDocument().getDocumentsOnLinkedId(new Set<Id>{proposal.Id});
                    if (proposalRelatedFiles.size() > 0) { // Minimum CSS file should be attached
                        for (ContentDocumentLink fileObj : proposalRelatedFiles) {
                            if (fileObj.ContentDocument.Title.ContainsIgnoreCase(CON_CPQ.CSS_FILE)) {
                                proposalObj.cssFileAttached = true;
                                break;
                            }
                        }
                    }
                } else {
               		proposalObj.recordTypeName = proposal.Record_Type_Name__c;
                    proposalObj.quoteAmount = proposal.Actual_Quote_Amount__c;
                    proposalObj.discountPercent = proposal.Apttus_Proposal__Discount_Percent__c;
                    proposalObj.discountAmount = proposal.Actual_Discount_Value__c;
                    proposalObj.quoteOwnerId = proposal.OwnerId;
                    proposalObj.isApprover = false;
                    proposalObj.isAdmin = false;
                    proposalObj.isOwner = false;
                    if (proposalObj.quoteOwnerId == UserInfo.getUserId()) {
                       proposalObj.isOwner = true; 
                    }
                    Set<Id> approverId = new Set<Id>();
                    List<ProcessInstanceWorkitem> lst = getProcessInstanceWorkItems(proposal.Id);
                    for (ProcessInstanceWorkitem pi : lst) {
                        approverId.add(pi.ActorId);
                    }
                    if (approverId.contains(UserInfo.getUserId())) {
                        proposalObj.isApprover = true;
                    }
                    if (adminProfiles != null) {
                        proposalObj.isAdmin = true;
                    }
                    proposalObj.proposalValidity = (proposal.Apttus_Proposal__ExpectedStartDate__c == null || proposal.Apttus_Proposal__ExpectedEndDate__c == null ? true : false);
                }
                if (proposal.Select_Pricing_Tool__c == CON_CPQ.AMESA && proposalObj.canCreateAgreement) {
                    proposalObj.isAgreementCreated = proposal.Apttus_QPComply__MasterAgreementId__c != null ? true : false;
                }
				
                for (CPQ_Proposal_Create_Settings__c customSetting : CPQ_Proposal_Create_Settings__c.getall().values()) {
                    if (customSetting.Available_Pricing_Tools__c == proposalObj.pricingTool)  {
                        proposalObj.flowName = customSetting.Flow_Name__c;
                    }
                }
                return proposalObj;
            } catch (Exception e) {
                proposalObj.error = e.getMessage();
                return proposalObj;
            }
        }
        return proposalObj;
    }
    
    @AuraEnabled
    public static void recallProposal(Id recordId) 
    {
        try {
            Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(recordId, new Set<String> {CON_CPQ.ID});
            ProcessInstanceWorkitem[] workItems = new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemByTargetIdAndStatus(new Set<Id>{proposal.Id}, CON_CPQ.PENDING, new Set<String>{CON_CPQ.Id}); 
            
            if (workItems.size() > 0) {
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setAction(CON_CPQ.REMOVED);
                pwr.setWorkItemId(workItems[0].id);
                Approval.process(pwr);
            }   
            update new Apttus_Proposal__Proposal__c(Id = proposal.Id, 
                                                    Total_Amount__c = 0,
                                                    Total_Extended_Price__c = 0,
                                                    Apttus_Proposal__Approval_Stage__c = CON_CPQ.IN_PROGRESS_STATUS);
        } 
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateQuoteStatus(Id recordId, String approvalStage) {
        try {
            update new Apttus_Proposal__Proposal__c(Id = recordId, Apttus_Proposal__Approval_Stage__c = approvalStage);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String syncPLIWithOpportunity(Id recordId, String pricingTool, String approvalStage) {
        try {
            QUE_CPQ_SyncBudgetWithOpportunity syncBudgetWithOpportunityJob = new QUE_CPQ_SyncBudgetWithOpportunity(recordId, True, pricingTool, approvalStage);
            Id jobId = System.enqueueJob(syncBudgetWithOpportunityJob);
            return jobId;
        } catch(Exception ex) {
            return ex.getMessage();
        }
    }
    
    //---------------------------------------------------------- CODE FOR DYNAMIC APPROVAL -------------------------------------------------
    
    public static map<String, WPR_CPQ_ApprovalMatrix> approversMap;
								
    @AuraEnabled
    public static String submitForApprovalProcess(Id recordId) {
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.APPROVAL_STAGE, CON_CPQ.APPROVAL_STATUS, CON_CPQ.APPROVER_LEVEL, 
            CON_CPQ.TOTAL_AMOUNT, CON_CPQ.COUNTRY_CODE, CON_CPQ.AVERAGE_GROSS_MARGIN, 
            CON_CPQ.DISCOUNT_PERCENT, CON_CPQ.DISCOUNT_AMOUNT, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL,
            CON_CPQ.OPPORTUNITY_NUMBER, CON_CPQ.PROPOSAL_OPPORTUNITY_NAME, CON_CPQ.Name, CON_CPQ.CONVERSION_DATE};
            Apttus_Proposal__Proposal__c thisProposal = new SLT_Proposal().getProposalDetails(recordId, fieldSet);																	
        String result = fetchApprover(thisProposal);
        if (result != 'ERROR') {
            result = submitApprovalRequest(thisProposal);
        }
        return result;
    }
	
    public static String fetchApprover(Apttus_Proposal__Proposal__c thisProposal) {
        approversMap = new map<String, WPR_CPQ_ApprovalMatrix>();
        Set<String> countryCodes = new Set<String>();
        countryCodes.add('All');
        Decimal usdAmount = 0;
        Decimal usdDiscountValue = 0;
        if (thisProposal.Select_Pricing_Tool__c == 'AMESA') {
            List<Apttus_QPConfig__ProposalProductAttributeValue__c> ppavList = [select Eligible_Countries__c from Apttus_QPConfig__ProposalProductAttributeValue__c where Apttus_QPConfig__LineItemId__r.Apttus_Proposal__Proposal__c =: thisProposal.Id];
            for (Apttus_QPConfig__ProposalProductAttributeValue__c ec : ppavList) {
                countryCodes.add(ec.Eligible_Countries__c);
            }
            if(thisProposal.CurrencyIsoCode != CON_CPQ.USD) {
                Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCode(new Set<String>{thisProposal.CurrencyIsoCode}, thisProposal.Conversion_Date__c);
                usdAmount = CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(CON_CPQ.USD).Conversion_rate__c, isoCodeTocurrencyTypeMap.get(thisProposal.CurrencyIsoCode).Conversion_rate__c, (double)thisProposal.Total_Amount__c);
                usdDiscountValue = CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(CON_CPQ.USD).Conversion_rate__c, isoCodeTocurrencyTypeMap.get(thisProposal.CurrencyIsoCode).Conversion_rate__c, (double)thisProposal.Actual_Discount_Value__c);  
            } else {
                usdAmount = thisProposal.Total_Amount__c;
                usdDiscountValue = thisProposal.Actual_Discount_Value__c;
            }       
        } else {
            countryCodes.add(thisProposal.CountryCode__c);
            usdAmount = thisProposal.Total_Amount__c;
            usdDiscountValue = thisProposal.Actual_Discount_Value__c;
        }
        usdAmount = usdAmount.setScale(5);
        usdDiscountValue = usdDiscountValue.setScale(5);
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID , CON_CPQ.APPROVE_ON_FIRST_RESPONSE, CON_CPQ.LEVELS, CON_CPQ.PRIORITY,CON_CPQ.COUNTRY, CON_CPQ.MIN_AMOUNT, CON_CPQ.MAX_AMOUNT, CON_CPQ.MIN_GORSS_MARGIN, CON_CPQ.MAX_GORSS_MARGIN, CON_CPQ.MIN_DISCOUNT_PERCENT, CON_CPQ.MAX_DISCOUNT_PERCENT, CON_CPQ.MIN_DISCOUNT_AMOUNT, CON_CPQ.MAX_DISCOUNT_AMOUNT, CON_CPQ.APPROVER1, CON_CPQ.APPROVER2, CON_CPQ.APPROVER3, CON_CPQ.APPROVER4, CON_CPQ.APPROVER5, CON_CPQ.OBJECT_NAME, CON_CPQ.TRACK_NAME, CON_CPQ.PRICING_TOOL, CON_CPQ.AUTO_APPROVE, CON_CPQ.NOTIFIER1, CON_CPQ.NOTIFIER2, CON_CPQ.NOTIFIER3, CON_CPQ.NOTIFIER4, CON_CPQ.NOTIFIER5};
        String condition = 'Min_Amount__c <= ' + (usdAmount == null ? 0 :  usdAmount) +
            ' AND Max_Amount__c > ' + (usdAmount == null ? 0 :  usdAmount) +
            ' AND Min_Gross_Margin__c <= ' + (thisProposal.Average_Gross_Margin__c == null ? 0 : thisProposal.Average_Gross_Margin__c) +
            ' AND Max_Gross_Margin__c > ' + (thisProposal.Average_Gross_Margin__c == null ? 0 : thisProposal.Average_Gross_Margin__c) +
            ' AND Min_Discount_Percent__c <= ' + (thisProposal.Apttus_Proposal__Discount_Percent__c == null ? 0 : thisProposal.Apttus_Proposal__Discount_Percent__c) +
            ' AND Max_Discount_Percent__c > ' + (thisProposal.Apttus_Proposal__Discount_Percent__c == null ? 0 : thisProposal.Apttus_Proposal__Discount_Percent__c) +
            ' AND Min_Discount_Amount__c <= ' + (usdDiscountValue == null ? 0 : usdDiscountValue) +
            ' AND Max_Discount_Amount__c > ' + (usdDiscountValue == null ? 0 : usdDiscountValue) +
            ' AND Country__c IN: countryCodes' + 
            ' AND Pricing_Tool__c = ' + '\'' + thisProposal.Select_Pricing_Tool__c + '\'' +
            ' AND Track_Name__c = ' + '\'' + CON_CPQ.CPQ + '\'' +
            ' AND Process_Type__c = ' + '\'' + CON_CPQ.APPROVAL_PROCESS + '\'';
        List<Approval_Matrix__c> approvalMatrix = new SLT_ApprovalMatrix().getApprover(fieldSet, condition, countryCodes);
        if (approvalMatrix.size() == 0) {
            return 'ERROR';
        }
        for (Approval_Matrix__c apm : approvalMatrix) {
            WPR_CPQ_ApprovalMatrix wcam = new WPR_CPQ_ApprovalMatrix();
            
            if(approversMap.containsKey(apm.Levels__c)){
                wcam = approversMap.get(apm.Levels__c);
            }
            if (apm.Approver_1__c != null) {
                wcam.approverIds.add(apm.Approver_1__c);
            }
            if (apm.Approver_2__c != null) {
                wcam.approverIds.add(apm.Approver_2__c);
            }
            if (apm.Approver_3__c != null) {
                wcam.approverIds.add(apm.Approver_3__c);
            }
            if (apm.Approver_4__c != null) {
                wcam.approverIds.add(apm.Approver_4__c);
            }
            if (apm.Approver_5__c != null) {
                wcam.approverIds.add(apm.Approver_5__c);
            }
            if (apm.Notifier_1__c != null) {
                wcam.notifiers.add(apm.Notifier_1__c);
            }
            if (apm.Notifier_2__c != null) {
                wcam.notifiers.add(apm.Notifier_2__c);
            }
            if (apm.Notifier_3__c != null) {
                wcam.notifiers.add(apm.Notifier_3__c);
            }
            if (apm.Notifier_4__c != null) {
                wcam.notifiers.add(apm.Notifier_4__c);
            }
            if (apm.Notifier_5__c != null) {
                wcam.notifiers.add(apm.Notifier_5__c);
            }
            wcam.approveOnFirstResponse = apm.Approve_On_First_Response__c;
            wcam.autoApprove = apm.Auto_Approve__c;
            approversMap.put(apm.Levels__c, wcam);
        }
        return 'SUCCESS';
    }
    
    public static String submitApprovalRequest(Apttus_Proposal__Proposal__c prop) {
	 
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
		
        WPR_CPQ_ApprovalMatrix aprObj = null;
        if (approversMap.containsKey('Level 1')) {
            aprObj = approversMap.get('Level 1');
        }
        if (aprObj != null || Test.isRunningTest()) {
            Apttus_Proposal__Proposal__c propApprs = new Apttus_Proposal__Proposal__c();
            propApprs.Id = prop.Id;
            propApprs.Approver_Level__c = 1;
            
            List<Id> approverList = new List<Id>();
            approverList.addAll(aprObj.approverIds);
            for (integer i = 1; i <= 5; i++) {
                if (aprObj.autoApprove) {
                    propApprs.put('Approver_' + i + '__c', UserInfo.getUserId());
                } else if (approverList.size() >= i && approverList.get(i - 1) != null) {
                    propApprs.put('Approver_' + i + '__c', approverList.get(i - 1));
                } else {
                    propApprs.put('Approver_' + i + '__c', propApprs.get('Approver_' + (i - 1) + '__c'));
                }
            }
            update propApprs;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for first level of approval');
            req1.setObjectId(prop.id);
            approvalRequests.add(req1);
		 
            Approval.process(approvalRequests);
            if (aprObj.notifiers.size() > 0) {
                sendEmailToNotifier(aprObj, prop);
            }
            
            String returnMessage = '';
            if (aprObj.autoApprove) {
                if (!approversMap.containsKey('Level 2')) {
                    List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(prop.Id);
                    Approval.process(createProcessWorkItemRequest(workItemIds[0].Id, null, 'Approve', 'Auto approved'));
                    returnMessage = 'Approved';
                } else {
                    returnMessage = checkForAutoApprove(2, approversMap.get('Level 2'), prop, null, 'Auto approved');
                }
            }
            CPQ_RMUtility.unlockApprovalProcess(new List<Apttus_Proposal__Proposal__c>{prop});
            returnMessage = 'SUCCESS';
            return returnMessage;
        } else {
            return 'ERROR';
        }
    }
    
    @AuraEnabled
    public static String updateOldApproverWithNew(String approversJSON, Id recordId){
        List<WPR_CPQ_Approvers> allApprovers = (List<WPR_CPQ_Approvers>) System.JSON.deserialize(approversJSON, List<WPR_CPQ_Approvers>.class);
        Map<Id, Id> userMap = new Map<Id, Id>();
        for (WPR_CPQ_Approvers approverObj: allApprovers) {
            if (approverObj.newUser.recordId != null && approverObj.newUser.recordId != approverObj.oldUser.recordId) {
                userMap.put(approverObj.instanceId, approverObj.newUser.recordId);
            }
        }
        
        List<ProcessInstanceWorkitem> processInstanceList = [SELECT Id, ActorId, ProcessInstance.SubmittedById, Actor.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recordId];
        List<ProcessInstanceWorkitem> newApproversWorkItem = new List<ProcessInstanceWorkitem>(); 
        for (ProcessInstanceWorkitem instanceObj: processInstanceList) {
            
            if (userMap.containsKey(instanceObj.Id)) {
                instanceObj.ActorId = userMap.get(instanceObj.Id);
                newApproversWorkItem.add(instanceObj);
            }
        }
        update newApproversWorkItem;
        return 'Success';
    }
    
    @AuraEnabled
    public static List<WPR_CPQ_Approvers> getActorProcessInstanceWorkItems(Id objectId) {
        List<ProcessInstanceWorkitem> lst = [SELECT Id, ActorId, ProcessInstance.SubmittedById, Actor.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: objectId];
        List<WPR_CPQ_Approvers> approverMap = new List<WPR_CPQ_Approvers>();
        for (ProcessInstanceWorkitem piwi : lst) {
            WPR_CPQ_Approvers approverObj = new WPR_CPQ_Approvers();
            WPR_CPQ_User userObj = new WPR_CPQ_User();
            userObj.searchField = piwi.Actor.Name;
            userObj.recordId = piwi.ActorId;
            userObj.Name = piwi.Actor.Name;
            approverObj.newUser = userObj;
            approverObj.oldUser = userObj;
            approverObj.instanceId = piwi.Id;
            approverMap.add(approverObj);
        }
        return approverMap;
    }
    
    public static List<ProcessInstanceWorkitem> getProcessInstanceWorkItems(Id objectId) {
        List<ProcessInstanceWorkitem> lst = [SELECT Id, ActorId, ProcessInstance.Status, ProcessInstanceId, Actor.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: objectId ORDER BY CreatedDate];
        return lst;
    }      
    
    public static Approval.ProcessWorkitemRequest createProcessWorkItemRequest(Id approvalStepId, Id approverId, String approvalAction, String commentFromApprover) {
        Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
        result.setComments(commentFromApprover);
        result.setAction(approvalAction);
        result.setWorkitemId(approvalStepId);
        if (approverId != null) {
            result.setNextApproverIds(new List<Id>{approverId});
        }
        return result;
    }
    
    @AuraEnabled
    public static String createWorkItemOnApprove(Id recordId, string comment) {
	    try {
            Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.APPROVAL_STAGE, CON_CPQ.APPROVAL_STATUS, 
                CON_CPQ.APPROVER_LEVEL, CON_CPQ.TOTAL_AMOUNT, CON_CPQ.COUNTRY_CODE, CON_CPQ.AVERAGE_GROSS_MARGIN, 
                CON_CPQ.DISCOUNT_PERCENT, CON_CPQ.DISCOUNT_AMOUNT, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL,
                CON_CPQ.OPPORTUNITY_NUMBER, CON_CPQ.PROPOSAL_OPPORTUNITY_NAME, CON_CPQ.Name, CON_CPQ.CONVERSION_DATE};
                Apttus_Proposal__Proposal__c thisProposal = new SLT_Proposal().getProposalDetails(recordId, fieldSet);
        
            fetchApprover(thisProposal);
        
            List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(recordId);
        
            boolean isPendingForAppr = false;
        
            WPR_CPQ_ApprovalMatrix aprObj1 = approversMap.get('Level ' + (Integer)(thisProposal.Approver_Level__c));
        
            Id piwiToUpdate = null;
        
            for(ProcessInstanceWorkitem piwi : workItemIds) {
                if (piwi.ProcessInstance.Status == CON_CPQ.PENDING && piwi.ActorId != UserInfo.getUserId()) {
                    isPendingForAppr = true;
                }
                if (piwi.ActorId == UserInfo.getUserId()) {
                    piwiToUpdate = piwi.Id;
                }
            }
            if (aprObj1.approveOnFirstResponse) {
                isPendingForAppr = false;
            }
        
            if (!isPendingForAppr && workItemIds.size() > 0) {							 
                String nextLevel ='Level ' + (Integer)(thisProposal.Approver_Level__c + 1);
                if (approversMap.containsKey(nextLevel)) {
                    WPR_CPQ_ApprovalMatrix aprObj = approversMap.get(nextLevel);
                    checkForAutoApprove((Integer)(thisProposal.Approver_Level__c + 1), aprObj, thisProposal, piwiToUpdate, comment);
                } else {
                    isPendingForAppr = true;
                }
            }
  
            if (aprObj1.approveOnFirstResponse && workItemIds.size() > 0) {
                if (workItemIds.size() > 1) {
                    approveAllRecords(recordId, comment);
                } else {
                    List<ProcessInstanceWorkitem> piwiList = [SELECT ID FROM ProcessInstanceWorkitem WHERE Id =: piwiToUpdate];
                    if (piwiList.size() > 0) {
                        Approval.process(createProcessWorkItemRequest(piwiToUpdate, null, 'Approve', comment));
                    }
                }  
            }  else if (piwiToUpdate != null && isPendingForAppr) {
                Approval.process(createProcessWorkItemRequest(piwiToUpdate, null, 'Approve', comment));
            }
            CPQ_RMUtility.unlockApprovalProcess(new List<Apttus_Proposal__Proposal__c>{thisProposal});
            return 'Approved';

        } catch(Exception ex) {
            return ex.getMessage();
        }
    }
	
    @future 
    public static void approveAllRecords(Id recordId, String comment) {
        List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(recordId);
        for (ProcessInstanceWorkitem piwi : workItemIds) {
            Approval.process(createProcessWorkItemRequest(piwi.Id, null, 'Approve', comment));
        }
        CPQ_RMUtility.unlockApprovalProcess(new List<Apttus_Proposal__Proposal__c>{new Apttus_Proposal__Proposal__c(Id = recordId)});
    }
	
    public static String checkForAutoApprove(Integer level, WPR_CPQ_ApprovalMatrix newMatrix, Apttus_Proposal__Proposal__c prop, Id piwiToUpdate, String comment){
        try {
            String result = '';
            if (newMatrix != null && newMatrix.autoApprove) {            
                Apttus_Proposal__Proposal__c propApprs = new Apttus_Proposal__Proposal__c();
                propApprs.Id = prop.Id;
                propApprs.Approver_Level__c = level;
                level++;
            
                for (integer i = 1; i <= 5; i++) {														  
                    propApprs.put('Approver_' + i + '__c', UserInfo.getUserId());
                }
                update propApprs;
                if (newMatrix.notifiers.size() > 0) {
                    sendEmailToNotifier(newMatrix, prop);
                }
            
                if (piwiToUpdate == null) {
                    List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(prop.Id);
                    if (workItemIds.size() > 0) {
                        Approval.process(createProcessWorkItemRequest(workItemIds[0].Id, null, 'Approve', 'Auto approved'));
                    }                
                } else {
                    Approval.process(createProcessWorkItemRequest(piwiToUpdate, null, 'Approve', comment));
                }
                if (approversMap.containsKey('Level ' + level)) {
                    result = checkForAutoApprove(level, approversMap.get('Level ' + level), prop, null, 'Auto approved');
                } else {    
                    List<ProcessInstanceWorkitem> workItemId = getProcessInstanceWorkItems(prop.Id);
                    if (workItemId.size() > 0) {
                        Approval.process(createProcessWorkItemRequest(workItemId[0].Id, null, 'Approve', 'Auto approved'));
                    }
                    return 'Approved';
                }
            } else {
                Apttus_Proposal__Proposal__c propApprs = new Apttus_Proposal__Proposal__c(Id = prop.Id);
                List<Id> approverList = new List<Id>();
                approverList.addAll(newMatrix.approverIds);
                for (integer i = 1; i <= 5; i++) {
                    if (approverList.size() >= i && approverList.get(i - 1) != null) {
                        propApprs.put('Approver_' + i + '__c', approverList.get(i - 1));
                    } else {
                        propApprs.put('Approver_' + i + '__c', propApprs.get('Approver_' + (i - 1) + '__c'));
                    }
                }
                propApprs.Approver_Level__c = level;
                update propApprs;
                if (newMatrix.notifiers.size() > 0) {
                    sendEmailToNotifier(newMatrix, prop);
                }
                List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(prop.Id);
   
                if (workItemIds.size() > 0) {
                    Approval.process(createProcessWorkItemRequest(workItemIds[0].Id, null, 'Approve', comment));  
                }
                return 'SUCCESS';
            }
            return result;
        } catch(Exception ex) {
            return ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static void createWorkItemOnReject(Id recordId, string comment) {
        Id workItemId = null;
        List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(recordId);       
        Id nextApproverId = UserInfo.getUserId();
        String approvalAction = 'Reject';
        String commentFromApprover = comment;
        for (ProcessInstanceWorkitem pi : workItemIds) {
            if (pi.ActorId == UserInfo.getUserId()) {
                workItemId = pi.Id;
            }
        }
        if (workItemId != null) {
            Approval.process(createProcessWorkItemRequest(workItemId, nextApproverId, approvalAction, commentFromApprover));
        }
    }
    
    @AuraEnabled
    public static void updateQuoteStatusOCE(Id recordId, String stage, String status) {
        try {
            update new Apttus_Proposal__Proposal__c(Id = recordId, Apttus_Proposal__Approval_Stage__c = stage, Approval_Status__c = status);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void sendEmailToNotifier(WPR_CPQ_ApprovalMatrix approvalMatrix, Apttus_Proposal__Proposal__c proposal) {
        Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
        try {
            objWorkFlowEmail.Related_To_Object_Id__c = proposal.Id;
            objWorkFlowEmail.Related_To_Object_Api__c = CON_CPQ.APTTUS_PROPOSAL_PROPOSAL;
            objWorkFlowEmail.Module_Name__c = CON_CPQ.CPQ;
            objWorkFlowEmail.Email_Action__c = 'CPQ_01_SendEmail';
            objWorkFlowEmail.Email_Subject__c = 'Approval Request Notification '+ proposal.Opportunity_Number__c + ' ' + proposal.Apttus_Proposal__Opportunity__r.Name + ' ' + proposal.Name;
            objWorkFlowEmail.content_1__c = URL.getOrgDomainUrl().toExternalForm() + '/' + proposal.Id;
            List<String> notifiersList = new List<String>();
            notifiersList.addAll(approvalMatrix.notifiers);
            
            for (integer i = 1; i <= 5; i++) {
                if (notifiersList.size() >= i && notifiersList.get(i-1) != null) {									   
                    objWorkFlowEmail.put('To_Email_' + i + '__c', notifiersList.get(i-1));
                }  
            }
            insert objWorkFlowEmail;
        }
        catch(Exception ex) {
            system.debug('Exception:'+ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getCollaborationConfigCartURL(Id recordId) {
        
        Apttus_Config2__CollaborationRequest__c collabRequest = [SELECT Id, OwnerId, Apttus_Config2__Status__c, Apttus_Config2__ParentConfigurationId__r.Apttus_QPConfig__Proposald__r.Select_Pricing_Tool__c, Apttus_Config2__ParentConfigurationId__r.Apttus_QPConfig__Proposald__c FROM Apttus_Config2__CollaborationRequest__c WHERE Id =: recordId];
        Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(collabRequest.Apttus_Config2__ParentConfigurationId__r.Apttus_QPConfig__Proposald__c, new Set<String> {CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL});
        String isOwnerWithFlow;
        for (CPQ_Proposal_Create_Settings__c customSetting : CPQ_Proposal_Create_Settings__c.getall().values()) {
            if (customSetting.Available_Pricing_Tools__c == proposal.Select_Pricing_Tool__c)  {
                isOwnerWithFlow = customSetting.Flow_Name__c;
            }
        }
        if (collabRequest.OwnerId == userInfo.getUserId() && !(collabRequest.Apttus_Config2__Status__c == 'Cancelled' || collabRequest.Apttus_Config2__Status__c == 'Deleted' || collabRequest.Apttus_Config2__Status__c == 'Abandoned')) {
            isOwnerWithFlow += '&true';
        } else {
            isOwnerWithFlow += '&false';
        }
        return isOwnerWithFlow;
    }
    
    public class WPR_CPQ_ProposalDetails {
        @AuraEnabled
        public Id recordId {get; set;}
        /*@AuraEnabled
        public Id iqviaQuoteId {get; set;}*/
        @AuraEnabled
        public Apttus_Proposal__Proposal__c proposalSObject {get; set;}
        @AuraEnabled
        public String approvalStage {get; set;}
        @AuraEnabled
        public String approvalStatus {get; set;}
        @AuraEnabled
        public String pricingTool {get; set;}
        @AuraEnabled
        public String error {get; set;}
        @AuraEnabled
        public Boolean isPrimary {get; set;}
        @AuraEnabled
        public Boolean isrecordTypeNameTechSolution{get; set;}
        @AuraEnabled
        public Boolean isPriceListAttached {get; set;}
        @AuraEnabled
        public Boolean isSpecialPricingCommentRequired {get; set;}
        @AuraEnabled
        public Boolean cssFileAttached {get; set;}
        @AuraEnabled
        public Boolean isAllowedToEditAction {get; set;}
        @AuraEnabled
        public String priceListName {get; set;}
        @AuraEnabled
        public String flowName {get; set;}
        @AuraEnabled
        public String syncStatus {get; set;}
        @AuraEnabled
        public String syncMessage {get; set;}
        @AuraEnabled
        public Boolean proposalValidity {get; set;}
        @AuraEnabled
        public String recordTypeName {get;set;}
        @AuraEnabled
        public String country {get;set;}
        @AuraEnabled
        public Boolean isApprover {get; set;}
        @AuraEnabled
        public Boolean isOwner {get; set;}
        @AuraEnabled
        public Boolean isAdmin {get; set;}
        @AuraEnabled
        public Decimal quoteAmount {get;set;}
        @AuraEnabled
        public Decimal discountPercent {get; set;}
        @AuraEnabled
        public Decimal discountAmount {get; set;}
        @AuraEnabled
        public Id quoteOwnerId {get; set;}
        @AuraEnabled
        public Boolean isAgreementCreated {get; set;}
        @AuraEnabled
        public Boolean canCreateAgreement {get; set;}
        
        public WPR_CPQ_ProposalDetails() {
            proposalSObject = new Apttus_Proposal__Proposal__c(); 
            isPrimary = false;
            isrecordTypeNameTechSolution = false;
            isPriceListAttached = false;
            isSpecialPricingCommentRequired = false;
            proposalValidity = false;
            cssFileAttached = false;
            isAllowedToEditAction = false;
            canCreateAgreement = false;
        }
    }
    
    public class WPR_CPQ_Approvers {
        @AuraEnabled
        public Id instanceId {get; set;}
        @AuraEnabled
        public WPR_CPQ_User oldUser {get; set;}
		@AuraEnabled
        public WPR_CPQ_User newUser {get; set;}
    }
    
    public class WPR_CPQ_User {
        @AuraEnabled
        public Id recordId {get; set;}
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String searchField {get; set;}
    }
    
    public class WPR_CPQ_ApprovalMatrix {
        @AuraEnabled
        public Set<Id> approverIds {get; set;}
        @AuraEnabled
        public boolean approveOnFirstResponse {get; set;}
        @AuraEnabled
        public boolean autoApprove {get; set;}
        @AuraEnabled
        public Set<String> notifiers {get; set;}
        
        public WPR_CPQ_ApprovalMatrix() {
            this.approverIds = new Set<Id>();
            this.approveOnFirstResponse = false;
            this.autoApprove = false;
            this.notifiers = new Set<String>();
        }
    }
}
