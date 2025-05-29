({
    getFavorites: function (component) {
        var action = component.get("c.getFavorites");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var favorites = response.getReturnValue();
                var articles = [];
                var cases = [];
                for (var i = 0; i < favorites.length; i++) {
					if (favorites[i].entityName === 'Case') {
                        cases.push(favorites[i]);
                    }
                    if (favorites[i].entityName === 'Knowledge__kav') {
                        articles.push(favorites[i]);
                    }
                }
                articles.sort(function (a, b) { return (a.title > b.title) ? 1 : ((b.title > a.title) ? -1 : 0); });
                component.set("v.cases", cases);
                component.set("v.articles", articles);                
            } else {
                console.log("Error", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
})