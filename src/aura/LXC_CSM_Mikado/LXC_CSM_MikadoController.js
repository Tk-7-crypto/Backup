({
    doInit: function(component, event, helper) {
        helper.getMikadoFolders(component);
    },
    filteredFolders: function(component, event, helper) {
        component.set("v.isLoading", true);
        var filteredString=event.getSource().get("v.value");
        var filteredFolders=[];
        var folders=component.get("v.folders");
        if(filteredString !=""){
            for(var i=0;i < folders.length; i++){
                if (folders[i].Name.toUpperCase().indexOf(filteredString.toUpperCase()) > -1){
                    filteredFolders.push(folders[i]);
                }
            }
            component.set("v.filteredFolders",filteredFolders);
        }else{
            component.set("v.filteredFolders",folders);
        }
        component.set("v.isLoading", false);
    },

    folderClick: function(component, event, helper) {
        var ctarget = event.currentTarget;
        component.set("v.csmFolderId", ctarget.dataset.value);
        component.set("v.subTabLabel", ctarget.dataset.title);
        component.find("cMikadoFiles").getMikadoFiles();  
    },
})