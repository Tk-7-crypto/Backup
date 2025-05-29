({
    init: function(component){
        component.set("v.currentFolder",{});
        component.set("v.navigationFolders",[]);
        component.set("v.files",[]);
        var type = component.get("v.type");
        switch(type){
            case 'Specific root folder':
                this.getFolderByTopicId(component);
                break;
            default:
                console.log('Sorry, we are out of ' + type + '.');
        }
    },

    getFolders: function(component){
        component.set("v.isLoading", true);
        var action = component.get("c.getFolders");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.folders",response.getReturnValue());
                console.log('Folders : '+response.getReturnValue());
            }else{
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    getFolderByTopicId: function(component){
        component.set("v.isLoading", true);
        var action = component.get("c.getFolderByTopicId");
        let folderToVisible = component.get('v.nameFolderVisible4All');
        console.log('Get window location : '+window.location.href);
        var currentURL=window.location.href;
        let hasParams = currentURL.includes('=') ? true : false;
        var categoryName=hasParams ? currentURL.split('=')[1].replace(/\+/g,' ').replace(/%20/g,' ') : undefined;
        console.log('Get Category Name : '+categoryName);
        var preview = component.get("v.previewOn");
        if(!preview || !categoryName)
        {
            console.log('inside preview');
            categoryName = !categoryName ? folderToVisible : categoryName;
            action.setParams({
                "categoryName": categoryName
            });
        }
        else{
            action.setParams({
                "categoryName":  'Sales Collateral for '+categoryName
            });
        }
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentFolder",response.getReturnValue()[0])
                console.log('Current Folder : ',response.getReturnValue());
                component.set("v.isLoading", false);
                var action2 = component.get("c.getFolders");
                action2.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var folders = response.getReturnValue();
                        console.log('These are the folders : ',folders);
                        var test = folders.filter(function(folder){ 
                            if (folder.Name === component.get("v.currentFolder").Name || component.get("v.currentFolder").Name === component.get("v.nameFolderVisible4All")) 
                                return true;
                            else 
                                return false;
                        });
                        if(test[0] != undefined){
                            var navigationFolders = component.get("v.navigationFolders");
                            navigationFolders.push(component.get("v.currentFolder"));
                            component.set("v.navigationFolders", navigationFolders)
                            this.getFoldersByParentId(component,component.get("v.currentFolder").Id);
                        }else {
                            console.log("Forbidden");
                            component.set("v.folders",[]);
                        }
                    }else{
                        console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                    }
                    component.set("v.isLoading", false);
                });
                $A.enqueueAction(action2);
            }else{
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    getFoldersByParentId: function(component, parentId){
        component.set("v.isLoading", true);
        var action = component.get("c.getFoldersByParentId");
        action.setParams({
            "parentContentFolderId":  parentId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var folders = response.getReturnValue();
                folders.sort(function(a,b) {return (a.LastModifiedDate < b.LastModifiedDate) ? 1 : ((b.LastModifiedDate < a.LastModifiedDate) ? -1 : 0);} ); 
                component.set("v.folders",folders);
                var action2 = component.get("c.getFolderMemberByParentId");
                action2.setParams({
                    "parentContentFolderId":  parentId
                });
                action2.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var files = response.getReturnValue();
                        console.log('Files::::', files);
                        let todayDate = new Date();
        				let lastDate = todayDate.setDate(todayDate.getDate() -60);
                        files.forEach(item=>{
                            let thisDate = new Date(item.ChildRecord.LastModifiedDate);
                            console.log('thisDate:::', thisDate);
                            item.ChildRecord.show = true;
                            if(thisDate > lastDate){
                            item.ChildRecord.showNewTag = true;
                        }else{
                                      item.ChildRecord.showNewTag = false;
                                      }
                                      })
                        files.sort(function(a,b) {return (a.ChildRecord.LastModifiedDate < b.ChildRecord.LastModifiedDate) ? 1 : ((b.ChildRecord.LastModifiedDate < a.ChildRecord.LastModifiedDate) ? -1 : 0);} );
                        //component.set("v.files",files);
                        let newFileArray = [];
                        let newSubArray = [];
                        let counter = 0;
                        let allFileCount = files.length;
                        console.log('ALL FILE COUNT:::', allFileCount);
                        let currentFileCount = 0;
                        files.forEach(item =>{
                            currentFileCount++;
                            if(counter <2){
                            newSubArray.push(item);
                            counter++;
                        }else{newSubArray.push(item);
                            counter++;
                                 newFileArray.push(JSON.parse(JSON.stringify(newSubArray)));
                        newSubArray = [];
                        counter=0;
                            
                                      }
                            if(currentFileCount == allFileCount && newSubArray.length){
                            newFileArray.push(JSON.parse(JSON.stringify(newSubArray)));
                        newSubArray = [];
                        counter=0;
                        }
                        });
                            console.log('ALL FILE COUNT2:::', newFileArray);
                            component.set("v.files",newFileArray[0]);
                            for(let i=1; i<newFileArray.length; i++){
                            setTimeout(()=>{
                            component.set("v.isLoading", false);
                            let currentList = component.get('v.files');
                            currentList = [...currentList, ...newFileArray[i]];
                            console.log('new Items:::', JSON.parse(JSON.stringify(currentList)));
                            component.set("v.files",currentList);
                        },2500);
                        }
                        //Lazy Loading code End
                    }else{
                        console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                    }
                    component.set("v.isLoading", false);
                });
                $A.enqueueAction(action2);


            }else{
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    }
})
