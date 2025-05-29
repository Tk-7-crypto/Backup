({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        var action = component.get("c.getAllKnowledgeReviewList");
         action.setParams({"articleId": recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var reviewList = response.getReturnValue();
                component.set("v.reviewList",reviewList);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading2", false);    
            }
        });
        $A.enqueueAction(action);
    },
    handleSave : function(component, event, helper) { 
        var recordId = component.get("v.recordId");
        if(component.get("v.rdate") == undefined ){
            helper.showToastmsg(component,"Error","error", "Please Select Review Date");
        }else if(component.find("reviewcomment").get("v.value") == ""){
            helper.showToastmsg(component,"Error","error", "Please Select Review Comment");
        }else if(component.find("reviewcomment").get("v.value") != undefined && component.get("v.rdate") != undefined) {
            var reviewDate = component.get("v.rdate");
            var reviewComment = component.find("reviewcomment").get("v.value");
            var action = component.get("c.insertKnowledgeReview");
            action.setParams({"articleId": recordId, "reviewDate":reviewDate,"reviewComment":reviewComment});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {                              
                    var reviewList = response.getReturnValue();
                    component.set("v.reviewList",reviewList);
                    component.find("reviewcomment").set("v.value",'');
                    component.set("v.rdate",null);
                    
                    helper.showToastmsg(component,"Success","Success", "Review added Successfully");
                }
                else if(state === "ERROR") {
                    var errors = response.getError();
                    //component.set("v.isLoading2", false);
                }
            });
            $A.enqueueAction(action);    
        }
        
    },
    
})