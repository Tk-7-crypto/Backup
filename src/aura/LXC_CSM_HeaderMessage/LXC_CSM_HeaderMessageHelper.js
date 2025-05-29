({
    checkUserProfile : function(component) {
        var action = component.get("c.getUserProfile");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var profileObject = response.getReturnValue();
                var userProfile = profileObject.Name;
                if(userProfile == "Service User"){
                    this.getMajorIncidents(component);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
	getMajorIncidents : function(component) {
        var action = component.get("c.getAllInternalCommunications");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var majorIncidentList = response.getReturnValue();
                if(majorIncidentList != undefined && majorIncidentList.length>0){
                    component.set("v.displayMajorIncident", true);
                    var status = majorIncidentList[0].Status__c;
                    if(status == 'In Progress'){
                        component.set("v.displayWarningMessage", true);
                    }
                    else if(status == 'Resolved'){
                        component.set("v.displaySuccessMessage", true);
                    }
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    getListViewId : function(component) {
        var action = component.get("c.getListViewRelatedIds");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var MIviewlist = response.getReturnValue();
                if(MIviewlist != undefined && MIviewlist.length > 0){
                    for(var i=0; i<MIviewlist.length; i++){
                        var viewName = MIviewlist[i].Name;
                        if(viewName == "In Progress MI List View"){
                            component.set("v.InProgressListView", MIviewlist[i].List_View_Id__c);
                        }
                        else if(viewName == "Resolved MI List View"){
                            component.set("v.ResolvedListView", MIviewlist[i].List_View_Id__c);
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})