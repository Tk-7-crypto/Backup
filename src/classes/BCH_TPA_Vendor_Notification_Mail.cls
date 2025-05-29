global class BCH_TPA_Vendor_Notification_Mail implements Database.Batchable<sObject>,Database.Stateful {
    public Boolean remindTPProcessortype = false;
    public Date todayDate;
    public Boolean includeTestDataOnly {
		get{
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}

    global BCH_TPA_Vendor_Notification_Mail () {
        todayDate = Date.today();
        //includeTestDataOnly = UTL_TPA.runBatchForTestRecords('BCH_TPA_Vendor_Notification_Mail');
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //Updated by Babita Dadarwal under ER-1940 Start
        String query = '';
        if(!remindTPProcessortype){
            query = 'Select id, Manual_Trigger_Reasons__c, Service_Provider_f__c, Client_Address__r.Name,Prevent_Cancellation__c,isCancellationNoticeSentForSignature__c,isCancellationNoticeSentForSubmission__c, ClientContact__r.email, Client_TPA_Representative_Email__c, name, Request_Status__c, '
                     + 'data_access_end_date__c, Vendor_e_mail__c, '
                     + ' Vendor_contact_email_client__c, Vendor_App_Sent__c, Sent_for_Signature__c, Client_Address__r.TPAOtherEmailIds__c, ' 
                     + 'Vendor_Language__c, Client_Language__c, TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Stop_TLLA_Generation_Notice_Sent_Date__c ' 
               + 'from TPA_request__c  '
               + 'where Vendor_contact_email_client__c != null ' 
               + 'and (Request_Status__c = \'Awaiting Vendor Submission\' or Request_Status__c = \'Awaiting Vendor Signature\' or Request_Status__c = \'Pending Vendor Response on Data Destruction from Prior TPAs\' or (Request_Status__c = \'In Review By IQVIA\' and Manual_Trigger_Reasons__c includes (\'Vendor DDN Acknowledgement Outstanding\'))) ' 
               + 'and Is_Submitted__c = true ' 
               + 'and Is_Vendor_Id_Invalid__c = false ';
               //+ ' and Id in (\'a8M0U00000004A5UAI\')' ;
               //and Id = \'a3S4C0000008RZBUA2\' ';//or Id = \'a3Sc00000009qL3EAI\')'; //Modified by C.P.Pandey under Issue-7112 // Updated by Babita Dadarwal under Issue-07855 and ER-2316,Modified by Govind under Issue-8019
               //Updated by Babita Dadarwal under ER-1940 End 
        }
        else{

            query = 'select id,Name,TP_Processor_Email__c,TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Client_Request_Submission__c,Vendor_App_Submitted__c, Data_Access_End_Date__c,Request_Status__c'+
            +',Vendor_Language__c from TPA_request__c where Is_Submitted__c = true and Request_Status__c = \'In Review By IQVIA\' and Data_Access_End_Date__c > '+(Datetime.now()).format('yyyy-MM-dd'); 
            
        }
        //if(UTL_TPA.includeTestDataOnlyinVendorNotiBatch)
        if(includeTestDataOnly){
            query += ' and (Client_Address__r.Name Like \'Test_'+'%\'  OR Service_Provider_f__c Like \'Test_'+'%\' )';
        }

        
        if(Test.isRunningTest())
            query += ' limit 3';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> objList) {
        if(remindTPProcessortype) {
            for(sobject obj : objList) {
                TPA_Request__c reqObj = (TPA_Request__c)obj;
                List<dsfs__DocuSign_Status__c> docuSign = new List<dsfs__DocuSign_Status__c>();
                if(reqObj != null  ) {
                    system.debug('docuSign');
                    system.debug('kanak');
                    docuSign = [select id,name,dsfs__Completed_Date_Time__c, dsfs__Envelope_Status__c,dsfs__Voided_Reason__c,dsfs__Voided_Date_Time__c from dsfs__DocuSign_Status__c  where TPA_Request__c =: reqObj.Id order by createddate desc limit 1] ;
                }
                if(docuSign != null && docuSign.size() >0) {
               	    system.debug('docuSign'+docuSign);
                    system.debug('docuSignreqObj'+reqObj.Name);
                    Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{'English_Translation__c','Japanese_Translation__c'});
                    String voidReason = multilanguageUtilityMap == null ? 'Account Placed on Hold due to Failure to Acknowledge DDN' : (String)multilanguageUtilityMap.get(reqObj.Vendor_Language__c + '_Translation__c~TPA_Request__c~Record~On_Hold')[0].get(reqObj.Vendor_Language__c + '_Translation__c');
                    if((Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4  || Test.isRunningTest())&&(reqObj.Request_Status__c == 'In Review By IQVIA' && docuSign[0].dsfs__Envelope_Status__c== 'voided' && docuSign[0].dsfs__Voided_Reason__c == voidReason && (docuSign[0].dsfs__Voided_Date_Time__c > reqObj.Client_Request_Submission__c || docuSign[0].dsfs__Voided_Date_Time__c >reqObj.Vendor_App_Submitted__c))) {
                        // updateActivityHistory(reqObj, 'In Review By IQVIA');
                        system.debug('insidemail');
                        SRV_TPA_TPARequest.sendReminderMailtoTPProcessorAbtStatusUpdate(reqObj);
                        system.debug('outsidemail');
                    }   //ER-13310
                }
            }
        }
        else {
            Set<Id> setVendorID = new Set<Id>();
            Set<Id> setRequestID = new Set<Id>();
            Map<Id,Address__c> mapAddressIdWithRecord = new Map<Id,Address__c>();

            for(sobject sobj : objList) {
                TPA_Request__c objRequest = (TPA_Request__c)sobj ;
                setRequestID.add(objRequest.id);
            }
            
            for(TPA_Request__c reqObj : [Select Service_Provider_Address__c, Service_Provider_Address__r.Parent_Vendor_Name__c, Service_Provider_Address__r.Primary_Vendor_Address__c from TPA_Request__c where id in: setRequestID]) {
                if(reqObj.Service_Provider_Address__c != Null ) {
                    if(reqObj.Service_Provider_Address__r.Primary_Vendor_Address__c == true) {
                        setVendorID.add(reqObj.Service_Provider_Address__c);
                    }
                    else if(reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c != null) {
                        setVendorID.add(reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c);
                    }
                    
                }
            }

            for(Address__c addObj : [Select id, (select id, Return_Destruction_Ack_Outstanding__c, DDN_Ack_Pending_Requests__c from TPA_Master_Extension_Informations__r)
                from Address__c where id IN: setVendorID]) { 
                    mapAddressIdWithRecord.put(addObj.id, addObj);
            }

            for(sobject sobj : objList) {
                TPA_Request__c reqObj = (TPA_Request__c)sobj;
                
                String query = 'Select id, Owner.Type, Owner.Email, Client_TPA_Representative_Email__c,Service_Provider_f__c, Manual_Trigger_Reasons__c, Client_Address__r.Name,Prevent_Cancellation__c,isCancellationNoticeSentForSignature__c,isCancellationNoticeSentForSubmission__c, ClientContact__r.email, name, Request_Status__c, '
                         + 'data_access_end_date__c, Vendor_e_mail__c, Service_Provider_Address__c,Service_Provider_Address__r.Parent_Vendor_Name__c,Service_Provider_Address__r.Primary_Vendor_Address__c, Service_Provider_Address__r.Parent_Vendor_Name__r.id, '
                         + ' Vendor_contact_email_client__c, Vendor_App_Sent__c, Sent_for_Signature__c, Client_Address__r.TPAOtherEmailIds__c, Service_provider_Address__r.TPAOtherEmailIds__c, ' 
                         + 'Vendor_Language__c, Client_Language__c, TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Stop_TLLA_Generation_Notice_Sent_Date__c '
                         + ', Vendor_Address_Extension_Record__r.DDN_Ack_Pending_Requests__c, Vendor_Address_Extension_Record__r.Return_Destruction_Ack_Outstanding__c , Vendor_Compliance_Email__c, Authorized_Signer_Email__c, (Select Id, Email__c From TPA_Request_Contacts__r) '
                   + 'from TPA_request__c  '
                   + 'where Vendor_contact_email_client__c != null ' 
                   + 'and (Request_Status__c = \'Awaiting Vendor Submission\' or Request_Status__c = \'Awaiting Vendor Signature\' or Request_Status__c = \'Pending Vendor Response on Data Destruction from Prior TPAs\' or (Request_Status__c = \'In Review By IQVIA\' and Manual_Trigger_Reasons__c includes (\'Vendor DDN Acknowledgement Outstanding\'))) ' 
                   + 'and Is_Submitted__c = true ' 
                   + 'and Is_Vendor_Id_Invalid__c = false and Id = \'' + reqObj.Id + '\'';
                if(Test.isRunningTest())
                    query += ' limit 3';
                List<sObject> sobjList = Database.query(query);
                if(sobjList == null || sobjList.size() == 0) {
                    continue;
                }
                else {
                    reqObj = (TPA_Request__c)sobjList[0];
                }
                
                if(reqObj.data_access_end_date__c >= todayDate) {
                    
                    String clientLanguage = reqObj.Client_Language__c != null ? reqObj.Client_Language__c : 'English';
                    //Action required mail will go in client languge if vendor language is not available.
                    String vendorLanguage = reqObj.Vendor_Language__c != null ? reqObj.Vendor_Language__c : clientLanguage;
                    
                    
                    List<String> ccAddresses = new List<string>();
                    List<TPA_Request__c> DDNAckPendingRecords = new List<TPA_Request__c>();
                        
                    if(UTL_TPA.tpaSetting != null && UTL_TPA.tpaSetting.TPA_DRN_Mails_Copy_To__c != null && UTL_TPA.tpaSetting.TPA_DRN_Mails_Copy_To__c.length() > 0) {
                        for(string mailIdObj: UTL_TPA.tpaSetting.TPA_DRN_Mails_Copy_To__c.split(',')) {
                            if(mailIdObj != null && mailIdObj.trim().length() > 0)
                                ccAddresses.add(mailIdObj.trim());
                        }
                    }
                    
                    ccAddresses = UTL_TPA_Multilingual.ccList(reqObj.Client_Address__r.TPAOtherEmailIds__c, ccAddresses);//Added by Rajendra under ER-11762
                    
                    List<TPA_Contact__c> tpaContactList = SRV_TPA_TPARequest.getContactsForRequest(reqObj.Id);
                    if(tpaContactList!= null && tpaContactList.size() > 0) {
                        for(TPA_Contact__c tpaContact : tpaContactList) {
                            if(tpaContact.Type__c == 'Additional Client Contact' || tpaContact.Type__c == 'Additional Contact' ) {
                                ccAddresses.add(tpaContact.Email__c);
                            }
                        }
                    }

                    if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
                        ccAddresses.add(reqObj.Client_TPA_Representative_Email__c);
                    }

                    if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
                        ccAddresses.add(reqObj.Owner.Email);
                    }
                    
                    if(reqObj.Request_Status__c == 'Awaiting Vendor Submission'  && !reqObj.isCancellationNoticeSentForSubmission__C && (Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4  || Test.isRunningTest()))//Modified by Govind under ER-3340
                    {
                        system.debug('vendorLanguage = ' + vendorLanguage + ' clientLanguage = ' + clientLanguage );
                        if(reqObj.Stop_TLLA_Generation_Notice_Sent_Date__c == null) {
                            /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                            if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                               SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
                            }*/
                            sendMail( new List<String>{ reqObj.Vendor_contact_email_client__c }, '', reqObj.id , vendorLanguage, reqObj);
                            //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                        }
                        
                        system.debug('done submission mail to vendor');
                        
                        
                        if(reqObj.Vendor_App_Sent__c != null) {
                            Date vendorAppSentDate = date.newinstance(reqObj.Vendor_App_Sent__c.year(), reqObj.Vendor_App_Sent__c.month(), reqObj.Vendor_App_Sent__c.day());
                            if(vendorAppSentDate.daysBetween(todayDate) !=0 ) {
                                
                                if((reqObj.Service_Provider_f__c != null && reqObj.Service_Provider_f__c.containsIgnoreCase('Test_')) || (reqObj.Client_Address__c !=null && reqObj.Client_Address__r.Name.containsIgnoreCase('Test_')) && reqObj.Stop_TLLA_Generation_Notice_Sent_Date__c == null) {//Modified by Rajendra under ER-3550
                                    sendAwaitingVendorSubmissionReminderMailToClient(reqObj, reqObj.Id,new List<String>{ reqObj.ClientContact__r.email }, clientLanguage , ccAddresses);                                    
                                }
                                else {
                                    system.debug('no of days not zero');
                                    Integer noOfDays = math.mod((vendorAppSentDate.daysBetween(todayDate)), 7);// updated for testing replace '2' with '7'
                                    system.debug('mod 7 - ' + noOfDays );
                                    if(noOfDays == 0) {
                                        sendAwaitingVendorSubmissionReminderMailToClient(reqObj, reqObj.Id,new List<String>{ reqObj.ClientContact__r.email }, clientLanguage , ccAddresses);
                                        system.debug('done submission mail to client');
                                    }
                                }
                                
                            }
                        }
                        
                    }
                    
                    else if(reqObj.Request_Status__c == 'Awaiting Vendor Signature' && !reqObj.isCancellationNoticeSentForSignature__c && !reqObj.Prevent_Cancellation__c)//Modified by Govind under ER-3340
                    {
                        
                        if(reqObj.Sent_for_Signature__c != null) {
							if(reqObj.TP_Processor_Email__c != null){
								ccAddresses.add(reqObj.TP_Processor_Email__c);
							}
                            if(reqObj.Vendor_Compliance_Email__c != null){
                                ccAddresses.add(reqObj.Vendor_Compliance_Email__c);
                            }
                            if(reqObj.Vendor_Contact_Email_Client__c  != null){
                                ccAddresses.add(reqObj.Vendor_Contact_Email_Client__c);
                            }
                            if(reqObj.Authorized_Signer_Email__c != null){
                                ccAddresses.add(reqObj.Authorized_Signer_Email__c);
                            }
                            if(reqObj.TPA_Request_Contacts__r != null && reqObj.TPA_Request_Contacts__r.size() > 0){
                                for(TPA_Contact__c tpaContact : reqObj.TPA_Request_Contacts__r ){
                                    if(tpaContact.Email__c != null){
                                        ccAddresses.add(tpaContact.Email__c);
                                    }
                                }
                            }
                            if(reqObj.Service_provider_Address__r.TPAOtherEmailIds__c != null){
                                ccAddresses = UTL_TPA_Multilingual.ccList(reqObj.Service_provider_Address__r.TPAOtherEmailIds__c, ccAddresses);
                            }
							system.debug('Awaiting Vendor Signature'+reqObj.Sent_for_Signature__c);
                            if(reqObj.Sent_for_Signature__c + 90 >= todayDate) {
                                Date sentForSignatureDate = date.newinstance(reqObj.Sent_for_Signature__c.year(), reqObj.Sent_for_Signature__c.month(), reqObj.Sent_for_Signature__c.day());
                                if(sentForSignatureDate.daysBetween(todayDate) !=0 ) {
                                    
                                    if((reqObj.Service_Provider_f__c != null && reqObj.Service_Provider_f__c.containsIgnoreCase('Test_')) || (reqObj.Client_Address__c !=null && reqObj.Client_Address__r.Name.containsIgnoreCase('Test_'))) {
                                        System.debug('In Sending mail If'+ ccAddresses);
                                        sendAwaitingSignatureReminderMailToClient(reqObj, reqObj.Id,new List<String>{ reqObj.ClientContact__r.email }, clientLanguage, ccAddresses); 
                                    }
                                    else {
                                        
                                        system.debug('no of days not zero');
                                        Integer noOfDays = math.mod((sentForSignatureDate.daysBetween(todayDate)), 7);// updated for testing replace '2' with '7'
                                        system.debug('mod 7 - ' + noOfDays );
                                        if(noOfDays == 0) {
                                            sendAwaitingSignatureReminderMailToClient(reqObj, reqObj.Id,new List<String>{ reqObj.ClientContact__r.email }, clientLanguage, ccAddresses);//Updated by Babita Dadarwal under ER-1940 //Updated by Neha Bansal under Issue-10561
                                            system.debug('done signature mail to client');
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else if((Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4  || Test.isRunningTest()) && (reqObj.Request_Status__c == 'Pending Vendor Response on Data Destruction from Prior TPAs' || (reqObj.Request_Status__c == 'In Review By IQVIA' && reqObj.Manual_Trigger_Reasons__c.contains('Vendor DDN Acknowledgement Outstanding')))) {
                        if(reqObj.Service_Provider_Address__c != null && (reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c != null
                                || reqObj.Service_Provider_Address__r.Primary_Vendor_Address__c == true)) {
                            Id vendorAddId = null;
                            if(reqObj.Service_Provider_Address__r.Primary_Vendor_Address__c == true) {
                                vendorAddId = reqObj.Service_Provider_Address__c;
                            }
                            else if(reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c != null) {
                                vendorAddId = reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c;
                            }
                            Address__c addObj = mapAddressIdWithRecord.get(vendorAddId);
                            if(addObj.TPA_Master_Extension_Informations__r != null && addObj.TPA_Master_Extension_Informations__r.size() > 0
                               && addObj.TPA_Master_Extension_Informations__r[0].Return_Destruction_Ack_Outstanding__c == true 
                               && addObj.TPA_Master_Extension_Informations__r[0].DDN_Ack_Pending_Requests__c != null) {
                                List<String> lstOfRequest = addObj.TPA_Master_Extension_Informations__r[0].DDN_Ack_Pending_Requests__c.split(', ');
                                DDNAckPendingRecords = [Select id, Service_Provider_f__c, Service_Provider_Contact_f__c, 
                                                        Vendor_Contact_e_mail__c, name, ClientContact__r.Email 
                                                        , Vendor_e_mail__c, Authorized_Signer_Email__c,
                                                        (select id, Email__c, Type__c from TPA_Request_Contacts__r) from TPA_Request__c 
                                                        where name IN : lstOfRequest];
                                sendDataDestructionAckOutstandingMail(DDNAckPendingRecords, reqObj);
                            }
                        }
                    }
                    
                }
            }
        }
    }

    public void sendDataDestructionAckOutstandingMail( List<TPA_Request__c> DDNAckPendingRecords, TPA_Request__c request){
        String subjText;
        String bodyText;
        String preferredLanguage;
        String templateID;
        String emailBody;
        String priorTPAs;
        String priorVendorcontactname;
        String priorVendorcontactemail;
        String priorDDNAckLink;
        if(DDNAckPendingRecords != null && DDNAckPendingRecords.size() > 0) {
            preferredLanguage = request.vendor_language__c != null ? request.vendor_language__c : 'English';
            Set<string> langSet = new Set<string>();
            String preferredLangField = UTL_TPA_Multilingual.supportedLanguageFieldMap.get(preferredLanguage);
            langSet.add(preferredLangField);
            Map<String, List<TPA_Language_Cross_Walk__c>> langCrossWalkMap = UTL_TPA_Multilingual.getTranslatedValueMap(langSet);
            if(langCrossWalkMap != null) {
                priorTPAs = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorTPAs')[0].get(preferredLangField);
                priorVendorcontactname = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorVendorcontactname')[0].get(preferredLangField);
                priorVendorcontactemail = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorVendorcontactemail')[0].get(preferredLangField);
                priorDDNAckLink = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorDDNAckLink')[0].get(preferredLangField);
            }

            templateID = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email TPA Request on Hold'+preferredLanguage).Translated_Template_Id__c;
            system.debug('templateID1'+templateID);
            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            if(templateID != '' && templateID != null) {        
                try {
                    system.debug('templateID'+templateID);
                    emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, request.Id);
                } catch(Exception exp) {
                    System.debug(templateID + ' Email Failed: ' + exp.getMessage());
                }
                emailBody = emailNotToSend.getHTMLBody();
                subjText = emailNotToSend.getSubject();
                subjText = 'Reminder: ' + subjText;
                String URL = '';
                bodyText = '<div style="background-color=white;text-align=left;">';
                bodytext += '<table style="border-collapse: collapse;border:1px solid;width: 80%;"><tr><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorTPAs+'</th><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorVendorcontactname+'</th><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorVendorcontactemail+'</th><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorDDNAckLink+'</th></tr>';
                
                if(DDNAckPendingRecords != null && DDNAckPendingRecords.size() > 0) {
                    for(TPA_Request__c reqObj : DDNAckPendingRecords){
                        URL = UTL_TPA.tpaSetting.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_VendorOfferingReturnAck&id='+ reqObj.Id;
                        bodytext += '<tr><td style="font-size:13px;font-family:arial;border:1px solid;">' + reqObj.name + '</td><td style="border:1px solid;font-size:13px;font-family:arial;">'+reqObj.Service_Provider_Contact_f__c+'</td><td style="border:1px solid;font-size:13px;font-family:arial;">'+reqObj.Vendor_Contact_e_mail__c+'</td><td style="font-size:13px;font-family:arial;border:1px solid;">' + '<a href=' + url + '>' + ' Click here'+ '</a>' + '</td></tr>';
                        
                        if(reqObj.Vendor_e_mail__c != null && reqObj.Vendor_e_mail__c.length() > 0){
                            ccAddresses.Add(reqObj.Vendor_e_mail__c);
                        }
                        if(reqObj.Authorized_Signer_Email__c != null && reqObj.Authorized_Signer_Email__c.length() > 0){
                            ccAddresses.Add(reqObj.Authorized_Signer_Email__c);
                        }

                        if(reqObj.TPA_Request_Contacts__r != null && reqObj.TPA_Request_Contacts__r.size() > 0) {
                            for(TPA_Contact__c tpaContact : reqObj.TPA_Request_Contacts__r) {
                                if(tpaContact.Type__c == 'Additional Vendor Contact') {                    
                                    ccAddresses.add(tpaContact.Email__c);
                                }
                            }
                        }
                    }
                }
                
                bodytext += '</table>';
                bodytext += '</div>';
                emailBody = emailBody.replace('[Prior_TPA_Table]', bodyText);
            }
            
            
            //toAddresses.add('neha.bansal@metacube.com');
            if(request.Vendor_Contact_Email_Client__c != null) {
                toAddresses.add(request.Vendor_Contact_Email_Client__c);
            }
            if(request.TP_Processor_Email__c != null) {
                toAddresses.add(request.TP_Processor_Email__c);
            }
            
            
            if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
                ccAddresses.add(UTL_TPA.sharedEmailAddress);
            }
            
            try{
                if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()){
                    System.debug('in sendDataDestructionAckOutstandingMail Email send: ');
                    /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                    if(request.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        SRV_TPA_TPARequest.assignedTPProcessorName = request.TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/
                    SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddresses, ccAddresses, 'SendEmail', null, request.Id, null, subjText, FALSE, emailBody, TRUE, TRUE, request);
                    //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                }
            }
            catch(Exception e){
                System.debug('Email Failed: ' + e.getMessage());
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_request:::sendDataDestructionAckOutstandingMail', request != null ? request.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
        }
        
    }

    // Function to send Awaiting Vendor Submission Reminder Mail to client
    public void sendAwaitingVendorSubmissionReminderMailToClient(TPA_Request__c reqObj, Id templateContextId, List<string> toRecipients , string clientLanguage, List<string> cCRecipients)  //Updated by Neha under Issue-10561
    {
        try{
            try{
                /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c){
                   SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
                }*/
                if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
                    toRecipients.add(reqObj.Client_TPA_Representative_Email__c);
                }
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toRecipients, cCRecipients, 'SendEmail', UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Week Reminder V Sub' + clientLanguage).Translated_Template_Id__c, templateContextId, null, '', false, '', TRUE, TRUE, reqObj);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                system.debug('sent submission mail to client');
            }catch(Exception e){
                System.debug('Email Failed: ' + e.getMessage());
            }
        }catch(System.EmailException emlEx){
            System.debug('Email Failed: ' + emlEx);
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
    
    //Function to send Awaiting Vendor Signature Reminder Mail to client
    public void sendAwaitingSignatureReminderMailToClient(TPA_Request__c reqObj, Id templateContextId, List<string> toRecipients, string clientLanguage, List<string> cCRecipients) //Updated by Babita Dadarwal under ER-1940 //Updated by Neha under Issue-10561
    {
        try{
            try{
                /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                    SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
                }*/
                if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
                    toRecipients.add(reqObj.Client_TPA_Representative_Email__c);
                }
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toRecipients, cCRecipients, 'SendEmail', UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Week Reminder V Sign' + clientLanguage).Translated_Template_Id__c, templateContextId, null, '', false, '', TRUE, TRUE, reqObj);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                system.debug('sent sign mail to client');
            }catch(Exception e){
                System.debug('Email Failed: ' + e.getMessage());
            }
        }catch(System.EmailException emlEx){
            System.debug('Email Failed: ' + emlEx);
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
    
    public void sendMail( List<string> toRecipients, string mailSubject, Id tpaRequestId, string vendorLanguage, TPA_Request__c reqObj)// Modified by Govind under Issue-8019//Updated by Babita Dadarwal under ER-1669 and ER-1940
    {
        try
        {
            List<String> ccAddressList = new List<String>();
            List<TPA_Contact__c> tpaContactList = SRV_TPA_TPARequest.getContactsForRequest(tpaRequestId);
            if(tpaContactList!= null && tpaContactList.size() > 0)
            {
                for(TPA_Contact__c tpaContact : tpaContactList)
                {
                    if(tpaContact.Type__c == 'Additional Vendor Contact')
                    {
                        ccAddressList.add(tpaContact.Email__c);
                    }
                }
            }
            if(UTL_TPA.tpaSetting != null && UTL_TPA.tpaSetting.TPA_DRN_Mails_Copy_To__c != null && UTL_TPA.tpaSetting.TPA_DRN_Mails_Copy_To__c.length() > 0)
            {
                for(string mailIdObj: UTL_TPA.tpaSetting.TPA_DRN_Mails_Copy_To__c.split(','))
                {
                    if(mailIdObj != null && mailIdObj.trim().length() > 0)
                        ccAddressList.add(mailIdObj.trim());
                }
            }
            
            string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Reminder of New Request' + vendorLanguage).Translated_Template_Id__c;
            SRV_TPA_TPARequest.sendEmailThroughWorkflow(toRecipients, ccAddressList, 'SendEmail', templateId, tpaRequestId, null, '', FALSE, '', TRUE, TRUE, reqObj);
            
        }
        catch(System.EmailException emlEx)
        {
            System.debug('Email Failed: ' + emlEx);
        }
        catch(Exception e)
        {
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}
