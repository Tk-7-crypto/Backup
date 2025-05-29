global class CNT_TPA_CommercialReviewForm { 
    
    /************
Properties
*************/
    public TPA_Request__c tpaRequest {get; set;}
    public Map<String, TPA_Commercial_Review__c>  tpaCommercialReviewList {get; set;}
    public string isAuthorisedSigner {get; set;}
    public String  commercialListToShow {get; set;}
    private static List<String> nonApprovedOfferingList = new List<String>();
    private static List<String> alwaysApprovedOfferingList = new List<String>();
    private static List<String> commercialOwnerEmailIdList = new List<String>();
    public static Set<String> futureApprovedComRevKeys = new Set<String>();
    public static List<TPA_Additional_Term__c> addHocTermsToUpdate = new List<TPA_Additional_Term__c>();
    public static Boolean isCommRevUpdate = false;
    public static string latestAMAContractDate{
        get{
            if(latestAMAContractDate == null){
                return SRV_TPA_AMAAgreementDetail.recentAMAContractDate()?.format('MM-dd-yyyy')??'';
            }
            return latestAMAContractDate;
        }
    }
    public static String  otherDataAssetsKeys {get{
        if(otherDataAssetsKeys == null){
            Set<String> otherDataAssetsKeySet = new Set<String>();
            String tpaRequestId = ApexPages.currentPage().getParameters().get('id');
            for(TPA_Data_Asset__c tpaDa : [Select Id,Asset_Name__c,BU__c,Geo_Level__c,A_Column_Use_For_Template__c,Purpose__r.Name,Purpose__r.Purpose_Category_Name__c,IMSLegalEntity__c,IMS_Legal_Entity_for_Other__c From TPA_Data_Asset__c where Asset_Name__c like '%Other%' and (IMSLegalEntity__c = null and IMS_Legal_Entity_for_Other__c = null) and Request__c =: tpaRequestId]){
                otherDataAssetsKeySet.add(createKeyDataAsset(tpaDa));
            }
            return JSON.serialize(otherDataAssetsKeySet);
        }
        return otherDataAssetsKeys;
    } set;}

    public static Integer pageSize {get{
        if(pageSize == null){
            pageSize = UTL_TPA.commercialFormPageSize == null ? 200 : UTL_TPA.commercialFormPageSize;
        }
        return pageSize;
    } set;}
    
    public string getLegalEntityList()
    {
        Set<String> lstPickvals = new Set<String>();
        lstPickvals.add('Select Other - Offering IQVIA Legal Entity Here');
        for(IMS_Data_Asset__c primaryOffering : [SELECT IMS_Legal_Entity__c, (SELECT IMS_Legal_Entity__c FROM IMS_Secondary_Data_Assets__r WHERE IMS_Legal_Entity__c <> null AND IMS_Legal_Entity__c <> '' AND is_Active__c = true) FROM IMS_Data_asset__c WHERE is_Active__c = true]){
			if(primaryOffering.IMS_Secondary_Data_Assets__r.size() > 0){
                for(IMS_Secondary_Data_Asset__c secondaryOffering : primaryOffering.IMS_Secondary_Data_Assets__r){
                    if(secondaryOffering?.IMS_Legal_Entity__c != null && secondaryOffering.IMS_Legal_Entity__c != '')
                        lstPickvals.add(secondaryOffering.IMS_Legal_Entity__c);
                }
            }else{
                if(primaryOffering?.IMS_Legal_Entity__c != null && primaryOffering.IMS_Legal_Entity__c != '')
            	    lstPickvals.add(primaryOffering.IMS_Legal_Entity__c);
            }
        }
        return JSON.serialize(lstPickvals);
    }

    public static List<String> getMailsToCompare(String emails){
        if(emails == null){
            return new List<String>();
        }
        List<String> emailList = emails.split(';');
        for(Integer i=0;i<emailList.size();i++){
            emailList[i] = emailList[i] + '%'; 
        }
        return emailList;
    }
    
    public static Integer countOfRecords {get{
        if(countOfRecords == null){
            String tpaRequestId = ApexPages.currentPage().getParameters().get('id');
            String query = 'Select count() From TPA_Commercial_Review__c where TPA_Request__c =: tpaRequestId';
            String viewMode = ApexPages.currentPage().getParameters().get('viewMode');
            List<String> actionNeededby,manualRevNames,reviewerEmails;
            if(viewMode != null && viewMode.contains('CSubmit')){
                actionNeededby = new List<String>{'Commercial Owner%','Mgmt%','Legal%'};
                String reviewerEmail = ApexPages.currentPage().getParameters().get('CSId');
                query += ' and Action_Needed_By__c like: actionNeededby and Receiver_s_Email__c != null ';
                List<String> tempcomRevEmail = reviewerEmail.split(';');
                if(tempcomRevEmail.size() == 1){
                    query += ' and Receiver_s_Email__c = \''+ reviewerEmail+'\'';
                }else{
                    query += 'and (';
                    for(String commercialID :tempcomRevEmail){
                        query += 'Receiver_s_Email__c like \'' + '%' + commercialID + '%\' AND ';
                    }
                    query = query.removeEnd('AND ');
                    query += ') ';
                }
            }
            else if(viewMode != null && viewMode.contains('TPSubmit')){
                actionNeededby = new List<String>{'TP-Country%'};
                String reviewerEmail = ApexPages.currentPage().getParameters().get('TPCountryId');
                query += ' and Action_Needed_By__c like: actionNeededby and TP_Country_Email__c != null ';
                query += ' and TP_Country_Email__c = \''+ reviewerEmail+'\'';
            }
            else if(viewMode != null && viewMode.contains('TPUS')){
                actionNeededby = new List<String>{'TP-US%'};
                String reviewerEmail = ApexPages.currentPage().getParameters().get('TPUSId');
                query += ' and Action_Needed_By__c like: actionNeededby and TP_US_Email__c != null ';
                query += ' and TP_US_Email__c = \''+ reviewerEmail+'\'';
            }
            else if(viewMode != null && viewMode.contains('MGMT')){
                manualRevNames = new List<String>{'Vendor Requires Secondary Review'};
                query += ' and Manual_Review_Reason__c =: manualRevNames ';
            }
            else if(viewMode != null && viewMode.contains('AMAAdmin')){
                manualRevNames = new List<String>{UTL_TPA.CLIENT_DOES_NOT_HAVE_AMA_AGREEMENT,UTL_TPA.CLIENTS_AMA_AGREEMENT_IS_EXPIRED};
                query += ' and Manual_Review_Reason__c =: manualRevNames ';
            }
            else if(viewMode != null && viewMode.contains('LGL')){
                manualRevNames = new List<String>{'IQVIA Legal Approval Required: New TPA - Ad-hoc Additional Term(s) / Exhibit Page(s) Requested','IQVIA Legal Approval Required: Prior TLLA had an Additional Term and/or Exhibit added and to be Renewed','IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested','IQVIA Legal Approval Required: [Renew] TPA: Ad-hoc Additional Term Requested'};
                query += ' and Manual_Review_Reason__c in: manualRevNames ';
            }
            
            countOfRecords = Database.countQuery(query);
        }
        return countOfRecords;
    } set;}

    public string tpaRequestId {get; set;}
    public static String comName;
    public string CSId {get; set;}
    public string viewMode {get; set;}
    public string TPCountryId {get; set;}
    public string TPUSId {get; set;}
    public string MGMTId {get; set;}
    public string LGLId {get;set;}
    public String AMAAdminId {get;set;}
    public string commercialOwnerName {get; set;}
    public static List<Id> resolvedComIds = new List<Id>();
    
    public String jsonData{get;set;}
    public String language{get;set;}
    
    public boolean isMessageShow { get; set; }
    public boolean isTPAPermanentDown { get; set; }
    public boolean isvalidVendorAccessCountry { get; set; }
    public boolean isPreAppTech { get; set; }
    public boolean isvalidVendorStorageCountry { get; set; }
    public boolean isvalidClientStorageCountry { get; set; }
    public boolean isAdditonalTermReviewApplicable {get; set; }
    public String title { get; set; }
    public static List<TPA_Request__c> requestsToUpdate = new List<TPA_Request__c>();
    public static boolean isSubmitThroughController = false;
    public boolean isTPProcessorLogin{
        get{
            if(isTPProcessorLogin == null){
                String viewMode = ApexPages.currentPage().getParameters().get('viewMode');
                if(viewMode == 'TPSubmit' || viewMode == 'TPUS')
                    return true;
                return false;
            }else
                return isTPProcessorLogin;
        }
        set;
    }
    public Static String permittedUseDefSummary {
        get{
            if(permittedUseDefSummary == null){
                List<TPA_Text_Editor__c> permittedUseDefSummaryList = [Select Content__c from TPA_Text_Editor__c where Page_Title__c = 'Alphabetical Summary of Permitted Use Definitions' AND Page_Type__c = 'Permitted Use Definitions Summary' AND Is_Active__c = true];
                if(permittedUseDefSummaryList != null && permittedUseDefSummaryList.size() > 0){
                    permittedUseDefSummary = permittedUseDefSummaryList[0].content__c;
                }
            }
            if(permittedUseDefSummary.contains('<p>')){
                permittedUseDefSummary = permittedUseDefSummary.replace('<p>','');
                permittedUseDefSummary = permittedUseDefSummary.replace('</p>','');
            }
            if(permittedUseDefSummary.contains('<div>')){
                permittedUseDefSummary = permittedUseDefSummary.replace('<div>','');
                permittedUseDefSummary = permittedUseDefSummary.replace('</div>','');
            }
            return permittedUseDefSummary;
        }
        set;
    }

    public Static String ComOwnnerChangeFormLink {
        get{
            if(ComOwnnerChangeFormLink == null){
                ComOwnnerChangeFormLink = TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_Com_Owner_Change_Request_Form&CSId=' + ApexPages.currentPage().getParameters().get('CSId');
            }
            return ComOwnnerChangeFormLink;
        }
        set;
    }


    public String Message { 
        get {
            String content = [Select Content__c from TPA_Text_Editor__c where Page_Title__c = 'Shutdown Message' AND Is_Active__c = true][0].Content__c;
            if(Message == null && content != null){
                Message = content;
            }else if(content == null){
                Message = Label.TPA_Downtime_Message;
            }
            return Message;
        }
        set; 
    }
    public static map<String, TPA_Text_Editor__C> mapOfIdWithTextEditorObjs {
        get {
            if(mapOfIdWithTextEditorObjs == null) {
                mapOfIdWithTextEditorObjs = new map<String, TPA_Text_Editor__C>();
                List<TPA_Text_Editor__c> listTPAText = new List<TPA_Text_Editor__c>();
                listTPAText = [SELECT Id, 
                               Name, 
                               Content__c, 
                               English_Translation__c, 
                               Japanese_Translation__c, 
                               Page_Name__c, 
                               Page_Title__c, 
                               Page_Type__c 
                               FROM TPA_Text_Editor__c where Page_Type__c = 'Commercial Review Reasons Types'];
                if(listTPAText.size() > 0){
                    for(TPA_Text_Editor__c bchRecordObj : listTPAText) {
                        mapOfIdWithTextEditorObjs.put(bchRecordObj.Page_Name__c , bchRecordObj);
                    }
                }
                
            }
            return mapOfIdWithTextEditorObjs;
        }
        private set{mapOfIdWithTextEditorObjs = value;}
    }
    public string getObjectMapOfIdWithTextEditorObj()
    {
        return JSON.serialize(mapOfIdWithTextEditorObjs);
    }
    public boolean isRestrictedUser { get; set; }
    public boolean TPA_Is_Show_TPA_Down_Message {get;set;}
    private static User CurrentUser = UTL_TPA_Multilingual.CurrentUser;
    public  List<AMA_Contract_Detail__c> amaContractListForOwnBehalf; 
    public static set<String> validClientNameSet = new Set<String>();
    public static string isQaTesting {get; set;}
    public boolean isSubmitButtonEnabled {get; set;}
    public static Boolean extensionRecCommercialReason {get{
        if(extensionRecCommercialReason == null){
            TPA_Master_Extension_Information__c extRecord = UTL_TPA.getExtensionRecOfVendorAddress(tpaRequestToEdit.Service_Provider_Address__c);
            if(extRecord != null){
                extensionRecCommercialReason = extRecord.Commercial_Reason__c;
            } 
            else{
                extensionRecCommercialReason = false;
            }
        }
        return extensionRecCommercialReason;
    } set;}


    /************
     Constructor
    *************/
    public CNT_TPA_CommercialReviewForm(ApexPages.StandardController stdController) {
        this();
    }
    public CNT_TPA_CommercialReviewForm() {
        isSubmitButtonEnabled = true;
        //Added for site to community logic submission start
        if(currentLoggedInUser.Profile.Name == 'tpa Profile') {
            return;
        }
        //Added for site to community logic submission end
        
        // perform initialization tasks
        tpaRequest = new TPA_Request__c();
        isMessageShow = UTL_TPA.isMessageShow;
        isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
        isAdditonalTermReviewApplicable = false;
        
        title = Label.TPA_Custom_Landing_Page_Title;
        //Message = Label.TPA_Downtime_Message;
        
        
            TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
            
            String restrictedUserIds = Label.TPA_Non_Restricted_Users;
            String currentUserId = String.valueOf(CurrentUser.Id).subString( 0, 15 );
            system.debug('restrictedUserIds:::'+restrictedUserIds.contains( currentUserId ));
            if( restrictedUserIds.contains( currentUserId )){
                isRestrictedUser = false; 
            }
            else if(isTPAPermanentDown){
                isRestrictedUser = true;
            }
            isQaTesting = ApexPages.currentPage().getParameters().get('isQaTesting');
            if(isTPAPermanentDown == true && isQaTesting == 'true'){
                isTPAPermanentDown=false;
                
            }
            else if (isTPAPermanentDown == true){
                isMessageShow = UTL_TPA.isMessageShow;
                isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
                
                title = Label.TPA_Custom_Landing_Page_Title;
                //Message = Label.TPA_Downtime_Message;
                TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
            }

    }

    //Added for site to community logic submission start

    public static User currentLoggedInUser {
        get {
            if(currentLoggedInUser == null) {
                return UTL_TPA.getCurrentUserDetails();
            }
            else {
                return currentLoggedInUser;
            }
        }
        set;
    }
    
    public static string currentUserProfileName {
        get {
            if(currentUserProfileName == null) {
                currentUserProfileName = currentLoggedInUser.Profile.Name;
            }
            return currentUserProfileName;
        }
        set;
    }
    
    public static string tpaCommunityUrl {
        get {
            if(tpaCommunityUrl == null && UTL_TPA.tpaSetting != null && !String.isEmpty(UTL_TPA.tpaSetting.TPA_Client_Community_Url__c)) {
                tpaCommunityUrl = UTL_TPA.tpaSetting.TPA_Client_Community_Url__c;
            }
            return tpaCommunityUrl;
        }
        set;
    }
    //Added for site to community logic submission end
    public static TPA_Request__c tpaRequestToEdit {
        get{
            string tpaRequestId;
            if(tpaRequestToEdit == null){
                if(!Test.isRunningTest()) {
                    tpaRequestId = ApexPages.currentPage().getParameters().get('id');
                }
                if(tpaRequestId != null) {
                    tpaRequestToEdit = getRequestInfo(tpaRequestId);
                }
            }
            return tpaRequestToEdit;
        }
        set;
    }
    
    private void getContractListForOwnBehalf() {
        
        if(amaContractListForOwnBehalf == null)
        {
            amaContractListForOwnBehalf = [Select id, Name, Client__c, Client_Services_On_Behalf_Of__c,Contract_End_Date__c,Contract_List_Type__c, Contract_Type__c, DBL__c,
                                           Max_Fee_Reached__c,Offshore_Storage__c,Offshore_Access__c,Special_Terms_And_Conditions__c From AMA_Contract_Detail__c
                                           Where Client_Services_On_Behalf_Of__c LIKE '%Own Behalf%'];
        }
    }
    
    private Map<String,List<AMA_Contract_Detail__c>> getOwnBehalfListForClient() {

        getContractListForOwnBehalf(); 
        Map<String,List<AMA_Contract_Detail__c>> ownBehalfListForClient = new Map<String,List<AMA_Contract_Detail__c>> ();
        if(amaContractListForOwnBehalf != null){

            for(AMA_Contract_Detail__c obj :amaContractListForOwnBehalf){

                String amaContractType =  obj.Contract_Type__c;
                List<AMA_Contract_Detail__c> contractDetailList;

                if(obj.Client__c != null && validClientNameSet.contains(obj.Client__c.toLowerCase())
                        && String.isNotBlank(amaContractType)){

                    if(ownBehalfListForClient.containsKey(amaContractType)){
                        contractDetailList = ownBehalfListForClient.get(amaContractType.toLowerCase());
                    }
                    else{
                        contractDetailList = new List<AMA_Contract_Detail__c>();
                    }
                    contractDetailList.add(obj);
                    ownBehalfListForClient.put(amaContractType.toLowerCase(),contractDetailList);
                }
            }
        }
        return ownBehalfListForClient;
    }
    
    public static AMA_Agreement_Detail__c amaAgreementDetail {
        get{
            if(tpaRequestToEdit != null){
                if(tpaRequestToEdit.AMA_Agreement_Details__r != null && tpaRequestToEdit.AMA_Agreement_Details__r.size() > 0){
                    return tpaRequestToEdit.AMA_Agreement_Details__r[0];
                }
            }
            return new AMA_Agreement_Detail__c();
        }
        set;
    }
    

    
    /*public static String amaLicenseRequired {
        get{
            if(amaLicenseRequired == null){
                if(tpaRequestToEdit != null) {
                    if(tpaRequestToEdit.AMA_USPrescriberData__c != null && tpaRequestToEdit.AMA_USPrescriberData__c.equalsIgnoreCase(UTL_TPA.YES)) {
                        amaLicenseRequired = 'Yes';
                    }
                    else if(tpaRequestToEdit.AMA_USPrescriberData__c != null && tpaRequestToEdit.AMA_USPrescriberData__c.equalsIgnoreCase(UTL_TPA.NO)){
                        amaLicenseRequired = 'No';
                    }
                }
            }
        return amaLicenseRequired;
        }
        set;
    }*/
    
  
    
    public static String vendorLegalName {
        get{
           
                if(tpaRequestToEdit != null) {
                    if(tpaRequestToEdit.AMA_Agreement_Details__r != null && tpaRequestToEdit.AMA_Agreement_Details__r.size() > 0 && tpaRequestToEdit.AMA_Agreement_Details__r[0].Vendor_Legal_Name__c != null) {
                        vendorLegalName = tpaRequestToEdit.AMA_Agreement_Details__r[0].Vendor_Legal_Name__c; 
                    }
                }
            return vendorLegalName;
        }
        set;
    }
    
    public static String employeeStoreDataCountry {
        get{
            if(employeeStoreDataCountry == null){
                if(tpaRequestToEdit != null) {
                    if(tpaRequestToEdit.AMA_Agreement_Details__r != null && tpaRequestToEdit.AMA_Agreement_Details__r.size() > 0) {
                        employeeStoreDataCountry = tpaRequestToEdit.AMA_Agreement_Details__r[0].Vendor_Employee_Store_Data_in_country__c; 
                    }
                }
            }
            return employeeStoreDataCountry;
        }
        set;
    }
    
    public static String employeeAccessDataCountry {
        get{
            if(employeeAccessDataCountry == null){
                if(tpaRequestToEdit != null) {
                    if(tpaRequestToEdit.AMA_Agreement_Details__r != null && tpaRequestToEdit.AMA_Agreement_Details__r.size() > 0) {
                        employeeAccessDataCountry = tpaRequestToEdit.AMA_Agreement_Details__r[0].Vendor_Employee_Accessed_Data_in_country__c; 
                    }
                }
            }
            return employeeAccessDataCountry;
        }
        set;
    }
    
    public static Map<String, TPA_Text_Editor__c> mapTpaTextAdditionalTerms {
        get{
            if(mapTpaTextAdditionalTerms == null && tpaRequestToEdit != null){
                mapTpaTextAdditionalTerms = new Map<String, TPA_Text_Editor__c>();
                Map<String, TPA_Text_Editor__c> mapTpaTextAdditionalTermsTemp = new Map<String, TPA_Text_Editor__c>();
                mapTpaTextAdditionalTermsTemp = UTL_TPA.getTpaTextAdditionalTerms(tpaRequestToEdit);
                if(mapTpaTextAdditionalTermsTemp != null){
                    for( String addKey : mapTpaTextAdditionalTermsTemp.keyset()) {
                        if(addKey.split(':')[1] == 'IMS_Legal_Entity__C'){
                            mapTpaTextAdditionalTerms.put(addKey,mapTpaTextAdditionalTermsTemp.get(addKey));
                        }
                    }
                }
            }
            return mapTpaTextAdditionalTerms;
        }
        private set{mapTpaTextAdditionalTerms = value;}
    }
    
    public string getObjectMapTpaTextAdditionalTerms()
    {
        return JSON.serialize(mapTpaTextAdditionalTerms);
    }
    
    public static Map<String, TPA_Additional_Term__c> mapTpaAdditionalTerms {
        get{
            if(mapTpaAdditionalTerms == null && tpaRequestToEdit != null){
                mapTpaAdditionalTerms = new Map<String, TPA_Additional_Term__c>();
                Map<String, TPA_Additional_Term__c> mapTpaAdditionalTermsTemp = new Map<String, TPA_Additional_Term__c>();
                mapTpaAdditionalTermsTemp = UTL_TPA.getTpaAdditionalTerms(tpaRequestToEdit);
                if(mapTpaAdditionalTermsTemp != null){
                    for( String addKey : mapTpaAdditionalTermsTemp.keyset()) {
                        if(addKey.split(':')[1] == 'Data Asset Specific Ad-Hoc Term' || addKey.split(':')[1] == 'Use Specific Ad-Hoc Terms' || addKey.split(':')[1] == 'Use/Offering Specific Ad-Hoc Terms'){
                            mapTpaAdditionalTerms.put(addKey,mapTpaAdditionalTermsTemp.get(addKey));
                        }
                    }
                }
            }
            return mapTpaAdditionalTerms;
        }
        private set{mapTpaAdditionalTerms = value;}
    }
    
    public string getObjectMapTpaAdditionalTerms()
    {
        return JSON.serialize(mapTpaAdditionalTerms);
    }
    
    public static Map<String , TPA_Offering_Notification_Mapping__c> mapTpaDynamicNotifications {
        get{
            if(mapTpaDynamicNotifications == null){
                mapTpaDynamicNotifications = new Map<String , TPA_Offering_Notification_Mapping__c>();
                if(tpaRequestToEdit != null){
                    TPA_Request__c tpaRequest =  [Select Id,Name,Service_Provider_Address__c,Vendor_Billing_Mailing_Country__c,is_LAAD_Response_Acknowledged__c, Is_VSN_Acknowlege_By_Client__c,(select id,IMS_Legal_Entity__c,Purpose__c,Purpose__r.Id from Purposes__r), (SELECT Id, TPA_Offering_Notification_Record__c, Type__c FROM TPA_Use_Offering_Atypical_Combinations__r WHERE Type__c = 'Offering Notification Record') From TPA_Request__c where Id =: tpaRequestToEdit.Id ];
                    mapTpaDynamicNotifications = UTL_TPA.getmapTpaDynamicNotifications(tpaRequest);
                }
            }
            return mapTpaDynamicNotifications;
        }
        private set{mapTpaDynamicNotifications = value;}
    }
    
    public string getObjectMapTpaDynamicNotifications()
    {
        return JSON.serialize(mapTpaDynamicNotifications);
    }
    

    
    /***************
     Public Methods
    ****************/
    public PageReference requestValidateOnLoad() {
        //Added for site to community logic submission start
        if(currentLoggedInUser.Profile.Name == 'tpa Profile') {
            return null;
        }
        //Added for site to community logic submission end

        tpaRequestId = ApexPages.currentPage().getParameters().get('id');
        List<TPA_Commercial_Review__c> totalComReasonsList = new List<TPA_Commercial_Review__c>();
        List<TPA_Commercial_Review__c> comReasonsList = new List<TPA_Commercial_Review__c>();
        CSId = ApexPages.currentPage().getParameters().get('CSId');
        viewMode = ApexPages.currentPage().getParameters().get('viewMode');
        TPCountryId = ApexPages.currentPage().getParameters().get('TPCountryId');
        TPUSId = ApexPages.currentPage().getParameters().get('TPUSId');
        AMAAdminId = ApexPages.currentPage().getParameters().get('AMAAdminId');
        MGMTId = ApexPages.currentPage().getParameters().get('MGMTId');
        LGLId = ApexPages.currentPage().getParameters().get('LGLId');
        
        if(tpaRequestId != null && !String.IsBlank(tpaRequestId))
        {
            // gets the vendor language selected at the time of request submit to be used in this page
            language = UTL_TPA_Multilingual.getLanguageForExistingRequests(tpaRequestId, 'v');
            Boolean formAlreadySubmitted = false;
            tpaCommercialReviewList = new Map<String, TPA_Commercial_Review__c>();
            commercialListToShow = JSON.serialize(new Map<String, TPA_Commercial_Review__c>());

            List<String> listEmailIds = new List<String>();                  
            tpaRequestToEdit = getRequestInfo(tpaRequestId);
            if(tpaRequestToEdit != null){
                isAuthorisedSigner = tpaRequestToEdit.TPA_Authorised_Signer__c;
                if(tpaRequestToEdit.AMA_USPrescriberData__c == 'Yes' && tpaRequestToEdit.AMA_Agreement_Details__r.size() > 0 && amaAgreementDetail != null){
                    if(amaAgreementDetail.Client_Employee_Store_Data_in_country__c != null ){
                        Set<String> offshoreAccessLocSet = new Set<String>();
                        List<String> Locations = new List<string>();
                        for(String CntType : getOwnBehalfListForClient().keySet()){
                            for(AMA_Contract_Detail__c conDetailObj : getOwnBehalfListForClient().get(CntType)) {
                                if(conDetailObj.Client__c != null && tpaRequestToEdit.Client_Address__r.Name.toLowerCase() == conDetailObj.Client__c.toLowerCase() && conDetailObj.Offshore_Storage__c != null){
                                    Locations = conDetailObj.Offshore_Storage__c.split(',');
                                    for(String strLoc : Locations){
                                        if(strLoc.indexOf('(ISO-3)') != -1)
                                            strLoc = strLoc.substringAfter('(ISO-3)');
                                        offshoreAccessLocSet.add(strLoc.trim());
                                    }
                                }
                                
                            }
                        }
                        System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
                        Set<String> offshoreLocationCountrySet = new Set<String>();
                        Set<String> vendorAccessCountrySet = new Set<String>();
                        
                        List<String> vendorAccessCountries = amaAgreementDetail.Client_Employee_Store_Data_in_country__c.split(';');
                        if(!offshoreAccessLocSet.isEmpty()) {
                            for(String locationCountry: offshoreAccessLocSet) {
                                if(SRV_TPA_AMAAgreementDetail.mapCountryCodeName.containsKey(locationCountry.toLowerCase())) {
                                    offshoreLocationCountrySet.add(SRV_TPA_AMAAgreementDetail.mapCountryCodeName.get(locationCountry.toLowerCase()));
                                }
                            }
                            system.debug('Offshore Country Location Set :-'+offshoreLocationCountrySet);
                            for(String country: vendorAccessCountries) {
                                if(SRV_TPA_AMAAgreementDetail.mapCountryCodeName.containsKey(country.toLowerCase()) && !country.equalsIgnoreCase('United States'))
                                    vendorAccessCountrySet.add(SRV_TPA_AMAAgreementDetail.mapCountryCodeName.get(country.toLowerCase()));
                            }
                            if(offshoreLocationCountrySet.containsAll(vendorAccessCountrySet)) {
                                isvalidClientStorageCountry = false;
                            }
                            else{
                                isvalidClientStorageCountry = true;
                            }
                        }
                        else{
                            isvalidClientStorageCountry = true;
                        }
                    }    
                    
                    if(amaAgreementDetail.Vendor_require_Remote_Access_from_NonUS__c != null && amaAgreementDetail.Vendor_require_Remote_Access_from_NonUS__c ==  'Yes' && amaAgreementDetail.Vendor_Employee_Accessed_Data_in_country__c != null){
                        for(String country: amaAgreementDetail.Vendor_Employee_Accessed_Data_in_country__c.split(';')){
                            if(!CNT_TPA_RequestSubmissionForm.approvedCountriesForRemoteAccess.contains(country.toLowerCase())){
                                isvalidVendorAccessCountry = true;
                            }
                        }
                        if(amaAgreementDetail.Technology_s_selected_for_remote_access__c != null && amaAgreementDetail.Technology_s_selected_for_remote_access__c.indexOf('Other') != -1){
                            isPreAppTech = true;
                        }
                    }
                    
                    if(amaAgreementDetail.Vendor_req_Storage_Permission_from_NonUS__c != null && amaAgreementDetail.Vendor_req_Storage_Permission_from_NonUS__c ==  'Yes' && amaAgreementDetail.Vendor_Employee_Store_Data_in_country__c != null){
                        if(!CNT_TPA_RequestSubmissionForm.ApprovedCountriesForStorage.contains(amaAgreementDetail.Vendor_Employee_Store_Data_in_country__c.toLowerCase())){
                            isvalidVendorStorageCountry = true;
                        }
                    } 
                    
                    
                }
            }
            
        }
        return null;
    }

    public string getObjectTpaRequestToEdit()
    {
        return JSON.serialize(tpaRequestToEdit);
    }
    
  

    public string getObjectTpaCommercialReviewList()
    {
        return JSON.serialize(tpaCommercialReviewList);
    }

    
    Public static List<IMS_Use_Offering_Atypical_Combination__c> secComReviewMasterListToUpdate = new List<IMS_Use_Offering_Atypical_Combination__c>();


    @remoteAction
    global static string saveRequest(string vendorDesConfirmatioSubmitObjDetail, string commercialName, string commercialEmailID, string tempcommercialEmailID)
    {
        permittedUseDefSummary = null;
        mapOfIdWithTextEditorObjs = null;
        mapTpaTextAdditionalTerms = null;
        mapTpaAdditionalTerms = null;
        mapTpaDynamicNotifications = null;
        isSubmitThroughController = true;
        Boolean isValidAMAFile = false;
        TPA_Request__c tpaRequest; 
        Set<id> comIds = new Set<id>();
        String tpProcessorEmail = '';
        comName = commercialName;
        
        
        Map<id, TPA_Commercial_Review__c> ComReviewMap = new Map<id, TPA_Commercial_Review__c>();
        List<TPA_Commercial_Review__c> comReviewListToUpdate = (List<TPA_Commercial_Review__c>)JSON.deserialize(vendorDesConfirmatioSubmitObjDetail, List<TPA_Commercial_Review__c>.class);
        System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
        if(comReviewListToUpdate.size() > 0){
            for(TPA_Commercial_Review__c review: comReviewListToUpdate){
                comIds.add(review.Id);
            }
        }
        
        
        
        Map<id,String> comIDWithLegalEntity = new Map<id,String>();
        
        Date dateOfResponse;
        List<id> lstIDs = new List<id>();
        List<id> lstAllCommID = new List<id>();
        Map<id, String> ComReviewIdWithAction = new Map<id, String>();
        
        //Set<String> futureApprovedComRevKeys = new Set<String>();
        String actionWithComments = '';
      
        string venodrLanguage;
        if(comReviewListToUpdate.size() >0) {
            tpaRequest = getRequestInfo(comReviewListToUpdate[0].TPA_Request__c);
            UTL_TPA_Multilingual.tpaReqObj = tpaRequest;
            venodrLanguage = UTL_TPA_Multilingual.getLanguageForExistingRequests(tpaRequest.id, 'v');
            for(TPA_Commercial_Review__c comReview: comReviewListToUpdate ) {
                comReview.Date_of_Action_Response__c = Date.today();
                dateOfResponse = comReview.Date_of_Action_Response__c;
                if(comReview.Action__c != null) {
                    lstAllCommID.add(comReview.Id);
                    if(comReview.Action__c == 'Questions / Comments' || comReview.Action__c == 'Potential Denial - Request TP Processor to arrange meeting with IQVIA Legal' || comReview.Action__c == 'No Valid AMA Agreement on File'){
                        tpProcessorEmail = comReview.TP_Country_Email__c;
                        lstIDs.add(comReview.Id);
                        }                   
                    } 
                    if(comReview.IMS_Legal_Entity__c != null){
                        system.debug('in if');
                        comIDWithLegalEntity.put(comReview.id, comReview.IMS_Legal_Entity__c);
                    }   
                    if(comReview.Action__c == 'Valid AMA Agreement on File'){
                        tpaRequest.AMA_Agreement_Details__r[0].Client_AMA_Manually_Validated__c = true;
                        isValidAMAFile = true;
                    }                       
            }
           
            
            try{
                if(isValidAMAFile){
                    update tpaRequest.AMA_Agreement_Details__r;
                    tpaRequest = SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(JSON.serialize(tpaRequest));
                    update tpaRequest;
                }
                isCommRevUpdate = true;
                Update comReviewListToUpdate;
                isCommRevUpdate = false;
            }
            catch(Exception e){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_CommercialReviewForm:::saveRequest', tpaRequest != null ? tpaRequest.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
            
           ComRevDataSubmission(JSON.serialize(lstIDs) ,JSON.serialize(lstAllCommID),JSON.serialize(tpaRequest),commercialName,commercialEmailID,JSON.serialize(dateOfResponse), JSON.serialize(SRV_TPA_TPARequest.primaryReviewsSubmission),JSON.serialize(resolvedComIds),tpProcessorEmail,tempcommercialEmailID,JSON.serialize(comIDWithLegalEntity));
           
            return ('success~'+'VFP_TPA_Page_Status?type=venOfferingReturnSubSuccess&lang='+venodrLanguage);
        }
        
        return 'error';
    }

    @future(callout=true)
    public static void ComRevDataSubmission(string lstIDs11, string lstAllCommID11, string tpaRequest11, string commercialName, string commercialEmailID, string dateOfResponse11, String isPriSub, string resolvedComIdList,String tpProcessorEmail, String tempcommercialEmailID,String comIDWithLegalEntity) {          
        List<id> lstIDs = (List<id>)JSON.deserialize(lstIDs11, List<id>.class);
        List<id> lstAllCommID = (List<id>)JSON.deserialize(lstAllCommID11, List<id>.class);
        TPA_Request__C tpaRequest = (TPA_Request__C)JSON.deserialize(tpaRequest11, TPA_Request__C.class);
        Date dateOfResponse = (Date)JSON.deserialize(dateOfResponse11, Date.class);
        SRV_TPA_TPARequest.primaryReviewsSubmission = (Boolean)JSON.deserialize(isPriSub, Boolean.Class);
        List<id> resolvedComIds = (List<id>)JSON.deserialize(resolvedComIdList, List<id>.class);
        Map<id,String> comIDWithLegalEntityMap = (Map<id,String>)JSON.deserialize(comIDWithLegalEntity, Map<id,String>.class);
        Map<String,String> uniqueSecCombwithOwnerMap = new Map<String,String>();
        Map<String,Boolean> secOwnerwithEmailSendingFlagMap = new Map<String,Boolean>();
        List<Id> secondaryOfferingIds = new List<Id>();
        Boolean secOfferingMailRequired = false;


        
        isSubmitThroughController = true;
        
        
        if(lstIDs != null && lstIDs.size() > 0 ){
            sendMailToTPProcessor(lstIDs, tpaRequest, commercialName, dateOfResponse,tpProcessorEmail, tempcommercialEmailID);
        }
        
        if(commercialEmailID != null){
            system.debug('before  sendMailToCommercialOwner');
            sendMailToCommercialOwner(lstAllCommID, tpaRequest, commercialName, commercialEmailID, dateOfResponse,tempcommercialEmailID);
        }

        if(resolvedComIds != null){
            SRV_TPA_TPARequest.tpaRequest = tpaRequest;
            SRV_TPA_TPARequest.multiRetriggerIds = resolvedComIds;
            if(!Test.isRunningTest()){
                SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
            }
            SRV_TPA_TPARequest.multiRetriggerIds = null;
        }

        List<TPA_Commercial_Review__c> secReviews = new List<TPA_Commercial_Review__c>();
        Boolean primaryAllCompleted = true;
        Boolean isReviewSecondary = false;
        Set<Id> reqWithSecondaryAddHocReviews = new Set<Id>();
        Set<Id> reqWithSecondaryOffReviews = new Set<Id>();
        Set<Id> reqWithVendorSecondaryReviews = new Set<Id>();
        Boolean isTLLACallSent = false;
        Boolean removeStopGenerationFlag = false;
        
        
        List<TPA_Commercial_Review__c> secondaryOffReviewsToUpdate = new List<TPA_Commercial_Review__c>();
        List<TPA_Data_Asset__c> OtheroffListTobeUpdated = new List<TPA_Data_Asset__c>();

        Map<String,TPA_Data_Asset__c> otherDataAssetsKeyMap = new Map<String,TPA_Data_Asset__c>();

        for(TPA_Data_Asset__c tpaDa : [Select Id,Request__c,Asset_Name__c,BU__c,Geo_Level__c,A_Column_Use_For_Template__c,Purpose__r.Name,Purpose__r.Purpose_Category_Name__c,IMSLegalEntity__c,IMS_Legal_Entity_for_Other__c From TPA_Data_Asset__c where Asset_Name__c like '%Other%' and (IMSLegalEntity__c = null and IMS_Legal_Entity_for_Other__c = null) and Request__c =: tpaRequest.id]){
            otherDataAssetsKeyMap.put((TGRH_TPA_Commercial_Review.createKeyDataAsset(tpaDa)),tpaDa);
        }
        
        List<TPA_Request__c> reqDetailsWithReviews = [Select Id,is_Bulk_TPA_Request__c,Is_Exhibit_Required__c,Name,Manual_Trigger_Reasons__c,Is_South_Africa_Sub_Off__c,Is_Vendor_Name_Contains_DeepIntent__c,Is_Vendor_Name_Contains_Edith__c,
                                                      Is_Vendor_Related_to_Source_Symphony_Acc__c,is_20_or_more_Offering_Present__c,Is_Vendor_Name_Contains_MedPro__c,
                                                      is_Specific_Vendors_LAAD_Off__c,is_Specific_Vendors_APLD_Off__c,is_Specific_Vendors_Long_Prescr_Data__c,is_Specific_Vendors_Medical_Claims_Data__c,
                                                      Data_Period_Start_Date__c,Data_Period_End_Date__c,Client_Project_Name__c,Client_Address__r.Name,Is_Manually_Approved__c,
                                                      Data_Access_Start_Date__c,Data_Access_End_Date__c,Parent_Request__c,Parent_Request__r.Name,Parent_Request__r.Renewed_As__c,
                                                      Is_Partially_Renewed__c,Vendor_Website__c,AMA_USPrescriberData__c,TPA_Processor_Contact__r.Name,Parent_Request__r.Is_Renewed__c,
                                                      Service_Provider_Address__r.Name,Client_Address__c,Service_Provider_Address__c,AMA_Agreement_required__c,Vendor_App_Submitted__c,
                                                      TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__r.Is_Active__c,
                                                      Co_Assigned_Global_TP_Processor__r.Initials__c,Requires_Manual_Review__c,TP_Processor_Email__c,vendor_language__c,TLLA_Batch_Call_Sent_On__c,
                                                      Request_Status__c,Is_VSN_Acknowlege_By_Client__c,isClientOnComplianceHold__c,isVendorOnComplianceHold__c,Is_Potential_Vendor_Case__c,
                                                      isLegalEntityPresent__c,Pending_Acknowledgements__c,(Select Id,Status__c,Last_Reminder_Sent_Date__c,Manual_Review_Reason__c,Associated_Use_to_Review__c,Associated_Offering_s_Use_Category_s__c,Associated_Offering_Category__c,BU__c,Associated_Offering_to_Review__c,TPA_Request__c,Is_Review_Secondary__c,Receiver_s_Email__c from TPA_Commercial_Reviews__r  order by Is_Review_Secondary__c desc),
                                                      (select id, name, CreatedDate from Attachments order by createddate desc),(Select Id,AMA_Manual_Review__c,Is_AMA_License_Required__c From AMA_Agreement_Details__r)
                                                      
                                                      from TPA_Request__c where Id =: tpaRequest.Id];
        
        for(TPA_Request__c reqObj : reqDetailsWithReviews){
            boolean isholdCase = false;
            boolean allCompleted = true;
            for(TPA_Commercial_Review__c comRev : reqObj.TPA_Commercial_Reviews__r){
                isReviewSecondary = false;
                if(comRev.Manual_Review_Reason__c.contains('Vendor Requires Secondary Review') || comRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review') || comRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by') || comRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')
                   ||UTL_TPA.isManualReviewAddHoc(comRev.Manual_Review_Reason__c) ){
                       isReviewSecondary = true;
                       secReviews.add(comRev);
                   }
                if(comRev.Is_Review_Secondary__c && comRev.Status__c == 'Awaiting to Send: Primary Commercial Owner Not Complete' && !TGRH_TPA_Commercial_Review.isComRevApproved(comRev.Status__c) ){
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
                
                if(comRev.Status__c == null || ! TGRH_TPA_Commercial_Review.isComRevApproved(comRev.Status__c)){
                    allCompleted = false;
                }
                if(comRev.Manual_Review_Reason__c != null && (comRev.Manual_Review_Reason__c.contains('offshore') || comRev.Manual_Review_Reason__c.contains('Other Use Selected')) && (comRev.Status__c != null && (comRev.Status__c.contains('Combination Approved') || comRev.Status__c.contains('Combination Approved and Future Approved') || comRev.Status__c.contains('Complete')))){
                    isholdCase = true;
                }                
                if(comRev.Status__c == null || (!isComRevApproved(comRev.Status__c) && !isReviewSecondary)){
                    primaryAllCompleted = false;
                }   
                if(comIDWithLegalEntityMap.containsKey(comRev.Id) && otherDataAssetsKeyMap.get(TGRH_TPA_Commercial_Review.createKeyComRev(comRev)) != null){
                    system.debug('in if **');
                    OtheroffListTobeUpdated.add(new TPA_Data_Asset__c(id = otherDataAssetsKeyMap.get(TGRH_TPA_Commercial_Review.createKeyComRev(comRev)).Id, IMS_Legal_Entity_for_Other__c = comIDWithLegalEntityMap.get(comRev.Id)));
                }                             
            }
			
			if(otherDataAssetsKeyMap != null && otherDataAssetsKeyMap.keySet() != null && otherDataAssetsKeyMap.keySet().size() > 0 && OtheroffListTobeUpdated != null && otherDataAssetsKeyMap.keySet().size() == OtheroffListTobeUpdated.size()){
                reqObj.Stop_TLLA_Generation_Notice_Sent_Date__c = null ;
                removeStopGenerationFlag = true;
            }

            
            for(TPA_Commercial_Review__c comRev : secReviews){
                if(comRev.Status__c != 'Awaiting to Send: Primary Commercial Owner Not Complete'){
                    continue;
                }
                if(reqObj.Is_Exhibit_Required__c && !isComRevApproved(comRev.Status__c) && primaryAllCompleted && SRV_TPA_TPARequest.primaryReviewsSubmission && UTL_TPA.isManualReviewAddHoc(comRev.Manual_Review_Reason__c)){
                    comRev.Status__c = 'Awaiting Review';
                    secondaryOffReviewsToUpdate.add(comRev);
                    reqWithSecondaryAddHocReviews.add(reqObj.Id);
                }
                if(comRev.Manual_Review_Reason__c.contains('Vendor Requires Secondary Review')){
                    if(!isComRevApproved(comRev.Status__c) && primaryAllCompleted && SRV_TPA_TPARequest.primaryReviewsSubmission){
                        comRev.Status__c = 'Awaiting Review';
                        secondaryOffReviewsToUpdate.add(comRev);
                        reqWithVendorSecondaryReviews.add(reqObj.Id);
                    }
                }
                if(comRev.Manual_Review_Reason__c.contains('Offering Requires Secondary Commercial Review')){
                    if(!isComRevApproved(comRev.Status__c) && comRev.Status__c != 'Awaiting Review' && (secOwnerwithEmailSendingFlagMap.get(comRev.Receiver_s_Email__c) == true || primaryAllCompleted) && SRV_TPA_TPARequest.primaryReviewsSubmission){

                        comRev.Status__c = 'Awaiting Review';
                        secondaryOffReviewsToUpdate.add(comRev);
                        reqWithSecondaryOffReviews.add(reqObj.Id);
                        if(!primaryAllCompleted){
                            comRev.Last_Reminder_Sent_Date__c = Date.today();
                            secondaryOfferingIds.add(comRev.Id);
                            secOfferingMailRequired = true;
                            SRV_TPA_TPARequest.secOfferingMailRequired = true;
                        }
                        else if(primaryAllCompleted){
                            comRev.Last_Reminder_Sent_Date__c = null;
                            SRV_TPA_TPARequest.secOfferingMailRequiredPrimAllCompleted = true;
                        }
                    }
                }
                if((comRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by') || comRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by'))){
                    if(!isComRevApproved(comRev.Status__c) && comRev.Status__c != 'Awaiting Review' && (secOwnerwithEmailSendingFlagMap.get(comRev.Receiver_s_Email__c) == true || primaryAllCompleted) && SRV_TPA_TPARequest.primaryReviewsSubmission){
                        comRev.Status__c = 'Awaiting Review';
                        secondaryOffReviewsToUpdate.add(comRev);
                        reqWithSecondaryOffReviews.add(reqObj.Id);
                        if(!primaryAllCompleted){
                            comRev.Last_Reminder_Sent_Date__c = Date.today();
                            secondaryOfferingIds.add(comRev.Id);
                            secOfferingMailRequired = true;
                            SRV_TPA_TPARequest.secOfferingMailRequired = true;
                        }
                        else if(primaryAllCompleted){
                            comRev.Last_Reminder_Sent_Date__c = null;
                            SRV_TPA_TPARequest.secOfferingMailRequiredPrimAllCompleted = true;
                        }
                    }
                }
            }

            
            Boolean amaManualReview = (reqObj.AMA_Agreement_Details__r != null && !reqObj.AMA_Agreement_Details__r.isEmpty()) ? reqObj.AMA_Agreement_Details__r[0].AMA_Manual_Review__c : false;
            if(allCompleted && !isholdCase ){                
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
                   
                    
                    if(reqObj.Attachments.size() > 0 && TGRH_TPA_Commercial_Review.checkIfAllDocsAreGenerated(reqObj.Attachments,isAMADocReq,reqObj.Vendor_App_Submitted__c)  && !amaManualReview){
                        if((futureApprovedComRevKeys != null && futureApprovedComRevKeys.size() > 0) || (addHocTermsToUpdate != null && addHocTermsToUpdate.size() > 0) && reqObj.is_Bulk_TPA_Request__c){
                            isTLLACallSent = true;
                            QBL_TPA_UpdateFutureApprovalAction updateFutureApprovalAction = new QBL_TPA_UpdateFutureApprovalAction();
                            updateFutureApprovalAction.request = tpaRequest;
                            updateFutureApprovalAction.commReviewKeys = futureApprovedComRevKeys;
                            updateFutureApprovalAction.addTermToUpdate = addHocTermsToUpdate;
                            updateFutureApprovalAction.sendTLLAForSign = true;
                            if(!Test.isRunningTest()){
                                System.enqueueJob(updateFutureApprovalAction);
                            }
                        }
                        else{
                            TGRH_TPA_Commercial_Review.sendForDocuSign(reqObj.Id);
                        }
                        
                    }
                }
                
                requestsToUpdate.add(reqObj);
                TGRH_TPA_Commercial_Review.sendEmailToTpProcessor(reqObj, amaManualReview);
            }
            
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
                TGRH_TPA_Commercial_Review.sendEmailToTpProcessor(reqObj, amaManualReview);
            }
			else if(removeStopGenerationFlag){
                requestsToUpdate.add(reqObj);
            }

            if(!isTLLACallSent && ((futureApprovedComRevKeys != null && futureApprovedComRevKeys.size() > 0) || (addHocTermsToUpdate != null && addHocTermsToUpdate.size() > 0)) && reqObj.is_Bulk_TPA_Request__c){
                QBL_TPA_UpdateFutureApprovalAction updateFutureApprovalAction = new QBL_TPA_UpdateFutureApprovalAction();
                updateFutureApprovalAction.request = tpaRequest;
                updateFutureApprovalAction.commReviewKeys = futureApprovedComRevKeys;
                updateFutureApprovalAction.addTermToUpdate = addHocTermsToUpdate;
                updateFutureApprovalAction.sendTLLAForSign = false;
                if(!Test.isRunningTest()){
                    System.enqueueJob(updateFutureApprovalAction);
                }

            }

          
            if(secondaryOffReviewsToUpdate != null && secondaryOffReviewsToUpdate.size()>0){
                UTL_TPA.isSecondaryReviewUpdate = true;
                update secondaryOffReviewsToUpdate;
                UTL_TPA.isSecondaryReviewUpdate = false;
            }

            if((reqWithVendorSecondaryReviews != null && reqWithVendorSecondaryReviews.size()>0)
            || (reqWithSecondaryOffReviews != null && reqWithSecondaryOffReviews.size()>0)
            || (reqWithSecondaryAddHocReviews != null && reqWithSecondaryAddHocReviews.size()>0)){
                SRV_TPA_TPARequest.tpaRequest = reqObj;
                if(secOfferingMailRequired && secondaryOfferingIds != null && secondaryOfferingIds.size()>0){
                    SRV_TPA_TPARequest.multiRetriggerIds = secondaryOfferingIds;
                }
                SRV_TPA_TPARequest.isSecComReview = true;
                SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
                SRV_TPA_TPARequest.multiRetriggerIds = null;

            }
      
        }
		try {
        if(OtheroffListTobeUpdated != null && OtheroffListTobeUpdated.size() > 0){
            Update OtheroffListTobeUpdated;
        }
        
        if(requestsToUpdate.size() > 0){
            update requestsToUpdate;
        }
		}catch(Exception exp) {
                        UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::CNT_TPA_CommercialReviewForm:::saverequest', ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                    }
		
    }

    public static Boolean isComRevApproved(String status){
        if(status != null && !status.contains('Combination Approved') && !status.contains('Combination Approved and Future Approved') && status != 'Complete' ){
            return false;
        }
        return true;
    }

    public class CommercialReviewWrapper{
        public TPA_Commercial_Review__c comRev;
        public Id attachmentId;
    }
    
    @remoteAction
    public static  List<CommercialReviewWrapper> getRelatedComList(Id tpaRequestId,string CSId,string viewMode,string TPCountryId,string TPUSId,string MGMTId, String lastRecId){

        if(tpaRequestId != null && !String.IsBlank(tpaRequestId))
        {            
            Boolean formAlreadySubmitted = false;
            transient List<TPA_Commercial_Review__c> comReasonsList = new List<TPA_Commercial_Review__c>();
            List<String> listEmailIds = new List<String>();
            //otherCommercialReviewLgl = new Map<String,String>();
            List<TPA_Commercial_Review__c> totalComReasonsList = new List<TPA_Commercial_Review__c>();
            List<String> manualRevNames;
            List<String> actionNeededby,reviewerEmails;
            system.debug('lastRecId: ' + lastRecId);
            String query = 'select Id, Commercial_Owner_Name__c,Temporary_Reviewer_s_Email__c, BU__c, Is_ReviewForm_Acknowledged__c, Associated_Offering_s_Use_Category_s__c,Associated_Offering_to_Review__c, Associated_Use_to_Review__c, Associated_Offering_Category__c, Manual_Review_Reason__c, Receiver_s_Email__c, Action_Needed_By__c, TPA_Request__c, Action__c, Status__c, TP_US_Email__c, Date_of_Action_Response__c, Additional_Questions_For_TP_Processor__c, TP_Country_Email__c, Additional_Text_For_Potential_Denial__c, Comment_For_Under_Validation__c, Sec_Review_Master__c,Primary_Data_Asset__c,Primary_Data_Asset__r.Asset_NametText__c,Primary_Data_Asset__r.IMSLegalEntity__c,Primary_Data_Asset__r.IMS_Legal_Entity_for_Other__c,TPA_Additional_Term__r.Name,TPA_Additional_Term__r.Term_Name__c,TPA_Additional_Term__r.Addtional_Term__c,TPA_Additional_Term__r.Category__c,TPA_Additional_Term__r.TPA_Legal_Entity_1__c,TPA_Additional_Term__r.CreatedDate,TPA_Additional_Term__r.LastModifiedDate,TPA_Additional_Term__r.Is_Future_Approved__c,TPA_Additional_Term__c,IMS_Legal_Entity__c from TPA_Commercial_Review__c where TPA_Request__c = : tpaRequestId';

            if(viewMode != null && viewMode.contains('CSubmit')){
                actionNeededby = new List<String>{'Commercial Owner%','Mgmt%','Legal%'};
                query += ' and Action_Needed_By__c like: actionNeededby and Receiver_s_Email__c != null ';
                List<String> tempcomRevEmail = CSId.split(';');
                if(tempcomRevEmail.size() == 1){
                    query += ' and Receiver_s_Email__c =: CSId';
                }else{
                    query += 'and (';
                    for(String commercialID :tempcomRevEmail){
                        query += 'Receiver_s_Email__c like \'' + '%' + commercialID + '%\' AND ';
                    }
                    query = query.removeEnd('AND ');
                    query += ') ';
                }
            }
            else if(viewMode != null && viewMode.contains('TPSubmit')){
                actionNeededby = new List<String>{'TP-Country%'};
                query += ' and Action_Needed_By__c like: actionNeededby and TP_Country_Email__c != null ';
                query += ' and TP_Country_Email__c =: TPCountryId';
            }
            else if(viewMode != null && viewMode.contains('TPUS')){
                actionNeededby = new List<String>{'TP-US%'};
                query += ' and Action_Needed_By__c like: actionNeededby and TP_US_Email__c != null ';
                query += ' and TP_US_Email__c =: TPUSId';
            }
            else if(viewMode != null && viewMode.contains('MGMT')){
                manualRevNames = new List<String>{'Vendor Requires Secondary Review'};
                query += ' and Manual_Review_Reason__c =: manualRevNames ';
            }
            else if(viewMode != null && viewMode.contains('LGL')){
                manualRevNames = new List<String>{'IQVIA Legal Approval Required: New TPA - Ad-hoc Additional Term(s) / Exhibit Page(s) Requested','IQVIA Legal Approval Required: Prior TLLA had an Additional Term and/or Exhibit added and to be Renewed','IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested','IQVIA Legal Approval Required: [Renew] TPA: Ad-hoc Additional Term Requested'};
                query += ' and Manual_Review_Reason__c in: manualRevNames ';
            }else if(viewMode != null && viewMode.contains('AMAAdmin')){
                manualRevNames = new List<String>{UTL_TPA.CLIENT_DOES_NOT_HAVE_AMA_AGREEMENT,UTL_TPA.CLIENTS_AMA_AGREEMENT_IS_EXPIRED};
                query += ' and Manual_Review_Reason__c in: manualRevNames ';
            }

            // if(tempID != null && tempID != ''){
            //     query += ' and (';
            //     List<String> tempIds = tempID.split(';');
            //     for(String comIDTemp : tempIds){
            //         query += ' Temporary_Reviewer_s_Email__c like \'%' + comIDTemp + '%\' AND';
            //     }
            //     query = query.removeEnd(' AND');
            //     query += ') ';
            // }
            
            query += ((lastRecId != null  && lastRecId.length() > 1) ? ' and Id >: lastRecId ' : '') + ' order by Id ASC Limit ' + String.valueOf(pageSize);
            
            System.debug(query);
            totalComReasonsList = Database.query(query);
            Set<Id> adHocIds = new Set<id>();
            for(TPA_Commercial_Review__c comRev: totalComReasonsList){
                if(comRev.TPA_Additional_Term__c != null){
                    adHocIds.add(comRev.TPA_Additional_Term__c);
                }
            }
            Map<Id,TPA_Additional_Term__c> addTermsWithAttachments = new Map<Id,TPA_Additional_Term__c>([Select Id,(Select Id From Attachments order by CreatedDate DESC Limit 1) From TPA_Additional_Term__c where Id in: adHocIds]);

            List<CommercialReviewWrapper> listToReturn = new List<CommercialReviewWrapper>();

            for(TPA_Commercial_Review__c comRev: totalComReasonsList){
                CommercialReviewWrapper comRevWrap = new CommercialReviewWrapper();
                comRevWrap.comRev = comRev;
                if(comRev.TPA_Additional_Term__c != null && addTermsWithAttachments != null && addTermsWithAttachments.get(comRev.TPA_Additional_Term__c) != null && addTermsWithAttachments.get(comRev.TPA_Additional_Term__c).Attachments != null && addTermsWithAttachments.get(comRev.TPA_Additional_Term__c).Attachments.size() > 0 ){
                    comRevWrap.attachmentId = addTermsWithAttachments.get(comRev.TPA_Additional_Term__c).Attachments[0].Id;
                    system.debug(comRevWrap.attachmentId);
                }
                if(viewMode != null && viewMode.contains('CSubmit')){
                    List<String> tempcomRevEmail = comRev.Receiver_s_Email__c.split(';');
                    tempcomRevEmail.sort();
                    String comRevEmail = string.join(tempcomRevEmail,';');
                    if(comRevEmail.equalsIgnoreCase(CSId)){
                        listToReturn.add(comRevWrap);
                    }
                }else{
                    listToReturn.add(comRevWrap);
                }
                
            }
            if(listToReturn.size() > 0) {
                return listToReturn;
            }
           return null;                        
        }
        return null;
    }

    public static String baseURL{
        get {
            return UTL_TPA.TPA_ClientCOM_URL; 
        }
        set;
    }

    public static String createKeyDataAsset(TPA_Data_Asset__c tpaDa){
        String Key = '';
        Key+= tpaDa.A_Column_Use_For_Template__c + ';';
        Key+= tpaDa.Purpose__r.Purpose_Category_Name__c + ';';
        Key+= tpaDa.Geo_Level__c + ';';
        Key+= tpaDa.BU__c + ';';
        if(tpaDa.Asset_Name__c != null && tpaDa.Asset_Name__c.contains(':')){
            Key+= tpaDa.Asset_Name__c.split(':')[0];
        }
        else{
            Key+= tpaDa.Asset_Name__c;
        }
        return Key;
    }
    
   
    public static void sendMailToTPProcessor(List<id> lstIDs, TPA_Request__C tpaRequest, String commOwnerName, Date dateOfResponse, String tpProcessorEmail, String tempcommercialEmailID) 
    {
        List<TPA_Commercial_Review__c> ListOfComReviwer = [select id,Commercial_Owner_Name__c, Manual_Review_Reason__c,TP_US_Email__c, Receiver_s_Email__c,BU__c,Associated_Offering_s_Use_Category_s__c,Associated_Offering_to_Review__c,Associated_Use_to_Review__c,Action__c,TP_Country_Email__c,Additional_Questions_For_TP_Processor__c,Additional_Text_For_Potential_Denial__c,Comment_For_Under_Validation__c from TPA_Commercial_Review__c where id IN : lstIDs];
        String subjText = '';
        String bodyText = '';
        String tableText = '';
        String TPProcessorName = '';
        Set<String> LstOfTPProcessor = new set <String>();
        Set<String> LstOfReviewer = new set <String>();
        Boolean isManagementEmail = false;
        Boolean isAMAAdminMail = false ;        
        

        for(TPA_Commercial_Review__c comReview: ListOfComReviwer){
            if((comReview.Manual_Review_Reason__c == UTL_TPA.CLIENTS_AMA_AGREEMENT_IS_EXPIRED || comReview.Manual_Review_Reason__c ==  UTL_TPA.CLIENT_DOES_NOT_HAVE_AMA_AGREEMENT) && (comReview.Action__c == 'Questions / Comments' ||  comReview.Action__c == 'No valid AMA Agreement on File') ){
                isAMAAdminMail = true;
            }
            if(comReview.Manual_Review_Reason__c == 'Vendor Requires Secondary Review'){
                isManagementEmail = true;
            }
            TPProcessorName = comReview.TP_Country_Email__c != null ? comReview.TP_Country_Email__c : comReview.TP_US_Email__c;
            if(commOwnerName == null || commOwnerName == '' ){
                commOwnerName = comReview.Commercial_Owner_Name__c;
            }
            if(comReview.TP_Country_Email__c != null && comReview.TP_Country_Email__c != ''){
                    LstOfTPProcessor.add(comReview.TP_Country_Email__c);
             }
             if(comReview.TP_US_Email__c != null && comReview.TP_US_Email__c != ''){
                    LstOfTPProcessor.add(comReview.TP_US_Email__c);
              } 
             if(comReview.Receiver_s_Email__c != ''){
                    for(String reviewerEmail : comReview.Receiver_s_Email__c.split(';')){
                    	LstOfReviewer.add(reviewerEmail);
                	}
             }            
        }

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
        
        
        subjText = 'Action Required: ('+ tpaRequest.Name+ ') '+(isManagementEmail ? 'Management Reviewer' : (isAMAAdminMail ? 'Client AMA Administrator' : 'Commercial Review'))+' Response Needs Attention  ' ; 
        
        bodyText += '<div style = "font-size : 13px; font-family: arial;"><B>Good day ' + (isAMAAdminMail ? UTL_TPA.TPUSEMailAddress : TPProcessorName) + ',</B></div> ';
        bodyText += '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">' + tpaRequest.Name + ' has been reviewed and the '+ (isManagementEmail ? 'Management Reviewer' : (isAMAAdminMail ? 'Client AMA Administrator has either responded No Valid Agreement on File or Questions/Comments' : 'Commercial Review has either Additional Questions or a Potential Denial')) +'.  Please see details of their response below and take Action as necessary.';
        
        bodytext += '<br>';
        bodytext += '<br><B>Client Company: </B>'+tpaRequest.Client_Address__r.Name;
        bodytext += '<br><B>Status: </B>' + tpaRequest.Request_Status__c;
        bodytext += '<br><B>Third Party Company: </B>'+tpaRequest.Service_Provider_Address__r.Name;
        if(tpaRequest.Vendor_Website__c != null){
            bodytext += '<br><B>Vendor Website & Network Id: </B>'+tpaRequest.Vendor_Website__c;
        }
        
        bodytext += '<br><B>Client Project Name: </B>'+((tpaRequest.Client_Project_Name__c == null)? '':tpaRequest.Client_Project_Name__c);
        bodytext += '<br><B>Project start and end date: </B>'+ startDate + ', ' + endDate;
        
        if(tpaRequest.AMA_USPrescriberData__c != null && tpaRequest.AMA_USPrescriberData__c.equalsIgnoreCase(UTL_TPA.YES) && SRV_TPA_AMAAgreementDetail.amaAgreementDetails != null) {
            bodytext += '<br><B>AMA Project Use(s): </B>'+ ((SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_Services_Provided__c  == null || SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_Services_Provided__c  == '') ? '' : SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_Services_Provided__c.replace(';', ', '));
            bodytext += '<br><B>AMA Variables Requested: </B>'+ ((SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_TypeOfPrescriberLevelData__c   == null || SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_TypeOfPrescriberLevelData__c   == '') ? '' : SRV_TPA_AMAAgreementDetail.amaAgreementDetails.AMA_TypeOfPrescriberLevelData__c.replace(';', ', '));
            
        }
        
        bodytext += '<br><table style="border-collapse: collapse;font-size:13px;font-family:arial;border:1px solid black;">';
        bodytext += '<tr><td style="width:25%;border:1px solid black;font-size:13px;font-family:arial;padding: 5px 5px 5px 5px;"><b>'+(isManagementEmail ? 'Management Reviewer' : (isAMAAdminMail ? 'Client AMA Administrator' : 'Commercial Review'))+' Name:</b> </td><td style="width:25%;border:1px solid black;font-size:13px;font-family:arial;padding: 5px 5px 5px 5px;">'+ commOwnerName +'</td></tr>';
        bodytext += '<tr><td style="width:25%;border:1px solid black;font-size:13px;font-family:arial;padding: 5px 5px 5px 5px;"><b>Date of Review: </b></td><td style="width:25%;border:1px solid black;font-size:13px;font-family:arial;padding: 5px 5px 5px 5px;">'+ Datetime.newInstance(dateOfResponse.year(), dateOfResponse.month(), dateOfResponse.day()).format('yyy-MM-dd')  +'</td></tr>';
        bodytext += '</table><br>';
        
        bodytext += '<br> TABLE_TEXT';
        tableText += '<table style="border-collapse: collapse;font-size:13px;font-family:arial;border:1px solid black;">';
        tableText += '<tr><th style="padding: 0px 5px 0px 5px;border:1px solid black;font-size:13px;font-family:arial;">Manual Review Reason</th> ';
        if(!isAMAAdminMail){
            tableText += (isManagementEmail ? '': '<th style="padding: 0px 5px 0px 5px;border:1px solid black;font-size:13px;font-family:arial;">Country of Offering</th>') + ' <th style="padding: 0px 5px 0px 5px;border:1px solid black;font-size:13px;font-family:arial;">Associated Offering(s) to Review</th><th style="padding: 0px 5px 0px 5px;border:1px solid black;font-size:13px;font-family:arial;">Associated Offering(s) Use(s) Requested</th>';
        }  
        tableText += '<th style="padding: 0px 5px 0px 5px;border:1px solid black;font-size:13px;font-family:arial;">'+(isManagementEmail ? 'Management Reviewer' : (isAMAAdminMail ? 'Client AMA Administrator Response' : 'Commercial Review Decision')) +' </th>';
        
        String style = 'style = "border: 1px solid black;padding: 0 5px 0 5px;"';
        
        String useName = '';
        String offreingName = '';
        String comOwnerDecision = '';
        String actionWithComments = '';
        String countryOfOffering = '';
        for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
            actionWithComments = '';
            useName = comRev.Associated_Use_to_Review__c != null ? comRev.Associated_Use_to_Review__c : '';
            offreingName = comRev.Associated_Offering_to_Review__c != null ? comRev.Associated_Offering_to_Review__c : '';
            comOwnerDecision = '';
            countryOfOffering = comRev.BU__c;
            if(comRev.Action__c == 'Questions / Comments'){
                actionWithComments = comRev.Action__c + (comRev.Additional_Questions_For_TP_Processor__c != null ? (': ' + comRev.Additional_Questions_For_TP_Processor__c) : '');
            }
            else if(comRev.Action__c == 'Potential Denial - Request TP Processor to arrange meeting with IQVIA Legal'){
                actionWithComments = comRev.Action__c + (comRev.Additional_Text_For_Potential_Denial__c != null ? (': ' + comRev.Additional_Text_For_Potential_Denial__c) : '');
            }
            else if(comRev.Action__c == 'Under Validation'){
                actionWithComments = comRev.Action__c + (comRev.Comment_For_Under_Validation__c != null ? (': ' + comRev.Comment_For_Under_Validation__c) : '');
            }
            else{
                actionWithComments = comRev.Action__c;
            }
            comOwnerDecision = actionWithComments;
            
            tableText += '<tr>';
            tableText += '<td ' + style + '>' + comRev.Manual_Review_Reason__c + '</td>';
            if(!isAMAAdminMail){
                tableText += (isManagementEmail? '': '<td '+ style +'>' + countryOfOffering + '</td>');
                tableText += '<td ' + style + '>' + offreingName + '</td>';
                tableText += '<td ' + style + '>' +  useName  + '</td>';
            }
            tableText += '<td ' + style + '>' + comOwnerDecision + '</td>';
            tableText += '</tr>';
        }
        
        
        tableText += '</table>';
        if(!isAMAAdminMail){
            bodytext += '<br><br>TP Processor Action Guidance if ‘'+(isManagementEmail ? 'Management Reviewer' : 'Commercial Owner')+' Decision’ is not an approval:';
            bodytext += '<UL style="list-style-type: disc;font-size:13px;font-family:arial;"><LI style="font-size:13px;font-family:arial;"> <b>' + 'If '+(isManagementEmail ? 'Management Reviewer' : 'Commercial Owner')+' Decision is: “Ask Additional Questions for TP Processor”'+ '</b></LI>';
            bodytext +='</UL> ';
            bodytext += '<UL style="list-style-type: disc;font-size:13px;font-family:arial;">&nbsp;&nbsp;&nbsp;&nbsp;&#10003; The '+(isManagementEmail ? 'Management Reviewer' : 'Commercial Owner')+' is carbon copied on this email, please research, and respond to the owner ';
            bodytext +='</UL> ';
            
            
            bodytext += '<UL style="list-style-type: disc;font-size:13px;font-family:arial;"><LI style="font-size:13px;font-family:arial;"><b>If '+(isManagementEmail ? 'Management Reviewer' : 'Commercial Owner')+' Decision is: “Potential Denial”   </b></LI> ';
            bodytext +='</UL> ';
            bodytext += '<UL style="list-style-type: disc;font-size:13px;font-family:arial;">&nbsp;&nbsp;&nbsp;&nbsp;&#10003;	TP Processor should reach out to <a href="mailto: TP-US@iqvia.com"> TP-US@iqvia.com </a>  to ask for a meeting with TPA global program management and IQVIA Legal';
            bodytext +='</UL> '; 
            bodytext += '<UL style="list-style-type: disc;font-size:13px;font-family:arial;">&nbsp;&nbsp;&nbsp;&nbsp;&#10003; The '+(isManagementEmail ? 'Management Reviewer' : 'Commercial Owner')+' feels this request should not be approved.  IQVIA Legal requires a meeting with the '+(isManagementEmail ? 'Management Reviewer' : 'Commercial Owner')+' for evaluation of the risk to IQVIA\' intellectual property (IP) and whether that risk can be sufficiently mitigated through some combination of technical, physical, administrative and governance controls and safeguards.';
            bodytext +='</UL> '; 
            bodytext += '<UL style="list-style-type: disc;font-size:13px;font-family:arial;">&nbsp;&nbsp;&nbsp;&nbsp;&#10003; IMPORTANT:   A proper TPA license request from a client cannot be denied unless reviewed and authorized by the IQVIA attorney assigned to the TPA global program management team.  </li>';
            bodytext +='</UL> ';   
        }
              
        bodytext += '<br><br></div>' ;     
        
        if(bodyText.replace('TABLE_TEXT', tableText).length() > 200000){
             String  URL = UTL_TPA.TPA_ClientCOM_URL + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CODescisionTable&id='+ tpaRequest.Id +'&viewMode=TPSubmit&TPCountryId=' + tpProcessorEmail + '&MailType=fyr';
             bodyText = bodyText.replace('TABLE_TEXT',  '<div style="font-size:13px;font-family:arial;"><B>For Manual Review Decision Details:</B> <a href =' + URL + '> Click here </a></div>' );
        }else{
             bodyText = bodyText.replace('TABLE_TEXT', tableText);
        }      
        List<String> toAddress = new List<String>();
        
        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           SRV_TPA_TPARequest.assignedTPProcessorName = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/
        
        toAddress = new List<String>();
        toAddress.addALL(LstOfTPProcessor);
        toAddress.addALL(LstOfReviewer);
        if(tempcommercialEmailID != null && tempcommercialEmailID != ''){
            toAddress.addALL(tempcommercialEmailID.split(';'));
        }
        if(isAMAAdminMail){
            toAddress = new List<String>();
            toAddress.add(UTL_TPA.TPUSEMailAddress);
            if(UTL_TPA.TPUSEMailAddress != tpaRequest.TP_Processor_Email__c)
                toAddress.add(tpaRequest.TP_Processor_Email__c);
        }
        System.debug(toAddress);
        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, null, 'SendEmail', null, tpaRequest.Id, null, subjText, FALSE, bodytext,TRUE, TRUE, tpaRequest);
        //SRV_TPA_TPARequest.addTPProcessorInitials = false;
        
    }
    
    
    
    public static void createUpdateWatchList(TPA_Request__c tpaRequest, Set<String> commReviewKeys) {

        List<Watch_List__c> watchListsToBeUpserted = new List<Watch_List__c>();
        String vendorAddress = tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null ? tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c : tpaRequest.Service_Provider_Address__c;
        for(Watch_List__c watch : [SELECT Id, Always_Approved__c, Data_Asset_Category__c, Offering__c, Use__c, Country_of_Offering__c
                                   FROM Watch_List__c
                                   WHERE Vendor_Address__c =: vendorAddress and Always_Approved__c = false ] ) {
            String use = ( watch.Use__c != null ? watch.Use__c : '' );
            String offering = ( watch.Offering__c != null ? watch.Offering__c : '' );
            String uniqueKey = use + offering;
            if(commReviewKeys.contains(uniqueKey) && !watch.Always_Approved__c){
                watch.Always_Approved__c = true;
                watchListsToBeUpserted.add(watch);
            }
        }
        try{
            if(watchListsToBeUpserted != null && watchListsToBeUpserted.size() > 0){
                upsert watchListsToBeUpserted;
            }
	}
	catch(Exception e){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_CommercialReviewForm:::createUpdateWatchList', tpaRequest != null ? tpaRequest.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
    }
    
    public static void sendMailToCommercialOwner(List<id> lstIDs, TPA_Request__C tpaRequest, String commOwnerName,String commOwnerID, Date dateOfResponse, String tempcommercialEmailID) 
    {
        
        Map<Id,Set<Id>> reqWithPurposeIds = new Map<Id,Set<Id>>();
        List<String> southAfricaOfferings = System.Label.TPA_SubNational_Offerings.split(';');
        TPA_Request__C tpaRequestForPurpose = [Select Id,Name,Service_Provider_Address__c,Vendor_Billing_Mailing_Country__c,is_LAAD_Response_Acknowledged__c,Is_VSN_Acknowlege_By_Client__c,(select id,IMS_Legal_Entity__c,Purpose__c,Purpose__r.Id from Purposes__r), (SELECT Id, TPA_Offering_Notification_Record__c, Type__c FROM TPA_Use_Offering_Atypical_Combinations__r WHERE Type__c = 'Offering Notification Record') , (SELECT Id,is_Canada__c FROM IMS_Legal_Entities__r) From TPA_Request__c where Id =: tpaRequest.Id ];
        
        List<TPA_Commercial_Review__c> ListOfComReviwer = [select id,Commercial_Owner_Name__c, Additional_Text_For_Potential_Denial__c,Comment_For_Under_Validation__c, Manual_Review_Reason__c,TP_US_Email__c,Additional_Questions_For_TP_Processor__c, Receiver_s_Email__c,BU__c,Associated_Offering_s_Use_Category_s__c,Associated_Offering_to_Review__c,Associated_Use_to_Review__c,Action__c,TP_Country_Email__c,TPA_Additional_Term__c from TPA_Commercial_Review__c where id IN : lstIDs];        
        String subjText = '';
        String bodyText = '';
        String tableText = '';
        String preferredLanguage;
        String templateID;
        String emailBody;
        String tempEmailBody;
        Map<String, TPA_Additional_Term__c> mapTpaAdditionalTerms = UTL_TPA.getTpaAdditionalTerms(tpaRequest);
        Map<String, TPA_Text_Editor__c> mapTpaTextAdditionalTerms = UTL_TPA.getTpaTextAdditionalTerms(tpaRequest);
        Map<String, TPA_Offering_Notification_Mapping__c> mapTpaDynamicNotifications = UTL_TPA.getmapTpaDynamicNotifications(tpaRequestForPurpose);
        Boolean isManagementEmail = false;
       // Set<String> futureApprovedComRevKeys = new Set<String>();
       // List<TPA_Additional_Term__c> addHocTermsToUpdate = new List<TPA_Additional_Term__c>();
        for(TPA_Commercial_Review__c comRev: ListOfComReviwer){
            if(comRev.Manual_Review_Reason__c == 'Vendor Requires Secondary Review'){
                isManagementEmail = true;
            }
            if(comRev.Action__c != null && comRev.Action__c == 'Approved for this specific TPA. The Vendor and specified Use(s) and IQVIA Offerings specific combination can be auto-approved moving forward for future requests') {
                if(!comRev.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')
                   && !comRev.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by')){
				       String useName = (comRev.Associated_Use_to_Review__c != null ? comRev.Associated_Use_to_Review__c : '');
                       String offName = '';
                       Pattern p = Pattern.compile(String.join(new List<String>(UTL_TPA.OfferingMapForAddText.keyset()),'|'));
                        if(comRev.Associated_Offering_to_Review__c != null ){
                            Matcher m = p.matcher(comRev.Associated_Offering_to_Review__c.replaceAll('\\(.*\\)', '').replaceAll('\\[|\\]', ''));
                            if(m.find()) {
                                offName = UTL_TPA.OfferingMapForAddText.get(m.group(0));
                            }else{
                                offName = comRev.Associated_Offering_to_Review__c;
                            }
                        }
                        System.debug('offName:' + offName);
                        String Key = useName + offName;
                        System.debug('Key:' + Key);
                       //String Key = (comRev.Associated_Use_to_Review__c != null ? comRev.Associated_Use_to_Review__c : '') + (comRev.Associated_Offering_to_Review__c != null ? comRev.Associated_Offering_to_Review__c : '');
                       futureApprovedComRevKeys.add(Key);                        
                   }
            }
            if(comRev.Action__c != null && comRev.Action__c == System.Label.TPA_Approved_Future_Approved_AdHoc) {
                addHocTermsToUpdate.add(new TPA_Additional_Term__c(Id = comRev.TPA_Additional_Term__c,Is_Future_Approved__c = true));    
            }
        }  
        
        if(futureApprovedComRevKeys.size() > 0 || addHocTermsToUpdate.size() > 0){
            
          /*  if(tpaRequest.is_Bulk_TPA_Request__c) {
                system.debug('here : ' );
                QBL_TPA_UpdateFutureApprovalAction updateFutureApprovalAction = new QBL_TPA_UpdateFutureApprovalAction();
                updateFutureApprovalAction.request = tpaRequest;
                updateFutureApprovalAction.commReviewKeys = futureApprovedComRevKeys;
                updateFutureApprovalAction.addTermToUpdate = addHocTermsToUpdate;
                if(!Test.isRunningTest()){
                    System.enqueueJob(updateFutureApprovalAction);
                }
            }else{
                createUpdateWatchList(tpaRequest, futureApprovedComRevKeys);
                if(addHocTermsToUpdate.size() > 0){
                    update addHocTermsToUpdate;
                }
            }*/

             if(!tpaRequest.is_Bulk_TPA_Request__c) {
                createUpdateWatchList(tpaRequest, futureApprovedComRevKeys);
                if(addHocTermsToUpdate.size() > 0){
                    UTL_TPA.updateFromPage = true;
                    update addHocTermsToUpdate;
                    UTL_TPA.updateFromPage = false;
                }
             }
        }
        

        
        
        preferredLanguage = 'English';
        
        templateID = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email to notify commercial owner'+preferredLanguage).Translated_Template_Id__c;
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
        
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateID != '' && templateID != null) {        
            try {
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, tpaRequest.Id);
            } catch(Exception exp) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::CNT_TPA_CommercialReviewForm:::sendMailToCommercialOwner', tpaRequest != null ? tpaRequest.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
            tempEmailBody = emailNotToSend.getHTMLBody();
            subjText = emailNotToSend.getSubject();
            bodyText = '<div style="background-color=white;text-align=left;">';
            
            bodytext += '<br><table style="border-collapse: collapse;font-size:13px;font-family:arial;border:1px solid black;">';
            bodytext += '<tr><td style="width:25%;border:1px solid black;font-size:13px;font-family:arial;padding: 5px 5px 5px 5px;"><b>'+(isManagementEmail ? 'Management Reviewer' : 'Commercial Owner')+' Name:</b> </td><td style="width:25%;border:1px solid black;font-size:13px;font-family:arial;padding: 5px 5px 5px 5px;">'+ commOwnerName +'</td></tr>';
            bodytext += '<tr><td style="width:25%;border:1px solid black;font-size:13px;font-family:arial;padding: 5px 5px 5px 5px;"><b>Date of Review: </b></td><td style="width:25%;border:1px solid black;font-size:13px;font-family:arial;padding: 5px 5px 5px 5px;">'+ Datetime.newInstance(dateOfResponse.year(), dateOfResponse.month(), dateOfResponse.day()).format('yyy-MM-dd')  +'</td></tr>';
            bodytext += '</table><br>';
            
            bodytext += '<br>TABLE_TEXT';
            tableText = '<table style="border-collapse: collapse;font-size:13px;font-family:arial;border:1px solid black;">';
            tableText += '<tr><th style="padding: 0px 5px 0px 5px;border:1px solid black;font-size:13px;font-family:arial;">Manual Review Reason</th><th style="padding: 0px 5px 0px 5px;border:1px solid black;font-size:13px;font-family:arial;">Country of Offering</th><th style="padding: 0px 5px 0px 5px;border:1px solid black;font-size:13px;font-family:arial;">Associated Offering(s) to Review</th><th style="padding: 0px 5px 0px 5px;border:1px solid black;font-size:13px;font-family:arial;">Associated Offering(s) Use(s) Requested</th><th style="padding: 0px 5px 0px 5px;border:1px solid black;font-size:13px;font-family:arial;">'+(isManagementEmail ? 'Management Reviewer' : 'Commercial Owner')+' Decision</th>';
            
            String style = 'style = "border: 1px solid black;padding: 0 5px 0 5px;"';
            String fontStyle = '<div style="font-size:13px !important;font-family:arial !important;">';
            
            String useName = '';
            String offeringName = '';
            String comOwnerDecision = '';
            String actionWithComments = '';
            String countryOfOffering = '';
            for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                actionWithComments = '';
                useName = comRev.Associated_Use_to_Review__c != null ? comRev.Associated_Use_to_Review__c : '';
                offeringName = comRev.Associated_Offering_to_Review__c != null ? comRev.Associated_Offering_to_Review__c : '';
                comOwnerDecision = '';
                countryOfOffering = comRev.BU__c;
                if(comRev.Action__c == 'Questions / Comments'){
                    actionWithComments = comRev.Action__c + (comRev.Additional_Questions_For_TP_Processor__c != null ? (': ' + comRev.Additional_Questions_For_TP_Processor__c) : '');
                }
                else if(comRev.Action__c == 'Potential Denial - Request TP Processor to arrange meeting with IQVIA Legal'){
                    actionWithComments = comRev.Action__c + (comRev.Additional_Text_For_Potential_Denial__c != null ? (': ' + comRev.Additional_Text_For_Potential_Denial__c) : '');
                }
                else if(comRev.Action__c == 'Under Validation'){
                    actionWithComments = comRev.Action__c + (comRev.Comment_For_Under_Validation__c != null ? (': ' + comRev.Comment_For_Under_Validation__c) : '');
                }
                else{
                    actionWithComments = comRev.Action__c;
                }
                comOwnerDecision = actionWithComments;
                tableText += '<tr>';
                tableText += '<td ' + style + '>' + comRev.Manual_Review_Reason__c + '</td>';
                tableText += '<td ' + style + '>' + countryOfOffering + '</td>';
                tableText += '<td ' + style + '>' + offeringName + '</td>';
                tableText += '<td ' + style + '>' +  useName  + '</td>';
                tableText += '<td ' + style + '>' + comOwnerDecision + '</td>';
                tableText += '</tr>';
            }
            tableText += '</table>';
            bodytext += '</div>';
            if(tpaRequest.Parent_Request__c != null && tpaRequest.Parent_Request__r.Is_Renewed__c && tpaRequest.Parent_Request__r.Renewed_As__c == tpaRequest.Id && tpaRequest.Is_Partially_Renewed__c != true) {
                bodytext += '<br><br><p style="font-size:13px;font-family:arial;"><B>' + tpaRequest.Name + ' Request Details: This is a renewal TPA. Parent TPA is ' + tpaRequest.Parent_Request__r.Name + '. </B>';
            }
            else {
                bodytext += '<br><br><p style="font-size:13px;font-family:arial;"><B>' + tpaRequest.Name + ' Request Details: </B>';
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
                bodytext += '<br><B>Data Period Start and End Dates: </B>'+dataPeriodStartDate + ', ' + dataPeriodEndDate;
            }
            
            
            if(tpaRequest.AMA_USPrescriberData__c != null && tpaRequest.AMA_USPrescriberData__c.equalsIgnoreCase(UTL_TPA.YES)) {
                bodytext += '<br><B>AMA license required: </B>'+ ' Yes';  
            }
            else if(tpaRequest.AMA_USPrescriberData__c != null && tpaRequest.AMA_USPrescriberData__c.equalsIgnoreCase(UTL_TPA.NO)) {
                bodytext += '<br><B>AMA license required: </B>'+ ' No';  
            }
            System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
            System.debug('Limits.getCpuTime - '+ Limits.getCpuTime());
            
            Set<String> TpaTextTerms =  new Set<String>();
            for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
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
                    if(comRev.Associated_Offering_to_Review__c.indexOf('Promo') != -1 ){
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
                    if(comRev.Associated_Offering_to_Review__c.indexOf('Xponent') != -1 || comRev.Associated_Offering_to_Review__c.indexOf('OneKey') != -1){
                        TpaTextTerms.add('is_Xponent_or_OneKey__c');
                    }
                    if(southAfricaOfferings.contains(comRev.Associated_Offering_to_Review__c) ){
                        TpaTextTerms.add('Is_South_Africa_Sub_Off__c');
                    }
                    if(comRev.Associated_Offering_to_Review__c.indexOf('Xponent PlanTrak') != -1 ){
                        TpaTextTerms.add('is_Xponent__c');
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
                    if(System.Label.TPA_DDD_Offering != null && System.Label.TPA_DDD_Offering.split(';').contains(comRev.Associated_Offering_to_Review__c) ){
                        TpaTextTerms.add('isDDDOffering__c');
                    }
                }
                
            }
            if(tpaRequestForPurpose != null){
                for (IMS_Legal_Entity__c legalentityObj : tpaRequestForPurpose.IMS_Legal_Entities__r){
                    if(legalentityObj.is_Canada__c != null && legalentityObj.is_Canada__c){
                        TpaTextTerms.add('is_Canada__c');
                    }
                }
            }
            
            
            List<TPA_Text_Editor__C> vendorSpecificTextAddTerms = new List<TPA_Text_Editor__C>();
            List<TPA_Text_Editor__C> offeringSpecificTextAddTerms = new List<TPA_Text_Editor__C>();
            List<TPA_Additional_Term__c> vendorSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            List<TPA_Additional_Term__c> offeringSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            List<TPA_Additional_Term__c> useSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            List<TPA_Additional_Term__c> useOfferingSpecificAddhocTerms = new List<TPA_Additional_Term__c>();
            List<TPA_Offering_Notification_Mapping__c> DynamicNotifications = new List<TPA_Offering_Notification_Mapping__c>();
            if(mapTpaTextAdditionalTerms != null || mapTpaAdditionalTerms != null || mapTpaDynamicNotifications != null){
                if(mapTpaTextAdditionalTerms != null){
                    for( String addKey : mapTpaTextAdditionalTerms.keyset()) {
                        if(addKey.split(':')[1] == 'TPA_Request__c'){
                            vendorSpecificTextAddTerms.add(mapTpaTextAdditionalTerms.get(addKey));
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
                            vendorSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                        }
                        if(addKey.split(':')[1] == 'Data Asset Specific Ad-Hoc Term'){
                            offeringSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                        }
                        if(addKey.split(':')[1] == 'Use Specific Ad-Hoc Terms'){
                            useSpecificAddhocTerms.add(mapTpaAdditionalTerms.get(addKey));
                        }
                        if(addKey.split(':')[1] == 'Use/Offering Specific Ad-Hoc Terms'){
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
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Use Specific Additional Term that will be included in the TPA Agreement: </B></div>';
                if(useSpecificAddhocTerms != null && useSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: useSpecificAddhocTerms){
                        for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.TPA_Additional_Term__c != null && comRev.TPA_Additional_Term__c == addhoc.Id){
                                bodytext += '<br><br>'+ fontStyle + '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                            else if(comRev.Associated_Use_to_Review__c != null  && comRev.Associated_Use_to_Review__c == addhoc.Use_Name__c){
                                bodytext += '<br><br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c + ':</u></strong>';
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
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Use/Offering Specific Additional Term that will be included in the TPA Agreement: </B></div>';
                if(useOfferingSpecificAddhocTerms != null && useOfferingSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: useOfferingSpecificAddhocTerms){
                        for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.TPA_Additional_Term__c != null && comRev.TPA_Additional_Term__c == addhoc.Id){
                                bodytext += '<br><br>'+ fontStyle + '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                            else if(comRev.Associated_Use_to_Review__c != null  && comRev.Associated_Use_to_Review__c == addhoc.Use_Name__c && comRev.BU__c != null && addhoc.Country_of_Offering__c != null && comRev.BU__c == addhoc.Country_of_Offering__c && comRev.Associated_Offering_to_Review__c != null && comRev.Associated_Offering_to_Review__c.indexOf(':') != -1 && ((addhoc.Primary_Offering_Name__c != null && addhoc.Primary_Offering_Name__c.indexOf(comRev.Associated_Offering_to_Review__c.split(':')[0]) != -1) || (addhoc.Secondary_Offering_Name__c != null && addhoc.Secondary_Offering_Name__c.indexOf(comRev.Associated_Offering_to_Review__c.split(':')[0]) != -1))){
                                bodytext += '<br><br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c + ':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                            else if(comRev.Associated_Use_to_Review__c != null  && comRev.Associated_Use_to_Review__c == addhoc.Use_Name__c && comRev.BU__c != null && addhoc.Country_of_Offering__c != null && comRev.BU__c == addhoc.Country_of_Offering__c && comRev.Associated_Offering_to_Review__c != null && ((addhoc.Primary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c.indexOf(addhoc.Primary_Offering_Name__c) != -1) || (addhoc.Secondary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c.indexOf(addhoc.Secondary_Offering_Name__c) != -1))){
                                bodytext += '<br><br>' + fontStyle +'<strong><u>'+ addhoc.Term_Name__c + ':</u></strong>';
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
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Offering Specific Additional Term that will be included in the TPA Agreement: </B></div>';
                if(offeringSpecificTextAddTerms != null && offeringSpecificTextAddTerms.size() > 0){
                    for(TPA_Text_Editor__C txt: offeringSpecificTextAddTerms){
                        bodytext += '<br><br>' + fontStyle + txt.Content__c + '</div>';
                    }
                }
                
                if(offeringSpecificAddhocTerms != null && offeringSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: offeringSpecificAddhocTerms){
                        set<String> stringcase = new set<String>();
                        for( TPA_Commercial_Review__c comRev : ListOfComReviwer) {
                            if(comRev.TPA_Additional_Term__c != null && comRev.TPA_Additional_Term__c == addhoc.Id){
                                bodytext += '<br><br>'+ fontStyle + '<strong><u>'+addhoc.Term_Name__c +':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null && comRev.Associated_Offering_to_Review__c.indexOf(':') != -1 && ((addhoc.Primary_Offering_Name__c != null && addhoc.Primary_Offering_Name__c.indexOf(comRev.Associated_Offering_to_Review__c.split(':')[0]) != -1) || (addhoc.Secondary_Offering_Name__c != null && addhoc.Secondary_Offering_Name__c.indexOf(comRev.Associated_Offering_to_Review__c.split(':')[0]) != -1))){
                                bodytext += '<br><br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c + ':</u></strong>';
                                bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                                if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                                    String attchId = addhoc.Attachments[0].Id;
                                    bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                                }
                                bodytext += '</div>';
                                break;
                            }
                            else if(comRev.Associated_Offering_to_Review__c != null && ((addhoc.Primary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c.indexOf(addhoc.Primary_Offering_Name__c) != -1) || (addhoc.Secondary_Offering_Name__c != null && comRev.Associated_Offering_to_Review__c.indexOf(addhoc.Secondary_Offering_Name__c) != -1))){
                                bodytext += '<br><br>' + fontStyle +'<strong><u>'+ addhoc.Term_Name__c + ':</u></strong>';
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
                        if(!DynNotiDuplicatecheck.contains(offNotifyContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', ''))){
                            DynNotiDuplicatecheck += offNotifyContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', '') + '|-|';
                            bodytext += '<br><br>' + fontStyle + offNotifyContent + '</div>';
                        }
                    }
                }
            }
            if((vendorSpecificTextAddTerms != null && vendorSpecificTextAddTerms.size() > 0) || (vendorSpecificAddhocTerms != null && vendorSpecificAddhocTerms.size() > 0)){
                bodytext += '<br><br><B><div style="font-size:13px;font-family:arial;">Additional Term(s) under TLLA Schedule A: </div></B>';
                if(vendorSpecificTextAddTerms != null && vendorSpecificTextAddTerms.size() > 0){
                    for(TPA_Text_Editor__C txt: vendorSpecificTextAddTerms){
                        bodytext += '<br><br>' + fontStyle + txt.Content__c + '</div>';
                    }
                }
                if(vendorSpecificAddhocTerms != null && vendorSpecificAddhocTerms.size() > 0){
                    for(TPA_Additional_Term__c addhoc: vendorSpecificAddhocTerms){
                        bodytext += '<br><br>' + fontStyle + '<strong><u>' + addhoc.Term_Name__c + ':</u></strong>';
                        bodytext += '<br><br>'  + addhoc.Addtional_Term__c ;
                        if(addhoc.Exhibit_Attached__c && addhoc.Attachments != null && addhoc.Attachments.size() > 0){
                            String attchId = addhoc.Attachments[0].Id;
                            bodytext += '<br><br><a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=servlet/servlet.FileDownload?file='+ attchId+' >Click here view Exhibit Page</a>';
                        }
                        bodytext += '</div>';
                    }
                }
            }
            
            
                
                bodytext += '<br><br><div style="font-size:13px;font-family:arial;"><B>Requested Uses and ' + Label.TPA_IQVIA_Keyword + ' Offering(s) by Country: </B>'+ '<a href = '+TPA_Settings__c.getOrgDefaults().TPA_Client_Community_Url__c + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_OfferingsWithCategory&reqId='+ tpaRequest.Id+' >Click here</a></div>' +'</p>';
                
            	if(bodyText.replace('TABLE_TEXT', tableText).length() > 200000){
            		String  URL = UTL_TPA.TPA_ClientCOM_URL + '/VFP_TPA_ExternalUserAction?actionType=tpasitelinkaccess&returlpage=VFP_TPA_CODescisionTable&id='+ tpaRequest.Id +'&viewMode=CSubmit&CSId=' + commOwnerID + '&MailType=fyr';
            		bodyText = bodyText.replace('TABLE_TEXT',  '<div style="font-size:13px;font-family:arial;"><B>For Manual Review Decision Details:</B> <a href =' + URL + '> Click here </a></div>' );
        		}else{
            		bodyText = bodyText.replace('TABLE_TEXT', tableText);
        		}
                emailBody = tempEmailBody.replace('[tablee]', bodyText);
                //Map<String,String> temporaryComOwnerMap = UTL_TPA.getTemporaryComOwnerMap();
                List<String> toAddresses = new List<String>();
                toAddresses.addALL(commOwnerID.split(';'));
                if(tempcommercialEmailID != null && tempcommercialEmailID != ''){
                    toAddresses.addALL(tempcommercialEmailID.split(';'));
                }
               /* for(String revID : commOwnerID.split(';')){
                    if(temporaryComOwnerMap != null && temporaryComOwnerMap.containsKey(revID)){
                        toAddresses.add(temporaryComOwnerMap.get(revID)); 
                    } 
                }*/
                try{
                    if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()){
                        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                        if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                            SRV_TPA_TPARequest.assignedTPProcessorName  = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
                        }*/
                        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddresses, null, 'SendEmail', null, tpaRequest.Id, null, subjText, FALSE, emailBody, TRUE, TRUE, tpaRequest);
                        //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                    }
                }
                catch(Exception e){
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_CommercialReviewForm:::sendMailToCommercialOwner', tpaRequest != null ? tpaRequest.Id : ''));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                }
                
            } 
        }  
    
    public static TPA_Request__c getRequestInfo(ID requestId) {
        TPA_Request__c req = [Select id, Generate_AMA_Contract__c, isbatchProcessing__c, TLLA_Batch_Call_Sent_On__c, Is_Manually_Approved__c,Manual_Trigger_Reasons__c, Vendor_Billing_Mailing_Country__c, Is_Veeva_Use_CRM_Off_OneKey__c,is_Veeva_Use_CRM__c,Is_Veeva_Use_CRM_SubNational_Off__c,Ack_Understanding_of_Prescriber_Data__c,Is_Exhibit_Required__c,Is_South_Africa_Sub_Off__c,is_Specific_Vendors_LAAD_Off__c,is_Specific_Vendors_APLD_Off__c,is_Specific_Vendors_Long_Prescr_Data__c,is_Specific_Vendors_Medical_Claims_Data__c,is_20_or_more_Offering_Present__c,Is_Vendor_Name_Contains_MedPro__c,is_Bulk_TPA_Request__c,
                              Data_Access_End_Date__c,Name,Request_Status__c,Service_Provider_Address__r.Name,Service_Provider_Address__r.Vendor_Tier__c,Service_Provider_Address__r.New_Vendor_Checklist__c,Service_Provider_Address__r.Pharma_Company_Checklist__c,Service_Provider_Address__r.Legal_Firm_Checklist__c,Service_Provider_Address__r.AMA_Check_List__c, Service_Provider_Address__r.Academia_Checklist__c,Service_Provider_Address__r.AMA_U_S_hold_status__c, Vendor_Website__c,Client_Project_Name__c,TPA_Assigned_TP_Processor__r.Is_Active__c,TPA_Assigned_TP_Processor__r.Initials__c,Co_Assigned_Global_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__r.Initials__c,
                              Vendor_e_mail__c,TPA_Authorised_Signer__c,AMA_USPrescriberData__c,Service_Provider_Address__c, Service_Provider_Address__r.Parent_Vendor_Name__c,Service_Provider_Address__r.Parent_Vendor_Name__r.Vendor_Tier__c,Service_Provider_Address__r.Parent_Vendor_Name__r.New_Vendor_Checklist__c,Service_Provider_Address__r.Parent_Vendor_Name__r.Pharma_Company_Checklist__c,Service_Provider_Address__r.Parent_Vendor_Name__r.Legal_Firm_Checklist__c,Service_Provider_Address__r.Parent_Vendor_Name__r.AMA_Check_List__c, Service_Provider_Address__r.Parent_Vendor_Name__r.Academia_Checklist__c,Service_Provider_Address__r.Parent_Vendor_Name__r.AMA_U_S_hold_status__c,
                              Client_Address__c, Client_Address__r.Name,Client_Language__c, Parent_Request__r.Name,Vendor_Language__c,Data_Access_Start_Date__c,Data_Period_Start_Date__c,Data_Period_End_Date__c,Parent_Request__c,Parent_Request__r.Is_Renewed__c,Parent_Request__r.Renewed_As__c,Is_Partially_Renewed__c,Is_Potential_Vendor_Case__c,Vendor_Contact_e_mail__c,TP_Processor_Email__c,Request_Type__c,isClientOnComplianceHold__c,isVendorOnComplianceHold__c,Pending_Acknowledgements__c, Service_Provider_Address__r.AMA_Database_Licensee__c, 
                              (select id, AMA_Services_Provided__c,AMA_TypeOfPrescriberLevelData__c,Vendor_Employee_Store_Data_in_country__c,Client_AMA_Manually_Validated__c,
                               Vendor_Employee_Accessed_Data_in_country__c,Client_Employee_Store_Data_in_country__c,Vendor_require_Remote_Access_from_NonUS__c,Technology_s_selected_for_remote_access__c,Vendor_req_Storage_Permission_from_NonUS__c, Vendor_Legal_Name__c  from AMA_Agreement_Details__r limit 1) from TPA_Request__c where Id = :requestId];
        if (req != null) {
            return req;
        }
        
        return null;
    }
    
}
