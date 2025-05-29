@isTest(seeAllData = false)
public class TST_CNT_TPA_AMA_RenewalDocGenerator {

    private static TPA_Request__c testTpaRequest;
    private static AMA_Agreement_Detail__c amaObj;
    //private static CNT_TPA_AMAOffshoreDocGenerator amaOffshoreTemplateController;
    private static String amaAgreementObjectAsString;
    private static String amaAgreementObjID;
    private static String AgrName;
    
    /**
    * Setup test data required to run tests in a data independent fashion
    */    
    static void setupTestDataForOffshore() {
     // TPAQueryHelper.getLoggedInUser();  
        //UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createTpaTestEditorData('TPA Email Footer', 'Test', 'emailFooter', 'emailFooter');
     
        Account acc = new Account(Name = 'Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        
        Address__c testNewClientAccount = UTL_TPA_SetupTestData.getAddress();
        testNewClientAccount.Name = 'test New Client';
        testNewClientAccount.is_TPA_Account__c = true;
        testNewClientAccount.Account__c = acc.Id;
        testNewClientAccount.Street__c = 'test';
        testNewClientAccount.City__c = 'test';
        testNewClientAccount.Country__c = 'test';
        testNewClientAccount.PostalCode__c = 'test';
        testNewClientAccount.TPA_Local_Address_Required__c = FALSE;
        insert testNewClientAccount;

        Contact tpaContact = UTL_TPA_SetupTestData.getContact();
        tpaContact.AccountId = testNewClientAccount.Account__c;
        insert tpaContact;
        
        TPA_Settings__c tpaSetting = new TPA_Settings__c(Is_Potential_Vendor_Submitted__c = true,
                                                         Base_Url__c = String.valueOf(URL.getOrgDomainUrl()), 
                                                         TPA_RequestSubmitted_Email__c = 'neha.bansal@metacube.com',
                                                         DBL_Contracts_Contact_Id__c = tpaContact.id,
                                                         Manual_Review_For_Special_Client_And_Use__c='001c0000016NHg9~Prescriber List Match only for overlap analysis, no prescriber communication');
        insert tpaSetting;        
        
        list<TPA_AMA_Settings__c> amaSettingList = new list<TPA_AMA_Settings__c>();//bulk List of custom setting object for bulk insert

        TPA_AMA_Settings__c amaSettingObj = new TPA_AMA_Settings__c(); //Custom Setting for Contact Fields
        amaSettingObj.Name='CreatedDate';//Static record 1 of custom setting
        amaSettingObj.Cancelation_Link_For_Vendor_Template_ID__c  = getEmailTemplate('AMA Email Notification: Vendor Cancelation Template to be completed by Vendor').id;
        amaSettingObj.CC_Address_For_Vendor_Cancelation_Mail__c = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_For_DBL_Cancelation_Mail__c = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_For_TP_US_Cancelation_Mail__c  = 'supriya.johari@metacube.com';
        amaSettingObj.Cancelation_Link_For_DBL_Template_ID__c  = getEmailTemplate('AMA Email Notification: Vendor Cancelation Template Completed by Vendor').Id;
        amaSettingObj.Cancelation_Noti_To_TPUS_Template_ID__c   = getEmailTemplate('AMA Email Notification: To TP-US regarding Termination Status of Cancelation Req').Id;
        amaSettingObj.Vendor_Contact_ID__c = tpaContact.id;
        amaSettingObj.To_Address_For_TP_US_Cancelation_Mail__c = tpaContact.id;
        amaSettingObj.AMA_Renewal_Cancellation_Disable_Link_On__c = '12-12';
        amaSettingObj.CC_address_Vendor_Renewal_Notification__c = 'testVend@test.com';
        amaSettingObj.CC_Address_For_DBL_Renewal_Notification__c = 'testVend@test.com';
        amaSettingObj.CC_Add_For_Client_Renewal_Notification__c = 'testVend@test.com';
        amaSettingObj.Vendor_Renewal_Noti_for_old_Template_Id__c = UTL_TPA_SetupTestData.getTestEmailTemplateId();
        amaSettingObj.DBL_Renewal_Notification_Template_Id__c = UTL_TPA_SetupTestData.getTestEmailTemplateId();        
        
        amaSettingList.add(amaSettingObj);
        insert amaSettingList;
        
        // Create test Tpa Request
        testTpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        testTpaRequest.OwnerId = UserInfo.getUserId();
        testTpaRequest.AMA_USPrescriberData__c = 'Yes';
        testTpaRequest.Service_Provider_Address__c = testNewClientAccount.Id;
        testTpaRequest.Client_Address__c = testNewClientAccount.Id;
        testTpaRequest.Vendor_Company_Name__c = 'Test company';
        testTpaRequest.data_access_start_date__c = Date.newInstance(2018 , 10 ,20);
        testTpaRequest.data_access_end_date__c = Date.newInstance(2019, 8, 20);
        testTpaRequest.IMS_Data_Country_Location__c = 'United States';
        testTpaRequest.Employee_Accessing_Data_Location__c = 'United States';
        testTpaRequest.TP_Processor_Email__c = 'tpProcessor@test.com';
        testTpaRequest.Vendor_e_mail__c = 'vendorTest@test.com';
        testTpaRequest.Service_Provider_Address__c = testNewClientAccount.Id;
        testTpaRequest.Client_Address__c = testNewClientAccount.Id;
        testTpaRequest.ClientContact__c = tpaContact.id;
        testTpaRequest.data_access_start_date__c = Date.newInstance(2018, 10 ,20);
        testTpaRequest.data_access_end_date__c = Date.newInstance(2019, 8, 20);
        testTpaRequest.Vendor_Company_Name__c = 'AMA Vendor SB II';
        testTpaRequest.Vendor_Contact_Name_f__c = 'JEREMY';
        testTpaRequest.Vendor_Contact_Last_Name__c = 'MAYORS';
        testTpaRequest.TP_Processor_Email__c = 'a.b@metacube.com';
        testTpaRequest.Vendor_Contact_e_mail__c = 'a.b@metacube.com';
        testTpaRequest.Vendor_Contact_Email_Client__c = 'a.b@metacube.com';
        testTpaRequest.Authorized_Signer_Email__c = 'a.b@metacube.com';
        insert testTpaRequest;
        createAttachment(testTpaRequest.Id,'AMA Vendor Renewal Cancelation.pdf');
        
        amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaObj.Agreement_Start_Date__c = Date.newInstance(2018, 10 ,20);
        amaObj.Agreement_End_Date__c = Date.newInstance(2019, 12 ,31);
        amaObj.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaObj.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaObj.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaObj.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        amaObj.Status_of_Renewal_Process__c = 'Awaiting Vendor Response for renewal';
        amaObj.Renewal_Cancellation_Vendor_Link_Date__c = DateTime.now().Date();
        amaObj.Contract_Type__c = 'Existing Agreement';
        amaObj.Invoice_Contact_Email__c = 'a.b@metacube.com';
        amaObj.Ex_Contract_Type__c = 'Test';
        insert amaObj; 
        amaAgreementObjID = amaObj.Id;
        AgrName = testTpaRequest.Agreement_Name__c;
        createAttachment(amaObj.Id,'Test.pdf');
        createAttachment(amaObj.Id,'AMA Vendor Renewal CancelationTest.doc');
        //amaOffshoreTemplateController = new CNT_TPA_AMAOffshoreDocGenerator();
    }
    
    public static Contact createContact(String name, id AccountID) {        
        Contact c1 = UTL_TPA_SetupTestData.getContact();
        c1.firstName = name;
        c1.lastName = name + '12';       
        c1.Accountid = AccountID;
        insert c1;
        
        return c1;
    }
    
    public static EmailTemplate getEmailTemplate(String name) {
        EmailTemplate emailTemp = UTL_TPA_SetupTestData.accessEmailTemplate(name);
        return emailTemp;
    }
    
    public static void createAttachment(Id pId,String aName)
    {
        Attachment att = UTL_TPA_SetupTestData.addAttachment(pId, aName);
        insert att;
    }

    public static testMethod void testReportMethods()
    {
        
        
        setupTestDataForOffshore();
        
        CNT_TPA_AMA_RenewalDocGenerator.amaAgreementID = amaObj.id;
        CNT_TPA_AMA_RenewalDocGenerator.requestID = testTpaRequest.id;
        CNT_TPA_AMA_RenewalDocGenerator objCtrl = new CNT_TPA_AMA_RenewalDocGenerator();
        objCtrl.getWordStyle();
        objCtrl.getPrintView();
        String str = objCtrl.amaAgreementDetailAsString;
        
        List<AMA_Agreement_Detail__c> lstAMAAgreement = CNT_TPA_AMA_RenewalDocGenerator.amaAgreementDetailValues;
        List<TPA_Request__C> lstRequests = CNT_TPA_AMA_RenewalDocGenerator.tpaRequestValues;
        String reqId = CNT_TPA_AMA_RenewalDocGenerator.requestID;
        Date cDate = CNT_TPA_AMA_RenewalDocGenerator.currentDate;
        String cDateStr = CNT_TPA_AMA_RenewalDocGenerator.currentDateString;
        Boolean isDisabled = CNT_TPA_AMA_RenewalDocGenerator.isLinkDisabled;
        
        List<TPA_AMA_Settings__c> amaSettings = CNT_TPA_AMA_RenewalDocGenerator.amaSetting;
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('oldReqProcInitiated', 'true');
        objCtrl.sendEmailForOldReqProcInitiate();
        Test.startTest();
        //CNT_TPA_AMA_RenewalDocGenerator.saveAmaAcknowledgment(JSON.serialize(amaObj));
        CNT_TPA_AMA_RenewalDocGenerator.saveVendorResponse(JSON.serialize(amaObj));
        system.debug('reqId:'+reqId);
        CNT_TPA_AMA_RenewalDocGenerator.sendClientNotification(reqId);
        CNT_TPA_AMA_RenewalDocGenerator.sendVendorAcknowlwdgeNotification(amaObj.id);
        CNT_TPA_AMA_RenewalDocGenerator.SendRenewalResponseToDBL(amaObj);
        //CNT_TPA_AMA_RenewalDocGenerator.SendVendorNotificationsToProcessor('NotificationForOldAmaProcessOnVendorSubmit',testTpaRequest);
        CNT_TPA_AMA_RenewalDocGenerator.generateDocument(amaObj.id,'Test','false');
        
        System.currentPageReference().getParameters().put('oldReqProcInitiated', 'false');
        System.currentPageReference().getParameters().put('processType', 'NewRequest');
        isDisabled = CNT_TPA_AMA_RenewalDocGenerator.isLinkDisabled;
        string strValue = objCtrl.amaAgreementDetailAsString;
        System.currentPageReference().getParameters().put('processType', 'OldRequest');
        isDisabled = CNT_TPA_AMA_RenewalDocGenerator.isLinkDisabled;
        amaObj.Status_of_Renewal_Process__c = 'Vendor Responded Cancel';
        update amaObj;
        CNT_TPA_AMA_RenewalDocGenerator.saveVendorResponse(JSON.serialize(amaObj));
        amaObj.Status_of_Renewal_Process__c = 'AMA Acknowledged';
        update amaObj;
        CNT_TPA_AMA_RenewalDocGenerator.saveVendorResponse(JSON.serialize(amaObj));
        String CommunityURL = CNT_TPA_AMA_RenewalDocGenerator.tpaCommunityUrl;
        
        Test.stopTest();
    }    
}