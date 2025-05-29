({
    sendHelper: function(component, emailDetailObj) {
        var action = component.get("c.sendMailMethod");
        action.setParams({
            'emailObjJSON': emailDetailObj
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var storeResponse = response.getReturnValue();
                component.set("v.showPopUp", false);
                component.set("v.showSpinner", false);
                var parentPopUp = component.get("v.parent");
                parentPopUp.set("v.isFunctionalReview", false);
                parentPopUp.set("v.isEmail", false);
        		parentPopUp.set("v.isSignOffEmail", false);
                $A.get('e.force:refreshView').fire();
                this.showToast('', 'Email Sent successfully!', 'success'); 
            } else if (state === "ERROR") {
                var errors = response.getError();
                this.showToast('Error!', errors, 'error');
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    collectEmailIds: function(component, emailList) {
        var emailIds = '';
        for (var emailComp in emailList) {
            if (emailIds == '') {
                emailIds = emailList[emailComp].searchField;
            } else {
                emailIds = emailIds + ',' + emailList[emailComp].searchField;
            }
        }
        return emailIds;
    },
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
})