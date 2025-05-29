public class CNT_TPA_Multiple_Retrigger {
    public String tpaRequestId{get;set;}
    public List<TPA_Commercial_Review__c> commercialReviews = new List<TPA_Commercial_Review__c>();
    public String baseUrl {
        get{
        	if(baseUrl == null){
            	baseUrl = TPA_Settings__c.getOrgDefaults().Base_Url_Public__c;
        	}
        	return baseUrl;
    	}set;
    }
    public String commercialReviewsJson{
        get{
            if(tpaRequestId != null && commercialReviews.size() == 0){
                commercialReviews = [Select Id,Name,Status__c,Action__c,Retrigger_By__c,Retrigger_Date__c,Manual_Review_Reason__c, Action_Needed_By__c, Associated_Offering_to_Review__c, Associated_Use_to_Review__c, Receiver_s_Email__c,Is_ReviewForm_Acknowledged__c,BU__c, Commercial_Owner_Name__c, Date_of_Approval__c,Is_Review_Secondary__c From TPA_Commercial_Review__c where TPA_Request__c =: tpaRequestId];
                List<TPA_Commercial_Review__c> comRevs = new List<TPA_Commercial_Review__c>();
                for(TPA_Commercial_Review__c comRev: commercialReviews){
                    if( !(comRev.Action_Needed_By__c == 'Commercial Owner' && (comRev.Receiver_s_Email__c == null || comRev.Receiver_s_Email__c == '')) 
                       && !(comRev.Action_Needed_By__c == 'TP-country' 
                       && ( (comRev.Associated_Offering_to_Review__c != null && comRev.Associated_Offering_to_Review__c.contains('other'))  || (comRev.Associated_Use_to_Review__c != null && comRev.Associated_Use_to_Review__c.contains('other')) ) 
                       && comRev.Action__c != 'Assigned to Commercial Owner (CO) – Awaiting CO Review' )){
                       comRevs.add(comRev);    
                    }
                }
                commercialReviews = comRevs;
            }
            return JSON.serialize(commercialReviews); 
        }
        set;
    }
    public String requestNumber {
        get{
            if(requestNumber == null){
            	TPA_Request__c req = [Select Id,Name From TPA_Request__c where Id =: tpaRequestId Limit 1];
                requestNumber = req.Name;
            }
            return requestNumber;
        }
        set;
    }
    public CNT_TPA_Multiple_Retrigger(){
        tpaRequestId = ApexPages.currentpage().getparameters().get('Id');
    }
    
    @remoteAction
    public static String retriggerRecords(String recordIds,String allRecords,String reqName){
        String result = 'Fail';
        List<TPA_Commercial_Review__c> comRevRecords = (List<TPA_Commercial_Review__c>)JSON.deserialize(allRecords,List<TPA_Commercial_Review__c>.class);
        List<TPA_Commercial_Review__c> recordsToUpdate = new List<TPA_Commercial_Review__c>();
        String commonRevIds = '' , vendorSecRevIds = '', offSecRevIds ='' ;
        for(TPA_Commercial_Review__c comRevObj : comRevRecords){
            if(recordIds != null && recordIds.contains(comRevObj.Id)){
            	if(comRevObj.Is_ReviewForm_Acknowledged__c){
        			comRevObj.Is_ReviewForm_Acknowledged__c = false;
            		if(comRevObj.Action_Needed_By__c == 'TP-country' && comRevObj.Action__c != null && comRevObj.Action__c.contains('Assigned to Commercial Owner (CO) – Awaiting CO Review')){
                		comRevObj.Action_Needed_By__c = 'Commercial Owner';
            		}
            	}
        		comRevObj.Retrigger_By__c = UTL_TPA_Multilingual.CurrentUser.Name;
        		comRevObj.Retrigger_Date__c = Datetime.now();
                recordsToUpdate.add(comRevObj);
                if(comRevObj.Manual_Review_Reason__c == 'Offering Requires Secondary Commercial Review'){
                	offSecRevIds += comRevObj.Id + ';';
            	}
            	else if(comRevObj.Manual_Review_Reason__c == 'Vendor Requires Secondary Review'){
                	vendorSecRevIds += comRevObj.Id + ';';
            	}
            	else{
             		commonRevIds += comRevObj.Id + ';';   
            	}
            }
        }
        if(recordsToUpdate.size() > 0){
            update recordsToUpdate;
            result = 'Success';
            triggerEmails(commonRevIds,vendorSecRevIds,offSecRevIds,reqName);
        }
        
        return result;
    }
    
    @future
    public static void triggerEmails(String commonRevIds,String vendorSecRevIds,String offSecRevIds,String reqName){
        TPA_Request__c reqObj = [Select Id,Name,Is_South_Africa_Sub_Off__c,Is_Vendor_Name_Contains_DeepIntent__c,Is_Vendor_Name_Contains_Edith__c,
                                 Is_Vendor_Related_to_Source_Symphony_Acc__c,is_20_or_more_Offering_Present__c,Is_Vendor_Name_Contains_MedPro__c,
                                 is_Specific_Vendors_LAAD_Off__c,is_Specific_Vendors_APLD_Off__c,is_Specific_Vendors_Long_Prescr_Data__c,is_Specific_Vendors_Medical_Claims_Data__c,
                                 Data_Period_Start_Date__c,Data_Period_End_Date__c,Client_Project_Name__c,Client_Address__r.Name,Is_Manually_Approved__c,
                                 Data_Access_Start_Date__c,Data_Access_End_Date__c,Parent_Request__c,Parent_Request__r.Name,Parent_Request__r.Renewed_As__c,
                                 Is_Partially_Renewed__c,Vendor_Website__c,AMA_USPrescriberData__c,TPA_Processor_Contact__r.Name,Parent_Request__r.Is_Renewed__c,
                                 Service_Provider_Address__r.Name,Client_Address__c,Service_Provider_Address__c,AMA_Agreement_required__c,Vendor_App_Submitted__c,
                                 TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Requires_Manual_Review__c,TP_Processor_Email__c,vendor_language__c,TLLA_Batch_Call_Sent_On__c,
                                 Request_Status__c,Is_VSN_Acknowlege_By_Client__c,isClientOnComplianceHold__c,isVendorOnComplianceHold__c,Is_Potential_Vendor_Case__c,
                                 Is_Veeva_Use_CRM_SubNational_Off__c,Ack_Understanding_of_Prescriber_Data__c,Is_Veeva_Use_CRM_Off_OneKey__c,is_Veeva_Use_CRM__c, 
                                 isLegalEntityPresent__c,Pending_Acknowledgements__c,Manual_Trigger_Reasons__c,(Select Id From Purposes__r) 
                                 from TPA_Request__c where Name =: reqName Limit 1];
        
        Set<Id> purposeIds = new Set<Id>();
        for(TPA_Purpose__c pur: reqObj.Purposes__r){
            purposeIds.add(pur.Id);
        }
        SRV_TPA_TPARequest.tpaRequest = reqObj;
        List<TPA_Data_Asset__c> tpaDataAssets = SRV_TPA_TPARequest.tpaDataAssetListCopy(purposeIds);
        SRV_TPA_TPARequest.BUPurposeGeoLevelDataAssetMap= UTL_TPA.setUseOfferingMap(tpaDataAssets);
        offSecRevIds += (offSecRevIds.length() > 0 ? ';' : '') + vendorSecRevIds;
        
        
        if(commonRevIds != ''){
            SRV_TPA_TPARequest.multiRetriggerIds = commonRevIds.split(';');
            if(!Test.isRunningTest()){
                SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
            }
            SRV_TPA_TPARequest.multiRetriggerIds = null;
        }
        if(offSecRevIds != ''){
            SRV_TPA_TPARequest.multiRetriggerIds = offSecRevIds.split(';');
            SRV_TPA_TPARequest.reminderSecOfferingMailRequired = true;
            system.debug('in this::'+SRV_TPA_TPARequest.reminderSecOfferingMailRequired);
            SRV_TPA_TPARequest.isSecComReview = true;
            if(!Test.isRunningTest()){
                SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
            }
            SRV_TPA_TPARequest.isSecComReview = false;
            SRV_TPA_TPARequest.multiRetriggerIds = null;
        }
        
    }
	
}
