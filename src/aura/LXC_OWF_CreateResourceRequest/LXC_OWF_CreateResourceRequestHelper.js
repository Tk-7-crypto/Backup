({
    getCoutriesMultiselect: function(component, event, helper) {
        var action = component.get("c.getPiklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i],
                        value: result[i]
                    });
                }
                component.set("v.GenreList", plValues);
            }
        });
        $A.enqueueAction(action);
    },
    
    setResourceRequestTypesForMultipleRR : function(component, event) {
        let action = component.get("c.getResourceRequestTypesForMultipleRR");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                let multipleSubgroupList = [];
                for (let i = 0; i < result.length; i++) {
                    multipleSubgroupList.push({
                        label: result[i],
                        value: result[i]
                    });
                }
                component.set("v.MultipleSubgroupList", multipleSubgroupList);
            }
        });
        $A.enqueueAction(action);
    },
    
    //handle RR Save
    saveResourceRequest : function(component, event) {
        component.set("v.Spinner", true);
        var bidCreatedDate = new Date(component.get("v.bidHistoryRecord.CreatedDate")).toISOString().split('T')[0];
        var bidDueDate = new Date(component.get("v.bidHistoryRecord.Bid_Due_Date__c")).toISOString().split('T')[0];
        var bidHistoryID =  component.get("v.recordId");
        var RRStartDate;
        var RREndDate;
        if(component.get("v.rr.Is_Bid_Defense__c")){
            RRStartDate = '';
            RREndDate = '';
        }else{
            RRStartDate = component.find("startDate").get("v.value");
            RREndDate = component.find("endDate").get("v.value");
        }
        component.set("v.rr.Bid_History__c" , bidHistoryID);
        var rr = component.get("v.rr"); 
        if((RRStartDate !== '' && (bidCreatedDate > RRStartDate || RRStartDate > bidDueDate))
           || (RREndDate !== '' && (bidCreatedDate > RREndDate || RREndDate > bidDueDate))){
            var toastEvent;
            component.set("v.Spinner", false);
            toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Validate Resource Request',
                message: 'Please Select Valid Start Date and End Date',
                duration:'5000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            component.set("v.Spinner", false);
        }else{
            if(RRStartDate !== null){
                component.set("v.rr.pse__Start_Date__c" , RRStartDate);  
            }
            if(RREndDate !== null){
                component.set("v.rr.pse__End_Date__c" , RREndDate);  
            }
            var action = component.get("c.saveResourceRequest");
            action.setParams({
                objRR : rr,
                //Add here list of countries
                selectedCountriesList : component.get("v.selectedGenreList"),
                selectedAll:component.get("v.selectAllCountries"),
                noOfRRToBeCreated : component.get("v.selectNoOfRRToBeCreated"),
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                var toastEvent;
                if(state === "SUCCESS"){
                    // Close the action panel
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Resource Request',
                        message: "Resource Request Created.",
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    
                } else if(state === "ERROR"){
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            errors[0].message = errors[0].message.substring(errors[0].message.indexOf(',')+1,errors[0].message.lastIndexOf(':'));
                            toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Validate Resource Request',
                                message: errors[0].message,
                                duration:'5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }
                        component.set("v.Spinner", false);
                    }
                }else if (status === "INCOMPLETE"){
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Validate Resource Request',
                        message: 'No response from server or client is offline.',
                        duration:'5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    component.set("v.Spinner", false);
                }
            });       
            $A.enqueueAction(action);
        }
        
    },
    
    createMultipleAnalyticsRequests: function(component, event) {
        component.set("v.Spinner", true);
        var bidHistoryID =  component.get("v.recordId");
        var bidCreatedDate = component.get("v.bidHistoryRecord.CreatedDate");
        var bidDueDate = component.get("v.bidHistoryRecord.Bid_Due_Date__c");
        var RRStartDate = component.find("startDateForMultipleRR").get("v.value");
        var RREndDate = component.find("endDateForMultipleRR").get("v.value");
        let selectedSubgroups = component.get("v.SelectedMultipleSubgroupList");
        if((RRStartDate !== '' && (bidCreatedDate > RRStartDate || RRStartDate > bidDueDate))
           || (RREndDate !== '' && (bidCreatedDate > RREndDate || RREndDate > bidDueDate))){
            var toastEvent;
            toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Validate Resource Request',
                message: 'Please Select Valid Start Date and End Date',
                duration:'5000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            component.set("v.Spinner", false);
        }else{
            if(RRStartDate != null){
                component.set("v.rr.pse__Start_Date__c" , RRStartDate);  
            }
            if(RREndDate != null){
                component.set("v.rr.pse__End_Date__c" , RREndDate);  
            }
            if (selectedSubgroups.length === 0) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'No Subgroup selected',
                    message: 'Please select a value',
                    duration:'5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.Spinner", false);
            } else {
                let action1 = component.get('c.showSpinner');
                $A.enqueueAction(action1);
                let resourceRequests = [];
                for (let i = 0; i < selectedSubgroups.length; i++) {
                    resourceRequests.push({'sobjectType': 'pse__Resource_Request__c', 
                                           'Is_Bid_Defense__c': 'false',
                                           'Bid_History__c': bidHistoryID,
                                           'SubGroup__c': selectedSubgroups[i],
                                           'pse__Start_Date__c': component.get("v.rr.pse__Start_Date__c"),
                                           'pse__End_Date__c': component.get("v.rr.pse__End_Date__c")
                                          });
                }
                let action = component.get("c.saveMultipleAnalyticsRequests");
                action.setParams({
                    resourceRequests : resourceRequests
                });
                action.setCallback(this,function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        // Close the action panel
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Resource Request',
                            message: "Resource Request Created.",
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", false);
                    } else if(state === "ERROR"){
                        
                        var errors = action.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                errors[0].message = errors[0].message.substring(errors[0].message.indexOf(',')+1,errors[0].message.lastIndexOf(':'));
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Validate Resource Request',
                                    message: errors[0].message,
                                    duration:'5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                            }
                            component.set("v.Spinner", false);
                        }
                    }else if (status === "INCOMPLETE") {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Validate Resource Request',
                            message: 'No response from server or client is offline.',
                            duration:'5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", false);
                    }
                });       
                $A.enqueueAction(action);
            }
        }
    },
    initResourceRequest : function(component, event) {
        var action = component.get("c.getRecordType");
    	action.setCallback(this, function(a) {
     	component.set("v.Resource_Request", a.getReturnValue())
    	});
    	$A.enqueueAction(action);
    },
    validateNoOfRRSelected : function(component, event) {
        var rrIterator = component.get("v.selectNoOfRRToBeCreated",rrIterator);
        if(rrIterator>10){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "error",
                "message": "Please select up to 10 values at one time."
            });
            toastEvent.fire();
            component.set("v.Spinner", false);								  
        }
        if(rrIterator != '' && rrIterator == 0 ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "error",
                "message": "Value of Select No of RR to be created should be greater than 0."
            });
            toastEvent.fire();
            component.set("v.Spinner", false);
        }  
    },
    calculateWindowHeight : function(component) {
        var windowHeight = window.innerHeight;
        var calculatedHeight;
        if(windowHeight > 680) {
            calculatedHeight = (windowHeight - 600)/2 +64 + 'px';
        }
        else{
            calculatedHeight = '8rem';
        }
        component.set("v.calculatedHeight", calculatedHeight);
	}
})