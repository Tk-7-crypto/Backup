({
    handleSubmit:function(component, event, helper) {
        event.preventDefault();
        var action = component.get("c.createAnnouncement");
        var eventFields = event.getParam("fields");
        
        if($A.util.isEmpty(eventFields.Subject__c) || $A.util.isEmpty(eventFields.Description__c)) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "error",
                "message": "Please fill Subject and Description fields."
            });
            toastEvent.fire();
        }
        else {
            if($A.util.isEmpty(eventFields.Partner_type__c) && $A.util.isEmpty(eventFields.Product2ID__c) && $A.util.isEmpty(eventFields.Partner_roles__c) && $A.util.isEmpty(JSON.parse(JSON.stringify(component.get("v.selectedLookUpRecords"))))) {
              var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "type": "error",
                    "message": "Please fill at least 1 filter field."
                });
                toastEvent.fire();
            }
            else {
                if($A.util.isEmpty(eventFields.Product2ID__c)) {
                    var prodId = null;
                }
                else {
                    var prodId = eventFields.Product2ID__c;
                }
                 action.setParams({
                    subject : eventFields.Subject__c,
                    status : 'Draft',
                    description : eventFields.Description__c,
                    parttype : eventFields.Partner_type__c,
                    partRoles : eventFields.Partner_roles__c,
                    productId : prodId,
                    expDate: eventFields.Expiry_Date__c,
                    accs: JSON.parse(JSON.stringify(component.get("v.selectedLookUpRecords"))),
                    recId: component.get("v.recordId")
                });
                action.setCallback(this, function(data) {
                    var state = data.getState();
                    if (state === "SUCCESS") {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": data.getReturnValue(),
                            "slideDevName": "related"
                        });
                        navEvt.fire();
                    }
                    else {
                        var error = JSON.parse(JSON.stringify(data.getError()))[0].message;
                        console.log(JSON.parse(JSON.stringify(data.getError()))[0].message)
                        console.log(JSON.parse(JSON.stringify(data.getError()))[0].message.split("ENTITY_IS_LOCKED").length);
                        if(JSON.parse(JSON.stringify(data.getError()))[0].message.split("ENTITY_IS_LOCKED").length > 1) {
                            error = "An error occurred: One or more specified targeted accounts are locked. Please contact your admin.";
                        }
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "type": "error",
                            "message": error
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    
    onCancel: function(component, event, helper) {
        if(component.get("v.recordId") != null) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "related"
            });
            navEvt.fire();
        }
        else {
            window.open("/Announcement__c/list?filterName=Recent", "_self");
        }
    },
    
    handleLoad: function(component, event, helper) {
        if(component.get("v.recordId") != null) {
            var action = component.get("c.getAccounts");
            action.setParams({
                recId : component.get("v.recordId")
            });
            action.setCallback(this, function(data) {
                var state = data.getState();
                var list = [];
                if (state === "SUCCESS") {
                    for(var i=0; i<data.getReturnValue().length; i++) {
                        list[i] = data.getReturnValue()[i].AccountID__r;
                    }
                    component.set("v.selectedLookUpRecords", list);
                }
            });
            $A.enqueueAction(action);
        }
    }
})