public class CNT_CPQ_BudgetApprovalChecklist
{
    @auraEnabled
    public static ProposalDetails fetchData(Id recordId)
    {
        ProposalDetails proposalObj = new ProposalDetails();
        List<ProposalQASelfCheckListWrapper> recordWrapperList = new List<ProposalQASelfCheckListWrapper>();
        proposalObj.allReviewersResponseValues = new Set<String>();
        
        Set<String> fieldSet = new Set<String>{CON_CPQ.Id,
            CON_CPQ.FIELD_PARENT_CLINICAL_BID_TYPE,
            CON_CPQ.RELATED_CLINICAL_OPPORTUNITY_TYPE,
            CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL,
            CON_CPQ.PROPOSAL_CATEGORY,
            CON_CPQ.APPROVAL_STAGE,
            CON_CPQ.APPROVAL_STATUS,
            CON_CPQ.PS_NUMBER_OF_BUDGET_REQUESTED,
            CON_CPQ.SP_NUMBER_OF_BUDGET_REQUESTED,
            CON_CPQ.RELATED_CLINICAL_OPPORTUNITY_NAME,
            CON_CPQ.RELATED_CLINICAL_ACCOUNT_NAME
        };
        Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(recordId, fieldSet);
        
        Decimal version = 0;
        proposalObj.recordId = proposal.Id;
        proposalObj.approvalStage = proposal.Apttus_Proposal__Approval_Stage__c;
        proposalObj.approvalStatus = proposal.Approval_Status__c;
        proposalObj.opportunityName = proposal.Clinical_Bid__r.Opportunity_Name__c;
        proposalObj.accountName = proposal.Clinical_Bid__r.Opportunity_Account__c;

        if(proposal.Approval_Status__c == CON_CPQ.PS_APPROVAL_PENDING)
        {
            proposalObj.selectedFilterType = CON_CPQ.PS;
            if(proposal.PS_Number_of_Budgets_Requested__c != null)
                version = proposal.PS_Number_of_Budgets_Requested__c;
        }      
        else if(proposal.Approval_Status__c == CON_CPQ.SP_APPROVAL_PENDING)
        {
            proposalObj.selectedFilterType = CON_CPQ.SP;
            if(proposal.SP_Number_of_Budgets_Requested__c != null)
                version = proposal.SP_Number_of_Budgets_Requested__c;
        }

        Set<String> proposalQAFieldSet = new Set<String>{CON_CPQ.Id, 
            CON_CPQ.FIELD_BUDGET,
            CON_CPQ.QUESTION, 
            CON_CPQ.GUIDELINES,
            CON_CPQ.STAGE,
            CON_CPQ.INSTANCE_ID,
            CON_CPQ.FILTER,
            CON_CPQ.REVIEWERS_RESPONSE,
            CON_CPQ.REVIEWERS_RESPONSE_VALUES,
            CON_CPQ.REVIEWERS_COMMENTS,
            CON_CPQ.QC_REVIEWER_STATUS,
            CON_CPQ.QC_REVIEWED_DATE,
            CON_CPQ.ORDER};

         List<Proposal_QA_Self_Check_List__c> proposalQASelfCheckList = 
            new SLT_ProposalQASelfCheckList().getProposalCheckListForBudgetFiltered(recordId, 
                proposalQAFieldSet, 
                proposal.Apttus_Proposal__Approval_Stage__c,
                version,
                proposalObj.selectedFilterType);
        
        if(proposalQASelfCheckList.size() == 0)
        {
            String opportunity_Type = CON_CPQ.ALL;
            if(proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID)
                opportunity_Type = proposal.Clinical_Bid__r.Bid_Type__c == CON_CPQ.BID_TYPE_REBID?CON_CPQ.REBID:CON_CPQ.OPPORTUNITY_TYPE_FSP;
            
            Set<String> qcFieldSet = new Set<String>{CON_CPQ.Id, 
                CON_CPQ.QUESTION, 
                CON_CPQ.GUIDELINES,
                CON_CPQ.AGREEMENT_OPPORTUNITY_TYPE,
                CON_CPQ.BUDGET_TYPE,
                CON_CPQ.PRICING_TOOL,
                CON_CPQ.STAGE,
                CON_CPQ.FILTER,
                CON_CPQ.REVIEWERS_RESPONSE,
                CON_CPQ.ORDER
                };
            List<QC_Check_List_Item__c> qcSelfCheckDraftList = new SLT_QCCheckListItem().getQCCheckListItemForBudgetFiltered(
                qcFieldSet,
                opportunity_Type,
                proposal.Apttus_Proposal__Proposal_Category__c,
                proposal.Select_Pricing_Tool__c,
                proposal.Apttus_Proposal__Approval_Stage__c,
                proposalObj.selectedFilterType);
                
            for(QC_Check_List_Item__c qcRecord : qcSelfCheckDraftList)
            {
                Proposal_QA_Self_Check_List__c record = new Proposal_QA_Self_Check_List__c();
                record.Budget__c = proposal.Id ;
                record.Question__c = qcRecord.Question__c;
                record.Guidelines__c = qcRecord.Guidelines__c;
                record.Stage__c = proposal.Apttus_Proposal__Approval_Stage__c ;
                record.Filter__c = proposalObj.selectedFilterType;
                record.Reviewer_s_Response_Values__c = qcRecord.Reviewer_s_Response__c;
                record.QC_Reviewer_Status__c = CON_CPQ.DRAFT;
                record.Instance_Id__c = 0;
                record.Order__c = qcRecord.Order__c;
                proposalQASelfCheckList.add(record);
            }
        }

        for(Proposal_QA_Self_Check_List__c record : proposalQASelfCheckList)
        {
             if(record.QC_Reviewer_Status__c == CON_CPQ.APPROVED_STATUS || record.QC_Reviewer_Status__c == CON_CPQ.REJECTED_STATUS)
             {
                record.Id = null;
                record.QC_Reviewer_Status__c = CON_CPQ.DRAFT;
                record.QC_Reviewed_Date__c = null;
                record.Instance_Id__c++;
             }
            ProposalQASelfCheckListWrapper recordWrapper = new ProposalQASelfCheckListWrapper();
            recordWrapper.question = record;
            recordWrapper.isNew = false;
            recordWrapper.reviewersResponseValues = String.IsNotBlank(record.Reviewer_s_Response_Values__c)?
                record.Reviewer_s_Response_Values__c.split(';'):null;
            recordWrapperList.add(recordWrapper);
            
            if(recordWrapper.reviewersResponseValues !=null)
                proposalObj.allReviewersResponseValues.addAll(recordWrapper.reviewersResponseValues);
        }
        proposalObj.questionList = recordWrapperList;
        proposalObj.instance = !recordWrapperList.isEmpty()?recordWrapperList.get(0).question.Instance_Id__c:0;
        return proposalObj;
    }
        
    @auraEnabled
    public static void saveAllDataAction(String proposalObjString)
    {
        ProposalDetails proposalObj = (ProposalDetails)JSON.deserialize(proposalObjString,ProposalDetails.class);
        String actionPerformed = proposalObj.actionPerformed;
        
        Decimal maxOrder = -1;
        List<Proposal_QA_Self_Check_List__c> recordsToUpsert = new List<Proposal_QA_Self_Check_List__c>();
        for(ProposalQASelfCheckListWrapper record : proposalObj.questionList)
        {
            if(record.isNew)
            {
                record.question.Budget__c = proposalObj.recordId;
                record.question.Filter__c = proposalObj.selectedFilterType;
                record.question.Stage__c = proposalObj.approvalStage;
                record.question.Reviewer_s_Response_Values__c = record.reviewersResponseValues!=null?String.join(record.reviewersResponseValues, ';'):'';
                record.question.QC_Reviewer_Status__c = CON_CPQ.DRAFT;
                record.question.Instance_Id__c = proposalObj.instance;
                record.question.Order__c = maxOrder+1;
            }
            if(actionPerformed == CON_CPQ.APPROVED_STATUS || actionPerformed == CON_CPQ.REJECTED_STATUS) 
            {
                record.question.QC_Reviewed_Date__c = DateTime.now();
                record.question.QC_Reviewer_Status__c = actionPerformed;
            }
            recordsToUpsert.add(record.question);
            maxOrder = maxOrder < record.question.Order__c ? record.question.Order__c : maxOrder;         
        }
        if(!recordsToUpsert.isEmpty())
            upsert recordsToUpsert;
        
        
        Apttus_Proposal__Proposal__c budget = new Apttus_Proposal__Proposal__c(Id = proposalObj.recordId);
        if(proposalObj.approvalStatus == CON_CPQ.PS_APPROVAL_PENDING)
            budget.PS_Number_of_Budgets_Requested__c = proposalObj.instance;
        else if(proposalObj.approvalStatus == CON_CPQ.SP_APPROVAL_PENDING) 
            budget.SP_Number_of_Budgets_Requested__c = proposalObj.instance;
        
        if(actionPerformed == CON_CPQ.APPROVED_STATUS)
        {
            if(proposalObj.approvalStatus == CON_CPQ.PS_APPROVAL_PENDING && proposalObj.spApprover != null && proposalObj.spApprover != '')
            {
                budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.PENDING_APPROVAL;
                budget.Approval_Status__c = CON_CPQ.SP_APPROVAL_PENDING;
                
                Messaging.SingleEmailMessage mail = CPQ_Utility.getSingleMessage(CON_CPQ.CPQ_QC_REVIEWER_ASSIGNMENT_EMAIL_NOTIFICATION, 
                    proposalObj.recordId, UserInfo.getUserId(), new List<String>{proposalObj.spApprover});
                String htmlBody = mail.getHtmlbody();
                htmlBody = htmlBody.replace(CON_CPQ.QC_STAGE_PLACEHOLDER, CON_CPQ.SP_REVIEW);
                htmlBody = htmlBody.replaceAll(CON_CPQ.OPPORTUNIY_NAME_PLACEHOLDER, (proposalObj.opportunityName!= null ? proposalObj.opportunityName : ''));
                htmlBody = htmlBody.replaceFirst(CON_CPQ.OPPORTUNIY_ACCOUNT_PLACEHOLDER, (proposalObj.accountName!= null ? proposalObj.accountName : ''));
                mail.setHtmlBody(htmlBody);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            } 
            else
            {
                budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.SIGN_OFF;
                budget.Approval_Status__c = CON_CPQ.SUBMITTED_FOR_FINAL_SIGNOFF;
            }
        }
        else if(actionPerformed == CON_CPQ.REJECTED_STATUS)
        {
            budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
            budget.Approval_Status__c = CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW;
        }
        update budget;
    }
    
    public class ProposalQASelfCheckListWrapper
    {
        @AuraEnabled 
        public Proposal_QA_Self_Check_List__c question{get;set;}
        @AuraEnabled 
        public Boolean isNew{get;set;}
        @AuraEnabled 
        public List<String> reviewersResponseValues{get;set;}
    }
    
    public class ProposalDetails 
    {
        @AuraEnabled
        public Id recordId {get; set;}
        @AuraEnabled
        public String approvalStage {get; set;}
        @AuraEnabled
        public String approvalStatus {get; set;}
        @AuraEnabled
        public String selectedFilterType {get; set;}
        @AuraEnabled
        public List<ProposalQASelfCheckListWrapper> questionList {get; set;}
        @AuraEnabled 
        public Set<String> allReviewersResponseValues{get;set;}
        @AuraEnabled 
        public decimal instance{get;set;}
        @AuraEnabled
        public String actionPerformed {get; set;}
        @AuraEnabled
        public String spApprover {get; set;}
        @AuraEnabled
        public String opportunityName {get; set;}
        @AuraEnabled
        public String accountName {get; set;}
    }
}