global without sharing class CNT_TPA_RequestSubmissionForm { 
    public static boolean isTPProcessor;
    public static boolean isUSTPProcessor;
    public static List<TPA_Country_Codes__c> existedCountryStateCodes;
    public static Boolean IsUpdateRenewalOfferinfDetail = false;
    public static List<id> legalEntityIDs;
    public static set<id> purposeIDsforBackup;
    public static Map<string, List<TPA_Commercial_Review__c>> commmercialReviewMap = new Map<string, List<TPA_Commercial_Review__c>>();
    public static Map<string, List<TPA_Commercial_Review__c>> commercialReviewMapSec =  new Map<string, List<TPA_Commercial_Review__c>>();
    public static set<Id> termsNotToRetain = new Set<Id>();

    public string tpaRequestId {get; set;}
    public string tpaRequestEditType {get; set;}
    public string tpaRequestCallType {get; set;}
    public boolean isTPAPermanentDown {get; set;}
    public String strContryStateCode {get; set;}
    public string formDisplayMode {get; set;}
    public string queueList {get; set;}
    public string getlastSelectedQueueRcrd {get; set;}

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

    public String cloneUseGuide {
        get {
            if(cloneUseGuide == null)
                return UTL_TPA.TPACloneUseGuide;
            else
                return cloneUseGuide;
        }
        set;
    }

    public static Integer noOfRecords {
        get {
            if(noOfRecords == null) {
                string tpaReqId = ApexPages.currentPage().getParameters().get('id');
                AggregateResult[] groupedResults = [SELECT count(id) FROM TPA_Purpose__c WHERE Request__c = : tpaReqId];
                if(groupedResults.size() > 0) {
                    for (AggregateResult ar : groupedResults)  {
                        noOfRecords = Integer.valueOf(ar.get('expr0')) ;
                    }
                }
                return noOfRecords;
            }
            else {
                return noOfRecords;
            }
        }
        set;
    }
    public List<String> lstMessageBoard = new List<String>();
    List<TPA_Text_Editor__c> lstTextEditorRecord = new List<TPA_Text_Editor__c>();
    public String textEditorRecords(String recordType){
        if(lstTextEditorRecord == null || lstTextEditorRecord.size() == 0){
            lstTextEditorRecord = [select Page_Name__c, Content__c from TPA_Text_Editor__c where Page_Type__c IN ('Shutdown Message','Hover Descriptions') order by Page_Type__c desc];
            for(TPA_Text_Editor__c textEditorRecord : lstTextEditorRecord){
                if(textEditorRecord.Page_Name__c != 'TPA ShutDown Message'){
                    if(HoverDescriptionMap == null) 
                        HoverDescriptionMap = new Map<String, String>();
                    HoverDescriptionMap.put(textEditorRecord.Page_Name__c, textEditorRecord.Content__c);
                }else{
                    lstMessageBoard.add( textEditorRecord.Content__c);
                }
            }
        }

        if(recordType == 'Shutdown Message'){ 
            return lstMessageBoard[0];
        }else if(recordType == 'Hover Descriptions'){
            return JSON.serialize(HoverDescriptionMap);
        }
        return '';
    }
    public Map<String, String> HoverDescriptionMap;
    public String HoverDescriptionMapString{
        get{
            if(HoverDescriptionMapString == null)
                return textEditorRecords('Hover Descriptions');
            else 
                return HoverDescriptionMapString;
        }
        set;
    } 

    public Static Map<string, String> usesAndCategoryMap {
        get{
            if(usesAndCategoryMap == null) {
                String categoryAndUse = '';
                usesAndCategoryMap = new Map<String, String>();
                List<TPA_Table_of_AMA_Use_And_Use_Category__c> listUseAndCategory = TPA_Table_of_AMA_Use_And_Use_Category__c.getall().values();
                for(TPA_Table_of_AMA_Use_And_Use_Category__c tabAma : listUseAndCategory){
                    categoryAndUse = tabAma.IQVIA_Use_Category__c + ';' + tabAma.IQVIA_USE__c;
                    usesAndCategoryMap.put(categoryAndUse, tabAma.Proposed_AMA_Use_to_Select__c);
                }
            }
            return usesAndCategoryMap;
        }
        set;       
    }

    //Constructors 
    public CNT_TPA_RequestSubmissionForm(ApexPages.StandardController stdController) {
        this();
    }

    public CNT_TPA_RequestSubmissionForm() {
        system.debug('currentLoggedInUser :::' + currentLoggedInUser);
        
        //Vendor guest user to vendor community user transition
        if(currentLoggedInUser.Profile.Name == 'tpa Profile') {
            return;
        }

        isTPProcessor = currentLoggedInUser.Profile.Name.indexOf('TPA Processor Profile') != -1 ? true : false;
        isUSTPProcessor = currentLoggedInUser.Profile.Name.indexOf('US TP Processor Profile') != -1 ? true : false;
        system.debug('isTPProcessor :: ' + isTPProcessor); 
        system.debug('isUSTPProcessor :: ' + isUSTPProcessor); 
        
        string tpaReqId = ApexPages.currentPage().getParameters().get('id');
        string tpaReqBy = ApexPages.currentPage().getParameters().get('type');
        string tpaLangOverride = ApexPages.currentPage().getParameters().get('isLangOverride');
        string tpaViewLang = ApexPages.currentPage().getParameters().get('currentViewLang');
        
        string vendorSelectedLanguage = ApexPages.currentPage().getParameters().get('venSelLang');
        system.debug('####tpaReqId: '+tpaReqId+', tpaReqBy: '+tpaReqBy+', tpaLangOverride: '+tpaLangOverride+', currentViewLang: '+tpaViewLang + ', venSelLang:'+vendorSelectedLanguage);

        if(((tpaReqId == null || tpaReqId.length() == 0) && (tpaViewLang == null || tpaViewLang.length() == 0)) || (tpaLangOverride != null && tpaLangOverride == 'true')) {
            system.debug('####venSelLang0:'+vendorSelectedLanguage+'::::'+currentLoggedInUser.Profile.Name+':::'+UTL_TPA.tpaVendorProfile);
            if(currentLoggedInUser.Profile.Name == UTL_TPA.tpaVendorProfile && vendorSelectedLanguage != null) {
                language = vendorSelectedLanguage;
            }
            else{
                language = UTL_TPA_Multilingual.getLanguage();
            }
        }
        else if((tpaLangOverride == null || tpaLangOverride.length() == 0) && tpaReqId != null && (tpaViewLang == null || tpaViewLang.length() == 0)) {
            language = UTL_TPA_Multilingual.getLanguageForExistingRequests(tpaReqId, tpaReqBy);
        }
        else if((tpaLangOverride == null || tpaLangOverride.length() == 0) && tpaReqId != null && (tpaViewLang != null && tpaViewLang.length() > 0)) {
            language = tpaViewLang;
        }


        Set<String> textEditorfieldSet = new Set<String>{'English_Translation__c', 'Japanese_Translation__c'};
        List<TPA_Text_Editor__c> editorDataList = SLT_TPATextEditor.instance.getTPATextEditorDataByListOfId(textEditorfieldSet, TPA_Settings__c.getOrgDefaults().VendorMessageBoardId__c.split(','));
        for(TPA_Text_Editor__c mb : editorDataList){
            if(mb.Page_Name__c == 'Vendor Message Board'){
                msgBoardContent = mb.get(supportedLanguageMap.get(language).split('~')[1]) != null ? String.valueOf(mb.get(supportedLanguageMap.get(language).split('~')[1])) : String.valueOf(mb.Content__c);
            }else if(mb.Page_Name__c == 'Vendor Primary Message Board'){
                msgPrimaryBoardContent = mb.get(supportedLanguageMap.get(language).split('~')[1]) != null ? String.valueOf(mb.get(supportedLanguageMap.get(language).split('~')[1])) : String.valueOf(mb.Content__c);
            }
        }

        tpaRequest = new TPA_Request__c();
        
        if(amaDataOffering == null) {
            amaDataOffering = Requires_AMA_Data_For_Offerings__c.getAll().values();
        }
        if(currentLoggedInUser != NULL) {
            tpaRequest.ClientContact__c = currentLoggedInUser.contactId;
            if(currentLoggedInUser.contact.Client_Contact_Territory__c != '') {
                tpaRequest.Client_Contact_Territory__c = currentLoggedInUser.contact.Client_Contact_Territory__c;
                tpaRequest.Secondary_Client_Contact_Territory__c = currentLoggedInUser.contact.Client_Contact_Territory__c;
                tpaRequest.Secondary_Location_Required__c = false;
            }
        }

        isShowVendorMessageBoard = UTL_TPA.tpaSetting.Is_Show_Vendor_Message_Board__c;
        if(tpaReqId != null) {
            List<TPA_Request__c> requestList = [Select id, Vendor_Language__c,Client_Address__c, Client_Address__r.TPA_Address_Country__c from TPA_Request__c where id =: tpaReqId];
            if(requestList != null && requestList.size() > 0) {
                TPA_Request__c tpaReqToEdit = requestList[0];
                if(tpaReqToEdit != null) {
                    if(tpaReqToEdit.Client_Address__c != null && tpaReqToEdit.Client_Address__r.TPA_Address_Country__c != null) {
                        setClientCountryDetails(tpaReqToEdit.Client_Address__r.TPA_Address_Country__c);
                    }
                    isLastSelectedLanguageSet = tpaReqToEdit.Vendor_Language__c != null ? true : false;
                }
            }
        }
    }

    public class My2Exception extends Exception {} 
    public static String TPA_CONTACTTYPE_ADDITIONAL = 'Additional Client Contact';
    public static String TPA_ADDITIONAL_CLIENT_CONTACT = 'Additional Contact';
    public static String TPA_CONTACTTYPE_SUBCONTRACTOR = 'SubContractor Contact';
    public static String TPA_ADDITIONAL_VENDOR_CONTACT = 'Additional Vendor Contact';
    public static Boolean isAwaitingClientConfirmationMailReq = false;

    

    public static AMA_Agreement_Detail__c amaAgreementDetails;
    public static Map<ID, TPA_Text_Editor__C> mapOfIdWithTextEditorObj;



    public boolean isShowVendorMessageBoard {get;set;}
    public string msgPrimaryBoardContent {get; set;}
    public String msgBoardContent {get; set;}
    public TPA_Request__c tpaRequest {get; set;}
    
    public TPA_Request__c tpaRequestToEdit {get; set;}
    
    public string reqObjString {get; set;}
    public string requestSubmissionResult {get; set;} 
    public User vendorCurrentUser { get; set; } 
    public string isAuthorisedSigner {get; set;}    
    public boolean isBulkRequest {get; set;}
    public String existingTllaLanguage {get; set;}
    public string isRenewedReqUseandOfferingChanged {get; set;}
    public boolean isVendorPartVisibleToClient {get; set;}
    public String clientEmail {get;set;} // to Check if The Client and Vendor Email extensions are not same 

    
    
    public static string clientNote {get; set;}
    public static string VendorNote {get; set;}
    public static string clientVendorNote {get; set;}
    
    public static List<Requires_AMA_Data_For_Offerings__c> amaDataOffering {get;set;}
    
    public boolean isClientFromUS {get; set;} 
    public boolean isLastSelectedLanguageSet {get; set;}
    
    
    public boolean isRestrictedUser { get; set; } 
    public String userId {get; set;}
    public static string isQaTesting {get; set;}
    public existedUsesAndAssets existedUsesAndAssetsData {get;set;}
    public static String language {get; set;}
    
    
    
    public static string GUID {
        get {
            if(GUID == null) {
                GUID = UTL_LogFactory.Guid;
            }
            return GUID;
        }
        set;
    }
    
    
    public static string jsonAmaDataOffering {
        get {
            if(amaDataOffering!= null) {
                jsonAmaDataOffering = JSON.serialize(amaDataOffering);
            }
            return jsonAmaDataOffering;
        }
        set;
    }
    
    
    //Added for site to community logic submission start
    public static string currentUserProfileName {
        get {
            if(currentUserProfileName == null) {
                currentUserProfileName = currentLoggedInUser.Profile.Name;
            }
            return currentUserProfileName;
        }
        set;
    }
    
    public static Boolean isBulkMatrixAccess {
        get {
            if(isBulkMatrixAccess == null){
                String permissionSetName = '';
                List<PermissionSetAssignment> lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :currentLoggedInUser.Id AND PermissionSet.Name = 'TPA_Bulk_Matrix_Access'];
                if(lstcurrentUserPerSet != null && lstcurrentUserPerSet.size() != 0) {
                    permissionSetName = lstcurrentUserPerSet[0].PermissionSet.Name;
                    return true;
                }
                return false;
            }
            return isBulkMatrixAccess;
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

    public static string getlastSelectedAddressRcrd{
        get {
            if(getlastSelectedAddressRcrd == null) {
                getlastSelectedAddressRcrd = '[]';
                List<TPA_Request__c> reqList= [Select id,Client_Address__c,CreatedDate from TPA_Request__c where ClientContact__c = :currentLoggedInUser.contact.Id order by CreatedDate  desc limit 1];
                if(reqList != null && reqList.size() > 0 ){
                    List<Contact_Address_Crosswalk__c> contactAddressCrosswalkList = [SELECT Id, Address__c,Address__r.Name,Address__r.Region_Territory__c
                                                                          FROM Contact_Address_Crosswalk__c
                                                                          WHERE Address__c =: reqList[0].Client_Address__c];
                    if(contactAddressCrosswalkList != null && contactAddressCrosswalkList.size() > 0) {
                        getlastSelectedAddressRcrd = JSON.serialize(contactAddressCrosswalkList);
                    }
                

                }
                else{
                    getlastSelectedAddressRcrd = JSON.serialize(UTL_TPA.getContactAddressCrowalk(currentLoggedInUser.contact.Id));
                }
                return getlastSelectedAddressRcrd;
            } else {
                return getlastSelectedAddressRcrd;
            }
        }
        set;
    }
    public static string getContactAddressCrowalk { 
        get {
            if(getContactAddressCrowalk == null) {
                getContactAddressCrowalk = JSON.serialize(UTL_TPA.getContactAddressCrowalk(currentLoggedInUser.contact.Id));
                return getContactAddressCrowalk;
            } else {
                return getContactAddressCrowalk;
            }
        }
        set;
    }

    public string getDependentVendorStateCountries{
        get{
            if(getDependentVendorStateCountries == null)
            {
                getDependentVendorStateCountries = JSON.serialize(TPA_DependentPicklists.GetDependentOptions('tpa_request__c', 'Vendor_Billing_Mailing_Country__c', 'Vendor_Billing_Mailing_State_Province__c'));
            }
            return getDependentVendorStateCountries;
        }
        set{getDependentVendorStateCountries = value;}
    }
    //Added by C.P.Pandey under CR-9059 end
    public string getDependentVendorComplianceStateCountries{
        get{
            if(getDependentVendorComplianceStateCountries == null)
            {
                getDependentVendorComplianceStateCountries = JSON.serialize(TPA_DependentPicklists.GetDependentOptions('tpa_request__c', 'Vendor_Compliance_Country__c', 'Vendor_Compliance_State__c'));
            }
            return getDependentVendorComplianceStateCountries;
        }
        set{getDependentVendorComplianceStateCountries = value;}
    }

    public static set<string> createStateCountryNameSet(string countryStateName, string requestType) {
        countryStateName = countryStateName.toLowerCase();
        set<string> countryStateNameList = new set<string>();
        set<string> tempCountryStateNameSet;
        if(existedCountryStateCodes == null ) {
            existedCountryStateCodes = [select name, Country_Possible_Codes__c, Code_Type__c from TPA_Country_Codes__c];
        }
        if(existedCountryStateCodes != null && existedCountryStateCodes.size() > 0) {
            for(TPA_Country_Codes__c tpaCountryCodeObj : existedCountryStateCodes) {
                if(tpaCountryCodeObj.Code_Type__c != requestType) {
                    continue;
                }
                tempCountryStateNameSet = new set<string>();
                if(tpaCountryCodeObj.Country_Possible_Codes__c != null && tpaCountryCodeObj.Country_Possible_Codes__c.trim().length() > 0){
                    tempCountryStateNameSet.addAll(tpaCountryCodeObj.Country_Possible_Codes__c.trim().toLowerCase().split(';'));
                }
                if(tpaCountryCodeObj.name.trim() == countryStateName || tempCountryStateNameSet.contains(countryStateName)) {
                    countryStateNameList = tempCountryStateNameSet;
                    countryStateNameList.add(tpaCountryCodeObj.name.toLowerCase().trim());
                    break;
                }
            }
        }
        return countryStateNameList;
    }

    public static void sendMailToTPProcessorClientAddressisNULL(TPA_Request__c tpaRequest) {
        List<String> toAddress = new List<String>{tpaRequest.TP_Processor_Email__c};
        List<String> ccAddresses = new List<String>();
        if(UTL_TPA.billingAddressMissOnAccRecipientLst != null) {
            for(String emailToCc: UTL_TPA.billingAddressMissOnAccRecipientLst.split(';')) {
                ccAddresses.add(emailToCc);
            }
        }

        SRV_TPA_TPARequest.sendTPANotifications(toAddress, ccAddresses, 'Billing Adderss Missing No TLLA', 'English', tpaRequest.id, true, null, null, FALSE, FALSE, null);
    }

    @remoteAction
    public static string getUserProfileName() {
        return currentUserProfileName;
    }
    
   
   
    
    public String Message { 
        get{
            String content = textEditorRecords('Shutdown Message');
            if(Message == null && content != null){
                Message = content;
            }else if(content == null){
                Message = Label.TPA_Downtime_Message;
            }
            return Message;
        }
        set; 
    }
   
    

    public Boolean vendorDocumentLanguageEnabled{
        get{
            return TPA_Settings__c.getOrgDefaults().French_Vendor_Language__c;
        }
        set;
    }

   
    public static Map<String, String> supportedLanguageMap {
        get {
            if(supportedLanguageMap == null) {
                supportedLanguageMap = new Map<String, String>();
                for(string langCodeMapObj : UTL_TPA_Multilingual.SuppLangCodeFieldNameLocalName.split(';')) {
                    supportedLanguageMap.put(langCodeMapObj.split('=')[0], langCodeMapObj.split('=')[1]);
                }
            }
            return supportedLanguageMap;
        }
        private set;
    }
    
    public static string isRenewedorModifiedRenewed { 
        get {
            if(isRenewedorModifiedRenewed == null) {
                string tpaReqId = ApexPages.currentPage().getParameters().get('id');
                List<TPA_Request__c> tpaRequestList = new List<TPA_Request__c>();
                tpaRequestList = [SELECT id, name, lastmodifieddate, lastmodifiedby.name, Renewed_Type__c,Request_Type__c, Is_Partially_Renewed__c,Parent_Request__c,Parent_Request__r.Renewed_Type__c FROM TPA_Request__c WHERE Id = : tpaReqId ];
                if(tpaRequestList.size() > 0) {
                    for(TPA_Request__c a: tpaRequestList) {
                        if(a.Request_Type__c != null && a.Request_Type__c == 'renew' && (a.Parent_Request__r.Renewed_Type__c != null && a.Parent_Request__r.Renewed_Type__c == 'Renewed')){
                            isRenewedorModifiedRenewed = 'Renewed';
                        }
                        else if(a.Request_Type__c != null && a.Request_Type__c == 'renew' && (a.Parent_Request__r.Renewed_Type__c != null && a.Parent_Request__r.Renewed_Type__c == 'Modified Renewal')){
                            isRenewedorModifiedRenewed = 'Modified Renewal';
                        }
                    }
                }
                return isRenewedorModifiedRenewed;
            } else {
                return isRenewedorModifiedRenewed;
            }
        }
        set;
    }
	    
    public static string TLLA_Doc { 
        get {
            if(TLLA_Doc == null) {
                string tpaReqId = ApexPages.currentPage().getParameters().get('id');
                List<Attachment> lstAttachment = new List<Attachment>();
                lstAttachment = [SELECT id, name, lastmodifieddate, lastmodifiedby.name FROM Attachment WHERE ParentId = : tpaReqId ORDER BY lastmodifieddate desc];
                if(lstAttachment.size() > 0) {
                    for(Attachment a: lstAttachment) {
                        if(a.Name.indexOf('_TLLA_') != -1 && a.name.toLowerCase().IndexOf('_completed') != -1){
                            TLLA_Doc = a.Id;
                        }
                    }
                }
                return TLLA_Doc;
            } else {
                return TLLA_Doc;
            }
        }
        set;
    }
    
    public static string AMA_Doc { 
        get {
            if(AMA_Doc == null) {
                string tpaReqId = ApexPages.currentPage().getParameters().get('id');
                List<Attachment> lstAttachment = new List<Attachment>();
                lstAttachment = [SELECT id, name, lastmodifieddate, lastmodifiedby.name FROM Attachment WHERE ParentId = : tpaReqId ORDER BY lastmodifieddate desc];
                if(lstAttachment.size() > 0) {
                    for(Attachment a: lstAttachment) {
                        if(a.Name.indexOf('AMA_') != -1 && a.name.toLowerCase().IndexOf('_completed') != -1){
                            AMA_Doc = a.Id;
                        }
                    }
                }
                return AMA_Doc;
            } else {
                return AMA_Doc;
            }
        }
        set;
    }

    public string getLanguageMap() {
        return JSON.serialize(supportedLanguageMap);
    }
    
    public static Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap {
        get {
            if(multilanguageUtilityMap == null) {
                multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{supportedLanguageMap.get(language != null ? language : 'en_US').split('~')[1]});
            }
            return multilanguageUtilityMap;
        }
        private set;
    }
    
    public static Map<String, String> secAssetFieldMap { 
        get {  
            if(secAssetFieldMap == null) {
                secAssetFieldMap = new Map<String, String>();
                if(Label.TPA_Sec_Asset_Field_Map.split(',') != null) {
                    for(string secAssetField : Label.TPA_Sec_Asset_Field_Map.split(',')) {
                        secAssetFieldMap.put(secAssetField.split('~')[0], secAssetField.split('~')[1]);
                    }
                }
            }
            return secAssetFieldMap;
        }
        private set{secAssetFieldMap = value;}
    }

    public string getSecDataAssetFieldMap() {
        return JSON.serialize(secAssetFieldMap);
    }

    public static Map<String, String> priAssetFieldMap { 
        get {
            if(priAssetFieldMap == null) {
                priAssetFieldMap = new Map<String, String>();
                if(Label.TPA_Primary_Asset_Field_Map.split(',') != null) {
                    for(string priAssetField : Label.TPA_Primary_Asset_Field_Map.split(',')) {
                        priAssetFieldMap.put(priAssetField.split('~')[0], priAssetField.split('~')[1]);
                    }
                }
            }
            return priAssetFieldMap;
        }
        private set{priAssetFieldMap = value;}
    }

       // Added By Neha Bansal under CR-12673 Starts
       public static List<String> approvedCountriesForRemoteAccess{
        get{
            if(approvedCountriesForRemoteAccess == null){
                approvedCountriesForRemoteAccess = new List<String>();
                String editorData = system.Label.TPA_Approval_Countries_RemoteAccess;
                if(editorData != null){
                    approvedCountriesForRemoteAccess = editorData.split('~');
                }
            }
            return approvedCountriesForRemoteAccess;
        }
        private set{approvedCountriesForRemoteAccess = value;}
    }

    public static List<String> ApprovedCountriesForStorage{
        get{
            if(ApprovedCountriesForStorage == null){
                ApprovedCountriesForStorage = new List< String>();
                String editorData = system.Label.TPA_Approval_Countries_ForStorage;
                if(editorData != null){
                ApprovedCountriesForStorage = editorData.split('~');
                }
            }
            return ApprovedCountriesForStorage;
        }
        private set{ApprovedCountriesForStorage = value;}
    }

    public TPA_Data_Asset__c getPriDataAssetField (TPA_Data_Asset__c fromPriDaObj, TPA_Data_Asset__c toPriDaObj) {
        Set<String> setPriDataAssetFields = new Set<String>();
        setPriDataAssetFields.addAll(Label.TPA_Primary_Data_Asset_Field_Name.split(';'));
        for(String filedName : setPriDataAssetFields) {
            if(fromPriDaObj.get(filedName) != null) {
                toPriDaObj.put(filedName,fromPriDaObj.get(filedName));
            }
        }
        return toPriDaObj;
    }

    public TPA_Secondary_Data_Asset__c getsecDataAsset (TPA_Secondary_Data_Asset__c secDaObj) {
        TPA_Secondary_Data_Asset__c secDataAssetObj = new TPA_Secondary_Data_Asset__c ();
        Set<String> setSecDataAssetFields = new Set<String>();
        setSecDataAssetFields.addAll(Label.TPA_Sec_Data_Asset_Field_Name.split(';'));
        for(String filedName : setSecDataAssetFields) {
            if(secDaObj.get(filedName) != null) {
                secDataAssetObj.put(filedName,secDaObj.get(filedName));
            }
        }
        return secDataAssetObj;
    }    

    
    
	public string getTLLALanguage() {
        List<string> languages = new List<string>();
        languages.add('--None--');
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.TLLA_Language_Chosen__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            languages.add(f.getLabel());
        }
        return JSON.serialize(languages);
    }

    enum statusType {
        VendorRegistrationNumberNotExisted, //If no such registration number exists
        RegistrationNumberAccountNotMatched, //If Registration number existed but its Account is not existed.
        RegistrationNumberContactNotMatched, //If Registration number and account is existed but its Contact is not existed.
        DifferentVendorContactAccount, //If Contact is not associated with given account.
        DifferentAuthorizedSignerContactAccount, //If Authorized Signer Contact is not associated with given account.
        PotentialNewVendor, //If Control number is not existed and vendor is new.
        Valid, //If No error.
        NullObject //If Passed argument is Null.
    }

    enum clientRequestMode {
        RegistrationNumberCheck,
        VendorAccountCheck,
        AuthorizedSignerCheck
    }


    public string getPriDataAssetFieldMap() {
        return JSON.serialize(priAssetFieldMap);
    }
    
    public string getTranslatedMap() {
        return JSON.serialize(multilanguageUtilityMap);
    }
    
    

    public PageReference requestValidateOnLoad() {
        //Added for site to community logic submission start
        if(currentLoggedInUser.Profile.Name == 'tpa Profile') {
            system.debug('In check profile0:::' + currentLoggedInUser.Profile.Name);
            return null;
        }
        //Added for site to community logic submission end
        
        List<TPA_Country_Codes__c> lstCountryStatesCodes = new List<TPA_Country_Codes__c>();
        lstCountryStatesCodes = [select name, Country_Possible_Codes__c, Code_Type__c from TPA_Country_Codes__c];
        strContryStateCode = JSON.serialize(lstCountryStatesCodes);

        List<Group> listOfGroup = [SELECT Id, DeveloperName,name  FROM Group where id in (SELECT GroupId FROM GroupMember WHERE Group.Type = 'Queue' and UserOrGroupId = :UserInfo.getUserId())];
        queueList = JSON.serialize(listOfGroup);

        String lastGroupID; 
        if(listOfGroup != null && listOfGroup.size() > 0 ){
            List<TPA_Request__c> reqList = [Select id,Owner.Id from TPA_Request__c where ClientContact__c = :currentLoggedInUser.contact.Id and Owner.Type = 'Queue' order by CreatedDate  desc limit 1];
            if(reqList != null && reqList.size() > 0 ){
                lastGroupID = reqList[0].Owner.Id;
            }
        }
        getlastSelectedQueueRcrd = JSON.serialize(lastGroupID);
        
        // todo GUID = TPAQueryHelper.Guid; //todo

        tpaRequestId = ApexPages.currentPage().getParameters().get('id');
        tpaRequestEditType = ApexPages.currentPage().getParameters().get('type');
        tpaRequestCallType = ApexPages.currentPage().getParameters().get('requestType');
        userId = ApexPages.currentPage().getParameters().get('uid');

        isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
        String restrictedUserIds = Label.TPA_Non_Restricted_Users;
        //Message = Label.TPA_Downtime_Message;
        isRestrictedUser = true;
        if(userId != null && userId.length() > 14) {
            userId = userId.subString( 0, 15 );
            if( restrictedUserIds.contains( userId )) {
                isRestrictedUser = false;
            }
            else if(isTPAPermanentDown) {
                isRestrictedUser = true;
            }
        }
        isQaTesting = ApexPages.currentPage().getParameters().get('isQaTesting');
        if(isTPAPermanentDown == true && isQaTesting == 'true'){
            isTPAPermanentDown=false;
            
        }
        else if (isTPAPermanentDown == true){
            isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
            //Message = Label.TPA_Downtime_Message;
        }

        if(isTPProcessor && tpaRequestId == null) {
            return new PageReference('/VFP_TPA_Page_Status?type=unauthenticated');
        }

        if(tpaRequestId != null 
          && tpaRequestEditType != null 
          && !String.IsBlank(tpaRequestId) 
          && !String.IsBlank(tpaRequestEditType)) {
            //loadUsesAndAssets(tpaRequestId);
            
            if(  ( currentLoggedInUser.Profile.Name == 'TPA Vendor Community User' 
                   && tpaRequestEditType != null 
                   && tpaRequestEditType.trim() == 'v' 
                   && tpaRequestCallType != null 
                   && tpaRequestCallType == 'edit'
                 ) 
              || ( currentLoggedInUser.Profile.Name != 'TPA Vendor Community User' 
                   && tpaRequestEditType != null 
                   && tpaRequestEditType.trim() == 'c' 
                   && tpaRequestCallType != null 
                   && (   tpaRequestCallType == 'edit' 
                       || tpaRequestCallType == 'clone' 
                       || tpaRequestCallType == 'renew' 
                       || tpaRequestCallType == 'view'
                      )
                  )
               ) {
                tpaRequestToEdit = SRV_TPA_TPARequest.getRequestInfo(tpaRequestId);
                
                List<User> vendorCurrentUserList = new List<User>([Select Id, 
                                                                          Name, 
                                                                          Email, 
                                                                          CompanyName 
                                                                   from User 
                                                                   where Contact.Id =: tpaRequestToEdit.ClientContact__c 
                                                                   Limit 1]);
                if(vendorCurrentUserList.size() > 1) {
                    vendorCurrentUser = vendorCurrentUserList[0];
                }
                if(tpaRequestToEdit != null) {
                    isVendorPartVisibleToClient = (tpaRequestEditType == 'c' && !isTPProcessor && (tpaRequestToEdit.LastAction__c == 'Request Edited By Vendor' || tpaRequestToEdit.LastAction__c == 'Request Edited By TP Processor' || tpaRequestToEdit.LastAction__c == 'Request Submitted By Vendor') && (tpaRequestCallType != 'clone' && tpaRequestCallType != 'renew')); 
                    if(tpaRequestEditType == 'v' && (tpaRequestToEdit.LastAction__c == 'Request Edited By Vendor' || tpaRequestToEdit.LastAction__c == 'Request Edited By TP Processor' || tpaRequestToEdit.LastAction__c == 'Request Submitted By Vendor')) {
                        return new PageReference('/VFP_TPA_Page_Status?type=vendoralreadysubmitted&&requestStatus=' + tpaRequestToEdit.Request_Status__c + '&reqNo=' +tpaRequestToEdit.name+ '&lang=' + UTL_TPA_Multilingual.supportedLanguageCodeMap.get(tpaRequestToEdit.Vendor_Language__c == null ? 'English' : tpaRequestToEdit.Vendor_Language__c));
                    }
                    if(tpaRequestToEdit.Is_Renewed__c && tpaRequestCallType == 'renew') {
                        return new PageReference('/VFP_TPA_Page_Status?type=requestHasBeenRenewed&&requestStatus=' + tpaRequestToEdit.Request_Status__c + '&lang=' + UTL_TPA_Multilingual.supportedLanguageCodeMap.get(tpaRequestToEdit.Client_Language__c == null ? 'English' : tpaRequestToEdit.Client_Language__c));
                    }

                    if(validateLoadRequestType(tpaRequestCallType, tpaRequestToEdit.Request_Status__c, tpaRequestEditType) == 'valid') {
                        if(tpaRequestToEdit != null ) {
                            isAuthorisedSigner = tpaRequestToEdit.TPA_Authorised_Signer__c; 
                            isBulkRequest = tpaRequestToEdit.is_Bulk_TPA_Request__c;
							existingTllaLanguage = tpaRequestToEdit.TLLA_Language_Chosen__c;               
                        }
                        tpaRequest.Client_Contact_Territory__c = tpaRequestToEdit.Client_Contact_Territory__c;
                        tpaRequest.Vendor_Billing_Mailing_Country__c = tpaRequestToEdit.Vendor_Billing_Mailing_Country__c;
                        tpaRequest.Vendor_Billing_Mailing_State_Province__c = tpaRequestToEdit.Vendor_Billing_Mailing_State_Province__c;
                        clientEmail = tpaRequestToEdit.Client_Email__c;
                    }
                    else {
                        return new PageReference('/VFP_TPA_Page_Status?type=unauthenticated&&requestStatus=' + tpaRequestToEdit.Request_Status__c);
                    }
                }
            }

            if( currentLoggedInUser.Profile.Name == 'TPA Vendor Community User' 
                && tpaRequestEditType != null 
                && tpaRequestEditType.trim() == 'v') {
                UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, GUID, UTL_TPA.savePoints.get('5S'), 'TPA', 'Custom', 'INFO', tpaRequestToEdit.Name, tpaRequestToEdit.Id);
            }
             else if(currentLoggedInUser.Profile.Name != 'TPA Vendor Community User' 
                    && tpaRequestEditType != null 
                    && tpaRequestEditType.trim() == 'c' 
                    && tpaRequestCallType != null) {
                if(tpaRequestCallType.trim() == 'edit') {
                    UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, GUID, UTL_TPA.savePoints.get((isTPProcessor || isUSTPProcessor)?'4S':'3S'), 'TPA', 'Custom', 'INFO', tpaRequestToEdit.Name, tpaRequestToEdit.Id);
                }
                else if(tpaRequestCallType.trim() == 'renew') {
                    UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, GUID, UTL_TPA.savePoints.get(isUSTPProcessor?'9S':'8S'), 'TPA', 'Custom', 'INFO', 'Renewed From:' + tpaRequestToEdit.Name, '');
                }
                else if(tpaRequestCallType.trim() == 'clone') {
                    UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, GUID, UTL_TPA.savePoints.get(isUSTPProcessor?'7S':'6S'), 'TPA', 'Custom', 'INFO', 'Cloned From:' + tpaRequestToEdit.Name, '');
                }
            }
            
            if(currentLoggedInUser.Profile.Name == 'TPA Vendor Community User' 
               && tpaRequestEditType != null 
               && tpaRequestEditType.trim() == 'v' 
               && tpaRequestCallType != null 
               && tpaRequestCallType.trim() == 'edit' ) {
                formDisplayMode = 'VDV';
            } 
            else if( currentLoggedInUser.Profile.Name != 'TPA Vendor Community User' 
                       && tpaRequestEditType != null 
                       && tpaRequestEditType.trim() == 'c' 
                       && tpaRequestCallType != null 
                       && (tpaRequestCallType.trim() == 'edit' || tpaRequestCallType.trim() == 'view')
                     ) {
                formDisplayMode = 'CDV';
            } 
            else if( currentLoggedInUser.Profile.Name != 'TPA Vendor Community User' 
                       && tpaRequestEditType == null 
                       && tpaRequestToEdit == null 
                       && tpaRequestCallType == null) {
                formDisplayMode = 'NV';
            } 
            else if( currentLoggedInUser.Profile.Name != 'TPA Vendor Community User' 
                       && tpaRequestEditType != null 
                       && tpaRequestEditType.trim() == 'c' 
                       && tpaRequestCallType != null 
                       && (tpaRequestCallType.trim() == 'clone' || tpaRequestCallType.trim() == 'renew')) {
                formDisplayMode = 'NV';
            } 
            else if(currentLoggedInUser.Profile.Name == 'TPA Vendor Community User'
                       && tpaRequestEditType != null 
                       && tpaRequestEditType.trim() == 'c'){
                return null;
            }
            else {
                return new PageReference('/VFP_TPA_Page_Status?type=invalid');
            }
        }
        else if(tpaRequestId == null && currentLoggedInUser.Profile.Name != 'TPA Vendor Community User') {
            formDisplayMode = 'NV';
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, GUID, UTL_TPA.savePoints.get(isUSTPProcessor?'2S':'1S'), 'TPA', 'Custom', 'INFO', isUSTPProcessor?'By US TP Processor':'By Client', '');
            
            return null;
        }
        else {
            return new PageReference('/VFP_TPA_Page_Status?type=invalid');
        }
        // todo TPAQueryHelper.logRef().generateLog(); 
        return null;
    }

    public String getCountries()
    {
        // Return the JSON value
        system.debug(multilanguageUtilityMap.get('English_Translation__c'+'~TPA_Request__c~Picklist~Region__c'));
        string languageCode = supportedLanguageMap.get(language != null ? language : 'en_US').split('~')[1];
        return JSON.serialize( multilanguageUtilityMap.get(languageCode+'~TPA_Request__c~Picklist~Region__c') );
    }

    //Wrapper class to store existing TPA request data
    public class existingTPARequestData {
        public Integer index;
        public List<TPA_Purpose__c> existedTpaPurposes;
        public List<TPA_Data_Asset__c> existedTpaAssets;
        public List<TPA_Secondary_Data_Asset__c> existedSecTpaAssets;
        public List<IMS_TPA_Purpose__c> lstIMSTPAPurpose;
        public List<String> usesMappedToAnotherUse;
        public List<string> removedUses;
        public List<String> usesMappedToAnother;
        public List<String> offeringUsesMappedToAnother;
        public List<string> removedOfferings;
        public List<string> primaryOffNotToRemove;
        public Map<String, IMS_TPA_Purpose_Description__c> mapIMSTPADescription;
        public List<IMS_TPA_Purpose_Description__c> lstIMSTPADescription;
        public Map<Id,String> mapIdWithName;
        public List<TPA_Purpose_Description__c> existedTpaPurpDesc;
        public Map<String,TPA_Purpose__c> PurposeMapOther;
        public Map<String,TPA_Purpose_Description__c> MapPurpDescOther;
        public Map<String,TPA_Purpose__c> PurposeMap;
        public Map<String,TPA_Purpose_Description__c> MapPurpDesc;
        public string translationLanguageField;

        //Map - Map of all primary data assets selected under a particular purpose/use
        //Key - IMS_tpa_purpose_Id : Purpose_category_Id : country :  (For Non 'Other' Use)
        //Key -  : country : Purpose_category_Id : other_Use_decs   (For 'Other' Use)
        //Value - set of all primary data assets selected under a particular purpose/use
        public Map<String,set<TPA_Data_Asset__c>> mapPurposeidWithDataAssetMap;

        //Map - Map of all secondary data assets selected under a particular purpose/use
        //Key - IMS_data_asset_Id : IMS_tpa_purpose_Id : Purpose_category_Id : country :  (For Non 'Other' Use)
        //Key - IMS_data_asset_Id :: Purpose_category_Id : country : Other_Use_Decs (For 'Other' Use)
        //Value - set of all secondary data assets selected under a particular purpose/use
        public Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetToInsert;

        public Map<String, String> secDAToRemoveMap;
        public Map<String,wrapperClassAssetPurpose> wrapperPurpAssetListObject;
        public Map<String, integer> SelectedDescIndexMap;
        public boolean isAmaTab;
        public string selectedSecondaryIds;    
        public Map<String, List<String>> mapOfOfferingWithAdditionalFields;    

        public existingTPARequestData() {
            existedTpaPurposes = new List<TPA_Purpose__c>();
            existedTpaAssets = new List<TPA_Data_Asset__c>();
            existedSecTpaAssets = new List<TPA_Secondary_Data_Asset__c>();
            lstIMSTPAPurpose = new List<IMS_TPA_Purpose__c>();
            usesMappedToAnotherUse = new List<string>();
            removedUses = new List<string>();
            usesMappedToAnother = new List<String>();
            offeringUsesMappedToAnother = new List<String>();
            removedOfferings = new List<String>();
            primaryOffNotToRemove = new List<String>();
            mapIMSTPADescription = new Map<String, IMS_TPA_Purpose_Description__c>();
            lstIMSTPADescription = new List<IMS_TPA_Purpose_Description__c>();
            mapIdWithName = new Map<Id,string>();
            existedTpaPurpDesc = new List<TPA_Purpose_Description__c>();
            PurposeMapOther = new Map<String,TPA_Purpose__c>();
            MapPurpDescOther = new Map<String,TPA_Purpose_Description__c>();
            PurposeMap = new Map<String,TPA_Purpose__c>();
            MapPurpDesc = new Map<String,TPA_Purpose_Description__c>();
            translationLanguageField = '';
            mapPurposeidWithDataAssetMap = new Map<String,set<TPA_Data_Asset__c>>();
            mapSecondayDataAssetToInsert = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
            secDAToRemoveMap = new Map<String, String>();
            wrapperPurpAssetListObject = new Map<String,wrapperClassAssetPurpose>();
            SelectedDescIndexMap = new Map<String, integer>();
            selectedSecondaryIds = '';
            mapOfOfferingWithAdditionalFields = new  Map<String, List<String>>();
        } 
    }

    //public static existingTPARequestData existingDataObjP;
    // public string getExistedUsesAndAssetsJSON() {
    //     return JSON.serialize(existingDataObjP);
    // }

    public string getProposalTreeObjJSON() {
        return getProposalTreeData();
    }

    @remoteAction
    public static string loadTPProcessorDetils(String territory) {
        String getTPPROcessorDetils;
        if(territory != '') {
            set<string> secCountryCodeSet = createStateCountryNameSet(territory, 'C');
            if(secCountryCodeSet != null && secCountryCodeSet.size() > 0) {
                List<TPA_Region_Country__c> lstRegionCountry = new List<TPA_Region_Country__c>();

                lstRegionCountry = [select TP_Processor__c,
                                    TP_Processor__r.region__c,
                                    TP_Processor__r.TP_Processor_Name__c,
                                    TP_Processor__r.TPA_Processor_Contact__c,
                                    TP_Processor__r.TPA_Processor_Contact__r.accountid,
                                    TP_Processor__r.TP_Processor_Email__c, 
                                    TP_Processor__r.Assigned_TP_Processors__c
                                from TPA_Region_Country__c
                                where Country__c in: secCountryCodeSet
                                limit 1 ];
                                if(lstRegionCountry.size() != 0 && lstRegionCountry[0].TP_Processor__c != null) {
                                        getTPPROcessorDetils = UTL_TPA.getAddressId(lstRegionCountry[0].TP_Processor__r.TPA_Processor_Contact__r.id);
                                }
                            }            
        }
        return getTPPROcessorDetils;
    }

    @remoteAction
    public static existingTPARequestData loadUsesAndAssets(string RequestId, string lastRecId, String buttonType, String isclientORVendor) {
       
        
        String USEQueryForVendor = 'select Id,purpose__r.English_Translation__c,purpose__r.Japanese_Translation__c, '
            + 'Name,Purpose__c,Purpose__r.Name,Purpose__r.primary_purpose_name__c,BU__c, '
            + 'Purpose_Region__c,TPA_Purpose_Category__c,Other_Details__c,Other_Text__c, '
            + 'Purpose__r.Is_Active__c,TPA_Purpose_Category__r.Category_Name__c, '
            + 'TPA_Purpose_Category__r.English_Translation__c,TPA_Purpose_Category__r.Japanese_Translation__c '
            + 'from TPA_Purpose__c where Request__c =: requestId ';
        
        existingTPARequestData existingDataObj = new existingTPARequestData();
        List<TPA_Purpose__c> existedTpaPurposes = new List<TPA_Purpose__c>();
        if(isclientORVendor == 'Client'){
            existedTpaPurposes = [select Id,
                                  purpose__r.New_IMS_TPA_Purpose__c,
                                  purpose__r.New_IMS_TPA_Purpose__r.Primary_Purpose_Name__c,
                                  purpose__r.New_TPA_Purpose_Category__c,
                                  purpose__r.New_TPA_Purpose_Category__r.Category_Name__c,
                                  purpose__r.English_Translation__c,
                                  purpose__r.Japanese_Translation__c,
                                  Name,
                                  TPA_Purpose_Category__r.isActive__c,
                                  Purpose__c,
                                  Purpose__r.Name,
                                  Purpose__r.primary_purpose_name__c,
                                  BU__c,
                                  Purpose_Region__c,
                                  TPA_Purpose_Category__c,
                                  Other_Details__c,
                                  Other_Text__c,
                                  Purpose__r.Is_Active__c,
                                  TPA_Purpose_Category__r.Category_Name__c,
                                  TPA_Purpose_Category__r.English_Translation__c,
                                  TPA_Purpose_Category__r.Japanese_Translation__c
                                  from TPA_Purpose__c
                                  where Request__c =: requestId
                                  order by Id,TPA_Purpose_Category__r.Category_Name__c,Purpose__r.primary_purpose_name__c];
        } else if(lastRecId != null && lastRecId != '') {
            system.debug('in first if: ' );
            if(buttonType == 'next') {
                USEQueryForVendor += 'and Id >: lastRecId order by Id, TPA_Purpose_Category__r.Category_Name__c, '
                    +' Purpose__r.primary_purpose_name__c ASC Limit 100 ';
                existedTpaPurposes = Database.query(USEQueryForVendor);
            }
            else{
                USEQueryForVendor += 'and Id <= : lastRecId order by Id,TPA_Purpose_Category__r.Category_Name__c, '
                    + 'Purpose__r.primary_purpose_name__c  ASC Limit 100 ';
                existedTpaPurposes = Database.query(USEQueryForVendor);
            }
            
        } else {
            system.debug('in second if: ' );
            USEQueryForVendor += 'Order by Id,TPA_Purpose_Category__r.Category_Name__c, '
                + 'Purpose__r.primary_purpose_name__c ASC Limit 100 ';
            existedTpaPurposes = Database.query(USEQueryForVendor);
        }
        
        existingDataObj.existedTpaPurposes = existedTpaPurposes;
        
        List<TPA_Data_Asset__c> existedTpaAssets = new List<TPA_Data_Asset__c>();
        List<TPA_Secondary_Data_Asset__c> existedSecTpaAssets = new List<TPA_Secondary_Data_Asset__c>();
        
        if(isclientORVendor == 'Client'){
            
            existedTpaAssets = [select Id,Name,
                                Asset_NametText__c,
                                Asset_Name__c,
                                BU__c,
                                APLD_Study_Name__c,
                                APLD_Delivery_Date__c,
                                RWE_Study_Name__c,
                                RWE_Delivery_Date__c,
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
                                CWH_NZ_Scan_data__c,
                                STI_Data_Report_Name__c,
                                Customized_Data_Text__c,
                                Geo_Level__c,
                                Data_Asset__c,
                                Data_Asset__r.Asset_Name__c,
                                Data_Asset__r.English_Translation__c,
                                Data_Asset__r.Japanese_Translation__c,
                                Data_Asset__r.BU__c,
                                Data_Asset__r.Geo_Level__c,
                                Data_Asset__r.Is_IMS_AGProduct__c,
                                Data_Asset__r.Is_Restricted_Data__c,
                                Data_Asset__r.Is_Active__c,
                                Data_Asset__r.Delete_Error_Message__c,
                                Data_Asset__r.Map_To__c,
                                Data_Asset__r.Is_AMA_Required__c,
                                Purpose__r.purpose__r.New_IMS_TPA_Purpose__c,
                                Data_Asset__r.Map_To__r.Asset_Name__c,
                                Data_Asset__r.Map_To__r.English_Translation__c,
                                Data_Asset__r.Map_To__r.Japanese_Translation__c,
                                Data_Asset__r.Map_To__r.BU__c,
                                Data_Asset__r.Map_To__r.Geo_Level__c,
                                Data_Asset__r.Map_To__r.Is_IMS_AGProduct__c,
                                Data_Asset__r.Map_To__r.Is_Restricted_Data__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Secondary_Asset_Name__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.English_Translation__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Japanese_Translation__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.Asset_Name__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.BU__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.Geo_Level__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.Is_IMS_AGProduct__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.Is_Restricted_Data__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.Is_Active__c,
                                Is_IMS_AGProduct__c,
                                Is_Restricted_Data__c,
                                Other_Data_Asset_Details__c,
                                Other_Text__c,
                                Request__c,
                                Purpose__c,
                                Purpose__r.Name,
                                Purpose__r.TPA_Purpose_Category__c,
                                Purpose__r.TPA_Purpose_Category__r.isActive__c,
                                Purpose__r.Purpose__c,
                                Purpose__r.Purpose__r.Is_Active__c,
                                A_Column_Use_For_Template__c,
                                Purpose__r.TPA_Purpose_Category__r.Category_Name__c
                                from TPA_Data_Asset__c
                                where Request__c =: requestId
                                and Purpose__c in : existedTpaPurposes];
        }else{
            existedTpaAssets = [select Id,Name,Asset_NametText__c,Asset_Name__c,BU__c,Geo_Level__c,Data_Asset__c,Data_Asset__r.Asset_Name__c,
                                Data_Asset__r.English_Translation__c,Data_Asset__r.Japanese_Translation__c,Data_Asset__r.BU__c,
                                Data_Asset__r.Geo_Level__c,Data_Asset__r.Is_IMS_AGProduct__c,Data_Asset__r.Is_Restricted_Data__c,
                                Data_Asset__r.Is_Active__c,Data_Asset__r.Map_To__c,Data_Asset__r.Is_AMA_Required__c,Purpose__r.purpose__r.New_IMS_TPA_Purpose__c,
                                Data_Asset__r.Map_To__r.Asset_Name__c,Data_Asset__r.Map_To__r.English_Translation__c,Data_Asset__r.Map_To__r.Japanese_Translation__c,
                                Data_Asset__r.Map_To__r.BU__c,Data_Asset__r.Map_To__r.Geo_Level__c,Data_Asset__r.Map_To_Secondary_Data_Asset__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Secondary_Asset_Name__c,Data_Asset__r.Map_To_Secondary_Data_Asset__r.English_Translation__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Japanese_Translation__c,Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.Asset_Name__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.BU__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.Geo_Level__c,
                                Data_Asset__r.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.Is_Active__c,
                                Other_Data_Asset_Details__c,Other_Text__c,Request__c,Purpose__c,A_Column_Use_For_Template__c
                                from TPA_Data_Asset__c
                                where Request__c =: requestId
                                and Purpose__c in : existedTpaPurposes ];
        }
        existingDataObj.existedTpaAssets = existedTpaAssets;
        system.debug('existedTpaAssets: ' + existedTpaAssets.size());   
        if(isclientORVendor == 'Client'){                                     
            existedSecTpaAssets = [select Id,
                                   Secondary_Asset_Name__c,
                                   Purpose__c,
                                   IMS_Secondary_Data_Asset__c,
                                   IMS_Secondary_Data_Asset__r.Is_Active__c,
                                   IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c,
                                   Pro_Voice_Study_Name__c,
                                   Pro_Voice_Delivery_Date__c,
                                   Channel_Dynamics_Delivery_Date__c,
                                   Channel_Dynamics_Study_Name__c,
                                   BrandImpact_Delivery_Date__c,
                                   BrandImpact_Study_Name__c,
                                   AU_Profits__c,
                                   Nostradata_LRx_Volume__c,
                                   Nostradata_Source_of_Business_LRx__c,
                                   AU_DDD_Hospital_Profits__c,
                                   AU_Other_Outlet_Data_Profits__c,
                                   Combined_Hos_and_Ret_Profit_AU__c,
                                   Pharmacy_Scan__c,
                                   Outliner_Label_Code__c,
                                   Outliner_Data_Period_Text__c,
                                   STI_Data_Custom_Report_Name__c,
                                   IMS_Secondary_Data_Asset__r.English_Translation__c,
                                   IMS_Secondary_Data_Asset__r.Japanese_Translation__c,
                                   IMS_Secondary_Data_Asset__r.Delete_Error_Message__c,
                                   IMS_Secondary_Data_Asset__r.Is_AMA_Required__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__c,
                                   IMS_Secondary_Data_Asset__r.Primary_Data_Asset__c,
                                   IMS_Secondary_Data_Asset__r.Primary_Data_Asset__r.BU__c, 
                                   IMS_Secondary_Data_Asset__r.Primary_Data_Asset__r.Asset_Name__c, 
                                   IMS_Secondary_Data_Asset__r.Map_To__r.Primary_Data_Asset__r.Asset_Name__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__r.Secondary_Asset_Name__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__r.English_Translation__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__r.Japanese_Translation__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__r.Primary_Data_Asset__r.BU__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__r.Primary_Data_Asset__r.Geo_Level__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__r.Map_To_Primary_Data_Asset__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__r.Primary_Data_Asset__r.Is_IMS_AGProduct__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__r.Primary_Data_Asset__r.Is_Restricted_Data__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.Asset_Name__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.English_Translation__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.Japanese_Translation__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.BU__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.Geo_Level__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.Is_IMS_AGProduct__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.Is_Restricted_Data__c,
                                   TPA_Data_Asset__c,
                                   TPA_Data_Asset__r.Purpose__r.Purpose__c,
                                   TPA_Data_Asset__r.Purpose__r.Purpose__r.Is_Active__c,
                                   TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__c,
                                   TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.isActive__c,
                                   TPA_Data_Asset__r.BU__c,
                                   TPA_Data_Asset__r.Data_Asset__r.BU__c
                                   from TPA_Secondary_Data_Asset__c
                                   where TPA_Data_Asset__c in :existedTpaAssets];
        }
        else{
            existedSecTpaAssets = [select Id,Secondary_Asset_Name__c,IMS_Secondary_Data_Asset__c,IMS_Secondary_Data_Asset__r.Is_Active__c,
                                   IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c,IMS_Secondary_Data_Asset__r.English_Translation__c,
                                   IMS_Secondary_Data_Asset__r.Japanese_Translation__c,IMS_Secondary_Data_Asset__r.Is_AMA_Required__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__c,IMS_Secondary_Data_Asset__r.Primary_Data_Asset__c,
                                   IMS_Secondary_Data_Asset__r.Primary_Data_Asset__r.BU__c,IMS_Secondary_Data_Asset__r.Primary_Data_Asset__r.Asset_Name__c, 
                                   IMS_Secondary_Data_Asset__r.Map_To__r.Primary_Data_Asset__r.Asset_Name__c,IMS_Secondary_Data_Asset__r.Map_To__r.Secondary_Asset_Name__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__r.English_Translation__c,IMS_Secondary_Data_Asset__r.Map_To__r.Japanese_Translation__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__r.Primary_Data_Asset__r.BU__c,IMS_Secondary_Data_Asset__r.Map_To__r.Primary_Data_Asset__r.Geo_Level__c,
                                   IMS_Secondary_Data_Asset__r.Map_To__r.Map_To_Primary_Data_Asset__c,IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.Asset_Name__c,IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.English_Translation__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.Japanese_Translation__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.BU__c,
                                   IMS_Secondary_Data_Asset__r.Map_To_Primary_Data_Asset__r.Geo_Level__c,
                                   TPA_Data_Asset__c,TPA_Data_Asset__r.BU__c,TPA_Data_Asset__r.Data_Asset__r.BU__c
                                   from TPA_Secondary_Data_Asset__c
                                   where TPA_Data_Asset__c in :existedTpaAssets];     
        }
        
        existingDataObj.existedSecTpaAssets = existedSecTpaAssets;
        system.debug('existedSecTpaAssets: ' + existedSecTpaAssets.size());
        Set<Id> stIMSTPAPurposeId = new Set<Id>();
        List<IMS_TPA_Purpose__c> lstIMSTPAPurpose = new List<IMS_TPA_Purpose__c>();
        for(TPA_Purpose__c objPurpose : existedTpaPurposes) {
            stIMSTPAPurposeId.add(objPurpose.Purpose__c);
        }
        
        lstIMSTPAPurpose = [select id,
                            Primary_Purpose_Name__c,
                            Is_Active__c,
                            (select IMS_TPA_Purpose__c,
                             New_TPA_Purpose_Category__c,
                             New_TPA_Purpose_Category__r.Category_Name__c,
                             isActive__c,
                             TPA_Purpose_Category__c 
                             from IMS_TPA_Purpose_Categories__r) 
                            from IMS_TPA_Purpose__c 
                            where id in: stIMSTPAPurposeId];
        
        existingDataObj.lstIMSTPAPurpose = lstIMSTPAPurpose;
        system.debug('lstIMSTPAPurpose: ' + lstIMSTPAPurpose.size());
        
        for(IMS_TPA_Purpose_Description__c purposeDes : [select id,TPA_Purpose_Category__c,Purpose__c,Is_Active__c from IMS_TPA_Purpose_Description__c where Is_Active__c = true]) {
            string key = '' + purposeDes.Purpose__c + purposeDes.TPA_Purpose_Category__c;
            existingDataObj.mapIMSTPADescription.put(key, purposeDes);
        }
        system.debug('existingDataObj.mapIMSTPADescription : ' + existingDataObj.mapIMSTPADescription ); 
        //existingDataObj.mapIMSTPADescription = new Map<Id, IMS_TPA_Purpose_Description__c>([select id,TPA_Purpose_Category__c,Purpose__c,Is_Active__c from IMS_TPA_Purpose_Description__c]);
        existingDataObj.existedTpaPurpDesc = [select Other_Details__c, Purpose__c, Description__c, Description_Text__c from TPA_Purpose_Description__c where Purpose__c in: existedTpaPurposes];
        system.debug('existingDataObj.existedTpaPurpDesc : ' + existingDataObj.existedTpaPurpDesc.size() ); 
        
        existingDataObj.isAmaTab = false;
        Integer noOfRecords = 0;

        if(isclientORVendor != 'Client'){
            AggregateResult[] groupedResults = [SELECT count(id) from TPA_Data_Asset__c where Request__c =: requestId
                                and Data_Asset__r.Is_AMA_Required__c = true];
            if(groupedResults != null && groupedResults.size() > 0) {
                for (AggregateResult ar : groupedResults)  {
                    noOfRecords = Integer.valueOf(ar.get('expr0')) ;
                    if(noOfRecords > 0){
                        existingDataObj.isAmaTab = true;
                    }
                    else{
                        AggregateResult[] groupedResultsforSec = [SELECT count(id) from TPA_Secondary_Data_Asset__c  where TPA_Request_Secondary_Assets__c  =: requestId
                                        and IMS_Secondary_Data_Asset__r.Is_AMA_Required__c = true];
                        if(groupedResultsforSec != null && groupedResultsforSec.size() > 0) {
                            for (AggregateResult arSec : groupedResultsforSec)  {
                                noOfRecords = Integer.valueOf(arSec.get('expr0')) ;
                                if(noOfRecords > 0){
                                    existingDataObj.isAmaTab = true;
                                }
                            }
                        }	
                    }
                }
                
            }
			
        }

        system.debug('existingDataObj.isAmaTab:' +existingDataObj.isAmaTab);
        


        Map<String, List<String>> mapOfOfferingWithAdditionalField = new  Map<String, List<String>>();
        List<Offering_Name_with_Additional_Field__mdt> offeringnameWithAdditionalTextList = new list<Offering_Name_with_Additional_Field__mdt>();
        
        offeringnameWithAdditionalTextList = [select id, Assest_Name__c, Field_Name_With_Label__c, Field_Name_With_Label_1__c from Offering_Name_with_Additional_Field__mdt];
        
        for(Offering_Name_with_Additional_Field__mdt obj : offeringnameWithAdditionalTextList) {
            if(obj.Assest_Name__c != null) {
                mapOfOfferingWithAdditionalField.put(obj.Assest_Name__c, new List<String>{});
            }
            if(obj.Assest_Name__c != null && obj.Field_Name_With_Label__c != null) {
                mapOfOfferingWithAdditionalField.get(obj.Assest_Name__c).add(obj.Field_Name_With_Label__c);
            }
            if(obj.Assest_Name__c != null && obj.Field_Name_With_Label_1__c != null) {
                mapOfOfferingWithAdditionalField.get(obj.Assest_Name__c).add(obj.Field_Name_With_Label_1__c);
            }
            
        }
        existingDataObj.mapOfOfferingWithAdditionalFields = mapOfOfferingWithAdditionalField;
        
        
        return existingDataObj;
    }

    public static TPA_Request_Backup__c getRequestBackup(tpaRequestDetails reqObj, String requestType) {
        TPA_Request_Backup__c TPARequestBackupDetails = new TPA_Request_Backup__c();
        String ClientAndVendorDetails = '';
        if(requestType == 'Client') {
            ClientAndVendorDetails = 'Client Contact Territory: ' + reqObj.tpaRequest.Client_Contact_Territory__c;
            String isSecLocReq = reqObj.tpaRequest.Secondary_Location_Required__c ? 'Yes' : 'No' ;
            ClientAndVendorDetails += '~Secondary Location Required: ' + isSecLocReq;
            if(reqObj.tpaRequest.Secondary_Location_Required__c) {
                ClientAndVendorDetails += '~Sec Client Contact Territory: ' + reqObj.tpaRequest.Secondary_Client_Contact_Territory__c;
            }
            ClientAndVendorDetails += '~Project Name: ' + reqObj.tpaRequest.Client_Project_Name__c;
            ClientAndVendorDetails += '~Vendor Contact First Name: ' + reqObj.tpaRequest.Vendor_Contact_First_Name_Client__c;
            ClientAndVendorDetails += '~Vendor Contact Last Name: ' + reqObj.tpaRequest.Vendor_Contact_Last_Name_Client__c;
            ClientAndVendorDetails += '~Vendor Contact Telephone Number: ' + reqObj.tpaRequest.Vendor_Contact_Telephone_Client__c;
            ClientAndVendorDetails += '~Vendor Contact Email: ' + reqObj.tpaRequest.Vendor_Contact_Email_Client__c;
            ClientAndVendorDetails += '~Additional Client Copies Exist: ' + reqObj.tpaRequest.CopyAdditionalContactOnTransactions__c;

            String ContactList = ':- (tpaAdditionalContactList = ';
            if(reqObj.tpaRequest.CopyAdditionalContactOnTransactions__c == 'Yes' && reqObj.tpaAdditionalContactList != null && reqObj.tpaAdditionalContactList.size() > 0 ) {
                for(TPA_Contact__C objTpaContact : reqObj.tpaAdditionalContactList) {
                    ContactList += '{' + 'Name:' + objTpaContact.Name + ', Title:' + objTpaContact.Title__c + ', Phone:' + objTpaContact.Phone__c + ', Email:' + objTpaContact.Email__c + '},';
                }
                if(ContactList.substring(ContactList.length()-1, ContactList.length()) == ',') {
                    ContactList = ContactList.substring(0, ContactList.length() -1);
                }
                ClientAndVendorDetails += ContactList + ')';
            }
            ClientAndVendorDetails += '~is Additional Vendor Required TP: ' + reqObj.tpaRequest.Employ_SubContractors__c;
        }
        else {
            ClientAndVendorDetails += 'Name of Vendor: '+ reqObj.tpaRequest.Vendor_Company_Name__c;
            ClientAndVendorDetails += '~Vendor Address: '+ reqObj.tpaRequest.Vendor_Billing_Mailing_Street__c;
            ClientAndVendorDetails += '~Country: '+ reqObj.tpaRequest.Vendor_Billing_Mailing_Country__c;
            ClientAndVendorDetails += '~State/Province: '+ reqObj.tpaRequest.Vendor_Billing_Mailing_State_Province__c;
            ClientAndVendorDetails += '~City: '+ reqObj.tpaRequest.Vendor_Billing_Mailing_City__c;
            ClientAndVendorDetails += '~Postal Code: '+ reqObj.tpaRequest.Vendor_Billing_Mailing_Zip_Post_Code__c;
            If(reqObj.tpaRequest.Vendor_Website__c != null && reqObj.tpaRequest.Vendor_Website__c != '' && reqObj.tpaRequest.Vendor_Website__c != 'null') {
                ClientAndVendorDetails += '~Website: '+ reqObj.tpaRequest.Vendor_Website__c;
            }
            If(reqObj.tpaRequest.Vendor_Phone__c != null && reqObj.tpaRequest.Vendor_Phone__c != '' && reqObj.tpaRequest.Vendor_Phone__c != 'null') {
                ClientAndVendorDetails += '~Phone: '+ reqObj.tpaRequest.Vendor_Phone__c;
            }

            ClientAndVendorDetails += '~Vendor Contact First Name: '+ reqObj.tpaRequest.Vendor_First_Name__c;
            ClientAndVendorDetails += '~Vendor Contact Last Name: '+ reqObj.tpaRequest.Vendor_Contact_Last_Name__c;
            ClientAndVendorDetails += '~Vendor Title: '+ reqObj.tpaRequest.Vendor_Contact_Title__c;
            ClientAndVendorDetails += '~Vendor Contact Phone #: '+ reqObj.tpaRequest.Vendor_Contact_Phone__c;
            ClientAndVendorDetails += '~Vendor Contact Email    : '+ reqObj.tpaRequest.Vendor_e_mail__c;

            if(reqObj.authorizedSignerResponse == 'No') {
                ClientAndVendorDetails += '~Authorized Signer first name: '+ reqObj.tpaRequest.Authorized_Signer_First_Name__c;
                ClientAndVendorDetails += '~Authorized Signer Last Name: '+ reqObj.tpaRequest.Authorized_Signer_Last_Name__c;
                ClientAndVendorDetails += '~Authorized Signer Title: '+ reqObj.tpaRequest.Authorized_Signer_Title__c;
                ClientAndVendorDetails += '~Authorized Signer Email Address: '+ reqObj.tpaRequest.Authorized_Signer_Email__c;
            }

            ClientAndVendorDetails += '~Additional Vendors (Vendor Response): '+ reqObj.tpaRequest.Employ_SubContractors_VendorResponse__c;
            ClientAndVendorDetails += '~Vendor has competing Product or Service: '+ reqObj.tpaRequest.Competitive_Service_to_IMS_Offerings__c;
            ClientAndVendorDetails += '~Prod/Service in design or future release: '+ reqObj.tpaRequest.Competitive_Service_to_IMS_Offerings_2__c;
            ClientAndVendorDetails += '~Vendor has a similar product or service?: '+ reqObj.tpaRequest.Competitive_Service_to_IMS_Offerings_3__c;
            ClientAndVendorDetails += '~Additional Vendor Contacts Exist: '+ reqObj.tpaRequest.Copy_Additional_Vendor_Contacts__c;

            String tpaAdditionalVendorContactList = ':- (TpaAdditionalVendorContactList = ';
            if(reqObj.tpaRequest.Copy_Additional_Vendor_Contacts__c == 'Yes' && reqObj.tpaAdditionalVendorContactList != null && reqObj.tpaAdditionalVendorContactList.size() > 0 ) {
                for(TPA_Contact__C objTpaContact : reqObj.tpaAdditionalVendorContactList) {
                    tpaAdditionalVendorContactList += '{' + 'Name:' + objTpaContact.Name + ', Title:' + objTpaContact.Title__c + ', Phone:' + objTpaContact.Phone__c + ', Email:' + objTpaContact.Email__c + '},';
                }
                if(tpaAdditionalVendorContactList.substring(tpaAdditionalVendorContactList.length()-1, tpaAdditionalVendorContactList.length()) == ',') {
                    tpaAdditionalVendorContactList = tpaAdditionalVendorContactList.substring(0, tpaAdditionalVendorContactList.length() -1);
                }
                ClientAndVendorDetails += tpaAdditionalVendorContactList + ')';
            }
        }
        TPARequestBackupDetails.Client_and_Vendor_Details__c = ClientAndVendorDetails;

        String requestDetails = '';
        if(requestType == 'Client') {
            if(reqObj.tpaRequest.Data_Access_Start_Date__c != null ) {
                requestDetails = 'Data Access Start Date: '+ DateTime.newinstance(reqObj.tpaRequest.Data_Access_Start_Date__c.year(), reqObj.tpaRequest.Data_Access_Start_Date__c.month(), reqObj.tpaRequest.Data_Access_Start_Date__c.day()).format('MM/dd/YY');
            } 
            if(reqObj.tpaRequest.Data_Access_End_Date__c != null ) {
                requestDetails += '~Data Access End Date: '+ DateTime.newinstance(reqObj.tpaRequest.Data_Access_End_Date__c.year(), reqObj.tpaRequest.Data_Access_End_Date__c.month(), reqObj.tpaRequest.Data_Access_End_Date__c.day()).format('MM/dd/YY');
            }
            if(reqObj.tpaRequest.Data_Period_Start_Date__c != null ) {
                requestDetails += '~Data Period Start Date: '+ DateTime.newinstance(reqObj.tpaRequest.Data_Period_Start_Date__c.year(), reqObj.tpaRequest.Data_Period_Start_Date__c.month(), reqObj.tpaRequest.Data_Period_Start_Date__c.day()).format('MM/dd/YY');
            }
            if(reqObj.tpaRequest.Data_Period_End_Date__c != null ) {
                requestDetails += '~Data Period End Date: '+ DateTime.newinstance(reqObj.tpaRequest.Data_Period_End_Date__c.year(), reqObj.tpaRequest.Data_Period_End_Date__c.month(), reqObj.tpaRequest.Data_Period_End_Date__c.day()).format('MM/dd/YY');
            }
        }
        TPARequestBackupDetails.Request_Details_Offering_s__c = requestDetails;

        String DataDeliveryTransmission = '';
        if(requestType == 'Vendor' && reqObj.amaAgrSubmitted != null && reqObj.amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c != '') {
            DataDeliveryTransmission += 'Vendor require Remote Access from NonUS: ' + reqObj.amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c;

            if(reqObj.amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c == 'Yes') {
                DataDeliveryTransmission += '~Vendor Employee Access Data in country: ' + reqObj.amaAgrSubmitted.Vendor_Employee_Accessed_Data_in_country__c + '~Technology(s) selected for remote access: ' + reqObj.amaAgrSubmitted.Technology_s_selected_for_remote_access__c + '~Other Technology for Remote Access: ' + reqObj.amaAgrSubmitted.Other_Technology_for_Remote_Access__c;
                DataDeliveryTransmission += '~Vendor Ex-U.S. Legal Entity For Remote Access Information --> Ex-US Legal Entity Name: ' + reqObj.amaAgrSubmitted.Ex_US_Legal_Entity_Name_Remote_Access__c + ' Ex-US Legal Entity Address: ' + reqObj.amaAgrSubmitted.Off_Access_Legal_Entity_Street__c + ' ' + reqObj.amaAgrSubmitted.Off_Access_Legal_Entity_City__c + ' ' + reqObj.amaAgrSubmitted.Off_Access_Legal_Entity_State__c + ' ' + reqObj.amaAgrSubmitted.Off_Access_Legal_Entity_Country__c + ' ' + reqObj.amaAgrSubmitted.Off_Access_Legal_Entity_Zip__c;
            }
        }
                
        if(requestType == 'Vendor' && reqObj.amaAgrSubmitted != null && reqObj.amaAgrSubmitted.Vendor_req_Storage_Permission_from_NonUS__c != '') {
            DataDeliveryTransmission += '~Vendor req Storage Permission from NonUS: ' + reqObj.amaAgrSubmitted.Vendor_req_Storage_Permission_from_NonUS__c;
            if(reqObj.amaAgrSubmitted.Vendor_req_Storage_Permission_from_NonUS__c == 'Yes') {
                DataDeliveryTransmission += '~Vendor Employee Store Data in country: ' + reqObj.amaAgrSubmitted.Vendor_Employee_Store_Data_in_country__c + '~ExUS Entity Authorized Signer Name: ' + reqObj.amaAgrSubmitted.Ex_US_Entity_Authorized_Signer_FName__c + ' ' + reqObj.amaAgrSubmitted.Ex_US_Entity_Authorized_Signer_LName__c + '~Ex-US Entity Authorized Signer Email: ' + reqObj.amaAgrSubmitted.Ex_US_Entity_Authorized_Signer_Email__c + '~Ex-US Entity Authorized Signer Title: ' + reqObj.amaAgrSubmitted.Ex_US_Entity_Authorized_Signer_Title__c;
                DataDeliveryTransmission += '~Vendor Ex-U.S. Legal Entity For Offshore Storage Information --> Ex-US Legal Entity Name: ' + reqObj.amaAgrSubmitted.Ex_US_Legal_Entity_Name_Offshore_Storage__c + ' Ex-US Legal Entity Address: ' + reqObj.amaAgrSubmitted.Off_Storage_Legal_Entity_Street__c + ' ' + reqObj.amaAgrSubmitted.Off_Storage_Legal_Entity_City__c + ' ' + reqObj.amaAgrSubmitted.Off_Storage_Legal_Entity_State__c + ' ' + reqObj.amaAgrSubmitted.Off_Storage_Legal_Entity_Country__c + ' ' + reqObj.amaAgrSubmitted.Off_Storage_Legal_Entity_Zip__c;
            }
        }
        TPARequestBackupDetails.Data_Delivery_Transmission__c = DataDeliveryTransmission;

        String AMADATA = '';
        if(requestType == 'Client') {
            if(reqObj.tpaRequest.AMA_USPrescriberData__c != '' ) {
                AMADATA += 'Provider Level Attibutes Included: '+ reqObj.tpaRequest.AMA_USPrescriberData__c;
                if(reqObj.tpaRequest.AMA_USPrescriberData__c == 'Yes') {
                    AMADATA += '~Type of prescriber level data requested: '+ reqObj.tpaRequest.AMA_TypeOfPrescriberLevelData__c;
                    AMADATA += '~Project use specifically related to the AMA prescriber identifiable data: '+ reqObj.tpaRequest.AMA_Services_Provided__c;
                    // if(reqObj.tpaRequest.AMA_Market_Research_Attributes__c != '') {
                    //     AMADATA += '~AMA Variables that best describes market research project: '+ reqObj.tpaRequest.AMA_Market_Research_Attributes__c;
                    // }
                    // if(reqObj.tpaRequest.AMA_Dist_ana_Mail_Atrr_For_Template__c != '') {
                    //     AMADATA += '~AMA Variables that best describes distribution and mailing project: '+ reqObj.tpaRequest.AMA_Dist_ana_Mail_Atrr_For_Template__c;
                    // }
                    AMADATA += '~Longest period of Accessing AMA Data: '+ reqObj.tpaRequest.AMA_Howlong_SP_has_Data_Access__c;
                 //   AMADATA += '~AMA Variables: '+ reqObj.tpaRequest.AMA_PPDVariablesCollected__c;
                    AMADATA += '~Frequency of the delivery to the Vendor: '+ reqObj.tpaRequest.FrequencyOfDeliveryToServiceProvider__c;
                    if(reqObj.tpaRequest.FrequencyOfDeliveryToSP_Other__c != '') {
                        AMADATA += '~Other frequency of the delivery to the Vendor: '+ reqObj.tpaRequest.FrequencyOfDeliveryToSP_Other__c;
                    }
                    if(reqObj.amaAgrSubmitted != null){
                        AMADATA += '~Client req Storage Permission from NonUS: ' + reqObj.amaAgrSubmitted.Client_req_Storage_Permission_from_NonUS__c;
                        AMADATA += '~Client Employee Store Data in country: ' + reqObj.amaAgrSubmitted.Client_Employee_Store_Data_in_country__c;
                    }
                }
            }
        }
        // else if(reqObj.tpaRequest.AMA_HowResponseDataCollected__c != null && reqObj.tpaRequest.AMA_HowResponseDataCollected__c != '') {
        //     AMADATA += 'Response data be collected: '+ reqObj.tpaRequest.AMA_HowResponseDataCollected__c;
        //     if(reqObj.tpaRequest.AMA_RepDataCollectedOtherWay__c != null && reqObj.tpaRequest.AMA_RepDataCollectedOtherWay__c != '') {
        //         AMADATA += '~Other Response Data Collection Method:'+ reqObj.tpaRequest.AMA_RepDataCollectedOtherWay__c;
        //     }
        //     AMADATA += '~Response Data must be returned or destroyed 90 days after collection: '+ reqObj.tpaRequest.AMA_RespDataAction__c;
        // }
        TPARequestBackupDetails.AMA_DATA__c = AMADATA;

        return TPARequestBackupDetails;
    }

    public void saveRequestAF() {
        requestSubmissionResult = CNT_TPA_RequestSubmissionForm.saveRequest(reqObjString);
    }

    @remoteAction
    global static string saveRequest(string requestDetail) {
        isTPProcessor = currentLoggedInUser.Profile.Name.indexOf('TPA Processor Profile') != -1 ? true : false;
        isUSTPProcessor = currentLoggedInUser.Profile.Name.indexOf('US TP Processor Profile') != -1 ? true : false;
        system.debug('isTPProcessor :: ' + isTPProcessor); 
        system.debug('isUSTPProcessor :: ' + isUSTPProcessor); 
        system.debug('requestDetail :: ' + requestDetail); 
        getLimitsMessage(); 
        tpaRequestDetails reqObj; 
        try {
            UTL_TPA.executeDataAssetTrigger = false; 
            UTL_TPA.isLegacySystem = false; 
            reqObj = (tpaRequestDetails)JSON.deserialize(requestDetail, tpaRequestDetails.class);
            requestDetail = null; // Set NULL after use to save heap size
            if(UTL_Validate.isValidGuid(reqObj.GUID)) {
                UTL_LogFactory.GUID = reqObj.GUID; 
            }

            if(reqObj.tpaRequest.request_type__c == 'renew' 
                && reqObj.requestTypeSubmitted == 'NewRequest' 
                && reqObj.tpaRequest.Parent_Request__c != null){
                TPA_Request__c parentReq = [Select Id,Renewed_As__c From TPA_Request__c where Id=:reqObj.tpaRequest.Parent_Request__c];
                if(parentReq.Renewed_As__c != null){
                    return 'requestAlreadyRenewed';
                }
            }

            language =  reqObj.processedLanguage;

            if( reqObj != null && reqObj.tpaRequest != null && reqObj.tpaRequest.Is_Potential_Vendor_Case__c ) {
                UTL_TPA.createActivityHistory = false;
            }
            else {
                UTL_TPA.createVendorSelectedActivityHistory = false;
            }
            
            if(reqObj.useOffBackupIds != null 
            && reqObj.useOffBackupIds != ''
            && reqObj.isOnlyReferenceDataCatSelected != null 
            && !reqObj.isOnlyReferenceDataCatSelected
            && (reqObj.tpaRequest.Data_Period_Start_Date__c == null 
            || reqObj.tpaRequest.Data_Period_End_Date__c == null)) {
                List<String> useOffBackupIdList = reqObj.useOffBackupIds.split(';');
                if(useOffBackupIdList != null && useOffBackupIdList.size() > 0) {
                    List<TPA_Use_Offerings_UI_Backup__c> useOfferingBackupList = [Select Id, Details__c from TPA_Use_Offerings_UI_Backup__c where Id IN : useOffBackupIdList Order By CreatedDate Desc limit 1];
                    if(useOfferingBackupList != null && useOfferingBackupList.size() > 0) {
                        String backupDetail = useOfferingBackupList[0].Details__c;
                        string dataPeriodStartDate = backupDetail.substringBetween('DPSD:', ';');
                        string dataPeriodEndDate = backupDetail.substringBetween('DPED:', ';');
                        if(dataPeriodStartDate != null && dataPeriodStartDate != '') {
                            reqObj.tpaRequest.Data_Period_Start_Date__c = date.valueOf(dataPeriodStartDate);
                        }                        
                        if(dataPeriodEndDate != null && dataPeriodEndDate != '') {
                            reqObj.tpaRequest.Data_Period_End_Date__c = date.valueOf(dataPeriodEndDate);
                        }
                    }
                }
            }

            if(reqObj.requestTypeSubmitted == 'InDraftRequest') {
                reqObj.tpaRequest.Request_Status__c = 'Client Draft'; 
                reqObj.tpaRequest.TPA_Request_Temporary_Status__c = 'Client Draft';
                upsert reqObj.tpaRequest;  
            } 
            else if(reqObj.requestTypeSubmitted == 'NewRequest' || reqObj.requestTypeSubmitted == 'ClientSubmit'){
                reqObj.tpaRequest.Request_Status__c = 'Client Submitted';
                reqObj.tpaRequest.TPA_Request_Temporary_Status__c = 'Client Submitted';
                upsert reqObj.tpaRequest;
            if( reqObj.bulkCSVFileName != null && reqObj.bulkCSVFileName != '') {
                saveBulkCSVFile(reqObj);
              }
            }
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Backup Details in Save Request : Request New Creation', 'TPA', 'Custom', 'INFO', 'MapPurpDesc(' + (reqObj.MapPurpDesc != null ? reqObj.MapPurpDesc.Size() : null) + ') MapPurpDescOther(' +  (reqObj.MapPurpDescOther != null ? reqObj.MapPurpDescOther.Size() : null) + ') PurposeMap(' +  (reqObj.PurposeMap != null ? reqObj.PurposeMap.Size() : null) + ') PurposeMapOther(' +  (reqObj.PurposeMapOther != null ? reqObj.PurposeMapOther.Size() : null) + ') SelectedDescMap(' +  (reqObj.SelectedDescMap != null ? reqObj.SelectedDescMap.Size() : null) + ') mapPurposeidWithDataAssetMap(' +  (reqObj.mapPurposeidWithDataAssetMap != null ? reqObj.mapPurposeidWithDataAssetMap.Size() : null) + ') mapSecondayDataAssetToInsert(' +  (reqObj.mapSecondayDataAssetToInsert != null ? reqObj.mapSecondayDataAssetToInsert.Size() : null) + ') categorypurposesList(' +  (reqObj.categorypurposesList != null ? reqObj.categorypurposesList.Size() : null) + ') secondarypurpose(' +  (reqObj.secondarypurpose != null ? reqObj.secondarypurpose.Size() : null) + ')', reqObj.tpaRequest.Id));
            
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);

            if(reqObj.requestTypeSubmitted == 'ClientSubmit' || reqObj.requestTypeSubmitted == 'InDraftRequest') {
                if(isTPProcessor || isUSTPProcessor) { 
                    TPA_Request_Backup__c TPARequestBackupDetails = getRequestBackup(reqObj, 'Client');
                    TPARequestBackupDetails.Submission_Type__c = 'Client Submission';
                    TPARequestBackupDetails.Related_TPA_Request__c = reqObj.tpaRequest.id;
                    insert TPARequestBackupDetails;
                    TPARequestBackupDetails = null;//Setting Null After use to save heap size

                    tpProcessorSubmission(JSON.serialize(reqObj), language, GUID); //TODO: Review
                    //reqObj.tpaRequest = SRV_TPA_TPARequest.getRequestInfo( reqObj.tpaRequest.Id );
                    if(reqObj.requestTypeSubmitted != 'InDraftRequest') {
                        UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'FROM TP-Processor Submission Complete', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id));
                        UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                        return ('success~' + UTL_TPA.TPA_COMMUNIYTURL + '/VFP_TPA_CustomLandingPage');
                    }
                }

            } 
            
            if(reqObj.requestTypeSubmitted == 'NewRequest' 
            || reqObj.requestTypeSubmitted == 'ClientSubmit' 
            || reqObj.requestTypeSubmitted == 'InDraftRequest') {
                TPA_Request_Backup__c TPARequestBackupDetails = getRequestBackup(reqObj, 'Client');
                TPARequestBackupDetails.Submission_Type__c = 'Client Submission';
                TPARequestBackupDetails.Related_TPA_Request__c = reqObj.tpaRequest.id;
                insert TPARequestBackupDetails;
                TPARequestBackupDetails = null;//Setting Null After use to save heap size

                clientSubmission(JSON.serialize(reqObj), language, GUID); //TODO: Review    
                return ('success~'+UTL_TPA.TPA_COMMUNIYTURL +'/VFP_TPA_CustomLandingPage');
            }

            if(reqObj.requestTypeSubmitted == 'VendorSubmit') {
                reqObj.tpaRequest.Request_Status__c = Label.TPA_In_Review_By_IQVIA_Status;
                reqObj.tpaRequest.TPA_Request_Temporary_Status__c = Label.TPA_In_Review_By_IQVIA_Status;
                reqObj.tpaRequest.Vendor_Language__c = supportedLanguageMap.get(language).split('~')[0];
                
                String vendorlanguage = reqObj.tpaRequest.TLLA_Language_Chosen__c != null ? reqObj.tpaRequest.TLLA_Language_Chosen__c : (reqObj.tpaRequest.Vendor_Language__c == null ? 'English' : reqObj.tpaRequest.Vendor_Language__c);
                
                List<TPA_RequestDocument__c> lstRequestDocument = new List<TPA_RequestDocument__c>();
                lstRequestDocument = [select id, Document_Type__c, Document_Id__c from TPA_RequestDocument__c where TPA_Request_Id__c =: reqObj.tpaRequest.Id order by Document_Type__c];
                if(lstRequestDocument.size() > 0) {
                    delete lstRequestDocument;
                }
                lstRequestDocument = new List<TPA_RequestDocument__c>();
                for(Integer count = 0; count < 2 ; count++) { 
                    TPA_RequestDocument__c objRequestDocument = new TPA_RequestDocument__c();
                    objRequestDocument.TPA_Request_Id__c = reqObj.tpaRequest.Id;
                    objRequestDocument.Version__c = 5;
                    lstRequestDocument.add(objRequestDocument);
                }
                lstRequestDocument.get(0).Document_Type__c = 'CP';
                lstRequestDocument.get(0).Document_Id__c = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Compliance Program Doc' + vendorlanguage).Translated_Template_Id__c;
                lstRequestDocument.get(1).Document_Type__c = 'TC';
                lstRequestDocument.get(1).Document_Id__c = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Std T&C Doc' + vendorlanguage).Translated_Template_Id__c;
                insert lstRequestDocument;
                lstRequestDocument = null; //Set Null after use to save heap size
                
                List<TPA_Contact__c> insertAdditionalVendors = new List<TPA_Contact__c>();
                if(reqObj.tpaSubContractors.size() > 0) {
                    for(TPA_Contact__C objTpaContact : reqObj.tpaSubContractors) {
                        objTpaContact.TPA_Request__c = reqObj.tpaRequest.Id;
                        objTpaContact.Type__c = TPA_CONTACTTYPE_SUBCONTRACTOR;
                        insertAdditionalVendors.add(objTpaContact);
                    }
                }
                List<TPA_contact__c> existedTpaContacts = [select Id from TPA_Contact__c where TPA_Request__c =: reqObj.tpaRequest.Id and Type__c =: TPA_CONTACTTYPE_SUBCONTRACTOR];
                delete existedTpaContacts;
                insert insertAdditionalVendors;
                insertAdditionalVendors = null; //Set Null after use to save heap size

                update reqObj.tpaRequest; //TODO: put exception logs here
                
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Request Updated', 'TPA', 'Custom', 'INFO', 'By Vendor:::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id));

                reqObj.tpaRequest = SRV_TPA_TPARequest.getRequestInfo( reqObj.tpaRequest.Id );

                if(reqObj.tpaRequest.Client_Address__r.Region_Territory__c == null ) {
                    CNT_TPA_RequestSubmissionForm.sendMailToTPProcessorClientAddressisNULL(reqObj.tpaRequest);
                    reqObj.tpaRequest.Stop_TLLA_Generation_Notice_Sent_Date__c = Date.today();
                }
                // add by yogesh
                TPA_Request_Backup__c TPARequestBackupDetails = getRequestBackup(reqObj, 'Vendor');
                TPARequestBackupDetails.Related_TPA_Request__c = reqObj.tpaRequest.id;
                TPARequestBackupDetails.Submission_Type__c = 'Vendor Submission';
                insert TPARequestBackupDetails;
                TPARequestBackupDetails = null;//Setting Null After use to save heap size


                vendorSubmission(JSON.serialize(reqObj), language, GUID); //TODO: Review

                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'FROM Vendor Submission Complete', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                return ('success~'+'VFP_TPA_Page_Status?type=vendorSubmitSuccess&reqNo=' + reqObj.tpaRequest.Name);
            }            

            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'FROM Client Submission Last Reach', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            return 'success';
        }
        catch(Exception ex) {
            system.debug('ERROR: '+ex.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest::FinalCatch', (reqObj != null && reqObj.tpaRequest != null) ? reqObj.tpaRequest.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
        return 'error';
    }

    @future(callout=true)
    public static void clientSubmission(string requestDetail, string languageArg, string argGUID) {  
        getLimitsMessage();

        if(UTL_Validate.isValidGuid(argGUID)) {
            UTL_LogFactory.GUID = argGUID; 
        }
        language = languageArg;

        isTPProcessor = currentLoggedInUser.Profile.Name.indexOf('TPA Processor Profile') != -1 ? true : false;
        isUSTPProcessor = currentLoggedInUser.Profile.Name.indexOf('US TP Processor Profile') != -1 ? true : false;
        
        CNT_TPA_RequestSubmissionForm.tpaRequestDetails reqObj = (CNT_TPA_RequestSubmissionForm.tpaRequestDetails)JSON.deserialize(requestDetail, CNT_TPA_RequestSubmissionForm.tpaRequestDetails.class);
        getLimitsMessage();
        requestDetail = null; //Set Null After use to save heap size

        try {
            UTL_TPA.executeDataAssetTrigger =  false;
            UTL_TPA.isLegacySystem = false;

            if(reqObj != null && reqObj.tpaRequest != null && reqObj.tpaRequest.Is_Potential_Vendor_Case__c) {
                UTL_TPA.createActivityHistory = false;
            } else {
                UTL_TPA.createVendorSelectedActivityHistory = false;
            }
            
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Backup Details in Client Submission : Client', 'TPA', 'Custom', 'INFO', 'MapPurpDesc(' + (reqObj.MapPurpDesc != null ? reqObj.MapPurpDesc.Size() : null) + ') MapPurpDescOther(' +  (reqObj.MapPurpDescOther != null ? reqObj.MapPurpDescOther.Size() : null) + ') PurposeMap(' +  (reqObj.PurposeMap != null ? reqObj.PurposeMap.Size() : null) + ') PurposeMapOther(' +  (reqObj.PurposeMapOther != null ? reqObj.PurposeMapOther.Size() : null) + ') SelectedDescMap(' +  (reqObj.SelectedDescMap != null ? reqObj.SelectedDescMap.Size() : null) + ') mapPurposeidWithDataAssetMap(' +  (reqObj.mapPurposeidWithDataAssetMap != null ? reqObj.mapPurposeidWithDataAssetMap.Size() : null) + ') mapSecondayDataAssetToInsert(' +  (reqObj.mapSecondayDataAssetToInsert != null ? reqObj.mapSecondayDataAssetToInsert.Size() : null) + ') categorypurposesList(' +  (reqObj.categorypurposesList != null ? reqObj.categorypurposesList.Size() : null) + ') secondarypurpose(' +  (reqObj.secondarypurpose != null ? reqObj.secondarypurpose.Size() : null) + ')', reqObj.tpaRequest.Id));

            if(reqObj.tpaRequest != null && reqObj.tpaRequest.is_Client_Representative__c != null && reqObj.tpaRequest.is_Client_Representative__c == true){
                reqObj.tpaRequest.Client_TPA_Representative_Email__c =  currentLoggedInUser.Email;
                reqObj.tpaRequest.Client_TPA_Representative_Name__c = currentLoggedInUser.Name;
                reqObj.tpaRequest.Client_TPA_Representative_Title__c = '';
            }
            if(reqObj.requestTypeSubmitted == 'NewRequest' || reqObj.requestTypeSubmitted == 'InDraftRequest') {
                reqObj.tpaRequest.Is_New_Notification_Sent__c = false;
                reqObj.tpaRequest.Client_Language__c = supportedLanguageMap.get(language).split('~')[0];
                reqObj.tpaRequest.Is_Submitted__c = true;
                reqObj.tpaRequest.Is_Vendor_Id_Invalid__c = false;
                reqObj.tpaRequest.ClientContact__c = currentLoggedInUser.contactId;


                if(reqObj.requestTypeSubmitted != 'InDraftRequest') {
                    reqObj.tpaRequest.Request_Status__c = 'Awaiting Vendor Submission';
                    reqObj.tpaRequest.TPA_Request_Temporary_Status__c = 'Awaiting Vendor Submission';
                }               
                
                if(reqObj.tpaRequest.Secondary_Client_Contact_Territory__c != null ) {
                    set<string> secCountryCodeSet = createStateCountryNameSet(reqObj.tpaRequest.Secondary_Client_Contact_Territory__c, 'C');
                    existedCountryStateCodes = null; //Set Null After use in createStateCountryNameSet function to save heap size
                    if(secCountryCodeSet != null && secCountryCodeSet.size() > 0) {
                        List<TPA_Region_Country__c> lstRegionCountry = new List<TPA_Region_Country__c>();                
                        lstRegionCountry = [select TP_Processor__c,
                                            TP_Processor__r.region__c,
                                            TP_Processor__r.TP_Processor_Name__c,
                                            TP_Processor__r.TPA_Processor_Contact__c,
                                            TP_Processor__r.TPA_Processor_Contact__r.accountid,
                                            TP_Processor__r.TP_Processor_Email__c, 
                                            TP_Processor__r.Assigned_TP_Processors__c
                                            from TPA_Region_Country__c
                                            where Country__c in: secCountryCodeSet
                                            limit 1 ];
                        if(lstRegionCountry.size() != 0 ) {
                            if(lstRegionCountry[0].TP_Processor__c != null) {
                                reqObj.tpaRequest.TPA_Processor_Contact__c = lstRegionCountry[0].TP_Processor__r.TPA_Processor_Contact__c;
                                reqObj.tpaRequest.TP_Processor_Email__c = lstRegionCountry[0].TP_Processor__r.TP_Processor_Email__c;
                                reqObj.tpaRequest.TP_Processor_Name__c = lstRegionCountry[0].TP_Processor__r.TP_Processor_Name__c;
                                List<TPA_Assigned_TP_Processor__c> assignedTPProcessors = [select Id, Name from TPA_Assigned_TP_Processor__c where TP_Processor__c =: lstRegionCountry[0].TP_Processor__c];
                                if(assignedTPProcessors.size() == 1) { 
                                    reqObj.tpaRequest.TPA_Assigned_TP_Processor__c = assignedTPProcessors[0].Id;
                                }
                            }
                            else {
                                reqObj.tpaRequest.TPA_Processor_Account_Address__c = null;
                                reqObj.tpaRequest.TPA_Processor_Contact__c = null;
                            }
                        }
                    }
                }
                
                getLimitsMessage();
                
              //  reqObj.tpaRequest.AMA_Services_Provided__c = savePurposes(reqObj);
              savePurposes(reqObj);
                /*
                if(reqObj.requestTypeSubmitted != 'InDraftRequest') {
                    TPA_Request_Backup__c TPARequestBackupDetails = getRequestBackup(reqObj, 'Client');
                    TPARequestBackupDetails.Submission_Type__c = 'Client Submission';
                    TPARequestBackupDetails.Related_TPA_Request__c = reqObj.tpaRequest.id;
                    insert TPARequestBackupDetails;
                    TPARequestBackupDetails = null;//Setting Null After use to save heap size
                }
                */
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Uses and Offerings Created', 'TPA', 'Custom', 'INFO', isUSTPProcessor?'By US TP Processor':'By Client', reqObj.tpaRequest.Id));
                
                if(reqObj.requestTypeSubmitted == 'InDraftRequest') {
                    reqObj.tpaRequest.LastAction__c = 'Request Saved In Draft By Client';

                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Request Saved in Draft', 'TPA', 'Custom', 'INFO', isUSTPProcessor?'By US TP Processor':'By Client', reqObj.tpaRequest.Id));
                } else {
                    reqObj.tpaRequest.LastAction__c = 'Request Submitted By Client';
                    
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Request Inserted', 'TPA', 'Custom', 'INFO', isUSTPProcessor?'By US TP Processor':'By Client', reqObj.tpaRequest.Id));
                }
				List<TPA_Additional_Term__c> addtionalTermList = new List<TPA_Additional_Term__c>();
                List<Id> addHocWithAttchs = new List<Id>();
                TPA_Request__c parentReq;
                if(reqObj.tpaRequest.request_type__c == 'renew' 
                && reqObj.requestTypeSubmitted == 'NewRequest' 
                && reqObj.tpaRequest.Parent_Request__c != null) { 
                    parentReq = [SELECT Id, Name, Is_Exhibit_Required__c,Exhibit_Page_Required__c, (SELECT Id, Exhibit_Attached__c,Name,Term_Name__c, Parent_Additional_Terms__c,TPA_Request__c ,TPA_Legal_Entity_1__c, TPA_Legal_Entity_1__r.IMS_Master_Legal_Entity__c,TPA_Legal_Entity_1__r.Name, Addtional_Term__c, Category__c, Is_All_Legal_Entities_Selected__c, Use_Name__c, Country_of_Offering__c, Primary_Offering_Name__c, Secondary_Offering_Name__c,Do_Not_Apply_if_Renewed__c,Is_Future_Approved__c,Type__c,Ad_hoc_Term_Last_Entered_By__c,Ad_hoc_Term_Last_Updated__c FROM TPA_Additional_Terms__r where Do_Not_Apply_if_Renewed__c = false ) FROM TPA_Request__c WHERE Id =: reqObj.tpaRequest.Parent_Request__c];
                    Boolean additionalTermApplied = false,exhibitPageRequired = false;
                    for(TPA_Additional_Term__c addHoc:parentReq.TPA_Additional_Terms__r){
                        if(addHoc.Exhibit_Attached__c){
                            addHocWithAttchs.add(addHoc.Id);
                            exhibitPageRequired = true;
                        }
                        additionalTermApplied = true;
                        List<TPA_Additional_Term__c> adds = new List<TPA_Additional_Term__c>();
                        if(SRV_TPA_TPARequest.MlegalEntityToAdditionalTermsMap.get(addHoc.TPA_Legal_Entity_1__r.IMS_Master_Legal_Entity__c) != null) {
                            adds =  SRV_TPA_TPARequest.MlegalEntityToAdditionalTermsMap.get(addHoc.TPA_Legal_Entity_1__r.IMS_Master_Legal_Entity__c);
                        }
                        adds.add(addHoc);
                        SRV_TPA_TPARequest.MlegalEntityToAdditionalTermsMap.put(addHoc.TPA_Legal_Entity_1__r.IMS_Master_Legal_Entity__c, adds);
                    }
                    if(parentReq.Is_Exhibit_Required__c && additionalTermApplied) {
                        reqObj.tpaRequest.Is_Exhibit_Required__c = true;
                    }
                    else{
                        reqObj.tpaRequest.Is_Exhibit_Required__c = false;
                    }
                    if(parentReq.Exhibit_Page_Required__c && additionalTermApplied && exhibitPageRequired) {
                        reqObj.tpaRequest.Exhibit_Page_Required__c = true;
                    }
                    else{
                        reqObj.tpaRequest.Exhibit_Page_Required__c = false;
                    }
                }

                UTL_TPA.ClientSubmissionUpdate = true; //TODO: Review Pending from my side
                upsert reqObj.tpaRequest; //TODO:will review, exception logs
                UTL_TPA.ClientSubmissionUpdate = false;

                if(reqObj.requestTypeSubmitted == 'InDraftRequest') { //will review
                    List<TPA_contact__c> existedTpaContacts =[select id from TPA_contact__c where TPA_Request__c = :reqObj.tpaRequest.Id AND (Type__c = :TPA_CONTACTTYPE_ADDITIONAL OR Type__c = :TPA_ADDITIONAL_CLIENT_CONTACT)];              
                    if(existedTpaContacts.size() > 0) {
                        delete existedTpaContacts;
                    }
                }

                updateClientCopies(reqObj); 
                
                if(reqObj.requestTypeSubmitted == 'InDraftRequest'){
                    SRV_TPA_TPARequest.sendDraftMail(reqObj.tpaRequest);
                }
                
                
                if(reqObj.requestTypeSubmitted != 'InDraftRequest') {
                    if(reqObj.tpaRequest.AMA_USPrescriberData__c == 'Yes' ) {
                        amaAgreementDetails = getAmaAgreement(reqObj.tpaRequest, reqObj.amaAgrSubmitted, 'NewRequest');
                        resetAmaValuesOnTpaRequest(reqObj.tpaRequest);
                        if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
                            amaAgreementDetails.id = reqObj.tpaRequest.AMA_Agreement_Details__r[0].id;
                        } else {
                            amaAgreementDetails.TPA_Request__c = reqObj.tpaRequest.id;
                        }
                    }
                    try {
                        if(amaAgreementDetails != null) {
                            upsert amaAgreementDetails;
                            amaAgreementDetails = null; //Setting Null after use to save heap size
                        }
                    } catch(Exception ex) {
                        UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest:::AMA Agreement Detail Update Exception', reqObj.tpaRequest.Id));
                        UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                        System.debug('**Exception while upserting AMA agreement**'+ex.getMessage());
                    }

                    SRV_TPA_TPARequest.updateAgreementFieldsForClient(reqObj.tpaRequest); 
                    
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Update Agreement Fields For Client Complete', 'TPA', 'Custom', 'INFO', isUSTPProcessor?'By US TP Processor':'By Client', reqObj.tpaRequest.Id));                   
                    
                    List<TPA_Request__c> tpaRequestList = [select id, name, Request_Type__c, Parent_Request__r.Name, Parent_Request__c, LastAction__c, ClientContact__c, Client_Contact_Territory__c, vendor_language__c, client_language__c, Vendor_Contact_Email_Client__c, TP_Processor_Email__c, Is_New_Notification_Sent__c, Client_Address__c, Client_Address__r.Name, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Request_Status__c, (SELECT Id, IMS_Master_Legal_Entity__c FROM IMS_Legal_Entities__r), (SELECT Id FROM TPA_Agreement_Additional_Fields__r) from TPA_Request__c where id =: reqObj.tpaRequest.Id];

                    if(tpaRequestList != null && tpaRequestList.size() > 0) {
                        reqObj.tpaRequest = tpaRequestList[0];
                    }


                    Map<Id, Id> materToTransactionalLegalEntityMap = new Map<Id, Id>();
                    for(IMS_Legal_Entity__c newReqLegalEntity : reqObj.tpaRequest.IMS_Legal_Entities__r) {
                        materToTransactionalLegalEntityMap.put(newReqLegalEntity.IMS_Master_Legal_Entity__c, newReqLegalEntity.Id);
                    }

                    Map<String,Attachment> keysWithAttachment = new Map<String,Attachment>();

                    if(parentReq != null && parentReq.Is_Exhibit_Required__c) {
                        Map<Id,Attachment> addHocIdWithAttachs = new Map<Id,Attachment>();
                        List<String> adHocCatList = new List<String>();
                        for(Attachment att:[Select Id,Body,Name,Description,ParentId From Attachment where ParentId in: addHocWithAttchs]){
                            addHocIdWithAttachs.put(att.ParentId, att);
                        }
                        for(TPA_Additional_Term__c addtionalTerm : parentReq.TPA_Additional_Terms__r) {
                            if(termsNotToRetain.contains(addtionalTerm.Id)){
                                continue;
                            }
                            if(addtionalTerm.Parent_Additional_Terms__c != '' && addtionalTerm.Parent_Additional_Terms__c != null){
                                system.debug('in here');
                                if(addtionalTerm.Is_Future_Approved__c){
                                    DAOH_TPA_Additional_Term.futureApprovedAdditionalTerms.add(UTL_TPA.createAddHocKey(addtionalTerm));
                                }
                                continue;
                            }
                            if(addtionalTerm.Exhibit_Attached__c){
                                addHocWithAttchs.add(addtionalTerm.Id);
                                keysWithAttachment.put(UTL_TPA.createAddHocKey(addtionalTerm), addHocIdWithAttachs.get(addtionalTerm.Id));
                            }
                            TPA_Additional_Term__c newAdditionalTerm = new TPA_Additional_Term__c();
                            newAdditionalTerm.Name = addtionalTerm.Name;
                            newAdditionalTerm.Term_Name__c = addtionalTerm.Term_Name__c;
                            newAdditionalTerm.TPA_Legal_Entity_1__c = materToTransactionalLegalEntityMap.get(addtionalTerm.TPA_Legal_Entity_1__r.IMS_Master_Legal_Entity__c);
                            newAdditionalTerm.Addtional_Term__c = addtionalTerm.Addtional_Term__c;
                            newAdditionalTerm.Exhibit_Attached__c = addtionalTerm.Exhibit_Attached__c;
                            newAdditionalTerm.Category__c = addtionalTerm.Category__c;
                            newAdditionalTerm.Use_Name__c = addtionalTerm.Use_Name__c;
                            newAdditionalTerm.Country_of_Offering__c = addtionalTerm.Country_of_Offering__c;
                            newAdditionalTerm.Primary_Offering_Name__c = addtionalTerm.Primary_Offering_Name__c;
                            newAdditionalTerm.Secondary_Offering_Name__c = addtionalTerm.Secondary_Offering_Name__c;
                            newAdditionalTerm.TPA_Request__c = reqObj.tpaRequest.Id;
                            newAdditionalTerm.Type__c = 'Renewed';
                            newAdditionalTerm.Is_Future_Approved__c = addtionalTerm.Is_Future_Approved__c;
                            newAdditionalTerm.Is_All_Legal_Entities_Selected__c = addtionalTerm.Is_All_Legal_Entities_Selected__c;
                            newAdditionalTerm.Ad_hoc_Term_Last_Entered_By__c = addtionalTerm.Ad_hoc_Term_Last_Entered_By__c;
                            newAdditionalTerm.Ad_hoc_Term_Last_Updated__c = addtionalTerm.Ad_hoc_Term_Last_Updated__c;
                            addtionalTermList.add(newAdditionalTerm);
                            if(adHocCatList == null || adHocCatList.size() == 0){
                                adHocCatList.add(newAdditionalTerm.Category__c) ;
                            }
                            else if(!adHocCatList.contains(newAdditionalTerm.Category__c)){
                                adHocCatList.add(newAdditionalTerm.Category__c) ;
                            }
                        }
                        if(addtionalTermList.size() > 0) {
                            insert addtionalTermList;
                        } 
                        List<Attachment> attachsToInsert = new List<Attachment>();
                        Map<Id,TPA_Additional_Term__c> addHocTerms = new Map<Id,TPA_Additional_Term__c>([Select Id,Term_Name__c,TPA_Legal_Entity_1__c,Category__c,Parent_Additional_Terms__c From TPA_Additional_Term__c where TPA_Request__c =: reqObj.tpaRequest.Id]);
                        for(TPA_Additional_Term__c addHocTerm: addHocTerms.values()){
                            TPA_Additional_Term__c parentTerm = addHocTerm.Parent_Additional_Terms__c != null ? addHocTerms.get(addHocTerm.Parent_Additional_Terms__c) : null;
                            if(keysWithAttachment.containsKey(UTL_TPA.createAddHocKey(addHocTerm))){
                                Attachment newAttach = keysWithAttachment.get(UTL_TPA.createAddHocKey(addHocTerm)).clone();
                                newAttach.ParentId = addHocTerm.Id;
                                attachsToInsert.add(newAttach);
                            }
                            else if( parentTerm != null && keysWithAttachment.containsKey(UTL_TPA.createAddHocKey(parentTerm))){
                                Attachment newAttach = keysWithAttachment.get(UTL_TPA.createAddHocKey(parentTerm)).clone();
                                newAttach.ParentId = addHocTerm.Id;
                                attachsToInsert.add(newAttach);
                            }
                            //keysWithAttachment
                        }
                        if(attachsToInsert.size() > 0){
                            insert attachsToInsert;
                        }
                        if(adHocCatList.size() > 0){
                            adHocCatList.sort();
                            String colonSepCat = '';
                            if(adHocCatList.size() >0){
                                colonSepCat = String.join(adHocCatList, ';');
                            }
                            reqObj.tpaRequest.Ad_hoc_Categories__c = colonSepCat;
                            upsert reqObj.tpaRequest;
                        }
                    }    
                    
                    getLimitsMessage();
                    TPA_Agreement_Additional_Field__c agreementAdditionalFieldData = new TPA_Agreement_Additional_Field__c();
                    if(reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r != null && reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r.size() > 0) {
                        agreementAdditionalFieldData.id = reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r[0].id;
                    } else {
                        agreementAdditionalFieldData.Related_TPA_Request__c = reqObj.tpaRequest.id;
                    }
                    
                    try {
                        if(agreementAdditionalFieldData != null) {
                            if(reqObj.tpaRequest.Request_Type__c == 'renew') {
                                IsUpdateRenewalOfferinfDetail = true;
                            	agreementAdditionalFieldData.Parent_TPA_Request_Offering_Data__c = reqObj.parentRequestOfferingDetails;
                                agreementAdditionalFieldData.Parent_TPA_Request_Offering_Category_s__c = reqObj.parentRequestCategoryDetails;
                                agreementAdditionalFieldData.Parent_TPA_Request_Offering_Country_s__c = reqObj.parentRequestOffCountryDetails;
                            	agreementAdditionalFieldData.Parent_TPA_Request_Use_Data__c = reqObj.parentRequestUseDetails;

                            }
                            upsert agreementAdditionalFieldData;
                        }
                    } catch(Exception ex) {
                        UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest:::agreementAdditionalFieldData upsert Exception', reqObj.tpaRequest.Id));
                        UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                        System.debug('**Exception while upserting Agreement Additional Field Data**'+ex.getMessage());
                    }

                    if(reqObj.useOffBackupIds != null && reqObj.useOffBackupIds != '') {
                        List<TPA_Use_Offerings_UI_Backup__c> useOffListToUpdate = new List<TPA_Use_Offerings_UI_Backup__c>();
                        for(string strUseOffId: reqObj.useOffBackupIds.split(';')) {
                            TPA_Use_Offerings_UI_Backup__c useOffObj = new TPA_Use_Offerings_UI_Backup__c();
                            useOffObj.Id = strUseOffId;
                            useOffObj.TPA_Request__c = reqObj.tpaRequest.Id;
                            useOffListToUpdate.add(useOffObj);
                        }
                        if(useOffListToUpdate.size() > 0) {
                            update useOffListToUpdate;
                        }
                    }
                    getLimitsMessage();                     

                    //SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(reqObj.tpaRequest.Id);//TODO: will review
                    SRV_TPA_TPARequest.tpaRequest = reqObj.tpaRequest;

                    //SRV_TPA_TPARequest.type = reqObj.tpaRequest.Request_Type__c;
                    if(reqObj.isRenewedReqUseandOfferingChanged != null) {
                        SRV_TPA_TPARequest.isRenewedReqUseandOfferingChanged = reqObj.isRenewedReqUseandOfferingChanged;
                    }
                    //SRV_TPA_TPARequest.requestNumber = ( reqObj.tpaRequest.Request_Type__c == 'New' ? reqObj.tpaRequest.Name : reqObj.tpaRequest.Parent_Request__r.Name );
                    
                    // if(reqObj.tpaRequest.Parent_Request__c != null) {
                    //     SRV_TPA_TPARequest.parentRequest = SRV_TPA_TPARequest.getRequestInfo(reqObj.tpaRequest.Parent_Request__c);//TODO: review
                    // }
                    //SRV_TPA_TPARequest.LastAction = reqObj.tpaRequest.LastAction__c;   
                    SRV_TPA_TPARequest.createActivityHistoryForClient();

                    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

                    UTL_TPA_Multilingual.updateChildRecordsTranslation(reqObj.tpaRequest.id, null);
                    UTL_TPA_Multilingual.langCrossWalkMap = null; //Setting Null after use to save heap size
                    UTL_TPA_Multilingual.tpaReqObj = null; //Setting Null after use to save heap size
                }
            }
            else if(reqObj.requestTypeSubmitted == 'ClientSubmit' || reqObj.requestTypeSubmitted == 'InDraftRequest') {
                reqObj.tpaRequest.Is_New_Notification_Sent__c = true;
                reqObj.tpaRequest.Client_Language__c = supportedLanguageMap.get(language).split('~')[0];
                reqObj.tpaRequest.Is_Vendor_Id_Invalid__c = false;
                reqObj.tpaRequest.Is_Vendor_Name_Contains_Veeva__c = false;
                reqObj.tpaRequest.Is_Vendor_Veeva_for_all_Use__c = false;
                reqObj.tpaRequest.Is_Vendor_Name_Contains_MedPro__c = false;
                //reqObj.tpaRequest.Is_Vendor_Name_Contains_DeepIntent__c = false;
                reqObj.tpaRequest.Is_Vendor_Related_to_Source_Symphony_Acc__c = false;
                reqObj.tpaRequest.Is_Veeva_Use_CRM_Off_OneKey__c = false;
                //reqObj.tpaRequest.is_Veeva_Use_CRM__c = false;
                reqObj.tpaRequest.Is_Veeva_Use_CRM_SubNational_Off__c = false;
                reqObj.tpaRequest.Is_South_Africa_Sub_Off__c = false;
                reqObj.tpaRequest.is_Specific_Vendors_LAAD_Off__c = false;
                reqObj.tpaRequest.is_Specific_Vendors_APLD_Off__c = false;
                reqObj.tpaRequest.is_Specific_Vendors_Long_Prescr_Data__c = false;
                reqObj.tpaRequest.is_Specific_Vendors_Medical_Claims_Data__c = false;
                reqObj.tpaRequest.Is_Vendor_Name_Contains_Edith__c = false;
                reqObj.tpaRequest.Is_Vendor_Name_Contains_DLIMI__c = false;
                reqObj.tpaRequest.Is_Vendor_Name_Contains_MedPro__c = false;
                reqObj.tpaRequest.is_20_or_more_Offering_Present__c = false;
                reqObj.tpaRequest.Is_VSN_Acknowlege_By_Client__c = false;
                reqObj.tpaRequest.is_VSN_Selected__c = false;
                reqObj.tpaRequest.is_Addendum_Attachment_Required__c = false;
                reqObj.tpaRequest.is_LAAD_Response_Acknowledged__c = false;
                reqObj.tpaRequest.is_LAAD_Response_Required__c = false;
                reqObj.tpaRequest.Pending_Acknowledgements__c = '';
                reqObj.tpaRequest.DDN_Ack_Pending_Requests__c = '';

                for(IMS_Legal_Entity__c oldLegalEntity : reqObj.tpaRequest.IMS_Legal_Entities__r) {
                    oldLegalEntity.is_GE_Centricity_EMR__c = false;
                    oldLegalEntity.is_Managed_Workbook__c = false;
                    oldLegalEntity.isDDDOffering__c = false;
                    oldLegalEntity.is_Xponent__c = false;
                    oldLegalEntity.is_Midas__c = false;
                    oldLegalEntity.Is_Ambulatory_EMR__c = false;
                    oldLegalEntity.Is_Oncology_EMR__c = false;
                    oldLegalEntity.Is_Health_Plan_Claims__c = false;
                    oldLegalEntity.is_South_Africa_Consumer_Health__c = false;
                    oldLegalEntity.is_LAAD_Offering__c = false;
                    oldLegalEntity.is_Patient_Companion_File__c = false;
                    oldLegalEntity.is_Payer_Companion_File__c = false;
                    oldLegalEntity.is_Provider_Companion_File__c = false;
                    oldLegalEntity.is_Promotrak__c = false;
                    oldLegalEntity.Is_Glbl_PromoTrack_Selected__c = false;
                    oldLegalEntity.is_Canada__c = false;
                    oldLegalEntity.containUS__c = false;
                    oldLegalEntity.is_Xponent_or_OneKey__c = false;
                    oldLegalEntity.Is_MedPages_Data__c = false;
                    oldLegalEntity.is_AIM_XR__c = false;
                    oldLegalEntity.is_Analytics_Link__c = false;
                }

                if(reqObj.requestTypeSubmitted == 'InDraftRequest') {
                    reqObj.tpaRequest.Is_New_Notification_Sent__c = false;
                    reqObj.tpaRequest.Request_Status__c = 'Client Draft';
                    reqObj.tpaRequest.TPA_Request_Temporary_Status__c= 'Client Draft';
                }
                else if(!reqObj.isPublicPrivateChangeOnly) {
                    reqObj.tpaRequest.Request_Status__c = 'Awaiting Vendor Submission';
                    reqObj.tpaRequest.TPA_Request_Temporary_Status__c= 'Awaiting Vendor Submission';
                }
                getLimitsMessage();

                try {
                    if(reqObj.tpaRequest.Secondary_Client_Contact_Territory__c != null) {
                        set<string> secCountryCodeSet = createStateCountryNameSet(reqObj.tpaRequest.Secondary_Client_Contact_Territory__c, 'C'); 
                        existedCountryStateCodes = null; //Set Null After use in createStateCountryNameSet function to save heap size
                        if(secCountryCodeSet != null && secCountryCodeSet.size() > 0) {
                            List<TPA_Region_Country__c> lstRegionCountry = new List<TPA_Region_Country__c>();
                            lstRegionCountry = [select TP_Processor__c,
                                                TP_Processor__r.region__c,
                                                TP_Processor__r.TP_Processor_Name__c,
                                                TP_Processor__r.TPA_Processor_Contact__c,
                                                TP_Processor__r.TPA_Processor_Contact__r.accountid,
                                                TP_Processor__r.TP_Processor_Email__c, 
                                                TP_Processor__r.Assigned_TP_Processors__c
                                            from TPA_Region_Country__c
                                            where Country__c in: secCountryCodeSet
                                            limit 1 ];
                            if(lstRegionCountry.size() != 0 ) {
                                if(lstRegionCountry[0].TP_Processor__c != null) {                                   
                                    reqObj.tpaRequest.TPA_Processor_Contact__c = lstRegionCountry[0].TP_Processor__r.TPA_Processor_Contact__c;
                                    reqObj.tpaRequest.TP_Processor_Email__c = lstRegionCountry[0].TP_Processor__r.TP_Processor_Email__c;
                                    reqObj.tpaRequest.TP_Processor_Name__c = lstRegionCountry[0].TP_Processor__r.TP_Processor_Name__c;
                                    List<TPA_Assigned_TP_Processor__c> assignedTPProcessors = [select Id, Name from TPA_Assigned_TP_Processor__c where TP_Processor__c =: lstRegionCountry[0].TP_Processor__c];
                                    if(assignedTPProcessors.size() != 0 && assignedTPProcessors.size() == 1){
                                        TPA_Assigned_TP_Processor__c assignedtpprocessor = assignedTPProcessors[0];
                                        reqObj.tpaRequest.TPA_Assigned_TP_Processor__c = assignedtpprocessor.Id;
                                    }
                                }
                                else {
                                    reqObj.tpaRequest.TPA_Processor_Account_Address__c = null;
                                    reqObj.tpaRequest.TPA_Processor_Contact__c = null;
                                }
                            }
                        }
                    }
                }
                catch(Exception ex) {
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest:::Client Edit:::TPA Processor Update Exception', (reqObj != null && reqObj.tpaRequest != null) ? reqObj.tpaRequest.Id : ''));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                    System.debug('**Exception while Client Edit:::TPA Processor Update Exception**'+ex.getMessage());
                }
                getLimitsMessage();

              //  reqObj.tpaRequest.AMA_Services_Provided__c = savePurposes(reqObj);
              savePurposes(reqObj);
                
                reqObj.tpaRequest.agreement_effective_date__c = null;            
                /*
                TPA_Request_Backup__c TPARequestBackupDetails = getRequestBackup(reqObj, 'Client');
                TPARequestBackupDetails.Submission_Type__c = 'Client Submission';
                TPARequestBackupDetails.Related_TPA_Request__c = reqObj.tpaRequest.id;
                insert TPARequestBackupDetails;
                TPARequestBackupDetails = null;//Setting Null After use to save heap size                    
                */
                getLimitsMessage();
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Uses and Offerings Updated', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id)); // Debug log change
                
                List<TPA_contact__c> existedTpaContacts = SLT_TPAContact.instance.getTPAContactByCodition('TPA_Request__c = \'' + reqObj.tpaRequest.Id + '\' and (Type__c = \'' + TPA_CONTACTTYPE_ADDITIONAL + '\' OR Type__c = \'' + TPA_ADDITIONAL_CLIENT_CONTACT + '\' )');                    
                delete existedTpaContacts;
                
                User currLoginUserObj = UTL_TPA.getCurrentUserDetails();
                Address__c currentAddress =  UTL_TPA.getAddress(reqObj.clientAddress);
                reqObj.tpaRequest.Client_Contact_Territory__c = currentAddress.Region_Territory__c;
                reqObj.tpaRequest.Secondary_Client_Contact_Territory__c = currentAddress.Region_Territory__c;
                getLimitsMessage();
                reqObj.tpaRequest.ClientContact__c = currLoginUserObj.contactId;                
                
                if(reqObj.requestTypeSubmitted == 'InDraftRequest') {
                    reqObj.tpaRequest.LastAction__c = 'Draft Request Edited By Client';
                } else {
                    reqObj.tpaRequest.LastAction__c = 'Request Edited By Client';
                }
               
                getLimitsMessage();
                if(reqObj.requestTypeSubmitted != 'InDraftRequest') {                    
                    if(reqObj.tpaRequest.AMA_USPrescriberData__c == 'Yes' ) {
                        amaAgreementDetails = getAmaAgreement(reqObj.tpaRequest, reqObj.amaAgrSubmitted, 'ClientSubmit');
                        resetAmaValuesOnTpaRequest(reqObj.tpaRequest);
                    } else {
                        reqObj.tpaRequest.Type_of_AMA_Agreement__c = null;
                        reqObj.tpaRequest.AMA_DBL__c = null;
                    }                 
                }

                TPA_Request__c parentRequest;
                if(reqObj != null && reqObj.tpaRequest.Parent_Request__c != null){
                    parentRequest = new TPA_Request__c();
                    parentRequest.Id = reqObj.tpaRequest.Parent_Request__c;
                    parentRequest.Renewed_Type__c = reqObj.tpaRequest.Parent_Request__r.Renewed_Type__c;
                }
                if(parentRequest != null && reqObj.isRenewedReqUseandOfferingChanged != null && reqObj.isRenewedReqUseandOfferingChanged != '' && reqObj.isRenewedReqUseandOfferingChanged != parentRequest.Renewed_Type__c){
                    if(reqObj.isRenewedReqUseandOfferingChanged == 'Modified Renewal'){
                        parentRequest.Renewed_Type__c = 'Modified Renewal';
                    }
                    if(reqObj.isRenewedReqUseandOfferingChanged == 'Renewed'){
                        parentRequest.Renewed_Type__c = 'Renewed';
                    }
                    UTL_TPA.modifyRequestForcefully = true;
                    update parentRequest; //TODO: Will review
                    DAOH_TpaRequest.isManageSharingTriggerd = false;
                    UTL_TPA.modifyRequestForcefully = false;
                }
                getLimitsMessage();
                update reqObj.tpaRequest; //TODO: will review, insert logs

                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Request Updated before updateClientCopies() method', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id)); // Debug log change

                updateClientCopies(reqObj);

                if(reqObj.requestTypeSubmitted != 'InDraftRequest') {
                    SRV_TPA_TPARequest.updateAgreementFieldsForClient(reqObj.tpaRequest);
                    SRV_TPA_TPARequest.updateActivityHistory(reqObj.tpaRequest.Id, 'TPA Request Edited', false);
                    SRV_TPA_TPARequest.updateActivityHistory(reqObj.tpaRequest.Id, 'Email Notification Send to Vendor', true);
                    
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'updateAgreementFieldsForClient called', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id));
                    UTL_TPA_Multilingual.updateChildRecordsTranslation(reqObj.tpaRequest.Id, null);
                }
                getLimitsMessage();
                if(reqObj.requestTypeSubmitted != 'InDraftRequest') {                   
                    //reqObj.tpaRequest = SRV_TPA_TPARequest.getRequestInfo( reqObj.tpaRequest.Id ); //TODO: Will review
                    List<TPA_Request__c> tpaRequestList = [select id, name, AMA_USPrescriberData__c, 
                    Request_Type__c, Parent_Request__r.Name, Parent_Request__c, LastAction__c, ClientContact__c, Client_Contact_Territory__c, vendor_language__c, client_language__c, Vendor_Contact_Email_Client__c, TP_Processor_Email__c, Is_New_Notification_Sent__c, Client_Address__c, Client_Address__r.Name, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Request_Status__c, (SELECT Id FROM TPA_Agreement_Additional_Fields__r), (select id from AMA_Agreement_Details__r) from TPA_Request__c where id =: reqObj.tpaRequest.Id];

                    if(tpaRequestList != null && tpaRequestList.size() > 0) {
                        reqObj.tpaRequest = tpaRequestList[0];
                    }

                    if(reqObj.tpaRequest.AMA_USPrescriberData__c == 'Yes' ) {
                        if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
                            amaAgreementDetails.id = reqObj.tpaRequest.AMA_Agreement_Details__r[0].id;
                        }
                        else {
                            amaAgreementDetails.TPA_Request__c = reqObj.tpaRequest.id;
                        }
                    }
                    else {
                        if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
                            delete reqObj.tpaRequest.AMA_Agreement_Details__r[0];
                        }
                    }
                    try {
                        if(amaAgreementDetails != null) {
                            upsert amaAgreementDetails;
                            SRV_TPA_AMAAgreementDetail.amaAgreementDetails = amaAgreementDetails;
                            SRV_TPA_AMAAgreementDetail.resetAllAmaAgreementDetail ();
                            amaAgreementDetails = null; //Setting Null after user to save heap size
                        }
                    }
                    catch(Exception ex) {
                        UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest:::amaAgreementDetails upsert and reset', reqObj.tpaRequest.Id));
                        UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                        System.debug('**Exception while upserting AMA agreement**'+ex.getMessage());
                    }
                   
                    getLimitsMessage();
                    if(reqObj.useOffBackupIds != null && reqObj.useOffBackupIds != '') {
                        List<TPA_Use_Offerings_UI_Backup__c> useOffListToUpdate = new List<TPA_Use_Offerings_UI_Backup__c>();
                        for(string strUseOffId: reqObj.useOffBackupIds.split(';')) {
                            TPA_Use_Offerings_UI_Backup__c useOffObj = new TPA_Use_Offerings_UI_Backup__c();
                            useOffObj.Id = strUseOffId;
                            useOffObj.TPA_Request__c = reqObj.tpaRequest.Id;
                            useOffListToUpdate.add(useOffObj);
                        }
                        if(useOffListToUpdate.size() > 0) {
                            update useOffListToUpdate;
                        }
                    }
                }

                getLimitsMessage();
                try {
                    TPA_Agreement_Additional_Field__c agreementAdditionalFieldData = new TPA_Agreement_Additional_Field__c();
                    if(reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r != null && reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r.size() > 0) {
                        agreementAdditionalFieldData.id = reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r[0].id;
                    }                 
                
                    if(agreementAdditionalFieldData != null) {
                        if(reqObj.tpaRequest.Request_Type__c == 'renew') {
                            IsUpdateRenewalOfferinfDetail = true;
                        }
                        upsert agreementAdditionalFieldData;
                    }
                } catch(Exception ex) {
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest:::agreementAdditionalFieldData upsert Exception', reqObj.tpaRequest.Id));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                    System.debug('**Exception while updating Agreement Additional Field Data**'+ex.getMessage());
                }
            }
            getLimitsMessage();

            

            getLimitsMessage();

            if(reqObj.requestTypeSubmitted == 'NewRequest' 
            || reqObj.requestTypeSubmitted == 'ClientSubmit' 
            || reqObj.requestTypeSubmitted == 'InDraftRequest') {
                try{
                    if(reqObj.tpaRequest.ClientContact__c != null) {
                        String profileName = currentLoggedInUser.Profile.Name;
                        List<Contact> clientContact = [Select Id, Name, Client_Contact_Territory__c from Contact where Id =: reqObj.tpaRequest.ClientContact__c limit 1];
                        if(clientContact != null && clientContact.size() > 0 && !isTPProcessor && !isUSTPProcessor && clientContact[0].Client_Contact_Territory__c != null && clientContact[0].Client_Contact_Territory__c != '' ) {
                            clientContact[0].Client_Contact_Territory__c = reqObj.tpaRequest.Client_Contact_Territory__c;
                            update clientContact[0];
                        }
                    }
                }
                catch(Exception ex){
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest::updateContactCatch', (reqObj != null && reqObj.tpaRequest != null) ? reqObj.tpaRequest.Id : ''));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                }
                
                if(reqObj.requestTypeSubmitted == 'NewRequest') {
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, UTL_TPA.savePoints.get(isUSTPProcessor?'2E':'1E'), 'TPA', 'Custom', 'INFO', (isUSTPProcessor?'By US TP Processor':'By Client') + ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id));
                }
                else {
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, UTL_TPA.savePoints.get((isTPProcessor || isUSTPProcessor)?'4E':'3E'), 'TPA', 'Custom', 'INFO', (isUSTPProcessor?'By US TP Processor':'By Client')+':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id)); // Debug log change                    
                }

                if(reqObj.requestTypeSubmitted == 'NewRequest') {
                    vendorSubmissionNotification(reqObj.tpaRequest); 
                }
                else if(reqObj.requestTypeSubmitted == 'ClientSubmit') {
                    if(!isTPProcessor && !isUSTPProcessor && !reqObj.isPublicPrivateChangeOnly) {
                        vendorSubmissionNotification(reqObj.tpaRequest);
                    }
                }

                if(reqObj.tpaRequest.Request_Status__c == 'Awaiting Vendor Submission' && currentLoggedInUser.Contact != null && TPA_Settings__c.getOrgDefaults().Gilead_Account_Ids__c != null && TPA_Settings__c.getOrgDefaults().Gilead_Account_Ids__c.contains(String.valueOf(reqObj.clientAddress).substring(0, 15))) { 
                    SRV_TPA_TPARequest.gileadRequestSubmissionEmail(reqObj.tpaRequest);
                }

                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'FROM Client Submission Complete', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'FROM Client Submission Last Reach', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
        catch(Exception ex) {
            system.debug('ERROR: '+ex.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest::FinalCatch', (reqObj != null && reqObj.tpaRequest != null) ? reqObj.tpaRequest.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
        getLimitsMessage();
    }

    public static void savePurposes(tpaRequestDetails reqObj) {
        UTL_TPA_RestApi requestArg = new UTL_TPA_RestApi();
        requestArg.requestObj = reqObj;        

        if(reqObj.requestTypeSubmitted != 'NewRequest') {
            for(IMS_Legal_Entity__c legalEntity : [select id, IMS_Master_Legal_Entity__c, (SELECT Id, Name, Addtional_Term__c, Is_All_Legal_Entities_Selected__c,Use_Name__c,Country_of_Offering__c, Parent_Additional_Terms__c, TPA_Legal_Entity_1__c, TPA_Legal_Entity_1__r.Name, Category__c, Primary_Offering_Name__c, Secondary_Offering_Name__c, TPA_Request__c from TPA_Additional_Terms1__r)  from IMS_Legal_Entity__c where TPA_Request__c=:reqObj.tpaRequest.Id]) {
                if(legalEntity.TPA_Additional_Terms1__r.size() > 0) {
                    SRV_TPA_TPARequest.MlegalEntityToAdditionalTermsMap.put(legalEntity.IMS_Master_Legal_Entity__c, legalEntity.TPA_Additional_Terms1__r);
                }            
            }
        }
        
        if(reqObj.tpaRequest.is_Bulk_TPA_Request__c) {
            if(reqObj.requestTypeSubmitted != 'NewRequest') {
                backupALLIds(reqObj);         
                requestArg.actionType = 'DeleteUseOffData';
                UTL_TPA_RestApi returnResult = UTL_TPA_RestApi.callTpaRestApiHttpPost(requestArg, userInfo.getSessionId()); //TODO: Review
            }

            requestArg.actionType = 'UpdateUseOffData';
            UTL_TPA_RestApi returnResult1 = UTL_TPA_RestApi.callTpaRestApiHttpPost(requestArg, userInfo.getSessionId()); //TODO: Review
            system.debug('returnResult1.isSuccess:' + returnResult1.isSuccess);
            if(!returnResult1.isSuccess) {
                //TODO: Insert Exception Logs here
                system.debug('legalEntityIDs: ' + legalEntityIDs);
                if(reqObj.requestTypeSubmitted != 'NewRequest') {
                    restoreALLData();
                }
            }
        } 
        else {
            if(reqObj.requestTypeSubmitted != 'NewRequest') {
                deleteData(requestArg);
            }
            updateALLData(requestArg);
        } 
        
     //   string proposedAmaStringForReturn = proposedAmaToSelect(reqObj);  

        reqObj.mapPurposeidWithDataAssetMap = null;
        reqObj.mapSecondayDataAssetToInsert = null;
        reqObj.PurposeMap = null;
        reqObj.PurposeMapOther = null;   
        
      //  return proposedAmaStringForReturn;
     //   return null;
    }

    public static void backupALLIds(tpaRequestDetails reqObj) {
        legalEntityIDs = new List<id>();
        for(IMS_Legal_Entity__c obj : [select id from IMS_Legal_Entity__c where TPA_Request__c=:reqObj.tpaRequest.Id]){
            legalEntityIDs.add(obj.id);
        }
        system.debug('legalEntityIDs: ' + legalEntityIDs);

        purposeIDsforBackup = new Set<Id>();
        for(TPA_Purpose__c obj : [select id from TPA_Purpose__c where Request__c=:reqObj.tpaRequest.Id]) {
            purposeIDsforBackup.add(obj.id);
        }
    }

    public static void restoreALLData() {
        system.debug('restoreALLData');
        system.debug('legalEntityIDs: ' + legalEntityIDs);
        system.debug('purposeIDsforBackup: ' + purposeIDsforBackup);
		//system.debug('purpDescIDsforBackup: ' + purpDescIDsforBackup);

        IMS_Legal_Entity__c[] legalEntities = [SELECT Id, Name FROM IMS_Legal_Entity__c WHERE id in : legalEntityIDs ALL ROWS]; 
        TPA_Purpose__c[] purposeList = [SELECT Id, Name FROM TPA_Purpose__c WHERE id in : purposeIDsforBackup ALL ROWS]; 

        try {
            undelete legalEntities;
            undelete purposeList;
        } catch (DmlException e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm.restoreALLData:::Exception uccurs while restoring Legal Entity or purposes', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);           
            //TODO: will review, exception logs
        }
    }

    public static UTL_TPA_RestApi deleteData(UTL_TPA_RestApi utlPsaRestApiArg) {
        tpaRequestDetails reqObj = utlPsaRestApiArg.requestObj;
        UTL_TPA_RestApi response = new UTL_TPA_RestApi();        
        response.isSuccess = true;
        response.responseMessage = 'Success';

        if(UTL_Validate.isValidGuid(reqObj.GUID)) {
            UTL_LogFactory.GUID = reqObj.GUID; 
        }
        system.debug('deleteData');
       
        try {
            Set<Id> idList = new Set<Id>();
    
            for(String s : reqObj.MapPurpDesc.keySet()) {
                idList.add(reqObj.MapPurpDesc.get(s).Purpose__c);
            }

            list<TPA_Data_Asset__c> existedDataAsset =  [select Id, A_Column_use_for_template__c, Purpose__c, Purpose__r.Purpose_Category_Name__c, Geo_Level__c, BU__C, Asset_name__c from TPA_Data_Asset__c where Request__c =: reqObj.tpaRequest.Id];
			List<TPA_Secondary_Data_Asset__c> existedSecondaryDataAsset =  [select Id,purpose__c,TPA_Data_Asset__c,TPA_Data_Asset__r.Purpose__c,TPA_Data_Asset__r.Purpose__r.Purpose_Category_Name__c,BU__c, Secondary_Asset_Geo_Level__c,IMS_secondary_Data_asset__r.name,IMS_secondary_Data_asset__r.Secondary_Asset_Name__c,(select id, Secondary_data_asset__c from TPA_Commercial_Reviews__r) from TPA_Secondary_Data_Asset__c where TPA_Request_Secondary_Assets__c = :reqObj.tpaRequest.Id];


            String detailsOfDataAsset;
            for(TPA_Data_Asset__c eDataAsset : existedDataAsset){
                detailsOfDataAsset = eDataAsset.Purpose__r.Purpose_Category_Name__c + '~' + eDataAsset.A_Column_use_for_template__c + '~' + eDataAsset.Geo_Level__c + '~' + eDataAsset.Asset_name__c + '~' + eDataAsset.BU__c ;
                List<TPA_Commercial_Review__c> commercialReviews = eDataAsset.TPA_Commercial_Reviews__r;
                commmercialReviewMap.put(detailsOfDataAsset,commercialReviews);
            }

            String detailsOfSecondaryDA;
            for(TPA_Secondary_Data_Asset__c oldSecondaryDataAsset: existedSecondaryDataAsset){
                detailsOfSecondaryDA = oldSecondaryDataAsset.TPA_Data_Asset__r.Purpose__r.Purpose_Category_Name__c + '~' + oldSecondaryDataAsset.purpose__c + '~' + oldSecondaryDataAsset.Secondary_Asset_Geo_Level__c + '~' + oldSecondaryDataAsset.IMS_secondary_Data_asset__r.Secondary_Asset_Name__c + '~' + oldSecondaryDataAsset.BU__c;
                List<TPA_Commercial_Review__c> commercialReviewsSec = oldSecondaryDataAsset.TPA_Commercial_Reviews__r;
                commercialReviewMapSec.put(detailsOfSecondaryDA, commercialReviewsSec);
            }
    
    
            
    
            List<TPA_Purpose__c> existedTpaPurposes = [select Id from TPA_Purpose__c where Request__c =: reqObj.tpaRequest.Id];
            List<TPA_Purpose_Description__c> existedTpaPurposeDescriptions = [select Id from TPA_Purpose_Description__c where  Purpose__c in :existedTpaPurposes]; 
            List<IMS_Legal_Entity__c> ExitingIMSLegalEntityList = [select id from IMS_Legal_Entity__c where TPA_Request__c=:reqObj.tpaRequest.Id];

            system.debug('existedTpaPurposes:' +existedTpaPurposes);
            system.debug('existedTpaPurposeDescriptions:' +existedTpaPurposeDescriptions);

            if(existedTpaPurposeDescriptions != null && existedTpaPurposeDescriptions.size()>0) {
                delete existedTpaPurposeDescriptions;
            }
            
            if(existedTpaPurposes != null && existedTpaPurposes.size()>0) {
                delete existedTpaPurposes;
            }
            
            if(ExitingIMSLegalEntityList != null && ExitingIMSLegalEntityList.size()>0) {
                delete ExitingIMSLegalEntityList ;
            } 
        }
        catch(Exception exp) {
            response.isSuccess = false; 
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, reqObj.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest:::deleteData delete Exception', reqObj.tpaRequest.Id));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
        return response;
    }

    public static UTL_TPA_RestApi updateALLData(UTL_TPA_RestApi utlPsaRestApiArg) {  
        tpaRequestDetails reqObj = utlPsaRestApiArg.requestObj;
        UTL_TPA_RestApi response = new UTL_TPA_RestApi();        
        response.isSuccess = true;
        response.responseMessage = 'Success';
        system.debug('updateALLData');

        if(UTL_Validate.isValidGuid(reqObj.GUID)) {
            UTL_LogFactory.GUID = reqObj.GUID; 
        }
        
        try { 
            Set<id> priOffIds = new Set<id>();
            for(Set<TPA_Data_Asset__c> setDataAssrtsToInset1 : reqObj.mapPurposeidWithDataAssetMap.values()) {
                for(TPA_Data_Asset__c dataAss : setDataAssrtsToInset1) {
                    priOffIds.add(dataAss.Data_Asset__c);
                }
            }

            Set<id> secOffIds = new Set<id>();
            for(list<TPA_Secondary_Data_Asset__c> listSecTpaDataAssets1 : reqObj.mapSecondayDataAssetToInsert.values()) {
                for(TPA_Secondary_Data_Asset__c tpaDA : listSecTpaDataAssets1) {
                    secOffIds.add(tpaDA.IMS_Secondary_Data_Asset__c);
                }
            }

            //Map<Id, String> offIDwithlegalentityName = new Map<Id, String>();
            Set<String> legalEntityList = new Set<String>();

            String FinalLegalEntityName = '';    

            for(IMS_Data_Asset__c priOff: [select id,IMS_Legal_Entity__c from IMS_Data_Asset__c where id in : priOffIds]) {
                String legalEntName =  priOff.IMS_Legal_Entity__c;
                if(legalEntName != null && legalEntName != '') {
                    if(legalEntName != Label.TPA_LegalEntity_NotIncluded) {
                        if(FinalLegalEntityName != '' && (FinalLegalEntityName == Label.Legal_Entity_Common || FinalLegalEntityName != legalEntName)){
                            FinalLegalEntityName = Label.Legal_Entity_Common;
                            break;
                        }
                        else if(FinalLegalEntityName == '' || FinalLegalEntityName == legalEntName){
                            FinalLegalEntityName = legalEntName;
                        }
                        
                    }
                }
            }

            If(FinalLegalEntityName != '' &&  FinalLegalEntityName != Label.Legal_Entity_Common){
                for(IMS_Secondary_Data_Asset__c secOFf : [select id, IMS_Legal_Entity__c, Primary_Data_Asset__c, Primary_Data_Asset__r.IMS_Legal_Entity__c from IMS_Secondary_Data_Asset__c where id in : secOffIds]) { 
                    String legalEntName ='';
                    if(secOFf.IMS_Legal_Entity__c != null && secOFf.IMS_Legal_Entity__c != '') {
                        legalEntName =  secOFf.IMS_Legal_Entity__c;
                    }
                    else {
                        legalEntName =  secOFf.Primary_Data_Asset__r.IMS_Legal_Entity__c;                   
                    }
                    if(FinalLegalEntityName != '' && (FinalLegalEntityName == Label.Legal_Entity_Common || FinalLegalEntityName != legalEntName)){
                        FinalLegalEntityName = Label.Legal_Entity_Common;
                        break;
                    }
                    else if(FinalLegalEntityName == '' || FinalLegalEntityName == legalEntName){
                        FinalLegalEntityName = legalEntName;
                    }
                }
            }

            legalEntityList = new Set<String> {FinalLegalEntityName};

            // Commented under Canada legal entity removal logic Start

            // Boolean isCanadaLegalEntityPresent = false;   
            
            

            // for(IMS_Data_Asset__c priOff: [select id,IMS_Legal_Entity__c from IMS_Data_Asset__c where id in : priOffIds]) {
            //     String legalEntName =  priOff.IMS_Legal_Entity__c;
            //     offIDwithlegalentityName.put(priOff.id, legalEntName);
            //     if(legalEntName != null && !legalEntityList.contains(legalEntName)) {
            //         if(legalEntName == Label.Canada_Legal_Entity) {
            //             isCanadaLegalEntityPresent = true;
            //         }
            //         if(legalEntName != Label.TPA_LegalEntity_NotIncluded) {
            //            legalEntityList.add(legalEntName);
            //         }
            //     }
            // }

            // for(IMS_Secondary_Data_Asset__c secOFf : [select id, IMS_Legal_Entity__c, Primary_Data_Asset__c, Primary_Data_Asset__r.IMS_Legal_Entity__c from IMS_Secondary_Data_Asset__c where id in : secOffIds]) { 
            //     String legalEntName ='';
            //     if(secOFf.IMS_Legal_Entity__c != null && secOFf.IMS_Legal_Entity__c != '') {
            //         legalEntName =  secOFf.IMS_Legal_Entity__c;
            //         offIDwithlegalentityName.put(secOFf.id, secOFf.IMS_Legal_Entity__c);
            //     }
            //     else {
            //         legalEntName =  secOFf.Primary_Data_Asset__r.IMS_Legal_Entity__c; 
            //         offIDwithlegalentityName.put(secOFf.id, secOFf.Primary_Data_Asset__r.IMS_Legal_Entity__c);                    
            //     }

            //     if(legalEntName != null && !legalEntityList.contains(legalEntName)) {
            //         if(legalEntName == Label.Canada_Legal_Entity) {
            //             isCanadaLegalEntityPresent = true;
            //         }
            //         legalEntityList.add(legalEntName);
            //     }
            // }

            // Set<String> stLegalEntityNames = new Set<String>();
            // if(legalEntityList.size() == 1) {
            //     stLegalEntityNames.addAll(legalEntityList);
            // } else if(legalEntityList.size() > 1 && !isCanadaLegalEntityPresent) {
            //     stLegalEntityNames.add(Label.Legal_Entity_Common);
            // } else if(legalEntityList.size() > 1 && isCanadaLegalEntityPresent) {
            //     stLegalEntityNames.add(Label.Legal_Entity_Common);
            //     stLegalEntityNames.add(Label.Canada_Legal_Entity);
            // }

             // Commented under Canada legal entity removal logic End

            List<IMS_Legal_Entity__c> newIMSLegalEntityList = new List<IMS_Legal_Entity__c>();
            for(IMS_Master_Legal_Entity__c IMSMasterLegalEntity : [Select Id, Name, Legal_Entity_Name_for_TLLA__c, IMS_Entity_Address__c, Location_of_Governing_Law__c from IMS_Master_Legal_Entity__c where Name in: legalEntityList] ) { 
                IMS_Legal_Entity__c ImsEntity = new IMS_Legal_Entity__c();
                ImsEntity.TPA_Request__c = reqObj.tpaRequest.Id;
                ImsEntity.Name = IMSMasterLegalEntity.Name;
                ImsEntity.Legal_Entity_Name_for_TLLA__c = IMSMasterLegalEntity.Legal_Entity_Name_for_TLLA__c;
                ImsEntity.IMS_Entity_Address__c = IMSMasterLegalEntity.IMS_Entity_Address__c;
                ImsEntity.Location_of_Governing_Law__c = IMSMasterLegalEntity.Location_of_Governing_Law__c;
                ImsEntity.IMS_Master_Legal_Entity__c = IMSMasterLegalEntity.Id;
                newIMSLegalEntityList.add(ImsEntity);
            }
            if(newIMSLegalEntityList.size() > 0) {
                upsert newIMSLegalEntityList;
            }

            Map<String, IMS_Legal_Entity__c> mapEntityNameWithObj = new Map<String, IMS_Legal_Entity__c>();
            for(IMS_Legal_Entity__c objEntity : [Select Id, Legal_Entity_Name_for_TLLA__c,Name, IMS_Master_Legal_Entity__c,IMS_Master_Legal_Entity__r.Name from IMS_Legal_Entity__C where TPA_Request__c = :reqObj.tpaRequest.Id]) {
                mapEntityNameWithObj.put(objEntity.Legal_Entity_Name_for_TLLA__c, objEntity);
            }

            if(reqObj.PurposeMap != null && reqObj.PurposeMap.size() > 0) {
                for(TPA_Purpose__c purInsert : reqObj.PurposeMap.values()) {
                    purInsert.Request__c = reqObj.tpaRequest.Id;
                }
                insert reqObj.PurposeMap.values();
            }

            if(reqObj.PurposeMapOther != null && reqObj.PurposeMapOther.size() > 0) {
                for(TPA_Purpose__c purInsert : reqObj.PurposeMapOther.values()) {
                    purInsert.Request__c = reqObj.tpaRequest.Id;
                }
                insert reqObj.PurposeMapOther.values();
            }
            UTL_TPA.isPurposeUpdateCalled = false; //TODO:will review, check if this flag should be true or false here, no where set as true

            Set<Id> idList = new Set<Id>();        
            map<String, id> mapImsPurposeToTpaPurpose = new map<String, id>();
            idList.clear();
            for(String s : reqObj.MapPurpDesc.keySet()) {
                reqObj.MapPurpDesc.get(s).Purpose__c = reqObj.PurposeMap.get(s).Id;
                idList.add(reqObj.MapPurpDesc.get(s).Purpose__c);
                mapImsPurposeToTpaPurpose.put(reqObj.PurposeMap.get(s).Purpose__c + ':' + reqObj.PurposeMap.get(s).TPA_Purpose_Category__c + ':'+reqObj.PurposeMap.get(s).BU__C+':', reqObj.PurposeMap.get(s).Id);
            }
        
            if( reqObj.MapPurpDesc != null && reqObj.MapPurpDesc.size() > 0) {
                insert reqObj.MapPurpDesc.values(); 
            }
            

            for(String catId : reqObj.MapPurpDescOther.keySet()) {
                reqObj.MapPurpDescOther.get(catId).Purpose__c = reqObj.PurposeMapOther.get(catId).Id;
                idList.add(reqObj.MapPurpDescOther.get(catId).Purpose__c);
                mapImsPurposeToTpaPurpose.put(':'+reqObj.PurposeMapOther.get(catId).BU__C+':'+reqObj.PurposeMapOther.get(catId).TPA_Purpose_Category__c+':'+reqObj.MapPurpDescOther.get(catId).Other_Details__c, reqObj.PurposeMapOther.get(catId).Id);
            }
        
            if( reqObj.MapPurpDescOther != null && reqObj.MapPurpDescOther.size() > 0) {
                insert reqObj.MapPurpDescOther.values();
            }
            
           // set<TPA_Data_Asset__c> setDataAssrtsToInset;
            //list<TPA_Secondary_Data_Asset__c> listSecTpaDataAssets;                     
            list<TPA_Data_Asset__c> listDataAssetToInset = new list<TPA_Data_Asset__c>();
            list<TPA_Secondary_Data_Asset__c> listSecDataAssetToInset = new list<TPA_Secondary_Data_Asset__c>();
            Map<String, id> mapimsDataAssToTpaDataAssets = new Map<String, id>();
            Set<String> uniqueOfferingSet = new Set<String>();
            
            for(String imsPurposeIdSelReg : reqObj.mapPurposeidWithDataAssetMap.keySet()) {
              //  setDataAssrtsToInset = reqObj.mapPurposeidWithDataAssetMap.get(imsPurposeIdSelReg);
                Id entityId = null;
                String entityNameOther = '';
                IMS_Legal_Entity__c objEntity  = null;
                String [] splittedKey = imsPurposeIdSelReg.split(':');
                String useKey;
                for(TPA_Data_Asset__c dataAss : reqObj.mapPurposeidWithDataAssetMap.get(imsPurposeIdSelReg)) {
                    if(entityId == null && dataAss.Asset_NametText__c != 'Other') {
                        //Commented under Canada legal entity removal logic Start
                        // if(mapEntityNameWithObj.containsKey(offIDwithlegalentityName.get(dataAss.Data_Asset__c))){
                        //     entityId = mapEntityNameWithObj.get(offIDwithlegalentityName.get(dataAss.Data_Asset__c)).id;
                        //     entityNameOther = offIDwithlegalentityName.get(dataAss.Data_Asset__c);
                        // }
                        // else{
                        //     entityId = mapEntityNameWithObj.get(Label.Legal_Entity_Common).id;
                        //     entityNameOther = Label.Legal_Entity_Common;
                        // }
                        //Commented under Canada legal entity removal logic end
                        if(FinalLegalEntityName != null && FinalLegalEntityName != ''){
                            entityId = mapEntityNameWithObj.get(FinalLegalEntityName).id;
                            entityNameOther = FinalLegalEntityName;
                        }
                    }
                    if(imsPurposeIdSelReg.substring(imsPurposeIdSelReg.length()-1, imsPurposeIdSelReg.length()).equals(':')){
                        useKey = dataAss.Data_Asset__c + ':'+splittedKey[0]+':'+splittedKey[1]+':'+splittedKey[2]+':'; 
                    }else{
                        useKey = dataAss.Data_Asset__c + ':'+splittedKey[2]+':'+splittedKey[1]+':'+splittedKey[3]+':'; 
                    }
                    if(!reqObj.mapSecondayDataAssetToInsert.containsKey(useKey)){
                        if(dataAss.Asset_NametText__c != 'Other') {
                            dataAss.IMSLegalEntity__c = entityId;
                        }                        
                    }
                    dataAss.Purpose__c = mapImsPurposeToTpaPurpose.get(imsPurposeIdSelReg);
                    dataAss.Request__c = reqObj.tpaRequest.Id;
                    if(!uniqueOfferingSet.contains(dataAss.BU__c + '~' + dataAss.Purpose__c + '~' + dataAss.Data_Asset__c)) {
                        listDataAssetToInset.add( dataAss );
                        uniqueOfferingSet.add(dataAss.BU__c + '~' + dataAss.Purpose__c + '~' + dataAss.Data_Asset__c);
                    }
                }
                for(TPA_Data_Asset__c dataAss : reqObj.mapPurposeidWithDataAssetMap.get(imsPurposeIdSelReg)) {//TODO: will review, Can we do this process in above loop itself
                    if(dataAss.Asset_NametText__c == 'Other') {
                        dataAss.IMSLegalEntity__c = entityId;
                        dataAss.IMS_Legal_Entity_for_Other__c = entityNameOther;
                    }
                }
            }
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Backup Details in savePurposes : 4', 'TPA', 'Custom', 'INFO', 'listDataAssetToInset(' + listDataAssetToInset.Size() + ') uniqueOfferingSet(' + uniqueOfferingSet.Size() + ')', reqObj.tpaRequest.Id));
            
            insert listDataAssetToInset;

            List<TPA_Data_Asset__c> tpaDataAssetList = [SELECT Id ,
                                                        Purpose__r.Purpose__c,
                                                        Purpose__c,
                                                        Purpose__r.Name,
                                                        DATA_Asset__c,
                                                        Purpose__r.TPA_Purpose_Category__c,
                                                        Purpose__r.Purpose_Category_Name__c,
                                                        BU__c,
                                                        A_column_use_for_template__C,
                                                        Geo_Level__c,
                                                        Asset_name__c
                                                        FROM TPA_Data_Asset__c 
                                                        where id in :listDataAssetToInset];
            
            Set<Id> purposeSetId = new Set<Id>();
            //List<TPA_Commercial_Review__c> commercialReviewsToUpdate = new List<TPA_Commercial_Review__c>();

            //String detailsOfDataAsset;
            for(TPA_Data_Asset__c objDataAsset : tpaDataAssetList) {
                purposeSetId.Add(objDataAsset.Purpose__c);
                /*detailsOfDataAsset = objDataAsset.Purpose__r.Purpose_Category_Name__c + '~' + objDataAsset.A_Column_use_for_template__c + '~' + objDataAsset.Geo_Level__c + '~' + objDataAsset.Asset_name__c + '~' + objDataAsset.BU__c ;
                List<TPA_Commercial_Review__c> commercialReviews = commmercialReviewMap.get(detailsOfDataAsset);
                if((commercialReviews!=null)&&(commercialReviews.size()>0)){
                    for(TPA_Commercial_Review__c ComRev : commercialReviews){
                        comRev.Primary_Data_Asset__c = objDataAsset.id;
						commercialReviewsToUpdate.add(comRev);                   
                    }
                }*/
            }

            List<TPA_Purpose_Description__c> tpaPurpDesc = [Select Other_Details__c, Purpose__c, Description__c, Description_Text__c, Purpose__r.Purpose_Category_Name__c, Purpose__r.Name from TPA_Purpose_Description__c where Purpose__c in: purposeSetId];
            Map<Id, TPA_Purpose_Description__c> tpaPurpDescMap = new Map<Id, TPA_Purpose_Description__c>();
            for(TPA_Purpose_Description__c tpaPurpDescOther: tpaPurpDesc) {
                tpaPurpDescMap.put(tpaPurpDescOther.Purpose__c, new TPA_Purpose_Description__c(Purpose__c = tpaPurpDescOther.Purpose__c,Other_Details__c=tpaPurpDescOther.Other_Details__c, Description__c=tpaPurpDescOther.Description__c, Description_Text__c=tpaPurpDescOther.Description_Text__c)); 
            }
            for(TPA_Data_Asset__c objDataAsset : tpaDataAssetList) {
                if( objDataAsset.Purpose__r.Name != 'Other') {
                    mapimsDataAssToTpaDataAssets.put(objDataAsset.DATA_Asset__c+':'+objDataAsset.Purpose__r.Purpose__c+':'+objDataAsset.Purpose__r.TPA_Purpose_Category__c+':'+objDataAsset.BU__c+':',objDataAsset.Id); 
                }
                else {
                    mapimsDataAssToTpaDataAssets.put(objDataAsset.DATA_Asset__c+'::'+objDataAsset.Purpose__r.TPA_Purpose_Category__c+':'+objDataAsset.BU__c+':'+((tpaPurpDescMap.get(objDataAsset.Purpose__c) != null && tpaPurpDescMap.get(objDataAsset.Purpose__c).Other_Details__c != null) ? tpaPurpDescMap.get(objDataAsset.Purpose__c).Other_Details__c : ''),objDataAsset.Id); 
                }
            }              
        
            idList.clear();
           // system.debug('reqObj.mapSecondayDataAssetToInsert: ' + reqObj.mapSecondayDataAssetToInsert);
            for(String imsDatacassPurposeId : reqObj.mapSecondayDataAssetToInsert.keySet()) {
                //listSecTpaDataAssets = reqObj.mapSecondayDataAssetToInsert.get(imsDatacassPurposeId);
                for(TPA_Secondary_Data_Asset__c tpaDA : reqObj.mapSecondayDataAssetToInsert.get(imsDatacassPurposeId)) {
                    Id entityId = null;
                    // if(mapEntityNameWithObj.containsKey(offIDwithlegalentityName.get(tpaDA.IMS_Secondary_Data_Asset__c))){
                    if(FinalLegalEntityName != null && FinalLegalEntityName != ''){
                        //entityId = mapEntityNameWithObj.get(offIDwithlegalentityName.get(tpaDA.IMS_Secondary_Data_Asset__c)).id;
                        entityId = mapEntityNameWithObj.get(FinalLegalEntityName).id;
                    }
                    // else{
                    //     entityId = mapEntityNameWithObj.get(Label.Legal_Entity_Common).id;
                    // }
                    
                    //system.debug('entityId: ' + entityId);
                    
                    tpaDA.TPA_Data_Asset__c = mapimsDataAssToTpaDataAssets.get(imsDatacassPurposeId);
                    tpaDA.TPA_Request_Secondary_Assets__c = reqObj.tpaRequest.Id;
                    tpaDA.IMS_Legal_Entity__c = entityId;
                    
                    idList.add(tpaDA.TPA_Data_Asset__c);
                    if(!uniqueOfferingSet.contains(tpaDA.BU__c + '~' + tpaDA.TPA_Data_Asset__c + '~' + tpaDA.IMS_Secondary_Data_Asset__c)) {
                        listSecDataAssetToInset.add( tpaDA );
                        uniqueOfferingSet.add(tpaDA.BU__c + '~' + tpaDA.TPA_Data_Asset__c + '~' + tpaDA.IMS_Secondary_Data_Asset__c);
                    }
                }
            }
            system.debug('listSecDataAssetToInset: ' + listSecDataAssetToInset);                
            insert listSecDataAssetToInset;

            /*String detailsOfSecondaryDA;
            list<TPA_Secondary_Data_Asset__c> tpaSecDataAsset = [select Id,purpose__c,TPA_Data_Asset__c,TPA_Data_Asset__r.Purpose__c,TPA_Data_Asset__r.Purpose__r.Purpose_Category_Name__c,BU__c,Secondary_Asset_Geo_Level__c, IMS_secondary_Data_asset__r.name,IMS_secondary_Data_asset__r.Secondary_Asset_Name__c,(select id, Secondary_data_asset__c from TPA_Commercial_Reviews__r) from TPA_Secondary_Data_Asset__c where id in :listSecDataAssetToInset];
            	for(TPA_Secondary_Data_Asset__c newSecondaryDA : tpaSecDataAsset){
                	detailsOfSecondaryDA = newSecondaryDA.TPA_Data_Asset__r.Purpose__r.Purpose_Category_Name__c + '~' + newSecondaryDA.purpose__c + '~' + newSecondaryDA.Secondary_Asset_Geo_Level__c + '~' + newSecondaryDA.IMS_secondary_Data_asset__r.Secondary_Asset_Name__c + '~' + newSecondaryDA.BU__c;
            		List<TPA_Commercial_Review__c> relatedCOmmRev = commercialReviewMapSec.get(detailsOfSecondaryDA);
                	if((relatedCOmmRev != null)&&(relatedCOmmRev.size() > 0)){
                    	for(TPA_Commercial_Review__c comRev : relatedCOmmRev){
                        	comRev.Secondary_Data_Asset__c = newSecondaryDA.id;
                        	commercialReviewsToUpdate.add(comRev);
                    	}
                	}
            	}

            if(commercialReviewsToUpdate != null && commercialReviewsToUpdate.size() > 0) {
                update commercialReviewsToUpdate;
            }
            commmercialReviewMap = null;
            commercialReviewMapSec = null;*/

        }
        catch(Exception exp) {
            response.isSuccess = false;
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, reqObj.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest:::deleteData updateALLData Exception', reqObj.tpaRequest.Id));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
        return response;        
    }
    
    /*public static String proposedAmaToSelect(tpaRequestDetails reqObj) {        
        String bannerAdsYes = 'Banner Ads;Assembly;Distribution and mailing;Email broadcasting;Focus groups;Inserting;Labeling;Packaging;Personalized Letters;Prescriber Recruitment;Printing;Telemarketing'; //TODO: will review, convert in labels
        String bannerAdsNo = 'Assembly;Distribution and mailing;Email broadcasting;Focus groups;Inserting;Labeling;Packaging;Personalized Letters;Prescriber Recruitment;Printing;Telemarketing';//TODO: will review, convert in labels

        String proposedAmaString = '';
        Set<String> proposedAmaSet = new Set<String>();
        
        for(TPA_Purpose__c purpose : SRV_TPA_TPARequest.getPurposesListForClientSubmission(reqObj.tpaRequest.Id)) { 
            String key = purpose.Purpose_Category_Name__c + ';' + purpose.Name;
            if(key == 'Marketing and Promotion;Direct to Prescriber and Health Care Organizations Communications') {
                if(reqObj.tpaRequest.Are_Banner_Ads_Selected__c) {
                	proposedAmaSet.addAll(bannerAdsYes.split(';'));
                }
                else {
                    proposedAmaSet.addAll(bannerAdsNo.split(';'));
                }
            }
            string proposedAmaStringValue = usesAndCategoryMap.get(key);
            if(proposedAmaStringValue != null){
                proposedAmaSet.addAll(proposedAmaStringValue.split(';'));
            }
        }
        for(String proposedAmaStringValue : proposedAmaSet){
            proposedAmaString += proposedAmaStringValue + ';';
        }
        
        return proposedAmaString.substringBeforeLast(';');
    }*/
    public static AMA_Agreement_Detail__c getAmaAgreement(TPA_Request__c tpaRequest, AMA_Agreement_Detail__c amaAgrSubmitted, String requestType) {
        amaAgreementDetails = new AMA_Agreement_Detail__c(); 
        amaAgreementDetails.Agreement_Start_Date__c = tpaRequest.Data_Access_Start_Date__c;
        amaAgreementDetails.Initial_Termination_Date__c = date.newInstance(tpaRequest.Data_Access_Start_Date__c.year(), 12, 31);
        amaAgreementDetails.Agreement_End_Date__c = date.newInstance(tpaRequest.Data_Access_End_Date__c.year(), 12, 31);
        
        if(requestType == 'NewRequest' || requestType == 'ClientSubmit' || requestType == 'Processor') {
            populateAmaValuesSubmittedByClient(amaAgreementDetails, amaAgrSubmitted, tpaRequest);
            populateAmaValuesSubmittedByVendor(amaAgreementDetails, amaAgrSubmitted, tpaRequest);
        }
        if(requestType == 'VendorSubmit' || requestType == 'Processor') {
            if(tpaRequest.AMA_TypeOfPrescriberLevelData__c != null) {
                populateAmaValuesSubmittedByClient(amaAgreementDetails, amaAgrSubmitted, tpaRequest);
            }
            populateAmaValuesSubmittedByVendor(amaAgreementDetails, amaAgrSubmitted, tpaRequest);
        }
        if(requestType == 'RunTpaBusinessRule') {
            if(tpaRequest.AMA_TypeOfPrescriberLevelData__c != null) {
                populateAmaValuesSubmittedByClient(amaAgreementDetails, amaAgrSubmitted, tpaRequest);
            }
            if(tpaRequest.AMA_Howlong_SP_has_Data_Access__c != null) {
                populateAmaValuesSubmittedByVendor(amaAgreementDetails, amaAgrSubmitted, tpaRequest);
            }
        }
        return amaAgreementDetails;
    }

    /*
     * Desc: To store all ama section values on AMA Agreement Details object submitted by client
    */
    public static void populateAmaValuesSubmittedByClient(AMA_Agreement_Detail__c amaAgreementDetailsObj, AMA_Agreement_Detail__c amaAgrSubmitted, TPA_Request__c tpaRequestObj) {
        amaAgreementDetailsObj.AMA_TypeOfPrescriberLevelData__c = tpaRequestObj.AMA_TypeOfPrescriberLevelData__c;
        amaAgreementDetailsObj.AMA_Services_Provided__c = tpaRequestObj.AMA_Services_Provided__c;
        amaAgreementDetailsObj.FrequencyOfDeliveryToServiceProvider__c = tpaRequestObj.FrequencyOfDeliveryToServiceProvider__c;
    //    amaAgreementDetailsObj.AMA_PPDVariablesCollected__c = tpaRequestObj.AMA_PPDVariablesCollected__c;
      //  amaAgreementDetailsObj.AMA_Market_Research_Attributes__c = tpaRequestObj.AMA_Market_Research_Attributes__c;
     //   amaAgreementDetailsObj.AMA_Distribution_And_Mailing_Attributes__c = tpaRequestObj.AMA_Distribution_And_Mailing_Attributes__c;
     //   amaAgreementDetailsObj.AMA_Market_Research_Attributes_For_Templ__c = tpaRequestObj.AMA_Market_Research_Attributes_For_Templ__c;
        amaAgreementDetailsObj.AMA_Dist_ana_Mail_Atrr_For_Template__c = tpaRequestObj.AMA_Dist_ana_Mail_Atrr_For_Template__c;
        amaAgreementDetailsObj.FrequencyOfDeliveryToSP_Other__c = tpaRequestObj.FrequencyOfDeliveryToSP_Other__c;
        amaAgreementDetailsObj.Client_req_Storage_Permission_from_NonUS__c = amaAgrSubmitted.Client_req_Storage_Permission_from_NonUS__c; 
        amaAgreementDetailsObj.Client_Employee_Store_Data_in_country__c = amaAgrSubmitted.Client_Employee_Store_Data_in_country__c;         
    }

    /*
     * Desc: To store all ama section values on AMA Agreement Details object submitted by vendor
    */
    public static void populateAmaValuesSubmittedByVendor(AMA_Agreement_Detail__c amaAgreementDetailsObj, AMA_Agreement_Detail__c amaAgrSubmitted, TPA_Request__c tpaRequestObj) {
        amaAgreementDetailsObj.AMA_Howlong_SP_has_Data_Access__c = tpaRequestObj.AMA_Howlong_SP_has_Data_Access__c;
        //amaAgreementDetailsObj.AMA_HowResponseDataCollected__c = tpaRequestObj.AMA_HowResponseDataCollected__c;
        amaAgreementDetailsObj.How_Response_Data_Collected_For_Template__c = tpaRequestObj.How_Response_Data_Collected_For_Template__c;
        //amaAgreementDetailsObj.AMA_RepDataCollectedOtherWay__c = tpaRequestObj.AMA_RepDataCollectedOtherWay__c;
        //amaAgreementDetailsObj.AMA_RespDataAction__c = tpaRequestObj.AMA_RespDataAction__c;

        system.debug('amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c: ' + amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c);

        if(amaAgrSubmitted != null && amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c != null) {
            amaAgreementDetailsObj.Vendor_require_Remote_Access_from_NonUS__c = amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c; 
            amaAgreementDetailsObj.Vendor_Employee_Accessed_Data_in_country__c = amaAgrSubmitted.Vendor_Employee_Accessed_Data_in_country__c; 
            amaAgreementDetailsObj.Technology_s_selected_for_remote_access__c = amaAgrSubmitted.Technology_s_selected_for_remote_access__c; 
            amaAgreementDetailsObj.Other_Technology_for_Remote_Access__c = amaAgrSubmitted.Other_Technology_for_Remote_Access__c; 
            amaAgreementDetailsObj.Ex_US_Legal_Entity_Name_Remote_Access__c = amaAgrSubmitted.Ex_US_Legal_Entity_Name_Remote_Access__c;
            amaAgreementDetailsObj.Off_Access_Legal_Entity_Street__c = amaAgrSubmitted.Off_Access_Legal_Entity_Street__c;
            amaAgreementDetailsObj.Off_Access_Legal_Entity_State__c = amaAgrSubmitted.Off_Access_Legal_Entity_State__c;
            amaAgreementDetailsObj.Off_Access_Legal_Entity_Country__c = amaAgrSubmitted.Off_Access_Legal_Entity_Country__c;
            amaAgreementDetailsObj.Off_Access_Legal_Entity_City__c = amaAgrSubmitted.Off_Access_Legal_Entity_City__c;
            amaAgreementDetailsObj.Off_Access_Legal_Entity_Zip__c = amaAgrSubmitted.Off_Access_Legal_Entity_Zip__c;
            amaAgreementDetailsObj.Ex_US_Foreign_Affiliate_of_TPA_Vendor__c = amaAgrSubmitted.Ex_US_Foreign_Affiliate_of_TPA_Vendor__c;
        }
        if(amaAgrSubmitted != null && amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c != null && amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c == 'No') {
            amaAgreementDetailsObj.Vendor_require_Remote_Access_from_NonUS__c = amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c; 
            amaAgreementDetailsObj.Vendor_Employee_Accessed_Data_in_country__c = ''; 
            amaAgreementDetailsObj.Technology_s_selected_for_remote_access__c = '';  
            amaAgreementDetailsObj.Other_Technology_for_Remote_Access__c = ''; 
            amaAgreementDetailsObj.Ex_US_Legal_Entity_Name_Remote_Access__c = ''; 
            amaAgreementDetailsObj.Off_Access_Legal_Entity_Street__c = ''; 
            amaAgreementDetailsObj.Off_Access_Legal_Entity_State__c = ''; 
            amaAgreementDetailsObj.Off_Access_Legal_Entity_Country__c = ''; 
            amaAgreementDetailsObj.Off_Access_Legal_Entity_City__c = ''; 
            amaAgreementDetailsObj.Off_Access_Legal_Entity_Zip__c = ''; 
            amaAgreementDetailsObj.Ex_US_Foreign_Affiliate_of_TPA_Vendor__c = false;
        }

        if(amaAgrSubmitted != null && amaAgrSubmitted.Vendor_req_Storage_Permission_from_NonUS__c != null) {
            amaAgreementDetailsObj.Vendor_req_Storage_Permission_from_NonUS__c = amaAgrSubmitted.Vendor_req_Storage_Permission_from_NonUS__c; 
            amaAgreementDetailsObj.Vendor_Employee_Store_Data_in_country__c = amaAgrSubmitted.Vendor_Employee_Store_Data_in_country__c;
            amaAgreementDetailsObj.Ex_US_Entity_Authorized_Signer_FName__c = amaAgrSubmitted.Ex_US_Entity_Authorized_Signer_FName__c; 
            amaAgreementDetailsObj.Ex_US_Entity_Authorized_Signer_LName__c = amaAgrSubmitted.Ex_US_Entity_Authorized_Signer_LName__c; 
            amaAgreementDetailsObj.Ex_US_Entity_Authorized_Signer_Title__c = amaAgrSubmitted.Ex_US_Entity_Authorized_Signer_Title__c; 
            amaAgreementDetailsObj.Ex_US_Entity_Authorized_Signer_Email__c = amaAgrSubmitted.Ex_US_Entity_Authorized_Signer_Email__c;
            amaAgreementDetailsObj.Ex_US_Legal_Entity_Name_Offshore_Storage__c = amaAgrSubmitted.Ex_US_Legal_Entity_Name_Offshore_Storage__c; 
            amaAgreementDetailsObj.Off_Storage_Legal_Entity_Street__c = amaAgrSubmitted.Off_Storage_Legal_Entity_Street__c;
            amaAgreementDetailsObj.Off_Storage_Legal_Entity_State__c = amaAgrSubmitted.Off_Storage_Legal_Entity_State__c;
            amaAgreementDetailsObj.Off_Storage_Legal_Entity_Country__c = amaAgrSubmitted.Off_Storage_Legal_Entity_Country__c;
            amaAgreementDetailsObj.Off_Storage_Legal_Entity_City__c = amaAgrSubmitted.Off_Storage_Legal_Entity_City__c;
            amaAgreementDetailsObj.Off_Storage_Legal_Entity_Zip__c = amaAgrSubmitted.Off_Storage_Legal_Entity_Zip__c;        
        }
        if(amaAgrSubmitted != null && (amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c == null || amaAgrSubmitted.Vendor_require_Remote_Access_from_NonUS__c == 'No') && 
             (amaAgrSubmitted.Vendor_req_Storage_Permission_from_NonUS__c == null || amaAgrSubmitted.Vendor_req_Storage_Permission_from_NonUS__c == 'No')) {
            amaAgreementDetailsObj.Date_of_AMA_Response_for_Offshore__c = null;   
            amaAgreementDetailsObj.Last_AMA_offshore_reminder_mail_sent__c = null;  
        }

    }

    public static void updateClientCopies(tpaRequestDetails reqObj) {
        if( (  reqObj.requestTypeSubmitted == 'NewRequest' 
             || reqObj.requestTypeSubmitted == 'ClientSubmit' 
             || reqObj.requestTypeSubmitted == 'InDraftRequest'
            ) 
           && reqObj.tpaRequest.CopyAdditionalContactOnTransactions__c == 'Yes'
          ) {
            List<TPA_Contact__c> insertAdditionalContacts = new List<TPA_Contact__c>();
            if(reqObj.tpaAdditionalContactList.size() > 0) {
                for(TPA_Contact__C objTpaContact : reqObj.tpaAdditionalContactList) {
                    objTpaContact.TPA_Request__c = reqObj.tpaRequest.Id;
                    objTpaContact.Type__c = TPA_CONTACTTYPE_ADDITIONAL;
                    insertAdditionalContacts.add(objTpaContact);
                }
            }
            insert insertAdditionalContacts;
        }
    }

    /*
     * Desc: To empty all ama section values on TPA Request record
    */
    public static void resetAmaValuesOnTpaRequest(TPA_Request__c tpaRequestObj) {
        tpaRequestObj.AMA_TypeOfPrescriberLevelData__c = null;
        tpaRequestObj.AMA_Howlong_SP_has_Data_Access__c = null;
        tpaRequestObj.AMA_Services_Provided__c = null;
        tpaRequestObj.FrequencyOfDeliveryToServiceProvider__c = null;
     //   tpaRequestObj.AMA_PPDVariablesCollected__c = null;
      //  tpaRequestObj.AMA_Market_Research_Attributes__c = null;
      //  tpaRequestObj.AMA_Distribution_And_Mailing_Attributes__c = null;
      //  tpaRequestObj.AMA_HowResponseDataCollected__c = null;
       // tpaRequestObj.AMA_RepDataCollectedOtherWay__c = null;
       // tpaRequestObj.AMA_RespDataAction__c = null;
        tpaRequestObj.FrequencyOfDeliveryToSP_Other__c = null;
    }

    public static void saveBulkCSVFile(tpaRequestDetails reqObj) {
        try {
            system.debug('inside savebulkcsv');
            Attachment attach= new Attachment();
            attach.Body= Blob.valueOf(reqObj.bulkCSVFileBody); //TODO: Will review if increase heap size
            attach.Name= reqObj.bulkCSVFileName;
            attach.ContentType = 'text/csv';
            attach.ParentID = reqObj.tpaRequest.id;
            insert attach;
            reqObj.bulkCSVFileBody = null; //Setting Null after user to save heap size
        }
        catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_ContractDtl_CSV_Import:::saveAttachment', ''));
            System.assert(false,e.getMessage());
        }
    }

    public static void vendorSubmissionNotification(tpa_request__c tpaRequest) {
        String subject;
        String emailType;
        String preferredLanguage = tpaRequest.vendor_language__c != null ? tpaRequest.vendor_language__c : (tpaRequest.client_language__c != null ? tpaRequest.client_language__c : 'English');
        
        if(tpaRequest.request_type__c == 'renew' && tpaRequest.lastAction__c == 'Request Submitted By Client') {
            emailType = 'Client Submission Renew';
        } else {
            emailType = 'Email New and Edited Request';
        }

        List<String> toAddresses = new List<String>();
        if(tpaRequest.Vendor_Contact_Email_Client__c != null) {
            toAddresses.add(tpaRequest.Vendor_Contact_Email_Client__c);
        }
        if(tpaRequest.TP_Processor_Email__c != null) {
            toAddresses.add(tpaRequest.TP_Processor_Email__c);
        }
        List<String> ccAddresses = new List<String>();
        if(UTL_TPA.tpaSetting != null && UTL_TPA.tpaSetting.TPA_RequestSubmitted_Email__c != null) {
            ccAddresses = UTL_TPA.tpaSetting.TPA_RequestSubmitted_Email__c.split(',', 0);
        }
        
        Set<string> langSet = new Set<string>();
        String preferredLangField = UTL_TPA_Multilingual.supportedLanguageFieldMap.get(preferredLanguage);
        langSet.add(preferredLangField);

        Map<String, List<TPA_Language_Cross_Walk__c>> langCrossWalkMap = UTL_TPA_Multilingual.getTranslatedValueMap(langSet);
        if(langCrossWalkMap != null) {
            subject = langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~NewReqVendorNotificationSubject')[0].get(preferredLangField)+' '+ tpaRequest.Name;
            if(preferredLanguage != 'English') {
                subject = tpaRequest.Name+' '+langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~NewReqVendorNotificationSubject')[0].get(preferredLangField);
            }
            if(tpaRequest.request_type__c == 'renew' && tpaRequest.lastAction__c == 'Request Submitted By Client') {
                String tempSub = langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~RenewVendorNotification')[0].get(preferredLangField)+' ';
                tempSub = tempSub.replace('Request_Number',tpaRequest.Parent_Request__r.name);
                subject = tempSub;
            }
            else if(tpaRequest.Is_New_Notification_Sent__c) {
                subject = langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~EditReqVendorNotificationSubject')[0].get(preferredLangField)+' '+tpaRequest.Name;
                if(preferredLanguage != 'English') {
                    subject = tpaRequest.Name+': '+langCrossWalkMap.get(preferredLangField+'~TPA_Request__c~Record~EditReqVendorNotificationSubject')[0].get(preferredLangField);
                }
            }
            if(tpaRequest.Client_Address__c != null ) {
                subject = tpaRequest.Client_Address__r.Name + '_' + subject;
            }
        }
        langCrossWalkMap = null; //Setting Null after use to save heap size
        
        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(tpaRequest.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            SRV_TPA_TPARequest.assignedTPProcessorName = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
        system.debug('tpaRequest.id:: ' + tpaRequest.id);
        SRV_TPA_TPARequest.sendTPANotifications(toAddresses, ccAddresses, emailType, preferredLanguage, tpaRequest.id, true, null, subject, TRUE, TRUE, tpaRequest);
        //SRV_TPA_TPARequest.addTPProcessorInitials = false;
    }
    

    

    /*public static UTL_TPA_RestApi insertDeleteGroupMembers(UTL_TPA_RestApi utlPsaRestApiArg) {
        UTL_TPA_RestApi response = new UTL_TPA_RestApi();        
        response.isSuccess = true;
        response.responseMessage = 'Success';
        system.debug('insertDeleteGroupMembers Called');
        return response;
    }*/
    
    /**
     * Name: resetAmaValuesOnAmaAgreement
     * @param:
     * @return:
     * Desc: To empty all ama section data on AMA Agreement Details object
    **/
    public static void resetAmaValuesOnAmaAgreement(AMA_Agreement_Detail__c amaAgreementDetailsObj) {
        amaAgreementDetailsObj.AMA_TypeOfPrescriberLevelData__c = null;
        amaAgreementDetailsObj.AMA_Howlong_SP_has_Data_Access__c = null;
        amaAgreementDetailsObj.AMA_Services_Provided__c = null;
        amaAgreementDetailsObj.FrequencyOfDeliveryToServiceProvider__c = null;
     //   amaAgreementDetailsObj.AMA_PPDVariablesCollected__c = null;
      //  amaAgreementDetailsObj.AMA_Market_Research_Attributes__c = null;
       // amaAgreementDetailsObj.AMA_Distribution_And_Mailing_Attributes__c = null;
       // amaAgreementDetailsObj.AMA_HowResponseDataCollected__c = null;
        amaAgreementDetailsObj.AMA_Dist_ana_Mail_Atrr_For_Template__c = null;
       // amaAgreementDetailsObj.AMA_Market_Research_Attributes_For_Templ__c = null;
        amaAgreementDetailsObj.How_Response_Data_Collected_For_Template__c = null;
       // amaAgreementDetailsObj.AMA_RepDataCollectedOtherWay__c = null;
       // amaAgreementDetailsObj.AMA_RespDataAction__c = null;
        amaAgreementDetailsObj.FrequencyOfDeliveryToSP_Other__c = null;
    }

    public static void CreateOrUpdateAgreementAdditionalFieldDataRecord(tpaRequestDetails reqObj, Boolean IsRequestRenewed) {
        TPA_Agreement_Additional_Field__c agreementAdditionalFieldData = new TPA_Agreement_Additional_Field__c();
        if(reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r != null && reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r.size() > 0) {
            agreementAdditionalFieldData.id = reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r[0].id;
        } else {
            agreementAdditionalFieldData.Related_TPA_Request__c = reqObj.tpaRequest.id;
        }
        System.debug('agreementAdditionalFieldData.id:'+agreementAdditionalFieldData.id);

        if(isAwaitingClientConfirmationMailReq){
            agreementAdditionalFieldData.Client_Contact_First_Name__c = '';
            agreementAdditionalFieldData.Offering_Notification_Ack_By_Email__c = '';
            agreementAdditionalFieldData.Offering_Notification_Acknowledged__c = null;
            agreementAdditionalFieldData.QuintilesIMS_Account_Team_First_Name__c = '';
        }
        agreementAdditionalFieldData.Client_Contact_Last_Name__c = '';
        agreementAdditionalFieldData.QuintilesIMS_Account_Team_Last_Name__c = '';
        agreementAdditionalFieldData.Vendor_Specific_Notification_Response__c = '';
        agreementAdditionalFieldData.Pending_Cancellation_Date__c = null;
        agreementAdditionalFieldData.Direct_To_Client_LAAD_Response_Value__c = '';
        agreementAdditionalFieldData.LAAD_Question_and_Compliance_Ack_Time__c = null ;

        try {
            if(agreementAdditionalFieldData != null) {
                IsUpdateRenewalOfferinfDetail = IsRequestRenewed;
                UTL_TPA.vendorSubmissionAddObjUpdate = true;
                upsert agreementAdditionalFieldData; 
                UTL_TPA.vendorSubmissionAddObjUpdate = false;
            }
        } catch(Exception ex) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::CreateOrUpdateAgreementAdditionalFieldDataRecord', (reqObj != null && reqObj.tpaRequest != null) ? reqObj.tpaRequest.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('**Exception while upserting Agreement Additional Field Data**'+ex.getMessage());
        }
    }

    @future(callout=true)
    public static void tpProcessorSubmission(string requestDetail, string languageArg, string argGUID) {
        isTPProcessor = currentLoggedInUser.Profile.Name.indexOf('TPA Processor Profile') != -1 ? true : false;
        isUSTPProcessor = currentLoggedInUser.Profile.Name.indexOf('US TP Processor Profile') != -1 ? true : false;
        if(UTL_Validate.isValidGuid(argGUID)) {
            UTL_LogFactory.GUID = argGUID; 
        }
        set<string> secCountryCodeSet;
        CNT_TPA_RequestSubmissionForm.tpaRequestDetails reqObj = (CNT_TPA_RequestSubmissionForm.tpaRequestDetails)JSON.deserialize(requestDetail, CNT_TPA_RequestSubmissionForm.tpaRequestDetails.class);
        requestDetail=null;//set this null after use to save heap size
        language = languageArg;
        if(reqObj.tpaRequest.ClientContact__c != null) {
            String profileName = currentLoggedInUser.Profile.Name;
            List<Contact> clientContact = [Select Id, Name, Email, Client_Contact_Territory__c from Contact where Id =: reqObj.tpaRequest.ClientContact__c limit 1];
            if(clientContact != null && clientContact.size() > 0 && !isTPProcessor && !isUSTPProcessor ) {
                clientContact[0].Client_Contact_Territory__c = reqObj.tpaRequest.Client_Contact_Territory__c;//will review, only update when clientContact[0].Client_Contact_Territory__c is null
                update clientContact[0];
            }
            //updateAdditionalVendorContacts(reqObj);//will review, check if this is applicable for tp processor, check inside is only fr vendor
        }
        UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Backup Details in tpProcessor Submission ', 'TPA', 'Custom', 'INFO', 'MapPurpDesc(' + (reqObj.MapPurpDesc != null ? reqObj.MapPurpDesc.Size() : null) + ') MapPurpDescOther(' +  (reqObj.MapPurpDescOther != null ? reqObj.MapPurpDescOther.Size() : null) + ') PurposeMap(' +  (reqObj.PurposeMap != null ? reqObj.PurposeMap.Size() : null) + ') PurposeMapOther(' +  (reqObj.PurposeMapOther != null ? reqObj.PurposeMapOther.Size() : null) + ') SelectedDescMap(' +  (reqObj.SelectedDescMap != null ? reqObj.SelectedDescMap.Size() : null) + ') mapPurposeidWithDataAssetMap(' +  (reqObj.mapPurposeidWithDataAssetMap != null ? reqObj.mapPurposeidWithDataAssetMap.Size() : null) + ') mapSecondayDataAssetToInsert(' +  (reqObj.mapSecondayDataAssetToInsert != null ? reqObj.mapSecondayDataAssetToInsert.Size() : null) + ') categorypurposesList(' +  (reqObj.categorypurposesList != null ? reqObj.categorypurposesList.Size() : null) + ') secondarypurpose(' +  (reqObj.secondarypurpose != null ? reqObj.secondarypurpose.Size() : null) + ')', reqObj.tpaRequest.Id));
        //        UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        System.debug('Client Part Start');
        getLimitsMessage();
        if(reqObj.requestTypeSubmitted == 'ClientSubmit' || reqObj.requestTypeSubmitted == 'InDraftRequest') {
            reqObj.tpaRequest.Is_New_Notification_Sent__c = true;
            reqObj.tpaRequest.Client_Language__c = supportedLanguageMap.get(language).split('~')[0];
            reqObj.tpaRequest.Is_Vendor_Veeva_for_all_Use__c = false;
            reqObj.tpaRequest.Is_Vendor_Id_Invalid__c = false;
            reqObj.tpaRequest.Is_Vendor_Name_Contains_Veeva__c = false;
            reqObj.tpaRequest.Is_Vendor_Name_Contains_MedPro__c = false;
            //reqObj.tpaRequest.Is_Vendor_Name_Contains_DeepIntent__c = false;
            reqObj.tpaRequest.Is_Vendor_Related_to_Source_Symphony_Acc__c = false;
            reqObj.tpaRequest.Is_Veeva_Use_CRM_Off_OneKey__c = false;
            //reqObj.tpaRequest.is_Veeva_Use_CRM__c = false;
            reqObj.tpaRequest.Is_Veeva_Use_CRM_SubNational_Off__c = false;
            reqObj.tpaRequest.Is_South_Africa_Sub_Off__c = false;
            reqObj.tpaRequest.is_Specific_Vendors_LAAD_Off__c = false;
            reqObj.tpaRequest.is_Specific_Vendors_APLD_Off__c = false;
            reqObj.tpaRequest.is_Specific_Vendors_Long_Prescr_Data__c = false;
            reqObj.tpaRequest.is_Specific_Vendors_Medical_Claims_Data__c = false;
            reqObj.tpaRequest.Is_Vendor_Name_Contains_Edith__c = false;
            reqObj.tpaRequest.Is_Vendor_Name_Contains_DLIMI__c  = false;
            reqObj.tpaRequest.Is_Vendor_Name_Contains_MedPro__c   = false;
            reqObj.tpaRequest.is_20_or_more_Offering_Present__c   = false;
            reqObj.tpaRequest.Is_VSN_Acknowlege_By_Client__c = false;
            reqObj.tpaRequest.is_VSN_Selected__c = false;
            reqObj.tpaRequest.is_Addendum_Attachment_Required__c = false;
            reqObj.tpaRequest.is_LAAD_Response_Acknowledged__c = false;
            reqObj.tpaRequest.is_LAAD_Response_Required__c = false;
            reqObj.tpaRequest.Pending_Acknowledgements__c = '';

            for(IMS_Legal_Entity__c oldLegalEntity : reqObj.tpaRequest.IMS_Legal_Entities__r) {
                oldLegalEntity.is_GE_Centricity_EMR__c = false;
                oldLegalEntity.is_Managed_Workbook__c = false;
                oldLegalEntity.isDDDOffering__c = false;
                oldLegalEntity.is_Xponent__c = false;
                oldLegalEntity.is_Midas__c = false;
                oldLegalEntity.Is_Ambulatory_EMR__c = false;
                oldLegalEntity.Is_Oncology_EMR__c = false;
                oldLegalEntity.Is_Health_Plan_Claims__c = false;
                oldLegalEntity.is_South_Africa_Consumer_Health__c = false;
                oldLegalEntity.is_LAAD_Offering__c = false;
                oldLegalEntity.is_Patient_Companion_File__c = false;
                oldLegalEntity.is_Payer_Companion_File__c = false;
                oldLegalEntity.is_Provider_Companion_File__c = false;
                oldLegalEntity.is_Promotrak__c = false;
                oldLegalEntity.Is_Glbl_PromoTrack_Selected__c = false;
                oldLegalEntity.is_Canada__c = false;
                oldLegalEntity.containUS__c = false;
                oldLegalEntity.is_Xponent_or_OneKey__c = false;
                oldLegalEntity.Is_MedPages_Data__c = false;
                oldLegalEntity.is_AIM_XR__c = false;
                oldLegalEntity.is_Analytics_Link__c = false;
            }
            if(reqObj.requestTypeSubmitted == 'InDraftRequest') {
                reqObj.tpaRequest.Is_New_Notification_Sent__c = false;
                reqObj.tpaRequest.Request_Status__c = 'Client Draft';
                reqObj.tpaRequest.TPA_Request_Temporary_Status__c= 'Client Draft';
            }
            else if(!reqObj.isPublicPrivateChangeOnly) {
                reqObj.tpaRequest.Request_Status__c = 'Awaiting Vendor Submission';
                reqObj.tpaRequest.TPA_Request_Temporary_Status__c= 'Awaiting Vendor Submission';
            }
            /*
            TPA_Request_Backup__c TPARequestBackupDetails = getRequestBackup(reqObj, 'Client');
            TPARequestBackupDetails.Submission_Type__c = 'Client Submission';
            TPARequestBackupDetails.Related_TPA_Request__c = reqObj.tpaRequest.id;
            insert TPARequestBackupDetails;
            TPARequestBackupDetails = null;//Setting Null After use to save heap size
            */

            reqObj.tpaRequest.agreement_effective_date__c = null;
         //   reqObj.tparequest.AMA_Services_Provided__c = savePurposes(reqObj);
           savePurposes(reqObj);
            
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Uses and Offerings Updated', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id)); // Debug log change
           // if(isTPProcessor || isUSTPProcessor) {
                List<TPA_contact__c> existedTpaContacts = [SELECT Id FROM TPA_Contact__c WHERE TPA_Request__c =: reqObj.tpaRequest.Id and (Type__c = 'Additional Client Contact' OR Type__c = 'Additional Contact' OR Type__c = 'SubContractor Contact' OR Type__c = 'Additional Vendor Contact' )];                    
                delete existedTpaContacts;
           // }
            // else {
            //     List<TPA_contact__c> existedTpaContacts = SLT_TPAContact.instance.getTPAContactByCodition('TPA_Request__c = \'' + reqObj.tpaRequest.Id + '\' and (Type__c = \'' + TPA_CONTACTTYPE_ADDITIONAL + '\' OR Type__c = \'' + TPA_ADDITIONAL_CLIENT_CONTACT + '\' )');                    delete existedTpaContacts;
            // }
            Address__c currentAddress =  UTL_TPA.getAddress(reqObj.clientAddress);

            reqObj.tpaRequest.Client_Contact_Territory__c = currentAddress.Region_Territory__c;
            reqObj.tpaRequest.Secondary_Client_Contact_Territory__c = currentAddress.Region_Territory__c;

            

            
                if(reqObj.authorizedSignerResponse == 'Yes') {
                    reqObj.tpaRequest.Authorized_Signer_First_Name__c = reqObj.tpaRequest.Vendor_First_Name__c;
                    reqObj.tpaRequest.Authorized_Signer_Last_Name__c = reqObj.tpaRequest.Vendor_Contact_Last_Name__c;
                    reqObj.tpaRequest.Authorized_Signer_Title__c = reqObj.tpaRequest.Vendor_Contact_Title__c;
                    reqObj.tpaRequest.Authorized_Signer_Email__c = reqObj.tpaRequest.Vendor_e_mail__c;
                }

                List<TPA_Contact__c> insertAdditionalVendors = new List<TPA_Contact__c>();
                if(reqObj.tpaSubContractors.size() > 0) {
                    for(TPA_Contact__C objTpaContact : reqObj.tpaSubContractors) {
                        objTpaContact.TPA_Request__c = reqObj.tpaRequest.Id;
                        objTpaContact.Type__c = TPA_CONTACTTYPE_SUBCONTRACTOR;
                        insertAdditionalVendors.add(objTpaContact);
                    }
                }
                insert insertAdditionalVendors;
                reqObj.tpaRequest.Request_Status__c = Label.TPA_In_Review_By_IQVIA_Status;
                reqObj.tpaRequest.TPA_Request_Temporary_Status__c= Label.TPA_In_Review_By_IQVIA_Status;
            

                try {
                    if(reqObj.tpaRequest != null && reqObj.tpaRequest.Secondary_Client_Contact_Territory__c != null) {
                        System.debug('Secondary Country is::'+ reqObj.tpaRequest.Secondary_Client_Contact_Territory__c);
                        secCountryCodeSet = createStateCountryNameSet(reqObj.tpaRequest.Secondary_Client_Contact_Territory__c, 'C'); // Added by C.P under CR-12673
                        if(secCountryCodeSet != null && secCountryCodeSet.size() > 0) {
                            List<TPA_Region_Country__c> lstRegionCountry = new List<TPA_Region_Country__c>();
                            lstRegionCountry = [select TP_Processor__c,
                                                TP_Processor__r.region__c,
                                                TP_Processor__r.TP_Processor_Name__c,
                                                TP_Processor__r.TPA_Processor_Contact__c,
                                                TP_Processor__r.TPA_Processor_Contact__r.accountid,
                                                TP_Processor__r.TP_Processor_Email__c, 
                                                TP_Processor__r.Assigned_TP_Processors__c
                                            from TPA_Region_Country__c
                                            where Country__c in: secCountryCodeSet
                                            limit 1 ];
                        if(lstRegionCountry.size() != 0 ) {
                            System.debug('###TP Processor iD is:: ' + lstRegionCountry[0].TP_Processor__c);
                            if(lstRegionCountry[0].TP_Processor__c != null) {
                                //reqObj.tpaRequest.TPA_Processor_Account_Address__c = UTL_TPA.getAddressId(lstRegionCountry[0].TP_Processor__r.TPA_Processor_Contact__r.id);
                                reqObj.tpaRequest.TPA_Processor_Contact__c = lstRegionCountry[0].TP_Processor__r.TPA_Processor_Contact__c;
                                reqObj.tpaRequest.TP_Processor_Email__c = lstRegionCountry[0].TP_Processor__r.TP_Processor_Email__c;
                                reqObj.tpaRequest.TP_Processor_Name__c = lstRegionCountry[0].TP_Processor__r.TP_Processor_Name__c;
                                List<TPA_Assigned_TP_Processor__c> assignedTPProcessors = [select Id, Name from TPA_Assigned_TP_Processor__c where TP_Processor__c =: lstRegionCountry[0].TP_Processor__c];
                                if(assignedTPProcessors.size() != 0 && assignedTPProcessors.size() == 1){
                                    TPA_Assigned_TP_Processor__c assignedtpprocessor = assignedTPProcessors[0];
                                    reqObj.tpaRequest.TPA_Assigned_TP_Processor__c = assignedtpprocessor.Id;
                                }
                            }
                            else {
                                reqObj.tpaRequest.TPA_Processor_Account_Address__c = null;
                                reqObj.tpaRequest.TPA_Processor_Contact__c = null;
                            }
                        }
                    }
                }
            }
            catch(Exception ex) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest:::Client Edit:::TPA Processor Update Exception', (reqObj != null && reqObj.tpaRequest != null) ? reqObj.tpaRequest.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                System.debug('**Exception while Client Edit:::TPA Processor Update Exception**'+ex.getMessage());
            }

           
            reqObj.tpaRequest.LastAction__c = 'Request Edited By TP Processor';
           
            try{
                UTL_TPA.ClientSubmissionUpdate = true; //TODO: Review Pending from my side
                update reqObj.tpaRequest;
                UTL_TPA.ClientSubmissionUpdate = false;
            }
            catch(Exception Ex){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::tpProcessorSubmission:::tpaReqUpdate', reqObj.tpaRequest.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Request Updated before updateClientCopies() method', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id)); // Debug log change
            updateClientCopies(reqObj);
            if(reqObj.requestTypeSubmitted != 'InDraftRequest') {
                SRV_TPA_TPARequest.updateAgreementFieldsForClient(reqObj.tpaRequest);
                SRV_TPA_TPARequest.updateActivityHistory(reqObj.tpaRequest.Id, 'TPA Request Edited', false);
                SRV_TPA_TPARequest.updateActivityHistory(reqObj.tpaRequest.Id, 'Email Notification Send to Vendor', true);
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'updateAgreementFieldsForClient called', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::saveRequest', reqObj.tpaRequest.Id));
                UTL_TPA_Multilingual.updateChildRecordsTranslation(reqObj.tpaRequest.Id, null);//Added by Govind under ER-1940
            }


            if(reqObj.requestTypeSubmitted != 'InDraftRequest' && reqObj.useOffBackupIds != null && reqObj.useOffBackupIds != '') {
                List<TPA_Use_Offerings_UI_Backup__c> useOffListToUpdate = new List<TPA_Use_Offerings_UI_Backup__c>();
                for(string strUseOffId: reqObj.useOffBackupIds.split(';')) {
                    TPA_Use_Offerings_UI_Backup__c useOffObj = new TPA_Use_Offerings_UI_Backup__c();
                    useOffObj.Id = strUseOffId;
                    useOffObj.TPA_Request__c = reqObj.tpaRequest.Id;
                    useOffListToUpdate.add(useOffObj);
                }
                if(useOffListToUpdate.size() > 0) {
                    update useOffListToUpdate;
                }
            }

           
            try {
                TPA_Agreement_Additional_Field__c agreementAdditionalFieldData = new TPA_Agreement_Additional_Field__c();
                if(reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r != null && reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r.size() > 0) {
                    agreementAdditionalFieldData.id = reqObj.tpaRequest.TPA_Agreement_Additional_Fields__r[0].id;
                } 
            
            
                if(agreementAdditionalFieldData != null) {
                    system.debug('Client submission : reqObj.tpaRequest.Request_Type__c' + reqObj.tpaRequest.Request_Type__c);
                    if(reqObj.tpaRequest.Request_Type__c == 'renew') {
                        IsUpdateRenewalOfferinfDetail = true;
                    }
                    upsert agreementAdditionalFieldData;
                }
            } catch(Exception ex) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::saveRequest:::agreementAdditionalFieldData upsert Exception', reqObj.tpaRequest.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                System.debug('**Exception while updating Agreement Additional Field Data**'+ex.getMessage());
            }
        }

        System.debug('Client Part End');
        getLimitsMessage();
        
        if(reqObj.requestTypeSubmitted != 'InDraftRequest') {
            Boolean isClientRepresentativeUpdate = false;
            if(reqObj.tpaRequest?.is_Client_Representative__c != null && reqObj.tpaRequest.is_Client_Representative__c == true){
                isClientRepresentativeUpdate = true;
            }
            reqObj.tpaRequest = SRV_TPA_TPARequest.getRequestInfo( reqObj.tpaRequest.Id );
            if(isClientRepresentativeUpdate && reqObj.tpaRequest?.clientContact__r?.Name != null && reqObj.tpaRequest.clientContact__r?.Email != null ){
                reqObj.tpaRequest.Client_TPA_Representative_Email__c =  reqObj.tpaRequest.ClientContact__r.Email;
                reqObj.tpaRequest.Client_TPA_Representative_Name__c = reqObj.tpaRequest.clientContact__r.Name;
                reqObj.tpaRequest.Client_TPA_Representative_Title__c = '';
            }
            reqObj.tpaRequest.isbatchProcessing__c = false; 
            reqObj.tpaRequest.TLLA_Batch_Call_Sent_On__c = null;
            String competitiveServicePresent = (reqObj.tpaRequest.Competitive_Service_to_IMS_Offerings__c == 'Yes' || reqObj.tpaRequest.Competitive_Service_to_IMS_Offerings_2__c == 'Yes' || reqObj.tpaRequest.Competitive_Service_to_IMS_Offerings_3__c == 'Yes') ? 'Yes' : 'No';
            CNT_TPA_RequestSubmissionForm.updateAccount(reqObj.tpaRequest.Service_Provider_Address__c, competitiveServicePresent);
            UTL_TPA_Multilingual.saveUseOfferingTranslatedNames(reqObj.tpaRequest.Id, supportedLanguageMap.get(language).split('~')[1], multilanguageUtilityMap);

            UTL_TPA.getGlobalBrandingVendorId(reqObj.tpaRequest);
            updateAdditionalVendorContacts(reqObj);

            isAwaitingClientConfirmationMailReq = SRV_TPA_TPARequest.isDynamicNotificationRequiredForVendor(reqObj.tpaRequest); 
            
            reqObj.tpaRequest.is_Addendum_Attachment_Required__c = false; 
            reqObj.tpaRequest.is_Addendum_Attachment_Required__c = CNT_TPA_AddendumNotification.AddendumAdditionalTermsRequiredOrNot(reqObj.tpaRequest);
            
            //Set Null After use to save heap size start
            CNT_TPA_AddendumNotification.tpaRequest = null;
            CNT_TPA_AddendumNotification.mapIdWithWrapperClassList = null;
            CNT_TPA_AddendumNotification.mapOfIdWithTextEditorObj = null;
            CNT_TPA_AddendumNotification.mapOfIdWithlegalEntityObj = null;
            CNT_TPA_AddendumNotification.mapIdWithObjofwrapperClassOfLegalEntity = null;            
            SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap = null;
            SRV_TPA_TPARequest.dynamicOffNotificationMappingMap = null;
            SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap = null;
            SRV_TPA_TPARequest.offNotMappingLst = null;
            //SRV_TPA_TPARequest.MapCountrywithOfferingId = null;
            SRV_TPA_TPARequest.tpaOfferingNotificationAcctMappingMap = null;
            //Set Null After use to save heap size end
            
            reqObj.tpaRequest.Stop_TLLA_Generation_Notice_Sent_Date__c = null;
            CreateOrUpdateAgreementAdditionalFieldDataRecord(reqObj, true);
            if(SRV_TPA_TPARequest.tpaRequest != null){
                reqObj.tpaRequest.Is_Partially_Renewed__c = SRV_TPA_TPARequest.tpaRequest.Is_Partially_Renewed__c;
            }
            if(reqObj.tpaRequest.AMA_USPrescriberData__c == 'Yes' ) {
                amaAgreementDetails = getAmaAgreement(reqObj.tpaRequest, reqObj.amaAgrSubmitted, 'Processor');
                if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
                    amaAgreementDetails.id = reqObj.tpaRequest.AMA_Agreement_Details__r[0].id;
                } else {
                    amaAgreementDetails.TPA_Request__c = reqObj.tpaRequest.id;
                }
            } else {
                if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
                    delete reqObj.tpaRequest.AMA_Agreement_Details__r[0];
                }
            }
            try {
                if(amaAgreementDetails != null) {
                    upsert amaAgreementDetails;
                }
            } catch(Exception ex) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::tpProcessorSubmission', (reqObj != null && reqObj.tpaRequest != null) ? reqObj.tpaRequest.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                System.debug('**Exception while upserting AMA agreement**'+ex.getMessage());
            }
            if(reqObj.tpaRequest.AMA_USPrescriberData__c == 'Yes' && reqObj.tpaRequest.Service_Provider_Address__c != null) { 
                reqObj.tpaRequest.Type_of_AMA_Agreement__c = null;
                reqObj.tpaRequest.AMA_DBL__c = null;
            }
            reqObj.tpaRequest.Vendor_Language__c = supportedLanguageMap.get(language).split('~')[0];
            //update reqObj.tpaRequest;

           


            TPA_Request__c parentRequest;
            if(reqObj != null && reqObj.tpaRequest.Parent_Request__c != null){
                parentRequest = new TPA_Request__c();
                parentRequest.Id = reqObj.tpaRequest.Parent_Request__c;
                parentRequest.Renewed_Type__c = reqObj.tpaRequest.Parent_Request__r.Renewed_Type__c;
            }

           
            if(parentRequest != null && reqObj.isRenewedReqUseandOfferingChanged != null && reqObj.isRenewedReqUseandOfferingChanged != '' && reqObj.isRenewedReqUseandOfferingChanged != parentRequest.Renewed_Type__c){
                if(reqObj.isRenewedReqUseandOfferingChanged == 'Modified Renewal'){
                    parentRequest.Renewed_Type__c = 'Modified Renewal';
                }
                UTL_TPA.modifyRequestForcefully = true;
                update parentRequest; //TODO: Will review
                UTL_TPA.modifyRequestForcefully = false;
            }

            

            try{
                UTL_TPA.vendorSubmissionFirstUpdate = true;
                reqObj.tpaRequest.Vendor_App_Submitted__c = Datetime.now();
                update reqObj.tpaRequest;//TODO: will review
                UTL_TPA.vendorSubmissionFirstUpdate = false;
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Request Updated2', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::tpProcessorSubmission', reqObj.tpaRequest.Id));
            }
            catch(Exception ex){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::tpProcessorSubmission', reqObj.tpaRequest.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
            
        }

        System.debug('Vendor Part Half End');
        getLimitsMessage();
        

        //update reqObj.tpaRequest;//??
        //UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Request Updated in tpProcessorSubmission', 'TPA', 'Custom', 'INFO', ((isTPProcessor || isUSTPProcessor)?'By TP Processor':'By Client')+':::CNT_TPA_RequestSubmissionForm:::tpProcessorSubmission', reqObj.tpaRequest.Id));
        //todo TPAQueryHelper.setLogObject(reqObj.tpaRequest.Id, 'Request Updated2',  (isTPProcessor || isUSTPProcessor)?'By TP Processor':'By Client',reqObj.tpaRequest.Id); //Added by C.P.Pandey under CR-7361 // Modified By Ajinkya Pande under ER-3593
        //todo TPAQueryHelper.logRef().generateLog();

        if(reqObj.requestTypeSubmitted != 'InDraftRequest') {
            SRV_TPA_TPARequest.tpaRequest = reqObj.tpaRequest;//??
            SRV_TPA_TPARequest.isSubContractAdded  = (reqObj.tpaSubContractors.size() > 0);
            SRV_TPA_TPARequest.authorizedSignerResponse = reqObj.authorizedSignerResponse;
            SRV_TPA_TPARequest.type = reqObj.tpaRequest.Request_Type__c;
            SRV_TPA_TPARequest.requestNumber = reqObj.tpaRequest.Parent_Request__r.Name;
            SRV_TPA_TPARequest.LastAction = reqObj.tpaRequest.LastAction__c;

            if(reqObj.tpaRequest.is_Bulk_TPA_Request__c) {

                QBL_TPA_getManualReviewReasons getManualReviewReasonsObj = new QBL_TPA_getManualReviewReasons();
                getManualReviewReasonsObj.request = reqObj.tpaRequest;
                getManualReviewReasonsObj.langFieldName = supportedLanguageMap.get(language).split('~')[1];
                getManualReviewReasonsObj.multilanguageUtilityMap = multilanguageUtilityMap;
                getManualReviewReasonsObj.LastAction = reqObj.tpaRequest.LastAction__c;
                getManualReviewReasonsObj.isSubContractAdded = (reqObj.tpaSubContractors.size() > 0);
                getManualReviewReasonsObj.authorizedSignerResponse = reqObj.authorizedSignerResponse;
                getManualReviewReasonsObj.type = reqObj.tpaRequest.Request_Type__c;
                getManualReviewReasonsObj.requestNumber = reqObj.tpaRequest.Parent_Request__r.Name;
                getManualReviewReasonsObj.isAwaitingClientConfirmationMailReq = isAwaitingClientConfirmationMailReq;
                getManualReviewReasonsObj.dynamicOfferingsNotificationListForVendor = SRV_TPA_TPARequest.dynamicOfferingsNotificationListForVendor;
                getManualReviewReasonsObj.isDirectToClientExeMode = SRV_TPA_TPARequest.isDirectToClientExeMode;
                getManualReviewReasonsObj.isQuintilesIMSSalesExeMode = SRV_TPA_TPARequest.isQuintilesIMSSalesExeMode;
                getManualReviewReasonsObj.isVendorChecklistChanges = SRV_TPA_TPARequest.isVendorChecklistChanges;
                getManualReviewReasonsObj.isdynamicOffNoticationReqOrNot = true;
                getManualReviewReasonsObj.runType = 'TPProcesscorSubmission';
                if(SRV_TPA_TPARequest.commercialReasonMap != null && SRV_TPA_TPARequest.commercialReasonMap.size() > 0) {
                    getManualReviewReasonsObj.commercialReasonListSecond = SRV_TPA_TPARequest.commercialReasonMap.values();
                }

                if(!Test.isRunningTest()){
                    System.enqueueJob(getManualReviewReasonsObj);
                }
            }
            else{
        
                reqObj.tpaRequest = SRV_TPA_TPARequest.getManualReviewReasons(reqObj.tpaRequest);// will make it queueable
        
                if(reqObj.tpaRequest.AMA_USPrescriberData__c == 'Yes' && reqObj.tpaRequest.Service_Provider_Address__c != null) {
                    //reqObj.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(reqObj.tpaRequest.Id); // will review, check if we need this query, check if we updated tpa request before this
                    String tpaRequestJSON = JSON.serialize(reqObj.tpaRequest);
                    reqObj.tpaRequest = SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(tpaRequestJSON);//will review
                }

                SRV_TPA_TPARequest.tpaRequest = reqObj.tpaRequest;
                
                SRV_TPA_TPARequest.updateAgreementFieldsForVendor(true);//will review, why we are sending always true here
        
                UTL_TPA_Multilingual.saveUseOfferingTranslatedNames(reqObj.tpaRequest.Id, supportedLanguageMap.get(language).split('~')[1], multilanguageUtilityMap);//will review, put logs on update inside, last two parameters are static no need to send as params, will do this work with updateChildRecordsTranslation
                UTL_TPA_Multilingual.updateChildRecordsTranslation(reqObj.tpaRequest.id ,null); //will review
        
            }
            
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, UTL_TPA.savePoints.get('4E'), 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::tpProcessorSubmission', reqObj.tpaRequest.Id));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
        System.debug('Vendor Part End');
        getLimitsMessage();
        
    }

    public static void updateAdditionalVendorContacts(tpaRequestDetails reqObj) {
        if(reqObj.tpaRequest.Copy_Additional_Vendor_Contacts__c == 'Yes') {
            List<TPA_Contact__c> insertAdditionalVendorContacts = new List<TPA_Contact__c>();
            if(reqObj.tpaAdditionalVendorContactList.size() > 0) {
                for(TPA_Contact__C objTpaContact : reqObj.tpaAdditionalVendorContactList) {
                    objTpaContact.TPA_Request__c = reqObj.tpaRequest.Id;
                    objTpaContact.Type__c = TPA_ADDITIONAL_VENDOR_CONTACT;
                    insertAdditionalVendorContacts.add(objTpaContact);
                }
            }
            insert insertAdditionalVendorContacts;
        }
    }

    public static Boolean updateAccount(String accountId, String competitiveServicePresent) {
        if(accountId == null || accountId == '') {
            return false;
        }
        List<TPA_Master_Extension_Information__c> lstTPAMasExt = [select id, Commercial_Reason__c, TPA_Accounts_Address__c from TPA_Master_Extension_Information__c where TPA_Accounts_Address__c =: accountId LIMIT 1];
        TPA_Master_Extension_Information__c objTPAMasExt;
        if(lstTPAMasExt != null && lstTPAMasExt.size() > 0) {
            objTPAMasExt = lstTPAMasExt[0];
        }
        Boolean isRecordAlreadyExisted = true;
        if(objTPAMasExt == null) {
            objTPAMasExt = new TPA_Master_Extension_Information__c(Commercial_Reason__c = false);
            isRecordAlreadyExisted = false;
        }
        if(competitiveServicePresent == 'Yes') {
            if(objTPAMasExt != null && objTPAMasExt.Commercial_Reason__c == false) {
                objTPAMasExt.Commercial_Reason__c = true;
                objTPAMasExt.TPA_Accounts_Address__c = accountId;
                try {
                    upsert objTPAMasExt;
                } 
                catch(Exception e) {
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::updateAccount', ''));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                    System.debug('Following Exception Occue In IF---------> ' + e);
                }
            }
            SRV_TPA_TPARequest.isVendorChecklistChanges = true;
            return true;
        }
        else if(objTPAMasExt != null && (isRecordAlreadyExisted == false || objTPAMasExt.Commercial_Reason__c)) {
            objTPAMasExt.Commercial_Reason__c = false;
            objTPAMasExt.TPA_Accounts_Address__c = accountId;
            try {
                upsert objTPAMasExt;
            } 
            catch(Exception e) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::updateAccount', ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                System.debug('Following Exception Occue In ELSE---------> ' + e);
            }
            return true;
        }
        return false;
    }    

    @future(callout=true)
    public static void vendorSubmission(string requestDetail, string languageArg, string argGuid) {
        getLimitsMessage();
        if(UTL_Validate.isValidGuid(argGUID)) {
            UTL_LogFactory.GUID = argGUID; 
        }
        language = languageArg;

        CNT_TPA_RequestSubmissionForm.tpaRequestDetails reqObj = (CNT_TPA_RequestSubmissionForm.tpaRequestDetails)JSON.deserialize(requestDetail, CNT_TPA_RequestSubmissionForm.tpaRequestDetails.class);
        requestDetail = null; //Set Null After use to save heap size
        getLimitsMessage();
        
        try {
            reqObj.tpaRequest = SRV_TPA_TPARequest.getRequestInfo( reqObj.tpaRequest.Id ); // will review, create a new tpa request query with required fields only
            getLimitsMessage();
            reqObj.tpaRequest.isbatchProcessing__c = false; 
            reqObj.tpaRequest.TLLA_Batch_Call_Sent_On__c = null;

            /*
            TPA_Request_Backup__c TPARequestBackupDetails = getRequestBackup(reqObj, 'Vendor');
            TPARequestBackupDetails.Related_TPA_Request__c = reqObj.tpaRequest.id;
            TPARequestBackupDetails.Submission_Type__c = 'Vendor Submission';
            insert TPARequestBackupDetails;
            TPARequestBackupDetails = null;//Setting Null After use to save heap size
            */

            CreateOrUpdateAgreementAdditionalFieldDataRecord(reqObj, false);

            reqObj.tpaRequest.is_Addendum_Attachment_Required__c = false; 
            UTL_TPA.getGlobalBrandingVendorId(reqObj.tpaRequest); //will remove if not necessary

            List<TPA_Purpose__c> TPAPurposetList = SRV_TPA_TPARequest.getPurposesList(reqObj.tpaRequest.Id);
            getLimitsMessage();
            //SRV_TPA_TPARequest.allPurposeIds = null; used in sendApprovalMail
            for(TPA_Purpose__c purposeObj :TPAPurposetList){
                SRV_TPA_TPARequest.allPurposeIds.add(purposeObj.Purpose__r.Id);
                SRV_TPA_TPARequest.transactionalPurposeIds.add(purposeObj.Id);
            }            
            //SRV_TPA_TPARequest.allPurposeIds = SRV_TPA_TPARequest.masterPurposeIds;//will check and review this
            TPAPurposetList = null; //Set Null After use to save heap size
            getLimitsMessage();            
            
            reqObj.tpaRequest.is_Addendum_Attachment_Required__c = CNT_TPA_AddendumNotification.AddendumAdditionalTermsRequiredOrNot(reqObj.tpaRequest);//will review
            system.debug('reqObj.tpaRequest.is_Addendum_Attachment_Required__c:' + reqObj.tpaRequest.is_Addendum_Attachment_Required__c);
            isAwaitingClientConfirmationMailReq = SRV_TPA_TPARequest.isDynamicNotificationRequiredForVendor(reqObj.tpaRequest); //will review, have changes inside
            system.debug('isAwaitingClientConfirmationMailReq:' + isAwaitingClientConfirmationMailReq);
            getLimitsMessage();
            
            //Set Null After use to save heap size start
            CNT_TPA_AddendumNotification.tpaRequest = null;
            CNT_TPA_AddendumNotification.mapIdWithWrapperClassList = null;
            CNT_TPA_AddendumNotification.mapOfIdWithTextEditorObj = null;
            CNT_TPA_AddendumNotification.mapOfIdWithlegalEntityObj = null;
            CNT_TPA_AddendumNotification.mapIdWithObjofwrapperClassOfLegalEntity = null;            
            SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap = null;
            SRV_TPA_TPARequest.dynamicOffNotificationMappingMap = null;
            SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap = null;
            SRV_TPA_TPARequest.offNotMappingLst = null;
            //SRV_TPA_TPARequest.MapCountrywithOfferingId = null;
            SRV_TPA_TPARequest.tpaOfferingNotificationAcctMappingMap = null;
            //Set Null After use to save heap size end

            reqObj.tpaRequest.Stop_TLLA_Generation_Notice_Sent_Date__c = null;
        }
        catch(Exception ex) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::vendorSubmission:::after insert TPARequestBackupDetails', (reqObj != null && reqObj.tpaRequest != null) ? reqObj.tpaRequest.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }        

        String competitiveServicePresent = (reqObj.tpaRequest.Competitive_Service_to_IMS_Offerings__c == 'Yes' || reqObj.tpaRequest.Competitive_Service_to_IMS_Offerings_2__c == 'Yes' || reqObj.tpaRequest.Competitive_Service_to_IMS_Offerings_3__c == 'Yes') ? 'Yes' : 'No';

        CNT_TPA_RequestSubmissionForm.updateAccount(reqObj.tpaRequest.Service_Provider_Address__c, competitiveServicePresent);
        
        getLimitsMessage();

        system.debug('before ama call');
        system.debug('reqObj.tpaRequest.AMA_USPrescriberData__c:' + reqObj.tpaRequest.AMA_USPrescriberData__c);
        system.debug('reqObj.amaAgrSubmitted:' + reqObj.amaAgrSubmitted);
        
        if(reqObj.tpaRequest.AMA_USPrescriberData__c == 'Yes') {
            system.debug('in if condition');
            amaAgreementDetails = getAmaAgreement(reqObj.tpaRequest, reqObj.amaAgrSubmitted, 'VendorSubmit');
            
            if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
                amaAgreementDetails.id = reqObj.tpaRequest.AMA_Agreement_Details__r[0].id;
            } else {
                amaAgreementDetails.TPA_Request__c = reqObj.tpaRequest.id;
            }
        } 
        else {
            system.debug('in else condition');
            if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
                amaAgreementDetails = reqObj.tpaRequest.AMA_Agreement_Details__r[0];
                CNT_TPA_RequestSubmissionForm.resetAmaValuesOnAmaAgreement(amaAgreementDetails);
                SRV_TPA_AMAAgreementDetail.amaAgreementDetails = amaAgreementDetails;
                SRV_TPA_AMAAgreementDetail.resetAllAmaAgreementDetail ();
            }
        }     
        
        try {
            system.debug('amaAgreementDetails:' + amaAgreementDetails);
            if(amaAgreementDetails != null) {
                upsert amaAgreementDetails;
                amaAgreementDetails = null; //Setting null after use to save heap size
                SRV_TPA_AMAAgreementDetail.amaAgreementDetails = null; //Setting null after use to save heap size
            }
        } catch(Exception ex) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::vendorSubmission:::update amaAgreementDetails', (reqObj != null && reqObj.tpaRequest != null) ? reqObj.tpaRequest.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            System.debug('**Exception while upserting AMA agreement**'+ex.getMessage());
        }

        if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
            amaAgreementDetails = reqObj.tpaRequest.AMA_Agreement_Details__r[0];
        }
        
        //system.debug('amaAgreementDetails:' + amaAgreementDetails.Vendor_require_Remote_Access_from_NonUS__c);

        //Run AMA Business Rule
        if(reqObj.tpaRequest.AMA_USPrescriberData__c == 'Yes' && reqObj.tpaRequest.Service_Provider_Address__c != null) {
            resetAmaValuesOnTpaRequest(reqObj.tpaRequest);
            reqObj.tpaRequest.Type_of_AMA_Agreement__c = null;
            reqObj.tpaRequest.AMA_DBL__c = null;
        }

        if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
            amaAgreementDetails = reqObj.tpaRequest.AMA_Agreement_Details__r[0];
        }

        //system.debug('amaAgreementDetails:' + amaAgreementDetails.Vendor_require_Remote_Access_from_NonUS__c);

        
        List<TPA_contact__c> existedTpaVendorContacts = [select Id from TPA_Contact__c where TPA_Request__c =: reqObj.tpaRequest.Id and Type__c =: TPA_ADDITIONAL_VENDOR_CONTACT];
        delete existedTpaVendorContacts;
        updateAdditionalVendorContacts(reqObj);
        
        if(reqObj.tpaRequest.isVendorSubmitted__c) {
            reqObj.tpaRequest.LastAction__c = 'Request Edited By Vendor';
        }
        else {
            reqObj.tpaRequest.LastAction__c = 'Request Submitted By Vendor';
            reqObj.tpaRequest.isVendorSubmitted__c = true;
        }

        if(reqObj.authorizedSignerResponse == 'Yes') {
            reqObj.tpaRequest.Authorized_Signer_First_Name__c = reqObj.tpaRequest.Vendor_First_Name__c;
            reqObj.tpaRequest.Authorized_Signer_Last_Name__c = reqObj.tpaRequest.Vendor_Contact_Last_Name__c;
            reqObj.tpaRequest.Authorized_Signer_Title__c = reqObj.tpaRequest.Vendor_Contact_Title__c;
            reqObj.tpaRequest.Authorized_Signer_Email__c = reqObj.tpaRequest.Vendor_e_mail__c;
        }

        if(reqObj.tpaRequest.Service_Provider_Address__c == null && reqObj.tpaRequest.Vendor_Company_Name__c != null) {
            reqObj.tpaRequest.Vendor_Name_f__c = 'Invited: ' + reqObj.tpaRequest.Vendor_Company_Name__c;
            reqObj.tpaRequest.Vendor_Contact_Name_f__c = 'Invited: ' + reqObj.tpaRequest.Vendor_First_Name__c + ' ' + reqObj.tpaRequest.Vendor_Contact_Last_Name__c;
        }
        reqObj.tpaRequest.Is_Submitted__c = true;

        // SRV_TPA_TPARequest.tpaRequest = reqObj.tpaRequest;
        // SRV_TPA_TPARequest.updateAgreementFields();
        // reqObj.tpaRequest = SRV_TPA_TPARequest.tpaRequest;

        if(reqObj.tpaRequest.Data_Access_Start_Date__c != null) {
            reqObj.tpaRequest.Original_Start_Date__c = reqObj.tpaRequest.Data_Access_Start_Date__c;
        }
        if(reqObj.tpaRequest.Data_Access_End_Date__c != null) {
            reqObj.tpaRequest.Expiration_Date__c = reqObj.tpaRequest.Data_Access_End_Date__c;
        }
        //reqObj.tpaRequest.IsSubContractorAdded__c = isSubContractAdded;
        if( reqObj.tpaRequest.Vendor_e_mail__c != null) {
            reqObj.tpaRequest.Vendor_Contact_e_mail__c = reqObj.tpaRequest.Vendor_e_mail__c;
        }
        if( reqObj.tpaRequest.Vendor_First_Name__c != null && reqObj.tpaRequest.Vendor_Contact_Last_Name__c != null) {
            reqObj.tpaRequest.Vendor_Contact_Name_f__c = reqObj.tpaRequest.Vendor_First_Name__c+' '+reqObj.tpaRequest.Vendor_Contact_Last_Name__c;
        }

        try{
            UTL_TPA.vendorSubmissionFirstUpdate = true;
            update reqObj.tpaRequest;//TODO: will review
            UTL_TPA.vendorSubmissionFirstUpdate = false;
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Request Updated2', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::vendorSubmission', reqObj.tpaRequest.Id));
        }
        catch(Exception ex){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::vendorSubmission', reqObj.tpaRequest.Id));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }

        if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
            amaAgreementDetails = reqObj.tpaRequest.AMA_Agreement_Details__r[0];
        }

        //system.debug('amaAgreementDetails:' + amaAgreementDetails.Vendor_require_Remote_Access_from_NonUS__c);


   
        //SRV_TPA_TPARequest.deleteExcludedReviews();

        TGRH_TPARequest.runAllCompletedBlock = true; //TODO: will review, need to check why we need to run this block here, shold be done at the end of the method
        
        //SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(reqObj.tpaRequest.Id); // will review, check if this query is required
        SRV_TPA_TPARequest.tpaRequest = reqObj.tpaRequest; // will review, check if this query is required
        //reqObj.tpaRequest = SRV_TPA_TPARequest.tpaRequest;//will review this line
        system.debug('reqObj.tpaRequest.is_Addendum_Attachment_Required__c:' + reqObj.tpaRequest.is_Addendum_Attachment_Required__c);

        //@@@@@@@@@@
        SRV_TPA_TPARequest.isSubContractAdded  = (reqObj.tpaSubContractors.size() > 0);
        SRV_TPA_TPARequest.authorizedSignerResponse = reqObj.authorizedSignerResponse;
        SRV_TPA_TPARequest.LastAction = reqObj.tpaRequest.LastAction__c;
        SRV_TPA_TPARequest.type = reqObj.tpaRequest.Request_Type__c;
        SRV_TPA_TPARequest.requestNumber = reqObj.tpaRequest.Parent_Request__r.Name;

        if(reqObj.tpaRequest.is_Bulk_TPA_Request__c) {

        QBL_TPA_getManualReviewReasons getManualReviewReasonsObj = new QBL_TPA_getManualReviewReasons();
        getManualReviewReasonsObj.request = reqObj.tpaRequest;
        getManualReviewReasonsObj.langFieldName = supportedLanguageMap.get(language).split('~')[1];
        getManualReviewReasonsObj.multilanguageUtilityMap = multilanguageUtilityMap;
        getManualReviewReasonsObj.LastAction = reqObj.tpaRequest.LastAction__c;
        getManualReviewReasonsObj.isSubContractAdded = (reqObj.tpaSubContractors.size() > 0);
        getManualReviewReasonsObj.authorizedSignerResponse = reqObj.authorizedSignerResponse;
        getManualReviewReasonsObj.type = reqObj.tpaRequest.Request_Type__c;
        getManualReviewReasonsObj.requestNumber = reqObj.tpaRequest.Parent_Request__r.Name;
        getManualReviewReasonsObj.isAwaitingClientConfirmationMailReq = isAwaitingClientConfirmationMailReq;
        getManualReviewReasonsObj.dynamicOfferingsNotificationListForVendor = SRV_TPA_TPARequest.dynamicOfferingsNotificationListForVendor;
        getManualReviewReasonsObj.isDirectToClientExeMode = SRV_TPA_TPARequest.isDirectToClientExeMode;
        getManualReviewReasonsObj.isQuintilesIMSSalesExeMode = SRV_TPA_TPARequest.isQuintilesIMSSalesExeMode;
        getManualReviewReasonsObj.isVendorChecklistChanges = SRV_TPA_TPARequest.isVendorChecklistChanges;
        getManualReviewReasonsObj.isdynamicOffNoticationReqOrNot = true;
        getManualReviewReasonsObj.runType = 'VendorSubmission';
        if(SRV_TPA_TPARequest.commercialReasonMap != null && SRV_TPA_TPARequest.commercialReasonMap.size() > 0) {
            getManualReviewReasonsObj.commercialReasonListSecond = SRV_TPA_TPARequest.commercialReasonMap.values();
        }
        if(!Test.isRunningTest()){
            System.enqueueJob(getManualReviewReasonsObj);
        }
    }
    else{
        if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
            amaAgreementDetails = reqObj.tpaRequest.AMA_Agreement_Details__r[0];
        }



        reqObj.tpaRequest = SRV_TPA_TPARequest.getManualReviewReasons(reqObj.tpaRequest);// will make it queueable

        if(reqObj.tpaRequest.AMA_Agreement_Details__r != null && reqObj.tpaRequest.AMA_Agreement_Details__r.size() > 0) {
            amaAgreementDetails = reqObj.tpaRequest.AMA_Agreement_Details__r[0];
        }



        if(reqObj.tpaRequest.AMA_USPrescriberData__c == 'Yes' && reqObj.tpaRequest.Service_Provider_Address__c != null) {
            //reqObj.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(reqObj.tpaRequest.Id); // will review, check if we need this query, check if we updated tpa request before this
            String tpaRequestJSON = JSON.serialize(reqObj.tpaRequest);
            reqObj.tpaRequest = SRV_TPA_AMAAgreementDetail.validateFunctionalRequirements(tpaRequestJSON);//will review
        }

        SRV_TPA_TPARequest.tpaRequest = reqObj.tpaRequest;

        
        UTL_TPA_Multilingual.saveUseOfferingTranslatedNames(reqObj.tpaRequest.Id, supportedLanguageMap.get(language).split('~')[1], multilanguageUtilityMap);//will review, put logs on update inside, last two parameters are static no need to send as params, will do this work with updateChildRecordsTranslation
        UTL_TPA_Multilingual.updateChildRecordsTranslation(reqObj.tpaRequest.id ,null); //will review
        
        SRV_TPA_TPARequest.updateAgreementFieldsForVendor(true);//will review, why we are sending always true here


       

    }



        
        UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Agreement Updated', 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::vendorSubmission', reqObj.tpaRequest.Id));
        
   
        UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, UTL_TPA.savePoints.get('5E'), 'TPA', 'Custom', 'INFO', ':::CNT_TPA_RequestSubmissionForm:::vendorSubmission', reqObj.tpaRequest.Id));
        UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE); 
    }   

    public string validateLoadRequestType(string loadType, string requestStatus, string requestBy) {
        if(requestBy == 'c') {
            Date todayDate = Date.today(); 
            if((loadType == 'renew') && isTPProcessor) {
                return 'invalid';
            }
            else if((loadType == 'view' || loadType == 'clone')
                 && (  requestStatus == 'expired'
                    || requestStatus == 'in effect'
                    || requestStatus == 'Awaiting Vendor Signature'
                    || requestStatus == 'In Auto Approval Process'
                    || requestStatus == 'TPA Approved Awaiting AMA Approval'
                    || requestStatus == Label.TPA_In_Review_By_IMS_Status
                    || requestStatus == Label.TPA_In_Review_By_IQVIA_Status
                    || requestStatus == 'Pending IQVIA Review of Voided Envelope'
                    || requestStatus == UTL_TPA.PENDING_VENDOR_RESPONSE_ON_DDN_FROM_PRIOR_TPAs
                    || requestStatus == 'Awaiting Vendor Submission'
                    || requestStatus == 'Signature Under Validation'
                    || requestStatus == Label.TPA_IQVIA_Denied_Status
                    || requestStatus == 'Initializing Vendor'
                    || requestStatus == 'Client Discontinued'
                    || requestStatus == 'AMA Cancelled'
                    || requestStatus == 'AMA Discontinued'
                    || requestStatus == UTL_TPA.AWAITING_CLIENT_CONFIRMATION
                    || requestStatus == 'Pending Vendor AMA Fee Acknowledgement'
                    || requestStatus == 'Pending - Vendor Declined AMA Fees'
                    || requestStatus == 'Awaiting Account Mgmt Communication'
                    || requestStatus == 'Awaiting Final Review'
                    || requestStatus == 'Pending Cancellation'
                    || requestStatus == 'Awaiting Client Modification'
                    || requestStatus == 'Cancelled' //Added by Rajendra under ER-12116
                    || requestStatus == 'Closed-IQVIA Affiliate' //Added by Rajendra under ER-12247 //Modified by Rajendra under ER-12209
                    || requestStatus == UTL_TPA.VENDOR_CANCELED_25_AMA_TPA_EXP_12_31_24
                    || requestStatus == UTL_TPA.VENDOR_CANCELED_26_AMA_TPA_EXP_12_31_25
                    || requestStatus == UTL_TPA.VENDOR_CANCELED_21_AMA_TPA_EXP_12_31_20
                    || requestStatus == UTL_TPA.VENDOR_CANCELED_22_AMA_TPA_EXP_12_31_21
                    || requestStatus == UTL_TPA.VENDOR_CANCELED_23_AMA_TPA_EXP_12_31_22
                    || requestStatus == UTL_TPA.VENDOR_CANCELED_24_AMA_TPA_EXP_12_31_23
                    || requestStatus == 'Hold for TPA non-compliance'
					|| requestStatus == 'Covered By MOU')) {
                return 'valid';
            }
            else if(loadType == 'renew' && requestStatus == 'expired') {
                return 'valid';
            }
            else if(loadType == 'view' && requestStatus == 'cancelled') {
                return 'valid';
            }
            else if(loadType == 'edit'
                && (  requestStatus == 'Awaiting Vendor Signature'
                   || requestStatus == 'In Auto Approval Process'
                   || requestStatus == 'TPA Approved Awaiting AMA Approval'
                   || requestStatus == Label.TPA_In_Review_By_IQVIA_Status
                   || requestStatus == 'Pending IQVIA Review of Voided Envelope'
                   || requestStatus == Label.TPA_In_Review_By_IMS_Status
                   || requestStatus == UTL_TPA.PENDING_VENDOR_RESPONSE_ON_DDN_FROM_PRIOR_TPAs
                   || requestStatus == 'Awaiting Vendor Submission'
                   || requestStatus == 'Initializing Vendor'
                   || requestStatus == UTL_TPA.AWAITING_CLIENT_CONFIRMATION
                   || requestStatus == 'Pending Vendor AMA Fee Acknowledgement'
                   || requestStatus == 'Pending - Vendor Declined AMA Fees'
                   || requestStatus == 'Awaiting Account Mgmt Communication'
                   || requestStatus == 'Awaiting Final Review'
                   || requestStatus == 'Pending Cancellation'
                   || requestStatus == 'Hold for TPA non-compliance'
                   || requestStatus == 'Awaiting Client Modification' )) {
                return 'valid';
            }
            else if(loadType == 'renew' && requestStatus == 'in effect' && tpaRequestToEdit != null && todayDate <= tpaRequestToEdit.Data_Access_End_Date__c && todayDate.daysBetween(tpaRequestToEdit.Data_Access_End_Date__c) < 61) {
                return 'valid';
            }
            else if((loadType == 'view' || loadType == 'edit') && requestStatus == 'Client Draft') {
                return 'valid';
            }
            else if(loadType == 'view' && requestStatus == 'Draft Closed') {
                return 'valid';
            }
            else {
                return 'invalid';
            }
        }
        else if(requestBy == 'v') {
            if( loadType == 'edit'
                && (requestStatus == 'Awaiting Vendor Signature'
                    || requestStatus == 'In Auto Approval Process'
                    || requestStatus == 'TPA Approved Awaiting AMA Approval'
                    || requestStatus == Label.TPA_In_Review_By_IQVIA_Status
                    || requestStatus == 'Pending IQVIA Review of Voided Envelope'
                    || requestStatus == Label.TPA_In_Review_By_IMS_Status
                    || requestStatus == 'Awaiting Vendor Submission')) {
                return 'valid';
            }
            else {
                return 'invalid';
            }
        }
        return 'invalid';
    }    

 

    @remoteAction
    global static string backupUseOffering(string useOffList, string backupDetail) {
        List<TPA_Use_Offerings_UI_Backup__c> useOffListToInsert = (List<TPA_Use_Offerings_UI_Backup__c>)JSON.deserialize(useOffList, List<TPA_Use_Offerings_UI_Backup__c>.class);
        tpaRequestDetails backupObj = (tpaRequestDetails)JSON.deserialize(backupDetail, tpaRequestDetails.class);

        if(UTL_Validate.isValidGuid(backupObj.GUID)) {
            UTL_LogFactory.GUID = backupObj.GUID; 
        }

        string tpaRequest = '';
        if(useOffListToInsert != null && useOffListToInsert.size() != 0) {
            tpaRequest = useOffListToInsert[0].TPA_Request__c;
        }

        String mapInfo = 'MapPurpDesc(' + (backupObj.MapPurpDesc != null ? backupObj.MapPurpDesc.Size() : null) + ') MapPurpDescOther(' +  (backupObj.MapPurpDescOther != null ? backupObj.MapPurpDescOther.Size() : null) + ') PurposeMap(' +  (backupObj.PurposeMap != null ? backupObj.PurposeMap.Size() : null) + ') PurposeMapOther(' +  (backupObj.PurposeMapOther != null ? backupObj.PurposeMapOther.Size() : null) + ') SelectedDescMap(' +  (backupObj.SelectedDescMap != null ? backupObj.SelectedDescMap.Size() : null) + ') mapPurposeidWithDataAssetMap(' +  (backupObj.mapPurposeidWithDataAssetMap != null ? backupObj.mapPurposeidWithDataAssetMap.Size() : null) + ') mapSecondayDataAssetToInsert(' +  (backupObj.mapSecondayDataAssetToInsert != null ? backupObj.mapSecondayDataAssetToInsert.Size() : null) + ') categorypurposesList(' +  (backupObj.categorypurposesList != null ? backupObj.categorypurposesList.Size() : null) + ') secondarypurpose(' +  (backupObj.secondarypurpose != null ? backupObj.secondarypurpose.Size() : null) + ')';
        String reuestID = tpaRequest;
        Log_History__c logObj = UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, 'Backup Details in backupUseOffering ', 'TPA', 'Custom', 'INFO', mapInfo , reuestID);

        UTL_LogFactory.getLogLst().Add(logObj);
        UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);

        Map<String, Schema.SObjectField> fieldMapBackupObj = Schema.SObjectType.TPA_Use_Offerings_UI_Backup__c.fields.getMap();
        
        Integer actionDetailsLength = fieldMapBackupObj.get('Action_Details__c').getDescribe().getLength();
        Integer keyDetailsLength = fieldMapBackupObj.get('Key_Details__c').getDescribe().getLength();

        for(TPA_Use_Offerings_UI_Backup__c obj :useOffListToInsert){
            if(obj.Action_Details__c != null){
                if(obj.Action_Details__c.length() > actionDetailsLength) {
                    obj.Action_Details__c = obj.Action_Details__c.substring(0, actionDetailsLength - 1);
                }
            }
            if(obj.Action_Details__c != null){
                if(obj.Key_Details__c.length() > keyDetailsLength) {
                    obj.Key_Details__c = obj.Key_Details__c.substring(0, keyDetailsLength - 1);
                }
            }
            
        }

        



        if(useOffListToInsert != null && useOffListToInsert.size() != 0) {
            insert useOffListToInsert;
        }
        tpaRequest = '';
        for(TPA_Use_Offerings_UI_Backup__c useOffBackupObj: useOffListToInsert) {
            tpaRequest += useOffBackupObj.Id + ';';
        }
        tpaRequest = tpaRequest.removeEnd(';');
        return 'success::' + tpaRequest;
    }
    //Added by C.P.Pandey under ER-2654 end

    //Added by Babita Dadarwal under ER-2106 Start
    //Function to get currect date time
    @remoteAction
    global static DateTime getAcknowledgementDateTime()
    {
        return DateTime.now();
    }

    //Function to get all offering notification fron text editor
    @remoteAction
    global static List<TPA_Text_Editor__C> getOfferingsNotificationsList(List<Id> masterOfferingIds) {
        List<String> masterOfferingID15Digit = new List<String>();
        for(string idValue: masterOfferingIds) {
            idValue = idValue.substring(0,idValue.length()-3);
            masterOfferingID15Digit.add(idValue );
        }
        List<TPA_Text_Editor__C> txtOffNotifications = [SELECT Id, 
                                                               Name, 
                                                               Content__c, 
                                                               English_Translation__c, 
                                                               Japanese_Translation__c, 
                                                               Page_Name__c, 
                                                               Page_Title__c, 
                                                               Page_Type__c 
                                                        FROM TPA_Text_Editor__c 
                                                        WHERE Page_Type__c = 'Tpa Offering Notifications' 
                                                        and (Page_Title__c IN :masterOfferingID15Digit 
                                                            or Page_Title__c='Client_Notification' 
                                                            or Page_Title__c='Client/Vendor Notification' 
                                                            or Page_Title__c='Vendor_Notification')
                                                        and Is_Active__c = true];
        return txtOffNotifications;
    }

    public class existingDynOffNotiDataData {
        public Map<ID, TPA_Text_Editor__C> mapOfIdWithTextEditorObj;
        List<TPA_Text_Editor__C> txtOffNotifications;
        List<TPA_Offering_Notification_Mapping__c> DynamicOffNotificationMappingList;  
        List<TPA_Text_Editor__C> clientVendorNotification;   

        public existingDynOffNotiDataData() {
            mapOfIdWithTextEditorObj = new Map<ID, TPA_Text_Editor__C>();
            txtOffNotifications = new List<TPA_Text_Editor__C>();
            DynamicOffNotificationMappingList = new List<TPA_Offering_Notification_Mapping__c>();
            clientVendorNotification = new List<TPA_Text_Editor__C>(); 
        } 
    }


    @remoteAction
    public static existingDynOffNotiDataData getdynamicOfferingsNotifications() {
        existingDynOffNotiDataData existingDynOffNotiDataObj = new existingDynOffNotiDataData();
        mapOfIdWithTextEditorObj = new Map<ID, TPA_Text_Editor__C>([SELECT Id, 
                                                                           Name, 
                                                                           Content__c, 
                                                                           English_Translation__c, 
                                                                           Japanese_Translation__c, 
                                                                           Page_Name__c, 
                                                                           Page_Title__c, 
                                                                           Page_Type__c 
                                                                    FROM TPA_Text_Editor__c]);
        existingDynOffNotiDataObj.mapOfIdWithTextEditorObj = mapOfIdWithTextEditorObj;                                                            

        List<TPA_Text_Editor__C> txtOffNotifications = [SELECT Id, 
                                                               Name, 
                                                               Content__c, 
                                                               Page_Name__c, 
                                                               Page_Title__c, 
                                                               Page_Type__c 
                                                        FROM TPA_Text_Editor__c 
                                                        WHERE Page_Type__c = 'Tpa Offering Notifications Mapping'];
        existingDynOffNotiDataObj.txtOffNotifications = txtOffNotifications;                                                 

        List<TPA_Offering_Notification_Mapping__c> DynamicOffNotificationMappingList = [SELECT Id,
                                                                                               Name,
                                                                                               IsActive__c,
                                                                                               OfferingName__c,
                                                                                               Country__c,
                                                                                               IMS_Primary_Data_Asset__r.Asset_Name__c,
                                                                                               IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c,
                                                                                               IMS_TPA_Purpose__r.Primary_Purpose_Name__c,
                                                                                               Offering_Notifications__r.Page_Name__c,
                                                                                               TLLA_Additional_Terms__r.Page_Name__c,
                                                                                               Vendor_Accounts_Name__c 
                                                                                        FROM TPA_Offering_Notification_Mapping__c 
                                                                                        where IsActive__c = true];
        existingDynOffNotiDataObj.DynamicOffNotificationMappingList = DynamicOffNotificationMappingList; 
        List<TPA_Text_Editor__C> clientVendorNotification = [SELECT Id, 
                                                                    Name, 
                                                                    Content__c, 
                                                                    English_Translation__c, 
                                                                    Japanese_Translation__c, 
                                                                    Page_Name__c, 
                                                                    Page_Title__c, 
                                                                    Page_Type__c 
                                                             FROM TPA_Text_Editor__c 
                                                             WHERE Page_Type__c = 'TPA Offering Addendum' 
                                                             and (Page_Title__c='Client_Notification' 
                                                                  or Page_Title__c='Client/Vendor Notification' 
                                                                  or Page_Title__c='Vendor_Notification')]; 
        existingDynOffNotiDataObj.clientVendorNotification = clientVendorNotification; 
                                           
        return  existingDynOffNotiDataObj;  

    }

    
     //added by neha under ER-3509 ends
    //*** Added by Sunny Bansal under ER-2024 starts ***//
    public Map<Integer,List<string>> getPresciberLevelAttributesList()
    {
        //Map to store the provider level attributes
        //Key: Integer values to map attributes
        //Value: List to store all provider level attributes as string
        Map<Integer,List<string>> requestedMap= new Map<Integer,List<string>>();

        //List to store all provider level attributes as string
        List<string> requestedData = new List<string>();
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.AMA_TypeOfPrescriberLevelData__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Integer var = 0;
        Integer rowCount = 0;
        Integer colCount = 0;
        for(Schema.PicklistEntry f : ple)
        {
            var++;
            requestedData.add(f.getLabel());
            colCount++;
            if(colCount == 4) {
                rowCount++;
                colCount = 0;
                requestedMap.put(rowCount, requestedData);
                requestedData = new List<String>();
            }
        }
        if(requestedData.size() > 0) {
            rowCount++;
            requestedMap.put(rowCount, requestedData);
        }
        return requestedMap;//JSON.serialize(requestedMap);
    }
    //*** Added by Sunny Bansal under ER-2024 ends ***//

    //Added by Babita Dadarwal under ER-2241 Start
    // Method to get AMA variables MAp for the AMA question  -- Please indicate the project USE specifically related to the AMA prescriber identifiable data included in the TPA request
    public Map<Integer,List<string>> getAMAlistValuesDataMap()
    {
        //Map to store the AMA prescriber identifiable data
        //Key: Integer values to map attributes
        //Value: List to store all AMA prescriber identifiable data as string
        Map<Integer,List<string>> requestedMap= new Map<Integer,List<string>>();


        //List to store all AMA prescriber identifiable data as string
        List<string> requestedData = new List<string>();

        MAP<String,TPA_AMA_Picklist__c> data = TPA_AMA_Picklist__c.getAll();

        List<String> picklistValues = new List<String>();
        for(String key : data.keySet())
        {
          picklistValues.add(data.get(key).Picklist_value__c);
        }

        picklistValues.sort();
        Integer var = 0;
        Integer rowCount = 0;
        Integer colCount = 0;
        for (String f : picklistValues)
        {
            var++;
            requestedData.add(f);
            colCount++;
            if(colCount == 5) {
                rowCount++;
                colCount = 0;
                requestedData.sort();
                requestedMap.put(rowCount, requestedData);
                requestedData = new List<String>();
            }
        }

        if(requestedData.size() > 0) {
          rowCount++;
          requestedData.sort();
          requestedMap.put(rowCount, requestedData);
        }

        return requestedMap;
    }

    // Method to get AMA variables MAp for the AMA question  -- If collecting response data, how will the response data be collected?
  /*  public Map<Integer,List<string>> getAmaResponseCollectionMeansMap()
    {

        //Map to store the AMA response data
        //Key: Integer values to map attributes
        //Value: List to store all AMA response data as string
        Map<Integer,List<string>> requestedMap= new Map<Integer,List<string>>();

        //List to store all AMA response data as string
        List<string> requestedData = new List<string>();

        Schema.DescribeFieldResult fieldResult = TPA_Request__c.AMA_HowResponseDataCollected__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        Integer var = 0;
        Integer rowCount = 0;
        Integer colCount = 0;
        for(Schema.PicklistEntry f : ple)
        {
            var++;
            requestedData.add(f.getLabel());
            colCount++;
            if(colCount == 3) {
                rowCount++;
                colCount = 0;
                requestedMap.put(rowCount, requestedData);
                requestedData = new List<String>();
            }
        }
        if(requestedData.size() > 0) {
            rowCount++;
            requestedMap.put(rowCount, requestedData);
        }

        return requestedMap;
    }*/

    // Method to get AMA prescribed variables  -- What AMA variables will be collected from the prescribers contacted, if any?
   /* public Map<Integer,List<string>> getAmaPpdVariablesMap()
    {
        //Map to store the AMA prescribed variables
        //Key: Integer values to map attributes
        //Value: List to store all AMA prescribed variables as string
        Map<Integer,List<string>> requestedMap= new Map<Integer,List<string>>();

        //List to store all AMA prescribed variables as string
        List<string> requestedData = new List<string>();

        Schema.DescribeFieldResult fieldResult = TPA_Request__c.AMA_PPDVariablesCollected__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        Integer var = 0;
        Integer rowCount = 0;
        Integer colCount = 0;
        for(Schema.PicklistEntry f : ple)
        {
            var++;
            requestedData.add(f.getLabel());
            colCount++;
            if(colCount == 5) {
                rowCount++;
                colCount = 0;
                requestedMap.put(rowCount, requestedData);
                requestedData = new List<String>();
            }
        }
        if(requestedData.size() > 0) {
            rowCount++;
            requestedMap.put(rowCount, requestedData);
        }
        return requestedMap;
    }*/

    // Method to get AMA Market Research Project Attributes for AMA Ques. - Chose any of the following that best describes your market research project:
    /*public Map<Integer,List<string>> getAMAMRAttributesMap()
    {
        //Map to store the AMA Market Research Project Attributes
        //Key: Integer values to map attributes
        //Value: List to store all AMA Market Research Project Attributes as string
        Map<Integer,List<string>> requestedMap= new Map<Integer,List<string>>();

        //List to store all AMA Market Research Project Attributes as string
        List<string> requestedData = new List<string>();

        MAP<String,TPA_AMA_Market_Research_Attributes_List__c> data = TPA_AMA_Market_Research_Attributes_List__c.getAll();
        List<String> picklistValues = new List<String>();
        for(String key : data.keySet())
        {
          picklistValues.add(data.get(key).AMA_Market_Research_Attributes__c);
        }

        Integer var = 0;
        Integer rowCount = 0;
        Integer colCount = 0;
        for (String f : picklistValues)
        {
            var++;
            requestedData.add(f);
            colCount++;
            if(colCount == 4) {
                rowCount++;
                colCount = 0;
                requestedData.sort();
                requestedMap.put(rowCount, requestedData);
                requestedData = new List<String>();
            }
        }
        if(requestedData.size() > 0) {
          rowCount++;
          requestedData.sort();
          requestedMap.put(rowCount, requestedData);
        }
        return requestedMap;
    }*/

    // Method to get AMA Distribution and Mailing Attributes  -- Chose any of the following that best describes your distribution and mailing project:
  /*  public Map<Integer,List<string>> getAmaDMAttribuesMap()
    {
        //Map to store the AMA Distribution and Mailing Attributes
        //Key: Integer values to map attributes
        //Value: List to store all AMA Distribution and Mailing Attributes as string
        Map<Integer,List<string>> requestedMap= new Map<Integer,List<string>>();

        //List to store all AMA Distribution and Mailing Attributes as string
        List<string> requestedData = new List<string>();

        Schema.DescribeFieldResult fieldResult = TPA_Request__c.AMA_Distribution_And_Mailing_Attributes__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Integer var = 0;
        Integer rowCount = 0;
        Integer colCount = 0;
        for(Schema.PicklistEntry f : ple)
        {
            var++;
            requestedData.add(f.getLabel());
            colCount++;
            if(colCount == 5) {
                rowCount++;
                colCount = 0;
                requestedMap.put(rowCount, requestedData);
                requestedData = new List<String>();
            }
        }
        if(requestedData.size() > 0) {
            rowCount++;
            requestedMap.put(rowCount, requestedData);
        }
        return requestedMap;
    }*/
    //Added by Babita Dadarwal under ER-2241 End

    public class ProposalTree
    {
        Map<id,IMS_TPA_Purpose__c> primarypurpose;
        List<IMS_TPA_Purpose_Description__c> secondarypurpose;
        List<IMS_TPA_Purpose_Category__c> categorypurposesList;
        List<IMS_Data_Asset__c> dataAssetList;
        Map<id,IMS_TPA_Purpose__c> mapPurposeAndDesc;
        map<id,IMS_Secondary_Data_Asset__c> secondaryDataAssetList;
        List<TPA_Purpose_Category__c> tpaPurposeCategoryList;
        Map<String,id> MapOffGeolevelBUwithOffId = new Map<String,id>(); //Added By Neha under CR-11745
         public Map<string,List<string>> mapOfferingWithlistOfCountry = new  Map<string,List<string>>(); // Added By Neha under CR-11745
    }
    transient ProposalTree proposTree; // Updated by C.P.Pandey under Issue-7485
    public string getProposalTreeData()
    {
        if(proposTree == null)
        {
            proposTree = new ProposalTree();
            //*** Changed by Sunny Bansal 27 Mar ER-1655 starts ***//
            proposTree.primarypurpose = new Map<id,IMS_TPA_Purpose__c>([Select Id,Primary_Purpose_Name__c, English_Translation__c, Japanese_Translation__c, BU__c from IMS_TPA_Purpose__c where Primary_Purpose_Name__c != null and Is_Active__c = true order by Primary_Purpose_Name__c]); //Updated by Babita Dadarwal under ER-1940 on 19 July 2016
            //***  Changed by Sunny Bansal 27 Mar ER-1655 ends ***//
            proposTree.secondarypurpose = [Select Id,Description__c,Purpose__c,TPA_Purpose_Category__c,TPA_Purpose_Category__r.Category_Name__c, TPA_Purpose_Category__r.English_Translation__c, TPA_Purpose_Category__r.Japanese_Translation__c, Purpose__r.Is_Active__c, Purpose__r.Primary_Purpose_Name__c, Purpose__r.English_Translation__c, Purpose__r.Japanese_Translation__c, Use_Definition_file_exist__c, Use_Definition_Page__c from IMS_TPA_Purpose_Description__c where Is_Active__c = true and TPA_Purpose_Category__r.isactive__c = true order by Purpose__r.Primary_Purpose_Name__c]; //Updated by Babita Dadarwal under ER-1940 on 20 July 2016
            //*** Changed by Sunny Bansal 27 Mar ER-1655 starts ***//
            proposTree.categorypurposesList = [Select i.IMS_TPA_Purpose__r.Id, i.IMS_TPA_Purpose__r.english_translation__c,i.IMS_TPA_Purpose__r.japanese_translation__c,i.TPA_Purpose_Category__c, i.TPA_Purpose_Category__r.Id, i.TPA_Purpose_Category__r.Category_Name__c, i.TPA_Purpose_Category__r.Japanese_Translation__c, i.TPA_Purpose_Category__r.English_Translation__c, i.Id, i.IMS_TPA_Purpose__c, i.IMS_TPA_Purpose__r.BU__c,i.IMS_TPA_Purpose__r.Primary_Purpose_Name__c,i.IMS_TPA_Purpose__r.Other_for_Sorting_Display__c From IMS_TPA_Purpose_Category__c i where i.IMS_TPA_Purpose__r.Is_Active__c = true and i.TPA_Purpose_Category__r.isActive__c = true order by i.IMS_TPA_Purpose__r.Other_for_Sorting_Display__c,i.IMS_TPA_Purpose__r.Primary_Purpose_Name__c];//modified by Govind under ER-1749 //Updated by Babita Dadarwal under ER-1940 on 19 July 2016
            proposTree.mapPurposeAndDesc = new Map<id,IMS_TPA_Purpose__c>([Select Id,Primary_Purpose_Name__c, English_Translation__c, Japanese_Translation__c, (Select Id,TPA_Purpose_Category__c,Purpose__c,Description__c,Use_Definition_file_exist__c, Use_Definition_Page__c from IMS_TPA_Purpose_Description__r where Is_Active__c = true) from IMS_TPA_Purpose__c where Is_Active__c = true]); //Updated by Babita Dadarwal under ER-1940 on 19 July 2016
            //***  Changed by Sunny Bansal 27 Mar ER-1655 ends ***//

            //Updated by Babita Dadarwal under ER-2106 Start
            //Updated by Babita Dadarwal under ER-2516 start
            proposTree.dataAssetList = [select id,
                                               BU__c,
                                               Geo_Level__c,
                                               Asset_Name__c,
                                               Other_for_Sorting_Display__c,
                                               Is_Restricted_Data__c,
                                               Commercial_Owner_Email__c,
                                               //Added by Babita Dadarwal under ER-1940 on 18 July 2016 Start
                                               English_Translation__c,
                                               Japanese_Translation__c,
                                               //Added by Babita Dadarwal under ER-1940  on 18 July 2016 End
                                               Is_IMS_AGProduct__c,
                                               Is_Notification_Required__c,
                                               Is_AMA_Required__c, // Added by Babita Dadrwal on 18 May 2016 uner ER-2812
                                               (select id,
                                               Display_Order__c,
                                                       Secondary_Asset_Name__c,
                                                       //Added by Babita Dadarwal under ER-1940 on 18 July 2016 Start
                                                       English_Translation__c,
                                                       Japanese_Translation__c,
                                                       //Added by Babita Dadarwal under ER-1940  on 18 July 2016 End
                                                       Geo_Level__c,
                                                       Commercial_Manager_Email__c
                                                from IMS_Secondary_Data_Assets__r
                                                where Is_Active__c = True
                                                order by Display_Order__c, Secondary_Asset_Name__c)
                                         from IMS_Data_Asset__c
                                         where BU__c != null
                                         and Is_Active__c = True
                                         order by Other_for_Sorting_Display__c, Asset_Name__c];

            proposTree.secondaryDataAssetList = new map<id,IMS_Secondary_Data_Asset__c>([select id,
                                                                                                Secondary_Asset_Name__c,
                                                                                                //Added by Babita Dadarwal under ER-1940 on 18 July 2016 Start
                                                                                                English_Translation__c,
                                                                                                Japanese_Translation__c,
                                                                                                //Added by Babita Dadarwal under ER-1940  on 18 July 2016 End
                                                                                                Primary_Data_Asset__c,
                                                                                                Primary_Data_Asset__r.Asset_Name__c,
                                                                                                Primary_Data_Asset__r.Geo_Level__c,
                                                                                                Primary_Data_Asset__r.Id,
                                                                                                Primary_Data_Asset__r.BU__c, // Added by Neha Bansal under CR-11745
                                                                                                Primary_Data_Asset__r.Is_Restricted_Data__c,
                                                                                                Is_AMA_Required__c, // Added by Babita Dadrwal on 18 May 2016 uner ER-2812
                                                                                                Primary_Data_Asset__r.Is_IMS_AGProduct__c
                                                                                         from IMS_Secondary_Data_Asset__c
                                                                                         where Is_Active__c = True
                                                                                         order By Primary_Data_Asset__r.Asset_Name__c]);
            //Updated by Babita Dadarwal under ER-2516 End
            //Updated by Babita Dadarwal under ER-2106 End

            proposTree.tpaPurposeCategoryList = [select Id, Name, Category_Name__c, English_Translation__c, Japanese_Translation__c from TPA_Purpose_Category__c where isActive__c = true order By Category_Name__c]; //Updated by Babita Dadarwal under ER-1940  on 19 July 2016
            //Added By Neha Bansal under CR-11745 starts
            String key = '';
            for(IMS_Data_Asset__c masterOffObj : proposTree.dataAssetList){
                if(masterOffObj.IMS_Secondary_Data_Assets__r.size() > 0 ){
                    for(IMS_Secondary_Data_Asset__c secOff : masterOffObj.IMS_Secondary_Data_Assets__r){
                        key = masterOffObj.BU__c + ':' + masterOffObj.Geo_Level__c + ':' + masterOffObj.Asset_Name__c.toLowerCase() + ':' + secOff.Secondary_Asset_Name__c.toLowerCase();
                        if( !proposTree.MapOffGeolevelBUwithOffId.containsKey(key) ){
                            proposTree.MapOffGeolevelBUwithOffId.put(key, secOff.id);
                        }
                    }
                }
                else{
                    key = masterOffObj.BU__c + ':' + masterOffObj.Geo_Level__c + ':' + masterOffObj.Asset_Name__c.toLowerCase() + ':';
                    if(masterOffObj.Asset_Name__c != 'Other' && !proposTree.MapOffGeolevelBUwithOffId.containsKey(key) ){
                        proposTree.MapOffGeolevelBUwithOffId.put(key, masterOffObj.id);
                    }
                }
            }
            //Added By Neha bansal under CR-11745 starts
            Map<string,List<string>> MapOffWithlistOfCountry = new Map<string,List<string>>();
            String OffGeolevelkey = '';
            for(IMS_Data_Asset__c masterOffObj : proposTree.dataAssetList){
                if(masterOffObj.Asset_Name__c.startsWithIgnoreCase('OneKey Data - ')  ){ //12651
                    if(masterOffObj.IMS_Secondary_Data_Assets__r.size() > 0 ){
                        for(IMS_Secondary_Data_Asset__c secOff : masterOffObj.IMS_Secondary_Data_Assets__r){
                            OffGeolevelkey = masterOffObj.Geo_Level__c + ':' + 'onekey data - ' + ':' + secOff.Secondary_Asset_Name__c.toLowerCase();
                            if(!MapOffWithlistOfCountry.containsKey(OffGeolevelkey) ){
                                MapOffWithlistOfCountry.put(OffGeolevelkey, new list<String>{masterOffObj.BU__c});
                            }
                            else {
                                MapOffWithlistOfCountry.get(OffGeolevelkey).add(masterOffObj.BU__c);
                            }
                        }
                    }
                    else{
                        OffGeolevelkey = masterOffObj.Geo_Level__c + ':' + 'onekey data - ' + ':';
                        if(masterOffObj.Asset_Name__c != 'Other' && !MapOffWithlistOfCountry.containsKey(OffGeolevelkey) ){
                            MapOffWithlistOfCountry.put(OffGeolevelkey, new list<String>{masterOffObj.BU__c});
                        }
                        else if(masterOffObj.Asset_Name__c != 'Other' ){
                            MapOffWithlistOfCountry.get(OffGeolevelkey).add(masterOffObj.BU__c);
                        }
                    }
                }
            }

            for(String mapkey:  MapOffWithlistOfCountry.keySet())
                if(MapOffWithlistOfCountry.get(mapkey).size() <=1){
                    MapOffWithlistOfCountry.remove(mapkey);
                }
            proposTree.mapOfferingWithlistOfCountry = MapOffWithlistOfCountry;

            //Added By Neha bansal under CR-11745 Ends
        }
        return JSON.serialize(proposTree);
    }

    // Added by Vikram Singh under Issue-09610 Start
    public string getAmaDataTimePeriod()
    {
        List<string> requestedData = new List<string>();
        requestedData.add('--None--');
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.AMA_Howlong_SP_has_Data_Access__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.add(f.getLabel());
        }
        return JSON.serialize(requestedData);
    }
    // Added by Vikram Singh under Issue-09610 End

    public string getAmaFreqDeliveryData()
    {
        List<string> requestedData = new List<string>();
        requestedData.add('--None--');
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.FrequencyOfDeliveryToServiceProvider__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.add(f.getLabel());
        }
        return JSON.serialize(requestedData);
    }

    // Added by Babita Dadarwal under ER-2241 Start
    public string getDdtFreqDeliveryData()
    {
        List<string> requestedData = new List<string>();
        requestedData.add('--None--');
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.Frequency_Of_Delivery__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.add(f.getLabel());
        }
        return JSON.serialize(requestedData);
    }
    // Added by Babita Dadarwal under ER-2241 End

    public string getAMAlistValuesData()
    {
        Map<string, string> requestedData = new Map<string, string>();
        MAP<String,TPA_AMA_Picklist__c> data = TPA_AMA_Picklist__c.getAll();
        List<String> picklistValues = new List<String>();
        picklistValues.addAll(data.keySet());
        picklistValues.sort();
        for (String picklistValue : picklistValues)
        {
            TPA_AMA_Picklist__c AMAValue = data.get(picklistValue);
            requestedData.put(AMAValue.Picklist_value__c, AMAValue.Picklist_value__c);
        }
        return JSON.serialize(requestedData);
    }

    public string getAmaPrescLvlData()
    {
        Map<string, string> requestedData = new Map<string, string>();
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.AMA_TypeOfPrescriberLevelData__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.put(f.getLabel(), f.getLabel());
        }
        return JSON.serialize(requestedData);
    }

    public string getUsesWithCategoryMap()
    {
        String categoryAndUse = '';
        Map<String, String> usesWithCategoryMap = new Map<String, String>();
        List<TPA_Table_of_AMA_Use_And_Use_Category__c> listUseAndCategory = TPA_Table_of_AMA_Use_And_Use_Category__c.getall().values();
        for(TPA_Table_of_AMA_Use_And_Use_Category__c tabAma : listUseAndCategory){
            categoryAndUse = tabAma.IQVIA_Use_Category__c + ';' + tabAma.IQVIA_USE__c;
            usesWithCategoryMap.put(categoryAndUse, tabAma.Proposed_AMA_Use_to_Select__c);
        }
        return JSON.serialize(usesWithCategoryMap);
    }

 /*   public string getAmaResponseCollectionMeans()
    {
        Map<string, string> requestedData = new Map<string, string>();
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.AMA_HowResponseDataCollected__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        integer count = 1;
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.put(string.valueof(count), f.getLabel());
            count++;
        }
        return JSON.serialize(requestedData);
    }*/

  /*  public string getAmaPpdVariablesData()
    {
        Map<string, string> requestedData = new Map<string, string>();
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.AMA_PPDVariablesCollected__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        integer count = 1;
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.put(string.valueof(count), f.getLabel());
            count++;
        }
        return JSON.serialize(requestedData);
    }*/

     //Added By Babita Dadarwal under ER-2241 Start

    //Method to get data of the AMA question 'Chose any of the following that best describes your market research project:'
    /*public string getAmaMRAttributesList()
    {
        Map<string, string> requestedData = new Map<string, string>();
        MAP<String,TPA_AMA_Market_Research_Attributes_List__c> data = TPA_AMA_Market_Research_Attributes_List__c.getAll();
        List<String> picklistValues = new List<String>();
        picklistValues.addAll(data.keySet());
        picklistValues.sort();
        for (String picklistValue : picklistValues)
        {
            TPA_AMA_Market_Research_Attributes_List__c AMAValue = data.get(picklistValue);
            requestedData.put(AMAValue.AMA_Market_Research_Attributes__c, AMAValue.AMA_Market_Research_Attributes__c);
        }
        return JSON.serialize(requestedData);
    }*/

    //Method to get data of the AMA question 'Chose any of the following that best describes your distribution and mailing project:'
  /*  public string getAmaDMAttributesList()
    {
        Map<string, string> requestedData = new Map<string, string>();
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.AMA_Distribution_And_Mailing_Attributes__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        integer count = 1;
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.put(string.valueof(count), f.getLabel());
            count++;
        }
        return JSON.serialize(requestedData);
    }*/
    //Added By Babita Dadarwal under ER-2241 End

    

    

    

    public string getImsSoftwareData()
    {
        Map<string, string> requestedData = new Map<string, string>();
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.IMSSoftware__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        integer count = 1;
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.put(string.valueof(count), f.getLabel());
            count++;
        }
        return JSON.serialize(requestedData);
    }

    

    public string getLoggedInCurrentUser()
    {
        return JSON.serialize(currentLoggedInUser); //Modified by C.P.Pandey under Issue-7485
    }

    // Added by Neetu Bansal under ER-1810
    public string getVendorLoggedInUser()
    {
        return JSON.serialize(vendorCurrentUser);
    }

    public string getObjectTpaRequestToEdit()
    {
        return JSON.serialize(tpaRequestToEdit);
    }
	
	public string getclientandVendorCopies(){
        List<TPA_Contact__c> clientandVendorCopies = new List<TPA_Contact__c>();
        if(tpaRequestToEdit != null) {
            for(TPA_Contact__c conObj : tpaRequestToEdit.TPA_Request_Contacts__r){
                clientandVendorCopies.add(conObj);
            }
        }
        system.debug('clientandVendorCopies:' + clientandVendorCopies);
        return JSON.serialize(clientandVendorCopies);
    }

    public string getObjectExistedUsesAndAssets()
    {
        return JSON.serialize(existedUsesAndAssetsData);
    }
@remoteAction
    global static string validateControlNumberAuthSigner(string argument)
    {
        try {
            controlNumberAuthSignerDetail objDetail = (controlNumberAuthSignerDetail)JSON.deserialize(argument, controlNumberAuthSignerDetail.class);
            if(UTL_Validate.isValidGuid(objDetail.GUID)) {
                UTL_LogFactory.GUID = objDetail.GUID; 
            }
            // todo TPAQueryHelper.setLogObject('', 'Vendor Account Registration Number Validation', (isTPProcessor || isUSTPProcessor)?'By TP Processor':'By Vendor');
            // todo TPAQueryHelper.logRef().generateLog();
            if(objDetail != null) {
                if(objDetail.getReqModeType() == clientRequestMode.RegistrationNumberCheck && objDetail.vendorRegistrationNumber != null && objDetail.vendorRegistrationNumber > 0)
                {
                    List<Address__c> accountListObj = [SELECT Id, Name, Vendor_Registration_Number__c, Street__c, Country__c, State__c, City__c, PostalCode__c FROM Address__c WHERE Vendor_Registration_Number__c =: objDetail.vendorRegistrationNumber and Is_Tpa_Account__c = true];
                    if(accountListObj == Null || accountListObj.size() == 0){
                        return statusType.VendorRegistrationNumberNotExisted.name();
                    }
                    string vendorProvidedFirstWord;
                    string existedFirstWord;
                    if(truncateTrailingSpecialCharacters(objDetail.vendorName.split(' ')[0].trim()) == 'the' && objDetail.vendorName.split(' ').size() > 1)
                    {
                        if(objDetail.vendorName.split(' ')[1] == null || objDetail.vendorName.split(' ')[1].trim().length() == 0){
                            return statusType.VendorRegistrationNumberNotExisted.name();
                        }
                        vendorProvidedFirstWord = 'The ' + truncateTrailingSpecialCharacters(objDetail.vendorName.split(' ')[1]);
                    }
                    else{
                        vendorProvidedFirstWord = truncateTrailingSpecialCharacters(objDetail.vendorName.split(' ')[0]);
                    }
                    if(truncateTrailingSpecialCharacters(accountListObj[0].Name.split(' ')[0].trim()) == 'the') {
                        if(accountListObj[0].Name.split(' ')[1] == null || accountListObj[0].Name.split(' ')[1].trim().length() == 0){
                            return statusType.VendorRegistrationNumberNotExisted.name();
                        }
                        existedFirstWord = 'The ' + truncateTrailingSpecialCharacters(accountListObj[0].Name.split(' ')[1]);
                    }
                    else{
                        existedFirstWord = truncateTrailingSpecialCharacters(accountListObj[0].Name.split(' ')[0]);
                    }
                    if(vendorProvidedFirstWord != existedFirstWord){
                       return statusType.RegistrationNumberAccountNotMatched.name();
                    }
                    List<Contact> contObj = [SELECT Account.Name, Account.Id, Id, Name, Email, Authorized_TPA_Signer__c FROM Contact WHERE Account.Id =: accountListObj[0].Id and Email =: objDetail.contactEmail];

                    if(contObj != Null && contObj.size() > 0){
                        return (statusType.Valid.name()+'~'+contObj[0].Account.Id+'~'+contObj[0].Id);
                    }
                    else{
                        return (statusType.Valid.name()+'~'+accountListObj[0].Id+'~');
                    }
                }
                else {
                    objDetail.reqModeType = 'VendorAccountCheck';
                    return validateAccountContactAuthSigner(objDetail);
                }
            }
            return statusType.NullObject.name();
        }
        catch(Exception ex) {
            system.debug(LoggingLevel.ERROR, 'ERROR: '+ex.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::validateControlNumberAuthSigner', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            // todo TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            // todo TPAQueryHelper.setLogObject('', 'Exception: Vendor Account Registration Number Validation', ex.getmessage()+' Line:'+ex.getLineNumber(),'');
            // todo TPAQueryHelper.logRef().generateLog();
            return 'error:' + ex.getMessage();
        }
    }

    public static string validateAccountContactAuthSigner(controlNumberAuthSignerDetail reqObj) {
        try {
            List<Address__c> accntObj;
            List<Address__c> tmpAccntObj = new List<Address__c>();
            List<Address__c> accntContactListObj;
            if(reqObj.getReqModeType() == clientRequestMode.VendorAccountCheck) {
                set<string> countryCodeSet = createStateCountryNameSet(reqObj.vendorCountry, 'C');
                string vendorProvidedFirstWord;
                string existedFirstWord;
                String vendorAccountId = reqObj.vendorAccountId;

                vendorProvidedFirstWord = getTruncatedName(reqObj.vendorName);
                if(vendorProvidedFirstWord == null || vendorProvidedFirstWord.length() == 0){
                    return statusType.PotentialNewVendor.name();
                }
                
                system.debug('##vendorProvidedFirstWord::'+ vendorProvidedFirstWord);
                System.debug('##State passed from VF Page is::'+reqObj.vendorState);

                accntObj = [SELECT Name, Id FROM Address__c where Name like: ('%' + vendorProvidedFirstWord + '%') AND TPA_Address_Country__c in: countryCodeSet AND Is_TPA_Account__c = true];
                
                Integer numberOfMatch = 0;
                if(accntObj != null && accntObj.size() > 1) {
                    for(Address__c obj: accntObj) {
                        existedFirstWord = getTruncatedName(obj.Name.trim());
                        if(existedFirstWord == vendorProvidedFirstWord) {
                            numberOfMatch++;
                            tmpAccntObj.Add(obj);
                        }
                    }
                    accntObj = tmpAccntObj;
                }
                else if(accntObj != null && accntObj.size() == 1)
                {
                    existedFirstWord = getTruncatedName(accntObj[0].Name.trim());
                    if(existedFirstWord != vendorProvidedFirstWord){
                        return statusType.PotentialNewVendor.name();
                    }
                }
                
                if(accntObj == null || accntObj.size() == 0 || (accntObj.size() > 1 && (vendorAccountId == null || vendorAccountId.length() == 0))){//Modified by C.P.Pandey under CR-6453
                    return statusType.PotentialNewVendor.name();
                }
                
                if(accntObj.size() == 1)
                {
                    accntContactListObj = [SELECT Name, Id FROM Address__c where id =: accntObj[0].id];
                }
                
                else{
                    accntContactListObj = [SELECT Name,Id FROM Address__c WHERE id =: vendorAccountId]; //Modified by C.P.Pandey under Issue-6736
                    System.debug('Size of lis is::'+accntContactListObj .size());
                }
                if(accntContactListObj != Null && accntContactListObj.size() > 0){
                    return (statusType.Valid.name()+'~'+accntContactListObj[0].Id+'~'+accntContactListObj[0].name);
                }
                
            }
            if(reqObj.getReqModeType() == clientRequestMode.AuthorizedSignerCheck)
            {
                if(accntObj == null){
                    return statusType.PotentialNewVendor.name();
                }
                List<Contact> contactListObj = [SELECT Account.Name, Account.Id, Id, Name, Email, Authorized_TPA_Signer__c FROM Contact WHERE Account.Name like: (reqObj.vendorName.split(' ')[0] + '%') AND Email =: reqObj.authorizedSignerEmail];
                if(contactListObj == null || contactListObj.size() == 0){
                    return statusType.DifferentAuthorizedSignerContactAccount.name();
                }
                else
                {
                    return (statusType.Valid.name()+'~'+accntContactListObj[0].Id+'~'+accntContactListObj[0].Name);
                }
            }
            return '1';
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.ERROR, 'ERROR: '+ex.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_RequestSubmissionForm:::validateAccountContactAuthSigner', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            return ex.getMessage();
        }
    }

    
    

    public static string truncateTrailingSpecialCharacters(string word)
    {
        boolean specialCharacterExisted = true;
        string tempContainer;
        word = word.trim();
        integer wordLength = word.length();
        while(specialCharacterExisted && wordLength > 0)
        {
            tempContainer = '';
            tempContainer = word.substring(word.length()-1).replaceAll('[^a-zA-Z0-9]+','');
            if(tempContainer != null && tempContainer.length() > 0){
               specialCharacterExisted = false;
            }
            else{
                word = word.substring(0, word.length()-1);
            }
            wordLength--;
        }
        return word;
    }

    public static string getTruncatedName(string truncatedName)
    {
        truncatedName = truncatedName.trim();
        Set<String> charactersToBeTruncated = new Set<String> {
            ', inc', ',inc', ' inc', ' inc.', ',inc.', ', inc.', ', llc', ',llc', ' llc', ', llp', ',llp'
            , ' llp', ', corp' , ',corp', ' corp', ', lp', ',lp', ' lp', ', ltd', ',ltd' , ' ltd', ' ltd.'
            , ', ltd.', ',ltd.', ', l.p.', ',l.P.', ' l.p.', ' &co', ' & co' , '. co', '.co' , ' co.'
            , ' and company', ' pvt' , ' pvt.'
        };
        for(String truncatedCharacters: charactersToBeTruncated) {
            if(truncatedName.endsWithIgnoreCase(truncatedCharacters)) {
                truncatedName = truncatedName.removeEndIgnoreCase(truncatedCharacters).trim();
                truncatedName = truncatedName.removeEnd(',');
                
            }
        }
        Set<String> charactersToBeTruncatedFromStart = new Set<String> {
            'The ', 'the '
        };
        
        for(String truncatedCharacters: charactersToBeTruncatedFromStart) {
            if(truncatedName.startsWithIgnoreCase(truncatedCharacters)) {
                truncatedName = truncatedName.removeStartIgnoreCase(truncatedCharacters).trim();
                truncatedName = truncatedName.removeStart(',');
            }
        }
        system.debug('truncated name end' + truncatedName);
        return truncatedName;
    }


    public class controlNumberAuthSignerDetail
    {
        public Integer vendorRegistrationNumber {get; set;}
        public string vendorName {get; set;}
        public string vendorAddress {get; set;}
        public string vendorCountry {get; set;}
        public string vendorState {get; set;}
        public string vendorCity {get; set;}
        public string vendorPostal {get; set;}
        public string contactEmail {get; set;}
        public string authorizedSignerEmail {get; set;}
        public string vendorAccountId {get;set;}
        public string reqModeType {get; set;}
        public string authorizedSignerRequired {get; set;}
        public string GUID {get; set;}
        public clientRequestMode getReqModeType()
        {
            clientRequestMode result;
            for(clientRequestMode rmObj: clientRequestMode.values())
            {
                if(rmObj.name() == reqModeType)
                {
                    result = rmObj;
                    break;
                }
            }
            return result;
        }
    }

    
    public string getCountryList()
    {
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('TPA_Request__c');//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Vendor_Employee_Country_AMA__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add('--None--');//added by Govind under ER-2138
        for (Schema.PicklistEntry a : pick_list_values)
        { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return JSON.serialize(lstPickvals);
    }

    //*** Recently Updated by Govind Start Sprint 3 under ER-1558***//
     //*** Added by Govind under Issue-8960 Start ***//
    public string getAMALongestPeriodList()
    {
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('TPA_Request__c');//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get('AMA_Howlong_SP_has_Data_Access__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add('--None--');//added by Govind under ER-2138
        for (Schema.PicklistEntry a : pick_list_values)
        { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return JSON.serialize(lstPickvals);
    }
    //  public string getAMAResponseDataReturnList()
    // {
    //     List<String> lstPickvals = new List<String>();
    //     Schema.SObjectType targetType = Schema.getGlobalDescribe().get('TPA_Request__c');//From the Object Api name retrieving the SObject
    //     Sobject Object_name = targetType.newSObject();
    //     Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
    //     Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
    //     Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
    //     List<Schema.PicklistEntry> pick_list_values = field_map.get('AMA_RespDataAction__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
    //     lstPickvals.add('--None--');//added by Govind under ER-2138
    //     for (Schema.PicklistEntry a : pick_list_values)
    //     { //for all values in the picklist list
    //         lstPickvals.add(a.getValue());//add the value  to our final list
    //     }
    //     return JSON.serialize(lstPickvals);
    // }
    public string getRequestingCountryList()
    {
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('TPA_Request__c');//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Client_Contact_Territory__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add('--None--');//added by Govind under ER-2138
        for (Schema.PicklistEntry a : pick_list_values)
        { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return JSON.serialize(lstPickvals);
    }

    public string getRequestingForCountryList()
    {
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('TPA_Request__c');//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Secondary_Client_Contact_Territory__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add('--None--');//added by Govind under ER-2138
        for (Schema.PicklistEntry a : pick_list_values)
        { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return JSON.serialize(lstPickvals);
    }

    public string getVendorCountryList()
    {
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('TPA_Request__c');//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Vendor_Billing_Mailing_Country__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add('--None--');//added by Govind under ER-2138
        for (Schema.PicklistEntry a : pick_list_values)
        { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return JSON.serialize(lstPickvals);
    }
    public string getVendorStateList()
    {
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('TPA_Request__c');//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Vendor_Billing_Mailing_State_Province__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add('--None--');//added by Govind under ER-2138
        for (Schema.PicklistEntry a : pick_list_values)
        { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return JSON.serialize(lstPickvals);
    }
    public string getVendorComplianceCountryList()
    {
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('TPA_Request__c');//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Vendor_Compliance_Country__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add('--None--');//added by Govind under ER-2138
        for (Schema.PicklistEntry a : pick_list_values)
        { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return JSON.serialize(lstPickvals);
    }
    public string getVendorComplianceStateList()
    {
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('TPA_Request__c');//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Vendor_Compliance_State__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add('--None--');//added by Govind under ER-2138
        for (Schema.PicklistEntry a : pick_list_values)
        { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return JSON.serialize(lstPickvals);
    }
    public string getCountryOfOfferingsList()
    {
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('TPA_Request__c');//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Region__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add('--None--');//added by Govind under ER-2138
        for (Schema.PicklistEntry a : pick_list_values)
        { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return JSON.serialize(lstPickvals);
    }
    public string getOfferingProviderList()
    {
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('TPA_Request__c');//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Data_Provided_By__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add('--None--');//added by Govind under ER-2138
        for (Schema.PicklistEntry a : pick_list_values)
        { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return JSON.serialize(lstPickvals);
    }
    //*** Added by Govind under Issue-8960 End ***//

    //Added by C.P.Pandey under CR-9059 start
    
    
     
  
    

    @remoteAction
    public static List<Address__c> getAccountOnDomain(String countryName,String vLegalName)
    {
            countryName = (String)JSON.deserialize(countryName, String.class);
            vLegalName = (String)JSON.deserialize(vLegalName, String.class);
            vLegalName = vLegalName.replace('\\','');
            if(vLegalName == null || vLegalName.length() == 0){
                vLegalName = '@@$$@@$$QWE';
            }
            
            Set<String> setPossibleCountryCodes = new Set<String>();
            setPossibleCountryCodes = createStateCountryNameSet(countryName,'C');
            String vendorLegalName = '%'+vLegalName+'%';
            List <Address__c> lstVendorLookUp = new List<Address__c>();
            lstVendorLookUp = [select Id,Name,vendor_registration_number__c,TPA_Address_Street__c,TPA_Address_PostalCode__c,TPA_Address_City__c,TPA_Address_State__c,TPA_Address_Country__c,Street__c,PostalCode__c,City__c,State__c,Country__c,Is_TPA_Account__c,Is_AMA_Account__c from Address__c where  is_tpa_account__c = true and Primary_Vendor_Address__c = true and name like: vendorLegalName and Country__c in: setPossibleCountryCodes order by State__c,City__c]; //Modified by Govind under Issue-7683,ER-2672 //Modified by C.P.Pandey under ER-2261
            return lstVendorLookUp;
    }
    
    @remoteAction
    public static List<Address__c> getVendorAccount(String globalBrandingName)
    {
            //countryName = (String)JSON.deserialize(countryName, String.class);
            String gBrandingName = (String)JSON.deserialize(globalBrandingName, String.class);
            gBrandingName = gBrandingName.replace('\\','');
            if(gBrandingName == null || gBrandingName.length() == 0){
                gBrandingName = '@@$$@@$$QWE';
            }
            // String vendorLegalName = '%'+gBrandingName+'%';
            List <Address__c> lstVendorLookUp = new List<Address__c>();
            lstVendorLookUp = [select Id, 
                                      Name,
                                      vendor_registration_number__c,
                                      TPA_Address_Street__c,
                                      TPA_Address_PostalCode__c,
                                      TPA_Address_City__c,
                                      TPA_Address_State__c,
                                      TPA_Address_Country__c,
                                      Street__c,
                                      PostalCode__c,
                                      City__c,
                                      State__c,
                                      Country__c,
                                      Is_TPA_Account__c,
                                      Is_AMA_Account__c 
                               from Address__c 
                               where is_tpa_account__c = true 
                               and (Parent_Vendor_Name__c =: gBrandingName 
                                    OR Id =: gBrandingName)]; 
            return lstVendorLookUp;
    }
    
    public void setClientCountryDetails(String country){
        Set<String> USACountryCode =  UTL_TPA_Multilingual.getCountryStateCodeSet('C', 'USA');
        if(USACountryCode != null && USACountryCode.size() > 0){
          isClientFromUS = USACountryCode.contains(country.toLowerCase()) ? true : false;
          if(isClientFromUS){
            language = 'en_US';
          }
        }
    }
    //  Added by Vikram Singh under ER-3186 End

    

    public class existedUsesAndAssets {
        public Map<String, String> secDAToRemoveMap;
        public Map<String,wrapperClassAssetPurpose> wrapperPurpAssetListObject;
        public Map<String, integer> SelectedDescIndexMap {get;set;}
        public string selectedSecondaryIds {get;set;}
        public List<string> removedUses {get;set;} 
        public List<string> removedOfferings {get;set;} 
        public List<string> primaryOffNotToRemove {get;set;} 
        public List<String> usesMappedToAnother {get;set;} 
        public List<String> usesMappedToAnotherUse = new List<string>();
        public List<String> offeringUsesMappedToAnother {get;set;}
        public List<IMS_TPA_Purpose_Description__c> lstIMSTPADescription = new List<IMS_TPA_Purpose_Description__c>();
        public Map<Id,String> mapIdWithName = new Map<Id,string>();
        public Map<String,TPA_Purpose__c> PurposeMapOther {get;set;}
        public Map<String,TPA_Purpose__c> PurposeMap {get;set;}
        public Map<String,TPA_Purpose_Description__c> MapPurpDescOther {get;set;}
        public Map<String,TPA_Purpose_Description__c> MapPurpDesc {get;set;}
        
        //Map - Map of all primary data assets selected under a particular purpose/use
        //Key - IMS_tpa_purpose_Id : Purpose_category_Id : country :  (For Non 'Other' Use)
        //Key -  : country : Purpose_category_Id : other_Use_decs   (For 'Other' Use)
        //Value - set of all primary data assets selected under a particular purpose/use
        public Map<String,set<TPA_Data_Asset__c>> mapPurposeidWithDataAssetMap {get;set;}

        //Map - Map of all secondary data assets selected under a particular purpose/use
        //Key - IMS_data_asset_Id : IMS_tpa_purpose_Id : Purpose_category_Id : country :  (For Non 'Other' Use)
        //Key - IMS_data_asset_Id :: Purpose_category_Id : country : Other_Use_Decs (For 'Other' Use)
        //Value - set of all secondary data assets selected under a particular purpose/use
        public Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetToInsert {get;set;}
        
        public string commDataAsset {get;set;}
        public integer index {get;set;}
        public boolean isAmaTab {get;set;}
        
        public existedUsesAndAssets() {
            PurposeMapOther = new Map<String,TPA_Purpose__c>();
            MapPurpDescOther = new Map<String,TPA_Purpose_Description__c>();
            PurposeMap = new Map<String,TPA_Purpose__c>();
            MapPurpDesc = new Map<String,TPA_Purpose_Description__c>();
            mapPurposeidWithDataAssetMap = new Map<String,set<TPA_Data_Asset__c>>();
            mapSecondayDataAssetToInsert = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
            secDAToRemoveMap = new Map<String, String>();
            wrapperPurpAssetListObject = new Map<String,wrapperClassAssetPurpose>();
            SelectedDescIndexMap = new Map<String, integer>();
            selectedSecondaryIds = '';
            removedUses = new List<string>(); 
            removedOfferings = new List<string>(); 
            primaryOffNotToRemove = new List<string>(); 
            usesMappedToAnother = new List<string>(); 
            usesMappedToAnotherUse = new List<string>();
            offeringUsesMappedToAnother = new List<string>(); 
            lstIMSTPADescription = new List<IMS_TPA_Purpose_Description__c>();
            mapIdWithName = new Map<Id,string>();
        }
    }

    public class tpaRequestDetails {
        public Boolean isPublicPrivateChangeOnly{get;set;}
        public Boolean isVendorContactInvited{get;set;}
        public Boolean isOnlyReferenceDataCatSelected {get;set;}
        public Contact invitedContact{get;set;}
        public TPA_Request__c tpaRequest {get; set;}
        public String processedLanguage {get;set;}
        public string requestTypeSubmitted {get; set;}
        public AMA_Agreement_Detail__c amaAgrSubmitted {get; set;} //CR-12673
        public List<TPA_Contact__C> tpaAdditionalContactList{get;set;}
        public List<TPA_Contact__C> tpaAdditionalVendorContactList{get;set;}
        public List<TPA_Contact__C> tpaSubContractors{get;set;}
        public string vendorName {get; set;}
        public string vendorContactName {get; set;}
        public string useOffBackupIds {get; set;}
        public string GUID {get; set;}
        public string bulkCSVFileBody {get; set;}
        public string bulkCSVFileName {get; set;}
        public string authorizedSignerResponse {get;set;}
        public List<IMS_TPA_Purpose_Category__c> categorypurposesList{get;set;}
        public Map<String, WrapperClass> SelectedDescMap {get;set;}
        public List<IMS_TPA_Purpose_Description__c> secondarypurpose{get;set;}
        public Map<String,TPA_Purpose__c> PurposeMapOther {get;set;}
        public Map<String,TPA_Purpose_Description__c> MapPurpDescOther {get;set;}
        public Map<String,TPA_Purpose__c> PurposeMap {get;set;}
        public Map<String,TPA_Purpose_Description__c> MapPurpDesc {get;set;}
        public Map<String,set<TPA_Data_Asset__c>> mapPurposeidWithDataAssetMap {get;set;}
        public Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetToInsert {get;set;}
        public String clientAddress { get;set; }
        public String parentRequestOfferingDetails { get;set; }
        public String parentRequestCategoryDetails { get;set; }
        public String parentRequestOffCountryDetails { get;set; }
        public String parentRequestUseDetails { get;set; }
        //public String ExcludedOfferingDetails { get;set; }
        public String isRenewedReqUseandOfferingChanged {get;set;}
    }

    public class wrapperClassAssetPurpose {
        public string categoryName {get;set;}
        public string translatedCategoryName {get;set;}
        public string otherPurposeId {get;set;}
        public string Param_otherDesc {get;set;}
        public string purposeName {get;set;}
        public string translatedPurposeName {get;set;}
        public string purposeId {get;set;}
        public string dataAsset {get;set;}
        public string dataAssetBackground {get;set;}
        public string translatedDataAsset {get;set;}
        public string country {get;set;}
        public string selectDes {get;set;}
        public boolean isUseDefinitionfileExist {get;set;}
        public string selectdataAssDetails {get;set;}
        public string purposeCategoryId {get;set;}
        public string useDefinitionPage {get;set;}
        public string key {get;set;}
        public string selectedPurposeIds {get;set;}
        public string dataAssetsInViewMode {get;set;}
        public string translatedDataAssetsInViewMode {get;set;}
        public string offeringCategoryName {get;set;}
        public string translatedOfferingCategoryName {get;set;}
        public string selectdataAssforOfferingAdditionDetails {get;set;}
    }

    public class WrapperClass {
        public String dataAsset {get;set;}
        public String categoryName {get;set;}
        public String purposeName {get;set;}
        public String purposeId {get;set;}
        public String otherPurposeId{get;set;}
        public String country {get;set;}
        public String selectDes {get;set;}
        public String selectdataAssDetails {get;set;}
        public String key {get;set;} 
        public boolean isUseDefinitionfileExist {get;set;}
        public string offeringCategoryName {get;set;}
        public string translatedOfferingCategoryName {get;set;}
        public string selectdataAssforOfferingAdditionDetails {get;set;}
    }

    public static void getLimitsMessage() {
        System.debug('Limits.getLimitAggregateQueries - '+ Limits.getLimitAggregateQueries());
        System.debug('Limits.getCallouts - '+ Limits.getCallouts());
        System.debug('Limits.getLimitCallouts - '+ Limits.getLimitCallouts());
        System.debug('Limits.getCpuTime - '+ Limits.getCpuTime());
        System.debug('Limits.getLimitCpuTime - '+ Limits.getLimitCpuTime());
        System.debug('Limits.getDMLRows - '+ Limits.getDMLRows());
        System.debug('Limits.getLimitDMLRows - '+ Limits.getLimitDMLRows());
        System.debug('Limits.getDMLStatements - '+ Limits.getDMLStatements());
        System.debug('Limits.getLimitDMLStatements - '+ Limits.getLimitDMLStatements());
        System.debug('Limits.getEmailInvocations - '+ Limits.getEmailInvocations());
        System.debug('Limits.getLimitEmailInvocations - '+ Limits.getLimitEmailInvocations());
        System.debug('Limits.getFutureCalls - '+ Limits.getFutureCalls());
        System.debug('Limits.getLimitFutureCalls - '+ Limits.getLimitFutureCalls());
        System.debug('Limits.getHeapSize - '+ Limits.getHeapSize());
        System.debug('Limits.getLimitHeapSize - '+ Limits.getLimitHeapSize());
        System.debug('Limits.getMobilePushApexCalls - '+ Limits.getMobilePushApexCalls());
        System.debug('Limits.getLimitMobilePushApexCalls - '+ Limits.getLimitMobilePushApexCalls());
        System.debug('Limits.getQueries - '+ Limits.getQueries());
        System.debug('Limits.getLimitQueries - '+ Limits.getLimitQueries());
        System.debug('Limits.getQueryLocatorRows - '+ Limits.getQueryLocatorRows());
        System.debug('Limits.getLimitQueryLocatorRows - '+ Limits.getLimitQueryLocatorRows());
        System.debug('Limits.getQueryRows - '+ Limits.getQueryRows());
        System.debug('Limits.getLimitQueryRows - '+ Limits.getLimitQueryRows());
        System.debug('Limits.getQueueableJobs - '+ Limits.getQueueableJobs());
        System.debug('Limits.getLimitQueueableJobs - '+ Limits.getLimitQueueableJobs());
        System.debug('Limits.getSoslQueries - '+ Limits.getSoslQueries());
        System.debug('Limits.getLimitSoslQueries - '+ Limits.getLimitSoslQueries());
    
    }
    
}
