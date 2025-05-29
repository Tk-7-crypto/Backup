@isTest(seeAllData = false)
public class TST_TGRH_TPAAMAAgreement {
 
    public static testMethod void testAgreementDetailTriggerHandlerMethods() {
        
        Test.startTest();

        AMA_Agreement_Detail__c objAgreementUpdated = getTestAgreement();
        
        objAgreementUpdated.Ex_Client__c = 'test updated Client';
        objAgreementUpdated.Ex_DBL__c='IMS';
        objAgreementUpdated.Ex_Client_Services_On_Behalf_Of__c='Updated Client Services';
        objAgreementUpdated.Ex_Contract_Type__c= 'updated contract type';
        objAgreementUpdated.Ex_Contract_End_Date__c=Date.newInstance(2018, 12, 31);
        objAgreementUpdated.Ex_Contract_List_Type__c='updated list';
        objAgreementUpdated.Ex_Max_Fee_Reached__c=False;
        objAgreementUpdated.Ex_Offshore_Approval__c=False;
        objAgreementUpdated.Ex_Offshore_Location__c='udated location';
        objAgreementUpdated.Ex_Special_Terms_Conditions__c='udated Terms Conditions';
        objAgreementUpdated.AMA_Amount_to_be_Credited_Billed__c = 1000;
        objAgreementUpdated.Vendor_employee_access_data_in_country__c = 'india';
        
        update objAgreementUpdated;
                
        Test.stopTest();
    }
    
    // Added by Supriya Johari under Er-2906 starts
    public static testMethod void testTriggerHelperForOffshore()
    {
        
        AMA_Agreement_Detail__c objAgreementUpdated = getTestAgreement();
        
        Test.startTest();
        objAgreementUpdated.AMA_Manual_Review__c = true;
        objAgreementUpdated.AMA_Manual_Trigger_Reasons__c = 'Vendor requires offshore approval';
        update objAgreementUpdated;
        objAgreementUpdated.AMA_Manual_Trigger_Reasons__c = null;
        objAgreementUpdated.Vendor_Reasons_for_Termination__c = 'Test vendor reason termination update';
        objAgreementUpdated.Status_of_Cancelation_Request__c = 'Cancelled';
        objAgreementUpdated.Activated_for_SAP_Report__c = Date.newInstance(2016 , 10 ,20);
        update objAgreementUpdated;
        TGRH_TPAAMAAgreement amaAgrDetClassObj = new TGRH_TPAAMAAgreement(true);
        Boolean triggContext = amaAgrDetClassObj.IsTriggerContext;
        Test.stopTest();
    }
    // Added by Supriya Johari under Er-2906 ends
	
    public static testMethod void testTriggerHelperForOffshore1()
    {
        
        AMA_Agreement_Detail__c objAgreementUpdated = getTestAgreement();
        
        Test.startTest();
        AMA_Agreement_Detail__c amaAgr = [Select id, Name, Ex_DBL__c, Agreement_Start_Date__c, Agreement_End_Date__c, Is_Prorated__c, 
                                Fee_Reduced__c, TPA_Request__c, Vendor_Legal_Name__c,Client__c,Contract_Type__c,
                                Current_Year_Fees__c, DBL__c,Current_Year__c,Final_End_Year__c,Next_Year__c,
                                 Initial_Termination_Date__c,Max_Fee_Reached__c,Is_AMA_License_Required__c,
                                 AMA_Manual_Review__c,TPA_Request__r.TPA_Request_Temporary_Status__c,
                                 TPA_Request__r.Pending_Acknowledgements__c,TPA_Request__r.Id, 
                                 TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,  TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c, 
                                 TPA_Request__r.Authorized_Signer_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c,
                                 TPA_Request__r.Request_Status__c, Template__c, Next_Year_Fees__c
                                 from AMA_Agreement_Detail__c  limit 1];
        amaAgr.AMA_Manual_Review__c = true;
        amaAgr.AMA_Manual_Trigger_Reasons__c = 'Vendor requires offshore approval';
        update amaAgr;
        TGRH_TPAAMAAgreement.sendOffshoreNotificationToDBL(amaAgr);
        Test.stopTest();
    }
     
    public static AMA_Agreement_Detail__c getTestAgreement() { 
        Date todayDate = Date.today();
        
        Account testAccount2 = new Account( name = 'TPA Test Account',
                                           BillingCountry = 'India',
                                           BillingState = 'Delhi',
                                           BillingCity = 'Test',
                                           BillingStreet = 'Test',
                                           BillingPostalCode = '123',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE' );
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
        //Test.startTest();
        
        
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
         
        list<TPA_AMA_Settings__c> amaSettingList = new list<TPA_AMA_Settings__c>();

        TPA_AMA_Settings__c amaSettingObj = new TPA_AMA_Settings__c(); //Custom Setting for Contact Fields
        amaSettingObj.Name='CreatedDate';//Static record 1 of custom setting
        amaSettingObj.CC_Address_For_Vendor_Offshore_Mail__c  = 'supriya.johari@metacube.com';
        amaSettingObj.Vendor_Contact_ID__c = testAccount2.id;
        amaSettingObj.Offshore_Vendor_Revised_Noti_Template_ID__c = getEmailTemplate('AMA Email Notification: AMA Offshore Form for Vendor').Id;
        amaSettingObj.Dev_Mail_ID__c  = 'testDev@test.com';
        amaSettingList.add(amaSettingObj);

        insert amaSettingList;
        
        return amaAgg;
    }
    
      public static Contact createContact(String name, id AccountID){
        
        Contact c1 = UTL_TPA_SetupTestData.getContact();
        c1.firstName = name;
        c1.lastName = name + '12';       
        c1.Accountid = AccountID;
        insert c1;
        
        return c1;
    }
    
    
    public static EmailTemplate getEmailTemplate(String name)
    {
        EmailTemplate emailTemp = UTL_TPA_SetupTestData.accessEmailTemplate(name);
        return emailTemp;
    }
   

}
