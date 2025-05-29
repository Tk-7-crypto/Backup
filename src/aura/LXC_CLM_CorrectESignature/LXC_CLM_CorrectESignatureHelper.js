({
    loadRecipients: function (component) {
        var action = component.get("c.loadDataForCorrectRecipients");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            "agreementId": rId
        });
        // Register the callback function
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                //alert('success');
                component.set('v.recipientList', response.getReturnValue().recipientList);

            } else if (response.getState() === "ERROR") {
                $A.log("Errors", response.getError());
            }
        });
        // Invoke the service
        $A.enqueueAction(action);
    },

    searchRecords: function (component, searchString) {
        var action = component.get("c.getRecords");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            "searchString": searchString,
            "objectApiName": component.get("v.objectApiName"),
            "idFieldApiName": component.get("v.idFieldApiName"),
            "valueFieldApiName": component.get("v.valueFieldApiName"),
            "extendedWhereClause": component.get("v.extendedWhereClause"),
            "maxRecords": component.get("v.maxRecords"),
            "agrId": rId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const serverResult = response.getReturnValue();
                const results = [];
                serverResult.forEach(element => {
                    const result = {
                        id: element[component.get("v.idFieldApiName")],
                        value: element[component.get("v.valueFieldApiName")],
                        email: element['Email__c'],
                        Name: element['Name__c'],
                        Type: element['Type__c']
                    };

                    results.push(result);
                });
                component.set("v.results", results);
                if (serverResult.length > 0) {
                    component.set("v.openDropDown", true);
                }

            } else {
                var toastEvent = $A.get("e.force:showToast");
                if (toastEvent) {
                    toastEvent.setParams({
                        "title": "ERROR",
                        "type": "error",
                        "message": "Something went wrong!! Check server logs!!"
                    });
                    toastEvent.fire();
                }
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    addRowForRecepient: function (component, event, helper) {
        //get the account List from component
        var recipientList = component.get("v.recipientList");
        component.set("v.newRecipientId", recipientList.length + 1);
        var newRecipientId = component.get("v.newRecipientId");
        //Add New Account Record
        recipientList.push({
            'recipientId': newRecipientId,
            'signingOrder': '',
            'recipientType': 'Need to Sign',
            'name': '',
            'email': '',
            'privateMessage': '',
            'disabled': 'false'

        });
        component.set("v.recipientList", recipientList);
    },

    getSendAsEmail: function (component) {
        var action = component.get("c.checkIfAccountDetailsAvailable");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            "agreementId": rId
        });
        // Register the callback function
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var eSResult = response.getReturnValue();
                component.set("v.sendAsUserEmail", eSResult);

            } else if (response.getState() === "ERROR") {
                $A.log("Errors", response.getError());
            }
        });
        // Invoke the service
        $A.enqueueAction(action);
    },

    updateEnvelope: function (component, event, helper) {
        var action = component.get("c.updateCorrectESignature");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        var email = component.get("v.sendAsUserEmail");
        action.setParams({
            "agreementId": rId,
            recipientsJson: JSON.stringify(component.get("v.recipientList")),
            sendAsUserEmail: component.get("v.sendAsUserEmail")
        });
        // Register the callback function
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var eSResult = response.getReturnValue();
                if (eSResult.status == "SUCCESS") {
                    var navSer = component.find("navigate");
                    var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));

                    window.open('/lightning/r/IQVIA_Agreement__c/' + rId + '/view', '_top');
                }

            } else if (response.getState() === "ERROR") {
                $A.log("Errors", response.getError());
            }
        });
        // Invoke the service
        $A.enqueueAction(action);
    },
})