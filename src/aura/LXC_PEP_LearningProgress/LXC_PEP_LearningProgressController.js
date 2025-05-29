({
    doInit: function(component, event, helper) {
        var action = component.get("c.getLearn");
        var list = [];
        component.set('v.active', false);
        component.set("v.btnName", "View all");
        action.setCallback(this, function(data) {
            var state = data.getState();
            if(data.getReturnValue().length == 0) {
                component.set("v.empty", true);
            }
            if (data.getReturnValue().length > 0 && state === "SUCCESS") {
                component.set("v.total",data.getReturnValue().length);
                if(data.getReturnValue().length > component.get('v.limit')) {
                    for(var i=0; i<component.get('v.limit'); i++) {
                        list[i] = data.getReturnValue()[i];
                    }
                    component.set("v.learningList", list);
                }
                else {
                    component.set("v.learningList", data.getReturnValue());
                }
            }
        });
        $A.enqueueAction(action);
    },
    updateList: function(component, event, helper) {
        if(component.get('v.active') === false) {
            component.set("v.btnName", "Collapse");
            component.set("v.active", true);
            var action = component.get("c.getLearn");
            action.setCallback(this, function(data) {
                var state = data.getState();
                if(data.getReturnValue().length == 0) {
                    component.set("v.empty", true);
                }
                else if (data.getReturnValue().length > 0 && state === "SUCCESS") {
                    component.set("v.learningList", data.getReturnValue());
                }
            });
            $A.enqueueAction(action); 
        }
        else {
            var a = component.get('c.doInit');
            $A.enqueueAction(a);
        }
    }
})