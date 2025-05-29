@isTest
private class TST_CNT_TPA_RequestSubmissionForm { 
    
    @TestSetup
    static void setupTestData()
    {
        UTL_TPA_SetupTestData.createTPASettingData();
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();

        insert new TPA_Country_Codes__c(name = 'USA', Country_Possible_Codes__c = 'USA', Code_Type__c = 'C');

        list<Log_Setting__c> logSettingList = new list<Log_Setting__c>();//bulk List of custom setting object for bulk insert

        Log_Setting__c logSettingObj = new Log_Setting__c(); 
        logSettingObj.Name = 'TPA';
        logSettingObj.Log_Data_to_keep_for__c   =  8;
        logSettingObj.Severity_Level__c  = 'DEBUG';
            

        logSettingList.add(logSettingObj);

        insert logSettingList;
        Account acc = new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert acc;
        Address__c testAddrs = new Address__c(Name = 'TPA Test Acc', recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, CurrencyIsoCode = 'USD', Account__c = acc.Id, Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
        insert testAddrs;
        Contact  con = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com', AccountId = acc.id);
        
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE Name like 'US TP Processor Profile CCP%' Limit 1];//Updated by Babita Dadarwal under ER-3552
        Profile p2 = [SELECT Id FROM Profile WHERE Name like 'Alliance TPA Processing%' Limit 1];
        TPA_Settings__c TPA_SettingObj1 = new TPA_Settings__c(Name = 'Test1', VendorMessageBoardId__c = 'test id', TPA_RequestSubmitted_Email__c = 'Test Email', Base_Url__c = String.valueOf(URL.getOrgDomainUrl()),SetupOwnerId=p.id);
        
        insert TPA_SettingObj1 ;
        TPA_SettingObj1 = new TPA_Settings__c(Name = 'Test1', VendorMessageBoardId__c = 'test id', TPA_RequestSubmitted_Email__c = 'Test Email', Base_Url__c = String.valueOf(URL.getOrgDomainUrl()), SetupOwnerId=p2.Id);
        insert TPA_SettingObj1;
        TPA_SettingObj1 = new TPA_Settings__c(Name = 'Test1', VendorMessageBoardId__c = 'test id', TPA_RequestSubmitted_Email__c = 'Test Email', Base_Url__c = String.valueOf(URL.getOrgDomainUrl()), SetupOwnerId=userinfo.getProfileId());
        insert TPA_SettingObj1;
        TPA_Text_Editor__c testHoverDesc = UTL_TPA_SetupTestData.createTpaTestEditorData('Test','Test', 'Test', 'Hover Descriptions');
        testHoverDesc = UTL_TPA_SetupTestData.createTpaTestEditorData('TPA ShutDown Message','Test', 'Test', 'Shutdown Message');
    }
    
    private static testmethod void requestValidateOnLoadForClientTest() {
        
        String userProfileName = CNT_TPA_RequestSubmissionForm.currentUserProfileName;
        String tpaCommunityUrl = CNT_TPA_RequestSubmissionForm.tpaCommunityUrl;
        Boolean bulkmMatrixAcc = CNT_TPA_RequestSubmissionForm.isBulkMatrixAccess;
        CNT_TPA_RequestSubmissionForm.getUserProfileName();
        
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Address__c addrs = [select id from Address__c where Name = 'TPA Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        
        //Getting profile id for TP Processor Profile
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP%' Limit 1];//Updated by Babita Dadarwal under ER-3552
        system.debug('profile: '+p);
        
        //Creating User with TP Processor profile
        User user = new User(Alias = 'standt', Email='standarduser123@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',
        ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@testing123.com',
        TimeZoneSidKey='America/Los_Angeles', ContactId = con.id);
        
        //Creating TPA request
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), ClientContact__c = con.id, Client_Language__c = 'English', Data_Asset_List__c = 'AAN',
                                                       Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                       Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test');
        insert tpaRequest;
        
        createOffTestData(tpaRequest) ;
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/
        
        Test.StartTest();
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','c' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        String HoverDesc = tpaRequestFormController.HoverDescriptionMapString;
        tpaRequestFormController.requestValidateOnLoad();
        System.assertNotEquals(null, tpaRequestFormController);
        //String testString = tpaRequestFormController.isRenewedorModifiedRenewed;

        CNT_TPA_RequestSubmissionForm.sendMailToTPProcessorClientAddressisNULL(tpaRequest);
        String isrened = CNT_TPA_RequestSubmissionForm.isRenewedorModifiedRenewed;

        
        // To set the current page to TPA Page Access Request Form page
        pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', null);
        pageRef.getParameters().put('type',null );
        pageRef.getParameters().put('requestType', null);
        Test.setCurrentPage(pageRef);
        sc = new ApexPages.standardController(tpaRequest);
        tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        tpaRequestFormController.requestValidateOnLoad();
        System.assertNotEquals(null, tpaRequestFormController);
        
        // To set the current page to TPA Page Access Request Form page
        pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','e' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        sc = new ApexPages.standardController(tpaRequest);
        tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        tpaRequestFormController.requestValidateOnLoad();
        System.assertNotEquals(null, tpaRequestFormController);
        tpaRequestFormController.getAMALongestPeriodList();
      //  tpaRequestFormController.getAMAResponseDataReturnList();
        tpaRequestFormController.getRequestingCountryList();
        tpaRequestFormController.getRequestingForCountryList();
        tpaRequestFormController.getVendorCountryList();
        tpaRequestFormController.getVendorStateList();
        tpaRequestFormController.getCountryOfOfferingsList();
        tpaRequestFormController.getOfferingProviderList();
        tpaRequestFormController.getVendorComplianceCountryList();
        tpaRequestFormController.getVendorComplianceStateList();
        tpaRequestFormController.getPriDataAssetField(new TPA_Data_Asset__c(),new TPA_Data_Asset__c());
        tpaRequestFormController.getsecDataAsset(new TPA_Secondary_Data_Asset__c(Secondary_Asset_Name__c='Test Sec Asset'));
        
        String testString = tpaRequestFormController.getCountries();
        //testString = tpaRequestFormController.getExistedUsesAndAssetsJSON();
        testString = tpaRequestFormController.getProposalTreeObjJSON();
        
        
        Test.StopTest();
    }
    
    public static void createOffTestData( TPA_Request__c tpaRequest){
        
        
        ATC__c tpaATC = new ATC__c(Active__c = true, ATC_Code__c = '123', Name_Eng__c = 'Test ATC');
        insert tpaATC;
        
        TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c(TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id);
        insert tpaRequestATC;
        
        List<IMS_TPA_Purpose__c> listIMSTPAPurpose = new List<IMS_TPA_Purpose__c>();
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        //insert imsTpaPurpose;
        listIMSTPAPurpose.add(imsTpaPurpose);
        
        IMS_TPA_Purpose__c imsTpaPurpose2 = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'test name2', Purpose_Details__c = 'test detail2',
                                                                   Is_Active__c = false);
        //insert imsTpaPurpose2;
        listIMSTPAPurpose.add(imsTpaPurpose2);
        
        insert listIMSTPAPurpose;
        
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis', isActive__c = true);
        insert tpaPurposeCategory;
        
        TPA_Purpose_Category__c tpaPurposeCategory2 = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis', isActive__c = false);
        insert tpaPurposeCategory2;
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                       Purpose__c = imsTpaPurpose.id);
        insert tpaPurpose;
        
        TPA_Purpose__c tpaPurpose2 = new TPA_Purpose__c(Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory2.id,
                                                        Purpose__c = imsTpaPurpose2.id);
        insert tpaPurpose2;
        
        List<IMS_Data_Asset__c> imsDataAssetList = new List<IMS_Data_Asset__c>();
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(BU__c = 'United States', Geo_Level__c = 'Sub-National', Is_Active__c = true, IMS_Legal_Entity__c='IQVIA AG', Asset_Name__c = 'test');
        //insert imsDataAsset;
        imsDataAssetList.add(imsDataAsset);
        
        IMS_Data_Asset__c imsDataAsset2 = new IMS_Data_Asset__c( Asset_Name__c = 'test' , BU__c = 'United States', Geo_Level__c = 'Sub-National', Is_Active__c = true, IMS_Legal_Entity__c='IQVIA AG');
        //imsDataAssetList.add(imsDataAsset2);
        insert imsDataAsset2;
        IMS_Data_Asset__c imsDataAsset3 = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States', Geo_Level__c = 'Sub-National', Is_Active__c = false, Map_To__c = imsDataAsset2.id, IMS_Legal_Entity__c='IQVIA AG');
        imsDataAssetList.add(imsDataAsset3);
        
        
        insert imsDataAssetList;
        
        List<TPA_Data_Asset__c> tpaDataAssetList = new List<TPA_Data_Asset__c>();
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        //insert tpaDataAsset;
        tpaDataAssetList.add(tpaDataAsset);

        TPA_Data_Asset__c tpaDataAsset1 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset3.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Test Data Asset 1');
        //insert tpaDataAsset;
        tpaDataAssetList.add(tpaDataAsset1);
        
        TPA_Data_Asset__c tpaDataAsset2 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        //insert tpaDataAsset2;
        tpaDataAssetList.add(tpaDataAsset2);
        
        TPA_Data_Asset__c tpaDataAsset3 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset3.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Test Data Asset');
        //insert tpaDataAsset2;
        tpaDataAssetList.add(tpaDataAsset3);

        
        
        insert tpaDataAssetList;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;

        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset2 = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset2;

        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset3 = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true, Is_Active__c = false, Map_To__c = imsSecondaryDataAsset.id);
        insert imsSecondaryDataAsset3;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset2;

        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset3 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset3.id);
        insert tpaSecondaryDataAsset3;


        IMS_Data_Asset__c imsDataAsset4 = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States', Geo_Level__c = 'Sub-National', Is_Active__c = false, Map_To_Secondary_Data_Asset__c = imsSecondaryDataAsset2.id, IMS_Legal_Entity__c='IQVIA AG');
        insert imsDataAsset4;
        TPA_Data_Asset__c tpaDataAsset4 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset4.id,
        BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'SecToPrimary');
        insert tpaDataAsset4;
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id);
        insert imsTpaPurposeCategory;
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        insert imsTpaPurposeCategory2;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true);
        insert imsTpaPurposeDescription;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id,
                                                                                                      Is_Active__c = true);
        insert imsTpaPurposeDescription2;
        
        TPA_Purpose_Description__c tpaPurposeDescription = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                          Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        insert tpaPurposeDescription;
        
        TPA_Purpose_Description__c tpaPurposeDescription2 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        insert tpaPurposeDescription2;
        
    }
    private static testmethod void requestValidateOnLoadForDiffRequestTypeClientTest() {
        
        
        
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Address__c addrs = [select id from Address__c where Name = 'TPA Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        //Getting profile id for TP Processor Profile
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP%' Limit 1];//Updated by Babita Dadarwal under ER-3552
        
        //Creating User with TP Processor profile
        User user = new User(Alias = 'standt', Email='standarduser123@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',
                             ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@testing123.com',
                             TimeZoneSidKey='America/Los_Angeles', ContactId = con.id);
        
        //Creating TPA request
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'expired');
        insert tpaRequest;
        
        //Creating TPA request
        TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'cancelled');
        insert tpaRequest2;
        
        //Creating TPA request
        TPA_Request__c tpaRequest3 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'Awaiting Vendor Signature');
        insert tpaRequest3;
        
        //Creating TPA request
        TPA_Request__c tpaRequest4 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'in effect',Data_Access_Start_Date__c = Date.today(),
                                                        Data_Access_End_Date__c = Date.today()+1, Data_Asset_List__c = 'AAN',
                                                        Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                        Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test');
        insert tpaRequest4;

        AMA_Agreement_Detail__c amaSub = new AMA_Agreement_Detail__c(Client_req_Storage_Permission_from_NonUS__c = 'Yes',
                                                                    Client_Employee_Store_Data_in_country__c = 'india',
                                                                    Vendor_require_Remote_Access_from_NonUS__c = 'Yes',
                                                                    Vendor_Employee_Accessed_Data_in_country__c = 'india',
                                                                    Technology_s_selected_for_remote_access__c = 'test',
                                                                    Vendor_req_Storage_Permission_from_NonUS__c = 'Yes',
                                                                    Vendor_Employee_Store_Data_in_country__c = 'india'
                                                                    );
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/
        
        Test.StartTest();
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','c' );
        pageRef.getParameters().put('requestType', 'clone');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        Integer noOfRecords = CNT_TPA_RequestSubmissionForm.noOfRecords;
        Map<string, String> usesAndCategoryMap = CNT_TPA_RequestSubmissionForm.usesAndCategoryMap;
        tpaRequestFormController.getUsesWithCategoryMap();
        AMA_Agreement_Detail__c amaAgreementDetails = CNT_TPA_RequestSubmissionForm.amaAgreementDetails;
        string clientNote = CNT_TPA_RequestSubmissionForm.clientNote;
        string VendorNote =CNT_TPA_RequestSubmissionForm.VendorNote;
        string clientVendorNote =CNT_TPA_RequestSubmissionForm.clientVendorNote;
        //List<TPA_Text_Editor__C> offeringsNotificationList =  CNT_TPA_RequestSubmissionForm.offeringsNotificationList;
        //CNT_TPA_RequestSubmissionForm.populateAmaValuesSubmittedByClient(amaAgreementDetails, amaSub, new TPA_Request__c());
        //CNT_TPA_RequestSubmissionForm.populateAmaValuesSubmittedByVendor(amaAgreementDetails, amaSub, new TPA_Request__c());
        CNT_TPA_RequestSubmissionForm.resetAmaValuesOnTpaRequest(new TPA_Request__c());
        CNT_TPA_RequestSubmissionForm.resetAmaValuesOnAmaAgreement(new AMA_Agreement_Detail__c());
        CNT_TPA_RequestSubmissionForm.getAmaAgreement(tpaRequest4,amaSub,'Processor');
        CNT_TPA_RequestSubmissionForm.getAmaAgreement(tpaRequest4,amaSub,'RunTpaBusinessRule');
        tpaRequestFormController.requestValidateOnLoad();
        System.assertNotEquals(null, tpaRequestFormController);
        
        // To set the current page to TPA Page Access Request Form page
        pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','c' );
        pageRef.getParameters().put('requestType', 'renew');
        Test.setCurrentPage(pageRef);
        sc = new ApexPages.standardController(tpaRequest);
        tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        tpaRequestFormController.requestValidateOnLoad();
        System.assertNotEquals(null, tpaRequestFormController);
        
        // To set the current page to TPA Page Access Request Form page
        pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest2.Id);
        pageRef.getParameters().put('type','c' );
        pageRef.getParameters().put('requestType', 'View');
        Test.setCurrentPage(pageRef);
        sc = new ApexPages.standardController(tpaRequest);
        tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        tpaRequestFormController.requestValidateOnLoad();
        System.assertNotEquals(null, tpaRequestFormController);
        
        Test.StopTest();
    }
    
    
    private static testmethod void requestValidateOnLoadForDiffRequestTypeClientTest1() {
        
        
        
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Address__c addrs = [select id from Address__c where Name = 'TPA Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        //Getting profile id for TP Processor Profile
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP%' Limit 1];//Updated by Babita Dadarwal under ER-3552
        
        //Creating User with TP Processor profile
        User user = new User(Alias = 'standt', Email='standarduser123@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',
                             ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@testing123.com',
                             TimeZoneSidKey='America/Los_Angeles', ContactId = con.id);
        
        //Creating TPA request
        
        
        //Creating TPA request
        TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'cancelled');
        insert tpaRequest2;
        
        //Creating TPA request
        TPA_Request__c tpaRequest3 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'Awaiting Vendor Signature');
        insert tpaRequest3;
        
        //Creating TPA request
        TPA_Request__c tpaRequest4 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'in effect',
                                                        Data_Access_End_Date__c = Date.today()+1);
        insert tpaRequest4;
        
        //Creating Agreement
        TPA_Request__c tpaRequest;
        System.runAs(user) {
            tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'expired', Data_Asset_List__c = 'AAN',
                                            Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                            Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test');
            insert tpaRequest;
            String result = CNT_TPA_RequestSubmissionForm.getlastSelectedAddressRcrd;
            
            CNT_TPA_RequestSubmissionForm.getlastSelectedAddressRcrd = result;
            result = CNT_TPA_RequestSubmissionForm.getlastSelectedAddressRcrd;
            result = CNT_TPA_RequestSubmissionForm.getContactAddressCrowalk;
            //result = CNT_TPA_RequestSubmissionForm.isRenewedorModifiedRenewed;
            result = CNT_TPA_RequestSubmissionForm.TLLA_Doc;
            result = CNT_TPA_RequestSubmissionForm.AMA_Doc;
        }
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/
        
        Test.StartTest();
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        
        pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest3.Id);
        pageRef.getParameters().put('type','c' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        sc = new ApexPages.standardController(tpaRequest);
        tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        tpaRequestFormController.requestValidateOnLoad();
        System.assertNotEquals(null, tpaRequestFormController);

        String result1 = tpaRequestFormController.getlastSelectedQueueRcrd;
        String result2 = tpaRequestFormController.queueList;
        String cloneUseGuide = tpaRequestFormController.cloneUseGuide;
        Boolean vendorDocumentLanguageEnabled = tpaRequestFormController.vendorDocumentLanguageEnabled;
        String reqObjString = tpaRequestFormController.reqObjString;
        String requestSubmissionResult = tpaRequestFormController.requestSubmissionResult;
        String isRenewedReqUseandOfferingChanged = tpaRequestFormController.isRenewedReqUseandOfferingChanged;
        
        System.runAs(user) {
            // To set the current page to TPA Page Access Request Form page
            pageRef = Page.VFP_TPA_RequestSubmissionForm;
            pageRef.getParameters().put('id', tpaRequest.Id);
            pageRef.getParameters().put('type','c' );
            pageRef.getParameters().put('requestType', 'clone');
            Test.setCurrentPage(pageRef);
            sc = new ApexPages.standardController(tpaRequest);
            tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
            tpaRequestFormController.requestValidateOnLoad();
            TPA_Text_Editor__c mess = new TPA_Text_Editor__c(Page_Title__c = 'Shutdown Message',Page_Name__c='Shut',Is_Active__c=true);
            insert mess;
            String msg = tpaRequestFormController.Message;
            System.assertNotEquals(null, tpaRequestFormController);
        }
        
        Test.StopTest();
    }
    
    private static testmethod void requestValidateOnLoadForDiffRequestTypeVendorTest() {
        
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Address__c addrs = [select id from Address__c where Name = 'TPA Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        //Creating TPA request
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'expired');
        insert tpaRequest;
        
        //Creating TPA request
        TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'cancelled');
        insert tpaRequest2;
        
        //Creating TPA request
        TPA_Request__c tpaRequest3 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'Awaiting Vendor Signature');
        insert tpaRequest3;
        
        //Creating TPA request
        TPA_Request__c tpaRequest4 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), Request_Status__c = 'in effect',
                                                        Data_Access_End_Date__c = Date.today()+1);
        insert tpaRequest4;
        
        //Creating TPA request
        TPA_Request__c tpaRequest5 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), LastAction__c = 'Request Edited By Vendor', Data_Asset_List__c = 'AAN',
                                                        Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                        Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test');
        insert tpaRequest5;
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/
        
        Test.StartTest();
        
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        // In case of already submitted request by vendor
        pageRef.getParameters().put('id', tpaRequest5.Id);
        pageRef.getParameters().put('type','v' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        //tpaRequestFormController.currentLoggedInUser.Name = 'tpa Site Guest User';
        tpaRequestFormController.requestValidateOnLoad();
        System.assertNotEquals(null, tpaRequestFormController);
        
        // To set the current page to TPA Page Access Request Form page
        pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest3.Id);
        pageRef.getParameters().put('type','v' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        sc = new ApexPages.standardController(tpaRequest);
        tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        tpaRequestFormController.requestValidateOnLoad();
        System.assertNotEquals(null, tpaRequestFormController);
        
        // To set the current page to TPA Page Access Request Form page
        pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest4.Id);
        pageRef.getParameters().put('type','v' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        sc = new ApexPages.standardController(tpaRequest);
        tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        tpaRequestFormController.requestValidateOnLoad();
        System.assertNotEquals(null, tpaRequestFormController);
        
        string picklistValues = tpaRequestFormController.getDependentVendorStateCountries;
        string msgBrdContent = tpaRequestFormController.msgBoardContent;
        string picklistValues2 = tpaRequestFormController.getDependentVendorComplianceStateCountries;
        Test.StopTest();
    }
    
    private static testmethod void myUnitTest() {
        // UTL_TPA_SetupTestData.setUpPseSecurity();
        // UTL_TPA_SetupTestData.createTPASettingData();
        Address__c testAddress = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor',1200);
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //Account testAccount = [select id from Account where id=: testAddress.Account__c];
        Contact tpaContact1 = UTL_TPA_SetupTestData.getTestContact(testAddress);
        System.debug('2.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        Profile p = [SELECT Id FROM Profile WHERE Name='TPA Customer Community Plus Login User'];
        User usr =  new User(Alias = 'standt', Email='standarduser@testorg.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p.Id,
                             TimeZoneSidKey='America/Los_Angeles',
                             UserName='standarduser@testorg.com',
                             ContactId= tpaContact1.Id);
        insert usr;
        System.debug('3.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //UTL_TPA_SetupTestData.createTPASettingData();
        TPA_Settings__c TPA_SettingObj1 = new TPA_Settings__c(Name = 'Test1', VendorMessageBoardId__c = 'test id', TPA_RequestSubmitted_Email__c = 'Test Email', Base_Url__c = String.valueOf(URL.getOrgDomainUrl()),SetupOwnerId=p.id);
        
        insert TPA_SettingObj1 ;
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        
        //Creating TPA Account
        Account acc = new Account(Name = 'the Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert acc;
        System.debug('5.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //Creating Address
        Address__c addrs = [select id from Address__c where Name = 'TPA Test Acc' limit 1];
        
        CNT_TPA_RequestSubmissionForm.updateAccount(addrs.Id, 'Yes');
        System.debug('6.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //Creating TPA Account
        //Account acc2 = new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1');//Modified by C.P.Pandey under Issue-7181
        //insert acc2;
        
        //Creating Address
        //Address__c addrs2 = [select id from Address__c where Name = 'TPA Test Acc' limit 1];

        //Creating Contact
        Contact con = new Contact(FirstName = 'TestFirstName1', LastName = 'Test Contact1', Email = 'sunny1.bansal@metacube.com', AccountId = acc.id);
        // setUpPseSecurityMethod();
        insert con;
        System.debug('7.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating Contact
        //Contact con2 = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com');
        //insert con2;
        
        //Creating TPA request
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true, TP_Processor_Email__c= 'test@test.com',Data_Access_Start_Date__c = Date.today(), Data_Access_End_Date__c = Date.today()+365,
                                                       Vendor_e_mail__c = 'test@test.com',
                                                       Client_Contact_Territory__c = 'United States',Vendor_Billing_Mailing_Country__c= 'United States', Client_Address__c = testAddress.Id, ClientContact__c = tpaContact1.id, Client_Language__c = 'English', Vendor_Language__c = 'English');
        insert tpaRequest;
        System.debug('8.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating TPA request
        TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                        Client_Contact_Territory__c = 'United States', Vendor_Billing_Mailing_Country__c= 'United States', isVendorSubmitted__c = true, ClientContact__c = con.id,
                                                        Is_Potential_Vendor_Case__c = true, TPA_Request_Marked_as__c = 'Public', Secondary_Client_Contact_Territory__c = 'United States', Client_Language__c = 'English', Vendor_Language__c = 'English',
                                                        Data_Asset_List__c = 'AAN',Data_Access_Start_Date__c = Date.today(), Data_Access_End_Date__c = Date.today()+365,
                                                        Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                        Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test', Client_Address__c = addrs.Id);
        
        //Creating TP Processor
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'sunny.bansal@metacube.com'); //Region__c = 'United States',  sunny change123
        insert tpProcessor;
        System.debug('9.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating TPA_Region_Country
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;
        System.debug('10.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        system.debug(':::'+tpaRequest.Id);
        
        TPA_Contact__c tpaContact = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        //insert tpaContact;
        
        TPA_Contact__c tpaContact2 = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        
        //Fetching Record type id for ATC
        RecordType recordType = [Select id From RecordType Where name = 'ATC'];
        
        //Fetching Record type id for USC
        RecordType recordType2 = [Select id From RecordType Where name = 'USC'];
        System.debug('11.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //Creating Therapautic Area for ATC
        ATC__c tpaATC = new ATC__c(Active__c = true, ATC_Code__c = 'A011', Name_Eng__c = 'A011', RecordTypeId = recordType.id, Level__c = 2);
        
        //insert tpaATC;
        
        //Creating Therapautic Area for USC
        ATC__c tpaATC2 = new ATC__c(Active__c = true, ATC_Code__c = '0100', Name_Eng__c = '0100', RecordTypeId = recordType2.id);
        //insert tpaATC2;
        
        //Creating Therapautic Area for USC
        ATC__c tpaATC3 = new ATC__c(Active__c = true, ATC_Code__c = '01000', Name_Eng__c = '01000', RecordTypeId = recordType2.id);
        //insert tpaATC3;
        
        insert new List<ATC__c>{tpaATC, tpaATC2, tpaATC3};
        System.debug('12.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c(TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id);
        insert tpaRequestATC;
        System.debug('13.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        //insert imsTpaPurpose;
        
        IMS_TPA_Purpose__c imsTpaPurpose2 = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'Other', Purpose_Details__c = 'test detail2',
                                                                   Is_Active__c = true);
        //insert imsTpaPurpose2;
        
        insert new List<IMS_TPA_Purpose__c> {imsTpaPurpose, imsTpaPurpose2};
        System.debug('14.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        //insert tpaPurposeCategory;
        
        TPA_Purpose_Category__c tpaPurposeCategory2 = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        //insert tpaPurposeCategory2;
        
        insert new List<TPA_Purpose_Category__c>{tpaPurposeCategory, tpaPurposeCategory2};
        System.debug('15.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',purpose__c = imsTpaPurpose.id,Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        //insert tpaPurpose;
        
        TPA_Purpose__c tpaPurpose2 = new TPA_Purpose__c(Name = 'Other' , Other_Text__c = 'test' , purpose__c = imsTpaPurpose.id,Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        //insert tpaPurpose2;
        
        TPA_Purpose__c tpaPurpose3 = new TPA_Purpose__c(Name = 'Test TPA Purpose3',purpose__c = imsTpaPurpose.id,Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        //insert tpaPurpose3;
        
        TPA_Purpose__c tpaPurpose4 = new TPA_Purpose__c(Name = 'Other' , Other_Text__c = 'test', purpose__c = imsTpaPurpose.id,Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        //insert tpaPurpose4;
        insert new List<TPA_Purpose__c> {tpaPurpose, tpaPurpose2, tpaPurpose3, tpaPurpose4};
        System.debug('16.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset;
        System.debug('17.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        //insert tpaDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset2 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        //insert tpaDataAsset2;
        
        TPA_Data_Asset__c tpaDataAsset3 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose3.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        //insert tpaDataAsset3;
        
        TPA_Data_Asset__c tpaDataAsset4 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose4.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        //insert tpaDataAsset4;
        insert new List<TPA_Data_Asset__c> {tpaDataAsset, tpaDataAsset2, tpaDataAsset3, tpaDataAsset4};
        System.debug('18.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        System.debug('19.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        //insert tpaSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        //insert tpaSecondaryDataAsset2;
        insert new List<TPA_Secondary_Data_Asset__c>{tpaSecondaryDataAsset, tpaSecondaryDataAsset2};
        System.debug('20.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset3 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset4 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id);
        //insert imsTpaPurposeCategory;
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        //insert imsTpaPurposeCategory2;
        insert new List<IMS_TPA_Purpose_Category__c>{imsTpaPurposeCategory, imsTpaPurposeCategory2};
        System.debug('21.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true);
        //insert imsTpaPurposeDescription;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id,
                                                                                                      Is_Active__c = true);
        //insert imsTpaPurposeDescription2;
        insert new List<IMS_TPA_Purpose_Description__c>{imsTpaPurposeDescription, imsTpaPurposeDescription2};
        System.debug('22.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Purpose_Description__c tpaPurposeDescription = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                          Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        //insert tpaPurposeDescription;
        
        TPA_Purpose_Description__c tpaPurposeDescription2 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        //insert tpaPurposeDescription2;
        insert new List<TPA_Purpose_Description__c>{tpaPurposeDescription, tpaPurposeDescription2};
        System.debug('23.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Purpose_Description__c tpaPurposeDescription3 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                           Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        
        TPA_Purpose_Description__c tpaPurposeDescription4 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        
        
        //Inserting country in custom setting TPA_Country_Codes__c
        TPA_Country_Codes__c tpaCountryCode = new TPA_Country_Codes__c(name = 'India', Country_Possible_Codes__c = 'IN', Code_Type__c = 'C');
        //insert tpaCountryCode;
        
        //Inserting state in custom setting TPA_Country_Codes__c
        TPA_Country_Codes__c tpaCountryCode2 = new TPA_Country_Codes__c(name = 'Delhi', Country_Possible_Codes__c = 'DL', Code_Type__c = 'S');
        //insert tpaCountryCode2;
        insert new List<TPA_Country_Codes__c>{tpaCountryCode, tpaCountryCode2};
        System.debug('24.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_AMA_Picklist__c amaPicklist = new TPA_AMA_Picklist__c(Name = 'AMAValue123', Picklist_value__c = 'Telemarketing');
        //insert amaPicklist;
        TPA_AMA_Picklist__c amaPicklist2 = new TPA_AMA_Picklist__c(Name = 'AMAValue124', Picklist_value__c = 'Telemarketing1');
        TPA_AMA_Picklist__c amaPicklist3 = new TPA_AMA_Picklist__c(Name = 'AMAValue125', Picklist_value__c = 'Telemarketing2');
        TPA_AMA_Picklist__c amaPicklist4 = new TPA_AMA_Picklist__c(Name = 'AMAValue126', Picklist_value__c = 'Telemarketing3');
        TPA_AMA_Picklist__c amaPicklist5 = new TPA_AMA_Picklist__c(Name = 'AMAValue127', Picklist_value__c = 'Telemarketing4');
        TPA_AMA_Picklist__c amaPicklist6 = new TPA_AMA_Picklist__c(Name = 'AMAValue128', Picklist_value__c = 'Telemarketing5');
        insert new List<TPA_AMA_Picklist__c>{amaPicklist, amaPicklist2, amaPicklist3, amaPicklist4, amaPicklist5, amaPicklist6};
        System.debug('25.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        new CNT_TPA_RequestSubmissionForm().getAMAlistValuesDataMap();
        System.debug('26.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //List to store TPA Contact
        List<TPA_Contact__c> tpaContactList= new List<TPA_Contact__c>();
        tpaContactList.add(tpaContact);
        
        //List to store TPA SubContractor
        List<TPA_Contact__c> tpaSubContractorsList= new List<TPA_Contact__c>();
        tpaSubContractorsList.add(tpaContact2);
        
        //List to store ATC
        List<ATC__c> listSavedATC = new List<ATC__c>();
        listSavedATC.add(tpaATC);
        
        //List to store IMS TPA Purpose Description
        List<IMS_TPA_Purpose_Category__c> imsTpaPurposecategoryList = new List<IMS_TPA_Purpose_Category__c>();
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory);
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory2);
        
        //Creating Instance of wrapper class
        CNT_TPA_RequestSubmissionForm.WrapperClass wrapperClassObj = new CNT_TPA_RequestSubmissionForm.WrapperClass();
        wrapperClassObj.dataAsset = '';
        wrapperClassObj.categoryName = '';
        wrapperClassObj.purposeName = '';
        wrapperClassObj.purposeId = '';
        wrapperClassObj.otherPurposeId = '';
        wrapperClassObj.country = '';
        wrapperClassObj.selectDes = '';
        wrapperClassObj.selectdataAssDetails = '';
        wrapperClassObj.selectdataAssforOfferingAdditionDetails = '';
        wrapperClassObj.key ='';
        wrapperClassObj.isUseDefinitionfileExist = true;
        System.debug('27.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Map to store purpose description
        Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass> selectedDescriptionMap = new Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass>();
        selectedDescriptionMap.put(tpaPurposeDescription.id, wrapperClassObj);
        
        //Map top store purposes
        Map<String,TPA_Purpose__c> purposesMap = new Map<String,TPA_Purpose__c>();
        purposesMap.put('tpaPurpose3',tpaPurpose3);
        
        //Map to store purposes named Other
        Map<String,TPA_Purpose__c> purposesOtherMap = new Map<String,TPA_Purpose__c>();
        purposesOtherMap.put('tpaPurpose4',tpaPurpose4);
        
        //Map to store purposes description
        Map<String,TPA_Purpose_Description__c> purpDescMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescMap.put('tpaPurpose3', tpaPurposeDescription3);
        
        //Map to store purposes description of Other named purposes
        Map<String,TPA_Purpose_Description__c> purpDescOtherMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescOtherMap.put('tpaPurpose4', tpaPurposeDescription4);
        
        //Set tp store data assets
        Set<TPA_Data_Asset__c> tpaDataAssetSet = new Set<TPA_Data_Asset__c>();
        tpaDataAssetSet.add(tpaDataAsset3);
        tpaDataAssetSet.add(tpaDataAsset4);
        
        //List to store secondary data assets
        List<TPA_Secondary_Data_Asset__c> tpaSecondaryDataAssetList = new List<TPA_Secondary_Data_Asset__c>();
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset3);
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset4);
        
        //Map to store data assets along with purpose id
        Map<String,set<TPA_Data_Asset__c>> mapPurposesIdWithDataAsset = new Map<String,set<TPA_Data_Asset__c>>();
        mapPurposesIdWithDataAsset.put('dataAssetMap', tpaDataAssetSet);
        
        //Map to store secondary data assets along with purpose id
        Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetsToInsert = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
        mapSecondayDataAssetsToInsert.put('dataAssetMap', tpaSecondaryDataAssetList);
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/
        System.debug('28.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA.modifyRequestNonSysAdminUser = true;
        Test.StartTest();
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','c' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        
        System.debug('001.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaRequestFormController.isAuthorisedSigner = 'Yes';
        
        System.debug('002.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getPresciberLevelAttributesList();
        System.debug('003.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getAmaFreqDeliveryData();
        System.debug('004.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getAMAlistValuesData();
        System.debug('005.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getAmaPrescLvlData();
        System.debug('006.Number of Queries used in this apex code so far: ' + Limits.getQueries());
     //   tpaRequestFormController.getAmaResponseCollectionMeans();
        System.debug('007.Number of Queries used in this apex code so far: ' + Limits.getQueries());
      //  tpaRequestFormController.getAmaPpdVariablesData();
        System.debug('008.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        
        
        
        tpaRequestFormController.getImsSoftwareData();
        System.debug('012.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaRequestFormController.getLoggedInCurrentUser();
        System.debug('014.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getVendorLoggedInUser();
        System.debug('015.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getObjectTpaRequestToEdit();
        System.debug('016.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getObjectExistedUsesAndAssets();
        System.debug('017.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaRequestFormController.getLanguageMap();
        System.debug('018.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getTranslatedMap();
        System.debug('019.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        CNT_TPA_RequestSubmissionForm.language = 'en_US';
        Map<String, String> supportedLanguageMaptest = new Map<String, String>();
        supportedLanguageMaptest.put('en_US' , 'English~English_Translation__c~English');
        
        //CNT_TPA_RequestSubmissionForm.supportedLanguageMap = supportedLanguageMaptest;
        String tpaRequestJSON = JSON.serialize(tpaRequest2);
        System.debug('addrs2-----------------> ' + JSON.serialize(tpaRequest2));
        System.debug('testAddress-----------------> ' + testAddress);
        String tpaContactListJSON = JSON.serialize(tpaContactList);
        String tpaSubContractorsListJSON = JSON.serialize(tpaSubContractorsList);
        String listSavedATCJSON = JSON.serialize(listSavedATC);
        String imsTpaPurposecategoryListJSON = JSON.serialize(imsTpaPurposecategoryList);
        String SelectedDescMapJSON = JSON.serialize(selectedDescriptionMap);
        String purposesMapJSON = JSON.serialize(purposesMap);
        String purposesOtherMapJSON = JSON.serialize(purposesOtherMap);
        String purpDescMapJSON = JSON.serialize(purpDescMap);
        String purpDescOtherMapJSON = JSON.serialize(purpDescOtherMap);
        String mapPurposesIdWithDataAssetJSON = JSON.serialize(mapPurposesIdWithDataAsset);
        String mapSecondayDataAssetsToInsertJSON = JSON.serialize(mapSecondayDataAssetsToInsert);
        String addID = JSON.serialize(testAddress.Id);
        
        //Added by C.P.Pandey under ER-2654 start
        List<TPA_Use_Offerings_UI_Backup__c> useOffListToInsert = new List<TPA_Use_Offerings_UI_Backup__c>();
        TPA_Use_Offerings_UI_Backup__c useOffObjToInsert = new TPA_Use_Offerings_UI_Backup__c(Details__c = ' edited', Country__c = 'Test', GUID__c = 'Test', Offerings_Selected__c = 'Test', Use_Name_with_Id__c = 'Test', TPA_Request__c = tpaRequest.Id);
        useOffListToInsert.add(useOffObjToInsert);
        String tpaRequestDetailsJSONtemp = '{"tpaRequest" : '+tpaRequestJSON+', "requestTypeSubmitted" : "NewRequest","processedLanguage" : "en_US" ,"GUID" : "21b213d3-6912-58f1-4152-1712f5fdf611", "tpaAdditionalContactList" : '+tpaContactListJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+ ', "useOffBackupIds":"' + null + '"' + ', "isOnlyReferenceDataCatSelected" : false }';//Added by C.P.Pandey under ER-2654

        CNT_TPA_RequestSubmissionForm.backupUseOffering(Json.serialize(useOffListToInsert), tpaRequestDetailsJSONtemp);
        System.debug('020.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        insert useOffObjToInsert;
        string useOffBackupIdsJSON = '' + useOffObjToInsert.Id;
        CNT_TPA_RequestSubmissionForm.tpaRequestDetails tpaReq = new CNT_TPA_RequestSubmissionForm.tpaRequestDetails();
        tpaReq.tpaRequest = tpaRequest;
        tpaReq.bulkCSVFileBody = 'bulkCSVFileBody';
        tpaReq.bulkCSVFileName = 'bulkCSVFileName';
        tpaReq.parentRequestOfferingDetails = 'parentRequestOfferingDetails';
        tpaReq.parentRequestCategoryDetails = 'parentRequestCategoryDetails';
        tpaReq.parentRequestOffCountryDetails = 'parentRequestOffCountryDetails';
        tpaReq.parentRequestUseDetails = 'parentRequestUseDetails';
        CNT_TPA_RequestSubmissionForm.saveBulkCSVFile(tpaReq);
        CNT_TPA_RequestSubmissionForm.WrapperClass wrapperClassObject = new CNT_TPA_RequestSubmissionForm.WrapperClass();
        wrapperClassObject.translatedOfferingCategoryName = 'translatedOfferingCategoryName';
        wrapperClassObject.offeringCategoryName = 'offeringCategoryName';
        
        //Added by C.P.Pandey under ER-2654 end
        
        //Calling save request method where requestTypeSubmitted is NewRequest

        String tpaRequestDetailsJSON = '{"tpaRequest" : '+tpaRequestJSON+', "requestTypeSubmitted" : "NewRequest","processedLanguage" : "en_US" ,"GUID" : "21b213d3-6912-58f1-4152-1712f5fdf611", "tpaAdditionalContactList" : '+tpaContactListJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+ ', "useOffBackupIds":"' + useOffBackupIdsJSON + '"' + ', "isOnlyReferenceDataCatSelected" : false }';//Added by C.P.Pandey under ER-2654
        System.assertNotEquals(null, tpaRequestDetailsJSON);
        //try{
            CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON);
        System.debug('021.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //}
        //catch(Exception e){}
        //Calling save request method where requestTypeSubmitted is ClientSubmit
        //TPA_Request__c newTpaRequest = [Select id From TPA_Request__c Where isVendorSubmitted__c = true];
        String tpaRequestJSON2 = JSON.serialize(tpaRequest);
        String tpaRequestDetailsJSON2 = '{"tpaRequest" : '+tpaRequestJSON2+', "clientAddress" : '+addID+', "requestTypeSubmitted" : "ClientSubmit","GUID" : "21b213d3-6912-58f1-4152-1712f5fdf611","processedLanguage" : "en_US","isPublicPrivateChangeOnly" : false, "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+ ', "useOffBackupIds":"' + useOffBackupIdsJSON + '"' + '}';//Added by C.P.Pandey under ER-2654
        //try{
            CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON2);
        System.debug('022.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //}
        //catch(Exception e){}
        //Calling save request method where requestTypeSubmitted is VendorSubmit
        String tpaRequestDetailsJSON3 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "VendorSubmit","processedLanguage" : "en_US", "GUID" : "21b213d3-6912-58f1-4152-1712f5fdf611","isPublicPrivateChangeOnly" : false, "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
        //try{
            CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON3);
        System.debug('023.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //}
        
        tpaRequest.TPA_Request_Marked_as__c = 'Private';
        String tpaRequestJSON3 = JSON.serialize(tpaRequest);
        String tpaRequestDetailsJSON4 = '{"tpaRequest" : '+tpaRequestJSON3+', "requestTypeSubmitted" : "InDraftRequest","processedLanguage" : "en_US", "GUID" : "21b213d3-6912-58f1-4152-1712f5fdf611", "isPublicPrivateChangeOnly" : false, "tpaAdditionalContactList" : '+tpaContactListJSON+', "clientAddress" :"'+testAddress.Id+'", "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
        CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON4);
        System.debug('024.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //tpaRequestDetailsJSON4 = '{"tpaRequest" : '+tpaRequestJSON3+', "requestTypeSubmitted" : "NewRequest","processedLanguage" : "en_US","isPublicPrivateChangeOnly" : false, "tpaAdditionalContactList" : '+tpaContactListJSON+', "clientAddress" :"'+testAddress.Id+'", "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
        //CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON4);
        
        //catch(Exception e){}
        string valTmp = CNT_TPA_RequestSubmissionForm.jsonAmaDataOffering;
        System.debug('025.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        Map<String,String> mapTmp;
        List<String> lstTmp;
        mapTmp = CNT_TPA_RequestSubmissionForm.secAssetFieldMap;
        mapTmp = CNT_TPA_RequestSubmissionForm.priAssetFieldMap;
        lstTmp = CNT_TPA_RequestSubmissionForm.approvedCountriesForRemoteAccess;
        lstTmp = CNT_TPA_RequestSubmissionForm.ApprovedCountriesForStorage;
        CNT_TPA_RequestSubmissionForm accessMultiObj = new CNT_TPA_RequestSubmissionForm();
        System.debug('026.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        valTmp = accessMultiObj.msgPrimaryBoardContent;
        valTmp = accessMultiObj.getSecDataAssetFieldMap();
        System.debug('027.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        valTmp = accessMultiObj.getPriDataAssetFieldMap();
        System.debug('028.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating instance of tpaRequestDetails class
        CNT_TPA_RequestSubmissionForm.tpaRequestDetails tpaRequestDetailsObj = new CNT_TPA_RequestSubmissionForm.tpaRequestDetails();
        System.debug('029.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestDetailsObj.isVendorContactInvited = true;
        tpaRequestDetailsObj.invitedContact = con;
        tpaRequestDetailsObj.vendorName = 'Sunny';
        tpaRequestDetailsObj.vendorContactName = 'sunny bansal';
        object result = tpaRequestDetailsObj.GUID;
        result = tpaRequestDetailsObj.secondarypurpose;
        System.debug('030.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        result = tpaRequestDetailsObj.mapSecondayDataAssetToInsert;
        System.debug('031.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating instance of wrapperClassAssetPurpose class
        CNT_TPA_RequestSubmissionForm.wrapperClassAssetPurpose wrapperClassAssetPurposeObj = new CNT_TPA_RequestSubmissionForm.wrapperClassAssetPurpose();
        System.debug('032.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        wrapperClassAssetPurposeObj.purposeCategoryId = '123';
        wrapperClassAssetPurposeObj.useDefinitionPage = 'test use definition';
        result = wrapperClassAssetPurposeObj.Param_otherDesc;
        System.debug('033.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating instance of existedUsesAndAssets class
        CNT_TPA_RequestSubmissionForm.existedUsesAndAssets existedUsesAndAssetsObj = new CNT_TPA_RequestSubmissionForm.existedUsesAndAssets();
        System.debug('034.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        existedUsesAndAssetsObj.commDataAsset = '';
        
        //Creating instance of controlNumberAuthSignerDetail class
        CNT_TPA_RequestSubmissionForm.controlNumberAuthSignerDetail controlNumberAuthSignerDetailObj = new CNT_TPA_RequestSubmissionForm.controlNumberAuthSignerDetail();
        System.debug('035.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        controlNumberAuthSignerDetailObj.vendorAddress = 'Delhi';
        controlNumberAuthSignerDetailObj.vendorCity = 'Delhi';
        controlNumberAuthSignerDetailObj.vendorPostal = '110032';
        controlNumberAuthSignerDetailObj.authorizedSignerEmail = 'sunny.bansal@metacube.com';
        controlNumberAuthSignerDetailObj.authorizedSignerRequired = 'yes';
        
        CNT_TPA_RequestSubmissionForm.getAcknowledgementDateTime();
        System.debug('036.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        List<String> lsitImsDataAssets = new List<String>();
        lsitImsDataAssets.add(imsDataAsset.Id);
        CNT_TPA_RequestSubmissionForm.getOfferingsNotificationsList(lsitImsDataAssets);
        System.debug('037.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        CNT_TPA_RequestSubmissionForm.loadUsesAndAssets(tpaRequest.Id,tpaRequest.Id,'next','Client');
        CNT_TPA_RequestSubmissionForm.loadUsesAndAssets(tpaRequest.Id,tpaRequest.Id,'next','Vendor');
        Test.StopTest();
        //}
    }

    private static testmethod void myUnitTest2() {
        // UTL_TPA_SetupTestData.setUpPseSecurity();
        // UTL_TPA_SetupTestData.createTPASettingData();
        Address__c testAddress = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor',1200);
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //Account testAccount = [select id from Account where id=: testAddress.Account__c];
        Contact tpaContact1 = UTL_TPA_SetupTestData.getTestContact(testAddress);
        System.debug('2.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        Profile p = [SELECT Id FROM Profile WHERE Name='TPA Customer Community Plus Login User'];
        User usr =  new User(Alias = 'standt', Email='standarduser@testorg.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p.Id,
                             TimeZoneSidKey='America/Los_Angeles',
                             UserName='standarduser@testorg.com',
                             ContactId= tpaContact1.Id);
        insert usr;
        System.debug('3.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //UTL_TPA_SetupTestData.createTPASettingData();
        TPA_Settings__c TPA_SettingObj1 = new TPA_Settings__c(Name = 'Test1', VendorMessageBoardId__c = 'test id', TPA_RequestSubmitted_Email__c = 'Test Email', Base_Url__c = String.valueOf(URL.getOrgDomainUrl()),SetupOwnerId=p.id);
        
        insert TPA_SettingObj1 ;
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        
        //Creating TPA Account
        Account acc = new Account(Name = 'the Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert acc;
        System.debug('5.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //Creating Address
        Address__c addrs = [select id from Address__c where Name = 'TPA Test Acc' limit 1];
        
        CNT_TPA_RequestSubmissionForm.updateAccount(addrs.Id, 'Yes');
        System.debug('6.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //Creating TPA Account
        //Account acc2 = new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1');//Modified by C.P.Pandey under Issue-7181
        //insert acc2;
        
        //Creating Address
        //Address__c addrs2 = [select id from Address__c where Name = 'TPA Test Acc' limit 1];

        //Creating Contact
        Contact con = new Contact(FirstName = 'TestFirstName1', LastName = 'Test Contact1', Email = 'sunny1.bansal@metacube.com', AccountId = acc.id);
        // setUpPseSecurityMethod();
        insert con;
        System.debug('7.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating Contact
        //Contact con2 = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com');
        //insert con2;
        
        //Creating TPA request
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true, TP_Processor_Email__c= 'test@test.com',Data_Access_Start_Date__c = Date.today(), Data_Access_End_Date__c = Date.today()+365,
                                                       Vendor_e_mail__c = 'test@test.com',
                                                       Client_Contact_Territory__c = 'United States',Vendor_Billing_Mailing_Country__c= 'United States', Client_Address__c = testAddress.Id, ClientContact__c = tpaContact1.id, Client_Language__c = 'English', Vendor_Language__c = 'English');
        insert tpaRequest;
        System.debug('8.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating TPA request
        TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                        Client_Contact_Territory__c = 'United States', Vendor_Billing_Mailing_Country__c= 'United States', isVendorSubmitted__c = true, ClientContact__c = con.id,
                                                        Is_Potential_Vendor_Case__c = true, TPA_Request_Marked_as__c = 'Public', Secondary_Client_Contact_Territory__c = 'United States', Client_Language__c = 'English', Vendor_Language__c = 'English',
                                                        Data_Asset_List__c = 'AAN',Data_Access_Start_Date__c = Date.today(), Data_Access_End_Date__c = Date.today()+365,
                                                        Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                        Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test', Client_Address__c = addrs.Id);
        
        //Creating TP Processor
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'sunny.bansal@metacube.com'); //Region__c = 'United States',  sunny change123
        insert tpProcessor;
        System.debug('9.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating TPA_Region_Country
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;
        System.debug('10.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        system.debug(':::'+tpaRequest.Id);
        
        TPA_Contact__c tpaContact = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        //insert tpaContact;
        
        TPA_Contact__c tpaContact2 = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        
        //Fetching Record type id for ATC
        RecordType recordType = [Select id From RecordType Where name = 'ATC'];
        
        //Fetching Record type id for USC
        RecordType recordType2 = [Select id From RecordType Where name = 'USC'];
        System.debug('11.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //Creating Therapautic Area for ATC
        ATC__c tpaATC = new ATC__c(Active__c = true, ATC_Code__c = 'A011', Name_Eng__c = 'A011', RecordTypeId = recordType.id, Level__c = 2);
        
        //insert tpaATC;
        
        //Creating Therapautic Area for USC
        ATC__c tpaATC2 = new ATC__c(Active__c = true, ATC_Code__c = '0100', Name_Eng__c = '0100', RecordTypeId = recordType2.id);
        //insert tpaATC2;
        
        //Creating Therapautic Area for USC
        ATC__c tpaATC3 = new ATC__c(Active__c = true, ATC_Code__c = '01000', Name_Eng__c = '01000', RecordTypeId = recordType2.id);
        //insert tpaATC3;
        
        insert new List<ATC__c>{tpaATC, tpaATC2, tpaATC3};
        System.debug('12.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c(TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id);
        insert tpaRequestATC;
        System.debug('13.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        //insert imsTpaPurpose;
        
        IMS_TPA_Purpose__c imsTpaPurpose2 = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'Other', Purpose_Details__c = 'test detail2',
                                                                   Is_Active__c = true);
        //insert imsTpaPurpose2;
        
        insert new List<IMS_TPA_Purpose__c> {imsTpaPurpose, imsTpaPurpose2};
        System.debug('14.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        //insert tpaPurposeCategory;
        
        TPA_Purpose_Category__c tpaPurposeCategory2 = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        //insert tpaPurposeCategory2;
        
        insert new List<TPA_Purpose_Category__c>{tpaPurposeCategory, tpaPurposeCategory2};
        System.debug('15.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',purpose__c = imsTpaPurpose.id,Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        //insert tpaPurpose;
        
        TPA_Purpose__c tpaPurpose2 = new TPA_Purpose__c(Name = 'Other', Other_Text__c = 'test', purpose__c = imsTpaPurpose.id,Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        //insert tpaPurpose2;
        
        TPA_Purpose__c tpaPurpose3 = new TPA_Purpose__c(Name = 'Test TPA Purpose3',purpose__c = imsTpaPurpose.id,Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        //insert tpaPurpose3;
        
        TPA_Purpose__c tpaPurpose4 = new TPA_Purpose__c(Name = 'Other', Other_Text__c = 'test', purpose__c = imsTpaPurpose.id,Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        //insert tpaPurpose4;
        insert new List<TPA_Purpose__c> {tpaPurpose, tpaPurpose2, tpaPurpose3, tpaPurpose4};
        System.debug('16.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset;
        System.debug('17.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        //insert tpaDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset2 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        //insert tpaDataAsset2;
        
        TPA_Data_Asset__c tpaDataAsset3 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose3.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        //insert tpaDataAsset3;
        
        TPA_Data_Asset__c tpaDataAsset4 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose4.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        //insert tpaDataAsset4;
        insert new List<TPA_Data_Asset__c> {tpaDataAsset, tpaDataAsset2, tpaDataAsset3, tpaDataAsset4};
        System.debug('18.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        System.debug('19.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        //insert tpaSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        //insert tpaSecondaryDataAsset2;
        insert new List<TPA_Secondary_Data_Asset__c>{tpaSecondaryDataAsset, tpaSecondaryDataAsset2};
        System.debug('20.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset3 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset4 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id);
        //insert imsTpaPurposeCategory;
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        //insert imsTpaPurposeCategory2;
        insert new List<IMS_TPA_Purpose_Category__c>{imsTpaPurposeCategory, imsTpaPurposeCategory2};
        System.debug('21.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true);
        //insert imsTpaPurposeDescription;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id,
                                                                                                      Is_Active__c = true);
        //insert imsTpaPurposeDescription2;
        insert new List<IMS_TPA_Purpose_Description__c>{imsTpaPurposeDescription, imsTpaPurposeDescription2};
        System.debug('22.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Purpose_Description__c tpaPurposeDescription = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                          Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        //insert tpaPurposeDescription;
        
        TPA_Purpose_Description__c tpaPurposeDescription2 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        //insert tpaPurposeDescription2;
        insert new List<TPA_Purpose_Description__c>{tpaPurposeDescription, tpaPurposeDescription2};
        System.debug('23.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Purpose_Description__c tpaPurposeDescription3 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                           Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        
        TPA_Purpose_Description__c tpaPurposeDescription4 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        
        
        //Inserting country in custom setting TPA_Country_Codes__c
        TPA_Country_Codes__c tpaCountryCode = new TPA_Country_Codes__c(name = 'India', Country_Possible_Codes__c = 'IN', Code_Type__c = 'C');
        //insert tpaCountryCode;
        
        //Inserting state in custom setting TPA_Country_Codes__c
        TPA_Country_Codes__c tpaCountryCode2 = new TPA_Country_Codes__c(name = 'Delhi', Country_Possible_Codes__c = 'DL', Code_Type__c = 'S');
        //insert tpaCountryCode2;
        insert new List<TPA_Country_Codes__c>{tpaCountryCode, tpaCountryCode2};
        System.debug('24.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_AMA_Picklist__c amaPicklist = new TPA_AMA_Picklist__c(Name = 'AMAValue123', Picklist_value__c = 'Telemarketing');
        //insert amaPicklist;
        TPA_AMA_Picklist__c amaPicklist2 = new TPA_AMA_Picklist__c(Name = 'AMAValue124', Picklist_value__c = 'Telemarketing1');
        TPA_AMA_Picklist__c amaPicklist3 = new TPA_AMA_Picklist__c(Name = 'AMAValue125', Picklist_value__c = 'Telemarketing2');
        TPA_AMA_Picklist__c amaPicklist4 = new TPA_AMA_Picklist__c(Name = 'AMAValue126', Picklist_value__c = 'Telemarketing3');
        TPA_AMA_Picklist__c amaPicklist5 = new TPA_AMA_Picklist__c(Name = 'AMAValue127', Picklist_value__c = 'Telemarketing4');
        TPA_AMA_Picklist__c amaPicklist6 = new TPA_AMA_Picklist__c(Name = 'AMAValue128', Picklist_value__c = 'Telemarketing5');
        insert new List<TPA_AMA_Picklist__c>{amaPicklist, amaPicklist2, amaPicklist3, amaPicklist4, amaPicklist5, amaPicklist6};
        System.debug('25.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        new CNT_TPA_RequestSubmissionForm().getAMAlistValuesDataMap();
        System.debug('26.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //List to store TPA Contact
        List<TPA_Contact__c> tpaContactList= new List<TPA_Contact__c>();
        tpaContactList.add(tpaContact);
        
        //List to store TPA SubContractor
        List<TPA_Contact__c> tpaSubContractorsList= new List<TPA_Contact__c>();
        tpaSubContractorsList.add(tpaContact2);
        
        //List to store ATC
        List<ATC__c> listSavedATC = new List<ATC__c>();
        listSavedATC.add(tpaATC);
        
        //List to store IMS TPA Purpose Description
        List<IMS_TPA_Purpose_Category__c> imsTpaPurposecategoryList = new List<IMS_TPA_Purpose_Category__c>();
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory);
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory2);
        
        //Creating Instance of wrapper class
        CNT_TPA_RequestSubmissionForm.WrapperClass wrapperClassObj = new CNT_TPA_RequestSubmissionForm.WrapperClass();
        wrapperClassObj.dataAsset = '';
        wrapperClassObj.categoryName = '';
        wrapperClassObj.purposeName = '';
        wrapperClassObj.purposeId = '';
        wrapperClassObj.otherPurposeId = '';
        wrapperClassObj.country = '';
        wrapperClassObj.selectDes = '';
        wrapperClassObj.selectdataAssDetails = '';
        wrapperClassObj.selectdataAssforOfferingAdditionDetails = '';
        wrapperClassObj.key ='';
        wrapperClassObj.isUseDefinitionfileExist = true;
        System.debug('27.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Map to store purpose description
        Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass> selectedDescriptionMap = new Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass>();
        selectedDescriptionMap.put(tpaPurposeDescription.id, wrapperClassObj);
        
        //Map top store purposes
        Map<String,TPA_Purpose__c> purposesMap = new Map<String,TPA_Purpose__c>();
        purposesMap.put('tpaPurpose3',tpaPurpose3);
        
        //Map to store purposes named Other
        Map<String,TPA_Purpose__c> purposesOtherMap = new Map<String,TPA_Purpose__c>();
        purposesOtherMap.put('tpaPurpose4',tpaPurpose4);
        
        //Map to store purposes description
        Map<String,TPA_Purpose_Description__c> purpDescMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescMap.put('tpaPurpose3', tpaPurposeDescription3);
        
        //Map to store purposes description of Other named purposes
        Map<String,TPA_Purpose_Description__c> purpDescOtherMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescOtherMap.put('tpaPurpose4', tpaPurposeDescription4);
        
        //Set tp store data assets
        Set<TPA_Data_Asset__c> tpaDataAssetSet = new Set<TPA_Data_Asset__c>();
        tpaDataAssetSet.add(tpaDataAsset3);
        tpaDataAssetSet.add(tpaDataAsset4);
        
        //List to store secondary data assets
        List<TPA_Secondary_Data_Asset__c> tpaSecondaryDataAssetList = new List<TPA_Secondary_Data_Asset__c>();
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset3);
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset4);
        
        //Map to store data assets along with purpose id
        Map<String,set<TPA_Data_Asset__c>> mapPurposesIdWithDataAsset = new Map<String,set<TPA_Data_Asset__c>>();
        mapPurposesIdWithDataAsset.put('dataAssetMap', tpaDataAssetSet);
        
        //Map to store secondary data assets along with purpose id
        Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetsToInsert = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
        mapSecondayDataAssetsToInsert.put('dataAssetMap', tpaSecondaryDataAssetList);
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/
        System.debug('28.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        Test.StartTest();
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','c' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        
        System.debug('001.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaRequestFormController.isAuthorisedSigner = 'Yes';
        
        System.debug('002.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getPresciberLevelAttributesList();
        System.debug('003.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getAmaFreqDeliveryData();
        System.debug('004.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getAMAlistValuesData();
        System.debug('005.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getAmaPrescLvlData();
        System.debug('006.Number of Queries used in this apex code so far: ' + Limits.getQueries());
      //  tpaRequestFormController.getAmaResponseCollectionMeans();
        System.debug('007.Number of Queries used in this apex code so far: ' + Limits.getQueries());
       // tpaRequestFormController.getAmaPpdVariablesData();
        System.debug('008.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        
        
        
        tpaRequestFormController.getImsSoftwareData();
        System.debug('012.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaRequestFormController.getLoggedInCurrentUser();
        System.debug('014.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getVendorLoggedInUser();
        System.debug('015.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getObjectTpaRequestToEdit();
        System.debug('016.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getObjectExistedUsesAndAssets();
        System.debug('017.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaRequestFormController.getLanguageMap();
        System.debug('018.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestFormController.getTranslatedMap();
        System.debug('019.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        CNT_TPA_RequestSubmissionForm.language = 'en_US';
        Map<String, String> supportedLanguageMaptest = new Map<String, String>();
        supportedLanguageMaptest.put('en_US' , 'English~English_Translation__c~English');
        
        //CNT_TPA_RequestSubmissionForm.supportedLanguageMap = supportedLanguageMaptest;
        String tpaRequestJSON = JSON.serialize(tpaRequest2);
        System.debug('addrs2-----------------> ' + JSON.serialize(tpaRequest2));
        System.debug('testAddress-----------------> ' + testAddress);
        String tpaContactListJSON = JSON.serialize(tpaContactList);
        String tpaSubContractorsListJSON = JSON.serialize(tpaSubContractorsList);
        String listSavedATCJSON = JSON.serialize(listSavedATC);
        String imsTpaPurposecategoryListJSON = JSON.serialize(imsTpaPurposecategoryList);
        String SelectedDescMapJSON = JSON.serialize(selectedDescriptionMap);
        String purposesMapJSON = JSON.serialize(purposesMap);
        String purposesOtherMapJSON = JSON.serialize(purposesOtherMap);
        String purpDescMapJSON = JSON.serialize(purpDescMap);
        String purpDescOtherMapJSON = JSON.serialize(purpDescOtherMap);
        String mapPurposesIdWithDataAssetJSON = JSON.serialize(mapPurposesIdWithDataAsset);
        String mapSecondayDataAssetsToInsertJSON = JSON.serialize(mapSecondayDataAssetsToInsert);
        String addID = JSON.serialize(testAddress.Id);
        
        //Added by C.P.Pandey under ER-2654 start
        List<TPA_Use_Offerings_UI_Backup__c> useOffListToInsert = new List<TPA_Use_Offerings_UI_Backup__c>();
        TPA_Use_Offerings_UI_Backup__c useOffObjToInsert = new TPA_Use_Offerings_UI_Backup__c(Details__c = ' edited', Country__c = 'Test', GUID__c = 'Test', Offerings_Selected__c = 'Test', Use_Name_with_Id__c = 'Test', TPA_Request__c = tpaRequest.Id);
        useOffListToInsert.add(useOffObjToInsert);
      //  CNT_TPA_RequestSubmissionForm.backupUseOffering(Json.serialize(useOffListToInsert));
        System.debug('020.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        insert useOffObjToInsert;
        string useOffBackupIdsJSON = '' + useOffObjToInsert.Id;
        //Added by C.P.Pandey under ER-2654 end
        
        //Calling save request method where requestTypeSubmitted is NewRequest
        String tpaRequestDetailsJSON = '{"tpaRequest" : '+tpaRequestJSON+', "requestTypeSubmitted" : "NewRequest","processedLanguage" : "en_US", "tpaAdditionalContactList" : '+tpaContactListJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+ ', "useOffBackupIds":"' + useOffBackupIdsJSON + '"' + '}';//Added by C.P.Pandey under ER-2654
        System.assertNotEquals(null, tpaRequestDetailsJSON);
        //try{
            CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON);
        System.debug('021.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //}
        //catch(Exception e){}
        //Calling save request method where requestTypeSubmitted is ClientSubmit
        //TPA_Request__c newTpaRequest = [Select id From TPA_Request__c Where isVendorSubmitted__c = true];
        String tpaRequestJSON2 = JSON.serialize(tpaRequest);
        String tpaRequestDetailsJSON2 = '{"tpaRequest" : '+tpaRequestJSON2+', "clientAddress" : '+addID+', "requestTypeSubmitted" : "ClientSubmit","processedLanguage" : "en_US","isPublicPrivateChangeOnly" : false, "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+ ', "useOffBackupIds":"' + useOffBackupIdsJSON + '"' + '}';//Added by C.P.Pandey under ER-2654
        //try{
            CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON2);
        System.debug('022.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //}
        //catch(Exception e){}
        //Calling save request method where requestTypeSubmitted is VendorSubmit
        //String tpaRequestDetailsJSON3 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "VendorSubmit","processedLanguage" : "en_US","isPublicPrivateChangeOnly" : false, "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
        //try{
            //CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON3);
        System.debug('023.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //}
        
        tpaRequest.TPA_Request_Marked_as__c = 'Private';
        String tpaRequestJSON3 = JSON.serialize(tpaRequest);
        //String tpaRequestDetailsJSON4 = '{"tpaRequest" : '+tpaRequestJSON3+', "requestTypeSubmitted" : "InDraftRequest","processedLanguage" : "en_US","isPublicPrivateChangeOnly" : false, "tpaAdditionalContactList" : '+tpaContactListJSON+', "clientAddress" :"'+testAddress.Id+'", "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
        //CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON4);
        System.debug('024.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        String tpaRequestDetailsJSON4 = '{"tpaRequest" : '+tpaRequestJSON3+', "requestTypeSubmitted" : "NewRequest","processedLanguage" : "en_US","isPublicPrivateChangeOnly" : false, "tpaAdditionalContactList" : '+tpaContactListJSON+', "clientAddress" :"'+testAddress.Id+'", "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
        CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON4);
        
        //catch(Exception e){}
        string valTmp = CNT_TPA_RequestSubmissionForm.jsonAmaDataOffering;
        System.debug('025.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        Map<String,String> mapTmp;
        List<String> lstTmp;
        mapTmp = CNT_TPA_RequestSubmissionForm.secAssetFieldMap;
        mapTmp = CNT_TPA_RequestSubmissionForm.priAssetFieldMap;
        lstTmp = CNT_TPA_RequestSubmissionForm.approvedCountriesForRemoteAccess;
        lstTmp = CNT_TPA_RequestSubmissionForm.ApprovedCountriesForStorage;
        CNT_TPA_RequestSubmissionForm accessMultiObj = new CNT_TPA_RequestSubmissionForm();
        System.debug('026.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        valTmp = accessMultiObj.msgPrimaryBoardContent;
        valTmp = accessMultiObj.getSecDataAssetFieldMap();
        System.debug('027.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        valTmp = accessMultiObj.getPriDataAssetFieldMap();
        System.debug('028.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating instance of tpaRequestDetails class
        CNT_TPA_RequestSubmissionForm.tpaRequestDetails tpaRequestDetailsObj = new CNT_TPA_RequestSubmissionForm.tpaRequestDetails();
        System.debug('029.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequestDetailsObj.isVendorContactInvited = true;
        tpaRequestDetailsObj.invitedContact = con;
        tpaRequestDetailsObj.vendorName = 'Sunny';
        tpaRequestDetailsObj.vendorContactName = 'sunny bansal';
        object result = tpaRequestDetailsObj.GUID;
        result = tpaRequestDetailsObj.secondarypurpose;
        System.debug('030.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        result = tpaRequestDetailsObj.mapSecondayDataAssetToInsert;
        System.debug('031.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating instance of wrapperClassAssetPurpose class
        CNT_TPA_RequestSubmissionForm.wrapperClassAssetPurpose wrapperClassAssetPurposeObj = new CNT_TPA_RequestSubmissionForm.wrapperClassAssetPurpose();
        System.debug('032.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        wrapperClassAssetPurposeObj.purposeCategoryId = '123';
        wrapperClassAssetPurposeObj.useDefinitionPage = 'test use definition';
        result = wrapperClassAssetPurposeObj.Param_otherDesc;
        System.debug('033.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Creating instance of existedUsesAndAssets class
        CNT_TPA_RequestSubmissionForm.existedUsesAndAssets existedUsesAndAssetsObj = new CNT_TPA_RequestSubmissionForm.existedUsesAndAssets();
        System.debug('034.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        existedUsesAndAssetsObj.commDataAsset = '';
        
        //Creating instance of controlNumberAuthSignerDetail class
        CNT_TPA_RequestSubmissionForm.controlNumberAuthSignerDetail controlNumberAuthSignerDetailObj = new CNT_TPA_RequestSubmissionForm.controlNumberAuthSignerDetail();
        System.debug('035.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        controlNumberAuthSignerDetailObj.vendorAddress = 'Delhi';
        controlNumberAuthSignerDetailObj.vendorCity = 'Delhi';
        controlNumberAuthSignerDetailObj.vendorPostal = '110032';
        controlNumberAuthSignerDetailObj.authorizedSignerEmail = 'sunny.bansal@metacube.com';
        controlNumberAuthSignerDetailObj.authorizedSignerRequired = 'yes';
        
        CNT_TPA_RequestSubmissionForm.getAcknowledgementDateTime();
        System.debug('036.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        List<String> lsitImsDataAssets = new List<String>();
        lsitImsDataAssets.add(imsDataAsset.Id);
        CNT_TPA_RequestSubmissionForm.getOfferingsNotificationsList(lsitImsDataAssets);
        System.debug('037.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        Test.StopTest();
        //}
    }
    
    private static testmethod void validateControlNumberAuthSignerTest() {
        
        
        //Creating TPA Account
        Account acc = new Account(Name = 'the sunny', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', BillingStreet = 'Delhi', BillingCity = 'Delhi', BillingCountry = 'India', BillingPostalCode = '110032', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert acc;
        insert new Address__c( name = acc.name,
                                          recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId,
                                          Is_TPA_Account__c = true,
                                          Account__c = acc.Id,
                                          Vendor_Registration_Number__c = 122,
                                          Industry__c = 'Biotech',
                                          Vendor_Tier__c = 'Y',
                                          Is_Payment_Risk__c = true,
                                          Street__c = 'Delhi',
                                          City__c = 'Delhi',
                                          State__c = 'Delhi',
                                          Country__c = 'India',
                                          PostalCode__c = '110032',
                                          TPA_Local_Address_Required__c = false  
                                        );
        
        Address__c addObj = new Address__c( name = 'Sunny',
                                          recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId,
                                          Is_TPA_Account__c = true,
                                          Account__c = acc.Id,
                                          Vendor_Registration_Number__c = 124,
                                          Industry__c = 'Biotech',
                                          Vendor_Tier__c = 'Y',
                                          Is_Payment_Risk__c = true,
                                          Street__c = 'Delhi',
                                          City__c = 'Delhi',
                                          Country__c = 'India',
                                          PostalCode__c = '110032',
                                          TPA_Local_Address_Required__c = false  
                                        );
        insert addObj;
        insert new Address__c( name = 'Sunny',
                                          recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId,
                                          Is_TPA_Account__c = true,
                                          Account__c = acc.Id,
                                          Vendor_Registration_Number__c = 123,
                                          Industry__c = 'Biotech',
                                          Vendor_Tier__c = 'Y',
                                          Is_Payment_Risk__c = true,
                                          Street__c = 'Delhi',
                                          City__c = 'Delhi',
                                          Country__c = 'India',
                                          PostalCode__c = '110032',
                                          TPA_Local_Address_Required__c = false  
                                        );
        insert new TPA_Country_Codes__c(name = 'India', Country_Possible_Codes__c = 'India', Code_Type__c = 'C');
        insert new TPA_Country_Codes__c(name = 'Delhi', Country_Possible_Codes__c = 'Delhi', Code_Type__c = 'S');
        Account acc2 =  [select id from account where Name = 'Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        //Creating Contact1
        Contact con2 = new Contact(FirstName = 'TestFirstName1', LastName = 'Test Contact1', Email = 'sunny1.bansal@metacube.com');
        insert con2;
        
        //Creating TPA request
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                       Client_Contact_Territory__c = 'United States', ClientContact__c = con.id);
        insert tpaRequest;
        
        //Creating TPA request
        TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                        Client_Contact_Territory__c = 'United States', isVendorSubmitted__c = true, ClientContact__c = con.id,
                                                        Is_Potential_Vendor_Case__c = true, Data_Asset_List__c = 'AAN',
                                                        Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                        Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test');
        
        //Creating TP Processor
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'sunny.bansal@metacube.com'); //Region__c = 'United States',  sunny change123
        insert tpProcessor;
        
        //Creating TPA_Region_Country
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;
        
        TPA_Contact__c tpaContact = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        //insert tpaContact;
        
        TPA_Contact__c tpaContact2 = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        
        //Fetching Record type id for ATC
        RecordType recordType = [Select id From RecordType Where name = 'ATC'];
        
        //Fetching Record type id for USC
        RecordType recordType2 = [Select id From RecordType Where name = 'USC'];
        
        //Creating Therapautic Area for ATC
        ATC__c tpaATC = new ATC__c(Active__c = true, ATC_Code__c = 'A011', Name_Eng__c = 'A011', RecordTypeId = recordType.id, Level__c = 2);
        insert tpaATC;
        
        //Creating Therapautic Area for USC
        ATC__c tpaATC2 = new ATC__c(Active__c = true, ATC_Code__c = '0100', Name_Eng__c = '0100', RecordTypeId = recordType2.id);
        insert tpaATC2;
        
        //Creating Therapautic Area for USC
        ATC__c tpaATC3 = new ATC__c(Active__c = true, ATC_Code__c = '01000', Name_Eng__c = '01000', RecordTypeId = recordType2.id);
        insert tpaATC3;
        
        TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c(TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id);
        insert tpaRequestATC;
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        insert imsTpaPurpose;
        
        IMS_TPA_Purpose__c imsTpaPurpose2 = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'Other', Purpose_Details__c = 'test detail2',
                                                                   Is_Active__c = true);
        insert imsTpaPurpose2;
        
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        insert tpaPurposeCategory;
        
        TPA_Purpose_Category__c tpaPurposeCategory2 = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        insert tpaPurposeCategory2;
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        insert tpaPurpose;
        
        TPA_Purpose__c tpaPurpose2 = new TPA_Purpose__c(Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        insert tpaPurpose2;
        
        TPA_Purpose__c tpaPurpose3 = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        
        TPA_Purpose__c tpaPurpose4 = new TPA_Purpose__c(Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = 'onekey data - United States' , BU__c = 'United States' , Geo_Level__c = 'Sub-National', Is_Active__c = True, IMS_Legal_Entity__c='IQVIA AG');
        insert imsDataAsset;
        new CNT_TPA_RequestSubmissionForm().getProposalTreeData();
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        insert tpaDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset2 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        insert tpaDataAsset2;
        
        TPA_Data_Asset__c tpaDataAsset3 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        //insert tpaDataAsset3;
        
        TPA_Data_Asset__c tpaDataAsset4 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        //insert tpaDataAsset4;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true, Is_Active__c = True, Secondary_Asset_Name__c = 'sec_test');
        insert imsSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset2;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset3 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset4 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id);
        insert imsTpaPurposeCategory;
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        insert imsTpaPurposeCategory2;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true);
        insert imsTpaPurposeDescription;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id,
                                                                                                      Is_Active__c = true);
        insert imsTpaPurposeDescription2;
        
        TPA_Purpose_Description__c tpaPurposeDescription = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                          Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        insert tpaPurposeDescription;
        
        TPA_Purpose_Description__c tpaPurposeDescription2 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        insert tpaPurposeDescription2;
        
        TPA_Purpose_Description__c tpaPurposeDescription3 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                           Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        
        TPA_Purpose_Description__c tpaPurposeDescription4 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        
        //Inserting country in custom setting TPA_Country_Codes__c
        TPA_Country_Codes__c tpaCountryCode = new TPA_Country_Codes__c(name = 'India', Country_Possible_Codes__c = 'IN', Code_Type__c = 'C');
        insert tpaCountryCode;
        
        //Inserting state in custom setting TPA_Country_Codes__c
        TPA_Country_Codes__c tpaCountryCode2 = new TPA_Country_Codes__c(name = 'Delhi', Country_Possible_Codes__c = 'DL', Code_Type__c = 'S');
        insert tpaCountryCode2;
        
        TPA_AMA_Picklist__c amaPicklist = new TPA_AMA_Picklist__c(Name = 'AMAValue123', Picklist_value__c = 'Telemarketing');
        insert amaPicklist;
        
        //List to store TPA Contact
        List<TPA_Contact__c> tpaContactList= new List<TPA_Contact__c>();
        tpaContactList.add(tpaContact);
        
        //List to store TPA SubContractor
        List<TPA_Contact__c> tpaSubContractorsList= new List<TPA_Contact__c>();
        tpaSubContractorsList.add(tpaContact2);
        
        //List to store ATC
        List<ATC__c> listSavedATC = new List<ATC__c>();
        listSavedATC.add(tpaATC);
        
        //List to store IMS TPA Purpose Description
        List<IMS_TPA_Purpose_Category__c> imsTpaPurposecategoryList = new List<IMS_TPA_Purpose_Category__c>();
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory);
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory2);
        
        //Creating Instance of wrapper class
        CNT_TPA_RequestSubmissionForm.WrapperClass wrapperClassObj = new CNT_TPA_RequestSubmissionForm.WrapperClass();
        wrapperClassObj.dataAsset = '';
        wrapperClassObj.categoryName = '';
        wrapperClassObj.purposeName = '';
        wrapperClassObj.purposeId = '';
        wrapperClassObj.otherPurposeId = '';
        wrapperClassObj.country = '';
        wrapperClassObj.selectDes = '';
        wrapperClassObj.selectdataAssDetails = '';
        wrapperClassObj.selectdataAssforOfferingAdditionDetails = '';
        wrapperClassObj.key ='';
        wrapperClassObj.isUseDefinitionfileExist = true;
        
        //Map to store purpose description
        Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass> selectedDescriptionMap = new Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass>();
        selectedDescriptionMap.put(tpaPurposeDescription.id, wrapperClassObj);
        
        //Map top store purposes
        Map<String,TPA_Purpose__c> purposesMap = new Map<String,TPA_Purpose__c>();
        purposesMap.put('tpaPurpose3',tpaPurpose3);
        
        //Map to store purposes named Other
        Map<String,TPA_Purpose__c> purposesOtherMap = new Map<String,TPA_Purpose__c>();
        purposesOtherMap.put('tpaPurpose4',tpaPurpose4);
        
        //Map to store purposes description
        Map<String,TPA_Purpose_Description__c> purpDescMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescMap.put('tpaPurpose3', tpaPurposeDescription3);
        
        //Map to store purposes description of Other named purposes
        Map<String,TPA_Purpose_Description__c> purpDescOtherMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescOtherMap.put('tpaPurpose4', tpaPurposeDescription4);
        
        //Set tp store data assets
        Set<TPA_Data_Asset__c> tpaDataAssetSet = new Set<TPA_Data_Asset__c>();
        tpaDataAssetSet.add(tpaDataAsset3);
        tpaDataAssetSet.add(tpaDataAsset4);
        
        //List to store secondary data assets
        List<TPA_Secondary_Data_Asset__c> tpaSecondaryDataAssetList = new List<TPA_Secondary_Data_Asset__c>();
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset3);
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset4);
        
        //Map to store data assets along with purpose id
        Map<String,set<TPA_Data_Asset__c>> mapPurposesIdWithDataAsset = new Map<String,set<TPA_Data_Asset__c>>();
        mapPurposesIdWithDataAsset.put('dataAssetMap', tpaDataAssetSet);
        
        //Map to store secondary data assets along with purpose id
        Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetsToInsert = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
        mapSecondayDataAssetsToInsert.put('dataAssetMap', tpaSecondaryDataAssetList);
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/
        
        Test.StartTest();
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','c' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        
        //Creating instance of controlNumberAuthSignerDetail class
        CNT_TPA_RequestSubmissionForm.controlNumberAuthSignerDetail controlNumberAuthSignerDetailObj = new CNT_TPA_RequestSubmissionForm.controlNumberAuthSignerDetail();
        controlNumberAuthSignerDetailObj.vendorAddress = 'Delhi';
        controlNumberAuthSignerDetailObj.vendorCity = 'Delhi';
        controlNumberAuthSignerDetailObj.vendorPostal = '110032';
        controlNumberAuthSignerDetailObj.authorizedSignerEmail = 'sunny.bansal@metacube.com';
        controlNumberAuthSignerDetailObj.authorizedSignerRequired = 'yes';
        
        //Calling controlNumberAuthSignerDetailJSON request method having incorrect Vendor registration number
        String controlNumberAuthSignerDetailJSON = '{"vendorRegistrationNumber" : "0001", "vendorName" : "test tpa", "vendorAddress" : "Delhi", "vendorCountry" : "India", "vendorState" : "Delhi", "vendorCity" : "Delhi", "vendorPostal" : "110032", "contactEmail" : "sunny.bansal@metacube.com", "authorizedSignerEmail" : "sunny@test.com", "reqModeType" : "RegistrationNumberCheck", "authorizedSignerRequired" : "No"}';
        String returnValue = CNT_TPA_RequestSubmissionForm.validateControlNumberAuthSigner(controlNumberAuthSignerDetailJSON);
        CNT_TPA_RequestSubmissionForm.getAccountOnDomain(JSON.serialize('India'), JSON.serialize('test tpa'));
        CNT_TPA_RequestSubmissionForm.getAccountOnDomain(JSON.serialize('India'), JSON.serialize(''));
        System.assertNotEquals(null, returnValue);
        
        //Calling controlNumberAuthSignerDetailJSON request method for RegistrationNumberCheck when Vendor not verified
        controlNumberAuthSignerDetailJSON = '{"vendorRegistrationNumber" : "123", "vendorName" : "the sunny", "vendorAddress" : "Delhi", "vendorCountry" : "India", "vendorState" : "--None--", "vendorCity" : "Delhi", "vendorPostal" : "110032", "contactEmail" : "sunny.bansal@metacube.com", "authorizedSignerEmail" : "sunny@test.com", "reqModeType" : "RegistrationNumberCheck", "authorizedSignerRequired" : "No"}';
        system.debug('vnBeforeCall::');
        returnValue = CNT_TPA_RequestSubmissionForm.validateControlNumberAuthSigner(controlNumberAuthSignerDetailJSON);
        //System.assertNotEquals(null, returnValue);
        
        //Calling controlNumberAuthSignerDetailJSON request method for RegistrationNumberCheck when Vendor Verfified
        controlNumberAuthSignerDetailJSON = '{"vendorRegistrationNumber" : "123", "vendorName" : "the Test Acc", "vendorAddress" : "Delhi", "vendorCountry" : "India", "vendorState" : "Delhi", "vendorCity" : "Delhi", "vendorPostal" : "110032", "contactEmail" : "sunny.bansal@metacube.com", "authorizedSignerEmail" : "sunny@test.com", "reqModeType" : "RegistrationNumberCheck", "authorizedSignerRequired" : "No"}';
        returnValue = CNT_TPA_RequestSubmissionForm.validateControlNumberAuthSigner(controlNumberAuthSignerDetailJSON);
        System.assertNotEquals(null, returnValue);
        
        //Calling controlNumberAuthSignerDetailJSON request method for RegistrationNumberCheck
        controlNumberAuthSignerDetailJSON = '{"vendorRegistrationNumber" : "456", "vendorName" : "the", "vendorAddress" : "Delhi", "vendorCountry" : "India", "vendorState" : "Delhi", "vendorCity" : "Delhi", "vendorPostal" : "110032", "contactEmail" : "sunny.bansal@metacube.com", "authorizedSignerEmail" : "sunny@test.com", "reqModeType" : "RegistrationNumberCheck", "authorizedSignerRequired" : "No"}';
        returnValue = CNT_TPA_RequestSubmissionForm.validateControlNumberAuthSigner(controlNumberAuthSignerDetailJSON);
        System.assertNotEquals(null, returnValue);
        
        //Calling controlNumberAuthSignerDetailJSON request method for VendorAccountCheck
        controlNumberAuthSignerDetailJSON = '{"vendorRegistrationNumber" : "123", "vendorName" : "the Test Acc", "vendorAddress" : "Delhi", "vendorCountry" : "India", "vendorState" : "Delhi", "vendorCity" : "Delhi", "vendorPostal" : "110032", "contactEmail" : "sunny.bansal@metacube.com", "authorizedSignerEmail" : "sunny@test.com", "reqModeType" : "VendorAccountCheck", "authorizedSignerRequired" : "No"}';
        returnValue = CNT_TPA_RequestSubmissionForm.validateControlNumberAuthSigner(controlNumberAuthSignerDetailJSON);
        System.assertNotEquals(null, returnValue);
        
        //Calling controlNumberAuthSignerDetailJSON request method for VendorAccountCheck
        controlNumberAuthSignerDetailJSON = '{"vendorRegistrationNumber" : "123", "vendorName" : "Sunny", "vendorAddress" : "Delhi", "vendorCountry" : "India", "vendorState" : "--None--", "vendorCity" : "Delhi", "vendorPostal" : "110032", "contactEmail" : "sunny.bansal@metacube.com", "authorizedSignerEmail" : "sunny@test.com", "reqModeType" : "VendorAccountCheck", "authorizedSignerRequired" : "No"}';
        returnValue = CNT_TPA_RequestSubmissionForm.validateControlNumberAuthSigner(controlNumberAuthSignerDetailJSON);
        delete addObj;
        returnValue = CNT_TPA_RequestSubmissionForm.validateControlNumberAuthSigner(controlNumberAuthSignerDetailJSON);
        //System.assertNotEquals(null, returnValue);
        
        //Calling controlNumberAuthSignerDetailJSON request method for VendorAccountCheck when no vendor name is provided
        controlNumberAuthSignerDetailJSON = '{"vendorRegistrationNumber" : "123", "vendorName" : "", "vendorAddress" : "Delhi", "vendorCountry" : "India", "vendorState" : "--None--", "vendorCity" : "Delhi", "vendorPostal" : "110032", "contactEmail" : "sunny.bansal@metacube.com", "authorizedSignerEmail" : "sunny@test.com", "reqModeType" : "VendorAccountCheck", "authorizedSignerRequired" : "No"}';
        returnValue = CNT_TPA_RequestSubmissionForm.validateControlNumberAuthSigner(controlNumberAuthSignerDetailJSON);
        System.assertNotEquals(null, returnValue);
        
        //Calling controlNumberAuthSignerDetailJSON request method for
        controlNumberAuthSignerDetailJSON = '{"vendorRegistrationNumber" : "123", "vendorName" : "test Sunny", "vendorAddress" : "Delhi", "vendorCountry" : "India", "vendorState" : "Delhi", "vendorCity" : "Delhi", "vendorPostal" : "110032", "contactEmail" : "sunny.bansal@metacube.com", "authorizedSignerEmail" : "sunny@test.com", "reqModeType" : "AuthorizedSignerCheck", "authorizedSignerRequired" : "No"}';
        returnValue = CNT_TPA_RequestSubmissionForm.validateControlNumberAuthSigner(controlNumberAuthSignerDetailJSON);
        System.assertNotEquals(null, returnValue);
        new CNT_TPA_RequestSubmissionForm().getProposalTreeData();
        Test.StopTest();
        
    }
    
    private static testmethod void therapeuticFunctionalityTest() {
        
        
        //Creating TPA Account
        Account acc = new Account(name = 'the Test Acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'Test', BillingCity = 'Test', BillingCountry = 'India',BillingState = 'Delhi', BillingPostalCode = '123', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert acc;
        
        Account acc2 =  [select id from account where Name = 'Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        //Creating Contact
        Contact con2 = new Contact(FirstName = 'TestFirstName1', LastName = 'Test Contact1', Email = 'sunny1.bansal@metacube.com');
        insert con2;
        
        //Creating TPA request
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                       Client_Contact_Territory__c = 'United States', ClientContact__c = con.id);
        insert tpaRequest;
        
        //Creating TPA request
        TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                        Client_Contact_Territory__c = 'United States', isVendorSubmitted__c = true, ClientContact__c = con.id,
                                                        Is_Potential_Vendor_Case__c = true, Data_Asset_List__c = 'AAN',
                                                        Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                        Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test');
        
        //Fetching Record type id for ATC
        RecordType recordType = [Select id From RecordType Where name = 'ATC'];
        
        //Fetching Record type id for USC
        RecordType recordType2 = [Select id From RecordType Where name = 'USC'];
        
        //Creating Therapautic Area for ATC
        ATC__c tpaATC = new ATC__c(Active__c = true, ATC_Code__c = 'A011', Name_Eng__c = 'A011', RecordTypeId = recordType.id, Level__c = 2);
        insert tpaATC;
        
        //Creating Therapautic Area for USC
        ATC__c tpaATC2 = new ATC__c(Active__c = true, ATC_Code__c = '0100', Name_Eng__c = '0100', RecordTypeId = recordType2.id);
        insert tpaATC2;
        
        //Creating Therapautic Area for USC
        ATC__c tpaATC3 = new ATC__c(Active__c = true, ATC_Code__c = '01000', Name_Eng__c = '01000', RecordTypeId = recordType2.id);
        insert tpaATC3;
        
        TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c(TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id);
        insert tpaRequestATC;
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/
        
        //List to store ATC
        List<ATC__c> listSavedATC = new List<ATC__c>();
        listSavedATC.add(tpaATC);
        
        Test.StartTest();
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','c' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        
        //Calling getSearchRecords method for ATC Code
        /*List<CNT_TPA_RequestSubmissionForm.ATCSearchWrapper> lstSearchRecord = CNT_TPA_RequestSubmissionForm.getSearchRecords('\"A0\"', '\"ATC\"');
System.assertNotEquals(null, lstSearchRecord);

//Calling getSearchRecords method for no search text
lstSearchRecord = CNT_TPA_RequestSubmissionForm.getSearchRecords('\"\"', '\"ATC\"');
System.assertNotEquals(null, lstSearchRecord);

//Calling getSearchRecords method for USC Code
lstSearchRecord = CNT_TPA_RequestSubmissionForm.getSearchRecords('\"01\"', '\"USC\"');
System.assertNotEquals(null, lstSearchRecord);
Test.StopTest();*/
    }
    
    private static testmethod void requestValidateOnLoadForVendorTest() {
        
        
        
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        //Creating TPA request
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                       Client_Contact_Territory__c = 'United States', ClientContact__c = con.id, isVendorSubmitted__c = true);
        insert tpaRequest;
        
        //Creating TPA request
        TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                        Client_Contact_Territory__c = 'United States', isVendorSubmitted__c = true, ClientContact__c = con.id,
                                                        TPA_Request_Marked_as__c = 'Public', Data_Asset_List__c = 'AAN',
                                                        Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                        Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test');
        
        //Creating TP Processor
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(Region__c = 'United States', TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'sunny.bansal@metacube.com');
        insert tpProcessor;
        
        //Creating TPA_Region_Country
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;
        
        TPA_Contact__c tpaContact = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        //insert tpaContact;
        
        TPA_Contact__c tpaContact2 = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        
        ATC__c tpaATC = new ATC__c(Active__c = true, ATC_Code__c = '123', Name_Eng__c = 'Test ATC');
        insert tpaATC;
        
        TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c(TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id);
        insert tpaRequestATC;
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        insert imsTpaPurpose;
        
        IMS_TPA_Purpose__c imsTpaPurpose2 = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'Other', Purpose_Details__c = 'test detail2',
                                                                   Is_Active__c = true);
        insert imsTpaPurpose2;
        
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        insert tpaPurposeCategory;
        
        TPA_Purpose_Category__c tpaPurposeCategory2 = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        insert tpaPurposeCategory2;
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        insert tpaPurpose;
        
        TPA_Purpose__c tpaPurpose2 = new TPA_Purpose__c(Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        insert tpaPurpose2;
        
        TPA_Purpose__c tpaPurpose3 = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        
        TPA_Purpose__c tpaPurpose4 = new TPA_Purpose__c(Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        insert tpaDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset2 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        insert tpaDataAsset2;
        
        TPA_Data_Asset__c tpaDataAsset3 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        //insert tpaDataAsset3;
        
        TPA_Data_Asset__c tpaDataAsset4 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        //insert tpaDataAsset4;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset2;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset3 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset4 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id);
        insert imsTpaPurposeCategory;
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        insert imsTpaPurposeCategory2;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true);
        insert imsTpaPurposeDescription;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id,
                                                                                                      Is_Active__c = true);
        insert imsTpaPurposeDescription2;
        
        TPA_Purpose_Description__c tpaPurposeDescription = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                          Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        insert tpaPurposeDescription;
        
        TPA_Purpose_Description__c tpaPurposeDescription2 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        insert tpaPurposeDescription2;
        
        TPA_Purpose_Description__c tpaPurposeDescription3 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                           Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        
        TPA_Purpose_Description__c tpaPurposeDescription4 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/
        
        //List to store TPA Contact
        List<TPA_Contact__c> tpaContactList= new List<TPA_Contact__c>();
        tpaContactList.add(tpaContact);
        
        //List to store TPA SubContractor
        List<TPA_Contact__c> tpaSubContractorsList= new List<TPA_Contact__c>();
        tpaSubContractorsList.add(tpaContact2);
        
        //List to store ATC
        List<ATC__c> listSavedATC = new List<ATC__c>();
        listSavedATC.add(tpaATC);
        
        //List to store IMS TPA Purpose Description
        List<IMS_TPA_Purpose_Category__c> imsTpaPurposecategoryList = new List<IMS_TPA_Purpose_Category__c>();
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory);
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory2);
        
        //Creating Instance of wrapper class
        CNT_TPA_RequestSubmissionForm.WrapperClass wrapperClassObj = new CNT_TPA_RequestSubmissionForm.WrapperClass();
        
        //Map to store purpose description
        Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass> selectedDescriptionMap = new Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass>();
        selectedDescriptionMap.put(tpaPurposeDescription.id, wrapperClassObj);
        
        //Map top store purposes
        Map<String,TPA_Purpose__c> purposesMap = new Map<String,TPA_Purpose__c>();
        purposesMap.put('tpaPurpose3',tpaPurpose3);
        
        //Map to store purposes named Other
        Map<String,TPA_Purpose__c> purposesOtherMap = new Map<String,TPA_Purpose__c>();
        purposesOtherMap.put('tpaPurpose4',tpaPurpose4);
        
        //Map to store purposes description
        Map<String,TPA_Purpose_Description__c> purpDescMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescMap.put('tpaPurpose3', tpaPurposeDescription3);
        
        //Map to store purposes description of Other named purposes
        Map<String,TPA_Purpose_Description__c> purpDescOtherMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescOtherMap.put('tpaPurpose4', tpaPurposeDescription4);
        
        //Set tp store data assets
        Set<TPA_Data_Asset__c> tpaDataAssetSet = new Set<TPA_Data_Asset__c>();
        tpaDataAssetSet.add(tpaDataAsset3);
        tpaDataAssetSet.add(tpaDataAsset4);
        
        //List to store secondary data assets
        List<TPA_Secondary_Data_Asset__c> tpaSecondaryDataAssetList = new List<TPA_Secondary_Data_Asset__c>();
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset3);
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset4);
        
        //Map to store data assets along with purpose id
        Map<String,set<TPA_Data_Asset__c>> mapPurposesIdWithDataAsset = new Map<String,set<TPA_Data_Asset__c>>();
        mapPurposesIdWithDataAsset.put('dataAssetMap', tpaDataAssetSet);
        
        //Map to store secondary data assets along with purpose id
        Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetsToInsert = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
        mapSecondayDataAssetsToInsert.put('dataAssetMap', tpaSecondaryDataAssetList);
        
        Test.StartTest();
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','v' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        
        tpaRequestFormController.getAmaFreqDeliveryData();
        tpaRequestFormController.getAMAlistValuesData();
        tpaRequestFormController.getAmaPrescLvlData();
     //   tpaRequestFormController.getAmaResponseCollectionMeans();
       // tpaRequestFormController.getAmaPpdVariablesData();
        
        
        
        tpaRequestFormController.getImsSoftwareData();
        
        tpaRequestFormController.getLoggedInCurrentUser();
        tpaRequestFormController.getVendorLoggedInUser();
        tpaRequestFormController.getObjectTpaRequestToEdit();
        tpaRequestFormController.getObjectExistedUsesAndAssets();
        //tpaRequestFormController.getTherapeuticAreaList();
        
        
        tpaRequestFormController.getCountryList();
        
        tpaRequestFormController.getAMAlistValuesDataMap();
      //  tpaRequestFormController.getAmaResponseCollectionMeansMap();
      //  tpaRequestFormController.getAmaPpdVariablesMap();
        /*insert new List<TPA_AMA_Market_Research_Attributes_List__c>{new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA', AMA_Market_Research_Attributes__c = 'Test'),
            new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA1', AMA_Market_Research_Attributes__c = 'Test1'),
            new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA2', AMA_Market_Research_Attributes__c = 'Test2'),
            new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA3', AMA_Market_Research_Attributes__c = 'Test3')};
                tpaRequestFormController.getAMAMRAttributesMap();*/
      //  tpaRequestFormController.getAmaDMAttribuesMap();
        tpaRequestFormController.getDdtFreqDeliveryData();
        //tpaRequestFormController.getAmaMRAttributesList();
       // tpaRequestFormController.getAmaDMAttributesList();
        
        String tpaRequestJSON = JSON.serialize(tpaRequest2);
        String tpaContactListJSON = JSON.serialize(tpaContactList);
        String tpaSubContractorsListJSON = JSON.serialize(tpaSubContractorsList);
        String listSavedATCJSON = JSON.serialize(listSavedATC);
        String imsTpaPurposecategoryListJSON = JSON.serialize(imsTpaPurposecategoryList);
        String SelectedDescMapJSON = JSON.serialize(selectedDescriptionMap);
        String purposesMapJSON = JSON.serialize(purposesMap);
        String purposesOtherMapJSON = JSON.serialize(purposesOtherMap);
        String purpDescMapJSON = JSON.serialize(purpDescMap);
        String purpDescOtherMapJSON = JSON.serialize(purpDescOtherMap);
        String mapPurposesIdWithDataAssetJSON = JSON.serialize(mapPurposesIdWithDataAsset);
        String mapSecondayDataAssetsToInsertJSON = JSON.serialize(mapSecondayDataAssetsToInsert);
        
        //Added by C.P.Pandey under ER-2654 start
        List<TPA_Use_Offerings_UI_Backup__c> useOffListToInsert = new List<TPA_Use_Offerings_UI_Backup__c>();
        TPA_Use_Offerings_UI_Backup__c useOffObjToInsert = new TPA_Use_Offerings_UI_Backup__c(Details__c = ' edited', Country__c = 'Test', GUID__c = 'Test', Offerings_Selected__c = 'Test', Use_Name_with_Id__c = 'Test', TPA_Request__c = tpaRequest.Id);
        useOffListToInsert.add(useOffObjToInsert);
        //CNT_TPA_RequestSubmissionForm.backupUseOffering(Json.serialize(useOffListToInsert));
        insert useOffObjToInsert;
        string useOffBackupIdsJSON = '' + useOffObjToInsert.Id;
        //Added by C.P.Pandey under ER-2654 end
        
        //Calling save request method where requestTypeSubmitted is NewRequest
        String tpaRequestDetailsJSON = '{"tpaRequest" : '+tpaRequestJSON+', "requestTypeSubmitted" : "NewRequest", "tpaAdditionalContactList" : '+tpaContactListJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+', "isVendorContactInvited" : true, "vendorName" : "Sunny", "vendorContactName" : "Bansal", "invitedContact" : '+con.id+'}';
        String returnValue;
        try{
            returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON);
            System.assertNotEquals(null, returnValue);}
        catch(Exception e){}
        
        
        //Calling save request method where requestTypeSubmitted is ClientSubmit
        tpaRequest.Secondary_Location_Required__c = true;
        tpaRequest.Vendor_Website__c = 'www.test.com';
        tpaRequest.Vendor_Phone__c = 'test';
        String tpaRequestJSON2 = JSON.serialize(tpaRequest);
        String tpaRequestDetailsJSON2 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "ClientSubmit", "tpaAdditionalContactList" : '+tpaContactListJSON+', "listSaved" : '+listSavedATCJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+ ', "useOffBackupIds":"' + useOffBackupIdsJSON + '"' + '}';//Added by C.P.Pandey under ER-2654
        try{
            returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON2);
            //System.assertNotEquals(null, returnValue);
        }
        catch(Exception e){}
        //Calling save request method where requestTypeSubmitted is VendorSubmit
        String tpaRequestDetailsJSON3 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "VendorSubmit", "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
        try{
            returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON3);
            //System.assertNotEquals(null, returnValue);
        }
        catch(Exception e){}
        
        CNT_TPA_RequestSubmissionForm.tpaRequestDetails tpaReqDetails = (CNT_TPA_RequestSubmissionForm.tpaRequestDetails)JSON.deserialize(tpaRequestDetailsJSON2, CNT_TPA_RequestSubmissionForm.tpaRequestDetails.class);
        tpaReqDetails.tpaRequest.Data_Access_Start_Date__c = Date.today();
        tpaReqDetails.tpaRequest.Data_Access_End_Date__c = Date.today() + 1;
        tpaReqDetails.tpaRequest.Data_Period_Start_Date__c = Date.today() - 5;
        tpaReqDetails.tpaRequest.Data_Period_End_Date__c = Date.today();
        tpaReqDetails.tpaRequest.Frequency_Of_Delivery__c = 'Other';
        tpaReqDetails.tpaRequest.AMA_USPrescriberData__c = 'Yes';
        tpaReqDetails.tpaRequest.AMA_Market_Research_Attributes__c = 'test';
        tpaReqDetails.tpaRequest.AMA_Dist_ana_Mail_Atrr_For_Template__c = 'test';
        tpaReqDetails.tpaRequest.FrequencyOfDeliveryToSP_Other__c = 'Other';
        CNT_TPA_RequestSubmissionForm.getRequestBackup(tpaReqDetails, 'Client');
        tpaReqDetails.requestTypeSubmitted = 'InDraftRequest';
        CNT_TPA_RequestSubmissionForm.updateClientCopies(tpaReqDetails);
        String tpaRequestDetailsJSON4 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "VendorSubmit", "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "No", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
        tpaReqDetails = (CNT_TPA_RequestSubmissionForm.tpaRequestDetails)JSON.deserialize(tpaRequestDetailsJSON4, CNT_TPA_RequestSubmissionForm.tpaRequestDetails.class);
        tpaReqDetails.tpaRequest.Copy_Additional_Vendor_Contacts__c = 'Yes';
        tpaReqDetails.tpaRequest.IMS_Data_Country_Location_Values__c = 'Other';
        tpaReqDetails.tpaRequest.Employee_Accessing_Data_Location__c = 'Other';
        tpaReqDetails.tpaRequest.AMA_HowResponseDataCollected__c = 'Other';
        tpaReqDetails.tpaRequest.AMA_RepDataCollectedOtherWay__c = 'Other';
        tpaReqDetails.tpaAdditionalVendorContactList = new List<TPA_Contact__C>{new TPA_Contact__C (Email__c = 'test@test.com')};
        CNT_TPA_RequestSubmissionForm.getRequestBackup(tpaReqDetails, 'Vendor');
       // CNT_TPA_RequestSubmissionForm.currentLoggedInUser = new User(Id = userinfo.getUserId());
        user objUsr = CNT_TPA_RequestSubmissionForm.currentLoggedInUser;
        CNT_TPA_RequestSubmissionForm.getContactAddressCrowalk = 'test';
        string rslt = CNT_TPA_RequestSubmissionForm.getContactAddressCrowalk;
        insert new TPA_Country_Codes__c(name = 'USA', Country_Possible_Codes__c = 'USA', Code_Type__c = 'C');
        new CNT_TPA_RequestSubmissionForm().setClientCountryDetails('USA');
        Test.StopTest();
    }
    
    private static testmethod void requestValidateOnLoadForTPAProcessorTest() {
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Address__c addrs = [select id from Address__c where Name = 'TPA Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        //Getting profile id for TP Processor Profile
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP%' Limit 1];//Updated by Babita Dadarwal under ER-3552
        
        //Creating User with TP Processor profile
        User user = new User(Alias = 'standt', Email='standarduser123@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',
                             ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@testing123.com',
                             TimeZoneSidKey='America/Los_Angeles', ContactId = con.id);
        
        
        //  System.runAs(user) {
        Test.StartTest();
        
        //Creating TPA request
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true, Service_Provider_Address__c = addrs.Id,
                                                       Client_Contact_Territory__c = 'United States', Data_Asset_List__c = 'AAN',
                                                       Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                       Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test',
                                                       ClientContact__c = con.id, Request_Status__c = 'Awaiting Vendor Signature', Client_Language__c = 'English', 
                                                       Secondary_Client_Contact_Territory__c = 'United States');
        insert tpaRequest;
        
        //Creating TPA request
        TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                        Client_Contact_Territory__c = 'United States', isVendorSubmitted__c = true, ClientContact__c = con.id);
        
        //Creating TP Processor
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(Region__c = 'United States', TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'sunny.bansal@metacube.com');
        insert tpProcessor;
        
        //Creating TPA_Region_Country
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;
        
        TPA_Contact__c tpaContact = new TPA_Contact__c(Type__c = 'SubContractor Contact'); //TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id,
        //insert tpaContact;
        
        TPA_Contact__c tpaContact2 = new TPA_Contact__c(Type__c = 'SubContractor Contact');
        
        ATC__c tpaATC = new ATC__c(Active__c = true, ATC_Code__c = '123', Name_Eng__c = 'Test ATC');
        insert tpaATC;
        
        TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c(TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id);
        insert tpaRequestATC;
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        insert imsTpaPurpose;
        
        IMS_TPA_Purpose__c imsTpaPurpose2 = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'Other', Purpose_Details__c = 'test detail2',
                                                                   Is_Active__c = true);
        insert imsTpaPurpose2;
        
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        insert tpaPurposeCategory;
        
        TPA_Purpose_Category__c tpaPurposeCategory2 = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        insert tpaPurposeCategory2;
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        insert tpaPurpose;
        
        TPA_Purpose__c tpaPurpose2 = new TPA_Purpose__c(Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        insert tpaPurpose2;
        
        TPA_Purpose__c tpaPurpose3 = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        
        TPA_Purpose__c tpaPurpose4 = new TPA_Purpose__c(Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset;
        
        IMS_Data_Asset__c imsDataAsset2 = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset2;
        IMS_Data_Asset__c imsDataAsset3 = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset3;
        IMS_Data_Asset__c imsDataAsset4 = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset4;
        IMS_Data_Asset__c imsDataAsset5 = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset5;
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        insert tpaDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset2 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset2.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        insert tpaDataAsset2;
        
        TPA_Data_Asset__c tpaDataAsset3 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        
        TPA_Data_Asset__c tpaDataAsset4 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset4.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        insert tpaDataAsset4 ;
        TPA_Data_Asset__c tpaDataAsset5 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset5.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        
        insert tpaDataAsset5 ;
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset2 = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset2.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset2;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset2.id);
        insert tpaSecondaryDataAsset2;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset3 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset4 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id);
        insert imsTpaPurposeCategory;
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        insert imsTpaPurposeCategory2;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true);
        insert imsTpaPurposeDescription;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id,
                                                                                                      Is_Active__c = true);
        insert imsTpaPurposeDescription2;
        
        TPA_Purpose_Description__c tpaPurposeDescription = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                          Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        insert tpaPurposeDescription;
        
        TPA_Purpose_Description__c tpaPurposeDescription2 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        insert tpaPurposeDescription2;
        
        TPA_Purpose_Description__c tpaPurposeDescription3 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                           Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        
        TPA_Purpose_Description__c tpaPurposeDescription4 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        
        //Inserting data in custom Setting: TPA_Settings__c
        
        
        //List to store TPA Contact
        List<TPA_Contact__c> tpaContactList= new List<TPA_Contact__c>();
        tpaContactList.add(tpaContact);
        
        //List to store TPA SubContractor
        List<TPA_Contact__c> tpaSubContractorsList= new List<TPA_Contact__c>();
        tpaSubContractorsList.add(tpaContact2);
        
        //List to store ATC
        List<ATC__c> listSavedATC = new List<ATC__c>();
        listSavedATC.add(tpaATC);
        
        //List to store IMS TPA Purpose Description
        List<IMS_TPA_Purpose_Category__c> imsTpaPurposecategoryList = new List<IMS_TPA_Purpose_Category__c>();
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory);
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory2);
        
        //Creating Instance of wrapper class
        CNT_TPA_RequestSubmissionForm.WrapperClass wrapperClassObj = new CNT_TPA_RequestSubmissionForm.WrapperClass();
        
        //Map to store purpose description
        Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass> selectedDescriptionMap = new Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass>();
        selectedDescriptionMap.put(tpaPurposeDescription.id, wrapperClassObj);
        
        //Map top store purposes
        Map<String,TPA_Purpose__c> purposesMap = new Map<String,TPA_Purpose__c>();
        purposesMap.put('tpaPurpose3',tpaPurpose3);
        
        //Map to store purposes named Other
        Map<String,TPA_Purpose__c> purposesOtherMap = new Map<String,TPA_Purpose__c>();
        purposesOtherMap.put('tpaPurpose4',tpaPurpose4);
        
        //Map to store purposes description
        Map<String,TPA_Purpose_Description__c> purpDescMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescMap.put('tpaPurpose3', tpaPurposeDescription3);
        
        //Map to store purposes description of Other named purposes
        Map<String,TPA_Purpose_Description__c> purpDescOtherMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescOtherMap.put('tpaPurpose4', tpaPurposeDescription4);
        
        //Set tp store data assets
        Set<TPA_Data_Asset__c> tpaDataAssetSet = new Set<TPA_Data_Asset__c>();
        tpaDataAssetSet.add(tpaDataAsset3);
        tpaDataAssetSet.add(tpaDataAsset4);
        
        //List to store secondary data assets
        List<TPA_Secondary_Data_Asset__c> tpaSecondaryDataAssetList = new List<TPA_Secondary_Data_Asset__c>();
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset3);
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset4);
        
        //Map to store data assets along with purpose id
        Map<String,set<TPA_Data_Asset__c>> mapPurposesIdWithDataAsset = new Map<String,set<TPA_Data_Asset__c>>();
        mapPurposesIdWithDataAsset.put('dataAssetMap', tpaDataAssetSet);
        
        //Map to store secondary data assets along with purpose id
        Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetsToInsert = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
        mapSecondayDataAssetsToInsert.put('dataAssetMap', tpaSecondaryDataAssetList);
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/
        
        // Test.StartTest();
        
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','c' );
        pageRef.getParameters().put('requestType', 'edit');
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        tpaRequestFormController.getLanguageMap();
        tpaRequestFormController.getTranslatedMap();
        CNT_TPA_RequestSubmissionForm.language = 'en_US';
        Map<String, String> supportedLanguageMaptest = new Map<String, String>();
        supportedLanguageMaptest.put('en_US' , 'English~English_Translation__c~English');
        //CNT_TPA_RequestSubmissionForm.supportedLanguageMap = supportedLanguageMaptest;
        String tpaContactListJSON = JSON.serialize(tpaContactList);
        String tpaSubContractorsListJSON = JSON.serialize(tpaSubContractorsList);
        String listSavedATCJSON = JSON.serialize(listSavedATC);
        String imsTpaPurposecategoryListJSON = JSON.serialize(imsTpaPurposecategoryList);
        String SelectedDescMapJSON = JSON.serialize(selectedDescriptionMap);
        String purposesMapJSON = JSON.serialize(purposesMap);
        String purposesOtherMapJSON = JSON.serialize(purposesOtherMap);
        String purpDescMapJSON = JSON.serialize(purpDescMap);
        String purpDescOtherMapJSON = JSON.serialize(purpDescOtherMap);
        String mapPurposesIdWithDataAssetJSON = JSON.serialize(mapPurposesIdWithDataAsset);
        String mapSecondayDataAssetsToInsertJSON = JSON.serialize(mapSecondayDataAssetsToInsert);
        
        //Added by C.P.Pandey under ER-2654 start
        List<TPA_Use_Offerings_UI_Backup__c> useOffListToInsert = new List<TPA_Use_Offerings_UI_Backup__c>();
        TPA_Use_Offerings_UI_Backup__c useOffObjToInsert = new TPA_Use_Offerings_UI_Backup__c(Details__c = ' edited', Country__c = 'Test', GUID__c = 'Test', Offerings_Selected__c = 'Test', Use_Name_with_Id__c = 'Test', TPA_Request__c = tpaRequest.Id);
        useOffListToInsert.add(useOffObjToInsert);
        //CNT_TPA_RequestSubmissionForm.backupUseOffering(Json.serialize(useOffListToInsert));
        insert useOffObjToInsert;
        string useOffBackupIdsJSON = '' + useOffObjToInsert.Id;
        //Added by C.P.Pandey under ER-2654 end
        
        //Calling save request method where requestTypeSubmitted is ClientSubmit
        String tpaRequestJSON2 = JSON.serialize(tpaRequest);
        String tpaRequestDetailsJSON2 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "ClientSubmit", "processedLanguage" : "en_US","isPublicPrivateChangeOnly" : false, "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "listSaved" : '+listSavedATCJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+ ', "useOffBackupIds":"' + useOffBackupIdsJSON + '"' + '}';//Added by C.P.Pandey under ER-2654
        String returnValue;
        try{
            returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON2);
            System.assertNotEquals(null, returnValue);
        }
        catch(Exception e)
        {}
        
        
        //Calling save request method where requestTypeSubmitted is VendorSubmit
        String tpaRequestDetailsJSON3 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "VendorSubmit", "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
        try
        {
            returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON3);
        }
        catch(Exception e){}
        
        String vendorId = acc.Id;
        List<TPA_Secondary_Data_Asset__c> tpaSecondaryDataAssetList1 ;
        Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetsToInsert1;
        
        tpaSecondaryDataAssetList1 = new List<TPA_Secondary_Data_Asset__c>();
        mapSecondayDataAssetsToInsert1 = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
        tpaSecondaryDataAssetList1.add(tpaSecondaryDataAsset3);
        mapSecondayDataAssetsToInsert1.put(tpaDataAsset.id+':'+tpaPurpose.id+'::United States', tpaSecondaryDataAssetList1);
        
        tpaSecondaryDataAssetList1 = new List<TPA_Secondary_Data_Asset__c>();
        mapSecondayDataAssetsToInsert1 = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
        tpaSecondaryDataAssetList1.add(tpaSecondaryDataAsset4);
        mapSecondayDataAssetsToInsert1.put(tpaDataAsset2.id+':'+tpaPurpose.id+'::United States', tpaSecondaryDataAssetList1);
        
        Map<String,set<TPA_Data_Asset__c>> mapPurposesIdWithDataAsset1 = new Map<String,set<TPA_Data_Asset__c>>();
        Set<TPA_Data_Asset__c> tpaDataAssetSet1;
        
        tpaDataAssetSet1 = new Set<TPA_Data_Asset__c>();
        tpaDataAssetSet1.add(tpaDataAsset);
        // tpaDataAssetSet1.add(tpaDataAsset1);
        tpaDataAssetSet1.add(tpaDataAsset2);
        tpaDataAssetSet1.add(tpaDataAsset3);
        tpaDataAssetSet1.add(tpaDataAsset4);
        
        TPA_Text_Editor__c tpaUseDefinition1 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification', Page_Title__c = imsDataAsset.Id, Page_Type__c = 'Tpa Offering Notifications');
        insert tpaUseDefinition1;
        
        // Added By Neha under Er-3031 starts
        TPA_Text_Editor__c tpaUseDefinition2 = UTL_TPA_SetupTestData.createTpaTestEditorData('Client/Vendor Notification', 'Test Offerings Notification', 'Client/Vendor Notification', 'TPA Offering Addendum');
        TPA_Text_Editor__c tpaUseDefinition3 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 3', 'Notification_Content', 'TPA Offering Addendum');
        TPA_Text_Editor__c tpaUseDefinition4 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 4', 'Notification_Content', 'TPA Offering Addendum');
        TPA_Text_Editor__c tpaUseDefinition5 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 5', 'Notification_Content', 'TPA Offering Addendum');
        TPA_Text_Editor__c tpaUseDefinition6 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 5', 'Notification_Content', 'TPA Offering Notifications');
        
        
        TPA_Offering_Notification_Mapping__c offNotObj = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id,IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition3.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj;
        
        TPA_Offering_Notification_Mapping__c offNotObj2 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset2.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset2.id, TLLA_Additional_Terms__c = tpaUseDefinition4.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj2;
        TPA_Offering_Notification_Mapping__c offNotObj3 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset4.Id, IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj3;
        TPA_Offering_Notification_Mapping__c offNotObj4 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset5.Id,IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj4;
        TPA_Offering_Notification_Mapping__c offNotObj6 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset3.Id, TLLA_Additional_Terms__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj6;
        TPA_Offering_Notification_Mapping__c offNotObj7 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.Id,IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition5.id, Offering_Notifications__c = tpaUseDefinition6.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj7;
        mapPurposesIdWithDataAsset1.put(tpaPurpose2.id+':'+tpaPurposeCategory2+':United States', tpaDataAssetSet);
        
        
        // Added By Neha under Er-3031 Ends
        
        
        Test.StopTest();
        //  }
    }
    
    /**
* Name: requestValidateOnLoadForUSTpaProcessorTest
* Description:
* Param:
* Return:
**/
    private static testmethod void requestValidateOnLoadForUSTpaProcessorTest() {
        
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        //Getting profile id for TP Processor Profile
        Profile p = [SELECT Id FROM Profile WHERE Name like 'US TP Processor Profile CCP%' Limit 1];//Updated by Babita Dadarwal under ER-3552
        //Creating User with TP Processor profile
        User user = new User(Alias = 'standt', Email='standarduser123@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',
                             ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@testing123.com',
                             TimeZoneSidKey='America/Los_Angeles', ContactId = con.id);
        insert user;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CSM_CSH_Community_Access'];
        insert new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id);
        
        Test.StartTest();
        requestValidateOnLoadForUSTpaProcessorFuture(user.Id, con.Id);
        Test.StopTest();
    }
    
    @future
    public static void requestValidateOnLoadForUSTpaProcessorFuture(string userId, string conId) {
        User user = [Select Id, Email from User where Id=: userId Limit 1];
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset;
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        System.runAs(user) {
            
            //Creating TPA request
            TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true, TP_Processor_Email__c= 'test@test.com',Data_Access_Start_Date__c = Date.today(), Data_Access_End_Date__c = Date.today()+365,
                                                           Vendor_e_mail__c = 'test@test.com',Data_Asset_List__c = 'AAN',
                                                           Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                           Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test', 
                                                           Client_Contact_Territory__c = 'United States',Vendor_Billing_Mailing_Country__c= 'United States', ClientContact__c = conId, Client_Language__c = 'English', Vendor_Language__c = 'English');
            insert tpaRequest;
            
            //Creating TPA request
            TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                            Client_Contact_Territory__c = 'United States',Vendor_Billing_Mailing_Country__c= 'United States', isVendorSubmitted__c = true, ClientContact__c = conId, Client_Language__c = 'English', Vendor_Language__c = 'English');
            
            //Creating TP Processor
            TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(Region__c = 'United States', TP_Processor_Name__c = 'US TP Proccessor',
                                                                      TP_Processor_Email__c = 'sunny.bansal@metacube.com');
            insert tpProcessor;
            
            //Creating TPA_Region_Country
            TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
            insert tpaRegionCountry;
            
            TPA_Contact__c tpaContact = new TPA_Contact__c(Type__c = 'SubContractor Contact'); //TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id,
            //insert tpaContact;
            
            TPA_Contact__c tpaContact2 = new TPA_Contact__c(Type__c = 'SubContractor Contact');
            
            ATC__c tpaATC = new ATC__c(Active__c = true, ATC_Code__c = '123', Name_Eng__c = 'Test ATC');
            insert tpaATC;
            
            TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c(TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id);
            insert tpaRequestATC;
            
            IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail',
                                                                      Is_Active__c = true);
            insert imsTpaPurpose;
            
            IMS_TPA_Purpose__c imsTpaPurpose2 = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'Other', Purpose_Details__c = 'test detail2',
                                                                       Is_Active__c = true);
            insert imsTpaPurpose2;
            
            TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
            insert tpaPurposeCategory;
            
            TPA_Purpose_Category__c tpaPurposeCategory2 = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
            insert tpaPurposeCategory2;
            
            TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
            insert tpaPurpose;
            
            TPA_Purpose__c tpaPurpose2 = new TPA_Purpose__c(Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory2.id);
            insert tpaPurpose2;
            
            TPA_Purpose__c tpaPurpose3 = new TPA_Purpose__c(Name = 'Test TPA Purpose1',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
            insert tpaPurpose3 ;
            TPA_Purpose__c tpaPurpose4 = new TPA_Purpose__c(Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
            insert tpaPurpose4;
            
            TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                                   BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
            insert tpaDataAsset;
            
            TPA_Data_Asset__c tpaDataAsset2 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                    BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
            insert tpaDataAsset2;
            
            TPA_Data_Asset__c tpaDataAsset3 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose3.id, Data_Asset__c = imsDataAsset.id,
                                                                    BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
            insert tpaDataAsset3;
            
            TPA_Data_Asset__c tpaDataAsset4 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose4.id, Data_Asset__c = imsDataAsset.id,
                                                                    BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
            insert tpaDataAsset4;
            
            TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
            insert tpaSecondaryDataAsset;
            
            TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
            insert tpaSecondaryDataAsset2;
            
            TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset3 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
            
            TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset4 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
            
            IMS_TPA_Purpose_Category__c imsTpaPurposeCategory= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id);
            insert imsTpaPurposeCategory;
            
            IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id);
            insert imsTpaPurposeCategory2;
            
            IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                         Is_Active__c = true);
            insert imsTpaPurposeDescription;
            
            IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id,
                                                                                                          Is_Active__c = true);
            insert imsTpaPurposeDescription2;
            
            TPA_Purpose_Description__c tpaPurposeDescription = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                              Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
            insert tpaPurposeDescription;
            
            TPA_Purpose_Description__c tpaPurposeDescription2 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                               Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
            insert tpaPurposeDescription2;
            
            TPA_Purpose_Description__c tpaPurposeDescription3 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                               Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
            
            TPA_Purpose_Description__c tpaPurposeDescription4 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                               Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
            
            
            List<TPA_Contact__c> tpaContactList= new List<TPA_Contact__c>();
            tpaContactList.add(tpaContact);
            
            //List to store TPA SubContractor
            List<TPA_Contact__c> tpaSubContractorsList= new List<TPA_Contact__c>();
            tpaSubContractorsList.add(tpaContact2);
            
            //List to store ATC
            List<ATC__c> listSavedATC = new List<ATC__c>();
            listSavedATC.add(tpaATC);
            
            //List to store IMS TPA Purpose Description
            List<IMS_TPA_Purpose_Category__c> imsTpaPurposecategoryList = new List<IMS_TPA_Purpose_Category__c>();
            imsTpaPurposecategoryList.add(imsTpaPurposeCategory);
            imsTpaPurposecategoryList.add(imsTpaPurposeCategory2);
            
            //Creating Instance of wrapper class
            CNT_TPA_RequestSubmissionForm.WrapperClass wrapperClassObj = new CNT_TPA_RequestSubmissionForm.WrapperClass();
            
            //Map to store purpose description
            Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass> selectedDescriptionMap = new Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass>();
            selectedDescriptionMap.put(tpaPurposeDescription.id, wrapperClassObj);
            
            //Map top store purposes
            Map<String,TPA_Purpose__c> purposesMap = new Map<String,TPA_Purpose__c>();
            purposesMap.put('tpaPurpose3',tpaPurpose3);
            
            //Map to store purposes named Other
            Map<String,TPA_Purpose__c> purposesOtherMap = new Map<String,TPA_Purpose__c>();
            purposesOtherMap.put('tpaPurpose4',tpaPurpose4);
            
            //Map to store purposes description
            Map<String,TPA_Purpose_Description__c> purpDescMap = new Map<String,TPA_Purpose_Description__c>();
            purpDescMap.put('tpaPurpose3', tpaPurposeDescription3);
            
            //Map to store purposes description of Other named purposes
            Map<String,TPA_Purpose_Description__c> purpDescOtherMap = new Map<String,TPA_Purpose_Description__c>();
            purpDescOtherMap.put('tpaPurpose4', tpaPurposeDescription4);
            
            //Set tp store data assets
            Set<TPA_Data_Asset__c> tpaDataAssetSet = new Set<TPA_Data_Asset__c>();
            tpaDataAssetSet.add(tpaDataAsset3);
            tpaDataAssetSet.add(tpaDataAsset4);
            
            //List to store secondary data assets
            List<TPA_Secondary_Data_Asset__c> tpaSecondaryDataAssetList = new List<TPA_Secondary_Data_Asset__c>();
            tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset3);
            tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset4);
            
            //Map to store data assets along with purpose id
            Map<String,set<TPA_Data_Asset__c>> mapPurposesIdWithDataAsset = new Map<String,set<TPA_Data_Asset__c>>();
            mapPurposesIdWithDataAsset.put('dataAssetMap', tpaDataAssetSet);
            
            //Map to store secondary data assets along with purpose id
            Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetsToInsert = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
            mapSecondayDataAssetsToInsert.put('dataAssetMap', tpaSecondaryDataAssetList);
            
            
            // To set the current page to TPA Page Access Request Form page
            PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
            pageRef.getParameters().put('id', tpaRequest.Id);
            pageRef.getParameters().put('type','c' );
            pageRef.getParameters().put('requestType', 'edit');
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
            //CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
            CNT_TPA_RequestSubmissionForm.language = 'en_US';
            Map<String, String> supportedLanguageMaptest = new Map<String, String>();
            supportedLanguageMaptest.put('en_US' , 'English~English_Translation__c~English');
            String tpaRequestJSON = JSON.serialize(tpaRequest2);
            String tpaContactListJSON = JSON.serialize(tpaContactList);
            String tpaSubContractorsListJSON = JSON.serialize(tpaSubContractorsList);
            String listSavedATCJSON = JSON.serialize(listSavedATC);
            String imsTpaPurposecategoryListJSON = JSON.serialize(imsTpaPurposecategoryList);
            String SelectedDescMapJSON = JSON.serialize(selectedDescriptionMap);
            String purposesMapJSON = JSON.serialize(purposesMap);
            String purposesOtherMapJSON = JSON.serialize(purposesOtherMap);
            String purpDescMapJSON = JSON.serialize(purpDescMap);
            String purpDescOtherMapJSON = JSON.serialize(purpDescOtherMap);
            String mapPurposesIdWithDataAssetJSON = JSON.serialize(mapPurposesIdWithDataAsset);
            String mapSecondayDataAssetsToInsertJSON = JSON.serialize(mapSecondayDataAssetsToInsert);
            
            //Added by C.P.Pandey under ER-2654 start
            List<TPA_Use_Offerings_UI_Backup__c> useOffListToInsert = new List<TPA_Use_Offerings_UI_Backup__c>();
            TPA_Use_Offerings_UI_Backup__c useOffObjToInsert = new TPA_Use_Offerings_UI_Backup__c(Details__c = ' edited', Country__c = 'Test', GUID__c = 'Test', Offerings_Selected__c = 'Test', Use_Name_with_Id__c = 'Test', TPA_Request__c = tpaRequest.Id);
            useOffListToInsert.add(useOffObjToInsert);
            //CNT_TPA_RequestSubmissionForm.backupUseOffering(Json.serialize(useOffListToInsert));
            insert useOffObjToInsert;
            string useOffBackupIdsJSON = '' + useOffObjToInsert.Id;
            //Added by C.P.Pandey under ER-2654 end
            
            //Calling save request method where requestTypeSubmitted is NewRequest
            /*String tpaRequestDetailsJSON = '{"tpaRequest" : '+tpaRequestJSON+', "requestTypeSubmitted" : "NewRequest", "tpaAdditionalContactList" : '+tpaContactListJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
String returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON);
System.assertNotEquals(null, returnValue);*/
            
            //Calling save request method where requestTypeSubmitted is ClientSubmit
            tpaRequest.AMA_USPrescriberData__c = 'Yes';
            String tpaRequestJSON2 = JSON.serialize(tpaRequest);
            String tpaRequestDetailsJSON2 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "ClientSubmit","processedLanguage" : "en_US","isPublicPrivateChangeOnly" : false, "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "listSaved" : '+listSavedATCJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+ ', "useOffBackupIds" : "' + useOffBackupIdsJSON + '"' + '}';//Added by C.P.Pandey under ER-2654
            string returnValue;
            try{
                returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON2);
            }
            catch(Exception e){}
            
            //Calling save request method where requestTypeSubmitted is VendorSubmit
            String tpaRequestDetailsJSON3 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "VendorSubmit","processedLanguage" : "en_US", "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
            try{
                //returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON3);
            }
            catch(Exception e){}
            //System.assertNotEquals(null, returnValue);
            
        }
    }
    
    /**
* Name: tpaRequestForUnAuthenticatedUserTest
* Description:
* Param:
* Return:
**/
    private static testmethod void tpaRequestForUnAuthenticatedUserTest() {
        
        
        
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        //Getting profile id for TP Processor Profile
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP%' Limit 1];//Updated by Babita Dadarwal under ER-3552
        
        //Creating User with TP Processor profile
        User user = new User(Alias = 'standt', Email='standarduser123@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',
                             ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@testing123.com',
                             TimeZoneSidKey='America/Los_Angeles', ContactId = con.id);
        insert user;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CSM_CSH_Community_Access'];
        insert new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id);
        
        Test.StartTest();
        tpaRequestForUnAuthenticatedUserFuture(user.Id);
        Test.StopTest();
    }
    
    @future
    public static void tpaRequestForUnAuthenticatedUserFuture(string userId) {   
        User user = [Select Id, Email from User where Id=: userId Limit 1];
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'USA' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset;  
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
            
        System.runAs(user) {
            
            //Creating TPA request
            TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(),  Data_Asset_List__c = 'AAN',
                                                           Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                           Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test');
            insert tpaRequest;
            
            ATC__c tpaATC = new ATC__c(Active__c = true, ATC_Code__c = '123', Name_Eng__c = 'Test ATC');
            insert tpaATC;
            
            TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c(TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id);
            insert tpaRequestATC;
            
            IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'USA', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail', Is_Active__c = true);
            insert imsTpaPurpose;
            
            TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'USA', Purpose__c = imsTpaPurpose.id);
            insert tpaPurpose;
            
            TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                                   BU__c = 'USA');
            insert tpaDataAsset;
            
            TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
            insert tpaSecondaryDataAsset;
            
            TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis', isActive__c = true);
            insert tpaPurposeCategory;
            
            IMS_TPA_Purpose_Category__c imsTpaPurposeCategory= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id, isActive__c = true);
            insert imsTpaPurposeCategory;
            
            IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                         Is_Active__c = true);
            insert imsTpaPurposeDescription;
            
            TPA_Purpose_Description__c tpaPurposeDescription = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                              Other_Details__c = 'Test Other Details');
            insert tpaPurposeDescription;
            
            //Creating custom setting record
            /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
            tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
            tpaCustomLandingPageMessage.Name = 'TPA Down Message';
            insert tpaCustomLandingPageMessage;*/
            
            // To set the current page to TPA Page Access Request Form page
            PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
            pageRef.getParameters().put('id', null);
            pageRef.getParameters().put('type','c' );
            pageRef.getParameters().put('requestType', 'edit');
            pageRef.getParameters().put('uid', userId);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
            CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
            tpaRequestFormController.requestValidateOnLoad();
            System.assertNotEquals(null, tpaRequestFormController);
            
            // To set the current page to TPA Page Access Request Form page
            pageRef = Page.VFP_TPA_RequestSubmissionForm;
            pageRef.getParameters().put('id', tpaRequest.id);
            pageRef.getParameters().put('type','c' );
            pageRef.getParameters().put('requestType', 'renew');
            Test.setCurrentPage(pageRef);
            sc = new ApexPages.standardController(tpaRequest);
            tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
            tpaRequestFormController.requestValidateOnLoad();
            System.assertNotEquals(null, tpaRequestFormController);
        }
    }
    
    private static testmethod void createOrUpdateAgreementAdditionalFieldDataRecordTest() {
        
        
        
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        //Creating TPA request
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                       Client_Contact_Territory__c = 'United States', ClientContact__c = con.id, isVendorSubmitted__c = true);
        insert tpaRequest;
        
        //Creating TPA request
        TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                        Client_Contact_Territory__c = 'United States', isVendorSubmitted__c = true, ClientContact__c = con.id,
                                                        TPA_Request_Marked_as__c = 'Public', Data_Asset_List__c = 'AAN',
                                                        Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                        Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test');
        
        //Creating TP Processor
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(Region__c = 'United States', TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'sunny.bansal@metacube.com');
        insert tpProcessor;
        
        //Creating TPA_Region_Country
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;
        
        TPA_Contact__c tpaContact = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        //insert tpaContact;
        
        TPA_Contact__c tpaContact2 = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        
        ATC__c tpaATC = new ATC__c(Active__c = true, ATC_Code__c = '123', Name_Eng__c = 'Test ATC');
        insert tpaATC;
        
        TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c(TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id);
        insert tpaRequestATC;
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        insert imsTpaPurpose;
        
        IMS_TPA_Purpose__c imsTpaPurpose2 = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'Other', Purpose_Details__c = 'test detail2',
                                                                   Is_Active__c = true);
        insert imsTpaPurpose2;
        
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        insert tpaPurposeCategory;
        
        TPA_Purpose_Category__c tpaPurposeCategory2 = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        insert tpaPurposeCategory2;
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        insert tpaPurpose;
        
        TPA_Purpose__c tpaPurpose2 = new TPA_Purpose__c(Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        insert tpaPurpose2;
        
        TPA_Purpose__c tpaPurpose3 = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        
        TPA_Purpose__c tpaPurpose4 = new TPA_Purpose__c(Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        insert tpaDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset2 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        insert tpaDataAsset2;
        
        TPA_Data_Asset__c tpaDataAsset3 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        //insert tpaDataAsset3;
        
        TPA_Data_Asset__c tpaDataAsset4 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        //insert tpaDataAsset4;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset2;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset3 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset4 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id);
        insert imsTpaPurposeCategory;
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        insert imsTpaPurposeCategory2;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true);
        insert imsTpaPurposeDescription;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id,
                                                                                                      Is_Active__c = true);
        insert imsTpaPurposeDescription2;
        
        TPA_Purpose_Description__c tpaPurposeDescription = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                          Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        insert tpaPurposeDescription;
        
        TPA_Purpose_Description__c tpaPurposeDescription2 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        insert tpaPurposeDescription2;
        
        TPA_Purpose_Description__c tpaPurposeDescription3 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                           Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        
        TPA_Purpose_Description__c tpaPurposeDescription4 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/

        AMA_Agreement_Detail__c amaSub = new AMA_Agreement_Detail__c(Client_req_Storage_Permission_from_NonUS__c = 'Yes',
                                                                    Client_Employee_Store_Data_in_country__c = 'india',
                                                                    Vendor_require_Remote_Access_from_NonUS__c = 'Yes',
                                                                    Vendor_Employee_Accessed_Data_in_country__c = 'india',
                                                                    Technology_s_selected_for_remote_access__c = 'test',
                                                                    Vendor_req_Storage_Permission_from_NonUS__c = 'Yes',
                                                                    Vendor_Employee_Store_Data_in_country__c = 'india'
                                                                    );
        
        //List to store TPA Contact
        List<TPA_Contact__c> tpaContactList= new List<TPA_Contact__c>();
        tpaContactList.add(tpaContact);
        
        //List to store TPA SubContractor
        List<TPA_Contact__c> tpaSubContractorsList= new List<TPA_Contact__c>();
        tpaSubContractorsList.add(tpaContact2);
        
        //List to store ATC
        List<ATC__c> listSavedATC = new List<ATC__c>();
        listSavedATC.add(tpaATC);
        
        //List to store IMS TPA Purpose Description
        List<IMS_TPA_Purpose_Category__c> imsTpaPurposecategoryList = new List<IMS_TPA_Purpose_Category__c>();
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory);
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory2);
        
        //Creating Instance of wrapper class
        CNT_TPA_RequestSubmissionForm.WrapperClass wrapperClassObj = new CNT_TPA_RequestSubmissionForm.WrapperClass();
        
        //Map to store purpose description
        Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass> selectedDescriptionMap = new Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass>();
        selectedDescriptionMap.put(tpaPurposeDescription.id, wrapperClassObj);
        
        //Map top store purposes
        Map<String,TPA_Purpose__c> purposesMap = new Map<String,TPA_Purpose__c>();
        purposesMap.put('tpaPurpose3',tpaPurpose3);
        
        //Map to store purposes named Other
        Map<String,TPA_Purpose__c> purposesOtherMap = new Map<String,TPA_Purpose__c>();
        purposesOtherMap.put('tpaPurpose4',tpaPurpose4);
        
        //Map to store purposes description
        Map<String,TPA_Purpose_Description__c> purpDescMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescMap.put('tpaPurpose3', tpaPurposeDescription3);
        
        //Map to store purposes description of Other named purposes
        Map<String,TPA_Purpose_Description__c> purpDescOtherMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescOtherMap.put('tpaPurpose4', tpaPurposeDescription4);
        
        //Set tp store data assets
        Set<TPA_Data_Asset__c> tpaDataAssetSet = new Set<TPA_Data_Asset__c>();
        tpaDataAssetSet.add(tpaDataAsset3);
        tpaDataAssetSet.add(tpaDataAsset4);
        
        //List to store secondary data assets
        List<TPA_Secondary_Data_Asset__c> tpaSecondaryDataAssetList = new List<TPA_Secondary_Data_Asset__c>();
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset3);
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset4);
        
        //Map to store data assets along with purpose id
        Map<String,set<TPA_Data_Asset__c>> mapPurposesIdWithDataAsset = new Map<String,set<TPA_Data_Asset__c>>();
        mapPurposesIdWithDataAsset.put('dataAssetMap', tpaDataAssetSet);
        
        //Map to store secondary data assets along with purpose id
        Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetsToInsert = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
        mapSecondayDataAssetsToInsert.put('dataAssetMap', tpaSecondaryDataAssetList);
        
        Test.StartTest();
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','v' );
        pageRef.getParameters().put('requestType', 'edit');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        
        tpaRequestFormController.getAmaFreqDeliveryData();
        tpaRequestFormController.getAMAlistValuesData();
        tpaRequestFormController.getAmaPrescLvlData();
       // tpaRequestFormController.getAmaResponseCollectionMeans();
      //  tpaRequestFormController.getAmaPpdVariablesData();
        
        
        
        tpaRequestFormController.getImsSoftwareData();
        
        tpaRequestFormController.getLoggedInCurrentUser();
        tpaRequestFormController.getVendorLoggedInUser();
        tpaRequestFormController.getObjectTpaRequestToEdit();
        tpaRequestFormController.getObjectExistedUsesAndAssets();
        //tpaRequestFormController.getTherapeuticAreaList();
        
        
        tpaRequestFormController.getCountryList();
        
        tpaRequestFormController.getAMAlistValuesDataMap();
      //  tpaRequestFormController.getAmaResponseCollectionMeansMap();
       // tpaRequestFormController.getAmaPpdVariablesMap();
        /*insert new List<TPA_AMA_Market_Research_Attributes_List__c>{new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA', AMA_Market_Research_Attributes__c = 'Test'),
            new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA1', AMA_Market_Research_Attributes__c = 'Test1'),
            new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA2', AMA_Market_Research_Attributes__c = 'Test2'),
            new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA3', AMA_Market_Research_Attributes__c = 'Test3')};
                tpaRequestFormController.getAMAMRAttributesMap();*/
      //  tpaRequestFormController.getAmaDMAttribuesMap();
        tpaRequestFormController.getDdtFreqDeliveryData();
        //tpaRequestFormController.getAmaMRAttributesList();
      //  tpaRequestFormController.getAmaDMAttributesList();
        
        String tpaRequestJSON = JSON.serialize(tpaRequest2);
        String tpaContactListJSON = JSON.serialize(tpaContactList);
        String tpaSubContractorsListJSON = JSON.serialize(tpaSubContractorsList);
        String listSavedATCJSON = JSON.serialize(listSavedATC);
        String imsTpaPurposecategoryListJSON = JSON.serialize(imsTpaPurposecategoryList);
        String SelectedDescMapJSON = JSON.serialize(selectedDescriptionMap);
        String purposesMapJSON = JSON.serialize(purposesMap);
        String purposesOtherMapJSON = JSON.serialize(purposesOtherMap);
        String purpDescMapJSON = JSON.serialize(purpDescMap);
        String purpDescOtherMapJSON = JSON.serialize(purpDescOtherMap);
        String mapPurposesIdWithDataAssetJSON = JSON.serialize(mapPurposesIdWithDataAsset);
        String mapSecondayDataAssetsToInsertJSON = JSON.serialize(mapSecondayDataAssetsToInsert);
        String amaJSON = JSON.serialize(amaSub);
        
        //Added by C.P.Pandey under ER-2654 start
        List<TPA_Use_Offerings_UI_Backup__c> useOffListToInsert = new List<TPA_Use_Offerings_UI_Backup__c>();
        TPA_Use_Offerings_UI_Backup__c useOffObjToInsert = new TPA_Use_Offerings_UI_Backup__c(Details__c = ' edited', Country__c = 'Test', GUID__c = 'Test', Offerings_Selected__c = 'Test', Use_Name_with_Id__c = 'Test', TPA_Request__c = tpaRequest.Id);
        useOffListToInsert.add(useOffObjToInsert);
        //CNT_TPA_RequestSubmissionForm.backupUseOffering(Json.serialize(useOffListToInsert));
        insert useOffObjToInsert;
        string useOffBackupIdsJSON = '' + useOffObjToInsert.Id;
        //Added by C.P.Pandey under ER-2654 end
        
        //Calling save request method where requestTypeSubmitted is NewRequest
        String tpaRequestDetailsJSON = '{"tpaRequest" : '+tpaRequestJSON+', "requestTypeSubmitted" : "NewRequest", "tpaAdditionalContactList" : '+tpaContactListJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+', "isVendorContactInvited" : true, "vendorName" : "Sunny", "vendorContactName" : "Bansal", "invitedContact" : '+con.id+'}';
        String returnValue;
        try{
            returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON);
            System.assertNotEquals(null, returnValue);}
        catch(Exception e){}
        
        
        //Calling save request method where requestTypeSubmitted is ClientSubmit
        tpaRequest.AMA_USPrescriberData__c = 'Yes';
        String tpaRequestJSON2 = JSON.serialize(tpaRequest);
        String tpaRequestDetailsJSON2 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "ClientSubmit", "tpaAdditionalContactList" : '+tpaContactListJSON+', "listSaved" : '+listSavedATCJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+ ', "useOffBackupIds":"' + useOffBackupIdsJSON + '"' + '}';//Added by C.P.Pandey under ER-2654
        try{
            returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON2);
            //System.assertNotEquals(null, returnValue);
        }
        catch(Exception e){}
        //Calling save request method where requestTypeSubmitted is VendorSubmit
        String tpaRequestDetailsJSON3 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "VendorSubmit", "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
        try{
            CNT_TPA_RequestSubmissionForm.CreateOrUpdateAgreementAdditionalFieldDataRecord((CNT_TPA_RequestSubmissionForm.tpaRequestDetails)JSON.deserialize(tpaRequestDetailsJSON2, CNT_TPA_RequestSubmissionForm.tpaRequestDetails.class), false);
        }
        catch(Exception e){}
        Test.StopTest();
    }
    
    private static testmethod void tpProcessorSubmissionTest() {
        
        UTL_TPA_SetupTestData.createCrossWalkData();
        TPA_AMA_Settings__c amaSetting = new TPA_AMA_Settings__c(Name = 'AMA Settings', Vendor_Renewal_Cancelation_Status__c = 'Vendor Canceled ‘21 AMA-TPA Exp-12/31/20');
        insert amaSetting;
        CNT_TPA_RequestSubmissionForm.loadTPProcessorDetils('US');
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Address__c addrs = [select id from Address__c where Name = 'TPA Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Test Contact' limit 1];
        
        //Creating TPA request
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                       Client_Contact_Territory__c = 'United States', ClientContact__c = con.id, isVendorSubmitted__c = true, AMA_USPrescriberData__c = 'Yes', Service_Provider_Address__c = addrs.Id
                                                       , Data_Access_Start_Date__c = Date.today(), Data_Access_End_Date__c = Date.today().addDays(365),Vendor_Billing_Mailing_Country__c= 'United States',is_Bulk_TPA_Request__c = true);
        insert tpaRequest;
        
        //Creating TPA request
        TPA_Request__c tpaRequest2 = new TPA_Request__c(OwnerId = UserInfo.getUserId(), CopyAdditionalContactOnTransactions__c = 'Yes', Is_Submitted__c = true,
                                                        Client_Contact_Territory__c = 'United States', isVendorSubmitted__c = true, ClientContact__c = con.id,
                                                        TPA_Request_Marked_as__c = 'Public', Data_Asset_List__c = 'AAN',
                                                        Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                        Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test', AMA_USPrescriberData__c = 'Yes', Service_Provider_Address__c = addrs.Id,Vendor_Billing_Mailing_Country__c= 'United States');
        
        //Creating TP Processor
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(Region__c = 'United States', TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'sunny.bansal@metacube.com');
        insert tpProcessor;
        
        //Creating TPA_Region_Country
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;
        
        TPA_Contact__c tpaContact = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        //insert tpaContact;
        
        TPA_Contact__c tpaContact2 = new TPA_Contact__c(TPA_Request__c = tpaRequest.id, Subcontractor_TPA_Request__c = tpaRequest.id, Type__c = 'SubContractor Contact');
        
        ATC__c tpaATC = new ATC__c(Active__c = true, ATC_Code__c = '123', Name_Eng__c = 'Test ATC');
        insert tpaATC;
        
        TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c(TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id);
        insert tpaRequestATC;
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(English_Translation__c = 'Test TPA Purpose', BU__c = 'United States', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        insert imsTpaPurpose;
        
        IMS_TPA_Purpose__c imsTpaPurpose2 = new IMS_TPA_Purpose__c(English_Translation__c = 'Test TPA Purpose', BU__c = 'United States', Primary_Purpose_Name__c = 'Other', Purpose_Details__c = 'test detail2',
                                                                   Is_Active__c = true);
        insert imsTpaPurpose2;
        
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        insert tpaPurposeCategory;
        
        TPA_Purpose_Category__c tpaPurposeCategory2 = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis');
        insert tpaPurposeCategory2;
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(purpose__c = imsTpaPurpose.Id,  Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        insert tpaPurpose;
        
        TPA_Purpose__c tpaPurpose2 = new TPA_Purpose__c(purpose__c = imsTpaPurpose.Id, Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory2.id, Other_Text__c = 'test');
        insert tpaPurpose2;
        
        TPA_Purpose__c tpaPurpose3 = new TPA_Purpose__c(purpose__c = imsTpaPurpose.Id,  Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id);
        
        TPA_Purpose__c tpaPurpose4 = new TPA_Purpose__c(purpose__c = imsTpaPurpose.Id,  Name = 'Other',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id, Other_Text__c = 'test');
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = 'onekey data - United States' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        insert tpaDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset2 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        insert tpaDataAsset2;
        
        TPA_Data_Asset__c tpaDataAsset3 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        //insert tpaDataAsset3;
        
        TPA_Data_Asset__c tpaDataAsset4 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose2.id, Data_Asset__c = imsDataAsset.id,
                                                                BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Other');
        //insert tpaDataAsset4;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset2;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset3 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset4 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset2.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id);
        insert imsTpaPurposeCategory;
        
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2= new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id);
        insert imsTpaPurposeCategory2;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true);
        insert imsTpaPurposeDescription;
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose2.id, TPA_Purpose_Category__c = tpaPurposeCategory2.id,
                                                                                                      Is_Active__c = true);
        insert imsTpaPurposeDescription2;
        
        TPA_Purpose_Description__c tpaPurposeDescription = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                          Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        insert tpaPurposeDescription;
        
        TPA_Purpose_Description__c tpaPurposeDescription2 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        insert tpaPurposeDescription2;
        
        TPA_Purpose_Description__c tpaPurposeDescription3 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id,
                                                                                           Other_Details__c = 'Test Other details', Description_Text__c = 'Test Desc Text');
        
        TPA_Purpose_Description__c tpaPurposeDescription4 = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose2.id, Description__c = imsTpaPurposeDescription2.id,
                                                                                           Other_Details__c = 'Test Other details2', Description_Text__c = 'Test Desc Text2');
        
        //Creating custom setting record
        /*TPA_Custom_Landing_Page_Message__c tpaCustomLandingPageMessage = new TPA_Custom_Landing_Page_Message__c();
        tpaCustomLandingPageMessage.Is_Show_Vendor_Message_Board__c = true;
        tpaCustomLandingPageMessage.Name = 'TPA Down Message';
        insert tpaCustomLandingPageMessage;*/
        
        //List to store TPA Contact
        List<TPA_Contact__c> tpaContactList= new List<TPA_Contact__c>();
        tpaContactList.add(tpaContact);
        
        //List to store TPA SubContractor
        List<TPA_Contact__c> tpaSubContractorsList= new List<TPA_Contact__c>();
        tpaSubContractorsList.add(tpaContact2);
        
        //List to store ATC
        List<ATC__c> listSavedATC = new List<ATC__c>();
        listSavedATC.add(tpaATC);
        
        //List to store IMS TPA Purpose Description
        List<IMS_TPA_Purpose_Category__c> imsTpaPurposecategoryList = new List<IMS_TPA_Purpose_Category__c>();
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory);
        imsTpaPurposecategoryList.add(imsTpaPurposeCategory2);
        
        //Creating Instance of wrapper class
        CNT_TPA_RequestSubmissionForm.WrapperClass wrapperClassObj = new CNT_TPA_RequestSubmissionForm.WrapperClass();
        
        //Map to store purpose description
        Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass> selectedDescriptionMap = new Map<String,CNT_TPA_RequestSubmissionForm.WrapperClass>();
        selectedDescriptionMap.put(tpaPurposeDescription.id, wrapperClassObj);
        
        //Map top store purposes
        Map<String,TPA_Purpose__c> purposesMap = new Map<String,TPA_Purpose__c>();
        purposesMap.put('tpaPurpose3',tpaPurpose3);
        
        //Map to store purposes named Other
        Map<String,TPA_Purpose__c> purposesOtherMap = new Map<String,TPA_Purpose__c>();
        purposesOtherMap.put('tpaPurpose4',tpaPurpose4);
        
        //Map to store purposes description
        Map<String,TPA_Purpose_Description__c> purpDescMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescMap.put('tpaPurpose3', tpaPurposeDescription3);
        
        //Map to store purposes description of Other named purposes
        Map<String,TPA_Purpose_Description__c> purpDescOtherMap = new Map<String,TPA_Purpose_Description__c>();
        purpDescOtherMap.put('tpaPurpose4', tpaPurposeDescription4);
        
        //Set tp store data assets
        Set<TPA_Data_Asset__c> tpaDataAssetSet = new Set<TPA_Data_Asset__c>();
        tpaDataAssetSet.add(tpaDataAsset3);
        tpaDataAssetSet.add(tpaDataAsset4);
        
        //List to store secondary data assets
        List<TPA_Secondary_Data_Asset__c> tpaSecondaryDataAssetList = new List<TPA_Secondary_Data_Asset__c>();
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset3);
        tpaSecondaryDataAssetList.add(tpaSecondaryDataAsset4);
        
        //Map to store data assets along with purpose id
        Map<String,set<TPA_Data_Asset__c>> mapPurposesIdWithDataAsset = new Map<String,set<TPA_Data_Asset__c>>();
        mapPurposesIdWithDataAsset.put('dataAssetMap', tpaDataAssetSet);
        
        //Map to store secondary data assets along with purpose id
        Map<String,List<TPA_Secondary_Data_Asset__c>> mapSecondayDataAssetsToInsert = new Map<String,List<TPA_Secondary_Data_Asset__c>>();
        mapSecondayDataAssetsToInsert.put('dataAssetMap', tpaSecondaryDataAssetList);
        
        List<TPA_Contact__c> tpaContactLiist = new List<TPA_Contact__c>{new TPA_Contact__c()};
        
        List<IMS_TPA_Purpose_Description__c> imsTPAPurpDiscList = new List<IMS_TPA_Purpose_Description__c>{imsTpaPurposeDescription};
        
        AMA_Agreement_Detail__c amaSub = new AMA_Agreement_Detail__c(Client_req_Storage_Permission_from_NonUS__c = 'Yes',
                                                                    Client_Employee_Store_Data_in_country__c = 'india',
                                                                    Vendor_require_Remote_Access_from_NonUS__c = 'Yes',
                                                                    Vendor_Employee_Accessed_Data_in_country__c = 'india',
                                                                    Vendor_req_Storage_Permission_from_NonUS__c = 'Yes',
                                                                    Vendor_Employee_Store_Data_in_country__c = 'india',
                                                                    TPA_Request__c = tpaRequest.id
                                                                    );
                                                                    
                                                                    
       insert amaSub;

       IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test', Legal_Entity_Name_for_TLLA__c = 'test Name', Name_for_ESign__c = 'Test Esign',Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;

        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test', TPA_Request__c = tpaRequest.Id,IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;
        
        Test.StartTest();
        // To set the current page to TPA Page Access Request Form page
        PageReference pageRef = Page.VFP_TPA_RequestSubmissionForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('type','v' );
        pageRef.getParameters().put('requestType', 'edit');
        pageRef.getParameters().put('currentViewLang', 'en_US');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(tpaRequest);
        CNT_TPA_RequestSubmissionForm tpaRequestFormController = new CNT_TPA_RequestSubmissionForm(sc);
        
        tpaRequestFormController.getAmaFreqDeliveryData();
        tpaRequestFormController.getAmaDataTimePeriod();
        tpaRequestFormController.getAMAlistValuesData();
        tpaRequestFormController.getAmaPrescLvlData();
      //  tpaRequestFormController.getAmaResponseCollectionMeans();
      //  tpaRequestFormController.getAmaPpdVariablesData();
        
        
        
        tpaRequestFormController.getImsSoftwareData();
        
        tpaRequestFormController.getLoggedInCurrentUser();
        tpaRequestFormController.getVendorLoggedInUser();
        tpaRequestFormController.getObjectTpaRequestToEdit();
        tpaRequestFormController.getObjectExistedUsesAndAssets();
        //tpaRequestFormController.getTherapeuticAreaList();
        
        
        tpaRequestFormController.getCountryList();
        
        tpaRequestFormController.getAMAlistValuesDataMap();
     //  tpaRequestFormController.getAmaResponseCollectionMeansMap();
      //  tpaRequestFormController.getAmaPpdVariablesMap();
        /*insert new List<TPA_AMA_Market_Research_Attributes_List__c>{new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA', AMA_Market_Research_Attributes__c = 'Test'),
            new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA1', AMA_Market_Research_Attributes__c = 'Test1'),
            new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA2', AMA_Market_Research_Attributes__c = 'Test2'),
            new TPA_AMA_Market_Research_Attributes_List__c(Name = 'test AMA3', AMA_Market_Research_Attributes__c = 'Test3')};
                tpaRequestFormController.getAMAMRAttributesMap();*/
     //   tpaRequestFormController.getAmaDMAttribuesMap();
        tpaRequestFormController.getDdtFreqDeliveryData();
        //tpaRequestFormController.getAmaMRAttributesList();
      //  tpaRequestFormController.getAmaDMAttributesList();
        
        String tpaRequestJSON = JSON.serialize(tpaRequest);
        String tpaContactListJSON = JSON.serialize(tpaContactList);
        String tpaSubContractorsListJSON = JSON.serialize(tpaSubContractorsList);
        String listSavedATCJSON = JSON.serialize(listSavedATC);
        String imsTpaPurposecategoryListJSON = JSON.serialize(imsTpaPurposecategoryList);
        String SelectedDescMapJSON = JSON.serialize(selectedDescriptionMap);
        String purposesMapJSON = JSON.serialize(purposesMap);
        String purposesOtherMapJSON = JSON.serialize(purposesOtherMap);
        String purpDescMapJSON = JSON.serialize(purpDescMap);
        String purpDescOtherMapJSON = JSON.serialize(purpDescOtherMap);
        String mapPurposesIdWithDataAssetJSON = JSON.serialize(mapPurposesIdWithDataAsset);
        String mapSecondayDataAssetsToInsertJSON = JSON.serialize(mapSecondayDataAssetsToInsert);
        String tpaAdditionalVendorContactListJSON = JSON.serialize(tpaContactLiist);
        String secondarypurposeJSON = JSON.serialize(imsTPAPurpDiscList);
        String amaJSON = JSON.serialize(amaSub);
        
        //Added by C.P.Pandey under ER-2654 start
        List<TPA_Use_Offerings_UI_Backup__c> useOffListToInsert = new List<TPA_Use_Offerings_UI_Backup__c>();
        TPA_Use_Offerings_UI_Backup__c useOffObjToInsert = new TPA_Use_Offerings_UI_Backup__c(Details__c = ' edited', Country__c = 'Test', GUID__c = 'Test', Offerings_Selected__c = 'Test', Use_Name_with_Id__c = 'Test', TPA_Request__c = tpaRequest.Id);
        useOffListToInsert.add(useOffObjToInsert);
        //CNT_TPA_RequestSubmissionForm.backupUseOffering(Json.serialize(useOffListToInsert));
        insert useOffObjToInsert;
        string useOffBackupIdsJSON = '' + useOffObjToInsert.Id;
        //Added by C.P.Pandey under ER-2654 end
        
        //Getting profile id for TP Processor Profile
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP%' Limit 1];//Updated by Babita Dadarwal under ER-3552
        system.debug('profile: '+p);
        
        //Creating User with TP Processor profile
        User user = new User(Alias = 'standt', Email='standarduser123@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',
                             ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@testing123.com',
                             TimeZoneSidKey='America/Los_Angeles', ContactId = con.id);
        System.runAs(user){
        //Calling save request method where requestTypeSubmitted is NewRequest
        String tpaRequestDetailsJSON = '{"tpaRequest" : '+tpaRequestJSON+', "requestTypeSubmitted" : "NewRequest", "tpaAdditionalContactList" : '+tpaContactListJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+', "isVendorContactInvited" : true, "vendorName" : "Sunny", "vendorContactName" : "Bansal", "invitedContact" : '+con.id+'}';
        String returnValue;
        try{
            returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON);
            System.assertNotEquals(null, returnValue);}
        catch(Exception e){}

        
        
        
        //Calling save request method where requestTypeSubmitted is ClientSubmit
        String tpaRequestJSON2 = JSON.serialize(tpaRequest);
        String tpaRequestDetailsJSON2 = '{"tpaRequest" : '+tpaRequestJSON2+', "requestTypeSubmitted" : "ClientSubmit", "tpaAdditionalContactList" : '+tpaContactListJSON+', "listSaved" : '+listSavedATCJSON+', "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+ ', "useOffBackupIds":"' + useOffBackupIdsJSON + '"' + '}';//Added by C.P.Pandey under ER-2654
        try{
            returnValue = CNT_TPA_RequestSubmissionForm.saveRequest(tpaRequestDetailsJSON2);
            //System.assertNotEquals(null, returnValue);
        }
        catch(Exception e){}
        //Calling save request method where requestTypeSubmitted is VendorSubmit
        String tpaRequestDetailsJSON3 = '{"tpaRequest" : '+tpaRequestJSON2+',"secondarypurpose":'+secondarypurposeJSON+',"amaAgrSubmitted":'+amaJSON+' ,"tpaAdditionalVendorContactListJSON" :'+tpaAdditionalVendorContactListJSON+', "requestTypeSubmitted" : "VendorSubmit", "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
        TPA_Multilingual_Template_Setting__c tpaMultiTempSetting = new TPA_Multilingual_Template_Setting__c(Name = 'FieldsAsException_LegacyId', 
                                                                                                            Label__c = 'FieldsAsException', 
                                                                                                            Translated_Template_Name__c = 'Legacy_Id__c');
        insert tpaMultiTempSetting;
        try{
            CNT_TPA_RequestSubmissionForm.tpProcessorSubmission(tpaRequestDetailsJSON3, 'en_US', UTL_LogFactory.Guid);
            CNT_TPA_RequestSubmissionForm.vendorSubmission(tpaRequestDetailsJSON3, 'en_US', UTL_LogFactory.Guid);
            CNT_TPA_RequestSubmissionForm.vendorSubmissionNotification(tpaRequest);
            tpaRequest.Copy_Additional_Vendor_Contacts__c = 'Yes';
            tpaRequestJSON2 = JSON.serialize(tpaRequest);
            tpaRequestDetailsJSON3 = '{"tpaRequest" : '+tpaRequestJSON2+', "tpaAdditionalVendorContactList" :'+tpaAdditionalVendorContactListJSON+', "requestTypeSubmitted" : "VendorSubmit", "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
            CNT_TPA_RequestSubmissionForm.updateAdditionalVendorContacts((CNT_TPA_RequestSubmissionForm.tpaRequestDetails)JSON.deserialize(tpaRequestDetailsJSON3, CNT_TPA_RequestSubmissionForm.tpaRequestDetails.class));
            TPA_Text_Editor__c textEditorData = new TPA_Text_Editor__c(Content__c = '<Strong><u>Offerings</u>', English_Translation__c = 'Test', Page_Name__c = 'Offering Notification');
            insert textEditorData;
           // CNT_TPA_RequestSubmissionForm.dynamicOfferingsNotificationList = new List<TPA_Text_Editor__C>{textEditorData};
            CNT_TPA_RequestSubmissionForm.mapOfIdWithTextEditorObj = new Map<ID, TPA_Text_Editor__C>{textEditorData.Id => textEditorData};
            CNT_TPA_RequestSubmissionForm.getdynamicOfferingsNotifications();
            CNT_TPA_RequestSubmissionForm controller = new CNT_TPA_RequestSubmissionForm();
            controller.isClientFromUS = true;
            Address__c testAddress = UTL_TPA_SetupTestData.getAddress();
            insert testAddress;
            tpaRequestDetailsJSON3 = '{"tpaRequest" : '+tpaRequestJSON2 +', "tpaAdditionalVendorContactList" :'+tpaAdditionalVendorContactListJSON+', "clientAddress" :"'+testAddress.Id +'", "secondarypurpose":'+secondarypurposeJSON+',"amaAgrSubmitted":'+amaJSON+' ,"tpaAdditionalVendorContactListJSON" :'+tpaAdditionalVendorContactListJSON+', "requestTypeSubmitted" : "ClientSubmit", "isPublicPrivateChangeOnly" : false, "tpaAdditionalContactList" : '+tpaContactListJSON+', "tpaSubContractors" : '+tpaSubContractorsListJSON+', "authorizedSignerResponse" : "Yes", "categorypurposesList" : '+imsTpaPurposecategoryListJSON+', "SelectedDescMap" : '+SelectedDescMapJSON+', "PurposeMap" : '+purposesMapJSON+', "PurposeMapOther" : '+purposesOtherMapJSON+', "MapPurpDesc" : '+purpDescMapJSON+', "MapPurpDescOther" : '+purpDescOtherMapJSON+', "mapPurposeidWithDataAssetMap" : '+mapPurposesIdWithDataAssetJSON+', "mapSecondayDataAssetToInsert" : '+mapSecondayDataAssetsToInsertJSON+'}';
            CNT_TPA_RequestSubmissionForm.tpProcessorSubmission(tpaRequestDetailsJSON3, 'en_US', UTL_LogFactory.Guid);


            
        }
        catch(Exception e){
            System.debug('exception-------> ' + e);
        }
        }
        Test.StopTest();
    }
    
    private static testmethod  void testgetVendorAccount() {
        CNT_TPA_RequestSubmissionForm.wrapperClassAssetPurpose wrapperClassAssetPurposeObj = new CNT_TPA_RequestSubmissionForm.wrapperClassAssetPurpose();
        
        wrapperClassAssetPurposeObj.categoryName = 'Test Category';
        wrapperClassAssetPurposeObj.translatedCategoryName = 'Test Transalte Category';
        wrapperClassAssetPurposeObj.otherPurposeId = 'Test Purpose';
        wrapperClassAssetPurposeObj.Param_otherDesc = 'Test Desc';
        wrapperClassAssetPurposeObj.purposeName = 'Test Purpose Name';
        wrapperClassAssetPurposeObj.translatedPurposeName = 'Test Translate Purpose';
        wrapperClassAssetPurposeObj.purposeId = 'purposeId';
        wrapperClassAssetPurposeObj.dataAsset = 'Test data Asset';
        wrapperClassAssetPurposeObj.dataAssetBackground = 'Data Asset Background';
        wrapperClassAssetPurposeObj.translatedDataAsset = 'translate';
        wrapperClassAssetPurposeObj.country = 'Country';
        wrapperClassAssetPurposeObj.selectDes = 'Des';
        wrapperClassAssetPurposeObj.isUseDefinitionfileExist = false;
        wrapperClassAssetPurposeObj.selectdataAssDetails = 'Data Asset Details';
        wrapperClassAssetPurposeObj.purposeCategoryId = 'CategoryId';
        wrapperClassAssetPurposeObj.useDefinitionPage = 'Use Defination';
        wrapperClassAssetPurposeObj.key = 'Key';
        wrapperClassAssetPurposeObj.selectedPurposeIds = 'selectedPurposeIds';
        wrapperClassAssetPurposeObj.dataAssetsInViewMode = 'View Mode';
        wrapperClassAssetPurposeObj.translatedDataAssetsInViewMode = 'AssetsInViewMode';
        wrapperClassAssetPurposeObj.offeringCategoryName = 'Offering Name';
        wrapperClassAssetPurposeObj.translatedOfferingCategoryName = 'CategoryName';
        wrapperClassAssetPurposeObj.selectdataAssforOfferingAdditionDetails = 'Selected Offereing';
        
        String globalBrandingName = JSON.serialize('a0A56000004rVC4EAM');
        List<Address__c> addrsList = CNT_TPA_RequestSubmissionForm.getVendorAccount(globalBrandingName);
        CNT_TPA_RequestSubmissionForm instanceOfRequestSubmissionForm = new CNT_TPA_RequestSubmissionForm();
        String language = instanceOfRequestSubmissionForm.getTLLALanguage();

    }

}
