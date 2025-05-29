@isTest
private class TST_CNT_TPA_AgrmntSendForSignature {

    static testMethod void myUnitTest() {
        TPA_Request__c tpaRequest1;
        Contact tpaContact;
        Account testAccount;
        Address__c testAddress;
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        Date todayDate = Date.today();
        
        // create account 
        testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        // create address
        testAddress = new Address__c(Name = 'Test Account', recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, Account__c = testAccount.Id, CurrencyIsoCode = 'USD', Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');//Modified by C.P.Pandey under Issue-7181
        insert testAddress;
        
        // Create Contact
        tpaContact = new Contact(FirstName = 'TestFirstName', LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        
        tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAddress.id);
        tpaRequest1.Data_Access_Start_Date__c = Date.Today();
        tpaRequest1.Data_Access_End_Date__c = Date.Today().addDays(5);
        tpaRequest1.Client_Off_Notification_Ack_Date__c = DateTime.Now();
        tpaRequest1.Vendor_Off_Notification_Ack_Date__c = DateTime.Now();
        update tpaRequest1;
        
        Blob b = Blob.valueOf('Test Data');        
        Attachment attachment = new Attachment();
        attachment.ParentId = tpaRequest1.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        
        Attachment attachment1 = new Attachment();
        attachment1.ParentId = tpaRequest1.Id;
        attachment1.Name = 'Test Attachment for Parent';
        attachment1.Body = b;
        
        Attachment attachment2 = new Attachment();
        attachment2.ParentId = tpaRequest1.Id;
        attachment2.Name = 'Test Attachment for Parent';
        attachment2.Body = b;
        
        Attachment attachment3 = new Attachment();
        attachment3.ParentId = tpaRequest1.Id;
        attachment3.Name = 'Test Attachment for Parent';
        attachment3.Body = b;
        
        Attachment attachment4 = new Attachment();
        attachment4.ParentId = tpaRequest1.Id;
        attachment4.Name = 'Test Attachment for Parent';
        attachment4.Body = b;
        
        Attachment attachment5 = new Attachment();
        attachment5.ParentId = tpaRequest1.Id;
        attachment5.Name = 'Test Attachment for Parent';
        attachment5.Body = b;
        
        Attachment attachment6 = new Attachment();
        attachment6.ParentId = tpaRequest1.Id;
        attachment6.Name = 'Test Attachment for Parent';
        attachment6.Body = b;
        
        insert new List<Attachment>{attachment, attachment1, attachment2, attachment3, attachment4, attachment5, attachment6};
        
        PageReference pageRef = Page.VFP_TPA_AgrmntSendForSignature;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', tpaRequest1.Id);
        ApexPages.currentPage().getParameters().put('mandatoryDocsId', attachment.Id+'TLLA:'+attachment1.Id+'AMA:'+attachment2.Id+'Addendum'+attachment3.Id+'TechLi'
                                                   +attachment4.Id+'TechAm'+attachment5.Id+'AMAFL'+attachment6.Id+UTL_TPA.helpfulHintsDocLabel);
        
        CNT_TPA_AgrmntSendForSignature controller = new CNT_TPA_AgrmntSendForSignature();
        CNT_TPA_AgrmntSendForSignature.submitDocusign(tpaRequest1.Id, attachment.Id);
        controller.redirectToDocusignCreateEnvelopePage();
    }
}