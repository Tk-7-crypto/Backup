global class CNT_TPA_ValidateUseDefDocType {
    public boolean isDRNSentAlready {get; set;}
    public boolean isCopyofSignedSentAlready {get; set;}
    public boolean isEnvelopeVoidedAlready {get; set;}
    public boolean isEnvelopestatusCompleted {get; set;}
    public boolean isOtherUseSelected {get; set;}
    public string agreementValidationMsg {get; set;}
    public boolean isAddendumRequired {get; set;}
    public boolean isAddendumAttachmentRequiredAndNotAttached {get; set;}
    public String requestIdforAddendumGeneration{get; set;}
    public string voidReasonForInvalidEnvelope {get; set;}
    public Id docusignStatusId {get; set;}

    public CNT_TPA_ValidateUseDefDocType() {
        isDRNSentAlready = false;
        isCopyofSignedSentAlready = false;
        isEnvelopeVoidedAlready = false;
        voidReasonForInvalidEnvelope = '';
        string requestId = ApexPages.currentPage().getParameters().get('id');
        isAddendumAttachmentRequiredAndNotAttached = false;
        isAddendumRequired = false;
        requestIdforAddendumGeneration = ApexPages.currentPage().getParameters().get('agrIdforAddendumGeneration');
        System.debug('In CNT_TPA_ValidateUseDefDocType: requestId: ' + requestId);
        if(requestId != null && requestId != ''){
            loadDefaultValues(requestId);
        }
    }

    public pagereference generateAddendumDoc(){
        SRV_TPA_TPARequest.generateAddendumNotificationDoc(requestIdforAddendumGeneration, 'word', UTL_LogFactory.GUID);
        return new PageReference('/'+requestIdforAddendumGeneration);
    }

    public void loadDefaultValues(string requestId) {
        List<Task> taskLists = [Select Id, WhatId, ActivityDate, Status, Subject, CallObject 
                                from Task 
                                where whatid =: requestId 
                                and (Subject like '%Data Release Notification Sent%' or Subject like '%Copy of executed%')];
        if(taskLists != null && taskLists.size() > 0){
            for(Task taskrecord: taskLists){
                if(taskrecord.Subject.containsIgnoreCase('Data Release Notification Sent')){
                   isDRNSentAlready = true;
                }
                if(taskrecord.Subject.containsIgnoreCase('Copy of executed')){
                    isCopyofSignedSentAlready = true;
                }
            }
        }
            

        List<dsfs__DocuSign_Status__c> DocusignStatusList = [select id, dsfs__Envelope_Status__c, dsfs__Voided_Reason__c 
                                                             from dsfs__DocuSign_Status__c 
                                                             where TPA_Request__c =: requestId 
                                                             order by CreatedDate Desc 
                                                             limit 1];
        if(DocusignStatusList != null && DocusignStatusList.size() > 0) {
            if(DocusignStatusList[0].dsfs__Envelope_Status__c == 'Voided') {
                isEnvelopeVoidedAlready = true;
            } else if(DocusignStatusList[0].dsfs__Envelope_Status__c == 'Completed') {
                isEnvelopestatusCompleted = true;
            } else if(DocusignStatusList[0].dsfs__Voided_Reason__c != null) {
                voidReasonForInvalidEnvelope = (String)DocusignStatusList[0].dsfs__Voided_Reason__c;
            }
            docusignStatusId = DocusignStatusList[0].Id;
        }
        TPA_Request__c request = [Select Id, Other_Use_Selected__c,Vendor_App_Submitted__c,is_Addendum_Attachment_Required__c, Vendor_App_Sent__c from TPA_Request__c where id =: requestId];
        isOtherUseSelected = request.Other_Use_Selected__c;
        agreementValidationMsg = SRV_TPA_TPARequest.validateAgreementForInEffect(requestId);
        List<Attachment> lstAttachment = [SELECT id, name, lastmodifieddate FROM Attachment WHERE ParentId =: requestId AND name LIKE '%Addendum Notification%.pdf' AND lastmodifieddate >= :request.Vendor_App_Sent__c LIMIT 1]; 
        if(request.is_Addendum_Attachment_Required__c && lstAttachment.size() <= 0){
            isAddendumAttachmentRequiredAndNotAttached = true;
        }
        if(request.is_Addendum_Attachment_Required__c) {
            isAddendumRequired = true;
        }
    }

    @remoteAction
    public static void sendDRNManually(string recId)
    {
        TGRH_TPARequest tpaReqTriggerHelperObj = new TGRH_TPARequest();
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();
        tpaReqTriggerHelperObj.orgWideEmailId = tpaCustomSettings.TPA_From_Address_For_Data_Release__c;
        tpaReqTriggerHelperObj.isManualDRNCalled = true;
        List<String> toAddress = new List<String>();
        string templateId = '';
        List<string> listCCAddresses = new List<String>();
        string vendorMailSendTo = '';
        List<String> vendorMailList = new List<String>();
        TPA_Request__c requestObj = [Select Id, Name, TPA_Assigned_TP_Processor__c, Client_TPA_Representative_Email__c, Owner.Email, Owner.Type, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, clientcontact__c, TP_Processor_Email__c, TPA_Authorised_Signer__c, Client_Address__c, Client_Address__r.TPAOtherEmailIds__c,
        Vendor_Contact_e_mail__c, Authorized_Signer_Email__c, Vendor_App_Submitted__c, ClientContact__r.Email, Vendor_App_Sent__c, Is_Restricted_Data_Asset__c, createddate,
        (SELECT Id, Email__c, Name, Type__c FROM TPA_Request_Contacts__r), (SELECT Id, Name, Email__c FROM Agreement_Contacts__r) from TPA_Request__c where Id =: recId Limit 1]; 
        if(requestObj != null)
        {
            if(requestObj?.ClientContact__r?.Email != null){
                listCCAddresses.add(requestObj.ClientContact__r.Email);
            }
            if(requestObj.Client_TPA_Representative_Email__c != null && requestObj.Client_TPA_Representative_Email__c != ''){
                toAddress.add(requestObj.Client_TPA_Representative_Email__c);
            }
            for(TPA_Contact__c objTpaCon: requestObj.TPA_Request_Contacts__r) {
                if(objTpaCon.Type__c == 'Additional Client Contact'){
                    listCCAddresses.add(objTpaCon.Email__c);
                }
            }
            if(requestObj.Owner.Type != null && requestObj.Owner.Type == 'Queue' && requestObj.Owner.Email != null){
                listCCAddresses.add(requestObj.Owner.Email);
            }
            if(requestObj.TP_Processor_Email__c != null && requestObj.TP_Processor_Email__c != '')
            {
                listCCAddresses.add(requestObj.TP_Processor_Email__c);
                vendorMailList.add(requestObj.TP_Processor_Email__c);
            }
            
            if(tpaCustomSettings.Shared_Email__c != null && tpaCustomSettings.Shared_Email__c != '') {
                listCCAddresses.add(tpaCustomSettings.Shared_Email__c);
            }
            
            if(requestObj.Client_Address__c != null && requestObj.Client_Address__r.TPAOtherEmailIds__c != '') {
                listCCAddresses = UTL_TPA_Multilingual.ccList(requestObj.Client_Address__r.TPAOtherEmailIds__c, listCCAddresses);
            }
            
            if(requestObj.TPA_Authorised_Signer__c == 'No' && requestObj.Vendor_Contact_e_mail__c != requestObj.Authorized_Signer_Email__c)
            {
                vendorMailList.add(requestObj.Vendor_Contact_e_mail__c);
            }

            templateId = tpaCustomSettings.TPA_Template_Id__c;
            if(requestObj.TPA_Authorised_Signer__c == 'Yes')
            {
                vendorMailSendTo = requestObj.Vendor_Contact_e_mail__c;
            }
            else
            {
                vendorMailSendTo = requestObj.Authorized_Signer_Email__c;
            }

            tpaReqTriggerHelperObj.sendMail(requestObj.ClientContact__c, toAddress, listCCAddresses, requestObj, templateId, 'Test:Data Release Authorization', requestObj.Id, vendorMailSendTo, vendorMailList, requestObj.Is_Restricted_Data_Asset__c, requestObj.createddate.date());

            insert (new Task( WhatId = requestObj.Id, ActivityDate = system.today(), Status = 'Completed', Subject = 'Data Release Notification Sent(Manually)', CallObject = 'Data Release Notification Sent(Manually)'));

        }
    }

    @remoteAction
    public static void sendCopyofSignedManually(string recId)
    {
        TGRH_TPARequest tpaReqTriggerHelperObj = new TGRH_TPARequest();
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();
        tpaReqTriggerHelperObj.orgWideEmailId = tpaCustomSettings.TPA_From_Address_For_Data_Release__c;
        tpaReqTriggerHelperObj.isManualCopyofSigned = true;
        TPA_Request__c requestObj = [select id, CreatedDate, Signer__c, Is_Restricted_Data_Asset__c, TPA_Authorised_Signer__c, Authorized_Signer_Email__c, Vendor_Contact_e_mail__c, 
                                     TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c,
                                     Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__r.Initials__c, Authorized_Signer_Name__c, 
                                     Signer__r.Name, Request_Status__c, Signer__r.dsfs__DocuSign_Recipient_Email__c, Signer__r.dsfs__Date_Signed__c, Name, ClientContact__c, 
                                     ClientContact__r.Email, Client_Address__r.TPAOtherEmailIds__c, Vendor_App_Submitted__c, Vendor_App_Sent__c, Client_Language__c, Vendor_Language__c, 
                                     (Select Email__c from TPA_Request_Contacts__r) from TPA_Request__c where id =:  recId limit 1];
        String vendorMailSendTo = '';
        List<String> vendorMailList;
        Boolean isRestricted = false;
        if(requestObj.TPA_Authorised_Signer__c == 'Yes') {
            vendorMailSendTo = requestObj.Vendor_Contact_e_mail__c;
        } else {
            vendorMailSendTo = requestObj.Authorized_Signer_Email__c;
        }
        vendorMailList = new List<String>();
        if(UTL_TPA.sharedEmailAddress != null) {
            vendorMailList.add(UTL_TPA.sharedEmailAddress);
        }
        if(requestObj.TP_Processor_Email__c != null && requestObj.TP_Processor_Email__c != '') {
            vendorMailList.add(requestObj.TP_Processor_Email__c);
        }
        if( requestObj.TPA_Authorised_Signer__c == 'No' && requestObj.Vendor_Contact_e_mail__c != requestObj.Authorized_Signer_Email__c) {
            vendorMailList.add(requestObj.Vendor_Contact_e_mail__c);
        }
        List<TPA_Contact__c> tpaContactsList = SRV_TPA_TPARequest.getContactsForRequest(requestObj.Id);
        if(tpaContactsList != null && tpaContactsList.size() > 0) {
            for(TPA_Contact__c tpaContact: tpaContactsList) {
                if(tpaContact.Type__c == 'Additional Vendor Contact') {
                    vendorMailList.add(tpaContact.Email__c);
                }
            }
        }
        isRestricted = requestObj.Is_Restricted_Data_Asset__c;

		tpaReqTriggerHelperObj.sendAcknowledgementToVendor(requestObj, vendorMailSendTo, vendorMailList, isRestricted, requestObj.Id);
        
		insert (new Task( WhatId = requestObj.Id, ActivityDate = system.today(), Status = 'Completed', Subject = 'Copy of Executed Email Sent(Manually)', CallObject = 'Copy of Executed Email Sent(Manually)'));


    }

    @remoteAction
    public static void voidEnvelopeNManually(string recId, string voidEnvType, string manualVoidReason)
    {
         Set<Id> stRequestId = new Set<Id>();
         stRequestId.add(recId);
         TPA_Request__c requestObj = [Select Id, Name, Vendor_Language__c from TPA_Request__c
                                             where Id =: recId
                                             limit 1];
         if(requestObj != null)
         {
            Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{requestObj.Vendor_Language__c + '_Translation__c'});
            String voidReason = 'Envelope is Corrected'; 
            if(manualVoidReason != null && manualVoidReason != '') {
                voidReason = manualVoidReason.length() > 199 ? manualVoidReason.substring(0, 199) : manualVoidReason;
				voidEnvType = 'manuallyVoided';             
            }
            if(multilanguageUtilityMap != null){
                if(voidEnvType == 'ineffect'){
                    voidReason = (String)multilanguageUtilityMap.get(requestObj.Vendor_Language__c + '_Translation__c~TPA_Request__c~Record~Manual VoidReason Ineffect')[0].get(requestObj.Vendor_Language__c + '_Translation__c');
                }else if(voidEnvType == 'resend'){
                    voidReason = (String)multilanguageUtilityMap.get(requestObj.Vendor_Language__c + '_Translation__c~TPA_Request__c~Record~Manual VoidReason Resend')[0].get(requestObj.Vendor_Language__c + '_Translation__c');
                }
            }

            voidReason = voidReason.replace('tpa_request_no',requestObj.Name);
            system.debug('####voidEnvType : '+voidEnvType+', voidReason : '+voidReason);

            try{
                TPA_Request__c relatedTPA = requestObj;
                System.debug('####TPA_UseDefDocTypeController.voidEnvelopeNManually relatedTPA record before: '+relatedTPA);
                relatedTPA.Void_Envelope_Type__c = voidEnvType;
                upsert relatedTPA;
                System.debug('####TPA_UseDefDocTypeController.voidEnvelopeNManually relatedTPA record after: '+relatedTPA);
            }catch(Exception e){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_ValidateUseDefDocType.voidEnvelopeNManually:::in update failed',requestObj.id != null ? requestObj.id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
            SRV_TPA_DocusignEnvelope.voidEnvelope(stRequestId, voidReason);
         }
    }
}
