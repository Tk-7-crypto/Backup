({
    handleClick: function (component, event, helper) {
        helper.searchFor(component);
       
    },
    handleKeyUp : function(component, event, helper){
        var isEnterKey = event.keyCode === 13;
        if (isEnterKey) {      
            helper.searchFor(component);
        }
    }
})