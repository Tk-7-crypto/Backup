({
	doInit: function (component, event, helper) {
		console.log('In LXC_CDA_LookupReport js controller: doInit method called');
		var searchFieldsMap = new Map();
		searchFieldsMap["Status__c"] = "Contract Executed";
		component.set("v.searchFieldsMap", searchFieldsMap);
		var searchEvt = $A.get("e.c:LXE_CDA_LandingPageSearchEvt");

		searchEvt.setParams({
			"searchMap": searchFieldsMap
		});
                
        //searchEvt.fire();
	},

	recordCounterChange: function (component, event, helper) {
		console.log('In controller: recordCounterChange method called');
		var currentPagesCount = event.getParam("currentPagesCount");
		component.set("v.pageNumber", '1');
		component.set("v.currentPagesCount", currentPagesCount);
		helper.getCDARequestList(component, '1', currentPagesCount, component.get('v.sortField'), component.get('v.sortDirection'), component.get("v.searchFieldsMap"), false, false);
	},

	pageChange: function (component, event, helper) {
		console.log('In LXC_CDA_LookupReport js controller: pageChange method (LXE_CDA_PaginationPageChangeEvt event handler) called');
		var pageNumber = event.getParam("pageNumber");
		var currentPagesCount = event.getParam("currentPagesCount");

		component.set("v.pageNumber", pageNumber);
		component.set("v.currentPagesCount", currentPagesCount);
		console.log('pageChange searchFieldsMap status : ' + JSON.stringify(component.get("v.searchFieldsMap")));
		helper.getCDARequestList(component, pageNumber, currentPagesCount, component.get('v.sortField'), component.get('v.sortDirection'), component.get("v.searchFieldsMap"), false, false);
	},

	sortList: function (component, event, helper) {
		console.log('In controller: sortList method called');
		console.log('in js controller: sortList: button value: ' + event.target.value);
		var sortField = event.target.value;
		var sortDirection = (component.get("v.sortDirection") == 'ASC') ? 'DESC' : 'ASC';
		console.log('In component: sortField: ' + sortField);
		console.log('In component: sortDirection: ' + sortDirection);
		component.set("v.sortField", sortField);
		component.set("v.sortDirection", sortDirection);
		var sortEvent = $A.get("e.c:LXE_CDA_PaginationPageChangeEvt");

		sortEvent.setParams({
			"pageNumber": '1',
			"currentPagesCount": component.get("v.currentPagesCount")
		});

		sortEvent.fire();
		//helper.getCDARequestList(component, '1', component.get("v.currentPagesCount"), sortField, sortDirection);       
	},

	openSection: function (component, event, helper) {
		console.log('In controller: openSection method called');
		var searchSection = component.find("searchSection");
		$A.util.toggleClass(searchSection, "slds-is-open");
		var searchSectionIcon = component.find("searchSectionIcon");
		$A.util.toggleClass(searchSectionIcon, "slds-m-bottom_medium");
	},

	searchRequests: function (component, event, helper) {        
        console.log('In LXC_CDA_LookupReport controller: searchRequests handler called');
		console.log('searchFieldsMap : ' + component.get("v.searchFieldsMap"));
		var currentTab = "CDA_Lookup_Report";
        if(window.location.pathname.split('/').length > 0) {
            currentTab = window.location.pathname.split('/')[window.location.pathname.split('/').length - 1];
        }
        if(currentTab != "CDA_Lookup_Report") {
            return false;
        }
		var searchMap = event.getParam("searchMap");
        if(searchMap["Recipient_Account__r.Name"] == null || searchMap["Recipient_Account__r.Name"].trim() == '') {
			alert($A.get("$Label.c.CDA_Recipient_Legal_Entity_Name_Search_field_can_t_be_empty"));
            return false;
        }
        if(searchMap["Recipient_Account__r.Name"].trim().length < 4) {
			alert($A.get("$Label.c.CDA_Please_enter_atleast_4_characters_to_search"));
            return false;
        }
        if(searchMap["Recipient_Account__r.Name"].indexOf('%') != -1) {
            searchMap["Recipient_Account__r.Name"] = searchMap["Recipient_Account__r.Name"].replace('%', '\\%');
        }
        
        var cmpTarget = component.find('lookupPagId');
        $A.util.removeClass(cmpTarget, 'lookupReportPagination');
        
        component.set("v.searchFieldsMap", searchMap);
		helper.getCDARequestList(component,
			'1',
			component.get('v.currentPagesCount'),
			component.get('v.sortField'),
			component.get('v.sortDirection'),
			searchMap,
			false, false);
	},

	navigateToRecord: function (component, event, helper) {
		console.log('In LXC_CDA_LookupReport controller: navigateToRecord handler called');
		// var navEvt = $A.get("e.force:navigateToSObject");
		// navEvt.setParams({
		// 	"recordId": event.target.id
		// });
		// navEvt.fire();
		var recordId = event.target.id;	//component.get('v.recordId');
		window.open('/' + recordId, '_blank');
	},

	reInit: function (component, event, helper) {
		console.log('ReInit Called Start');
		$A.get('e.force:refreshView').fire();
		console.log('ReInit Called Start');
	},

	// ## function call on Click on the "Download As CSV" Button. 
	downloadCsv: function (component, event, helper) {
		console.log('inside downloadCsv');
		helper.getCDARequestList(component, 0, 0, component.get('v.sortField'), component.get('v.sortDirection'), component.get("v.searchFieldsMap"), false, true);
	}, 
})