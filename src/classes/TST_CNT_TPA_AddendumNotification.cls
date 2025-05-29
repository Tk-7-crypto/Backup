@isTest(SeeAllData=False)
public class TST_CNT_TPA_AddendumNotification {
    private static TPA_Request__c tpaRequest1;
    private static Contact tpaContact;
    private static Account testAccountRecord1;
    private static Account testAccountRecord2;
    private static Address__c testAccount;
    private static Address__c testClientAccount;
    private static CNT_TPA_AddendumNotification TPA_AddendumNotificationControllerInstance;
    public static testMethod void TTPA_AddendumNotificationControllerTest() {  
        setupTestData();
        //testAccount = [select id from Address__c where name like 'test vendor' limit 1];
        //List <TPA_Request__C> reqLst = [select id from TPA_Request__C limit 1];
        //tpaRequest1 = reqLst[0];
        
        PageReference pageRef = Page.VFP_TPA_AddendumNotification;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', tpaRequest1.Id);
        ApexPages.currentPage().getParameters().put('language_Field', 'English_Translation__c');
        ApexPages.currentPage().getParameters().put('reqVendorAccountId', testAccount.id);
        ApexPages.currentPage().getParameters().put('aggNo', 'TPA-000');
        Test.startTest();
		CNT_TPA_AddendumNotification AddendumNotificationInstance = new CNT_TPA_AddendumNotification();
        //system.assertEquals(true, CNT_TPA_AddendumNotification.AddendumAdditionalTermsRequiredOrNot(tpaRequest1.Id,testAccount.id));
        Test.stopTest();
    }
    
    static void setupTestData() {
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        
        Date todayDate = Date.today();
        testAccountRecord1 = UTL_TPA_SetupTestData.getAccountObjectRecord('test vendor');
        testAccountRecord2 = UTL_TPA_SetupTestData.getAccountObjectRecord('test client');
        insert new List<Account>{testAccountRecord1, testAccountRecord2};
        testAccount = UTL_TPA_SetupTestData.getAddressByNameAndRegNo('test vendor',1200);
        testAccount.Account__c = testAccountRecord1.Id;
        testClientAccount = UTL_TPA_SetupTestData.getAddressByNameAndRegNo('test client',1211);
        testClientAccount.Account__c = testAccountRecord2.Id;
        testClientAccount.City__c = 'test billing city';
        testClientAccount.State__c = 'test billing state';
        insert new List<Address__c> {testAccount, testClientAccount};
        //update testClientAccount;
        
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
        
        tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAccount.id);
        tpaRequest1.Client_Address__c = testClientAccount.id;
        date strtDate = date.newInstance(2014, 1, 1);
        tpaRequest1.Data_Access_Start_Date__c = strtDate.addDays(-5);
        update tpaRequest1;
        
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test', Legal_Entity_Name_for_TLLA__c = 'test Name', Name_for_ESign__c = 'Test Esign',Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;
        
        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test', Tpa_Request__c = tpaRequest1.Id,IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;
        
        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose', tpaRequest1, tpaPurposeCategory, imsTpaPurpose, imsLegalEntity);
        
        IMS_TPA_Purpose__c imsTpaPurpose1 = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name1');
        TPA_Purpose__c tpaPurpose1 = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose1', tpaRequest1, tpaPurposeCategory, imsTpaPurpose1, imsLegalEntity);
        
        
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);
        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset, imsLegalEntity);
        
        //IMS_Data_Asset__c imsDataAsset1 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        //TPA_Data_Asset__c tpaDataAsset1 = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset1, imsLegalEntity);
        
        //IMS_Data_Asset__c imsDataAsset2 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        //TPA_Data_Asset__c tpaDataAsset2 = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset2, imsLegalEntity);
        
        //IMS_Data_Asset__c imsDataAsset3 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        //TPA_Data_Asset__c tpaDataAsset3 = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset3, imsLegalEntity);
        
        //IMS_Data_Asset__c imsDataAsset4 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        //TPA_Data_Asset__c tpaDataAsset4 = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset4, imsLegalEntity);
        
        //IMS_Data_Asset__c imsDataAsset5 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        //TPA_Data_Asset__c tpaDataAsset5 = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset5, imsLegalEntity);
        
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true ,'test');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset, imsSecondaryDataAsset, imsLegalEntity, tpaRequest1, 'test');
        
        //IMS_Secondary_Data_Asset__c imsSecondaryDataAsset1 = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset1, true, 'test');
        //TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset1 = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset1, imsSecondaryDataAsset1, imsLegalEntity, tpaRequest1, 'test');
        
        //IMS_Secondary_Data_Asset__c imsSecondaryDataAsset2 = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset2, true, 'test1');
        //TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset2, imsSecondaryDataAsset2, imsLegalEntity, tpaRequest1, 'test2');
        
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true, Use_Definition_Page__c = 'testPage');
        insert imsTpaPurposeDescription;
        
        TPA_Text_Editor__c tpaUseDefinition1 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification', Page_Title__c = imsDataAsset.Id, Page_Type__c = 'Tpa Offering Notifications');
        insert tpaUseDefinition1;
        
        TPA_Text_Editor__c tpaUseDefinition2 = UTL_TPA_SetupTestData.createTpaTestEditorData('Client/Vendor Notification', 'Test Offerings Notification', 'Client/Vendor Notification', 'TLLA Additional Terms');
        TPA_Text_Editor__c tpaUseDefinition3 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 3', 'Notification_Content', 'TPA Offering Addendum');
        TPA_Text_Editor__c tpaUseDefinition4 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 4', 'Notification_Content', 'TLLA Additional Terms');
        TPA_Text_Editor__c tpaUseDefinition5 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 5', 'Notification_Content', 'TPA Offering Addendum');
        
        
        TPA_Offering_Notification_Mapping__c offNotObj = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id,IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition3.id, IsActive__c = true,Country__c = 'United States');
        //insert offNotObj;
        //TPA_Offering_Notification_Mapping__c offNotObj1 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset1.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset1.id,IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition4.id, IsActive__c = true,Country__c = 'United States');
        //insert offNotObj1;
        //TPA_Offering_Notification_Mapping__c offNotObj2 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset2.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset2.id, TLLA_Additional_Terms__c = tpaUseDefinition4.id, IsActive__c = true,Country__c = 'United States');
        //insert offNotObj2;
        //TPA_Offering_Notification_Mapping__c offNotObj3 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset4.Id, IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        //insert offNotObj3;
        //TPA_Offering_Notification_Mapping__c offNotObj4 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset5.Id,IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        //insert offNotObj4;
        //TPA_Offering_Notification_Mapping__c offNotObj5 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset1.Id, TLLA_Additional_Terms__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        //insert offNotObj5;
        //TPA_Offering_Notification_Mapping__c offNotObj6 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset3.Id, TLLA_Additional_Terms__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        //insert offNotObj6;
        TPA_Offering_Notification_Mapping__c offNotObj7 = new TPA_Offering_Notification_Mapping__c(IMS_TPA_Purpose__c = imsTpaPurpose1.Id, TLLA_Additional_Terms__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        insert new List<TPA_Offering_Notification_Mapping__c> {offNotObj,offNotObj7};
    }
}