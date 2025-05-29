({
    doInit : function(component, event, helper) {
        var caseRecord = component.get('v.simpleRecord');
        console.log(JSON.stringify(caseRecord));
    },

    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
})