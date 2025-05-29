({
    doInit : function(component, event, helper) {
        helper.getGroupsRelatedToProduct(component);
    },
    
    openGroupDetailPage: function (component, event, helper) {
        var groupId = event.target.id;       
        let mainURL = window.location.href
        let finalURL = String(mainURL).substring(0, mainURL.indexOf('/s/'));
        console.log('Final URL:::', finalURL);
        window.open(finalURL + '/s/group-details?groupId=' + groupId,'_blank');
    },
   
})
