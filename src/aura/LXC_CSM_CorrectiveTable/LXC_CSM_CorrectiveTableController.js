({
    doInit : function(component, event, helper) {
        helper.addRow(component);
    },
    
    addRow: function(component, event, helper) {
        var correctiveActionWrapperList = component.get("v.correctiveActionWrapperList");
        var maxRows = component.get("v.maxRows");
        if(correctiveActionWrapperList.length < maxRows) {
            helper.addRow(component);
        }
        component.set("v.isShowDelete", true); 
    },
    
    handleChange: function(component, event, helper) {
        var selectedFieldNames = new Set();
        var selectedFieldName = event.getSource().get("v.value");
        var correctiveActionWrapperList = component.get("v.correctiveActionWrapperList");
        for(var i = 0; i < correctiveActionWrapperList.length; i++ ){
            if(correctiveActionWrapperList[i].correctiveAction.Corrective_Field_Name__c != '' || 
               correctiveActionWrapperList[i].correctiveAction.Corrective_Field_Name__c != 'Please Specify') {
                correctiveActionWrapperList[i].isShowFieldNameError = false;
                var isValid = component.find('correctiveform').reduce(function (validSoFar, inputCmp) {
                    var inputCmpName = inputCmp.get('v.name');
                    if(inputCmpName != undefined && inputCmpName == 'correctiveFieldPicklist') {
                        inputCmp.set('v.validity', {valid:true});
                        $A.util.removeClass(inputCmp, "is-required slds-has-error lightningInput");
                    }
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
            } 
        } 
        component.set("v.correctiveActionWrapperList", correctiveActionWrapperList);
    },
    
    removeRow: function(component, event, helper) {
        var correctiveActionWrapperList = component.get("v.correctiveActionWrapperList");
        if(correctiveActionWrapperList.length > 1) {
            var selectedItem = event.currentTarget;
            var index = selectedItem.dataset.record;
            correctiveActionWrapperList.splice(index, 1);
            component.set("v.correctiveActionWrapperList", correctiveActionWrapperList);   
            var isShowDelete = correctiveActionWrapperList.length == 1 ? false : true;
            component.set("v.isShowDelete", isShowDelete);
        }
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component, event, helper) {
        component.set("v.Spinner", false);
    },
    
    saveCorrectiveActions : function(component, event, helper) {
        var isValidCmp = helper.checkValidity(component) && helper.checkDuplicacy(component);
        var correctiveActionWrapperList = component.get("v.correctiveActionWrapperList");
        if(isValidCmp) {
            component.set("v.Spinner", true);
            helper.saveData(component, correctiveActionWrapperList);
            component.set("v.Spinner", false);
        }
    }
})