@isTest(seeAllData=false)
public class TST_CNT_TPA_AMAOffshoreTemplate_Revised { 
    private static CNT_TPA_NewClientVendorMatch amaControllerObj;
    private static CNT_TPA_AMAOffshoreTemplate_Revised cntOffshoreTemplateObj;
    private static string serializeMapRecord;
    private static Contact tpaContact;
    private static Account testAccount;
    private static Address__c testAddress;
    private static TPA_Request__c tpaRequest;
    private static TPA_Request__c objAgreement;
   
    
    public static void createTestData() {
       
       
    }   
     
    /**
    * Setup test data required to run tests in a data independent fashion
    */    
    @testSetup static void setup() {
        // create account 
        testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        // create address
        testAddress =  new Address__c(Name = 'Test Account', recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, CurrencyIsoCode = 'USD', Account__c = testAccount.Id, Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
        insert testAddress;
        
        // Create Contact
        tpaContact = new Contact(FirstName = 'TestFirstName', LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAddress.id);
        objAgreement = UTL_TPA_SetupTestData.getAgreement(tpaRequest);
        objAgreement.Data_Access_Start_Date__c  = date.newInstance(2017, 1, 1);
        objAgreement.Data_Access_End_Date__c  = date.newInstance(2017, 2, 2);
        update objAgreement;
        
        AMA_Agreement_Detail__c amaAgg1 = UTL_TPA_SetupTestData.getAMAAgreementDetail('IMS', 'Service Bureau II',objAgreement.Id);
        amaAgg1.Vendor_employee_access_data_in_country__c = 'United States';
        update amaAgg1;
               
        list<TPA_AMA_Settings__c> amaSettingList = new list<TPA_AMA_Settings__c>();//bulk List of custom setting object for bulk insert

        TPA_AMA_Settings__c amaSettingObj = new TPA_AMA_Settings__c(); //Custom Setting for Contact Fields
        amaSettingObj.Name='CreatedDate';//Static record 1 of custom setting
        amaSettingObj.CC_Address_For_DBL_Offshore_Mail__c = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_For_Vendor_Offshore_Mail__c  = 'supriya.johari@metacube.com';
        amaSettingObj.Vendor_Contact_ID__c = tpaContact.id;
        amaSettingObj.Email_Noti_AMA_Submitted_Response_to_AMA__c = getEmailTemplate('AMA Email Notification: To TP-US regarding Termination Status of Cancelation Req').Id;
        amaSettingObj.Offshore_Vendor_Revised_Noti_Template_ID__c = getEmailTemplate('AMA Email Notification: To TP-US regarding Termination Status of Cancelation Req').Id;
        amaSettingObj.Offshore_Link_For_DBL_Template_ID__c = getEmailTemplate('AMA Email Notification: To TP-US regarding Termination Status of Cancelation Req').Id;
        amaSettingObj.Revised_Offshore_Noti_To_TPUS_TemplateID__c = getEmailTemplate('AMA Email Notification: To TP-US regarding Termination Status of Cancelation Req').Id;
        amaSettingList.add(amaSettingObj);

        insert amaSettingList;
        
        TPA_Settings__c TPA_SettingObj1 = new TPA_Settings__c(Name = 'Test1', VendorMessageBoardId__c = 'test id', TPA_RequestSubmitted_Email__c = 'Test Email', Base_Url__c = String.valueOf(URL.getOrgDomainUrl()), Is_TPA_Permanent_Down__c = true, TPA_Client_Community_Url__c = String.valueOf(URL.getOrgDomainUrl()));
        
        insert TPA_SettingObj1 ;
                
    } 
    
    public static EmailTemplate getEmailTemplate(String name)
    {
        EmailTemplate emailTemp = UTL_TPA_SetupTestData.accessEmailTemplate(name);
        return emailTemp;
    }
    
    @isTest static void testcases1(){
        
        test.startTest();
        cntOffshoreTemplateObj = new CNT_TPA_AMAOffshoreTemplate_Revised();
        String amaAgrDetailAsString = cntOffshoreTemplateObj.amaAgreementDetailAsString;
        cntOffshoreTemplateObj.getPrintView();
        cntOffshoreTemplateObj.getWordStyle();
        cntOffshoreTemplateObj.getTechnologyToAccessAMAPPDList();
        List<AMA_Agreement_Detail__c> amaObjList = [select id, Name, Status_of_Offshore_Process__c, Technologies_to_access_AMA_PPD_by_vendor__c from AMA_Agreement_Detail__c limit 1];
        CNT_TPA_AMAOffshoreTemplate_Revised.amaAgreementID = amaObjList.get(0).id;
        String amaRecord = JSON.serialize(amaObjList.get(0));
        CNT_TPA_AMAOffshoreTemplate_Revised.saveAMAResponseForOffshore('request approved',amaRecord);
        AMA_Agreement_Detail__c amaObj = amaObjList.get(0);
        amaObj.Status_of_Offshore_Process__c = 'Awaiting AMA Response: Offshore Consent form requires AMA review/approval';
        update amaObj;
        CNT_TPA_AMAOffshoreTemplate_Revised.saveAMAResponseForOffshore('request approved',amaRecord);
        CNT_TPA_AMAOffshoreTemplate_Revised.saveAMAResponseForOffshore('not approved',amaRecord);
        String ProfileName = CNT_TPA_AMAOffshoreTemplate_Revised.currentUserProfileName;
        String CommunityURL = CNT_TPA_AMAOffshoreTemplate_Revised.tpaCommunityUrl;
        test.stopTest();
    }
    
    
    @isTest static void testcases2(){
        
        test.startTest();
        cntOffshoreTemplateObj = new CNT_TPA_AMAOffshoreTemplate_Revised();
        String amaAgrDetailAsString = cntOffshoreTemplateObj.amaAgreementDetailAsString;
        cntOffshoreTemplateObj.getPrintView();
        cntOffshoreTemplateObj.getWordStyle();
        cntOffshoreTemplateObj.getTechnologyToAccessAMAPPDList();
        List<AMA_Agreement_Detail__c> amaObjList = [select id, Name, Status_of_Offshore_Process__c, Technologies_to_access_AMA_PPD_by_vendor__c from AMA_Agreement_Detail__c limit 1];
        CNT_TPA_AMAOffshoreTemplate_Revised.amaAgreementID = amaObjList.get(0).id;
        AMA_Agreement_Detail__c amaObj = amaObjList.get(0);
        amaObj.Status_of_Offshore_Process__c = 'Awaiting AMA Response: Offshore Consent form requires AMA review/approval';
        amaObj.Technologies_to_access_AMA_PPD_by_vendor__c = 'Other';
        update amaObj;
        String amaRecord = JSON.serialize(amaObj);
        CNT_TPA_AMAOffshoreTemplate_Revised.saveAMAResponseForOffshore('Additional questions for Vendor',amaRecord);
        test.stopTest();
    }

}