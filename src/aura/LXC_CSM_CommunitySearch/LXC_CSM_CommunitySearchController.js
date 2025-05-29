({
    init: function (component, event, helper) {
        let currentUser = $A.get("$SObjectType.CurrentUser.Id");
        if(currentUser) 
            helper.getUserContact(component);
        else
            helper.getProductCommunityTopics(component);
    },
    handleClick: function (component, event, helper) {
        helper.searchFor(component);
    },
    handleKeyUp: function (component, event, helper) {
        var isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            helper.searchFor(component);
        }
    }
})