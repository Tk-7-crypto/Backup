public class CNT_TPA_Retrigger_Reason {
	public Id recordId{get;set;}
    public Boolean isRecordRetriggerReady{get;set;}
    public Boolean isCommercialIdNotPresent{get;set;}
    public Boolean isLegalEntityNotPresent{get;set;}

    public void SendNotificationCommercialOwner(TPA_Commercial_Review__C  comRevObj)
    {             
        if(comRevObj.Is_ReviewForm_Acknowledged__c){
        	comRevObj.Is_ReviewForm_Acknowledged__c = false;
            if(comRevObj.Action_Needed_By__c == 'TP-country' && comRevObj.Action__c != null && comRevObj.Action__c.contains('Assigned to Commercial Owner (CO) – Awaiting CO Review')){
                comRevObj.Action_Needed_By__c = 'Commercial Owner';
            }

        }
        comRevObj.Retrigger_By__c = UTL_TPA_Multilingual.CurrentUser.Name;
        comRevObj.Retrigger_Date__c = Datetime.now();
        update comRevObj;
        Boolean isManagementEmail = false;
        if(comRevObj.Manual_Review_Reason__c == 'Vendor Requires Secondary Review'){
            isManagementEmail = true;
        }
        SRV_TPA_TPARequest.comRevId = comRevObj.Id;
        SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(comRevObj.TPA_Request__r.Id);
        //SRV_TPA_TPARequest.manualApproval(SRV_TPA_TPARequest.tpaRequest);
      /*  List<TPA_Data_Asset__c> tpaDataAssets = getDataAsset(comRevObj.TPA_Request__r.Id);
        SRV_TPA_TPARequest.BUPurposeGeoLevelDataAssetMap= UTL_TPA.setUseOfferingMap(tpaDataAssets);

        SRV_TPA_TPARequest.sendFinalReviewMail = isManagementEmail;
        if(comRevObj.Manual_Review_Reason__c == 'Offering Requires Secondary Commercial Review'
        || comRevObj.Manual_Review_Reason__c.containsIgnoreCase('Vendor - Use - Offering Secondary Review by')
        || comRevObj.Manual_Review_Reason__c.containsIgnoreCase('Vendor - Use Secondary Review by')){
            SRV_TPA_TPARequest.sendSecondaryOffReviewMail = true;
        }
        if(comRevObj.Manual_Review_Reason__c.contains('IQVIA Legal Approval Required: New TPA - Ad-hoc Additional Term(s) / Exhibit Page(s) Requested') || 
        comRevObj.Manual_Review_Reason__c.contains('IQVIA Legal Approval Required: Prior TLLA had an Additional Term and/or Exhibit added and to be Renewed')){
            SRV_TPA_TPARequest.sendLegalReviewMail =  true;
        }*/

        if(comRevObj.Is_Review_Secondary__c ){
            SRV_TPA_TPARequest.isSecComReview =  true;
        }

        if(!Test.isRunningTest()){
        	SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
        }
        SRV_TPA_TPARequest.sendSecondaryOffReviewMail = false;
        SRV_TPA_TPARequest.sendFinalReviewMail = false;
        SRV_TPA_TPARequest.sendLegalReviewMail = false;
    }
    public void retriggerReason(){
        if(!Test.isRunningTest()){
        	recordId = ApexPages.currentPage().getParameters().get('Id');
        }
        isRecordRetriggerReady = true;
        TPA_Commercial_Review__c comRevObj = [Select Id,Is_Review_Secondary__c,Associated_Use_to_Review__c,Associated_Offering_s_Use_Category_s__c,Associated_Offering_Category__c,BU__c,Associated_Offering_to_Review__c ,Status__c,Retrigger_By__c,Retrigger_Date__c,Receiver_s_Email__c,TP_US_Email__c,TP_Country_Email__c,Additional_Emails__c,Action_Needed_By__c,Action__c,Manual_Review_Reason__c, TPA_Request__c,TPA_Request__r.Id, TPA_Request__r.status__c,Is_ReviewForm_Acknowledged__c  from TPA_Commercial_Review__c where Id =: recordId][0];
        List<TPA_Data_Asset__c> dataAssetRec = [Select Id,Asset_Name__c,IMSLegalEntity__c,IMS_Legal_Entity_for_Other__c From TPA_Data_Asset__c where Request__c =: comRevObj.TPA_Request__c and Asset_name__c = 'Other' and BU__c =: comRevObj.BU__c and Geo_Level__c =: comRevObj.Associated_Offering_Category__c Limit 1];
        if(comRevObj.Action_Needed_By__c == 'Commercial Owner' && (comRevObj.Receiver_s_Email__c == null || comRevObj.Receiver_s_Email__c == '') ){
            isRecordRetriggerReady = false;
        }
        // if(comRevObj.Manual_Review_Reason__c == 'Other Offering Selected' && dataAssetRec != null && dataAssetRec[0].Asset_Name__c == 'Other' && dataAssetRec[0].IMSLegalEntity__c == null){
        //     isLegalEntityNotPresent = true;
        //     isRecordRetriggerReady = false;
        // }
        if((comRevObj.Manual_Review_Reason__c == 'Other Use Selected' && comRevObj.Action__c != null && comRevObj.Action__c == 'Assigned to Commercial Owner (CO) – Awaiting CO Review') && (comRevObj.Receiver_s_Email__c == '' || comRevObj.Receiver_s_Email__c == null)){
            isCommercialIdNotPresent = true;
            isRecordRetriggerReady = false;
        }
        if(isRecordRetriggerReady){
            SendNotificationCommercialOwner(comRevObj);
        }
        PageReference pageRef = new PageReference('/'+recordId);
        pageRef.setRedirect(true);
       	//return pageRef;
    }
    
    public List<TPA_Data_Asset__c>  getDataAsset(Id reqID){

        return [Select  t.Purpose__c, 
        Purpose__r.Name,
        Purpose__r.Primary_Purpose_Name__c, 
        BU__c,
        t.Asset_Name__c,
        Name,
        Other_Text__c, 
        APLD_Delivery_Date__c,
        APLD_Study_Name__c,
        RWE_Delivery_Date__c,
        RWE_Study_Name__c,
        Consumer_Profile_Study_Name__c, 
        Consumer_Profile_Delivery_Date__c, 
        Promotional_ROI_Study_Name__c, 
        Promotional_ROI_Delivery_Date__c, 
        Nostradata_Source_of_Business_LRx__c,
        Longitudanal_Patient_Diagonsis__c,
        CH_Combined_Hos_and_Ret_Profit_AU__c,
        CH_Hospital_Profits__c,
        CH_Other_Outlet_Profits__c,
        CH_Retail_Profits__c,
        Health_Plan_Claims_Data__c, 
        LAAD_Longitudinal_Access_and_Adj_data__c, 
        Patient_Reference_File__c,
        Patient_Companion_File__c, 
        Payer_Companion_File__c, 
        Provider_Companion_File__c,
        STI_Data_Report_Name__c,
        CWH_NZ_Scan_data__c,
        Customized_Data_Text__c,
        Data_Asset__r.BU__c,
        Purpose__r.TPA_Purpose_Category__c,
        Purpose__r.Purpose__c,
        DDD_Level__c,
        Data_Asset__c,
        Region__c,
        Request__c,
        hasDDD__c,
        hasMidas__c,
        Geo_Level__c,
        Asset_NametText__c,
        Other_Data_Asset_Details__c,
        Is_Restricted_Data__c,
        Data_Asset__r.Is_Restricted_Data__c,
        Data_Asset__r.Requires_Fee__c,
        Data_Asset__r.External_License_Data_Supplier_Req__c, 
        Data_Asset__r.Additional_Data_Protection_Terms__c, 
        Data_Asset__r.Geo_Level__c,
        Data_Asset__r.IMS_Legal_Entity__c, 
        Data_Asset__r.Commercial_Owner_Email__c,
        Data_Asset__r.Needs_license_or_data_supplier_response__c,
        Data_Asset__r.Requires_Secondary_Review__c,
        A_Column_Use_For_Template__c,
        Asset_Name_For_Template__c,
        hasXponentPlanTrak__c,
        Requires_Manual_Review__c,
        Data_Asset__r.Requires_Manual_Review__c,
        Is_IMSAG_Product_For_Template__c,
        Is_Restricted_Data_For_Template__c,
        Is_IMS_AGProduct__c,
        Purpose__r.TPA_Purpose_Category__r.Category_Name__c, 
        Region_For_Template__c,
        (Select Id,
         Name,
         Bu__c,
         Secondary_Asset_Name__c,
         Is_RestrictedData__c,
         IMS_Secondary_Data_Asset__c,
         IMS_Secondary_Data_Asset__r.Requires_Manual_Review__c,
         IMS_Secondary_Data_Asset__r.Requires_Secondary_Review__c,
         IMS_Secondary_Data_Asset__r.Commercial_Manager_Email__c, 
         IMS_Secondary_Data_Asset__r.Is_Restricted_Data__c,
         IMS_Secondary_Data_Asset__r.Need_license_or_data_supplier_permission__c,
         AU_Profits__c,
         Nostradata_LRx_Volume__c,
         Nostradata_Source_of_Business_LRx__c,
         AU_DDD_Hospital_Profits__c,
         AU_Other_Outlet_Data_Profits__c,
         Combined_Hos_and_Ret_Profit_AU__c,
         Pharmacy_Scan__c,
         STI_Data_Custom_Report_Name__c, 
         TPA_Data_Asset__r.Data_Asset__r.Commercial_Owner_Email__c, 
         TPA_Data_Asset__r.A_Column_Use_For_Template__c,BrandImpact_Delivery_Date__c,
         BrandImpact_Study_Name__c,
         Outliner_Label_Code__c,
         Outliner_Data_Period_Text__c,
         Channel_Dynamics_Delivery_Date__c,
         Channel_Dynamics_Study_Name__c,
         Pro_Voice_Delivery_Date__c,
         Pro_Voice_Study_Name__c, 
         Purpose__c,
         TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.Category_Name__c,
         TPA_Data_Asset__r.Asset_Name__c,
         TPA_Data_Asset__r.APLD_Delivery_Date__c,
         TPA_Data_Asset__r.APLD_Study_Name__c
         from TPA_Secondary_Data_Assets__r ) 
        From TPA_Data_Asset__c t where Request__c = :reqID];

    }
}
