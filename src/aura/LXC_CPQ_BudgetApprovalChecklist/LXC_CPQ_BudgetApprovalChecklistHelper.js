({
    checkForQuestions : function(component) 
    {
        component.set("v.isErrorMessage",false);
        var questionList = component.get("v.proposalObj").questionList;
        for(var cmp in questionList)
        {
            if(questionList[cmp].isNew
               && (!questionList[cmp].question.Question__c 
                   || !questionList[cmp].question.Guidelines__c))
            {
                component.set("v.isErrorMessage",true);
            }
        }
    },
    saveAllData : function(component) 
    {
        component.set("v.Spinner", true);
        var action = component.get("c.saveAllDataAction");
        action.setParams({
            "proposalObjString" : JSON.stringify(component.get("v.proposalObj"))
        });
        action.setCallback(this, function(response) 
        {
            if (response.getState() === "SUCCESS") 
            {
                var parentPopUp = component.get("v.parent");
                parentPopUp.showToast('Saved Successfully!!');
                parentPopUp.set("v.isApprovalReview", false);
                $A.get('e.force:refreshView').fire();
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    }
})