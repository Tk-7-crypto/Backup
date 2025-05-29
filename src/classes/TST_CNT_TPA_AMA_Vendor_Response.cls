/*
 @author: Supriya Johari
 Related To: ER-3081
*/
@isTest(seeAllData = false)
private class TST_CNT_TPA_AMA_Vendor_Response {

    private static TPA_Request__c testTpaRequest;
    private static AMA_Agreement_Detail__c amaObj;
    private static CNT_TPA_AMA_Vendor_Response responseTempController ;
    private static String amaAgreementDetailAsString ;
    private static String amaAgreementID;
    private static String AgrName;

    /**
    * Setup test data required to run tests in a data independent fashion
    */

    static void setupTestDataForVendorResponse() {
     
        Address__c testNewClientAccount = UTL_TPA_SetupTestData.getAddress();
        testNewClientAccount.Name = 'test New Client';
        testNewClientAccount.is_TPA_Account__c = true;
        testNewClientAccount.Street__c = 'test';
        testNewClientAccount.City__c = 'test';
        testNewClientAccount.Country__c = 'test';
        testNewClientAccount.PostalCode__c = 'test';
        testNewClientAccount.Vendor_Registration_Number__c = null;
        insert testNewClientAccount;
        TPA_Settings__c tpaSetting = new TPA_Settings__c(Is_Potential_Vendor_Submitted__c = true,TP_US_Mail_Id__c = 'supriya.johari@metacube.com',
                                                         Base_Url__c = String.valueOf(URL.getOrgDomainUrl()),
                                                         TPA_BCC_Emails__c = 'a@a.com',
                                                         TPA_RequestSubmitted_Email__c = 'neha.bansal@metacube.com',
                                                         DBL_Contracts_Contact_Id__c = createContact('Tp-US',testNewClientAccount.Account__c).id,
                                                         Manual_Review_For_Special_Client_And_Use__c='001c0000016NHg9~Prescriber List Match only for overlap analysis, no prescriber communication');
        insert tpaSetting;
		UTL_TPA.isTPAPermanentDown = true;
        list<TPA_AMA_Settings__c> amaSettingList = new list<TPA_AMA_Settings__c>();//bulk List of custom setting object for bulk insert

        TPA_AMA_Settings__c amaSettingObj = new TPA_AMA_Settings__c(); //Custom Setting for Contact Fields
        amaSettingObj.Name='CreatedDate';//Static record 1 of custom setting
        amaSettingObj.Cancelation_Link_For_Vendor_Template_ID__c  = getEmailTemplate('AMA Email Notification: Vendor Cancelation Template to be completed by Vendor').id;
        amaSettingObj.CC_Address_For_Vendor_Cancelation_Mail__c = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_For_DBL_Cancelation_Mail__c = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_For_TP_US_Cancelation_Mail__c  = 'supriya.johari@metacube.com';
        amaSettingObj.Cancelation_Link_For_DBL_Template_ID__c  = getEmailTemplate('AMA Email Notification: Vendor Cancelation Template Completed by Vendor').Id;
        amaSettingObj.Cancelation_Noti_To_TPUS_Template_ID__c   = getEmailTemplate('AMA Email Notification: To TP-US regarding Termination Status of Cancelation Req').Id;
        amaSettingObj.Vendor_Contact_ID__c = createContact('vendor', testNewClientAccount.Account__c).id;
        amaSettingObj.To_Address_For_TP_US_Cancelation_Mail__c = createContact('Tp-US', testNewClientAccount.Account__c).id;
        amaSettingObj.CC_Address_For_All_The_AMA_Mails__c = 'supriya.johari@metacube.com';
        amaSettingList.add(amaSettingObj);
        insert amaSettingList;

        // Create test Tpa Request
        testTpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        testTpaRequest.OwnerId = UserInfo.getUserId();
        testTpaRequest.AMA_USPrescriberData__c = 'Yes';
        testTpaRequest.Service_Provider_Address__c = testNewClientAccount.Id;
        testTpaRequest.Client_Address__c = testNewClientAccount.Id;
        testTpaRequest.Vendor_Company_Name__c = 'Test company';
        testTpaRequest.data_access_start_date__c = Date.newInstance(2016 , 10 ,20);
        testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
        testTpaRequest.IMS_Data_Country_Location__c = 'United States';
        testTpaRequest.Employee_Accessing_Data_Location__c = 'United States';
        testTpaRequest.Request_Status__c = 'Pending Vendor AMA Fee Acknowledgement';
        testTpaRequest.TPA_Request_Temporary_Status__c = 'In Auto Approval Process';
        testTpaRequest.Agreement_Name__c = 'Test CPC agreement';
        testTpaRequest.Vendor_Contact_Name_f__c = 'JEREMY';
        testTpaRequest.Vendor_Contact_Last_Name__c = 'MAYORS';
        testTpaRequest.TP_Processor_Email__c = 'supriya.johari@metacube.com';
        testTpaRequest.Vendor_Contact_e_mail__c = 'supriya.johari@metacube.com';
        testTpaRequest.Vendor_Contact_Email_Client__c = 'supriya.johari@metacube.com';
        testTpaRequest.Request_Status__c = 'Pending Vendor AMA Fee Acknowledgement';
        testTpaRequest.Authorized_Signer_Email__c = 'testAuthSig@test.com';
        testTpaRequest.Pending_Acknowledgements__c = 'AMA Fee Acknowledgement';
        insert testTpaRequest;

        amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaObj.Agreement_Start_Date__c = Date.newInstance(2016 , 10 ,20);
        amaObj.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaObj.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaObj.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaObj.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaObj.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        amaObj.Vendor_AMA_Fee_Response__c = '';
        insert amaObj;
        amaAgreementID = amaObj.Id;
        AgrName = testTpaRequest.Name;
        responseTempController = new CNT_TPA_AMA_Vendor_Response();
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

    /*
     * Name: testcase1
     *
     */
    public static testMethod void testcases1() {
        test.startTest();
        setupTestDataForVendorResponse();
		String pname = CNT_TPA_AMA_Vendor_Response.currentUserProfileName;
        String tpac = CNT_TPA_AMA_Vendor_Response.tpaCommunityUrl;
        Set<String> countryCodes = CNT_TPA_AMA_Vendor_Response.countryCodes;
        CNT_TPA_AMA_Vendor_Response.amaAgreementID = amaObj.id;
        CNT_TPA_AMA_Vendor_Response.amaAgreementDetailObj.Vendor_AMA_Fee_Response__c  = 'declined';
        amaAgreementDetailAsString = responseTempController.amaAgreementDetailAsString;
        CNT_TPA_AMA_Vendor_Response.saveVendorFeeResponse(amaAgreementDetailAsString);
        CNT_TPA_AMA_Vendor_Response.tpUsReqResendAMAFeeNoti(amaObj.id);
        testTpaRequest.Authorized_Signer_Email__c = null;
        update testTpaRequest;
		test.stopTest();
        CNT_TPA_AMA_Vendor_Response.saveVendorFeeResponse(responseTempController.amaAgreementDetailAsString);
        CNT_TPA_AMA_Vendor_Response.amaAgreementDetailObj.Vendor_AMA_Fee_Response__c = 'acknowledged';
        CNT_TPA_AMA_Vendor_Response.tpUsReqResendAMAFeeNoti(amaObj.id);
        testTpaRequest.TPA_Request_Temporary_Status__c = 'In Batch Process';
        CNT_TPA_AMA_Vendor_Response.saveVendorFeeResponse(responseTempController.amaAgreementDetailAsString);
        update testTpaRequest;
        CNT_TPA_AMA_Vendor_Response.saveVendorFeeResponse(responseTempController.amaAgreementDetailAsString);

        
    }
}
