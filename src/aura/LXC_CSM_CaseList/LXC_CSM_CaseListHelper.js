({
    getUserContact: function (component) {
        var action = component.get("c.getUserContact");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contact = response.getReturnValue()[0];
                if (contact) {
                    var portal_case_type = contact.Portal_Case_Type__c.split(';');
                    this.getCSMCommunityListViewConfig(component, portal_case_type);
                }
            } else if (state === "ERROR") {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },

    getCSMCommunityListViewConfig: function (component, userPortalCaseType) {
        var action = component.get("c.getCSMCommunityListViewConfig");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = [];
                var locale = $A.get("$Locale.language");
                var listViewConfigResult = response.getReturnValue();
                listViewConfigResult.sort((a, b) => (a.order__c > b.order__c) ? 1 : ((b.order__c > a.order__c) ? -1 : 0));
                var item;
                var portalCaseType;
                for (var i = 0; i < listViewConfigResult.length; i++) {
                    item = {};
                    portalCaseType = listViewConfigResult[i].Portal_Case_Type__c.split(';');
                    if (userPortalCaseType.some(r => portalCaseType.includes(r))) {
                        item.value = listViewConfigResult[i].Name;
                        if (listViewConfigResult[i][locale + "__c"] !== undefined && listViewConfigResult[i][locale + "__c"] !== "")
                            item.label = listViewConfigResult[i][locale + "__c"];
                        else
                            item.label = listViewConfigResult[i].en__c;
                        items.push(item);
                    }
                }

                var name = "favoriteListView=";
                var favListviewName = '';
                var ca = document.cookie.split(';');
                for (var i = 0; i < ca.length; i++) {
                    var c = ca[i];
                    while (c.charAt(0) == ' ') {
                        c = c.substring(1);
                    }
                    if (c.indexOf(name) == 0) {
                        favListviewName = c.substring(name.length, c.length);
                        component.set("v.favoriteListView", favListviewName);
                    }
                }

                if (favListviewName != '') {
                    for (var i = 0; i < items.length; i++) {
                        if (favListviewName === items[i].value) {
                            var itm = items[i];
                            items.splice(i, 1);
                            items.unshift(itm);
                            break;
                        }
                    }
                }
                component.set("v.listName", items[0].value);
                component.set("v.buttonMenuListNameLabel", items[0].label);
                component.set("v.actions", items);
                component.set("v.showListView", true);
            } else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    getCSMCommunityListViewForCurrentUser: function (component) {
        var action = component.get("c.getCSMCommunityListViewForCurrentUser");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = [];
                var locale = $A.get("$Locale.language");
                var listViewConfigResult = response.getReturnValue();
                var item;
                for (var i = 0; i < listViewConfigResult.length; i++) {
                    item = {};
                    item.value = listViewConfigResult[i].Name;
                    if (listViewConfigResult[i][locale + "__c"] !== undefined && listViewConfigResult[i][locale + "__c"] !== "")
                        item.label = listViewConfigResult[i][locale + "__c"];
                    else
                        item.label = listViewConfigResult[i].en__c;
                    items.push(item);
                }
                var name = "favoriteListView=";
                var favListviewName = '';
                var ca = document.cookie.split(';');
                for (var i = 0; i < ca.length; i++) {
                    var c = ca[i];
                    while (c.charAt(0) == ' ') {
                        c = c.substring(1);
                    }
                    if (c.indexOf(name) == 0) {
                        favListviewName = c.substring(name.length, c.length);
                        component.set("v.favoriteListView", favListviewName);
                    }
                }

                if (favListviewName != '') {
                    for (var i = 0; i < items.length; i++) {
                        if (favListviewName === items[i].value) {
                            var itm = items[i];
                            items.splice(i, 1);
                            items.unshift(itm);
                            break;
                        }
                    }
                }
                component.set("v.listName", items[0].value);
                component.set("v.buttonMenuListNameLabel", items[0].label);
                component.set("v.actions", items);
                component.set("v.showListView", true);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    }
})