global class CNT_TPA_EarlyExpiryForm {
    public static TPA_Request__c tpaRequest {get; set;}
    public static String tpaRequestId {get; set;}
    public string IMSLogo {
        get{
            if(IMSLogo == null){
                String imageLogoId= TPA_Settings__c.getInstance().IMS_health_logo_url__c?.substring(TPA_Settings__c.getInstance().IMS_health_logo_url__c?.lastIndexOf('=') + 1);
                String imageurl =  TPA_Settings__c.getOrgDefaults().Base_Url_Public__c+'/servlet/servlet.ImageServer?id=' +imageLogoId+'&oid='+UserInfo.getOrganizationId()+'&contentType=image/png';
                return imageurl;
            }
            return IMSLogo;
        }
        set;
    }
    
    public static boolean isMessageShow { get; set; }
    public static boolean isTPAPermanentDown { get; set; }
    public static String title { get; set; }
    public static String Message { 
        get {
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
    public static boolean TPA_Is_Show_TPA_Down_Message {get;set;}
    private static User CurrentUser = UTL_TPA_Multilingual.CurrentUser;
    public static string isQaTesting {get; set;}
    public string getObjectTpaRequest()
    {
        return JSON.serialize(tpaRequest);
    }
    
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
    
    public CNT_TPA_EarlyExpiryForm (){
        
        isMessageShow = UTL_TPA.isMessageShow;
        isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
        
        title = Label.TPA_Custom_Landing_Page_Title;
        
        TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
        
        String restrictedUserIds = Label.TPA_Non_Restricted_Users;
        String currentUserId = String.valueOf(CurrentUser.Id).subString( 0, 15 );
        system.debug('restrictedUserIds:::'+restrictedUserIds.contains( currentUserId ));
        if(currentUserId != null && currentUserId.length() > 14){
            if( restrictedUserIds.contains( currentUserId )){
                isRestrictedUser = false; 
            }
            else if(isTPAPermanentDown){
                isRestrictedUser = true;
            }
        }
        isQaTesting = ApexPages.currentPage().getParameters().get('isQaTesting');
        if(isTPAPermanentDown == true && isQaTesting == 'true'){
            isTPAPermanentDown=false;
            
        }
        else if (isTPAPermanentDown == true){
            isMessageShow = UTL_TPA.isMessageShow;
            isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
            
            title = Label.TPA_Custom_Landing_Page_Title;
            TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
        }
        
        tpaRequestId = ApexPages.currentPage().getParameters().get('id');
        if(tpaRequestId != NULL){
            tpaRequest = [SELECt id, Name,Early_Expiry_Acknowledgement_Date__c,Early_Expiry_Requestor_Email__c,Early_Expiry_Requestor_Name__c,Early_Expiry_Requestor_Title__c,Client_Expired_Early__c,Early_Contract_Expiry_Date__c,Expired_Date__c,Expiration_Date__c, Client_Set_Earlier_Expiry_Date__c, Request_Status__c,Client_Email__c,Client_TPA_Representative_Email__c, Owner.Type, Owner.Email,TP_Processor_Email__c, Vendor_Contact_e_mail__c,Vendor_Contact_Email_Client__c,Client_Address__r.TPAOtherEmailIds__c,  Global_Brand_Company_Name__c,Client_Project_Name__c, (SELECT id, Type__c, Email__c FROM TPA_Request_Contacts__r),(SELECT Current_Year_Fees__c, Next_Year_Fees__c FROM AMA_Agreement_Details__r),(SELECT id FROM TPA_Agreement_Additional_Fields__r)  FROM TPA_Request__c where Id =: tpaRequestId LIMIT 1];
        }
    }
    

    
    @remoteAction
    global static void onClientSubmission(String expiryDate , String request){
        try{
            TPA_Request__c tpaRequest = (TPA_Request__C)JSON.deserialize(request, TPA_Request__C.class);
            List<String> DateString = expiryDate.split('-');

            tpaRequest.Early_Contract_Expiry_Date__c = DateTime.newInstance(Integer.valueOf(DateString[0]), Integer.valueOf(DateString[1]), Integer.valueOf(DateString[2]) ,00,00,00); 
            if(tpaRequest.Expiration_Date__c.isSameDay(Date.today())){
                tpaRequest.Request_Status__c = 'Expired';
                update tpaRequest;
                CNT_TPA_ContinueNotificationProcess.sendDDNMail(tpaRequest.TPA_Agreement_Additional_Fields__r[0].id, false);
            }else{
                update tpaRequest;
            }
            sendEarlyExpiryMail(tpaRequest);
        }catch(Exception ex){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_EarlyExpiryForm:::onClientSubmission:::  Exception' + ':::TPArequest:::' +((tpaRequest != null) ? tpaRequest.id : '') , tpaRequest != null ? tpaRequest.id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('Exception on Ealy Expiry Mail: ' + ex.getMessage());
        }
            
    }
    
    public static void sendEarlyExpiryMail(TPA_Request__C reqObj){
        try{
            List<String> toAddress = new List<String>();
            String emailBody;
            String subjText;
            if(reqObj.Client_Email__c != null) {
                toAddress.add(reqObj.Client_Email__c);
            }
            if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
                toAddress.add(reqObj.Client_TPA_Representative_Email__c);
            }
            if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
                toAddress.add(reqObj.Owner.Email);
            }
            for(TPA_Contact__c tpaContact : reqObj.TPA_Request_Contacts__r ){
                if(tpaContact.Email__c != null){
                    toAddress.add(tpaContact.Email__c);
                }
            }
            toAddress = UTL_TPA_Multilingual.ccList(reqObj.Client_Address__r.TPAOtherEmailIds__c, toAddress);
             if(reqObj.Vendor_Contact_Email_Client__c != null) {
                toAddress.add(reqObj.Vendor_Contact_Email_Client__c);
            }
            if(reqObj.Vendor_Contact_e_mail__c != null) {
                toAddress.add(reqObj.Vendor_Contact_e_mail__c);
            }
            if(reqObj.TP_Processor_Email__c != null) {
                toAddress.add(reqObj.TP_Processor_Email__c);
            }
            
            string templateId = UTL_TPA_Multilingual.getEmailTemplateId('Early Expiry Confirmation Email' , 'English');
            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            if(templateID != '' && templateID != null) {  
                try {
                    system.debug('templateID'+templateID);
                    emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
                } catch(Exception exp) {
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::CNT_TPA_EarlyExpiryForm:::sendEarlyExpiryMail:::Template Error', reqObj.Id));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);    
                }
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, null, 'SendEmail', null, reqObj.Id, null, emailNotToSend.getSubject(), FALSE, emailNotToSend.getHTMLBody(), TRUE, TRUE, reqObj);
                if(reqObj.AMA_Agreement_Details__r != null && reqObj.AMA_Agreement_Details__r.size() > 0){
                    if((reqObj.AMA_Agreement_Details__r[0].Current_Year_Fees__c != null && reqObj.AMA_Agreement_Details__r[0].Current_Year_Fees__c > 0) || (reqObj.AMA_Agreement_Details__r[0].Next_Year_Fees__c != null && reqObj.AMA_Agreement_Details__r[0].Next_Year_Fees__c > 0)){
                        sendEarlyExpiryAMAMail(reqObj);
                    }
                }
            }
        }catch(Exception ex){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_EarlyExpiryForm:::sendEarlyExpiryMail:::  Exception' + ':::TPArequest:::' +((reqObj != null) ? reqObj.id : '') , reqObj != null ? reqObj.id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('Exception on Ealy Expiry Mail: ' + ex.getMessage());
        }
    }    
    
     public static void sendEarlyExpiryAMAMail(TPA_Request__C reqObj){
        try{
            List<String> toAddress = new List<String>();
            String emailBody;
            String currentYearFees = '';
            String nextYearFees = '';
            
            if(reqObj.AMA_Agreement_Details__r != null && reqObj.AMA_Agreement_Details__r.size() > 0){
                currentYearFees = (reqObj.AMA_Agreement_Details__r[0].Current_Year_Fees__c != null ? reqObj.AMA_Agreement_Details__r[0].Current_Year_Fees__c.format() : '');
                nextYearFees =  (reqObj.AMA_Agreement_Details__r[0].Next_Year_Fees__c != null ? reqObj.AMA_Agreement_Details__r[0].Next_Year_Fees__c.format() : '');
            }
            toAddress.add(UTL_TPA.TPUSEMailAddress);
            string templateId = UTL_TPA_Multilingual.getEmailTemplateId('Early Expiry Confirmation AMA Email' , 'English');
            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            
            if(templateID != '' && templateID != null) {  
                try {
                    system.debug('templateID'+templateID);
                    emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
                    emailBody = emailNotToSend.getHTMLBody();
                    emailBody = emailBody.replace('CURRENT_FEE', currentYearFees).replace('NEXT_FEE', nextYearFees);
                } catch(Exception exp) {
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::CNT_TPA_EarlyExpiryForm:::sendEarlyExpiryAMAMail:::Template Error', reqObj.Id));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);    
                }
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, null, 'SendEmail', null, reqObj.Id, null, emailNotToSend.getSubject(), FALSE, emailBody, TRUE, TRUE, reqObj);
            }
        }catch(Exception ex){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_EarlyExpiryForm:::sendEarlyExpiryAMAMail:::  Exception' + ':::TPArequest:::' +((reqObj != null) ? reqObj.id : '') , reqObj != null ? reqObj.id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('Exception on Early Expiry Mail: ' + ex.getMessage());
        }
    }
    
    
}