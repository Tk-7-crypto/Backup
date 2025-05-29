@isTest(SeeAllData=False)
public class TST_QBL_TPA_HelpfulHintsAddendum {
    private static TPA_Request__c tpaRequest1;
    private static Contact tpaContact;
    private static Address__c testAccount;
    private static Address__c testClientAccount;
    private static CNT_TPA_Helpful_Hints_Addendum TPA_AddendumNotificationControllerInstance;
    public static testMethod void TTPA_AddendumNotificationControllerTest() {  
        
        testAccount = [select id from Address__c where name like 'test vendor' limit 1];
        List <TPA_Request__C> reqLst = [select id from TPA_Request__C limit 1];
        tpaRequest1 = reqLst[0];
        
        PageReference pageRef = Page.VFP_TPA_Helpful_Hints_Addendum;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', tpaRequest1.Id);
        ApexPages.currentPage().getParameters().put('language_Field', 'English_Translation__c');
        ApexPages.currentPage().getParameters().put('mode', 'pdf');
        ApexPages.currentPage().getParameters().put('aggNo', 'TPA-000');
        Test.startTest();
        Test.stopTest();
    }
    
    @TestSetup
    static void setupTestData() {
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createMultilingualGlobalSettingsData();        
        Date todayDate = Date.today();
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor',1200);
        testClientAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test client',1211);
        testClientAccount.City__c = 'test billing city';
        testClientAccount.State__c = 'test billing state';
        update testClientAccount;
        
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
        
        tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAccount.id);
        tpaRequest1.Client_Address__c = testClientAccount.id;
        date strtDate = date.newInstance(2014, 1, 1);
        tpaRequest1.Data_Access_Start_Date__c = strtDate.addDays(-5);
        tpaRequest1.TLLA_Language_Chosen__c = 'English';
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
        
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true ,'test');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset, imsSecondaryDataAsset, imsLegalEntity, tpaRequest1, 'test');
        
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                                                                     Is_Active__c = true, Use_Definition_Page__c = 'testPage');
        insert imsTpaPurposeDescription;
        
        List<TPA_Text_Editor__c> textEditorsList = new List<TPA_Text_Editor__c>();
        TPA_Text_Editor__c tpaHelpful1 = new TPA_Text_Editor__c(Page_Name__c = 'TPA Helpful Hints Addendum', Content__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', English_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Japanese_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', French_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Page_Title__c = 'TPA Helpful Hints Addendum', Page_Type__c = 'Helpful Hints Addendum');
        textEditorsList.add(tpaHelpful1);
        TPA_Text_Editor__c tpaHelpful2 = new TPA_Text_Editor__c(Page_Name__c = 'TPA Helpful Hints Addendum 1', Content__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', English_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Japanese_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', French_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Page_Title__c = 'TPA Helpful Hints Addendum 1', Page_Type__c = 'Helpful Hints Addendum');
        textEditorsList.add(tpaHelpful2);
        TPA_Text_Editor__c tpaHelpful3 = new TPA_Text_Editor__c(Page_Name__c = 'TPA Helpful Hints Addendum 2', Content__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', English_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Japanese_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', French_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Page_Title__c = 'TPA Helpful Hints Addendum 2', Page_Type__c = 'Helpful Hints Addendum');
        textEditorsList.add(tpaHelpful3);
        TPA_Text_Editor__c tpaHelpful4 = new TPA_Text_Editor__c(Page_Name__c = 'TPA Helpful Hints Addendum 3', Content__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', English_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Japanese_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', French_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Page_Title__c = 'TPA Helpful Hints Addendum 3', Page_Type__c = 'Helpful Hints Addendum');
        textEditorsList.add(tpaHelpful4);
        TPA_Text_Editor__c tpaHelpful5 = new TPA_Text_Editor__c(Page_Name__c = 'TPA Helpful Hints Addendum 4', Content__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', English_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Japanese_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', French_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Page_Title__c = 'TPA Helpful Hints Addendum 4', Page_Type__c = 'Helpful Hints Addendum');
        textEditorsList.add(tpaHelpful5);
        TPA_Text_Editor__c tpaHelpful6 = new TPA_Text_Editor__c(Page_Name__c = 'TPA Helpful Hints Addendum 5', Content__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', English_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Japanese_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', French_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Page_Title__c = 'TPA Helpful Hints Addendum 5', Page_Type__c = 'Helpful Hints Addendum');
        textEditorsList.add(tpaHelpful6);
        TPA_Text_Editor__c tpaHelpful7 = new TPA_Text_Editor__c(Page_Name__c = 'TPA Helpful Hints Addendum 6', Content__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', English_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Japanese_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', French_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Page_Title__c = 'TPA Helpful Hints Addendum 6', Page_Type__c = 'Helpful Hints Addendum');
        textEditorsList.add(tpaHelpful7);
        TPA_Text_Editor__c tpaHelpful8 = new TPA_Text_Editor__c(Page_Name__c = 'TPA Helpful Hints Addendum 7', Content__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', English_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Japanese_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', French_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Page_Title__c = 'TPA Helpful Hints Addendum 7', Page_Type__c = 'Helpful Hints Addendum');
        textEditorsList.add(tpaHelpful8);
        TPA_Text_Editor__c tpaHelpful9 = new TPA_Text_Editor__c(Page_Name__c = 'TPA Helpful Hints Addendum 8', Content__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', English_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Japanese_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', French_Translation__c = 'Client_Request_Number TLLA_Effective_Date IMS_Legal_Entity_Name Vendor_Legal_Name', Page_Title__c = 'TPA Helpful Hints Addendum 8', Page_Type__c = 'Helpful Hints Addendum');
        textEditorsList.add(tpaHelpful9);
        insert textEditorsList;
        
        QBL_TPA_HelpfulHintsAddendum qblHelpfulHints = new QBL_TPA_HelpfulHintsAddendum();
        qblHelpfulHints.requestId = tpaRequest1.Id;
        qblHelpfulHints.GUID = 'GUID';
        System.enqueueJob(qblHelpfulHints);
        
    }

}