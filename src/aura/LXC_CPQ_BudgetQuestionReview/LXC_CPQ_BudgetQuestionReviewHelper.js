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
    saveAllData : function(component, actionPerformed) 
    {
        component.set("v.Spinner", true);
        var action = component.get("c.saveAllDataAction");
        action.setParams({
            "proposalObjString" : JSON.stringify(component.get("v.proposalObj")),
            "actionPerformed" : actionPerformed
        });
        action.setCallback(this, function(response) 
        {
            if (response.getState() === "SUCCESS") 
            {
                var parentPopUp = component.get("v.parent");
                parentPopUp.showToast('Saved Successfully!!');
                parentPopUp.set("v.isQcReview", false);
                
                if(actionPerformed == 'SaveComplete')
                {
                    if(component.get("v.proposalObj").approvalStage == 'Draft')
                    {
                        parentPopUp.set("v.multiQC", false);
                        parentPopUp.set("v.askForQCReview", true);
                        parentPopUp.set("v.header", 'Draft Review');
                        parentPopUp.set("v.message", 'Do you want to proceed with Draft Review?');
                    } 
                    else if (component.get("v.proposalObj").approvalStage == 'Final Review') 
                    {
                        parentPopUp.set("v.multiQC", true);
                        parentPopUp.set("v.askForQCReview", true);
                        parentPopUp.set("v.header", 'Select Final Reviewer');
                        parentPopUp.set("v.title", 'Proceed with Final Review');
                        parentPopUp.set("v.message", 'Select multiple Reviewers by entering their names.');
                    }
                }
                $A.get('e.force:refreshView').fire();
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    }
})