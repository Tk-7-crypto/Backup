({
    getAllDocuments: function (component) {
        var action = component.get("c.getAllDocuments");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            "agreementId": rId
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && response.getReturnValue() != '') {
                var selectedRowsList = component.get("v.selectedRowsList");
                var rids = response.getReturnValue()[0].attId;
                selectedRowsList.push(response.getReturnValue()[0].attId);
                component.set('v.selectedRowsList', selectedRowsList);
                component.set("v.selectedAttachments", selectedRowsList);
                component.set('v.documentSize', response.getReturnValue()[0].bodyLength.replace(' kb', ''));
                component.set('v.lstDocuments', response.getReturnValue());
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": "There is an Error in Finding the documents "+ JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getAgreementContacts: function (component) {
        var action = component.get("c.getAgreementContacts");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            agrId: rId
        });
        action.setCallback(this, function (response) {
            var docuSignFlag = false;
            if (response.getState() === "SUCCESS") {
                var contacts = response.getReturnValue();
                if(contacts.length > 0) {
                    const results = [];
                    var recipientList = component.get("v.recipientList");
                    var i = 1;
                    contacts.forEach(element => {
                        if (element['DocuSign_Recipient__c'])
                            docuSignFlag = true;
                    });
                    if (docuSignFlag) {
                        contacts.forEach(element => {
                            if (element['DocuSign_Recipient__c']) { 
                                var recipientType = element['Role__c'] != '' && element['Role__c'] != undefined && element['Role__c'].includes('Receive a Copy') ? 'Carbon copy':'Signer'; 
                                recipientList.push({
                                    'recipientId': '', 
                                    'signingOrder': i,
                                    'recipientType': recipientType,
                                    'name': element['Contact__r'].FirstName + ' ' + element['Contact__r'].LastName,
                                    'email': element['Email__c'],
                                    'privateMessage': element['Job_Title__c'],
                                    'disabled': 'false',
                                    'userType': element['Type__c']
                                });
                                i++ 
                            }
                        });     
                    }
                    else {
                        var toastEvent = $A.get("e.force:showToast");
                 		toastEvent.setParams({
                            "title": "Error!",
                            "type": "Error",
                            "mode": 'dismissible',
                            "message": 'Agreement Contact(s) are not marked as DocuSign Recipient. Please update Agreement Contact and mark DocuSign Recipient.'
                        });
                        toastEvent.fire();
                        component.set("v.loadScreen", false);                
                        const myTimeout = setTimeout(goToAgreement, 3000);
                        function goToAgreement() {
                            var navSer = component.find("navigate");
                            var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
                            window.open('/lightning/r/Apttus__APTS_Agreement__c/' + rId + '/view', '_top');
                        }
                    }
                    if (contacts[0].Agreement__r.Execution_Order__c != undefined && (contacts[0].Agreement__r.Execution_Order__c == "Account Only" || contacts[0].Agreement__r.Execution_Order__c == "Legal Entities Only")) {
                        component.set("v.executionOrderCheck", true);
                    } 
                    component.set("v.executionOrder", contacts[0].Agreement__r.Execution_Order__c);
                    component.set("v.recipientList", recipientList);
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "Error",
                        "mode": 'dismissible',
                        "message": 'There are no valid Agreement Contacts available. Please Create and Try Again'
                    });
                    toastEvent.fire();
                    component.set("v.loadScreen", false);                
                    const myTimeout = setTimeout(goToAgreement, 3000);
                    function goToAgreement() {
                        var navSer = component.find("navigate");
                        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
                        window.open('/lightning/r/Apttus__APTS_Agreement__c/' + rId + '/view', '_top');
                    }
                }
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getEmailTemplateBody: function (component) {
        var action = component.get("c.getEmailTemplateExecutedBody");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            agreementId: rId,
            emailTemplateName: component.get("v.templateName"),
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var rv = response.getReturnValue();
                component.set('v.emailSubject', rv.subject);
                component.set('v.emailBlurb', rv.body);
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    sendForESignature: function (component, helper) {
        component.set("v.loaded", true);
        var csfValue = component.get("v.csfOption");
        var action = component.get("c.processESignature");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            selectedAttJSON: JSON.stringify(component.get("v.selectedAttachments")),
            selectedSignersJSON: JSON.stringify(component.get("v.recipientList")),
            emailSubject: component.get("v.emailSubject"),
            emailBlurb: component.get("v.emailBlurb"),
            agreementId: rId,
            reminderAndExp: JSON.stringify(component.get("v.reminderAndExp")),
            sendAsUserEmail: component.get("v.sendAsUserEmail")
        });
        action.setCallback(this, function (response) {
            var eSResult = response.getReturnValue();
            if (eSResult.status == 'SUCCESS') {
                component.set("v.hasError", false);
                component.set("v.errorList", '');
                component.set('v.batchId', eSResult.batchId);
                component.set("v.currentProgressStep", "s5");
                component.set("v.showPage1", false);
                component.set("v.checkUserPage", false);
                component.set("v.showPage2", false);
                component.set("v.showPage3", false);
                component.set("v.showPage4", false);
                component.set("v.showPage5", true);
                component.set("v.loaded", false);
                helper.getBatchStatus(component, helper);
            } else {
                component.set("v.loaded", false);
                component.set("v.hasError", true);
                component.set("v.errorList", eSResult.message);
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    previewEnv: function (component, helper) {
        var csfValue = component.get("v.csfOption");
        var action = component.get("c.previewEnvelopeWithRecipents");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            selectedAttJSON: JSON.stringify(component.get("v.selectedAttachments")),
            selectedSignersJSON: JSON.stringify(component.get("v.recipientList")),
            emailSubject: component.get("v.emailSubject"),
            emailBlurb: component.get("v.emailBlurb"),
            agreementId: rId,
            reminderAndExp: JSON.stringify(component.get("v.reminderAndExp")),
            sendAsUserEmail: component.get("v.sendAsUserEmail")
        });
        action.setCallback(this, function (response) {
            var eSResult = response.getReturnValue();
            if (eSResult.status == 'SUCCESS') {
                component.set("v.hasError", false);
                component.set("v.errorList", '');
                component.set('v.batchId', eSResult.batchId);
                component.set("v.currentProgressStep", "s4");
                component.set("v.showPage1", false);
                component.set("v.checkUserPage", false);
                component.set("v.showPage2", false);
                component.set("v.showPage3", false);
                component.set("v.showPage4", true);
                component.set("v.showPage5", false);
                helper.getPreviewBatchStatus(component, helper);
            } else {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'sticky',
                    "message": $A.get("$Label.c.CLM_CL00019_DOCUSIGN_FILE_SIZE_EXCEEDED_ERROR")
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    finalizedInDocuSign: function (component, helper) {
        component.set("v.loaded", true);
        var action = component.get("c.processFinalizeInDocuSign");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            selectedAttJSON: JSON.stringify(component.get("v.selectedAttachments")),
            selectedSignersJSON: JSON.stringify(component.get("v.recipientList")),
            emailSubject: component.get("v.emailSubject"),
            emailBlurb: component.get("v.emailBlurb"),
            agreementId: rId,
            reminderAndExp: JSON.stringify(component.get("v.reminderAndExp")),
            sendAsUserEmail: component.get("v.sendAsUserEmail")
        });
        action.setCallback(this, function (response) {
            var eSResult = response.getReturnValue();
            if (eSResult.status == 'SUCCESS') {
                component.set("v.hasError", false);
                component.set("v.errorList", '');
                component.set('v.docuSignEnvelopeId', eSResult.batchId);
                helper.getUrlForTheFinalizeInDocuSign(component);
                component.set("v.loaded", false);
            } else {
                if(eSResult.message.includes("AUTHORIZATION_INVALID_TOKEN")) {
                    component.set("v.loaded", false);
                    var errors = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "Error",
                        "mode": 'sticky',
                        "message": $A.get("$Label.c.CLM_CL00020_DOCUSIGN_EMAIL_INCORRECT") + " " + component.get("v.sendAsUserEmail")
                    });
                    toastEvent.fire();
                    $A.log("Errors", response.getError());
                }
                else {
                    component.set("v.loaded", false);
                    var errors = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "Error",
                        "mode": 'sticky',
                        "message": $A.get("$Label.c.CLM_CL00019_DOCUSIGN_FILE_SIZE_EXCEEDED_ERROR") + '\n' + eSResult.message
                    });
                    toastEvent.fire();
                    $A.log("Errors", response.getError());
                }
            }
        });
        $A.enqueueAction(action);
    },

    updateDocuSignEnvelope: function (component, event, helper) {
        component.set("v.loaded", true);
        var action = component.get("c.updateDocuSignEnvelope");
        action.setParams({
            envelopeId: component.get("v.envId")
        });
        action.setCallback(this, function (response) {
            var eSResult = response.getReturnValue();
            if (eSResult.status == 'SUCCESS') {
                component.set("v.hasError", false);
                component.set("v.errorList", '');
                window.open('/lightning/r/Apttus__APTS_Agreement__c/' + eSResult.batchId + '/view', '_top');
            } else {
                component.set("v.loaded", false);
                component.set("v.hasError", true);
                component.set("v.errorList", eSResult.message);
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getUrlForTheFinalizeInDocuSign: function (component) {
        var action = component.get("c.getUrlForFinalizeInDocuSign");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            envelopeId: component.get("v.docuSignEnvelopeId"),
            agreementId: rId,
            sendAsUserEmail: component.get("v.sendAsUserEmail"),
            docuSignAccId: component.get("v.docuSignAccId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var eSResult = response.getReturnValue();
                if (eSResult.status == 'SUCCESS') {
                    component.set("v.hasError", false);
                    component.set("v.errorList", '');
                    window.open(eSResult.batchId, '_blank');
                    window.open('/lightning/r/Apttus__APTS_Agreement__c/' + rId + '/view', '_top');
                } else {
                    component.set("v.loaded", false);
                    component.set("v.hasError", true);
                    component.set("v.errorList", eSResult.message);
                }
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getReminderAndExpiration: function (component) {
        var action = component.get("c.getReminderAndExpiration");
        action.setParams({
            docuSignAccId: component.get("v.docuSignAccId"),
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.reminderAndExp', response.getReturnValue());
                component.set('v.defaultReminderDelay', response.getReturnValue().reminderDelay);
                component.set('v.defaultReminderFrequency', response.getReturnValue().reminderFrequency);
                component.set('v.defaultExpireAfter', response.getReturnValue().expireAfter);
                component.set('v.defaultExpireWarn', response.getReturnValue().expireWarn);
        		var today = new Date();
                today.setDate(today.getDate() + parseInt(response.getReturnValue().expireAfter));
                var expireDate = $A.localizationService.formatDate(today, "MMMM dd yyyy");
                component.set("v.expiredate", expireDate);
            } 
            else if (response.getState() === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    addRowForRecepient: function (component, event, helper) {
        var recipientList = component.get("v.recipientList");
        recipientList.push({
            'recipientId': '',
            'signingOrder': '',
            'recipientType': 'Need to Sign',
            'name': '',
            'email': '',
            'privateMessage': '',
            'disabled': 'false'
        });
        component.set("v.recipientList", recipientList);
    },

    removeSelectedRecepient: function (component, event, helper) {
        var recipientList = component.get("v.recipientList");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        recipientList.splice(index, 1);
        component.set("v.recipientList", recipientList);
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
                        name: element['Name__c'],
                        type: element['Type__c'],
                        title : element['Job_Title__c'],
                    	role : element['Role__c']
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
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    },

    getBatchCurrentStatus: function (component, helper) {
        var action = component.get("c.getBatchCurrentStatus");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        var batchId = component.get('v.batchId');
        action.setParams({
            "batchId": batchId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.batchJobStatus", result.status);
                if (result.status == 'Completed') {
                    var noe = result.numberOfErrors;
                    if (noe >= 1) {
                        var element = document.getElementById("batchJobStatusDiv");
                        element.classList.remove("successO");
                        element.classList.add("errorO");
                        component.set("v.hasErrors", true);
                        component.set("v.batchJobStatus", $A.get("$Label.c.CLM_CL00019_DOCUSIGN_FILE_SIZE_EXCEEDED_ERROR"));
                    } else {
                        var element = document.getElementById("batchJobStatusDiv");
                        element.classList.remove("errorO");
                        element.classList.add("successO");
                        component.set("v.batchJobStatus", " Success - redirecting to agreement record.");
                        window.open('/lightning/r/Apttus__APTS_Agreement__c/' + rId + '/view', '_top');
                    }
                } else if (result.status == 'Failed') {
                    var element = document.getElementById("batchJobStatusDiv");
                    element.classList.remove("successO");
                    element.classList.add("errorO");
                    component.set("v.hasErrors", true);
                    component.set("v.batchJobStatus", $A.get("$Label.c.CLM_CL00019_DOCUSIGN_FILE_SIZE_EXCEEDED_ERROR"));
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": $A.get("$Label.c.CLM_CL00019_DOCUSIGN_FILE_SIZE_EXCEEDED_ERROR")
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
        window.setTimeout(
            $A.getCallback(function () {
                helper.getBatchCurrentStatus(component, helper);
            }), 5000);
    },

    getPreviewBatchStatus: function (component, helper) {
        var timer = 0;
        var action = component.get("c.getBatchCurrentStatus");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        var batchId = component.get('v.batchId');
        action.setParams({
            "batchId": batchId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.batchJobStatus", result.status);
                if (result.status == 'Completed') {
                    clearTimeout(timer);
                    var noe = result.numberOfErrors;
                    if (noe >= 1) {
                        var element = document.getElementById("batchJobStatusDiv");
                        component.set("v.batchJobStatus", " Failed - " + result.extendedStatus);
                        component.set("v.isModalOpen", false);  
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "Error",
                            "mode": 'sticky',
                            "message": $A.get("$Label.c.CLM_CL00019_DOCUSIGN_FILE_SIZE_EXCEEDED_ERROR")
                        });
                        toastEvent.fire();
                    } else {
                        var element = document.getElementById("batchJobStatusDiv");
                        component.set("v.batchJobStatus", " Success - Previewing the envelope.");
                        helper.getPreviewUrl(component, helper);
                    }
                } else if (result.status == 'Failed') {
                    clearTimeout(timer);
                    var element = document.getElementById("batchJobStatusDiv");
                    component.set("v.batchJobStatus", " Failed - " + result.extendedStatus);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
        timer = window.setTimeout(
        $A.getCallback(function () {
            helper.getPreviewBatchStatus(component, helper);
        }), 5000);
    },

    getPreviewUrl: function (component, helper) {
        var recipientId = component.get("v.defaultRecipientId");
        var action = component.get("c.getDocuSignPreviewUrl");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            agreementId: rId,
            sendAsUserEmail: component.get("v.sendAsUserEmail"),
            docuSignAccId: component.get("v.docuSignAccId"),
            recipientId : recipientId
        });
        action.setCallback(this, function (response) {
            var eSResult = response.getReturnValue();
            if (response.getState() === "SUCCESS") {
                component.set("v.hasError", false);
                component.set("v.errorList", '');
                component.set("v.previewUrl", eSResult.batchId);
                document.getElementById("previewIframe").src = eSResult.batchId;
                component.set("v.loaded", false);
            } else if (response.getState() === "ERROR") {
                component.set("v.loaded", false);
                component.set("v.hasError", true);
                component.set("v.errorList", eSResult.message);
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
                console.log("Errors::" + JSON.stringify(errors));
            }
			component.set("v.isDocuPreviewLoaded", false);
        });
        $A.enqueueAction(action);
    },

    getBatchStatus: function (component, helper) {
        helper.getBatchCurrentStatus(component, helper);
    },

    checkHeapSize: function (component, event, helper) {
        var action = component.get("c.checkHeapSize");
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if (result) {
                    component.set("v.currentProgressStep", "s2");
                    component.set("v.showPage1", false);
                    component.set("v.checkUserPage", true);
                    component.set("v.showPage2", false);
                    component.set("v.showPage3", false);
                    component.set("v.showPage4", false);
                    component.set("v.showPage5", false);
                } else {
                    alert('In order to proceed further Please use the Finalize In Docusign button, since the selected attachments exceeds the heap size.');
                    component.set("v.enableFinalizeInDocuSignForContractAdmin", true);
                }
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    openFinalizedInDocuSign: function (component, helper) {
        component.set("v.loaded", true);
        var action = component.get("c.processFinalizeInDocuSign");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            selectedAttJSON: JSON.stringify(component.get("v.selectedAttachments")),
            selectedSignersJSON: JSON.stringify(component.get("v.dummyRecipientList")),
            emailSubject: component.get("v.emailSubject"),
            emailBlurb: component.get("v.emailBlurb"),
            agreementId: rId,
            reminderAndExp: JSON.stringify(component.get("v.reminderAndExp")),
            sendAsUserEmail: component.get("v.sendAsUserEmail")
        });
        action.setCallback(this, function (response) {
            var eSResult = response.getReturnValue();
            if (eSResult.status == 'SUCCESS') {
                component.set("v.hasError", false);
                component.set("v.errorList", '');
                component.set('v.docuSignEnvelopeId', eSResult.batchId);
                helper.getUrlForTheFinalizeInDocuSign(component);
                component.set("v.loaded", false);
            } else {
                component.set("v.loaded", false);
                component.set("v.hasError", true);
                component.set("v.errorList", eSResult.message);
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getEmailTemplatesNames: function (component) {
        var action = component.get("c.getEmailTemplateNames");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            agreementId: rId
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var rv = response.getReturnValue();
                component.set('v.emailTemplateList', rv); 
                component.set('v.recordType', rv[0].recortypeName);
                component.set("v.internalDefaultTemplate", rv[0].internalDefault);
                component.set("v.externalDefaultTemplate", rv[0].externalDefault);
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getIndividualEmailTemplateBody: function (component) {
        var recipientList = component.get("v.recipientList");
        var selectedTemplates = [];
        for (var i = 0; i < recipientList.length; i++) {
            selectedTemplates.push(recipientList[i].emailTemplate);
        }
        var action = component.get("c.getIndividualEmailTemplateBody");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            agreementId: rId,
            templateNameList: selectedTemplates,
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var rv = response.getReturnValue();
                rv.forEach(element => {
                    for (var i = 0; i < recipientList.length; i++) {
                        if (recipientList[i].emailTemplate == element['template']) {
                            recipientList[i].emailSubject = element['subject'];
                            recipientList[i].emailBody = element['body'];
                        }
                    }
                });
                component.set("v.recipientList", recipientList);

            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getDocusignUserMetadataList: function (component) {
        var docusignUserList = component.get("v.docusignEmailList");
        var action = component.get("c.getDocusignUserMetadataList");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            agreementId: rId
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.docusignEmailList', response.getReturnValue());
                if(response.getReturnValue()[0].defaultValue === '') {
                    component.find("sendAsEmail").set("v.value", "LoggedInUser");                    
                }
                else {
                    component.set('v.userNameDefaultValue', response.getReturnValue()[0].defaultValue);
                }
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    checkUserInDocusign: function (component) {
        var selectedSendAsUserEmail = component.get("v.selectedSendAsUserEmail");
        var sendAsUserEmail = component.get("v.sendAsUserEmail");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        var action = component.get("c.checkIfUserExistInDocuSign");
        action.setParams({
            agreementId: rId,
            userEmail: selectedSendAsUserEmail,
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var eSResult = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if (eSResult.status == 'SUCCESS') {
                    component.set("v.sendAsUserEmail", eSResult.message);
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "mode": 'dismissible',
                        "message": "User Verification in Docusign Successful!"
                    });
                    toastEvent.fire();
                    component.set("v.showNext", true);
                    component.set("v.sendAsUserEmail", eSResult.message);
                    component.set("v.checkUser", false);
                    component.set("v.showPage1", false);
                    component.set("v.checkUserPage", false);
                    component.set("v.showPage2", true);
                    component.set("v.showPage3", false);
                    component.set("v.showPage4", false);
                    component.set("v.showPage5", false);
                } else {
                    if(eSResult.message.includes("AUTHORIZATION_INVALID_TOKEN")) {
                        if(selectedSendAsUserEmail == 'LoggedInUser') {
                            selectedSendAsUserEmail = $A.get("$SObjectType.CurrentUser.Email");
                        }                        
                        toastEvent.setParams({
                            "title": "Sorry!",
                            "type": "warning",
                            "mode": 'dismissible',
                            "message": $A.get("$Label.c.CLM_CL00020_DOCUSIGN_EMAIL_INCORRECT") + " " + selectedSendAsUserEmail
                        });
                        toastEvent.fire();
                    }
                    else {
                        toastEvent.setParams({
                            "title": "Sorry!",
                            "type": "warning",
                            "mode": 'dismissible',
                            "message": "Selected User with " + selectedSendAsUserEmail + " email address doesn't Exist in Docusign. Please select another User."
                        });
                        toastEvent.fire();
                    }
                }

            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    fetchUserDetails : function (component) {
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.sendAsUserName", storeResponse.Name);
            }
        });
        $A.enqueueAction(action);
	},        
        
    getRecipientIds: function (component, helper) {
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));       
        var action = component.get("c.previewRecipents");
        action.setParams({
            selectedSignersJSON: JSON.stringify(component.get("v.recipientList"))
        });
        action.setCallback(this, function (response) {
            var eSResult = response.getReturnValue(); 
            if (eSResult.status == 'SUCCESS') {
                component.set("v.hasError", false);
                component.set("v.errorList", '');   
                component.set('v.recipientList', eSResult.recipientList);
                component.set("v.showPage1", false);
                component.set("v.checkUserPage", false);
                component.set("v.showPage2", false);
                component.set("v.showPage3", false);
                component.set("v.showPage4", true);
                component.set("v.showPage5", false);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": 'We could not process the request.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    sendDocusignEnvelope : function(component, helper){
        var action = component.get("c.sendDocusignEnv");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            agreementId: rId,
            sendAsUserEmail: component.get("v.sendAsUserEmail"),
            docuSignAccId: component.get("v.docuSignAccId")            
        });
        action.setCallback(this, function(response) {
            var eSResult = response.getReturnValue();
            if (response.getState() === "SUCCESS") {
                if (eSResult.status == 'SUCCESS') {
                    component.set("v.hasError", false);
                    component.set("v.errorList", '');
                    component.set("v.loaded", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Document Sent successully!"
                    });
                    toastEvent.fire();
                    window.open('/lightning/r/Apttus__APTS_Agreement__c/' + rId + '/view', '_top');
                } else {
                    if(eSResult.message.includes("INVALID_EMAIL_ADDRESS_FOR_RECIPIENT")) {
                        var errors = response.getError();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Sorry!",
                            "type": "warning",
                            "mode": 'dismissible',
                            "message": 'The email address for the recipient is invalid.'
                        });
                        toastEvent.fire();
                    } else {
                        var errors = response.getError();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Sorry!",
                            "type": "warning",
                            "mode": 'dismissible',
                            "message": JSON.stringify(errors)
                        });
                        toastEvent.fire();
                    }
                }

            } else if (response.getState() === "ERROR") {
                component.set("v.loaded", false);
                component.set("v.hasError", true);
                component.set("v.errorList", eSResult.message);
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
                console.log("Errors::" + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
    },
        
    getOpenDocuSignEnvelope: function (component) {
        var action = component.get("c.getOpenDocuSignEnvelope");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            agrId: rId
        });
        action.setCallback(this, function (response) {
            var docuSignFlag = false;
            if (response.getState() === "SUCCESS") {
                var docuSignEnvelope = response.getReturnValue();
                if(docuSignEnvelope.length > 0) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "Error",
                        "mode": 'dismissible',
                        "message": $A.get("$Label.c.CLM_CL00023_ACTIVE_DOCUSIGN_ENVELOPE_EXISTS")
                    });
                    toastEvent.fire();
                    component.set("v.loadScreen", false);                
                    const myTimeout = setTimeout(goToAgreement, 5000);
                    function goToAgreement() {
                        var navSer = component.find("navigate");
                        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
                        window.open('/lightning/r/Apttus__APTS_Agreement__c/' + rId + '/view', '_top');
                    }
                }
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
})