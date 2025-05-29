public without sharing class TGRH_VendorOfferingReturnAck { 
	
	public static void updateExcludedOfferingsDetails(List<Vendor_Offering_Return_Acknowledgment__c> newVendorOfferingReturnList){
        Set<Id> tpaRequests = new Set<Id>();
        Map<Id,Id> reqAndRenewedReq = new Map<Id,Id>();
        Map<Id,String> tpaRequestsWithExcludedOfferings = new Map<Id,String>();
        if(trigger.isBefore){
            for(Vendor_Offering_Return_Acknowledgment__c voraEntry : newVendorOfferingReturnList){
                tpaRequests.add(voraEntry.TPA_Request__c);
            }
            for(TPA_Request__c tpaReq :[Select id, 
                                        name, 
                                        Renewed_As__c,
                                        Renewed_As__r.Is_Partially_Renewed__c                                      
                                        from TPA_Request__c 
                                        where id in : tpaRequests]){
                if(tpaReq.Renewed_As__r.Is_Partially_Renewed__c){
                    reqAndRenewedReq.put(tpaReq.Renewed_As__c,tpaReq.Id);   
                    System.debug('hello');
                }                        
            }
            for(TPA_Request__c tpaReq : [select id, name, (select id, Excluded_Offerings_In_Renewal__c from TPA_Agreement_Additional_Fields__r)
                                        from TPA_Request__c where id in : reqAndRenewedReq.keySet()]){
                if(tpaReq.TPA_Agreement_Additional_Fields__r != null && tpaReq.TPA_Agreement_Additional_Fields__r.size() > 0){
                    tpaRequestsWithExcludedOfferings.put(reqAndRenewedReq.get(tpaReq.Id),tpaReq.TPA_Agreement_Additional_Fields__r[0].Excluded_Offerings_In_Renewal__c);
                }                            
            }
            for(Vendor_Offering_Return_Acknowledgment__c voraEntry : newVendorOfferingReturnList){
                if(tpaRequestsWithExcludedOfferings.get(voraEntry.TPA_Request__c) != null){
                    voraEntry.Excluded_Offerings_In_Renewal__c = tpaRequestsWithExcludedOfferings.get(voraEntry.TPA_Request__c);
                }
            }
        }
    }
	
    public static void updateAddressExtensionRecords( List<Vendor_Offering_Return_Acknowledgment__c> newVendorOfferingReturnList) {
        Set<id> lstTpaRequest = new Set<id>();
        List<TPA_Request__c> lstTpaRequestToBeUpdated = new List<TPA_Request__c>();
        Map<Id, TPA_Request__c> tpaRequestToUpdate = new Map<Id, TPA_Request__c>();
        List<Watch_List_History__c> watchHistories = new List<Watch_List_History__c>();
        if((trigger.isInsert && Trigger.isAfter)|| (trigger.isUpdate && Trigger.isAfter)){
            for(Vendor_Offering_Return_Acknowledgment__c offReturnAckObj :newVendorOfferingReturnList){
                lstTpaRequest.add(offReturnAckObj.TPA_Request__c);
            }
            UTL_TPA.getRequestToAddressMap(lstTpaRequest);
            List<TPA_Master_Extension_Information__c> lstTpaMastExtension = new List<TPA_Master_Extension_Information__c>();
            for(TPA_Request__c reqObj : [Select id, 
                                                name, 
                                                Client_Email__c, 
                                                Is_DDN_Pending_Request__c, 
                                                TP_Processor_Email__c, 
                                                Renewed_As__c,
                                                Renewed_As__r.Is_Partially_Renewed__c                                      
                                        from TPA_Request__c 
                                        where id in : lstTpaRequest]) {
                //if(reqObj.Renewed_As__r.Is_Partially_Renewed__c) {
                    //sendClientNotificationForNotSharingExcludedOfferings(reqObj);
                //}
                if(UTL_TPA.mapRequestToAddress != null && UTL_TPA.mapRequestToAddress.containsKey(reqObj.id+'-GBVendor')){
                    Address__c addObj = UTL_TPA.mapRequestToAddress.get(reqObj.id+'-GBVendor');
                    if(addObj.TPA_Master_Extension_Informations__r != null && addObj.TPA_Master_Extension_Informations__r.size() > 0) {
                        TPA_Master_Extension_Information__c extObj = addObj.TPA_Master_Extension_Informations__r[0];
                        if(extObj != null && extObj.DDN_Ack_Pending_Requests__c != null 
                        && extObj.DDN_Ack_Pending_Requests__c.contains(reqObj.name)) {
                            String DDNAckPendingRequests = extObj.DDN_Ack_Pending_Requests__c;
                            Boolean isReturnDestructionAckOutstanding = true; 
                            if(DDNAckPendingRequests.contains(', '+reqObj.name)){
                                DDNAckPendingRequests = DDNAckPendingRequests.remove(', '+reqObj.name);
                            }
                            else if(DDNAckPendingRequests.contains(reqObj.name +', ')){
                                DDNAckPendingRequests = DDNAckPendingRequests.remove(reqObj.name +', ');
                            }
                            else {
                                DDNAckPendingRequests = DDNAckPendingRequests.remove(reqObj.name);
                            }
                            if(DDNAckPendingRequests == ''){
                                isReturnDestructionAckOutstanding = false;
                            }
                           // reqObj.is_Vora_Record_present__c = true;
                            if(reqObj.Is_DDN_Pending_Request__c) {
                                reqObj.Is_DDN_Pending_Request__c = false;
                            }
                            //lstTpaRequestToBeUpdated.add(reqObj);
                            tpaRequestToUpdate.put( reqObj.Id, reqObj );
                            lstTpaMastExtension.add(new TPA_Master_Extension_Information__c(id =  extObj.id, DDN_Ack_Pending_Requests__c = DDNAckPendingRequests, Return_Destruction_Ack_Outstanding__c = isReturnDestructionAckOutstanding ));
                        }
                    }

                   
                }   
                
                if(trigger.isInsert && Trigger.isAfter){
                    if(tpaRequestToUpdate != null && tpaRequestToUpdate.get(reqObj.Id) != null) {
                        reqObj = tpaRequestToUpdate.get(reqObj.Id);
                        system.debug('Private case');
                        reqObj.is_Vora_Record_present__c = true;
                    }
                    else{
                        reqObj.is_Vora_Record_present__c = true;
                    }
                    tpaRequestToUpdate.put(reqObj.Id, reqObj);

                }
            	
            }
            
            
            for(Watch_List_History__c watchHistoryObj : [Select id from Watch_List_History__c where Pending_TPA_Request__c in : lstTpaRequest]){
                watchHistories.add(new Watch_List_History__c(id = watchHistoryObj.id, Request_removed_on_Date__c = Date.today()))  ;            
            }
            try{
                if(watchHistories != null && watchHistories.size() > 0){
                    update(watchHistories);
                }
                if(lstTpaMastExtension != null && lstTpaMastExtension.size() > 0){
                    update(lstTpaMastExtension);
                }
                // if(lstTpaRequestToBeUpdated != null && lstTpaRequestToBeUpdated.size() > 0){
                //     update(lstTpaRequestToBeUpdated);
                // }
                if(tpaRequestToUpdate != null && tpaRequestToUpdate.size() > 0 ) {
                    update tpaRequestToUpdate.values();
                }
            }
            catch(Exception e){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_VendorOfferingReturnAck:::updateAddressExtensionRecords::updation Error', null));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
        }
    } 

    public static void sendClientNotificationForNotSharingExcludedOfferings(TPA_Request__c reqObj) {
        TPA_Request__c renewedRequest;
        if(reqObj.Renewed_As__c != null) {
            system.debug('reqObj.Renewed_As__c: ' + reqObj.Renewed_As__c);
            List<TPA_Request__c> renewedRequestList =  [select id, name, (select id, Excluded_Offerings_In_Renewal__c from TPA_Agreement_Additional_Fields__r)
                                from TPA_Request__c where id =: reqObj.Renewed_As__c ];
            renewedRequest = renewedRequestList[0];
            system.debug('renewedRequest: ' + renewedRequest);
            system.debug('renewedRequest: ' + renewedRequest.TPA_Agreement_Additional_Fields__r);
        }
        List<String> toAddress = new List<String>();
        String emailBody;
        String subjText;
        toAddress.add(reqObj.Client_Email__c);
        if(reqObj.TP_Processor_Email__c != null) {
            toAddress.add(reqObj.TP_Processor_Email__c);
        }
        string vendorLanguage = (reqObj.vendor_language__c != null && reqObj.vendor_language__c != '') ? reqObj.vendor_language__c : 'English';
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Discontinue Offering Sharing' + vendorLanguage).Translated_Template_Id__c;
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
            System.debug('emailBody: ' + emailBody);
            System.debug('subjText: ' + subjText);
            //subjText = subjText.replace('old_status', OldStatus);
            //subjText = subjText.replace('new_status', newStatus);
            if(renewedRequest != null && renewedRequest.TPA_Agreement_Additional_Fields__r.size() > 0) {
                TPA_Agreement_Additional_Field__c aggObj = renewedRequest.TPA_Agreement_Additional_Fields__r[0];
                system.debug('aggObj' + aggObj.Excluded_Offerings_In_Renewal__c);
                string excludedOfferings = UTL_TPA.getOfferingDetailsToHtmlList(aggObj.Excluded_Offerings_In_Renewal__c);
                system.debug('excludedOfferings' + excludedOfferings);
                if(excludedOfferings != null && excludedOfferings != '') {
                    emailBody = emailBody.replace('Excluded_Offerings', '<div style="font-size:13px;font-family:arial;">' + excludedOfferings + '</div>');
                    System.debug('emailBody1: ' + emailBody);
                }
            } else {
                emailBody = emailBody.replace('Excluded_Offerings', '');
                System.debug('emailBody2: ' + emailBody);
            }
            System.debug('emailBody3: ' + emailBody);
            System.debug('subjText1: ' + subjText);
        }

        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, null, 'SendEmail', null, reqObj.Id, null, subjText, FALSE, emailBody, FALSE, FALSE, null);
    }
}
