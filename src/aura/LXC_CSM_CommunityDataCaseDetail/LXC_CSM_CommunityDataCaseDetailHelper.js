({
    saveCase: function (component, event) {
        console.log('save');
        var recordData = component.get("v.recordId");
        var mailCCData = component.get("v.mailCCValue");
        var action = component.get("c.updateMailCCList");
        action.setParams({
            "recordId": recordData,
            "mailCC": mailCCData
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.editMaillCC", "false");
                component.set("v.editMaillCCButton", "true");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log('errors', JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
    }
})