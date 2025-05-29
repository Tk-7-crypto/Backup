@isTest(seeAllData = false)
public class TST_BCH_TPA_AutoWeeklyExceptionReport {
    private static List<TPA_Request__c> tpaRequests;
    private static List<dsfs__DocuSign_Status__c> testDsEnvelopes;

    //different status
    private static final String DS_VOIDED = 'Voided';
    private static final String DS_SENT = 'Sent';
    private static final String DS_DECLINED = 'Declined';
    private static final String DS_COMPLETED = 'Completed';
    private static final String STATUS_AwaitVendSubm = 'Awaiting Vendor Submission';
    private static final String STATUS_InRevByIMS = 'In Review By IMS';
    private static final String STATUS_InRevByIQVIA = 'In Review By IQVIA';
    private static final String STATUS_AwaitVendSign = 'Awaiting Vendor Signature';
    private static final String STATUS_InEffect = 'In Effect';
    private static final String STATUS_IMSDenied = 'IMS Denied';
    private static final String STATUS_Expired = 'Expired';
    private static final String STATUS_Cancelled = 'Cancelled';
    private static final String STATUS_VendorCancelled = 'Vendor Canceled ‘17 AMA-TPA Exp-12/31/16';
    private static final String STATUS_AMACancelled = 'AMA Cancelled';
    private static final String STATUS_AMADiscontinued = 'AMA Discontinued';
    private static final String STATUS_ClientDiscontinued = 'Client Discontinued';
    private static final String STATUS_ClientSubmitted = 'Client Submitted';
    private static final String STATUS_InitializingVendor = 'Initializing Vendor';
    
	@isTest
    public static void testAutoWeeklyExceptionsReport() {

        Test.startTest();

        //  String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);

        // Schedule the test job
        //String jobId = System.schedule('testDailyScheduler', CRON_EXP, new TPA_Schedular_Daily_Exception_Rpt_Local());
        //String jobId1 = System.schedule('testWeeklyScheduler', CRON_EXP, new TPA_Schedular_Weekly_Exception_Rpt_Legal());
        // Wrapper class coverage
        
        BCH_TPA_AutoWeeklyExceptionReport bchObj = new BCH_TPA_AutoWeeklyExceptionReport('check TPA requests');
        
        Database.executeBatch(bchObj);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testAutoweeklyExceptionReport2(){
        Test.startTest();
        BCH_TPA_AutoWeeklyExceptionReport bchObj1 = new BCH_TPA_AutoWeeklyExceptionReport('check vendor address extension');
        Database.executeBatch(bchObj1);
        Test.stopTest();
    }
	
    @testSetup
    private static void setupTestData()
    {
        
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        //create custom setting record
        TPA_Settings__c objTPASetting = new TPA_Settings__c();
        objTPASetting.TPA_Auto_Exception_Rpt_Recepients_Local__c = 'test@test.com';
        objTPASetting.TPA_Auto_Exception_Rpt_Recepients_Legal__c = 'test@test.com';
        objTPASetting.Include_Test_Records_in_Exception_Report__c = true;
        objTPASetting.Base_Url__c = String.valueOf(URL.getOrgDomainUrl());
        objTPASetting.TPA_RequestSubmitted_Email__c = 'testt@imshealth1.com.dev2';

        insert objTPASetting;

        //Create Account
        Account testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        // Create Address
        Address__c testAddress =  new Address__c(Name = 'Test Account', CurrencyIsoCode = 'USD', Account__c = testAccount.Id, Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
        insert testAddress;

        

        //Create Contact
        Contact testContact = new Contact( FirstName = 'TestFirstName',
                                        LastName = 'con',
                                        AccountId = testAccount.Id,
                                        CurrencyIsoCode = 'USD',
                                        Email = 'test@mail.com',
                                        Title = 'Dev');
        insert testContact;


        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAddress.id);
        tpaRequest1.Request_Status__c = STATUS_InRevByIQVIA;
        update tpaRequest1;
        
        TPA_Commercial_Review__c comRev = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Combination Approved',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='test Reason',TPA_Request__c=tpaRequest1.Id);
        insert comRev;
        
        List<Task> taskLists =  new List<Task>();
        Task taskRecord = new Task(WhatId = tpaRequest1.Id, Subject = 'Data Release Notification Sent');
        taskLists.add(taskRecord);
        Task taskRecord1 = new Task(WhatId = tpaRequest1.Id, Subject = 'Copy of executed');
        taskLists.add(taskRecord1);
        Task taskRecord2 = new Task(WhatId = tpaRequest1.Id, Subject = 'Client Courtesy Email');
        taskLists.add(taskRecord2);
        
        insert taskLists;
        
        TPA_Master_Extension_Information__c tPAMasterExtensionInformation = new TPA_Master_Extension_Information__c(TPA_Accounts_Address__c = testAddress.id, Return_Destruction_Ack_Outstanding__c = true);
        insert tPAMAsterExtensionInformation;

        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test', Legal_Entity_Name_for_TLLA__c = 'test Name', Name_for_ESign__c = 'Test Esign',Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;

        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test', TPA_Request__c = tpaRequest1.Id,IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;

        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');

        IMS_TPA_Purpose__c imsTpaPurpose1 = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name1');
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);

        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose', tpaRequest1, tpaPurposeCategory, imsTpaPurpose, imsLegalEntity);


        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset, imsLegalEntity);

        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true ,'test');
      
        

        //Create envelopes 1-4
        testDsEnvelopes = new List<dsfs__DocuSign_Status__c>();
        testDsEnvelopes.add(new dsfs__DocuSign_Status__c(TPA_Request__c = tpaRequest1.Id, dsfs__Envelope_Status__c = 'Sent'));

        insert testDsEnvelopes;
    }
}
