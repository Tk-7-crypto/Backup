({
    getMikadoFiles : function(component, event, helper) {
        helper.getContentFolderMember(component);
    },

    handleUploadFinished: function (component, event,helper) {
        var parentContentFolderId = component.get("v.parentContentFolderId");
        var uploadedFiles = event.getParam("files");
        for (var i=0; i<uploadedFiles.length; i++){
            helper.updateContentFolderMember(component,parentContentFolderId, uploadedFiles[i].documentId);
        }
        helper.getContentFolderMember(component);
    },

    sortBy:function(component, event,helper){
        var files = component.get("v.files");
        if (event.currentTarget.id == "sortByName"){
            if ( event.currentTarget.dataset.sort == 'desc' ){
                files.sort(function(a,b) {return (a.ChildRecord.Title.toLowerCase() < b.ChildRecord.Title.toLowerCase()) ? 1 : ((b.ChildRecord.Title.toLowerCase() < a.ChildRecord.Title.toLowerCase()) ? -1 : 0);} ); 
                event.currentTarget.dataset.sort="asc"
            }else{               
                files.sort(function(a,b) {return (a.ChildRecord.Title.toLowerCase() > b.ChildRecord.Title.toLowerCase()) ? 1 : ((b.ChildRecord.Title.toLowerCase() > a.ChildRecord.Title.toLowerCase()) ? -1 : 0);} ); 
                event.currentTarget.dataset.sort="desc"
            }
        }else{
            if ( event.currentTarget.dataset.sort == 'desc' ){
                files.sort(function(a,b) {return (a.ChildRecord.LastModifiedDate < b.ChildRecord.LastModifiedDate) ? 1 : ((b.ChildRecord.LastModifiedDate < a.ChildRecord.LastModifiedDate) ? -1 : 0);} ); 
                event.currentTarget.dataset.sort="asc"
            }else{
                files.sort(function(a,b) {return (a.ChildRecord.LastModifiedDate > b.ChildRecord.LastModifiedDate) ? 1 : ((b.ChildRecord.LastModifiedDate > a.ChildRecord.LastModifiedDate) ? -1 : 0);} ); 
                event.currentTarget.dataset.sort="desc"
            }
        }
        component.set("v.files", files);
    },

    openSingleFile: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var childRecordId = selectedItem.dataset.value;
        $A.get('e.lightning:openFiles').fire({
            recordIds: [childRecordId]
        });
    },

    deleteFile: function(component, event, helper) {
        var r = confirm("Are you sure you want to delete this file ?" );
        var selectedItem = event.currentTarget;
        var childRecordId = selectedItem.dataset.value;
        if (r == true) {
            helper.deleteContentDocumentById(component, childRecordId );
        } 
    }



})