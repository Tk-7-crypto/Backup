({
	doInit : function(component, event, helper) {
        var url = "https://quintiles.sharepoint.com/sites/IQVIA_CRM/SitePages/Home.aspx";
        window.open(url,'_blank');
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
    }
})