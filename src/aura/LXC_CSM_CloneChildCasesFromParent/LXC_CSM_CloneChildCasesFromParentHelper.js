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
                        showToastmsg(component,"Warning","warning",errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    showToastmsg: function(cmp,title,variant,message){
        cmp.find('notifLib').showToast({
            "title": title,
            "variant":variant,         
            "message": message
        });
    },
    
    getControllingField: function (component) {
        var record = component.get("v.parentCase");
        var action = component.get("c.getCategorizationWithAggregate");
        var field = "LOS__c";
            action.setParams({
                "q": "select " + field + "  from CSM_QI_Case_Categorization__c where RecordTypeId__c='" + record.RecordTypeId + "' and Active__c=true group by " + field
            });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cfList = response.getReturnValue();
                var cfArray = [];
                cfArray.push({
                    class: "optionClass",
                    label: "Please Specify",
                    value: "Please Specify"
                })
                for (var i = 0; i < cfList.length; i++) {
                    var value = cfList[i].LOS__c;
                    
                    if (value != undefined) cfArray.push({ class: "optionClass", label: value, value: value });
                }
                component.set("v.losList", cfArray);
                this.getSubtype(component, 1);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    getSubtype: function (component, idx) {
        var record = component.get("v.parentCase");
        var currentControllingField;
        if (idx > 1) currentControllingField = "sltST" + (idx - 1);
        else currentControllingField = "sltLos";
        if (component.get("v."+currentControllingField) != "Please Specify") {
            var q = "";
            var c = "";
            if (idx > 1) {
                for (var j = 1; j < idx; j++) {
                    c += " and SubType" + j + "__c='" + component.find("selectSubType" + j).get("v.value") + "'";
                }
            }
            var controllingField = component.find("selectLos").get("v.value");
            q = "select SubType" + idx + "__c  from CSM_QI_Case_Categorization__c where RecordTypeId__c='" + record.RecordTypeId + "' and Active__c=true and LOS__c ='" + controllingField + "'" + c + " group by SubType" + idx + "__c"
            var action = component.get("c.getCategorizationWithAggregate");
            action.setParams({
                "q": q
            });
            action.setCallback(this, function (response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    var subtypeList = response.getReturnValue();
                    var subtypeArray = [];
                    var subtype;
                    
                    
                    for (var i = 0; i < subtypeList.length; i++) {
                        subtype = subtypeList[i]["SubType" + idx + "__c"];
                        if (subtype != undefined) subtypeArray.push({ class: "optionClass", label: subtype, value: subtype });
                        else subtypeArray.push({ class: "optionClass", label: "none", value: "Please Specify" });
                    }

                     for (var i = 0; i < subtypeArray.length; i++) {
                        if (subtypeArray[i].value === "Please Specify") {
                            subtypeArray.unshift(subtypeArray[i]);
                            subtypeArray.splice(i + 1, 1);
                        }
                    }
                    if(subtypeArray != undefined && subtypeArray.length == 0){
                     subtypeArray.push({ class: "optionClass", label: "Please Specify", value: "Please Specify" });
                     //component.find("subType" + idx).set("v.value", "Please Specify");   
                    }

                    component.set("v.sType"+idx+"List", subtypeArray);

                    if (idx < 3) this.getSubtype(component, idx + 1);
                    else component.set("v.isLoading", false);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log(errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.sType"+idx+"List", { class: "optionClass", label: "Please Specify", value: "Please Specify" });
            if (idx < 3) this.getSubtype(component, idx + 1);
            else component.set("v.isLoading", false);
        }
    },

    getTemplate: function (component) {
        var controllerValueKey = component.find("selectLos").get("v.value");
        var Map = component.get("v.dependentFieldMap");
        if (controllerValueKey != 'Please Specify') {
            var ListOfDependentFields = Map[controllerValueKey];
            this.fetchDepValues(component, ListOfDependentFields);
        } else {
            var defaultVal = [{
                class: "optionClass",
                label: 'Please Specify',
                value: 'Please Specify'
            }];
            component.set("v.templateList", defaultVal);
            //component.set("v.isDependentDisable", true);
        }
        //var record = component.get("v.simpleRecord");
       // if (record.Template__c) component.find("template").set("v.value", record.Template__c);
    },
    
    fetchDepValues: function (component, ListOfDependentFields) {
        var dependentFields = [];

        if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
            dependentFields.push({
                class: "optionClass",
                label: "Please Specify",
                value: "Please Specify"
            });
            
            for (var i = 0; i < ListOfDependentFields.length; i++) {
                dependentFields.push({
                    class: "optionClass",
                    label: ListOfDependentFields[i],
                    value: ListOfDependentFields[i]
                });
            }
            component.set("v.templateList", dependentFields);
            
        }
    },
    
    fetchPicklistValues: function (component, controllerField, dependentField) {
        var action = component.get("c.getDependentOptionsImpl");
        action.setParams({
            'objApiName': "Case",
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var StoreResponse = response.getReturnValue();
                component.set("v.dependentFieldMap", StoreResponse);
                var listOfkeys = [];
                var ControllerField = [];

                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }

                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push({
                        class: "optionClass",
                        label: "Please Specify",
                        value: "Please Specify"
                    });
                }

                this.getTemplate(component);
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push({
                        class: "optionClass",
                        label: listOfkeys[i],
                        value: listOfkeys[i]
                    });
                }
            }
        });
        $A.enqueueAction(action);
    },
})