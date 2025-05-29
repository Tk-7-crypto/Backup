public without sharing class TGRH_TPA_Commercial_Review {
    public static Map<Id,TPA_Data_Asset__c> mapSecRuleWithPriOffering = new Map<ID,TPA_Data_Asset__c>();
    public static Map<Id,TPA_Secondary_Data_Asset__c> mapSecRuleWithSecOffering = new Map<ID,TPA_Secondary_Data_Asset__c>();

    public static String createKeyDataAsset(TPA_Data_Asset__c tpaDa){
        String Key = '';
        Key+= tpaDa.A_Column_Use_For_Template__c + ';';
        Key+= tpaDa.Purpose__r.Purpose_Category_Name__c + ';';
        Key+= tpaDa.Geo_Level__c + ';';
        Key+= tpaDa.BU__c + ';';
        if(tpaDa.Asset_Name__c != null && tpaDa.Asset_Name__c.contains('Other')){
            Key+= 'Other Offering Selected;';
        }
        else if(tpaDa.Asset_Name__c != null && tpaDa.Asset_Name__c.contains(':')){
            Key+= tpaDa.Asset_Name__c.split(':')[0]+';';
        }
        else{
            Key+= tpaDa.Asset_Name__c+';';
        }
        Key += tpaDa.Request__c;
        return Key;
    }

    public static String createKeyComRev(TPA_Commercial_Review__c comreview){
        String key = '';
        key +=comreview.Associated_Use_to_Review__c + ';';
        key +=comreview.Associated_Offering_s_Use_Category_s__c + ';';
        key +=comreview.Associated_Offering_Category__c + ';';
        key +=comreview.BU__c + ';';
        if(comreview.Associated_Offering_to_Review__c != null && comreview.Associated_Offering_to_Review__c.contains(':')){
            key +=comreview.Associated_Offering_to_Review__c.split(':')[0] + ';';
        }
        else{
            key +=comreview.Associated_Offering_to_Review__c + ';';
        }
        key += comreview.TPA_Request__c;
        return key;
    }

    public static void validateRecordsBeforeUpdate(List<TPA_Commercial_Review__c> newRecords,List<TPA_Commercial_Review__c> existingRecords,Map<Id, TPA_Commercial_Review__c> newRecordsMap,Map<Id, TPA_Commercial_Review__c> oldRecordsMap){
        if(BCH_TPA_Update_Commercial_Review.updateTemporaryDetails) {
            return;
        }
        Map<Id, TPA_Commercial_Review__C> mapComReviewRecords = new Map<Id, TPA_Commercial_Review__C>();
        Map<String,Boolean> comReviewLglEnt = new Map<String,Boolean>();
        if(newRecordsMap !=null && !newRecordsMap.isEmpty()){
            mapComReviewRecords = new Map<Id, TPA_Commercial_Review__C>([SELECT Action_Needed_By__c,Action__c,Additional_Emails__c,Additional_Questions_For_TP_Processor__c,Additional_Text_For_Potential_Denial__c,Associated_Offering_s_Use_Category_s__c,Associated_Offering_to_Review__c,Associated_Use_to_Review__c,Comment_For_Under_Validation__c,Commercial_Owner_Name__c,Country_of_Offering__c,CreatedById,Date_of_Action_Response__c,Date_of_Approval__c,Date_Potential_Denial_Removed__c,Date_TP_Processor_Removed__c,Date_Under_Validation_Removed__c,Days_Pending_Review__c,Days_Response_Pending_From_TP_Processor__c,Days_Response_Pending_Potential_Denial__c,Days_Response_Pending_Under_Validation__c,Id,Is_ReviewForm_Acknowledged__c,Manual_Review_Reason__c,Name,Receiver_s_Email__c,Reference_Date_for_Potential_Denial__c,Reference_Date_for_TP_Processor__c,Reference_Date_for_Under_Validation__c,Retrigger_By__c,Retrigger_Date__c,Retrigger_Notification__c,Secondary_Data_Asset__c,Sec_Review_Master__c,Status__c,TPA_Request__c,TP_Country_Email__c,TP_US_Email__c FROM TPA_Commercial_Review__c where Id in : newRecordsMap.keyset()]);
        }
        Set<Id> reqIds = new Set<Id>();
        Set<String> BUset = new Set<String>();
        for(TPA_Commercial_Review__c comRev:newRecords){
            reqIds.add(comRev.TPA_Request__c);
            BUset.add(comRev.BU__c);
        }
        Set<String> otherDataAssetsKeys = new Set<String>();
		for(TPA_Data_Asset__c tpaDa : [Select Id,Request__c,A_Column_Use_For_Template__c,Asset_Name__c,BU__c,Geo_Level__c,Purpose__r.Name,Purpose__r.Purpose_Category_Name__c,IMSLegalEntity__c,IMS_Legal_Entity_for_Other__c From TPA_Data_Asset__c where Asset_Name__c = 'Other' and BU__c in: buSet and (IMSLegalEntity__c != null or IMS_Legal_Entity_for_Other__c != null) and Request__c in: reqIds]){
            otherDataAssetsKeys.add(createKeyDataAsset(tpaDa));
        }
        
        Boolean isLegalEntityNotPresent = false;
        Boolean isResolvedActionNotPresent = false;
        Boolean isReviewerEmailNotPresent = false;
        for(TPA_Commercial_Review__C commRev : newRecords){
            if(commRev.Action__c == 'Assigned to Commercial Owner (CO) – Awaiting CO Review' && commRev.Manual_Review_Reason__c == 'Other Use Selected' && oldRecordsMap != null && oldRecordsMap.get(commRev.Id) != null && commRev.Action__c != oldRecordsMap.get(commRev.Id).Action__c && commRev.Receiver_s_Email__c != null && commRev.Receiver_s_Email__c != oldRecordsMap.get(commRev.Id).Receiver_s_Email__c){
                commRev.Action_Needed_By__c = 'Commercial Owner';
            }
            if(commRev.Manual_Review_Reason__c == 'Other Offering Selected' && !otherDataAssetsKeys.contains(createKeyComRev(commRev)) && oldRecordsMap != null && oldRecordsMap.get(commRev.Id) != null && commRev.Receiver_s_Email__c != null && commRev.Receiver_s_Email__c != oldRecordsMap.get(commRev.Id).Receiver_s_Email__c ){
                isLegalEntityNotPresent = true;
            }
            if(commRev.Action__c == 'Assigned to Commercial Owner (CO) – Awaiting CO Review' && oldRecordsMap != null && oldRecordsMap.get(commRev.Id) != null && commRev.Action__c != oldRecordsMap.get(commRev.Id).Action__c && commRev.Receiver_s_Email__c == null){
                isReviewerEmailNotPresent = true;
            }
            if(commRev.Manual_Review_Reason__c == 'Other Offering Selected' && otherDataAssetsKeys.contains(createKeyComRev(commRev)) && oldRecordsMap != null && oldRecordsMap.get(commRev.Id) != null && commRev.Receiver_s_Email__c != null && commRev.Receiver_s_Email__c != oldRecordsMap.get(commRev.Id).Receiver_s_Email__c ){
                commRev.Action__c = 'Assigned to Commercial Owner (CO) – Awaiting CO Review';
                commRev.Action_Needed_By__c = 'Commercial Owner';
            }
            if(commRev.Action__c != 'Assigned to Commercial Owner (CO) – Awaiting CO Review' && (commRev.Manual_Review_Reason__c == 'Other Use Selected') && oldRecordsMap != null && oldRecordsMap.get(commRev.Id) != null && commRev.Receiver_s_Email__c != null && commRev.Receiver_s_Email__c != oldRecordsMap.get(commRev.Id).Receiver_s_Email__c){
                isResolvedActionNotPresent = true;
            }
            // if(isLegalEntityNotPresent) {
            //     commRev.addError('If ‘Offering of Other’ has been verified with Client to be true - You may need to assign an IQVIA Legal Entity and a Commercial Owner to move this forward. Step 1: Update the Offering Legal Entity Step 2:  Regenerate a refreshed TLLA  Step 3: Update the ‘Reviewer’s Email’, ‘Save’, and ‘Retrigger Commercial Review‘ See your Manual Review Email ‘Trigger Description’ for full instructions',false);
            // }
            if(isReviewerEmailNotPresent) {
                commRev.addError('You have selected ‘Assigned to Commercial Owner (CO) – Awaiting CO Review’ – you must add the email address of the Commercial Owner for their commercial review to move this forward in the process.',false);
            }
            else if(isResolvedActionNotPresent) {
                commRev.addError('Step 1: Update and Save the ‘Commercial Owner Decision’ to ‘Assigned to Commercial Owner (CO) – Awaiting CO Review’ Step 2: Update the ‘Reviewer’s Email’ field to the Offering Owner, Save, then click ‘Retrigger Commercial Review’');
            }
            if(commRev.Action__c != null && commRev.Action__c == 'Approved for this specific TPA. The Vendor and specified Use(s) and IQVIA Offerings specific combination can be auto-approved moving forward for future requests') {
                if(commRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')
                   || commRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by')){
                       CNT_TPA_CommercialReviewForm.secComReviewMasterListToUpdate.add(new IMS_Use_Offering_Atypical_Combination__c(id = commRev.Sec_Review_Master__c, is_Approved_For_Future__c = true));
                   } 
            }
            
            if(commRev.Action__c != null && oldRecordsMap != null && oldRecordsMap.get(commRev.Id) != null && commRev.Action__c != oldRecordsMap.get(commRev.Id).Action__c){
                if(oldRecordsMap.get(commRev.Id).Action__c == 'Under Validation'){
                    commRev.Date_Under_Validation_Removed__c = Date.today();
                }
                else if(oldRecordsMap.get(commRev.Id).Action__c == 'Questions / Comments'){
                    commRev.Date_TP_Processor_Removed__c = Date.today();
                }
                else if(oldRecordsMap.get(commRev.Id).Action__c == UTL_TPA.potentialDenialStatus){
                    commRev.Date_Potential_Denial_Removed__c = Date.today();
                }
                
                if(commRev.Action__c == 'Under Validation'){
                    commRev.Reference_Date_for_Under_Validation__c = Date.today();
                }
                else if(commRev.Action__c == 'Questions / Comments'){
                    commRev.Reference_Date_for_TP_Processor__c = Date.today();
                }
                else if(commRev.Action__c == UTL_TPA.potentialDenialStatus){
                    commRev.Reference_Date_for_Potential_Denial__c = Date.today();
                }
                else if(commRev.Action__c == 'Complete' || commRev.Action__c.contains('Approved for this specific TPA')){
                    commRev.Date_of_Approval__c = Date.today();
                }
                commRev.Is_ReviewForm_Acknowledged__c = true; 
                if(oldRecordsMap.get(commRev.Id).Action_Needed_By__c == 'TP-country' && commRev.Action__c != null && commRev.Action__c.contains('Assigned to Commercial Owner (CO) – Awaiting CO Review') && commRev.Receiver_s_Email__c != null){
                    commRev.Action_Needed_By__c = 'Commercial Owner';
                    commRev.Is_ReviewForm_Acknowledged__c = false; 
                    commRev.Retrigger_By__c = UTL_TPA_Multilingual.CurrentUser.Name;
                    commRev.Retrigger_Date__c = Datetime.now();
                    CNT_TPA_CommercialReviewForm.resolvedComIds.add(commRev.Id);
                }
                if(CNT_TPA_CommercialReviewForm.comName != null && CNT_TPA_CommercialReviewForm.comName != ''){
                    commRev.Commercial_Owner_Name__c = CNT_TPA_CommercialReviewForm.comName;
                }
            }
            if(commRev.Status__c != null && (commRev.Status__c.contains('Combination Approved') || commRev.Status__c.contains('Combination Approved and Future Approved') || commRev.Status__c == 'Complete' ) && oldRecordsMap != null && oldRecordsMap.get(commRev.Id) != null && oldRecordsMap.get(commRev.Id).Status__c != commRev.Status__c){
                if(!commRev.Manual_Review_Reason__c.contains('Vendor Requires Secondary Review') && !commRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review') && !commRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by') && !commRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')){
                    SRV_TPA_TPARequest.primaryReviewsSubmission = true;
                }
            }

            List<String> updatedReviewersEmail = new List<String>();
            List<String> reviewersEmail = commRev.Receiver_s_Email__c != null ? commRev.Receiver_s_Email__c.split(';') : new List<String>();
            for(String email : reviewersEmail){
                if(UTL_TPA_Multilingual.isValidEmailId(email)){
                    updatedReviewersEmail.add(email);
                }
                else{
                    commRev.addError('Please use correct format for Email Address');
                }
            }
            commRev.Receiver_s_Email__c = String.join(updatedReviewersEmail, ';');
        }
        if(CNT_TPA_CommercialReviewForm.secComReviewMasterListToUpdate != null && CNT_TPA_CommercialReviewForm.secComReviewMasterListToUpdate.size() > 0){
            try{
                Update CNT_TPA_CommercialReviewForm.secComReviewMasterListToUpdate ;
            }
            catch(Exception e){
                //   UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_CommercialReviewForm:::saveRequest', tpaRequest != null ? tpaRequest.Id : ''));
                //   UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
        } 
    }

    /*public static void validateRecordsBeforeInsert(List<TPA_Commercial_Review__c> newRecords,List<TPA_Commercial_Review__c> existingRecords,Map<Id, TPA_Commercial_Review__c> newRecordsMap,Map<Id, TPA_Commercial_Review__c> oldRecordsMap){
        for(TPA_Commercial_Review__C commRev : newRecords){
            if(commRev.Action__c == 'Assigned to Commercial Owner (CO) – Awaiting CO Review' && oldRecordsMap != null && oldRecordsMap.get(commRev.Id) != null && commRev.Action__c != oldRecordsMap.get(commRev.Id).Action__c ){
                commRev.Action_Needed_By__c = 'Commercial Owner';
            }
            List<String> updatedReviewersEmail = new List<String>();
            List<String> reviewersEmail = commRev.Receiver_s_Email__c != null ? commRev.Receiver_s_Email__c.split(';') : new List<String>();
            for(String email : reviewersEmail){
                if(UTL_TPA_Multilingual.isValidEmailId(email)){
                    updatedReviewersEmail.add(email);
                }
                else{
                    commRev.addError('Please use correct format for Email Address');
                }
            }
            commRev.Receiver_s_Email__c = String.join(updatedReviewersEmail, ';');
        }
    }*/
    
    public static List<TPA_Request__c> requestsToUpdate = new List<TPA_Request__c>();
    public static void checkIfApproved(List<TPA_Commercial_Review__c> newRecords,List<TPA_Commercial_Review__c> existingRecords,Map<Id, TPA_Commercial_Review__c> newRecordsMap,Map<Id, TPA_Commercial_Review__c> oldRecordsMap){
        if(BCH_TPA_Update_Commercial_Review.updateTemporaryDetails) {
            return;
        }
        Set<Id> requestsIdsToCheck = new Set<Id>();
        for(TPA_Commercial_Review__c commRev : newRecords){
            if(commRev.Status__c != null && (commRev.Status__c.contains('Combination Approved') || commRev.Status__c.contains('Combination Approved and Future Approved') || commRev.Status__c == 'Complete' ) && oldRecordsMap.get(commRev.Id).Status__c != commRev.Status__c){
            	requestsIdsToCheck.add(commRev.TPA_Request__c);
                if(!commRev.Manual_Review_Reason__c.contains('Vendor Requires Secondary Review') && !commRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review') && !commRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by') && !commRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')){
                    SRV_TPA_TPARequest.primaryReviewsSubmission = true;
                }
            }
        }
        
       
        // Map<Id,List<TPA_Data_Asset__c>> reqsWithOfferings = new Map<Id,List<TPA_Data_Asset__c>>();
        // List<TPA_Data_Asset__c> assetList = [Select Id,
        //                                      RWE_Study_Name__c,
        //                                      RWE_Delivery_Date__c,
        //                                      Consumer_Profile_Study_Name__c,
        //                                      Consumer_Profile_Delivery_Date__c,
        //                                      Promotional_ROI_Study_Name__c,
        //                                      Promotional_ROI_Delivery_Date__c,
        //                                      APLD_Study_Name__c,
        //                                      APLD_Delivery_Date__c,
        //                                      STI_Data_Report_Name__c,
        //                                      Longitudanal_Patient_Diagonsis__c,
        //                                      Nostradata_Source_of_Business_LRx__c,
        //                                      CH_Retail_Profits__c,
        //                                      CH_Other_Outlet_Profits__c,
        //                                      CH_Hospital_Profits__c,
        //                                      CH_Combined_Hos_and_Ret_Profit_AU__c,
        //                                      Health_Plan_Claims_Data__c,
        //                                      LAAD_Longitudinal_Access_and_Adj_data__c,
        //                                      Payer_Companion_File__c,
        //                                      Provider_Companion_File__c,
        //                                      Patient_Reference_File__c,
        //                                      CWH_NZ_Scan_data__c,
        //                                      Customized_Data_Text__c,
        //                                      Other_Text__c,
        //                                      Name,Request__c,Asset_Name__c,Purpose__r.Name,purpose__r.TPA_Purpose_Category__c, Purpose__r.Purpose_Category_Name__c,purpose__r.purpose__c, Data_Asset__c, Data_Asset__r.Requires_Secondary_Review__c,Data_Asset__r.Secondary_Commercial_Reviewer_Name__c,Data_Asset__r.Secondary_Commercial_Reviewer_Email__c,
        //                                     (Select Id,
        //                                     BrandImpact_Study_Name__c,
        //                                     BrandImpact_Delivery_Date__c,
        //                                     Channel_Dynamics_Study_Name__c,
        //                                     Channel_Dynamics_Delivery_Date__c,
        //                                     Pro_Voice_Study_Name__c,
        //                                     Pro_Voice_Delivery_Date__c,
        //                                     Pharmacy_Scan__c,
        //                                     Combined_Hos_and_Ret_Profit_AU__c,
        //                                     AU_Other_Outlet_Data_Profits__c,
        //                                     AU_DDD_Hospital_Profits__c,
        //                                     Nostradata_LRx_Volume__c,
        //                                     Nostradata_Source_of_Business_LRx__c,
        //                                     AU_Profits__c,
        //                                     STI_Data_Custom_Report_Name__c,
        //                                     Outliner_Label_Code__c,
        //                                     Outliner_Data_Period_Text__c,
        //                                     TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.Category_Name__c,
        //                                     TPA_Data_Asset__r.Asset_Name__c,
        //                                     TPA_Data_Asset__r.APLD_Delivery_Date__c,
        //                                     TPA_Data_Asset__r.APLD_Study_Name__c,
        //                                     Secondary_Asset_Name__c,IMS_Secondary_Data_Asset__r.Requires_Secondary_Review__c,IMS_Secondary_Data_Asset__r.Secondary_Commercial_Reviewer_Name__c,IMS_Secondary_Data_Asset__r.Secondary_Commercial_Reviewer_Email__c From TPA_Secondary_Data_Assets__r)
        // From TPA_Data_Asset__c where Request__c in: requestsIdsToCheck];
        // for(TPA_Data_Asset__c dataAsset : assetList){
        //     Boolean secondaryOffRequiresRev = false;
        //     for(TPA_Secondary_Data_Asset__c secDataAsset : dataAsset.TPA_Secondary_Data_Assets__r){
        //         if(secDataAsset.IMS_Secondary_Data_Asset__r.Requires_Secondary_Review__c){
        //             secondaryOffRequiresRev = true;
        //             break;
        //         }
        //     }
            // if(dataAsset.Data_Asset__r.Requires_Secondary_Review__c || secondaryOffRequiresRev){
            //     List<TPA_Data_Asset__c> dataAssets = new List<TPA_Data_Asset__c>();
            //     if(reqsWithOfferings.containsKey(dataAsset.Request__c)){
            //         dataAssets = reqsWithOfferings.get(dataAsset.Request__c);
            //         dataAssets.add(dataAsset);
            //     }
            //     else{
            //         dataAssets.add(dataAsset);
            //     }
            //     reqsWithOfferings.put(dataAsset.Request__c,dataAssets);
            // }
        // }
      //  Map<Id,List<IMS_Use_Offering_Atypical_Combination__c>> reqWithSecComb = checkforSecReviewCombinations(reqDetailsWithReviews, assetList);
      //  checkAllRelatedReviews(reqDetailsWithReviews,reqsWithOfferings,reqWithSecComb);
        if (!CNT_TPA_CommercialReviewForm.isSubmitThroughController){
            List<TPA_Request__c> reqDetailsWithReviews = [Select Id,Is_Exhibit_Required__c,Name,Manual_Trigger_Reasons__c,Is_South_Africa_Sub_Off__c,Is_Vendor_Name_Contains_DeepIntent__c,Is_Vendor_Name_Contains_Edith__c,
                                                          Is_Vendor_Related_to_Source_Symphony_Acc__c,is_20_or_more_Offering_Present__c,Is_Vendor_Name_Contains_MedPro__c,
                                                          is_Specific_Vendors_LAAD_Off__c,is_Specific_Vendors_APLD_Off__c,is_Specific_Vendors_Long_Prescr_Data__c,is_Specific_Vendors_Medical_Claims_Data__c,
                                                          Data_Period_Start_Date__c,Data_Period_End_Date__c,Client_Project_Name__c,Client_Address__r.Name,Is_Manually_Approved__c,
                                                          Data_Access_Start_Date__c,Data_Access_End_Date__c,Parent_Request__c,Parent_Request__r.Name,Parent_Request__r.Renewed_As__c,
                                                          Is_Partially_Renewed__c,Vendor_Website__c,AMA_USPrescriberData__c,TPA_Processor_Contact__r.Name,Parent_Request__r.Is_Renewed__c,
                                                          Service_Provider_Address__r.Name,Client_Address__c,Service_Provider_Address__c,AMA_Agreement_required__c,Vendor_App_Submitted__c,
                                                          TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__c,Co_Assigned_Global_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__r.Initials__c,Requires_Manual_Review__c,TP_Processor_Email__c,vendor_language__c,TLLA_Batch_Call_Sent_On__c,
                                                          Request_Status__c,Is_VSN_Acknowlege_By_Client__c,isClientOnComplianceHold__c,isVendorOnComplianceHold__c,Is_Potential_Vendor_Case__c,
                                                          isLegalEntityPresent__c,Pending_Acknowledgements__c,(Select Id,Last_Reminder_Sent_Date__c,Status__c,Manual_Review_Reason__c,Associated_Use_to_Review__c,Associated_Offering_to_Review__c,Is_Review_Secondary__c,Receiver_s_Email__c from TPA_Commercial_Reviews__r order by Is_Review_Secondary__c desc),
                                                          (select id, name, CreatedDate from Attachments order by createddate desc),(Select Id,AMA_Manual_Review__c,Is_AMA_License_Required__c From AMA_Agreement_Details__r)
                                                          
                                                          from TPA_Request__c where Id in: requestsIdsToCheck];
            checkAllRelatedReviews(reqDetailsWithReviews);
            
        }
        if(requestsToUpdate.size() > 0){
            update requestsToUpdate;
        }
    }

    public static Map<Id, List<IMS_Use_Offering_Atypical_Combination__c>> checkforSecReviewCombinations(List<TPA_Request__c> requests, List<TPA_Data_Asset__c> offList) {
        Map<String, List<IMS_Use_Offering_Atypical_Combination__c>> mapMasterSecCombinations = new Map<String, List<IMS_Use_Offering_Atypical_Combination__c>>();
        Set<Id> vendorIdSet = new Set<Id>();
        for(TPA_Request__c reqObj : requests) {
            vendorIdSet.add(reqObj.Service_Provider_Address__r.id);
        }
        mapMasterSecCombinations = SRV_TPA_IMSUseOffAtypicalComb.getSecReviewCombinations(vendorIdSet); // add vendor and uses in the query
        system.debug('mapMasterSecCombinations:' + mapMasterSecCombinations);
        String vendorUseOffKey = '';
        String vendorUseKey = '';
        Map<Id,List<IMS_Use_Offering_Atypical_Combination__c>> reqsWithCom = new Map<Id,List<IMS_Use_Offering_Atypical_Combination__c>>();


        for(TPA_Request__c reqObj :requests){
            Set<IMS_Use_Offering_Atypical_Combination__c> selComb = new Set<IMS_Use_Offering_Atypical_Combination__c>();
            for(TPA_Data_Asset__c dataAsset : offList){
                vendorUseOffKey = reqObj.Service_Provider_Address__r.id + ':' + dataAsset.purpose__r.TPA_Purpose_Category__c+':'+dataAsset.purpose__r.purpose__c+':'+dataAsset.Data_Asset__c;
                vendorUseKey  = reqObj.Service_Provider_Address__r.id + ':' + dataAsset.purpose__r.TPA_Purpose_Category__c+':'+dataAsset.purpose__r.purpose__c+':';
                
                
                if(mapMasterSecCombinations.containsKey(vendorUseKey )  ) {
                    selComb.addAll(mapMasterSecCombinations.get(vendorUseKey ));
                }

                Boolean secondaryOffRequiresRev = false;
                for(TPA_Secondary_Data_Asset__c secDataAsset : dataAsset.TPA_Secondary_Data_Assets__r){
                    if(mapMasterSecCombinations.containsKey(vendorUseOffKey  + ':'+ secDataAsset.IMS_Secondary_Data_Asset__c)  ) {
                        selComb.addAll(mapMasterSecCombinations.get(vendorUseOffKey  + ':'+ secDataAsset.IMS_Secondary_Data_Asset__c));
                        for(IMS_Use_Offering_Atypical_Combination__c atyObj : mapMasterSecCombinations.get(vendorUseOffKey  + ':'+ secDataAsset.IMS_Secondary_Data_Asset__c)){
                            mapSecRuleWithSecOffering.put(atyObj.id, secDataAsset);
                        }
                        secondaryOffRequiresRev = true;
                        system.debug('secondaryOffRequiresRev:' + secondaryOffRequiresRev);
                    }
                    
                }
                    if(mapMasterSecCombinations.containsKey(vendorUseOffKey )  ) {
                        selComb.addAll(mapMasterSecCombinations.get(vendorUseOffKey ));
                        for(IMS_Use_Offering_Atypical_Combination__c atyObj : mapMasterSecCombinations.get(vendorUseOffKey)){
                            mapSecRuleWithPriOffering.put(atyObj.id, dataAsset);
                        }
                    }
            }
            reqsWithCom.put(reqObj.id,new List<IMS_Use_Offering_Atypical_Combination__c>(selComb));
        }
        return reqsWithCom;
      
    }
    
     public static void checkAllRelatedReviews(List<TPA_Request__c> requests){
        if(UTL_TPA.isSecondaryReviewUpdate){
            return;
        }
        List<TPA_Commercial_Review__c> newReviews = new List<TPA_Commercial_Review__c>();
         Map<String,String> uniqueSecCombwithOwnerMap = new Map<String,String>();
         Map<String,Boolean> secOwnerwithEmailSendingFlagMap = new Map<String,Boolean>();
         List<Id> secondaryOfferingIds = new List<Id>();
         Boolean secOfferingMailRequired = false;
         Set<Id> reqWithSecondaryOffReviews = new Set<Id>();
         Set<Id> reqWithVendorSecondaryReviews = new Set<Id>();
         Set<Id> reqWithSecondaryAddHocReviews = new Set<Id>();
        // List<TPA_Commercial_Review__c> secondaryOffReviewsToInsert = new List<TPA_Commercial_Review__c>();
        List<TPA_Commercial_Review__c> secondaryOffReviewsToUpdate = new List<TPA_Commercial_Review__c>();
     //   Map<Id,Set<Id>> reqWithPurposeIds = new Map<Id,Set<Id>>();
        Map<Id,TPA_Request__c> reqWithId = new Map<Id,TPA_Request__c>();
        Set<Id> vendorIds = new Set<Id>();
        for(TPA_Request__c reqObj : requests){
            vendorIds.add(reqObj.Service_Provider_Address__c);
            reqWithId.put(reqObj.Id,reqObj);
        }
        List<Address__c> addressList = [Select Id, Name, Account__c, Account__r.Vendor_Account_Compliance__c, Account__r.Parent.Vendor_Account_Compliance__c,
                Account__r.Vendor_Account_Compliance__r.TPAs_Require_Secondary_Review_by_Mgmt__c, Account__r.Vendor_Account_Compliance__r.TPA_Secondary_Review_Assigned_Mgmt_Email__c,
                Account__r.Parent.Vendor_Account_Compliance__r.TPAs_Require_Secondary_Review_by_Mgmt__c, Account__r.Parent.Vendor_Account_Compliance__r.TPA_Secondary_Review_Assigned_Mgmt_Email__c                                                                         
                FROM Address__c WHERE Id in: vendorIds];
        Map<Id,Account_Compliance__c> accCompRecords = new Map<Id,Account_Compliance__c>() ; 
        for(Address__c add:addressList){
            if(add.Account__c != null && add.Account__r.Parent != null && add.Account__r.Parent.Vendor_Account_Compliance__c != null && !add.Account__r.Vendor_Account_Compliance__r.TPAs_Require_Secondary_Review_by_Mgmt__c){
                accCompRecords.put(add.Id,new Account_Compliance__c(Id = add.Account__r.Vendor_Account_Compliance__c,
                                                                    TPAs_Require_Secondary_Review_by_Mgmt__c = add.Account__r.Parent.Vendor_Account_Compliance__r.TPAs_Require_Secondary_Review_by_Mgmt__c,
                                                                   	TPA_Secondary_Review_Assigned_Mgmt_Email__c = add.Account__r.Parent.Vendor_Account_Compliance__r.TPA_Secondary_Review_Assigned_Mgmt_Email__c));
            }
            else if(add.Account__c != null && add.Account__r.Vendor_Account_Compliance__c != null){
                accCompRecords.put(add.Id,new Account_Compliance__c(Id = add.Account__r.Vendor_Account_Compliance__c,
                                                                    TPAs_Require_Secondary_Review_by_Mgmt__c = add.Account__r.Vendor_Account_Compliance__r.TPAs_Require_Secondary_Review_by_Mgmt__c,
                                                                   	TPA_Secondary_Review_Assigned_Mgmt_Email__c = add.Account__r.Vendor_Account_Compliance__r.TPA_Secondary_Review_Assigned_Mgmt_Email__c));
            }
        }        	
        for(TPA_Request__c reqObj : requests){
            boolean isholdCase = false;
            boolean allCompleted = true;
            Boolean secondaryReviewRecord = false;//Vendor Requires Secondary Review
            // Boolean isVendorOnSecondaryReview = false;
            Boolean secondaryOfferingReviewRecord = false;
            Boolean secReviewCombRecord = false;
         //   Boolean isSecondaryOfferingReviewReq = reqsWithAssets.containsKey(reqObj.Id);
            Boolean primaryAllCompleted = true;
            String mgmtEmail = '';
        	// if(accCompRecords != null){
            // 	Account_Compliance__c accVendorComp = accCompRecords.get(reqObj.Service_Provider_Address__c);
            // 	if(accVendorComp != null && accVendorComp.TPAs_Require_Secondary_Review_by_Mgmt__c){
            //     	isVendorOnSecondaryReview = true;
            //         mgmtEmail = accVendorComp.TPA_Secondary_Review_Assigned_Mgmt_Email__c;
            // 	}
        	// }
            // Set<Id> purposeIds = new Set<Id>();
            // for(TPA_Purpose__c purpose:reqObj.Purposes__r){
            // 	purposeIds.add(purpose.Id);
            // }
         //   reqWithPurposeIds.put(reqObj.Id,purposeIds);
            // List<IMS_Use_Offering_Atypical_Combination__c> lstRequiredSecComb = reqWithSecComb.get(reqObj.Id);
            Boolean isReviewSecondary = false;
            List<TPA_Commercial_Review__c> secReviews = new List<TPA_Commercial_Review__c>();
            for(TPA_Commercial_Review__c comRev : reqObj.TPA_Commercial_Reviews__r){
                isReviewSecondary = false;
                if(comRev.Manual_Review_Reason__c.contains('Vendor Requires Secondary Review') || comRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review') || comRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by') || comRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')
                || UTL_TPA.isManualReviewAddHoc(comRev.Manual_Review_Reason__c) ){
                    isReviewSecondary = true;
                    secReviews.add(comRev);
                }
                if(comRev.Status__c == null || !isComRevApproved(comRev.Status__c)){
                    allCompleted = false;
                }
                if(comRev.Status__c == null || (!isComRevApproved(comRev.Status__c) && !isReviewSecondary)){
                    primaryAllCompleted = false;
                }
                if(comRev.Is_Review_Secondary__c && !uniqueSecCombwithOwnerMap.containsKey(comRev.Associated_Use_to_Review__c + ':' + comRev.Associated_Offering_to_Review__c) && !TGRH_TPA_Commercial_Review.isComRevApproved(comRev.Status__c)){
                    uniqueSecCombwithOwnerMap.put(comRev.Associated_Use_to_Review__c + ':' + comRev.Associated_Offering_to_Review__c,comRev.Receiver_s_Email__c);
                    secOwnerwithEmailSendingFlagMap.put(comRev.Receiver_s_Email__c, true);
                    //secondaryOfferingIds.add(comRev.Id);
                }
                else if(!comRev.Is_Review_Secondary__c && uniqueSecCombwithOwnerMap.containsKey(comRev.Associated_Use_to_Review__c + ':' + comRev.Associated_Offering_to_Review__c) && !TGRH_TPA_Commercial_Review.isComRevApproved(comRev.Status__c)){
                    secOwnerwithEmailSendingFlagMap.put(uniqueSecCombwithOwnerMap.get(comRev.Associated_Use_to_Review__c + ':' + comRev.Associated_Offering_to_Review__c), false);
                }
                if(!comRev.Is_Review_Secondary__c && uniqueSecCombwithOwnerMap.containsKey(comRev.Associated_Use_to_Review__c + ':' + comRev.Associated_Offering_to_Review__c) && TGRH_TPA_Commercial_Review.isComRevApproved(comRev.Status__c)){
                    secondaryOfferingIds.add(comRev.Id);
                }
                if(comRev.Manual_Review_Reason__c != null && (comRev.Manual_Review_Reason__c.contains('offshore') || comRev.Manual_Review_Reason__c.contains('Other Use Selected')) && (comRev.Status__c != null && (comRev.Status__c.contains('Combination Approved') || comRev.Status__c.contains('Combination Approved and Future Approved') || comRev.Status__c.contains('Complete')))){
                    isholdCase = true;
                }
            }
            for(TPA_Commercial_Review__c comRev : secReviews){
                if(reqObj.Is_Exhibit_Required__c && !isComRevApproved(comRev.Status__c) && (comRev.Status__c != 'Awaiting Review'|| Test.isRunningTest()) && primaryAllCompleted && SRV_TPA_TPARequest.primaryReviewsSubmission && UTL_TPA.isManualReviewAddHoc(comRev.Manual_Review_Reason__c)){
                    comRev.Status__c = 'Awaiting Review';
                    secondaryOffReviewsToUpdate.add(comRev);
                    reqWithSecondaryAddHocReviews.add(reqObj.Id);
                }
                 if(comRev.Manual_Review_Reason__c.contains('Vendor Requires Secondary Review')){
                     secondaryReviewRecord = true;
                     if(!isComRevApproved(comRev.Status__c) && primaryAllCompleted && SRV_TPA_TPARequest.primaryReviewsSubmission){
                         comRev.Status__c = 'Awaiting Review';
                         secondaryOffReviewsToUpdate.add(comRev);
                         reqWithVendorSecondaryReviews.add(reqObj.Id);
                     }
                 }
                 if(comRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review')){
                     secondaryOfferingReviewRecord = true;
                     if(!isComRevApproved(comRev.Status__c) && comRev.Status__c != 'Awaiting Review' && (secOwnerwithEmailSendingFlagMap.get(comRev.Receiver_s_Email__c) == true || primaryAllCompleted) && SRV_TPA_TPARequest.primaryReviewsSubmission){
                         comRev.Status__c = 'Awaiting Review';
                         secondaryOffReviewsToUpdate.add(comRev);
                         reqWithSecondaryOffReviews.add(reqObj.Id);
                         if(!primaryAllCompleted){
                             comRev.Last_Reminder_Sent_Date__c = Date.today();
                             secOfferingMailRequired = true;
                             SRV_TPA_TPARequest.secOfferingMailRequired = true;
                             secondaryOfferingIds.add(comRev.Id);
                         }
                         else if(primaryAllCompleted){
                             comRev.Last_Reminder_Sent_Date__c = null;
                             SRV_TPA_TPARequest.secOfferingMailRequiredPrimAllCompleted = true;
                         }
                     }
                 }
                 if((comRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by') || comRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by'))){
                     secReviewCombRecord = true;
                     if(!isComRevApproved(comRev.Status__c) && comRev.Status__c != 'Awaiting Review' && (secOwnerwithEmailSendingFlagMap.get(comRev.Receiver_s_Email__c) == true || primaryAllCompleted) && SRV_TPA_TPARequest.primaryReviewsSubmission){
                         comRev.Status__c = 'Awaiting Review';
                         secondaryOffReviewsToUpdate.add(comRev);
                         reqWithSecondaryOffReviews.add(reqObj.Id);
                         if(!primaryAllCompleted){
                             comRev.Last_Reminder_Sent_Date__c = Date.today();
                             secOfferingMailRequired = true;
                             SRV_TPA_TPARequest.secOfferingMailRequired = true;
                             secondaryOfferingIds.add(comRev.Id);
                         }
                         else if(primaryAllCompleted){
                             comRev.Last_Reminder_Sent_Date__c = null;
                             SRV_TPA_TPARequest.secOfferingMailRequiredPrimAllCompleted = true;
                         }
                     }
                 }
               //  if(Test.isRunningTest() && comRev.Manual_Review_Reason__c.contains('secondary')){
              //   	isVendorOnSecondaryReview = true;
            	// }
            }

            
            Boolean amaManualReview = (reqObj.AMA_Agreement_Details__r != null && !reqObj.AMA_Agreement_Details__r.isEmpty()) ? reqObj.AMA_Agreement_Details__r[0].AMA_Manual_Review__c : false;
            if(allCompleted && !isholdCase) {

                string strPickListValue = reqObj.Pending_Acknowledgements__c;
                
                if(strPickListValue != null){
                    List<string> lstPicklistValues = strPickListValue.split(';');
                    string strValueToRemove ='Pending Commercial Review Acknowledgements';
                    if(lstPicklistValues.contains(strValueToRemove)){
                        lstPicklistValues.remove(lstPicklistValues.indexOf(strValueToRemove));
                    }
                    reqObj.Pending_Acknowledgements__c = String.join(lstPicklistValues,';');
                }
                if(reqObj.Request_Status__c == 'In Review by IQVIA' && SRV_TPA_TPARequest.isReqReadyForSignatures(reqObj)){
                    Boolean isAMADocReq = (reqObj.AMA_Agreement_Details__r != null && !reqObj.AMA_Agreement_Details__r.isEmpty()) ? reqObj.AMA_Agreement_Details__r[0].Is_AMA_License_Required__c : false ;
                    
                    if(reqObj.Attachments.size() > 0 && checkIfAllDocsAreGenerated(reqObj.Attachments,isAMADocReq,reqObj.Vendor_App_Submitted__c)  && !amaManualReview){
                        sendForDocuSign(reqObj.Id);
                    }
                }
                requestsToUpdate.add(reqObj);
                sendEmailToTpProcessor(reqObj, amaManualReview);
            }                
            // else if(primaryAllCompleted && isVendorOnSecondaryReview && !secondaryReviewRecord){
                //     //Per this TPA Request
                //     TPA_Commercial_Review__c newComRev = new TPA_Commercial_Review__c();
                //     newComRev.Manual_Review_Reason__c = 'Vendor Requires Secondary Review';
                //     newComRev.TPA_Request__c = reqObj.Id;
                //     newComRev.Status__c = 'Awaiting Review';
                //     newComRev.Action_Needed_By__c = 'Management'; 
                //     newComRev.Receiver_s_Email__c = mgmtEmail;
                //     newComRev.TP_US_Email__c = UTL_TPA.TPUSEMailAddress;
                //     newComRev.Associated_Offering_to_Review__c = 'Per this TPA Request';
                //     newComRev.Associated_Use_to_Review__c = 'Per this TPA Request';
                //     newReviews.add(newComRev);
                //     reqWithVendorSecondaryReviews.add(reqObj.Id);
                // }
                // else if(primaryAllCompleted && ((isSecondaryOfferingReviewReq && !secondaryOfferingReviewRecord)
                // || (lstRequiredSecComb != null && lstRequiredSecComb.size()> 0 && !secReviewCombRecord))){
                    
                    // if(allCompleted && isSecondaryOfferingReviewReq && !secondaryOfferingReviewRecord){
                        //     List<TPA_Commercial_Review__c> secondaryOffReviews = new List<TPA_Commercial_Review__c>();
                        //     for(TPA_Data_Asset__c dataAsset : reqsWithAssets.get(reqObj.Id)){
                            //         Boolean hasSecondaryOff = false;
                            //         for(TPA_Secondary_Data_Asset__c secDA:dataAsset.TPA_Secondary_Data_Assets__r){
                                //             hasSecondaryOff = true;
                                //             if(secDA.IMS_Secondary_Data_Asset__r.Requires_Secondary_Review__c){
                //                 secondaryOffReviews.add(createManualReview(reqObj,'Offering Requires Secondary Commercial Review',secDA.IMS_Secondary_Data_Asset__r.Secondary_Commercial_Reviewer_Email__c,secDA.Secondary_Asset_Name__c,dataAsset.Purpose__r.Name,null,secDA,dataAsset.Purpose__r.Purpose_Category_Name__c));
                //             }
                //         }
                //         if(!hasSecondaryOff && dataAsset.Data_Asset__r.Requires_Secondary_Review__c){
                    //             secondaryOffReviews.add(createManualReview(reqObj,'Offering Requires Secondary Commercial Review',dataAsset.Data_Asset__r.Secondary_Commercial_Reviewer_Email__c,dataAsset.Asset_Name__c,dataAsset.Purpose__r.Name,dataAsset,null,dataAsset.Purpose__r.Purpose_Category_Name__c));
                    //         }
                    //     }
                    //     reqWithSecondaryOffReviews.add(reqObj.Id);
                    //     // secondaryOffReviewsToInsert.addAll(secondaryOffReviews);
                    // }
                    // if(lstRequiredSecComb != null && lstRequiredSecComb.size()> 0 && !secReviewCombRecord){
                        //   system.debug('asdasd');
                        //   List<TPA_Commercial_Review__c> secondaryOffReviews = new List<TPA_Commercial_Review__c>();
                        // for(IMS_Use_Offering_Atypical_Combination__c comObj : lstRequiredSecComb){
                            //     if(comObj.Secondary_Offering_Name__c != null){
                                //         secondaryOffReviews.add(createManualReviewForSecComb(reqObj,'Vendor - Use - Offering Secondary Review by ',comObj.Action_Needed_By__c, SRV_TPA_TPARequest.fullOfferingName(null, mapSecRuleWithSecOffering.get(comObj.id)), comObj.Use_Name__r.Primary_Purpose_Name__c,comObj,null,comObj.Use_Category__r.Category_Name__c));
                                //     }
                                //     else if(comObj.Offering_Name__c != null){
                                    //         secondaryOffReviews.add(createManualReviewForSecComb(reqObj,'Vendor - Use - Offering Secondary Review by ',comObj.Action_Needed_By__c, SRV_TPA_TPARequest.fullOfferingName(mapSecRuleWithPriOffering.get(comObj.id), null), comObj.Use_Name__r.Primary_Purpose_Name__c,comObj,null,comObj.Use_Category__r.Category_Name__c));
                                    //     }
                                    //     else{
                                        //         secondaryOffReviews.add(createManualReviewForSecComb(reqObj,'Vendor - Use Secondary Review by ',comObj.Action_Needed_By__c,null,comObj.Use_Name__r.Primary_Purpose_Name__c,comObj,null,comObj.Use_Category__r.Category_Name__c));
                                        //     }
                                        // }
                                        // reqWithSecondaryOffReviews.add(reqObj.Id);
                                        // secondaryOffReviewsToInsert.addAll(secondaryOffReviews);
                                        // }
            // }
            else if(isholdCase && allCompleted){
                string strPickListValue = reqObj.Pending_Acknowledgements__c;
                if(strPickListValue != null){
                    List<string> lstPicklistValues = strPickListValue.split(';');
                    string strValueToRemove ='Pending Commercial Review Acknowledgements';
                    if(lstPicklistValues.contains(strValueToRemove)){
                        lstPicklistValues.remove(lstPicklistValues.indexOf(strValueToRemove));
                    }
                    reqObj.Pending_Acknowledgements__c = String.join(lstPicklistValues,';');
                }
                requestsToUpdate.add(reqObj);
                sendEmailToTpProcessor(reqObj, amaManualReview);
            }
        }
        if(newReviews.size() > 0){
            insert newReviews;
        }
        if(secondaryOffReviewsToUpdate != null && secondaryOffReviewsToUpdate.size()>0){
            UTL_TPA.isSecondaryReviewUpdate = true;
            update secondaryOffReviewsToUpdate;
            UTL_TPA.isSecondaryReviewUpdate = false;
        }
         for(Id reqId : reqWithVendorSecondaryReviews){
             SRV_TPA_TPARequest.tpaRequest = reqWithId.get(reqId);
             SRV_TPA_TPARequest.sendFinalReviewMail = true;
           //  List<TPA_Data_Asset__c> tpaDataAssets = SRV_TPA_TPARequest.tpaDataAssetListCopy(reqWithPurposeIds.get(reqId));
            // SRV_TPA_TPARequest.BUPurposeGeoLevelDataAssetMap= UTL_TPA.setUseOfferingMap(tpaDataAssets);
             if(!Test.isRunningTest()){
                 SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
             }
             SRV_TPA_TPARequest.sendFinalReviewMail = false;
         }
        // if(secondaryOffReviewsToInsert.size() > 0){
        //     insert secondaryOffReviewsToInsert;
        // }
         if(reqWithSecondaryOffReviews != null && reqWithSecondaryOffReviews.size() > 0){
             for(Id reqId : reqWithSecondaryOffReviews){

                 SRV_TPA_TPARequest.tpaRequest = reqWithId.get(reqId);
                 if(secOfferingMailRequired && secondaryOfferingIds != null && secondaryOfferingIds.size()>0){
                     SRV_TPA_TPARequest.multiRetriggerIds = secondaryOfferingIds;
                 }
                 SRV_TPA_TPARequest.sendSecondaryOffReviewMail = true;
        //         List<TPA_Data_Asset__c> tpaDataAssets = SRV_TPA_TPARequest.tpaDataAssetListCopy(reqWithPurposeIds.get(reqId));
        //         SRV_TPA_TPARequest.BUPurposeGeoLevelDataAssetMap= UTL_TPA.setUseOfferingMap(tpaDataAssets);
                 if(!Test.isRunningTest()){
                     SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
                 }
                 SRV_TPA_TPARequest.multiRetriggerIds = null;
                 SRV_TPA_TPARequest.sendSecondaryOffReviewMail = false;
             }
         }
    }

    public static Boolean isComRevApproved(String status){
        if(status != null && !status.contains('Combination Approved') && !status.contains('Combination Approved and Future Approved') && status != 'Complete' ){
            return false;
        }
        return true;
    }

    public static TPA_Commercial_Review__c createManualReview(TPA_Request__c request,String manualApprovalReason,String email,String offeringDetail,String useDetail, TPA_Data_Asset__c dataAsset, TPA_Secondary_Data_Asset__c secondaryDataAsset, String useCategory){
        TPA_Commercial_Review__c newReason = new TPA_Commercial_Review__c();
        newReason.TPA_Request__c = request.Id;
        newReason.Manual_Review_Reason__c = manualApprovalReason;
        newReason.Status__c = 'Awaiting Review';
        newReason.Action_Needed_By__c = 'Commercial Owner';
        newReason.TP_Country_Email__c = request.TP_Processor_Email__c; 
        newReason.Receiver_s_Email__c = email; 
        if(offeringDetail != null) {
            newReason.Associated_Offering_to_Review__c	= offeringDetail;
        }
        if(useDetail != null) {
            newReason.Associated_Use_to_Review__c = useDetail;
        }
        if(dataAsset != null){
            //newReason.Primary_Data_Asset__c	= dataAsset.Id;
        }
        if(secondaryDataAsset != null){
            //newReason.Secondary_Data_Asset__c = secondaryDataAsset.Id;
        }
        if(useCategory != null){
            newReason.Associated_Offering_s_Use_Category_s__c = useCategory;
        }
        return newReason;
    }

    public static TPA_Commercial_Review__c createManualReviewForSecComb(TPA_Request__c request,String manualApprovalReason,String actionNeededBy,String offeringDetail,String useDetail, IMS_Use_Offering_Atypical_Combination__c atyObj, TPA_Secondary_Data_Asset__c secondaryDataAsset, String useCategory){
        TPA_Commercial_Review__c newReason = new TPA_Commercial_Review__c();
        newReason.TPA_Request__c = request.Id;
        newReason.Manual_Review_Reason__c = atyObj.Action_Needed_By__c.contains('Mgmt') ? manualApprovalReason + 'Mgmt' : manualApprovalReason + 'Legal';
        newReason.Status__c = 'Awaiting Review';
        newReason.Action_Needed_By__c = actionNeededBy;
        newReason.Receiver_s_Email__c = atyObj.Action_Needed_By__c.contains('Mgmt') ? atyObj.Mgmt_Review_email__c : atyObj.Legal_Review_Email__c;
        newReason.TP_Country_Email__c = request.TP_Processor_Email__c; 
        if(offeringDetail != null) {
            newReason.Associated_Offering_to_Review__c	= offeringDetail;
        }
        if(useDetail != null) {
            newReason.Associated_Use_to_Review__c = useDetail;
        }
        if(atyObj != null){
            newReason.Sec_Review_Master__c	= atyObj.Id;
        }
        if(useCategory != null){
            newReason.Associated_Offering_s_Use_Category_s__c = useCategory;
        }
        return newReason;
    }

    @remoteAction
    public static void sendForDocuSign(String reqId){
        QBL_TPA_AsyncSendDoc asyncSendDocCall= new QBL_TPA_AsyncSendDoc();
        asyncSendDocCall.requestId = reqId;
        System.enqueueJob(asyncSendDocCall); 
    }

    public static Boolean checkIfAllDocsAreGenerated(List<Attachment> attchs,Boolean isAmaDocReq,Datetime vendrAppSubDate){
        Boolean isTLLAAttached = false,isHelpfulHintsAttached = false,isAmaDocAttached=false;
        for(Attachment att : attchs){
            if(att.Name.contains('TLLA') && (att.Name.contains('IQVIA Third Party Tech') == false) && vendrAppSubDate != null && vendrAppSubDate < att.CreatedDate){
                isTLLAAttached = true;
            }
            else if(att.Name.contains('Helpful Hints') && vendrAppSubDate != null && vendrAppSubDate < att.CreatedDate){
                isHelpfulHintsAttached = true;
            }
            else if(att.Name.contains('AMA_') && vendrAppSubDate != null && vendrAppSubDate < att.CreatedDate){
                isAmaDocAttached = true;
            }
        }

        return isTLLAAttached && isHelpfulHintsAttached && (isAmaDocReq ? isAmaDocAttached : true);
    }

    public static void sendEmailToTpProcessor( TPA_Request__c reqObj, Boolean amaManualReview){
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        String emailBody;
        String subjectText;
        
        if(reqObj.TP_Processor_Email__c != null) {
            if(amaManualReview && reqObj.TP_Processor_Email__c != UTL_TPA.TPUSEMailAddress){
                toAddress.add(UTL_TPA.TPUSEMailAddress);
                ccAddress.add(reqObj.TP_Processor_Email__c);
            }else{
                toAddress.add(reqObj.TP_Processor_Email__c);
            }
        }
        string vendorLanguage = (reqObj.vendor_language__c != null && reqObj.vendor_language__c != '') ? reqObj.vendor_language__c : 'English';
        String emailTemplate = amaManualReview ?  'Review Before Send for Sign' : 'Email to notify TP Processor';
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get(emailtemplate + vendorLanguage).Translated_Template_Id__c;
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateID != '' && templateID != null) {  
            try {
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
            } catch(Exception exp) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::TGRH_TPA_Commercial_Review:::sendEmailToTpProcessor:::', reqObj.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);    
            }
            emailBody = emailNotToSend.getHTMLBody();
            subjectText = emailNotToSend.getSubject();
    	}
        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccAddress, 'SendEmail', null, reqObj.Id, null, subjectText, FALSE, emailBody, TRUE, TRUE, reqObj); 
		//SRV_TPA_TPARequest.addTPProcessorInitials = false; 
	}     
}
