({
    doInit: function(component, event, helper) {
        var preSelectedField = component.get("v.preSelectedField");
        var preSelectedRecords = component.get("v.preSelectedValues");
        if (!$A.util.isEmpty(preSelectedField) && !$A.util.isEmpty(preSelectedRecords)) {
            helper.showSelectedRecords(component, event, preSelectedField, preSelectedRecords);
        } else {
            component.set("v.showSpinner", false);
        }
    },
    showError : function(component, event, helper) {
        var params = event.getParam('arguments');
        component.set("v.errorMessage", params.param);
    },
    onfocus: function(component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        var getInputkeyWord = component.get('v.SearchKeyWord');
        component.set("v.errorMessage", '');
        helper.searchHelper(component, event, getInputkeyWord);
    },
    onblur: function(component, event, helper) {
        component.set("v.listOfSearchRecords", null);
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController: function(component, event, helper) {
        var getInputkeyWord = component.get("v.SearchKeyWord");
        if (getInputkeyWord.length > 0) {
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, getInputkeyWord);
        } else {
            component.set("v.listOfSearchRecords", null);
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    clear: function(component, event, heplper) {
        var isMultiSelect = component.get("v.isMultiSelect");
        if (isMultiSelect) {
            var index = event.getSource().get("v.name");
            var selectedRecordList = component.get("v.selectedRecordList");
            var selectedRecordIds = component.get("v.selectedRecordIds");
            var removeId = selectedRecordList[index].recordId;
            selectedRecordList.splice(index, 1);
            selectedRecordIds = selectedRecordIds.replace(removeId, '');
            selectedRecordIds = selectedRecordIds.replace(',,', ',');
            component.set("v.selectedRecordList", selectedRecordList);
            component.set("v.selectedRecordIds", selectedRecordIds);
            component.set("v.SearchKeyWord", null);
            component.set("v.listOfSearchRecords", null);
        } else {
            var pillTarget = component.find("lookup-pill");
            var lookUpTarget = component.find("lookupField");

            $A.util.addClass(pillTarget, 'slds-hide');
            $A.util.removeClass(pillTarget, 'slds-show');

            $A.util.addClass(lookUpTarget, 'slds-show');
            $A.util.removeClass(lookUpTarget, 'slds-hide');

            component.set("v.SearchKeyWord", null);
            component.set("v.listOfSearchRecords", null);
            component.set("v.selectedRecord", {});
        }
    },

    handleComponentEvent: function(component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        var isMultiSelect = component.get("v.isMultiSelect");
        if (isMultiSelect) {
            var selectedRecordList = component.get("v.selectedRecordList");
            var selectedRecordIds = component.get("v.selectedRecordIds");
            if (selectedRecordIds.indexOf(selectedAccountGetFromEvent.recordId) <= 0) {
                selectedRecordList.push({
                    "recordId": selectedAccountGetFromEvent.recordId,
                    "searchField": selectedAccountGetFromEvent.searchField,
                    "Name": selectedAccountGetFromEvent.Name
                });
                selectedRecordIds = selectedRecordIds + ',' + selectedAccountGetFromEvent.recordId;
            }
            component.set("v.selectedRecordList", selectedRecordList);
            component.set("v.selectedRecordIds", selectedRecordIds);
            component.set("v.SearchKeyWord", null);
            component.set("v.listOfSearchRecords", null);
            console.log(selectedRecordList);
        } else {
            component.set("v.selectedRecord", {
                "recordId": selectedAccountGetFromEvent.recordId,
                "searchField": selectedAccountGetFromEvent.searchField,
                "Name": selectedAccountGetFromEvent.Name
            });
        }
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');
    },
})