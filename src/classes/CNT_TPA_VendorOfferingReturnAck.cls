/*****************************************************
* Updated by: Vikram Singh Fartyal on 15Feb2017 (ER-3221)
* Class: TPA_Vendor_Offering_Return_Ack_Con
* VF Page: TPA_Vendor_Offering_Return_Ack_Page
* Purpose: contains the business logic for the page
* ****************************************************/
global class CNT_TPA_VendorOfferingReturnAck {

    /************
     Properties
    *************/
    public TPA_Request__c tpaRequest {get; set;}
    //public static TPA_Request__c tpaRequestToEdit {get; set;}
    public Map<String, String>  purposeIdDataAssetMap {get; set;}
    public string isAuthorisedSigner {get; set;}

    public string tpaRequestId {get; set;}
    public string excludedOfferingsDetail {get; set;}

    public String jsonData{get;set;}
    public String language{get;set;}
    
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


    /************
     Constructor
    *************/
    public CNT_TPA_VendorOfferingReturnAck() {
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
                    tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(tpaRequestId);
                }
            }
            return tpaRequestToEdit;
        }
        set;
    }
    
    public static Vendor_Offering_Return_Acknowledgment__c VORAObj {
        get{
            if(VORAObj == null){
                if(tpaRequestToEdit != null) {
                    if(tpaRequestToEdit.Vendor_Offering_Return_Acknowledgments__r != null && tpaRequestToEdit.Vendor_Offering_Return_Acknowledgments__r.size() > 0) {
                        VORAObj = tpaRequestToEdit.Vendor_Offering_Return_Acknowledgments__r[0]; 
                    }
                }
            }
            return VORAObj;
        }
        set;
    }
    
    public static AMA_Agreement_Detail__c amaAgreementDetail {
        get{
            if(tpaRequestToEdit != null){
                if(tpaRequestToEdit.AMA_Agreement_Details__r != null && tpaRequestToEdit.AMA_Agreement_Details__r.size() > 0){
                    return tpaRequestToEdit.AMA_Agreement_Details__r[0];
                }
            }
            return new AMA_Agreement_Detail__c();
        }
        set;
    }
    
    public static String note {
        get{
            String noteTemp = System.Label.TPA_Note_AMA_DATA_Destruction_Acknowledgment_Attachment;
            String contractType = amaAgreementDetail.Contract_Type__c == null? '' : amaAgreementDetail.Contract_Type__c;
            return noteTemp.replace('[type of agreement]', contractType);
        }
        set;
    }
    
    public static List<String> amaUsesSelected {
        get{
            if(amaUsesSelected == null){
                if(tpaRequestToEdit != null) {
                    if(tpaRequestToEdit.AMA_Agreement_Details__r != null && tpaRequestToEdit.AMA_Agreement_Details__r.size() > 0) {
                        amaUsesSelected = tpaRequestToEdit.AMA_Agreement_Details__r[0].AMA_Services_Provided__c.split(';'); 
                    }
                }
            }
            return amaUsesSelected;
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
        String excludedOfferings = '';
        if(tpaRequestId != null && !String.IsBlank(tpaRequestId))
        {
            // gets the vendor language selected at the time of request submit to be used in this page
            language = UTL_TPA_Multilingual.getLanguageForExistingRequests(tpaRequestId, 'v');

            list<Vendor_Offering_Return_Acknowledgment__c> venOffReturnAckObjlist = [select id from Vendor_Offering_Return_Acknowledgment__c where TPA_Request__c=:tpaRequestId limit 1];
            if(venOffReturnAckObjlist.size() > 0)
            {
                return new PageReference('/VFP_TPA_Page_Status?type=vendorAckAlreadySubmitted&lang='+language);
            }
            tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(tpaRequestId);
            TPA_Agreement_Additional_Field__c tpaRenewedReqAgrAddFieldsRec;
            if(tpaRequestToEdit != null)
                isAuthorisedSigner = tpaRequestToEdit.TPA_Authorised_Signer__c;
            if(tpaRequestToEdit.Renewed_As__c != null && tpaRequestToEdit.Renewed_As__r.Is_Partially_Renewed__c){
                tpaRenewedReqAgrAddFieldsRec = [Select id, Excluded_Offerings_In_Renewal__c FROM TPA_Agreement_Additional_Field__c Where Related_TPA_Request__c = :tpaRequestToEdit.Renewed_As__c limit 1];
                system.debug('tpaRenewedReqAgrAddFieldsRec.Excluded_Offerings_In_Renewal__c'+tpaRenewedReqAgrAddFieldsRec.Excluded_Offerings_In_Renewal__c);
                if(tpaRenewedReqAgrAddFieldsRec != null && !UTL_Validate.isEmptyOrNull(tpaRenewedReqAgrAddFieldsRec.Excluded_Offerings_In_Renewal__c)) {
                    excludedOfferingsDetail = tpaRenewedReqAgrAddFieldsRec.Excluded_Offerings_In_Renewal__c;
                    excludedOfferingsDetail = UTL_TPA.getOfferingDetailsToHtmlList(excludedOfferingsDetail);
                }
            }
            
            Set<Id> purposeIds = new Set<Id>();
            Map<Id, String> purposeMap = new Map<Id, String>();
            purposeIdDataAssetMap = new Map<String, String>();

            for (TPA_Purpose__c tpaPurposeSO :SRV_TPA_TPARequest.getPurposeAndDescriptionList(tpaRequestId))
            {
                purposeIds.add( tpaPurposeSO.Id );
                if(tpaPurposeSO.name == 'Other') {
                    if(tpaPurposeSO.Purpose_Descriptions__r.size() > 0 ){
                        purposeMap.put(tpaPurposeSO.Id,tpaPurposeSO.Purpose_Region__c + '~ '+tpaPurposeSO.Translated_Purpose_Name__c+': '+tpaPurposeSO.Purpose_Descriptions__r[0].Other_Details__c);
                    }else{
                        purposeMap.put(tpaPurposeSO.Id,tpaPurposeSO.Purpose_Region__c + '~ '+tpaPurposeSO.Translated_Purpose_Name__c);
                    }
                }
                else{
                    purposeMap.put(tpaPurposeSO.Id,tpaPurposeSO.Purpose_Region__c + '~ '+tpaPurposeSO.Translated_Purpose_Name__c);
                }
            }

            Map<Id,List<TPA_Data_Asset__c>> purposeIdDataAssetMap1 = SRV_TPA_TPARequest.getPurposeIdDataAssetMap( purposeIds );//Not found in any Util
            for(Id objId : purposeIdDataAssetMap1.keySet())
            {
                string dataAssetString = '';
                for (TPA_Data_Asset__c tpaPurposeDataAssetSO : purposeIdDataAssetMap1.get(objId))
                {
                    if(tpaPurposeDataAssetSO.TPA_Secondary_Data_Assets__r.size()>0) {
                        for(TPA_Secondary_Data_Asset__c secondaryDataAsset : tpaPurposeDataAssetSO.TPA_Secondary_Data_Assets__r)
                        {
                            dataAssetString = dataAssetString + secondaryDataAsset.Secondary_Asset_Name__c + ', ';
                        }
                    }
                    else{
                        if(tpaPurposeDataAssetSO.Asset_NametText__c == 'Other' )
                            dataAssetString = dataAssetString + tpaPurposeDataAssetSO.Asset_NametText__c+ ': '+tpaPurposeDataAssetSO.Other_Text__c +' ,';
                        else
                            dataAssetString = dataAssetString + tpaPurposeDataAssetSO.Asset_NametText__c+' ,';
                    }
                }
                if(dataAssetString != '')
                    dataAssetString = dataAssetString.trim().substring(0,dataAssetString.trim().length() - 1);
                purposeIdDataAssetMap.put(purposeMap.get(objId ),dataAssetString );
            }
        }
        return null;
    }

    public string getObjectTpaRequestToEdit()
    {
        return JSON.serialize(tpaRequestToEdit);
    }
    public string getObjectpurposeIdDataAssetMap()
    {
        return JSON.serialize(purposeIdDataAssetMap );
    }
    public string getExcludedOfferingDetail()
    {
        return JSON.serialize(excludedOfferingsDetail );
    }

    @remoteAction
    global static string saveRequest(string vendorDesConfirmatioSubmitObjDetail)
    {
        Type t = Type.forName('Vendor_Offering_Return_Acknowledgment__c');
        Vendor_Offering_Return_Acknowledgment__c venAckObj = (Vendor_Offering_Return_Acknowledgment__c)JSON.deserialize(vendorDesConfirmatioSubmitObjDetail, t);
        Boolean isPartialRenewed = false;
        if( venAckObj != null) {
            string venodrLanguage = UTL_TPA_Multilingual.getLanguageForExistingRequests(venAckObj.TPA_Request__c, 'v');
            string renewedRequestNo = '';
            if(venAckObj.ActionTaken__c.indexOf('Executed New') > -1) {
                List<string> splitActionArray = venAckObj.ActionTaken__c.split(' ');
                if(splitActionArray != null) {
                    renewedRequestNo = splitActionArray[splitActionArray.size()-1];
                }
            }
            else if(venAckObj.ActionTaken__c.indexOf('The Above Referenced Excluded Offerings') > -1) {
                List<string> splitActionArray = venAckObj.ActionTaken__c.split(' ');
                if(splitActionArray != null) {
                    renewedRequestNo = splitActionArray[splitActionArray.size()-1];
                }
                isPartialRenewed = true;
            }
            string query = 'select Id, Client_Email__c, vendor_language__c,  TP_Processor_Email__c, Is_Partially_Renewed__c, Renewed_As__r.Is_Partially_Renewed__c, Request_status__c, Renewed_As__c, Client_Address__c,Parent_Request__c, Name, Agreement_Name__c, Is_TPA_Send_DDN_Button_Enabled__c, (select id,Is_AMA_License_Required__c  from AMA_Agreement_Details__r) from TPA_Request__c where (Id =\'' + venAckObj.TPA_Request__c +'\' ';
            
            if(renewedRequestNo != '') {
                query += ' OR Name =\'TPA-' + renewedRequestNo + '\'';//@@@@@@@@@@@@@@@
            }
            query += ' )';
            List<TPA_Request__c> tparequestList  = Database.query(query);

            Boolean isRenewedReqNoValid = true;
            TPA_Request__c parentrequest;
            TPA_Request__c renewedRequest;
            if(tparequestList != null && tparequestList.size() > 0) {
                for(TPA_Request__c tparequest : tparequestList) {
                    if(tparequest.Id == venAckObj.TPA_Request__c ) {
                        parentrequest = tparequest;
                    } else If (tparequest.Name == 'TPA-'+renewedRequestNo) {
                        renewedRequest = tparequest;
                    }
                }
                if(renewedRequestNo != '' && !isPartialRenewed) {
                    if( renewedRequest == null || (renewedRequest != null && renewedRequest.Request_status__c == 'Cancelled')) {
                        isRenewedReqNoValid = false;
                    } else {
                        isRenewedReqNoValid = true;
                    }
                }
                else if(renewedRequestNo != '' && isPartialRenewed) {
                    if( renewedRequest == null || (renewedRequest != null && (renewedRequest.Request_status__c != 'In Effect' || renewedRequest.Client_Address__c != parentrequest.Client_Address__c || renewedRequest.Id == parentrequest.Renewed_As__c))) {
                        isRenewedReqNoValid = false;
                    } else {
                        isRenewedReqNoValid = true;
                    }
                }

                if(!isRenewedReqNoValid && !isPartialRenewed) {
                    return 'Invalid Renewed Request';
                }
                else if(!isRenewedReqNoValid && isPartialRenewed) {
                    return 'Please enter a valid In Effect TPA number that covers the ‘excluded offering(s)’ referenced within the body of the notification form. If you do not know the valid TPA #, please reach back to your Client Contact.';
                } else {
                    if(parentrequest != null) {
                        parentrequest.Is_TPA_Send_DDN_Button_Enabled__c = false;
                        parentrequest.DDN_Confirmation_Date__c = System.now();
                        update parentrequest;
                    }
                    insert venAckObj;
                    if(parentrequest.Renewed_As__r.Is_Partially_Renewed__c && venAckObj.ActionTaken__c.indexOf('The Above Referenced Excluded Offerings') == -1) {
                        TGRH_VendorOfferingReturnAck.sendClientNotificationForNotSharingExcludedOfferings(parentrequest); 
                    }
                    if( parentrequest.AMA_Agreement_Details__r.size() > 0 
                        && parentrequest.AMA_Agreement_Details__r[0].Is_AMA_License_Required__c) {
                        generateDocument(parentrequest.id, parentrequest.AMA_Agreement_Details__r[0].id, parentrequest.Agreement_Name__c);   
                    }   
                    return ('success~'+'VFP_TPA_Page_Status?type=venOfferingReturnSubSuccess&lang='+venodrLanguage); //Modified by Ajinkya under ER-3221
                }
            }
        }
        return 'error';
    }
    
    @Future(callout=true)
    global static void generateDocument(Id recId, Id amaObjId, string agrName)
    {
        tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(recId);
            
            if(tpaRequestToEdit.AMA_Agreement_Details__r != null && tpaRequestToEdit.AMA_Agreement_Details__r.size() > 0) {
                amaUsesSelected = tpaRequestToEdit.AMA_Agreement_Details__r[0].AMA_Services_Provided__c.split(';'); 
            }
         try {
            PageReference pdf = Page.VFP_TPA_AMA_VendorOffReturnAck_Export;
            
            pdf.getParameters().put('id',recId);
            
            Blob body;
            if(Test.IsRunningTest()) {
                body = Blob.valueOf('UNIT.TEST');
            }
            else {
                body = pdf.getContent();
            }
            
            String attchDocName = 'AMA Data Destruction Acknowledgment.pdf';
            List<Attachment> attachmentList = [SELECT Id, Name, Body, ContentType  FROM Attachment WHERE Parentid =: tpaRequestToEdit.AMA_Agreement_Details__r[0].id and Name =:attchDocName];
            if(!attachmentList.isEmpty()) {
                delete attachmentList;
            }
            
            Attachment attach = new Attachment();
            attach.Body = body;
            attach.Name = attchDocName;
            attach.IsPrivate = false;
            attach.ParentId = amaObjId;
            insert attach;
            
            sendamaDDNAcknowledgmentNoticeToDBL(tpaRequestToEdit); 
            
        }
        catch(Exception ex) {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_VendorOfferingReturnAck.generateDocument', recId != null ? recId : '');
            system.debug(ex.getMessage());
        }
        
    }
    
    public static void sendamaDDNAcknowledgmentNoticeToDBL(TPA_request__c reqObj) { 
        
        Date todayDate;
        todayDate = Date.today(); 
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();                
        Id templateId = UTL_TPA_Multilingual.getEmailTemplateId('Email AMA DDN Acknowledgment Notice', 'English');

        // String dblContractsContactId = tpaCustomSettings.DBL_Contracts_Contact_Id__c; 
        String initials = '';
        String globalTPProcessorInitials = '';
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c)) {
            List<String> ccTo = amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c.split(';');
            mail.setToAddresses(ccTo);
        }
        
        // mail.setTargetObjectId(dblContractsContactId);
        mail.setWhatId(reqObj.AMA_Agreement_Details__r[0].id);
        
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, reqObj.AMA_Agreement_Details__r[0].id);
        mail.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
        mail.setSubject(emailNotToSend.getSubject());
        mail.setCharset('UTF-8'); 
        
        mail.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Address_For_Data_Release__c);
        mail.setSaveAsActivity(true);
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            initials = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        }
        if(reqObj.Co_Assigned_Global_TP_Processor__r.Is_Active__c ) {
            globalTPProcessorInitials = reqObj.Co_Assigned_Global_TP_Processor__r.Initials__c;
        }
        mail.setSubject(SRV_TPA_TPARequest.setEmailInitials(initials, globalTPProcessorInitials, mail.getSubject()));
        
        // if(String.isNotBlank(reqObj.Service_Provider_f__c) &&
        //    String.isNotBlank(reqObj.Client_First_Name__c) &&
        //    (reqObj.Service_Provider_f__c.startsWithIgnoreCase('Test') || reqObj.Client_First_Name__c.startsWithIgnoreCase('Test'))){
        //        mail.setTreatTargetObjectAsRecipient(false);
        //    }
        
        List<Attachment> attachments = [SELECT Id, Name, Body, ContentType, LastModifiedDate  FROM Attachment WHERE Parentid =:reqObj.AMA_Agreement_Details__r[0].id];
        
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment offshoreDoc = new Messaging.EmailFileAttachment();
        for(Attachment att : attachments) {
            
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            if(String.isNotBlank(att.Name) && att.Name.containsIgnoreCase('AMA Data Destruction Acknowledgment')) {
                
                efa.setFileName(att.Name);
                efa.setBody(att.Body);
                efa.setContentType(att.ContentType);
                emailAttachments.add(efa);
            }
        }
        
        mail.setFileAttachments(emailAttachments);
        mails.add(mail);
        
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                Messaging.sendEmail(mails);
                
            }
        } catch(Exception e) {
            System.debug('Send AMA Response to DBL failed: ' + e.getMessage());
        } 
    }
    
}
