@isTest(seeAllData = false)
public class TST_QBL_TPA_UpdateFutureApprovalAction {
    private static TPA_Request__c tpaRequest;
    private static Contact con;
    private static Account acc;
    private static Address__c account;
    private static Address__c testAccount;
    private static String TEST_REGION = 'US';
    private static IMS_TPA_Purpose__c imsPurpose1;
    private static TPA_Purpose__c tpaPurpose1;
    private static IMS_TPA_Purpose_Description__c imsPurposeDescription1;
    private static TPA_Purpose_Description__c tpaPurposeDescription1;
    private static TPA_Purpose_Category__c purposeCategory1;
    private static IMS_Data_Asset__c imsDataAss1;
    private static TPA_Data_Asset__c tpaDataAss1;
    private static IMS_Secondary_Data_Asset__c imsSecondaryDataAss1;
    private static TPA_Secondary_Data_Asset__c tpaSecondaryDataAss1;
    private static Boolean isAwaitingClientConfirmationMailReq = false;
    
    public static testMethod void test_QBL_TPA_UpdateFutureApprovalAction()
    {
        String SuppLangCodeFieldNameLocalNameTest  = UTL_TPA_Multilingual.SuppLangCodeFieldNameLocalName;
        Map<String, String> supportedLanguageMaptest = new Map<String, String>();
        supportedLanguageMaptest.put('en_US' , 'English~English_Translation__c~English');
        
        QBL_TPA_UpdateFutureApprovalAction queuableObject = new QBL_TPA_UpdateFutureApprovalAction();
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 3];
        List<TPA_Additional_Term__c > agrList  = [SELECT Id FROM TPA_Additional_Term__c];
        TPA_Request__c tpaRequest = SRV_TPA_TPARequest.getRequestInfo(requestList[0].id);


        queuableObject.request = tpaRequest ;
        queuableObject.sendTLLAForSign = true;
        queuableObject.addTermToUpdate = agrList;
        System.enqueueJob(queuableObject);
    }
    
     @TestSetup static void setup() {
        TST_QBL_TPA_sendCommercialMail obj = new TST_QBL_TPA_sendCommercialMail();
        UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createTpaTestEditorData('TPA Email Footer', 'Test', 'emailFooter', 'emailFooter');
        Date todayDate = Date.today();
       // acc = new Account(Name = 'Test Account',Industry = 'Associations');
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
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        tpaRequest.OwnerId = UserInfo.getUserId();
        tpaRequest.Client_Region__c = TEST_REGION;
        tpaRequest.Data_Provided_By__c = 'IQVIA in lieu of Client';
        tpaRequest.Is_Data_Accessed_Via_IMS_Software__c = 'Yes';
        tpaRequest.AMA_USPrescriberData__c = 'Yes';
        tpaRequest.Does_the_request_require_information_con__c = 'Yes';
        tpaRequest.Service_Provider_Address__c = account.Id;
        tpaRequest.Client_Address__c = account.Id;
        tpaRequest.ClientContact__c = con.Id;
        tpaRequest.Vendor_Company_Name__c = 'Test company';
        tpaRequest.Is_Potential_Vendor_Case__c = false;
        tpaRequest.TP_Processor_Email__c = 'a.a@g.com';
        tpaRequest.Authorized_Signer_Email__c = 'test@mail.com';
        tpaRequest.Data_Delivered_By__c = 'IQVIA Software';
        tpaRequest.Data_Access_Start_Date__c = Date.newInstance(2016, 10, 20);
        tpaRequest.Data_Access_End_Date__c = Date.newInstance(2017, 12, 31);
        tpaRequest.Request_Status__c = 'In Review By IQVIA';
        tpaRequest.Is_Submitted__c = true;
        tpaRequest.Is_Manually_Approved__c = true;
        tpaRequest.Client_Off_Notification_Ack_Date__c = Date.newInstance(2017, 12, 31);
        tpaRequest.Vendor_Off_Notification_Ack_Date__c = Date.newInstance(2017, 12, 31);
        tpaRequest.Is_Exhibit_Required__c = true;
        tpaRequest.Vendor_Language__c = 'Japanese';
        tpaRequest.Client_Language__c = 'English';
        insert tpaRequest;
         
        IMS_Legal_Entity__c imsLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity_Template();
        imsLegalEntity.Name = 'IQVIA Ltd.';
        imsLegalEntity.Legal_Entity_Name_for_TLLA__c = 'IQVIA Ltd.';
        imsLegalEntity.TPA_Request__c = tpaRequest.Id;
        insert imsLegalEntity;
         
        List<TPA_Additional_Term__c> additionalTerms = new List<TPA_Additional_Term__c>();
        TPA_Additional_Term__c tpaAddTermForParent = new TPA_Additional_Term__c(CurrencyIsoCode='INR',TPA_Request__c = tpaRequest.Id,TPA_Legal_Entity_1__c = imsLegalEntity.Id);
        insert tpaAddTermForParent;
       
    }

}