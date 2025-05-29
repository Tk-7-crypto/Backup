({
    doInit : function(component, event, helper) {
        var caseId = component.get("v.recordId");
        component.set("v.caseId", caseId); 
        component.set("v.Spinner", true);
        var picklistWrapper = {'statusValues': [], 'subStatusValues': [], 'countries': [], 'rootCauses': [], 'subType3Values': [], 'queryTypeAreas': [], 'correctiveActions': [], 'resolutionCodes': []};
        component.set("v.picklistWrapper", picklistWrapper);
        helper.checkIfAllFieldsRequired(component);
        helper.checkUserPermissions(component);
        helper.getCaseRecord(component);
        helper.loadPicklistValues(component);
        component.set("v.isMandatory", true);
        component.set("v.cssStyle", "<style>.cuf-scroller-outside {background: rgb(255, 255, 255) !important;}</style>");
    },
    
    onStatusChange : function(component, event, helper) {
        var caseWrapper = component.get("v.caseWrapper");
        var contrFieldValue = caseWrapper.caseRecord.Status;
        if(caseWrapper.caseRecord.SubStatus__c != null && caseWrapper.caseRecord.SubStatus__c != '' && caseWrapper.caseRecord.SubStatus__c != 'Please Specify'){
            component.set("v.caseWrapper.caseRecord.SubStatus__c", '');                        
        }
        var dependentSubstatusValues = component.get("v.dependentSubstatusValues");
        var picklistWrapper = component.get("v.picklistWrapper");
        component.set("v.picklistWrapper.subStatusValues", dependentSubstatusValues[contrFieldValue]);
    },
    
    onQueryTypeChange : function(component, event, helper) {
        helper.onQueryTypeChange(component);
    },
    
    onResolutionCodeChange : function(component, event, helper) {
        helper.onResolutionCodeChange(component);
    },
    
    saveCaseData : function(component, event, helper) {
        component.set("v.Spinner", true);
        var allFieldsRequired = component.get("v.allFieldsRequired");
        var isPicklistValid = true;
        if(allFieldsRequired) {
            isPicklistValid = helper.checkValidityForPicklist(component);
            var isValidCmp = isPicklistValid && helper.checkValidityForInputCmp(component);
            if(isValidCmp) {
                helper.save(component);
            } else {
                var message = 'All Fields are mandatory!!'
                helper.showMessage("Error", message, "error");
            }
        } else {
            var isValidCmp = helper.checkValidityForInputCmp(component);
            if(isValidCmp) {
                var caseWrapper = component.get("v.caseWrapper");
                caseWrapper.caseRecord.Country_of_the_requester2__c = caseWrapper.caseRecord.Country_of_the_requester2__c == 'Please Specify' ? '' : caseWrapper.caseRecord.Country_of_the_requester2__c;
                caseWrapper.resolutionCode = caseWrapper.resolutionCode == 'Please Specify' ? '' : caseWrapper.resolutionCode;
                caseWrapper.correctiveAction = caseWrapper.correctiveAction == 'Please Specify' ? '' : caseWrapper.correctiveAction;
                caseWrapper.rootCause = caseWrapper.rootCause == 'Please Specify' ? '' : caseWrapper.rootCause;
                component.set('v.caseWrapper', caseWrapper);
                helper.save(component);
            }
        }
        component.set("v.Spinner", false);
    },

    onCheckboxChange: function(component, event, helper) {
        var forceCSAT = event.getParam('checked');
        component.set("v.caseWrapper.caseRecord.Force_CSAT_Email_Survey__c", forceCSAT); 
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component, event, helper) {
        component.set("v.Spinner", false);
    },
	
})
