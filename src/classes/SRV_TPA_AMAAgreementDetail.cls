public without sharing class SRV_TPA_AMAAgreementDetail {
    public static TPA_Request__c tpaRequest;
    public static Boolean isAMAPerpetualAgreement_US_Only;
    public static List<TPA_AMA_Parent_Child_Account_Crosswalk__c> tpaParChildAccountObj;
    public static Map<String,String> reasonForAmaApprovalMap;
    //public static Boolean noManualReviewForTPA = false;
    public static Boolean includeAmaAttributesOnly = false;
    // Added By Neha Bansal under CR-12673 Starts
    public static Boolean IsForeignLicenseRequired = False;
    public static Boolean IsOffshoreAccessAmendmentReq = False;
    public static Boolean IsOffshoreAccessAmendmentFLReq = False;
    public static Boolean IsGenerateOffConsentForm = false;
    public static Boolean onlyClientReqOffAccess = false;
    public static Boolean isvendorStorageReq = false;
    public static Boolean IsOffAccessAmendmentReqWithNALoc = false;
    public static Decimal oldCurrentYearFee ;
    public static Decimal oldNextYearFee ;
    public static String oldContractType ;

    public static Boolean isvalidVendorAccessCountry = true;
    public static Boolean isvalidVendorStorageCountry = true;
    public static Boolean isPreAppTech = true;
    public static Boolean isAccessCountriesMatched = true;
    public static Boolean isLetterShopUseExist = true;


    // Added By Neha Bansal under CR-12673 Ends
    
    public static AMA_Agreement_Detail__c amaAgreementDetails;
    private static Boolean vendor_has_no_any_existing_license_with_client_listed = true;
    private static Boolean vendor_has_existing_license_with_client_listed = false;
    private static Boolean vendor_has_existing_license_with_different_client_listed = false;
    private static Boolean vendor_has_no_existing_license_with_any_client = true;
    public static Map<String,List<AMA_Contract_Detail__c>> vendor_has_existing_license_with_same_client = new Map<String,List<AMA_Contract_Detail__c>>();
    public static Map<String,List<AMA_Contract_Detail__c>> vendor_has_existing_license_with_other_client = new Map<String,List<AMA_Contract_Detail__c>>();
    public static Map<String,List<AMA_Contract_Detail__c>> vendor_has_existing_license_with_any_client = new Map<String,List<AMA_Contract_Detail__c>>();
    private static List<AMA_Contract_Detail__c> amaContractListForOwnBehalf;  
    private static Boolean maxFeesReached = false;
    private static Boolean hasOffshoreAccess = false;
    private static Set<String> offshoreLocations = new Set<String>();
    public static Map<String,Set<String>> dblValuesWithSameClient = new Map<String,Set<String>>();
    private static Map<String,Set<String>> dblValuesWithOtherClient = new Map<String,Set<String>>();
    private static Boolean isAmaLicenseRequired= false;
    private static Boolean amaManualReview = false;
    private static String contractTypeRequired = '';
    private static String vendorHasLicence = '';
    //private static Boolean generateAMALicense = false;
    private static Boolean isCilentValid = false;
    private static Boolean isSpecialLicensePresent= false;
    private static set<String> validVendorNameSet = new Set<String>();
    private static set<String> validClientNameSet = new Set<String>();
    private static List<TPA_AMA_Client_Vendor_Search_Map__c> searchMapList;
    private static List<String> scenariosSatisfiedDetails = new List<String>();
    public static Integer numberOfScenariosSatisfied = 0;
    private static Boolean notifyViaMail = false;
    private static Boolean calculateFeeForCurrentYear = true;
    private static Boolean checkIfExpired = true;
    private static Boolean isClientFromUS = false;
    
    private static final String LETTERSHOP = 'Lettershop';
    private static final String SERVICE_BUREAU_I = 'Service Bureau I';
    private static final String SERVICE_BUREAU_II = 'Service Bureau II';
    private static final String SERVICE_BUREAU_I_EOA = 'Service Bureau I EOA';
    private static final String CONTRACT_SALESFORCE = 'Contract Sales Force';
    private static final String PHYSICIAN_SPECIFIC_ANALYSIS = 'Physician Specific Analysis';
    private static final String PHYSICIAN_SPECIFIC_ANALYTIC = 'Physician Specific Analytics';
    private static final String MEDICAL_DIAGNOSIS_EQUIPMENT_SUPPLY = 'Medical/Diagnostic Equipment & Supply';
    private static final String CSF_AMENDMENT = 'CSF Amendment';  
    private static final String SBII_AMENDMENT = 'SBII Amendment';  
    private static final String PSA_SERVICE_BUREAU = 'PSA - Service Bureau';
    private static final String SBII_EXUS_ENTITY_FOREIGN = 'SBII ExUS Entity Foreign License';
    private static final String SBI_EXUS_ENTITY_FOREIGN = 'SBI ExUS Entity Foreign License';
    private static final String LS_EXUS_ENTITY_FOREIGN = 'LS ExUS Entity Foreign License';
    private static final String OFFSHORE_ACCESS_AMEDNDMENT = 'Offshore Access Amendment'; // added by Neha Bansal CR-12673
    private static final String OFFSHORE_ACCESS_AMEDNDMENT_TO_FL = 'Offshore Access Amendment to Foreign License'; // added by Neha Bansal CR-12673
    private static final String FOREIGN_LICENSE = 'Foreign License'; // added by Neha Bansal CR-12673
    
    private static final String HEALTHCARE_PROVIDER = 'Healthcare Provider';
    private static final String SBI_EO_For_Amgen = 'SB I Evaluation Overlap for Amgen';  
    private static final String DATABASE_LICENSEE = 'Database Licensee';  
    
    private static Set<String> offshoreLocationSet = new Set<String>();
    // Added By Neha Bansal under CR-12673 Starts
    public static map<string,string> mapCountryCodeWithName = new map<string,string>();
    public static map<string,string> mapCountryCodeName{
        get{
            if(mapCountryCodeName == null){
                mapCountryCodeName =  new map<string,string>();
                for(TPA_Country_Codes__c tpaCountryCode: [Select id,Name,Country_Possible_Codes__c from TPA_Country_Codes__c where Code_Type__c ='C']) {
                    mapCountryCodeWithName.put(tpaCountryCode.Name.toLowerCase(), tpaCountryCode.Country_Possible_Codes__c.toLowerCase());
                    Boolean nameAdded = false;
                    list<String> codeValues = tpaCountryCode.Country_Possible_Codes__c.split(';');
                    for(String codeSingle : codeValues){
                        mapCountryCodeName.put(codeSingle.toLowerCase(),tpaCountryCode.Name);
                        if(codeSingle.toLowerCase() == tpaCountryCode.Name.toLowerCase()) {
                            nameAdded = true;
                        }
                    }
                    if(!nameAdded) {
                        mapCountryCodeName.put(tpaCountryCode.Name.toLowerCase(),tpaCountryCode.Name);
                    }
                }
            }
            return mapCountryCodeName;
        }
        private set{mapCountryCodeName = value;}
    }

    // Added By Neha Bansal under CR-12673 Ends

    public static Boolean isRunCommercialAutoLogic {
        get {
            TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
            if( tpaCustomSettings.Enable_Commercial_Review_Automation__c && tpaRequest != null && 
                ((tpaRequest.is_Bulk_TPA_Request__c && tpaCustomSettings.Enable_Comm_Auto_for_Bulk_Requests__c) 
                  || !tpaRequest.is_Bulk_TPA_Request__c) 
              ){
                return true;
            }
            return false;
        }
        set;
    }
    
    public static DateTime latestAMAContractDate;
    public static DateTime recentAMAContractDate(){
        if(latestAMAContractDate == null){
            latestAMAContractDate = [SELECT id, CreatedDate FROM AMA_Contracts_Attachments__c ORDER BY CreatedDate DESC LIMIT 1]?.CreatedDate;
        }
        return latestAMAContractDate;
    }
    
    public static TPA_Request__c validateFunctionalRequirements(String requestJSON) {
        
        //Deserializing object TPA Request from TPA Request JSON String
        TPA_Request__c request = (TPA_Request__c)JSON.deserialize(requestJSON, TPA_Request__c.class);
        tpaRequest = request ;
        System.debug('**********JSON to TPA Request converted**'+request);
        if(request.AMA_Agreement_Details__r != null && request.AMA_Agreement_Details__r.size() > 0){
            Id amaId = request.AMA_Agreement_Details__r[0].id;
           // amaAgreementDetails = request.AMA_Agreement_Details__r[0];
            amaAgreementDetails = [Select id,Name,Ex_Client__c,Ex_Client_Services_On_Behalf_Of__c, Ex_Offshore_Access__c,
            Agreement_Start_Date__c,Agreement_End_Date__c,Ex_US_Foreign_Affiliate_of_TPA_Vendor__c,
            Is_Prorated__c,Fee_Reduced__c,TPA_Request__c,Vendor_Legal_Name__c,Client__c,Contract_Type__c,Current_Year_Fees__c,
            Next_Year_Fees__c,DBL__c,Current_Year__c,Ex_Contract_End_Date__c,Final_End_Year__c,Next_Year__c,Client_AMA_Manually_Validated__c,
            Ex_Contract_Type__c,Max_Fee_Reached__c,Is_AMA_License_Required__c,AMA_Manual_Trigger_Reasons__c,
            AMA_Manual_Review__c,Number_Of_Scenarios_Satisfied__c,Scenarios_Satisfied_Details__c,
            FrequencyOfDeliveryToServiceProvider__c,AMA_TypeOfPrescriberLevelData__c,AMA_Howlong_SP_has_Data_Access__c,
            AMA_Services_Provided__c,Client_req_Storage_Permission_from_NonUS__c, Client_Employee_Store_Data_in_country__c, 
            Vendor_require_Remote_Access_from_NonUS__c,Vendor_Employee_Accessed_Data_in_country__c,Vendor_req_Storage_Permission_from_NonUS__c, 
            Vendor_Employee_Store_Data_in_country__c, Technology_s_selected_for_remote_access__c,Other_Technology_for_Remote_Access__c,
            Ex_US_Entity_Authorized_Signer_FName__c,Ex_US_Entity_Authorized_Signer_LName__c,Ex_US_Entity_Authorized_Signer_Title__c,
            Ex_US_Entity_Authorized_Signer_Email__c,Ex_US_Legal_Entity_Name_Offshore_Storage__c,Ex_US_Legal_Entity_Name_Remote_Access__c,
            Off_Access_Legal_Entity_Street__c,Off_Access_Legal_Entity_State__c,Off_Access_Legal_Entity_Country__c,
            Off_Access_Legal_Entity_City__c,Off_Access_Legal_Entity_Zip__c,Off_Storage_Legal_Entity_Country__c,
            Off_Storage_Legal_Entity_City__c,Off_Storage_Legal_Entity_Street__c,Off_Storage_Legal_Entity_State__c,
            Off_Storage_Legal_Entity_Zip__c,Vendor_AMA_Fee_Response__c,TPA_Request__r.Service_Provider_Address__r.Has_AMA_Perpetual_Agreement_U_S_Only__c, Is_Offshore_Access_Amendment_Required__c  from AMA_Agreement_Detail__c where Id =: amaId];
            if(amaAgreementDetails.Current_Year_Fees__c != null){
                oldCurrentYearFee = amaAgreementDetails.Current_Year_Fees__c;
            }
            if(amaAgreementDetails.Next_Year_Fees__c != null){
                oldNextYearFee = amaAgreementDetails.Next_Year_Fees__c;
            }
            if(amaAgreementDetails.Contract_Type__c != null){
                oldContractType = amaAgreementDetails.Contract_Type__c;
            }
        }else{
            amaAgreementDetails = [Select id,Name,Ex_Client__c,Ex_Client_Services_On_Behalf_Of__c, Ex_Offshore_Access__c,
            Agreement_Start_Date__c,Agreement_End_Date__c,Ex_US_Foreign_Affiliate_of_TPA_Vendor__c,
            Is_Prorated__c,Fee_Reduced__c,TPA_Request__c,Vendor_Legal_Name__c,Client__c,Contract_Type__c,Current_Year_Fees__c,
            Next_Year_Fees__c,DBL__c,Current_Year__c,Ex_Contract_End_Date__c,Final_End_Year__c,Next_Year__c,Client_AMA_Manually_Validated__c,
            Ex_Contract_Type__c,Max_Fee_Reached__c,Is_AMA_License_Required__c,AMA_Manual_Trigger_Reasons__c,
            AMA_Manual_Review__c,Number_Of_Scenarios_Satisfied__c,Scenarios_Satisfied_Details__c,
            FrequencyOfDeliveryToServiceProvider__c,AMA_TypeOfPrescriberLevelData__c,AMA_Howlong_SP_has_Data_Access__c,
            AMA_Services_Provided__c,Client_req_Storage_Permission_from_NonUS__c, Client_Employee_Store_Data_in_country__c, 
            Vendor_require_Remote_Access_from_NonUS__c,Vendor_Employee_Accessed_Data_in_country__c,Vendor_req_Storage_Permission_from_NonUS__c, 
            Vendor_Employee_Store_Data_in_country__c, Technology_s_selected_for_remote_access__c,Other_Technology_for_Remote_Access__c,
            Ex_US_Entity_Authorized_Signer_FName__c,Ex_US_Entity_Authorized_Signer_LName__c,Ex_US_Entity_Authorized_Signer_Title__c,
            Ex_US_Entity_Authorized_Signer_Email__c,Ex_US_Legal_Entity_Name_Offshore_Storage__c,Ex_US_Legal_Entity_Name_Remote_Access__c,
            Off_Access_Legal_Entity_Street__c,Off_Access_Legal_Entity_State__c,Off_Access_Legal_Entity_Country__c,
            Off_Access_Legal_Entity_City__c,Off_Access_Legal_Entity_Zip__c,Off_Storage_Legal_Entity_Country__c,
            Off_Storage_Legal_Entity_City__c,Vendor_AMA_Fee_Response__c,Off_Storage_Legal_Entity_Street__c,Off_Storage_Legal_Entity_State__c, Is_Offshore_Access_Amendment_Required__c,
            Off_Storage_Legal_Entity_Zip__c,TPA_Request__r.Service_Provider_Address__r.Has_AMA_Perpetual_Agreement_U_S_Only__c   from AMA_Agreement_Detail__c where TPA_Request__c =: request.id];

        }
        
        if(!SRV_TPA_TPARequest.retriggerManualReviewEmail && !SRV_TPA_TPARequest.istriggerManualReviewReasonsOnly){
            resetAllAmaAgreementDetail (); 
        }    
        
        System.debug('amaAgreementDetails: '+amaAgreementDetails);
        System.debug('amaAgreementDetails: '+request.Data_Access_Start_Date__c );
        
        String clientName = request.Client_Address__r.Name;
        String vendorName = request.Service_Provider_Address__r.Name;
        String clientId = request.Client_Address__c;
        String vendorId = request.Service_Provider_Address__c;
        String globalBrandingVendorId = null;
        Set<String> clientNameSet = new Set<String>();
        Boolean isClientAccountValid = false;
        Boolean isVendorAccountValid = false;
        Boolean clientValidButExpiredContract =  false;
        Boolean specialuseWithSpecialClientID = false; 
        Boolean specialuse = false; 
        Boolean isAMADatabaseLicensee = request.Service_Provider_Address__r.AMA_Database_Licensee__c; // added by supriya johari under ER-4020
        isAMAPerpetualAgreement_US_Only = amaAgreementDetails.TPA_Request__r.Service_Provider_Address__r.Has_AMA_Perpetual_Agreement_U_S_Only__c; // added by supriya johari under ER-4020

        Boolean isSpecialUseEngArch = false;
        Set<id> vendorFamilyIds = new Set<id>();
        if(request.Service_Provider_Address__c != null && request.Service_Provider_Address__r.Parent_Vendor_Name__c != null ){
            vendorFamilyIds = UTL_TPA.getFamilyIds(request.Service_Provider_Address__r.Parent_Vendor_Name__r.id);
        }
        else if(request.Service_Provider_Address__c != null && request.Service_Provider_Address__r.Primary_Vendor_Address__c == true){
            vendorFamilyIds = UTL_TPA.getFamilyIds(request.Service_Provider_Address__r.id);
        }
        else
            vendorFamilyIds.add(request.Service_Provider_Address__r.id);

        
        if(tpaParChildAccountObj == null)
            tpaParChildAccountObj = [Select id, Child_Account_Address__c, Parent_Account_Address__c from TPA_AMA_Parent_Child_Account_Crosswalk__c where Child_Account_Address__c=:clientId OR Child_Account_Address__c in : vendorFamilyIds];
        Set<Id> parAccoToSearchSet = new Set<Id>();
        Set<Id> vendorAccoToSearchSet = new Set<Id>();
        Map<Id , Id> parAccoToSearchSetMap = new Map<Id, Id>();
        for(TPA_AMA_Parent_Child_Account_Crosswalk__c parChildObj: tpaParChildAccountObj)
        {
            parAccoToSearchSet.add(parChildObj.Parent_Account_Address__c);
            if(clientId == parChildObj.Child_Account_Address__c){
                parAccoToSearchSetMap.put(clientId, parChildObj.Parent_Account_Address__c);
                system.debug('Parent Account from set: first IF ');
            }
            else{
                parAccoToSearchSet.add(clientId);
            }

            for(Id id : vendorFamilyIds){
                if(id == parChildObj.Child_Account_Address__c){
                    vendorAccoToSearchSet.add(parChildObj.Parent_Account_Address__c);
                }
                else{
                    parAccoToSearchSet.add(id);
                    vendorAccoToSearchSet.add(id);
                }
            }

        }
        
            
        if(searchMapList == null)
        {
            if(parAccoToSearchSet.size() > 0)
                searchMapList = [Select id, AMA_Account_Search_Text__c, TPA_Account_Address__c,TPA_Account_Address__r.id From TPA_AMA_Client_Vendor_Search_Map__c where TPA_Account_Address__c IN :parAccoToSearchSet];
            else
                searchMapList = [Select id, AMA_Account_Search_Text__c, TPA_Account_Address__c,TPA_Account_Address__r.id From TPA_AMA_Client_Vendor_Search_Map__c where TPA_Account_Address__c = :clientId OR TPA_Account_Address__c in :vendorFamilyIds ];
        }

        system.debug('Parent Account from set:  '+parAccoToSearchSet);
        system.debug('Search Map List:  '+searchMapList);
        
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();
        String specialUsewithClientID = tpaCustomSettings.Manual_Review_For_Special_Client_And_Use__c;
        List<String> idAndUseList = specialUsewithClientID.split('~');

        if(parAccoToSearchSetMap.containsKey(clientId))
            validateClientAccount(parAccoToSearchSetMap.get(clientId));
        else
            validateClientAccount(clientId);
        
        if(idAndUseList.get(0)!= null && idAndUseList.get(1)!= null && amaAgreementDetails.AMA_Services_Provided__c!= null &&
           idAndUseList.get(0).contains(clientId.substring(0,15)) && amaAgreementDetails.AMA_Services_Provided__c.equalsIgnoreCase(idAndUseList.get(1)) && amaAgreementDetails.Next_Year__c != null && integer.valueof(amaAgreementDetails.Current_Year__c) < UTL_TPA.YEAR_2019) {
            specialuseWithSpecialClientID = true;
            isClientAccountValid = true; 
            isCilentValid =  true; 
        }
        else if(idAndUseList.get(0)!= null && idAndUseList.get(1)!= null && amaAgreementDetails.AMA_Services_Provided__c!= null &&
                !(amaAgreementDetails.AMA_Howlong_SP_has_Data_Access__c.equalsIgnoreCase('Greater than 90 days')) &&
                amaAgreementDetails.AMA_Services_Provided__c.equalsIgnoreCase(idAndUseList.get(1)) && amaAgreementDetails.Next_Year__c != null && integer.valueof(amaAgreementDetails.Current_Year__c) >= UTL_TPA.YEAR_2019 ){
                    specialuse = true;
                    isClientAccountValid = true;
                    isCilentValid =  true;
                }
        else {
           
            
            if(!validClientNameSet.isEmpty()) {
                isClientAccountValid = true;
                clientNameSet = validateClientHavingContract();
            }
            
            if(clientNameSet.isEmpty())
                clientValidButExpiredContract = true;
            
            if(amaAgreementDetails.Client_AMA_Manually_Validated__c){
                removeReason( tpaRequest, UTL_TPA.CLIENT_DOES_NOT_HAVE_AMA_AGREEMENT);
                removeReason( tpaRequest, UTL_TPA.CLIENTS_AMA_AGREEMENT_IS_EXPIRED);
                clientValidButExpiredContract = false;
                isCilentValid = true;
            }
            
        }

        Boolean isGBVendorAccountValid = false;

        system.debug('vendorAccoToSearchSet: '+vendorAccoToSearchSet);
        system.debug('vendorFamilyIds: '+ vendorFamilyIds);

        if(vendorAccoToSearchSet != null && vendorAccoToSearchSet.size() > 0)
            isVendorAccountValid = validateVendorAccount(vendorAccoToSearchSet);
        else    
            isVendorAccountValid = validateVendorAccount(vendorFamilyIds);

        
        system.debug('vendor account valid: '+isVendorAccountValid);
        system.debug('Client account valid: '+isClientAccountValid);
        
        if(reasonForAmaApprovalMap == null)
            reasonForAmaApprovalMap = new map<String,String>();
        
        if(isClientAccountValid && isVendorAccountValid) {
            if((isCilentValid && !clientValidButExpiredContract) || SRV_TPA_TPARequest.isOnekeySelectOfferingPresent) {
                if(specialuseWithSpecialClientID) {
                    
                    scenariosSatisfiedDetails.add('Amgen USA requires special template');
                    numberOfScenariosSatisfied++;
                    vendor_has_no_existing_license_with_any_client = true;
                    
                    //The system shall select a Contract type of SBI EOA.
                    isAmaLicenseRequired = true;
                    contractTypeRequired = SBI_EO_For_Amgen;  
                    vendorHasLicence = 'has no existing Licence with AMA';
                    
                    //Update the Agreement record with the existing AMA license type, Fees and DBL that is covering the project.
                    amaAgreementDetails.Contract_Type__c = SBI_EO_For_Amgen;  
                    amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                    
                }
                else {
                    //To validate if vendor has existing license with AMA same client, different client or any client
                    getVendorExistingLicensesFromList(validClientNameSet,validVendorNameSet);
                    
                    //To find required ama contract type
                    findContracType(request);
                }
                system.debug('amaManualReview1:'+amaManualReview);

                
                if(amaAgreementDetails.AMA_Services_Provided__c != null && 
                (amaAgreementDetails.AMA_Services_Provided__c.toLowercase().indexOf(UTL_TPA.SpecialUseEngArch) != -1 || amaAgreementDetails.AMA_Services_Provided__c.toLowercase().indexOf('Other') != -1)){
                    isSpecialUseEngArch = true;
                    amaManualReview = true;
                    addReason(request,'AMA Contract Type cannot be determined');
                    addReasonCommercial(request, 'AMA Contract Type cannot be determined', null, null);
                    addAMAReason(amaAgreementDetails, 'AMA Contract Type cannot be determined');
                    reasonForAmaApprovalMap.put( System.Label.TPA_AMA_AMA_Contract_Type_cannot_be_determined_based_on_conditions,'AMA Contract Type cannot be determined based on conditions;This requires TP Processor manual handling to determine contract type;Determine AMA contract required' );
                    scenariosSatisfiedDetails.add('Condition 42');    
                }
                
                if(specialuse && !isSpecialLicensePresent ) { 
                    if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)){
                        resetBasicAmaAgreementDetail();
                        notifyViaMail = false;
                        String existingContractType = SERVICE_BUREAU_I;
                        vendor_has_existing_license_with_client_listed = true;
                        vendor_has_no_any_existing_license_with_client_listed = false;
                        List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                        AMA_Contract_Detail__c existingAMAContractDetailObj = getExistingContractDetail(existingAMAContractDetailList);
                        updatingExContractDetail(existingAMAContractDetailObj);
                        isAmaLicenseRequired = false;
                        numberOfScenariosSatisfied++;
                        amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                        contractTypeRequired = 'Existing Agreement';
                     //   amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                        vendorHasLicence = 'has existing licence with client listed on TPA form'; 
                        scenariosSatisfiedDetails.add('SBI Special Condition with Existing Agreement');
                    }
                    else{
                        resetBasicAmaAgreementDetail();
                        notifyViaMail = false;
                        scenariosSatisfiedDetails.add('SBI Special Condition');
                        numberOfScenariosSatisfied++;
                        vendor_has_no_existing_license_with_any_client = true;
                        isAmaLicenseRequired = true;
                        contractTypeRequired = SERVICE_BUREAU_I; 
                        vendorHasLicence = 'has no existing Licence with AMA';
                        amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_I;
                        amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                    }
                   
                }
                else if(amaAgreementDetails.Ex_US_Foreign_Affiliate_of_TPA_Vendor__c == false && amaAgreementDetails.Vendor_require_Remote_Access_from_NonUS__c == 'Yes'){                   
                        amaManualReview = true;
                        isAmaLicenseRequired = false;
                        addReason(request,'Ex-US legal entity not a foreign affiliate');
                        addReasonCommercial(request, 'Ex-US legal entity not a foreign affiliate', null, null);
                        addAMAReason(amaAgreementDetails, 'Ex-US legal entity not a foreign affiliate');
                        reasonForAmaApprovalMap.put( 'Ex-US legal entity not a foreign affiliate','Ex-US legal entity not a foreign affiliate;Ex-US legal entity for remote access not a foreign affiliate of '+amaAgreementDetails.Vendor_Legal_Name__c+';Advise the vendor and client that as the Ex-US legal entity is not a foreign affiliate of '+amaAgreementDetails.Vendor_Legal_Name__c+', the Ex-US legal entity cannot receive data under this TPA.  Separate TPA and AMA agreements will be required.  The vendor will need to advise the client accordingly and revise this TPA request to remove the remote access selection.' );
                }
                else{
                    if(vendor_has_existing_license_with_same_client.containsKey(CONTRACT_SALESFORCE) || getOwnBehalfListForVendor().keySet().contains(CONTRACT_SALESFORCE.toLowerCase())){
                        resetBasicAmaAgreementDetail();
                        notifyViaMail = false;
                        String existingContractType = CONTRACT_SALESFORCE;
                        vendor_has_existing_license_with_client_listed = true;
                        vendor_has_no_any_existing_license_with_client_listed = false;
                        List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.containsKey(CONTRACT_SALESFORCE) ? vendor_has_existing_license_with_same_client.get(existingContractType) : getOwnBehalfListForVendor().get(CONTRACT_SALESFORCE.toLowerCase());
                        AMA_Contract_Detail__c existingAMAContractDetailObj = getExistingContractDetail(existingAMAContractDetailList);
                        updatingExContractDetail(existingAMAContractDetailObj);
                        isAmaLicenseRequired = false;
                        numberOfScenariosSatisfied++;
                        amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                        //amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                        vendorHasLicence = 'has existing licence with client listed on TPA form'; 
                        scenariosSatisfiedDetails.add('Vendor has CSF Agreement with Same Client');
                    }
                }
 
               
                
                // modified by supriya johari under Issue-11574 ends
                if(numberOfScenariosSatisfied == 0  && !amaManualReview) {
                    system.debug('Point 42 covered.');
                    amaManualReview = true;
                    isAmaLicenseRequired = false;
                    addReason(request,'AMA Contract Type cannot be determined');
                    addReasonCommercial(request, 'AMA Contract Type cannot be determined', null, null);
                    addAMAReason(amaAgreementDetails, 'AMA Contract Type cannot be determined');
                    reasonForAmaApprovalMap.put( System.Label.TPA_AMA_AMA_Contract_Type_cannot_be_determined_based_on_conditions,'AMA Contract Type cannot be determined based on conditions;This requires TP Processor manual handling to determine contract type;Determine AMA contract required' );
                    scenariosSatisfiedDetails.add('Condition 42');
                }
                else if((numberOfScenariosSatisfied == 1 && !amaManualReview) || isSpecialUseEngArch) {
                    //--- Point 8 covered
                    if(amaAgreementDetails.Ex_Client__c != null && amaAgreementDetails.Ex_Client_Services_On_Behalf_Of__c != null && checkIfExpired
                       && (contractTypeRequired == CSF_AMENDMENT || contractTypeRequired == SBII_AMENDMENT || contractTypeRequired == CONTRACT_SALESFORCE || contractTypeRequired == SERVICE_BUREAU_I || contractTypeRequired == SERVICE_BUREAU_II) ) {// modified by supriya johari under ER-2847 and ER-2848
                           if(amaAgreementDetails.Ex_Contract_End_Date__c == null || amaAgreementDetails.Ex_Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() ) { // modified by Supriya Johari under Issue-08675
                               system.debug('Point 8a covered.');
                               scenariosSatisfiedDetails.add('Condition 8a');
                           } else if(amaAgreementDetails.Ex_Contract_End_Date__c.year() < amaAgreementDetails.Agreement_End_Date__c.year() ) { // modified by Supriya Johari under Issue-08675
                               isAmaLicenseRequired = true;
                               vendorHasLicence = 'has no existing Licence with AMA';
                               
                               system.debug('Point 8b covered.');
                               scenariosSatisfiedDetails.add('Condition 8b');
                               resetValuesforAMA();
                               //date endDateOfYear = date.newInstance(amaAgreementDetails.Agreement_Start_Date__c.year(), 12, 31);
                               system.debug('amaAgreementDetails.Ex_Contract_End_Date__c'+amaAgreementDetails.Ex_Contract_End_Date__c +'amaAgreementDetails.Contract_Type__c'+amaAgreementDetails.Contract_Type__c);
                               
                               if(amaAgreementDetails.Ex_Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_Start_Date__c.year()  && amaAgreementDetails.Contract_Type__c == 'Existing Agreement')
                               {
                                   calculateFeeForCurrentYear = false; //No fee would be calculated for current year
                               }
                               else if(amaAgreementDetails.Ex_Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_Start_Date__c.year() &&
                                       amaAgreementDetails.Ex_Contract_Type__c!= null && amaAgreementDetails.Ex_Contract_Type__c == CONTRACT_SALESFORCE
                                       && (contractTypeRequired == CONTRACT_SALESFORCE || contractTypeRequired == CSF_AMENDMENT )) // modified under ER-2848 and ER-2847 by supriya johari
                               {
                                   calculateFeeForCurrentYear = false; //already paid $36,000 annual fee since one exists already
                               }
                               else
                               {
                                   if((contractTypeRequired == SERVICE_BUREAU_II || contractTypeRequired == SBII_AMENDMENT) && maxFeesReached) // modified under ER-2848 and ER-2847 by supriya johari
                                   {
                                       calculateFeeForCurrentYear = false; 
                                   }
                                   else
                                   {
                                       calculateFeeForCurrentYear = true; 
                                   }
                               }
                               if(contractTypeRequired == CSF_AMENDMENT)
                                   amaAgreementDetails.Contract_Type__c = CSF_AMENDMENT; 
                               else if(contractTypeRequired == SBII_AMENDMENT)
                                   amaAgreementDetails.Contract_Type__c = SBII_AMENDMENT; 
                               else
                                   amaAgreementDetails.Contract_Type__c = contractTypeRequired;
                               amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                               
                           }
                       }
                    Boolean isvalidOffshoreCountry = true;
                    //--- Point 4,6a,6b,6c covered
                    if(request.AMA_USPrescriberData__c == 'Yes') {
                        findOffshoreCondition(request,amaAgreementDetails);

                        if(IsForeignLicenseRequired){
                            amaAgreementDetails.Is_Foreign_License_Required__c = true;
                        }
                        if(IsOffshoreAccessAmendmentReq){
                            amaAgreementDetails.Is_Offshore_Access_Amendment_Required__c = true;
                        }
                        if(IsOffshoreAccessAmendmentFLReq){
                            amaAgreementDetails.Is_Offshore_Access_Amendment_to_FL_Req__c = true;
                        }
                        if(IsGenerateOffConsentForm){
                            amaAgreementDetails.Is_Offshore_Consent_Form_Req__c = true;
                        }

                        if(IsOffAccessAmendmentReqWithNALoc){
                            amaAgreementDetails.Is_Off_Access_Amendment_Req_WithNALoc__c = true;
                        }  
                    }
                    
                    //--- Point 7a covered
                    if(maxFeesReached && vendor_has_existing_license_with_client_listed && contractTypeRequired == SERVICE_BUREAU_II ) { //To do with same client case need to be added
                        system.debug('Point 7a covered');
                        scenariosSatisfiedDetails.add('Condition 7a');
                    }
                }
                else if(numberOfScenariosSatisfied > 1) {
                    System.debug('Multiple Contract type Found');
                    //Reset AMA Agreement Detail and reset contract type Required and isAmaLicenseRequired and set amaManualReview , add reason and add in reasonForAmaApprovalMap
                    amaManualReview = true;
                    isAmaLicenseRequired = false;
                    contractTypeRequired = '';
                    resetAmaAgreementDetail ();
                    addReason(request,'Multiple AMA contracts types are TRUE');
                    addReasonCommercial(request, 'Multiple AMA contracts types are TRUE', null, null);
                    addAMAReason(amaAgreementDetails, 'Multiple AMA contracts types are TRUE');
                    reasonForAmaApprovalMap.put( System.Label.TPA_AMA_Multiple_AMA_contracts_types_resulted_in_TRUE,'Multiple AMA contracts types resulted in TRUE;This requires TP Processor manual handling to determine contract type;Determine AMA contract required' );
                    scenariosSatisfiedDetails.add('Multiple AMA contracts types resulted in TRUE');
                }
            } else if(!isCilentValid && !SRV_TPA_TPARequest.isOnekeySelectOfferingPresent){
                amaManualReview = true;
                isAmaLicenseRequired = false;
                addReason(request,UTL_TPA.CLIENT_DOES_NOT_HAVE_AMA_AGREEMENT);
                addReasonCommercial(request, UTL_TPA.CLIENT_DOES_NOT_HAVE_AMA_AGREEMENT, UTL_TPA.IQVIAClientAMAAdmin, null);
                addAMAReason(amaAgreementDetails, UTL_TPA.CLIENT_DOES_NOT_HAVE_AMA_AGREEMENT);
                reasonForAmaApprovalMap.put( System.Label.TPA_AMA_Client_does_not_have_an_AMA_Agreement_in_place,'Client does not have an AMA Agreement;IQVIA Client AMA Administrator to validate AMA Agreement on file. <br/><br/>Valid AMA Agreement was not found on the AMA Client Contract List (CCL) dated AMACCLDATE;Client AMA Administrator, please confirm if a valid client agreement is on file to permit AMA Data use. Please select Questions/Comments and provide details for any pending agreements or other relevant considerations' );
                system.debug('Client is Not Valid');
                scenariosSatisfiedDetails.add('Client does not have an AMA Agreement in place');
            } else if(clientValidButExpiredContract){
                amaManualReview = true;
                isAmaLicenseRequired = false;
                addReason(request,UTL_TPA.CLIENTS_AMA_AGREEMENT_IS_EXPIRED);
                addReasonCommercial(request, UTL_TPA.CLIENTS_AMA_AGREEMENT_IS_EXPIRED, UTL_TPA.IQVIAClientAMAAdmin, null);
                addAMAReason(amaAgreementDetails, UTL_TPA.CLIENTS_AMA_AGREEMENT_IS_EXPIRED);
                reasonForAmaApprovalMap.put( 'Client\'s ama agreement contract end date is less than the project end date.','Client\'s AMA agreement has expired;IQVIA Client AMA Administrator to validate AMA Agreement on file.<br><br>Client\'s ama agreement contract end date is less than the project end date.;Client AMA Administrator, please confirm if a valid client agreement is on file to permit AMA Data use. Please select Questions/Comments and provide details for any pending agreements or other relevant considerations.' );
                system.debug('Client\'s ama agreement contract end date is less than the project end date');
                scenariosSatisfiedDetails.add('Client\'s ama agreement contract end date is less than the project end date');
                
            }
        }
        else{
            amaManualReview = true;
            isAmaLicenseRequired = false;
            addReason(request,'Client/Vendor not found in AMA Crosswalk');
            addReasonCommercial(request, 'Client/Vendor not found in AMA Crosswalk', null, null);
            addAMAReason(amaAgreementDetails, 'Client/Vendor not found in AMA Crosswalk');
            scenariosSatisfiedDetails.add('Client/Vendor does not match in AMA Crosswalk Table');
            if(isClientAccountValid == false && isVendorAccountValid == false){
                system.debug('isClientAccountValid1**************isVendorAccountValid1'+isClientAccountValid+''+isVendorAccountValid);
                reasonForAmaApprovalMap.put( System.Label.TPA_AMA_Client_Vendor_does_not_match_in_AMA_Crosswalk_Table, 'Account does not match in AMA Crosswalk Table: '+clientName+', '+vendorName+';Add required mapping and re-run business rules; Request of TP-US@iqvia.com to perform this task and to advise when complete.' );
            }else
                if(isClientAccountValid == false){
                    system.debug('isClientAccountValid**************'+isClientAccountValid);
                    reasonForAmaApprovalMap.put( System.Label.TPA_AMA_Client_Vendor_does_not_match_in_AMA_Crosswalk_Table, 'Account does not match in AMA Crosswalk Table: '+clientName+';Add required mapping and re-run business rules; Request of TP-US@iqvia.com to perform this task and to advise when complete.' );
                }else
                    if(isVendorAccountValid == false){
                        system.debug('isVendorAccountValid**************'+isVendorAccountValid);
                        reasonForAmaApprovalMap.put( System.Label.TPA_AMA_Client_Vendor_does_not_match_in_AMA_Crosswalk_Table, 'Account does not match in AMA Crosswalk Table: '+vendorName+';Add required mapping and re-run business rules; Request of TP-US@iqvia.com to perform this task and to advise when complete.' );
                    }
        }
        
        if(isAmaLicenseRequired && (request.Client_Address__r.AMA_Special_Handling__c || request.Service_Provider_Address__r.AMA_Special_Handling__c)){
            amaManualReview = true;
            addReason(request,System.Label.TPA_AMA_AMA_Special_Handling);
            addReasonCommercial(request, System.Label.TPA_AMA_AMA_Special_Handling, null, null);
            addAMAReason(amaAgreementDetails, System.Label.TPA_AMA_AMA_Special_Handling);
            reasonForAmaApprovalMap.put(System.Label.TPA_AMA_AMA_Special_Handling,System.Label.TPA_AMA_AMA_Special_Handling_Manual_Review);
            scenariosSatisfiedDetails.add(System.Label.TPA_AMA_AMA_Special_Handling);
            
        }
        if(request.AMA_USPrescriberData__c == 'Yes' && amaAgreementDetails.Contract_Type__c != null && amaAgreementDetails.Contract_Type__c != 'Existing Agreement' && amaAgreementDetails.Contract_Type__c != 'Lettershop' &&  amaAgreementDetails.Contract_Type__c != 'Service Bureau I' && 
           ((request.Service_Provider_Address__r.Parent_Vendor_Name__c != null && request.Service_Provider_Address__r.Parent_Vendor_Name__r.AMA_Check_List__c == 'Y' && request.Service_Provider_Address__r.AMA_U_S_hold_status__c != null && request.Service_Provider_Address__r.AMA_U_S_hold_status__c == 'Prior collection issue' )
            || (request.Service_Provider_Address__r.Parent_Vendor_Name__c == null && request.Service_Provider_Address__r.AMA_Check_List__c == 'Y' && request.Service_Provider_Address__r.AMA_U_S_hold_status__c != null && request.Service_Provider_Address__r.AMA_U_S_hold_status__c == 'Prior collection issue'))) {
                system.debug('AMA_Check_List__c = ' + request.Service_Provider_Address__r.AMA_Check_List__c);
                request.Is_Manually_Approved__c = true;
                request.Manual_Trigger_Reasons__c += '; IQVIA Finance - Account On Hold List';
                addReasonCommercial(request, 'IQVIA Finance - Account On Hold List', null, null);
            }
        if(request.AMA_USPrescriberData__c == 'Yes'){
            Set<String> USACountryCode =  UTL_TPA_Multilingual.getCountryStateCodeSet('C', 'USA');
            system.debug('####SRV_TPA_AMAAgreementDetail USACountryCode: '+USACountryCode);
            if(USACountryCode != null && USACountryCode.size() > 0){
                system.debug('####SRV_TPA_AMAAgreementDetail request.Vendor_Billing_Mailing_Country__c.toLowerCase(): '+request.Vendor_Billing_Mailing_Country__c.toLowerCase());
                isClientFromUS = USACountryCode.contains(request.Vendor_Billing_Mailing_Country__c.toLowerCase()) ? true : false;
                system.debug('####SRV_TPA_AMAAgreementDetail isClientFromUS: '+isClientFromUS);
                if(!isClientFromUS){
                    amaManualReview = true;
                    addReason(request,System.Label.TPA_Vendor_location_not_in_the_United_States);
                    addReasonCommercial(request, System.Label.TPA_Vendor_location_not_in_the_United_States, null, null);
                    addAMAReason(amaAgreementDetails, System.Label.TPA_Vendor_location_not_in_the_United_States);
                    reasonForAmaApprovalMap.put(System.Label.TPA_Vendor_location_not_in_the_United_States,System.Label.TPA_AMA_Manual_Review_Reasons_for_Vendor_location_not_in_the_United_States);
                    scenariosSatisfiedDetails.add(System.Label.TPA_Vendor_location_not_in_the_United_States);
                }
            }
        }
        System.debug('**amaManualReview**'+amaManualReview+'**isAmaLicenseRequired**'+isAmaLicenseRequired);
        if(amaManualReview) {
            //--- Point 9 covered.
            notifyViaMail = false;
            system.debug('Point 9 covered.');
            scenariosSatisfiedDetails.add('Condition 9');
            amaAgreementDetails.AMA_Manual_Review__c = true;
            request.Is_Manually_Approved__c = true;
        }
        
        system.debug('reasonForAmaApprovalMap: ' + reasonForAmaApprovalMap);
        SRV_TPA_TPARequest.reasonForAmaApprovalMap = reasonForAmaApprovalMap;
        //If there is no TPA reason for manual review but AMA requires manual review
        if(reasonForAmaApprovalMap.size() > 0 && SRV_TPA_TPARequest.noManualReviewForTPA) {
            includeAmaAttributesOnly = true;
            SRV_TPA_TPARequest.includeAmaAttributesOnly = true;
        }
        //To set TPA Request status on the basis of TPA or AMA manual review reasons

        if(!SRV_TPA_TPARequest.retriggerManualReviewEmail && !SRV_TPA_TPARequest.istriggerManualReviewReasonsOnly){

            if(SRV_TPA_TPARequest.DDNAckPendingRecords != null && SRV_TPA_TPARequest.DDNAckPendingRecords.size() > 0 && SRV_TPA_TPARequest.isDynamicNotiAckRecived == true) {
                system.debug('in IF condition DDN Dtatus: AMA agreement');
                request.request_status__c = 'Pending Vendor Response on Data Destruction from Prior TPAs';
            }
            else if(request.Is_Manually_Approved__c && includeAmaAttributesOnly == false){
                request.Request_Status__c = Label.TPA_In_Review_By_IQVIA_Status; //Modified by C.P.Pandey under ER-3051 // Updated by Babita Dadarwl under CR-11410
            } else if(request.Is_Manually_Approved__c && includeAmaAttributesOnly == true) {
                request.Request_Status__c = 'TPA Approved Awaiting AMA Approval';
            } else {
                request.Request_Status__c = 'In Auto Approval Process';
            }
            
            //--- Point 10 and point 11 are covered
            if(isAmaLicenseRequired && !amaManualReview && !isAMADatabaseLicensee) { //Updated by Rajendra under ER-12318
                scenariosSatisfiedDetails.add('Condition 10');
                calulateLicenseFee(contractTypeRequired, vendorHasLicence);
            } 
            else {
                if((String.isNotBlank(contractTypeRequired) && !isAmaLicenseRequired && !amaManualReview) || isAMADatabaseLicensee) { //Updated by Rajendra under ER-12318
                    amaAgreementDetails.Current_Year_Fees__c = 0;
                    amaAgreementDetails.Next_Year_Fees__c = 0;
                    amaAgreementDetails.Fee_Reduced__c = 0;
                    scenariosSatisfiedDetails.add('Condition 11');
                    
                }
            }
            
            
            if(contractTypeRequired == SERVICE_BUREAU_II)
            {
                // set the Max Fee reached for vendor in every case whether we are upadting,creating or manual review
                amaAgreementDetails.Max_Fee_Reached__c = maxFeesReached;
            }
            
            if(String.isNotBlank(request.Employee_Accessing_Data_Location__c)) {
                amaAgreementDetails.Vendor_employee_access_data_in_country__c = request.Employee_Accessing_Data_Location__c.replace(';',', ');
            }
            //--- Point 1a covered
            if(includeAmaAttributesOnly) {
                if(!amaManualReview && isAmaLicenseRequired) {
                    system.debug('Point 1a covered');
                    scenariosSatisfiedDetails.add('Condition 1 a)');
                }
            }
            
            if(isAMADatabaseLicensee) {
                isAmaLicenseRequired = false;
                notifyViaMail = false;
                scenariosSatisfiedDetails.add('Vendor is Database Licensee');
                amaAgreementDetails.DBL__c = getDBLValue(vendorName);
                amaAgreementDetails.Contract_Type__c = DATABASE_LICENSEE;
                
            }
            
            // set the values for Scenarios Satisfied to track every satisfied condition
            updatingValueForScenariosSatisfied();
            
            // setting the value of AMA License Required in AMA Agreement Detail
            amaAgreementDetails.Is_AMA_License_Required__c = isAmaLicenseRequired;
            
            //To track if mail is needs to be send to DBL at the time of In-Effect
            if(notifyViaMail && !amaManualReview)
                amaAgreementDetails.Send_DBL_Notification_To_AMA__c = notifyViaMail;
                update amaAgreementDetails;
            
            request.Type_of_AMA_Agreement__c = amaAgreementDetails.Contract_Type__c;
            request.AMA_DBL__c = amaAgreementDetails.DBL__c;
            if(isRunCommercialAutoLogic){
                insertReasons();
            }
        }
        if(((amaAgreementDetails.Contract_Type__c != null  && UTL_TPA.templateContractTypes.contains(amaAgreementDetails.Contract_Type__c) && amaAgreementDetails.Is_AMA_License_Required__c && !amaAgreementDetails.AMA_Manual_Review__c) || amaAgreementDetails.Is_Offshore_Access_Amendment_Required__c)){
            request.Generate_AMA_Contract__c = true;
            request.TLLA_Batch_Call_Sent_On__c = null;
            request.isbatchProcessing__c = false;
        }
        return request;
    }
    
    
    /**
* Name: validateClientAccount
* author: Supriya Johari
* @param: clientId of string type
* @return: valid client name set
* Desc: To validate the client accounts from vendor search map
**/
    private static void validateClientAccount(String clientId) {
        List<AMA_Contract_Detail__c> amaContractsDetailsRelatedIDList = new List<AMA_Contract_Detail__c>();
        if(String.isNotBlank(clientId)) {
            List<TPA_AMA_Client_Vendor_Search_Map__c> searchMapListForClient = new List<TPA_AMA_Client_Vendor_Search_Map__c>();
            for(TPA_AMA_Client_Vendor_Search_Map__c searchMapObject: searchMapList) {
                String str = searchMapObject.TPA_Account_Address__c;
                if(searchMapObject.TPA_Account_Address__c != null && str.contains(clientId.substring(0,15))) {
                    searchMapListForClient.add(searchMapObject);
                }
            }
            for(TPA_AMA_Client_Vendor_Search_Map__c searchMapForClientObj: searchMapListForClient) {
                validClientNameSet.add(searchMapForClientObj.AMA_Account_Search_Text__c.toLowerCase());
            }
        }
    }
    /**
* Name: validateClientHavingContract
* author: Supriya Johari
* @param: Set of string having Client Names
* @return:
* Desc: To validate the Client having any of predefined Contract types.
* Added or modified: Added under Er-2261 and modified under CR-8669
**/
    private static set<String> validateClientHavingContract() {
        
        set<String> clientNameSet = new Set<String>();
        
        getContractListForOwnBehalf(); 
        system.debug('amaContractListForOwnBehalf:'+amaContractListForOwnBehalf.size());
        system.debug('amaContractListForOwnBehalf:'+amaContractListForOwnBehalf);
        system.debug('validClientNameSet:'+validClientNameSet);
        for(AMA_Contract_Detail__c amaContDetailObj: amaContractListForOwnBehalf) {
            if(validClientNameSet.contains(amaContDetailObj.Client__c.toLowerCase()) && String.isNotBlank(amaContDetailObj.Contract_Type__c)) {
                for(String clientLicense : UTL_TPA.clientValidateLicenses) {
                    if(amaContDetailObj.Contract_Type__c.equalsIgnoreCase(clientLicense)) {
                        isCilentValid =  true;
                        if(amaContDetailObj.Contract_End_Date__c == null  || amaContDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year()  ) { // modified by Supriya Johari under Issue-08675
                            clientNameSet.add(amaContDetailObj.Client__c);
                            if(amaAgreementDetails.Ex_Client__c != null)
                                resetExContractDetail();
                        } else {
                            if(amaAgreementDetails.Ex_Client__c == null)
                            {
                                updatingExContractDetail(amaContDetailObj);
                                amaAgreementDetails.DBL__c =  null;
                            }
                        }
                    }
                }
            }
        }
        return clientNameSet;
    }
    
    /**
* Name: validateVendorAccount
* author: Supriya Johari
* @param: clientId of string type
* @return: valid client name set
* Desc: validate the vendor account from vendor search map
**/
    private static Boolean validateVendorAccount(Set<id> vendorFamilyIds) {
        if(vendorFamilyIds != null && vendorFamilyIds.size() >0 ) {
            List<TPA_AMA_Client_Vendor_Search_Map__c> searchMapListForVendor = new List<TPA_AMA_Client_Vendor_Search_Map__c>();
            for(TPA_AMA_Client_Vendor_Search_Map__c searchMapObject: searchMapList) {
                String str= searchMapObject.TPA_Account_Address__c;
                if(searchMapObject.TPA_Account_Address__c != null && vendorFamilyIds.contains(searchMapObject.TPA_Account_Address__r.id))
                {
                    searchMapListForVendor.add(searchMapObject);
                }
            }
            for(TPA_AMA_Client_Vendor_Search_Map__c searchMapForVendorObj: searchMapListForVendor) {
                validVendorNameSet.add(searchMapForVendorObj.AMA_Account_Search_Text__c.toLowerCase());
            }
            system.debug('validVendorNameSet' + validVendorNameSet );
            if(validVendorNameSet.size() > 0)
                return true;
        }
        return false;
    }
    
    /**
* Name: getDBLValue
* author: Supriya Johari
* @param: String DBL value
* @return: string
* Desc: To get the exact value from DBL picklist on AMA agreement Detail, which we need to update. modified under ER-4020
**/
    private static string getDBLValue (String dbl) {
        if(String.isNotBlank(dbl)) {
            system.debug('DBL value:- '+dbl);
            Map<String,String> dblAbbreviationMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult = AMA_Agreement_Detail__c.DBL__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple) {
                String picklistValue = f.getValue();
                String separator1 = '(';
                String separator2 = ')';
                String temp = picklistValue.substringAfter(separator1);
                String keyValue = temp.substringBefore(separator2);
                dblAbbreviationMap.put(keyValue.toLowerCase(),picklistValue);
            }
            system.debug('Map'+dblAbbreviationMap);
            // check if map contains the existing DBL value
            if(dblAbbreviationMap.containsKey(dbl.toLowerCase())) {
                return dblAbbreviationMap.get(dbl.toLowerCase());
            }
        }
        return dbl;
    }
    
    /**
* Name: getVendorExistingLicensesFromList
* author: Supriya Johari
* @param: Valid client name and valid vendor names
* @return:
* Desc: To get vendor having existing licenses with any client
**/
    private static void getVendorExistingLicensesFromList(set<String> validClientNames, Set<String> validVendorNames) {
        System.debug('*******Get Vendor Licenses**********'+validClientNames+'=='+validVendorNames);
        List<AMA_Contract_Detail__c> amaContractDetailListForValidVendor = new List<AMA_Contract_Detail__c>();
        List<AMA_Contract_Detail__c> amaContractDetailsList = [Select  id, Name, Client__c, Client_Services_On_Behalf_Of__c,Contract_End_Date__c,Contract_List_Type__c, Contract_Type__c, DBL__c,
                                                               Max_Fee_Reached__c,Offshore_Storage__c,Offshore_Access__c,Special_Terms_And_Conditions__c
                                                               From AMA_Contract_Detail__c
                                                               Where Client_Services_On_Behalf_Of__c != null AND Client_Services_On_Behalf_Of__c != ''
                                                               AND (NOT(Client_Services_On_Behalf_Of__c LIKE '%Own Behalf%'))  AND Contract_Type__c != null AND Contract_Type__c != ''];
        System.debug('*amaContractDetailsList***'+amaContractDetailsList);
        for(AMA_Contract_Detail__c obj:amaContractDetailsList) {
            if(obj.Client__c != null && validVendorNames.contains(obj.Client__c.toLowerCase()))
                amaContractDetailListForValidVendor.add(obj);
        }
        if(amaContractDetailListForValidVendor.size() > 0) {
            String amaContractType = '';
            for(AMA_Contract_Detail__c amaContract : amaContractDetailListForValidVendor) {
                amaContractType =  amaContract.Contract_Type__c;
                List<AMA_Contract_Detail__c> contractDetailList;
                List<AMA_Contract_Detail__c> contDetailListForAnyClient;
                
                //Vendor with same client or different client
                if(validClientNames.contains(amaContract.Client_Services_On_Behalf_Of__c.toLowerCase())) {
                    System.debug('*****Vendor with same client*****'+amaContractType);
                    //Find all DBL values of each contract type with same client
                    if(!dblValuesWithSameClient.containsKey(amaContractType))
                        dblValuesWithSameClient.put(amaContractType,new Set<String>());
                    Set<String> dblValuesForContractType = dblValuesWithSameClient.get(amaContractType);
                    Boolean dblValueExist = false;
                    for(String dblValue: dblValuesForContractType) {
                        if(amaContract.DBL__c != null && dblValue!= null && dblValue.toLowerCase() == amaContract.DBL__c.toLowerCase()) { // modified by supriya Johari under ER-09385
                            dblValueExist =  true;
                            break;
                        }
                    }
                    if(!dblValueExist)
                        dblValuesWithSameClient.get(amaContractType).add(amaContract.DBL__c);
                    
                    //Find if vendor has reached maxed fees
                    if(amaContractType.containsIgnoreCase(SERVICE_BUREAU_II) &&  (amaContract.Contract_End_Date__c == null || amaContract.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_Start_Date__c.year()) && !maxFeesReached) // modified by Supriya Johari under Issue-08675
                        maxFeesReached = amaContract.Max_Fee_Reached__c;
                    
                    // For Same Client
                    if(vendor_has_existing_license_with_same_client.containsKey(amaContractType))
                        contractDetailList = vendor_has_existing_license_with_same_client.get(amaContractType);
                    else
                        contractDetailList = new List<AMA_Contract_Detail__c>();
                    contractDetailList.add(amaContract);
                    vendor_has_existing_license_with_same_client.put(amaContractType,contractDetailList);
                } else {
                    System.debug('*****Vendor with different client*****'+amaContractType+'*dblValuesWithOtherClient:*'+dblValuesWithOtherClient+'*amaContract.DBL__c*'+amaContract.DBL__c);
                    //Find all DBL values of each contract type with other client
                    if(!dblValuesWithOtherClient.containsKey(amaContractType))
                        dblValuesWithOtherClient.put(amaContractType,new Set<String>());
                    Set<String> dblValuesForContractType = dblValuesWithOtherClient.get(amaContractType);
                    Boolean dblValueExistOtherClient = false;
                    for(String dblValue: dblValuesForContractType) {
                        if(amaContract.DBL__c != null && dblValue!= null && dblValue.toLowerCase() == amaContract.DBL__c.toLowerCase()) {
                            dblValueExistOtherClient =  true;
                            break;
                        }
                    }
                    if(!dblValueExistOtherClient)
                        dblValuesWithOtherClient.get(amaContractType).add(amaContract.DBL__c);
                    
                    //Find if vendor has reached maxed fees
                    System.debug('**amaContract.Contract_End_Date__c**'+amaContract.Contract_End_Date__c+'**amaAgreementDetails.Agreement_Start_Date__c**'+amaAgreementDetails.Agreement_Start_Date__c.year());
                    System.debug('**Here2**');
                    if(amaContractType.containsIgnoreCase(SERVICE_BUREAU_II) && (amaContract.Contract_End_Date__c == null || amaContract.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_Start_Date__c.year()) && !maxFeesReached) // modified by Supriya Johari under Issue-08675
                        maxFeesReached = amaContract.Max_Fee_Reached__c;
                    
                    // For different Client
                    if(vendor_has_existing_license_with_other_client.containsKey(amaContractType))
                        contractDetailList = vendor_has_existing_license_with_other_client.get(amaContractType);
                    else
                        contractDetailList = new List<AMA_Contract_Detail__c>();
                    contractDetailList.add(amaContract);
                    vendor_has_existing_license_with_other_client.put(amaContractType,contractDetailList);
                }
                System.debug('**vendor_has_existing_license_with_any_client**'+vendor_has_existing_license_with_any_client);
                // for Any Client
                if(vendor_has_existing_license_with_any_client.containsKey(amaContractType))
                    contDetailListForAnyClient = vendor_has_existing_license_with_any_client.get(amaContractType);
                else
                    contDetailListForAnyClient = new List<AMA_Contract_Detail__c>();
                contDetailListForAnyClient.add(amaContract);
                vendor_has_existing_license_with_any_client.put(amaContractType,contDetailListForAnyClient);
            }
            System.debug('**vendor_has_existing_license_with_any_client**'+vendor_has_existing_license_with_any_client);
            // to set the values of vendor_has_no_any_existing_license_with_client_listed
            if(vendor_has_existing_license_with_same_client.isEmpty())
            {
                vendor_has_no_any_existing_license_with_client_listed =  true;
            }
            else
            {
                vendor_has_no_any_existing_license_with_client_listed = false;
            }
            
            // to set the values of vendor_has_no_existing_license_with_any_client
            System.debug('**vendor_has_existing_license_with_any_client**'+vendor_has_existing_license_with_any_client);
            if(vendor_has_existing_license_with_any_client.isEmpty())
                vendor_has_no_existing_license_with_any_client = true;
            else
                vendor_has_no_existing_license_with_any_client =  false;
        }
    }
    
    private static void findContracType(TPA_Request__c request){
        System.debug('****Inside findContracType******'+amaAgreementDetails.AMA_Howlong_SP_has_Data_Access__c);
        String amaDataPeriod = amaAgreementDetails.AMA_Howlong_SP_has_Data_Access__c;
        String amaFrequencyOfDelivery = amaAgreementDetails.FrequencyOfDeliveryToServiceProvider__c;
        Boolean isLettershopUse = false;
        Boolean isLettershopSpecialUse = false;
        Boolean isLettershopAllUse = true;
        Boolean isCsfUse = true;
        Boolean isSBIUse = true;
        Boolean isSBIIUseDueToFrequencyAndUse = true;
        Boolean isSBIIUseDueToUse = true;
        Boolean isSBIIUsesGreaterThan90 = true;
        Boolean isSBIIUsesLessThan90 = false;
        Boolean isCSFSpecialUse = false;
        Boolean isCSFOtherUse= true;
        Boolean isLettershopforCombinationScenarios = false; 
        Boolean isSBIforCombinationScenarios = false; 
        Boolean isOnlySpecialAMAUse = true; 
        Boolean isCondition60To65Uses = true;
        if(amaAgreementDetails.AMA_Services_Provided__c != null && amaAgreementDetails.AMA_Services_Provided__c != ''
           && amaAgreementDetails.AMA_TypeOfPrescriberLevelData__c != null && amaAgreementDetails.AMA_TypeOfPrescriberLevelData__c != '') {
               List<String> usesSelected = amaAgreementDetails.AMA_Services_Provided__c.split(';');
               List<String> prescriberLevelData = amaAgreementDetails.AMA_TypeOfPrescriberLevelData__c.split(';');
               system.debug('Selected Uses :-'+usesSelected);
               for(String use : usesSelected) {
                   
                   if(!UTL_TPA.SBIICondition60to65UsesSet.contains(use.toLowercase()) && isCondition60To65Uses){//Modified by Rajendra under ER-11891
                       isCondition60To65Uses = false;
                   }
                   
                   if(UTL_TPA.lettershopUses.contains(use.toLowercase()) && !isLettershopSpecialUse)//Modified by Rajendra under ER-11891
                   {
                       isLettershopSpecialUse = true;
                       isLettershopforCombinationScenarios = true;
                   }
                   
                   if(UTL_TPA.SBIUses.contains(use.toLowercase()) && !isSBIforCombinationScenarios)//Modified by Rajendra under ER-11891
                   {
                       isSBIforCombinationScenarios = true;
                   }
                   
                   
                   if(!UTL_TPA.lettershopUses.contains(use.toLowercase()) && isLettershopAllUse)//Modified by Rajendra under ER-11891
                   {
                       System.debug('******Lettershop:- use didnt match******'+use);
                       isLettershopAllUse = false;
                       isLetterShopUseExist = false;
                   }
                   
                   
                   if(UTL_TPA.csfUses.contains(use.toLowercase()))//Modified by Rajendra under ER-11891
                   {
                       isCSFSpecialUse = true;
                   }
                   
                   if(!UTL_TPA.csfOtherUses.contains(use.toLowercase()) && !UTL_TPA.csfUses.contains(use.toLowercase()) &&  isCSFOtherUse) {//Modified by Rajendra under ER-11891
                       System.debug('******CSF:- use didnt match******'+use);
                       isCSFOtherUse = false;
                   }
                   
                   
                   if(!UTL_TPA.SBIUses.contains(use.toLowercase()) && isSBIUse)//Modified by Rajendra under ER-11891
                   {
                       System.debug('******SBI:- use didnt match******'+use);
                       isSBIUse = false;
                   }
                   
                   if(!UTL_TPA.SBIIUsesDueToFrequencyAndUse.contains(use.toLowercase()) && isSBIIUseDueToFrequencyAndUse)//Modified by Rajendra under ER-11891
                   {
                       System.debug('******SBII due to Freq and use:- use didnt match******'+use);
                       isSBIIUseDueToFrequencyAndUse = false;
                   }
                   
                   if(!UTL_TPA.SBIIUsesDueToUse.contains(use.toLowercase()) && isSBIIUseDueToUse)//Modified by Rajendra under ER-11891
                   {
                       System.debug('******SBII use due to use:- use didnt match******'+use);
                       isSBIIUseDueToUse = false;
                   }
                   
                   if(!UTL_TPA.SBIIUsesGreaterThan90.contains(use.toLowercase()) && isSBIIUsesGreaterThan90){//Modified by Rajendra under ER-11891
                       
                       System.debug('******SBII Greater than 90 :- use didnt match******'+use);
                       isSBIIUsesGreaterThan90 = false;
                   }
                   if(UTL_TPA.SBIIUseslessThan90.contains(use.tolowerCase()) && !isSBIIUsesLessThan90){//Modified by Rajendra under ER-11891 (for Condition 58)
                       
                       System.debug('******SBII less than 90 :- use didnt match******'+use);
                       isSBIIUsesLessThan90 = true;
                   }
                   
               }
               
               if(isCSFSpecialUse && isCSFOtherUse )
               {
                   isCsfUse = true;
               }
               else
               {
                   isCsfUse = false;
               }
               
               if(isLettershopSpecialUse && isLettershopAllUse)
               {
                   isLettershopUse = true;
               }
               else
               {
                   isLettershopUse = false;
               }
               System.debug('****Uses :-****isOnlySpecialAMAUse'+ isOnlySpecialAMAUse + 'Lettershop ='+isLettershopUse+' CSf = '+isCsfUse+' SB1 = '+isSBIUse+' SBIIUseDueToFrequencyAndUse = '+isSBIIUseDueToFrequencyAndUse+' SBIIUseDueToUse = '+isSBIIUseDueToUse+' SBIIUsesGreaterThan90 = '+isSBIIUsesGreaterThan90); // modified by Supriya Johari under ER-3886
           }
        
        /*if(isLettershopAllUse && amaAgreementDetails.Vendor_require_Remote_Access_from_NonUS__c != null && amaAgreementDetails.Vendor_require_Remote_Access_from_NonUS__c ==  'Yes' && amaAgreementDetails.Vendor_Employee_Accessed_Data_in_country__c != null){
            amaManualReview = true;
            isAmaLicenseRequired = false;
            addReason(request,'Lettershop use with offshore access');
            addReasonCommercial(request, 'Lettershop use with offshore access', null, null);
            addAMAReason(amaAgreementDetails, 'Lettershop use with offshore access');
            reasonForAmaApprovalMap.put( 'Lettershop use with offshore access','Lettershop use with offshore access;Offshore access not allowed by AMA for Lettershop uses;Advise client and vendor that only US resources can access the data for this project' );
        }  
        else{*/
        evaluateLettershopConditions(isLettershopUse, amaDataPeriod);
        //}        
        evaluateCSFConditions(isCsfUse, amaDataPeriod, request);
        
        evaluateServiceBureauIConditions(isSBIUse, amaDataPeriod, amaFrequencyOfDelivery);
        
        evaluateLettershopAndSBICombinationConditions(isSBIforCombinationScenarios, isLettershopforCombinationScenarios, amaDataPeriod, amaFrequencyOfDelivery, request);
        
        evaluateServiceBureauII90daysOrLessConditions(isSBIIUseDueToFrequencyAndUse, amaDataPeriod, amaFrequencyOfDelivery, request);
        
        evaluateLettershopAndSBIICombination90daysOrLessConditions(isLettershopSpecialUse, isSBIIUsesLessThan90, amaDataPeriod, amaFrequencyOfDelivery, request); //Added By Neha Under CR-11891
        
        evaluateServiceBureauIIDueToUseConditions(isSBIIUseDueToUse, amaDataPeriod, request);
        
        evaluateServiceBureauIIGreaterThan90DaysConditions(isSBIIUsesGreaterThan90, amaDataPeriod, request);
        
        evaluateCondition60to65SBII(isCondition60To65Uses, amaDataPeriod, amaFrequencyOfDelivery, request);//Added by Rajendra under ER-11891
        
        System.debug('*******Contract type found*****'+contractTypeRequired +'******isAmaLicenseRequired***'+isAmaLicenseRequired+'*****amaManualReview******'+amaManualReview);
        
        if((contractTypeRequired == SERVICE_BUREAU_II || contractTypeRequired == SBII_AMENDMENT  )&& (vendor_has_existing_license_with_any_client.containsKey(CONTRACT_SALESFORCE) || vendor_has_existing_license_with_any_client.containsKey(MEDICAL_DIAGNOSIS_EQUIPMENT_SUPPLY) || vendor_has_existing_license_with_any_client.containsKey(HEALTHCARE_PROVIDER))){
            String existingContractType = '';
            if(vendor_has_existing_license_with_any_client.containsKey(CONTRACT_SALESFORCE)) {
                existingContractType = CONTRACT_SALESFORCE;
            } else if(vendor_has_existing_license_with_any_client.containsKey(MEDICAL_DIAGNOSIS_EQUIPMENT_SUPPLY)) {
                existingContractType = MEDICAL_DIAGNOSIS_EQUIPMENT_SUPPLY;
            } else if(vendor_has_existing_license_with_any_client.containsKey(HEALTHCARE_PROVIDER)) {
                existingContractType = HEALTHCARE_PROVIDER;
            }
            List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_any_client.get(existingContractType);
            if(existingAMAContractDetailList.size()>0) {
                for(AMA_Contract_Detail__c conDetailObj:existingAMAContractDetailList) {
                    if(conDetailObj.Contract_End_Date__c == null || conDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year()) { // modified by Supriya Johari under Issue-08675
                        system.debug('SB2 Generic Logic');
                        //To reset the all the values of which were set in the process for SBII
                        resetBasicAmaAgreementDetail();
                        String multipleDblReason = 'Vendor has SBII with multiple DBLS';
                        String amendmentReason = 'AMA SBII Amendment is required'; // added by supriya johari under ER-2749 and Issue-08754
                        removeReason(request,multipleDblReason);
                        removeReason(request,amendmentReason); // added by supriya johari under ER-2749 and Issue-08754
                        scenariosSatisfiedDetails.add('SBII generic logic');
                        amaManualReview = true;
                        isAmaLicenseRequired = false;
                        addReason(request,'SBII & Vendor has CSF,Medical,Healthcare');
                        addReasonCommercial(request, 'SBII & Vendor has CSF,Medical,Healthcare', null, null);
                        addAMAReason(amaAgreementDetails, 'SBII & Vendor has CSF,Medical,Healthcare');
                        reasonForAmaApprovalMap.put( System.Label.TPA_AMA_SBII_is_TRUE_and_vendor_has_a_Contract_Sales_Force_Medical,'SBII is TRUE and vendor has a Contract Sales Force, Medical/Diagnostic Equipment & Supply, or Healthcare Provider on AMA List;This requires TP Processor manual handling to determine contract type;Determine AMA contract required' );
                        updatingExContractDetail(conDetailObj);
                        amaAgreementDetails.DBL__c =  null;
                        break;
                    }
                }
            }              
        }
        System.debug('******keyset******'+getOwnBehalfListForVendor().keySet());
        if(String.isNotBlank(contractTypeRequired) && (getOwnBehalfListForVendor().keySet().contains(MEDICAL_DIAGNOSIS_EQUIPMENT_SUPPLY.toLowerCase()) || getOwnBehalfListForVendor().keySet().contains(HEALTHCARE_PROVIDER.toLowerCase()))) {
            System.debug('******lettershopOtherUses:- use  matched****** other use'+isOnlySpecialAMAUse);
            List<AMA_Contract_Detail__c> existingAMAContractDetailList = new List<AMA_Contract_Detail__c>();
            if(getOwnBehalfListForVendor().keySet().contains(MEDICAL_DIAGNOSIS_EQUIPMENT_SUPPLY.toLowerCase())) {
                existingAMAContractDetailList = getOwnBehalfListForVendor().get(MEDICAL_DIAGNOSIS_EQUIPMENT_SUPPLY.toLowerCase());
            } else if(getOwnBehalfListForVendor().keySet().contains(HEALTHCARE_PROVIDER.toLowerCase())) {
                existingAMAContractDetailList = getOwnBehalfListForVendor().get(HEALTHCARE_PROVIDER.toLowerCase());
            }
            if(existingAMAContractDetailList.size()>0) {
                for(AMA_Contract_Detail__c conDetailObj:existingAMAContractDetailList) {
                    if(conDetailObj.Contract_End_Date__c == null || conDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year()) { // modified by Supriya Johari under Issue-08675
                        system.debug('AMA Special Usecase ER-3886');
                        //To reset the all the values of which were set in the process for SBII
                        resetBasicAmaAgreementDetail();
                        String multipleDblReason = 'Vendor has SBII with multiple DBLS';
                        String amendmentReason = 'AMA SBII Amendment is required';
                           vendor_has_existing_license_with_client_listed = true; 
                        vendor_has_no_any_existing_license_with_client_listed = false; 
                        removeReason(request,multipleDblReason);
                        removeReason(request,amendmentReason);
                        numberOfScenariosSatisfied++;
                        scenariosSatisfiedDetails.add('AMA Special Use and having PSA, MESM, Healthcare Provider ');
                        amaManualReview = false;
                        isAmaLicenseRequired = false;
                        updatingExContractDetail(conDetailObj);
                        amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                        isSpecialLicensePresent = true;
                        break;
                    }
                }
            }           
        }
        // added by Supriya Johari under ER-3886 ends //
		if(String.isNotBlank(contractTypeRequired) && (getOwnBehalfListForVendor().keySet().contains(PHYSICIAN_SPECIFIC_ANALYTIC.toLowerCase()))){
            System.debug('******lettershopOtherUses:- use  matched****** other use'+isOnlySpecialAMAUse);
            System.debug('******contractTypeRequired:-'+contractTypeRequired);
            List<AMA_Contract_Detail__c> existingAMAContractDetailList = new List<AMA_Contract_Detail__c>();
            if(getOwnBehalfListForVendor().keySet().contains(PHYSICIAN_SPECIFIC_ANALYTIC.toLowerCase())) {
                existingAMAContractDetailList = getOwnBehalfListForVendor().get(PHYSICIAN_SPECIFIC_ANALYTIC.toLowerCase());
            }
            if(existingAMAContractDetailList.size()>0) {
                String dblValue = 'iqvia';
                Boolean existImsAsDBL;
                AMA_Contract_Detail__c existingWithDifferentDbl;
				for(AMA_Contract_Detail__c amaContractDetailObj :existingAMAContractDetailList){
                    if(amaContractDetailObj.DBL__c != null){
					    String dblToLowerCase = amaContractDetailObj.DBL__c.toLowerCase();
					    system.debug('amaContractDetailObj.DBL__c.toLowerCase()'+amaContractDetailObj.DBL__c.toLowerCase());
					    if(!dblToLowerCase.contains(dblValue)){
						    existImsAsDBL =  false;
						    if(amaContractDetailObj.Contract_End_Date__c == null || amaContractDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() ) // modified by Supriya Johari under Issue-08675
						    {
							    existingWithDifferentDbl = amaContractDetailObj;
							    break;
						    }
						    else
						    {
							    existingWithDifferentDbl = amaContractDetailObj;
						    }
					    }
					    else if(dblToLowerCase.contains(dblValue)) {
						    existImsAsDBL = true;
						    if(existingWithDifferentDbl ==  null)
						    {
							    if(amaContractDetailObj.Contract_End_Date__c == null || amaContractDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() ) // modified by Supriya Johari under Issue-08675
							    {
								    existingWithDifferentDbl = amaContractDetailObj;
							    }
						    }   
						
					    }
                    }
				}
                system.debug('existImsAsDBLbefore'+existImsAsDBL);
                if(existingWithDifferentDbl != null && existImsAsDBL != null && !existImsAsDBL ){
                    
                    system.debug('point 48 is covered.');
                    resetBasicAmaAgreementDetail();
                    String multipleDblReason = 'Vendor has SBII with multiple DBLS';
                    String amendmentReason = 'AMA SBII Amendment is required';
                    vendor_has_existing_license_with_client_listed = true; 
                    vendor_has_no_any_existing_license_with_client_listed = false; 
                    removeReason(request,multipleDblReason);
                    removeReason(request,amendmentReason);
                    numberOfScenariosSatisfied++;
                    scenariosSatisfiedDetails.add('AMA Special Use and having Physician Specific Analytics with different DBL');
                    amaManualReview = false;
                    isAmaLicenseRequired = false;
                    //updatingExContractDetail(conDetailObj);
                    amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                    contractTypeRequired = 'Existing Agreement';
                    isSpecialLicensePresent = true;
                    isAmaLicenseRequired = false;
                    //vendorHasLicence = 'has existing licence with different client listed on TPA form';
                    updatingExContractDetail(existingWithDifferentDbl);
                    //notifyViaMail = true;
		    system.debug('Kanak');
                    
                }
                else {
                    system.debug('existImsAsDBLafter'+existImsAsDBL);
                    system.debug('point 49 is covered.');
                    resetBasicAmaAgreementDetail();
                    String multipleDblReason = 'Vendor has SBII with multiple DBLS';
                    String amendmentReason = 'AMA SBII Amendment is required';
                    vendor_has_existing_license_with_client_listed = true; 
                    vendor_has_no_any_existing_license_with_client_listed = false; 
                    removeReason(request,multipleDblReason);
                    removeReason(request,amendmentReason);
                    numberOfScenariosSatisfied++;
                    scenariosSatisfiedDetails.add('AMA Special Use and having Physician Specific Analytics with same DBL');
                    amaManualReview = false;
                    isAmaLicenseRequired = false;
                    //updatingExContractDetail(conDetailObj);
                    updatingExContractDetail(existingWithDifferentDbl);
                    amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                    contractTypeRequired = 'Existing Agreement';
                    isSpecialLicensePresent = true;
                    //vendorHasLicence = 'has no existing Licence with AMA';
                    amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                    
                }
            }
        }
    }

    public static List<TPA_Commercial_Review__c> reasonsList = new List<TPA_Commercial_Review__c>();
    public static Map<string,string> responsibiltyMap;
    
    public static void insertReasons(){
        Boolean isTPAUpdate = false;
        if(reasonsList != null && reasonsList.size() > 0){
            List<TPA_Commercial_Review__c> reasonsToInsert = new List<TPA_Commercial_Review__c>();
            for(TPA_Commercial_Review__c comRev : reasonsList){
                String Key = '';
                Key += comRev.Manual_Review_Reason__c == null ? '' : comRev.Manual_Review_Reason__c ;
                Key += comRev.Associated_Use_to_Review__c == null ? ';' : (comRev.Associated_Use_to_Review__c+';') ;
                Key += comRev.Associated_Offering_to_Review__c == null ? ';' : (';' + comRev.Associated_Offering_to_Review__c) ;
                if(!SRV_TPA_TPARequest.retainedComRevs.containsKey(Key)){
                    reasonsToInsert.add(comRev);
                }
                SRV_TPA_TPARequest.revsTriggeredAgain.add(Key);
                System.debug('Insert'+Key);
            }
            
            if(reasonsToInsert != null && reasonsToInsert.size() > 0){
                insert reasonsToInsert;
                if(tpaRequest.Pending_Acknowledgements__c == null || tpaRequest.Pending_Acknowledgements__c == ''){
                    isTPAUpdate = true;
                    tpaRequest.Pending_Acknowledgements__c =  'Pending Commercial Review Acknowledgements' ;
                }
                else if(tpaRequest.Pending_Acknowledgements__c.indexOf('Pending Commercial Review Acknowledgements') == -1){
                    isTPAUpdate = true;
                    tpaRequest.Pending_Acknowledgements__c = tpaRequest.Pending_Acknowledgements__c + ';Pending Commercial Review Acknowledgements' ;
                }
                if(isTPAUpdate)
                    update tpaRequest;
            }
        }
        reasonsList = new List<TPA_Commercial_Review__c>();
    }

    private static void addReasonCommercial(TPA_Request__c request,String manualApprovalReason,String email,String offeringDetail){
        Boolean isReasonExists = false;
        TPA_Commercial_Review__c newReason = new TPA_Commercial_Review__c();
        newReason.TPA_Request__c = request.Id;
        newReason.Status__c = 'Awaiting Review';
        newReason.Manual_Review_Reason__c = manualApprovalReason;
        String owners = findResponsibility(manualApprovalReason);
        if(owners != null && owners.contains('Commercial')){
            newReason.Action_Needed_By__c = 'Commercial Owner';
        }
        else if(owners != null && owners.contains('TP-Country')){
            newReason.Action_Needed_By__c = 'TP-Country';
        }
        else if(owners?.contains('AMA-Admin') == true){
            newReason.Action_Needed_By__c = 'IQVIA Client AMA Administrator';
        } 
        else{
            newReason.Action_Needed_By__c = owners;
        }
        if(owners != null){
            List<String> ownersList = owners.split(';');
            for(String own:ownersList){
                if(own.trim() == 'TP-Country'){
                    newReason.TP_Country_Email__c = request.TP_Processor_Email__c;
                }
                else if(own.trim() == 'TP-US'){
                    newReason.TP_US_Email__c = UTL_TPA.TPUSEMailAddress;
                }
            }
        }
        newReason.Receiver_s_Email__c = email; 
        if(offeringDetail != null)
            newReason.Associated_Offering_to_Review__c	= offeringDetail;
        reasonsList.add(newReason);
    }


    public static String findResponsibility(String reason){
        if(responsibiltyMap == null){
            responsibiltyMap = new Map<String,String>();
            List<TPA_Table_Of_Responsibility_Settings__c> listOfResponsibilty = [Select Id,MANUAL_TRIGGER_REASONS__c,OWNER_REVIEW__c From TPA_Table_Of_Responsibility_Settings__c ];
            for(TPA_Table_Of_Responsibility_Settings__c resp : listOfResponsibilty){
                responsibiltyMap.put(resp.MANUAL_TRIGGER_REASONS__c.trim().toLowerCase(),resp.OWNER_REVIEW__c.trim());
            }
            return responsibiltyMap.get(reason.trim().toLowerCase());
        }
        else{
            return responsibiltyMap.get(reason.trim().toLowerCase());
        }
    }
    
    //*** Added by Sunny Bansal unde ER-2101 starts ***//
    private static void addReason(TPA_Request__c request, String manualApprovalReason) {
        Boolean reasonAlreadyExists = false;
        if(request.Manual_Trigger_Reasons__c != null) {
            String[] reasons = request.Manual_Trigger_Reasons__c.split(';');
            for(String reason : reasons) {
                if(reason.equalsIgnoreCase(manualApprovalReason)) {
                    reasonAlreadyExists = true;
                    break;
                }
            }
            if(!reasonAlreadyExists) {
                request.Manual_Trigger_Reasons__c = request.Manual_Trigger_Reasons__c + ';' + manualApprovalReason;
            }
        } else {
            request.Manual_Trigger_Reasons__c = manualApprovalReason;
        }
    }
    //*** Added by Sunny Bansal unde ER-2101 ends ***//
    
    
    //*** Added by Supriya Johari under ER-2261 starts ***//
    private static void removeReason(TPA_Request__c request, String manualApprovalReason) {
        Boolean reasonExists = false;
        Integer pos = -1;
        Integer i = 0;
        if(request.Manual_Trigger_Reasons__c != null) {
            List<string> reasons = request.Manual_Trigger_Reasons__c.split(';');
            
            for(String reason : reasons) {
                if(reason.equalsIgnoreCase(manualApprovalReason)) {
                    reasonExists = true;
                    pos = i;
                    break;
                }
                i++;
            }
            if(reasonExists)
            {
                if(pos != -1)
                {
                    reasons.remove(pos);
                }
                request.Manual_Trigger_Reasons__c = String.join(reasons, ';');
            }
        }
    }
    //*** Added by Supriya Johari under ER-2261 ends ***//
    
    //*** Added by Sunny Bansal unde ER-2261 starts ***//
    private static void addAMAReason(AMA_Agreement_Detail__c amaAgreement, String manualApprovalReason) {
        Boolean reasonAlreadyExists = false;
        if(amaAgreement.AMA_Manual_Trigger_Reasons__c != null) {
            String[] reasons = amaAgreement.AMA_Manual_Trigger_Reasons__c.split(';');
            for(String reason : reasons) {
                if(reason.equalsIgnoreCase(manualApprovalReason)) {
                    reasonAlreadyExists = true;
                    break;
                }
            }
            if(!reasonAlreadyExists) {
                amaAgreement.AMA_Manual_Trigger_Reasons__c = amaAgreement.AMA_Manual_Trigger_Reasons__c + ';' + manualApprovalReason;
            }
        } else {
            amaAgreement.AMA_Manual_Trigger_Reasons__c = manualApprovalReason;
        }
    }
    
    /**
* Name: resetValuesforAMA
* author: Supriya Johari
* @param:
* @return:
* Desc: To set variables same as those were in the initiation phase.
**/
    private static void resetValuesforAMA() {
        vendor_has_no_any_existing_license_with_client_listed = true;
        vendor_has_existing_license_with_client_listed = false;
        vendor_has_existing_license_with_different_client_listed = false;
        notifyViaMail = false;
    }
    
    
    /**
* Name: calculateLicenseFee
* author: Supriya Johari
* @param: contractType and vendorHasLicence
* @return: void
* Desc: To calculate fee for particular contract type and vendor has licence values
**/
    private static void calulateLicenseFee(String contractType, String vendorHasLicenceVal) {
        system.debug('*************debugging'+tpaRequest.Data_Access_Start_Date__c);
        Date projectStartDate = amaAgreementDetails.Agreement_Start_Date__c;
        Date projectEndDate = amaAgreementDetails.Agreement_End_Date__c;
        Integer currentYear = Integer.valueOf(amaAgreementDetails.Current_Year__c);
        
        String currentYearValue = '' + currentYear;
        Integer nextYear;
        Decimal currentYearFee = 0;
        Decimal nextyearFee = 0;
        Decimal fullYearFee = 0;
        if(amaAgreementDetails.Agreement_End_Date__c != null) {
            nextYear = Integer.valueOf(amaAgreementDetails.Agreement_End_Date__c.year());
        }
        AMA_Fee_Master__c feeMasterObject;
        try {
            system.debug('*************$contractType:'+contractType + ' &vendorHasLicence: ' + vendorHasLicence +' &currentYear: ' + currentYear+ ' &nextYear: '+ nextYear + ' &projectStartDate: ' +projectStartDate + ' &projectEndDate:' +projectEndDate +'$************');
            List<AMA_Fee_Master__c> feeRules = [Select id,Contract_Type__c,Fee__c, Fee_Calculated__c, Proration_Rules_Applied__c, Template__r.Name ,Vendor_has_Licence__c,Year__c
                                                FROM AMA_Fee_Master__c
                                                Where Contract_Type__c = :contractType AND Vendor_has_Licence__c = :vendorHasLicenceVal AND Year__c = :currentYearValue ];
            System.debug('**feeRules size**'+feeRules.size()+'**Data**'+feeRules[0]);
            if(feeRules.size() > 0) {
                feeMasterObject = feeRules.get(0);
                updatingFeeRuleDetail(feeMasterObject);
                if(feeMasterObject.Fee_Calculated__c == UTL_TPA.TPA_AMA_Calculate_fee_if_vendor_has_not_reached_maxed_fees) {
                    system.debug('Calculate Fee if vendor has not reached maxed fees');
                    
                    if(!maxFeesReached) {
                        system.debug('max fees not reached');
                        if(feeMasterObject.Proration_Rules_Applied__c) {
                            currentYearFee = ProratedFeeForCurrentYear(feeMasterObject.Fee__c);
                        } else {
                            currentYearFee = feeMasterObject.Fee__c;
                        }
                    } else {
                        currentYearFee = 0;
                        system.debug('Max fee reached'+amaAgreementDetails.Max_Fee_Reached__c);
                    }
                    
                    if(nextYear > currentYear) {
                        nextyearFee = feeMasterObject.Fee__c;
                    } else {
                        nextyearFee = 0;
                    }
                } else if(feeMasterObject.Fee_Calculated__c == UTL_TPA.TPA_AMA_Calculate_Fee) {
                    
                    if(feeMasterObject.Proration_Rules_Applied__c == true) {
                        currentYearFee = ProratedFeeForCurrentYear(feeMasterObject.Fee__c);
                    } else {
                        currentYearFee = feeMasterObject.Fee__c;
                    }
                    
                    if(nextYear > currentYear) {
                        nextyearFee = feeMasterObject.Fee__c;
                    } else {
                        nextyearFee = 0;
                    }
                }
                else if(feeMasterObject.Fee_Calculated__c == UTL_TPA.TPA_AMA_Calculate_Fee_For_Nex_Year_Only) {
                    currentYearFee = 0;
                    if(nextYear > currentYear) {
                        nextyearFee = feeMasterObject.Fee__c;
                    } else {
                        nextyearFee = 0;
                    }
                }
                else if(feeMasterObject.Fee_Calculated__c == UTL_TPA.TPA_AMA_No_Fee) {
                    currentYearFee = 0;
                    nextyearFee = 0;
                }
                // check if according to previously condition 8b satisfied, if calculateFeeForCurrentYear is false then we do  not need to calculate for for current year only next year fee would be applied.
                if(!calculateFeeForCurrentYear) {
                    currentYearFee = 0;
                    if(amaAgreementDetails.Is_Prorated__c == true) {
                        amaAgreementDetails.Is_Prorated__c = false;
                    }
                }
                
                if(amaAgreementDetails.Is_Prorated__c == false)
                {
                    amaAgreementDetails.Fee_Reduced__c = 0;
                }
                system.debug('*************$'+currentYearFee + ' and ' + nextyearFee +'$************');
            }
        }
        catch(exception e) {
            system.debug(e.getMessage());
        }
        amaAgreementDetails.Current_Year_Fees__c = currentYearFee;
        amaAgreementDetails.Next_Year_Fees__c = nextyearFee;
        system.debug(amaAgreementDetails.Current_Year_Fees__c);
    }
    
    /**
* Name: updatingValueForScenariosSatisfied
* author: Supriya Johari
* @param:
* @return:
* Desc: To set field Number_Of_Scenarios_Satisfied__c and Scenarios_Satisfied_Details__c
**/
    private static void updatingValueForScenariosSatisfied() {
        amaAgreementDetails.Number_Of_Scenarios_Satisfied__c = numberOfScenariosSatisfied;
        system.debug('Scenarios satisfied'+scenariosSatisfiedDetails);
        amaAgreementDetails.Scenarios_Satisfied_Details__c = String.join(scenariosSatisfiedDetails, ' ; ');
    }
    
    // Added by supriya Johari
    /**
* Name: evaluateLettershopConditions
* @param: isLettershopUse, amaDataPeriod
* @return:
* Desc: to evaluate Lettershop Conditions
**/
    private static void evaluateLettershopConditions(Boolean isLettershopUse, String amaDataPeriod) {
        //*** 90-days or less scenarios that fall under Lettershop starts ***//
        if(amaDataPeriod.equalsIgnoreCase('90 days or less') && isLettershopUse) {  //When data required for Less then 90 days
            System.debug('*******Inside Lettershop conditions*******');
            Map<String,List<AMA_Contract_Detail__c>> specialContractwithOwnBehalfForVendor =  getOwnBehalfAndSpecialContractsForVendor(); // added by supriya johari under CR-08669
            
            system.debug('****Special Contract Types with Own Behalf For Vendor '+specialContractwithOwnBehalfForVendor);
            if(vendor_has_no_existing_license_with_any_client && specialContractwithOwnBehalfForVendor.isEmpty()) { // modified by supriya johari under CR-08669
                //point 12 is covered.
                System.debug('point 12 is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Lettershop Condition 12');
                
                System.debug('****Lettershop: No existing any license*************');
                vendor_has_no_existing_license_with_any_client = true;
                //The system shall select a Contract type of Lettershop.
                isAmaLicenseRequired = true;
                contractTypeRequired = LETTERSHOP;
                vendorHasLicence = 'N/A';
                
                //Update the Agreement record with the existing AMA license type, Fees and DBL that is covering the project.
                amaAgreementDetails.Contract_Type__c = LETTERSHOP;
                amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA);
            } else if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I) && specialContractwithOwnBehalfForVendor.isEmpty()) { // modified by supriya johari under CR-08669
                //point 12 is covered.
                System.debug('point 12+SB I is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Lettershop Condition 12b');
                
                System.debug('****Lettershop: with existing SB I license*************');
                //The system shall select a Contract type of Lettershop.
                isAmaLicenseRequired = true;
                contractTypeRequired = LETTERSHOP;
                vendorHasLicence = 'N/A';
                
                //Update the Agreement record with the existing AMA license type, Fees and DBL that is covering the project.
                amaAgreementDetails.Contract_Type__c = LETTERSHOP;
                amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA);
            } else if(vendor_has_existing_license_with_same_client.containsKey(LETTERSHOP)
                      || vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)
                      || !specialContractwithOwnBehalfForVendor.isEmpty()) { // modified by supriya johari under CR-08669
                          //point 13 is covered.
                          System.debug('point 13 is covered.');
                          numberOfScenariosSatisfied++;
                          scenariosSatisfiedDetails.add('Lettershop Condition 13');
                          System.debug('*******Lettershop 3rd condition******');
                          vendor_has_existing_license_with_client_listed = true;
                          vendor_has_no_any_existing_license_with_client_listed = false;
                          isAmaLicenseRequired = false;
                          String existingContractType;
                          contractTypeRequired = LETTERSHOP;
                          
                          //Update the Agreement record with the existing AMA license type and DBL that is covering the project.
                          if(vendor_has_existing_license_with_same_client.containsKey(LETTERSHOP)) {
                              existingContractType = LETTERSHOP;
                              
                          } else if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)) {
                              existingContractType = SERVICE_BUREAU_II;
                              
                          } else if(!specialContractwithOwnBehalfForVendor.isEmpty()){
                              existingContractType = 'Special Contract Type';
                          }
                          
                          amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                          AMA_Contract_Detail__c existingAMAContractDetailObj;
                          
                          if(existingContractType == LETTERSHOP || existingContractType == SERVICE_BUREAU_II )
                          {
                              List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                              system.debug('in point 13 contract List size '+existingAMAContractDetailList.size());
                              
                              existingAMAContractDetailObj =  getExistingContractDetail(existingAMAContractDetailList);
                          }
                          else
                          {
                              Set<String> availableContractTypes = specialContractwithOwnBehalfForVendor.keySet();
                              existingAMAContractDetailObj = getExistingContractDetailForDifferentTypes(availableContractTypes, specialContractwithOwnBehalfForVendor);
                              
                          }
                          
                          System.debug('**existingAMAContractDetailObj**'+existingAMAContractDetailObj);
                          //Update agreement detail object with existing contract detail
                          updatingExContractDetail(existingAMAContractDetailObj);
                          
                      } else if(vendor_has_existing_license_with_other_client.containsKey(LETTERSHOP) ||  
                      vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II) || 
                      vendor_has_existing_license_with_other_client.containsKey(CONTRACT_SALESFORCE) || 
                      vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_I)) {
                          
                          List<AMA_Contract_Detail__c> recordsWithDifferentClient = vendor_has_existing_license_with_other_client.get(LETTERSHOP);
                          AMA_Contract_Detail__c existingWithDifferentClient = getExistingContractDetail(recordsWithDifferentClient);
                          
                          //point 14 is covered.
                          System.debug('point 14 is covered.');
                          numberOfScenariosSatisfied++;
                          scenariosSatisfiedDetails.add('Lettershop Condition 14');
                          System.debug('****Lettershop: Existing lettershop license with different client*************');
                          vendor_has_existing_license_with_different_client_listed = true;
                          //The system shall select the AMA Lettershop Template
                          isAmaLicenseRequired = true;
                          contractTypeRequired = LETTERSHOP;
                          vendorHasLicence = 'N/A';
                          // update the ex Contract Detail section
                          updatingExContractDetail(existingWithDifferentClient);
                          //Update the Agreement record with the existing AMA license type, Fees and DBL that is covering the project.
                          amaAgreementDetails.Contract_Type__c = LETTERSHOP;
                          amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                          
                      } else if(!vendor_has_existing_license_with_same_client.isEmpty()
                                && !( vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I_EOA)
                                     || vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I)
                                     || vendor_has_existing_license_with_same_client.containsKey(PHYSICIAN_SPECIFIC_ANALYTIC)
                                     || vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)
                                     ||vendor_has_existing_license_with_same_client.containsKey(LETTERSHOP)
                                    )) {
                                        
                                        Set<String> availableContractTypes = vendor_has_existing_license_with_same_client.keySet();
                                        AMA_Contract_Detail__c existingWithSameClient = getExistingContractDetailForDifferentTypes(availableContractTypes, vendor_has_existing_license_with_same_client);
                                        
                                        
                                        System.debug('point 15 is covered.');
                                        numberOfScenariosSatisfied++;
                                        scenariosSatisfiedDetails.add('Lettershop Condition 15');
                                        //The system shall select a Contract type of Lettershop. The system shall
                                        isAmaLicenseRequired = true;
                                        contractTypeRequired = LETTERSHOP;
                                        vendorHasLicence = 'N/A';
                                        
                                        // update the ex Contract Detail section
                                        updatingExContractDetail(existingWithSameClient);
                                        
                                        // Update the Agreement record with the existing AMA Contract type, Fees and DBL that is covering the project.Means:-(Contract type=?Lettershop?,DBL=?IMS?,Fees=0$)
                                        amaAgreementDetails.Contract_Type__c = LETTERSHOP;
                                        //amaAgreementDetails.DBL__c = getDBLValue('IMS');/Commented By Neha Bansal Under CR-11895
                                        amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); //Added By Neha Bansal Under CR-11895
                                    }
        }
        //*** 90-days or less scenarios that fall under Lettershop ends ***//
    }
    
    
    /**
* Name: evaluateServiceBureauIConditions
* @param: isSBIUse, amaDataPeriod, amaFrequencyOfDelivery
* @return:
* Desc: to evaluate Service Bureau I Conditions
**/
    private static void evaluateServiceBureauIConditions(Boolean isSBIUse, String amaDataPeriod,String amaFrequencyOfDelivery) {
        if(isSBIUse && amaDataPeriod.equalsIgnoreCase('90 days or less') && (amaFrequencyOfDelivery.contains('Quarterly') || amaFrequencyOfDelivery.containsIgnoreCase('One-time'))) { //When data required for Less then 90 days
            Map<String,List<AMA_Contract_Detail__c>> specialContractwithOwnBehalfForVendor =  getOwnBehalfAndSpecialContractsForVendor(); // added by supriya johari under CR-08669
            
            if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I) && !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)) {
                system.debug('point 25 is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau I Condition 25');
                vendor_has_existing_license_with_client_listed = true;
                vendor_has_no_any_existing_license_with_client_listed = false;
                String existingContractType = SERVICE_BUREAU_I;
                List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                AMA_Contract_Detail__c existingAMAContractDetailObj =  getExistingContractDetail(existingAMAContractDetailList);
                isAmaLicenseRequired = false;
                contractTypeRequired = SERVICE_BUREAU_I;
                //Update the Agreement record with the existing AMA Contract type and DBL that is covering the project
                amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                //Update agreement detail object with existing contract detail
                
                updatingExContractDetail(existingAMAContractDetailObj);
                vendorHasLicence = 'has existing licence with client listed on TPA form'; 
            } else if((vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II) || !specialContractwithOwnBehalfForVendor.isEmpty())
                      && !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I) ) {
                          system.debug('point 26 is covered.');
                          numberOfScenariosSatisfied++;
                          scenariosSatisfiedDetails.add('Service Bureau I Condition 26');
                          vendor_has_existing_license_with_client_listed = true;
                          vendor_has_no_any_existing_license_with_client_listed = false;
                          
                          String existingContractType = '';
                          AMA_Contract_Detail__c existingAMAContractDetailObj;
                          
                          if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II))
                              existingContractType = SERVICE_BUREAU_II;
                          else if(!specialContractwithOwnBehalfForVendor.isEmpty())
                              existingContractType = 'Special Contract Type';
                          
                          if(existingContractType == SERVICE_BUREAU_II )
                          {
                              List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                              existingAMAContractDetailObj = getExistingContractDetail(existingAMAContractDetailList);
                          }
                          else if(existingContractType == 'Special Contract Type' )
                          {
                              Set<String> availableContractTypes = specialContractwithOwnBehalfForVendor.keySet();
                              existingAMAContractDetailObj = getExistingContractDetailForDifferentTypes(availableContractTypes, specialContractwithOwnBehalfForVendor);
                          }
                          isAmaLicenseRequired = false;
                          contractTypeRequired = SERVICE_BUREAU_I;
                          //Update the Agreement record with the existing AMA Contract type and DBL that is covering the project
                          amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                          updatingExContractDetail(existingAMAContractDetailObj);
                          vendorHasLicence = 'has existing licence with client listed on TPA form'; 
                          
                          
                      }  else if(!(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I) || vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II))
                                 && specialContractwithOwnBehalfForVendor.isEmpty() )  { // modified by Supriya johari under CR-08669
                                     
                                     Boolean maxFeeReachedforDiffDBL = false;
                                     String dblValue = 'iqvia';
                                     Boolean existImsAsDBL;
                                     AMA_Contract_Detail__c existingWithDifferentDbl;
                                     for(List<AMA_Contract_Detail__c> contDetailListForAnyClient : vendor_has_existing_license_with_any_client.values()){
                                         for(AMA_Contract_Detail__c amaContractDetailObj :contDetailListForAnyClient){
                                            if(amaContractDetailObj.DBL__c != null){
                                                String dblToLowerCase = amaContractDetailObj.DBL__c.toLowerCase();
                                                if(amaContractDetailObj.Max_Fee_Reached__c && !dblToLowerCase.contains(dblValue)){
                                                    existImsAsDBL =  false;
                                                    maxFeeReachedforDiffDBL = true;
                                                    if(amaContractDetailObj.Contract_End_Date__c == null || amaContractDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() ) // modified by Supriya Johari under Issue-08675
                                                    {
                                                        existingWithDifferentDbl = amaContractDetailObj;
                                                        break;
                                                    }
                                                    else
                                                    {
                                                        existingWithDifferentDbl = amaContractDetailObj;
                                                    }
                                                }
                                                else if(dblToLowerCase.contains(dblValue)) {
                                                    existImsAsDBL = true;
                                                    if(existingWithDifferentDbl ==  null)
                                                    {
                                                        if(amaContractDetailObj.Contract_End_Date__c == null || amaContractDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() ) // modified by Supriya Johari under Issue-08675
                                                        {
                                                            existingWithDifferentDbl = amaContractDetailObj;
                                                        }
                                                    }                                                 
                                                }
                                            }
                                         }
                                     }
                                     if(maxFeeReachedforDiffDBL && (existingWithDifferentDbl != null && existImsAsDBL != null && !existImsAsDBL )){
                                         
                                         system.debug('point 28 is covered.');
                                         numberOfScenariosSatisfied++;
                                         scenariosSatisfiedDetails.add('Service Bureau I Condition 28');
                                         isAmaLicenseRequired = false;
                                         contractTypeRequired = SERVICE_BUREAU_I;
                                         vendorHasLicence = 'has existing licence with different client listed on TPA form';
                                         amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                                         updatingExContractDetail(existingWithDifferentDbl);
                                         notifyViaMail = true;
                                         
                                     }
                                     else {
                                         system.debug('point 27 is covered.');
                                         numberOfScenariosSatisfied++;
                                         scenariosSatisfiedDetails.add('Service Bureau I Condition 27');
                                         contractTypeRequired = SERVICE_BUREAU_I;
                                         isAmaLicenseRequired = true;
                                         vendorHasLicence = 'has no existing Licence with AMA';
                                         //Update the Agreement record with the existing AMA Contract type and DBL that is covering the project.Means-(Contract type=?SBI?,DBL=?IMS?,Fees=0
                                         amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_I;
                                         amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                                         
                                     }
                                 }
        }
    }
    
    /**
* Name: evaluateCSFConditions
* @param: isSBIUse, amaDataPeriod, request
* @return:
* Desc: to evaluate CSF Conditions
**/
    private static void evaluateCSFConditions(Boolean isCSFUse, String amaDataPeriod, TPA_Request__c request) {
        
        if(isCSFUse) {
            if((!vendor_has_no_existing_license_with_any_client)
               &&(!(vendor_has_existing_license_with_any_client.containsKey(CONTRACT_SALESFORCE)
                    || vendor_has_existing_license_with_any_client.containsKey(SERVICE_BUREAU_II)))) {
                        system.debug('point 23 is covered.');
                        numberOfScenariosSatisfied++;
                        scenariosSatisfiedDetails.add('Contract SalesForce Condition 23');
                        contractTypeRequired = CONTRACT_SALESFORCE;
                        isAmaLicenseRequired = true;
                        vendorHasLicence = 'has no existing Licence with AMA';
                        Set<String> availableContractTypes = vendor_has_existing_license_with_any_client.keySet();
                        AMA_Contract_Detail__c existingWithAnyClient = getExistingContractDetailForDifferentTypes(availableContractTypes, vendor_has_existing_license_with_any_client);
                        updatingExContractDetail(existingWithAnyClient);
                        amaAgreementDetails.Contract_Type__c = CONTRACT_SALESFORCE;
                        amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                        
                    } else if(!vendor_has_existing_license_with_any_client.containsKey(CONTRACT_SALESFORCE)) {
                        system.debug('point 20 is covered.');
                        numberOfScenariosSatisfied++;
                        scenariosSatisfiedDetails.add('Contract SalesForce Condition 20');
                        //Point 20 is covered
                        contractTypeRequired = CONTRACT_SALESFORCE;
                        isAmaLicenseRequired = true;
                        vendorHasLicence = 'has no existing Licence with AMA';
                        //Update the Agreement record with the existing AMA Contract type, Fees and DBL that is covering the project. Means-(Contract type=?CSF?,DBL=?IMS?,Fees=36000$)
                        amaAgreementDetails.Contract_Type__c = CONTRACT_SALESFORCE;
                        //amaAgreementDetails.DBL__c = getDBLValue('IMS');/Commented By Neha Bansal Under CR-11895
                        amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); //Added By Neha Bansal Under CR-11895
                        
                    } else if(vendor_has_existing_license_with_same_client.containsKey(CONTRACT_SALESFORCE)) {
                        system.debug('point 22 is covered.');
                        numberOfScenariosSatisfied++;
                        scenariosSatisfiedDetails.add('Contract SalesForce Condition 22');
                        vendor_has_existing_license_with_client_listed = true;
                        vendor_has_no_any_existing_license_with_client_listed = false;
                        //As per the business requirement explicitly mentioned i.e. If come across duplicates DBL for Service Bureau II, Contract Sales Force it would need to be manual review
                        if(dblValuesWithSameClient.get(CONTRACT_SALESFORCE).size() > 1) {
                            amaManualReview = true;
                            isAmaLicenseRequired = false;
                            contractTypeRequired = CONTRACT_SALESFORCE;
                            addReason(request,'Vendor has CSF with multiple DBLS');
                            addReasonCommercial(request, 'Vendor has CSF with multiple DBLS', null, null);
                            addAMAReason(amaAgreementDetails, 'Vendor has CSF with multiple DBLS');
                            reasonForAmaApprovalMap.put( System.Label.TPA_AMA_Vendor_has_Contract_Sales_Force_with_multiple_DBLS,'Vendor has Contract Sales Force with multiple DBLS;This requires TP Processor manual handling to determine contract type;Determine AMA contract required' );
                        } else {
                            //The system shall NOT create a new AMA Contract. (existing Contract will cover the project)
                            String existingContractType = CONTRACT_SALESFORCE;
                            List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                            AMA_Contract_Detail__c existingAMAContractDetailObj = getExistingContractDetail(existingAMAContractDetailList);
                            isAmaLicenseRequired = false;
                            contractTypeRequired = CONTRACT_SALESFORCE;
                            amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                            //Update agreement detail object with existing contract detail
                            updatingExContractDetail(existingAMAContractDetailObj);
                        }
                    } else if(vendor_has_existing_license_with_other_client.containsKey(CONTRACT_SALESFORCE)) {
                        List<AMA_Contract_Detail__c> recordsWithDifferentDbls = vendor_has_existing_license_with_other_client.get(CONTRACT_SALESFORCE);
                        AMA_Contract_Detail__c existingWithDifferentDbl;
                        String dblValue = 'iqvia';  //Added By Neha Bansal Under CR-11895
                        Boolean existImsAsDBL;
                        if(recordsWithDifferentDbls.size() > 0)
                        {
                            for(AMA_Contract_Detail__c amaContractDetailObj: recordsWithDifferentDbls)
                            {
                                if(amaContractDetailObj.DBL__c != null)
                                {
                                    String dblToLowerCase = amaContractDetailObj.DBL__c.toLowerCase();
                                    if(!dblToLowerCase.contains(dblValue))
                                    {
                                        existImsAsDBL =  false;
                                        if(amaContractDetailObj.Contract_End_Date__c == null || amaContractDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() ) // modified by Supriya Johari under Issue-08675
                                        {
                                            existingWithDifferentDbl = amaContractDetailObj;
                                            break;
                                        }
                                        else
                                        {
                                            existingWithDifferentDbl = amaContractDetailObj;
                                        }
                                    }
                                    else
                                    {
                                        existImsAsDBL = true;
                                        if(existingWithDifferentDbl ==  null)
                                        {
                                            if(amaContractDetailObj.Contract_End_Date__c == null || amaContractDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() ) // modified by Supriya Johari under Issue-08675
                                            {
                                                existingWithDifferentDbl = amaContractDetailObj;
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                            if(existingWithDifferentDbl ==  null)
                            {
                                for(AMA_Contract_Detail__c amaContractDetailObj: recordsWithDifferentDbls)
                                {
                                    if(amaContractDetailObj.DBL__c != null )
                                    {
                                        existingWithDifferentDbl = amaContractDetailObj;
                                        break;
                                    }
                                }
                            }
                            
                            
                            if(existingWithDifferentDbl != null && existImsAsDBL != null && !existImsAsDBL )
                            {
                                system.debug('condition 21 a) is covered.');
                                numberOfScenariosSatisfied++;
                                scenariosSatisfiedDetails.add('Contract SalesForce Condition 21 a)');
                                
                                vendor_has_existing_license_with_different_client_listed = true;
                                contractTypeRequired = CONTRACT_SALESFORCE;
                                isAmaLicenseRequired = false;
                                vendorHasLicence = 'has existing licence either with same or different client listed on TPA form';
                                
                                //Update the Agreement record with the existing AMA Contract type and DBL that is covering the project.
                                amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                                updatingExContractDetail(existingWithDifferentDbl);
                                notifyViaMail = true;
                                
                            }else if(existingWithDifferentDbl != null && existImsAsDBL != null && existImsAsDBL)
                            {
                                system.debug('condition 21 b) is covered.');
                                numberOfScenariosSatisfied++;
                                scenariosSatisfiedDetails.add('Contract SalesForce Condition 21 b)');
                                
                                vendor_has_existing_license_with_different_client_listed = true;
                                contractTypeRequired = CSF_AMENDMENT; 
                                isAmaLicenseRequired = true;
                                vendorHasLicence = 'has existing licence with different client listed on TPA form';
                                // update Existing Contract detaiil section
                                updatingExContractDetail(existingWithDifferentDbl);
                                
                                //Update the Agreement record with the existing AMA Contract type, Fees and DBL that is covering the project. Means-(Contract type=?CSF?,DBL=?IMS?,Fees=36000$)
                                amaAgreementDetails.Contract_Type__c = CSF_AMENDMENT;
                                amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                                
                            }
                        }
                        
                    }
            
            
        }
        //*** Contracted Sales Force (CSF) Scenarios ends ***//
    }
    
    // Added by supriya johari under ER-2847 evaluateLettershopAndSBICombinationConditions starts
    
    /**
* Name: evaluateLettershopAndSBICombinationConditions
* author: Supriya Johari
* @param: isSBIIUseDueToFrequencyAndUse, amaDataPeriod, amaFrequencyOfDelivery, request
* @return:
* Desc: to evaluate Lettershop and SBI combination Scenarios
**/
    private static void evaluateLettershopAndSBICombinationConditions(Boolean isSBIUse, Boolean isLettershopUse, String amaDataPeriod, String amaFrequencyOfDelivery, TPA_Request__c request) {
        //*** 90-days or less scenarios that fall under Lettershop and Service Burau I combination scenarios ***//
        System.debug('90-days or less scenarios that fall under Lettershop and Service Burau I combination scenarios');
        if(isSBIUse && isLettershopUse && amaDataPeriod.equalsIgnoreCase('90 days or less')) { //When data required for Less then 90 days
            system.debug('90-days or less scenarios that fall under  Lettershop and Service Burau I combination scenarios');
            
            Map<String,List<AMA_Contract_Detail__c>> specialContractwithOwnBehalfForVendor =  getOwnBehalfAndSpecialContractsForVendor(); // added by supriya johari under CR-08669
            
            system.debug('****Special Contract Types with Own Behalf For Vendor '+specialContractwithOwnBehalfForVendor);
            
            Boolean isQuarterlyOneTime = false;
            
            System.debug('isQuarterlyOneTime----> ' + isQuarterlyOneTime);
            System.debug('vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)----> ' + vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II));
            System.debug('maxFeesReached----> ' + maxFeesReached);
            
            if(amaFrequencyOfDelivery.containsIgnoreCase('Quarterly') || amaFrequencyOfDelivery.containsIgnoreCase('One-time'))
            {
                isQuarterlyOneTime = true;
            }
            
            if(!vendor_has_existing_license_with_same_client.isEmpty() && vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I)){
                for(AMA_Contract_Detail__c AMAcd: vendor_has_existing_license_with_same_client.get(SERVICE_BUREAU_I)){
                    if(!maxFeesReached && AMAcd.Max_Fee_Reached__c && (AMAcd.Contract_End_Date__c == null || AMAcd.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_Start_Date__c.year())){
                        maxFeesReached = AMAcd.Max_Fee_Reached__c;
                    }
                }
            }
            
            if(isQuarterlyOneTime && vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I)
               &&  !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II))  {
                   
                   system.debug('point 44 is covered.');
                   numberOfScenariosSatisfied++;
                   scenariosSatisfiedDetails.add('Lettershop and Service Bureau I combination Condition 44');
                   vendor_has_existing_license_with_client_listed = true;
                   vendor_has_no_any_existing_license_with_client_listed = false;
                   
                   //The system shall NOT create a new AMA Contract
                   //Update the Agreement record with the existing AMA Contract type, fees and DBL that is covering the project.
                   String existingContractType = SERVICE_BUREAU_I;
                   List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                   AMA_Contract_Detail__c existingAMAContractDetailObj =  getExistingContractDetail(existingAMAContractDetailList);
                   isAmaLicenseRequired = false;
                   contractTypeRequired = SERVICE_BUREAU_I;
                   amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                   //Update agreement detail object with existing contract detail
                   updatingExContractDetail(existingAMAContractDetailObj);
                   
               }
            else if(!isQuarterlyOneTime && !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II) && maxFeesReached){
                if(isAMAPerpetualAgreement_US_Only){
                    system.debug('point 46 is covered.');
                    numberOfScenariosSatisfied++;
                    scenariosSatisfiedDetails.add('Lettershop and Service Bureau I combination condition 46');
                    
                    vendor_has_existing_license_with_different_client_listed = true;
                    contractTypeRequired = SBII_AMENDMENT;
                    isAmaLicenseRequired = true;
                    vendorHasLicence = 'has existing licence with different client listed on TPA form';
                    checkIfExpired = false;
                    // update Existing Contract detaiil section for SBI
                    String existingContractType = SERVICE_BUREAU_II;
                    List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_other_client.get(existingContractType);
                    AMA_Contract_Detail__c existingAMAContractDetailObj =  getExistingContractDetail(existingAMAContractDetailList);
                    //Update agreement detail object with existing contract detail
                    updatingExContractDetail(existingAMAContractDetailObj);
                    amaAgreementDetails.Contract_Type__c = SBII_AMENDMENT;
                    //amaAgreementDetails.DBL__c = getDBLValue('IMS');/Commented By Neha Bansal Under CR-11895
                    amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); //Added By Neha Bansal Under CR-11895
                }
                else{
                    numberOfScenariosSatisfied++;
                    scenariosSatisfiedDetails.add('Lettershop and Service Bureau I combination condition Without Has AMA Perpetual Agreement (U.S. Only):');
                    vendor_has_existing_license_with_different_client_listed = true;
                    contractTypeRequired = SERVICE_BUREAU_II;
                    isAmaLicenseRequired = true;
                    vendorHasLicence = 'has existing licence with different client listed on TPA form';
                    String existingContractType = SERVICE_BUREAU_II;
                    List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_other_client.get(existingContractType);
                    AMA_Contract_Detail__c existingAMAContractDetailObj =  getExistingContractDetail(existingAMAContractDetailList);
                    //Update agreement detail object with existing contract detail
                    updatingExContractDetail(existingAMAContractDetailObj);
                    amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                    amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA);

                }
                
                
                
            }
            else if(isQuarterlyOneTime && !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I) &&
                    (vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)
                     || !specialContractwithOwnBehalfForVendor.isEmpty()) ) {
                         System.debug('point 47 is covered.');
                         numberOfScenariosSatisfied++;
                         scenariosSatisfiedDetails.add('Lettershop and Service Bureau I combination condition 47');
                         vendor_has_existing_license_with_client_listed = true;
                         vendor_has_no_any_existing_license_with_client_listed = false;
                         isAmaLicenseRequired = false;
                         String existingContractType;
                         contractTypeRequired = SERVICE_BUREAU_II;
                         
                         //Update the Agreement record with the existing AMA license type and DBL that is covering the project.
                         if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)) {
                             existingContractType = SERVICE_BUREAU_II;
                             
                         } else if(!specialContractwithOwnBehalfForVendor.isEmpty()){
                             existingContractType = 'Special Contract Type';
                         }
                         
                         amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                         AMA_Contract_Detail__c existingAMAContractDetailObj;
                         
                         if(existingContractType == SERVICE_BUREAU_II )
                         {
                             List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                             system.debug('in point 47 contract List size '+existingAMAContractDetailList.size());
                             
                             existingAMAContractDetailObj =  getExistingContractDetail(existingAMAContractDetailList);
                         }
                         else
                         {
                             Set<String> availableContractTypes = specialContractwithOwnBehalfForVendor.keySet();
                             existingAMAContractDetailObj = getExistingContractDetailForDifferentTypes(availableContractTypes, specialContractwithOwnBehalfForVendor);
                             
                         }
                         
                         System.debug('**existingAMAContractDetailObj**'+existingAMAContractDetailObj);
                         
                         //Update agreement detail object with existing contract detail
                         updatingExContractDetail(existingAMAContractDetailObj);
                         
                     }
            else if(!isQuarterlyOneTime && !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I) && //Modified by Rajendra under ER-11891
                    (vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)
                     || !specialContractwithOwnBehalfForVendor.isEmpty()) ) {
                         System.debug('point 48 is covered.');
                         numberOfScenariosSatisfied++;
                         scenariosSatisfiedDetails.add('Lettershop and Service Bureau I combination condition 48');
                         vendor_has_existing_license_with_client_listed = true;
                         vendor_has_no_any_existing_license_with_client_listed = false;
                         isAmaLicenseRequired = false;
                         String existingContractType;
                         contractTypeRequired = SERVICE_BUREAU_II;
                         
                         //Update the Agreement record with the existing AMA license type and DBL that is covering the project.
                         if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)) {
                             existingContractType = SERVICE_BUREAU_II;
                             
                         } else if(!specialContractwithOwnBehalfForVendor.isEmpty()){
                             existingContractType = 'Special Contract Type';
                         }
                         
                         amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                         AMA_Contract_Detail__c existingAMAContractDetailObj;
                         
                         if(existingContractType == SERVICE_BUREAU_II )
                         {
                             List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                             system.debug('in point 48 contract List size '+existingAMAContractDetailList.size());
                             
                             existingAMAContractDetailObj =  getExistingContractDetail(existingAMAContractDetailList);
                         }
                         else
                         {
                             Set<String> availableContractTypes = specialContractwithOwnBehalfForVendor.keySet();
                             existingAMAContractDetailObj = getExistingContractDetailForDifferentTypes(availableContractTypes, specialContractwithOwnBehalfForVendor);
                             
                         }
                         
                         System.debug('**existingAMAContractDetailObj**'+existingAMAContractDetailObj);
                         
                         //Update agreement detail object with existing contract detail
                         updatingExContractDetail(existingAMAContractDetailObj);
                         
                     }
            else if(isQuarterlyOneTime && !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)
                    && !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I)
                    && specialContractwithOwnBehalfForVendor.isEmpty()) {
                        
                        system.debug('point 49 is covered.');
                        numberOfScenariosSatisfied++;
                        scenariosSatisfiedDetails.add('Lettershop and Service Bureau I combination condition 49');
                        contractTypeRequired = SERVICE_BUREAU_I;
                        isAmaLicenseRequired = true;
                        vendorHasLicence = 'has no existing Licence with AMA';
                        checkIfExpired = false;
                        amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_I;
                        amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                    }
            else if(!isQuarterlyOneTime  && !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II) && !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I) //Modified by Rajendra under ER-11891
                    && specialContractwithOwnBehalfForVendor.isEmpty() && !maxFeesReached){
                        system.debug('point 50 is covered.');
                        numberOfScenariosSatisfied++;
                        scenariosSatisfiedDetails.add('Lettershop and Service Bureau I combination condition 50');
                        contractTypeRequired = SERVICE_BUREAU_II;
                        isAmaLicenseRequired = true;
                        vendorHasLicence = 'has no existing Licence with AMA';
                        checkIfExpired = false;
                        amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                        amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                    }
        }
        
    }
    // Added by supriya johari under ER-2847 ends
    
    /**
* Name: evaluateServiceBureauII90daysOrLessConditions
* author: Supriya Johari
* @param: isSBIIUseDueToFrequencyAndUse, amaDataPeriod, amaFrequencyOfDelivery, request
* @return:
* Desc: to evaluate Service Bureau II 90 days Or Less Conditions
**/
    public static void evaluateServiceBureauII90daysOrLessConditions(Boolean isSBIIUseDueToFrequencyAndUse, String amaDataPeriod, String amaFrequencyOfDelivery, TPA_Request__c request) {
        
        Boolean isvalid30to32UsesListA = false;
        Boolean isvalid30to32UsesListB = false;
        if(amaAgreementDetails.AMA_Services_Provided__c != null && amaAgreementDetails.AMA_Services_Provided__c != ''){
            List<String> selectedAMAUses = amaAgreementDetails.AMA_Services_Provided__c.split(';');
            for(String use : selectedAMAUses){
                if(UTL_TPA.SBIICondition30to32UsesListA.contains(use.toLowerCase())){
                    isvalid30to32UsesListA = true;
                }
                if(UTL_TPA.SBIICondition30to32UsesListB.contains(use.toLowerCase())){
                    isvalid30to32UsesListB = true;
                }
            }
            if((isvalid30to32UsesListA && isvalid30to32UsesListB) && isSBIIUseDueToFrequencyAndUse && amaDataPeriod.equalsIgnoreCase('90 days or less')) { //When data required for Less then 90 days and frequency of use is not quarterly or one-time //Modified by Rajendra under ER-11891(For Condition 32)
                system.debug('90-days or less scenarios that fall under Service Bureau II (SBII) due to Frequency and USES starts ');
                if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II))  {
                    system.debug('point 30 is covered.');
                    numberOfScenariosSatisfied++;
                    scenariosSatisfiedDetails.add('Service Bureau II Condition 30');
                    vendor_has_existing_license_with_client_listed = true;
                    vendor_has_no_any_existing_license_with_client_listed = false;
                    //As per the business requirement explicitly mentioned i.e. If come across duplicates DBL for Service Bureau II, Contract Sales Force it would need to be manual review
                    if(dblValuesWithSameClient.get(SERVICE_BUREAU_II).size() > 1) {
                        amaManualReview = true;
                        isAmaLicenseRequired = false;
                        contractTypeRequired = SERVICE_BUREAU_II;
                        addReason(request,'Vendor has SBII with multiple DBLS');
                        addReasonCommercial(request, 'Vendor has SBII with multiple DBLS', null, null);
                        addAMAReason(amaAgreementDetails, 'Vendor has SBII with multiple DBLS');
                        reasonForAmaApprovalMap.put( System.Label.TPA_AMA_Vendor_has_Service_Bureau_II_with_multiple_DBLS,'Vendor has Service Bureau II with multiple DBLS;This requires TP Processor manual handling to determine contract type;Determine AMA contract required' );
                    } else {
                        //NOT create Service Bureau II agreement, existing will cover the project
                        //Update the Agreement record with the existing AMA Contract type, fees and DBL that is covering the project.
                        String existingContractType = SERVICE_BUREAU_II;
                        List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                        AMA_Contract_Detail__c existingAMAContractDetailObj =  getExistingContractDetail(existingAMAContractDetailList);
                        isAmaLicenseRequired = false;
                        contractTypeRequired = SERVICE_BUREAU_II;
                        amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                        //Update agreement detail object with existing contract detail
                        updatingExContractDetail(existingAMAContractDetailObj);
                    }
                }
                else if(vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II)) {
                    system.debug('in Condition 31');
                    
                    String ruleNo31 = '31';
                    evaluateSBIIWithDifferentDBLScenario(ruleNo31, request);// modified by supriya johari under Issue-08754
                }
                else if(vendor_has_existing_license_with_any_client.isEmpty() || !vendor_has_existing_license_with_any_client.containsKey(SERVICE_BUREAU_II)) { //Modified by Rajendra Under ER-11891
                    
                    system.debug('point 32 is covered.');
                    numberOfScenariosSatisfied++;
                    scenariosSatisfiedDetails.add('Service Bureau II Condition 32');
                    contractTypeRequired = SERVICE_BUREAU_II;
                    isAmaLicenseRequired = true;
                    //update section AMA Contract Detail
                    Set<String> availableContractTypes = vendor_has_existing_license_with_same_client.keySet();
                    AMA_Contract_Detail__c existingWithSameClient = getExistingContractDetailForDifferentTypes(availableContractTypes, vendor_has_existing_license_with_same_client);
                    
                    // update the ex Contract Detail section
                    updatingExContractDetail(existingWithSameClient);
                    vendorHasLicence = 'has no existing Licence with AMA';
                    amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                    amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); //Added By Neha Bansal Under CR-11895
                }
            }
        }

        
        //*** 90-days or less scenarios that fall under Service Bureau II (SBII) due to Frequency and USES ends ***//
    }
    //Added By Neha Under CR-11891 Starts
    public static void evaluateLettershopAndSBIICombination90daysOrLessConditions(Boolean isSBIIUse, Boolean isLettershopUse, String amaDataPeriod, String amaFrequencyOfDelivery, TPA_Request__c request) {
        system.debug('isSBIIUse: '+isSBIIUse);
        system.debug('isLettershopUse: '+isLettershopUse);
        if(isSBIIUse && isLettershopUse && amaDataPeriod.equalsIgnoreCase('90 days or less')) {
            if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II))  {
                system.debug('point 30 is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau II Condition 51');
                vendor_has_existing_license_with_client_listed = true;
                vendor_has_no_any_existing_license_with_client_listed = false;
                //As per the business requirement explicitly mentioned i.e. If come across duplicates DBL for Service Bureau II, Contract Sales Force it would need to be manual review
                if(dblValuesWithSameClient.get(SERVICE_BUREAU_II).size() > 1) {
                    amaManualReview = true;
                    isAmaLicenseRequired = false;
                    contractTypeRequired = SERVICE_BUREAU_II;
                    addReason(request,'Vendor has SBII with multiple DBLS');
                    addReasonCommercial(request, 'Vendor has SBII with multiple DBLS', null, null);
                    addAMAReason(amaAgreementDetails, 'Vendor has SBII with multiple DBLS');
                    reasonForAmaApprovalMap.put( System.Label.TPA_AMA_Vendor_has_Service_Bureau_II_with_multiple_DBLS,'Vendor has Service Bureau II with multiple DBLS;This requires TP Processor manual handling to determine contract type;Determine AMA contract required' );
                } else {
                    //NOT create Service Bureau II agreement, existing will cover the project
                    //Update the Agreement record with the existing AMA Contract type, fees and DBL that is covering the project.
                    String existingContractType = SERVICE_BUREAU_II;
                    List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                    AMA_Contract_Detail__c existingAMAContractDetailObj =  getExistingContractDetail(existingAMAContractDetailList);
                    isAmaLicenseRequired = false;
                    contractTypeRequired = SERVICE_BUREAU_II;
                    amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                    //Update agreement detail object with existing contract detail
                    updatingExContractDetail(existingAMAContractDetailObj);
                }
            }
            else if(vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II)) {
                system.debug('in Condition 52');
                
                String ruleNo52 = '52';
                evaluateSBIIWithDifferentDBLScenario(ruleNo52, request);// modified by supriya johari under Issue-08754
            }
            else if(!vendor_has_existing_license_with_same_client.isEmpty()
                    && !(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I)
                         || vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)
                         || vendor_has_existing_license_with_same_client.containsKey(CONTRACT_SALESFORCE))) {
                             system.debug('point 56 is covered.');
                             numberOfScenariosSatisfied++;
                             scenariosSatisfiedDetails.add('Service Bureau II Condition 56');
                             contractTypeRequired = SERVICE_BUREAU_II;
                             isAmaLicenseRequired = true;
                             
                             Set<String> availableContractTypes = vendor_has_existing_license_with_same_client.keySet();
                             AMA_Contract_Detail__c existingWithSameClient = getExistingContractDetailForDifferentTypes(availableContractTypes, vendor_has_existing_license_with_same_client);
                             
                             // update the Ex Contract Detail section
                             if(existingWithSameClient != null)
                             {
                                 updatingExContractDetail(existingWithSameClient);
                             }
                             vendorHasLicence = 'has no existing Licence with AMA';
                             amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                             amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); //Added By Neha Bansal Under CR-11895
                             
                             
                         }
            else if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I) || vendor_has_existing_license_with_same_client.containsKey(CONTRACT_SALESFORCE)) {
                system.debug('point 57 is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau II Condition 57');
                contractTypeRequired = SERVICE_BUREAU_II;
                vendorHasLicence = 'has no existing Licence with AMA';
                isAmaLicenseRequired = true;
                String existingContractType = '';
                if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I))
                {
                    existingContractType = SERVICE_BUREAU_I;
                }
                else
                {
                    existingContractType = CONTRACT_SALESFORCE;
                }
                
                List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                AMA_Contract_Detail__c existingAMAContractDetailObj = getExistingContractDetail(existingAMAContractDetailList);
                //Update agreement detail object with existing contract detail
                updatingExContractDetail(existingAMAContractDetailObj);
                
                amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); //Added By Neha Bansal Under CR-11895
            }
            else if(!vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II) && !vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II)) { //***added by supriya johari under CR Issue-08754 starts*** //
                system.debug('point 58 is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau II Condition 58');
                contractTypeRequired = SERVICE_BUREAU_II;
                vendorHasLicence = 'has no existing Licence with AMA';
                isAmaLicenseRequired = true;
                amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                
            }
        }
        
    }
    //Added By Neha Under CR-11891 Ends
    
    /**
* Name: evaluateServiceBureauIIDueToUseConditions
* author: Supriya Johari
* @param: isSBIIUseDueToFrequencyAndUse, amaDataPeriod, amaFrequencyOfDelivery, request
* @return:
* Desc: to evaluate Service Bureau II due to use
**/
    private static void evaluateServiceBureauIIDueToUseConditions(Boolean isSBIIUseDueToUse, String amaDataPeriod, TPA_Request__c request) {
        if(isSBIIUseDueToUse &&  amaDataPeriod.equalsIgnoreCase('90 days or less')) {
            system.debug('Service Bureau II (SBII) Scenarios due to USE starts  ');
            if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)) {
                system.debug('point 34 is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau II Condition 34');
                vendor_has_existing_license_with_client_listed = true;
                vendor_has_no_any_existing_license_with_client_listed = false;
                //As per the business requirement explicitly mentioned i.e. If come across duplicates DBL for Service Bureau II, Contract Sales Force it would need to be manual review
                if(dblValuesWithSameClient.get(SERVICE_BUREAU_II).size() > 1) {
                    amaManualReview = true;
                    isAmaLicenseRequired = false;
                    contractTypeRequired = SERVICE_BUREAU_II;
                    addReason(request,'Vendor has SBII with multiple DBLS');
                    addReasonCommercial(request, 'Vendor has SBII with multiple DBLS', null, null);
                    addAMAReason(amaAgreementDetails, 'Vendor has SBII with multiple DBLS');
                    reasonForAmaApprovalMap.put( System.Label.TPA_AMA_Vendor_has_Service_Bureau_II_with_multiple_DBLS,'Vendor has Service Bureau II with multiple DBLS;This requires TP Processor manual handling to determine contract type;Determine AMA contract required' );
                } else {
                    String existingContractType = SERVICE_BUREAU_II;
                    List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                    AMA_Contract_Detail__c existingAMAContractDetailObj = getExistingContractDetail(existingAMAContractDetailList);
                    isAmaLicenseRequired = false;
                    contractTypeRequired = SERVICE_BUREAU_II;
                    amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                    //Update agreement detail object with existing contract detail
                    updatingExContractDetail(existingAMAContractDetailObj);
                }
            }
            else if(vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II)) {
                system.debug('in Condition 35');
                String ruleNo35 = '35';
                evaluateSBIIWithDifferentDBLScenario(ruleNo35, request);// modified by supriya johari under Issue-08754
            }
            else if(!vendor_has_existing_license_with_same_client.isEmpty() && !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)) {
                system.debug('point 36 is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau II Condition 36');
                contractTypeRequired = SERVICE_BUREAU_II;
                vendorHasLicence = 'has no existing Licence with AMA';
                isAmaLicenseRequired = true;
                
                Set<String> availableContractTypes = vendor_has_existing_license_with_same_client.keySet();
                AMA_Contract_Detail__c existingWithSameClient = getExistingContractDetailForDifferentTypes(availableContractTypes, vendor_has_existing_license_with_same_client);
                
                if(existingWithSameClient != null)
                {
                    updatingExContractDetail(existingWithSameClient);
                }
                amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); //Added By Neha Bansal Under CR-11895
            }
            else if(!vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II) && !vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II) ) { //***added by supriya johari under CR Issue-08754 starts*** //
                system.debug('point 33 is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau II Condition 33');
                contractTypeRequired = SERVICE_BUREAU_II;
                isAmaLicenseRequired = true;
                vendorHasLicence = 'has no existing Licence with AMA';
                amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
            }
        }
        //*** Service Bureau II (SBII) Scenarios due to USE ends ***//
    }
    
    /**
* Name: evaluateServiceBureauIIGreaterThan90DaysConditions
* author: Supriya Johari
* @param: isSBIIUseDueToFrequencyAndUse, amaDataPeriod, amaFrequencyOfDelivery, request
* @return:
* Desc: to evaluate Service Bureau II 90 days Or Less Conditions
**/
    private static void evaluateServiceBureauIIGreaterThan90DaysConditions(Boolean isSBIIUsesGreaterThan90,String amaDataPeriod, TPA_Request__c request) {
        if(isSBIIUsesGreaterThan90 && amaDataPeriod.equalsIgnoreCase('Greater than 90 days')) {
            system.debug('Greater than 90-days scenarios that fall under Service Bureau II (SBII) starts');
            if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II))  {
                system.debug('point 37 is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau II Condition 37');
                vendor_has_existing_license_with_client_listed = true;
                vendor_has_no_any_existing_license_with_client_listed = false;
                //As per the business requirement explicitly mentioned i.e. If come across duplicates DBL for Service Bureau II, Contract Sales Force it would need to be manual review
                if(dblValuesWithSameClient.get(SERVICE_BUREAU_II).size() > 1) {
                    amaManualReview = true;
                    isAmaLicenseRequired = false;
                    contractTypeRequired = SERVICE_BUREAU_II;
                    addReason(request,'Vendor has SBII with multiple DBLS');
                    addReasonCommercial(request, 'Vendor has SBII with multiple DBLS', null, null);
                    addAMAReason(amaAgreementDetails, 'Vendor has SBII with multiple DBLS');
                    reasonForAmaApprovalMap.put( System.Label.TPA_AMA_Vendor_has_Service_Bureau_II_with_multiple_DBLS,'Vendor has Service Bureau II with multiple DBLS;This requires TP Processor manual handling to determine contract type;Determine AMA contract required' );
                } else {
                    // NOT create Service Bureau II agreement, existing will cover the project.
                    String existingContractType = SERVICE_BUREAU_II;
                    List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                    AMA_Contract_Detail__c existingAMAContractDetailObj = getExistingContractDetail(existingAMAContractDetailList);
                    isAmaLicenseRequired = false;
                    contractTypeRequired = SERVICE_BUREAU_II;
                    amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                    //Update agreement detail object with existing contract detail
                    updatingExContractDetail(existingAMAContractDetailObj);
                }
            }
            else if(vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II)) {
                system.debug('in Condition 39');
                String ruleNo39 = '39';
                evaluateSBIIWithDifferentDBLScenario(ruleNo39, request);// modified by supriya johari under Issue-08754
                
            }
            else if(!vendor_has_existing_license_with_same_client.isEmpty()
                    && !(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I)
                         || vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)
                         || vendor_has_existing_license_with_same_client.containsKey(CONTRACT_SALESFORCE))) {
                             system.debug('point 40 is covered.');
                             numberOfScenariosSatisfied++;
                             scenariosSatisfiedDetails.add('Service Bureau II Condition 40');
                             contractTypeRequired = SERVICE_BUREAU_II;
                             isAmaLicenseRequired = true;
                             
                             Set<String> availableContractTypes = vendor_has_existing_license_with_same_client.keySet();
                             AMA_Contract_Detail__c existingWithSameClient = getExistingContractDetailForDifferentTypes(availableContractTypes, vendor_has_existing_license_with_same_client);
                             
                             // update the Ex Contract Detail section
                             if(existingWithSameClient != null)
                             {
                                 updatingExContractDetail(existingWithSameClient);
                             }
                             vendorHasLicence = 'has no existing Licence with AMA';
                             amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                             amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); //Added By Neha Bansal Under CR-11895
                         }
            else if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I) || vendor_has_existing_license_with_same_client.containsKey(CONTRACT_SALESFORCE)) {
                system.debug('point 41 is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau II Condition 41');
                contractTypeRequired = SERVICE_BUREAU_II;
                vendorHasLicence = 'has no existing Licence with AMA';
               isAmaLicenseRequired = true;
                String existingContractType = '';
                if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_I))
                {
                    existingContractType = SERVICE_BUREAU_I;
                }
                else
                {
                    existingContractType = CONTRACT_SALESFORCE;
                }
                
                List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(existingContractType);
                AMA_Contract_Detail__c existingAMAContractDetailObj = getExistingContractDetail(existingAMAContractDetailList);
                //Update agreement detail object with existing contract detail
                updatingExContractDetail(existingAMAContractDetailObj);
                
                amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); //Added By Neha Bansal Under CR-11895
            }
            else if(!vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II) && !vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II)) { //***added by supriya johari under CR Issue-08754 starts*** //
                system.debug('point 38 is covered.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau II Condition 38');
                contractTypeRequired = SERVICE_BUREAU_II;
                vendorHasLicence = 'has no existing Licence with AMA';
                isAmaLicenseRequired = true;
                amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); //Added By Neha Bansal Under CR-11895
                
            } //***added by supriya johari under CR Issue-08754 ends*** //
        }
        //*** Greater than 90-days scenarios that fall under Service Bureau II (SBII) ends ***//
    }
    
    /**
* Name: evaluateSBIIWithDifferentDBLScenario
* author: Supriya Johari
* @param: String rule no.
* @return: null
* Desc: to check various conditions For SBII perform then condition according combination of maxed fee reached and existing DBL value with DIfferent Client
**/
    private static void evaluateSBIIWithDifferentDBLScenario (String ruleNo, TPA_Request__c request) { // modified by supriya johari under Issue-08754
        List<AMA_Contract_Detail__c> recordsWithDifferentDbls = vendor_has_existing_license_with_other_client.get(SERVICE_BUREAU_II);
        AMA_Contract_Detail__c existingWithDifferentDbl;
        String dblValue = 'iqvia'; 
        Boolean existImsAsDBL = false;
        if(recordsWithDifferentDbls.size() > 0)
        {
            for(AMA_Contract_Detail__c amaContractDetailObj: recordsWithDifferentDbls)
            {
                if(amaContractDetailObj.DBL__c != null)
                {
                    String dblToLowerCase = amaContractDetailObj.DBL__c.toLowerCase();
                    if(dblToLowerCase.contains(dblValue))
                    {
                        existImsAsDBL =  true;
                        if( amaContractDetailObj.Contract_End_Date__c == null || amaContractDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() )// modified by Supriya Johari under Issue-08675
                        {
                            existingWithDifferentDbl = amaContractDetailObj;
                            break;
                        }
                        else
                        {
                            existingWithDifferentDbl = amaContractDetailObj;
                        }
                    }
                    else
                    {
                        if(existingWithDifferentDbl ==  null)
                        {
                            if(amaContractDetailObj.Contract_End_Date__c == null || amaContractDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() ) // modified by Supriya Johari under Issue-08675
                            {
                                existingWithDifferentDbl = amaContractDetailObj;
                            }
                        }
                    }
                    
                }
                
            }
            
            if(existingWithDifferentDbl ==  null)
            {
                for(AMA_Contract_Detail__c amaContractDetailObj: recordsWithDifferentDbls)
                {
                    if(amaContractDetailObj.DBL__c != null )
                    {
                        existingWithDifferentDbl = amaContractDetailObj;
                        break;
                    }
                }
            }
            
            if(existingWithDifferentDbl !=  null && existImsAsDBL && maxFeesReached)
            {
                if(isAMAPerpetualAgreement_US_Only){
                    system.debug('point '+ruleNo+' a) is covered.');
                    numberOfScenariosSatisfied++;
                    if (!ruleNo.equals('52'))
                        scenariosSatisfiedDetails.add('Service Bureau II Condition '+ruleNo+' a)');
                    else
                        scenariosSatisfiedDetails.add('Service Bureau II Condition 52' );
                    vendor_has_existing_license_with_different_client_listed = true;
                    contractTypeRequired = SBII_AMENDMENT; 
                    
                    isAmaLicenseRequired = true;
                    vendorHasLicence = 'has existing licence with different client listed on TPA form';
                    // update Existing Contract detaiil section
                    updatingExContractDetail(existingWithDifferentDbl);
                    
                    //Update the Agreement record with the existing AMA Contract type, Fees and DBL that is covering the project. Means-(Contract type=?CSF?,DBL=?IMS?,Fees=36000$)
                    amaAgreementDetails.Contract_Type__c = SBII_AMENDMENT;
                    amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                }else{
                    numberOfScenariosSatisfied++;
                    if (!ruleNo.equals('52'))
                        scenariosSatisfiedDetails.add('Service Bureau II Condition '+ruleNo+' a) Without Has AMA Perpetual Agreement (U.S. Only):');
                    else
                        scenariosSatisfiedDetails.add('Service Bureau II Condition 52 Without Has AMA Perpetual Agreement (U.S. Only):' );
                    vendor_has_existing_license_with_different_client_listed = true;
                    contractTypeRequired = SERVICE_BUREAU_II;
                    isAmaLicenseRequired = true;
                    vendorHasLicence = 'has existing licence with different client listed on TPA form';
                    updatingExContractDetail(existingWithDifferentDbl);
                    amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                    amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA);

                }
                
                
                
            }else if( existingWithDifferentDbl !=  null && existImsAsDBL && !maxFeesReached)
            {
                system.debug('point '+ruleNo+' b) is covered.');
                numberOfScenariosSatisfied++;
                if (!ruleNo.equals('52'))
                    scenariosSatisfiedDetails.add('Service Bureau II Condition '+ruleNo+' b)');
                else
                    scenariosSatisfiedDetails.add('Service Bureau II Condition 53');
                
                vendor_has_existing_license_with_different_client_listed = true;
                contractTypeRequired = SERVICE_BUREAU_II;
                isAmaLicenseRequired = true;
                amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                updatingExContractDetail(existingWithDifferentDbl);
                amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); //Added By Neha Bansal Under CR-11895
                vendorHasLicence = 'has existing licence with different client listed on TPA form';
                
            }else if(existingWithDifferentDbl != null && !existImsAsDBL && maxFeesReached)
            {
                numberOfScenariosSatisfied++;
                if (!ruleNo.equals('52'))
                    scenariosSatisfiedDetails.add('Service Bureau II Condition '+ruleNo+' c)');
                else{
                    scenariosSatisfiedDetails.add('Service Bureau II Condition 54');
                }
                
                vendor_has_existing_license_with_different_client_listed = true;
                contractTypeRequired = SERVICE_BUREAU_II;
                isAmaLicenseRequired = false;
                vendorHasLicence = 'has existing licence with different client listed on TPA form';
                amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                updatingExContractDetail(existingWithDifferentDbl);
                notifyViaMail = true;
                
            }else if(existingWithDifferentDbl !=  null && !existImsAsDBL && !maxFeesReached)
            {
                system.debug('point '+ruleNo+' d) is covered.');
                numberOfScenariosSatisfied++;
                if (!ruleNo.equals('52'))
                    scenariosSatisfiedDetails.add('Service Bureau II Condition '+ruleNo+' d)');
                else{
                    scenariosSatisfiedDetails.add('Service Bureau II Condition 55');
                }
                
                vendor_has_existing_license_with_different_client_listed = true;
                contractTypeRequired = SERVICE_BUREAU_II;
                isAmaLicenseRequired = true;
                amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                updatingExContractDetail(existingWithDifferentDbl);
                amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA); 
                vendorHasLicence = 'has existing licence with different client listed on TPA form';
                
            }
        }
        
    }
    
    /**
* Name: getExistingContractDetail
* author: Supriya Johari
* @param:
* @return:
* Desc: to get Existing Contract Detail Record for particular contract type while updating Existing AMA Contract Detail Section
**/
    private static AMA_Contract_Detail__c getExistingContractDetail (List<AMA_Contract_Detail__c> existingRecords) {
        
        AMA_Contract_Detail__c contractDetailObj;
        if(existingRecords != null && existingRecords.size() > 0)
        {
            for(AMA_Contract_Detail__c amaContractDetailObj: existingRecords)
            {
                if( amaContractDetailObj.Contract_End_Date__c == null || amaContractDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() ) // modified by Supriya Johari under Issue-08675
                {
                    contractDetailObj = amaContractDetailObj;
                    break;
                }
            }
            if(contractDetailObj == null) {
                contractDetailObj =  existingRecords.get(0);
            }
        }
        
        
        return contractDetailObj;
        
    }
    
    /**
* Name: getExistingContractDetailForDifferentTypes
* author: Supriya Johari
* @param:
* @return:
* Desc: to get Existing Contract Detail Record for particular contract type while updating Existing AMA Contract Detail Section
**/
    private static AMA_Contract_Detail__c getExistingContractDetailForDifferentTypes (Set<String> availableContractTypes, Map<String,List<AMA_Contract_Detail__c>> mapForExistingContractTypes) {
        AMA_Contract_Detail__c contractDetailObj = new AMA_Contract_Detail__c();
        if(availableContractTypes != null && availableContractTypes.size() > 0 && mapForExistingContractTypes != null) {
            Integer counter = 0;
            for(String contractType: availableContractTypes) {
                counter++;
                List<AMA_Contract_Detail__c> amaContractDetailObjList = mapForExistingContractTypes.get(contractType);
                contractDetailObj = getExistingContractDetail(amaContractDetailObjList);
                if(contractDetailObj != null && (contractDetailObj.Contract_End_Date__c!= null && contractDetailObj.Contract_End_Date__c.year() < amaAgreementDetails.Agreement_End_Date__c.year() ) && counter < availableContractTypes.size()) { // modified by Supriya Johari under Issue-08675
                    continue;
                }
                break;
            }
        }
        return contractDetailObj;
        
    }
    
    /**
* Name: resetAmaAgreementDetail
* author: Supriya Johari
* @param:
* @return: to reset the existing Contract Detail fields in ama agreement Detail
* Desc: to reset the existing Contract Detail fields in ama agreement Detail
**/
    private static void resetAmaAgreementDetail () {
        amaAgreementDetails.Contract_Type__c =  null;
        amaAgreementDetails.DBL__c =  null;
        amaAgreementDetails.Is_Prorated__c =  false;
        amaAgreementDetails.License_Term__c   =  null;
        amaAgreementDetails.Current_Year_Fees__c  = null;
        amaAgreementDetails.Next_Year_Fees__c =  null;
        amaAgreementDetails.Fee_Reduced__c =  null;
        amaAgreementDetails.Max_Fee_Reached__c =  false;
        amaAgreementDetails.Template__c = null;
        amaAgreementDetails.Send_copy_of_the_invoice__c = null;
        amaAgreementDetails.Invoice_Contact__c = null;
        amaAgreementDetails.Invoice_Contact_Email__c = null;
        resetExContractDetail ();
        resetFeeRule();
        resetTheOffshoreSection();
    }
    
    
    
    /**
* Name: resetAllAmaAgreementDetail
* author: Supriya Johari
* @param:
* @return: to reset the existing Contract Detail fields in ama agreement Detail
* Desc: to reset the existing Contract Detail fields in ama agreement Detail
**/
    public static void resetAllAmaAgreementDetail () {
        if(amaAgreementDetails != null)
        {
            system.debug( 'object :'+ amaAgreementDetails);
            resetAmaAgreementDetail();
            amaAgreementDetails.AMA_Manual_Review__c =  false;
            amaAgreementDetails.Is_AMA_License_Required__c =  false;
            amaAgreementDetails.AMA_Manual_Trigger_Reasons__c = null;
            amaAgreementDetails.Number_Of_Scenarios_Satisfied__c = null;
            amaAgreementDetails.Scenarios_Satisfied_Details__c= null;
            amaAgreementDetails.Send_DBL_Notification_To_AMA__c = false;
            if(amaAgreementDetails.Vendor_AMA_Fee_Response__c != null && amaAgreementDetails.Vendor_AMA_Fee_Response__c == 'declined'){
                amaAgreementDetails.Vendor_AMA_Fee_Response__c = null;
            }
            
            update amaAgreementDetails;
        }
    }
    
    /**
* Name: updatingExContractDetail
* author: Supriya Johari
* @param: amaContractDetail Object
* @return: to update the existing Contract Detail fields in ama agreement Detail
* Desc: to update the existing Contract Detail fields in ama agreement Detail
**/
    private static void updatingExContractDetail (AMA_Contract_Detail__c amaContractDetailObj) {
        if(amaContractDetailObj != null)
        {
            amaAgreementDetails.DBL__c = getDBLValue(amaContractDetailObj.DBL__c);
            amaAgreementDetails.Ex_TPA_AMA_Contract_Detail__c = amaContractDetailObj.id;
            amaAgreementDetails.Ex_TPA_AMA_Contract_Detail_Name__c = amaContractDetailObj.name;
            amaAgreementDetails.Ex_Client__c = amaContractDetailObj.Client__c;
            amaAgreementDetails.Ex_DBL__c = amaContractDetailObj.DBL__c;
            amaAgreementDetails.Ex_Client_Services_On_Behalf_Of__c = amaContractDetailObj.Client_Services_On_Behalf_Of__c;
            amaAgreementDetails.Ex_Contract_Type__c = amaContractDetailObj.Contract_Type__c;
            amaAgreementDetails.Ex_Contract_List_Type__c = amaContractDetailObj.Contract_List_Type__c;
            amaAgreementDetails.Ex_Contract_End_Date__c = amaContractDetailObj.Contract_End_Date__c;
            amaAgreementDetails.Ex_Max_Fee_Reached__c = amaContractDetailObj.Max_Fee_Reached__c;
            amaAgreementDetails.Ex_Offshore_Storage__c = amaContractDetailObj.Offshore_Storage__c; // Modified By Neha Bansal under CR-12673
            amaAgreementDetails.Ex_Offshore_Access__c = amaContractDetailObj.Offshore_Access__c; // Modified By Neha Bansal under CR-12673
            amaAgreementDetails.Ex_Special_Terms_Conditions__c = amaContractDetailObj.Special_Terms_And_Conditions__c;
        }
    }
    
    /**
* Name: resetExContractDetail
* author: Supriya Johari
* @param:
* @return: to reset the existing Contract Detail fields in ama agreement Detail
* Desc: to reset the existing Contract Detail fields in ama agreement Detail
**/
    private static void resetExContractDetail () {
        //reset the values of Ex AMA contract detail
        amaAgreementDetails.Ex_Client__c = null;
        amaAgreementDetails.Ex_DBL__c = null;
        amaAgreementDetails.Ex_TPA_AMA_Contract_Detail__c =  null;
        amaAgreementDetails.Ex_TPA_AMA_Contract_Detail_Name__c =  null;
        amaAgreementDetails.Ex_Client_Services_On_Behalf_Of__c = null;
        amaAgreementDetails.Ex_Contract_Type__c = null;
        amaAgreementDetails.Ex_Contract_List_Type__c = null;
        amaAgreementDetails.Ex_Contract_End_Date__c = null;
        amaAgreementDetails.Ex_Max_Fee_Reached__c = false;
        amaAgreementDetails.Ex_Offshore_Storage__c = null; // Modified By Neha Bansal under CR-12673
        amaAgreementDetails.Ex_Offshore_Access__c = null; // Modified By Neha Bansal under CR-12673
        amaAgreementDetails.Ex_Special_Terms_Conditions__c = null;
    }
    
    /**
* Name: resetBasicAmaAgreementDetail
* author: Supriya Johari
* @param:
* @return: to reset the Ama agreement Detail fields  of section -1 in ama agreement Detail
* Desc: to reset the existing basic Ama agreement detail fields in ama agreement Detail
**/
    private static void resetBasicAmaAgreementDetail () {
        numberOfScenariosSatisfied = 0;
        scenariosSatisfiedDetails.clear();
        contractTypeRequired =  null;
        amaAgreementDetails.Contract_Type__c = null;
        if(amaManualReview == true) {
            amaManualReview =  false;
            reasonForAmaApprovalMap.clear();
            amaAgreementDetails.AMA_Manual_Trigger_Reasons__c = null;
        }
    }
    
    
    /**
* Name: ProrateFeeForCurrentYear
* @param:
* @return: to check whether fee is prorated
* Desc:
**/
    private static Decimal ProratedFeeForCurrentYear(Decimal fee) {
        system.debug('entered in Prorated fee For current year');
        Date projectStartDate = amaAgreementDetails.Agreement_Start_Date__c;
        Integer currentYear = Integer.valueOf(amaAgreementDetails.Current_Year__c);
        Decimal currentYearFee = 0;
        Date expectedDateJuly = date.newInstance(currentYear, 7,1);
        Date expectedDateOct = date.newInstance(currentYear,10,1);
        Date expectedDateDec = date.newInstance(currentYear,12,16);
        if(projectStartDate < expectedDateJuly) {
            currentYearFee = fee;
            amaAgreementDetails.Fee_Reduced__c = 0;
            amaAgreementDetails.Is_Prorated__c = false;
        } else if(projectStartDate >= expectedDateJuly && projectStartDate < expectedDateOct ) {
            currentYearFee = fee * 0.50;
            amaAgreementDetails.Fee_Reduced__c = 50;
            amaAgreementDetails.Is_Prorated__c = true;
        } else if(projectStartDate >= expectedDateOct && projectStartDate < expectedDateDec) {
            currentYearFee = fee * 0.25;
            amaAgreementDetails.Fee_Reduced__c = 75;
            amaAgreementDetails.Is_Prorated__c = true;
        } else if( projectStartDate >= expectedDateDec) {
            currentYearFee = 0;
            amaAgreementDetails.Is_Prorated__c = true;
            amaAgreementDetails.Fee_Reduced__c = 100;
        }
        return currentYearFee;
    }
    
    /**
* Name: UpdatingFeeRuleDetail
* @param: amaContractDetail Object
* @return: to update the existing Contract Detail fields in ama agreement Detail
* Desc: to update the existing Contract Detail fields in ama agreement Detail
**/
    private static void updatingFeeRuleDetail (AMA_Fee_Master__c amaFeeMasterObj) {
        amaAgreementDetails.Fee_Rule_Contract_Type__c = amaFeeMasterObj.Contract_Type__c;
        amaAgreementDetails.Fee_Rule_Fee__c = amaFeeMasterObj.Fee__c    ;
        amaAgreementDetails.Fee_Rule_Fee_Calculated__c = amaFeeMasterObj.Fee_Calculated__c;
        amaAgreementDetails.Fee_Rule_Proration_Rules_Applied__c  = amaFeeMasterObj.Proration_Rules_Applied__c;
        amaAgreementDetails.Fee_Rule_Vendor_has_Licence__c = amaFeeMasterObj.Vendor_has_Licence__c;
        amaAgreementDetails.Fee_Rule_Year__c = amaFeeMasterObj.Year__c;
    }
    
    /**
* Name: resetTheFeeRule
* @param:
* @return: to reset the existing Contract Detail fields in ama agreement Detail
* Desc: to reset the existing Contract Detail fields in ama agreement Detail
**/
    private static void resetFeeRule () {
        amaAgreementDetails.Fee_Rule_Contract_Type__c = null;
        amaAgreementDetails.Fee_Rule_Fee__c = null ;
        amaAgreementDetails.Fee_Rule_Fee_Calculated__c = null;
        amaAgreementDetails.Fee_Rule_Proration_Rules_Applied__c  = false;
        amaAgreementDetails.Fee_Rule_Vendor_has_Licence__c = null;
        amaAgreementDetails.Fee_Rule_Year__c = null;
    }
    
    // added by supriya Johari under Issue-09770
    /**
* Name: resetTheOffshoreSection
* @param:
* @return: to reset the Offshore section fields in ama agreement Detail
* Desc: to reset the Offshore section fields in ama agreement Detail
**/
    
    private static void resetTheOffshoreSection () {
        
        if(amaAgreementDetails != null) {
            amaAgreementDetails.Where_will_the_data_reside__c  = null;
            amaAgreementDetails.pharmaceutical_client_accessed_overseas__c  = null ;
            amaAgreementDetails.service_provider_accessed_overseas__c  = null;
            amaAgreementDetails.With_the_overseas_entity__c  = null;
            amaAgreementDetails.Tell_us_about_the_project__c  = null;
            amaAgreementDetails.Volume_of_records__c  = null;
            amaAgreementDetails.Specific_variables_requested__c  = null;
            amaAgreementDetails.offshore_entity_interacting_with_data__c  = null;
            amaAgreementDetails.How_will_the_data_be_accessed__c  = null;
            amaAgreementDetails.HTTPS_VPN_Other__c  = null;
            amaAgreementDetails.app_software_used_at_offshore__c = null;
            amaAgreementDetails.Data_security_procedures_used__c = null;
            amaAgreementDetails.Encryption__c = null;
            amaAgreementDetails.Can_data_be_downloaded_or_printed__c  = null;
            amaAgreementDetails.Firewall_port_filtering_technologies__c   = null;
            amaAgreementDetails.Other__c   = null;
            amaAgreementDetails.physical_security_procedures__c   = null;
            amaAgreementDetails.Portable_storage_devices_allowed__c    = null;
            amaAgreementDetails.Employees_have_wireless_connectivity__c    = null;
            amaAgreementDetails.Is_area_secure__c  = null;
            amaAgreementDetails.Number_of_computers_used__c    = null;
            amaAgreementDetails.Additional_technologies_used__c    = null;
            amaAgreementDetails.Status_of_Offshore_Questionnaire__c    = null;
            amaAgreementDetails.Last_Vendor_Offshore_Reminder_Mail_Sent__c   = null;
            amaAgreementDetails.Status_of_Offshore_Process__c = null;
            amaAgreementDetails.Technologies_to_access_AMA_PPD_by_vendor__c =  null;
            amaAgreementDetails.Other_technology_to_access_AMA_PPD__c = null;
            amaAgreementDetails.Questions_for_Vendor_Response__c = null;
            amaAgreementDetails.Vendor_Name_who_requested_offshore__c = null;
            amaAgreementDetails.AMA_reasons_why_offshore_not_approved__c = null;
            amaAgreementDetails.Title_for_vendor_who_requested_offshore__c = null;
            amaAgreementDetails.Last_AMA_offshore_reminder_mail_sent__c = null;
            amaAgreementDetails.Date_vendor_responded_for_offshore__c = null;
            amaAgreementDetails.AMA_Response__c = null;
            amaAgreementDetails.Is_Foreign_License_Required__c = false;
            amaAgreementDetails.Is_Offshore_Access_Amendment_Required__c = false;
            amaAgreementDetails.Is_Offshore_Access_Amendment_to_FL_Req__c = false;
            amaAgreementDetails.Is_Offshore_Consent_Form_Req__c = false;
            amaAgreementDetails.Is_Off_Access_Amendment_Req_WithNALoc__c = false;
        amaAgreementDetails.AMA_Foreign_Storage_Contract_Type__c = null;
        amaAgreementDetails.Foreign_Storage_Current_Year_Fees__c = null;
        amaAgreementDetails.Foreign_Storage_Next_Year_Fees__c = null;
            
        }
    }
    
    public static String generateAmaAgreement(TPA_Request__c request) {
        String templateId = '';
        String templateName = '';
        String year = request.AMA_Agreement_Details__r[0].Current_Year__c;
        //Gettting template name to be generated
        if(request.AMA_Agreement_Details__r[0].Is_Offshore_Access_Amendment_Required__c){
            templateName = year + ' '+'AMA Offshore Access Amendment'; 
        }
        else if(request.AMA_Agreement_Details__r[0].Contract_Type__c.equalsIgnoreCase(LETTERSHOP)){
            templateName = year + ' '+'LS';
        }
        else if(request.AMA_Agreement_Details__r[0].Contract_Type__c.equalsIgnoreCase(SERVICE_BUREAU_I)){
            templateName = year + ' '+'SB1';
        }
        else if(request.AMA_Agreement_Details__r[0].Contract_Type__c.equalsIgnoreCase(SERVICE_BUREAU_II)){
            templateName =  year + ' '+'SB2';
        }
        else if(request.AMA_Agreement_Details__r[0].Contract_Type__c.equalsIgnoreCase(CONTRACT_SALESFORCE)){
            templateName =  year + ' '+'CSF';
        }
        else if(request.AMA_Agreement_Details__r[0].Contract_Type__c.equalsIgnoreCase(SBI_EO_For_Amgen)){
            templateName =  year + ' '+'SB I Evaluation Overlap for Amgen';
        }
        else if(request.AMA_Agreement_Details__r[0].Contract_Type__c.equalsIgnoreCase(CSF_AMENDMENT)){
            templateName =  year + ' '+'AMA-PPD CSF Agreement Amendment';
        }
        else if(request.AMA_Agreement_Details__r[0].Contract_Type__c.equalsIgnoreCase(SBII_AMENDMENT)){
            templateName =  year + ' '+'AMA-PPD SB2 Agreement Amendment';
        }
        /*else if(request.AMA_Agreement_Details__r[0].Contract_Type__c.equalsIgnoreCase(PSA_SERVICE_BUREAU)){
            templateName =  year + ' '+'AMA PSA Amendment';
        }*/
        else if(request.AMA_Agreement_Details__r[0].Contract_Type__c.equalsIgnoreCase(LS_EXUS_ENTITY_FOREIGN)){
            templateName =  year + ' '+'LS ExUS Entity Foreign License';
        }
        else if(request.AMA_Agreement_Details__r[0].Contract_Type__c.equalsIgnoreCase(SBI_EXUS_ENTITY_FOREIGN)){
            templateName =  year + ' '+'SBI ExUS Entity Foreign License';
        }
        else if(request.AMA_Agreement_Details__r[0].Contract_Type__c.equalsIgnoreCase(SBII_EXUS_ENTITY_FOREIGN)){
            templateName =  year + ' '+'SBII ExUS Entity Foreign License';
        }
        
        List<Apttus__APTS_Template__c> templates = [Select id,Name from Apttus__APTS_Template__c Where Name = :templateName AND Apttus__IsActive__c = TRUE LIMIT 1];
        system.debug(templates +'contract type' +'ama contract'+request.AMA_Agreement_Details__r[0].Contract_Type__c + 'template name '+ templateName );
        if(templates.size() > 0) {
            if(!Test.isRunningTest()) {
                System.debug('**Just before generating Agreement**template name**');
                templateId = templates[0].id;
            }
        }
        return templateId;
    }
    
    /**
* Name: getContractListForOwnBehalf
* author: Supriya Johari
* @param:
* @return:
* Desc: To get OwnBehalf Records from Contract List
* Added or modified: Added under CR-08669
**/
    private static void getContractListForOwnBehalf() {
        
        if(amaContractListForOwnBehalf == null)
        {
            amaContractListForOwnBehalf = [Select id, Name, Client__c, Client_Services_On_Behalf_Of__c,Contract_End_Date__c,Contract_List_Type__c, Contract_Type__c, DBL__c,
                                           Max_Fee_Reached__c,Offshore_Storage__c,Offshore_Access__c,Special_Terms_And_Conditions__c From AMA_Contract_Detail__c
                                           Where Client_Services_On_Behalf_Of__c LIKE '%Own Behalf%'];
        }
    }
    
    /**
* Name: getOwnBehalfAndSpecialContractsForVendor
* author: Supriya Johari
* @param:
* @return: Map<String,List<AMA_Contract_Detail__c>>
* Desc: To get OwnBehalf Records from Contract List for particular Venodr with special Contract Types which are :-'Medical/Diagnostic Equipment & Supply','Physician Specific Analysis','Physician Specific Analytics'
* Added or modified: Added under CR-08669 and modified under ER-3886
**/
    private static Map<String,List<AMA_Contract_Detail__c>> getOwnBehalfAndSpecialContractsForVendor() {
        
        Map<String,List<AMA_Contract_Detail__c>> ownBehalfSpecialListForVendor = new Map<String,List<AMA_Contract_Detail__c>> ();
        Map<String,List<AMA_Contract_Detail__c>> ownBehalfListForVendor = getOwnBehalfListForVendor();
        if(!ownBehalfListForVendor.isEmpty()){
            
            for(String specialContractType:UTL_TPA.specialContractTypes){
                
                if(ownBehalfListForVendor.containsKey(specialContractType.toLowerCase())){//Modified by Rajendra Under ER-11891
                    
                    ownBehalfSpecialListForVendor.put(specialContractType,ownBehalfListForVendor.get(specialContractType));
                }
            }
        }
        return ownBehalfSpecialListForVendor;
    }
    
    /**
* Name: getOwnBehalfListForVendor
* author: Supriya Johari
* @param:
* @return: Map<String,List<AMA_Contract_Detail__c>>
* Desc: To get OwnBehalf Records from Contract List for particular Venodr with special Contract Types which are :-'Medical/Diagnostic Equipment & Supply','Physician Specific Analysis','Physician Specific Analytics'
* Added or modified: Added under ER-3886
**/
    private static Map<String,List<AMA_Contract_Detail__c>> getOwnBehalfListForVendor() {
        
        getContractListForOwnBehalf();
        Map<String,List<AMA_Contract_Detail__c>> ownBehalfListForVendor = new Map<String,List<AMA_Contract_Detail__c>> ();
        if(amaContractListForOwnBehalf != null){
            
            for(AMA_Contract_Detail__c obj :amaContractListForOwnBehalf){
                
                String amaContractType =  obj.Contract_Type__c;
                List<AMA_Contract_Detail__c> contractDetailList;
                
                if(obj.Client__c != null && validVendorNameSet.contains(obj.Client__c.toLowerCase())
                   && String.isNotBlank(amaContractType)){
                       
                       if(ownBehalfListForVendor.containsKey(amaContractType)){
                           contractDetailList = ownBehalfListForVendor.get(amaContractType.toLowerCase());//Modified by Rajendra Under ER-11891
                       }
                       else{
                           contractDetailList = new List<AMA_Contract_Detail__c>();
                       }
                       contractDetailList.add(obj);
                       ownBehalfListForVendor.put(amaContractType.toLowerCase(),contractDetailList);//Modified by Rajendra Under ER-11891
                   }
            }
        }
        return ownBehalfListForVendor;
        
    }

    //Added By Neha Bansal under CR-12673 Starts

    private static Map<String,List<AMA_Contract_Detail__c>> getOwnBehalfListForClient() {

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

    // Added By Neha Bansal under CR-12673 Ends
    
    private static void evaluateCondition60to65SBII(Boolean isCondition60To65Uses, String amaDataPeriod, String amaFrequencyOfDelivery, TPA_Request__c request) {
        System.debug('In evaluation of condition 60 to 65'+' (isCondition60To65Uses) --> ' + (isCondition60To65Uses == true)+ ' amaDataPeriod--> '+ amaDataPeriod.equalsIgnoreCase('90 days or less') + ' amaFrequencyOfDelivery--> '+ amaFrequencyOfDelivery);
        Boolean isMaxFeeReached = false;
        Boolean existIQVIAAsDBL = false;
        String dblValue = 'iqvia';
        AMA_Contract_Detail__c existingWithDifferentDbl = new AMA_Contract_Detail__c();
        sObject emptyObject = new AMA_Contract_Detail__c();
        List<AMA_Contract_Detail__c> recordsWithDifferentDbls = new List<AMA_Contract_Detail__c>();
        recordsWithDifferentDbls = vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II)? vendor_has_existing_license_with_other_client.get(SERVICE_BUREAU_II): new List<AMA_Contract_Detail__c>();
        if(recordsWithDifferentDbls.size() > 0){
            System.debug('recordsWithDifferentDbls--> '+ recordsWithDifferentDbls);
            for(AMA_Contract_Detail__c amaContractDetailObj: recordsWithDifferentDbls){
                if(amaContractDetailObj.Max_Fee_Reached__c){
                    isMaxFeeReached = true;
                }
                if(amaContractDetailObj.DBL__c != null)
                {
                    System.debug('recordsWithDifferentDbls--> if'+ existingWithDifferentDbl);
                    String dblToLowerCase = amaContractDetailObj.DBL__c.toLowerCase();
                    if(dblToLowerCase.contains(dblValue))
                    {
                        existIQVIAAsDBL =  true;
                        if( amaContractDetailObj.Contract_End_Date__c == null || amaContractDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() )
                        {
                            existingWithDifferentDbl = amaContractDetailObj;
                            break;
                        }
                        else
                        {
                            existingWithDifferentDbl = amaContractDetailObj;
                        }
                    }
                    else
                    {
                        System.debug('recordsWithDifferentDbls--> else'+ existingWithDifferentDbl);
                        if(existingWithDifferentDbl == null)
                        {
                            System.debug('recordsWithDifferentDbls--> else'+ existingWithDifferentDbl);
                            if(amaContractDetailObj.Contract_End_Date__c == null || amaContractDetailObj.Contract_End_Date__c.year() >= amaAgreementDetails.Agreement_End_Date__c.year() )
                            {
                                existingWithDifferentDbl = amaContractDetailObj;
                                System.debug('recordsWithDifferentDbls--> else'+ existingWithDifferentDbl);
                            }
                        }
                    }
                    System.debug('recordsWithDifferentDbls--> else'+ existingWithDifferentDbl);
                }
            }
        }
        
        if(existingWithDifferentDbl == emptyObject)
        {
            for(AMA_Contract_Detail__c amaContractDetailObj: recordsWithDifferentDbls)
            {
                if(amaContractDetailObj.DBL__c != null )
                {
                    existingWithDifferentDbl = amaContractDetailObj;
                    break;
                }
            }
        }
        
        System.debug('In evaluation of condition 60 to 65'+' (isCondition60To65Uses) --> ' + (isCondition60To65Uses == true)+ ' amaDataPeriod--> '+ amaDataPeriod.equalsIgnoreCase('90 days or less') + ' amaFrequencyOfDelivery--> '+ amaFrequencyOfDelivery + ' '+!amaFrequencyOfDelivery.equalsIgnoreCase('Quarterly') + ' '+!amaFrequencyOfDelivery.equalsIgnoreCase('One-time'));
        System.debug(vendor_has_existing_license_with_same_client.keySet());
        if(isCondition60To65Uses && amaDataPeriod.equalsIgnoreCase('90 days or less') && !amaFrequencyOfDelivery.equalsIgnoreCase('Quarterly') && !amaFrequencyOfDelivery.equalsIgnoreCase('One-time')){
            System.debug('Condition 60 to 65 if.');
            if(vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II)){
                System.debug('Condition 60 satisfied.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau II Condition 60');
                vendor_has_existing_license_with_client_listed = true;
                vendor_has_no_any_existing_license_with_client_listed = false;
                List<AMA_Contract_Detail__c> existingAMAContractDetailList = vendor_has_existing_license_with_same_client.get(SERVICE_BUREAU_II);
                AMA_Contract_Detail__c existingAMAContractDetailObj = getExistingContractDetail(existingAMAContractDetailList);
                isAmaLicenseRequired = false;
                contractTypeRequired = SERVICE_BUREAU_II;
                amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                updatingExContractDetail(existingAMAContractDetailObj);
            }else if(vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II) && existIQVIAAsDBL){
                
                if(isMaxFeeReached && isAMAPerpetualAgreement_US_Only){
                    System.debug('Condition 61 satisfied.');
                    numberOfScenariosSatisfied++;
                    scenariosSatisfiedDetails.add('Service Bureau II Condition 61');
                    vendor_has_existing_license_with_different_client_listed = true;
                    contractTypeRequired = SBII_AMENDMENT;
                    isAmaLicenseRequired = true;
                    vendorHasLicence = 'has existing licence with different client listed on TPA form';
                    amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA);
                    //Update the Agreement record with the existing AMA Contract type and DBL that is covering the project.
                    amaAgreementDetails.Contract_Type__c = SBII_AMENDMENT;
                    //The system shall NOT create a new AMA Contract. (existing Contract will cover the project)
                    //Update agreement detail object with existing contract detail
                    updatingExContractDetail(existingWithDifferentDbl);
                }else{
                    System.debug('Condition 62 satisfied.');
                    numberOfScenariosSatisfied++;
                    scenariosSatisfiedDetails.add('Service Bureau II Condition 62');
                    vendor_has_existing_license_with_different_client_listed = true;
                    contractTypeRequired = SERVICE_BUREAU_II;
                    isAmaLicenseRequired = true;
                    vendorHasLicence = 'has existing licence with different client listed on TPA form';
                    amaAgreementDetails.DBL__c = getDBLValue(UTL_TPA.DBL_Val_IQVIA);
                    //Update the Agreement record with the existing AMA Contract type and DBL that is covering the project.
                    amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                    
                    //The system shall NOT create a new AMA Contract. (existing Contract will cover the project)
                    //Update agreement detail object with existing contract detail
                    updatingExContractDetail(existingWithDifferentDbl);
                }
                
            }else if(vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II) && !existIQVIAAsDBL){
                System.debug(vendor_has_existing_license_with_other_client.get(SERVICE_BUREAU_II));
                System.debug(existingWithDifferentDbl);
                if(isMaxFeeReached){
                    System.debug('Condition 63 satisfied.');
                    numberOfScenariosSatisfied++;
                    scenariosSatisfiedDetails.add('Service Bureau II Condition 63');
                    vendor_has_existing_license_with_different_client_listed = true;
                    contractTypeRequired = SERVICE_BUREAU_II;
                    isAmaLicenseRequired = false;
                    vendorHasLicence = 'has existing licence with different client listed on TPA form';
                    amaAgreementDetails.Contract_Type__c = 'Existing Agreement';
                    //The system shall NOT create a new AMA Contract. (existing Contract will cover the project)
                    //Update agreement detail object with existing contract detail
                    updatingExContractDetail(existingWithDifferentDbl);
                    notifyViaMail = true;
                    amaManualReview = true;
                    addReason(request,'Vendor has SBII with multiple DBLS');
                    addReasonCommercial(request, 'Vendor has SBII with multiple DBLS', null, null);
                    addAMAReason(amaAgreementDetails, 'Vendor has SBII with multiple DBLS');
                    reasonForAmaApprovalMap.put( System.Label.TPA_AMA_Vendor_has_Service_Bureau_II_with_multiple_DBLS,'Vendor has Service Bureau II with multiple DBLS;This requires TP Processor manual handling to determine contract type;Determine AMA contract required' );
                }else{
                    System.debug('Condition 64 satisfied.');
                    numberOfScenariosSatisfied++;
                    scenariosSatisfiedDetails.add('Service Bureau II Condition 64');
                    vendor_has_existing_license_with_different_client_listed = true;
                    contractTypeRequired = SERVICE_BUREAU_II;
                    isAmaLicenseRequired = true;
                    amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                    vendorHasLicence = 'has existing licence with different client listed on TPA form';
                    updatingExContractDetail(existingWithDifferentDbl);
                }
                
            }else if(!vendor_has_existing_license_with_other_client.containsKey(SERVICE_BUREAU_II) && !vendor_has_existing_license_with_same_client.containsKey(SERVICE_BUREAU_II) && !vendor_has_existing_license_with_any_client.containsKey(SERVICE_BUREAU_II)){
                System.debug('Condition 65 satisfied.');
                numberOfScenariosSatisfied++;
                scenariosSatisfiedDetails.add('Service Bureau II Condition 65');
                vendor_has_existing_license_with_different_client_listed = true;
                contractTypeRequired = SERVICE_BUREAU_II;
                isAmaLicenseRequired = true;
                amaAgreementDetails.Contract_Type__c = SERVICE_BUREAU_II;
                updatingExContractDetail(existingWithDifferentDbl);
                
                vendorHasLicence = 'has no existing Licence with AMA';
            }
        }
    }

    public static void findOffshoreCondition(TPA_Request__c request, AMA_Agreement_Detail__c amaAgreementDetails){
        Boolean isvalidClientStorageCountry = true;
        Boolean isAccessLocAppForVendor = true;
        Boolean isStorageLocAppForVendor = true;
        Boolean vendorAccessCountriesMatched = false;
        Boolean vendorStorageCountriesMatched = false;

        
        
        if(request.AMA_USPrescriberData__c == 'Yes') {
            if(amaAgreementDetails.Vendor_require_Remote_Access_from_NonUS__c != null && amaAgreementDetails.Vendor_require_Remote_Access_from_NonUS__c ==  'Yes' && amaAgreementDetails.Vendor_Employee_Accessed_Data_in_country__c != null){
                for(String country: amaAgreementDetails.Vendor_Employee_Accessed_Data_in_country__c.split(';')){
                    if(!CNT_TPA_RequestSubmissionForm.approvedCountriesForRemoteAccess.contains(country.toLowerCase())){
                        isvalidVendorAccessCountry = false;
                    }
                }
                if(amaAgreementDetails.Technology_s_selected_for_remote_access__c != null && amaAgreementDetails.Technology_s_selected_for_remote_access__c.indexOf('Other') != -1){
                    isPreAppTech = false;
                }
            }
            
            if(amaAgreementDetails.Vendor_req_Storage_Permission_from_NonUS__c != null && amaAgreementDetails.Vendor_req_Storage_Permission_from_NonUS__c ==  'Yes' && amaAgreementDetails.Vendor_Employee_Store_Data_in_country__c != null){
                if(!CNT_TPA_RequestSubmissionForm.ApprovedCountriesForStorage.contains(amaAgreementDetails.Vendor_Employee_Store_Data_in_country__c.toLowerCase())){
                    isvalidVendorStorageCountry = false;
                }
            }                       
        }
        
        if(vendor_has_existing_license_with_client_listed){

            if(amaAgreementDetails.Vendor_Employee_Accessed_Data_in_country__c != null && isvalidVendorAccessCountry){
                List<String> Locations = new List<string>();
                Set<String> offshoreLocationCountrySet = new Set<String>();
                Set<String> vendorAccessCountrySet = new Set<String>();
                
                List<String> vendorAccessCountries = amaAgreementDetails.Vendor_Employee_Accessed_Data_in_country__c.split(';');
                Set<String> offshoreAccessLocSet = new Set<String>();
                if(amaAgreementDetails.Ex_Offshore_Access__c != null)
                {
                    Locations = amaAgreementDetails.Ex_Offshore_Access__c.split(',');
                    for(String strLoc : Locations){
                        if(strLoc.indexOf('(ISO-3)') != -1)
                            strLoc = strLoc.substringAfter('(ISO-3)');
                        offshoreAccessLocSet.add(strLoc.trim());
                    }
                    if(!offshoreAccessLocSet.isEmpty()) {
                        for(String locationCountry: offshoreAccessLocSet) {
                            if(mapCountryCodeName.containsKey(locationCountry.toLowerCase())) {
                                offshoreLocationCountrySet.add(mapCountryCodeName.get(locationCountry.toLowerCase()));
                            }
                        }
                        for(String country: vendorAccessCountries) {
                            if(mapCountryCodeName.containsKey(country.toLowerCase()) && !country.equalsIgnoreCase('United States'))
                            vendorAccessCountrySet.add(mapCountryCodeName.get(country.toLowerCase()));
                        }
                        if(offshoreLocationCountrySet.containsAll(vendorAccessCountrySet)) {
                            vendorAccessCountriesMatched = true;
                        }
                        else{
                            vendorAccessCountriesMatched = false;
                        }
                    }
                    
                }
                
                
            }
        }

        isAccessCountriesMatched = vendorAccessCountriesMatched;

        if(amaAgreementDetails.Client_Employee_Store_Data_in_country__c != null ){
            Set<String> offshoreAccessLocSet = new Set<String>();
            List<String> Locations = new List<string>();
            List<AMA_Contract_Detail__c> existingclientAMAContractDetailList = new List<AMA_Contract_Detail__c>();
            for(String CntType : getOwnBehalfListForClient().keySet()){
                for(AMA_Contract_Detail__c conDetailObj : getOwnBehalfListForClient().get(CntType)) {
                    if(conDetailObj.Client__c != null && request.Client_Address__r.Name.toLowerCase() == conDetailObj.Client__c.toLowerCase() && conDetailObj.Offshore_Storage__c != null){
                        Locations = conDetailObj.Offshore_Storage__c.split(',');
                        for(String strLoc : Locations){
                            if(strLoc.indexOf('(ISO-3)') != -1)
                                strLoc = strLoc.substringAfter('(ISO-3)');
                            offshoreAccessLocSet.add(strLoc.trim());
                        }
                    }
                    
                }
            }
            
            Set<String> offshoreLocationCountrySet = new Set<String>();
            Set<String> vendorAccessCountrySet = new Set<String>();
            
            List<String> vendorAccessCountries = amaAgreementDetails.Client_Employee_Store_Data_in_country__c.split(';');
            if(!offshoreAccessLocSet.isEmpty()) {
                for(String locationCountry: offshoreAccessLocSet) {
                    system.debug('CountryLocation :-'+locationCountry);
                    if(mapCountryCodeName.containsKey(locationCountry.toLowerCase())) {
                        system.debug('existing value :-'+locationCountry);
                        offshoreLocationCountrySet.add(mapCountryCodeName.get(locationCountry.toLowerCase()));
                    }
                }
                system.debug('Offshore Country Location Set :-'+offshoreLocationCountrySet);
                for(String country: vendorAccessCountries) {
                    if(mapCountryCodeName.containsKey(country.toLowerCase()) && !country.equalsIgnoreCase('United States'))
                    vendorAccessCountrySet.add(mapCountryCodeName.get(country.toLowerCase()));
                }
                if(offshoreLocationCountrySet.containsAll(vendorAccessCountrySet)) {
                    system.debug('Requested Country Matched in Client List');
                    isvalidClientStorageCountry = true;
                }
                else{
                    isvalidClientStorageCountry = false;
                }
            }
            else{
                isvalidClientStorageCountry = false;
            }
        }    

        if(!isvalidVendorAccessCountry){
            system.debug('in isvalidVendorAccessCountry');
            reasonForAmaApprovalMap.put( System.Label.TPA_Vendor_requires_offshore_access_location_approval,System.Label.TPA_Vendor_requires_offshore_access_location_approval +';Offshore access location of ' + amaAgreementDetails.Vendor_Employee_Accessed_Data_in_country__c + '  requires AMA review;Determine AMA offshore requirements');
        }
        if(!isPreAppTech && !vendorAccessCountriesMatched){
            system.debug('in isPreAppTech');
            reasonForAmaApprovalMap.put( System.Label.TPA_Vendor_requires_offshore_access_technology_approval, System.Label.TPA_Vendor_requires_offshore_access_technology_approval +';Offshore technology of other requires AMA review;Determine AMA offshore requirements');
        }
        
        if(amaAgreementDetails.Vendor_req_Storage_Permission_from_NonUS__c != null && amaAgreementDetails.Vendor_req_Storage_Permission_from_NonUS__c ==  'Yes' && amaAgreementDetails.Vendor_Employee_Store_Data_in_country__c != null && amaAgreementDetails.Vendor_Employee_Store_Data_in_country__c != '--None--'){ 
            system.debug('in isvalidVendorStorageCountry');
            reasonForAmaApprovalMap.put( System.Label.TPA_Vendor_requires_offshore_storage_location_approval, System.Label.TPA_Vendor_requires_offshore_storage_location_approval +';Offshore storage location of ' + amaAgreementDetails.Vendor_Employee_Store_Data_in_country__c + '  requires AMA review;Determine AMA offshore requirements<p>TP-Processor - Seek assistance from TP-US for manually handling of the below:</p><ul><li>Populate the fee fields</li><li>Gain Vendor acknowledgement of fees and record said acknowledgement</li><li>Determine AMA Foreign License [FL] Type</li><li>Generate the required FL agreement type which the system should dynamically populate the required fields in the generated FL agreement</li></ul>');
        }
        if(!isvalidClientStorageCountry){
            system.debug('in isvalidClientStorageCountry');
            reasonForAmaApprovalMap.put( System.Label.TPA_Client_requires_offshore_storage_approval, System.Label.TPA_Client_requires_offshore_storage_approval +';Forward to Contracts team.  Client storage location not on AMA Client Contract List;Determine AMA offshore requirements');
        }
        
        Boolean isvendorAccessReq = false;
        if(amaAgreementDetails.Vendor_Employee_Accessed_Data_in_country__c != null && !amaAgreementDetails.Vendor_Employee_Accessed_Data_in_country__c.equalsignorecase('United States') && !vendorAccessCountriesMatched) {
         isvendorAccessReq = true;
        }
        
        if(isvalidVendorAccessCountry && isPreAppTech && isvalidVendorStorageCountry && !isvalidClientStorageCountry){
            onlyClientReqOffAccess = true;
            
        }

        if(amaAgreementDetails.Vendor_Employee_Accessed_Data_in_country__c != null && !vendorAccessCountriesMatched){
            IsGenerateOffConsentForm = true;
        }

        String dblValue = 'IQVIA (IQVIA)';

        if(!isvalidVendorAccessCountry || (!isPreAppTech && !vendorAccessCountriesMatched) || !isvalidClientStorageCountry || amaAgreementDetails.Vendor_Employee_Store_Data_in_country__c != null){
            amaManualReview = true;
            addReason(request,'Client and/or Vendor requires offshore approval'); 
            addReasonCommercial(request, 'Client and/or Vendor requires offshore approval', null, null);
            addAMAReason(amaAgreementDetails, 'Client and/or Vendor requires offshore approval');
        }
        if(isvendorAccessReq && isvalidVendorAccessCountry && isPreAppTech && amaAgreementDetails.DBL__c != null){
            amaManualReview = true;
            addReason(request,'Client and/or Vendor requires offshore approval'); 
            addReasonCommercial(request, 'Client and/or Vendor requires offshore approval', null, null);
            addAMAReason(amaAgreementDetails, 'Client and/or Vendor requires offshore approval');
            reasonForAmaApprovalMap.put( System.Label.TPA_Vendor_requires_offshore_access_location_approval,System.Label.TPA_Vendor_requires_offshore_access_location_approval +';Offshore access location of ' + amaAgreementDetails.Vendor_Employee_Accessed_Data_in_country__c + '  requires AMA review;Determine AMA offshore requirements');
        }
        if(!isAmaLicenseRequired){
            if(isvendorAccessReq && isvalidVendorAccessCountry && isPreAppTech && amaAgreementDetails.DBL__c == dblValue){
              IsOffshoreAccessAmendmentReq = true;
              IsGenerateOffConsentForm = false;
            }
            else if(isvendorAccessReq && (!isvalidVendorAccessCountry || !isPreAppTech || amaAgreementDetails.DBL__c != dblValue)){
                IsOffAccessAmendmentReqWithNALoc= true;
                IsGenerateOffConsentForm = false;
            }
        }
    }

    public static List<String> getClientandVendorEmail(ID reqId){
        TPA_Request__c tpaReq = [SELECT Client_Email__c, Owner.Email, Client_TPA_Representative_Email__c, Owner.Type, Vendor_e_mail__c , Authorized_Signer_Email__c FROM TPA_Request__c WHERE Id =: reqId];
        List<String> emailAddresses = new List<String>();

        emailAddresses.add(tpaReq.Client_Email__c);
        if(tpaReq.Client_TPA_Representative_Email__c != null && tpaReq.Client_TPA_Representative_Email__c != ''){
            emailAddresses.add(tpaReq.Client_TPA_Representative_Email__c);
        }

        if(tpaReq.Owner.Type != null && tpaReq.Owner.Type == 'Queue' && tpaReq.Owner.Email != null){
            emailAddresses.add(tpaReq.Owner.Email);
        }
        emailAddresses.add(tpaReq.Vendor_e_mail__c);
        if(tpaReq.Authorized_Signer_Email__c != null && String.isNotBlank(tpaReq.Authorized_Signer_Email__c ))
            emailAddresses.add(tpaReq.Authorized_Signer_Email__c);
        return emailAddresses;
    }

    public static void sendEmailToVendor(AMA_Agreement_Detail__c amaAgrObj) {

        Date todayDate;
        todayDate = Date.today(); 

        TPA_Multilingual_Template_Setting__c templatObj = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email to Vendor Secure Tech of Other' + 'English');
        String templateId = templatObj.Translated_Template_Id__c;
        
        List<String> toAddress = new List<String>();
        List<String> ccTo = new List<String>();
        TPA_Request__c tpaReq = [SELECT Id, Name, Client_Email__c , TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Vendor_e_mail__c , Authorized_Signer_Email__c FROM TPA_Request__c WHERE Id =: amaAgrObj.TPA_Request__c];

		
	    toAddress.addAll(getClientandVendorEmail(amaAgrObj.TPA_Request__c));
        
        List<TPA_Contact__c> tpaContactsList = SRV_TPA_TPARequest.getContactsForRequest(amaAgrObj.TPA_Request__c);
        if(tpaContactsList!= null && tpaContactsList.size() > 0){
            for(TPA_Contact__c tpaContact : tpaContactsList){
                toAddress.add(tpaContact.Email__c);
            }
        }
        
        // if(amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c != Null && amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c != '') {
        //     ccTo = amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c.split(';');
        // }
        toAddress.add(amaAgrObj.TPA_Request__r.TP_Processor_Email__c);
        ccTo.addAll(TPA_Settings__c.getOrgDefaults().TP_US_Mail_Id__c.split(','));

        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
        
                    
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '', TRUE, TRUE, tpaReq);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                
            }
        } catch(Exception e) {
            System.debug('Offshore Notification sent to DBL failed: ' + e.getMessage());
        } 
    }
}