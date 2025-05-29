({
    doInit : function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Queue User Management"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:settings",
                iconAlt: "settings"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
        helper.callServer(component, "c.getLocalAdmin",function(response){
            
            component.set('v.appAccess',response);
            if(!response){
                helper.showToastmsg(component,"Warning","Warning","You don't have a permission to access Queue User Management.");    
            }
            
        },null,true);
        /** helper.callServer(component, "c.getTotalNoOfRows",function(response){
            component.set("v.totalNumberOfRows", response);
        },null,true); */
        
       
    },
   searchUser: function (component, event, helper) {
       var  selected = component.get('v.selectedRecord');
       if(component.get('v.searchUserName') == null)
       {
           selected = 'A';
       }
       if(selected != undefined && selected.Group_Id__c != undefined){
           
           helper.callServer(component, "c.getSearchUsers",function(response){
               //alert(JSON.stringify(response));
               
               component.set("v.listOptions", response);
               //component.set("v.defaultOptions", values);
               //component.set("v.requiredOptions", required);
               
           },{"queueId": component.get('v.selectedRecord').Group_Id__c, "searchKeyWord": component.get('v.searchUserName')},true);    
       }else {
           helper.showToastmsg(component,"Error","error","Please select the Queue Name");
       }
       
       
    },
    saveSelectedUsers : function (component, event, helper) {
       
        var  selected = component.get('v.selectedRecord');
        var lst = component.get('v.selectedOptionsList');
        if(lst != undefined && lst.length <= 0 ){
            helper.showToastmsg(component,"Error","error","Please select/remove the Queue Members");
        }else if(selected != undefined && selected.Group_Id__c != undefined){
        if(component.get("v.defaultSelected") == component.get("v.selectedOptionsList")){
        }else{
            helper.callServer(component, "c.saveSelectedUsersinGroupMember",function(response){
                var values = [];
                var newResponse = [];
                var validationFlag = false;
                var validationNames = [];
                for (var i=0; i<response.length; i++) {
                    if(response[i].label.indexOf('--Restricted') > -1){
                        if(validationFlag == false){
                            validationFlag = true;
                        }
                        var name = response[i].label.split('--')[0];
                        validationNames.push(name);
                    }
                    else{
                        values.push(response[i].value);
                        newResponse.push(response[i]);
                    }
                }
                if(validationFlag == true){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Warning!",
                        "message": 'User(s) '+validationNames+' can\'t be removed since an active Service User cannot have no queue assigned',
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                component.set("v.searchUserName", null);
                component.set("v.defaultOptions", values);
                component.set("v.defaultSelected", values);
                component.set("v.listOptions", newResponse);
                helper.callServer(component, "c.getAddedDeletedList",function(response){
                    component.set("v.columns", response.lstDataTableColumns);
                    component.set("v.data", response.lstDataTableData);
                },{"queueId": component.get('v.selectedRecord').Group_Id__c},true); 
                
            },{"queueId": component.get('v.selectedRecord').Group_Id__c, "defaultList": component.get('v.defaultSelected'),"selected": component.get('v.selectedOptionsList')},true);
        }
       }else{
           helper.showToastmsg(component,"Error","error","Please select the Queue Name");
       }
    },
    handleRowAction : function(component, event, helper){
      var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'show_details':
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({"recordId": row.Id,"slideDevName": "detail"});
                navEvt.fire();
                break;
            case 'delete':
                var rows = component.get('v.data');
                var rowIndex = rows.indexOf(row);
                helper.callServer(component, "c.deleteRecord",function(response){
                    helper.showToastmsg(component,"Success","info","Record Deleted succesfully");
                },{"id" : row.Id},true);
                rows.splice(rowIndex, 1);
                component.set('v.data', rows);
                break;
        }  
    },
    handleChange: function (cmp, event) {
        // Get the list of the "value" attribute on all the selected options
        var selectedOptionsList = event.getParam("value");
        cmp.set("v.selectedOptionsList", selectedOptionsList);
        //alert("Options selected: '" + selectedOptionsList + "'");
    },
    
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.spinner", false);
    },
    
   onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';
         helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        component.set("v.listOptions", []);
        component.set("v.defaultOptions", []);
        component.set("v.searchUserName", '');
        component.set("v.data", []);
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );   
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        
        helper.callServer(component, "c.getSelectedQueueUsers",function(response){
            var values = [];
            for (var i=0; i<response.length; i++) {
                values.push(response[i].value);
            }
        component.set("v.listOptions", response);
        component.set("v.defaultOptions", values);
        component.set("v.defaultSelected", values);
            
        //component.set("v.requiredOptions", required);
            
       },{"queueId": component.get('v.selectedRecord').Group_Id__c},true);
        
        helper.callServer(component, "c.getAddedDeletedList",function(response){
            component.set("v.columns", response.lstDataTableColumns);
            if(response.lstDataTableData.length > 0){
                 var datatable = component.find("datatable");
                $A.util.addClass(datatable, 'slds-show');
                component.set("v.data", response.lstDataTableData);    
            }else{
               var datatable = component.find("datatable");
                $A.util.addClass(datatable, 'slds-hide'); 
            }
            
        },{"queueId": component.get('v.selectedRecord').Group_Id__c},true); 
       
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
      
	},
})