({
    getUserContact: function (component) {
        var action = component.get("c.getUserContact");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contact = response.getReturnValue()[0];
                if (contact) {
                    var portal_case_type = contact.Portal_Case_Type__c.split(';');
                    this.getPRMCommunityListViewConfig(component, portal_case_type);
                }
            } else if (state === "ERROR") {
                console.log("ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    
    getPRMCommunityListViewConfig: function (component, userPortalCaseType) {
        var action = component.get("c.getPRMCommunityListViewConfig");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = [];                
                var listViewConfigResult = response.getReturnValue();
                listViewConfigResult.sort((a, b) => (a.order__c > b.order__c) ? 1 : ((b.order__c > a.order__c) ? -1 : 0));
                var item;
                var portalCaseType;
                for (var i = 0; i < listViewConfigResult.length; i++) {
                    item = {};
                    portalCaseType = listViewConfigResult[i].Portal_Case_Type__c.split(';');
                    if (userPortalCaseType.some(r => portalCaseType.includes(r))) {
                        item.value = listViewConfigResult[i].Name;
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
    }
})