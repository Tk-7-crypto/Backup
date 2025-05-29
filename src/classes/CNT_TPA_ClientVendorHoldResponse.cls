global class CNT_TPA_ClientVendorHoldResponse {

    /************
     Properties
    *************/
    public TPA_Request__c tpaRequest {get; set;} 
    //public static TPA_Request__c tpaRequestToEdit {get; set;}
    public Map<String, String>  purposeIdDataAssetMap {get; set;}
    public string isAuthorisedSigner {get; set;}

    public string tpaRequestId {get; set;}

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
    public static string clientVendorName {get; set;}


    /************
     Constructor
    *************/
    public CNT_TPA_ClientVendorHoldResponse() {
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
        	tpaRequestId = ApexPages.currentPage().getParameters().get('id');
        	tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(tpaRequestId);
            clientVendorName = '';
            Map<String,Account_Compliance__c> accCompRecords = UTL_TPA.getTPAClientVendorComplianceDetails(tpaRequestToEdit.Client_Address__c, tpaRequestToEdit.Service_Provider_Address__c); 
            if(accCompRecords != null) {
                Account_Compliance__c accClientComp = accCompRecords.get('CC-'+tpaRequestToEdit.Client_Address__c);
                Account_Compliance__c accVendorComp = accCompRecords.get('VC-'+tpaRequestToEdit.Service_Provider_Address__c);
                if(accClientComp != null && accClientComp.Client_TPA_Compliance_Hold__c){
                    clientVendorName = tpaRequestToEdit.Client_Address__r.Name;
                }
                else if(accVendorComp != null && accVendorComp.Vendor_TPA_Compliance_Hold__c){
                    clientVendorName = tpaRequestToEdit.Service_Provider_Address__r.Name;
                }
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
    
    public static String note2 {
        get{
            String noteTemp = System.Label.TPA_Company_name_associated_with_flag_is_out_of_compliance_and_must_remediate;
            return noteTemp.replace('[Company name associated with flag]', clientVendorName);
        }
        set;
    }
    
    public static String note3 {
        get{
            String noteTemp = System.Label.TPA_must_be_denied_Please_provide_Company_name_associated_with_flag_with_the;
            return noteTemp.replace('[Company name associated with flag]', clientVendorName);
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
    
    public static TPA_Agreement_Additional_Field__c additionalAgrField {
        get{
            if(additionalAgrField == null){
                if(tpaRequestToEdit != null) {
                    if(tpaRequestToEdit.TPA_Agreement_Additional_Fields__r != null && tpaRequestToEdit.TPA_Agreement_Additional_Fields__r.size() > 0) {
                        additionalAgrField = tpaRequestToEdit.TPA_Agreement_Additional_Fields__r[0]; 
                    }
                }
            }
            return additionalAgrField;
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
        String clientCompanyName;
        String vendorCompanyName;
        String clientOnComplianceHoldReason;
        String vendorOnComplianceHoldReason;
        Boolean isClientOnComplianceHold = false;
        Boolean isVendorOnComplianceHold = false;
        if(tpaRequestId != null && !String.IsBlank(tpaRequestId))
        {
            // gets the vendor language selected at the time of request submit to be used in this page
            language = UTL_TPA_Multilingual.getLanguageForExistingRequests(tpaRequestId, 'v');

            tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(tpaRequestId);
            
            Map<String,Account_Compliance__c> accCompRecords = UTL_TPA.getTPAClientVendorComplianceDetails(tpaRequestToEdit.Client_Address__c, tpaRequestToEdit.Service_Provider_Address__c); 
            if(accCompRecords != null){
                Account_Compliance__c accClientComp = accCompRecords.get('CC-'+tpaRequestToEdit.Client_Address__c);
                if(accClientComp != null && accClientComp.Client_TPA_Compliance_Hold__c){
                    isClientOnComplianceHold = true;
                    clientCompanyName = tpaRequestToEdit.Client_Address__r.Name;
                    clientOnComplianceHoldReason = accClientComp.Client_TPA_Compliance_Hold_Reason__c;
                }
                Account_Compliance__c accVendorComp = accCompRecords.get('VC-'+tpaRequestToEdit.Service_Provider_Address__c);
                if(accVendorComp != null && accVendorComp.Vendor_TPA_Compliance_Hold__c){
                    isVendorOnComplianceHold = true;
                    vendorCompanyName = tpaRequestToEdit.Service_Provider_Address__r.Name;
                    vendorOnComplianceHoldReason = accVendorComp.Vendor_TPA_Compliance_Hold_Reason__c;
                }
            }
            
            TPA_Agreement_Additional_Field__c tpaRenewedReqAgrAddFieldsRec;
            if(tpaRequestToEdit != null){
                tpaRenewedReqAgrAddFieldsRec = [Select id, TPA_Compliance_Hold_Acknowledged__c FROM TPA_Agreement_Additional_Field__c Where Related_TPA_Request__c = :tpaRequestToEdit.Id limit 1];
                if(!isClientOnComplianceHold && !isVendorOnComplianceHold){
                    return new PageReference('/VFP_TPA_Page_Status?type=clientvendorholdreleased&lang='+language);
                }
                else if(tpaRenewedReqAgrAddFieldsRec != null && tpaRenewedReqAgrAddFieldsRec.TPA_Compliance_Hold_Acknowledged__c) {
                    return new PageReference('/VFP_TPA_Page_Status?type=clientvendorholdalreadysubmitted&lang='+language);
                }
            }
            
            if(tpaRequestToEdit != null)
                isAuthorisedSigner = tpaRequestToEdit.TPA_Authorised_Signer__c;
            
            
        system.debug('tpaRequestToEdit.Request_status__c'+tpaRequestToEdit.Request_status__c);
            
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

    @remoteAction
    global static string saveRequest(string vendorDesConfirmatioSubmitObjDetail)
    {
        system.debug('vendorDesConfirmatioSubmitObjDetail'+vendorDesConfirmatioSubmitObjDetail);
        ResponseWrapper newWrapper = (ResponseWrapper)JSON.deserialize(vendorDesConfirmatioSubmitObjDetail, ResponseWrapper.class);
        Boolean isPartialRenewed = false;
        if(newWrapper != null){
            string venodrLanguage = UTL_TPA_Multilingual.getLanguageForExistingRequests(newWrapper.requestId, 'v');
            string renewedRequestNo = '';
            string query = 'select Id, Client_Email__c,Client_Address__r.TPAOtherEmailIds__c,Is_VSN_Acknowlege_By_Client__c, Client_TPA_Representative_Email__c, Owner.Email, Owner.Type, ClientContact__r.email,Manual_Trigger_Reasons__c,Service_Provider_Address__c,Service_Provider_Address__r.Parent_Vendor_Name__c,isClientOnComplianceHold__c,isVendorOnComplianceHold__c, vendor_language__c,  TP_Processor_Email__c, Is_Partially_Renewed__c, Renewed_As__r.Is_Partially_Renewed__c, Request_status__c, Renewed_As__c, Client_Address__c,Parent_Request__c, Name, Agreement_Name__c, Is_TPA_Send_DDN_Button_Enabled__c,TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__c,Co_Assigned_Global_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__r.Initials__c, (select id,Is_AMA_License_Required__c,AMA_Manual_Trigger_Reasons__c  from AMA_Agreement_Details__r), (SELECT Id, TPA_Compliance_Response_to_Hold__c, Early_Contract_Expiry_Date__c FROM TPA_Agreement_Additional_Fields__r LIMIT 1), (Select Email__c, Type__c, Id From TPA_Request_Contacts__r) from TPA_Request__c where (Id =\'' + newWrapper.requestId +'\' ';
            query += ' )';
            List<TPA_Request__c> tparequestList  = Database.query(query);
            List<TPA_Request__c> updateRequestList = new List<TPA_Request__c>();
            List<TPA_Agreement_Additional_Field__c> agrAddFieldList = new List<TPA_Agreement_Additional_Field__c>();
            TPA_Agreement_Additional_Field__c agrAddField;
            TPA_Request__c tpaRequestUpdate;
            if(tparequestList != null && tparequestList.size() > 0) {
                for(TPA_Request__c tparequest : tparequestList) {
                    tpaRequestUpdate = tparequest;
                    agrAddField = tparequest.TPA_Agreement_Additional_Fields__r[0];
                }
            }
            
            
            system.debug('agrAddField'+agrAddField);
            if(tpaRequestUpdate != null) {
                if(newWrapper.ddnAck1) {
                    if(tpaRequestUpdate.isClientOnComplianceHold__c) {
                        tpaRequestUpdate.isClientOnComplianceHold__c = false;
                    }
                    if(tpaRequestUpdate.isVendorOnComplianceHold__c) {
                        tpaRequestUpdate.isVendorOnComplianceHold__c = false;
                    }
                    tpaRequestUpdate = SRV_TPA_TPARequest.getRequestStatus(tpaRequestUpdate);
                    if(agrAddField != null) {
                        agrAddField.TPA_Compliance_Hold_Action_Taken__c = 'TPA can be released';
                    }
                    updateRequestList.add(tpaRequestUpdate);
                }
                if(newWrapper.ddnAck2) {
                    if(agrAddField != null) {
                        agrAddField.TPA_Compliance_Hold_Action_Taken__c = 'Company is out of compliance';
                        agrAddField.TPA_Compliance_Response_to_Hold__c = newWrapper.ddnAck2Response;
                    }
                }
                if(newWrapper.ddnAck3) {
                    if(agrAddField != null) {
                        agrAddField.TPA_Compliance_Hold_Action_Taken__c = 'TPA must be denied';
                        agrAddField.TPA_Compliance_Response_to_Hold__c = newWrapper.ddnAck3Response;
                    }
                }
                agrAddField.TPA_Compliance_Hold_Acknowledged__c = true;
                agrAddField.Date_of_TPA_Compliance_Response_to_Hold__c = System.now();
                agrAddFieldList.add(agrAddField);
                
            }
            if(updateRequestList != null && updateRequestList.size()>0) {
                update updateRequestList;
            }
            if(agrAddFieldList != null && agrAddFieldList.size()>0) {
                update agrAddFieldList;
            }
            generateDocument(tpaRequestUpdate.id);
            sendComplianceHoldResponseToLegal(tpaRequestUpdate);
            //sendComplianceHoldResponseToTPProcessor(tpaRequestUpdate);
            return ('success~'+'VFP_TPA_Page_Status?type=venOfferingReturnSubSuccess&lang='+venodrLanguage);
        }
        return 'error';
    }
    
    @Future(callout=true)
    global static void generateDocument(Id recId)
    {
        tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(recId);
         try {
            PageReference pdf = Page.VFP_TPA_ClientVendorHoldResponse_Export;
            
            pdf.getParameters().put('id',recId);
            
            Blob body;
            if(Test.IsRunningTest()) {
                body = Blob.valueOf('UNIT.TEST');
            }
            else {
                body = pdf.getContent();
            }
            
            String attchDocName = 'TPA Client/Vendor Hold Compliance Acknowledgment.pdf';
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
            
            //sendamaDDNAcknowledgmentNoticeToDBL(tpaRequestToEdit); 
            
        }
        catch(Exception ex) {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_ClientVendorHoldResponse.generateDocument:::Document Generation Failed',tpaRequestToEdit.id != null ? tpaRequestToEdit.id : '');
        }
        
    }
    
    public class ResponseWrapper
    {
        public Boolean ddnAck1 {get;set;}
        public Boolean ddnAck2 {get;set;}
        public Boolean ddnAck3 {get;set;}
        public String requestId {get;set;}
        public String ddnAck2Response {get;set;}
        public String ddnAck3Response {get;set;}
    }

    public static void sendComplianceHoldResponseToLegal(TPA_Request__c reqObj) {
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        // String emailBody;
        // String subjText;
        if(tpaCustomSettings.TPA_Compliance_Hold_Emails__c != null) {
            toAddress.add(tpaCustomSettings.TPA_Compliance_Hold_Emails__c);
        }
        if(reqObj.TP_Processor_Email__c != null) {
            ccAddress.add(reqObj.TP_Processor_Email__c);
        }
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Compliance Hold Res Legal' + 'English').Translated_Template_Id__c;
        // Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        // if(templateID != '' && templateID != null) {  
        //     try {
        //         system.debug('templateID'+templateID);
        //         emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
        //     } catch(Exception exp) {
        //         System.debug(templateID + ' Email Failed: ' + exp.getMessage());
        //     }
        //     emailBody = emailNotToSend.getHTMLBody();
        //     subjText = emailNotToSend.getSubject();
        // }

        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;        
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccAddress, 'SendComplianceHoldEmail', templateID, reqObj.Id, null, null, FALSE, null, TRUE, TRUE, reqObj);
        //SRV_TPA_TPARequest.addTPProcessorInitials = false;
    }

    /*public static void sendComplianceHoldResponseToTPProcessor(TPA_Request__c reqObj) {
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        List<String> toAddress = new List<String>();
        String emailBody;
        String subjText;
        if(reqObj.TP_Processor_Email__c != null) {
            toAddress.add(reqObj.TP_Processor_Email__c);
        }
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Compliance Hold Res TP Proc' + 'English').Translated_Template_Id__c;
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateID != '' && templateID != null) {  
            try {
                system.debug('templateID'+templateID);
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
            } catch(Exception exp) {
                System.debug(templateID + ' Email Failed: ' + exp.getMessage());
            }
            emailBody = emailNotToSend.getHTMLBody();
            subjText = emailNotToSend.getSubject();
        }
        SRV_TPA_TPARequest.addTPProcessorInitials = true;
        SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, null, 'SendEmail', null, reqObj.Id, null, subjText, FALSE, emailBody);
        SRV_TPA_TPARequest.addTPProcessorInitials = false;
                    
    }*/
    
}
