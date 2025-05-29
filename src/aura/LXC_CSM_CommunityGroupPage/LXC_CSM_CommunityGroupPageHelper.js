({
    searchProducts : function(component, event, helper, value) {
        $A.util.removeClass(component.find("lookupSpinner"), "slds-hide");
        component.set('v.lookupMessage','');
        component.set('v.recordsList',null);
        var action = component.get('c.searchProducts');
        action.setStorable();
        action.setParams({
            'searchString' : component.get('v.searchString')
        });
        action.setCallback(this,function(response){
            var result = response.getReturnValue();
            if(response.getState() === 'SUCCESS') {
                if(result.length > 0) {
                    if( $A.util.isEmpty(value) ) {
                        component.set('v.recordsList',result);        
                    } else {
                        var index = result.findIndex(function (x) {return x.value===value});
                        if(index != -1) {
                            var selectedRecord = result[index];
                        }
                        component.set('v.selectedRecord',selectedRecord);
                    }
                } else {
                    component.set('v.lookupMessage', $A.get('$Label.c.No_Records_Found'));
                }
            } else if(response.getState() === 'INCOMPLETE') {
                component.set('v.lookupMessage','No Server Response or client is offline');
            } else if(response.getState() === 'ERROR') {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.lookupMessage', errors[0].message);
                }
            }
            if( $A.util.isEmpty(value) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
            $A.util.addClass(component.find("lookupSpinner"), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    checkGroupManager : function(component) {
        var action = component.get('c.checkGroupManagerExistence');
        action.setParams({
            'groupId' : component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS') {
                var groupManagerExist = response.getReturnValue();
                component.set('v.groupManagerExist', groupManagerExist);
                if(groupManagerExist) {
                    $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
                    if( !$A.util.isEmpty(component.get('v.lookupValue')) ) {
                        this.searchProducts( component, event, helper, component.get('v.lookupValue') );
                    }
                    component.set('v.modalSpinner', false);
                }
            } else if(response.getState() === 'ERROR') {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log('ERROR [LXC_CSM_CommunityGroupPage] = ',errors[0].message);
                    component.set('v.modalSpinner', false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    saveProductRelationship : function(component) {
        var action = component.get('c.saveProductRelationship');
        action.setParams({
            'groupId' : component.get('v.recordId'),
            'selectedProduct' : component.get('v.selectedRecord'),
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS') {
                var productRelationship = response.getReturnValue();
                if(productRelationship != null && productRelationship != undefined && productRelationship != ''){
                    component.set('v.productRelationship', productRelationship);
                    component.set('v.productRelationshipExist', true);
                    component.set('v.isEditProductRelationship', false);
                    component.set('v.modalSpinner', false);
                    component.set('v.isOpenModal', false);
                    this.showToast("Success", "Product relationship created successfully!!", "success");
                }
            } else if(response.getState() === 'ERROR') {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log('ERROR [LXC_CSM_CommunityGroupPage] = ', errors[0].message);
                    component.set('v.isOpenModal', false);
                    component.set('v.modalSpinner', false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    updateProductRelationship : function(component) {
        var action = component.get('c.updateProductRelationship');
        action.setParams({
            'groupId' : component.get('v.recordId'),
            'selectedProduct' : component.get('v.selectedRecord'),
            'productRelationship' : component.get('v.productRelationship')
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS') {
                var productRelationship = response.getReturnValue();
                if(productRelationship != null && productRelationship != undefined && productRelationship != ''){
                    component.set('v.productRelationship', productRelationship);
                    component.set('v.modalSpinner', false);
                    this.showToast("Success", "Product relationship updated successfully!!", "success");
                    component.set('v.isOpenModal', false);
                    component.set('v.productRelationshipExist', true);
                    component.set('v.isEditProductRelationship', false);
                }
            } else if(response.getState() === 'ERROR') {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log('ERROR [LXC_CSM_CommunityGroupPage] = ', errors[0].message);
                    component.set('v.modalSpinner', false);
                    component.set('v.isOpenModal', false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getProductRelationship : function(component) {
        var action = component.get('c.getProductRelationship');
        action.setParams({
            'groupId' : component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS') {
                var productRelationship = response.getReturnValue();
                if(productRelationship != null && productRelationship != undefined && productRelationship != ''){
                    component.set('v.productRelationship', productRelationship);
                    var selectedRecord = {'label': productRelationship.Product__r.Name, 'value': productRelationship.Product__c,
                                          'product': ''};
                    component.set('v.selectedRecord', selectedRecord);
                    component.set('v.productRelationshipExist', true);
                    component.set('v.modalSpinner', false);
                } else {
                    component.set('v.productRelationshipExist', false);
                }
            } else if(response.getState() === 'ERROR') {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log('ERROR [LXC_CSM_CommunityGroupPage] = ',errors[0].message);
                    component.set('v.modalSpinner', false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getCurrentUserInfo: function (component) {
        var action = component.get("c.getCurrentUserInfo");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var currentUser = response.getReturnValue();
                component.set("v.currentUser", currentUser);
                if(currentUser.Profile.Name == 'Service User' || currentUser.Profile.Name == 'System Administrator'  || currentUser.Profile.Name == 'System Administrator Module' || currentUser.Profile.Name == 'System Administrator Package Support' || currentUser.Profile.Name == 'System Administrator Integration' || currentUser.Profile.Name == 'IQVIA Salesforce Platform Support') {
                    var recordId = component.get('v.recordId');
                    if(recordId != undefined && recordId != '' && recordId != null && recordId != 'Default' ) {
                        component.set('v.showProductRelationshipButton', true);
                        this.getGroupDetails(component, recordId);
                        this.getProductRelationship(component);
                    } 
                }
            } else if (state === "ERROR") {
                console.log("LXC_CSM_CommunityGroupPage] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    
    getGroupIdFromURL : function(component) {
        var groupId = "";
        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        var sURLVariables = sPageURL.split('&');
        var sParameterName;
        var i;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); 
            if (sParameterName[0] === 'groupId') { 
                sParameterName[1] === undefined ? '' : sParameterName[1];
                groupId = sParameterName[1];
            }
        }
        return groupId;
    },
    
    getGroupDetails : function(component, groupId) {
        var action = component.get("c.getGroupDetails");
        action.setParams({
            "groupId": groupId            
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var data = [];
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != null) {
                    var group = result;
                    component.set('v.currentGroupName', group.Name);
                } 
            } else {
                console.log("LXC_CSM_CommunityGroupDetail] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(title, message, type) {
        var toastParams = {
            title: title,
            message: message, 
            type: type
        };
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },   
})