({
    saveData : function(component, correctiveActionWrapperList) {
        var action = component.get("c.save");
        action.setParams({ 
            "correctiveActionWrapperJSON": JSON.stringify(correctiveActionWrapperList)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                              
                this.showToast(component);  
                component.set("v.correctiveActionWrapperList", []);
                this.addRow(component);
                component.set("v.isShowDelete", false);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    addRow: function(component) {
        var correctiveActionWrapperList = component.get("v.correctiveActionWrapperList");
        var caseId = component.get("v.caseId");
        var tabName = component.get("v.tabName");
        var correctiveActionWrapper = {'correctiveAction': {}, 'isShowFieldNameError': false, 'caseId': caseId};
        correctiveActionWrapper.correctiveAction.Case__c = caseId;
        correctiveActionWrapper.correctiveAction.Type__c = tabName;
        correctiveActionWrapperList.push(correctiveActionWrapper);
        component.set("v.correctiveActionWrapperList", correctiveActionWrapperList);
    },
    
    checkValidity: function(component) {
        var correctiveActionWrapperList = component.get("v.correctiveActionWrapperList");
        var isValid = component.find('correctiveform').reduce(function (validSoFar, inputCmp) {
            var inputCmpName = inputCmp.get('v.name');
            var inputCmpValue = inputCmp.get('v.value');
            if(inputCmpName != undefined && inputCmpName == 'correctiveFieldPicklist' &&  
               (inputCmpValue == '' || inputCmpValue == 'Please Specify')) {
                inputCmp.set('v.validity', {valid:false});
                $A.util.addClass(inputCmp, "is-required slds-has-error lightningInput");
            }
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        for(var i = 0; i < correctiveActionWrapperList.length; i++ ){
            if(correctiveActionWrapperList[i].correctiveAction.Corrective_Field_Name__c == '' || 
               correctiveActionWrapperList[i].correctiveAction.Corrective_Field_Name__c == 'Please Specify') {
                correctiveActionWrapperList[i].isShowFieldNameError = true;
            }
        } 
        component.set("v.correctiveActionWrapperList", correctiveActionWrapperList);
        return isValid;
    },
   
    checkDuplicacy : function(component) {
        var correctiveActionWrapperList = component.get("v.correctiveActionWrapperList");
        var isValidFieldNames = true;
        if(correctiveActionWrapperList.length > 1) {
            for(var i = 0; i < correctiveActionWrapperList.length; i++ ){
                for(var j = i+1; j < correctiveActionWrapperList.length; j++) {
                    if(i == j) {
                        break;
                    }
                    else if(correctiveActionWrapperList[i].correctiveAction.Corrective_Field_Name__c == correctiveActionWrapperList[j].correctiveAction.Corrective_Field_Name__c ) {
                        this.showErrorToast(component);
                        isValidFieldNames = false;
                        break;
                    }
                }
            } 
        }
        return isValidFieldNames;
    },
    
    showToast : function(component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Records have been saved successfully.",
            "type": "success"
        });
        toastEvent.fire();
    },

    showErrorToast : function(component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "message": "Corrective Field Names can not be duplicate",
            "type": "error"
        });
        toastEvent.fire();
    },
    
    handleErrors : function(errors) {
        var toastParams = {
            title: "Error",
            message: "Unknown error", 
            type: "error"
        };
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
})