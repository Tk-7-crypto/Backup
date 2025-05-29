({
    doInit : function(component, event) { 
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            if(sParameterName[0] == 'cid')
            component.set('v.contactId', sParameterName[1]);
            if(sParameterName[0] == 'caseId')
                component.set('v.caseRecordType', sParameterName[1]);
        }
        var action = component.get('c.updateContact');  
        action.setParams({
            expid : component.get("v.contactId"),
            caseid : component.get("v.caseRecordType")
        });
        action.setCallback(this, function(response) {
        var state = response.getState();
            if(state === "ERROR"){
                var errors = response.getError();
                var result = true;
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
            }
      });
        $A.enqueueAction(action);   
	},
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    }
})