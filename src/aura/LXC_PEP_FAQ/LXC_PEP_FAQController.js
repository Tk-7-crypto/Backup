({
	doInit: function(component, event, helper) {     
        var action = component.get("c.getFAQArticles");    
        action.setCallback(this, function(response){
            console.log('in callback');
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('in success');
                var faqArticles = response.getReturnValue();
                component.set("v.articles", faqArticles);
            }
            else{console.log('Error');}
        });
        $A.enqueueAction(action);
        
    }
})