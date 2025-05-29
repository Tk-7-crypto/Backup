({
	doInit: function(component, event, helper) {
        
        var action = component.get("c.getContentDoc");
        
        action.setParams({
            aParentId: component.get('v.recordId') 
        });

        action.setCallback(this, function(data) {
            var state = data.getState();
            console.log(state);
            if (state === "SUCCESS") {
                console.log('data:' +data.getReturnValue());
                if($A.util.isEmpty(data.getReturnValue())) {
                    component.set("v.empty", true);
                }
                else {
                    component.set("v.fileList", data.getReturnValue());

                } 
            }
        });
        $A.enqueueAction(action);
    }
        
})