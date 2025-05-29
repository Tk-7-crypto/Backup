global class BCH_TPA_UpdateAwaitingSubmissionReq  implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {

    Date todayDate;
    public Boolean includeTestDataOnly {
		get {
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}

    global BCH_TPA_UpdateAwaitingSubmissionReq () {
         todayDate = Date.today();
         //includeTestDataOnly = UTL_TPA.runBatchForTestRecords('BCH_TPA_UpdateAwaitingSubmissionReq');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        query = 'select id,Service_Provider_f__c,Cancelation_Pending_Notice_Sent_Date__c, Client_Address__r.Name,Vendor_Language__c,client_language__c,Vendor_Contact_Email_Client__c,Prevent_Cancellation__c,TP_Processor_Email__c,TPA_Assigned_TP_Processor__c,TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, ClientContact__r.email, Vendor_e_mail__c,client_Request_Submission__c,request_status__c,Sent_for_Signature__c,Client_Address__r.TPAOtherEmailIds__c from TPA_request__c where (Request_Status__c = \'Awaiting Vendor Submission\' or Request_Status__c = \'Awaiting Vendor Signature\') and Is_Submitted__c= true';
        if(includeTestDataOnly){
            query += ' and (Client_Address__r.Name Like \'Test_'+'%\'  OR Service_Provider_f__c Like \'Test_'+'%\' )';
        }
        //query += ' and Id in (\'a8M0U00000004AAUAY\')' ;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> objList) {
        system.debug('in execute');
        String preferredLanguage = 'English';
        List<TPA_request__c> lstAgreementToBeCancelled = new List<TPA_request__c>();
        List<TPA_Request__c> lstTPAPreCancellationNoticeSent = new List<TPA_Request__c>();
        List<TPA_Request__c> lstTPAPendingCancellationNoticeSent = new List<TPA_Request__c>(); 
        for(sobject sobj : objList) {
            system.debug('in objList');
            TPA_request__c reqObj = (TPA_request__c)sobj;
            
            String query = '';
            query = 'select id,Owner.Email, Owner.Type, Client_TPA_Representative_Email__c, Service_Provider_f__c,Cancelation_Pending_Notice_Sent_Date__c, Client_Address__r.Name,Vendor_Language__c,client_language__c,Vendor_Contact_Email_Client__c,Prevent_Cancellation__c,TP_Processor_Email__c,TPA_Assigned_TP_Processor__c,TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, ClientContact__r.email, Vendor_e_mail__c,client_Request_Submission__c,request_status__c,Sent_for_Signature__c,Client_Address__r.TPAOtherEmailIds__c from TPA_request__c where (Request_Status__c = \'Awaiting Vendor Submission\' or Request_Status__c = \'Awaiting Vendor Signature\') and Is_Submitted__c= true and Id = \'' + reqObj.Id + '\''; 
            List<sObject> sobjList = Database.query(query);
            if(sobjList == null || sobjList.size() == 0) {
                continue;
            }
            else {
                reqObj = (TPA_Request__c)sobjList[0];
            }
            
            preferredLanguage = reqObj.client_language__c != null ? reqObj.client_language__c : 'English';
            Date clientSubmissionDate;
            Date agreementSentForSignatureDate;
            Date agrCancelationPendingNoticeSentDate; 
            if(reqObj.client_Request_Submission__c != null)
                clientSubmissionDate = date.newinstance(reqObj.client_Request_Submission__c.year(), reqObj.client_Request_Submission__c.month(), reqObj.client_Request_Submission__c.day());
            if(reqObj.Sent_for_Signature__c != null)
                agreementSentForSignatureDate = date.newinstance(reqObj.Sent_for_Signature__c.year(), reqObj.Sent_for_Signature__c.month(), reqObj.Sent_for_Signature__c.day());
            if(reqObj.Cancelation_Pending_Notice_Sent_Date__c != null) {  
                agrCancelationPendingNoticeSentDate = date.newinstance(reqObj.Cancelation_Pending_Notice_Sent_Date__c.year(), reqObj.Cancelation_Pending_Notice_Sent_Date__c.month(), reqObj.Cancelation_Pending_Notice_Sent_Date__c.day()); 
            }
            
           // system.debug(agreementSentForSignatureDate.daysBetween(todayDate) + 'agrCancelationPendingNoticeSentDate: '+ agrCancelationPendingNoticeSentDate );
           // system.assert(false, agrCancelationPendingNoticeSentDate.daysBetween(todayDate) + 'agrCancelationPendingNoticeSentDate: '+ agrCancelationPendingNoticeSentDate );
          //  system.debug(agrCancelationPendingNoticeSentDate.daysBetween(todayDate) + 'agrCancelationPendingNoticeSentDate: '+ agrCancelationPendingNoticeSentDate );
          //  system.debug('agrCancelationPendingNoticeSentDate: '+agrCancelationPendingNoticeSentDate+ ': '+ agreementSentForSignatureDate.daysBetween(todayDate));
            if(reqObj.request_status__c == 'Awaiting Vendor Submission') {
                System.debug('INNN1');
                System.debug('Diff is::'+clientSubmissionDate.daysBetween(todayDate));
                if((reqObj.Service_Provider_f__c != null && reqObj.Service_Provider_f__c.containsIgnoreCase('Test_')) || (reqObj.Client_Address__c !=null && reqObj.Client_Address__r.Name.containsIgnoreCase('Test_'))) {
                    if(clientSubmissionDate.daysBetween(todayDate) == 2) {
                        TPA_Request__c objRequest = new TPA_request__c(id=reqObj.id);
                        objRequest.isCancellationNoticeSentForSubmission__C = true;
                        lstTPAPreCancellationNoticeSent.add(objRequest);
                        System.debug('email '+reqObj.Vendor_e_mail__c);
                        sendAwaitingVendorSubmissionPreCancellationNotice(reqObj,new List<String>{ reqObj.ClientContact__r.email }, reqObj.TP_Processor_Email__c,reqObj.Vendor_Contact_Email_Client__c,UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Pre Cancellation Sub'+preferredLanguage).Translated_Template_Id__c, 'Email Pre Cancellation Sub'); 
                    }
                    else if(clientSubmissionDate.daysBetween(todayDate) == 4) {
                        List<String> toAddress = new List<String>();
                        toAddress.add( reqObj.ClientContact__r.email);
                        if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
                            toAddress.add(reqObj.Client_TPA_Representative_Email__c);
                        }
                        if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
                            toAddress.add(reqObj.Owner.Email);
                        }
                        toAddress.add( reqObj.Vendor_Contact_Email_Client__c);
                        reqObj.Request_Status__c = 'Cancelled';
                        UTL_TPA.isCancelledBySystem = true;
                        //UTL_TPA.isEnvelopeVoided = true;
                        //SRV_TPA_DocusignEnvelope.voidEnvelopeCallout(reqObj.id , reqObj.Vendor_Language__c); 
                        lstAgreementToBeCancelled.add(reqObj);
                        SRV_TPA_TPARequest.updateActivityHistory(reqObj.Id, 'No Response from Vendor: Request Cancelled.', true); 
                        sendAwaitingVendorSubmissionCancellationNotice(reqObj,toAddress, reqObj.TP_Processor_Email__c,UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Post Cancellation Sub'+preferredLanguage).Translated_Template_Id__c, 'Email Post Cancellation Sub'); 
                    }
                }
                else if(clientSubmissionDate.daysBetween(todayDate) == 30)
                {
                    TPA_Request__c objRequest = new TPA_request__c(id=reqObj.id);
                    objRequest.isCancellationNoticeSentForSubmission__C = true;
                    lstTPAPreCancellationNoticeSent.add(objRequest);
                    System.debug('email '+reqObj.Vendor_e_mail__c);
                    sendAwaitingVendorSubmissionPreCancellationNotice(reqObj,new List<String>{ reqObj.ClientContact__r.email }, reqObj.TP_Processor_Email__c,reqObj.Vendor_Contact_Email_Client__c,UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Pre Cancellation Sub'+preferredLanguage).Translated_Template_Id__c, 'Email Pre Cancellation Sub');
                }
                else if(clientSubmissionDate.daysBetween(todayDate) == 45)
                {
                    List<String> toAddress = new List<String>();
                    toAddress.add( reqObj.ClientContact__r.email);
                    if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
                        toAddress.add(reqObj.Client_TPA_Representative_Email__c);
                    }
                    if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
                        toAddress.add(reqObj.Owner.Email);
                    }
                    toAddress.add( reqObj.Vendor_Contact_Email_Client__c);
                    reqObj.Request_Status__c = 'Cancelled';
                    UTL_TPA.isCancelledBySystem = true;
                    // UTL_TPA.isEnvelopeVoided = true;
                    // SRV_TPA_DocusignEnvelope.voidEnvelopeCallout(reqObj.id , reqObj.Vendor_Language__c); 
                    lstAgreementToBeCancelled.add(reqObj);
                    SRV_TPA_TPARequest.updateActivityHistory(reqObj.Id, 'No Response from Vendor: Request Cancelled.', true); 
                    sendAwaitingVendorSubmissionCancellationNotice(reqObj,toAddress, reqObj.TP_Processor_Email__c,UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Post Cancellation Sub'+preferredLanguage).Translated_Template_Id__c, 'Email Post Cancellation Sub'); 
                }
            }
            else if(!reqObj.Prevent_Cancellation__c && reqObj.Request_Status__c == 'Awaiting Vendor Signature')
            {
                System.debug('INNN2');
                System.debug('Diff is::'+agreementSentForSignatureDate.daysBetween(todayDate));
                if((reqObj.Service_Provider_f__c != null && reqObj.Service_Provider_f__c.containsIgnoreCase('Test_')) || (reqObj.Client_Address__c !=null && reqObj.Client_Address__r.Name.containsIgnoreCase('Test_'))){
                    if(agreementSentForSignatureDate.daysBetween(todayDate) == 2)
                    {
                        TPA_Request__c objRequest = new TPA_request__c(id=reqObj.id);
                        objRequest.isCancellationNoticeSentForSignature__c = true;
                        lstTPAPreCancellationNoticeSent.add(objRequest);
                        sendAwaitingVendorSubmissionPreCancellationNotice(reqObj,new List<String>{ reqObj.ClientContact__r.email }, reqObj.TP_Processor_Email__c,reqObj.Vendor_e_mail__c,UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Pre Cancellation Sign'+preferredLanguage).Translated_Template_Id__c, 'Email Pre Cancellation Sign'); //Modified by Rajendra under ER-11762
                    }
                    else if(agreementSentForSignatureDate.daysBetween(todayDate) == 4 || (agrCancelationPendingNoticeSentDate != null && agrCancelationPendingNoticeSentDate.daysBetween(todayDate) == 1)){ 
                        List<String> toAddress = new List<String>();
                        toAddress.add( reqObj.ClientContact__r.email);
                        if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
                            toAddress.add(reqObj.Client_TPA_Representative_Email__c);
                        }
                        if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
                            toAddress.add(reqObj.Owner.Email);
                        }
                        toAddress.add( reqObj.Vendor_e_mail__c);
                        reqObj.Request_Status__c = 'Cancelled';
                        UTL_TPA.isCancelledBySystem = true;
                        UTL_TPA.isEnvelopeVoided = true;
                        SRV_TPA_DocusignEnvelope.voidEnvelopeCallout(reqObj.id , reqObj.Vendor_Language__c); 
                        lstAgreementToBeCancelled.add(reqObj);
                        SRV_TPA_TPARequest.updateActivityHistory(reqObj.Id, 'No Response from Vendor: Request Cancelled.', true); 
                        sendAwaitingVendorSubmissionCancellationNotice(reqObj,toAddress, reqObj.TP_Processor_Email__c,UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Post Cancellation Sign'+preferredLanguage).Translated_Template_Id__c, 'Email Post Cancellation Sign'); 
                    }
                    else if(agreementSentForSignatureDate.daysBetween(todayDate) > 4 && agrCancelationPendingNoticeSentDate == null){
                        TPA_Request__c objRequest = new TPA_request__c(id=reqObj.id);
                        objRequest.Cancelation_Pending_Notice_Sent_Date__c  = todayDate;
                        lstTPAPendingCancellationNoticeSent.add(objRequest);
                        sendAwaitingVendorSubmissionPreCancellationNotice(reqObj,new List<String>{ reqObj.ClientContact__r.email }, reqObj.TP_Processor_Email__c,reqObj.Vendor_e_mail__c, TPA_Settings__c.getOrgDefaults().Email_Pending_Cancellation_Sign__c, 'SendEmail'); 
                    }
                }
                else if(agreementSentForSignatureDate.daysBetween(todayDate) == 45)
                {
                    TPA_Request__c objRequest = new TPA_request__c(id=reqObj.id);
                    objRequest.isCancellationNoticeSentForSignature__c = true;
                    lstTPAPreCancellationNoticeSent.add(objRequest);
                    sendAwaitingVendorSubmissionPreCancellationNotice(reqObj,new List<String>{ reqObj.ClientContact__r.email }, reqObj.TP_Processor_Email__c,reqObj.Vendor_e_mail__c,UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Pre Cancellation Sign'+preferredLanguage).Translated_Template_Id__c, 'Email Pre Cancellation Sign'); 
                }
                else if(agreementSentForSignatureDate.daysBetween(todayDate) == 60 || (agrCancelationPendingNoticeSentDate != null && agrCancelationPendingNoticeSentDate.daysBetween(todayDate) == 10)) 
                {
                    List<String> toAddress = new List<String>();
                    toAddress.add( reqObj.ClientContact__r.email);
                    if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
                        toAddress.add(reqObj.Client_TPA_Representative_Email__c);
                    }
                    if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
                        toAddress.add(reqObj.Owner.Email);
                    }
                    toAddress.add( reqObj.Vendor_e_mail__c);
                    reqObj.Request_Status__c = 'Cancelled';
                    UTL_TPA.isCancelledBySystem = true;
                    UTL_TPA.isEnvelopeVoided = true;
                    SRV_TPA_DocusignEnvelope.voidEnvelopeCallout(reqObj.id , reqObj.Vendor_Language__c); 
                    lstAgreementToBeCancelled.add(reqObj);
                    SRV_TPA_TPARequest.updateActivityHistory(reqObj.Id, 'No Response from Vendor: Request Cancelled.', true); 
                    sendAwaitingVendorSubmissionCancellationNotice(reqObj,toAddress, reqObj.TP_Processor_Email__c,UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Post Cancellation Sign'+preferredLanguage).Translated_Template_Id__c, 'Email Post Cancellation Sign'); 
                }
                
                else if(agreementSentForSignatureDate.daysBetween(todayDate) > 60 && agrCancelationPendingNoticeSentDate == null){
                    TPA_Request__c objRequest = new TPA_request__c(id=reqObj.id);
                    objRequest.Cancelation_Pending_Notice_Sent_Date__c  = todayDate;
                    lstTPAPendingCancellationNoticeSent.add(objRequest);
                    sendAwaitingVendorSubmissionPreCancellationNotice(reqObj,new List<String>{ reqObj.ClientContact__r.email }, reqObj.TP_Processor_Email__c,reqObj.Vendor_e_mail__c, TPA_Settings__c.getOrgDefaults().Email_Pending_Cancellation_Sign__c, 'SendEmail'); 
                }
                
            }

        }
        if(lstTPAPreCancellationNoticeSent.size() > 0)
            update lstTPAPreCancellationNoticeSent;
        if(lstAgreementToBeCancelled.size() > 0){
            UTL_TPA.isEnvelopeVoided = true;
            update lstAgreementToBeCancelled;
            UTL_TPA.isEnvelopeVoided = false;
        }
        if(lstTPAPendingCancellationNoticeSent.size() > 0){ 
             update lstTPAPendingCancellationNoticeSent; 
        } 
            
    }
    global void finish(Database.BatchableContext BC)
    {

    }
    public void sendAwaitingVendorSubmissionPreCancellationNotice(TPA_request__c templateContext, List<string> toRecipients, String tpProcessorEmail ,String vendorEmail,String templateId, String emailType) {
        try {
            if(templateContext?.Client_TPA_Representative_Email__c != null){
                toRecipients.add(templateContext.Client_TPA_Representative_Email__c);
            }
            //List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
            List<String> ccList = new List<String>();
            //Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            //emailNotToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
            //emailNotToSend.setTreatTargetObjectAsRecipient(false);
            //emailNotToSend.setToAddresses(toRecipients);
            //emailNotToSend.setWhatId(templateContext.Id);  
            //emailNotToSend.setTemplateId(templateId);
            //emailNotToSend.setOrgWideEmailAddressId(TPA_Settings__c.getInstance().TPA_From_Orgwide_Email_Id__c);
            //emailNotToSend.setSaveAsActivity(false);
            //Savepoint sp = Database.setSavepoint();
            //try
            //{
            //    if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
            //        Messaging.SendEmail(New Messaging.SingleEmailMessage[] {emailNotToSend});
            //    }
            //}
            //catch(Exception e)
            //{
            //    System.debug('Email Failed: ' + e.getMessage());
            //}
            //Database.rollback(sp);
            //Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            //emailToSend.setCharset('UTF-8');    
            //emailToSend.setToAddresses(toRecipients);
            //emailToSend.setPlainTextBody(emailNotToSend.getPlainTextBody());
            //emailToSend.setHTMLBody(emailNotToSend.getHTMLBody());
            //emailToSend.setSubject(emailNotToSend.getSubject());
            //emailToSend.setWhatId(templateContext.Id); 
            //emailToSend.setOrgWideEmailAddressId(TPA_Settings__c.getInstance().TPA_From_Orgwide_Email_Id__c);
            //emailToSend.setSaveAsActivity(true);
            //emailToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
            //emailToSend.setTreatTargetObjectAsRecipient(false);
            if(String.IsNotEmpty(vendorEmail)) {
                ccList.add(vendorEmail);
            }
            if(String.IsNotEmpty(tpProcessorEmail)) {
                ccList.add(tpProcessorEmail);
            }
            //ccList.add(TPA_Settings__c.getInstance().Shared_Email__c);
            if(TPA_Settings__c.getInstance() != null && TPA_Settings__c.getInstance().TPA_DRN_Mails_Copy_To__c != null && TPA_Settings__c.getInstance().TPA_DRN_Mails_Copy_To__c.length() > 0) {
                for(string mailIdObj: TPA_Settings__c.getInstance().TPA_DRN_Mails_Copy_To__c.split(',')) {
                    if(mailIdObj != null && mailIdObj.trim().length() > 0) {
                        ccList.add(mailIdObj.trim());
                    }
                }
            }
            if(templateContext.Client_Address__r.TPAOtherEmailIds__c != null && templateContext.Client_Address__r.TPAOtherEmailIds__c != '') {
                ccList = UTL_TPA_Multilingual.ccList(templateContext.Client_Address__r.TPAOtherEmailIds__c, ccList);
            }
            
            //emailToSend.setCcAddresses(ccList);
            //msgListToBeSend.add(emailToSend);
            try {
                //if(msgListToBeSend != null && msgListToBeSend.size() > 0 && UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                    //Messaging.sendEmail(msgListToBeSend);
                /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                if(templateContext.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            	   SRV_TPA_TPARequest.assignedTPProcessorName = templateContext.TPA_Assigned_TP_Processor__r.Initials__c; 
                }*/
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toRecipients, ccList, emailType, templateId, templateContext.Id, null, null, false, null, TRUE, TRUE, templateContext);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                system.debug('sent submission mail to client');
                //}
            }
            catch(Exception e) {
                System.debug('Email Failed: ' + e.getMessage());
            }
        }
        catch(System.EmailException emlEx) {
            System.debug('Email Failed: ' + emlEx);
        }
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }

    public void sendAwaitingVendorSubmissionCancellationNotice(TPA_request__c templateContext, List<string> toRecipients, String tpProcessorEmail,String templateId, String emailType) {
        try {
            //List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
            List<String> ccList = new List<String>();
            //Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            //emailNotToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
            //emailNotToSend.setTreatTargetObjectAsRecipient(false);
            //emailNotToSend.setToAddresses(toRecipients);
            //emailNotToSend.setWhatId(templateContext.Id); 
            //emailNotToSend.setTemplateId(templateId);
            //emailNotToSend.setOrgWideEmailAddressId(TPA_Settings__c.getInstance().TPA_From_Orgwide_Email_Id__c);
            //emailNotToSend.setSaveAsActivity(false);
            //Savepoint sp = Database.setSavepoint();
            //try {
            //    if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
            //        Messaging.SendEmail(New Messaging.SingleEmailMessage[] {emailNotToSend});
            //    }
            //}
            //catch(Exception e)
            //{
            //    System.debug('Email Failed: ' + e.getMessage());
            //}
            //Database.rollback(sp);
            //Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            //emailToSend.setCharset('UTF-8');    
            //emailToSend.setToAddresses(toRecipients);
            //emailToSend.setPlainTextBody(emailNotToSend.getPlainTextBody());
            //emailToSend.setHTMLBody(emailNotToSend.getHTMLBody());
            //emailToSend.setSubject(emailNotToSend.getSubject());
            //emailToSend.setWhatId(templateContext.Id); 
            //emailToSend.setOrgWideEmailAddressId(TPA_Settings__c.getInstance().TPA_From_Orgwide_Email_Id__c);
            //emailToSend.setSaveAsActivity(true);
            //emailToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
            //emailToSend.setTreatTargetObjectAsRecipient(false);
            if(String.IsNotEmpty(tpProcessorEmail )) {
                ccList.add(tpProcessorEmail);
            }
            
            //ccList.add(TPA_Settings__c.getInstance().Shared_Email__c);
            if(TPA_Settings__c.getInstance() != null && TPA_Settings__c.getInstance().TPA_DRN_Mails_Copy_To__c != null && TPA_Settings__c.getInstance().TPA_DRN_Mails_Copy_To__c.length() > 0) {
                for(string mailIdObj: TPA_Settings__c.getInstance().TPA_DRN_Mails_Copy_To__c.split(',')) {
                    if(mailIdObj != null && mailIdObj.trim().length() > 0) {
                        ccList.add(mailIdObj.trim());
                    }   
                }
            }
            
            ccList = UTL_TPA_Multilingual.ccList(templateContext.Client_Address__r.TPAOtherEmailIds__c, ccList);
            
            //emailToSend.setCcAddresses(ccList);
            //msgListToBeSend.add(emailToSend);
            try {
                //if(msgListToBeSend != null && msgListToBeSend.size() > 0 && UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                //    Messaging.sendEmail(msgListToBeSend);
                /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                if(templateContext.TPA_Assigned_TP_Processor__r.Is_Active__c){
                    SRV_TPA_TPARequest.assignedTPProcessorName = templateContext.TPA_Assigned_TP_Processor__r.Initials__c;
                }*/
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toRecipients, ccList, emailType, templateId, templateContext.Id, null, null, false, null, TRUE, TRUE, templateContext);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                
                system.debug('sent submission mail to client');
                //}
            }
            catch(Exception e) {
                System.debug('Email Failed: ' + e.getMessage());
            }
        }
        catch(System.EmailException emlEx) {
            System.debug('Email Failed: ' + emlEx);
        }
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }

}
