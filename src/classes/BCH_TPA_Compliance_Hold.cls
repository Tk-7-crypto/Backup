global class BCH_TPA_Compliance_Hold implements Database.Batchable<sObject>,Database.Stateful {
    public List<Id> accountsOnHold;
    public Set<Id> requestsToVoidOnComplianceHold = new Set<Id>(); 
    public String type;
    
    public BCH_TPA_Compliance_Hold() {

    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Boolean holdType = type =='PutOnHold' ? true : false;
        List<Address__c> clientAddresses = [Select Id,Name,Account__c From Address__c Where Account__c in: accountsOnHold and Account__r.Client_Account_Compliance__r.Client_TPA_Compliance_Hold__c =: holdType  and Id in (Select Address__c From Contact_Address_Crosswalk__c)];
        List<Address__c> vendorAddresses = [Select Id,Name,Account__c From Address__c Where Account__c in: accountsOnHold and (Account__r.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold__c =: holdType or (Account__r.ParentId != null and Account__r.Parent.Vendor_Account_Compliance__c != null and Account__r.Parent.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold__c =: holdType)) and Is_TPA_Account__c =: true];
        String query = '';
        query = 'Select Id,Name,Vendor_e_mail__c,Manual_Trigger_Reasons__c,Service_Provider_Address__r.Parent_Vendor_Name__c,Is_Manually_Approved__c,Data_Access_Start_Date__c,Data_Access_End_Date__c,Request_Status__c,Client_Address__c,Global_Branding_Vendor_Address__c,Service_Provider_Address__c,isClientOnComplianceHold__c,isVendorOnComplianceHold__c,Client_Address__r.Name, Is_VSN_Acknowlege_By_Client__c, ClientContact__r.email, Client_TPA_Representative_Email__c, Owner.Type, Owner.Email, Client_Address__r.TPAOtherEmailIds__c' ;
        query += ' ,Vendor_Compliance_Email__c,Client_Request_Submission__c,Authorized_Signer_Email__c,TP_Processor_Email__c,vendor_language__c,Vendor_App_Submitted__c,TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Parent_Request__c,Parent_Request__r.Is_Renewed__c,Parent_Request__r.Renewed_As__c,Parent_Request__r.Name,Service_Provider_Address__r.Name,Vendor_Website__c,Client_Project_Name__c,AMA_USPrescriberData__c';
        query += ',(Select Id,AMA_Manual_Trigger_Reasons__c From AMA_Agreement_Details__r),';
        query += '( select id, Type__c, Email__c from TPA_Request_Contacts__r)';
        query += ' From TPA_Request__c Where ( Request_Status__c in (\'Hold for TPA non-compliance\',\'Pending IQVIA Review of Voided Envelope\',\'In Review By IQVIA\', \'Awaiting Vendor Signature\', \'TPA Approved Awaiting AMA Approval\') ) ';
        query += ' and ( Client_Address__c in: clientAddresses ';
        query += ' or (Global_Branding_Vendor_Address__c in: vendorAddresses or Service_Provider_Address__c in: vendorAddresses) )';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> objList)
    {	
        List<TPA_Request__c> requestToBeUpdated = new List<TPA_Request__c>();
        List<TPA_Request__c> requestToBeRemoveFromHold = new List<TPA_Request__c>();
        Map<String, Account_Compliance__c> mapClientVendorAccountCompliance = new Map<String,Account_Compliance__c>();
        for(sobject sobj : objList)
        {	
			TPA_Request__c objRequest = (TPA_Request__c)sobj ;
            if(mapClientVendorAccountCompliance == null || (mapClientVendorAccountCompliance.get('CC-'+objRequest.Client_Address__c) == null ||( objRequest.Service_Provider_Address__c != null && mapClientVendorAccountCompliance.get('VC-'+objRequest.Service_Provider_Address__c) == null)))
                mapClientVendorAccountCompliance = UTL_TPA.getTpaClientVendorComplianceDetails(objRequest.Client_Address__c,objRequest.Service_Provider_Address__c == null ? objRequest.Client_Address__c : objRequest.Service_Provider_Address__c );
            Account_Compliance__c accCompClient ;
            Account_Compliance__c accCompVendor ;

            if(mapClientVendorAccountCompliance != null && mapClientVendorAccountCompliance.get('CC-'+objRequest.Client_Address__c) != null)
                accCompClient = mapClientVendorAccountCompliance.get('CC-'+objRequest.Client_Address__c);
            if(mapClientVendorAccountCompliance != null && mapClientVendorAccountCompliance.get('VC-'+objRequest.Service_Provider_Address__c) != null)
                accCompVendor = mapClientVendorAccountCompliance.get('VC-'+objRequest.Service_Provider_Address__c);
            Boolean reqChanged = false;
            if(type =='PutOnHold'){
                if( accCompClient != null && accCompClient.Client_TPA_Compliance_Hold__c){
                    objRequest.isClientOnComplianceHold__c = true;
                    objRequest.Request_Status__c = 'Hold for TPA non-compliance';
                    reqChanged = true;
                }
                if( accCompVendor != null && accCompVendor.Vendor_TPA_Compliance_Hold__c){
                    objRequest.isVendorOnComplianceHold__c = true;
                    objRequest.Request_Status__c = 'Hold for TPA non-compliance';
                    reqChanged = true;
                }
                if(reqChanged){
                    objRequest = SRV_TPA_TPARequest.getRequestStatus(objRequest);
                }
            }
            if(type =='RemoveFromHold'){
                if( accCompClient != null && !accCompClient.Client_TPA_Compliance_Hold__c && objRequest.isClientOnComplianceHold__c){
                    objRequest.isClientOnComplianceHold__c = false;
                    reqChanged = true;
                }
                if( accCompVendor != null && !accCompVendor.Vendor_TPA_Compliance_Hold__c && objRequest.isVendorOnComplianceHold__c){
                    objRequest.isVendorOnComplianceHold__c = false;
                    reqChanged = true;
                }
                if(reqChanged && !objRequest.isClientOnComplianceHold__c && !objRequest.isVendorOnComplianceHold__c){
                    requestToBeRemoveFromHold.add(objRequest);        
                }
            }
            if(reqChanged){
                requestToBeUpdated.add(objRequest);
            }
		}

        if(requestToBeUpdated != null && requestToBeUpdated.size() > 0){
            try
            {
                update requestToBeUpdated;
            }
            catch(Exception e)
            {
                System.debug('Request updated Failed: ' + e.getMessage());
            }
            if(accountsOnHold != null){
                if(type == 'PutOnHold'){
                    for(TPA_Request__c tpaReq : requestToBeUpdated){
                        requestsToVoidOnComplianceHold.add(tpaReq.Id);
                        String preferredLang = tpaReq.vendor_language__c != null ? tpaReq.vendor_language__c : 'English';
                        List<String> TPProcessorEmailId = new List<String>();
                        if(tpaReq.TP_Processor_Email__c != null && String.isNotBlank(tpaReq.TP_Processor_Email__c))
                            TPProcessorEmailId.add(tpaReq.TP_Processor_Email__c);
                        if(!Test.isRunningTest()){
                            List<TPA_Data_Asset__c> tpaDataAssets = getDataAsset(tpaReq.id);
                            SRV_TPA_TPARequest.tpaRequest = tpaReq;
                            // SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.manualApproval(SRV_TPA_TPARequest.getRequestInfo(tpaReq.id));
                            SRV_TPA_TPARequest.BUPurposeGeoLevelDataAssetMap= UTL_TPA.setUseOfferingMap(tpaDataAssets);
                            SRV_TPA_TPARequest.sendTPAComplianceHoldMail(UTL_TPA.tpaSetting.TPA_Compliance_Hold_Emails__c,TPProcessorEmailId);
                        }
                        List<String> toRecipient = new List<String>();
                        List<String> ccRecipient = new List<String>();
                        if(tpaReq.Authorized_Signer_Email__c != null)
                            toRecipient.add(tpaReq.Authorized_Signer_Email__c);
                        if(tpaReq.Vendor_Compliance_Email__c != null)
                            toRecipient.add(tpaReq.Vendor_Compliance_Email__c);
                        List<TPA_Contact__c> tpaContactList = SRV_TPA_TPARequest.getContactsForRequest(tpaReq.Id);
                        if(tpaContactList!= null && tpaContactList.size() > 0)
                        {
                            for(TPA_Contact__c tpaContact : tpaContactList)
                            {
                                if(tpaContact.Type__c == 'Additional Vendor Contact')
                                {
                                    toRecipient.add(tpaContact.Email__c);
                                }                                
                            }
                        }
                        if(tpaReq.TP_Processor_Email__c != null && String.isNotBlank(tpaReq.TP_Processor_Email__c))
                            ccRecipient.add(tpaReq.TP_Processor_Email__c);
                        if(!Test.isRunningTest() && tpaReq.Vendor_e_mail__c != null){
                            toRecipient.add(tpaReq.Vendor_e_mail__c);
                            String templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email notice to Vendor of Hold placed'+preferredLang).Translated_Template_Id__c;
                            SRV_TPA_TPARequest.sendEmailThroughWorkflow(toRecipient, ccRecipient, 'SendEmail', templateId, tpaReq.Id, null, '', FALSE, '', FALSE, FALSE, null);
                        }
					}
                }
            }
            if(requestToBeRemoveFromHold.size() > 0){
                for(TPA_Request__c tpaReq : requestToBeRemoveFromHold){
                   updateRequest(tpaReq);
                }
            }
        }
    }

    public static void updateRequest(TPA_Request__c reqObj) {
       // reqObj = SRV_TPA_TPARequest.manualApproval(reqObj);
        reqObj = SRV_TPA_TPARequest.getRequestStatus(reqObj);
        if(reqObj.Request_Status__c == 'In Auto Approval Process'){
            reqObj.TLLA_Batch_Call_Sent_On__c = null;
            reqObj.isbatchProcessing__c = false;
        }
        if(reqObj.Request_Status__c == 'Hold for TPA non-compliance') {
            reqObj.Request_Status__c = 'In Review By IQVIA';
        }

        update reqObj;
        List<dsfs__DocuSign_Status__c> docuSign = new List<dsfs__DocuSign_Status__c>();
        if(reqObj != null  ){
            docuSign = [select id,name,dsfs__Completed_Date_Time__c, dsfs__Envelope_Status__c,dsfs__Voided_Reason__c,dsfs__Voided_Date_Time__c from dsfs__DocuSign_Status__c  where TPA_Request__c =: reqObj.Id order by createddate desc limit 1] ;
        }
        if(docuSign != null && docuSign.size() >0){
            if( reqObj.Request_Status__c == 'In Review By IQVIA' && docuSign[0].dsfs__Envelope_Status__c== 'voided' && docuSign[0].dsfs__Voided_Reason__c == 'TPA Request on Hold for TPA Non-Compliance' && (docuSign[0].dsfs__Voided_Date_Time__c > reqObj.Client_Request_Submission__c || docuSign[0].dsfs__Voided_Date_Time__c >reqObj.Vendor_App_Submitted__c)){
                SRV_TPA_TPARequest.sendMailtoTPProcessorAbtStatusUpdateFromComplianceHold(reqObj);
            }  
        }        
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

    global void finish(Database.BatchableContext BC)
    {
        if(requestsToVoidOnComplianceHold.size()>0){
            QBL_TPA_AsyncVoidEnvelope asyncVoidEnvelopeCall= new QBL_TPA_AsyncVoidEnvelope();
            asyncVoidEnvelopeCall.requestIds = requestsToVoidOnComplianceHold;
            asyncVoidEnvelopeCall.voidReason = 'TPA Request on Hold for TPA Non-Compliance ';
            if(!Test.isRunningTest()) 
                System.enqueueJob(asyncVoidEnvelopeCall);
        }
    }
}
