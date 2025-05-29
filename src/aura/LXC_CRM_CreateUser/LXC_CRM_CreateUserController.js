({
	doInit : function(component, event, helper) {
		component.set("v.isLDSVisible",true);
	},
    closeModal : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
})