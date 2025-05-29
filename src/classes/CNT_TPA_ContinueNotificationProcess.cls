public class CNT_TPA_ContinueNotificationProcess { 
    public TPA_Request__c tpaRequestObj ;
    public TPA_Agreement_Additional_Field__c tpaAgreementAdditionalFieldDataObj;
    public string agrId;
    public string agrAdditionalId;  
    public Date expireDateValue{get; set;}
    public String expireDateString{get; set;}
    public static Boolean isRequestEarlyExpired = false; // flag to update Early expiry field when TPA Request status is "In Effect" 
    
    public CNT_TPA_ContinueNotificationProcess() {
        string reqType = ApexPages.currentPage().getParameters().get('type');
        if(reqType != null && reqType.trim().equalsIgnoreCase('setExpire')) {
            agrAdditionalId = ApexPages.currentPage().getParameters().get('id');
            agrId = ApexPages.currentPage().getParameters().get('agrId');
            getAccessDate();
        }
        else {
          
            agrId = ApexPages.currentPage().getParameters().get('id');
            if(agrId != null)
            {
                tpaAgreementAdditionalFieldDataObj = [select id,Related_TPA_Request__c, Related_TPA_Request__r.Id from TPA_Agreement_Additional_Field__c where Related_TPA_Request__r.Id = :agrId];
                tpaRequestObj = SRV_TPA_TPARequest.getRequestInfo(tpaAgreementAdditionalFieldDataObj.Related_TPA_Request__r.Id);
            }
        } 
    }
    
    public void getAccessDate() {
        TPA_Agreement_Additional_Field__c obj = [Select id,Related_TPA_Request__r.Data_Access_End_Date__c
                    FROM TPA_Agreement_Additional_Field__c Where id = :agrAdditionalId limit 1];
        expireDateValue = (Date)obj.Related_TPA_Request__r.Data_Access_End_Date__c;
    }
    
    public void sendVSNMail(){
        sendMails(JSON.serialize(tpaRequestObj), JSON.serialize(tpaAgreementAdditionalFieldDataObj));
        
    }
    
    @future(callout=true)
    public static void sendMails( String tpaRequest, String tpaAgreementAdditionalFieldData){
        TPA_Request__c tpaRequestObj = (TPA_Request__c)JSON.deserialize(tpaRequest, TPA_Request__c.class);
        TPA_Agreement_Additional_Field__c tpaAgreementAdditionalFieldDataObj = (TPA_Agreement_Additional_Field__c)JSON.deserialize(tpaAgreementAdditionalFieldData, TPA_Agreement_Additional_Field__c.class);
        
        UTL_TPA.getGlobalBrandingVendorId(tpaRequestObj);
       Boolean isAwaitingClientConfirmationMailReq = SRV_TPA_TPARequest.isDynamicNotificationRequiredForVendor(tpaRequestObj);
        if(isAwaitingClientConfirmationMailReq){
            if(SRV_TPA_TPARequest.isQuintilesIMSSalesExeMode == true){
                tpaRequestObj.request_status__c = 'Awaiting Account Mgmt Communication';
                tpaRequestObj.TPA_Request_Temporary_Status__c = 'Awaiting Account Mgmt Communication';
                SRV_TPA_TPARequest.VendorSpecificNotificationSendConfirmationToTPProcessor(tpaRequestObj,tpaRequestObj.ClientContact__r.email);  
            }
            else if(SRV_TPA_TPARequest.isDirectToClientExeMode == true){
                tpaRequestObj.request_status__c = UTL_TPA.AWAITING_CLIENT_CONFIRMATION;
                tpaRequestObj.TPA_Request_Temporary_Status__c = UTL_TPA.AWAITING_CLIENT_CONFIRMATION;
                SRV_TPA_TPARequest.VendorSpecificNotificationSendConfirmationToClient(tpaRequestObj,tpaRequestObj.ClientContact__r.email);   
            }
            tpaRequestObj.Is_VSN_Acknowlege_By_Client__c  = true;
            update tpaRequestObj;
        }
        
    }

    public void setStatusExp(){
    
        TPA_Agreement_Additional_Field__c obj = [Select id, Expire_Contract_Early__c, Early_Contract_Expiry_Date__c, Related_TPA_Request__r.Request_Status__c , Related_TPA_Request__c, Related_TPA_Request__r.vendor_language__c, Related_TPA_Request__r.Vendor_e_mail__c, Related_TPA_Request__r.Authorized_Signer_Email__c, Related_TPA_Request__r.Early_Contract_Expiry_Date__c, Expired_By_User__c
                    FROM TPA_Agreement_Additional_Field__c Where id = :agrAdditionalId limit 1];
        if(expireDateString != null){
            obj.Early_Contract_Expiry_Date__c  =  System.now() + ((System.now()).date()).daysBetween(date.valueOf(expireDateString));
            isRequestEarlyExpired = true;
            obj.Related_TPA_Request__r.Early_Contract_Expiry_Date__c = obj.Early_Contract_Expiry_Date__c;
            obj.Expired_By_User__c = UTL_TPA.getCurrentUserDetails().Name;
        }
        else {
           expireDateString = String.valueof(System.now());
        }
        
        if((System.Now().Date()).isSameDay(Date.valueof(expireDateString))) {
            obj.Related_TPA_Request__r.Request_Status__c = 'Expired';
            update obj.Related_TPA_Request__r;
            sendDDNMail(agrAdditionalId, false);
        }else{
            update obj.Related_TPA_Request__r;
        }
        
        try {
            update obj;
        } catch (Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_ContinueNotificatioProcess.setStatusExp:::in update records', obj.id != null ? obj.id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
    }
    
    public static void sendDDNMail(string agrAddId, Boolean isRenewedReqCancelled){// Updated by Babita Dadarwal under CR-12675
    
        BCH_TPA_Vendor_Off_Return_Ack offReturnAck = new BCH_TPA_Vendor_Off_Return_Ack();
        TPA_Agreement_Additional_Field__c obj = [Select id, Expire_Contract_Early__c, Early_Contract_Expiry_Date__c, Excluded_Offerings_In_Renewal__c, Related_TPA_Request__r.Renewed_As__c, Related_TPA_Request__r.Renewed_As__r.Is_Partially_Renewed__c, Related_TPA_Request__r.Renewed_As__r.Request_Status__c, Related_TPA_Request__r.Request_Status__c, Related_TPA_Request__c,Related_TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, Related_TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, Related_TPA_Request__r.id, Related_TPA_Request__r.vendor_language__c,Related_TPA_Request__r.Service_Provider_f__c, Related_TPA_Request__r.Client_First_Name__c , Related_TPA_Request__r.Vendor_e_mail__c, Related_TPA_Request__r.Authorized_Signer_Email__c, Related_TPA_Request__r.Vendor_Compliance_Email__c
                    FROM TPA_Agreement_Additional_Field__c Where id = :agrAddId limit 1];
        
        String excludedOfferings = '';
        TPA_Agreement_Additional_Field__c tpaRenewedReqAgrAddFieldsRec;
        if(obj.Related_TPA_Request__r.Renewed_As__c != null && obj.Related_TPA_Request__r.Renewed_As__r.Is_Partially_Renewed__c) {
            tpaRenewedReqAgrAddFieldsRec = [Select id, Excluded_Offerings_In_Renewal__c FROM TPA_Agreement_Additional_Field__c Where Related_TPA_Request__c = :obj.Related_TPA_Request__r.Renewed_As__c limit 1];
            if(tpaRenewedReqAgrAddFieldsRec != null && !UTL_Validate.isEmptyOrNull(tpaRenewedReqAgrAddFieldsRec.Excluded_Offerings_In_Renewal__c)) {
                excludedOfferings = tpaRenewedReqAgrAddFieldsRec.Excluded_Offerings_In_Renewal__c;
            }
        }
        
        List<String> toRecipients = new List<String>();
        List<String> ccRecipients = new List<String>();

        String preferredLanguage = obj.Related_TPA_Request__r.vendor_language__c != null ? obj.Related_TPA_Request__r.vendor_language__c : 'English';
        String templateID = '';
        if((obj.Related_TPA_Request__r.Renewed_As__c != null && obj.Related_TPA_Request__r.Renewed_As__r.Is_Partially_Renewed__c && obj.Related_TPA_Request__r.Renewed_As__r.Request_Status__c != 'Cancelled')){
            templateID = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA DDN Partial Modify Email'+preferredLanguage).Translated_Template_Id__c;  
        }else{
            templateID =  UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Ack of DD'+preferredLanguage).Translated_Template_Id__c;
            if(obj.Related_TPA_Request__r.Vendor_Compliance_Email__c != null){
                ccRecipients.add(obj.Related_TPA_Request__r.Vendor_Compliance_Email__c);
            }
        }
        
        /*if(TPA_Settings__c.getInstance().Shared_Email__c != null) {
            ccRecipients.add(TPA_Settings__c.getInstance().Shared_Email__c);
        }*/
        toRecipients.add(obj.Related_TPA_Request__r.Vendor_e_mail__c);
        if(obj.Related_TPA_Request__r.Vendor_e_mail__c != obj.Related_TPA_Request__r.Authorized_Signer_Email__c) {
            toRecipients.add(obj.Related_TPA_Request__r.Authorized_Signer_Email__c);
        }
        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(obj.Related_TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
        	SRV_TPA_TPARequest.assignedTPProcessorName = obj.Related_TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
        
        if((obj.Related_TPA_Request__r.Service_Provider_f__c != null && obj.Related_TPA_Request__r.Service_Provider_f__c.startsWithIgnoreCase('Test_')) || (obj.Related_TPA_Request__r.Client_First_Name__c != null && obj.Related_TPA_Request__r.Client_First_Name__c.startsWithIgnoreCase('Test_'))) {
            offReturnAck.sendMail(obj.Related_TPA_Request__r, toRecipients, ccRecipients, templateID, 1, isRenewedReqCancelled, excludedOfferings);// Updated by Babita Dadarwal under CR-12675
        } else {
            offReturnAck.sendMail(obj.Related_TPA_Request__r, toRecipients, ccRecipients, templateID, 10, isRenewedReqCancelled, excludedOfferings);// Updated by Babita Dadarwal under CR-12675
        }
    }
}
