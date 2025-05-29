({
    doInit: function(component, event, helper) {
        helper.getCaseComment(component);
    },

    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        console.log(eventParams.changeType);
        if(eventParams.changeType === "LOADED") {
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
            $A.get('e.force:refreshView').fire();

        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
        component.set("v.isLoading", false);
    },

    handleSave: function(component, event, helper) {

        if(component.find("commentBody").get("v.value") != "") {
            component.set("v.isLoading", true);
            helper.insertCaseComment(component);
            var record = component.get("v.simpleRecord");
            if(record.Status === "Resolved with Customer"){
                if(component.find("autoCloseCaseCheck").getElement().checked){
                    component.set("v.simpleRecord.Status", "Closed");
                    component.find("recordLoader").saveRecord(function(saveResult) {
                        console.log(JSON.stringify(saveResult));
                        if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        } else if (saveResult.state === "INCOMPLETE") {
                        } else if (saveResult.state === "ERROR") {
                        } else {
                        }
                        
                    });
                }
            }
        }
    },



})