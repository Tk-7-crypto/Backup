({
    show : function(component) {
        $A.util.removeClass(component.find("prompt"), "slds-fade-in-hide");
        $A.util.addClass(component.find("prompt"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop_prompt"), "slds-backdrop_hide");
        $A.util.addClass(component.find("backdrop_prompt"), "slds-backdrop_open");

    },
    hide : function(component) {
        $A.util.addClass(component.find("prompt"), "slds-fade-in-hide");
        $A.util.removeClass(component.find("prompt"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop_prompt"), "slds-backdrop_hide");
        $A.util.removeClass(component.find("backdrop_prompt"), "slds-backdrop_open");
    },
})