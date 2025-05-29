({
	getRecord: function (component, event) {
		var recordId = component.get("v.recordId");
        var objName = component.get("v.sObjectName");
        component.set("v.isModalLoading", false);
        var action = component.get("c.getParentRecord");
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
                    var simpleData = {};
                    simpleData.Frequency__c = object.Frequency__c;
                    component.set("v.simpleRecord", simpleData);
                    if(object.FrequencyId__c != undefined){
                        var frequencyId = object.FrequencyId__c;
                        this.getFrequencyRecord(component, event, frequencyId);
                    }
                    else{
                        component.set("v.isLoading", false);
                    }
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    getFrequencyRecord : function(component, event, frequencyId){
        var action = component.get("c.fetchFrequencyRecord");
        action.setParams({
            "frequencyId": frequencyId,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.simpleRecord", response.getReturnValue()[0]);
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    frequencyChange : function(component, event){
        var freqValue = component.find("FrequencySelect").get("v.value");
        component.set("v.simpleRecord.Frequency__c", freqValue);
        if(freqValue == 'Daily'){
            component.set("v.disableMonthDate", true);
            component.set("v.disableMonthWeek", true);
            component.set("v.simpleRecord.Month_Date__c", '');
            component.set("v.simpleRecord.Month_Interval__c", '');
            component.set("v.simpleRecord.Week__c", '');
            component.set("v.simpleRecord.Weekday__c", '');
        }
        if(freqValue == 'Weekly'){
            component.set("v.disableMonthDate", true);
            component.set("v.disableMonthWeek", true);
            component.set("v.simpleRecord.Month_Date__c", '');
            component.set("v.simpleRecord.Month_Interval__c", '');
            component.set("v.simpleRecord.Week__c", '');
            var weekList = component.get("v.weeklyValues");
            var options = [];
            for(var i=0; i<weekList.length; i++){
                var option = {};
                option.label = weekList[i];
                option.value = weekList[i];
                option.class = "optionClass";
                options.push(option);
            }
            component.find("WeeklySelect").set("v.options", options);
            if(component.get("v.simpleRecord.Weekday__c") != undefined){
                component.find("WeeklySelect").set("v.value", component.get("v.simpleRecord.Weekday__c"));
            }
            else{
                component.set("v.simpleRecord.Weekday__c", weekList[0]);
            }
        }
        else if(freqValue == 'Monthly'){
            var dateList = component.get("v.dateValues");
            var dateOptions = [];
            for(var i=0; i<dateList.length; i++){
                var option = {};
                option.label = dateList[i];
                option.value = dateList[i];
                option.class = "optionClass";
                dateOptions.push(option);
            }
            var monthList = component.get("v.monthValues");
            var monthOptions = [];
            for(var i=0; i<monthList.length; i++){
                var option = {};
                option.label = monthList[i];
                option.value = monthList[i];
                option.class = "optionClass";
                monthOptions.push(option);
            }
            var weekList = component.get("v.weekValues");
            var weekOptions = [];
            for(var i=0; i<weekList.length; i++){
                var option = {};
                option.label = weekList[i];
                option.value = weekList[i];
                option.class = "optionClass";
                weekOptions.push(option);
            }
            var dayList = component.get("v.weeklyValues");
            var dayOptions = [];
            for(var i=0; i<dayList.length; i++){
                var option = {};
                option.label = dayList[i];
                option.value = dayList[i];
                option.class = "optionClass";
                dayOptions.push(option);
            }
            component.find("DateSelect").set("v.options", dateOptions);
            component.find("MonthSelect").set("v.options", monthOptions);
            if(component.get("v.simpleRecord.Month_Date__c") != undefined && component.get("v.simpleRecord.Month_Interval__c") != undefined){
                component.find("DateSelect").set("v.value", component.get("v.simpleRecord.Month_Date__c"));
                component.find("MonthSelect").set("v.value", component.get("v.simpleRecord.Month_Interval__c"));
            }
            component.find("WeekSelect").set("v.options", weekOptions);
            component.find("WeekdaySelect").set("v.options", dayOptions);
            component.find("MonthIntervalSelect").set("v.options", monthOptions);
            if(component.get("v.simpleRecord.Week__c") != undefined && component.get("v.simpleRecord.Weekday__c") != undefined && 
               component.get("v.simpleRecord.Month_Interval__c") != undefined){
                component.find("WeekSelect").set("v.value", component.get("v.simpleRecord.Week__c"));
                component.find("WeekdaySelect").set("v.value", component.get("v.simpleRecord.Weekday__c"));
                component.find("MonthIntervalSelect").set("v.value", component.get("v.simpleRecord.Month_Interval__c"));
            }
        }
    },
    
    saveFrequencyRecord : function(component, event){
        var record = component.get("v.simpleRecord");
        var recordId = component.get("v.recordId");
        var jsonObject = JSON.stringify(record);
        var action = component.get("c.saveFrequency");
        action.setParams({
            "jsonString" : jsonObject,
            "recordId" : recordId,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set("v.isModalLoading", false);
            component.set("v.isLoading", true);
            this.getRecord(component, event);
            $A.util.addClass(component.find("modaldialog"), "slds-fade-in-hide");
            $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-open");
            $A.util.addClass(component.find("backdrop"), "slds-backdrop--hide");
            $A.util.removeClass(component.find("backdrop"), "slds-backdrop--open");
        });
        $A.enqueueAction(action);
    },
    
    showToastMessage : function(component, event, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message,
            "type": "error"
        });
        toastEvent.fire();
    }
})