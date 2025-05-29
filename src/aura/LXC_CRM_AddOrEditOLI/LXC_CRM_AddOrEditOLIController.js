({
    onInit:  function(component, event, helper) {
        helper.fetchRecordTypeId(component, event, helper);
    },
    showModel : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var params = event.getParams();
        component.set("v.title", params.title);
        if(params.operationType === "createFromLDS") {
            component.set("v.operationType", "create");
            component.set("v.createFromLDS", true);
        } else {
            component.set("v.operationType", params.operationType);
        }
        component.set("v.selectedList", params.selectedList);
        component.set("v.isFadeIn", params.isFadeIn);
        component.set("v.fieldsToShow", params.fieldsToShow);
        component.set("v.fieldsToDisable", params.fieldsToDisable);
        component.set("v.territory", params.territory);
        if(params.isFadeIn){
            var addProductComp = component.find("addProduct");
            var modalDiv = component.find("modalDiv");
            var backDropComp = component.find("backdrop-addProduct");
            $A.util.addClass(addProductComp, "slds-fade-in-open");
            if($A.get("$Browser.isPhone")){
                $A.util.addClass(modalDiv, "mobile-modal");
            }
            $A.util.addClass(backDropComp, "slds-backdrop--open");
            helper.getFieldDetails(component, event, helper);
        }
    },
    onCancel : function(component, event, helper) {
        helper.fadeOutModel(component, event, helper);
        component.set("v.actionType", "");
        component.set("v.resolveScreen", null);
        var ldsScreenEvent = $A.get("e.c:LXE_CRM_RenderLDSScreen");
        ldsScreenEvent.setParams({"needs" : "unhide"});
        ldsScreenEvent.fire();
    },
    onSave : function(component, event, helper) {
        helper.onSave(component, event, helper);
    },
    checkValidity : function(component, event, helper) {
        var inputcom = event.getSource();
        var value = inputcom.get("v.value");
        if(component.get("v.operationType") == "create") {
            helper.setTotalSum(component, event, helper);
        }
        if (value < 0) {
            inputcom.set("v.validity", {valid:false, badInput :true});
            $A.util.addClass(inputcom, "slds-has-error");
            $A.util.removeClass(inputcom, "hide-error-message");
        } else {
            $A.util.removeClass(inputcom, "slds-has-error");
            $A.util.addClass(inputcom, "hide-error-message");
        }
    },
    getResolveLineItem : function(component, event, helper) {
        var params = event.getParams();
        if(params.action != "resolve") {
            return ;
        }
        component.set("v.resolveLineItem", params.resolveLineItem);
        component.set("v.actionType", params.actionType);
        component.set("v.resolveScreen", params.screen);
    },
    
    openRevenueSchedule : function(component, event, helper) {
        helper.openRevenueSchedule(component, event, helper);
    },
    
    setSchedule : function(component, event, helper) {
        helper.setSchedule(component, event, helper);
    },
    
    cloneRecord : function(component, event, helper) {
        var oliWrapperList = component.get("v.oliWrapperList");
        var oliWrapperClone = JSON.parse(JSON.stringify(oliWrapperList[0]));
        oliWrapperList.push(oliWrapperClone);
        component.set("v.oliWrapperList", oliWrapperList);
        helper.setDefaultValues(component, event, helper);
        helper.setTotalSum(component, event, helper);
    },
    
    removeRecord : function(component, event, helper) {
        var oliWrapperList = component.get("v.oliWrapperList");
        var currentId = event.getSource().get("v.name");
        oliWrapperList.splice(currentId, 1);
        component.set("v.oliWrapperList", oliWrapperList);
        setTimeout(function(){ helper.setTotalSum(component, event, helper); }, 100);
        
    },
})