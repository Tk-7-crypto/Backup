({
    logEditStartTime : function(component) {
        //console.log('logEditStartTime : ');
        var action = component.get('c.logEditStartTime');
        action.setParams({
            'sObjectName' : component.get('v.sObjectName'),
            'recordId' : component.get('v.recordId')
        });
        $A.enqueueAction(action);
	},
    openEditDialog : function(component){
        console.log('openEditDialog');
        var url = "/lightning/r/"+component.get('v.sObjectName')+"/"+component.get('v.recordId')+"/view";
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: component.get('v.sObjectName'),
                recordId : component.get('v.recordId'),
                actionName: 'edit'
            },
            state:{
                nooverride : 1,
                backgroundContext : url
            }
        };
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            this.navigateToOppRecordPage(url);
        }).bind(this), $A.getCallback(function(error) {
            this.navigateToOppRecordPage(url);
        }).bind(this));
        
        this.logEditStartTime(component);
    },
    navigateToOppRecordPage : function(url){
        //console.log('navigateToOppRecordPage : '+url);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url,
            "isredirect": "true"
        });
        urlEvent.fire();
    }   
})