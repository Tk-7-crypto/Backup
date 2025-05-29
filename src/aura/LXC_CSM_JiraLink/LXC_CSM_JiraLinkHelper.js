({
    getCase: function (component) {
        var action = component.get("c.getCase");
        action.setParams({
            "caseId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue()[0] != undefined) {
                    var c = response.getReturnValue()[0];
                    component.set("v.case", c);
                    component.set("v.jiraCreateIssue.summary", c.Subject);
                    component.set("v.jiraCreateIssue.description", c.Description);
                    if (c.Status !== "Closed" && c.Status !== "Canceled" && c.Status !== "Abandoned") {
                        component.set("v.canEdit", true);
                    } else {
                        component.set("v.canEdit", false);
                    }
                    this.getJiraLink(component);
                }
            } else {
                console.log("[LXC_CSM_JiraLink] get Case result Error");
            }
        });
        $A.enqueueAction(action);
    },

    getJiraLink: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getJiraLink");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()[0] != undefined) {
                component.set("v.jiraLinkId", response.getReturnValue()[0].Id);
                component.find("jiraLinkRecord").reloadRecord(true);
                component.set("v.isLinked", true);
            } else {
                component.set("v.isLinked", false);
                component.find("jiraLinkRecord").getNewRecord(
                    "CSM_QI_JiraLink__c",
                    null,
                    false,
                    $A.getCallback(function () {
                        var rec = component.get("v.newJiraLink");
                        var error = component.get("v.newJiraLinkError");
                        if (error || (rec === null)) {
                            console.log("[LXC_CSM_JiraLink] Error initializing record Jira template: " + error);
                        } else {
                            component.set("v.simpleNewJiraLink.case_recordId__c", component.get("v.recordId"));
                        }
                    })
                );
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    getJiraBaseUrls: function (component) {
        var action = component.get("c.getJiraBaseUrls");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.jiraBaseUrls", response.getReturnValue());
                component.set("v.simpleNewJiraLink.jira_base_url__c", response.getReturnValue()[0]);
            } else {
                console.log("[LXC_CSM_JiraLink] Get Jira base url result ERROR ");
            }
        });
        $A.enqueueAction(action);
    },

    getJiraPriorities: function (component) {
        var action = component.get("c.getCalloutResponseContents");
        action.setParams({
            "url": component.get("v.simpleNewJiraLink.jira_base_url__c") + '/rest/api/2/priority'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (response.getReturnValue()[0] == "200") {
                    var jiraPrioritiesResult = JSON.parse("{\"priorities\":" + response.getReturnValue()[1] + "}");
                    component.set("v.jiraPriorities", jiraPrioritiesResult.priorities.reverse());
                    component.set("v.jiraCreateIssue.selectedjiraPriorityValue", component.get("v.jiraPriorities")[0].id);
                } else {
                    var jiraError = JSON.parse(response.getReturnValue()[1]);
                    console.log("[LXC_CSM_JiraLink] priorities Error: " + jiraError);
                }
            } else {
                console.log("[LXC_CSM_JiraLink] Error: " + response.getError()[0].message);
                var jiraError = JSON.parse('{"errorMessages":["Error to connect to ' + component.get("v.simpleNewJiraLink.jira_base_url__c") + ', contact your administrator"],"errors":{}}');
            }
        });
        $A.enqueueAction(action);
    },
    getJiraTransitions: function (component) {
        var action = component.get("c.getCalloutResponseContents");
        action.setParams({
            "url": component.get("v.simpleNewJiraLink.jira_base_url__c") + '/rest/api/2/issue/' + component.get("v.simpleNewJiraLink.jira_key__c") + '/transitions?expand=transitions.fields'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (response.getReturnValue()[0] == "200") {
                    var jiraTransitionsResult = JSON.parse(response.getReturnValue()[1]);
                    component.set("v.jiraTransitions", jiraTransitionsResult.transitions);
                } else {
                    var jiraError = JSON.parse(response.getReturnValue()[1]);
                    console.log("[LXC_CSM_JiraLink] get transitions Error: " + jiraError);
                }
            } else {
                console.log("[LXC_CSM_JiraLink] Error: " + response.getError()[0].message);
                var jiraError = JSON.parse('{"errorMessages":["Error to connect to ' + component.get("v.simpleNewJiraLink.jira_base_url__c") + ', contact your administrator"],"errors":{}}');
            }
        });
        $A.enqueueAction(action);
    },

    getProjects: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getCalloutResponseContents");
        action.setParams({
            "url": component.get("v.simpleNewJiraLink.jira_base_url__c") + '/rest/api/2/issue/createmeta'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (response.getReturnValue()[0] == "200") {
                    var jiraProjects = JSON.parse(response.getReturnValue()[1]);
                    component.set("v.jiraProjects", jiraProjects.projects);
                    component.set("v.jiraCreateIssue.selectedjiraProjectValue", 0);
                    this.getJiraIssueTypes(component);
                } else {
                    var jiraError = JSON.parse(response.getReturnValue()[1]);
                    console.log("[LXC_CSM_JiraLink] Get project Error: " + jiraError);
                }
            } else {
                console.log("[LXC_CSM_JiraLink] Error: " + response.getError()[0].message);
                var jiraError = JSON.parse('{"errorMessages":["Error to connect to ' + component.get("v.simpleNewJiraLink.jira_base_url__c") + ', contact your administrator"],"errors":{}}');
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    getJiraIssueTypes: function (component) {
        var jiraProjects = component.get("v.jiraProjects");
        var index = (component.get("v.jiraCreateIssue.selectedjiraProjectValue") != undefined ? component.get("v.jiraCreateIssue.selectedjiraProjectValue") : 0);
        component.set("v.jiraIssueTypes", jiraProjects[index].issuetypes);
        var jiraIssueTypes = component.get("v.jiraIssueTypes");
        component.set("v.jiraCreateIssue.selectedjiraIssueTypeValue", jiraIssueTypes[0].id);
        this.getJiraAvailableFields(component);
    },

    getJiraAvailableFields: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getCalloutResponseContents");
        var jiraProjects = component.get("v.jiraProjects");
        action.setParams({
            "url": component.get("v.simpleNewJiraLink.jira_base_url__c") + '/rest/api/2/issue/createmeta?projectKeys=' + jiraProjects[component.get("v.jiraCreateIssue.selectedjiraProjectValue")].key + '&issuetypeIds=' + component.get("v.jiraCreateIssue").selectedjiraIssueTypeValue + '&expand=projects.issuetypes.fields'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (response.getReturnValue()[0] == "200") {
                    component.set("v.jiraCustomerAvailable", false);
                    component.set("v.jiraCountryAvailable", false);
                    var c = component.get("v.case");
                    var createmeta = response.getReturnValue()[1];
                    if (createmeta.indexOf('{"type":"priority","system":"priority"}') !== -1) {
                        $A.util.removeClass(component.find("blockPriority"), "slds-hide");
                        component.set("v.jiraPrioritiesAvailable", true);
                    }
                    else {
                        $A.util.addClass(component.find("blockPriority"), "slds-hide");
                        component.set("v.jiraPrioritiesAvailable", false);
                    }

                    if (createmeta.indexOf('"customfield_14511"') !== -1) {
                        component.set("v.jiraCustomerAvailable", true);
                        var jsonCreatemeta = JSON.parse(createmeta);
                        var customers = jsonCreatemeta.projects[0].issuetypes[0].fields.customfield_14511.allowedValues;
                        component.set("v.jiraCustomers", customers);
                        for (var i in customers) {
                            if (customers[i].value.toUpperCase() == c.Account.Name.toUpperCase() || customers[i].value.toUpperCase() == c.Account.Name.substring(0, c.Account.Name.indexOf('[') - 1).toUpperCase()) {
                                component.set("v.jiraCreateIssue.selectedJiraCustomerValue", customers[i].id);
                            }
                        }
                    }
                    else {
                        component.set("v.jiraCustomerAvailable", false);
                    }

                    if (createmeta.indexOf('"customfield_14510"') !== -1) {
                        component.set("v.jiraCountryAvailable", true);
                        var jsonCreatemeta = JSON.parse(createmeta);
                        var countries = jsonCreatemeta.projects[0].issuetypes[0].fields.customfield_14510.allowedValues
                        component.set("v.jiraCountries", countries);
                        var action = component.get("c.getCountryLabelByCode");
                        action.setParams({
                            codeCountry: c.Account.AccountCountry__c
                        });
                        action.setCallback(this, function (response) {
                            var country = response.getReturnValue();
                            for (var i in countries) {
                                if (countries[i].value.toUpperCase() == country.toUpperCase()) {
                                    component.set("v.jiraCreateIssue.selectedJiraCountryValue", countries[i].id);
                                }
                            }
                        })
                        $A.enqueueAction(action);
                    }
                    else {
                        component.set("v.jiraCountryAvailable", false);
                    }

                    if (createmeta.indexOf('"customfield_16646"') !== -1) {
                        component.set("v.jiraPSAProjectAvailable", true);
                        component.set("v.jiraCreateIssue.PSAProject", c.PSACode__c);
                    } else component.set("v.jiraPSAProjectAvailable", false);

                    if (createmeta.indexOf('"system":"fixVersions"}') !== -1) {
                        $A.util.removeClass(component.find("blockFixVersion"), "slds-hide");
                        component.set("v.jiraFixVersionsAvailable", true);
                        var jsonCreatemeta = JSON.parse(createmeta);
                        component.set("v.jiraFixVersions", jsonCreatemeta.projects[0].issuetypes[0].fields.fixVersions.allowedValues);
                    }
                    else {
                        $A.util.addClass(component.find("blockFixVersion"), "slds-hide");
                        component.set("v.jiraFixVersionsAvailable", false);
                    }
                } else {
                    $A.util.addClass(component.find("blockPriority"), "slds-hide");
                    component.set("v.jiraPrioritiesAvailable", false);
                    var jiraError = JSON.parse(response.getReturnValue()[1]);
                    console.log("[LXC_CSM_JiraLink] Get getJiraAvailableFields result Error: " + jiraError.message);
                }
            } else {
                console.log("[LXC_CSM_JiraLink] Get getJiraAvailableFields result Error: " + response.getError()[0].message);
                var jiraError = JSON.parse('{"errorMessages":["Error to connect to ' + component.get("v.simpleNewJiraLink.jira_base_url__c") + ', contact your administrator"],"errors":{}}');
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    createJiraIssue: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.postCalloutResponseContents");
        var jiraProjects = component.get("v.jiraProjects");
        var JSONString = '{"fields": {"project": {         "key": "' + jiraProjects[component.get("v.jiraCreateIssue.selectedjiraProjectValue")].key + '"     },     "summary": "' + this.escape(component.get("v.jiraCreateIssue").summary) + '",     "description": "' + this.escape(component.get("v.jiraCreateIssue").description) + '",     "issuetype": {"id": "' + component.get("v.jiraCreateIssue").selectedjiraIssueTypeValue + '"} ';
        if (component.get("v.jiraPrioritiesAvailable")) JSONString += ',"priority": {"id": "' + component.get("v.jiraCreateIssue").selectedjiraPriorityValue + '"}';
        if (component.get("v.jiraCountryAvailable")) JSONString += ',"customfield_14510": {"id": "' + component.get("v.jiraCreateIssue").selectedJiraCountryValue + '"}';
        if (component.get("v.jiraCustomerAvailable")) JSONString += ',"customfield_14511": {"id": "' + component.get("v.jiraCreateIssue").selectedJiraCustomerValue + '"}';
        if (component.get("v.jiraPSAProjectAvailable")) JSONString += ',"customfield_16646": "' + component.get("v.jiraCreateIssue").PSAProject + '"';
        //if(component.get("v.jiraFixVersionsAvailable") && component.get("v.jiraCreateIssue").selectedjiraFixVersionsValue != "")JSONString+=',"fixVersions": [{"id": "'+component.get("v.jiraCreateIssue").selectedjiraFixVersionsValue+'"}]';
        JSONString += '}}';
        action.setParams({
            "url": component.get("v.simpleNewJiraLink.jira_base_url__c") + '/rest/api/2/issue/',
            "JSONString": JSONString
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (response.getReturnValue()[0] == "201") {
                    var jiraLink = component.get("v.simpleNewJiraLink");
                    jiraLink.jira_key__c = JSON.parse(response.getReturnValue()[1]).key;
                    this.linkJiraIssue(component, true);
                } else {
                    var jiraError = JSON.parse(response.getReturnValue()[1]);
                    console.log(jiraError);
                    if (jiraError.errorMessages[0]) this.toast("error", "Jira Link Component", jiraError.errorMessages[0]);
                    else this.toast("error", "Jira Link Component", "A problem has occurred. It is possible that a required field is not implemented.");
                }
            } else {
                var jiraError = JSON.parse('{"errorMessages":["Error to connect to ' + component.get("v.simpleNewJiraLink.jira_base_url__c") + ', contact your administrator"],"errors":{}}');
                this.toast("error", "Jira Link Component", jiraError.errorMessages[0]);
            }
        });
        $A.enqueueAction(action);
    },

    linkJiraIssue: function (component, newLink) {
        component.set("v.isLoading", true);
        var jiraStatusUpdated = false;
        var action = component.get("c.getCalloutResponseContents");
        action.setParams({
            "url": component.get("v.simpleNewJiraLink.jira_base_url__c") + '/rest/api/2/issue/' + component.get("v.simpleNewJiraLink.jira_key__c") + '?expand=changelog'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (response.getReturnValue()[0] == "200") {
                    var fixVersions = "";
                    var returnValue = this.eliminateInvalidCharacter(response.getReturnValue()[1]);
                    component.set("v.simpleNewJiraLink.jiraFields", JSON.parse(returnValue).fields);
                    var changelog = JSON.parse(returnValue).changelog;
                    var fixVersionArray = JSON.parse(returnValue).fields.fixVersions;
                    if (fixVersionArray != undefined) {
                        for (var i in fixVersionArray)
                            fixVersions += fixVersionArray[i].name + ";";
                        fixVersions = fixVersions.substring(0, fixVersions.length - 1);
                    }
                    component.set("v.simpleNewJiraLink.fixVersions__c", fixVersions);
                    var attachments = "";
                    var attachmentArray = JSON.parse(returnValue).fields.attachment;
                    if (attachmentArray != undefined) {
                        for (var i = 0; i < Object.keys(attachmentArray).length; i++) {
                            attachmentArray[i].author = attachmentArray[i].author.displayName;
                        }
                        component.set("v.jiraAttachments", attachmentArray);
                    }

                    if (JSON.parse(returnValue).fields.customfield_14511 != null) component.set("v.simpleNewJiraLink.customer__c", JSON.parse(returnValue).fields.customfield_14511.value);
                    if (JSON.parse(returnValue).fields.customfield_14510 != null) component.set("v.simpleNewJiraLink.country__c", JSON.parse(returnValue).fields.customfield_14510.value);
                    if (JSON.parse(returnValue).fields.customfield_16646 != null) component.set("v.simpleNewJiraLink.PSA_Project__c", JSON.parse(returnValue).fields.customfield_16646);
                    if (JSON.parse(returnValue).fields.customfield_14449 != null) component.set("v.simpleNewJiraLink.due_date__c", JSON.parse(returnValue).fields.customfield_14449);
                    if (JSON.parse(returnValue).fields.customfield_10340 != null) {
                        var sprintName = JSON.parse(returnValue).fields.customfield_10340[0].split(",")[3].split("=")[1];
                        component.set("v.simpleNewJiraLink.Sprint__c", sprintName);
                    }
                    component.set("v.simpleNewJiraLink.summary__c", JSON.parse(returnValue).fields.summary);
                    component.set("v.simpleNewJiraLink.description__c", JSON.parse(returnValue).fields.description);
                    component.set("v.simpleNewJiraLink.Jira_Created_Date__c", JSON.parse(returnValue).fields.created);
                    component.set("v.simpleNewJiraLink.Jira_Updated_Date__c", JSON.parse(returnValue).fields.updated);
                    if (JSON.parse(returnValue).fields.priority != null) component.set("v.simpleNewJiraLink.priority__c", JSON.parse(returnValue).fields.priority.name);
                    if (component.get("v.simpleNewJiraLink.status__c") != JSON.parse(returnValue).fields.status.name) jiraStatusUpdated = true;
                    component.set("v.simpleNewJiraLink.status__c", JSON.parse(returnValue).fields.status.name);

                    if (JSON.parse(returnValue).fields.assignee != null) component.set("v.simpleNewJiraLink.assignee__c", JSON.parse(returnValue).fields.assignee.displayName);
                    else component.set("v.simpleNewJiraLink.assignee__c", "Unassigned");
                    component.set("v.simpleNewJiraLink.reporter__c", JSON.parse(returnValue).fields.reporter.displayName);
                    component.set("v.simpleNewJiraLink.issue_type__c", JSON.parse(returnValue).fields.issuetype.name);

                    if (changelog != undefined) {
                        var histories = changelog.histories;
                        var items = [];
                        if (histories != undefined) {
                            for (var i = 0; i < histories.length; i++) {
                                items.push(histories[i].items);
                            }
                            for (var i = 0; i < items.length; i++) {
                                if (items[i][0].field === 'Sprint') {
                                    component.set("v.simpleNewJiraLink.Sprint_Time_Stamp__c", histories[i].created);
                                }
                            }
                        }
                    }

                    var self = this;
                    component.find("jiraLinkRecord").saveRecord(function (saveResult) {
                        if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                            if (newLink) {
                                component.set("v.isLoading", true);
                                self.closeModal(component);
                                var jiraLink = component.get("v.simpleNewJiraLink");
                                var c = component.get("v.case");
                                if (c.Status !== "Closed" && c.Status !== "Canceled" && c.Status !== "Abandoned") {
                                    var action2 = component.get("c.updateCaseJiraIssue");
                                    action2.setParams({
                                        "caseId": component.get("v.recordId"),
                                        "jiraIssue": jiraLink.jira_key__c
                                    });
                                    action2.setCallback(this, function (response) {
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            if (newLink) {
                                                self.toast("success", "Jira Link Component", "The new JIRA link was saved.");
                                                self.getJiraLink(component);
                                            }
                                        } else if (state === "ERROR") {
                                            console.log("ERROR: " + JSON.stringify(response.getError()));
                                            self.toast("error", "Jira Link Component", "There is problem saving the JIRA link.");
                                        }
                                        component.set("v.isLoading", false);
                                    });
                                    $A.enqueueAction(action2);
                                }
                            }
                            if (jiraStatusUpdated) {
                                self.insertCaseComment(component);
                            }
                        } else {
                            self.toast("error", "Jira Link Component", "There is problem saving the JIRA link.");
                        }
                    });
                    this.getJiraTransitions(component);
                    this.getJiraComments(component);
                } else {
                    var returnValue = this.eliminateInvalidCharacter(response.getReturnValue()[1]);
                    var jiraError = JSON.parse(returnValue);
                    console.log("[LXC_CSM_JiraLink] Get issue from Jira Error: " + jiraError);
                    this.toast("error", "Jira Link Component", jiraError.errorMessages[0]);
                }
            } else {
                console.log("[LXC_CSM_JiraLink] Error: " + response.getError()[0].message);
                var jiraError = JSON.parse('{"errorMessages":["Error to connect to ' + component.get("v.simpleNewJiraLink.jira_base_url__c") + ', contact your administrator"],"errors":{}}');
                this.toast("error", "Jira Link Component", jiraError.errorMessages[0]);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    updateCaseJiraIssue: function (component) {


    },


    getJiraComments: function (component) {
        var action = component.get("c.getCalloutResponseContents");
        action.setParams({
            "url": component.get("v.simpleNewJiraLink.jira_base_url__c") + '/rest/api/2/issue/' + component.get("v.simpleNewJiraLink").jira_key__c + '/comment'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (response.getReturnValue()[0] == "200") {
                    var returnValue = this.eliminateInvalidCharacter(response.getReturnValue()[1]).replace(/24x24/g, "m24x24");
                    var jiraResult = JSON.parse(returnValue);
                    if (Object.keys(jiraResult.comments).length == 0) {
                        console.log("[LXC_CSM_JiraLink] There are no comments yet on this issue.");
                    } else {
                        this.upsertJiraLinkComments(component, jiraResult.comments);
                    }
                } else {
                    var returnValue = this.eliminateInvalidCharacter(response.getReturnValue()[1]);
                    var jiraError = JSON.parse(returnValue);
                    console.log("[LXC_CSM_JiraLink] Get Jira comments Error: " + jiraError);
                    this.toast("error", "Jira Link Component", jiraError);
                    component.set("v.isLoading", false);
                }
            } else {
                console.log("[LXC_CSM_JiraLink] Get Jira comments Error: " + response.getError()[0].message);
                var jiraError = JSON.parse('{"errorMessages":["Error to connect to ' + component.get("v.simpleNewJiraLink.jira_base_url__c") + ', contact your administrator"],"errors":{}}');
                this.toast("error", "Jira Link Component", jiraError);
                component.set("v.isLoading", false);
            }

        });
        $A.enqueueAction(action);
    },

    upsertJiraLinkComments: function (component, jiraComments) {
        var jiraLinkComments = [];
        for (var i = 0; i < jiraComments.length; i++) {
            var jiraLinkComment = {};
            jiraLinkComment.body = jiraComments[i].body;
            jiraLinkComment.id = jiraComments[i].id;
            jiraLinkComment.created = jiraComments[i].created;
            jiraLinkComment.updated = jiraComments[i].updated;
            jiraLinkComment.jiraLinkId = component.get("v.simpleNewJiraLink").Id;
            jiraLinkComment.author = jiraComments[i].author.displayName;
            jiraLinkComment.updateAuthor = jiraComments[i].updateAuthor.displayName;
            jiraLinkComments.push(jiraLinkComment);
        }
        var action = component.get("c.upsertJiraLinkComments");
        action.setParams({
            jsonJiraComments: JSON.stringify(jiraLinkComments)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                this.getJiraLinkComments(component);
            } else {
                console.log(JSON.stringify(response.getError()));
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    getJiraLinkComments: function (component) {
        var action = component.get("c.getJiraLinkComments");
        action.setParams({
            "jiraLinkId": component.get("v.simpleNewJiraLink").Id
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.jiraComments", response.getReturnValue())
            } else {
                console.log("[LXC_CSM_JiraLink] get getJiraLinkComments result Error");
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    addJiraComment: function (component) {
        var action = component.get("c.postCalloutResponseContents");
        action.setParams({
            "url": component.get("v.simpleNewJiraLink.jira_base_url__c") + '/rest/api/2/issue/' + component.get("v.simpleNewJiraLink").jira_key__c + '/comment',
            "JSONString": '{"body": "' + component.find('txtComment').get('v.value') + '"}'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (response.getReturnValue()[0] == "201") {
                    var result = JSON.parse(response.getReturnValue()[1]);
                    var action2 = component.get("c.saveJiraCommentFromCSM");
                    action2.setParams({
                        "jiraCommentId": result.id,
                        "jiraLinkId": component.get("v.simpleNewJiraLink").Id
                    });
                    action2.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            this.toast("success", "Jira Link Component", "The comment was saved.");
                            component.find("txtComment").set("v.value", "");
                            this.linkJiraIssue(component, false);
                        } else {
                            console.log("[LXC_CSM_JiraLink] save jira commment from csm Error");
                        }
                    });
                    $A.enqueueAction(action2);
                } else {
                    var jiraError = JSON.parse(response.getReturnValue()[1]);
                    console.log("[LXC_CSM_JiraLink] Add Jira comments Error");
                    this.toast("error", "Jira Link Component", jiraError);
                }
            } else {
                var jiraError = JSON.parse('{"errorMessages":["Error to connect to ' + component.get("v.simpleNewJiraLink.jira_base_url__c") + ', contact your administrator"],"errors":{}}');
                this.toast("error", "Jira Link Component", jiraError.errorMessages[0]);
            }
        });
        $A.enqueueAction(action);
    },

    addJiraAttachment: function (component, documentId) {
        var action = component.get("c.postAttachmentCalloutResponseContents");
        action.setParams({
            "url": component.get("v.simpleNewJiraLink.jira_base_url__c") + '/rest/api/2/issue/' + component.get("v.simpleNewJiraLink").jira_key__c + "/attachments",
            "contentDocumentId": documentId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var action2 = component.get("c.deleteContentDocumentById");
                action2.setParams({
                    "contentDocumentId": documentId
                });
                action2.setCallback(this, function (response) { this.linkJiraIssue(component, false); });
                $A.enqueueAction(action2);

            } else {
                console.log(JSON.stringify(response.getError()));
            }
            //this.openModal(component);
        });
        $A.enqueueAction(action);
    },

    updateJiraStatus: function (component, transition_id) {
        var action = component.get("c.postCalloutResponseContents");
        action.setParams({
            "url": component.get("v.simpleNewJiraLink.jira_base_url__c") + '/rest/api/2/issue/' + component.get("v.simpleNewJiraLink").jira_key__c + "/transitions",
            "JSONString": '{"update": { "comment": [{"add": { "body": "Comment added when CSM update JIRA status"}}]},"fields": {},"transition": {"id": "' + transition_id + '"}}'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if (response.getReturnValue()[0] == "204") {
                    this.toast("success", "Jira Link Component", "The status was updated.");
                    component.find("txtComment").set("v.value", "");
                    this.linkJiraIssue(component, false);
                } else {
                    var jiraError = JSON.parse(response.getReturnValue()[1]);
                    console.log("[LXC_CSM_JiraLink] Update Jira status Error");
                    this.toast("error", "Jira Link Component", "A problem has occurred. It is possible that one or more fields is required for perform this transition.");
                }
            } else {
                var jiraError = JSON.parse('{"errorMessages":["Error to connect to ' + component.get("v.simpleNewJiraLink.jira_base_url__c") + ', contact your administrator"],"errors":{}}');
                this.toast("error", "Jira Link Component", jiraError.errorMessages[0]);
            }
        });
        $A.enqueueAction(action);
    },

    validateJIRAForm: function (component) {
        var valid = true;
        var allValid = component.find('jiraLinkField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);

        if (allValid) {
            var newJiraLink = component.get("v.newJiraLink");
            if ($A.util.isEmpty(newJiraLink)) {
                valid = false;
            }
            if (component.get("v.simpleNewJiraLink.case_recordId__c") == null) {
                component.set("v.formError", "Please make sure that all fields marked with a red star are filled in");
                valid = false;
            }
            return (valid);
        }
    },

    validateCreateJIRAForm: function (component) {
        var valid = true;
        var allValid = component.find('field').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);

        if (allValid) {
            var newJiraLink = component.get("v.newJiraLink");
            if ($A.util.isEmpty(newJiraLink)) {
                valid = false;
            }
            if (component.get("v.simpleNewJiraLink.case_recordId__c") == null || component.get("v.jiraCreateIssue").selectedjiraProjectValue == null) {
                component.set("v.formError", "Please make sure that all fields marked with a red star are filled in");
                valid = false;
            }
            return (valid);
        }
    },

    insertCaseComment: function (component) {
        var action = component.get("c.insertCaseComment");
        var caseComment = {};
        caseComment.ParentId = component.get("v.recordId");
        caseComment.Body = "JIRA status was updated with the value " + component.get("v.simpleNewJiraLink.status__c");
        caseComment.CreatedById = "0056A000002atA5QAI";
        action.setParams({
            "caseComment": caseComment
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Case Comment added");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                    }
                } else {
                }
            }
        });
        $A.enqueueAction(action);
    },

    openModal: function (component) {
        component.set("v.cssStyle", ".forceStyle .viewport .oneHeader.slds-global-header_container {z-index:0} .forceStyle.desktop .viewport{overflow:hidden}");
        $A.util.removeClass(component.find('modaldialog'), 'slds-fade-in-hide');
        $A.util.addClass(component.find('modaldialog'), 'slds-fade-in-open');
        $A.util.removeClass(component.find('backdrop'), 'slds-backdrop--hide');
        $A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
    },

    closeModal: function (component) {
        component.set("v.cssStyle", ".forceStyle .viewport .oneHeader.slds-global-header_container {z-index:5} .forceStyle.desktop .viewport{overflow:visible}")
        $A.util.addClass(component.find('modaldialog'), 'slds-fade-in-hide');
        $A.util.removeClass(component.find('modaldialog'), 'slds-fade-in-open');
        $A.util.addClass(component.find('backdrop'), 'slds-backdrop--hide');
        $A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
    },

    toast: function (type, title, message) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        $A.get("e.force:closeQuickAction").fire();
        resultsToast.fire();
    },

    escape: function (str) {
        return str
            .replace(/[\\]/g, '\\\\')
            .replace(/[\"]/g, "\\\"")
            .replace(/[\/]/g, '\\/')
            .replace(/[\b]/g, '\\b')
            .replace(/[\f]/g, '\\f')
            .replace(/[\n]/g, '\\n')
            .replace(/[\r]/g, '\\r')
            .replace(/[\t]/g, '\\t');
    },

    eliminateInvalidCharacter: function (str) {
        return str
            .replace(/\n/g, "\\n")
            .replace(/\r/g, "\\r")
            .replace(/\t/g, "\\t")
            .replace(/\f/g, "\\f");
    }

})