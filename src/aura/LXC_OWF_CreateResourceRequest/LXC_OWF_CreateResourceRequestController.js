({
    //Load data Picklist
    doInit: function(component, event, helper) {
        
        helper.initResourceRequest(component, event);        
        helper.getCoutriesMultiselect(component, event);
        helper.setResourceRequestTypesForMultipleRR(component, event);
        helper.calculateWindowHeight(component);
        window.addEventListener('resize', function() {
            helper.calculateWindowHeight(component);
        });
    },
    
    //handle ResourceRequest Save
    handleResourceRequest : function(component, event, helper) {
        helper.validateNoOfRRSelected(component, event);
        var rrIterator = component.get("v.selectNoOfRRToBeCreated",rrIterator);
        if(rrIterator > 0 && rrIterator <= 10) 
        {
            helper.saveResourceRequest(component, event);
        }
    },
    
    selectNoOfRRToBeCreated : function(component, event, helper) {
        var rrIterator = event.getParam("value");
        component.set("v.selectNoOfRRToBeCreated",rrIterator);
    },
    validateRRToBeCreated : function(component, event, helper){
        helper.validateNoOfRRSelected(component, event);
    },
    
   //handle Industry Picklist Selection
    handleSubgroupOnChange : function(component, event, helper) {
        var subgroup = event.getParam("value");
        component.set("v.rr.SubGroup__c",subgroup);
        var x = document.getElementById("dcalc");	
        x.style.opacity = "0.4";
        x.style.pointerEvents = "none";
        if(subgroup == "Global Analytics"){        
            x.style.opacity = 1;
            x.style.pointerEvents = "auto";
        }
        else
        {
            component.set("v.selectedGenreList","[]");
        }        
    },
    
    isbiddefense :function(component ,event, helper){
        
        var chkbox = event.getSource().get('v.checked');
        component.set("v.rr.Is_Bid_Defense__c",chkbox);
    },
    
    handleOnload : function(component, event, helper) {
        component.set("v.rr.Is_Bid_Defense__c",false);
        component.set("v.selectedGenreList",[]);
        component.set("v.SelectedMultipleSubgroupList",[]);
        component.set("v.selectNoOfRRToBeCreated",1);
        component.set("v.rr.SubGroup__c",null);
        component.set("v.Spinner", false);
    },
    
    handleGenreChange: function (component, event, helper) {
        //Get the Selected values   
        var selectedValues = event.getParam("value");
        
        //Update the Selected Values      
        component.set("v.selectedGenreList", selectedValues);
        
    },
    cancelResourceRequest : function(component, event, helper) {
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    createMultipleAnalyticsRequests: function(component, event, helper) {
        helper.createMultipleAnalyticsRequests(component, event);
    }
    
})
