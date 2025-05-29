global class CNT_TPA_ManualDDNTrigger { 
    public static TPA_Request__c tpaRequest {get; set;}
    public static TPA_Request__c tpaRequestToEdit {get; set;}
    public static String isVendorDDNInfCorrect{get; set;}
    public string isAuthorisedSigner {get; set;}
    public static TPA_Agreement_Additional_Field__c tpaAgreementAdditionalFieldData;
    
    public string tpaRequestId {get; set;}
    
    public String jsonData{get;set;}
    public String language{get;set;}
    
    
    /************
    Constructor
    *************/
    public CNT_TPA_ManualDDNTrigger() {
        
        // perform initialization tasks
        tpaRequest = new TPA_Request__c();
    }
    
    
    /***************
    Public Methods
    ****************/
    public PageReference requestValidateOnLoad() {
        
        tpaRequestId = ApexPages.currentPage().getParameters().get('id');
        if(tpaRequestId != null && !String.IsBlank(tpaRequestId))
        {
            // gets the vendor language selected at the time of request submit to be used in this page
            language = UTL_TPA_Multilingual.getLanguageForExistingRequests(tpaRequestId, 'v');
            
            
            tpaAgreementAdditionalFieldData = [select id,Vendor_DDN_First_Name__c,Vendor_DDN_Last_Name__c,Vendor_DDN_Title__c,Vendor_DDN_Email__c,Related_TPA_Request__c,Related_TPA_Request__r.Early_Contract_Expiry_Date__c from TPA_Agreement_Additional_Field__c where Related_TPA_Request__c = :tpaRequestId LIMIT 1];
            tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(tpaRequestId);
            if(tpaRequestToEdit != null)
                isAuthorisedSigner = tpaRequestToEdit.TPA_Authorised_Signer__c;
        }
        return null;
    }
    
    public string getObjectTpaRequestToEdit()
    {
        return JSON.serialize(tpaRequestToEdit);
    }
    public string gettpaAgreementAdditionalFieldData()
    {
        return JSON.serialize(tpaAgreementAdditionalFieldData);
    }
    
    @remoteAction
    global static string saveRequest(string AgreementAdditionalFieldObj,String action)
    {
        List<string> toRecipients = new List<String>();
        List<string> ccRecipients = new List<String>();
        String isVendorDDNInfCorrect = (String)JSON.deserialize(action, String.class);
        Boolean isRenewedReqCancelled = false;
        Type t = Type.forName('TPA_Agreement_Additional_Field__c');
        tpaAgreementAdditionalFieldData = (TPA_Agreement_Additional_Field__c)JSON.deserialize(AgreementAdditionalFieldObj, t);
        string venodrLanguage = UTL_TPA_Multilingual.getLanguageForExistingRequests(tpaAgreementAdditionalFieldData.Related_TPA_Request__c, 'v');
        String preferredLanguage = 'English';
        try{
            if( isVendorDDNInfCorrect == 'No' && tpaAgreementAdditionalFieldData != null)
            {
                update tpaAgreementAdditionalFieldData;
            }
            tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(tpaAgreementAdditionalFieldData.Related_TPA_Request__c);
            preferredLanguage = tpaRequestToEdit.vendor_language__c != null ? tpaRequestToEdit.vendor_language__c : 'English';
            tpaRequest = [select id, Name,Renewed_As__c,Renewed_As__r.Request_Status__c,Renewed_As__r.Cancelled__c,Expired_Date__c,request_termination_time__c from TPA_Request__c where Id =: tpaAgreementAdditionalFieldData.Related_TPA_Request__c limit 1];
            if(tpaRequest.Renewed_As__c != null 
               && tpaRequest.Renewed_As__r.Request_Status__c == 'cancelled' 
               && (tpaRequest.Renewed_As__r.Cancelled__c >= tpaAgreementAdditionalFieldData.Related_TPA_Request__r.Early_Contract_Expiry_Date__c
                   || tpaRequest.Renewed_As__r.Cancelled__c >= tpaRequest.Expired_Date__c
                   || tpaRequest.Renewed_As__r.Cancelled__c >= tpaRequest.request_termination_time__c))
            {
                isRenewedReqCancelled = true;
            }
            if(isVendorDDNInfCorrect == 'Yes'){
                if(tpaRequestToEdit.Vendor_e_mail__c != null){
                    toRecipients.add(tpaRequestToEdit.Vendor_e_mail__c);
                }
                if(tpaRequestToEdit.Authorized_Signer_Email__c != null && tpaRequestToEdit.Vendor_e_mail__c != tpaRequestToEdit.Authorized_Signer_Email__c)
                    toRecipients.add(tpaRequestToEdit.Authorized_Signer_Email__c);
            }
            if(isVendorDDNInfCorrect == 'No'){
                if(tpaAgreementAdditionalFieldData.Vendor_DDN_Email__c != null)
                    toRecipients.add(tpaAgreementAdditionalFieldData.Vendor_DDN_Email__c);
            }
            if(tpaRequestToEdit.ClientContact__r.Email != null){
                ccRecipients.add(tpaRequestToEdit.ClientContact__r.Email);
            }
            if(tpaRequestToEdit.Client_TPA_Representative_Email__c != null && tpaRequestToEdit.Client_TPA_Representative_Email__c != ''){
                ccRecipients.add(tpaRequestToEdit.Client_TPA_Representative_Email__c);
            }
            if(tpaRequestToEdit.Owner.Type != null && tpaRequestToEdit.Owner.Type == 'Queue' && tpaRequestToEdit.Owner.Email != null){
                ccRecipients.add(tpaRequestToEdit.Owner.Email);
            }
            if(tpaRequestToEdit.TPA_Request_Contacts__r.size() > 0)
            {
                for(TPA_Contact__c tpaCon : tpaRequestToEdit.TPA_Request_Contacts__r)
                {
                    ccRecipients.add(tpaCon.Email__c);
                }
            }
            System.debug('INN!234');
            Id templateID;
            List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
            
            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            
            try
            {
                system.debug('vendor language'+venodrLanguage);
                system.debug('vendor language'+preferredLanguage);
                templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email 3Day Notice of Ack DD'+preferredLanguage).Translated_Template_Id__c;
                system.debug('templateId'+templateId);
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, tpaRequestToEdit.Id);
            }
            catch(Exception e)
            {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_ManualDDNTrigger:::saveRequest:::Template Error',tpaRequestToEdit.id != null ? tpaRequestToEdit.id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
            
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setCharset('UTF-8');
            emailToSend.setToAddresses(toRecipients);
            emailToSend.setPlainTextBody(emailNotToSend.getPlainTextBody());
            emailToSend.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
            emailToSend.setSubject(emailNotToSend.getSubject());
            emailToSend.setOrgWideEmailAddressId(TPA_Settings__c.getInstance().TPA_From_Orgwide_Email_Id__c);
            emailToSend.setWhatId(tpaRequestToEdit.Id);
            emailToSend.setSaveAsActivity(true);
            
            if(String.isNotBlank(TPA_Settings__c.getOrgDefaults().TPA_RequestSubmitted_Email__c) && ccRecipients != null ) {
                ccRecipients.addAll(TPA_Settings__c.getOrgDefaults().TPA_RequestSubmitted_Email__c.split(','));
            }
            if(tpaRequestToEdit.Vendor_Compliance_Email__c != null){
                ccRecipients.add(tpaRequestToEdit.Vendor_Compliance_Email__c);
            }
            if(ccRecipients != null && ccRecipients.size() > 0)
            {
                
                emailToSend.setCcAddresses(ccRecipients);
            }
            
            msgListToBeSend.add(emailToSend);
            try
            {
                if(msgListToBeSend != null && msgListToBeSend.size() > 0 && UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                    SRV_TPA_TPARequest.sendEmailThroughWorkflow(toRecipients, ccRecipients, 'SendEmail', templateId, tpaRequestToEdit.Id, null, '', FALSE, '', FALSE, FALSE, null);
                }
            }
            catch(Exception e)
            {
               UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_ManualDDNTrigger:::saveRequest:::Email Failed',tpaRequestToEdit.id != null ? tpaRequestToEdit.id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
            TPA_Acknowledgment_Log__c tpaAckLog = new TPA_Acknowledgment_Log__c();
            for(String recipient : toRecipients)
            {
                if(tpaAckLog.Email_Sent_To__c == null || tpaAckLog.Email_Sent_To__c == '')
                    tpaAckLog.Email_Sent_To__c = recipient;
                else
                    tpaAckLog.Email_Sent_To__c = tpaAckLog.Email_Sent_To__c +  ', ' + recipient;
            }
            tpaAckLog.TPA_Request__c = tpaRequestToEdit.Id;
            if(isRenewedReqCancelled) {
                tpaAckLog.Description__c = 'Data Destroy Notificiation sent after renewed request cancelled';
            } else {
                tpaAckLog.Description__c = 'Data Destroy Notificiation re-trigger successfully';
            }
            insert tpaAckLog;
            return ('success~'+'VFP_TPA_Page_Status?type=venOfferingReturnSubSuccess&lang='+venodrLanguage);
        }catch(Exception ex)
        {
            UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                FALSE, 
                                                UTL_LogFactory.GUID, 
                                                ex.getMessage(), 
                                                'TPA', 
                                                'Exception', 
                                                'ERROR', 
                                                'Line#' + ex.getLineNumber() + ' :::CNT_TPA_ManualDDNTrigger:::saveRequest :: ', 
                                                (tpaRequestToEdit.Id != null) ? tpaRequestToEdit.Id : '');
        }
        return 'error';
    }
}
