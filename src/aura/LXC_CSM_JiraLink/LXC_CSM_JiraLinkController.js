({
    doInit: function (component, event, helper) {
        component.set("v.selectedtypeJiraLink", "1");
        helper.getCase(component);
    },

    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var message = "";
        if (uploadedFiles.length == 1) message = uploadedFiles.length + " file was added to case";
        else if (uploadedFiles.length > 1) message = uploadedFiles.length + " files were added to case";
        for (var i = 0; i < uploadedFiles.length; i++) {
            helper.addJiraAttachment(component, uploadedFiles[i].documentId);
        }

        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "type": "success",
            "title": "Saved",
            "message": message
        });
        resultsToast.fire();
    },

    changeJiraPlatform: function (component, event, helper) {
        if (component.get("v.selectedtypeJiraLink") != "1") {
            helper.getProjects(component);
            helper.getJiraPriorities(component);
        }
    },

    changeJiraProject: function (component, event, helper) {
        var jiraProjects = component.get("v.jiraProjects");
        helper.getJiraIssueTypes(component);
    },

    changeJiraIssueType: function (component, event, helper) {
        helper.getJiraAvailableFields(component);
    },

    deleteJiraRecord: function (component, event, helper) {
        component.set("v.isLoading", true);
        component.find("jiraLinkRecord").deleteRecord($A.getCallback(function (deleteResult) {
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                component.set("v.jiraLinkId", null);
            } else if (deleteResult.state === "ERROR") {
                console.log('[LXC_CSM_JiraLink] Problem deleting record, error: ' + JSON.stringify(deleteResult.error));
                component.set("v.isLoading", false);
            } else {
                console.log(' [LXC_CSM_JiraLink]Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
                component.set("v.isLoading", false);
            }
        }));
    },

    updateStatus: function (component, event, helper) {
        helper.updateJiraStatus(component, event.getSource().get("v.value"));
    },

    jiraRecordUpdated: function (component, event, helper) {
        var eventParams = event.getParams();
        if (eventParams.changeType === "LOADED") {
            if (component.get("v.jiraLinkId") == undefined) {
                helper.getJiraBaseUrls(component);
            } else {
                helper.linkJiraIssue(component, false);
                helper.getJiraTransitions(component);
            }
        } else if (eventParams.changeType === "REMOVED") {
            var action = component.get("c.updateCaseJiraIssue");
            action.setParams({
                "caseId": component.get("v.recordId"),
                "jiraIssue": ""
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.toast("success", "Jira Link Component", "The JIRA link was deleted.");
                    helper.getJiraLink(component);
                } else if (state === "ERROR") {
                    console.log("ERROR: " + JSON.stringify(response.getError()));
                    helper.toast("error", "Jira Link Component", "There is problem delete the JIRA link.");
                }
                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);
        }
    },

    addJiraComment: function (component, event, helper) {
        helper.addJiraComment(component);
    },

    openCommentsJiraForm: function (component, event, helper) {
        helper.openModal(component);
        helper.getJiraComments(component);
    },

    closeCommentsJiraForm: function (component, event, helper) {
        helper.closeModal(component);
    },


    openCreateJiraForm: function (component, event, helper) {
        helper.openModal(component);
    },

    closeCreateJiraForm: function (component, event, helper) {
        helper.closeModal(component);
    },

    handleRadioTypeJiraLinkClick: function (component, event, helper) {
        component.set('v.selectedtypeJiraLink', event.getSource().get('v.value'));
        if (event.getSource().get('v.value') != "1") {
            helper.getJiraPriorities(component);
            helper.getProjects(component);
        }
    },

    handleCreateJiraLinkClick: function (component, event, helper) {
        if (component.get('v.selectedtypeJiraLink') == "1") {
            if (helper.validateJIRAForm(component)) {
                helper.linkJiraIssue(component, true);
            } else {
                console.log("[LXC_CSM_JiraLink] Form Not valided!");
            }
        } else {
            if (helper.validateCreateJIRAForm(component)) {
                helper.createJiraIssue(component);
            }
        }
    },
})