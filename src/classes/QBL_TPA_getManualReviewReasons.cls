public class QBL_TPA_getManualReviewReasons implements Queueable,Database.AllowsCallouts { 
    public TPA_Request__c request; 
    public Boolean isSubContractAdded;
    public Boolean isAwaitingClientConfirmationMailReq;
    public Boolean isdynamicOffNoticationReqOrNot;
    public String authorizedSignerResponse;
    public String LastAction;
    public String type;
    public String requestNumber;
    public List<TPA_Offering_Notification_Mapping__c> dynamicOfferingsNotificationListForVendor;
    public Boolean isDirectToClientExeMode;
    public Boolean isQuintilesIMSSalesExeMode;
    public String langFieldName;
    public Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap;
    public Boolean isVendorChecklistChanges;
    public String runType;
    public String GUID = '';
    public List<TPA_Commercial_Review__c> commercialReasonListSecond;

    public void execute(QueueableContext context) {
        SRV_TPA_TPARequest.tpaRequest = request;
        SRV_TPA_TPARequest.authorizedSignerResponse = authorizedSignerResponse;
        SRV_TPA_TPARequest.dynamicOfferingsNotificationListForVendor = dynamicOfferingsNotificationListForVendor;
        SRV_TPA_TPARequest.isDirectToClientExeMode = isDirectToClientExeMode;
        SRV_TPA_TPARequest.isQuintilesIMSSalesExeMode = isQuintilesIMSSalesExeMode;
        SRV_TPA_TPARequest.getManualReviewReasons(request);
        if(request.AMA_USPrescriberData__c == 'Yes' && request.Service_Provider_Address__c != null) {
                String tpaRequestJSON = JSON.serialize(request);
                request = SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(tpaRequestJSON);
        }

        system.debug('SRV_TPA_TPARequest.approvalNotificationMap:' + SRV_TPA_TPARequest.approvalNotificationMap);
        QBL_TPA_updateVendorDetails updateVendorDetailsObj = new QBL_TPA_updateVendorDetails();
        updateVendorDetailsObj.request = request;
        
        if(runType == 'VendorSubmission' || runType == 'TPProcesscorSubmission'){
            updateVendorDetailsObj.langFieldName = langFieldName;
            updateVendorDetailsObj.multilanguageUtilityMap = multilanguageUtilityMap;
        }
        updateVendorDetailsObj.authorizedSignerResponse = authorizedSignerResponse;
        updateVendorDetailsObj.reasonForAmaApprovalMap = SRV_TPA_TPARequest.reasonForAmaApprovalMap;
        updateVendorDetailsObj.approvalNotificationMap = SRV_TPA_TPARequest.approvalNotificationMap;
        updateVendorDetailsObj.includeAmaAttributesOnly = SRV_TPA_TPARequest.includeAmaAttributesOnly;
        updateVendorDetailsObj.isAwaitingClientConfirmationMailReq = isAwaitingClientConfirmationMailReq;
        updateVendorDetailsObj.isdynamicOffNoticationReqOrNot = isdynamicOffNoticationReqOrNot;
        updateVendorDetailsObj.isVendorChecklistChanges = isVendorChecklistChanges;
        updateVendorDetailsObj.manualReviewReasonList = SRV_TPA_TPARequest.manualReviewReasonList;
        updateVendorDetailsObj.runType = runType;
        updateVendorDetailsObj.isDirectToClientExeMode = isDirectToClientExeMode;
        updateVendorDetailsObj.isQuintilesIMSSalesExeMode = isQuintilesIMSSalesExeMode;
        updateVendorDetailsObj.DDNAckPendingRecords = SRV_TPA_TPARequest.DDNAckPendingRecords;
        if(SRV_TPA_TPARequest.commercialReasonMap != null && SRV_TPA_TPARequest.commercialReasonMap.size() > 0) {
            updateVendorDetailsObj.commercialReasonListSecond = SRV_TPA_TPARequest.commercialReasonMap.values();
        }
        
        if(!Test.isRunningTest()){
            System.enqueueJob(updateVendorDetailsObj);
        } 
        
    }

}
