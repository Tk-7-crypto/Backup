({
    getCSM_CaseHistory: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getCSM_CaseHistory");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "email_show": component.get("v.isShow"),
            "status_show": component.get("v.isShowStatus")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var history = response.getReturnValue();
                if (history != undefined && history.length > 0) {
                    history.sort(function (a, b) { return (a.lastModifiedDate < b.lastModifiedDate) ? 1 : ((b.lastModifiedDate < a.lastModifiedDate) ? -1 : 0); });
                    if (history[history.length - 1].value != undefined && history[history.length - 1].value.includes("Description:")) {
                        history.pop();
                    }
                    component.set("v.CSM_CaseHistory", history);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) { }
                } else { }
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    insertCaseComment: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.insertCaseComment");
        var caseComment = {};
        caseComment.ParentId = component.get("v.recordId");
        caseComment.CommentBody = component.find("commentBody").get("v.value");
        action.setParams({
            "caseComment": caseComment
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("commentBody").set("v.value", "");
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": "Success",
                    "message": "Case Comment was created."
                });
                resultsToast.fire();

                var record = component.get("v.simpleRecord");
                if (record.Status === "Resolved with Customer" || record.SubStatus__c === "Customer Confirmation to Close" ) {
                    if (component.get("v.autoCloseCaseIsChecked")) {
                        component.set("v.simpleRecord.Status", "Closed");
                        component.set("v.simpleRecord.SubStatus__c", "");
                        component.find("recordLoader").saveRecord(function (saveResult) {
                            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                                var resultsToast = $A.get("e.force:showToast");
                                resultsToast.setParams({
                                    "type": 'Success',
                                    "title": "Case updated",
                                    "message": "The case is now closed"
                                });
                                resultsToast.fire();
                            } else if (saveResult.state === "INCOMPLETE") { } else if (saveResult.state === "ERROR") {
                                var errors = "";
                                for (var i = 0; saveResult.error.length > i; i++) {
                                    errors = errors + saveResult.error[i].message;
                                }
                                var resultsToast = $A.get("e.force:showToast");
                                resultsToast.setParams({
                                    "type": 'Error',
                                    "title": "Case not Updated",
                                    "message": errors
                                });
                                resultsToast.fire();
                            } else { }
                        });
                    }
                }
                this.getCSM_CaseHistory(component);
            } else if (state === "ERROR") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": "Error",
                    "message": "Unable to add a commentary"
                });
                resultsToast.fire();
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    notifyCaseOriginatorForAttachment: function (component) {
        var caseId = component.get('v.recordId');
        var action = component.get("c.sendAttachmentEmailToCaseOriginator");
        action.setParams({
            caseId: caseId,
        });                                                     
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
            } else if (state === "ERROR") {
                var errors = response.getError();
            }
            component.set("v.isLoading", false);
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
})