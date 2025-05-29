({
    searchFor: function (component) {
        var searchText = component.find('enter-search').get('v.value');
        searchText = searchText.replace(/[^a-zA-Z0-9]/g, ' ');
        searchText = searchText.split(' ').filter((ele) => ele.length > 2).join(' ');
        var searchForPrd = "";
        if(component.find('searchForPrd')!= undefined) {
           searchForPrd = component.find('searchForPrd').get('v.value');
        }
        var limit = component.get("v.limit");
        sessionStorage.setItem('search--text', searchText);
        sessionStorage.setItem('search--prd', searchForPrd);
        var action = component.get('c.searchForIds');
        action.setParams({
            searchText: searchText,
            searchForPrd: searchForPrd,
            searchObject: '',
            rowLimit: limit,
            rowOffset: 0
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var results = response.getReturnValue();
                sessionStorage.setItem('customSearch--results', JSON.stringify(results));
                var navEvt = $A.get('e.force:navigateToURL');
                navEvt.setParams({ url: '/search-results' });
                navEvt.fire();
            } else {
                console.log("ERROR: " + JSON.stringify(response.getError()));
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
                    this.getProductCommunityTopics(component);
                }
            } else if (state === "ERROR") {
                console.log("ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },

    getProductCommunityTopics: function (component) {
        var action = action = component.get("c.getProductCommunityTopics");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var products = response.getReturnValue();
                var items = [];
                var item = {
                    "label": $A.get("$Label.c.All_Products"),
                    "value": ""
                };
                items.push(item);
                products.forEach(prd => {
                    var item = {
                        "label": prd.Name,
                        "value": prd.Id
                    };
                    items.push(item);
                });

                component.set("v.options", items);
            } else if (state === "ERROR") {
                console.log("ERROR: " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
})