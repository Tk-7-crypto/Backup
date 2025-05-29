({
    doInit: function (component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var recordId = pageReference.state.c__recordId;
        component.set("v.recordId", recordId);
        helper.loadRecipients(component);
        helper.getSendAsEmail(component);

    },

    searchHandler: function (component, event, helper) {
        const searchString = event.target.value;
        if (searchString.length >= 2) {
            //Ensure that not many function execution happens if user keeps typing
            if (component.get("v.inputSearchFunction")) {
                clearTimeout(component.get("v.inputSearchFunction"));
            }
            var inputTimer = setTimeout($A.getCallback(function () {
                        helper.searchRecords(component, searchString);
                    }), 1000);
            component.set("v.inputSearchFunction", inputTimer);
        } else {
            component.set("v.results", []);
            component.set("v.openDropDown", false);
        }
    },

    optionClickHandler: function (component, event, helper) {
        const selectedId = event.target.closest('li').dataset.id;
        const selectedValue = event.target.closest('li').dataset.value;
        component.set("v.inputValue", selectedValue);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedId);
    },

    addToListHandler: function (component, event, helper) {
        helper.addRowForRecepient(component, event, helper);
        var contacts = component.get("v.results");
        var selectedContactId = component.get("v.selectedOption");
        var recipientList = component.get("v.recipientList");
        contacts.forEach(element => {
            if (element['id'] === selectedContactId) {
                recipientList.every(elementR => {
                    if (elementR['name'] == '' && elementR['email'] == '') {
                        elementR['name'] = element['Name'];
                        elementR['email'] = element['email'];
                        elementR['userType'] = element['Type'];
                        elementR['recipientType'] = 'Signer';
                        return false;
                    } else {
                        return true;
                    }
                });
            }
        });
        component.set("v.recipientList", recipientList);
        component.set("v.inputValue", "");
        component.set("v.results", []);
        component.set("v.selectedOption", "");
    },

    goto0: function (component, event, helper) {
        var navSer = component.find("navigate");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        window.open('/lightning/r/Apttus__APTS_Agreement__c/' + rId + '/view', '_top');

    },

    updateEnvelope: function (component, event, helper) {
        var isValid = true;
        var availableRoutingNumbers = [];
        var missingRoutingNumber = [];
        var recipientList = component.get("v.recipientList");
        if (recipientList.length > 0) {
            for (var i = 0; i < recipientList.length; i++) {
                if (recipientList[i].signingOrder == '' || recipientList[i].signingOrder !=Math.floor(recipientList[i].signingOrder) || recipientList[i].name == '' || recipientList[i].email == '' || recipientList[i].signingOrder<1 ) {
                    isValid = false;
                } else {
                    availableRoutingNumbers.push(parseInt(recipientList[i].signingOrder));
                }
            }
            const min = 1;
            const max = Math.max(...availableRoutingNumbers);
            for (let i = min; i <= max; i++) {
                if (!availableRoutingNumbers.includes(i)) {
                    missingRoutingNumber.push(i);
                }
            }
            if (isValid === false) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": "Input values are invalid for one or more recipient(s). Please fill and try again."
                });
                toastEvent.fire();
            } else if (missingRoutingNumber.length > 0) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": "Assigned routing orders doesn't match with number of recipients. Please validate and try again."
                });
                toastEvent.fire();
            } else {
                
				helper.updateEnvelope(component, event, helper);
            }
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "Error",
                "mode": 'dismissible',
                "message": "Please add atleast one recipient."
            });
            toastEvent.fire();
        }
    }
})