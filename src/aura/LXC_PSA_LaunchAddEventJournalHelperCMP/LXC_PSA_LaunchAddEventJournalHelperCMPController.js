({
    doInit : function(component, event, helper) {
        
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var addressableContext = JSON.parse(window.atob(value));
        var recordId = addressableContext.attributes.recordId;
        console.log('###recordId : '+recordId);
        if( !recordId ){
            window.open(window.location.origin+'/lightning/n/PSA_ADD_Journal?New','_self');
        }else{
            window.open(window.location.origin+'/lightning/n/PSA_ADD_Journal?c__LR_Project_Overview='+recordId,'_self');
        }
        
        
    }
})
