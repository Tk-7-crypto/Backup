@isTest(seeAllData = false)
public class TST_QBL_TPA_getManualReviewReasons {
    private static TPA_Request__c tpaReq1;
    private static Contact con;
    private static Account acc;
    private static Address__c account;
    private static Address__c testAccount;
    private static String TEST_REGION = 'US';
    private static TPA_Contact__c tpaContact;
    private static IMS_TPA_Purpose__c imsPurpose1;
    private static TPA_Purpose__c tpaPurpose1;
    private static TPA_Purpose__c tpaPurpose2;
    private static TPA_Purpose__c tpaPurpose3;
    private static IMS_TPA_Purpose_Description__c imsPurposeDescription1;
    private static TPA_Purpose_Description__c tpaPurposeDescription1;
    private static TPA_Purpose_Description__c tpaPurposeDescription2;
    private static TPA_Purpose_Category__c purposeCategory1;
    private static IMS_Data_Asset__c imsDataAss1;
    private static IMS_Data_Asset__c imsDataAss2;
    private static IMS_Data_Asset__c imsDataAss3;
    private static TPA_Data_Asset__c tpaDataAss1;
    private static TPA_Data_Asset__c tpaDataAss2;
    private static TPA_Data_Asset__c tpaDataAss3;
    private static TPA_Data_Asset__c tpaDataAss4;
    private static IMS_Secondary_Data_Asset__c imsSecondaryDataAss1;
    private static IMS_Secondary_Data_Asset__c imsSecondaryDataAss2;
    private static TPA_Secondary_Data_Asset__c tpaSecondaryDataAss1;
    private static TPA_Secondary_Data_Asset__c tpaSecondaryDataAss2;
    private static TPA_Secondary_Data_Asset__c tpaSecondaryDataAss3;
    private static Boolean isAwaitingClientConfirmationMailReq = false;
    
    public static testMethod void test_QBL_TPA_getManualReviewReasons()
    {
        String SuppLangCodeFieldNameLocalNameTest  = UTL_TPA_Multilingual.SuppLangCodeFieldNameLocalName;
        Map<String, String> supportedLanguageMaptest = new Map<String, String>();
        supportedLanguageMaptest.put('en_US' , 'English~English_Translation__c~English');
        
        QBL_TPA_getManualReviewReasons queuableObject = new QBL_TPA_getManualReviewReasons();
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 3];
        TPA_Request__c objTpaReq = SRV_TPA_TPARequest.getRequestInfo(requestList[0].id);
        queuableObject.request = objTpaReq ;
        queuableObject.langFieldName = supportedLanguageMaptest.get('en_US').split('~')[1];
        queuableObject.multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{supportedLanguageMaptest.get('en_US').split('~')[1]});
        queuableObject.type = objTpaReq.Request_Type__c;
        queuableObject.requestNumber = objTpaReq.Parent_Request__r.Name;
        queuableObject.isAwaitingClientConfirmationMailReq = SRV_TPA_TPARequest.isDynamicNotificationRequiredForVendor(objTpaReq);
        queuableObject.LastAction = objTpaReq.LastAction__c;
        queuableObject.authorizedSignerResponse = 'Yes';
        queuableObject.dynamicOfferingsNotificationListForVendor = SRV_TPA_TPARequest.dynamicOfferingsNotificationListForVendor;
        queuableObject.isDirectToClientExeMode = SRV_TPA_TPARequest.isDirectToClientExeMode;
        queuableObject.isQuintilesIMSSalesExeMode = SRV_TPA_TPARequest.isQuintilesIMSSalesExeMode;
        queuableObject.isVendorChecklistChanges = SRV_TPA_TPARequest.isVendorChecklistChanges;
        queuableObject.isdynamicOffNoticationReqOrNot = true;
        queuableObject.runType = 'VendorSubmission';
        Test.startTest();
        System.enqueueJob(queuableObject);
        Test.stopTest();
    }
    
     @TestSetup static void setup() {
        TST_QBL_TPA_getManualReviewReasons obj = new TST_QBL_TPA_getManualReviewReasons();
        UTL_TPA_SetupTestData.createTPASettingsData();
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createTpaTestEditorData('TPA Email Footer', 'Test', 'emailFooter', 'emailFooter');
        Date todayDate = Date.today();
        acc = new Account(Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acc;
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        account = UTL_TPA_SetupTestData.getBlankAccount();
        account.Name = 'Test Account veeva';
        account.Account__c = acc.Id;
        account.Vendor_Tier__c = 'Y';
        account.Is_Payment_Risk__c = true;
        account.Vendor_Registration_Number__c = 9999;
        account.is_TPA_Account__c = true;
        account.Street__c = 'test';
        account.City__c = 'test';
        account.Country__c = 'test';
        account.PostalCode__c = 'test';
        account.AMA_Check_List__c = 'Y';
        insert account;
        System.debug('2.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        con = UTL_TPA_SetupTestData.getContact();
        con.LastName = 'Test Contact';
        con.Email = 'test@test.com';
        con.AccountId = account.Account__c;
        insert con;
        System.debug('3.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // Create test tpa request
        tpaReq1 = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        tpaReq1.OwnerId = UserInfo.getUserId();
        tpaReq1.Client_Region__c = TEST_REGION;
        tpaReq1.Data_Provided_By__c = 'IQVIA in lieu of Client';
        tpaReq1.Is_Data_Accessed_Via_IMS_Software__c = 'Yes';
        tpaReq1.AMA_USPrescriberData__c = 'Yes';
        tpaReq1.Does_the_request_require_information_con__c = 'Yes';
        tpaReq1.Service_Provider_Address__c = account.Id;
        tpaReq1.Client_Address__c = account.Id;
        tpaReq1.ClientContact__c = con.Id;
        tpaReq1.Vendor_Company_Name__c = 'Test company';
        tpaReq1.Is_Potential_Vendor_Case__c = false;
        tpaReq1.TP_Processor_Email__c = 'a.a@g.com';
        tpaReq1.Authorized_Signer_Email__c = 'test@mail.com';
        tpaReq1.Data_Delivered_By__c = 'IQVIA Software';
        tpaReq1.Data_Access_Start_Date__c = Date.newInstance(2016, 10, 20);
        tpaReq1.Data_Access_End_Date__c = Date.newInstance(2017, 12, 31);
        tpaReq1.Is_Submitted__c = true;
        tpaReq1.Is_Manually_Approved__c = true;
        tpaReq1.Client_Off_Notification_Ack_Date__c = Date.newInstance(2017, 12, 31);
        tpaReq1.Is_Exhibit_Required__c = true;
        tpaReq1.Vendor_Language__c = 'Japanese';
        tpaReq1.Client_Language__c = 'English';
        insert tpaReq1;
        system.assert(tpaReq1.Id != null);
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        List<Attachment> lstAttachment = new List<Attachment>();
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(tpaReq1.Id, 'Vendor\'s Operation Guide.pdf'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(tpaReq1.Id, 'Offerings Notification Client.pdf'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(tpaReq1.Id, 'Protective Order for.pdf'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(tpaReq1.id, 'AMA_Original TPA- Offerings Notification Limited License Agreement'));
        
        insert lstAttachment;
        System.debug('5.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(tpaReq1.id);
        amaAgg.AMA_Manual_Review__c = false;
        amaAgg.Is_AMA_License_Required__c = true;
        amaAgg.Current_Year_Fees__c  = 21000;
        amaAgg.Contract_Type__c = 'Service Bureau II';
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016 , 10 ,20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c='Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c='Telemarketing;Labeling';
        amaAgg.Invoice_Contact_Email__c='testinvoice@gmail.com';
        insert amaAgg;
        System.debug('6.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        Watch_List__c watchObj = UTL_TPA_SetupTestData.createWatchList(tpaReq1.Service_Provider_Address__c);
        watchObj.Offering__c = 'Asset 1';
        watchObj.Use__c = 'test purpose';
        insert watchObj;
        System.debug('7.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // create test contact
        tpaContact = UTL_TPA_SetupTestData.getTestTPAContact(tpaReq1);
        tpaContact.Name = 'Initiator Contact';
        tpaContact.Company_Name__c = 'Test Company';
        tpaContact.Email__c = 'testcontact@apttus.com';
        tpaContact.Title__c = 'Test Manager';
        tpaContact.Phone__c = '408-123-5678';
        tpaContact.AddressLine1__c = '1400 Fashion Island Blvd';
        tpaContact.City__c = 'San Mateo';
        tpaContact.State__c = 'CA';
        tpaContact.ZipCode__c = '94404';
        insert tpaContact;
        system.assert(tpaContact.Id != null);
        System.debug('8.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // create test ims purpose
        imsPurpose1 = UTL_TPA_SetupTestData.getIMSTpaPurposeData();
        imsPurpose1.Name = 'test purpose';
        imsPurpose1.Purpose_Details__c = 'test purpose details';
        imsPurpose1.Consulting_Area__c = 'test consulting area';
        imsPurpose1.Business_Line__c = 'test business line';
        imsPurpose1.Primary_Purpose_Name__c = 'test purpose';
        insert imsPurpose1;
        system.assert(imsPurpose1.Id != null);
        System.debug('9.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // Create test TPA Purposes
        tpaPurpose1 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaReq1);
        tpaPurpose1.Name = 'test purpose';
        tpaPurpose1.Region__c = TEST_REGION;
        tpaPurpose1.Purpose__c = imsPurpose1.Id;
        tpaPurpose1.Prescriber_ID_Number__c = null;
        tpaPurpose1.Prescriber_ID_Number_Details__c = null;
        tpaPurpose1.PrescriberNPINumber__c = null;
        tpaPurpose1.PrescriberNPINumber_Details__c = null;
        tpaPurpose1.OutletReferenceFiles__c = null;
        tpaPurpose1.Other_Reference_File__c = null;
        tpaPurpose1.Other_Details__c = '';
        tpaPurpose1.Other_Text__c = '';
        tpaPurpose1.NCPDPIDorNPIOutletNumber__c = null;
        tpaPurpose1.NCPDPIDorNPIOutletNumber_Details__c = null;
        tpaPurpose1.Managed_Care__c = null;
        tpaPurpose1.Managed_Care_Details__c = null;
        tpaPurpose1.Linked_Data_Description__c = null;
        tpaPurpose1.IMSPrescriberIDNumber__c = null;
        tpaPurpose1.IMSPrescriberIDNumber_Details__c = null;
        tpaPurpose1.FinDr_ID__c = null;
        tpaPurpose1.Extended_Category_Codes__c = null;
        tpaPurpose1.Deliverables_Freq_To_Client__c = null;
        tpaPurpose1.Data_Usage__c = null;
        tpaPurpose1.Data_Assets__c = null;
        tpaPurpose1.Client_Deliverables__c = null;
        tpaPurpose1.Additional_Reference_Info__c = null;
        tpaPurpose1.AMABridgeFile__c = null;
        tpaPurpose1.AMABridgeFile_Details__c = null;
        System.debug('10.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaPurpose2 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaReq1);
        tpaPurpose2.Name = 'Other';
        tpaPurpose2.Region__c = TEST_REGION;
        tpaPurpose2.Purpose__c = imsPurpose1.Id;
        tpaPurpose2.Prescriber_ID_Number__c = null;
        tpaPurpose2.Prescriber_ID_Number_Details__c = null;
        tpaPurpose2.PrescriberNPINumber__c = null;
        tpaPurpose2.PrescriberNPINumber_Details__c = null;
        tpaPurpose2.OutletReferenceFiles__c = null;
        tpaPurpose2.Other_Reference_File__c = null;
        tpaPurpose2.Other_Details__c = '';
        tpaPurpose2.other_Text__c = 'Other use 1';
        tpaPurpose2.NCPDPIDorNPIOutletNumber__c = null;
        tpaPurpose2.NCPDPIDorNPIOutletNumber_Details__c = null;
        tpaPurpose2.Managed_Care__c = null;
        tpaPurpose2.Managed_Care_Details__c = null;
        tpaPurpose2.Linked_Data_Description__c = null;
        tpaPurpose2.IMSPrescriberIDNumber__c = null;
        tpaPurpose2.IMSPrescriberIDNumber_Details__c = null;
        tpaPurpose2.FinDr_ID__c = null;
        tpaPurpose2.Extended_Category_Codes__c = null;
        tpaPurpose2.Deliverables_Freq_To_Client__c = null;
        tpaPurpose2.Data_Usage__c = null;
        tpaPurpose2.Data_Assets__c = null;
        tpaPurpose2.Client_Deliverables__c = null;
        tpaPurpose2.Additional_Reference_Info__c = null;
        tpaPurpose2.AMABridgeFile__c = null;
        tpaPurpose2.AMABridgeFile_Details__c = null;
        System.debug('11.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaPurpose3 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaReq1);
        tpaPurpose3.Name = 'Expert Analysis for Legal or Governmental Purposes';
        tpaPurpose3.Region__c = TEST_REGION;
        tpaPurpose3.Purpose__c = imsPurpose1.Id;
        tpaPurpose3.Prescriber_ID_Number__c = null;
        tpaPurpose3.Prescriber_ID_Number_Details__c = null;
        tpaPurpose3.PrescriberNPINumber__c = null;
        tpaPurpose3.PrescriberNPINumber_Details__c = null;
        tpaPurpose3.OutletReferenceFiles__c = null;
        tpaPurpose3.Other_Reference_File__c = null;
        tpaPurpose3.Other_Details__c = '';
        tpaPurpose3.Other_Text__c = '';
        tpaPurpose3.NCPDPIDorNPIOutletNumber__c = null;
        tpaPurpose3.NCPDPIDorNPIOutletNumber_Details__c = null;
        tpaPurpose3.Managed_Care__c = null;
        tpaPurpose3.Managed_Care_Details__c = null;
        tpaPurpose3.Linked_Data_Description__c = null;
        tpaPurpose3.IMSPrescriberIDNumber__c = null;
        tpaPurpose3.IMSPrescriberIDNumber_Details__c = null;
        tpaPurpose3.FinDr_ID__c = null;
        tpaPurpose3.Extended_Category_Codes__c = null;
        tpaPurpose3.Deliverables_Freq_To_Client__c = null;
        tpaPurpose3.Data_Usage__c = null;
        tpaPurpose3.Data_Assets__c = null;
        tpaPurpose3.Client_Deliverables__c = null;
        tpaPurpose3.Additional_Reference_Info__c = null;
        tpaPurpose3.AMABridgeFile__c = null;
        tpaPurpose3.AMABridgeFile_Details__c = null;
        insert new List<TPA_Purpose__c> {tpaPurpose1, tpaPurpose2,tpaPurpose3};

        System.debug('10.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        
        //Create test purpose category
        purposeCategory1 = UTL_TPA_SetupTestData.getTpaPurposeCategory('Test Category');
        insert purposeCategory1;
        System.debug('12.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //Create test ims purpose description
        imsPurposeDescription1 = UTL_TPA_SetupTestData.getImsTpaPurpDes();
        imsPurposeDescription1.Description__c = 'Test Description';
        imsPurposeDescription1.Purpose__c = imsPurpose1.Id;
        imsPurposeDescription1.TPA_Purpose_Category__c = purposeCategory1.Id;
        imsPurposeDescription1.Requires_Manual_Review__c = True;
        insert imsPurposeDescription1;
        System.debug('13.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Legal_Entity__c imsLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity_Template();
        imsLegalEntity.Name = 'IQVIA Ltd.';
        imsLegalEntity.Legal_Entity_Name_for_TLLA__c = 'IQVIA Ltd.';
        imsLegalEntity.TPA_Request__c = tpaReq1.Id;
        insert imsLegalEntity;
        System.debug('14.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = UTL_TPA_SetupTestData.getImsMasterLegalEntity();
        imsMasterLegalEntity.Name = 'IQVIA Ltd.';
        update imsMasterLegalEntity;
        System.debug('15.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // create test IMS data assets
        imsDataAss1 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAss1.Region__c = TEST_REGION;
        imsDataAss1.Requires_Manual_Review__c = true;
        imsDataAss1.IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id;
        imsDataAss1.IMS_Legal_Entity__c = 'IQVIA Ltd.';
        imsDataAss1.Asset_Name__c = 'MIDAS';
        imsDataAss1.Additional_terms_required__c = true;
        System.debug('16.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        imsDataAss2 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAss2.Region__c = TEST_REGION;
        imsDataAss2.Is_Restricted_Data__c = True;
        imsDataAss2.Requires_Fee__c = True;
        imsDataAss2.Requires_Manual_Review__c = true;
        imsDataAss2.IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id;
        imsDataAss2.IMS_Legal_Entity__c = 'IQVIA Ltd.';
        imsDataAss2.Asset_Name__c = 'Managed Care Workbook - New View';
        System.debug('17.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        imsDataAss3 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAss3.Asset_Name__c = 'Other';
        imsDataAss3.Region__c = TEST_REGION;
        imsDataAss3.Is_Restricted_Data__c = True;
        imsDataAss3.Requires_Fee__c = True;
        imsDataAss3.Requires_Manual_Review__c = true;
        imsDataAss3.IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id;
        imsDataAss3.IMS_Legal_Entity__c = 'IQVIA Ltd.';
        insert new List<IMS_Data_Asset__c> {imsDataAss1, imsDataAss2, imsDataAss3};
        System.debug('18.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // Create test tpa purpose descriptions
        tpaPurposeDescription1 = UTL_TPA_SetupTestData.getTpaPurpDes();
        tpaPurposeDescription1.Purpose__c = tpaPurpose1.Id;
        tpaPurposeDescription1.Description__c = imsPurposeDescription1.Id;
        tpaPurposeDescription1.Requires_Manual_Review__c = imsPurposeDescription1.Requires_Manual_Review__c;
        System.debug('19.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaPurposeDescription2 = UTL_TPA_SetupTestData.getTpaPurpDes();
        tpaPurposeDescription2.Purpose__c = tpaPurpose2.Id;
        tpaPurposeDescription2.Description__c = imsPurposeDescription1.Id;
        tpaPurposeDescription2.Requires_Manual_Review__c = imsPurposeDescription1.Requires_Manual_Review__c;
        insert new List<TPA_Purpose_Description__c> {tpaPurposeDescription1, tpaPurposeDescription2};
        System.debug('20.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // create test TPA data assets
        tpaDataAss1 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose1.Id);
        tpaDataAss1.Request__c = tpaReq1.Id;
        tpaDataAss1.Region__c = TEST_REGION;
        tpaDataAss1.Data_Asset__c = imsDataAss1.Id;
        tpaDataAss1.BU__c = TEST_REGION;
        tpaDataAss1.Geo_Level__c = 'Real World Evidence';
        System.debug('21.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaDataAss2 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose2.Id);
        tpaDataAss2.Request__c = tpaReq1.Id;
        tpaDataAss2.Region__c = TEST_REGION;
        tpaDataAss2.Data_Asset__c = imsDataAss2.Id;
        tpaDataAss2.Is_Restricted_Data__c = imsDataAss2.Is_Restricted_Data__c;
        tpaDataAss2.BU__c = TEST_REGION;
        tpaDataAss2.Geo_Level__c = 'Anonymized Patient-Level Data / Transaction-Level';
        System.debug('22.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaDataAss3 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose3.Id);
        tpaDataAss3.Request__c = tpaReq1.Id;
        tpaDataAss3.Region__c = TEST_REGION;
        tpaDataAss3.Data_Asset__c = imsDataAss3.Id;
        tpaDataAss3.Is_Restricted_Data__c = imsDataAss3.Is_Restricted_Data__c;
        tpaDataAss3.Other_Data_Asset_Details__c = 'test';
        
        tpaDataAss4 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose3.Id);
        tpaDataAss4.Request__c = tpaReq1.Id;
        tpaDataAss4.Region__c = TEST_REGION;
        tpaDataAss4.Data_Asset__c = imsDataAss1.Id;
        tpaDataAss4.Is_Restricted_Data__c = imsDataAss1.Is_Restricted_Data__c;
        tpaDataAss4.BU__c = TEST_REGION;
        tpaDataAss4.Geo_Level__c = 'Reference Data';
        
        insert new List<TPA_Data_Asset__c> {tpaDataAss1, tpaDataAss2, tpaDataAss3,tpaDataAss4};
        System.debug('23.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        imsSecondaryDataAss1 = UTL_TPA_SetupTestData.getImsSecDataAsset();
        imsSecondaryDataAss1.Primary_Data_Asset__c = imsDataAss1.Id;
        imsSecondaryDataAss1.Requires_Manual_Review__c = true;
        imsSecondaryDataAss1.Is_Restricted_Data__c = true;
        imsSecondaryDataAss1.Secondary_Asset_Name__c = 'ims sec asset 1';
        System.debug('24.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        imsSecondaryDataAss2 = UTL_TPA_SetupTestData.getImsSecDataAsset();
        imsSecondaryDataAss2.Primary_Data_Asset__c = imsDataAss2.Id;
        imsSecondaryDataAss2.Requires_Manual_Review__c = true;
        imsSecondaryDataAss2.Is_Restricted_Data__c = true;
        imsSecondaryDataAss2.Secondary_Asset_Name__c = 'BrandImpact Custom Study Name & Project Delivery Date:';
        insert new List<IMS_Secondary_Data_Asset__c> {imsSecondaryDataAss1, imsSecondaryDataAss2};
        System.debug('25.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaSecondaryDataAss1 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAss1.TPA_Data_Asset__c = tpaDataAss1.Id;
        tpaSecondaryDataAss1.IMS_Secondary_Data_Asset__c = imsSecondaryDataAss1.id;
        tpaSecondaryDataAss1.Secondary_Asset_Name__c = 'Channel Dynamics Custom Study Name & Project Delivery Date:';
        tpaSecondaryDataAss1.Channel_Dynamics_Delivery_Date__c = Date.today();
        System.debug('26.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaSecondaryDataAss2 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAss2.TPA_Data_Asset__c = tpaDataAss2.Id;
        tpaSecondaryDataAss2.IMS_Secondary_Data_Asset__c = imsSecondaryDataAss2.id;
        tpaSecondaryDataAss2.Secondary_Asset_Name__c = 'tpa sec asset 2';
        //insert tpaSecondaryDataAss2;
        System.debug('27.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaSecondaryDataAss3 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAss3.TPA_Data_Asset__c = tpaDataAss1.Id;
        tpaSecondaryDataAss3.IMS_Secondary_Data_Asset__c = imsSecondaryDataAss1.id;
        tpaSecondaryDataAss3.Secondary_Asset_Name__c = 'ProVoice Custom Study Name & Project Delivery Date:';
        tpaSecondaryDataAss3.Pro_Voice_Delivery_Date__c = Date.today();
        insert new List<TPA_Secondary_Data_Asset__c> {tpaSecondaryDataAss1, tpaSecondaryDataAss2, tpaSecondaryDataAss3};
        system.assert(tpaSecondaryDataAss3.Id != null);
        System.debug('28.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Use_Offering_Atypical_Combination__c IMSUseOfferingAtypicalCombinationObj1 = new IMS_Use_Offering_Atypical_Combination__c(Use_Category__c = purposeCategory1.id,Use_Name__c = imsPurpose1.id, Offering_Name__c =  imsDataAss1.id, Secondary_Offering_Name__c = imsSecondaryDataAss1.id, isActive__c = true, is_Approved_For_Future__c = false);
        System.debug('29.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Use_Offering_Atypical_Combination__c IMSUseOfferingAtypicalCombinationObj2 = new IMS_Use_Offering_Atypical_Combination__c(Use_Category__c = purposeCategory1.id,Use_Name__c = imsPurpose1.id, Offering_Name__c =  imsDataAss2.id, isActive__c = true, is_Approved_For_Future__c = false);
        insert new List<IMS_Use_Offering_Atypical_Combination__c> {IMSUseOfferingAtypicalCombinationObj1, IMSUseOfferingAtypicalCombinationObj2};
        TPA_Use_Offering_Atypical_Combination__c TPAUseOfferingAtypicalCombinationObj1 = new TPA_Use_Offering_Atypical_Combination__c(IMS_Use_Offering_Atypical_Combination__c = IMSUseOfferingAtypicalCombinationObj1.id, TPA_Request__c = tpaReq1.id);
        TPA_Use_Offering_Atypical_Combination__c TPAUseOfferingAtypicalCombinationObj2 = new TPA_Use_Offering_Atypical_Combination__c(IMS_Use_Offering_Atypical_Combination__c = IMSUseOfferingAtypicalCombinationObj2.id, TPA_Request__c = tpaReq1.id);
        insert new List<TPA_Use_Offering_Atypical_Combination__c> {TPAUseOfferingAtypicalCombinationObj1, TPAUseOfferingAtypicalCombinationObj2};
        System.debug('30.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Contact__c tpaContact = UTL_TPA_SetupTestData.getTPAContactByReqId(tpaReq1);
        tpaContact.Subcontractor_TPA_Request__c = tpaReq1.Id;
        tpaContact.Type__c = 'Additional Client Contact';
        update tpaContact;
        System.debug('31.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAss1, true, 'Test Sec Assest');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAss1, imsSecondaryDataAss1, imsLegalEntity, tpaReq1, 'Xponent PlanTrak');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAss2, imsSecondaryDataAss1, imsLegalEntity, tpaReq1, 'Test Sec Asset');
        
        List<TPA_Text_Editor__c> textEditorList = new List<TPA_Text_Editor__c>();

        TPA_Text_Editor__c tpaUseDefinition3 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification 3', Page_Title__c = 'Notification_Content', Page_Type__c = 'TPA Offering Notifications');
        textEditorList.add(tpaUseDefinition3) ;
        System.debug('32.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Text_Editor__c tpaUseDefinition4 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification 4', Page_Title__c = 'Notification_Content', Page_Type__c = 'TPA Offering Notifications');
        textEditorList.add(tpaUseDefinition4) ;
        System.debug('33.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        TPA_Text_Editor__c tpaUseDefinition5 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification  4', Page_Title__c = 'Notification_Content', Page_Type__c = 'TPA Offering Notifications');
        textEditorList.add(tpaUseDefinition5) ;

        TPA_Text_Editor__c tpaUseDefinition6 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification  4', Page_Title__c = 'Notification_Content', Page_Type__c = 'TPA Offering Addendum');
        textEditorList.add(tpaUseDefinition6) ;

        TPA_Text_Editor__c tpaUseDefinition7 = new TPA_Text_Editor__c(Page_Name__c = 'Is_Oncology_EMR__c', Content__c = 'Test Offerings Additional Terms', Page_Title__c = 'Is_Oncology_EMR__c', Page_Type__c = 'IMS_Legal_Entity__c');
        textEditorList.add(tpaUseDefinition7) ;

        insert textEditorList;
        System.debug('34.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        List<TPA_Offering_Notification_Mapping__c> offNotObjList = new List<TPA_Offering_Notification_Mapping__c>();
        TPA_Offering_Notification_Mapping__c offNotObj = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAss1.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAss1.id,IMS_TPA_Purpose__c = imsPurpose1.id,Offering_Notifications__c = tpaUseDefinition3.id, IsActive__c = true,Country__c = 'United States', TLLA_Additional_Terms__c = tpaUseDefinition6.id);
        offNotObjList.add(offNotObj);
        TPA_Offering_Notification_Mapping__c offNotObj1 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAss1.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAss1.id,IMS_TPA_Purpose__c = imsPurpose1.id,Offering_Notifications__c = tpaUseDefinition4.id, IsActive__c = true,Country__c = 'United States', TLLA_Additional_Terms__c = tpaUseDefinition6.id);
        offNotObjList.add(offNotObj1);
        TPA_Offering_Notification_Mapping__c offNotObj2 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAss2.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAss2.id, Offering_Notifications__c = tpaUseDefinition4.id, IsActive__c = true,Country__c = 'United States' , TLLA_Additional_Terms__c = tpaUseDefinition6.id);
        offNotObjList.add(offNotObj2);
        TPA_Offering_Notification_Mapping__c offNotObj3 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAss2.Id, IMS_TPA_Purpose__c = imsPurpose1.id,Offering_Notifications__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States',OneKey_Countries__c='United Kingdom' , TLLA_Additional_Terms__c = tpaUseDefinition6.id);
        offNotObjList.add(offNotObj3);
        TPA_Offering_Notification_Mapping__c offNotObj4 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAss2.Id, Offering_Notifications__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States', OneKey_Countries__c='United Kingdom',TLLA_Additional_Terms__c = tpaUseDefinition6.id);
        offNotObjList.add(offNotObj4);
        insert offNotObjList;
        System.debug('35.Number of Queries used in this apex code so far: ' + Limits.getQueries());

        List<TPA_Off_Notification_Account_Mapping__c> accMapList = new List<TPA_Off_Notification_Account_Mapping__c>();

        
        TPA_Off_Notification_Account_Mapping__c accmapObj1 = new TPA_Off_Notification_Account_Mapping__c(Vendor_Account_Address__c = account.id, TPA_Offering_Notification_Mapping_Rule__c = offNotObj.id);
        accMapList.add(accmapObj1);
        TPA_Off_Notification_Account_Mapping__c accmapObj2 = new TPA_Off_Notification_Account_Mapping__c(Vendor_Account_Address__c = account.id, TPA_Offering_Notification_Mapping_Rule__c = offNotObj4.id);
        accMapList.add(accmapObj2);

        insert accMapList;
        System.debug('36.Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }

}