({
    getDetails : function(component, event, helper) {
		helper.getDetails(component, event); 
	},
    submitQNA : function(component, event, helper)
    {
        var isValidated = helper.getValidationMessage(component, event);
        if (isValidated)
        {
            var childComp;
            var proposalObj = component.get("v.proposalObj");
            if(proposalObj.isQCApprover)
            {
                component.set("v.isApprovalReview", true);
                childComp = component.find('ApprovalChecklistComponent');
            }
            else
            {
                component.set("v.isQcReview", true);
                childComp = component.find('QCComponent');
            }
            if ($A.util.isArray(childComp))
                childComp = childComp[childComp.length - 1];
            childComp.loadGuidelines();  
        }            
	},
    submitForReview : function(component, event, helper) {
        var isValidated = helper.getValidationMessage(component, event);
        if (isValidated){
        	component.set("v.isFunctionalReview", true);  
        }
	},
    submitForApproverReview : function(component, event, helper) {
        helper.fireAprrovalRequest(component, event);
    },
    submitForFinalReview : function(component, event, helper) {
        // Change under LC-9365 to hide Final Review Status Update
        helper.updateQuoteStatus(component, 'Sign Off', 'Final Review Approved', 'Budget is approved successfully');
    },
    completeReview : function(component, event, helper) {
        var proposalObj = component.get("v.proposalObj");
        if (proposalObj.budgetType == 'Preliminary'
           || proposalObj.budgetType == 'Project Specific'
           || proposalObj.budgetType == 'Change Order'
           || proposalObj.budgetType == 'CNF'
           || proposalObj.budgetType == 'Ballpark') 
        {
            helper.updateQuoteStatus(component, 'Presented', 'Document Presented', 'Budget is moved to Presented stage successfully.');
        }
        else
        {
            helper.updateQuoteStatus(component, 'Generated', 'Document Generated', 'Budget document is created and moved to Generated stage successfully.');
        }
	},
    YesModel : function(component, event, helper) {
        component.set("v.title", 'Select Reviewers');
        component.set("v.header", 'Select Reviewers');
        component.set("v.message", 'Select multiple Reviewers by entering their names.');
        component.set("v.multiQC", true);
	},
    NoModel : function(component, event, helper) {
        var proposalObj = component.get("v.proposalObj");
        if (proposalObj.approvalStage == 'Draft') {
            helper.updateQuoteStatus(component, 'Draft', 'Ready for Functional Review', 'Budget is ready for Functional Review.');
        } else if (proposalObj.approvalStage == 'Final Review') {
            helper.updateQuoteStatus(component, 'Final Review', 'Final Review Approved', 'Budget is ready for Document Generation.');
        }
        component.set("v.askForQCReview", false);
	},
    saveQCReviewers: function(component, event, helper) {
        console.log(component.get("v.reviewersIds"));
        var recordIds = helper.collectIds(component, component.get("v.reviewersIds"));
        console.log(recordIds);
        if (recordIds != null && recordIds != '') 
        {
            helper.insertQCReviewers(component, recordIds);
        } 
        else 
        {
            helper.showToast('', 'Please select reviewers.', 'error');
        }
    },
    showToast : function(component, event, helper)
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: event.getParam('arguments').message,
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    handleConfirmation : function(component, event, helper) {
        component.set('v.showConfirmation', true);
    },
     
    handleYesConfirmation : function(component, event, helper) {
        component.set('v.showConfirmation', false);
        helper.reject(component, event);
    },
     
    handleNoConfirmation : function(component, event, helper) {
        component.set('v.showConfirmation', false);
        component.set('v.showAcceptConfirmation', false);
    },
    
    handleAcceptConfirmation : function(component, event, helper) {
        component.set('v.showAcceptConfirmation', true);
    },
    
    handleApproverComments : function(component, event, helper){
        component.set('v.showApproverComment', true);
    },
    
    handleCancelConfirmation : function(component, event, helper){
        component.set("v.comment", "");
        component.set('v.showApproverComment', false);
    },
    
    handleSaveConfirmation : function(component, event, helper){
        var comment = component.get("v.comment");
        if (comment){
            var action = component.get("c.approve");
            var recordID = component.get("v.recordId");
            var approvalStage = component.get("v.proposalObj.approvalStage");
            var approvalStatus = component.get("v.proposalObj.approvalStatus");
            action.setParams({
                'recordID' : recordID,
                'comment' : comment,
                'approvalStage' : approvalStage,
                'approvalStatus' : approvalStatus
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    if (returnValue == '') {
                        component.set("v.comment", "");
                        component.set('v.showApproverComment', false);
                        $A.get('e.force:refreshView').fire();
                        helper.showToast('', 'TSL Review completed offline', 'success');
                    } else {
                        helper.showToast('Error!', returnValue, 'error');
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            component.find("comment").reportValidity();
        }     
    },
    
    markAccepted : function(component, event, helper) {
        var proposalObj = component.get("v.proposalObj");
        if(proposalObj.isOpportunityStageFinalisingDealOrHigher) {
                if ((proposalObj.budgetType == 'Preliminary'
                     || proposalObj.budgetType == 'Project Specific'
                     || proposalObj.budgetType == 'Change Order') && proposalObj.isExecutedDateNull && !proposalObj.isrecordTypeNameRDSBudget) {
                        
                    helper.showToast('', 'Please enter the “Executed Date” to move to Accepted Stage.', 'error'); 
                }
                else if (proposalObj.budgetType == 'CNF' && !proposalObj.isCNFApprovalDateOrChangeOrderNumberExist) {
                        
                    helper.showToast('', 'Please enter the Approval/Rejected/Completion Date, Status(Accepted) and Change Order Number to move to Accepted stage.', 'error');
                }
                else if (proposalObj.budgetType == 'Ballpark' && !proposalObj.isApprovalDateExistAndStatusIsAccepted) {
                    
                    helper.showToast('', 'Note!!! Please enter the Approval/Rejected/Completion Date and Status(Accepted) to move to Accepted stage.', 'error');
                }
                else if (proposalObj.budgetType == 'Change Order' && !proposalObj.isRelatedAgreementIsActivated) {
                    
                    helper.showToast('', 'There is no activated Change Order Agreement associated with this Quote so it could not be marked as Accepted. Please ensure the related Change Order Agreement is Activated before Accepting the Quote.', 'error');
                }
                else {
                    if (proposalObj.budgetType == 'CNF' || proposalObj.budgetType == 'Ballpark' || proposalObj.budgetType == 'Preliminary' || proposalObj.budgetType == 'Project Specific' || proposalObj.budgetType == 'Change Order') {
                        if ((proposalObj.isrecordTypeNameRDSBudget && proposalObj.isFinalized ) || !proposalObj.isrecordTypeNameRDSBudget) {
                            helper.updateQuoteStatus(component, 'Accepted', 'Document Presented', 'Budget is Accepted.');
                        }
                        else {
                            helper.showToast('', 'Please Finalize the Budget', 'error');
                        }
                    }
                    else if (proposalObj.budgetType == 'Initial' || proposalObj.budgetType == 'Rebid') {
                        if (proposalObj.isPrimary) {
                            if (proposalObj.isrecordTypeNameRDSBudget && proposalObj.isFinalized) {
                                helper.updateQuoteStatus(component, 'Accepted', 'Document Presented', 'Budget is Accepted.');
                            }
                            else {
                                helper.showToast('', 'Please Finalize the Budget', 'error');
                            }
                        }
                        else {
                            helper.showToast('', 'Please mark the Budget as primary.', 'error');
                        }
                    }
                }
        }
        else {
            helper.showToast('', 'The Opportunity is either at stage 7b-lost or stage should be 5 or higher to Accept the Budget.', 'error');
        }
        component.set('v.showAcceptConfirmation', false);
    },
    inactivateQuote : function(component, event, helper) {
        component.set('v.isInactivate', true);
    },
    resync: function(component, event, helper) 
    {
        component.set('v.proposalObj.syncStatus', 'In-Progress');
        var proposalObj = component.get("v.proposalObj");
        var action = component.get("c.syncBudgetWithOpportunity");
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            if (state === "SUCCESS") {
                var jobId = returnValue;
                var pollId = setInterval(function(){
                    var temp = component.get("v.proposalObj.syncStatus");
                    if(temp == 'Completed' || temp == 'Failed') {
                        clearInterval(pollId);
                        if(temp == 'Completed') {
                            helper.showToast('', 'Proposal Line Items are synced with Opportunity Line Items.','success');
                        }
                        component.set("v.spinner", false);
                    }
                    $A.get('e.force:refreshView').fire();
                },5000);
            } 
            else {
                helper.showToast('Error!', 'Synchronization With Opportunity Failed!!' , 'error');
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
        helper.showToast('', 'Sync is In-Progress, Please wait until it completes and do not close this screen.', 'warning');
        component.set("v.spinner", true);
    },
    
    handleValueChange : function (component, event, helper) {
        var statusValue = component.get("v.proposalObj.cnfStatus");
        if (component.get("v.oldCNFStatus") == 'Accepted' && statusValue == 'Rejected' && (component.get("v.proposalObj.budgetType") == 'CNF' || component.get("v.proposalObj.budgetType") == 'Ballpark'))  {
            helper.showToastWithSpecifiedMode('','Please ensure the Approval/Rejected/Completed date aligns with your status update.','warning','sticky');
        }
        component.set("v.oldCNFStatus", statusValue);
    },
    
    handleCreateAgreement : function (component) {
        component.set("v.isCreateAgreement", true);
        var proposalObj = component.get("v.proposalObj");
        var flowName = proposalObj.clmFlowName;
        var recId = component.get("v.recordId");
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : recId
            }
        ];
        var flow = component.find("flowData");
        flow.startFlow(flowName, inputVariables);
    }
})