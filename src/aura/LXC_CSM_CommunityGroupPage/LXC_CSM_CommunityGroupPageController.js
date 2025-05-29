({
    doInit : function(component, event, helper) {
        component.set('v.pageSpinner', true);
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.pageSpinner", false);
            }), 2500
        );
        var groupId = helper.getGroupIdFromURL(component);
        if(groupId != '' && groupId != undefined && groupId != null) {
            helper.getGroupDetails(component, groupId);
        }
        else{
            helper.getCurrentUserInfo(component);
        }  
    },
    
    openProductRelationshipForm : function(component, event, helper) {
        component.set('v.modalSpinner', true);
        component.set('v.isOpenModal', true);
        window.setTimeout(
            $A.getCallback(function() {
                helper.checkGroupManager(component);
                helper.getProductRelationship(component);
                component.set("v.modalSpinner", false);
            }), 2500
        );
    },
    
    saveRecord: function(component, event, helper) {
        var selectedRecord = component.get('v.selectedRecord');
        if(selectedRecord != null && selectedRecord != '' && selectedRecord != undefined) {
            var isEditProductRelationship = component.get('v.isEditProductRelationship');
            if(isEditProductRelationship) {
                var productRelationship = component.get('v.productRelationship');
                if(productRelationship.Product__c == selectedRecord.value) {
                    component.set('v.isShowError', true);
                    component.set('v.errorMessage', $A.get('$Label.c.Please_select_new_product'));
                } else {
                    component.set('v.modalSpinner', true);
                    helper.updateProductRelationship(component);
                }
            } else{
                component.set('v.modalSpinner', true);
                helper.saveProductRelationship(component);
            }
            component.set('v.lookupValue','');
            component.set('v.searchString','');
        } else {
            component.set('v.isShowError', true);
            component.set('v.errorMessage', $A.get('$Label.c.Please_Select_a_Product'));
            component.set('v.modalSpinner', false);
        }
    },
    
    editRecord: function(component, event, helper) {
        component.set('v.modalSpinner', true);
        window.setTimeout(
            $A.getCallback(function() {
                helper.checkGroupManager(component);
                helper.getProductRelationship(component);
                component.set('v.isEditProductRelationship', true);
                component.set("v.modalSpinner", false);
            }), 2500
        );
    },
    
    closeModal : function(component, event, helper) {
        component.set('v.isOpenModal', false);
        component.set('v.isEditProductRelationship', false);
        component.set('v.selectedRecord','');
        component.set('v.lookupValue','');
        component.set('v.searchString','');
        component.set('v.isShowError', false);
        component.set('v.errorMessage', '');
    },
    
    searchRecords : function( component, event, helper ) {
        if(event.which == 13){
            event.preventDefault();
        }
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
            helper.searchProducts( component, event, helper, '' );
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
        component.set('v.isShowError', false);
        component.set('v.errorMessage', '');
    },
    
    removeItem: function(component, event, helper) {
        component.set('v.selectedRecord','');
        component.set('v.lookupValue','');
        component.set('v.searchString','');
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);        
    },
    
    selectItem : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            var recordsList = component.get('v.recordsList');
            var index = recordsList.findIndex(function (x) {return x.value===event.currentTarget.id});
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            component.set('v.selectedRecord', selectedRecord);
            component.set('v.lookupValue', selectedRecord.value);
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    blurEvent : function( component, event, helper ){
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
    
})