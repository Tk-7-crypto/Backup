({
    sendResetPassword : function(component, event) {
        var action = component.get("c.sendResetPassword");
        action.setParams({
            "userId" : component.get('v.userId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('statestate'+state);
            if(state === "SUCCESS"){
                console.log(response.getReturnValue());
            }});
        $A.enqueueAction(action);
    }
})