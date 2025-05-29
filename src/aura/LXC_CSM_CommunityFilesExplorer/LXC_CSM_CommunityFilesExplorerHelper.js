({
    init: function (component) {
        component.set("v.currentFolder", {});
        component.set("v.navigationFolders", []);
        component.set("v.files", []);
        var type = component.get("v.type");
        switch (type) {
            case 'Specific root folder':
                this.getFolderByTopicId(component);
                break;
            case 'Folder Name':
                if(component.get("v.folderName") != 'IQVIA Data Privacy Resources') {
                    var pageUrl = window.location.href;
                    var params = new URL(pageUrl).searchParams;
                    var productName = params.get('p');
                    if (productName) {
                        component.set("v.folderName", decodeURI(productName));
                    }
                }
                this.getFolderByFolderNameForCurrentUser(component);
                component.set("v.message", $A.get("$Label.c.It_may_have_been_deleted_or_you_don_t_have_permission_to_view_it"));
                break;
            case 'Shared folder':
                component.set("v.message", $A.get("$Label.c.You_do_not_have_a_share_folder_yet_Please_make_a_request_to_your_IQVIA_Service"));
                this.canUploadFile(component);
                this.getSharedFolderByUserParentAccount(component);
                break;
            case 'Mikado Reports Folder':
                component.set("v.message", $A.get("$Label.c.We_cannot_find_your_Mikado_Reports_Please_make_a_request_to_you_IQVIA_Service_S"));
                component.set("v.currentFolder.Name", "Mikado Reports");
                this.getMikadoContentFolderMember(component);
                break;
            default:
                console.log('Sorry, we are out of ' + type + '.');
        }
    },

    canUploadFile: function (component) {
        var action = component.get("c.getUserAccount");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue()[0]) {
                    var writePermission = response.getReturnValue()[0].Shared_Folder_Write_Permission__c;
                    component.set("v.canUploadFile", writePermission);
                }
            } else {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },

    checkIfAccess: function (component) {
        var action = component.get("c.getFolders");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var folders = response.getReturnValue();
            } else {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    updateContentFolderMember: function (component, parentContentFolderId, childRecordId) {
        component.set("v.isLoading", true);
        var action = component.get("c.updateContentFolderMember");
        action.setParams({
            "parentContentFolderId": parentContentFolderId,
            "childRecordId": childRecordId

        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    getFolders: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getFolders");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.folders", response.getReturnValue());
            } else {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    getFolderByFolderNameForCurrentUser: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getFolderByFolderNameForCurrentUser");
        action.setParams({
            "folderName": component.get("v.folderName")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(!response.getReturnValue()[0]) {
                    component.set("v.folders", []);
                    component.set("v.isLoading", false);
                    return;
                }
                component.set("v.currentFolder", response.getReturnValue()[0])
                var action2 = component.get("c.getFolders");
                action2.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var folders = response.getReturnValue();
                        var test = folders.filter(function (folder) {
                            if (folder.Name === component.get("v.currentFolder").Name)
                                return true;
                            else
                                return false;
                        });
                        var foldersVisible4All = component.get("v.nameFolderVisible4All");
                        if (test[0] != undefined || foldersVisible4All.includes(component.get("v.currentFolder").Name )) {
                            var navigationFolders = component.get("v.navigationFolders");
                            navigationFolders.push(component.get("v.currentFolder"));
                            component.set("v.navigationFolders", navigationFolders)
                            this.getFoldersByParentId(component, component.get("v.currentFolder").Id);
                        } else {
                            console.log("Forbidden");
                            component.set("v.folders", []);
                            component.set("v.showModule", false)
                            component.set("v.isLoading", false);
                        }
                    } else {
                        component.set("v.isLoading", false);
                        console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                    }
                });
                $A.enqueueAction(action2);
            } else {
                component.set("v.isLoading", false);
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    createNewFolder: function (component) {
        var action = component.get("c.insertNewFolder");
        action.setParams({
            "name": component.find("newFolderName").get("v.value"),
            "parentContentFolderId": component.get("v.currentFolder").Id
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.getFoldersByParentId(component, component.get("v.currentFolder").Id);
                this.closeForm(component);
            } else {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    getFolderByTopicId: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getFolderByTopicId");
        action.setParams({
            "id": component.get("v.rootFolder")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentFolder", response.getReturnValue()[0])
                var action2 = component.get("c.getFolders");
                action2.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var folders = response.getReturnValue();
                        var foldersVisible4All = component.get("v.nameFolderVisible4All");
                        var test = folders.filter(function (folder) {
                            if (folder.Name === component.get("v.currentFolder").Name || foldersVisible4All.includes(component.get("v.currentFolder").Name ))
                                return true;
                            else
                                return false;
                        });
                        if (test[0] != undefined) {
                            var navigationFolders = component.get("v.navigationFolders");
                            navigationFolders.push(component.get("v.currentFolder"));
                            component.set("v.navigationFolders", navigationFolders)
                            this.getFoldersByParentId(component, component.get("v.currentFolder").Id);
                        } else {
                            console.log("Forbidden");
                            component.set("v.folders", []);
                        }
                    } else {
                        console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                    }
                    component.set("v.isLoading", false);
                });
                $A.enqueueAction(action2);
            } else {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    getSharedFolderByUserParentAccount: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getSharedFolderByUserParentAccount");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var currentFolder = response.getReturnValue()[0];
                if (currentFolder) {
                    component.set("v.currentFolder", currentFolder);
                    var navigationFolders = component.get("v.navigationFolders");
                    navigationFolders.push(currentFolder);
                    component.set("v.navigationFolders", navigationFolders)
                    this.getContentWorkspaceByRootContentFolderId(component, currentFolder.ParentContentFolderId);
                    this.getFoldersByParentId(component, currentFolder.Id);
                } else {
                    component.set("v.showModule", false);
                }
            } else if (state === "ERROR") {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                component.set("v.isLoading", false);
                component.set("v.showModule", false);
            }

        });
        $A.enqueueAction(action);
    },

    getContentWorkspaceByRootContentFolderId: function (component, rootContentFolderId) {
        var action = component.get("c.getContentWorkspaceByRootContentFolderId");
        action.setParams({
            "rootContentFolderId": rootContentFolderId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var workspaceId = response.getReturnValue().Id;
                component.set("v.workspaceId", workspaceId);

            } else if (state === "ERROR") {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }

        });
        $A.enqueueAction(action);
    },

    getMikadoContentFolderMember: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getMikadoContentFolderMember");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                var files = response.getReturnValue();
                if (files) {
                    files.sort(function (a, b) { return (a.ChildRecord.LastModifiedDate < b.ChildRecord.LastModifiedDate) ? 1 : ((b.ChildRecord.LastModifiedDate < a.ChildRecord.LastModifiedDate) ? -1 : 0); });
                    component.set("v.files", files);
                } else {
                    component.set("v.showModule", false);
                }
            }
            else if (state === "ERROR") {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                component.set("v.showModule", false);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    getMikadoFoldersByContact: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getMikadoFoldersByContact");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mikadoFolders = response.getReturnValue();
                if (mikadoFolders.length > 0) {
                    var action2 = component.get("c.getFoldersByParentId");
                    action2.setParams({
                        "parentContentFolderId": component.get("v.rootMikadoFolder")
                    });
                    action2.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var contentFolders = response.getReturnValue();
                            var folders = [];
                            if (contentFolders) {
                                for (var i = 0; i < contentFolders.length; i++) {
                                    for (var j = 0; j < mikadoFolders.length; j++) {
                                        if (contentFolders[i].Name == mikadoFolders[j].Name) {
                                            folders.push(contentFolders[i]);
                                        }
                                    }
                                }
                                folders.sort(function (a, b) { return (a.LastModifiedDate < b.LastModifiedDate) ? 1 : ((b.LastModifiedDate < a.LastModifiedDate) ? -1 : 0); });
                                component.set("v.folders", folders);
                            } else {
                                component.set("v.showModule", false);
                            }
                        } else {
                            console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                        }
                        component.set("v.isLoading", false);
                    });
                    $A.enqueueAction(action2);
                } else {
                    component.set("v.showModule", false);
                    component.set("v.isLoading", false);
                }
            } else if (state === "ERROR") {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                component.set("v.isLoading", false);
                component.set("v.showModule", false);
            }

        });
        $A.enqueueAction(action);
    },

    getFoldersByParentId: function (component, parentId) {
        component.set("v.isLoading", true);
        console.log(parentId);
        var action = component.get("c.getFoldersByParentId");
        action.setParams({
            "parentContentFolderId": parentId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var folders = response.getReturnValue();
                folders.sort(function (a, b) { return (a.LastModifiedDate < b.LastModifiedDate) ? 1 : ((b.LastModifiedDate < a.LastModifiedDate) ? -1 : 0); });
                var repFolder;
                folders.forEach(folder => {
                    if (folder.Name === component.get("v.forceToSeeFolderName")) {
                        repFolder = folder;
                    }
                });

                if (repFolder) {
                    component.set("v.currentFolder", repFolder);
                    var navigationFolders = component.get("v.navigationFolders");
                    navigationFolders.push(repFolder);
                    component.set("v.navigationFolders", navigationFolders)
                    this.getFoldersByParentId(component, repFolder.Id);
                } else {
                    component.set("v.folders", folders);
                    var action2 = component.get("c.getFolderMemberByParentId");
                    action2.setParams({
                        "parentContentFolderId": parentId
                    });
                    action2.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var files = response.getReturnValue();
                            files.sort(function (a, b) { return (a.ChildRecord.LastModifiedDate < b.ChildRecord.LastModifiedDate) ? 1 : ((b.ChildRecord.LastModifiedDate < a.ChildRecord.LastModifiedDate) ? -1 : 0); });
                            component.set("v.files", files);
                        } else {
                            console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                        }
                        component.set("v.isLoading", false);
                    });
                    $A.enqueueAction(action2);
                }


            } else {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },

    deleteContentDocumentById: function (component, contentDocumentId) {
        var action = component.get("c.deleteContentDocumentById");
        action.setParams({
            "contentDocumentId": contentDocumentId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.getFoldersByParentId(component, component.get("v.currentFolder").Id);
            } else if (state === "ERROR") {
                if (response.getError()[0].pageErrors[0].statusCode === "INSUFFICIENT_ACCESS_OR_READONLY") {
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "ERROR",
                        "title": " Action Denied",
                        "message": "You are not allowed to delete this file"
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    resultsToast.fire();
                } else {
                    console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                }
            }
        });
        $A.enqueueAction(action);

    },

    openForm: function (component) {
        $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-hide");
        $A.util.addClass(component.find("modaldialog"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop--hide");
        $A.util.addClass(component.find("backdrop"), "slds-backdrop--open");

    },
    closeForm: function (component) {
        $A.util.addClass(component.find("modaldialog"), "slds-fade-in-hide");
        $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop"), "slds-backdrop--hide");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop--open");
    }
})