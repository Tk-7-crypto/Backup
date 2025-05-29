public without sharing class SRV_TPA_TPARequest {      
    public static TPA_Request__c tpaRequest;
    public static Boolean isRunCommercialAutoLogic;
    public static Map<String,String> reasonForAmaApprovalMap;// will review later
    public static Map<String, Watch_List__c> useOfferingsCategoryWatchMap;
    public static List<Watch_List__c> watchListsToBeUpserted;
    public static set<String> manualReviewReasonList;
    public static Boolean isOfferingOnSecondaryReview = false; // will review later
    public static Map<String, Map<String, Map<String, String>>> BUPurposeGeoLevelDataAssetMap;
    public static List<Watch_List__c> listWatchList;
    public static Map<String, TPA_Commercial_Review__c> commercialReasonMap = new Map<String,TPA_Commercial_Review__c>();
    public static Map<String,TPA_Assigned_TP_Processor__c> tempComOwnerMap;

    private static List<String> nonApprovedOfferingList = new List<String>();
    public static Map<string,string> responsibiltyMap;    
    public static Set<String> reasonsSet = new Set<String>();// will review later
    public static List<TPA_Commercial_Review__c> reasonsList = new List<TPA_Commercial_Review__c>();// will review later
    public static List<TPA_Purpose__c> PurposeAndDescriptionListPrvt;   
    public static Map<String, String> approvalNotificationMap = new Map<String, String>();
    public static Set<String> purposesRequireMRSet = new Set<String>();
    public static Map<String, TPA_Data_Asset__c> offeringsRequireMRMap = new Map<String, TPA_Data_Asset__c>();
    public static String dataAssetList;//will review later
    public static Map <String, TPA_Offering_Notification_Mapping__c> dynamicOffNotificationMappingMap {get; set;}
    public static Map <String, List<TPA_Offering_Notification_Mapping__c> > dynamicOffNotificationMappingWithCountryMap {get; set;}
    public static Map <String, List<TPA_Offering_Notification_Mapping__c> > tpaOffNotRulesForOffNotiMap {get; set;}
    public static List<TPA_Offering_Notification_Mapping__c> offNotMappingLst {get; set;}
    //public static Set<Id> masterPurposeIds = new Set<Id>();
    public static Set<Id> transactionalPurposeIds = new Set<Id>();
    public static Set<String> futureApprovedAddHocTermsKeys = new Set<String>();
    //public static boolean addTPProcessorInitials = false;
    //public static String assignedTPProcessorName = '';
    public static boolean sendVendorSecondaryEmail = false;
    public static boolean sendSecondaryEmail = false;
    public static boolean sendLegalMail = false;
    public static boolean isSecComReview = false;
    public static boolean multiRetriggerForSecondaryReviews = false;
    public static boolean isSecRevTableRechedMaxLimit = false;

    public static List<Task> tasksToInsert {get; set;}
	

    public static Boolean runCommercialAutoLogic() {
        if( UTL_TPA.tpaSetting.Enable_Commercial_Review_Automation__c  && tpaRequest != null && !tpaRequest.Is_Potential_Vendor_Case__c && (!tpaRequest.is_Bulk_TPA_Request__c || (tpaRequest.is_Bulk_TPA_Request__c && UTL_TPA.tpaSetting.Enable_Comm_Auto_for_Bulk_Requests__c))) {
            return true;
        }
        return false;
    }
     
    public static List<TPA_Purpose__c> getPurposeAndDescriptionList(ID reqId) {
        if(PurposeAndDescriptionListPrvt == null) {
            PurposeAndDescriptionListPrvt = [Select Id,
                                             Name,
                                             Purpose_Region__c, 
                                             Request__c,
                                             AMABridgeFile_Details__c,
                                             AMABridgeFile__c,
                                             Additional_Reference_Info__c,
                                             Business_Line__c,
                                             Client_Deliverables__c,
                                             Consulting_Area__c,
                                             Data_Assets__c,
                                             Purpose__r.Requires_Manual_Review__c,
                                             TPA_Purpose_Category__r.Category_Name__c,
                                             Other_Text__c, 
                                             Data_Usage__c,
                                             Deliverables_Freq_To_Client__c,
                                             Dollar_Value__c,
                                             Extended_Category_Codes__c,
                                             FinDr_ID__c,
                                             Has_Linked_Data__c,
                                             Has_Reference_Data__c,
                                             IMSPrescriberIDNumber_Details__c,
                                             IMSPrescriberIDNumber__c,
                                             Linked_Data_Description__c,
                                             Managed_Care_Details__c,
                                             Managed_Care__c,
                                             NCPDPIDorNPIOutletNumber_Details__c,
                                             NCPDPIDorNPIOutletNumber__c,
                                             Other_Details__c,
                                             Other_Reference_File__c,
                                             OutletReferenceFiles__c,
                                             PrescriberNPINumber_Details__c,
                                             PrescriberNPINumber__c,
                                             Prescriber_ID_Number_Details__c,
                                             Prescriber_ID_Number__c,
                                             Purpose__c,
                                             Region__c,
                                             Primary_Purpose_Name__c,
                                             Purpose__r.Id,
                                             Purpose__r.English_Translation__c,
                                             Purpose__r.Japanese_Translation__c,
                                             Purpose__r.French_Translation__c,
                                             BU__c,
                                           //  IMS_Legal_Entity__r.IMS_Master_Legal_Entity__r.id,
                                             Translated_Purpose_Name__c,  
                                             (Select Description__c,
                                              Other_Details__c,
                                              Description__r.Requires_Manual_Review__c,
                                              Requires_Manual_Review__c,
                                              Purpose__r.Name, Purpose__r.Purpose_Category_Name__c 
                                              From Purpose_Descriptions__r)
                                             from TPA_Purpose__c
                                             where Request__c = :reqId];
        }
        return PurposeAndDescriptionListPrvt;
    }

    public static Map<Id, List<TPA_Data_Asset__c>> getPurposeIdDataAssetMap( Set<Id> purposeId ) {
        CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
        Map<Id,List<TPA_Data_Asset__c>> purposeIdDataAssetMap = new Map<Id,List<TPA_Data_Asset__c>>();
        
        for( TPA_Data_Asset__c dataAsset : tpaDataAssetListCopy(purposeId) ) {
            List<TPA_Data_Asset__c> tempList = new List<TPA_Data_Asset__c>();
            if( purposeIdDataAssetMap.containskey( dataAsset.Purpose__c) ) {
                tempList = purposeIdDataAssetMap.get( dataAsset.Purpose__r.Id);                               
            }
            tempList.add( dataAsset );
            purposeIdDataAssetMap.put( dataAsset.Purpose__c, tempList); 
        }
        CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
        return purposeIdDataAssetMap ;
    }

    public static Map<Id, List<TPA_Secondary_Data_Asset__c>> getPrimaryDataAssetMap( Set<Id> purposeIdSet ) {
        Map<Id, List<TPA_Secondary_Data_Asset__c>> dataAssetTOSecondaryAssetMap = new Map<Id,List<TPA_Secondary_Data_Asset__c>>();
        for( TPA_Data_Asset__c dataAsset :  tpaDataAssetListCopy(purposeIdSet) ) {             
            if( dataAsset.TPA_Secondary_Data_Assets__r.size() > 0 ){
                dataAssetTOSecondaryAssetMap.put( dataAsset.Id, dataAsset.TPA_Secondary_Data_Assets__r );
            }
            if(dataAsset.TPA_Secondary_Data_Assets__r == null || dataAsset.TPA_Secondary_Data_Assets__r.size() == 0 ) {
                dataAssetTOSecondaryAssetMap.put( dataAsset.Id, new List<TPA_Secondary_Data_Asset__c>() );
            }
        }
        return dataAssetTOSecondaryAssetMap ;
    }

    public  Map<Id, List<TPA_Secondary_Data_Asset__c>> getPrimaryDataAssetMapCopy( Set<Id> purposeIdSet ) {
        Map<Id, List<TPA_Secondary_Data_Asset__c>> dataAssetTOSecondaryAssetMap = new Map<Id,List<TPA_Secondary_Data_Asset__c>>();
        for( TPA_Data_Asset__c dataAsset :  [Select id,Asset_Name__c,
        Purpose__r.Name,
        purpose__r.TPA_Purpose_Category__c,
        purpose__r.purpose__c,
        Purpose__r.TPA_Purpose_Category__r.Category_Name__c,
         BU__c,
         Geo_Level__c,
         Requires_Manual_Review__c,
         Data_Asset__c,
         Data_Asset__r.External_License_Data_Supplier_Req__c,
         Data_Asset__r.Requires_Manual_Review__c,
         Data_Asset__r.BU__c,
         Data_Asset__r.Geo_Level__c,
         Data_Asset__r.Commercial_Owner_Email__c,
         Data_Asset__r.Requires_Secondary_Review__c,
         Data_Asset__r.Secondary_Commercial_Reviewer_Email__c,
         A_Column_Use_For_Template__c,
         Other_Data_Asset_Details__c,
         Nostradata_Source_of_Business_LRx__c,
         Longitudanal_Patient_Diagonsis__c,
         CH_Other_Outlet_Profits__c,
         CH_Hospital_Profits__c,
         CH_Combined_Hos_and_Ret_Profit_AU__c,
         Health_Plan_Claims_Data__c,
         LAAD_Longitudinal_Access_and_Adj_data__c,
         Patient_Reference_File__c,
         Payer_Companion_File__c,
         Provider_Companion_File__c,
         CWH_NZ_Scan_data__c,
         CH_Retail_Profits__c,
         STI_Data_Report_Name__c,
         
        (select id,
        bu__c,
        Secondary_Asset_Name__c,
        IMS_Secondary_Data_Asset__c,
        Nostradata_Source_of_Business_LRx__c,
        Combined_Hos_and_Ret_Profit_AU__c,
        AU_Profits__c,
        AU_Other_Outlet_Data_Profits__c,
        AU_DDD_Hospital_Profits__c,
        Nostradata_LRx_Volume__c,
        Pharmacy_Scan__c,
        BrandImpact_Study_Name__c,
        BrandImpact_Delivery_Date__c,
        Channel_Dynamics_Study_Name__c,
        Channel_Dynamics_Delivery_Date__c,
        Pro_Voice_Study_Name__c,
        Pro_Voice_Delivery_Date__c,
        Outliner_Label_Code__c,
        Outliner_Data_Period_Text__c,
        STI_Data_Custom_Report_Name__c,
        IMS_Secondary_Data_Asset__r.Requires_Manual_Review__c,
        IMS_Secondary_Data_Asset__r.Commercial_Manager_Email__c,
        IMS_Secondary_Data_Asset__r.Need_license_or_data_supplier_permission__c,
        TPA_Data_Asset__r.A_Column_Use_For_Template__c,
        TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.Category_Name__c
        from TPA_Secondary_Data_Assets__r)  
        From TPA_Data_Asset__c t where Purpose__c IN : purposeIdSet]) {             
            if( dataAsset.TPA_Secondary_Data_Assets__r.size() > 0 ){
                dataAssetTOSecondaryAssetMap.put( dataAsset.Id, dataAsset.TPA_Secondary_Data_Assets__r );
            }
            if(dataAsset.TPA_Secondary_Data_Assets__r == null || dataAsset.TPA_Secondary_Data_Assets__r.size() == 0 ) {
                dataAssetTOSecondaryAssetMap.put( dataAsset.Id, new List<TPA_Secondary_Data_Asset__c>() );
            }
        }
        return dataAssetTOSecondaryAssetMap ;
    }

    public static List<TPA_Purpose__c> purposeList;
    public static List<TPA_Purpose__c> getPurposesList(String Id) {
        if(purposeList == null) {
            purposeList = [select id, name, BU__c, Request__c, Purpose__c, Purpose__r.Id, Purpose__r.English_Translation__c, Purpose__r.Japanese_Translation__c, Purpose__r.French_Translation__c, IMS_Legal_Entity__r.IMS_Master_Legal_Entity__r.id,  Other_Text__c, Purpose_Category_Name__c, TPA_Purpose_Category__r.Category_Name__c, (select id, Description__r.Requires_Manual_Review__c, Requires_Manual_Review__c from Purpose_Descriptions__r) from TPA_Purpose__c where request__c =: Id ];
        }
        return purposeList;
    }

    public static List<TPA_Purpose__c> purposeListForClientSubmission;
    public static List<TPA_Purpose__c> getPurposesListForClientSubmission(String Id) {
        if(purposeListForClientSubmission == null) {
            purposeListForClientSubmission = [Select Id, Name, Purpose_Category_Name__c From TPA_Purpose__c where Request__c =: Id ];
        }
        return purposeListForClientSubmission;
    }

    public static List<TPA_Data_Asset__c> offeringList;
    public static List<TPA_Data_Asset__c> getOfferingsList(Set<Id> purposeId){
        if(offeringList == null){
            offeringList = [SELECT id, Data_Asset__r.English_Translation__c, Data_Asset__r.Japanese_Translation__c, Data_Asset__r.IMS_Legal_Entity__c, Purpose__c, Purpose__r.Id, Purpose__r.Name, Purpose__r.Purpose_Category_Name__c, Purpose__r.Other_Text__c, Primary_Asset_Geo_Level__c, Geo_Level__c, BU__c, A_Column_Use_For_Template__c, Other_Data_Asset_Details__c, Other_Text__c, Name, Asset_NametText__c, Asset_Name__c, additional_terms_required__c, Request__c, Is_IMS_AGProduct__c, Is_Restricted_Data__c, hasXponentPlanTrak__c, (SELECT id, BU__c, additional_terms_required__c,  IMS_Secondary_Data_Asset__r.English_Translation__c, IMS_Secondary_Data_Asset__r.Japanese_Translation__c, IMS_Secondary_Data_Asset__r.IMS_Legal_Entity__c, Secondary_Asset_Name__c FROM TPA_Secondary_Data_Assets__r) from TPA_Data_Asset__c where Purpose__c in: purposeId order by Purpose__c,Asset_NametText__c];
        }
        return offeringList;
    }

    public static List<TPA_Data_Asset__c> offeringListForClientSubmission;
    public static List<TPA_Data_Asset__c> getOfferingsListForClientSubmission(Set<Id> purposeId){
        if(offeringListForClientSubmission == null){
            offeringListForClientSubmission = [SELECT id, Asset_Name__c,Geo_Level__c, Asset_NametText__c, Data_Asset__r.IMS_Legal_Entity__c, BU__c, additional_terms_required__c, Purpose__r.Id, A_Column_Use_For_Template__c, (SELECT id, Secondary_Asset_Name__c, IMS_Secondary_Data_Asset__r.IMS_Legal_Entity__c, additional_terms_required__c, BU__c FROM TPA_Secondary_Data_Assets__r) from TPA_Data_Asset__c where Purpose__c in: purposeId order by Purpose__c,Asset_NametText__c];
        }
        return offeringListForClientSubmission;
    }

    public static Map<Id,List<TPA_Data_Asset__c>> getUseIdOfferingsMap(Set<Id> purposeId){
        Map<Id,List<TPA_Data_Asset__c>> useIdOfferingMap = new Map<Id,List<TPA_Data_Asset__c>>();
        for(TPA_Data_Asset__c dasset:getOfferingsList(purposeId)){
            if(useIdOfferingMap.containsKey(dasset.Purpose__c)){
                List<TPA_Data_Asset__c> tempList = useIdOfferingMap.get(dasset.Purpose__c);
                tempList.add(dasset);
            }
            else{
                useIdOfferingMap.put(dasset.Purpose__c,new List<TPA_Data_Asset__c>{dasset});
            }
        }
        return useIdOfferingMap;
    }

    public static Map<String, String> MapCountrywithOfferingId {
        get {
            if(MapCountrywithOfferingId == null) {
                MapCountrywithOfferingId = new Map<String, String>();
                List<IMS_Data_Asset__c> imsDataAssetList = [select id, BU__c, Geo_Level__c, Asset_Name__c 
                from IMS_Data_Asset__c where BU__c != null and Is_Active__c = true and Asset_Name__c = 'OneKey Database'];
                for(IMS_Data_Asset__c obj : imsDataAssetList){
                    if(!tpaOffNotRulesForOffNotiMap.containsKey(obj.BU__c)) {
                        MapCountrywithOfferingId.put(obj.BU__c, obj.id);
                    }
                }   
            }
            return MapCountrywithOfferingId;
        }
        private set;
    }

    
    public static TPA_Request__c parentRequest;
    public Id tpaRequestId;
    public static String requestNumber;
    public static String type;
    public static String isRenewedReqUseandOfferingChanged;
    public static User currentUser;
    public static String LastAction;
    public Static List<String> TPProcessorEmailId = new List<String>();
    public static Boolean isSubContractAdded = false;
    public static Boolean create;
    public static Boolean isRunTPAButtonClicked = false;
    public static Boolean isOffNotificationDocGenerated = false;
    public static String runType = '';
    
    public static Boolean isLAADOffering = false;
    public static Boolean isVendorChecklistChanges = false;
    public static Boolean isSubnationalOff = false;
    public static Boolean isAisleOff = false;
    public static Boolean isSouthAfrica = false;
    public static Boolean isContainUSEforVeeva = false;
    public static Boolean isUseCRM = false;
    public static Boolean isOffOneKey = false;
    //public static Boolean isCanadaRefOff = false;
    public static Boolean isAPLDOffSpecVendors = false;
    public static Boolean isLongPrescriData = false;
    public static Boolean isMedClaimsData = false;
    public static Boolean isOnekeySelectOfferingPresent = false;
    public Static Set<String> specVendorOffNameList = new Set<String>();
    public static String authorizedSignerResponse {get;set;}
    public static Boolean isDirectToClientExeMode = false;
    public static Boolean isQuintilesIMSSalesExeMode = false;
    public static Boolean includeAmaAttributesOnly = false;
    public static Boolean isDynamicNotiAckRecived = false;
    public static Boolean istriggerManualReviewReasonsOnly = false;
    public static Boolean isIncentiveCompensationWithLAAD = false; 
    
    
    public static Id comRevId;
    public static Boolean isReminderForCommercialOwner = false;
    public static Boolean isReminderForExpertAnalysisUseSelected = false;
    public static Boolean sendFinalReviewMail = false;
    public static Boolean sendLegalReviewMail = false;
    public static Boolean primaryReviewsSubmission = false;
    public static Boolean secOfferingMailRequired = false;
    public static Boolean secOfferingMailRequiredPrimAllCompleted = false;
    public static Boolean reminderSecOfferingMailRequired = false;
    public static Boolean sendSecondaryOffReviewMail = false;
    public static Boolean sendVendorSecReviewMail = false;
    public static List<Id> multiRetriggerIds;
    public static Set<Id> allPurposeIds = new Set<Id>();
    
    public static List<Workflow_Email_Record__c> lstEmailWorkflow = new List<Workflow_Email_Record__c>();
    public static Map<Id, List<TPA_Additional_Term__c>> MlegalEntityToAdditionalTermsMap = new Map<Id, List<TPA_Additional_Term__c>>();
    
    public static TPA_Text_Editor__c emailFooterRecord {
        get {
            if(emailFooterRecord == null) {
                List<TPA_Text_Editor__c> emailFooterList = [SELECT Id, 
                                      Name, 
                                      Content__c, 
                                      English_Translation__c, 
                                      Japanese_Translation__c, 
                                      Page_Name__c, 
                                      Page_Title__c, 
                                      Page_Type__c 
                                FROM TPA_Text_Editor__c 
                                WHERE Page_Title__c = 'emailFooter'
                                and Is_Active__c = true 
                                LIMIT 1];
                if(emailFooterList != null && emailFooterList.size() > 0) {
                    emailFooterRecord = emailFooterList[0];
                }
            }
            return emailFooterRecord;
        }
        set;
    }    

    public static String addEmailFooter(String emailBody) {
        if(emailBody != null && emailFooterRecord != null) {
            emailBody = emailBody.replace('[TPA_Email_Footer_En]', emailFooterRecord.English_Translation__c);
            emailBody = emailBody.replace('[TPA_Email_Footer_JA]', emailFooterRecord.Japanese_Translation__c);
        }
        return emailBody;
    }

    public static String setEmailInitials(String assignedTPProcessorInitials, String globalTPProcessorInitials, String emailSubject) {
        string tpProcessorInitial = '(TBD)';
        if(assignedTPProcessorInitials != null && assignedTPProcessorInitials != '' && globalTPProcessorInitials != null && globalTPProcessorInitials != ''  && assignedTPProcessorInitials != globalTPProcessorInitials) {
            tpProcessorInitial = '(' +assignedTPProcessorInitials +') ('+ globalTPProcessorInitials + ')';
        }
        else if(assignedTPProcessorInitials != null && assignedTPProcessorInitials != '' && globalTPProcessorInitials != null && globalTPProcessorInitials != '' && assignedTPProcessorInitials == globalTPProcessorInitials) {
            tpProcessorInitial = '(' +globalTPProcessorInitials + ')';
        }
        else if(assignedTPProcessorInitials != null && assignedTPProcessorInitials != '' && (globalTPProcessorInitials == null || globalTPProcessorInitials == '')){
            tpProcessorInitial = '(' + assignedTPProcessorInitials + ')';
        }
        else if(globalTPProcessorInitials != null && globalTPProcessorInitials != '' && (assignedTPProcessorInitials == null || assignedTPProcessorInitials == '')){
            tpProcessorInitial = '(' + globalTPProcessorInitials + ')';
        }
        if(emailSubject != '') {
            emailSubject = tpProcessorInitial + ' ' + emailSubject;
        }
        return emailSubject;
    }

    public static Workflow_Email_Record__c sendBulkEmailThroughWorkfloww(List<String> toAddresses, List<string> ccAddresses, String emailType, String templateId, Id emailWhatId, List<Attachment> lstAttachment, String subject, boolean isAttachmentRequired, string staticContent, boolean addTPProcessorInitials, boolean addGlobalTPProcessorInitials, TPA_Request__c tpaRequest) {
        system.debug('in sendBulkEmailThroughWorkfloww');
        System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
        if(!UTL_TPA.isSendOutgoingEmails) {            
            return null;
        }
        try {
            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        
            Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();

            List<String> recipientAddresses = new List<String>();

            system.debug('templateId ::::'+templateId+'emailWhatId ::::'+emailWhatId);
                
            if(toAddresses != null && toAddresses.size() > 0) {
                for(string strToEmail: toAddresses) {
                    if(!Test.isRunningTest() && (UTL_TPA_Multilingual.isValidEmailId(strToEmail) || UTL_TPA_Multilingual.isValidRecordId(strToEmail))) {
                        recipientAddresses.add(strToEmail);
                    }
                }
            }
            //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
            if(ccAddresses != null && ccAddresses.size() > 0) {
                for(string strCcEmail: ccAddresses) {
                    if(!Test.isRunningTest() && (UTL_TPA_Multilingual.isValidEmailId(strCcEmail) || UTL_TPA_Multilingual.isValidRecordId(strCcEmail))) {
                        recipientAddresses.add(strCcEmail);
                    }
                }
            }
            //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
            if(templateId != '' && templateId != null && (staticContent == '' || staticContent == null)) {
                try {
                    //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                    emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, emailWhatId);
                    //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                    if(Test.isRunningTest()) {
                        SRV_TPA_TPARequest.getCustomException();
                    }
                } catch(Exception exp) {
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::SRV_TPA_TPARequest:::sendBulkEmailThroughWorkfloww:::objWorkFlowEmail Insert Exception' + ':::emailType:::' +((emailType != null) ? emailType : '') , emailWhatId));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                    System.debug(emailType + ' Email Failed: ' + exp.getMessage());
                }
                //Database.rollback(sp);
                //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                objWorkFlowEmail.content_1__c = addEmailFooter(emailNotToSend.getHTMLBody());
                objWorkFlowEmail.Email_Subject__c = (subject != null && subject.length() > 0) ? subject : emailNotToSend.getSubject();
                //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
            }
            else {
                if(staticContent != null) {
                   // System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                   // staticContent = addEmailFooter(staticContent);
                    if(emailFooterRecord != null && (staticContent.contains('[TPA_Email_Footer_En]') || staticContent.contains('[TPA_Email_Footer_JA]'))) {
                        staticContent = staticContent.replace('[TPA_Email_Footer_En]', emailFooterRecord.English_Translation__c);
                        staticContent = staticContent.replace('[TPA_Email_Footer_JA]', emailFooterRecord.Japanese_Translation__c);
                    }
                   // System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                    Integer content1FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.getMap().get('content_1__c').getDescribe().getLength();
                    //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                    Integer content2FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.getMap().get('content_2__c').getDescribe().getLength();
                    Integer content3FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.getMap().get('content_3__c').getDescribe().getLength();
                    Integer content4FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.getMap().get('content_4__c').getDescribe().getLength();
                    //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                    if(Test.isRunningTest()) {
                        content1FieldLength = content2FieldLength = content3FieldLength = content4FieldLength = 3;
                    }
                  //  System.debug('staticContent size = ' + staticContent.length());
                    //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                    if(staticContent.length() < content1FieldLength) {
                        objWorkFlowEmail.content_1__c = staticContent;
                        //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                    } 
                    else {
                        //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                        objWorkFlowEmail.content_1__c = staticContent.substring(0, content1FieldLength);
                        //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                        if(staticContent.length() < content1FieldLength + content2FieldLength) {
                            //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                            objWorkFlowEmail.content_2__c = staticContent.substring(content1FieldLength, staticContent.length());
                            //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                        } 
                        else {
                           // System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                            objWorkFlowEmail.content_2__c = staticContent.substring(content1FieldLength, content1FieldLength + content2FieldLength);
                            if(staticContent.length() < content1FieldLength + content2FieldLength + content3FieldLength ) {
                                objWorkFlowEmail.content_3__c = staticContent.substring(content1FieldLength + content2FieldLength, staticContent.length());
                            } 
                            else {
                                objWorkFlowEmail.content_3__c = staticContent.substring(content1FieldLength + content2FieldLength, content1FieldLength + content2FieldLength  + content3FieldLength);
                                if(staticContent.length() < content1FieldLength + content2FieldLength + content3FieldLength + content4FieldLength ) {
                                    objWorkFlowEmail.content_4__c = staticContent.substring(content1FieldLength + content2FieldLength + content3FieldLength, staticContent.length());
                                } 
                                else {
                                    objWorkFlowEmail.content_4__c = staticContent.substring(content1FieldLength + content2FieldLength + content3FieldLength, content1FieldLength + content2FieldLength  + content3FieldLength  + content4FieldLength);
                                }
                            }
                        }
                    }
                }
                //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                objWorkFlowEmail.Email_Subject__c = subject;
            }
            //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
            
            if((addTPProcessorInitials || addGlobalTPProcessorInitials) && tpaRequest != null) {
                String assignedTPProcessorInitials = '';
                String globalTPProcessorInitials = '';
                if(addTPProcessorInitials && tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                    assignedTPProcessorInitials = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
                }
                if(addGlobalTPProcessorInitials && tpaRequest.Co_Assigned_Global_TP_Processor__r.Is_Active__c ) {
                    globalTPProcessorInitials = tpaRequest.Co_Assigned_Global_TP_Processor__r.Initials__c;
                }
                objWorkFlowEmail.Email_Subject__c = setEmailInitials(assignedTPProcessorInitials, globalTPProcessorInitials, objWorkFlowEmail.Email_Subject__c);
            }
            //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
            if(isAttachmentRequired) {
                string attDetails = '';
                for(Attachment objAtt: lstAttachment) {
                    attDetails += objAtt.Name+'~~'+objAtt.Id+';';
                }
                objWorkFlowEmail.Attachment_Details__c = attDetails;
            }
            
            objWorkFlowEmail.isAttachmentRequired__c = isAttachmentRequired;
            if(emailWhatId != null) {
                objWorkFlowEmail.Related_To_Object_Id__c = emailWhatId;
                objWorkFlowEmail.Related_To_Object_Api__c = emailWhatId.getSObjectType().getDescribe().getName();
            }
            //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
            objWorkFlowEmail.Module_Name__c = 'TPA';

            if(emailType != null && (emailType ==  'Client Submission Renew' || emailType ==  'Email New and Edited Request')){
                objWorkFlowEmail.Email_Action__c = 'TPA_02_SendVendorSubmissionEmail';
            } 
            else if(emailType == 'SendCountryOfferingReport') {
                objWorkFlowEmail.Attachment_Details__c = SCH_TPA_Agreement_UpdateStatus.offeringWBReportFltr;
                objWorkFlowEmail.Email_Action__c = 'TPA_03_SendCountryOfferingReport';
            } 
            else if(emailType == 'SendComplianceHoldEmail') {
                    objWorkFlowEmail.Email_Action__c = 'TPA_04_SendComplianceHoldRes';
            }else if(emailType == 'SendAMAFeeDeclinedEmail') {
                objWorkFlowEmail.Email_Action__c = 'TPA_05_AMA_Fee_Declined_Email';
            }else if(emailType == 'SendTPA500rMoreLicensesEmail') {
                objWorkFlowEmail.Email_Action__c = 'TPA_06_50orMore_Licenses_Email';
            }
                
            else {
                    objWorkFlowEmail.Email_Action__c = 'TPA_01_SendEmail';
            }
            //System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());  
            Integer toEmailCounter = 1;
            Integer toUserCounter = 1;
            if(recipientAddresses != null && recipientAddresses.size() > 0) {
                for(string strToEmail: recipientAddresses) {
                    if(UTL_TPA_Multilingual.isValidEmailId(strToEmail)) {
                        objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', strToEmail);
                        toEmailCounter++;
                    }
                    else if(UTL_TPA_Multilingual.isValidRecordId(strToEmail)) {
                        objWorkFlowEmail.put('To_User_'+toUserCounter+'__c', strToEmail);
                        toUserCounter++;
                    }
                }
            }
            
            if(Test.isRunningTest()) {
                objWorkFlowEmail.content_1__c = 'TEST Content';
                objWorkFlowEmail.Email_Subject__c = 'TEST Subject';
                SRV_TPA_TPARequest.getCustomException();
            }
            System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());  
            return objWorkFlowEmail;  
                
        }
        catch(Exception ex) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SRV_TPA_TPARequest:::sendBulkEmailThroughWorkflow:::objWorkFlowEmail Insert Exception', emailWhatId));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            system.debug('workFlowException:::'+ex.getMessage());
        }
        return null;  
    }

    public static void sendTPANotifications(List<String> toAddresses, List<string> ccAddresses, String emailType, String language, Id emailWhatId, Boolean saveAsActivity, List<Attachment> lstAttachment, String subject, boolean addTPProcessorInitials, boolean addGlobalTPProcessorInitials, TPA_Request__c tpaRequest) {
        String emailLanguage = (language == null || language == '') ? 'English' : language;
        
        Id emailTempId = UTL_TPA_Multilingual.getEmailTemplateId(emailType, emailLanguage);
        System.debug('emailTempId:'+emailTempId);

        if(emailType != null 
        && (emailType ==  'Client Submission Renew' 
        || emailType ==  'Email New and Edited Request' 
        || emailType == 'VSN Cancelation Confirmation' 
        || emailType == 'Email CompetitiveServices'
        || emailType == 'Email Renewal Noti Client'
        || emailType == 'Email Pending Expiration'
        || emailType == 'Notify Affiliated DBL Regarding Update'
        || emailType == 'Email Post Expiration')) {            
            Workflow_Email_Record__c objWorkFlowEmail = sendBulkEmailThroughWorkfloww(toAddresses, ccAddresses, emailType, emailTempId, emailWhatId, lstAttachment, subject, FALSE, '', TRUE, TRUE, tpaRequest);
            if(objWorkFlowEmail != null) {
                upsert objWorkFlowEmail;
            }
            return;
        }
        
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();

        try {
            emailNotToSend = Messaging.renderStoredEmailTemplate(emailTempId, NULL, emailWhatId);
        } catch(Exception exp) {
            System.debug(emailType + ' Email Failed: ' + exp.getMessage());
        }
        //Database.rollback(sp);

        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();

        emailToSend.setCharset('UTF-8');

        if(toAddresses != null && toAddresses.size() > 0) {
            emailToSend.setToAddresses(toAddresses);
        }
        if(ccAddresses != null) {
            emailToSend.setCcAddresses(ccAddresses);
        }

        emailToSend.setPlainTextBody(emailNotToSend.getPlainTextBody());
        emailToSend.setHTMLBody(addEmailFooter(emailNotToSend.getHTMLBody()));

        if(subject != null && subject.length() > 0) {
            emailToSend.setSubject(subject);
        } else {
            emailToSend.setSubject(emailNotToSend.getSubject());
        }
        if((addTPProcessorInitials || addGlobalTPProcessorInitials) && tpaRequest != null) {
            String assignedTPProcessorInitials = '';
            String globalTPProcessorInitials = '';
            if(addTPProcessorInitials && tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                assignedTPProcessorInitials = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
            }
            if(addGlobalTPProcessorInitials && tpaRequest.Co_Assigned_Global_TP_Processor__r.Is_Active__c ) {
                globalTPProcessorInitials = tpaRequest.Co_Assigned_Global_TP_Processor__r.Initials__c;
            }
            emailToSend.setSubject(setEmailInitials(assignedTPProcessorInitials, globalTPProcessorInitials, emailToSend.getSubject()));
        }

        if(UTL_TPA.orgWideEmailAddress != null) {
            emailToSend.setOrgWideEmailAddressId(UTL_TPA.orgWideEmailAddress);
        }

        emailToSend.setWhatId(emailWhatId);
        emailToSend.setSaveAsActivity(saveAsActivity);
        emailToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
        emailToSend.setTreatTargetObjectAsRecipient(false);
        
        if(lstAttachment != null && lstAttachment.size() > 0) {
            List<Messaging.Emailfileattachment> emailAttach = new List<Messaging.Emailfileattachment>();
            Attachment a = lstAttachment[0];
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(a.Name);
            efa.setBody(a.Body);
            emailAttach.add(efa);
            emailToSend.setFileAttachments(emailAttach);
        }

        if(emailType != null && emailType ==  'VSN TP Processor Notification') {
            emailToSend.setUseSignature(false); 
        }
        
        if(emailType != null && (emailType ==  'Client Submission Renew' || emailType ==  'Email New and Edited Request')){
            if(String.isNotBlank(UTL_TPA.tpaSetting.TPA_BCC_Emails__c)) {
               List<String> bccTo = new List<String>();
               bccTo.addAll(UTL_TPA.tpaSetting.TPA_BCC_Emails__c.split(';'));
               emailToSend.setBccAddresses(bccTo);
            }
        }
        
        emailsList.add(emailToSend);
        
        try {
            if(!emailsList.isEmpty() && UTL_TPA.isSendOutgoingEmails) {
                Messaging.sendEmail(emailsList);
            }            
        } catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_TPARequest:::sendTPANotifications::emailsList send email error' + ':::emailType:::' +((emailType != null) ? emailType : ''), emailWhatId));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug(e.getMessage());
        }
    }

    

    
    //public static Map<Id,List<TPA_Secondary_Data_Asset__c>> dataAssetTOSecondaryAssetMap;
    public static List<TPA_Offering_Notification_Mapping__c> dynamicOfferingsNotificationListForVendor = new List<TPA_Offering_Notification_Mapping__c>();
    
    
    
    
    

    

    
    public static List<TPA_Commercial_Review__c> ListOfComReviwer{
        get{
            if(ListOfComReviwer == null){
                ListOfComReviwer = [select id,Commercial_Owner_Name__c, Manual_Review_Reason__c,TP_US_Email__c, 
                                    Receiver_s_Email__c,BU__c,Associated_Offering_s_Use_Category_s__c,Associated_Offering_to_Review__c,
                                    Associated_Use_to_Review__c,Action__c,TP_Country_Email__c,TPA_Additional_Term__c from TPA_Commercial_Review__c 
                                    where TPA_Request__c =: tparequest.Id];
            }
            return ListOfComReviwer;
        }
        private set;
    }

    public static set<String> TpaTextTerms{
        get{
            if(TpaTextTerms == null){
        		List<String> southAfricaOfferings = System.Label.TPA_SubNational_Offerings.split(';');
                List<String> DDDOfferings = System.Label.TPA_DDD_Offering.split(';');
                List<String> XponentOrOneKey = System.Label.Xponent_or_OneKey_Offeing_List_for_Medpro.split(';');
                TpaTextTerms = new Set<String>();
                //List<TPA_Commercial_Review__c> ComRevList = [Select id, Associated_Offering_to_Review__c from TPA_Commercial_Review__c where TPA_Request__c =: tparequest.id];
                for (TPA_Commercial_Review__c comRev : ListOfComReviwer){
                    if(comRev.Associated_Offering_to_Review__c != null){
                        if(comRev.Associated_Offering_to_Review__c.indexOf('MIDAS') != -1 ){
                            TpaTextTerms.add('is_Midas__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('Patient Reference File') != -1 ){
                            TpaTextTerms.add('is_Patient_Reference_File__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('GE Centricity EMR') != -1 ){
                            TpaTextTerms.add('is_GE_Centricity_EMR__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.toLowerCase().indexOf('promo') != -1 ){
                            TpaTextTerms.add('is_Promotrak__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('Managed Care Workbook') != -1 ){
                            TpaTextTerms.add('is_Managed_Workbook__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('IQVIA Global Promo.track™') != -1 ){
                            TpaTextTerms.add('Is_Glbl_PromoTrack_Selected__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('IQVIA Consumer Aisle') != -1 ){
                            TpaTextTerms.add('is_South_Africa_Consumer_Health__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('PharMetrics® Plus') != -1 ){
                            TpaTextTerms.add('IS_Health_Plan_Claims__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('Patient Companion File') != -1 ){
                            TpaTextTerms.add('is_Patient_Companion_File__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('Provider Companion File') != -1 ){
                            TpaTextTerms.add('is_Provider_Companion_File__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('Payer Companion File') != -1 ){
                            TpaTextTerms.add('is_Payer_Companion_File__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('LAAD - Longitudinal Access and Adjudication Data') != -1 ){
                            TpaTextTerms.add('is_LAAD_Offering__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('Oncology electronic medical records data') != -1){
                            TpaTextTerms.add('Is_Oncology_EMR__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('Ambulatory electronic medical records data') != -1 ){
                            TpaTextTerms.add('Is_Ambulatory_EMR__c');
                        }
                        if(XponentOrOneKey.contains(comRev.Associated_Offering_to_Review__c)){
                            TpaTextTerms.add('is_Xponent_or_OneKey__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('Xponent PlanTrak') != -1 ){
                            TpaTextTerms.add('is_Xponent__c');
                        }
                        if(southAfricaOfferings.contains(comRev.Associated_Offering_to_Review__c) ){
                            TpaTextTerms.add('Is_South_Africa_Sub_Off__c');
                        }
                        if(DDDOfferings.contains(comRev.Associated_Offering_to_Review__c) ){
                            TpaTextTerms.add('isDDDOffering__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('Medpages Data') != -1){
                            TpaTextTerms.add('Is_MedPages_Data__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('AIM XR Web Search/Social Insights') != -1){
                            TpaTextTerms.add('is_AIM_XR__c');
                        }
                        if(comRev.Associated_Offering_to_Review__c.indexOf('Analytics Link – Client Extract Only – No 3rd Party tool access included') != -1){
                            TpaTextTerms.add('is_Analytics_Link__c');
                        }
                    }
                }
                if(tparequest != null){
                    for (IMS_Legal_Entity__c legalentityObj : tparequest.IMS_Legal_Entities__r){
                        if(legalentityObj.is_Canada__c != null && legalentityObj.is_Canada__c){
                            TpaTextTerms.add('is_Canada__c');
                        }
                    }
                }
            }
            return TpaTextTerms;
        }
        private set;
    }

    

    public static Map<Id, Set<Id>> tpaOfferingNotificationAcctMappingMap {get; set;}
    public static Map<Id, Set<Id>> gettpaOfferingNotificationAcctMappingMap(Id vedorID) {
        if(tpaOfferingNotificationAcctMappingMap == null) {
            tpaOfferingNotificationAcctMappingMap = new Map<Id, Set<Id>>();
            system.debug('vedorID'+vedorID);
            for(TPA_Off_Notification_Account_Mapping__c TPAOffNotificationAcctMappingObj : [Select id, TPA_Offering_Notification_Mapping_Rule__c, TPA_Offering_Notification_Mapping_Rule__r.id, TPA_Offering_Notification_Mapping_Rule__r.IsActive__c, Vendor_Account_Address__c, Vendor_Account_Address__r.id from TPA_Off_Notification_Account_Mapping__c where TPA_Offering_Notification_Mapping_Rule__r.IsActive__c = true and Vendor_Account_Address__c = :vedorID]) {
                Set<id> temp = tpaOfferingNotificationAcctMappingMap.get(TPAOffNotificationAcctMappingObj.TPA_Offering_Notification_Mapping_Rule__r.id);
                if(temp == null) {
                    tpaOfferingNotificationAcctMappingMap.put(TPAOffNotificationAcctMappingObj.TPA_Offering_Notification_Mapping_Rule__r.id, new Set<id>{TPAOffNotificationAcctMappingObj.Vendor_Account_Address__r.id});
                } else {
                    temp.add(TPAOffNotificationAcctMappingObj.Vendor_Account_Address__r.id);
                }
            }
        }
        //system.debug('tpaOfferingNotificationAcctMappingMap' + tpaOfferingNotificationAcctMappingMap);
        return tpaOfferingNotificationAcctMappingMap;
    }



    
    
    
    

    public static Boolean noManualReviewForTPA = false;
    
   

    //Private variables
    private static Id recordTypeId;
   
   
    private static Boolean is_IMS_AGProduct = false;
    private static Boolean hasMidas = false;
    private static Boolean hasXponentPlanTrak = false;
    private static Boolean hasManagedCareWorkBook = false;
    private static final string CLIENT_CON = 'Client';
    private static final string VENDOR_CON = 'Vendor';


    //Constructor
    // public SRV_TPA_TPARequest() {
    //     isSubContractAdded = false;
    // }

    /*
    * This method is used to get a Map of countries with its all the possible names.
    * @param: objectType - name of the object 
    * @param: fieldType - Name of the field
    * @return: map<string, string> Key- Country name, Value - All possible names for that country
    */
    public static map<string, string> getCountryCodeMap(String objectType, String fieldType) {
        //Country Map with all possible country name values
        map<string, string> tpReqCountryMap = new map<string, string>();
        
        List<String> submittingCountries = new List<String>();
        //Schema.DescribeFieldResult fieldResult = TPA_Region_Country__c.Country__c.getDescribe();
        // Get the describe for the object
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectType).getDescribe();
        // Get the field dynamically
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldType).getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry entry : ple) {
            submittingCountries.add(entry.getValue());
        }
        
        List<String> countrySet;
        String countryCode;
        for(String countryName : submittingCountries) {
            if(SRV_TPA_AMAAgreementDetail.mapCountryCodeName.containsKey(countryName.toLowerCase())) {
                countrySet = new List<String>();
                
                countryCode = SRV_TPA_AMAAgreementDetail.mapCountryCodeName.get(countryName.toLowerCase());
                
                if(countryCode != null && countryCode != '') {
                    countrySet.addAll(SRV_TPA_AMAAgreementDetail.mapCountryCodeWithName.get(countryCode.toLowerCase()).split(';'));
                    countrySet.add(countryCode.toLowerCase());
                    tpReqCountryMap.put(countryName.toLowerCase(), string.join(countrySet, ','));
                }
            }
            else {
                tpReqCountryMap.put(countryName.toLowerCase(), countryName.toLowerCase());
            }            
        }
        return tpReqCountryMap;
    }

    //Public methods
    /**
    * This method is used to get list of all TPA Contacts email addresss by TPA Request Ids.
    */
    public static Map<string, List<string>> getTPAContactEmailList(List<Id> tpaRequestIdsList) {
        Map<string, List<string>> tpaContacatEmailList = new Map<string, List<string>>();
        List<string> internalObj;
        List<TPA_Contact__c> tpaContactList = new List<TPA_Contact__c>([SELECT TPA_Request__c, Email__c, Name FROM TPA_Contact__c where TPA_Request__c IN : tpaRequestIdsList order by TPA_Request__c]);
        for(TPA_Contact__c tpaContact: tpaContactList) {
            internalObj = tpaContacatEmailList.get(tpaContact.TPA_Request__c);
            if(internalObj == null) {
                internalObj = new List<string>();
            }
            internalObj.add(tpaContact.Email__c);
            tpaContacatEmailList.put(tpaContact.TPA_Request__c, internalObj);
        }
        return tpaContacatEmailList;
    }

    public static string validateAgreementForInEffect(Id tpaRequestId) {
        String errorString = '';
 
        TPA_Request__c tpaRequest = [select id,
                                            Client_Address__c,
                                            Client_Address__r.Name,
                                            Name,
                                            Request_Status__c,
                                            Service_Provider_Name__c,
                                            Client_Contact_Territory__c,
                                            isLegalEntityPresent__c,
                                            Secondary_Client_Contact_Territory__c,
                                            client_language__c, 
                                            vendor_language__c,
                                            (select id, Secondary_Asset_Name__c, IMS_Legal_Entity__c, TPA_Data_Asset__c, TPA_Data_Asset__r.IMSLegalEntity__c from TPA_Tertiary_Data_Assets__r),
                                            (Select id, name, Is_AMA_License_Required__c,Vendor_Legal_Name__c,Client__c, DBL__c, Max_Fee_Reached__c, Agreement_End_Date__c, Contract_Type__c, AMA_Manual_Review__c, Send_DBL_Notification_To_AMA__c from AMA_Agreement_Details__r limit 1), 
                                            (select id,Asset_NametText__c,IMSLegalEntity__c from Data_Assets__r),
                                            (select id,IMS_Legal_Entity__c from Purposes__r), 
                                            (select Id, Name from Attachments order by LastModifiedDate Desc),
                                            (select id, dsfs__Envelope_Status__c from DocuSign_Status__r order by LastModifiedDate Desc limit 1)
                                     from TPA_Request__c
                                     where id =: tpaRequestId 
                                     LIMIT 1];
        System.debug('####UTL_TPA.validateAgreementForInEffect Agreement: ' + tpaRequest);
        System.debug('####UTL_TPA.validateAgreementForInEffect Agreement.Attachments.size() : ' + tpaRequest.Attachments.size());

        //validate the attachments for all possible scenarios
        if(tpaRequest != null && tpaRequest.Attachments.size() > 0) {
            string currentYear = String.valueOf(Date.Today().Year());
            string previousYear = String.valueOf(Date.Today().Year()-1);
            string nextYear = String.valueOf(Date.Today().Year()+1);
            List<String> withCompletedSuffixAttachments = new List<String>();
            List<String> withoutCompletedSuffixAttachments = new List<String>();
            Boolean isTLLASentPresent = false;
            Boolean isAMAOldSentPresent = false;
            Boolean isAMASentPresent = false;
            Boolean isHelpfulHintSent = false;
            Boolean isAMAOldCompletePresent = false;
            Boolean isTLLACompletePresent = false;
            Boolean isAMACompletePresent = false;
            Boolean isHelpfulHintCompletedAttached = false;
            String tpaRequestName = tpaRequest.Name.toLowerCase();
            String amaContractType = null;
            String sentTLLA ;
            String sentAMA ;
            String sentOldAMA;
            Boolean isNewAMADocRequired = false;
            Boolean isOldAMADocRequired = false;
            List<String> oldAMATemplateNames = new List<String>();
            oldAMATemplateNames = Label.AMA_Documents_Name.split(';');
            String previousNameTemplate ;
            String currentNameTemplate ;
            String nextNameTemplate;

            if(tpaRequest.AMA_Agreement_Details__r.size() > 0) {
                amaContractType = tpaRequest.AMA_Agreement_Details__r[0].Contract_Type__c == null ? '' : tpaRequest.AMA_Agreement_Details__r[0].Contract_Type__c.toLowerCase();
                if(tpaRequest.AMA_Agreement_Details__r[0].Is_AMA_License_Required__c) {
                    isNewAMADocRequired = true;
                }
            }

            for(Attachment attchmnt : tpaRequest.Attachments) {
                if(attchmnt.name.toLowerCase().IndexOf('_completed') != -1) {
                    List<String> lstSplittedName = new List<String>();
                    lstSplittedName = attchmnt.name.toLowerCase().split('_completed');
                    if(lstSplittedName != null && lstSplittedName.size()  == 1) {
                        withCompletedSuffixAttachments.add(attchmnt.name);
                    }
                }
                else {
                    withoutCompletedSuffixAttachments.add(attchmnt.name);
                }
            }

            for(String  att : withoutCompletedSuffixAttachments) {
                if(att.toLowerCase().indexOf('tlla') != -1) {
                    Boolean isAMA = false;
                    for(String templateName : oldAMATemplateNames) {
                        previousNameTemplate = previousYear +' ' +templateName.toLowerCase();
                        currentNameTemplate = currentYear +' ' +templateName.toLowerCase();
                        nextNameTemplate = nextYear +' ' +templateName.toLowerCase();
                        System.debug('Previous Names::::'+previousNameTemplate);
                        System.debug('Current Names::::'+currentNameTemplate);
                        System.debug('Next Names::::'+nextNameTemplate);
                        if( att.toLowerCase().indexOf(previousNameTemplate) != -1 
                         || att.toLowerCase().indexOf(currentNameTemplate) != -1 
                         || att.toLowerCase().indexOf(nextNameTemplate) != -1) {
                            isAMA = true;
                            break;
                        }
                    }
                    if(isAMA) {
                        if(!isAMAOldSentPresent) {
                            isOldAMADocRequired = true;
                            isAMAOldSentPresent = true;
                            sentOldAMA = att;
                            if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                                errorString += 'TPA Request Number is Invalid in AMA Document.';
                            }
                        }
                    }
                    else {
                        if(!isTLLASentPresent) {
                            isTLLASentPresent = true;
                            sentTLLA = att;
                            if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                                errorString += 'TPA Request Number is Invalid in TLLA Document.';
                            }
                        }
                    }
                    continue;
                }
                if(att.toLowerCase().indexOf('ama_') != -1 && !isAMASentPresent && isNewAMADocRequired) {
                    isAMASentPresent = true;
                    sentAMA = att;
                    if(att.toLowerCase().indexOf(tpaRequestName) == -1 && att.toLowerCase().indexOf(amaContractType) == -1) {
                        errorString += 'TPA Request Number and Contract Type is Invalid in AMA Document.';
                    }
                    else if(att.toLowerCase().indexOf(amaContractType) == -1) {
                        errorString += 'Contract Type is Invalid in AMA Document.';
                    }
                    else if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                        errorString += 'TPA Request Number is Invalid in AMA Document.';
                    }
                    continue;
                }
                if(att.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1 ){
                    isHelpfulHintSent = true;
                }
            }
            if(!isTLLASentPresent) {
                errorString += 'Agreement does not have TLLA Document';
            }
            if((!isAMASentPresent && isNewAMADocRequired) || (!isAMAOldSentPresent && isOldAMADocRequired)) {               
                errorString += 'Agreement does not have AMA Document';
            }
            if(!isHelpfulHintSent){
                errorString += 'Agreement does not have Helpful Hint Document';
            }
            for(String att : withCompletedSuffixAttachments) {
                System.debug('Completed Doc names are:'+att);
                if(att.toLowerCase().indexOf('tlla') != -1) {
                    Boolean isAMA = false;
                    for(String templateName : oldAMATemplateNames) {
                        previousNameTemplate = previousYear +' ' +templateName.toLowerCase();
                        currentNameTemplate = currentYear +' ' +templateName.toLowerCase();
                        nextNameTemplate = nextYear +' ' +templateName.toLowerCase();
                        System.debug('Previous Names::::'+previousNameTemplate);
                        System.debug('Current Names::::'+currentNameTemplate);
                        System.debug('Next Names::::'+nextNameTemplate);
                        if( att.toLowerCase().indexOf(previousNameTemplate) != -1 
                         || att.toLowerCase().indexOf(currentNameTemplate) != -1 
                         || att.toLowerCase().indexOf(nextNameTemplate) != -1) {
                            isAMA = true;
                            break;
                        }
                    }
                    if(isAMA) {
                        if(!isAMAOldCompletePresent) {
                            isAMAOldCompletePresent = true;
                            if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                                errorString += 'TPA Request Number is Invalid in AMA Completed Document.';
                            }
                        }
                    }
                    else {
                        if(!isTLLACompletePresent) {
                            isTLLACompletePresent = true;
                            if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                                errorString += 'TPA Request Number is Invalid in TLLA Completed Document.';
                            }
                        }
                    }
                    continue;
                }
                if(att.toLowerCase().indexOf('ama_') != -1 && !isAMACompletePresent && isNewAMADocRequired) {
                    isAMACompletePresent = true;
                    if(att.toLowerCase().indexOf(tpaRequestName) == -1 && att.toLowerCase().indexOf(amaContractType) == -1) {
                        errorString += 'TPA Request Number and Contract Type is Invalid in AMA Completed Document.';
                    }
                    else if(att.toLowerCase().indexOf(amaContractType) == -1) {
                        errorString += 'Contract Type is Invalid in AMA Completed Document.';
                    }
                    else if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                        errorString += 'TPA Request Number is Invalid in AMA Completed Document.';
                    }
                    continue;
                }
                if(att.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1 && att.indexOfIgnoreCase('completed') != -1 && !isHelpfulHintCompletedAttached){
                    isHelpfulHintCompletedAttached = true;
                    if(att.toLowerCase().indexOf(tpaRequestName) == -1) {
                        errorString += 'Helpful Hint Completed Document Name :TPA Request Number is Invalid';
                    }
                }
            }
            if(isTLLASentPresent && !isTLLACompletePresent) {
                errorString += 'Completed Document is missing for TLLA Document.';
            }
            if(isAMASentPresent && !isAMACompletePresent && isNewAMADocRequired) {
                errorString += 'Completed Document is missing for AMA Document.';
            }
            if(isAMAOldSentPresent && !isAMAOldCompletePresent && isOldAMADocRequired) {
                errorString += 'Completed Document is missing for AMA Document.';
            }
            if(isHelpfulHintSent && !isHelpfulHintCompletedAttached){
                errorString += 'Completed Document is missing for Helpful Hint Document.';
            } 
        } else {
            errorString += 'Agreement does not have any Attachments';
        }
        System.debug('####UTL_TPAs.validateAgreementForInEffect errorString:'+errorString);
        return errorString;
    }

    public static void sendRenewalAndExpirationMail(TPA_Request__c[] listTpaRequest) {
        Set<Id> tpaRequestIdsSet = (new Map<Id, TPA_Request__c>(listTpaRequest)).keySet();
        Set<String> fieldSet = new Set<String> {'Is_CPC_Expiration_Notice_Sent__c',
            'ClientContact__r.Email',
            'Client_TPA_Representative_Email__c',
            'Owner.Type',
            'Owner.Email',
            'ClientContact__r.Name',
            'Is_CPC_Renewal_Notice_Sent__c',
            'Vendor_Compliance_Email__c',
            'Is_CPC_Post_Expiration_Notice_Sent__c',
            'Client_Address__r.TPAOtherEmailIds__c',
            'TPA_Assigned_TP_Processor__r.Initials__c',
            'TPA_Assigned_TP_Processor__r.Is_Active__c',
            'Co_Assigned_Global_TP_Processor__c',
            'Co_Assigned_Global_TP_Processor__r.Is_Active__c',
            'Co_Assigned_Global_TP_Processor__r.Initials__c'};
        Map<Id, TPA_Request__c> oldTPARequestMap = new Map<Id, TPA_Request__c>(SLT_TPARequest.instance.getTPARequestById(tpaRequestIdsSet, fieldSet));

        String[] batchEmailAddresses = UTL_TPA.batchEmailAddresses.split(',', 0);

        Map<Id, TPA_Request__c> mailRenewalListMap = new Map<Id, TPA_Request__c>();
        Map<Id, TPA_Request__c> mailExpirationListMap = new Map<Id, TPA_Request__c>();
        Map<Id, TPA_Request__c> mailPostExpirationListMap = new Map<Id, TPA_Request__c>();
        List<Id> idsToSendRenewalMail = new List<Id>();
        List<Id> idsToSendExpirationMail = new List<Id>();
        List<Id> idsToSendPostExpirationMail = new List<Id>();
        Map<string, List<string>> mapContactCCEmails;
        List<string> contactCCList = new List<string>();
        List<string> contactToList = new List<string>();

        for(TPA_Request__c tpaObj: listTpaRequest) {
            system.debug('tpaId:'+tpaObj.Id);
            if(tpaObj.Is_CPC_Renewal_Notice_Sent__c
               && tpaObj.CPC_Renewal_Notice_Sent_Last_Date__c == null
               && tpaObj.Request_Status__c == 'In Effect') {
                   //TODO
                   //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success';
                   //TPAQueryHelper.setLogObject(tpaObj.id , 'Success:Agreement Added for Renewal Mail ', '');
                   //TPAQueryHelper.logRef().generateLog();
                   idsToSendRenewalMail.Add(tpaObj.Id);
                   mailRenewalListMap.put(tpaObj.Id, tpaObj);
                   tpaObj.Is_CPC_Renewal_Notice_Sent__c = false;
                   tpaObj.CPC_Renewal_Notice_Sent_Last_Date__c = DateTime.now();
               }
            if(tpaObj.Is_CPC_Expiration_Notice_Sent__c
               && tpaObj.CPC_Expiration_Notice_Sent_Last_Date__c == null
               && tpaObj.Request_Status__c == 'In Effect') {
                   //TODO
                   //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success';
                   //TPAQueryHelper.setLogObject(tpaObj.id , 'Success:Agreement Added for Expiration Mail ', '');
                   //TPAQueryHelper.logRef().generateLog();
                   idsToSendExpirationMail.Add(tpaObj.Id);
                   mailExpirationListMap.put(tpaObj.Id, tpaObj);
                   tpaObj.Is_CPC_Expiration_Notice_Sent__c = false;
                   tpaObj.CPC_Expiration_Notice_Sent_Last_Date__c = DateTime.now();
               }
            if(tpaObj.Is_CPC_Post_Expiration_Notice_Sent__c
               && tpaObj.CPC_Expiration_Postnotice_Sent_Last_Date__c == null) {
                   //TODO
                   //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success';
                   //TPAQueryHelper.setLogObject(tpaObj.id , 'Success:Agreement Added for Post Expiration Mail ', '');
                   //TPAQueryHelper.logRef().generateLog();
                   idsToSendPostExpirationMail.Add(tpaObj.Id);
                   mailPostExpirationListMap.put(tpaObj.Id, tpaObj);
                   tpaObj.Is_CPC_Post_Expiration_Notice_Sent__c = false;
                   tpaObj.CPC_Expiration_Postnotice_Sent_Last_Date__c = DateTime.now();
               }
        }

        //send TLLA Renewal Mails
        mapContactCCEmails = getTPAContactEmailList(idsToSendRenewalMail);
        for(Id objId: idsToSendRenewalMail) {
            TPA_Request__c tmpObj = mailRenewalListMap.get(objId);
            contactCCList = mapContactCCEmails.get(objId) != NULL ? mapContactCCEmails.get(objId): new List<String>();
            if(oldTPARequestMap != null && oldTPARequestMap.get(objId) != null) {
                contactToList.add(oldTPARequestMap.get(objId).ClientContact__r.Email);
                if(oldTPARequestMap.get(objId).Client_TPA_Representative_Email__c != null && oldTPARequestMap.get(objId).Client_TPA_Representative_Email__c != ''){
                    contactToList.add(oldTPARequestMap.get(objId).Client_TPA_Representative_Email__c);
                }
                if(oldTPARequestMap.get(objId).Owner.Type != null && oldTPARequestMap.get(objId).Owner.Type == 'Queue' && oldTPARequestMap.get(objId).Owner.Email != null){
                    contactToList.add(oldTPARequestMap.get(objId).Owner.Email);
                }
            }
            contactCCList.add(oldTPARequestMap.get(objId).Vendor_e_mail__c);
            for(string mailId: batchEmailAddresses) {
                contactCCList.add(mailId);
            }
            if(oldTPARequestMap.get(objId).tp_processor_email__c != null) {
                contactCCList.add(oldTPARequestMap.get(objId).tp_processor_email__c);
            }
            if(oldTPARequestMap.get(objId).Vendor_Compliance_Email__c != null) {
                contactCCList.add(oldTPARequestMap.get(objId).Vendor_Compliance_Email__c);
            }
            contactCCList = UTL_TPA_Multilingual.ccList(tmpObj.Client_Address__r.TPAOtherEmailIds__c, contactCCList);
            /*addTPProcessorInitials = true;
            if(oldTPARequestMap.get(objId).TPA_Assigned_TP_Processor__r.Is_Active__c) {
            	assignedTPProcessorName = oldTPARequestMap.get(objId).TPA_Assigned_TP_Processor__r.Initials__c;
            }*/
            sendTPANotifications(contactToList, contactCCList, 'Email Renewal Noti Client', tmpObj.client_language__c, objId, true, null, null, FALSE, FALSE, null);
            //addTPProcessorInitials = false;
        }

        //send TLLA Expiration Mails
        mapContactCCEmails = getTPAContactEmailList(idsToSendExpirationMail);
        for(Id objId: idsToSendExpirationMail) {
            TPA_Request__c tmpObj = mailExpirationListMap.get(objId);
            contactCCList = mapContactCCEmails.get(objId) != NULL ? mapContactCCEmails.get(objId): new List<String>();
            contactCCList.add(oldTPARequestMap.get(objId).ClientContact__r.Email);
            if(oldTPARequestMap.get(objId).Client_TPA_Representative_Email__c != null && oldTPARequestMap.get(objId).Client_TPA_Representative_Email__c != ''){
                contactCCList.add(oldTPARequestMap.get(objId).Client_TPA_Representative_Email__c);
            }
            if(oldTPARequestMap.get(objId).Owner.Type != null && oldTPARequestMap.get(objId).Owner.Type == 'Queue' && oldTPARequestMap.get(objId).Owner.Email != null){
                contactToList.add(oldTPARequestMap.get(objId).Owner.Email);
            }
            for(string mailId: batchEmailAddresses) {
                contactCCList.add(mailId);
            }
            if(oldTPARequestMap.get(objId).tp_processor_email__c != null) {
                contactCCList.add(oldTPARequestMap.get(objId).tp_processor_email__c);
            }
            if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
                contactCCList.add(UTL_TPA.sharedEmailAddress);
            }
            if(oldTPARequestMap.get(objId).Vendor_Compliance_Email__c != null) {
                contactCCList.add(oldTPARequestMap.get(objId).Vendor_Compliance_Email__c);
            }
            //this.setExpirationMailList(objId, new List<string>{tmpObj.Vendor_e_mail__c}, contactCCList, '', mailTemplateId);//Modified by C.P.Pandey under Issue-7287
            /*addTPProcessorInitials = true;
            if(oldTPARequestMap.get(objId).TPA_Assigned_TP_Processor__r.Is_Active__c) {
            	assignedTPProcessorName = oldTPARequestMap.get(objId).TPA_Assigned_TP_Processor__r.Initials__c;
            }*/
            sendTPANotifications(new List<string>{tmpObj.Vendor_e_mail__c}, contactCCList, 'Email Pending Expiration', tmpObj.vendor_language__c, objId, true, null, null, FALSE, FALSE, null);
            //addTPProcessorInitials = false;
        }

        //send TLLA Post Expiration Mails
        mapContactCCEmails = getTPAContactEmailList(idsToSendPostExpirationMail);
        for(Id objId: idsToSendPostExpirationMail) {
            TPA_Request__c tmpObj = mailPostExpirationListMap.get(objId);
            contactCCList = mapContactCCEmails.get(objId) != NULL ? mapContactCCEmails.get(objId): new List<String>();
            contactCCList.add(oldTPARequestMap.get(objId).ClientContact__r.Email);
            if(oldTPARequestMap.get(objId).Client_TPA_Representative_Email__c != null && oldTPARequestMap.get(objId).Client_TPA_Representative_Email__c != ''){
                contactCCList.add(oldTPARequestMap.get(objId).Client_TPA_Representative_Email__c);
            }
            if(oldTPARequestMap.get(objId).Owner.Type != null && oldTPARequestMap.get(objId).Owner.Type == 'Queue' && oldTPARequestMap.get(objId).Owner.Email != null){
                contactToList.add(oldTPARequestMap.get(objId).Owner.Email);
            }
            for(string mailId: batchEmailAddresses) {
                contactCCList.add(mailId);
            }
            if(oldTPARequestMap.get(objId).tp_processor_email__c != null) {
                contactCCList.add(oldTPARequestMap.get(objId).tp_processor_email__c);
            }
            if(oldTPARequestMap.get(objId).Vendor_Compliance_Email__c != null) {
                contactCCList.add(oldTPARequestMap.get(objId).Vendor_Compliance_Email__c);
            }

            //this.setExpirationMailList(objId, new List<string>{tmpObj.Vendor_e_mail__c}, contactCCList, '', mailTemplateId);//Modified by C.P.Pandey under Issue-7287
            /*addTPProcessorInitials = true;
            if(oldTPARequestMap.get(objId).TPA_Assigned_TP_Processor__r.Is_Active__c) {
            	assignedTPProcessorName = oldTPARequestMap.get(objId).TPA_Assigned_TP_Processor__r.Initials__c; 
            }*/
            sendTPANotifications(new List<string>{tmpObj.Vendor_e_mail__c}, contactCCList, 'Email Post Expiration', tmpObj.vendor_language__c, objId, true, null, null, FALSE, FALSE, null);
            //addTPProcessorInitials = false;
        }
    }
    
    public static void sendEmailThroughWorkflow(List<String> toAddresses, List<string> ccAddresses, String emailType, String templateId, Id emailWhatId, List<Attachment> lstAttachment, String subject, boolean isAttachmentRequired, string staticContent, boolean addTPProcessorInitials, boolean addGlobalTPProcessorInitials, TPA_Request__c tpaRequest) {
        if(!UTL_TPA.isSendOutgoingEmails) {
            system.debug('UTL_TPA.isSendOutgoingEmails:::'+UTL_TPA.isSendOutgoingEmails);
            return;
        }
        try {
            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        
            Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
            List<String> recipientAddresses = new List<String>();
            system.debug('templateId ::::'+templateId);
            system.debug('toAddresses:::' + toAddresses);
            system.debug('ccAddresses:::' + ccAddresses);
                
            if(toAddresses != null && toAddresses.size() > 0) {
                for(string strToEmail: toAddresses) {
                    if(!Test.isRunningTest() && (UTL_TPA_Multilingual.isValidEmailId(strToEmail) || UTL_TPA_Multilingual.isValidRecordId(strToEmail))) {
                        recipientAddresses.add(strToEmail);
                    }
                }
            }
            if(ccAddresses != null && ccAddresses.size() > 0) {
                for(string strCcEmail: ccAddresses) {
                    if(!Test.isRunningTest() && (UTL_TPA_Multilingual.isValidEmailId(strCcEmail) || UTL_TPA_Multilingual.isValidRecordId(strCcEmail))) {
                        recipientAddresses.add(strCcEmail);
                    }
                }
            }
            
            if(templateId != '' && templateId != null && (staticContent == '' || staticContent == null)) {
                try {                    
                    emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, emailWhatId);
                    if(Test.isRunningTest()) {
                        SRV_TPA_TPARequest.getCustomException();
                    }
                } catch(Exception exp) {
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::SRV_TPA_TPARequest:::sendEmailThroughWorkflow:::objWorkFlowEmail Insert Exception' + ':::emailType:::' +((emailType != null) ? emailType : ''), emailWhatId));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                    System.debug(emailType + ' Email Failed: ' + exp.getMessage());
                }
                //Database.rollback(sp);
                objWorkFlowEmail.content_1__c = addEmailFooter(emailNotToSend.getHTMLBody());
                objWorkFlowEmail.Email_Subject__c = (subject != null && subject.length() > 0) ? subject : emailNotToSend.getSubject();
                system.debug('objWorkFlowEmail0:::'+objWorkFlowEmail);
            }
            else {
                if(staticContent != null) {
                    staticContent = addEmailFooter(staticContent);
                    Integer content1FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.getMap().get('content_1__c').getDescribe().getLength();
                    Integer content2FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.getMap().get('content_2__c').getDescribe().getLength();
                    Integer content3FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.getMap().get('content_3__c').getDescribe().getLength();
                    Integer content4FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.getMap().get('content_4__c').getDescribe().getLength();
                    if(Test.isRunningTest()) {
                        content1FieldLength = content2FieldLength = content3FieldLength = content4FieldLength = 3;
                    }
                    System.debug('staticContent size = ' + staticContent.length());

                    if(staticContent.length() < content1FieldLength) {
                        objWorkFlowEmail.content_1__c = staticContent;
                    } else {
                        objWorkFlowEmail.content_1__c = staticContent.substring(0, content1FieldLength);

                        if(staticContent.length() < content1FieldLength + content2FieldLength) {
                            objWorkFlowEmail.content_2__c = staticContent.substring(content1FieldLength, staticContent.length());
                        } else {
                            objWorkFlowEmail.content_2__c = staticContent.substring(content1FieldLength, content1FieldLength + content2FieldLength);
                            if(staticContent.length() < content1FieldLength + content2FieldLength + content3FieldLength ) {
                                objWorkFlowEmail.content_3__c = staticContent.substring(content1FieldLength + content2FieldLength, staticContent.length());
                            } else {
                                objWorkFlowEmail.content_3__c = staticContent.substring(content1FieldLength + content2FieldLength, content1FieldLength + content2FieldLength  + content3FieldLength);
                                if(staticContent.length() < content1FieldLength + content2FieldLength + content3FieldLength + content4FieldLength ) {
                                    objWorkFlowEmail.content_4__c = staticContent.substring(content1FieldLength + content2FieldLength + content3FieldLength, staticContent.length());
                                } else {
                                    objWorkFlowEmail.content_4__c = staticContent.substring(content1FieldLength + content2FieldLength + content3FieldLength, content1FieldLength + content2FieldLength  + content3FieldLength  + content4FieldLength);
                                }
                            }
                        }
                    }
                }
               objWorkFlowEmail.Email_Subject__c = subject;
            //   system.debug('objWorkFlowEmail00:::'+objWorkFlowEmail);
            }
            
        if((addTPProcessorInitials || addGlobalTPProcessorInitials) && tpaRequest != null) {
            String assignedTPProcessorInitials = '';
            String globalTPProcessorInitials = '';
            if(addTPProcessorInitials && tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                assignedTPProcessorInitials = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
            }
            if(addGlobalTPProcessorInitials && tpaRequest.Co_Assigned_Global_TP_Processor__r.Is_Active__c ) {
                globalTPProcessorInitials = tpaRequest.Co_Assigned_Global_TP_Processor__r.Initials__c;
            }
            objWorkFlowEmail.Email_Subject__c = setEmailInitials(assignedTPProcessorInitials, globalTPProcessorInitials, objWorkFlowEmail.Email_Subject__c);
        }
            if(isAttachmentRequired) {
                string attDetails = '';
                for(Attachment objAtt: lstAttachment) {
                    attDetails += objAtt.Name+'~~'+objAtt.Id+';';
                }
                objWorkFlowEmail.Attachment_Details__c = attDetails;
            }
            system.debug('after att:::');
            objWorkFlowEmail.isAttachmentRequired__c = isAttachmentRequired;
            string strWhatId = emailWhatId;
            if(strWhatId != null && strWhatId != '') {
                objWorkFlowEmail.Related_To_Object_Id__c = emailWhatId;
                Id objId = emailWhatId;
                objWorkFlowEmail.Related_To_Object_Api__c = objId.getSObjectType().getDescribe().getName();
            }
            system.debug('after whatid');
            objWorkFlowEmail.Module_Name__c = 'TPA';
            if(emailType != null && (emailType ==  'Client Submission Renew' || emailType ==  'Email New and Edited Request')){
                objWorkFlowEmail.Email_Action__c = 'TPA_02_SendVendorSubmissionEmail';
        } else if(emailType == 'SendCountryOfferingReport') {
            objWorkFlowEmail.Attachment_Details__c = SCH_TPA_Agreement_UpdateStatus.offeringWBReportFltr;
            objWorkFlowEmail.Email_Action__c = 'TPA_03_SendCountryOfferingReport';
            } else if(emailType == 'SendComplianceHoldEmail') {
                objWorkFlowEmail.Email_Action__c = 'TPA_04_SendComplianceHoldRes';
            }
            else if(emailType == 'SendAMAFeeDeclinedEmail') {
                objWorkFlowEmail.Email_Action__c = 'TPA_05_AMA_Fee_Declined_Email';
            }else if(emailType == 'SendTPA500rMoreLicensesEmail') {
                objWorkFlowEmail.Email_Action__c = 'TPA_06_50orMore_Licenses_Email';
            }else if(emailType == 'ConfirmTempChangeOfCO'){
                objWorkFlowEmail.Email_Action__c = 'TPA_07_ConfirmTempChangeOfCO';
            }else if(emailType == 'ConfirmPermChangeOfCO'){
                objWorkFlowEmail.Email_Action__c = 'TPA_08_ConfirmPermChangeOfCO';
            }
            else {
                objWorkFlowEmail.Email_Action__c = 'TPA_01_SendEmail';
            }
            system.debug('after Module Name');
            Integer toEmailCounter = 1;
            Integer toUserCounter = 1;
            if(recipientAddresses != null && recipientAddresses.size() > 0) {
                for(string strToEmail: recipientAddresses) {
                    if(UTL_TPA_Multilingual.isValidEmailId(strToEmail)) {
                        objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', strToEmail);
                        toEmailCounter++;
                    }
                    else if(UTL_TPA_Multilingual.isValidRecordId(strToEmail)) {
                        objWorkFlowEmail.put('To_User_'+toUserCounter+'__c', strToEmail);
                        toUserCounter++;
                    }
                }
            }
            system.debug('after toaddress');
            if(Test.isRunningTest()) {
                objWorkFlowEmail.content_1__c = 'TEST Content';
                objWorkFlowEmail.Email_Subject__c = 'TEST Subject';
            }
          //  system.debug('objWorkFlowEmail:::'+objWorkFlowEmail);
            insert objWorkFlowEmail;            
            if(Test.isRunningTest()) {
                SRV_TPA_TPARequest.getCustomException();
            }
        }
        catch(Exception ex) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SRV_TPA_TPARequest:::sendEmailThroughWorkflow:::objWorkFlowEmail Insert Exception' + ':::emailType:::' +((emailType != null) ? emailType : '') , emailWhatId));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            system.debug('workFlowException:::'+ex.getMessage());
        }
    }

    

    

    public static Messaging.SingleEmailMessage getTPANotificationEmailDraft(List<String> toAddresses, List<string> ccAddresses, String emailType, String language, Id emailWhatId, Boolean saveAsActivity, List<Attachment> lstAttachment, String subject, boolean addTPProcessorInitials, boolean addGlobalTPProcessorInitials, TPA_Request__c tpaRequest) {
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();

        System.debug('UTL_TPA.emailTargetContactId:'+UTL_TPA.emailTargetContactId);
       

        String emailLanguage = (language == null || language == '') ? 'English' : language;
        System.debug('emailLanguage:'+emailLanguage);
        Id emailTempId = UTL_TPA_Multilingual.getEmailTemplateId(emailType, emailLanguage);
        System.debug('emailTempId:'+emailTempId);
      
        try {
            emailNotToSend = Messaging.renderStoredEmailTemplate(emailTempId, NULL, emailWhatId);
        } catch(Exception exp) {
            System.debug(emailType + ' Email Failed: ' + exp.getMessage());
        }

        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();

        emailToSend.setCharset('UTF-8');
        if(toAddresses != null && toAddresses.size() > 0) {
            emailToSend.setToAddresses(toAddresses);
        }
        emailToSend.setPlainTextBody(emailNotToSend.getPlainTextBody());
        emailToSend.setHTMLBody(addEmailFooter(emailNotToSend.getHTMLBody()));
        if(subject != null && subject.length() > 0) {
            emailToSend.setSubject(subject);
        } else {
            emailToSend.setSubject(emailNotToSend.getSubject());
        }
        if((addTPProcessorInitials || addGlobalTPProcessorInitials) && tpaRequest != null) {
            String assignedTPProcessorInitials = '';
            String globalTPProcessorInitials = '';
            if(addTPProcessorInitials && tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                assignedTPProcessorInitials = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
            }
            if(addGlobalTPProcessorInitials && tpaRequest.Co_Assigned_Global_TP_Processor__r.Is_Active__c ) {
                globalTPProcessorInitials = tpaRequest.Co_Assigned_Global_TP_Processor__r.Initials__c;
            }
            emailToSend.setSubject(setEmailInitials(assignedTPProcessorInitials, globalTPProcessorInitials, emailToSend.getSubject()));
        }
        if(UTL_TPA.orgWideEmailAddress != null) {
            emailToSend.setOrgWideEmailAddressId(UTL_TPA.orgWideEmailAddress);
        }
        emailToSend.setWhatId(emailWhatId);
        emailToSend.setSaveAsActivity(saveAsActivity);
        emailToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
        emailToSend.setTreatTargetObjectAsRecipient(false);

        if(ccAddresses != null) {
            emailToSend.setCcAddresses(ccAddresses);
        }

        if(lstAttachment != null && lstAttachment.size() > 0) {
            List<Messaging.Emailfileattachment> emailAttach = new List<Messaging.Emailfileattachment>();
            Attachment a = lstAttachment[0];
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(a.Name);
            efa.setBody(a.Body);
            emailAttach.add(efa);
            emailToSend.setFileAttachments(emailAttach);
        }

        if(emailType != null && emailType ==  'VSN TP Processor Notification') {
            emailToSend.setUseSignature(false); 
        }

        return emailToSend;
    }
    
    public static void updateAgreementFieldsForClient(TPA_Request__c tpaReq) {
        tpaRequest = tpaReq;
        if( tpaRequest.Request_Type__c != 'New') {
            tpaRequest.agreement_effective_date__c = null;
        }
        tpaRequest.isTpProcessor__c = CNT_TPA_RequestSubmissionForm.isTPProcessor;
        tpaRequest.isUSTPProcessor__c = CNT_TPA_RequestSubmissionForm.isUSTPProcessor;
        tpaRequest.Is_Submitted__c = true;
        tpaRequest.Is_Client_Submitted_Request__c = true;

        if(tpaRequest.Data_Access_Start_Date__c != null) {
            tpaRequest.Original_Start_Date__c = tpaRequest.Data_Access_Start_Date__c;
        }
        if(tpaRequest.Data_Access_End_Date__c != null) {
            tpaRequest.Expiration_Date__c = tpaRequest.Data_Access_End_Date__c;
        }
        //tpaRequest.IsSubContractorAdded__c = isSubContractAdded;
        if( tpaRequest.Vendor_e_mail__c != null) {
            tpaRequest.Vendor_Contact_e_mail__c = tpaRequest.Vendor_e_mail__c;
        }
        if( tpaRequest.Vendor_First_Name__c != null && tpaRequest.Vendor_Contact_Last_Name__c != null) {
            tpaRequest.Vendor_Contact_Name_f__c = tpaRequest.Vendor_First_Name__c+' '+tpaRequest.Vendor_Contact_Last_Name__c;
        }

        // User currentUser = UTL_TPA.getCurrentUserDetails();
        // String profileName = '';
        // if(currentUser != null) {
        //     profileName = currentUser.Profile.Name;

        //     if(profileName.indexOf('TPA Processor Profile') != -1) {
        //         tpaRequest.isTpProcessor__c = true;
        //         tpaRequest.isUSTPProcessor__c = false;
        //     } else if(profileName.indexOf('US TP Processor Profile') != -1) {
        //         tpaRequest.isUSTPProcessor__c = true;
        //         tpaRequest.isTpProcessor__c = false;
        //     } else {
        //         tpaRequest.isTpProcessor__c = false;
        //         tpaRequest.isUSTPProcessor__c = false;
        //     }
        // }
        //setDefaults(tpaRequest);  
        
        //updateAgreementFields();
        
        //TPA_Request_Localized__c objLocalized =  clientVendorUpdates(CLIENT_CON, null, null);// TODO: Pending review from my side, will review, this function will call only for vendor
        //updateAgreementFieldsForPurpose();//will review and update according to clientVendorUpdates
        
        //system.debug('In SRV_TPA_TPARequest : tpaRequest.Secondary_Data_Asset_List__c = ' + tpaRequest.Secondary_Data_Asset_List__c);
        //setAgreementFieldsForDataAsset// TODO: Will check this flag after submission, setting from data asset trigger helper also
        //updateAgreementFieldsForDataAsset();// TODO: Will check this flag after submission, setting from data asset trigger helper also

        
        //system.debug('MlegalEntityToAdditionalTermsMap: ' + MlegalEntityToAdditionalTermsMap);
        
        updateAgreementChildRecordsForClient();
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();        
        try {
            upsert tpaRequest; //TODO: Review pending from my side will review 
        } catch(Exception ex) {
            system.debug('ErrorCpc:'+ex.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SRV_TPA_TPARequest:::updateAgreementFieldsForClient', tpaRequest != null ? tpaRequest.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
        
    }

    public static void updateAgreementChildRecordsForClient() { 
        system.debug('Inside updateAgreementChildRecordsForClient');
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();

        
        Set<Id> stEntityId = new Set<Id>();
        Set<Id> stPurposeId = new Set<Id>();
        List<IMS_Legal_Entity__c> lstEntityUpdated = new List<IMS_Legal_Entity__c>();
        List<TPA_Purpose__c> lstPurposeUpdated = new List<TPA_Purpose__c>();  

        //List<TPA_Purpose__c> tpaPurposes = getPurposeAndDescriptionList(tpaRequest.Id);

        Set<Id> purposeIds = new Set<Id>();
        for(TPA_Purpose__c tpaPurposeSO : getPurposesListForClientSubmission(tpaRequest.Id)) {
            purposeIds.add( tpaPurposeSO.Id );
        }

        Map<String, IMS_Legal_Entity__c> mapEntityNameWithObj = new Map<String, IMS_Legal_Entity__c>();
        for(IMS_Legal_Entity__c objEntity : [Select Id, Legal_Entity_Name_for_TLLA__c,Name, IMS_Master_Legal_Entity__c,IMS_Master_Legal_Entity__r.Name from IMS_Legal_Entity__C where TPA_Request__c = :tpaRequest.Id]) {
            mapEntityNameWithObj.put(objEntity.Legal_Entity_Name_for_TLLA__c, objEntity);
        }

        Boolean isRenewCase = false;
        if(MlegalEntityToAdditionalTermsMap.size() > 0) {
            List<TPA_Additional_Term__c> additionalTermToUpdateList = new List<TPA_Additional_Term__c>();
            List<TPA_Additional_Term__c> additionalTermsToDelete = new List<TPA_Additional_Term__c>();
            for(IMS_Legal_Entity__c legalEntity : mapEntityNameWithObj.values()) {
                List<TPA_Additional_Term__c> oldAdditionalTerms = MlegalEntityToAdditionalTermsMap.get(legalEntity.IMS_Master_Legal_Entity__c);
                if(oldAdditionalTerms != null && oldAdditionalTerms.size() > 0) {
                    for(TPA_Additional_Term__c oldAdditionalTerm : oldAdditionalTerms) {
                        if(oldAdditionalTerm.TPA_Request__c != tpaRequest.Id && !isRenewCase){
                            isRenewCase = true;
                        }
                        Boolean retainAdditionalTerm = false;
                        
                        if(oldAdditionalTerm.Category__c == 'Data Asset Specific Ad-Hoc Term' || oldAdditionalTerm.Category__c == 'Use Specific Ad-Hoc Terms' || oldAdditionalTerm.Category__c == 'Use/Offering Specific Ad-Hoc Terms') {
                            
                            for(TPA_Data_Asset__c tpaDataAssetSO : getOfferingsListForClientSubmission(purposeIds)) {
                                if(oldAdditionalTerm.Category__c == 'Use Specific Ad-Hoc Terms' && oldAdditionalTerm.Use_Name__c != null && oldAdditionalTerm.Use_Name__c == tpaDataAssetSO.A_Column_Use_For_Template__c && legalEntity.Name != null && oldAdditionalTerm.TPA_Legal_Entity_1__r.Name != null && legalEntity.Name == oldAdditionalTerm.TPA_Legal_Entity_1__r.Name){
                                    oldAdditionalTerm.TPA_Legal_Entity_1__c = legalEntity.Id;
                                    additionalTermToUpdateList.add(oldAdditionalTerm);
                                    retainAdditionalTerm = true;
                                    break;
                                }
                                else if(oldAdditionalTerm.Category__c == 'Use/Offering Specific Ad-Hoc Terms' && oldAdditionalTerm.Use_Name__c != null && oldAdditionalTerm.Use_Name__c == tpaDataAssetSO.A_Column_Use_For_Template__c && oldAdditionalTerm.Country_of_Offering__c != null && oldAdditionalTerm.Country_of_Offering__c == tpaDataAssetSO.BU__c){
                                    if(tpaDataAssetSO.TPA_Secondary_Data_Assets__r.size() > 0) {
                                        for(TPA_Secondary_Data_Asset__c tpaSecDataAsset : tpaDataAssetSO.TPA_Secondary_Data_Assets__r) {
                                            if(oldAdditionalTerm.Secondary_Offering_Name__c == tpaSecDataAsset.Secondary_Asset_Name__c) {
                                                oldAdditionalTerm.TPA_Legal_Entity_1__c = legalEntity.Id;
                                                additionalTermToUpdateList.add(oldAdditionalTerm);
                                                retainAdditionalTerm = true;
                                                break;
                                            } 
                                        }
                                    } 
                                    else if(oldAdditionalTerm.Primary_Offering_Name__c == tpaDataAssetSO.Asset_Name__c) {
                                        oldAdditionalTerm.TPA_Legal_Entity_1__c = legalEntity.Id;
                                        additionalTermToUpdateList.add(oldAdditionalTerm);
                                        retainAdditionalTerm = true;
                                        break;
                                    }
                                }
                                else if(oldAdditionalTerm.Category__c == 'Data Asset Specific Ad-Hoc Term' && oldAdditionalTerm.Country_of_Offering__c != null && oldAdditionalTerm.Country_of_Offering__c == tpaDataAssetSO.BU__c){
                                    if(tpaDataAssetSO.TPA_Secondary_Data_Assets__r.size() > 0) {
                                        for(TPA_Secondary_Data_Asset__c tpaSecDataAsset : tpaDataAssetSO.TPA_Secondary_Data_Assets__r) {
                                            if(oldAdditionalTerm.Secondary_Offering_Name__c == tpaSecDataAsset.Secondary_Asset_Name__c) {
                                                oldAdditionalTerm.TPA_Legal_Entity_1__c = legalEntity.Id;
                                                additionalTermToUpdateList.add(oldAdditionalTerm);
                                                retainAdditionalTerm = true;
                                                break;
                                            } 
                                        }
                                    } 
                                    else if(oldAdditionalTerm.Primary_Offering_Name__c == tpaDataAssetSO.Asset_Name__c) {
                                        oldAdditionalTerm.TPA_Legal_Entity_1__c = legalEntity.Id;
                                        additionalTermToUpdateList.add(oldAdditionalTerm);
                                        retainAdditionalTerm = true;
                                        break;
                                    }
                                }
                                if(retainAdditionalTerm) {
                                    break;
                                }
                            }
                        } else if (oldAdditionalTerm.Category__c == 'General Ad-Hoc Term') {
                            oldAdditionalTerm.TPA_Legal_Entity_1__c = legalEntity.Id;
                            additionalTermToUpdateList.add(oldAdditionalTerm);
                            retainAdditionalTerm = true;
                        }
                        
                        if(!retainAdditionalTerm) {
                            additionalTermsToDelete.add(oldAdditionalTerm);
                        }
                    }
                    MlegalEntityToAdditionalTermsMap.remove(legalEntity.IMS_Master_Legal_Entity__c);
                } 
            }
            
            for(Id legalEntityId : MlegalEntityToAdditionalTermsMap.keySet()) {
                additionalTermsToDelete.addAll(MlegalEntityToAdditionalTermsMap.get(legalEntityId));
            }

            if(additionalTermsToDelete.size() > 0 && !isRenewCase) {
                delete additionalTermsToDelete;
            }
            if(additionalTermToUpdateList.size() > 0 && !isRenewCase) {
                UTL_TPA.updateFromPage = true;
                update additionalTermToUpdateList;
                UTL_TPA.updateFromPage = false;
            }
            if(additionalTermsToDelete.size() > 0 && isRenewCase){
                CNT_TPA_RequestSubmissionForm.termsNotToRetain = (new Map<Id,SObject>(additionalTermsToDelete)).keySet().clone();
            }
        }

        Set<String> setPromoOffering = new Set<String>(Label.Promotrack_Offerings.split(';'));        
        String globalPTOffering = Label.TPA_Global_Promotrak_Offerings;
        Set<String> setDDDOffering = new Set<String>(Label.TPA_DDD_Offering.split(';'));
        tpaRequest.Countries_of_offerings__c = '';
        tpaRequest.Category_of_Offerings__c = '';
      
        for(TPA_Data_Asset__c tpaPurposeDataAssetSO : getOfferingsListForClientSubmission(purposeIds)) {
           Id entityId = null;
           IMS_Legal_Entity__c objEntity  = null;

            if(tpaRequest.Countries_of_offerings__c.indexOf(tpaPurposeDataAssetSO.BU__c) == -1){
                tpaRequest.Countries_of_offerings__c += tpaPurposeDataAssetSO.BU__c + ',';
            }
            if(tpaRequest.Category_of_Offerings__c.indexOf(tpaPurposeDataAssetSO.Geo_Level__c) == -1){
                tpaRequest.Category_of_Offerings__c += tpaPurposeDataAssetSO.Geo_Level__c + ',';
            }
            if(tpaPurposeDataAssetSO.Asset_NametText__c != 'Other') {
                if(objEntity == null) {
                    objEntity = mapEntityNameWithObj.get(tpaPurposeDataAssetSO.Data_Asset__r.IMS_Legal_Entity__c);
                    if(objEntity == null) {
                        objEntity = mapEntityNameWithObj.get(Label.Legal_Entity_Common);
                    }
                    if(objEntity == null && tpaPurposeDataAssetSO.TPA_Secondary_Data_Assets__r.size() > 0) {
                        TPA_Secondary_Data_Asset__c objTemp = tpaPurposeDataAssetSO.TPA_Secondary_Data_Assets__r[0];
                        objEntity = mapEntityNameWithObj.get(objTemp.IMS_Secondary_Data_Asset__r.IMS_Legal_Entity__c);
                    }
                }
              
                if(objEntity != null) {
                    entityId = objEntity.id;
                }



                if(tpaPurposeDataAssetSO.Asset_Name__c == 'MIDAS') {
                    objEntity.is_Midas__c = true;
                } 
                else if(tpaPurposeDataAssetSO.Asset_Name__c == 'Patient Reference File') {
                    objEntity.is_Patient_Reference_File__c = true;
                } 
                else if(tpaPurposeDataAssetSO.Asset_Name__c == 'GE Centricity EMR') {
                    system.debug('yes in GE Centricity EMR');
                    objEntity.is_GE_Centricity_EMR__c = true;
                } 
                else if(setPromoOffering.contains( tpaPurposeDataAssetSO.Asset_Name__c ) ) {
                    objEntity.is_Promotrak__c = true;
                } 
                else if((tpaPurposeDataAssetSO.Asset_Name__c == 'Managed Care Workbook - New View' || tpaPurposeDataAssetSO.Asset_Name__c == 'Managed Care Workbook - PBM Plans' ) && tpaPurposeDataAssetSO.BU__c == 'United States') {
                    objEntity.is_Managed_Workbook__c = true;
                } 
                else if(globalPTOffering.equalsIgnoreCase( tpaPurposeDataAssetSO.Asset_Name__c)  && tpaPurposeDataAssetSO.BU__c == 'Global') {
                    objEntity.Is_Glbl_PromoTrack_Selected__c = true;
                } 
                else if(tpaPurposeDataAssetSO.BU__c == 'South Africa' && tpaPurposeDataAssetSO.Asset_Name__c == 'IQVIA Consumer Aisle') {
                    objEntity.is_South_Africa_Consumer_Health__c = true;
                }
                else if(tpaPurposeDataAssetSO.BU__c == 'United States' && tpaPurposeDataAssetSO.Asset_Name__c == 'PharMetrics® Plus (Health Plan Claims)') {
                    objEntity.IS_Health_Plan_Claims__c= true;
                } 
                else if(tpaPurposeDataAssetSO.BU__c == 'United States' && tpaPurposeDataAssetSO.Asset_Name__c == 'Patient Companion File (PatCo) - Formerly Patient Reference File') {
                    objEntity.is_Patient_Companion_File__c = true;
                }
                else if(tpaPurposeDataAssetSO.BU__c == 'United States' && tpaPurposeDataAssetSO.Asset_Name__c.indexOf('Provider Companion File') != -1 ) {
                    objEntity.is_Provider_Companion_File__c = true;
                }
                else if(tpaPurposeDataAssetSO.BU__c == 'United States' && tpaPurposeDataAssetSO.Asset_Name__c.indexOf('Payer Companion File') != -1) {
                    objEntity.is_Payer_Companion_File__c = true;
                }
                else if(tpaPurposeDataAssetSO.Asset_Name__c == 'LAAD - Longitudinal Access and Adjudication Data') {
                    objEntity.is_LAAD_Offering__c = true;
                }
                else if(tpaPurposeDataAssetSO.BU__c == 'United States' && tpaPurposeDataAssetSO.Asset_Name__c == 'Oncology electronic medical records data') {
                    objEntity.Is_Oncology_EMR__c = true;
                }
                else if(tpaPurposeDataAssetSO.BU__c == 'United States' && tpaPurposeDataAssetSO.Asset_Name__c == 'Ambulatory electronic medical records data') {
                    objEntity.Is_Ambulatory_EMR__c= true;
                } 
                else if((tpaPurposeDataAssetSO.Asset_Name__c == 'Xponent' || tpaPurposeDataAssetSO.Asset_Name__c == 'OneKey Emails' || tpaPurposeDataAssetSO.Asset_Name__c == 'OneKey Organizations (formerly HCOS)' || tpaPurposeDataAssetSO.Asset_Name__c == 'OneKey Professionals (formerly HCPS)' || tpaPurposeDataAssetSO.Asset_Name__c == 'OneKey Select') && tpaPurposeDataAssetSO.BU__c == 'United States') {
                    objEntity.is_Xponent_or_OneKey__c = true;
                } 
                else if((tpaPurposeDataAssetSO.Asset_Name__c == 'Xponent' || tpaPurposeDataAssetSO.Asset_Name__c == 'OneKey - Facilities' || tpaPurposeDataAssetSO.Asset_Name__c == 'OneKey - Professionals') && tpaPurposeDataAssetSO.BU__c == 'Canada') {
                    objEntity.is_Xponent_or_OneKey__c = true;
                }
                else if( tpaPurposeDataAssetSO.Asset_Name__c.indexOf('Medpages Data') != -1 ){
                    objEntity.Is_MedPages_Data__c = true;
                }
                else if(tpaPurposeDataAssetSO.Asset_Name__c == 'Analytics Link – Client Extract Only – No 3rd Party tool access included' && tpaPurposeDataAssetSO.BU__c == 'Global') {
                    objEntity.is_Analytics_Link__c = true;
                }
                

              
                if(tpaPurposeDataAssetSO.BU__c == 'Canada' && tpaPurposeDataAssetSO.additional_terms_required__c) {
                    objEntity.is_Canada__c = true;
                } 
                
                if(tpaPurposeDataAssetSO.BU__c == 'United States') {
                    objEntity.containUS__c = true;
                } 
                              
                if(tpaPurposeDataAssetSO.TPA_Secondary_Data_Assets__r.size() > 0) {
                    for(TPA_Secondary_Data_Asset__c secondaryDataAsset : tpaPurposeDataAssetSO.TPA_Secondary_Data_Assets__r) {
                        if(setPromoOffering.contains( secondaryDataAsset.Secondary_Asset_Name__c) ) {
                            objEntity.is_Promotrak__c = true;
                        } 
                        else if(setDDDOffering.contains( secondaryDataAsset.Secondary_Asset_Name__c) ) {
                            objEntity.isDDDOffering__c = true;
                        } 
                        else if(secondaryDataAsset.Secondary_Asset_Name__c == 'Xponent PlanTrak' && secondaryDataAsset.BU__c == 'United States') {
                            objEntity.is_Xponent__c = true ;
                        } 
                        else if( secondaryDataAsset.Secondary_Asset_Name__c == 'AIM XR Web Search/Social Insights' ){
                            objEntity.is_AIM_XR__c = true;
                        }
                        
                        if(secondaryDataAsset.BU__c == 'Canada' && secondaryDataAsset.additional_terms_required__c) {
                            objEntity.is_Canada__c = true;
                        } 
                    }
                }                 
            }
          
            if(objEntity != null) {
                if(!stEntityId.contains(objEntity.id)) {
                    stEntityId.add(objEntity.id);
                    lstEntityUpdated.add(objEntity);
                }
            }
            if(objEntity != null && !stPurposeId.contains(tpaPurposeDataAssetSO.Purpose__r.Id)) {
                stPurposeId.add(tpaPurposeDataAssetSO.Purpose__r.Id);
                lstPurposeUpdated.add(new TPA_Purpose__c(id = tpaPurposeDataAssetSO.Purpose__r.Id, IMS_Legal_Entity__c = entityId));
            }
        }
        
        tpaRequest.Countries_of_offerings__c = tpaRequest.Countries_of_offerings__c.substringBeforeLast(',');
        tpaRequest.Category_of_Offerings__c = tpaRequest.Category_of_Offerings__c.substringBeforeLast(',');

        System.debug('countries ::'+tpaRequest.Countries_of_offerings__c);
        if(lstPurposeUpdated.size() > 0) {
            if(lstEntityUpdated.size() > 0) {
                upsert lstEntityUpdated; //TODO:exception logs here
            }

            update lstPurposeUpdated; //TODO:exception logs here
        }
        CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
    }

    public static void createActivityHistoryForClient() {
        requestNumber = ( tpaRequest.Request_Type__c == 'New' ? tpaRequest.Name : tpaRequest.Parent_Request__r.Name );
        type = Test.isRunningTest() ? type : tpaRequest.Request_Type__c;         

        if( (requestNumber != null && requestNumber != '' && tpaRequest.LastAction__c == 'Request Submitted By Client' ) || Test.IsRunningTest() ) {
            if( type == 'renew' ) {
                SRV_TPA_TPARequest.updateActivityHistory( tpaRequest.Id, 'TPA Request '+requestNumber+' is Renewed.', false);
                if(tpaRequest.Parent_Request__c != null) {
                    List<TPA_Request__c> tpaRequestList = [select id, name, Is_Renewed__c, Renewed_As__c, Renewed_On__c, Renewed_Type__c from TPA_Request__c where id =: tpaRequest.Parent_Request__c];

                    if(tpaRequestList != null && tpaRequestList.size() > 0) {
                        parentRequest = tpaRequestList[0];
                    }
                }
                if(parentRequest != null) {
                    parentRequest.Is_Renewed__c = true;
                    parentRequest.Renewed_As__c = tpaRequest.Id;
                    parentRequest.Renewed_On__c = system.now();
                    
                    if(isRenewedReqUseandOfferingChanged != null && isRenewedReqUseandOfferingChanged == 'Modified Renewal'){
                        parentRequest.Renewed_Type__c = 'Modified Renewal';
                    }
                    if(isRenewedReqUseandOfferingChanged != null && isRenewedReqUseandOfferingChanged == 'Renewed'){
                        parentRequest.Renewed_Type__c = 'Renewed';
                    }
                    UTL_TPA.modifyRequestForcefully = true;
                    update parentRequest;// TODO: Will review 
                    UTL_TPA.modifyRequestForcefully = false;
                }
            }
            else if( type == 'clone' ) {
                SRV_TPA_TPARequest.updateActivityHistory( tpaRequest.Id,'TPA Request '+requestNumber+' is Cloned.', false);
            }
            else if( type == 'New' ) {
                SRV_TPA_TPARequest.updateActivityHistory( tpaRequest.Id,'TPA Request '+requestNumber+' is Submitted.', false);
            }
            SRV_TPA_TPARequest.updateActivityHistory( tpaRequest.Id, 'Email Notification Send to Vendor', true);
        }
    }

    public static void updateActivityHistory(Id parId, String taskSubject, boolean isInsertTask ) {
        if(UTL_TPA.createActivityHistory) {
            if(tasksToInsert == null) {
                tasksToInsert = new List<Task>();
            }
            
            Task task = new Task();
            task.WhatId = parId;
            task.ActivityDate = system.today();
            task.Status = 'Completed';
            task.Subject = taskSubject;
            tasksToInsert.add( task );
    
            if( taskSubject.equalsIgnoreCase(Label.TPA_In_Review_By_IQVIA_Status) && UTL_TPA.createVendorSelectedActivityHistory ) {
                Task t2 = new Task( WhatId = parId, ActivityDate = system.today(), Status = 'Completed',
                                    Subject = 'Vendor Legal Name Selected' );
                tasksToInsert.add( t2 );
            }
            
            if( tasksToInsert.size() > 0 && isInsertTask) {
                Datetime d = Datetime.now();
                Time t1 = d.time();
                Time t2 = t1.addSeconds(2);
                while( t2 > t1 ) {
                    t1 = Datetime.now().time();
                }
                try {
                    insert tasksToInsert;
                    tasksToInsert = new List<Task>();
                }
                catch(Exception ex) {
                    system.debug(ex.getMessage());
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SRV_TPA_TPARequest:::updateActivityHistory:::'+taskSubject, parId != null ? parId : ''));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                }
            }
        }
    }

    public static void updateActivityHistoryForBulk(Set<Id> parIds, String taskSubject, boolean isInsertTask ) {
        if(UTL_TPA.createActivityHistory) {
            if(tasksToInsert == null) {
                tasksToInsert = new List<Task>();
            }
            
            for(Id requestId : parIds){
                Task task = new Task();
                task.WhatId = requestId;
                task.ActivityDate = system.today();
                task.Status = 'Completed';
                task.Subject = taskSubject;
                tasksToInsert.add( task );
        
                if( taskSubject.equalsIgnoreCase(Label.TPA_In_Review_By_IQVIA_Status) && UTL_TPA.createVendorSelectedActivityHistory ) {
                    Task t2 = new Task( WhatId = requestId, ActivityDate = system.today(), Status = 'Completed',
                                        Subject = 'Vendor Legal Name Selected' );
                    tasksToInsert.add( t2 );
                }
            }
            
            if( tasksToInsert.size() > 0 && isInsertTask) {
                Datetime d = Datetime.now();
                Time t1 = d.time();
                Time t2 = t1.addSeconds(2);
                while( t2 > t1 ) {
                    t1 = Datetime.now().time();
                }
                try {
                    insert tasksToInsert;
                    tasksToInsert = new List<Task>();
                }
                catch(Exception ex) {
                    system.debug(ex.getMessage());
                }
            }
        }
    }

    public static TPA_Request__c updateAgreementFieldsForVendor(Boolean isdynamicOffNoticationReqOrNot) {
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();
        
        if(tpaRequest.Is_Submitted__c) {
            //setDefaults(tpaRequest);

            //List<TPA_Purpose__c>lstPurposeList = new List<TPA_Purpose__c>();
            //getGlobalBrandingVendorId(tpaRequest);//will review and remove

            Boolean isAwaitingClientConfirmationMailReq = CNT_TPA_RequestSubmissionForm.isAwaitingClientConfirmationMailReq;
           
            //system.debug('isAwaitingClientConfirmationMailReq: ' + isAwaitingClientConfirmationMailReq);

            //updateAgreementFields();
            
          //  clientVendorUpdates('Vendor', null, null); //will review, have changes inside

            vendorUseDefinationUpdates();
            Set<String> specVendorOffList = new Set<String>();
            Boolean isRepwise = false;
            Boolean isVeeva = false;
            Boolean isDLIMI = false;
            //Boolean isDeepIntent = false;
            Boolean isSourceOrSymphonyVendor = false;
            Boolean isMedPro = false;
            Boolean isEdith = false;
            Boolean isSpecificTPVendor = false;
            if(tpaRequest.Service_Provider_Address__c != null && tpaRequest.Service_Provider_Address__r.Name != null && tpaRequest.Service_Provider_Address__r.Name != '') {
                if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('veeva') != -1 ) {
                    string []strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('veeva');
                    if(strMap != null) {
                        if(strMap.size() == 0  ) {
                            isVeeva = true;
                        }
                        else if(strMap.size() == 1) {
                            if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                                isVeeva = true;
                            }
                        }
                        else {
                            if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                                isVeeva = true;
                            }
                        }
                    }
                }
                
                if( (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('source') != -1) || (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('symphony') != -1)) {
                     string []strMap;
                     if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('source')){
                         strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('source');
                     }else if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('symphony')){
                         strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('symphony');
                     }
                     
                    if(strMap != null) {
                        if(strMap.size() == 0  ) {
                            isSourceOrSymphonyVendor = true;
                        }
                        else if(strMap.size() == 1) {
                            if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                                isSourceOrSymphonyVendor = true;
                            }
                        }
                        else {
                            if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                                isSourceOrSymphonyVendor = true;
                            }
                        }
                    }
                }
                 if( (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('dlimi') != -1) || (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('dli') != -1) || (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('signum') != -1)) {
                     string []strMap;
                     if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('dlimi')){
                         strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('dlimi');
                     }else if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('dli')){
                         strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('dli');
                     }else if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('signum')){
                         strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('signum');
                     }
                     
                    if(strMap != null) {
                        if(strMap.size() == 0  ) {
                            isDLIMI = true;
                        }
                        else if(strMap.size() == 1) {
                            if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                                isDLIMI = true;
                            }
                        }
                        else {
                            if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                                isDLIMI = true;
                            }
                        }
                    }
                }
                /*if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('deepintent') != -1 ) {
                    isDeepIntent = true;
                }*/
                if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('edith') != -1 ) {
                    isEdith = true;
                }
                if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('repwise') != -1 ) {
                    string []strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('repwise');
                    if(strMap != null) {
                        if(strMap.size() == 0  ) {
                            isRepwise = true;
                        }
                        else if(strMap.size() == 1) {
                            if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                                isRepwise = true;
                            }
                        }
                        else {
                            if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                                isRepwise = true;
                            }
                        }
                    }
                }
                if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('medpro') != -1 ) {
                    string []strMap1 = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('medpro');
                    if(strMap1 != null) {
                        if(strMap1.size() == 0  ) {
                            isMedPro = true;
                        }
                        else if(strMap1.size() == 1) {
                            if(strMap1[0] == '' || !strMap1[0].substring(strMap1[0].length()-1,strMap1[0].length()).isAlphanumeric()) {
                                isMedPro = true;
                            }
                        }
                        else {
                            if((strMap1[1] == '' || !strMap1[1].substring(0,1).isAlphanumeric()) && (strMap1[0] == '' || !strMap1[0].substring(strMap1[0].length()-1,strMap1[0].length()).isAlphanumeric()) ) {
                                isMedPro = true;
                            }
                        }
                    }
                }
                
                
                for(string vendorName : Label.TPA_Specific_Third_Party_Vendors.toLowerCase().split(';')) {
                    if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf(vendorName) != -1 ) {
                        string []strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split(vendorName);
                        if(strMap != null) {
                            if(strMap.size() == 0  ) {
                                isSpecificTPVendor = true;
                            }
                            else if(strMap.size() == 1) {
                                if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                                    isSpecificTPVendor = true;
                                }
                            }
                            else {
                                if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                                    isSpecificTPVendor = true;
                                }
                            }                            
                        }
                    }
                }
            }

            if(isVeeva || isSourceOrSymphonyVendor || isMedPro || isSouthAfrica || isEdith || isSpecificTPVendor || isDLIMI) {
                /*if(isVeeva){
                    tpaRequest.Is_Vendor_Veeva_for_all_Use__c = true;
                }*/
                if(isVeeva && isContainUSEforVeeva) {
                    tpaRequest.Is_Vendor_Name_Contains_Veeva__c = true;
                }
                if(isVeeva && isUseCRM && isOffOneKey) {
                    tpaRequest.Is_Veeva_Use_CRM_Off_OneKey__c = true;
                }
                /* if(isVeeva && isUseCRM ) {
                    tpaRequest.is_Veeva_Use_CRM__c = true;
                } */
                if(isSourceOrSymphonyVendor) {
                    tpaRequest.Is_Vendor_Related_to_Source_Symphony_Acc__c = true;
                }
                if(isSouthAfrica && isSubnationalOff) {
                    tpaRequest.Is_South_Africa_Sub_Off__c = true;
                }
                if((isVeeva || isRepwise) && isUseCRM && isSouthAfrica && isSubnationalOff) {
                    tpaRequest.Is_South_Africa_Sub_Off__c = false;
                    tpaRequest.Is_Veeva_Use_CRM_SubNational_Off__c = true;
                }
                if(isMedPro) {
                    tpaRequest.Is_Vendor_Name_Contains_MedPro__c = true;
                }
                /*if(isDeepIntent) {
                    tpaRequest.Is_Vendor_Name_Contains_DeepIntent__c = true;
                }*/
                if(isEdith){
                    tpaRequest.Is_Vendor_Name_Contains_Edith__c = true;
                }
                if(isDLIMI){
                    tpaRequest.Is_Vendor_Name_Contains_DLIMI__c = true;
                }
                if(isSpecificTPVendor) {
                    if(isLAADOffering) {
                        tpaRequest.is_Specific_Vendors_LAAD_Off__c = true;
                        specVendorOffList.add('is_Specific_Vendors_LAAD_Off__c');
                    }
                    if(isAPLDOffSpecVendors) {
                        tpaRequest.is_Specific_Vendors_APLD_Off__c = true;
                        specVendorOffList.add('is_Specific_Vendors_APLD_Off__c');
                    }
                    if(isLongPrescriData) {
                        tpaRequest.is_Specific_Vendors_Long_Prescr_Data__c = true;
                        specVendorOffList.add('is_Specific_Vendors_Long_Prescr_Data__c');
                    }
                    if(isMedClaimsData) {
                        tpaRequest.is_Specific_Vendors_Medical_Claims_Data__c = true;
                        specVendorOffList.add('is_Specific_Vendors_Medical_Claims_Data__c');
                    }
                }
                update tpaRequest;
                //will review, put logs here on tpa request update
            }

            CNT_TPA_RequestSubmissionForm.getLimitsMessage();
            updateAgreementChildRecords(isdynamicOffNoticationReqOrNot, isAwaitingClientConfirmationMailReq);//will review //@@@@
            
            //@@@@@@
            Map<String, TPA_Text_Editor__c> mapTpaTextAdditionalTerms = UTL_TPA.getTpaTextAdditionalTerms(tpaRequest);
            String bodyText = '';
            if(!specVendorOffList.isEmpty() && mapTpaTextAdditionalTerms != null){
                system.debug('mapTpaTextAdditionalTerms'+mapTpaTextAdditionalTerms.values());
                for( String addKey : mapTpaTextAdditionalTerms.keyset()){
                    for(String off : specVendorOffList){
                        if(addKey.split(':')[0] == off && addKey.split(':')[1] == 'TPA_Request__c'){
                            TPA_Text_Editor__C listEditor = mapTpaTextAdditionalTerms.get(addKey);
                            bodytext += '<br><br>'+mapTpaTextAdditionalTerms.get(addKey).Content__c;
                        }
                    }
                      
                }
            }
            
            if(bodyText != ''){
                sendEmailDirectToClient(tpaRequest, 'Email Dir to Client Spec Ven and Off', bodyText);
            }

            if(isAisleOff){
                sendEmailToClientToNotifyAisleOff(tpaRequest,'Email to Client IQVIA Aisle off');
            }
            // if(isCanadaRefOff){
            //     sendEmailToClientToNotifyAisleOff(tpaRequest,'Email to Client Canada Ref off');
            // }


            if( requestNumber != null && requestNumber != '' && SRV_TPA_TPARequest.LastAction == 'Request Submitted By Client' ) {
                 if( type == 'renew' ){
                     SRV_TPA_TPARequest.updateActivityHistory(tpaRequest.Id, 'TPA Request '+requestNumber+' is renewed.', false);
                 }else if( type == 'clone' ){
                     SRV_TPA_TPARequest.updateActivityHistory(tpaRequest.Id, 'TPA Request '+requestNumber+' is cloned.', false);
                 }
            }

            SRV_TPA_TPARequest.updateActivityHistory(tpaRequest.Id, 'TPA Request form Received', false);
            if( tpaRequest.Is_Manually_Approved__c  && SRV_TPA_TPARequest.includeAmaAttributesOnly == false && (tpaRequest.isClientOnComplianceHold__c || tpaRequest.isVendorOnComplianceHold__c)){
                 SRV_TPA_TPARequest.updateActivityHistory(tpaRequest.Id, 'Hold for TPA non-compliance', false);
            }
            else if( tpaRequest.Is_Manually_Approved__c  && SRV_TPA_TPARequest.includeAmaAttributesOnly == false){
                 SRV_TPA_TPARequest.updateActivityHistory(tpaRequest.Id, Label.TPA_In_Review_By_IQVIA_Status, false);
            } else if (tpaRequest.Is_Manually_Approved__c && SRV_TPA_TPARequest.includeAmaAttributesOnly == true) {
                 SRV_TPA_TPARequest.updateActivityHistory(tpaRequest.Id, 'TPA Approved Awaiting AMA Approval', false);
            }
            system.debug(' before task created 3');
            if( tpaRequest.Is_Manually_Approved__c){
                 SRV_TPA_TPARequest.updateActivityHistory(tpaRequest.Id, 'TLLA Contract Manually Approved', true);
            } else if (!tpaRequest.Is_Manually_Approved__c) {
                 SRV_TPA_TPARequest.updateActivityHistory(tpaRequest.Id, 'TLLA Contract Auto Approved', true);
            }
            tpaRequest.Is_Client_Submitted_Request__c = true;
            tpaRequest.TPA_Authorised_Signer__c = authorizedSignerResponse;
            tpaRequest.Request_Status__c = Label.TPA_In_Review_By_IQVIA_Status;

            system.debug('tpaRequest.Is_Manually_Approved__c:' + tpaRequest.Is_Manually_Approved__c);
            system.debug('tpaRequest.Is_Potential_Vendor_Case__c:' + tpaRequest.Is_Potential_Vendor_Case__c);
            system.debug('SRV_TPA_TPARequest.includeAmaAttributesOnly:' + SRV_TPA_TPARequest.includeAmaAttributesOnly);

            if(tpaRequest.Is_Manually_Approved__c && !tpaRequest.Is_Potential_Vendor_Case__c){
                if(tpaRequest.isClientOnComplianceHold__c || tpaRequest.isVendorOnComplianceHold__c){
                    tpaRequest.Request_Status__c = 'Hold for TPA non-compliance';
                }else if(DDNAckPendingRecords != null && DDNAckPendingRecords.size() > 0) {
                    tpaRequest.request_status__c = 'Pending Vendor Response on Data Destruction from Prior TPAs';
                    sendMailtoTPProcessorAbtStatusUpdate(tpaRequest,'Awaiting Vendor Submission', 'Pending Vendor Response on Data Destruction from Prior TPAs');
                }else if(isAwaitingClientConfirmationMailReq && isdynamicOffNoticationReqOrNot){
                    if(isQuintilesIMSSalesExeMode) {
                        tpaRequest.request_status__c = 'Awaiting Account Mgmt Communication';
                    }
                    else if(isDirectToClientExeMode){
                        tpaRequest.request_status__c = UTL_TPA.AWAITING_CLIENT_CONFIRMATION;
                    }
                }else if(SRV_TPA_TPARequest.includeAmaAttributesOnly == false){
                    tpaRequest.Request_Status__c = Label.TPA_In_Review_By_IQVIA_Status;
                }else if(SRV_TPA_TPARequest.includeAmaAttributesOnly == true){
                    tpaRequest.Request_Status__c = 'TPA Approved Awaiting AMA Approval';
                }
            }else if(!tpaRequest.Is_Potential_Vendor_Case__c && isAwaitingClientConfirmationMailReq && isdynamicOffNoticationReqOrNot){
                if(isQuintilesIMSSalesExeMode) {
                    tpaRequest.request_status__c = 'Awaiting Account Mgmt Communication';
                }
                else if(isDirectToClientExeMode){
                    tpaRequest.request_status__c = UTL_TPA.AWAITING_CLIENT_CONFIRMATION;
                }
            }else if(tpaRequest.Is_Potential_Vendor_Case__c) {
                tpaRequest.Request_Status__c = 'Initializing Vendor';
                Task task = new Task();
                task.WhatId = tpaRequest.id;
                task.ActivityDate = system.today();
                task.Status = 'Completed';
                task.Subject = 'Initializing Vendor';
                task.CallObject = task.Subject;
                insert task;
            }else{
                tpaRequest.Request_Status__c = 'In Auto Approval Process';
            }

            system.debug('tpaRequest.is_Bulk_TPA_Request__c:' + tpaRequest.is_Bulk_TPA_Request__c);
            system.debug('tpaRequest.Client_Off_Notification_Ack_Date__c:' + tpaRequest.Client_Off_Notification_Ack_Date__c);
            system.debug('tpaRequest.Vendor_Off_Notification_Ack_Date__c:' + tpaRequest.Vendor_Off_Notification_Ack_Date__c);
            system.debug('isAwaitingClientConfirmationMailReq:' + isAwaitingClientConfirmationMailReq);
            system.debug('isdynamicOffNoticationReqOrNot:' + isdynamicOffNoticationReqOrNot);
            system.debug('tpaRequest.Request_Status__c:' + tpaRequest.Request_Status__c);
           

            if(Test.isRunningTest() || (!tpaRequest.is_Bulk_TPA_Request__c && ((tpaRequest.Client_Off_Notification_Ack_Date__c != null && tpaRequest.Vendor_Off_Notification_Ack_Date__c != null) || isAwaitingClientConfirmationMailReq) && isdynamicOffNoticationReqOrNot && tpaRequest.Request_Status__c != 'Initializing Vendor'))
            {
                System.debug('Call sent for notification...');
                SRV_TPA_TPARequest.isOffNotificationDocGenerated = true;
                TPA_Dyn_Off_Not_GeneratorQueue tpaDynOffNotGeneratorQueueObj = new TPA_Dyn_Off_Not_GeneratorQueue();
                tpaDynOffNotGeneratorQueueObj.reqId = tpaRequest.Id;
                tpaDynOffNotGeneratorQueueObj.vendorAccountId = tpaRequest.Service_Provider_Address__c;
                tpaDynOffNotGeneratorQueueObj.clientLanguage = tpaRequest.Client_Language__c;
                tpaDynOffNotGeneratorQueueObj.vendorLanguage = tpaRequest.Vendor_Language__c;
                tpaDynOffNotGeneratorQueueObj.reqName = tpaRequest.Name;
                tpaDynOffNotGeneratorQueueObj.ClientContactEmail = tpaRequest.ClientContact__r.email;
                tpaDynOffNotGeneratorQueueObj.isdynamicOffNotificationReqForVendor = isAwaitingClientConfirmationMailReq;
                tpaDynOffNotGeneratorQueueObj.reqStatus = tpaRequest.Request_Status__c;
                tpaDynOffNotGeneratorQueueObj.GUID = UTL_LogFactory.GUID;
                tpaDynOffNotGeneratorQueueObj.runType = runType;
                if(!Test.isRunningTest()){
                    System.enqueueJob(tpaDynOffNotGeneratorQueueObj);
                }
            }
            // else if (!tpaRequest.is_Bulk_TPA_Request__c && runType == 'RunTpaBusinessRule' && tpaRequest.Request_Status__c != 'Initializing Vendor'){
            //     QBL_TPA_AsyncGenerateDoc asyncGenerateDocCall= new QBL_TPA_AsyncGenerateDoc();
            //     asyncGenerateDocCall.requestId = tpaRequest.Id ;
            //     asyncGenerateDocCall.GUID = UTL_LogFactory.GUID;
            //     System.enqueueJob(asyncGenerateDocCall);
            // }

            if(tpaRequest.Data_Access_Start_Date__c != null && tpaRequest.Data_Access_Start_Date__c.daysBetween(date.today()) > 0) {
                tpaRequest.Agreement_Effective_Date__c = date.today();
            }
            else {
                tpaRequest.Agreement_Effective_Date__c = tpaRequest.Data_Access_Start_Date__c;
            }
            try{
                upsert tpaRequest;
                //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success';
                //TPAQueryHelper.setLogObject(cpcAgreement.id , 'Status Updated to '+cpcAgreement.request_status__c, '',tpaRequest.id);
                //TPAQueryHelper.logRef().generateLog();
            }
            catch(Exception ex)
            {
                system.debug('ErrorCpc:'+ex.getMessage());
                // Debug log change
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SRV_TPA_TPARequest:::updateAgreementFieldsForVendor', tpaRequest != null ? tpaRequest.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                // Debug log change
                //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
                //TPAQueryHelper.setLogObject(cpcAgreement.id , 'Exception:Error Updating the Status after Vendor Submission',ex.getMessage()+' Line:'+ex.getLineNumber(),tpaRequest.id);
                //TPAQueryHelper.logRef().generateLog();
            }
        }
        if(SRV_TPA_TPARequest.isVendorChecklistChanges) {
            /*addTPProcessorInitials = true;
            if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
               assignedTPProcessorName = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c; 
            }*/
            SRV_TPA_TPARequest.sendCompetitiveMail(tpaRequest);
            //addTPProcessorInitials = false;
        }            
      //  updateTPAContactsforClientAndVendorBoth();
        return tpaRequest;
    }

    // public static void updateAgreementFields() {
    //     if(tpaRequest != null) {
    //         if(tpaRequest.Data_Access_Start_Date__c != null) {
    //             tpaRequest.Original_Start_Date__c = tpaRequest.Data_Access_Start_Date__c;
    //         }
    //         if(tpaRequest.Data_Access_End_Date__c != null) {
    //             tpaRequest.Expiration_Date__c = tpaRequest.Data_Access_End_Date__c;
    //         }
    //         tpaRequest.IsSubContractorAdded__c = isSubContractAdded;
    //         if( tpaRequest.Vendor_e_mail__c != null) {
    //             tpaRequest.Vendor_Contact_e_mail__c = tpaRequest.Vendor_e_mail__c;
    //         }
    //         if( tpaRequest.Vendor_First_Name__c != null && tpaRequest.Vendor_Contact_Last_Name__c != null) {
    //             tpaRequest.Vendor_Contact_Name_f__c = tpaRequest.Vendor_First_Name__c+' '+tpaRequest.Vendor_Contact_Last_Name__c;
    //         }
    //     }
    // }    

    public static void updateAgreementChildRecords(Boolean isdynamicOffNoticationReqOrNot, Boolean isAwaitingClientConfirmation) {
        system.debug('isdynamicOffNoticationReqOrNot in updateAgreementChildRecords: ' + isdynamicOffNoticationReqOrNot);
        isRunCommercialAutoLogic = runCommercialAutoLogic();
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();
        Set<String> purposeList = new Set<String>();
        Set<String> dataAssetNames = new Set<String>();
        Map<Id, Id> requestAgreementChildMap = new Map<Id, Id>();
        List<sObject> agreementChildToDelete = new List<sObject>();
        Map<String,String> uniqueSecCombwithOwnerMap = new Map<String,String>();
        Map<String,Boolean> secOwnerwithEmailSendingFlagMap = new Map<String,Boolean>();
        Boolean secOffMailRequired = false;
        List<Id> secondaryOfferingIds = new List<Id>();
        String value = '';

        if(tpaRequest.TP_Processor_Email__c != null && String.isNotBlank(tpaRequest.TP_Processor_Email__c)) {
            TPProcessorEmailId.add(tpaRequest.TP_Processor_Email__c);
        }
        system.debug('tpaRequest.Is_Potential_Vendor_Case__c in updateAgreementChildRecords: ' + tpaRequest.Is_Potential_Vendor_Case__c);
        system.debug('tpaRequest.Is_Manually_Approved__c in updateAgreementChildRecords: ' + tpaRequest.Is_Manually_Approved__c);

        if( tpaRequest.Is_Manually_Approved__c && !tpaRequest.Is_Potential_Vendor_Case__c) {
            if(isdynamicOffNoticationReqOrNot) {
                CNT_TPA_RequestSubmissionForm.getLimitsMessage();
                sendApprovalMail(UTL_TPA.tpaSetting.TPA_AllianceTeamManualReview_Email__c, TPProcessorEmailId  ); //will review//@@@@@
                if(isRunCommercialAutoLogic) {
                    /*List<TPA_Commercial_Review__c> comReviewList = new List<TPA_Commercial_Review__c>();
                    for(TPA_Commercial_Review__c comRev : tpaRequest.TPA_Commercial_Reviews__r) {
                        if(!comRev.Is_ReviewForm_Acknowledged__c) {
                            comReviewList.add(comRev);
                        }
                    }*/
                    //sendApprovalMailToCommericialOwner(comReviewList); //will review//@@@@
                  //  Boolean sendVendorSecondaryEmail = false,sendSecondaryEmail = false;
                    List<TPA_Commercial_Review__c> finalCommercialReviews = [Select Id,Last_Reminder_Sent_Date__c,Is_Review_Secondary__c,Associated_Use_to_Review__c,Associated_Offering_to_Review__c,Manual_Review_Reason__c,Status__c,TPA_Request__c,Receiver_s_Email__c From TPA_Commercial_Review__c where TPA_Request__c =: tpaRequest.Id order by Is_Review_Secondary__c desc];
                    Boolean isPrimaryApp = true,isAllSecondary = true,isAllRevApproved = true;
                    List<TPA_Commercial_Review__c> secondaryReviews = new List<TPA_Commercial_Review__c>();
                    List<TPA_Commercial_Review__c> secondaryReviewsToUpdate = new List<TPA_Commercial_Review__c>();
                    
                    for(TPA_Commercial_Review__c comRev:finalCommercialReviews){
                        if(comRev.Is_Review_Secondary__c && !uniqueSecCombwithOwnerMap.containsKey(comRev.Associated_Use_to_Review__c + ':' + comRev.Associated_Offering_to_Review__c) && !TGRH_TPA_Commercial_Review.isComRevApproved(comRev.Status__c)){
                            uniqueSecCombwithOwnerMap.put(comRev.Associated_Use_to_Review__c + ':' + comRev.Associated_Offering_to_Review__c,comRev.Receiver_s_Email__c);
                            secOwnerwithEmailSendingFlagMap.put(comRev.Receiver_s_Email__c, true);
                            secondaryOfferingIds.add(comRev.Id);
                        }
                        else if(!comRev.Is_Review_Secondary__c && uniqueSecCombwithOwnerMap.containsKey(comRev.Associated_Use_to_Review__c + ':' + comRev.Associated_Offering_to_Review__c) && !TGRH_TPA_Commercial_Review.isComRevApproved(comRev.Status__c)){
                            secOwnerwithEmailSendingFlagMap.put(uniqueSecCombwithOwnerMap.get(comRev.Associated_Use_to_Review__c + ':' + comRev.Associated_Offering_to_Review__c), false);
                        }
                        if(!comRev.Is_Review_Secondary__c && uniqueSecCombwithOwnerMap.containsKey(comRev.Associated_Use_to_Review__c + ':' + comRev.Associated_Offering_to_Review__c) && TGRH_TPA_Commercial_Review.isComRevApproved(comRev.Status__c)){
                            secondaryOfferingIds.add(comRev.Id);
                        }
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
                        sendVendorSecondaryEmail = false;
                        sendSecondaryEmail = false;
                        for(TPA_Commercial_Review__c comRev: secondaryReviews){
                            if((comRev.Status__c == 'Awaiting Review' || comRev.Status__c == 'Awaiting to Send: Primary Commercial Owner Not Complete') && secOwnerwithEmailSendingFlagMap.get(comRev.Receiver_s_Email__c) == true && comRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review')){
                                secOffMailRequired = true;
                                system.debug('inside1:::');
                                if(comRev.Status__c == 'Awaiting Review'){
                                    system.debug('inside2:::');
                                    secOffMailRequired = true;
                                    SRV_TPA_TPARequest.secOfferingMailRequired = true;
                                    continue; 
                                }
                                if(comRev.Status__c == 'Awaiting to Send: Primary Commercial Owner Not Complete'){
                                    comRev.Status__c = 'Awaiting Review';
                                    comRev.Last_Reminder_Sent_Date__c = Date.today();
                                    comRev.Action__c = null;
                                    secondaryReviewsToUpdate.add(comRev);
                                    secOffMailRequired = true;
                                    SRV_TPA_TPARequest.secOfferingMailRequired = true;
                                    continue; 
                                }
                            }
                            else if(comRev.Status__c == 'Awaiting Review'){
                               comRev.Status__c = 'Awaiting to Send: Primary Commercial Owner Not Complete';
                                comRev.Action__c = null;
                                secondaryReviewsToUpdate.add(comRev);
                            }
                        }
                    }
                    else if((isPrimaryApp || isAllSecondary) && secondaryReviews != null && secondaryReviews.size() > 0){
                        for(TPA_Commercial_Review__c comRev: secondaryReviews){
                            if((isPrimaryApp || isAllSecondary || secOwnerwithEmailSendingFlagMap.get(comRev.Receiver_s_Email__c) == true) && comRev.Status__c == 'Awaiting Review' && comRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review')){
                                secOffMailRequired = true;
                                if(comRev.Last_Reminder_Sent_Date__c != null){
                                    SRV_TPA_TPARequest.secOfferingMailRequired = true;
                                }
                                if(isPrimaryApp || isAllSecondary){
                                    SRV_TPA_TPARequest.secOfferingMailRequiredPrimAllCompleted = true;
                                }
                                //SRV_TPA_TPARequest.secOfferingMailRequired = true;
                                continue;
                            }
                            if(comRev.Status__c == 'Awaiting to Send: Primary Commercial Owner Not Complete'){
                                if((isPrimaryApp || isAllSecondary || secOwnerwithEmailSendingFlagMap.get(comRev.Receiver_s_Email__c) == true) && comRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review')){
                                    secOffMailRequired = true;
                                    comRev.Status__c = 'Awaiting Review';
                                    //comRev.Last_Reminder_Sent_Date__c = Date.today();
                                    comRev.Action__c = null;
                                    secondaryReviewsToUpdate.add(comRev);
                                    if(isPrimaryApp || isAllSecondary){
                                        SRV_TPA_TPARequest.secOfferingMailRequiredPrimAllCompleted = true;
                                    }
                                    continue;
                                }
                                else if(isPrimaryApp || isAllSecondary){
                                    comRev.Status__c = 'Awaiting Review';
                                    comRev.Action__c = null;
                                    secondaryReviewsToUpdate.add(comRev);
                                }
                                
                            }
                            if(comRev.Manual_Review_Reason__c == 'Vendor Requires Secondary Review' && (isPrimaryApp || isAllSecondary)){
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
                    if(secondaryReviewsToUpdate.size() > 0){
                        //isSecComReview = true;
                        update secondaryReviewsToUpdate;
                    }
                    CNT_TPA_RequestSubmissionForm.getLimitsMessage();
                    if(!tpaRequest.is_Bulk_TPA_Request__c && !tpaRequest.Is_Potential_Vendor_Case__c) {
                        sendApprovalMailToCommericialOwnerForBulk();
                    }
                    if(secondaryReviewsToUpdate.size() > 0 || sendVendorSecondaryEmail || sendLegalMail || sendSecondaryEmail || SRV_TPA_TPARequest.secOfferingMailRequired || SRV_TPA_TPARequest.secOfferingMailRequiredPrimAllCompleted){
                        isSecComReview = true;
                        if(SRV_TPA_TPARequest.secOfferingMailRequired && !isPrimaryApp && !isAllSecondary){
                            if(secondaryOfferingIds != null && secondaryOfferingIds.size()>0){
                                SRV_TPA_TPARequest.multiRetriggerIds = secondaryOfferingIds;
                            }
                        }
                            sendApprovalMailToCommericialOwnerForBulk();
                            SRV_TPA_TPARequest.multiRetriggerIds = null;
                            isSecComReview = false;
                            SRV_TPA_TPARequest.secOfferingMailRequired = false;

                    }
                }                
                sendAtypicalUseOffClientNotification(tpaRequest);//will review//@@@@
                sendDataDestructionAckOutstandingMail(tpaRequest);//will review//@@@@
            }
            if((tpaRequest.isClientOnComplianceHold__c || tpaRequest.isVendorOnComplianceHold__c) && (tpaRequest.TPA_Agreement_Additional_Fields__r != null && tpaRequest.TPA_Agreement_Additional_Fields__r.size() > 0 && !tpaRequest.TPA_Agreement_Additional_Fields__r[0].TPA_Compliance_Hold_Acknowledged__c ) ){
                sendTPAComplianceHoldMail( UTL_TPA.tpaSetting.TPA_Compliance_Hold_Emails__c, TPProcessorEmailId  );//will review//@@@@
            }
            if(SRV_TPA_TPARequest.includeAmaAttributesOnly) {
                tpaRequest.Requires_Manual_Review__c = false;
            } else {
                tpaRequest.Requires_Manual_Review__c = true;
            }
        }
        else if(!tpaRequest.Is_Potential_Vendor_Case__c && (!isdynamicOffNoticationReqOrNot || !isAwaitingClientConfirmation)) { 
            tpaRequest.Requires_Manual_Review__c = false;
            sendAutoApprovalMail( UTL_TPA.tpaSetting.TPA_AllianceTeamManualReview_Email__c, TPProcessorEmailId ); //will review//@@@@
        }
    }

    public static void vendorUseDefinationUpdates(){

        String englishApttusMultiPicklist = '';
        String japaneseApttusMultiPicklist = '';
        String frenchApttusMultiPicklist = '';
        Set<String> setUseforVeevaTerms = new Set<String>(Label.TPA_Use_name_for_Veeva_Terms.split(';'));
        if(UTL_TPA.tpaSetting != null && !UTL_Validate.isEmptyOrNull(UTL_TPA.tpaSetting.TPA_Supported_Languages__c)) {
            string []languageMap = UTL_TPA.tpaSetting.TPA_Supported_Languages__c.split('~');
            if(languageMap != null) {
                if(languageMap[0] != '') {
                    englishApttusMultiPicklist = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Apttus Purpose MultiPicklist' + languageMap[0]).Translated_Template_Name__c;
                }
                if(languageMap[1] != '') {
                    japaneseApttusMultiPicklist = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Apttus Purpose MultiPicklist' + languageMap[1]).Translated_Template_Name__c;
                }
                if(languageMap[2] != '') {
                    frenchApttusMultiPicklist = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Apttus Purpose MultiPicklist' + languageMap[2]).Translated_Template_Name__c;
                }
            }
        }
        
        //List<TPA_Purpose__c> tpaPurposes = lstPurposeList;
        
        //When client and vendor languages are same or different, Populating Apptus multipicklist fields for tpa available languages.
        String englishSelectedPurposes = '';
        String japaneseSelectedPurposes = '';
        String frenchSelectedPurposes = '';
        String UseListRichtextFormateEnglish = '';
        String UseListRichtextFormateJa = '';
        String UseListRichtextFormateFr = '';
        for(TPA_Purpose__c tpaPurposeSO : getPurposesList(tpaRequest.Id)) {
            if(tpaPurposeSO.Name != 'Other') {
                if(setUseforVeevaTerms.contains( tpaPurposeSO.Name ) ) {
                    isContainUSEforVeeva = true;
                }
                
                if(tpaPurposeSO.Name == 'CRM'){
                    isUseCRM = true;
                }
                
                String purposeName_EnglishLang = '';
                String purposeName_JapaneseLang = '';
                String purposeName_FrenchLang = '';

                
                if(UTL_TPA.tpaSetting != null && !UTL_Validate.isEmptyOrNull(UTL_TPA.tpaSetting.TPA_Supported_Languages__c)) {
                    string []languageMap = UTL_TPA.tpaSetting.TPA_Supported_Languages__c.split('~');
                    if(languageMap != null)
                    {
                        if(languageMap[0] != ''){
                            purposeName_EnglishLang = (String)tpaPurposeSO.purpose__r.get(languageMap[0]+'_Translation__c') != null ? (String)tpaPurposeSO.purpose__r.get(languageMap[0]+'_Translation__c') : tpaPurposeSO.Name;
                        }
                        if(languageMap[1] != ''){
                            purposeName_JapaneseLang = (String)tpaPurposeSO.purpose__r.get(languageMap[1]+'_Translation__c') != null ? (String)tpaPurposeSO.purpose__r.get(languageMap[1]+'_Translation__c') : tpaPurposeSO.Name;
                        }
                        if(languageMap[2] != ''){
                            purposeName_FrenchLang = (String)tpaPurposeSO.purpose__r.get(languageMap[2]+'_Translation__c') != null ? (String)tpaPurposeSO.purpose__r.get(languageMap[2]+'_Translation__c') : tpaPurposeSO.Name;
                        }
                    }
                }
                
                if(englishSelectedPurposes.indexOf(purposeName_EnglishLang) == -1) {
                    englishSelectedPurposes += purposeName_EnglishLang + ';';
                    UseListRichtextFormateEnglish += purposeName_EnglishLang +  '</li><li>';
                }
                if(japaneseSelectedPurposes.indexOf(purposeName_JapaneseLang) == -1) {
                    japaneseSelectedPurposes += purposeName_JapaneseLang + ';';
                    UseListRichtextFormateJa += purposeName_JapaneseLang +  '</li><li>';
                }
                if(frenchSelectedPurposes.indexOf(purposeName_FrenchLang) == -1) {
                    frenchSelectedPurposes += purposeName_FrenchLang + ';';
                    UseListRichtextFormateFr += purposeName_FrenchLang +  '</li><li>';
                }
            }
        }

        String vendorLanguage = tpaRequest.TLLA_Language_Chosen__c != null ? tpaRequest.TLLA_Language_Chosen__c : (tpaRequest.Vendor_Language__c != null ? tpaRequest.Vendor_Language__c : 'English');

        
        if(englishApttusMultiPicklist != '' && englishSelectedPurposes != ''){
            englishSelectedPurposes = englishSelectedPurposes.subString(0, englishSelectedPurposes.length()-1);
            tpaRequest.put(englishApttusMultiPicklist, englishSelectedPurposes);
            System.debug('englishApttusMultiPicklist'+tpaRequest.get(englishApttusMultiPicklist));
        }
        if(japaneseApttusMultiPicklist != '' && japaneseSelectedPurposes != ''){
            japaneseSelectedPurposes = japaneseSelectedPurposes.subString(0, japaneseSelectedPurposes.length()-1);
            tpaRequest.put(japaneseApttusMultiPicklist, japaneseSelectedPurposes);
            System.debug(tpaRequest.get(englishApttusMultiPicklist));
        }
        if(frenchApttusMultiPicklist != '' && frenchSelectedPurposes != ''){
            frenchSelectedPurposes = frenchSelectedPurposes.subString(0, frenchSelectedPurposes.length()-1);
            tpaRequest.put(frenchApttusMultiPicklist, frenchSelectedPurposes);
        }

        if(UseListRichtextFormateEnglish != ''){
            UseListRichtextFormateEnglish = UseListRichtextFormateEnglish.removeEnd('<li>');
            UseListRichtextFormateEnglish = '<ul style="font-size: 8.0pt;color: black; font-family: Arial, sans-serif;" ><li>' + UseListRichtextFormateEnglish + '</ul>';
            tpaRequest.put('Use_List__c', UseListRichtextFormateEnglish);
        }
        if(vendorLanguage == 'Japanese' && UseListRichtextFormateJa != ''){
            UseListRichtextFormateJa = UseListRichtextFormateJa.removeEnd('<li>');
            UseListRichtextFormateJa = '<ul style="font-size: 8.0pt;color: black; font-family: Arial, sans-serif;" ><li>' + UseListRichtextFormateJa + '</li></ul>';
            tpaRequest.put('Localized_Use_List__c', UseListRichtextFormateJa);
        }
        else if(vendorLanguage == 'French' && UseListRichtextFormateFr != ''){
            UseListRichtextFormateFr = UseListRichtextFormateFr.removeEnd('<li>');
            UseListRichtextFormateFr = '<ul style="font-size: 8.0pt;color: black; font-family: Arial, sans-serif;" ><li>' + UseListRichtextFormateFr + '</li></ul>';
            tpaRequest.put('Localized_Use_List__c', UseListRichtextFormateFr);
        }

        
    }
    

    /*
    public static TPA_Request_Localized__c clientVendorUpdates(String vendorOrClient, List<TPA_Purpose__c> lstPurposeList,List<TPA_Data_Asset__c> lstPrimarySecondaryAsset) { 
        String clientLanguage = tpaRequest.Client_Language__c != null ? tpaRequest.Client_Language__c : 'English';
        String vendorLanguage = tpaRequest.Vendor_Language__c != null ? tpaRequest.Vendor_Language__c : 'English';
        String clientLanguageField = clientLanguage + '_Translation__c';
        String vendorLanguageField = vendorLanguage + '_Translation__c';

        Set<String> langSet = new Set<String>();        
        langSet.add(clientLanguageField);
        langSet.add(vendorLanguageField);

        Map<String,List<TPA_Language_Cross_Walk__c>> mapTranslation = UTL_TPA_Multilingual.getTranslatedValueMap( langSet);

        String permittedTranslationClient = (String)mapTranslation.get(clientLanguageField + '~IMS_TPA_Purpose__c~Record~Permitted Use')[0].get(clientLanguageField);
        String permittedTranslationVendor = (String)mapTranslation.get(vendorLanguageField + '~IMS_TPA_Purpose__c~Record~Permitted Use')[0].get(vendorLanguageField);

        String imsDataTranslationClient = (String)mapTranslation.get(clientLanguageField + '~IMS_TPA_Purpose__c~Record~IQVIA Data')[0].get(clientLanguageField);
        String imsDataTranslationVendor = (String)mapTranslation.get(vendorLanguageField + '~IMS_TPA_Purpose__c~Record~IQVIA Data')[0].get(vendorLanguageField);
        
        Map<String, String> mapDefaultToTranslatedClient = new Map<String, String>();
        Map<String, String> mapDefaultToTranslatedVendor = new Map<String, String>();
        List<TPA_Language_Cross_Walk__c> lstCrossWalkClient =  mapTranslation.get(clientLanguageField+'~IMS_Data_Asset__c~Picklist~Geo_Level__c');
        List<TPA_Language_Cross_Walk__c> lstCrossWalkVendor =  mapTranslation.get(vendorLanguageField+'~IMS_Data_Asset__c~Picklist~Geo_Level__c');        
        for(TPA_Language_Cross_Walk__c objCrossWalk :lstCrossWalkClient ) {
            mapDefaultToTranslatedClient.put(objCrossWalk.Default_Value__c,(String) objCrossWalk.get(clientLanguageField));
        }
        for(TPA_Language_Cross_Walk__c objCrossWalk :lstCrossWalkVendor ) {
            mapDefaultToTranslatedVendor.put(objCrossWalk.Default_Value__c,(String) objCrossWalk.get(vendorLanguageField));
        }
        //System.debug('mapDefaultToTranslated ::'+mapDefaultToTranslated);

        List<TPA_Request_Localized__c> lstLocalized = UTL_TPA_Multilingual.getRequestChildLocalizedRecords(tpaRequest.id);
        System.debug('########localized list is::::'+lstLocalized);

        TPA_Request_Localized__c obClientLocal = new TPA_Request_Localized__c();
        TPA_Request_Localized__c obVendorLocal = new TPA_Request_Localized__c();
        
        for(TPA_Request_Localized__c objTemp : lstLocalized) {
            if(objTemp.Record_Localized_For__c == 'client' || objTemp.Record_Localized_For__c == 'client-vendor') {
                obClientLocal  = objTemp;
            } 
            else if(objTemp.Record_Localized_For__c == 'vendor') {
                obVendorLocal = objTemp;
            }
        }
        System.debug('###obClientLocal si:::::'+obClientLocal);
        System.debug('###obVendorLocal si:::::'+obVendorLocal);

        tpaRequest.purpose_List__c = '';
        tpaRequest.Agreement_Purpose_List__c = '';

        tpaRequest.PurposeWithDataAsset__c = '';
        obClientLocal.PurposeWithDataAsset__c = '';
        obVendorLocal.PurposeWithDataAsset__c = '';

        tpaRequest.Countries_of_offerings__c = '';
        tpaRequest.Category_of_Offerings__c = '';
        tpaRequest.data_asset_List__c = '';

        Boolean isOtherUseSelected = false;
        String bodyTextForOtherUse = '';
        Boolean isOtherOfferingSelected = false;
        String bodyTextForOtherOffering = '';

        Set<String> categoryForOtherUse = new Set<String>();
        String dataAssetsString = '';
        String dataAssetsStringLocalizedClient = '';
        String dataAssetsStringLocalizedVendor = '';
        String dataAssetsStringByCategory = '';
        String dataAssetsStringByCategoryLocalizedClient = '';
        String dataAssetsStringByCategoryLocalizedVendor = '';
        String secondaryOfferingNames = '';
        Map<String, String> dataAssetsByRegionMap = new Map<String, String>();
        Map<String,String> dataAssetsByRegionMapLocalizedClient = new Map<String,String>();
        Map<String,String> dataAssetsByRegionMapLocalizedVendor = new Map<String,String>();
        Map<String, String> dataAssetsByCategoryMap = new Map<String, String>();
        Map<String,String> dataAssetsByCategoryMapLocalizedClient = new Map<String,String>();
        Map<String,String> dataAssetsByCategoryMapLocalizedVendor = new Map<String,String>();

        Set<Id> purposeId = new Set<Id>();
        for(TPA_Purpose__c tpaPurpose : getPurposesList(tpaRequest.Id)) {
            purposeId.add(tpaPurpose.Id);
        }
        
        for(TPA_Purpose__c tpaPurpose : getPurposesList(tpaRequest.Id)) { 
            if(tpaPurpose.Name != 'Other') {
                tpaRequest.Has_Use_Definition_Attachment__c = true;
            }

            tpaRequest.purpose_List__c += tpaPurpose.Name + ', ';
            
            tpaRequest.PurposeWithDataAsset__c += Label.TPA_Permitted_Use_Keyword + tpaPurpose.Name + ' / ' + Label.TPA_IQVIA_Data_Keyword;            
            obClientLocal.PurposeWithDataAsset__c += permittedTranslationClient + ': ' + (tpaPurpose.Purpose__r.get(clientLanguageField) != null ? tpaPurpose.Purpose__r.get(clientLanguageField): tpaPurpose.Name) + ' /' + imsDataTranslationClient +': ';
            obVendorLocal.PurposeWithDataAsset__c += permittedTranslationVendor + ': ' + (tpaPurpose.Purpose__r.get(vendorLanguageField) != null ? tpaPurpose.Purpose__r.get(vendorLanguageField): tpaPurpose.Name) + ' /' + imsDataTranslationVendor +': ';
            
            for(TPA_Data_Asset__c primaryAsset : getUseIdOfferingsMap(purposeId).get(tpaPurpose.Id)) {
                dataAssetsString = '';
                dataAssetsStringLocalizedClient = '';
                dataAssetsStringLocalizedVendor = '';
                dataAssetsStringByCategory = '';                
                dataAssetsStringByCategoryLocalizedClient = '';
                dataAssetsStringByCategoryLocalizedVendor = '';

                String offeringCategory = '\nOffering Category ' + primaryAsset.Primary_Asset_Geo_Level__c; 
                String offeringCategoryLocalizedClient =  '\nOffering Category ' + (mapDefaultToTranslatedClient.get(primaryAsset.Primary_Asset_Geo_Level__c) != null ? mapDefaultToTranslatedClient.get(primaryAsset.Primary_Asset_Geo_Level__c):primaryAsset.Primary_Asset_Geo_Level__c );
                String offeringCategoryLocalizedVendor =  '\nOffering Category ' + (mapDefaultToTranslatedVendor.get(primaryAsset.Primary_Asset_Geo_Level__c) != null ? mapDefaultToTranslatedVendor.get(primaryAsset.Primary_Asset_Geo_Level__c):primaryAsset.Primary_Asset_Geo_Level__c );

                if(dataAssetsByRegionMap.containsKey(primaryAsset.BU__c)) {
                    dataAssetsString = dataAssetsByRegionMap.get(primaryAsset.BU__c);
                    dataAssetsStringLocalizedClient = dataAssetsByRegionMapLocalizedClient.get(primaryAsset.BU__c);
                    dataAssetsStringLocalizedVendor = dataAssetsByRegionMapLocalizedVendor.get(primaryAsset.BU__c);
                }

                if(dataAssetsByCategoryMap.containsKey(offeringCategory)) {
                    dataAssetsStringByCategory = dataAssetsByCategoryMap.get(offeringCategory);
                    dataAssetsStringByCategoryLocalizedClient = dataAssetsByCategoryMapLocalizedClient.get(offeringCategoryLocalizedClient);
                    dataAssetsStringByCategoryLocalizedVendor = dataAssetsByCategoryMapLocalizedVendor.get(offeringCategoryLocalizedVendor);
                }

                if(primaryAsset.TPA_Secondary_Data_Assets__r != null && primaryAsset.TPA_Secondary_Data_Assets__r.size() > 0) {
                    dataAssetsString +=  primaryAsset.Asset_Name__c + ' <';
                    dataAssetsStringLocalizedClient +=  (primaryAsset.Data_Asset__r.get(clientLanguageField) != null ? primaryAsset.Data_Asset__r.get(clientLanguageField) :  primaryAsset.Asset_Name__c ) + ' <';
                    dataAssetsStringLocalizedVendor +=  (primaryAsset.Data_Asset__r.get(vendorLanguageField) != null ? primaryAsset.Data_Asset__r.get(vendorLanguageField) :  primaryAsset.Asset_Name__c ) + ' <';

                    dataAssetsStringByCategory += primaryAsset.Asset_Name__c + ' <';
                    dataAssetsStringByCategoryLocalizedClient += (primaryAsset.Data_Asset__r.get(clientLanguageField) != null ? primaryAsset.Data_Asset__r.get(clientLanguageField) :  primaryAsset.Asset_Name__c ) + ' <';
                    dataAssetsStringByCategoryLocalizedVendor += (primaryAsset.Data_Asset__r.get(vendorLanguageField) != null ? primaryAsset.Data_Asset__r.get(vendorLanguageField) :  primaryAsset.Asset_Name__c ) + ' <';
                    

                    for(TPA_Secondary_Data_Asset__c secondaryAsset: primaryAsset.TPA_Secondary_Data_Assets__r) {
                        dataAssetsString += secondaryAsset.Secondary_Asset_Name__c + '; ';
                        dataAssetsStringLocalizedClient += (secondaryAsset.IMS_Secondary_Data_Asset__r.get(clientLanguageField) != null ?secondaryAsset.IMS_Secondary_Data_Asset__r.get(clientLanguageField) :secondaryAsset.Secondary_Asset_Name__c ) + '; ';
                        dataAssetsStringLocalizedVendor += (secondaryAsset.IMS_Secondary_Data_Asset__r.get(vendorLanguageField) != null ?secondaryAsset.IMS_Secondary_Data_Asset__r.get(vendorLanguageField) :secondaryAsset.Secondary_Asset_Name__c ) + '; ';

                        dataAssetsStringByCategory += secondaryAsset.Secondary_Asset_Name__c + '; ';
                        secondaryOfferingNames += secondaryAsset.Secondary_Asset_Name__c + ', ';
                        dataAssetsStringByCategoryLocalizedClient += (secondaryAsset.IMS_Secondary_Data_Asset__r.get(clientLanguageField) != null ? secondaryAsset.IMS_Secondary_Data_Asset__r.get(clientLanguageField) : secondaryAsset.Secondary_Asset_Name__c ) + '; ';
                        dataAssetsStringByCategoryLocalizedVendor += (secondaryAsset.IMS_Secondary_Data_Asset__r.get(vendorLanguageField) != null ? secondaryAsset.IMS_Secondary_Data_Asset__r.get(vendorLanguageField) : secondaryAsset.Secondary_Asset_Name__c ) + '; ';

                        tpaRequest.PurposeWithDataAsset__c +=  secondaryAsset.Secondary_Asset_Name__c  + ', ';
                        obClientLocal.PurposeWithDataAsset__c += (String)secondaryAsset.IMS_Secondary_Data_Asset__r.get(clientLanguageField) != null ? (String)secondaryAsset.IMS_Secondary_Data_Asset__r.get(clientLanguageField) : secondaryAsset.Secondary_Asset_Name__c  + ', ';
                        obVendorLocal.PurposeWithDataAsset__c += (String)secondaryAsset.IMS_Secondary_Data_Asset__r.get(vendorLanguageField) != null ? (String)secondaryAsset.IMS_Secondary_Data_Asset__r.get(vendorLanguageField) : secondaryAsset.Secondary_Asset_Name__c  + ', ';
                    }

                    dataAssetsString = dataAssetsString.trim().substring(0, dataAssetsString.trim().length() - 1) + '>, ';
                    dataAssetsStringLocalizedClient = dataAssetsStringLocalizedClient.trim().substring(0,dataAssetsStringLocalizedClient.trim().length() - 1) + '>, ';
                    dataAssetsStringLocalizedVendor = dataAssetsStringLocalizedVendor.trim().substring(0,dataAssetsStringLocalizedVendor.trim().length() - 1) + '>, ';

                    dataAssetsStringByCategory = dataAssetsStringByCategory.trim().substring(0,dataAssetsStringByCategory.trim().length() - 1) + '>, ';
                    dataAssetsStringByCategoryLocalizedClient = dataAssetsStringByCategoryLocalizedClient.trim().substring(0,dataAssetsStringByCategoryLocalizedClient.trim().length() - 1) + '>, ';
                    dataAssetsStringByCategoryLocalizedVendor = dataAssetsStringByCategoryLocalizedVendor.trim().substring(0,dataAssetsStringByCategoryLocalizedVendor.trim().length() - 1) + '>, ';                   
                } 
                else {
                    if(primaryAsset.Asset_Name__c == 'Other') {
                        dataAssetsString += 'Other : ' + primaryAsset.Other_Data_Asset_Details__c + ', ';
                        dataAssetsStringLocalizedClient += 'Other : ' + primaryAsset.Other_Data_Asset_Details__c + ', ';
                        dataAssetsStringLocalizedVendor += 'Other : ' + primaryAsset.Other_Data_Asset_Details__c + ', ';

                        dataAssetsStringByCategory += 'Other : ' + primaryAsset.Other_Data_Asset_Details__c+', ';
                        dataAssetsStringByCategoryLocalizedVendor += 'Other : ' + primaryAsset.Other_Data_Asset_Details__c+', ';
                        dataAssetsStringByCategoryLocalizedVendor += 'Other : ' + primaryAsset.Other_Data_Asset_Details__c+', ';
                    } else {
                        if(dataAssetsString.indexOf(primaryAsset.Asset_Name__c) == -1 ) {
                            dataAssetsString +=  primaryAsset.Asset_Name__c + ', ';
                            dataAssetsStringLocalizedClient += (primaryAsset.Data_Asset__r.get(clientLanguageField) != null ? primaryAsset.Data_Asset__r.get(clientLanguageField): primaryAsset.Asset_Name__c) + ', ';
                            dataAssetsStringLocalizedVendor += (primaryAsset.Data_Asset__r.get(vendorLanguageField) != null ? primaryAsset.Data_Asset__r.get(vendorLanguageField): primaryAsset.Asset_Name__c) + ', ';
                        }

                        if(dataAssetsStringByCategory.indexOf(primaryAsset.Asset_Name__c) == -1 ) {
                            dataAssetsStringByCategory += primaryAsset.Asset_Name__c+', ';
                            dataAssetsStringByCategoryLocalizedClient += (primaryAsset.Data_Asset__r.get(clientLanguageField) != null ? primaryAsset.Data_Asset__r.get(clientLanguageField) : primaryAsset.Asset_Name__c) + ', ';  
                            dataAssetsStringByCategoryLocalizedVendor += (primaryAsset.Data_Asset__r.get(vendorLanguageField) != null ? primaryAsset.Data_Asset__r.get(vendorLanguageField) : primaryAsset.Asset_Name__c) + ', ';                         
                        }
                    }
                    
                    tpaRequest.PurposeWithDataAsset__c += primaryAsset.Asset_NametText__c + ', ';
                    obClientLocal.PurposeWithDataAsset__c += (String)primaryAsset.Data_Asset__r.get(clientLanguageField) != null ? (String)primaryAsset.Data_Asset__r.get(clientLanguageField) : primaryAsset.Asset_NametText__c + ', ';
                    obVendorLocal.PurposeWithDataAsset__c += (String)primaryAsset.Data_Asset__r.get(vendorLanguageField) != null ? (String)primaryAsset.Data_Asset__r.get(vendorLanguageField) : primaryAsset.Asset_NametText__c + ', ';
                }

                dataAssetsByRegionMap.put(primaryAsset.BU__c, dataAssetsString);
                dataAssetsByRegionMapLocalizedClient.put(primaryAsset.BU__c, dataAssetsStringLocalizedClient);
                dataAssetsByRegionMapLocalizedVendor.put(primaryAsset.BU__c, dataAssetsStringLocalizedVendor);

                dataAssetsByCategoryMap.put(offeringCategory, dataAssetsStringByCategory);
                dataAssetsByCategoryMapLocalizedClient.put(offeringCategoryLocalizedClient, dataAssetsStringByCategoryLocalizedClient);
                dataAssetsByCategoryMapLocalizedVendor.put(offeringCategoryLocalizedVendor, dataAssetsStringByCategoryLocalizedVendor);

                if(tpaRequest.Countries_of_offerings__c.indexOf(primaryAsset.BU__c) == -1) {
                    tpaRequest.Countries_of_offerings__c += primaryAsset.BU__c + ', ';
                }

                if(primaryAsset.Asset_NametText__c == 'Other') {
                    bodyTextForOtherOffering += '<tr> <td style="font-size:12px ;font-family:arial;border : 2px solid black;padding-left: 5px;"> ' + primaryAsset.BU__c + '</td>';
                    bodyTextForOtherOffering += '<td style="font-size:12px;font-family:arial;border : 2px solid black;padding-left: 5px;"> ' + primaryAsset.Geo_Level__c + '</td>';
                    bodyTextForOtherOffering += '<td style="font-size:12px;font-family:arial;border : 2px solid black;padding-left: 5px;"> ' + primaryAsset.Other_Data_Asset_Details__c + '</td></tr>';
                    isOtherOfferingSelected = true;
                }
            }
            tpaRequest.PurposeWithDataAsset__c = tpaRequest.PurposeWithDataAsset__c.substringBeforeLast(',') + '\n';
            obClientLocal.PurposeWithDataAsset__c = obClientLocal.PurposeWithDataAsset__c.substringBeforeLast(',') + '\n';
            obVendorLocal.PurposeWithDataAsset__c = obVendorLocal.PurposeWithDataAsset__c.substringBeforeLast(',') + '\n';

            if(tpaPurpose.Name == 'Other' && !categoryForOtherUse.contains(tpaPurpose.Purpose_Category_Name__c)) {
                bodyTextForOtherUse += '<p style ="font-size:12px;font-family:arial;">&emsp;&emsp;' + tpaPurpose.Purpose_Category_Name__c + ' Other: ' + tpaPurpose.Other_Text__c + '  <br>';
                isOtherUseSelected = true;
                categoryForOtherUse.add(tpaPurpose.Purpose_Category_Name__c);
            }
        }

        Map<String, Schema.SObjectField> fieldMapTPARequestLocalized = Schema.SObjectType.TPA_Request_Localized__c.fields.getMap();
        Integer dataPurposeWithDataAssetLocLength = fieldMapTPARequestLocalized.get('PurposeWithDataAsset__c').getDescribe().getLength();
        Integer dataAssetFieldLocalizedLength = fieldMapTPARequestLocalized.get('Data_Asset_List__c').getDescribe().getLength();
        Integer OfferingwithCategoryLocFieldLength = fieldMapTPARequestLocalized.get('Offerings_With_Category__c').getDescribe().getLength();
        
        Map<String, Schema.SObjectField> fieldMapTPARequest = Schema.SObjectType.TPA_Request__c.fields.getMap();
        Integer dataPurposeWithDataAssetLength = fieldMapTPARequest.get('PurposeWithDataAsset__c').getDescribe().getLength();
        Integer dataAssetFieldTPARequestLength = fieldMapTPARequest.get('Data_Asset_List__c').getDescribe().getLength();
        Integer OfferingwithCategoryFieldLength = fieldMapTPARequest.get('Offerings_With_Category__c').getDescribe().getLength();

        tpaRequest.purpose_List__c = tpaRequest.purpose_List__c.substringBeforeLast(',');
        tpaRequest.Agreement_Purpose_List__c = tpaRequest.purpose_List__c;
        tpaRequest.Countries_of_offerings__c = tpaRequest.Countries_of_offerings__c.substringBeforeLast(',');
        tpaRequest.Secondary_Data_Asset_List__c = secondaryOfferingNames.substring(0,secondaryOfferingNames.length() - 1);

        tpaRequest.PurposeWithDataAssetClientLocalized__c = obClientLocal.PurposeWithDataAsset__c;
        if(tpaRequest.PurposeWithDataAsset__c.length() > dataPurposeWithDataAssetLength) {
            tpaRequest.PurposeWithDataAsset__c = tpaRequest.PurposeWithDataAsset__c.substring(0, dataPurposeWithDataAssetLength);
        }
        
        if(obClientLocal.PurposeWithDataAsset__c.length() > dataPurposeWithDataAssetLocLength) {
            tpaRequest.PurposeWithDataAssetClientLocalized__c = tpaRequest.PurposeWithDataAssetClientLocalized__c.substring(0, dataPurposeWithDataAssetLocLength);
            obClientLocal.PurposeWithDataAsset__c = obClientLocal.PurposeWithDataAsset__c.substring(0, dataPurposeWithDataAssetLocLength);
            obVendorLocal.PurposeWithDataAsset__c = obVendorLocal.PurposeWithDataAsset__c.substring(0, dataPurposeWithDataAssetLocLength);
        }

        tpaRequest.data_asset_List__c = '';
        obClientLocal.data_asset_List__c = '';
        obVendorLocal.data_asset_List__c = '';
        for(String region : dataAssetsByRegionMap.keySet()) {
            if(tpaRequest.data_asset_List__c == '') {
                tpaRequest.data_asset_List__c = region + ' -- ' + dataAssetsByRegionMap.get(region);
                obClientLocal.data_asset_List__c = region + ' -- ' + dataAssetsByRegionMapLocalizedClient.get(region);
                obVendorLocal.data_asset_List__c = region + ' -- ' + dataAssetsByRegionMapLocalizedVendor.get(region);
            } else {
                tpaRequest.data_asset_List__c += ' \n ' + region + ' -- ' + dataAssetsByRegionMap.get(region);
                obClientLocal.data_asset_List__c += ' \n ' + region + ' -- ' + dataAssetsByRegionMapLocalizedClient.get(region);
                obVendorLocal.data_asset_List__c += ' \n ' + region + ' -- ' + dataAssetsByRegionMapLocalizedVendor.get(region);
            }
        }  
         
        if(obClientLocal.data_asset_List__c.length() > dataAssetFieldLocalizedLength) {
            obClientLocal.data_asset_List__c = obClientLocal.data_asset_List__c.substring(0, dataAssetFieldLocalizedLength);
        }
        if(obVendorLocal.data_asset_List__c.length() > dataAssetFieldLocalizedLength) {
            obVendorLocal.data_asset_List__c = obVendorLocal.data_asset_List__c.substring(0, dataAssetFieldLocalizedLength);
        }
        if(tpaRequest.data_asset_List__c.length() > dataAssetFieldTPARequestLength) {
            tpaRequest.data_asset_List__c = tpaRequest.data_asset_List__c.substring(0, dataAssetFieldTPARequestLength);
        }
    
        tpaRequest.Offerings_With_Category__c = '';
        for(String region : dataAssetsByCategoryMap.keySet()) {
            if(tpaRequest.Offerings_With_Category__c == '') {
                tpaRequest.Offerings_With_Category__c = region + ' -- ' + dataAssetsByCategoryMap.get(region);
            } else {
                tpaRequest.Offerings_With_Category__c += ' \n ' + region + ' -- ' + dataAssetsByCategoryMap.get(region);
            }
        }
        if(tpaRequest.Offerings_With_Category__c.length() > OfferingwithCategoryFieldLength) {
            tpaRequest.Offerings_With_Category__c = tpaRequest.Offerings_With_Category__c.substring(0, OfferingwithCategoryFieldLength);
        }        

        obClientLocal.Offerings_With_Category__c = '';
        for(String region : dataAssetsByCategoryMapLocalizedClient.keySet()) {
            if(obClientLocal.Offerings_With_Category__c == '') {
                obClientLocal.Offerings_With_Category__c = region + ' -- ' + dataAssetsByCategoryMapLocalizedClient.get(region);
            } else {
                obClientLocal.Offerings_With_Category__c += ' \n ' + region + ' -- ' + dataAssetsByCategoryMapLocalizedClient.get(region);
            }
        }
        if(obClientLocal.Offerings_With_Category__c.length() > OfferingwithCategoryLocFieldLength) {
            obClientLocal.Offerings_With_Category__c = obClientLocal.Offerings_With_Category__c.substring(0, OfferingwithCategoryLocFieldLength);
        }

        obVendorLocal.Offerings_With_Category__c = '';
        for(String region : dataAssetsByCategoryMapLocalizedVendor.keySet()) {
            if(obVendorLocal.Offerings_With_Category__c == '') {
                obVendorLocal.Offerings_With_Category__c = region + ' -- ' + dataAssetsByCategoryMapLocalizedVendor.get(region);
            } else {
                obVendorLocal.Offerings_With_Category__c += ' \n ' + region + ' -- ' + dataAssetsByCategoryMapLocalizedVendor.get(region);
            }
        }
        if(obVendorLocal.Offerings_With_Category__c.length() > OfferingwithCategoryLocFieldLength) {
            obVendorLocal.Offerings_With_Category__c = obVendorLocal.Offerings_With_Category__c.substring(0, OfferingwithCategoryLocFieldLength);
        }
        
        Set<String> setUseforVeevaTerms = new Set<String>(Label.TPA_Use_name_for_Veeva_Terms.split(';')); //will review       
        
        System.debug('Working after permitted...');

        //------ Set Apptus TPA Purpose MultiPiclist Values Start ----------//
        if(vendorOrClient == VENDOR_CON) {            
            String englishApttusMultiPicklist = '';
            String japaneseApttusMultiPicklist = '';
            String frenchApttusMultiPicklist = '';
            
            if(UTL_TPA.tpaSetting != null && !UTL_Validate.isEmptyOrNull(UTL_TPA.tpaSetting.TPA_Supported_Languages__c)) {
                string []languageMap = UTL_TPA.tpaSetting.TPA_Supported_Languages__c.split('~');
                if(languageMap != null) {
                    if(languageMap[0] != '') {
                        englishApttusMultiPicklist = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Apttus Purpose MultiPicklist' + languageMap[0]).Translated_Template_Name__c;
                    }
                    if(languageMap[1] != '') {
                        japaneseApttusMultiPicklist = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Apttus Purpose MultiPicklist' + languageMap[1]).Translated_Template_Name__c;
                    }
                    if(languageMap[2] != '') {
                        frenchApttusMultiPicklist = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Apttus Purpose MultiPicklist' + languageMap[2]).Translated_Template_Name__c;
                    }
                }
            }

            //List<TPA_Purpose__c> tpaPurposes = lstPurposeList;

            //When client and vendor languages are same or different, Populating Apptus multipicklist fields for tpa available languages.
            String englishSelectedPurposes = '';
            String japaneseSelectedPurposes = '';
            String frenchSelectedPurposes = '';
            for(TPA_Purpose__c tpaPurposeSO : getPurposesList(tpaRequest.Id)) {
                if(tpaPurposeSO.Name != 'Other') {
                    if(setUseforVeevaTerms.contains( tpaPurposeSO.Name ) ) {
                        isContainUSEforVeeva = true;
                    }
                    
                    if(tpaPurposeSO.Name == 'CRM'){
                        isUseCRM = true;
                    }

                    String purposeName_EnglishLang = '';
                    String purposeName_JapaneseLang = '';
                    String purposeName_FrenchLang = '';

                    if(UTL_TPA.tpaSetting != null && !UTL_Validate.isEmptyOrNull(UTL_TPA.tpaSetting.TPA_Supported_Languages__c)) {
                        string []languageMap = UTL_TPA.tpaSetting.TPA_Supported_Languages__c.split('~');
                        if(languageMap != null)
                        {
                            if(languageMap[0] != ''){
                                purposeName_EnglishLang = (String)tpaPurposeSO.purpose__r.get(languageMap[0]+'_Translation__c') != null ? (String)tpaPurposeSO.purpose__r.get(languageMap[0]+'_Translation__c') : tpaPurposeSO.Name;
                            }
                            if(languageMap[1] != ''){
                                purposeName_JapaneseLang = (String)tpaPurposeSO.purpose__r.get(languageMap[1]+'_Translation__c') != null ? (String)tpaPurposeSO.purpose__r.get(languageMap[1]+'_Translation__c') : tpaPurposeSO.Name;
                            }
                            if(languageMap[2] != ''){
                                purposeName_FrenchLang = (String)tpaPurposeSO.purpose__r.get(languageMap[2]+'_Translation__c') != null ? (String)tpaPurposeSO.purpose__r.get(languageMap[2]+'_Translation__c') : tpaPurposeSO.Name;
                            }
                        }
                    }
                    
                    if(englishSelectedPurposes.indexOf(purposeName_EnglishLang) == -1) {
                        englishSelectedPurposes += purposeName_EnglishLang + ';';
                    }
                    if(japaneseSelectedPurposes.indexOf(purposeName_JapaneseLang) == -1) {
                        japaneseSelectedPurposes += purposeName_JapaneseLang + ';';
                    }
                    if(frenchSelectedPurposes.indexOf(purposeName_FrenchLang) == -1) {
                        frenchSelectedPurposes += purposeName_FrenchLang + ';';
                    }
                }
            }
            
            if(englishApttusMultiPicklist != '' && englishSelectedPurposes != ''){
                englishSelectedPurposes = englishSelectedPurposes.subString(0, englishSelectedPurposes.length()-1);
                tpaRequest.put(englishApttusMultiPicklist, englishSelectedPurposes);
            }
            if(japaneseApttusMultiPicklist != '' && japaneseSelectedPurposes != ''){
                japaneseSelectedPurposes = japaneseSelectedPurposes.subString(0, japaneseSelectedPurposes.length()-1);
                tpaRequest.put(japaneseApttusMultiPicklist, japaneseSelectedPurposes);
            }
            if(frenchApttusMultiPicklist != '' && frenchSelectedPurposes != ''){
                frenchSelectedPurposes = frenchSelectedPurposes.subString(0, frenchSelectedPurposes.length()-1);
                tpaRequest.put(frenchApttusMultiPicklist, frenchSelectedPurposes);
            }
        }
        //------ Set Apptus TPA Purpose MultiPiclist Values end ----------//

        System.debug('FIne2...');

        if(vendorOrClient == VENDOR_CON && tpaRequest.Request_Type__c != 'renew' && tpaRequest.is_Bulk_TPA_Request__c != true){
            if(isOtherUseSelected){
                sendEmailDirectToClient(tpaRequest, 'Email Direct to Client message', bodyTextForOtherUse);
            }
            if(isOtherOfferingSelected) {
                String bodyText = '<table style="width:100%; border-collapse: collapse">' +  '<tr><th style="font-size:12px ;font-family:arial;border: 2px solid black;padding: 0 5px 0 5px;background-color:#0CB6F3">Country of Offering</th>' + '<th style="font-size:12px ;font-family:arial;border: 2px solid black;padding: 0 5px 0 5px;background-color:#0CB6F3">Category of Offering</th>' + '<th style="font-size:12px ;font-family:arial;border: 2px solid black;padding: 0 5px 0 5px;background-color:#0CB6F3">‘Offering of Other’</th></tr>';
                bodyText += bodyTextForOtherOffering;
                bodyText += '</table>' + '</br>';

                sendEmailDirectToClient(tpaRequest, 'Email Direct to Client Offering', bodyText);
            }
        }
        if(lstLocalized.size() == 2) {
            lstLocalized.clear();
            lstLocalized.add(obClientLocal);
            lstLocalized.add(obVendorLocal);
        } 
        else {
            lstLocalized.clear();
            lstLocalized.add(obClientLocal);
        }
        upsert lstLocalized;
        return obClientLocal;
    }*/

    public static void sendEmailDirectToClient(TPA_Request__c reqObj, String settingName, String bodyText){
        List<String> toAddress = new List<String>();
        String emailBody;
        String subjText;
        String offList = '';
        List<String> ccAddress = new List<String>();
        TPA_Settings__c tpaSettings = TPA_Settings__c.getOrgDefaults();
        if(reqObj.Client_Email__c != null){
            toAddress.add(reqObj.Client_Email__c);
        }
        if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
            toAddress.add(reqObj.Client_TPA_Representative_Email__c);
        }
        if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
            toAddress.add(reqObj.Owner.Email);
        }

        if(reqObj.TP_Processor_Email__c != null){
            ccAddress.add(reqObj.TP_Processor_Email__c);
        }
        if(settingName == 'Email Direct to Client Offering' || settingName == 'Email Client Confirmation Req'){
            if(reqObj.TPA_Request_Contacts__r != null && reqObj.TPA_Request_Contacts__r.size() > 0){
                for(TPA_Contact__c tpaContact : reqObj.TPA_Request_Contacts__r ){
                    if(tpaContact.Type__c == 'Additional Client Contact' && tpaContact.Email__c != null){
                        ccAddress.add(tpaContact.Email__c);
                    }
                }
            }
        }
        ccAddress = UTL_TPA_Multilingual.ccList(reqObj.Client_Address__r.TPAOtherEmailIds__c, ccAddress);
        String templateId = UTL_TPA_Multilingual.multilingualTemplateSettingsMap.get(settingName+'English').Translated_Template_Id__c;
        system.debug('template ID : ' + templateId);
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateId != '' && templateId != null){
            try {
                system.debug('templateID'+templateID);
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
                system.debug('in try for email send');
            } catch(Exception exp) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::SRV_TPA_TPARequest:::sendEmailDirectToClient:::', reqObj.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);    
            }
            String tempEmailBody = emailNotToSend.getHTMLBody();
            emailBody = tempEmailBody.replace('[content]', '<div style="font-size:13px;font-family:arial;">' + bodyText + '</div>');
            if(!specVendorOffNameList.isEmpty() && emailBody.contains('[relatednotificationofferings]')){
                for(String off: specVendorOffNameList){
                    offList += off + ',';
                }
                offList = offList.substring(0, offList.length() - 1);
                emailBody = emailBody.replace('[relatednotificationofferings]', '<div style="font-size:13px;font-family:arial;">' + offList + '</div>');
            }
            if(settingName == 'Email Client Confirmation Req'){
                String URL = tpaSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_ClientConfirmRequestedForm&id=' + reqObj.Id;
                emailBody = emailBody.replace('click here', '<a style ="color: #ED7D31;" href=' + URL + '>' + 'click here'+ '</a>');
            }
            subjText = emailNotToSend.getSubject();
            subjText = (isReminderForExpertAnalysisUseSelected ? 'Reminder: ' : '' ) + subjText;
        }
        /*addTPProcessorInitials = true;
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/
        sendEmailThroughWorkflow(toAddress, ccAddress,'SendEmail', null, reqObj.Id, null, subjText, FALSE, emailBody,TRUE,TRUE,reqObj);
        //addTPProcessorInitials = false;
    }

    public static void sendEmailToClientToNotifyAisleOff(TPA_Request__c reqObj,String settingName) {
        List<String> toAddress = new List<String>();
        String emailBody;
        String subjText;
        if(reqObj.Client_Email__c != null) {
            toAddress.add(reqObj.Client_Email__c);
        }
        if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
            toAddress.add(reqObj.Client_TPA_Representative_Email__c);
        }
        if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
            toAddress.add(reqObj.Owner.Email);
        }
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get(settingName+'English').Translated_Template_Id__c;
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateID != '' && templateID != null) {  
            try {
                system.debug('templateID'+templateID);
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
            } catch(Exception exp) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::SRV_TPA_TPARequest:::sendEmailToClientToNotifyAisleOff:::', reqObj.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);    
            }
            emailBody = emailNotToSend.getHTMLBody();
            subjText = emailNotToSend.getSubject();
        }

        /*addTPProcessorInitials = true;
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/
        sendEmailThroughWorkflow(toAddress, null, 'SendEmail', null, reqObj.Id, null, subjText, FALSE, emailBody, TRUE, TRUE, reqObj);
        //addTPProcessorInitials = false;
    }

    // public static void updateTPAContactsforClientAndVendorBoth() {
    //     Map<Id,Id> requestAgreementChildMap = new Map<Id,Id>();
    //     // get agreement object fieldnames
    //   //  List<String> agrContactFields = getCustomFieldNames(Agreement_Contact__c.getSObjectType());
    //     List<sObject> agreementChildToDelete = new List<sObject>();
    //     String value = '';
    //     // if( !create ){
    //     //     for( Agreement_Contact__c agreementContact : cpcAgreement.Agreement_Contacts__r ){
    //     //         system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'+agreementContact.Related_TPA_Contact__c);
    //     //         if( agreementContact.Related_TPA_Contact__c != null ){
    //     //             if(!requestAgreementChildMap.containsKey( agreementContact.Related_TPA_Contact__c )){
    //     //                 system.debug( 'agreementContact.Related_TPA_Contact__c--------------------------------------'+agreementContact.Related_TPA_Contact__c);
    //     //                 requestAgreementChildMap.put(agreementContact.Related_TPA_Contact__c,agreementContact.Id );
    //     //             }
    //     //         }else{
    //     //             system.debug( 'delete additional contract*****************' );
    //     //             agreementChildToDelete.add( agreementContact );
    //     //         }
    //     //     }
    //     // }

    //     // if( agreementChildToDelete.size() >0 ){
    //     //     delete agreementChildToDelete;
    //     // }

    
    // }

  

    public static boolean isDynamicNotificationRequiredForVendor(TPA_Request__c reqObj) {
        system.debug('in isDynamicNotificationRequiredForVendor');
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();
        Id reqVendorAccountId = reqObj.Service_Provider_Address__c;
        String GBVendorId = null;
        boolean isNotificationRequired = false;
        Id requestId = reqObj.id;
        List <TPA_Offering_Notification_Mapping__c> lstOffNotMapObj;
        Set<Id> masterPurposeIds = new Set<Id>();
        List<TPA_Use_Offering_Atypical_Combination__c> lstNewAtypicalRecordData = new List<TPA_Use_Offering_Atypical_Combination__c>();
        Set<Id> newOfferingNotificationIDs = new Set<Id>(); 
        Set<Id> currentOfferingNotificationIDs = new Set<Id>(); 
        Set<Id> oldOfferingNotificationIDs = new Set<Id>();
        Map<Id, TPA_Use_Offering_Atypical_Combination__c> existingOfferingNotificationMap = new Map<Id, TPA_Use_Offering_Atypical_Combination__c>();

        /**
         * Existing Records Map -> <Text Editor ID, record in which ID is used>
         *  - Used to Track all Common and Uncommon IDs with Current transaction 
         *  - Uncommon IDs from existing Data are removed at last
         */
        for(TPA_Use_Offering_Atypical_Combination__c record: reqObj.TPA_Use_Offering_Atypical_Combinations__r){
            existingOfferingNotificationMap.put(record.TPA_Offering_Notification_Record__c, record);
        }
        oldOfferingNotificationIDs = new Set<Id>(existingOfferingNotificationMap.keySet());
      
        List<TPA_Purpose__c> TPAPurposetList = getPurposesList(requestId);
        
        if(allPurposeIds == null || allPurposeIds.size() == 0 || transactionalPurposeIds == null || transactionalPurposeIds.size() == 0) {
            for(TPA_Purpose__c purposeObj :TPAPurposetList){
                masterPurposeIds.add(purposeObj.Purpose__r.Id);
                transactionalPurposeIds.add(purposeObj.Id);
            }
            allPurposeIds = masterPurposeIds;
        } 
        system.debug('transactionalPurposeIds::' + transactionalPurposeIds);

        if(tpaOffNotRulesForOffNotiMap == null || tpaOffNotRulesForOffNotiMap.size() == 0) {
            getdynamicOffNotificationMappingMaps(reqVendorAccountId);
        }
        if(UTL_TPA.GlobalBrandingVendorId != null ) {
            GBVendorId = UTL_TPA.GlobalBrandingVendorId + '' ;
        }

        String useID = '';   String countryName = '';  String priOffID = ''; String secOffID = ''; String vendorAccID = '';
        vendorAccID = reqVendorAccountId + '';
        
        for(TPA_Data_Asset__c dataAssetObj : tpaDataAssetForDynamicNotiList(transactionalPurposeIds)) {
            useID = dataAssetObj.Purpose__r.Purpose__r.id + '';
            priOffID = dataAssetObj.Data_Asset__r.id + '';
            secOffID = '';
            countryName = dataAssetObj.Data_Asset__r.BU__c;
            //system.debug(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':');
            lstOffNotMapObj = new list <TPA_Offering_Notification_Mapping__c>();
            if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':'));
                system.debug('d1 with GBVendorId:' + countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':');
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':'));
                system.debug('d1' + countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':');
            }
            else if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + GBVendorId + '::' + priOffID + ':') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + GBVendorId + '::' + priOffID + ':'));
                system.debug('d2 with GBVendorId:');
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + vendorAccID + '::' + priOffID + ':') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + vendorAccID + '::' + priOffID + ':'));
                system.debug('d2');
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + '::' + useID +':' + priOffID + ':') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + '::' + useID +':' + priOffID + ':'));
                system.debug('d3');
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':::' + priOffID + ':') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':::' + priOffID + ':'));
                system.debug('d4');
            }
            for(TPA_Secondary_Data_Asset__c secdataAssetObj : dataAssetObj.TPA_Secondary_Data_Assets__r){
                secOffID = secdataAssetObj.IMS_Secondary_Data_Asset__r.id + '';
                if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':' + secOffID) ) {
                    lstOffNotMapObj.addAll(tpaOffNotRulesForOffNotiMap.get(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':' + secOffID));
                    system.debug('s1 with GBVendor');
                }
                else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':' + secOffID) ) {
                    lstOffNotMapObj.addAll(tpaOffNotRulesForOffNotiMap.get(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':' + secOffID));
					system.debug('s1 with Vendor');
				}
				else if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + GBVendorId + '::' + priOffID + ':' + secOffID)) {
					lstOffNotMapObj.addAll(tpaOffNotRulesForOffNotiMap.get(countryName + ':' + GBVendorId + '::' + priOffID + ':' + secOffID));
					system.debug('s2 with GBVendor');
				}
				else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + vendorAccID + '::' + priOffID + ':' + secOffID)) {
					lstOffNotMapObj.addAll(tpaOffNotRulesForOffNotiMap.get(countryName + ':' + vendorAccID + '::' + priOffID + ':' + secOffID));
					system.debug('s2 with Vendor');
				}
				else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + '::' + useID +':' + priOffID + ':' + secOffID)) {
					lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + '::' + useID +':' + priOffID + ':' + secOffID));
                    system.debug('s3');
                }
                else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':::' + priOffID + ':' + secOffID)) {
                    lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':::' + priOffID + ':' + secOffID));
                    system.debug('s4');
                }
            }
            if(lstOffNotMapObj != null && lstOffNotMapObj.size () > 0) {
                for(TPA_Offering_Notification_Mapping__c OffMapObj:lstOffNotMapObj) {
                    dynamicOfferingsNotificationListForVendor.add(OffMapObj);
                }
            }
        }

        priOffID = '';
        secOffID = '';
        for(TPA_Purpose__c purposeObj : TPAPurposetList) { 
            useID = purposeObj.Purpose__r.id + '';
            countryName = purposeObj.BU__c;
            lstOffNotMapObj = new list <TPA_Offering_Notification_Mapping__c>();
            if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + GBVendorId + ':' + useID +'::') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + GBVendorId + ':' + useID +'::'));
                system.debug('1 with GBVendorId');
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + vendorAccID + ':' + useID +'::') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + vendorAccID + ':' + useID +'::'));
                system.debug('1');
            }
            else if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey('ALL' + ':' + GBVendorId + ':' + useID +'::') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get('ALL' + ':' + GBVendorId + ':' + useID +'::'));
                system.debug('2 with GBVendorId');
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey('ALL' + ':' + vendorAccID + ':' + useID +'::') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get('ALL' + ':' + vendorAccID + ':' + useID +'::'));
                system.debug('2');
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + '::' + useID +'::') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + '::' + useID +'::'));
                system.debug('3');
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey('ALL' + '::' + useID +'::') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get('ALL' + '::' + useID +'::'));
                system.debug('4');
            }
            if(lstOffNotMapObj != null && lstOffNotMapObj.size () > 0) {
                for(TPA_Offering_Notification_Mapping__c OffMapObj:lstOffNotMapObj) {
                    dynamicOfferingsNotificationListForVendor.add(OffMapObj);
                }
            }
        }

        String keyOfVendorOnly = reqVendorAccountId + ':::';
        if(tpaOffNotRulesForOffNotiMap.containsKey(keyOfVendorOnly)) {
            lstOffNotMapObj = tpaOffNotRulesForOffNotiMap.get(keyOfVendorOnly);
            if(lstOffNotMapObj != null && lstOffNotMapObj.size () > 0) {
                for(TPA_Offering_Notification_Mapping__c OffMapObj:lstOffNotMapObj){
                    if(OffMapObj.Offering_Notifications__c != null) {
                        dynamicOfferingsNotificationListForVendor.add(OffMapObj);
                    }
                }
            }
        }
        
        for(TPA_Offering_Notification_Mapping__c offeringNotObj : dynamicOfferingsNotificationListForVendor){
            // Filtering New and Common Records
            if(offeringNotObj.Offering_Notifications__c != null){
                if(!oldOfferingNotificationIDs.contains(offeringNotObj.Offering_Notifications__c)){
                    newOfferingNotificationIDs.add(offeringNotObj.Offering_Notifications__c);
                }else{
                    existingOfferingNotificationMap.remove(offeringNotObj.Offering_Notifications__c);
                }
                currentOfferingNotificationIDs.add(offeringNotObj.Offering_Notifications__c);
            }
            if(offeringNotObj.Process_Execution_Mode__c == 'Direct to Client') {
                isDirectToClientExeMode = true;
            }
            else if(offeringNotObj.Process_Execution_Mode__c == Label.TPA_IQVIA_Sales_Keyword || offeringNotObj.Process_Execution_Mode__c == 'QuintilesIMS Sales') { 
                isQuintilesIMSSalesExeMode = true;
            }
            // if(isOnlyLAADResponseReq && !(offeringNotObj.Process_Execution_Mode__c == 'Direct to Client' && offeringNotObj.Primary_Data_Asset_Name__c != null && offeringNotObj.Primary_Data_Asset_Name__c.equalsIgnoreCase('LAAD - Longitudinal Access and Adjudication Data'))) {//will review, do we still need laad
            //     isOnlyLAADResponseReq = false;
            // }
        }

        System.debug('existingOfferingNotificationMap After Filtering: ' + existingOfferingNotificationMap);
        
        for(Id recordID : newOfferingNotificationIDs){
            lstNewAtypicalRecordData.add(new TPA_Use_Offering_Atypical_Combination__c(Type__c = 'Offering Notification Record', TPA_Request__c = requestId, TPA_Offering_Notification_Record__c = recordId));
        }
        try{
            if(existingOfferingNotificationMap.size() > 0)
                delete existingOfferingNotificationMap.values();
            if(lstNewAtypicalRecordData.size() > 0)
                insert lstNewAtypicalRecordData;

        }catch(Exception ex){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SRV_TPA_TPARequest:::isDynamicNotificationRequiredForVendor', requestId != null ? requestId : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
        system.debug('dynamicOfferingsNotificationListForVendor: ' +dynamicOfferingsNotificationListForVendor);
        system.debug('isDirectToClientExeMode:'+isDirectToClientExeMode);
        system.debug('isQuintilesIMSSalesExeMode:'+isQuintilesIMSSalesExeMode);
        
        if(((oldOfferingNotificationIDs.equals(currentOfferingNotificationIDs)) && !reqObj.Is_VSN_Acknowlege_By_Client__c)) {
            isNotificationRequired = false;
        }else{
            isNotificationRequired = true;
        }
        return isNotificationRequired;
    }

    public static List<TPA_Offering_Notification_Mapping__c> getOffNotMappingLst(Id vedorID) {
        if(offNotMappingLst == null) {
            system.debug('allPurposeIds' + allPurposeIds);
            system.debug('vedorID' + vedorID);

            offNotMappingLst = new List <TPA_Offering_Notification_Mapping__c>();
            Set<TPA_Offering_Notification_Mapping__c> tempoffNotMappingLst = new Set<TPA_Offering_Notification_Mapping__c>();
            offNotMappingLst = [SELECT Id, Name, Process_Execution_Mode__c, IsActive__c, Country__c, Offering_Country_Name__c, IMS_Primary_Data_Asset__r.Asset_Name__c, IMS_Primary_Data_Asset__r.id, OfferingName__c, Primary_Data_Asset_Name__c, IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c,IMS_Secondary_Data_Asset__r.id,Secondary_Data_Asset_Name__c, IMS_TPA_Purpose__r.Primary_Purpose_Name__c, Offering_Notifications__r.Page_Name__c, Offering_Notifications__r.Content__c, IMS_TPA_Purpose__r.id, Purpose_Name__c, TLLA_Additional_Terms__r.Page_Name__c, TLLA_Additional_Terms__r.id, TLLA_Additional_Terms__r.Content__c, OneKey_Countries__c, Is_Applicable_for_All_OneKey_Countries__c, (select id, Vendor_Account_Address__c, Vendor_Account_Address__r.id from TPA_Off_Notification_Account_Mapping__r where Vendor_Account_Address__r.id = :vedorID) FROM TPA_Offering_Notification_Mapping__c where IsActive__c = true AND (Purpose_Name__c = 'ALL' OR IMS_TPA_Purpose__c in : allPurposeIds) AND (id in (select TPA_Offering_Notification_Mapping_Rule__c from TPA_Off_Notification_Account_Mapping__c where Vendor_Account_Address__r.id = :vedorID))];

            offNotMappingLst.addALL([SELECT Id, Name, Process_Execution_Mode__c, IsActive__c, Country__c, Offering_Country_Name__c, IMS_Primary_Data_Asset__r.Asset_Name__c, IMS_Primary_Data_Asset__r.id,OfferingName__c,Primary_Data_Asset_Name__c, IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c, IMS_Secondary_Data_Asset__r.id, Secondary_Data_Asset_Name__c, IMS_TPA_Purpose__r.Primary_Purpose_Name__c, Offering_Notifications__r.Page_Name__c, Offering_Notifications__r.Content__c, IMS_TPA_Purpose__r.id, Purpose_Name__c, TLLA_Additional_Terms__r.Page_Name__c, TLLA_Additional_Terms__r.Content__c,TLLA_Additional_Terms__r.id, OneKey_Countries__c, Is_Applicable_for_All_OneKey_Countries__c, (select id, Vendor_Account_Address__c, Vendor_Account_Address__r.id from TPA_Off_Notification_Account_Mapping__r where Vendor_Account_Address__r.id = :vedorID) FROM TPA_Offering_Notification_Mapping__c where IsActive__c = true AND (Purpose_Name__c = 'ALL' OR IMS_TPA_Purpose__c in : allPurposeIds) AND Is_Vendor_Specific_Rule__c = false]); // will review and merge with above query

            tempoffNotMappingLst.addAll(offNotMappingLst); 
            offNotMappingLst.clear();
            offNotMappingLst.addALL(tempoffNotMappingLst);
        }
        system.debug('offNotMappingLst' + offNotMappingLst);
        return offNotMappingLst; 
    }

    public static void getdynamicOffNotificationMappingMaps(Id vedorID) {
        system.debug('Inside SRV_TPA_TPARequest --> getdynamicOffNotificationMappingMaps');
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();

        if(dynamicOffNotificationMappingMap == null || dynamicOffNotificationMappingWithCountryMap == null || tpaOffNotRulesForOffNotiMap == null) {
            dynamicOffNotificationMappingMap = new Map<String, TPA_Offering_Notification_Mapping__c>();
            dynamicOffNotificationMappingWithCountryMap = new Map<String, List<TPA_Offering_Notification_Mapping__c>>();
            tpaOffNotRulesForOffNotiMap = new Map<String, List<TPA_Offering_Notification_Mapping__c>>();

            String priOffId = '';  
            String secOffId =  ''; 
            String vendorAccId = ''; 
            String useId = ''; 
            String key = '';

            getOffNotMappingLst(vedorID);
            CNT_TPA_RequestSubmissionForm.getLimitsMessage();

            for(TPA_Offering_Notification_Mapping__c mapObj: offNotMappingLst) { 
                priOffId = ''; secOffId =  ''; vendorAccId = ''; useId = '';
                
                if(mapObj.IMS_Primary_Data_Asset__c != null) {
                    priOffId = mapObj.IMS_Primary_Data_Asset__r.id + '' ;
                }
                if(mapObj.IMS_Secondary_Data_Asset__c != null) {
                    secOffId = mapObj.IMS_Secondary_Data_Asset__r.id + '';
                }
                if(mapObj.IMS_TPA_Purpose__c != null) {
                    useId = mapObj.IMS_TPA_Purpose__r.id + '';
                }

                list<TPA_Offering_Notification_Mapping__c> settlist ;

                if(mapObj.TPA_Off_Notification_Account_Mapping__r.size() > 0 ) {
                    system.debug('in first IF: ');
                    for(TPA_Off_Notification_Account_Mapping__c accMapObj : mapObj.TPA_Off_Notification_Account_Mapping__r) {
                        system.debug('accMapObj.Vendor_Account_Address__c: ' + accMapObj.Vendor_Account_Address__c);

                        if( vedorID == accMapObj.Vendor_Account_Address__c || (UTL_TPA.GlobalBrandingVendorId != null && UTL_TPA.GlobalBrandingVendorId == accMapObj.Vendor_Account_Address__c)) {
                            vendorAccId = accMapObj.Vendor_Account_Address__c + ''; 

                            if((mapObj.OneKey_Countries__c != null && mapObj.OneKey_Countries__c != '') || mapObj.Is_Applicable_for_All_OneKey_Countries__c) {
                                List<String> countries = new List<String>();
                                if(mapObj.Is_Applicable_for_All_OneKey_Countries__c) {
                                    countries.addAll(MapCountrywithOfferingId.keySet());
                                }
                                else if(mapObj.OneKey_Countries__c != null && mapObj.OneKey_Countries__c != '') {
                                    countries = mapObj.OneKey_Countries__c.split(';');
                                    countries.add(mapObj.Country__c);
                                }

                                for(String OneKeyCountry : countries) {
                                    priOffId = MapCountrywithOfferingId.get(OneKeyCountry);
                                    key =  OneKeyCountry + ':' + vendorAccId + ':' + useId + ':'+ priOffId + ':' + secOffId;

                                    dynamicOffNotificationMappingMap.put(vendorAccId + ':' + useId + ':'+ priOffId + ':' + secOffId, mapObj);

                                    if(mapObj.TLLA_Additional_Terms__c != null) {
                                        if(!dynamicOffNotificationMappingWithCountryMap.containsKey(key)) {
                                            dynamicOffNotificationMappingWithCountryMap.put(key, new list<TPA_Offering_Notification_Mapping__c>{mapObj});
                                        } else {
                                            dynamicOffNotificationMappingWithCountryMap.get(key).add(mapObj);
                                        }
                                    }
                                    
                                    if(mapObj.Offering_Notifications__c != null) {
                                        if(!tpaOffNotRulesForOffNotiMap.containsKey(key)) {
                                            tpaOffNotRulesForOffNotiMap.put(key, new list<TPA_Offering_Notification_Mapping__c>{mapObj});
                                        } else {
                                            tpaOffNotRulesForOffNotiMap.get(key).add(mapObj);
                                        }
                                    }
                                }
                            }
                            else if(mapObj.Country__c != null ) {
                                key =  mapObj.Country__c+ ':' + vendorAccId + ':' + useId + ':'+ priOffId + ':' + secOffId;

                                dynamicOffNotificationMappingMap.put(vendorAccId + ':' + useId + ':'+ priOffId + ':' + secOffId, mapObj);

                                if(mapObj.TLLA_Additional_Terms__c != null){
                                    if(!dynamicOffNotificationMappingWithCountryMap.containsKey(key)) {
                                        dynamicOffNotificationMappingWithCountryMap.put(key, new list<TPA_Offering_Notification_Mapping__c>{mapObj});
                                    } else {
                                        dynamicOffNotificationMappingWithCountryMap.get(key).add(mapObj);
                                    }
                                }
                                
                                if(mapObj.Offering_Notifications__c != null){
                                    if(!tpaOffNotRulesForOffNotiMap.containsKey(key)) {
                                        tpaOffNotRulesForOffNotiMap.put(key, new list<TPA_Offering_Notification_Mapping__c>{mapObj});
                                    } else {
                                        tpaOffNotRulesForOffNotiMap.get(key).add(mapObj);
                                    }
                                }
                            }                            
                        }
                    }
                } 
                else {
                    system.debug('in else condition: ');
                    system.debug('mapObj ' + mapObj.Id);
                    if((mapObj.OneKey_Countries__c != null && mapObj.OneKey_Countries__c != '') || mapObj.Is_Applicable_for_All_OneKey_Countries__c) {
                        List<String> countries = new List<String>();
                        if(mapObj.Is_Applicable_for_All_OneKey_Countries__c) {
                            countries.addAll(MapCountrywithOfferingId.keySet());
                        }
                        else if(mapObj.OneKey_Countries__c != null && mapObj.OneKey_Countries__c != '') {
                            countries = mapObj.OneKey_Countries__c.split(';');
                            countries.add(mapObj.Country__c);
                        }
                        for(String OneKeyCountry : countries){
                            priOffId = MapCountrywithOfferingId.get(OneKeyCountry);
                            key =  OneKeyCountry+ ':' + '' + ':' + useId + ':'+ priOffId + ':' + secOffId;
                            dynamicOffNotificationMappingMap.put(vendorAccId + ':' + useId + ':'+ priOffId + ':' + secOffId, mapObj);
                            if(mapObj.TLLA_Additional_Terms__c != null) {
                                if(!dynamicOffNotificationMappingWithCountryMap.containsKey(key)) {
                                    dynamicOffNotificationMappingWithCountryMap.put(key, new list<TPA_Offering_Notification_Mapping__c>{mapObj});
                                }
                                else {
                                    dynamicOffNotificationMappingWithCountryMap.get(key).add(mapObj);
                                }
                            }
                            if(mapObj.Offering_Notifications__c != null) {
                                if(!tpaOffNotRulesForOffNotiMap.containsKey(key)) {
                                    tpaOffNotRulesForOffNotiMap.put(key, new list<TPA_Offering_Notification_Mapping__c>{mapObj});
                                }
                                else {
                                    tpaOffNotRulesForOffNotiMap.get(key).add(mapObj);
                                }
                            }
                        }
                    }
                    else if(mapObj.Country__c != null){
                        key =  mapObj.Country__c+ ':' + '' + ':' + useId + ':'+ priOffId + ':' + secOffId;
                        dynamicOffNotificationMappingMap.put(vendorAccId + ':' + useId + ':'+ priOffId + ':' + secOffId, mapObj);
                        if(mapObj.TLLA_Additional_Terms__c != null) {
                            if(!dynamicOffNotificationMappingWithCountryMap.containsKey(key)) {
                                dynamicOffNotificationMappingWithCountryMap.put(key, new list<TPA_Offering_Notification_Mapping__c>{mapObj});
                            }
                            else {
                                dynamicOffNotificationMappingWithCountryMap.get(key).add(mapObj);
                            }
                        }
                        if(mapObj.Offering_Notifications__c != null) {
                            if(!tpaOffNotRulesForOffNotiMap.containsKey(key)) {
                                tpaOffNotRulesForOffNotiMap.put(key, new list<TPA_Offering_Notification_Mapping__c>{mapObj});
                            }
                            else {
                                tpaOffNotRulesForOffNotiMap.get(key).add(mapObj);
                            }
                        }                        
                    }                    
                }
            }
            system.debug('tpaOffNotRulesForOffNotiMap: '+tpaOffNotRulesForOffNotiMap);
        }
    }


    

    /*private static void setAgreementFieldsForDataAsset(TPA_Data_Asset__c dataAsset) {
        if(dataAsset.Is_IMS_AGProduct__c) {
            is_IMS_AGProduct  = dataAsset.Is_IMS_AGProduct__c;
        }
        if(dataAsset.Asset_Name__c == 'MIDAS') {
            hasMidas  = true;
        }
        if(dataAsset.Asset_Name__c == 'Managed Care Workbook - New View' || dataAsset.Asset_Name__c == 'Managed Care Workbook - PBM Plans' ) {
            hasManagedCareWorkBook = true;
        }
    }

    private static void updateAgreementFieldsForDataAsset() {
        tpaRequest.Has_IMS_AG_Product__c = is_IMS_AGProduct ;
        tpaRequest.Has_MIDAS__c = hasMidas ;
        tpaRequest.Manage_Care_For_Template__c = hasManagedCareWorkBook ;
    }*/

    public static List<TPA_Request_Localized__c> localizedRecords;
    public static List<TPA_Request_Localized__c> getLocalizedRequests(string tpaReqId) {
        if(localizedRecords == null)
            localizedRecords = [SELECT ID, Name, Record_Localized_For__c, TPA_Request__c,
                                Authorized_Signer_Email__c, Authorized_Signer_First_Name__c, Authorized_Signer_Last_Name__c,
                                Authorized_Signer_Title__c, Client_Contact_Territory__c, Client_Project_Name__c, Client_Region__c,
                                Region__c, Data_Asset_List__c, Data_Delivered_By__c, Data_Provided_By__c, Employee_Accessing_Data_Location__c,
                                Employee_Accessing_Data_Location_Values__c, Frequency_Of_Delivery__c, Frequency_of_Delivery_Other__c,
                                FrequencyOfDeliveryToServiceProvider__c, FrequencyOfDeliveryToSP_Other__c, IMS_Data_Country_Location__c,
                                IMS_Data_Country_Location_Values__c, IMS_Data_Physical_Location__c, IMS_Data_Physical_Location_Other__c,
                                Language__c, List_Of_Uses__c, Offerings_With_Category__c, Project_include_directToPrescriberComm__c,
                                PurposeWithDataAsset__c, Secondary_Client_Contact_Territory__c,
                                Secondary_Location_Required__c, Request_Status__c, Total_Deliveries__c,
                                U_S_Prescriber_Level_Data_Outside_US__c, Vendor_Billing_Mailing_City__c, Vendor_Billing_Mailing_Country__c,
                                Vendor_Billing_Mailing_State_Province__c, Vendor_Billing_Mailing_Street__c, Vendor_Billing_Mailing_Zip_Post_Code__c,
                                Vendor_Company_Name__c, Vendor_e_mail__c, Vendor_Contact_Email_Client__c, Vendor_Contact_First_Name_Client__c,
                                Vendor_Contact_Last_Name__c, Vendor_Contact_Last_Name_Client__c, Vendor_Contact_Phone__c, Vendor_Contact_Telephone_Client__c,
                                Vendor_Contact_Title__c, Vendor_Employee_Country_AMA__c, Vendor_First_Name__c, Vendor_Phone__c,
                                Vendor_Website__c
                                FROM TPA_Request_Localized__c WHERE TPA_Request__c =: tpaReqId];
        return localizedRecords;
    }

    public static List<TPA_Request__c> DDNAckPendingRecords;
    public static void getDDNAckPendingRequests(string vendorId){
        if(DDNAckPendingRecords == null){
            DDNAckPendingRecords = UTL_TPA.getDDNAckPendingRequests(vendorId);
        }
    }

    public static Id GlobalBrandingVendorId; //will remove
    public static void getGlobalBrandingVendorId(TPA_Request__c reqObj){
        if(GlobalBrandingVendorId == null){
            GlobalBrandingVendorId = UTL_TPA.getGlobalBrandingVendorId(reqObj);
        }
    }

    public static List<IMS_Master_Legal_Entity__c> IMSMasterLegalEntityListPrvt;
    public static List<IMS_Master_Legal_Entity__c> IMSMasterLegalEntityList()
    {
        if(IMSMasterLegalEntityListPrvt == null)
        {
            IMSMasterLegalEntityListPrvt = [Select Id, Name, Legal_Entity_Name_for_TLLA__c, IMS_Entity_Address__c, Location_of_Governing_Law__c from IMS_Master_Legal_Entity__c];
        }
        return IMSMasterLegalEntityListPrvt;
    }

    public static TPA_Request__c getRequestInfo(ID requestId) {
        TPA_Request__c req = [Select Vendor_e_mail__c,
                                    Generate_AMA_Contract__c,
                                    Always_approved_Use_Offering_Combination__c,
                                    Are_Banner_Ads_Selected__c,
                                    Vendor_Website__c,
                                    Agreement_Effective_Date__c, 
                                    Vendor_Phone__c,
                                    Client_Off_Notification_Ack_Date__c,
                                    Vendor_Off_Notification_Ack_Date__c,
                                    is_Addendum_Attachment_Required__c, 
                                    Client_Confirmation_Requested_Response__c,
                                    Client_Confirmation_Req_Response_Date__c,
                                    Client_Confirmation_Req_Form_Sent_Date__c,
                                    Agreement_Name__c,
                                    Renewed_Type__c,
		                            Client_TPA_Representative_Email__c,
		                            Client_TPA_Representative_Name__c,
		                            Client_TPA_Representative_Title__c,
		                            is_Client_Representative__c,
                                    Renewed_As__r.Name,
                                    Is_VSN_Acknowlege_By_Client__c,
                                    Is_South_Africa_Sub_Off__c,
                                    Is_Vendor_Name_Contains_Edith__c,
                              		is_Specific_Vendors_LAAD_Off__c,
                                    Is_Veeva_Use_CRM_Off_OneKey__c,
                                    // is_Veeva_Use_CRM__c,
                                    Is_Veeva_Use_CRM_SubNational_Off__c,
                                    Ack_Understanding_of_Prescriber_Data__c,
                              		is_Specific_Vendors_APLD_Off__c,
                              		is_Specific_Vendors_Long_Prescr_Data__c,
                              		is_Specific_Vendors_Medical_Claims_Data__c,
                                    is_20_or_more_Offering_Present__c,
                                    is_50_or_more_Offering_Present__c,
                                    Renewed_As__r.Is_Partially_Renewed__c,
                                    Renewed_As__r.Partially_Renewed_Date__c,
                                    Parent_Request__r.Renewed_Type__c,
                                    Renewed_As__r.Request_Status__c,
                                    Is_Partially_Renewed__c,
                                    Partially_Renewed_Date__c,
                                    Client_Request_Submission__c,
                                    Client_Email__c,
                                    Owner.Email,
                                    Owner.Type,
                                    Owner.Name,
                                    Vendor_App_Submitted__c,
                                    is_Bulk_TPA_Request__c,
                                    isClientOnComplianceHold__c,
                                    isVendorOnComplianceHold__c,
                                    Parent_Request__r.isClientOnComplianceHold__c,
                                    Parent_Request__r.isVendorOnComplianceHold__c,
                                    TPA_Authorised_Signer__c,
                                    Vendor_Last_Name__c,
                                    Vendor_First_Name__c,
                                    Service_Provider_f__c,
                                    Client_First_Name__c,
                                    Vendor_Contact_e_mail__c,
                                    Service_Provider_Contact_f__c,
                                    Is_New_Notification_Sent__c,
                                    Vendor_Contact_Last_Name__c,
                                    Vendor_Contact_Title__c,
                                    Vendor_Contact_Tilte_Other__c,
                                    Vendor_Contact_State_Province__c,
                                    Vendor_Contact_Phone__c,
                                    Vendor_Contact_Country__c,
                                    Vendor_Contact_Billing_Zip_Code__c,
                                    Vendor_Contact_Billing_Street__c,
                                    Vendor_Contact_Billing_City__c,
                                    Secondary_Location_Required__c,
                                    Secondary_Client_Contact_Territory__c,//added by Govind under Er-2689
                                    Vendor_Company_Name__c,
                                    Global_Brand_Company_Name__c,
                                    Is_ATypical_Combination_Present__c,//Added by Govind under ER-3045
                                    Vendor_Billing_Mailing_Street__c,
                                    Vendor_Billing_Mailing_State_Province__c,
                                    Vendor_Billing_Mailing_Country__c,
                                    Vendor_Billing_Mailing_City__c,
                                    Vendor_Billing_Mailing_Zip_Post_Code__c,
                                    Authorized_Signer_First_Name__c,
                                    Authorized_Signer_Last_Name__c,
                                    Authorized_Signer_Title__c,
                                    Authorized_Signer_Email__c,
                                    Vendor_Compliance_First_Name__c, //Added by Shaik
                                    Vendor_Compliance_Last_Name__c, //Added by Shaik
                                    Vendor_Compliance_Job_Title__c, //Added by Shaik
                                    Vendor_Compliance_Email__c, //Added by Shaik
                                    Vendor_Compliance_Street_Address__c, //Added by Shaik
                                    Vendor_Compliance_City__c, //Added by Shaik
                                    Vendor_Compliance_State__c, //Added by Shaik
                                    Vendor_Compliance_Country__c, //Added by Shaik
                                    Vendor_Compliance_Zip_Code__c, //Added by Shaik
                                    Total_NumberOf_Deliverables__c,
                                    Is_CPC_Renewal_Notice_Sent__c,
                                    Is_CPC_Expiration_Notice_Sent__c,
                                    Is_CPC_Post_Expiration_Notice_Sent__c,
                                    CPC_Renewal_Notice_Sent_Last_Date__c,
                                    CPC_Expiration_Notice_Sent_Last_Date__c,
                                    CPC_Expiration_Postnotice_Sent_Last_Date__c,
                                    TPA_Assigned_TP_Processor__c,
                                    TPA_Assigned_TP_Processor__r.Name,
                                    TPA_Assigned_TP_Processor__r.Initials__c,
                                    TPA_Assigned_TP_Processor__r.Is_Active__c,
                              	    Co_Assigned_Global_TP_Processor__c,
                              	    Co_Assigned_Global_TP_Processor__r.Is_Active__c,
                              	    Co_Assigned_Global_TP_Processor__r.Initials__c,
                                    Pending_Acknowledgements__c,
                                    Is_Exhibit_Required__c,
                                    Total_No_of_Deliverables__c,
                                    Total_Deliveries__c,
                                    Total_Selected_Uses__c,
                                    ThirdParty_Access_Measures__c,
                                    ThirdParty_Access_Measures_Other__c,
                                    ThirdPartySubmissionDelayReason__c,
                                    ThirdPartySubmissionApproved__c,
                                    Therapy_Areas__c,
                                    TPA_Responsible_Party_Contact_Email__c,
                                    TPA_Request_Marked_as__c,
                                    //TPA_Portal_User_Inserted__c,
                                    TPA_Client_Confirming_Contact_Email__c,
                                    TPA_Approve_Reject_Comments__c,
                                    TPA_Approval_Queue_Response_Values__c,
                                    TPA_Approval_Queue_Response_Value__c,
                                    TPA_Approval_Queue_Request_Values__c,
                                    //TPA_Account_Name__c,
                                    TPASiteURL__c,
                                    TPASiteSecurityCode__c,
                                    TPASiteSPRequestLink__c,
                                    TPASiteRequestCompletedBySubmitter__c,
                                    TPASiteRequestCompletedByServiceProvider__c,
                                    TPASiteRequestCompletedByApprover__c,
                                    TPASiteClientRequestLink__c,
                                    TPASiteClientAckRequestLink__c,
                                    SystemModstamp,
                                    Status__c,
                                    Status_Category__c,
                                    Service_Provider_Address__c,
                                    Service_Provider_Contact__c,
                                    SP_Collecting_Response_Data__c,
                                    SPResources_At_ClinetLocation__c,
                                    Responsible_Party_Contact__c,
                                    ResponsiblePartySameAsClientContact__c,
                                    Service_Provider_Address__r.Parent_Vendor_Name__c, 
                                    Service_Provider_Address__r.Primary_Vendor_Address__c,
                                    Service_Provider_Address__r.Parent_Vendor_Name__r.Name, 
                                    Service_Provider_Address__r.Vendor_Registration_Number__c, //Added by C.P.Pandey under Issue-6828
                                    Service_Provider_Address__r.AMA_Database_Licensee__c, //Added by Sunny Bansal under ER-2261
                                    Client_Address__r.AMA_Special_Handling__c, // added by Supriya Johari under ER-4123
                                    Service_Provider_Address__r.AMA_Special_Handling__c, // added by Supriya Johari under ER-4123
                                    Vendor_Registration_Number__c, //Added by C.P.Pandey Vendor Registration Number ER-1558 (Sprint-5)
                                    Is_Potential_Vendor_Case__c, //Added by C.P.Pandey under ER-1717
                                    Vendor_Contact_First_Name_Client__c, //Added by C.P.Pandey under ER-1799
                                    Vendor_Contact_Last_Name_Client__c, 
                                    Vendor_Contact_Telephone_Client__c, 
                                    Vendor_Contact_Email_Client__c, 
                                    Is_Client_Submitted_Request__c,
                                    TPA_Control_Number__c, 
                                    Renewed_As__c,
                                    Renewed_On__c,
                                    Region__c, 
                                    Competitive_Service_to_IMS_Offerings__c,
                                    Competitive_Service_to_IMS_Offerings_2__c,
                                    Competitive_Service_to_IMS_Offerings_3__c,
                                    Is_APLD_Selected__c, 
                                    Is_RWE_Selected__c, 
                                    Total_TherapeuticAreas__c, 
                                    OwnerId,
                                    Name,
                                    Manual_Trigger_Reasons__c, //Added by Sunny Bansal under ER-2101
                                    Midas_Statistics_Other__c,
                                    Midas_Level_of_Detail__c,
                                    LastModifiedDate,
                                    LastModifiedById,
                                    LastActivityDate,
                                    Is_Submitted__c,
                                    Is_Renewal__c,
                                    IsDeleted,
                                    Id,
                                    IMSSoftware__c,
                                    Frequency_of_Delivery_Other__c,
                                    Frequency_Of_Delivery__c,
                                    FrequencyOfDeliveryToServiceProvider__c,
                                    FrequencyOfDeliveryToSP_Other__c,
                                    Employ_SubContractors__c,
                                    Employ_SubContractors_VendorResponse__c,
                                    Date_IMS_Receipt_Recent__c,
                                    Date_IMS_Receipt_Initial__c,
                                    Data_Provided_By__c,
                                    Data_Access_Start_Date__c,
                                    Data_Access_End_Date__c,
                                    TP_Processor_Email__c,//added by Govind issue 6291
                                    TPA_Processor_Contact__r.Name,
                                    isVendorSubmitted__c,
                                    LastAction__c,
                                    Data_Period_Start_Date__c,
                                    Data_Period_End_Date__c,
                                    TP_Processor_Name__c,
                                    CurrencyIsoCode,
                                    CreatedDate,
                                    CreatedById,
                                    CopyAdditionalContactOnTransactions__c,
                                    Client_Address__c,
                                    Client_Address__r.Name, 
                                    Client_Address__r.TPAOtherEmailIds__c, 
                                    Client_Address__r.City__c, 
                                    Client_Address__r.State__c, 
                                    Client_Address__r.Country__c,   
                                    ClientContact__r.Client_Contact_Territory__c, // added by sumita ER 1074
                                    Client_Contact_Territory__c,// added by sumita ER 1074
                                    Client_Company_Name_Address__c,
                                    Client_Approved__c,
                                    ClientContact__c,
                                    Client_Project_Name__c,
                                    Request_Status__c,//Added by Babita on 18 Feb 2015 under ER-1558 Vendor Validation
                                    ClientContact__r.Name, //Added by babita on 31 jan 2015 issue-05927
                                    ClientContact__r.Salutation, //Added by babita on 31 jan 2015 issue-05927
                                    ClientContact__r.Title, //Added by Neetu Bansal under ER-1810
                                    ClientContact__r.Phone, //Added by babita on 31 jan 2015 issue-05927
                                    ClientContact__r.Email, //Added by babita on 31 jan 2015 issue-05927
                                    Parent_Request__r.Name,//Added by Babita On 12 Feb 2015 Issue-06297
                                    Parent_Request__r.Renewed_As__c,//Added by Govind under ER-1736
                                    Parent_Request__c,//Added by C.P under CR-12401
                                    Parent_Request__r.Is_Renewed__c,//Added by C.P under CR-12401
                                    Parent_Request__r.Is_Exhibit_Required__c,
                                    list_of_uses__c,//Added by Govind under ER-2441
                                    Parent_Request__r.Data_Access_End_Date__c,//Added by Govind under ER-1736
                                    Parent_Request__r.Data_Period_End_Date__c,
                                    Is_Renewed__c, // Added by Babita Dadarwal under ER-2105
                                    Days_since_TLLA_has_expired__c, // Added by Babita Dadarwal under ER-2105
                                    In_Effect_Date__c, // Added by Babita Dadarwal under ER-2105
                                    Is_Vendor_Name_Contains_Veeva__c, //Added by Babita Dadarwal under ER-2270
                                    Is_Vendor_Name_Contains_DLIMI__c, 
                                    Is_Vendor_Name_Contains_MedPro__c, //Added by Shaik
                                    Is_Vendor_Name_Contains_DeepIntent__c,
                                    Is_Vendor_Related_to_Source_Symphony_Acc__c, //Added by Neha Bansal under CR-11826
                                  //  AMA_Distribution_And_Mailing_Attributes__c, //Added by Babita Dadarwal under ER-2241
                                  //  AMA_Market_Research_Attributes__c, //Added by Babita Dadarwal under ER-2241
                                  //  AMA_Market_Research_Attributes_For_Templ__c, //added by supriya Johari under CR-2694 ER-2261
                                    AMA_Dist_ana_Mail_Atrr_For_Template__c, //added by supriya Johari under CR-2694 ER-2261
                                    How_Response_Data_Collected_For_Template__c, //added by supriya Johari under CR-2694 ER-2261
                                    Copy_Additional_Vendor_Contacts__c,
                                    Client_Language__c,
                                    Vendor_Language__c,
                                    Offerings_With_Category__c,
                                    PurposeWithDataAsset__c,
                                    Action__c,
                                    ATC_Data__c,
                                    ATC_Category__c,
                                    AMA_USPrescriberData__c,
                                    AMA_TypeOfPrescriberLevelData__c,
                                  //  AMA_RespDataAction__c,
                                  //  AMA_RepDataCollectedOtherWay__c,
                                  //  AMA_PPDVariablesCollected__c,
                                    AMA_Howlong_SP_has_Data_Access__c,
                                  //  AMA_HowResponseDataCollected__c,

                                    AMA_DBL__c,
                                    Type_of_AMA_Agreement__c, 
                                    AMA_Services_Provided__c,
                                    //Start : ER-905 Ranu
                                    Does_the_request_require_information_con__c,
                                    Volumetric_Elements__c,
                                    Request_Type__c,  
                                    Service_Provider_Address__r.Name,
                                    Service_Provider_Address__r.Id,
                                    Service_Provider_Address__r.New_Vendor_Checklist__c,
                                    Service_Provider_Address__r.AMA_Check_List__c,
                              	    Service_Provider_Address__r.AMA_U_S_hold_status__c,
                              	    Service_Provider_Address__r.AMA_U_S_hold_status_details__c,
                                    Service_Provider_Address__r.Pharma_Company_Checklist__c,
                                    Service_Provider_Address__r.Legal_Firm_Checklist__c,
                                    Service_Provider_Address__r.Academia_Checklist__c,
                                    Service_Provider_Address__r.Parent_Vendor_Name__r.New_Vendor_Checklist__c,
                                    Service_Provider_Address__r.Parent_Vendor_Name__r.AMA_Check_List__c,
                              	    Service_Provider_Address__r.Parent_Vendor_Name__r.AMA_U_S_hold_status__c,
                              	    Service_Provider_Address__r.Parent_Vendor_Name__r.AMA_U_S_hold_status_details__c,
                                    Service_Provider_Address__r.Parent_Vendor_Name__r.Pharma_Company_Checklist__c,
                                    Service_Provider_Address__r.Parent_Vendor_Name__r.Legal_Firm_Checklist__c,
                                    Service_Provider_Address__r.Parent_Vendor_Name__r.Academia_Checklist__c,
                                    Client_Company_Name_Address__r.Name,
                                    Vendor_Employee_Country__c,
                                    Vendor_Employee_Outside_Data_Country__c,
                                    Vendor_Employee_Physical_Location_Other__c,
                                    Vendor_Employee_Physical_Location__c,
                                    Vendor_Employee_Country_AMA__c,
                                    U_S_Prescriber_Level_Data_Outside_US__c,
                                    Client_Company_Name_Address__r.Vendor_Tier__c,
                                    Service_Provider_Address__r.Is_Payment_Risk__c,
                                    Service_Provider_Address__r.Parent_Vendor_Name__r.Is_Payment_Risk__c,
                                    Payment_Risk_On_Vendor__c,
                                    Is_Manually_Approved__c,
                                    Purpose_Requires_Manual_Review__c,
                                    Requires_Manual_Review__c,
                                    Agreement_Number__c,
                                    Service_Provider_Address__r.Vendor_Tier__c,
                                    Service_Provider_Address__r.Parent_Vendor_Name__r.Vendor_Tier__c,
                                    Client_Address__r.Region_Territory__c,
                                    // added by sumita dabas issue 5348
                                    Arbitration_Attachment_Version__c, // added by sumita ER 941
                                    Other_Purpose_Selected__c,//Added 8 fields by Jyotsna ER-1058 14 Oct 2014
                                    Other_Data_Asset_Selected__c,
                                    TLLA_Language_Chosen__c,
                                    is_LAAD_Response_Acknowledged__c, 
                                    Countries_of_offerings__c,
				                    Category_of_Offerings__c,
				                    
                                    (Select Id,Name,dsfs__Completed_Date_Time__c, dsfs__Envelope_Status__c,dsfs__Voided_Reason__c,dsfs__Voided_Date_Time__c From Docusign_Status__r order by createddate desc limit 1),
                                    (Select id,
                                            Name,
                                            Agreement_Start_Date__c,
                                            Agreement_End_Date__c,
                                            Is_Prorated__c,
                                            Fee_Reduced__c,
                                            TPA_Request__c,
                                            Vendor_Legal_Name__c,
                                            Client__c,
                                            Contract_Type__c,
                                            Current_Year_Fees__c,
                                            Next_Year_Fees__c,
                                            DBL__c,
                                            Current_Year__c,
                                            Ex_Contract_End_Date__c,
                                            Final_End_Year__c,
                                            Next_Year__c,
                                            Ex_Contract_Type__c,
                                            Initial_Termination_Date__c,
                                            Max_Fee_Reached__c,
                                            Is_AMA_License_Required__c,
                                            AMA_Manual_Trigger_Reasons__c,
                                            AMA_Manual_Review__c,
                                            Number_Of_Scenarios_Satisfied__c,
                                            Scenarios_Satisfied_Details__c,
                                            FrequencyOfDeliveryToServiceProvider__c,
                                        //    AMA_PPDVariablesCollected__c,
                                            AMA_TypeOfPrescriberLevelData__c,
                                            FrequencyOfDeliveryToSP_Other__c,
                                        //    AMA_Market_Research_Attributes__c,
                                            AMA_Howlong_SP_has_Data_Access__c,
                                          //  AMA_HowResponseDataCollected__c,
                                         //   AMA_RepDataCollectedOtherWay__c,
                                         //   AMA_RespDataAction__c,
                                            AMA_Services_Provided__c,
                                          //  AMA_Distribution_And_Mailing_Attributes__c,
                                          //  AMA_Market_Research_Attributes_For_Templ__c,
                                            AMA_Dist_ana_Mail_Atrr_For_Template__c,
                                            Client_req_Storage_Permission_from_NonUS__c, 
                                            Client_Employee_Store_Data_in_country__c, 
                                            Vendor_require_Remote_Access_from_NonUS__c, 
                                            Vendor_Employee_Accessed_Data_in_country__c, 
                                            Vendor_req_Storage_Permission_from_NonUS__c, 
                                            Vendor_Employee_Store_Data_in_country__c,
                                            Technology_s_selected_for_remote_access__c,
                                            Other_Technology_for_Remote_Access__c,
                                            Ex_US_Entity_Authorized_Signer_FName__c,
                                            Ex_US_Entity_Authorized_Signer_LName__c,
                                            Ex_US_Entity_Authorized_Signer_Title__c,
                                            Ex_US_Entity_Authorized_Signer_Email__c,
                                            Ex_US_Legal_Entity_Name_Offshore_Storage__c,
                                            Ex_US_Legal_Entity_Name_Remote_Access__c,
                                            Ex_US_Foreign_Affiliate_of_TPA_Vendor__c, 
                                            Off_Access_Legal_Entity_Street__c,
                                            Off_Access_Legal_Entity_State__c,
                                            Off_Access_Legal_Entity_Country__c,
                                            Off_Access_Legal_Entity_City__c,
                                            Off_Access_Legal_Entity_Zip__c,
                                            Off_Storage_Legal_Entity_Country__c,
                                            Off_Storage_Legal_Entity_City__c,
                                            Off_Storage_Legal_Entity_Street__c,
                                            Off_Storage_Legal_Entity_State__c,
                                            Off_Storage_Legal_Entity_Zip__c

                                    from AMA_Agreement_Details__r
                                    limit 1),
                                    (select Name
                                            , Type__c
                                            , Title__c
                                            , Phone__c
                                            , Id
                                            , Fax__c
                                            , Email__c
                                            , Company_Name__c
                                            , AddressLine1__c
                                            , AddressLine2__c
                                            , City__c
                                            , State__c
                                            , ZipCode__c
                                            , ServiceProvider__c
                                            , TPA_Request__c
                                            , Where_Incorporated__c
                                            , Roles_And_Responsiblities__c
                                            , Located_Offshore__c
                                            , Country__c
                                            , Company_Phone__c
                                            , Vendor_Contact_Country__c
                                            , Vendor_Contact_State__c
                                            , Street__c
                                            , Vendor_Country__c
                                            , Vendor_State__c
                                            , Website__c
                                            , Contact_Zip_Code__c
                                            ,Contact_Last_Name__c
                                            ,Contact_first_Name__c
                                    From TPA_Request_Contacts__r),
                                    (select Name
                                            , Located_Offshore__c
                                            , Company_Name__c
                                            , Phone__c
                                            , Id
                                            , Email__c
                                    From SubcontractorsTPA__r),
                                    (Select Id, Name, ATC__c, TPA_Request__c from TPA_Request_MarketDefs__r)
                                    ,(SELECT Id, Name, TPA_Compliance_Hold_Action_Taken__c,TPA_Compliance_Hold_Acknowledged__c, TPA_Compliance_Response_to_Hold__c, Date_of_TPA_Compliance_Response_to_Hold__c, Related_TPA_Request__c, Related_TPA_Request__r.Service_Provider_Address__c
                                    ,Included_Category_s_In_Renewal__c
                                    ,Excluded_Category_s_In_Renewal__c
                                    ,Included_Offering_Country_s_In_Renewal__c
                                    ,Excluded_Offering_Country_s_In_Renewal__c
                                    ,Included_Uses_In_Renewal__c
                                    ,Excluded_Uses_In_Renewal__c
                                    ,Related_TPA_Request__r.Service_Provider_Address__r.Name 
                                    FROM TPA_Agreement_Additional_Fields__r) //Added By Neha Under Er-3031
                                    ,(Select Id, TPA_Offering_Notification_Record__c, Type__c FROM TPA_Use_Offering_Atypical_Combinations__r where Type__c = 'Offering Notification Record') // Added by Ajinkya Pande under Issue-10582
                                    ,TPA_Old_Status_When_Cancelled__c  
                                    ,(Select id,Vendor_Destruction_Confirmation_FName__c,
                                            Vendor_Destruction_Confirmation_LName__c,
                                            Vendor_Destruction_Confirmation_Title__c,
                                            Vendor_Destruction_Confirmation_Email__c,
                                            Vendor_Destruction_Confirmation_Date__c,
                                            ActionTaken__c FROM Vendor_Offering_Return_Acknowledgments__r), 
                                    (SELECT Id, IMS_Master_Legal_Entity__c, TPA_Request__c,is_Canada__c FROM IMS_Legal_Entities__r)
                                    ,(Select Id,Name,Status__c,Action__c,Receiver_s_Email__c,Action_Needed_By__c,Manual_Review_Reason__c,Associated_Use_to_Review__c,Country_of_Offering__c,BU__c, Is_Review_Secondary__c,
                                    Associated_Offering_to_Review__c,Associated_Offering_Category__c,Date_of_Action_Response__c,
                                    TPA_Additional_Term__c,TPA_Additional_Term__r.Name,TPA_Additional_Term__r.Term_Name__c,TPA_Additional_Term__r.TPA_Legal_Entity_1__r.Name From TPA_Commercial_Reviews__r  order by Is_Review_Secondary__c desc)
                                    ,(Select Id,Type__c,Name,Term_Name__c,Is_Future_Approved__c,TPA_Legal_Entity_1__c,TPA_Legal_Entity_1__r.Name From TPA_Additional_Terms__r)
                                From TPA_Request__c
                                where Id = :requestId];
        if (req != null) {
            return req;
        }

        return null;
    }

       /**
     * Gets request contact
     * @param contactId
     * @return contact object
     */
    public static List<TPA_Contact__c> getContactsForRequest(ID reqId) {
        List<TPA_Contact__c> contactList = [select
                ZipCode__c,
                Where_Incorporated__c,
                Type__c,
                Title__c,
                TPA_Request__c,
                SystemModstamp,
                State__c,
                ServiceProvider__c,
                Roles_And_Responsiblities__c,
                Phone__c,
                Name,
                Located_Offshore__c,
                LastModifiedDate,
                LastModifiedById,
                IsDeleted,
                Id,
                Fax__c,
                Email__c,
                CurrencyIsoCode,
                CreatedDate,
                CreatedById,
                Country__c,
                Company_Name__c,
                City__c,
                Address__c,
                AddressLine2__c,
                AddressLine1__c
                , Company_Phone__c
                , Vendor_Contact_Country__c
                , Vendor_Contact_State__c
                , Street__c
                , Vendor_Country__c
                , Vendor_State__c
                , Website__c
                , Contact_Zip_Code__c
                ,Contact_Last_Name__c
                ,Contact_first_Name__c
            from TPA_Contact__c where TPA_Request__c = :reqId];

        return contactList;
    }

    
    
    
    public static void sendCompetitiveMail(TPA_Request__c tpaRequest)
    {
        List<String> toAddresses = new List<String>();
        if(UTL_TPA.ChristineEmailAddress != null && UTL_TPA.ChristineEmailAddress != '') {
            toAddresses.add(UTL_TPA.ChristineEmailAddress);
        }

        List<String> ccAddresses = new List<String>();
        if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
            ccAddresses.add(UTL_TPA.sharedEmailAddress);
        }
        if(UTL_TPA.TpaEmailAddress != null && UTL_TPA.TpaEmailAddress != '') {
            for(String emailToCc: UTL_TPA.TpaEmailAddress.split(';')) {
                ccAddresses.add(emailToCc);
            }
        }
        
        String emailType = 'Email CompetitiveServices';
        SRV_TPA_TPARequest.sendTPANotifications(toAddresses, ccAddresses, emailType, 'English', tpaRequest.Id, true, null, null, TRUE, TRUE, tpaRequest);

    }

    public static void VendorSpecificNotificationSendConfirmationToClient(TPA_Request__c reqObj,String clientEmail)
    {
        system.debug('in VendorSpecificNotificationSendConfirmationToClient');
        system.debug(' clientEmail: '+clientEmail);
        List<String> toAddresses = new List<String>{};
        List<String> ccAddresses = new List<String>();
        
        if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
            toAddresses.add(reqObj.Client_TPA_Representative_Email__c);
        }
        if(clientEmail != null && reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != '' && clientEmail != reqObj.Client_TPA_Representative_Email__c){
            ccAddresses.add(clientEmail);
        }
        if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
            ccAddresses.add(reqObj.Owner.Email);
        }
        if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
            ccAddresses.add(UTL_TPA.sharedEmailAddress);
        }
        if(reqObj.TP_Processor_Email__c != null) {
            ccAddresses.add(reqObj.TP_Processor_Email__c);
        }
        ccAddresses = UTL_TPA_Multilingual.ccList(reqObj.Client_Address__r.TPAOtherEmailIds__c, ccAddresses);
        if(UTL_TPA.DRNEmailCopyAddress != null) {
            for(String emailToCc: UTL_TPA.DRNEmailCopyAddress.split(',')) {
                ccAddresses.add(emailToCc);
            }
        }
        //if(reqObj.TPA_Request_Contacts__r != null && reqObj.TPA_Request_Contacts__r.size() > 0) {
            for(TPA_Contact__c tpaContact : reqObj.TPA_Request_Contacts__r) {
                if(tpaContact.Type__c == 'Additional Client Contact') {                    
                    ccAddresses.add(tpaContact.Email__c);
                }
            }
        //}

        List<Attachment> lstAttachment = [select Id, Name,Body from Attachment where ParentId =: reqObj.Id and Name like '%Offerings Notification Client%.pdf' order by LastModifiedDate Desc limit 1];
        
        SRV_TPA_TPARequest.updateActivityHistory(reqObj.Id, 'Vendor-Specific Notification: Client Contact Notification Email Sent', true);
        String emailType = 'VSN Client Contact Notification';
        /*addTPProcessorInitials = true;
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/
        SRV_TPA_TPARequest.sendTPANotifications(toAddresses, ccAddresses, emailType, 'English', reqObj.id, true, lstAttachment, null, TRUE, TRUE, reqObj);
        //addTPProcessorInitials = false;

    }

    public static void VendorSpecificNotificationSendConfirmationToTPProcessor(TPA_Request__c reqObj,String clientEmail)
    {
        
        List<String> toAddresses = new List<String>{ reqObj.TP_Processor_Email__c };
        List<String> ccAddresses = new List<String>();

        if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
            ccAddresses.add(UTL_TPA.sharedEmailAddress);
        }

        if(UTL_TPA.DRNEmailCopyAddress != null) {
            for(String emailToCc: UTL_TPA.DRNEmailCopyAddress.split(',')) {
                ccAddresses.add(emailToCc);
            }
        }
        
        if(UTL_TPA.TPUSEMailAddress != null) {
            for(String emailToCc: UTL_TPA.TPUSEMailAddress.split(',')) {
                ccAddresses.add(emailToCc);
            }
        }

        List<Attachment> lstAttachment = [select Id, Name,Body from Attachment where ParentId =: reqObj.id and Name like '%Offerings Notification Client%.pdf' order by LastModifiedDate Desc limit 1];
        
        String emailType = 'VSN TP Processor Notification';
        /*addTPProcessorInitials = true;
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
        SRV_TPA_TPARequest.sendTPANotifications(toAddresses, ccAddresses, emailType, 'English', reqObj.id, true, lstAttachment, null, TRUE, TRUE, reqObj);
        //addTPProcessorInitials = false;
        
        SRV_TPA_TPARequest.updateActivityHistory(reqObj.Id, 'Vendor-Specific Notification: TP Processor Notification Email Sent', true);

    }

    public static void VendorSpecificNotificationSendCancellationConfirmationToClient(TPA_Request__c reqObj)
    {
        //Id reqId = reqObj.Id;
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();

        if(reqObj.ClientContact__r.email != null && reqObj.ClientContact__r.email != ''){
            toAddresses.add(reqObj.ClientContact__r.email);
        }
        if(reqObj.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
            toAddresses.add(reqObj.Client_TPA_Representative_Email__c);
        }
        if(reqObj.Owner.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
            toAddresses.add(reqObj.Owner.Email);
        }
        if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
            ccAddresses.add(UTL_TPA.sharedEmailAddress);
        }
        if(UTL_TPA.DRNEmailCopyAddress != null) {
            for(String emailToCc: UTL_TPA.DRNEmailCopyAddress.split(',')) {
                ccAddresses.add(emailToCc);
            }
        }
        
        List<Attachment> lstAttachment = [select Id, Name,Body from Attachment where ParentId =: reqObj.Id and Name like '%Offerings Notification Client%.pdf' order by LastModifiedDate Desc limit 1];
        String emailType = 'VSN Cancelation Confirmation';
        SRV_TPA_TPARequest.sendTPANotifications(toAddresses, ccAddresses, emailType, 'English', reqObj.Id, true, lstAttachment, null, FALSE, FALSE, null);

        SRV_TPA_TPARequest.updateActivityHistory(reqObj.Id, 'Vendor-Specific Notification: Cancelation Confirmation mail Sent', true);
    
    }

    public static void VendorSpecificNotificationClientContactAcknowledgment(TPA_Request__c reqObj,TPA_Agreement_Additional_Field__c agrAdditionalFieldObj){
        Id reqId = reqObj.Id; 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Id emailTempId = UTL_TPA_Multilingual.getEmailTemplateId('VSN Client Contact Acknowledgement Email','English');
        email = Messaging.renderStoredEmailTemplate(emailTempId, NULL, reqObj.Id);
        String initials = '';
        String globalTPProcessorInitials = '';
        System.debug('Email Template Id '+emailTempId);
        String replaceAcknowledgmentPart = '<html> <body>';
        replaceAcknowledgmentPart +=' <p style="border: 1px solid #0176d3; background-color: #0176d3; color:white; padding:5px;font-family: \'Segoe UI\', Arial; font-size: 10pt;">Acknowledged</p><br>';
        replaceAcknowledgmentPart+='<span style="font-family:Wingdings;">&thorn;</span>';
        replaceAcknowledgmentPart+='<span style = "font-family: \'Segoe UI\', Arial; font-size: 10pt;"> I have reviewed the Offering Notification document, understand, and will comply to ensure the protection of IQVIA intellectual property.</span><br><br>';
        replaceAcknowledgmentPart+='<span style="font-family:Wingdings">&thorn;</span>';
        replaceAcknowledgmentPart+='<span style = "font-family: \'Segoe UI\', Arial; font-size: 10pt;"> I will provide the Offering Notification document to my data provisioning person or department to ensure that proprietary attributes are not released to this Vendor. </span><br><br>';
        replaceAcknowledgmentPart +='<p style="border: 1px solid #0176d3; background-color: #0176d3; color:white; padding:5px; font-family: \'Segoe UI\', Arial; font-size: 10pt;">Acknowledged by</p>';
        replaceAcknowledgmentPart+='</body></html>';
        String replaceAcknowledgementDate = Date.Today().format();
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        if(reqObj?.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != ''){
            toAddresses.add(reqObj.Client_TPA_Representative_Email__c);
        }
        if(reqObj?.ClientContact__r?.email != null && reqObj?.Client_TPA_Representative_Email__c != null && reqObj.Client_TPA_Representative_Email__c != '' && reqObj.ClientContact__r.email != reqObj.Client_TPA_Representative_Email__c){
            ccAddresses.add(reqObj.ClientContact__r.email);
        }
        if(reqObj?.Owner?.Type != null && reqObj.Owner.Type == 'Queue' && reqObj.Owner.Email != null){
            ccAddresses.add(reqObj.Owner.Email);
        }
        if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
            ccAddresses.add(UTL_TPA.sharedEmailAddress);
        }
        if(reqObj?.TP_Processor_Email__c != null) {
            ccAddresses.add(reqObj.TP_Processor_Email__c);
        }
        ccAddresses = UTL_TPA_Multilingual.ccList(reqObj?.Client_Address__r?.TPAOtherEmailIds__c, ccAddresses);

        //if(reqObj?.TPA_Request_Contacts__r != null && reqObj.TPA_Request_Contacts__r.size() > 0) {
            for(TPA_Contact__c tpaContact : reqObj.TPA_Request_Contacts__r) {
                if(tpaContact?.Type__c == 'Additional Client Contact') {                    
                    ccAddresses.add(tpaContact.Email__c);
                }
            }
        //}
        emailToSend.setToAddresses(toAddresses);
        emailToSend.setCCAddresses(ccAddresses);
        emailToSend.setWhatId(reqObj.Id);
        emailToSend.setPlainTextBody(email.getPlainTextBody());
        emailToSend.setHTMLBody(addEmailFooter(email.getHTMLBody().replace('ACKNOWLEDGMENT_PART',replaceAcknowledgmentPart).replace('ACKNOWLEDGEMENT_DATE',replaceAcknowledgementDate).replace('FULL_NAME', agrAdditionalFieldObj.Client_Contact_First_Name__c ).replace('CLIENT_TITLE', agrAdditionalFieldObj.QuintilesIMS_Account_Team_First_Name__c).replace('CLIENT_EMAIL', agrAdditionalFieldObj.Offering_Notification_Ack_By_Email__c)));
        emailToSend.setCharset('UTF-8');

        //here I need to change the Name like
        List<Attachment> lstAttachment = [select Id, Name,Body from Attachment where ParentId =: reqObj.id and Name like '%Offerings Notification Client%.pdf' order by LastModifiedDate Desc limit 1];
        if(lstAttachment?.size() > 0)
        {
            Attachment att = lstAttachment[0];
            List<Messaging.Emailfileattachment> emailAttach = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(att.Name);
            efa.setBody(att.Body);
            emailAttach.add(efa);
            emailToSend.setFileAttachments(emailAttach);
        }
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            initials = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        }
        if(reqObj.Co_Assigned_Global_TP_Processor__r.Is_Active__c) {
            globalTPProcessorInitials = reqObj.Co_Assigned_Global_TP_Processor__r.Initials__c;
        }
        emailToSend.setSubject(setEmailInitials(initials, globalTPProcessorInitials, email.getSubject()));
        
        emailToSend.setSaveAsActivity(true);
        emailToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
        emailToSend.setTreatTargetObjectAsRecipient(false);
        if(UTL_TPA.orgWideEmailAddress != null) {
            emailToSend.setOrgWideEmailAddressId(UTL_TPA.orgWideEmailAddress);
        }

        try
        {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                Messaging.SendEmail(New Messaging.SingleEmailMessage[] {emailToSend});
                SRV_TPA_TPARequest.updateActivityHistory(reqId, 'Client Contact Acknowledgment Mail sent', true);

            }
        }
        catch(Exception e)
        {
            System.debug('Email Failed: ' + e.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_TPARequest:::VendorSpecificNotificationClientContactAcknowledgment', reqObj != null ? reqObj.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
    }
    
    public static void VendorSpecificNotificationSendTPProcessorNotificationofSalesCommunicationResult(TPA_Request__c reqObj,TPA_Agreement_Additional_Field__c agrAdditionalFieldObj, String actionTaken)
    {
        Id reqId = reqObj.Id;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
           

        String additionalEmailBodyOne = '';
        String additionalEmailBodyTwo = '';
        if(actionTaken != '' && actionTaken != null ){
            if(actionTaken.contains('Cancel')){
                additionalEmailBodyOne = 'The client has indicated they wish to cancel this request. The client contact has received an email with a link to either confirm cancellation or modify the request. No action is required at this time for the TP Processor. If the client choses to modify the request, you will receive a new email to continue processing the request based on the new set of information provided.';
                additionalEmailBodyTwo = 'The request will remain in the status of \"Pending Cancellation\" until the client either confirms cancellation or modifies the request. If they take no action for 45 days, the request will automatically be cancelled';
            }
            if(actionTaken.contains('Acknowledge')){
                additionalEmailBodyOne = 'The request is now in the hands of the TP Processor to complete a final review and to make sure all aspects of the request are updated. For example, if AMA is involved and an AMA attribute needs to be removed from the AMA online selection screens, per the notification, then you must work with the client to make sure the AMA online section of the request is compliant with the notification parameters.';
                additionalEmailBodyTwo = 'The request will remain in \"Awaiting Final Review\" until you complete your analysis and take the "Send for Signature" Action or confirm the TPA is cancelled once the client has directly confirmed this action.';
            }
            if(actionTaken.contains('Modify')){
                additionalEmailBodyOne = 'The client has indicated they wish to modify this request. No action is required at this time for the TP Processor until the request has been modified. Once the client has modified the request, you will receive a new email to continue processing the request based on the new set of information provided.' ;
                additionalEmailBodyTwo = 'The request will remain in the status of \"Awaiting Client Modification\" until the client edits the request.';
            }
        }

        
        //email.setWhatId(agrAdditionalFieldObj.Id);

        //List<String> toAddresses = new List<String>{ clientEmail };
        List<String> ccAddresses = new List<String>();

        if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
            ccAddresses.add(UTL_TPA.sharedEmailAddress);
        }
        if(UTL_TPA.DRNEmailCopyAddress != null && UTL_TPA.DRNEmailCopyAddress != '') {
            for(String emailToCc: UTL_TPA.DRNEmailCopyAddress.split(',')) {
                ccAddresses.add(emailToCc);
            }
        }

        Id emailTempId = UTL_TPA_Multilingual.getEmailTemplateId('VSN TPProcessor Sales Communication Result', 'English');
        String initials = '';
        String globalTPProcessorInitials = '';
        
        try
        {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                email = Messaging.renderStoredEmailTemplate(emailTempId, NULL, agrAdditionalFieldObj.Id);
            }
            if(Test.isRunningTest()){
                 email.setHtmlBody('test');
            }
        }
        catch(Exception e)
        {
            System.debug('Email Failed: ' + e.getMessage());
        }
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        emailToSend.setToAddresses(new List<String>{ reqObj.TP_Processor_Email__c });
        emailToSend.setWhatId(agrAdditionalFieldObj.Id);
        emailToSend.setCCAddresses(ccAddresses);
        emailToSend.setPlainTextBody(email.getPlainTextBody());
        emailToSend.setHTMLBody(addEmailFooter(email.getHTMLBody().replace('DynamicActionButtonContentFirst', additionalEmailBodyOne).replace('DynamicActionButtonContentSecond', additionalEmailBodyTwo)));
        emailToSend.setCharset('UTF-8');
        List<Attachment> lstAttachment = [select Id, Name,Body from Attachment where ParentId =: reqObj.id and Name like '%Offerings Notification Client%.pdf' order by LastModifiedDate Desc limit 1];
        if(lstAttachment.size() > 0)
        {
            Attachment att = lstAttachment[0];
            List<Messaging.Emailfileattachment> emailAttach = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(att.Name);
            efa.setBody(att.Body);
            emailAttach.add(efa);
            emailToSend.setFileAttachments(emailAttach);
        }
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            initials = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        }
        if(reqObj.Co_Assigned_Global_TP_Processor__r.Is_Active__c) {
            globalTPProcessorInitials = reqObj.Co_Assigned_Global_TP_Processor__r.Initials__c;
        }
        emailToSend.setSubject(setEmailInitials(initials, globalTPProcessorInitials, email.getSubject()));
        
        emailToSend.setSaveAsActivity(true);
        emailToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
        emailToSend.setTreatTargetObjectAsRecipient(false);
        try
        {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                Messaging.SendEmail(New Messaging.SingleEmailMessage[] {emailToSend});
                SRV_TPA_TPARequest.updateActivityHistory(reqId, 'TP Processor Notification of Sales Communication Result mail Sent', true);

            }
        }
        catch(Exception e)
        {
            System.debug('Email Failed: ' + e.getMessage());
            // Debug log change
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_TPARequest:::VendorSpecificNotificationSendTPProcessorNotificationofSalesCommunicationResult', reqObj != null ? reqObj.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            // Debug log change
        }
    }
    public static void DirectToClientNotificationSendTPProcessorNotificationofClientLAADResponce(TPA_Request__c reqObj,TPA_Agreement_Additional_Field__c agrAdditionalFieldObj)
    {
        List<String> toAddresses = new List<String>{ reqObj.TP_Processor_Email__c };
        List<String> ccAddresses = new List<String>();
     
        if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
            ccAddresses.add(UTL_TPA.sharedEmailAddress);
        }
        if(UTL_TPA.tpaSetting != null && UTL_TPA.tpaSetting.TPA_RequestSubmitted_Email__c != null) {
            for(string objEmailId: UTL_TPA.tpaSetting.TPA_RequestSubmitted_Email__c.split(',', 0)) {
                if(objEmailId != null && objEmailId != '') {
                    ccAddresses.add(objEmailId);
                }
            }
        }

        List<Attachment> lstAttachment = [select Id, Name,Body from Attachment where ParentId =: reqObj.id and Name like '%Offerings Notification Client%.pdf' order by LastModifiedDate Desc limit 1];
        String emailType = 'Direct To Client:LAAD Response to TPUS';
        /*addTPProcessorInitials = true;
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
        	assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
        SRV_TPA_TPARequest.sendTPANotifications(toAddresses, ccAddresses, emailType, 'English', agrAdditionalFieldObj.id, true, lstAttachment, null, TRUE, TRUE, reqObj);
        //addTPProcessorInitials = false;

    }

    

   @future(callout=true)
    public static void generateOffNotificationDoc(Id reqId, string cType,Id vendorAccountId,String vendorLanguage,String reqName,String ClientContactEmail,Boolean isdynamicOffNotificationReqForVendor, String reqStatus, String argGUID) {   //updated by neha under ER-3031, CR-11850
        system.debug('in generateOffNotificationDoc::::');
        // Debug log change
        if(UTL_Validate.isValidGuid(argGUID)) {
            UTL_LogFactory.GUID = argGUID; 
        }
        TPA_Request__c objTpaRequest;
        // Debug log change
        user currentUser = [Select Id, profile.Name, profile.UserLicense.Name from User where Id =: UserInfo.getUserId()];
        try {
            objTpaRequest = SRV_TPA_TPARequest.getRequestInfo(reqId); // Debug log change
 
            String languageField = (cType == CLIENT_CON ? objTpaRequest.Client_Language__c : objTpaRequest.Vendor_Language__c) + '_Translation__c' ;
            PageReference pdf = null;
                pdf = Page.VFP_TPA_OffNotificationsGenerator;
                pdf.getParameters().put('mode','pdf');
                pdf.getParameters().put('id',reqId);
                pdf.getParameters().put('reqVendorAccountId',vendorAccountId);
                pdf.getParameters().put('reqVendorCountary',objTpaRequest.Vendor_Billing_Mailing_Country__c); 
                pdf.getParameters().put('language_Field', (cType == CLIENT_CON ? objTpaRequest.Client_Language__c : objTpaRequest.Vendor_Language__c) + '_Translation__c');   
           

            Blob body;

            if (Test.IsRunningTest()) {
                body = Blob.valueOf('UNIT.TEST');
            }
            else {
                body = pdf.getContent();
            }
            Attachment attach = new Attachment();
            attach.Body = body;

            attach.Name = cType == CLIENT_CON ? reqName  + ' Offerings Notification '+CLIENT_CON+'.pdf' : reqName  + ' Offerings Notification '+VENDOR_CON+'.pdf';  
            attach.IsPrivate = false;
            attach.ParentId = reqId;
            insert attach;

            //todo TPAQueryHelper.setLogObject(agg.Id, 'Offering notification attachment created', 'for '+cType+''); //Added by Vikram Singh under Issue-9952
            //todo TPAQueryHelper.logRef().generateLog(); 
            string taskSubject = cType == CLIENT_CON ? 'Offerings Notification '+CLIENT_CON+'' : 'Offerings Notification '+VENDOR_CON+'';   //Updated by Vikram Singh under Issue-9952
            SRV_TPA_TPARequest.updateActivityHistory(reqId, 'Generated ' + taskSubject, true);

            if(cType == VENDOR_CON){   
                objTpaRequest.Offering_Notification_Document_Id__c  = attach.Id;
            }
            

            if((reqStatus == 'Awaiting Account Mgmt Communication' || reqStatus == UTL_TPA.AWAITING_CLIENT_CONFIRMATION ) && cType == CLIENT_CON) { 
                if(objTpaRequest.Pending_Acknowledgements__c == null || objTpaRequest.Pending_Acknowledgements__c == ''){
                    objTpaRequest.Pending_Acknowledgements__c =  'Managed Attribute Acknowledgement' ;
                }
                else if(objTpaRequest.Pending_Acknowledgements__c.indexOf('Managed Attribute Acknowledgement') == -1){
                    objTpaRequest.Pending_Acknowledgements__c = objTpaRequest.Pending_Acknowledgements__c + ';Managed Attribute Acknowledgement' ;
                }
                if(reqStatus == 'Awaiting Account Mgmt Communication' && cType == CLIENT_CON) { 
                    SRV_TPA_TPARequest.VendorSpecificNotificationSendConfirmationToTPProcessor(objTpaRequest,objTpaRequest.ClientContact__r.email);
                }
                else if(reqStatus == UTL_TPA.AWAITING_CLIENT_CONFIRMATION && cType == CLIENT_CON){
                    SRV_TPA_TPARequest.VendorSpecificNotificationSendConfirmationToClient(objTpaRequest,objTpaRequest.ClientContact__r.email);
                    system.debug('objTpaRequest.ClientContact__r.email: ' + objTpaRequest.ClientContact__r.email);
                }
            }
            

            update objTpaRequest;


        } catch(Exception ex) {
            system.debug('####AttachmentTriggerHandler.generateOffNotificationDoc Error '+ ex.getMessage()+ ', Line: '+ex.getLineNumber()+', Cause: '+ex.getCause());
            // Debug log change
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SRV_TPA_TPARequest:::generateOffNotificationDoc', objTpaRequest != null ? objTpaRequest.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            // Debug log change
             //TODO
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            //TPAQueryHelper.setLogObject(reqId, 'Offering notification attachment failed', ' for '+cType+': '+ex.getMessage()+', Line:'+ex.getLineNumber()); 
            //TPAQueryHelper.logRef().generateLog(); 
        }
    }

    @future(callout=true)
    public static void generateAddendumNotificationDoc(Id reqId, String mode, String argGUID) { // Debug log change
        // Debug log change
        if(UTL_Validate.isValidGuid(argGUID)) {
            UTL_LogFactory.GUID = argGUID; 
        }
        TPA_Request__c objTpaRequest;
        // Debug log change
        try {
            objTpaRequest = SRV_TPA_TPARequest.getRequestInfo(reqId); // Debug log change
            system.debug('addendumGeneration::::');

            PageReference pdf = Page.VFP_TPA_AddendumNotification;
            pdf.getParameters().put('mode', mode); 
            pdf.getParameters().put('id',reqId);
            pdf.getParameters().put('reqVendorAccountId',objTpaRequest.Service_Provider_Address__r.Id);
            pdf.getParameters().put('aggNo',objTpaRequest.Name);
            pdf.getParameters().put('aggStartDate',string.valueOfGmt(objTpaRequest.Data_Access_Start_Date__c));
            Blob body;
            if (Test.IsRunningTest()) {
                body = Blob.valueOf('UNIT.TEST');
            }
            else {
                body = pdf.getContent();
            }
            Attachment attach = new Attachment();
            attach.Body = body;
            
            if(mode == 'word'){
                attach.Name = objTpaRequest.Name + ' Addendum Notification.doc';
            }
            else{
                attach.Name = objTpaRequest.Name + ' Addendum Notification.pdf';
            } 

            attach.IsPrivate = false;
            attach.ParentId = reqId;
            insert attach;
            string taskSubject = 'Addendum Notification';
            SRV_TPA_TPARequest.updateActivityHistory(reqId,'Generated ' + taskSubject, true);
        } catch(Exception ex) {
            system.debug(ex.getMessage());
            // Debug log change
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SRV_TPA_TPARequest:::generateAddendumNotificationDoc', reqId != null ? reqId : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            // Debug log change
            // todo TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            // todo TPAQueryHelper.setLogObject(reqId, 'generate Addendum Notification Doc Failed', ex.getMessage()+', Line:'+ex.getLineNumber()); 
            // todo TPAQueryHelper.logRef().generateLog(); 
        }
      }

    @future(callout=true)
    public static void generateHelpfulHintsAddendumDoc(Id reqId) { // Debug log change
        string templateName = '';
        string  adminUser = UTL_TPA.userNameContract; 
        string  adminUserPwd = UTL_TPA.passwordContract;
        string sessionId = UTL_TPA_Class_LoginAPI.login(adminUser,adminUserPwd);
        string serverUrl = '';
        TPA_Request__c objTpaRequest;
        // Debug log change
        try {
            objTpaRequest = SRV_TPA_TPARequest.getRequestInfo(reqId); // Debug log change
            String vendorLanguage = objTpaRequest.TLLA_Language_Chosen__c != null ? objTpaRequest.TLLA_Language_Chosen__c : (objTpaRequest.Vendor_Language__c != null ? objTpaRequest.Vendor_Language__c : 'English');
                if(vendorLanguage == 'English'){
                    templateName = 'TPA Helpful Hints Addendum';
                }else{
                    templateName = 'TPA Helpful Hints Addendum ' + vendorLanguage;
                }
            system.debug('HelpfulHintsaddendumGeneration::::');
            List<Apttus__APTS_Template__c> templates = [SELECT Id,Name FROM Apttus__APTS_Template__c WHERE Name =: templateName and Apttus__IsActive__c = TRUE LIMIT 1];

            serverUrl = UTL_TPA_Class_LoginAPI.serverUrl;  
            //generate document   
            System.debug('**Before Generating**adminUser**'+adminUser+'=2=adminUserPwd:'+adminUserPwd+'=3=sessionId:'+sessionId+'=4=serverUrl:'+serverUrl);                
            //Adding Five Seconds delay starts
            Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
            Integer delayInMilliseconds = 10000; // Five-second delay
            while (System.now().getTime() - startingTime < delayInMilliseconds){
                // Do nothing until desired delay has passed
            }
            //Adding Five Seconds delay ends
            boolean isDisplayWatermark = false;
            if(UTL_TPA.tpaSetting.Is_Template_Watermark_Automated__c) {
                isDisplayWatermark = UTL_TPA.isSandboxOrg;
            }
            
            Id docId = Apttus.MergeWebService.generateCustomDoc( templates[0].Id, objTpaRequest.id, 'TPA_Request__c', 'Full access', 'pdf', isDisplayWatermark,sessionId,serverUrl); 
            System.debug('**Successfully generated TPA Helpful Hints Addendum Template**docId**'+docId);
            
        } catch(Exception ex) {
            system.debug(ex.getMessage());
            // Debug log change
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SRV_TPA_TPARequest:::generateHelpfulHintsAddendumDoc', reqId != null ? reqId : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            // Debug log change
            // todo TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            // todo TPAQueryHelper.setLogObject(reqId, 'generate Addendum Notification Doc Failed', ex.getMessage()+', Line:'+ex.getLineNumber()); 
            // todo TPAQueryHelper.logRef().generateLog(); 
        }
      }
    
    
    

    public static Boolean retriggerManualReviewEmail = false;
    public static void retriggerManualReviewMail(TPA_Request__c tpaReq) {
        tpaRequest = getRequestInfo(tpaReq.Id);// TODO: Change query with required fields only
        retriggerManualReviewEmail = true;
        tpaRequest = getManualReviewReasons(tpaRequest);
        
        //VAlidate AMA manual reasons
        if(tpaRequest.AMA_Agreement_Details__r != null && tpaRequest.AMA_Agreement_Details__r.size() > 0) {
            String tpaRequestJSON = JSON.serialize(tpaRequest);
        	tpaRequest = SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(tpaRequestJSON);
        }
        
        if(tpaRequest.TP_Processor_Email__c != null && String.isNotBlank(tpaRequest.TP_Processor_Email__c)) {
            TPProcessorEmailId.add(tpaRequest.TP_Processor_Email__c);
        }
        sendApprovalMail(UTL_TPA.tpaSetting.TPA_AllianceTeamManualReview_Email__c, TPProcessorEmailId);
        if(tpaRequest.isClientOnComplianceHold__c || tpaRequest.isVendorOnComplianceHold__c){
            sendTPAComplianceHoldMail( UTL_TPA.tpaSetting.TPA_Compliance_Hold_Emails__c, TPProcessorEmailId  );
        }
    }
    
    public static Boolean isVendorOnSecondaryReview = false;
    
    public static TPA_Commercial_Review__c vendorSecRevRec;//will review later
    public static List<TPA_Commercial_Review__c> updatedSecReviews = new List<TPA_Commercial_Review__c>();
    public static List<TPA_Commercial_Review__c> offeringSecReviews = new List<TPA_Commercial_Review__c>();

    public static TPA_Request__c getManualReviewReasons (TPA_Request__c request) {
        system.debug('Inside getManualReviewReasons');

        CNT_TPA_RequestSubmissionForm.getLimitsMessage();
        tpaRequest = request ;

        system.debug('tpaRequest :: ' + tpaRequest);

        if(!retriggerManualReviewEmail) {
            isRunCommercialAutoLogic = runCommercialAutoLogic();
        }
        else {
            isRunCommercialAutoLogic = false;
        }
        System.debug('In getManualReviewReasons :: isRunCommercialAutoLogic :: ' + isRunCommercialAutoLogic);

        tpaRequest.Is_Manually_Approved__c = false;
        tpaRequest.Always_approved_Use_Offering_Combination__c = '';
        tpaRequest.Is_Vendor_Invited__c = false;
        tpaRequest.Other_Data_Asset_Selected__c = false;
        tpaRequest.Purpose_Requires_Manual_Review__c = false;
        tpaRequest.Other_Purpose_Selected__c = false;
        tpaRequest.DA_Requires_Manual_Review__c = false; 
        tpaRequest.Is_APLD_Selected__c = false; 
        tpaRequest.Is_RWE_Selected__c = false; 
        tpaRequest.Manual_Trigger_Reasons__c = ''; 

        reasonForAmaApprovalMap = new Map<String,String>(); //will review later
        useOfferingsCategoryWatchMap = new Map<String, Watch_List__c>();
        watchListsToBeUpserted = new List<Watch_List__c>();
        manualReviewReasonList = new set<string>(); 
        isOfferingOnSecondaryReview = false; 
        isVendorOnSecondaryReview = false;

        Boolean isVendorOnChecklist = false;
        boolean isVendorRequireReview = false;
        Boolean isVeeva = false;
        Boolean isMedPro = false;
        Boolean isRepwise = false;
        Boolean isSFDC = false;
        //Boolean isDeepIntent = false;
        Boolean isSourceOrSymphonyVendor = false;
        Boolean isEdith = false;
        Boolean isDLIMI = false;
        Boolean isSignum = false;
        Boolean isSpecificTPVendor = false;
        Set<Id> purposeIds = new Set<Id>();
        Boolean isRequestContainCRMUse = false;
        set<string> offeringCombCheck = new set<string>();  
        Boolean isClientOnComplianceHold = false;
        Boolean isVendorOnComplianceHold = false; 
        Boolean isOtherUseSelected = false;
        Boolean isExpertAnalysisUseSelected = false;
        String bodyTextForOtherUse = '';
        Boolean isOtherOfferingSelected = false;
        String bodyTextForOtherOffering = '';
        
        Set<String> categoryForOtherUse = new Set<String>();         
        Set<String> setUseforVeevaTerms = new Set<String>(Label.TPA_Use_name_for_Veeva_Terms.split(';'));
       // tempComOwnerMap = UTL_TPA.getTemporaryComOwnerDetails();
        tempComOwnerMap = UTL_TPA.getTemporaryComOwnerMapWithOff();

        //for(TPA_Purpose__c purpose : getPurposeAndDescriptionList(tpaRequest.Id)) {//TODO:create a new static function that returns purpose with purpose descriptions and remove this function's all references
        for(TPA_Purpose__c purpose : getPurposesList(tpaRequest.Id)) {
            purposeIds.add(purpose.Id);
            if(purpose.Name == 'CRM') {
                isRequestContainCRMUse = true;
            }
            if(setUseforVeevaTerms.contains( purpose.Name ) ) {
                isContainUSEforVeeva = true;
            }
        }

       Map<Id, List<TPA_Secondary_Data_Asset__c>> priOfferingIdToSecOfferingListMap = getPrimaryDataAssetMap( purposeIds );//TODO: Remove this
       Map<Id, List<TPA_Data_Asset__c>> useIdDataAssetMap = getPurposeIdDataAssetMap( purposeIds );        
       List<TPA_Data_Asset__c> tpaDataAssets = tpaDataAssetListCopy(purposeIds); // TODO: Create new query with required fields only
   
        
        //will create atypical combination before manual approval function start
        List<TPA_Use_Offering_Atypical_Combination__c> lstAtypicalUsePresent = new List<TPA_Use_Offering_Atypical_Combination__c>();
        
        if(!retriggerManualReviewEmail) {
            for(TPA_Use_Offering_Atypical_Combination__c atypicalobj : [select id, IMS_Use_Offering_Atypical_Combination__c, TPA_Request__c from TPA_Use_Offering_Atypical_Combination__c where TPA_Request__c = :tpaRequest.id and Type__c <> 'Offering Notification Record']) { 
                lstAtypicalUsePresent.add(atypicalobj);
            }
            
            System.debug('lstAtypicalUsePresent***:::'+lstAtypicalUsePresent);
            if(lstAtypicalUsePresent != null && lstAtypicalUsePresent.size() > 0){
                delete lstAtypicalUsePresent;
            }
        }
        //will create atypical combination before manual approval function

        System.debug('request.Manual_Trigger_Reasons__c1 ::: '+request.Manual_Trigger_Reasons__c);
        if( tpaRequest.Service_Provider_Address__c == null ) {
            tpaRequest.Is_Vendor_Invited__c = true;
            tpaRequest.Is_Manually_Approved__c = true;
            manualReviewReasonList.add('Vendor is null');
            isVendorRequireReview = true;                        
        }
        else if(tpaRequest.Service_Provider_Address__r.Name != null && tpaRequest.Service_Provider_Address__r.Name != '') {
            if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('veeva') != -1 ) {
                string []strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('veeva');
                if(strMap != null) {
                    if(strMap.size() == 0  ) {
                        isVeeva = true;
                    }
                    else if(strMap.size() == 1) {
                        if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                            isVeeva = true;
                        }
                    }
                    else {
                        if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                            isVeeva = true;
                        }
                    }
                }
            }
             if( (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('dlimi') != -1) || (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('dli') != -1) || (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('signum') != -1)) {
                string []strMap;
                if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('dlimi')){
                    strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('dlimi');
                }else if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('dli')){
                    strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('dli');
                }else if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('signum')){
                    isSignum = true;
                    strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('signum');
                }
                
                if(strMap != null) {
                    if(strMap.size() == 0  ) {
                        isDLIMI = true;
                    }
                    else if(strMap.size() == 1) {
                        if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                            isDLIMI = true;
                        }
                    }
                    else {
                        if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                            isDLIMI = true;
                        }
                    }
                }
            }
            if(isDLIMI && isSignum){
                tpaRequest.Is_Manually_Approved__c = true; 
                addReasonCommercial(tpaRequest, 'Vendor Signum: Requires to be Invoiced', null, null,null,null, null,null,null, null);
                manualReviewReasonList.add('Vendor Signum: Requires to be Invoiced');
            }

            if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('medpro') != -1 ) {
                string []strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('medpro');
                if(strMap != null) {
                    if(strMap.size() == 0  ) {
                        isMedPro = true;
                    }
                    else if(strMap.size() == 1) {
                        if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                            isMedPro = true;
                        }
                    }
                    else {
                        if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                            isMedPro = true;
                        }
                    }
                }
            }
            /*if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('deepintent') != -1 ) {
                isDeepIntent = true;
            }*/
            if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('edith') != -1 ) {
                isEdith = true;
            }
            if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('repwise') != -1 ) {
                string []strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('repwise');
                if(strMap != null) {
                    if(strMap.size() == 0  ) {
                        isRepwise = true;
                    }
                    else if(strMap.size() == 1) {
                        if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                            isRepwise = true;
                        }
                    }
                    else {
                        if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                            isRepwise = true;
                        }
                    }
                }
            }

        	if( (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('source') != -1) || (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('symphony') != -1)) {
                 string []strMap;
                 if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('source')){
                     strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('source');
                 }else if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('symphony')){
                     strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('symphony');
                 }
                 
                if(strMap != null) {
                    if(strMap.size() == 0  ) {
                        isSourceOrSymphonyVendor = true;
                    }
                    else if(strMap.size() == 1) {
                        if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                            isSourceOrSymphonyVendor = true;
                        }
                    }
                    else {
                        if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                            isSourceOrSymphonyVendor = true;
                        }
                    }
                }
            }

            if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('salesforce') != -1 ) {
                string []strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('salesforce');
                if(strMap != null) {
                    if(strMap.size() == 0  ) {
                        isSFDC = true;
                    }
                    else if(strMap.size() == 1) {
                        if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                            isSFDC = true;
                        }
                    }
                    else {
                        if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                            isSFDC = true;
                        }
                    }
                }
            }

            if(isSFDC || (tpaRequest.Vendor_Contact_e_mail__c != null && tpaRequest.Vendor_Contact_e_mail__c.endswith('@salesforce.com'))){
                tpaRequest.Is_Manually_Approved__c = true; 
                manualReviewReasonList.add('Vendor Has Limited Master TPA Certificate');
                addReasonCommercial(tpaRequest, 'Vendor Has Limited Master TPA Certificate', null, null, null, null, null, null, null,null);
            }

            for(string vendorName : Label.TPA_Specific_Third_Party_Vendors.toLowerCase().split(';')) {
                if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf(vendorName) != -1 ) {
                    string []strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split(vendorName);
                    if(strMap != null) {
                        if(strMap.size() == 0  ) {
                            isSpecificTPVendor = true;
                        }
                        else if(strMap.size() == 1) {
                            if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                                isSpecificTPVendor = true;
                            }
                        }
                        else {
                            if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                                isSpecificTPVendor = true;
                            }
                        }                            
                    }
                }
            }

            system.debug('isVeeva :: ' + isVeeva);
            system.debug('isMedPro :: ' + isMedPro);

            if( (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null
                 && (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Vendor_Tier__c == 'Y'
                    || tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.New_Vendor_Checklist__c))
             || (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c == null 
                 && (tpaRequest.Service_Provider_Address__r.Vendor_Tier__c == 'Y'
                    || tpaRequest.Service_Provider_Address__r.New_Vendor_Checklist__c))) { 
                system.debug('vendor checkilist is Y');
                isVendorOnChecklist = true;
               // isVendorRequireReview = createUpdateWatchList(tpaRequest,true,null,null,null); 
               isVendorRequireReview = createUpdateWatchList(tpaRequest,true,null,null,null,useIdDataAssetMap);                 
                if(isVendorRequireReview) {
                    tpaRequest.Is_Manually_Approved__c = true;
                    manualReviewReasonList.add('Vendor Requires Review');
                }
            }
            system.debug('tpaRequest.Always_approved_Use_Offering_Combination__c:: after vendor check ' + tpaRequest.Always_approved_Use_Offering_Combination__c);
            
            if((tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null 
            && (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Pharma_Company_Checklist__c
            || tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Legal_Firm_Checklist__c
            || tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Academia_Checklist__c))
            || (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c == null
            && (tpaRequest.Service_Provider_Address__r.Pharma_Company_Checklist__c
            || tpaRequest.Service_Provider_Address__r.Legal_Firm_Checklist__c
            || tpaRequest.Service_Provider_Address__r.Academia_Checklist__c))) {
                system.debug('Vendor is on other checklist');
                tpaRequest.Is_Manually_Approved__c = true;                
                manualReviewReasonList.add('Vendor Requires Review');
                if(tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Pharma_Company_Checklist__c || tpaRequest.Service_Provider_Address__r.Pharma_Company_Checklist__c)
                    addReasonCommercial(tpaRequest, 'Vendor requires review Vendor is a Pharma company or Affiliate of client', null, null, null, null, null, null, null,null);
                if(tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Legal_Firm_Checklist__c || tpaRequest.Service_Provider_Address__r.Legal_Firm_Checklist__c )
                     addReasonCommercial(tpaRequest, 'Vendor requires review Vendor is a Legal Firm', null, null, null, null, null, null, null,null);
                if(tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Academia_Checklist__c || tpaRequest.Service_Provider_Address__r.Academia_Checklist__c)
                     addReasonCommercial(tpaRequest, 'Vendor requires review Vendor is an Educational institution (Academia)', null, null, null, null, null, null, null,null);
                isVendorRequireReview = true;
            }
            if((tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null && tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.AMA_Check_List__c == 'Y' && (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.AMA_U_S_hold_status__c == null || (tpaRequest.Service_Provider_Address__r.AMA_U_S_hold_status__c != null && tpaRequest.Service_Provider_Address__r.AMA_U_S_hold_status__c != 'Prior collection issue')))
               || (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c == null && tpaRequest.Service_Provider_Address__r.AMA_Check_List__c == 'Y' && (tpaRequest.Service_Provider_Address__r.AMA_U_S_hold_status__c == null || (tpaRequest.Service_Provider_Address__r.AMA_U_S_hold_status__c != null && tpaRequest.Service_Provider_Address__r.AMA_U_S_hold_status__c != 'Prior collection issue')))) {
                   system.debug('AMA_Check_List__c = ' + tpaRequest.Service_Provider_Address__r.AMA_Check_List__c);
                   tpaRequest.Is_Manually_Approved__c = true;   
                   manualReviewReasonList.add('IQVIA Finance - Account On Hold List');
                   addReasonCommercial(tpaRequest, 'IQVIA Finance - Account On Hold List', null, null, null, null, null, null, null,null);
               }
        }

        if(isVendorRequireReview) {
            System.debug('isVendorRequireReview :: '+isVendorRequireReview);
            manualReviewReasonList.add('Vendor Requires Review');            
        }

        Map<String, Account_Compliance__c> accCompRecords = UTL_TPA.getTPAClientVendorComplianceDetails(tpaRequest.Client_Address__c, tpaRequest.Service_Provider_Address__c); 
        if(accCompRecords != null) {
            Account_Compliance__c accClientComp = accCompRecords.get('CC-'+tpaRequest.Client_Address__c);
            Account_Compliance__c accVendorComp = accCompRecords.get('VC-'+tpaRequest.Service_Provider_Address__c);
                
            if(tpaRequest.TPA_Agreement_Additional_Fields__r != null && tpaRequest.TPA_Agreement_Additional_Fields__r.size() > 0 && tpaRequest.TPA_Agreement_Additional_Fields__r[0].TPA_Compliance_Hold_Action_Taken__c != 'TPA can be released') {
                if(accClientComp != null && accClientComp.Client_TPA_Compliance_Hold__c) {
                    isClientOnComplianceHold = true;
                    tpaRequest.Is_Manually_Approved__c = true;
                    tpaRequest.isClientOnComplianceHold__c = true;
                    tpaRequest.Request_Status__c = 'Hold for TPA non-compliance';
                    manualReviewReasonList.add('Client TPA Compliance Hold:  Requires TPA Compliance Review');
                    addReasonCommercial(tpaRequest, 'Client TPA Compliance Hold:  Requires TPA Compliance Review', null, null, null, null, null, null, null,null); 
                }
                if(accVendorComp != null && accVendorComp.Vendor_TPA_Compliance_Hold__c) {
                    isVendorOnComplianceHold = true;
                    tpaRequest.Is_Manually_Approved__c = true;
                    tpaRequest.isVendorOnComplianceHold__c = true;
                    tpaRequest.Request_Status__c = 'Hold for TPA non-compliance';
                    manualReviewReasonList.add('Vendor TPA Compliance Hold: Requires TPA Compliance Review');
                    addReasonCommercial(tpaRequest, 'Vendor TPA Compliance Hold: Requires TPA Compliance Review', null, null, null, null, null, null, null,null);                    
                }
            }
            
            if(accVendorComp != null && accVendorComp.TPAs_Require_Secondary_Review_by_Mgmt__c) {
                isVendorOnSecondaryReview = true;
                vendorSecRevRec = new TPA_Commercial_Review__c(Manual_Review_Reason__c = 'Vendor Requires Secondary Review', TPA_Request__c = tpaRequest.Id, Status__c = 'Awaiting to Send: Primary Commercial Owner Not Complete', Action_Needed_By__c = 'Management', Receiver_s_Email__c = accVendorComp.TPA_Secondary_Review_Assigned_Mgmt_Email__c, TP_US_Email__c = UTL_TPA.TPUSEMailAddress, Associated_Offering_to_Review__c = 'Per this TPA Request', Associated_Use_to_Review__c = 'Per this TPA Request');
                
                addReasonCommercial(tpaRequest, 'Vendor Requires Secondary Review', accVendorComp.TPA_Secondary_Review_Assigned_Mgmt_Email__c, 'Per this TPA Request', 'Per this TPA Request', null, null, null, null,null);
                
                tpaRequest.Is_Manually_Approved__c = true;
                manualReviewReasonList.add('Vendor Requires Secondary Review');
                approvalNotificationMap.put('Vendor Requires Secondary Review', tpaRequest.Service_Provider_Address__r.Name);
            }
        }

        system.debug('isClientOnComplianceHold'+isClientOnComplianceHold);
        system.debug('isVendorOnComplianceHold'+isVendorOnComplianceHold);
        
        Set<Id> purposeIdsToWatchList = new Set<Id>();        
        Boolean isUsesRequireManualReview = false;
        String purposesList = '';

        //for(TPA_Purpose__c purpose : getPurposeAndDescriptionList( tpaRequest.Id )) {
        for(TPA_Purpose__c purpose : getPurposesList( tpaRequest.Id )) {
            Boolean isPurposeRequireManualReview = false;
            for( TPA_Purpose_Description__c tpaDescription : purpose.Purpose_Descriptions__r ) {
                if( tpaDescription.Description__r.Requires_Manual_Review__c || tpaDescription.Requires_Manual_Review__c) {
                    isPurposeRequireManualReview = true;
                }                
            }
            if(isPurposeRequireManualReview) {
                //system.debug('purpose requires MR - ' + purpose.Name);
                purposesRequireMRSet.add(purpose.Name);
                purposeIdsToWatchList.add(purpose.Id);
            }

            List<String> allOfferingNames = new List<String>();
            if(purpose.Name == Label.TPA_EXPERT_ANALYSIS_FOR_LEGAL_OR_GOVERNMENTAL_PURPOSES || purpose.Name == 'Other') {
                String use = purpose.Name == 'Other' ? purpose.Other_Text__c : purpose.Name ;
                String categoryName = purpose.TPA_Purpose_Category__r.Category_Name__c != null ? purpose.TPA_Purpose_Category__r.Category_Name__c : '';
                //system.debug('useIdDataAssetMap :: '+ useIdDataAssetMap); 
                //system.debug('purpose.Id :: '+ purpose.Id); 
                //system.debug('useIdDataAssetMap.get(purpose.Id) :: '+ useIdDataAssetMap.get(purpose.Id)); 
                if(purpose.Name == 'Other' && !categoryForOtherUse.contains(purpose.Purpose_Category_Name__c) ) {
                    bodyTextForOtherUse += '<p style ="font-size:13px;font-family:arial;">&emsp;&emsp;' + purpose.Purpose_Category_Name__c + ' Other: ' + purpose.Other_Text__c + '  <br>';
                    isOtherUseSelected = true;
                    categoryForOtherUse.add(purpose.Purpose_Category_Name__c);
                }
                for(TPA_Data_Asset__c da : useIdDataAssetMap.get(purpose.Id)) {
                    if(da.TPA_Secondary_Data_Assets__r.size() == 0) {                        
                        if(purpose.Name == 'Other') {
                            addReasonCommercial(tpaRequest, 'Other Use Selected', null, fullOfferingName(da, null), use, da, null, categoryName, null,null);
                        }
                        else if(purpose.Name == Label.TPA_EXPERT_ANALYSIS_FOR_LEGAL_OR_GOVERNMENTAL_PURPOSES) {
                            allOfferingNames.add(fullOfferingName(da, null));
                        }
                        
                    } else if(da.TPA_Secondary_Data_Assets__r.size() > 0) {
                        for(TPA_Secondary_Data_Asset__c secDA : da.TPA_Secondary_Data_Assets__r){
                            if(purpose.Name == 'Other'){
                                addReasonCommercial(tpaRequest, 'Other Use Selected', null, fullOfferingName(null, secDA), use, null, secDA, categoryName, null,null);
                            }
                            else if(purpose.Name == Label.TPA_EXPERT_ANALYSIS_FOR_LEGAL_OR_GOVERNMENTAL_PURPOSES) {
                                allOfferingNames.add(fullOfferingName(null, secDa));
                            }
                        } 
                    }
                }
                if(allOfferingNames != null && allOfferingNames.size() > 0) {
                    allOfferingNames.sort();
                    tpaRequest.Is_Manually_Approved__c = true; 
                    isExpertAnalysisUseSelected = true;
                    String offNames = '';
                    for(String offName:allOfferingNames){
                        offNames += offName + ', ';
                    }
                    offNames = offNames.removeEnd(', ');
                    
                    manualReviewReasonList.add('IQVIA Use of Expert Analysis for Legal or Governmental Purposes Selected');
                    addReasonCommercial(tpaRequest, 'IQVIA Use of Expert Analysis for Legal or Governmental Purposes Selected', null, offNames, 'Expert Analysis for Legal or Governmental Purposes', null, null, categoryName, null,null);                    
                }
                if( purpose.Name == 'Other') {
                    tpaRequest.Is_Manually_Approved__c = true; 
                    tpaRequest.Other_Purpose_Selected__c = true;
                    manualReviewReasonList.add('Other Use Selected');
                    
                    String otherPurposes = '';
                    if(approvalNotificationMap.containsKey('Other Use Selected')) {
                        otherPurposes = approvalNotificationMap.get('Other Use Selected');
                        if(!otherPurposes.contains(purpose.Other_Text__c)) {
                            otherPurposes += ', '+ purpose.Other_Text__c;
                        }
                        approvalNotificationMap.put('Other Use Selected', otherPurposes);
                    }
                    else {
                        approvalNotificationMap.put('Other Use Selected', purpose.Other_Text__c);
                    }
                }
            }
        }
        
        System.debug('purposeSetMR before : ' + purposesRequireMRSet);
		System.debug('purposeIdsToWatchList : ' + purposeIdsToWatchList);

        //if(purposesRequireMRSet.size() > 0  && !isVendorOnChecklist) {
        if(purposesRequireMRSet.size() > 0) {
            isUsesRequireManualReview = true;
            system.debug('isUsesRequireManualReview' + isUsesRequireManualReview); 
            //createUpdateWatchList(tpaRequest, false, purposeIdsToWatchList, purposesRequireMRSet, null);
            createUpdateWatchList(tpaRequest, false, purposeIdsToWatchList, purposesRequireMRSet, null, useIdDataAssetMap);
        }

        system.debug('tpaRequest.Always_approved_Use_Offering_Combination__c2:: ' + tpaRequest.Always_approved_Use_Offering_Combination__c);
        
        System.debug('purposeSetMR after : ' + purposesRequireMRSet);
        if(purposesRequireMRSet.size() > 0) {
            //purposesList = String.join(purposesRequireMRSet, ',');
            purposesList = string.valueof(purposesRequireMRSet).replace('{', '').replace('}', '');
            approvalNotificationMap.put('Selected Use requires Manual Review', purposesList);

            System.debug('purposesRequireMRSet : ' + purposesRequireMRSet);
            tpaRequest.Purpose_Requires_Manual_Review__c = true;
            tpaRequest.Is_Manually_Approved__c = true;
            manualReviewReasonList.add('Selected Use requires Manual Review');
        }

        String dataAssetComb = '';
        Boolean isNationOfferingSelectedWithCRMMDM = false;
        Map<String, String> countryToDataAssetMap = new Map<String, string>();
        Boolean isExternalLicenseReuired = false;
        Map<string, string> countryToOffRequireExternalLic = new Map<string, string>();
        String dataAssetCombMedPro = '';
        String dataAssetCombForSecondaryReview = '';
        String aTypicalCombinationKey = '';
        String aTypicalCombinationValue = '';        
        String promotionCustomStudyDateManual = '';
        String savedCombination = '';
        List<String> offeringsList = new List<String>();
        Integer otherCount = 0;
        String dataAssets = '';
        String OtherDataAssets = '';
        String OneKeyCountries = '';
        String MedpagesCountries = '';
        String midasCountries = '';
        String medproCountries = '';
        Boolean is_Xponent_or_OneKeyExist = false;

        List<TPA_Use_Offering_Atypical_Combination__c> lstATyicalCombinations = new List<TPA_Use_Offering_Atypical_Combination__c>();
        Map<String,String> mapMasterATypicalCombinations = new Map<String,String>();
        mapMasterATypicalCombinations = SRV_TPA_IMSUseOffAtypicalComb.getAtypicalCombinations();//TODO: Set null after use
        System.debug('Map is:::'+mapMasterATypicalCombinations);  
        
        Set<String> setSubNationalOfferings = new Set<String>(Label.TPA_SubNational_Offerings.split(';'));
        // Set<String> setUsesforDirecttoClientComm = new Set<String>(Label.TPA_Uses_DirecttoClient_Comm.split(';'));
        Set<String> setAPLDOfferingsForSpecVendors = new Set<String>(Label.TPA_APLD_Offerings_for_Specific_TP_Vendors.split(';'));

        for(TPA_Data_Asset__c da : tpaDataAssets) {
            
            //system.debug('offering loop start - da.Asset_Name__c :: ' + da.Asset_Name__c);
            if(da.Purpose__r.Name != 'CRM' && isVeeva && da.Geo_Level__c == 'Reference Data') {
                //System.debug('dataAssets:::'+dataAssetComb);
                if(dataAssetComb == ''){
                    dataAssetComb = da.Purpose__r.Name +' - '+ da.BU__c +' - '+ da.Asset_Name__c ;
                }
                else {
                    dataAssetComb += ' , ' + da.Purpose__r.Name +' - '+ da.BU__c +' - '+ da.Asset_Name__c;
                }
            }

            if((da.Purpose__r.Name == 'CRM' || da.Purpose__r.Name == 'Master Data Management - Stewardship, Governance, Maintenance Services' || da.Purpose__r.Name == 'Master Data Management - Hosting or Providing MDM Software') 
            && da.Geo_Level__c == 'National') {
                isNationOfferingSelectedWithCRMMDM = true;
                if(countryToDataAssetMap.containsKey(da.BU__c)) {
                    countryToDataAssetMap.put(da.BU__c, countryToDataAssetMap.get(da.BU__c) + ' ,' + da.Asset_Name__c);
                } else {
                    countryToDataAssetMap.put(da.bu__c, da.Asset_Name__c);
                }
                system.debug('countryToDataAssetMap: ' + countryToDataAssetMap);
            }
            //system.debug('priOfferingIdToSecOfferingListMap.get( da.Id ) :: ' + priOfferingIdToSecOfferingListMap.get( da.Id ));

            //Added from clientvendor method start
            if(da.BU__c == 'South Africa' ) {
                isSouthAfrica = true;
            }
            if(da.BU__c == 'South Africa' && da.Geo_Level__c == 'Sub-National' && setSubNationalOfferings.contains(da.Asset_Name__c)) {
                isSubNationalOff = true;
            }
            if(da.BU__c == 'South Africa' && da.Geo_Level__c == 'Consumer Health' && da.Asset_Name__c == 'IQVIA Consumer Aisle'){
                isAisleOff = true;
            }
            if(da.Asset_Name__c.contains('OneKey') && da.Purpose__r.Name == 'CRM' ){
                isOffOneKey = true;
                if(OneKeyCountries.indexOf(da.BU__c) == -1){
                    OneKeyCountries += da.BU__c + ', ';
                }
            }
            if(da.Asset_Name__c.indexOf('Medpages Data') != -1 && MedpagesCountries.indexOf(da.BU__c) == -1){
                MedpagesCountries += da.BU__c + ', ';
            }
            if(da.Asset_Name__c == 'MIDAS' && midasCountries.indexOf(da.BU__c) == -1) {
                midasCountries += da.BU__c + ', ';
            }
            if((da.Asset_Name__c == 'Xponent' || da.Asset_Name__c == 'OneKey Emails' || da.Asset_Name__c == 'OneKey Organizations (formerly HCOS)' || da.Asset_Name__c == 'OneKey Professionals (formerly HCPS)' || da.Asset_Name__c == 'OneKey Select') && da.BU__c == 'United States') {
                is_Xponent_or_OneKeyExist = true;
            } 
            else if((da.Asset_Name__c == 'Xponent' || da.Asset_Name__c == 'OneKey - Facilities' || da.Asset_Name__c == 'OneKey - Professionals') && da.BU__c == 'Canada') {
                is_Xponent_or_OneKeyExist = true;
            }
            if(is_Xponent_or_OneKeyExist){
                if(medproCountries == '' || medproCountries == null || medproCountries == da.BU__c){
                    medproCountries = da.BU__c;
                }else{
                    medproCountries = 'Multiple Countries of Offerings';
                }
            }
            if(da.Asset_Name__c.contains('OneKey Select') &&  da.BU__c == 'United States'){
                isOnekeySelectOfferingPresent = true;
            }
            // if(da.BU__c == 'Canada' && da.Geo_Level__c == 'Reference Data' && setUsesforDirecttoClientComm.contains(da.A_Column_Use_For_Template__c)){
            //     isCanadaRefOff = true;
            // }
            if(da.Asset_Name__c == 'LAAD - Longitudinal Access and Adjudication Data') {
                isLAADOffering = true;
                specVendorOffNameList.add(da.Asset_Name__c);
            }
            if(da.Asset_Name__c == 'Longitudinal prescription data') {
                isLongPrescriData = true;
                specVendorOffNameList.add(da.Asset_Name__c);
            }
            if(da.Asset_Name__c == 'Medical claims data') {
                isMedClaimsData = true;
                specVendorOffNameList.add(da.Asset_Name__c);
            }
            
            //Added from clientvendor method end

            if(priOfferingIdToSecOfferingListMap.get( da.Id ) == null || priOfferingIdToSecOfferingListMap.get( da.Id ).size() < 1 ) {
                //system.debug('inside primary');
                if(da.Asset_Name__c == 'Other') {
                    otherCount++;
                    offeringsList.add(da.Asset_Name__c + ' ' + otherCount);
                }
                else {
                    offeringsList.add(da.Asset_Name__c);
                }
                if( da.Data_Asset__r.Requires_Manual_Review__c || da.Requires_Manual_Review__c || da.Data_Asset__r.External_License_Data_Supplier_Req__c ) {
                    String use = ( da.A_Column_Use_For_Template__c != null ? da.A_Column_Use_For_Template__c : '' );
                    String offering = ( da.Asset_Name__c != null ? da.Asset_Name__c : '' );
                    String uniqueKey = use+offering;
                    
                    if(!offeringsRequireMRMap.containsKey(uniqueKey)) {
                        //system.debug('@@@@@@pri');
                        offeringsRequireMRMap.put(uniqueKey, da);
                    }
                    //System.debug('offering requires MR offeringsRequireMRMap: ' + offeringsRequireMRMap);
                }                
                
                if(da.Data_Asset__r.Needs_license_or_data_supplier_response__c == 'Yes') {
                    isExternalLicenseReuired = true;
                    if(countryToOffRequireExternalLic.containsKey(da.bu__c)) {
                        countryToOffRequireExternalLic.put(da.bu__c, countryToOffRequireExternalLic.get(da.bu__c) + ', ' + da.Asset_Name__c);
                    } else {
                        countryToOffRequireExternalLic.put(da.bu__c, da.Asset_Name__c);
                    }
                    system.debug('countryToOffRequireExternalLic1: ' + countryToOffRequireExternalLic);
                }

                if(isMedPro) {
                    if(!da.Asset_Name__c.contains('OneKey - Professionals') || da.Purpose__r.Name != 'Prescriber License Validation' ||  (da.BU__c != 'United States' && da.BU__c != 'Canada')) {
                        if(dataAssetCombMedPro == '') {
                            dataAssetCombMedPro = da.Purpose__r.Name +' - '+ da.BU__c +' - '+ da.Asset_Name__c ;
                        }
                        else {
                            dataAssetCombMedPro += ' , ' + da.Purpose__r.Name +' - '+ da.BU__c +' - '+ da.Asset_Name__c;
                        }  
                    }
                }

                aTypicalCombinationKey = da.purpose__r.TPA_Purpose_Category__c+':'+da.purpose__r.purpose__c+':'+da.Data_Asset__c; 
                aTypicalCombinationValue = mapMasterATypicalCombinations.get(aTypicalCombinationKey);
                
                if(aTypicalCombinationValue != null && aTypicalCombinationValue.split(':')[0] == 'false') {
                    TPA_Use_Offering_Atypical_Combination__c objAtypicalCombination = new TPA_Use_Offering_Atypical_Combination__c();
                    objAtypicalCombination.TPA_Request__c = tpaRequest.id;
                    objAtypicalCombination.IMS_Use_Offering_Atypical_Combination__c = aTypicalCombinationValue.split(':')[1];
                    lstATyicalCombinations.add(objAtypicalCombination);
                    savedCombination = '';
                    String categoryName = ( da.Purpose__r.TPA_Purpose_Category__r.Category_Name__c != null ? da.Purpose__r.TPA_Purpose_Category__r.Category_Name__c : '' );
                    if(approvalNotificationMap.containsKey('Use-Offering Atypical Combination is Present')) {
                        savedCombination = approvalNotificationMap.get('Use-Offering Atypical Combination is Present');
                        savedCombination += '<br/>'+'Use Name - '+da.Purpose__r.name+', '+'Primary Offering Name - '+da.Asset_Name__c+', '+'Offering Country - '+da.Data_Asset__r.BU__c; 
                    }
                    else {
                        savedCombination = 'Use Name - '+da.Purpose__r.name+', '+'Primary Offering Name - '+da.Asset_Name__c+', '+'Offering Country - '+da.Data_Asset__r.BU__c;
                    }
                    approvalNotificationMap.put('Use-Offering Atypical Combination is Present', savedCombination);
                    addReasonCommercial(tpaRequest, 'Use-Offering Atypical Combination is Present', da.Data_Asset__r.Commercial_Owner_Email__c, fullOfferingName(da, null), da.Purpose__r.name, da, null, categoryName, null,null);
                }

                if(da.Asset_Name__c == 'LAAD - Longitudinal Access and Adjudication Data' && da.Purpose__r.name == 'Incentive Compensation Processing') {
                    addReasonCommercial(tpaRequest, 'Combination of LAAD and \'Incentive Compensation\' selected', da.Data_Asset__r.Commercial_Owner_Email__c, fullOfferingName(da, null), da.Purpose__r.name, da, null, da.Purpose__r.TPA_Purpose_Category__r.Category_Name__c != null ? da.Purpose__r.TPA_Purpose_Category__r.Category_Name__c : '', null,null);
                    isIncentiveCompensationWithLAAD = true;
                }

                if(da.Data_Asset__r.Requires_Secondary_Review__c) {
                    dataAssetCombForSecondaryReview += da.Asset_Name__c + ',';
                    addReasonCommercial(tpaRequest, 'Offering Requires Secondary Commercial Review',  da.Data_Asset__r.Secondary_Commercial_Reviewer_Email__c, fullOfferingName(da,null), da.A_Column_Use_For_Template__c, da, null, da.Purpose__r.Purpose_Category_Name__c, null,null);
                }                  
            } 
            else if(priOfferingIdToSecOfferingListMap.get( da.Id ) != null && priOfferingIdToSecOfferingListMap.get( da.Id ).size() > 0) {
                //System.debug('inside sec offering  name');
                for(TPA_Secondary_Data_Asset__c secDA : priOfferingIdToSecOfferingListMap.get( da.Id )) {
                    offeringsList.add(secDA.Secondary_Asset_Name__c);
                    if(secDA.IMS_Secondary_Data_Asset__r.Requires_Manual_Review__c) {
                        String use = ( secDA.TPA_Data_Asset__r.A_Column_Use_For_Template__c != null ? secDA.TPA_Data_Asset__r.A_Column_Use_For_Template__c : '' );
                        String offering = ( secDA.Secondary_Asset_Name__c != null ? secDA.Secondary_Asset_Name__c : '' );
                        String uniqueKey = use+offering;
                        //System.debug('sec offering requires MR name : ' + secDA.Secondary_Asset_Name__c);
                        //System.debug('sec offering requires MR use: ' + use);
                        //System.debug('purposesRequireMRSet:sec ' + purposesRequireMRSet);
                        //if(!purposesRequireMRSet.contains(use) && !offeringsRequireMRMap.containsKey(uniqueKey)) {
                        if(!offeringsRequireMRMap.containsKey(uniqueKey)) {
                            //system.debug('@@@@@@pri');
                            offeringsRequireMRMap.put(uniqueKey, da);
                        }
                        //System.debug('sec offering requires MR offeringsRequireMRMap: ' + offeringsRequireMRMap);
                    }                    

                    if(secDA.IMS_Secondary_Data_Asset__r.Need_license_or_data_supplier_permission__c == 'Yes') {
                        isExternalLicenseReuired = true;
                        if(countryToOffRequireExternalLic.containsKey(secDA.bu__c)) {
                            system.debug('countryToOffRequireExternalLic: ' + countryToOffRequireExternalLic);
                            countryToOffRequireExternalLic.put(secDA.bu__c, countryToOffRequireExternalLic.get(secDA.bu__c) + ', ' + secDA.Secondary_Asset_Name__c);
                        } else {
                            countryToOffRequireExternalLic.put(secDA.bu__c, secDA.Secondary_Asset_Name__c);
                        }
                        //system.debug('countryToOffRequireExternalLic1: ' + countryToOffRequireExternalLic);
                    }

                    if(isMedPro) {
                        if(da.Purpose__r.Name != 'Prescriber License Validation' || (( da.BU__c != 'United States' && da.BU__c != 'Canada') || (!da.Asset_Name__c.contains('OneKey Professionals') && !da.Asset_Name__c.contains('OneKey Organizations'))) || (secDA.Secondary_Asset_Name__c != 'Xponent Prescribing Dynamics' || secDA.BU__c != 'United States')) {
                            if(dataAssetCombMedPro == ''){
                                dataAssetCombMedPro = da.Purpose__r.Name +' - '+ secDA.BU__c +' - '+ da.Asset_Name__c ;
                            }
                            else{
                                dataAssetCombMedPro += ' , ' + da.Purpose__r.Name +' - '+ secDA.BU__c +' - '+ da.Asset_Name__c;
                            }
                        }
                    }

                    aTypicalCombinationKey = da.purpose__r.TPA_Purpose_Category__c+':'+da.purpose__r.purpose__c+':'+da.Data_Asset__c + ':'+secDA.IMS_Secondary_Data_Asset__c; 

                    aTypicalCombinationValue = mapMasterATypicalCombinations.get(aTypicalCombinationKey); 
                    if(aTypicalCombinationValue != null && aTypicalCombinationValue.split(':')[0] == 'false') {
                        TPA_Use_Offering_Atypical_Combination__c objAtypicalCombination = new TPA_Use_Offering_Atypical_Combination__c();
                        objAtypicalCombination.TPA_Request__c = tpaRequest.id;
                        objAtypicalCombination.IMS_Use_Offering_Atypical_Combination__c = aTypicalCombinationValue.split(':')[1];
                        lstATyicalCombinations.add(objAtypicalCombination);
                        savedCombination = '';
                        String categoryName = ( secDA.TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.Category_Name__c != null ? secDA.TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.Category_Name__c : '' );

                        if(approvalNotificationMap.containsKey('Use-Offering Atypical Combination is Present'))  {
                            savedCombination = approvalNotificationMap.get('Use-Offering Atypical Combination is Present');
                            savedCombination += '<br/>'+'Use Name - '+da.Purpose__r.name+', '+'Primary Offering Name - '+da.Asset_Name__c+', '+'Secondary Offering Name - '+secDA.Secondary_Asset_Name__c+', Offering Country - '+da.Data_Asset__r.BU__c;
                        }
                        else {
                            savedCombination = 'Use Name - '+da.Purpose__r.name+', '+'Primary Offering Name - '+da.Asset_Name__c+', '+'Secondary Offering Name - '+secDA.Secondary_Asset_Name__c+', Offering Country - '+da.Data_Asset__r.BU__c; 
                        }
                        addReasonCommercial(tpaRequest, 'Use-Offering Atypical Combination is Present', secDA.IMS_Secondary_Data_Asset__r.Commercial_Manager_Email__c, fullOfferingName(null, secDA), da.Purpose__r.name, null, secDA, categoryName, null,null);
                        approvalNotificationMap.put('Use-Offering Atypical Combination is Present', savedCombination);
                    }
                    
                    if(secDA.IMS_Secondary_Data_Asset__r.Requires_Secondary_Review__c) {
                        dataAssetCombForSecondaryReview += secDA.Secondary_Asset_Name__c + ',';
                        addReasonCommercial(tpaRequest, 'Offering Requires Secondary Commercial Review', secDA.IMS_Secondary_Data_Asset__r.Secondary_Commercial_Reviewer_Email__c, fullOfferingName(null, secDA), da.A_Column_Use_For_Template__c, null, secDA, da.Purpose__r.Purpose_Category_Name__c, null,null);
                    }

                    if(da.Asset_Name__c == 'APLD Custom Study Name & Project Delivery Date:') {
                        if(setAPLDOfferingsForSpecVendors.contains( secDA.Secondary_Asset_Name__c) ) {
                            isAPLDOffSpecVendors = true;
                            specVendorOffNameList.add(secDA.Secondary_Asset_Name__c);
                        }
                    }
                }
            }

            if( da.Data_Asset__r.Geo_Level__c == 'Real World Evidence') {
                tpaRequest.Is_RWE_Selected__c = true;
            }
            
            if( da.Data_Asset__r.Geo_Level__c == 'Anonymized Patient-Level Data / Transaction-Level'){
                tpaRequest.Is_APLD_Selected__c = true;
            }
            
            if(da.Asset_Name__c == 'Other') {
                if(da.Asset_NametText__c == 'Other'){
                    bodyTextForOtherOffering += '<tr> <td style="font-size:13px ;font-family:arial;border : 2px solid black;padding-left: 5px;"> ' + da.BU__c + '</td>';
                    bodyTextForOtherOffering += '<td style="font-size:13px;font-family:arial;border : 2px solid black;padding-left: 5px;"> ' + da.Geo_Level__c + '</td>';
                    bodyTextForOtherOffering += '<td style="font-size:13px;font-family:arial;border : 2px solid black;padding-left: 5px;"> ' + da.Other_Data_Asset_Details__c + '</td></tr>';
                    isOtherOfferingSelected = true;
                }
                tpaRequest.Is_Manually_Approved__c = true;
                tpaRequest.Other_Data_Asset_Selected__c = true;
                addReasonCommercial(tpaRequest, 'Other Offering Selected', null, fullOfferingName(da, null), da.A_Column_Use_For_Template__c, da, null, da.Purpose__r.TPA_Purpose_Category__r.Category_Name__c != null ? da.Purpose__r.TPA_Purpose_Category__r.Category_Name__c : '', null,null);

                manualReviewReasonList.add('Other Offering Selected');
                
                if(approvalNotificationMap.containsKey('Other Offering Selected')) {
                    OtherDataAssets = approvalNotificationMap.get('Other Offering Selected');
                    if(OtherDataAssets.indexOf(da.Other_Data_Asset_Details__c) ==-1) {
                        OtherDataAssets += ', '+da.Other_Data_Asset_Details__c;
                    }
                    approvalNotificationMap.put('Other Offering Selected', OtherDataAssets);
                }
                else {
                    approvalNotificationMap.put('Other Offering Selected', da.Other_Data_Asset_Details__c);
                }

            }   
            
            
        }
        Boolean offeringRequiresReview = true;
        //if(offeringsRequireMRMap.size() > 0 && !isVendorOnChecklist) { 
        if(offeringsRequireMRMap.size() > 0) { 
          //  createUpdateWatchList(tpaRequest, false, null, null, offeringsRequireMRMap);
          offeringRequiresReview = createUpdateWatchList(tpaRequest, false, null, null, offeringsRequireMRMap, useIdDataAssetMap);
        }

        Map<String, String> priAssetFieldMap = new Map<String, String>();
        for(string priAssetField : Label.TPA_Primary_Asset_Field_Map.split(',')){
            priAssetFieldMap.put(priAssetField.split('~')[0], priAssetField.split('~')[1]);
        }
        Map<String, String> secAssetFieldMap = new Map<String, String>();
        for(string secAssetField : Label.TPA_Sec_Asset_Field_Map.split(',')) {
            secAssetFieldMap.put(secAssetField.split('~')[0], secAssetField.split('~')[1]);
        }
        
        for(TPA_Data_Asset__c da : offeringsRequireMRMap.values()) {
            if(priOfferingIdToSecOfferingListMap.get( da.Id ) == null || priOfferingIdToSecOfferingListMap.get( da.Id ).size() < 1 ) {                
                String dataAssetString = '';
                if(priAssetFieldMap != null && priAssetFieldMap.size() > 0 && priAssetFieldMap.keySet().contains(da.Asset_Name__c)) {
                    String fieldName = priAssetFieldMap.get(da.Asset_Name__c);                    
                    if(da.get(fieldName) != null){
                        dataAssetString += da.Asset_Name__c +': ' + da.get(fieldName);
                    }                    
                }
                else if(da.Asset_Name__c.equalsIgnoreCase(Label.TPA_STI_Data_Offering_Name)) {
                    dataAssetString =  da.Asset_Name__c + da.STI_Data_Report_Name__c;
                }
                else {
                    dataAssetString = da.Asset_Name__c;
                }
                if(!offeringCombCheck.contains((da.BU__c + ' - ' + dataAssetString).toLowerCase())) {
                    dataAssets += ',' + da.BU__c + ' - ' + dataAssetString;                    
                    offeringCombCheck.add((da.BU__c + ' - ' + dataAssetString).toLowerCase());
                }
            }
            else if(priOfferingIdToSecOfferingListMap.get( da.Id ) != null && priOfferingIdToSecOfferingListMap.get( da.Id ).size() > 0) {
                for(TPA_Secondary_Data_Asset__c secDA : priOfferingIdToSecOfferingListMap.get( da.Id )) {
                    promotionCustomStudyDateManual = '';
                    if(secDA.Secondary_Asset_Name__c == 'BrandImpact Custom Study Name & Project Delivery Date:') {
                        promotionCustomStudyDateManual += 'BrandImpact Custom Study Name: '+secDA.BrandImpact_Study_Name__c;
                        promotionCustomStudyDateManual += ' BrandImpact Project Delivery Date: '+secDA.BrandImpact_Delivery_Date__c.format();                        
                    }
                    else if(secDA.Secondary_Asset_Name__c == 'Channel Dynamics Custom Study Name & Project Delivery Date:') {
                        promotionCustomStudyDateManual += 'Channel Dynamics Custom Study Name: ' + secDA.Channel_Dynamics_Study_Name__c;
                        promotionCustomStudyDateManual += ' Channel Dynamics Project Delivery Date: ' + secDA.Channel_Dynamics_Delivery_Date__c.format();
                    }
                    else if(secDA.Secondary_Asset_Name__c == 'ProVoice Custom Study Name & Project Delivery Date:') {
                        promotionCustomStudyDateManual += 'ProVoice Custom Study Name: '+secDA.Pro_Voice_Study_Name__c;
                        promotionCustomStudyDateManual += ' ProVoice Project Delivery Date: '+secDA.Pro_Voice_Delivery_Date__c.format();
                    }
                    else if(secAssetFieldMap != null && secAssetFieldMap.size() > 0 && secAssetFieldMap.keySet().contains(secDA.Secondary_Asset_Name__c)) {
                        String fieldName = secAssetFieldMap.get(secDA.Secondary_Asset_Name__c);
                        if(secDA.get(fieldName) != null) {
                            promotionCustomStudyDateManual+= secDA.Secondary_Asset_Name__c + ': '+ secDA.get(fieldName);
                        }
                    }
                    else if(secDA.Secondary_Asset_Name__c == Label.TPA_OutlierView) {
                        promotionCustomStudyDateManual += ' Data Niche Associates (DNA) Medicaid Data: OutlierView Labeler Codes: '+secDA.Outliner_Label_Code__c;
                        promotionCustomStudyDateManual += ' Data Niche Associates (DNA) Medicaid Data: OutlierView Date: '+secDA.Outliner_Data_Period_Text__c;
                    }
                    else if(secDA.Secondary_Asset_Name__c == Label.STI_Data_Custom_Report_Name) {
                        promotionCustomStudyDateManual += Label.STI_Data_Custom_Report_Name + secDA.STI_Data_Custom_Report_Name__c;
                    }
                    else if(dataAssets.indexOf(secDA.BU__c + ' - ' + secDA.Secondary_Asset_Name__c) == -1) { 
                        dataAssets += ',' + secDA.BU__c + ' - ' + secDA.Secondary_Asset_Name__c;
                    }

                    if(!offeringCombCheck.contains((secDA.BU__c + ' - ' + promotionCustomStudyDateManual).toLowerCase())) {
                        dataAssets += ',' + secDA.BU__c + ' - ' + promotionCustomStudyDateManual;
                        offeringCombCheck.add((secDA.BU__c + ' - ' + promotionCustomStudyDateManual).toLowerCase());
                    }
                }
            }
        }

        if(dataAssets != null && dataAssets != '' && offeringRequiresReview) {
            approvalNotificationMap.put('Selected Offering requires Manual Review', dataAssets);
            tpaRequest.DA_Requires_Manual_Review__c = true;
            tpaRequest.Is_Manually_Approved__c = true;
            manualReviewReasonList.add('Selected Offering requires Manual Review');
            
            String approvalNotificationTemp = '';
            if(approvalNotificationMap.get('Selected Offering requires Manual Review') != null) {
                approvalNotificationTemp = approvalNotificationMap.get('Selected Offering requires Manual Review').replaceAll(';', '');
            }
            approvalNotificationMap.put('Selected Offering requires Manual Review', approvalNotificationTemp);
        } 
        tpaRequest.Total_Offerings_Selected__c = (offeringsList != null ? offeringsList.size() : 0);
        System.debug('offeringsList.size( : ' + offeringsList.size());
        Set<String> uniqueOffLst = new Set<String>();
        uniqueOffLst.addAll(offeringsList);
        tpaRequest.Unique_number_of_data_assets__c = (uniqueOffLst != null ? uniqueOffLst.size() : 0);

        /* if(offeringsList.size() >= UTL_TPA.OFFERING_COUNT ) {
            tpaRequest.is_20_or_more_Offering_Present__c = true;
        }
        else {
            tpaRequest.is_20_or_more_Offering_Present__c = false;
        }  */ 
        if(offeringsList.size() >= 100 ) {
            tpaRequest.is_50_or_more_Offering_Present__c = true;
            tpaRequest.Is_Manually_Approved__c = true;
            if(!tpaRequest.is_Bulk_TPA_Request__c) {
                sendNotificationfor50OrMoreLicenses(tpaRequest);
            }
            manualReviewReasonList.add('Legal Review Required: Greater than 100 Licenses Requires Final Review for Legal Approval');
            addReasonCommercial(tpaRequest, 'Legal Review Required: Greater than 100 Licenses Requires Final Review for Legal Approval',null,null,null,null,null,null, null,null);
        }
        else {
            tpaRequest.is_50_or_more_Offering_Present__c = false;
        }  
        
        if(OneKeyCountries != null && OneKeyCountries != ''){
            OneKeyCountries = OneKeyCountries.removeEnd(', ');
            tpaRequest.Onekey_Countries__c = OneKeyCountries;
        }
        if(MedpagesCountries != null && MedpagesCountries != ''){
            MedpagesCountries = MedpagesCountries.removeEnd(', ');
            tpaRequest.Medpages_Data_Countries__c = MedpagesCountries;
        }
        if(midasCountries != null && midasCountries != ''){
            midasCountries = midasCountries.removeEnd(', ');
            tpaRequest.Midas_Countries__c = midasCountries;
        }
        if(medproCountries != null && medproCountries != ''){
            tpaRequest.Medpro_Countries__c = medproCountries;
        }
        
        
        
        if(isVeeva || isSourceOrSymphonyVendor || isMedPro || isSouthAfrica || isEdith || isSpecificTPVendor || isDLIMI) {
            /*if(isVeeva){
                tpaRequest.Is_Vendor_Veeva_for_all_Use__c = true;
            }*/
            if(isVeeva && isContainUSEforVeeva) {
                tpaRequest.Is_Vendor_Name_Contains_Veeva__c = true;
            }
            if(isVeeva && isRequestContainCRMUse && isOffOneKey) {
                tpaRequest.Is_Veeva_Use_CRM_Off_OneKey__c = true;
            }
            /* if(isVeeva && isRequestContainCRMUse) {
                tpaRequest.is_Veeva_Use_CRM__c = true;
            } */
            if(isSourceOrSymphonyVendor) {
                tpaRequest.Is_Vendor_Related_to_Source_Symphony_Acc__c = true;
            }
            if(isSouthAfrica && isSubnationalOff) {
                tpaRequest.Is_South_Africa_Sub_Off__c = true;
            }
            if((isVeeva || isRepwise) && isRequestContainCRMUse && isSouthAfrica && isSubnationalOff) {
                tpaRequest.Is_South_Africa_Sub_Off__c = false;
                tpaRequest.Is_Veeva_Use_CRM_SubNational_Off__c = true;
            }
            if(isMedPro) {
                tpaRequest.Is_Vendor_Name_Contains_MedPro__c = true;
            }
            /*if(isDeepIntent) {
                tpaRequest.Is_Vendor_Name_Contains_DeepIntent__c = true;
            }*/
            if(isEdith){
                tpaRequest.Is_Vendor_Name_Contains_Edith__c = true;
            }
            if(isDLIMI){
                tpaRequest.Is_Vendor_Name_Contains_DLIMI__c = true;
            }	
            if(isSpecificTPVendor) {
                if(isLAADOffering) {
                    tpaRequest.is_Specific_Vendors_LAAD_Off__c = true;
                }
                if(isAPLDOffSpecVendors) {
                    tpaRequest.is_Specific_Vendors_APLD_Off__c = true;
                }
                if(isLongPrescriData) {
                    tpaRequest.is_Specific_Vendors_Long_Prescr_Data__c = true;
                }
                if(isMedClaimsData) {
                    tpaRequest.is_Specific_Vendors_Medical_Claims_Data__c = true;
                }
            }            
        }

        if(!isRequestContainCRMUse && isVeeva && dataAssetComb != '') {
            manualReviewReasonList.add('IQVIA Legal Review Required - Specific Use/Offering Combination(s) requires Legal Final Review for Approval');
            tpaRequest.Is_Manually_Approved__c = true;
            addReasonCommercial(tpaRequest, 'IQVIA Legal Review Required - Specific Use/Offering Combination(s) requires Legal Final Review for Approval',null,null,null,null,null,null, null,null);
            System.debug('dataAssetComb :::'+dataAssetComb);
            approvalNotificationMap.put('IQVIA Legal Review Required - Specific Use/Offering Combination(s) requires Legal Final Review for Approval', dataAssetComb);
        }
        if(isMedpro && dataAssetCombMedpro != '') {
            manualReviewReasonList.add('IQVIA Legal Review Required - Specific Use/Offering Combination(s) requires Legal Final Review for Approval 2'); //will review later
            tpaRequest.Is_Manually_Approved__c = true;
            addReasonCommercial(tpaRequest,'IQVIA Legal Review Required - Specific Use/Offering Combination(s) requires Legal Final Review for Approval',null,null,null,null,null,null, null,null);
            System.debug('dataAssetComb :::'+dataAssetCombMedpro);
            approvalNotificationMap.put('IQVIA Legal Review Required - Specific Use/Offering Combination(s) requires Legal Final Review for Approval 2', dataAssetCombMedpro);
        }
        if(dataAssetCombForSecondaryReview != null && dataAssetCombForSecondaryReview != '') {
            isOfferingOnSecondaryReview = true;
            tpaRequest.Is_Manually_Approved__c = true;
            
            manualReviewReasonList.add('Offering Requires Secondary Commercial Review');
            
            dataAssetCombForSecondaryReview = dataAssetCombForSecondaryReview.substringBeforeLast(',');
            System.debug('dataAssetComb :::'+dataAssetCombForSecondaryReview);
            approvalNotificationMap.put('Offering Requires Secondary Commercial Review', dataAssetCombForSecondaryReview);
        }
        if(isExternalLicenseReuired) {
            manualReviewReasonList.add('Needs license or data supplier response');
            tpaRequest.Is_Manually_Approved__c = true;
            addReasonCommercial(tpaRequest,'Needs license or data supplier response',null,null,null,null,null,null, null,null);
            string countryWithOfferings = '';
            
            for(String country : countryToOffRequireExternalLic.keySet()) {
                if(countryWithOfferings == '') {
                    countryWithOfferings = country + ' - ' + countryToOffRequireExternalLic.get(country);
                } else {
                    countryWithOfferings += ', ' + country + ' - ' + countryToOffRequireExternalLic.get(country);
                }
            }
            approvalNotificationMap.put('Needs license or data supplier response', countryWithOfferings);
        }
        if(isNationOfferingSelectedWithCRMMDM) {
            manualReviewReasonList.add('National Level Offering(s) Selected for CRM / MDM Use(s) Requires Review');
            addReasonCommercial(tpaRequest,'National Level Offering(s) Selected for CRM / MDM Use(s) Requires Review',null,null,null,null,null,null, null,null);
            tpaRequest.Is_Manually_Approved__c = true;
            string countryWithNationOfferings = '';
            for(String country : countryToDataAssetMap.keySet()) {
                if(countryWithNationOfferings == '') {
                    countryWithNationOfferings = country + ' - ' + countryToDataAssetMap.get(country);
                } else {
                    countryWithNationOfferings += ', ' + country + ' - ' + countryToDataAssetMap.get(country);
                }
            }
            approvalNotificationMap.put('National Level Offering(s) Selected for CRM / MDM Use(s) Requires Review', countryWithNationOfferings);
        }
        if(lstATyicalCombinations != null && lstATyicalCombinations.size() > 0) {
            tpaRequest.Is_Manually_Approved__c = true;
            tpaRequest.Is_ATypical_Combination_Present__c = true;
            manualReviewReasonList.add('Use-Offering Atypical Combination is Present');
        }
        
        system.debug('tpaRequest.Always_approved_Use_Offering_Combination__c3:: ' + tpaRequest.Always_approved_Use_Offering_Combination__c);

        if(tpaRequest.Service_Provider_Address__c != null && tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null) {
            getDDNAckPendingRequests(tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c);
        } else {
            getDDNAckPendingRequests(tpaRequest.Service_Provider_Address__c);
        }

        if(DDNAckPendingRecords != null && DDNAckPendingRecords.size() > 0) {
            String ddnAckPendingRequestNumber = '';
            for(TPA_Request__C reqRcrd : DDNAckPendingRecords){
                ddnAckPendingRequestNumber+= reqRcrd.name + ', ';
            }
            ddnAckPendingRequestNumber = ddnAckPendingRequestNumber.removeEnd(', ');

            tpaRequest.Is_Manually_Approved__c = true;
            tpaRequest.DDN_Ack_Pending_Requests__c = ddnAckPendingRequestNumber;
            manualReviewReasonList.add('Vendor DDN Acknowledgement Outstanding');
            approvalNotificationMap.put('Vendor DDN Acknowledgement Outstanding', ddnAckPendingRequestNumber);
        } 
        
        if(tpaRequest.Is_Exhibit_Required__c) {
            tpaRequest.Is_Manually_Approved__c = true;
            String manualReviewReason = '';
            Boolean renewalTermApplied = false,newTermApplied=false,priRenewalTermApplied=false;
            /*if(tpaRequest.Parent_Request__c != null && tpaRequest.Parent_Request__r.Is_Renewed__c && tpaRequest.Parent_Request__r.Renewed_As__c == tpaRequest.Id) {
                manualReviewReason = 'Renewal has ' + manualReviewReason;
            }
            
            addReasonCommercial(tpaRequest, manualReviewReason, null, null, null, null, null, null, null);*/
            String key = '';
            String addTermKey = ';;;;;';
            for(TPA_Additional_Term__c addHocTerm: tpaRequest.TPA_Additional_Terms__r){
                if(addHocTerm.Is_Future_Approved__c){
                    key = addHocTerm.Type__c == 'Renewed' ? ('IQVIA Legal Approval Required: [Renew] TPA: Ad-hoc Additional Term Requested'+addTermKey) : ('IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested' + addTermKey);
                    key += addhocTerm.Term_Name__c + ';' + (addhocTerm.TPA_Legal_Entity_1__c != null ? addhocTerm.TPA_Legal_Entity_1__r.Name  : '');
                    futureApprovedAddHocTermsKeys.add(key);
                    if(addHocTerm.Type__c == 'Renewed'){
                        key = 'Renewal includes an Ad-hoc Additional Term and, if applicable, an Exhibit / Schedule Page from the prior TLLA' + addTermKey + addhocTerm.Term_Name__c + ';' + (addhocTerm.TPA_Legal_Entity_1__c != null ? addhocTerm.TPA_Legal_Entity_1__r.Name  : '');
                        futureApprovedAddHocTermsKeys.add(key);
                    }
                }
                if(addHocTerm.Type__c == 'Renewed' && addHocTerm.Is_Future_Approved__c){
                    priRenewalTermApplied = true;
                    addReasonCommercial(tpaRequest, 'Renewal includes an Ad-hoc Additional Term and, if applicable, an Exhibit / Schedule Page from the prior TLLA', null, null, null, null, null, null, null,addHocTerm);
                }
                else if(addHocTerm.Type__c == 'Renewed'){
                    renewalTermApplied = true;
                    addReasonCommercial(tpaRequest, 'Renewal includes an Ad-hoc Additional Term and, if applicable, an Exhibit / Schedule Page from the prior TLLA', null, null, null, null, null, null, null,addHocTerm);
                    addReasonCommercial(tpaRequest, 'IQVIA Legal Approval Required: [Renew] TPA: Ad-hoc Additional Term Requested', null, null, null, null, null, null, null,addHocTerm);
                }
                else{
                    newTermApplied = true;
                    addReasonCommercial(tpaRequest, 'IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested', null, null, null, null, null, null, null,addHocTerm);
                }
            }
            
            if(renewalTermApplied){
                manualReviewReason = 'Renewal includes an Ad-hoc Additional Term and, if applicable, an Exhibit / Schedule Page from the prior TLLA;IQVIA Legal Approval Required: [Renew] TPA: Ad-hoc Additional Term Requested';
                manualReviewReasonList.addAll(manualReviewReason.split(';'));
            }
            if(priRenewalTermApplied && !renewalTermApplied){
                manualReviewReason = 'Renewal includes an Ad-hoc Additional Term and, if applicable, an Exhibit / Schedule Page from the prior TLLA';
                manualReviewReasonList.add(manualReviewReason);
            }
            if(newTermApplied){
                manualReviewReason = 'IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested' ;
                manualReviewReasonList.add(manualReviewReason);
            }
            
        }
        
        Map<Id, List<IMS_Use_Offering_Atypical_Combination__c>> reqWithSecComb = TGRH_TPA_Commercial_Review.checkforSecReviewCombinations(new List<TPA_Request__c>{tpaRequest}, tpaDataAssets);
        if(reqWithSecComb != null && reqWithSecComb.containsKey(tpaRequest.Id)){
            system.debug('reqWithSecComb:' + reqWithSecComb);
            List<IMS_Use_Offering_Atypical_Combination__c> lstRequiredSecComb = reqWithSecComb.get(tpaRequest.Id);
            if(lstRequiredSecComb != null && lstRequiredSecComb.size() > 0 ){
                String allSecComb = '';
                String ruleCombination = '';
                Map<String, String> actionAndRuleCreteriaMap = new Map<String, String>();
                
                for(IMS_Use_Offering_Atypical_Combination__c comObj : lstRequiredSecComb){
                    ruleCombination = '';
                    if( (comObj.Secondary_Offering_Name__c != null ? comObj.Secondary_Offering_Name__r.Secondary_Asset_Name__c : comObj.Offering_Name__r.Asset_Name__c) != null) {
                        ruleCombination += '[ '+ comObj.Vendor_Name__r.Name+' - '+ comObj.Use_Name__r.Primary_Purpose_Name__c +' - '+ (comObj.Secondary_Offering_Name__c != null ? comObj.Secondary_Offering_Name__r.Secondary_Asset_Name__c : comObj.Offering_Name__r.Asset_Name__c) + ' ]';
                    }
                    else {
                        ruleCombination += '[ '+comObj.Vendor_Name__r.Name+' - '+ comObj.Use_Name__r.Primary_Purpose_Name__c + ' ]';
                    }
                    if(actionAndRuleCreteriaMap.containsKey(comObj.Action_Needed_By__c)) {
                        actionAndRuleCreteriaMap.put(comObj.Action_Needed_By__c, actionAndRuleCreteriaMap.get(comObj.Action_Needed_By__c)+ ', ' + ruleCombination);
                    }
                    else {
                        actionAndRuleCreteriaMap.put(comObj.Action_Needed_By__c, ruleCombination);
                    }                    
                    if(comObj.Secondary_Offering_Name__c != null){

                        addReasonCommercial(tpaRequest, 'Vendor - Use - Offering Secondary Review by ',  null, fullOfferingName(null, TGRH_TPA_Commercial_Review.mapSecRuleWithSecOffering.get(comObj.id)), comObj.Use_Name__r.Primary_Purpose_Name__c, null, null, comObj.Use_Category__r.Category_Name__c, comObj,null);
                    }
                    else if(comObj.Offering_Name__c != null){

                        addReasonCommercial(tpaRequest, 'Vendor - Use - Offering Secondary Review by ',  null, fullOfferingName(TGRH_TPA_Commercial_Review.mapSecRuleWithPriOffering.get(comObj.id), null), comObj.Use_Name__r.Primary_Purpose_Name__c, null, null, comObj.Use_Category__r.Category_Name__c, comObj,null);
                    }
                    else{

                        addReasonCommercial(tpaRequest, 'Vendor - Use Secondary Review by ',  null, null, comObj.Use_Name__r.Primary_Purpose_Name__c, null, null, comObj.Use_Category__r.Category_Name__c, comObj,null);
                    }
                }

                system.debug('updatedSecReviews:' + updatedSecReviews);

                if(!actionAndRuleCreteriaMap.isEmpty()) {
                    for(String key : actionAndRuleCreteriaMap.keySet()) {
                        allSecComb += Key + ' -: ' + actionAndRuleCreteriaMap.get(key) + '<br><br>';
                    }
                }
                allSecComb = allSecComb.removeEnd(', ');
                tpaRequest.Is_Manually_Approved__c = true;
                manualReviewReasonList.add('Vendor, Use, and/or Offering(s) Requires Secondary Review');
                approvalNotificationMap.put('Vendor, Use, and/or Offering(s) Requires Secondary Review', allSecComb);
            }
        }

        String VSNCombination = '', UseName = '' , PrimaryOffName = '', SecOffName = '', OffCountry = '' ;

        for(TPA_Offering_Notification_Mapping__c offNotMapObj: SRV_TPA_TPARequest.dynamicOfferingsNotificationListForVendor) {
            UseName = ''; PrimaryOffName = ''; SecOffName = ''; OffCountry = '';
            if(offNotMapObj.IMS_TPA_Purpose__c != null && offNotMapObj.IMS_TPA_Purpose__r.Primary_Purpose_Name__c != null && offNotMapObj.IMS_TPA_Purpose__r.Primary_Purpose_Name__c != ''){
                UseName = 'Use Name - ' + offNotMapObj.IMS_TPA_Purpose__r.Primary_Purpose_Name__c + ', ';
            }
            if(offNotMapObj.IMS_Primary_Data_Asset__c != null && offNotMapObj.IMS_Primary_Data_Asset__r.Asset_Name__c != null && offNotMapObj.IMS_Primary_Data_Asset__r.Asset_Name__c != ''){
                PrimaryOffName = 'Primary Offering Name - '+ offNotMapObj.IMS_Primary_Data_Asset__r.Asset_Name__c + ', ';
            }
            if(offNotMapObj.IMS_Secondary_Data_Asset__c != null && offNotMapObj.IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c != null && offNotMapObj.IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c != ''){
                SecOffName = 'Secondary Offering Name - '+ offNotMapObj.IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c + ', ';
            }
            if(offNotMapObj.Country__c != null){
                OffCountry = 'Offering Country - '+ offNotMapObj.Country__c ;
            }
            if(VSNCombination == ''){
                VSNCombination = UseName + PrimaryOffName + SecOffName + OffCountry ;
            }
            else if(!VSNCombination.contains(UseName+ PrimaryOffName + SecOffName + OffCountry)){
                VSNCombination += ':'+UseName + PrimaryOffName + SecOffName + OffCountry ;
            }
        }
        /*if(VSNCombination != '') {
            approvalNotificationMap.put('Vendor Specific Dynamic Notification is selected', VSNCombination);
          //  tpaRequest.Is_Manually_Approved__c = true;
        }*/
        if(isIncentiveCompensationWithLAAD) {
            tpaRequest.Is_Manually_Approved__c = true;
            manualReviewReasonList.add('Combination of LAAD and \'Incentive Compensation\' selected');
        }

        /*if(SRV_TPA_TPARequest.isDirectToClientExeMode || SRV_TPA_TPARequest.isQuintilesIMSSalesExeMode) {
            manualReviewReasonList.add('Vendor Specific Dynamic Notification is selected');
            tpaRequest.Is_Manually_Approved__c = true;
            addReasonCommercial(tpaRequest, 'Vendor Specific Dynamic Notification is selected',null,null,null,null,null, null, null,null);
        }*/

        for(string manualReviewReason : manualReviewReasonList) {
            if(manualReviewReason == 'IQVIA Legal Review Required - Specific Use/Offering Combination(s) requires Legal Final Review for Approval 2') {
                manualReviewReason = manualReviewReason.substringBeforeLast('2');
            }
            tpaRequest.Manual_Trigger_Reasons__c += manualReviewReason + '; ';
        }
        tpaRequest.Manual_Trigger_Reasons__c = tpaRequest.Manual_Trigger_Reasons__c.substringBeforeLast(';');
        system.debug('tpaRequest.Manual_Trigger_Reasons__c after :: ' + tpaRequest.Manual_Trigger_Reasons__c);
        
        //will review later start
        if(!tpaRequest.Is_Manually_Approved__c && (lstATyicalCombinations == null || lstATyicalCombinations.size() == 0 )) {
            noManualReviewForTPA = true; 
            tpaRequest.Requires_Manual_Review__c = false; 
            tpaRequest.Is_ATypical_Combination_Present__c = false;
        }
        else {
            tpaRequest.Requires_Manual_Review__c = true;
            tpaRequest.Is_Manually_Approved__c = true;
            if(lstATyicalCombinations != null && lstATyicalCombinations.size() > 0 && !retriggerManualReviewEmail ) {
                tpaRequest.Is_ATypical_Combination_Present__c = true;                
                upsert lstATyicalCombinations;
            }
            else {
                tpaRequest.Is_ATypical_Combination_Present__c = false;
            }
        }        
        //will review later end

        system.debug('DDNAckPendingRecords: ' + DDNAckPendingRecords);

        if(!retriggerManualReviewEmail) {
            if(isExpertAnalysisUseSelected){
                if(tpaRequest.Client_Confirmation_Requested_Response__c == '' || tpaRequest.Client_Confirmation_Requested_Response__c == null){
                    if(tpaRequest.Pending_Acknowledgements__c == null || tpaRequest.Pending_Acknowledgements__c == ''){
                        tpaRequest.Pending_Acknowledgements__c =  UTL_TPA.Pending_Client_Acknowledgements ;
                    }
                    else if(tpaRequest.Pending_Acknowledgements__c.indexOf(UTL_TPA.Pending_Client_Acknowledgements) == -1){
                        tpaRequest.Pending_Acknowledgements__c = tpaRequest.Pending_Acknowledgements__c + '; ' + UTL_TPA.Pending_Client_Acknowledgements ;
                    }
                    tpaRequest.Client_Confirmation_Req_Form_Sent_Date__c = Date.today();
                    sendEmailDirectToClient(tpaRequest, 'Email Client Confirmation Req', '');
                }
            }
            else if(!isExpertAnalysisUseSelected){
                tpaRequest.Client_Confirmation_Req_Form_Sent_Date__c = null;
                tpaRequest.Client_Confirmation_Requested_Response__c = '';
                tpaRequest.Client_Confirmation_Req_Response_Date__c = null;
                if(tpaRequest.Pending_Acknowledgements__c != null && tpaRequest.Pending_Acknowledgements__c.indexOf(UTL_TPA.Pending_Client_Acknowledgements) != -1){
                    string strPickListValue = tpaRequest.Pending_Acknowledgements__c;
                    if(strPickListValue != null) {
                        List<string> lstPicklistValues = strPickListValue.split(';');
                        string strValueToRemove = UTL_TPA.Pending_Client_Acknowledgements;
                        if(lstPicklistValues != null && lstPicklistValues.contains(strValueToRemove)){
                            lstPicklistValues.remove(lstPicklistValues.indexOf(strValueToRemove));
                        }
                        tpaRequest.Pending_Acknowledgements__c = String.join(lstPicklistValues,';');
                    }
                }
            } 
            if(tpaRequest.Request_Type__c != 'renew' && tpaRequest.is_Bulk_TPA_Request__c != true){
                if(isOtherUseSelected){
                    sendEmailDirectToClient(tpaRequest, 'Email Direct to Client message', bodyTextForOtherUse);
                }
                if(isOtherOfferingSelected) {
                    String bodyText = '<table style="width:100%; border-collapse: collapse">' +  '<tr><th style="font-size:13px ;font-family:arial;border: 2px solid black;padding: 0 5px 0 5px;background-color:#0CB6F3">Country of Offering</th>' + '<th style="font-size:13px ;font-family:arial;border: 2px solid black;padding: 0 5px 0 5px;background-color:#0CB6F3">Category of Offering</th>' + '<th style="font-size:13px ;font-family:arial;border: 2px solid black;padding: 0 5px 0 5px;background-color:#0CB6F3">‘Offering of Other’</th></tr>';
                    bodyText += bodyTextForOtherOffering; 
                    bodyText += '</table>' + '</br>';
                    
                    sendEmailDirectToClient(tpaRequest, 'Email Direct to Client Offering', bodyText);
                }
            }
            if(DDNAckPendingRecords != null && DDNAckPendingRecords.size() > 0 && SRV_TPA_TPARequest.isDynamicNotiAckRecived) {
                system.debug('in IF condition DDN Dtatus: ');
                sendMailtoTPProcessorAbtStatusUpdate(tpaRequest, tpaRequest.request_status__c, 'Pending Vendor Response on Data Destruction from Prior TPAs');
                tpaRequest.request_status__c = 'Pending Vendor Response on Data Destruction from Prior TPAs';
            }
            else if(tpaRequest.Is_Manually_Approved__c && !SRV_TPA_TPARequest.includeAmaAttributesOnly && (tpaRequest.isClientOnComplianceHold__c || tpaRequest.isVendorOnComplianceHold__c)) {
                tpaRequest.Request_Status__c = 'Hold for TPA non-compliance';
            }
            else if((tpaRequest.Is_Manually_Approved__c || manualReviewReasonList.size() > 0) && !SRV_TPA_TPARequest.includeAmaAttributesOnly) {
                tpaRequest.Request_Status__c = Label.TPA_In_Review_By_IQVIA_Status;
            }
            else if(tpaRequest.Is_Manually_Approved__c && SRV_TPA_TPARequest.includeAmaAttributesOnly) {
                tpaRequest.Request_Status__c = 'TPA Approved Awaiting AMA Approval';
            }
            else
            {
                tpaRequest.Request_Status__c = 'In Auto Approval Process';
            }
            system.debug('tpaRequest.Request_Status__c: '+ tpaRequest.Request_Status__c );
            
            if(watchListsToBeUpserted.size() > 0) {
                upsert watchListsToBeUpserted;
            }
            if(comRevId == null && isRunCommercialAutoLogic) {
                //insertReasons();
                insertCommercialReasons();   
            }
        }

        if(Test.isRunningTest()){
            manualReviewReasonList.add('Vendor Requires Review');
            manualReviewReasonList.add('Vendor Requires Secondary Review');
        }

        return tpaRequest;
    }
    public static void sendNotificationfor50OrMoreLicenses( TPA_Request__c request){
        String subjText;
        String bodyText = '';
        String bodyTextEn;
        String preferredLanguage;
        String templateID;
        String emailBody;
        String fontStyle = '<div style="font-size:13px !important;font-family:arial !important;">';
        List<String> ccAddresses = new List<String>();
        Map<String, TPA_Text_Editor__c> mapTpaTextAdditionalTerms = UTL_TPA.getTpaTextAdditionalTerms(tpaRequest);
        Map<String, TPA_Additional_Term__c> mapTpaAdditionalTerms = UTL_TPA.getTpaAdditionalTerms(tpaRequest);
        
        TPA_Request__C tpaRequestForPurpose = [Select Id,Name,Service_Provider_Address__c,Vendor_Billing_Mailing_Country__c,is_LAAD_Response_Acknowledged__c,Parent_Request__r.Renewed_Type__c,Is_VSN_Acknowlege_By_Client__c, 
                                    (SELECT Included_Category_s_In_Renewal__c
                                    ,Excluded_Category_s_In_Renewal__c
                                    ,Additional_Offerings_in_Renewal__c
                                    ,Excluded_Offerings_In_Renewal__c
                                    ,Included_Uses_In_Renewal__c
                                    ,Excluded_Uses_In_Renewal__c
                                    FROM TPA_Agreement_Additional_Fields__r),(select id,IMS_Legal_Entity__c,Purpose__c,Purpose__r.Id from Purposes__r), (SELECT Id, TPA_Offering_Notification_Record__c, Type__c FROM TPA_Use_Offering_Atypical_Combinations__r WHERE Type__c = 'Offering Notification Record') From TPA_Request__c where Id =: tpaRequest.Id ];
        
        Map<String, TPA_Offering_Notification_Mapping__c> mapTpaDynamicNotifications = UTL_TPA.getmapTpaDynamicNotifications(tpaRequestForPurpose); 
        
        TPA_Agreement_Additional_Field__c agreementAdditionalFieldData = new TPA_Agreement_Additional_Field__c();
        if(tpaRequestForPurpose.TPA_Agreement_Additional_Fields__r != null && tpaRequestForPurpose.TPA_Agreement_Additional_Fields__r.size() > 0) {
            agreementAdditionalFieldData = tpaRequestForPurpose.TPA_Agreement_Additional_Fields__r[0];
        }
        
        preferredLanguage = request.vendor_language__c != null ? request.vendor_language__c : 'English';
        templateID = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email for 50 Or More Licenses'+preferredLanguage).Translated_Template_Id__c;
        system.debug('templateID1'+templateID);
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateID != '' && templateID != null) {        
            try {
                system.debug('templateID'+templateID);
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, request.Id);
            } catch(Exception exp) {
                System.debug(templateID + ' Email Failed: ' + exp.getMessage());
            }
            emailBody = emailNotToSend.getHTMLBody();
            subjText = emailNotToSend.getSubject();
            
            Set<String> uniqueUseLst = new Set<String>();
            uniqueUseLst.addAll(tpaRequest.List_Of_Uses__c.split(','));
            //String setString = string.valueof(uniqueUseLst).replace('{', '').replace('}', '');
            String setString = String.join(new List<String>(uniqueUseLst),',');
            
            if( (agreementAdditionalFieldData.Additional_Offerings_in_Renewal__c != null && agreementAdditionalFieldData.Additional_Offerings_in_Renewal__c.length() > 1000) ||
               (agreementAdditionalFieldData.Excluded_Offerings_In_Renewal__c != null   && agreementAdditionalFieldData.Excluded_Offerings_In_Renewal__c.length() > 1000)){
                   bodytext += fontStyle + '<a href = \'' + UTL_TPA.tpaSetting.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_OfferingsDetails&reqId=' + tpaRequest.id + '\'> Click Here for Offering Details <a></div>';
               }
               else{
                   
                   bodytext += fontStyle + '<br><br><b>Country(s) of Offerings:</b>  ' + tpaRequest.Countries_of_offerings__c ;

                   if(tpaRequest.Parent_Request__c != null && tpaRequest.Parent_Request__r.Is_Renewed__c && tpaRequest.Parent_Request__r.Renewed_As__c == tpaRequest.Id && tpaRequestForPurpose.Parent_Request__r.Renewed_Type__c == 'Modified Renewal') {
                       bodytext += '<br><br><b>Modified Renewal Offering changes:</b> ' ;
                       bodytext += '<br><b>Modified Renewal Offerings Added:</b>  ' + ((agreementAdditionalFieldData.Additional_Offerings_in_Renewal__c != null) ? agreementAdditionalFieldData.Additional_Offerings_in_Renewal__c : 'None' );
                       bodytext += '<br><b>Modified Renewal Offerings Excluded:</b>  ' + ((agreementAdditionalFieldData.Excluded_Offerings_In_Renewal__c != null) ? agreementAdditionalFieldData.Excluded_Offerings_In_Renewal__c : 'None' );
                   }
                   
                   bodytext += '<br><br><b>Category(s) of Offerings:</b>  ' + tpaRequest.Category_of_Offerings__c ;
                   
                   if(tpaRequest.Parent_Request__c != null && tpaRequest.Parent_Request__r.Is_Renewed__c && tpaRequest.Parent_Request__r.Renewed_As__c == tpaRequest.Id && tpaRequestForPurpose.Parent_Request__r.Renewed_Type__c == 'Modified Renewal') {
                       bodytext += '<br><b>Modified Renewal Category of Offerings Added:</b>  ' + ((agreementAdditionalFieldData.Included_Category_s_In_Renewal__c != null) ? agreementAdditionalFieldData.Included_Category_s_In_Renewal__c : 'None') ;
                       bodytext += '<br><b>Modified Renewal Category of Offerings Excluded:</b>  ' + ((agreementAdditionalFieldData.Excluded_Category_s_In_Renewal__c != null) ? agreementAdditionalFieldData.Excluded_Category_s_In_Renewal__c : 'None' );
                       
                   }
                   
                   bodytext += '<br><br><b>Requested Uses:</b>  ' + setString ;           
                   if(tpaRequest.Parent_Request__c != null && tpaRequest.Parent_Request__r.Is_Renewed__c && tpaRequest.Parent_Request__r.Renewed_As__c == tpaRequest.Id && tpaRequestForPurpose.Parent_Request__r.Renewed_Type__c == 'Modified Renewal') {
                       bodytext += '<br><b>Modified Renewal Uses Added:</b>  ' + ((agreementAdditionalFieldData.Included_Uses_In_Renewal__c != null) ? agreementAdditionalFieldData.Included_Uses_In_Renewal__c : 'None') ;
                       bodytext += '<br><b>Modified Renewal Uses Excluded:</b>  ' + ((agreementAdditionalFieldData.Excluded_Uses_In_Renewal__c != null) ? agreementAdditionalFieldData.Excluded_Uses_In_Renewal__c : 'None') ;
                   }
                   bodyText += '</div>';
               }
            
            bodytext += fontStyle + '<br><br><B>Collective Uses/Offerings Table View: </B>'+ '<a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_OfferingsWithCategory&reqId='+ tpaRequest.Id+' >Click here</a></div>';


            List<TPA_Text_Editor__C> offeringSpecificTextAddTerms = new List<TPA_Text_Editor__C>();
            List<TPA_Additional_Term__c> offeringSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            List<TPA_Additional_Term__c> useSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            List<TPA_Additional_Term__c> useOfferingSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            Set<TPA_Offering_Notification_Mapping__c> DynamicNotifications = new Set<TPA_Offering_Notification_Mapping__c>();
            if(mapTpaTextAdditionalTerms != null || mapTpaAdditionalTerms != null  || mapTpaDynamicNotifications != null){
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Additional Term(s) under TLLA Schedule A: </B></div>';
                if(mapTpaTextAdditionalTerms != null){
                    /*if(mapTpaTextAdditionalTerms.containsKey('is_Veeva_Use_CRM__c:TPA_Request__c')){
                        bodytext += '<br><br>' + fontStyle + mapTpaTextAdditionalTerms.get('is_Veeva_Use_CRM__c:TPA_Request__c').content__c + '</div>'; 
                    }*/
                    if(mapTpaTextAdditionalTerms.containsKey('AI_ML_Restrictions:TPA_Request__c')){
                        bodytext += '<br><br>' + fontStyle + mapTpaTextAdditionalTerms.get('AI_ML_Restrictions:TPA_Request__c').content__c + '</div>'; 
                    }
                    system.debug('mapTpaTextAdditionalTerms'+mapTpaTextAdditionalTerms.values());
                    for( String addKey : mapTpaTextAdditionalTerms.keyset()) {
                        if(addKey.split(':')[1] == 'TPA_Request__c'){
                            if(!(addKey.split(':')[0] == 'is_Veeva_Use_CRM__c' ||  addKey.split(':')[0] == 'AI_ML_Restrictions')){
                                TPA_Text_Editor__C listEditor = mapTpaTextAdditionalTerms.get(addKey);
                                bodytext += '<br><br>' + fontStyle + mapTpaTextAdditionalTerms.get(addKey).Content__c + '</div>';
                            }
                        }
                        if(addKey.split(':')[1] == 'IMS_Legal_Entity__c'){
                            TPA_Text_Editor__C listEditor = mapTpaTextAdditionalTerms.get(addKey);
                           // if(TpaTextTerms.contains(listEditor.Page_Name__c)){
                                offeringSpecificTextAddTerms.add(mapTpaTextAdditionalTerms.get(addKey));
                          //  }
                        }
                    }
                }
                system.debug('offeringSpecificTextAddTerms'+offeringSpecificTextAddTerms);
                CNT_TPA_RequestSubmissionForm.getLimitsMessage();
                if(mapTpaAdditionalTerms != null){
                    for( String addKey : mapTpaAdditionalTerms.keyset()) {
                        if(addKey.split(':')[1] == 'General Ad-Hoc Term'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            bodytext += '<br><br>' + fontStyle + '<strong><u>' + addhocTerm.Term_Name__c + ':</u></strong>';
                            bodytext += '<br><br>'  + addhocTerm.Addtional_Term__c ;
                            if(addhocTerm.Exhibit_Attached__c && addhocTerm.Attachments != null && addhocTerm.Attachments.size() > 0){
                                String attchId = addhocTerm.Attachments[0].Id;
                                bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                            }
                            bodytext += '</div>';
                        }
                        if(addKey.split(':')[1] == 'Data Asset Specific Ad-Hoc Term'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            offeringSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                        if(addKey.split(':')[1] == 'Use Specific Ad-Hoc Terms'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            useSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                        if(addKey.split(':')[1] == 'Use/Offering Specific Ad-Hoc Terms'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            useOfferingSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                    }
                }
                CNT_TPA_RequestSubmissionForm.getLimitsMessage();
                if(mapTpaDynamicNotifications != null){
                    for( String addKey : mapTpaDynamicNotifications.keyset()) {
                        DynamicNotifications.add(mapTpaDynamicNotifications.get(addKey));
                       /* TPA_Offering_Notification_Mapping__c offNotify =  mapTpaDynamicNotifications.get(addKey);
                        set<String> offeringDupCheck = new set<String>();
                        for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.Associated_Offering_to_Review__c == null){
                                DynamicNotifications.add(mapTpaDynamicNotifications.get(addKey));
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null && !offeringDupCheck.contains(comRev.Associated_Offering_to_Review__c) && (comRev.Associated_Offering_to_Review__c.indexOf(offNotify.Primary_Data_Asset_Name__c) != -1 || comRev.Associated_Offering_to_Review__c.indexOf(offNotify.Secondary_Data_Asset_Name__c) != -1)){
                                offeringDupCheck.add(comRev.Associated_Offering_to_Review__c);
                                DynamicNotifications.add(mapTpaDynamicNotifications.get(addKey));
                            }
                        }*/
                    }
                }
            }
            if((offeringSpecificTextAddTerms != null && offeringSpecificTextAddTerms.size() > 0) || (offeringSpecificAddhocTerms != null && offeringSpecificAddhocTerms.size() > 0) || (useSpecificAddhocTerms != null && useSpecificAddhocTerms.size() > 0) || (useOfferingSpecificAddhocTerms != null && useOfferingSpecificAddhocTerms.size() > 0) || (DynamicNotifications != null && DynamicNotifications.size() > 0)){
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Use Specific Additional Term(s) under TLLA Schedule A:</B></div>';
                if(useSpecificAddhocTerms != null && useSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: useSpecificAddhocTerms){
                        bodytext += '<br><br>' + fontStyle+ '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                        bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                        if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                            String attchId = addhoc.Attachments[0].Id;
                            bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                        }
                        bodytext += '</div>'; 
                    }
                }
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Use/Offering Specific Additional Term(s) under TLLA Schedule A:</B></div>';
                if(useOfferingSpecificAddhocTerms != null && useOfferingSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: useOfferingSpecificAddhocTerms){
                        bodytext += '<br><br>' + fontStyle+ '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                        bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                        if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                            String attchId = addhoc.Attachments[0].Id;
                            bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                        }
                        bodytext += '</div>'; 
                    }
                }
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Offering Specific Additional Term(s) under TLLA Schedule A:</B></div>';
                if(offeringSpecificTextAddTerms != null && offeringSpecificTextAddTerms.size() > 0){ 
                    for(TPA_Text_Editor__C txt: offeringSpecificTextAddTerms){
                        bodytext += '<br><br>' + fontStyle + txt.Content__c + '</div>';
                    }
                }
                CNT_TPA_RequestSubmissionForm.getLimitsMessage();
                if(offeringSpecificAddhocTerms != null && offeringSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: offeringSpecificAddhocTerms){
                        bodytext += '<br><br>' + fontStyle+ '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                        bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                        if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                            String attchId = addhoc.Attachments[0].Id;
                            bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                        }
                        bodytext += '</div>';
                     /* for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.TPA_Additional_Term__c != null && comRev.TPA_Additional_Term__c == addhoc.Id){
                                bodytext += '<br><br><b>'+addhoc.Name +'</b>';
                                bodytext += '<br>'+addhoc.Addtional_Term__c;
                                break;
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null && comRev.Associated_Offering_to_Review__c.indexOf(':') != -1 && ( (addhoc.Primary_Offering_Name__c != null && addhoc.Primary_Offering_Name__c == comRev.Associated_Offering_to_Review__c.split(':')[0] ) || ( addhoc.Secondary_Offering_Name__c != null && addhoc.Secondary_Offering_Name__c == comRev.Associated_Offering_to_Review__c.split(':')[0] ) )){
                                bodytext += '<br><br><b>'+addhoc.Name +'</b>';
                                bodytext += '<br>'+addhoc.Addtional_Term__c;
                                break;
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null && ( (addhoc.Primary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c == addhoc.Primary_Offering_Name__c) || (addhoc.Secondary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c == addhoc.Secondary_Offering_Name__c ))){
                                bodytext += '<br><br><b>'+addhoc.Name +'</b>';
                                bodytext += '<br>'+addhoc.Addtional_Term__c;
                                break;
                            }
                        }*/
                        
                    }
                }
                String DynNotiDuplicatecheck = '';
                if(DynamicNotifications != null && DynamicNotifications.size() > 0){
                    for(TPA_Offering_Notification_Mapping__c offNotify: DynamicNotifications){
                        String offNotifyContent = offNotify.Offering_Notifications__r.Content__c;
                        if(!DynNotiDuplicatecheck.contains(offNotifyContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', ''))){
                            DynNotiDuplicatecheck += offNotifyContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', '') + '|-|';
                            system.debug('in dynamic notification : ' + offNotifyContent);
                            bodytext += '<br><br>' + fontStyle + offNotifyContent + '</div>';
                        }
                    }
                }
            }
            List<String> toAddresses = UTL_TPA.Tpa50orMoreLicensesEmailIds.split(';');
            String tempBodyText = '';
            tempBodyText = emailBody.replace('OFFERINGS_DETAILS',bodytext);
            tempBodyText = tempBodyText.replace('Client_Country', tpaRequest.Client_Address__r.Country__c);
            tempBodyText = tempBodyText.replace('Total_Offerings_Selected__c', tpaRequest.Total_Offerings_Selected__c.intValue() + '');
            tempBodyText = tempBodyText.replace('Unique_number_of_data_assets__c', tpaRequest.Unique_number_of_data_assets__c.intValue() + '');
            
            if(tpaRequest.Parent_Request__c != null && tpaRequest.Parent_Request__r.Is_Renewed__c && tpaRequest.Parent_Request__r.Renewed_As__c == tpaRequest.Id) {
                String renewdType = '<br><b>Renewal:</b> ' + tpaRequestForPurpose.Parent_Request__r.Renewed_Type__c;
                tempBodyText = tempBodyText.replace('Renewed_As_Is_or_Modified_Renewal', renewdType);
            }
            else{
                tempBodyText = tempBodyText.replace('Renewed_As_Is_or_Modified_Renewal', '');
            }
            /*addTPProcessorInitials = true;
            if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                assignedTPProcessorName = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
            }*/
            sendEmailThroughWorkflow(toAddresses, null, 'SendTPA500rMoreLicensesEmail', null, tpaRequest.Id, null, subjText, FALSE, tempBodyText, TRUE, TRUE, tpaRequest);
            //addTPProcessorInitials = false;
        }
    }

    public static String findResponsibility(String reason) {
        if(responsibiltyMap == null) {
            responsibiltyMap = new Map<String,String>();
            
            List<TPA_Table_Of_Responsibility_Settings__c> listOfResponsibilty = TPA_Table_Of_Responsibility_Settings__c.getAll().values(); 
            for(TPA_Table_Of_Responsibility_Settings__c resp : listOfResponsibilty) {
                responsibiltyMap.put(resp.MANUAL_TRIGGER_REASONS__c.trim().toLowerCase(), resp.OWNER_REVIEW__c.trim());
            }
            return responsibiltyMap.get(reason.trim().toLowerCase());
        }
        else {
            return responsibiltyMap.get(reason.trim().toLowerCase());
        }
    }

    public static String getComRevKey(TPA_Commercial_Review__c comRev,String countryOfOffering,String offCategory,String addTermName,String addTermLegalName) {
        String Key = '';
        Key += comRev.Manual_Review_Reason__c == null ? '' : comRev.Manual_Review_Reason__c ;
        Key += comRev.Associated_Use_to_Review__c == null ? ';' : (';'+comRev.Associated_Use_to_Review__c) ;
        Key += comRev.Associated_Offering_to_Review__c == null ? ';' : (';' + comRev.Associated_Offering_to_Review__c) ;
        if(comRev.Action_Needed_By__c != null && (comRev.Action_Needed_By__c.contains('Vendor - Use - Offering Secondary Review by') || comRev.Action_Needed_By__c.contains('Vendor - Use Secondary Review by')) ){
            Key += comRev.Receiver_s_Email__c == null ? ';' : (';' + comRev.Receiver_s_Email__c) ;
        }
        Key += (countryOfOffering != null && countryOfOffering != '') ? (';' + countryOfOffering) : ';';
        Key += (offCategory != null && offCategory != '') ? (';' + offCategory) : ';';
        Key += (addTermName != null && addTermName != '') ? (';' + addTermName) : ';';
        Key += (addTermLegalName != null && addTermLegalName != '') ? (';' + addTermLegalName) : ';';
        
        return Key;
    }

    public static void addReasonCommercial(TPA_Request__c request, String manualApprovalReason, String email, String offeringDetail, String useDetail, TPA_Data_Asset__c dataAsset, TPA_Secondary_Data_Asset__c secondaryDataAsset, String useCategory, IMS_Use_Offering_Atypical_Combination__c atyObj,TPA_Additional_Term__c addHocTerm) {
       // System.debug('isRunCommercialAutoLogic: in addcommercialreason method' + isRunCommercialAutoLogic);
        if(isRunCommercialAutoLogic) {
            TPA_Commercial_Review__c newReason = new TPA_Commercial_Review__c();   
            String countryOfOffering = '',offeringCategory = '',addTermName='',addTermLegalName='';
             
            newReason.TPA_Request__c = request.Id;

            newReason.Manual_Review_Reason__c = manualApprovalReason;
            newReason.Receiver_s_Email__c = email; 
            String temoraryDetails = '';
           
           
            
            if(offeringDetail != null) {
                newReason.Associated_Offering_to_Review__c	= offeringDetail;
            }
            if(useDetail != null) {
                newReason.Associated_Use_to_Review__c = useDetail;
            }
            if(dataAsset != null){
                //newReason.Primary_Data_Asset__c	= dataAsset.Id;
                countryOfOffering = dataAsset.BU__c;
				newReason.BU__c = dataAsset.BU__c;
                newReason.Associated_Offering_Category__c = dataAsset.Geo_Level__c;
                offeringCategory = dataAsset.Geo_Level__c;
            }
            if(secondaryDataAsset != null){
                //newReason.Secondary_Data_Asset__c = secondaryDataAsset.Id;
                countryOfOffering = secondaryDataAsset.BU__c;
                newReason.BU__c = secondaryDataAsset.BU__c;
				newReason.Associated_Offering_Category__c = secondaryDataAsset.Secondary_Asset_Geo_Level__c;
                offeringCategory = secondaryDataAsset.Secondary_Asset_Geo_Level__c;
            }
            if(useCategory != null){
                newReason.Associated_Offering_s_Use_Category_s__c = useCategory;
            }
            if(atyObj != null){
                newReason.Sec_Review_Master__c	= atyObj.Id;
                countryOfOffering = atyObj.Offering_Country_del__c;
                newReason.BU__c = countryOfOffering;
            }
            if(addHocTerm != null){
                newReason.TPA_Additional_Term__c = addHocTerm.Id;
                addTermName = addhocTerm.Term_Name__c;
                addTermLegalName = addHocTerm.TPA_Legal_Entity_1__r.Name;
            }

            if(manualApprovalReason == 'Vendor Requires Secondary Review' ) {
                newReason.Status__c = 'Awaiting to Send: Primary Commercial Owner Not Complete';
                newReason.Action_Needed_By__c = 'Management';
                newReason.TP_US_Email__c = UTL_TPA.TPUSEMailAddress;
            } 
            else if(manualApprovalReason == 'Offering Requires Secondary Commercial Review') {
                newReason.Status__c = 'Awaiting to Send: Primary Commercial Owner Not Complete';
                newReason.Action_Needed_By__c = 'Commercial Owner'; 
                newReason.TP_Country_Email__c = request.TP_Processor_Email__c; 
                newReason.TP_US_Email__c = UTL_TPA.TPUSEMailAddress;               
            }
            else if(UTL_TPA.isManualReviewAddHoc(manualApprovalReason)) {
                newReason.Status__c = 'Awaiting to Send: Primary Commercial Owner Not Complete';
                newReason.Action_Needed_By__c = 'Legal'; 
                newReason.TP_Country_Email__c = request.TP_Processor_Email__c;  
                newReason.Receiver_s_Email__c =  TPA_Settings__c.getOrgDefaults() != null ? TPA_Settings__c.getOrgDefaults().Legal_Review_Email__c : '';  
                newReason.TP_US_Email__c = UTL_TPA.TPUSEMailAddress;            
            }
            else if(manualApprovalReason == 'Vendor - Use - Offering Secondary Review by ' || manualApprovalReason == 'Vendor - Use Secondary Review by ') {
                newReason.Manual_Review_Reason__c = atyObj.Action_Needed_By__c.contains('Mgmt') ? manualApprovalReason + 'Mgmt' : manualApprovalReason + 'Legal';
                newReason.Status__c = 'Awaiting to Send: Primary Commercial Owner Not Complete';
                newReason.Action_Needed_By__c = atyObj.Action_Needed_By__c;
                newReason.Receiver_s_Email__c = atyObj.Action_Needed_By__c.contains('Mgmt') ? atyObj.Mgmt_Review_email__c : atyObj.Legal_Review_Email__c;
                newReason.TP_Country_Email__c = request.TP_Processor_Email__c;   
                newReason.TP_US_Email__c = UTL_TPA.TPUSEMailAddress;      
            }
            else {
                newReason.Status__c = 'Awaiting Review';
                String owners = findResponsibility(manualApprovalReason);    
                if(owners != null) {
                    if(owners.contains('Commercial')) {
                        newReason.Action_Needed_By__c = 'Commercial Owner';
                    }
                    else if(owners.contains('TP-Country') || owners.contains('TP-US')) {
                        newReason.Action_Needed_By__c = owners;                    
                    }
                    if(owners.contains('TP-US')) {
                        newReason.TP_US_Email__c = UTL_TPA.TPUSEMailAddress;
                    } 
                    if(owners.contains('TP-Country')) {
                        newReason.TP_Country_Email__c = manualApprovalReason == 'Vendor Signum: Requires to be Invoiced' ? UTL_TPA.TPNordicsEmailID : request.TP_Processor_Email__c;
                    }
                } else {
                    newReason.Action_Needed_By__c = owners;
                }
            }

            if(newReason != null && newReason.Receiver_s_Email__c!= null && newReason.Receiver_s_Email__c != ''){
                 for(String revID : newReason.Receiver_s_Email__c.split(';')){
                    String CorrectOffName = '';
                    if(newReason.Associated_Offering_to_Review__c != null && newReason.Associated_Offering_to_Review__c.contains(':')){
                        CorrectOffName = resolvedOfferingName(newReason.Associated_Offering_to_Review__c.split(':')[0]);
                    }
                    else{
                        CorrectOffName = newReason.Associated_Offering_to_Review__c;
                    }
                    TPA_Assigned_TP_Processor__c obj;
                    if(tempComOwnerMap.containsKey(revID.toLowerCase() + '~' + CorrectOffName)){
                        obj = tempComOwnerMap.get(revID.toLowerCase() + '~' + CorrectOffName);
                    }
                    else if(tempComOwnerMap.containsKey(revID.toLowerCase())){
                        obj = tempComOwnerMap.get(revID.toLowerCase());
                    }
                    if(obj != null){
                        temoraryDetails += revID + ' - Temp. CO - ' + obj.Temporary_Commercial_Owner_Email__c + ' From ' + DateTime.newInstance(obj.Out_of_Office_Leave_Start_Date__c.year(),obj.Out_of_Office_Leave_Start_Date__c.month(),obj.Out_of_Office_Leave_Start_Date__c.day()).format('MM/dd/YY') + ' To ' + DateTime.newInstance(obj.Out_of_Office_Leave_End_Date__c.year(),obj.Out_of_Office_Leave_End_Date__c.month(),obj.Out_of_Office_Leave_End_Date__c.day()).format('MM/dd/YY') + ';'; 
                    }
                 }
                 newReason.Temporary_Reviewer_s_Email__c = temoraryDetails;
             }
            
            
            String Key = getComRevKey(newReason,countryOfOffering,offeringCategory,addTermName,addTermLegalName);

            if(!commercialReasonMap.containsKey(Key)) {
                commercialReasonMap.put(Key, newReason);
            }
                
            // if(!reasonsSet.contains(Key)){
            //     reasonsSet.add(Key);
            //     reasonsList.add(newReason);
            // }
        }
    }

    public static void insertCommercialReasons() {
        Map<String,TPA_Commercial_Review__c> comReasonToDelete = new Map<String,TPA_Commercial_Review__c>();
        // Maps of <Reviewer Email, List<Related Commercial Review>> for Offering Removal Scenario
        Map<String, List<TPA_Commercial_Review__c>> currentSessionComReasonMap = new Map<String, List<TPA_Commercial_Review__c>>();
        Map<String, List<TPA_Commercial_Review__c>> pendingReviewComRevToDelete= new Map<String, List<TPA_Commercial_Review__c>>();
        
        Boolean addPending = false;
        Boolean isTPAUpdate = false;
        Boolean isAllApproved = true;
        String offCategory = '',addTermName='',addTermLegalName='';
        for(TPA_Commercial_Review__c comRev : tpaRequest.TPA_Commercial_Reviews__r) {
            offCategory = '';
            addTermName = '';
            addTermLegalName = '';
            if(comRev.Associated_Offering_Category__c != null){
                offCategory = comRev.Associated_Offering_Category__c;
            }
            if(comRev.TPA_Additional_Term__c != null){
                addTermName = comRev.TPA_Additional_Term__r.Term_Name__c;
                addTermLegalName = comRev.TPA_Additional_Term__r.TPA_Legal_Entity_1__r.Name;
            }
            String Key = getComRevKey(comRev,comRev.BU__c,offCategory,addTermName,addTermLegalName);
            if((comRev.Manual_Review_Reason__c == 'Renewal has "Additional Term(s) Added" and/or "Exhibit Page Added" in prior TLLA'
            || comRev.Manual_Review_Reason__c == 'IQVIA Legal Approval Required: New TPA - Ad-hoc Additional Term(s) / Exhibit Page(s) Requested'
            || comRev.Manual_Review_Reason__c == 'IQVIA Legal Approval Required: Prior TLLA had an Additional Term and/or Exhibit added and to be Renewed') && comRev.Status__c != null && (comRev.Status__c.contains('Approved') || comRev.Status__c == 'Complete')){
                String tempKey = Key.replace(comRev.Manual_Review_Reason__c,UTL_TPA.getNewReviewReason(comRev.Manual_Review_Reason__c));
                if(commercialReasonMap.containsKey(tempKey)){
                    if(comRev.Receiver_s_Email__c != null && !currentSessionComReasonMap.containsKey(comRev.Receiver_s_Email__c)){
                        currentSessionComReasonMap.put(comRev.Receiver_s_Email__c, new List<TPA_Commercial_Review__c>{comRev});
                    }else if(comRev.Receiver_s_Email__c != null){
                        currentSessionComReasonMap.get(comRev.Receiver_s_Email__c).add(comRev);
                    }
                    commercialReasonMap.remove(tempKey);
                }
            }
            else if((commercialReasonMap.containsKey(Key) || futureApprovedAddHocTermsKeys.contains(Key)) && comRev.Manual_Review_Reason__c != 'Other Offering Selected') {
                if(comRev.Receiver_s_Email__c != null && !currentSessionComReasonMap.containsKey(comRev.Receiver_s_Email__c)){
                    currentSessionComReasonMap.put(comRev.Receiver_s_Email__c, new List<TPA_Commercial_Review__c>{comRev});
                }else if(comRev.Receiver_s_Email__c != null){
                    currentSessionComReasonMap.get(comRev.Receiver_s_Email__c).add(comRev);
                }
                commercialReasonMap.remove(Key);
                if(futureApprovedAddHocTermsKeys.contains(Key) && !manualReviewReasonList.contains(comRev.Manual_Review_Reason__c)){
                    manualReviewReasonList.add(comRev.Manual_Review_Reason__c);
                }
                if(comRev.Status__c == null || (!comRev.Status__c.contains('Approved') && comRev.Status__c != 'Complete')){
                    addPending = true;
                }
            }
            else {
                comReasonToDelete.put(Key,comRev);
                if(comRev.Action__c != null && (comRev.Action__c == 'Questions / Comments' || comRev.Action__c.contains('Potential Denial'))){
                    if(comRev.Receiver_s_Email__c != null && !pendingReviewComRevToDelete.containsKey(comRev.Receiver_s_Email__c)){
                        pendingReviewComRevToDelete.put(comRev.Receiver_s_Email__c, new List<TPA_Commercial_Review__c>{comRev});
                    }else if(comRev.Receiver_s_Email__c != null){
                        pendingReviewComRevToDelete.get(comRev.Receiver_s_Email__c).add(comrev);
                    }
                }
            }
            if(comRev.Status__c == null ||(!comReasonToDelete.containsKey(Key) && !comRev.Status__c.contains('Approved') && comRev.Status__c != 'Complete')){
                isAllApproved = false;
            }
        }
        for(TPA_Commercial_Review__c newReason : commercialReasonMap.values()){
            if(newReason.Receiver_s_Email__c != null && !currentSessionComReasonMap.containsKey(newReason.Receiver_s_Email__c)){
                currentSessionComReasonMap.put(newReason.Receiver_s_Email__c, new List<TPA_Commercial_Review__c>{newReason});
            }else if(newReason.Receiver_s_Email__c != null){
                currentSessionComReasonMap.get(newReason.Receiver_s_Email__c).add(newReason);
            }
        }
        if(comReasonToDelete != null && comReasonToDelete.size() > 0) {
            if(pendingReviewComRevToDelete.size() > 0){
                for(String comRevEmail : pendingReviewComRevToDelete.keySet()){
                    sendForYourRecordsOnDeletionMail(pendingReviewComRevToDelete.get(comRevEmail), currentSessionComReasonMap.get(comRevEmail), comRevEmail);
                }
            }
            delete comReasonToDelete.values();
        }
       if(commercialReasonMap != null && commercialReasonMap.size() > 0) {
            if(!tpaRequest.is_Bulk_TPA_Request__c && !tpaRequest.Is_Potential_Vendor_Case__c){
                upsert commercialReasonMap.values();
            }
            addPending = true;
        } else {
            if(isAllApproved && tpaRequest.Pending_Acknowledgements__c != null && tpaRequest.Pending_Acknowledgements__c.indexOf('Pending Commercial Review Acknowledgements') != -1) {
                string strPickListValue = tpaRequest.Pending_Acknowledgements__c;
                if(strPickListValue != null) {
                    List<string> lstPicklistValues = strPickListValue.split(';');
                    string strValueToRemove ='Pending Commercial Review Acknowledgements';
                    if(lstPicklistValues.contains(strValueToRemove)){
                        isTPAUpdate = true;
                        lstPicklistValues.remove(lstPicklistValues.indexOf(strValueToRemove));
                    }
                    tpaRequest.Pending_Acknowledgements__c = String.join(lstPicklistValues,';');
                }
            }
        }

        if(addPending) {
            if(tpaRequest.Pending_Acknowledgements__c == null || tpaRequest.Pending_Acknowledgements__c == '') {
                isTPAUpdate = true;
                tpaRequest.Pending_Acknowledgements__c =  'Pending Commercial Review Acknowledgements' ;
            }
            else if(tpaRequest.Pending_Acknowledgements__c.indexOf('Pending Commercial Review Acknowledgements') == -1) {
                isTPAUpdate = true;
                tpaRequest.Pending_Acknowledgements__c = tpaRequest.Pending_Acknowledgements__c + ';Pending Commercial Review Acknowledgements' ;
            }
        }
        if(isTPAUpdate) {
            update tpaRequest;
        }
    }

   

    public static void sendApprovalMail(String emailaddresses, List<String> tpProcessorEmailId) {
        String clientOnComplianceHoldReason;
        String vendorOnComplianceHoldReason;
        Boolean isClientOnComplianceHold = false;
        Boolean isVendorOnComplianceHold = false;
        Boolean isSignumVendor = false;
        Map<String, Account_Compliance__c> accCompRecords = UTL_TPA.getTPAClientVendorComplianceDetails(tpaRequest.Client_Address__c, tpaRequest.Service_Provider_Address__c); 
        Map<String, TPA_Additional_Term__c> mapTpaAdditionalTerms = UTL_TPA.getTpaAdditionalTerms(tpaRequest);
        Map<String, TPA_Text_Editor__c> mapTpaTextAdditionalTerms = UTL_TPA.getTpaTextAdditionalTerms(tpaRequest);

        if(accCompRecords != null){
            Account_Compliance__c accClientComp = accCompRecords.get('CC-'+tpaRequest.Client_Address__c);
            if(accClientComp != null && accClientComp.Client_TPA_Compliance_Hold__c){
                isClientOnComplianceHold = true;
                clientOnComplianceHoldReason = accClientComp.Client_TPA_Compliance_Hold_Reason__c;
            }
            Account_Compliance__c accVendorComp = accCompRecords.get('VC-'+tpaRequest.Service_Provider_Address__c);
            if(accVendorComp != null && accVendorComp.Vendor_TPA_Compliance_Hold__c){
                isVendorOnComplianceHold = true;
                vendorOnComplianceHoldReason = accVendorComp.Vendor_TPA_Compliance_Hold_Reason__c;
            }
        }
        system.debug('in sendApprovalMail: tpaRequest.Is_Manually_Approved__c: '+tpaRequest.Is_Manually_Approved__c );
        if( tpaRequest.Is_Manually_Approved__c ) {
            List<String> lstDateSplitted = new List<String>();
            String startDate = String.valueOf(tpaRequest.Data_Access_Start_Date__c);
            if(startDate != null) {
                lstDateSplitted = startDate.split('-');
                startDate = lstDateSplitted[1]+'/'+lstDateSplitted[2]+'/'+lstDateSplitted[0];
            }
            String endDate = String.valueOf(tpaRequest.Data_Access_End_Date__c);
            if(endDate != null) {
                lstDateSplitted = new List<String>();
                lstDateSplitted = endDate.split('-');
                endDate = lstDateSplitted[1]+'/'+lstDateSplitted[2]+'/'+lstDateSplitted[0];
            }
            String dataPeriodStartDate = String.valueOf(tpaRequest.Data_Period_Start_Date__c);
            if(dataPeriodStartDate != null) {
                lstDateSplitted = new List<String>();
                lstDateSplitted = dataPeriodStartDate.split('-');
                dataPeriodStartDate = lstDateSplitted[1]+'/'+lstDateSplitted[2]+'/'+lstDateSplitted[0];
            }
            String dataPeriodEndDate = String.valueOf(tpaRequest.Data_Period_End_Date__c);
            if(dataPeriodEndDate != null) {
                lstDateSplitted = new List<String>();
                lstDateSplitted = dataPeriodEndDate.split('-');
                dataPeriodEndDate = lstDateSplitted[1]+'/'+lstDateSplitted[2]+'/'+lstDateSplitted[0];
            }
            Integer i=1;
            String subjText;
            String bodyText = '';
            String fontStyle = '<div style="font-size:13px !important;font-family:arial !important;">';
            // if(dataAssetList == null) {
            //     dataAssetList = '';
            // }
            // dataAssetList = dataAssetList.replace('\n', ':');
            // dataAssetList = dataAssetList.replace('<', '&lt;');
            // dataAssetList = dataAssetList.replace('>', '&gt;');
            
            subjText = 'Summary View: ' + tpaRequest.Client_Address__r.Name + '_A TPA Request ('+ tpaRequest.Name+ ') Requires a Manual Review';
            
            bodytext += '<table style="border-collapse: collapse;border:2px solid;"><tr><th style="border:2px solid;font-size:13px;font-family:arial;">Manual Trigger(s)</th><th style="border:2px solid;font-size:13px;font-family:arial;">Trigger Description</th><th style="border:2px solid;font-size:13px;font-family:arial;">Consideration(s)</th></tr>';
              
            TPA_Master_Extension_Information__c extRecord = UTL_TPA.getExtensionRecOfVendorAddress(tpaRequest.Service_Provider_Address__c);

            List<TPA_Text_Editor__c> manualReasonTextEditorList = [select id, Page_Name__c, Page_Title__c, Page_Url__c,Content__c from TPA_Text_Editor__c where Page_Type__c = 'Manual Review Reasons' and  Page_Name__c IN :manualReviewReasonList];

            for(TPA_Text_Editor__c manualReason : manualReasonTextEditorList) {
                if(manualReason.Content__c != null && approvalNotificationMap.get(manualReason.Page_Name__c) != null) {
                    manualReason.Content__c = manualReason.Content__c.replace('DYNAMIC-TAG', approvalNotificationMap.get(manualReason.Page_Name__c));
                }
                
                List<String> lstReason = (manualReason.Content__c.unescapeHtml4().stripHtmlTags()).split('SPLIT-HERE');
                if(lstReason != null && lstReason.size() > 2) {
                    if(lstReason[0] == 'Vendor Requires Review ') {
                        system.debug('IN Vendor Requires Review');
                        List<String> backgroundSubReasons = lstReason[1].stripHtmlTags().split('~');
                        List<String> actionSubReasons = lstReason[2].split('~');
                        System.debug('backgroundSubReasons ' + backgroundSubReasons);
                        System.debug('actionSubReasons ' + actionSubReasons);
                        Integer listSize = 5;
                        if(backgroundSubReasons != null && backgroundSubReasons.size() > listSize && actionSubReasons != null && actionSubReasons.size() > listSize) {
                            string fisrtCellValue = lstReason[0];
                            if( ( extRecord != null && extRecord.Commercial_Reason__c) //need to check this condition
                            || (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null && tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Vendor_Tier__c == 'Y') 
                            || (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c == null && tpaRequest.Service_Provider_Address__r.Vendor_Tier__c == 'Y' )) {
                                if((tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null && tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Vendor_Tier__c == 'Y') 
                                || (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c == null && tpaRequest.Service_Provider_Address__r.Vendor_Tier__c == 'Y' )) {
                                    fisrtCellValue += (nonApprovedOfferingList.size() > 0) ? ' - Specific Data Use/Offering Combinations need commercial review: ' + string.join(nonApprovedOfferingList,', ') : '';
                                    System.debug('Inside the first condition 1');
                                    bodytext += '<tr><td style="font-size:13px;font-family:arial;border-left: 2px solid;">' + fisrtCellValue + '</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+backgroundSubReasons[0]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+actionSubReasons[0]+'</td></tr>';
                                    fisrtCellValue = '&nbsp;';
                                }
                            }
                            if((tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null && tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.New_Vendor_Checklist__c) 
                            || (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c == null && tpaRequest.Service_Provider_Address__r.New_Vendor_Checklist__c )) {
                                System.debug('Inside the first condition 2');

                                bodytext += '<tr><td style="font-size:13px;font-family:arial;border-left: 2px solid;">' + fisrtCellValue + '</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+backgroundSubReasons[1]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+actionSubReasons[1]+'</td></tr>';
                                fisrtCellValue = '&nbsp;';
                            }
                            if((tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null && tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Is_Payment_Risk__c) 
                            || (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c == null && tpaRequest.Service_Provider_Address__r.Is_Payment_Risk__c )) {
                                System.debug('Inside the first condition 3');

                                bodytext += '<tr><td style="font-size:13px;font-family:arial;border-left: 2px solid;">' + fisrtCellValue + '</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+backgroundSubReasons[2]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+actionSubReasons[2]+'</td></tr>';
                                fisrtCellValue = '&nbsp;';
                            }
                            if((tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null && tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Pharma_Company_Checklist__c) 
                            || (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c == null && tpaRequest.Service_Provider_Address__r.Pharma_Company_Checklist__c )) {
                                System.debug('Inside the first condition 4');

                                bodytext += '<tr><td style="font-size:13px;font-family:arial;border-left: 2px solid;">' + fisrtCellValue + '</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+backgroundSubReasons[3]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+actionSubReasons[3]+'</td></tr>';
                                fisrtCellValue = '&nbsp;';
                            }
                            if((tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null && tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Legal_Firm_Checklist__c) 
                            || (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c == null && tpaRequest.Service_Provider_Address__r.Legal_Firm_Checklist__c )) {
                                System.debug('Inside the first condition 5');

                                bodytext += '<tr><td style="font-size:13px;font-family:arial;border-left: 2px solid;">' + fisrtCellValue + '</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+backgroundSubReasons[4]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+actionSubReasons[4]+'</td></tr>';
                                fisrtCellValue = '&nbsp;';
                            }
                            if((tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null && tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__r.Academia_Checklist__c) 
                            || (tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c == null && tpaRequest.Service_Provider_Address__r.Academia_Checklist__c )) {
                                System.debug('Inside the first condition 6');

                                bodytext += '<tr><td style="font-size:13px;font-family:arial;border-left: 2px solid;">' + fisrtCellValue + '</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+backgroundSubReasons[5]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+actionSubReasons[5]+'</td></tr>';
                                fisrtCellValue = '&nbsp;';
                            }
                        }
                    }
                    else if(lstReason[0] == 'Vendor Has Limited Master TPA Certificate'){
                        System.debug('Inside Sf condition');
                        
                        bodytext += '<tr><td style="border:2px solid;font-size:13px;font-family:arial;"><span style="color:red;">'+lstReason[0]+'</span></td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[1]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[2]+'</td></tr>';
                    }                      
                    else if(manualReason.Page_Name__c == 'Asset_Name__c-Other') {
                        System.debug('Inside the first condition 6');

                        system.debug('lstReason[0]' + lstReason[0]);
                        List<String> OtherString = lstReason[0].split(':');
                        system.debug('OtherString:' + OtherString);
                        Blob decodedOtherOff = EncodingUtil.base64Decode(OtherString[1]);
                        bodytext += '<tr><td style="border:2px solid;font-size:13px;font-family:arial;">'+ OtherString[0] + ': '+ decodedOtherOff.toString()+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[1]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[2]+'</td></tr>';
                    } 
                    else if(lstReason[0] == 'Client TPA Compliance Hold:  Requires TPA Compliance Review' || lstReason[0] == 'Vendor TPA Compliance Hold: Requires TPA Compliance Review' || lstReason[0].startsWith('IQVIA Legal Review Required - Specific Use/Offering Combination(s) requires Legal Final Review for Approval')) {
                        System.debug('Inside the first condition 6');

                        bodytext += '<tr><td style="border:2px solid;font-size:13px;font-family:arial;"><span style="color:red; font-size:13px; font-family:arial;">'+lstReason[0]+'</span></td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[1]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[2]+'</td></tr>';
                    }else if(lstReason[0].startsWith('Vendor Signum: Requires to be Invoiced')){
                        isSignumVendor = true;
                        bodytext += '<tr><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[0]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[1]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[2]+'</td></tr>';
                    }
                    else if(lstReason[0].startsWith('Account Requires Secondary Review')) {
                        System.debug('Inside the first condition 6');

                    bodytext += '<tr><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[0]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;"><u>Account Requires Secondary Review</u> :'+lstReason[1]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[2]+'</td></tr>';
                    }
                    else {
                        System.debug('Inside the first condition 6');

                        bodytext += '<tr><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[0]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[1]+'</td><td style="border:2px solid;font-size:13px;font-family:arial;">'+lstReason[2]+'</td></tr>';
                    }
                }                  
            }
  
            if(reasonForAmaApprovalMap.keyset() != null && reasonForAmaApprovalMap.keyset().size() > 0) {
                bodytext += '<tr bgcolor="#b3b3b3"><td colspan="4" style="border:2px solid;padding: 5px;text-align: center;text-decoration: underline;font-size: 13px;font-family:arial;"><b>AMA Manual Review Reasons - TPA Processor USE ONLY (Do Not Use)</b></td></tr>';
            }
            for( String reasonOfAmaManualReview : reasonForAmaApprovalMap.keyset()) {
                List<String> lstAmaReason = reasonForAmaApprovalMap.get( reasonOfAmaManualReview ).split(';');
                if(lstAmaReason != null && lstAmaReason.size() > 2) {
                    bodytext += '<tr bgcolor="#b3b3b3"><td style="border:2px solid;padding:3px;font-size: 13px;font-family:arial;">'+lstAmaReason[0]+'</td><td style="border:2px solid;padding:3px;font-size: 13px;font-family:arial;">'+lstAmaReason[1]+'</td><td colspan="2" style="border:2px solid;padding:3px;font-size: 13px;font-family:arial;">'+lstAmaReason[2]+'</td></tr>';
                }
            }
            
            bodytext += '</table>';
            if(tpaRequest.isClientOnComplianceHold__c) {
                bodytext += '<br><div style = "font-size: 13px;font-family:arial;"><B>Client TPA Compliance Hold: </B>' + clientOnComplianceHoldReason + '</div>';
            }
            if(tpaRequest.isVendorOnComplianceHold__c) {
                bodytext += '<br><div style = "font-size: 13px;font-family:arial;"><B>Vendor TPA Compliance Hold: </B>' + vendorOnComplianceHoldReason + '</div>';
            }
            if(tpaRequest.Parent_Request__c != null && tpaRequest.Parent_Request__r.Is_Renewed__c && tpaRequest.Parent_Request__r.Renewed_As__c == tpaRequest.Id && tpaRequest.Is_Partially_Renewed__c != true) {
                bodytext += '<br><br><br><br><p style="font-size:13px;font-family:arial;"><B>' + tpaRequest.Name + ' Request Details: This is a renewal TPA. Parent TPA is ' + tpaRequest.Parent_Request__r.Name + '. </B>';
            }
            else {
                bodytext += '<br><br><br><br><p style="font-size:13px;font-family:arial;"><B>' + tpaRequest.Name + ' Request Details: </B>';
            }
            bodytext = bodytext.replace('AMACCLDATE', SRV_TPA_AMAAgreementDetail.recentAMAContractDate()?.format('MM-dd-yyyy')??'');
            bodytext += '<br>';
            bodytext += '<br><B>Client Company: </B>'+tpaRequest.Client_Address__r.Name;
            bodytext += '<br><B>Status: </B>' + tpaRequest.Request_Status__c;
            bodytext += '<br><B>Third Party Company: </B>'+tpaRequest.Service_Provider_Address__r.Name;
            if(tpaRequest.Vendor_Website__c != null){
            bodytext += '<br><B>Vendor Website & Network Id: </B>'+tpaRequest.Vendor_Website__c;
            }
              
            bodytext += '<br><B>Client Project Name: </B>'+((tpaRequest.Client_Project_Name__c == null)? '':tpaRequest.Client_Project_Name__c);
            bodytext += '<br><B>Agreement Start and End Dates: </B>'+startDate + ', ' + endDate;
            if(dataPeriodStartDate != null && dataPeriodEndDate != null){
                bodytext += '<br><B>Data Period Start and End Dates: </B>'+dataPeriodStartDate + ', ' + dataPeriodEndDate;
            }
              
            if(tpaRequest.AMA_USPrescriberData__c != null && tpaRequest.AMA_USPrescriberData__c.equalsIgnoreCase(UTL_TPA.YES)) {
                bodytext += '<br><B>AMA license required: </B>'+ 'Yes';
            }
            else if(tpaRequest.AMA_USPrescriberData__c != null && tpaRequest.AMA_USPrescriberData__c.equalsIgnoreCase(UTL_TPA.NO)) {
                bodytext += '<br><B>AMA license required: </B>'+ 'No';
            }
            if(tpaRequest.Manual_Trigger_Reasons__c != null && (tpaRequest.Manual_Trigger_Reasons__c.contains('Vendor Requires Secondary Review') || tpaRequest.Manual_Trigger_Reasons__c.contains('Offering Requires Secondary Commercial Review') || tpaRequest.Manual_Trigger_Reasons__c.contains('Offering(s) Requires Secondary Review') || tpaRequest.Manual_Trigger_Reasons__c.contains('Offering(s) Requires Secondary Review')) ) {
                bodytext += '<br><br><B>Note: This TPA Will Also be Sent for Secondary Management Review as a Final Review.</B> PLEASE DO NOT add a Comment \'Approved if Management approves\' or the like - Please be assured the TPA will not release for signature if all reviews are not approved.';
            }

            List<TPA_Text_Editor__C> offeringSpecificTextAddTerms = new List<TPA_Text_Editor__C>();
            List<TPA_Additional_Term__c> offeringSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            List<TPA_Additional_Term__c> useSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            List<TPA_Additional_Term__c> useOfferingSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            Set<TPA_Offering_Notification_Mapping__c> DynamicNotifications = new Set<TPA_Offering_Notification_Mapping__c>(); 

            TPA_Request__C tpaRequestForPurpose = [Select Id,Name,Service_Provider_Address__c,Vendor_Billing_Mailing_Country__c,is_LAAD_Response_Acknowledged__c,Is_VSN_Acknowlege_By_Client__c, (select id,IMS_Legal_Entity__c,Purpose__c,Purpose__r.Id from Purposes__r), (SELECT Id, TPA_Offering_Notification_Record__c, Type__c FROM TPA_Use_Offering_Atypical_Combinations__r WHERE Type__c = 'Offering Notification Record') From TPA_Request__c where Id =: tpaRequest.Id ];  //will review this

            Map<String, TPA_Offering_Notification_Mapping__c> mapTpaDynamicNotifications = UTL_TPA.getmapTpaDynamicNotifications(tpaRequestForPurpose); 

            if(mapTpaTextAdditionalTerms != null || mapTpaAdditionalTerms != null || mapTpaDynamicNotifications != null){
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Additional Term(s) under TLLA Schedule A: </B></div>';
                if(mapTpaTextAdditionalTerms != null){
                    system.debug('mapTpaTextAdditionalTerms'+mapTpaTextAdditionalTerms.values());
                    /*if(mapTpaTextAdditionalTerms.containsKey('is_Veeva_Use_CRM__c:TPA_Request__c')){
                        bodytext += '<br><br>' + fontStyle + mapTpaTextAdditionalTerms.get('is_Veeva_Use_CRM__c:TPA_Request__c').content__c + '</div>'; 
                    }*/
                    if(mapTpaTextAdditionalTerms.containsKey('AI_ML_Restrictions:TPA_Request__c')){
                        bodytext += '<br><br>' + fontStyle + mapTpaTextAdditionalTerms.get('AI_ML_Restrictions:TPA_Request__c').content__c + '</div>'; 
                    }
                    for( String addKey : mapTpaTextAdditionalTerms.keyset()) {
                        if(addKey.split(':')[1] == 'TPA_Request__c'){
                            if(!(addKey.split(':')[0] == 'is_Veeva_Use_CRM__c' ||  addKey.split(':')[0] == 'AI_ML_Restrictions')){
                                TPA_Text_Editor__C listEditor = mapTpaTextAdditionalTerms.get(addKey);
                                bodytext += '<br><br>'+ fontStyle + mapTpaTextAdditionalTerms.get(addKey).Content__c + '</div>';
                            }
                        }
                        if(addKey.split(':')[1] == 'IMS_Legal_Entity__c'){
                            TPA_Text_Editor__C listEditor = mapTpaTextAdditionalTerms.get(addKey);
                            if(TpaTextTerms.contains(listEditor.Page_Name__c)){
                                offeringSpecificTextAddTerms.add(mapTpaTextAdditionalTerms.get(addKey));
                            }
                        }  
                    }
                }
                if(mapTpaAdditionalTerms != null){
                    for( String addKey : mapTpaAdditionalTerms.keyset()) {
                        if(addKey.split(':')[1] == 'General Ad-Hoc Term'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            bodytext += '<br><br>' + fontStyle + '<strong><u>' + addhocTerm.Term_Name__c + ':</u></strong>';
                            bodytext += '<br><br>'  + addhocTerm.Addtional_Term__c ;
                            if(addhocTerm.Exhibit_Attached__c && addhocTerm.Attachments != null && addhocTerm.Attachments.size() > 0){
                                String attchId = addhocTerm.Attachments[0].Id;
                                bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                            }
                            bodytext += '</div>';
                        }
                        if(addKey.split(':')[1] == 'Data Asset Specific Ad-Hoc Term'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            offeringSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                        if(addKey.split(':')[1] == 'Use Specific Ad-Hoc Terms'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            useSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                        if(addKey.split(':')[1] == 'Use/Offering Specific Ad-Hoc Terms'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            useOfferingSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                    }
                }
                if(mapTpaDynamicNotifications != null){
                    for( String addKey : mapTpaDynamicNotifications.keyset()) {
                        TPA_Offering_Notification_Mapping__c offNotify =  mapTpaDynamicNotifications.get(addKey);
                        set<String> offeringDupCheck = new set<String>();
                        for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.Associated_Offering_to_Review__c == null){
                                DynamicNotifications.add(mapTpaDynamicNotifications.get(addKey));
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null && !offeringDupCheck.contains(comRev.Associated_Offering_to_Review__c) && (comRev.Associated_Offering_to_Review__c.indexOf(offNotify.Primary_Data_Asset_Name__c) != -1 || comRev.Associated_Offering_to_Review__c.indexOf(offNotify.Secondary_Data_Asset_Name__c) != -1)){
                                offeringDupCheck.add(comRev.Associated_Offering_to_Review__c);
                                DynamicNotifications.add(mapTpaDynamicNotifications.get(addKey));
                            }
                        }
                    }
                }
            }
            if((offeringSpecificTextAddTerms != null && offeringSpecificTextAddTerms.size() > 0) || (offeringSpecificAddhocTerms != null && offeringSpecificAddhocTerms.size() > 0) || (useSpecificAddhocTerms != null && useSpecificAddhocTerms.size() > 0) || (useOfferingSpecificAddhocTerms != null && useOfferingSpecificAddhocTerms.size() > 0) || (DynamicNotifications != null && DynamicNotifications.size() > 0)){
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Use Specific Additional Term(s) under TLLA Schedule A: </B></div>';
                if(useSpecificAddhocTerms != null && useSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: useSpecificAddhocTerms){
                        bodytext += '<br><br>' + fontStyle + '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                        bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                        if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                            String attchId = addhoc.Attachments[0].Id;
                            bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                        }
                        bodytext += '</div>';
                    }
                }
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Use/Offering Specific Additional Term(s) under TLLA Schedule A: </B></div>';
                if(useOfferingSpecificAddhocTerms != null && useOfferingSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: useOfferingSpecificAddhocTerms){
                        bodytext += '<br><br>' + fontStyle + '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                        bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                        if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                            String attchId = addhoc.Attachments[0].Id;
                            bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                        }
                        bodytext += '</div>';
                    }
                }
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Offering Specific Additional Term(s) under TLLA Schedule A: </B></div>';
                if(offeringSpecificTextAddTerms != null && offeringSpecificTextAddTerms.size() > 0){ 
                    for(TPA_Text_Editor__C txt: offeringSpecificTextAddTerms){
                        bodytext += '<br><br>'+ fontStyle + txt.Content__c + '</div>';
                    }
                }
                if(offeringSpecificAddhocTerms != null && offeringSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: offeringSpecificAddhocTerms){
                        bodytext += '<br><br>' + fontStyle + '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                        bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                        if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                            String attchId = addhoc.Attachments[0].Id;
                            bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                        }
                        bodytext += '</div>';
                      /*  for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.TPA_Additional_Term__c != null && comRev.TPA_Additional_Term__c == addhoc.Id){
                                bodytext += '<br><br><b>'+addhoc.Name +'</b>';
                                bodytext += '<br>'+addhoc.Addtional_Term__c;
                                break;
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null && comRev.Associated_Offering_to_Review__c.indexOf(':') != -1 && ( (addhoc.Primary_Offering_Name__c != null && addhoc.Primary_Offering_Name__c == comRev.Associated_Offering_to_Review__c.split(':')[0] ) || ( addhoc.Secondary_Offering_Name__c != null && addhoc.Secondary_Offering_Name__c == comRev.Associated_Offering_to_Review__c.split(':')[0] ) )){
                                bodytext += '<br><br><b>'+addhoc.Name +'</b>';
                                bodytext += '<br>'+addhoc.Addtional_Term__c;
                                break;
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null && ( (addhoc.Primary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c == addhoc.Primary_Offering_Name__c) || (addhoc.Secondary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c == addhoc.Secondary_Offering_Name__c ))){
                                bodytext += '<br><br><b>'+addhoc.Name +'</b>';
                                bodytext += '<br>'+addhoc.Addtional_Term__c;
                                break;
                            }
                        } */
                        
                    }
                }
                String DynNotiDuplicatecheck = '';
                if(DynamicNotifications != null && DynamicNotifications.size() > 0){
                    for(TPA_Offering_Notification_Mapping__c offNotify: DynamicNotifications){
                        String offNotifyContent = offNotify.Offering_Notifications__r.Content__c;
                        if(!DynNotiDuplicatecheck.contains(offNotifyContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', ''))){
                            DynNotiDuplicatecheck += offNotifyContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', '') + '|-|';
                            system.debug('in dynamic notification : ' + offNotifyContent);
                            bodytext += '<br><br>' + fontStyle + offNotifyContent + '</div>';
                        }
                    }
                }
            }
              
              
            bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Requested Uses and ' + Label.TPA_IQVIA_Keyword + ' Offering(s) by Country: </B>'+ '<a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_OfferingsWithCategory&reqId='+ tpaRequest.Id+' >Click here</a></div>' +'</p>'; 
            /*BUPurposeGeoLevelDataAssetMap = new Map<String, Map<String, Map<String, String>>>();
            Set<Id> purposeIds = new Set<Id>();
            //for(TPA_Purpose__c purpose : getPurposeAndDescriptionList(tpaRequest.Id)) {
            for(TPA_Purpose__c purpose : getPurposesList(tpaRequest.Id)) {
                purposeIds.add(purpose.Id);
            }
            List<TPA_Data_Asset__c> tpaDataAssets = tpaDataAssetListCopy(purposeIds);        
            BUPurposeGeoLevelDataAssetMap = UTL_TPA.setUseOfferingMap(tpaDataAssets);
        
            for( String dataAssetContry : BUPurposeGeoLevelDataAssetMap.keyset()) {                
                bodytext += '<br><table style="border-collapse: collapse;font-size:13px;font-family:arial;border:2px solid #0CB6F3;"><tr><th colSpan="8" style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">' + dataAssetContry + ' Offerings Selected in Request</th></tr>';
                bodytext += '<tr><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Use(s) Selected in Request</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Sub-national</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">National</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Anonymized Patient-Level Data / Transaction-Level Offering Section</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Consumer Health</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Real World Evidence</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Global Services</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Reference Data</th></tr>';
                Map<String, Map<String, String>> purpose_GL_DataAssetMap = new Map<String, Map<String, String>>();
                purpose_GL_DataAssetMap = BUPurposeGeoLevelDataAssetMap.get(dataAssetContry);
                for( String dataAssetPurpose : purpose_GL_DataAssetMap.keyset() )                 {
                    bodytext += '<tr><td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + dataAssetPurpose + '</td>';
                    Map<String, String> gl_DataAssetMap = new Map<String, String>();
                    gl_DataAssetMap = purpose_GL_DataAssetMap.get(dataAssetPurpose);
                    bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + ( gl_DataAssetMap.get('Sub-National') != null ? gl_DataAssetMap.get('Sub-National') : 'n/a' ) +'</th>';
                    bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + ( gl_DataAssetMap.get('National') != null ? gl_DataAssetMap.get('National') : 'n/a' ) +'</th>';
                    bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + ( gl_DataAssetMap.get('Anonymized Patient-Level Data / Transaction-Level') != null ? gl_DataAssetMap.get('Anonymized Patient-Level Data / Transaction-Level') : 'n/a' ) +'</th>';
                    bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + ( gl_DataAssetMap.get('Consumer Health') != null ? gl_DataAssetMap.get('Consumer Health') : 'n/a' ) +'</th>';
                    bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + ( gl_DataAssetMap.get('Real World Evidence') != null ? gl_DataAssetMap.get('Real World Evidence') : 'n/a' ) +'</th>';
                    bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + ( gl_DataAssetMap.get('Global Services') != null ? gl_DataAssetMap.get('Global Services') : 'n/a' ) +'</th>';
                    bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + ( gl_DataAssetMap.get('Reference Data') != null ? gl_DataAssetMap.get('Reference Data') : 'n/a' ) +'</th></tr>';
                }
                bodytext += '</table><br>';
            }*/
  
            if( tpaRequest != null ) {
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>FOR TP-PROCESSOR ONLY: </B> ' + TPA_Settings__c.getOrgDefaults().Base_Url__c + '/' + tpaRequest.Id + '</div>';
            }
            bodytext += '<br><br></p></div>';
              
            List<String> ccAddressesList = new List<String>();
            if(emailaddresses != NULL && emailaddresses.trim() != '') {
                ccAddressesList = emailaddresses.split(',', 0);
            }

            
            if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
                ccAddressesList.add(UTL_TPA.sharedEmailAddress);
            }
              
            List<String> toAddresses =  UTL_TPA.TpaEmailAddress.split(';');
            if(tpProcessorEmailId != null && !tpProcessorEmailId.isEmpty()){
                toAddresses = new List<String>();
                toAddresses.addAll(tpProcessorEmailId);
            }
                
            try {
                if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                    System.debug('Email send: ');
                    /*addTPProcessorInitials = true;
                    if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        assignedTPProcessorName = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/
                    sendEmailThroughWorkflow(toAddresses, ccAddressesList, 'SendEmail', null, tpaRequest.Id, null, subjText, FALSE, bodyText, TRUE, TRUE, tpaRequest);
                    //addTPProcessorInitials = false;
                }
            }
            catch(Exception e) {
                System.debug('Email Failed: ' + e.getMessage());
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_TPARequest:::sendApprovalMail', tpaRequest != null ? tpaRequest.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
        }
        
        System.debug('isRunCommercialAutoLogic: ' + isRunCommercialAutoLogic);
    }

   

    public static TPA_Request__c manualApproval( TPA_Request__c request ) {
         tpaRequest = request ;
         return request;
    }
    
   
    
    public static string fullOfferingName(TPA_Data_Asset__c tpaDataAsset, TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset){
		string FullOfferingName = '';
        if(tpaDataAsset != null){
            if(tpaDataAsset.Asset_Name__c == 'RWE Custom Study Name & Project Delivery Date:'){
                FullOfferingName += 'RWE Custom Study Name: ' + tpaDataAsset.RWE_Study_Name__c + ' Project Delivery Date: ' + tpaDataAsset.RWE_Delivery_Date__c.format();
            }
            else if(tpaDataAsset.Asset_Name__c.equalsIgnoreCase(UTL_TPA.consumerProfilesOfferingName)){
                FullOfferingName += 'Consumer Profiles Custom Study Name: ' + tpaDataAsset.Consumer_Profile_Study_Name__c + ' Project Delivery Date: ' + tpaDataAsset.Consumer_Profile_Delivery_Date__c.format();
            }
            else if(tpaDataAsset.Asset_Name__c == 'Promotional Response (ROI) Custom Study Name & Project Delivery Date:'){
                FullOfferingName += 'Promotional Response (ROI) Custom Study Name: ' + tpaDataAsset.Promotional_ROI_Study_Name__c + ' Project Delivery Date: ' + tpaDataAsset.Promotional_ROI_Delivery_Date__c.format();
            }
            else if(tpaDataAsset.Asset_Name__c == 'APLD Custom Study Name & Project Delivery Date:'){
                FullOfferingName += 'APLD Custom Study Name: ' + tpaDataAsset.APLD_Study_Name__c + ' Project Delivery Date: ' + tpaDataAsset.APLD_Delivery_Date__c.format();
            }
            else if(tpaDataAsset.Asset_Name__c=='STI Data - Custom Report Name'){
                FullOfferingName += 'STI Data - Custom Report Name: ' + tpaDataAsset.STI_Data_Report_Name__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'Longitudinal Patient Diagnosis'){
                FullOfferingName += 'Longitudinal Patient Diagnosis: ' + tpaDataAsset.Longitudanal_Patient_Diagonsis__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'Nostradata Source of Business (LRx)'){
                FullOfferingName += 'Nostradata Source of Business (LRx) Provide Market: ' + tpaDataAsset.Nostradata_Source_of_Business_LRx__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'CH-Retail Profits'){
                FullOfferingName += 'CH-Retail Profits: ' + tpaDataAsset.CH_Retail_Profits__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'CH-Other Outlet Profits'){
                FullOfferingName += 'CH-Other Outlet Profits Provide Market: ' + tpaDataAsset.CH_Other_Outlet_Profits__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'CH-Hospital Profits'){
                FullOfferingName += 'CH-Hospital Profits Provide Market: ' + tpaDataAsset.CH_Hospital_Profits__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'CH Combined Hos and Ret Profit AU'){
                FullOfferingName += 'CH Combined Hos and Ret Profit AU: ' + tpaDataAsset.CH_Combined_Hos_and_Ret_Profit_AU__c;
            }
	        else if(tpaDataAsset.Asset_Name__c== 'PharMetrics® Plus (Health Plan Claims)'){
                FullOfferingName += 'PharMetrics® Plus (Health Plan Claims): ' + tpaDataAsset.Health_Plan_Claims_Data__c;
            }
	        else if(tpaDataAsset.Asset_Name__c== 'LAAD - Longitudinal Access and Adjudication Data'){
                FullOfferingName += 'LAAD - Longitudinal Access and Adjudication Data: ' + tpaDataAsset.LAAD_Longitudinal_Access_and_Adj_data__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'Payer Companion File'){
                FullOfferingName += 'Payer Companion File: ' + tpaDataAsset.Payer_Companion_File__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'Provider Companion File'){
                FullOfferingName += 'Provider Companion File: ' + tpaDataAsset.Provider_Companion_File__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'Patient Reference File'){
                FullOfferingName += 'Patient Reference File: ' + tpaDataAsset.Patient_Reference_File__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'CWH NZ Scan data'){
                FullOfferingName += 'CWH NZ Scan data: ' + tpaDataAsset.CWH_NZ_Scan_data__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'Customized IQVIA Data - Specify name of Customized Data will be shared:'){
                FullOfferingName += 'Customized IQVIA Data - Specify name of Customized Data will be shared: ' + tpaDataAsset.Customized_Data_Text__c;
            }
            else if(tpaDataAsset.Asset_Name__c== 'Other'){
                FullOfferingName += 'Other Offering Selected: ' + tpaDataAsset.Other_Text__c;
            }
            else{
                FullOfferingName += tpaDataAsset.Asset_Name__c;
            }
        }
        else{
            if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'BrandImpact Custom Study Name & Project Delivery Date:'){
                FullOfferingName += 'BrandImpact Custom Study Name: ' +  tpaSecondaryDataAsset.BrandImpact_Study_Name__c + ' BrandImpact Project Delivery Date: ' + tpaSecondaryDataAsset.BrandImpact_Delivery_Date__c.format();
            }
            else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'Channel Dynamics Custom Study Name & Project Delivery Date:'){
                FullOfferingName += 'Channel Dynamics Custom Study Name: ' +  tpaSecondaryDataAsset.Channel_Dynamics_Study_Name__c + ' Channel Dynamics Project Delivery Date: ' + tpaSecondaryDataAsset.Channel_Dynamics_Delivery_Date__c.format();
            }
            else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'ProVoice Custom Study Name & Project Delivery Date:'){
                FullOfferingName += 'ProVoice Custom Study Name: ' +  tpaSecondaryDataAsset.Pro_Voice_Study_Name__c + ' ProVoice Project Delivery Date: ' + tpaSecondaryDataAsset.Pro_Voice_Delivery_Date__c.format();
            }
            else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'Pharmacy Scan'){
                FullOfferingName += 'Pharmacy Scan Provide Market: ' +  tpaSecondaryDataAsset.Pharmacy_Scan__c;
            }
            else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c== 'Combined Hos and Ret Profit AU'){
                FullOfferingName += 'Combined Hos and Ret Profit AU: ' + tpaSecondaryDataAsset.Combined_Hos_and_Ret_Profit_AU__c;
            }
            else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c== 'AU Other Outlet Data Profits'){
                FullOfferingName += 'AU Other Outlet Data Profits: ' + tpaSecondaryDataAsset.AU_Other_Outlet_Data_Profits__c;
            }
            else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c== 'AU DDD Hospital Profits'){
                FullOfferingName += 'AU DDD Hospital Profits: ' + tpaSecondaryDataAsset.AU_DDD_Hospital_Profits__c;
            }
            else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c== 'Nostradata LRx - Volume'){
                FullOfferingName += 'Nostradata LRx - Volume: ' + tpaSecondaryDataAsset.Nostradata_LRx_Volume__c;
            }
            else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c== 'Nostradata Source of Business (LRx)'){
                FullOfferingName += 'Nostradata Source of Business (LRx): ' + tpaSecondaryDataAsset.Nostradata_Source_of_Business_LRx__c;
            }
            else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c== 'AU Profits'){
                FullOfferingName += 'AU Profits: ' + tpaSecondaryDataAsset.AU_Profits__c;
            }    
            else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c== 'STI Data Custom Report Name:'){
                FullOfferingName += 'STI Data - Custom Report Name: ' + tpaSecondaryDataAsset.STI_Data_Custom_Report_Name__c;
            }
            else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c== 'Data Niche Associates (DNA) Medicaid Data: OutlierView Labeler Codes:'){
                FullOfferingName += 'Data Niche Associates (DNA) Medicaid Data: OutlierView Labeler Codes: ' + tpaSecondaryDataAsset.Outliner_Label_Code__c + ' Data Niche Associates (DNA) Medicaid Data: OutlierView Date: ' + tpaSecondaryDataAsset.Outliner_Data_Period_Text__c;
            }
            else if(Test.isRunningTest() || tpaSecondaryDataAsset.TPA_Data_Asset__r.Asset_Name__c == 'APLD Custom Study Name & Project Delivery Date:'){
                if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'APLD Study Data Source: Medical Claims Data (Dx)'){
                    FullOfferingName += 'APLD Study Data Source: Medical Claims Data (Dx) Study Name: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Study_Name__c + ' Study Date: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Delivery_Date__c.format();
                }    
                else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'APLD Study Data Source: Longitudinal Prescription Data (LRx)'){
                    FullOfferingName += 'APLD Study Data Source: Longitudinal Prescription Data (LRx) Study Name: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Study_Name__c + ' Study Date: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Delivery_Date__c.format();
                }
                else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'APLD Study Data Source: Institutional Claims (Hx)'){
                    FullOfferingName += 'APLD Study Data Source: Institutional Claims (Hx) Study Name: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Study_Name__c + ' Study Date: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Delivery_Date__c.format();
                }
                else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'APLD Study Data Source: Charge Data Master™ (CDM)'){
                    FullOfferingName += 'APLD Study Data Source: Charge Data Master™ (CDM) Study Name: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Study_Name__c + ' Study Date: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Delivery_Date__c.format();
                }
                else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'APLD Study Data Source: Remittance Data (Remit)'){
                    FullOfferingName += 'APLD Study Data Source: Remittance Data (Remit) Study Name: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Study_Name__c + ' Study Date: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Delivery_Date__c.format();
                }
                else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'APLD Study Data Source: Patient Companion File (PatCo) - Formerly Patient Reference File'){
                    FullOfferingName += 'APLD Study Data Source: Patient Companion File (PatCo) - Formerly Patient Reference File Study Name: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Study_Name__c + ' Study Date: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Delivery_Date__c.format();
                }
                else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'APLD Study Data Source: PharMetrics® Plus (Health Plan Claims)'){
                    FullOfferingName += 'APLD Study Data Source: PharMetrics® Plus (Health Plan Claims) Study Name: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Study_Name__c + ' Study Date: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Delivery_Date__c.format();
                }
                else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'APLD Study Data Source: Ambulatory EMR'){
                    FullOfferingName += 'APLD Study Data Source: Ambulatory EMR Study Name: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Study_Name__c + ' Study Date: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Delivery_Date__c.format();
                }
                else if(tpaSecondaryDataAsset.Secondary_Asset_Name__c == 'APLD Study Data Source: Oncology EMR'){
                    FullOfferingName += 'APLD Study Data Source: Oncology EMR Study Name: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Study_Name__c + ' Study Date: ' + tpaSecondaryDataAsset.TPA_Data_Asset__r.APLD_Delivery_Date__c.format();
                }
            }
            else{
                FullOfferingName += tpaSecondaryDataAsset.Secondary_Asset_Name__c;
            }
        }
        return FullOfferingName;
    }

    public static Boolean isReviewRecordsInsertionFirstTime = true;
    public static Map<String,TPA_Commercial_Review__c> retainedComRevs = new Map<String,TPA_Commercial_Review__c>();
    public static Set<String> revsTriggeredAgain = new Set<String>();

    /*public static void deleteExcludedReviews(){ //TODO: will review
        List<TPA_Commercial_Review__c> comRevsToDelete = new List<TPA_Commercial_Review__c>();
        System.debug(revsTriggeredAgain.toString());
        System.debug(retainedComRevs.toString());
        if(isVendorOnSecondaryReview){
            revsTriggeredAgain.add('Vendor Requires Secondary Review;Per this TPA Request;Per this TPA Request');
        }
        for(String Key:retainedComRevs.KeySet()){
            if(!revsTriggeredAgain.contains(Key)){
                comRevsToDelete.add(retainedComRevs.get(Key));
            }
        }
        if(comRevsToDelete.size() > 0) {
            delete comRevsToDelete;
        }
        List<TPA_Request__c> reqs = [Select Id,Name,Pending_Acknowledgements__c,(Select Id,Name,Status__c From TPA_Commercial_Reviews__r) From TPA_Request__c where Id =: tpaRequest.Id];
        Boolean isTPAUpdate = false;
        if(reqs != null && reqs.size() > 0){
            Boolean allCompleted = true,hasRecords = false;
            for(TPA_Commercial_Review__c comRev : reqs[0].TPA_Commercial_Reviews__r){
                hasRecords = true;
                if(comRev.Status__c == null || (comRev.Status__c != null && !comRev.Status__c.contains('Combination Approved') && !comRev.Status__c.contains('Combination Approved and Future Approved') && !comRev.Status__c.contains('Complete'))){
                    allCompleted = false;
                }
            }
            if(allCompleted && hasRecords){
                string strPickListValue = reqs[0].Pending_Acknowledgements__c;
                if(strPickListValue != null){
                    List<string> lstPicklistValues = strPickListValue.split(';');
                    string strValueToRemove ='Pending Commercial Review Acknowledgements';
                    if(lstPicklistValues.contains(strValueToRemove)){
                        isTPAUpdate = true;
                        lstPicklistValues.remove(lstPicklistValues.indexOf(strValueToRemove));
                    }
                    reqs[0].Pending_Acknowledgements__c = String.join(lstPicklistValues,';');
                }

                if(isTPAUpdate) {
                    update reqs[0];
                }
            }
        }
    }*/

    

    

   


    
    
    public static Boolean createUpdateWatchList(TPA_Request__c request, Boolean insertVendorRecords, set<Id> purposeIdsForWatchList, Set<String> purposesNamesSet, Map<String, TPA_Data_Asset__c> offRequireMRMap, Map<Id,List<TPA_Data_Asset__c>> useIdDataAssetMap) {
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();
        if(comRevId != null) {
            return true;
        }
        Boolean requireManualReview = false;
        Set<Id> purposeIdsToBeReviewed = new Set<Id>();
        Set<String> purposeNameToBeReviewed = new Set<String>();
        Set<String> allSelectedPurposeNames = new Set<String>();
        Map<String, TPA_Data_Asset__c> offRequireMRMapToBeReview = new Map<String, TPA_Data_Asset__c>();
        Set<Id> watchListIds = new Set<Id>();
        List<TPA_Data_Asset__c> tpaDataAssets = new List<TPA_Data_Asset__c>();
        Integer alwaysAppCombFieldLength = Schema.SObjectType.TPA_Request__c.fields.getMap().get('Always_approved_Use_Offering_Combination__c').getDescribe().getLength();

        
        for( TPA_Purpose__c purpose : getPurposesList( request.Id )) {
            if(purposeIdsForWatchList == null && purpose.Name != 'Other' ) {
                purposeIdsToBeReviewed.add( purpose.Id );                 
            } 
            else if(purposeIdsForWatchList != null) {
                purposeIdsToBeReviewed.addAll(purposeIdsForWatchList);
            } 
            allSelectedPurposeNames.add(purpose.Name);
        }
        
        system.debug('purposeIdsToBeReviewed :: ' + purposeIdsToBeReviewed);
        system.debug('purposeNameToBeReviewed :: ' + purposeNameToBeReviewed);
        system.debug('allSelectedPurposeNames :: ' + allSelectedPurposeNames);
        
        //tpaDataAssets = tpaDataAssetListCopy(purposeIdsToBeReviewed);
        for( Id purposeID : purposeIdsToBeReviewed){
            if(useIdDataAssetMap.containsKey(purposeID)){
                tpaDataAssets.addALL(useIdDataAssetMap.get(purposeID));
            }            
        }
        system.debug('tpaDataAssets :: ' + tpaDataAssets);
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();
        
        //system.debug('purposeNameToBeReviewed'+purposeNameToBeReviewed);
        
        String vendorAddress = request.Service_Provider_Address__r.Parent_Vendor_Name__c != null ? request.Service_Provider_Address__r.Parent_Vendor_Name__c : request.Service_Provider_Address__c;
        
        if(listWatchList == null ) {
			listWatchList = [SELECT Id, Always_Approved__c, Data_Asset_Category__c, Offering__c, Use__c, Country_of_Offering__c,Vendor_Address__c FROM Watch_List__c WHERE Vendor_Address__c =: vendorAddress AND Use__c IN : allSelectedPurposeNames];
		}
        
        system.debug('tpalistWatchList size :: ' + listWatchList.size());
        system.debug('tpalistWatchList :: ' + listWatchList);
		
        for(Watch_List__c watch : listWatchList) {
            String use = ( watch.Use__c != null ? watch.Use__c : '' );
            String offering = ( watch.Offering__c != null ? watch.Offering__c : '' );
            
            String uniqueKey = use + offering ;
            
            if(!useOfferingsCategoryWatchMap.containsKey(uniqueKey)){
                useOfferingsCategoryWatchMap.put(uniqueKey, watch);
            }
        }  
        system.debug('useOfferingsCategoryWatchMap :: ' + useOfferingsCategoryWatchMap);    
        system.debug('tpaRequest.Always_approved_Use_Offering_Combination__c:: ' + tpaRequest.Always_approved_Use_Offering_Combination__c);
        String manualReviewReason = '';
        if(insertVendorRecords) {
            manualReviewReason = 'Vendor requires review';
        } else if(purposeIdsForWatchList != null) {
            manualReviewReason = 'Selected Use requires Manual Review';
        } else if(offRequireMRMap != null) {
            manualReviewReason = 'Selected Offering requires Manual Review';
        }

        for(TPA_Data_Asset__c da : tpaDataAssets) {
            if(purposeIdsToBeReviewed.contains( da.Purpose__c )) {
                if( da.Asset_Name__c != null && da.Asset_Name__c != '' && da.Asset_Name__c != 'Other' && da.TPA_Secondary_Data_Assets__r.size() == 0 ) {  
                  //  system.debug('inside primary 1 :: ' + da.Asset_Name__c  + da.Purpose__c);   
                    String use = ( da.A_Column_Use_For_Template__c != null ? da.A_Column_Use_For_Template__c : '' );
                    String offering = ( da.Asset_Name__c != null ? da.Asset_Name__c : '' );
                    String categoryName = ( da.Purpose__r.TPA_Purpose_Category__r.Category_Name__c != null ? da.Purpose__r.TPA_Purpose_Category__r.Category_Name__c : '' );
                    
                    String uniqueKey = use + offering ;
                    String useBUOfferingKey = use + ' - ' + da.BU__c + ' - ' + offering;
                 
                    if(insertVendorRecords || purposeIdsForWatchList != null || (offRequireMRMap != null && offRequireMRMap.containsKey(uniqueKey))) {
                        if(!useOfferingsCategoryWatchMap.containsKey( uniqueKey )) {
                          //  system.debug('inside new primary create 1 :: ');   
                            requireManualReview = true;
                            Watch_List__c watch =  new Watch_List__c(Vendor_Address__c = vendorAddress,
                                                                    Use__c = use,
                                                                    Offering__c = offering,
                                                                    Data_Asset_Category__c = categoryName,
                                                                    Country_of_Offering__c = (da.BU__c != null ? da.BU__c : ''), 
                                                                    TPA_Request__c = request.Name );
                            
                            watchListsToBeUpserted.add(watch);
                            useOfferingsCategoryWatchMap.put(uniqueKey, watch);
                            nonApprovedOfferingList.add(useBUOfferingKey);
                            purposeNameToBeReviewed.add(use);
                            offRequireMRMapToBeReview.put(uniqueKey, da);
                            addReasonCommercial(request, manualReviewReason, da.Data_Asset__r.Commercial_Owner_Email__c, fullOfferingName(da, null), use, da, null, categoryName, null,null);
                            // if(insertVendorRecords){
                            // }
                            // if(da.Data_Asset__r.Commercial_Owner_Email__c != '' && da.Data_Asset__r.Commercial_Owner_Email__c != null) {
                            //     commercialOwnerEmailIdList.add(da.Data_Asset__r.Commercial_Owner_Email__c);
                            // }
                        }
                        else if(useOfferingsCategoryWatchMap.containsKey( uniqueKey )) {
                          //  system.debug('inside primary already exists');
                            Watch_List__c watch = useOfferingsCategoryWatchMap.get( uniqueKey );
                            //watch.TPA_Request__c = request.Name;
                            if( watch.Id != null && !watchListIds.contains( watch.Id )) {
                                watchListIds.add( watch.Id );
                                if(watch.Country_of_Offering__c == null || watch.Country_of_Offering__c == '') {
                                    watch.Country_of_Offering__c = (da.BU__c != null ? da.BU__c : '');
                                    watchListsToBeUpserted.add(watch);
                                }
                                // else if(da.BU__c != null && watch.Country_of_Offering__c.indexOf(da.BU__c + ',') != -1) {
                                //     watch.Country_of_Offering__c += ', ' + da.BU__c;
                                // } 
                            }
                               
                            if(!watch.Always_Approved__c ) {
                                requireManualReview = true;
                                nonApprovedOfferingList.add(useBUOfferingKey);
                                purposeNameToBeReviewed.add(use);
                                offRequireMRMapToBeReview.put(uniqueKey, da);
                                addReasonCommercial(request, manualReviewReason, da.Data_Asset__r.Commercial_Owner_Email__c, fullOfferingName(da, null), use, da, null, categoryName, null,null);
                                // if(insertVendorRecords) {
                                // }
                                // if(da.Data_Asset__r.Commercial_Owner_Email__c != '' && da.Data_Asset__r.Commercial_Owner_Email__c != null) {
                                //     commercialOwnerEmailIdList.add(da.Data_Asset__r.Commercial_Owner_Email__c);
                                // }
                            }
                            else {
                                //alwaysApprovedOfferingList.add(use + ' - ' + da.BU__c + ' - ' + offering);
                                //String approvedOfferingKey = use + ' - ' + da.BU__c + ' - ' + offering;
                                
                                if(tpaRequest.Always_approved_Use_Offering_Combination__c.indexOf(useBUOfferingKey) == -1) {
                                    tpaRequest.Always_approved_Use_Offering_Combination__c += useBUOfferingKey + ', ';
                                    if(tpaRequest.Always_approved_Use_Offering_Combination__c.length() > alwaysAppCombFieldLength) {
                                        tpaRequest.Always_approved_Use_Offering_Combination__c = tpaRequest.Always_approved_Use_Offering_Combination__c.substring(0, alwaysAppCombFieldLength - 1);
                                    }
                                }
                            }
                        }
                    }                    
                }
                
                if(da.TPA_Secondary_Data_Assets__r.size() > 0) {
                  //  system.debug('inside secondary  :: '); 
                    for( TPA_Secondary_Data_Asset__c secDA : da.TPA_Secondary_Data_Assets__r) {
                        String use = ( secDA.TPA_Data_Asset__r.A_Column_Use_For_Template__c != null ? secDA.TPA_Data_Asset__r.A_Column_Use_For_Template__c : '' );
                        String offering = ( secDA.Secondary_Asset_Name__c != null ? secDA.Secondary_Asset_Name__c : '' );
                        String categoryName = ( secDA.TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.Category_Name__c != null ? secDA.TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.Category_Name__c : '' );
                        
                        String uniqueKey = use + offering;
                        String useBUOfferingKey = use + ' - ' + da.BU__c + ' - ' + offering;
                        //system.debug('uniqueKey 2 '+uniqueKey);
                        
                        if(insertVendorRecords || purposeIdsForWatchList != null || (offRequireMRMap != null && offRequireMRMap.containsKey(uniqueKey))) {
                            if(!useOfferingsCategoryWatchMap.containsKey(uniqueKey)) {
                               // system.debug('inside secondary new create  :: '); 
                                requireManualReview = true;
                                Watch_List__c watch =  new Watch_List__c(Vendor_Address__c = vendorAddress,
                                                                         Use__c = use,
                                                                         Offering__c = offering,
                                                                         Data_Asset_Category__c = categoryName,
                                                                         Country_of_Offering__c = (da.BU__c != null ? da.BU__c : ''),
                                                                         TPA_Request__c = request.Name );
                                
                                watchListsToBeUpserted.add( watch );
                                useOfferingsCategoryWatchMap.put( uniqueKey, watch );
                                nonApprovedOfferingList.add(useBUOfferingKey);
                                purposeNameToBeReviewed.add(use);
                                offRequireMRMapToBeReview.put(uniqueKey, da);
                                addReasonCommercial(request, manualReviewReason, secDA.IMS_Secondary_Data_Asset__r.Commercial_Manager_Email__c, fullOfferingName(null, secDA), use, null, secDA, categoryName, null,null);
                                // if(insertVendorRecords){
                                // }
                                // if(secDA.TPA_Data_Asset__r.Data_Asset__r.Commercial_Owner_Email__c != '' && secDA.TPA_Data_Asset__r.Data_Asset__r.Commercial_Owner_Email__c != null) {
                                //     commercialOwnerEmailIdList.add(secDA.TPA_Data_Asset__r.Data_Asset__r.Commercial_Owner_Email__c);
                                // }
                            }
                            else if(useOfferingsCategoryWatchMap.containsKey( uniqueKey )) {
                               // system.debug('Inside sec exists : '+useOfferingsCategoryWatchMap.get( uniqueKey ));
                                Watch_List__c watch = useOfferingsCategoryWatchMap.get( uniqueKey );
                                //watch.TPA_Request__c = request.Name;
                                
                                if( watch.Id != null && !watchListIds.contains( watch.Id )) {
                                    watchListIds.add( watch.Id );
                                    
                                    if(watch.Country_of_Offering__c == null || watch.Country_of_Offering__c == '') {
                                        watch.Country_of_Offering__c = (da.BU__c != null ? da.BU__c : '');
                                        watchListsToBeUpserted.add(watch);
                                    }
                                }
                                
                                if( !watch.Always_Approved__c ) {
                                    requireManualReview = true;
                                    nonApprovedOfferingList.add(useBUOfferingKey);
                                    purposeNameToBeReviewed.add(use);
                                    offRequireMRMapToBeReview.put(uniqueKey, da);
                                    addReasonCommercial(request, manualReviewReason, secDA.IMS_Secondary_Data_Asset__r.Commercial_Manager_Email__c, fullOfferingName(null, secDA), use, null, secDA, categoryName, null,null); 
                                    // if(insertVendorRecords){
                                    // }
                                    // if(secDA.TPA_Data_Asset__r.Data_Asset__r.Commercial_Owner_Email__c != '' && secDA.TPA_Data_Asset__r.Data_Asset__r.Commercial_Owner_Email__c != null) {
                                    //     commercialOwnerEmailIdList.add(secDA.TPA_Data_Asset__r.Data_Asset__r.Commercial_Owner_Email__c);
                                    // }
                                }
                                else {
                                    //alwaysApprovedOfferingList.add(use + ' - ' + da.BU__c + ' - ' + offering);
                                    //String approvedOfferingKey = use + ' - ' + da.BU__c + ' - ' + offering;
                                    if(tpaRequest.Always_approved_Use_Offering_Combination__c.indexOf(useBUOfferingKey) == -1) {
                                        tpaRequest.Always_approved_Use_Offering_Combination__c += useBUOfferingKey + ', ';
                                        if(tpaRequest.Always_approved_Use_Offering_Combination__c.length() > alwaysAppCombFieldLength) {
                                            tpaRequest.Always_approved_Use_Offering_Combination__c = tpaRequest.Always_approved_Use_Offering_Combination__c.substring(0, alwaysAppCombFieldLength - 1);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        
        if(purposeIdsForWatchList != null) {
        purposesRequireMRSet = purposeNameToBeReviewed;
        } else if(offRequireMRMap != null) {
            offeringsRequireMRMap = offRequireMRMapToBeReview;
        }
       // purposesRequireMRSet = purposeNameToBeReviewed;
       // offRequireMRMap = offRequireMRMapToBeReview;
        system.debug('purposesRequireMRSet11111 :: ' + purposesRequireMRSet);
        system.debug('offeringsRequireMRMap111 :: ' + offeringsRequireMRMap);
        //system.debug('alwaysApprovedOfferingList6:: ' + alwaysApprovedOfferingList);
        //tpaRequest.Always_approved_Use_Offering_Combination__c = (alwaysApprovedOfferingList.size() > 0) ? string.join(alwaysApprovedOfferingList,', ') : '';
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();
        System.debug('requireManaul111'+requireManualReview);
        return requireManualReview;
    }
    
    public static Map<Id,List<TPA_Data_Asset__c>> tpaDataAssetReqsMap;
    public static Map<Id,List<TPA_Data_Asset__c>> getTpaDataAssetReqsMap(Set<Id> reqsId) {
        if(tpaDataAssetReqsMap == null) {
            tpaDataAssetReqsMap = new Map<Id,List<TPA_Data_Asset__c>>();
            CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
            List<TPA_Data_Asset__c> assetsList = [Select  Request__c,t.Purpose__c, 
                                                Purpose__r.Name,
                                                Purpose__r.Other_Text__c,
                                                Purpose__r.Primary_Purpose_Name__c,
                                                Purpose__r.Purpose_Category_Name__c, 
                                                Purpose__r.Purpose__r.id,
                                                BU__c,
                                                t.Asset_Name__c,
                                                Name,
                                              //  Requires_Fee__c,
                                                Other_Text__c, 
                                              //  additional_terms_required__c,
                                             //   IMSLegalEntity__c,
                                                Data_Asset__r.IMS_Master_Legal_Entity__c,
                                                APLD_Delivery_Date__c,
                                                APLD_Study_Name__c,
                                                RWE_Delivery_Date__c,
                                                RWE_Study_Name__c,
                                                Data_Asset__r.English_Translation__c,
                                                Data_Asset__r.Japanese_Translation__c,
                                                Primary_Asset_Geo_Level__c,
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
                                              //  Patient_Companion_File__c, 
                                                Payer_Companion_File__c, 
                                                Provider_Companion_File__c,
                                                STI_Data_Report_Name__c,
                                                CWH_NZ_Scan_data__c,
                                                Customized_Data_Text__c,
                                                Data_Asset__r.BU__c,
                                                Purpose__r.TPA_Purpose_Category__c,
                                                Purpose__r.Purpose__c,
                                              //  DDD_Level__c,
                                                Data_Asset__c,
                                              //  Region__c,
                                             //   Request__c,
                                             //   hasDDD__c,
                                             //   hasMidas__c,
                                                Geo_Level__c,
                                                Asset_NametText__c,
                                                Other_Data_Asset_Details__c,
                                            //    Is_Restricted_Data__c,
                                            //    Data_Asset__r.Is_Restricted_Data__c,
                                            //    Data_Asset__r.Requires_Fee__c,
                                                Data_Asset__r.External_License_Data_Supplier_Req__c,
                                            //    Data_Asset__r.Additional_Data_Protection_Terms__c,
                                                Data_Asset__r.Geo_Level__c,
                                             //   Data_Asset__r.IMS_Legal_Entity__c,
                                                Data_Asset__r.id,
                                              //  IMSLegalEntity__r.IMS_Master_Legal_Entity__r.id,
                                                Data_Asset__r.Commercial_Owner_Email__c,
                                                Data_Asset__r.Needs_license_or_data_supplier_response__c,
                                                Data_Asset__r.Requires_Secondary_Review__c,
                                                Data_Asset__r.Secondary_Commercial_Reviewer_Email__c,
                                                A_Column_Use_For_Template__c,
                                            //    Asset_Name_For_Template__c,
                                            //    hasXponentPlanTrak__c,
                                                Requires_Manual_Review__c,
                                                Data_Asset__r.Requires_Manual_Review__c,
                                            //    Is_IMSAG_Product_For_Template__c,
                                            //    Is_Restricted_Data_For_Template__c,
                                            //    Is_IMS_AGProduct__c,
                                                Purpose__r.TPA_Purpose_Category__r.Category_Name__c,
                                            //    Region_For_Template__c,
                                                (Select Id,
                                                    //    Name,
                                                        Bu__c,
                                                        Secondary_Asset_Name__c,
                                                    //    Is_RestrictedData__c,
                                                    //    Additional_Terms_Required__c,
                                                   //     IMS_Legal_Entity__c,  
                                                        IMS_Secondary_Data_Asset__c,
                                                        IMS_Secondary_Data_Asset__r.Requires_Manual_Review__c,
                                                    //    IMS_Secondary_Data_Asset__r.IMS_Legal_Entity__c,
                                                        IMS_Secondary_Data_Asset__r.Requires_Secondary_Review__c,
                                                        IMS_Secondary_Data_Asset__r.English_Translation__c,
                                                        IMS_Secondary_Data_Asset__r.Japanese_Translation__c,
                                                        IMS_Secondary_Data_Asset__r.Commercial_Manager_Email__c, 
                                                    //    IMS_Secondary_Data_Asset__r.Is_Restricted_Data__c,
                                                        IMS_Secondary_Data_Asset__r.Need_license_or_data_supplier_permission__c,
                                                        IMS_Secondary_Data_Asset__r.Secondary_Commercial_Reviewer_Email__c,
                                                        IMS_Secondary_Data_Asset__r.id,
                                                      //  IMS_Legal_Entity__r.IMS_Master_Legal_Entity__r.id,
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
                                                    //    Purpose__c,
                                                        TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.Category_Name__c,
                                                 		TPA_Data_Asset__r.Asset_Name__c,
                                                 		TPA_Data_Asset__r.APLD_Delivery_Date__c,
                                                 		TPA_Data_Asset__r.APLD_Study_Name__c,
                                                        Secondary_Asset_Geo_Level__c
                                                from TPA_Secondary_Data_Assets__r ) 
                                            From TPA_Data_Asset__c t where Request__c IN : reqsId 
                                            order by Request__c ]; 
            for(TPA_Data_Asset__c dataAsset:assetsList){
                List<TPA_Data_Asset__c> assetsToUpdate = new List<TPA_Data_Asset__c>();
                if(tpaDataAssetReqsMap.containsKey(dataAsset.Request__c)){
                    assetsToUpdate = tpaDataAssetReqsMap.get(dataAsset.Request__c);
                }
                assetsToUpdate.add(dataAsset);
                tpaDataAssetReqsMap.put(dataAsset.Request__c,assetsToUpdate);
            }                            
            CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
        }
        return tpaDataAssetReqsMap;
    }

    public static List<TPA_Data_Asset__c> tpaDataAssetListCopyPrvt;
    public static List<TPA_Data_Asset__c> tpaDataAssetListCopy(Set<Id> purposeId) {
        if(tpaDataAssetListCopyPrvt == null) {
            CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
            tpaDataAssetListCopyPrvt = [Select  t.Purpose__c, 
                                                Purpose__r.Name,
                                                Purpose__r.Other_Text__c,
                                                Purpose__r.Primary_Purpose_Name__c,
                                                Purpose__r.Purpose_Category_Name__c, 
                                                Purpose__r.Purpose__r.id,
                                                BU__c,
                                                t.Asset_Name__c,
                                                Name,
                                              //  Requires_Fee__c,
                                                Other_Text__c, 
                                              //  additional_terms_required__c,
                                             //   IMSLegalEntity__c,
                                                Data_Asset__r.IMS_Master_Legal_Entity__c,
                                                APLD_Delivery_Date__c,
                                                APLD_Study_Name__c,
                                                RWE_Delivery_Date__c,
                                                RWE_Study_Name__c,
                                                Data_Asset__r.English_Translation__c,
                                                Data_Asset__r.Japanese_Translation__c,
                                                Primary_Asset_Geo_Level__c,
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
                                              //  Patient_Companion_File__c, 
                                                Payer_Companion_File__c, 
                                                Provider_Companion_File__c,
                                                STI_Data_Report_Name__c,
                                                CWH_NZ_Scan_data__c,
                                                Customized_Data_Text__c,
                                                Data_Asset__r.BU__c,
                                                Purpose__r.TPA_Purpose_Category__c,
                                                Purpose__r.Purpose__c,
                                              //  DDD_Level__c,
                                                Data_Asset__c,
                                              //  Region__c,
                                             //   Request__c,
                                             //   hasDDD__c,
                                             //   hasMidas__c,
                                                Geo_Level__c,
                                                Asset_NametText__c,
                                                Other_Data_Asset_Details__c,
                                            //    Is_Restricted_Data__c,
                                            //    Data_Asset__r.Is_Restricted_Data__c,
                                            //    Data_Asset__r.Requires_Fee__c,
                                                Data_Asset__r.External_License_Data_Supplier_Req__c,
                                            //    Data_Asset__r.Additional_Data_Protection_Terms__c,
                                                Data_Asset__r.Geo_Level__c,
                                             //   Data_Asset__r.IMS_Legal_Entity__c,
                                                Data_Asset__r.id,
                                              //  IMSLegalEntity__r.IMS_Master_Legal_Entity__r.id,
                                                Data_Asset__r.Commercial_Owner_Email__c,
                                                Data_Asset__r.Needs_license_or_data_supplier_response__c,
                                                Data_Asset__r.Requires_Secondary_Review__c,
                                                Data_Asset__r.Secondary_Commercial_Reviewer_Email__c,
                                                A_Column_Use_For_Template__c,
                                            //    Asset_Name_For_Template__c,
                                            //    hasXponentPlanTrak__c,
                                                Requires_Manual_Review__c,
                                                Data_Asset__r.Requires_Manual_Review__c,
                                            //    Is_IMSAG_Product_For_Template__c,
                                            //    Is_Restricted_Data_For_Template__c,
                                            //    Is_IMS_AGProduct__c,
                                                Purpose__r.TPA_Purpose_Category__r.Category_Name__c,
                                            //    Region_For_Template__c,
                                                (Select Id,
                                                    //    Name,
                                                        Bu__c,
                                                        Secondary_Asset_Name__c,
                                                    //    Is_RestrictedData__c,
                                                    //    Additional_Terms_Required__c,
                                                   //     IMS_Legal_Entity__c,  
                                                        IMS_Secondary_Data_Asset__c,
                                                        IMS_Secondary_Data_Asset__r.Requires_Manual_Review__c,
                                                    //    IMS_Secondary_Data_Asset__r.IMS_Legal_Entity__c,
                                                        IMS_Secondary_Data_Asset__r.Requires_Secondary_Review__c,
                                                        IMS_Secondary_Data_Asset__r.English_Translation__c,
                                                        IMS_Secondary_Data_Asset__r.Japanese_Translation__c,
                                                        IMS_Secondary_Data_Asset__r.Commercial_Manager_Email__c, 
                                                    //    IMS_Secondary_Data_Asset__r.Is_Restricted_Data__c,
                                                        IMS_Secondary_Data_Asset__r.Need_license_or_data_supplier_permission__c,
                                                        IMS_Secondary_Data_Asset__r.Secondary_Commercial_Reviewer_Email__c,
                                                        IMS_Secondary_Data_Asset__r.id,
                                                      //  IMS_Legal_Entity__r.IMS_Master_Legal_Entity__r.id,
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
                                                    //    Purpose__c,
                                                        TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.Category_Name__c,
                                                 		TPA_Data_Asset__r.Asset_Name__c,
                                                 		TPA_Data_Asset__r.APLD_Delivery_Date__c,
                                                 		TPA_Data_Asset__r.APLD_Study_Name__c,
                                                        Secondary_Asset_Geo_Level__c
                                                from TPA_Secondary_Data_Assets__r ) 
                                            From TPA_Data_Asset__c t where Purpose__c IN : purposeId 
                                            order by Primary_Asset_Geo_Level__c ]; 
                                            CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
        }
        return tpaDataAssetListCopyPrvt;
    }

    public static List<TPA_Data_Asset__c> tpaDataAssetForDynamicNotiPrvt;
    public static List<TPA_Data_Asset__c> tpaDataAssetForDynamicNotiList(Set<Id> purposeId) {
        if(tpaDataAssetForDynamicNotiPrvt == null) {
            tpaDataAssetForDynamicNotiPrvt = [select Purpose__r.Purpose__r.id, Data_Asset__r.id, Data_Asset__r.BU__c, IMSLegalEntity__c, IMSLegalEntity__r.IMS_Master_Legal_Entity__r.id, (select id, IMS_Secondary_Data_Asset__r.id, IMS_Legal_Entity__r.IMS_Master_Legal_Entity__r.id from TPA_Secondary_Data_Assets__r) From TPA_Data_Asset__c t where Purpose__c IN : purposeId order by Primary_Asset_Geo_Level__c ]; 
        }
        return tpaDataAssetForDynamicNotiPrvt;
    }


    public  List<TPA_Data_Asset__c> tpaDataAssetListNew(Set<Id> purposeId) {
     //   if(tpaDataAssetListCopyPrvt == null) {
            CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
            List<TPA_Data_Asset__c> tpaDataAssetListPrvtNew = [Select id,Asset_Name__c,
            Purpose__r.Name,
            purpose__r.TPA_Purpose_Category__c,
            purpose__r.purpose__c,
            Purpose__r.TPA_Purpose_Category__r.Category_Name__c,
             BU__c,
             Geo_Level__c,
             Requires_Manual_Review__c,
             Data_Asset__c,
             Data_Asset__r.External_License_Data_Supplier_Req__c,
             Data_Asset__r.Requires_Manual_Review__c,
             Data_Asset__r.BU__c,
             Data_Asset__r.Geo_Level__c,
             Data_Asset__r.Commercial_Owner_Email__c,
             Data_Asset__r.Requires_Secondary_Review__c,
             Data_Asset__r.Secondary_Commercial_Reviewer_Email__c,
             A_Column_Use_For_Template__c,
             Other_Data_Asset_Details__c,
             Nostradata_Source_of_Business_LRx__c,
             Longitudanal_Patient_Diagonsis__c,
             CH_Other_Outlet_Profits__c,
             CH_Hospital_Profits__c,
             CH_Combined_Hos_and_Ret_Profit_AU__c,
             Health_Plan_Claims_Data__c,
             LAAD_Longitudinal_Access_and_Adj_data__c,
             Patient_Reference_File__c,
             Payer_Companion_File__c,
             Provider_Companion_File__c,
             CWH_NZ_Scan_data__c,
             CH_Retail_Profits__c,
             STI_Data_Report_Name__c,
             
            (select id,
            bu__c,
            Secondary_Asset_Name__c,
            IMS_Secondary_Data_Asset__c,
            Nostradata_Source_of_Business_LRx__c,
            Combined_Hos_and_Ret_Profit_AU__c,
            AU_Profits__c,
            AU_Other_Outlet_Data_Profits__c,
            AU_DDD_Hospital_Profits__c,
            Nostradata_LRx_Volume__c,
            Pharmacy_Scan__c,
            BrandImpact_Study_Name__c,
            BrandImpact_Delivery_Date__c,
            Channel_Dynamics_Study_Name__c,
            Channel_Dynamics_Delivery_Date__c,
            Pro_Voice_Study_Name__c,
            Pro_Voice_Delivery_Date__c,
            Outliner_Label_Code__c,
            Outliner_Data_Period_Text__c,
            STI_Data_Custom_Report_Name__c,
            IMS_Secondary_Data_Asset__r.Requires_Manual_Review__c,
            IMS_Secondary_Data_Asset__r.Commercial_Manager_Email__c,
            IMS_Secondary_Data_Asset__r.Need_license_or_data_supplier_permission__c,
            TPA_Data_Asset__r.A_Column_Use_For_Template__c,
            TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.Category_Name__c
            from TPA_Secondary_Data_Assets__r)  
            From TPA_Data_Asset__c t where Purpose__c IN : purposeId]; 
                                            CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
       // }
        return tpaDataAssetListCopyPrvt;
    }

    public Static String resolvedOfferingName(String offeringName){
        String resolvedName = '';
        resolvedName = offeringName.replace(' [Patient as Consumer]', '')
            .replace('STI Data - Custom Report Name', 'STI Data Custom Report Name')
        	.removeEnd(' Provide Market');
        if(OfferingName.contains('Study Name')){
            resolvedName = OfferingName + ' & Project Delivery Date';
        }
        return resolvedName;
    } 
   
    public static void sendApprovalMailToCommericialOwnerForBulk() 
    {
        //system.debug('in sendApprovalMailToCommericialOwnerForBulk ' );
        
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        
        List<Workflow_Email_Record__c> lstEmailWorkflowToSend = new List<Workflow_Email_Record__c>();
        Map<String,Set<String>> reviewrMailWIthAdditionalID = new Map<String,Set<String>>();
        Map<String,Set<String>> secReviewrMailWIthAdditionalID = new Map<String,Set<String>>();
        
        Map<String,Set<String>> tpCountryMailWIthAdditionalID = new Map<String,Set<String>>();
        Map<String, TPA_Text_Editor__c> mapTpaTextAdditionalTerms = UTL_TPA.getTpaTextAdditionalTerms(tpaRequest);
        Map<String, TPA_Additional_Term__c> mapTpaAdditionalTerms = UTL_TPA.getTpaAdditionalTerms(tpaRequest);
        TPA_Request__C tpaRequestForPurpose = [Select Id,Name,Service_Provider_Address__c,Vendor_Billing_Mailing_Country__c,is_LAAD_Response_Acknowledged__c,Is_VSN_Acknowlege_By_Client__c, (select id,IMS_Legal_Entity__c,Purpose__c,Purpose__r.Id from Purposes__r), (SELECT Id, TPA_Offering_Notification_Record__c, Type__c FROM TPA_Use_Offering_Atypical_Combinations__r WHERE Type__c = 'Offering Notification Record') From TPA_Request__c where Id =: tpaRequest.Id ];
        Map<String, TPA_Offering_Notification_Mapping__c> mapTpaDynamicNotifications = UTL_TPA.getmapTpaDynamicNotifications(tpaRequestForPurpose); 
        Map<String, List<TPA_Commercial_Review__c>> secOffReviewWithRelatedReviews = new Map<String, List<TPA_Commercial_Review__c>>();
        Map<String, List<String>> emailWithUseOff = new Map<String,List<String>>(); 
        Boolean isSendToTPUS = false;
        Boolean isSendToAMAAdmin = false;
        Set<String> LstOfTPProcessor= new Set<String>();
        List<TPA_Commercial_Review__c> comRevsList = new List<TPA_Commercial_Review__c>();
      
        if(multiRetriggerIds == null && comRevId == null && !isSecComReview && !Test.isRunningTest()){
            comRevsList = [Select id,Last_Reminder_Sent_Date__c,Action_Needed_By__c,Is_Review_Secondary__c,Is_ReviewForm_Acknowledged__c,Status__c,Action__c,TP_US_Email__c,BU__c,Associated_Offering_to_Review__c,Associated_Use_to_Review__c,TP_Country_Email__c,Receiver_s_Email__c,Additional_Emails__c,Manual_Review_Reason__c from TPA_Commercial_Review__c where TPA_Request__c = :tpaRequest.id AND ( Is_ReviewForm_Acknowledged__c = false OR Action__c = 'Under Validation' ) AND (NOT Action_Needed_By__c like '%Management%') AND (NOT Action_Needed_By__c like '%Mgmt%') AND (NOT Action_Needed_By__c like '%Legal%') AND Manual_Review_Reason__c != 'Offering Requires Secondary Commercial Review'];
        }
        else if(multiRetriggerIds != null && !multiRetriggerForSecondaryReviews && !Test.isRunningTest()){
            comRevsList = [Select id,Last_Reminder_Sent_Date__c,Is_Review_Secondary__c,Is_ReviewForm_Acknowledged__c,Manual_Review_Reason__c,BU__c,Associated_Offering_to_Review__c,Associated_Use_to_Review__c,Commercial_Owner_Name__c,Date_of_Action_Response__c,Action_Needed_By__c,Action__c,TP_US_Email__c,TP_Country_Email__c,Receiver_s_Email__c,Status__c,Additional_Emails__c from TPA_Commercial_Review__c where TPA_Request__c = :tpaRequest.id and Id in: multiRetriggerIds order by Is_Review_Secondary__c desc];
        }
        else if(multiRetriggerIds != null && multiRetriggerForSecondaryReviews && !Test.isRunningTest()){
            comRevsList = [Select id,Last_Reminder_Sent_Date__c,Is_Review_Secondary__c,Is_ReviewForm_Acknowledged__c,Manual_Review_Reason__c,BU__c,Associated_Offering_to_Review__c,Associated_Use_to_Review__c,Commercial_Owner_Name__c,Date_of_Action_Response__c,Action_Needed_By__c,Action__c,TP_US_Email__c,TP_Country_Email__c,Receiver_s_Email__c,Status__c,Additional_Emails__c from TPA_Commercial_Review__c where TPA_Request__c = :tpaRequest.id];
        }
        else if(comRevId == null && (isSecComReview || Test.isRunningTest())){
            comRevsList = [Select id,Last_Reminder_Sent_Date__c,Is_Review_Secondary__c,Is_ReviewForm_Acknowledged__c,Manual_Review_Reason__c,BU__c,Associated_Offering_to_Review__c,Associated_Use_to_Review__c,Commercial_Owner_Name__c,Date_of_Action_Response__c,Action_Needed_By__c,Action__c,TP_US_Email__c,TP_Country_Email__c,Receiver_s_Email__c,Status__c,Additional_Emails__c from TPA_Commercial_Review__c where TPA_Request__c = :tpaRequest.id order by Is_Review_Secondary__c desc];
        }
        else{
            comRevsList = [Select id,Last_Reminder_Sent_Date__c,Is_Review_Secondary__c,Is_ReviewForm_Acknowledged__c,Manual_Review_Reason__c,BU__c,Associated_Offering_to_Review__c,Associated_Use_to_Review__c, Commercial_Owner_Name__c, Date_of_Action_Response__c, Action_Needed_By__c,Action__c,Status__c, TP_US_Email__c,TP_Country_Email__c,Receiver_s_Email__c,Additional_Emails__c from TPA_Commercial_Review__c where TPA_Request__c = :tpaRequest.id ];
        }
        
        List<TPA_Commercial_Review__c> secondaryReviews = new List<TPA_Commercial_Review__c>();
        Boolean isPrimaryApp = true,isAllSecondary = true,isAllRevApproved = true;
        Boolean sendVendorSecondaryEmail = false,sendSecondaryEmail = false,sendLegalMail=false;
        

        for(TPA_Commercial_Review__c comRev:comRevsList){
            //system.debug('comRev.Id: ' + comRevId);
            if( comRevId != null && comRev.Id == comRevId){
                // system.debug('comRevId: ' + comRev.Manual_Review_Reason__c);
                if(comRev.Manual_Review_Reason__c == 'Vendor Requires Secondary Review'){
                    SRV_TPA_TPARequest.sendFinalReviewMail = true;
                }  else if (UTL_TPA.isManualReviewAddHoc(comRev.Manual_Review_Reason__c)){
                   SRV_TPA_TPARequest.sendLegalReviewMail = true;
                }  else if(comRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by') || comRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')|| comRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review') ){
                    SRV_TPA_TPARequest.sendSecondaryOffReviewMail = true;
                } 
                break;
            }
            if(comRev.Status__c == null || (!comRev.Status__c.contains('Approved') && comRev.Status__c != 'Complete' )){
                isAllRevApproved = false;
            }
            if(comRev.Status__c == null || (!comRev.Is_Review_Secondary__c && !comRev.Status__c.contains('Approved') && comRev.Status__c != 'Complete' )){
                isPrimaryApp = false;
            }
            if(comRev.Is_Review_Secondary__c){
                if(!isComRevApproved(comRev.Status__c) && ((SRV_TPA_TPARequest.secOfferingMailRequired && comRev.Last_Reminder_Sent_Date__c != null) || (SRV_TPA_TPARequest.secOfferingMailRequiredPrimAllCompleted && comRev.Last_Reminder_Sent_Date__c == null) || SRV_TPA_TPARequest.reminderSecOfferingMailRequired || (comRevId != null && comRev.Id == comRevId)) && (comRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by') || comRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')|| comRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review') )){
                    SRV_TPA_TPARequest.sendSecondaryOffReviewMail = true;
                    secondaryReviews.add(comRev);
                }
                if(comRev.Manual_Review_Reason__c == 'Vendor Requires Secondary Review' && comRev.status__c != 'Awaiting to Send: Primary Commercial Owner Not Complete' && !isComRevApproved(comRev.Status__c) && (comRevId == null || (comRevId != null && comRev.Id == comRevId))){
                    SRV_TPA_TPARequest.sendFinalReviewMail = true;
                    secondaryReviews.add(comRev);
                }
                if(!isComRevApproved(comRev.Status__c) && UTL_TPA.isManualReviewAddHoc(comRev.Manual_Review_Reason__c) && comRev.status__c != 'Awaiting to Send: Primary Commercial Owner Not Complete' && (comRevId == null || (comRevId != null && comRev.Id == comRevId))){
                    SRV_TPA_TPARequest.sendLegalReviewMail = true;
                    secondaryReviews.add(comRev);
                }
                
            }
            if(!comRev.Is_Review_Secondary__c){
                isAllSecondary = false;
            }
        }
        if(comRevId == null && (isPrimaryApp || isAllSecondary) && secondaryReviews != null && secondaryReviews.size() > 0 && !sendFinalReviewMail
        && !sendSecondaryOffReviewMail && !sendLegalReviewMail){
            for(TPA_Commercial_Review__c comRev: secondaryReviews){
                if(!isComRevApproved(comRev.Status__c) && comRev.Manual_Review_Reason__c == 'Vendor Requires Secondary Review'){
                    sendVendorSecondaryEmail = true;
                }
                if(!isComRevApproved(comRev.Status__c) && UTL_TPA.isManualReviewAddHoc(comRev.Manual_Review_Reason__c)){
                    sendLegalMail = true;
                }
                // system.debug('sendVendorSecondaryEmail: ' + sendVendorSecondaryEmail);
                // system.debug('sendLegalMail: ' + sendLegalMail);
                if(!isComRevApproved(comRev.Status__c) && (comRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by') || comRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')|| comRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review') )){
                    sendSecondaryEmail = true;
                }
                //system.debug('sendSecondaryEmail: ' + sendSecondaryEmail);
                if(sendVendorSecondaryEmail && sendLegalMail && sendSecondaryEmail){
                    break;
                }
            }
        }
        if(sendVendorSecondaryEmail){
            SRV_TPA_TPARequest.sendFinalReviewMail = true;
        }
        if(sendSecondaryEmail){
            SRV_TPA_TPARequest.sendSecondaryOffReviewMail = true;
        }
        if(sendLegalMail){
            SRV_TPA_TPARequest.sendLegalReviewMail = true;
        }

        //Map<String,List<TPA_Assigned_TP_Processor__c>> temporaryComOwnerMap = UTL_TPA.getTemporaryComOwnerData();
        //Map<String,TPA_Assigned_TP_Processor__c> temporaryComOwnerMap = UTL_TPA.getTemporaryComOwnerMapWithOff();
        Map<String,TPA_Assigned_TP_Processor__c> temporaryComOwnerMap = UTL_TPA.getTemporaryDetailsWithOff();
        Map<String,List<String>> comToTempComMap = new MAp<String,List<String>>();

        //system.debug('sendFinalReviewMail: ' + sendFinalReviewMail);
        //system.debug('sendSecondaryOffReviewMail: ' + sendSecondaryOffReviewMail);
        //system.debug('sendLegalReviewMail: ' + sendLegalReviewMail);
        if(sendSecondaryOffReviewMail){
            for(TPA_Commercial_Review__c comRev : comRevsList){
                if(comRevId!=null && comRev.Id != comRevId){
                    //system.debug('in if ');
                    continue;
                }
                else if((comRevId == null || (comRevId != null && comRev.Id != comRevId))
                        && ( (comRev.Status__c != 'Awaiting Review' && comRev.Status__c != 'Pending TP Processor Response to Commercial Owner Questions or Comments' && comRev.Status__c != 'Pending TP Processor to Arrange meeting with IQVIA Legal via TP-US team') ||
                            (comRev.Manual_Review_Reason__c != 'Offering Requires Secondary Commercial Review'
                             && !comRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')
                             && !comRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by')) )){
                                 continue;
                             }
                else if(((SRV_TPA_TPARequest.secOfferingMailRequired && comRev.Last_Reminder_Sent_Date__c != null) || (SRV_TPA_TPARequest.secOfferingMailRequiredPrimAllCompleted && comRev.Last_Reminder_Sent_Date__c == null) || SRV_TPA_TPARequest.reminderSecOfferingMailRequired || (comRevId != null && comRev.Id == comRevId)) && comRev.Is_Review_Secondary__c && comRev.Receiver_s_Email__c != null && comRev.Receiver_s_Email__c != '' && comRev.Is_ReviewForm_Acknowledged__c == false){
                    List<String> tempcomRevEmail = comRev.Receiver_s_Email__c.split(';');
                    tempcomRevEmail.sort();
                    List<String> comRevToSend = new List<String>();
                    String temporaryEmailIDs = '';
                    String CorrectOffName = '';
                    if(comRev.Associated_Offering_to_Review__c != null && comRev.Associated_Offering_to_Review__c.contains(':')){
                        CorrectOffName = resolvedOfferingName(comRev.Associated_Offering_to_Review__c.split(':')[0]);
                    }
                    else{
                        CorrectOffName = comRev.Associated_Offering_to_Review__c;
                    }
                    Boolean temporaryFound = false;
                    for(String comIDToSend:tempcomRevEmail){
                        TPA_Assigned_TP_Processor__c obj;
                        if(temporaryComOwnerMap.containsKey(comIDToSend.toLowerCase() + '~' + CorrectOffName)){
                            obj = temporaryComOwnerMap.get(comIDToSend.toLowerCase() + '~' + CorrectOffName);
                        }
                        else if(temporaryComOwnerMap.containsKey(comIDToSend.toLowerCase())){
                            obj = temporaryComOwnerMap.get(comIDToSend.toLowerCase());
                        }
                        if(obj != null){
                            temporaryFound = true;
                            temporaryEmailIDs += obj.Temporary_Commercial_Owner_Email__c + ';';                           
                        }
                        else if(temporaryEmailIDs != ''){
                            temporaryEmailIDs += ';';
                        }
                    }
                    String comRevEmail = string.join(tempcomRevEmail,';');
                    temporaryEmailIDs = temporaryEmailIDs.removeEnd(';');
                    if(!comToTempComMap.containsKey(comRevEmail)) {
                        comToTempComMap.put(comRevEmail, new list<String>{temporaryEmailIDs});
                    } else {
                        comToTempComMap.get(comRevEmail).add(temporaryEmailIDs);
                    }
                    List<String> useOffValues = new List<String>();
                    if(emailWithUseOff.containsKey(comRevEmail)){
                        useOffValues = emailWithUseOff.get(comRevEmail);
                        useOffValues.add(comRev.Associated_Offering_to_Review__c + comRev.Associated_Use_to_Review__c);
                    }else{
                        useOffValues.add(comRev.Associated_Offering_to_Review__c + comRev.Associated_Use_to_Review__c);
                    }
                    emailWithUseOff.put(comRevEmail,useOffValues);
                    if(!secReviewrMailWIthAdditionalID.containsKey(comRevEmail)) {
                        Set<String> addEMailIDs = new Set<String>();
                        if(comRev.TP_US_Email__c != null && comRev.TP_US_Email__c != ''){
                            addEMailIDs.add(comRev.TP_US_Email__c);
                        }
                        if(comRev.TP_Country_Email__c != null && comRev.TP_Country_Email__c != ''){
                            addEMailIDs.add(comRev.TP_Country_Email__c);
                        }
                        if(comRev.Additional_Emails__c != null && comRev.Additional_Emails__c != '' ){
                            addEMailIDs.add(comRev.Additional_Emails__c);
                        }
                        secReviewrMailWIthAdditionalID.put(comRevEmail, addEMailIDs);
                    }
                    else {
                        Set<String> addEMailIDs = secReviewrMailWIthAdditionalID.get(comRevEmail);
                        if(comRev.TP_US_Email__c != null && comRev.TP_US_Email__c != ''){
                            addEMailIDs.add(comRev.TP_US_Email__c);
                        }
                        if(comRev.TP_Country_Email__c != null && comRev.TP_Country_Email__c != ''){
                            addEMailIDs.add(comRev.TP_Country_Email__c);
                        }
                        if(comRev.Additional_Emails__c != null && comRev.Additional_Emails__c != '' ){
                            addEMailIDs.add(comRev.Additional_Emails__c);
                        }
                        secReviewrMailWIthAdditionalID.put(comRevEmail, addEMailIDs);
                    }
                    
                }
            }
        }
        
        // system.debug('secReviewrMailWIthAdditionalID: ' + secReviewrMailWIthAdditionalID);
        // system.debug('sendFinalReviewMail: ' + sendFinalReviewMail);
        // system.debug('sendSecondaryOffReviewMail: ' + sendSecondaryOffReviewMail);
        // system.debug('sendLegalReviewMail: ' + sendLegalReviewMail);
        // system.debug('reviewrMailWIthAdditionalID: ' + reviewrMailWIthAdditionalID);

        system.debug('temporaryComOwnerMap' + temporaryComOwnerMap);

        
        if(!sendFinalReviewMail && !sendSecondaryOffReviewMail && !sendLegalReviewMail){
            system.debug('in yes');
            for(TPA_Commercial_Review__c comRev : comRevsList){
            if(!comRev.Is_Review_Secondary__c){
                if(comRevId!=null && comRev.Id != comRevId){
                    continue;
                }
                else if(comRev?.Action_Needed_By__c == 'IQVIA Client AMA Administrator' && comRev?.Receiver_s_Email__c != ''){
                    isSendToAMAAdmin = true;
                }
                else if(comRev.Receiver_s_Email__c != null && comRev.Receiver_s_Email__c != '' && comRev.Is_ReviewForm_Acknowledged__c == false){
                    List<String> tempcomRevEmail = comRev.Receiver_s_Email__c.split(';');
                    tempcomRevEmail.sort();
                    String comRevEmail = string.join(tempcomRevEmail,';');
                    String CorrectOffName = '';
                    String temporaryEmailIDs = '';
                    if(comRev.Associated_Offering_to_Review__c != null && comRev.Associated_Offering_to_Review__c.contains(':')){
                        CorrectOffName = resolvedOfferingName(comRev.Associated_Offering_to_Review__c.split(':')[0]);
                    }
                    else{
                        CorrectOffName = comRev.Associated_Offering_to_Review__c;
                    }
                    Boolean temporaryFound = false;
                    for(String comIDToSend:tempcomRevEmail){

                        // if(temporaryComOwnerMap.containsKey(comIDToSend)){
                        //     for(TPA_Assigned_TP_Processor__c tempComobj: temporaryComOwnerMap.get(comIDToSend)){
                        //         system.debug('tempComobj.Primary_Offering_Names__c' + tempComobj.Primary_Offering_Names__c);
                        //         if((tempComobj.Primary_Offering_Names__c != null && tempComobj.Primary_Offering_Names__c.contains(CorrectOffName))
                        //         || (tempComobj.Secondary_Offering_Names__c != null && tempComobj.Secondary_Offering_Names__c.contains(CorrectOffName))
                        //         || (tempComobj.Primary_Offering_Names__c == null && tempComobj.Secondary_Offering_Names__c == null)){
                        //             temporaryFound = true;
                        //             temporaryEmailIDs += tempComobj.Temporary_Commercial_Owner_Email__c + ';';
                        //         }
                        //     }
                        // }
                        // else{
                        //     temporaryEmailIDs += ';';
                        // }

                        TPA_Assigned_TP_Processor__c obj;
                        if(temporaryComOwnerMap.containsKey(comIDToSend.toLowerCase() + '~' + CorrectOffName)){
                            obj = temporaryComOwnerMap.get(comIDToSend.toLowerCase() + '~' + CorrectOffName);
                        }
                        else if(temporaryComOwnerMap.containsKey(comIDToSend.toLowerCase())){
                            obj = temporaryComOwnerMap.get(comIDToSend.toLowerCase());
                        }
                        if(obj != null){
                            temporaryFound = true;
                            temporaryEmailIDs += obj.Temporary_Commercial_Owner_Email__c + ';';                           
                        }
                        else if(temporaryEmailIDs != ''){
                            temporaryEmailIDs += ';';
                        }
                    }
                    temporaryEmailIDs = temporaryEmailIDs.removeEnd(';');
                    if(!comToTempComMap.containsKey(comRevEmail)) {
                        comToTempComMap.put(comRevEmail, new list<String>{temporaryEmailIDs});
                    } else {
                        comToTempComMap.get(comRevEmail).add(temporaryEmailIDs);
                    }
                    if(!reviewrMailWIthAdditionalID.containsKey(comRevEmail)) {
                        Set<String> addEMailIDs = new Set<String>();
                        if(comRev.TP_US_Email__c != null && comRev.TP_US_Email__c != ''){
                            addEMailIDs.add(comRev.TP_US_Email__c);
                        }
                        if(comRev.TP_Country_Email__c != null && comRev.TP_Country_Email__c != ''){
                            addEMailIDs.add(comRev.TP_Country_Email__c);
                        }
                        if(comRev.Additional_Emails__c != null && comRev.Additional_Emails__c != '' ){
                            addEMailIDs.add(comRev.Additional_Emails__c);
                        }
                        reviewrMailWIthAdditionalID.put(comRevEmail, addEMailIDs);
                    }
                    else {
                        Set<String> addEMailIDs = reviewrMailWIthAdditionalID.get(comRevEmail);
                        if(comRev.TP_US_Email__c != null && comRev.TP_US_Email__c != ''){
                            addEMailIDs.add(comRev.TP_US_Email__c);
                        }
                        if(comRev.TP_Country_Email__c != null && comRev.TP_Country_Email__c != ''){
                            addEMailIDs.add(comRev.TP_Country_Email__c);
                        }
                        if(comRev.Additional_Emails__c != null && comRev.Additional_Emails__c != '' ){
                            addEMailIDs.add(comRev.Additional_Emails__c);
                        }
                        reviewrMailWIthAdditionalID.put(comRevEmail, addEMailIDs);
                    }
                    
                }
                else if((comRev.Receiver_s_Email__c == null || comRev.Receiver_s_Email__c == '')
                        && (comRev.TP_Country_Email__c != null && comRev.TP_Country_Email__c != '')
                        && (!comRev.Is_ReviewForm_Acknowledged__c || comRev.Action__c == 'Under Validation' )){
                            
                            if(!tpCountryMailWIthAdditionalID.containsKey(comRev.TP_Country_Email__c)) {
                                Set<String> addEMailIDs = new Set<String>();
                                if(comRev.TP_US_Email__c != null && comRev.TP_US_Email__c != ''){
                                    addEMailIDs.add(comRev.TP_US_Email__c);
                                }
                                tpCountryMailWIthAdditionalID.put(comRev.TP_Country_Email__c, addEMailIDs);                    
                            }
                            else {
                                Set<String> addEMailIDs = tpCountryMailWIthAdditionalID.get(comRev.TP_Country_Email__c);
                                if(comRev.TP_US_Email__c != null && comRev.TP_US_Email__c != ''){
                                    addEMailIDs.add(comRev.TP_US_Email__c);
                                }
                                tpCountryMailWIthAdditionalID.put(comRev.TP_Country_Email__c, addEMailIDs);
                            }
                            
                        }
                else if((comRev.Receiver_s_Email__c == null || comRev.Receiver_s_Email__c == '')
                        && (comRev.TP_Country_Email__c == null || comRev.TP_Country_Email__c == '')
                        && (comRev.TP_US_Email__c != null && comRev.TP_US_Email__c != '')){
                            isSendToTPUS = true;
                        }
                        }
            }
        }
               
        //system.debug('reviewrMailWIthAdditionalID: ' + reviewrMailWIthAdditionalID);
       // Map<String,String> temporaryComOwnerMap = UTL_TPA.getTemporaryComOwnerMap();

        
        if(sendSecondaryOffReviewMail){
            List<TPA_Commercial_Review__c> comRevs;
            for(TPA_Commercial_Review__c comRev : comRevsList){
                if(comRev.Manual_Review_Reason__c == 'Offering Requires Secondary Commercial Review'
                   || comRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')
                   || comRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by')){
                       continue;
                   }
                if(((SRV_TPA_TPARequest.secOfferingMailRequired && comRev.Last_Reminder_Sent_Date__c != null) || (SRV_TPA_TPARequest.secOfferingMailRequiredPrimAllCompleted && comRev.Last_Reminder_Sent_Date__c == null) || SRV_TPA_TPARequest.reminderSecOfferingMailRequired || (comRevId != null && comRev.Id == comRevId)) && comRev.Associated_Offering_to_Review__c != null && comRev.Associated_Offering_to_Review__c != '' 
                   && comRev.Associated_Use_to_Review__c != null && comRev.Associated_Use_to_Review__c != ''){
                       comRevs = new List<TPA_Commercial_Review__c>();
                       String Key = comRev.Associated_Offering_to_Review__c + comRev.Associated_Use_to_Review__c;
                       if(secOffReviewWithRelatedReviews.containsKey(Key)){
                           comRevs = secOffReviewWithRelatedReviews.get(Key);
                           comRevs.add(comRev);
                           secOffReviewWithRelatedReviews.put(Key,comRevs);
                       }
                       else{
                           comRevs.add(comRev);
                           secOffReviewWithRelatedReviews.put(Key,comRevs);
                       }
                   }
            }
        }
        
            
            
        if(sendFinalReviewMail){
            Integer secondaryReviewIndex = 0;
            for(Integer i = 0;i<comRevsList.size();i++){
                if(comRevsList[i].Action_Needed_By__c == 'Management' && comRevsList[i].Is_ReviewForm_Acknowledged__c == false){
                    secondaryReviewIndex = i;
                }
            }
            if(secondaryReviewIndex != 0){
                TPA_Commercial_Review__c tempCom = comRevsList[0];
                comRevsList[0] = comRevsList[secondaryReviewIndex];
                comRevsList[secondaryReviewIndex] = tempCom;
            }
        }

        system.debug('comToTempComMap: ' + comToTempComMap);
        
        
        if( tpaRequest.Is_Manually_Approved__c || comRevId != null || isReminderForCommercialOwner || sendFinalReviewMail || sendLegalReviewMail)
        {
            List<String> lstDateSplitted = new List<String>();
            String startDate = String.valueOf(tpaRequest.Data_Access_Start_Date__c);
            if(startDate != null) {
                lstDateSplitted = startDate.split('-');
                startDate = lstDateSplitted[1]+'/'+lstDateSplitted[2]+'/'+lstDateSplitted[0];
            }
            String endDate = String.valueOf(tpaRequest.Data_Access_End_Date__c);
            if(endDate != null) {
                lstDateSplitted = new List<String>();
                lstDateSplitted = endDate.split('-');
                endDate = lstDateSplitted[1]+'/'+lstDateSplitted[2]+'/'+lstDateSplitted[0];
            }
            String dataPeriodStartDate = String.valueOf(tpaRequest.Data_Period_Start_Date__c);
            if(dataPeriodStartDate != null) {
                lstDateSplitted = new List<String>();
                lstDateSplitted = dataPeriodStartDate.split('-');
                dataPeriodStartDate = lstDateSplitted[1]+'/'+lstDateSplitted[2]+'/'+lstDateSplitted[0];
            }
            String dataPeriodEndDate = String.valueOf(tpaRequest.Data_Period_End_Date__c);
            if(dataPeriodEndDate != null) {
                lstDateSplitted = new List<String>();
                lstDateSplitted = dataPeriodEndDate.split('-');
                dataPeriodEndDate = lstDateSplitted[1]+'/'+lstDateSplitted[2]+'/'+lstDateSplitted[0];
            }
            Integer i=1;
            String subjText;
            String bodyText;
            String tableText = '';
            String plannedLeaveText = '';
            String fontStyle = '<div style="font-size:13px !important;font-family:arial !important;margin:0px;">';
            if(dataAssetList == null) {
                dataAssetList = '';
            }
            dataAssetList = dataAssetList.replace('\n', ':');
            dataAssetList = dataAssetList.replace('<', '&lt;');
            dataAssetList = dataAssetList.replace('>', '&gt;');
            
            subjText = (isReminderForCommercialOwner ? 'Reminder: ' : '' ) + 'SubPrefix' + ' Review Required: ' + tpaRequest.Client_Address__r.Name + ' ('+ tpaRequest.Name+ ') Request to Share IQVIA Data with ' + tpaRequest.Service_Provider_Address__r.name ; //Added by C.P.Pandey under ER-1717 // Modified by Neha Bansal under ER-3446
            
            plannedLeaveText = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;color:#00b0f0"><B>Planned Leave of Absence?</B> Submit your Temporary Change in Coverage ComOwnerChangeReqURL</p>';
            bodyText = '<div style="background-color=white;text-align=left;"><p style="margin-top:0px;font-size:13px;font-family:arial;color:#5b9bd5;"><B>ACTION: YOUR REVIEW AND RESPONSE REQUIRED.</B></p>';
            
            bodyText += 'plannedLeaveText';

            bodyText += '<B>Good day, GREETING_0 Third Party Access  (' + tpaRequest.Name + ') request requires your review and response to move the Client’s request forward.</B> <br>';
            bodyText += '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;"><B>ACTION REQUESTED:</B><br>';
            
            bodytext += '<UL style="list-style-type: decimal;font-size:13px;font-family:arial;"><LI style="font-size:13px;font-family:arial;"> ' + 'Please review the summary of the TPA Request Details below for a complete view of the request.'+ '</LI>';
            bodytext += '<LI style="font-size:13px;font-family:arial;">Then, click on the following link to review each applicable “Manual Trigger” reason RESPONSE_CONTENT: formURL  </LI>';
            
            
            
            bodytext += '</table>';
            
            if(tpaRequest.Parent_Request__c != null && tpaRequest.Parent_Request__r.Is_Renewed__c && tpaRequest.Parent_Request__r.Renewed_As__c == tpaRequest.Id && tpaRequest.Is_Partially_Renewed__c != true) {
                bodytext += '<p style="font-size:13px;font-family:arial;"><B>' + tpaRequest.Name + ' Request Details: This is a renewal TPA. Parent TPA is ' + tpaRequest.Parent_Request__r.Name + '. </B>';
            }
            else {
                bodytext += '<p style="font-size:13px;font-family:arial;"><B>' + tpaRequest.Name + ' Request Details: </B>';
            }
            
            bodytext += '<br>';
            bodytext += '<br><B>Client Company: </B>'+tpaRequest.Client_Address__r.Name;
            bodytext += '<br><B>Status: </B>' + tpaRequest.Request_Status__c;
            bodytext += '<br><B>Third Party Company: </B>'+tpaRequest.Service_Provider_Address__r.Name;
            if(tpaRequest.Vendor_Website__c != null){
                bodytext += '<br><B>Vendor Website & Network Id: </B>'+tpaRequest.Vendor_Website__c;
            }
            
            bodytext += '<br><B>Client Project Name: </B>'+((tpaRequest.Client_Project_Name__c == null)? '':tpaRequest.Client_Project_Name__c);
            bodytext += '<br><B>Agreement Start and End Dates: </B>'+startDate + ', ' + endDate;
            if(dataPeriodStartDate != null && dataPeriodEndDate != null){
                bodytext += '<br><B>Data Period Start and End Dates*: </B>'+dataPeriodStartDate + ', ' + dataPeriodEndDate;
                bodyText += '<br><br><span style="font-size:8.0pt;">* Note: ' + Label.TPA_Commercial_Review_Mail_DPED_Note + '</span>';
            }

            /* if(tpaRequest.AMA_USPrescriberData__c != null && tpaRequest.AMA_USPrescriberData__c.equalsIgnoreCase(UTL_TPA.YES)) {
                bodytext += '<br><B>AMA license required: </B>'+ 'Yes';
            }
            else if(tpaRequest.AMA_USPrescriberData__c != null && tpaRequest.AMA_USPrescriberData__c.equalsIgnoreCase(UTL_TPA.NO)) {
                bodytext += '<br><B>AMA license required: </B>'+ 'No';
            } */
            if(!sendSecondaryOffReviewMail && !sendFinalReviewMail && !sendLegalReviewMail && tpaRequest.Manual_Trigger_Reasons__c != null && (tpaRequest.Manual_Trigger_Reasons__c.contains('Vendor Requires Secondary Review') || tpaRequest.Manual_Trigger_Reasons__c.contains('Offering Requires Secondary Commercial Review') || tpaRequest.Manual_Trigger_Reasons__c.contains('Offering(s) Requires Secondary Review') || tpaRequest.Manual_Trigger_Reasons__c.contains('Offering(s) Requires Secondary Review')) ){
                bodytext += '<br><br><div><B>Note: This TPA Will Also be Sent for Secondary Management Review as a Final Review.</B> PLEASE DO NOT add a Comment \'Approved if Management approves\' or the like - Please be assured the TPA will not release for signature if all reviews are not approved.</div>';
            }
            List<TPA_Text_Editor__C> offeringSpecificTextAddTerms = new List<TPA_Text_Editor__C>();
            List<TPA_Additional_Term__c> offeringSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            List<TPA_Additional_Term__c> useSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            List<TPA_Additional_Term__c> useOfferingSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            Set<TPA_Offering_Notification_Mapping__c> DynamicNotifications = new Set<TPA_Offering_Notification_Mapping__c>();   
            if(mapTpaTextAdditionalTerms != null || mapTpaAdditionalTerms != null || mapTpaDynamicNotifications != null){
                bodytext += '<br><div style="font-size:13px;font-family:arial;"><B>Additional Term(s) under TLLA Schedule A: </B></div>';
                if(mapTpaTextAdditionalTerms != null){
                    /* if(mapTpaTextAdditionalTerms.containsKey('is_Veeva_Use_CRM__c:TPA_Request__c')){
                        bodytext += '<br><br>' + fontStyle + mapTpaTextAdditionalTerms.get('is_Veeva_Use_CRM__c:TPA_Request__c').content__c + '</div>'; 
                    } */
                    if(mapTpaTextAdditionalTerms.containsKey('AI_ML_Restrictions:TPA_Request__c')){
                        bodytext += '<br>' + fontStyle + mapTpaTextAdditionalTerms.get('AI_ML_Restrictions:TPA_Request__c').content__c + '</div>'; 
                    }
                    //system.debug('mapTpaTextAdditionalTerms'+mapTpaTextAdditionalTerms.values());
                    for( String addKey : mapTpaTextAdditionalTerms.keyset()) {
                        if(addKey.split(':')[1] == 'TPA_Request__c'){
                            if(!(addKey.split(':')[0] == 'is_Veeva_Use_CRM__c' ||  addKey.split(':')[0] == 'AI_ML_Restrictions')){
                                TPA_Text_Editor__C listEditor = mapTpaTextAdditionalTerms.get(addKey);
                                bodytext += '<br>' + fontStyle + mapTpaTextAdditionalTerms.get(addKey).Content__c + '</div>';
                            }
                        }
                        if(addKey.split(':')[1] == 'IMS_Legal_Entity__c'){
                            TPA_Text_Editor__C listEditor = mapTpaTextAdditionalTerms.get(addKey);
                            if(TpaTextTerms.contains(listEditor.Page_Name__c)){
                                offeringSpecificTextAddTerms.add(mapTpaTextAdditionalTerms.get(addKey));
                            }
                        }
                    }
                }
                if(mapTpaAdditionalTerms != null){
                    for( String addKey : mapTpaAdditionalTerms.keyset()) {
                        if(addKey.split(':')[1] == 'General Ad-Hoc Term'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            bodytext += '<br>' + fontStyle + '<strong><u>' + addhocTerm.Term_Name__c + ':</u></strong>';
                            bodytext += '<br><br>'  + addhocTerm.Addtional_Term__c ;
                            if(addhocTerm.Exhibit_Attached__c && addhocTerm.Attachments != null && addhocTerm.Attachments.size() > 0){
                                String attchId = addhocTerm.Attachments[0].Id;
                                bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                            }
                            bodytext += '</div>';
                        }
                        if(addKey.split(':')[1] == 'Data Asset Specific Ad-Hoc Term'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            offeringSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                        if(addKey.split(':')[1] == 'Use Specific Ad-Hoc Terms'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            useSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                        if(addKey.split(':')[1] == 'Use/Offering Specific Ad-Hoc Terms'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            useOfferingSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                    }
                }
                if(mapTpaDynamicNotifications != null){
                    for( String addKey : mapTpaDynamicNotifications.keyset()) {
                        TPA_Offering_Notification_Mapping__c offNotify =  mapTpaDynamicNotifications.get(addKey);
                        set<String> offeringDupCheck = new set<String>();
                        for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.Associated_Offering_to_Review__c == null){
                                DynamicNotifications.add(mapTpaDynamicNotifications.get(addKey));
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null && !offeringDupCheck.contains(comRev.Associated_Offering_to_Review__c) && (comRev.Associated_Offering_to_Review__c.indexOf(offNotify.Primary_Data_Asset_Name__c) != -1 || comRev.Associated_Offering_to_Review__c.indexOf(offNotify.Secondary_Data_Asset_Name__c) != -1)){
                                offeringDupCheck.add(comRev.Associated_Offering_to_Review__c);
                                DynamicNotifications.add(mapTpaDynamicNotifications.get(addKey));
                            }
                        }
                    }
                }
            }
            if((offeringSpecificTextAddTerms != null && offeringSpecificTextAddTerms.size() > 0) || (offeringSpecificAddhocTerms != null && offeringSpecificAddhocTerms.size() > 0) || (useSpecificAddhocTerms != null && useSpecificAddhocTerms.size() > 0) || (useOfferingSpecificAddhocTerms != null && useOfferingSpecificAddhocTerms.size() > 0) || (DynamicNotifications != null && DynamicNotifications.size() > 0)){
                bodytext += '<br><div style="font-size:13px;font-family:arial;"><B>Use Specific Additional Term(s) under TLLA Schedule A: </B></div>';
                if(useSpecificAddhocTerms != null && useSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: useSpecificAddhocTerms){
                        for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.TPA_Additional_Term__c != null && comRev.TPA_Additional_Term__c == addhoc.Id){
                                bodytext += '<br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c + ':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                            else if(comRev.Associated_Use_to_Review__c != null  && comRev.Associated_Use_to_Review__c == addhoc.Use_Name__c){
                                bodytext += '<br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c + ':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                        }
                        
                    }
                }
                bodytext += '<br><div style="font-size:13px;font-family:arial;"><B>Use/Offering Specific Additional Term(s) under TLLA Schedule A: </B></div>';
                if(useOfferingSpecificAddhocTerms != null && useOfferingSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: useOfferingSpecificAddhocTerms){
                        for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.TPA_Additional_Term__c != null && comRev.TPA_Additional_Term__c == addhoc.Id){
                                bodytext += '<br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c + ':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                            else if(comRev.Associated_Use_to_Review__c != null  && comRev.Associated_Use_to_Review__c == addhoc.Use_Name__c && comRev.BU__c != null && addhoc.Country_of_Offering__c != null && comRev.BU__c == addhoc.Country_of_Offering__c && comRev.Associated_Offering_to_Review__c != null  && comRev.Associated_Offering_to_Review__c.indexOf(':') != -1 && ( (addhoc.Primary_Offering_Name__c != null && addhoc.Primary_Offering_Name__c == comRev.Associated_Offering_to_Review__c.split(':')[0] ) || ( addhoc.Secondary_Offering_Name__c != null && addhoc.Secondary_Offering_Name__c == comRev.Associated_Offering_to_Review__c.split(':')[0] ) )){
                                bodytext += '<br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c + ':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                            else if(comRev.Associated_Use_to_Review__c != null  && comRev.Associated_Use_to_Review__c == addhoc.Use_Name__c && comRev.BU__c != null && addhoc.Country_of_Offering__c != null && comRev.BU__c == addhoc.Country_of_Offering__c && comRev.Associated_Offering_to_Review__c != null && ( (addhoc.Primary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c == addhoc.Primary_Offering_Name__c) || (addhoc.Secondary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c == addhoc.Secondary_Offering_Name__c))){
                                bodytext += '<br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c +':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                        }
                        
                    }
                }
                bodytext += '<br><div style="font-size:13px;font-family:arial;"><B>Offering Specific Additional Term(s) under TLLA Schedule A: </B></div>';
                if(offeringSpecificTextAddTerms != null && offeringSpecificTextAddTerms.size() > 0){ 
                    for(TPA_Text_Editor__C txt: offeringSpecificTextAddTerms){
                        bodytext += '<br>'+ fontStyle + txt.Content__c + '</div>';
                    }
                }
                if(offeringSpecificAddhocTerms != null && offeringSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: offeringSpecificAddhocTerms){
                        for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.TPA_Additional_Term__c != null && comRev.TPA_Additional_Term__c == addhoc.Id){
                                bodytext += '<br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c + ':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null  && comRev.Associated_Offering_to_Review__c.indexOf(':') != -1 && ( (addhoc.Primary_Offering_Name__c != null && addhoc.Primary_Offering_Name__c == comRev.Associated_Offering_to_Review__c.split(':')[0] ) || ( addhoc.Secondary_Offering_Name__c != null && addhoc.Secondary_Offering_Name__c == comRev.Associated_Offering_to_Review__c.split(':')[0] ) )){
                                bodytext += '<br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c + ':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null && ( (addhoc.Primary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c == addhoc.Primary_Offering_Name__c) || (addhoc.Secondary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c == addhoc.Secondary_Offering_Name__c))){
                                bodytext += '<br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c +':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                        }
                        
                    }
                }
                String DynNotiDuplicatecheck = '';
                if(DynamicNotifications != null && DynamicNotifications.size() > 0){
                    for(TPA_Offering_Notification_Mapping__c offNotify: DynamicNotifications){
                        String offNotifyContent = offNotify.Offering_Notifications__r.Content__c;
                        system.debug('in dynamic notification : ' + offNotifyContent);
                        if(!DynNotiDuplicatecheck.contains(offNotifyContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', ''))){
                            DynNotiDuplicatecheck += offNotifyContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', '') + '|-|';
                            bodytext += '<br><br>' + fontStyle + offNotifyContent + '</div>';
                        }
                    }
                }
            }
            
            bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Requested Uses and ' + Label.TPA_IQVIA_Keyword + ' Offering(s) by Country: </B>'+ '<a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_OfferingsWithCategory&reqId='+ tpaRequest.Id+' >Click here</a></div>' +'</p>'; // Updated by Babita Dadarwl under CR-11410
            
            // system.debug('sendFinalReviewMail: ' + sendFinalReviewMail);
            
            
            //   if((sendFinalReviewMail && comRevsList.size()>0) || Test.isRunningTest()){
            //       bodytext += ' addApprovedRcrd ';
            //    }
            //system.debug('sendSecondaryOffReviewMail: ' + sendSecondaryOffReviewMail);
            
            if((sendFinalReviewMail && comRevsList.size()>0) || sendSecondaryOffReviewMail){
                bodytext += ' addReviewsTable ';
            }
            
            bodytext += '<br>Thank you very much for your time and attention towards this request.';
            bodytext += '<br><br>IQVIA Third Party Access Program<br><br>';
            
            String imageLogoId= tpaCustomSettings.IMS_health_logo_url__c.substring(tpaCustomSettings.IMS_health_logo_url__c.lastIndexOf('=') + 1);
            
            String imageurl =  TPA_Settings__c.getOrgDefaults().Base_Url_Public__c+'/servlet/servlet.ImageServer?id=' +imageLogoId+'&oid='+UserInfo.getOrganizationId()+'&contentType=image/png';
            
            bodytext += '<div style="float:left;clear:both;">';
            bodytext += '<img width="200" src="' + imageurl + '" />';
            bodytext += '</div>';
            bodytext += '<div style="float:left;clear:both;">';
            
            bodytext += '<br><br><br><a href = https://www.iqvia.com >Learn More</a> <span style="color:#00008B;">about IQVIA<span><br>';
            bodytext += '</div>';
            bodytext += '<br><br></div>' ;             
            
            List<String> toAddress = new List<String>();
            
            String URL = '';
            String ComOwnerChangeReqURL = '';
            
            
            String tempBodyText = '';
            String tempsubText = '';
            //system.debug('secReviewrMailWIthAdditionalID: ' + secReviewrMailWIthAdditionalID);
            
            if(secReviewrMailWIthAdditionalID != null && secReviewrMailWIthAdditionalID.size() > 0) {
                //system.debug('inside if: ');
                
                for(String revwerId : secReviewrMailWIthAdditionalID.keySet()){
                    Set<String> tempComIds = new Set<String>(comToTempComMap.get(revwerId));
                    if(tempComIds == null || tempComIds.size() == 0){
                        tempComIds = new Set<String>{''};
                    }
                    for(String temporaryId : tempComIds){
                        tempBodyText = ''; 
                        tempsubText = subjText.replace('SubPrefix','Secondary Commercial');
                        
                        List<String> useOffKeys = emailWithUseOff.get(revwerId);
                        String tableForReviews;
                        if(useOffKeys != null && useOffKeys.size() > 0){
                            List<TPA_Commercial_Review__c> commRevsForTable = new List<TPA_Commercial_Review__c>();
                            for(String useOff : useOffKeys){
                                if(secOffReviewWithRelatedReviews.containsKey(useOff)){
                                    commRevsForTable.addAll(secOffReviewWithRelatedReviews.get(useOff));
                                }
                            }
                            tableForReviews = UTL_TPA.createTableFromManualReviews(commRevsForTable);
                        }
                        toAddress = new List<String>();
                        //toAddress.addALL(revwerId.split(';'));
                        if(temporaryId != null && temporaryId != ''){
                            toAddress.addALL(temporaryId.split(';'));
                        }else{
                            toAddress.addALL(revwerId.split(';'));
                        }
                        // for(String revID : revwerId.split(';')){
                        //     if(temporaryComOwnerMap != null && temporaryComOwnerMap.containsKey(revID.toLowerCase())){
                        //         toAddress.add(temporaryComOwnerMap.get(revID.toLowerCase())); 
                        //     }
                        //     else{
                        //         toAddress.add(revID); 
                        //     }
                        // }
                        toAddress.addAll(secReviewrMailWIthAdditionalID.get(revwerId));
                        URL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CommercialReviewForm&id='+ tpaRequest.Id +'&viewMode=SCSubmit&CSId=' + revwerId;
                        if(temporaryId != ''){
                            URL += '&tempID=' + temporaryId;
                        }
                        ComOwnerChangeReqURL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_Com_Owner_Change_Request_Form&iCSId=' + revwerId;
    
                        tempBodyText = bodyText.replace('formURL', '<a href=' + url + '>' + ' Reply via Link'+ '</a>').replace('plannedLeaveText', plannedLeaveText).replace('RESPONSE_CONTENT','for your offering(s) and provide your decision').replace('GREETING_0', 'a');
                        tempBodyText = tempBodyText.replace('ComOwnerChangeReqURL', '<a style ="text-decoration: underline; color: #00b0f0;" href=' + ComOwnerChangeReqURL + '>' + ' Here'+ '</a>');
    
                       
    
                        if(tableForReviews != null){
                            tempBodyText = tempBodyText.replace(' addReviewsTable ', tableForReviews);
                        } else if(isSecRevTableRechedMaxLimit){                        
                            String  COURL = UTL_TPA.TPA_ClientCOM_URL + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CODescisionTable&id='+ tpaRequest.Id +'&viewMode=SCSubmit&CSId=' + revwerId + '&MailType=fyr';
                            tempBodyText = tempBodyText.replace(' addReviewsTable ', '<div style="font-size:13px;font-family:arial;"><B>For Manual Review Decision Details:</B> <a href=' +  COURL + '> Click here </a></div><br/>' );                
                        }
    
                        Workflow_Email_Record__c objWorkFlowEmail = sendBulkEmailThroughWorkfloww(toAddress, null, 'SendEmail', null, tpaRequest.Id, null, tempsubText, FALSE, tempBodyText, TRUE, TRUE, tpaRequest);
                        if(objWorkFlowEmail != null){
                            lstEmailWorkflowToSend.add(objWorkFlowEmail);
                        }
                    }
                    
                } 
            }
            
            //system.debug('reviewrMailWIthAdditionalID: ' + reviewrMailWIthAdditionalID);

            if(reviewrMailWIthAdditionalID != null && reviewrMailWIthAdditionalID.size() > 0 && !sendLegalReviewMail) {
                for(String revwerId : reviewrMailWIthAdditionalID.keySet()){
                    Set<String> tempComIds = new Set<String>(comToTempComMap.get(revwerId));
                    if(tempComIds == null || tempComIds.size() == 0){
                        tempComIds = new Set<String>{''};
                    }
                    for(String temporaryId : tempComIds){
                        tempBodyText = ''; 
                    
                    tempsubText = subjText.replace('SubPrefix','Commercial');
                    List<String> useOffKeys = emailWithUseOff.get(revwerId);
                    String tableForReviews;
                    
                    toAddress = new List<String>();
                    //toAddress.addALL(revwerId.split(';'));
                    if(temporaryId != null && temporaryId != ''){
                        toAddress.addALL(temporaryId.split(';'));
                    }else{
                        toAddress.addALL(revwerId.split(';'));
                    }
                    // for(String revID : revwerId.split(';')){
                    //     if(temporaryComOwnerMap != null && temporaryComOwnerMap.containsKey(revID.toLowerCase())){
                    //         toAddress.add(temporaryComOwnerMap.get(revID.toLowerCase())); 
                    //     }
                    //     else{
                    //         toAddress.add(revID); 
                    //     }
                    // }
                    toAddress.addAll(reviewrMailWIthAdditionalID.get(revwerId));
                    if(sendSecondaryOffReviewMail){
                        URL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CommercialReviewForm&id='+ tpaRequest.Id +'&viewMode=SCSubmit&CSId=' + revwerId;
                        if(temporaryId != ''){
                            URL += '&tempID=' + temporaryId;
                        }
                    }
                    else{
                        URL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CommercialReviewForm&id='+ tpaRequest.Id +'&viewMode=CSubmit&CSId=' + revwerId;
                        if(temporaryId != ''){
                            URL += '&tempID=' + temporaryId;
                        }
                    }
                    ComOwnerChangeReqURL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_Com_Owner_Change_Request_Form&CSId=' + revwerId;
                    
                    tempBodyText = bodyText.replace('formURL', '<a href=' + url + '>' + ' Reply via Link'+ '</a>');
                    tempBodyText = tempBodyText.replace(' addReviewsTable ','').replace('plannedLeaveText', plannedLeaveText);
                    tempBodyText = tempBodyText.replace('ComOwnerChangeReqURL', '<a style ="text-decoration: underline; color: #00b0f0;" href=' + ComOwnerChangeReqURL + '>' + ' Here'+ '</a>').replace('RESPONSE_CONTENT','for your offering(s) and provide your decision').replace('GREETING_0', 'a');
                    
                    Workflow_Email_Record__c objWorkFlowEmail = sendBulkEmailThroughWorkfloww(toAddress, null, 'SendEmail', null, tpaRequest.Id, null, tempsubText, FALSE, tempBodyText, TRUE, TRUE, tpaRequest); 
                    if(objWorkFlowEmail != null){
                        lstEmailWorkflowToSend.add(objWorkFlowEmail);
                    }
                    }
                    
                } 
            }

            system.debug('URL' + URL) ;
            
            if(tpCountryMailWIthAdditionalID != null && tpCountryMailWIthAdditionalID.size() > 0) {
                for(String tpCountryId : tpCountryMailWIthAdditionalID.keySet()){
                    tempBodyText = ''; tempsubText = '';
                    if(tpCountryId != null){
                        String tpProcessorText = (tpaRequest.TPA_Processor_Contact__r != null && tpaRequest.TPA_Processor_Contact__r.Name != null ? tpaRequest.TPA_Processor_Contact__r.Name : '');
                        tpProcessorText = (tpCountryId == UTL_TPA.TPNordicsEmailID ? 'TP Nordics' : tpProcessorText);
                        tempsubText = subjText.replace('SubPrefix', tpProcessorText);
                        toAddress = new List<String>();
                        toAddress.add(tpCountryId);
                        //ComOwnerChangeReqURL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_Com_Owner_Change_Request_Form&CSId=' + tpCountryId;
                        // if(temporaryComOwnerMap != null && temporaryComOwnerMap.containsKey(tpCountryId.toLowerCase())){
                        //     toAddress.add(temporaryComOwnerMap.get(tpCountryId.toLowerCase())); 
                        // }
                        // else{
                        //     toAddress.add(tpCountryId); 
                        // }
                        toAddress.addAll(tpCountryMailWIthAdditionalID.get(tpCountryId));
                        URL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CommercialReviewForm&id='+ tpaRequest.Id +'&viewMode=TPSubmit&TPCountryId=' + tpCountryId;
                        tempBodyText = bodyText.replace('formURL', '<a href=' + url + '>' + ' Reply via Link'+ '</a>');
                        tempBodyText = tempBodyText.replace(' addReviewsTable ','');
                        tempBodyText = tempBodyText.replace('plannedLeaveText', '').replace('RESPONSE_CONTENT','for your offering(s) and provide your decision').replace('GREETING_0', 'a');
                        Workflow_Email_Record__c objWorkFlowEmail = sendBulkEmailThroughWorkfloww(toAddress, null, 'SendEmail', null, tpaRequest.Id, null, tempsubText, FALSE, tempBodyText, TRUE, TRUE, tpaRequest); 
                        if(objWorkFlowEmail != null){
                            lstEmailWorkflowToSend.add(objWorkFlowEmail);
                        }
                    } 
                }
            }
            //System.debug('isSendToTPUS==>'+isSendToTPUS);
            if(isSendToTPUS){
                tempBodyText = ''; tempsubText = '';
                tempsubText = subjText.replace('SubPrefix', 'US TP');
                toAddress = new List<String>();
                toAddress.add(UTL_TPA.TPUSEMailAddress);
                // if(temporaryComOwnerMap != null && temporaryComOwnerMap.containsKey(UTL_TPA.TPUSEMailAddress.toLowerCase())){
                //     toAddress.add(temporaryComOwnerMap.get(UTL_TPA.TPUSEMailAddress.toLowerCase())); 
                // }
                // else{
                //     toAddress.add(UTL_TPA.TPUSEMailAddress); 
                // }
                //ComOwnerChangeReqURL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_Com_Owner_Change_Request_Form&iCSId=' + UTL_TPA.TPUSEMailAddress;
                //toAddress.addAll(tpCountryMailWIthAdditionalID.get(tpCountryId));
                URL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CommercialReviewForm&id='+ tpaRequest.Id +'&viewMode=TPUS&TPUSId=' + UTL_TPA.TPUSEMailAddress;
                tempBodyText = bodyText.replace('formURL', '<a href=' + url + '>' + ' Reply via Link'+ '</a>');
                tempBodyText = tempBodyText.replace(' addReviewsTable ','');
                tempBodyText = tempBodyText.replace('plannedLeaveText', '').replace('RESPONSE_CONTENT','for your offering(s) and provide your decision').replace('GREETING_0', 'a');
                Workflow_Email_Record__c objWorkFlowEmail = sendBulkEmailThroughWorkfloww(toAddress, null, 'SendEmail', null, tpaRequest.Id, null, tempsubText, FALSE, tempBodyText, TRUE, TRUE, tpaRequest);
                if(objWorkFlowEmail != null){
                    lstEmailWorkflowToSend.add(objWorkFlowEmail);
                }
            }
            if(isSendToAMAAdmin){
                System.debug(isSendToAMAAdmin);
                tempBodyText = ''; tempsubText = '';
                tempsubText = subjText.replace('SubPrefix', 'Client AMA Administrator');
                toAddress = new List<String>();
                toAddress.add(UTL_TPA.IQVIAClientAMAAdmin);
                URL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CommercialReviewForm&id='+ tpaRequest.Id +'&viewMode=AMAAdmin&AMAAdminId=' + UTL_TPA.IQVIAClientAMAAdmin;
                tempBodyText = bodyText.replace('formURL', '<a href=' + url + '>' + ' Reply via Link'+ '</a>');
                tempBodyText = tempBodyText.replace(' addReviewsTable ','');
                tempBodyText = tempBodyText.replace('plannedLeaveText', '').replace('RESPONSE_CONTENT','and provide your response').replace('GREETING_0', 'IQVIA Client AMA Administrator. A');
                Workflow_Email_Record__c objWorkFlowEmail = sendBulkEmailThroughWorkfloww(toAddress, null, 'SendEmail', null, tpaRequest.Id, null, tempsubText, FALSE, tempBodyText, TRUE, TRUE, tpaRequest);
                if(objWorkFlowEmail != null){
                    lstEmailWorkflowToSend.add(objWorkFlowEmail);
                }
            }
            
            if(sendFinalReviewMail && comRevsList.size() > 0){
                String approvedRcrd = '';
                boolean maxLimitForFinalReviewEmail = false;
                tempBodyText += '<br><br><B> Commercial Review Records: </B></p>';
                approvedRcrd += '<br><table style="border-collapse: collapse;font-size:13px;font-family:arial;border:2px solid #0CB6F3;"><tr><th colSpan="8" style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Commercial Review Records Detail</th></tr>';
                approvedRcrd += '<tr><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Manual Review Reason</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Associated Offering(s) to Review</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Associated Offering(s) Use(s) Requested</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Commercial Owner Name</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Date of Review</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Commercial Owner Decision</th></tr>';
                
                for(TPA_Commercial_Review__c comRev: comRevsList ){
                    if(comRev.Action__c != null && (comRev.Action__c == 'Approved for this specific TPA request'
                    || comRev.Action__c == 'Approved for this specific TPA. The Vendor and specified Use(s) and IQVIA Offerings specific combination can be auto-approved moving forward for future requests'
                    || comRev.Action__c == System.Label.TPA_Approved_Future_Approved_AdHoc)){                        String reviewDate = '';
                        if(comRev.Date_of_Action_Response__c != null){
                            reviewDate = comRev.Date_of_Action_Response__c.format();
                        }
                        approvedRcrd += '<tr><td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + (comRev.Manual_Review_Reason__c != null ? comRev.Manual_Review_Reason__c : '') + '</td>';
                        approvedRcrd += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + (comRev.Associated_Offering_to_Review__c != null ? comRev.Associated_Offering_to_Review__c : '') + '</td>';
                        approvedRcrd += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + (comRev.Associated_Use_to_Review__c != null ? comRev.Associated_Use_to_Review__c : '') + '</td>';
                        approvedRcrd += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + (comRev.Commercial_Owner_Name__c != null ? comRev.Commercial_Owner_Name__c : '') + '</td>';
                        approvedRcrd += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + reviewDate  + '</td>';
                        approvedRcrd += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + (comRev.Action__c != null ? comRev.Action__c : '')+ '</td></tr>';
                    }
                    if(approvedRcrd.length() > 200000){
                        maxLimitForFinalReviewEmail = true;
                        break;
                    }
                }
                approvedRcrd += '</table><br>';

                if(maxLimitForFinalReviewEmail){
                    approvedRcrd = null;
                }

                //system.debug('approvedRcrd: ' + approvedRcrd);

                
                
                tempBodyText = ''; tempsubText = '';
                tempsubText = subjText.replace('SubPrefix', 'Management');
                toAddress = new List<String>();
                if(comRevsList[0].Receiver_s_Email__c != null){
                    //toAddress.add(comRevsList[0].Receiver_s_Email__c);
                        if(temporaryComOwnerMap != null && temporaryComOwnerMap.containsKey(comRevsList[0].Receiver_s_Email__c.toLowerCase()) && temporaryComOwnerMap.get(comRevsList[0].Receiver_s_Email__c.toLowerCase()).Temporary_Commercial_Owner_Email__c != null ){
                            toAddress.add(temporaryComOwnerMap.get(comRevsList[0].Receiver_s_Email__c.toLowerCase()).Temporary_Commercial_Owner_Email__c); 
                        }
                        else{
                            toAddress.add(comRevsList[0].Receiver_s_Email__c); 
                        }
                } 
                toAddress.add(UTL_TPA.TPUSEMailAddress);
                if(tpaRequest.TP_Processor_Email__c != null && UTL_TPA.TPUSEMailAddress != tpaRequest.TP_Processor_Email__c){
                    toAddress.add(tpaRequest.TP_Processor_Email__c);
                }
                ComOwnerChangeReqURL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_Com_Owner_Change_Request_Form&CSId=' + toAddress[0];
                URL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CommercialReviewForm&id='+ tpaRequest.Id +'&viewMode=MGMT&MGMTId=' + toAddress[0];
                tempBodyText = bodyText.replace('formURL', '<a href=' + url + '>' + ' Reply via Link'+ '</a>').replace('plannedLeaveText', plannedLeaveText).replace('RESPONSE_CONTENT','for your offering(s) and provide your decision').replace('GREETING_0', 'a');
                tempBodyText = tempBodyText.replace('ComOwnerChangeReqURL', '<a style ="text-decoration: underline; color: #00b0f0;" href=' + ComOwnerChangeReqURL + '>' + ' Here'+ '</a>');
               /* if(approvedRcrd != null){
                    if(bodyText.replace('addReviewsTable', tableText).length() > 200000){
                        String  COURL = UTL_TPA.TPA_ClientCOM_URL + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CODescisionTable&id='+ tpaRequest.Id +'&viewMode=MGMT&MGMTId=' + toAddress[0] + '&MailType=rr';
                        bodyText = bodyText.replace('addReviewsTable', '<a href=' +  COURL + '> Click here </a>');
                    }else{
                        tempBodyText = bodyText.replace('addReviewsTable', tableText);
                    }
                }*/
                if(approvedRcrd != null){
                    tempBodyText = tempBodyText.replace(' addReviewsTable ',approvedRcrd);
                }else if(maxLimitForFinalReviewEmail){                        
                    String  COURL = UTL_TPA.TPA_ClientCOM_URL + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CODescisionTable&id='+ tpaRequest.Id +'&viewMode=MGMT&MGMTId=' + toAddress[0] + '&MailType=rr';
                    tempBodyText = tempBodyText.replace(' addReviewsTable ', '<div style="font-size:13px;font-family:arial;"><B>For Manual Review Decision Details:</B> <a href=' +  COURL + '> Click here </a></div><br/>');                    
                }

                Workflow_Email_Record__c objWorkFlowEmail = sendBulkEmailThroughWorkfloww(toAddress, null, 'SendEmail', null, tpaRequest.Id, null, tempsubText, FALSE, tempBodyText, TRUE, TRUE, tpaRequest);
                if(objWorkFlowEmail != null){
                    lstEmailWorkflowToSend.add(objWorkFlowEmail);
                }
            }
            if(sendLegalReviewMail && comRevsList.size() > 0){
                tempBodyText = ''; tempsubText = '';
                tempsubText = subjText.replace('SubPrefix', 'Legal');
                toAddress = new List<String>();
                String reviewEmail = '';
                String temporaryId = '';
                if(TPA_Settings__c.getOrgDefaults() != null){
                    List<String> tempToAddress = new List<String>();
                    if(TPA_Settings__c.getOrgDefaults().Legal_Review_Email__c != null && TPA_Settings__c.getOrgDefaults().Legal_Review_Email__c != ''){
                        tempToAddress = TPA_Settings__c.getOrgDefaults().Legal_Review_Email__c.toLowerCase().split(';');
                        reviewEmail = TPA_Settings__c.getOrgDefaults().Legal_Review_Email__c;
                    }
                    if(tempToAddress != null && tempToAddress.size() > 0){
                        for(String email: tempToAddress){
                            if(temporaryComOwnerMap != null && temporaryComOwnerMap.containsKey(email) && temporaryComOwnerMap.get(email).Temporary_Commercial_Owner_Email__c != null ){
                                toAddress.add(temporaryComOwnerMap.get(email).Temporary_Commercial_Owner_Email__c);
                                temporaryId = temporaryId + temporaryComOwnerMap.get(email).Temporary_Commercial_Owner_Email__c + ';'; 
                            }
                            else {
                                toAddress.add(email);
                            }
                        }
                    }
                    // if(temporaryComOwnerMap != null && temporaryComOwnerMap.containsKey(TPA_Settings__c.getOrgDefaults().Legal_Review_Email__c.toLowerCase())){
                    //     toAddress.add(temporaryComOwnerMap.get(TPA_Settings__c.getOrgDefaults().Legal_Review_Email__c.toLowerCase())); 
                    // }
                    // else{
                    //     toAddress.add(TPA_Settings__c.getOrgDefaults().Legal_Review_Email__c);
                    // }
                } 
                toAddress.add(UTL_TPA.TPUSEMailAddress);
                if(tpaRequest.TP_Processor_Email__c != null && UTL_TPA.TPUSEMailAddress != tpaRequest.TP_Processor_Email__c){
                    toAddress.add(tpaRequest.TP_Processor_Email__c);
                }
                URL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CommercialReviewForm&id='+ tpaRequest.Id +'&viewMode=LGL&LGLId=' + reviewEmail;
                if(temporaryId != ''){
                    URL += '&tempID=' + temporaryId.subString(0, temporaryId.length()-1);
                }
                ComOwnerChangeReqURL = tpaCustomSettings.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_Com_Owner_Change_Request_Form&CSId=' + reviewEmail;
                tempBodyText = bodyText.replace('formURL', '<a href=' + url + '>' + ' Reply via Link'+ '</a>');
                tempBodyText = tempBodyText.replace(' addReviewsTable ','').replace('plannedLeaveText', plannedLeaveText);
                tempBodyText = tempBodyText.replace('ComOwnerChangeReqURL', '<a style ="text-decoration: underline; color: #00b0f0;" href=' + ComOwnerChangeReqURL + '>' + ' Here'+ '</a>').replace('RESPONSE_CONTENT','for your offering(s) and provide your decision').replace('GREETING_0', 'a');
                Workflow_Email_Record__c objWorkFlowEmail = sendBulkEmailThroughWorkfloww(toAddress, null, 'SendEmail', null, tpaRequest.Id, null, tempsubText, FALSE, tempBodyText, TRUE, TRUE, tpaRequest);
                if(objWorkFlowEmail != null){
                    lstEmailWorkflowToSend.add(objWorkFlowEmail);
                }
            }
            try {
                if(lstEmailWorkflowToSend != null && lstEmailWorkflowToSend.size() > 0){
                    insert lstEmailWorkflowToSend;
                }
                System.debug('lstEmailWorkflowToSend inserted successfully');
            } catch(Exception e) {
                System.debug('lstEmailWorkflowToSend Following Exception Occue In IF---------> ' + e);
            }
        }
    }

    


    

    public static Boolean isReqReadyForSignatures(TPA_Request__c tpaReq) {
        if(tpaReq.Is_VSN_Acknowlege_By_Client__c || tpaReq.isClientOnComplianceHold__c || tpaReq.isVendorOnComplianceHold__c || tpaReq.Is_Potential_Vendor_Case__c || tpaReq.isLegalEntityPresent__c || !String.isBlank(tpaReq.Pending_Acknowledgements__c)){
            return false;
        }
        return true;
    }

    public static void sendTPAComplianceHoldMail( String emailaddresses, List<String> tpProcessorEmailId) {
        String clientCompanyName;
		String vendorCompanyName;
        String clientOnComplianceHoldReason;
		String vendorOnComplianceHoldReason;
        Boolean isClientOnComplianceHold = false;
        Boolean isVendorOnComplianceHold = false;

        Map<String,Account_Compliance__c> accCompRecords = UTL_TPA.getTPAClientVendorComplianceDetails(tpaRequest.Client_Address__c, tpaRequest.Service_Provider_Address__c); 

        if(accCompRecords != null) {
            Account_Compliance__c accClientComp = accCompRecords.get('CC-'+tpaRequest.Client_Address__c);
            if(accClientComp != null && accClientComp.Client_TPA_Compliance_Hold__c){
                isClientOnComplianceHold = true;
                clientCompanyName = tpaRequest.Client_Address__r.Name;
                clientOnComplianceHoldReason = accClientComp.Client_TPA_Compliance_Hold_Reason__c;
            }
            Account_Compliance__c accVendorComp = accCompRecords.get('VC-'+tpaRequest.Service_Provider_Address__c);
            if(accVendorComp != null && accVendorComp.Vendor_TPA_Compliance_Hold__c){
                isVendorOnComplianceHold = true;
                vendorCompanyName = tpaRequest.Service_Provider_Address__r.Name;
                vendorOnComplianceHoldReason = accVendorComp.Vendor_TPA_Compliance_Hold_Reason__c;
            }
        }
		
        system.debug('in sendTPAComplianceHoldMail: tpaRequest.Is_Manually_Approved__c: '+tpaRequest.Is_Manually_Approved__c );
        if( tpaRequest.Is_Manually_Approved__c && (tpaRequest.isClientOnComplianceHold__c == true || tpaRequest.isVendorOnComplianceHold__c == true)) {//TODO: Move this condition while calling 
            List<String> lstDateSplitted = new List<String>();
            String startDate = String.valueOf(tpaRequest.Data_Access_Start_Date__c);
            if(startDate != null) {
                lstDateSplitted = startDate.split('-');
                startDate = lstDateSplitted[1]+'/'+lstDateSplitted[2]+'/'+lstDateSplitted[0];
            }
            String endDate = String.valueOf(tpaRequest.Data_Access_End_Date__c);
            if(endDate != null) {
                lstDateSplitted = new List<String>();
                 lstDateSplitted = endDate.split('-');
                endDate = lstDateSplitted[1]+'/'+lstDateSplitted[2]+'/'+lstDateSplitted[0];
            }
            Integer i=1;
            //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String subjText;
            String bodyText;
            // if(dataAssetList == null) {
            //     dataAssetList = '';
            // }
            // dataAssetList = dataAssetList.replace('\n', ':');
            // dataAssetList = dataAssetList.replace('<', '&lt;');
            // dataAssetList = dataAssetList.replace('>', '&gt;');
            
            /*if(isClientOnComplianceHold && isVendorOnComplianceHold){
                subjText = 'TPA Compliance Hold: ('+ tpaRequest.Name+ ') Requires TPA Compliance Review related '+tpaRequest.Client_Address__r.Name +' and ' +tpaRequest.Service_Provider_Address__r.Name ;
                bodyText = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">' + tpaRequest.Name + ' has been received for '+tpaRequest.Client_Address__r.Name +' and ' +tpaRequest.Service_Provider_Address__r.Name + '.  This company is on TPA Compliance Hold and requires TPA Compliance Review before continuing through the review process. <br><br></p>';
            }*/
            if(isClientOnComplianceHold){
                subjText = 'TPA Compliance Hold: ('+ tpaRequest.Name+ ') Requires TPA Compliance Review related '+tpaRequest.Client_Address__r.Name  ;
                bodyText = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">' + tpaRequest.Name + ' has been received for '+tpaRequest.Client_Address__r.Name +'.  This company is on TPA Compliance Hold and requires TPA Compliance Review before continuing through the review process. <br><br></p>';
            }
            else if(isVendorOnComplianceHold){
                subjText = 'TPA Compliance Hold: ('+ tpaRequest.Name+ ') Requires TPA Compliance Review related '+tpaRequest.Service_Provider_Address__r.Name  ;
                bodyText = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">' + tpaRequest.Name + ' has been received for '+tpaRequest.Service_Provider_Address__r.Name +'.  This company is on TPA Compliance Hold and requires TPA Compliance Review before continuing through the review process. <br><br></p>';
            }
            bodytext += '<p style="font-size:13px;font-family:arial;"><B>TPA Details: </B>';
            if(tpaRequest.Parent_Request__c != null && tpaRequest.Parent_Request__r.Is_Renewed__c && tpaRequest.Parent_Request__r.Renewed_As__c == tpaRequest.Id) {
                bodytext += '<br><br><B>' + tpaRequest.Name + ' Request Details: This is a renewal TPA. Parent TPA is ' + tpaRequest.Parent_Request__r.Name + '. </B>';
            }
            else {
                bodytext += '<br><br><B>' + tpaRequest.Name + ' Request Details: </B>';
            }
            bodytext += '<br>';
            bodytext += '<br><B>Client Company: </B>'+tpaRequest.Client_Address__r.Name;
            bodytext += '<br><B>Status: </B>' + tpaRequest.Request_Status__c;
            bodytext += '<br><B>Third Party Company: </B>'+tpaRequest.Service_Provider_Address__r.Name;
            if(tpaRequest.Vendor_Website__c != null){
              bodytext += '<br><B>Vendor Website & Network Id: </B>'+tpaRequest.Vendor_Website__c;
            }
            
            bodytext += '<br><B>Client Project Name: </B>'+((tpaRequest.Client_Project_Name__c == null)? '':tpaRequest.Client_Project_Name__c);
            bodytext += '<br><B>Project start and end date: </B>'+startDate + ', ' + endDate;
            
            if(tpaRequest.AMA_USPrescriberData__c != null && tpaRequest.AMA_USPrescriberData__c.equalsIgnoreCase(UTL_TPA.YES) && SRV_TPA_AMAAgreementDetail.amaAgreementDetails != null) { // TODO: Check if this is required 
                bodytext += '<br><B>AMA Project Use(s): </B>'+ ((SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_Services_Provided__c  == null || SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_Services_Provided__c  == '') ? '' : SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_Services_Provided__c.replace(';', ', '));
                bodytext += '<br><B>AMA Variables Requested: </B>'+ ((SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_TypeOfPrescriberLevelData__c   == null || SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_TypeOfPrescriberLevelData__c   == '') ? '' : SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_TypeOfPrescriberLevelData__c.replace(';', ', '));

            }
            bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Requested Uses and ' + Label.TPA_IQVIA_Keyword + ' Offering(s) by Country: </B>'+ '<a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_OfferingsWithCategory&reqId='+ tpaRequest.Id+' >Click here</a></div>' +'</p>'; 
            //Integer nooftablesDisplayed = 0;
            

            /*if(isClientOnComplianceHold && isVendorOnComplianceHold){
                bodytext += '<p style="font-size:14px;font-family:arial;"><UL><LI style="font-size:13px;font-family:arial;">We are presently holding this TPA for your advisement due to: '+clientOnComplianceHoldReason + ' and ' +vendorOnComplianceHoldReason + '.</LI></UL>';
            }*/
            if(isClientOnComplianceHold){
                bodytext += '<p style="font-size:13px;font-family:arial;"><UL><LI style="font-size:13px;font-family:arial;">We are presently holding this TPA for your advisement due to: '+clientOnComplianceHoldReason + '.</LI></UL>';
            }
            else if(isVendorOnComplianceHold){
                bodytext += '<p style="font-size:13px;font-family:arial;"><UL><LI style="font-size:13px;font-family:arial;">We are presently holding this TPA for your advisement due to: ' +vendorOnComplianceHoldReason + '.</LI></UL>';
            }
            bodytext += '<br><div style = "font-size : 13px; font-family: arial;"><B>Please advise which of the following actions should be followed:</B></div>';
            if( tpaRequest != null ) {
                bodytext +=  '<br><br><div style = "font-size : 13px; font-family: arial;"><a href= '+ TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_ClientVendorHoldResponse&id=' + tpaRequest.Id+'>' + TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_ClientVendorHoldResponse&id=' + tpaRequest.Id+'</a></div>';
            }
            bodytext += '<br><br></p></div>';
            
            List<String> ccAddressesList = new List<String>();
            if(emailaddresses != NULL && emailaddresses.trim() != '') {
                ccAddressesList = emailaddresses.split(',', 0);
            }
            
            if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
                ccAddressesList.add(UTL_TPA.sharedEmailAddress);
            }
            
            /*if(commercialOwnerEmailIdList != null && commercialOwnerEmailIdList.size() > 0) {
                ccAddressesList.addAll(commercialOwnerEmailIdList);
            }*/

            List<String> toAddresses =  UTL_TPA.TpaEmailAddress.split(';');
            if(tpProcessorEmailId != null && !tpProcessorEmailId.isEmpty()){
                System.debug('i am here');
                toAddresses = new List<String>();
                toAddresses.addAll(tpProcessorEmailId);
            }
            System.debug('i am here');

            try
            {
                if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest())  //Added by Babita under issue-06997
                {
                    System.debug('Email send: ');
                    //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    /*addTPProcessorInitials = true;
                    if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        assignedTPProcessorName = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/
                    //subjText = setEmailInitials(tpaRequest.Assigned_TP_Processor__c, subjText);
                    sendEmailThroughWorkflow(toAddresses, ccAddressesList, 'SendEmail', null, tpaRequest.Id, null, subjText, FALSE, bodyText, TRUE, TRUE, tpaRequest);
                    //addTPProcessorInitials = false;
                }
            }
            catch(Exception e)
            {
                System.debug('Email Failed: ' + e.getMessage());
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_TPARequest:::sendTPAComplianceHoldMail', tpaRequest != null ? tpaRequest.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
            }
    }
    public static void sendDraftMail(TPA_Request__c request){
        
        request = [select id,Client_Address__r.TPAOtherEmailIds__c, Client_TPA_Representative_Email__c, ClientContact__r.Email, Owner.Type, Owner.Email, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, TP_Processor_Email__c, Client_Request_Submission__c from TPA_Request__c where id = :request.Id Limit 1];
        
        String subjText = '';
        String emailBody = '';
        List<String> toAddressesList = new List<String>();
        toAddressesList.add(request.ClientContact__r.Email);

        if(request.Client_TPA_Representative_Email__c != null && request.Client_TPA_Representative_Email__c != ''){
            toAddressesList.add(request.Client_TPA_Representative_Email__c);
        }

        if(request.Owner.Type != null && request.Owner.Type == 'Queue' && request.Owner.Email != null){
            toAddressesList.add(request.Owner.Email);
        }
        
        List<String> ccAddressesList = new List<String>();
        ccAddressesList.add(request.TP_Processor_Email__c);
        
        ccAddressesList = UTL_TPA_Multilingual.ccList(request.Client_Address__r.TPAOtherEmailIds__c, ccAddressesList);

        List<TPA_Contact__c> addContactsList = getContactsForRequest(request.id);
        
        for(TPA_Contact__c addContacts : addContactsList){
            ccAddressesList.add(addContacts.Email__c);
        }
        
        string language = 'English';
        String emailType = 'In Client Draft Notification';
		string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get(emailType + Language).Translated_Template_Id__c;

        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();

        if(templateId != null) {        
            try {
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, request.Id);
            } catch(Exception exp) {
                System.debug('Failed to Load In Client Draft Mail ' + exp.getMessage());
            }
            emailBody = emailNotToSend.getHTMLBody();
            subjText = emailNotToSend.getSubject();
            
            Date submissionDate = request.Client_Request_Submission__c.date();
            submissionDate = submissionDate.addDays(45);
            emailBody = emailBody.replace('DRAFT_CLOSE', submissionDate.format());
        }
        try{
            /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
            if(request.TPA_Assigned_TP_Processor__r.Is_Active__c) {
               SRV_TPA_TPARequest.assignedTPProcessorName = request.TPA_Assigned_TP_Processor__r.Initials__c; 
            }*/
            SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddressesList, ccAddressesList, 'inClientDraftNotification', null, request.Id, null, subjText, FALSE, emailBody, TRUE, TRUE, request);
        	//SRV_TPA_TPARequest.addTPProcessorInitials = false;
        }catch(exception e){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_TPARequest.sendDraftMail:::Failed to Send In Client Draft Mail', request.id != null ? request.id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('Failed to Send In Client Draft Mail ' + e.getMessage());
        }
    }
    public static void sendClosedRequestMail(TPA_Request__c request, Boolean isClosedByClient) {
        //TPA_Settings__c tpaSetting = TPA_Settings__c.getInstance();
        
        List<String> toAddressesList = new List<String>();
        toAddressesList.add(request.ClientContact__r.Email);

        if(request.Client_TPA_Representative_Email__c != null && request.Client_TPA_Representative_Email__c != ''){
            toAddressesList.add(request.Client_TPA_Representative_Email__c);
        }

        if(request.Owner.Type != null && request.Owner.Type == 'Queue' && request.Owner.Email != null){
            toAddressesList.add(request.Owner.Email);
        }
        
        List<String> ccAddressesList = new List<String>();
        ccAddressesList.add(request.TP_Processor_Email__c);
        
        ccAddressesList = UTL_TPA_Multilingual.ccList(request.Client_Address__r.TPAOtherEmailIds__c, ccAddressesList);

        List<TPA_Contact__c> addContactsList = getContactsForRequest(request.id);
        
        for(TPA_Contact__c addContacts : addContactsList){
            ccAddressesList.add(addContacts.Email__c);
        }
        
        String emailType = isClosedByClient ? 'In Draft Request Closed by Client':'In Draft Request Closed Template ID';
        string clientLanguage =  'English';
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get(emailType + clientLanguage).Translated_Template_Id__c;
        
        try {
            /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
            if(request.TPA_Assigned_TP_Processor__r.Is_Active__c) {
               SRV_TPA_TPARequest.assignedTPProcessorName = request.TPA_Assigned_TP_Processor__r.Initials__c; 
            }*/
            SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddressesList, ccAddressesList, emailType, templateId, request.id, null, null, false, null, TRUE, TRUE, request);
            //SRV_TPA_TPARequest.addTPProcessorInitials = false;
            
            System.debug('Success: In Draft Request Closed Notification Sent to client.'); 
        }
        catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_TPARequest.sendClosedRequestMail:::Draft Request Closed Notification Failed', request.id != null ? request.id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('Failed: In Draft Request Closed Notification NOT sent to client' + e.getMessage());
        }
    }

    public static void sendDataDestructionAckOutstandingMail( TPA_Request__c request){
        String subjText;
        String bodyText;
        String bodyTextEn;
        String preferredLanguage;
        String templateID;
        String emailBody;
        String priorTPAs;
        String priorVendorcontactname;
        String priorVendorcontactemail;
        String priorDDNAckLink;
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();

        if(DDNAckPendingRecords != null && DDNAckPendingRecords.size() > 0) {
            preferredLanguage = request.vendor_language__c != null ? request.vendor_language__c : 'English';
            Set<string> langSet = new Set<string>();
            String preferredLangField = UTL_TPA_Multilingual.supportedLanguageFieldMap.get(preferredLanguage);
            if(UTL_TPA_Multilingual.supportedLanguageFieldMap != null){
                langSet.add(UTL_TPA_Multilingual.supportedLanguageFieldMap.get('English'));
                langSet.add(UTL_TPA_Multilingual.supportedLanguageFieldMap.get('Japanese'));
            }

            Map<String, List<TPA_Language_Cross_Walk__c>> langCrossWalkMap = UTL_TPA_Multilingual.getTranslatedValueMap(langSet);
            if(langCrossWalkMap != null) {
                priorTPAs = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorTPAs')[0].get(preferredLangField);
                priorVendorcontactname = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorVendorcontactname')[0].get(preferredLangField);
                priorVendorcontactemail = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorVendorcontactemail')[0].get(preferredLangField);
                priorDDNAckLink = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorDDNAckLink')[0].get(preferredLangField);
            }
            
			templateID = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email TPA Request on Hold'+preferredLanguage).Translated_Template_Id__c;
            system.debug('templateID1'+templateID);
            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            if(templateID != '' && templateID != null) {        
            try {
                system.debug('templateID'+templateID);
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, request.Id);
            } catch(Exception exp) {
                System.debug(templateID + ' Email Failed: ' + exp.getMessage());
            }
        	emailBody = emailNotToSend.getHTMLBody();
            subjText = emailNotToSend.getSubject();
            String URL = '';
            bodyText = '<div style="background-color=white;text-align=left;">';
            bodytext += '<table style="border-collapse: collapse;border:1px solid;width: 80%;"><tr><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorTPAs+'</th><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorVendorcontactname+'</th><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorVendorcontactemail+'</th><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorDDNAckLink+'</th></tr>';
            
            if(DDNAckPendingRecords != null && DDNAckPendingRecords.size() > 0) {
                for(TPA_Request__c reqObj : DDNAckPendingRecords){
                    URL = UTL_TPA.tpaSetting.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_VendorOfferingReturnAck&id='+ reqObj.Id;
                    bodytext += '<tr><td style="font-size:13px;font-family:arial;border:1px solid;">' + reqObj.name + '</td><td style="border:1px solid;font-size:13px;font-family:arial;">'+reqObj.Service_Provider_Contact_f__c+'</td><td style="border:1px solid;font-size:13px;font-family:arial;">'+reqObj.Vendor_Contact_e_mail__c+'</td><td style="font-size:13px;font-family:arial;border:1px solid;">' + '<a href=' + url + '>' + ' Click here'+ '</a>' + '</td></tr>';
                    
                    if(reqObj.Vendor_e_mail__c != null && reqObj.Vendor_e_mail__c.length() > 0){
                        ccAddresses.Add(reqObj.Vendor_e_mail__c);
                    }
                    if(reqObj.Authorized_Signer_Email__c != null && reqObj.Authorized_Signer_Email__c.length() > 0){
                        ccAddresses.Add(reqObj.Authorized_Signer_Email__c);
                    }

                    if(reqObj.TPA_Request_Contacts__r != null && reqObj.TPA_Request_Contacts__r.size() > 0) {
                        for(TPA_Contact__c tpaContact : reqObj.TPA_Request_Contacts__r) {
                            if(tpaContact.Type__c == 'Additional Vendor Contact') {                    
                                ccAddresses.add(tpaContact.Email__c);
                            }
                        }
                    }
                }
            }
            
            bodytext += '</table>';
            bodytext += '</div>';
            emailBody = emailBody.replace('[Prior_TPA_Table]', bodyText);
            bodyTextEn = '<div style="background-color=white;text-align=left;">';
            bodyTextEn += '<table style="border-collapse: collapse;border:1px solid;width: 80%;"><tr><th style="border:1px solid;font-size:13px;font-family:arial;">Prior TPA # (s)</th><th style="border:1px solid;font-size:13px;font-family:arial;">Prior Vendor Contact Name</th><th style="border:1px solid;font-size:13px;font-family:arial;">Prior Vendor contact email</th></tr>';
            
            if(DDNAckPendingRecords != null && DDNAckPendingRecords.size() > 0) {
                for(TPA_Request__c reqObj : DDNAckPendingRecords){
                    bodyTextEn += '<tr><td style="font-size:13px;font-family:arial;border:1px solid;">' + reqObj.name + '</td><td style="border:1px solid;font-size:13px;font-family:arial;">'+reqObj.Service_Provider_Contact_f__c+'</td><td style="border:1px solid;font-size:13px;font-family:arial;">'+reqObj.Vendor_Contact_e_mail__c+'</td></tr>';
                }
            }
            
            bodyTextEn += '</table>';
            bodyTextEn += '</div>';
            emailBody = emailBody.replace('[Prior_TPA_Table_En]', bodyTextEn);
        	}
            
            
            if(request.Vendor_Contact_Email_Client__c != null) {
                toAddresses.add(request.Vendor_Contact_Email_Client__c);
            }
            if(request.TP_Processor_Email__c != null) {
                toAddresses.add(request.TP_Processor_Email__c);
            }
            
            
            if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
                ccAddresses.add(UTL_TPA.sharedEmailAddress);
            }
            try{
                if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()){
                    System.debug('in sendDataDestructionAckOutstandingMail Email send: ');
                    /*addTPProcessorInitials = true;
                    if(request.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                       assignedTPProcessorName = request.TPA_Assigned_TP_Processor__r.Initials__c; 
                    }*/
                    sendEmailThroughWorkflow(toAddresses, ccAddresses, 'SendEmail', null, request.Id, null, subjText, FALSE, emailBody, TRUE, TRUE, request);
                    //addTPProcessorInitials = false;
                }
            }
            catch(Exception e){
                System.debug('Email Failed: ' + e.getMessage());
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_request:::sendDataDestructionAckOutstandingMail', request != null ? request.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
        }
    }


    public static void sendDataDestructionAckOutstandingMailforBulkRequest( List<TPA_Request__c> lstRequest, Map<ID,List<TPA_Request__c>> mapAddressIdWithRequestLst, Map<ID,List<TPA_Request__c>> mapVendorIdWithRequestLst, Map<ID,ID> mapRequestwithVendor){
        String subjText;
        String bodyText;
        String bodyTextEn;
        String preferredLanguage;
        String templateID;
        String emailBody;
        String priorTPAs;
        String priorVendorcontactname;
        String priorVendorcontactemail;
        String priorDDNAckLink;
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        List<TPA_Request__c> DDNPendingRcrds = new List<TPA_Request__c>();
        Map<Id, TPA_Request__c> mapTPARequests = new Map<Id, TPA_Request__c>();
        Id vendorId;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(TPA_Request__c request : lstRequest ){
            
            if(request.Service_Provider_Address__r.Primary_Vendor_Address__c) {
                vendorId = request.Service_Provider_Address__c;
            } else if(request.Service_Provider_Address__r.Parent_Vendor_Name__c != null){
                vendorId = request.Service_Provider_Address__r.Parent_Vendor_Name__c;
            }
            DDNPendingRcrds = mapAddressIdWithRequestLst.get(vendorId);
            
            if(DDNPendingRcrds != null && DDNPendingRcrds.size() > 0) {
                preferredLanguage = request.vendor_language__c != null ? request.vendor_language__c : 'English';
                Set<string> langSet = new Set<string>();
                String preferredLangField = UTL_TPA_Multilingual.supportedLanguageFieldMap.get(preferredLanguage);
                
                langSet.add(UTL_TPA_Multilingual.supportedLanguageFieldMap.get('English'));
                langSet.add(UTL_TPA_Multilingual.supportedLanguageFieldMap.get('Japanese'));
                
                Map<String, List<TPA_Language_Cross_Walk__c>> langCrossWalkMap = UTL_TPA_Multilingual.getTranslatedValueMap(langSet);
                if(langCrossWalkMap != null) {
                    priorTPAs = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorTPAs')[0].get(preferredLangField);
                    priorVendorcontactname = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorVendorcontactname')[0].get(preferredLangField);
                    priorVendorcontactemail = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorVendorcontactemail')[0].get(preferredLangField);
                    priorDDNAckLink = (String)langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~priorDDNAckLink')[0].get(preferredLangField);
                }
                
                templateID = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email TPA Request on Hold'+preferredLanguage).Translated_Template_Id__c;
                Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
                emailNotToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
                emailNotToSend.setTreatTargetObjectAsRecipient(false);
                emailNotToSend.setSaveAsActivity(false);
                emailNotToSend.setCharset('UTF-8');
                if(templateID != '' && templateID != null) {    
                    emailNotToSend.setWhatId(request.Id);
                    emailNotToSend.setTemplateId(templateID);  
                    toAddresses = new List<String>();
                    if(request.Vendor_Contact_Email_Client__c != null) {
                        toAddresses.add(request.Vendor_Contact_Email_Client__c);
                    }
                    if(request.TP_Processor_Email__c != null) {
                        toAddresses.add(request.TP_Processor_Email__c);
                    }
                    mapTPARequests.put(request.Id,request);
                    emailNotToSend.setToAddresses(toAddresses);
                    
                    mails.add(emailNotToSend);
                    
                }
            }
        }
        
        Savepoint sp = Database.setSavepoint(); 
        try {
            Messaging.SendEmail(mails);
            
        } catch(Exception exp) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::SRV_TPA_TPARequest.sendDataDestructionAckOutstandingMailforBulkRequest:::Email failed', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug(templateID + ' Email Failed: ' + exp.getMessage());
        }
        Database.rollback(sp);
        
        bodyText = '';
        Id requestId = null;
        List<TPA_Request__c> DDNAckPendingRecords = new List<TPA_Request__c>();
        List<Messaging.SingleEmailMessage> mailstoSend = new List<Messaging.SingleEmailMessage>();
        for(Messaging.SingleEmailMessage mailObj:mails){
            requestId = mailObj.WhatId;
            vendorId = mapRequestwithVendor.get(requestId);
            DDNAckPendingRecords = mapAddressIdWithRequestLst.get(vendorId);
            emailBody = mailObj.HtmlBody;
            subjText = mailObj.Subject;
            toAddresses = new List<String>();
            toAddresses = mailObj.toaddresses;
            ccAddresses = new List<String>();
            bodyText = '';
            String URL = '';
            bodyText = '<div style="background-color=white;text-align=left;">';
            bodytext += '<table style="border-collapse: collapse;border:1px solid;width: 80%;"><tr><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorTPAs+'</th><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorVendorcontactname+'</th><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorVendorcontactemail+'</th><th style="border:1px solid;font-size:13px;font-family:arial;">'+priorDDNAckLink+'</th></tr>';
            if(DDNAckPendingRecords != null && DDNAckPendingRecords.size() > 0) {
                for(TPA_Request__c reqObj : DDNAckPendingRecords){
                    URL = UTL_TPA.tpaSetting.TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_VendorOfferingReturnAck&id='+ reqObj.Id;
                    bodytext += '<tr><td style="font-size:13px;font-family:arial;border:1px solid;">' + reqObj.name + '</td><td style="border:1px solid;font-size:13px;font-family:arial;">'+reqObj.Service_Provider_Contact_f__c+'</td><td style="border:1px solid;font-size:13px;font-family:arial;">'+reqObj.Vendor_Contact_e_mail__c+'</td><td style="font-size:13px;font-family:arial;border:1px solid;">' + '<a href=' + url + '>' + ' Click here'+ '</a>' + '</td></tr>';
                    
                    if(reqObj.Vendor_e_mail__c != null && reqObj.Vendor_e_mail__c.length() > 0){
                        ccAddresses.Add(reqObj.Vendor_e_mail__c);
                    }
                    if(reqObj.Authorized_Signer_Email__c != null && reqObj.Authorized_Signer_Email__c.length() > 0){
                        ccAddresses.Add(reqObj.Authorized_Signer_Email__c);
                    }
                    
                    if(reqObj.TPA_Request_Contacts__r != null && reqObj.TPA_Request_Contacts__r.size() > 0) {
                        for(TPA_Contact__c tpaContact : reqObj.TPA_Request_Contacts__r) {
                            if(tpaContact.Type__c == 'Additional Vendor Contact') {                    
                                ccAddresses.add(tpaContact.Email__c);
                            }
                        }
                    }
                    if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
                        ccAddresses.add(UTL_TPA.sharedEmailAddress);
                    }
                }
            }
            bodytext += '</table>';
            bodytext += '</div>';
            if(emailBody != null){
            emailBody = emailBody.replace('[Prior_TPA_Table]', bodyText);
            }
            bodyTextEn = '<div style="background-color=white;text-align=left;">';
            bodyTextEn += '<table style="border-collapse: collapse;border:1px solid;width: 80%;"><tr><th style="border:1px solid;font-size:13px;font-family:arial;">Prior TPA # (s)</th><th style="border:1px solid;font-size:13px;font-family:arial;">Prior Vendor Contact Name</th><th style="border:1px solid;font-size:13px;font-family:arial;">Prior Vendor contact email</th></tr>';
            
            if(DDNAckPendingRecords != null && DDNAckPendingRecords.size() > 0) {
                for(TPA_Request__c reqObj : DDNAckPendingRecords){
                    bodyTextEn += '<tr><td style="font-size:13px;font-family:arial;border:1px solid;">' + reqObj.name + '</td><td style="border:1px solid;font-size:13px;font-family:arial;">'+reqObj.Service_Provider_Contact_f__c+'</td><td style="border:1px solid;font-size:13px;font-family:arial;">'+reqObj.Vendor_Contact_e_mail__c+'</td></tr>';
                }
            }
            
            bodyTextEn += '</table>';
            bodyTextEn += '</div>';
            if(emailBody != null){
                emailBody = emailBody.replace('[Prior_TPA_Table_En]', bodyTextEn);
            }
            Workflow_Email_Record__c objWorkFlowEmail = sendBulkEmailThroughWorkfloww(toAddresses, ccAddresses, 'SendEmail', null, requestId, null, subjText, FALSE, emailBody, TRUE, TRUE, mapTPARequests.get(requestId));
            if(objWorkFlowEmail != null){
                lstEmailWorkflow.add(objWorkFlowEmail);
            }
        }
        
        try {
            if(lstEmailWorkflow != null && lstEmailWorkflow.size() > 0){
                insert lstEmailWorkflow;
            }
            System.debug('lstEmailWorkflow inserted successfully');
        } catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_TPARequest.sendDataDestructionAckOutstandingMailforBulkRequest:::Email Workflow error', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('Following Exception Occue In IF---------> ' + e);
        }
    }

    public static void sendMailtoTPProcessorAbtStatusUpdate(TPA_Request__c reqObj, String OldStatus, String newStatus) {
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        List<String> toAddress = new List<String>();
        String emailBody;
        String subjText;
        if(reqObj.TP_Processor_Email__c != null) {
            toAddress.add(reqObj.TP_Processor_Email__c);
        }
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Pending Vendor Response on DDN' + 'English').Translated_Template_Id__c;
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
            subjText = subjText.replace('old_status', OldStatus);
            subjText = subjText.replace('new_status', newStatus);
            emailBody = emailBody.replaceAll('old_status', OldStatus);
            emailBody = emailBody.replaceAll('new_status', newStatus);
        }

        /*addTPProcessorInitials = true;
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
        sendEmailThroughWorkflow(toAddress, null, 'SendEmail', null, reqObj.Id, null, subjText, FALSE, emailBody, TRUE, TRUE, reqObj);
        //addTPProcessorInitials = false;
        //sendEmailThroughWorkflow(toAddress, null, 'SendEmail', templateId, reqObj.Id, null, '', FALSE, '');
        
    }
    
   
    
    public static void sendMailtoTPProcessorAbtSignaturetoHoldForBulk(List<TPA_Request__c> lstRequest, Map<ID,String> mapRequestwitheNewStatus) {
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        List<Workflow_Email_Record__c> lstEmailWorkflowToSend = new List<Workflow_Email_Record__c>();
        List<String> toAddresses = new List<String>();
        Map<Id, TPA_Request__c> mapTPARequests =  new Map<Id, TPA_Request__c>();
        String emailBody;
        String subjText;
        String OldStatus = '';
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Pending on DDN Signature to Hold' + 'English').Translated_Template_Id__c;
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<Id, String> tpaRequestIdAndEmailMap = new Map<Id, String>();

        for(TPA_Request__c request : lstRequest ){
            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            emailNotToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
            emailNotToSend.setTreatTargetObjectAsRecipient(false);
            emailNotToSend.setSaveAsActivity(false);
            emailNotToSend.setCharset('UTF-8');
            if(templateID != '' && templateID != null) {    
                emailNotToSend.setWhatId(request.Id);
                emailNotToSend.setTemplateId(templateID);  
                toAddresses = new List<String>();
                if(request.TP_Processor_Email__c != null) {
                    tpaRequestIdAndEmailMap.put(request.Id, request.TP_Processor_Email__c);
                    toAddresses.add(request.TP_Processor_Email__c);
                }
                mapTPARequests.put(request.Id, request);
                // toAddresses.add('neha.bansal@metacube.com');
                emailNotToSend.setToAddresses(toAddresses);
                
                mails.add(emailNotToSend);
                
            }
        }
        Savepoint sp = Database.setSavepoint(); 
        try {
            system.debug('templateID'+templateID);
            Messaging.SendEmail(mails);
            
        } catch(Exception exp) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::SRV_TPA_TPARequest.sendMailtoTPProcessorAbtSignaturetoHoldForBulk:::Email Failed', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug(templateID + ' Email Failed: ' + exp.getMessage());
        }
        Database.rollback(sp);
        Id requestId = null;
        List<Messaging.SingleEmailMessage> mailstoSend = new List<Messaging.SingleEmailMessage>();
        for(Messaging.SingleEmailMessage mailObj:mails){
            requestId = mailObj.WhatId;
            emailBody = mailObj.HtmlBody;
            subjText = mailObj.Subject;
            OldStatus = mapRequestwitheNewStatus.get(requestId);
            if(!Test.isRunningTest()){
                subjText = subjText.replace('old_status', OldStatus);
                subjText = subjText.replace('new_status', 'Pending Vendor Response on Data Destruction from Prior TPAs');
                emailBody = emailBody.replace('old_status', OldStatus);
                emailBody = emailBody.replace('new_status', 'Pending Vendor Response on Data Destruction from Prior TPAs');
            }
            toAddresses = new List<String>{ tpaRequestIdAndEmailMap.get(mailObj.WhatId)};
            Workflow_Email_Record__c objWorkFlowEmail = sendBulkEmailThroughWorkfloww(toAddresses, null, 'SendEmail', null, requestId, null, subjText, FALSE, emailBody, TRUE, TRUE, mapTPARequests.get(requestId));
            if(objWorkFlowEmail != null){
                lstEmailWorkflowToSend.add(objWorkFlowEmail);
            }
        }
        try {
            if(lstEmailWorkflowToSend != null && lstEmailWorkflowToSend.size() > 0){
                insert lstEmailWorkflowToSend;
            }
            System.debug('lstEmailWorkflowToSend inserted successfully');
        } catch(Exception e) {
            System.debug('lstEmailWorkflowToSend Following Exception Occue In IF---------> ' + e);
        }
    }
    
    public static void sendReminderMailtoTPProcessorAbtStatusUpdate(TPA_Request__c reqObj) {
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        List<String> toAddress = new List<String>();
        String emailBody;
        String subjText;
        if(reqObj.TP_Processor_Email__c != null) {
            toAddress.add(reqObj.TP_Processor_Email__c);
        }
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Reminder Vendor Response on DDN' + 'English').Translated_Template_Id__c;
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateID != '' && templateID != null) {  
            try {
                system.debug('templateID'+templateID);
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
            } catch(Exception exp) {
                UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::SRV_TPA_TPARequest.sendReminderMailtoTPProcessorAbtStatusUpdate:::Template Render failed', reqObj.Id != null ? reqObj.Id : '');
                System.debug(templateID + ' Email Failed: ' + exp.getMessage());
            }
            emailBody = emailNotToSend.getHTMLBody();
            subjText = emailNotToSend.getSubject();
            
        }
        
        /*addTPProcessorInitials = true;
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
        sendEmailThroughWorkflow(toAddress, null, 'SendEmail', null, reqObj.Id, null, subjText, FALSE, emailBody, TRUE, TRUE, reqObj);
        //addTPProcessorInitials = false;
        
    }

    public static void sendMailtoTPProcessorAbtStatusUpdateFromComplianceHold(TPA_Request__c reqObj) {
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        List<String> toAddress = new List<String>();
        String emailBody;
        String subjText;
        if(reqObj.TP_Processor_Email__c != null) {
            toAddress.add(reqObj.TP_Processor_Email__c);
        }
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email to Tp Processor removal of Compliance Hold' + 'English').Translated_Template_Id__c;
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateID != '' && templateID != null) {  
            try {
                system.debug('templateID'+templateID);
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
            } catch(Exception exp) {
                UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::SRV_TPA_TPARequest.sendMailtoTPProcessorAbtStatusUpdateFromComplianceHold:::Template Render failed', reqObj.Id != null ? reqObj.Id : '');
                System.debug(templateID + ' Email Failed: ' + exp.getMessage());
            }
            emailBody = emailNotToSend.getHTMLBody();
            subjText = emailNotToSend.getSubject();
            
        }
        
        /*addTPProcessorInitials = true;
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
        sendEmailThroughWorkflow(toAddress, null, 'SendEmail', null, reqObj.Id, null, subjText, FALSE, emailBody, TRUE, TRUE, reqObj);
        //addTPProcessorInitials = false;
        
    }
 
    public static void gileadRequestSubmissionEmail(TPA_Request__c reqObj) {
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        List<String> toAddress;
        if(tpaCustomSettings.Gilead_Account_Email_Ids__c != null) {
            toAddress = tpaCustomSettings.Gilead_Account_Email_Ids__c.split(',');
        }

        Workflow_Email_Record__c objWorkFlowEmail = sendBulkEmailThroughWorkfloww(toAddress, null, 'SendEmail', tpaCustomSettings.Gilead_Request_Submission_Template_Id__c, reqObj.Id, null, '', false, '', FALSE, FALSE, reqObj);
        if(objWorkFlowEmail != null) {
            upsert objWorkFlowEmail;
        }
        //sendEmailThroughWorkflow(toAddress, null, 'SendEmail', tpaCustomSettings.Gilead_Request_Submission_Template_Id__c, reqObj.Id, null, '', false, '');       
    }
    
    public static list<TPA_Use_Offering_Atypical_Combination__c> getAtypicalUseOffCombByRequestID( Id requestId )
    {
        list<TPA_Use_Offering_Atypical_Combination__c> atypicalCombList = [select Id,
                                                                                  Name,
                                                                                  IMS_Use_Offering_Atypical_Combination__c,
                                                                                  IMS_Use_Offering_Atypical_Combination__r.Use_Name__r.Primary_Purpose_Name__c,
                                                                                  IMS_Use_Offering_Atypical_Combination__r.Offering_Name__r.Asset_Name__c,
                                                                                  IMS_Use_Offering_Atypical_Combination__r.Secondary_Offering_Name__r.Secondary_Asset_Name__c
                                                                            from TPA_Use_Offering_Atypical_Combination__c
                                                                            where TPA_Request__c =: requestId and Type__c <> 'Offering Notification Record'];
        return atypicalCombList;
    }
    
    public static void sendAtypicalUseOffClientNotification(TPA_Request__c request){
        list<TPA_Use_Offering_Atypical_Combination__c> atypicalCombList = getAtypicalUseOffCombByRequestID(request.Id);
        if(atypicalCombList != null && atypicalCombList.size() > 0)
        {
            List<String> toAddressesList = new List<String>();
            if(UTL_TPA.TPUSEMailAddress != null) {
                toAddressesList.add(UTL_TPA.TPUSEMailAddress);
            }
            List<String> ccAddressesList = new List<String>();
            if(request.TP_Processor_Email__c != null && String.isNotBlank(request.TP_Processor_Email__c)){
                ccAddressesList.add(request.TP_Processor_Email__c);
            }
            String orgId = '';
            String IMSLogoDocLInk = '';
            Integer i = 0;
            TPA_Settings__c tpaSetting = TPA_Settings__c.getInstance();
            if(tpaSetting != null){
               
                ccAddressesList.add(tpaSetting.Shared_Email__c);
                if(tpaSetting.TPA_DRN_Mails_Copy_To__c != null && String.isNotBlank(tpaSetting.TPA_DRN_Mails_Copy_To__c)){
                    List<String> ccAdd =  tpaSetting.TPA_DRN_Mails_Copy_To__c.split(',');
                    ccAddressesList.addAll(ccAdd);
                }
                //ccAddressesList.add(tpaSetting.TPA_DRN_Mails_Copy_To__c);
                orgId = tpaSetting.TPA_From_Address_For_Data_Release__c;
                IMSLogoDocLInk = tpaSetting.IMS_health_logo_url__c;
            }

            String subject = 'Response Needed: ' + request.name +' Requires Additional Information To Continue Processing';

            String emailBody = '<div style="background-color=white;text-align=left;">';
            emailBody += '<div style="width:100%;background-color:#CCC;overflow:auto;">';
            emailBody += '<div style="width:55%;margin:auto;overflow:auto;background-color: white;padding:0 10px 0 10px;">';
            emailBody += '<div style="float:right;clear:both;">';
            emailBody += '<img src="' + IMSLogoDocLInk + '" />';
            emailBody += '</div>';
            emailBody += '<div style="float:right;clear:both;font-size:13px;font-family:arial;">';
            emailBody += '<p style="color: #5b9bd5;"><b>Response Needed: Additional information is required for ' + request.name +' to continue processing</b></p>';
            emailBody += '<p>Good day ' + request.ClientContact__r.name + ', thank you for your diligence and compliance around ' + Label.TPA_IQVIA_Keyword + ' Third-Party Access.</p>';
            emailBody += '<p>We have received your Third Party Access (' + request.name +') request to share ' + Label.TPA_IQVIA_Keyword + ' Data with ' + request.Service_Provider_Address__r.name + '.  Upon internal review, one or more Use(s) and ' + Label.TPA_IQVIA_Keyword + ' Offerings selected are not typically used in such a combination.</p>';
            emailBody += '<p>Use / Offering Combination not typical further explanation required:';
            emailBody += '<table style="min-width: 65%;border-collapse:collapse;border: 2px solid black;">';
            emailBody += '<tr>';
            emailBody += '<th style="border: 2px solid black;padding: 0 5px 0 5px;">USE(s)</th>';
            emailBody += '<th style="border: 2px solid black;padding: 0 5px 0 5px;">Offering(s)</th></tr>';
            system.debug('important debug7::');

            for(TPA_Use_Offering_Atypical_Combination__c atypicalComb : atypicalCombList)
            {
                system.debug('In TPAQueryHelper : sendAtypicalUseOffClientNotification() : atypicalComb = ' + atypicalComb);
                String alterColor = '';
                if( math.mod(i, 2) == 0 ) {
                    alterColor = 'background-color: #acc2e5;';
                }else{
                    alterColor = 'background-color: white;';
                }
                i++;
                emailBody += '<tr style="'+ alterColor +'">';
                emailBody += '<td style="border: 2px solid black;padding: 0 5px 0 5px;">' + atypicalComb.IMS_Use_Offering_Atypical_Combination__r.Use_Name__r.Primary_Purpose_Name__c + '</td>';
                emailBody += '<td style="border: 2px solid black;padding: 0 5px 0 5px;">';
                emailBody += atypicalComb.IMS_Use_Offering_Atypical_Combination__r.Offering_Name__r.Asset_Name__c;
                if(atypicalComb.IMS_Use_Offering_Atypical_Combination__r.Secondary_Offering_Name__r.Secondary_Asset_Name__c != null)
                    emailBody += ' < ' + atypicalComb.IMS_Use_Offering_Atypical_Combination__r.Secondary_Offering_Name__r.Secondary_Asset_Name__c + ' > ';
                emailBody += '</td></tr>';
            }
            
            emailBody += '</table></p>';
            emailBody += '<p><span style="color: #5b9bd5;">ACTION REQUESTED:</span> To continue our review for approval we ask that you please respond by way of this message how the offering(s) will be utilized for such Use(s).  If such selections were made in error, you can remove them through the on-line TPA Portal within ' + request.name + ' by selecting \'delete\' for the combination.</p>';
            emailBody += '<p><span style="color: #5b9bd5;">PLEASE NOTE:</span> This TPA is pending ' + Label.TPA_IQVIA_Keyword + ' Review while waiting for your additional support.</p>';
            emailBody += '<p>We thank you for your time in advance,</p>';
            emailBody += '<p>' + Label.TPA_IQVIA_Keyword + ' Third Party Access Program</p></div>';
            emailBody += '<p>[TPA_Email_Footer_En]</p></div>';
            emailBody += '</div></div>';

            /*String clientLanguage = 'English';//Japanese is not supported for now.
            TPA_Multilingual_Template_Setting__c templatObj = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Atypical_Comb_Client_Notification' + clientLanguage);
            String templateId = templatObj.Translated_Template_Id__c; */

            //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //mail.setToAddresses(toAddressesList);
            /*if(String.isNotBlank(tpaSetting.TPA_Mail_ID__c)) {
                List<String> bccTo =  tpaSetting.TPA_Mail_ID__c.split(';');
                mail.setBccAddresses(bccTo);
            }*/
            //ccAddressesList = UTL_TPA_Multilingual.ccList(request.Client_Address__r.TPAOtherEmailIds__c, ccAddressesList);
            //ccAddressesList = UTL_TPA_Multilingual.addAdditionalClientContactInccList(SRV_TPA_TPARequest.getContactsForRequest(request.id), ccAddressesList);
            /*mail.setCcAddresses(ccAddressesList);
            mail.setSubject(subject);
            mail.setHtmlBody(emailBody);
            mail.setWhatId(request.id);
            mail.setOrgWideEmailAddressId(orgId);
            mail.setSaveAsActivity(true);
            mail.setTargetObjectId(UTL_TPA.emailTargetContactId);
            mail.setTreatTargetObjectAsRecipient(false);*/
            
            try
            {
                if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest())
                {
                    //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    /*addTPProcessorInitials = true;
                    if(request.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                       assignedTPProcessorName = request.TPA_Assigned_TP_Processor__r.Initials__c; 
                    }*/
                    sendEmailThroughWorkflow(toAddressesList, ccAddressesList, 'SendEmail', '', request.id, null, subject, false, emailBody, TRUE, TRUE, request);
                    //addTPProcessorInitials = false;
                    System.debug('Success: Atypical Combination Notification Sent to client.');
                    //todo
                    //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success';
                    //TPAQueryHelper.setLogObject(request.id , 'Success: Atypical Combination Notification Sent to client.', '');
                    //TPAQueryHelper.logRef().generateLog();
                }
            }
            catch(Exception e)
            {
                System.debug('Failed: Atypical Combination Notification NOT sent to client' + e.getMessage());
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_TPARequest:::sendAtypicalUseOffClientNotification', request != null ? request.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                //todo
                //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
                //TPAQueryHelper.setLogObject(tpaRequest.id , 'Exception: Atypical Combination Notification NOT Sent to client.', e.getMessage()+'In Class TPAQueryHelper : sendAtypicalUseOffClientNotification() at line No : '+e.getLineNumber());
                //TPAQueryHelper.logRef().generateLog();
            }
        }
    }
    
    public static void sendAutoApprovalMail( String emailaddresses,  List<String> tpProcessorEmailId) {
        //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String subjText;
        String bodyText;
        String[] ccAddressesList;
        if(SRV_TPA_TPARequest.LastAction == 'Request Edited By Vendor' || SRV_TPA_TPARequest.LastAction == 'Request Edited By TP Processor') {
            subjText = '\'' + tpaRequest.Client_Address__r.Name + '\' Vendor \''+tpaRequest.Service_Provider_Address__r.Name+'\' \''+tpaRequest.Name+'\' TPA request is edited and auto-approved.';
        } else {
            subjText = '\''+tpaRequest.Client_Address__r.Name+'\' Vendor \''+tpaRequest.Service_Provider_Address__r.Name+'\' \''+tpaRequest.Name+'\' TPA request is auto-approved.';
        }
        bodyText = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">Dear Third Party Processor :';
        bodyText += '<br>A TPA Request submitted to ' + Label.TPA_IQVIA_Keyword + ' is Auto Approved';
        bodytext += '<br><br>TPA Request details are as follows:';
        bodytext += '<br><br>';
        bodytext += '<br>ID: '+tpaRequest.Id;
        bodytext += '<br>Name: '+tpaRequest.Name;
        bodytext += '<br>Client: '+tpaRequest.Client_Address__r.Name;
        bodytext += '<br>Third Party: '+tpaRequest.Service_Provider_Address__r.Name;
        bodytext += '<br>Status: Awaiting Vendor Signature';
        if(tpaRequest != null) {
            //  bodytext += '<br>Agreement number: '+tpaRequest.Agreement_Number__c;
            bodytext += '<br>Click on the link below to access the agreement record:';
            //bodytext += '<br><br><a>'+ Label.TPA_Link_to_agrrement +tpaRequest.Id+'</a>';
            bodytext += '<br><br><a>'+ TPA_Settings__c.getOrgDefaults().Base_Url__c + '/' + tpaRequest.Id+'</a>';
        }
        bodytext += '<br>';
        bodyText += '<br><br>Thanks</p></div>';
        if(emailaddresses != NULL && emailaddresses.trim() != '') {
            ccAddressesList = emailaddresses.split(',', 0);
            //TPA_Settings__c tpaSetting = TPA_Settings__c.getInstance();
            //if(tpaSetting != null && tpaSetting.Shared_Email__c != null)
            //    address.add(tpaSetting.Shared_Email__c);
            //mail.setCcAddresses(address);
            //mail.setToAddresses(tpProcessorEmailId);
        }
        
        /*if(String.isNotBlank(UTL_TPA.tpaSetting.TPA_BCC_Emails__c)) {
           List<String> bccTo = new List<String>();
           bccTo.addAll(UTL_TPA.tpaSetting.TPA_BCC_Emails__c.split(';'));
           mail.setBccAddresses(bccTo);
        }*/
            
        //mail.setSubject(subjText);
        //mail.setHtmlBody(bodyText);
        //mail.setWhatId(tpaRequest.Id);
        //mail.setSaveAsActivity(true);
        //mail.setTargetObjectId(UTL_TPA.emailTargetContactId);
        //mail.setTreatTargetObjectAsRecipient(false);
        try {
            //if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            /*addTPProcessorInitials = true;
            if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
               assignedTPProcessorName = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c; 
            }*/
            SRV_TPA_TPARequest.sendEmailThroughWorkflow(tpProcessorEmailId, ccAddressesList, null, null, tpaRequest.Id, null, subjText, false, bodyText, TRUE, TRUE, tpaRequest);
            //addTPProcessorInitials = false;
            
                //todo
                //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success';
                //TPAQueryHelper.setLogObject(tpaRequest.id , 'Success: Auto Approval Email Sent Successfully', '');
                //TPAQueryHelper.logRef().generateLog();
            //}
        }
        catch(Exception e)
        {
            System.debug('Email Failed: ' + e.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_TPARequest:::sendAutoApprovalMail', tpaRequest != null ? tpaRequest.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            //todo
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            //TPAQueryHelper.setLogObject(tpaRequest.id , 'Exception: Auto Approval Email NOT Sent', e.getMessage()+'*'+e.getLineNumber());
            //TPAQueryHelper.logRef().generateLog();
        }
    }
    
    
    
    /* Method to create a Task entry under activity history of object
        parId: record id under which task needs to create
        taskSubject: Subject for task
        isInsertTask: task will be inserted/created only if this flag is true
    */
    
    
    public static List<TPA_Secondary_Data_Asset__c> getTPASecondaryDataAsset(Set<Id> setTPADataAsset) {
        List<TPA_Secondary_Data_Asset__c> tpaSecondaryDataAssets =
            [SELECT Id, Secondary_Asset_Name__c,TPA_Data_Asset__c,Geo_Level__c,IMS_Secondary_Data_Asset__c FROM TPA_Secondary_Data_Asset__c
            where TPA_Data_Asset__c in :setTPADataAsset order by TPA_Data_Asset__c];

        return tpaSecondaryDataAssets;
    }

    public static void getCustomException() {
        if(Test.isRunningTest()) { 
            CalloutException e = new CalloutException();
            e.setMessage('This is a constructed exception for testing and code coverage');
            throw e;
        }
    }

    public static TPA_Request__c getRequestStatus(TPA_Request__c tpaRequest) {
        List<TPA_Request__c> DDNAckPendingRecords;

        if(tpaRequest.Service_Provider_Address__c != null && tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null) {
            DDNAckPendingRecords =  UTL_TPA.getDDNAckPendingRequests(tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c);
        } else {
            DDNAckPendingRecords =  UTL_TPA.getDDNAckPendingRequests(tpaRequest.Service_Provider_Address__c);
        }

        Boolean onlyAMAReasonsApplicable = false;
        Boolean ifTPAReasonsApplicable = false;

        Set<String> tpaReasons = new Set<String>();
        Set<String> tpaReasonsTemp = new Set<String>();
        Set<String> amaReasons = new Set<String>();

        


        if(tpaRequest.Manual_Trigger_Reasons__c != null && tpaRequest.Manual_Trigger_Reasons__c != ''){
            tpaReasons = new Set<String>(tpaRequest.Manual_Trigger_Reasons__c.split(';'));
            tpaReasonsTemp.addAll(tpaReasons);
        }

        system.debug(tpaReasons.contains('Vendor DDN Acknowledgement Outstanding')+'//'+DDNAckPendingRecords);
        if(tpaReasons.contains('Vendor DDN Acknowledgement Outstanding') && (DDNAckPendingRecords == null || DDNAckPendingRecords.size() == 0)){
            tpaReasons.remove('Vendor DDN Acknowledgement Outstanding');
            tpaReasonsTemp.remove('Vendor DDN Acknowledgement Outstanding');
            tpaRequest.Manual_Trigger_Reasons__c = String.join(new List<String>(tpaReasons), '; ');
        }
        else if(tpaReasons.contains('Client TPA Compliance Hold:  Requires TPA Compliance Review') && !tpaRequest.isClientOnComplianceHold__c){
            tpaReasons.remove('Client TPA Compliance Hold:  Requires TPA Compliance Review');
            tpaReasonsTemp.remove('Client TPA Compliance Hold:  Requires TPA Compliance Review');
            tpaRequest.Manual_Trigger_Reasons__c = String.join(new List<String>(tpaReasons), '; ');
            deleteComReview('Client TPA Compliance Hold:  Requires TPA Compliance Review',tpaRequest);
        }
        else if(tpaReasons.contains('Vendor TPA Compliance Hold: Requires TPA Compliance Review') && !tpaRequest.isVendorOnComplianceHold__c){
            tpaReasons.remove('Vendor TPA Compliance Hold: Requires TPA Compliance Review');
            tpaReasonsTemp.remove('Vendor TPA Compliance Hold: Requires TPA Compliance Review');
            tpaRequest.Manual_Trigger_Reasons__c = String.join(new List<String>(tpaReasons), '; ');
            deleteComReview('Vendor TPA Compliance Hold: Requires TPA Compliance Review',tpaRequest);
        }

        if(tpaRequest.AMA_Agreement_Details__r != null && tpaRequest.AMA_Agreement_Details__r.size() > 0) {
            AMA_Agreement_Detail__c amaAgreementDetails = tpaRequest.AMA_Agreement_Details__r[0];
            if(amaAgreementDetails.AMA_Manual_Trigger_Reasons__c != null && amaAgreementDetails.AMA_Manual_Trigger_Reasons__c != ''){
                amaReasons = new Set<String>(amaAgreementDetails.AMA_Manual_Trigger_Reasons__c.split(';'));
            }
        }

        if(amaReasons.size() > 0 && tpaReasonsTemp.containsAll(amaReasons)){
            tpaReasonsTemp.removeAll(amaReasons);
            if(tpaReasonsTemp.size() == 0){
                onlyAMAReasonsApplicable = true;
            }       
        } 
        if(tpaReasonsTemp.size() > 0){
            ifTPAReasonsApplicable = true;
        }
        
        if(DDNAckPendingRecords != null && DDNAckPendingRecords.size() > 0) {
            system.debug('in IF condition DDN Dtatus: ');
            SRV_TPA_TPARequest.sendMailtoTPProcessorAbtStatusUpdate(tpaRequest, tpaRequest.request_status__c , 'Pending Vendor Response on Data Destruction from Prior TPAs');
            tpaRequest.request_status__c = 'Pending Vendor Response on Data Destruction from Prior TPAs';
        } 
        else if(ifTPAReasonsApplicable && !onlyAMAReasonsApplicable && (tpaRequest.isClientOnComplianceHold__c || tpaRequest.isVendorOnComplianceHold__c)) {
            tpaRequest.Request_Status__c = 'Hold for TPA non-compliance';
            if(tpaRequest.isClientOnComplianceHold__c){
                tpaReasons.add('Client TPA Compliance Hold:  Requires TPA Compliance Review');
                tpaRequest.Manual_Trigger_Reasons__c = String.join(new List<String>(tpaReasons), '; ');
                insertComReview('Client TPA Compliance Hold:  Requires TPA Compliance Review',tpaRequest);
            }
            if(tpaRequest.isVendorOnComplianceHold__c){
                tpaReasons.add('Vendor TPA Compliance Hold: Requires TPA Compliance Review');
                tpaRequest.Manual_Trigger_Reasons__c = String.join(new List<String>(tpaReasons), '; ');
                insertComReview('Vendor TPA Compliance Hold: Requires TPA Compliance Review',tpaRequest);
            }
        }
        else if(SRV_TPA_TPARequest.isDynamicNotificationRequiredForVendor(tpaRequest) && SRV_TPA_TPARequest.isDirectToClientExeMode && tpaRequest.Is_VSN_Acknowlege_By_Client__c == true){
            tpaRequest.request_status__c = UTL_TPA.AWAITING_CLIENT_CONFIRMATION;
            SRV_TPA_TPARequest.VendorSpecificNotificationSendConfirmationToClient(tpaRequest,tpaRequest.ClientContact__r.email);
        }
        else if(ifTPAReasonsApplicable && !onlyAMAReasonsApplicable) {
            tpaRequest.Request_Status__c = Label.TPA_In_Review_By_IQVIA_Status;
        }
        else if(onlyAMAReasonsApplicable) {
            tpaRequest.Request_Status__c = 'TPA Approved Awaiting AMA Approval';
        }
        else {
            tpaRequest.Request_Status__c = 'In Auto Approval Process';
        }  
        return tpaRequest;
    }

    public static void sendForYourRecordsOnDeletionMail(List<TPA_Commercial_Review__c> ListComRvForDeletedRecord, List<TPA_Commercial_Review__c> ListComRvFilteredRecord, String CommercialReviewEmail){
        Id reqId = tpaRequest.Id;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Id emailTempId = UTL_TPA_Multilingual.getEmailTemplateId('For Your Records Mail on Offering Deletion','English');
        email = Messaging.renderStoredEmailTemplate(emailTempId, NULL, reqId);
        String initials = '';
        String globalTPProcessorInitials = '';
        System.debug('Email Template Id '+emailTempId);
        String additionalTermBody = '';
        String tableStyle = 'style = "border-collapse: collapse;font-size:10px;font-family:arial;border:2px solid;"';
        String tableRowStyle = 'style = "border:2px solid #000;font-size:8pt;font-family:arial;"';
        String tableHeaderStyle = 'style = "border:2px solid #000;font-size:10pt;font-family:arial; font-size:10pt; color:#fff; background-color:blue;"';
        String fontstyle = '<div style="font-size:10pt !important;font-family:arial !important;margin:0px;">'; 

        String tableContentforDeletedOfferings = '';
        String tableContentForRemainingOfferings = '';
        
        if(ListComRvForDeletedRecord != null && ListComRvForDeletedRecord.size() > 0){
            tableContentforDeletedOfferings += '<div><table ' + tableStyle +'><tr><th ' + tableHeaderStyle + '>Manual Review Reason</th>';
            tableContentforDeletedOfferings += '<th ' + tableHeaderStyle + '>Associated Use(s)</th>';
            tableContentforDeletedOfferings += '<th ' + tableHeaderStyle + '>Country of Offering</th>';
            tableContentforDeletedOfferings += '<th ' + tableHeaderStyle + '>Associated Offerings(s)</th>';
            tableContentforDeletedOfferings += '<th ' + tableHeaderStyle + '>Date of Review</th></tr>';
            for(TPA_Commercial_Review__c comRvForDeletedRecord : ListComRvForDeletedRecord){
                tableContentforDeletedOfferings += '<tr><td ' + tableRowStyle + '>' + (comRvForDeletedRecord?.Manual_Review_Reason__c ?? '') +  '</td>';
                tableContentforDeletedOfferings += '<td ' + tableRowStyle + '>' + (comRvForDeletedRecord?.Associated_Use_to_Review__c ?? '')  +  '</td>';
                tableContentforDeletedOfferings += '<td ' + tableRowStyle + '>' + (comRvForDeletedRecord?.BU__c ?? '') +  '</td>';
                tableContentforDeletedOfferings += '<td ' + tableRowStyle + '>' + (comRvForDeletedRecord?.Associated_Offering_to_Review__c ?? '')  +  '</td>';
                tableContentforDeletedOfferings += '<td ' + tableRowStyle + '>' + (comRvForDeletedRecord?.Date_of_Action_Response__c?.format() ?? '' ) +  '</td></tr>';
            }
            tableContentforDeletedOfferings += '</table></div>';
        }
        
        if(ListComRvFilteredRecord != null && ListComRvFilteredRecord.size() > 0){
            tableContentForRemainingOfferings += '<br><div><span style = "color:#4472C4"><strong>Updated Record of Manual Reviews:</strong></span><br/>The table below provides an updated record of the items in the TPA Request that remain from your prior review.</div><br>';
            tableContentForRemainingOfferings += '<div><table ' + tableStyle + '><tr><th ' + tableHeaderStyle + '>Manual Review Reason</th>';
            tableContentForRemainingOfferings += '<th ' + tableHeaderStyle + '>Associated Use(s)</th>';
            tableContentForRemainingOfferings += '<th ' + tableHeaderStyle + '>Country of Offering</th>';
            tableContentForRemainingOfferings += '<th ' + tableHeaderStyle + '>Associated Offerings(s)</th>';
            tableContentForRemainingOfferings += '<th ' + tableHeaderStyle + '>Commercial Owner Decision</th></tr>';
            for(TPA_Commercial_Review__c comRvFilteredRecord : ListComRvFilteredRecord){
                tableContentForRemainingOfferings += '<tr><td ' + tableRowStyle + '>' + (comRvFilteredRecord?.Manual_Review_Reason__c ?? '') +  '</td>';
                tableContentForRemainingOfferings += '<td ' + tableRowStyle + '>' + (comRvFilteredRecord?.Associated_Use_to_Review__c ?? '')   +  '</td>';
                tableContentForRemainingOfferings += '<td ' + tableRowStyle + '>' + (comRvFilteredRecord?.BU__c ?? '') +  '</td>';
                tableContentForRemainingOfferings += '<td ' + tableRowStyle + '>' + (comRvFilteredRecord?.Associated_Offering_to_Review__c ?? '')  +  '</td>';
                tableContentForRemainingOfferings += '<td ' + tableRowStyle + '>' + (comRvFilteredRecord?.Action__c ?? '') +  '</td></tr>';
            }
            tableContentForRemainingOfferings += '</table></div>';
        }
        
        List<TPA_Text_Editor__C> offeringSpecificTextAddTerms = new List<TPA_Text_Editor__C>();
        List<TPA_Additional_Term__c> offeringSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
        List<TPA_Additional_Term__c> useSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
        List<TPA_Additional_Term__c> useOfferingSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
        Set<TPA_Offering_Notification_Mapping__c> DynamicNotifications = new Set<TPA_Offering_Notification_Mapping__c>(); 
        Map<String, TPA_Text_Editor__c> mapTpaTextAdditionalTerms = UTL_TPA.getTpaTextAdditionalTerms(tpaRequest);
        Map<String, TPA_Additional_Term__c> mapTpaAdditionalTerms = UTL_TPA.getTpaAdditionalTerms(tpaRequest);
        TPA_Request__C tpaRequestForPurpose = [Select Id,Name,Service_Provider_Address__c,Vendor_Billing_Mailing_Country__c,is_LAAD_Response_Acknowledged__c,Is_VSN_Acknowlege_By_Client__c, (select id,IMS_Legal_Entity__c,Purpose__c,Purpose__r.Id from Purposes__r), (SELECT Id, TPA_Offering_Notification_Record__c, Type__c FROM TPA_Use_Offering_Atypical_Combinations__r WHERE Type__c = 'Offering Notification Record') From TPA_Request__c where Id =: tpaRequest.Id ];
        Map<String, TPA_Offering_Notification_Mapping__c> mapTpaDynamicNotifications = UTL_TPA.getmapTpaDynamicNotifications(tpaRequestForPurpose);
        if(mapTpaTextAdditionalTerms != null || mapTpaAdditionalTerms != null || mapTpaDynamicNotifications != null){
                additionalTermBody += '<div style="font-size:13px;font-family:arial;"><B>Additional Term(s) under TLLA Schedule A: </B></div>';
                if(mapTpaTextAdditionalTerms != null){
                    system.debug('mapTpaTextAdditionalTerms'+mapTpaTextAdditionalTerms.values());
                    if(mapTpaTextAdditionalTerms.containsKey('AI_ML_Restrictions:TPA_Request__c')){
                        additionalTermBody += '<br><br>' + fontStyle + mapTpaTextAdditionalTerms.get('AI_ML_Restrictions:TPA_Request__c').content__c + '</div>'; 
                    }
                    for( String addKey : mapTpaTextAdditionalTerms.keyset()) {
                        if(addKey.split(':')[1] == 'TPA_Request__c'){
                            if(!(addKey.split(':')[0] == 'is_Veeva_Use_CRM__c' ||  addKey.split(':')[0] == 'AI_ML_Restrictions')){
                                TPA_Text_Editor__C listEditor = mapTpaTextAdditionalTerms.get(addKey);
                                additionalTermBody += '<br><br>'+ fontStyle + mapTpaTextAdditionalTerms.get(addKey).Content__c + '</div>';
                            }
                        }
                        if(addKey.split(':')[1] == 'IMS_Legal_Entity__c'){
                            TPA_Text_Editor__C listEditor = mapTpaTextAdditionalTerms.get(addKey);
                            if(TpaTextTerms.contains(listEditor.Page_Name__c)){
                                offeringSpecificTextAddTerms.add(mapTpaTextAdditionalTerms.get(addKey));
                            }
                        }  
                    }
                }
                if(mapTpaAdditionalTerms != null){
                    for( String addKey : mapTpaAdditionalTerms.keyset()) {
                        if(addKey.split(':')[1] == 'General Ad-Hoc Term'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            additionalTermBody += '<br><br>' + fontStyle + '<strong><u>' + addhocTerm.Term_Name__c + ':</u></strong>';
                            additionalTermBody += '<br><br>'  + addhocTerm.Addtional_Term__c ;
                            if(addhocTerm.Exhibit_Attached__c && addhocTerm.Attachments != null && addhocTerm.Attachments.size() > 0){
                                String attchId = addhocTerm.Attachments[0].Id;
                                additionalTermBody += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                            }
                            additionalTermBody += '</div>';
                        }
                        if(addKey.split(':')[1] == 'Data Asset Specific Ad-Hoc Term'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            offeringSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                        if(addKey.split(':')[1] == 'Use Specific Ad-Hoc Terms'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            useSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                        if(addKey.split(':')[1] == 'Use/Offering Specific Ad-Hoc Terms'){
                            TPA_Additional_Term__c addhocTerm = mapTpaAdditionalTerms.get(addKey);
                            useOfferingSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                            
                        }
                    }
                }
            	if(mapTpaDynamicNotifications != null){
                    for( String addKey : mapTpaDynamicNotifications.keyset()) {
                        TPA_Offering_Notification_Mapping__c offNotify =  mapTpaDynamicNotifications.get(addKey);
                        set<String> offeringDupCheck = new set<String>();
                        for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.Associated_Offering_to_Review__c == null){
                                DynamicNotifications.add(mapTpaDynamicNotifications.get(addKey));
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null && !offeringDupCheck.contains(comRev.Associated_Offering_to_Review__c) && (comRev.Associated_Offering_to_Review__c.indexOf(offNotify.Primary_Data_Asset_Name__c) != -1 || comRev.Associated_Offering_to_Review__c.indexOf(offNotify.Secondary_Data_Asset_Name__c) != -1)){
                                offeringDupCheck.add(comRev.Associated_Offering_to_Review__c);
                                DynamicNotifications.add(mapTpaDynamicNotifications.get(addKey));
                            }
                        }
                    }
                }
            }
            if((offeringSpecificTextAddTerms != null && offeringSpecificTextAddTerms.size() > 0) || (offeringSpecificAddhocTerms != null && offeringSpecificAddhocTerms.size() > 0) || (useSpecificAddhocTerms != null && useSpecificAddhocTerms.size() > 0) || (useOfferingSpecificAddhocTerms != null && useOfferingSpecificAddhocTerms.size() > 0) || (DynamicNotifications != null && DynamicNotifications.size() > 0) ){
                additionalTermBody += '<br><br><div style="font-size:13px;font-family:arial;"><B>Use Specific Additional Term(s) under TLLA Schedule A: </B></div>';
                if(useSpecificAddhocTerms != null && useSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: useSpecificAddhocTerms){
                        additionalTermBody += '<br><br>' + fontStyle + '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                        additionalTermBody += '<br><br>'  + addhoc.Addtional_Term__c ;
                        if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                            String attchId = addhoc.Attachments[0].Id;
                            additionalTermBody += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                        }
                        additionalTermBody += '</div>';
                    }
                }
                additionalTermBody += '<br><br><div style="font-size:13px;font-family:arial;"><B>Use/Offering Specific Additional Term(s) under TLLA Schedule A: </B></div>';
                if(useOfferingSpecificAddhocTerms != null && useOfferingSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: useOfferingSpecificAddhocTerms){
                        additionalTermBody += '<br><br>' + fontStyle + '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                        additionalTermBody += '<br><br>'  + addhoc.Addtional_Term__c ;
                        if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                            String attchId = addhoc.Attachments[0].Id;
                            additionalTermBody += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                        }
                        additionalTermBody += '</div>';
                    }
                }
                additionalTermBody += '<br><br><div style="font-size:13px;font-family:arial;"><B>Offering Specific Additional Term(s) under TLLA Schedule A: </B></div>';
                if(offeringSpecificTextAddTerms != null && offeringSpecificTextAddTerms.size() > 0){ 
                    for(TPA_Text_Editor__C txt: offeringSpecificTextAddTerms){
                        additionalTermBody += '<br><br>'+ fontStyle + txt.Content__c + '</div>';
                    }
                }
                if(offeringSpecificAddhocTerms != null && offeringSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: offeringSpecificAddhocTerms){
                        additionalTermBody += '<br><br>' + fontStyle + '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                        additionalTermBody += '<br><br>'  + addhoc.Addtional_Term__c ;
                        if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                            String attchId = addhoc.Attachments[0].Id;
                            additionalTermBody += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                        }
                        additionalTermBody += '</div>';
                        
                    }
                }
                String DynNotiDuplicatecheck = '';
                if(DynamicNotifications != null && DynamicNotifications.size() > 0){
                    for(TPA_Offering_Notification_Mapping__c offNotify: DynamicNotifications){
                        String offNotifyContent = offNotify.Offering_Notifications__r.Content__c;
                        if(!DynNotiDuplicatecheck.contains(offNotifyContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', ''))){
                            DynNotiDuplicatecheck += offNotifyContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', '') + '|-|';
                            system.debug('in dynamic notification : ' + offNotifyContent);
                            additionalTermBody += '<br><br>' + fontStyle + offNotifyContent + '</div>';
                        }
                    }
                }
            }
        
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        if(CommercialReviewEmail != null){
        	toAddresses.addAll(CommercialReviewEmail.split(';'));
        }
        emailToSend.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(email.getHTMLBody().replace('TABLE_RECORDS', tableContentforDeletedOfferings + tableContentForRemainingOfferings).replace('ADDITIONAL_TERM_RECORDS', additionalTermBody)));
        emailToSend.setSubject(email.getSubject());
        try
        {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                sendEmailThroughWorkflow(toAddresses, null,'SendEmail', null, reqId, null, emailToSend.getSubject(), FALSE, emailToSend.getHTMLBody(),TRUE,TRUE,tpaRequest);
                SRV_TPA_TPARequest.updateActivityHistory(reqId, 'sendForYourRecordsOnDeletionMail sent', true);
                
            }
        }
        catch(Exception e)
        {
            System.debug('Email Failed: ' + e.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::SRV_TPA_TPARequest:::sendForYourRecordsOnDeletionMail', reqId != null ? reqId : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
    }   

    public static void deleteComReview(String manReviewReason,TPA_Request__c tpaRequest){
        List<TPA_Commercial_Review__c> comRev = [Select Id From TPA_Commercial_Review__c where Manual_Review_Reason__c =: manReviewReason and TPA_Request__c =: tpaRequest.Id];
        if(comRev != null && comRev.size() > 0){
            delete comRev;
        }
    }

    public static void insertComReview(String manReviewReason,TPA_Request__c tpaRequest){
        TPA_Commercial_Review__c comRev = new TPA_Commercial_Review__c(Manual_Review_Reason__c=manReviewReason,TPA_Request__c=tpaRequest.Id,Action_Needed_By__c='TP-Country',TP_Country_Email__c=tpaRequest.TP_Processor_Email__c);
        insert comRev;
    }
	
	public static Boolean isComRevApproved(String status){
        if(status != null && !status.contains('Combination Approved') && !status.contains('Combination Approved and Future Approved') && status != 'Complete' ){
            return false;
        }
        return true;
    }

    public class commercialReviewWrapper {
        public TPA_Request__c request;
        public string manualReviewReason;
        public string ReceiversEmail;
        public string AssociatedOffering;
        public string AssociatedUse;
        public TPA_Data_Asset__c priDataAsset;
        public TPA_Secondary_Data_Asset__c secDataAsset;
        public String useCategory;
        public string status;
        public string ActionNeededBy;
    }
}