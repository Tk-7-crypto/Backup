({
	doInit: function (component, event, helper) {
        console.log("init frequency");
        helper.getRecord(component, event);
    },
    
    openForm : function (component, event, helper) {
        $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-hide");
        $A.util.addClass(component.find("modaldialog"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop--hide");
        $A.util.addClass(component.find("backdrop"), "slds-backdrop--open");
        var freqList = component.get("v.frequencyValues");
        var options = [];
        for(var i=0; i<freqList.length; i++){
            var option = {};
            option.label = freqList[i];
            option.value = freqList[i];
            option.class = "optionClass";
            options.push(option);
        }
        component.find("FrequencySelect").set("v.options", options);
        component.find("FrequencySelect").set("v.value", component.get("v.simpleRecord.Frequency__c"));
        if(component.get("v.simpleRecord.Frequency__c") == 'Weekly' || component.get("v.simpleRecord.Frequency__c") == 'Monthly'){
            helper.frequencyChange(component, event);
        }
    },
    
    closeForm : function (component, event, helper) {
        $A.util.addClass(component.find("modaldialog"), "slds-fade-in-hide");
        $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop"), "slds-backdrop--hide");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop--open");
        $A.get('e.force:refreshView').fire();
    },
    
    onFrequencyChange : function(component, event, helper) {
        helper.frequencyChange(component, event);
    },
    
    onWeekdayChange : function(component, event, helper) {
        component.set("v.simpleRecord.Weekday__c", component.find("WeeklySelect").get("v.value"));
    },
    
    onGroupChange : function(component, event, helpler) {
        var node = event.getSource();
        var id = node.getLocalId();
        if(id == 'MonthlyDate'){
            component.set("v.disableMonthDate", false);
            component.set("v.disableMonthWeek", true);
            component.set("v.simpleRecord.Week__c", '');
            component.set("v.simpleRecord.Weekday__c", '');
            component.set("v.simpleRecord.Month_Date__c", component.find("DateSelect").get("v.value"));
            component.set("v.simpleRecord.Month_Interval__c", component.find("MonthSelect").get("v.value"));
        }
        else if(id == 'MonthlyWeek'){
            component.set("v.disableMonthDate", true);
            component.set("v.disableMonthWeek", false);
            component.set("v.simpleRecord.Week__c", component.find("WeekSelect").get("v.value"));
            component.set("v.simpleRecord.Weekday__c", component.find("WeekdaySelect").get("v.value"));
            component.set("v.simpleRecord.Month_Date__c", '');
            component.set("v.simpleRecord.Month_Interval__c", component.find("MonthIntervalSelect").get("v.value"));
        }
    },
    
    onDateChange : function(component, event, helper){
        component.set("v.simpleRecord.Month_Date__c", component.find("DateSelect").get("v.value"));
    },
    
    onMonthIntervalChange : function(component, event, helper){
        component.set("v.simpleRecord.Month_Interval__c", component.find("MonthSelect").get("v.value"));
    }, 
    
    onWeekChange : function(component, event, helper){
        component.set("v.simpleRecord.Week__c", component.find("WeekSelect").get("v.value"));
    },
    
    onMonthlyWeekdayChange : function(component, event, helper){
        component.set("v.simpleRecord.Weekday__c", component.find("WeekdaySelect").get("v.value"));
    },
    
    onWeekMonthIntervalChange : function(component, event, helper){
        component.set("v.simpleRecord.Month_Interval__c", component.find("MonthIntervalSelect").get("v.value"));
    },
    
    onSubmit : function(component, event, helper){
        if(component.get("v.simpleRecord.Frequency__c") == 'Monthly'){
            if(component.get("v.disableMonthDate") == true && component.get("v.disableMonthWeek") == true){
                var message = 'Please select atleast one type of monthly frequency';
                helper.showToastMessage(component, event, message);
                return;
            }
        }
        console.log('-------------');
        component.set("v.isModalLoading", true);
        helper.saveFrequencyRecord(component, event);
    }
})