({
    doInit: function(component, event, helper) {
        var agreementId = component.get("v.pageReference").state.c__agreementId;
        component.set("v.agreementId", agreementId);
        component.set('v.showSpinner', false);
    },

    handleUploadFinished: function (component, event, helper) {
        // Get the uploaded file
        var uploadedFile = event.getParams().files[0];
        component.set('v.showSpinner', true);
        helper.createAgreementLineItem(component, uploadedFile.documentId);
    },

    handleCancel: function (component, event, helper) {
        window.history.back();
    }
});