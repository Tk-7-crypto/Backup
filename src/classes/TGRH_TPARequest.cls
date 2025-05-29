public without sharing class TGRH_TPARequest  { 
    public static User currentUser;
    public static Boolean isTpaAdminAssignedToUser = false;
    public static Boolean doesUserContainsUSTPAccessSet = false;
    public static String profileName;
    public static Boolean dataMailSent = false;
    public static Boolean isCreateActivity = true;
    public string orgWideEmailId = '';
    public string templateId = '';
    public boolean isManualDRNCalled = false;
    public boolean isManualCopyofSigned = false;
    public static boolean updateTpaAfterExecutionEmails = false;
    public static boolean updateTpaAfterSignature = false;
    public static boolean isCourtesyEmailSent = false;
    public static boolean isOnHoldFieldUpdate = false;
    public static boolean runAllCompletedBlock = false;
    public static Map<Id, TPA_Master_Extension_Information__c> mapTPAMasExtension {
        get; set;
    }

    public static fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
        new Schema.SObjectType[] {
            TPA_Request__c.SobjectType
        }
    );

    public TGRH_TPARequest() {
       currentUser = UTL_TPA.getCurrentUserDetails();
       profileName = currentUser.Profile.Name;

        for(PermissionSetAssignment permSetAssign: currentUser.PermissionSetAssignments) {
            if(permSetAssign.PermissionSet.Label == 'TPA Admin') {
                isTpaAdminAssignedToUser = true;
            }
            if(permSetAssign.PermissionSet.Label == 'TP Processor Access Set'){
                doesUserContainsUSTPAccessSet = true;
            }
        }
    }   

    public void onBeforeInsert(List<TPA_Request__c> newTpaReqList) {
        String userCountry = string.IsBlank(currentUser.User_Country__c) ? 'USA' : currentUser.User_Country__c;
        for(TPA_Request__c tpaRequest : newTpaReqList) {
            tpaRequest.User_Country__c = userCountry;
            tpaRequest.Client_Request_Submission__c = Datetime.now();
            tpaRequest.Vendor_App_Sent__c = Datetime.now();               
        }
    }

    public Boolean onBeforeUpdate(List<TPA_Request__c> newTpaReqList, List<TPA_Request__c> oldTpaReqList, Map<Id, TPA_Request__c> newTpaReqMap, Map<Id, TPA_Request__c> oldTpaReqMap) {
        system.debug('before update method called');
        if(TGRH_TPA_AgreementAdditionalField.isPartiallyRenewed || UTL_TPA.isPurposeUpdateCalled) {
            return false;
        }
        if(UTL_TPA.notificationsTriggerExecuted) {
            SRV_TPA_TPARequest.sendRenewalAndExpirationMail(newTpaReqList);
        }
        
        if(newTpaReqMap != null) { 
            if(!UTL_TPA.ClientSubmissionUpdate) {
                if(mapTPAMasExtension == null) {
                    Map<Id, Id> mapTPAVendAddId = new Map<Id, Id>();
    
                    for(TPA_Request__c tpaRequest : newTpaReqList) {
                        TPA_Request__c newTpaRequest = newTpaReqMap.get(tpaRequest.Id);
                        TPA_Request__c oldTpaRequest = oldTpaReqMap.get(tpaRequest.Id);
                        if(newTpaRequest.Service_Provider_Address__c != null && (newTpaRequest.Vendor_Address_Extension_Record__c == null || newTpaRequest.Service_Provider_Address__c != oldTpaRequest.Service_Provider_Address__c)) {
                            mapTPAVendAddId.put(newTpaRequest.Id, newTpaRequest.Service_Provider_Address__c);
                        }
                    }
                    if((mapTPAVendAddId != null && mapTPAVendAddId.size() > 0)) {
                        Map<Id, Address__c> mapTPAVendAdd = new Map<ID, Address__c>([Select Id, (Select Id from TPA_Master_Extension_Informations__r limit 1) From Address__c where Id in: mapTPAVendAddId.values()]);
                        if(mapTPAVendAdd != null && mapTPAVendAdd.size() > 0) {
                            for(TPA_Request__c tpaRequest : newTpaReqList) {
                                if(mapTPAVendAdd.get(tpaRequest.Service_Provider_Address__c) != null && mapTPAVendAdd.get(tpaRequest.Service_Provider_Address__c).TPA_Master_Extension_Informations__r != null && mapTPAVendAdd.get(tpaRequest.Service_Provider_Address__c).TPA_Master_Extension_Informations__r.size() > 0) {
                                    tpaRequest.Vendor_Address_Extension_Record__c = mapTPAVendAdd.get(tpaRequest.Service_Provider_Address__c).TPA_Master_Extension_Informations__r[0].Id;
                                }
                            }
                        }
                    }
                }
                if(TGRH_TPARequest.runAllCompletedBlock) {
                    for(TPA_Request__c tpaReq:[Select Id,Name,AMA_Agreement_required__c,Requires_Manual_Review__c,Vendor_App_Submitted__c,TP_Processor_Email__c,vendor_language__c,TLLA_Batch_Call_Sent_On__c,Request_Status__c,Is_VSN_Acknowlege_By_Client__c,isClientOnComplianceHold__c,isVendorOnComplianceHold__c,Is_Potential_Vendor_Case__c,isLegalEntityPresent__c,Pending_Acknowledgements__c,(Select Id,Status__c,Manual_Review_Reason__c from TPA_Commercial_Reviews__r),(select id, name, CreatedDate from Attachments order by createddate desc),(Select Id,Is_AMA_License_Required__c,AMA_Manual_Review__c From AMA_Agreement_Details__r) From TPA_Request__c where Id in: newTPAReqMap.keySet()]){
                        if(newTPAReqMap.get(tpaReq.Id).Request_Status__c == 'In Review by IQVIA' && oldTpaReqMap.get(tpaReq.Id).Request_Status__c != 'Awaiting Vendor Signature'){
                            Boolean allCompleted = true;
                            Boolean isOtherUseorOffshoreSelected = false;
                            Integer countOfReviews = 0;// will review, use a flag
                            for(TPA_Commercial_Review__c comRev: tpaReq.TPA_Commercial_Reviews__r) {
                                if(comRev.Status__c == null || (comRev.Status__c != null && !comRev.Status__c.contains('Combination Approved') && !comRev.Status__c.contains('Combination Approved and Future Approved') && comRev.Status__c != 'Complete')){
                                    allCompleted = false;
                                }
                                if(comRev.Manual_Review_Reason__c != null && (comRev.Manual_Review_Reason__c.contains('offshore') || comRev.Manual_Review_Reason__c.contains('Other Use Selected'))){
                                    isOtherUseorOffshoreSelected = true;
                                }
                                countOfReviews++;
                            }
                            if(countOfReviews>0 && allCompleted) {
                                string strPickListValue = newTPAReqMap.get(tpaReq.Id).Pending_Acknowledgements__c;
                                if(strPickListValue != null){
                                    List<string> lstPicklistValues = strPickListValue.split(';');
                                    string strValueToRemove ='Pending Commercial Review Acknowledgements';
                                    if(lstPicklistValues.contains(strValueToRemove)){
                                        lstPicklistValues.remove(lstPicklistValues.indexOf(strValueToRemove));
                                    }
                                    newTPAReqMap.get(tpaReq.Id).Pending_Acknowledgements__c = String.join(lstPicklistValues,';');
                                }
                            }                    
                            
                            if(countOfReviews>0 && allCompleted && !isOtherUseorOffshoreSelected && oldTpaReqMap.get(tpaReq.Id).Request_Status__c != newTPAReqMap.get(tpaReq.Id).Request_Status__c && newTPAReqMap.get(tpaReq.Id).Request_Status__c == 'In Review by IQVIA'){    
                                Boolean amaManualReview = false;
                                Boolean isAMADocReq = false;
                                AMA_Agreement_Detail__c amaObj;
                                if(tpaReq.AMA_Agreement_Details__r != null && !tpaReq.AMA_Agreement_Details__r.isEmpty()) {
                                    amaObj = tpaReq.AMA_Agreement_Details__r[0];
                                    if(amaObj.AMA_Manual_Review__c ){
                                        amaManualReview = amaObj.AMA_Manual_Review__c;
                                    }
                                    if(amaObj.Is_AMA_License_Required__c ){
                                        isAMADocReq = amaObj.Is_AMA_License_Required__c;
                                    }
                                }
                                //Boolean isAMADocReq = tpaReq.AMA_Agreement_required__c;
                                if(SRV_TPA_TPARequest.isReqReadyForSignatures(newTPAReqMap.get(tpaReq.Id)) && TGRH_TPA_Commercial_Review.checkIfAllDocsAreGenerated(tpaReq.Attachments, isAmaDocReq,tpaReq.Vendor_App_Submitted__c) && !amaManualReview){    
                                    TGRH_TPA_Commercial_Review.sendForDocuSign(tpaReq.Id);
                                }
                            }
                        }
                    } 
                }	
            }			
            for(TPA_Request__c tpaRequest : newTpaReqMap.values()) {
                if(!UTL_TPA.ClientSubmissionUpdate && !UTL_TPA.vendorSubmissionFirstUpdate) {
                    if(tpaRequest.Request_Status__c == 'Cancelled' && oldTpaReqMap.get(tpaRequest.Id).Request_Status__c != 'Cancelled') {
                        tpaRequest.TPA_Old_Status_When_Cancelled__c = oldTpaReqMap.get(tpaRequest.Id).Request_Status__c;
                    }
                    if(oldTpaReqMap.get(tpaRequest.Id).Request_Status__c != tpaRequest.Request_Status__c && doesUserContainsUSTPAccessSet) {
                        Boolean showError = true;
                        //will review, combine all the if blocks together
                        if(tpaRequest.Request_Status__c == 'Cancelled'){
                            showError = false;
                        }
                        else if(tpaRequest.Request_Status__c == 'Signature Under Validation'){
                            showError = false;
                        }
                        else if(oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Signature Under Validation' && tpaRequest.Request_Status__c == 'In Effect'){
                            showError = false;
                        }
                    else if(oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'In Effect' && tpaRequest.Request_Status__c == 'Expired'){
                        showError = false;
                    }
                        String errorMsg = 'TPA Request Status cannot be updated to ' + tpaRequest.Request_Status__c + ' from In Review by IQVIA by your User';
                        if(showError){
                            tpaRequest.addError(errorMsg);
                        }
                    }
                    if( (oldTpaReqMap.get(tpaRequest.Id).Request_Status__c != 'In Effect' &&
                            oldTpaReqMap.get(tpaRequest.Id).Request_Status__c != 'AMA Discontinued' &&
                            oldTpaReqMap.get(tpaRequest.Id).Request_Status__c != 'AMA Cancelled' &&
                            oldTpaReqMap.get(tpaRequest.Id).Request_Status__c != 'Client Discontinued')
                        && ( tpaRequest.Request_Status__c == 'AMA Discontinued' 
                             || tpaRequest.Request_Status__c == 'AMA Cancelled'  
                             || tpaRequest.Request_Status__c == 'Client Discontinued' 
                           ) 
                        && !UTL_TPA.modifyRequest) {
                        String errorMsg = 'TPA Request Status can be updated to ' + tpaRequest.Request_Status__c + ' from In Effect Status Only';
                        tpaRequest.addError(errorMsg);
                    }
                    if( oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'In Effect' 
                        && tpaRequest.Request_Status__c != 'Cancelled' 
                        && tpaRequest.Request_Status__c != 'Client Discontinued' 
                        && tpaRequest.Request_Status__c != 'AMA Cancelled' 
                        && tpaRequest.Request_Status__c != 'AMA Discontinued' 
                        && tpaRequest.Request_Status__c != 'Expired' 
                        && tpaRequest.Request_Status__c != 'Closed-IQVIA Affiliate'  
                        && !updateTpaAfterExecutionEmails
                        && !updateTpaAfterSignature
                        && !UTL_TPA.modifyRequest 
                        && UTL_TPA.amaSettings != null 
                        && !UTL_TPA.amaSettings.isEmpty() 
                        && !UTL_TPA.modifyRequestForcefully
                        && tpaRequest.Request_Status__c != UTL_TPA.amaSettings.get(0).Vendor_Renewal_Cancelation_Status__c) {
                        if(tpaRequest.Request_Status__c == 'In Effect') {
                            if( oldTpaReqMap.get(tpaRequest.Id).Vendor_Contact_e_mail__c == tpaRequest.Vendor_Contact_e_mail__c 
                                && oldTpaReqMap.get(tpaRequest.Id).Authorized_Signer_Email__c == tpaRequest.Authorized_Signer_Email__c
                              	&& !CNT_TPA_ContinueNotificationProcess.isRequestEarlyExpired
                                && !tpaRequest.Client_Expired_Early__c) {
                                tpaRequest.addError('TPA Request cannot be updated once status is In Effect.');
                            }
                        }
                        else {
                            tpaRequest.Request_Status__c = oldTpaReqMap.get(tpaRequest.Id).Request_Status__c;
                            tpaRequest.addError('TPA Request status cannot be set to previous status once it is In Effect.');
                        }
                    }
                    if((    ( oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Awaiting Vendor Submission' 
                              && tpaRequest.Request_Status__c == 'Covered By MOU'
                              && (profileName.indexOf('Alliance TPA Processing') != -1 && !isTpaAdminAssignedToUser ) 
                            ) 
                         || ( (   oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Initializing Vendor' 
                               || oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Awaiting Vendor Submission'
                              )  
                              && profileName !='System Administrator' 
                              && profileName !='System Administrator Integration' 
                              && profileName !='TPA Vendor Community User' 
                              && (profileName.indexOf('TPA Processor Profile') == -1) 
                              && (profileName.indexOf('US TP Processor Profile') == -1) 
                              && (profileName.indexOf('Super User Profile') == -1) 
                              && profileName !='TPA Customer Community Plus Login User' 
                              && profileName.indexOf('Alliance TPA Processing') == -1
                              && !isTpaAdminAssignedToUser
                            ) 
                        ) 
                        && !UTL_TPA.modifyRequestNonSysAdminUser 
                        && tpaRequest.Request_Status__c != oldTpaReqMap.get(tpaRequest.Id).Request_Status__c) {
                         tpaRequest.addError('You are not authorized to change the status from ' + oldTpaReqMap.get(tpaRequest.Id).Request_Status__c + ' to ' + tpaRequest.Request_Status__c +' for this request.');
                    }                    
                    if(tpaRequest.Request_Status__c == 'In Effect') {
                        Date startDateVal = Date.today();
                        Date endDateVal = tpaRequest.Data_Access_End_Date__c;
                        Integer numberDays = startDateVal.daysBetween(endDateVal);
                        
                        if(numberDays >= 0) {
                            tpaRequest.Original_Start_Date__c = tpaRequest.Data_Access_Start_Date__c;
                        }
                        else {
                            tpaRequest.Request_Status__c = 'Expired';
                            tpaRequest.Original_Start_Date__c = tpaRequest.Data_Access_Start_Date__c;
                        }
    
                        tpaRequest.Is_TPA_Signed_Contract_Attached__c = true;
                    }
                    if(tpaRequest.Request_Status__c == 'Covered By MOU' 
                        && (
                        oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Cancelled' 
                        || oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Client Discontinued' 
                        || oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'AMA Cancelled' 
                        || oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'AMA Discontinued' 
                        || oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Expired' 
                        || oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Closed-IQVIA Affiliate'
                        || oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'In Effect'
                        || oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == UTL_TPA.amaSettings.get(0).Vendor_Renewal_Cancelation_Status__c)
                        && !UTL_TPA.modifyRequest                
                    ){
                        tpaRequest.addError('TPA Request cannot be updated to Covered By MOU from any final status.');
                    }
                    if(oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Covered By MOU'
                        && (
                            tpaRequest.Request_Status__c != 'Awaiting Vendor Submission'
                            && tpaRequest.Request_Status__c != 'In Auto Approval Process'
                            && tpaRequest.Request_Status__c != 'In Review By IQVIA'    
                        )
                        && !UTL_TPA.modifyRequest
                        && !UTL_TPA.isMOUStatusChangeValidationChecked){
                        tpaRequest.addError('TPA Request status cannot be updated from Covered By MOU to ' + tpaRequest.Request_Status__c);
                    }
                    else if(oldTpaReqMap.get(tpaRequest.Id).Request_Status__c != 'Covered By MOU' 
                        && tpaRequest.Request_Status__c == 'Covered By MOU'){
                            UTL_TPA.isMOUStatusChangeValidationChecked = true;
                    }
                    If( oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Cancelled' && !UTL_TPA.modifyRequest) {
                        tpaRequest.Request_Status__c = 'Cancelled';
                    }
                }
                if(tpaRequest.Data_Access_End_Date__c != null && !tpaRequest.Client_Expired_Early__c) {
                    tpaRequest.Expiration_Date__c = tpaRequest.Data_Access_End_Date__c;
                }

                try {
                    if(tpaRequest.Is_Contract_Generated__c) {
                        QBL_TPA_AsyncSendDoc asyncSendDocCall= new QBL_TPA_AsyncSendDoc();
                        asyncSendDocCall.requestId = tpaRequest.id;
                        System.enqueueJob(asyncSendDocCall);
                        tpaRequest.Is_Contract_Generated__c = false;
                    }
                }
                catch( Exception ex) {
                    system.debug(ex.getMessage() + ex.getCause());
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() +':::' + ex.getCause() +':::TGRH_TPARequest:::BeforeUpdate:::Docusign Call:::', (tpaRequest.id != null) ? tpaRequest.id : ''));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), FALSE);
                }

                if(tpaRequest.TPA_Authorised_Signer__c == 'Yes') {
                    tpaRequest.Authorized_Signer_First_Name__c = tpaRequest.Vendor_First_Name__c;
                    tpaRequest.Authorized_Signer_Last_Name__c = tpaRequest.Vendor_Contact_Last_Name__c;
                    tpaRequest.Authorized_Signer_Title__c = tpaRequest.Vendor_Contact_Title__c;
                    tpaRequest.Authorized_Signer_Email__c = tpaRequest.Vendor_Contact_e_mail__c;
                }

                if(tpaRequest.Request_Status__c != oldTpaReqMap.get(tpaRequest.id).Request_Status__c
                || tpaRequest.Agreement_Effective_Date__c != oldTpaReqMap.get(tpaRequest.id).Agreement_Effective_Date__c
                || tpaRequest.Authorized_Signer_Email__c != oldTpaReqMap.get(tpaRequest.id).Authorized_Signer_Email__c
                || tpaRequest.Authorized_Signer_First_Name__c != oldTpaReqMap.get(tpaRequest.id).Authorized_Signer_First_Name__c
                || tpaRequest.Authorized_Signer_Last_Name__c != oldTpaReqMap.get(tpaRequest.id).Authorized_Signer_Last_Name__c
                || tpaRequest.Authorized_Signer_Title__c != oldTpaReqMap.get(tpaRequest.id).Authorized_Signer_Title__c
                || tpaRequest.Internal_Pending_Status__c != oldTpaReqMap.get(tpaRequest.id).Internal_Pending_Status__c
                || tpaRequest.TPA_Assigned_TP_Processor__c != oldTpaReqMap.get(tpaRequest.id).TPA_Assigned_TP_Processor__c) {
                    if(tpaRequest.request_status__c == 'Cancelled') {
                        String userTimeZone = currentUser.TimeZoneSidKey;
                        String userName = currentUser.name;
                        String userId = currentUser.Id;
                        
                        List<String> lstTimeDate = (Datetime.now().format('MM/dd/yyyy HH:mm a',userTimeZone)).split(' ');
                        String todayDate = lstTimeDate[0]+', '+lstTimeDate[1]+' '+lstTimeDate[2];
                                
                        if(profileName == 'TPA Customer Community Plus Login User') {
                            tpaRequest.TPA_Request_Cancel_Reason__c = 'Request Cancelled by '+userName+'('+userId+') on '+todayDate+' with profile Customer Community Login User(Client)';
                        }
                        else if(profileName.indexOf('Super User Profile') != -1) {
                            tpaRequest.TPA_Request_Cancel_Reason__c = 'Request Cancelled by '+userName+'('+userId+') on '+todayDate+' with profile Super User';
                        }
                        else if(profileName.indexOf('TPA Processor Profile') != -1) {
                            tpaRequest.TPA_Request_Cancel_Reason__c = 'Request Cancelled by '+userName+'('+userId+') on '+todayDate+' with profile TP Processor Profile(through portal)';
                        }
                        else if(profileName.indexOf('US TP Processor Profile') != -1) {
                            tpaRequest.TPA_Request_Cancel_Reason__c = 'Request Cancelled by '+userName+'('+userId+') on '+todayDate+' with profile US TP Processor Profile(through portal)';
                        }
                        else if(profileName == 'System Administrator' && UTL_TPA.isCancelledBySystem) {
                            tpaRequest.TPA_Request_Cancel_Reason__c = 'Request Cancelled by System on '+todayDate;
                        }
                        else if(profileName == 'System Administrator') {
                            tpaRequest.TPA_Request_Cancel_Reason__c = 'Request Cancelled by '+userName+'('+userId+') on '+todayDate+' with profile System Admin';
                        }
                        else {
                            tpaRequest.TPA_Request_Cancel_Reason__c = 'Request Cancelled by '+userName+'('+userId+') on '+todayDate+' with profile '+ profileName;
                        }
                    }  

                    if( !tpaRequest.Request_Status__c.equalsIgnoreCase('Pending Vendor AMA Fee Acknowledgement') 
                    && !tpaRequest.Request_Status__c.equalsIgnoreCase('Pending - Vendor Declined AMA Fees')) {
                        tpaRequest.TPA_Request_Temporary_Status__c = tpaRequest.Request_Status__c;
                    }
                }
            }
        }

        Map<Id, DateTime> mapAgreeIdWithDate = new Map<Id, DateTime>();
        Set<Id> PriDataAssetIdWithSecData = new Set<Id>();

        if(!QBL_TPA_sendCommercialMail.isComReviewsInsert && !CNT_TPA_CommercialReviewForm.isCommRevUpdate){
        for(TPA_Request__c tpaRequest: [select Id,Client_Address__c,Client_Address__r.Name,Name,Request_Status__c,Service_Provider_Name__c,Service_Provider_Address__r.Name,
                                        Service_Provider_Address__r.Parent_Vendor_Name__c,Service_Provider_Address__r.Parent_Vendor_Name__r.Name,Client_Contact_Territory__c,
                                        isLegalEntityPresent__c,Secondary_Client_Contact_Territory__c,client_language__c,
                                        vendor_language__c,TPA_Assigned_TP_Processor__c,TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, AMA_Agreement_required__c,
                                        (select Id, Secondary_Asset_Name__c, IMS_Legal_Entity__c, TPA_Data_Asset__c, TPA_Data_Asset__r.IMSLegalEntity__c from TPA_Tertiary_Data_Assets__r),
                                        (Select Id, name, Is_AMA_License_Required__c, Vendor_Legal_Name__c, Client__c, DBL__c, Max_Fee_Reached__c, Agreement_End_Date__c, Contract_Type__c, 
                                        AMA_Manual_Review__c, Send_DBL_Notification_To_AMA__c, Vendor_Employee_Accessed_Data_in_country__c, AMA_Foreign_Storage_Contract_Type__c, Is_Foreign_License_Required__c,Current_Year_Fees__c, Vendor_AMA_Fee_Response__c from AMA_Agreement_Details__r limit 1),
                                        (select id, Vendor_Specific_Notification_Response__c from TPA_Agreement_Additional_Fields__r),
                                        (select id, Asset_NametText__c, IMSLegalEntity__c from Data_Assets__r),
                                        (select Id, Name from Attachments order by LastModifiedDate Desc),
                                        (select id, dsfs__Envelope_Status__c from DocuSign_Status__r order by LastModifiedDate Desc limit 1)
                                        from TPA_Request__c
                                        where id in: newTpaReqMap.keySet()]) {            
            if(oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Awaiting Vendor Signature') {
                if(newTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'In Effect') {
                    if(!tpaRequest.DocuSign_Status__r.isEmpty()) {
                        if( tpaRequest.DocuSign_Status__r[0].dsfs__Envelope_Status__c != 'Voided' 
                        && tpaRequest.DocuSign_Status__r[0].dsfs__Envelope_Status__c != 'Completed'
                        && !Test.isRunningTest()) {
                            newTpaReqMap.get(tpaRequest.Id).Request_Status__c = oldTpaReqMap.get(tpaRequest.Id).Request_Status__c;
                            newTpaReqMap.get(tpaRequest.Id).addError('Click \'Void Envelope\' first and then change the status to \'In Effect\'');
                        }
                    }
                }
            }
            //String UseListRichtextFormate = '';
            
            //String vendorLanguage = newTpaReqMap.get(tpaRequest.Id).TLLA_Language_Chosen__c != null ? newTpaReqMap.get(tpaRequest.Id).TLLA_Language_Chosen__c : (newTpaReqMap.get(tpaRequest.Id).Vendor_Language__c != null ? newTpaReqMap.get(tpaRequest.Id).Vendor_Language__c : 'English');

            //if((oldTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus__c != newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus__c) || (newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus__c != null && newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus__c != '' && (newTpaReqMap.get(tpaRequest.Id).Use_List__c == null || newTpaReqMap.get(tpaRequest.Id).Use_List__c == ''))) {
            //	UseListRichtextFormate = String.join(newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus__c.split(';'), '</li><li>');
            //	UseListRichtextFormate = '<ul style="font-size: 8.0pt;color: black;" ><li>' + UseListRichtextFormate + '</li></ul>';
            //	newTpaReqMap.get(tpaRequest.Id).Use_List__c = UseListRichtextFormate;
            //}
            //if(vendorLanguage == 'French' && (oldTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus_Fr__c != newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus_Fr__c) || (newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus_Fr__c != null && newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus_Fr__c != '' && (newTpaReqMap.get(tpaRequest.Id).Localized_Use_List__c == null || newTpaReqMap.get(tpaRequest.Id).Localized_Use_List__c == ''))) {
            //	UseListRichtextFormate = String.join(newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus_Fr__c.split(';'), '</li><li>');
            //	UseListRichtextFormate = '<ul style="font-size: 8.0pt;color: black;" ><li>' + UseListRichtextFormate + '</li></ul>';
            //	newTpaReqMap.get(tpaRequest.Id).Localized_Use_List__c = UseListRichtextFormate;
            //}
            //else if(vendorLanguage == 'Japanese' && (oldTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus_Ja__c != newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus_Ja__c) || (newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus_Ja__c != null && newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus_Ja__c != '' && (newTpaReqMap.get(tpaRequest.Id).Localized_Use_List__c == null || newTpaReqMap.get(tpaRequest.Id).Localized_Use_List__c == ''))) {
            //	UseListRichtextFormate = String.join(newTpaReqMap.get(tpaRequest.Id).TPA_Purpose_Picklist_Apttus_Ja__c.split(';'), '</li><li>');
            //	UseListRichtextFormate = '<ul style="font-size: 8.0pt;color: black;" ><li>' + UseListRichtextFormate + '</li></ul>';
            //	newTpaReqMap.get(tpaRequest.Id).Localized_Use_List__c = UseListRichtextFormate;
            //}
            if(newTpaReqMap.get(tpaRequest.Id).Request_Status__c != oldTpaReqMap.get(tpaRequest.id).Request_Status__c) {
                Boolean holdForAMAFeeConfirmation = false;
                Boolean isVSNAckAlready = false;
                if(tpaRequest.TPA_Agreement_Additional_Fields__r != null && tpaRequest.TPA_Agreement_Additional_Fields__r.size() > 0) {
                    TPA_Agreement_Additional_Field__c tpaAgreementAdditionalFieldData = tpaRequest.TPA_Agreement_Additional_Fields__r[0];
                    isVSNAckAlready = tpaAgreementAdditionalFieldData!= null 
                                && tpaAgreementAdditionalFieldData.Vendor_Specific_Notification_Response__c != null 
                                && tpaAgreementAdditionalFieldData.Vendor_Specific_Notification_Response__c != '' 
                                && tpaAgreementAdditionalFieldData.Vendor_Specific_Notification_Response__c.contains('Acknowledge');
                } 
                if(!tpaRequest.AMA_Agreement_Details__r.isEmpty()) {
                    AMA_Agreement_Detail__c amaAgreement = tpaRequest.AMA_Agreement_Details__r[0];
                    if( amaAgreement!= null 
                    && amaAgreement.Is_AMA_License_Required__c 
                    && amaAgreement.Current_Year_Fees__c > 0 
                    && (String.isBlank(amaAgreement.Vendor_AMA_Fee_Response__c) || !(amaAgreement.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('acknowledged') ))
                    && ( amaAgreement.Contract_Type__c == 'Service Bureau II' 
                    || amaAgreement.Contract_Type__c == 'Contract Sales Force')) {
                        holdForAMAFeeConfirmation = true;
                    }
                }
            
                if(SRV_TPA_TPARequest.isDirectToClientExeMode || SRV_TPA_TPARequest.isQuintilesIMSSalesExeMode) {
                    newTpaReqMap.get(tpaRequest.Id).is_VSN_Selected__c = true;
                }
                if(!isVSNAckAlready && newTpaReqMap.get(tpaRequest.Id).is_VSN_Selected__c == true){
                    newTpaReqMap.get(tpaRequest.Id).Is_VSN_Acknowlege_By_Client__c  = true;
                    if(SRV_TPA_TPARequest.tpaRequest?.Is_VSN_Acknowlege_By_Client__c != null)
                        SRV_TPA_TPARequest.tpaRequest.Is_VSN_Acknowlege_By_Client__c = true;                
                }
                if(newTpaReqMap.get(tpaRequest.Id).is_VSN_Selected__c) {
                    if(holdForAMAFeeConfirmation && !isVSNAckAlready) {
                        if( (  oldTpaReqMap.get(tpaRequest.id).Request_Status__c == 'Pending - Vendor Declined AMA Fees' 
                            || oldTpaReqMap.get(tpaRequest.id).Request_Status__c == 'Pending Vendor AMA Fee Acknowledgement'
                            ) 
                        && tpaRequest.Request_Status__c == Label.TPA_In_Review_By_IQVIA_Status
                        ) {
                            newTpaReqMap.get(tpaRequest.Id).Is_VSN_Acknowlege_By_Client__c  = true;
                        }
                    }
                    else if(newTpaReqMap.get(tpaRequest.Id).Request_Status__c == UTL_TPA.AWAITING_CLIENT_CONFIRMATION) {
                        newTpaReqMap.get(tpaRequest.Id).Is_VSN_Acknowlege_By_Client__c  = true; 
                    }
                }
            }

            newTpaReqMap.get(tpaRequest.Id).Agreement_Name__c = getAgreementName(tpaRequest);
            
            AMA_Agreement_Detail__c amaObj;
            if(tpaRequest.AMA_Agreement_Details__r != null && !tpaRequest.AMA_Agreement_Details__r.isEmpty()) {
                amaObj = tpaRequest.AMA_Agreement_Details__r[0];
                if(amaObj.Is_AMA_License_Required__c ){
                    newTpaReqMap.get(tpaRequest.Id).AMA_Agreement_required__c = true;
                }
                else{
                    newTpaReqMap.get(tpaRequest.Id).AMA_Agreement_required__c = false;
                }
            }

            if(oldTpaReqMap.get(tpaRequest.Id).Request_Status__c != 'In Effect') {
                if(newTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'In Effect') {
                    if( amaObj != null 
                    && amaObj.Send_DBL_Notification_To_AMA__c
                    && !UTL_TPA.DBL_Notification_Mail_Sent) {
                        List<String> toAddresses = new List<String>{ UTL_TPA.dblContractContactEmail };
                        if( String.isNotBlank(amaObj.Client__c) 
                        && String.isNotBlank(amaObj.Vendor_Legal_Name__c) 
                        && ( amaObj.Client__c.startsWithIgnoreCase('Test')  || amaObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))) {
                            toAddresses = null;
                        }
                        
                        String emailType = 'Notify Affiliated DBL Regarding Update';
                        List<String> ccAddresses = new List<String>();
                        if(String.isNotBlank(UTL_TPA.amaSettings[0].Mail_Addresses_for_Amendment_To_DBL__c)) {
                            ccAddresses = UTL_TPA.amaSettings[0].Mail_Addresses_for_Amendment_To_DBL__c.split(';');
                        }
                        Id emailWhatId = amaObj.Id;
                        Boolean saveAsActivity = true;

                        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                        if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                           SRV_TPA_TPARequest.assignedTPProcessorName = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c; 
                        }*/

                        try {
                            SRV_TPA_TPARequest.sendTPANotifications(toAddresses, ccAddresses, emailType, 'English', emailWhatId, saveAsActivity, null, null, TRUE, TRUE, tpaRequest);
                            UTL_TPA.DBL_Notification_Mail_Sent = true;
                            //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                        } catch(Exception e) {
                            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_TPARequest.onBeforeUpdate:::AMA DBL Notification Email sending Failed', tpaRequest.id != null ? tpaRequest.id : ''));
                            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                            System.debug('AMA DBL Notification Email sending Failed: ' + e.getMessage());
                        }
                    }
                    
                    if( amaObj != null 
                    && amaObj.Is_AMA_License_Required__c
                    && !amaObj.AMA_Manual_Review__c
                    && !UTL_TPA.Inserted_To_AMA_Data) {
                        try {
                            AMA_Contract_Detail__c createdContracDetailObj = new AMA_Contract_Detail__c();
                            String vendorName = '';
                            Id vendorId = null;
                            if(tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null){
                                vendorName = tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Name;
                                vendorId = tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.id;                            
                            }
                            else{
                                vendorName = tpaRequest.Service_Provider_Address__r.Name;
                                vendorId = tpaRequest.Service_Provider_Address__r.id;                             
                            }
                            createdContracDetailObj.Client__c = vendorName;
                            //createdContracDetailObj.Client__c = tpaRequest.AMA_Agreement_Details__r[0].Vendor_Legal_Name__c;
                            createdContracDetailObj.Client_Services_On_Behalf_Of__c = amaObj.Client__c;
                            if(amaObj.DBL__c != null && amaObj.DBL__c.contains('(')) {
                                String dblValue = amaObj.DBL__c;
                                String separator1 = '(';
                                String separator2 = ')';
                                dblValue = dblValue.substringAfter(separator1);
                                dblValue = dblValue.substringBefore(separator2);
                                createdContracDetailObj.DBL__c  = dblValue ;
                            } else {
                                createdContracDetailObj.DBL__c  = amaObj.DBL__c ;
                            }
                            createdContracDetailObj.Contract_End_Date__c = amaObj.Agreement_End_Date__c;
                            createdContracDetailObj.Contract_Type__c = amaObj.Contract_Type__c;

                            if(amaObj.Vendor_Employee_Accessed_Data_in_country__c != null 
                            && !amaObj.Vendor_Employee_Accessed_Data_in_country__c.equalsIgnoreCase('USA')) {
                                String location='';
                                if(amaObj.Vendor_Employee_Accessed_Data_in_country__c.contains(';'))
                                    location = amaObj.Vendor_Employee_Accessed_Data_in_country__c.replace(';',',');
                                else
                                    location = amaObj.Vendor_Employee_Accessed_Data_in_country__c;
                                createdContracDetailObj.Offshore_Access__c = location; 
                            }
                            if(createdContracDetailObj.Contract_Type__c != null 
                            && createdContracDetailObj.Contract_Type__c.equalsIgnoreCase('Lettershop')) {
                                createdContracDetailObj.Contract_List_Type__c = 'Lettershop';
                            }
                            else {
                                createdContracDetailObj.Contract_List_Type__c = 'Client List';
                            }
                            insert createdContracDetailObj;
                            amaObj.TPA_AMA_Contract_Detail_Info__c = createdContracDetailObj.id;
                            update amaObj;
                            UTL_TPA.updateEntryInClientVendorSrchMap(vendorId, vendorName);
                            UTL_TPA.Inserted_To_AMA_Data = true;
                        } catch(Exception e) {
                            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_TPARequest.onBeforeUpdate:::Error while inserting new contract detail object', tpaRequest.id != null ? tpaRequest.id : ''));
                            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                            system.debug('Error while inserting new contract detail object:- '+e.getMessage());
                        }
                    }
                    //if(!tpaRequest.Attachments.isEmpty()) {
                        string currentYear = String.valueOf(Date.Today().Year());
                        string previousYear = String.valueOf(Date.Today().Year()-1);
                        string nextYear = String.valueOf(Date.Today().Year()+1);
                        List<String> withCompletedSuffixAttachments = new List<String>();
                        List<String> withoutCompletedSuffixAttachments = new List<String>();
                        Boolean isTLLASentPresent = false;
                        Boolean isAMAOldSentPresent = false;
                        Boolean isAMASentPresent = false;
                        Boolean isAMAFLSentPresent = false;
                        Boolean isHelpfulHintSent = false; 
                        Boolean isAMAOldCompletePresent = false;
                        Boolean isTLLACompletePresent = false;
                        Boolean isAMACompletePresent = false;
                        Boolean isAMAFLCompletePresent = false;
                        Boolean isHelpfulHintCompletedAttached = false;
                        String errorString = '';
                        String tpaRequestName = tpaRequest.Name.toLowerCase();
                        String amaContractType = null;
                        String amaFLContractType = null; 
                        String sentTLLA ;
                        String sentAMA ;
                        String sentAMAFL ;
                        String sentOldAMA;
                        String sentHelpful;
                        Boolean isNewAMADocRequired = false;
                        Boolean isAMAFLDocRequired = false; 
                        Boolean isOldAMADocRequired = false;
                        List<String> oldAMATemplateNames = new List<String>();
                        oldAMATemplateNames = Label.AMA_Documents_Name.split(';');
                        String previousNameTemplate ;
                        String currentNameTemplate ;
                        String nextNameTemplate;

                        if(amaObj != null) {
                            amaContractType = amaObj.Contract_Type__c == null ? '' : amaObj.Contract_Type__c.toLowerCase();
                            if(amaObj.Is_AMA_License_Required__c) {
                                isNewAMADocRequired = true;
                            }
                            if(amaObj.Is_Foreign_License_Required__c) {
                                isAMAFLDocRequired = true;
                            }
                        }
                        
                        Boolean isAttachmentPresent = false;

                        for(Attachment attchmnt : tpaRequest.Attachments) {
                            isAttachmentPresent = true;
                            if(attchmnt.name.toLowerCase().IndexOf('_completed') != -1) {
                                List<String> lstSplittedName = new List<String>();
                                lstSplittedName = attchmnt.name.toLowerCase().split('_completed');
                                if(lstSplittedName != null && lstSplittedName.size()  == 1) {
                                    withCompletedSuffixAttachments.add(attchmnt.name);
                                }
                            }
                            else {
                                withoutCompletedSuffixAttachments.add(attchmnt.name);
                            }
                        }
                        
                        if(!isAttachmentPresent) {
                           newTpaReqMap.get(tpaRequest.Id).Request_Status__c = oldTpaReqMap.get(tpaRequest.Id).Request_Status__c;
                           newTpaReqMap.get(tpaRequest.Id).addError('TPA Request does not have any Attachments');
                        }

                        for(String  att : withoutCompletedSuffixAttachments) {
                            if((att.toLowerCase().indexOf('tlla') != -1)&& (att.indexOf('IQVIA Third Party Tech') == -1)) {
                                Boolean isAMA = false;
                                for(String templateName : oldAMATemplateNames) {
                                    previousNameTemplate = previousYear +' ' +templateName.toLowerCase();
                                    currentNameTemplate = currentYear +' ' +templateName.toLowerCase();
                                    nextNameTemplate = nextYear +' ' +templateName.toLowerCase();
                                    if( att.toLowerCase().indexOf(previousNameTemplate) != -1 
                                    || att.toLowerCase().indexOf(currentNameTemplate) != -1 
                                    || att.toLowerCase().indexOf(nextNameTemplate) != -1) {
                                        isAMA = true;
                                        break;
                                    }
                                }

                                if(isAMA) {
                                    if(!isAMAOldSentPresent) {
                                        isOldAMADocRequired = true;
                                        isAMAOldSentPresent = true;
                                        sentOldAMA = att;
                                        if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                                            errorString += '<br/> AMA Document Name - ' + att + ' :TPA Request Number is Invalid';
                                        }
                                    }
                                }
                                else {
                                    if(!isTLLASentPresent) {
                                        isTLLASentPresent = true;
                                        sentTLLA = att;
                                        if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                                            errorString += '<br/> TLLA Document Name - ' + att + ' :TPA Request Number is Invalid';
                                        }
                                    }
                                }
                                continue;
                            }
                            if(att.toLowerCase().indexOf('ama_') != -1 && UTL_TPA.isAmaDoc(att.toLowerCase()) && !isAMASentPresent && isNewAMADocRequired) {
                                isAMASentPresent = true;
                                sentAMA = att;
                                if(att.toLowerCase().indexOf(tpaRequestName) == -1 && att.toLowerCase().indexOf(amaContractType) == -1) {
                                    errorString += '<br/> AMA Document Name - ' + att + ' :TPA Request Number and Contract Type is Invalid';
                                }
                                else if(att.toLowerCase().indexOf(amaContractType) == -1) {
                                    errorString += '<br/> AMA Document Name - ' + att + ' :Contract Type is Invalid';
                                }
                                else if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                                    errorString += '<br/> AMA Document Name - ' + att + ' :TPA Request Number is Invalid';
                                }
                                continue;
                            }
                            if(att.toLowerCase().indexOf('ama_') != -1  && UTL_TPA.isAmaFLDoc(att.toLowerCase()) && !isAMAFLSentPresent && isAMAFLDocRequired)
                            {
                                    isAMAFLSentPresent = true;
                                    sentAMAFL = att;
                            }
                            if(att.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1 ){
                                isHelpfulHintSent = true;
                                sentHelpful = att;
                            }
                        }

                        if(!isTLLASentPresent) {
                            errorString += '<br/> TLLA Document Name - :TPA Request does not have TLLA Document';
                        }
                        if(!isHelpfulHintSent){
                            errorString += '<br/> Helpful Hint Document Name - :TPA Request does not have Helpful Hint Document';
                        }
                        if((!isAMASentPresent && isNewAMADocRequired) || (!isAMAOldSentPresent && isOldAMADocRequired)) {
                            errorString += '<br/> AMA Document Name - :TPA Request does not have AMA Document';
                        }

                        for(String att : withCompletedSuffixAttachments) {
                            System.debug('Completed Doc names are:'+att);
                            if((att.toLowerCase().indexOf('tlla') != -1) && (att.indexOf('IQVIA Third Party Tech') == -1)) {
                                Boolean isAMA = false;
                                for(String templateName : oldAMATemplateNames) {
                                    previousNameTemplate = previousYear +' ' +templateName.toLowerCase();
                                    currentNameTemplate = currentYear +' ' +templateName.toLowerCase();
                                    nextNameTemplate = nextYear +' ' +templateName.toLowerCase();
                                    System.debug('Previous Names::::'+previousNameTemplate);
                                    System.debug('Current Names::::'+currentNameTemplate);
                                    System.debug('Next Names::::'+nextNameTemplate);
                                    if( att.toLowerCase().indexOf(previousNameTemplate) != -1 
                                    || att.toLowerCase().indexOf(currentNameTemplate) != -1 
                                    || att.toLowerCase().indexOf(nextNameTemplate) != -1) {
                                        isAMA = true;
                                        break;
                                    }
                                }
                                if(isAMA) {
                                    if(!isAMAOldCompletePresent) {
                                        isAMAOldCompletePresent = true;
                                        if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                                            errorString += '<br/> AMA Completed Document Name - ' + att + ' :TPA Request Number is Invalid';
                                        }
                                    }
                                }
                                else {
                                    if(!isTLLACompletePresent) {
                                        isTLLACompletePresent = true;
                                        if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                                            errorString += '<br/> TLLA Completed Document Name - ' + att + ' :TPA Request Number is Invalid';
                                        }
                                    }
                                }
                                continue;
                            }
                            if(att.toLowerCase().indexOf('ama_') != -1 && UTL_TPA.isAmaDoc(att.toLowerCase()) && !isAMACompletePresent && isNewAMADocRequired) {
                                isAMACompletePresent = true;
                                if(att.toLowerCase().indexOf(tpaRequestName) == -1 && att.toLowerCase().indexOf(amaContractType) == -1) {
                                    errorString += '<br/> AMA Completed Document Name - ' + att + ' :TPA Request Number and Contract Type is Invalid';
                                }
                                else if(att.toLowerCase().indexOf(amaContractType) == -1) {
                                    errorString += '<br/> AMA Completed Document Name - ' + att + ' :Contract Type is Invalid';
                                }
                                else if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                                    errorString += '<br/> AMA Completed Document Name - ' + att + ' :TPA Request Number is Invalid';
                                }
                                continue;
                            }
                            if(att.toLowerCase().indexOf('ama_') != -1 && UTL_TPA.isAmaFLDoc(att.toLowerCase()) && !isAMAFLCompletePresent && isAMAFLDocRequired) 
                            {
                                isAMAFLCompletePresent = true;
                                continue;
                            } 
                            if(att.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1 && att.indexOfIgnoreCase('completed') != -1 && !isHelpfulHintCompletedAttached){
                                isHelpfulHintCompletedAttached = true;
                                if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                                    errorString += '<br/> Helpful Hint Completed Document Name - ' + att + ' :TPA Request Number is Invalid';
                                }
                            }
                        }

                        if(isTLLASentPresent && !isTLLACompletePresent) {
                            errorString += '<br/> TLLA Document Name - ' + sentTLLA + ' :Completed Document is missing';
                        }
                        if(isAMASentPresent && !isAMACompletePresent && isNewAMADocRequired) {
                            errorString += '<br/> AMA Document Name - ' + sentAMA + ' :Completed Document is missing';
                        }
                        if(isAMAOldSentPresent && !isAMAOldCompletePresent && isOldAMADocRequired) {
                            errorString += '<br/> AMA Document Name - ' + sentOldAMA + ' :Completed Document is missing';
                        }
                        if(isAMAFLSentPresent && !isAMAFLCompletePresent) {
                            errorString += '<br/> AMA Foreign License Document Name - ' + sentAMAFL + ' :Completed Document is missing'; 
                        }
                        if(isHelpfulHintSent && !isHelpfulHintCompletedAttached){
                            errorString += '<br/> Helpful Hint Document Name - ' + sentHelpful + ' :Completed Document is missing';
                        }    
                        if(errorString.length() >0 ) {
                            newTpaReqMap.get(tpaRequest.Id).Request_Status__c = oldTpaReqMap.get(tpaRequest.Id).Request_Status__c;
                            newTpaReqMap.get(tpaRequest.Id).addError(errorString,false);
                        }
                    //}
                    /*else {
                        newTpaReqMap.get(tpaRequest.Id).Request_Status__c = oldTpaReqMap.get(tpaRequest.Id).Request_Status__c;
                        newTpaReqMap.get(tpaRequest.Id).addError('TPA Request does not have any Attachments');
                    }*/
                }
            }
            
            Boolean isEntityPresent = true;

            for(TPA_Secondary_Data_Asset__c objSecAssest : tpaRequest.TPA_Tertiary_Data_Assets__r ) {
               	PriDataAssetIdWithSecData.add(objSecAssest.TPA_Data_Asset__c);
               	if(objSecAssest.IMS_Legal_Entity__c == null) {
                    isEntityPresent = false;
                    break;
                }
            }
            if(isEntityPresent){
            for(TPA_Data_Asset__c objAsset : tpaRequest.Data_Assets__r) {
            	if(!PriDataAssetIdWithSecData.contains(objAsset.id)) {
                	if(objAsset.IMSLegalEntity__c == null) {
                    	isEntityPresent = false;
                    	break;
                    }
                }
            }
            }
            

            if(!isEntityPresent) {
                newTpaReqMap.get(tpaRequest.Id).isLegalEntityPresent__c = true;
            }
            else {
                newTpaReqMap.get(tpaRequest.Id).isLegalEntityPresent__c = false;
            }
                        
            Date agreementSentForSignatureDate;
            Date todayDate = Date.today();
            
            if( newTpaReqMap.get(tpaRequest.Id).Sent_for_Signature__c != null 
            && oldTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Awaiting Vendor Signature' 
            && newTpaReqMap.get(tpaRequest.Id).Request_Status__c == 'Awaiting Vendor Signature' 
            && oldTpaReqMap.get(tpaRequest.Id).Prevent_Cancellation__c 
            && !newTpaReqMap.get(tpaRequest.Id).Prevent_Cancellation__c) {
                agreementSentForSignatureDate = date.newinstance(newTpaReqMap.get(tpaRequest.Id).Sent_for_Signature__c.year(), newTpaReqMap.get(tpaRequest.Id).Sent_for_Signature__c.month(), newTpaReqMap.get(tpaRequest.Id).Sent_for_Signature__c.day());
                if(agreementSentForSignatureDate.daysBetween(todayDate) == 60) {
                    newTpaReqMap.get(tpaRequest.Id).Request_Status__c = 'Cancelled';
                }
            }
        }
        }

        updateStatusChangeDates(newTpaReqList, oldTpaReqMap);
        return true;
    } 

    public void onBeforeDelete(List<TPA_Request__c> oldTpaReqList) {
        if(!UTL_TPA.modifyRequest) {
            for(TPA_Request__c tpaRequest : oldTpaReqList) {
                tpaRequest.addError('You do not have necessary permissions to delete the record.');
            }
        }
    }

    public void onAfterInsert(List<TPA_Request__c> newTPARequestList) {
        Boolean toCommit = false;
        dataMailSent = false;
        for(TPA_Request__c tpaRequest : newTPARequestList) {
            TPA_Request__c tpaRequestToUpdate = new TPA_Request__c(Id = tpaRequest.Id);
            TPA_Request__c tpaReqForAgrName = SRV_TPA_TPARequest.getRequestInfo(tpaRequest.Id);// change this query with used fields only and put before for loop using a map
            if(tpaRequest.Name == null || tpaRequest.Name == tpaRequest.Id) {
                system.debug('onAfterInsert @@@@');
                tpaRequestToUpdate.Name = (String)tpaRequest.get('TPA_Request_Number__c');
                tpaRequestToUpdate.Agreement_Name__c = getAgreementName(tpaReqForAgrName);
                toCommit = true;
                uow.registerDirty(tpaRequestToUpdate);
            }
        }
        if(toCommit) {
            uow.commitWork(); 
        }
    }

    public Boolean onAfterUpdate(List<TPA_Request__c> newTpaReqList, List<TPA_Request__c> oldTpaReqList, Map<Id,TPA_Request__c> newTpaReqMap, Map<Id,TPA_Request__c> oldTpaReqMap) {
        system.debug('TGRH_TPA_AgreementAdditionalField.isPartiallyRenewed: ' + TGRH_TPA_AgreementAdditionalField.isPartiallyRenewed);
        if(TGRH_TPA_AgreementAdditionalField.isPartiallyRenewed) {
            TGRH_TPA_AgreementAdditionalField.isPartiallyRenewed = false;
            return false;
        }
        if(UTL_TPA.isPurposeUpdateCalled) {
            return false;
        }
        Set<Id> stAgreementCancelled = new Set<Id>(); 
        Set<Id> voidResubmittedReq = new Set<Id>(); 
        Set<Id> CancelledReq = new Set<Id>(); 
        Set<Id> reqSet = new Set<Id>();
        Set<Id> requestIdSet = new Set<ID>();
        List<Vendor_Offering_Return_Acknowledgment__c> deleteOffReturnAckList = new List<Vendor_Offering_Return_Acknowledgment__c>();
        
        for(TPA_Request__c req : newTpaReqMap.values()) {
            if(req.Parent_Request__c != null
            && req.Request_Status__c == 'Cancelled' 
            && oldTpaReqMap.get(req.Id).Request_Status__c != 'Cancelled') {
                Map<String, TPA_request__c> parentRequestMap = new Map<String, TPA_request__c>([SELECT Id, Name, Request_Status__c, Parent_Request__c, Renewed_As__c, Parent_Request__r.Renewed_As__c,Is_Renewed__c,Renewed_On__c, (SELECT Id, Early_Contract_Expiry_Date__c FROM TPA_Agreement_Additional_Fields__r LIMIT 1),
                (select Id, TPA_Request__c, ActionTaken__c from Vendor_Offering_Return_Acknowledgments__r) FROM TPA_Request__c WHERE Renewed_As__c IN :newTpaReqMap.keySet() AND Is_Renewed__c = true AND In_Effect_Date__c != null ]);                

                TPA_Request__c parentReq = parentRequestMap.get(req.Parent_Request__c);
                system.debug('IN Cancelled parentReq' + parentReq);
                if(parentReq != null
                && parentReq.Request_Status__c == 'Expired'
                && parentReq.TPA_Agreement_Additional_Fields__r != null
                && parentReq.TPA_Agreement_Additional_Fields__r.size() > 0){
                    system.debug('IN Cancelled');
                    if(parentReq.Vendor_Offering_Return_Acknowledgments__r != null && parentReq.Vendor_Offering_Return_Acknowledgments__r.size() > 0) {
                        if(parentReq.Vendor_Offering_Return_Acknowledgments__r[0].ActionTaken__c != null) {
                            deleteOffReturnAckList.add(parentReq.Vendor_Offering_Return_Acknowledgments__r);
                        }
                    }
                    CNT_TPA_ContinueNotificationProcess.sendDDNMail(parentReq.TPA_Agreement_Additional_Fields__r[0].Id, true);
                }
            }
            
            //will review, in tp processor case start
            if(((req.TPA_Assigned_TP_Processor__c != null && req.TPA_Assigned_TP_Processor__c != oldTpaReqMap.get(req.Id).TPA_Assigned_TP_Processor__c) || (req.Co_Assigned_Global_TP_Processor__c != null && req.Co_Assigned_Global_TP_Processor__c != oldTpaReqMap.get(req.Id).Co_Assigned_Global_TP_Processor__c)) 
            && (req.Request_Status__c == UTL_TPA.AWAITING_CLIENT_CONFIRMATION
            || req.Request_Status__c == 'Pending Vendor Response on Data Destruction from Prior TPAs'
            || req.Request_Status__c == 'TPA Approved Awaiting AMA Approval' 
            || req.Request_Status__c == Label.TPA_In_Review_By_IQVIA_Status)) {
                SRV_TPA_TPARequest.isDynamicNotificationRequiredForVendor(req);
                SRV_TPA_TPARequest.retriggerManualReviewMail(req); 
            }
            //will review, in tp processor case end            
        }
        if(deleteOffReturnAckList != null && deleteOffReturnAckList.size() > 0){
            delete deleteOffReturnAckList;
        }        

        for(Id id: newTpaReqMap.keySet()) {
            requestIdSet.add(id);
            if( newTpaReqMap.get(id).Request_Status__c != oldTpaReqMap.get(id).Request_Status__c 
             && ((newTpaReqMap.get(id).Request_Status__c.equalsIgnoreCase(UTL_TPA.IN_EFFECT) 
             && oldTpaReqMap.get(id).Request_Status__c.equalsIgnoreCase(UTL_TPA.SIGNATURE_UNDER_VALIDATION))
              ||(newTpaReqMap.get(id).Request_Status__c.equalsIgnoreCase(UTL_TPA.IN_EFFECT) 
             && oldTpaReqMap.get(id).Request_Status__c.equalsIgnoreCase(UTL_TPA.AWAITING_VENDOR_SIGNATURE)))) {
                reqSet.add(id);
            }
            if( newTpaReqMap.get(id).Request_Status__c != oldTpaReqMap.get(id).Request_Status__c 
             && ( newTpaReqMap.get(id).Request_Status__c.contains('Vendor Canceled') 
               || newTpaReqMap.get(id).Request_Status__c.equalsIgnoreCase('Cancelled') 
               || newTpaReqMap.get(id).Request_Status__c.equalsIgnoreCase('AMA Cancelled') 
               || newTpaReqMap.get(id).Request_Status__c.equalsIgnoreCase('AMA Discontinued') 
               || newTpaReqMap.get(id).Request_Status__c.equalsIgnoreCase('Client Discontinued') 
               || newTpaReqMap.get(id).Request_Status__c.equalsIgnoreCase('Vendor Discontinued'))) {
                reqSet.add(id);
            }
        }

        Map<id, List<AMA_Agreement_Detail__c>> childDetailMap = new Map<id, List<AMA_Agreement_Detail__c>>();
        Map<id, List<Task>> amaAgreeWithTasks = new Map<id,List<Task>>();
        Set<id> amaAgreeIds = new Set<id>();
        Map<id, List<Attachment>> listAttachmentMap = new Map<id, List<Attachment>>();
        Map<Id, AMA_Agreement_Detail__c> amaAgrtoUpdate;

        if(!reqSet.isEmpty()) {
            List<AMA_Agreement_Detail__c> amaAgrDetailList = [SELECT id, 
                                                                     Vendor_Legal_Name__c, 
                                                                     Client__c, 
                                                                     TPA_Request__c, 
                                                                     TPA_Request__r.name,
                                                              		 TPA_Request__r.Service_Provider_Address__c,
                                                              		 TPA_Request__r.Service_Provider_Address__r.Country__c,
                                                              		 TPA_Request__r.TPA_Assigned_TP_Processor__c,
                                                              		 TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c,
                                                              		 TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c,
                                                             		 TPA_Request__r.Co_Assigned_Global_TP_Processor__c,
                                                            		 TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,
                                                             		 TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c,
                                                              		 TPA_Request__r.ClientContact__c,
                                                              		 TPA_Request__r.TP_Processor_Email__c,
                                                              		 TPA_Request__r.Vendor_Compliance_Email__c,
                                                              		 TPA_Request__r.Vendor_Contact_e_mail__c,
                                                              		 TPA_Request__r.Authorized_Signer_Email__c,
                                                              		 TPA_Request__r.Vendor_Contact_Email_Client__c,
                                                              		 TPA_Request__r.Service_provider_Address__r.TPAOtherEmailIds__c,
                                                              		 TPA_Account_SAP_Code__c,
                                                                     Next_Year_Fees__c, 
                                                                     Current_Year__c,
                                                              		 Current_Year_Fees__c
                                                              FROM AMA_Agreement_Detail__c 
                                                              where TPA_Request__c IN :reqSet];

            for(AMA_Agreement_Detail__c amaObj: amaAgrDetailList) {
                List<AMA_Agreement_Detail__c> childList = new List<AMA_Agreement_Detail__c>();
                if(childDetailMap.containsKey(amaObj.TPA_Request__c)) {
                    childList = childDetailMap.get(amaObj.TPA_Request__c);
                }
                childList.add(amaObj);
                childDetailMap.put(amaObj.TPA_Request__c, childList);
                amaAgreeIds.add(amaObj.Id);
            }

            for(Task tsk:[Select ActivityDate, Subject, Description,WhatId  from Task where WhatId in: amaAgreeIds ORDER BY ActivityDate DESC , LastModifiedDate DESC]){
                List<Task> allTask = new List<Task>();
                if(amaAgreeWithTasks.containsKey(tsk.WhatId)){
                    allTask = amaAgreeWithTasks.get(tsk.WhatId);
                }
                allTask.add(tsk);
                amaAgreeWithTasks.put(tsk.WhatId,allTask);
            }

            List<Attachment> listAttachment = [select Id, Name, Body, ParentId, ContentType
                                               from Attachment 
                                               where ParentId IN :reqSet and (Name like 'AMA_%TPA%.pdf_Completed')];
            for(Attachment attObj: listAttachment) {
                List<Attachment> lstAttach = new List<Attachment>();
                if(listAttachmentMap.containsKey(attObj.ParentId)) {
                    lstAttach = listAttachmentMap.get(attObj.ParentId);
                }
                lstAttach.add(attObj);
                listAttachmentMap.put(attObj.ParentId, lstAttach);
            }
        }
        
        if(isCreateActivity) {
            createActivityHistoryForVendor(newTpaReqList, oldTpaReqMap);
        }

        for(TPA_Request__c tpaRequest: newTpaReqList) {
            System.debug('####update called');
            if( tpaRequest.Request_Status__c != oldTpaReqMap.get(tpaRequest.id).Request_Status__c 
             && (tpaRequest.Request_Status__c == 'Cancelled' || tpaRequest.Request_Status__c == 'Expired'  )) {
                System.debug('####in the void envelope');
                stAgreementCancelled.add(tpaRequest.Id);
            }
            
            if( tpaRequest.Request_Status__c != oldTpaReqMap.get(tpaRequest.id).Request_Status__c 
             && oldTpaReqMap.get(tpaRequest.id).Request_Status__c == 'Awaiting Vendor Signature' 
             && (tpaRequest.Request_Status__c == 'Awaiting Vendor Submission' 
             || tpaRequest.Request_Status__c == 'In Review by IQVIA' 
             || tpaRequest.Request_Status__c == 'In Auto Approval Process'
             || tpaRequest.Request_Status__c == 'Client Submitted')){
                voidResubmittedReq.add(tpaRequest.Id);
                system.debug('####In the void envelope call');
            } 

            if( tpaRequest.Request_Status__c != oldTpaReqMap.get(tpaRequest.id).Request_Status__c 
             && ( tpaRequest.Request_Status__c.contains('Vendor Canceled')  
               || tpaRequest.Request_Status__c == 'AMA Cancelled' 
               ||tpaRequest.Request_Status__c == 'Cancelled' 
               || tpaRequest.Request_Status__c == 'AMA Discontinued' 
               || tpaRequest.Request_Status__c == 'Client Discontinued' 
               || tpaRequest.Request_Status__c == 'Vendor Discontinued')) {
                CancelledReq.add(tpaRequest.Id);
                system.debug('####In the cancel call');
            }

            if( CancelledReq.size() > 0 && childDetailMap.size() > 0) {
                List<AMA_Agreement_Detail__c> amaAgrList =  childDetailMap.get(tpaRequest.id);
                if(amaAgrList != null && amaAgrList.size() > 0) {
                    for(AMA_Agreement_Detail__c  amaChildObj: amaAgrList) {
                        if( amaChildObj.Next_Year_Fees__c != null 
                        && amaChildObj.Next_Year_Fees__c > 0  
                        && Integer.valueOf(amaChildObj.Current_Year__c) == Date.today().year()) {
                            amaChildObj.Next_Year_Fees__c = 0;
                            if(amaAgrtoUpdate == null) {
                                amaAgrtoUpdate = new Map<Id, AMA_Agreement_Detail__c>();
                            }
                            amaAgrtoUpdate.put(amaChildObj.id, amaChildObj);
                        }
                    }
                }
            }

            if(amaAgrtoUpdate != null && amaAgrtoUpdate.size() > 0) {
                update amaAgrtoUpdate.values();
            }
            
            System.debug('#####Request Status' + tpaRequest.Request_Status__c);

            if(tpaRequest.Request_Status__c == 'In Effect') {
                if( tpaRequest.Request_Status__c != oldTpaReqMap.get(tpaRequest.id).Request_Status__c  
                 && oldTpaReqMap.get(tpaRequest.id).Request_Status__c.equalsIgnoreCase(UTL_TPA.SIGNATURE_UNDER_VALIDATION)) {
                    List<Attachment> lstAttachment = new List<Attachment>();
                    lstAttachment =  listAttachmentMap.get(tpaRequest.id);
                    if(lstAttachment != null && lstAttachment.size() > 0) {
                        Boolean dblExecutedMailSent = false;
                        List<AMA_Agreement_Detail__c> amaAgrList =  childDetailMap.get(tpaRequest.id);
                        List<Task> activityHistories = new List<Task>();
                        for(AMA_Agreement_Detail__c es: amaAgrList) {
                            activityHistories = amaAgreeWithTasks.get(es.Id);
                            system.debug('es: ***'+es);
                            string dblExecutedMailSubject = UTL_TPA.DBL_EXECUTED_MAIL_SUBJECT.replace('vendorLegalName', es.Vendor_Legal_Name__c).replace('clientName',es.Client__c ).replace('tpaRequestNo',es.TPA_Request__r.name );
                            system.debug('dblExecutedMailSent: ***'+ dblExecutedMailSubject + activityHistories);
                            if(activityHistories != null){
                                for(Task ah: activityHistories) {
                                    if(ah.Subject != null && ah.Subject.equalsIgnoreCase(dblExecutedMailSubject)) {
                                        dblExecutedMailSent = true;
                                    }
                                }
                            }
                        }
                        if(!dblExecutedMailSent) {
                            sendMailToDblForExecutedAmaAgreement(tpaRequest.Id);
                        }
                    }
                }
                
                if( tpaRequest.Request_Status__c != oldTpaReqMap.get(tpaRequest.id).Request_Status__c 
                 && ( (  tpaRequest.Request_Status__c == 'In Effect' 
                      && oldTpaReqMap.get(tpaRequest.id).Request_Status__c == 'Awaiting Vendor Signature'
                      ) 
                    || 
                      (  tpaRequest.Request_Status__c == 'In Effect' 
                      && oldTpaReqMap.get(tpaRequest.id).Request_Status__c == 'Signature Under Validation'
                      )
                    )
                 && !dataMailSent) {
                    System.debug('###in the mail sent method');
                    //TPA_TriggerHelper_DSRecipientStatus.sendDataAuthorizationForAgreement(tpaRequest);
                    sendAgreementsForDataAuthorizationMail(tpaRequest);
                } 
                
                if( tpaRequest.Request_Status__c != oldTpaReqMap.get(tpaRequest.id).Request_Status__c 
                 && !dataMailSent) {
                    dataMailSent = true;
                    SRV_TPA_TPARequest.updateActivityHistory(tpaRequest.Id, 'Agreement Activated', true);
                }
                /*if((tpaRequest.Request_Status__c != oldTpaReqMap.get(tpaRequest.id).Request_Status__c && childDetailMap.get(tpaRequest.id) != null )){
                    AMA_Agreement_Detail__c amaAgreement = childDetailMap.get(tpaRequest.id)[0];
                    if( (amaAgreement != null)
                       && ((amaAgreement.Current_Year_Fees__c != null && amaAgreement.Current_Year_Fees__c > 0) || (amaAgreement.Next_Year_Fees__c != null && amaAgreement.Next_Year_Fees__c > 0))
                       && (amaAgreement.TPA_Account_SAP_Code__c == null || amaAgreement.TPA_Account_SAP_Code__c == '')
                       && (amaAgreement.TPA_Request__c != null && amaAgreement.TPA_Request__r.Service_Provider_Address__c != null && amaAgreement.TPA_Request__r.Service_Provider_Address__r.Country__c != null && amaAgreement.TPA_Request__r.Service_Provider_Address__r.Country__c != 'USA')
                       && listAttachmentMap.get(amaAgreement.TPA_Request__c) != null){
                           sendGSTINInvoiceMail(amaAgreement,listAttachmentMap.get(amaAgreement.TPA_Request__c)[0]); 
                       }
                }*/
            }
        }

        if(stAgreementCancelled.size() > 0 && !UTL_TPA.isEnvelopeVoided) {
            SRV_TPA_DocusignEnvelope.voidEnvelope(stAgreementCancelled, ''); 
        }

        if(!Test.isRunningTest() && voidResubmittedReq.size() > 0 && !UTL_TPA.isEnvelopeVoided) {
            voidEnvelopeCall(voidResubmittedReq, 'Resubmission Void Reason');
        }
        
        Map<Id, String> tpaRequestIdAgreementCategoryMap = new Map<Id, String>();
        Map<Id, TPA_Request__c> tpaRequestToUpdate;
        Set<Id> tparequestIds = new Set<Id>();        
        
        for(TPA_Request__c tpaReq: newTpaReqList) {
            system.debug('tpaReq.Client_Address__c.Name11' +tpaReq.Client_Address__c +'  ' +oldTpaReqMap.get(tpaReq.id).Client_Address__c);
            
            if(tpaReq.Client_Address__c != oldTpaReqMap.get(tpaReq.id).Client_Address__c) {
                system.debug('Client Activity History');
                SRV_TPA_TPARequest.updateActivityHistory(tpaReq.Id, 'Client Updated', true);
            }            
            
            if( tpaReq.In_Effect__c != oldTpaReqMap.get(tpaReq.id).In_Effect__c 
             || tpaReq.Data_Access_End_Date__c != oldTpaReqMap.get(tpaReq.id).Data_Access_End_Date__c 
             || tpaReq.Data_Access_Start_Date__c != oldTpaReqMap.get(tpaReq.id).Data_Access_Start_Date__c 
             || tpaReq.OwnerId != oldTpaReqMap.get(tpaReq.id).OwnerId 
             || tpaReq.Client_Address__c != oldTpaReqMap.get(tpaReq.id).Client_Address__c 
             || tpaReq.ClientContact__c != oldTpaReqMap.get(tpaReq.id).ClientContact__c 
             || tpaReq.TP_Processor_Email__c != oldTpaReqMap.get(tpaReq.id).TP_Processor_Email__c) {
                system.debug('tpaReq.Client_Address__c.Name1' +tpaReq.Client_Address__c +'  ' +oldTpaReqMap.get(tpaReq.id).Client_Address__c);
                tparequestIds.add(tpaReq.Id);
            }
        }
        
        if(tparequestIds != null && tparequestIds.size() > 0) {
            system.debug('tparequestIds ' +tparequestIds );
            for(TPA_Request__c req : [Select Id,
                                             Request_Status__c,
                                             TP_Processor_Email__c,
                                             TPA_Request_Marked_as__c, 
                                             Data_Access_End_Date__c,
                                             Data_Access_Start_Date__c, 
                                             OwnerId, 
                                             Client_Address__c, 
                                             ClientContact__c, 
                                             Client_Company_Name_Address__c 
                                      from TPA_Request__c 
                                      where Id IN : tparequestIds]) {
                if(tpaRequestToUpdate != null && tpaRequestToUpdate.get(req.Id) != null) {
                    req = tpaRequestToUpdate.get(req.Id);
                    system.debug('Private case');
                }
                else if(tpaRequestToUpdate == null) {
                    tpaRequestToUpdate = new Map<Id, TPA_Request__c>();
                    system.debug('public case');
                }
                
                for(TPA_Request__c newReq:  newTpaReqList) {//TODO: will review
                    if( newReq.Data_Access_End_Date__c != req.Data_Access_End_Date__c 
                     || newReq.Data_Access_Start_Date__c != req.Data_Access_Start_Date__c 
                     || newReq.OwnerId != req.OwnerId 
                     || newReq.Client_Address__c != req.Client_Address__c 
                     || newReq.ClientContact__c != req.ClientContact__c 
                     || newReq.Client_Address__c != req.Client_Company_Name_Address__c 
                     || newReq.TP_Processor_Email__c != req.TP_Processor_Email__c 
                     || newReq.Request_Status__c != req.Request_Status__c
                    ) {
                        if(req.TPA_Request_Marked_as__c == 'Public') {
                            req.Client_Company_Name_Address__c = newReq.Client_Address__c;
                        }
                        system.debug('req.Client_Company_Name_Address__c ' +req.Client_Company_Name_Address__c +' ' + newReq.Client_Address__c);
                        if(req.Request_Status__c != 'In Effect' || (req.Request_Status__c == 'In Effect' && UTL_TPA.modifyRequest)) {
                            tpaRequestToUpdate.put( req.Id, req );
                        }
                    }
                }
            }
        }
        
        if(tpaRequestToUpdate != null && tpaRequestToUpdate.size() > 0 ) {
            update tpaRequestToUpdate.values();
        }

        List<TPA_Request__c> aggToBeUpdated = new List<TPA_Request__c>();
        Map<Id, TPA_Master_Extension_Information__c> masterExtensionObjMap = new Map<Id, TPA_Master_Extension_Information__c>();

        Map<String,Address__C> mapRequestToAddress;
        Map<TPA_Request__c,Set<String>> mapRequestToEmailIds = new Map<TPA_Request__c,Set<String>>();
        for(TPA_Request__c tpaReq : [Select Id, 
                                            Name,
                                            Client_Address__r.Name,
                                            Data_Access_Start_Date__c,
                                            Data_Access_End_Date__c,
                                            Client_Address__r.Region_Territory__c,
                                            Expiration_Date__c,
	                                        Client_Expired_Early__c,
                                            Service_Provider_Address__c, 
                                            Service_Provider_Address__r.Name,
                                            Vendor_First_Name__c,
                                            Vendor_Contact_Last_Name__c,
                                            Docusign_Custom_Textbox__c, 
                                            In_Effect__c,
                                            AMA_Agreement_required__c,
                                            (select id, Is_AMA_License_Required__c, Purchase_order_number__c, Date_Agreement_Activated__c, Agreement_Start_Date__c  
                                             from AMA_Agreement_Details__r LIMIT 1),
                                            Request_Status__c,
                                            Client_Contact_Territory__c,
                                            Secondary_Client_Contact_Territory__c,
                                            client_language__c, 
                                            In_Effect_Date__c,
                                            vendor_language__c,
                                            TP_Processor_Email__c,
                                            TPA_Assigned_TP_Processor__r.Initials__c,
                                     	    TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, 
                                            (Select Id,Name,Receiver_s_Email__c From TPA_Commercial_Reviews__r)
                                     from TPA_Request__c 
                                     where Id IN : newTpaReqList]) {
            system.debug('in On hold check');
            system.debug('tpareq Name: ' + tpareq.Name);
            
            if(newTPAReqMap.get(tpaReq.Id).Request_Status__c == 'Cancelled' 
            && (oldTpaReqMap.get(tpaReq.Id).Request_Status__c =='In Review By IQVIA' || oldTpaReqMap.get(tpaReq.Id).Request_Status__c =='TPA Approved Awaiting AMA Approval'
            || oldTpaReqMap.get(tpaReq.Id).Request_Status__c =='Pending Vendor AMA Fee Acknowledgement' || oldTpaReqMap.get(tpaReq.Id).Request_Status__c =='Pending - Vendor Declined AMA Fees')){
                Set<String> emailIds = new Set<String>();
                TPA_Settings__c tpaCustomSettings = UTL_TPA.tpaSetting;
                emailIds.add(tpaReq.TP_Processor_Email__c);
                emailIds.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(','));
                for(TPA_Commercial_Review__c comRev: tpaReq.TPA_Commercial_Reviews__r){
                    if(comRev.Receiver_s_Email__c != null && comRev.Receiver_s_Email__c != ''){
                        for(String emailtoAdd : comRev.Receiver_s_Email__c.split(';')){
                            if(!emailIds.contains(emailtoAdd)){
                                emailIds.add(emailtoAdd);
                            }
                            if(emailIds.size() == 50){
                                break;
                            }
                        }
                    }
                    if(emailIds.size() == 50){
                        break;
                    }
                }
                mapRequestToEmailIds.put(tpaReq,emailIds);
            }

            Address__c globalAddress;
            TPA_Master_Extension_Information__c masterExtensionObj;
            string onHoldRequests = '';
            if((tpaReq.Request_Status__c == 'Pending Vendor Response on Data Destruction from Prior TPAs'
            || oldTpaReqMap.get(tpaReq.id).Request_Status__c == 'Pending Vendor Response on Data Destruction from Prior TPAs')
            && tpaReq.Request_Status__c != oldTpaReqMap.get(tpaReq.id).Request_Status__c) {
                mapRequestToAddress = UTL_TPA.getRequestToAddress(requestIdSet);
                if(mapRequestToAddress != null) {
                    globalAddress = mapRequestToAddress.get(tpaReq.Id + '-GBVendor');
                    if(globalAddress != null && globalAddress.TPA_Master_Extension_Informations__r.size() > 0) {
                        masterExtensionObj = globalAddress.TPA_Master_Extension_Informations__r[0];
                    }
                    system.debug('masterExtensionObj' + masterExtensionObj);
                    if(masterExtensionObj != null) {
                        if(masterExtensionObjMap.containsKey(masterExtensionObj.id)) {
                            onHoldRequests = masterExtensionObjMap.get(masterExtensionObj.Id).On_Hold_TPA_Requests__c;
                        }       
                        else {
                            onHoldRequests = masterExtensionObj.On_Hold_TPA_Requests__c;
                        }
                    }
                    system.debug('onHoldRequests:1 ' + onHoldRequests);
                    
                }
            }
            
            if(tpaReq.Request_Status__c == 'Pending Vendor Response on Data Destruction from Prior TPAs'
               && tpaReq.Request_Status__c != oldTpaReqMap.get(tpaReq.id).Request_Status__c) {
                //system.debug('in On hold check111');
                if(onHoldRequests != ''  && onHoldRequests != null) {
                    if(!onHoldRequests.contains(tpaReq.Name)) {
                        system.debug('in On hold check222');
                        onHoldRequests += ', ' + tpaReq.Name;
                    }
                } else {
                    //system.debug('in On hold check444');
                    onHoldRequests = tpaReq.Name;
                }
                system.debug('onHoldRequests:2 ' + onHoldRequests);
                //TPA_Master_Extension_Information__c obj = new TPA_Master_Extension_Information__c(id=tpaReq.Vendor_Address_Extension_Record__c, On_Hold_TPA_Requests__c = onHoldRequests);
                if(masterExtensionObj != null) {
                    masterExtensionObj.On_Hold_TPA_Requests__c = onHoldRequests;
                    masterExtensionObjMap.put(masterExtensionObj.id, masterExtensionObj);
                }
            } else if (oldTpaReqMap.get(tpaReq.id).Request_Status__c == 'Pending Vendor Response on Data Destruction from Prior TPAs'
            && tpaReq.Request_Status__c != oldTpaReqMap.get(tpaReq.id).Request_Status__c) {
                //system.debug('in On hold check555');
                if(onHoldRequests != '' && onHoldRequests != null 
                  && onHoldRequests.contains(tpaReq.Name)) {
                    //system.debug('in On hold check6666');
                    List<String> onHoldTPAs = onHoldRequests.split(',');
                    onHoldRequests = ''; 
                    for(String reqName: onHoldTPAs) {
                        if(reqName.trim() != tpaReq.Name) {
                            onHoldRequests += reqName + ', ';
                        }                        
                    }
                    onHoldRequests = onHoldRequests.removeEnd(', ');
                    //TPA_Master_Extension_Information__c obj = new TPA_Master_Extension_Information__c(id=tpaReq.Vendor_Address_Extension_Record__c, On_Hold_TPA_Requests__c = onHoldRequests);
                    //masterExtensionObjList.add(obj);
                    if(masterExtensionObj != null) {
                        masterExtensionObj.On_Hold_TPA_Requests__c = onHoldRequests;
                        masterExtensionObjMap.put(masterExtensionObj.id, masterExtensionObj);
                    }
                }
            }

            if(masterExtensionObjMap.size() > 0) {
                isOnHoldFieldUpdate = true;
                update masterExtensionObjMap.values();
            }

            if(!tpaReq.AMA_Agreement_Details__r.isEmpty()) {
                Boolean needToUpdate = false;
                AMA_Agreement_Detail__c amaAgreementObject = tpaReq.AMA_Agreement_Details__r[0];
                if(amaAgreementObject.Date_Agreement_Activated__c != tpaReq.In_Effect_Date__c) {
                    amaAgreementObject.Date_Agreement_Activated__c = tpaReq.In_Effect_Date__c;
                    needToUpdate = true;
                }
                if(amaAgreementObject.Purchase_order_number__c != tpaReq.Docusign_Custom_Textbox__c) {
                    amaAgreementObject.Purchase_order_number__c = tpaReq.Docusign_Custom_Textbox__c;
                    needToUpdate = true;
                }
                if(amaAgreementObject.Agreement_Start_Date__c != tpaReq.Data_Access_Start_Date__c) {
                    amaAgreementObject.Agreement_Start_Date__c = tpaReq.Data_Access_Start_Date__c;
                    needToUpdate = true;
                }
                if(needToUpdate) {
                    Update amaAgreementObject;
                }
            }
            
            if( tpaReq.Service_Provider_Address__c != oldTpaReqMap.get(tpaReq.id).Service_Provider_Address__c
                || tpaReq.Vendor_First_Name__c != oldTpaReqMap.get(tpaReq.id).Vendor_First_Name__c
                || tpaReq.Vendor_Contact_Last_Name__c != oldTpaReqMap.get(tpaReq.id).Vendor_Contact_Last_Name__c
                || (tpaReq.Expiration_Date__c != oldTpaReqMap.get(tpaReq.id).Expiration_Date__c  && !tpaReq.Client_Expired_Early__c)
                || tpaReq.Data_Access_End_Date__c != oldTpaReqMap.get(tpaReq.id).Data_Access_End_Date__c
            ) {
                tpaReq.Expiration_Date__c = tpaReq.Data_Access_End_Date__c;
                tpaReq.Vendor_Name_f__c = tpaReq.Service_Provider_Address__r.Name;
                tpaReq.Vendor_Contact_Name_f__c = tpaReq.Vendor_First_Name__c + ' ' + tpaReq.Vendor_Contact_Last_Name__c; // Added by Sunny Bansal under ER-1799 on 14 April
                
                if(tpaReq.Request_Status__c != 'In Effect' || (tpaReq.Request_Status__c == 'In Effect' && UTL_TPA.modifyRequest)) {
                    aggToBeUpdated.add(tpaReq);
                }
            }
        }

        for(TPA_Request__c tpaReq: mapRequestToEmailIds.keySet()){
            sendCancellationMailtoTPProcessorAndCommercialOwners(tpaReq,mapRequestToEmailIds.get(tpaReq));
        }

        if( aggToBeUpdated.size() > 0 )
        {
            update aggToBeUpdated;
            isCreateActivity = false; // Added by Neetu Bansal under Issue-06739
        }

        // Call method to send awaiting signature email
        sendVendorSignatureEmail(newTpaReqMap, oldTpaReqMap);
        return true;
    }

    public void sendCancellationMailtoTPProcessorAndCommercialOwners(TPA_Request__c reqObj,Set<String> emailIds){
        List<String> toAddress = new List<String>(emailIds);
        String emailBody;
        String subjectText;
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA Cancel Email' + 'English').Translated_Template_Id__c;
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateID != '' && templateID != null) {  
            try {
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
            } catch(Exception exp) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::TGRH_TPARequest:::sendCancellationMailtoTPProcessorAndCommercialOwners:::', reqObj.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);    
            }
            emailBody = emailNotToSend.getHTMLBody();
            subjectText = emailNotToSend.getSubject();
    	}
        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/
        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, null, 'SendEmail', null, reqObj.Id, null, subjectText, FALSE, emailBody, TRUE, TRUE, reqObj); 
		//SRV_TPA_TPARequest.addTPProcessorInitials = false;
    }

    /**
     * This method is used to create Activity record when Vendor Legal name is changed
     * @param: newReqList - List of Requests to be updated
     *         oldReqMap - Map of old agreements which are to be updated
     *         Key - Request Id
     *         Value - Request Record
     **/
    public void createActivityHistoryForVendor(List<TPA_Request__c> newReqList, Map<Id, TPA_Request__c> oldReqMap) {
        Set<Id> serviceProviderIds = new Set<Id>();

        for(TPA_Request__c tpaRequest : newReqList) {
            System.debug('#####Service Provider1'+tpaRequest.Service_Provider_Address__c);
            System.debug('#####Service Provider2'+oldReqMap.get(tpaRequest.Id).Service_Provider_Address__c);
            if( tpaRequest.Service_Provider_Address__c != null
             && oldReqMap.get(tpaRequest.Id).Service_Provider_Address__c != null
             && tpaRequest.Service_Provider_Address__c != oldReqMap.get(tpaRequest.Id).Service_Provider_Address__c) {
                // Add old and new Vendors
                serviceProviderIds.add(tpaRequest.Service_Provider_Address__c);
                serviceProviderIds.add(oldReqMap.get(tpaRequest.Id).Service_Provider_Address__c);
            }
        }
        
        List<Task> tasksToBeInserted = new List<Task>();
        // Map of Vendors
        // Key - Vendor Id
        // Value - Vendor Record

        for( TPA_Request__c tpaRequest : newReqList ) {
            if( tpaRequest.Service_Provider_Address__c != null
               && oldReqMap.get(tpaRequest.Id).Service_Provider_Address__c != null
               && tpaRequest.Service_Provider_Address__c != oldReqMap.get(tpaRequest.Id).Service_Provider_Address__c ) {
                // Create new Activity and add into list
                Map<Id, Address__c> vendorMap = new Map<Id, Address__c>([ Select Id, Name from Address__c where Id IN: serviceProviderIds ]); 

                Task task = new Task( WhatId = tpaRequest.Id, ActivityDate = system.today(), Status = 'Completed',
                                     Subject = 'Vendor Legal Name Changed', CallObject = 'Vendor Legal Name Changed' );

                if( vendorMap.containsKey( oldReqMap.get(tpaRequest.Id).Service_Provider_Address__c )
                   && vendorMap.containsKey( tpaRequest.Service_Provider_Address__c )) {
                    task.Subject = 'Vendor Legal Name Changed from ' + vendorMap.get( oldReqMap.get(tpaRequest.Id).Service_Provider_Address__c ).Name + ' to ' +  vendorMap.get( tpaRequest.Service_Provider_Address__c ).Name;
                    task.CallObject = 'Vendor Legal Name Changed from ' + vendorMap.get( oldReqMap.get(tpaRequest.Id).Service_Provider_Address__c ).Name + ' to ' +  vendorMap.get( tpaRequest.Service_Provider_Address__c ).Name;
                }
                tasksToBeInserted.add( task );
            }
        }

        if( tasksToBeInserted.size() > 0 ) {
            insert tasksToBeInserted;
        }
    }
    
    public String getAgreementName(TPA_Request__c reqObjForAgrName) {
        String spName;
        String cName;
        String region ='';
        String tpaRequestName ='';
        
        if(reqObjForAgrName.Service_Provider_Address__r.Name != null && reqObjForAgrName.Service_Provider_Address__r.Name != '') {
            spName = (reqObjForAgrName.Service_Provider_Address__r.Name.length() > 15? reqObjForAgrName.Service_Provider_Address__r.Name.Substring(0,15): reqObjForAgrName.Service_Provider_Address__r.Name);
        } else {
            spName = reqObjForAgrName.Service_Provider_Address__r.Name;
        }
        
        if(reqObjForAgrName.Client_Address__r.Name != null && reqObjForAgrName.Client_Address__r.Name != '') {
            cName = (reqObjForAgrName.Client_Address__r.Name.length() > 10? reqObjForAgrName.Client_Address__r.Name.Substring(0,10): reqObjForAgrName.Client_Address__r.Name);
        } else { 
            cName = reqObjForAgrName.Client_Address__r.Name;
        }
        
        if(reqObjForAgrName.Client_Address__r != null && reqObjForAgrName.Secondary_Client_Contact_Territory__c != null ) {
            region = reqObjForAgrName.Secondary_Client_Contact_Territory__c;
        }
        if(reqObjForAgrName.Name != null) {
            tpaRequestName = reqObjForAgrName.Name;
        }
        string currentYear = string.valueOf(Date.Today().Year());
        
        return (spName+'_'+ Label.TPA_TLLA +'_'+cName+'_'+tpaRequestName+'_'+region+'_'+ currentYear);
    }
    
    private void updateStatusChangeDates(List<TPA_Request__c> newTpaReqList, Map<Id, TPA_Request__c> oldTpaReqMap) {
        Date todayDate = Date.today();
        Date Dec31Date;
        if(UTL_TPA.amaSettings != null && !UTL_TPA.amaSettings.isEmpty() && UTL_TPA.amaSettings.get(0).Vendor_Canceled_AMA_TPA_EXP_12_31__c != null) {
            Dec31Date = UTL_TPA.amaSettings.get(0).Vendor_Canceled_AMA_TPA_EXP_12_31__c.date();
        }
        
        Set<String> vendorCancelledTpaRequestIds = new Set<String>();
        for(TPA_Request__c tpaRequest: newTpaReqList) {
            if(UTL_TPA.vendorSubmissionFirstUpdate) {
                tpaRequest.Vendor_App_Submitted__c = Datetime.now();
            }
            if(tpaRequest.Request_Status__c != oldTpaReqMap.get( tpaRequest.Id ).Request_Status__c) {
                if(tpaRequest.Request_Status__c == 'Awaiting Vendor Submission') {
                    tpaRequest.Client_Request_Submission__c = Datetime.now();
                    tpaRequest.Vendor_App_Sent__c = Datetime.now();
                    tpaRequest.Vendor_App_Submitted__c = null;
                    tpaRequest.In_IMS_Review__c = null;
                    tpaRequest.TPA_Approved_Awaiting_AMA_Approval__c = null; 
                    tpaRequest.Sent_for_Signature__c = null;
                    tpaRequest.In_Effect_Date__c = null;
                    tpaRequest.Signature_Received__c = null;
                    tpaRequest.Signature_Under_Validation__c = null;
                    tpaRequest.IMS_Denied__c = null;
                    tpaRequest.Cancelled__c = null;
                    tpaRequest.Expired_Date__c = null;
                    tpaRequest.Request_Termination_Time__c = null;
                }
                else if(tpaRequest.Request_Status__c == Label.TPA_In_Review_By_IQVIA_Status) {
                    tpaRequest.In_IMS_Review__c = Datetime.now();
                } 
                else if(tpaRequest.Request_Status__c == 'TPA Approved Awaiting AMA Approval') {
                    tpaRequest.TPA_Approved_Awaiting_AMA_Approval__c = Datetime.now();
                } 
                else if(tpaRequest.Request_Status__c == 'In Auto Approval Process') {
                    tpaRequest.In_Auto_Approval_Process__c = Datetime.now();
                    
                }
                else if( tpaRequest.Request_Status__c == 'Awaiting Vendor Signature') {
                    tpaRequest.Internal_Pending_Status__c = '';
                    tpaRequest.Sent_for_Signature__c = Datetime.now();
                } 
                else if( tpaRequest.Request_Status__c == 'In Effect') {
                    tpaRequest.In_Effect_Date__c = Datetime.now();
                    tpaRequest.Signature_Received__c = Datetime.now();
                } 
                else if( tpaRequest.Request_Status__c == 'Signature Under Validation' ) {
                    tpaRequest.Signature_Under_Validation__c = Datetime.now();
                    tpaRequest.Signature_Received__c = Datetime.now();
                } 
                else if( tpaRequest.Request_Status__c == Label.TPA_IQVIA_Denied_Status ) {
                    tpaRequest.IMS_Denied__c = Datetime.now();
                } 
                else if( tpaRequest.Request_Status__c == 'Cancelled' ) {
                    tpaRequest.Internal_Pending_Status__c = ''; 
                    tpaRequest.Cancelled__c = Datetime.now();
                } 
                else if( tpaRequest.Request_Status__c == 'Expired' ) {
                    tpaRequest.Expired_Date__c = Datetime.now();
                } 
                else if( tpaRequest.Request_Status__c == 'Client Discontinued' 
                || tpaRequest.Request_Status__c == 'AMA Cancelled' 
                || tpaRequest.Request_Status__c =='AMA Discontinued') {   
                    tpaRequest.Request_Termination_Time__c = Datetime.now();
                } 
                else if( UTL_TPA.amaSettings != null 
                        && !UTL_TPA.amaSettings.isEmpty() 
                        && tpaRequest.Request_Status__c == UTL_TPA.amaSettings.get(0).Vendor_Renewal_Cancelation_Status__c 
                        && UTL_TPA.amaSettings.get(0).Vendor_Canceled_AMA_TPA_EXP_12_31__c != null) {
                            if((tpaRequest.Vendor_Company_Name__c != null && tpaRequest.Vendor_Company_Name__c.startsWithIgnoreCase('Test_')) 
                               || (tpaRequest.Client_Name__c !=null && tpaRequest.Client_Name__c.startsWithIgnoreCase('Test_'))) {
                                   tpaRequest.Request_Termination_Time__c = System.now().AddDays(1);
                                   tpaRequest.Data_Access_End_Date__c = System.today().AddDays(1);
                               }
                            else {
                                tpaRequest.Request_Termination_Time__c = UTL_TPA.amaSettings.get(0).Vendor_Canceled_AMA_TPA_EXP_12_31__c;
                                tpaRequest.Data_Access_End_Date__c = UTL_TPA.amaSettings.get(0).Vendor_Canceled_AMA_TPA_EXP_12_31__c.date();
                            }
                            if(Dec31Date!= null && todayDate > Dec31Date){
                                vendorCancelledTpaRequestIds.add(tpaRequest.Id);
                            }
                } 
                else if(( tpaRequest.Request_Status__c == UTL_TPA.AWAITING_CLIENT_CONFIRMATION || tpaRequest.Request_Status__c == 'Awaiting Account Mgmt Communication') 
                && ((oldTpaReqMap.get( tpaRequest.Id ).Request_Status__c == 'Awaiting Vendor Submission')
                || (tpaRequest.LastAction__c == 'Request Edited By TP Processor' 
                && (profileName.indexOf('TPA Processor Profile') != -1 
                || profileName.indexOf('US TP Processor Profile') != -1)))) {
                    tpaRequest.Vendor_App_Submitted__c = Datetime.now();
                }
            }
        }
        
        if(vendorCancelledTpaRequestIds.size()>0){
            List<TPA_Agreement_Additional_Field__c> tpaAgrAddFieldList = [Select Id from TPA_Agreement_Additional_Field__c where Related_TPA_Request__c IN :vendorCancelledTpaRequestIds];
            for(TPA_Agreement_Additional_Field__c tpaAgrAddField : tpaAgrAddFieldList){
                CNT_TPA_ContinueNotificationProcess.sendDDNMail(tpaAgrAddField.Id, false);
            }
        }
       
        
        
    }

    public void sendVendorSignatureEmail(Map<Id, TPA_Request__c> newTpaReqMap, Map<Id, TPA_Request__c> oldTpaReqMap) {
        system.debug('newTpaReqMap: ' + newTpaReqMap.values().get(0));
        system.debug('newTpaReqMap: ' + newTpaReqMap.keyset());
        system.debug('oldTpaReqMap: ' + oldTpaReqMap);
        List<TPA_Request__c> tpaRequestAwaitingSign = new List<TPA_Request__c>();	
        for(TPA_Request__c tpaRequest : newTpaReqMap.values()) {	
            if(newTpaReqMap.get(tpaRequest.Id).Request_Status__c != null 	
               && newTpaReqMap.get(tpaRequest.Id).Request_Status__c.equals('Awaiting Vendor Signature')	
               && newTpaReqMap.get(tpaRequest.Id).Request_Status__c != oldTpaReqMap.get(tpaRequest.Id).Request_Status__c) {	
                tpaRequestAwaitingSign.add(tpaRequest);	
            }	
        }	
        if(tpaRequestAwaitingSign.size() > 0) {
            List<TPA_Request__c> tpaRequestList = [Select Id, 
                                                     Vendor_Language__c, 
                                                     Owner.Type,
                                                     Owner.Email,
                                                     Client_TPA_Representative_Email__c,
                                                     Client_Language__c, 
                                                     Request_Status__c,
                                                     request_type__c, 
                                                     ClientContact__c, 
                                                     TP_Processor_Email__c,
                                                     TPA_Assigned_TP_Processor__c,
                                                     TPA_Assigned_TP_Processor__r.Initials__c,
                                                     TPA_Assigned_TP_Processor__r.Is_Active__c,
                                                   	 Co_Assigned_Global_TP_Processor__c,
                                                     Co_Assigned_Global_TP_Processor__r.Is_Active__c,
                                                     Co_Assigned_Global_TP_Processor__r.Initials__c,
                                                     Client_Address__r.TPAOtherEmailIds__c,
                                                     (Select Email__c from TPA_Request_Contacts__r where (Type__c = 'Additional Client Contact' OR Type__c = 'Additional Contact'))
                                              from TPA_Request__c 
                                              where Id IN: tpaRequestAwaitingSign];
            system.debug('tpaRequestList: ' + tpaRequestList);
            Map<Id, List<Attachment>> tpaReqAttachmentsMap = new Map<Id, List<Attachment>>();
            List<Attachment> lstAttachment = [select Id, ParentId, Name, Body from Attachment where ParentId IN : tpaRequestList and (Name like '%Offerings Notification Client%.pdf') order by LastModifiedDate Desc ];
            for(Attachment attach: lstAttachment) {
                List<Attachment> tpaReqAttachs = new List<Attachment>();
                if(tpaReqAttachmentsMap.containsKey(attach.ParentId)) { 
                    tpaReqAttachs = tpaReqAttachmentsMap.get(attach.ParentId);
                }
                tpaReqAttachs.add(attach);
                tpaReqAttachmentsMap.put(attach.ParentId, tpaReqAttachs);
            } 

            List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
               
            for(TPA_Request__c tpaRequest : tpaRequestList) {
                system.debug('Courtesy email check: request Name : ' + tpaRequest.Id);
                system.debug('tpaRequest.Request_Status__c : ' + newTpaReqMap.get(tpaRequest.Id).Request_Status__c);
                system.debug('old status : ' + oldTpaReqMap.get(tpaRequest.Id).Request_Status__c);

                if(newTpaReqMap.get(tpaRequest.Id).Request_Status__c != null && newTpaReqMap.get(tpaRequest.Id).Request_Status__c.equals('Awaiting Vendor Signature')
                 && newTpaReqMap.get(tpaRequest.Id).Request_Status__c != oldTpaReqMap.get(tpaRequest.Id).Request_Status__c) {
                    String preferredLanguage = tpaRequest.client_language__c != null ? tpaRequest.client_language__c : 'English';
                    String emailType = 'Email Agreement for signature';
                    if(tpaRequest.request_type__c == 'renew') {
                        emailType = 'Client Courtesy Renew';
                    }

                    List<String> toAddresses = new List<String>();
                    string strClientContact = tpaRequest.ClientContact__c;
                    if(strClientContact != null && strClientContact != '') {
                    toAddresses.add(strClientContact);
                    }
                    if(tpaRequest.Client_TPA_Representative_Email__c != null && tpaRequest.Client_TPA_Representative_Email__c != ''){
                        toAddresses.add(tpaRequest.Client_TPA_Representative_Email__c);
                    }
            
                    List<String> ccAddresses = new List<String>();

                    if(tpaRequest.Owner.Type != null && tpaRequest.Owner.Type == 'Queue' && tpaRequest.Owner.Email != null){
                        ccAddresses.add(tpaRequest.Owner.Email);
                    }
                    if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
                        ccAddresses.add(UTL_TPA.sharedEmailAddress);
                    }
                    if(tpaRequest.TP_Processor_Email__c != null && tpaRequest.TP_Processor_Email__c != '') {
                        ccAddresses.add(tpaRequest.TP_Processor_Email__c);
                    }

                    for(TPA_Contact__c aggCon: tpaRequest.TPA_Request_Contacts__r) {
					    if(aggCon.Email__c != null && aggCon.Email__c != ''){ 
						    ccAddresses.add( aggCon.Email__c );
					    }
                    }
        
                    ccAddresses = UTL_TPA_Multilingual.ccList(tpaRequest.Client_Address__r.TPAOtherEmailIds__c, ccAddresses);

                    List<Attachment> emailAttachmentList = new List<Attachment>();
                    if(tpaReqAttachmentsMap.size() > 0) {
                        boolean isOffNotificationAttached = false;
                        boolean isAddendumNotificationAttached = false;
                        for(Attachment attach: tpaReqAttachmentsMap.get(tpaRequest.Id)) {
                            if(attach.Name.indexOf('Offerings Notification Client') != -1 && !isOffNotificationAttached) {
                                //Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                                //efa.setFileName(attach.Name);
                                //efa.setBody(aattach.Body);
                                //emailAttach.add(efa);
                                emailAttachmentList.add(attach);
                                if(attach.Name.indexOf('Offerings Notification Client') != -1) {
                                    isOffNotificationAttached = true;
                                }
                            }
                        }
                        //mail.setFileAttachments(emailAttach);
                    }

                    /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                    if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        SRV_TPA_TPARequest.assignedTPProcessorName = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c; 
                    }*/
                    emailsList.add(SRV_TPA_TPARequest.getTPANotificationEmailDraft(toAddresses, ccAddresses, emailType, preferredLanguage, tpaRequest.Id, true, emailAttachmentList, null, TRUE, TRUE, tpaRequest));
                    //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                    system.debug('request added for courtesy email send');
                }
            }
            try {
                system.debug('Courtesy Email: emailsList: ' + emailsList.size());
                system.debug('Courtesy Email: UTL_TPA.isSendOutgoingEmails: ' + UTL_TPA.isSendOutgoingEmails);
                system.debug('Courtesy Email: isCourtesyEmailSent: ' + isCourtesyEmailSent);
            
                if(!emailsList.isEmpty() && UTL_TPA.isSendOutgoingEmails && !isCourtesyEmailSent ) {
                    Messaging.sendEmail(emailsList);
                    isCourtesyEmailSent = true;
                    system.debug('Email Message List: ' + emailsList);
                    System.debug('Courtesy Email Send Successfully');
                }            
            } catch(Exception e) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_TPARequest.sendVendorSignatureMail:::Courtesy Email Failed', ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                System.debug(e.getMessage());
            }
		}
    }

    public void sendMailToDblForExecutedAmaAgreement(string requestId) {
        try {
            List<TPA_Request__c> tpaRequestList = [select id,
                                                   createddate,
                                                   Signer__c, 
                                                   Is_Restricted_Data_Asset__c,
                                                   TPA_Authorised_Signer__c,
                                                   Authorized_Signer_Email__c,
                                                   Vendor_Contact_e_mail__c,
                                                   TP_Processor_Email__c,
                                                   Authorized_Signer_Name__c,
                                                  
                                                   Signer__r.Name ,
                                                   Request_Status__c,
                                                   Signer__r.dsfs__DocuSign_Recipient_Email__c,
                                                   Signer__r.dsfs__Date_Signed__c,
                                                   Name,
                                                   ClientContact__c,
                                                   ClientContact__r.Email,
                                                   Vendor_App_Submitted__c,
                                                   Vendor_App_Sent__c,
                                                   Client_Language__c, 
                                                   Vendor_Language__c,
                                                   TPA_Assigned_TP_Processor__c,
                                                   TPA_Assigned_TP_Processor__r.Initials__c,
                                                   TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, 
                                                   Signature_Under_Validation__c,
                                                   (Select id,Client__c,Vendor_Legal_Name__c,Contract_Type__c 
                                                    from AMA_Agreement_Details__r )
                                            from TPA_Request__c 
                                            where id =: requestId];

            if(tpaRequestList != null && tpaRequestList.size() > 0) {
                sendMailToDblForExecutedAmaAgreementToDBL(tpaRequestList);
            }
        } catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
    
    public static void sendMailToTPAAdmintoExtractAMADocumentFromSignedOnPaperDoc(string agreementId) {
        try {
            List<TPA_Request__c> listAgg = [ select id,createddate, Signer__c , Is_Restricted_Data_Asset__c,
                                           ClientContact__c, TP_Processor_Email__c,
                                           (Select id,Client__c,Vendor_Legal_Name__c, Contract_Type__c from AMA_Agreement_Details__r ) 
                                           from TPA_Request__c where id =: agreementId];

            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Id amaAgrId ;
            for(TPA_Request__c agg: listAgg) {

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                TPA_Settings__c tpaCustomSettings = UTL_TPA.tpaSetting;
                String templateId = tpaCustomSettings.Notification_To_Extrct_AMA_Completed_Doc__c;

                List<String> toAddress = new List<String>();
                if(tpaCustomSettings.TPA_Admin_Email_Address__c != null && tpaCustomSettings.TPA_Admin_Email_Address__c != '') {
                    toAddress = tpaCustomSettings.TPA_Admin_Email_Address__c.split(',');
                }
                
                if(agg.TP_Processor_Email__c != null)
                    toAddress.add(agg.TP_Processor_Email__c);

                List<String> ccEmailList = new List<String>();

                if(UTL_TPA.tpaSetting != null && tpaCustomSettings.TPA_DRN_Mails_Copy_To__c != null && tpaCustomSettings.TPA_DRN_Mails_Copy_To__c.length() > 0){
                    for(string mailIdObj: tpaCustomSettings.TPA_DRN_Mails_Copy_To__c.split(',')){
                        if(mailIdObj != null && mailIdObj.trim().length() > 0)
                            ccEmailList.add(mailIdObj.trim());
                    }
                }
                if(agg.AMA_Agreement_Details__r != null && agg.AMA_Agreement_Details__r.size() > 0) {
                    amaAgrId = agg.AMA_Agreement_Details__r[0].id;
                }

                email.setTargetObjectId(agg.ClientContact__c);
                email.setTreatTargetObjectAsRecipient(false);
                email.setWhatId(agg.Id);
                email.setToAddresses(toAddress);
                email.setCcAddresses(ccEmailList);
                email.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Orgwide_Email_Id__c);
                //email.setTemplateId(templateId);
                email.setCharset('UTF-8');
                email.setSaveAsActivity(true);
                Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, agg.Id);
                email.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
                email.setSubject(emailNotToSend.getSubject());
                mails.add(email);
            }
            try {
                if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                    Messaging.sendEmail(mails);
                    if(amaAgrId != null) {
                        SRV_TPA_TPARequest.updateActivityHistory(amaAgrId, 'AMA agreement signed with wet signature Email Sent', true);
                    }
                    //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success';
                    //TPAQueryHelper.setLogObject('' , 'AMA agreement signed with wet signature Email ', '');
                    //TPAQueryHelper.logRef().generateLog();
                }
            }
            catch(Exception e) {
                System.debug('Email Failed: ' + e.getMessage());
                UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_TPARequest.sendMailToTPAAdmintoExtractAMADocumentFromSignedOnPaperDoc:::AMA agreement signed with wet signature Email NOT Sent', amaAgrId != null ? amaAgrId : '');
                //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
                //TPAQueryHelper.setLogObject('', 'Exception:AMA agreement signed with wet signature Email NOT Sent ', e.getMessage()+'*'+e.getLineNumber());
                //TPAQueryHelper.logRef().generateLog();
            }
        }
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            //TPAQueryHelper.setLogObject('', 'Exception:AMA agreement signed with wet signature Email NOT Sent ', e.getMessage()+'*'+e.getLineNumber());
            //TPAQueryHelper.logRef().generateLog();
        }
    }

    public void sendMailToDblForExecutedAmaAgreementToDBL(List<TPA_Request__c> objList) {
        //TODO
        //List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        //emailsList.add(SRV_TPA_TPARequest.getTPANotificationEmailDraft(List<String> toAddresses, List<string> ccAddresses, String emailType, String language, Id emailWhatId, Boolean saveAsActivity, List<Attachment> lstAttachment, String subject));
        
        System.debug('####in the Executed agreement notification to DBL method');
        
        String templateId = UTL_TPA.tpaSetting.TPA_Executed_AMA_Agreement_Template__c;
        String dblContractsContactId = UTL_TPA.dblContractContactId;
        String tp_us_EmailId = UTL_TPA.tpaSetting.TP_US_Mail_Id__c;
        String contracts_EmailId = UTL_TPA.tpaSetting.Contracts_Mail_Id__c;
        String SERVICE_BUREAU_II = 'Service Bureau II';
        String CONTRACT_SALESFORCE = 'Contract Sales Force';
        String initials = '';
        String globalTPProcessorInitials = '';

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(TPA_Request__c tpaRequest: objList) {
            List<AMA_Agreement_Detail__c> amaAgreementList = tpaRequest.AMA_Agreement_Details__r;
            if(amaAgreementList.size() > 0) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                List<String> ccTo = new List<String>();
                if(UTL_TPA.amaSettings.get(0).Mail_Addresses_for_signed_AMA_Agreement__c != null && UTL_TPA.amaSettings.get(0).Mail_Addresses_for_signed_AMA_Agreement__c != '') {
                    ccTo = UTL_TPA.amaSettings.get(0).Mail_Addresses_for_signed_AMA_Agreement__c.split(';');
                }
                mail.setCcAddresses(ccTo);
                
                String targetObjectId = dblContractsContactId;
                mail.setTargetObjectId(targetObjectId);
                mail.setWhatId(amaAgreementList[0].id);
                //mail.setTemplateId(templateId);

                Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, amaAgreementList[0].id);
                mail.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
                mail.setSubject(emailNotToSend.getSubject());
                mail.setCharset('UTF-8');  

                mail.setOrgWideEmailAddressId(UTL_TPA.tpaSetting.TPA_From_Address_For_Data_Release__c);
                mail.setSaveAsActivity(true);
                mail.setUseSignature(false);
                if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                    initials = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
                }
                if(tpaRequest.Co_Assigned_Global_TP_Processor__r.Is_Active__c ) {
                    globalTPProcessorInitials = tpaRequest.Co_Assigned_Global_TP_Processor__r.Initials__c;
                }
                mail.setSubject(SRV_TPA_TPARequest.setEmailInitials(initials, globalTPProcessorInitials, mail.getSubject()));
                
                /*if(String.isNotBlank(UTL_TPA.tpaSetting.TPA_BCC_Emails__c)) {
                    List<String> bccTo = new List<String>();
                    bccTo.addAll(UTL_TPA.tpaSetting.TPA_BCC_Emails__c.split(';'));
                    mail.setBccAddresses(bccTo);
                }*/
                
                if(String.isNotBlank(amaAgreementList[0].Client__c) &&
                   String.isNotBlank(amaAgreementList[0].Vendor_Legal_Name__c) &&
                   (  amaAgreementList[0].Client__c.startsWithIgnoreCase('Test') 
                   || amaAgreementList[0].Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))) {
                    mail.setTreatTargetObjectAsRecipient(false);
                }
                
                List<Attachment> lstAttachment = new List<Attachment>();
                lstAttachment = [select Id, Name,Body from Attachment where ParentId =: tpaRequest.id and (Name like 'AMA_%TPA%.pdf_Completed') order by LastModifiedDate Desc limit 1];
                if(lstAttachment.size() > 0) {
                    List<Messaging.Emailfileattachment> emailAttach = new List<Messaging.Emailfileattachment>();
                    boolean isAmaSignedAgreementAttached = false;
                    for(Attachment a: lstAttachment) {
                        if(a.Name.indexOf('AMA_') == 0 && a.Name.indexOf('TPA') != -1 && !isAmaSignedAgreementAttached) {
                            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                            efa.setFileName(a.Name.substring(0,a.name.length() -10));
                            efa.setBody(a.Body);
                            emailAttach.add(efa);
                            if(a.Name.indexOf('AMA_') == 0 && a.Name.indexOf('TPA') != -1)
                                isAmaSignedAgreementAttached = true;
                        }
                    }
                    mail.setFileAttachments(emailAttach);
                    mails.add(mail);
                }
            }
        }
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                //Send all emails in the master list
                Messaging.sendEmail(mails);
            }
        } catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_TPARequest.sendMailToDblForExecutedAmaAgreementToDBL:::AMA Signed Email Failed', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('AMA Signed Email Failed: ' + e.getMessage());
        }
    }

    public void sendAgreementsForDataAuthorizationMail(TPA_Request__c tpaRequest) {
        try {
            this.orgWideEmailId = UTL_TPA.orgWideEmailAddress;
            String preferredLanguage = tpaRequest.client_language__c != null ? tpaRequest.client_language__c : 'English';
            this.templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Data Release Client'+preferredLanguage).Translated_Template_Id__c;
            
            List<TPA_Request__c> tpaRequestList = [select id,
                                                          CreatedDate,
                                                          Signer__c,
                                                          Is_Restricted_Data_Asset__c,
                                                          TPA_Authorised_Signer__c,
                                                          Authorized_Signer_Email__c,
                                                          Vendor_Contact_e_mail__c,
                                                          TP_Processor_Email__c,
                                                          TPA_Assigned_TP_Processor__c,
                                                          TPA_Assigned_TP_Processor__r.Initials__c,
                                                          TPA_Assigned_TP_Processor__r.Is_Active__c,
														  Co_Assigned_Global_TP_Processor__c,
														  Co_Assigned_Global_TP_Processor__r.Is_Active__c,
														  Co_Assigned_Global_TP_Processor__r.Initials__c,
                                                          Authorized_Signer_Name__c,
                                                          Signer__r.Name, 
                                                          Request_Status__c,
                                                          Signer__r.dsfs__DocuSign_Recipient_Email__c,
                                                          Signer__r.dsfs__Date_Signed__c,  
                                                          Name,
                                                          ClientContact__c,
                                                          ClientContact__r.Email, 
                                                          Client_TPA_Representative_Email__c,
                                                          Client_Address__r.TPAOtherEmailIds__c,
                                                          Vendor_App_Submitted__c,
                                                          Vendor_App_Sent__c,
                                                          Client_Language__c, 
                                                          Vendor_Language__c,
                                                          Owner.Type,
                                                          Owner.Email,
                                                          (Select Email__c from TPA_Request_Contacts__r)
                                                   from TPA_Request__c 
                                                   where id =: tpaRequest.Id];

            if(tpaRequestList != null && tpaRequestList.size() > 0) {
                this.sendDataAuthorizationMailToClient(tpaRequestList);
            }
        } catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_TPARequest.sendAgreementsForDataAuthorizationMail:::Data Authorisation Mail Failed ', tpaRequest.id != null ? tpaRequest.id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }

    public void sendDataAuthorizationMailToClient(List<TPA_Request__c> objList) {
        System.debug('####in the data release method');
        TPA_Settings__c tpaSetting = TPA_Settings__c.getInstance();//Added by Govind under ER-2194
        Map<Id, Date> mapIdDate = new Map<Id, Date>();
        Map<String, Boolean> isRestrictedMap = new Map<String, Boolean>();
        List<String> vendorMailCCAddress = new List<String>();
        String vendorMailSendTo = '';
        Map<string, List<string>> vendorMailMapContactCCEmails = new Map<string, List<string>>();
        Map<string, string> vendorMailMapContactToEmails = new Map<string, string>();
        List<Id> reqIds = new List<Id>();
        List<Id> aggIds = new List<Id>();
        Map<string, List<string>> mapContactCCEmails = new Map<string, List<string>>();
        Map<string, string> mapContactToEmails = new Map<string, string>();
        List<String> vendorMailList;
        List<string> lstData ;
        List<string> lstAggId ;
        List<string> listCCAddresses = new List<String>();
        List<String> listToAddresses = new List<String>();
        List<Contact> contactList = new List<Contact>();
        string targetID = '';
        //String emailType = 'Email Data Release Client';
        //String preferredLanguage = tpaRequest.client_language__c != null ? tpaRequest.client_language__c : 'English';
            
        for(TPA_Request__c tpaRequest: objList) {
            mapIdDate.put(tpaRequest.id, tpaRequest.createddate.date());
            tpaRequest.Is_MailSend_For_DataAccess__c = true;
            aggIds.add(tpaRequest.Id);

            mapContactToEmails.put(tpaRequest.Id, tpaRequest.clientcontact__c);
            
            if(tpaRequest.TPA_Authorised_Signer__c == 'Yes') {
                vendorMailMapContactToEmails.put(tpaRequest.Id, tpaRequest.Vendor_Contact_e_mail__c);
            } else {
                vendorMailMapContactToEmails.put(tpaRequest.Id, tpaRequest.Authorized_Signer_Email__c);
            }
            
            lstData = new List<string>();
            vendorMailList = new List<String>();
            if(UTL_TPA.sharedEmailAddress != null) {
                vendorMailList.add(UTL_TPA.sharedEmailAddress);
            }
            
            if(tpaRequest.TP_Processor_Email__c != null && tpaRequest.TP_Processor_Email__c != '') {
                vendorMailList.add(tpaRequest.TP_Processor_Email__c);
                lstData.add(tpaRequest.TP_Processor_Email__c);
                mapContactCCEmails.put(tpaRequest.Id, lstData);
            }
            
            if( tpaRequest.TPA_Authorised_Signer__c == 'No' 
             && tpaRequest.Vendor_Contact_e_mail__c != tpaRequest.Authorized_Signer_Email__c) {
                vendorMailList.add(tpaRequest.Vendor_Contact_e_mail__c);
            }

            List<TPA_Contact__c> tpaContactsList = SRV_TPA_TPARequest.getContactsForRequest(tpaRequest.Id);
            if(tpaContactsList != null && tpaContactsList.size() > 0) {
                for(TPA_Contact__c tpaContact: tpaContactsList) {
                    if(tpaContact.Type__c == 'Additional Vendor Contact') {
                        vendorMailList.add(tpaContact.Email__c);
                    }
                }
            }
            system.debug('vendorMailList: ' + vendorMailList);
            
            vendorMailMapContactCCEmails.put(tpaRequest.Id, vendorMailList);
            system.debug('vendorMailMapContactCCEmails: ' + vendorMailMapContactCCEmails);
            isRestrictedMap.put(tpaRequest.Id, tpaRequest.Is_Restricted_Data_Asset__c);
        }

        for(TPA_Contact__c aggContact: [SELECT TPA_Request__c, Email__c, Name 
                                              FROM TPA_Contact__c
                                              where TPA_Request__c IN : aggIds AND (Type__c = 'Additional Client Contact') 
                                              order by TPA_Request__c]) {
                                                
            lstData = mapContactCCEmails.get(aggContact.TPA_Request__c);
            lstData.add(aggContact.Email__c);
            mapContactCCEmails.put(aggContact.TPA_Request__c, lstData);
        }
        
        for(TPA_Request__c tpaRequest: objList) {
            if(tpaRequest.Client_TPA_Representative_Email__c != null && tpaRequest.Client_TPA_Representative_Email__c != ''){
                listToAddresses.add(tpaRequest.Client_TPA_Representative_Email__c);
            }
            if(mapContactCCEmails.size() > 0) {
                listCCAddresses= mapContactCCEmails.get(tpaRequest.Id);
            }
            
            if(UTL_TPA.sharedEmailAddress != null) {
                listCCAddresses.add(UTL_TPA.sharedEmailAddress);
            }
            if(tpaRequest?.ClientContact__r?.Email != null){
                listCCAddresses.add(tpaRequest.ClientContact__r.Email);
            }
            targetID = mapContactToEmails.get(tpaRequest.Id);
            vendorMailSendTo = vendorMailMapContactToEmails.get(tpaRequest.Id);
            listCCAddresses = UTL_TPA_Multilingual.ccList(tpaRequest.Client_Address__r.TPAOtherEmailIds__c, listCCAddresses);
            if(tpaRequest.Owner.Type != null && tpaRequest.Owner.Type == 'Queue' && tpaRequest.Owner.Email != null){
                listCCAddresses.add(tpaRequest.Owner.Email);
            }
            system.debug('mapContactToEmails:'+mapContactToEmails);
            sendMail(targetID, listToAddresses, listCCAddresses, tpaRequest, templateId, 'Test:Data Release Authorization', objList[0].Id,vendorMailSendTo,vendorMailMapContactCCEmails.get(tpaRequest.Id),isRestrictedMap.get(tpaRequest.Id),mapIdDate.get(tpaRequest.Id));
            //SRV_TPA_TPARequest.getTPANotificationEmailDraft(toAddress, listCCAddresses, emailType, preferredLanguage, tpaRequest.Id, Boolean saveAsActivity, List<Attachment> lstAttachment, String subject)
        }
        
        if(contactList.size() > 0) {
            delete contactList;
        }
        updateTpaAfterExecutionEmails = true;
        update objList;
    }

    public void sendMail(Id targetId, List<String> toAddresses, List<string> ccAddresses, TPA_Request__c tpaRequest, Id templateId, string mailSubject, Id reqId, String vendorMailSendTo, List<String> vendorMailCCAddress, Boolean isRestricted, Date creationDate) {
        // TODO
        //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success'; //Added by govind under ER-3039
        //TPAQueryHelper.setLogObject(reqId, 'Success:In the Send DRN Mail Method ',''); //Added by govind under ER-3039
        //TPAQueryHelper.logRef().generateLog();  //Added by govind under ER-3039
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();
        List<String> splittedDate = new List<String>();
        Id whatId = tpaRequest.Id;
        String initials = '';
        String globalTPProcessorInitials = '';
        
        if(!Test.isRunningTest()) {
            splittedDate = tpaCustomSettings.Deployment_Date__c.split('-');
        }
        
        Date globalDate;
        if(splittedDate.size() > 0) {
            globalDate = Date.newInstance(Integer.valueof(splittedDate[0]), Integer.valueof(splittedDate[1]), Integer.valueof(splittedDate[2]));
        } else {
            globalDate = Date.newInstance(2015, 05, 28);
        }
        System.debug('*******Inside2*******');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //email.setTargetObjectId(targetId);
        email.setWhatId(whatId);
        //email.setTemplateId(templateId);
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, whatId);
        email.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
        if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            initials = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
        }
        if(tpaRequest.Co_Assigned_Global_TP_Processor__r.Is_Active__c) {
            globalTPProcessorInitials = tpaRequest.Co_Assigned_Global_TP_Processor__r.Initials__c;
        }
        email.setSubject(SRV_TPA_TPARequest.setEmailInitials(initials, globalTPProcessorInitials, emailNotToSend.getSubject()));
        email.setCharset('UTF-8');  

        if( tpaCustomSettings != null 
         && tpaCustomSettings.TPA_DRN_Mails_Copy_To__c != null 
         && tpaCustomSettings.TPA_DRN_Mails_Copy_To__c.length() > 0) {
            for(string mailIdObj: tpaCustomSettings.TPA_DRN_Mails_Copy_To__c.split(',')) {
                if(mailIdObj != null && mailIdObj.trim().length() > 0) {
                    ccAddresses.add(mailIdObj.trim());
                }
            }
        }
       
        System.debug('*******CCList*******'+tpaCustomSettings.TPA_DRN_Mails_Copy_To__c+':::'+ccAddresses);
        DateTime vendorAppsub = tpaRequest.Vendor_App_Sent__c ; 
        List<Attachment> lstAttachment = new List<Attachment>();
        lstAttachment = [SELECT Id, Name, Body 
                         FROM Attachment 
                         WHERE ParentId =: whatId 
                         AND createdDate >= :vendorAppsub 
                         AND (Name like '%.pdf_Completed' 
                              or Name like '%.pdf_completed' 
                              or Name like '%Offerings Notification Client%.pdf'
                              or Name like : '%' + UTL_TPA.standardTermsAndCondDoc + '%.pdf'
                              or Name like : '%' + UTL_TPA.complianceProgramDoc + '%.pdf') 
                         order by LastModifiedDate Desc];
        
        

        List<ContentVersion> lstCV = new List<ContentVersion>();
        List<Id> attachmentIds = new List<Id>();
        if(lstAttachment.size() > 0) {
            
            boolean isTLLAAttached = false;
            boolean isTechLicAttached = false;
            boolean isTechAmmendAttached = false;
            boolean isAMAAttached = false;
            boolean isAMAFLAttached = false;
            boolean isOffNotificationAttached = false;
            boolean isAddendumNotificationAttached = false;
            boolean isHelpfulHintAttached = false;
            for(Attachment a: lstAttachment) {
                if((a.Name.indexOf('TLLA') != -1 && a.Name.indexOf('Tech Amendment') == -1 && a.Name.indexOf('Tech License') == -1 && !isTLLAAttached) 
                   || (a.Name.indexOf('TLLA') != -1 && a.Name.indexOf('Tech Amendment') != -1 && !isTechAmmendAttached) 
                   || (a.Name.indexOf('TLLA') != -1 && a.Name.indexOf('Tech License') != -1 && !isTechLicAttached) 
                   || (a.Name.indexOf('AMA') != -1 && UTL_TPA.isAmaDoc(a.Name.toLowerCase()) && !isAMAAttached)
                   || (a.Name.indexOf('AMA') != -1 && UTL_TPA.isAmaFLDoc(a.Name.toLowerCase()) && !isAMAFLAttached)
                   || (a.Name.indexOf('TPSA') != -1)
                   || (a.Name.indexOf('Offerings Notification Client') != -1 && !isOffNotificationAttached)
                   || (a.Name.indexOf('Addendum Notification') != -1 && !isAddendumNotificationAttached)
                   || a.Name.indexOf(UTL_TPA.standardTermsAndCondDoc) != -1 
                   || a.Name.indexOf(UTL_TPA.complianceProgramDoc) != -1   
                   || a.Name.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1 )
                {
                    ContentVersion cv = new ContentVersion();
                    String attName = a.Name;
                    String trimmedName;
                    if(a.Name.indexOf('_Completed') != -1 || a.Name.indexOf('_completed') != -1) {
                        trimmedName = attName.substring(0,attName.length() -10);
                    } else {
                        trimmedName = attName;
                    }
                    
                    cv.Title = trimmedName;
                    cv.PathOnClient = trimmedName;
                    cv.Description = trimmedName;
                    cv.isMajorVersion = true;
                    cv.VersionData = a.Body;
                    lstCV.add(cv);
                    
                    if(a.Name.indexOf('TLLA') != -1 && a.Name.indexOf('Tech Amendment') == -1 && a.Name.indexOf('Tech License') == -1)
                        isTLLAAttached = true;
                    else if(a.Name.indexOf('TLLA') != -1 && a.Name.indexOf('Tech Amendment') != -1)
                        isTechAmmendAttached = true;
                    else if(a.Name.indexOf('TLLA') != -1 && a.Name.indexOf('Tech License') != -1)
                        isTechLicAttached = true;
                    else if(a.Name.indexOf('AMA') != -1 && UTL_TPA.isAmaDoc(a.Name.toLowerCase()) )
                        isAMAAttached = true;
                    else if(a.Name.indexOf('AMA') != -1 && UTL_TPA.isAmaFLDoc(a.Name.toLowerCase()) )
                        isAMAFLAttached = true;
                    else if(a.Name.indexOf('Offerings Notification Client') != -1)  
                        isOffNotificationAttached = true;
                    else if(a.Name.indexOf('Addendum Notification') != -1) 
                        isAddendumNotificationAttached = true;  
                    else if(a.Name.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1) 
                        isHelpfulHintAttached = true;
                }
            }
        }

        try {
            if(lstCV != null && lstCV.size() > 0){
                insert lstCV;
            }
            System.debug('lstCV inserted successfully');
        } catch(Exception e) {
            System.debug('Following Exception Occue In IF---------> ' + e);
        }

        if(lstCV != null && lstCV.size() > 0){
            for(ContentVersion cvObj : lstCV){
                attachmentIds.add(cvObj.id);
            }
        }

        if(attachmentIds != null && attachmentIds.size() > 0 ){
            email.setEntityAttachments(attachmentIds);
        }
        
        if(ccAddresses.size() > 0) {
            email.setCcAddresses(ccAddresses);
        }
        if(toAddresses.size() > 0) {
            email.setToAddresses(toAddresses);
        }
        
        email.setOrgWideEmailAddressId(orgWideEmailId );
        email.setSaveAsActivity(true);
        email.setUseSignature(false); 
        
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                Messaging.SendEmail(New Messaging.SingleEmailMessage[] {email});
                // TODO
                //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success';
                //TPAQueryHelper.setLogObject(reqId, 'Success:DRN Sent Successfully ','');
               // TPAQueryHelper.logRef().generateLog(); 
            }
            if(!isManualDRNCalled) {
              SRV_TPA_TPARequest.updateActivityHistory(whatId, 'Data Release Notification sent', true);
            }
        } catch(Exception e) {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_TPARequest.sendMail:::Data Release Notification Failed', whatId != null ? whatId : '');
            System.debug('Email Failed: ' + e.getMessage());
            // TODO
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            //TPAQueryHelper.setLogObject(reqId, 'Exception:Exception Occurred in Sending the DRN ',e.getMessage()+'*'+e.getLineNumber()); 
            //TPAQueryHelper.logRef().generateLog();
        }
        
        if(!isManualDRNCalled && (creationDate > globalDate || Test.isRunningTest())) {
            this.sendAcknowledgementToVendor(tpaRequest, vendorMailSendTo, vendorMailCCAddress, isRestricted, reqId);
        }
    }

    // Copy of signed
    public void sendAcknowledgementToVendor(TPA_Request__c tpaRequest, String sendTo, List<String> ccAddress, Boolean isRestricted, Id reqId) {
        try {
            // TODO
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success'; 
            //TPAQueryHelper.setLogObject(reqId, 'Success:In the Copy Of Signed Method ',''); 
            //TPAQueryHelper.logRef().generateLog();  
            Id whatId = tpaRequest.Id; 
            Boolean isWetSign = false;
            String recipientName = 'Test Contact';
            String templateId = '';
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            List<TPA_RequestDocument__c> lstRequestDocuments = new List<TPA_RequestDocument__c>();
            lstRequestDocuments = [select Document_Id__c from TPA_RequestDocument__c where TPA_Request_Id__c =: reqId];
            Set<Id> stDocumentId = new Set<Id>();
            for(TPA_RequestDocument__c objRequestDocument : lstRequestDocuments) {
                stDocumentId.add(objRequestDocument.Document_Id__c);
            }
            
            System.debug('##Working fine');
            /*email.setTargetObjectId(UTL_TPA.emailTargetContactId);
            email.setTreatTargetObjectAsRecipient(false);
            email.setToAddresses(new List<string>{sendTo});
            email.setWhatId(whatId);*/
            System.debug('##Working fine');
            TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();

            String preferredLanguage = tpaRequest.vendor_language__c != null ? tpaRequest.vendor_language__c : 'English';
            templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Data Release Vendor'+preferredLanguage).Translated_Template_Id__c;
            system.debug('####TPA_TriggerHelper_TPARequest.sendAcknowledgementToVendor preferredLanguage: '+preferredLanguage+', templateId: '+templateId);
            /*email.setTemplateId(templateId);
            email.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Address_For_Data_Release__c);
            if(ccAddress.size() > 0) {
                 email.setCcAddresses(ccAddress);
            }*/
            List<Id> lstIds = new List<Id>();
            List<Messaging.Emailfileattachment> lstAttachment = new List<Messaging.Emailfileattachment>();
            List<Document> docs = new List<Document>();
            docs = [select id,name,body from Document where id in: stDocumentId];
            if(docs.size() > 0) {
                for(integer docCounter = 0 ; docCounter < docs.size() ; docCounter++) {
                    if(!isRestricted && docs.get(docCounter).Name.indexOf('Restricted Data Security Requirement') != -1) {
                        continue;
                    }
                    lstIds.add(docs.get(docCounter).Id);
                }
            }
            boolean isOffNotAttached = false;
            boolean isAddendumNotAttached = false;
            boolean isHelpfulHintNotAttached = false;
            DateTime vendorAppsub = tpaRequest.Vendor_App_Sent__c;
            for (Attachment a : [select Id,Name,Body from Attachment where ParentId =: whatId and createdDate >= :vendorAppsub and ((Name like '%Completed%' and (NOT (Name like '%Use Definition%')) and (NOT (Name like '%Offerings Notification Client%'))) OR Name like '%Offerings Notification Vendor%.pdf' OR Name like '%Addendum Notification%.pdf_Completed' OR Name like '%TPA Helpful Hints Addendum%.pdf_Completed')  order by name]) {
                if(isOffNotAttached && a.Name.indexOf('Offerings Notification Vendor') != -1) {
                    continue;
                }
                if(isAddendumNotAttached && a.Name.indexOf('Addendum Notification') != -1) {
                    continue; 
                }
                if(isHelpfulHintNotAttached && a.Name.indexOf('TPA Helpful Hints Addendum') != -1) {
                    continue; 
                }

                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                String attName = a.Name;
                String trimmedName;
                if((a.Name.indexOf('Offerings Notification Vendor') != -1 || a.Name.indexOf('Addendum Notification') != -1 || a.Name.indexOf('TPA Helpful Hints Addendum') != -1) && a.Name.indexOf('Completed') == -1) {
                    trimmedName = attName;
                } else {
                    trimmedName = attName.substring(0,attName.length() -10);
                }
                if( trimmedName.indexOf('Signed') != -1) {
                    trimmedName =  trimmedName + '.pdf';
                    isWetSign = true;
                }
                efa.setFileName(trimmedName);
                efa.setBody(a.Body);
                if(isWetSign && trimmedName.substring(0,5).indexOf('TPA-') != -1 && trimmedName.indexOf('Offerings Notification Vendor') == -1 && trimmedName.indexOf('Addendum Notification') == -1) {
                    continue;
                }
                lstAttachment.add(efa);
                if(a.Name.indexOf('Offerings Notification Vendor') != -1) {
                    isOffNotAttached = true; 
                }
                if(a.Name.indexOf('Addendum Notification') != -1) {
                    isAddendumNotAttached = true; 
                }
                if(a.Name.indexOf('TPA Helpful Hints Addendum') != -1) {
                    isHelpfulHintNotAttached = true; 
                }
            }
            if(docs.size() > 0) {
                for (Document a : docs) {
                   Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    String attName = a.Name;
                    String trimmedName;
                    if(a.Name.toLowerCase().indexOf(('Compliance Program').toLowerCase()) != -1 && a.Name.toLowerCase().indexOf(('Compliance Program Japanese').toLowerCase()) == -1) {
                        trimmedName = 'Compliance Program';
                        if( trimmedName != null) {
                            trimmedName =  trimmedName + '.pdf';
                        }
                        efa.setFileName(trimmedName);
                        efa.setBody(a.Body);
                        lstAttachment.add(efa);
                    } 
                    if(a.Name.toLowerCase().indexOf(('STANDARD TERMS AND CONDITIONS').toLowerCase()) != -1 && a.Name.toLowerCase().indexOf(('STANDARD TERMS AND CONDITIONS JAPANESE').toLowerCase()) == -1) {
                        trimmedName = 'STANDARD TERMS AND CONDITIONS';
                        if( trimmedName != null) {
                            trimmedName =  trimmedName + '.pdf';
                        }
                        efa.setFileName(trimmedName);
                        efa.setBody(a.Body);
                        lstAttachment.add(efa);
                    }
                    if(a.Name.toLowerCase().indexOf(('Compliance Program Japanese').toLowerCase()) != -1) {
                        trimmedName = 'Compliance Program Japanese';
                        if( trimmedName != null) {
                            trimmedName =  trimmedName + '.pdf';
                        }
                        efa.setFileName(trimmedName);
                        efa.setBody(a.Body);
                        lstAttachment.add(efa);
                    } 
                    if(a.Name.toLowerCase().indexOf(('STANDARD TERMS AND CONDITIONS JAPANESE').toLowerCase()) != -1) {
                        trimmedName = 'STANDARD TERMS AND CONDITIONS JAPANESE';
                        if( trimmedName != null) {
                            trimmedName =  trimmedName + '.pdf';
                        }
                        efa.setFileName(trimmedName);
                        efa.setBody(a.Body);
                        lstAttachment.add(efa);
                    }
                }
            }
            
            /*email.setEntityAttachments(lstIds); 
            email.setFileAttachments(lstAttachment);
            email.setSaveAsActivity(false);

            Savepoint sp = Database.setSavepoint();*/
            try {
                //if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                    //Messaging.SendEmail(New Messaging.SingleEmailMessage[] {email});
                //}
                email = Messaging.renderStoredEmailTemplate(templateId, NULL, whatId);
            } catch(Exception e) {
                System.debug('Email Failed: ' + e.getMessage());
            }
            //Database.rollback(sp);
            String initials = '';
            String globalTPProcessorInitials = '';
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setCharset('UTF-8');  
            emailToSend.setToAddresses(new List<string>{sendTo});
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(email.getHTMLBody()));
            if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                initials = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
            }
            if(tpaRequest.Co_Assigned_Global_TP_Processor__r.Is_Active__c) {
                globalTPProcessorInitials = tpaRequest.Co_Assigned_Global_TP_Processor__r.Initials__c;
            }
            emailToSend.setSubject(SRV_TPA_TPARequest.setEmailInitials(initials, globalTPProcessorInitials, email.getSubject()));
            emailToSend.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Address_For_Data_Release__c);
            emailToSend.setWhatId(whatId);
            //emailToSend.setEntityAttachments(lstIds); 
            emailToSend.setFileAttachments(lstAttachment);
            emailToSend.setSaveAsActivity(true);
            emailToSend.setUseSignature(false); 
            emailToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
            emailToSend.setTreatTargetObjectAsRecipient(false);
            
            if(ccAddress == null) {
               ccAddress = new List<String>();
            }
            
            if(ccAddress != null && ccAddress.size() > 0) {
                emailToSend.setCcAddresses(ccAddress);
            }
            List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
            msgListToBeSend.add(emailToSend);
            try {
                if(msgListToBeSend != null && msgListToBeSend.size() > 0 && UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                    Messaging.sendEmail(msgListToBeSend);
                    if(!isManualCopyofSigned) {
                        SRV_TPA_TPARequest.updateActivityHistory(whatId, 'Copy of Executed Email Sent', true);
                    }
                }
            } catch(Exception e) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_TPARequest.sendAcknowledgementToVendor:::Copy of Executed Email Failed', whatId != null ? whatId : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                // TODO
                //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
                //TPAQueryHelper.setLogObject(reqId, 'Exception:Exception Occurred in Sending the Copy Of Signed',e.getMessage()+'*'+e.getLineNumber()); 
                //TPAQueryHelper.logRef().generateLog();  
                System.debug('Email Failed: ' + e.getMessage());
            }
        } catch(Exception exp) {
            // TODO
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            //TPAQueryHelper.setLogObject(reqId, 'Exception:Exception Occurred in Sending the Copy Of Signed',exp.getMessage()+'*'+exp.getLineNumber()); 
            //TPAQueryHelper.logRef().generateLog();  
            System.debug(exp.getMessage()); 
        }
    }

    public static void voidEnvelopeCall(Set<Id> stAgreementCancelled, String voidReason) {
        system.debug('#### in Void envelope method');
        try {
            String reasonToVoid = '';
            List<String> lstStatusVoided = new List<String>();
            List<dsfs__DocuSign_Status__c> statusList = [select id,
                                                                TPA_Request__r.Vendor_Language__c,
                                                                dsfs__DocuSign_Envelope_ID__c
                                                         from dsfs__DocuSign_Status__c
                                                         where  dsfs__Envelope_Status__c in ('Sent','Delivered') 
                                                         and TPA_Request__c in: stAgreementCancelled 
                                                         limit 1];
            String envID = '';
            //Void Envelope for cancel and expired
            for(dsfs__DocuSign_Status__c objStatus: statusList ) {
                envid = objStatus.dsfs__DocuSign_Envelope_ID__c;

                if(voidReason == 'Resubmission Void Reason') {
                    Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{objStatus.TPA_Request__r.Vendor_Language__c + '_Translation__c'});
                    reasonToVoid = multilanguageUtilityMap == null ? 'Envelope is Corrected' : (String)multilanguageUtilityMap.get(objStatus.TPA_Request__r.Vendor_Language__c + '_Translation__c~TPA_Request__c~Record~ResubmissionVoidReason')[0].get(objStatus.TPA_Request__r.Vendor_Language__c + '_Translation__c');
                    system.debug('####TPA_TriggerHelper_Agreement.voidEnvelope multilanguageUtilityMap= ' + multilanguageUtilityMap); 
                } else {
                    reasonToVoid = voidReason;
                }
            }
            system.debug('#### reasonToVoid:'+reasonToVoid);
            system.debug('#### env id:'+envid);
            UTL_TPA.isEnvelopeVoided = true;
            UTL_TPA.isCancelledBySystem = true;
            system.debug('#### calling method: SRV_TPA_DocusignEnvelope.voidEnvelope');
            SRV_TPA_DocusignEnvelope.voidEnvelope(envID, reasonToVoid); 
            system.debug('#### finished method: SRV_TPA_DocusignEnvelope.voidEnvelope');
        } catch(Exception ex) {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::TGRH_TPARequest.voidEnvelopeCall:::Void Envelope Error', '');
            System.debug('####TPA_TriggerHelper_Agreement.voidEnvelope an error occured: '+ex.getMessage()+', Line: '+ex.getLineNumber()+', Cause: '+ex.getCause());
        }
    }

    //Share tpa request with associated tp processors and super users.
    public void manageSharing(list<TPA_Request__c> requestList) {
        try {
            //Key : User's Contact id
            //Value : User
            Map<id, User> contactIdUserMap = new Map<id, User>();
            
            for(User user : [select Id, Name, ContactId, Profile.Name
                                from User
                                where isActive = true
                                and (Profile.Name like 'Super User Profile CCP' 
                                or Profile.Name like 'TPA Processor Profile CCP' 
                                or Profile.Name like 'US TP Processor Profile CCP')]) {
                contactIdUserMap.put(user.ContactId, user);
            }
            System.Debug('contactIdUserMap.size() = ' + contactIdUserMap.size());
            
            //Key : Address id
            //Value : Contact id
            List<Contact_Address_Crosswalk__c> conAddCrosswalkObjList = [SELECT Address__c, Contact__c from Contact_Address_Crosswalk__c where Contact__c IN :contactIdUserMap.keySet()];
            System.Debug('conAddCrosswalkObjList.size() = ' + conAddCrosswalkObjList.size());
            
            //Key : Address__c Id
            //Value : List of Contact Ids associted with Addresses ids
            Map<Id, List<Id>> addressIdContactIdListMap = new Map<Id, List<Id>>();
            for(Contact_Address_Crosswalk__c conAddCrosswalkObj: conAddCrosswalkObjList) {
                List<Id> tempCrosswalkList = new List<Id>(); // Contact id List
                if(addressIdContactIdListMap.containsKey(conAddCrosswalkObj.Address__c)) {
                    tempCrosswalkList = addressIdContactIdListMap.get(conAddCrosswalkObj.Address__c);
                }
                tempCrosswalkList.add(conAddCrosswalkObj.Contact__c);
                addressIdContactIdListMap.put(conAddCrosswalkObj.Address__c, tempCrosswalkList);
            }
            System.Debug('addressIdContactIdListMap.size() = ' + addressIdContactIdListMap.size());
            System.Debug('addressIdContactIdListMap = ' + addressIdContactIdListMap);
        
            //Key : UserOrGroupId + ParentId
            //Value : TPA_Request__Share
            map<String, TPA_Request__Share> oldShareRecordsMap = new map<String, TPA_Request__Share>();
            for(TPA_Request__Share oldShareRecord : [SELECT Id, UserOrGroupId, ParentId
                                                        FROM TPA_Request__Share
                                                        WHERE ParentId IN :requestList
                                                        AND (RowCause = :Schema.TPA_Request__Share.rowCause.TP_Processor__c  
                                                        OR RowCause = :Schema.TPA_Request__Share.rowCause.Super_User__c 
                                                        or RowCause = 'Manual')]) {
                oldShareRecordsMap.put('' + oldShareRecord.UserOrGroupId + oldShareRecord.ParentId, oldShareRecord);
            }
            system.debug('oldShareRecordsMap.size() = ' + oldShareRecordsMap.size());

            List<TPA_Request__Share> sharingRecords = new List<TPA_Request__Share>();

            for(TPA_Request__c request : requestList) {
               
                if(request.Request_Status__c != 'Client Draft' && request.Request_Status__c != 'Client Submitted') { 
                    List<Id> tpProcessorContactIdList = addressIdContactIdListMap.get(request.TPA_Processor_Account_Address__c);
                    system.debug('tpProcessorContactIdList = ' + tpProcessorContactIdList);
                    if(tpProcessorContactIdList != null) {
                        for(Id contactid: tpProcessorContactIdList) {
                            User tpProcessor = contactIdUserMap.get(contactid);
                           
                            if( (tpProcessor.id != request.OwnerId) 
                                && contactid == request.TPA_Processor_Contact__c
                                && ( tpProcessor.Profile.Name == 'TPA Processor Profile CCP'  || tpProcessor.Profile.Name == 'US TP Processor Profile CCP' )
                                ) {
                                    if(oldShareRecordsMap.get('' + tpProcessor.Id + request.Id) == null) {
                                        system.debug('In TP Processor check --> Share ' + request.Name + 'with ' + tpProcessor.name + tpProcessor.id);
                                        TPA_Request__Share requestShare = new TPA_Request__Share();
                                        requestShare.ParentId = request.Id;
                                        requestShare.UserOrGroupId = tpProcessor.Id;
                                        requestShare.AccessLevel = 'Edit';
                                        requestShare.RowCause = Schema.TPA_Request__Share.RowCause.TP_Processor__c;
                                        sharingRecords.add(requestShare);
                                    }
                                    else {
                                        //system.debug('Existing Sharing Record for ' + request.Name + 'and ' + user.name + user.id);
                                        oldShareRecordsMap.remove('' + tpProcessor.Id + request.Id);
                                    }
                                }
                        }
                    }
                    
                    List<Id> superUserContactIdList = addressIdContactIdListMap.get(request.Client_Company_Name_Address__c);
                    system.debug('superUserContactIdList = ' + superUserContactIdList);
                    
                    if(superUserContactIdList != null) {
                        for(Id contactid: superUserContactIdList) {
                            User superUser = contactIdUserMap.get(contactid);
                           
                            
                            if(superUser.id != request.OwnerId && superUser.Profile.Name == 'Super User Profile CCP') {
                                if(oldShareRecordsMap.get('' + superUser.Id + request.Id) == null) {
                                    system.debug('In Super user check --> Share ' + request.Name + ' with ' + superUser.name + ' ' + superUser.id);
                                    TPA_Request__Share requestShare = new TPA_Request__Share();
                                    requestShare.ParentId = request.Id;
                                    requestShare.UserOrGroupId = superUser.Id;
                                    requestShare.AccessLevel = 'Edit';
                                    requestShare.RowCause = Schema.TPA_Request__Share.RowCause.Super_User__c;
                                    sharingRecords.add(requestShare);
                                } else {
                                    oldShareRecordsMap.remove('' + superUser.Id + request.Id);
                                }
                            }
                        }
                    }
                    DAOH_TpaRequest.isManageSharingTriggerd = true;
                }
            }
            
            system.debug('sharingRecords = ' + sharingRecords);
            system.debug('oldShareRecordsMap.size() After = ' + oldShareRecordsMap.size());

            if(oldShareRecordsMap != null && oldShareRecordsMap.size() > 0) {
                list<TPA_Request__Share> oldShareRecordDelete = new list<TPA_Request__Share>();
                for(TPA_Request__Share oldReq : oldShareRecordsMap.values()) {
                    oldShareRecordDelete.add(oldReq);
                }
                if(oldShareRecordDelete.size() > 0) {
                    delete oldShareRecordDelete;
                }
                system.debug('Old sharing Records deleted successfully.');
            }

            if(sharingRecords != null && sharingRecords.size() > 0) {
                Database.SaveResult[] results = Database.insert(sharingRecords, false);

                // Create counter
                Integer i=0;

                for(Database.SaveResult result : results) {
                    if(!result.isSuccess()) {
                        // Get the first save result error
                        Database.Error err = result.getErrors()[0];
                        system.debug('Exception :  ' + err.getMessage() + ' for TPA Request Id ' + sharingRecords[i].ParentId);
                    }
                    i++;
                }
            }            
        }
        catch(Exception ex) {
            System.debug('Exception Occured : ' + ex.getMessage());
        }
    }
    /*public void sendGSTINInvoiceMail(AMA_Agreement_Detail__c amaAgreement,Attachment amaAttachment){

        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        
	 	Messaging.SingleEmailMessage emailNotToSend = new  Messaging.SingleEmailMessage();
        
        String templateName = 'GSTIN / VAT number Invoice Mail';
        id templateid = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get(templateName + 'English').Translated_Template_Id__c;
        if(templateid != null){
            emailNotToSend = Messaging.renderStoredEmailTemplate(templateid, NULL, amaAgreement.TPA_Request__c);
        }
        
        emailToSend.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
        
        if(amaAttachment != null){
            efa.setFileName(amaAttachment.Name);
            efa.setBody(amaAttachment.Body);
            efa.setContentType(amaAttachment.ContentType);
        } 
        emailToSend.setWhatId(amaAgreement.TPA_Request__c);
        String assignedTPProcessorInitials = '';
        String globalTPProcessorInitials = '';
        if(amaAgreement.TPA_request__c != null &&  amaAgreement.TPA_request__r.TPA_Assigned_TP_Processor__c != null && amaAgreement.TPA_request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            assignedTPProcessorInitials = amaAgreement.TPA_request__r.TPA_Assigned_TP_Processor__r.Initials__c;
        }
        if(amaAgreement.TPA_request__c != null &&  amaAgreement.TPA_request__r.Co_Assigned_Global_TP_Processor__c != null && amaAgreement.TPA_request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c ) {
            globalTPProcessorInitials = amaAgreement.TPA_request__r.Co_Assigned_Global_TP_Processor__r.Initials__c;
        }
        emailToSend.setSubject(SRV_TPA_TPARequest.setEmailInitials(assignedTPProcessorInitials, globalTPProcessorInitials, emailNotToSend.getSubject()));
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        if(amaAgreement.TPA_request__c != null){
            if(amaAgreement.TPA_Request__r.TP_Processor_Email__c != null)
                ccAddresses.add(amaAgreement.TPA_request__r.TP_Processor_Email__c);
            if(amaAgreement.TPA_Request__r.Vendor_Contact_e_mail__c != null)
                toAddresses.add(amaAgreement.TPA_Request__r.Vendor_Contact_e_mail__c);
            if(amaAgreement.TPA_Request__r.Vendor_Compliance_Email__c != null)
                toAddresses.add(amaAgreement.TPA_Request__r.Vendor_Compliance_Email__c);
            if(amaAgreement.TPA_Request__r.Authorized_Signer_Email__c != null)
                toAddresses.add(amaAgreement.TPA_Request__r.Authorized_Signer_Email__c);
            if(amaAgreement.TPA_Request__r.Vendor_Contact_Email_Client__c != null)
                toAddresses.add(amaAgreement.TPA_Request__r.Vendor_Contact_Email_Client__c);
            if(amaAgreement.TPA_Request__r.Service_provider_Address__c != null && amaAgreement.TPA_Request__r.Service_provider_Address__r.TPAOtherEmailIds__c != null)
                toAddresses = UTL_TPA_Multilingual.ccList(amaAgreement.TPA_Request__r.Service_provider_Address__r.TPAOtherEmailIds__c, toAddresses);
        }
        List<TPA_Contact__c> addContactsList = SRV_TPA_TPARequest.getContactsForRequest(amaAgreement.TPA_request__c);
        for(TPA_Contact__c addContacts : addContactsList){
            if(addContacts.Type__c == 'Additional Vendor Contact')
                toAddresses.add(addContacts.Email__c);
        }        
        
        if(UTL_TPA.TPA_AdminEmailID != null && UTL_TPA.TPA_AdminEmailID != '') {
            toAddresses.add(UTL_TPA.TPA_AdminEmailID);
        }
        if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != ''){
            ccAddresses.add(UTL_TPA.sharedEmailAddress);
        }
        emailToSend.setToAddresses(ToAddresses);
        emailToSend.setCCAddresses(ccAddresses);
        emailToSend.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
        try{
            if(!Test.isRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{emailToSend});
            }
        }catch(Exception exc){
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, exc.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exc.getLineNumber() + ':::TGRH_TPARequest.sendGSTINInvoiceMail:::GSTIN Invoice Mail Failed', amaAgreement.id != null ? amaAgreement.id : '');

            system.debug(exc);
        }
    }*/
}
