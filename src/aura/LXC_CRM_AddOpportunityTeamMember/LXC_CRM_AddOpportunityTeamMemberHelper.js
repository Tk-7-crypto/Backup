({
    checkForCommercialUser : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getCommercialUserDetail");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if(response) {
                    helper.getFieldDetails(component, event, helper);
                } else {
                    var errorsList = [];
                    errorsList.push("Only Commercial Operations users can Edit Opportunity Teams or Accounts.");
                    component.set("v.errors", errorsList);
                    component.set("v.Spinner", false);
                    component.set("v.isCommercialUser", true);
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                var err = JSON.parse(errors[0].message).errorList;
                helper.setToast(component, event, helper, err, "error", "Error!");
                component.set("v.Spinner", false);
            }
        })
        $A.enqueueAction(action);
    },
    
    getFieldDetails : function(component, event, helper) {
        var fieldsToShow = component.get("v.fieldsToShow");
        var action = component.get("c.getOppTeamMemberFieldDetail");
        action.setParams({
            fieldData : fieldsToShow,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var fieldsToShowWrapper = [];
                var returnValue = response.getReturnValue();
                component.set("v.fieldsToShowWrapper", returnValue);
                helper.addTeamMembers(component, event, helper);
            } else if(state === "ERROR") {
                var errors = response.getError();
                var err = JSON.parse(errors[0].message).errorList;
                helper.setToast(component, event, helper, err, "error", "Error!");
                component.set("v.Spinner", false);
            }
        })
        $A.enqueueAction(action);
    },
    
    onSave : function(component, event, helper) {
        component.set("v.Spinner", true);
        var errorsList = [];
        component.set("v.errors",errorsList);
        var opportunityRecord = component.get("v.opportunityRecord");
        var accountComp = component.find("accountlookup");
        if(opportunityRecord.AccountId == null || opportunityRecord.AccountId == '') {
            $A.util.addClass(accountComp, "slds-has-error");
            errorsList.push("Please Complete Required Fields.");
            component.set("v.errors",errorsList);
            component.set("v.Spinner", false);
            return;
        }
        else {
            errorsList = [];
            $A.util.removeClass(accountComp, "slds-has-error");
        }
        var OpportunityTeamMemberList = component.get("v.OpportunityTeamMemberList");
        var auraIdList = ["picklist","lookup"];
        var componentsMap = helper.findComponentByAuraIds(component, event, auraIdList);
        var picklistCompList = componentsMap.get(auraIdList[0]);
        var lookupCompList = componentsMap.get(auraIdList[1]);
        var selectedList = component.get("v.OpportunityTeamMemberList");
        var fieldsToShowWrapper = component.get("v.fieldsToShowWrapper");
        var recordId = component.get("v.recordId");
        var saveWrapper = [];
        var picklistIndex = 0;
        var lookupIndex = 0;
        var noOfPicklistInRow = (picklistCompList.length / selectedList.length);
        var noOfLookupInRow = (lookupCompList.length / selectedList.length);
        var fieldsToShow = component.get("v.fieldsToShow");
        var fieldsToShowArr = fieldsToShow.split(",");
        fieldsToShow = fieldsToShow.toLowerCase().split(",");
        var fieldsToShowSet = new Set(fieldsToShow);
        var isError = false;
        for(var i = 0; i < selectedList.length; i++) {
            var rowWrapper = {};
            rowWrapper["opportunityId"] = recordId;
            rowWrapper["Id"] = selectedList[i].Id;
            for(var k = 0; k < noOfLookupInRow; k++) {
                var key = lookupCompList[lookupIndex].get("v.label");
                var value = lookupCompList[lookupIndex].get("v.value");
                if(value == "") {
                    value = null;
                }
                rowWrapper[key] = value;
                lookupIndex++;
            }
            for(var k = 0; k < noOfPicklistInRow; k++) {
                var key = picklistCompList[picklistIndex].get("v.label");
                var value = picklistCompList[picklistIndex].get("v.value");
                if( rowWrapper["userid"] != undefined && (value == "--None--" || value == "" || value == null)) {
                    value = "";
                    $A.util.addClass(picklistCompList[picklistIndex], "slds-has-error");
                    isError = true;
                }
                rowWrapper[key] = value;
                picklistIndex++;
            }
            saveWrapper.push(rowWrapper);
        }
        if(!isError) {
            var oldAccountId = component.get("v.oldAccountId");
            var isAccountChanged = opportunityRecord.AccountId != oldAccountId;
            var action = component.get("c.saveOpportunityTeamMembers");
            action.setParams({ 
                recordJSON : JSON.stringify(saveWrapper),
                opportunityRecord : opportunityRecord,
                isAccountChanged : isAccountChanged
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var OpportunityTeamMemberListToDelete = component.get("v.OpportunityTeamMemberListToDelete");
                    if(OpportunityTeamMemberListToDelete.length > 0){
                        helper.deleteOpportunityTeamMember(component, event, helper);
                    } else{
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        component.set("v.Spinner", false);
                    }
                } else if(state === "ERROR") {
                    var errors = response.getError();
                    var err = JSON.parse(errors[0].message).errorList;
                    helper.setToast(component, event, helper, err, "error", "Error!");
                    component.set("v.Spinner", false);
                }
            })
            $A.enqueueAction(action);
        } else {
            errorsList.push("Please Complete Required Fields.");
            component.set("v.errors",errorsList);
            component.set("v.Spinner", false);
        }
    },
    
    findComponentByAuraIds : function(component, event, cmpIds) {
        var componentsMap = new Map();
        for(var cmpIndex = 0; cmpIndex < cmpIds.length; cmpIndex++) {
            var componentList = [];
            componentList = component.find(cmpIds[cmpIndex]);
            var componentTempList = [];
            if(componentList !=  undefined && componentList.length ==  undefined) {
                componentTempList.push(componentList);
                componentList = componentTempList;
            }
            componentTempList = [];
            if(componentList != undefined) {
                for(var index = 0; index < componentList.length; index++) {
                    if(componentList[index].isValid() && componentList[index].get('v.label') != undefined) {
                        componentTempList.push(componentList[index]);
                    }
                }
            }
            componentList = componentTempList;
            componentsMap.set(cmpIds[cmpIndex], componentList);
        }
        return componentsMap;
    },
    
    addTeamMemberRow : function(component, event, helper) {
        component.set("v.Spinner", true);
        var OpportunityTeamMemberList = component.get("v.OpportunityTeamMemberList");
        var recordId = component.get("v.recordId");
        var opportunityTeamMember = {
            "Id" : null,
            "OpportunityId" : recordId,
            "TeamMemberRole" : null,
            "UserId" : null,
            "OpportunityAccessLevel" : null,
        };
        OpportunityTeamMemberList.push(
            opportunityTeamMember
        );
        component.set("v.OpportunityTeamMemberList", OpportunityTeamMemberList);
        component.set("v.Spinner", false);
    },
    
    addTeamMembers : function(component, event, helper) {
        var action = component.get("c.getOppTeamMemberList");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var OpportunityTeamMemberList = component.get("v.OpportunityTeamMemberList");
                var recordId = component.get("v.recordId");
                for(var i = 0; i < returnValue.length; i++) {
                    if(returnValue[i].OpportunityAccessLevel != 'All'){
                        var opportunityTeamMember = {
                            "Id" : returnValue[i].Id,
                            "OpportunityId" : recordId,
                            "TeamMemberRole" : returnValue[i].TeamMemberRole,
                            "UserId" : returnValue[i].UserId,
                            "OpportunityAccessLevel" : returnValue[i].OpportunityAccessLevel,
                        };
                        OpportunityTeamMemberList.push(
                            opportunityTeamMember
                        );
                    }
                }
                component.set("v.OpportunityTeamMemberList", OpportunityTeamMemberList);
                component.set("v.Spinner", false);
            }else if(state === "ERROR") {
                var errors = response.getError();
                var err = JSON.parse(errors[0].message).errorList;
                helper.setToast(component, event, helper, err, "error", "Error!");
                component.set("v.Spinner", false);
            }
        })
        $A.enqueueAction(action);
    },
    
    setToast : function(component, event, helper, message, type, title) {
        var errorMsg = message;
        var msg = "";
        for(var x = 0; x < errorMsg.length; x++) {
            msg = msg + errorMsg[x] + "\n";
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            type : type,
            message : msg,
            mode : "sticky"
        });
        toastEvent.fire();
    },
    
    deleteOpportunityTeamMember : function(component, event, helper) {
        var OpportunityTeamMemberListToDelete = component.get("v.OpportunityTeamMemberListToDelete");
        var action = component.get("c.deleteOpportunityTeamMembers");
        action.setParams({
            recordJSON : JSON.stringify(OpportunityTeamMemberListToDelete),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else if(state === "ERROR") {
                var errors = response.getError();
                var err = JSON.parse(errors[0].message).errorList;
                helper.setToast(component, event, helper, err, "error", "Error!");
            }
        })
        $A.enqueueAction(action);
    },
})