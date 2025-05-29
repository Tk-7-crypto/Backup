({
    doInit: function (component, event, helper) {
        let currentUser = $A.get("$SObjectType.CurrentUser.Id");
        if(currentUser)
            component.set("v.userId", currentUser.substring(0, 15))
        helper.getFavoriteArticles(component);
        helper.getArticlesByCategoryForCurrentUser(component);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
    },

    showMore: function (component, event, helper) {
        component.set("v.numChapter", parseInt(event.currentTarget.dataset.chapter_num));
        //component.set("v.articleObj", component.get("v.articleObj"));
    },

    back: function (component, event, helper) {
        component.set("v.numChapter", -1)
        //component.set("v.articleObj", component.get("v.articleObj"));
    },

    filter: function (component, event, helper) {
        var articleObj = component.get("v.articleObj");
        var articleObjfiltered = [];
        var isFilteredByAcc = component.get("v.isFilteredByAcc");
        var isFilteredByFav = component.get("v.isFilteredByFav");
        var isFilteredByNew = component.get("v.isFilteredByNew");
        var isFilteredByUpdated = component.get("v.isFilteredByUpdated");

        var filterType = event.target.getAttribute("data-type");
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");

        if (filterType === "byUpdated") {
            isFilteredByUpdated = !isFilteredByUpdated;
        }
        if (filterType === "byNew") {
            isFilteredByNew = !isFilteredByNew;
        }
        if (filterType === "byFav") {
            isFilteredByFav = !isFilteredByFav;
        }
        if (filterType === "byAcc") {
            isFilteredByAcc = !isFilteredByAcc;
        }
        if (!isFilteredByFav && !isFilteredByAcc && !isFilteredByNew && !isFilteredByUpdated) {
            component.set("v.articleObjfiltered", articleObj);
        } else {
            articleObj.forEach(element => {
                var articles = element.articles;
                var articlesfiltered = [];
                articles.forEach(article => {
                    if ((article.forThisAcc === true && isFilteredByAcc) || (article.fav === true && isFilteredByFav) || (article.contentArticle.End_date_of_display_as_new_or_updated__c >= today && article.contentArticle.VersionNumber === 1 && isFilteredByNew) || (article.contentArticle.End_date_of_display_as_new_or_updated__c >= today && isFilteredByUpdated && article.contentArticle.VersionNumber !== 1)) {
                        articlesfiltered.push(article);
                    }
                });
                articleObjfiltered.push({
                    categorization: element.categorization,
                    articles: articlesfiltered
                });
            });
            component.set("v.articleObjfiltered", articleObjfiltered);
        }
        component.set("v.isFilteredByAcc", isFilteredByAcc);
        component.set("v.isFilteredByFav", isFilteredByFav);
        component.set("v.isFilteredByNew", isFilteredByNew);
        component.set("v.isFilteredByUpdated", isFilteredByUpdated);
    },

    filterPRMArticles: function (component, event, helper) {
        var articleObj = component.get("v.articleObj");
        var articleObjfiltered = [];
        var isFilteredByNew = component.get("v.isFilteredByNew");
        var isFilteredByUpdated = component.get("v.isFilteredByUpdated");
        var filterType = event.target.getAttribute("data-type");
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");

        if (filterType === "byUpdated") {
            isFilteredByUpdated = !isFilteredByUpdated;
            console.log("filterByUpdated : " + isFilteredByUpdated);
        }
        if (filterType === "byNew") {
            isFilteredByNew = !isFilteredByNew;
            console.log("filterByNew : " + isFilteredByNew);
        }

        if (!isFilteredByUpdated && !isFilteredByNew) {
            console.log('if : : : ');
            component.set("v.articleObjfiltered", articleObj);
        } else {
            console.log('else : : : ');
            console.log('article object : ' + articleObj);
            articleObj.forEach(element => {
                var articles = element.articles;
                console.log('articles loop  : ' + articles);
                var articlesfiltered = [];
                articles.forEach(article => {
                console.log('articles loop inner : ' + article.versionNumber);
                    if ( (article.visibilityDate >= today && article.versionNumber == '1' && isFilteredByNew) || (article.visibilityDate >= today && isFilteredByUpdated && article.versionNumber!= '1')) {
                        articlesfiltered.push(article);
                    }
                });
                articleObjfiltered.push({
                    categorization: element.categorization,
                    articles: articlesfiltered
                });
            });
            component.set("v.articleObjfiltered", articleObjfiltered);
            console.log('filtered articles' + articleObjfiltered)
        }
        component.set("v.isFilteredByNew", isFilteredByNew);
        component.set("v.isFilteredByUpdated", isFilteredByUpdated);
    }
})