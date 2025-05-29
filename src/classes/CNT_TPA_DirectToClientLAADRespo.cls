global class CNT_TPA_DirectToClientLAADRespo {
    
    public static List<TPA_Request__c> requestDetailValues{get; set;}
    public static List<TPA_Agreement_Additional_Field__c> requestAdditionalFieldDetailValues{get; set;}
    public static String requestID{get; set;}
    public boolean isMessageShow { get; set; }
    public boolean isTPAPermanentDown { get; set; }
    public String title { get; set; }
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
    
    public CNT_TPA_DirectToClientLAADRespo() {
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
    public String amaAgreementDetailAsString{get; set;}
    
    
    public static TPA_Agreement_Additional_Field__c agreementAdditionalFieldDetailObj {
        get{
            if(agreementAdditionalFieldDetailObj == null || agreementAdditionalFieldDetailObj.Direct_To_Client_LAAD_Response_Value__c == null || agreementAdditionalFieldDetailObj.Direct_To_Client_LAAD_Response_Value__c == ''){
                if(!Test.isRunningTest()) {
                    requestID = ApexPages.currentPage().getParameters().get('id');
                }
                if(requestID != null) {
                    
                    requestAdditionalFieldDetailValues = [select id,Direct_To_Client_LAAD_Response_Value__c,Related_TPA_Request__c,Related_TPA_Request__r.Name, LAAD_Question_and_Compliance_Ack_Time__c
                                                            from TPA_Agreement_Additional_Field__c where
                                                            Related_TPA_Request__c = :requestID ];
                    
                    if(requestAdditionalFieldDetailValues!= null && !requestAdditionalFieldDetailValues.isEmpty()) {
                        agreementAdditionalFieldDetailObj = requestAdditionalFieldDetailValues.get(0);
                    }
                }
            }
            return agreementAdditionalFieldDetailObj;
        }
        set;
    }
   
  
    public String agreementAdditionalFieldDetailAsString {
        get{
            return JSON.serialize(agreementAdditionalFieldDetailObj);
        }
        set;
    }
    
    @remoteAction
    public static String saveLAADResponseforClient(String agreementAdditionalFieldObj) {
        
        agreementAdditionalFieldDetailObj = (TPA_Agreement_Additional_Field__c)JSON.deserialize(agreementAdditionalFieldObj, TPA_Agreement_Additional_Field__c.class);        
        TPA_Agreement_Additional_Field__c obj = [Select id, LAAD_Question_and_Compliance_Ack_Time__c, Related_TPA_Request__c, Related_TPA_Request__r.id FROM TPA_Agreement_Additional_Field__c  Where id =:agreementAdditionalFieldDetailObj.id limit 1];
        
        TPA_Request__c tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(obj.Related_TPA_Request__r.id);

        UTL_TPA.getGlobalBrandingVendorId(tpaRequestToEdit);
        SRV_TPA_TPARequest.isDynamicNotificationRequiredForVendor(tpaRequestToEdit); 
        
   
        try {
            
            if(obj.LAAD_Question_and_Compliance_Ack_Time__c != null) {
                return 'alreadySubmittedResponse';
            }
            else {
                
                agreementAdditionalFieldDetailObj.LAAD_Question_and_Compliance_Ack_Time__c = datetime.now();
                
                TPA_Action_Log__c TPAActionLogObj = new TPA_Action_Log__c();
                
                TPAActionLogObj.TPA_Request__c = tpaRequestToEdit.id;
                TPAActionLogObj.Action_Type__c = 'Vendor Specific Notification';
                
                
                TPAActionLogObj.Action_Details__c = 'Action performed : Acknowledge Request By : Client';
                agreementAdditionalFieldDetailObj.VSN_Response_Date__c = system.now()- (1/4.8);
                //if(SRV_TPA_TPARequest.isOnlyLAADResponseReq){
                    agreementAdditionalFieldDetailObj.Vendor_Specific_Notification_Response__c = 'Acknowledge Request';
                //}
                insert TPAActionLogObj;
                update agreementAdditionalFieldDetailObj;
                SRV_TPA_TPARequest.isDynamicNotiAckRecived = true;
                SRV_TPA_TPARequest.istriggerManualReviewReasonsOnly = true;
                
                tpaRequestToEdit = SRV_TPA_TPARequest.manualApproval( tpaRequestToEdit );

                if(tpaRequestToEdit.AMA_USPrescriberData__c == 'Yes' && tpaRequestToEdit.Service_Provider_Address__c != null) {
                    tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(tpaRequestToEdit.Id);
                    String tpaRequestJSON = JSON.serialize(tpaRequestToEdit);
                    tpaRequestToEdit = SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(tpaRequestJSON);
                }

                tpaRequestToEdit.Is_VSN_Acknowlege_By_Client__c  = False;
                tpaRequestToEdit.is_LAAD_Response_Acknowledged__c = True;

                update tpaRequestToEdit;
                                               
                SRV_TPA_TPARequest.DirectToClientNotificationSendTPProcessorNotificationofClientLAADResponce(tpaRequestToEdit,agreementAdditionalFieldDetailObj);
                
                generateDocument(tpaRequestToEdit.id, tpaRequestToEdit.Agreement_Name__c);
                return ('success~'+('/imshealthPortal/VFP_TPA_Page_Status?actionPerformed=acknowledge&reqNo='+tpaRequestToEdit.Name));
            }
            
        } catch (Exception e) {
            system.debug(e.getMessage());
            return 'error';
        }
    }
    
    @Future(callout=true)
    public static void generateDocument(String recId, string agrName)
    {
        agreementAdditionalFieldDetailObj = [select id,Direct_To_Client_LAAD_Response_Value__c,Related_TPA_Request__c,Related_TPA_Request__r.Name,
                                             LAAD_Question_and_Compliance_Ack_Time__c, Related_TPA_Request__r.id
                                             from TPA_Agreement_Additional_Field__c where
                                             Related_TPA_Request__c = :recId limit 1];
        
        try {
            
            //PageReference pdf = new PageReference(UTL_TPA.tpaSetting.TPA_Client_Community_Url__c+'/VFP_TPA_DirToCli_LAADRespoGenerate?id='+recId+'&docGenCall=true');
            
            PageReference pdf = Page.VFP_TPA_DirToCli_LAADRespoGenerate;
            pdf.getParameters().put('id',recId);
            pdf.getParameters().put('docGenCall','true');

            Blob body;
            if(Test.IsRunningTest()) {
                body = Blob.valueOf('UNIT.TEST');
            }
            else {
                body = pdf.getContent();
            }
            
            String attchDocName = agreementAdditionalFieldDetailObj.Related_TPA_Request__r.Name + ' LAAD Question and Compliance Response Form.doc';
            List<Attachment> attachmentList = [SELECT Id, Name, Body, ContentType  FROM Attachment WHERE Parentid =: recId and Name =:attchDocName];
            if(!attachmentList.isEmpty()) {
                delete attachmentList;
            }
            
            Attachment attach = new Attachment();
            attach.Body = body;
            attach.Name = attchDocName;
            attach.IsPrivate = false;
            attach.ParentId = agreementAdditionalFieldDetailObj.Related_TPA_Request__r.id;
            insert attach;
            
            
        }
        catch(Exception ex) {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_DirectToClientLAADRespo.generateDocument:::Document Generation Failed', recId != null ? recId : '');
            system.debug(ex.getMessage());
        }
        
    }
    
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
}
