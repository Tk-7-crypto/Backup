({
    getGroupsRelatedToProduct : function(component) {
        var action; //= component.get("c.getGroupsRelatedToProduct");
        let prodName = component.get('v.productName');
        if(prodName){
            console.log('Calling with product....');
            action = component.get("c.getGroupsRelatedToProduct");
            component.set('v.showAllGroups', false);
            action.setParams({
            "productName": component.get('v.productName')            
        });
        }else{
            //getGroupsRelatedToUser
            console.log('Calling without product....');
            component.set('v.showAllGroups', true);
            action = component.get("c.getGroupsRelatedToUser");
        }
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            var data = [];
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Results::::', result);
                if(result != null) {
                    var productGroupWrapperList = JSON.parse(result);
                    component.set('v.productGroupWrapperList', productGroupWrapperList);
                } else {
                    component.set('v.noRecordFound', true);
                }
            } else {
                console.log("LXC_CSM_CommunityGroups] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    
})
