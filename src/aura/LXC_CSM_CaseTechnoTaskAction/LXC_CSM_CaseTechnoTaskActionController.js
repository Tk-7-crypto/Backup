({
	doInit : function(component, event, helper) {
        component.set("v.cssStyle", "<style>.cuf-scroller-outside {background: rgb(255, 255, 255) !important;}</style>");
        helper.callServer(component, "c.getCaseRecord",function(response){
            var caseRecord = response[0];
            component.set('v.caseRecord',caseRecord);
            
            helper.callServer(component, "c.getCaseTechnoTaskList",function(response){
            var taskList = [];
            for (var i=0; i<response.length; i++) {
                if(response[i].label == "Resolution plan provided" || response[i].label =="Case update provided"){
                    taskList.push({name: response[i].label,value: response[i].value});    
                }else if(component.get("v.caseRecord").Case_Type__c == "Incident" && component.get("v.caseRecord") !== undefined && component.get("v.caseRecord").SubType1__c !== undefined && component.get("v.caseRecord").SubType1__c.includes("Incident") && (response[i].label == "RCA Delivered" || response[i].label == "RCA Requested")){
                    taskList.push({name: response[i].label,value: response[i].value});
                }else if((response[i].label == "Plan Provided by T3" || response[i].label == "Issue Reproduced by T3")){
                    taskList.push({name: response[i].label,value: response[i].value});
                }
                
            }
            
            component.set('v.casetaskList',taskList);
        },{"recordId": component.get("v.recordId"),"TaskMilestone" : component.get("v.caseRecord.TaskMilestone__c")},true);
        
            helper.callServer(component, "c.getCasePostUserQueueMembers",function(response){
                var postUsers = [];
                for (var i=0; i<response.length; i++) {
                    postUsers.push({name: response[i].label,value: response[i].value});    
                }
                component.set('v.postUsers',postUsers);
            },{"caseId": component.get("v.recordId"),"queue" : component.get("v.caseRecord.InitialQueue__c"), "firstEscById":component.get("v.caseRecord.First_Escalated_By__c")},true);
            
        },{"recordId": component.get("v.recordId")},true);
        
        
	},
    saveTask : function(component, event, helper) {
        event.preventDefault();
        if(component.get("v.sltCaseTask") == ""){
            helper.showToastmsg(component,"Error","error", "Please select Task");
        }else if(component.get("v.sltCaseTask") == "Resolution plan provided"){
            var taskList = component.get('v.postUsers');
            if(component.get("v.caseRecord").InitialQueue__c.includes('T1') || component.get("v.caseRecord").InitialQueue__c.includes('L1')){
				helper.updatePostAction(component);
			}else if(component.get("v.caseRecord").Origin == 'Customer Portal'){
                helper.updateLogCommentAction(component);
            }else{
              helper.updateSendEmailAction(component);
            }
        }else{
            helper.callServer(component, "c.saveTasktoCreate",function(response){
                $A.get('e.force:refreshView').fire();
            },{"updateObject" : component.get("v.caseRecord"),"recordId": component.get("v.recordId"), "selectTask" : component.get("v.sltCaseTask")},true);    
        }
    }
    
})