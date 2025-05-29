({
	getDetails : function(component, event) {
		var action = component.get("c.getProposalDetails");
        var recordId = component.get("v.recordId");

        action.setParams({
            'recordId': recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var returnValue = response.getReturnValue();
                component.set("v.proposalObj", returnValue);
                var flowName = returnValue.clmFlowName;
                if(returnValue.approvalStage == 'Presented' && returnValue.isBudgetTypeInitialOrRebid && returnValue.syncStatus == 'None') {
                    if(!returnValue.isFinalized) {
                        this.showToast('', 'For Quotes in the Presented stage, the Budget file must be finalized before marking as Primary.', 'info', 10000);
                    } else if(!returnValue.isPrimary) {
                        this.showToast('', 'Mark the Budget record as Primary only if synchronization of products to the Opportunity record is required.', 'info', 10000);
                    }
                }
                if(returnValue.approvalStage == 'Presented' && returnValue.isBudgetTypeInitialOrRebid && returnValue.isFinalized && returnValue.isPrimary) {
                    var delay = returnValue.timeoutDelay;
                    setTimeout(function(){
                        $A.get('e.force:refreshView').fire();
                    }, delay);
                }
                console.log("proposal details");
                console.log(component.get("v.proposalObj"));
                $A.get('e.force:refreshView').fire();
            } else {
                console.log('error');
                console.log(state);
                var returnValue = response.getReturnValue();
                console.log(returnValue);
            }
        });
        $A.enqueueAction(action);
	},
    reject : function(component, event) {
		var action = component.get("c.reject");

        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var returnValue = response.getReturnValue();
                if (returnValue == '') {
                    $A.get('e.force:refreshView').fire();
                    this.showToast('', 'The budget is rejected successfully', 'success'); 
                } else {
                    this.showToast('Error!', returnValue, 'error');
                }
            }
        });
        $A.enqueueAction(action);
	},
    showToast : function(title, message, type, duration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "duration": duration
        });
        toastEvent.fire();
    },
    
    
    getValidationMessage : function(component, event) {
        var message ='';

        if ((component.get("v.proposalObj.isMapCallRequired") && component.get("v.proposalObj.mapCallDate") == null) &&
               (component.get("v.proposalObj.isStrategyCallRequired") && component.get("v.proposalObj.strategyCallDate") == null) && component.get("v.proposalObj.isBudgetTypeInitialOrRebid")){
        	message = 'Please enter date for Strategy Call/Core Team Mtg and Map call if not required uncheck Is Strategy call/Core Team Mtg required and Is Map Call Required';
        }
        else if (component.get("v.proposalObj.isStrategyCallRequired") && component.get("v.proposalObj.strategyCallDate") == null && component.get("v.proposalObj.isBudgetTypeInitialOrRebid")){
        	message = 'Please enter date for Strategy Call/Core Team Mtg if not required uncheck Is Strategy call/Core Team Mtg required';
        }
        else if (component.get("v.proposalObj.isMapCallRequired") && component.get("v.proposalObj.mapCallDate") == null && component.get("v.proposalObj.isBudgetTypeInitialOrRebid")){
        	message = 'Please enter date for map call if not required uncheck Is Map Call Required';
        }
        if (message != ''){
            this.showToast('', message, 'error');
            return false;
        }
        else {
            return true;
        }
        
	},
    
    fireAprrovalRequest : function(component, event) {
        var proposal = component.get("v.proposalObj");
        if (proposal.isApproverMissing || (!proposal.isBudgetTypeInitialOrRebid))
        {
            this.updateQuoteStatus(component, 'Sign Off', 'Submitted for Final SignOff', 'Budget has been moved to final signoff.');
        }
        else if(proposal.tool == 'LCS_UPT' && (proposal.budgetType == 'Initial' || proposal.budgetType == 'Rebid'))
        {
            if(proposal.psApproverId != null && proposal.psApproverId != '')
            {
                this.updateQuoteStatusAndSendEmail(component, 'Pending Approval', 
                    'PS Approval Pending', 'Budget has been Submitted for PS Approval.', proposal.psApproverId);
            }
			/*Commented under LC-9607 to remove approval process by Strategic Pricing user
            else if(proposal.spApproverId != null && proposal.spApproverId != '')
            {
                this.updateQuoteStatusAndSendEmail(component, 'Pending Approval', 
                    'SP Approval Pending', 'Budget has been Submitted for SP Approval.', proposal.spApproverId);
            }*/
        }
        else
        {
            this.submitForApproval(component, proposal.approver);
        }
    },
    
    submitForApproval : function(component, approver) {
        var action  = component.get("c.fireAprrovalRequest");
        action.setParams({ 
            proposalId : component.get("v.recordId"), 
            approver : approver
        });
        action.setCallback(this, function(response) {
            component.set("v.spinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast('', 'Review request submitted successfully.', 'success'); 
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        if (errors[0].message.includes('ALREADY_IN_PROCESS')){
                            this.showToast('', 'Record is already submitted for approval', 'error');
                        }
                        else
                            this.showToast('', errors[0].message, 'error');                            
                    }
                }                  
            }
        });
        $A.enqueueAction(action);
	},
    updateQuoteStatus : function(component, stage, status, msg) {
		var action = component.get("c.updateQuoteStatus");

        action.setParams({
            'recordId': component.get("v.recordId"),
            'stage': stage,
            'status': status
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var returnValue = response.getReturnValue();
                if (returnValue == '') {
                    $A.get('e.force:refreshView').fire();
                    this.showToast('', msg, 'success'); 
                    
                    if (stage == 'Generated') {
                        window.setTimeout(
                            $A.getCallback(function() {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": 'Note!!!',
                                    "message": 'Please enter the Bid Sent Date to move to Presented Stage.',
                                    "type": 'info'
                                });
                                toastEvent.fire();
                            }), 5000
                        );
                    }
                } else {
                    this.showToast('Error!', returnValue, 'error');
                }
            }
        });
        $A.enqueueAction(action);
	},
    updateQuoteStatusAndSendEmail : function(component, stage, status, msg, reviewerUserId) 
    {
        var action = component.get("c.updateQuoteStatusAndSendEmail");
        action.setParams({
            'recordId': component.get("v.recordId"),
            'stage': stage,
            'status': status,
            'reviewerUserId': reviewerUserId
        });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var returnValue = response.getReturnValue();
                if (returnValue == '') 
                {
                    $A.get('e.force:refreshView').fire();
                    this.showToast('', msg, 'success'); 
                } 
                else 
                {
                    this.showToast('Error!', returnValue, 'error');
                }
            }
        });
        $A.enqueueAction(action);
	},
    collectIds: function(component, reviewerList) {
        var recordIds = '';
        for (var record in reviewerList) {
            if (recordIds == '') {
                recordIds = reviewerList[record].recordId;
            } else {
                recordIds = recordIds + ',' + reviewerList[record].recordId;
            }
        }
        return recordIds;
    },
    /*Commented under LC-10187 to remove ref of Reviewer/Final Reviewer picklist value from Team Member object
    insertQCReviewers : function(component, reviewerIds) {
		var action = component.get("c.insertQCReviewers");

        action.setParams({
            'recordId': component.get("v.recordId"),
            'reviewerIds': reviewerIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.spinner", false);
            if (state === "SUCCESS") {
				var returnValue = response.getReturnValue();
                if (returnValue == '') {
                    $A.get('e.force:refreshView').fire();
                    component.set("v.askForQCReview", false);
                    this.showToast('', 'Reviewers are assigned successfully', 'success'); 
                } else {
                    this.showToast('Error!', returnValue, 'error');
                }
            } else {
                this.showToast('Error!', returnValue, 'error');
            }
        });
        $A.enqueueAction(action);
        component.set("v.spinner", true);
	},
    */
    showToastWithSpecifiedMode : function(title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode" : mode
        });
        toastEvent.fire();
    }
})