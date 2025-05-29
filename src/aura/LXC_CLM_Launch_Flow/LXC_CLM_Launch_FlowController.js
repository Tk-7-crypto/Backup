({
    doInit : function(component, event, helper) {
        component.set("v.isOpen", true);
        var recId = component.get("v.recordId");
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : recId
            }
        ]; 
        var flow = component.find("flowData");
        flow.startFlow(component.get("v.flowName"), inputVariables);
    },
    
    closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
        window.location = '/lightning/r/Bid_History__c/' + component.get("v.recordId") + '/view';
    }    
})