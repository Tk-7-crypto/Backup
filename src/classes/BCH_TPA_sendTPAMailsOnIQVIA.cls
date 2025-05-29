global class BCH_TPA_sendTPAMailsOnIQVIA implements Database.Batchable<sObject>,Database.AllowsCallouts { 
    List<TPA_request__c> listOfRequest = new List<TPA_request__c>() ;
    String REQStatus_AMACancelled = 'AMA Cancelled';
    String REQStatus_AMA_Discontinued = 'AMA Discontinued';
    String REQStatus_AwaitAccMgmtCommunication = 'Awaiting Account Mgmt Communication';
    String REQStatus_AwaitClientConfirmation = UTL_TPA.AWAITING_CLIENT_CONFIRMATION;
    String REQStatus_AwaitClientModification = 'Awaiting Client Modification';
    String REQStatus_AwaitFinalReview = 'Awaiting Final Review';
    String REQStatus_AwaitVendorSignature = 'Awaiting Vendor Signature';
    String REQStatus_AwaitVendorSubmission = 'Awaiting Vendor Submission';
    List<Messaging.SingleEmailMessage> mailListToBeSend;
    List<TPA_AMA_Settings__c> amaSetting;
    public String query = '';
    public String scriptType = '';
    Date todayDate;
    public Set<string> objIDs;
    
    global BCH_TPA_sendTPAMailsOnIQVIA ()
    {
        amaSetting = TPA_AMA_Settings__c.getall().values();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        // String amaCancelationStatus = amaSetting.get(0).Vendor_Renewal_Cancelation_Status__c;
        
        system.debug ('query: '+ query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> objList)
    {
        String emailType;
        String preferredLanguage;
        List<String> toRecipients = new List<String>();
        List<String> ccRecipients = new List<String>();
        mailListToBeSend = new List<Messaging.SingleEmailMessage>();
        todayDate = Date.today(); 
        List<AMA_Agreement_Detail__c> amaAgrList = new List<AMA_Agreement_Detail__c>();
        
                if(scriptType == 'RenewalAndExpirationMail'){
                    sendRenewalAndExpirationMail(objList);
                }
                if(scriptType == 'DayOffExpirationMail'){
                    sendDayOffExpirationMail(objList);
                }
        
        for(sobject sobj : objList){
            if(sobj instanceof TPA_Request__C){
                TPA_request__c reqObj = (TPA_request__c)sobj ;
                Boolean sendLAADRemindermail = reqObj.is_LAAD_Response_Required__c && !reqObj.is_LAAD_Response_Acknowledged__c; 
                Boolean isVSNAckAlready = False;
                if(reqObj.TPA_Agreement_Additional_Fields__r != null && reqObj.TPA_Agreement_Additional_Fields__r.size() > 0  && reqObj.TPA_Agreement_Additional_Fields__r[0].Vendor_Specific_Notification_Response__c != null) {
                    isVSNAckAlready = reqObj.TPA_Agreement_Additional_Fields__r[0].Vendor_Specific_Notification_Response__c.contains('Acknowledge');
                }

                if(scriptType == 'ClientUtilization' && reqObj.Request_Status__c == 'Awaiting Vendor Submission') {
                    sendClientUtilizationmail(reqObj);
                }
                
                if(scriptType == 'ClientConfirmation'){
                    if(reqObj.Request_Status__c == UTL_TPA.AWAITING_CLIENT_CONFIRMATION){
                        if(reqObj.ClientContact__r.email != null && reqObj.ClientContact__r.email != '') {
                            toRecipients = new list<string>{reqObj.ClientContact__r.email};
                            //toRecipients.add(reqObj.ClientContact__r.email);
                        }
                        if(reqObj.TP_Processor_Email__c != null && reqObj.TP_Processor_Email__c != '') {
                            ccRecipients = new List<String>{reqObj.TP_Processor_Email__c};
                            //ccRecipients.add(reqObj.TP_Processor_Email__c);
                        }
                        if(sendLAADRemindermail){
                            sendDyNotificationMail(reqObj.Id, toRecipients, ccRecipients, 'DirectToClient_LAAD_Ques_Compliance_Temp__c');
                        }
                        else if(!isVSNAckAlready){
                            sendDyNotificationMail(reqObj.Id, toRecipients, ccRecipients, 'VSN Client Contact Notification');
                        }
                    }
                }
                if(scriptType == 'AccountMgmtCommunication'){
                    if(reqObj.Request_Status__c == 'Awaiting Account Mgmt Communication'){
                        if(reqObj.TP_Processor_Email__c != null && reqObj.TP_Processor_Email__c != '') {
                            //toRecipients.add(reqObj.TP_Processor_Email__c);
                            toRecipients = new List<String>{reqObj.TP_Processor_Email__c};
                        }
                        sendDyNotificationMail(reqObj.Id, toRecipients, ccRecipients, 'VSN TP Processor Notification');
                    }
                }
                
                
                
            }
            else if(sobj instanceof AMA_Agreement_Detail__c){
                
                AMA_Agreement_Detail__c amaObj = (AMA_Agreement_Detail__c)sobj ;
                
                if(scriptType == 'AMA_OFFSHORE'){
                    if(String.isNotBlank(amaObj.Status_of_Offshore_Process__c) && amaObj.Status_of_Offshore_Process__c == UTL_TPA.AWAITING_AMA_RESPONSE_FOR_OFFSHORE_PROCESS) {
                        sendOffshoreNotificationToDBL(amaObj);
                    }
                }
                if(scriptType == 'FEE_Acknowledgement' && String.isNotBlank(amaObj.TPA_Request__r.Request_Status__c) && amaObj.TPA_Request__r.Request_Status__c == 'Pending Vendor AMA Fee Acknowledgement' && (String.isBlank(amaObj.Vendor_AMA_Fee_Response__c) || !(amaObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('acknowledged') || amaObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('declined') ))){
                    addAMAFeeInvoicedBeforeSignConfirmationMail(amaObj);
                }
                if(scriptType == 'AMA_CANCELATION' && String.isNotBlank(amaObj.Vendor_Reasons_for_Termination__c)){ 
                    if(amaObj.Status_of_Cancelation_Request__c  == 'Awaiting Vendor Cancelation Acknowledgement'){  
                        SendNotificationWithCancelationLink(amaObj);
                    }
                    else if(amaObj.Status_of_Cancelation_Request__c  == 'Awaiting AMA Response to Vendor Cancelation Request'){
                        SendCancelationNotificationToDBL(amaObj);   
                    }
                }  
            }  
        }
        
        try{
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest())
            {     
                Messaging.sendEmail(mailListToBeSend);
                update amaAgrList;
            }
        } 
        
        catch(Exception ex){
            System.debug('in exception');
            System.debug(ex.getMessage());
        } 
    }

    public void sendClientUtilizationmail(TPA_request__c tpaRequest){
        String emailType;
        String preferredLanguage;
        String subject;
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();

        preferredLanguage = tpaRequest.vendor_language__c != null ? tpaRequest.vendor_language__c : (tpaRequest.client_language__c != null ? tpaRequest.client_language__c : 'English');
        
        toAddresses.add(tpaRequest.Vendor_Contact_Email_Client__c );
        
       
        ccAddresses = new List<String>();

        List<TPA_Contact__c> tpaContactList = SRV_TPA_TPARequest.getContactsForRequest(tpaRequest.id);
        if(tpaContactList!= null && tpaContactList.size() > 0)
        {
            for(TPA_Contact__c tpaContact : tpaContactList)
            {
                if(tpaContact.Type__c == 'Additional Vendor Contact')
                {
                    ccAddresses.add(tpaContact.Email__c);
                }
            }
        }

        if(TPA_Settings__c.getInstance() != null && TPA_Settings__c.getInstance().TPA_DRN_Mails_Copy_To__c != null && TPA_Settings__c.getInstance().TPA_DRN_Mails_Copy_To__c.length() > 0)
        {
            for(string mailIdObj: TPA_Settings__c.getInstance().TPA_DRN_Mails_Copy_To__c.split(','))
            {
                if(mailIdObj != null && mailIdObj.trim().length() > 0)
                ccAddresses.add(mailIdObj.trim());
            }
        }
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Reminder of New Request' + preferredLanguage).Translated_Template_Id__c;
        //SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddresses, ccAddresses, 'SendEmail', templateId, tpaRequest.id, null, '', FALSE, '');


    }
    
    //Method to send 10,20,23,26,29,31-day Data Destroy Notificiation mail start
    public static void sendDayOffExpirationMail(TPA_Request__c[] objList){
        BCH_TPA_Vendor_Off_Return_Ack offReturnAck = new BCH_TPA_Vendor_Off_Return_Ack();
        List<string> toRecipients = new List<String>();
        List<string> ccRecipients = new List<String>();
        String preferredLanguage = 'English';
        Date todayDate;
        todayDate = Date.today();
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        
        for(sobject sobj : objList)
        {
            TPA_Request__c requestObj = (TPA_Request__c)sobj;
            
            preferredLanguage = requestObj.vendor_language__c != null ? requestObj.vendor_language__c : 'English';
            system.debug('####BCH_TPA_sendTPAMailsOnIQVIA.execute preferredLanguage: '+preferredLanguage);
            
            toRecipients = new List<String>();
            ccRecipients = new List<String>();
            /*if(TPA_Settings__c.getInstance().Shared_Email__c != null)
ccRecipients.add(TPA_Settings__c.getInstance().Shared_Email__c);*/
            
            toRecipients.add(requestObj.Vendor_e_mail__c);
            if(requestObj.Vendor_e_mail__c != requestObj.Authorized_Signer_Email__c)
                toRecipients.add(requestObj.Authorized_Signer_Email__c);
            
            
            Integer dayDiff = 0;
            Date statusExpiryDate;
            Boolean isEarlyExpired = false;
            Boolean isRenewedReqCancelled = false; 
            if(requestObj.Expired_Date__c != null)
            {
                DateTime earlyExpireDateTime;
                if(requestObj.TPA_Agreement_Additional_Fields__r.size() > 0) {
                    earlyExpireDateTime = requestObj.TPA_Agreement_Additional_Fields__r[0].Early_Contract_Expiry_Date__c;
                }
                if(earlyExpireDateTime != null) {
                    if(requestObj.Renewed_As__c != null 
                       && requestObj.Renewed_As__r.Request_Status__c == 'cancelled' 
                       && requestObj.Renewed_As__r.Cancelled__c >= earlyExpireDateTime) {
                           isRenewedReqCancelled = true;
                           DateTime cancelledDate = requestObj.Renewed_As__r.Cancelled__c;
                           statusExpiryDate = date.newinstance(cancelledDate.year(), cancelledDate.month(), cancelledDate.day());
                       } else {
                           statusExpiryDate = date.newinstance(earlyExpireDateTime.year(), earlyExpireDateTime.month(), earlyExpireDateTime.day());
                       }
                    statusExpiryDate = statusExpiryDate.addDays(-11);
                    dayDiff = statusExpiryDate.daysBetween(todayDate);
                    if(requestObj.Request_Status__c.equalsIgnoreCase(UTL_TPA.EXPIRED)) {
                        isEarlyExpired = true;
                    }
                }
                else {
                    if(requestObj.Renewed_As__c != null 
                       && requestObj.Renewed_As__r.Request_Status__c == 'cancelled'
                       && requestObj.Renewed_As__r.Cancelled__c >= requestObj.Expired_Date__c) {
                           isRenewedReqCancelled = true;
                           system.debug('In Cancelled-Expired');
                           DateTime cancelledDate = requestObj.Renewed_As__r.Cancelled__c;
                           statusExpiryDate = date.newinstance(cancelledDate.year(), cancelledDate.month(), cancelledDate.day());
                       } else {
                           DateTime statusExpiredDateTime = requestObj.Expired_Date__c;
                           statusExpiryDate = date.newinstance(statusExpiredDateTime.year(), statusExpiredDateTime.month(), statusExpiredDateTime.day());
                       }
                    dayDiff = statusExpiryDate.daysBetween(todayDate);
                }
                
                
            }
            
            Integer terminationDayDiff = 0;
            
            if(requestObj.request_termination_time__c != null)
            {
                
                Date statusTerminationDate;
                if(requestObj.Renewed_As__c != null 
                   && requestObj.Renewed_As__r.Request_Status__c == 'cancelled'
                   && requestObj.Renewed_As__r.Cancelled__c >= requestObj.request_termination_time__c) {
                       isRenewedReqCancelled = true;
                       DateTime cancelledDate = requestObj.Renewed_As__r.Cancelled__c;
                       statusTerminationDate = date.newinstance(cancelledDate.year(), cancelledDate.month(), cancelledDate.day());
                   } else {
                       DateTime statusTerminationDateTime = requestObj.request_termination_time__c;
                       statusTerminationDate = date.newinstance(statusTerminationDateTime.year(), statusTerminationDateTime.month(), statusTerminationDateTime.day());
                   }
                
                terminationDayDiff = statusTerminationDate.daysBetween(todayDate);
            }
            
            Integer dayDiffToDisplayInActivity = (requestObj.request_status__c == 'Expired'?dayDiff:terminationDayDiff);
            Boolean isExpired = requestObj.Request_Status__c == 'Expired';
            Boolean isCancelledOrDiscontinued = (requestObj.Request_Status__c == 'AMA Cancelled' || requestObj.Request_Status__c == 'AMA Discontinued' || requestObj.Request_Status__c == 'Client Discontinued' || requestObj.Request_Status__c == amaSetting.get(0).Vendor_Renewal_Cancelation_Status__c); 
            system.debug('####BCH_TPA_sendTPAMailsOnIQVIA.execute dayDiffToDisplayInActivity: '+dayDiffToDisplayInActivity);
            if((dayDiff >= 10 && dayDiff < 20 && isExpired) || (terminationDayDiff >= 10 && dayDiff < 20 && isCancelledOrDiscontinued))
            {
                system.debug('####BCH_TPA_sendTPAMailsOnIQVIA.execute dayDiff or terminationDayDiff: '+dayDiff +' '+' '+terminationDayDiff);
                dayDiffToDisplayInActivity = 10;
                //offReturnAck.sendMail(requestObj, toRecipients, ccRecipients, UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Ack of DD'+preferredLanguage).Translated_Template_Id__c, dayDiffToDisplayInActivity, isRenewedReqCancelled, null);
            }
            else if((dayDiff >= 20 && dayDiff <= 30 && isExpired) || (terminationDayDiff >= 20 && terminationDayDiff <= 30 && isCancelledOrDiscontinued))
            {
                system.debug('20th -30th day');
                
                ccRecipients.add(requestObj.ClientContact__r.Email);
                if(requestObj.TPA_Request_Contacts__r.size() > 0)
                {
                    for(TPA_Contact__c tpaCon : requestObj.TPA_Request_Contacts__r)
                    {
                        ccRecipients.add(tpaCon.Email__c);
                    }
                }
                
                if((dayDiff >= 20 && dayDiff < 23 && isExpired) || (terminationDayDiff >= 20 && terminationDayDiff < 23 && isCancelledOrDiscontinued))
                {
                    system.debug('####BCH_TPA_sendTPAMailsOnIQVIA.execute dayDiff or terminationDayDiff: '+dayDiff +' '+' '+terminationDayDiff);
                    dayDiffToDisplayInActivity = 20;
                    //offReturnAck.sendMail(requestObj, toRecipients, ccRecipients, UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email FollowUp of Ack DD'+preferredLanguage).Translated_Template_Id__c, dayDiffToDisplayInActivity, isRenewedReqCancelled, null);
                }
                if((dayDiff >= 23 && dayDiff < 26 && isExpired) || (terminationDayDiff >= 23 && terminationDayDiff < 26 && isCancelledOrDiscontinued))
                {
                    system.debug('####BCH_TPA_sendTPAMailsOnIQVIA.execute dayDiff or terminationDayDiff: '+dayDiff +' '+' '+terminationDayDiff);
                    dayDiffToDisplayInActivity = 23;
                    //offReturnAck.sendMail(requestObj, toRecipients, ccRecipients, UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email FollowUp of Ack DD'+preferredLanguage).Translated_Template_Id__c, dayDiffToDisplayInActivity, isRenewedReqCancelled, null);
                }
                if((dayDiff >= 26 && dayDiff < 29 && isExpired) || (terminationDayDiff >= 26 && terminationDayDiff < 29 && isCancelledOrDiscontinued))
                {
                    system.debug('####BCH_TPA_sendTPAMailsOnIQVIA.execute dayDiff or terminationDayDiff: '+dayDiff +' '+' '+terminationDayDiff);
                    dayDiffToDisplayInActivity = 26;
                    //offReturnAck.sendMail(requestObj, toRecipients, ccRecipients, UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email FollowUp of Ack DD'+preferredLanguage).Translated_Template_Id__c, dayDiffToDisplayInActivity, isRenewedReqCancelled, null);
                }
                if((dayDiff >= 29 && dayDiff <= 30 && isExpired) || (terminationDayDiff >= 29 && terminationDayDiff <= 30 && isCancelledOrDiscontinued))
                {
                    system.debug('####BCH_TPA_sendTPAMailsOnIQVIA.execute dayDiff or terminationDayDiff: '+dayDiff +' '+' '+terminationDayDiff);
                    dayDiffToDisplayInActivity = 29;
                    //offReturnAck.sendMail(requestObj, toRecipients, ccRecipients, UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email FollowUp of Ack DD'+preferredLanguage).Translated_Template_Id__c, dayDiffToDisplayInActivity, isRenewedReqCancelled, null);
                }
            }
            else if((dayDiff == 31 || dayDiff <= 39 && isExpired) || (terminationDayDiff == 31 || dayDiff <= 39 && isCancelledOrDiscontinued))
            {
                system.debug('31st day');
                system.debug('####BCH_TPA_sendTPAMailsOnIQVIA.execute dayDiffToDisplayInActivity: '+dayDiffToDisplayInActivity);
                ccRecipients.add(requestObj.ClientContact__r.Email);
                if(requestObj.TPA_Request_Contacts__r.size() > 0)
                {
                    for(TPA_Contact__c tpaCon : requestObj.TPA_Request_Contacts__r)
                    {
                        ccRecipients.add(tpaCon.Email__c);
                    }
                }
                ccRecipients.add(requestObj.TP_Processor_Email__c);
                dayDiffToDisplayInActivity = 31;
                system.debug('####BCH_TPA_sendTPAMailsOnIQVIA.execute dayDiffToDisplayInActivity: '+dayDiffToDisplayInActivity);
                //offReturnAck.sendMail(requestObj, toRecipients, ccRecipients, UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email 3Day Notice of Ack DD'+preferredLanguage).Translated_Template_Id__c, dayDiffToDisplayInActivity, isRenewedReqCancelled, null);
            }
            
        }
    }
    //Method to send 10,20,23,26,29,31-day Data Destroy Notificiation mail end
    
    //Method to send Renewal, Pre and Post Expiration Mail start
    public static void sendRenewalAndExpirationMail(TPA_Request__c[] listTpaRequest) {
        
        List<TPA_Request__c> tpaRequestUpdateList = new List<TPA_Request__c>();
        UTL_TPA.notificationsTriggerExecuted = true;
        Date todayDate;
        todayDate = Date.today();
        for(sobject sobj : listTpaRequest) {
            system.debug(2);
            TPA_Request__c tpaObj = (TPA_Request__c)sobj;
            
            Integer dateDifferenceInDays = todayDate <= tpaObj.Data_Access_End_Date__c ? todayDate.daysBetween(tpaObj.Data_Access_End_Date__c) : tpaObj.Data_Access_End_Date__c.daysBetween(todayDate);
            system.debug('dd'+ dateDifferenceInDays+ '-'+3);
            if(todayDate <= tpaObj.Data_Access_End_Date__c) {
                system.debug(4);
                if(dateDifferenceInDays <= 30 && tpaObj.Request_Status__c == 'In Effect') {
                    tpaObj.Is_CPC_Renewal_Notice_Sent__c = true;
                    system.debug(5);
                }
                if(dateDifferenceInDays <= 14 && tpaObj.Request_Status__c == 'In Effect') {
                    tpaObj.Is_CPC_Expiration_Notice_Sent__c = true;
                }
                tpaRequestUpdateList.add(tpaObj);
            }
            else if(tpaObj.Request_Status__c == 'Expired' && todayDate > tpaObj.Data_Access_End_Date__c && dateDifferenceInDays >= 1 && ( tpaObj.TPA_Agreement_Additional_Fields__r.size() == 0 || (tpaObj.TPA_Agreement_Additional_Fields__r.size() > 0 && tpaObj.TPA_Agreement_Additional_Fields__r[0].Early_Contract_Expiry_Date__c == null))) { 
                tpaObj.Is_CPC_Post_Expiration_Notice_Sent__c = true;
                tpaRequestUpdateList.add(tpaObj);
            }
        }
        UTL_TPA.modifyRequestForcefully = true;
        update tpaRequestUpdateList;   
        
        Set<Id> tpaRequestIdsSet = (new Map<Id, TPA_Request__c>(tpaRequestUpdateList)).keySet();
        Set<String> fieldSet = new Set<String> {'Is_CPC_Expiration_Notice_Sent__c',
            'ClientContact__r.Email',
            'ClientContact__r.Name',
            'Is_CPC_Renewal_Notice_Sent__c',
            'Is_CPC_Post_Expiration_Notice_Sent__c',
            'Client_Address__r.TPAOtherEmailIds__c'};
                Map<Id, TPA_Request__c> oldTPARequestMap = new Map<Id, TPA_Request__c>(SLT_TPARequest.instance.getTPARequestById(tpaRequestIdsSet, fieldSet));
        
        String[] batchEmailAddresses = UTL_TPA.batchEmailAddresses.split(',', 0);
        
        Map<Id, TPA_Request__c> mailRenewalListMap = new Map<Id, TPA_Request__c>();
        Map<Id, TPA_Request__c> mailExpirationListMap = new Map<Id, TPA_Request__c>();
        Map<Id, TPA_Request__c> mailPostExpirationListMap = new Map<Id, TPA_Request__c>();
        List<Id> idsToSendRenewalMail = new List<Id>();
        List<Id> idsToSendExpirationMail = new List<Id>();
        List<Id> idsToSendPostExpirationMail = new List<Id>();
        Map<string, List<string>> mapContactCCEmails;
        List<string> contactCCList = new List<string>();
        
        for(TPA_Request__c tpaObj: tpaRequestUpdateList) {
            system.debug('tpaId:'+tpaObj.Id);
            if(tpaObj.Is_CPC_Renewal_Notice_Sent__c
               && tpaObj.Request_Status__c == 'In Effect') {
                   idsToSendRenewalMail.Add(tpaObj.Id);
                   mailRenewalListMap.put(tpaObj.Id, tpaObj);
                   tpaObj.Is_CPC_Renewal_Notice_Sent__c = false;
                   tpaObj.CPC_Renewal_Notice_Sent_Last_Date__c = DateTime.now();
               }
            if(tpaObj.Is_CPC_Expiration_Notice_Sent__c
               && tpaObj.Request_Status__c == 'In Effect') {
                   idsToSendExpirationMail.Add(tpaObj.Id);
                   mailExpirationListMap.put(tpaObj.Id, tpaObj);
                   tpaObj.Is_CPC_Expiration_Notice_Sent__c = false;
                   tpaObj.CPC_Expiration_Notice_Sent_Last_Date__c = DateTime.now();
               }
            if(tpaObj.Is_CPC_Post_Expiration_Notice_Sent__c) {
                idsToSendPostExpirationMail.Add(tpaObj.Id);
                mailPostExpirationListMap.put(tpaObj.Id, tpaObj);
                tpaObj.Is_CPC_Post_Expiration_Notice_Sent__c = false;
                tpaObj.CPC_Expiration_Postnotice_Sent_Last_Date__c = DateTime.now();
            }
        }
            UTL_TPA.modifyRequestForcefully = true;
            update tpaRequestUpdateList;
        
        //send TLLA Renewal Mails
        mapContactCCEmails = getTPAContactEmailList(idsToSendRenewalMail);
        for(Id objId: idsToSendRenewalMail) {
            TPA_Request__c tmpObj = mailRenewalListMap.get(objId);
            contactCCList = mapContactCCEmails.get(objId) != NULL ? mapContactCCEmails.get(objId): new List<String>();
            contactCCList.add(oldTPARequestMap.get(objId).Vendor_e_mail__c);
            for(string mailId: batchEmailAddresses) {
                contactCCList.add(mailId);
            }
            if(oldTPARequestMap.get(objId).tp_processor_email__c != null) {
                contactCCList.add(oldTPARequestMap.get(objId).tp_processor_email__c);
            }
            contactCCList = UTL_TPA_Multilingual.ccList(tmpObj.Client_Address__r.TPAOtherEmailIds__c, contactCCList);
            //SRV_TPA_TPARequest.sendTPANotifications(new List<String>{tmpObj.ClientContact__c}, contactCCList, 'Email Renewal Noti Client', tmpObj.client_language__c, objId, true, null, null);
        }
        
        //send TLLA Expiration Mails
        mapContactCCEmails = getTPAContactEmailList(idsToSendExpirationMail);
        for(Id objId: idsToSendExpirationMail) {
            TPA_Request__c tmpObj = mailExpirationListMap.get(objId);
            contactCCList = mapContactCCEmails.get(objId) != NULL ? mapContactCCEmails.get(objId): new List<String>();
            contactCCList.add(oldTPARequestMap.get(objId).ClientContact__r.Email);
            for(string mailId: batchEmailAddresses) {
                contactCCList.add(mailId);
            }
            if(oldTPARequestMap.get(objId).tp_processor_email__c != null) {
                contactCCList.add(oldTPARequestMap.get(objId).tp_processor_email__c);
            }
            if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
                contactCCList.add(UTL_TPA.sharedEmailAddress);
            }
            
            //SRV_TPA_TPARequest.sendTPANotifications(new List<string>{tmpObj.Vendor_e_mail__c}, contactCCList, 'Email Pending Expiration', tmpObj.vendor_language__c, objId, true, null, null);
        }
        
        //send TLLA Post Expiration Mails
        mapContactCCEmails = getTPAContactEmailList(idsToSendPostExpirationMail);
        for(Id objId: idsToSendPostExpirationMail) {
            TPA_Request__c tmpObj = mailPostExpirationListMap.get(objId);
            contactCCList = mapContactCCEmails.get(objId) != NULL ? mapContactCCEmails.get(objId): new List<String>();
            contactCCList.add(oldTPARequestMap.get(objId).ClientContact__r.Email);
            for(string mailId: batchEmailAddresses) {
                contactCCList.add(mailId);
            }
            if(oldTPARequestMap.get(objId).tp_processor_email__c != null) {
                contactCCList.add(oldTPARequestMap.get(objId).tp_processor_email__c);
            }
            //SRV_TPA_TPARequest.sendTPANotifications(new List<string>{tmpObj.Vendor_e_mail__c}, contactCCList, 'Email Post Expiration', tmpObj.vendor_language__c, objId, true, null, null);
        }
    }
    
    public static Map<string, List<string>> getTPAContactEmailList(List<Id> tpaRequestIdsList) {
        Map<string, List<string>> tpaContacatEmailList = new Map<string, List<string>>();
        List<string> internalObj;
        List<TPA_Contact__c> tpaContactList = new List<TPA_Contact__c>([SELECT TPA_Request__c, Email__c, Name FROM TPA_Contact__c where TPA_Request__c IN : tpaRequestIdsList order by TPA_Request__c]);
        for(TPA_Contact__c tpaContact: tpaContactList) {
            internalObj = tpaContacatEmailList.get(tpaContact.TPA_Request__c);
            if(internalObj == null)
                internalObj = new List<string>();
            system.debug('Email Ids: ' + tpaContact.Email__c);
            internalObj.add(tpaContact.Email__c);
            tpaContacatEmailList.put(tpaContact.TPA_Request__c, internalObj);
        }
        return tpaContacatEmailList;
    }
    //Method to send Renewal, Pre and Post Expiration Mail end
    
    
    //Method to send Revised Offshore Notification mail to DBL Start
    public static void sendOffshoreNotificationToDBL(AMA_Agreement_Detail__c amaAgrObj) { 
        
        System.debug('####sendOffshoreNotificationToDBL');
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();                
        String templateId = amaSetting.get(0).Revised_Offshore_AMA_Reminder_TempId__c;
        Date todayDate;
        todayDate = Date.today();
        
        
        List<String> toAddress = new List<String>();
        List<String> ccTo = new List<String>();
       

        if(String.isNotBlank(amaAgrObj.Client__c) &&
        String.isNotBlank(amaAgrObj.Vendor_Legal_Name__c) &&
        (!amaAgrObj.Client__c.startsWithIgnoreCase('Test') && !amaAgrObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))){
            toAddress.add(UTL_TPA.dblContractContactEmail);
        }
        
        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c)) {
            ccTo = amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c.split(';');
        }
        
     
        try {
            //SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '');
            amaAgrObj.Last_AMA_offshore_reminder_mail_sent__c = todayDate;
            update amaAgrObj;
        } catch(Exception e) {
            System.debug('Offshore Notification sent to DBL failed: ' + e.getMessage());
        }
    }
    //Method to send Revised Offshore Notification mail to DBL End
    
    //Method to sending mail to vendor for invoiced confirmation start
    public static string addAMAFeeInvoicedBeforeSignConfirmationMail(AMA_Agreement_Detail__c  amaAgreementDetailObj)
    {
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        
        List<String> toAddress = new List<String>();
        List<String> ccTo = new List<String>();
        if(String.isNotBlank(amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c) && String.isNotBlank(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c) && !amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c.equalsIgnoreCase(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c)) {
            toAddress.add(amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c);
            toAddress.add(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c);
        }
        else {
            if(String.isNotBlank(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c))
                toAddress.add(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c);
            else
                toAddress.add(amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c);
        }
        
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        
        if(String.isNotBlank(tpaCustomSettings.TP_US_Mail_Id__c))
        {
            ccTo = tpaCustomSettings.TP_US_Mail_Id__c.split(',');
            if(String.isNotBlank(amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c)) {
                List<String> addCCTo = amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c.split(';');
                ccTo.addAll(addCCTo);
            }
        }
        
        //String targetObjectId = amaSetting.get(0).Vendor_Contact_ID__c;
        //mail.setTargetObjectId(targetObjectId);
        //mail.setTreatTargetObjectAsRecipient(false);
        try {
            //SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', amaSetting.get(0).Fee_Confirm_Before_Sign_Reminder_Temp__c, amaAgreementDetailObj.Id, null, '', FALSE, '');
        }catch(Exception e) {
            System.debug('send ama fee notification to vendor failed : ' + e.getMessage());
            return 'error';
        }
        return 'success';  
    }
    //Method to sending mail to vendor for invoiced confirmation end
    
    //Method to send Awaiting Vendor Cancelation Acknowledgement mail start
    public static void SendNotificationWithCancelationLink(AMA_Agreement_Detail__c  amaAgrObj)
    {        
        
        Date todayDate;
        todayDate = Date.today(); 
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        
        //email.setTargetObjectId(amaSetting.get(0).Vendor_Contact_ID__c );
        
        
        List<String> toAddress= new List<String>{amaAgrObj.TPA_Request__r.TP_Processor_Email__c, ((amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c == null || amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c.length() == 0) ? amaAgrObj.TPA_Request__r.Vendor_Contact_Email_Client__c : amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c)};
            List<String> ccTo= new List<String>();

        if(toAddress.isEmpty() && String.isNotBlank(amaSetting.get(0).Dev_Mail_ID__c)){
            
            toAddress = amaSetting.get(0).Dev_Mail_ID__c.split(';'); 
        }
        
        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_Vendor_Cancelation_Mail__c)){
            
            ccTo = amaSetting.get(0).CC_Address_For_Vendor_Cancelation_Mail__c.split(';');
        }
        
        try{
            //SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', amaSetting.get(0).Vendor_Cancelation_Reminder_Template_Id__c, amaAgrObj.Id, null, '', FALSE, '');
            amaAgrObj.Last_Vendor_Reminder_Mail_Sent__c = todayDate;
            update amaAgrObj;
        }
        catch(Dmlexception ex){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::BCH_TPA_sendTPAMailsOnIQVIA:::SendNotificationWithCancelationLink', (amaAgrObj != null && amaAgrObj.TPA_Request__c != null) ? amaAgrObj.TPA_Request__c : ''));
            System.debug(ex.getMessage());
        }
        catch(Exception e){
            
            System.debug('Email Failed: ' + e.getMessage());
        }
    }
    //Method to send Awaiting Vendor Cancelation Acknowledgement mail end
    
    //Method for Send Cancelation notification mail to DBL Start
    public static void SendCancelationNotificationToDBL(AMA_Agreement_Detail__c amaAgrObj){
        
        Date todayDate;
        todayDate = Date.today(); 
        List<TPA_AMA_Settings__c> amaSetting =  TPA_AMA_Settings__c.getall().values();
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();                
        String templateId = amaSetting.get(0).AMA_Cancelation_Reminder_Template_Id__c;
       // String dblContractsContactId = tpaCustomSettings.DBL_Contracts_Contact_Id__c; 
        
        List<String> toAddress = new List<String>();
        List<String> ccTo = new List<String>();

        if(String.isNotBlank(amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c )) {
            toAddress = amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c.split(';');
        }

        if(String.isNotBlank(amaAgrObj.Client__c) &&
        String.isNotBlank(amaAgrObj.Vendor_Legal_Name__c) &&
        (!amaAgrObj.Client__c.startsWithIgnoreCase('Test') && !amaAgrObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))){
            toAddress.add(UTL_TPA.dblContractContactEmail);
        }
        
        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_DBL_Cancelation_Mail__c)){
            ccTo = amaSetting.get(0).CC_Address_For_DBL_Cancelation_Mail__c.split(';');
        }
       
        try {
            //SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', amaSetting.get(0).Cancelation_Link_For_DBL_Template_ID__c, amaAgrObj.Id, null, '', FALSE, '');
            amaAgrObj.Last_AMA_Reminder_Mail_Sent__c = todayDate;
            update amaAgrObj;
        }catch(Dmlexception ex){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::BCH_TPA_sendTPAMailsOnIQVIA:::SendCancelationNotificationToDBL', (amaAgrObj != null && amaAgrObj.TPA_Request__c != null) ? amaAgrObj.TPA_Request__c : ''));
            System.debug(ex.getMessage());
        } catch(Exception e) {
            System.debug('Send Cancelation notification mail to DBL failed: ' + e.getMessage());
        }
        
    }
    //Method for Send Cancelation notification mail to DBL End
    
    public void sendDyNotificationMail(Id reqId, List<string> toRecipients, List<string> ccRecipients, String emailType)
    {
        try
        {
            Id templateID = UTL_TPA_Multilingual.getEmailTemplateId(emailType, 'English');
            
            List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
            
            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            
            emailNotToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
            emailNotToSend.setTreatTargetObjectAsRecipient(false);
            emailNotToSend.setToAddresses(toRecipients);
            emailNotToSend.setWhatId(reqId);
            emailNotToSend.setTemplateId(templateID);
            emailNotToSend.setOrgWideEmailAddressId(TPA_Settings__c.getOrgDefaults().TPA_From_Orgwide_Email_Id__c);
            emailNotToSend.setSaveAsActivity(false);
            
            Savepoint sp = Database.setSavepoint();
            try
            {
                if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                    Messaging.SendEmail(New Messaging.SingleEmailMessage[] {emailNotToSend});
                }
            }
            catch(Exception e)
            {
                System.debug('Email Failed: ' + e.getMessage());
            }
            Database.rollback(sp);
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
            
            if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
                ccRecipients.add(UTL_TPA.sharedEmailAddress);
            }
            
            if(UTL_TPA.DRNEmailCopyAddress != null) {
                for(String emailToCc: UTL_TPA.DRNEmailCopyAddress.split(',')) {
                    ccRecipients.add(emailToCc);
                }
            }
            emailToSend.setToAddresses(toRecipients);
            emailToSend.setPlainTextBody(emailNotToSend.getPlainTextBody());
            emailToSend.setHTMLBody(emailNotToSend.getHTMLBody());
            emailToSend.setSubject('Reminder: '+emailNotToSend.getSubject());
            emailToSend.setOrgWideEmailAddressId(TPA_Settings__c.getOrgDefaults().TPA_From_Orgwide_Email_Id__c);
            emailToSend.setWhatId(reqId);
            emailToSend.setSaveAsActivity(true);
            emailToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
            emailToSend.setTreatTargetObjectAsRecipient(false);
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
            }
        }
        catch(Exception e)
        {
            System.debug('An exception occurred: ' + e.getMessage());
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
