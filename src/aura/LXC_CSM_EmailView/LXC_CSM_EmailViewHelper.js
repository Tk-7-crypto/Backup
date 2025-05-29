({
    getEmailInfo: function (component, recordData) {
        var action = component.get("c.getData");
        action.setParams({
            "recordIDD": recordData
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var countRelated = 0;
            if (state === "SUCCESS") {
                var emailMessage = response.getReturnValue();
                if (emailMessage != null) {
                    component.set("v.emailMsg", emailMessage);
                    countRelated = Object.keys(emailMessage).length;
                    component.set("v.countForRelated", countRelated);
                    let allowedRecordTypes = component.get("v.recordTypeForPIIDataIdentified");
                    if (allowedRecordTypes.includes(emailMessage.Parent.RecordTypeName__c)) {
                        component.set("v.isRecordTypeAllowed", true);
                    } else {
                        component.set("v.isRecordTypeAllowed", false);
                    }
                    var subTab = component.get("v.emailMsg.Subject");
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        var focusedTabId = response.tabId;
                        if (subTab != null) {
                            workspaceAPI.setTabLabel({
                                tabId: focusedTabId,
                                label: subTab //set label you want to set
                            });
                        }
                        else {
                            workspaceAPI.setTabLabel({
                                tabId: focusedTabId,
                                label: 'Email' //set label you want to set
                            });
                        }
                        workspaceAPI.setTabIcon({
                            tabId: focusedTabId,
                            icon: "standard:email",
                            iconAlt: "Email"
                        });
                    })
                }
                else {
                    var errors = response.getError();
                    component.set("v.isLoading2", false);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    getEmailMessageRelation: function (component, recordData) {
        var action = component.get("c.getEmailMessageRelations");
        //alert("Helper2"+recordData);
        action.setParams({
            "recordIDD": recordData
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var priorityList = response.getReturnValue();
                var countRelation = 0;
                if (priorityList != null)
                    countRelation = Object.keys(priorityList).length;

                var priorityNamesArray = [];
                for (var i = 0; i < Object.keys(priorityList).length; i++) {
                    var productName = priorityList[i];
                    //alert("Al"+productName)
                    priorityNamesArray.push(productName);
                }
                component.set("v.emailMessageRelationsRecord", priorityNamesArray);
                component.set("v.countForRelation", countRelation);
                //component.set("v.emailMsgRelation", priorityNamesArray[0]);               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },

    getAttachmentsInfo: function (component, recordData) {
        var action = component.get("c.getAttachments");
        //alert("Helper2"+recordData);
        action.setParams({
            "recordIDD": recordData
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var priorityList = response.getReturnValue();
                var countAttachements = 0;
                if (priorityList != null)
                    countAttachements = Object.keys(priorityList).length;
                var priorityNamesArray = [];
                for (var i = 0; i < Object.keys(priorityList).length; i++) {
                    var productName = priorityList[i];
                    priorityNamesArray.push(productName);
                }

                component.set("v.emailMsgAttachmentsRelation", priorityNamesArray);
                component.set("v.countForAttachments", countAttachements);

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },

    navigateToRecord: function (component, objectName, recordId, actionName) {
        var caseId = component.get('v.emailMsg.ParentId');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            var parentTabId = response.parentTabId;
            workspaceAPI.openTab({
                url: '/lightning/r/Case/' + caseId + '/' + actionName
            }).then(function (response) {
                workspaceAPI.openSubtab({
                    parentTabId: response,
                    url: '/lightning/r/' + objectName + '/' + recordId + '/' + actionName,
                    focus: true
                });
            })
                .catch(function (error) {
                    console.log(error);
                });

        })
            .catch(function (error) {
                console.log(error);
            });
        /*workspaceAPI.openTab({
            url: '/lightning/r/'+objectName+'/'+recordId+'/'+actionName,
        }).then(function(response) {
            workspaceAPI.focusTab({tabId : response});
        })

        .catch(function(error) {
            console.log(error);
        });*/
    },

    updatePIIDataIdentified: function (component, event, helper) {
        var emailMsg = component.get("v.emailMsg");
        var newPIIState = !emailMsg.PII_Data_Identified__c;
        var message;

        var action = component.get("c.updatePIIDataIdentified");
        action.setParams({
            recordId: component.get("v.recordId"),
            piiDataIdentified: newPIIState
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                emailMsg.PII_Data_Identified__c = newPIIState;
                component.set("v.emailMsg", emailMsg);
                if (newPIIState) {
                    message = "PII Data identified in the email. The email will be deleted!";
                } else {
                    message = "No PII Data identified in the email. The email will not be deleted!";
                }

                $A.get("e.force:showToast").setParams({
                    "title": "Success",
                    "message": message,
                    "type": "success"
                }).fire();
            } else {
                $A.get("e.force:showToast").setParams({
                    "title": "Error",
                    "message": "Failed to update PII Data Identified.",
                    "type": "error"
                }).fire();
                console.error("Failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    }
}
)