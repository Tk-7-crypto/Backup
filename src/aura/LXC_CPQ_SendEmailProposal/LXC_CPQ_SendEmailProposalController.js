({
    doInit: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var action = component.get("c.getEmailTemplate");
        var header = component.get("v.header");
        var emailFor = (header == 'Challenge Review/Strategy Approval Request' ? 'Challenge Review' : '');
        if (header == 'Final Sign Off Request') {
            emailFor = 'Sign Off';
        }
        action.setParams({
            recordId: component.get("v.recordId"),
            emailFor: emailFor
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = [];
                storeResponse = response.getReturnValue();
                component.set("v.emailDetailObj", storeResponse);
                component.set("v.showSpinner", false);      
                component.set("v.showPopUp", true);  
            }
        });
        $A.enqueueAction(action);
    },
    sendMail: function(component, event, helper) {
        var getEmail = helper.collectEmailIds(component, component.get("v.emailList"));
        component.set("v.showSpinner", true);
        
        if ($A.util.isEmpty(getEmail)) {
            component.set("v.showSpinner", false);
            var childComp = component.find('emailAddress');
        	childComp.showError("Enter valid email address and select a Contact");
        } else {
            var emailDetailObj = component.get("v.emailDetailObj");
            emailDetailObj.toEmailIds = getEmail;
            emailDetailObj.ccEmailIds = helper.collectEmailIds(component, component.get("v.CcemailList"));
            emailDetailObj.bccEmailIds = helper.collectEmailIds(component, component.get("v.BccemailList"));
            emailDetailObj = JSON.stringify(emailDetailObj);
            helper.sendHelper(component, emailDetailObj);
        }
    },
    closeMessage: function(component, event, helper) {
        component.set("v.email", null);
        component.set("v.subject", null);
        component.set("v.body", null);
        component.set("v.showPopUp", false);
    },
    ClosePopUp: function(component, event, helper) {
        component.set("v.showPopUp", false);
        var parentPopUp = component.get("v.parent");
        parentPopUp.set("v.isFunctionalReview", false);
        parentPopUp.set("v.isEmail", false);
        parentPopUp.set("v.isSignOffEmail", false);
    },
    handleUploadFinished: function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        var attachmentList = component.get("v.attachmentList");
        attachmentList.push({
            value: documentId,
            label: fileName
        });
        component.set("v.attachmentList", attachmentList);
        var attachmentId = component.get("v.emailDetailObj.attachmentIds");
        attachmentId.push(documentId);
        component.set("v.emailDetailObj.attachmentIds", attachmentId);
        component.set("v.showFiles", true);
    },
    deleteFile: function(component, event, helper) {
        var attachmentList = component.get("v.attachmentList");
        var index = event.target.dataset.index;
        attachmentList.splice(index, 1);
        component.set("v.attachmentList", attachmentList);
        var action = component.get("c.deleteAttachments");
        action.setParams({
            'attachmentIds': event.target.id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {}
        });
        $A.enqueueAction(action);
    },
    removeFile: function(component, event, helper) {
        var attachmentList = component.get("v.attachmentList");
        var index = event.target.dataset.index;
        attachmentList.splice(index, 1);
        component.set("v.attachmentList", attachmentList);
        component.set("v.isUPTFileRemoved", true);
    },
})