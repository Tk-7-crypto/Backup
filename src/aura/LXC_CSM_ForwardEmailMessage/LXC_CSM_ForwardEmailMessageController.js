({
	doInit : function(component, event, helper) {
        var recordIdValue = component.get("v.recordId");
        helper.getEmailMessages(component, event, recordIdValue);
	},
    
    setFromAddress : function(component, event, helper){
        var newFromValue = component.find("fromAddress").get("v.value");
        component.set("v.fromAddress", newFromValue);
    },
    
    forwardMail : function(component, event, helper) {
        helper.forwardMail(component, event);
    },
    
    openAttachmentModal : function(component, event, helper){
        component.set("v.isAttachmentOpen", true);
        component.set("v.showAttachmentList", false);
        component.set("v.showNoAttachment", false);
        helper.fetchDataForAttachment(component, event);
    },
    
    setRecordChecked : function(component, event, helper){
        if(event.currentTarget.firstElementChild.firstElementChild.firstElementChild.nextElementSibling.getAttribute("data-checked") != "true"){
            event.currentTarget.firstElementChild.firstElementChild.firstElementChild.nextElementSibling.setAttribute("checked", true);
            event.currentTarget.firstElementChild.firstElementChild.firstElementChild.nextElementSibling.setAttribute("data-checked", "true");
            event.currentTarget.parentNode.parentNode.classList.add("selectedRecord");
        }
        else{
            event.currentTarget.firstElementChild.firstElementChild.firstElementChild.nextElementSibling.removeAttribute("checked");
            event.currentTarget.firstElementChild.firstElementChild.firstElementChild.nextElementSibling.setAttribute("data-checked", "false");
            event.currentTarget.parentNode.parentNode.classList.remove("selectedRecord");
        }
        var checkboxes = $("#attachmentResultContainer").find("ul.results").find("input[type='checkbox']:checked");
        var checkboxes = $("#attachmentResultContainer").find("ul.results").find("input[type='checkbox']:checked");
        if(checkboxes.length>0){
            if(checkboxes.length > 10){
                $("#addAttachmentButton").attr("disabled", "disabled");
                alert("More than 10 files can't be selected at one time");
            }
            else{
                $("#filesCountHeader").html(checkboxes.length+" of 10 files selected");
                $("#addAttachmentButton").removeAttr("disabled");
            }
        }
        else{
            $("#addAttachmentButton").attr("disabled", "disabled");
        }
    },
    
    setActiveClassAndFetchData : function(component, event, helper){
        $("#bottomPaneMenuItem").find("li").removeClass("slds-is-active");
        event.currentTarget.classList.add("slds-is-active");
        helper.fetchDataForAttachment(component, event);
    },
    
    closeAttachmentModal : function(component, event, helper){
        component.set("v.isAttachmentOpen", false);
    },
    
    handleFileUploadFinished : function(component, event, helper){
        var uploadedFiles = event.getParam("files");
        var docIdArray = [];
        var documentsArray = [];
        var existingIds = component.get("v.attachmentIds");
        if(existingIds != '' && existingIds.length>0){
            for(var i=0; i<existingIds.length; i++){
                docIdArray.push(existingIds[i]);
            }
        }
        for(var index=0; index<uploadedFiles.length; index++){
            docIdArray.push(uploadedFiles[index].documentId);
            var attachmentRecord = {};
            attachmentRecord.DocumentId = uploadedFiles[index].documentId;
            var fileName = uploadedFiles[index].name;
            fileName = fileName.split('.');
            attachmentRecord.FileName = fileName[0];
            if(fileName[1] == 'png' || fileName[1] == 'jpg' || fileName[1] == 'jpeg'){
                attachmentRecord.FileIcon = 'doctype:image';
            }else if(fileName[1] == 'txt'){
                attachmentRecord.FileIcon = 'doctype:txt';
            }else if(fileName[1] == 'csv'){
                attachmentRecord.FileIcon = 'doctype:csv';
            }else if(fileName[1] == 'exe'){
                attachmentRecord.FileIcon = 'doctype:exe';
            }else if(fileName[1] == 'pdf'){
                attachmentRecord.FileIcon = 'doctype:pdf';
            }else if(fileName[1] == 'xls' || fileName[1] == 'xlsx'){
                attachmentRecord.FileIcon = 'doctype:excel';
            }else if(fileName[1] == 'ppt'){
                attachmentRecord.FileIcon = 'doctype:ppt';
            }else if(fileName[1] == 'docx'){
                attachmentRecord.FileIcon = 'doctype:word';
            }else if(fileName[1] == 'xml'){
                attachmentRecord.FileIcon = 'doctype:xml';
            }else{
                attachmentRecord.FileIcon = 'doctype:unknown';
            }
            documentsArray.push(attachmentRecord);
        }

        var emailDocArray = component.get("v.emailAttachmentsList");
        for(var i=0; i < emailDocArray.length; i++){
            docIdArray.push(emailDocArray[i].DocumentId);
            documentsArray.push(emailDocArray[i]);
        }
        component.set("v.attachmentsList", documentsArray);
        component.set("v.isAttachmentOpen", false);
        component.set("v.attachmentIds", docIdArray);
        component.set("v.showFilePills", true);
    },
    
    removeAttachmentFromMail : function(component, event, helper){
        var liNode = event.target.parentNode.parentNode.parentNode.parentNode;
        $(liNode).remove();
    },
    
    showTemplateBox : function(component, event, helper){
        $("#template-dialog-box").toggle();
    },
    
    openTemplateModal : function(component, event, helper){
        $("#template-dialog-box").hide();
        component.set("v.isTemplateOpen", true);
        component.set("v.isLoading", true);
        var refreshIntervalId = setInterval(function(){
            var templateType = document.getElementById("templateType").value;
            component.set("v.templateType", templateType);
            helper.loadFolderDetails(component, event);
        }, 200);
        setTimeout(function(){ clearInterval(refreshIntervalId); },250);
    },
    
    closeTemplateModal : function(component, event, helper){
        component.set("v.isTemplateOpen", false);
    },
    
    openPreviewModal : function(component, event, helper){
        component.set("v.isPreviewOpen", true);
        var intervalId = setInterval(function(){
            document.getElementById("previewmailcontent").innerHTML = component.get("v.bodyText");
        }, 50);
        setTimeout(function(){ clearInterval(intervalId); },60);
    },
    
    closePreviewModal : function(component, event, helper){
        component.set("v.isPreviewOpen", false);
    },
    
    addAttachmentInMail : function(component, event, helper){
        var docIdArray = [];
        var documentsArray = [];
        var existingIds = component.get("v.attachmentIds");
        if(existingIds != '' && existingIds.length>0){
            for(var i=0; i<existingIds.length; i++){
                docIdArray.push(existingIds[i]);
            }
        }
        var liNodes = $("#attachmentResultContainer").find("ul.results").find("li.selectedRecord");
        for(var i=0; i<liNodes.length; i++){
            var documentId = $(liNodes[i]).find("span.uiAttachDocContainer").attr("data-document-id");
            docIdArray.push(documentId);
            var attachmentRecord = {};
            attachmentRecord.DocumentId = documentId;
            var fileName = $(liNodes[i]).find("span.uiAttachDocContainer").text();
            attachmentRecord.FileName = fileName;
            var fileType = $(liNodes[i]).find("p").children().last().text();
            if(fileType == 'png' || fileType == 'jpg' || fileType == 'jpeg'){
                attachmentRecord.FileIcon = 'doctype:image';
            }else if(fileType == 'txt'){
                attachmentRecord.FileIcon = 'doctype:txt';
            }else if(fileType == 'csv'){
                attachmentRecord.FileIcon = 'doctype:csv';
            }else if(fileType == 'exe'){
                attachmentRecord.FileIcon = 'doctype:exe';
            }else if(fileType == 'pdf'){
                attachmentRecord.FileIcon = 'doctype:pdf';
            }else if(fileType == 'xls' || fileType == 'xlsx'){
                attachmentRecord.FileIcon = 'doctype:excel';
            }else if(fileType == 'ppt'){
                attachmentRecord.FileIcon = 'doctype:ppt';
            }else if(fileType == 'docx'){
                attachmentRecord.FileIcon = 'doctype:word';
            }else if(fileType == 'xml'){
                attachmentRecord.FileIcon = 'doctype:xml';
            }else{
                attachmentRecord.FileIcon = 'doctype:unknown';
            }
            documentsArray.push(attachmentRecord);
        }

        var emailDocArray = component.get("v.emailAttachmentsList");
        for(var i=0; i < emailDocArray.length; i++){
            docIdArray.push(emailDocArray[i].DocumentId);
            documentsArray.push(emailDocArray[i]);
        }
        component.set("v.attachmentsList", documentsArray);
        component.set("v.isAttachmentOpen", false);
        component.set("v.attachmentIds", docIdArray);
        component.set("v.showFilePills", true);
    },
    
    loadTemplatesBasedOnType : function(component, event, helper){
        component.set("v.isLoading", true);
        var templateType = document.getElementById("templateType").value;
        var templateFolder = document.getElementById("templateFolder").value;
        component.set("v.templateType", templateType);
        component.set("v.templateFolder", templateFolder);
        helper.loadFolderDetails(component, event);
    },
    
    loadTemplatesBasedOnFolder : function(component, event, helper){
        component.set("v.isLoading", true);
        var templateType = document.getElementById("templateType").value;
        var templateFolder = document.getElementById("templateFolder").value;
        component.set("v.templateType", templateType);
        component.set("v.templateFolder", templateFolder);
        helper.loadEmailTemplatesForMail(component, event);
    },
    
    addTemplateInMail : function(component, event, helper){
        component.set("v.isLoading", true);
        var templateId = event.target.getAttribute("data-template-id");
        helper.getTemplateForMail(component, event, templateId);
    },
        
    closeMailMessenger : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    filterTemplateName : function(component, event, helper){
        var searchText = $("#templateSearch").val();
        var trNodeList = $("#templateResultsTable").find("tr");
        component.set("v.isLoading", true);
        if(searchText.length > 0){
            $("#templateSearch").next().removeClass("hide");
            for(var index=0; index<trNodeList.length; index++){
                var trNode = trNodeList[index];
                var nodeValue = $(trNode).find("a").html();
                if(nodeValue.indexOf(searchText) == -1){
                    $(trNode).addClass("trHide");
                }
                else{
                    $(trNode).removeClass("trHide");
                }
            }
        }
        else{
            $("#templateSearch").next().addClass("hide");
            for(var index=0; index<trNodeList.length; index++){
                var trNode = trNodeList[index];
                $(trNode).removeClass("trHide");
            }
        }
        component.set("v.isLoading", false);
    },
    
    clearTemplateSearch : function(component, event, helper){
        $("#templateSearch").val("");
        $("#templateSearch").next().addClass("hide");
        var trNodeList = $("#templateResultsTable").find("tr");
        for(var index=0; index<trNodeList.length; index++){
            var trNode = trNodeList[index];
            $(trNode).removeClass("trHide");
        }
    },
    
    searchToAddressRelatedUserContactRecord : function(component, event, helper){
        var toAddress = component.get("v.toAddress");
        var node = event.target;
        if(toAddress != undefined){
            if(toAddress.indexOf(';') != -1){
                var toAddresses = toAddress.split(';');
                var newAddress = toAddresses[toAddresses.length-1];
                newAddress = newAddress.trim();
                if(newAddress.length>1){
                    $(node).next().find("ul").next().show();
                    helper.getContactLeadUserDetails(component, event, node, newAddress);
                }
                else{
                    $(node).next().hide();
                    $(node).next().find("ul").hide();
                }
            }
            else{
                toAddress = toAddress.trim();
                if(toAddress.length>1){
                    $(node).next().find("ul").next().show();
                    helper.getContactLeadUserDetails(component, event, node, toAddress);
                }
                else{
                    $(node).next().hide();
                    $(node).next().find("ul").hide();
                }
            }
        }
    },
    
    setEmailAddressInToAddressField : function(component, event, helper){
        var node = event.target;
        var liNode;
        if($(node).nodeName != 'LI'){
            liNode = $(node).closest("li");
        }
        else{
            liNode = node;
        }
        var emailAddress = $(liNode).find('.contactEmailBlock').eq(0).find('span').html();
        var toAddress = component.get("v.toAddress");
        if(toAddress != null && toAddress != ''){
            if(toAddress.indexOf(';') > 0){
                var toAddresses = toAddress.split(';');
                var newAddress = toAddresses[toAddresses.length-1];
                toAddress = toAddress.replace(newAddress, ' ');
                if(!toAddress.includes(emailAddress)){
                    toAddress = toAddress+emailAddress+'; ';
                }
            }
            else{
                toAddress = '';
                toAddress = emailAddress+'; ';
            }
            component.set("v.toAddress", toAddress);
            $(liNode).parent().hide();
            $(liNode).parent().parent().parent().hide();
        }
    },
    
    searchCcAddressRelatedUserContactRecord : function(component, event, helper){
        var toAddress = component.get("v.ccAddress");
        var node = event.target;
        if(toAddress != undefined){
            if(toAddress.indexOf(';') != -1){
                var toAddresses = toAddress.split(';');
                var newAddress = toAddresses[toAddresses.length-1];
                newAddress = newAddress.trim();
                if(newAddress.length>1){
                    $(node).next().find("ul").next().show();
                    helper.getContactLeadUserDetails(component, event, node, newAddress);
                }
                else{
                    $(node).next().hide();
                    $(node).next().find("ul").hide();
                }
            }
            else{
                toAddress = toAddress.trim();
                if(toAddress.length>1){
                    $(node).next().find("ul").next().show();
                    helper.getContactLeadUserDetails(component, event, node, toAddress);
                }
                else{
                    $(node).next().hide();
                    $(node).next().find("ul").hide();
                }
            }
        }
    },
    
    setEmailAddressInCcAddressField : function(component, event, helper){
        var node = event.target;
        var liNode;
        if($(node).nodeName != 'LI'){
            liNode = $(node).closest("li");
        }
        else{
            liNode = node;
        }
        var emailAddress = $(liNode).find('.contactEmailBlock').eq(0).find('span').html();
        var toAddress = component.get("v.ccAddress");
        if(toAddress != null && toAddress != ''){
            if(toAddress.indexOf(';') > 0){
                var toAddresses = toAddress.split(';');
                var newAddress = toAddresses[toAddresses.length-1];
                toAddress = toAddress.replace(newAddress, ' ');
                if(!toAddress.includes(emailAddress)){
                    toAddress = toAddress+emailAddress+'; ';
                }
            }
            else{
                toAddress = '';
                toAddress = emailAddress+'; ';
            }
            component.set("v.ccAddress", toAddress);
            $(liNode).parent().hide();
            $(liNode).parent().parent().parent().hide();
        }
    },
    
    searchBccAddressRelatedUserContactRecord : function(component, event, helper){
        var toAddress = component.get("v.bccAddress");
        var node = event.target;
        if(toAddress != undefined){
            if(toAddress.indexOf(';') != -1){
                var toAddresses = toAddress.split(';');
                var newAddress = toAddresses[toAddresses.length-1];
                newAddress = newAddress.trim();
                if(newAddress.length>1){
                    $(node).next().find("ul").next().show();
                    helper.getContactLeadUserDetails(component, event, node, newAddress);
                }
                else{
                    $(node).next().hide();
                    $(node).next().find("ul").hide();
                }
            }
            else{
                toAddress = toAddress.trim();
                if(toAddress.length>1){
                    $(node).next().find("ul").next().show();
                    helper.getContactLeadUserDetails(component, event, node, toAddress);
                }
                else{
                    $(node).next().hide();
                    $(node).next().find("ul").hide();
                }
            }
        }
    },
    
    setEmailAddressInBccAddressField : function(component, event, helper){
        var node = event.target;
        var liNode;
        if($(node).nodeName != 'LI'){
            liNode = $(node).closest("li");
        }
        else{
            liNode = node;
        }
        var emailAddress = $(liNode).find('.contactEmailBlock').eq(0).find('span').html();
        var toAddress = component.get("v.bccAddress");
        if(toAddress != null && toAddress != ''){
            if(toAddress.indexOf(';') > 0){
                var toAddresses = toAddress.split(';');
                var newAddress = toAddresses[toAddresses.length-1];
                toAddress = toAddress.replace(newAddress, ' ');
                if(!toAddress.includes(emailAddress)){
                    toAddress = toAddress+emailAddress+'; ';
                }
            }
            else{
                toAddress = '';
                toAddress = emailAddress+'; ';
            }
            component.set("v.bccAddress", toAddress);
            $(liNode).parent().hide();
            $(liNode).parent().parent().parent().hide();
        }
    }
})
