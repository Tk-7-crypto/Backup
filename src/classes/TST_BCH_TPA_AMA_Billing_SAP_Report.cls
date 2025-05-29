@isTest(seeAllData = false)
public class TST_BCH_TPA_AMA_Billing_SAP_Report {

    private static Contact tpaContact;
    private static Address__c testClientAccount;
    private static Address__c testAccount;
    public static TPA_Request__c tpaRequest;
  
    @testSetup
    public static void setupTestData() {

        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createTpaTestEditorData('TPA Email Footer', 'Test', 'emailFooter', 'emailFooter');
        Address__c TestAccount = UTL_TPA_SetupTestData.getTestAccount(); 
        
        // create test request
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        tpaRequest.OwnerId = UserInfo.getUserId();
        tpaRequest.Client_Region__c = 'US';
        tpaRequest.Data_Provided_By__c = 'IMS in lieu of Client';
        tpaRequest.Is_Data_Accessed_Via_IMS_Software__c = 'Yes';
        tpaRequest.AMA_USPrescriberData__c = 'Yes';
        tpaRequest.Does_the_request_require_information_con__c = 'Yes';
        tpaRequest.Service_Provider_Address__c = TestAccount.Id;
        tpaRequest.Client_Address__c = TestAccount.Id;
        tpaRequest.Vendor_Company_Name__c = 'Test company';
        tpaRequest.Authorized_Signer_Email__c = 'soup@metacube.com';
        tpaRequest.Vendor_Contact_Email_Client__c = 'soup.johari@metacube.com'; 
        tpaRequest.Vendor_Contact_e_mail__c = 'soup.johari@metacube.com';
        tpaRequest.Data_Access_End_Date__c = Date.today().addDays(-2);
        tpaRequest.Data_Access_Start_Date__c  = Date.today().addDays(-10);
        tpaRequest.Authorized_Signer_First_Name__c = 'Test';
        tpaRequest.Vendor_Contact_Name_f__c = 'Test ';
        tpaRequest.Authorized_Signer_First_Name__c  = 'Test Auth F';
        tpaRequest.Authorized_Signer_Last_Name__c  = 'Test Auth L';
        tpaRequest.Client_Company_Name_Address__c = TestAccount.Id;
        insert tpaRequest;
        Test.setCreatedDate(tpaRequest.id, System.now().addDays(-420));

    }


    public static testMethod void testExecute() {
    
        tpaRequest = [select id from TPA_Request__c limit 1];
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(tpaRequest.Id);
        amaAgg.Date_Agreement_Activated__c = system.now();
        amaAgg.Contract_Type__c = 'Service Bureau II';
        amaAgg.Current_Year_Fees__c = 21000;
        amaAgg.Invoice_Contact__c = 'Invoice test';
        amaAgg.Invoice_Contact_Email__c = 'supriya.johari@metacube.com';
        insert amaAgg;
        Test.setCreatedDate(amaAgg.id, System.now().addDays(-420));
        
        Test.startTest();
        
        String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);
        
        // Schedule the test job 
        String jobId = System.schedule('testScheduler', CRON_EXP, new SCH_TPA_AMA_Billing_SAP_Report());
        
        Test.stopTest();
    
    }

    public static testMethod void testExecute1() {
        tpaRequest = [select id from TPA_Request__c limit 1];
        AMA_Agreement_Detail__c amaAgg1 = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(tpaRequest.Id);
        amaAgg1.Contract_Type__c = 'Service Bureau II';
        amaAgg1.Current_Year_Fees__c = 10500;
        amaAgg1.AMA_Amount_to_be_Credited_Billed__c = 0;
        amaAgg1.Date_Agreement_Activated__c = system.now();
        amaAgg1.Invoice_Contact__c = 'Invoice test1';
        amaAgg1.Invoice_Contact_Email__c = 'soup.johari@metacube.com';
        insert amaAgg1;
        Test.setCreatedDate(amaAgg1.id, System.now().addDays(-420));
        Test.startTest();
        
        String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);
        
        // Schedule the test job 
        String jobId = System.schedule('testScheduler', CRON_EXP, new SCH_TPA_AMA_Billing_SAP_Report());
        
        Test.stopTest();
    }

    public static testMethod void testExecute2() {
        tpaRequest = [select id,Vendor_Contact_e_mail__c from TPA_Request__c limit 1];
        tpaRequest.Vendor_Contact_e_mail__c = 'soup@metacube.com';
        update tpaRequest;
        AMA_Agreement_Detail__c amaAgg1 = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(tpaRequest.Id);
        amaAgg1.Contract_Type__c = 'Service Bureau II';
        amaAgg1.Current_Year_Fees__c = 5250;
        amaAgg1.AMA_Amount_to_be_Credited_Billed__c = 0;
        amaAgg1.Date_Agreement_Activated__c = system.now();
        amaAgg1.Invoice_Contact__c = 'Invoice test1';
        amaAgg1.Invoice_Contact_Email__c = 'testInvoice@metacube.com';
        insert amaAgg1;
        Test.setCreatedDate(amaAgg1.id, System.now().addDays(-420));
        Test.startTest();
        
        String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);
        
        // Schedule the test job 
        String jobId = System.schedule('testScheduler', CRON_EXP, new SCH_TPA_AMA_Billing_SAP_Report());
        
        Test.stopTest();
    }
}
