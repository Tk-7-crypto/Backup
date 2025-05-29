({ 
    getPicklistData :function(component, event){
        var action = component.get("c.getSpecialTerms");
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();  
                component.set("v.specialTermsList", result);
            }
        });
        $A.enqueueAction(action);
    },
    getCustomSettingData : function(component, event) {
        var action = component.get("c.showCustomSettingData"); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue(); 
                component.set("v.customSettingList", result);
            }
        });
        $A.enqueueAction(action);
    }, showToast : function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                'type': type,
                'message': message
            });
            toastEvent.fire();
        }
        else {
            alert(message);
        }
    }
     
})