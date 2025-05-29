@isTest(SeeAllData=false)
public class TST_CNT_TPA_ManualDDNTrigger { 
    static TPA_Agreement_Additional_Field__c tpaAgreeAdditionalObj;
    static TPA_Request__c tpaRequest;
    static void setup() { 
        createMultilingualTemplateSettingData();
        TPA_Text_Editor__c tpaEmailFooter = new TPA_Text_Editor__c(Page_Name__c = 'PageName', Content__c = 'PageContent', Page_Title__c = 'emailFooter', Page_Type__c = 'PageType', English_Translation__c = 'Test English Content', Japanese_Translation__c = 'Test Japanese Content', Is_Active__c = true);
        insert tpaEmailFooter;
        
        // create account
        Account testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech',  Is_Payment_Risk__c = true,  BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        System.debug('CD::01.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        Address__c testAddress = new Address__c(Account__c = testAccount.Id, recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, is_TPA_Account__c=true, Vendor_Tier__c = 'Y', Vendor_Registration_Number__c = 9999);
        insert testAddress;
        System.debug('CD::02.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // Create Contact
        Contact tpaContact = new Contact(FirstName = 'Test',LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        System.debug('CD::03.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAddress.id);
        TPA_Contact__c tpaContact2 = UTL_TPA_SetupTestData.getTPAContactByReqId(tpaRequest);
        System.debug('CD::04.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaAgreeAdditionalObj = new TPA_Agreement_Additional_Field__c();
        tpaAgreeAdditionalObj.Related_TPA_Request__c = tpaRequest.Id;
        insert tpaAgreeAdditionalObj;
        tpaRequest.TPA_Authorised_Signer__c = 'No';
        tpaRequest.Request_Status__c = 'Expired';
        tpaRequest.Vendor_e_mail__c = 'test@gmail.com';
        system.debug('clientcontact'+tpaContact.Id);
        system.debug('clientcontact2'+tpaRequest.ClientContact__r.Id);
        tpaRequest.ClientContact__c = tpaContact.Id;
        tpaRequest.Authorized_Signer_Email__c = 'test1@gmail.com';
        tpaRequest.Vendor_Language__c = 'English';
        tpaRequest.Client_Language__c = 'English';
        tpaRequest.TP_Processor_Email__c = 'test9@mail.com';
        update tpaRequest;
        System.debug('CD::05.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
    }
    public static void createMultilingualTemplateSettingData() {
        String templateid = UTL_TPA_SetupTestData.getTestEmailTemplateId();
        list<TPA_Multilingual_Template_Setting__c> setObjList = new list<TPA_Multilingual_Template_Setting__c>();
        TPA_Multilingual_Template_Setting__c obj12 = new TPA_Multilingual_Template_Setting__c(Name = 'Test12', label__c ='Email 3Day Notice of Ack DD', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj15 = new TPA_Multilingual_Template_Setting__c(Name = 'Test15', label__c ='Email 3Day Notice of Ack DD', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        setObjList.add(obj12);
        setObjList.add(obj15);
        insert setObjList;
    }
    
    static testMethod void unitTest1() {
        setup();
        Test.StartTest();
        String query = 'Select Id, Vendor_Contact_e_mail__c, TP_Processor_Email__c, ClientContact__c, Authorized_Signer_Email__c,(select id, Email__c from TPA_Request_Contacts__r) from TPA_Request__c where Request_Status__c = \'Expired\'';
        List<TPA_Request__c> requestList = Database.Query(query);
        System.debug('----------------------------> ' + Database.Query(query));
        system.debug('requestlist'+requestList.size());
        if(tpaRequest != null) {
            
            TPA_Agreement_Additional_Field__c vendorOffRetAckObj = new TPA_Agreement_Additional_Field__c(Vendor_DDN_First_Name__c = 'test First name',
                                                                                                         Vendor_DDN_Last_Name__c = 'test LAst Name',
                                                                                                         Vendor_DDN_Title__c = 'test vendor title',
                                                                                                         Vendor_DDN_Email__c = 'test2@mail.com',
                                                                                                         Related_TPA_Request__c = tpaRequest.Id);
            
            system.debug('tparequestnew'+tpaRequest);
            String isVendorCorrect = 'Yes';
            PageReference pageRef = Page.VFP_TPA_ManualDDNTrigger;
            pageRef.getParameters().put('id', tpaRequest.Id);
            Test.setCurrentPage(pageRef);
            CNT_TPA_ManualDDNTrigger venOffRetAckCon = new CNT_TPA_ManualDDNTrigger();
            venOffRetAckCon.requestValidateOnLoad();
            
            String vendorOffRetAckJSON2 = JSON.serialize(vendorOffRetAckObj );
            String isVendorCorrect2 = JSON.serialize(isVendorCorrect );
            CNT_TPA_ManualDDNTrigger.saveRequest(vendorOffRetAckJSON2 , isVendorCorrect2);
            
            venOffRetAckCon.getObjectTpaRequestToEdit();
            venOffRetAckCon.gettpaAgreementAdditionalFieldData();
        }
    }
    static testMethod void unitTest2() {
        setup();
        Test.StartTest();
        String query = 'Select Id, Vendor_Contact_e_mail__c, TP_Processor_Email__c, ClientContact__c, Authorized_Signer_Email__c,(select id, Email__c from TPA_Request_Contacts__r) from TPA_Request__c where Request_Status__c = \'Expired\'';
        List<TPA_Request__c> requestList = Database.Query(query);
        System.debug('----------------------------> ' + Database.Query(query));
        system.debug('requestlist'+requestList.size());
        if(tpaRequest != null) {
            
            TPA_Agreement_Additional_Field__c vendorOffRetAckObj = new TPA_Agreement_Additional_Field__c(Vendor_DDN_First_Name__c = 'test First name',
                                                                                                         Vendor_DDN_Last_Name__c = 'test LAst Name',
                                                                                                         Vendor_DDN_Title__c = 'test vendor title',
                                                                                                         Vendor_DDN_Email__c = 'test3@mail.com',
                                                                                                         Related_TPA_Request__c = tpaRequest.Id);
            
            String isVendorCorrect = 'No';
            PageReference pageRef = Page.VFP_TPA_ManualDDNTrigger;
            pageRef.getParameters().put('id', tpaRequest.Id);
            Test.setCurrentPage(pageRef);
            CNT_TPA_ManualDDNTrigger venOffRetAckCon = new CNT_TPA_ManualDDNTrigger();
            venOffRetAckCon.requestValidateOnLoad();
            
            String vendorOffRetAckJSON2 = JSON.serialize(vendorOffRetAckObj );
            String isVendorCorrect2 = JSON.serialize(isVendorCorrect );
            CNT_TPA_ManualDDNTrigger.saveRequest(vendorOffRetAckJSON2 , isVendorCorrect2);
            
            venOffRetAckCon.getObjectTpaRequestToEdit();
            venOffRetAckCon.gettpaAgreementAdditionalFieldData();
        }
    }
    
}