({
    doInit: function (component, event, helper) {
        console.log("init categorisation");
        component.set("v.errors", []);
        helper.getRecord(component);
    },



    onControllingFieldChange: function (component, event, helper) {
        var record = component.get("v.simpleRecord");
        var objName = component.get("v.sObjectName");
        if (record != undefined) {
            if (component.get("v.pillar") != component.get("v.pillarDataName")) {
                helper.getSubtype(component, 1);
                if (record.RecordTypeId == component.get("v.TechnoRecordTypeId")) {
                    helper.getAffectsVersion(component);
                }
                if (objName === "Knowledge__kav") {
                    helper.getKnowledgeArticleChapter(component);
                }
            } else if (record.RecordTypeId == component.get("v.RDActivityPlanRecordTypeId")) {
                helper.getTemplate(component);
            } else if (record.RecordTypeName__c === component.get("v.DataCreateName")) {
                helper.getSubtype(component, 1);
                helper.getCreateAdditionalInfos(component);
            }
        }
    },

    onProductChange: function (component, event, helper) {
        helper.getSubtype1_v2(component);
    },

    onSubType1Change: function (component, event, helper) {
        helper.getSubtype(component, 2);
    },

    onSubType2Change: function (component, event, helper) {
        var record = component.get("v.simpleRecord");
        helper.getSubtype(component, 3);
        if (record.RecordTypeName__c === component.get("v.DataCreateName")) {
            helper.getMediaDates(component);
            helper.getCreateAdditionalInfos(component);
        }
    },

    onSubType3Change: function (component, event, helper) {
        var record = component.get("v.simpleRecord");
        var subtype3 = event.getSource().get("v.value");
        if (record.RecordTypeName__c === component.get("v.DataCreateName") && (subtype3 === 'Insync' || subtype3 === 'Shared')) {
            component.set("v.otherAuditsAndTheirFrequenciesRequired", true);
        } else {
            component.set("v.otherAuditsAndTheirFrequenciesRequired", false);
        }
    },

    closeForm: function (component, event, helper) {
        helper.closeForm(component);
    },

    openForm: function (component, event, helper) {
        helper.getRecord(component);
        helper.openForm(component);
    },

    onSubmit: function (component, event, helper) {
        var record = component.get("v.simpleRecord");
        var objName = component.get("v.sObjectName");
        if ((record.RecordTypeId == component.get("v.DataRecordTypeId") && record.AccountCountry__c == "BR" && component.find("controllingField").get("v.value") == "Please Specify")) {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "title": $A.get("$Label.c.Categorization"),
                "message": $A.get("$Label.c.Please_select_the_Asset")
            });
            resultsToast.fire();
        } else if ((component.get("v.isMandatory") == true)
            && ((record.RecordTypeId != component.get("v.DataRecordTypeId") && component.find("controllingField").get("v.value") == "Please Specify")
                || (component.find("subType1").get("v.value") == "Please Specify")
                || (component.find("subType2").get("v.value") == "Please Specify")
                || ((record.RecordTypeId == component.get("v.DataRecordTypeId") || record.RecordTypeName__c == component.get("v.RDCTP")) && component.find("subType3") != null && component.find("subType3").get("v.value") == "Please Specify")
            )) {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "title": $A.get("$Label.c.Categorization"),
                "message": $A.get("$Label.c.Please_fill_all_fields_in_the_categorization_form")
            });
            resultsToast.fire();
        } else if ((record.RecordTypeId == component.get("v.RDActivityPlanRecordTypeId")) && (record.ContactId == undefined)) {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "title": $A.get("$Label.c.Categorization"),
                "message": $A.get("$Label.c.Please_select_a_Contact_Name")
            });
            resultsToast.fire();
        } else if (record.RecordTypeName__c == component.get("v.DataCreateName") && component.get("v.reasonforLateRequestReRunRequired") && (!component.find("ReasonforLateRequestReRun").get("v.value") || component.find("ReasonforLateRequestReRun").get("v.value") === '')) {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "title": $A.get("$Label.c.Categorization"),
                "message": "Please select a Reason for Late Request Re Run"
            });
            resultsToast.fire();
        } else if (record.RecordTypeName__c == component.get("v.DataCreateName") && component.get("v.otherAuditsAndTheirFrequenciesRequired") && (!component.find("OtherAuditsAndTheirFrequencies").get("v.value") || component.find("OtherAuditsAndTheirFrequencies").get("v.value") === '')) {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "title": $A.get("$Label.c.Categorization"),
                "message": "Please select a Other audits and their frequencies"
            });
            resultsToast.fire();
        } else if (objName === "Knowledge__kav" &&
            record.Pillar__c === 'Technology Solutions' &&
            component.find("controllingField").get("v.value") != "Please Specify" &&
            (
                component.find("subType1").get("v.value") == "Please Specify" ||
                component.find("subType2").get("v.value") == "Please Specify" ||
                ((component.find("controllingField").get("v.value") === 'OCE Personal' || component.find("controllingField").get("v.value") === 'OCE Digital') && (component.find("subType3").get("v.value") == "Please Specify"))
            )
        ) {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "title": $A.get("$Label.c.Categorization"),
                "message": $A.get("$Label.c.Please_fill_all_fields_in_the_categorization_form")
            });
            resultsToast.fire();
        }
        else {
            helper.updateObjectCategorization(component);
        }
    },

    hideErrors: function (component, event, helper) {
        component.set("v.errors", null);
    },

    handleAdditionalInfoSubmit: function (component, event, helper) {
        const fieldsData = event.getParam('data');
        component.set("v.createAdditionalInfoData", fieldsData);
    },

    handleAdditionalInfoCancel: function (component, event, helper) {
       component.find("subType2").set("v.value") == "Please Specify";
    },

    handleMediaDateChange: function (component, event, helper) {
        var record = component.get("v.simpleRecord");
        var selectedMediaDateValue = event.getSource().get("v.value");
        var mediaDateOptions = component.get("v.mediaDateOptions");

        if (selectedMediaDateValue) {
            var selectedMediaDate = mediaDateOptions.find(function (option) {
                return option.Media_Date__c === selectedMediaDateValue;
            });

            if (selectedMediaDate) {
                var maintDueDate = new Date(selectedMediaDate.Maint_Due_Date__c);
                var createdDate = new Date(record.CreatedDate);
                if (maintDueDate < createdDate) {
                    component.set("v.reasonforLateRequestReRunRequired", true);
                    var reasonforLateRequestReRun = component.find("ReasonforLateRequestReRun");
                    if (reasonforLateRequestReRun) {
                        var options = reasonforLateRequestReRun.get("v.options");
                        if (!options || options.length === 0) {
                            helper.getReasonforLateRequestReRunOptions(component);
                        }
                    }
                } else {
                    component.set("v.reasonforLateRequestReRunRequired", false);
                    var reasonforLateRequestReRun = component.find("ReasonforLateRequestReRun");
                    if (reasonforLateRequestReRun) {
                        reasonforLateRequestReRun.set("v.value", null);
                    }
                }
                component.set("v.mediaDateDetail", selectedMediaDate);
            } else {
                component.set("v.mediaDateDetail", null);
            }
        } else {
            component.set("v.mediaDateDetail", null);
        }
    }

})