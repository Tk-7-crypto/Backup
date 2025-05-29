({
    getAttachments: function (component) {
        component.set("v.isLoading", true);
        var startLetter = component.get("v.recordId").substring(0, 1);
        if (startLetter == 'k') {
            component.set("v.knowledge", true);
        }
        else {
            component.set("v.knowledge", false);
        }
        var action = component.get("c.getAttachments");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var files = response.getReturnValue();
                component.set("v.files", files);
            }
            else if (state === "ERROR") {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    getPermissionSets: function (component) {
        var action = component.get("c.getPermissionSets");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var files = response.getReturnValue();
                component.set("v.permission", files);
            }
            else if (state === "ERROR") {
                console.log("ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    getPublishStatus: function (component) {
        var action = component.get("c.getPublishStatus");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.publishStatus", response.getReturnValue());
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },


    getCurrentUser: function (component) {
        var action = component.get("c.currentUser");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var files = response.getReturnValue();
                component.set("v.user", files);
            }
            else if (state === "ERROR") {
                console.log("ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    deleteContentDocumentById: function (component, contentDocumentId, showMessage) {
        var action = component.get("c.deleteContentDocumentById");
        action.setParams({
            "contentDocumentId": contentDocumentId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (showMessage) {
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "SUCCESS",
                        "message": "File was deleted."
                    });
                    resultsToast.fire();
                }
                console.log("File was deleted.");
                this.getAttachments(component);
            } else if (state === "ERROR") {
                if (response.getError()[0].pageErrors[0].statusCode === "INSUFFICIENT_ACCESS_OR_READONLY") {
                    if (showMessage) {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type": "ERROR",
                            "title": " Action Denied",
                            "message": "You are not allowed to delete this file"
                        });
                        $A.get("e.force:closeQuickAction").fire();
                        resultsToast.fire();
                    }
                    console.log("You are not allowed to delete this file");
                } else {
                    console.log("ERROR " + JSON.stringify(response.getError()));
                }
            }
        });
        $A.enqueueAction(action);
    },

    updateContentDocumentLinkVisibility: function (component, contentDocumentId, visibility) {
        var action = component.get("c.updateContentDocumentLinkVisibility");
        action.setParams({
            "contentDocumentId": contentDocumentId,
            "linkedEntityId": component.get("v.recordId"),
            "visibility": visibility
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "Success",
                    "message": "The visibility of the attachment has been updated."
                });
                resultsToast.fire();
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                if(response.getError()[0].pageErrors[0].message.includes("Case Type Is Mandatory")){
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "ERROR",
                        "title": " Action Denied",
                        "message": "Case type is mandatory to make public visible"
                    });
                    resultsToast.fire();
                    console.log("ERROR: " + JSON.stringify(response.getError()));
                }
                //console.log("ERROR STRING: " + (response.getError()[0]));
                
            }
        });
        $A.enqueueAction(action);
    },

    updateSelectAllState: function(component) {
        let files = component.get("v.files") || [];
        let total = files.length;
        let selectedCount = files.filter(f => f.isSelected).length;
    
        let selectAllCheckbox = document.querySelector('input[name="selectAll"]');
        
        if (selectAllCheckbox) {
            if (selectedCount === total) {
                selectAllCheckbox.checked = true;
                selectAllCheckbox.indeterminate = false;
                component.set("v.isAllSelected", true);
            } else if (selectedCount === 0) {
                selectAllCheckbox.checked = false;
                selectAllCheckbox.indeterminate = false;
                component.set("v.isAllSelected", false);
            } else {
                selectAllCheckbox.checked = false;
                selectAllCheckbox.indeterminate = true;
                component.set("v.isAllSelected", false);
            }
        }
    },

    dowloadFile: function(component, fileId) {
        if (fileId) {
            const downloadUrl = '/sfc/servlet.shepherd/document/download/' + fileId;
           /* window.open(downloadUrl, '_blank');*/
            $A.get("e.force:navigateToURL").setParams({
                "url": downloadUrl,
                "isredirect": false
            }).fire();
        } else {
            console.error('No file ID found for download.');
        }
    }
    
    
})