({
    doInit: function (component, event, helper) {
        helper.getCSM_CaseHistory(component);
    },

    handleRecordUpdated: function (component, event, helper) {
        var eventParams = event.getParams();
        if (eventParams.changeType === "LOADED") {
        } else if (eventParams.changeType === "CHANGED") {
            // record is changed
            $A.get('e.force:refreshView').fire();
        } else if (eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if (eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
        component.set("v.isLoading", false);
    },

    handleSave: function (component, event, helper) {
        if (component.find("commentBody").get("v.value") != "") {
            if (component.get("v.autoCloseCaseIsChecked") && component.find("autoCloseCaseCheck") !== undefined) {
                var r = confirm($A.get("$Label.c.Please_confirm_that_you_would_like_to_close_this_Case"));
                if (r === true) {
                    helper.insertCaseComment(component);
                }
            } else {
                helper.insertCaseComment(component);
            }
        }
    },

    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var message = "";
        if (uploadedFiles.length == 1) message = uploadedFiles.length + " file was added to case";
        else if (uploadedFiles.length > 1) message = uploadedFiles.length + " files were added to case";
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "type": "success",
            "title": "Saved",
            "message": message
        });
        resultsToast.fire();
        helper.notifyCaseOriginatorForAttachment(component);
    },

    displayEmail: function (component, event, helper) {
        var show = component.find("showHideEmail").get("v.checked");
        if (show == true) {
            component.set("v.isShow", true);
        } else {
            component.set("v.isShow", false);
        }
        helper.getCSM_CaseHistory(component);
    },

    displayStatus: function (component, event, helper) {
        var show = component.find("showHideStatus").get("v.checked");
        if (show == true) {
            component.set("v.isShowStatus", true);
        } else {
            component.set("v.isShowStatus", false);
        }
        helper.getCSM_CaseHistory(component);
    }
})