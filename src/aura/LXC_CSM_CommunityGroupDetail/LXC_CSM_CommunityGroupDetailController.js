({
    doInit : function(component, event, helper) {
        var groupId = "";
        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        var sURLVariables = sPageURL.split('&');
        var sParameterName;
        var i;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); 
            if (sParameterName[0] === 'groupId') { 
                sParameterName[1] === undefined ? '' : sParameterName[1];
                groupId = sParameterName[1];
            }
        }
        component.set("v.groupId", groupId);
        helper.getGroupDetails(component);
    }
})