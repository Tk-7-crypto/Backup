({
    
    getEmailMessages : function(component, event, recordIdValue) {
        var action = component.get("c.getEmailMessages");
        action.setParams({
            "recordIdValue" : recordIdValue
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.emailMessageRecord", response.getReturnValue()[0]);
                component.set("v.caseRecordTypeId", response.getReturnValue()[0].ParentId);
                var subTab = component.get("v.emailMessageRecord.Subject");
                var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        if(subTab !=null){
                            workspaceAPI.setTabLabel({
                                tabId: focusedTabId,
                                label: subTab //set label you want to set
                            });
                        }
                        else{
                            workspaceAPI.setTabLabel({
                                tabId: focusedTabId,
                                label: 'Email' //set label you want to set
                            });
                        }
                        workspaceAPI.setTabIcon({
                            tabId: focusedTabId,
                            icon: "standard:email",
                            iconAlt: "Email"
                        });
                    })
                this.getParentDetails(component, event);
            }
            else if(state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError()[0].message,
                    "type": "error"
                });
                toastEvent.fire();
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getParentDetails : function(component, event){
        var action = component.get("c.getParentDetails");
        action.setParams({
            "parentId" : component.get("v.caseRecordTypeId")
        });
        action.setCallback(this, function(response){
            var returnArray = response.getReturnValue()[0];
            if(returnArray != null && returnArray != '' && returnArray != undefined){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.los", response.getReturnValue()[0].LOS__c);
                    component.set("v.recordTypeId", response.getReturnValue()[0].RecordTypeName__c);
                    component.set("v.caseId", response.getReturnValue()[0].Id);
                    component.set("v.currentQueue", response.getReturnValue()[0].CurrentQueue__c);
                    component.set("v.caseNumber", response.getReturnValue()[0].CaseNumber);
                    component.set("v.caseUrl", "/lightning/r/"+response.getReturnValue()[0].Id+"/view");
                    component.set("v.fromEmailToCase", response.getReturnValue()[0].From_EmailToCase__c);
                    this.getUserDetails(component, event);
                    this.getQueueRelatedEmailAddress(component, event);
                }
                else if(state === "ERROR"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": response.getError()[0].message,
                        "type": "error"
                    });
                    toastEvent.fire();
                    component.set("v.isLoading", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getUserDetails : function(component, event){
        var action = component.get("c.getUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
            }else if(state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError()[0].message,
                    "type": "error"
                });
                toastEvent.fire();
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getQueueRelatedEmailAddress : function(component, event){
        var self = this;
        var action = component.get("c.getQueueRelatedEmailAddress");
        action.setParams({
            "LOS" : component.get("v.LOS"),
            "recordTypeId" : component.get("v.recordTypeId"),
            "currentQueue" : component.get("v.currentQueue")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.subject", component.get("v.emailMessageRecord").Subject);
                component.set("v.bodyText", "<br/><br/><br/>----------Original Message----------<br/>"+component.get("v.emailMessageRecord").HtmlBody);
                if(component.get("v.emailMessageRecord").Incoming)
                    component.set("v.toAddress", component.get("v.emailMessageRecord").FromAddress);
                else
                    component.set("v.toAddress", component.get("v.emailMessageRecord").ToAddress);
                if(component.get("v.emailMessageRecord").BccAddress != null && !component.get("v.userInfo").EmailPreferencesAutoBcc)
                    component.set("v.bccAddress", component.get("v.emailMessageRecord").BccAddress);
                else if(component.get("v.emailMessageRecord").BccAddress != null && component.get("v.userInfo").EmailPreferencesAutoBcc){
                    var bccaddress = component.get("v.emailMessageRecord").BccAddress;
                    if( bccaddress.indexOf(component.get("v.userInfo").Email) == -1)
                        component.set("v.bccAddress", component.get("v.emailMessageRecord").BccAddress+";"+component.get("v.userInfo").Email);
                    else
                        component.set("v.bccAddress", component.get("v.emailMessageRecord").BccAddress);
                }
                else if(component.get("v.emailMessageRecord").BccAddress == null && component.get("v.userInfo").EmailPreferencesAutoBcc)
                    component.set("v.bccAddress", component.get("v.userInfo").Email);
                
                if(component.get("v.emailMessageRecord").CcAddress != null)
                    component.set("v.ccAddress", component.get("v.emailMessageRecord").CcAddress);
                
                var options = [];
                options.push({
                    label : "Please specify",
                    value : ""
                });
                var fromAddresses = response.getReturnValue();
                if(fromAddresses != undefined && fromAddresses.length > 0){
                    for(var index=0; index<fromAddresses.length; index++){
                        var addressText = fromAddresses[index].Queue_Emails_Text__c;
                        if(addressText.indexOf(';')>0){
                            addressText.split(';').forEach(function(address){
                                options.push({
                                    label : address.trim(),
                                    value : address.trim()
                                });
                            });
                        }
                        else{
                            options.push({
                                label : addressText,
                                value : addressText
                            });
                        }
                    }
                    var flag = true;
                    for(var i=0; i<options.length; i++){
                        if(options[i].label == component.get("v.emailMessageRecord.ToAddress")){
                            flag = false;
                            break;
                        }
                    }
                    if(flag){
                        if(component.get("v.emailMessageRecord").Incoming){
                            options.push({
                                label : component.get("v.emailMessageRecord.ToAddress"),
                                value : component.get("v.emailMessageRecord.ToAddress")
                            });
                        }
                        else{
                            options.push({
                                label : component.get("v.emailMessageRecord.FromAddress"),
                                value : component.get("v.emailMessageRecord.FromAddress")
                            });
                        }
                    }
                    component.set("v.fromAddresses", options);
                    var emailid;
                    if(component.get("v.emailMessageRecord").Incoming)
                        emailid = component.get("v.emailMessageRecord.ToAddress");
                    else
                        emailid = component.get("v.emailMessageRecord.FromAddress");
                    var refreshIntervalId = setInterval(function(){
                    component.set("v.fromAddress", emailid);
                    }, 250);
                    setTimeout(function(){ clearInterval(refreshIntervalId); },300);
                    component.set("v.isLoading", false);
                }
                else{
                    self.getDefaultOrgAddresses(component, event);
                }
            }
            else if(state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError()[0].message,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    getDefaultOrgAddresses : function(component, event){
        var action = component.get("c.getOrgWideDefaultQueues");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var options = [];
                options.push({
                    label : "Please specify",
                    value : ""
                });
                var fromAddresses = response.getReturnValue();
                if(fromAddresses != undefined && fromAddresses.length > 0){
                    for(var index=0; index<fromAddresses.length; index++){
                        var addressText = fromAddresses[index].Address;
                        options.push({
                            label : addressText,
                            value : addressText
                        });
                    }
                    var flag = true;
                    for(var i=0; i<options.length; i++){
                        if(options[i].label == component.get("v.emailMessageRecord.ToAddress")){
                            flag = false;
                            break;
                        }
                    }
                    if(flag && component.get("v.emailMessageRecord.Incoming")){
                        options.push({
                            label : component.get("v.emailMessageRecord.ToAddress"),
                            value : component.get("v.emailMessageRecord.ToAddress")
                        });
                    }else{
                        options.push({
                            label : component.get("v.emailMessageRecord.FromAddress"),
                            value : component.get("v.emailMessageRecord.FromAddress")
                        });
                    }
                    component.set("v.fromAddresses", options);
                    var emailid;
                    if(component.get("v.emailMessageRecord.Incoming"))
                        emailid = component.get("v.emailMessageRecord.ToAddress");
                    else
                        emailid = component.get("v.emailMessageRecord.FromAddress");
                    var refreshIntervalId = setInterval(function(){
                        component.set("v.fromAddress", emailid);
                    }, 350);
                    setTimeout(function(){ clearInterval(refreshIntervalId); },400);
                    component.set("v.isLoading", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    forwardMail : function(component, event){
        component.set("v.isLoading", true);
        var action = component.get("c.sendMailToUsers");
        var toAddresses = component.get("v.toAddress");
        var ccAddresses = component.get("v.ccAddress");
        var bccAddresses = component.get("v.bccAddress");
        if(toAddresses != undefined){
            toAddresses = toAddresses.trim();
        }
        if(ccAddresses != undefined){
            ccAddresses = ccAddresses.trim();
        }
        if(bccAddresses != undefined){
            bccAddresses = bccAddresses.trim();
        }
        action.setParams({
            "fromAddress" : component.get("v.fromAddress"),
            "toAddress" : toAddresses,
            "ccAddress" : ccAddresses,
            "bccAddress" : bccAddresses,
            "subject" : component.get("v.subject"),
            "mailBody" : component.get("v.bodyText"),
            "caseId" : component.get("v.caseId"),
            "documentIds" : component.get("v.attachmentIds"),
            "recordIdValue" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                if(response.getReturnValue()){
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Mail has been sent successfully",
                        "type": "success"
                    });
                }
                else{
                    toastEvent.setParams({
                        "title": "Failure!",
                        "message": "Error while sending mail",
                        "type": "error"
                    });
                }
                toastEvent.fire();
            }
            else if(state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError()[0].message,
                    "type": "error"
                });
                toastEvent.fire();
            }
            component.set("v.isLoading", false);
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    },
    
    fetchDataForAttachment : function(component, event){
        if(event.target.nodeName == "DIV"){
            component.set("v.fetchAttachData", "owned");
            this.loadDataForAttachment(component, event);
        }
        else if(event.target.nodeName == "A"){
            var fileSharing = event.target.parentNode.getAttribute("data-files");
            var fetchDataType = component.get("v.fetchAttachData");
            if(fileSharing != fetchDataType){
                component.set("v.fetchAttachData", fileSharing);
                this.loadDataForAttachment(component, event);
            }
        }
    },
    
    loadDataForAttachment : function(component, event){
        var self = this;
        component.set("v.isLoading", true);
        var action = component.get("c.loadDataForAttachment");
        action.setParams({
            "attachmentType" : component.get("v.fetchAttachData"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var contentDocumentList = response.getReturnValue();
                if(contentDocumentList.length > 0){
                    component.set("v.showNoAttachment", false);
                    var arrayRecord = [];
                    for(var i=0; i<contentDocumentList.length; i++){
                        var objectRecord = contentDocumentList[i];
                        if(contentDocumentList[i].FileExtension == 'png' || contentDocumentList[i].FileExtension == 'jpg' || contentDocumentList[i].FileExtension == 'jpeg'){
                            objectRecord.FileIcon = 'doctype:image';
                        }else if(contentDocumentList[i].FileExtension == 'txt'){
                            objectRecord.FileIcon = 'doctype:txt';
                        }else if(contentDocumentList[i].FileExtension == 'csv'){
                            objectRecord.FileIcon = 'doctype:csv';
                        }else if(contentDocumentList[i].FileExtension == 'exe'){
                            objectRecord.FileIcon = 'doctype:exe';
                        }else if(contentDocumentList[i].FileExtension == 'pdf'){
                            objectRecord.FileIcon = 'doctype:pdf';
                        }else if(contentDocumentList[i].FileExtension == 'xls' || contentDocumentList[i].FileExtension == 'xlsx'){
                            objectRecord.FileIcon = 'doctype:excel';
                        }else if(contentDocumentList[i].FileExtension == 'ppt'){
                            objectRecord.FileIcon = 'doctype:ppt';
                        }else if(contentDocumentList[i].FileExtension == 'docx'){
                            objectRecord.FileIcon = 'doctype:word';
                        }else if(contentDocumentList[i].FileExtension == 'xml'){
                            objectRecord.FileIcon = 'doctype:xml';
                        }else{
                            objectRecord.FileIcon = 'doctype:unknown';
                        }
                        objectRecord.CreatedDate = contentDocumentList[i].CreatedDate.substring(0, 10);
                        var fileSize = contentDocumentList[i].ContentSize;
                        if(fileSize < 1024){
                            objectRecord.ContentSize = fileSize;
                            objectRecord.ContentSizeString = 'B';
                        }
                        else if(fileSize >= 1024 && fileSize <1048576){
                            fileSize = fileSize/1024;
                            fileSize = fileSize.toFixed(2);
                            objectRecord.ContentSize = fileSize;
                            objectRecord.ContentSizeString = 'KB';
                        }
                        else if(fileSize>=1048576){
                            fileSize = fileSize/1048576;
                            fileSize = fileSize.toFixed(2);
                            objectRecord.ContentSize = fileSize;
                            objectRecord.ContentSizeString = 'MB';
                        }
                        arrayRecord.push(objectRecord);
                    }
                    component.set("v.attachmentsList", arrayRecord);
                    component.set("v.showAttachmentList", true);
                }
                else{
                    component.set("v.showAttachmentList", false);
                    component.set("v.showNoAttachment", true);
                }
            }
            else if(state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError()[0].message,
                    "type": "error"
                });
                toastEvent.fire();
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    loadEmailTemplatesForMail : function(component, event){
        var action = component.get("c.loadEmailTemplatesForMail");
        action.setParams({
            "templateType" : component.get("v.templateType"),
            "templateFolder" : component.get("v.templateFolder")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var templateList = response.getReturnValue();
                var tempList = [];
                if(templateList.length > 0){
                    for(var i=0; i<templateList.length; i++){
                        var attachRecord = templateList[i];
                        var attachDate = templateList[i].CreatedDate;
                        attachDate = attachDate.substring(0, 10);
                        attachRecord.CreatedDate = attachDate;
                        var folderName = attachRecord.FolderName;
                        if(folderName.startsWith('My')){
                            folderName = folderName.substring(3, folderName.length);
                            attachRecord.FolderName = folderName;
                        }
                        tempList.push(attachRecord);
                    }
                    component.set("v.templateList", tempList);
                    component.set("v.isTemplateContent", false);
                    component.set("v.templateAvailable", true);
                }
                else{
                    component.set("v.isTemplateContent", true);
                    component.set("v.templateAvailable", false);
                }
            }
            else if(state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError()[0].message,
                    "type": "error"
                });
                toastEvent.fire();
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    getTemplateForMail : function(component, event, templateId){
        var action = component.get("c.addTemplateDataInMail");
        action.setParams({
            "templateId" : templateId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var template = response.getReturnValue()[0];
                var subject;
                var body;
                if(template.Subject != undefined || template.Subject != ''){
                    subject = template.Subject;
                }
                else if(template.Subject == undefined || template.Subject == ''){
                    subject = template.Name;
                }
                if(template.HtmlValue != undefined && template.HtmlValue != ''){
                    body = template.HtmlValue;
                }
                else if(template.Body != undefined && template.Body != ''){
                    body = template.Body;
                }
                else if(template.Markup != undefined && template.Markup != ''){
                    body = template.Markup;
                }
                component.set("v.subject", subject);
                if(body.includes("]]>")){
                    body = body.replace("]]>", '');
                }
                var bodyText = component.get("v.bodyText");
                body += bodyText;
                component.set("v.bodyText", body);
            }
            else if(state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError()[0].message,
                    "type": "error"
                });
                toastEvent.fire();
            }
            component.set("v.isTemplateOpen", false);
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    loadFolderDetails : function(component, event){
        var self = this;
        var action = component.get("c.getFolderDetailsForTemplates");
        action.setParams({
            "templateType" : component.get("v.templateType")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var options = [];
                options.push({
                    label : "All",
                    value : ""
                });
                var foldermap = response.getReturnValue();
                if(foldermap != undefined){
                    for(var keyItem in foldermap){
                        options.push({
                            label : foldermap[keyItem],
                            value : keyItem
                        });
                    }
                    component.set("v.templateFolders", options);
                    self.loadEmailTemplatesForMail(component, event);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getContactLeadUserDetails : function(component, event, node, newAddress){
        var action = component.get("c.getContactLeadUserDetails");
        action.setParams({
            "SearchValue" : newAddress
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var userContactList = response.getReturnValue();
                var userArray = [];
                if(userContactList != null && userContactList != undefined){
                    var visibleFlag = false;
                    for(var key in userContactList){
                        var recordList = userContactList[key];
                        if(recordList.length > 0){
                            visibleFlag = true;
                        }
                        for(var i=0; i<recordList.length; i++){
                            var userRecord = {};
                            userRecord.Name = recordList[i].Name;
                            userRecord.Email = recordList[i].Email;
                            if(key == 'Contact'){
                                userRecord.Type = 'standard:contact';
                            }else if(key == 'Lead'){
                                userRecord.Type = 'standard:lead';
                            }else if(key == 'User'){
                                userRecord.Type = 'standard:user';
                            }
                            userArray.push(userRecord);
                        }
                    }
                    if(visibleFlag){
                        component.set("v.userContactList", userArray);
                        $(node).next().show();
                        $(node).next().find("ul").show();
                    }
                }
                else{
                    $(node).next().show();
                    $(node).next().find("ul").show();
                }
                $(node).next().find("ul").next().hide();
            }
        });
        $A.enqueueAction(action);
    }
})