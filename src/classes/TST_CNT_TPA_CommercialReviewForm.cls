@isTest(seeAllData = false)
private class TST_CNT_TPA_CommercialReviewForm {
    @TestSetup
    static void setupTestData(){
        Date todayDate = Date.today();
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createTPASettingData();
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        Account acc = new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        
        Address__c testAddrs = new Address__c(Name = 'TPA Test Acc', recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, CurrencyIsoCode = 'USD', Account__c = acc.Id, Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
        insert testAddrs;
        
        Contact  con = new Contact(FirstName = 'test', LastName = 'Vendor', Email = 'sunny.bansal@metacube.com', AccountId = acc.id);
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP%' Limit 1];
        
        User user = new User(Alias = 'standt', Email='standarduser123@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',
                             ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@testing123.com',
                             TimeZoneSidKey='America/Los_Angeles', ContactId = con.id);
        System.debug(UserInfo.getUserId());

        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), ClientContact__c = con.id, Client_Address__c =testAddrs.id, Client_Language__c = 'English', Data_Asset_List__c = 'AAN',
                                                       Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',AMA_USPrescriberData__c='Yes', Vendor_Website__c = 'test.html',
                                                       Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test', Data_Access_Start_Date__c = Date.today(),
                                                       Data_Access_End_Date__c = Date.today()+1,Data_Period_Start_Date__c = Date.today()-5,Data_Period_End_Date__c = Date.today());
        tpaRequest.Service_Provider_Address__c = testAddrs.id; 
        insert tpaRequest;
        
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = UTL_TPA_SetupTestData.getImsMasterLegalEntity();
        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        
        IMS_Data_Asset__c imsDataAsset1 = UTL_TPA_SetupTestData.createImsDataAssetWithName('Test IMS Data Asset 1');
        IMS_Data_Asset__c imsDataAsset2 = UTL_TPA_SetupTestData.createImsDataAssetWithName('Test IMS Data Asset Other');
        IMS_Secondary_Data_Asset__c imsSecondaryDA = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset1.id, Secondary_Asset_Name__c = 'Test IMS Secondary Data Asset', is_active__c = true, IMS_Legal_Entity__c = 'IQVIA Ltd.');
        insert imsSecondaryDA;
        
        IMS_Legal_Entity__c imsLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity(tpaRequest, imsMasterLegalEntity);
        List<TPA_Additional_Term__c> lstAdditionalTerms = new List<TPA_Additional_Term__c>();
        TPA_Additional_Term__c newAdditionalTerm1 = new TPA_Additional_Term__c(Name = 'Test',TPA_Legal_Entity_1__c = imsLegalEntity.Id, Addtional_Term__c = 'Test Term',
                                                                              Category__c = 'General Ad-Hoc Term', TPA_Request__c = tpaRequest.Id, Exhibit_Attached__c = true);
        lstAdditionalTerms.add(newAdditionalTerm1);
        TPA_Additional_Term__c newAdditionalTerm2 = new TPA_Additional_Term__c(Name = 'Test',TPA_Legal_Entity_1__c = imsLegalEntity.Id, Addtional_Term__c = 'Test Term', Exhibit_Attached__c = true,
                                                                              Category__c = 'Use/Offering Specific Ad-Hoc Terms', TPA_Request__c = tpaRequest.Id);
        lstAdditionalTerms.add(newAdditionalTerm2);
        TPA_Additional_Term__c newAdditionalTerm3 = new TPA_Additional_Term__c(Name = 'Test',TPA_Legal_Entity_1__c = imsLegalEntity.Id, Addtional_Term__c = 'Test Term', Exhibit_Attached__c = true, 
                                                                              Category__c = 'Use Specific Ad-Hoc Terms', TPA_Request__c = tpaRequest.Id);
        lstAdditionalTerms.add(newAdditionalTerm3);
        TPA_Additional_Term__c newAdditionalTerm4 = new TPA_Additional_Term__c(Name = 'Test',TPA_Legal_Entity_1__c = imsLegalEntity.Id, Addtional_Term__c = 'Test Term', Exhibit_Attached__c = true, 
                                                                              Category__c = 'Data Asset Specific Ad-Hoc Term', TPA_Request__c = tpaRequest.Id);
        lstAdditionalTerms.add(newAdditionalTerm4);
        insert lstAdditionalTerms;
         Attachment testAttachment = UTL_TPA_SetupTestData.addAttachmentToParent(newAdditionalTerm1.id, 'test Attachment');
        Attachment testAttachment2 = UTL_TPA_SetupTestData.addAttachmentToParent(newAdditionalTerm3.id, 'test Attachment');

        
        List<TPA_Commercial_Review__c> tpaCommercialReviewList = new List<TPA_Commercial_Review__c>();
        
        TPA_Commercial_Review__c comRev1 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        IMS_Legal_Entity__c = imsLegalEntity.id,
                                                                        Associated_Offering_to_Review__c = 'Oncology electronic medical records data', 
                                                                        Associated_Use_to_Review__c = 'Data Cleansing', 
                                                                        Manual_Review_Reason__c = 'Other Offering Selected',  
                                                                        Action_Needed_By__c = 'Commercial Owner', 
                                                                        TPA_Request__c = tpaRequest.Id, 
                                                                        TPA_Additional_Term__c = newAdditionalTerm3.id,
                                                                        Action__c = 'Under Validation', 
                                                                        Receiver_s_Email__c = 'test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = todayDate, 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev1);
        
        TPA_Commercial_Review__c comRev2 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        Associated_Offering_to_Review__c = 'test', 
                                                                        Associated_Use_to_Review__c = 'Data Cleansing', 
                                                                        Manual_Review_Reason__c = 'Other Offering Selected', 
                                                                        Action_Needed_By__c = 'TP-country', 
                                                                        TPA_Additional_Term__c = newAdditionalTerm4.id,
                                                                        TPA_Request__c = tpaRequest.Id, 
                                                                        Action__c = 'Assigned to Commercial Owner (CO) – Awaiting CO Review', 
                                                                        Receiver_s_Email__c = 'test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = todayDate, 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev2);
        
        TPA_Commercial_Review__c comRev3 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        Associated_Offering_to_Review__c = 'Xponent PlanTrak MIDAS Promo', 
                                                                        Associated_Use_to_Review__c = 'test', 
                                                                        Manual_Review_Reason__c = 'Other Use Selected',  
                                                                        Action_Needed_By__c = 'Commercial Owner', 
                                                                        Additional_Questions_For_TP_Processor__c = 'Question;',
                                                                        TPA_Request__c = tpaRequest.Id, 
                                                                        TPA_Additional_Term__c = newAdditionalTerm2.id,
                                                                        Receiver_s_Email__c = 'test@gmail.com',
                                                                        Action__c = 'Approved for this specific TPA. The Vendor and specified Use(s) and IQVIA Offerings specific combination can be auto-approved moving forward for future requests', 
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = todayDate, 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev3);
        
        TPA_Commercial_Review__c comRev4 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        Associated_Offering_to_Review__c = 'Patient Reference File', 
                                                                        Associated_Use_to_Review__c = 'test', 
                                                                        Manual_Review_Reason__c = 'Other Use Selected', 
                                                                        Action_Needed_By__c = 'Commercial Owner', 
                                                                        Status__c = 'Complete',
                                                                        TPA_Request__c = tpaRequest.Id, 
                                                                        TPA_Additional_Term__c = newAdditionalTerm1.id,
                                                                        Action__c = 'Assigned to Commercial Owner (CO) – Awaiting CO Review', 
                                                                        Receiver_s_Email__c = 'test1@gmail.com;test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = todayDate, 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev4);
        
        TPA_Commercial_Review__c comRev5 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        Associated_Offering_to_Review__c = 'TERRITORIAL', 
                                                                        Associated_Use_to_Review__c = 'test', 
                                                                        Manual_Review_Reason__c = 'Other Use', 
                                                                        Action_Needed_By__c = 'TP-US',
                                                                        Action__c = 'Questions / Comments',
                                                                        TPA_Request__c = tpaRequest.Id, 
                                                                        Receiver_s_Email__c = 'test1@gmail.com;test@gmail.com',
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = todayDate, 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev5);
        TPA_Commercial_Review__c comRev6 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                                                        Associated_Offering_to_Review__c = 'MIDAS', 
                                                                        Associated_Use_to_Review__c = 'aTest TPA Purpose', 
                                                                        Manual_Review_Reason__c = 'Offering Requires Secondary Commercial Review', 
                                                                        Action_Needed_By__c = 'TP-US',
                                                                        TPA_Request__c = tpaRequest.Id, 
                                                                        Status__c = 'Awaiting to Send: Primary Commercial Owner Not Complete', 
                                                                        TP_US_Email__c = UserInfo.getUserEmail(), 
                                                                        Date_of_Action_Response__c = todayDate, 
                                                                        TP_Country_Email__c = 'test@gmail.com');
        tpaCommercialReviewList.add(comRev6);
        
        insert tpaCommercialReviewList;
        
        
        AMA_Contract_Detail__c amaContract1 = new AMA_Contract_Detail__c(Client__c = 'TPA Test Acc', Client_Services_On_Behalf_Of__c = '(Own Behalf)'
                                                                         ,Contract_End_Date__c = Date.newInstance(2015, 10, 20), Contract_List_Type__c = 'Client'
                                                                         ,Contract_Type__c = 'Service Bureau II', DBL__c = 'DMD', Max_Fee_Reached__c = False
                                                                         ,Offshore_Approval__c = true,Offshore_Storage__c = 'India;(ISO-3)Canada');
        
        insert amaContract1;
        
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(tpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        amaAgg.Client_Employee_Store_Data_in_country__c = 'India;Canada';
        amaAgg.Vendor_require_Remote_Access_from_NonUS__c = 'Yes';
        amaAgg.Vendor_Employee_Accessed_Data_in_country__c = 'India';
        amaAgg.Is_AMA_License_Required__c = true;
        insert amaAgg;
        

        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose', tpaRequest, tpaPurposeCategory, imsTpaPurpose, imsLegalEntity);
        TPA_Data_Asset__c tpaDataAsset1 = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest, tpaPurpose, imsDataAsset1, imsLegalEntity);
        TPA_Data_Asset__c tpaDataAsset2 = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset2.id,BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        insert tpaDataAsset2;
        System.debug('Test Data Asset : ' + tpaDataAsset2?.Asset_Name__c);
        TPA_Secondary_Data_Asset__c tpaSecDataAsset = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset1, imsSecondaryDA, imsLegalEntity, tpaRequest, 'Test TPA Secondary data Asset');
        
        List<TPA_Text_Editor__c> textEditorRecord = new List<TPA_Text_Editor__c>();
        TPA_Text_Editor__c textEd1 = new TPA_Text_Editor__c( Page_Name__c = 'Test Page',  Page_Title__c = 'Alphabetical Summary of Permitted Use Definitions', Page_Type__c = 'Permitted Use Definitions Summary' , content__c = '<div><p>Test Content for Text Editor</p></div>');
        TPA_Text_Editor__c textEd2 = new TPA_Text_Editor__c( Page_Name__c = 'Test Page2',  Page_Title__c = 'Shutdown Message', Page_Type__c = 'Shutdown Message' , content__c = '<div><p>Shut Down Message</p></div>', is_active__c = true);
        TPA_Text_Editor__c textEd3 = new TPA_Text_Editor__c( Page_Name__c = 'Test Commercial Review',  Page_Title__c = 'Commercial Review', Page_Type__c = 'Commercial Review Reasons Types' , content__c = 'Commercial Review', is_active__c = true);
        textEditorRecord.add(textEd3);
        textEditorRecord.add(textEd1);
        textEditorRecord.add(textEd2);
        insert textEditorRecord;
        
        String testlink = CNT_TPA_CommercialReviewForm.ComOwnnerChangeFormLink;
        CNT_TPA_CommercialReviewForm cntTPA = new CNT_TPA_CommercialReviewForm();
        cntTPA.getLegalEntityList();
        String testMessage = cntTPA.Message;
        cntTPA.getObjectMapOfIdWithTextEditorObj();
        cntTPA.getObjectTpaRequestToEdit();
        
        Boolean isProcessorLogin = cntTPA.isTPProcessorLogin;
        String testVendorLegalName = CNT_TPA_CommercialReviewForm.vendorLegalName;
        test_VFProperties();
    }
    
    static void test_VFProperties(){
        // Review Later
        CNT_TPA_CommercialReviewForm.getMailsToCompare('test@test.com;test@test.in');
        String AlphabeticalRecord = CNT_TPA_CommercialReviewForm.permittedUseDefSummary;
        STring dateVal = CNT_TPA_CommercialReviewForm.latestAMAContractDate;
        
    }
    
    @isTest static void test_requestValidationOnLoadForCommercial(){
        ApexPages.currentPage().getParameters().put('viewMode', 'CSubmit');
        ApexPages.currentPage().getParameters().put('CSId', 'test1@test.com;test@test.com');
        CNT_TPA_CommercialReviewForm cntTPA = new CNT_TPA_CommercialReviewForm();
        Boolean isProcessorLogin = cntTPA.isTPProcessorLogin;
            Integer count = CNT_TPA_CommercialReviewForm.countOfRecords;
        system.debug(ApexPages.currentPage().getParameters());
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Address__c addrs = [select id from Address__c where Name = 'TPA Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Vendor' limit 1];
        
        Address__c testClient = UTL_TPA_SetupTestData.getBlankAccount();
        testClient.Name = 'test Vendor';
        testClient.is_TPA_Account__c = true;
        testClient.Street__c = 'test';
        testClient.City__c = 'test';
        testClient.Country__c = 'test';
        testClient.PostalCode__c = 'test';
        testClient.AMA_Special_Handling__c = true;
        insert testClient;
        
        insert new Watch_List__c( Always_Approved__c = false, Vendor_Address__c = testClient.id, 
                                 Data_Asset_Category__c = 'Expert Analysis', Offering__c = 'MIDAS', Use__c = 'aTest TPA Purpose', country_of_Offering__c = 'United States');
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP%' Limit 1];
        Date todayDate = Date.today();
        
        User user = new User(Alias = 'standt', Email='standarduser123@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',
                             ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@testing123.com',
                             TimeZoneSidKey='America/Los_Angeles', ContactId = con.id);
        
        TPA_Request__c tpaRequest = [select id, Service_Provider_Address__c,Service_Provider_Address__r.Parent_Vendor_Name__c, Pending_Acknowledgements__c, Request_Status__c from TPA_request__c Limit 1];
        tpaRequest.Service_Provider_Address__c = testClient.id;
        tpaRequest.Pending_Acknowledgements__c = 'Pending Commercial Review Acknowledgements';
        tpaRequest.Request_Status__c = 'In Review by IQVIA';
        update tpaRequest;
        ApexPages.currentPage().getParameters().put('id', tpaRequest.id);
        String otherDataAssetKey = CNT_TPA_CommercialReviewForm.otherDataAssetsKeys;
        List<TPA_Commercial_Review__c> comRevList = [select Id, Commercial_Owner_Name__c, Is_ReviewForm_Acknowledged__c, Associated_Offering_to_Review__c, Associated_Use_to_Review__c, Manual_Review_Reason__c, Receiver_s_Email__c, Action_Needed_By__c, TPA_Request__c, Action__c, Status__c, TP_US_Email__c, Date_of_Action_Response__c, Additional_Questions_For_TP_Processor__c, TP_Country_Email__c from TPA_Commercial_Review__c where TPA_Request__c = :tpaRequest.id ORDER BY Associated_Use_to_Review__c ];
        if(comRevList.size() > 0){
            String userProfileName = CNT_TPA_CommercialReviewForm.currentUserProfileName;
            String tpaCommunityUrl = CNT_TPA_CommercialReviewForm.tpaCommunityUrl;
            CNT_TPA_CommercialReviewForm.getRelatedComList(tpaRequest.id,'test@gmail.com;test1@gmail.com','CSubmit',null,UserInfo.getUserEmail(),null,null);
            
            Test.startTest();
            PageReference pageRef = Page.VFP_TPA_CommercialReviewForm;
            pageRef.getParameters().put('id', tpaRequest.Id);
            System.debug(comRevList[0].Receiver_s_Email__c);
            pageRef.getParameters().put('CSId', comRevList[0].Receiver_s_Email__c);
            pageRef.getParameters().put('viewMode', 'CSubmit');
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(tpaRequest);
            CNT_TPA_CommercialReviewForm  comFormController = new CNT_TPA_CommercialReviewForm(sc);
            CNT_TPA_CommercialReviewForm.validClientNameSet.add('tpa test acc');
            comFormController.requestValidateOnLoad();
            comFormController.getObjectMapTpaTextAdditionalTerms();
            comFormController.getObjectMapTpaAdditionalTerms();
            comFormController.getObjectMapTpaDynamicNotifications();
            String comRevJson1 = JSON.serialize(comRevList);
            System.debug('The List: ' + comrevJson1);
            String Key = comRevList[0].Associated_Use_to_Review__c + comRevList[0].Associated_Offering_to_Review__c;
            CNT_TPA_CommercialReviewForm.createUpdateWatchList(tpaRequest, new Set<String>{Key});
            CNT_TPA_CommercialReviewForm.saveRequest(comRevJson1, comRevList[0].Commercial_Owner_Name__c,'test@gmail.com','test1@gmail.com');
            //Integer count = CNT_TPA_CommercialReviewForm.countOfRecords;
            String countries = CNT_TPA_CommercialReviewForm.employeeStoreDataCountry;
            countries = CNT_TPA_CommercialReviewForm.employeeAccessDataCountry;
            Boolean ext = CNT_TPA_CommercialReviewForm.extensionRecCommercialReason;
            Test.stopTest();
        }
    }

    @isTest static void test_requestValidationOnLoadForTpProcessor(){
        ApexPages.currentPage().getParameters().put('viewMode', 'TPSubmit');
        Integer recordCount = CNT_TPA_CommercialReviewForm.countOfRecords;
        
        Account acc =  [select id from account where Name = 'Test Acc' limit 1];
        Address__c addrs = [select id from Address__c where Name = 'TPA Test Acc' limit 1];
        Contact con =  [select id from contact where LastName = 'Vendor' limit 1];
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP%' Limit 1];
        Date todayDate = Date.today();
        
        User user = new User(Alias = 'standt', Email='standarduser123@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',
                             ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@testing123.com',
                             TimeZoneSidKey='America/Los_Angeles', ContactId = con.id);
        
        TPA_Request__c tpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(), ClientContact__c = con.id, Client_Language__c = 'English', Data_Asset_List__c = 'AAN',
                                                       Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test', AMA_USPrescriberData__c = 'Yes',
                                                       Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test',Data_Access_Start_Date__c = Date.today(),
                                                       Data_Access_End_Date__c = Date.today()+1,Data_Period_Start_Date__c = Date.today()-5,Data_Period_End_Date__c = Date.today());
        tpaRequest.Service_Provider_Address__c = addrs.id;                                               
        insert tpaRequest;
        
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(tpaRequest.Id);
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = 'Greater than 90 days';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Annual';
        amaAgg.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c = 'Prescriber Recruitment';
        amaAgg.Client_Employee_Store_Data_in_country__c = 'India;Canada';
        amaAgg.Is_AMA_License_Required__c = true;
        insert amaAgg;
        
        List<TPA_Text_Editor__c> textEditorList = new List<TPA_Text_Editor__c>();
        
        TPA_Text_Editor__c tpaUseDefinition3 = new TPA_Text_Editor__c(Page_Name__c = 'is_Managed_Workbook__c', Content__c = 'Test Offerings Notification 3', Page_Title__c = 'is_Managed_Workbook__c', Page_Type__c = 'IMS_Legal_Entity__C');
        textEditorList.add(tpaUseDefinition3) ;
        
        TPA_Text_Editor__c tpaUseDefinition4 = new TPA_Text_Editor__c(Page_Name__c = 'is_GE_Centricity_EMR__c', Content__c = 'Test Offerings Notification 4', Page_Title__c = 'is_GE_Centricity_EMR__c', Page_Type__c = 'IMS_Legal_Entity__C');
        textEditorList.add(tpaUseDefinition4) ;
        
        TPA_Text_Editor__c tpaUseDefinition5 = new TPA_Text_Editor__c(Page_Name__c = 'is_Promotrak__c', Content__c = 'Test Offerings Notification  4', Page_Title__c = 'is_Promotrak__c', Page_Type__c = 'IMS_Legal_Entity__C');
        textEditorList.add(tpaUseDefinition5) ;
        
        TPA_Text_Editor__c tpaUseDefinition6 = new TPA_Text_Editor__c(Page_Name__c = 'is_Midas__c', Content__c = 'Test Offerings Notification  4', Page_Title__c = 'is_Midas__c', Page_Type__c = 'IMS_Legal_Entity__C');
        textEditorList.add(tpaUseDefinition6) ;
        
        TPA_Text_Editor__c tpaUseDefinition7 = new TPA_Text_Editor__c(Page_Name__c = 'Is_Oncology_EMR__c', Content__c = 'Test Offerings Additional Terms', Page_Title__c = 'Is_Oncology_EMR__c', Page_Type__c = 'IMS_Legal_Entity__c');
        textEditorList.add(tpaUseDefinition7) ;
        
        insert textEditorList;
        
        IMS_Legal_Entity__C imsLegalEntity = new IMS_Legal_Entity__C();
        imsLegalEntity.TPA_Request__c = tpaRequest.Id;
        imsLegalEntity.is_Midas__c = true;
        imsLegalEntity.is_Patient_Reference_File__c = true;
        imsLegalEntity.is_GE_Centricity_EMR__c = true;
        imsLegalEntity.is_Promotrak__c = true;
        imsLegalEntity.is_Managed_Workbook__c = true;
        imsLegalEntity.Is_Glbl_PromoTrack_Selected__c = true;
        imsLegalEntity.is_South_Africa_Consumer_Health__c = true;
        imsLegalEntity.IS_Health_Plan_Claims__c = true;
        imsLegalEntity.is_Patient_Companion_File__c = true;
        imsLegalEntity.is_Provider_Companion_File__c = true;
        imsLegalEntity.is_Payer_Companion_File__c = true;
        imsLegalEntity.is_LAAD_Offering__c = true;
        imsLegalEntity.Is_Oncology_EMR__c = true;
        imsLegalEntity.Is_Ambulatory_EMR__c = true;
        imsLegalEntity.is_Xponent_or_OneKey__c = true;
        imsLegalEntity.is_Canada__c = true;
        imsLegalEntity.containUS__c = true;
        imsLegalEntity.isDDDOffering__c = true;
        imsLegalEntity.is_Xponent__c = true;
        
        insert imsLegalEntity;
        TPA_Text_Editor__c tpaUseDefinition = new TPA_Text_Editor__c(Page_Name__c = 'IS_Health_Plan_Claims__c', Content__c = 'Test Offerings Additional Terms', Page_Title__c = 'IS_Health_Plan_Claims__c', Page_Type__c = 'IMS_Legal_Entity__c');
        insert tpaUseDefinition;
        List<TPA_Additional_Term__c> addocList = new List<TPA_Additional_Term__c>();
        TPA_Additional_Term__c addTerm = new TPA_Additional_Term__c(Name = 'name', Addtional_Term__c  = 'test123',Primary_Offering_Name__c = 'MIDAS Promo', Category__c = 'Data Asset Specific Ad-Hoc Term', TPA_Request__c =tpaRequest.Id );
        addocList.add(addTerm);
        TPA_Additional_Term__c addTerm1 = new TPA_Additional_Term__c(Name = 'name2', Addtional_Term__c  = 'test1234', Category__c = 'General Ad-Hoc Term', TPA_Request__c =tpaRequest.Id );
        addocList.add(addTerm1);
        TPA_Additional_Term__c addTerm2 = new TPA_Additional_Term__c(Name = 'name2', Addtional_Term__c  = 'test1234', Category__c = 'Use/Offering Specific Ad-Hoc Terms', TPA_Request__c =tpaRequest.Id );
        addocList.add(addTerm2);
        TPA_Additional_Term__c addTerm3 = new TPA_Additional_Term__c(Name = 'name2', Addtional_Term__c  = 'test1234', Category__c = 'Use Specific Ad-Hoc Terms', TPA_Request__c =tpaRequest.Id );
        addocList.add(addTerm3);
        insert addocList;
        
        List<TPA_Commercial_Review__c> comRevList = [select Id, Commercial_Owner_Name__c, Is_ReviewForm_Acknowledged__c, Associated_Offering_to_Review__c, Associated_Use_to_Review__c, Manual_Review_Reason__c, Receiver_s_Email__c, Action_Needed_By__c, TPA_Request__c, Action__c, Status__c, TP_US_Email__c, Date_of_Action_Response__c, Additional_Questions_For_TP_Processor__c, TP_Country_Email__c from TPA_Commercial_Review__c limit 4];
        if(comRevList.size() > 0){
            String userProfileName = CNT_TPA_CommercialReviewForm.currentUserProfileName;
            String tpaCommunityUrl = CNT_TPA_CommercialReviewForm.tpaCommunityUrl;
            TPA_Commercial_Review__c comRev1 = new TPA_Commercial_Review__c( 
                Associated_Offering_to_Review__c = 'MIDAS Promo Xponent', 
                Associated_Use_to_Review__c = 'Data Cleansing', 
                Manual_Review_Reason__c = 'Other Offering Selected', 
                Action_Needed_By__c = 'TP-country', 
                TPA_Request__c = tpaRequest.Id, 
                Action__c = 'Under Validation', 
                TP_US_Email__c = UserInfo.getUserEmail(),
                Receiver_s_Email__c = 'test@gmail.com',
                Date_of_Action_Response__c = todayDate, 
                TP_Country_Email__c = 'test@gmail.com',
                Commercial_Owner_Name__c = 'shaik',
                TPA_Additional_Term__c = addTerm.Id);
            insert comRev1;
            
            Test.startTest();
            PageReference pageRef = Page.VFP_TPA_CommercialReviewForm;
            pageRef.getParameters().put('id', tpaRequest.Id);
            pageRef.getParameters().put('TPCountryId', comRev1.TP_Country_Email__c);
            pageRef.getParameters().put('viewMode', 'TPSubmit');
            
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(tpaRequest);
            CNT_TPA_CommercialReviewForm  comFormController = new CNT_TPA_CommercialReviewForm(sc);
            comFormController.requestValidateOnLoad();
            String message2 = comFormController.Message;
            String comRevJson1 = JSON.serialize(comRevList);
            map<String, TPA_Text_Editor__C> mapOfIdWithTextEditorObjs = CNT_TPA_CommercialReviewForm.mapOfIdWithTextEditorObjs;
            Map<String, TPA_Text_Editor__c> mapTpaTextAdditionalTerms = CNT_TPA_CommercialReviewForm.mapTpaTextAdditionalTerms;
            Map<String, TPA_Additional_Term__c> mapTpaAdditionalTerms = CNT_TPA_CommercialReviewForm.mapTpaAdditionalTerms;
            Map<String , TPA_Offering_Notification_Mapping__c> mapTpaDynamicNotifications = CNT_TPA_CommercialReviewForm.mapTpaDynamicNotifications;
            CNT_TPA_CommercialReviewForm cntTPA = new CNT_TPA_CommercialReviewForm();
            String objectTPAEditorList = cntTPA.getObjectMapOfIdWithTextEditorObj();
            Boolean isRestrictedUser = cntTPA.isRestrictedUser;
            String commercialOwnerName = cntTPA.commercialOwnerName;
            Boolean isvalidVendorAccessCountry = cntTPA.isvalidVendorAccessCountry;
            Boolean isPreAppTech = cntTPA.isPreAppTech;
            Boolean isvalidVendorStorageCountry = cntTPA.isvalidVendorStorageCountry;
            
            CNT_TPA_CommercialReviewForm.getRelatedComList(tpaRequest.id,'test@gmail.com','TPSubmit',null,UserInfo.getUserEmail(),null,null);
            CNT_TPA_CommercialReviewForm.saveRequest(comRevJson1, comRev1.Commercial_Owner_Name__c,'test@gmail.com' ,'test1@gmail.com');
            Integer count = CNT_TPA_CommercialReviewForm.countOfRecords;

        }
    }
    
    @isTest static void test_requestValidationOnLoadForUSTpProcessor(){
        ApexPages.currentPage().getParameters().put('viewMode', 'TPUS');
        Integer recordCount = CNT_TPA_CommercialReviewForm.countOfRecords;
        TPA_Request__c tpaRequest = [Select Id,Name From TPA_Request__c];
        
        Test.startTest();
        PageReference pageRef = Page.VFP_TPA_CommercialReviewForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('TPUSId', UserInfo.getUserEmail());
        pageRef.getParameters().put('viewMode', 'TPUS');
        CNT_TPA_CommercialReviewForm.getRelatedComList(tpaRequest.id,'test@gmail.com','TPUS',null,UserInfo.getUserEmail(),null,null);
        
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(tpaRequest);
        CNT_TPA_CommercialReviewForm  comFormController = new CNT_TPA_CommercialReviewForm(sc);
        comFormController.requestValidateOnLoad();
        comFormController.getObjectTpaRequestToEdit();
        comFormController.getObjectTpaCommercialReviewList();
        String permittedUseDefSummaryContent = CNT_TPA_CommercialReviewForm.permittedUseDefSummary;
        String baseURL = CNT_TPA_CommercialReviewForm.baseURL;
        Assert.areEqual(permittedUseDefSummaryContent,'Test Content for Text Editor');
        Test.stopTest();
    }
    
     @isTest static void test_requestValidationOnLoadForAMAAdmin(){
        ApexPages.currentPage().getParameters().put('viewMode', 'AMAAdmin');
        Integer recordCount = CNT_TPA_CommercialReviewForm.countOfRecords;
        TPA_Request__c tpaRequest = [Select Id,Name From TPA_Request__c];
        
        Test.startTest();
        PageReference pageRef = Page.VFP_TPA_CommercialReviewForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        pageRef.getParameters().put('AMAAdminId', UserInfo.getUserEmail());
        pageRef.getParameters().put('viewMode', 'AMAAdmin');
        CNT_TPA_CommercialReviewForm.getRelatedComList(tpaRequest.id,'test@gmail.com','AMAAdmin',null,UserInfo.getUserEmail(),null,null);
        
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(tpaRequest);
        CNT_TPA_CommercialReviewForm  comFormController = new CNT_TPA_CommercialReviewForm(sc);
        comFormController.requestValidateOnLoad();
        comFormController.getObjectTpaRequestToEdit();
        comFormController.getObjectTpaCommercialReviewList();
        String permittedUseDefSummaryContent = CNT_TPA_CommercialReviewForm.permittedUseDefSummary;
        String baseURL = CNT_TPA_CommercialReviewForm.baseURL;
        Assert.areEqual(permittedUseDefSummaryContent,'Test Content for Text Editor');
        Test.stopTest();
    }
    
    
}