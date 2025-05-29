({
    getOliWithScheduleDetails : function (component, event, helper) {
        var action = component.get("c.getOliByIdWithSchedule");
        var olifields = component.get("v.olifields");
        var oliSchedulefieldList = component.get("v.oliSchedulefieldList");
        var recordId = component.get("v.recordId");
        action.setParams({
            "opportinityId" : recordId,
            "olifieldList" : olifields,
            "oliSchedulefieldList" : oliSchedulefieldList,
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var oliList = actionResult.getReturnValue();
                var oppRecordName = '';
                var oppRecordCloseDate = '';
                var oppRecordCurrencyISOCode = '';
                if(oliList != null && oliList.length > 0) {
                    oppRecordName =  oliList[0].Opportunity.Name;
                    oppRecordCloseDate =  oliList[0].Opportunity.CloseDate;
                    oppRecordCurrencyISOCode = oliList[0].Opportunity.CurrencyIsoCode;
                    component.set("v.oliList", oliList);
                    component.set("v.opportunityLineItem",oliList[0]);
                    component.set("v.tempOpportunityLineItem",oliList[0]);
                    component.set("v.oppRecordName",oppRecordName);
                    component.set("v.oppRecordCloseDate",oppRecordCloseDate);
                    component.set("v.oppRecordCurrencyISOCode",oppRecordCurrencyISOCode);
                    if(component.get("v.modifiedCloseDate") == null)
                    {
                        component.set("v.modifiedCloseDate",oppRecordCloseDate);
                    }
                } else {
                    var oppAction = component.get("c.getOpportunityRecord");
                    oppAction.setParams({
                        "opportinityId" : recordId,
                    });
                    oppAction.setCallback(this, function(actionResult) {
                        if (state === "SUCCESS") {
                            var oppList = actionResult.getReturnValue();
                            if(oppList != null && oppList.length > 0) {
                                oppRecordName =  oppList[0].Name;
                    			oppRecordCloseDate =  oppList[0].CloseDate;
                    			oppRecordCurrencyISOCode = oppList[0].CurrencyIsoCode;
                                component.set("v.oppRecordName",oppRecordName);
                                component.set("v.oppRecordCloseDate",oppRecordCloseDate);
                                component.set("v.oppRecordCurrencyISOCode",oppRecordCurrencyISOCode);
                                if(component.get("v.modifiedCloseDate") == null || component.get("v.modifiedCloseDate") == '' || component.get("v.modifiedCloseDate") == undefined ) 
                                {
                                    component.set("v.modifiedCloseDate",oppRecordCloseDate);
                                }
                                var options = [{'label': 'Update Expected Close Date only', 'value': 'option1'}]
                                component.set("v.options",options);
                                component.set("v.isUpdateSchedule","option1");
                            }
                        }
                        else if(state === "ERROR") {
                            var errors = actionResult.getError();
                            if (errors && errors[0] && errors[0].message) {
                                var errorMsg = JSON.parse(errors[0].message).errorList;
                                helper.setToast(component, event, helper, errorMsg, "error", "Error!");  
                                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                            }  
                        }
                    });
                    $A.enqueueAction(oppAction);
                }
            } else if(state === "ERROR") {
            	var errors = actionResult.getError();
                if (errors && errors[0] && errors[0].message) {
                    var errorMsg = JSON.parse(errors[0].message).errorList;
                    helper.setToast(component, event, helper, errorMsg, "error", "Error!");  
                }  
            }
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        });
        $A.enqueueAction(action);
    },
    
    updateCloseDate: function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var oliList = component.get("v.oliList");
        var tempOpportunityLineItem = component.get("v.opportunityLineItem");
        var modifiedCloseDate = helper.parseDate(component.get("v.modifiedCloseDate"));
        var oppRecordCloseDate = helper.parseDate(component.get("v.oppRecordCloseDate"));
        var timeDiff = Math.abs(modifiedCloseDate.getTime() - oppRecordCloseDate.getTime());
		var dayMoved = Math.ceil(timeDiff / (1000 * 3600 * 24)); 
        var currentDate = new Date();
        var isUpdateSchedule = component.get("v.isUpdateSchedule");
        if(isUpdateSchedule == 'option2') {
            tempOpportunityLineItem.Opportunity.Gross_Q1_Value__c = 0;
            tempOpportunityLineItem.Opportunity.Gross_Q2_Value__c = 0;
            tempOpportunityLineItem.Opportunity.Gross_Q3_Value__c = 0;
            tempOpportunityLineItem.Opportunity.Gross_Q4_Value__c = 0;
            tempOpportunityLineItem.Opportunity.Gross_Q1_NY_Value__c = 0;
            tempOpportunityLineItem.Opportunity.Gross_Q2_NY_Value__c = 0;
            tempOpportunityLineItem.Opportunity.Gross_Q3_NY_Value__c = 0;
            tempOpportunityLineItem.Opportunity.Gross_Q4_NY_Value__c = 0;
            component.set("v.tempOpportunityLineItem",tempOpportunityLineItem);
            tempOpportunityLineItem = component.get("v.tempOpportunityLineItem");
            for(var count in oliList) {
                var olisList = oliList[count].OpportunityLineItemSchedules;
                for(var index in olisList) {
                    var tempScheduleDate = new Date(olisList[index].ScheduleDate);
                    if(modifiedCloseDate > oppRecordCloseDate) {
                        var confirmationMsg = [];
                        confirmationMsg.push('After save, Expected Close Date will be moved forward to '+ modifiedCloseDate.toString().substr(4, 11) +' ( '+ dayMoved +' days after current Expected Close Date).');
                        confirmationMsg.push('All schedules will be moved forward by '+ dayMoved +' days.');
                        component.set("v.isShowconfirmationMsg",true);
                        component.set("v.confirmationMsg",confirmationMsg);
                        tempScheduleDate = tempScheduleDate.setDate(tempScheduleDate.getDate() + dayMoved);
                    } else {
                        var confirmationMsg = [];
                        confirmationMsg.push('After save, Expected Close Date will be moved back  to '+ modifiedCloseDate.toString().substr(4, 11) +' ( '+ dayMoved +' days prior to current Expected Close Date).');
                        confirmationMsg.push('All schedules will be moved back by '+ dayMoved +' days.');
                        component.set("v.isShowconfirmationMsg",true);
                        component.set("v.confirmationMsg",confirmationMsg);
                        tempScheduleDate = tempScheduleDate.setDate(tempScheduleDate.getDate() - dayMoved);
                    }
                    var tempScheduleFormattedDate = new Date(helper.formatDate(component, event, helper, tempScheduleDate));    
                    if(tempScheduleFormattedDate.getFullYear() == currentDate.getFullYear() && tempScheduleFormattedDate.getMonth() + 1 <= 3) {  
                        tempOpportunityLineItem.Opportunity.Gross_Q1_Value__c += olisList[index].Revenue;
                    }
                    else if(tempScheduleFormattedDate.getFullYear() == currentDate.getFullYear() && tempScheduleFormattedDate.getMonth() + 1 > 3 && tempScheduleFormattedDate.getMonth() + 1 <= 6) {                                  
                        tempOpportunityLineItem.Opportunity.Gross_Q2_Value__c += olisList[index].Revenue;
                    }
                    else if(tempScheduleFormattedDate.getFullYear() == currentDate.getFullYear() && tempScheduleFormattedDate.getMonth() + 1 > 6 && tempScheduleFormattedDate.getMonth() + 1 <= 9) {                                  
                        tempOpportunityLineItem.Opportunity.Gross_Q3_Value__c += olisList[index].Revenue;
                    }
                    else if(tempScheduleFormattedDate.getFullYear() == currentDate.getFullYear() && tempScheduleFormattedDate.getMonth() + 1 > 9 && tempScheduleFormattedDate.getMonth() + 1 <= 12) {                                  
                        tempOpportunityLineItem.Opportunity.Gross_Q4_Value__c += olisList[index].Revenue;
                    }
                    else if(tempScheduleFormattedDate.getFullYear() == currentDate.getFullYear() + 1 && tempScheduleFormattedDate.getMonth() + 1 <= 3) {                                  
                        tempOpportunityLineItem.Opportunity.Gross_Q1_NY_Value__c += olisList[index].Revenue;
                    }
                    else if(tempScheduleFormattedDate.getFullYear() == currentDate.getFullYear() + 1 && tempScheduleFormattedDate.getMonth() + 1 > 3 && tempScheduleFormattedDate.getMonth() + 1 <= 6) {                                  
                        tempOpportunityLineItem.Opportunity.Gross_Q2_NY_Value__c += olisList[index].Revenue;
                    }
                    else if(tempScheduleFormattedDate.getFullYear() == currentDate.getFullYear() + 1 && tempScheduleFormattedDate.getMonth() + 1 > 6 && tempScheduleFormattedDate.getMonth() + 1 <= 9) {                                  
                        tempOpportunityLineItem.Opportunity.Gross_Q3_NY_Value__c += olisList[index].Revenue;
                    }
                    else if(tempScheduleFormattedDate.getFullYear() == currentDate.getFullYear() + 1 && tempScheduleFormattedDate.getMonth() + 1 > 9 && tempScheduleFormattedDate.getMonth() + 1 <= 12) {                                  
                        tempOpportunityLineItem.Opportunity.Gross_Q4_NY_Value__c += olisList[index].Revenue;
                    }
                }
            }
            component.set("v.tempOpportunityLineItem",tempOpportunityLineItem);
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        } else {
            component.set("v.isShowconfirmationMsg",false);
            component.set("v.confirmationMsg",'');
            helper.getOliWithScheduleDetails(component, event, helper);
        }
    },
    
    updateCloseDateOfOpportunity : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var recordId = component.get("v.recordId");
        var modifiedCloseDate = helper.parseDate(component.get("v.modifiedCloseDate"));
        var oppRecordCloseDate = helper.parseDate(component.get("v.oppRecordCloseDate"));
        var timeDiff = modifiedCloseDate.getTime() - oppRecordCloseDate.getTime();
		var dayMoved = Math.ceil(timeDiff / (1000 * 3600 * 24)); 
        var isToUpdateSchedule = false;
        var isUpdateSchedule = component.get("v.isUpdateSchedule");
        var olifields = component.get("v.olifields");
        var oliSchedulefieldList = component.get("v.oliSchedulefieldList");
        if(isUpdateSchedule == 'option2') {
            isToUpdateSchedule = true;
        }
        var action = component.get("c.updateCloseDateOfOpportunity");
        action.setParams({
            "opportinityId" : recordId,
            "dayMoved" : JSON.stringify(dayMoved),
            "isToUpdateSchedule" : isToUpdateSchedule,
            "olifieldList" : olifields,
            "oliSchedulefieldList" : oliSchedulefieldList
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                helper.navigateToOpp(component, event, helper, recordId);
            } else if(state === "ERROR") {
                var errors = actionResult.getError();
                if (errors && errors[0] && errors[0].message) {
                    var errorMsg = JSON.parse(errors[0].message).errorList;
                    helper.setToast(component, event, helper, errorMsg, "error", "Error!");  
                }
            }
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        });
        $A.enqueueAction(action);
    },
    
    navigateToOpp : function (component, event, helper, recordId) {
        window.location.href = "/" + recordId;
    },
    
    parseDate : function (input) {
      var parts = input.match(/(\d+)/g);
      return new Date(parts[0], parts[1]-1, parts[2]); // months are 0-based
    },
    
    formatDate : function (component, event, helper, date) {
        var dt = new Date(date);
        var month = '' + (dt.getMonth() + 1);
        var day = '' + dt.getDate();
        var year = dt.getFullYear();
        if (month.length < 2) {
            month = '0' + month;
        }
        if (day.length < 2) {
            day = '0' + day;
        }
        return [year, month, day].join('-');
    },
    
    setToast : function(component, event, helper, message, type, title) {
        var errorMsg = message;
        var msg = "";
        for(var x = 0; x < errorMsg.length; x++) {
            msg = msg + errorMsg[x] + "\n";
        }
        var mode;
        if(type == "success") {
            mode = "dismissible";
        } else {
            mode = "sticky";
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            type : type,
            message : msg,
            mode : mode
        });
        toastEvent.fire();
    }
})