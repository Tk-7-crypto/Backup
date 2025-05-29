@isTest(SeeAllData=false)
public class TST_UTL_TPA_Multilingual {
    private static User u;
    private static TPA_Request__c objTpaReq;
    private static Contact testContact;
    private static Account testAccount;
    public static Map<String, List<TPA_Language_Cross_Walk__c>> translationMap;
    public static List<TPA_Multilingual_Template_Setting__c> multiLingualTemplateSettings;
    public static map<String, TPA_Multilingual_Template_Setting__c> multiLingualTemplateSettingsMap;
    public static map<String, list<TPA_Multilingual_Template_Setting__c>> multiLingualTemplateSettingsListMap;
    public static string fieldsAsException;
    public static string fieldsPopulateDynam;
    public static string MultiSelectPicklistsToTranslate;
    public static string MultiSelectPicklistsCommaSeprated;
    public static string SuppLangCodeFieldNameLocalName;
    public static Map<String, String> supportedLanguageCodeMap;
    public static Map<String, String> supportedLanguageCodeAndNameMap;
    public static Map<String, String> supportedLanguageFieldMap;
    public static TPA_Multilingual_Global_Settings__c mlGlobalSettings;
    public static User CurrentUser;
    
    
    static void setupData(){
        List<TPA_Data_Asset__c> dAListToUpdate = new List<TPA_Data_Asset__c>();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createTPACountryCodeData('C','USA', 'US;U.S.;USA;United States Of America;U.S;U.S.A;United States;U.S.A.');
        objTpaReq = getTPARequest();
        IMS_TPA_Purpose__c imsTpaPurpose = createImsTPAPurpose('Expert Analysis for Legal or Governmental Purposes');
        TPA_Purpose__c purpose = createTPAPurpose(objTpaReq.id,imsTpaPurpose.id, imsTpaPurpose.Primary_Purpose_Name__c);
        IMS_Data_Asset__c imsDataAsset = createImsDataAsset('ChannelDynamics (NEW promotional audit)');
        createTPADataAsset(objTpaReq.id, purpose.id, imsDataAsset.id );
        IMS_Data_Asset__c imsDataAsset1 = createImsDataAsset('National Prescription Audit™ (NPA)National Prescription Audit™ (NPA)');
        TPA_Data_Asset__c tpaDataAsset1 = createTPADataAsset(objTpaReq.id, purpose.id, imsDataAsset1.id );
        
        IMS_Data_Asset__c tmpImsDataAsset = createImsDataAsset('APLD Custom Study Name & Project Delivery Date:');
        TPA_Data_Asset__c tmpTpaDataAsset = createTPADataAsset(objTpaReq.id, purpose.id, tmpImsDataAsset.id );
        tmpTpaDataAsset.APLD_Delivery_Date__c = Date.today() - 1;
        tmpTpaDataAsset.APLD_Study_Name__c = 'test';
        dAListToUpdate.add(tmpTpaDataAsset);
        
        
        tmpImsDataAsset = createImsDataAsset('RWE Custom Study Name & Project Delivery Date:');
        tmpTpaDataAsset = createTPADataAsset(objTpaReq.id, purpose.id, tmpImsDataAsset.id );
        tmpTpaDataAsset.RWE_Delivery_Date__c = Date.today() - 1;
        tmpTpaDataAsset.RWE_Study_Name__c = 'test';
        dAListToUpdate.add(tmpTpaDataAsset);
		
        tmpImsDataAsset = createImsDataAsset('Consumer Profiles Custom Study Name & Project Delivery Date:');
        tmpTpaDataAsset = createTPADataAsset(objTpaReq.id, purpose.id, tmpImsDataAsset.id );
        tmpTpaDataAsset.Consumer_Profile_Delivery_Date__c = Date.today() - 1;
        tmpTpaDataAsset.Consumer_Profile_Study_Name__c = 'test';
        dAListToUpdate.add(tmpTpaDataAsset);
        
        tmpImsDataAsset = createImsDataAsset('Consumer Profiles Custom Study Name & Project Delivery Date:');
        tmpTpaDataAsset = createTPADataAsset(objTpaReq.id, purpose.id, tmpImsDataAsset.id );
        tmpTpaDataAsset.Consumer_Profile_Delivery_Date__c = Date.today() - 1;
        tmpTpaDataAsset.Consumer_Profile_Study_Name__c = 'test';
        dAListToUpdate.add(tmpTpaDataAsset);
        
        
        tmpImsDataAsset = createImsDataAsset('Promotional Response (ROI) Custom Study Name & Project Delivery Date:');
        tmpTpaDataAsset = createTPADataAsset(objTpaReq.id, purpose.id, tmpImsDataAsset.id );
        tmpTpaDataAsset.Promotional_ROI_Delivery_Date__c = Date.today() - 1;
        tmpTpaDataAsset.Promotional_ROI_Study_Name__c = 'test';
        dAListToUpdate.add(tmpTpaDataAsset);
        
        tmpImsDataAsset = createImsDataAsset('STI Data - Custom Report Name:');
        tmpTpaDataAsset = createTPADataAsset(objTpaReq.id, purpose.id, tmpImsDataAsset.id );
        tmpTpaDataAsset.STI_Data_Report_Name__c = 'STI';
        dAListToUpdate.add(tmpTpaDataAsset);
        
        tmpImsDataAsset = createImsDataAsset('Consumer Profiles [Patient as Consumer] Custom Study Name & Project Delivery Date:');
        tmpTpaDataAsset = createTPADataAsset(objTpaReq.id, purpose.id, tmpImsDataAsset.id );
        tmpTpaDataAsset.Consumer_Profile_Delivery_Date__c = Date.Today() -1;
        tmpTpaDataAsset.Consumer_Profile_Study_Name__c = 'Test';
        dAListToUpdate.add(tmpTpaDataAsset);
        
        update dAListToUpdate;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = createSecondaryIMSTPADataAsset('NPA New To Brand™', imsDataAsset1.id );
        createSecondaryTPADataAsset(objTpaReq.id, tpaDataAsset1.id, imsSecondaryDataAsset.id,'NPA New To Brand™');
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset2 = createSecondaryIMSTPADataAsset('BrandImpact Custom Study Name & Project Delivery Date:', imsDataAsset1.id );
        createSecondaryTPADataAsset(objTpaReq.id, tpaDataAsset1.id, imsSecondaryDataAsset2.id,'BrandImpact Custom Study Name & Project Delivery Date:');
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset3 = createSecondaryIMSTPADataAsset('Channel Dynamics Custom Study Name & Project Delivery Date:', imsDataAsset1.id );
        createSecondaryTPADataAsset(objTpaReq.id, tpaDataAsset1.id, imsSecondaryDataAsset3.id,'Channel Dynamics Custom Study Name & Project Delivery Date:');
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset4 = createSecondaryIMSTPADataAsset('ProVoice Custom Study Name & Project Delivery Date:', imsDataAsset1.id );
        createSecondaryTPADataAsset(objTpaReq.id, tpaDataAsset1.id, imsSecondaryDataAsset4.id,'ProVoice Custom Study Name & Project Delivery Date:');
        
        
        Date todayDate = Date.today();

        TPA_Country_Codes__c countryCode = createCountryCode('testCountry', 'TR','S');
        
    }
    
    public static testmethod void testMultilingualUtilMethods(){
        setupData();
        System.debug('01.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_Multilingual.getEmailTemplateId('Email Week Reminder V Sub', 'Japanese');
        UTL_TPA_Multilingual.getTranslatedValueMap(new Set<String> {'English_Translation__c'});
        
        List<TPA_Multilingual_Template_Setting__c> MultiLingTemplateSettingsTest = UTL_TPA_Multilingual.multiLingualTemplateSettings;
        System.debug('02.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        map<String, TPA_Multilingual_Template_Setting__c> multiLingTemplateSettingsMapTest= UTL_TPA_Multilingual.multiLingualTemplateSettingsMap;
        
        map<String, list<TPA_Multilingual_Template_Setting__c>> multiLingTemplateSettingsListMapTest = UTL_TPA_Multilingual.multiLingualTemplateSettingsListMap;
        System.debug('03.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        System.debug('04.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        System.debug('05.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        String SuppLangCodeFieldNameLocalNameTest  = UTL_TPA_Multilingual.SuppLangCodeFieldNameLocalName;
        
        Map<String, String> supportedLanguageCodeMapTest = UTL_TPA_Multilingual.supportedLanguageCodeMap;
        
        Map<String, String> supportedLanguageCodeAndNameMapTest =  UTL_TPA_Multilingual.supportedLanguageCodeAndNameMap;
        System.debug('06.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        Map<String, String> supportedLanguageFieldMapTest = UTL_TPA_Multilingual.supportedLanguageFieldMap;
        
        TPA_Multilingual_Global_Settings__c mlGlobalSettingsTest = UTL_TPA_Multilingual.mlGlobalSettings;
        system.debug('before::::'+objTpaReq);
        System.debug('07.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        Map<String, String> CountryStatesAndCodes = UTL_TPA_Multilingual.mapCountryStatesCodes;
        System.debug('08.Number of Queries used in this apex code so far: ' + Limits.getQueries());

        Test.startTest();
        Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{objTpaReq.Vendor_Language__c + '_Translation__c'});
        system.debug('after::::');
        System.debug('001.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_Multilingual.updateChildRecordsTranslation(objTpaReq.id, null);
        System.debug('002.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_Multilingual.updateChildRecordsTranslation(objTpaReq.id, objTpaReq);
        
        System.debug('003.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_Multilingual.getLanguageForExistingRequests(objTpaReq.id ,'c');
        System.debug('004.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_Multilingual.getLanguageForExistingRequests(objTpaReq.id ,'v');
        System.debug('005.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_Multilingual.saveUseOfferingTranslatedNames(objTpaReq.id ,'English_Translation__c' ,multilanguageUtilityMap);
		System.debug('006.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_Multilingual.getCountryStateCodeSet('C', 'USA');
        System.debug('007.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_Multilingual.firstLetterCapital('english_translation__c');
        System.debug('008.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_Multilingual.getLanguage();
        System.debug('009.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        List<string> lstStr = UTL_TPA_Multilingual.addAdditionalClientContactInccList(new List<TPA_Contact__c>{new TPA_Contact__c(Type__c = 'Additional Contact',Email__c = 'test@test.com')}, new List<string>{'test'});
        System.debug('010.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_Multilingual.isValidEmailId('test@test.com');
        UTL_TPA_Multilingual.ccList('a@a.com;test@test.com', null);        
        
        TPA_Request_Localized__c objReqLoc = new TPA_Request_Localized__c(
            OwnerId = UserInfo.getUserId()
        );
        insert objReqLoc;        
        System.debug('011.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_Multilingual.getRequestChildLocalizedRecords(objTpaReq.Id);
        System.debug('012.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        objTpaReq.Vendor_Language__c = null;
        UTL_TPA_Multilingual.getRequestChildLocalizedRecords(objTpaReq.Id);
        System.debug('013.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        objTpaReq.Vendor_Language__c = 'Japanese';
        UTL_TPA_Multilingual.getRequestChildLocalizedRecords(objTpaReq.Id);
        System.debug('014.Number of Queries used in this apex code so far: ' + Limits.getQueries());
                
		Set<String> CountryStateCodeSetWithName = UTL_TPA_Multilingual.getCountryStateCodeSetWithName('S','TestCountry');   
        System.debug('015.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        UTL_TPA_Multilingual.isValidRecordId(objTpaReq.Id);
        System.debug('016.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        Test.stopTest();
        
    }
    
    public static TPA_Country_Codes__c createCountryCode(String countryName,String countryPossibleCodes ,String codeType){
        TPA_Country_Codes__c countryCode = new TPA_Country_Codes__c(name = countryName, Country_Possible_Codes__c = countryPossibleCodes, Code_Type__c = codeType);
        insert countryCode;
        return countryCode;
    }
    public static Address__c getTestAccount() {
        Account TestAccount;
		Address__c testAddress;
		List<Address__c> ListAddress = [select Id,Name from Address__c where Name like 'Supriya' LIMIT 1];
		if(ListAddress.size() == 0)
        {
            TestAccount = new Account
                (Name = 'Supriya',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech', BillingCountry = 'India', BillingState = 'Delhi', BillingStreet = 'Shahdara', BillingCity = 'Delhi',BillingPostalCode = '110032', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');        
            insert TestAccount;
			testAddress = new Address__c( name = 'Supriya',
                                          Is_TPA_Account__c = true,
                                          Is_AMA_Account__c = true,
                                          Account__c = testAccount.Id,
                                          Vendor_Registration_Number__c = 9999,
                                          Street__c = 'Test',
                                          City__c = 'Test',
                                          State__c = 'Test',
                                          Country__c = 'Test',
                                          PostalCode__c = 'Test',
                                          TPA_Local_Address_Required__c = false  
                                        );
            insert testAddress;
            getTestContact(testAddress);
        }
        else {
			testAddress = ListAddress[0];
        }
		return testAddress;
    }
    
    public static Contact getTestContact(Address__c testAddress) {
        Contact TestContact ;
        List<Contact > ListContact = [Select id,Name  From Contact where Name like 'Test' LIMIT 1];
        if(ListContact.size() == 0) {
            TestContact = new Contact();
            TestContact.FirstName = 'TestFirstName';
            TestContact.LastName = 'Test';
            TestContact.AccountId = testAddress.Account__c;
            TestContact.CurrencyIsoCode = 'USD';
            TestContact.Email = 'test@mail.com';
            TestContact.Title = 'Dev';
            insert TestContact ;
        }
        else {
            TestContact = ListContact [0];
        }
        return TestContact;
    }
    
    public static TPA_Request__c getTPARequest() {
        Address__c TestAccount = getTestAccount();
        Date todayDate = Date.today();
        TPA_Request__c tpaRequest = new TPA_Request__c(
            OwnerId = UserInfo.getUserId(),
            Client_Region__c = 'US',
            Data_Provided_By__c = 'IMS in lieu of Client',
            Is_Data_Accessed_Via_IMS_Software__c = 'Yes',
            AMA_USPrescriberData__c = 'Yes',
            Does_the_request_require_information_con__c = 'Yes',
            Service_Provider_Address__c = TestAccount.Id,
            Vendor_Company_Name__c = 'Test company',
            Is_Submitted__c = true,
            Request_Status__c = 'In Effect',
            Data_Access_End_Date__c = todayDate.addDays(3),
            Vendor_e_mail__c = 'test@mail.com',
            Vendor_contact_email_client__c = 'test@mail.com',
            TP_Processor_Email__c = 'test@mail.com',
            Is_Potential_Vendor_Case__c = true,
            Client_Language__c = 'English',
            Vendor_Language__c = 'English'            
        );
        insert tpaRequest;
        return tpaRequest; 
    }
    
    public static IMS_TPA_Purpose__c createImsTPAPurpose(String PurposeName) {  
        IMS_TPA_Purpose__c imsPurpose = new IMS_TPA_Purpose__c(Name = PurposeName,
                                                               Purpose_Details__c = 'test purpose details',
                                                               Consulting_Area__c = 'test consulting area',
                                                               Business_Line__c = 'test business line',
                                                               Primary_Purpose_Name__c = PurposeName
                                                              );
        insert imsPurpose;
        return imsPurpose;
    }
    
    public static TPA_Purpose__c createTPAPurpose(Id tpaRequestID , Id purposeId,  String PrimaryPurposeName) {
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = PrimaryPurposeName,
                                                       Request__c = tpaRequestID,
                                                       Region__c = 'TEST_REGION',
                                                       Purpose__c = purposeId,
                                                       Prescriber_ID_Number__c = null,
                                                       Prescriber_ID_Number_Details__c = null,
                                                       PrescriberNPINumber__c = null,
                                                       PrescriberNPINumber_Details__c = null,
                                                       OutletReferenceFiles__c = null,
                                                       Other_Reference_File__c = null,
                                                       Other_Details__c = '',
                                                       other_Text__c = '',
                                                       NCPDPIDorNPIOutletNumber__c = null,
                                                       NCPDPIDorNPIOutletNumber_Details__c = null,
                                                       Managed_Care__c = null,
                                                       Managed_Care_Details__c = null,
                                                       Linked_Data_Description__c = null,
                                                       IMSPrescriberIDNumber__c = null,
                                                       IMSPrescriberIDNumber_Details__c = null,
                                                       FinDr_ID__c = null,
                                                       Extended_Category_Codes__c = null,
                                                       Deliverables_Freq_To_Client__c = null,
                                                       Data_Usage__c = null,
                                                       Data_Assets__c = null,
                                                       Client_Deliverables__c = null,
                                                       Additional_Reference_Info__c = null,
                                                       AMABridgeFile__c = null,
                                                       AMABridgeFile_Details__c = null
                                                      );
        insert tpaPurpose;
        return tpaPurpose;
    }
    
    public static IMS_Data_Asset__c createImsDataAsset(String imsDataAssetName) {  
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = imsDataAssetName ,Region__c = 'TEST_REGION', Requires_Manual_Review__c = false, BU__c ='United States', Is_Active__c = true, Geo_Level__c  = 'National', IMS_Legal_Entity__c = 'Quintiles IMS Incorporated');
        insert imsDataAsset;
        return imsDataAsset;
    }
    
    public static TPA_Data_Asset__c createTPADataAsset(Id tpaReqId, Id purposeID, Id imsDataAsset) {  
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaReqId,
                                                               Region__c = 'TEST_REGION',
                                                               Purpose__c = purposeID,
                                                               Data_Asset__c = imsDataAsset,
                                                               BU__c = 'United States',
                                                               Geo_Level__c = 'National'
                                                              );
        insert tpaDataAsset;
        return tpaDataAsset;
    }
    
    public static IMS_Secondary_Data_Asset__c createSecondaryIMSTPADataAsset(string Name, Id imsDataAsset) {  
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset,
                                                                                            Requires_Manual_Review__c = true,
                                                                                            Is_Restricted_Data__c = true, 
                                                                                            Secondary_Asset_Name__c = Name
                                                                                           );
        insert imsSecondaryDataAsset;
        return imsSecondaryDataAsset;
    }
    
    public static TPA_Secondary_Data_Asset__c createSecondaryTPADataAsset(Id tpaReqId, Id tpaDataAsset, Id imsSecondaryDataAsset, String secondaryDataAssetName) {  
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset,
                                                                                            IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset,
                                                                                            Secondary_Asset_Name__c = secondaryDataAssetName,
                                                                                            BrandImpact_Delivery_Date__c = Date.today(),
                                                                                            Channel_Dynamics_Delivery_Date__c = Date.today(),
                                                                                            Pro_Voice_Delivery_Date__c = Date.today()
                                                                                           );
        insert tpaSecondaryDataAsset;
        return tpaSecondaryDataAsset;
    }   
}