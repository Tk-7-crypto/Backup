({
    getArticlesByCategoryForCurrentUser: function (component) {
        component.set("v.isLoading", true);
        var partnerURL = component.get('v.partnerURL');
        if (partnerURL == true) {
            var action = component.get("c.getArticlesByCategoryForCurrentPRMUser");
            action.setParams({
                "category": component.get('v.category'),
                "salesCollateral": component.get('v.oce_sales_articles')
            });
        }
        else {
            var action = component.get("c.getArticlesByCategoryForCurrentUser");
            action.setParams({
                "category": component.get('v.category')
            });
        }
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var articles = response.getReturnValue();
                console.log('success', JSON.stringify(articles));
                var categorization = [];
                var articleObj = [];
                var articles2 = [];
                var cat;
                if (partnerURL == true) {

                    for (var i = 0; i < articles.length; i++) {
                        if (articles[i].contentArticle.Article_Chapter__c) cat = articles[i].contentArticle.Article_Chapter__c;
                        else cat = "Other";
                        if (categorization.indexOf(cat) === -1) categorization.push(cat);
                    }
                    for (var i = 0; i < categorization.length; i++) {
                        articles2 = [];
                        for (var j = 0; j < articles.length; j++) {
                            if (articles[j].contentArticle.Article_Chapter__c) cat = articles[j].contentArticle.Article_Chapter__c;
                            else cat = "Other";
                            if (cat === categorization[i]) {
                                articles2.push(articles[j])
                            }
                        }

                        articles2.sort(function (a, b) { return (a.Title > b.Title) ? 1 : ((b.Title > a.Title) ? -1 : 0); });
                        articleObj.push({
                            categorization: categorization[i],
                            articles: articles2
                        });
                    }
                } else {
                    if (articles.length < 1 && component.get('v.category') !== '') {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/resources?name=" + component.get('v.category')
                        });
                        urlEvent.fire();
                        return;
                    }
                    var articleFav = component.get("v.articleFav");
                    for (var i = 0; i < articles.length; i++) {
                        if (articles[i].contentArticle.Article_Chapter__c && articles[i].contentArticle.Article_Chapter__c !== 'Please Specify') 
                            cat = articles[i].contentArticle.Article_Chapter__c;
                        else cat = $A.get("$Label.c.Uncategorized");
                        if (categorization.indexOf(cat) === -1) categorization.push(cat);
                        articleFav.forEach(fav => {
                            if (fav.EntityId__c == articles[i].contentArticle.KnowledgeArticleId) {
                                articles[i].fav = true;
                            }
                        });
                    }
                    for (var i = 0; i < categorization.length; i++) {
                        articles2 = [];
                        for (var j = 0; j < articles.length; j++) {
                            if (articles[j].contentArticle.Article_Chapter__c && articles[j].contentArticle.Article_Chapter__c !== 'Please Specify')
                                cat = articles[j].contentArticle.Article_Chapter__c;
                            else cat = $A.get("$Label.c.Uncategorized");
                            if (cat === categorization[i]) {
                                articles2.push(articles[j])
                            }
                        }
                        articleObj.push({
                            categorization: categorization[i],
                            articles: articles2
                        });
                    }
                }
                articleObj.sort(function (a, b) { return (a.categorization > b.categorization) ? 1 : ((b.categorization > a.categorization) ? -1 : 0); });
                component.set("v.articleObj", articleObj);
                component.set("v.articleObjfiltered", articleObj);
                if (articleObj.length === 1) {
                    component.set("v.numChapter", 0);
                } else {
                    component.set("v.numChapter", -1);
                }

            } else if (state === 'ERROR') {
                console.log("CNT_CSM_PortalArticles] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    getFavoriteArticles: function (component) {
        var action = component.get("c.getFavoriteArticles");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.articleFav", response.getReturnValue());
            } else {
                console.log("Error", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
})