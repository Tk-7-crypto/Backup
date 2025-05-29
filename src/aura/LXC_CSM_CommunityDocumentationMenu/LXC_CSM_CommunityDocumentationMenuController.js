({
    doInit: function (component, event, helper) {
        let currentUser = $A.get("$SObjectType.CurrentUser.Id");
        if (currentUser)
            component.set("v.userId", currentUser.substring(0, 15))
        var partnerURL = component.get('v.partnerURL');
        console.log('Inside Init');
        if (partnerURL == true) {
            var action = component.get("c.getProductDetails");
            action.setParams({
                "category": component.get('v.category')
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var productDetail = response.getReturnValue();
                    console.log('Product description : : : ' + productDetail[0].Name);
                    component.set("v.prodDescription", productDetail[0].Community_Description__c);
                }
            });
            $A.enqueueAction(action);
        }
    },
    openMenu: function (component, event, helper) {
        var page = event.target.getAttribute("data-pageName");
        if (component.get("v.userId") !== undefined || page === 'doc') {
            var navService = component.find("navService");
            event.preventDefault();
            var pageReference = {
                type: "standard__namedPage",
                attributes: {
                    pageName: page
                },
                state: {
                    name: component.get("v.category")
                }
            };
            sessionStorage.setItem('localTransfer', JSON.stringify(pageReference.state));
            navService.navigate(pageReference);
        } else {
            window.location.href = '/support/login?ec=302&startURL='+ $A.get("$Site.siteUrlPrefix") +'/'+ page+'?name='+component.get("v.category");
        }
    }
})