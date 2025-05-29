({
    pickStatus:function(component,parentValue,methodname){
        var action = component.get("c.getSubStatusValueChange");
        action.setParams({ 
            "status": parentValue
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {       
                var priorityList = response.getReturnValue();
                var priorityNamesArray = [];
                priorityNamesArray.push('None');
                for (var i = 0; i < Object.keys(priorityList).length; i++) {
                    var productName = priorityList[i];
                    priorityNamesArray.push(productName);
                }
                if(methodname == 'PickStatusChange') component.set("v.newContact.SubStatus__c", '');
                component.set("v.substatus", priorityNamesArray);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPreviousqueue:function(component,recordData)
    {
        var action = component.get("c.getPreviousQueueValue");
        action.setParams({
            "recordId": recordData
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {       
                var priorityList = response.getReturnValue();
                var priorityNamesArray = [];            
                for (var i = 0; i < priorityList.length; i++) {
                    var productName = priorityList[i];                
                    priorityNamesArray.push(productName);
                }
                component.set("v.previousqueue", priorityNamesArray);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getSubstatus:function(component)
    {
        var action = component.get("c.getSubStatusValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {       
                var priorityList = response.getReturnValue();
                var priorityNamesArray = [];
                for (var i = 0; i < Object.keys(priorityList).length; i++) {
                    var productName = priorityList[i];                
                    priorityNamesArray.push(productName);          
                }
                priorityNamesArray.push('None');
                component.set("v.substatus", priorityNamesArray);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPreviousqueueBasedUser:function(component,prevUsedBased,recordData)
    {
        var action = component.get("c.getPreviousQueueAssignUser");
        action.setParams({
            "userId": prevUsedBased,
            "recordD" :recordData
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {       
                var priorityList = response.getReturnValue();
                console.log('pr',priorityList);
                var priorityNamesArray = [];            
                for (var i = 0; i < priorityList.length; i++) {
                    var productName = priorityList[i];                
                    priorityNamesArray.push(productName);
                }
                component.set("v.previousqueueBasedonUser", priorityNamesArray);
                component.set("v.previousqueue", priorityNamesArray);
                
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPrevioususer:function(component,recordData)
    {
        var action = component.get("c.getOldCaseOwnerUser");
        action.setParams({
            "recordId": recordData
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {       
                var priorityList = response.getReturnValue();
                var priorityNamesArray = [];            
                for (var i = 0; i < priorityList.length; i++) {
                    var productName = priorityList[i];                
                    priorityNamesArray.push(productName);
                }
                component.set("v.previoususer", priorityNamesArray);
       
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    getPreviousOwner:function(component,recordData)
    {
        var action = component.get("c.getOldCaseOwner");
        action.setParams({
            "recordId": recordData
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {       
                var priorityList = response.getReturnValue();
                var priorityNamesArray = [];            
                for (var i = 0; i < priorityList.length; i++) {
                    var productName = priorityList[i];                
                    priorityNamesArray.push(productName);
                }
                component.set("v.previousowner", priorityNamesArray);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    getPreviousQueueBasedOnAssignee :function(component,recordData)
    {
        var action = component.get("c.getPreviousQueueBasedOnAssignee");
        action.setParams({
            "recordId": recordData
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {       
                var priorityList = response.getReturnValue();
                var priorityNamesArray = [];            
                for (var i = 0; i < priorityList.length; i++) {
                    var productName = priorityList[i];
                    priorityNamesArray.push(productName);
                }
                if(priorityNamesArray.length>0){
                    component.set("v.previousqueue", priorityNamesArray);
                    component.set("v.newContact.Previous_User__c",recordData);
                }
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    openFormDispatch: function (component) {
        var selectedIndustry = component.find("Prev");
        var selectedIndustry1 = component.get("v.previousowner");
        var selectedDispatch = component.get("v.newContact.PreviousQueueUser__c");
        if(selectedDispatch != 'Please Specify')
        {
            var action = component.get("c.getIdFromQueue");
                action.setParams({
                    "recordId": selectedDispatch
                });
                action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {       
                    var priorityList = response.getReturnValue();
                    var priorityNamesArray = [];            
                    for (var i = 0; i < priorityList.length; i++) {
                        productName = priorityList[i].Id;
                        groupName = priorityList[i].Name;
                        priorityNamesArray.push(productName);
                    }
                    var selectedRecord = {label: groupName, value: productName};
                        if( component.find("LookupOwner")!= undefined){
                            component.find("LookupOwner").selectedRecord = selectedRecord;
                            component.find("LookupOwner").set("v.selectedRecord",selectedRecord);
                        }
                }
                else if(state === "ERROR") {
                    var errors = response.getError();
                    component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
        }
        var QueueUSer = selectedIndustry.get("v.value");
        if(QueueUSer != 'Please Specify'){
            component.set("v.radioGroupVis",true);
        }
        var recordData = component.get("v.recordId");
        this.getPreviousqueue(component,recordData);
        var selectedIndustry2 = component.get("v.previousqueue");
        if(!selectedIndustry2.includes(selectedIndustry.get("v.value")) && QueueUSer != 'Please Specify' ){
            $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-hide");
            $A.util.addClass(component.find("modaldialog"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"), "slds-backdrop--hide");
            $A.util.addClass(component.find("backdrop"), "slds-backdrop--open");
            var prevUsedBased = component.get("v.newContact.Previous_User__c");
            this.getPreviousqueueBasedUser(component,prevUsedBased,recordData);
            var productName,groupName;
            var action = component.get("c.getIdFromUser");
            action.setParams({
                "recordId": prevUsedBased
            });
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {       
                var priorityList = response.getReturnValue();
                var priorityNamesArray = [];            
                for (var i = 0; i < priorityList.length; i++) {
                    productName = priorityList[i].Id;
                    groupName = priorityList[i].Name;
                    priorityNamesArray.push(productName);
                }
                var selectedRecord = {label: groupName, value: productName};
                      if( component.find("Lookup")!= undefined){
                          component.find("Lookup").selectedRecord = selectedRecord;
                          component.find("Lookup").set("v.selectedRecord",selectedRecord);
                          component.set("v.newContact.Previous_User__c",selectedRecord.label);
                          
                      }
                var recordData = selectedRecord.label;
                this.getPreviousQueueBasedOnAssignee(component,recordData);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
            component.set("v.showModule",true);
            
        }
        else{
            if(QueueUSer != 'Please Specify'){
                var preQueue = component.get("v.newContact.Previous_User__c");
                var productName,groupName;
                var action = component.get("c.getIdFromQueue");
                action.setParams({
                    "recordId": preQueue
                });
                action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {       
                    var priorityList = response.getReturnValue();
                    var priorityNamesArray = [];            
                    for (var i = 0; i < priorityList.length; i++) {
                        productName = priorityList[i].Id;
                        groupName = priorityList[i].Name;
                        priorityNamesArray.push(productName);
                    }
                    var selectedRecord = {label: groupName, value: productName};
                        if( component.find("LookupOwner")!= undefined){
                            component.find("LookupOwner").selectedRecord = selectedRecord;
                            component.find("LookupOwner").set("v.selectedRecord",selectedRecord);
                        }
                }
                else if(state === "ERROR") {
                    var errors = response.getError();
                    component.set("v.isLoading2", false);   
            }
        });
        $A.enqueueAction(action);
             
           }
        }
        
    },
     getCurrent:function(component){
         var recordData = component.get("v.recordId");
         var action = component.get("c.getCurrentStatus");
         action.setParams({
                    "caseId": recordData
                });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {       
                var priorityList = response.getReturnValue();
                var priorityNamesArray = [];
                for (var i = 0; i < Object.keys(priorityList).length; i++) {
                    var productName = priorityList[i];                
                    priorityNamesArray.push(productName);
                }
                component.set("v.currentStatus", priorityNamesArray[0].Status);
                component.set("v.currentSubStatus", priorityNamesArray[0].SubStatus__c);
                component.set("v.newContact.Status", priorityNamesArray[0].Status);
                component.set("v.newContact.SubStatus__c", priorityNamesArray[0].SubStatus__c);
                component.set("v.newContact.IsEscalated", priorityNamesArray[0].IsEscalated);
                component.set("v.newContact.Internal_Follow_Up__c", priorityNamesArray[0].Internal_Follow_Up__c);
                component.set("v.internalFollowUp", priorityNamesArray[0].Internal_Follow_Up__c);
                component.set("v.caseDevice", priorityNamesArray[0].Device__c);
                component.set("v.caseEnvironmentType", priorityNamesArray[0].EnvironmentType__c);
                component.set("v.product", priorityNamesArray[0].ProductName__c);
                component.set("v.subType1", priorityNamesArray[0].SubType1__c);
                component.set("v.subType2", priorityNamesArray[0].SubType2__c);
                component.set("v.caseRecordType", priorityNamesArray[0].RecordTypeName__c);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    getPriority:function(component)
    {
        var action = component.get("c.getStatusPicklist");
        action.setParams({ 
                "recordId": component.get("v.recordId")
            });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {     
                var priorityList = response.getReturnValue();
                var priorityNamesArray = [];
                for (var i = 0; i < Object.keys(priorityList).length; i++) {
                    var productName = priorityList[i];                
                    priorityNamesArray.push(productName);     
                }
                component.set("v.prioritytype", priorityNamesArray);
                var currentStatus = component.get("v.currentStatus");
                var currentSubStatus = component.get("v.currentSubStatus");
                window.setTimeout(
                $A.getCallback( function() {
                    // Now set our preferred value
                    component.find('parentStatus').set("v.value", currentStatus);
                    var parentValue = component.find('parentStatus').get('v.value');
                    if(parentValue == 'New' || parentValue == 'Solution Provided'|| parentValue == 'Closed' || parentValue == 'Abandoned'){
                        component.set('v.disabledPick',true);
                    }
                    else{
                        component.set('v.disabledPick',false);
                    }
                    
                }));
                var parentValue = component.get("v.currentStatus");
                this.pickStatus(component,parentValue);
                component.set("v.esclated", true);
                
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    GetProfileName: function(component){
        var action =  component.get('c.getProfileName');
        action.setCallback(this, function(a){
            var state = a.getState();
                if(state == 'SUCCESS') {
                    component.set("v.currentProfileName", a.getReturnValue());
                }
        });
        $A.enqueueAction(action);
        
    }
    
})
