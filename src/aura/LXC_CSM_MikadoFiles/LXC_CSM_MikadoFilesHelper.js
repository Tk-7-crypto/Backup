({
    getContentFolderMember: function(component){
        component.set("v.isLoading", true);
        var action = component.get("c.getFiles");
        action.setParams({
            "csmFolderId": component.get("v.csmFolderId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var files = response.getReturnValue();
                files.sort(function(a,b) {return (a.ChildRecord.LastModifiedDate < b.ChildRecord.LastModifiedDate) ? 1 : ((b.ChildRecord.LastModifiedDate < a.ChildRecord.LastModifiedDate) ? -1 : 0);} );
                component.set("v.files",files);
            }
            else if (state === "ERROR") {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
        
    },

    updateContentFolderMember: function(component,parentContentFolderId,childRecordId){
        var action = component.get("c.updateContentFolderMember");
        action.setParams({
            "parentContentFolderId": parentContentFolderId,
            "childRecordId": childRecordId,
            "csmFolderId": component.get("v.csmFolderId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "ERROR") {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    deleteContentDocumentById : function(component,contentDocumentId){
        var action = component.get("c.deleteContentDocumentById");
        action.setParams({
            "contentDocumentId": contentDocumentId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type":"SUCCESS",
                    "message": "File was deleted."
                });
                
                this.getContentFolderMember(component);
                resultsToast.fire();
            }else if (state === "ERROR") {
                if(response.getError()[0].pageErrors[0].statusCode==="INSUFFICIENT_ACCESS_OR_READONLY"){
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type":"ERROR",
                        "title": " Action Denied",
                        "message": "You are not allowed to delete this file"
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    resultsToast.fire();
                }else {
                    console.log("ERROR " + JSON.stringify(response.getError()));
                }
            }
        });
        $A.enqueueAction(action);
    },
})