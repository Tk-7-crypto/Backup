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
                
                var values = [];
                for(var index in returnValue.filterTypes) 
                {
                    values.push({'label': returnValue.filterTypes[index], 'value': returnValue.filterTypes[index]});
                }
                component.set("v.filterTypes", values.reverse());
                var action2 = component.get("c.filterQuestions");
                $A.enqueueAction(action2);
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    filterQuestions : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var proposalObj = component.get("v.proposalObj");
        for(var index1 in component.get("v.proposalObj").questionList)
        {
            proposalObj.questionList[index1].isSatisfyFilter = false;
            for(var index2 in component.get("v.proposalObj").selectedFilterTypes) 
            {
                if(component.get("v.proposalObj").questionList[index1].filterValues.indexOf(component.get("v.proposalObj").selectedFilterTypes[index2]) > -1) 
                {
                    proposalObj.questionList[index1].isSatisfyFilter = true;
                }
            }
        }
        component.set("v.proposalObj", proposalObj);
        component.set("v.Spinner", false);
    },
    addMoreItem : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var proposalObj = component.get("v.proposalObj");        
        proposalObj.questionList.splice(proposalObj.questionList.length-1, 0, {'sobjectType':'ProposalQASelfCheckListWrapper',
            'isNew':true,
            'ownersResponseValues': proposalObj.allOwnersResponseValues,
            'reviewersResponseValues': proposalObj.allReviewersResponseValues,
            'majorFindingCompletedValues':proposalObj.allMajorFindingCompletedValues,
            'filterValues':proposalObj.selectedFilterTypes,
            'isSatisfyFilter': true});
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
            helper.saveAllData(component, event.getSource().get("v.name"));
        }
    },
    cancelAction : function(component, event, helper) 
    {
        var parentPopUp = component.get("v.parent");
        parentPopUp.set("v.isQcReview",false);
    }
})