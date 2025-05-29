({
    doInit: function(component, event, helper) {
        console.log('{!v.recordId}--------'+component.get("v.recordId"));
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
        }
        var hideDiv= component.find("messageDiv");
        $A.util.addClass(hideDiv, "invisible");

        
        var labelValue = $A.get("$Label.c.Return_from_DocuSign_message");
        
        if(sParameterName[1] == 'signing_complete'){
            component.set("v.recordErrorMsg", labelValue);
            $A.util.removeClass(hideDiv, "invisible");
        }	
    },
    
    refreshComponent: function(component,event,helper)
    {
        window.location.reload();
    }
})