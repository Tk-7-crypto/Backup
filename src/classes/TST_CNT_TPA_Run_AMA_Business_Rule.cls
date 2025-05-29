@isTest(SeeAllData=false)
public class TST_CNT_TPA_Run_AMA_Business_Rule {
    @testSetup
    static void setupData() {
        TPA_Settings__c objTpaSett = UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
        objTpaSett.TPA_BCC_Emails__c = 'testbcc@test.com';
        update objTpaSett;
        
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        
        Date todayDate = Date.today();
        
        Account testAccount2 = new Account( name = 'TPA Test Account',
                                           BillingCountry = 'India',
                                           BillingState = 'Delhi',
                                           BillingCity = 'Test',
                                           BillingStreet = 'Test',
                                           BillingPostalCode = '123',
                                           CustomerSegment__c = 'GOVERNMENT',
                                           Sub_Industry__c = 'STATE' );
        insert testAccount2;
        
        Address__c testAccount = UTL_TPA_SetupTestData.getAccount();
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAddress();
        testAccount.Name = 'Test Acc';
        testAccount.Account__c = testAccount2.Id;
        insert testAccount;
        insert testAccount1;
        
        Contact testContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name LIKE 'US TP Processor Profile CCP%' LIMIT 1];
        
        User testUser = UTL_TPA_SetupTestData.createTestUser(testContact, testProfile);
        List<TPA_Request__c> lstAgreement = new List<TPA_Request__c>();
        
        TPA_Request__c testAgreement2 = UTL_TPA_SetupTestData.gettestAgreement();
        testAgreement2.Request_Status__c = 'TPA Approved Awaiting AMA Approval';
        testAgreement2.AMA_USPrescriberData__c = 'Yes';
        testAgreement2.Data_Access_Start_Date__c = todayDate;
        testAgreement2.Data_Access_End_Date__c = todayDate.addDays(2);
        testAgreement2.Requires_Manual_Review__c = false;
        testAgreement2.TP_Processor_Email__c = 'a.a@gmail.com';
        testAgreement2.TP_Processor_Name__c = 'Test TP Processor';
        testAgreement2.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        testAgreement2.TPA_Authorised_Signer__c = 'Yes';
        testAgreement2.Client_Address__c = testAccount.Id;
        testAgreement2.Service_Provider_Address__c = testAccount.Id;
        testAgreement2.Client_Address__c = testAccount1.Id;
        testAgreement2.Service_Provider_Address__c = testAccount1.Id;
        testAgreement2.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        testAgreement2.Vendor_First_Name__c ='FName';
        testAgreement2.Vendor_Contact_Last_Name__c ='LName';
        testAgreement2.Client_Contact_Territory__c = 'USA';
        testAgreement2.Vendor_App_Submitted__c = Date.newInstance(2015, 10, 20);
        lstAgreement.add(testAgreement2);
        insert lstAgreement;
        Test.startTest();
        
        
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testAgreement2.id);
        amaAgg.AMA_Manual_Review__c = false;
        amaAgg.Is_AMA_License_Required__c = true;
        amaAgg.Current_Year_Fees__c  = 21000;
        amaAgg.Contract_Type__c = 'Service Bureau II';
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016 , 10 ,20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c='Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c='Telemarketing;Labeling';
        amaAgg.Invoice_Contact_Email__c='testinvoice@gmail.com';
        insert amaAgg;
        
        Test.stopTest();
        
    }
    
    public static testMethod void testcases1() {
        Test.startTest();
        AMA_Agreement_Detail__c amaAgr = [Select id, Name, Ex_DBL__c, Agreement_Start_Date__c, Agreement_End_Date__c, Is_Prorated__c, 
                                          Fee_Reduced__c, TPA_Request__c, Vendor_Legal_Name__c,Client__c,Contract_Type__c,
                                          Current_Year_Fees__c, DBL__c,Current_Year__c,Final_End_Year__c,Next_Year__c,
                                          Initial_Termination_Date__c,Max_Fee_Reached__c,Is_AMA_License_Required__c,
                                          AMA_Manual_Review__c,TPA_Request__r.TPA_Request_Temporary_Status__c,
                                          TPA_Request__r.Pending_Acknowledgements__c,TPA_Request__r.Id, 
                                          TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c,TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,  TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c, 
                                          TPA_Request__r.Authorized_Signer_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c,
                                          TPA_Request__r.Request_Status__c, Template__c, Next_Year_Fees__c
                                          from AMA_Agreement_Detail__c limit 1];
        PageReference pageRef = Page.VFP_TPA_Run_AMA_Business_Rule;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', amaAgr.Id);
        CNT_TPA_Run_AMA_Business_Rule offNotificationInstance = new CNT_TPA_Run_AMA_Business_Rule();
        
        offNotificationInstance.sendMails();
        Test.stopTest();
    }
}