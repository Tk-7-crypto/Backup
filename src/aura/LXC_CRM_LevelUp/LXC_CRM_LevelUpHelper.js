({
    getLevelFields : function(cmp, event, helper) {
        var action = cmp.get("c.getLevelProgression");
        action.setParams({
            recordId: cmp.get("v.recordId"),
            cmpObject: cmp.get("v.cmpObject"),
            maxLevel: cmp.get("v.maxLevel")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var errors = [];
            if(state === "SUCCESS"){
                cmp.set("v.currentLevelFields", response.getReturnValue());
                var currentFields = cmp.get("v.currentLevelFields");
                var maxLevel = cmp.get("v.maxLevel");
                
                if(Object.keys(currentFields).length == 0){
                    cmp.set("v.fieldsAvailable", false);
                    cmp.set("v.showSpinner", false);
                }
                else if(Object.keys(currentFields).length > 0 && currentFields[0].Level != maxLevel){
                    cmp.set("v.fieldsAvailable", true);
                    cmp.set("v.finalLevel", false);
                    cmp.set("v.currentStep", currentFields[0].Level.toString());
                    cmp.set("v.nextStep", currentFields[0].Level + 1);
                }
                else{
                    cmp.set("v.finalLevel", true);
                    cmp.set("v.showSpinner", false);
                }
            }
            else if(state === "ERROR"){
                this.showToast(
                    'error',
                    'Error!',
                    'There was an error loading the ' + cmp.get("v.cmpTitle") + ' component.'
                );
                errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(tType, tTitle, tMessage){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": tType,
            "title": tTitle,
            "message": tMessage,
            "duration": 10000
        });
        toastEvent.fire();
	}
})