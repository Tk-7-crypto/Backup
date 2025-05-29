global class CNT_TPA_ClientConfirmRequestedForm {
    
    /************
     Properties
    *************/
    public TPA_Request__c tpaRequest {get; set;}


    public string tpaRequestId {get; set;}

    public String jsonData{get;set;}
    public String language{get;set;}
    
    public boolean isMessageShow { get; set; }
    public boolean isTPAPermanentDown { get; set; }
    public String title { get; set; }
    public class myException extends Exception{}
    public String Message { 
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
    public boolean TPA_Is_Show_TPA_Down_Message {get;set;}
    private static User CurrentUser = UTL_TPA_Multilingual.CurrentUser;
    public static string isQaTesting {get; set;}


    /************
     Constructor
    *************/
    public CNT_TPA_ClientConfirmRequestedForm() {
        //Added for site to community logic submission start
        if(currentLoggedInUser.Profile.Name == 'tpa Profile') {
            system.debug('In check profile:::' + currentLoggedInUser.Profile.Name);
            return;
        }
        //Added for site to community logic submission end

        // perform initialization tasks
        tpaRequest = new TPA_Request__c();
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
    public static TPA_Request__c tpaRequestToEdit {
        get{
            string tpaRequestId;
            if(tpaRequestToEdit == null){
                if(!Test.isRunningTest()) {
                    tpaRequestId = ApexPages.currentPage().getParameters().get('id');
                }
                if(tpaRequestId != null) {
                    tpaRequestToEdit = [select Id, Name, Client_Confirmation_Requested_Response__c, Request_Status__c, Client_Project_Name__c, Client_Address__r.Name, Service_Provider_Address__r.Name from TPA_Request__c where Id =: tpaRequestId];
                    system.debug('tpaRequestToEdit::'+tpaRequestToEdit);
                }
            }
            return tpaRequestToEdit;
        }
        set;
    }


    


    
    
    /***************
     Public Methods
    ****************/
    public PageReference requestValidateOnLoad() {
        //Added for site to community logic submission start
        if(currentLoggedInUser.Profile.Name == 'tpa Profile') {
            system.debug('In check profile0:::' + currentLoggedInUser.Profile.Name);
            return null;
        }
        //Added for site to community logic submission end

        tpaRequestId = ApexPages.currentPage().getParameters().get('id');
        if(tpaRequestId != null && !String.IsBlank(tpaRequestId))
        {
            // gets the vendor language selected at the time of request submit to be used in this page
            language = UTL_TPA_Multilingual.getLanguageForExistingRequests(tpaRequestId, 'v');

            tpaRequestToEdit = [select Id, Name, Client_Confirmation_Requested_Response__c, Request_Status__c, Client_Project_Name__c, Client_Address__r.Name, Service_Provider_Address__r.Name from TPA_Request__c where Id =: tpaRequestId];
            if(tpaRequestToEdit != null && tpaRequestToEdit.Client_Confirmation_Requested_Response__c != null){
                return new PageReference('/VFP_TPA_Page_Status?type=clientConfirmRequestedFormAlreadySubmitted&lang='+language);
            }

        }
        return null;
    }

    public string getObjectTpaRequestToEdit()
    {
        return JSON.serialize(tpaRequestToEdit);
    }

    @remoteAction
    global static string saveRequest(string clientConfirmRequestedFormObj, Boolean clientConfirmReq1, Boolean clientConfirmReq2, Boolean clientConfirmReq3, Boolean clientConfirmReq4)
    {
        system.debug('clientConfirmRequestedFormObj::'+clientConfirmRequestedFormObj);
        List<TPA_Request__c> updateRequestList = new List<TPA_Request__c>();
        Type t = Type.forName('TPA_Request__c');
        TPA_Request__c tpaRequest = (TPA_Request__c)JSON.deserialize(clientConfirmRequestedFormObj, t);
        string venodrLanguage = UTL_TPA_Multilingual.getLanguageForExistingRequests(tpaRequest.Id, 'v');
        if(tpaRequest != null){
            TPA_Request__c requestToUpdate = [select Id, Name, Client_Confirmation_Requested_Response__c, Request_Status__c, Client_Project_Name__c, Client_Address__r.Name, Service_Provider_Address__r.Name, Pending_Acknowledgements__c, Client_Email__c, Client_TPA_Representative_Email__c, Owner.Type, Owner.Email, TP_Processor_Email__c, Client_Address__r.TPAOtherEmailIds__c, TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Assigned_TP_Processor__r.Initials__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__r.Initials__c, (select Id, Name, Type__c, Email__c from TPA_Request_Contacts__r) from TPA_Request__c where Id =: tpaRequest.Id];
            if (tpaRequest.Client_Confirmation_Requested_Response__c != '' && tpaRequest.Client_Confirmation_Requested_Response__c.length() > 0) {
                requestToUpdate.Client_Confirmation_Requested_Response__c = tpaRequest.Client_Confirmation_Requested_Response__c.substring(0, tpaRequest.Client_Confirmation_Requested_Response__c.length() - 1);
                requestToUpdate.Client_Confirmation_Req_Response_Date__c = System.now();
                if(requestToUpdate.Pending_Acknowledgements__c != null && requestToUpdate.Pending_Acknowledgements__c.indexOf(UTL_TPA.Pending_Client_Acknowledgements) != -1) {
                    string strPickListValue = requestToUpdate.Pending_Acknowledgements__c;
                    if(strPickListValue != null) {
                        List<string> lstPicklistValues = strPickListValue.split(';');
                        string strValueToRemove = UTL_TPA.Pending_Client_Acknowledgements;
                        if(lstPicklistValues != null && lstPicklistValues.contains(strValueToRemove)){
                            lstPicklistValues.remove(lstPicklistValues.indexOf(strValueToRemove));
                        }
                        requestToUpdate.Pending_Acknowledgements__c = String.join(lstPicklistValues,';');
                    }
                }
                updateRequestList.add(requestToUpdate);
            }
            system.debug('requestToUpdate::'+requestToUpdate);
            String bodyText = '<div style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;padding-left: 35px;">' +(clientConfirmReq1 ? '<input type="checkbox" checked="checked" disabled>' : '<input type="checkbox" disabled>' ) + '<b>&nbsp;&nbsp;'+Label.TPA_Disclosure_to_external_legal_counsel_solely_for_purposes_of_obtaining_intern+'</b>';
            bodyText += '<div style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;"><ul style="list-style-type:circle;padding-left: 35px;"><li style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;"> ' + Label.TPA_Description_If_Client_is_interested_in_or_required_to_disclose_IQVIA_inform + '</li>';
            bodyText += '</ul></div></div> ';
            bodyText += '<div style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;padding-left: 35px;">' +(clientConfirmReq2 ? '<input type="checkbox" checked="checked" disabled>' : '<input type="checkbox" disabled>' ) + '<b>&nbsp;&nbsp;'+Label.TPA_Disclosure_to_a_retained_expert_or_consultant_solely_for_purposes_of_obtaini+'</b>';
            bodyText += '<div style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;"><ul style="list-style-type:circle;padding-left: 35px;"><li style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;"> ' + Label.TPA_If_Client_is_interested_in_or_required_to_disclose_IQVIA_information_to_expe + '</li>';
            bodyText += '</ul></div></div> ';
            bodyText += '<div style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;padding-left: 35px;">' +(clientConfirmReq3 ? '<input type="checkbox" checked="checked" disabled>' : '<input type="checkbox" disabled>' ) + ' <b>&nbsp;&nbsp;'+Label.TPA_Disclosure_to_other_litigants_experts_attorneys_etc_in_connection_with_l+'</b>';
            bodyText += '<div style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;"><ul style="list-style-type:circle;padding-left: 35px;"><li style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;"> ' + Label.TPA_If_Client_is_interested_in_or_required_to_disclose_IQVIA_information_includ + '</li>';
            bodyText += '</ul></div></div> ';
            bodyText += '<div style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;padding-left: 35px;">' +(clientConfirmReq4 ? '<input type="checkbox" checked="checked" disabled>' : '<input type="checkbox" disabled>' ) + ' <b>&nbsp;&nbsp;'+Label.TPA_Disclosure_for_governmental_purposes+'</b>';
            bodyText += '<div style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;"><ul style="list-style-type:circle;padding-left: 35px;"><li style="font-size:13px;padding: 0 5px 0 5px;font-family:arial;"> ' + Label.TPA_Description_A_response_to_an_inquiry_from_a_governmental_organization_agen + '</li>';
            bodyText += '</ul></div></div> ';
            system.debug('bodyText::'+bodyText);
            try {
                if(updateRequestList != null && updateRequestList.size() > 0){
                    update updateRequestList;
                }
            }
            catch(Exception ex)
            {
                UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_ClientConfirmRequestedForm.saveRequest', tpaRequest.Id);
                system.debug(ex.getMessage());
            }
            
            sendClientConfirmationResponseEmail(requestToUpdate, 'Email Client Confirm Response', bodyText);
            sendConfirmationResponsetoTPUSEmail(requestToUpdate, 'Email Confirm Response to TPUS', bodyText);
            return ('success~'+'VFP_TPA_Page_Status?type=clientConfirmRequestedFormSubSuccess&lang='+venodrLanguage);
        }
        
        return 'error';
    }
    
    public static void sendClientConfirmationResponseEmail(TPA_Request__c reqObj, String settingName, String bodyText){
        List<String> toAddress = new List<String>();
        String emailBody;
        String subjText;
        String offList = '';
        List<String> ccAddress = new List<String>();
        if(reqObj.Client_Email__c != null){
            toAddress.add(reqObj.Client_Email__c);
        }
        if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
            toAddress.add(reqObj.Client_TPA_Representative_Email__c);
        }
        if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
            toAddress.add(reqObj.Owner.Email);
        }
        //toAddress.add('shaikshavali.shaik@metacube.com');
        //toAddress.add('sshaik@us.imshealth.com');
        if(reqObj.TP_Processor_Email__c != null){
            ccAddress.add(reqObj.TP_Processor_Email__c);
        }
        if(settingName == 'Email Client Confirm Response'){
            if(reqObj.TPA_Request_Contacts__r != null && reqObj.TPA_Request_Contacts__r.size() > 0){
                for(TPA_Contact__c tpaContact : reqObj.TPA_Request_Contacts__r ){
                    if(tpaContact.Type__c == 'Additional Client Contact' && tpaContact.Email__c != null){
                        ccAddress.add(tpaContact.Email__c);
                    }
                }
            }
        }
        ccAddress = UTL_TPA_Multilingual.ccList(reqObj.Client_Address__r.TPAOtherEmailIds__c, ccAddress);
        String templateId = UTL_TPA_Multilingual.multilingualTemplateSettingsMap.get(settingName+'English').Translated_Template_Id__c;
        system.debug('template ID : ' + templateId);
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateId != '' && templateId != null){
            try {
                system.debug('templateID'+templateID);
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
                system.debug('in try for email send');
            } catch(Exception exp) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::SRV_TPA_TPARequest:::sendEmailDirectToClient:::', reqObj.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);    
            }
            String tempEmailBody = emailNotToSend.getHTMLBody();
            emailBody = tempEmailBody.replace('[content]', bodyText);
            subjText = emailNotToSend.getSubject();
        }
        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccAddress,'SendEmail', null, reqObj.Id, null, subjText, FALSE, emailBody,TRUE,TRUE,reqObj);
    }
    
    public static void sendConfirmationResponsetoTPUSEmail(TPA_Request__c reqObj, String settingName, String bodyText){
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        List<String> toAddress = new List<String>();
        String emailBody;
        String subjText;
        String offList = '';
        List<String> ccAddress = new List<String>();
        if(String.isNotBlank(tpaCustomSettings.TP_US_Mail_Id__c)){
            toAddress.add(tpaCustomSettings.TP_US_Mail_Id__c);
        }

        //toAddress.add('shaikshavali.shaik@metacube.com');
        //toAddress.add('sshaik@us.imshealth.com');
        String templateId = UTL_TPA_Multilingual.multilingualTemplateSettingsMap.get(settingName+'English').Translated_Template_Id__c;
        system.debug('template ID : ' + templateId);
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateId != '' && templateId != null){
            try {
                system.debug('templateID'+templateID);
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
                system.debug('in try for email send');
            } catch(Exception exp) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::SRV_TPA_TPARequest:::sendEmailDirectToClient:::', reqObj.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);    
            }
            String tempEmailBody = emailNotToSend.getHTMLBody();
            emailBody = tempEmailBody.replace('[content]', bodyText);
            String tableBodytext = '<table style="border-collapse: collapse;border:2px solid;"><tr><th style="border:2px solid;font-size:13px;font-family:arial;">Manual Trigger(s)</th><th style="border:2px solid;font-size:13px;font-family:arial;">Trigger Description</th><th style="border:2px solid;font-size:13px;font-family:arial;">Consideration(s)</th></tr>';
            
            List<TPA_Text_Editor__c> manualReasonTextEditorList = [select id, Page_Name__c, Page_Title__c, Page_Url__c,Content__c from TPA_Text_Editor__c where Page_Type__c = 'Manual Review Reasons' and  Page_Name__c =: UTL_TPA.Expert_Analysis_for_Legal_or_Governmental_Purposes_Selected ];
            
            IF(manualReasonTextEditorList != null && manualReasonTextEditorList.size() > 0){
                for(TPA_Text_Editor__c manualReason : manualReasonTextEditorList) {
                    List<String> lstReason = new List<String>();
                    if(manualReason.Content__c != null && manualReason.Content__c.containsIgnorecase('SPLIT-HERE')){
                        lstReason = (manualReason.Content__c.unescapeHtml4().stripHtmlTags()).split('SPLIT-HERE');
                    }
                    if(lstReason != null && lstReason.size() > 2) {
                        tableBodytext += '<tr><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[0]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[1]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[2]+'</td></tr>';
                    }
                }
            }
            emailBody = emailBody.replace('[Manual_Trigger_Description]', tableBodytext);
            subjText = emailNotToSend.getSubject();
        }
        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccAddress,'SendEmail', null, reqObj.Id, null, subjText, FALSE, emailBody,TRUE,TRUE,reqObj);
    }


}
