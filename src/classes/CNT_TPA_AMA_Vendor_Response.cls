global class CNT_TPA_AMA_Vendor_Response {

    public static List<AMA_Agreement_Detail__c> amaAgreementDetailValues{get; set;}
    public static String amaAgreementID{get; set;}
    public static TPA_AMA_Picklist_Value__mdt[] picklistValueMdt;
    public static List<Agreement_Contact__c> listOfClientContacts;
    public static String inReviewByImsValue;
    public static String inReviewByImsPreValue;
    public static String inAutoAppValue;
    public static String awaitingAMAApprovalValue;
    public static String inBatchProcessValue;
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
    //public boolean TPA_Is_Show_TPA_Down_Message {get;set;}
    private static User CurrentUser = UTL_TPA_Multilingual.CurrentUser;
    public static string isQaTesting {get; set;}
    public Static Set<String> countryCodes {
        get {
            if(countryCodes == null) {
                Set<String> USACountryCode =  UTL_TPA_Multilingual.getCountryStateCodeSet('C', 'USA');
                countryCodes = USACountryCode;
                return countryCodes;
            }
            else {
                return countryCodes;
            }
        }
        set;
    }
    public static AMA_Agreement_Detail__c amaAgreementDetailObj {
        get{
            if(amaAgreementDetailObj == null){
                if(!Test.isRunningTest())
                    amaAgreementID = ApexPages.currentPage().getParameters().get('id');
                if(amaAgreementID != null)
                {
                    amaAgreementDetailValues = [select id, Current_Year__c, Next_Year__c, Current_Year_Fees__c, Next_Year_Fees__c, Contract_Type__c, Client__c, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c, Vendor_AMA_Fee_Response__c, Send_copy_of_the_invoice__c, Invoice_Contact_Email__c, Invoice_Contact__c, TPA_Request__c ,TPA_Request__r.Name, TPA_Request__r.Vendor_Billing_Mailing_Country__c, TPA_Request__r.Agreement_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Service_Provider_Address__c, TPA_Request__r.Service_Provider_Address__r.Name, Tax_Identification_Number__c, TPA_Request__r.Service_Provider_Address__r.AMA_SAP_Code__c, TPA_Request__r.Client_Address__c, TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Authorized_Signer_Email__c ,TPA_Request__r.ClientContact__c, TPA_Request__r.Is_Contract_Generated__c, TPA_Request__r.Request_Status__c , TPA_Request__r.TPA_Request_Temporary_Status__c,  TPA_Request__r.Previous_Status_If_In_Batch_Process__c from AMA_Agreement_Detail__c where id = :amaAgreementID];

                    if(amaAgreementDetailValues!= null && !amaAgreementDetailValues.isEmpty()) {
                        amaAgreementDetailObj = amaAgreementDetailValues.get(0);
                    }
                }
            }
            return amaAgreementDetailObj;
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

    public String amaAgreementDetailAsString {
      get{
            return JSON.serialize(amaAgreementDetailObj);
        }
        set;
    }

    public CNT_TPA_AMA_Vendor_Response() {
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

    }

    // added by supriya Johari under CR-11650 starts
    @remoteAction
    public static String tpUsReqResendAMAFeeNoti(String amaAgreementObjID) {

        Set<String> agrDetFieldsSet = new Set<String> {'id', 'Current_Year__c', 'Next_Year__c', 'Current_Year_Fees__c', 'Next_Year_Fees__c', 'Contract_Type__c', 'Client__c', 'Agreement_Start_Date__c', 'Initial_Termination_Date__c', 'Agreement_End_Date__c', 'AMA_TypeOfPrescriberLevelData__c', 'AMA_Services_Provided__c', 'Vendor_Contact_Name__c', 'Vendor_Legal_Name__c', 'AMA_Howlong_SP_has_Data_Access__c', 'Vendor_AMA_Fee_Response__c', 'Send_copy_of_the_invoice__c', 'Invoice_Contact_Email__c', 'Invoice_Contact__c', 'TPA_Request__c', 'TPA_Request__r.Name', 'TPA_Request__r.Agreement_Name__c', 'TPA_Request__r.Vendor_Contact_Name_f__c', 'TPA_Request__r.Assigned_TP_Processor__c', 'TPA_Request__r.TPA_Assigned_TP_Processor__c', 'TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c', 'TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c', 'TPA_Request__r.Vendor_Contact_Last_Name__c', 'TPA_Request__r.Vendor_Company_Name__c', 'TPA_Request__r.Client_Address__c', 'TPA_Request__r.TP_Processor_Email__c', 'TPA_Request__r.Vendor_Contact_e_mail__c', 'TPA_Request__r.Vendor_Contact_Email_Client__c', 'TPA_Request__r.Authorized_Signer_Email__c','TPA_Request__r.ClientContact__c', 'TPA_Request__r.Is_Contract_Generated__c', 'TPA_Request__r.Request_Status__c', 'TPA_Request__r.TPA_Request_Temporary_Status__c', 'TPA_Request__r.Previous_Status_If_In_Batch_Process__c'};  

        AMA_Agreement_Detail__c amaAgreementDetailObj = new AMA_Agreement_Detail__c();
        amaAgreementDetailValues = new List<AMA_Agreement_Detail__c>();
        amaAgreementDetailValues = SLT_AMAAgreementDetail.instance.getAMAAgreementDetailsById(amaAgreementObjID, agrDetFieldsSet, 1);

        if(amaAgreementDetailValues!= null && !amaAgreementDetailValues.isEmpty()) {
            amaAgreementDetailObj = amaAgreementDetailValues.get(0);
        }

        try {
            if(amaAgreementDetailObj != null) {
                amaAgreementDetailObj.TPA_Request__r.Request_Status__c = UTL_TPA.PENDING_VENDOR_AMA_FEE_ACKNOWLEDGEMENT;
                amaAgreementDetailObj.Vendor_AMA_Fee_Response__c = '';
                update amaAgreementDetailObj.TPA_Request__r;
                update amaAgreementDetailObj;

                List<String> toAddress = new List<String>();
                if(String.isNotBlank(amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c) && String.isNotBlank(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c) && !amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c.equalsIgnoreCase(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c)) {
                    toAddress.add(amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c);
                    toAddress.add(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c);
                }
                else {
                    if(String.isNotBlank(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c))
                        toAddress.add(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c);
                    else
                        toAddress.add(amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c);
                }
                return addAMAFeeInvoicedBeforeSignConfirmationMail(amaAgreementDetailObj, toAddress);
            }
        } catch (Exception e) {
            system.debug(e.getMessage());           
            return 'error';
        }
        return 'error';
    }

    @remoteAction
    public static String saveVendorFeeResponse(String amaAgreementObj) {

        String previousStatus = '';
        AMA_Agreement_Detail__c amaAgreementUpdatedObj;
        picklistValueMdt = [SELECT MasterLabel, Objcet_Name__c, Field_Name__c, Value__c FROM TPA_AMA_Picklist_Value__mdt];

        for (TPA_AMA_Picklist_Value__mdt pckListvalue:picklistValueMdt) {

            if(pckListvalue.MasterLabel == 'Tpa Req In Auto Approval') {
                inAutoAppValue = pckListvalue.Value__c;
            } else if(pckListvalue.MasterLabel == 'Tpa Req In Review By IQVIA') {
                inReviewByImsValue = pckListvalue.Value__c;
            } else if(pckListvalue.MasterLabel == 'Tpa Req In Review By IMS') {
                inReviewByImsPreValue = pckListvalue.Value__c;
            } else if(pckListvalue.MasterLabel == 'Tpa Req Awaiting AMA Approval') {
                awaitingAMAApprovalValue = pckListvalue.Value__c;
            } else if(pckListvalue.MasterLabel == 'In Batch Process') {
                inBatchProcessValue = pckListvalue.Value__c;
            }
        }

        amaAgreementUpdatedObj = (AMA_Agreement_Detail__c)JSON.deserialize(amaAgreementObj, AMA_Agreement_Detail__c.class);
        Set<String> agrDetFieldsSet = new Set<String> {'id', 'Current_Year__c', 'Next_Year__c', 'Current_Year_Fees__c', 'Next_Year_Fees__c', 'Contract_Type__c', 'Client__c','Agreement_Start_Date__c', 'Initial_Termination_Date__c', 'Agreement_End_Date__c', 'AMA_TypeOfPrescriberLevelData__c', 'AMA_Services_Provided__c' , 'Vendor_Contact_Name__c', 'Vendor_Legal_Name__c', 'AMA_Howlong_SP_has_Data_Access__c', 'Vendor_AMA_Fee_Response__c', 'Send_copy_of_the_invoice__c', 'Invoice_Contact_Email__c', 'Invoice_Contact__c', 'TPA_Request__c', 'TPA_Request__r.Id', 'TPA_Request__r.Name', 'TPA_Request__r.Agreement_Name__c', 'TPA_Request__r.Vendor_Contact_Name_f__c', 'TPA_Request__r.Vendor_Contact_Last_Name__c', 'TPA_Request__r.Vendor_Company_Name__c', 'TPA_Request__r.Client_Address__c', 'TPA_Request__r.TP_Processor_Email__c', 'TPA_Request__r.Vendor_Contact_e_mail__c', 'TPA_Request__r.Vendor_Contact_Email_Client__c', 'TPA_Request__r.Authorized_Signer_Email__c','TPA_Request__r.ClientContact__c','TPA_Request__r.ClientContact__r.Email','TPA_Request__r.Is_Contract_Generated__c', 'TPA_Request__r.Request_Status__c', 'TPA_Request__r.TPA_Request_Temporary_Status__c', 'TPA_Request__r.Previous_Status_If_In_Batch_Process__c', 'TPA_Request__r.Client_Address__r.TPAOtherEmailIds__c'};

        AMA_Agreement_Detail__c amaAgreementDetailObj = new AMA_Agreement_Detail__c();
         /*amaAgreementDetailValues = new List<AMA_Agreement_Detail__c>();
        amaAgreementDetailValues = SLT_AMAAgreementDetail.instance.getAMAAgreementDetailsById(amaAgreementUpdatedObj.id, agrDetFieldsSet, 1);

        if(amaAgreementDetailValues!= null && !amaAgreementDetailValues.isEmpty()) {
            amaAgreementDetailObj = amaAgreementDetailValues.get(0);
        }*/
        
        amaAgreementDetailObj =  [Select id,TPA_Request__r.Pending_Acknowledgements__c,Current_Year__c, Next_Year__c, Current_Year_Fees__c, Next_Year_Fees__c, Contract_Type__c, Client__c,Agreement_Start_Date__c, Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c, Vendor_Legal_Name__c, TPA_Request__r.Vendor_Billing_Mailing_Country__c, TPA_Request__r.Service_Provider_Address__c, TPA_Request__r.Service_Provider_Address__r.Name, Tax_Identification_Number__c, TPA_Request__r.Service_Provider_Address__r.AMA_SAP_Code__c, AMA_Howlong_SP_has_Data_Access__c, Vendor_AMA_Fee_Response__c, Send_copy_of_the_invoice__c, Invoice_Contact_Email__c, Invoice_Contact__c, TPA_Request__c, TPA_Request__r.Id, TPA_Request__r.Name, TPA_Request__r.Agreement_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Address__c, TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Authorized_Signer_Email__c,TPA_Request__r.ClientContact__c,TPA_Request__r.ClientContact__r.Email,TPA_Request__r.Is_Contract_Generated__c, TPA_Request__r.Request_Status__c, TPA_Request__r.TPA_Request_Temporary_Status__c, TPA_Request__r.Previous_Status_If_In_Batch_Process__c, TPA_Request__r.Client_Address__r.TPAOtherEmailIds__c FROM AMA_Agreement_Detail__c Where id = :amaAgreementUpdatedObj.id limit 1]; 


        try {
            if(amaAgreementDetailObj != null) {
                if(String.isBlank(amaAgreementDetailObj.Vendor_AMA_Fee_Response__c) && String.isNotBlank(amaAgreementUpdatedObj.Vendor_AMA_Fee_Response__c) && (amaAgreementUpdatedObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('acknowledged') || amaAgreementUpdatedObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('declined') ) && amaAgreementDetailObj.TPA_Request__r.Request_Status__c == UTL_TPA.PENDING_VENDOR_AMA_FEE_ACKNOWLEDGEMENT &&  amaAgreementDetailObj.TPA_Request__r.Request_Status__c == UTL_TPA.PENDING_VENDOR_AMA_FEE_ACKNOWLEDGEMENT ) {
                    if(amaAgreementDetailObj.TPA_Request__r.Pending_Acknowledgements__c != null && amaAgreementDetailObj.TPA_Request__r.Pending_Acknowledgements__c != ''){
                        if(amaAgreementDetailObj.TPA_Request__r.Pending_Acknowledgements__c.contains('; '+amaAgreementDetailObj.TPA_Request__r.name)){
                            amaAgreementDetailObj.TPA_Request__r.Pending_Acknowledgements__c = amaAgreementDetailObj.TPA_Request__r.Pending_Acknowledgements__c.remove(';'+'AMA Fee Acknowledgement');
                        }
                        else if(amaAgreementDetailObj.TPA_Request__r.Pending_Acknowledgements__c.contains(amaAgreementDetailObj.TPA_Request__r.name +'; ')){
                            amaAgreementDetailObj.TPA_Request__r.Pending_Acknowledgements__c = amaAgreementDetailObj.TPA_Request__r.Pending_Acknowledgements__c.remove('AMA Fee Acknowledgement' +';');
                        }
                        else {
                            amaAgreementDetailObj.TPA_Request__r.Pending_Acknowledgements__c = amaAgreementDetailObj.TPA_Request__r.Pending_Acknowledgements__c.remove('AMA Fee Acknowledgement');
                        }
                    }
                    if(amaAgreementDetailObj.TPA_Request__r.TPA_Request_Temporary_Status__c.equalsIgnoreCase(inBatchProcessValue)) {
                        previousStatus = amaAgreementDetailObj.TPA_Request__r.Previous_Status_If_In_Batch_Process__c;
                    }
                    else {
                        previousStatus = amaAgreementDetailObj.TPA_Request__r.TPA_Request_Temporary_Status__c;
                    }
                    if(amaAgreementDetailObj.TPA_Request__r.Is_Contract_Generated__c == false && (previousStatus.equalsIgnoreCase(inReviewByImsValue)|| previousStatus.equalsIgnoreCase(inReviewByImsPreValue) || previousStatus.equalsIgnoreCase(inAutoAppValue) || previousStatus.equalsIgnoreCase(awaitingAMAApprovalValue)) ) { // modified  by supriya Johari under Issue-11573
                        if(previousStatus.equalsIgnoreCase(inReviewByImsValue) && amaAgreementUpdatedObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('acknowledged')) {
                            TGRH_TPARequest.runAllCompletedBlock = true;
                        }
                        if(previousStatus.equalsIgnoreCase(inAutoAppValue) && amaAgreementUpdatedObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('acknowledged')) {
                            amaAgreementDetailObj.TPA_Request__r.Is_Contract_Generated__c = true;
                        }
                        if(amaAgreementUpdatedObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('declined')) {
                            amaAgreementDetailObj.TPA_Request__r.Request_Status__c = UTL_TPA.PENDING_VENDOR_DECLINED_AMA_FEES;
                            amaAgreementDetailObj.TPA_Request__r.Is_Contract_Generated__c = false;
                            amaAgreementDetailObj.Send_copy_of_the_invoice__c = '';
                            amaAgreementDetailObj.Invoice_Contact__c = '';
                            amaAgreementDetailObj.Invoice_Contact_Email__c = '';
                        }
                        else {
                            amaAgreementDetailObj.TPA_Request__r.Request_Status__c  = previousStatus;
                            amaAgreementDetailObj.Tax_Identification_Number__c = amaAgreementUpdatedObj.Tax_Identification_Number__c;
                            amaAgreementDetailObj.Send_copy_of_the_invoice__c = amaAgreementUpdatedObj.Send_copy_of_the_invoice__c;
                            amaAgreementDetailObj.Invoice_Contact__c = amaAgreementUpdatedObj.Invoice_Contact__c;
                            amaAgreementDetailObj.Invoice_Contact_Email__c = amaAgreementUpdatedObj.Invoice_Contact_Email__c;
                        }
                        amaAgreementDetailObj.Vendor_AMA_Fee_Response__c = amaAgreementUpdatedObj.Vendor_AMA_Fee_Response__c;
                        update amaAgreementDetailObj.TPA_Request__r;

                        update amaAgreementDetailObj;

                        if(amaAgreementDetailObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('declined')) {
                            List<String> ccAddress = new List<String>();
                            if(String.isNotBlank(amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c ) && String.isNotBlank(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c) && !amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c.equalsIgnoreCase(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c)) {
                                ccAddress.add(amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c);
                                ccAddress.add(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c);
                            }
                            else {
                                if(String.isNotBlank(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c)) {
                                    ccAddress.add(amaAgreementDetailObj.TPA_Request__r.Vendor_Contact_e_mail__c);
                                } else {
                                    ccAddress.add(amaAgreementDetailObj.TPA_Request__r.Authorized_Signer_Email__c);
                                }
                            }
                            listOfClientContacts = [select id, Name, Email__c , TPA_Request__c from Agreement_Contact__c where TPA_Request__c = :amaAgreementDetailObj.TPA_Request__c];
                            for(Agreement_Contact__c agrContactObj: listOfClientContacts) {
                                ccAddress.add(agrContactObj.Email__c );
                            }
                            ccAddress = UTL_TPA_Multilingual.ccList(amaAgreementDetailObj.TPA_Request__r.Client_Address__r.TPAOtherEmailIds__c, ccAddress);//Added by Rajendra under ER-11762
                            SendVendorDeclinedNotiToClient(amaAgreementDetailObj,ccAddress);
                        }
                        return SendFeeAcknowledgeNotification(amaAgreementDetailObj);
                    }
                } else if(String.isNotBlank(amaAgreementDetailObj.Vendor_AMA_Fee_Response__c) && (amaAgreementDetailObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('acknowledged') || amaAgreementDetailObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('declined') ) && amaAgreementDetailObj.TPA_Request__r.Request_Status__c != UTL_TPA.PENDING_VENDOR_AMA_FEE_ACKNOWLEDGEMENT &&  amaAgreementDetailObj.TPA_Request__r.Request_Status__c != UTL_TPA.PENDING_VENDOR_AMA_FEE_ACKNOWLEDGEMENT) {
                    return 'AlreadySubmitted';
                }
            }
        } catch (Exception e) {
            system.debug(e.getMessage());            
            return 'error';
        }

        return 'error';
    }

    public static string SendFeeAcknowledgeNotification(AMA_Agreement_Detail__c amaAgrObj)
    {
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        String templateId = amaSetting.get(0).Fee_Confirm_Ack_TPUS_Before_Sign_Temp__c  ;

        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        TPA_Request__c tpaRequest = [Select id, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: amaAgrObj.TPA_Request__c];

        List<String> ccTo = new List<String>();
        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c)){
            ccTo = amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c.split(';');
        }
        
        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/

        try {
            SRV_TPA_TPARequest.sendEmailThroughWorkflow(new List<String>{amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c}, ccTo, 'SendEmail', templateId, amaAgrObj.id, null, '', false, '', TRUE, TRUE, tpaRequest);
            //SRV_TPA_TPARequest.addTPProcessorInitials = false;
        } catch(Exception e) {
            System.debug('AMA Vendor Fee Acknowledgment Notification sending to TP-US after completion : ' + e.getMessage());
            return 'error';
        }
        return 'success';
    }

    public static string SendVendorDeclinedNotiToClient(AMA_Agreement_Detail__c amaAgrObj, List<String> ccAddress)
    {
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        String templateId = amaSetting.get(0).FeesInvoice_vendorDeclined_Notify_Client__c  ;

        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        TPA_Request__c tpaRequest = [Select id, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: amaAgrObj.TPA_Request__c];

        List<String> toAddress = new List<String>();
        toAddress.add(amaAgrObj.TPA_Request__r.ClientContact__r.Email);

        if(amaAgrObj.TPA_Request__r.Client_TPA_Representative_Email__c != null && amaAgrObj.TPA_Request__r.Client_TPA_Representative_Email__c != ''){
            toAddress.add(amaAgrObj.TPA_Request__r.Client_TPA_Representative_Email__c);
        }
        if(amaAgrObj.TPA_Request__r.Owner.Type != null && amaAgrObj.TPA_Request__r.Owner.Type == 'Queue' && amaAgrObj.TPA_Request__r.Owner.Email != null){
            toAddress.add(amaAgrObj.TPA_Request__r.Owner.Email);
        }

        if(String.isNotBlank(tpaCustomSettings.TP_US_Mail_Id__c))
            ccAddress.add(tpaCustomSettings.TP_US_Mail_Id__c);

        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c)){
            List<String> addCCTo = amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c.split(';');
            ccAddress.addAll(addCCTo);
        }
        List<TPA_Contact__c> tpaContactList = SRV_TPA_TPARequest.getContactsForRequest(amaAgrObj.TPA_Request__r.Id);
        if(tpaContactList != null && tpaContactList.size() > 0){
            for(TPA_Contact__c tpaContact : tpaContactList){
                if(tpaContact.Type__c == 'Additional Client Contact'){
                    ccAddress.add(tpaContact.Email__c);
                }
            }
        }

        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/

        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccAddress, 'SendAMAFeeDeclinedEmail', templateId, amaAgrObj.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
            }
        } catch(Exception e) {
            System.debug('AMA Vendor Fee Declined Notification sending to Client contact after completion : ' + e.getMessage());
            return 'error';
        }
        return 'success';
    }

    public static string addAMAFeeInvoicedBeforeSignConfirmationMail(AMA_Agreement_Detail__c  amaAgreement, List<String> toAddress)
    {
        system.debug('In method where sending mail to vendor for invoiced confirmation before sending agreements for signatures' + amaAgreement);

        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();

        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        TPA_Request__c tpaRequest = [Select id, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: amaAgreement.TPA_Request__c];
        List<String> ccTo = new List<String>();

        if(String.isNotBlank(tpaCustomSettings.TP_US_Mail_Id__c)){
            ccTo = tpaCustomSettings.TP_US_Mail_Id__c.split(',');
            if(String.isNotBlank(amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c)){
                List<String> addCCTo = amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c.split(';');
                ccTo.addAll(addCCTo);
            }
        }
        
        if(String.isNotBlank(tpaCustomSettings.TPA_BCC_Emails__c)) {
           List<String> bccTo = new List<String>();
           bccTo.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(';'));
        }

        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            SRV_TPA_TPARequest.assignedTPProcessorName = amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/

        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', amaSetting.get(0).Fees_Invoice_Confirm_BeforeSign_Template__c, amaAgreement.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
            }
        } catch(Exception e) {
            System.debug('send ama fee notification to vendor failed : ' + e.getMessage());
            return 'error';
        }
        return 'success';
    }

}
