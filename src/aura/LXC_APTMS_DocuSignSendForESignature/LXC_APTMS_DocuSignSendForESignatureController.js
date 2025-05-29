({
    doInit: function (component, event, helper) {
        var envelopeId = component.get("v.envId");
        if (envelopeId != undefined) {
            component.set("v.loadScreen", false);
            helper.updateDocuSignEnvelope(component, event, helper);
        } else {
            var pageReference = component.get("v.pageReference");
            var recordId = pageReference.state.c__recordId;
            var docuSignAccId = pageReference.state.c__accId;
            component.set("v.docuSignAccId", docuSignAccId);
            component.set("v.recordId", recordId);
            component.set('v.columns', [{
                label: 'Document Name',
                fieldName: 'name',
                type: 'text'
            },{label: ' DocumentType',
               fieldName : 'fileType',
               type: 'text',
            },{
                label: 'Size (kb)',
                fieldName: 'bodyLength',
                type: 'text',
                fixedWidth: 150
            },{label: 'Last Modified By',
               fieldName: 'lastModifiedBy',
               type: 'text',
               fiexdWidth: 180
            },{
                label: 'Last Modified Date',
                fieldName: 'lastModifiedDate',
                type: 'date',
                fixedWidth: 160
            }
            ]);
            var action = component.get("c.checkIfAccountDetailsAvailable");
            action.setParams({
                agreementId: component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                if (response.getState() == "SUCCESS") {
                    var eSResult = response.getReturnValue();
                    component.set("v.sendAsUserEmail", eSResult);
                    helper.getAllDocuments(component);
                    helper.getAgreementContacts(component);
                    helper.getOpenDocuSignEnvelope(component);
                    helper.getReminderAndExpiration(component);
                    helper.getEmailTemplatesNames(component);
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
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    updateSelectedAttachments: function (component, event, helper) {
        var capturedCheckboxes = event.getParam('selectedRows');
        var selectedCheckBoxes = [];       
        var bodyLength = 0; 
        for (var i = 0; i < capturedCheckboxes.length; i++) {
            if (selectedCheckBoxes.indexOf(capturedCheckboxes[i].attId) > -1) {
                selectedCheckBoxes.splice(selectedCheckBoxes.indexOf(capturedCheckboxes[i].attId), 1);
            } else {
                selectedCheckBoxes.push(capturedCheckboxes[i].attId);
                bodyLength += parseInt(capturedCheckboxes[i].bodyLength.replace(' kb', ''));
            }
        }
        if (capturedCheckboxes.length === 0) {
            selectedCheckBoxes = [];
        }
        component.set("v.documentSize", bodyLength);
        component.set("v.selectedAttachments", selectedCheckBoxes);
        component.set("v.selectedRowsList", selectedCheckBoxes);
    },
    
    removeSelectedRecepient: function (component, event, helper) {
        helper.removeSelectedRecepient(component, event, helper);
    },
    
    sendForESignature: function (component, event, helper) {
        helper.sendForESignature(component, helper);
    },
    
    finalizedInDocuSign: function (component, event, helper) {
        component.set("v.loaded", true);   
        setTimeout($A.getCallback(function() {
            var popUp = window.open('https://www.docusign.com', 'width=1, height=1');
            if((popUp === null) || (typeof (popUp) == 'undefined')) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'sticky',
                    "message": $A.get("$Label.c.CLM_CL00022_POPUP_BLOCKED_ERROR")
                });
                toastEvent.fire();
                component.set("v.loaded", false);      
            }
            else  {
                popUp.close();
                helper.finalizedInDocuSign(component, helper);
            } 
        }), 5000);
    },
    
    openModel: function (component, event, helper) {
        component.set("v.isModalOpen", true);
        component.set("v.isDocuPreviewLoaded", true);
        helper.getRecipientIds(component, helper);
        helper.previewEnv(component, helper);
    },
    
    displaySelectedRecipient : function (component, event, helper) {
        var value = component.find("APTS_selectRecipient").get("v.value");
        component.set("v.defaultRecipientId", value);
        helper.getPreviewUrl(component, helper);
    },

    sendEnvelope : function(component, event,helper) {
        helper.sendDocusignEnvelope(component, helper);        
    },
    
    closeModel: function (component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    submitDetails: function (component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    goto0: function (component, event, helper) {
        var navSer = component.find("navigate");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        window.open('/lightning/r/Apttus__APTS_Agreement__c/' + rId + '/view', '_top');
    },
    
    goto1: function (component, event, helper) {
        component.set("v.showPage1", true);
        component.set("v.checkUserPage", false);
        component.set("v.showPage2", false);
        component.set("v.showPage3", false);
        component.set("v.showPage4", false);
        component.set("v.showPage5", false);
    },
    
    gotoCheckUserPage: function (component, event, helper) {
        var totalDocumentSize = component.get("v.documentSize");
        var selectedCheckBoxes = component.get("v.selectedAttachments");
        if (selectedCheckBoxes == '') {
            alert('Please select at least one document !!');
        }
        else if(totalDocumentSize > 4300) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "Error",
                "mode": 'dismissible',
                "message": 'Please choose documents having size less than 4.2 MB'
            });
            toastEvent.fire();
        }       
        else {
            helper.checkHeapSize(component, event, helper);
            helper.getDocusignUserMetadataList(component, helper);
        }
    },
    
    goto2: function (component, event, helper) {
        var selectedSendAsUserEmail = component.get("v.selectedSendAsUserEmail");
        var sendAsUserEmail = component.get("v.sendAsUserEmail");
        if (component.get("v.checkUser") == true) {
            helper.checkUserInDocusign(component);
        } else {
            component.set("v.showPage1", false);
            component.set("v.checkUserPage", false);
            component.set("v.showPage2", true);
            component.set("v.showPage3", false);
            component.set("v.showPage4", false);
            component.set("v.showPage5", false);
        }
    },
    
    goto3: function (component, event, helper) {
        var isValid = true;
        var availableRoutingNumbers = [];
        var missingRoutingNumber = [];
        var recipientList = component.get("v.recipientList");
        if (recipientList.length > 0) {
            for (var i = 0; i < recipientList.length; i++) {
                if (recipientList[i].signingOrder == '' || recipientList[i].signingOrder !=Math.floor(recipientList[i].signingOrder) || recipientList[i].signingOrder<1) {
                    isValid = false;
                } 
                else {
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
                    "message": "Routing order is invalid for one or more recipient(s). Please fill and try again."
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
            }
            else {
                component.set("v.currentProgressStep", "s3");
                component.set("v.showPage1", false);
                component.set("v.checkUserPage", false);
                component.set("v.showPage2", false);
                component.set("v.showPage3", true);
                component.set("v.showPage4", false);
                component.set("v.showPage5", false);
                if (component.get("v.executionOrderCheck") == true) {
                    helper.getEmailTemplateBody(component, helper);
                } else {
                    helper.getIndividualEmailTemplateBody(component);
                }
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
    },
    
    goto4: function (component, event, helper) {
        if(component.get("v.executionOrderCheck") == true) {
            var emailSubject = component.get("v.emailSubject");
            var emailBody = component.get("v.emailBlurb");
            if(emailSubject == undefined || emailBody == undefined || emailSubject === "" || emailBody === ""){
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": "Email subject or body can't be blank, Please validate and try again."
                });
                toastEvent.fire();
            } else if(emailSubject != undefined && emailSubject.length > 100){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": "Email subject is exceeding the maximum characters limit of 100 characters, Please validate and try again."
                });
                toastEvent.fire();
            } else {
                component.set("v.currentProgressStep", "s4");
                component.set("v.showPage1", false);
                component.set("v.checkUserPage", false);
                component.set("v.showPage2", false);
                component.set("v.showPage3", false);
                component.set("v.showPage4", true);
                component.set("v.showPage5", false);
            }
        } else { 
            var isValid = true;
            var recipientList = component.get("v.recipientList");
            if (recipientList.length > 0) {
                var recipientList = component.get("v.recipientList");
                for (var i = 0; i < recipientList.length; i++) {
                    if(recipientList[i].emailSubject == undefined || recipientList[i].emailBody == undefined || recipientList[i].emailSubject === "" || recipientList[i].emailBody === "" ){
                        isValid = false;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "Error",
                            "mode": 'dismissible',
                            "message": "Recipient "+ recipientList[i].signingOrder+" - Email subject or body can't be blank, Please validate and try again."
                        });
                        toastEvent.fire();
                    }else if (recipientList[i].emailSubject != undefined && recipientList[i].emailSubject.length > 100) {
                        isValid = false;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "Error",
                            "mode": 'dismissible',
                            "message": "Recipient "+ recipientList[i].signingOrder+" - Email subject is exceeding the maximum characters limit of 100 characters, Please validate and try again."
                        });
                        toastEvent.fire();
                    }
                }
                    if(isValid){
                        component.set("v.currentProgressStep", "s4");
                        component.set("v.showPage1", false);
                        component.set("v.checkUserPage", false);
                        component.set("v.showPage2", false);
                        component.set("v.showPage3", false);
                        component.set("v.showPage4", true);
                        component.set("v.showPage5", false);  
                    }
            }
        }
    },

    goto5: function (component, event, helper) {
        component.set("v.currentProgressStep", "s5");
        component.set("v.showPage1", false);
        component.set("v.checkUserPage", false);
        component.set("v.showPage2", false);
        component.set("v.showPage3", false);
        component.set("v.showPage4", false);
        component.set("v.showPage5", true);
    },
    
    searchHandler: function (component, event, helper) {
        const searchString = event.target.value;
        if (searchString.length >= 2) {
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
        var container = document.getElementsByClassName('slds-combobox_container')[0];
        document.addEventListener('click', function(event) {
            if(container !== event.target && !container.contains(event.target)) {    
                component.set("v.openDropDown", false);
            }
        });
    },
    
    optionClickHandler: function (component, event, helper) {
        const selectedId = event.target.closest('li').dataset.id;
        const selectedValue = event.target.closest('li').dataset.value;
        component.set("v.inputValue", selectedValue);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedId);
    },
    
    clearOption: function (component, event, helper) {
        component.set("v.results", []);
        component.set("v.openDropDown", false);
        component.set("v.inputValue", "");
        component.set("v.selectedOption", "");
    },
    
    addToListHandler: function (component, event, helper) {
        var contacts = component.get("v.results");
        var selectedContactId = component.get("v.selectedOption");
        if (selectedContactId != '' && selectedContactId != undefined) {
            helper.addRowForRecepient(component, event, helper);
        }
        var recipientList = component.get("v.recipientList");
        contacts.forEach(element => {
            if (element['id'] === selectedContactId) {
                recipientList.every(elementR => {
                if (elementR['name'] == '' && elementR['email'] == '') {
                    var recipientType = element['role'] != '' && element['role'] != undefined && element['role'].includes('Receive a Copy') ? 'Carbon copy' : 'Signer';
                    elementR['name'] = element['name'];
                    elementR['email'] = element['email'];
                    elementR['userType'] = element['type'];
                    elementR['recipientType'] = recipientType;
                    elementR['privateMessage'] = element['title'];
                    return false;
                } 
            else {
                return true;
            }});        
        }});
        var recipientListNew = [];
        var executionOrder = component.get("v.executionOrder");
        var recipientList1 = [];
        var recipientList2 = [];
        if (executionOrder != undefined && (executionOrder == 'Legal Entities First' || executionOrder == 'Account First')) {
            recipientList.forEach(element => {
                if (element['userType'] == 'Contact') {
                recipientList1.push(element);
                } else {
                    recipientList2.push(element);
                }
            });
            if (executionOrder != undefined && executionOrder == 'Legal Entities First') {
                recipientListNew.push(...sortResults2('name', false));
                recipientListNew.push(...sortResults1('name', false));
                component.set("v.recipientList", recipientListNew);
            } else if (executionOrder != undefined && executionOrder == 'Account First') {
                recipientListNew.push(...sortResults1('name', false));
                recipientListNew.push(...sortResults2('name', false));
                component.set("v.recipientList", recipientListNew);
            }
        } else {
            recipientListNew.push(...sortResults('name', false));
            component.set("v.recipientList", recipientListNew);
        }
        function sortResults1(prop, asc) {
            return recipientList1.sort(function (a, b) {
                if (asc) {
                    return (a[prop] > b[prop]) ? 1 : ((a[prop] < b[prop]) ? -1 : 0);
                } else {
                    return (b[prop] > a[prop]) ? 1 : ((b[prop] < a[prop]) ? -1 : 0);
                }
            });
        }
        function sortResults2(prop, asc) {
            return recipientList2.sort(function (a, b) {
                if (asc) {
                    return (a[prop] > b[prop]) ? 1 : ((a[prop] < b[prop]) ? -1 : 0);
                } else {
                    return (b[prop] > a[prop]) ? 1 : ((b[prop] < a[prop]) ? -1 : 0);
                }
            });
        }
        function sortResults(prop, asc) {
            return recipientList.sort(function (a, b) {
                if (asc) {
                    return (a[prop] > b[prop]) ? 1 : ((a[prop] < b[prop]) ? -1 : 0);
                } else {
                    return (b[prop] > a[prop]) ? 1 : ((b[prop] < a[prop]) ? -1 : 0);
                }
            });
        }
        component.set("v.inputValue", "");
        component.set("v.results", []);
        component.set("v.selectedOption", "");
        },
    
    updateReminderAndExp: function (component, event, helper) {
        var targetValue = event.target.value;
        var targetName = event.target.name;
        if (targetValue != '' && targetValue != undefined && targetValue >= 1) {
            if (targetName == "reminderDelay") {
                component.set("v.reminderAndExp.reminderDelay", targetValue);
            } else if (targetName == "reminderFrequency") {
                component.set("v.reminderAndExp.reminderFrequency", targetValue);
            } else if (targetName == "expireAfter") {
                component.set("v.reminderAndExp.expireAfter", targetValue);
                var today = new Date();
                today.setDate(today.getDate() + parseInt(targetValue));
                var expireDate = $A.localizationService.formatDate(today, "MMMM dd yyyy");
                component.set("v.expiredate", expireDate);
            } else if (targetName == "expireWarn") {
                component.set("v.reminderAndExp.expireWarn", targetValue);
            }
        } 
        else {
            if (targetName == "reminderDelay") {
                component.set("v.reminderAndExp.reminderDelay", component.get("v.defaultReminderDelay"));
            } else if (targetName == "reminderFrequency") {
                component.set("v.reminderAndExp.reminderFrequency", component.get("v.defaultReminderFrequency"));
            } else if (targetName == "expireAfter") {
                component.set("v.reminderAndExp.expireAfter", component.get("v.defaultExpireAfter"));
                var today = new Date();
                today.setDate(today.getDate() + parseInt(component.get("v.defaultExpireAfter")));
                var expireDate = $A.localizationService.formatDate(today, "MMMM dd yyyy");
                component.set("v.expiredate", expireDate);
            } else if (targetName == "expireWarn") {
                component.set("v.reminderAndExp.expireWarn", component.get("v.defaultExpireWarn"));
            }
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type": "warning",
                "mode": 'dismissible',
                "message": "Reminders and Expiration values Should not be less than 1 day ! Else default values will be Used for eSignature"
            });
            toastEvent.fire();
        }        
    },
        
    openFinalizedInDocuSign: function (component, event, helper) {
        helper.openFinalizedInDocuSign(component, helper);
    },
            
    checkUserInDocusign: function (component, event, helper) {
        helper.checkUserInDocusign(component, helper);
    },

    checkSelectedUser: function (component, event, helper) {
        component.set("v.askConsent", false);
        var selectedSendAsUserEmail = component.get("v.selectedSendAsUserEmail");
        var sendAsUserEmail = component.get("v.sendAsUserEmail");
        if (selectedSendAsUserEmail != sendAsUserEmail) {
            component.set("v.checkUser", true);
        }
        var emailList = component.get("v.docusignEmailList"); 
        var value = component.find("sendAsEmail").get("v.value");
        var index, contactName;                    
        if(value == 'LoggedInUser'){                       
            helper.fetchUserDetails(component);
        }else{
            emailList.forEach(function(v,i,a) { 
                if(v.value == value) {
                    index = i;
                }
            });
            contactName = emailList[index].label;  
            component.set("v.sendAsUserName", contactName);
        }                           
    },
})