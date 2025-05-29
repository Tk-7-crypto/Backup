({
    doInit : function(cmp, event, helper) {
        cmp.set("v.showSpinner", true);

        // initialize progress indicator steps
        var maxLevel = cmp.get("v.maxLevel");

        var levels = [];
        
        for(var i = 0; i < maxLevel; i++){
            var lvl = i + 1;
            levels.push(lvl.toString());
        }
        
        console.log(levels);
        cmp.set("v.levels", levels);
        
        helper.getLevelFields(cmp);
    },

    handleOnLoad : function(cmp, event, helper) {
        cmp.set("v.showSpinner", false);
    },

    handleOnSucess : function(cmp,event, helper) {
        $A.get('e.force:refreshView').fire();
        cmp.set("v.hasError", false);
    },

    handleOnSumbit : function(cmp, event, helper) {
        cmp.set("v.showSpinner", true);
    },
    
    handleOnError : function(cmp, event, helper) {
        cmp.set("v.showSpinner", false);
        cmp.set("v.hasError", true);
    }
})