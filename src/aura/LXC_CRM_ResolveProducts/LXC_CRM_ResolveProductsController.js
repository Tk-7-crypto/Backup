({
    setProductSearchData : function(component, event, helper)  {
        var params = event.getParams();
        if(params.action == "search") {
            component.set("v.resolveLineItem", params.resolveLineItem);
            component.set("v.resolveScreen", params.screen);
        }
        if(params.action != "searchResult") {
            return;
        }
        component.set("v.showFavoriteProduct", false);
        component.set("v.resolveProducts", params.pbeWrapperList);
        component.set("v.resolveLineItem", params.resolveLineItem);
        component.set("v.actionType", params.actionType);
        component.set("v.resolveScreen", params.screen);
        helper.createSearchResultWrapper(component, event, helper, params.pbeWrapperList,false);
        helper.getFavoriteProducts(component, event, helper);
    },
    
    onCancel : function(component, event, helper) {
        var resolveScreen = component.get("v.resolveScreen");
        var resolveLineItem = component.get("v.resolveLineItem");
        if(resolveScreen == "ProductDetail") {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": resolveLineItem.Id,
                "isredirect" : true
            });
            navEvt.fire();
        }
        else {
            $A.get("e.c:LXE_CRM_HideResolveTabEvent").fire();
        }
        
    },
    
    resetAttributes : function(component, event, helper) {
        component.set("v.resolveProducts", []);
        component.set("v.resolveLineItem", null);
        component.set("v.resultObjectWrapper", []);
        component.set("v.actionType", null);
        component.set("v.showResult", false);
        component.set("v.showFavoriteProduct", false);
        component.set("v.resolveScreen", null);
    },
    
    addProduct : function(component, event, helper) {
        helper.addProducts(component, event, helper);
    },
    
    getFavoriteProduct : function(component, event, helper) {
        helper.getFavoriteProduct(component, event, helper);
    },
 
    openCommentModel: function(component, event, helper) {
        var productId = event.getSource().get("v.value");
        component.set("v.favProductSelected", productId);
        component.set("v.isCommentModalOpen", true);
    },
    closeCommentModel: function(component, event, helper) {
        helper.closeCommentModel(component, event, helper);
    },
    addFavoriteProduct : function(component, event, helper) {
        component.action = "create";
        helper.modifyFavoriteProduct(component, event, helper);
        helper.closeCommentModel(component, event, helper);
    },
    deleteFavoriteProduct : function(component, event, helper) {
        component.action = "Delete";
        var productId = event.getSource().get("v.value");
        component.set("v.favProductSelected", productId);
        helper.modifyFavoriteProduct(component, event, helper);
    },
})