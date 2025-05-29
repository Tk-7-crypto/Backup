({
    handleUploadFinished: function (component, event, helper) {
        component.set('v.showLoading', true);
        var uploadedFiles = event.getParam("files");
        var documentsId = [];
        uploadedFiles.forEach(function callback(file) {
            documentsId.push(file.documentId);
        });
        
        var params = {
            "lstDocumentId": documentsId,
            "parentId": component.get("v.recordId"),
            "isUploadFromAttachment": component.get("v.isUploadFromAttachment"),
            "folderName": component.get("v.folderName")
        };
        helper.callServerAction(component, 'c.uploadFileToSharepoint', params, function (response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                var vx = component.get("v.method");
                $A.enqueueAction(vx);
            }
            else{
                let errors = response.getError();
                let message = '';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                helper.showToast('dismissible', 'error', 'Error', $A.get("$Label.CLM_CL0004_Upload_File_Failed_Please_Try_Later"));
                helper.callServerAction(component, 'c.deleteContentDocument', params, function(response){
                    var state = response.getState();
                    if(state === 'ERROR'){
                        console.error(response.getError());
                    }
                });
                component.set("v.showLoading", false);
            }
        });
    },
})