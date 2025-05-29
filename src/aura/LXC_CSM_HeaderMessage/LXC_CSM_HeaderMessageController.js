({
	doInit : function(component, event, helper) {
        helper.checkUserProfile(component);
        //helper.getMajorIncidents(component);
        helper.getListViewId(component);
	},

    openProgressTab : function(component, event, helper){
        var navEvent = $A.get("e.force:navigateToURL");
        var id = component.get("v.InProgressListView");
        navEvent.setParams({
            "url" : '/lightning/o/Major_Incident__c/list?filterName='+id
        });
        navEvent.fire();
    },
    
    openResolvedTab : function(component, event, helper){
        var navEvent = $A.get("e.force:navigateToURL");
        var id = component.get("v.ResolvedListView");
        navEvent.setParams({
            "url" : '/lightning/o/Major_Incident__c/list?filterName='+id
        });
        navEvent.fire();
    }
})