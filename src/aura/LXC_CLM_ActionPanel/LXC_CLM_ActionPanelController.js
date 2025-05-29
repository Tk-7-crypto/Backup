({
    doInit: function(component, event) {
    },

	closeFlowModal : function(component, event) {
        component.set("v.isFlowOpen", false);
	},

    showFlow: function(component, event, helper) {
        component.set("v.isFlowOpen", true);
        helper.startFlow(component, event);
	},
    
    statusChange: function(component, event) {
        if (event.getParam('status') === "FINISHED") {
            component.set("v.isFlowOpen", false);
        }
    }
})