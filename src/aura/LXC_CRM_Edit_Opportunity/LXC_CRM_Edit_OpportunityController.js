({
    doInit : function (component, event, helper) {
        var pathname = window.location.pathname;
        component.set('v.num', Math.floor(Math.random() * 1000));
        //console.log('doInit : '+component.get('v.num')+' : '+ window.location.href);
        helper.openEditDialog(component);
    },
    
    onLocationChange : function (component, event, helper) {
        var pathname = window.location.pathname;
        //console.log('onLocationchange : '+component.get('v.num')+'---**---'+pathname);
        if(pathname && pathname.endsWith('edit') && pathname.indexOf(component.get('v.recordId'))>-1){
            if(!component.get('v.isInit') && !component.get('v.isLocationChange')){
                component.set('v.isLocationChange', true);
                helper.openEditDialog(component);
            }
        }else {
            component.set('v.isInit', false);
            component.set('v.isLocationChange', false); 
        }
    }
})