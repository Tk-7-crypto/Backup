({
    getCategorizationAndAsset: function (component) {
        return new Promise(function(resolve, reject) {
        component.set("v.isLoading", true);
        var recordId = component.get("v.simpleNewCase.RecordTypeId");
        var productName = component.find("product" + recordId).get("v.value");
        var cshSubtype;
        if (recordId != "0126A000000hC33QAE"){
            cshSubtype = (component.find("caseSubType") !== undefined && component.get("v.AccountCaseSubtype") && component.get("v.ContactUserType") == "HO User" && component.find("caseSubType").get("v.value") != "undefined") ? component.find("caseSubType").get("v.value") : "Please Specify";            
        }
        var action = component.get("c.getCategorization");
        action.setParams({
            "productName": productName,
            "cshSubtype": cshSubtype
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.simpleNewCase.Case_CategorizationId__c", response.getReturnValue()[0].Id);
                component.set("v.simpleNewCase.ProductName__c", response.getReturnValue()[0].ProductName__c);
                component.set("v.simpleNewCase.Case_Type__c", response.getReturnValue()[0].CaseType__c);
                if (component.get("v.AccountCaseSubtype") && component.get("v.ContactUserType") == "HO User" && recordId != "0126A000000hC33QAE") {
                    component.set("v.simpleNewCase.CSHSubType__c", response.getReturnValue()[0].CSHSubType__c);
                }
                component.set("v.simpleNewCase.SubType1__c", response.getReturnValue()[0].SubType1__c);
                component.set("v.simpleNewCase.SubType2__c", response.getReturnValue()[0].SubType2__c);
                component.set("v.isLoading", false);
                resolve(response.getReturnValue());

            } else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading", false);
                reject(new Error(response.getError()));
            }
        });
        $A.enqueueAction(action);
       });
    },


    getCategorizationForDataGlobalSupport: function(component, product, recordTypeId) {
        return new Promise(function(resolve, reject) {
            var action = component.get("c.getCategorizationForDataGlobalSupport");
            action.setParams({ 
                productName: product,
                recordTypeId: recordTypeId
             });
            action.setCallback(this, function(response) {
              var state = response.getState();
              if (state === "SUCCESS") {
                if (response.getReturnValue()) {
                  resolve(response.getReturnValue());
                }
              } else {
                console.log("error categorizationForDataGlobalSupport", response.getError());
                reject(new Error(response.getError()));
              }
            });
            $A.enqueueAction(action);
          });
    },

    getUserAccount: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getUserAccount");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var account = response.getReturnValue()[0];
                component.set("v.account", account);
                if (account) {
                    if (account.AccountCountry__c == 'US') {
                        component.set("v.simpleNewCase.PhoneVerification__c", true);
                    } else {
                        component.set("v.simpleNewCase.PhoneVerification__c", false);
                        component.set("v.disabledProblem_Type", true);
                    }
                    component.set("v.loggedInUserAccountId", account.Id);
                    component.set("v.AccountCaseSubtype", account.CSH_SubType__c);
                    component.set("v.isDisableCSHP1CaseCreation", account.Disable_CSH_P1_Case_Creation__c);
                    component.set("v.simpleNewCase.AccountId", account.Id);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    getUserContact: function (component) {
        var action = component.get("c.getUserContact");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contact = response.getReturnValue()[0];
                if (contact) {
                    component.set("v.contact", contact);
                    var portal_case_type = contact.Portal_Case_Type__c.split(';');
                    component.set("v.portalCaseTypes", portal_case_type);
                    if (portal_case_type.length == 1) {
                        component.set("v.portalCaseTypeSelectedValue", portal_case_type[0])
                    }
                    component.set("v.simpleNewCase.ContactId", contact.Id);
                    component.set("v.ContactUserType", contact.Contact_User_Type__c);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    /*
        getUserAssetsForDATA: function (component) {
            var action = component.get("c.getUserAssetsForDATA2");
            action.setParams({
                "names": component.get("v.assetsName")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var assets = response.getReturnValue();
                    var opts = [];
                    if (assets != undefined && assets.length > 0) {
                        opts.push({
                            class: "optionClass",
                            label: "Please Specify",
                            value: ""
                        });
                    }
                    for (var i = 0; i < assets.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: assets[i].Name,
                            value: assets[i].Id
                        });
                    }
                    component.set("v.assets", opts);
    
    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                }
            });
            $A.enqueueAction(action);
        },
    */
    getPickListOptions: function (component, field, optionsNameAttribut) {
        var action = component.get("c.getPickListOptions");
        action.setParams({
            "fld": field
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var opts = [];
                var allValues = response.getReturnValue();
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "Please Specify",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.set(optionsNameAttribut, opts);

            } else if (state === "ERROR") {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    },

    getProducts: function (component) {
        if (component.get("v.AccountCaseSubtype") && component.get("v.ContactUserType") == "HO User") {
            component.set("v.isDependentTechnoSubTypeDisable", true);
        }
        component.set("v.isLoading", true);
        var action = component.get("c.getProductCategorizationForNewCase");
        action.setParams({
            "accountId": component.get("v.account").Id,
            "recordType": component.get("v.simpleNewCase.RecordTypeId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var productsList = response.getReturnValue();
                component.set("v.assetIds", productsList);
                var productNamesArray = [];
                productNamesArray.push({
                    class: "optionClass",
                    label: "Please Specify",
                    value: "Please Specify"
                });
                for (var i = 0; i < productsList.length; i++) {
                    productNamesArray.push({ class: "optionClass", label: productsList[i].label, value: productsList[i].label });
                }
                var recordId = component.get("v.simpleNewCase.RecordTypeId");
                component.find("product" + recordId).set("v.options", productNamesArray);
                component.set("v.isLoading", false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(JSON.stringify(errors));
                component.set("v.isLoading", false);
            }

        });
        $A.enqueueAction(action);
    },

    getTechnoSubtype: function (component) {
        component.set("v.isLoading", true);
        var recordId = component.get("v.simpleNewCase.RecordTypeId");
        var productName = component.find("product" + recordId).get("v.value");
        if (productName != "Please Specify") {
            //PEP-ACN add new param to filter by PRM subtype in case of partner portal
            var action = component.get("c.getSubtypeCategorization");
            action.setParams({
                "productName": productName,
                "origin": component.get("v.communityOrigin")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var subtypeList = response.getReturnValue();
                    var subtypeArray = [];
                    if (subtypeList.length > 1) {
                        for (var i = 0; i < Object.keys(subtypeList).length; i++) {
                            var subtype = subtypeList[i].CSHSubType__c;
                            subtypeArray.push({ class: "optionClass", label: subtype, value: subtype });
                        }
                        var idx = subtypeArray.map(function (element) { return element.value; }).indexOf("Please Specify");
                        if (idx != -1) {
                            subtypeArray.splice(idx, 1);
                            subtypeArray.splice(0, 0, { class: "optionClass", label: "Please Specify", value: "Please Specify" });
                        }
                        component.find("caseSubType").set("v.options", subtypeArray);
                        component.set("v.isDependentTechnoSubTypeDisable", false);
                        component.set("v.isLoading", false);
                    } else if (subtypeList.length == 1 && subtypeList[0].CSHSubType__c == "Please Specify") {
                        subtypeArray.splice(idx, 1);
                        subtypeArray.splice(0, 0, { class: "optionClass", label: "Please Specify", value: "Please Specify" });
                        component.find("caseSubType").set("v.options", subtypeArray);
                        component.set("v.isDependentTechnoSubTypeDisable", true);
                        component.set("v.isLoading", false);
                    } else {
                        component.set("v.isLoading", false);
                    }
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    component.set("v.isLoading", false);
                }

            });
        } else {
            if (component.get("v.AccountCaseSubtype")) {
                component.set("v.isDependentTechnoSubTypeDisable", true);
                component.find("caseSubType").set("v.options", { class: "optionClass", label: "Please Specify", value: "Please Specify" });
            }

            component.set("v.isLoading", false);
        }
        $A.enqueueAction(action);
    },
    validateCaseForm: function (component) {
        var recordId = component.get("v.simpleNewCase.RecordTypeId");
        component.set("v.productSelectError", false);
        component.set("v.mailFormatError", false);
        component.set("v.caseSubTypeSelectError", false);
        if (component.find("productSelectFormElement" + recordId)) $A.util.removeClass(component.find("productSelectFormElement" + recordId), "is-required slds-has-error lightningInput");
        if (component.find("MailCcFormElement" + recordId)) $A.util.removeClass(component.find("MailCcFormElement" + recordId), "slds-has-error lightningInput");
        var validCase = true;
        // Show error messages if required fields are blank
        validCase = component.find('caseField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        var descr = component.find('caseFieldDes'+ recordId);
        var descrValue = descr.get('v.value');
        if (!descrValue || descrValue.trim().length === 0) {
            descr.set("v.errors", [{ message: "Complete this field." }]);
            validCase = false;
        } else {
            descr.set("v.errors", null);
        }

        if (component.find("product" + recordId)) {
            if (component.find("product" + recordId).get("v.value") == "Please Specify") {
                validCase = false;
                $A.util.addClass(component.find("productSelectFormElement" + recordId), "is-required slds-has-error lightningInput");
                component.set("v.productSelectError", true);
            }
        }

        if (component.find("caseSubType") && component.get("v.subtypeMandatory")) {
            if (component.find("caseSubType").get("v.value") == "Please Specify") {
                validCase = false;
                $A.util.addClass(component.find("caseSubTypeSelectFormElement"), "is-required slds-has-error lightningInput");
                component.set("v.caseSubTypeSelectError", true);
            }
        }

        if (component.get("v.showTechnoSubtypes")) {
            if (component.find("subType1").get("v.value") == "Please Specify") {
                validCase = false;
                $A.util.addClass(component.find("subType1SelectFormElement"), "is-required slds-has-error lightningInput");
            }
            if (component.find("subType2").get("v.value") == "Please Specify") {
                validCase = false;
                $A.util.addClass(component.find("subType2SelectFormElement"), "is-required slds-has-error lightningInput");
            }
            if (component.find("subType3").get("v.value") == "Please Specify") {
                validCase = false;
                $A.util.addClass(component.find("subType3SelectFormElement"), "is-required slds-has-error lightningInput");
            }
        }
        if (component.find("mailCcList" + recordId)) {
            var mailFlag = true;
            var emailField = component.find("mailCcList" + recordId);
            var emailFieldValue = emailField.get("v.value");
            var mailformat = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
            if (!$A.util.isEmpty(emailFieldValue)) {
                emailFieldValue = emailFieldValue.trim();
                if (emailFieldValue.indexOf(";") > -1) {
                    var multiemails = emailFieldValue.split(";");
                    for (var index = 0; index < multiemails.length; index++) {
                        var emailAddress = multiemails[index].trim();
                        if (emailAddress.trim().match(mailformat)) {
                            mailFlag = true;
                        }
                        else {
                            mailFlag = false;
                            break;
                        }
                    }
                }
                else {
                    if (emailFieldValue.match(mailformat)) {
                        mailFlag = true;
                    }
                    else {
                        mailFlag = false;
                    }
                }
                if (mailFlag) {
                    $A.util.removeClass(component.find("MailCcFormElement" + recordId), 'slds-has-error');
                    component.set("v.mailFormatError", false);
                }
                else {
                    $A.util.addClass(component.find("MailCcFormElement" + recordId), 'slds-has-error lightningInput');
                    component.set("v.mailFormatError", true);
                    validCase = false;
                }
            }
        }
        if (component.get("v.attachmentMandatory") && component.get('v.contentDocumentIds').length < 1) {
            validCase = false;
        }
        return (validCase);
    },

    openAttachmentForm: function (component) {
        $A.util.removeClass(component.find("modaldialog_caseCreateAttachment"), "slds-fade-in-hide");
        $A.util.addClass(component.find("modaldialog_caseCreateAttachment"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop_caseCreateAttachment"), "slds-backdrop--hide");
        $A.util.addClass(component.find("backdrop_caseCreateAttachment"), "slds-backdrop--open");

    },
    closeAttachmentForm: function (component) {
        $A.util.addClass(component.find("modaldialog_caseCreateAttachment"), "slds-fade-in-hide");
        $A.util.removeClass(component.find("modaldialog_caseCreateAttachment"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop_caseCreateAttachment"), "slds-backdrop--hide");
        $A.util.removeClass(component.find("backdrop_caseCreateAttachment"), "slds-backdrop--open");
    },
    getPriority: function (component) {
        var action = component.get("c.getpriorityvalue");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var priorityList = response.getReturnValue();
                var priorityNamesArray = [];
                for (var i = 0; i < Object.keys(priorityList).length; i++) {
                    var productName = priorityList[i];
                    priorityNamesArray.push(productName);
                }
                component.set("v.prioritytype", priorityNamesArray);
                component.set("v.simpleNewCase.Priority", "Low");
                //component.find("priority").set("v.prioritytype", productNamesArray);               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },

    getUrgency: function (component) {
        var action = component.get("c.getUrgencyList");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var urgencyList = response.getReturnValue();
                var urgencyNamesArray = [];
                for (var i = 0; i < Object.keys(urgencyList).length; i++) {
                    var urgencyName = urgencyList[i];
                    urgencyNamesArray.push(urgencyName);
                }
                component.set("v.urgencyList", urgencyNamesArray);
                component.set("v.simpleNewCase.Urgency__c", "Low");
                //component.find("priority").set("v.prioritytype", productNamesArray);               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    getImpact: function (component) {
        var action = component.get("c.getImpactList");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var impactList = response.getReturnValue();
                var impactNamesArray = [];
                for (var i = 0; i < Object.keys(impactList).length; i++) {
                    var impactName = impactList[i];
                    impactNamesArray.push(impactName);
                }
                component.set("v.impactList", impactNamesArray);
                component.set("v.simpleNewCase.Techno_Impact__c", "Low");
                //component.find("priority").set("v.prioritytype", productNamesArray);               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },

    getEnvironment: function (component) {
        var action = component.get("c.getEnvironmentList");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var environmentList = response.getReturnValue();
                var environmentNamesArray = [];
                //environmentNamesArray.push('Please Specify');
                for (var i = 0; i < Object.keys(environmentList).length; i++) {
                    var environmentName = environmentList[i];
                    environmentNamesArray.push(environmentName);
                }
                component.set("v.environmentList", environmentNamesArray);            
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log('errors', JSON.stringify(errors));
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },


    getCountryRequester: function (component) {
        var action = component.get("c.getCountryRequesterList");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var countryRes = response.getReturnValue();
                var countryList = [];
                for (var i = 0; i < countryRes.length; i++) {
                    countryList.push({ name: countryRes[i].label, value: countryRes[i].value });
                }
                component.set('v.countryList', countryList);

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);

    },

    getEscalationFormFields: function (component) {
        var action = component.get("c.getEscalationFormFields");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var escalationFormFields = response.getReturnValue();
                var deviceList = [],onlineorAppVersionList = [], browserUsedList = [], iOSVersionList = [];
                for (var i = 0; i < escalationFormFields.length; i++) {
                    for (var j = 0; j < escalationFormFields[i].options.length; j++) {
                        if(escalationFormFields[i].fieldName == 'device'){
                            deviceList.push({ name: escalationFormFields[i].options[j].label, value: escalationFormFields[i].options[j].value });
                        }else if(escalationFormFields[i].fieldName == 'onlineorAppVersion'){
                            onlineorAppVersionList.push({ name: escalationFormFields[i].options[j].label, value: escalationFormFields[i].options[j].value });
                        }else if(escalationFormFields[i].fieldName == 'browserUsed'){
                            browserUsedList.push({ name: escalationFormFields[i].options[j].label, value: escalationFormFields[i].options[j].value });
                        }
                        
                    }
                }
                component.set('v.escalationFormFields', escalationFormFields);
                component.set('v.deviceList', deviceList);
                component.set('v.onlineorAppVersionList', onlineorAppVersionList);
                component.set('v.browserUsedList', browserUsedList);

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);

    },
    
    getAffectsVersion: function (component) {
        var action = component.get("c.getAffectsVersionList");
        action.setParams({ "productName": component.get("v.simpleNewCase.ProductName__c") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var affectsVersion = response.getReturnValue();
                var affectsVersionArray = [];
                for (var i = 0; i < affectsVersion.length; i++) {
                    affectsVersionArray.push(affectsVersion[i].Affects_Version__c);
                }
                component.set("v.affectsVersionList", affectsVersionArray);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getSubtype: function (component, idx) {
        var record = component.get("v.simpleNewCase");
        var currentControllingField;
        if (idx > 1) {
            currentControllingField = "subType" + (idx - 1);
            $A.util.removeClass(component.find("subType" + idx + "SelectFormElement"), "is-required slds-has-error lightningInput");
        }
        else currentControllingField = "product0126A000000hC35QAE";
        if (component.find(currentControllingField).get("v.value") != "Please Specify") {
            var q = "";
            var c = "";
            if (idx > 1) {
                for (var j = 1; j < idx; j++) {
                    c += " and SubType" + j + "__c='" + component.find("subType" + j).get("v.value") + "'";
                }
            }
            var controllingField = component.find("product0126A000000hC35QAE").get("v.value");
            q = "select SubType" + idx + "__c  from CSM_QI_Case_Categorization__c where RecordTypeId__c='" + record.RecordTypeId + "' and Active__c=true and ProductName__c ='" + controllingField + "'" + c + " group by SubType" + idx + "__c";
            var action = component.get("c.getCategorizationWithAggregate");
            action.setParams({ "q": q });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var subtypeList = response.getReturnValue();
                    var subtypeArray = [];
                    var subtype;
                    for (var i = 0; i < Object.keys(subtypeList).length; i++) {
                        subtype = subtypeList[i]["SubType" + idx + "__c"];
                        if (subtype != undefined) subtypeArray.push({ class: "optionClass", label: subtype, value: subtype });
                        else subtypeArray.push({ class: "optionClass", label: "none", value: "Please Specify" });
                    }
                    for (var i = 0; i < subtypeArray.length; i++) {
                        if (subtypeArray[i].value === "Please Specify") {
                            subtypeArray.unshift(subtypeArray[i]);
                            subtypeArray.splice(i + 1, 1);
                        }
                    }
                    component.find("subType" + idx).set("v.options", subtypeArray);
                    component.find("subType" + idx).set("v.value", "Please Specify");
                    component.set("v.isDependentSubType" + idx + "Disable", false);
                    component.set("v.simpleNewCase.SubType" + idx + "__c", component.find("subType" + idx).get("v.value"));

                    if (idx < 3) this.getSubtype(component, idx + 1);
                    else {
                        this.getCategorizationId(component);
                        component.set("v.isLoading", false);
                    }

                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log(errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.isDependentSubType" + idx + "Disable", true);
            component.find("subType" + idx).set("v.options", { class: "optionClass", label: "Please Specify", value: "Please Specify" });
            if (idx < 3) this.getSubtype(component, idx + 1);
            else {
                this.getCategorizationId(component);
                component.set("v.isLoading", false);
            }
        }
    },

    searchFor: function (component) {
        var searchText = component.get("v.simpleNewCase.Subject");
        var productName = component.get("v.simpleNewCase.ProductName__c");
        var communityOrigin = component.get("v.communityOrigin");
        console.log('Search text ' + searchText);
        if (communityOrigin == 'Partner Portal') {
            var action = component.get('c.searchForPRMIds');
        }
        else {
            if (searchText === "" || searchText === null || productName === null || communityOrigin !== "Customer Portal") return;
            var action = component.get('c.searchForIds');
        }
        component.set("v.isLoading3", true);
        action.setParams({
            searchText: searchText,
            productName: productName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var results = response.getReturnValue();
                var articleRecords = [];
                var getUrl = window.location;
                var siteUrl = getUrl.protocol + "//" + getUrl.host + $A.get("$Site.siteUrlPrefix");
                if (Object.keys(results).length > 0) {
                    results.forEach(result => {
                        result.sobj.fieldUrl = siteUrl + "/kb?u=" + result.sobj.UrlName;
                        articleRecords.push(result.sobj);
                    });
                }
                component.set("v.articleDatas", articleRecords);
            } else {
                console.log(response.getError());
            }
            component.set("v.isLoading3", false);
        });
        $A.enqueueAction(action);
    },

    getCategorizationId: function (component) {
        component.set("v.isLoading", true);
        var recordId = component.get("v.simpleNewCase.RecordTypeId");
        var productName = component.find("product" + recordId).get("v.value");
        var subtype1 = component.find("subType1").get("v.value");
        var subtype2 = component.find("subType2").get("v.value");
        var subtype3 = component.find("subType3").get("v.value");
        var action = component.get("c.getCategorizationId");
        action.setParams({
            "productName":productName,
            "subtype1": subtype1,
            "subtype2": subtype2,
            "subtype3": subtype3
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue().length > 0) {
                    component.set("v.simpleNewCase.Case_Type__c", response.getReturnValue()[0].CaseType__c);
                    component.set("v.simpleNewCase.Case_CategorizationId__c", response.getReturnValue()[0].Id);
                }
                component.set("v.isLoading", false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(JSON.stringify(errors));
                component.set("v.isLoading", false);
            }

        });
        $A.enqueueAction(action);
    },

    openModal: function (component, suffixId) {
        $A.util.removeClass(component.find("modaldialog_" + suffixId), "slds-fade-in-hide");
        $A.util.addClass(component.find("modaldialog_" + suffixId), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop_" + suffixId), "slds-backdrop--hide");
        $A.util.addClass(component.find("backdrop_" + suffixId), "slds-backdrop--open");
    },
    closeModal: function (component, suffixId) {
        $A.util.addClass(component.find("modaldialog_" + suffixId), "slds-fade-in-hide");
        $A.util.removeClass(component.find("modaldialog_" + suffixId), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop_" + suffixId), "slds-backdrop--hide");
        $A.util.removeClass(component.find("backdrop_" + suffixId), "slds-backdrop--open");
    },
                        
   saveTechnologySolutionsForm :function (component) {
        var action = component.get("c.saveTechnologySolutionsForm");
        action.setParams({
            "caseId": component.get('v.newCaseId'),
            "onlineorAppVersion" : component.get('v.sltOnlineorAppVersion'),
            "browserUsed" : component.get('v.sltBrowserUsed'), 
            "iOSVersion" : component.get('v.formIOSVersion'), 
            "noUsersImpacted" : component.get('v.formNumberOfUsersImpacted'), 
            "username" : component.get('v.formUsername')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
            } else if (state === "ERROR") {
                var errors = response.getError();
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    notifyCaseOriginatorForAttachment: function (component) {
        var caseId = component.get('v.newCaseId');
        var action = component.get("c.sendAttachmentEmailToCaseOriginator");
        action.setParams({
            caseId: caseId,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error("Error to notify Case Originator for Attachment:", errors);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    checkAssetSubtype: function (component) {
        var recordId = component.get("v.simpleNewCase.RecordTypeId");
        var subType2  = component.find("subType2").get("v.value");
        var product  = component.find("product" + recordId).get("v.value");
        console.log(product,subType2);
        if (product === 'HCPO Engagement Management' && subType2 === 'Service Catalog') {
            this.openModal(component, "warningMessageAssetSubtype");
        }
    },

    createContentDocumentLink: function(component) {
        var contentDocumentIds = component.get('v.contentDocumentIds');
        var caseId = component.get('v.newCaseId');
        var action = component.get("c.createContentDocumentLink");
        action.setParams({
            "contentDocumentIds": contentDocumentIds,
            "parentId": caseId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.notifyCaseOriginatorForAttachment(component);
            } else {
                console.error("Error creating ContentDocumentLinks:", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getHospitalList: function (component) {
        var account = component.get("v.account").Name;
    
        const MOA_hospitalOptions = [
            { label: "Please Specify", value: "" },
            { label: "HAIL GENERAL HOSPITAL - MOH", value: "HAIL GENERAL HOSPITAL - MOH" },
            { label: "Al-Ghazalah General Hospital - MOH", value: "Al-Ghazalah General Hospital - MOH" },
            { label: "Al-Shannan General Hospital - MOH", value: "Al-Shannan General Hospital - MOH" },
            { label: "Baqaa General Hospital - MOH", value: "Baqaa General Hospital - MOH" },
            { label: "Abu Ajram General Hospital - MOH", value: "Abu Ajram General Hospital - MOH" },
            { label: "Miqua General Hospital - MOH", value: "Miqua General Hospital - MOH" },
            { label: "Hagl General Hospital - MOH", value: "Hagl General Hospital - MOH" },
            { label: "AlBad General Hospital - MOH", value: "AlBad General Hospital - MOH" },
            { label: "Al-Shamly General Hospital - MOH", value: "Al-Shamly General Hospital - MOH" },
            { label: "Al-Suliamy General Hospital - MOH", value: "Al-Suliamy General Hospital - MOH" },
            { label: "Moqeq General Hospital - MOH", value: "Moqeq General Hospital - MOH" },
            { label: "Abu Rakah General Hospital - MOH", value: "Abu Rakah General Hospital - MOH" },
            { label: "Alwajh General Hospital - MOH", value: "Alwajh General Hospital - MOH" },
            { label: "Al Hadithah General Hospital - MOH", value: "Al Hadithah General Hospital - MOH" },
            { label: "Domat Al-Jandal General Hospital - MOH", value: "Domat Al-Jandal General Hospital - MOH" },
            { label: "Sharaf Hospital - MOH", value: "Sharaf Hospital - MOH" },
            { label: "Tabarjal General Hospital - MOH", value: "Tabarjal General Hospital - MOH" },
            { label: "Ashwaq Hospital - MOH", value: "Ashwaq Hospital - MOH" },
            { label: "TaymaaÂ General Hospital - MOH", value: "TaymaaÂ General Hospital - MOH" },
            { label: "Mental Health Hospital - MOH", value: "Mental Health Hospital - MOH" },
            { label: "Mental Health and Recovery in Jouf - MOH", value: "Mental Health and Recovery in Jouf - MOH" },
            { label: "King Abdulaziz Specialist Hospital - MOH", value: "King Abdulaziz Specialist Hospital - MOH" },
            { label: "Samira General Hospital - MOH", value: "Samira General Hospital - MOH" },
            { label: "Al Hayit Hospital - MOH", value: "Al Hayit Hospital - MOH" },
            { label: "King Abdulaziz Specialty Hospital - MOH", value: "King Abdulaziz Specialty Hospital - MOH" },
            { label: "King Khalid Hospital - Hail N4", value: "King Khalid Hospital - Hail N4" },
            { label: "Aja Hospital for Long Care and Medical Rehabilitation - Hail N4", value: "Aja Hospital for Long Care and Medical Rehabilitation - Hail N4" },
            { label: "Maternity and Children's Hospital - Hail N4", value: "Maternity and Children's Hospital - Hail N4" },
            { label: "Specialized Ophthalmology Center - Hail N4", value: "Specialized Ophthalmology Center - Hail N4" },
            { label: "Prince Metaab Bin AbdelAziz Hospital - Jouf N3", value: "Prince Metaab Bin AbdelAziz Hospital - Jouf N3" },
            { label: "Specialized Clinics Center in Al-Jouf - Jouf N3", value: "Specialized Clinics Center in Al-Jouf - Jouf N3" },
            { label: "Al Qurayyat General Hospital - Jouf N3", value: "Al Qurayyat General Hospital - Jouf N3" },
            { label: "Qurayyat Mental Health Hospital - Jouf N3", value: "Qurayyat Mental Health Hospital - Jouf N3" },
            { label: "Maternity and Children Hospital - Jouf N3", value: "Maternity and Children Hospital - Jouf N3" },
            { label: "King Faisal Hospital - Jouf N3", value: "King Faisal Hospital - Jouf N3" },
            { label: "Maternity and Children's Hospital - Tabuk N2", value: "Maternity and Children's Hospital - Tabuk N2" },
            { label: "King Khaled Hospital - Tabuk N2", value: "King Khaled Hospital - Tabuk N2" },
            { label: "King Fahd Specialist Hospital - Tabuk N2", value: "King Fahd Specialist Hospital - Tabuk N2" },
            { label: "Duba General Hospital - Tabuk N2", value: "Duba General Hospital - Tabuk N2" },
            { label: "All N2", value: "All N2" },
            { label: "All N3", value: "All N3" },
            { label: "All N4", value: "All N4" }
        ];
    
        const KINGSAUD_hospitalOptions = [
            { label: "Please Specify", value: "" },
            { label: "King Saud Medical City", value: "King Saud Medical City" },
            { label: "Al-Iman General Hospital - R1Exp", value: "Al-Iman General Hospital - R1Exp" },
            { label: "Imam Abdulrahman Al-Faisal Hospital - R1Exp", value: "Imam Abdulrahman Al-Faisal Hospital - R1Exp" },
            { label: "The Long Care hospital - R1Exp", value: "The Long Care hospital - R1Exp" },
            { label: "King Salman Hospital in Riyadh - R1Exp", value: "King Salman Hospital in Riyadh - R1Exp" },
            { label: "King Khalid Hospital and Prince Sultan Center for Health Services - R1Exp", value: "King Khalid Hospital and Prince Sultan Center for Health Services - R1Exp" },
            { label: "Al-Quwayiyah General Hospital - R1Exp", value: "Al-Quwayiyah General Hospital - R1Exp" },
            { label: "Wadi Al-Dawasir General Hospital - R1Exp", value: "Wadi Al-Dawasir General Hospital - R1Exp" },
            { label: "Mental health hospital in Al-Kharj - R2Exp", value: "Mental health hospital in Al-Kharj - R2Exp" },
            { label: "Children and Delivery Hospital Kharj - R2Exp", value: "Children and Delivery Hospital Kharj - R2Exp" },
            { label: "Aflaj Hospital - R2Exp", value: "Aflaj Hospital - R2Exp" },
            { label: "Hotat Tamem Hospital - R2Exp", value: "Hotat Tamem Hospital - R2Exp" },
            { label: "Sulayil Hospital - R2Exp", value: "Sulayil Hospital - R2Exp" },
            { label: "Rewaydat Alard Hospital - R2Exp", value: "Rewaydat Alard Hospital - R2Exp" },
            { label: "Muzahmia Hospital - R2Exp", value: "Muzahmia Hospital - R2Exp" },
            { label: "Prince Salman Bin Mohammed General Hospital Dalam - R2Exp", value: "Prince Salman Bin Mohammed General Hospital Dalam - R2Exp" },
            { label: "Alhareq Hospital - R2Exp", value: "Alhareq Hospital - R2Exp" },
            { label: "Khasra Hospital - R2Exp", value: "Khasra Hospital - R2Exp" },
            { label: "Alrean Hospital - R2Exp", value: "Alrean Hospital - R2Exp" }
        ];
    
        var hospitalOptions = [];
    
        if (account === "MOH  [SA]") {
            hospitalOptions = MOA_hospitalOptions;
        } else if (account === "KING SAUD MEDICAL CITY  [SA]") {
            hospitalOptions = KINGSAUD_hospitalOptions;
        } else {
            hospitalOptions = [{ label: "Please Specify", value: "" }];
        }
    
        component.set("v.hospitalOptions", hospitalOptions);
    }    
})
