global class CNT_TPA_AMA_Cancellation_Template {    
    
    public String amaAgreementDetailAsString { get; set;}
    public static AMA_Agreement_Detail__c amaAgreementDetailObj { get; set;}
    public static string amaAgreementID{get; set;}
    public boolean isMessageShow { get; set; }
    public boolean isTPAPermanentDown { get; set; }
    public String title { get; set; }
    public String Message { 
        get{
            String content = [Select Content__c from TPA_Text_Editor__c where Page_Title__c = 'Shutdown Message' AND Is_Active__c = true][0].Content__c;
            if(Message == null && content != null){
                Message = content;
            } else if(content == null){
                Message = Label.TPA_Downtime_Message;
            }
            return Message;
        }
        set; 
    }
    public boolean isRestrictedUser { get; set; }
    //public boolean TPA_Is_Show_TPA_Down_Message {get;set;}
    private static User CurrentUser = UTL_TPA_Multilingual.CurrentUser;
    public static string isQaTesting {get; set;}
    
    public static List<AMA_Agreement_Detail__c> amaAgreementDetailValues{
        get{
            if(amaAgreementDetailValues == null){
                amaAgreementDetailObj = new AMA_Agreement_Detail__c();
                if(!Test.isRunningTest())
                    amaAgreementID = ApexPages.currentPage().getParameters().get('id');
                amaAgreementDetailValues = [Select id, TPA_Request__r.Agreement_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Signature_Received__c,
                    TPA_Request__c, TPA_Request__r.Name, TPA_Request__r.Request_Status__c, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c ,Client__c, Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c
                        ,Vendor_Reasons_for_Termination__c, Vendor_Name_who_Acknowledged_Cancelation__c, REVISED_AMA_Use_and_or_Frequency__c, If_vendor_cancellation_reason_is_Other__c , Status_of_Cancelation_Request__c ,
                        DBL__c, Contract_Type__c , Current_Year_Fees__c , Next_Year_Fees__c, Required_Additional_Info_By_AMA__c , Reasons_For_Not_Approval__c, Client_Company_Name__c , Last_Vendor_Reminder_Mail_Sent__c , Last_AMA_Reminder_Mail_Sent__c , Request_Process_Initiated__c, Vendor_Cancelation_Response_Date__c, Term_requested_to_cancel__c       
                        FROM AMA_Agreement_Detail__c Where id = :amaAgreementID limit 1];
                
                if(amaAgreementDetailValues!= null && !amaAgreementDetailValues.isEmpty())
                    amaAgreementDetailObj = amaAgreementDetailValues.get(0);
            }
            return amaAgreementDetailValues;
        }
        set;
    }
    //Added for site to community logic submission start
    public static User currentLoggedInUser {
        get {
            if(currentLoggedInUser == null) {
                return UTL_TPA.getCurrentUserDetails();
            }
            else {
                return currentLoggedInUser;
            }
        }
        set;
    }
    
    
    public static string currentUserProfileName {
        get {
            if(currentUserProfileName == null) {
                currentUserProfileName = currentLoggedInUser.Profile.Name;
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
    //Added for site to community logic submission end
    
    
    public CNT_TPA_AMA_Cancellation_Template() {
        //Added for site to community logic submission start
        if(currentLoggedInUser.Profile.Name == 'tpa Profile') {
            system.debug('In check profile:::' + currentLoggedInUser.Profile.Name);
            return;
        }
        //Added for site to community logic submission end
        isMessageShow = UTL_TPA.isMessageShow;
        isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
        
        title = Label.TPA_Custom_Landing_Page_Title;
        //Message = Label.TPA_Downtime_Message;
        
        //TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
        
        String restrictedUserIds = Label.TPA_Non_Restricted_Users;
        String currentUserId = String.valueOf(CurrentUser.Id).subString( 0, 15 );
        system.debug('restrictedUserIds:::'+restrictedUserIds.contains( currentUserId ));
        if( restrictedUserIds.contains( currentUserId )){
            isRestrictedUser = false; 
        }
        else if(isTPAPermanentDown){
            isRestrictedUser = true;
        }
        isQaTesting = ApexPages.currentPage().getParameters().get('isQaTesting');
        if(isTPAPermanentDown == true && isQaTesting == 'true'){
            isTPAPermanentDown=false;
            
        }
        else if (isTPAPermanentDown == true){
            isMessageShow = UTL_TPA.isMessageShow;
            isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
            
            title = Label.TPA_Custom_Landing_Page_Title;
            //Message = Label.TPA_Downtime_Message;
            //TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
        }
        if(amaAgreementDetailValues != null)
            amaAgreementDetailAsString = JSON.serialize(amaAgreementDetailValues);
        amaAgreementDetailAsString= amaAgreementDetailAsString.replace('\'', '&#39;');
    }
    
    public string getCancelationReasonList() {
    
        List<String> cancelationReasonList = new List<String>();
        Schema.DescribeFieldResult fieldResult = AMA_Agreement_Detail__c.Vendor_Reasons_for_Termination__c.getDescribe();
        List<Schema.PicklistEntry> pleForVendorCancelationReason = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : pleForVendorCancelationReason){
        
            cancelationReasonList.add(f.getValue());
        }  
        
        return JSON.serialize(cancelationReasonList);
    }
    
    @remoteAction
    public static String saveVendorCancelationReason(String amaAgreementObj) {
        
        amaAgreementDetailObj = (AMA_Agreement_Detail__c)JSON.deserialize(amaAgreementObj, AMA_Agreement_Detail__c.class);
        
        AMA_Agreement_Detail__c obj = [Select id, TPA_Request__r.Agreement_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,
                    TPA_Request__c, TPA_Request__r.Name, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,  TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c
                        ,Vendor_Reasons_for_Termination__c, Vendor_Name_who_Acknowledged_Cancelation__c, REVISED_AMA_Use_and_or_Frequency__c, If_vendor_cancellation_reason_is_Other__c , Status_of_Cancelation_Request__c , Client__c, //Modified by C.P.Pandey under Issue-9540
                        DBL__c, Contract_Type__c , Current_Year_Fees__c , Next_Year_Fees__c, Required_Additional_Info_By_AMA__c , Reasons_For_Not_Approval__c, Client_Company_Name__c , Last_Vendor_Reminder_Mail_Sent__c , Last_AMA_Reminder_Mail_Sent__c , Request_Process_Initiated__c, Vendor_Cancelation_Response_Date__c, Term_requested_to_cancel__c             
                        FROM AMA_Agreement_Detail__c Where id = :amaAgreementDetailObj.Id limit 1];
        
        try {
            if(obj.Status_of_Cancelation_Request__c != 'Awaiting Vendor Cancelation Acknowledgement'){
            
                return 'alreadySubmittedResponse';
            }
            else {
            
                amaAgreementDetailObj.Vendor_Cancelation_Response_Date__c = Datetime.now(); 
                update amaAgreementDetailObj;
            }
        } catch (DmlException e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::saveVendorCancelationReason', (obj != null && obj.TPA_Request__c != null) ? obj.TPA_Request__c : ''));
            system.debug(e.getMessage());
            return 'error';
        }

        SendCancelationNotificationToDBL(amaAgreementDetailObj);
        return 'Success';
        
    }
    
    @remoteAction
    public static Boolean tpUsRequestforCancelation(String amaAgreementObjID ) {
        Date todayDate;
        todayDate = Date.today();
        AMA_Agreement_Detail__c obj = [Select id, TPA_Request__r.Agreement_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,  TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,
                    TPA_Request__c, TPA_Request__r.Name, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c
                        ,Vendor_Reasons_for_Termination__c, Vendor_Name_who_Acknowledged_Cancelation__c, REVISED_AMA_Use_and_or_Frequency__c, If_vendor_cancellation_reason_is_Other__c , Status_of_Cancelation_Request__c , Client_Company_Name__c , Last_Vendor_Reminder_Mail_Sent__c , Last_AMA_Reminder_Mail_Sent__c, Request_Process_Initiated__c, Term_requested_to_cancel__c
                        FROM AMA_Agreement_Detail__c Where id = :amaAgreementObjID limit 1];
        obj.Status_of_Cancelation_Request__c  = 'Awaiting Vendor Cancelation Acknowledgement';
        obj.Request_Process_Initiated__c = todayDate;
        try {
            update obj;
            
        } catch (DmlException e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(true, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::tpUsRequestforCancelation', (obj != null && obj.TPA_Request__c != null) ? obj.TPA_Request__c : ''));
            system.debug(e.getMessage());
            return false;
        }

        SendNotificationWithCancelationLink(obj);
        return true;
        
    }
    
    @remoteAction
    public static Boolean tpUsReqResendTOAMA(String amaAgreementObjID ) {
        
        AMA_Agreement_Detail__c obj = [Select id, TPA_Request__r.Agreement_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,
                    TPA_Request__c, TPA_Request__r.Name, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,  TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c
                        ,Vendor_Reasons_for_Termination__c, Vendor_Name_who_Acknowledged_Cancelation__c, REVISED_AMA_Use_and_or_Frequency__c, If_vendor_cancellation_reason_is_Other__c , Status_of_Cancelation_Request__c , Client__c, //Modified by C.P.Pandey under Issue-09540
                        DBL__c, Contract_Type__c , Current_Year_Fees__c , Next_Year_Fees__c, Required_Additional_Info_By_AMA__c , Reasons_For_Not_Approval__c, Client_Company_Name__c , Last_Vendor_Reminder_Mail_Sent__c , Last_AMA_Reminder_Mail_Sent__c , Request_Process_Initiated__c, Vendor_Cancelation_Response_Date__c, Term_requested_to_cancel__c            
                        FROM AMA_Agreement_Detail__c Where id = :amaAgreementObjID limit 1]; 
        obj.Status_of_Cancelation_Request__c  = 'Awaiting AMA Response to Vendor Cancelation Request';
        try {
            
            update obj;
                
        } catch (DmlException e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::tpUsReqResendTOAMA', (obj != null && obj.TPA_Request__c != null) ? obj.TPA_Request__c : ''));
            system.debug(e.getMessage());
            return false;
        }

        SendCancelationNotificationToDBL(obj);
        return true;
        
    }
    
    
    @remoteAction
    public static String saveAMAResponse(String amaResponse, String amaAgreementObj) {
        
        amaAgreementDetailObj = (AMA_Agreement_Detail__c)JSON.deserialize(amaAgreementObj, AMA_Agreement_Detail__c.class);
        AMA_Agreement_Detail__c obj = [Select id, TPA_Request__r.Agreement_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,
                    TPA_Request__c, TPA_Request__r.Name, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,  TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c ,Client__c, Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c
                        ,Vendor_Reasons_for_Termination__c, Vendor_Name_who_Acknowledged_Cancelation__c, REVISED_AMA_Use_and_or_Frequency__c, If_vendor_cancellation_reason_is_Other__c , Status_of_Cancelation_Request__c , Client_Company_Name__c 
                        ,DBL__c, Contract_Type__c , Current_Year_Fees__c , Next_Year_Fees__c, Required_Additional_Info_By_AMA__c , Reasons_For_Not_Approval__c , Last_Vendor_Reminder_Mail_Sent__c , Last_AMA_Reminder_Mail_Sent__c,Request_Process_Initiated__c, Vendor_Cancelation_Response_Date__c, Full_partial_credit__c, Term_requested_to_cancel__c
                                       FROM AMA_Agreement_Detail__c Where id = :amaAgreementDetailObj.Id limit 1];
        
        
        try {
        
            if(obj.Status_of_Cancelation_Request__c != 'Awaiting AMA Response to Vendor Cancelation Request'){
                return 'alreadySubmittedResponse';
            }
            else{
            
                if(amaResponse == 'Approved cancelation and full/partial credit'){
                    obj.Status_of_Cancelation_Request__c  = 'AMA has approved cancelation and full/partial credit';
                    obj.Full_partial_credit__c = amaAgreementDetailObj.Full_partial_credit__c;
                }
                else if(amaResponse == 'Additional information is required'){
                
                    obj.Status_of_Cancelation_Request__c  = 'AMA responded with additional questions';
                    obj.Required_Additional_Info_By_AMA__c  = amaAgreementDetailObj.Required_Additional_Info_By_AMA__c;
                }
                else if(amaResponse == 'Not approved, reasons why'){
               
                    obj.Status_of_Cancelation_Request__c  = 'AMA did not approve';
                    obj.Reasons_For_Not_Approval__c  = amaAgreementDetailObj.Reasons_For_Not_Approval__c;
                }
                else{
                
                }
                if(amaResponse != 'Not approved, reasons why'){
                
                    obj.Reasons_For_Not_Approval__c = '';
                }
                if(amaResponse != 'Additional information is required'){
                
                    obj.Required_Additional_Info_By_AMA__c = '';
                }
                if(amaResponse != 'Approved cancelation and full/partial credit'){
                
                    obj.Full_partial_credit__c = '';
                }
                
                if(String.isNotBlank(amaAgreementDetailObj.Term_requested_to_cancel__c)){
                    obj.Term_requested_to_cancel__c  = amaAgreementDetailObj.Term_requested_to_cancel__c;
                }
                
            }
            update obj;
                
        } catch (DmlException e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::saveAMAResponse', (obj != null && obj.TPA_Request__c != null) ? obj.TPA_Request__c : ''));
            system.debug(e.getMessage());
            return 'error';
        } catch (Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::saveAMAResponse', (obj != null && obj.TPA_Request__c != null) ? obj.TPA_Request__c : ''));
            system.debug(e.getMessage());
            return 'error';
        }

        SendCompletionOfCancelationNotification(obj);
        sendSummaryReportToDBL(obj);
        return 'Success';
    }
  
    public static void sendSummaryReportToDBL(AMA_Agreement_Detail__c amaAgrObj)
    {      
        Date todayDate;
        todayDate = Date.today(); 
        //Set list of people who should be CC'ed
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();                
        String templateId = amaSetting.get(0).AMA_Cancellation_Summary_Receipt_TempId__c;
        String dblContractsContactId = tpaCustomSettings.DBL_Contracts_Contact_Id__c; //dblcontracts@ama-assn.org
        String initials = '';
        String globalTPProcessorInitials = '';
        
        //Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        //Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        
        if(amaSetting.get(0).CC_Address_For_DBL_Cancelation_Mail__c != null && amaSetting.get(0).CC_Address_For_DBL_Cancelation_Mail__c != ''){
        
            List<String> ccTo = amaSetting.get(0).CC_Address_For_DBL_Cancelation_Mail__c.split(';');
            mail.setCCAddresses(ccTo);
        }
        
        /*if(String.isNotBlank(tpaCustomSettings.TPA_BCC_Emails__c)) {
           List<String> bccTo = new List<String>();
           bccTo.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(';'));
           mail.setBccAddresses(bccTo);
        }*/
        
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
        if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c){
            initials = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
        }
        if(amaAgrObj.TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c){
            globalTPProcessorInitials = amaAgrObj.TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c;
        }
        mail.setSubject(SRV_TPA_TPARequest.setEmailInitials(initials, globalTPProcessorInitials, mail.getSubject()));
        
        
        if(String.isNotBlank(amaAgrObj.Client__c) &&
           String.isNotBlank(amaAgrObj.Vendor_Legal_Name__c) &&
           (amaAgrObj.Client__c.startsWithIgnoreCase('Test') || amaAgrObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))){
            mail.setTreatTargetObjectAsRecipient(false);
        }
        
        //Add email to the master list
        mails.add(mail);
                    
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                //Send all emails in the master list
                Messaging.sendEmail(mails);
            }
        } catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::sendSummaryReportToDBL', (amaAgrObj != null && amaAgrObj.TPA_Request__c != null) ? amaAgrObj.TPA_Request__c : ''));
            System.debug('Send Cancelation notification mail to DBL failed: ' + e.getMessage());
        } 
    }
    
    public static void SendNotificationWithCancelationLink(AMA_Agreement_Detail__c  amaAgrObj)
    {        
        try {       
                 
            Date todayDate;
            todayDate = Date.today(); 
            TPA_Request__c tpaRequest = [Select id, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: amaAgrObj.TPA_Request__c];
            List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
            email.setTargetObjectId(amaSetting.get(0).Vendor_Contact_ID__c );
            email.setWhatId(amaAgrObj.Id);
              
            
            email.setTemplateId(amaSetting.get(0).Cancelation_Link_For_Vendor_Template_ID__c);
            List<String> toAddress= new List<String>{amaAgrObj.TPA_Request__r.TP_Processor_Email__c, ((amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c == null || amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c.length() == 0) ? amaAgrObj.TPA_Request__r.Vendor_Contact_Email_Client__c : amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c)};
            List<String> ccTo = new List<String>();
            if(toAddress.isEmpty() && String.isNotBlank(amaSetting.get(0).Dev_Mail_ID__c)){
            
                List<String> toAdd = amaSetting.get(0).Dev_Mail_ID__c.split(';'); 
              email.setToAddresses(toAdd); 
            }
            else{
                email.setToAddresses(toAddress);
            }
            
            if(String.isNotBlank(amaSetting.get(0).CC_Address_For_Vendor_Cancelation_Mail__c)){
            
                ccTo = amaSetting.get(0).CC_Address_For_Vendor_Cancelation_Mail__c.split(';');
                email.setCCAddresses(ccTo);
            }
            
            
            TPA_Settings__c tpaSetting = TPA_Settings__c.getInstance();
            email.setOrgWideEmailAddressId(tpaSetting.TPA_From_Orgwide_Email_Id__c);
            
            if(String.isNotBlank(tpaSetting.TPA_BCC_Emails__c)) {
               List<String> bccTo = new List<String>();
               bccTo.addAll(tpaSetting.TPA_BCC_Emails__c.split(';'));
               email.setBccAddresses(bccTo);
            }
            
            email.setSaveAsActivity(true);
            email.setTreatTargetObjectAsRecipient(false);
            try{
            
                if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) { 
                    //Messaging.sendEmail(New Messaging.SingleEmailMessage[] {email});
                    /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                    if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/
                    SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', amaSetting.get(0).Cancelation_Link_For_Vendor_Template_ID__c, amaAgrObj.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);
                    //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                    amaAgrObj.Last_Vendor_Reminder_Mail_Sent__c = todayDate;
                    try{
                    
                        update amaAgrObj;
                    }
                    catch(Dmlexception ex){
                        UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::SendNotificationWithCancelationLink', (amaAgrObj != null && amaAgrObj.TPA_Request__c != null) ? amaAgrObj.TPA_Request__c : ''));
                        System.debug(ex.getMessage());
                    } 
                }
            }
            catch(Exception e){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::SendNotificationWithCancelationLink', (amaAgrObj != null && amaAgrObj.TPA_Request__c != null) ? amaAgrObj.TPA_Request__c : ''));
                System.debug('Email Failed: ' + e.getMessage());
            }
        }
        catch(Exception ex){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::SendNotificationWithCancelationLink', (amaAgrObj != null && amaAgrObj.TPA_Request__c != null) ? amaAgrObj.TPA_Request__c : ''));
            system.debug(ex.getMessage());
        }
    }
    
    public static void SendCancelationNotificationToDBL(AMA_Agreement_Detail__c amaAgrObj){
        AMA_Agreement_Detail__c obj = [Select id, TPA_Request__c,  TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,  TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c 
                                       FROM AMA_Agreement_Detail__c Where id = :amaAgrObj.Id limit 1];
        Date todayDate;
        todayDate = Date.today(); 
        TPA_Request__c tpaRequest = [Select id, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: obj.TPA_Request__c];

        List<TPA_AMA_Settings__c> amaSetting =  TPA_AMA_Settings__c.getall().values();
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();              
        String dblContractsContactId = tpaCustomSettings.DBL_Contracts_Contact_Id__c; 
        
        
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
        
        if(String.isNotBlank(tpaCustomSettings.TPA_BCC_Emails__c)) {
           List<String> bccTo = new List<String>();
           bccTo.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(';'));
        }
        
        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(obj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           SRV_TPA_TPARequest.assignedTPProcessorName = obj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
                    
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', amaSetting.get(0).Cancelation_Link_For_DBL_Template_ID__c, amaAgrObj.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                amaAgrObj.Last_AMA_Reminder_Mail_Sent__c = todayDate;
                try{
                    update amaAgrObj;
                }
                catch(Dmlexception ex){
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::SendCancelationNotificationToDBL', (amaAgrObj != null && amaAgrObj.TPA_Request__c != null) ? amaAgrObj.TPA_Request__c : ''));
                    System.debug(ex.getMessage());
                } 
                
            }
        } catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::SendCancelationNotificationToDBL', (amaAgrObj != null && amaAgrObj.TPA_Request__c != null) ? amaAgrObj.TPA_Request__c : ''));
            System.debug('Send Cancelation notification mail to DBL failed: ' + e.getMessage());
        } 
    }
    
    public static void SendCompletionOfCancelationNotification(AMA_Agreement_Detail__c amaAgrObj)
    {
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        TPA_Request__c tpaRequest = [Select id, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: amaAgrObj.TPA_Request__c];
        String templateId = amaSetting.get(0).Cancelation_Noti_To_TPUS_Template_ID__c ;
        
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance(); 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> toAddress = new List<String>();
        List<String> ccTo = new List<String>();
        
        if(String.isNotBlank(amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c )) {
            toAddress = amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c.split(';');
        }
        
        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_TP_US_Cancelation_Mail__c)){
            ccTo = amaSetting.get(0).CC_Address_For_TP_US_Cancelation_Mail__c.split(';');
        }
        
        if(String.isNotBlank(tpaCustomSettings.TPA_BCC_Emails__c)) {
           List<String> bccTo = new List<String>();
           bccTo.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(';'));
        }

        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/
        
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
            }
        } catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_Cancellation_Template:::SendCompletionOfCancelationNotification', (amaAgrObj != null && amaAgrObj.TPA_Request__c != null) ? amaAgrObj.TPA_Request__c : ''));
            system.debug('Notification sent to TP-US after completion : ' + e.getMessage());
        } 
    }
    
}
