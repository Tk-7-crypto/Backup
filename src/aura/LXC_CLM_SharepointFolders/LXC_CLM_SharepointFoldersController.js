({
    init: function (component, event, helper) {
        var foldersCommaSeparated = component.get("v.foldersCommaSeparated");
        if(foldersCommaSeparated) {
            component.set("v.folders", foldersCommaSeparated.split(","));
        }
        helper.fetchData(component, event, helper);
    },

    refreshFileDate : function(component, event, helper) {
        helper.fetchData(component, event, helper);
    },

    folderToggel : function(component, event, helper) {
        var targetElementName = event.target.name;
        if(targetElementName != "close") {
            component.set("v.folderName", targetElementName);
            component.set("v.isModalShown", true);
        } else {
            component.set("v.isModalShown", false);
            $A.get('e.force:refreshView').fire();
            $A.enqueueAction(component.get('c.refreshFileDate'));
        }
    }
})