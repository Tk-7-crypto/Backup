@isTest
private class TST_BCH_TPA_Send_AMA_Renewal_Mail_Annua {
    private static Contact tpaContact;
    private static Account testAccount;
    private static Address__c testAddress;
    private static TPA_Request__c tpaRequest;
    private static TPA_Request__c objAgreement;
    
    static void setup() {
        
        // create account 
        testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech', BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        testAddress = new Address__c(Name = 'Test Address', recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true);
        insert testAddress;

        // Create Contact
        tpaContact = new Contact(FirstName = 'testfirstname', LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        
        objAgreement = UTL_TPA_SetupTestData.getAgreement();
        objAgreement.Data_Access_Start_Date__c  = date.newInstance(2017, 1, 1);
        objAgreement.Data_Access_End_Date__c  = Date.today().addYears(1);
        objAgreement.Request_Status__c = 'In Effect';
        objAgreement.Vendor_Contact_e_mail__c = 'test@test.com';
        objAgreement.Authorized_Signer_Email__c = 'test@test.com';
        objAgreement.Service_Provider_Address__c = testAddress.Id;
        objAgreement.Client_Address__c = testAddress.Id;
        upsert objAgreement;
        UTL_TPA_SetupTestData.addAttachmentToParent(objAgreement.Id, [Select Name from TPA_Request__c where Id = :objAgreement.Id].get(0).Name + '_TLLA' + '.pdf');
        System.debug('CD::01.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_SetupTestData.addAttachmentToParent(objAgreement.Id, [Select Name from TPA_Request__c where Id = :objAgreement.Id].get(0).Name + '_TLLA' + '.pdf_Completed');
        System.debug('CD::02.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_SetupTestData.addAttachmentToParent(objAgreement.Id, [Select Name from TPA_Request__c where Id = :objAgreement.Id].get(0).Name + '_TPA Helpful Hints Addendum' + '.pdf');
        System.debug('CD::03.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_SetupTestData.addAttachmentToParent(objAgreement.Id, [Select Name from TPA_Request__c where Id = :objAgreement.Id].get(0).Name + '_TPA Helpful Hints Addendum' + '.pdf_Completed');
        System.debug('CD::04.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        objAgreement.Request_Status__c = UTL_TPA.SIGNATURE_UNDER_VALIDATION;
        update objAgreement;

        //List<AMA_Agreement_Detail__c> ss = [Select Id, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.ClientContact__c, TPA_Request__r.Request_Status__c,DBL__c,Next_Year_Fees__c, Status_of_Renewal_Process__c,Agreement_End_Date__c from AMA_Agreement_Detail__c ];
        //system.debug('sslist: ' + ss);
        
    }
    
    @isTest
    private static void testBatch(){
        String CRON_EXP = '0 0 0 3 9 ? 2023';
        setup();
        Test.startTest();        
        objAgreement.Request_Status__c = 'In Effect';
        objAgreement.In_Effect_Date__c = Date.today().addDays(-1);
        update objAgreement;
        
        AMA_Agreement_Detail__c amaAgg1 = UTL_TPA_SetupTestData.getAMAAgreementDetail('IMS', 'Service Bureau II',objAgreement.id);
        amaAgg1.Next_Year_Fees__c = 21000;
        amaAgg1.Agreement_End_Date__c = Date.today().addYears(2);
        update amaAgg1;
        
        list<TPA_AMA_Settings__c> amaSettingList = new list<TPA_AMA_Settings__c>();
        
        EmailTemplate emailTemplate = UTL_TPA_SetupTestData.accessEmailTemplate('AMA_Yearly_Invoice_Notification_Mail');

        TPA_AMA_Settings__c amaSettingObj = new TPA_AMA_Settings__c();
        amaSettingObj.Name = 'Custom Setting';
        amaSettingObj.TP_US_Email_Id__c = 'test@test.com';
        amaSettingObj.Last_Day_Of_Year__c = '12-31';
        amaSettingObj.VendorRenewalNotifiAnnuallyTemplateId__c = emailTemplate.Id;
        amaSettingObj.CC_address_Vendor_Renewal_Notification__c = 'cctest@cctest.com';
        amaSettingObj.Send_Renewal_Notification__c = true;
        insert amaSettingObj;
        
        Database.executeBatch(new BCH_TPA_Send_AMA_Renewal_Mail_Annua(), 1);
        Test.stopTest();
    }
}