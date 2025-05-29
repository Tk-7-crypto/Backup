({
    saveCase : function(component,event) {
        var recordData = component.get("v.recordId");
        var mailCCData = component.get("v.mailCCValue");
        var action = component.get("c.updateMailCCList");
        action.setParams({ 
            "recordId": recordData,
            "mailCC" : mailCCData
        });
		
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.editMaillCC","false");
                component.set("v.editMaillCCButton","true");
            }
            else if(state === "ERROR") {
                var errors = response.getError();       
            }
        });
        $A.enqueueAction(action);
    },
    
    cloneCaseForFollowUp : function(component) {
        var recordId = component.get("v.recordId");
        var followUpDescription = component.get("v.followUpDescription");
        var action = component.get("c.getCloneCaseAsParentForFollowUp");
        action.setParams({ 
            "recordId": recordId,
            "followUpDescription" : followUpDescription,
            "retrieveOnly" : false
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();   
            if (state === "SUCCESS") {
                var clonedCase = response.getReturnValue(); 
                component.set("v.isCaseFollowed", true);
                console.log('clonedCase = ',JSON.stringify(clonedCase));
                component.set("v.followerCase", clonedCase);
               	this.showModal(component);
            }
            else if(state === "ERROR") {
                var errors = response.getError(); 
            }
        });
        $A.enqueueAction(action);
        component.set("v.isOpenModal", false);
        
    },

    getFollowerCase : function(component, caseId) {
        var action = component.get("c.getCloneCaseAsParentForFollowUp");
        action.setParams({ 
            "recordId": caseId,
            "followUpDescription" : '',
            "retrieveOnly" : true
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();   
            if (state === "SUCCESS") {
                var clonedCase = response.getReturnValue(); 
                component.set("v.followerCase", clonedCase);
            }
            else if(state === "ERROR") {
                var errors = response.getError(); 
            }
        });
        $A.enqueueAction(action);
        
    },
    
    showModal : function(component) {
        component.set("v.isOpenModal", true);
    },
})