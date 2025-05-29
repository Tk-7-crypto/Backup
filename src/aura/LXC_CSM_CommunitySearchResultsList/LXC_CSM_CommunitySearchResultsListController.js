({
    init: function (component, event, helper) {
        component.set('v.caseColumns', [
            {
                label: 'Case Number', fieldName: 'fieldUrl', type: 'url',
                typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_blank' }
            },
            { label: 'Subject', fieldName: 'Subject', type: 'text' },
            { label: 'Status', fieldName: 'Status', type: 'text' },
            { label: 'Priority', fieldName: 'Priority', type: 'text' },
            { label: 'Product Name', fieldName: 'ProductName__c', type: 'text' },
            { label: 'SubType 1', fieldName: 'SubType1__c', type: 'text' },
            { label: 'SubType 2', fieldName: 'SubType2__c', type: 'text' },
            { label: 'SubType 3', fieldName: 'SubType3__c', type: 'text' }
        ]);

        component.set('v.articleColumns', [
            {
                label: 'Tile', fieldName: 'fieldUrl', type: 'url',
                typeAttributes: { label: { fieldName: 'Title' }, target: '_blank' }
            },
            { label: 'Article Number', fieldName: 'ArticleNumber', type: 'text' },
            { label: 'Product Name', fieldName: 'ProductName__c', type: 'text' },
            { label: 'SubType 1', fieldName: 'SubType1__c', type: 'text' },
            { label: 'SubType 2', fieldName: 'SubType2__c', type: 'text' },
            { label: 'SubType 3', fieldName: 'SubType3__c', type: 'text' },
            { label: 'Device', fieldName: 'Device__c', type: 'text' },
            { label: 'Published Date', fieldName: 'LastPublishedDate', type: 'date' }
        ]);

        component.set('v.groupColumns', [
            {
                label: 'Question', fieldName: 'fieldUrl', type: 'url',
                typeAttributes: { label: { fieldName: 'Title' }, target: '_blank' }
            },
            { label: 'Forum Thread', fieldName: 'groupName', type: 'text' },
            { label: 'Best Answer', fieldName: 'bestAnswer', type: 'html' }
        ]);

        var jsonResult = sessionStorage.getItem('customSearch--results');
        var searchText = sessionStorage.getItem('search--text');
        var searchForPrd = sessionStorage.getItem('search--prd');
        component.set("v.searchText", searchText);
        component.set("v.searchForPrd", searchForPrd);
        helper.fetchDatas(component, jsonResult);
    },
    handleLoadMore: function (component, event, helper) {
        var obj = event.currentTarget.dataset.obj;
        helper.loadData(component, obj);

    },

    openArticle: function (component, event, helper) {
        var href = event.currentTarget.dataset.href;
        window.open(href, '_blank').focus();
    }
})