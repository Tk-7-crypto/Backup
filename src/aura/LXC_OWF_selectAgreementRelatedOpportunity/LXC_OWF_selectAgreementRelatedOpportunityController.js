({
    doInit : function(component, event, helper) {
        helper.getCLMRecordTypeIdsOfAvailableUsers(component, event);
        helper.getCLMRecordTypeIdsForMVP(component, event);
    },
    onRender: function(component,event, helper) {
        console.log('Helper in Rerender');
        helper.redirectUser(component, event);
    },
    closeFlowModal: function(component, event, helper) {
        component.set("v.isOpen", false);
        var base64Context = component.get("v.pageReference").state.inContextOfRef;
        if(base64Context != null && base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        var contextRefObject = addressableContext.attributes.objectApiName;
        var contextRefRecordId = null;       
        if(contextRefObject != null && contextRefObject != 'undefined' && contextRefObject == 'Account') {  
            contextRefRecordId = addressableContext.attributes.recordId;
        }
        if(contextRefRecordId != null) {
            window.location = '/lightning/r/Account/' + contextRefRecordId + '/view';
        }
        else {
            window.location = '/lightning/o/Apttus__APTS_Agreement__c/list';
        } 
    }    
})