({
    init: function (component, event, helper) {
        helper.getUserContact(component);
    },

    ListViewSelect: function (component, event) {
        component.set("v.showListView", false);
        var selectedMenuItemValue = event.getParam("value");
        var items = component.get("v.actions");
        component.set("v.listName", selectedMenuItemValue);

        for (var i = 0; i < items.length; i++) {
            if (items[i].value == selectedMenuItemValue) {
                component.set("v.buttonMenuListNameLabel", items[i].label);
            }
        }
        component.set("v.showListView", true);
    },
    
    pinListViewClick: function (component, event, helper) {
        var toastEvent;
        toastEvent = $A.get("e.force:showToast");
        var d = new Date();
        d.setTime(d.getTime() + (365 * 24 * 60 * 60 * 1000));
        var expires = "expires=" + d.toUTCString();
        var cvalue = component.get("v.listName");
        if (component.get("v.favoriteListView") === cvalue) {
            cvalue = '';
            toastEvent.setParams({
                "message": $A.get("$Label.c.This_List_View_is_no_longer_your_favorite"),
                "type": "success"
            });
        } else {
            toastEvent.setParams({
                "message": $A.get("$Label.c.This_List_View_is_now_your_favorite"),
                "type": "success"
            });
        }
        document.cookie = "favoriteListView=" + cvalue + ";" + expires + ";path=/";
        component.set("v.favoriteListView", cvalue);
        toastEvent.fire();
    }
})