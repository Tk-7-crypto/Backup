({
	callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    errorMessage : function(cmp,title,severity,message){
        
        $A.createComponents([
            ["ui:message",{"title" : title,"severity" : severity,"closable" : "true","click":"{!c.handleClick}"}],
            ["ui:outputText",{"value" : message}]
        ],function(components, status, errorMessage){
           if (status === "SUCCESS") {
               var message = components[0];
               var outputText = components[1];
               message.set("v.body", outputText);
               cmp.set("v.message", components); 
               //var message = components[0];
                //var outputText = components[1];
                // set the body of the ui:message to be the ui:outputText
                //message.set("v.body", outputText);
                //var div1 = cmp.find("div1");
                // Replace div body with the dynamic component
               // div1.set("v.body", message);
            }else if (status === "INCOMPLETE") {
               console.log("No response from server or client is offline.")
               // Show offline error
            }else if (status === "ERROR") {
              console.log("Error: " + errorMessage);
              // Show error message
            }
            });
    },
    
    showToastmsg: function(cmp,title,variant,message){
        cmp.find('notifLib').showToast({
            "title": title,
            "variant":variant,         
            "message": message
        });
    },
    
    fetchData: function(component , rows){
        return new Promise($A.getCallback(function(resolve, reject) {
            var currentDatatemp = component.get('c.getPortalDataList');
            var counts = component.get("v.currentCount");
            currentDatatemp.setParams({
                "limits": component.get("v.initialRows"),
                "offsets": counts 
            });
            currentDatatemp.setCallback(this, function(a) {
                resolve(a.getReturnValue());
                var countstemps = component.get("v.currentCount");
                countstemps = countstemps+component.get("v.initialRows");
                component.set("v.currentCount",countstemps);
                
            });
            $A.enqueueAction(currentDatatemp);
            
            
        }));
        
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.filteredData");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.filteredData", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));

        }
    },
     
    preparePagination: function (component, imagesRecords) {
        let countTotalPage = Math.ceil(imagesRecords.length/component.get("v.pageSize"));
        let totalPage = countTotalPage > 0 ? countTotalPage : 1;
        component.set("v.totalPages", totalPage);
        component.set("v.currentPageNumber", 1);
        this.setPageDataAsPerPagination(component);
    },
 
    setPageDataAsPerPagination: function(component) {
        let data = [];
        let pageNumber = component.get("v.currentPageNumber");
        let pageSize = component.get("v.pageSize");
        let filteredData = component.get('v.filteredData');
        let x = (pageNumber - 1) * pageSize;
        for (; x < (pageNumber) * pageSize; x++){
            if (filteredData[x]) {
                data.push(filteredData[x]);
            }
        }
        component.set("v.tableData", data);
    },
    
})