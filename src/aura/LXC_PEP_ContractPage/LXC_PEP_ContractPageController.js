({
    doInit: function(component, event, helper) {
        var idParam = component.get("v.recordId");
        var action = component.get("c.getrelatedContractId");
        action.setParams({"contractId":idParam});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var concatenatefields = response.getReturnValue();
                var str_array = concatenatefields.split(';');
                for(var i = 0; i < str_array.length; i++) {
                    var paymentmethod = str_array[0];
                    var sowstatus = str_array[1];
                    var notificationCounter=str_array[2];
                    var newContractNumber=str_array[3];
                    var isNonStandard=str_array[4];
                    var renewalStatus=str_array[5];
                    console.log(renewalStatus);
                    console.log(sowstatus);
                    console.log(paymentmethod);
                    if(paymentmethod != "null"){
                        component.set("v.Payment_method", paymentmethod);
                    }else{
                        component.set("v.isModalOpen", true);
                        component.set("v.Payment_method", 'null');
                    }
                    if(sowstatus != null){
                        component.set("v.SOW_status", sowstatus);
                    }
                    if(notificationCounter!=null)
                    {
                        if(notificationCounter>1 && notificationCounter<5)
                        {                     
                            component.set("v.showRenewButton", true);
                        }
                    }
                    if(isNonStandard=="true")
                    {
                        component.set("v.nonStandardContract", true);
                    }
                    if(renewalStatus != null){
                        component.set("v.renewalStatus", renewalStatus);   
                    }else{
                        component.set("v.renewalStatus", 'null');
                    }
                    if((renewalStatus =="Renewal Requested" || renewalStatus =="Renewal Contracting") && isNonStandard=='true'){
                        var cmpTarget = component.find('Modalbox6');
                        var cmpBack = component.find('Modalbackdrop');
                        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
                        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
                    }

                    console.log('Is non Standard?: '+ component.get("v.nonStandardContract") + ' '+isNonStandard);
                    console.log('paymentmethod: '+ component.get("v.Payment_method"));
                    console.log('sowstatus: '+ component.get("v.SOW_status"));
                    break;
                }
            }
        });
        $A.enqueueAction(action);
    },
                           
    signSOW: function(component, event, helper) {
        var idParam = component.get("v.recordId");
        var hasPerm = false;
        
        var haspaymentmethod = false;
        if(component.get("v.Payment_method") != null){
            var paymentmethod = component.get("v.Payment_method");
            haspaymentmethod = true;
        }
        
        if(component.get("v.SignSOW_online") != null){
            hasPerm = true;
        }
        
        try {
            if (!hasPerm) {
                throw new Error("Please select signing method.");
            }
            if (!haspaymentmethod) {
                throw new Error("A payment method should be selected.");
            }
        }
        catch (e) {
            $A.createComponents([
                ["ui:message",{
                    "severity" : "error",
                }],
                ["ui:outputText",{
                    "value" : e.message
                }]
            ],
                                function(components, status, errorMessage){
                                    if (status === "SUCCESS") {
                                        var message = components[0];
                                        var outputText = components[1];
                                        // set the body of the ui:message to be the ui:outputText
                                        message.set("v.body", outputText);
                                        var div3 = component.find("div3");
                                        // Replace div body with the dynamic component
                                        div3.set("v.body", message);
                                    }
                                }
                               );
        }
        if (hasPerm && haspaymentmethod) {
            var signSOW_online = component.get("v.SignSOW_online");
            var action = component.get("c.getContractId");
            action.setParams({"contractId":idParam , "signSOW_online":signSOW_online});
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS" && signSOW_online != "False") {
                    var cmpTarget = component.find('Modalbox2');
                    var cmpBack = component.find('Modalbackdrop');
                    $A.util.removeClass(cmpBack,'slds-backdrop--open');
                    $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
                    var docuSignURL = response.getReturnValue();
                    console.log('docuSignURL--------'+docuSignURL);
                    window.open(docuSignURL,'_top');
                }else{
                    try {
                            throw new Error("An email has been sent to your email address.");
                    }
                    catch (e) {
                        $A.createComponents([
                            ["ui:message",{
                                "severity" : "error",
                            }],
                            ["ui:outputText",{
                                "value" : e.message
                            }]
                        ],
                                            function(components, status, errorMessage){
                                                if (status === "SUCCESS") {
                                                    var message = components[0];
                                                    var outputText = components[1];
                                                    // set the body of the ui:message to be the ui:outputText
                                                    message.set("v.body", outputText);
                                                    var div3 = component.find("div3");
                                                    // Replace div body with the dynamic component
                                                    div3.set("v.body", message);
                                                    var proceedButton= component.find("proceedButton");
                                                    var cancelButton= component.find("cancelButton");
                                                    var closeButton= component.find("closeButton");
                                                    $A.util.addClass(proceedButton, "invisible");
                                                    $A.util.addClass(cancelButton, "invisible");
                                                    $A.util.removeClass(closeButton, "slds-hide");
                                                }
                                            }
                                           );
                    }
                    
                    
                }    
            });
            $A.enqueueAction(action);
        }     
    },
    //PO Number Submit click button
    addPONum: function(component, event, helper) {
        var hasPerm = false;        
        if(component.get("v.PONumber") != null){
            var poNumber = component.get("v.PONumber");
            // PO number validation
            if(/^[a-zA-Z0-9][-\s\./a-zA-Z0-9]+$/.test(poNumber)){
                component.set("v.simpleRecord.PO_Number__c", poNumber);
                hasPerm = true;
            }
            
        }
        
        // this sample always throws an error to demo try/catch
        try {
            if (!hasPerm) {
                throw new Error("Please enter a valid PO Number.");
            }
        }
        catch (e) {
            $A.createComponents([
                ["ui:message",{
                    "severity" : "error",
                }],
                ["ui:outputText",{
                    "value" : e.message
                }]
            ],
                                function(components, status, errorMessage){
                                    if (status === "SUCCESS") {
                                        var message = components[0];
                                        var outputText = components[1];
                                        // set the body of the ui:message to be the ui:outputText
                                        message.set("v.body", outputText);
                                        var div2 = component.find("div2");
                                        // Replace div body with the dynamic component
                                        div2.set("v.body", message);
                                    }
                                }
                               );
        }
        
        if (hasPerm) {
            component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    console.log("Save completed successfully.");
                    var div2 = component.find("div2");
                    div2.set("v.body", " ");
                    
                    var cmpTarget = component.find('Modalbox3');
                    var cmpBack = component.find('Modalbackdrop');
                    $A.util.removeClass(cmpBack,'slds-backdrop--open');
                    $A.util.removeClass(cmpTarget, 'slds-fade-in-open');                
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    console.log('Problem saving record, error: ' + 
                                JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            })); 
        }    
    },
    newPopup : function(component, event, helper){
        var cmpTarget = component.find('Modalbox1');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    newPopup2 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox2');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
        var div3 = component.find("div3");
        div3.set("v.body", "");
        var proceedButton= component.find("proceedButton");
        var cancelButton= component.find("cancelButton");
        var closeButton= component.find("closeButton");
        $A.util.removeClass(proceedButton, "invisible");
        $A.util.removeClass(cancelButton, "invisible");
        $A.util.addClass(closeButton, "slds-hide");
    },
    newPopup3 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox3');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    newPopup4 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox4');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    
    newPopup5 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox5');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    newPopup6 : function(component, event, helper){		
        var cmpTarget = component.find('Modalbox6');		
        var cmpBack = component.find('Modalbackdrop');		
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');		
        $A.util.addClass(cmpBack, 'slds-backdrop--open');		
    },
    onGroup: function(component, event, helper) {
        var selected = event.getSource().get("v.text");
        console.log('selected onGroup----------------'+selected);
        if(selected === "Invoice – I will issue a PO"){
            selected = "Invoice – with PO";
        }        
        component.set("v.Paymentsave_method", selected);
    },
    onSelectSOW: function(component, event, helper) {
        var selected = event.getSource().get("v.text");
        
        if(selected == "Sign Now"){
            selected = "True";
        }else if (selected == "Email me the SOW"){
            selected = "False";
        }        
        component.set("v.SignSOW_online", selected);
    },
    //Payment method Submit click button
    saveModal : function(component){
        var hasPerm = false;
        if(component.get("v.Paymentsave_method") != null){
            hasPerm = true;
        }
        
        // this sample always throws an error to demo try/catch
        try {
            if (!hasPerm) {
                throw new Error("Please select payment method.");
            }
        }
        catch (e) {
            $A.createComponents([
                ["ui:message",{
                    "severity" : "error",
                }],
                ["ui:outputText",{
                    "value" : e.message
                }]
            ],
                                function(components, status, errorMessage){
                                    if (status === "SUCCESS") {
                                        var message = components[0];
                                        var outputText = components[1];
                                        // set the body of the ui:message to be the ui:outputText
                                        message.set("v.body", outputText);
                                        var div1 = component.find("div1");
                                        // Replace div body with the dynamic component
                                        div1.set("v.body", message);
                                    }
                                }
                               );
        }
        
        if (hasPerm) {
            var paymentmethod = component.get("v.Paymentsave_method");
            component.set("v.Payment_method", paymentmethod);
            component.set("v.simpleRecord.Payment_method__c", paymentmethod);
            component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    console.log("Save completed successfully.");
                    var div1 = component.find("div1");
                    div1.set("v.body", " ");
                    
                    var cmpTarget = component.find('Modalbox1');
                    var cmpBack = component.find('Modalbackdrop');
                    $A.util.removeClass(cmpBack,'slds-backdrop--open');
                    $A.util.removeClass(cmpTarget, 'slds-fade-in-open');                
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    console.log('Problem saving record, error: ' + 
                                JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            }));
        }
        $A.enqueueAction(component.get('c.newPopup2'));
    },
    closeNewModal : function(component, event, helper){
        var cmpTarget = component.find('Modalbox1');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    closeNewModal2 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox2');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    closeNewModal3 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox3');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    closeNewModal4 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox4');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    
    closeNewModal5 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox5');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    
    closeNewModal6 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox6');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    renewContract : function(component, event, helper) {
        console.log('in func');
        var contractId = component.get("v.recordId");
        var action = component.get("c.renewContractController");    
        action.setParams({"contractId":contractId});
        action.setCallback(this, function(response){
            console.log('in callback');
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('in success');
                var ContractId = response.getReturnValue();
                var currentURL=window.location.href;
                var substrURL=currentURL.substr(0,currentURL.indexOf('contract/'));
                window.open(substrURL+'contract/'+ContractId,'_top');
                console.log(window.location.href);
            }  
            else{console.log('else');}
        });
        $A.enqueueAction(action);
    },
    renewNonStandardContract : function(component, event, helper) {
        console.log('in func');
        var contractId = component.get("v.recordId");
        var action = component.get("c.renewNonStandardContractController");    
        action.setParams({"contractId":contractId});
        console.log(contractId);
        action.setCallback(this, function(response){
            console.log('in callback');
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('in success');
               // var ContractId = response.getReturnValue();
                var currentURL=window.location.href;
                var substrURL=currentURL.substr(0,currentURL.indexOf('contract/'));
                window.open(substrURL+'contract/'+contractId,'_top');
            }  
            else{console.log('else');}
        });
        $A.enqueueAction(action);
    },
    
        redirectToChildContract : function(component, event, helper) {
        console.log('in func');
        var contractId = component.get("v.recordId");
        var action = component.get("c.getChildContract");    
        action.setParams({"contractId":contractId});
        console.log(contractId);
        action.setCallback(this, function(response){
            console.log('in callback');
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('in success');
                var childContractId = response.getReturnValue();
                var currentURL=window.location.href;
                var substrURL=currentURL.substr(0,currentURL.indexOf('contract/'));
                window.open(substrURL+'contract/'+childContractId,'_top');
            }  
            else{console.log('else');}
        });
        $A.enqueueAction(action);
    },
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    }
})