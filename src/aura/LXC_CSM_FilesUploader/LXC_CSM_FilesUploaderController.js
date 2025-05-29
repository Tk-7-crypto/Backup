({
    init: function(component, event, helper) {
        helper.getCountAttachment(component);
    },

    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var message="";
        if (uploadedFiles.length == 1)message=uploadedFiles.length + " file was added to case";
        else if (uploadedFiles.length > 1) message=uploadedFiles.length + " files were added to case";
        if(component.find("availableForAllUsers").getElement().checked || component.get("v.knowledge") === true ){
            for (var i=0; i< uploadedFiles.length; i++){
                helper.updateContentDocumentLinkVisibility(component,uploadedFiles[i].documentId,"AllUsers");
            }
            component.find("availableForAllUsers").set("v.value", false);
        }
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "type": "success",
            "title": "Saved",
            "message": message
        });
        resultsToast.fire();
        helper.getCountAttachment(component);
    },

    openSubtab: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__LXC_CSM_RecordAttachments"
                    },
                    "state": {
                        "uid": "1",
                        "c__recordId": component.get("v.recordId")
                    }
                }
            }).then(function(subtabId) {
                workspaceAPI.setTabIcon({
                    tabId: subtabId,
                    icon: "utility:file",
                    iconAlt: "attachment"
                });
                workspaceAPI.setTabLabel({
                    tabId: subtabId,
                    label: "Attachments"
                });
            }).catch(function(error) {
                console.log("error");
            });
        });
    }
})