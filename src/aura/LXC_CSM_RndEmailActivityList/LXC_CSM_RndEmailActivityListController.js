({
    init: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var caseId = component.get('v.pageReference').state.c__caseId;
        component.set('v.caseId', caseId);
        if(caseId != undefined){
            var ws = component.get('v.pageReference').state.ws;
            if(ws == undefined){
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    workspaceAPI.closeTab({tabId: response.tabId});
                })
                .catch(function(error) {
                    console.log(error);
                });
                
                workspaceAPI.openTab({
                    url: '/lightning/r/Case/'+ caseId +'/view',
                    focus: false
                }).then(function(response) {
                    workspaceAPI.openSubtab({
                        parentTabId: response,
                        url: '/lightning/cmp/c__LXC_CSM_RndEmailActivityList?c__caseId='+caseId,
                        focus: true
                    }).then(function(response) {
                        workspaceAPI.setTabLabel({tabId: response,label: "Update Email Activity"});    
                    });
                    workspaceAPI.openSubtab({
                        parentTabId: response,
                        url: '/lightning/r/'+ caseId +'/related/EmailMessages/view',
                        focus: false
                    });
                    
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
            helper.callServer(component, "c.getEmailActivityList",function(response){
                if(response != undefined){
                    component.set('v.columns', [
                        {label: 'Subject', fieldName: 'emailUrl', type: 'url',typeAttributes: {label: { fieldName: 'subject' },target : '_self'}},
                        {label: 'From Address', fieldName: 'fromAddress', type: 'text'},
                        {label: 'To Address', fieldName: 'toAddress', type: 'text'},
                        {label: 'Message Date', fieldName: 'messageDate', type: 'date'},
                        {label: 'Email Status', fieldName: 'estatus', type: 'text'},
                        {label: 'Activity', fieldName: 'activityUrl', type: 'url',typeAttributes: {label: { fieldName: 'name' },target : '_self'}},
                        {label: 'Type', fieldName: 'actType', type: 'text'},
                        {label: 'Email Categorization', fieldName: 'emailCategorization', type: 'text'},
                        {label: 'Activity Status', fieldName: 'astatus', type: 'text'}
                    ]);
                component.set('v.data', response);
                }
            },{"caseId" : caseId},true);
            helper.callServer(component, "c.getEmailCategorizationList",function(response){
                if(response != undefined){
                    var emArray = [];
                    for (var i = 0; i < Object.keys(response).length; i++) {
                        var em = response[i];
                        emArray.push(em);
                    }
                    component.set("v.options", emArray);
                }
            },{"fieldName" : "Email_Categorization__c"},true);
            helper.callServer(component, "c.getEmailCategorizationList",function(response){
                if(response != undefined){
                    var emArray = [];
                    for (var i = 0; i < Object.keys(response).length; i++) {
                        var em = response[i];
                        emArray.push(em);
                    }
                    component.set("v.optionStatus", emArray);
                }
            },{"fieldName" : "Status__c"},true);
        }
    },
     updateSelectedText: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
         component.set('v.selectedRows',selectedRows);
        component.set('v.selectedRowsCount', selectedRows.length);
    },
    updateRowSelection: function(component, event, helper) {
        if(component.get('v.selectedRowsCount') > 0){
            component.set("v.isModalOpen", true);    
        }else{
            helper.showToastmsg(component,"Error","error","Please select at least one record");
        }
        
    },
    closeModel: function(component, event, helper) {
        //component.set('v.selectedRows',[]);
        //component.set('v.selectedRowsCount', 0);
        component.set('v.selectedValue','');
        component.set('v.sltStatusValue','');
        component.set("v.isModalOpen", false);
        
    },
    updateEmailActivity: function (component, event,helper) {
        var emActList = component.get('v.selectedRows');
        for (var i = 0; i < emActList.length; i++) {
            emActList[i].emailCategorization = component.get('v.selectedValue');
            emActList[i].astatus = component.get('v.sltStatusValue');
        }
        //alert(JSON.stringify(component.get('v.selectedRows')));
        helper.callServer(component, "c.updateEmailActivityWrapperList",function(response){
            if(response != undefined){
                component.set('v.data', response);
                component.set("v.isModalOpen", false);
                component.set('v.selectedRows',[]);
                component.set('v.selectedRowsCount', 0);
                component.set('v.selectedValue','');
                component.set('v.sltStatusValue','');
                var ltngCmp = component.find("ltngDatatableCmp");
                if(ltngCmp){
                    ltngCmp.set("v.selectedRows", []); 
                }
            }
        },{"emailActivityList" : component.get('v.selectedRows')},true);
    }
})