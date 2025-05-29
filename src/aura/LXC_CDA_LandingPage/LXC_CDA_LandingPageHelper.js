({
    getDateFormatted: function(component,dateStr,datePattern){
        var parsedDate = $A.localizationService.formatDate(dateStr, datePattern);
        return parsedDate;
    },
    getCDARequestList: function(component, pNum, currentPCount, sortField, sortDirection, searchMap, isNegotiatorTab) {
        console.log('In LXC_CDA_LandingPage helper : getCDARequestList method called');
        //console.log('getCDARequestList searchFieldsMap status : ' + component.get("v.searchFieldsMap").get("Status__c"));
        this.showSpinner(component);
        var action = component.get('c.getCDARequests');     
        
        action.setParams({
            "pageNumber" : pNum.toString(),
            "currnetPagesCount" : currentPCount.toString(),
            "sortField" : sortField,
            "sortDirection" : sortDirection,
            "searchMap" : searchMap,
            "isNegotiatorTab" : isNegotiatorTab
        });
        
    	action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                console.log('getCDARequests callback method: ');
                var requests = response.getReturnValue();
                var datePattern = 'MM/DD/YY';
                for(var i=0;i<requests.length;i++){
                    if(requests[i].CDA_Effective_Date__c != null){
                    	requests[i].CDA_Effective_Date__c = this.getDateFormatted(component,requests[i].CDA_Effective_Date__c.toString(),datePattern);
                    }
                    requests[i].LastModifiedDate = this.getDateFormatted(component,requests[i].LastModifiedDate.toString().substring(0,10),datePattern);
                }
                component.set('v.cdaRequests', requests);
                this.hideSpinner(component);
            }
     	});
        $A.enqueueAction(action);
	},
    
    showSpinner: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    navigateToRequestEditScreen: function(component, recordId) {
        console.log('In LXC_CDA_LandingPage js helper : navigateToRequestEditScreen: ');
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LXC_CDA_RequestEditScreen",
            componentAttributes: {
                "recordId" : recordId
            }
        });
        evt.fire();
    },
    
    cancelCDARequest: function(component, recordId) {
        console.log('In LXC_CDA_LandingPage js helper : cancelCDARequest: start');
        this.showSpinner(component);
        var action = component.get('c.cancelRequest');
        action.setParams({
            "cdaRequestId" : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                console.log('cancelRequest callback method: ');
                this.hideSpinner(component);
                $A.get('e.force:refreshView').fire();
            }
     	});
        $A.enqueueAction(action);
        console.log('In LXC_CDA_LandingPage js helper : cancelCDARequest: end');
    }, 
    
    openPopup: function(component, event, popupType) {
        console.log('LXC_CDA_LandingPage: js helper: openPopup start');
        component.set("v.isPopupOpen", true);
        component.set("v.popupType", popupType);
        var tempMap = new Map();
        
        if(popupType == 'cancelRequestPopup') {
            tempMap['button1'] = 'Yes';
            tempMap['button2'] = 'No';
        } 
        
        component.set("v.popupButtonMap", tempMap);
        console.log('LXC_CDA_LandingPage: js helper: openPopup End');        
    },
})