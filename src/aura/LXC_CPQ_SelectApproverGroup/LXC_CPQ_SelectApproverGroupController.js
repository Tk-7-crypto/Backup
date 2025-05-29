({
	approvalMatrixData : function(component, event, helper) {
        var opts = document.querySelector('input[name="options"]:checked').value;
        component.set("v.approverType", opts);
        component.set("v.approverDataDisplay", true);
        var evt = $A.get("e.force:navigateToComponent");
        if(component.get("v.approverType") == "AccountDirectory"){
            evt.setParams({
                componentDef : "c:LXC_CPQ_AccountDirectoryDetails",
            });
        }else if(component.get("v.approverType") == "CountrySalesHead"){
            evt.setParams({
                componentDef : "c:LXC_CPQ_CountrySalesHeadsDetails",
            });            
        }else{
            evt.setParams({
                componentDef : "c:LXC_CPQ_UpdateApproverDetails",
                componentAttributes: {
                    approverGroupName : component.get("v.approverType")
                }
            });
        }
        evt.fire();
    }
})