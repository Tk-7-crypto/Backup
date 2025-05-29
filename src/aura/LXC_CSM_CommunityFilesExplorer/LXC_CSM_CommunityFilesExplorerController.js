({
    doInit: function (component, event, helper) {
        helper.init(component);
    },

    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        for (var i = 0; i < uploadedFiles.length; i++) {
            helper.updateContentFolderMember(component, component.get("v.currentFolder").Id, uploadedFiles[i].documentId);
        }
        helper.getFoldersByParentId(component, component.get("v.currentFolder").Id);
        var navigationFolders = component.get("v.navigationFolders");
        navigationFolders.push(component.get("v.folders")[event.currentTarget.id]);
        component.set("v.navigationFolders", navigationFolders);
    },

    handleNewFolder: function (component, event, helper) {
        helper.createNewFolder(component);
    },

    closeForm: function (component, event, helper) {
        helper.closeForm(component);
    },

    openForm: function (component, event, helper) {
        helper.openForm(component);
    },
    onSubmit: function (component, event, helper) {
        if (component.find("newFolderName").get("v.value") == "") {
            component.find("newFolderName").set('v.validity', { valid: false, badInput: true });
            component.find("newFolderName").showHelpMessageIfInvalid();
        } else helper.createNewFolder(component);
    },

    folderClick: function (component, event, helper) {
        component.set("v.currentFolder", component.get("v.folders")[event.currentTarget.id]);
        helper.getFoldersByParentId(component, component.get("v.currentFolder").Id);
        var navigationFolders = component.get("v.navigationFolders");
        navigationFolders.push(component.get("v.folders")[event.currentTarget.id]);
        component.set("v.navigationFolders", navigationFolders);
    },


    folderClick2: function (component, event, helper) {
        if (event.currentTarget.id === "reset") {
            helper.init(component);
        } else {
            component.set("v.currentFolder", component.get("v.navigationFolders")[event.currentTarget.id]);
            helper.getFoldersByParentId(component, component.get("v.currentFolder").Id);
            var navigationFolders = component.get("v.navigationFolders");
            navigationFolders = navigationFolders.slice(0, parseInt(event.currentTarget.id) + 1);
            component.set("v.navigationFolders", navigationFolders)
        }

    },

    sortBy: function (component, event, helper) {
        var folders = component.get("v.folders");
        var files = component.get("v.files");
        if (event.currentTarget.id == "sortByName") {
            if (event.currentTarget.dataset.sort == 'desc') {
                folders.sort(function (a, b) { return (a.Name.toLowerCase() < b.Name.toLowerCase()) ? 1 : ((b.Name.toLowerCase() < a.Name.toLowerCase()) ? -1 : 0); });
                files.sort(function (a, b) { return (a.ChildRecord.Title.toLowerCase() < b.ChildRecord.Title.toLowerCase()) ? 1 : ((b.ChildRecord.Title.toLowerCase() < a.ChildRecord.Title.toLowerCase()) ? -1 : 0); });
                event.currentTarget.dataset.sort = "asc"
            } else {
                folders.sort(function (a, b) { return (a.Name.toLowerCase() > b.Name.toLowerCase()) ? 1 : ((b.Name.toLowerCase() > a.Name.toLowerCase()) ? -1 : 0); });
                files.sort(function (a, b) { return (a.ChildRecord.Title.toLowerCase() > b.ChildRecord.Title.toLowerCase()) ? 1 : ((b.ChildRecord.Title.toLowerCase() > a.ChildRecord.Title.toLowerCase()) ? -1 : 0); });
                event.currentTarget.dataset.sort = "desc"
            }
        } else {
            if (event.currentTarget.dataset.sort == 'desc') {
                folders.sort(function (a, b) { return (a.LastModifiedDate < b.LastModifiedDate) ? 1 : ((b.LastModifiedDate < a.LastModifiedDate) ? -1 : 0); });
                files.sort(function (a, b) { return (a.ChildRecord.LastModifiedDate < b.ChildRecord.LastModifiedDate) ? 1 : ((b.ChildRecord.LastModifiedDate < a.ChildRecord.LastModifiedDate) ? -1 : 0); });
                event.currentTarget.dataset.sort = "asc"
            } else {
                folders.sort(function (a, b) { return (a.LastModifiedDate > b.LastModifiedDate) ? 1 : ((b.LastModifiedDate > a.LastModifiedDate) ? -1 : 0); });
                files.sort(function (a, b) { return (a.ChildRecord.LastModifiedDate > b.ChildRecord.LastModifiedDate) ? 1 : ((b.ChildRecord.LastModifiedDate > a.ChildRecord.LastModifiedDate) ? -1 : 0); });
                event.currentTarget.dataset.sort = "desc"
            }
        }
        component.set("v.folders", folders);
        component.set("v.files", files);
    },

    openSingleFile: function (component, event, helper) {
        $A.get('e.lightning:openFiles').fire({
            recordIds: [component.get("v.files")[event.currentTarget.id].ChildRecordId]
        });
    },

    deleteFile: function (component, event, helper) {
        var r = confirm("Are you sure you want to delete this file ?");
        if (r == true) {
            helper.deleteContentDocumentById(component, component.get("v.files")[event.currentTarget.id].ChildRecordId);
        }
    },

    navigateToKb: function(component, event, helper) {
        const productName = event.getSource().get("v.value");
        const navService = component.find("navService");
        const pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: '/kb?p=' + productName
            }
        };
        navService.navigate(pageReference);
    },

    navigateToForum: function(component, event, helper) {
        const productName = event.getSource().get("v.value");
        const navService = component.find("navService");
        const pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: '/groups?p=' + productName
            }
        };
        navService.navigate(pageReference);
    }

})