({
    doInit : function(component, event, helper) {
        helper.getOppByIdWithOppTeamSplits(component, event, helper);
    },
    
    deleteSpiltRecord : function(component, event, helper) {
        helper.deleteSpiltRecord(component, event, helper);
    },
    
    addSpiltRecord : function(component, event, helper) {
        helper.addSpiltRecord(component, event, helper);
    },
    
    saveSplits : function(component, event, helper) {
        helper.checkSplitMember(component, event, helper, false);
    },
    
    saveClose : function(component, event, helper) {
        helper.checkSplitMember(component, event, helper, true);
    },
    
    setTotalAmount : function(component, event, helper) {
        helper.setTotalAmount(component, event, helper);
    },
    
    checkSplitMember : function(component, event, helper) {
        helper.checkSplitMember(component, event, helper);
    },
    
    addOpportunityTeamMember : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.addOpportunityTeamMember(component, event, helper, recordId);
    },
 
    removeErrors : function(component, event, helper) {
        var errorsToShow = component.get("v.errors");
        var errorId = "SplitOwnerId";
        var errorRemoveIndex = -1;
        for(var errorIndex in errorsToShow) {
            if(errorsToShow[errorIndex].Id == errorId) {
                errorRemoveIndex = errorIndex;
                break;
            }
        }
        if(errorRemoveIndex != -1) {
            errorsToShow.splice(errorRemoveIndex, 1);
            component.set("v.errors", errorsToShow);
        }
    },
    
    setOppSplitField : function(component, event, helper) {
        var inputComp = event.getSource();
        var localId = inputComp.getLocalId();
        var index = inputComp.get("v.label").split(localId)[1];
        var inputValue = inputComp.get("v.value");
        if(inputValue != undefined) {
            var oppSplitWrapperList = component.get("v.oppSplitWrapperList");
            oppSplitWrapperList[index]["splitRecord"][localId] = inputValue
            component.set("v.oppSplitWrapperList", oppSplitWrapperList);
        }
    },
    
    navigateToOpp : function(component, event, helper){
        var recordId = component.get("v.recordId");
        helper.navigateToOpp(component, event, helper, recordId);
    },
    
    callReloadEvent : function(component, event, helper) {
       helper.callReloadEvent(component, event, helper);
    }
})