({
    searchHelper: function(component, event, getInputkeyWord) {
        var action = component.get("c.fetchLookUpData");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'objectName': component.get("v.objectAPIName"),
            'searchField': component.get("v.searchField"),
            'displayField': component.get("v.displayField"),
            'subTextField': component.get("v.subTextField"),
            'whereClause': component.get("v.whereClause"),
            'showRecordsOnTypeOnly': component.get("v.showRecordsOnTypeOnly"),
            'queryLimit': component.get("v.limit")
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    showSelectedRecords: function(component, event, preSelectedField, preSelectedRecords) {
        var action = component.get("c.setSelectedData");
        action.setParams({
            'objectName': component.get("v.objectAPIName"),
            'searchField': component.get("v.searchField"),
            'displayField': component.get("v.displayField"),
            'subTextField': component.get("v.subTextField"),
            'whereClause': component.get("v.whereClause"),
            'preSelectedField': preSelectedField,
            'preSelectedRecords': preSelectedRecords
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length > 0) {
                    var isMultiSelect = component.get("v.isMultiSelect");
                    if (isMultiSelect) {
                        component.set("v.selectedRecordList", storeResponse);
                        var selectedRecordIds = component.get("v.selectedRecordIds");
                        for (var index in storeResponse) {
                            selectedRecordIds = selectedRecordIds + ',' + storeResponse[index].recordId;
                        }
                        component.set("v.selectedRecordIds", selectedRecordIds);
                    } else {
                        component.set("v.selectedRecord", storeResponse[0]);
                        var forclose = component.find("lookup-pill");
                        $A.util.addClass(forclose, 'slds-show');
                        $A.util.removeClass(forclose, 'slds-hide');

                        var forclose = component.find("searchRes");
                        $A.util.addClass(forclose, 'slds-is-close');
                        $A.util.removeClass(forclose, 'slds-is-open');

                        var lookUpTarget = component.find("lookupField");
                        $A.util.addClass(lookUpTarget, 'slds-hide');
                        $A.util.removeClass(lookUpTarget, 'slds-show');
                    }
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
})