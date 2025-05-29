({
	doInit: function(component, event, helper) {
		helper.getArtclesByTopicId(component);
	},
	
	showMore: function(component, event, helper) {
		component.set("v.numChapter",parseInt(event.currentTarget.dataset.chapter_num));
		component.set("v.articleObj", component.get("v.articleObj"));
	},
	
	back: function(component, event, helper) {
		component.set("v.numChapter",-1)
		component.set("v.articleObj", component.get("v.articleObj"));
	}
})