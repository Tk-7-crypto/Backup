({
    doInit : function(component, event) { 
        var cancelUpdate = false;
        component.set('v.cancelAll', cancelUpdate);
        var editContract = false;
        component.set('v.editContactInfo', editContract);
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            if(sParameterName[0] == 'cid')
            component.set('v.contactId', sParameterName[1]);
			console.log('sParameterName--'+sParameterName);
            if(sParameterName[0] == 'type')
            component.set('v.caseRecordType', sParameterName[1]);
            if(sParameterName[0] == 'caId')
                component.set('v.caseId', sParameterName[1]);
        }
        var action = component.get('c.selectContactInfo');  
        action.setParams({
			contactId : component.get("v.contactId"),
            portalType : component.get("v.caseRecordType")
        });
      action.setCallback(this, function(response) {
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set('v.contactRecord', response.getReturnValue());
        }  else if(state === "ERROR"){
                var errors = response.getError();
                var result = true;
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
            }
      });
        $A.enqueueAction(action);   
	},
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    goToExternalSite: function(component, event, helper) {
        var action = component.get("c.getCSMSetting"); 
        action.setCallback(this, function(response){
        if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
            window.location.href = response.getReturnValue();
        }
    });
    $A.enqueueAction(action);   
    }
})