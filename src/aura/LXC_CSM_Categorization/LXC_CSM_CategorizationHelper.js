({
    getRecord: function (component) {
        component.set("v.isLoading", true);
        var recordId = component.get("v.recordId");
        var objName = component.get("v.sObjectName");
        var action = component.get("c.getRecord");
        action.setParams({
            "recordId": recordId,
            "objName": objName,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var object = response.getReturnValue()[0];
                if (object != undefined) {
                    component.set("v.showEditButton", true);
                    component.set("v.object", object);
                    component.set("v.simpleRecord", object);
                    if (objName === "Knowledge__kav") {
                        if (component.get("v.simpleRecord").Pillar__c != null) {
                            component.set("v.pillar", component.get("v.simpleRecord").Pillar__c);
                            this.mustHideEdit(component);
                            this.getControllingField(component);
                            this.getKnowledgeArticleChapter(component);
                        } else {
                            var errors = [];
                            errors.push($A.get("$Label.c.Please_select_a_pillar"));
                            component.set("v.errors", errors);
                            component.set("v.showEditButton", false);
                            component.set("v.isLoading", false);
                        }

                    } else if (object.RecordTypeId == component.get("v.TechnoRecordTypeId") && (objName === "Case")) {
                        if (object.AccountId == undefined) {
                            var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                "type": "warning",
                                "title": $A.get("$Label.c.Categorization"),
                                "message": $A.get("$Label.c.Please_select_the_Account_Name")
                            });
                            var errors = [];
                            errors.push($A.get("$Label.c.Please_select_the_Account_Name"));
                            component.set("v.errors", errors);
                        }
                        component.set("v.pillar", component.get("v.pillarTechnoName"));
                        this.getControllingField(component);
                        this.getCaseArticles(component);
                        this.mustForceToFill(component);
                        this.mustHideEdit(component);
                        this.getActiveTimeSheetRecord(component);
                    }
                    else if (object.RecordTypeName__c == component.get("v.RDCTP") || object.RecordTypeName__c == component.get("v.RDCDP") || object.RecordTypeName__c == component.get("v.RDVirtualTrialsCase") || (object.RecordTypeId == component.get("v.RDAssistReqRecordTypeId")) || (object.RecordTypeId == component.get("v.RDActivityPlanRecordTypeId"))) {
                        component.set("v.pillar", component.get("v.pillarRDName"));
                        this.getControllingField(component);
                        if (object.RecordTypeId == component.get("v.RDActivityPlanRecordTypeId")) {
                            //this.fetchPicklistValues(component, 'LOS__c', 'Template__c');
                            this.getTemplate(component);
                        }
                        if (object.RecordTypeName__c == component.get("v.RDCTP")) {
                            this.mustForceToFill(component);
                        }
                    }  else if (object.RecordTypeId == component.get("v.DataRecordTypeId") || object.RecordTypeName__c == component.get("v.DataCreateName")) {
                         component.set("v.pillar", component.get("v.pillarDataName"));
                        if(object.RecordTypeName__c == component.get("v.DataCreateName")){
                            var dueDate = new Date(object.DueDate__c);
                            var createdDate = new Date(object.CreatedDate);

                            var mediaDateDetail = {
                                Maint_Due_Date__c: object.DueDate__c ? object.DueDate__c : null,
                                Media_Date__c: object.Media_Date__c ? object.Media_Date__c : null,
                                Media_Date_Label__c: object.Media_Date_Label__c ? object.Media_Date_Label__c : null,
                                Download_Date__c: object.Media_Download_Date__c ? object.Media_Download_Date__c : null
                            };
                            
                            component.set("v.mediaDateDetail", mediaDateDetail);
                            if (dueDate < createdDate) {
                                component.set("v.reasonforLateRequestReRunRequired", true);
                                this.getReasonforLateRequestReRunOptions(component);
                            }
                            if(object.SubType3__c === 'Insync' || object.SubType3__c === 'Shared') {
                                component.set("v.otherAuditsAndTheirFrequenciesRequired", true);
                                var otherAuditsAndTheirFrequencies = object.Other_audits_and_their_frequencies__c ? object.Other_audits_and_their_frequencies__c : ''; 
                                component.find("OtherAuditsAndTheirFrequencies").set("v.value", otherAuditsAndTheirFrequencies);
                            }
                        }
                        this.getControllingField(component);
                        setTimeout($A.getCallback(() => {
                            this.mustForceToFill(component);
                        }), 0);
                        this.mustHideEdit(component);
                    }
                    else if (objName == "CSM_QI_CaseAutomationScheduler__c") {
                        if (object.Pillar__c == 'Technology Solutions') {
                            component.set("v.pillar", component.get("v.pillarTechnoName"));
                            this.getControllingField(component);
                            //this.getCaseArticles(component);
                            //this.mustForceToFill(component);
                            //this.mustHideEdit(component);
                            //this.getActiveTimeSheetRecord(component);
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    getControllingField: function (component) {
        var objName = component.get("v.sObjectName");
        var record = component.get("v.simpleRecord");
        var action;
        var field;
        if (component.get("v.pillarTechnoName") === component.get("v.pillar")) {
            component.find("controllingField").set("v.label", "Product");
            field = "ProductName__c";
            if (objName === "Case") {
                action = component.get("c.getProductCategorizationForCase");
                action.setParams({ "recordId": record.Id, "pillar": component.get("v.pillar") });
            } else if (objName === "Knowledge__kav") {
                action = component.get("c.getProductCategorization");
                action.setParams({ "pillar": record.Pillar__c });
            } else if (objName === "CSM_QI_CaseAutomationScheduler__c") {
                action = component.get("c.getProductCategorizationForAutomation");
                action.setParams({ "recordId": record.Id, "pillar": record.Pillar__c });
            }
        } else if (component.get("v.pillar") == component.get("v.pillarRDName")) {
            component.find("controllingField").set("v.label", "LOS");
            field = "LOS__c";
            var recordTypeCond = '';
            if (objName === "Case")
                recordTypeCond = " and RecordTypeId__c='" + record.RecordTypeId + "'";
            action = component.get("c.getCategorizationWithAggregate");
            action.setParams({
                "q": "select " + field + "  from CSM_QI_Case_Categorization__c where Pillar__c='" + component.get("v.pillar") + "' and Active__c=true" + recordTypeCond + " group by " + field
            });
        } else if (component.get("v.pillarDataName") === component.get("v.pillar")) {
            component.find("controllingField").set("v.label", "Asset");
            field = "ProductName__c";
            if (objName === "Case") {
                action = component.get("c.getProductCategorizationForCase");
                action.setParams({ "recordId": record.Id, "pillar": component.get("v.pillar") });
            } else if (objName === "Knowledge__kav") {
                action = component.get("c.getProductCategorization");
                action.setParams({ "pillar": record.Pillar__c });
            }
        }
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var controllingFieldList = response.getReturnValue();
                var controllingFieldArray = [];
                controllingFieldArray.push({
                    class: "optionClass",
                    label: "Please Specify",
                    value: "Please Specify"
                })
                for (var i = 0; i < Object.keys(controllingFieldList).length; i++) {
                    var value;
                    if (controllingFieldList[i].hasOwnProperty("Name")) {
                        value = controllingFieldList[i].Name;
                    } else { value = controllingFieldList[i][field]; }
                    if (value != undefined) controllingFieldArray.push({ class: "optionClass", label: value, value: value });
                }
                component.find("controllingField").set("v.options", controllingFieldArray);
                if (record[field] == undefined) component.find("controllingField").set("v.value", "Please Specify");
                else component.find("controllingField").set("v.value", record[field]);
                this.getSubtype(component, 1);
                if (record.RecordTypeId == component.get("v.TechnoRecordTypeId")) {
                    this.getAffectsVersion(component);
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
    },

    getSubtype: function (component, idx) {
        var objName = component.get("v.sObjectName");
        var record = component.get("v.simpleRecord");
        var currentControllingField;
        var recordTypeCond = '';
        if (idx > 1) {
            currentControllingField = "subType" + (idx - 1);
        } else {
            currentControllingField = "controllingField";
            if(record.RecordTypeName__c === component.get("v.DataCreateName")){
                component.find("subType1").set("v.label", "Weekly/Monthly");
                component.find("subType2").set("v.label", "Extract");
                if(component.find("subType3")) {
                    component.find("subType3").set("v.label", "Market Type");
                }
            } else {
                component.find("subType1").set("v.label", $A.get("$Label.c.Sub_Type")+1);
                component.find("subType2").set("v.label", $A.get("$Label.c.Sub_Type")+2);
                component.find("subType3").set("v.label", $A.get("$Label.c.Sub_Type")+3);
            }
        }
        if (component.find(currentControllingField).get("v.value") != "Please Specify" || component.get("v.pillarDataName") === component.get("v.pillar")) {
            var q = "";
            var c = "";
            if (idx > 1) {
                for (var j = 1; j < idx; j++) {
                    c += " and SubType" + j + "__c='" + component.find("subType" + j).get("v.value") + "'";
                }
            }
            var controllingField = component.find("controllingField").get("v.value");
            // if (objName === "Knowledge__kav") q = "select SubType" + idx + "__c  from CSM_QI_Case_Categorization__c where Active__c=true and ProductName__c ='" + controllingField + "'" + c + " group by SubType" + idx + "__c";
            //else 
            if (component.get("v.pillar") == component.get("v.pillarTechnoName")) q = "select SubType" + idx + "__c  from CSM_QI_Case_Categorization__c where Type__c = 'Categorization' and Pillar__c='" + component.get("v.pillar") + "' and Active__c=true and ProductName__c ='" + controllingField + "'" + c + " group by SubType" + idx + "__c";
            else if (component.get("v.pillar") == component.get("v.pillarRDName")) {
                if (objName === "Case")
                    recordTypeCond = " and RecordTypeId__c='" + record.RecordTypeId + "'";
                q = "select SubType" + idx + "__c  from CSM_QI_Case_Categorization__c where Type__c = 'Categorization' and Pillar__c='" + component.get("v.pillar") + "' and Active__c=true and LOS__c ='" + controllingField + "'" + c + recordTypeCond + " group by SubType" + idx + "__c";
            }
            else if (component.get("v.pillar") == component.get("v.pillarDataName")) {
                if (objName === "Case") {
                    recordTypeCond = " and RecordTypeId__c='" + record.RecordTypeId + "'";
                }
                if(record.RecordTypeName__c === component.get("v.DataCreateName") && (objName === "Case")){
                    q = "select SubType" + idx + "__c  from CSM_QI_Case_Categorization__c where Type__c = 'Categorization' and Pillar__c='" + component.get("v.pillar") + "' and Active__c=true and ProductName__c ='" + controllingField + "'" + c + recordTypeCond + " group by SubType" + idx + "__c";
                } else {
                    q = "select SubType" + idx + "__c  from CSM_QI_Case_Categorization__c where Type__c = 'Categorization' and Product__c = null and Pillar__c='" + component.get("v.pillar") + "' and Active__c=true " + c + recordTypeCond + " group by SubType" + idx + "__c";
                }
            }
            
            var action = component.get("c.getCategorizationWithAggregate");
            action.setParams({
                "q": q
            });
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
                    if (component.find("subType" + idx)){
                        component.find("subType" + idx).set("v.options", subtypeArray);
                        component.find("subType" + idx).set("v.value", "Please Specify");
                        for (var i = 0; i < subtypeArray.length; i++) {
                            if (subtypeArray[i].value === record["SubType" + idx + "__c"]) {
                                component.find("subType" + idx).set("v.value", record["SubType" + idx + "__c"]);
                            }

                        }
                    }
                    component.set("v.isDependentSubType" + idx + "Disable", false);

                    if (idx < 3) this.getSubtype(component, idx + 1);
                    else component.set("v.isLoading", false);

                    if (record.RecordTypeName__c === component.get("v.DataCreateName") && idx === 2) {
                        this.getMediaDates(component);
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
            if(component.find("subType" + idx)) {
                component.find("subType" + idx).set("v.options", { class: "optionClass", label: "Please Specify", value: "Please Specify" });
            }
            if (idx < 3) this.getSubtype(component, idx + 1);
            else component.set("v.isLoading", false);
        }
    },

    getTemplateOld: function (component) {
        var controllerValueKey = component.find("controllingField").get("v.value");
        var Map = component.get("v.dependentFieldMap");
        if (controllerValueKey != 'Please Specify') {
            var ListOfDependentFields = Map[controllerValueKey];
            this.fetchDepValues(component, ListOfDependentFields);
        } else {
            var defaultVal = [{
                class: "optionClass",
                label: 'Please Specify',
                value: 'Please Specify'
            }];
            component.find('template').set("v.options", defaultVal);
            component.set("v.isDependentDisable", true);
        }
        var record = component.get("v.simpleRecord");
        if (record.Template__c) component.find("template").set("v.value", record.Template__c);
    },


    getTemplate: function (component) {
        var controllingField = component.find("controllingField").get("v.value");
        var action = component.get("c.getTemplate");
        action.setParams({
            "contrField": controllingField
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var templateList = response.getReturnValue();
                var templateArray = [];
                var template;
                templateArray.push({ class: "optionClass", label: "Please Specify", value: "Please Specify" });
                for (var i = 0; i < Object.keys(templateList).length; i++) {
                    template = templateList[i];
                    if (template != undefined) templateArray.push({ class: "optionClass", label: template, value: template });
                }
                component.find("template").set("v.options", templateArray);
                component.find("template").set("v.value", "Please Specify");

                var record = component.get("v.simpleRecord");
                if (record.Template__c) component.find("template").set("v.value", record.Template__c);
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
    },

    getKnowledgeArticleChapter: function (component) {
        var objName = component.get("v.sObjectName");
        var record = component.get("v.simpleRecord");
        var controllingField = component.find("controllingField").get("v.value");
        var action = component.get("c.getKnowledgeArticleChapterList");
        action.setParams({
            "contrField": controllingField
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var ArticleChapterList = response.getReturnValue();
                var ArticleChapterArray = [];
                var ArticleChapter;
                for (var i = 0; i < Object.keys(ArticleChapterList).length; i++) {
                    ArticleChapter = ArticleChapterList[i];
                    if (ArticleChapter != undefined) ArticleChapterArray.push({ class: "optionClass", label: ArticleChapter, value: ArticleChapter });
                    else ArticleChapterArray.push({ class: "optionClass", label: "Please Specify", value: "Please Specify" });
                }

                ArticleChapterArray.push({ class: "optionClass", label: "Please Specify", value: "Please Specify" });

                for (var i = 0; i < ArticleChapterArray.length; i++) {
                    if (ArticleChapterArray[i].value === "Please Specify") {
                        ArticleChapterArray.unshift(ArticleChapterArray[i]);
                        ArticleChapterArray.splice(i + 1, 1);
                    }
                }

                component.find("ArticleChapter").set("v.options", ArticleChapterArray);
                component.find("ArticleChapter").set("v.value", "Please Specify");
                component.set("v.isDependentArticleDisable", false);
                if (ArticleChapterList.length == 0) {
                    var defaultVal = [{ class: "optionClass", label: 'Please Specify', value: 'Please Specify' }];
                    component.find('ArticleChapter').set("v.options", defaultVal);
                    component.find("ArticleChapter").set("v.value", "Please Specify");
                    component.set("v.isDependentArticleDisable", true);
                }

                if (ArticleChapterList.length == 1 && component.get("v.pillar") == component.get("v.pillarRDName")) {
                    ArticleChapter = ArticleChapterList[0];
                    var defaultVal = [{ class: "optionClass", label: ArticleChapter, value: ArticleChapter }];
                    component.find('ArticleChapter').set("v.options", defaultVal);
                    component.find("ArticleChapter").set("v.value", ArticleChapter);
                    component.set("v.isDependentArticleDisable", true);
                }

                var record = component.get("v.simpleRecord");
                if (record.Article_Chapter__c) component.find("ArticleChapter").set("v.value", record.Article_Chapter__c);
            } else if (state === "ERROR") {
                component.find("ArticleChapter").set("v.value", "Please Specify");
                component.set("v.isDependentArticleDisable", false);
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

    },

    getCaseArticles: function (component) {
        var objName = component.get("v.sObjectName");
        var record = component.get("v.simpleRecord");
        if ((objName === "Case") && (component.get("v.pillar") == component.get("v.pillarTechnoName"))) {
            var recordId = component.get("v.recordId");
            var action = component.get("c.getCaseArticles");
            action.setParams({
                "caseId": recordId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var numberOfArticle = Object.keys(response.getReturnValue()).length;
                    var c = record;
                    if (numberOfArticle != c.Number_of_Article__c) {
                        c.Number_of_Article__c = numberOfArticle;
                        if (c.Status !== 'Closed' || c.Status !== 'Canceled' || c.Status !== 'Abandoned') {
                            this.updateCase(component);
                        }
                    }
                    var caseArticle = response.getReturnValue()[0];
                    component.set("v.caseArticle", caseArticle);
                    if (caseArticle != undefined) {
                        var recordId = caseArticle.KnowledgeArticleVersionId;
                        var objName = "Knowledge__kav";
                        var action2 = component.get("c.getRecord");
                        action2.setParams({
                            "recordId": recordId,
                            "objName": objName
                        });
                        action2.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var k = response.getReturnValue()[0];
                                var c = component.get("v.simpleRecord");
                                if (k.ProductName__c != undefined) {
                                    component.find("controllingField").set("v.value", k.ProductName__c);
                                    component.find("subType1").set("v.value", k.SubType1__c);
                                    component.find("subType2").set("v.value", k.SubType2__c);

                                    var kb_subtype3;
                                    if (k.SubType3__c == undefined) {
                                        if (k.ProductName__c == "OCE Digital" || k.ProductName__c == "OCE Personal" || k.ProductName__c == "OCE Marketing" || k.ProductName__c == "OCE Sales" || k.ProductName__c == "IQVIA MDM-Product" || k.ProductName__c == "IQVIA MDM-Customer" || k.ProductName__c == "IQVIA CDW" || k.ProductName__c == "Reltio MDM" || k.ProductName__c == "Customer Data Platform") kb_subtype3 = "Please Specify";
                                        else kb_subtype3 = "--none--";
                                    }
                                    else kb_subtype3 = k.SubType3__c;
                                    component.find("subType3").set("v.value", kb_subtype3);

                                    if ((k.ProductName__c != c.ProductName__c) ||
                                        (k.SubType1__c != c.SubType1__c) ||
                                        (k.SubType2__c != c.SubType2__c) ||
                                        (kb_subtype3 != c.SubType3__c)) {
                                        component.set("v.showEditButton", false);
                                        component.find("controllingField").set("v.options", { class: "optionClass", label: k.ProductName__c, value: k.ProductName__c });
                                        component.find("controllingField").set("v.value", k.ProductName__c);
                                        component.find("subType3").set("v.options", { class: "optionClass", label: kb_subtype3, value: kb_subtype3 });
                                        component.find("subType3").set("v.value", kb_subtype3);
                                        component.find("subType2").set("v.options", { class: "optionClass", label: k.SubType2__c, value: k.SubType2__c });
                                        component.find("subType2").set("v.value", k.SubType2__c);
                                        component.find("subType1").set("v.options", { class: "optionClass", label: k.SubType1__c, value: k.SubType1__c });
                                        component.find("subType1").set("v.value", k.SubType1__c);
                                        if (c.Status !== 'Closed' || c.Status !== 'Canceled' || c.Status !== 'Abandoned') {
                                            this.updateObjectCategorization(component);
                                        }
                                    } else if ((component.find("controllingField").get("v.value") == k.ProductName__c)) {
                                        component.set("v.showEditButton", false);
                                        component.set("v.isLoading", false);
                                    } else {
                                        component.set("v.showEditButton", true);
                                        component.set("v.isLoading", false);
                                    }
                                } else {
                                    component.set("v.showEditButton", true);
                                    component.set("v.isLoading", false);
                                }
                            }
                            //this.updateCaseCountArticle(component);
                        });
                        $A.enqueueAction(action2);

                    } else {
                        //this.getControllingField(component);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    mustHideEdit: function (component) {
        var objName = component.get("v.sObjectName");
        if (objName === "Knowledge__kav") {
            var k = component.get("v.object");
            if (k.PublishStatus != 'Draft') component.set("v.showEditButton", false);
        } else if (objName === "Case") {
            var c = component.get("v.object");
            if (c.Status === 'Closed' || c.Status === 'Canceled' || c.Status === 'Abandoned') component.set("v.showEditButton", false);
        }
    },

    mustForceToFill: function (component) {
        var objName = component.get("v.sObjectName");
        var record = component.get("v.simpleRecord");
        var recordName = record.RecordTypeName__c;
        if (objName === "Case") {
            var c = component.get("v.object");
            var createdDate = new Date(c.CreatedDate);
            var closedDate = new Date(c.ClosedDate);
            var today = new Date();
            var accountCountry = c.AccountCountry__c;
            if ((component.get("v.pillar") == component.get("v.pillarDataName") ||recordName == component.get("v.RDCTP") ) 
                && (c.SubType1__c == undefined || c.SubType2__c == undefined || (component.find("subType3") && c.SubType3__c == undefined) || c.SubType1__c == "Please Specify" || c.SubType2__c == "Please Specify" || (component.find("subType3") && c.SubType3__c == "Please Specify") 
                || (component.get("v.pillar") == component.get("v.pillarDataName") && component.find("subType3") && c.SubType3__c == "--none--"))
            ) {
                this.openForm(component);
                if ((today.getTime() - createdDate.getTime()) < 30000)
                    component.set("v.isMandatory", true);
            } else if (((closedDate.getTime() === createdDate.getTime()))
                && ((c.ProductName__c == undefined)
                    || (c.SubType1__c == "Please Specify")
                    || (c.SubType2__c == "Please Specify")
                    || (component.find("subType3") && c.SubType3__c == "Please Specify"))
                && (accountCountry != "US")) {
                    this.openForm(component);
                    component.set("v.isMandatory", true);
            } else if ((((today.getTime() - createdDate.getTime()) < 10000)
                && (c.ProductName__c == undefined)
                && (accountCountry != "US"))) {
                    this.openForm(component);
            }
        }
    },

    updateCase: function (component) {
        var c = component.get("v.object");
        var action = component.get("c.updateCase");
        action.setParams({
            "c": c
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            }
        });
        $A.enqueueAction(action);
    },

    updateObjectCategorization: function (component) {
        component.set("v.isLoading2", true);
        var record = component.get("v.simpleRecord");
        var objName = component.get("v.sObjectName");
        var controllingField = component.find("controllingField").get("v.value");
        var subtype1 = component.find("subType1").get("v.value");
        var subtype2 = component.find("subType2").get("v.value");
        if(component.find("subType3")) {
            var subtype3 = component.find("subType3").get("v.value");
        } else {
            var subtype3 = "Please Specify";
        }
        var pillar = component.get("v.pillar");
        var AffectsVersion = '';
        var mediaDateDetail = component.get("v.mediaDateDetail");
        if (record.RecordTypeId == component.get("v.TechnoRecordTypeId")) {
            AffectsVersion = component.find("AffectsVersion").get("v.value");
        }
        var ArticleChapter = '';
        if (objName === "Knowledge__kav") {
            ArticleChapter = component.find("ArticleChapter").get("v.value");
        }
        var template = "";
        if (record.RecordTypeId == component.get("v.RDActivityPlanRecordTypeId")) {
            template = component.find("template").get("v.value");
            if (template == "Please Specify") template = "";
        }
        var reasonforLateRequestReRun = null;
        if (component.get("v.reasonforLateRequestReRunRequired")) {
            reasonforLateRequestReRun = component.find("ReasonforLateRequestReRun").get("v.value");
        }
        var otherAuditsAndTheirFrequencies = '';
        if (component.get("v.otherAuditsAndTheirFrequenciesRequired")) {
            otherAuditsAndTheirFrequencies = component.find("OtherAuditsAndTheirFrequencies").get("v.value");
        }
        var createAdditionalInfoJson = '';
        if (component.get("v.createAdditionalInfoData")) {
            createAdditionalInfoJson = component.get("v.createAdditionalInfoData");
        }
        var action = component.get("c.updateObjectCategorization");
        action.setParams({
            "objectToUpdate": record,
            "controllingField": controllingField,
            "subtype1": subtype1,
            "subtype2": subtype2,
            "subtype3": subtype3,
            "template": template,
            "pillar": pillar,
            "ArticleChapter": ArticleChapter,
            "AffectsVersion": AffectsVersion,
            "mediaDateDetail": mediaDateDetail,
            "reasonforLateRequestReRun": reasonforLateRequestReRun,
            "otherAuditsAndTheirFrequencies": otherAuditsAndTheirFrequencies,
            "createAdditionalInfoJson": createAdditionalInfoJson

        });
        action.setCallback(this, function (response) {
            component.set("v.isLoading2", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("[LXC_CSM_Categorization] Save SUCCESS...");
                if (component.get("v.isMandatory") == true) {
                    component.set("v.isMandatory", false);
                }
                this.closeForm(component);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": $A.get("$Label.c.Saved"),
                    "message": $A.get("$Label.c.The_categorization_was_saved")
                });
                resultsToast.fire();
                $A.get("e.force:refreshView").fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                //alert(JSON.stringify(errors));
                if (errors.length > 0) {
                    if (errors[0] != null && errors[0].message != null) {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type": "error",
                            "title": $A.get("$Label.c.Error"),
                            "message": errors[0].message
                        });
                        resultsToast.fire();
                        $A.get("e.force:refreshView").fire();
                    } else if (errors[0] != null && errors[0].pageErrors[0] != null && errors[0].pageErrors[0].message != null) {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type": "error",
                            "title": $A.get("$Label.c.Error"),
                            "message": errors[0].pageErrors[0].message
                        });
                        resultsToast.fire();
                        $A.get("e.force:refreshView").fire();
                    }
                } else {
                    console.log("Unknown error");
                }

            }
        });
        $A.enqueueAction(action);
    },


    fetchPicklistValues: function (component, controllerField, dependentField) {
        var action = component.get("c.getDependentOptionsImpl");
        action.setParams({
            'objApiName': "Case",
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var StoreResponse = response.getReturnValue();
                component.set("v.dependentFieldMap", StoreResponse);
                var listOfkeys = [];
                var ControllerField = [];

                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }

                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push({
                        class: "optionClass",
                        label: "Please Specify",
                        value: "Please Specify"
                    });
                }

                this.getTemplate(component);
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push({
                        class: "optionClass",
                        label: listOfkeys[i],
                        value: listOfkeys[i]
                    });
                }
            }
        });
        $A.enqueueAction(action);
    },

    fetchDepValues: function (component, ListOfDependentFields) {
        var dependentFields = [];
        if (ListOfDependentFields != undefined) {
            dependentFields.push({
                class: "optionClass",
                label: "Please Specify",
                value: "Please Specify"
            });

            for (var i = 0; i < ListOfDependentFields.length; i++) {
                dependentFields.push({
                    class: "optionClass",
                    label: ListOfDependentFields[i],
                    value: ListOfDependentFields[i]
                });
            }
            component.find('template').set("v.options", dependentFields);
            component.set("v.isDependentDisable", false);
        }
    },

    openForm: function (component) {
        $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-hide");
        $A.util.addClass(component.find("modaldialog"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop--hide");
        $A.util.addClass(component.find("backdrop"), "slds-backdrop--open");

    },

    closeForm: function (component) {
        $A.util.addClass(component.find("modaldialog"), "slds-fade-in-hide");
        $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop"), "slds-backdrop--hide");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop--open");
    },

    getActiveTimeSheetRecord: function (component) {
        var record = component.get("v.simpleRecord");
        var action = component.get("c.getTimeSheetRecord");
        action.setParams({
            "caseId": record.Id,
        });
        action.setCallback(this, function (response) {
            component.set("v.isLoading2", false);
            var state = response.getState();
            var TimeSheet = response.getReturnValue();
            if (state === "SUCCESS") {
                if (TimeSheet != undefined && record.Id == TimeSheet.Case__c) {

                    var actionAPI = component.find("quickActionAPI");
                    var fields = { "sObj": "Case" };
                    var args = {
                        actionName: "Case.Time_Sheet_LC",
                        entityName: "Case",
                        targetFields: fields
                    };
                    actionAPI.setActionFieldValues(args).then(function () {
                        actionAPI.invokeAction(args);
                    }).catch(function (e) {
                    });
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors.length > 0) {
                    if (errors[0] != null && errors[0].message != null) {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type": "error",
                            "title": $A.get("$Label.c.Error"),
                            "message": errors[0].message
                        });
                        resultsToast.fire();
                    } else if (errors[0] != null && errors[0].pageErrors[0] != null && errors[0].pageErrors[0].message != null) {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type": "error",
                            "title": $A.get("$Label.c.Error"),
                            "message": errors[0].pageErrors[0].message
                        });
                        resultsToast.fire();
                    }
                } else {
                    console.log("Unknown error");
                }

            }
        });
        $A.enqueueAction(action);
    },

    getAffectsVersion: function (component) {
        var controllingField = component.find("controllingField").get("v.value");
        console.log('controllingField', controllingField);
        var action = component.get("c.getAffectsVersion");
        action.setParams({
            "contrField": controllingField
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var AffectsVersionList = response.getReturnValue();
                var AffectsVersionArray = [];
                var AffectsVersion;
                AffectsVersionArray.push({ class: "optionClass", label: "Please Specify", value: "Please Specify" });
                for (var i = 0; i < Object.keys(AffectsVersionList).length; i++) {
                    AffectsVersion = AffectsVersionList[i];
                    if (AffectsVersion != undefined) AffectsVersionArray.push({ class: "optionClass", label: AffectsVersion, value: AffectsVersion });
                }
                component.find("AffectsVersion").set("v.options", AffectsVersionArray);
                component.find("AffectsVersion").set("v.value", "Please Specify");

                var record = component.get("v.simpleRecord");
                if (record.Affects_Version__c) component.find("AffectsVersion").set("v.value", record.Affects_Version__c);
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
    },

    getMediaDates: function(component) {
        var productName = component.find("controllingField").get("v.value");
        var subType1 = component.find("subType1").get("v.value");
        var subType2 = component.find("subType2").get("v.value");
        var action = component.get("c.getMediaDates");
        action.setParams({
            product: productName,
            subtype1: subType1,
            subtype2: subType2
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mediaDateOptions = response.getReturnValue();
                component.set("v.mediaDateOptions", mediaDateOptions);
                var mediaDateArray = [];
                mediaDateArray.push({ class: "optionClass", label: "Please Specify", value: "Please Specify" });
                for (var i = 0; i < Object.keys(mediaDateOptions).length; i++) {
                    mediaDateArray.push({ class: "optionClass", label: mediaDateOptions[i].Media_Date_Label__c, value: mediaDateOptions[i].Media_Date__c });
                }
                component.find("MediaDate").set("v.options", mediaDateArray);
                component.find("MediaDate").set("v.value", "Please Specify");
                var mediaDateLabel = component.get("v.simpleRecord").Media_Date_Label__c;
                if (mediaDateLabel) {
                    var mediaDateOptions = component.get("v.mediaDateOptions");
                    for (var i = 0; i < mediaDateOptions.length; i++) {
                        if (mediaDateOptions[i].Media_Date_Label__c === mediaDateLabel) {
                            component.find("MediaDate").set("v.value", mediaDateOptions[i].Media_Date__c);
                            break;
                        }
                    }
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
    },

    getReasonforLateRequestReRunOptions: function(component) {
        component.set("v.isLoading2", true);
        var record = component.get("v.simpleRecord");
        var action = component.get("c.getReasonLateList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var picklistValues = response.getReturnValue();
                var options = [];
                options.push({
                    class: "optionClass",
                    label: "Please Specify",
                    value: null
                });

                picklistValues.forEach(function(p) {
                    options.push({
                        class: "optionClass",
                        label: p.label,
                        value: p.value
                    });
                });
                component.find("ReasonforLateRequestReRun").set("v.options", options);
                component.find("ReasonforLateRequestReRun").set("v.value", null);                
                if (record.Reason_for_Late_Request_Re_Run__c) {
                    component.find("ReasonforLateRequestReRun").set("v.value", record.Reason_for_Late_Request_Re_Run__c);
                }
                component.set("v.isLoading2", false);
            }  else if (state === "ERROR") {
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

    getCreateAdditionalInfos: function(component) {
        var record = component.get("v.simpleRecord");
        var subType2 = component.find("subType2").get("v.value")
        var maintenanceType = record.Maintenance_Type__c;
        var assetName = component.find("controllingField").get("v.value");
        var lwcComponent = component.find("createAdditionalInfo");
        lwcComponent.set("v.subtype2", subType2);
        lwcComponent.set("v.assetName", assetName);
        lwcComponent.set("v.maintenanceType", maintenanceType);
    }
    
})
