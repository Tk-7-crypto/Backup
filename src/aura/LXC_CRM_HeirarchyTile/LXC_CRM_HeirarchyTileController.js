({
    doInit: function(component, event, helper) {
        if(component.get("v.isParent")) {
            var currentChain = '';
            component.set("v.currentLayer", "1");
            component.set("v.currentChain", currentChain);
            helper.setNextLayerProducts(component, event, helper,true);
        }
    },
    SetCurrentValue: function(component, event, helper) { 
        var currentChain = event.target.getAttribute("data-chain") + "->";
        component.set("v.currentLayer", (currentChain.match(/->/g)).length + 1);
        component.set("v.currentChain", currentChain);
        helper.setNextLayerProducts(component, event, helper,false);
    },
    
    gotoRegionalHierarchy : function(component, event, helper) {
        var ldsScreenEvent = $A.get("e.c:LXE_CRM_RenderLDSScreen");
        ldsScreenEvent.setParams({"productRecord" : component.get("v.enableRegionalProduct")});
        ldsScreenEvent.fire();
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    
    hideButton : function(component, event, helper) {
        component.set("v.enableRegionalHierarchy", false);
    }
})