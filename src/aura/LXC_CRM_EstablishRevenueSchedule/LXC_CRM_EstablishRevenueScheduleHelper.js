({
    getOLISchedules : function(component, event, helper) {
        var oliWrapper = component.get("v.oliWrapper");
        var olisWrapper = oliWrapper[0].revSchWrapperList;
        var olisList = [];
        component.set("v.olisWrapper", olisWrapper);
        component.set('v.establishButton', 'Establish');
        if(oliWrapper[0].oliRecord.OpportunityLineItemSchedules != undefined) {
            component.set("v.olisList", oliWrapper[0].oliRecord.OpportunityLineItemSchedules);
        } else {
            component.set("v.olisList", []);
        }
        component.set("v.oppLineItem", oliWrapper[0].oliRecord);
        component.find("text-input-revenue").set("v.value", oliWrapper[0].oliRecord.TotalPrice);
        if(oliWrapper[0].revSchWrapperList != undefined && oliWrapper[0].revSchWrapperList.length > 0) {
            component.set('v.establishButton', 'Re Establish');
        }
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    
    fadeOutRevenueModel : function(component, event, helper) {
        component.set("v.isRevenueVisible",false);
        var revenueSchComp = component.find("revenueSch");
        var backDropComp = component.find("backdrop");
        $A.util.removeClass(revenueSchComp, "slds-fade-in-open");
        $A.util.removeClass(backDropComp, "slds-backdrop--open");
        $A.get('e.force:refreshView').fire();
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    
    saveAndClose : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var oliScheduleListNew = [];
        var oliScheduleWrapperList = [];
        var errorList = [];
        var oppLineItem = component.get("v.oppLineItem");
        var olisList = component.get("v.olisList");
        var decimalPlace = component.get("v.decimalPlace");
        for(var i = 0; i < olisList.length; i++) {
            var scheduleRecord = olisList[i];
            var rev = parseFloat(scheduleRecord.Revenue).toFixed(decimalPlace);
            if((!$A.util.isEmpty(scheduleRecord.ScheduleDate) && (!$A.util.isEmpty(scheduleRecord.Revenue) || !scheduleRecord.Revenue == ''))) {
                oliScheduleListNew.push({
                    "ScheduleDate" : scheduleRecord.ScheduleDate,
                    "Revenue" : rev,
                    "Description" : scheduleRecord.Description,
                    "OpportunityLineItemId" : oppLineItem.Id,
                    "Type" : "Revenue"
                });
                
            }
        }
        for(var i = 0; i < oliScheduleListNew.length; i++) {
            oliScheduleWrapperList.push({
                schRecord : oliScheduleListNew[i],
                operationType : "create"
            });
        } 
        if(oliScheduleWrapperList.length == 0) {
            errorList.push("Please Enter atleast One Revenue Schedule");
            helper.setToast(component, event, helper, errorList, "error", "Error!");
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            return;
        }
        var action = component.get("c.updateOliSchedule");
        action.setParams({
            jsonWrapper : JSON.stringify(oliScheduleWrapperList)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastMessage = [];
                var msg = "Schedules has been updated successfully.";
                toastMessage.push(msg);
                helper.setToast(component, event, helper, toastMessage, "success", "Success!");
                helper.fadeOutRevenueModel(component, event, helper);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    var errorMsg = JSON.parse(errors[0].message).errorList;
                    helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            } else {
                helper.setToast(component, event, helper, "Unknown Error", "error", "Error!");
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
        })
        $A.enqueueAction(action);
    },
    establish :function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var hasError = false;
        var errorsList = [];
        var oliWrapper = component.get("v.oliWrapper");
        var oppLineItem = oliWrapper[0].oliRecord;
        var startDate = component.find("text-input-start-date").get("v.value");
        var revenue = component.find("text-input-revenue").get("v.value");
        var scheduleType = component.find("select-input-scheduleType").get("v.value");
        var installmentPeriod = component.find("select-input-installmentPeriod").get("v.value");
        var numberOfInstallment = component.find("text-input-numberOfInstallment").get("v.value");
        if($A.util.isEmpty(startDate)) {
            $A.util.addClass(startDate, "slds-has-error");
            hasError = true;
            errorsList.push("Please Enter Start Date");
        } else {
            $A.util.removeClass(startDate, "slds-has-error");
        }
        if($A.util.isEmpty(revenue) /* || revenue <= 0 */) {
            $A.util.addClass(revenue, "slds-has-error");
            hasError = true;
            errorsList.push("Please Enter Revenue Amount");
        } else {
            $A.util.removeClass(revenue, "slds-has-error");
        }
        if($A.util.isEmpty(scheduleType)) {
            $A.util.addClass(scheduleType, "slds-has-error");
            hasError = true;
            errorsList.push("Please Enter Schedule Type");
        } else {
            $A.util.removeClass(scheduleType, "slds-has-error");
        }
        if($A.util.isEmpty(installmentPeriod)) {
            $A.util.addClass(installmentPeriod, "slds-has-error");
            hasError = true;
            errorsList.push("Please Enter Installment Period");
        } else {
            $A.util.removeClass(installmentPeriod, "slds-has-error");
        }
        if($A.util.isEmpty(numberOfInstallment) || numberOfInstallment.includes('.') 
           || numberOfInstallment <=0 || numberOfInstallment > 156) {
            
            $A.util.addClass(numberOfInstallment, "slds-has-error");
            errorsList.push("Please Enter Number Of Installments Between 0 to 156");
            hasError = true;
        } else {
            $A.util.removeClass(numberOfInstallment, "slds-has-error");
        }
        if(hasError) {
            helper.setToast(component, event, helper, errorsList, "error", "Error!");
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            return;
        }
        var revenueNew = parseFloat(revenue);
        var decimalPlace = component.get("v.decimalPlace");
        revenueNew = revenueNew.toFixed(decimalPlace);
        var olisDate = helper.createDateList(component, event, helper, startDate, installmentPeriod, numberOfInstallment);
        helper.createSchedules(component, event, helper, revenueNew, installmentPeriod, numberOfInstallment, olisDate, scheduleType); 
        /*var establishWrapper = {oliId : oppLineItem.Id, 
            startDate : startDate,
            revenue : revenueNew,
            scheduleType : scheduleType,
            installmentPeriod : installmentPeriod,
            noOfInstallment : numberOfInstallment,
            type : "Revenue"
        };
        var action = component.get("c.establishSchedule");
        action.setParams({
            jsonWrapper : JSON.stringify(establishWrapper)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                var toastMessage;
                var toastTitle;
                var toastType;
                toastMessage = [];
                var msg = "Schedules has been created successfully.";
                toastMessage.push(msg);
                toastTitle = "Success!";
                toastType = "success";
                helper.setToast(component, event, helper, toastMessage, toastType, toastTitle);
                var oppWrapper = result;
                var oliWrapper = oppWrapper.oliWrapperList;
                var oli = oliWrapper[0].oliRecord;
                component.set("v.oppLineItem", oli);
                component.find("text-input-revenue").set("v.value", oliWrapper[0].oliRecord.TotalPrice);
                component.set("v.olisWrapper", oliWrapper[0].revSchWrapperList);
                if(oliWrapper[0].oliRecord.OpportunityLineItemSchedules != undefined) {
                    component.set("v.olisList", oliWrapper[0].oliRecord.OpportunityLineItemSchedules);
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                    }
                } else {
                    helper.setToast(component, event, helper, "Unknown error", "error", "Error!");
                }
            }
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        })
        $A.enqueueAction(action);*/
    }, 
    
    delete : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var olisWrapper = component.get("v.olisWrapper")
        var olisWrapperNew = [];
        for(var i = 0; i < olisWrapper.length; i++) {
            olisWrapperNew.push({
                schRecord : olisWrapper[i].schRecord,
                operationType : "none"
            });
        }
        var action = component.get("c.updateOliSchedule");
        action.setParams({
            jsonWrapper : JSON.stringify(olisWrapperNew)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastMessage = [];
                var msg = "Schedules has been deleted successfully.";
                toastMessage.push(msg);
                helper.setToast(component, event, helper, toastMessage, "success", "Success!");
                helper.fadeOutRevenueModel(component, event, helper);
            } else if(state === "ERROR") {
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                var errors = response.getError();
                if (errors) {
                    var errorMsg = JSON.parse(errors[0].message).errorList;
                    helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                }
            } else {
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                helper.setToast(component, event, helper, "Unknown Error", "error", "Error!");
            }
        })
        $A.enqueueAction(action);
    },
        
    createDateList : function(component, event, helper, startDate, installmentPeriod, numberOfInstallment) {
        var olisDate = [];
        var actualDate = startDate.split("-");
        var tempDate = new Date(actualDate[0], actualDate[1]-1, actualDate[2], 0, 0, 0, 0);
        olisDate.push(helper.formatDate(component, event, helper, tempDate));
        var lastDayOfActualMonth = new Date(actualDate[0], actualDate[1], 0).getDate();
        var useLastDate = false;
        if(lastDayOfActualMonth == actualDate[2]) {
            useLastDate = true;
        }
        for(var index = 1; index < numberOfInstallment; index++) {
            if(installmentPeriod == "Daily") {
                tempDate.setDate(tempDate.getDate() + 1);
            } else if(installmentPeriod == "Weekly") {
                tempDate.setDate(tempDate.getDate() + 7);
            } else if(installmentPeriod == "Monthly") {
                var lastDay = helper.dayOfMonth(tempDate.getFullYear(), tempDate.getMonth() + 1, actualDate[2], useLastDate);
                var setTempDate = new Date(tempDate.getFullYear(), tempDate.getMonth() + 1, lastDay);
                tempDate = setTempDate;
            } else if(installmentPeriod == "Quarterly") {
                var lastDay = helper.dayOfMonth(tempDate.getFullYear(), tempDate.getMonth() + 3, actualDate[2], useLastDate);
                var setTempDate = new Date(tempDate.getFullYear(), tempDate.getMonth() + 3, lastDay);
                tempDate = setTempDate;
            } else if(installmentPeriod == "Yearly") {
                var lastDay = helper.dayOfMonth(tempDate.getFullYear(), tempDate.getMonth() + 12, actualDate[2], useLastDate);
                var setTempDate = new Date(tempDate.getFullYear(), tempDate.getMonth() + 12, lastDay);
                tempDate = setTempDate;
            } else if(installmentPeriod == "Semesterly") {
                var lastDay = helper.dayOfMonth(tempDate.getFullYear(), tempDate.getMonth() + 6, actualDate[2], useLastDate);
                var setTempDate = new Date(tempDate.getFullYear(), tempDate.getMonth() + 6, lastDay);
                tempDate = setTempDate;
            }
            var dt = helper.formatDate(component, event, helper, tempDate);
            olisDate.push(dt);
        }
        return olisDate;
    },
    
    createSchedules : function (component, event, helper, revenueNew, installmentPeriod, numberOfInstallment, olisDate, scheduleType) {
        var amount;
        if(scheduleType == "Divide Amount into multiple installments") {
            amount = Math.floor(revenueNew/numberOfInstallment);
        } else if(scheduleType == "Repeat Amount for each installment") {
            amount = revenueNew;
            component.find("text-input-revenue").set("v.value", amount * numberOfInstallment);
        }
        var sumOfAmount = amount * (numberOfInstallment - 1);
        var oliSchList = [];
        for(var i = 0; i < numberOfInstallment; i++) {
            oliSchList.push ({
                Revenue : amount,
                ScheduleDate : olisDate[i],
                "Type" : "Revenue"
            });
        }
        if(scheduleType == "Divide Amount into multiple installments") {
            oliSchList[numberOfInstallment - 1].Revenue = revenueNew - sumOfAmount;
        }
        console.log(oliSchList);
        component.set("v.olisList", oliSchList);
        //component.set("v.establishButton", "Re Establish");
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
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
        for(var x in errorMsg) {
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
    },
        
    dayOfMonth : function (y, m, currDate, toUseLastDate) {
        var lastDateOfMonth = new Date(y, m+1, 0).getDate();
        if(!toUseLastDate && lastDateOfMonth > currDate) {
            lastDateOfMonth = currDate;
        }
        return lastDateOfMonth;
    },
        
    save : function(component, event, helper) {
        var olisList = component.get("v.olisList");
        var boolean = false;
        var today = new Date();
        var mm = parseInt(String(today.getMonth() + 1).padStart(2, '0'));
        var yyyy = parseInt(today.getFullYear());
        for(var i = 0; i < olisList.length; i++) {
            var scheduleDate = olisList[i].ScheduleDate;
            var year = parseInt(scheduleDate.substring(0,4));
            var month = parseInt(scheduleDate.substring(5,7));
            if(year < yyyy || ( month < mm && year == yyyy)) {
                boolean = true;
            }
        }
        if(boolean == true) {
            $A.createComponent("c:AddRevenueScheduleConfirmation", {"eventType1" : "EstablishRevenue"},
                               function(content, status) {
                                   if (status === "SUCCESS") {
                                       var modalBody = content;
                                       component.find('overlayLib').showCustomModal({
                                           header: "The date you have selected belongs to a previous month. Are you sure you wish to continue?",
                                           body: modalBody, 
                                           closeCallback: function(ovl) {
                                               console.log('Overlay is closing');
                                           }
                                       }).then(function(overlay){
                                           console.log("Overlay is made");
                                       });
                                   }
                               });
        } else {
            helper.saveAndClose(component, event, helper);
        } 
    },
})