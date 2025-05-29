({
    doInit: function(component, event, helper) {
        console.log('action:');
        var action = component.get("c.getActiveAgencyProg");

        action.setCallback(this, function(data) {
            var state = data.getState();
            console.log(state);
            if (state === "SUCCESS") {
                if($A.util.isEmpty(data.getReturnValue())) {
                    component.set("v.empty", true);
                }
                else {
                    let programList = data.getReturnValue();
                    let visibleAgencyProgramList = [];
                    programList.forEach((programItem) => {
                        if(programItem.Visible_in_PRM__c)
                        	visibleAgencyProgramList.push(programItem);
                    });
                    component.set("v.agencyProgramList", visibleAgencyProgramList);
                } 
            }
        });
        $A.enqueueAction(action);
        
    },
	createContract : function(component, event, helper) {
        var ctarget = event.currentTarget;
    	var agencyProgramId = ctarget.dataset.value;
        var action = component.get("c.createContractController");   
        
        action.setParams({"agencyProgramId":agencyProgramId});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var ContractId = response.getReturnValue();
                window.open('../s/contract/'+ContractId,'_top')
            }    
        });
		$A.enqueueAction(action);
    }
})
