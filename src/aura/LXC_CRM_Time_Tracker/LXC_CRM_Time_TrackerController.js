({
	doInit : function (component, event, helper) {
        //console.log('doInit : initializing component...');
        var pathname = window.location.pathname;
        if(pathname && pathname.endsWith('edit')){
            if(!component.get('v.isEditMode')){
                component.set('v.isEditMode', true);
                helper.startTimer(component);
            }
        }

        window.addEventListener('beforeunload', function(evt){
            var isEditMode = component.get('v.isEditMode');
            if(isEditMode){
                component.set('v.isEditMode', false);
                //console.log('window.addEventListener : calling logEditTime');
                helper.logEditTime(component);
            }
        });
    },
    onLocationChange : function (component, event, helper) {
        var pathname = window.location.pathname;
        //console.log('onLocationchange');
        if(pathname && pathname.endsWith('edit')){
            if(!component.get('v.isEditMode')){
                component.set('v.isEditMode', true);
                helper.startTimer(component);
            }
        }else if(pathname && pathname.endsWith('view')){
            var recordId = component.get('v.recordId');
            var sObjectName = component.get('v.sObjectName');
            
            if(pathname.includes(recordId) && pathname.includes(sObjectName)){
                if(component.get('v.isEditMode')){
                    component.set('v.isEditMode', false);
                    //console.log('onLocationChange : calling logEditTime');
                    helper.logEditTime(component);
                }
            }else{
                //console.log('onLocationChange : destroying component...');
                component.destroy();
            }
        }else{
            //console.log('onLocationChange : destroying component...');
            component.destroy();
        }
    },
})