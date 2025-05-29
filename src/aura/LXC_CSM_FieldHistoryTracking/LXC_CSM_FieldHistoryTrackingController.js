({
    
    doInit : function(cmp, event, helper) {
        cmp.set("v.allchecked",false);
        cmp.set('v.selectAll','Select All');
        cmp.set("v.cardTitle","Field History Tracking");
        $A.util.addClass(cmp.find('defaultCheckList'), 'slds-hide');
        $A.util.removeClass(cmp.find('myForm'), 'slds-form--stacked');
        helper.callServer(cmp, "c.getObjNameList",function(response){
            var objectList = [];
            var  selectedItem=null;
            
            for (var i=0; i<response.length; i++) {
                objectList.push({
                    name: response[i].label,
                    value: response[i].value
                });
                
            }
            
            cmp.set('v.objectList',objectList);
            cmp.set('v.selectedItem',selectedItem);
            
        },null,true);
        
    },
    showFieldGroupCheckbox : function(cmp, event, helper) {
        cmp.set("v.allchecked",false);
        cmp.set('v.selectAll','Select All');
        
        if(cmp.get("v.selectedItem").length>0){
            
            cmp.set("v.cardTitle"," "+helper.replaceCObjectName(cmp.get("v.selectedItem"))+" Field History Tracking");
            
            helper.callServer(cmp, "c.showFieldGroupCheckboxData",function(response){
                if(response.checkboxList.length>0){
                    $A.util.removeClass(cmp.find('myFormDefaultFieldSet'), 'slds-hide');
                    $A.util.addClass(cmp.find('myFormDefaultFieldSet'), 'slds-show');
                    
                }else{
                    $A.util.removeClass(cmp.find('myFormDefaultFieldSet'), 'slds-show');
                    $A.util.addClass(cmp.find('myFormDefaultFieldSet'), 'slds-hide');
                    
                }
                
                cmp.set('v.value',response.value);
                cmp.set('v.options',response.checkboxList);
                var num=[];
                for(var i=0;i<(6-(response.checkboxList.length%6));i++){
                    num[i]=i; 
                }
                cmp.set('v.litems',num);
                
                
            },{ selectedObject : cmp.get("v.selectedItem")},true);
            
            helper.callServer(cmp, "c.showFieldGroupCheckboxCustomData",function(response){
                
                if(response.checkboxList.length>0){
                    $A.util.removeClass(cmp.find('myFormCustomFieldSet'), 'slds-hide');
                    $A.util.addClass(cmp.find('myFormCustomFieldSet'), 'slds-show');
                }else{
                    $A.util.removeClass(cmp.find('myFormCustomFieldSet'), 'slds-show');
                    $A.util.addClass(cmp.find('myFormCustomFieldSet'), 'slds-hide');
                    
                }
                
                cmp.set('v.customvalue',response.value);
                cmp.set('v.customoptions',response.checkboxList);
                var num=[];
                for(var i=0;i<(6-(response.checkboxList.length%6));i++){
                    num[i]=i; 
                }
                cmp.set('v.clitems',num);
                
                
            },{ selectedObject : cmp.get("v.selectedItem")},true);
            
            cmp.find('btnsaveForm').set('v.disabled',false); 
            $A.util.removeClass(cmp.find('defaultCheckList'), 'slds-hide');
            $A.util.addClass(cmp.find('defaultCheckList'), 'slds-box');
            
        }else{
            cmp.set("v.cardTitle"," Field History Tracking");
            $A.util.removeClass(cmp.find('defaultCheckList'), 'slds-box');
            $A.util.addClass(cmp.find('defaultCheckList'), 'slds-hide');
        }
        
    },
    handleSelectAll: function (cmp, event,helper) {
        
        var changeValue = cmp.get("v.allchecked");
        var customcheckbox=cmp.find("customcheckbox");
        if((cmp.get("v.selectedItem")=="") || (cmp.get("v.selectedItem")==null)){
            try {
                throw new Error("Please Select the Object");
            }catch (e) {
                helper.showToastmsg(cmp,"Error","error",e.message);
            }
            
            
        }else{
            
            if(changeValue){
                for(var i=0; i<customcheckbox.length; i++){
                    customcheckbox[i].set('v.checked',true);
                }
                cmp.set('v.selectAll','Clear All ');
            }else{
                for(var i=0; i<customcheckbox.length; i++){
                    customcheckbox[i].set('v.checked',false);   
                } 
                cmp.set('v.selectAll','Select All');
            }  
        }
        
        
    },
    showSpinner: function(cmp, event, helper) {
        // make Spinner attribute true for display loading spinner 
        cmp.set("v.Spinner", true); 
    },
    hideSpinner : function(cmp,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        cmp.set("v.Spinner", false);
    },handleClick:function(cmp,event,helper){
        
        
    },
    saveForm: function (cmp, event,helper) {
        event.preventDefault();
        var result=[];
        var customcheckbox=cmp.find("customcheckbox");
        
        if((cmp.get("v.selectedItem")=="") || (cmp.get("v.selectedItem")==null)){
            
            try {
                throw new Error("Please Select the Object");
            }catch (e) {
                helper.showToastmsg(cmp,"Error","error",e.message);
            }
            
            
        }else{
            for(var i=0; i<customcheckbox.length; i++){
                if(customcheckbox[i].get('v.checked')){
                    result.push(customcheckbox[i].get('v.name'));
                }
                
            }
            
            if((result.toString()=="") || (result.toString()==null)){
                try {
                    throw new Error("Please check at least one checkbox");
                }catch (e) {
                    helper.showToastmsg(cmp,"Error","error",e.message);
                    
                }    
            }else if( cmp.get('v.customvalue').toString()==result.toString()){
                try {
                    throw new Error("you have not checked any new checkbox");
                }catch (e) {
                    helper.showToastmsg(cmp,"Error","error",e.message);
                } 
            }else{
                
                helper.callServer(cmp, "c.saveFields",function(response){
                    
                    helper.showToastmsg(cmp,response.title,response.severity,helper.replaceCObjectName(response.message));
                    
                    if('success'===response.severity){
                        helper.callServer(cmp, "c.showFieldGroupCheckboxCustomData",function(response){
                            
                            if(response.checkboxList.length>0){
                                $A.util.removeClass(cmp.find('myFormCustomFieldSet'), 'slds-hide');
                                $A.util.addClass(cmp.find('myFormCustomFieldSet'), 'slds-show');
                            }else{
                                $A.util.removeClass(cmp.find('myFormCustomFieldSet'), 'slds-show');
                                $A.util.addClass(cmp.find('myFormCustomFieldSet'), 'slds-hide');
                                
                            }
                            cmp.set('v.customvalue',response.value);
                            cmp.set('v.customoptions',response.checkboxList);
                            var num=[];
                            for(var i=0;i<(6-(response.checkboxList.length%6));i++){
                                num[i]=i; 
                            }
                            cmp.set('v.clitems',num);  
                            cmp.set('v.selectAll','Select All');
                            cmp.set("v.allchecked",false);
                        },{ selectedObject : cmp.get("v.selectedItem")},true);
                    }
                    
                },{ "selectedObject" : cmp.get("v.selectedItem"),"fields":result.toString()},true);  
                
            } 
            
        }
        
        
    }
})