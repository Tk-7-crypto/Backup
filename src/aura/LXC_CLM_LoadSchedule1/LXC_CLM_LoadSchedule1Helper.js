({
    createAgreementLineItem: function(component, documentId) {
        var helper = this;
        var agreementId = component.get('v.agreementId');
        var action = component.get('c.createAgreementLineItem');
        action.setParams({
            'agreementId': agreementId,
            'contentDocumentId': documentId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var agreementLineItemId = response.getReturnValue();
                if (!agreementLineItemId) {
                    alert("Invalid agreement id '" + agreementId + "' or document id '" + documentId + "' specified");
                    return;
                }
                helper.showToast('success', 'Schedule 1 Upload Successful');
                helper.goToRecord(component, 'Apttus__APTS_Agreement__c', agreementId);
            }
            else {
                alert('Error creating Schedule 1 agreement line item: ' + response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                'type': type,
                'message': message
            });
            toastEvent.fire();
        }
        else {
            alert(message);
        }
    },

    goToRecord : function(component, type, recordId) {
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: type,
                actionName: 'view'
            }
        };
        var navService = component.find("navService");
        navService.navigate(pageReference);
        component.set('v.showSpinner', false);
    }
});