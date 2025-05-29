({
    getDetails: function (component, event, helper) {
        helper.getDetails(component, event);
    },

    configureProducts: function (component, event, helper) {
        helper.configureProducts(component);
    },

    makeAsPrimary: function (component, event, helper) {
        helper.makeAsPrimary(component);
    },

    handleConfirmation : function(component, event, helper) {
        component.set('v.showConfirmation', true);
    },

    handleYesConfirmation : function(component, event, helper) {
        component.set('v.showConfirmation', false);
        component.set("v.spinner", true);
        if (component.get('v.messageRoute') == 'onReject') {
            if (component.get("v.proposalObj.pricingTool") == 'OCE') {
                helper.updateQuoteStatusForOCE(component, 'Rejected', 'The Proposal has been rejected by customer', 'Document Rejected');
            } else {
            	helper.updateQuoteStatus(component, 'Rejected', 'The Proposal has been rejected by customer');
            }
        } else {
            helper.recallAction(component, event);   
        }
    },
     
    handleNoConfirmation : function(component, event, helper) {
        component.set('v.showConfirmation', false);
    },

    acceptAction : function(component, event, helper) {
        if (component.get("v.proposalObj.pricingTool") == 'OCE') {
            component.set("v.spinner", true);
            helper.updateQuoteStatusForOCE(component, 'Accepted', 'The Proposal has been accepted by customer', 'Document Accepted');
        }
        else if(component.get("v.proposalObj").isPrimary) {
            component.set("v.spinner", true);
            helper.updateQuoteStatus(component, 'Accepted', 'The Proposal has been accepted by customer');
        } else {
            helper.showToast('', 'Please mark the Budget as primary.', 'error');
        }
    },

    rejectAction : function(component, event, helper) {
        component.set("v.confirmationMsg", "Are you sure to reject this proposal?");
        component.set('v.messageRoute', 'onReject');
        component.set('v.showConfirmation', true);
    },
    submitApprovalRequest : function(component, event, helper) {
        if (component.get("v.proposalObj.pricingTool") == 'TS Japan') {
            var isValidated = helper.getValidationMessage(component, event);
            if (isValidated) {
                component.set("v.isDisplayCSSForm", true);
            }
        }
        else if (component.get("v.proposalObj.pricingTool") == 'OCE') {
            if (component.get("v.proposalObj.country") == null) {
            	helper.showToast('Error!', 'Please select the main delivery country for this proposal before submitting for approval.' , 'error');
            } else {
                component.set("v.spinner", true);
                helper.updateQuoteStatusOCE(component, 'Pending Approval', 'The Proposal has been submitted for approval');
            }
        } else if (component.get("v.proposalObj.pricingTool") == 'AMESA') {
            component.set("v.spinner", true);
            helper.updateQuoteStatusOCE(component, 'Pending Approval', 'The Proposal has been submitted for approval');
        }
    },
    showToast: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: event.getParam('arguments').message,
            duration: ' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    syncwithOpportunity: function (component, event, helper) {
        var proposalObj = component.get("v.proposalObj");
        if(proposalObj.isPrimary) {
            component.set('v.proposalObj.syncStatus', 'In-Progress');
            var action = component.get("c.syncPLIWithOpportunity");
            var recordId = component.get("v.recordId");
            var pricingTool = component.get("v.proposalObj.pricingTool");
            var approvalStage = component.get("v.proposalObj.approvalStage");
            action.setParams({
                'recordId': recordId,
                'pricingTool': pricingTool,
                'approvalStage':approvalStage
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var returnValue = response.getReturnValue();
                if (state === "SUCCESS") {
                    var jobId = returnValue;
                    var pollId = setInterval(function() {
                        var temp = component.get("v.proposalObj.syncStatus");
                        var msg = component.get("v.proposalObj.syncMessage");
                        if(temp == 'Completed' || temp == 'Failed') {
                            clearInterval(pollId);
                            if(temp == 'Completed' && (msg == null || msg == '')) {
                                helper.showToast('Success!', 'Line Items are synced with Opportunity Line Items.','success');
                            } else if(temp == 'Completed' && msg != null && msg != '') {
                                helper.showToastWithMode('Warning!', msg, 'warning', 'sticky');
                            } else {
                                helper.showToast('Error!', 'Synchronization With Opportunity Failed!!' , 'error');
                            }
                            component.set("v.spinner", false);
                        }
                        $A.get('e.force:refreshView').fire();
                    }, 4000);
                } 
                else {
                    helper.showToast('Error!', 'Synchronization With Opportunity Failed!!' , 'error');
                    component.set("v.spinner", false);
                }
            });
            $A.enqueueAction(action);
            helper.showToast('', 'Sync is In-Progress, Please wait until it completes and do not close this screen.', 'warning');
            component.set("v.spinner", true);
        } else {
            helper.showToast('', 'Please mark the Budget as primary.', 'error');
        }
    },
    generateProposal: function (component, event, helper) {
        helper.generateProposals(component);
	},

    handleApproveRequest: function (component, event, helper) {
        var comment = component.get("v.comment");
        helper.requestApproved(component, comment);
        component.set('v.showApproverComment', false);
    },

    handleRejectRequest: function (component, event, helper) {
        var comment = component.get("v.comment");
        helper.requestRejected(component, 'Rejected', comment);
        component.set('v.showApproverCommentOnReject', false);
    },

    handleApproverComments: function (component, event, helper) {
        component.set('v.showApproverComment', true);
    },

    handleApproverCommentsForReject: function (component, event, helper) {
        component.set('v.showApproverCommentOnReject', true);
    },

    handleCancelConfirmation: function (component, event, helper) {
        component.set("v.comment", "");
        component.set('v.showApproverComment', false);
        component.set('v.showApproverCommentOnReject', false);
    },

    handleReassignRequest: function (component, event, helper) {
        component.set("v.spinner", true);
        var action = component.get("c.getActorProcessInstanceWorkItems");
        action.setParams({
            'objectId': component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var data = response.getReturnValue();
            component.set("v.spinner", false);
            var instanceApprovers = response.getReturnValue();
            component.set("v.instanceApprovers", instanceApprovers);
        });
        component.set('v.reassignForSubmitter', true);
        $A.enqueueAction(action);
    },

    reassignRequestForSubmitter: function (component, event, helper) {
        console.log(component.get("v.instanceApprovers"));
        var allApprovers = component.get("v.instanceApprovers");
        var isValidRequest = true;
        allApprovers.forEach(function (record) {
            if (record.newUser == null || record.newUser.recordId == null || record.newUser.recordId == '') {
                isValidRequest = false;
            }
        });
        if (isValidRequest) {
            helper.updateNewApprover(component, allApprovers);
        } else {
            helper.showToast('', 'Please select all the approvers.', 'error');
        }
    },
    cancelReassign: function (component, event, helper) {
        component.set("v.reassignForSubmitter", false);
    },
    previewProposal: function (component, event, helper) {
        helper.previewProposals(component);
    },
    createAgreement : function(component, event, helper) {
        helper.createAgreements(component);			 
    }
})
