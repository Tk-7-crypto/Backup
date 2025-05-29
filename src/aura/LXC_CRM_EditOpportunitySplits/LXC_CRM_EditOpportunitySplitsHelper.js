({
    getOppByIdWithOppTeamSplits : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var action = component.get("c.getOppByIdWithOppTeamSplits");
        var oppTeamMembersFields = component.get("v.oppTeamMembersFields");
        var oppSplitsfields = component.get("v.oppSplitsfields");
        var oppfields = component.get("v.oppfields");
        var recordId = component.get("v.recordId");
        action.setParams({
            "opportinityId" : recordId,
            "oppfieldList" : oppfields,
            "oppSplitFieldList" : oppSplitsfields,
            "oppTeamFieldList" : oppTeamMembersFields,
            "splitType" : "Overlay"
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var oppWrapper = actionResult.getReturnValue();
                if(oppWrapper != null) {
                    helper.createTeamMembersPicklist(component, event, helper, oppWrapper);
                }
                component.set("v.decimalPlace", oppWrapper.decimalPlace);
                component.set("v.decimalPlaceStep", oppWrapper.decimalPlaceStep);
            } else if(state === "ERROR") {
                var errors = actionResult.getError();
                if (errors && errors[0] && errors[0].message) {
                    var errorMsg = JSON.parse(errors[0].message).errorList;
                    helper.setToast(component, event, helper, errorMsg, "error", "Error!");  
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
        });
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        $A.enqueueAction(action);
    },
    
    createTeamMembersPicklist : function(component, event, helper, oppDetail) {
        var teamMemberList = oppDetail.oppTeamMemberList;
        var oppRecord = oppDetail.opportunityRecord;
        var oppSplitWrapperList = oppDetail.oppSplitWrapperList;
        var oppSplitRecords = new Map();
        for(var index = 0; index < oppSplitWrapperList.length; index++) {
            var splitRecord = oppSplitWrapperList[index].splitRecord;
            oppSplitRecords[splitRecord["Id"]] = splitRecord["SplitOwnerId"];
        }
        var teamMemberPicklist = [];
        for(var index in teamMemberList) {
            var tempMemberList = {};
            tempMemberList["Id"] = teamMemberList[index].UserId;
            tempMemberList["Name"] = teamMemberList[index].Name;
            teamMemberPicklist.push(tempMemberList);
        }
        component.set("v.oppSplitRecords", oppSplitRecords);
        component.set("v.oppTeamMembers", teamMemberPicklist);
        component.set("v.oppRecord", oppRecord);
        var oppAmount = 0.00;
        var decimalPlace = component.get("v.decimalPlace");
        if(oppRecord.Amount != undefined && oppRecord.Amount != null) {
            oppAmount = parseFloat(oppRecord.Amount).toFixed(decimalPlace);
        }
        component.set("v.oppAmount", oppAmount);
        component.set("v.oppSplitWrapperList", oppSplitWrapperList);
        component.set("v.showResult", true);
        if(parseFloat(oppAmount) == 0) {
            var addMoreRowComp = component.find("addMoreRow");
            $A.util.addClass(addMoreRowComp, "disabledTab");
            var errorId = "addMoreRow";
            var errorsToShow = [];
            errorsToShow.push({
                "Id" : errorId,
                "message" : "You can't create Opportunity Split when Opportunity amount is 0."
            });
            component.set("v.errors", errorsToShow);
            var errorDivComp = component.find("errorDiv");
            $A.util.removeClass(errorDivComp, "slds-theme_error");
            $A.util.addClass(errorDivComp, "slds-theme_info");
            helper.disableAllInputs(component, event, helper);
        } 
        else if (oppSplitWrapperList.length == 0 ) {
            helper.addSpiltRecord(component, event, helper);
        }
        helper.showTotal(component, event, helper, false, [], oppSplitWrapperList);   
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    
    updateOpportunitySplitRecords : function(component, event, helper, saveClose) {
        var errors = component.get("v.errors");
        if(errors.length > 0) {
            return;
        }
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var action = component.get("c.updateOpportunitySplitRecords");
        var oppSplitWrapperList = component.get("v.oppSplitWrapperList");
        var oppSplitWrapperDeleteList = component.get("v.oppSplitWrapperDeleteList");
        var oppSplitTemp = oppSplitWrapperList.concat(oppSplitWrapperDeleteList);
        oppSplitWrapperList = oppSplitTemp;
        var oppSplitRecords = component.get("v.oppSplitRecords");
        for(var index = 0; index < oppSplitWrapperList.length; index++) {
            var oppSplitWrapper = oppSplitWrapperList[index];
            if(oppSplitWrapper.operationType == "edit" && (oppSplitWrapper.splitRecord.SplitOwnerId != oppSplitRecords[oppSplitWrapper.splitRecord.Id])) {
                oppSplitWrapper.operationType = "create"; 
            }
            oppSplitWrapper.splitRecord.SplitAmount = null;
        }
        action.setParams({
            "oppSplitWrapperListJsonStr" : JSON.stringify(oppSplitWrapperList),
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                component.set("v.oppSplitWrapperDeleteList", []);
                if(saveClose) {
                    var recordId = component.get("v.recordId");
                    $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                    helper.navigateToOpp(component, event, helper, recordId);
                } else {
                    component.set("v.showResult", false); 
                    helper.getOppByIdWithOppTeamSplits(component, event, helper);
                }
            } else if(state === "ERROR") {
                var errors = actionResult.getError();
                if (errors && errors[0] && errors[0].message) {
                    var errorMsg = JSON.parse(errors[0].message).errorList;
                    helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    deleteSpiltRecord : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var oppSplitWrapperList = component.get("v.oppSplitWrapperList");
        var oppSplitWrapperDeleteList = component.get("v.oppSplitWrapperDeleteList");
        var deleteList  = [];
        var index = event.target.id;
        if(index >= 0 && index < oppSplitWrapperList.length) {
            oppSplitWrapperList[index].operationType = "Delete";
            deleteList = oppSplitWrapperList.splice(index, 1);
            component.set("v.oppSplitWrapperList", oppSplitWrapperList);
            helper.showTotal(component, event, helper, true, [], oppSplitWrapperList);
        }
        if(deleteList.length > 0 && deleteList[0].splitRecord.Id != null) {
            oppSplitWrapperDeleteList.push(deleteList[0]);
            component.set("v.oppSplitWrapperDeleteList", oppSplitWrapperDeleteList);
        }
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        
    },
    
    addSpiltRecord : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var oppSplitWrapperList = component.get("v.oppSplitWrapperList");
        var oppTeamMembers = component.get("v.oppTeamMembers");
        var recordId = component.get("v.recordId");
        var oppSplitWrapper = {
            "Id" : null,
            "OpportunityId" : recordId,
            "SplitOwnerId" : oppTeamMembers[0]["Id"],
            "SplitTypeId" : null,
            "SplitPercentage" : "0.00",
            "SplitNote" : null,
            "SplitAmount" : "0.00"
        };
        oppSplitWrapperList.push({
            "operationType" : "create",
            "splitRecord" : oppSplitWrapper
        });
        component.set("v.oppSplitWrapperList", oppSplitWrapperList);
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    
    checkSplitMember : function(component, event, helper, saveClose) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var errorsToShow = [];
        var teamMemerSet = new Set();
        var memberCmp = component.find("SplitOwnerId");
        var memberCmpTemp = [];
        if (memberCmp != undefined && memberCmp != null && memberCmp.length == undefined) {
            memberCmpTemp.push(memberCmp);
            memberCmp = memberCmpTemp;
        }
        if(memberCmp == undefined) {
            memberCmp = [];
        }
        var errorIndexSet = new Set();
        var hasError = false;
        for(var index = 0; index < memberCmp.length; index++) {
            var memberValue = memberCmp[index].get("v.value");
            if(!teamMemerSet.has(memberValue)) {
                teamMemerSet.add(memberValue);
            } else {
                hasError = true;
                errorIndexSet.add(index);
            }
        }
        var errorId = "SplitOwnerId";
        if(hasError) {
            errorsToShow.push({
                "Id" : errorId,
                "message" : "The user has already been entered for that split type."
            });
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            component.set("v.errors", errorsToShow);
        }
        for(var index = 0; index < memberCmp.length; index++) {
            if(hasError && errorIndexSet.has(index)) {
                $A.util.addClass(memberCmp[index], "slds-has-error");
                $A.util.removeClass(memberCmp[index], "hide-error-message");
            }
            if(!hasError) {
                $A.util.removeClass(memberCmp[index], "slds-has-error");
                $A.util.addClass(memberCmp[index], "hide-error-message");
            }
        }
        if(errorsToShow.length == 0) {
            helper.updateOpportunitySplitRecords(component, event, helper, saveClose);
        }
    },
    
    setTotalAmount : function(component, event, helper) {
        var inputComp = event.getSource();
        var localIds = ["SplitPercentage", "SplitAmount"];
        var isAmountValue = false;
        var localId = inputComp.getLocalId();
        var boundaryValue = 100.00;
        var oppAmount = component.get("v.oppAmount");
        var decimalPlace = component.get("v.decimalPlace");
        oppAmount  = parseFloat(oppAmount).toFixed(decimalPlace);
        var toogleLocalId = localIds[1];
        if(localId === localIds[1]) {
            boundaryValue = oppAmount;
            isAmountValue = true;
            toogleLocalId = localIds[0];
        }
        var toggleComp = component.find(toogleLocalId);
        var toggleCompTemp = [];
        if (toggleComp != null && toggleComp.length == undefined) {
            toggleCompTemp.push(toggleComp);
            toggleComp = toggleCompTemp;
        }
        var index = inputComp.get("v.label").split(localId)[1];
        var toggleCompOne = toggleComp[index];
        var errorsToShow = component.get("v.errors");
        var hasError = false;
        var inputValue = inputComp.get("v.value");
        if(inputValue == null || inputValue == "") {
            inputValue = 0.00;
        }
        var inputValue = parseFloat(inputValue).toFixed(decimalPlace);
        var currentValue = 0.00;
        var oppSplitWrapperList = component.get("v.oppSplitWrapperList");
        if(parseFloat(inputValue) < 0.00 || parseFloat(inputValue) > parseFloat(boundaryValue)) {
            hasError = true;
        }
        if(isAmountValue) {
            currentValue = (inputValue * 100) / oppAmount;
            currentValue = currentValue.toFixed(decimalPlace);
            oppSplitWrapperList[index]["splitRecord"][localIds[0]] = currentValue;
            oppSplitWrapperList[index]["splitRecord"][localIds[1]] = inputValue;
            toggleCompOne.set("v.value", currentValue);
        } else {
            currentValue = (oppAmount * inputValue)/100;
            currentValue = currentValue.toFixed(decimalPlace);
            oppSplitWrapperList[index]["splitRecord"][localIds[1]] = currentValue;
            oppSplitWrapperList[index]["splitRecord"][localIds[0]] = inputValue;
            toggleCompOne.set("v.value", currentValue);
        }
        inputComp.set("v.value", inputValue);
        component.set("v.oppSplitWrapperList", oppSplitWrapperList);
        if(hasError) {
            inputComp.set("v.validity", {valid : true, badInput : true});
            $A.util.addClass(inputComp, "slds-has-error");
            $A.util.removeClass(inputComp, "hide-error-message");
            $A.util.addClass(toggleCompOne, "slds-has-error");
            $A.util.removeClass(toggleCompOne, "hide-error-message");
        }
        else {
            $A.util.removeClass(inputComp, "slds-has-error");
            $A.util.addClass(inputComp, "hide-error-message");
            $A.util.removeClass(toggleCompOne, "slds-has-error");
            $A.util.addClass(toggleCompOne, "hide-error-message");
        }
        helper.showTotal(component, event, helper, true, errorsToShow, oppSplitWrapperList);
    },
    
    showTotal : function(component, event, helper, isValidate, errorsToShow, oppSplitWrapperList) {
        var totalPercent = 0.00;
        var totalAmount = 0.00;
        var isRowLimitError = false;
        for(var index = 0; index < oppSplitWrapperList.length; index++) {
            var splitRecord = oppSplitWrapperList[index].splitRecord;
            totalPercent += parseFloat(splitRecord.SplitPercentage);
            totalAmount += parseFloat(splitRecord.SplitAmount);
            if(parseFloat(splitRecord.SplitPercentage) > 100 || parseFloat(splitRecord.SplitPercentage) < 0) {
                isRowLimitError = true;
            }
        }
        var decimalPlace = component.get("v.decimalPlace");
        totalPercent = totalPercent.toFixed(2);
        totalAmount = totalAmount.toFixed(decimalPlace);
        component.set("v.totalPercent", totalPercent);
        component.set("v.totalAmount", totalAmount);
        if(isValidate) {
            var errorRemoveIndex = -1;
            var errorId = "SplitPercentage";
            for(var errorIndex in errorsToShow) {
                if(errorsToShow[errorIndex].Id == errorId)
                    errorRemoveIndex = errorIndex;
            }
            if(isRowLimitError && errorRemoveIndex == -1) {
                errorsToShow.push({
                    "Id" : errorId,
                    "message" : "Split percentage must be between 0 and 100.00."
                });
            }
            else if(!isRowLimitError && errorRemoveIndex != -1) {
                errorsToShow.splice(errorRemoveIndex, 1);
            }
            var totalAmountCmp = component.find("totalAmount");
            var totalPercentCmp = component.find("totalPercent");
            errorId = "totalPercent";
            errorRemoveIndex = -1;
            for(var errorIndex in errorsToShow) {
                if(errorsToShow[errorIndex].Id == errorId)
                    errorRemoveIndex = errorIndex;
            }
            if(errorRemoveIndex != -1) {
                errorsToShow.splice(errorRemoveIndex, 1);
            }
            if(parseFloat(totalPercent) > 100.00 || parseFloat(totalPercent) < 0) {
                errorsToShow.push({
                    "Id" : errorId,
                    "message" : "Revenue must total up to 100% for an Opportunity Split."
                });
                $A.util.addClass(totalAmountCmp, "redColor");
                $A.util.addClass(totalPercentCmp, "redColor");
            }
            else {
                $A.util.removeClass(totalAmountCmp, "redColor");
                $A.util.removeClass(totalPercentCmp, "redColor");
            }
            component.set("v.errors", errorsToShow);
        }
    },
    
    navigateToOpp : function (component, event, helper, recordId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
    
    disableAllInputs : function (component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var inputIds = ["SplitOwnerId","SplitPercentage","SplitAmount","SplitNote"];
        var allInputsList = [];
        for(var i = 0; i < inputIds.length; i++) {
            var inputComp = component.find(inputIds[i]);
            if(inputComp == undefined) {
                break;
            }
            if(inputComp != null && inputComp.length == undefined) {
                var inputTempcomp = [];
                inputTempcomp.push(inputComp);
                inputComp = inputTempcomp;
            }
            for(var j = 0; j < inputComp.length; j++) {
                allInputsList.push(inputComp[j]);
            }
        }
        for(var index = 0; index < allInputsList.length; index++) {
            allInputsList[index].set("v.disabled", true);
        }
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
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
    
    addOpportunityTeamMember: function(component, event, helper, recordId) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var appEvent = $A.get("e.c:LXE_CRM_AddOpportunityTeamMemberEvent");
        appEvent.setParams({"recordId" : recordId});
        appEvent.setParams({"isFadeIn" : true});
        appEvent.setParams({"fieldsToShow" : 'TeamMemberRole,UserId,OpportunityAccessLevel'});
        appEvent.fire();
    },
    
    callReloadEvent : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var eventFor = event.getParams().eventFor;
        if(eventFor == "reloadOpportunitySplits") {
        	helper.getOppByIdWithOppTeamSplits(component, event, helper);
        }
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    }
})