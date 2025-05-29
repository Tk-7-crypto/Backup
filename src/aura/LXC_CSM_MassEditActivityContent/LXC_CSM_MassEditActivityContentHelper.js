({
    loadActivityWrapperList : function(component){
        var action = component.get("c.getAllRelatedActivities");
        action.setParams({ 
            "recordId": component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                              
                var result = response.getReturnValue();
                var activityWrapperList = JSON.parse(result);
                component.set('v.activityWrapperList', activityWrapperList);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    setPaginationList : function(component, event){ 
        var activityWrapperList = component.get('v.activityWrapperList');
        if(activityWrapperList.length > 0){
            var pageSize = component.get("v.pageSize");
            var totalRecordsList = activityWrapperList;
            var totalLength = totalRecordsList.length ;
            component.set("v.totalRecordsCount", totalLength);
            component.set("v.startPage",0);
            component.set("v.endPage",pageSize-1);
            var PaginationList = [];                    
            for(var i = 0; i < pageSize; i++){
                if(component.get("v.activityWrapperList").length > i){
                    PaginationList.push(activityWrapperList[i]);    
                } 
            }
            component.set('v.PaginationList', PaginationList);
            this.setDependentPicklistValues(component);
            component.set("v.selectedCount" , 0);
            component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));   
        } else{
            component.set("v.bNoRecordsFound" , true);
        } 
    },
    
    setActivityListToBeUpdated: function(component, btn) {
        var PaginationList = component.get('v.PaginationList');
        var activityWrapperMapToSave = component.get('v.activityWrapperMapToSave');
        var activityWrapperMapKeySet = component.get('v.activityWrapperMapKeySet');
        if(activityWrapperMapToSave.length == 0) {
            var activity = PaginationList[0].activity;
            var activityWrapper = {'activity': activity};
            activityWrapperMapToSave.push({key: activity.Id, value: activityWrapper});
            activityWrapperMapKeySet.push(activity.Id);
        }
        for(var i = 0; i < PaginationList.length; i++) {
            var activity = PaginationList[i].activity;
            if(activity != undefined && activity != null) {
                var key = activity.Id;
                var activityWrapper = {'activity': activity};
                if(activityWrapperMapKeySet.includes(key)) {
                    var keys = activityWrapperMapToSave.keys();
                    for(var keyInLoop of keys) {
                        if(activityWrapperMapToSave[keyInLoop].key == key) {
                            activityWrapperMapToSave[keyInLoop].value = activityWrapper;
                            break;                        
                        }
                    }
                } else {
                    activityWrapperMapToSave.push({key: key, value: activityWrapper});
                    activityWrapperMapKeySet.push(key);
                }
            }
        }
        component.set('v.activityWrapperMapKeySet', activityWrapperMapKeySet);
        component.set('v.activityWrapperMapToSave', activityWrapperMapToSave);
    },
    
    saveActivities: function(component) {
        var activityWrapperMapToSave = component.get('v.activityWrapperMapToSave');
        var activityList = [];
        if(activityWrapperMapToSave != undefined && activityWrapperMapToSave.length > 0) {
            for(var i = 0; i < activityWrapperMapToSave.length; i++) {
                var activity = activityWrapperMapToSave[i].value.activity;
                activity.Status__c = activity.Status__c == 'Please Specify' ? '' : activity.Status__c;
                activity.PassFail__c = activity.PassFail__c == 'Please Specify' ? '' : activity.PassFail__c;
                activity.LOS__c = activity.LOS__c == 'Please Specify' ? '' : activity.LOS__c;
                activity.Type__c = activity.Type__c == 'Please Specify' ? '' : activity.Type__c;
                activity.EscalationType__c = activity.EscalationType__c == 'Please Specify' ? '' : activity.EscalationType__c;
                activity.RandD_Location__c = activity.RandD_Location__c == 'Please Specify' ? '' : activity.RandD_Location__c;
                activity.Email_Categorization__c = activity.Email_Categorization__c == 'Please Specify' ? '' : activity.Email_Categorization__c;
                activityList.push(activity);
            }
            var action = component.get("c.updateActivities");
            action.setParams({ 
                "activityListJSON": JSON.stringify(activityList)
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {                              
                    var result = response.getReturnValue();
                    this.showMessage("Success", "Activities updated successfully!!", "success");
                    $A.get('e.force:refreshView').fire();
                }
                else if(state === "ERROR") {
                    var errors = response.getError();
                    this.handleErrors(errors);
                    component.set('v.SpinnerMassEditActivity', false);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    next : function(component, event, sObjectList, end, start, pageSize) {
        var Paginationlist = [];
        var counter = 0;
        this.setActivityListToBeUpdated(component, 'next');
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
        this.setDependentPicklistValues(component);
    },
    
    previous : function(component, event, sObjectList, end, start, pageSize) {
        var Paginationlist = [];
        var counter = 0;
        this.setActivityListToBeUpdated(component, 'previous');
        for(var i = start-pageSize; i < start ; i++) {
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    setDependentPicklistValues: function(component) {
        var pageSize = component.get("v.pageSize");
        var picklistWrapper = component.get("v.picklistWrapper");
        var paginationList = component.get('v.PaginationList');
        for(var i = 0; i < pageSize; i++) { 
            if(component.get("v.PaginationList").length > i) {
                var activity = paginationList[i].activity;
                if(activity.EscalationType__c != undefined && activity.EscalationType__c != null && activity.EscalationType__c != '' && activity.EscalationType__c != 'Please Specify') {
                    paginationList[i].typeValues = picklistWrapper.mapOfLOSAndTypeValues[activity.LOS__c];
                    paginationList[i].escalationTypeValues = picklistWrapper.mapOfTypeAndEscalationTypeValues[activity.Type__c];
                    if(paginationList[i].typeValues.length == 0) {
                        paginationList[i].escalationTypeValues = [];
                        paginationList[i].activity.EscalationType__c = '';
                        paginationList[i].activity.Type__c = '';
                    }
                } else if(activity.Type__c != undefined && activity.Type__c != null && activity.Type__c != '' && activity.Type__c != 'Please Specify') {
                    paginationList[i].typeValues = picklistWrapper.mapOfLOSAndTypeValues[activity.LOS__c];
                    paginationList[i].escalationTypeValues = picklistWrapper.mapOfTypeAndEscalationTypeValues[activity.Type__c];
                } else if(activity.LOS__c != undefined && activity.LOS__c != null && activity.LOS__c != '' && activity.LOS__c != 'Please Specify') {
                    paginationList[i].typeValues = picklistWrapper.mapOfLOSAndTypeValues[activity.LOS__c];
                }
            } 
        }
        component.set("v.PaginationList", paginationList);
    },
    
    loadPicklistValues : function(component, event) {
        var action = component.get("c.getPickListValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                              
                var result = response.getReturnValue();
                var picklistWrapperInstance = JSON.parse(result);
                var picklistWrapper = component.get("v.picklistWrapper"); 
                picklistWrapper.statusValues = JSON.parse(picklistWrapperInstance.statusValues);
                picklistWrapper.passFailValues = JSON.parse(picklistWrapperInstance.passFailValues);
                picklistWrapper.losValues = JSON.parse(picklistWrapperInstance.losValues);
                picklistWrapper.emailCategorizationValues = JSON.parse(picklistWrapperInstance.emailCategorizationValues);
                picklistWrapper.locationValues = JSON.parse(picklistWrapperInstance.locationValues);
                picklistWrapper.mapOfLOSAndTypeValues = JSON.parse(picklistWrapperInstance.mapOfLOSAndTypeValues);
                picklistWrapper.mapOfTypeAndEscalationTypeValues = JSON.parse(picklistWrapperInstance.mapOfTypeAndEscalationTypeValues);
                component.set("v.picklistWrapper", picklistWrapper);
                this.setPaginationList(component, event);
                this.hideSpinner(component);                
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    showMessage : function(title, message, type) {
        var toastParams = {
            title: title,
            message: message, 
            type: type
        };
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    
    handleErrors : function(errors) {
        var toastParams = {
            title: "Error",
            message: "Unknown error", 
            type: "error"
        };
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message.split(',')[1].split(':')[0];
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    
    showSpinner: function(component) {
        component.set("v.SpinnerMassEditActivity", true); 
    },
    
    hideSpinner : function(component) {
        component.set("v.SpinnerMassEditActivity", false);
    },
})