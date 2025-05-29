({
    fetchPickListVal: function(component, fieldName, elementId) {
        var action = component.get("c.getSelectOptions");
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fieldName": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                if (allValues != undefined && allValues.length > 0) {
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }  
                }                
                component.find(elementId).set("v.options", opts);
            }
        });
        $A.enqueueAction(action);
    },
    fetchOptionValueSet: function(component, elementId) {  
        var opts = [];
        var action = component.get("c.getValueSet");
        action.setParams({
            sale: component.find("sales2").get("v.value"),
            role: component.find("myRole2").get("v.value")
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--None--",
                        value: "None"
                    });  
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }  
                    component.set("v.showAccountCountrySales",true);
                    component.find(elementId).set("v.options", opts);
                }else{
                    component.set("v.showAccountCountrySales",false); 
                }   
                component.find('0-5Name').set("v.value", '');
                component.find('5-10Name').set("v.value", '');
                component.find('10-20Name').set("v.value", '');
                component.find('20-50Name').set("v.value", '');
                component.find('50+Name').set("v.value", '');
                component.find('0-5Mail').set("v.value", '');
                component.find('5-10Mail').set("v.value", '');
                component.find('10-20Mail').set("v.value", '');
                component.find('20-50Mail').set("v.value", '');
                component.find('50+Mail').set("v.value", '');
            }
        });
        $A.enqueueAction(action);
    },
    onCustomerChanges : function(component) {
        component.find('0-5Name').set("v.value", '');
        component.find('5-10Name').set("v.value", '');
        component.find('10-20Name').set("v.value", '');
        component.find('20-50Name').set("v.value", '');
        component.find('50+Name').set("v.value", '');
        component.find('0-5Mail').set("v.value", '');
        component.find('5-10Mail').set("v.value", '');
        component.find('10-20Mail').set("v.value", '');
        component.find('20-50Mail').set("v.value", '');
        component.find('50+Mail').set("v.value", '');
        if(component.find("accountCountrySales").get("v.value") != 'None')
        {
            var opts = [];
            var action = component.get("c.getCustomerValues"); 
            action.setParams({
                sale: component.find("sales2").get("v.value"),
                role: component.find("myRole2").get("v.value"),
                customer: component.find("accountCountrySales").get("v.value")
            });
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {    
                    var customerValue = response.getReturnValue();
                    component.find('0-5Name').set("v.value", customerValue[0]);
                    component.find('5-10Name').set("v.value", customerValue[0]);
                    component.find('10-20Name').set("v.value", customerValue[0]);
                    component.find('20-50Name').set("v.value", customerValue[0]);
                    component.find('50+Name').set("v.value", customerValue[0]);
                    component.find('0-5Mail').set("v.value", customerValue[1]);
                    component.find('5-10Mail').set("v.value", customerValue[1]);
                    component.find('10-20Mail').set("v.value", customerValue[1]);
                    component.find('20-50Mail').set("v.value", customerValue[1]);
                    component.find('50+Mail').set("v.value", customerValue[1]);
                }
            });
            $A.enqueueAction(action); 
        } 
    },
    fetchApprovalMatrixData: function(component, event, helper) {
        component.set("v.showSpinner",true);
        var approverGroupValue = component.get("v.approverGroupName");
        var opportunityType = component.find("myOpportunityType").get("v.value");
        var customerType = component.find("myCustomerType").get("v.value");
        var role = component.find("myRole").get("v.value");
        var customerEmail;
        var therapyArea;
        var region;        
        var sales;
        var md;
        var customer;
        var globalProjectUnit;
        if (customerType == 'X0_5M_USD__c')
            customerEmail = 'X0_5M_USD_Email__c';
        else if (customerType == 'X5_10M_USD__c')
            customerEmail = 'X5_10M_USD_Email__c';
        else if (customerType == 'X10_20M_USD__c')
            customerEmail = 'X10_20M_USD_Email__c';
        else if (customerType == 'X20_50M_USD__c')
            customerEmail = 'X20_50M_USD_Email__c';
        else
            customerEmail = 'X50M_USD_Email__c';
        if(approverGroupValue == 'tssu'){
            therapyArea = component.find("therapyArea").get("v.value");
            region = component.find("region").get("v.value");
            sales = 'test';
            md = 'test';
            customer = 'test';
            globalProjectUnit = 'test';
        }
        else if (approverGroupValue == 'pl'){
            therapyArea = component.find("therapyArea").get("v.value");
            region ='test';
            sales = 'test';
            md = 'test';
            customer = 'test';
            globalProjectUnit= component.find("globalProjectUnit").get("v.value");
        }
        else if (approverGroupValue == 'plCustomer'){
            therapyArea = component.find("therapyArea").get("v.value");
            region ='test';
            sales = 'test';
            md = 'test';
            customer = component.find("customer").get("v.value");
            globalProjectUnit= 'test';
        }
        else {            
            sales = component.find("sales").get("v.value");
            region = component.find("region").get("v.value");
            md = component.find("md").get("v.value");
            therapyArea = 'test';
            customer = 'test';
            globalProjectUnit= 'test';
        }
        component.set('v.customerName', customerType);
        var action = component.get("c.getApproverGroups");
        action.setParams({
            approverGroupName : approverGroupValue,
            opportunityType : opportunityType,
            customerType : customerType,
            therapyArea : therapyArea,
            region : region,
            role :  role,
            sales : sales,
            md : md,
            customerEmail : customerEmail,
            globalProjectUnit : globalProjectUnit,
            customer : customer
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {				               
                var returnValue = response.getReturnValue();
                component.set("v.ApprovalMatrixWithKeyWrapper", returnValue);
                component.set("v.showSpinner",false);
                component.set("v.isDeleteButtonDisable",true);
                component.set("v.isSaveButtonDisable",true);               
            }
        });
        $A.enqueueAction(action);
    }
})