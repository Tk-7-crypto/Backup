({ 
    doInit : function(component, event, helper) {
        document.getElementsByTagName('html')[0].style.backgroundColor = "#aec5de";
        var oliId = component.get('v.oliId');
        if(oliId != null && oliId != '') {
            helper.changeLineItem(component, event, helper, oliId);
        }
    },
    
    getFavoriteProducts : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        $A.get("e.c:LXE_CRM_FavoriteProductEvent").setParams({"isTabEvent" : true}).fire();
    },
    
    getRecentProducts :function(component, event, helper) {
        helper.getRecentProducts(component, event, helper);
    },
    
    setTab : function(component, event, helper) {
        var params = event.getParams();
        var actionLabel = params.actionLabel;
        if(component.get("v.source") == "Quote__c"){
            component.set("v.activeTabId", params.activeTabId);
        }else{
            if(actionLabel != undefined && actionLabel != null) {
                var resolveProductsComp = component.find("resolveProducts");
                if(resolveProductsComp != undefined) {
                    resolveProductsComp.set("v.class", "");
                    var resolveLabel = resolveProductsComp.get("v.label");
                    resolveLabel[0].set("v.value", params.actionLabel);
                }
                helper.disableOtherTabs(component, event, helper);
            }   
            component.set("v.activeTabId", params.activeTabId);
        }
    },
    
    goToButtom : function(component, event, helper) {
        if(!(component.get("v.disableOnLoadScroll"))) {
            scroll = setTimeout(function() {
                var searchPrd = document.getElementById("SearchProducts");
                var oppDetail = document.getElementById("OpportunityDetail");
                if(searchPrd != undefined && oppDetail != undefined) {
                    window.scrollTo(0, searchPrd.clientHeight + oppDetail.clientHeight);    
                }
            }, 1000);
        }
        component.set("v.disableOnLoadScroll", false);
    },
    
    hideResolveTab : function(component, event, helper) {
        helper.hideResolveTab(component, event, helper);
    },
    renderLDS : function(component, event, helper) {
        var ldsComp = component.find("ldsScreen");
        if(event.getParams().productRecord != undefined) {
            component.set("v.productRecord", event.getParams().productRecord);
            var OpportunityRecord = component.find("oppDetail").get("v.OpportunityRecord");
            var defaultProductFilterObj = component.find("searchProduct").get("v.defaultProductFilterObj");
            if(defaultProductFilterObj.Default_Territory__c != undefined) {
                component.set("v.territory", defaultProductFilterObj.Default_Territory__c);
            }
            component.set("v.opportunityRecord", OpportunityRecord);
            component.set("v.isLDSVisible", true);
        } else if(event.getParams().needs != undefined && ldsComp != undefined) {
            if(event.getParams().needs === "destroy") {
                ldsComp.set("v.showModal", false);
                component.set("v.isLDSVisible", false);
            } else if(event.getParams().needs === "unhide") {
                ldsComp.set("v.hidemodal", "slds-modal__container");
            }
        }
    },
    unrenderLDS : function(component, event, helper) {
        component.set("v.isLDSVisible", false);
    },
    addProductRecord : function(component, event, helper) {
        var productRecordJSON = event.getParams();
        helper.addProducts(component, event, helper, productRecordJSON);
    }
})