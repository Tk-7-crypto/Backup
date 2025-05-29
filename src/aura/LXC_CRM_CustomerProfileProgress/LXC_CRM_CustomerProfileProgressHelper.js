({
	setScores : function(cmp) {
		var action = cmp.get("c.getScores");
        action.setParams({
            recordId: cmp.get("v.recordId"),
            cmpObject: cmp.get("v.cmpObject")
        });
        action.setCallback(this, function(response){
            cmp.set("v.scoresMap", response.getReturnValue());
            var state = response.getState();
            if (state === "SUCCESS"){
                this.setProgressVariant(cmp, 'Data Quality Score', "v.dataQualityWarning");
                
                cmp.set("v.dataQualityScore", cmp.get("v.scoresMap")['Data Quality Score']);
            }
            else if(state == "ERROR"){
                this.showToast(
                    'error',
                    'Error!',
                    'There was an error loading the Customer Profile component.'
                );
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
	},
    
    setProgressVariant : function(cmp, scoreType, variantType) {
        if(cmp.get("v.scoresMap")[scoreType] == 100){
            cmp.set(variantType, false);
        }
        else if(cmp.get("v.scoresMap")[scoreType] < 100){
            cmp.set(variantType, true);
        }
    },

    showToast : function(tType, tTitle, tMessage){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": tType,
            "title": tTitle,
            "message": tMessage,
            "duration": 10000
        });
        toastEvent.fire();
	}
})