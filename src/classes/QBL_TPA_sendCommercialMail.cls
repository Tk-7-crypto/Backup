public class QBL_TPA_sendCommercialMail implements Queueable,Database.AllowsCallouts { 
    public TPA_Request__c request; 
    public Map<String, Map<String, Map<String, String>>> BUPurposeGeoLevelDataAssetMap;
    public boolean sendVendorSecondaryEmail;
    public boolean sendSecondaryEmail;
    public Boolean isAwaitingClientConfirmationMailReq;
    public Boolean isdynamicOffNoticationReqOrNot;
    public Boolean isSecComReview;
    public List<TPA_Commercial_Review__c> commercialReasonListSecond;
    public String runType;
    public static Boolean isComReviewsInsert = false;
    public void execute(QueueableContext context) {
        SRV_TPA_TPARequest.tpaRequest = request;
        SRV_TPA_TPARequest.isSecComReview = isSecComReview;
        if(commercialReasonListSecond != null && commercialReasonListSecond.size() > 0) {
            try {
                isComReviewsInsert = true;
                upsert commercialReasonListSecond;
                isComReviewsInsert = false;
            } catch(Exception ex) {
                system.debug('ErrorCpc:'+ex.getMessage());
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::QBL_TPA_sendCommercialMail:::update Com Records', request != null ? request.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
            
        }
        
        List<TPA_Commercial_Review__c> finalCommercialReviews = [Select Id,Is_Review_Secondary__c,Manual_Review_Reason__c,Status__c,TPA_Request__c From TPA_Commercial_Review__c where TPA_Request__c =: request.Id];
        Boolean isPrimaryApp = true,isAllSecondary = true,isAllRevApproved = true;
        boolean sendLegalMail = false;
        boolean sendVendorSecondaryEmail = false;
        boolean sendSecondaryEmail = false;
        List<TPA_Commercial_Review__c> secondaryReviews = new List<TPA_Commercial_Review__c>();
        List<TPA_Commercial_Review__c> secondaryReviewsToUpdate = new List<TPA_Commercial_Review__c>();
        
        for(TPA_Commercial_Review__c comRev:finalCommercialReviews){
            if(comRev.Status__c == null || (!comRev.Status__c.contains('Approved') && comRev.Status__c != 'Complete' )){
                isAllRevApproved = false;
            }
            if(comRev.Status__c == null || (!comRev.Is_Review_Secondary__c && !comRev.Status__c.contains('Approved') && comRev.Status__c != 'Complete' )){
                isPrimaryApp = false;
            }
            if(comRev.Is_Review_Secondary__c && !comRev.Status__c.contains('Approved')){
                secondaryReviews.add(comRev);
            }
            if(!comRev.Is_Review_Secondary__c){
                isAllSecondary = false;
            }
        }
        if(!isPrimaryApp && secondaryReviews != null && secondaryReviews.size() > 0){
            system.debug('in first if ****');
            sendVendorSecondaryEmail = false;
            sendSecondaryEmail = false;
            for(TPA_Commercial_Review__c comRev: secondaryReviews){
                if(comRev.Status__c == 'Awaiting Review'){
                    comRev.Status__c = 'Awaiting to Send: Primary Commercial Owner Not Complete';
                    comRev.Action__c = null;
                    secondaryReviewsToUpdate.add(comRev);
                }
            }
        }
        else if((isPrimaryApp || isAllSecondary) && secondaryReviews != null && secondaryReviews.size() > 0){
            system.debug('in second if ****');
            for(TPA_Commercial_Review__c comRev: secondaryReviews){
                if(comRev.Status__c == 'Awaiting to Send: Primary Commercial Owner Not Complete'){
                    comRev.Status__c = 'Awaiting Review';
                    comRev.Action__c = null;
                    secondaryReviewsToUpdate.add(comRev);
                }
                if(comRev.Manual_Review_Reason__c == 'Vendor Requires Secondary Review'){
                    sendVendorSecondaryEmail = true;
                }
                if(UTL_TPA.isManualReviewAddHoc(comRev.Manual_Review_Reason__c)){
                    sendLegalMail = true;
                }
                if(!sendLegalMail && !sendVendorSecondaryEmail){
                    sendSecondaryEmail = true;
                }
                if(sendVendorSecondaryEmail && sendLegalMail && sendSecondaryEmail){
                    break;
                }
            }
        }
        if(secondaryReviewsToUpdate.size() > 0 || sendVendorSecondaryEmail || sendLegalMail || sendSecondaryEmail){
            SRV_TPA_TPARequest.isSecComReview = true;
        }
        
        SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
        
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
            SRV_TPA_DocusignEnvelope.generateDocForSign(request.Id, UTL_LogFactory.GUID); 
        }
    }
}
