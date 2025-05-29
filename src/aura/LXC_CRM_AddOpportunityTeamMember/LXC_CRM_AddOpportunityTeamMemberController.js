({
    showModel : function(component, event, helper) { 
        helper.checkForCommercialUser(component, event, helper);
    },
    
    recordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            var opportunityRecord = component.get("v.opportunityRecord");
            component.set("v.oldAccountId",opportunityRecord.AccountId);
        }
    },
    
    addTeamMemberRow : function(component, event, helper) {
        helper.addTeamMemberRow(component, event, helper);
    },
            
    onSave : function(component, event, helper) {
        helper.onSave(component, event, helper);
    },
    
    removeRecord : function(component, event, helper) {
        var OpportunityTeamMemberList = component.get("v.OpportunityTeamMemberList");
        var currentId = event.getSource().get("v.name");
        var OpportunityTeamMemberListToDelete = component.get("v.OpportunityTeamMemberListToDelete");
        OpportunityTeamMemberListToDelete.push(OpportunityTeamMemberList[currentId]);
        component.set("v.OpportunityTeamMemberListToDelete", OpportunityTeamMemberListToDelete);
        OpportunityTeamMemberList.splice(currentId, 1);
        component.set("v.OpportunityTeamMemberList", OpportunityTeamMemberList);
    },
            
    onCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();    
    },
})