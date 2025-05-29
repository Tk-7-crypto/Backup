@isTest(seeAllData=false)
public class TST_BCH_TPA_AMA_Billing_SAP_Rprt_FrNxtYr {

   private static Contact tpaContact;
    private static Account testAccount;
    private static Address__c testAddress;
    private static TPA_Request__c tpaRequest;
    private static TPA_Request__c objAgreement;
    @testSetup
    static  void testsetup() 
    {
         TPA_AMA_Settings__c obj = UTL_TPA_SetupTestData.createAMASetting();
         UTL_TPA_SetupTestData.createTpaTestEditorData('TPA Email Footer', 'Test', 'emailFooter', 'emailFooter');
        obj.Exclude_Test_Records_in_Report__c = false;
        update obj;
    }

   
    private static testmethod void testTST_SCH_TPA_AMA_Billing_Report_ForNextYr(){ 
       
        // create account 
        testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech', Is_Payment_Risk__c = true, BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        // create address
        testAddress =  new Address__c( name = 'Test Account',
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
        tpaContact = new Contact(firstName = 'testfirstname', LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com',  Title = 'Dev');
        insert tpaContact;
        
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAddress.id);
        tpaRequest.Data_Access_Start_Date__c  = date.newInstance(2017, 1, 1);
        tpaRequest.Data_Access_End_Date__c  = date.newInstance(2017, 2, 2);
        tpaRequest.Request_Status__c = 'In Effect';
        tpaRequest.Client_Address__c = testAddress.id;
        
        tpaRequest.Authorized_Signer_Email__c = 'soup@metacube.com';
        tpaRequest.Authorized_Signer_First_Name__c = 'Test';
        tpaRequest.Authorized_Signer_Last_Name__c  = 'Test Auth L';
        update tpaRequest;
        
        AMA_Agreement_Detail__c amaAgg1 = UTL_TPA_SetupTestData.getAMAAgreementDetail( 'IMS', 'Service Bureau II',tpaRequest.id);
        amaAgg1.Date_Agreement_Activated__c = system.now();
        amaAgg1.Contract_Type__c = 'Service Bureau II';
        amaAgg1.Current_Year_Fees__c = 21000;
        amaAgg1.Next_Year_Fees__c = 21000;
        amaAgg1.Invoice_Contact__c = 'Invoice test';
        amaAgg1.Invoice_Contact_Email__c = 'supriya.johari@metacube.com';
        amaAgg1.AMA_Amount_to_be_Credited_Billed__c = 0;
        upsert amaAgg1;
        BCH_TPA_AMA_Billing_SAP_Rprt_FrNxtYr agreementUpdateStatusTrigger = new BCH_TPA_AMA_Billing_SAP_Rprt_FrNxtYr();
        Database.executebatch(agreementUpdateStatusTrigger,2);
    }

    private static testmethod void testTST_SCH_TPA_AMA_Billing_Report_ForNextYr2(){ 
      
        testAccount = new Account(Name = 'Test Account1', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech', Is_Payment_Risk__c = true, BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        // create address
        testAddress =  new Address__c( name = 'Test Account',
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
        tpaContact = new Contact(firstName = 'testfirstname', LastName = 'Test1', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com',  Title = 'Dev');
        insert tpaContact;
        
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAddress.id);
        tpaRequest.Data_Access_Start_Date__c  = date.newInstance(2017, 1, 1);
        tpaRequest.Data_Access_End_Date__c  = date.newInstance(2017, 2, 2);
        tpaRequest.Request_Status__c = 'In Effect';
        tpaRequest.Client_Address__c = testAddress.id;
        
        update tpaRequest;
        
        AMA_Agreement_Detail__c amaAgg1 = UTL_TPA_SetupTestData.getAMAAgreementDetail( 'IMS', 'Service Bureau II',tpaRequest.id);
        amaAgg1.Date_Agreement_Activated__c = system.now();
        amaAgg1.Contract_Type__c = 'Service Bureau II';
        amaAgg1.Current_Year_Fees__c = 10500;
        amaAgg1.Next_Year_Fees__c = 10500;
        amaAgg1.Invoice_Contact__c = 'Invoice test';
        amaAgg1.Invoice_Contact_Email__c = 'supriya.johari@metacube.com';
        amaAgg1.AMA_Amount_to_be_Credited_Billed__c = 0;
        upsert amaAgg1;

        BCH_TPA_AMA_Billing_SAP_Rprt_FrNxtYr agreementUpdateStatusTrigger = new BCH_TPA_AMA_Billing_SAP_Rprt_FrNxtYr();
        Database.executebatch(agreementUpdateStatusTrigger,2);
        
    }
}