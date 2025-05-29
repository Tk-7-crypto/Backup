({
    getUserContact: function(component){
        var action = component.get("c.getUserContact");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contact = response.getReturnValue()[0];
                if (contact){
                    component.set("v.contact",contact);
                    var portal_case_type = contact.Portal_Case_Type__c.split(';');
                    component.set("v.portalCaseTypes",portal_case_type);
                }
            } else if (state === "ERROR") {
                console.log("LXC_CSM_PortalReport] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
/*
    getDashboards: function(component,listDashboardIds,dashboardsObjToPopulate){
        var dashboardIds=[];
        dashboardIds = component.get(listDashboardIds).split(',');
        var action = component.get("c.getDashboards");
        action.setParams({
            "dashboardIds": dashboardIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dashboards = response.getReturnValue();
                dashboards.sort(function(a,b) {return (a.Title.toLowerCase() > b.Title.toLowerCase()) ? 1 : ((b.Title.toLowerCase() > a.Title.toLowerCase()) ? -1 : 0);} );
                component.set(dashboardsObjToPopulate,dashboards);
            } else if (state === "ERROR") {
                console.log("LXC_CSM_PortalReport] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },*/

    getDashboards: function(component){
        var action = component.get("c.getDashboardsForCurrentUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dcs = response.getReturnValue();
                dcs.forEach(dc => {
                    dc.dashboards.sort(function(a,b) {return (a.Title.toLowerCase() > b.Title.toLowerCase()) ? 1 : ((b.Title.toLowerCase() > a.Title.toLowerCase()) ? -1 : 0);} );    
                });
                component.set("v.dcs", dcs);
                console.log(dcs);
            } else if (state === "ERROR") {
                console.log("LXC_CSM_PortalReport] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    getReports: function(component){
        var action = component.get("c.getReportsForCurrentUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rcs = response.getReturnValue();
                rcs.forEach(rc => {
                    rc.reports.sort(function(a,b) {return (a.Title.toLowerCase() > b.Title.toLowerCase()) ? 1 : ((b.Title.toLowerCase() > a.Title.toLowerCase()) ? -1 : 0);} );    
                });
                component.set("v.rcs", rcs);
                console.log(rcs);
            } else if (state === "ERROR") {
                console.log("LXC_CSM_PortalReport] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    getDashboardsAndReportsForCurrentUser: function(component){
        var action = component.get("c.getDashboardsAndReportsForCurrentUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var drs = response.getReturnValue();
                drs.forEach(dr => {
                    dr.reports.sort(function(a,b) {return (a.Name.toLowerCase() > b.Name.toLowerCase()) ? 1 : ((b.Name.toLowerCase() > a.Name.toLowerCase()) ? -1 : 0);} );
                    dr.dashboards.sort(function(a,b) {return (a.Title.toLowerCase() > b.Title.toLowerCase()) ? 1 : ((b.Title.toLowerCase() > a.Title.toLowerCase()) ? -1 : 0);} );    
                });
                component.set("v.drs", drs);
                console.log(drs);
            } else if (state === "ERROR") {
                console.log("LXC_CSM_PortalReport] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

/*
    getReports: function(component,listReportIds,reportsObjToPopulate){
        var reportIds=[];
        reportIds = component.get(listReportIds).split(',');
        var action = component.get("c.getReports");
        action.setParams({
            "reportIds": reportIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var reports = response.getReturnValue();
                reports.sort(function(a,b) {return (a.Name.toLowerCase() > b.Name.toLowerCase()) ? 1 : ((b.Name.toLowerCase() > a.Name.toLowerCase()) ? -1 : 0);} );
                component.set(reportsObjToPopulate,reports);
            } else if (state === "ERROR") {
                console.log("LXC_CSM_PortalReport] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
*/

    getPrivateReports: function(component){

        var action = component.get("c.getPrivateReports");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var reports = response.getReturnValue();
                reports.sort(function(a,b) {return (a.Name.toLowerCase() > b.Name.toLowerCase()) ? 1 : ((b.Name.toLowerCase() > a.Name.toLowerCase()) ? -1 : 0);} );
                component.set("v.privateReports",reports);
            } else if (state === "ERROR") {
                console.log("LXC_CSM_PortalReport] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
})