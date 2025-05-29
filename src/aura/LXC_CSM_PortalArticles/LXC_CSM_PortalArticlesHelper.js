({
	getArtclesByTopicId: function(component){
		component.set("v.isLoading", true);
		var action = component.get("c.getArticlesByTopic");
		action.setParams({
			"topicId":  component.get("v.topicId")
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var articles = response.getReturnValue();
				var categorization=[];
				var articleObj=[];
				var articles2=[];
				var cat;
				for (var i = 0; i < articles.length; i++) {
					if(articles[i].Article_Chapter__c) cat =articles[i].Article_Chapter__c;
					else cat = "Other";
					if (categorization.indexOf(cat) === -1) categorization.push(cat);
				}
				for (var i = 0; i < categorization.length; i++) {
					articles2=[];
					for (var j = 0; j < articles.length; j++) {
						if(articles[j].Article_Chapter__c) cat =articles[j].Article_Chapter__c;
						else cat = "Other";
						if(cat=== categorization[i]){
							articles2.push(articles[j])
						}
					}
					articleObj.push({
						categorization: categorization[i],
						articles: articles2
					});
				}
				articleObj.sort(function(a,b) {return (a.categorization > b.categorization) ? 1 : ((b.categorization > a.categorization) ? -1 : 0);} );
				component.set("v.articleObj", articleObj);
			}else if(state === 'ERROR'){
				console.log("CNT_CSM_PortalArticles] ERROR " + JSON.stringify(response.getError()));
			}
			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},
})