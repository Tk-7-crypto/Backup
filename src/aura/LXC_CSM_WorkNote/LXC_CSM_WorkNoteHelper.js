({
    getCaseComment: function(component){
        var action = component.get("c.getCaseCommentByParentId");
        action.setParams({
            "parentId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.caseComments",response.getReturnValue());
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                    }
                } else {
                }
            }
        });
        $A.enqueueAction(action);
    },

    insertCaseComment: function(component){
        var action = component.get("c.insertCaseComment");
        var caseComment={};
        caseComment.ParentId = component.get("v.recordId");
        caseComment.CommentBody = component.find("commentBody").get("v.value");
        action.setParams({
            "caseComment" : caseComment
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("commentBody").set("v.value","");
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": "Success",
                    "message": "Case Comment was created."
                });
                resultsToast.fire();
                component.set("v.isLoading", false);
                this.getCaseComment(component);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                    }
                } else {
                }
            }
        });
        $A.enqueueAction(action);
    },

    updateCase: function(component){

        component.set("v.simpleRecord.Origin", "Customer Portal");
        var c = component.get("v.simpleRecord");
        c.Status="Closed";
        console.log(JSON.stringify(c));
        var action = component.get("c.updateCase");
        action.setParams({
            "c" : c
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": "Success",
                    "message": "The case is closed."
                });
                resultsToast.fire();
            } else if(state === "ERROR") {
                console.log(JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
})