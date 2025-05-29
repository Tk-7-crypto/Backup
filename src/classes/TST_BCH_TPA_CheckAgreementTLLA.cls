@isTest(seeAllData = false)
public class TST_BCH_TPA_CheckAgreementTLLA {
    private static TPA_Request__c tpaRequest1;
    private static TPA_Request__c TestAgreement1;
    private static TPA_Request__c TestAgreement2;
    private static TPA_Request__c TestAgreement3;
    private static TPA_Request__c TestAgreement4;
    private static TPA_Request__c TestAgreement5;
    private static TPA_Request__c TestAgreement6;
    private static TPA_Request__c TestAgreement7;
    private static TPA_Request__c TestAgreement8;
    private static TPA_Request__c TestAgreement9;
    private static TPA_Request__c TestAgreement10;
    private static TPA_Request__c TestAgreement11;
    private static TPA_Request__c TestAgreement12;
    private static TPA_Request__c TestAgreement13;
    private static TPA_Request__c TestAgreement14;
    private static TPA_Request__c TestAgreement15;
    private static TPA_Request__c TestAgreement16;
    private static TPA_Request__c TestAgreement17;
    private static TPA_Request__c TestAgreement18;
    private static TPA_Request__c TestAgreement19;
    private static TPA_Request__c TestAgreement20;
    private static Contact tpaContact;
    private static Account testAccount;
    private static Address__c testAddress;
    private static Date todayDate = Date.today();
    List<TPA_Request__c> lstAgreement = new list<TPA_Request__c>();

    private void setupTestData() {

        // create account
        testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech', Is_Payment_Risk__c = true, BillingStreet = 'test', BillingCity = 'test', BillingState = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        // create address
        Address__c testAddress = new Address__c( name = 'Test Account',
                                          recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId,
                                          Is_TPA_Account__c = true,
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

        // Create Contact
        tpaContact = new Contact(FirstName = 'testfirstname', LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP' LIMIT 1];

        TestAgreement1 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement1.Client_Address__c = testAddress.Id;

        lstAgreement.add(TestAgreement1);

        TestAgreement2 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement2.Client_Address__c = testAddress.Id;

        TestAgreement2.In_IMS_Review__c = todayDate.addDays(1);
        lstAgreement.add(TestAgreement2);


        TestAgreement3 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement3.Client_Address__c = testAddress.Id;
        TestAgreement3.In_Auto_Approval_Process__c = todayDate.addDays(1);
        lstAgreement.add(TestAgreement3);

        TestAgreement5 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement5.Client_Address__c = testAddress.Id;
        TestAgreement5.In_IMS_Review__c = todayDate.addDays(1);
        TestAgreement5.In_Auto_Approval_Process__c = todayDate.addDays(2);
        TestAgreement5.TLLA_Batch_Call_Sent_On__c = Date.today();
        lstAgreement.add(TestAgreement5);

        TestAgreement6 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement6.Client_Address__c = testAddress.Id;
        TestAgreement6.In_IMS_Review__c = todayDate.addDays(1);
        TestAgreement6.In_Auto_Approval_Process__c = null;
        TestAgreement6.TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(3);
        lstAgreement.add(TestAgreement6);

        TestAgreement7 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement7.Client_Address__c = testAddress.Id;
        TestAgreement7.In_IMS_Review__c = todayDate.addDays(1);
        TestAgreement7.In_Auto_Approval_Process__c = null;
        TestAgreement7.TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(3);
        TestAgreement7.isbatchprocessing__c = true;
        TestAgreement7.TLLA_Batch_Call_Sent_On__c = DateTime.now();
        lstAgreement.add(TestAgreement7);
        
        insert lstAgreement;
        


    }

    private void setupTestData1() {

        testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech', Is_Payment_Risk__c = true, BillingStreet = 'test', BillingCity = 'test', BillingState = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert testAccount;
        
        Address__c testAddress = new Address__c( name = 'Test Account',
                                          recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId,
                                          Is_TPA_Account__c = true,
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

        tpaContact = new Contact(firstName = 'testfirstname', LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP' LIMIT 1];

        TestAgreement9 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement9.Client_Address__c = testAddress.Id;
        TestAgreement9.In_IMS_Review__c = todayDate.addDays(1);
        TestAgreement9.In_Auto_Approval_Process__c = todayDate.addDays(2);
        lstAgreement.add(TestAgreement9);


        TestAgreement10 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement10.Client_Address__c = testAddress.Id;
        TestAgreement10.In_IMS_Review__c = todayDate.addDays(2);
        TestAgreement10.In_Auto_Approval_Process__c = todayDate.addDays(1);
        lstAgreement.add(TestAgreement10);

        TestAgreement11 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement11.Client_Address__c = testAddress.Id;
        TestAgreement11.In_IMS_Review__c = todayDate.addDays(2);
        TestAgreement11.TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(1);
        lstAgreement.add(TestAgreement11);


        TestAgreement12 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement12.Client_Address__c = testAddress.Id;
        TestAgreement12.In_IMS_Review__c = todayDate.addDays(1);
        TestAgreement12.TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(2);
        lstAgreement.add(TestAgreement12);

        TestAgreement13 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement13.Client_Address__c = testAddress.Id;
        TestAgreement13.In_IMS_Review__c = todayDate.addDays(1);
        TestAgreement13.TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(2);
        TestAgreement13.In_Auto_Approval_Process__c = todayDate.addDays(3);
        lstAgreement.add(TestAgreement13);

        TestAgreement14 = UTL_TPA_SetupTestData.getNewTestAgreement( testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement14.Client_Address__c = testAddress.Id;
        TestAgreement14.In_IMS_Review__c = todayDate.addDays(1);
        TestAgreement14.TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(3);
        TestAgreement14.In_Auto_Approval_Process__c = todayDate.addDays(2);
        lstAgreement.add(TestAgreement14);

        TestAgreement15 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement15.Client_Address__c = testAddress.Id;

        TestAgreement15.In_IMS_Review__c = todayDate.addDays(3);
        TestAgreement15.TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(1);
        TestAgreement15.In_Auto_Approval_Process__c = todayDate.addDays(2);
        lstAgreement.add(TestAgreement15);
        insert lstAgreement;
        TST_BCH_TPA_CheckAgreementTLLA objBatchTest = new TST_BCH_TPA_CheckAgreementTLLA();
        objBatchTest.addAttachmentToParent(TestAgreement13.Id,'_TLLA');
        BCH_TPA_CheckAgreementTLLA objBatch = new BCH_TPA_CheckAgreementTLLA();
        Database.executeBatch(objBatch);

    }
    
    static testMethod void testConditionAllCases1()
    {
        TST_BCH_TPA_CheckAgreementTLLA objBatchTest = new TST_BCH_TPA_CheckAgreementTLLA();
        objBatchTest.setupTestData1();
        testAccount = new Account(Name = 'Test Account2', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech', Is_Payment_Risk__c = true, BillingStreet = 'test', BillingCity = 'test', BillingState = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        // create address
        Address__c testAddress = new Address__c( name = 'Test Account2',
                                          recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId,
                                          Is_TPA_Account__c = true,
                                          Account__c = testAccount.Id,
                                          Vendor_Registration_Number__c = 9997,
                                          Street__c = 'Test',
                                          City__c = 'Test',
                                          State__c = 'Test',
                                          Country__c = 'Test',
                                          PostalCode__c = 'Test',
                                          TPA_Local_Address_Required__c = false  
                                        );
            insert testAddress;

        // Create Contact
        tpaContact = new Contact(FirstName = 'testfirstname', LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        TestAgreement7 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement7.Client_Address__c = testAddress.Id;
        TestAgreement7.In_IMS_Review__c = todayDate.addDays(1);
        TestAgreement7.In_Auto_Approval_Process__c = todayDate.addDays(2);
        TestAgreement7.TLLA_Batch_Call_Sent_On__c = Date.today();
        insert TestAgreement7;
        list<TPA_Purpose__c> lstAllPurposes;
        BCH_TPA_CheckAgreementTLLA.CheckDiscrReasonOfOfferingandUse(TestAgreement7, 'Client', lstAllPurposes);
        Test.startTest();
        objBatchTest.addAttachmentToParent(TestAgreement9.Id,'_TLLA');
        objBatchTest.addAttachmentToParent(TestAgreement10.Id,'_TLLA');
        objBatchTest.addAttachmentToParent(TestAgreement11.Id,'_TLLA');
        // create account
        
        TestAgreement6 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement6.Client_Address__c = testAddress.Id;
        TestAgreement6.In_IMS_Review__c = todayDate.addDays(1);
        TestAgreement6.In_Auto_Approval_Process__c = todayDate.addDays(2);
        TestAgreement6.TLLA_Batch_Call_Sent_On__c = Date.today();
        insert TestAgreement6;
        BCH_TPA_CheckAgreementTLLA.CheckDiscrReasonOfOfferingandUse(TestAgreement6, 'Client', lstAllPurposes);
        
        
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test1', Legal_Entity_Name_for_TLLA__c = 'test Name1', Name_for_ESign__c = 'Test Esign1',Legal_Entity_Title__c = 'test title1');
        insert imsMasterLegalEntity;
        
        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test1', TPA_Request__c = TestAgreement6.Id,IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;
        
        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name1');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis1');
        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose1', TestAgreement6, tpaPurposeCategory, imsTpaPurpose, imsLegalEntity);
        tpaPurpose.All_Data_Assets__c = null;
        update tpaPurpose;
        
        lstAllPurposes = new List<TPA_Purpose__c>();
        lstAllPurposes.add(tpaPurpose);
        BCH_TPA_CheckAgreementTLLA.CheckDiscrReasonOfOfferingandUse(TestAgreement6, 'Batch', lstAllPurposes);
        //IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);
        //TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.createTpaDataAsset(TestAgreement17, tpaPurpose, imsDataAsset, imsLegalEntity);
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = TestAgreement6.id, Purpose__c = tpaPurpose.id,Asset_NametText__c = 'Midas');
        insert tpaDataAsset;
        BCH_TPA_CheckAgreementTLLA.CheckDiscrReasonOfOfferingandUse(TestAgreement6, 'Batch', lstAllPurposes);
        BCH_TPA_CheckAgreementTLLA objBatch = new BCH_TPA_CheckAgreementTLLA();
        Database.executeBatch(objBatch);
        Test.stopTest();
    }
    
    static testMethod void testConditionAllCases2()
    {
        TST_BCH_TPA_CheckAgreementTLLA objBatchTest = new TST_BCH_TPA_CheckAgreementTLLA();
        objBatchTest.setupTestData1();
        Test.startTest();
        objBatchTest.addAttachmentToParent(TestAgreement12.Id,'_TLLA');
        
        objBatchTest.addAttachmentToParent(TestAgreement13.Id,'_TLLA');
        objBatchTest.addAttachmentToParent(TestAgreement14.Id,'_TLLA');
        BCH_TPA_CheckAgreementTLLA objBatch = new BCH_TPA_CheckAgreementTLLA();
        Database.executeBatch(objBatch);
        Test.stopTest();
    }

    private void addAttachmentToParent(Id parentId,string Name)
    {
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = parentId;
        attachment.Name = Name + '_Test';
        attachment.Body = b;
        insert(attachment);
    }

    static testMethod void testConditionAllCases()
    {
        TST_BCH_TPA_CheckAgreementTLLA objBatchTest = new TST_BCH_TPA_CheckAgreementTLLA();
        TPA_Settings__c tpaSetting = new TPA_Settings__c(Is_Potential_Vendor_Submitted__c = true,
                                                         Base_Url__c = String.valueOf(URL.getOrgDomainUrl()),
                                                         TPA_RequestSubmitted_Email__c = 'neha.bansal@metacube.com,test1@test1.com',
                                                         Manual_Review_For_Special_Client_And_Use__c='001c0000016NHg9~Prescriber List Match only for overlap analysis, no prescriber communication',
                                                         TPA_DRN_Mails_Copy_To__c  = 'test@test.com,test1@test1.com',
                                                         Shared_Email__c = 'test@test.com',
                                                         TPA_Send_Emails__c = true,
                                                         TPA_Batch_to_Attempt_TLLA_Call_Duration__c = 720,
                                                         Stop_TLLA_Generation_Notice_Id__c = accessEmailTemplate('Stop TLLA Generation Notice').id);
        insert tpaSetting;
        objBatchTest.setupTestData();


        objBatchTest.addAttachmentToParent(TestAgreement5.Id,'_TLLA');
        objBatchTest.addAttachmentToParent(TestAgreement2.Id,'_TLLA');
        //objBatchTest.addAttachmentToParent(TestAgreement3.Id,'_TLLA');
        system.debug('TPA_Settings__c.getOrgDefaults().Stop_TLLA_Generation_Notice_Id__c :' +TPA_Settings__c.getOrgDefaults().Stop_TLLA_Generation_Notice_Id__c );
        Test.startTest();
        BCH_TPA_CheckAgreementTLLA objBatch = new BCH_TPA_CheckAgreementTLLA();
        Database.executeBatch(objBatch);
        Test.stopTest();
    }

    public static EmailTemplate accessEmailTemplate(String Name)
    {
        EmailTemplate validEmailTemplate = [select Name, DeveloperName, Body, TemplateType, FolderId, isActive from EmailTemplate where Name =: Name limit 1]  ;
        system.debug('validEmailTemplate:'+validEmailTemplate);
        return validEmailTemplate;
    }

    static testMethod void testConditionAllCases3()
    {
        Test.startTest();
        TST_BCH_TPA_CheckAgreementTLLA objBatchTest = new TST_BCH_TPA_CheckAgreementTLLA();
        objBatchTest.setupTestData3();
        BCH_TPA_CheckAgreementTLLA objBatch = new BCH_TPA_CheckAgreementTLLA();
        Database.executeBatch(objBatch);
        Test.stopTest();
    }

    private void setupTestData3() {

        // create account
        testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech', Is_Payment_Risk__c = true, BillingStreet = 'test', BillingCity = 'test', BillingState = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        // create address
        Address__c testAddress = new Address__c( name = 'Test Account',
                                          recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId,
                                          Is_TPA_Account__c = true,
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

        // Create Contact
        tpaContact = new Contact(FirstName = 'testfirstname', LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP' LIMIT 1];
        list<TPA_Purpose__c> lstAllPurposes;
        tpaRequest1 = new TPA_Request__c(OwnerId = UserInfo.getUserId(),
                                         Client_Region__c = 'US',
                                         Data_Provided_By__c = 'IMS in lieu of Client',
                                         Is_Data_Accessed_Via_IMS_Software__c = 'Yes',
                                         AMA_USPrescriberData__c = 'Yes',
                                         Does_the_request_require_information_con__c = 'Yes',
                                         Service_Provider_Address__c = testAddress.Id,
                                         Vendor_Company_Name__c = 'Test company',
                                         Is_Submitted__c = true,
                                         Request_Status__c = 'In Review By IQVIA',
                                         Data_Access_End_Date__c = todayDate.addDays(-3),
                                         Vendor_e_mail__c = 'test@mail.com',
                                         Vendor_contact_email_client__c = 'test@mail.com'
                                        );
        insert tpaRequest1;


        TestAgreement17 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement17.Client_Address__c = testAddress.Id;
        TestAgreement17.TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(2);
        TestAgreement17.In_Auto_Approval_Process__c = todayDate.addDays(1);
        TestAgreement17.Data_Access_Start_Date__c = todayDate;
        TestAgreement17.Data_Access_End_Date__c = todayDate.addDays(2);
        TestAgreement17.Data_Period_Start_Date__c = todayDate;
        TestAgreement17.Data_Period_End_Date__c = todayDate.addDays(2);
        lstAgreement.add(TestAgreement17);

        insert lstAgreement;
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test1', Legal_Entity_Name_for_TLLA__c = 'test Name1', Name_for_ESign__c = 'Test Esign1',Legal_Entity_Title__c = 'test title1');
        insert imsMasterLegalEntity;

        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test1', TPA_Request__c = TestAgreement17.Id,IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;

        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name1');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis1');
        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose1', TestAgreement17, tpaPurposeCategory, imsTpaPurpose, imsLegalEntity);
        tpaPurpose.All_Data_Assets__c = 'test';
        update tpaPurpose;
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);
        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.createTpaDataAsset(TestAgreement17, tpaPurpose, imsDataAsset, imsLegalEntity);
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true ,'test');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset, imsSecondaryDataAsset, imsLegalEntity, tpaRequest1, 'test');
        system.debug('');
        lstAllPurposes = new list<TPA_Purpose__c>();
        lstAllPurposes.add(tpaPurpose);
        BCH_TPA_CheckAgreementTLLA.CheckDiscrReasonOfOfferingandUse(TestAgreement17, 'Batch', lstAllPurposes);
        BCH_TPA_CheckAgreementTLLA.CheckDiscrReasonOfOfferingandUse(TestAgreement17, 'Client', lstAllPurposes);

    }

    static testMethod void testConditionAllCases4()
    {
        TST_BCH_TPA_CheckAgreementTLLA objBatchTest = new TST_BCH_TPA_CheckAgreementTLLA();
        objBatchTest.setupTestData4();
        Test.startTest();
        objBatchTest.addAttachmentToParent(TestAgreement16.Id,'_TLLA');
        objBatchTest.addAttachmentToParent(TestAgreement19.Id,'_TLLA');
        objBatchTest.addAttachmentToParent(TestAgreement20.Id,'_TLLA');
        BCH_TPA_CheckAgreementTLLA objBatch = new BCH_TPA_CheckAgreementTLLA();
        Database.executeBatch(objBatch);
        Test.stopTest();
    }

    private void setupTestData4() {

        // create account
        testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech', Is_Payment_Risk__c = true, BillingStreet = 'test', BillingCity = 'test', BillingState = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert testAccount;
        
        // create address
        Address__c testAddress = new Address__c( name = 'Test Account',
                                          recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId,
                                          Is_TPA_Account__c = true,
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

        // Create Contact
        tpaContact = new Contact(FirstName = 'testfirstname', LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        Profile p = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP' LIMIT 1];

        tpaRequest1 = new TPA_Request__c(OwnerId = UserInfo.getUserId(),
                                         Client_Region__c = 'US',
                                         Data_Provided_By__c = 'IMS in lieu of Client',
                                         Is_Data_Accessed_Via_IMS_Software__c = 'Yes',
                                         AMA_USPrescriberData__c = 'Yes',
                                         Does_the_request_require_information_con__c = 'Yes',
                                         Service_Provider_Address__c = testAddress.Id,
                                         Vendor_Company_Name__c = 'Test company',
                                         Is_Submitted__c = true,
                                         Request_Status__c = 'In Review By IQVIA',
                                         Data_Access_End_Date__c = todayDate.addDays(-3),
                                         Vendor_e_mail__c = 'test@mail.com',
                                         Vendor_contact_email_client__c = 'test@mail.com'
                                        );
        insert tpaRequest1;


        TestAgreement16 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement16.Client_Address__c = testAddress.Id;
        TestAgreement16.In_IMS_Review__c = todayDate.addDays(1);
        TestAgreement16.In_Auto_Approval_Process__c = todayDate.addDays(-2);
        TestAgreement16.TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(-2);
        lstAgreement.add(TestAgreement16);

        TestAgreement19 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement19.Client_Address__c = testAddress.Id;
        TestAgreement19.TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(2);
        TestAgreement19.In_IMS_Review__c = todayDate.addDays(1);
        TestAgreement19.In_Auto_Approval_Process__c = todayDate.addDays(-1);
        lstAgreement.add(TestAgreement19);

        TestAgreement20 = UTL_TPA_SetupTestData.getNewTestAgreement(testAddress.Id, true, tpaContact.id, testAddress.Id,  tpaContact.id);
        TestAgreement20.Client_Address__c = testAddress.Id;
        TestAgreement20.TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(2);
        TestAgreement20.In_Auto_Approval_Process__c = todayDate.addDays(-1);
        lstAgreement.add(TestAgreement20);

        insert lstAgreement;
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test1', Legal_Entity_Name_for_TLLA__c = 'test Name1', Name_for_ESign__c = 'Test Esign1',Legal_Entity_Title__c = 'test title1');
        insert imsMasterLegalEntity;

        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test1', TPA_Request__c = TestAgreement20.Id,IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;

        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name1');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis1');
        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose1', TestAgreement20, tpaPurposeCategory, imsTpaPurpose, imsLegalEntity);
        tpaPurpose.All_Data_Assets__c = 'test';
        update tpaPurpose;
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);
        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.createTpaDataAsset(TestAgreement20, tpaPurpose, imsDataAsset, imsLegalEntity);
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true ,'test');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset, imsSecondaryDataAsset, imsLegalEntity, tpaRequest1, 'test');
        system.debug('');

    }

    @TestSetup
    static void autosetupTestData() {
        UTL_TPA_SetupTestData.createTPASettingsData();
    }
}
