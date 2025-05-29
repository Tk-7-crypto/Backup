({
    doInit: function(component, event, helper) {	
        var pagereference = component.get('v.pageReference');
        var caseId = component.get('v.pageReference').state.c__recordId;
        component.set('v.recordId', caseId);
        var workspaceAPI = component.find("workspace");        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
                workspaceAPI.isSubtab({
                    tabId: focusedTabId
                }).then(function(response) {
                    if (response) {
                        workspaceAPI.setTabLabel({
                            tabId: focusedTabId,
                            label: "Mass Activity Edit"
                        });
                        workspaceAPI.setTabIcon({
                            tabId: focusedTabId,
                            icon: "standard:case",
                            iconAlt: "activity edit"
                        });
                    }
                });
        })
        .catch(function(error) {
            console.log(error);
        });
        
        component.set('v.SpinnerMassEditActivity', true);
        var picklistWrapper = {'statusValues': [], 'passFailValues': [], 'losValues': [], 'emailCategorizationValues': [], 
                               'locationValues': [], 'typeValues': [], 'escalationTypeValues': [], 
                               'mapOfLOSAndTypeValues': {}, 'mapOfTypeAndEscalationTypeValues': {}
                              };
        component.set("v.picklistWrapper", picklistWrapper);
        var activityWrapperMapToSave = [];
        component.set("v.activityWrapperMapToSave", activityWrapperMapToSave);    
        component.set("v.activityWrapperMapKeySet", []);
        helper.loadActivityWrapperList(component);
        helper.loadPicklistValues(component, event);
    },
    
    onLOSChange: function(component, event, helper) {
        var selectedIndex = event.getSource().get("v.name");
        var selectedLOS = event.getSource().get("v.value");
        var PaginationList = component.get('v.PaginationList');
        if(selectedLOS == '' || selectedLOS == 'Please Specify') {
            PaginationList[selectedIndex].typeValues = [];
            PaginationList[selectedIndex].escalationTypeValues = [];
            PaginationList[selectedIndex].activity.Type__c = '';
            PaginationList[selectedIndex].activity.EscalationType__c = '';
            component.set('v.PaginationList', PaginationList);
        } else {
            helper.setDependentPicklistValues(component);
            var picklistWrapper = component.get("v.picklistWrapper");
            var typeValues = picklistWrapper.mapOfLOSAndTypeValues[selectedLOS];
            PaginationList[selectedIndex].activity.Type__c = '';
            if(typeValues.length == 0) {
                PaginationList[selectedIndex].escalationTypeValues = [];
                PaginationList[selectedIndex].activity.EscalationType__c = '';
            }
            component.set('v.PaginationList', PaginationList);
        }
    },
    
    onTypeChange: function(component, event, helper) {
        var selectedIndex = event.getSource().get("v.name");
        var selectedType = event.getSource().get("v.value");
        var PaginationList = component.get('v.PaginationList');
        PaginationList[selectedIndex].activity.EscalationType__c = '';
        if(selectedType == '' || selectedType == 'Please Specify') {
            PaginationList[selectedIndex].escalationTypeValues = [];
            component.set('v.PaginationList', PaginationList);
        } else {
            helper.setDependentPicklistValues(component);
        }
    },
    
    onSave: function(component, event, helper) {
        var activityWrapperMapToSave = component.get('v.activityWrapperMapToSave');
        helper.showSpinner(component);
        helper.setActivityListToBeUpdated(component, 'save');        
        helper.saveActivities(component);
    },
    
    navigation: function(component, event, helper) {
        component.set("v.SpinnerMassEditActivity", true); 
        var timerId = setInterval(function() { 
            var sObjectList = component.get("v.activityWrapperList");
            var end = component.get("v.endPage");
            var start = component.get("v.startPage");
            var pageSize = component.get("v.pageSize");
            var whichBtn = event.getSource().get("v.name");
            if (whichBtn == 'next') {
                component.set("v.currentPage", component.get("v.currentPage") + 1);
                helper.next(component, event, sObjectList, end, start, pageSize);
            }
            else if (whichBtn == 'previous') {
                component.set("v.currentPage", component.get("v.currentPage") - 1);
                helper.previous(component, event, sObjectList, end, start, pageSize);
            }
            component.set("v.SpinnerMassEditActivity", false); 
        }, 200);
        
        setTimeout(function() { 
            clearInterval(timerId); 
        }, 250);
    },
})