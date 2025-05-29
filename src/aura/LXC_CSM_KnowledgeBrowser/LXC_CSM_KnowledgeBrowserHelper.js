({
    getProducts: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getProducts");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var products = response.getReturnValue();
                products.sort(function (a, b) { return (a.Name.toLowerCase() > b.Name.toLowerCase()) ? 1 : ((b.Name.toLowerCase() > a.Name.toLowerCase()) ? -1 : 0); });
                component.set("v.products", products);
                component.set("v.filteredProducts", products);
            } else if (state === "ERROR") {
                console.log("ERROR:" + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    getAccountsArticlesByProductName: function (component, productName) {
        var action = component.get("c.getAccountsArticlesByProductName");
        action.setParams({
            "productName": productName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var accounts = [];
                for (let [key, value] of Object.entries(response.getReturnValue())) {
                    accounts.push(value);
                }
                accounts.sort(function (a, b) { return (a.Name.toLowerCase() > b.Name.toLowerCase()) ? 1 : ((b.Name.toLowerCase() > a.Name.toLowerCase()) ? -1 : 0); });
                component.set("v.accounts", accounts);
            } else if (state === 'ERROR') {
                console.log("ERROR:" + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    getArtclesByProductName: function (component, productName, accId) {
        component.set("v.isLoading", true);
        var action = component.get("c.getArticlesByProductName2");
        action.setParams({
            "productName": productName,
            "accountId": accId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var articles = response.getReturnValue();
                console.log(articles);
                var categorization = [];
                var articleObj = [];
                var articles2 = [];
                var cat;
                for (var i = 0; i < articles.length; i++) {
                    if (articles[i].Article_Chapter__c) cat = articles[i].Article_Chapter__c;
                    else cat = "Other";
                    if (categorization.indexOf(cat) === -1) categorization.push(cat);
                }
                for (var i = 0; i < categorization.length; i++) {
                    articles2 = [];
                    for (var j = 0; j < articles.length; j++) {
                        if (articles[j].Article_Chapter__c) cat = articles[j].Article_Chapter__c;
                        else cat = "Other";
                        if (cat === categorization[i]) {
                            articles2.push(articles[j])
                        }
                    }
                    articleObj.push({
                        categorization: categorization[i],
                        articles: articles2
                    });
                }
                articleObj.sort(function (a, b) { return (a.categorization > b.categorization) ? 1 : ((b.categorization > a.categorization) ? -1 : 0); });
                component.set("v.articleObj", articleObj);
                component.set("v.filteredArticleObj", articleObj);
            } else if (state === 'ERROR') {
                console.log("ERROR:" + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },


    getArticlesByAccount: function (component) {
        var accId = component.find('accountId').get('v.value');
        var productName = component.get("v.productName");
        console.log(accId);
        if (accId === "") {
            this.getArtclesByProductName(component,productName);
        } else {
            this.getArtclesByProductName(component,productName,accId);
        }

        
    },
})