({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        if(recordId != undefined){
            helper.getPriority(component, helper);
            helper.getCompletedTime(component, helper);    
            var workspaceAPI = component.find("workspace");
            if(workspaceAPI != undefined && workspaceAPI.getFocusedTabInfo() != undefined && !component.get("v.completed") ){
                component.set("v.checkMethod","Init");
                setTimeout(function(){
                    helper.calculateOLA(component, helper);
                },3000);
            }
        }
        
    },
    
    doRefresh : function(component, event, helper) {
        helper.getPriority(component, helper);
        helper.getCompletedTime(component, helper);
        component.set("v.checkMethod","Refresh");
        setTimeout(function(){
        helper.calculateOLA(component, helper);
        },5000);
    }
})