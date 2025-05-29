({
    getAnnouncementsForCurrentUser : function(component) {
        var action = component.get("c.getAnnouncementsForCurrentUser");
        action.setParams({
            "includeExpired": component.get("v.includeExpired")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var announcements = response.getReturnValue();
                if (announcements) {
                    announcements.sort((a, b) => new Date(b.CreatedDate) - new Date(a.CreatedDate));
                    component.set("v.announcements", announcements);
                    announcements.forEach(announcement => {
                        if( new Date(announcement.Expiry_Date__c) >=  new Date()){
                            announcement.isExpired = false;
                        } else {
                            announcement.isExpired = true;
                        }
                    });
                }
            } else if (state === "ERROR") {
                console.log("ERROR: " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    
    getUserSessionId : function(component){
        var action = component.get("c.getUserSessionId");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var sessionId = response.getReturnValue();
                console.log('UserSessionId =:::', sessionId);
            } else {
                console.log("getSessionIDFail: " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    
    getAnnouncementsForCurrentPRMUser : function(component) {
        var action = component.get("c.getAnnouncementsForCurrentPRMUser");
        action.setParams({
            "homePage": component.get("v.homePage"),
            "restricted": component.get("v.restricted")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var announcements = response.getReturnValue();
                console.log('These are the announcements : : : ' + announcements);
                announcements.sort(function(o1,o2){
                    let date1 = new Date(o1.CreatedDate).getTime();
                    let date2 = new Date(o2.CreatedDate).getTime();
                    if(date1 > date2) return -1;
                    if(date1 < date2) return +1;
                    return 0;
                });
                var announcementsWebinar = [];
                let lastItemDate;
                let todayDate = new Date();
                todayDate = todayDate.setHours(0,0,0,0);
                console.log('todayDate',todayDate);
                console.log('Anouncement Data:::', announcements);
                announcements.forEach(item=>{
                    let currentDate = new Date(item.CreatedDate).getTime();
                    if(item.PRM_Webinar__c && item.PRM_Webinar__c == true){
                    let newDate = new Date(item.Expiry_Date__c);
                    newDate.setDate(newDate.getDate() - 3);
                    newDate = newDate.setHours(0,0,0,0);
                    console.log('Current newDate Hours:::', newDate);
                    console.log('CompResult:::', (todayDate >= newDate));
                    if(todayDate >= newDate)
                    	announcementsWebinar.push(item);
                    if(!lastItemDate)
                    	lastItemDate = currentDate
                    if(lastItemDate && lastItemDate < currentDate)
                    	lastItemDate = currentDate;
                }
                });
                console.log('announcementsWebinar Data:::', announcementsWebinar);
                
                if(announcementsWebinar && announcementsWebinar.length >0){
                    component.set("v.showWebinarAnouncement", true);                                        
                }
                
                //isWebinarEnabled
                let cookies = document.cookie;
                console.log('Cookies:::', cookies);
                if(cookies){
                    var parts = cookies.split("; ");
                    console.log('parts:::', parts)
                    if(parts){                       
                        let allCookieData = [];
                        parts.forEach(item=>{
                            let dt = item.split('=');
                            let cItem = {};
                                      cItem['Value'] = dt[1];
                                      cItem['Key'] =dt[0];
                                      allCookieData.push(cItem);
                        });
                    	console.log('cookieData:::01', allCookieData);
                    let anounceData = allCookieData.find(item => item.Key == 'ShowWebinarAnouncement');
                    let lastUpdated = allCookieData.find(item => item.Key == 'LastUpdate');
                    let closedFor = allCookieData.find(item => item.Key == 'ClosedFor');
                    if(!lastUpdated){
                        if(anounceData && anounceData.Value == 'false'){
                            component.set("v.isWebinarEnabled", true);
                            document.cookie = 'ShowWebinarAnouncement' + "=" + escape('true')+ "; path=/";
                        }
                    }
                    console.log('Date::::lastUpdated', lastUpdated);
                    console.log('Date::::lastItemDate', lastItemDate);
                    
                    if(lastUpdated && lastItemDate && lastUpdated.Value && Number(lastUpdated.Value) < lastItemDate){
                        component.set("v.isWebinarEnabled", true);
                        document.cookie = 'ShowWebinarAnouncement' + "=" + escape('true')+ "; path=/";
                    }else{
                        console.log('DataFound:::00', anounceData);
                    if(anounceData){
                        console.log('DataFound:::', anounceData);
                        component.set("v.isWebinarEnabled", anounceData.Value == 'true' ? true : false);
                    }else{
                        document.cookie = 'ShowWebinarAnouncement' + "=" + escape('true')+ "; path=/";
                    }
                    }
                    console.log('ClosedFor:::', closedFor);
                    if(closedFor){
                        let currentSessionId = component.get('v.UserSessionId');
                        console.log('currentSessionId:::', currentSessionId);
                        console.log('currentSessionId:::', closedFor.Value);
                        console.log('Result:::', (escape(currentSessionId) == closedFor.Value));
                        if(escape(currentSessionId) == closedFor.Value){
                            component.set("v.isWebinarEnabled", false);
                        }
                    }
                }else{
                    document.cookie = 'ShowWebinarAnouncement' + "=" + escape('true')+ "; path=/";
                }
                    
                }
                component.set("v.announcementsWebinar", announcementsWebinar);
                component.set("v.announcements", announcements);
            } else {
                console.log("ERROR: " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    getPrmOrgBaseUrl : function(component) {
        let action = component.get("c.getPRMOrgBaseUrlSetting");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var prmOrgBaseUrlSetting = response.getReturnValue();
                console.log('Prm Partner Portal Url : : : ' + prmOrgBaseUrlSetting.PRM_Partner_Portal_URL__c);
                component.set("v.prmPartnerPortalUrl", prmOrgBaseUrlSetting.PRM_Partner_Portal_URL__c);
            } else {
                console.log("ERROR: " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    }
})