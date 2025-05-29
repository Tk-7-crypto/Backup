public class DAOH_TeamMember {
    /**
    * This method used to recall the approval process where TSL change in mid and submit for approval for new TSL assigned.
    * @return  
    */
    public static void recallOldAndSubmitProposalForNewApproval(List<Team_Member__c> newTeamMemberList,
        Map<Id, Team_Member__c> oldRecordsMap) {
        /*Commented under LC-11457 to deactivate approval process
        Map<Id, Team_Member__c> selectedProposalIds = new Map<Id, Team_Member__c>();
        Set<Id> proposalToBeRecalled = new Set<Id>();
        Set<Id> proposalToBeUnlock = new Set<Id>();
        Map<Id, Apttus_Proposal__Proposal__c> proposalRecordMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        Map<Id, Id> proposalUserMap = new Map<Id, Id>();
        
        for (Team_Member__c teamMember : newTeamMemberList) {
            if (teamMember.Member_Role__c == CON_CPQ.APPROVER && (teamMember.Role_from_RR__c == CON_CPQ.TSL || teamMember.Role_from_RR__c == CON_CPQ.TSL_JAPAN)) {
                if (teamMember.User__c != oldRecordsMap.get(teamMember.Id).User__c && teamMember.User__c != null) {
                    selectedProposalIds.put(teamMember.Proposal__c, teamMember);
                    proposalUserMap.put(teamMember.Proposal__c, oldRecordsMap.get(teamMember.Id).User__c);
                }
            }
        }
        if (!(selectedProposalIds == null || selectedProposalIds.isEmpty())) {
            proposalRecordMap = new SLT_Proposal().selectByProposalIds(selectedProposalIds.keySet(), new Set<String> {CON_CPQ.ID, CON_CPQ.APPROVAL_STAGE, CON_CPQ.APPROVAL_STATUS, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL, CON_CPQ.OWNER});
            if (!(proposalRecordMap == null || proposalRecordMap.isEmpty())) {                    
                for (Apttus_Proposal__Proposal__c proposalRecord : proposalRecordMap.values()) {
                    if (proposalRecord.Apttus_Proposal__Approval_Stage__c == CON_CPQ.PENDING_APPROVAL && proposalRecord.Approval_Status__c == CON_CPQ.CHALLENGE_REVIEW_COMPLETED_SUBMITTED_TSL_REVIEW && selectedProposalIds != null && selectedProposalIds.containsKey(proposalRecord.Id) && 
                        selectedProposalIds.get(proposalRecord.Id).Member_Role__c == CON_CPQ.APPROVER) {
                        proposalToBeRecalled.add(proposalRecord.Id);
                    }
                }
            }
        }
        if (proposalToBeRecalled.size()>0) {
            ProcessInstanceWorkitem[] workItems = new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemByTargetIdAndStatus(proposalToBeRecalled, CON_CPQ.PENDING, new Set<String>{CON_CPQ.ID, CON_CPQ.PROCESS_INSTANCE_TARGET_OBEJCT_ID, CON_CPQ.ACTORID});
            System.debug('workItems'+workItems);
            for (ProcessInstanceWorkitem workItem: workItems) {
                if (proposalUserMap.get(workItem.ProcessInstance.TargetObjectId) == workItem.ActorId) {
                    recallApprovalProcess(workItem.id);
                    Id userId = selectedProposalIds.get(workItem.ProcessInstance.TargetObjectId).User__c;
                    submitApprovalProcess(workItem.ProcessInstance.TargetObjectId, userId, proposalRecordMap.get(workItem.ProcessInstance.TargetObjectId).OwnerId);
                    proposalToBeUnlock.add(workItem.ProcessInstance.TargetObjectId);
                }                                                                                                                                                                               
            }
            if (proposalToBeUnlock.size()>0) {
                List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
                for (Id proposalId :proposalToBeUnlock) {
                    proposalList.add(new Apttus_Proposal__Proposal__c(Id = proposalId));
                }
                CNT_CPQ_BudgetWorkflowController.unlockApprovalProcess(proposalList);
            }
        }*/
    }
    
    /**
    * This method used to recall the approval process when Team member got delete in mid of the approval process.
    * @return  
    */
    public static void recallApprovalProcessOnDeletion(List<Team_Member__c> teamMemberList) {
        /*Commented under LC-11457 to deactivate approval process
        Map<Id, Team_Member__c> selectedProposalIds = new Map<Id, Team_Member__c>();
        Map<Id, Apttus_Proposal__Proposal__c>  proposalToBeRecalled = new Map<Id, Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal__c> proposalToBeUpdated = new List<Apttus_Proposal__Proposal__c>();
        Map<Id, Apttus_Proposal__Proposal__c> proposalRecordMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        Map<Id, Id> proposalUserMap = new Map<Id, Id>();
        Map<Id, Apttus_Proposal__Proposal__c>  updateProposalMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        
        for (Team_Member__c teamMember : teamMemberList) {
            if (teamMember.Member_Role__c == CON_CPQ.APPROVER && (teamMember.Role_from_RR__c == CON_CPQ.TSL || teamMember.Role_from_RR__c == CON_CPQ.TSL_JAPAN)) {
                selectedProposalIds.put(teamMember.Proposal__c, teamMember);
            }
        }
        if (!(selectedProposalIds == null || selectedProposalIds.isEmpty())) {
            proposalRecordMap = new SLT_Proposal().selectByProposalIds(selectedProposalIds.keySet(), new Set<String> {CON_CPQ.ID, CON_CPQ.APPROVAL_STAGE, CON_CPQ.APPROVAL_STATUS, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL});
            if (!(proposalRecordMap == null || proposalRecordMap.isEmpty())) {
                for (Apttus_Proposal__Proposal__c proposalRecord : proposalRecordMap.values()) {
                    if (proposalRecord.Apttus_Proposal__Approval_Stage__c == CON_CPQ.PENDING_APPROVAL && proposalRecord.Approval_Status__c == CON_CPQ.CHALLENGE_REVIEW_COMPLETED_SUBMITTED_TSL_REVIEW &&
                        selectedProposalIds != null && selectedProposalIds.containsKey(proposalRecord.Id) && selectedProposalIds.get(proposalRecord.Id).Member_Role__c == CON_CPQ.APPROVER) { 
                        proposalToBeRecalled.put(proposalRecord.Id, proposalRecord);
                    }
                }
            }
        }
        if (!(proposalToBeRecalled == null || proposalToBeRecalled.isEmpty())) {
            ProcessInstanceWorkitem[] workItems = new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemByTargetIdAndStatus(proposalToBeRecalled.keySet(), CON_CPQ.PENDING, new Set<String>{CON_CPQ.ID, CON_CPQ.PROCESS_INSTANCE_TARGET_OBEJCT_ID, CON_CPQ.ACTORID});
            for (ProcessInstanceWorkitem workItem: workItems) {
                if (selectedProposalIds.get(workItem.ProcessInstance.TargetObjectId).User__c == workItem.ActorId) {
                    recallApprovalProcess(workItem.id);
                    updateProposalMap.put(workItem.ProcessInstance.TargetObjectId, proposalToBeRecalled.get(workItem.ProcessInstance.TargetObjectId));
                }
            }
            if(!(updateProposalMap == null || updateProposalMap.isEmpty())) {
                for (Apttus_Proposal__Proposal__c proposalRecord : proposalToBeRecalled.values()) {
                    proposalRecord.Apttus_Proposal__Approval_Stage__c = CON_CPQ.SUBMIT_FOR_REVIEW ;
                    proposalRecord.Approval_Status__c = CON_CPQ.SUBMITTED_FOR_FUNCTIONAL_REVIEW;
                    proposalToBeUpdated.add(proposalRecord);
                }
            }
        }            
        if (proposalToBeUpdated.size() >0 ) 
            update proposalToBeUpdated;*/
    }
    
    /*Commented under LC-11457 to deactivate approval process
    private static void recallApprovalProcess(Id workItemId) {
        Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
        pwr.setAction('Removed');
        pwr.setWorkItemId(workItemId);
        Approval.ProcessResult result = Approval.process(pwr);
    }
    			
    private static void submitApprovalProcess(Id targetObjectId, Id approverId, Id ownerId) {
        Approval.ProcessSubmitRequest request= new Approval.ProcessSubmitRequest();
        request.setObjectId(targetObjectId);
        request.setSubmitterId(ownerId);
        request.setNextApproverIds(new Id[] {approverId});
        Approval.ProcessResult approvalResult = Approval.process(request);
    }*/
    /*Commented under LC-10187 to remove ref of Reviewer/Final Reviewer picklist value from Team Member object
    public static void sendQCNotification(List<Team_Member__c> newTeamMemberList, Map<Id, Team_Member__c> oldRecordsMap)
    {    
        List<Team_Member__c> changeQCTeamMemberList = new List<Team_Member__c>();
        Set<Id> qcUserIdSet = new Set<Id>();
        Set<Id> proposalIdSet = new Set<Id>();
        for (Team_Member__c teamMember : newTeamMemberList) 
        {
            if ((teamMember.Member_Role__c == CON_CPQ.QC_REVIEWER || teamMember.Member_Role__c == CON_CPQ.FINAL_QC_REVIEWER)
                && teamMember.User__c != oldRecordsMap.get(teamMember.Id).User__c && teamMember.User__c != null)
            {
                changeQCTeamMemberList.add(teamMember);
                qcUserIdSet.add(teamMember.User__c);
                qcUserIdSet.add(oldRecordsMap.get(teamMember.Id).User__c);
                proposalIdSet.add(teamMember.Proposal__c);
            }
        }
        
        Map<Id, User> userMap = new SLT_User().selectByUserId(qcUserIdSet,new Set<String>{CON_CPQ.ID, CON_CPQ.NAME,CON_CPQ.EMAIL});
        Map<Id, Apttus_Proposal__Proposal__c> proposalMap = new SLT_Proposal().selectByProposalIds(proposalIdSet, 
            new Set<String> {CON_CPQ.ID, CON_CPQ.PROPOSAL_OPPORTUNITY_NAME, CON_CPQ.PROPOSAL_RELATED_ACCOUNT_NAME});
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for (Team_Member__c teamMember : changeQCTeamMemberList) 
        {              
            Messaging.SingleEmailMessage oldQCMail = CPQ_Utility.getSingleMessage(CON_CPQ.CPQ_QC_REVIEWER_REASSIGNMENT_EMAIL_NOTIFICATION, 
                teamMember.Proposal__c, UserInfo.getUserId(), new List<String>{oldRecordsMap.get(teamMember.Id).User__c});
            oldQCMail.setHtmlBody(oldQCMail.getHtmlbody().replaceAll(CON_CPQ.REPLACE_OLD_QC_REVIEWER,userMap.get(oldRecordsMap.get(teamMember.Id).User__c).Name));
            oldQCMail.setHtmlBody(oldQCMail.getHtmlbody().replaceAll(CON_CPQ.REPLACE_NEW_QC_REVIEWER,userMap.get(teamMember.User__c).Name));
            mailList.add(oldQCMail);
            
            Messaging.SingleEmailMessage newQCMail = CPQ_Utility.getSingleMessage(CON_CPQ.CPQ_QC_REVIEWER_ASSIGNMENT_EMAIL_NOTIFICATION, 
                teamMember.Proposal__c, UserInfo.getUserId(), new List<String>{teamMember.User__c});
            
            String htmlBody = newQCMail.getHtmlbody();
            htmlBody = htmlBody.replaceAll(CON_CPQ.QC_STAGE_PLACEHOLDER, teamMember.Member_Role__c == CON_CPQ.QC_REVIEWER ? CON_CPQ.DRAFT_REVIEW : CON_CPQ.FINAL_REVIEW);
            htmlBody = htmlBody.replaceAll(CON_CPQ.OPPORTUNIY_NAME_PLACEHOLDER, proposalMap.get(teamMember.Proposal__c).Apttus_Proposal__Opportunity__r.Name != null ? proposalMap.get(teamMember.Proposal__c).Apttus_Proposal__Opportunity__r.Name : '');
            htmlBody = htmlBody.replaceFirst(CON_CPQ.OPPORTUNIY_ACCOUNT_PLACEHOLDER, proposalMap.get(teamMember.Proposal__c).Apttus_Proposal__Account__r.Name != null ? proposalMap.get(teamMember.Proposal__c).Apttus_Proposal__Account__r.Name : '');
            newQCMail.setHtmlBody(htmlBody);
            String mailSubject = newQCMail.getSubject();
            mailSubject = mailSubject.replaceAll(CON_CPQ.QC_STAGE_PLACEHOLDER, teamMember.Member_Role__c == CON_CPQ.QC_REVIEWER ? CON_CPQ.DRAFT_REVIEW : CON_CPQ.FINAL_REVIEW);
            mailSubject = mailSubject.replaceAll(CON_CPQ.OPPORTUNIY_NAME_PLACEHOLDER, proposalMap.get(teamMember.Proposal__c).Apttus_Proposal__Opportunity__r.Name != null ? proposalMap.get(teamMember.Proposal__c).Apttus_Proposal__Opportunity__r.Name : '');
            mailSubject = mailSubject.replaceFirst(CON_CPQ.OPPORTUNIY_ACCOUNT_PLACEHOLDER, proposalMap.get(teamMember.Proposal__c).Apttus_Proposal__Account__r.Name != null ? proposalMap.get(teamMember.Proposal__c).Apttus_Proposal__Account__r.Name : '');
            newQCMail.setSubject(mailSubject);
            mailList.add(newQCMail);
        }
        Messaging.sendEmail(mailList);
    }*/
}