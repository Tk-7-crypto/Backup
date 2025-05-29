({
    getOLISchedules : function(component, event, helper) {
        var oliWrapper = component.get("v.oliWrapper");
        console.log(oliWrapper);
        var olisList = [];
        component.set("v.productName", oliWrapper[0].oliRecord.Product2.Name);
        component.set("v.currencyCode", oliWrapper[0].oliRecord.CurrencyIsoCode);
        component.find("text-input-revenue").set("v.value", event.getParams().price);
        if(oliWrapper[0].olisWrapper != undefined && oliWrapper[0].olisWrapper.length > 0) {
            component.set("v.establishButton", "Re Establish");
            var schList = [];
            for(var i = 0; i < oliWrapper[0].olisWrapper.length; i++) {
                schList.push(oliWrapper[0].olisWrapper[i].schRecord);
            }
            component.set("v.olisList", schList);
        }  
        helper.setOppDetail(component, event, helper);
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    
    fadeOutRevenueModel : function(component, event, helper) {
        component.set("v.isRevenueVisible",false);
        component.set("v.oliRecord", null);
        var revenueSchComp = component.find("revenueSch");
        var backDropComp = component.find("backdrop");
        $A.util.removeClass(revenueSchComp, "slds-fade-in-open");
        $A.util.removeClass(backDropComp, "slds-backdrop--open");
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    
    establish : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var startDate = component.find("text-input-start-date").get("v.value");
        var revenue = component.find("text-input-revenue").get("v.value");
        var scheduleType = component.find("select-input-scheduleType").get("v.value");
        var installmentPeriod = component.find("select-input-installmentPeriod").get("v.value");
        var numberOfInstallment = component.find("text-input-numberOfInstallment").get("v.value");
        var hasError = false;
        var errorsList =[];
        var hasLicense = component.get("v.hasLicense");
        if(hasLicense) {
            var minLic = component.find("minLic");
            var maxLic = component.find("maxLic");
            var minLicV = minLic.get("v.value");
            var maxLicV = maxLic.get("v.value");
            if($A.util.isEmpty(minLicV)) {
                minLicV = 0;
            }
            if($A.util.isEmpty(maxLicV)) {
                maxLicV = 0;
            }
            if(parseInt(minLicV) > parseInt(maxLicV)) {
                $A.util.addClass(minLic, "slds-has-error");
                $A.util.addClass(maxLic, "slds-has-error");
                hasError = true;
                errorsList.push("Min licenses should be less than max licenses");
            } else {
                $A.util.removeClass(minLic, "slds-has-error");
                $A.util.removeClass(maxLic, "slds-has-error"); 
            }
        }
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
        helper.createSchedules (component, event, helper, revenueNew, installmentPeriod, numberOfInstallment, olisDate, scheduleType); 
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
        component.set("v.olisList", oliSchList);
        component.set("v.establishButton", "Re Establish");
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
    
    dayOfMonth : function (y, m, currDate, toUseLastDate) {
        var lastDateOfMonth = new Date(y, m+1, 0).getDate();
        if(!toUseLastDate && lastDateOfMonth > currDate) {
            lastDateOfMonth = currDate;
        }
        return lastDateOfMonth;
    },
    
    clearSchedules : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        component.find("text-input-revenue").set("v.value", 0);
        component.find("text-input-numberOfInstallment").set("v.value", "12");
        component.find("select-input-installmentPeriod").set("v.value", "Monthly");
        component.find("select-input-scheduleType").set("v.value", "Divide Amount into multiple installments");
        component.set("v.olisList", []);
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    
    saveAndClose : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var oliScheduleListNew = [];
        var oliScheduleWrapperList = [];
        var errorList = [];
        var olisList = component.get("v.olisList");
        var total = 0;
        var decimalPlace = component.get("v.decimalPlace");
        for(var i = 0; i < olisList.length; i++) {
            var scheduleRecord = olisList[i];
            var rev = parseFloat(scheduleRecord.Revenue).toFixed(decimalPlace);            
            if((!$A.util.isEmpty(scheduleRecord.ScheduleDate) && (!$A.util.isEmpty(scheduleRecord.Revenue) || !scheduleRecord.Revenue == ''))) {
                total = parseFloat(total) + parseFloat(rev);
                oliScheduleListNew.push({
                    "ScheduleDate" : scheduleRecord.ScheduleDate,
                    "Revenue" : rev,
                    "Description" : scheduleRecord.Description,
                    "Type" : "Revenue"
                });
            }
        }
        console.log(total);
        if(total == null) {
            errorList.push("Sales Price is required when adding products to an opportunity.");
            helper.setToast(component, event, helper, errorList, "error", "Error!");
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            return; 
        }
        component.find("text-input-revenue").set("v.value", total);
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
        var establishSchedule = $A.get("e.c:LXE_CRM_SetScheduleEvent");
        establishSchedule.setParams({
            "olisWrapper" : oliScheduleWrapperList,
            "index" : component.get("v.index"),
            "price" : component.find("text-input-revenue").get("v.value"),
            "type" : "save",
            "oliRecord" : component.get("v.oliRecord")
        });
        establishSchedule.fire();
        component.set("v.olisList", []);
        component.set("v.establishButton", "Establish");
        helper.fadeOutRevenueModel(component, event, helper);
    },
    
    closeModel : function(component, event, helper) {
        component.set("v.olisList", []);
        component.set("v.establishButton", "Establish");
        var establishSchedule = $A.get("e.c:LXE_CRM_SetScheduleEvent");
        establishSchedule.setParams({
            "type" : "close"
        });
        establishSchedule.fire();
        helper.fadeOutRevenueModel(component, event, helper); 
    },
    
    setOppDetail : function(component, event, helper) {
        var action = component.get("c.getOpportunityDetails");
        var fieldsToShow = [];
        fieldsToShow.push("Id");
        fieldsToShow.push("Name");
        var oppId = component.get("v.recordId");
        action.setParams({ 
            oppId : oppId,
            oppFields : fieldsToShow,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.oppRecord", returnValue);
            } else if(state === "ERROR") {
                var errors = response.getError();
                var err = JSON.parse(errors[0].message).errorList;
                helper.setToast(component, event, helper, err, "error", "Error!");
            }
            var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
            appEvent.setParams({"action" : "stop"});
            appEvent.fire();
        })
        $A.enqueueAction(action);
    },
    
    setToast : function(component, event, helper, message, type, title) {
        var errorMsg = message;
        var msg = "";
        for(var x in errorMsg) {
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
            $A.createComponent("c:AddRevenueScheduleConfirmation", {"eventType1" : "AddRevenue"},
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