({
    checkUserFromCurrentQueue:function(component){
        var recordId = component.get("v.recordId");
        var actionn = component.get("c.checkUserFromCurrentQueue");
        actionn.setParams({
            "caseId":recordId
        });
        actionn.setCallback(this,function(resp){
            var returnState = resp.getState();
            if(returnState === "SUCCESS"){
                var showComponent = resp.getReturnValue();
                console.log('OUTPUT : '+showComponent);
                component.set("v.showComponent",showComponent);
                if(showComponent == true){
                    console.log('trueTrue');
                    var recordData = component.get("v.recordId");
                    var action = component.get("c.getCurrentStatus");
                    action.setParams({ 
                        "caseId": recordData
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {                              
                            var caseList = response.getReturnValue();
                            console.log('CaseList');
                            console.log(caseList);
                            component.set("v.simpleNewCase", caseList[0]);             
                            component.set("v.currentStatus", caseList[0].Status);
                            component.set("v.currentSubStatus", caseList[0].SubStatus__c);
                            component.set("v.newContact.Status", caseList[0].Status);
                            component.set("v.newContact.SubStatus__c", caseList[0].SubStatus__c);
                            if(caseList[0].CurrentQueue__c != undefined){
                                
                                component.set("v.currentQueueName", caseList[0].CurrentQueue__r.Name);
                                component.set("v.currentQueueId", caseList[0].CurrentQueue__c);
                                component.set('v.sltAssignQueue',caseList[0].CurrentQueue__c);
                            }
                            if(caseList[0].RecordTypeName__c == 'ConnectedDevicePatient' || caseList[0].RecordTypeName__c == 'ClinicalTrialPayment' || caseList[0].RecordTypeName__c == 'VirtualTrialsCase' || caseList[0].RecordTypeName__c == 'ActivityPlan' || caseList[0].RecordTypeName__c == 'RandDCase' || caseList[0].RecordTypeName__c == 'DATACase'){
                                component.set('v.statusList',component.get('v.nonTechStatus'));
                            }else if(caseList[0].RecordTypeName__c == 'TechnologyCase'){
                                component.set('v.statusList',component.get('v.technoStatus'));
                                component.set('v.newContact.Internal_Follow_Up__c', caseList[0].Internal_Follow_Up__c);																					   
                            }
                                else if(caseList[0].RecordTypeName__c == 'DATACreateService'){
                                    component.set('v.statusList',component.get('v.createDataStatus'));  
                                }
                        }
                        else if(state === "ERROR") {
                            var errors = response.getError();
                            component.set("v.isLoading2", false);    
                        }
                        this.getAssignCurrentQueue(component);
                        this.pickStatus(component,'getCurrent');
                    });
                    $A.enqueueAction(action);
                }
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);    
            }});
        $A.enqueueAction(actionn);
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
                var caseList = response.getReturnValue();
                component.set("v.simpleNewCase", caseList[0]);             
                component.set("v.currentStatus", caseList[0].Status);
                component.set("v.currentSubStatus", caseList[0].SubStatus__c);
                component.set("v.newContact.Status", caseList[0].Status);
                component.set("v.newContact.SubStatus__c", caseList[0].SubStatus__c);
                if(caseList[0].CurrentQueue__c != undefined){
                    component.set("v.currentQueueName", caseList[0].CurrentQueue__r.Name);
                    component.set("v.currentQueueId", caseList[0].CurrentQueue__c);
                    component.set('v.sltAssignQueue',caseList[0].CurrentQueue__c);
                }
                if(caseList[0].RecordTypeName__c == 'VirtualTrialsCase' || caseList[0].RecordTypeName__c == 'ActivityPlan' || caseList[0].RecordTypeName__c == 'RandDCase' || caseList[0].RecordTypeName__c == 'DATACase'){
                    component.set('v.statusList',component.get('v.nonTechStatus'));
                }else if(caseList[0].RecordTypeName__c == 'TechnologyCase'){
                    component.set('v.statusList',component.get('v.technoStatus'));
					component.set('v.newContact.Internal_Follow_Up__c', caseList[0].Internal_Follow_Up__c);																					   
                }
                else if(caseList[0].RecordTypeName__c == 'DATACreateService'){
                    component.set('v.statusList',component.get('v.createDataStatus'));  
                }
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);    
            }
            this.getAssignCurrentQueue(component);
            this.pickStatus(component,'getCurrent');
        });
        $A.enqueueAction(action);
     },
    
    
    getAssignCurrentQueue : function(component){
         var recordData = component.get("v.recordId");
         var action = component.get("c.getAssignCurrentQueues");
         action.setParams({ 
                    "caseId": recordData
                });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                              
                var assignQRes = response.getReturnValue();
                var assignQList = [];
                for (var i=0; i<assignQRes.length; i++) {
                    assignQList.push({name: assignQRes[i].label,value: assignQRes[i].value});
                    if(component.get("v.currentQueueId") == assignQRes[i].value){
                        component.set('v.newContact.CurrentQueue__c',component.get("v.currentQueueId"));
                    }else if( i == 0){
                        component.set('v.newContact.CurrentQueue__c',assignQRes[i].value);
                    }
                }
                for (let i = 0; i < assignQList.length; ++i){
                    for (let j = 0; j < assignQList.length; ++j){
                        if (i !== j && assignQList[i].name === assignQList[j].name && component.get('v.newContact.CurrentQueue__c') !== assignQList[j].value){
                            assignQList.splice(j, 1);
                        }
                    }
                }
                console.log('assignQList : '+assignQList);
                component.set('v.assignQueueList',assignQList);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);    
            }
        });
        $A.enqueueAction(action);
     },
     pickStatus:function(component,methodName){
         var parentValue = component.find('parentStatus').get('v.value');
        var recordType = component.get("v.simpleNewCase.RecordTypeName__c");
        if(parentValue == 'New' || parentValue == 'Internal Solution Provided' || ((recordType == 'RandDCase' || recordType == 'ActivityPlan' || recordType == 'VirtualTrialsCase' || recordType == 'DATACase') && parentValue == 'Canceled') || (recordType == 'DATACase' && parentValue == 'In Progress') || (recordType == 'TechnologyCase' && parentValue == 'Closed') || parentValue == 'Abandoned'){
            component.set('v.disabledPick',true);
        }
        else{
            component.set('v.disabledPick',false);
        }
        
        if (recordType != "" && parentValue != "") {
            if(recordType == 'VirtualTrialsCase' || recordType == "ActivityPlan"){
                recordType = "RandDCase";
            }
            if(methodName == 'PickStatusChange') component.set("v.newContact.SubStatus__c", '');
            var caseSubstatus = component.get("v.caseSubstatus");
            for (var i = 0; i < Object.keys(caseSubstatus).length; i++) {
                if(caseSubstatus[i].RecordTypeName == recordType && parentValue == caseSubstatus[i].Status){
                    component.set("v.substatus", caseSubstatus[i].SubStatus);
                    break;
                }else{
                    component.set("v.substatus", null);   
                }                 
            }
        }
    }
})
