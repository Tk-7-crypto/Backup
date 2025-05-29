({
    doInit: function (component, event, helper) {
        component.set('v.articleColumns', [
            {
                label: $A.get("$Label.c.Title"), fieldName: 'fieldUrl', type: 'url',
                typeAttributes: { label: { fieldName: 'Title' }, target: '_blank' }
            },
            { label: $A.get("$Label.c.Published_Date"), fieldName: 'LastPublishedDate', type: 'date', initialWidth: 200 }
        ]);
        component.find("caseRecordCreator").getNewRecord(
            "Case",
            null,
            false,
            $A.getCallback(function () {
                var rec = component.get("v.newCase");
                var error = component.get("v.newCaseError");
                var locale = $A.get("$Locale.language");
                component.set("v.locale_language", locale);

                if (error || (rec === null)) return;
                helper.getUserAccount(component);
                helper.getUserContact(component);
                /** helper.getPriority(component);*/
                helper.getUrgency(component);
                helper.getImpact(component);
                helper.getEnvironment(component);
                component.set("v.simpleNewCase.UrgentForCustomer__c", false);
            })
        );
    },
    prioritychange: function (component, event, helper) {
        helper.getPriority(component);
    },

    portalCaseTypeChange: function (component, event, helper) {
        if (event.getParam('value') == 'Technology Solutions') {
            component.set("v.simpleNewCase.RecordTypeId", "0126A000000hC35QAE");
            helper.getProducts(component);
            helper.getCountryRequester(component);
            helper.getEscalationFormFields(component);
            component.set("v.simpleNewCase.Urgency__c", "Low");
            component.set("v.simpleNewCase.Techno_Impact__c", "Low");
        } else if (event.getParam('value') == 'Information Offering') {
            component.set("v.simpleNewCase.RecordTypeId", "0126A000000hC33QAE");
            var account = component.get("v.account");
            if (account.AccountCountry__c != 'US') {
                helper.getCountryRequester(component);
            }
            helper.getProducts(component);
            //else helper.getUserAssetsForDATA(component);
            component.set("v.simpleNewCase.Priority", "Low");
            component.set("v.simpleNewCase.Urgency__c", "");
            component.set("v.simpleNewCase.Techno_Impact__c", "");
            helper.getPickListOptions(component, "Metric__c", "v.metrics");
            component.set("v.showHospitalField", false)
        }
    },
    /*
        onProductChangeUS: function (component, event, helper) {
            component.set("v.productSelectError", false);
            var assetIds = component.get("v.assets");
            var recordId = component.get("v.simpleNewCase.RecordTypeId");
            var assetId = component.get("v.simpleNewCase.AssetId");
    
            for (var i = 0; i < assetIds.length; i++) {
                if (assetIds[i].value == assetId) {
                    component.set("v.simpleNewCase.ProductName__c", assetIds[i].label);
                    break;
                }
            }
        },
    */
    onProductChange: function (component, event, helper) {
        component.set("v.productSelectError", false);
        var assetIds = component.get("v.assetIds");
        var recordId = component.get("v.simpleNewCase.RecordTypeId");
        var assetId = component.find("product" + recordId).get("v.value");
        var showTechnoSubtypes = false;
        var subtypeMandatory = false;
        var attachmentMandatory = false;
        var disableCSHP1CaseCreationByAsset = false;
        for (var i = 0; i < assetIds.length; i++) {
            if (assetIds[i].label == assetId) {
                component.set("v.simpleNewCase.AssetId", assetIds[i].value);
                component.set("v.simpleNewCase.ProductName__c", assetIds[i].label);
                showTechnoSubtypes = assetIds[i].enableSubtype_1_2_3;
                subtypeMandatory = assetIds[i].subtypeMandatory;
                disableCSHP1CaseCreationByAsset = assetIds[i].disableCSHP1CaseCreation;
                attachmentMandatory = assetIds[i].attachmentMandatory;
                break;
            }
        }
        var DATA_Global_Support = component.get("v.account").DATA_Global_Support_CSH_Form__c;
        if (DATA_Global_Support && recordId === "0126A000000hC33QAE") {
            var dataGlobalSupportCaseCategories = [];
            if (assetId != 'Please Specify') {
                helper.getCategorizationForDataGlobalSupport(component, assetId, recordId)
                    .then(function (result) {
                        if (result.length > 0) {
                            component.set("v.isDATAGlobalSupportCSHForm", true);
                            var dataGlobalSupportCategoriesAllValues = { subtype1: [] };

                            for (var i = 0; i < result.length; i++) {
                                var subType1 = result[i].SubType1__c;
                                var subType2 = result[i].SubType2__c;
                                var subType3 = result[i].SubType3__c;

                                var subtype1Array = dataGlobalSupportCategoriesAllValues.subtype1;
                                var subtype1Object = subtype1Array.find(obj => obj.api === subType1);

                                if (!subtype1Object) {
                                    subtype1Object = { label: subType1, api: subType1, subtype2: [] };
                                    subtype1Array.push(subtype1Object);
                                }

                                if (subType2 !== "Please Specify") {
                                    var subtype2Array = subtype1Object.subtype2;
                                    var subtype2Object = subtype2Array.find(obj => obj.api === subType2);
                                
                                    if (!subtype2Object) {
                                      subtype2Object = { label: subType2, api: subType2, subtype3: [] };
                                      subtype2Array.push(subtype2Object);
                                    }
                                
                                    if (subType3 !== "Please Specify") {
                                      var subtype3Object = { label: subType3, api: subType3 };
                                      subtype2Object.subtype3.push(subtype3Object);
                                    }
                                }
                            }
                            for (let s1 in dataGlobalSupportCategoriesAllValues.subtype1) {
                                for (let s2 in dataGlobalSupportCategoriesAllValues.subtype1[s1].subtype2) {
                                    dataGlobalSupportCaseCategories.push(dataGlobalSupportCategoriesAllValues.subtype1[s1].subtype2[s2]);
                                }

                                component.set('v.dataGlobalSupportCategoriesAllValues', dataGlobalSupportCategoriesAllValues);
                            }
                            component.set('v.dataGlobalSupportCaseCategories', dataGlobalSupportCaseCategories);
                            component.set("v.disabledCaseCategories", false);

                        } else {
                            component.set("v.isDATAGlobalSupportCSHForm", false);
                        }

                    })
                    .catch(function (error) {
                        console.error(error);
                    });
            } else {
                component.set('v.dataGlobalSupportCaseCategories', dataGlobalSupportCaseCategories);
                component.set("v.disabledCaseCategories", true);
            }
        }
        $A.util.removeClass(component.find("productSelectFormElement" + recordId), "is-required slds-has-error lightningInput");
        if (component.find("product" + recordId).get("v.label") == "Please Specify") {
            component.set("v.productSelectError", true);
            $A.util.addClass(component.find("productSelectFormElement" + recordId), "is-required slds-has-error lightningInput");
        }
        component.set("v.showTechnoSubtypes", showTechnoSubtypes);
        component.set("v.subtypeMandatory", subtypeMandatory);
        component.set("v.showEscalationFormFields", false);
        component.set("v.disableCSHP1CaseCreationByAsset", disableCSHP1CaseCreationByAsset);
        component.set("v.attachmentMandatory", attachmentMandatory);
        if (recordId === "0126A000000hC35QAE") {
            helper.getUrgency(component);
            helper.getImpact(component);
            var account = component.get("v.account").Name;
            var product = component.get("v.simpleNewCase.ProductName__c");
            var showNoPersonalHealthDataCheckbox = false;
            var showHospitalField = false;
            if (product === 'IQVIA HIS') {
                showNoPersonalHealthDataCheckbox = true;
            }
            if (
                (account === 'MOH  [SA]' && product === 'IQVIA HIS') ||
                (account === 'KING SAUD MEDICAL CITY  [SA]' && product === 'IQVIA HIS')
            ) { 
                showHospitalField = true;
            }
            component.set("v.showNoPersonalHealthDataCheckbox", showNoPersonalHealthDataCheckbox);
            component.set("v.showHospitalField", showHospitalField);
            if (showHospitalField) {
                helper.getHospitalList(component);
            }
        }
        if (showTechnoSubtypes) {
            helper.getSubtype(component, 1);
            helper.getAffectsVersion(component);
        } else if (component.get("v.AccountCaseSubtype") && component.get("v.ContactUserType") == "HO User" && recordId != "0126A000000hC33QAE") {
            component.set("v.caseSubTypeSelectError", false);
            $A.util.removeClass(component.find("caseSubTypeSelectFormElement"), "is-required slds-has-error lightningInput");
            helper.getTechnoSubtype(component);
            helper.getAffectsVersion(component);
        }

        var productEnvironment = $A.get("$Label.c.CSH_Environment_Type_Product_Visibility");
        const productEnvironmentArray = productEnvironment.split(";");
        component.set("v.environmentIsVisible", productEnvironmentArray.includes(assetId));

        var productsAccessingDTMSInformation = component.get('v.productsAccessingDTMSInformation');
        component.set('v.showDTMSInformation', productsAccessingDTMSInformation.includes(component.get("v.simpleNewCase.ProductName__c")));
        if (assetId != "Please Specify") {
            helper.getCategorizationAndAsset(component);
            helper.searchFor(component);
            helper.checkAssetSubtype(component);
        }
    },

    onTechnoSubTypeChange: function (component, event, helper) {
        component.set("v.caseSubTypeSelectError", false);
        $A.util.removeClass(component.find("caseSubTypeSelectFormElement"), "is-required slds-has-error lightningInput");
        if (component.get("v.subtypeMandatory")) {
            if (component.find("caseSubType").get("v.value") == "Please Specify") {
                $A.util.addClass(component.find("caseSubTypeSelectFormElement"), "is-required slds-has-error lightningInput");
                component.set("v.caseSubTypeSelectError", true);
            }
        }
        helper.getCategorizationAndAsset(component).then(function (result) {
            var case_type = component.get("v.simpleNewCase.Case_Type__c");
            var showEscalationFormFields = false;
            var caseSub = component.find("caseSubType").get("v.value");
            if (component.get("v.AccountCaseSubtype") && component.get("v.ContactUserType") == "HO User" && case_type == "Incident"){
                var assetIds = component.get("v.assetIds");
                var assetId = component.get("v.simpleNewCase.ProductName__c");
                for (var i = 0; i < assetIds.length; i++) {
                    if (assetIds[i].label == assetId) {
                        showEscalationFormFields = assetIds[i].enableEscalationForm;
                        break;
                    }
                }
            }
            component.set("v.showEscalationFormFields", showEscalationFormFields);
        
        });
    },

    onSubType1Change: function (component, event, helper) {
        helper.getSubtype(component, 2);
        $A.util.removeClass(component.find("subType1SelectFormElement"), "is-required slds-has-error lightningInput");
        component.set("v.simpleNewCase.SubType1__c", component.find("subType1").get("v.value"));
        if (component.get("v.simpleNewCase.ProductName__c") == 'Cognos Reporting' || component.get("v.simpleNewCase.ProductName__c").startsWith('IVP') || component.get("v.simpleNewCase.ProductName__c").startsWith('Argus') || component.get("v.simpleNewCase.ProductName__c").startsWith('PVM') || component.get("v.simpleNewCase.ProductName__c").startsWith('PVQ') || component.get("v.simpleNewCase.ProductName__c").startsWith('OBIEE') || component.get("v.simpleNewCase.ProductName__c").startsWith('H&MS Database')) {
            if (component.get("v.simpleNewCase.SubType1__c") == 'Incident') {
                component.set("v.simpleNewCase.Service_Now_Type__c", 'Incident');
            } else if (component.get("v.simpleNewCase.SubType1__c") == 'Request') {
                component.set("v.simpleNewCase.Service_Now_Type__c", 'Service Request');
            }
        }
        var showEscalationFormFields = false;
        if (component.get("v.simpleNewCase.SubType1__c").startsWith('Incident')){
            var assetIds = component.get("v.assetIds");
            var assetId = component.get("v.simpleNewCase.ProductName__c");
            for (var i = 0; i < assetIds.length; i++) {
                if (assetIds[i].label == assetId) {
                    showEscalationFormFields = assetIds[i].enableEscalationForm;
                    break;
                }
            }
        }
        component.set("v.showEscalationFormFields", showEscalationFormFields);
    },
    onSubType2Change: function (component, event, helper) {
        helper.getSubtype(component, 3);
        $A.util.removeClass(component.find("subType2SelectFormElement"), "is-required slds-has-error lightningInput");
        component.set("v.simpleNewCase.SubType2__c", component.find("subType2").get("v.value"));
        helper.checkAssetSubtype(component);
    },
    onSubType3Change: function (component, event, helper) {
        $A.util.removeClass(component.find("subType3SelectFormElement"), "is-required slds-has-error lightningInput");
        component.set("v.simpleNewCase.SubType3__c", component.find("subType3").get("v.value"));
        helper.getCategorizationId(component);
    },
    onSimplePickListChange: function (component, event, helper) {
        component.set("v.simpleNewCase." + event.getSource().getLocalId(), event.getSource().get("v.value"));
    },

    onCaseCategoryChange: function (component, event, helper) {
        var selectedVal = component.get("v.simpleNewCase.SubType2__c");
        var isDATAGlobalSupportCSHForm = component.get("v.isDATAGlobalSupportCSHForm");
        if (selectedVal != "") {
            if (isDATAGlobalSupportCSHForm) {
                var dataGlobalSupportPbTypes = [];
                var dataGlobalSupportCategoriesAllValues = component.get('v.dataGlobalSupportCategoriesAllValues');
                for (let s1 in dataGlobalSupportCategoriesAllValues.subtype1) {
                    for (let s2 in dataGlobalSupportCategoriesAllValues.subtype1[s1].subtype2) {
                        if (dataGlobalSupportCategoriesAllValues.subtype1[s1].subtype2[s2].api === selectedVal) {
                            dataGlobalSupportPbTypes = dataGlobalSupportCategoriesAllValues.subtype1[s1].subtype2[s2].subtype3
                            break;
                        }
                    }
                }
                component.set("v.dataGlobalSupportPbTypes", dataGlobalSupportPbTypes);
            } else {
                var caseCategories = component.get("v.caseCategories");
                var index = caseCategories.map(function (e) { return e.api; }).indexOf(selectedVal);
                var pbTypesObj = caseCategories[index].pbTypesObj;
                component.set("v.pbTypesObj", pbTypesObj);
            }
            component.set("v.disabledProblem_Type", false);
        } else {
            component.set("v.simpleNewCase.SubType3__c", "");
            component.set("v.disabledProblem_Type", true);
        }
    },

    closeAttachmentForm: function (component, event, helper) {
        var message = "Your case is created";
        helper.closeModal(component, "caseCreateAttachment");
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "type": "success",
            "title": "Saved",
            "message": message
        });
        resultsToast.fire();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/case/" + component.get("v.simpleNewCase.Id")
        });
        urlEvent.fire();
    },

    openAttachmentForm: function (component, event, helper) {
        helper.openModal(component, "caseCreateAttachment");
    },

    confirmImpactUrgency_agree: function (component, event, helper) {
        helper.closeModal(component, "confirmImpactUrgency");
    },

    confirmImpactUrgency_disagree: function (component, event, helper) {
        helper.getUrgency(component);
        helper.getImpact(component);
        helper.closeModal(component, "confirmImpactUrgency");
    },

    onImpactUrgencyChange: function (component, event, helper) {
        if (component.get("v.isDisableCSHP1CaseCreation") == false && component.get("v.disableCSHP1CaseCreationByAsset") == false && component.get("v.simpleNewCase.Urgency__c") === 'High' && component.get("v.simpleNewCase.Techno_Impact__c") === 'Significant') {
            helper.openModal(component, "confirmImpactUrgency");
        } else if ((component.get("v.isDisableCSHP1CaseCreation") || component.get("v.disableCSHP1CaseCreationByAsset")) && component.get("v.communityOrigin") == 'Customer Portal') {
            var impactList = component.get('v.impactList');
            var urgencyList = component.get('v.urgencyList');
            if (!impactList.includes('Significant'))
                impactList.unshift('Significant');
            if (!urgencyList.includes('High'))
                urgencyList.unshift('High');
            if (component.get('v.simpleNewCase.Urgency__c') === 'High')
                impactList = impactList.filter(e => e !== 'Significant');
            if (component.get('v.simpleNewCase.Techno_Impact__c') === 'Significant')
                urgencyList = urgencyList.filter(e => e !== 'High');
            component.set('v.impactList', impactList);
            component.set('v.urgencyList', urgencyList);
        }
    },

    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var message = "";
        if (uploadedFiles.length == 1) message = uploadedFiles.length + " file was added to case"
        else if (uploadedFiles.length > 1) message = uploadedFiles.length + " files were added to case"
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "type": "success",
            "title": "Saved",
            "message": message
        });
        resultsToast.fire();
        helper.notifyCaseOriginatorForAttachment(component);
    },

    handleSaveCase: function (component, event, helper) {
        component.set("v.isLoading", true);
        if (helper.validateCaseForm(component)) {
            var assetId = component.get("v.simpleNewCase.AssetId");
            if ($A.util.isEmpty(assetId)) {
                component.set("v.isLoading", false);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": $A.get("$Label.c.Error"),
                    "mode": "sticky",
                    "message": $A.get("$Label.c.An_error_occurred_during_the_case_creation_process")
                });
                resultsToast.fire();
                return;
            }
            var recordTypeId = component.get("v.simpleNewCase.RecordTypeId");
            // PEP set the request origin
            component.set("v.simpleNewCase.Origin", component.get("v.communityOrigin"));
            if (recordTypeId === "0126A000000hC33QAE") {
                var isDATAGlobalSupportCSHForm = component.get("v.isDATAGlobalSupportCSHForm");
                if (isDATAGlobalSupportCSHForm) {
                    var dataGlobalSupportCategoriesAllValues = component.get('v.dataGlobalSupportCategoriesAllValues');
                    var subtype2 = component.get("v.simpleNewCase.SubType2__c");
                    for (let s1 in dataGlobalSupportCategoriesAllValues.subtype1) {
                        for (let s2 in dataGlobalSupportCategoriesAllValues.subtype1[s1].subtype2) {
                            if (dataGlobalSupportCategoriesAllValues.subtype1[s1].subtype2[s2].api === subtype2) {
                                component.set("v.simpleNewCase.SubType1__c", dataGlobalSupportCategoriesAllValues.subtype1[s1].api);
                                break;
                            }
                        }
                    }
                } else {
                    if (component.get("v.account.AccountCountry__c") != 'US') {
                        component.set("v.simpleNewCase.SubType1__c", "SERVICE");
                    } else {
                        component.set("v.simpleNewCase.SubType1__c", "DATA MGT/PRODUCTION");
                        component.set("v.simpleNewCase.SubType2__c", "DATA ISSUES");
                    }
                }
                component.set("v.simpleNewCase.UrgentForCustomer__c", false);
            } else if (recordTypeId === "0126A000000hC35QAE") {
                var showHospitalField = component.get("v.showHospitalField")
                if(showHospitalField){
                    var selectedHospital = component.get("v.selectedHospital");
                    var description = component.get("v.simpleNewCase.Description");
                    var updatedDescription = description + "\nHospital: " + selectedHospital;
                    component.set("v.simpleNewCase.Description", updatedDescription);
                }
            }
            component.find("caseRecordCreator").saveRecord(function (saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    component.set("v.newCaseId", component.get("v.simpleNewCase.Id"));
                    if(component.get("v.showEscalationFormFields")){
                        helper.saveTechnologySolutionsForm(component);
                    }
                    var contentDocumentIds = component.get('v.contentDocumentIds');
                    if (contentDocumentIds.length > 0) {
                        helper.createContentDocumentLink(component);
                    }
                    var urlEvent = $A.get("e.force:navigateToURL");
                    setTimeout(function() {
                        urlEvent.setParams({
                            "url": "/case/" + component.get("v.simpleNewCase.Id")
                        });
                        urlEvent.fire();
                    }, 500);
                    //helper.openModal(component, "caseCreateAttachment");
                } else if (saveResult.state === "INCOMPLETE") {
                    component.set("v.newCaseError", "You are offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    component.set("v.newCaseError", "Problem saving case, error: " + JSON.stringify(saveResult.error));
                } else {
                    component.set("v.newCaseError", "Unknown problem, state: " + saveResult.state + ", error: " + JSON.stringify(saveResult.error));
                }
                component.set("v.isLoading", false);
            });
        } else {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "title": $A.get("$Label.c.Error"),
                "mode": "sticky",
                "message": $A.get("$Label.c.One_or_more_field_is_required_to_save_the_case")
            });
            resultsToast.fire();
            component.set("v.isLoading", false);
        }
    },

    searchArtciles: function (component, event, helper) {
        helper.searchFor(component);
    },

    onUrgentforCustomerCheck: function (component, event) {
        var checkCmp = component.find("checkUrgentforCustomer");
        component.set("v.simpleNewCase.UrgentForCustomer__c", checkCmp.get("v.value"));

    },

    closeModalWarningMessageAssetSubtype: function (component, event, helper) {
        helper.closeModal(component, "warningMessageAssetSubtype");
    },

    handleContentDocumentAdded : function(component, event, helper) {
        const contentDocumentIds = event.getParam('data');
        const existingIds = component.get('v.contentDocumentIds') || [];
        component.set('v.contentDocumentIds', [...existingIds, ...contentDocumentIds]);
    },

    handleContentDocumentDeleted : function(component, event, helper) {
        const deletedId = event.getParam('data');
        const existingIds = component.get('v.contentDocumentIds') || [];
        const updatedIds = existingIds.filter(id => id !== deletedId);
        component.set('v.contentDocumentIds', updatedIds);
    }
})
