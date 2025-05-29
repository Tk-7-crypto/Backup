global class BCH_TPA_Agreement_UpdateStatus implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    List<TPA_request__c> tpaRequestToUpdate = new List<TPA_request__c>() ;
    List<Task> taskToInsertList = new List<Task>() ; 
    List<TPA_AMA_Settings__c> amaSetting;
    Boolean BatchForExpire = false;

    public Boolean includeTestDataOnly {
		get {
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}

    global BCH_TPA_Agreement_UpdateStatus () {
        amaSetting = TPA_AMA_Settings__c.getall().values();
    }
    
    global BCH_TPA_Agreement_UpdateStatus (Boolean forExpire) {
        BatchForExpire = forExpire;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string status ='Expired';  
        string cancelledStatus = 'Cancelled';
        string deniedStatus =  Label.TPA_IQVIA_Denied_Status; 
        String amaRenewalCancelationStatus = ''; 
        String clientDiscontinuedStatus = 'Client Discontinued';
        String amaCancelledStatus = 'AMA Cancelled';
        String amaDiscontinuedStatus = 'AMA Discontinued';
        String tpaIQVIA_AffiliateStatus = 'Closed-IQVIA Affiliate';
        String coveredByMOUStatus = 'Covered By MOU';
        String draftClosed = 'Draft Closed';
        String inEffect =  'In Effect';

        if(amaSetting != null && !amaSetting.isEmpty()) {
            amaRenewalCancelationStatus =  amaSetting.get(0).Vendor_Renewal_Cancelation_Status__c; 
        }

        String query = '';
        if(!BatchForExpire) {
            query = 'select id, Sent_for_Signatures_on__c, Signer__c, Signer__r.Name, Signer__r.dsfs__DocuSign_Recipient_Email__c, Data_Access_End_Date__c, (select id, Vendor_Specific_Notification_Response__c from TPA_Agreement_Additional_Fields__r), Request_Status__c ' + ', Vendor_Language__c' + ' from TPA_request__c where Is_Submitted__c = true and (( Request_Status__c not in (\'' + cancelledStatus + '\', \'' + deniedStatus + '\', \'' + status + '\', \'' + amaRenewalCancelationStatus + '\' , \'' + clientDiscontinuedStatus + '\' , \'' + amaCancelledStatus + '\' , \'' + amaDiscontinuedStatus + '\' , \'' + tpaIQVIA_AffiliateStatus + '\' , \'' + coveredByMOUStatus + '\', \'' + draftClosed + '\') and Data_Access_End_Date__c < '+(Datetime.now()).format('yyyy-MM-dd') + ')' + ' OR ( Request_Status__c = \'' + amaRenewalCancelationStatus + '\' AND Data_Access_End_Date__c = '+(Datetime.now()).format('yyyy-MM-dd') +'))'; 
        }
        else {
            query = 'select id, Related_TPA_Request__r.Early_Contract_Expiry_Date__c, Related_TPA_Request__r.Request_Status__c , Related_TPA_Request__c, Related_TPA_Request__r.Vendor_Language__c ' + ' from TPA_Agreement_Additional_Field__c where Related_TPA_Request__r.Early_Contract_Expiry_Date__c!= null and Related_TPA_Request__r.Early_Contract_Expiry_Date__c <= Today and Related_TPA_Request__r.Request_Status__c in (\'' + inEffect + '\') and Related_TPA_Request__r.Data_Access_End_Date__c > '+(Datetime.now().format('yyyy-MM-dd')); 
        }

        if(includeTestDataOnly && !BatchForExpire) {
            query += ' and (Client_Address__r.Name Like \'Test_'+'%\'  OR Service_Provider_f__c Like \'Test_'+'%\' )';
        }

        if(Test.isRunningTest()){
            query += ' limit 1';
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> objList) {
        try {
        	String amaRenewalCancelationStatus = ''; 
            if(amaSetting != null && !amaSetting.isEmpty()) {
                amaRenewalCancelationStatus =  amaSetting.get(0).Vendor_Renewal_Cancelation_Status__c; 
            }
            for(sobject sobj : objList){
                
                if(!BatchForExpire) {
                    TPA_request__c reqObj = (TPA_request__c)sobj;
                    if(reqObj.Request_Status__c == 'In Effect') {
                        reqObj.Request_Status__c = 'Expired';
                        updateActivityHistory(reqObj, 'Expired');
                    }else if(reqObj.Request_Status__c == amaRenewalCancelationStatus ) {
                        Date todayDate = Date.today(); 
                        system.debug('here');
                        if(reqObj.Data_Access_End_Date__c == todayDate){
                            CNT_TPA_ContinueNotificationProcess.sendDDNMail(reqObj.TPA_Agreement_Additional_Fields__r[0].Id, false);
                        }
                    }
                    else{
                        reqObj.Request_Status__c = 'Cancelled';
                        UTL_TPA.isCancelledBySystem = true;
                        updateActivityHistory( reqObj,'Cancelled' );
                    }
                    if(reqObj.Request_Status__c != amaRenewalCancelationStatus){
                        UTL_TPA.isEnvelopeVoided = true;
                        SRV_TPA_DocusignEnvelope.voidEnvelopeCallout(reqObj.id, reqObj.Vendor_Language__c); 
                        tpaRequestToUpdate.add(reqObj);
                    }
                }
                else {
                    TPA_Agreement_Additional_Field__c reqObj = (TPA_Agreement_Additional_Field__c)sobj;
                    if(reqObj.Related_TPA_Request__r.Request_Status__c == 'In Effect') {
                        TPA_request__c tpaRequestObj = new TPA_request__c();
                        tpaRequestObj.Id = reqObj.Related_TPA_Request__c;
                        tpaRequestObj.Request_Status__c = 'Expired';
            
                        updateActivityHistory(tpaRequestObj, 'Expired');
                        tpaRequestToUpdate.add(tpaRequestObj);
                        UTL_TPA.isEnvelopeVoided = true;
                        SRV_TPA_DocusignEnvelope.voidEnvelopeCallout(tpaRequestObj.id, reqObj.Related_TPA_Request__r.Vendor_Language__c);
                        CNT_TPA_ContinueNotificationProcess.sendDDNMail(reqObj.Id, false);
                    }
                }                          
            }
            if(tpaRequestToUpdate.size() > 0) {
                update tpaRequestToUpdate;
            }
            
            if(Test.isRunningTest()) {
                SRV_TPA_TPARequest.getCustomException();
            }
        } catch(Exception ex) {
            UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                FALSE, 
                                                UTL_LogFactory.GUID, 
                                                'Exception: in BCH_TPA_Agreement_UpdateStatus class execute method :: ' + ex.getMessage(), 
                                                'TPA', 
                                                'Exception', 
                                                'ERROR', 
                                                'Line#' + ex.getLineNumber() + ':::BCH_TPA_Agreement_UpdateStatus:::execute', 
                                                '');
        }
    }
    
    global void finish(Database.BatchableContext bc) {        
        try {
            if( taskToInsertList.size() > 0 ) {
                insert taskToInsertList;
            }
            if(Test.isRunningTest()) {
                SRV_TPA_TPARequest.getCustomException();
            }

            if(!BatchForExpire) {
                BCH_TPA_Agreement_UpdateStatus agrmntsUpdateBatchInstance= new BCH_TPA_Agreement_UpdateStatus(true);
                Database.executebatch(agrmntsUpdateBatchInstance ,1);
            }
        } catch(Exception ex) {
            UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                FALSE, 
                                                UTL_LogFactory.GUID, 
                                                'Exception: in BCH_TPA_Agreement_UpdateStatus class finish method :: ' + ex.getMessage(), 
                                                'TPA', 
                                                'Exception', 
                                                'ERROR', 
                                                'Line#' + ex.getLineNumber() + ':::BCH_TPA_Agreement_UpdateStatus:::finish', 
                                                '');
        }
    }
       
    private void updateActivityHistory(TPA_request__c tpaRequest, String subject) {
        Task task = new Task();
        task.WhatId = tpaRequest.Id;
        task.ActivityDate = system.today();
        task.Status = 'Completed';
        task.CallObject = subject;
        task.Subject = subject;
        
        taskToInsertList.add( task );
    }
}
