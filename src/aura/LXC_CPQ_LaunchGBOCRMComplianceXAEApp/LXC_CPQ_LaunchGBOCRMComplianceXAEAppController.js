({
    
    doInit : function(component, event, helper) {
        var action1 = component.get('c.getAppName');
        action1.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                if(a.getReturnValue().indexOf('CRM Compliance - Contracts') != -1) {
                    component.set("v.isOpen", true);
                    component.set('v.hideContractButton', true);
                }
                if(a.getReturnValue().indexOf('CRM Compliance - Bid History') != -1){
                    component.set("v.isOpen", true);
                    component.set('v.hideBidHistoryButton', true);
                }
                if(a.getReturnValue().indexOf('Master Service Agreements Updates') != -1){
                    component.set("v.isOpen", true);
                    component.set('v.hideMSAButton', true);
                }
            }
        });
        $A.enqueueAction(action1);
    },
    closeModel : function(component, event, helper) {
      component.set("v.isOpen", false);
   },
    LaunchBidHistory : function(component, event, helper) {
         component.set("v.appName", 'CRM Compliance - Bid History');
         helper.LaunchBidHistory(component, event, helper);
    },
    LaunchContracts : function(component, event, helper) {
         component.set("v.appName", 'CRM Compliance - Contracts');
         helper.LaunchContracts(component, event, helper);
    },
    LaunchMSA : function(component, event, helper) {
         component.set("v.appName", 'Master Service Agreements Updates');
         helper.LaunchMSA(component, event, helper);
    }
})