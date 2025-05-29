({
	//for navigate to another url
    gotoURL : function (component, urlToNavigate) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({"url": urlToNavigate});
        urlEvent.fire();
    },

})