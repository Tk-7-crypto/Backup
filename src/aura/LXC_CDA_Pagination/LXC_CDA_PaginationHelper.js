({
	getPageCountAndTotal : function(component, rCount, isNegotiatorTab, searchMap) {
        console.log('In LXC_CDA_Pagination js helper: getPageCountAndTotal method called');
        console.log('isNegotiatorHelper::' + isNegotiatorTab);
		var action = component.get("c.getPageCountInfo");
        action.setParams({
            "pageCountInfo" : rCount,
            "searchMap" : searchMap,
            "isNegotiatorTab" : isNegotiatorTab
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.pageInfo", response.getReturnValue());                
            }
        });
        $A.enqueueAction(action);
	},
    
    resetCounters : function (component, pNum, rCunt, totalPage, totalRecords) {
        console.log('In LXC_CDA_Pagination js helper: resetCounters method called');
        var action = component.get("c.getPageCountChange");
        console.log('pageNumber in helper: resetCounters: ' + pNum);
	    action.setParams({
            "pageNumber" : pNum.toString(),
            "currnetPagesCount" : rCunt.toString(),
            "totalPages" : totalPage.toString(),
            "totalRecords" : totalRecords.toString()
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.pageInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})