({
    fetchPicklistValues : function(component) {
        var action = component.get("c.getDependentOptionsImpl");
        
        action.setParams({
            'objApiName' : "CDA_Request__c",
            'contrfieldApiName' : "QuintilesIMS_Business__c",
            'depfieldApiName' : "CDA_Type__c"
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var depnedentFieldMap = response.getReturnValue();
                
                component.set("v.depnedentFieldMap", depnedentFieldMap);
                
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on ui field. 
                
                for (var singlekey in depnedentFieldMap) {
                    listOfkeys.push(singlekey);
                }                
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push({
                        class: "optionClass",
                        label: "--None--",
                        value: "--None--"
                    });
                }                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push({
                        class: "optionClass",
                        label: listOfkeys[i],
                        value: listOfkeys[i]
                    });
                }
                //component.find('conCountry').set("v.options", ControllerField);
                component.set("v.iqviaBusinessPicklistValues", ControllerField);                
            }
        });
        $A.enqueueAction(action);
    }, 
    
    fetchDepValues: function(component, ListOfDependentFields) {
      var dependentFields = [];
 
      if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
         dependentFields.push({
            class: "optionClass",
            label: "--None--",
            value: "--None--"
         });
 
      }
      for (var i = 0; i < ListOfDependentFields.length; i++) {
         dependentFields.push({
            class: "optionClass",
            label: ListOfDependentFields[i],
            value: ListOfDependentFields[i]
         });
      }
      //component.find('conState').set("v.options", dependentFields);
      component.set("v.cdaTypePicklistValues", dependentFields);
      component.set("v.isDependentDisable", false);
   },
})