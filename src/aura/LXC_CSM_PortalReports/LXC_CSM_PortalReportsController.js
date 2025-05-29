({
    doInit: function(component, event, helper) {
      /*  helper.getUserContact(component);
        if (component.get("v.listTechnoReportIds")!= undefined){
            helper.getReports(component,"v.listTechnoReportIds","v.technoReports");
        }
        if (component.get("v.listDataReportIds")!= undefined){
            helper.getReports(component,"v.listDataReportIds","v.dataReports");
        }
        if (component.get("v.listIQVIAEmployeesDashboardIds")!= undefined){
            helper.getDashboards(component,"v.listIQVIAEmployeesDashboardIds","v.IQVIAEmployeesDashboards");
        }
        if (component.get("v.listTechnoDashboardIds")!= undefined){
            helper.getDashboards(component,"v.listTechnoDashboardIds","v.technoDashboards");
        }
        if (component.get("v.listDataDashboardIds")!= undefined){
            helper.getDashboards(component,"v.listDataDashboardIds","v.dataDashboards");
        }*/
        helper.getDashboardsAndReportsForCurrentUser(component);
    //    helper.getDashboards(component);
    //    helper.getReports(component);
          helper.getPrivateReports(component);
    },
})