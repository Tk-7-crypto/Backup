({  
    doInit : function(component, event, helper) {
        helper.getProductSearchInitData(component, event, helper);
    },
    
    filterProducts : function(component, event, helper) {
        helper.searchfilterProducts(component, event, helper);
    },
    
    clearFilter : function(component, event, helper) {
        helper.clearDefaultFilter(component, event, helper);
    },
    
    saveFilter : function(component, event, helper) {
        helper.saveDefaultFilter(component, event, helper);
    },
    
    hideErrors : function(component, event, helper) {
        component.set("v.errors", null);
    },
    
    searchResolvedProduct : function(component, event, helper) {
        var params = event.getParams();
        if(params.action != "search") {
            return;
        }
        helper.searchResolvedProduct(component, event, helper, params);
    },
    
    hideResolveProduct : function(component, event, helper) {
        helper.hideResolveProduct(component, event, helper);
    },
    
    setSearchedField : function(component, event, helper) {
        var params = event.getParams();
        var defaultProductFilterObj = component.get("v.defaultProductFilterObj");
        var fieldsAPIList = params.fieldsAPIList;
        for(var count in fieldsAPIList) {
            var fieldValue = params.searchFieldValueList[fieldsAPIList[count]];
            fieldValue = fieldValue === undefined ? "" : fieldValue;
            if(fieldsAPIList[count] == 'Hierarchy_Global_Code_Description__c') {
                defaultProductFilterObj["Df_" + fieldsAPIList[count]] = fieldValue;
            } else {
                defaultProductFilterObj["Default_" + fieldsAPIList[count]] = fieldValue;
            }
        }
        component.set("v.defaultProductFilterObj", defaultProductFilterObj);
    },
    
    keyCheck : function(component, event, helper) {
        if (event.which == 13){
            event.preventDefault();
            helper.searchfilterProducts(component, event, helper);
        }    
    },
    
    handleChange : function(component, event, helper) {
        var changeValue = event.getParam("value");
        component.set("v.andORLogic", changeValue);
    },
})