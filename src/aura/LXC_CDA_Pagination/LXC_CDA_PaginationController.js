({
    doInit: function(component, event, helper) {
        console.log('In LXC_CDA_Pagination js controller: doInit method called');
	    var rCount = '';
        console.log('paginationController:::' + component.get("v.isNegotiatorTab"));
        var currentTab = "CDA_Request";
        if(window.location.pathname.split('/').length > 0) {
            currentTab = window.location.pathname.split('/')[window.location.pathname.split('/').length - 1];
        }
        console.log('paginationControllerCurrTab:::' + currentTab);
        component.set("v.isNegotiatorTab", currentTab == "CDA_Negotiator_Support");
		helper.getPageCountAndTotal(component,rCount,component.get("v.isNegotiatorTab"));
	},
    
    openthePage: function(component, event, helper) {
        console.log('In LXC_CDA_Pagination js controller: openthePage method called');
        
        var btnClicked = event.getSource(); 
        var pageNumber = btnClicked.get("v.label");        
        var currentPagesCount = component.get("v.currentPagesCount");
        var totalPages = component.get("v.pageInfo.totalPages");
        var totalRecords = component.get("v.pageInfo.totalRecords");
        
        console.log('pageNumber' + pageNumber);
        console.log('currentPagesCount ' + currentPagesCount);
        console.log('totalPages ' + totalPages);
        
        var pageChangeEvent = $A.get("e.c:LXE_CDA_PaginationPageChangeEvt");

        pageChangeEvent.setParams({
            "pageNumber": pageNumber,
            "currentPagesCount": component.get("v.currentPagesCount")
        });
		
        console.log('In LXC_CDA_Pagination js controller: LXE_CDA_PaginationPageChangeEvt event fired');
        pageChangeEvent.fire();
        
        //helper.resetCounters(component, pageNumber, currentPagesCount, totalPages, totalRecords);
    },
    
    pageChange: function(component, event, helper) {    
        console.log('In LXC_CDA_Pagination js controller: pageChange method (LXE_CDA_PaginationPageChangeEvt event handler) called');
        
        var pageNumber = event.getParam("pageNumber");
        var currentPagesCount = event.getParam("currentPagesCount");
        var totalPages = component.get("v.pageInfo.totalPages");
        var totalRecords = component.get("v.pageInfo.totalRecords");
        helper.resetCounters(component, pageNumber, currentPagesCount, totalPages, totalRecords);

    },
    
    // go to Previous or Next page
    goPreNextPage : function (component, event, helper) {
        console.log('In LXC_CDA_Pagination js controller: goPreNextPage method called');
        
        var totalPages = component.get("v.pageInfo.totalPages");
        var pageNumber = component.get("v.pageInfo.currentPageNumber");
        var totalRecords = component.get("v.pageInfo.totalRecords");
        var currentPagesCount = 10;
        
        console.log('pageNumber' + pageNumber);
        console.log('currentPagesCount ' + currentPagesCount);
        console.log('totalPages ' + totalPages);
        
        var btnClicked = event.getSource(); // the button
        var btnAlternativeText = btnClicked.get("v.alternativeText");
        
        console.log(btnAlternativeText + ' btn clicked.');
        
        var pageChangeEvent = $A.get("e.c:LXE_CDA_PaginationPageChangeEvt");

        if(btnAlternativeText == 'Left') {
            pageChangeEvent.setParams({
                "pageNumber": (parseInt(pageNumber)-1).toString(),
                "currentPagesCount": currentPagesCount.toString()
            });
            //helper.resetCounters(component, (parseInt(pageNumber)-1).toString(), currentPagesCount.toString(), totalPages, totalRecords);
    	} else {
            pageChangeEvent.setParams({
                "pageNumber": (parseInt(pageNumber)+1).toString(),
                "currentPagesCount": currentPagesCount.toString()
            });
        	//helper.resetCounters(component, (parseInt(pageNumber)+1).toString(), currentPagesCount.toString(), totalPages, totalRecords);
		} 
        console.log('In LXC_CDA_Pagination js controller: LXE_CDA_PaginationPageChangeEvt event fired');
        pageChangeEvent.fire();
	},
    
    changeRecordNumber : function(component, event, helper) {
        var currentPagesCount  = component.find("selectItem").get("v.value");
        var isNegotiatorTab  = component.get("v.isNegotiatorTab");
        component.set("v.currentPagesCount", currentPagesCount);
        helper.getPageCountAndTotal(component, currentPagesCount, isNegotiatorTab, component.get("v.searchFieldsMap"));
        
        var pageTotalChangeEvt = $A.get("e.c:LXE_CDA_PaginationPageTotalChange");
        pageTotalChangeEvt.setParams({ "currentPagesCount": currentPagesCount});
        pageTotalChangeEvt.fire();
	},
    
    searchRequests : function(component, event, helper) {
        console.log('In LXC_CDA_Pagination controller: searchRequests handler called');
        var searchMap = event.getParam("searchMap");
        component.set("v.searchFieldsMap", searchMap);
        helper.getPageCountAndTotal(component, 
                                 	component.get('v.currentPagesCount'),
                                    component.get("v.isNegotiatorTab"),
                                 	searchMap);
        //console.log('searchFieldsMap status : ' + testMp.get("Status__c"));
        /*var searchEvent = $A.get("e.c:LXE_CDA_PaginationPageChangeEvt");

        searchEvent.setParams({
            "pageNumber": '1',
            "currentPagesCount": component.get("v.currentPagesCount"), 
            "searchMap" : component.get("v.searchFieldsMap")
        });

        searchEvent.fire();*/
    }
})