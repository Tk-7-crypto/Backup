public  without sharing class CNT_CPQ_BudgetWorkflowController {

    /* Commented under LC-11451
    @AuraEnabled
    public static String reject(Id recordId) 
    {
        try 
        {
            Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(recordId, new Set<String> {CON_CPQ.ID, 
                CON_CPQ.APPROVAL_STAGE, CON_CPQ.APPROVAL_STATUS, CON_CPQ.PROPOSAL_CATEGORY});
            
            ProcessInstanceWorkitem[] workItems = new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemByTargetIdAndStatus(new Set<Id>{proposal.Id}, 
                CON_CPQ.PENDING, new Set<String>{CON_CPQ.Id});
            for (ProcessInstanceWorkitem workItem: workItems) 
            {
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setAction(CON_CPQ.REMOVED);
                pwr.setWorkItemId(workItem.id);
                Approval.ProcessResult result = Approval.process(pwr);
            }
            /* Commented under LC-9356    
            if (proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC 
                || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY 
                || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF 
                || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER
                || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK)
                updateQuoteStatus(proposal.Id, CON_CPQ.DRAFT, CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW);
            else	//Comment end under LC-11451
            updateQuoteStatus(proposal.Id, CON_CPQ.DRAFT, CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW);
            return '';
        } 
        catch(Exception e) 
        {
            return e.getMessage();
        }
    }*/
	
    @AuraEnabled
    public static String updateQuoteStatus(Id recordId, String stage, String status) {
        try {
            update new Apttus_Proposal__Proposal__c(Id = recordId, Apttus_Proposal__Approval_Stage__c = stage, Approval_Status__c = status);
            Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(recordId, new Set<String> {CON_CPQ.ID, CON_CPQ.PROPOSAL_CATEGORY});
            if (stage == CON_CPQ.ACCEPTED && proposal != null && proposal.Apttus_Proposal__Proposal_Category__c != CON_CPQ.INITIAL && proposal.Apttus_Proposal__Proposal_Category__c != CON_CPQ.REBID) {
                CPQ_Utility.syncProtocolNumberOnOpp(new Set<Id>{recordId});
            }
            return '';
        } catch(Exception e) {
            return e.getMessage();
        }
    }
    /* Commented under LC-10187 to remove ref. of Reviewer/Final Reviewer picklist value from Team Member object
    @AuraEnabled
    public static String insertQCReviewers(Id recordId, String reviewerIds) {
        try {
            List<String> reviewerUserIds = reviewerIds.split(CON_CPQ.COMMA);
            Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(recordId, new Set<String> {CON_CPQ.ID, 
                CON_CPQ.APPROVAL_STAGE, CON_CPQ.APPROVAL_STATUS, CON_CPQ.PROPOSAL_OPPORTUNITY_NAME, CON_CPQ.PROPOSAL_RELATED_ACCOUNT_NAME});
			
            String role = (proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.DRAFT ? CON_CPQ.QC_REVIEWER : CON_CPQ.FINAL_QC_REVIEWER);
            List<String> roleList =  new List<String> {role};
            List<Team_Member__c> proposalMemberList = new SLT_TeamMember().getTeamMemberByProposalIdANDMemberRole(new Set<ID> {recordId}, new Set<String>{CON_CPQ.ID, CON_CPQ.USER_FIELD, CON_CPQ.MEMBER_ROLE, CON_CPQ.ROLE_FROM_RR}, roleList);
            Set<Id> existingUserIdSet = new Set<Id>();
            List<Team_Member__c> proposalMemeberDeletionList = new List<Team_Member__c>();
            if (proposalMemberList.size() > 0) {
                for (Team_Member__c teamMember : proposalMemberList) {
                    if (reviewerUserIds.contains(teamMember.User__c)) {
                        existingUserIdSet.add(teamMember.User__c);
                    } else {
                        proposalMemeberDeletionList.add(teamMember);
                    }
                }
            }
            if (proposalMemeberDeletionList.size() > 0)
                delete proposalMemeberDeletionList;
            List<Team_Member__c> proposalMemberInsertionList = new List<Team_Member__c>();
            for (String userId : reviewerUserIds) {
                if (proposalMemberList.isEmpty() || !(existingUserIdSet.contains(userId))) {
                    proposalMemberInsertionList.add(new Team_Member__c(User__c = (Id)userId.trim(), Member_Role__c = role, Proposal__c = recordId));
                }
            }
            if (proposalMemberInsertionList.size() >0 )
                insert proposalMemberInsertionList;
            if (proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.DRAFT) {
                updateQuoteStatus(proposal.Id, CON_CPQ.DRAFT, CON_CPQ.QC_REVIEW_DRAFT);
            } else if (proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.FINAL_REVIEW) {
                updateQuoteStatus(proposal.Id, CON_CPQ.FINAL_REVIEW, CON_CPQ.QC_REVIEW_FINAL);
            }
            
            if (proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.DRAFT)
                sendEmailToReviewer(proposal, reviewerUserIds, CON_CPQ.DRAFT_REVIEW);
            else if (proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.FINAL_REVIEW)
                sendEmailToReviewer(proposal, reviewerUserIds, CON_CPQ.FINAL_REVIEW);
                
            return '';
        } catch(Exception e) {
            return e.getMessage();
        }
    }*/
    
    @AuraEnabled
    public static ProposalDetails getProposalDetails(Id recordId) {
        ProposalDetails proposalObj = new ProposalDetails();
        try {        
            Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL,
                CON_CPQ.APPROVAL_STAGE, CON_CPQ.APPROVAL_STATUS, CON_CPQ.RELATED_CLINICAL_OPPORTUNITY_TYPE, CON_CPQ.OWNER,
                CON_CPQ.IS_STRATEGY_CALL_REQUIRED, CON_CPQ.IS_MAP_CALL_REQUIRED, CON_CPQ.STRATEGY_CALL_DATE, CON_CPQ.MAP_CALL_DATE, CON_CPQ.FINAL_REVIEW_CALL_NOTES,
                CON_CPQ.APTTUS_PROPOSAL_PRIMARY, CON_CPQ.FIELD_FINALIZE_DATE, CON_CPQ.PROPOSAL_CATEGORY, CON_CPQ.RECORDTYPEID, CON_CPQ.CHNAGE_ORDER_NUMBER, CON_CPQ.CNF_APPROVAL_DATE,
                CON_CPQ.CNF_STATUS, CON_CPQ.EXECUTED_DATE, CON_CPQ.RELATED_OPPORTUNITY_STAGENAME, CON_CPQ.RFP_SCENARIO, CON_CPQ.BUDGET_SYNC_STATUS,
                CON_CPQ.RELATED_AGREEMENT_STATUS_CATEGORY, 
                CON_CPQ.RELATED_AGREEMENT_STATUS, CON_CPQ.BID_RECORD_TYPE_NAME};
            Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(recordId, fieldSet);
            String QCRole = (proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.DRAFT ? CON_CPQ.QC_REVIEWER : (proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.FINAL_REVIEW ? CON_CPQ.FINAL_QC_REVIEWER : ''));
            List<String> roles = new List<String> {CON_CPQ.APPROVER};
            if (QCRole != null && QCRole != '') {
                roles.add(QCRole);
            }
            List<Team_Member__c> teamMemberList = new SLT_TeamMember().getTeamMemberByProposalIdANDMemberRole(new Set<ID> {proposal.Id}, new Set<String>{CON_CPQ.ID, CON_CPQ.USER_FIELD, CON_CPQ.CONTACT, CON_CPQ.MEMBER_ROLE, CON_CPQ.ROLE_FROM_RR}, roles);
            List<Profile> sysAdminProfileList = new SLT_Profile().getAdminProfiles(new Set<String> {CON_CPQ.ID, CON_CPQ.NAME});
            Set<Id> sysAdminProfileIdSet = new Set<Id>();
            for(Profile profile : sysAdminProfileList){
                sysAdminProfileIdSet.add(profile.id);
            }
            
            CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
            
            List<ProcessInstance>  processInstance = new SLT_ProcessInstance().getProcessInstanceByTargetObjectIdAndStatus(new Set<Id> {proposal.Id}, CON_CPQ.PENDING,
                new Set<String> {CON_CPQ.TARGET_OBEJCT_ID, CON_CPQ.SUBMITTED_BY_ID, CON_CPQ.STATUS});
            proposalObj.approvalStatus = proposal.Approval_Status__c;
            proposalObj.recordId = proposal.Id;
            proposalObj.tool = proposal.Select_Pricing_Tool__c;
            proposalObj.approvalStage = proposal.Apttus_Proposal__Approval_Stage__c;
            proposalObj.isMapCallRequired = proposal.Is_Map_Call_Required__c;
            proposalObj.mapCallDate = proposal.Map_Call_Date__c;
            proposalObj.isStrategyCallRequired = proposal.Is_Strategy_Call_Required__c;
            proposalObj.strategyCallDate = proposal.Strategy_Call_Date__c;
            proposalObj.finalReviewCallNotes = proposal.Final_Review_Call_Notes__c;
            proposalObj.selectedQCReviewerIds = '';
            proposalObj.psApproverId = '';
            proposalObj.spApproverId = '';
            proposalObj.isPrimary = proposal.Apttus_Proposal__Primary__c;
            proposalObj.isFinalized = proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c != null;
            proposalObj.isApproverMissing = true;
            proposalObj.isBudgetTypeNeitherCNFNorChangeOrder = proposal.Apttus_Proposal__Proposal_Category__c != CON_CPQ.CNF && proposal.Apttus_Proposal__Proposal_Category__c != CON_CPQ.CHNAGE_ORDER ? True : False ;
            proposalObj.isPLIExist = checkPLIOnProposal(proposal.Id);
            proposalObj.isBudgetTypeInitialOrRebid = proposal.Apttus_Proposal__Proposal_Category__c != CON_CPQ.INITIAL && proposal.Apttus_Proposal__Proposal_Category__c != CON_CPQ.REBID ? False : True ;
            proposalObj.isBudgetTypeNotProjectSpecific = proposal.Apttus_Proposal__Proposal_Category__c != CON_CPQ.PROJECT_SPECIFIC ? True : False ;
            proposalObj.isrecordTypeNameRDSBudget = proposal.RECORDTYPEID == CPQ_Utility.proposalBudgetRecordTypeId ? true : false;
            proposalObj.budgetType = proposal.Apttus_Proposal__Proposal_Category__c;
            proposalObj.isCNFApprovalDateOrChangeOrderNumberExist = proposal.CNF_Approval_Date__c != null && proposal.Change_Order_Number__c != null && proposal.CNF_Status__c == CON_CPQ.ACCEPTED;
            proposalObj.isExecutedDateNull = proposal.Executed_Date__c != null ? false : true;
            proposalObj.isBudgetInactive = proposal.RFP_Scenario__c == CON_CPQ.INACTIVE ? True : False;
            proposalObj.isOpportunityStageFinalisingDealOrHigher = !CON_CPQ.OPPORTUNITY_STAGES.contains(proposal.Apttus_Proposal__Opportunity__r.StageName) && proposal.Apttus_Proposal__Opportunity__r.StageName != CON_CPQ.OPPORTUNITY_STAGE_7B_CLOSED_LOST;
            proposalObj.isCNFRejected = proposal.CNF_Status__c == CON_CPQ.REJECTED ? True : False;
            proposalObj.syncStatus = proposal.Execution_Status__c;
            proposalObj.timeoutDelay = cpqSetting.Timeout_Delay__c;
            proposalObj.isApprovalDateExistAndStatusIsAccepted = proposal.CNF_Approval_Date__c != null && proposal.CNF_Status__c == CON_CPQ.ACCEPTED;
            proposalObj.cnfStatus = proposal.CNF_Status__c;
            proposalObj.isRelatedAgreementIsActivated = proposal.Apttus_QPComply__MasterAgreementId__r.Apttus__Status_Category__c == CON_CPQ.AGREEMENT_STATUS_CATEGORY_IN_EFFECT && proposal.Apttus_QPComply__MasterAgreementId__r.Apttus__Status__c == CON_CPQ.AGREEMENT_STATUS_ACTIVATED;
            if (proposal.Apttus_QPComply__MasterAgreementId__c == null && proposal.Clinical_Bid__c != null && proposal.Clinical_Bid__r.Record_Type_Developer_Name__c == CON_CPQ.CONTRACT_POST_AWARD) {
                proposalObj.isCreateAgreement = true;
            }
            proposalObj.clmFlowName = cpqSetting.CLM_Flow__c;
            List<GroupMember> groupMemberList = new SLT_GroupMember().getGroupMemberByUserAndGroupDeveloperName(UserInfo.getUserId(), CON_CPQ.CPQ_ADMIN_USERS_FOR_INACTIVE_QUOTES);
            if (groupMemberList !=null && !groupMemberList.isEmpty()) {
                proposalObj.isInactiveButtonVisible = True;
            }
            else {
                proposalObj.isInactiveButtonVisible = False; 
            }																					  
            if (teamMemberList.size() > 0) {
                for (Team_Member__c member : teamMemberList) {
                    if (member.Member_Role__c == CON_CPQ.APPROVER && (member.User__c != null || (!proposalObj.isBudgetTypeInitialOrRebid && member.Contact__c != null))) {
                        proposalObj.approver = member.User__c == null ? member.Contact__c : member.User__c;
                        proposalObj.isApproverMissing = false;
                        if(member.User__c != null && member.Role_from_RR__c == CON_CPQ.LCS_PRODUCT_SPECIALIST)
                            proposalObj.psApproverId =  member.User__c;
                        /*Commented under LC-9607 to remove approval process by Strategic Pricing user
                        else if(member.User__c != null && member.Role_from_RR__c == CON_CPQ.STRATEGIC_PRICING_LEAD)
                            proposalObj.spApproverId =  member.User__c;*/
                    }
                    else if (QCRole != null && QCRole != '' && member.Member_Role__c == QCRole) {
                        proposalObj.selectedQCReviewerIds = proposalObj.selectedQCReviewerIds + member.User__c + CON_CPQ.COMMA;
                    }
                }
            }
            if (proposalObj.approvalStatus == CON_CPQ.NONE || proposalObj.approvalStatus == CON_CPQ.SELF_CHECK_DRAFT) {
                proposalObj.isDraft = true;
            } else {
                proposalObj.isDraft = false;
            }
            if (proposalObj.approvalStage == CON_CPQ.SUBMIT_FOR_REVIEW || 
                proposalObj.approvalStage == CON_CPQ.PENDING_APPROVAL || proposalObj.approvalStage == CON_CPQ.SIGN_OFF
                || proposalObj.approvalStage == CON_CPQ.GENERATED) {
                proposalObj.isRecallVisible = true;
            } else {
                proposalObj.isRecallVisible = false;
            }
            
            if ((proposalObj.approvalStatus == CON_CPQ.QC_REVIEW_DRAFT || proposalObj.approvalStatus == CON_CPQ.QC_REVIEW_FINAL) &&
            	(sysAdminProfileIdSet.contains(UserInfo.getProfileId()) || proposalObj.selectedQCReviewerIds.contains(UserInfo.getUserId()))) {
                proposalObj.isQCReviewer = true;
            } else {
                proposalObj.isQCReviewer = false;
            }
            if ((proposalObj.approvalStatus == 'PS Approval Pending' && (sysAdminProfileIdSet.contains(UserInfo.getProfileId()) || proposalObj.psApproverId == UserInfo.getUserId()))
                || (proposalObj.approvalStatus == 'SP Approval Pending' && (sysAdminProfileIdSet.contains(UserInfo.getProfileId()) || proposalObj.spApproverId == UserInfo.getUserId())))
            {
                proposalObj.isQCApprover = true;
            }
            else
            {
                proposalObj.isQCApprover = false;
            }
            if (proposalObj.approvalStage == CON_CPQ.PENDING_APPROVAL){
                proposalObj.isTSLOffline = true;
            }
            else{
                proposalObj.isTSLOffline = false;
            }
            CPQ_Setting__mdt linkToFAQ = [SELECT Id, URL__c from CPQ_Setting__mdt WHERE DeveloperName = 'Link_to_FAQ' LIMIT 1];
            if(linkToFAQ != null) {
                proposalObj.linkToFAQ = linkToFAQ.URL__c;
            }
            return proposalObj;
        } catch (Exception e) {
            proposalObj.error = e.getMessage();
            return proposalObj;
        }
    }
	
    /* Commented under LC-11451
    @AuraEnabled
    public static void fireAprrovalRequest(Id proposalId, Id approver) {
        try {            
            List<Apttus_Proposal__Proposal__c> proposalList = new SLT_Proposal().getProposalFieldsById(new Set<Id> {proposalId}, new Set<String> {CON_CPQ.Id, CON_CPQ.OWNER});
            submitApprovalWithUnlockBudget(proposalList, approver);
            updateQuoteStatus(proposalId, CON_CPQ.PENDING_APPROVAL, CON_CPQ.CHALLENGE_REVIEW_COMPLETED_SUBMITTED_TSL_REVIEW);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void submitApprovalWithUnlockBudget(List<Apttus_Proposal__Proposal__c> proposalList, Id approver) {
        List<Id> approverIds = new List<Id>();
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(proposalList[0].Id);
        request.setSubmitterId(proposalList[0].OwnerId);
        request.setNextApproverIds(new Id[] {approver});
        Approval.ProcessResult result = Approval.process(request);
        unlockApprovalProcess(proposalList);
        
    }*/
    
    public static void unlockApprovalProcess(List<Apttus_Proposal__Proposal__c> proposalList) {        
        List<Approval.UnlockResult> ulrList = Approval.unlock(proposalList, false);
        for (Approval.UnlockResult  ulr : ulrList) {
            if (ulr.isSuccess()) {
                System.debug('Successfully unlocked account with ID: ' + ulr.getId());
            } else {            
                for (Database.Error err : ulr.getErrors()) {                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }
    
    @auraEnabled
    public static String createPreliminaryAgreement(Id quoteId) 
    {
        return UTL_CLM.createPreliminaryRecordFromQuote(quoteId);
    }

    public static Boolean checkPLIOnProposal(Id proposalId) {
        try {            
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = new SLT_ProposalLineItems().selectByQuoteId(proposalId);
            if(proposalLineItemList.size() > 0)
                return true;
            else
                return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* Commented under LC-11451
    @AuraEnabled
    public static String updateQuoteStatusAndSendEmail(Id recordId, String stage, String status, String reviewerUserId) 
    {
        try 
        {
            updateQuoteStatus(recordId, stage, status);
            
            Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(recordId, 
                new Set<String> {CON_CPQ.ID, CON_CPQ.PROPOSAL_OPPORTUNITY_NAME, CON_CPQ.PROPOSAL_RELATED_ACCOUNT_NAME});
            
            if (status == CON_CPQ.PS_APPROVAL_PENDING)
                sendEmailToReviewer(proposal, new List<String>{reviewerUserId}, CON_CPQ.PS_REVIEW);
            else if (status == CON_CPQ.SP_APPROVAL_PENDING)
                sendEmailToReviewer(proposal, new List<String>{reviewerUserId}, CON_CPQ.SP_REVIEW);
            return '';
        } 
        catch(Exception e) 
        {
            return e.getMessage();
        }
    }
    
    public static void sendEmailToReviewer(Apttus_Proposal__Proposal__c proposal, List<String> reviewerUserIds, String stagePlaceholder) 
    {
        Messaging.SingleEmailMessage mail = CPQ_Utility.getSingleMessage(CON_CPQ.CPQ_QC_REVIEWER_ASSIGNMENT_EMAIL_NOTIFICATION, 
            proposal.Id, UserInfo.getUserId(), reviewerUserIds);
        String htmlBody = mail.getHtmlbody();
        htmlBody = htmlBody.replace(CON_CPQ.QC_STAGE_PLACEHOLDER, stagePlaceholder);
        htmlBody = htmlBody.replaceAll(CON_CPQ.OPPORTUNIY_NAME_PLACEHOLDER, (proposal.Apttus_Proposal__Opportunity__r.Name != null ? proposal.Apttus_Proposal__Opportunity__r.Name : ''));
        htmlBody = htmlBody.replaceFirst(CON_CPQ.OPPORTUNIY_ACCOUNT_PLACEHOLDER, (proposal.Apttus_Proposal__Account__r.Name != null ? proposal.Apttus_Proposal__Account__r.Name : ''));
        mail.setHtmlBody(htmlBody);
        String mailSubject = mail.getSubject();
        mailSubject = mailSubject.replace(CON_CPQ.QC_STAGE_PLACEHOLDER, stagePlaceholder);
        mailSubject = mailSubject.replaceAll(CON_CPQ.OPPORTUNIY_NAME_PLACEHOLDER, (proposal.Apttus_Proposal__Opportunity__r.Name != null ? proposal.Apttus_Proposal__Opportunity__r.Name : ''));
        mailSubject = mailSubject.replaceFirst(CON_CPQ.OPPORTUNIY_ACCOUNT_PLACEHOLDER, (proposal.Apttus_Proposal__Account__r.Name != null ? proposal.Apttus_Proposal__Account__r.Name : ''));
        mail.setSubject(mailSubject);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }*/
    //LXC_CPQ_BudgetInactivate component's controller method
    @AuraEnabled
    public static void saveQuoteRecord(Id proposalId, string reason) {
        update new Apttus_Proposal__Proposal__c(Id = proposalId, Scenario_Description__c = reason, RFP_Scenario__c = CON_CPQ.INACTIVE , Apttus_Proposal__Primary__c = false);
    }
    
    /* Commented under LC-11451
    @AuraEnabled
    public static String approve(Id recordID, string comment, string approvalStage, string approvalStatus) 
    {
        try 
        {	
            ProcessInstanceWorkitem[] workItems = new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemByTargetIdAndStatus(new Set<Id>{recordID}, 
            	CON_CPQ.PENDING, new Set<String>{CON_CPQ.Id});
            for (ProcessInstanceWorkitem workItem: workItems) 
            {
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setAction(CON_CPQ.APPROVE);
                pwr.setWorkItemId(workItem.id);
                pwr.setComments(comment);
                Approval.ProcessResult result = Approval.process(pwr);           
            }
  
            Set<String> teamMemberFieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.USER_NAME, CON_CPQ.TSL_APPROVE_OFFLINE,
                CON_CPQ.EMAIL_SUBJECT, CON_CPQ.EMAIL_BODY, CON_CPQ.MEMBER_ROLE, CON_CPQ.ROLE_FROM_RR, CON_CPQ.PROPOSAL,
                CON_CPQ.PROPOSAL_NUMBER, CON_CPQ.RELATED_PROPOSAL_NAME};
                    
            List<Team_Member__c> teamMemberList = new SLT_TeamMember().getTeamMemberByProposalIdANDMemberRole(new Set<Id> {recordID}, teamMemberFieldSet, new List<String>{CON_CPQ.APPROVER});
            String proposalURL = URL.getOrgDomainUrl().toExternalForm() +'/' + recordID;
            if (teamMemberList.size() > 0) {
                for (Team_Member__c teamMember : teamMemberList){
                    if ( teamMember.Member_Role__c == CON_CPQ.APPROVER ){
                        teamMember.TSL_Approve_Offline__c = true; 
                        teamMember.Email_Subject__c = CON_CPQ.TSL_OFFLINE_APPROVAL_EMAIL_SUBJECT;
                        teamMember.Email_Subject__c = teamMember.Email_Subject__c.replace('Proposal_Number',teamMember.Proposal__r.Name);
                        teamMember.Email_Subject__c = teamMember.Email_Subject__c.replace('Budget_Name', teamMember.Proposal__r.Apttus_Proposal__Proposal_Name__c);
                        
                        teamMember.Email_Body__c = CON_CPQ.TSL_OFFLINE_APPROVAL_EMAIL_BODY;
                        teamMember.Email_Body__c = teamMember.Email_Body__c.replace('TSL_Approver', teamMember.User__r.Name);
                        teamMember.Email_Body__c = teamMember.Email_Body__c.replace('Budget_Name', teamMember.Proposal__r.Apttus_Proposal__Proposal_Name__c);
                        teamMember.Email_Body__c = teamMember.Email_Body__c.replace('Proposal_Number', teamMember.Proposal__r.Name);
                        teamMember.Email_Body__c = teamMember.Email_Body__c.replace('Quote_Link', proposalURL);                        
                    }
                } 
                update teamMemberList;
            }
            return '';
        } 
        catch(Exception e) 
        {
            return e.getMessage();
        }
    }*/
    
    @AuraEnabled
    public static String syncBudgetWithOpportunity(Id recordId) 
    {
     try 
        {
            QUE_CPQ_SyncBudgetWithOpportunity syncBudgetWithOpportunityJob = new QUE_CPQ_SyncBudgetWithOpportunity(recordId, True);
            Id jobId = System.enqueueJob(syncBudgetWithOpportunityJob);
            return jobId;
        }
        catch(Exception ex) 
        {
            String errorMessage = ex.getMessage() + '\n' + ex.getStackTraceString();
            return ex.getMessage();
        }
    }

    public class ProposalDetails {
        @AuraEnabled
        public Id recordId {get; set;}
        @AuraEnabled
        public String approvalStatus {get; set;}
        @AuraEnabled
        public String approvalStage {get; set;}
        @AuraEnabled
        public Boolean isMapCallRequired {get; set;}
        @AuraEnabled
        public Date mapCallDate {get; set;}
        @AuraEnabled
        public Boolean isStrategyCallRequired {get; set;}
        @AuraEnabled
        public Date strategyCallDate {get; set;}
        @AuraEnabled
        public String finalReviewCallNotes {get; set;}
        @AuraEnabled
        public Boolean isApproverMissing {get; set;}
        @AuraEnabled
        public Id approver {get; set;}
        @AuraEnabled        
        public Boolean isDraft {get; set;}
        @AuraEnabled
        public String error {get; set;}
        @AuraEnabled
        public Boolean isRecallVisible {get; set;}
        @AuraEnabled
        public Boolean isQCReviewer {get; set;}
        @AuraEnabled
        public String selectedQCReviewerIds {get; set;}
        @AuraEnabled
        public Boolean isQCApprover {get; set;}
        @AuraEnabled
        public String psApproverId {get; set;}
        @AuraEnabled
        public String spApproverId {get; set;}
        @AuraEnabled
        public Boolean isPrimary {get; set;}
        @AuraEnabled
        public Boolean isFinalized {get; set;}
        @AuraEnabled
        public String tool {get; set;}
        @AuraEnabled
        public Boolean isBudgetTypeNeitherCNFNorChangeOrder {get; set;}
        @AuraEnabled
        public Boolean isPLIExist{get; set;}
        @AuraEnabled
        public Boolean isBudgetTypeInitialOrRebid{get; set;}
        @AuraEnabled
        public Boolean isBudgetTypeNotProjectSpecific{get; set;}
        @AuraEnabled
        public Boolean isrecordTypeNameRDSBudget{get; set;}
        @AuraEnabled
        public String budgetType {get; set;}
        @AuraEnabled
        public Boolean isCNFApprovalDateOrChangeOrderNumberExist {get; set;}			
        @AuraEnabled
        public Boolean isExecutedDateNull {get; set;}
        @AuraEnabled
        public Boolean isInactiveButtonVisible {get; set;}
        @AuraEnabled
        public Boolean isBudgetInactive {get; set;}
        @AuraEnabled
        public Boolean isOpportunityStageFinalisingDealOrHigher {get; set;}
        @AuraEnabled
        public Boolean isCNFRejected {get; set;}
        @AuraEnabled
        public Boolean isTSLOffline {get; set;}
        @AuraEnabled
        public String syncStatus {get; set;}
        @AuraEnabled
        public Decimal timeoutDelay {get; set;}
        @AuraEnabled
        public Boolean isApprovalDateExistAndStatusIsAccepted {get; set;}
        @AuraEnabled
        public String cnfStatus {get; set;}
        @AuraEnabled
        public Boolean isRelatedAgreementIsActivated {get; set;}
        @AuraEnabled
        public String linkToFAQ {get; set;}
        @AuraEnabled
        public String clmFlowName {get; set;}
        @AuraEnabled
        public Boolean isCreateAgreement {get; set;}
    }
}