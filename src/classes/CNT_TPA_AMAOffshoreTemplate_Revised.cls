global without Sharing class CNT_TPA_AMAOffshoreTemplate_Revised {   
    
    public static List<AMA_Agreement_Detail__c> amaAgreementDetailValues{get; set;}
    public static String amaAgreementID{get; set;}
    public boolean isMessageShow { get; set; }
    public boolean isTPAPermanentDown { get; set; }
    public String title { get; set; }
    public String Message {
        get{
            String content = [Select Content__c from TPA_Text_Editor__c where Page_Title__c = 'Shutdown Message' AND Is_Active__c = true][0].Content__c;
            if(Message == null && content != null){
                Message = content;
            }else if(content == null){
                Message = Label.TPA_Downtime_Message;
            }
            return Message;
        }
        set; 
    }
    public boolean isRestrictedUser { get; set; }
    public boolean TPA_Is_Show_TPA_Down_Message {get;set;}
    private static User CurrentUser = UTL_TPA_Multilingual.CurrentUser;
    public static string isQaTesting {get; set;}

    public static AMA_Agreement_Detail__c amaAgreementDetailObj {
        get{
            if(amaAgreementDetailObj == null){
                if(!Test.isRunningTest()) {
                    amaAgreementID = ApexPages.currentPage().getParameters().get('id');
                }
                if(amaAgreementID != null) {
                
                    amaAgreementID = UTL_TPA_AMA.getValidStringOnlyWordChar(amaAgreementID);
                    Set<String> fieldSet = new Set<String>{'TPA_Request__r.Agreement_Name__c', 'TPA_Request__r.Vendor_Contact_Name_f__c', 'TPA_Request__r.Vendor_Contact_Last_Name__c',
                                                           'TPA_Request__r.Vendor_Company_Name__c', 'TPA_Request__r.TP_Processor_Email__c', 'TPA_Request__r.Vendor_Contact_e_mail__c', 'Ex_US_Legal_Entity_Name__c',
                                                           'TPA_Request__r.Vendor_Contact_Email_Client__c', 'TPA_Request__r.Name'};
                    amaAgreementDetailValues = SLT_AMAAgreementDetail.instance.getAMAAgreementDetailById(true, new Set<Id>{amaAgreementID}, fieldSet);
                    
                    if(amaAgreementDetailValues!= null && !amaAgreementDetailValues.isEmpty()) {
                        amaAgreementDetailObj = amaAgreementDetailValues.get(0);
                    }
                }
            }
            return amaAgreementDetailObj;
        }
        set;
    }
    
    public String amaAgreementDetailAsString {
        get{
            String jsonStr = JSON.serialize(amaAgreementDetailObj);
            jsonStr = jsonStr.replace('\\', '\\\\');
            jsonStr = jsonStr.unescapeJava();
            return jsonStr;
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
    public String getPrintView() {
    
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
    
    public String getWordStyle() {
    
        return '<style>.useDefStyle p {margin:0.0in;} .useDefStyle ol ol li p {margin:0.04in 0.0in 0.1in 0.0in;}</style>';
    }
    
    
    public CNT_TPA_AMAOffshoreTemplate_Revised() {
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
        
        
            TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
            
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
            TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
        }
    }
    
    public string getTechnologyToAccessAMAPPDList() {
    
        List<String> technologyToAccessAMAPPDList = new List<String>();
        Schema.DescribeFieldResult fieldResult = AMA_Agreement_Detail__c.Technologies_to_access_AMA_PPD_by_vendor__c.getDescribe();
        List<Schema.PicklistEntry> pleForVendorCancelationReason = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : pleForVendorCancelationReason){
            technologyToAccessAMAPPDList.add(f.getValue());
        }  
        return JSON.serialize(technologyToAccessAMAPPDList);
    }
    

    
    
    @remoteAction
    public static String saveAMAResponseForOffshore(String amaResponse, String amaAgreementObj) {
        amaAgreementDetailObj = (AMA_Agreement_Detail__c)JSON.deserialize(amaAgreementObj, AMA_Agreement_Detail__c.class);
        //AMA_Agreement_Detail__c obj = SLT_AMAAgreementDetail.instance.getAMAAgreementDetailById(true, new Set<Id>{amaAgreementDetailObj.id}, new Set<String>{'Status_of_Offshore_Process__c', 'TPA_Request__r.Agreement_Name__c', 'TPA_Request__r.Assigned_TP_Processor__c'}).get(0);
        AMA_Agreement_Detail__c obj = [SELECT AMA_Howlong_SP_has_Data_Access__c, AMA_Project_Uses_Value__c, 
            AMA_Response__c, AMA_Services_Provided__c, AMA_TypeOfPrescriberLevelData__c, 
            AMA_reasons_why_offshore_not_approved__c, Agreement_End_Date__c, Agreement_Start_Date__c, Client__c, 
            Contract_Type__c, CurrencyIsoCode, Date_of_AMA_Response_for_Offshore__c, 
            Date_vendor_responded_for_offshore__c, Ex_US_Legal_Entity_Name_Offshore_Storage__c, 
            Ex_US_Legal_Entity_Name_Remote_Access__c, Id, Initial_Termination_Date__c, 
            Last_AMA_offshore_reminder_mail_sent__c, Name, Other_Technology_for_Remote_Access__c, 
            Other_technology_to_access_AMA_PPD__c, Questions_for_Vendor_Response__c, Status_of_Offshore_Process__c, 
            TPA_Request__c, TPA_Request__r.Agreement_Name__c, TPA_Request__r.Assigned_TP_Processor__c,
            TPA_Request__r.TPA_Assigned_TP_Processor__r.Name, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, 
            Technologies_to_access_AMA_PPD_by_vendor__c, Technology_s_selected_for_remote_access__c, 
            Title_for_vendor_who_requested_offshore__c, Vendor_Contact_Name__c, 
            Vendor_Employee_Accessed_Data_in_country__c, Vendor_Employee_Store_Data_in_country__c, 
            Vendor_Legal_Name__c, Vendor_Name_who_requested_offshore__c, Vendor_employee_access_data_in_country__c, 
            Vendor_req_Storage_Permission_from_NonUS__c, Vendor_require_Remote_Access_from_NonUS__c 
            FROM AMA_Agreement_Detail__c WHERE Id = :amaAgreementDetailObj.id] ;

        List <TPA_Request__c> lstReq = [select id, Pending_Acknowledgements__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where id =: obj.TPA_Request__r.id];

        if(lstReq[0].Pending_Acknowledgements__c != null && lstReq[0].Pending_Acknowledgements__c != ''){
            String offShoreAck = 'AMA Offshore Acknowledgement';
            if(lstReq[0].Pending_Acknowledgements__c.contains(';'+offShoreAck)){
                lstReq[0].Pending_Acknowledgements__c = lstReq[0].Pending_Acknowledgements__c.remove(';'+offShoreAck);
            }
            else if(lstReq[0].Pending_Acknowledgements__c.contains(offShoreAck +';')){
                lstReq[0].Pending_Acknowledgements__c = lstReq[0].Pending_Acknowledgements__c.remove(offShoreAck +';');
            }
            else {
                lstReq[0].Pending_Acknowledgements__c = lstReq[0].Pending_Acknowledgements__c.remove(offShoreAck);
            }
        }
        
        
        try {
        
            if(obj.Status_of_Offshore_Process__c  != UTL_TPA.AWAITING_AMA_RESPONSE_FOR_OFFSHORE_PROCESS) {
                return 'alreadySubmittedResponse';
            }
            else {
                if(amaResponse == 'request approved') {
                    obj.Status_of_Offshore_Process__c  = UTL_TPA.AMA_APPROVED_OFFSHORE_PROCESS;
                    obj.AMA_Response__c = UTL_TPA.AMA_RESPONSE_APPROVED;
                }
                else if(amaResponse == 'Additional questions for Vendor') {
                    obj.Status_of_Offshore_Process__c  = UTL_TPA.AMA_ADDITIONAL_QUESTIONS_FOR_OFFSHORE_PROCESS;
                    obj.Questions_for_Vendor_Response__c  = amaAgreementDetailObj.Questions_for_Vendor_Response__c;
                    obj.AMA_Response__c = UTL_TPA.AMA_RESPONSE_ADDITIONAL_QUESTIONS;
                }
                else if(amaResponse == 'not approved') {
                    obj.Status_of_Offshore_Process__c  = UTL_TPA.AMA_DENIED_OFFSHORE_PROCESS;
                    obj.AMA_reasons_why_offshore_not_approved__c  = amaAgreementDetailObj.AMA_reasons_why_offshore_not_approved__c;
                    obj.AMA_Response__c = UTL_TPA.AMA_RESPONSE_NOT_APPROVED;
                }
                obj.Date_of_AMA_Response_for_Offshore__c = Date.today();                 
            }
            update obj;
            update lstReq[0];
                
        } catch (Exception e) {
            system.debug(e.getMessage());
            return 'error';
        }

        sendCompletionOffshoreNotification(obj, lstReq[0]);
        generateDocument(obj.id, obj.TPA_Request__r.Agreement_Name__c);       
        return 'success';
    }
    
    public static void sendCompletionOffshoreNotification(AMA_Agreement_Detail__c amaAgrObj, TPA_Request__c tpaRequest) {
    
        //Set list of people who should be CC'ed
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        String templateId = amaSetting.get(0).Revised_Offshore_Noti_To_TPUS_TemplateID__c  ;
        
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults(); 
        
        //Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        //Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        
        List<String> toAddress = new List<String>();
        List<String> ccTo = new List<String>();
        
        if(amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c != null && amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c != '') {
            toAddress = amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c.split(';');
        }

        if(amaSetting.get(0).CC_Address_For_TPUS_Offshore_Mail__c != null && amaSetting.get(0).CC_Address_For_TPUS_Offshore_Mail__c != '') {
            ccTo = amaSetting.get(0).CC_Address_For_TPUS_Offshore_Mail__c .split(';');
            mail.setCCAddresses(ccTo);
        }
        
        
        if(String.isNotBlank(tpaCustomSettings.TPA_BCC_Emails__c)) {
           List<String> bccTo = new List<String>();
           bccTo.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(';'));
           mail.setBccAddresses(bccTo);
        }

        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/
          
        
        mail.setWhatId(amaAgrObj.id);
        mail.setTemplateId(templateId); 
        mail.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Address_For_Data_Release__c);
        mail.setSaveAsActivity(true);
        
        mails.add(mail);
              
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
            }
        } catch(Exception e) {
            System.debug('Offshore Notification sent to TP-US after completion failed: : ' + e.getMessage());
        } 
    }
    
   
    
    public static void sendOffshoreAMAResponseToDBL(AMA_Agreement_Detail__c amaAgrObj) { 
         
        Date todayDate;
        todayDate = Date.today(); 
        //Set list of people who should be CC'ed
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();                
        String templateId = amaSetting.get(0).Email_Noti_AMA_Submitted_Response_to_AMA__c;
        String dblContractsContactId = tpaCustomSettings.DBL_Contracts_Contact_Id__c; //dblcontracts@ama-assn.org
        String initials = '';
        String globalTPProcessorInitials = '';
        
        //Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        //Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c)) {
        
            List<String> ccTo = amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c.split(';');
            mail.setCCAddresses(ccTo);
        }
        
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
        if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            initials = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
        }
        if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            globalTPProcessorInitials = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
        }
        mail.setSubject(SRV_TPA_TPARequest.setEmailInitials(initials, globalTPProcessorInitials, mail.getSubject()));
        
        if(String.isNotBlank(amaAgrObj.Client__c) &&
            String.isNotBlank(amaAgrObj.Vendor_Legal_Name__c) &&
                (amaAgrObj.Client__c.startsWithIgnoreCase('Test') || amaAgrObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))){
            
            mail.setTreatTargetObjectAsRecipient(false);
        }
        
        
        List<Attachment> attachments = [SELECT Id, Name, Body, ContentType, LastModifiedDate  FROM Attachment WHERE Parentid =:amaAgrObj.id];
        
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment offshoreDoc = new Messaging.EmailFileAttachment();
        for(Attachment att : attachments) {
        
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            // to figure out the correct file extension
            if(String.isNotBlank(att.Name) && att.Name.containsIgnoreCase('AMA Offshore Request for Approval Form')) {
                
                efa.setFileName(att.Name);
                // Take the blob data from the Attachment and put it on the email.
                efa.setBody(att.Body);
                efa.setContentType(att.ContentType);
                emailAttachments.add(efa);
            }
        }
        
        mail.setFileAttachments(emailAttachments);
        mails.add(mail);
                    
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                //Send all emails in the master list
                Messaging.sendEmail(mails);
                
            }
        } catch(Exception e) {
            System.debug('Send AMA Response to DBL failed: ' + e.getMessage());
        } 
    }
    
    
    @Future(callout=true)
    global static void generateDocument(String recId, string agrName)
    {
        AMA_Agreement_Detail__c amaObject = [SELECT AMA_Howlong_SP_has_Data_Access__c, AMA_Project_Uses_Value__c, 
            AMA_Response__c, AMA_Services_Provided__c, AMA_TypeOfPrescriberLevelData__c, 
            AMA_reasons_why_offshore_not_approved__c, Agreement_End_Date__c, Agreement_Start_Date__c, Client__c, 
            Contract_Type__c, CurrencyIsoCode, Date_of_AMA_Response_for_Offshore__c, 
            Date_vendor_responded_for_offshore__c, Ex_US_Legal_Entity_Name_Offshore_Storage__c, 
            Ex_US_Legal_Entity_Name_Remote_Access__c, Ex_US_Legal_Entity_Name__c, Id, 
            Initial_Termination_Date__c, Last_AMA_offshore_reminder_mail_sent__c, Name, 
            Other_Technology_for_Remote_Access__c, Other_technology_to_access_AMA_PPD__c, 
            Questions_for_Vendor_Response__c, Status_of_Offshore_Process__c, TPA_Request__c, 
            TPA_Request__r.Agreement_Name__c, TPA_Request__r.Assigned_TP_Processor__c,
            TPA_Request__r.TPA_Assigned_TP_Processor__r.Name, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,  TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, 
            Technologies_to_access_AMA_PPD_by_vendor__c, Technology_s_selected_for_remote_access__c, 
            Title_for_vendor_who_requested_offshore__c, Vendor_Contact_Name__c, 
            Vendor_Employee_Accessed_Data_in_country__c, Vendor_Employee_Store_Data_in_country__c, 
            Vendor_Legal_Name__c, Vendor_Name_who_requested_offshore__c, Vendor_employee_access_data_in_country__c, 
            Vendor_req_Storage_Permission_from_NonUS__c, Vendor_require_Remote_Access_from_NonUS__c 
            FROM AMA_Agreement_Detail__c WHERE Id = :recId] ;
        //AMA_Agreement_Detail__c amaObject = SLT_AMAAgreementDetail.instance.getAMAAgreementDetailById(true, new Set<Id>{recId}, new Set<String>{'TPA_Request__r.Agreement_Name__c', 'Ex_US_Legal_Entity_Name__c', 'TPA_Request__r.Assigned_TP_Processor__c'}).get(0);
        try {
            system.debug('URL:'+ UTL_TPA.tpaSetting.TPA_Client_Community_Url__c+'/VFP_TPA_AMA_OffshoreDocGenerator?id='+recId+'&docGenCall=true');
            
            PageReference pdf = Page.VFP_TPA_AMA_OffshoreDocGenerator;
             
            pdf.getParameters().put('id',recId);
            pdf.getParameters().put('docGenCall','true');
            
            Blob body;
            if(Test.IsRunningTest()) {
                body = Blob.valueOf('UNIT.TEST');
            }
            else {
                body = pdf.getContent();
            }
            
            String attchDocName = 'AMA Offshore Request for Approval Form - AMA Response_For AMA Records.doc';
            List<Attachment> attachmentList = [SELECT Id, Name, Body, ContentType  FROM Attachment WHERE Parentid =: recId and Name =:attchDocName];
            if(!attachmentList.isEmpty()) {
                delete attachmentList;
            }
            
            Attachment attach = new Attachment();
            attach.Body = body;
            attach.Name = attchDocName;
            attach.IsPrivate = false;
            attach.ParentId = recId;
            insert attach;
            
            sendOffshoreAMAResponseToDBL(amaObject); 
            
        }
        catch(Exception ex) {
            system.debug(ex.getMessage());
        }
        
    }
    
      
    
}
