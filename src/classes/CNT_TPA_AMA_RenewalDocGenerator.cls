global class CNT_TPA_AMA_RenewalDocGenerator {

    public static List<AMA_Agreement_Detail__c> amaAgreementDetailValues{get; set;}
    public static List<TPA_Request__c> tpaRequestValues{get; set;}
    public static String amaAgreementID{get; set;}
    public static String requestID{get; set;}
    public static Date currentDate {
        get{
            return date.today();
        }
        set;
    }

    public static string currentUserProfileName {
        get {
            if(currentUserProfileName == null) {
                currentUserProfileName = UTL_TPA.getCurrentUserDetails().Profile.Name;
            }
            return currentUserProfileName;
        }
        set;
    }
    public static string tpaCommunityUrl {
        get {
            if(tpaCommunityUrl == null && UTL_TPA.tpaSetting != null && !String.isEmpty(UTL_TPA.tpaSetting.TPA_Client_Community_Url__c)) {
                tpaCommunityUrl = UTL_TPA.tpaSetting.TPA_Client_Community_Url__c;
            }
            return tpaCommunityUrl;
        }
        set;
    }

    public static boolean isLinkDisabled{
        get{
            Date d;
            isLinkDisabled = false;
            system.debug('d0::::'+d);
            if(isLinkDisabled == false && ApexPages.currentPage().getParameters().get('oldReqProcInitiated') != 'true'){
                if(ApexPages.currentPage().getParameters().get('processType') != 'OldRequest' && amaAgreementDetailObj != null && amaAgreementDetailObj.Renewal_Cancellation_Vendor_Link_Date__c != null){
                    d = Date.newInstance(amaAgreementDetailObj.Renewal_Cancellation_Vendor_Link_Date__c.year(),integer.valueof(amaSetting.get(0).AMA_Renewal_Cancellation_Disable_Link_On__c.split('-')[0]),integer.valueof(amaSetting.get(0).AMA_Renewal_Cancellation_Disable_Link_On__c.split('-')[1]));
                }
                else if(requestDetailObj != null && requestDetailObj.Renewal_Cancellation_Vendor_Link_Date__c != null){
                    d = Date.newInstance(requestDetailObj.Renewal_Cancellation_Vendor_Link_Date__c.year(),integer.valueof(amaSetting.get(0).AMA_Renewal_Cancellation_Disable_Link_On__c.split('-')[0]),integer.valueof(amaSetting.get(0).AMA_Renewal_Cancellation_Disable_Link_On__c.split('-')[1]));
                }
                system.debug('d::::'+d);
                isLinkDisabled = d < date.today();
            }
            return isLinkDisabled;
        }
        set;
    }

    public static string currentDateString{
        get{
            return date.today().format();
        }
        set;
    }

    public static List<TPA_AMA_Settings__c> amaSetting{
        get{
            if(amaSetting == null)
                amaSetting = [Select id, Dev_Mail_ID__c, Vendor_Renewal_Noti_for_old_Template_Id__c, To_address_Vendor_Renewal_Notification__c,
                              DBL_Renewal_Notification_Template_Id__c,  CC_address_Vendor_Renewal_Notification__c, CC_Address_For_DBL_Renewal_Notification__c,
                              AMA_Ren_Canc_Ackn_AMA_To_Processor__c, DBL_Renewal_Noti_Template_Id_for_old__c, AMA_Renewal_Cancellation_Disable_Link_On__c,
                              From_Add_For_Client_Renewal_Notification__c, CC_Add_For_Client_Renewal_Notification__c, Client_Renewal_Notification_Template_Id__c, Vendor_Renewal_Cancelation_Status__c, Client_Renewal_Noti_Template_Old_Tpa_Id__c, Vendor_Acknowlwdge_Template_of_AMA_Renew__c    from TPA_AMA_Settings__c Limit 1];
            return amaSetting;
        }
        set;
    }

    public static AMA_Agreement_Detail__c amaAgreementDetailObj {
        get{
            if(amaAgreementDetailObj == null){
                if(!Test.isRunningTest())
                {
                    amaAgreementID = ApexPages.currentPage().getParameters().get('id');
                }
                if(amaAgreementID != null)
                {
                    amaAgreementDetailValues = [Select id,Name, TPA_Request__r.Agreement_Name__c,TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,
                                                TPA_Request__c, TPA_Request__r.Name, TPA_Request__r.Related_Agreement_Name__c, TPA_Request__r.Request_Status__c,Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c, Client_Company_Name__c, Contract_Type__c, Ex_Contract_Type__c,
                                                Client__C,Status_of_Renewal_Process__c, Vendor_Name_who_Cancelled_Renewal__c, Next_Year__c, Renewal_Cancellation_Vendor_Link_Date__c, Current_Year__c, Invoice_Contact_Email__c, TPA_Request__r.ClientContact__c  FROM AMA_Agreement_Detail__c Where id = :amaAgreementID limit 1];

                    if(amaAgreementDetailValues!= null && !amaAgreementDetailValues.isEmpty())
                        amaAgreementDetailObj = amaAgreementDetailValues.get(0);
                    if(amaAgreementDetailObj != null && amaAgreementDetailObj.Contract_Type__c == 'Existing Agreement')
                        amaAgreementDetailObj.Contract_Type__c = amaAgreementDetailObj.Ex_Contract_Type__c;
                }
            }
            return amaAgreementDetailObj;
        }
        set;
    }

    public static TPA_Request__c requestDetailObj {
        get{
            if(requestDetailObj == null){
                if(!Test.isRunningTest())
                {
                    requestID = ApexPages.currentPage().getParameters().get('id');
                }
                if(requestID != null)
                {
                    tpaRequestValues = [Select id, Name,Request_Status__c, Status_of_Renewal_Process__c, Related_Agreement_Name__c, Service_Provider_Contact_f__c, Service_Provider_Address__r.Name,
                                        Client_Address__r.Name, Client_Address__c, Data_Access_Start_Date__c, Vendor_Name_who_Cancelled_Renewal__c,
                                        TP_Processor_Email__c, Vendor_e_mail__c, Vendor_Contact_Email_Client__c, Type_of_AMA_Agreement__c, createddate, Renewal_Cancellation_Vendor_Link_Date__c,
                                        ClientContact__c , Initial_Termination_Date__c, Agreement_End_Date__c FROM TPA_Request__c Where id = :requestID limit 1];

                    if(tpaRequestValues!= null && !tpaRequestValues.isEmpty())
                        requestDetailObj = tpaRequestValues.get(0);
                }
            }
            return requestDetailObj;
        }
        set;
    }

    public String amaAgreementDetailAsString {
        get{
            if(ApexPages.currentPage().getParameters().get('processType') != 'OldRequest')
                return JSON.serialize(amaAgreementDetailObj);
            else
                return JSON.serialize(requestDetailObj);
        }
        set;
    }

    public String getPrintView()
    {
        return
        '<!--[if gte mso 9]>' +
            '<xml>' +
            '<w:WordDocument>' +
            '<w:View>Print</w:View>' +
            '<w:Zoom>125</w:Zoom>' +
            '<w:DoNotOptimizeForBrowser/>' +
            '</w:WordDocument>' +
            '</xml>' +
            '<![endif]>' +
            '<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />' +
            '<style>' +
            'p.MsoHeader, li.MsoHeader, div.MsoHeader{margin:0in;margin-top:.0001pt;margin-left:0.8in;mso-pagination:widow-orphan;tab-stops:center 3.0in right 6.0in;}' +
            'p.MsoFooter, li.MsoFooter, div.MsoFooter{margin:0in;margin-bottom:.0001pt;margin-left:-0.45in;mso-pagination:widow-orphan;tab-stops:center 3.0in right 6.0in;}' +
            '@page main{mso-header:h1;mso-footer:f1;}' +
            'div.main{page:main;}' +
            'table#hrdftrtbl{margin:0in 0in 0in 9in;}' +
            '</style>';

    }

    public String getWordStyle()
    {
        return '<style>.useDefStyle p {margin:0.0in;} .useDefStyle ol ol li p {margin:0.04in 0.0in 0.1in 0.0in;}</style>';
    }

    public CNT_TPA_AMA_RenewalDocGenerator() {
        if(currentUserProfileName == 'tpa Profile') {
            system.debug('In check profile:::' + currentUserProfileName);
            return;
        }
    }

    public void sendEmailForOldReqProcInitiate(){
        if(ApexPages.currentPage().getParameters().get('oldReqProcInitiated') == 'true'){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            email.setTargetObjectId(amaSetting.get(0).To_address_Vendor_Renewal_Notification__c);
            email.setWhatId(requestDetailObj.Id);
            //email.setTemplateId(amaSetting.get(0).Vendor_Renewal_Noti_for_old_Template_Id__c);

            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            emailNotToSend = Messaging.renderStoredEmailTemplate(amaSetting.get(0).Vendor_Renewal_Noti_for_old_Template_Id__c, NULL, requestDetailObj.Id);
            email.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
            email.setSubject(emailNotToSend.getSubject());
            email.setCharset('UTF-8');
            
            List<String> toAddress= new List<String>{((requestDetailObj.Vendor_e_mail__c == null || requestDetailObj.Vendor_e_mail__c.length() == 0) ? requestDetailObj.Vendor_Contact_Email_Client__c : requestDetailObj.Vendor_e_mail__c)};
            if(requestDetailObj.TP_Processor_Email__c != null)
                toAddress.add(requestDetailObj.TP_Processor_Email__c);
            if(toAddress.isEmpty() && String.isNotBlank(amaSetting.get(0).Dev_Mail_ID__c))
            {
                toAddress.add(amaSetting.get(0).Dev_Mail_ID__c);
            }
            email.setToAddresses(toAddress);

            if(String.isNotBlank(amaSetting.get(0).CC_address_Vendor_Renewal_Notification__c))
            {
                List<String> ccTo = amaSetting.get(0).CC_address_Vendor_Renewal_Notification__c.split(';');
                email.setCCAddresses(ccTo);
            }

            TPA_Settings__c tpaSetting = TPA_Settings__c.getInstance();
            email.setOrgWideEmailAddressId(tpaSetting.TPA_From_Orgwide_Email_Id__c);

            email.setSaveAsActivity(true);

            requestDetailObj.Status_of_Renewal_Process__c = 'Awaiting Vendor Response for renewal';
            requestDetailObj.Renewal_Cancellation_Vendor_Link_Date__c = Date.today();
             if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest())
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            update requestDetailObj;
        }
    }

    // @remoteAction
    // public static string saveAmaAcknowledgment(string amaAgreementObj){
    //     amaAgreementDetailObj = (AMA_Agreement_Detail__c)JSON.deserialize(amaAgreementObj, AMA_Agreement_Detail__c.class);
    //     amaAgreementDetailObj.AMA_Renewal_Cancellation_Acknowledged_On__c = DateTime.now();
    //     amaAgreementDetailObj.Next_Year_Fees__c = 0;
    //     update amaAgreementDetailObj;
    //     TPA_Request__c reqObj;
    //     amaAgreementDetailObj = [Select Id,TPA_Request__c,TPA_Request__r.ClientContact__c, TPA_Request__r.Client_TPA_Representative_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, 
    //                              TPA_Request__r.Authorized_Signer_Email__c, TPA_Request__r.ClientContact__r.email, TPA_Request__r.Client_Address__r.TPAOtherEmailIds__c, Invoice_Contact_Email__c from AMA_Agreement_Detail__c 
    //                              where Id =: amaAgreementDetailObj.Id limit 1];
    //     SendVendorNotificationsToProcessor('NotificationForAmaAcknowledgment', amaAgreementDetailObj);

    //     try{
    //         reqObj = [SELECT id, Name, Request_Status__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Owner.Email, Client_TPA_Representative_Email__c, Owner.Type  FROM TPA_Request__c WHERE Id =: amaAgreementDetailObj.TPA_Request__c limit 1];
    //         reqObj.Request_Status__c = amaSetting.get(0).Vendor_Renewal_Cancelation_Status__c;
    //         update reqObj;
    //     }
    //     catch(Exception e)
    //     {
    //         system.debug('Exception while updating request status of agreement: '+e.getMessage());
    //     }

    //     SendRenewalNotificationsToClient('RenewalNotificationToClientForNewAMA',amaAgreementDetailObj,reqObj);

    //     return 'Success';
    // }

    @remoteAction
    public static string sendClientNotification(String reqId){
        requestID = reqId;
        requestDetailObj = [Select id, Name, Status_of_Renewal_Process__c, Related_Agreement_Name__c, Service_Provider_Contact_f__c, Service_Provider_Address__r.Name,
                                        Client_Address__r.Name, Client_Address__c, Data_Access_Start_Date__c, Vendor_Name_who_Cancelled_Renewal__c,
                                        TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Vendor_e_mail__c, Vendor_Contact_Email_Client__c, Type_of_AMA_Agreement__c, createddate, Renewal_Cancellation_Vendor_Link_Date__c, ClientContact__c  FROM TPA_Request__c Where id = :requestID limit 1];
        SendRenewalNotificationsToClient('RenewalNotificationToClientForOLDAMA',requestDetailObj,null);

        return 'success';
    }

    @remoteAction
    public static string sendVendorAcknowlwdgeNotification(String recId){
        AMA_Agreement_Detail__c amaAgrObj = [Select Id, TPA_Request__r.Agreement_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,
                                             TPA_Request__c, TPA_Request__r.Name, TPA_Request__r.Id, TPA_Request__r.Related_Agreement_Name__c, TPA_Request__r.Authorized_Signer_Email__c, Invoice_Contact_Email__c, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c,
                                             Client__c, DBL__c, Contract_Type__c , Current_Year_Fees__c , Next_Year_Fees__c , Status_of_Renewal_Process__c , Vendor_Name_who_Cancelled_Renewal__c, Next_Year__c, Current_Year__c
                                             FROM AMA_Agreement_Detail__c Where id =:recId limit 1];
        system.debug('amaAgrObj: ' + amaAgrObj);
        TPA_Request__c tpaRequest = [Select id, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: amaAgrObj.TPA_Request__c];
        if( amaAgrObj.Status_of_Renewal_Process__c.equalsIgnoreCase('Awaiting Vendor Response for renewal'))
        {
            amaAgrObj.Status_of_Renewal_Process__c = 'Vendor Confirmed Renewal';
            update amaAgrObj;
        }
        Date todayDate;
        todayDate = Date.today();
        //Set list of people who should be CC'ed

        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();
        String templateId = amaSetting.get(0).Vendor_Acknowlwdge_Template_of_AMA_Renew__c;
        List<String> toAddress= new List<String>{((amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c == null || (amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c).length() == 0) ? amaAgrObj.TPA_Request__r.Vendor_contact_email_client__c : amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c)};

        if(amaAgrObj.TPA_Request__r.Authorized_Signer_Email__c != null && amaAgrObj.TPA_Request__r.Authorized_Signer_Email__c.length() > 0)
        {
            toAddress.Add(amaAgrObj.TPA_Request__r.Authorized_Signer_Email__c);
        }

         if(String.isNotBlank(amaAgrObj.Invoice_Contact_Email__c)) {
            toAddress.add(amaAgrObj.Invoice_Contact_Email__c);
          }


        if(toAddress.isEmpty() && String.isNotBlank(amaSetting.get(0).Dev_Mail_ID__c))
        {
            toAddress.add(amaSetting.get(0).Dev_Mail_ID__c);
        }


        List<String> ccTo = new List<String>();

        if(amaAgrObj.TPA_Request__r.TP_Processor_Email__c != null)
            ccTo.add(amaAgrObj.TPA_Request__r.TP_Processor_Email__c);

        if(UTL_TPA.TPUSEMailAddress != null) {
            for(String emailToCc: UTL_TPA.TPUSEMailAddress.split(',')) {
                ccTo.add(emailToCc);
            }
        } 

        if(String.isNotBlank(amaSetting.get(0).CC_address_Vendor_Renewal_Notification__c)){
            ccTo.addAll(amaSetting.get(0).CC_address_Vendor_Renewal_Notification__c.split(';'));
        }
        

        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                    SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
                }*/
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '', FALSE, FALSE, tpaRequest);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                SRV_TPA_TPARequest.updateActivityHistory(amaAgrObj.TPA_Request__r.Id, 'Renewal Acknowlegment Notification Mail to Vendor Sent', true);

            }
            if(Test.isRunningTest()) {
                SRV_TPA_TPARequest.getCustomException();
            }
        } catch(Exception e) {
            UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                FALSE, 
                                                UTL_LogFactory.GUID, 
                                                'Exception: Renewal Acknowlegment Vendor Notification Email NOT Sent ::: ' + e.getLineNumber(), 
                                                'TPA', 
                                                'Exception', 
                                                'ERROR', 
                                                ':::CNT_TPA_AMA_RenewalDocGenerator:::sendVendorAcknowlwdgeNotification :::Renewal Acknowlegment Notification Mail to Vendor failed: ' + e.getMessage()  , 
                                                (amaAgrObj.TPA_Request__r.Id != null) ? amaAgrObj.TPA_Request__r.Id : '');
            return 'error';
        }

        return 'Success';
    }

    @remoteAction
    public static String saveVendorResponse(String amaAgreementObj) {

        amaAgreementDetailObj = (AMA_Agreement_Detail__c)JSON.deserialize(amaAgreementObj, AMA_Agreement_Detail__c.class);

        AMA_Agreement_Detail__c obj = [Select id, TPA_Request__r.Agreement_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,
                                       TPA_Request__c, TPA_Request__r.Name,TPA_Request__r.Related_Agreement_Name__c, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c,
                                       Client__c, DBL__c, Contract_Type__c , Current_Year_Fees__c , Next_Year_Fees__c , Status_of_Renewal_Process__c , Vendor_Name_who_Cancelled_Renewal__c, Next_Year__c, Current_Year__c, Invoice_Contact_Email__c
                                       FROM AMA_Agreement_Detail__c Where id = :amaAgreementDetailObj.Id limit 1];

        try {
            if( obj.Status_of_Renewal_Process__c.equalsIgnoreCase('Awaiting Vendor Response for renewal'))
            {
                update amaAgreementDetailObj;
            }
            else if(obj.Status_of_Renewal_Process__c.equalsIgnoreCase('Vendor Responded Cancel') )
            {
                return 'alreadySubmittedResponse';
            }
            else
            {
                return 'error';
            }
        } catch (DmlException e) {
            system.debug(e.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_RenewalDocGenerator:::saveVendorResponse', amaAgreementDetailObj != null ? amaAgreementDetailObj.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
            return 'error';
        } catch (Exception e) {
            system.debug(e.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_RenewalDocGenerator:::saveVendorResponse', amaAgreementDetailObj != null ? amaAgreementDetailObj.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
            return 'error';
        }

        return 'Success';

    }

    // @remoteAction
    // public static String saveVendorResponseForOldRequests(String amaAgreementObj) {

    //     amaAgreementDetailObj = (AMA_Agreement_Detail__c)JSON.deserialize(amaAgreementObj, AMA_Agreement_Detail__c.class);

    //     TPA_Request__c obj = [Select id, Status_of_Renewal_Process__c FROM TPA_Request__c Where id = :amaAgreementDetailObj.Id limit 1];

    //     try {
    //         if( obj.Status_of_Renewal_Process__c.equalsIgnoreCase('Awaiting Vendor Response for renewal'))
    //         {
    //             obj.Status_of_Renewal_Process__c = amaAgreementDetailObj.Status_of_Renewal_Process__c;
    //             obj.Vendor_Name_who_Cancelled_Renewal__c = amaAgreementDetailObj.Vendor_Name_who_Cancelled_Renewal__c;
    //             update obj;
    //         }
    //         else if(obj.Status_of_Renewal_Process__c.equalsIgnoreCase('Vendor Responded Cancel') )
    //         {
    //             return 'alreadySubmittedResponse';
    //         }
    //         else
    //         {
    //             return 'error';
    //         }
    //     } catch (DmlException e) {
    //         system.debug(e.getMessage());
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_RenewalDocGenerator:::saveVendorResponseForOldRequests', amaAgreementDetailObj != null ? amaAgreementDetailObj.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         return 'error';
    //     } catch (Exception e) {
    //         system.debug(e.getMessage());
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_RenewalDocGenerator:::saveVendorResponseForOldRequests', amaAgreementDetailObj != null ? amaAgreementDetailObj.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         return 'error';
    //     }
    //     return 'Success';
    // }

    public static void SendRenewalResponseToDBL(AMA_Agreement_Detail__c amaAgrObj)
    {
        Date todayDate;
        todayDate = Date.today();
        //Set list of people who should be CC'ed

        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();
        String templateId = amaSetting.get(0).DBL_Renewal_Notification_Template_Id__c;
        String dblContractsContactId = tpaCustomSettings.DBL_Contracts_Contact_Id__c; //dblcontracts@ama-assn.org
        String initials = '';
        String globalTPProcessorInitials = '';

        //Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        //Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        List<String> ccTo = new List<String>();
        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_DBL_Renewal_Notification__c))
        {
            ccTo = amaSetting.get(0).CC_Address_For_DBL_Renewal_Notification__c.split(';');
        }

        if(String.isNotBlank(amaAgrObj.TPA_Request__r.TP_Processor_Email__c))
            ccTo.add(amaAgrObj.TPA_Request__r.TP_Processor_Email__c);
        
        if(UTL_TPA.TPUSEMailAddress != null) {
            for(String emailToCc: UTL_TPA.TPUSEMailAddress.split(',')) {
                ccTo.add(emailToCc);
            }
        }     

        if(!ccTo.isEmpty())
            mail.setCCAddresses(ccTo);

        //Set email contents - you can use variables!
        mail.setTargetObjectId(dblContractsContactId);
        mail.setWhatId(amaAgrObj.id);
        //mail.setTemplateId(templateId);

        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, amaAgrObj.id);
        mail.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
        mail.setSubject(emailNotToSend.getSubject());
        mail.setCharset('UTF-8'); 
    
        mail.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Address_For_Data_Release__c);
        mail.setSaveAsActivity(true);
        // if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
        //     initials = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
        // }
        // if(amaAgrObj.TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c) {
        //     globalTPProcessorInitials = amaAgrObj.TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c;
        // }
        // mail.setSubject(SRV_TPA_TPARequest.setEmailInitials(initials, globalTPProcessorInitials, mail.getSubject()));

        if(String.isNotBlank(amaAgrObj.Client__c) &&
           String.isNotBlank(amaAgrObj.Vendor_Legal_Name__c) &&
           (amaAgrObj.Client__c.startsWithIgnoreCase('Test') || amaAgrObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test')))
        {
            mail.setTreatTargetObjectAsRecipient(false);
        }

        List<Attachment> attachments = [SELECT Id, Name, Body, ContentType, LastModifiedDate  FROM Attachment WHERE Parentid =:amaAgrObj.id order by LastModifiedDate desc limit 1 ];

        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        for(Attachment att : attachments) {

            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            // to figure out the correct file extension
            if(String.isNotBlank(att.Name) && !att.Name.startsWithIgnoreCase('Temp')
               && ((att.Name.containsIgnoreCase('AMA Vendor Renewal Cancelation'))))
            {
                efa.setFileName(att.Name);
                // Take the blob data from the Attachment and put it on the email.
                efa.setBody(att.Body);
                efa.setContentType(att.ContentType);
                emailAttachments.add(efa);
            }
        }

        mail.setFileAttachments(emailAttachments);

        //Add email to the master list
        mails.add(mail);

        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                //Send all emails in the master list
                Messaging.sendEmail(mails);
            }
        } catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_RenewalDocGenerator:::SendRenewalResponseToDBL', amaAgrObj != null ? amaAgrObj.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
        }
    }

    public static void SendVendorNotificationsToProcessor(string notificationType, SObject sObj)
    {
        Date todayDate;
        todayDate = Date.today();
        //Set list of people who should be CC'ed

        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();
        String templateId = '';
        AMA_Agreement_Detail__c amaAgrObj;
        
        templateId = amaSetting.get(0).AMA_Ren_Canc_Ackn_AMA_To_Processor__c;
        amaAgrObj = (AMA_Agreement_Detail__c)sObj;
        TPA_Request__c tpaRequest = [Select id, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: amaAgrObj.TPA_Request__c];

        List<String> toAddress = new List<String>();
        
        if(amaAgrObj.TPA_Request__r != null && amaAgrObj.TPA_Request__r.TP_Processor_Email__c != null)
            toAddress.add(amaAgrObj.TPA_Request__r.TP_Processor_Email__c);

        if(UTL_TPA.TPUSEMailAddress != null) {
            for(String emailToCc: UTL_TPA.TPUSEMailAddress.split(',')) {
                toAddress.add(emailToCc);
            }
        } 
        List<String> ccTo = new List<String>();

        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_DBL_Renewal_Notification__c))
        {
            ccTo = amaSetting.get(0).CC_Address_For_DBL_Renewal_Notification__c.split(';');
        }

        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                    SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
                }*/
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                
            }
            if(Test.isRunningTest()) {
                SRV_TPA_TPARequest.getCustomException();
            }
        } catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_RenewalDocGenerator:::SendVendorNotificationsToProcessor', amaAgrObj != null ? amaAgrObj.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
        }
    }

    @remoteAction
    global static string generateDocument(String recId, string agrName, string isProcessOldType){
     system.debug('isProcessOldType:::'+isProcessOldType);
     AMA_Agreement_Detail__c amaObject;
     TPA_Request__c reqObj;
     amaObject = [Select Id,TPA_Request__c,TPA_Request__r.ClientContact__c, TPA_Request__r.Client_TPA_Representative_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, Client__c, Vendor_Legal_Name__c, 
                                 TPA_Request__r.Authorized_Signer_Email__c, TPA_Request__r.ClientContact__r.email, TPA_Request__r.Client_Address__r.TPAOtherEmailIds__c, Invoice_Contact_Email__c from AMA_Agreement_Detail__c 
                                 where id =:recId limit 1];
    
     try
     {
         PageReference pdf = Page.VFP_TPA_AMA_RenewalDocGenerator;
         pdf.getParameters().put('id',recId);
         pdf.getParameters().put('docGenCall','true');
         Blob body;
         if (Test.IsRunningTest())
         {
             body = Blob.valueOf('UNIT.TEST');
         }
         else
         {
             body = pdf.getContent();
         }
         String attchDocName = 'AMA Vendor Renewal Cancelation'+ ' ' +agrName + '.doc';
         List<Attachment> attachmentList = [SELECT Id, Name, Body, ContentType  FROM Attachment WHERE Parentid =: recId and Name =:attchDocName];
         delete attachmentList;

         Attachment attach = new Attachment();
         attach.Body = body;
         attach.Name = attchDocName;
         attach.IsPrivate = false;
         attach.ParentId = recId;
         insert attach;


        try{
            reqObj = [SELECT id, Name, Request_Status__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Owner.Email, Client_TPA_Representative_Email__c, Owner.Type  FROM TPA_Request__c WHERE Id =: amaObject.TPA_Request__c limit 1];
            reqObj.Request_Status__c = amaSetting.get(0).Vendor_Renewal_Cancelation_Status__c;
            update reqObj;
        }
        catch(Exception e)
        {
            system.debug('Exception while updating request status of agreement: '+e.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_RenewalDocGenerator:::generateDocument', reqObj != null ? reqObj.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE); 
        }

        SendRenewalNotificationsToClient('RenewalNotificationToClientForNewAMA',amaObject,reqObj);
        SendRenewalResponseToDBL(amaObject);


        //  if(isProcessOldType != 'true')
        //      SendRenewalResponseToDBL(amaObject);
        //  else
        //      SendVendorNotificationsToProcessor('NotificationForOldAmaProcessOnVendorSubmit', reqObject);
     }
     catch(Exception ex)
     {
         UTL_LogFactory.generateAndCommitLog(TRUE, 
                                             FALSE, 
                                             UTL_LogFactory.GUID, 
                                             'Exception: In generating doc ::: ' + ex.getLineNumber(), 
                                             'TPA', 
                                             'Exception', 
                                             'ERROR', 
                                             ':::CNT_TPA_AMA_RenewalDocGenerator:::generateDocument ::: ' + ex.getMessage(), 
                                             (recId != null) ? recId : '');
         return 'exception: ' + ex.getMessage();
     }
     return 'Success';
    }

    public static void SendRenewalNotificationsToClient(string notificationType, SObject sObj, SObject sObj2)
    {

        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();
        String templateId = '';
        TPA_Request__c reqObject;
        AMA_Agreement_Detail__c amaAgrObj;

        if(notificationType == 'RenewalNotificationToClientForNewAMA')
        {
            templateId = amaSetting.get(0).Client_Renewal_Notification_Template_Id__c;
            amaAgrObj = (AMA_Agreement_Detail__c)sObj;
            if(sObj2 != null){
                reqObject = (TPA_Request__c)sObj2;
                 }
        }
        else if(notificationType == 'RenewalNotificationToClientForOLDAMA')
        {
            templateId = amaSetting.get(0).Client_Renewal_Noti_Template_Old_Tpa_Id__c;
            reqObject = (TPA_Request__c)sObj;
        }


        List<String> toAddress = new List<String>();
        List<String> ccTo = new List<String>();

        if(notificationType == 'RenewalNotificationToClientForNewAMA'){
            if(amaAgrObj.TPA_Request__r != null && amaAgrObj.TPA_Request__r.TP_Processor_Email__c != null)
                toAddress.add(amaAgrObj.TPA_Request__r.TP_Processor_Email__c);
            toAddress = UTL_TPA_Multilingual.ccList(amaAgrObj.TPA_Request__r.Client_Address__r.TPAOtherEmailIds__c, toAddress);    
            if(amaAgrObj.TPA_Request__r.ClientContact__r.email != null && amaAgrObj.TPA_Request__r.ClientContact__r.email != ''){
                toAddress.add(amaAgrObj.TPA_Request__r.ClientContact__r.email);
            }
            if(amaAgrObj.TPA_Request__r.Client_TPA_Representative_Email__c != null && amaAgrObj.TPA_Request__r.Client_TPA_Representative_Email__c != ''){
                toAddress.add(amaAgrObj.TPA_Request__r.Client_TPA_Representative_Email__c);
            }
            if(reqObject!= null && reqObject.Owner.Type != null && reqObject.Owner.Type == 'Queue' && reqObject.Owner.Email != null){
                toAddress.add(reqObject.Owner.Email);
            }
        }
        else if(notificationType == 'RenewalNotificationToClientForOLDAMA')
        {
            if(reqObject.TP_Processor_Email__c != null)
                toAddress.add(reqObject.TP_Processor_Email__c);
        }

        if(UTL_TPA.TPUSEMailAddress != null) {
            for(String emailToCc: UTL_TPA.TPUSEMailAddress.split(',')) {
                toAddress.add(emailToCc);
            }
        } 
        


        if(String.isNotBlank(amaSetting.get(0).CC_Add_For_Client_Renewal_Notification__c)) {
            ccTo = amaSetting.get(0).CC_Add_For_Client_Renewal_Notification__c.split(';');
        }

        if(notificationType == 'RenewalNotificationToClientForNewAMA'){
            if(amaAgrObj.TPA_Request__r != null && amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c  != null)
               ccTo.add(amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c );
               ccTo = UTL_TPA_Multilingual.ccList(amaAgrObj.TPA_Request__r.Client_Address__r.TPAOtherEmailIds__c, ccTo);
               
        }
        else if(notificationType == 'RenewalNotificationToClientForOLDAMA')
        {
            if(reqObject.Vendor_e_mail__c  != null)
                ccTo.add(reqObject.Vendor_e_mail__c );
        }
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                    SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
                }*/
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '', FALSE, FALSE, reqObject);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;

            }
        } catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_RenewalDocGenerator:::SendRenewalNotificationsToClient', amaAgrObj != null ? amaAgrObj.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
        }
    }
}
