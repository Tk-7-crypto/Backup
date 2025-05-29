/**
* Name: TPA_OfferingNotificationsControllerTest
* Author Name: Chandra Prakash
* Date Created: 02 Nov 2015 
* Description: Test Class for contoller: TST_TPA_OfferingNotificationsController
**/

@isTest(SeeAllData=False)
public class TST_CNT_TPA_OffNotificationsGenerator {
    private static TPA_Request__c tpaRequest1;
    private static Contact tpaContact;
    private static Address__c testAccount;
    private static CNT_TPA_OffNotificationsGenerator offNotificationInstance;
    public static testMethod void testTpaEditorController() {
        setupTestData();
        PageReference pageRef = Page.VFP_TPA_OffNotificationsGenerator;
        Test.setCurrentPage(pageRef);
        //testAccount = [select id from Address__c where name like 'Test Account' limit 1];
        //List <TPA_Request__C> reqLst = [select id from TPA_Request__C limit 1];
        //tpaRequest1 = reqLst[0];
        
        ApexPages.currentPage().getParameters().put('id', tpaRequest1.Id);
        ApexPages.currentPage().getParameters().put('language_Field', 'English_Translation__c');
        ApexPages.currentPage().getParameters().put('reqVendorAccountId', testAccount.id);
        ApexPages.currentPage().getParameters().put('reqVendorCountary', 'United states');
        
        Test.startTest();
        offNotificationInstance = new CNT_TPA_OffNotificationsGenerator();
        offNotificationInstance.loadData();
        system.assertEquals(true, offNotificationInstance.dynamicOfferingsNotificationList.size() > 0 );
        Test.stopTest();
    }
    
    static void setupTestData() 
    {
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        Date todayDate = Date.today();
        
        // create account 
        testAccount = new Address__c(Name = 'Test Account', recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, CurrencyIsoCode = 'USD', Industry__c = 'Car Seller [CS]', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');//Modified by C.P.Pandey under Issue-7181
        insert testAccount;
        
        // Create Contact
        tpaContact = new Contact(FirstName = 'TestFirstName', LastName = 'Test', AccountId = testAccount.Account__c, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        
        tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAccount.id);
        tpaRequest1.Client_Off_Notification_Ack_Date__c = DateTime.Now();
        tpaRequest1.Vendor_Off_Notification_Ack_Date__c = DateTime.Now();
        update tpaRequest1;
        
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test', Legal_Entity_Name_for_TLLA__c = 'test Name', Name_for_ESign__c = 'Test Esign',Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;
        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test',IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;
        
        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose', tpaRequest1, tpaPurposeCategory, imsTpaPurpose, imsLegalEntity);
        
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);
        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset, imsLegalEntity);
        
        IMS_Data_Asset__c imsDataAsset1 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        TPA_Data_Asset__c tpaDataAsset1 = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset1, imsLegalEntity);
        
        IMS_Data_Asset__c imsDataAsset2 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        TPA_Data_Asset__c tpaDataAsset2 = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset2, imsLegalEntity);
        
        IMS_Data_Asset__c imsDataAsset4 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        TPA_Data_Asset__c tpaDataAsset4 = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset4, imsLegalEntity);
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true ,'test');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset, imsSecondaryDataAsset, imsLegalEntity, tpaRequest1, 'test');
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset1 = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset1, true, 'test');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset1 = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset1, imsSecondaryDataAsset1, imsLegalEntity, tpaRequest1, 'test 1');
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset2 = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset2, true, 'test');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset2, imsSecondaryDataAsset2, imsLegalEntity, tpaRequest1, 'test 2');
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true, Use_Definition_Page__c = 'testPage');
        insert imsTpaPurposeDescription;
        
        TPA_Text_Editor__c tpaUseDefinition = new TPA_Text_Editor__c(Page_Name__c = 'Client/Vendor Notification', Content__c = 'Test Offerings Notification', Page_Title__c = 'Client/Vendor Notification', Page_Type__c = 'Tpa Offering Notifications');
        insert tpaUseDefinition;
        
        TPA_Text_Editor__c tpaUseDefinition1 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification', Page_Title__c = imsDataAsset.Id, Page_Type__c = 'Tpa Offering Notifications');
        insert tpaUseDefinition1;
        
        TPA_Text_Editor__c tpaUseDefinition2 = new TPA_Text_Editor__c(Page_Name__c = 'Client/Vendor Notification', Content__c = 'Test Offerings Notification', Page_Title__c = 'Client/Vendor Notification', Page_Type__c = 'Tpa Offering Notifications Mapping');
        insert tpaUseDefinition2;
        
        IMS_TPA_Purpose__c imsTpaPurpose1 = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name1');
        TPA_Purpose__c tpaPurpose1 = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose', tpaRequest1, tpaPurposeCategory, imsTpaPurpose1, imsLegalEntity);
        IMS_Data_Asset__c imsDataAsset3 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        
        TPA_Text_Editor__c tpaUseDefinition3 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification 3', Page_Title__c = 'Notification_Content', Page_Type__c = 'TPA Offering Notifications');
        insert tpaUseDefinition3;
        TPA_Text_Editor__c tpaUseDefinition4 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification 4', Page_Title__c = 'Notification_Content', Page_Type__c = 'TPA Offering Notifications');
        insert tpaUseDefinition4;
        TPA_Text_Editor__c tpaUseDefinition5 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification 5', Page_Title__c = 'Notification_Content', Page_Type__c = 'TPA Offering Notifications');
        insert tpaUseDefinition5;
         TPA_Text_Editor__c tpaUseDefinition6 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification 6', Page_Title__c = 'Notification_Content', Page_Type__c = 'Tpa Offering Notifications Mapping');
        insert tpaUseDefinition6;
        
        TPA_Offering_Notification_Mapping__c offNotObj = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id,IMS_TPA_Purpose__c = imsTpaPurpose.id,Offering_Notifications__c = tpaUseDefinition3.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj;
        TPA_Offering_Notification_Mapping__c offNotObj1 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset1.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset1.id,IMS_TPA_Purpose__c = imsTpaPurpose.id,Offering_Notifications__c = tpaUseDefinition4.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj1;
        TPA_Offering_Notification_Mapping__c offNotObj2 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset2.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset2.id, Offering_Notifications__c = tpaUseDefinition4.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj2;
        TPA_Offering_Notification_Mapping__c offNotObj3 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset4.Id, IMS_TPA_Purpose__c = imsTpaPurpose.id,Offering_Notifications__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj3;
        TPA_Offering_Notification_Mapping__c offNotObj4 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset.Id,IMS_TPA_Purpose__c = imsTpaPurpose.id,Offering_Notifications__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj4;
        TPA_Offering_Notification_Mapping__c offNotObj5 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset1.Id, Offering_Notifications__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj5;
        TPA_Offering_Notification_Mapping__c offNotObj6 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset3.Id, Offering_Notifications__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj6;
        TPA_Offering_Notification_Mapping__c offNotObj7 = new TPA_Offering_Notification_Mapping__c(IMS_TPA_Purpose__c = imsTpaPurpose1.Id, Offering_Notifications__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj7;
        
        TPA_Country_Codes__c tpaCountryCode = new TPA_Country_Codes__c();
        tpaCountryCode.Name = 'United states';
        tpaCountryCode.Country_Possible_Codes__c = 'United states';
        tpaCountryCode.Name = 'C';
        insert tpaCountryCode;
    }
}