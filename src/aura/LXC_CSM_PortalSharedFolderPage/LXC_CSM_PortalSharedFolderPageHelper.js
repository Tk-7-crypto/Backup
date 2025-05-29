({
    getUserContact: function (component) {
        var action = component.get("c.getUserContact");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contact = response.getReturnValue()[0];
                if (contact) {
                    component.set("v.contact", contact);
                    var mikadoServiceLevel = contact.MikadoServiceLevel__c;
                    var portal_case_type = contact.Portal_Case_Type__c.split(';');
                    if (portal_case_type.indexOf("Technology Solutions") > -1 && mikadoServiceLevel === 'Professional Service') {
                        component.set("v.mikadoReporterFolderVisibily", true);
                    } else {
                        component.set("v.mikadoReporterFolderVisibily", false);
                    }
                }
            } else if (state === "ERROR") {
                console.log("ERROR: " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    }
})