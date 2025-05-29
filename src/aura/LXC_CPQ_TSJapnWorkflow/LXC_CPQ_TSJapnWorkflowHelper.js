({
    getDetails: function (component, event) {
        var action = component.get("c.getProposalDetails");
        var recordId = component.get("v.recordId");

        action.setParams({
            'recordId': recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.spinner", false);							  
                var returnValue = response.getReturnValue();
                component.set("v.proposalObj", returnValue);
                /*if (returnValue.iqviaQuoteId != undefined && returnValue.iqviaQuoteId != null) {
                    component.set("v.spinner", true);
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": returnValue.iqviaQuoteId
                    });
                    sObjectEvent.fire();
                }*/
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

    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

    showToastWithMode: function (title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode" : mode
        });
        toastEvent.fire();
    },

    getValidationMessage: function (component, event) {
        var message = '';

        // If "Min Gross Margin" is less than 20% then "Special Prcing Explanation/Comments" is required
        if (component.get("v.proposalObj.isSpecialPricingCommentRequired")) {
            message = 'Special Pricing Explanation/Comments field is required';

        // Checks for Account Tier
        } else if (!component.get("v.proposalObj.proposalSObject.Account_Tier_0_5__c")) {
            message = 'Under Target GM field is required';

        // Checks for Proposal related attachment having "CSS" keyword in file name
        } else if (!component.get("v.proposalObj.cssFileAttached")) {
            message = 'CSS document is REQUIRED to be attached on Quote before submitting for approval';
        }

        if (message != '') {
            this.showToast('', message, 'error');
            return false;
        }
        else {
            return true;
        }
    },

    configureProducts: function (component) {
        var proposalId = component.get("v.recordId");
        var flowName = component.get("v.proposalObj.flowName");
        if ((component.get("v.proposalObj.pricingTool") == 'AMESA' || component.get("v.proposalObj.pricingTool") == 'OCE')  && component.get("v.proposalObj.proposalValidity")) {
            this.showToast('', $A.get("$Label.c.proposalValidationError"), 'error');
        } else if(flowName != null) {
            window.open("/apex/Apttus_QPConfig__ProposalConfiguration?flow="+flowName+"&id=" + proposalId + "&useAdvancedCurrency=true", "_self");
            this.updateQuoteStatus(component, 'In-Progress', '');
        }
    },

    makeAsPrimary: function (component) {
        var proposalId = component.get("v.recordId");
        window.open("/apex/Apttus_Proposal__ProposalMakePrimary?id=" + proposalId, "_self");
    },

    recallAction : function(component, event) {
		var action = component.get("c.recallProposal");

        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.spinner", false);
				$A.get('e.force:refreshView').fire();
                this.showToast('', 'The Proposal record is recalled successfully', 'success'); 
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                       this.showToast('ERROR', errors[0].message, 'error');
                    }
                    component.set("v.spinner", false);
                }
            }
        });
        $A.enqueueAction(action);
	},

    updateQuoteStatus : function(component, stage, msg) {
		var action = component.get("c.updateQuoteStatus");

        action.setParams({
            'recordId': component.get("v.recordId"),
            'approvalStage': stage
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && msg != '') {
                component.set("v.spinner", false);
				$A.get('e.force:refreshView').fire();
                this.showToast('', msg, 'success'); 
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                       this.showToast('ERROR', errors[0].message, 'error');
                    }
                    component.set("v.spinner", false);
                }
            }
        });
        $A.enqueueAction(action);
	},

    updateQuoteStatusForOCE : function(component, stage, msg, status) {
        var action = component.get("c.updateQuoteStatusOCE");
        
        action.setParams({
            'recordId': component.get("v.recordId"),
            'stage': stage,
            'status' : status
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.spinner", false);
                $A.get('e.force:refreshView').fire();
                this.showToast('', msg, 'success'); 
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast('ERROR', errors[0].message, 'error');
                    }
                    component.set("v.spinner", false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    updateQuoteStatusOCE: function (component, stage, msg) {
        component.set("v.spinner", true);
        var action = component.get("c.submitForApprovalProcess");

        action.setParams({
            'recordId': component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            var state = response.getReturnValue();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                this.showToast('', 'The Proposal has been submitted for approval', 'success');
            } else if (state === "ERROR") {
                this.showToast('ERROR', 'No approvers found for existing criteria.', 'error');
            } else if (state === 'Approved') {
                $A.get('e.force:refreshView').fire();
                this.showToast('', 'Due to Auto approve criteria this proposal has been moved to Approved stage.', 'success');
            }
            else {
                console.log(state);
                this.showToast('ERROR', 'Something went wrong.', 'error');
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },

    requestApproved: function (component, comment) {
        component.set("v.spinner", true);
        var action = component.get("c.createWorkItemOnApprove");
        action.setParams({
            'recordId': component.get("v.recordId"),
            'comment': comment
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var status = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.spinner", false);
                $A.get('e.force:refreshView').fire();
                if(status === "Approved" || status === "SUCCESS"){
                    this.showToast('', 'Approved', 'success');
                }
                else{
                    console.log(status)
                    this.showToast('ERROR', 'Something went wrong.', 'error');
                }
                
            } else if (state === "ERROR") {
                component.set("v.spinner", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast('ERROR', errors[0].message, 'error');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    requestRejected: function (component, stage, comment) {
        component.set("v.spinner", true);
        var action = component.get("c.createWorkItemOnReject");

        action.setParams({
            'recordId': component.get("v.recordId"),
            'comment': comment
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.spinner", false);
                $A.get('e.force:refreshView').fire();
                this.showToast('', 'Rejected', 'error');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    component.set("v.spinner", false);
                    if (errors[0] && errors[0].message) {
                        this.showToast('ERROR', errors[0].message, 'error');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    updateNewApprover: function (component, oldActorToNewActorIdMap) {
        component.set("v.spinner", true);
        var action = component.get("c.updateOldApproverWithNew");
        action.setParams({
            approversJSON: JSON.stringify(oldActorToNewActorIdMap),
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getReturnValue() == 'Success') {
                component.set("v.spinner", false);
                this.showToast('', 'Approvers are reassigned successfully.', 'success');
            } else {
                var errors = response.getError();
                if (errors) {
                    component.set("v.spinner", false);
                    if (errors[0] && errors[0].message) {
                        this.showToast('ERROR', errors[0].message, 'error');
                    }
                }
            }
            console.log(response.getReturnValue)
        });
        component.set('v.reassignForSubmitter', false);
        component.set("v.spinner", false);
        $A.enqueueAction(action);

    },
    
    generateProposals : function (component) {
        var proposalId = component.get("v.recordId");
        window.open("/apex/Apttus_Proposal__ProposalGenerate?id=" + proposalId, "_self");
    },
    previewProposals : function (component) {
        var proposalId = component.get("v.recordId");
        window.open("/apex/Apttus_Proposal__ProposalGenerate?action=Preview&id=" + proposalId, "_self");
    },
    createAgreements : function(component) {
        var vfUrl = '/apex/Apttus_QPComply__ProposalAgreementCreate?id=' + component.get("v.recordId") + '&copyLineItems=true';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": vfUrl
        });
        urlEvent.fire();				 
    }
})
