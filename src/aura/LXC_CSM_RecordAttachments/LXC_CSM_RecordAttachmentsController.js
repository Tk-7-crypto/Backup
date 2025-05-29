({
    init: function (component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var recordId;
        if (component.get('v.recordId')) {
            recordId = component.get('v.recordId');
        } else {
            recordId = myPageRef && myPageRef.state ? myPageRef.state.c__recordId : undefined;
        }
        if (recordId) {
            component.set("v.recordId", recordId);
            component.find("record").reloadRecord();
            helper.getAttachments(component);
            helper.getPublishStatus(component);
            helper.getPermissionSets(component);
            helper.getCurrentUser(component);
        }


    },

    openSingleFile: function (component, event, helper) {
        var selectedItem = event.currentTarget;
        var ContentDocumentId = selectedItem.dataset.value;
        $A.get('e.lightning:openFiles').fire({
            recordIds: [ContentDocumentId]
        });
    },

    sortBy: function (component, event, helper) {
        var files = component.get("v.files");
        var val = event.currentTarget.dataset.val;
        if (event.currentTarget.dataset.sort == 'desc') {
            files.sort(function (a, b) { return (a[val].toLowerCase() < b[val].toLowerCase()) ? 1 : ((b[val].toLowerCase() < a[val].toLowerCase()) ? -1 : 0); });
            event.currentTarget.dataset.sort = "asc"
        } else {
            files.sort(function (a, b) { return (a[val].toLowerCase() > b[val].toLowerCase()) ? 1 : ((b[val].toLowerCase() > a[val].toLowerCase()) ? -1 : 0); });
            event.currentTarget.dataset.sort = "desc"
        }
        component.set("v.files", files);
    },

    deleteFile: function (component, event, helper) {
        var r = confirm("Are you sure you want to delete this file ?");
        var selectedItem = event.currentTarget;
        var childRecordId = selectedItem.dataset.value;
        if (r == true) {
            helper.deleteContentDocumentById(component, childRecordId, true);
        }
    },

    openSubtab: function (component, event, helper) {
        var selectedItem = event.currentTarget;
        var recordId = selectedItem.dataset.value;
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openSubtab({
            url: '/lightning/r/' + recordId + '/view',
            focus: true
        }).then(function (subtabId) {
        })
            .catch(function (error) {
                console.log(error);
            });
    },

    openRecord: function (component, event, helper) {
        var selectedItem = event.currentTarget;
        var recordId = selectedItem.dataset.value;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "related"
        });
        navEvt.fire();
    },

    updateVisibility: function (component, event, helper) {
        var selectedItem = event.currentTarget;
        var documentId = selectedItem.dataset.value;
        var visibility = selectedItem.dataset.visibility;
        helper.updateContentDocumentLinkVisibility(component, documentId, visibility);
    },


    handleSelectAll: function(component, event, helper) {
        let isChecked = event.target.checked;
        let files = component.get("v.files") || [];
    
        files.forEach(file => {
            file.isSelected = isChecked;
        });
    
        let selectedIds = isChecked ? files.map(file => file.id) : [];
    
        component.set("v.files", files);
        component.set("v.selectedFiles", selectedIds);
        component.set("v.isAllSelected", isChecked);
        helper.updateSelectAllState(component);
    },
        

    handleFileSelect: function (component, event, helper) {
        let checkbox = event.getSource();
        let fileId = checkbox.get("v.value");
        let isChecked = checkbox.get("v.checked");
    
        let files = component.get("v.files") || [];
        let selected = component.get("v.selectedFiles") || [];
    
        for (let file of files) {
            if (file.id === fileId) {
                file.isSelected = isChecked;
                break;
            }
        }
    
        if (isChecked) {
            if (!selected.includes(fileId)) {
                selected.push(fileId);
            }
        } else {
            selected = selected.filter(id => id !== fileId);
        }
    
        component.set("v.files", files);
        component.set("v.selectedFiles", selected);
        helper.updateSelectAllState(component);
    },
    
    
    downloadSelected : function(component, event, helper) {
        let selectedFiles = component.get("v.selectedFiles");
        let caseId =  component.get("v.simpleRecord.CaseNumber");
        if (!selectedFiles || selectedFiles.length === 0) {
            alert("Please select at least one file.");
            return;
        }
        component.set("v.isLoading", true);
        let action = component.get("c.downloadFilesAsZip");
        action.setParams({ 
            fileIds: selectedFiles,
            caseId: caseId
         });
    
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let contentDocumentId = response.getReturnValue();
                helper.dowloadFile(component, contentDocumentId);

                setTimeout(() => {
                    helper.deleteContentDocumentById(component, contentDocumentId, false);
                }, 4000);

            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Erreur with ZIP generation: " + errors[0].message);
                }
            } else {
                console.error("Error : " + state);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    downloadFile : function(component, event, helper) {
        const fileId = event.currentTarget.getAttribute("data-value");
        helper.dowloadFile(component, fileId);
    }
})