({
    loadGuidelines : function(component, event, helper)
    {
        component.set('v.isOpen', true);		
        component.set("v.Spinner", true);
        var action = component.get("c.fetchData");
        action.setParams({ 
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) 
        {
            if (response.getState() === "SUCCESS")
            {
                var returnValue = response.getReturnValue();
                component.set("v.proposalObj", returnValue);  
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    addMoreItem : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var proposalObj = component.get("v.proposalObj");        
        proposalObj.questionList.splice(proposalObj.questionList.length-1, 0, {'sobjectType':'ProposalQASelfCheckListWrapper',
            'isNew':true, 'reviewersResponseValues': proposalObj.allReviewersResponseValues});
        component.set("v.proposalObj", proposalObj);
        component.set("v.Spinner", false);
    },
    deleteItem : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var proposalObj = component.get("v.proposalObj");
        proposalObj.questionList.splice(event.getSource().get("v.name"), 1);
        component.set("v.proposalObj", proposalObj);
        component.set("v.Spinner", false);
    },
    saveData : function(component, event, helper) 
    {
        helper.checkForQuestions(component);
        if(!component.get("v.isErrorMessage"))
        {
            var proposalObj = component.get("v.proposalObj"); 
            proposalObj.actionPerformed = event.getSource().get("v.name");
            proposalObj.spApprover = component.get("v.parent").get("v.proposalObj").spApproverId;
            component.set("v.proposalObj", proposalObj);
            helper.saveAllData(component, event.getSource().get("v.name"));
        }
    }
})