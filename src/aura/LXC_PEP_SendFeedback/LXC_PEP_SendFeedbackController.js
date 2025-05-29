({
    doInit: function (component, event, helper) {
        helper.getLikeOrDislike(component);
    },
 
    feedbackPopup : function(component, event, helper){
        var fileid = event.getSource().get("v.value");        
        var title = event.getSource().get("v.name");
        component.set("v.feedbackTitle", title);
        component.set("v.fileId", fileid);
        component.set("v.isModalOpen", true);
        console.log('Feedback Title : ' + event.getSource().get("v.name"));  
        console.log('item type : ' + component.get("v.itemType"));  
        console.log('prm sales : ' + component.get("v.isPRMSalesArticle"));
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.isModalOpen2", false);
        component.set("v.showError", false);
    },
    
    saveDocFeedback: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var fbValue = component.find("feedback").get("v.value");
        if(fbValue != undefined){
            fbValue = fbValue.trim();
        }
        console.log('Your feedback is  : ' + fbValue);
        if(fbValue != undefined && fbValue != ''){
            component.set("v.isModalOpen", false);
            var action = component.get("c.saveFeedback");    
            action.setParams({"feedback":fbValue, "docTitle":component.get("v.feedbackTitle"), "aId" : recordId, "itemType" : component.get("v.itemType"), "fileId" : component.get("v.fileId"), "isPRMSalesArticle" : component.get("v.isPRMSalesArticle") });
            action.setCallback(this, function(response){
                console.log('in callback');
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.isModalOpen2", true);
                }  
                else{console.log('else');}
            });
            $A.enqueueAction(action);
        }
        else{
            console.log('inside blank value');
            component.set("v.showError", true);
        }
    },
    
    saveLikeOrDislike: function (component, event, helper) {
        var selectedItem = event.currentTarget;
        var likeOrDislike = selectedItem.dataset.value;
        helper.saveLikeOrDislike(component, likeOrDislike);
    },
    
    waiting: function (component, event, helper) {
        component.set("v.isLoading", true);
    },

    doneWaiting: function (component, event, helper) {
        component.set("v.isLoading", false);
    }
})
