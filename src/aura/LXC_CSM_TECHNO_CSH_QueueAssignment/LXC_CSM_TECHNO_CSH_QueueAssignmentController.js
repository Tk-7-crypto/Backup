({
    doInit : function(component, event, helper) {
        
         var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Queue Assignment"
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
        
        helper.callServer(component, "c.getAccountCountryList",function(response){
            var countryList = [];
            
            for (var i=0; i<response.length; i++) {
                countryList.push({
                    name: response[i].label,
                    value: response[i].value
                });
                
            }
            
            component.set('v.accCountryList',countryList);
        },null,true);
        helper.callServer(component, "c.getContactUserTypeList",function(response){
            var userTypeList = [];
            
            for (var i=0; i<response.length; i++) {
                userTypeList.push({
                    name: response[i].label,
                    value: response[i].value
                });
                
            }
            component.set('v.conUserTypeList',userTypeList);
        },null,true);
        
        helper.callServer(component, "c.getTechnoQueueList",function(response){
            var queueList = [];
            
            for (var i=0; i<response.length; i++) {
                queueList.push({
                    name: response[i].Name,
                    value: response[i].Id
                });
                
            }
            
            component.set('v.queueNameList',queueList);
        },null,true);
        
        helper.callServer(component, "c.getTotalNoOfRows",function(response){
            component.set("v.totalNumberOfRows", response);
        },null,true);
        
       helper.callServer(component, "c.getPortalDataList",function(response){
           component.set("v.columns", response.lstDataTableColumns);
           component.set("v.searchList", response.lstDataTableColumns);
           component.set("v.data", response.lstDataTableData);
           component.set("v.filteredData", response.lstDataTableData);
           helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
           helper.preparePagination(component, response.lstDataTableData);
       },null,true);        
    },
    
    selectAccounts : function(component, event, helper){
        var  country = component.get("v.sltCountry");
        if(country != undefined && country !==""){
            helper.callServer(component, "c.getAllCustomerPortalAccountList",function(response){
                var accList = [];
                var accountName ;
                for (var i=0; i<response.length; i++) {
                    if( response[i].Name != undefined && response[i].MDMID__c != undefined){
                        accountName =  response[i].Name +' - ' + response[i].MDMID__c;
                    }else if(response[i].Name != undefined){
                        accountName =  response[i].Name;
                    }
                    
                    accList.push({
                        name: accountName,
                        value: response[i].Id
                    });
                    
                }
                
                component.set('v.accNameList',accList);
                //component.set('v.isDefaultAcc',false);
            },{"accCountry" : country},true);    
        }else{
            component.set('v.accNameList',null);
        }
        
    },
    
    selectProducts : function(component, event, helper){
        var  sltAccount = component.get("v.sltAccount");
        
        if(sltAccount != undefined && sltAccount !==""){
            helper.callServer(component, "c.getAccountProductList",function(response){
                var productList = [];
                for (var i=0; i<response.length; i++) {
                    if(response[i].Name != undefined){
                        productList.push({
                            name: response[i].Name,
                            value: response[i].Name
                        });    
                    }
                }
                
                component.set('v.accProductList',productList);
                //component.set('v.isDefaultAcc',false);
                /** helper.callServer(component, "c.getDefaultAccountQueueConfig",function(response){
                    component.set('v.checkDefaultQueue',response);
                    if(response.includes('TechnologyCase') || response.includes('DATACase')){
                        component.set('v.isDefaultAcc',true);
                        helper.showToastmsg(component,"Warning","warning", "Please configure the default queue for "+response +" record type");
                        component.set('v.message',"Please configure the default queue for "+response +" record type");
                    }else{
                        component.set('v.isDefaultAcc',false);
                    }
                    
                },{"accId" : sltAccount, "country" : component.get("v.sltCountry")},true);*/
                
            },{"accId" : sltAccount},true);
            
        }else{
            component.set('v.accProductList',null);
        }
        
    },
    
    selectCSHSubtypes : function(component, event, helper){
        
        var  sltProduct = component.get("v.sltProduct");
        if(sltProduct != undefined && sltProduct !==""){
            helper.callServer(component, "c.getCSHSubtypeList",function(response){
                var subtypeList = [];
                for (var i=0; i<response.length; i++) {
                    if(response[i].CSHSubType__c != undefined && response[i].CSHSubType__c != "Please Specify"){
                        subtypeList.push({
                            name: response[i].CSHSubType__c,
                            value: response[i].CSHSubType__c
                        }); 
                    }
                }
                
                component.set('v.cshSubtypeList',subtypeList);
                
            },{"productId" : sltProduct},true);
        }else{
            component.set('v.cshSubtypeList',null);
        }
    },
    
    addRecords : function(component, event, helper){
        var  sltcountry = component.get("v.sltCountry");
        var  sltAccount = component.get("v.sltAccount");
        var  sltUserType = component.get("v.sltUserType");
        var  sltProduct = component.get("v.sltProduct");
        var  sltsubType = component.get("v.sltSubtype");
        var  sltQueue = component.get("v.sltQueue");
        if(sltcountry != undefined && sltcountry !=="" && sltAccount != undefined && sltAccount !=="" && sltQueue != undefined && sltQueue !==""){
            helper.callServer(component, "c.addtoCSMDataPortal",function(response){
                if(response.startsWith('Warning')){
                    try {
                        throw new Error("Combinations already exist.");
                    }catch (e) {
                        helper.showToastmsg(component,"Warning","warning",e.message);
                    }
                }else if(response.startsWith('Error')){
                    try {
                        throw new Error("Record not saved.");
                    }catch (e) {
                        helper.showToastmsg(component,"Error","error",e.message);
                    }
                }else if(response.startsWith('Success')){
                    helper.callServer(component, "c.getPortalDataList",function(response){
                        component.set("v.columns", response.lstDataTableColumns);
                        component.set("v.searchList", response.lstDataTableColumns);
                        component.set("v.data", response.lstDataTableData);
                        component.set("v.filteredData", response.lstDataTableData);
                        helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
                        helper.showToastmsg(component,"Success","info","Record saved succesfully");
                        component.set("v.sltCountry","");
                        component.set("v.sltAccount","");
                        component.set("v.sltUserType","");
                        component.set("v.sltProduct","");
                        component.set("v.sltSubtype","");
                        component.set("v.sltQueue","");
                    },null,true);    
                }
                        
            },{"country" : sltcountry ,"accId" : sltAccount,"product" : sltProduct, "subtype" : sltsubType, "queue": sltQueue, "userType" : sltUserType },true);
        }else{
            var message='Please select';
            if(sltcountry == undefined || sltcountry ==="")
                message+=' Country,';
                if(sltAccount == undefined || sltAccount ==="")
                message+=' Account,';
                if(sltQueue == undefined || sltQueue ==="")
                message+=' Queue,';
            
            helper.showToastmsg(component,"Error","error", message.substring(0,message.length-1));
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
                component.set('v.filteredData', rows);
                helper.preparePagination(component, rows);
                break;
        }  
    },
    loadMoreData: function (component, event, helper) {
        //Display a spinner to signal that data is being loaded
        event.getSource().set("v.isLoading", true);
        //Display "Loading" when more data is being loaded
        component.set('v.loadMoreStatus', 'Loading');
        helper.fetchData(component, component.get('v.rowsToLoad')).then($A.getCallback(function (data) {
            if (component.get('v.data').length >= component.get('v.totalNumberOfRows')) {
                component.set('v.enableInfiniteLoading', false);
                component.set('v.loadMoreStatus', 'No more data to load');
            } else {
                var currentData = component.get('v.data');
                //Appends new data to the end of the table
                var newData = currentData.concat(data);
                component.set('v.data', newData);
                component.set('v.loadMoreStatus', 'Please wait ');
            }
            event.getSource().set("v.isLoading", false);
        }));
    },
     
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.spinner", true); 
    },
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.spinner", false);
    },
    handleClick:function(component,event,helper){
        
    },
    filter: function(component, event, helper) {
        var data = component.get("v.data"),
            term = component.get("v.filter"),
            results = data, regex;
        var searchField = component.get("v.sltField");
        
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            if(searchField != undefined){
                if(searchField == "AccountCountry__c"){
                    results = data.filter(row=>regex.test(row.AccountCountry__c));    
                }else if(searchField == "AccountName__c"){
                    results = data.filter(row=>regex.test(row.AccountName__c));    
                }else if(searchField == "Contact_User_Type__c"){
                    results = data.filter(row=>regex.test(row.Contact_User_Type__c));    
                }else if(searchField == "Product__c"){
                    results = data.filter(row=>regex.test(row.Product__c));    
                }else if(searchField == "CSH_Sub_Type__c"){
                    results = data.filter(row=>regex.test(row.CSH_Sub_Type__c));    
                }else if(searchField == "QueueName__c"){
                    results = data.filter(row=>regex.test(row.QueueName__c));    
                }
                    
            }else{
                results = data.filter(row=>regex.test(row.AccountCountry__c) || regex.test(row.Product__c.toString()));    
            }
            
        } catch(e) {
            // invalid regex, use full list
        }
        component.set("v.filteredData", results);
        helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
        helper.preparePagination(component, results);
    },
    updateColumnSorting : function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    enableSearch : function(cmp, event, helper){
        var isSearch = cmp.get("v.isSearch");
        if(isSearch){
            $A.util.removeClass(cmp.find("btnsearch"), "slds-button_brand");
            cmp.set("v.isSearch",false);
            if(cmp.get("v.filter") != undefined){
                cmp.set("v.filter","");
                cmp.set("v.sltField","PleaseSpecify");
                cmp.set("v.filteredData", cmp.get("v.data"));    
            }
        }else{
            cmp.set("v.isSearch",true);
            $A.util.addClass(cmp.find("btnsearch"), "slds-button_brand");
        } 
            
    },
    
    onNext: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber + 1);
        helper.setPageDataAsPerPagination(component);
    },
     
    onPrev: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber - 1);
        helper.setPageDataAsPerPagination(component);
    },
     
    onFirst: function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.setPageDataAsPerPagination(component);
    },
     
    onLast: function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.setPageDataAsPerPagination(component);
    },
 
    onPageSizeChange: function(component, event, helper) {        
        helper.preparePagination(component, component.get('v.filteredData'));
    },
    
})