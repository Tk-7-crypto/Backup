public class CNT_CPQ_BudgetQuestionReview
{
    @auraEnabled
    public static ProposalDetails fetchData(Id recordId)
    {
        ProposalDetails proposalObj = new ProposalDetails();
        List<ProposalQASelfCheckListWrapper> recordWrapperList = new List<ProposalQASelfCheckListWrapper>();
        proposalObj.allOwnersResponseValues = new Set<String>();
        proposalObj.allReviewersResponseValues = new Set<String>();
        proposalObj.allMajorFindingCompletedValues = new Set<String>();
        
        Set<String> fieldSet = new Set<String>{CON_CPQ.Id,
            CON_CPQ.FIELD_PARENT_CLINICAL_BID_TYPE, 
            CON_CPQ.RELATED_CLINICAL_OPPORTUNITY_TYPE,
            CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL,
            CON_CPQ.PROPOSAL_CATEGORY,
            CON_CPQ.APPROVAL_STAGE,
            CON_CPQ.APPROVAL_STATUS,
            CON_CPQ.DRAFT_QC_PROPOSAL_TYPES,
            CON_CPQ.FINAL_QC_PROPOSAL_TYPES,
            CON_CPQ.DRAFT_QC_REVIEW_DATE,
            CON_CPQ.FINAL_QC_REVIEW_DATE,
            CON_CPQ.DRAFT_QC_NUMBER_OF_BUDGET_REQUESTED,
            CON_CPQ.FINAL_QC_NUMBER_OF_BUDGET_REQUESTED,
            CON_CPQ.APTTUS_PROPOSAL_PARENT_BID,
            CON_CPQ.REALTED_AGREEMENT
        };
        Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(recordId, fieldSet);
        
        Decimal version = 0;
        proposalObj.recordId = proposal.Id;
        proposalObj.approvalStage = proposal.Apttus_Proposal__Approval_Stage__c;
        proposalObj.approvalStatus = proposal.Approval_Status__c;
        if(proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.DRAFT)
        {
            proposalObj.selectedFilterTypes = String.IsNotBlank(proposal.Draft_QC_Proposal_Types__c)?proposal.Draft_QC_Proposal_Types__c.split(';'):null;
            proposalObj.isQCReviewerView = proposal.Approval_Status__c == CON_CPQ.QC_REVIEW_DRAFT?true:false;
            proposalObj.isQCDoneBefore = proposal.Draft_QC_Review_Date__c != null?true:false;
            if(proposal.Draft_QC_Number_of_Budgets_Requested__c != null)
                version = proposal.Draft_QC_Number_of_Budgets_Requested__c;
        }      
        else if(proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.FINAL_REVIEW)
        {
            proposalObj.selectedFilterTypes = String.IsNotBlank(proposal.Final_QC_Proposal_Types__c)?proposal.Final_QC_Proposal_Types__c.split(';'):null;
            proposalObj.isQCReviewerView = proposal.Approval_Status__c == CON_CPQ.QC_REVIEW_FINAL?true:false;
            proposalObj.isQCDoneBefore = proposal.Final_QC_Review_Date__c != null?true:false;
            if(proposal.Final_QC_Number_of_Budgets_Requested__c != null)
                version = proposal.Final_QC_Number_of_Budgets_Requested__c;
        }
        
        if(proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC
           || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER
           || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF
           || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY
           || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK)
            proposalObj.isMajorFindingView = true;
        else
            proposalObj.isMajorFindingView = false;

        List<QC_Review_Default_Filter__c> filterList = [SELECT Filter__c, Default_Filter__c 
            FROM QC_Review_Default_Filter__c
            WHERE Budget_Type__c like :'%' + proposal.Apttus_Proposal__Proposal_Category__c + '%'
            AND Budget_Tool__c like :'%' + proposal.Select_Pricing_Tool__c + '%'
            AND Budget_Stage__c like :'%' + proposal.Apttus_Proposal__Approval_Stage__c + '%'];
        if(!filterList.isEmpty())
        {
            if(String.IsNotBlank(filterList.get(0).Filter__c))
                proposalObj.filterTypes = filterList.get(0).Filter__c.split(';');
            
            if(proposalObj.selectedFilterTypes == null || proposalObj.selectedFilterTypes.isEmpty())
                if(String.IsNotBlank(filterList.get(0).Default_Filter__c))
                    proposalObj.selectedFilterTypes = filterList.get(0).Default_Filter__c.split(';');
                else
                    proposalObj.selectedFilterTypes = new List<String>(proposalObj.filterTypes);
        }

        Set<String> proposalQAFieldSet = new Set<String>{CON_CPQ.Id, 
            CON_CPQ.FIELD_BUDGET,
            CON_CPQ.QUESTION, 
            CON_CPQ.GUIDELINES,
            CON_CPQ.STAGE,
            CON_CPQ.INSTANCE_ID,
            CON_CPQ.FILTER,
            CON_CPQ.OWNERS_RESPONSE,
            CON_CPQ.OWNERS_RESPONSE_VALUES,
            CON_CPQ.OWNERS_COMMENTS,
            CON_CPQ.REVIEWERS_RESPONSE,
            CON_CPQ.REVIEWERS_RESPONSE_VALUES,
            CON_CPQ.REVIEWERS_COMMENTS,
            CON_CPQ.REVIEWERS_MAJOR_FINDINGS,
            CON_CPQ.REVIEWERS_MAJOR_FINDINGS_VALUES,
            CON_CPQ.QC_REVIEWER_STATUS,
            CON_CPQ.QC_REVIEWED_DATE,
            CON_CPQ.ORDER
        };
         List<Proposal_QA_Self_Check_List__c> proposalQASelfCheckList = new SLT_ProposalQASelfCheckList().getProposalCheckListForBudget(recordId, 
            proposalQAFieldSet, 
            proposal.Apttus_Proposal__Approval_Stage__c,
            version);
        
        if(proposalQASelfCheckList.size() == 0)
        {
            String opportunity_Type = 'All';
            if(proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID)
            {
                if(proposal.Clinical_Bid__r.Bid_Type__c == CON_CPQ.BID_TYPE_REBID)
                {
                    opportunity_Type = CON_CPQ.REBID;
                }
                else
                {
                    opportunity_Type = proposal.Clinical_Bid__r.Opportunity_Type__c; 
                }
            }
            
            Set<String> qcFieldSet = new Set<String>{CON_CPQ.Id, 
                CON_CPQ.QUESTION, 
                CON_CPQ.GUIDELINES,
                CON_CPQ.AGREEMENT_OPPORTUNITY_TYPE,
                CON_CPQ.BUDGET_TYPE,
                CON_CPQ.PRICING_TOOL,
                CON_CPQ.STAGE,
                CON_CPQ.FILTER,
                CON_CPQ.OWNERS_RESPONSE,
                CON_CPQ.REVIEWERS_RESPONSE,
                CON_CPQ.REVIEWERS_MAJOR_FINDINGS,
                CON_CPQ.ORDER
            };
            List<QC_Check_List_Item__c> qcSelfCheckList = new SLT_QCCheckListItem().getQCCheckListItemForBudget(
                qcFieldSet,
                opportunity_Type,
                proposal.Apttus_Proposal__Proposal_Category__c,
                proposal.Select_Pricing_Tool__c,
                proposal.Apttus_Proposal__Approval_Stage__c);
                
            for(QC_Check_List_Item__c qcRecord : qcSelfCheckList)
            {
                Proposal_QA_Self_Check_List__c record = new Proposal_QA_Self_Check_List__c();
                record.Budget__c = proposal.Id ;
                record.Question__c = qcRecord.Question__c;
                record.Guidelines__c = qcRecord.Guidelines__c;
                record.Stage__c = proposal.Apttus_Proposal__Approval_Stage__c ;
                record.Filter__c = qcRecord.Filter__c;
                record.Owner_s_Response_Values__c = qcRecord.Owner_s_Response__c;
                record.Reviewer_s_Response_Values__c = qcRecord.Reviewer_s_Response__c;
                record.Reviewer_s_Major_Findings_Values__c = qcRecord.Reviewer_s_Major_Findings__c;
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
            recordWrapper.filterValues = String.IsNotBlank(record.Filter__c)?
                record.Filter__c.split(';'):null;
            recordWrapper.isSatisfyFilter = false;
            recordWrapper.isNew = false;
            recordWrapper.ownersResponseValues = String.IsNotBlank(record.Owner_s_Response_Values__c)?
                record.Owner_s_Response_Values__c.split(';'):null;
            recordWrapper.reviewersResponseValues = String.IsNotBlank(record.Reviewer_s_Response_Values__c)?
                record.Reviewer_s_Response_Values__c.split(';'):null;
            recordWrapper.majorFindingCompletedValues = String.IsNotBlank(record.Reviewer_s_Major_Findings_Values__c)?
                record.Reviewer_s_Major_Findings_Values__c.split(';'):null;
            recordWrapperList.add(recordWrapper);

            if(recordWrapper.ownersResponseValues !=null)
                proposalObj.allOwnersResponseValues.addAll(recordWrapper.ownersResponseValues);
            if(recordWrapper.reviewersResponseValues !=null)
                proposalObj.allReviewersResponseValues.addAll(recordWrapper.reviewersResponseValues);
            if(recordWrapper.majorFindingCompletedValues !=null)
                proposalObj.allMajorFindingCompletedValues.addAll(recordWrapper.majorFindingCompletedValues);
        }
        proposalObj.questionList = recordWrapperList;
        proposalObj.instance = recordWrapperList.get(0).question.Instance_Id__c;
        
        Id boxFolderRecordId = recordId;
        String boxMessage = '';
        if(proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL
           || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID)
        {
            boxFolderRecordId = proposal.Clinical_Bid__c;
            boxMessage = CON_CPQ.BOX_MESSAGE_CLINICAL_BID_MISSING;
        }
        else if(proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC
           || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER
           || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY)
        {
            boxFolderRecordId = proposal.Apttus_QPComply__MasterAgreementId__c;
            boxMessage = CON_CPQ.BOX_MESSAGE_RELATED_AGREEMENT_MISSING;
        }
        
        if(boxFolderRecordId !=null)
        {
            CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
            String boxDefaultPath = cpqSetting.Box_Path__c;
            List<box__FRUP__c> boxFolder = new SLT_FRUP().getFRUPRecordsByBoxRecordId(new Set<Id>{boxFolderRecordId},new Set<String>{CON_CPQ.BOX_FOLDER_ID},
                'box__Record_ID__c IN: boxRecordIds');
            if(boxFolder != null && boxFolder.size()>0)
            {
                proposalObj.boxPath = boxDefaultPath.replace('0', boxFolder[0].box__Folder_ID__c);
            }
            else
            {
                proposalObj.boxPath = boxDefaultPath;
            }
        }
        else
        {
            proposalObj.boxMessage = boxMessage;
        }
        
        return proposalObj;
    }
        
    @auraEnabled
    public static void saveAllDataAction(String proposalObjString, String actionPerformed)
    {
        ProposalDetails proposalObj = (ProposalDetails)JSON.deserialize(proposalObjString,ProposalDetails.class);
        
        Decimal maxOrder = -1;
        List<Proposal_QA_Self_Check_List__c> recordsToUpsert = new List<Proposal_QA_Self_Check_List__c>();
        for(ProposalQASelfCheckListWrapper record : proposalObj.questionList)
        {
            if(record.isNew)
            {
                record.question.Budget__c = proposalObj.recordId;
                record.question.Filter__c = record.filterValues!=null?String.join(record.filterValues, ';'):'';
                record.question.Stage__c = proposalObj.approvalStage;
                record.question.Owner_s_Response_Values__c = record.ownersResponseValues!=null?String.join(record.ownersResponseValues, ';'):'';
                record.question.Reviewer_s_Response_Values__c = record.reviewersResponseValues!=null?String.join(record.reviewersResponseValues, ';'):'';
                record.question.Reviewer_s_Major_Findings_Values__c = record.majorFindingCompletedValues!=null?String.join(record.majorFindingCompletedValues, ';'):'';
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
        if(proposalObj.approvalStage == CON_CPQ.DRAFT) 
        {
            budget.Draft_QC_Proposal_Types__c = proposalObj.selectedFilterTypes!=null?String.join(proposalObj.selectedFilterTypes, ';'):'';
            budget.Draft_QC_Number_of_Budgets_Requested__c = proposalObj.instance;
            if(actionPerformed == CON_CPQ.APPROVED_STATUS || actionPerformed == CON_CPQ.REJECTED_STATUS) 
            {
                budget.Draft_QC_Review_Date__c = DateTime.now();
                budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
                //Updated Under LC-9358
                budget.Approval_Status__c = CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW;
            }
        } 
        else if(proposalObj.approvalStage == CON_CPQ.FINAL_REVIEW) 
        {
            budget.Final_QC_Proposal_Types__c =  proposalObj.selectedFilterTypes!=null?String.join(proposalObj.selectedFilterTypes, ';'):'';
            budget.Final_QC_Number_of_Budgets_Requested__c = proposalObj.instance;
            if(actionPerformed == CON_CPQ.APPROVED_STATUS || actionPerformed == CON_CPQ.REJECTED_STATUS) 
            {
                budget.Final_QC_Review_Date__c = DateTime.now();
                //Updated Under LC-9358
                budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.SIGN_OFF;
                budget.Approval_Status__c = (actionPerformed == CON_CPQ.APPROVED_STATUS) ? CON_CPQ.FINAL_REVIEW_APPROVED : CON_CPQ.SUBMITTED_FOR_FINAL_SIGN_OFF;
            }
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
        public List<String> ownersResponseValues{get;set;}
        @AuraEnabled 
        public List<String> reviewersResponseValues{get;set;}
        @AuraEnabled 
        public List<String> majorFindingCompletedValues{get;set;}
        @AuraEnabled 
        public List<String> filterValues{get;set;}
        @AuraEnabled 
        public Boolean isSatisfyFilter{get;set;}
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
        public List<String> filterTypes {get; set;}
        @AuraEnabled
        public List<String> selectedFilterTypes {get; set;}
        @AuraEnabled
        public List<ProposalQASelfCheckListWrapper> questionList {get; set;}
        @AuraEnabled
        public Boolean isQCDoneBefore {get; set;}
        @AuraEnabled
        public Boolean isQCReviewerView {get; set;}
        @AuraEnabled
        public Boolean isMajorFindingView {get; set;}
        @AuraEnabled 
        public Set<String> allOwnersResponseValues{get;set;}
        @AuraEnabled 
        public Set<String> allReviewersResponseValues{get;set;}
        @AuraEnabled 
        public Set<String> allMajorFindingCompletedValues{get;set;}
        @AuraEnabled 
        public decimal instance{get;set;}
        @AuraEnabled 
        public String boxPath{get;set;}
        @AuraEnabled 
        public String boxMessage{get;set;}
    }
}