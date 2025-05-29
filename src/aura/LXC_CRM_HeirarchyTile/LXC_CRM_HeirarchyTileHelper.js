({
    setNextLayerProducts: function(component, event, helper,autoCall) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        component.set("v.enableRegionalHierarchy", false);
        var action = component.get("c.getProductDetails");
        action.setParams({
            "currentChain" : component.get("v.currentChain"),
            "territory" : null,
            "isLWCScreen" : false,
            "isMaterialLevel" : false
        });
        if(component.get("v.currentLayer") != "1" && autoCall === false) {
            var selecteNode = event.currentTarget;
            var selectedClass = selecteNode.className;
            var productIndex = event.target.getAttribute("data-index");
            var productRecords = component.get("v.productRecords");
            var searchFieldValueList = [];
            var fieldsAPIList = component.get("v.fieldsAPIList");
            for(var count in fieldsAPIList) {
                var fieldValue = productRecords[productIndex][fieldsAPIList[count]];
                searchFieldValueList[fieldsAPIList[count]] = fieldValue;
            }
            var appEvent = $A.get("e.c:LXE_CRM_PopulateFieldSearchProductEvent");
            appEvent.setParams({"searchFieldValueList" : searchFieldValueList});
            appEvent.setParams({"fieldsAPIList" : fieldsAPIList});
            appEvent.fire();

            if(productRecords[productIndex]["Enable_Regional_Hierarchy__c"]) {
                component.set("v.enableRegionalHierarchy", true);
                component.set("v.enableRegionalProduct", productRecords[productIndex]);
                /*var ldsScreenEvent = $A.get("e.c:LXE_CRM_RenderLDSScreen");
                ldsScreenEvent.setParams({"productRecord" : productRecords[productIndex]});
                ldsScreenEvent.fire();
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                return;*/
            }
            var elements = component.find("link");
            if(elements.length != undefined || elements.length > 0) {
                for (var index = 0; index < elements.length; index++) {    
                    elements[index].getElements()[0].classList.remove("active");
                }   
            }
            $A.util.addClass(selecteNode, "active");
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(component.get("v.currentLayer") == "1") {
                    component.set("v.productRecords", response.getReturnValue());
                }
                var appEvent = $A.get("e.c:LXE_CRM_ProductSelectedEvent");
                var prodList = response.getReturnValue();
                if(prodList == undefined || prodList.length <= 0){
                    var spans = component.find("expandArrow");
                    var productList = component.find("link");
                    if(spans != null && spans.length == undefined) {
                        var selectedspan1 = spans;
                        $A.util.addClass(selectedspan1, 'slds-hide');
                    }
                    if(spans != null && spans.length != undefined) {
                        var selectedIndex = 1;
                        for (var index = 0; index < productList.length; index++) {
                            var sourceProduct = productList[index];
                            if(event.target != undefined && productList[index].getElements()[0].id == event.target.getAttribute("data-chain")) { 
                                selectedIndex = index;
                            }
                        }
                        var selectedspan = spans[selectedIndex];
                        $A.util.addClass(selectedspan, 'slds-hide');
                    }
                }
                appEvent.setParams({"productRecords" : response.getReturnValue()});
                appEvent.setParams({"currentChain" : component.get("v.currentChain")});
                appEvent.setParams({"currentLayer" : component.get("v.currentLayer")});
                appEvent.fire();
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                if(autoCall === true && component.get("v.currentLayer") < 8){
                    helper.autoRenderNextLayer(component, event, helper,response.getReturnValue());                    
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = JSON.parse(errors[0].message).errorList;
                        console.log(errorMsg);
                        //helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    autoRenderNextLayer: function(component, event, helper,products) {
        var currentChain = component.get("v.currentChain"); 
        var currentLayer = component.get("v.currentLayer");
        var Hierarchychain = [''];

        var action = component.get("c.fetchHierarchyChain");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                Hierarchychain = response.getReturnValue();
                for(let i = 0; i<products.length; i++){
                    if(products[i].Hierarchy_Chain__c == Hierarchychain[currentLayer]){
                        currentLayer++;
                        currentChain = products[i].Hierarchy_Chain__c + "->";
                        component.set("v.currentLayer", currentLayer);
                        component.set("v.currentChain", currentChain);
                        helper.setNextLayerProducts(component, event, helper,true);
                    }
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    }
})