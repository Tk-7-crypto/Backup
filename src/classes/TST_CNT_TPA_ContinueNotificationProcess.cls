@isTest
public class TST_CNT_TPA_ContinueNotificationProcess { 
    private static TPA_Request__c tpaRequest1;
    private static TPA_Agreement_Additional_Field__c tpaAdditionalRequest;
    
    @isTest
    static void CNT_TPA_ContinueNotificationProcesstest(){
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();

        //Create Account
        Account testAccount1 = new Account(Name = 'test12345Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount1;
        
        //Create Address
        Address__c testAddress1 = new Address__c(Name = 'test12345Account', recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, CurrencyIsoCode = 'USD', Account__c = testAccount1.Id, Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
        insert testAddress1;

        //Create Contact
        Contact testContact = new Contact(FirstName = 'testFirstname',
                                          LastName = 'con',
                                          AccountId = testAccount1.Id,
                                          CurrencyIsoCode = 'USD',
                                          Email = 'test@mail.com',
                                          Title = 'Dev');
        insert testContact;


        tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAddress1.id);
        tpaRequest1.Request_Status__c = 'In Review by IQVIA';
        update tpaRequest1;
        
        tpaAdditionalRequest = new TPA_Agreement_Additional_Field__c(Related_TPA_Request__c = tpaRequest1.Id);
        insert tpaAdditionalRequest;

        date strtDate = date.newInstance(2014, 1, 1);

        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test', Legal_Entity_Name_for_TLLA__c = 'test Name', Name_for_ESign__c = 'Test Esign',Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;

        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test', TPA_Request__c = tpaRequest1.Id,IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;

        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');

        IMS_TPA_Purpose__c imsTpaPurpose1 = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name1');
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);

        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose', tpaRequest1, tpaPurposeCategory, imsTpaPurpose, imsLegalEntity);
        TPA_Purpose__c tpaPurpose1 = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose1', tpaRequest1, tpaPurposeCategory, imsTpaPurpose1, imsLegalEntity);

        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset, imsLegalEntity);

        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true ,'test');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset, imsSecondaryDataAsset, imsLegalEntity, tpaRequest1, 'test');
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true, Use_Definition_Page__c = 'testPage');
        insert imsTpaPurposeDescription;
        
        TPA_Text_Editor__c tpaUseDefinition1 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification', Page_Title__c = imsDataAsset.Id, Page_Type__c = 'Tpa Offering Notifications');
        insert tpaUseDefinition1;
        
        TPA_Text_Editor__c tpaUseDefinition2 = UTL_TPA_SetupTestData.createTpaTestEditorData('Client/Vendor Notification', 'Test Offerings Notification', 'Client/Vendor Notification', 'Tpa Offering Notifications Mapping');
        TPA_Text_Editor__c tpaUseDefinition3 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 3', 'Notification_Content', 'TPA Offering Notifications');
        TPA_Text_Editor__c tpaUseDefinition4 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 4', 'Notification_Content', 'TPA Offering Notifications');
        TPA_Text_Editor__c tpaUseDefinition5 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 5', 'Notification_Content', 'Tpa Offering Notifications Mapping');
        
       
        
        TPA_Offering_Notification_Mapping__c offNotObj = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id,IMS_TPA_Purpose__c = imsTpaPurpose.id,Offering_Notifications__c = tpaUseDefinition3.id, IsActive__c = true,Country__c = 'United States',Process_Execution_Mode__c = 'Direct to Client');
        insert offNotObj;
        TPA_Offering_Notification_Mapping__c offNotObj1 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id,IMS_TPA_Purpose__c = imsTpaPurpose.id,Offering_Notifications__c = tpaUseDefinition4.id, IsActive__c = true,Country__c = 'United States',Process_Execution_Mode__c = 'QuintilesIMS Sales');
        insert offNotObj1;
        
        Test.startTest();
        PageReference pageRef = Page.VFP_TPA_ContinueNotificationProcess;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('type', 'setExpire');
        ApexPages.currentPage().getParameters().put('id', tpaAdditionalRequest.Id);
        ApexPages.currentPage().getParameters().put('agrId', tpaRequest1.Id);
        
        CNT_TPA_ContinueNotificationProcess controller = new CNT_TPA_ContinueNotificationProcess();
        controller.setStatusExp();
        
        ApexPages.currentPage().getParameters().put('type', '');
        ApexPages.currentPage().getParameters().put('id', tpaRequest1.Id);
        
        controller = new CNT_TPA_ContinueNotificationProcess();
        controller.sendVSNMail();
        Test.stopTest();
    }
    
}