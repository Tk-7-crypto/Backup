public class QBL_TPA_updateVendorDetails implements Queueable,Database.AllowsCallouts { 
    public TPA_Request__c request; 
    public String langFieldName;
    public Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap;
    public Map<String,String> reasonForAmaApprovalMap;
    public Boolean isAwaitingClientConfirmationMailReq;
    public Boolean isdynamicOffNoticationReqOrNot;
    public String authorizedSignerResponse;
    public Boolean includeAmaAttributesOnly;
    public Boolean isVendorChecklistChanges;
    public Map<String, String> approvalNotificationMap;
    public set<String> manualReviewReasonList;
    public Boolean isDirectToClientExeMode;
    public Boolean isQuintilesIMSSalesExeMode;
    public String runType;
    public String GUID = '';
    public List<TPA_Request__c> DDNAckPendingRecords;
    public List<TPA_Commercial_Review__c> commercialReasonListSecond;
    

    public void execute(QueueableContext context) {
        SRV_TPA_TPARequest.tpaRequest = request;
        SRV_TPA_TPARequest.authorizedSignerResponse = authorizedSignerResponse;
        SRV_TPA_TPARequest.reasonForAmaApprovalMap = reasonForAmaApprovalMap;
        SRV_TPA_TPARequest.approvalNotificationMap = approvalNotificationMap;
        SRV_TPA_TPARequest.includeAmaAttributesOnly = includeAmaAttributesOnly;
        SRV_TPA_TPARequest.isVendorChecklistChanges = isVendorChecklistChanges;
        SRV_TPA_TPARequest.manualReviewReasonList = manualReviewReasonList;
        CNT_TPA_RequestSubmissionForm.isAwaitingClientConfirmationMailReq = isAwaitingClientConfirmationMailReq;
        SRV_TPA_TPARequest.isDirectToClientExeMode = isDirectToClientExeMode;
        SRV_TPA_TPARequest.isQuintilesIMSSalesExeMode = isQuintilesIMSSalesExeMode;
        SRV_TPA_TPARequest.DDNAckPendingRecords = DDNAckPendingRecords;
        if(runType == 'VendorSubmission' || runType == 'TPProcesscorSubmission'){
            UTL_TPA_Multilingual.saveUseOfferingTranslatedNames(request.id, langFieldName, multilanguageUtilityMap);
            UTL_TPA_Multilingual.updateChildRecordsTranslation(request.id , null);
        }
        if(request.is_50_or_more_Offering_Present__c){
            SRV_TPA_TPARequest.sendNotificationfor50OrMoreLicenses(request);
        }
        SRV_TPA_TPARequest.updateAgreementFieldsForVendor(isdynamicOffNoticationReqOrNot);
        
        Boolean isRunCommercialAutoLogic = SRV_TPA_TPARequest.runCommercialAutoLogic();
        
        system.debug('is isRunCommercialAutoLogic: ' + isRunCommercialAutoLogic);
        
        if(isRunCommercialAutoLogic){
            QBL_TPA_sendCommercialMail tpaSendCommercialMailrQueueObj = new QBL_TPA_sendCommercialMail();
            tpaSendCommercialMailrQueueObj.request = request;
            tpaSendCommercialMailrQueueObj.BUPurposeGeoLevelDataAssetMap = SRV_TPA_TPARequest.BUPurposeGeoLevelDataAssetMap;
            tpaSendCommercialMailrQueueObj.sendVendorSecondaryEmail = SRV_TPA_TPARequest.sendVendorSecondaryEmail;
            tpaSendCommercialMailrQueueObj.sendSecondaryEmail = SRV_TPA_TPARequest.sendSecondaryEmail;
            tpaSendCommercialMailrQueueObj.isSecComReview = SRV_TPA_TPARequest.isSecComReview;
            tpaSendCommercialMailrQueueObj.isAwaitingClientConfirmationMailReq = isAwaitingClientConfirmationMailReq;
            tpaSendCommercialMailrQueueObj.isdynamicOffNoticationReqOrNot = isdynamicOffNoticationReqOrNot;
            tpaSendCommercialMailrQueueObj.runType = runType;
            tpaSendCommercialMailrQueueObj.commercialReasonListSecond = commercialReasonListSecond;
            
            if(!Test.isRunningTest()){
                System.enqueueJob(tpaSendCommercialMailrQueueObj);
            }
        }
        else{
            if(((request.Client_Off_Notification_Ack_Date__c != null && request.Vendor_Off_Notification_Ack_Date__c != null) || isAwaitingClientConfirmationMailReq) && isdynamicOffNoticationReqOrNot && request.Request_Status__c != 'Initializing Vendor')
            {
                System.debug('Call sent for notification...');
                SRV_TPA_TPARequest.isOffNotificationDocGenerated = true;
                TPA_Dyn_Off_Not_GeneratorQueue tpaDynOffNotGeneratorQueueObj = new TPA_Dyn_Off_Not_GeneratorQueue();
                tpaDynOffNotGeneratorQueueObj.reqId = request.Id;
                tpaDynOffNotGeneratorQueueObj.vendorAccountId = request.Service_Provider_Address__c;
                tpaDynOffNotGeneratorQueueObj.clientLanguage = request.Client_Language__c;
                tpaDynOffNotGeneratorQueueObj.vendorLanguage = request.Vendor_Language__c;
                tpaDynOffNotGeneratorQueueObj.reqName = request.Name;
                tpaDynOffNotGeneratorQueueObj.ClientContactEmail = request.ClientContact__r.email;
                tpaDynOffNotGeneratorQueueObj.isdynamicOffNotificationReqForVendor = isAwaitingClientConfirmationMailReq;
                tpaDynOffNotGeneratorQueueObj.reqStatus = request.Request_Status__c;
                tpaDynOffNotGeneratorQueueObj.GUID = UTL_LogFactory.GUID;
                tpaDynOffNotGeneratorQueueObj.runType = runType;
                if(!Test.isRunningTest()){
                    System.enqueueJob(tpaDynOffNotGeneratorQueueObj);
                }
            } else if(runType == 'RunTpaBusinessRule'){
                SRV_TPA_DocusignEnvelope.generateDocForSign(request.Id, GUID); 
            } 
        }
        
    }
    
}
