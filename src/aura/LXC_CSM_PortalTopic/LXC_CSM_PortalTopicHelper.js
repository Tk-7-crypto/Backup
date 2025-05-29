({
    getTopics: function(component){
        var action;
        if(component.get("v.docCategory")==='None'){
            action = component.get("c.getTopics");
        }
        else{
            action = component.get("c.getTopicsByDocCategory");
            action.setParams({
                "category": component.get("v.docCategory")
            });            
        }
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.topics",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    getTopics4all: function(component){
        var topics4all = component.get("v.paramTopics4all");
        var array = topics4all.split(',');
        var action = component.get("c.getTopicsByName");
        action.setParams({
            "topicsList": array
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.topics4all",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

})