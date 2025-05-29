({
    doInit: function (component, event, helper) {
        var caseRecord = component.get('v.simpleRecord');
        component.set("v.mailCCValue", caseRecord.Mail_CC_List__c);
    },
    saveMailCC: function (component, event, helper) {
        var recordData = component.get("v.recordId");
        var emailFieldValue = component.get("v.mailCCValue");
        var isValidEmail = true;
        var emailField = component.find("leadEMail");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (!$A.util.isEmpty(emailFieldValue)) {
            var storevalue = 0;
            for (storevalue = 0; storevalue < emailFieldValue.split(';').length; storevalue++) {
                var mail = emailFieldValue.split(';')[storevalue];
                if (mail.match(regExpEmailformat)) {
                    isValidEmail = true;

                } else {
                    isValidEmail = false;
                    component.set("v.errorMessageCheck", "true");
                    component.set("v.errorMessage", "Please Enter a Valid Email Address");
                    $A.util.addClass(emailField, 'slds-has-error');
                    emailField.set("v.errors", [{ message: "Please Enter a Valid Email Address" }]);
                }
            }
        }

        // if Email Address is valid then execute code     
        if (isValidEmail) {
            helper.saveCase(component, event);
        }

    },
    handleEdit: function (component, event, helper) {
        component.set("v.editMaillCC", "true");
        component.set("v.editMaillCCButton", "false");
        var mailCCValue = component.get("v.simpleRecord.Mail_CC_List__c");
        component.set("v.mailCCValue", mailCCValue);
    },
    showSpinner: function (component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true);
    },

    // this function automatic call by aura:doneWaiting event 
    hideSpinner: function (component, event, helper) {
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
})