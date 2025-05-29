({
    getCommentRating: function (component) {
        var action = component.get("c.getCommentRatingByCaseId");
        action.setParams({
            "caseId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    component.set("v.commentRatings", response.getReturnValue());
                }
            } else {
                console.log("Error getCommentRating");
            }
        });
        $A.enqueueAction(action);
    },

    getCSATInternalIfAuthorized: function (component) {
        var action = component.get("c.getUserProfile");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var profile = response.getReturnValue();
                    var profilesNotAuthorized = component.get("v.profilesNotAuthorized");
                    if (profilesNotAuthorized.indexOf(profile.Name) === -1) {
                        var action2 = component.get("c.getUserPermissionSet");
                        action2.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                if (response.getReturnValue() != undefined) {
                                    var permissionSets = response.getReturnValue();
                                    var permissionSetNotAuthorized = component.get("v.permissionSetNotAuthorized");
                                    for (var p in permissionSets) {
                                        if (permissionSetNotAuthorized.indexOf(permissionSets[p].PermissionSet.Name) > -1) {
                                            component.set("v.isAuthorized", false);
                                        }
                                    }
                                    this.getCommentRating(component);
                                }
                            } else {
                                console.log("Error to getUserPermissionSet");
                            }
                        });
                        $A.enqueueAction(action2);
                    } else {
                        component.set("v.isAuthorized", false);
                    }
                }
            } else {
                console.log("Error to getUserProfile");
            }
        });
        $A.enqueueAction(action);
    },

    saveRate: function (component, id, rate) {
        var action = component.get("c.saveCommentRating");
        action.setParams({
            "id": id,
            "rate": rate,
            "caseCurrentQueue": component.get("v.caseCurrentQueue")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.getCommentRating(component);
            } else {
                console.log("Error to save your rate");
            }
        });
        $A.enqueueAction(action);
    },

    getCase: function (component) {
        var action = component.get("c.getCase");
        action.setParams({
            "caseId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var c = response.getReturnValue()[0];
                    component.set("v.caseCurrentQueue", c.CurrentQueue__c);
                    var userId = $A.get("$SObjectType.CurrentUser.Id");
                    if (c.OwnerId === userId) {
                        component.set("v.canRate", true);
                    } else {
                        component.set("v.canRate", false);
                    }
                    component.set("v.userId", userId);
                }
            } else {
                console.log("Error getCase");
            }
        });
        $A.enqueueAction(action);
    },
})