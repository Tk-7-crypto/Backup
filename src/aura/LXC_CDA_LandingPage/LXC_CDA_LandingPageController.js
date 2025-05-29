({
    doInit: function(component, event, helper) {
        console.log('In LXC_CDA_LandingPage js controller: doInit method called');
        
        var isNegotiatorAction = component.get('c.isNegotiator');
        var getCDATrainingDocURL = component.get('c.getCDASettingValues');
        getCDATrainingDocURL.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.cdaSetting", response.getReturnValue());
                component.set("v.cdaTrainingDocURL", response.getReturnValue().CDA_Training_Doc_URL__c);
                console.log('response.getReturnValue() ----------> ' + response.getReturnValue());
            }
        });
        $A.enqueueAction(getCDATrainingDocURL);
        
        var currentTab = "CDA_Request";
        if(window.location.pathname.split('/').length > 0) {
            currentTab = window.location.pathname.split('/')[window.location.pathname.split('/').length - 1];
        }
		component.set("v.isNegotiatorTab", currentTab == "CDA_Negotiator_Support");
        console.log(currentTab);
        
        isNegotiatorAction.setCallback(this, function(isNegotiatorResponse) {
            var state = isNegotiatorResponse.getState();
            if(component.isValid() && state === "SUCCESS") {
                console.log('isNegotiator callback method: ');
                console.log('isNegotiator: ' + isNegotiatorResponse.getReturnValue());
                helper.getCDARequestList(component, component.get("v.pageNumber"), component.get("v.currentPagesCount"), component.get('v.sortField'), component.get('v.sortDirection'), component.get("v.searchFieldsMap"), component.get("v.isNegotiatorTab"));
            }
        });
        $A.enqueueAction(isNegotiatorAction);
    },
	toggleChatbot : function (component, event, helper) {
        console.log('In LXC_CDA_Pagination js controller: toggleChatbot method called');
        
        var toggleChatbot = component.get("v.isOpenChatbot");
        component.set("v.isOpenChatbot", !toggleChatbot);
        
	},
    
    loadIframe : function (component, event, helper) {
        console.log('In LXC_CDA_Pagination js controller: loadIframe method called');
        var cdaSettingValue = component.get("v.cdaSetting");
        window.addEventListener("message", function(e) {
            console.log("Event Triggered : e.data.type : " + e.data.type + " : e.data.authenticated : " + e.data.authenticated);
            // redirect to SSO login if the web client logs in but is logged in as a guest user(unauthenticated)
            if(e.data.type==="SESSION_CREATED" && e.data.authenticated === false) {
                window.location.href = cdaSettingValue.IQVIASupportChatLoginURL__c+cdaSettingValue.LandingPageURL__c;
                console.log('In 1');
            }

            // redirect to SSO login if the ServiceNow platform logs out from underneath the web client
            if(e.data.type==="SESSION_LOGGED_OUT") {
                window.location.href = cdaSettingValue.IQVIASupportChatLoginURL__c+cdaSettingValue.LandingPageURL__c; 
                console.log('In 2');
            }
        });
	},
    
    createNewRequest: function(component, event, helper) {
        console.log('In controller: createNewRequest method called');
        helper.navigateToRequestEditScreen(component, null);
    },
    
    recordCounterChange : function(component, event, helper) {
        console.log('In controller: recordCounterChange method called');
        var currentPagesCount = event.getParam("currentPagesCount");
        component.set("v.pageNumber", '1');
        component.set("v.currentPagesCount", currentPagesCount);
        helper.getCDARequestList(component, '1', currentPagesCount, component.get('v.sortField'), component.get('v.sortDirection'), component.get("v.searchFieldsMap"), component.get("v.isNegotiatorTab"));
    }, 
    
    pageChange: function(component, event, helper) {
        console.log('In LXC_CDA_LandingPage js controller: pageChange method (LXE_CDA_PaginationPageChangeEvt event handler) called');
        var pageNumber = event.getParam("pageNumber");
        var currentPagesCount = event.getParam("currentPagesCount");

        component.set("v.pageNumber", pageNumber);
        component.set("v.currentPagesCount", currentPagesCount);
		console.log('pageChange searchFieldsMap status : ' + JSON.stringify(component.get("v.searchFieldsMap")));
        helper.getCDARequestList(component, pageNumber, currentPagesCount, component.get('v.sortField'), component.get('v.sortDirection'), component.get("v.searchFieldsMap"), component.get("v.isNegotiatorTab"));
    },
    
    sortList: function(component, event, helper) {
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
    
    openSection: function(component, event, helper) {
        console.log('In controller: openSection method called');
        var searchSection = component.find("searchSection");
        $A.util.toggleClass(searchSection, "slds-is-open");
        var searchSectionIcon = component.find("searchSectionIcon");
        $A.util.toggleClass(searchSectionIcon, "slds-m-bottom_medium");
    }, 
    
    searchRequests : function(component, event, helper) {
        console.log('In LXC_CDA_LandingPage controller: searchRequests handler called');
        //console.log('searchFieldsMap : ' + component.get("v.searchFieldsMap"));
        var searchMap = event.getParam("searchMap");
        component.set("v.searchFieldsMap", searchMap);
        helper.getCDARequestList(component, 
                                 '1', 
                                 component.get('v.currentPagesCount'), 
                                 component.get('v.sortField'), 
                                 component.get('v.sortDirection'), 
                                 searchMap,
                                 component.get('v.isNegotiatorTab'));
        //console.log('searchFieldsMap status : ' + testMp.get("Status__c"));
        /*var searchEvent = $A.get("e.c:LXE_CDA_PaginationPageChangeEvt");

        searchEvent.setParams({
            "pageNumber": '1',
            "currentPagesCount": component.get("v.currentPagesCount"), 
            "searchMap" : component.get("v.searchFieldsMap")
        });

        searchEvent.fire();*/
    }, 
    
    navigateToRecord : function(component, event, helper) {
        console.log('In LXC_CDA_LandingPage controller: navigateToRecord handler called');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId" : event.target.id
        });
        navEvt.fire();
    }, 
    
    navigateToRequestEditScreen: function(component, event, helper) {
        console.log('In LXC_CDA_LandingPage JS controller: navigateToRequestEditScreen');
        
        helper.navigateToRequestEditScreen(component, event.target.id);
    },
    
    cancelCDARequest: function(component, event, helper) {
        console.log('In LXC_CDA_LandingPage JS controller: cancelCDARequest start');
        component.set("v.CancelledRequestId", event.target.id);
        
        helper.openPopup(component, event, "cancelRequestPopup");
        //helper.cancelCDARequest(component, event.target.id);
        //console.log('event.target.id: ' + event.target.id);
        console.log('In LXC_CDA_LandingPage JS controller: cancelCDARequest End');
    },
    
    reInit: function(component, event, helper) {
        console.log('ReInit Called Start');
        $A.get('e.force:refreshView').fire();
        console.log('ReInit Called Start');
    }, 
    
    popupActionButton2: function(component, event, helper) {
        console.log('LXC_CDA_LandingPage: js controller: popupActionButton2 start');
        var popupType = component.get("v.popupType");
        console.log('popupType : ' + popupType);
        
        if(popupType == 'cancelRequestPopup') {
            component.set("v.isPopupOpen", false);
        }
        
        console.log("popupType: " + component.get("v.popupType"));
        console.log('LXC_CDA_LandingPage: js controller: popupActionButton2 End');
    },
    
    popupActionButton1: function(component, event, helper) {
        console.log('LXC_CDA_LandingPage: js controller: popupActionButton1 start');
        var popupType = component.get("v.popupType");
        
        console.log('popupType : ' + popupType);
        
        if(popupType == 'cancelRequestPopup') {
            helper.cancelCDARequest(component, component.get("v.CancelledRequestId"));
            component.set("v.isPopupOpen", false);
        } 
        
        console.log('LXC_CDA_LandingPage: js controller: popupActionButton1 end');
    },
})