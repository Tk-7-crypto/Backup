global class BCH_TPA_VendorSpeNoti_Reminder implements Database.Batchable<sObject>,Database.Stateful ,Database.AllowsCallouts {
    Date todayDate;
    public String awaitingClientConfirmationStatus = UTL_TPA.AWAITING_CLIENT_CONFIRMATION;
    public String pendingCancellationStatus = 'Pending Cancellation';
    public String awaitingAccountMgmtStatus =  'Awaiting Account Mgmt Communication';
    
    List<TPA_request__c> listAgrmt = new List<TPA_request__c>() ;
    public Boolean includeTestDataOnly{
		get{
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}

    global BCH_TPA_VendorSpeNoti_Reminder()
    {
        todayDate = Date.today();
        //includeTestDataOnly = UTL_TPA.runBatchForTestRecords('BCH_TPA_VendorSpeNoti_Reminder');
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'Select id, Vendor_Language__c,TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Vendor_App_Submitted__c, Vendor_Off_Notification_Ack_Date__c, Request_Status__c,is_LAAD_Response_Acknowledged__c,is_LAAD_Response_Required__c, Service_Provider_f__c, Client_Address__r.Name, ClientContact__r.email ,(SELECT id,Vendor_Specific_Notification_Response__c,Pending_Cancellation_Date__c FROM TPA_Agreement_Additional_Fields__r) '
            +' from TPA_request__c where Is_Submitted__c = true'
            +' and ((request_status__c in ( \'' + awaitingClientConfirmationStatus + '\' , \'' + pendingCancellationStatus + '\' , \'' + awaitingAccountMgmtStatus + '\')) or (Request_Status__c in (\'Pending IQVIA Review of Voided Envelope\',\'Awaiting Account Mgmt Communication\',\'' + UTL_TPA.AWAITING_CLIENT_CONFIRMATION + '\',\'Awaiting Client Modification\',\'Awaiting Final Review\',\'In Review By IQVIA\',\'Pending Vendor AMA Fee Acknowledgement\',\'Pending - Vendor Declined AMA Fees\',\'TPA Approved Awaiting AMA Approval\',\'Pending Vendor Response on Data Destruction from Prior TPAs\',\'Hold for TPA non-compliance\') and Pending_Acknowledgements__c includes (\''+ UTL_TPA.Pending_Client_Acknowledgements + '\'))) ';
        //+ ' and Id in (\'a8M0U00000002w1UAA\')' ;
        if(includeTestDataOnly){
            query += ' and (Client_Address__r.Name Like \'Test_'+'%\'  OR Service_Provider_f__c Like \'Test_'+'%\' )';
        }

        if(Test.isRunningTest())
            query += ' limit 5';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> objList)
    {
        List<string> toRecipients = new List<String>();
        List<string> ccRecipients = new List<String>();
        for(sobject sobj : objList)
        {
            TPA_request__c reqObj = (TPA_request__c)sobj;
            
            String query = 'Select id, Vendor_Language__c,TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Client_Confirmation_Requested_Response__c, Client_Confirmation_Req_Form_Sent_Date__c, Client_Project_Name__c, Vendor_App_Submitted__c, Vendor_Off_Notification_Ack_Date__c, Request_Status__c,is_LAAD_Response_Acknowledged__c,is_LAAD_Response_Required__c, Service_Provider_f__c, Client_Address__r.Name, Pending_Acknowledgements__c, Service_Provider_Address__r.Name, ClientContact__r.email, Client_Email__c, Owner.Type, Owner.Email ,Client_TPA_Representative_Email__c, Client_Address__r.TPAOtherEmailIds__c, (SELECT id,Vendor_Specific_Notification_Response__c,Pending_Cancellation_Date__c FROM TPA_Agreement_Additional_Fields__r), ' 
            +' (select Id, Name, Type__c, Email__c from TPA_Request_Contacts__r) from TPA_request__c where Is_Submitted__c = true'
            +' and ((request_status__c in ( \'' + awaitingClientConfirmationStatus + '\' , \'' + pendingCancellationStatus + '\' , \'' + awaitingAccountMgmtStatus + '\')) or (Request_Status__c in (\'Pending IQVIA Review of Voided Envelope\',\'Awaiting Account Mgmt Communication\',\'' + UTL_TPA.AWAITING_CLIENT_CONFIRMATION + '\',\'Awaiting Client Modification\',\'Awaiting Final Review\',\'In Review By IQVIA\',\'Pending Vendor AMA Fee Acknowledgement\',\'Pending - Vendor Declined AMA Fees\',\'TPA Approved Awaiting AMA Approval\',\'Pending Vendor Response on Data Destruction from Prior TPAs\',\'Hold for TPA non-compliance\') and Pending_Acknowledgements__c includes (\''+ UTL_TPA.Pending_Client_Acknowledgements + '\'))) and Id = \'' + reqObj.Id + '\'';
            if(Test.isRunningTest())
                query += ' limit 5';
            List<sObject> sobjList = Database.query(query);
            if(sobjList == null || sobjList.size() == 0) {
                continue;
            }
            else {
                reqObj = (TPA_Request__c)sobjList[0];
            }
            
            if(reqObj.Pending_Acknowledgements__c != null && reqObj.Pending_Acknowledgements__c.indexOf(UTL_TPA.Pending_Client_Acknowledgements) != -1){
                Date sentDate = reqObj.Client_Confirmation_Req_Form_Sent_Date__c;
                Integer daysDiff = 0;
                if(sentDate != null){
                    daysDiff = sentDate.daysBetween(Date.today());
                }
                Integer noOfDays = math.mod((daysDiff), 2);
                if(daysDiff >= 2 && noOfDays == 0 && Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4 ){
                    SRV_TPA_TPARequest.isReminderForExpertAnalysisUseSelected = true;
                    SRV_TPA_TPARequest.sendEmailDirectToClient(reqObj, 'Email Client Confirmation Req', '');
                }
                
            }
            if(reqObj.request_status__c == awaitingClientConfirmationStatus || reqObj.request_status__c == pendingCancellationStatus || reqObj.request_status__c == awaitingAccountMgmtStatus){
                Id reqId = reqObj.id;
                TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
                toRecipients = new List<String>();
                ccRecipients = new List<String>();
                // ccRecipients.add('neha.bansal@metacube.com');
                if(TPA_Settings__c.getOrgDefaults().Shared_Email__c != null)
                    ccRecipients.add(TPA_Settings__c.getOrgDefaults().Shared_Email__c);
                if(TPA_Settings__c.getOrgDefaults() != null && TPA_Settings__c.getOrgDefaults().TPA_DRN_Mails_Copy_To__c != null && TPA_Settings__c.getOrgDefaults().TPA_DRN_Mails_Copy_To__c.length() > 0)
                {
                    for(string mailIdObj: TPA_Settings__c.getOrgDefaults().TPA_DRN_Mails_Copy_To__c.split(','))
                    {
                        if(mailIdObj != null && mailIdObj.trim().length() > 0)
                            ccRecipients.add(mailIdObj.trim());
                    }
                }
                Integer dayDiff = 0;
                Date vendorSubmissionDate;
                Boolean isAlternativeDay = False;
                Boolean isAlternativeDayForPendindCanStatus = False;
                Boolean isThirdDay = False;
                Boolean sendMailforTestRecord = false; 
                system.debug('reqObj.Vendor_App_Submitted__c: '+reqObj.Vendor_App_Submitted__c);
                if(reqObj.Vendor_App_Submitted__c != null)
                {
                    DateTime vendorSubmissionDateTime = reqObj.Vendor_App_Submitted__c;
                    vendorSubmissionDate = date.newinstance(vendorSubmissionDateTime.year(), vendorSubmissionDateTime.month(), vendorSubmissionDateTime.day());
                    dayDiff = vendorSubmissionDate.daysBetween(todayDate);
                    isAlternativeDay = dayDiff != 0 && math.mod(dayDiff, 2) == 0; 
                    isThirdDay = dayDiff != 0 && math.mod(dayDiff, 3) == 0; 
                    sendMailforTestRecord = dayDiff != 0 && math.mod(dayDiff, 1) == 0; 
                }
                system.debug('isAlternativeDay: '+isAlternativeDay+' isThirdDay: '+isThirdDay);
                
                Boolean isAwaitingClientConfirmationStatus = reqObj.Request_Status__c == awaitingClientConfirmationStatus;
                Boolean isAwaitingAccountMgmtStatus = reqObj.Request_Status__c == awaitingAccountMgmtStatus;
                Boolean ispendingCancellationStatus = reqObj.Request_Status__c == pendingCancellationStatus;
                Boolean sendLAADRemindermail = reqObj.is_LAAD_Response_Required__c && !reqObj.is_LAAD_Response_Acknowledged__c; // Added By Neha Bansal Under CR-12175
                Boolean isAckAlready = False;
                if(reqObj.TPA_Agreement_Additional_Fields__r != null && reqObj.TPA_Agreement_Additional_Fields__r.size() > 0  && reqObj.TPA_Agreement_Additional_Fields__r[0].Vendor_Specific_Notification_Response__c != null) {
                    isAckAlready = reqObj.TPA_Agreement_Additional_Fields__r[0].Vendor_Specific_Notification_Response__c.contains('Acknowledge');
                }
                
                system.debug('isAwaitingClientConfirmationStatus'+isAwaitingClientConfirmationStatus+'isAwaitingAccountMgmtStatus'+isAwaitingAccountMgmtStatus+'ispendingCancellationStatus'+ispendingCancellationStatus);
                
                if((reqObj.Service_Provider_f__c != null && reqObj.Service_Provider_f__c.containsIgnoreCase('Test_')) || (reqObj.Client_Address__c !=null && reqObj.Client_Address__r.Name.containsIgnoreCase('Test_'))){
                    if(sendMailforTestRecord){
                        if(isAwaitingClientConfirmationStatus){
                            if(reqObj.ClientContact__r.email != null && reqObj.ClientContact__r.email != '') {
                                toRecipients.add(reqObj.ClientContact__r.email);
                            }
                            if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
                                toRecipients.add(reqObj.Client_TPA_Representative_Email__c);
                            }
                            if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
                                toRecipients.add(reqObj.Owner.Email);
                            }
                            if(reqObj.TP_Processor_Email__c != null && reqObj.TP_Processor_Email__c != '') {
                                ccRecipients.add(reqObj.TP_Processor_Email__c);
                            }
                            if(sendLAADRemindermail){
                                /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                                if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                                SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
                                }*/
                                sendMail(reqObj.Id, toRecipients, ccRecipients, tpaCustomSettings.DirectToClient_LAAD_Ques_Compliance_Temp__c, TRUE, TRUE, reqObj);
                                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                            }
                            else if(!isAckAlready){
                                /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                                if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                                SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
                                }*/
                                sendMail(reqObj.Id, toRecipients, ccRecipients, tpaCustomSettings.VSN_Client_Contact_Notification_Email__c, TRUE, TRUE, reqObj);
                                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                            }
                        }
                        if(isAwaitingAccountMgmtStatus){
                            toRecipients.add(reqObj.TP_Processor_Email__c);
                            /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                            if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                            SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
                            }*/
                            sendMail(reqObj.Id, toRecipients, ccRecipients, tpaCustomSettings.VSN_TP_Processor_Notification_Email__c, TRUE, TRUE, reqObj);
                            //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                        }
                    }
                }
                else{
                    if(isAwaitingClientConfirmationStatus && isThirdDay){ 
                        if(reqObj.ClientContact__r.email != null && reqObj.ClientContact__r.email != '') {
                            toRecipients.add(reqObj.ClientContact__r.email);
                        }
                        if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
                            toRecipients.add(reqObj.Client_TPA_Representative_Email__c); 
                        }
                        if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
                            toRecipients.add(reqObj.Owner.Email);
                        }
                        if(reqObj.TP_Processor_Email__c != null && reqObj.TP_Processor_Email__c != '') {
                            ccRecipients.add(reqObj.TP_Processor_Email__c);
                        }
                        if(sendLAADRemindermail){
                            /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                            if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                            SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
                            }*/
                            sendMail(reqObj.Id, toRecipients, ccRecipients, tpaCustomSettings.DirectToClient_LAAD_Ques_Compliance_Temp__c, TRUE, TRUE, reqObj);
                            //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                        }
                        else if(!isAckAlready){
                            /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                            if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                            SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
                            }*/
                            sendMail(reqObj.Id, toRecipients, ccRecipients, tpaCustomSettings.VSN_Client_Contact_Notification_Email__c, TRUE, TRUE, reqObj);
                            //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                        }
                    } 
                    if(isAwaitingAccountMgmtStatus && isThirdDay){
                        toRecipients.add(reqObj.TP_Processor_Email__c);
                        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
                        }*/
                        sendMail(reqObj.Id, toRecipients, ccRecipients, tpaCustomSettings.VSN_TP_Processor_Notification_Email__c, TRUE, TRUE, reqObj);
                        //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                    }
                }
                
                
                
                Date PendingCancellationDate;
                Integer dayDiffForCancelled;
                if(reqObj.TPA_Agreement_Additional_Fields__r != null && reqObj.TPA_Agreement_Additional_Fields__r.size() > 0 )
                {
                    TPA_Agreement_Additional_Field__c agreementAdditionalFieldData = reqObj.TPA_Agreement_Additional_Fields__r[0];
                    if(agreementAdditionalFieldData.Pending_Cancellation_Date__c != null){
                        DateTime PendingCancellationDateTime = agreementAdditionalFieldData.Pending_Cancellation_Date__c;
                        PendingCancellationDate = date.newinstance(PendingCancellationDateTime.year(), PendingCancellationDateTime.month(), PendingCancellationDateTime.day());
                        dayDiffForCancelled = PendingCancellationDate.daysBetween(todayDate);
                        isAlternativeDayForPendindCanStatus = math.mod(dayDiffForCancelled, 2) == 0;
                    }
                }
                system.debug('ispendingCancellationStatus'+ispendingCancellationStatus+'dayDiffForCancelled'+dayDiffForCancelled);
                if(ispendingCancellationStatus && isAlternativeDayForPendindCanStatus){
                    toRecipients.add(reqObj.ClientContact__r.email);
                    if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
                        toRecipients.add(reqObj.Client_TPA_Representative_Email__c);
                    }
                    if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
                        toRecipients.add(reqObj.Owner.Email);
                    }
                    ccRecipients.add(reqObj.TP_Processor_Email__c);
                    /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                    if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                    SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/
                    sendMail(reqObj.Id, toRecipients, ccRecipients, tpaCustomSettings.VSN_Cancelation_Confirmation__c, TRUE, TRUE, reqObj);
                    //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                }
                else if(ispendingCancellationStatus && dayDiffForCancelled == 30){
                    reqObj.Request_Status__c = 'Cancelled';
                    UTL_TPA.isCancelledBySystem = true;
                    UTL_TPA.isEnvelopeVoided = true;
                    SRV_TPA_DocusignEnvelope.voidEnvelopeCallout(reqObj.id , reqObj.Vendor_Language__c);
                    listAgrmt.add(reqObj);
                }
                
                update listAgrmt; 
            }
            

        }
    }
    public void sendMail(Id reqId, List<string> toRecipients, List<string> ccRecipients, Id templateID, boolean addTPProcessorInitials, boolean addGlobalTPProcessorInitials, TPA_Request__c tpaRequest)
    {
        try
        {
            System.debug('INN!234');
            List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();

            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();

            /*emailNotToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
            emailNotToSend.setTreatTargetObjectAsRecipient(false);
            emailNotToSend.setToAddresses(toRecipients);
            emailNotToSend.setWhatId(reqId);
            emailNotToSend.setTemplateId(templateID);
            emailNotToSend.setOrgWideEmailAddressId(TPA_Settings__c.getOrgDefaults().TPA_From_Orgwide_Email_Id__c);
            emailNotToSend.setSaveAsActivity(false);

            Savepoint sp = Database.setSavepoint();*/
            try
            {
                /*if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                    Messaging.SendEmail(New Messaging.SingleEmailMessage[] {emailNotToSend});
                }*/
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqId);
            }
            catch(Exception e)
            {
                System.debug('Email Failed: ' + e.getMessage());
            }
            //Database.rollback(sp);
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setCharset('UTF-8');
            List<Attachment> lstAttachment = new List<Attachment>();
            lstAttachment = [select Id, Name,Body from Attachment where ParentId =: reqId and Name like '%Offerings Notification%.pdf' order by LastModifiedDate Desc limit 1];
            if(lstAttachment.size() > 0)
            {
                Attachment att = lstAttachment[0];
                List<Messaging.Emailfileattachment> emailAttach = new List<Messaging.Emailfileattachment>();
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(att.Name);
                efa.setBody(att.Body);
                emailAttach.add(efa);
                emailToSend.setFileAttachments(emailAttach);
            }
            emailToSend.setToAddresses(toRecipients);
            emailToSend.setPlainTextBody(emailNotToSend.getPlainTextBody());
            emailToSend.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
            emailToSend.setSubject('Reminder: '+emailNotToSend.getSubject());
            emailToSend.setOrgWideEmailAddressId(TPA_Settings__c.getOrgDefaults().TPA_From_Orgwide_Email_Id__c);
            emailToSend.setWhatId(reqId);
            emailToSend.setSaveAsActivity(true);
            emailToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
            emailToSend.setTreatTargetObjectAsRecipient(false);
            if(addTPProcessorInitials && tpaRequest != null) {
                String assignedTPProcessorInitials = '';
                String globalTPProcessorInitials = '';
                if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                    assignedTPProcessorInitials = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
                }
                if(addGlobalTPProcessorInitials && tpaRequest.Co_Assigned_Global_TP_Processor__r.Is_Active__c ) {
                    globalTPProcessorInitials = tpaRequest.Co_Assigned_Global_TP_Processor__r.Initials__c;
                }
            	emailToSend.setSubject(SRV_TPA_TPARequest.setEmailInitials(assignedTPProcessorInitials, globalTPProcessorInitials, emailToSend.getSubject()));
            }
            if(ccRecipients != null && ccRecipients.size() > 0)
            {
                emailToSend.setCcAddresses(ccRecipients);
            }

            msgListToBeSend.add(emailToSend);
            try
            {
                if(msgListToBeSend != null && msgListToBeSend.size() > 0 && UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                    Messaging.sendEmail(msgListToBeSend);
                }
            }
            catch(Exception e)
            {
                System.debug('Email Failed: ' + e.getMessage());
                //todo
                //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
                //TPAQueryHelper.setLogObject(reqId , 'Exception:Vendor Notification Email NOT Sent ', e.getMessage()+'*'+e.getLineNumber());
                //TPAQueryHelper.logRef().generateLog();
            }
        }
        catch(Exception e)
        {
            System.debug('An exception occurred: ' + e.getMessage());
            //todo
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            //TPAQueryHelper.setLogObject(reqId , 'Exception:Vendor Notification Email NOT Sent ', e.getMessage()+'*'+e.getLineNumber());
            //TPAQueryHelper.logRef().generateLog();
            UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                FALSE, 
                                                UTL_LogFactory.GUID, 
                                                'Exception: Vendor Notification Email NOT Sent' + e.getLineNumber(), 
                                                'TPA', 
                                                'Exception', 
                                                'ERROR', 
                                                ':::BCH_TPA_VendorSpeNoti_Reminder:::sendMail ' + e.getMessage(), 
                                                (reqId != null) ? reqId : '');
        }
    }

    global void finish(Database.BatchableContext BC)
    {

    }
}
