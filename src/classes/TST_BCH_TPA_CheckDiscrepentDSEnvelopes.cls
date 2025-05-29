@isTest(seeAllData = false)
public with sharing class TST_BCH_TPA_CheckDiscrepentDSEnvelopes {

    private static List<TPA_Request__c> tpaRequests;
    private static List<TPA_Request__c> testAgreements;
    private static List<dsfs__DocuSign_Envelope__c> testDsEnvelopes;
    private static List<dsfs__DocuSign_Status__c> testDsStatuses;

    //different statuses
    private static final String DS_DELIVERED = 'Delivered';
    private static final String DS_SENT = 'Sent';
    private static final String STATUS_SentForSign = 'Sent for Signature';
    
    public static testMethod void testWeeklyDiscrepentDSEnvelopesReport() {
        setupTestData();

        Test.startTest();

        String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);

        // Schedule the test job
        String jobId = System.schedule('testDailyScheduler', CRON_EXP, new SCH_TPA_CheckDiscrepentDSEnvelopes());
        dsfs__DocuSign_Status__c testDsStatus = [SELECT id, Name, dsfs__DocuSign_Envelope_ID__c,  dsfs__Envelope_Status__c, CreatedDate, dsfs__Sent_Date_Time__c, dsfs__Completed_Date_Time__c, Related_TPA_Request_Number__c, TPA_Request__r.Vendor_Name_f__c, TPA_Request__r.Client_Name__c,  TPA_Request__r.Request_Status__c FROM dsfs__DocuSign_Status__c WHERE TPA_Request__r.Is_Submitted__c = true AND dsfs__Envelope_Status__c IN ('Sent', 'Delivered') LIMIT 1];
        
        // Wrapper class coverage
        BCH_TPA_CheckDiscrepentDSEnvelopes.watchListWrapper awr = new BCH_TPA_CheckDiscrepentDSEnvelopes.watchListWrapper(testDsStatus, null);

        Test.stopTest();
    }


    private static void setupTestData()
    {
        //create custom setting record
        TPA_Settings__c objTPASetting = new TPA_Settings__c();
        objTPASetting.TPA_Auto_Exception_Rpt_Recepients_Local__c = 'test@test.com';
        objTPASetting.TPA_Auto_Exception_Rpt_Recepients_Legal__c = 'test@test.com';
        objTPASetting.Include_Test_Records_in_Exception_Report__c = true;
        objTPASetting.Base_Url__c = String.valueOf(URL.getOrgDomainUrl());
        objTPASetting.TPA_RequestSubmitted_Email__c = 'testt@imshealth1.com.dev2';

        insert objTPASetting;

        TPA_Request__c testagreement1 = UTL_TPA_SetupTestData.getAgreementByName();
        testagreement1.Request_Status__c = STATUS_SentForSign;
        testagreement1.Is_Submitted__c = true;
        update testagreement1;

        TPA_Request__c testagreement2 = UTL_TPA_SetupTestData.getAgreementByName();
        testagreement2.Request_Status__c = STATUS_SentForSign;
        testagreement1.Is_Submitted__c = true;
        update testagreement2;
        
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test', Legal_Entity_Name_for_TLLA__c = 'test Name', Name_for_ESign__c = 'Test Esign',Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;

        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test', TPA_Request__c = testagreement1.Id,IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;

        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');

        IMS_TPA_Purpose__c imsTpaPurpose1 = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name1');
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);

        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose', testagreement1, tpaPurposeCategory, imsTpaPurpose, imsLegalEntity);
        TPA_Purpose__c tpaPurpose1 = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose1', testagreement1, tpaPurposeCategory, imsTpaPurpose1, imsLegalEntity);

        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.createTpaDataAsset(testagreement1, tpaPurpose, imsDataAsset, imsLegalEntity);

        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true ,'test');
    
        //Create envelopes
        
        dsfs__DocuSign_Envelope__c testDsEnvelope1 = new dsfs__DocuSign_Envelope__c();
        testDsEnvelope1.dsfs__Document_Name__c = 'SentEnvelope';
        insert testDsEnvelope1;
        
        dsfs__DocuSign_Envelope__c testDsEnvelope2 = new dsfs__DocuSign_Envelope__c();
        testDsEnvelope2.dsfs__Document_Name__c = 'DeliveredEnvelope';        
        insert testDsEnvelope2;
        
        testDsStatuses = new List<dsfs__DocuSign_Status__c>();
        testDsStatuses .add(new dsfs__DocuSign_Status__c(TPA_Request__c = testagreement1.Id, dsfs__Envelope_Status__c = 'Sent', dsfs__DocuSign_Envelope_ID__c = testDsEnvelope1.Id));
        testDsStatuses .add(new dsfs__DocuSign_Status__c(TPA_Request__c = testagreement2.Id, dsfs__Envelope_Status__c = 'Delivered', dsfs__DocuSign_Envelope_ID__c = testDsEnvelope2.Id));
        insert testDsStatuses ;
    }

}
