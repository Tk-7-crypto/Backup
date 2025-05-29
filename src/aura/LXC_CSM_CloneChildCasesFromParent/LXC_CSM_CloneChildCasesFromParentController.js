({
    doInit : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var caseId = component.get('v.pageReference').state.c__caseId;
        component.set('v.caseId', caseId);
        if(caseId != undefined ){
            var ws = component.get('v.pageReference').state.ws;
            component.set("v.caseSearchDisable",true);
            component.set("v.buttonSDisable",false);
            component.set("v.data",null);
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
                        url: '/lightning/r/'+ caseId +'/related/Cases/view',
                        focus: false
                    });
                    workspaceAPI.openSubtab({
                        parentTabId: response,
                        url: '/lightning/n/New_Bulk_RandD_Child_Cases?c__caseId='+caseId,
                        focus: true
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            }else if(caseId != undefined){
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.isSubtab({
                        tabId: focusedTabId
                    }).then(function(response) {
                        if (response) {
                            workspaceAPI.setTabLabel({
                                tabId: focusedTabId,
                                label: "RandD Bulk Child Case Create"
                            });
                        }
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "standard:case",
                        iconAlt: "settings"
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
                helper.callServer(component, "c.searchParentCase",function(response){
                    component.set("v.parentCase", response);
                    if(response.ContactId != null){
                        component.set("v.sltContactId", response.ContactId);
                        component.set("v.sltContactName", response.Contact.Name);
                    }
                    if(response.RecordTypeName__c != 'VirtualTrialsCase' && response.OnBehalfOf__c != null){
                        component.set("v.sltOnBeOfId", response.OnBehalfOf__c);
                        component.set("v.sltOnBeOfName", response.OnBehalfOf__r.Name);
                    }
                    if(response.Study__c != null){ component.set("v.sltStudyId", "Study__c = '"+response.Study__c+"'"); }
                    if(response.Site_Related_to_the_Study__c != null){
                        component.set("v.sltSSCId", response.Site_Related_to_the_Study__c);
                        component.set("v.sltSSCName", response.Site_Related_to_the_Study__r.Name);
                    }
                    component.set("v.sltLos", response.LOS__c);
                    component.set("v.sltST1", response.SubType1__c);
                    component.set("v.sltST2", response.SubType2__c);
                    component.set("v.sltST3", response.SubType3__c);
                    component.set("v.sltTemplate", response.Template__c);
                    component.set("v.conUserRole", response.Contact_User_Role__c);
                    component.set("v.subjectId", response.Subject_ID__c);
                    helper.getControllingField(component);
                    if(response.RecordTypeName__c == 'ActivityPlan'){
                        component.set("v.sltSiteAssignment", response.Site_Assignment__c);
                        helper.callServer(component, "c.getPiklistValues",function(res){
                            var plValues = [];
                            for (var i = 0; i < res.length; i++) {
                                plValues.push({label: res[i],value: res[i]});
                            }
                            component.set("v.siteAssignmentList", plValues);
                        },{ objName : 'Case', fieldName : 'Site_Assignment__c'},true);
                        
                        if(response.Site_Assignment__c != undefined && response.Site_Assignment__c.includes(';')){
                            var values = response.Site_Assignment__c.split(';');
                            component.set("v.selectedSiteAssignmentList", values);
                        }else{
                            var siteVals = [];
                            siteVals.push(response.Site_Assignment__c);
                            component.set("v.selectedSiteAssignmentList", siteVals);
                        }
                        
                        
                        helper.fetchPicklistValues(component, 'LOS__c', 'Template__c');
                        var  columnLst = component.get('v.columns');
                        columnLst.splice(4 , 0, { label: "Template", fieldName: "template", type: "text"});
                        columnLst.push({ label: "Contact User Role", fieldName: "conUserRole", type: "text"});
                        columnLst.push({ label: "Site Assignment", fieldName: "siteAssignment", type: "text"});
                        component.set('v.columns', columnLst);
                    }
                    if(response.RecordTypeName__c == 'VirtualTrialsCase'){
                        var  columnLst = component.get('v.columns');
                      columnLst.push({ label: "Subject ID", fieldName: "subjectId", type: "text"});
                    }
                    
                },{ caseId : caseId},true);
            }    
        }else{
            component.set("v.caseSearchDisable",false);
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "RandD Bulk Child Case Create"
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }
        var columnLst = [];
        columnLst.push({ type: "action", typeAttributes: { rowActions: [{ label: "Delete", name: "delete" }]}});
        columnLst.push({ label: "Row No", fieldName: "Id", type: "number"});
        columnLst.push({ label: "Contact Name", fieldName: "contactName", type: "text"});
        columnLst.push({ label: "On Behalf Of", fieldName: "onBehalfOfName", type: "text"});
        columnLst.push({ label: "Site Name", fieldName: "siteName", type: "text"});
        columnLst.push({ label: "LOS", fieldName: "los", type: "text"});
        columnLst.push({ label: "Sub-Type1", fieldName: "subType1", type: "text"});
        columnLst.push({ label: "Sub-Type2", fieldName: "subType2", type: "text"});
        columnLst.push({ label: "Sub-Type3", fieldName: "subType3", type: "text"});
        component.set('v.columns', columnLst);
        
        
    },
    
	searchForm : function(component, event, helper) {
        helper.callServer(component, "c.searchParentCase",function(response){
            component.set("v.parentCase", response);
            if(response.ContactId != null){
                component.set("v.sltContactId", response.ContactId);
                component.set("v.sltContactName", response.Contact.FirstName + ' ' + response.Contact.LastName);
            }
            if(response.RecordTypeName__c != 'VirtualTrialsCase' && response.OnBehalfOf__c != null){
                component.set("v.sltOnBeOfId", response.OnBehalfOf__c);
                component.set("v.sltOnBeOfName", response.OnBehalfOf__r.FirstName + ' ' + response.OnBehalfOf__r.LastName);
            }
            if(response.Site_Related_to_the_Study__c != null){
                component.set("v.sltSSCId", response.Site_Related_to_the_Study__c);
                component.set("v.sltSSCName", response.Site_Related_to_the_Study__r.Name);
            }
            component.set("v.sltLos", response.LOS__c);
            component.set("v.sltST1", response.SubType1__c);
            component.set("v.sltST2", response.SubType2__c);
            component.set("v.sltST3", response.SubType3__c);
            component.set("v.sltTemplate", response.Template__c);
            component.set("v.conUserRole", response.Contact_User_Role__c);
            component.set("v.subjectId", response.Subject_ID__c);
            component.set("v.sltSiteAssignment", response.Site_Assignment__c);
            },{ caseId : component.get("v.caseId")},true);
    },
    resetForm : function(component, event, helper){
        
    },
    addtoDataTable : function(component, event, helper){
        var count = component.get("v.sltChildNo");
        var array = [];
        if(component.get("v.caseId") == undefined || component.get("v.caseId") == ''){
            helper.showToastmsg(component,"Warning","warning",'Please Select the Parent Case');
            return ;
        }else if(component.get("v.sltContactId") == undefined || component.get("v.sltContactId") == ''){
            helper.showToastmsg(component,"Warning","warning",'Please Select the Contact Name or StudySiteContact Name');
            return ;
        }
        if(component.get("v.data") != null){
          array = component.get("v.data");
        }
        if(array.length == 0){
        var i=1;    
        }else if(array.length > 0){
          var i = parseInt(array.length)+1;
            count = parseInt(count) + parseInt(array.length);
        }
        component.set("v.dataTblCount",count);
        for(; i<= count; i++){
            var myCon = new Object();
            myCon.contactName = component.get("v.sltContactName");
            myCon.contactId = component.get("v.sltContactId");
            myCon.onBehalfOfName = component.get("v.sltOnBeOfName");
            myCon.onBehalfOfId = component.get("v.sltOnBeOfId");
            myCon.caseNumber = '';
            myCon.siteName = component.get("v.sltSSCName");
            myCon.sscId = component.get("v.sltSSCId");
            myCon.studyId = component.get("v.sltStudyId");
            myCon.los = component.get("v.sltLos") != 'Please Specify' ?component.get("v.sltLos") : '';
            myCon.template = component.get("v.sltTemplate") != 'Please Specify' ?component.get("v.sltTemplate") : '';
            myCon.subType1 = component.get("v.sltST1") != 'Please Specify' ?component.get("v.sltST1") : '';
            myCon.subType2 = component.get("v.sltST2") != 'Please Specify' ?component.get("v.sltST2") : '';
            myCon.subType3 = component.get("v.sltST3") != 'Please Specify' ?component.get("v.sltST3") : '';
            myCon.conUserRole  = component.get("v.conUserRole");
            myCon.subjectId  =  component.get("v.subjectId");
            myCon.siteAssignment = component.get("v.sltSiteAssignment");
            myCon.Id = i;
            array.push(myCon);
            
        }
        component.set("v.arrayStr", array);
        component.set("v.data", array);
        
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'edit':
                var id = row.Id;
                list = cmp.get("v.data");
                break;
            case 'delete':
                var id = row.Id;
                var list = cmp.get("v.data");
                var index = list.map(x => {
                    return x.Id;
                }).indexOf(id);
                
                list.splice(index, 1);
                for (var i = 0; i < list.length; i++){
                   list[i].Id = i+1; 
                }
                cmp.set("v.data",list);
                break;
        }
    },
    openModel: function(component, event, helper) {
      // Set isModalOpen attribute to true
      component.set("v.isModalOpen", true);
   },
  
   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   },
    editChildCases : function(component, event, helper) {
        component.set("v.isModalOpen", true);
        component.set("v.dummyData", component.get("v.data"));
    },
   submitDetails: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      event.stopPropagation();
      component.set("v.data", component.get("v.dummyData"));
       window.setTimeout(function(){
           component.set("v.isModalOpen", false);
           component.set("v.dummyData", null);
       },2000);
   },
    saveChildCases : function(component, event, helper) {
        $A.createComponent("c:LXC_CSM_OverlayLibraryModal", {},function(content, status) {
                               if (status === "SUCCESS") {
                                   var modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       header: "You are going to create '"+ component.get("v.data").length + "' Child Case, please confirm to proceed.",
                                       body: modalBody, 
                                       showCloseButton: false,
                                       closeCallback: function(ovl) {
                                           console.log('Overlay is closing');
                                       }
                                   }).then(function(overlay){
                                       console.log("Overlay is made");
                                   });
                               }
                           });
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        //component.set("v.spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
       // component.set("v.spinner", false);
    },
    
    onLOSChange: function(component, event, helper) {
        var record = component.get("v.parentCase");
        if (record != undefined){
            helper.getSubtype(component,1);
            if(record.RecordTypeName__c == 'ActivityPlan'){
                helper.getTemplate(component);
            }    
        }
    },

    onSubType1Change: function(component, event, helper) {
        helper.getSubtype(component,2);
    },
    onSubType2Change: function(component, event, helper) {
        helper.getSubtype(component,3);
    },

    handleApplicationEvent : function(component, event, helper) {
        var message = event.getParam("message");
        if(message == 'Ok' && component.get("v.data") != undefined)
        {
            component.set("v.spinner", true);
            helper.callServer(component, "c.insertChildCases",function(response){
                var columnLst = [];
                columnLst.push({ label: "Row No", fieldName: "Id", type: "number"});
                columnLst.push({ label: "Case Number", fieldName: "caseNumber", type: "text"});
                columnLst.push({ label: "Contact Name", fieldName: "contactName", type: "text"});
                columnLst.push({ label: "On Behalf Of", fieldName: "onBehalfOfName", type: "text"});
                columnLst.push({ label: "Site Name", fieldName: "siteName", type: "text"});
                columnLst.push({ label: "LOS", fieldName: "los", type: "text"});
                if(component.get("v.parentCase").RecordTypeName__c == 'ActivityPlan'){
                    columnLst.push({ label: "Template", fieldName: "template", type: "text"});
                }
                columnLst.push({ label: "Sub-Type1", fieldName: "subType1", type: "text"});
                columnLst.push({ label: "Sub-Type2", fieldName: "subType2", type: "text"});
                columnLst.push({ label: "Sub-Type3", fieldName: "subType3", type: "text"});
                if(component.get("v.parentCase").RecordTypeName__c == 'ActivityPlan'){
                    columnLst.push({ label: "Contact User Role", fieldName: "conUserRole", type: "text"});
                    columnLst.push({ label: "Site Assignment", fieldName: "siteAssignment", type: "text"});
                }
                if(component.get("v.parentCase").RecordTypeName__c == 'VirtualTrialsCase'){
                    columnLst.push({ label: "Subject ID", fieldName: "subjectId", type: "text"});  
                }
                component.set('v.columns', columnLst);
                component.set("v.data",response);
                component.set("v.buttonSDisable",true);
                helper.showToastmsg(component,"success","success", response.length + ' Child cases saved Successfully.');
                component.set("v.spinner", false);
            },{ caseId : component.get("v.caseId"), childData : JSON.stringify(component.get("v.data"))},true);
            
        }
        else if(message == 'Cancel')
        {
            // if the user clicked the Cancel button do your further Action here for canceling
        }
    },
    handleSiteAssignmentChange: function (component, event, helper) {
        //Get the Selected values   
        var selectedValues = event.getParam("value");
        //Update the Selected Values  
        component.set("v.selectedSiteAssignmentList", selectedValues);
        component.set("v.sltSiteAssignment", selectedValues.toString().replace(',', ';'));
    },
    
})