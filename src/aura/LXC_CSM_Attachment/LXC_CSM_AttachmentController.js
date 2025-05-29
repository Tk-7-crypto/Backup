({
	doInit : function(component, event, helper) {
        //alert('This is Lc ' + component.get('v.recordId'));
		//var id = component.get("v.pageReference").state.c__recordId;         
       // component.set("v.isLoaded", true);
        component.set("v.recId", component.get('v.recordId'));
	}
})