global class CNT_TPA_VendorSpeciNotifOffAck {
    public static TPA_Request__c tpaRequest {get; set;}
    public static TPA_Request__c tpaRequestToEdit {get; set;}
    public static String actionToPerform{get; set;}
    public static String processExecutionMode{get; set;}
    public static Boolean isSubmitclicked;
    public static TPA_Agreement_Additional_Field__c tpaAgreementAdditionalFieldData;

    public static string tpaRequestId {get; set;}

    public String jsonData{get;set;}

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
    public string getObjectTpaRequestToEdit()
    {
        return JSON.serialize(tpaRequestToEdit);
    }
    public string getObjectTpaRequest()
    {
        return JSON.serialize(tpaRequest);
    }
    public string gettpaAgreementAdditionalFieldData()
    {
        return JSON.serialize(tpaAgreementAdditionalFieldData);
    }

    public static Attachment attachment {
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
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

    public CNT_TPA_VendorSpeciNotifOffAck (){
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
                //Message = Label.TPA_Downtime_Message;
                TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
            }
        
        tpaRequestId = ApexPages.currentPage().getParameters().get('id');
        actionToPerform = ApexPages.currentPage().getParameters().get('action');
        processExecutionMode = ApexPages.currentPage().getParameters().get('processExecutionMode');
        isSubmitclicked = false;
        if(tpaRequestId != NULL){
            tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(tpaRequestId);
            tpaRequest = [select id, Name, Request_Status__c from TPA_Request__c where Id =: tpaRequestId limit 1];
            tpaAgreementAdditionalFieldData = [select id from TPA_Agreement_Additional_Field__c where Related_TPA_Request__c = :tpaRequestId LIMIT 1];
        }
    }

    @remoteAction
    global static string saveRequest(string AgreementAdditionalFieldObj,String reqId,String action,String processExeMode, String attachmentBody, String attachmentName)
    {
           String requestId = (String)JSON.deserialize(reqId, String.class);
            
        try
        {
            actionToPerform = (String)JSON.deserialize(action, String.class);
            processExecutionMode = (String)JSON.deserialize(processExeMode, String.class);
            system.debug('requestId'+requestId);
            tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(requestId);
            tpaRequest = [select id, Name, Request_Status__c from TPA_Request__c where Id =: requestId limit 1];
            Type t = Type.forName('TPA_Agreement_Additional_Field__c');
            tpaAgreementAdditionalFieldData = (TPA_Agreement_Additional_Field__c)JSON.deserialize(AgreementAdditionalFieldObj, t);
            system.debug('tpaAgreementAdditionalFieldData'+tpaAgreementAdditionalFieldData);
            update tpaAgreementAdditionalFieldData;
            isSubmitclicked = true;
            if(attachmentName != null && attachmentName != ''){
                attachment.Name =  attachmentName;
                attachment.ParentId = tpaAgreementAdditionalFieldData.id;
                attachment.IsPrivate = false;
                attachment.Body = EncodingUtil.base64Decode(attachmentBody);
                insert attachment;
            }
        }
        catch(Exception ex)
        {
            system.debug('ERROR: '+ex.getMessage());
            //@todo
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            //TPAQueryHelper.setLogObject('', 'Exception: Request Exception', ex.getMessage());
            //TPAQueryHelper.logRef().generateLog();
            UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                FALSE, 
                                                UTL_LogFactory.GUID, 
                                                'Exception: ' + ex.getLineNumber(), 
                                                'TPA', 
                                                'Exception', 
                                                'ERROR', 
                                                ':::CNT_TPA_VendorSpeciNotifOffAck:::saveRequest :: ' + ex.getMessage(), 
                                                (requestId != null) ? requestId : '');
        }
        PageReference pagRef = requestValidateOnLoad();
        return 'success~'+pagRef.getUrl();
    }

    public static PageReference requestValidateOnLoad() {
        //Added for site to community logic submission start
        if(currentLoggedInUser.Profile.Name == 'tpa Profile') {
            system.debug('In check profile:::' + currentLoggedInUser.Profile.Name);
            return null;
        }
        //Added for site to community logic submission end
        PageReference pagRef = null;
        TPA_Action_Log__c TPAActionLogObj = new TPA_Action_Log__c();
        Boolean updateVSNResponse = false;
        system.debug('tpaRequestToEdit'+tpaRequestToEdit);
        system.debug('tpaRequest'+tpaRequest);
        if(ApexPages.currentPage() != null){
        isQaTesting = ApexPages.currentPage().getParameters().get('isQaTesting');
        if(isTPAPermanentDown == true && isQaTesting == 'true'){
            isTPAPermanentDown=false;
            
        }
        else if (isTPAPermanentDown == true){
            isMessageShow = UTL_TPA.isMessageShow;
            isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
            
            title = Label.TPA_Custom_Landing_Page_Title;
            Message = Label.TPA_Downtime_Message;
            TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
            return pagRef;
        }
        }

        if(tpaRequestToEdit != null && tpaRequest != null && (tpaRequest.Request_Status__c == UTL_TPA.AWAITING_CLIENT_CONFIRMATION || tpaRequest.Request_Status__c == 'Awaiting Account Mgmt Communication' || ((tpaRequest.Request_Status__c == 'Pending Cancellation' || tpaRequest.Request_Status__c == 'Awaiting Client Modification') && processExecutionMode == 'DirectToClient')) && (isSubmitclicked == true || processExecutionMode == 'DirectToClient'))
        {
            system.debug('1actionToPerform: '+processExecutionMode+'::'+actionToPerform);
            tpaAgreementAdditionalFieldData = [select id,Vendor_Specific_Notification_Response__c from TPA_Agreement_Additional_Field__c where Related_TPA_Request__c = :tpaRequestToEdit.Id LIMIT 1];
            TPAActionLogObj.TPA_Request__c = tpaRequestToEdit.id;
            TPAActionLogObj.Action_Type__c = 'Vendor Specific Notification';
            Id agreeId = tpaRequest.id;
            if(actionToPerform == 'Cancel')
            {
                tpaRequestToEdit.request_status__c = 'Pending Cancellation';
                tpaRequest.Request_Status__c = 'Pending Cancellation';
                tpaRequestToEdit.TPA_Request_Temporary_Status__c = 'Pending Cancellation';
                tpaAgreementAdditionalFieldData.Pending_Cancellation_Date__c = System.now();
                SRV_TPA_TPARequest.VendorSpecificNotificationSendCancellationConfirmationToClient(tpaRequestToEdit);
                pagRef = new PageReference('/imshealthPortal/VFP_TPA_Page_Status?actionPerformed=pendingCancellation%26reqNo='+tpaRequest.Name);
                updateVSNResponse = true;
            }
            else if(actionToPerform == 'Acknowledge')
            {
                system.debug('in Acknowledge');
                if(tpaRequest.Request_Status__c == 'Awaiting Account Mgmt Communication'){
                    tpaRequestToEdit.request_status__c = 'Awaiting Final Review';
                    tpaRequest.Request_Status__c = 'Awaiting Final Review';
                    tpaRequestToEdit.TPA_Request_Temporary_Status__c = 'Awaiting Final Review';
                    tpaRequestToEdit.In_Awaiting_Final_Review__c = System.now();
                    updateVSNResponse = true;
                    pagRef = new PageReference('/imshealthPortal/VFP_TPA_Page_Status?actionPerformed=awaitingFinalReview&reqNo='+tpaRequest.Name);
                }
                else if(tpaRequest.Request_Status__c == UTL_TPA.AWAITING_CLIENT_CONFIRMATION){
                    Boolean isAckAlready = tpaAgreementAdditionalFieldData.Vendor_Specific_Notification_Response__c != Null && tpaAgreementAdditionalFieldData.Vendor_Specific_Notification_Response__c != '' && tpaAgreementAdditionalFieldData.Vendor_Specific_Notification_Response__c.contains('Acknowledge');
                    if( tpaRequestToEdit.Is_Manually_Approved__c || tpaRequestToEdit.Is_Potential_Vendor_Case__c || (tpaRequestToEdit.AMA_Agreement_Details__r != NULL && tpaRequestToEdit.AMA_Agreement_Details__r.size() > 0 && tpaRequestToEdit.AMA_Agreement_Details__r[0].AMA_Manual_Review__c == true) )
                    {
                        if(isAckAlready){
                            pagRef = new PageReference('/imshealthPortal/VFP_TPA_Page_Status?actionPerformed=responseSubmittedalready&reqNo='+tpaRequest.Name);
                        }
                    }
                }
                tpaRequestToEdit.Is_VSN_Acknowlege_By_Client__c  = False;
            }
            else if(actionToPerform == 'Modify'){                
                if(tpaRequest.Request_Status__c == UTL_TPA.AWAITING_CLIENT_CONFIRMATION || ((tpaRequest.Request_Status__c == 'Pending Cancellation' || tpaRequest.Request_Status__c == 'Awaiting Client Modification' ) && processExecutionMode == 'DirectToClient')){
                    pagRef = new PageReference(UTL_TPA.requestSubmissionformURL +'?id='+tpaRequestToEdit.id+'&requestType=edit&type=c');
                     updateVSNResponse = true;
                }else if(tpaRequest.Request_Status__c == 'Awaiting Account Mgmt Communication'){
                    pagRef = new PageReference('/imshealthPortal/VFP_TPA_Page_Status?actionPerformed=awaitingClientModification&reqNo='+tpaRequest.Name);
                    updateVSNResponse = true;
                }
                tpaRequestToEdit.request_status__c = 'Awaiting Client Modification';
                tpaRequest.Request_Status__c = 'Awaiting Client Modification';
                tpaRequestToEdit.TPA_Request_Temporary_Status__c = 'Awaiting Client Modification';
            }
            else if(actionToPerform == 'Confirm_Cancellation'){
                tpaRequestToEdit.request_status__c = 'Cancelled';
                tpaRequest.Request_Status__c = 'Cancelled';
                tpaRequestToEdit.TPA_Request_Temporary_Status__c = 'Cancelled';
                 updateVSNResponse = true;
                pagRef = new PageReference('/imshealthPortal/VFP_TPA_Page_Status?actionPerformed=confirmCancellation%26reqNo='+tpaRequest.Name);
            }
            TPAActionLogObj.Action_Details__c = 'Action performed : '+actionToPerform+' Request By : '+processExecutionMode;
            tpaAgreementAdditionalFieldData.Vendor_Specific_Notification_Response__c = actionToPerform +' Request';
            tpaAgreementAdditionalFieldData.VSN_Response_Date__c = system.now()- (1/4.8);

            insert TPAActionLogObj;
            if(updateVSNResponse)
            update tpaAgreementAdditionalFieldData;
            if(tpaRequestToEdit.Pending_Acknowledgements__c != null && tpaRequestToEdit.Pending_Acknowledgements__c != ''){
                if(tpaRequestToEdit.Pending_Acknowledgements__c.contains(';'+tpaRequestToEdit.name)){
                    tpaRequestToEdit.Pending_Acknowledgements__c = tpaRequestToEdit.Pending_Acknowledgements__c.remove(';'+'Managed Attribute Acknowledgement');
                }
                else if(tpaRequestToEdit.Pending_Acknowledgements__c.contains(tpaRequestToEdit.name +';')){
                    tpaRequestToEdit.Pending_Acknowledgements__c = tpaRequestToEdit.Pending_Acknowledgements__c.remove('Managed Attribute Acknowledgement' +';');
                }
                else {
                    tpaRequestToEdit.Pending_Acknowledgements__c = tpaRequestToEdit.Pending_Acknowledgements__c.remove('Managed Attribute Acknowledgement');
                }
            }

            
            update tpaRequestToEdit;
            if(processExecutionMode == 'QuintilesIMSSales')
            {
                SRV_TPA_TPARequest.VendorSpecificNotificationSendTPProcessorNotificationofSalesCommunicationResult(tpaRequestToEdit,tpaAgreementAdditionalFieldData,actionToPerform);
            }

        }
        if(pagRef == NULL && tpaRequest.Request_Status__c != UTL_TPA.AWAITING_CLIENT_CONFIRMATION && tpaRequest.Request_Status__c != 'Awaiting Account Mgmt Communication'){
            pagRef = new PageReference('/imshealthPortal/VFP_TPA_Page_Status?actionPerformed=responseSubmittedalready&reqNo='+tpaRequest.Name);
        }
        if(pagRef != NULL && processExecutionMode == 'DirectToClient')
        return new PageReference(EncodingUtil.urlDecode(pagRef.getUrl(), 'UTF-8'));
        return pagRef;
    }

    @remoteAction
    global static void onClientSubmission(string AgreementAdditionalFieldObj, String reqId){
        try{
            String requestId = (String)JSON.deserialize(reqId, String.class);
            TPA_Request__c request = SRV_TPA_TPARequest.getRequestInfo(requestId);
            Type t = Type.forName('TPA_Agreement_Additional_Field__c');
            tpaAgreementAdditionalFieldData = (TPA_Agreement_Additional_Field__c)JSON.deserialize(AgreementAdditionalFieldObj, t);
            tpaAgreementAdditionalFieldData.Offering_Notification_Acknowledged__c = Date.today();
            tpaAgreementAdditionalFieldData.Vendor_Specific_Notification_Response__c =  'Acknowledge Request';
            update tpaAgreementAdditionalFieldData;
            SRV_TPA_TPARequest.VendorSpecificNotificationClientContactAcknowledgment(request,tpaAgreementAdditionalFieldData);
            request.Is_VSN_Acknowlege_By_Client__c = false;
            request = SRV_TPA_TPARequest.getRequestStatus(request);
            update request;
        }catch(Exception ex){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_VendorSpeciNotifOffAck:::onClientSubmission:::  Exception' + ':::TPArequest:::' +((reqId != null) ? reqId : '') , reqId != null ? reqId : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('Exception on Client Acknowledgement: ' + ex.getMessage());
        }
    }

}
