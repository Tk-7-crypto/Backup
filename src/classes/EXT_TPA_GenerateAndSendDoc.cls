/*
Create By: Jay vardhan Singh 
*/
public without sharing class EXT_TPA_GenerateAndSendDoc { 
    
    //public properties
    public String sessionId{get;set;}
    public String serverUrl{get;set;} 
    public Id docId{get;set;}
    public string urlId{get;set;}
    public String adminUser{get;set;}
    public String adminUserPwd{get;set;}
    public string templateName = 'TPA Portal TLLA Template';
    Boolean isRunAllTpaRule{get;set;}
    
    
    
    //constructor
    public EXT_TPA_GenerateAndSendDoc(ApexPages.StandardController controller) 
    {
        System.debug('#####Method without potential vendor');
        adminUser = UTL_TPA.userNameContract;
        adminUserPwd = UTL_TPA.passwordContract;
    }
    
    //method to update the Agreement record, generate document and send to sign
    public pagereference generateAndSendForSignDoc() 
    {
        System.debug('#####Method without potential vendor');
        string submitType = Apexpages.currentPage().getParameters().get('type');
        string reqId = Apexpages.currentPage().getParameters().get('reqId');
        sessionId = UTL_TPA_Class_LoginAPI.login(adminUser,adminUserPwd);
        docId=null;
        isRunAllTpaRule = True;
        
        if(Apexpages.currentPage().getParameters().get('isRunAllTpaRule') != NULL && Apexpages.currentPage().getParameters().get('isRunAllTpaRule') != '')
            isRunAllTpaRule = Boolean.valueOf(Apexpages.currentPage().getParameters().get('isRunAllTpaRule'));
        
        if(reqId != null && reqId.trim().length() > 0 && submitType == 'vpsubmit') {
            return generateAndSendForSignDocPotentialVendorCase(reqId.trim());
        }
        
        List<TPA_Request__c> lstTPARequest = [SELECT Id, Requires_Manual_Review__c, OwnerId, Owner.email ,Name, Owner.Name  FROM TPA_Request__c WHERE id=:reqId LIMIT 1];  
        
        TPA_Request__c reqObj = lstTPARequest[0];
        String tpaRequestNo = reqObj.Name;
        system.debug('requestNo'+tpaRequestNo);
        try {
            
            TPA_Settings__c objSetting = TPA_Settings__c.getInstance();
            if(objSetting.Generate_TLLA_Automatically__c) {
                QBL_TPA_AsyncGenerateDoc asyncGenerateDocCall= new QBL_TPA_AsyncGenerateDoc();
                asyncGenerateDocCall.requestId = reqId ;
                asyncGenerateDocCall.GUID = UTL_LogFactory.GUID;
                System.enqueueJob(asyncGenerateDocCall);
            }
            
        }
        catch(Exception e) {
            system.debug(e.getMessage());
        }
        
        PageReference pageref;
        pageref = new PageReference('/VFP_TPA_Page_Status?type=vendorSubmitSuccess&reqNo='+tpaRequestNo);
        

        Profile prof = UTL_TPA.getCurrentUserProfileInfo();
        if((prof.Name.indexOf('TPA Processor Profile') != -1) || (prof.Name.indexOf('US TP Processor Profile') != -1)) {
            pageref =  new PageReference(UTL_TPA.TPA_COMMUNIYTURL +'/apex/VFP_TPA_CustomLandingPage');
        }
        return pageref;
    } 
    public pagereference generateAndSendForSignDocPotentialVendorCase(string reqId) {
        System.debug('#####Method with potential vendor');
        TPA_Request__c tpaReq = SRV_TPA_TPARequest.getRequestInfo( reqId );

        // Boolean resetDynamicOffNotiVal = true;
        
        // if(Apexpages.currentPage().getParameters().get('isRunAllTpaRule') != NULL && Apexpages.currentPage().getParameters().get('isRunAllTpaRule') != '')
        //     resetDynamicOffNotiVal = Boolean.valueOf(Apexpages.currentPage().getParameters().get('isRunAllTpaRule'));
        
        // Boolean isRunAllTpaBusinessRule = True;
        
        // if(Apexpages.currentPage().getParameters().get('isRunAllTpaRule') != NULL && Apexpages.currentPage().getParameters().get('isRunAllTpaRule') != '')
        //     isRunAllTpaBusinessRule = Boolean.valueOf(Apexpages.currentPage().getParameters().get('isRunAllTpaRule'));
        
        
        // String isClient = Apexpages.currentPage().getParameters().get('client');

        runTPABusinessRuleSubmission(reqId, UTL_LogFactory.GUID);

        
      //  runTPABusinessRuleSubmission(reqId, isClient, resetDynamicOffNotiVal, isRunAllTpaBusinessRule, UTL_LogFactory.GUID);
        
        // if(isClient != null && isClient == 'yes'){
        //     return new PageReference('/imshealthPortal/VFP_TPA_Page_Status?actionPerformed=acknowledge&reqNo='+tpaReq.Name);
        // }
        return new PageReference('/'+reqId);
    }

    @future(callout=true)
    public static void runTPABusinessRuleSubmission(String reqId, string argGUID) {

        System.debug('#####Method with potential vendor');
    
        TPA_Request__c tpaReq = SRV_TPA_TPARequest.getRequestInfo( reqId );
        system.debug('tpaReq.Client_Off_Notification_Ack_Date__c:' + tpaReq.Client_Off_Notification_Ack_Date__c);
       
        TPA_Agreement_Additional_Field__c agreementAdditionalFieldData = new TPA_Agreement_Additional_Field__c();

        // if(tpaReq.TPA_Agreement_Additional_Fields__r != null && tpaReq.TPA_Agreement_Additional_Fields__r.size() > 0 && resetDynamicOffNotiVal) {
        if(tpaReq.TPA_Agreement_Additional_Fields__r != null && tpaReq.TPA_Agreement_Additional_Fields__r.size() > 0 ) {

            agreementAdditionalFieldData.id = tpaReq.TPA_Agreement_Additional_Fields__r[0].id;
            agreementAdditionalFieldData.Vendor_Specific_Notification_Response__c = '';
            agreementAdditionalFieldData.LAAD_Question_and_Compliance_Ack_Time__c = null ;
            agreementAdditionalFieldData.Direct_To_Client_LAAD_Response_Value__c = '';
        }

        try {
            if(agreementAdditionalFieldData != null)
                upsert agreementAdditionalFieldData;
        } catch(Exception ex) {
            System.debug('**Exception while upserting Agreement Additional Field Data**'+ex.getMessage());
        }
        
        try { 
            UTL_TPA.getGlobalBrandingVendorId(tpaReq);
            Boolean isAwaitingClientConfirmationMailReq = SRV_TPA_TPARequest.isDynamicNotificationRequiredForVendor(tpaReq);
            tpaReq.is_Addendum_Attachment_Required__c = CNT_TPA_AddendumNotification.AddendumAdditionalTermsRequiredOrNot(tpaReq);
            
            AMA_Agreement_Detail__c amaAgreementDetails;
            if(tpaReq.AMA_USPrescriberData__c == 'Yes' ) {
                if(tpaReq.AMA_Agreement_Details__r != null && tpaReq.AMA_Agreement_Details__r.size() > 0) {
                    amaAgreementDetails = tpaReq.AMA_Agreement_Details__r[0];
                }
                amaAgreementDetails = CNT_TPA_RequestSubmissionForm.getAmaAgreement(tpaReq, amaAgreementDetails, 'RunTpaBusinessRule');
                if(tpaReq.AMA_Agreement_Details__r != null && tpaReq.AMA_Agreement_Details__r.size() > 0) {
                    amaAgreementDetails.id = tpaReq.AMA_Agreement_Details__r[0].id;
                } else {
                    amaAgreementDetails.TPA_Request__c = tpaReq.id;
                }
                tpaReq.Type_of_AMA_Agreement__c = null;
                tpaReq.AMA_DBL__c = null;
            } else {
                if(tpaReq.AMA_Agreement_Details__r != null && tpaReq.AMA_Agreement_Details__r.size() > 0) {
                    amaAgreementDetails = tpaReq.AMA_Agreement_Details__r[0];
                    CNT_TPA_RequestSubmissionForm.resetAmaValuesOnAmaAgreement(amaAgreementDetails);
                    SRV_TPA_AMAAgreementDetail.amaAgreementDetails = amaAgreementDetails;
                    SRV_TPA_AMAAgreementDetail.resetAllAmaAgreementDetail (); 
                }
            }
            
            try {
                if(amaAgreementDetails != null)
                    upsert amaAgreementDetails;
            } catch(Exception ex) {
                System.debug('**Exception while upserting AMA agreement**'+ex.getMessage());
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog( FALSE, 
                                                                                    FALSE, 
                                                                                    argGUID, 
                                                                                    'Exception: In Updating AMA Agreement Details. Line# - ' + ex.getLineNumber(), 
                                                                                    'TPA', 
                                                                                    'Exception', 
                                                                                    'ERROR', 
                                                                                    ':::EXT_TPA_GenerateAndSendDoc:::generateAndSendForSignDocPotentialVendorCase - ' + ex.getMessage(), 
                                                                                    (reqId != null) ? reqId : ''));
            }
            
            tpaReq.Is_Potential_Vendor_Case__c = false;
            
            system.debug('tpaReq.is_Bulk_TPA_Request__c:' + tpaReq.is_Bulk_TPA_Request__c);
            system.debug('tpaReq.Client_Off_Notification_Ack_Date__c:' + tpaReq.Client_Off_Notification_Ack_Date__c);
           
         //   update tpaReq;
            system.debug('tpaReq.is_Bulk_TPA_Request__c:' + tpaReq.is_Bulk_TPA_Request__c);
            system.debug('tpaReq.Client_Off_Notification_Ack_Date__c:' + tpaReq.Client_Off_Notification_Ack_Date__c);
           

            List<TPA_Contact__C> tpaSubContractors = [select Id from TPA_Contact__c where TPA_Request__c =: tpaReq.Id and Type__c = 'SubContractor Contact'];
            
            SRV_TPA_TPARequest.tpaRequest = tpaReq;
            SRV_TPA_TPARequest.isSubContractAdded  = (tpaSubContractors != null && tpaSubContractors.size() > 0);
            SRV_TPA_TPARequest.authorizedSignerResponse = (((tpaReq.Authorized_Signer_Email__c == null || tpaReq.Authorized_Signer_Email__c.trim().length() == 0) || (tpaReq.Authorized_Signer_Email__c == tpaReq.Vendor_e_mail__c && tpaReq.Authorized_Signer_First_Name__c == tpaReq.Vendor_First_Name__c && tpaReq.Authorized_Signer_Last_Name__c == tpaReq.Vendor_Contact_Last_Name__c && tpaReq.Authorized_Signer_Title__c == tpaReq.Vendor_Contact_Title__c))?'Yes':'No');
            SRV_TPA_TPARequest.type = tpaReq.Request_Type__c;
            SRV_TPA_TPARequest.requestNumber = tpaReq.Parent_Request__r.Name;

            if(tpaReq.is_Bulk_TPA_Request__c) {

                QBL_TPA_getManualReviewReasons getManualReviewReasonsObj = new QBL_TPA_getManualReviewReasons();
                getManualReviewReasonsObj.request = tpaReq;
                getManualReviewReasonsObj.LastAction = tpaReq.LastAction__c;
                getManualReviewReasonsObj.isSubContractAdded = (tpaSubContractors != null && tpaSubContractors.size() > 0);
               getManualReviewReasonsObj.authorizedSignerResponse = (((tpaReq.Authorized_Signer_Email__c == null || tpaReq.Authorized_Signer_Email__c.trim().length() == 0) || (tpaReq.Authorized_Signer_Email__c == tpaReq.Vendor_e_mail__c && tpaReq.Authorized_Signer_First_Name__c == tpaReq.Vendor_First_Name__c && tpaReq.Authorized_Signer_Last_Name__c == tpaReq.Vendor_Contact_Last_Name__c && tpaReq.Authorized_Signer_Title__c == tpaReq.Vendor_Contact_Title__c))?'Yes':'No');
                getManualReviewReasonsObj.type = tpaReq.Request_Type__c;
                getManualReviewReasonsObj.requestNumber = tpaReq.Parent_Request__r.Name;
                getManualReviewReasonsObj.isAwaitingClientConfirmationMailReq = isAwaitingClientConfirmationMailReq;
                getManualReviewReasonsObj.dynamicOfferingsNotificationListForVendor = SRV_TPA_TPARequest.dynamicOfferingsNotificationListForVendor;
                getManualReviewReasonsObj.isDirectToClientExeMode = SRV_TPA_TPARequest.isDirectToClientExeMode;
                getManualReviewReasonsObj.isQuintilesIMSSalesExeMode = SRV_TPA_TPARequest.isQuintilesIMSSalesExeMode;
                getManualReviewReasonsObj.isVendorChecklistChanges = false;
                getManualReviewReasonsObj.isdynamicOffNoticationReqOrNot = TRUE;
               getManualReviewReasonsObj.runType = 'RunTpaBusinessRule';
                if(!Test.isRunningTest()){
                    System.enqueueJob(getManualReviewReasonsObj);
                }
            }
            else{
               tpaReq = SRV_TPA_TPARequest.getManualReviewReasons(tpaReq);

                
                if(tpaReq.AMA_USPrescriberData__c == 'Yes' && tpaReq.Service_Provider_Address__c != null) { 
                  //  tpaReq = SRV_TPA_TPARequest.getRequestInfo( tpaReq.Id );
                    String tpaRequestJSON = JSON.serialize(tpaReq);
                    System.debug('request.Manual_Trigger_Reasons__c1 ::: '+tpaReq.Manual_Trigger_Reasons__c);
                    tpaReq = SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(tpaRequestJSON);
                }

               
               CNT_TPA_RequestSubmissionForm.isAwaitingClientConfirmationMailReq = isAwaitingClientConfirmationMailReq;

               SRV_TPA_TPARequest.runType = 'RunTpaBusinessRule';
               SRV_TPA_TPARequest.tpaRequest = tpaReq;
               tpaReq = SRV_TPA_TPARequest.updateAgreementFieldsForVendor(TRUE);


            }

          //  tpaReq.Is_Potential_Vendor_Case__c = false;
          // update tpaReq;

            
        }
        catch(Exception ex) {
            system.debug(ex.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog( FALSE, 
                                                                                FALSE, 
                                                                                argGUID, 
                                                                                'Exception: Line# - ' + ex.getLineNumber(), 
                                                                                'TPA', 
                                                                                'Exception', 
                                                                                'ERROR', 
                                                                                ':::EXT_TPA_GenerateAndSendDoc:::generateAndSendForSignDocPotentialVendorCase - ' + ex.getMessage(), 
                                                                                (reqId != null) ? reqId : ''));
     
        }
       
        

    }
    
    @remoteAction
    public static String getRequestNo() { 
        string reqId = Apexpages.currentPage().getParameters().get('id');
        TPA_Request__c reqObj= [SELECT Id,Name FROM TPA_Request__c WHERE id=:reqId LIMIT 1];  
        return reqObj.Name;
    }
}
