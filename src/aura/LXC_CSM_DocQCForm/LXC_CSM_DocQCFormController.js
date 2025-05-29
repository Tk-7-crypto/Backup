({
    onPageReferenceChange : function (component, event, helper) {
        var caseId = component.get('v.pageReference').state.c__caseId;
        console.log('caseId : '+caseId);
        console.log('myPageRef : '+component.get("v.pageReference"));
        console.log('myPageRef JSON: '+JSON.stringify(component.get("v.pageReference")));
		//var id = myPageRef.state.c__id;
        //component.set("v.id", id); 
	}
})