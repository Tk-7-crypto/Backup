public without sharing class TGRH_TPAMasterExtensionInformation { 
    public static void onBeforeUpdate(List<TPA_Master_Extension_Information__c> newTPAMasterExtList, List<TPA_Master_Extension_Information__c> oldTPAMasterExtList, Map<Id,TPA_Master_Extension_Information__c> newTPAMasterExtMap, Map<Id,TPA_Master_Extension_Information__c> oldTPAMasterExtMap) {
        for(TPA_Master_Extension_Information__c masterExtObj :newTPAMasterExtList){
            if(masterExtObj.Return_Destruction_Ack_Outstanding__c == false && 
               (masterExtObj.DDN_Ack_Pending_Requests__c == null || masterExtObj.DDN_Ack_Pending_Requests__c == ''))
               masterExtObj.On_Hold_TPA_Requests__c = '';
        }
    }

    public static void updatePendingTPARequests(List<TPA_Master_Extension_Information__c> newTPAMasterExtList, List<TPA_Master_Extension_Information__c> oldTPAMasterExtList, Map<Id,TPA_Master_Extension_Information__c> newTPAMasterExtMap, Map<Id,TPA_Master_Extension_Information__c> oldTPAMasterExtMap) {
        List<id> lstTpaRequest = new List<id>();
        Set<id> setAllVendorId = new Set<id>();
        Set<id> setGlobalAddressId = new Set<id>();
        
        if(trigger.isUpdate && Trigger.isAfter) {
            for(TPA_Master_Extension_Information__c masterExtObj :newTPAMasterExtList){
                if(masterExtObj.Return_Destruction_Ack_Outstanding__c == false && 
                   (masterExtObj.DDN_Ack_Pending_Requests__c == null || masterExtObj.DDN_Ack_Pending_Requests__c == '')
                   && masterExtObj.TPA_Accounts_Address__c != null)
                    setGlobalAddressId.add(masterExtObj.TPA_Accounts_Address__c);
            }
            system.debug('setGlobalAddressId:' + setGlobalAddressId);
            for(Address__c addObj:[Select id,(select id from ChildAddresses__r) from Address__c where id in : setGlobalAddressId]) {
                setAllVendorId.add(addObj.id);
                if(addObj.ChildAddresses__r != null && addObj.ChildAddresses__r.size() > 0){
                    for(Address__c childAdd:addObj.ChildAddresses__r){
                        setAllVendorId.add(childAdd.id);
                    }
                }
            }
            system.debug('setAllVendorId:' + setAllVendorId);


            if(setAllVendorId != null && setAllVendorId.size() > 0){
                for(TPA_Request__c reqObj : [Select id,name from TPA_Request__c where Service_Provider_Address__c in : setAllVendorId 
                                             and (Request_Status__c = 'Pending Vendor Response on Data Destruction from Prior TPAs' or 
                                             (Request_Status__c = 'In Review By IQVIA' and Manual_Trigger_Reasons__c includes ('Vendor DDN Acknowledgement Outstanding')))]){
                                                 updateRequest(JSON.serialize(reqObj));                 
                                             }
            }
            
        }
        
    } 
    
    @future(callout=true)
    public static void updateRequest(String requestDetail) {
        TPA_Request__c reqObj = (TPA_Request__c)JSON.deserialize(requestDetail, TPA_Request__c.class);
        reqObj = SRV_TPA_TPARequest.getRequestInfo(reqObj.id);

        reqObj = SRV_TPA_TPARequest.getRequestStatus(reqObj);
      
      //  SRV_TPA_TPARequest.istriggerManualReviewReasonsOnly = true; //For stop reseting ama after on hold removal
    //    SRV_TPA_TPARequest.isDynamicNotificationRequiredForVendor(reqObj.Service_Provider_Address__c,reqObj.id,reqObj.Vendor_Billing_Mailing_Country__c, true); 

    //    reqObj = SRV_TPA_TPARequest.manualApproval(reqObj);
        if(reqObj.Request_Status__c == 'In Auto Approval Process'){
            reqObj.TLLA_Batch_Call_Sent_On__c = null;
            reqObj.isbatchProcessing__c = false;
            reqObj.Requires_Manual_Review__c = false;
        }

        // if(reqObj.AMA_USPrescriberData__c == 'Yes' && reqObj.Service_Provider_Address__c != null) {
        //     System.debug('in ama point discuss');
        //     String tpaRequestJSON = JSON.serialize(reqObj);
        //     reqObj = SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(tpaRequestJSON);
        // }      //For stop reseting ama after on hold removal
        
        TGRH_TPARequest.runAllCompletedBlock = true;
        update reqObj;
        TGRH_TPARequest.runAllCompletedBlock = false;

        Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{'English_Translation__c','Japanese_Translation__c'});
        if(Test.isRunningTest())
            multilanguageUtilityMap = null;
        String voidReason = multilanguageUtilityMap == null ? 'Account Placed on Hold due to Failure to Acknowledge DDN' : (String)multilanguageUtilityMap.get(reqObj.Vendor_Language__c + '_Translation__c~TPA_Request__c~Record~On_Hold')[0].get(reqObj.Vendor_Language__c + '_Translation__c');
        
        if( reqObj.Request_Status__c == 'In Review By IQVIA' && reqObj.Docusign_Status__r != null && reqObj.Docusign_Status__r.size() > 0 && reqObj.Docusign_Status__r[0].dsfs__Envelope_Status__c== 'voided' && reqObj.Docusign_Status__r[0].dsfs__Voided_Reason__c == voidReason && (reqObj.Docusign_Status__r[0].dsfs__Voided_Date_Time__c > reqObj.Client_Request_Submission__c || reqObj.Docusign_Status__r[0].dsfs__Voided_Date_Time__c >reqObj.Vendor_App_Submitted__c)){
            SRV_TPA_TPARequest.sendReminderMailtoTPProcessorAbtStatusUpdate(reqObj);
        }
        else {
            SRV_TPA_TPARequest.sendMailtoTPProcessorAbtStatusUpdate(reqObj,'Pending Vendor Response on Data Destruction from Prior TPA',reqObj.request_status__c);
        }
    }
    
}
