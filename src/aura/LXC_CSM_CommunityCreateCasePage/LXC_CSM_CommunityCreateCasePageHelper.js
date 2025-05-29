({
    getTPAAccess: function (component) {
        var action = component.get("c.checkTPAPermissionSetsAssigned");
        action.setParams({
            'pmSetTPA': component.get("v.tpaAppPermissionSets")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isTPAAccess", response.getReturnValue());
                component.set("v.headerContent", $A.get("$Label.c.Third_Party_Agreement_TPA_Information"));
                component.set("v.bodyContent", '<p>' + $A.get("$Label.c.Third_Party_Agreement_services_are_now_available_in_IQVIA_CSH") + '</p><br>' +
                    '<p>' + $A.get("$Label.c.To_create_a_TPA_request_please_click_on_the_9_dots") +
                    '<span class="slds-icon_container slds-icon-utility-apps" title="AppLauncher icon">' +
                    '<svg class="slds-icon slds-icon-text-default" aria-hidden="true">' +
                    '<use lightning-primitiveIcon_primitiveIcon="" xlink:href="/support/_slds/icons/utility-sprite/svg/symbols.svg?cache=9.31.2-1#apps"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" id="apps"><path d="M6 1.8H3.2c-.8 0-1.4.6-1.4 1.4V6c0 .8.6 1.4 1.4 1.4H6c.8 0 1.4-.6 1.4-1.4V3.2c0-.8-.6-1.4-1.4-1.4zm0 14.8H3.2c-.8 0-1.4.6-1.4 1.4v2.8c0 .8.6 1.4 1.4 1.4H6c.8 0 1.4-.6 1.4-1.4V18c0-.8-.6-1.4-1.4-1.4zm0-7.4H3.2c-.8 0-1.4.6-1.4 1.4v2.8c0 .8.6 1.4 1.4 1.4H6c.8 0 1.4-.6 1.4-1.4v-2.8c0-.8-.6-1.4-1.4-1.4zm7.4-7.4h-2.8c-.8 0-1.4.6-1.4 1.4V6c0 .8.6 1.4 1.4 1.4h2.8c.8 0 1.4-.6 1.4-1.4V3.2c0-.8-.6-1.4-1.4-1.4zm0 14.8h-2.8c-.8 0-1.4.6-1.4 1.4v2.8c0 .8.6 1.4 1.4 1.4h2.8c.8 0 1.4-.6 1.4-1.4V18c0-.8-.6-1.4-1.4-1.4zm0-7.4h-2.8c-.8 0-1.4.6-1.4 1.4v2.8c0 .8.6 1.4 1.4 1.4h2.8c.8 0 1.4-.6 1.4-1.4v-2.8c0-.8-.6-1.4-1.4-1.4zm7.4-7.4H18c-.8 0-1.4.6-1.4 1.4V6c0 .8.6 1.4 1.4 1.4h2.8c.8 0 1.4-.6 1.4-1.4V3.2c0-.8-.6-1.4-1.4-1.4zm0 14.8H18c-.8 0-1.4.6-1.4 1.4v2.8c0 .8.6 1.4 1.4 1.4h2.8c.8 0 1.4-.6 1.4-1.4V18c0-.8-.6-1.4-1.4-1.4zm0-7.4H18c-.8 0-1.4.6-1.4 1.4v2.8c0 .8.6 1.4 1.4 1.4h2.8c.8 0 1.4-.6 1.4-1.4v-2.8c0-.8-.6-1.4-1.4-1.4z"></path></svg></use>' +
                    '</svg>' +
                    '<span class="slds-assistive-text">AppLauncher icon</span>' +
                    '</span> ' + $A.get("$Label.c.on_the_top_left_of_the_home_page_to_navigate_to_TPA_services") + '</p>');
            } else if (state === "ERROR") {
                console.log("ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },

    getUserContact: function (component) {
        var action = component.get("c.getUserContact");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contact = response.getReturnValue()[0];
                if (contact) {
                    component.set("v.contact", contact);
                    if (contact.Remove_Case_Creation__c === true) {
                        component.set("v.allowed", false);
                    } else {
                        component.set("v.allowed", true);
                    }
                }
            } else if (state === "ERROR") {
                console.log("ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },

})