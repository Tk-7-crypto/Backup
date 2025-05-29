({
    handleChange : function(component, event, helper) {
        var radioGrpValue = component.get("v.value");
        var recordData = component.get("v.recordId");
        if(radioGrpValue == 'option1'){
           component.set("v.newContact.Internal_Follow_Up__c", component.get("v.internalFollowUp"));
        }
        helper.getPreviousqueue(component, recordData);
        helper.getPreviousOwner(component, recordData);     
    },
    openForm: function (component, event, helper) {
        
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
					helper.GetProfileName(component);
					helper.getCurrent(component);
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
								if(parentValue == 'New' || parentValue == 'Solution Provided'|| parentValue == 'Closed' || parentValue == 'Abandoned'|| parentValue == 'Internal Solution Provided'){
									component.set('v.disabledPick',true);
									component.set("v.newContact.SubStatus__c", '');
								}
								else{
									component.set('v.disabledPick',false);
									component.set("v.newContact.SubStatus__c", component.get("v.currentSubStatus"));
								}
								
							})); 
							var parentValue = component.get("v.currentStatus");
							//component.set("v.newContact.SubStatus__c", currentSubStatus);
							helper.pickStatus(component,parentValue,'openForm');
						
							component.set("v.esclated", true);
							
						}
						else if(state === "ERROR") {
							var errors = response.getError();
							component.set("v.isLoading2", false);    
						}
					});
					$A.enqueueAction(action);
					var recordData = component.get("v.recordId");
					helper.getPreviousqueue(component, recordData);
					helper.getPrevioususer(component, recordData);
					helper.getPreviousOwner(component, recordData);
					//component.set('v.newContact.IsEscalated', true);
					component.set("v.cssStyle", "<style>.cuf-scroller-outside {background: rgb(255, 255, 255) !important;}</style>");
				}
			}
			else if(state === "ERROR") {
				var errors = response.getError();
				component.set("v.isLoading2", false);    
			}});
		$A.enqueueAction(actionn);
    },
    PickStatusChange:function(component, event, helper) {
        var parentValue = component.find('parentStatus').get('v.value');
        if(parentValue == 'New' || parentValue == 'Solution Provided'|| parentValue == 'Closed' || parentValue == 'Abandoned' || parentValue == 'Internal Solution Provided'
          || parentValue == 'Coding' || parentValue == 'Verification'|| parentValue == 'Rework' || parentValue == 'Review' ){
            component.set('v.disabledPick',true);
        }
        else{
            component.set('v.disabledPick',false);
        }
        helper.pickStatus(component,parentValue,'PickStatusChange');
        
    },
    handleApplicationEvent : function(component, event, helper) {
        var recordData = event.getParam("message");    
        helper.getPreviousQueueBasedOnAssignee(component, recordData);
        
	},
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
    closeForm: function (component) {
        $A.util.addClass(component.find("modaldialog"), "slds-fade-in-hide");
        $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop"), "slds-backdrop--hide");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop--open");
    },
    
    saveData : function(component, event, helper) {
        var recordData = component.get("v.recordId");
        var lookupOwnerCmp = component.find("LookupOwner");
        var previousQueue = component.get("v.newContact.Previous_Queue__c");
        var prevOwnerQueue = component.get("v.newContact.Previous_User__c");
        var status = component.get("v.newContact.Status");
        var substatus = component.get("v.newContact.SubStatus__c");
        if(substatus === 'None'){
            component.set("v.newContact.SubStatus__c",'');
        }
        var visibility = component.get("v.showModule");
        var previousUserLength = component.get("v.previoususer");
        var radioVisiblity = component.get("v.radioGroupVis");
        if(component.get('v.disabledPick'))
            component.set("v.newContact.SubStatus__c",'');
        if( previousQueue == '' && lookupOwnerCmp != undefined){
            var lookupOwnerSelectedRecord = lookupOwnerCmp.get("v.selectedRecord");
            previousQueue = lookupOwnerSelectedRecord.label;
        }
        if(previousQueue == ''){
            var queueList = component.get("v.previousqueue");
            if(queueList.length > 0){
                previousQueue = queueList[0];
            }
        }
        component.set("v.newContact.Previous_Queue__c",previousQueue);
        component.set("v.newContact.Status",component.find('parentStatus').get('v.value'));
        var newcon = component.get("v.newContact");
        var isExpandable = $A.util.hasClass(component.find("modaldialog"), "slds-fade-in-open");
        if (!isExpandable){
            var action = component.get("c.Save");      
            action.setParams({ 
                "con": newcon,
                "recordId": recordData
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    var wrapperObject = JSON.parse(a.getReturnValue());
                    var selectedUser = wrapperObject.lstUser;
                    var selectedQueue = wrapperObject.lstGroup;
                    if(selectedQueue !=null){
                        var selectedRecord = {label: selectedQueue.Name, value: selectedQueue.Id};
                        if( component.find("LookupOwner")!= undefined){
                            component.find("LookupOwner").selectedRecord = selectedRecord;
                            component.find("LookupOwner").set("v.selectedRecord",selectedRecord);
                        }
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Dispatched',
                            message: 'Case is Dispatched Successfully',
                            messageTemplate: 'Record {0} created! See it {1}!',
                            duration:'5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    $A.get('e.force:refreshView').fire();
                }
                else if(state === "ERROR"){
                    var errors = action.getError();
                    if (errors) {        
                        if(errors[0].message.split('.')[0] == 'Update failed') {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: errors[0].message.split(',')[1].split('.')[0]+ '.',
                                messageTemplate: 'Record {0} created! See it {1}!',
                                duration:'20000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }else if(errors[0].message.split('.')[0] == 'Please create an escalation form to proceed the dispatch') {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: errors[0].message,
                                duration:'20000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: errors[0].message,
                                duration:'20000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                       component.set("v.newContact.Previous_Queue__c",'');
                    }
                }
            });
            $A.enqueueAction(action);
        }
        $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-open");
        $A.util.addClass(component.find("modaldialog"), "slds-fade-in-hide");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop--open");
        $A.util.addClass(component.find("backdrop"),"slds-backdrop--hide");
    },
    
    
    changepiclist: function (component, event, helper) {
        helper.openFormDispatch(component);
    },
    
    openNewEscalationForm: function (component, event, helper) {
        if(component.get("v.caseDevice") == undefined && component.get("v.caseEnvironmentType") == undefined){
            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: 'Please Select Device and Environment Type',
                                duration:'6000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
        }else{
            var fieldValues = "Case__c="+component.get("v.recordId");
            if(component.get("v.product").toLowerCase() == 'onekey' && component.get("v.subType1").toLowerCase() == 'service request' && component.get("v.subType2").toLowerCase() == 'new field request'){
                fieldValues+=",Form_Type__c=OneKey%20New%20Field%20Request";
            }else{
                fieldValues+=",Form_Type__c=T2toT3%20Escalation";
            }
            var workspaceAPI = component.find("workspace");
            workspaceAPI.openSubtab({
                pageReference: {
                    "type": "standard__objectPage",
                    "attributes": {
                        "objectApiName": 'CSM_Technology_Solutions_Form__c',
                        "actionName":"new"
                    },
                    "state": {
                        "nooverride": "1",
                        "defaultFieldValues": fieldValues
                    }
                },
                focus: true
            }).then(function(response) {
                workspaceAPI.getTabInfo({
                    tabId: response
                }).then(function(tabInfo) {
                    console.log("The recordId for this tab is: " + tabInfo.recordId);
                });
            }).catch(function(error) {
                console.log(error);
            });
        }
    },
    
})
