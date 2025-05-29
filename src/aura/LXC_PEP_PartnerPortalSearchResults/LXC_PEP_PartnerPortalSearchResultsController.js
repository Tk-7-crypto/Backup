({
    init: function (component, event, helper) {
        component.set('v.caseColumns', [
            { label: 'Case Number', fieldName: 'fieldUrl', type: 'url',
            typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_blank' } },
            { label: 'Subject', fieldName: 'Subject', type: 'text' },
            { label: 'Status', fieldName: 'Status', type: 'text' },
            { label: 'Priority', fieldName: 'Priority', type: 'text' },
            { label: 'Product Name', fieldName: 'ProductName__c', type: 'text' },
            { label: 'SubType 1', fieldName: 'SubType1__c', type: 'text' },
            { label: 'SubType 2', fieldName: 'SubType2__c', type: 'text' },
            { label: 'SubType 3', fieldName: 'SubType3__c', type: 'text' }
        ]);

        component.set('v.articleColumns', [
            { label: 'Tile', fieldName: 'fieldUrl', type: 'url',
            typeAttributes: { label: { fieldName: 'Title' }, target: '_blank' } },
            { label: 'Article Number', fieldName: 'ArticleNumber', type: 'text' },
            { label: 'Product Name', fieldName: 'ProductName__c', type: 'text' },
            { label: 'SubType 1', fieldName: 'SubType1__c', type: 'text' },
            { label: 'SubType 2', fieldName: 'SubType2__c', type: 'text' },
            { label: 'SubType 3', fieldName: 'SubType3__c', type: 'text' },
            { label: 'Published Date', fieldName: 'LastPublishedDate', type: 'date' }
        ]);
		component.set('v.filesColumns', [
            { label: 'Title', fieldName: 'fieldUrl', type: 'url',
            typeAttributes: { label: { fieldName: 'Title', target: '_self' }, target: '_self' } },
            { label: 'File Type', fieldName: 'FileType', type: 'text' },
            { label: 'Size (In KB)', fieldName: 'newSize', type: 'text' },
        ]);
        
        var jsonResult = sessionStorage.getItem('customSearch--results');
        var searchText = sessionStorage.getItem('search--text');
        component.set("v.searchText", searchText);
        helper.fetchDatas(component, jsonResult);
       /* if (!$A.util.isUndefinedOrNull(jsonResult)) {
            var results = JSON.parse(jsonResult);
            var articleRecords = [];
            var caseRecords = [];
            console.log('Length : : :: : : :' + Object.keys(results).length);
            if (Object.keys(results).length > 0) {
                results.forEach(result => {
                    if (result.objName === 'Knowledge__kav') {
                        result.sobj.fieldUrl='/partner/s/article/'+result.sobj.UrlName;
                        articleRecords.push(result.sobj);
                    } else if (result.objName === 'Case') {
                        result.sobj.fieldUrl='/partner/s/case/'+result.id;
                        caseRecords.push(result.sobj);
                    }
                });
                component.set("v.caseDatas", caseRecords);
                component.set("v.articleDatas", articleRecords);
                // sessionStorage.removeItem('customSearch--results');
            } else {
                component.set("v.displayAlert", true);
            }
        }*/
    },
    handleLoadMore: function (component, event, helper) {
        var obj = event.currentTarget.dataset.obj;
        helper.loadData(component, obj);
    },
            handleButtonClick : function (component, event, helper) {
        var obj = event.currentTarget.name;
            console.log('Name::::', obj);
            let item = document.querySelector('.forceContentFileCard');//document.getElementsByName(obj);
            console.log('Item:::', item);
            if(item)
            {
            console.log(item.innerHTML);
            console.log('childNodes:000::', item.children.length);
            item.children[0].click();
            }
    },
            
})
