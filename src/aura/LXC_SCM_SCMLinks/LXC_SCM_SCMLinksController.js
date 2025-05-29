({
	navigateToATCChart : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": "/apex/ATC_Chart"
        });
        navEvt.fire();
        var utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
    },
    
    navigateToAgreementLocator : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": "/apex/AgreementLocator"
        });
        navEvt.fire();
        var utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
    },
    
    navigateToContractChart : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": "/apex/ContractChart"
        });
        navEvt.fire();
        var utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
    }
})