({
	loadData: function (component, object) {
        component.set("v.isLoading", true);
        var limit = component.get("v.limit");
        switch (object) {
            case 'Knowledge__kav':
                var offset = component.get("v.articleOffSet");
                break;
            case 'Case':
                var offset = component.get("v.caseOffSet");
                break;
            case 'ContentDocument':
                var offset = component.get("v.filesOffSet");
                break;
        }
        var searchText = component.get("v.searchText");
        var action = component.get("c.searchForIds");
        action.setParams({
            searchText: searchText,
            searchObject: object,
            rowLimit: limit,
            rowOffset: offset
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('Inside search calls');
            if (state === "SUCCESS") {
                var datas = response.getReturnValue();
                console.log('Inside search success');
                switch (object) {
                    case 'Knowledge__kav':
                        if ((datas.filter(data => (data.objName === "Knowledge__kav")).length > 0)) {
                            var jsonResult = JSON.stringify(datas);
                            offset = offset + limit;
                            component.set("v.articleOffSet", offset);
                            this.fetchDatas(component, jsonResult);
                        } else {
                            component.set("v.articleLoadMore", false);
                        }
                        break;
                    case 'Case':
                        if ((datas.filter(data => (data.objName === "Case")).length > 0)) {
                            var jsonResult = JSON.stringify(datas);
                            offset = offset + limit;
                            component.set("v.caseOffSet", offset);
                            this.fetchDatas(component, jsonResult);
                        } else {
                            component.set("v.caseLoadMore", false);
                        }
                        break;
                    case 'ContentDocument':
                        if ((datas.filter(data => (data.objName === "ContentDocument")).length > 0)) {
                            var jsonResult = JSON.stringify(datas);
                            offset = offset + limit;
                            component.set("v.filesOffSet", offset);
                            this.fetchDatas(component, jsonResult);
                        } else {
                            component.set("v.filesLoadMore", false);
                        }
                        break;
                }
            } else if (state === "ERROR") {
                console.log("ERROR: " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    fetchDatas: function (component, jsonResult) {
        if (!$A.util.isUndefinedOrNull(jsonResult)) {
            var results = JSON.parse(jsonResult);
            var articleRecords = [];
            var caseRecords = [];
            var fileRecords = [];
            console.log(results);
            if (Object.keys(results).length > 0) {
                results.forEach(result => {
                    if (result.objName === 'Knowledge__kav') {
                        result.sobj.fieldUrl='/partner/s/kb?u='+result.sobj.UrlName;
                        articleRecords.push(result.sobj);
                    } else if (result.objName === 'Case') {
                        result.sobj.fieldUrl='/partner/s/case/'+result.id;
                        caseRecords.push(result.sobj);
                    }else if (result.objName === 'ContentDocument') {
                        result.sobj.fieldUrl='../sfc/servlet.shepherd/document/download/' + result.id;
                        result.sobj.fieldNewUrl='../sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + result.id;
                        result.sobj.recId = result.id;
                        result.sobj.newSize = (result.sobj.ContentSize / 1024).toFixed(2);
                        fileRecords.push(result.sobj); 
                    ;}
                });

                var currentCaseData = component.get("v.caseDatas");
                var currentArticleData = component.get("v.articleDatas");
            	var currentFileData = component.get("v.fileDatas");
                if (currentCaseData != null) {
                    caseRecords = currentCaseData.concat(caseRecords);
                }
                if (currentArticleData != null) {
                    articleRecords = currentArticleData.concat(articleRecords);
                }
            	if (currentFileData != null) {
                    fileRecords = currentFileData.concat(fileRecords);
                }
                component.set("v.caseDatas", caseRecords);
                component.set("v.articleDatas", articleRecords);
                //component.set("v.fileDatas", fileRecords);
                let newFileArray = [];
                        let newSubArray = [];
                        let counter = 0;
                        let allFileCount = fileRecords.length;
                        console.log('ALL FILE COUNT:::', allFileCount);
                        let currentFileCount = 0;
                        fileRecords.forEach(item =>{
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
                            component.set("v.fileDatas",newFileArray[0]);
                            for(let i=1; i<newFileArray.length; i++){
                            setTimeout(()=>{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Please Wait.",
                                "message": " Your search is loading."
                            });
                            toastEvent.fire();
                            component.set("v.isLoading", false);
                            let currentList = component.get('v.fileDatas');
                            currentList = [...currentList, ...newFileArray[i]];
                            console.log('new Items:::', JSON.parse(JSON.stringify(currentList)));
                            component.set("v.fileDatas",currentList);
                        },2500);
                        }
            } else {
                component.set("v.displayAlert", true);
            }
        }
    }
})
