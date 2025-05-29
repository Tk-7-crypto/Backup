({
    doInit: function(component, event, helper) {
        helper.init(component);
        component.set("v.itemType","File");
    },
    
    folderClick: function(component, event, helper) {
        component.set("v.currentFolder",component.get("v.folders")[event.currentTarget.id]);
        helper.getFoldersByParentId(component,component.get("v.currentFolder").Id);
        var navigationFolders = component.get("v.navigationFolders");
        navigationFolders.push(component.get("v.folders")[event.currentTarget.id]);
        component.set("v.navigationFolders", navigationFolders);
    },
    
    //View Stat Record create method//
    
    prepareLogRecord: function(component, event, helper){
        var fileDetails = component.get('v.files')[event.currentTarget.id];
        var convertedData = JSON.parse(JSON.stringify(fileDetails));
        console.log('File Details: ', JSON.stringify(fileDetails));
        //prepareLogRecord
        try{
            console.log('fileDetails: ', fileDetails);
            console.log(' convertedData.ChildRecord.Id: ',  convertedData.ChildRecord.Id);
            console.log(' convertedData.ChildRecord.Title: ',  convertedData.ChildRecord.Title);
            var action = component.get("c.logViewStat");
        action.setParams({
            "ContentVersionId":  convertedData.ChildRecord.Id,
            "FileTitle":  convertedData.ChildRecord.Title
        });
        action.setCallback(this, function(response){
            console.log('Got Response');
            var state = response.getState();
            console.log('Response:::',response );
            if (state === "SUCCESS") {
                console.log('Record Created successfully.');
            }else{
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
            //component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
            console.log('End of action: ');
        }catch(e){
            console.log('Error while preparing records::', e);
        }
        
    },
    filterPRMArticles: function(component, event, helper){
        var isFilteredByNew = component.get("v.isFilteredByNew");
        try{
            let files = JSON.parse(JSON.stringify(component.get("v.files")));
            let todayDate = new Date();
            let lastDate = todayDate.setDate(todayDate.getDate() -60);
            let currentValue = event.getSource().get("v.checked");
            files.forEach(item=>{
                if(currentValue){
                let thisDate = new Date(item.ChildRecord.LastModifiedDate);
                if(thisDate > lastDate){
                item.ChildRecord.showNewTag = true;
                item.ChildRecord.show = true;
            }else{
                          item.ChildRecord.showNewTag = false;
                          item.ChildRecord.show = false;
                          }
                          }else{
                          item.ChildRecord.showNewTag = true;
                          item.ChildRecord.show = true;
                          }            
                          });
            component.set("v.files", files);
        }catch(Ex){
        }       
    }
})
