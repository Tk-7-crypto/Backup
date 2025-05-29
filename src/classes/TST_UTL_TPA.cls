@isTest(SeeAllData=false)
public class TST_UTL_TPA {
    public static String CRON_EXP = '0 0 0 15 3 ? ' + (Date.Today().Year() + 1);
    private static TPA_Request__c testTpaRequest;   
    private static AMA_Agreement_Detail__c amaObj;
    private static Date todayDate;
    private static Address__c testNewClientAccount;
    
    @TestSetup
    static void setupTestData() {
        List<TPA_Country_Codes__c> lstCountCodes = new List<TPA_Country_Codes__c>();
        lstCountCodes.add(new TPA_Country_Codes__c(Name = 'test1', Country_Possible_Codes__c = 'a1;a2', Code_Type__c = 'C'));
        lstCountCodes.add(new TPA_Country_Codes__c(Name = 'test2', Country_Possible_Codes__c = 'a1;a2', Code_Type__c = 'S'));
        lstCountCodes.add(new TPA_Country_Codes__c(Name = 'test3', Code_Type__c = 'C'));
        lstCountCodes.add(new TPA_Country_Codes__c(Name = 'test4', Code_Type__c = 'S'));
        insert lstCountCodes;
    }
    
    static void setupTestDataForCancellation() {
    
        testNewClientAccount = UTL_TPA_SetupTestData.getAccount();
        testNewClientAccount.Name = 'veeva medpro edith deepintent repwise';
        testNewClientAccount.is_TPA_Account__c = true;
        testNewClientAccount.Street__c = 'test';
        testNewClientAccount.City__c = 'test';
        testNewClientAccount.Country__c = 'test';
        testNewClientAccount.PostalCode__c = 'test';
        insert testNewClientAccount;
       
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createTPASettingData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();

        testTpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        testTpaRequest.OwnerId = UserInfo.getUserId();
        testTpaRequest.AMA_USPrescriberData__c = 'Yes';
        testTpaRequest.Service_Provider_Address__c = testNewClientAccount.Id;
        testTpaRequest.Client_Address__c = testNewClientAccount.Id;
        testTpaRequest.Vendor_Company_Name__c = 'AMA Vendor SB II';
        testTpaRequest.data_access_start_date__c = Date.newInstance(2016 , 10 ,20);
        testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
        testTpaRequest.IMS_Data_Country_Location__c = 'United States';
        testTpaRequest.Employee_Accessing_Data_Location__c = 'United States';
        testTpaRequest.Vendor_Contact_Name_f__c = 'JEREMY';
        testTpaRequest.Vendor_Contact_Last_Name__c = 'MAYORS';
        testTpaRequest.TP_Processor_Email__c = 'supriya.johari@metacube.com';
        testTpaRequest.Vendor_Contact_e_mail__c = 'supriya.johari@metacube.com';
        testTpaRequest.Vendor_Contact_Email_Client__c = 'supriya.johari@metacube.com';
        testTpaRequest.Request_Status__c = 'Pending Vendor AMA Fee Acknowledgement';
        testTpaRequest.Is_Vendor_Veeva_for_all_Use__c = true;
        testTpaRequest.Is_Veeva_Use_CRM_Off_OneKey__c = true;
        testTpaRequest.is_Veeva_Use_CRM__c = true;
        testTpaRequest.Is_Veeva_Use_CRM_SubNational_Off__c = true;
        testTpaRequest.Is_South_Africa_Sub_Off__c = true;
        testTpaRequest.is_Specific_Vendors_LAAD_Off__c = true;
        testTpaRequest.is_Specific_Vendors_APLD_Off__c = true;
        testTpaRequest.is_Specific_Vendors_Long_Prescr_Data__c = true;
        testTpaRequest.is_Specific_Vendors_Medical_Claims_Data__c = true;
        testTpaRequest.is_20_or_more_Offering_Present__c = true;
        testTpaRequest.Is_Vendor_Name_Contains_MedPro__c = true;
        testTpaRequest.AMA_USPrescriberData__c = 'Yes';
        insert testTpaRequest;
        
        IMS_Legal_Entity__C imsLegalEntity = new IMS_Legal_Entity__C();
        imsLegalEntity.TPA_Request__c = testTpaRequest.Id;
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
        
        TPA_Request__c testTpaRequest2 = [select Id, Name, Service_Provider_Address__c,Is_Vendor_Name_Contains_MedPro__c, is_Specific_Vendors_LAAD_Off__c, is_Specific_Vendors_APLD_Off__c, is_Specific_Vendors_Long_Prescr_Data__c, is_Specific_Vendors_Medical_Claims_Data__c, Service_Provider_Address__r.Id, Service_Provider_Address__r.Name,Is_South_Africa_Sub_Off__c,is_20_or_more_Offering_Present__c,AMA_USPrescriberData__c from TPA_Request__c limit 1];
        
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
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = testTpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                       Purpose__c = imsTpaPurpose.id);
        insert tpaPurpose;
        
        TPA_Purpose__c tpaPurpose2 = new TPA_Purpose__c(Name = 'Other',Request__c = testTpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory2.id,
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
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = testTpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        //insert tpaDataAsset;
        tpaDataAssetList.add(tpaDataAsset);

        TPA_Data_Asset__c tpaDataAsset1 = new TPA_Data_Asset__c(Request__c = testTpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset3.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Test Data Asset 1');
        //insert tpaDataAsset;
        tpaDataAssetList.add(tpaDataAsset1);
    
        insert tpaDataAssetList;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset1.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset2;
        UTL_TPA.getTpaAdditionalTerms(testTpaRequest);
        UTL_TPA.getGlobalBrandingVendorId(testTpaRequest);
        testTpaRequest = [ select id, Service_Provider_Address__r.Name, Client_Address__c, Vendor_Company_Name__c,AMA_USPrescriberData__c, Is_VSN_Acknowlege_By_Client__c,
        data_access_start_date__c, data_access_end_date__c, IMS_Data_Country_Location__c, Employee_Accessing_Data_Location__c, Vendor_Contact_Name_f__c,
        Vendor_Contact_Last_Name__c, TP_Processor_Email__c, Vendor_Contact_e_mail__c , Vendor_Contact_Email_Client__c, Request_Status__c,
        Is_Veeva_Use_CRM_Off_OneKey__c, is_Veeva_Use_CRM__c, Is_Veeva_Use_CRM_SubNational_Off__c, Is_South_Africa_Sub_Off__c, is_Specific_Vendors_LAAD_Off__c,
        is_Specific_Vendors_APLD_Off__c,is_Specific_Vendors_Long_Prescr_Data__c, Is_Vendor_Name_Contains_MedPro__c, is_Specific_Vendors_Medical_Claims_Data__c, is_20_or_more_Offering_Present__c from TPA_Request__c where id=:testTpaRequest.id limit 1];
        Map<string, TPA_Text_Editor__C> mapContainer2 = UTL_TPA.getTpaTextAdditionalTerms(testTpaRequest);
        Map<string, TPA_Text_Editor__C> mapContainer4 = UTL_TPA.getTpaTextAdditionalTerms(testTpaRequest2);
        Map<string, TPA_Offering_Notification_Mapping__c> mapContainer3 = UTL_TPA.getmapTpaDynamicNotifications(testTpaRequest);
    }
    
    public static void createAMAagreementForVendor() {
        todayDate = Date.today();
        amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaObj.Agreement_Start_Date__c = Date.newInstance(2016 , 10 ,20);
        amaObj.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaObj.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaObj.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaObj.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaObj.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        amaObj.Status_of_Cancelation_Request__c = 'Awaiting Vendor Cancelation Acknowledgement';
        amaObj.Last_Vendor_Reminder_Mail_Sent__c =  todayDate.addDays(-1);
        amaObj.Vendor_Reasons_for_Termination__c  = 'No AMA data was shared';
        insert amaObj; 
    }
    
    public static testMethod void testcases_isvalidPhone() {
        UTL_TPA.isvalidPhone('asdf');
        Contact con = new Contact(FirstName='Test',LastName='22');
        insert con;
        Address__c add = UTL_TPA_SetupTestData.getAddress();
        insert add;
        insert UTL_TPA_SetupTestData.getjunctionRecord(con.Id,add.Id);
        
        UTL_TPA.getAddressId(con.Id);
        UTL_TPA.getAddressIds(con.Id);
        UTL_TPA.getContactAddressCrowalk(con.Id);
    }
    
    public static testMethod void testAccountCompliance(){
        Account clientAcc = UTL_TPA_SetupTestData.getAccountObjectRecord('Test Client Account');
        insert clientAcc;
        Account vendorAcc = UTL_TPA_SetupTestData.getAccountObjectRecord('Test Vendor Account');
        insert vendorAcc;
        Account_Compliance__c accCompClient = new Account_Compliance__c(Account__c = clientAcc.Id);
        Account_Compliance__c accCompVendor = new Account_Compliance__c(Account__c = vendorAcc.Id);
        insert new List<Account_Compliance__c>{accCompClient,accCompVendor};
        Address__c vendorAdd = UTL_TPA_SetupTestData.getAddress();
        Address__c clientAdd = UTL_TPA_SetupTestData.getAddress();
        clientAdd.Account__c = clientAcc.Id;
        vendorAdd.Account__c = vendorAcc.Id;
        insert new List<Address__c>{vendorAdd,clientAdd};
        Map<String, Account_Compliance__c> tempMap = UTL_TPA.getTpaClientVendorComplianceDetails(clientAdd.Id,vendorAdd.Id);
    }
    
    public static testMethod void test1() {
   
        Test.startTest();
        
        setupTestDataForCancellation();
        createAMAagreementForVendor();
        UTL_TPA.getCurrentUserProfileInfo();
        UTL_TPA.getPortalProfileMap();
        UTL_TPA.getTPAProfileMap();
        UTL_TPA.capitalizeWords('test');
        UTL_TPA.getAddress(testNewClientAccount.Id);
        UTL_TPA.sendCompetitiveMail(null);
        UTL_TPA.getOfferingDetailsToHtmlList('country:PrimOff:SecOff;');
        List<TPA_Request__c> tpaRequestList1 = [Select id,TP_Processor_Email__c,(Select Id From Purposes__r) from TPA_Request__c];
        UTL_TPA.getRequestToAddressMap(new Set<Id>{tpaRequestList1[0].id});
        UTL_TPA.getIdOfMembersOfGroup();
        UTL_TPA.getIdsOfQueue();
        UTL_TPA.isUserTPASuperAdmin();
        UTL_TPA.isManualReviewAddHoc('IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested');
        UTL_TPA.createAddHocKey(new TPA_Additional_Term__c());
        UTL_TPA.getVendorProfileMap();
        List<TPA_Commercial_Review__c> comReviewList = new List<TPA_Commercial_Review__c>();
        TPA_Commercial_Review__c comRev1 = new TPA_Commercial_Review__c(Commercial_Owner_Name__c = UserInfo.getUserName(), 
                                               Associated_Offering_to_Review__c = 'test', 
                                               Associated_Use_to_Review__c = 'Data Cleansing', 
                                               Manual_Review_Reason__c = 'Vendor Requires Secondary Review',  
                                               Action_Needed_By__c = 'Management', 
                                               TPA_Request__c = tpaRequestList1[0].Id, 
                                               Action__c = 'Under Validation', 
                                               Receiver_s_Email__c = 'test@gmail.com',
                                               TP_US_Email__c = UserInfo.getUserEmail(), 
                                               TP_Country_Email__c = 'test@gmail.com');
        insert comRev1;
        comReviewList.add(comRev1);
        UTL_TPA.createTableFromManualReviews(comReviewList);
        UTL_TPA.updateEntryInClientVendorSrchMap(testNewClientAccount.Id, 'veeva');
        UTL_TPA.getDDNAckPendingRequests(testNewClientAccount.Id);
        UTL_TPA.isAmaDoc('exus entity foreign license');
        UTL_TPA.isAmaFLDoc('exus entity foreign license');
        Set<Id> purIds = new Set<Id>();
        for(TPA_Purpose__c pur:tpaRequestList1[0].Purposes__r){
            purIds.add(pur.Id);
        }
        List<TPA_Data_Asset__c> tpaDataAssets = SRV_TPA_TPARequest.tpaDataAssetListCopy(purIds);
        UTL_TPA.setUseOfferingMap(tpaDataAssets);
        System.debug(UTL_TPA.runBatchForTestRecordsMap);
        UTL_TPA.VendorSpecificNotificationSendConfirmationToClient(tpaRequestList1[0],'test EMail');
        
        Boolean IsSandbox = UTL_TPA.isSandboxOrg;
        Map<string, string> mapSavePoints = UTL_TPA.savePoints;
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new SCH_TPA_AMA_Send_Reminder_Mail());
          
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
          
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
          
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
          
        // Verify the next time the job will run
        System.assertEquals((Date.Today().Year() + 1) + '-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
        
      List<sObject> lstSObj = UTL_TPA.lstTPACountryAndStateCodes;
        Map<string, string> mapContainer = UTL_TPA.mapCountryCodeWithAllPossibleValues;
        mapContainer = UTL_TPA.mapStateCodeWithAllPossibleValues;
    }
}
