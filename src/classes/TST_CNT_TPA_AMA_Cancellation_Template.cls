@isTest(seeAllData = false)
public class TST_CNT_TPA_AMA_Cancellation_Template {
       
    private static TPA_Request__c testTpaRequest;   
    private static AMA_Agreement_Detail__c amaObj;
    private static CNT_TPA_AMA_Cancellation_Template amaCancellationTemplateController;
    private static String amaAgreementObjectAsString;
    private static String amaAgreementObjID;
    
    static void setupTestDataForCancellation() {

        //UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createTpaTestEditorData('TPA Email Footer', 'Test', 'emailFooter', 'emailFooter');
        Address__c testNewClientAccount = UTL_TPA_SetupTestData.getAddress();
        testNewClientAccount.Name = 'veeva New Client';
        testNewClientAccount.is_TPA_Account__c = true;
        testNewClientAccount.Street__c = 'test';
        testNewClientAccount.City__c = 'test';
        testNewClientAccount.Country__c = 'test';
        testNewClientAccount.PostalCode__c = 'test';
        insert testNewClientAccount;
        
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'a.b@metacube.com'); 
        insert tpProcessor;
        
        TPA_Assigned_TP_Processor__c tpaAssignedTPProcessor = new TPA_Assigned_TP_Processor__c(Email__c = 'a.c@metacube.com', Initials__c = 'AB', Is_Active__c = true, TP_Processor__c = tpProcessor.id);
        insert tpaAssignedTPProcessor;
        
        TPA_Settings__c tpaSetting = new TPA_Settings__c(Is_Potential_Vendor_Submitted__c = true,
                                                         SetupOwnerId = UserInfo.getOrganizationId(),
                                                         Base_Url__c = String.valueOf(URL.getOrgDomainUrl()), 
                                                         TPA_Send_Emails__c = true,
                                                         TPA_BCC_Emails__c = 'devbcctest@test.com',
                                                         TPA_RequestSubmitted_Email__c = 'neha.bansal@metacube.com',
                                                         TPA_Client_Community_Url__c = String.valueOf(URL.getOrgDomainUrl()),
                                                         DBL_Contracts_Contact_Id__c = createContact('Tp-US',testNewClientAccount.Account__c).id,
                                                         Manual_Review_For_Special_Client_And_Use__c='001c0000016NHg9~Prescriber List Match only for overlap analysis, no prescriber communication');
        insert tpaSetting;
        
        list<TPA_AMA_Settings__c> amaSettingList = new list<TPA_AMA_Settings__c>();//bulk List of custom setting object for bulk insert

        TPA_AMA_Settings__c amaSettingObj = new TPA_AMA_Settings__c(); //Custom Setting for Contact Fields
        amaSettingObj.Name='CreatedDate';//Static record 1 of custom setting
        amaSettingObj.Cancelation_Link_For_Vendor_Template_ID__c  = getEmailTemplate('AMA Email Notification: Vendor Cancelation Template to be completed by Vendor').id;
        amaSettingObj.AMA_Cancellation_Summary_Receipt_TempId__c = UTL_TPA_SetupTestData.getTestEmailTemplateId();
        amaSettingObj.CC_Address_For_Vendor_Cancelation_Mail__c = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_For_DBL_Cancelation_Mail__c = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_For_TP_US_Cancelation_Mail__c  = 'supriya.johari@metacube.com';
        amaSettingObj.Cancelation_Link_For_DBL_Template_ID__c  = getEmailTemplate('AMA Email Notification: Vendor Cancelation Template Completed by Vendor').Id;
        amaSettingObj.Cancelation_Noti_To_TPUS_Template_ID__c   = getEmailTemplate('AMA Email Notification: To TP-US regarding Termination Status of Cancelation Req').Id;
        amaSettingObj.Vendor_Contact_ID__c = createContact('vendor', testNewClientAccount.Account__c).id;
        amaSettingObj.To_Address_For_TP_US_Cancelation_Mail__c = createContact('Tp-US', testNewClientAccount.Account__c).id;
        amaSettingObj.Dev_Mail_ID__c = 'testdev@test.com';
        
        amaSettingList.add(amaSettingObj);
        insert amaSettingList;
        
        // Create test Tpa Request
        testTpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        testTpaRequest.OwnerId = UserInfo.getUserId();
        testTpaRequest.TPA_Assigned_TP_Processor__c = tpaAssignedTPProcessor.Id;
        testTpaRequest.AMA_USPrescriberData__c = 'Yes';
        testTpaRequest.Service_Provider_Address__c = testNewClientAccount.Id;
        testTpaRequest.Client_Address__c = testNewClientAccount.Id;
        testTpaRequest.Vendor_Company_Name__c = 'Test company';
        testTpaRequest.data_access_start_date__c = Date.newInstance(2016 , 10 ,20);
        testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
        testTpaRequest.IMS_Data_Country_Location__c = 'United States';
        testTpaRequest.Employee_Accessing_Data_Location__c = 'United States';
        testTpaRequest.data_access_start_date__c = Date.newInstance(2016 , 10 ,20);
        testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
        testTpaRequest.Service_Provider_Address__c = testNewClientAccount.Id;
        testTpaRequest.Client_Address__c = testNewClientAccount.Id;
        testTpaRequest.Vendor_Company_Name__c = 'AMA Vendor SB II';
        testTpaRequest.Vendor_Contact_Name_f__c = 'JEREMY';
        testTpaRequest.Vendor_Contact_Last_Name__c = 'MAYORS';
        testTpaRequest.TP_Processor_Email__c = 'supriya.johari@metacube.com';
        testTpaRequest.Vendor_Contact_e_mail__c = 'supriya.johari@metacube.com';
        testTpaRequest.Vendor_Contact_Email_Client__c = 'supriya.johari@metacube.com';
        insert testTpaRequest;
                
        amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaObj.Agreement_Start_Date__c = Date.newInstance(2016 , 10 ,20);
        amaObj.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaObj.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaObj.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaObj.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaObj.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        amaObj.Term_requested_to_cancel__c = 'cancel this request';
        insert amaObj; 
        amaAgreementObjID = amaObj.Id;
        UTL_TPA.isTPAPermanentDown = true;
        UTL_TPA.dblContractContactEmail = 'test@t.com';
        amaCancellationTemplateController = new CNT_TPA_AMA_Cancellation_Template();
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
    
    /*
     * Name: testcase1
     * 
     */
    public static testMethod void testcases1() {  
        
        test.startTest();
        setupTestDataForCancellation();
        UTL_TPA.dblContractContactEmail = 'test@t.com';
        amaCancellationTemplateController.getCancelationReasonList();
        CNT_TPA_AMA_Cancellation_Template.tpUsRequestforCancelation(amaAgreementObjID);
        
        amaObj.Vendor_Reasons_for_Termination__c = 'No AMA data was shared';
        amaObj.Vendor_Name_who_Acknowledged_Cancelation__c = 'supriya';
        amaObj.Status_of_Cancelation_Request__c = 'Awaiting AMA Response to Vendor Cancelation Request';
        amaAgreementObjectAsString = JSON.serialize(amaObj);
        String pname = CNT_TPA_AMA_Cancellation_Template.currentUserProfileName;
        String tpac = CNT_TPA_AMA_Cancellation_Template.tpaCommunityUrl;
        CNT_TPA_AMA_Cancellation_Template.saveVendorCancelationReason(amaAgreementObjectAsString);
        CNT_TPA_AMA_Cancellation_Template.tpUsReqResendTOAMA(amaAgreementObjID );
        amaAgreementObjectAsString = JSON.serialize(amaObj);
        CNT_TPA_AMA_Cancellation_Template.saveAMAResponse('Approved cancelation and full/partial credit',amaAgreementObjectAsString);
        test.stopTest();
        
    }
    
    public static testMethod void testcases2() {  
        
        test.startTest();
        setupTestDataForCancellation();
        UTL_TPA.dblContractContactEmail = 'test@t.com';
        amaCancellationTemplateController.getCancelationReasonList();
        CNT_TPA_AMA_Cancellation_Template.tpUsRequestforCancelation(amaAgreementObjID);
        
        amaObj.Vendor_Reasons_for_Termination__c = 'No AMA data was shared';
        amaObj.Vendor_Name_who_Acknowledged_Cancelation__c = 'supriya';
        amaObj.Status_of_Cancelation_Request__c = 'Awaiting AMA Response to Vendor Cancelation Request';
        amaAgreementObjectAsString = JSON.serialize(amaObj);
        CNT_TPA_AMA_Cancellation_Template.saveVendorCancelationReason(amaAgreementObjectAsString);
        CNT_TPA_AMA_Cancellation_Template.tpUsReqResendTOAMA(amaAgreementObjID);
        amaAgreementObjectAsString = JSON.serialize(amaObj);
        CNT_TPA_AMA_Cancellation_Template.saveAMAResponse('Additional information is required',amaAgreementObjectAsString);
        test.stopTest();
        
    }
    
    public static testMethod void testcases3() {  
        
        test.startTest();
        setupTestDataForCancellation();
        UTL_TPA.dblContractContactEmail = 'test@t.com';
        amaCancellationTemplateController.getCancelationReasonList();
        CNT_TPA_AMA_Cancellation_Template.tpUsRequestforCancelation(amaAgreementObjID);
        
        amaObj.Vendor_Reasons_for_Termination__c = 'No AMA data was shared';
        amaObj.Vendor_Name_who_Acknowledged_Cancelation__c = 'supriya';
        amaObj.Status_of_Cancelation_Request__c = 'Awaiting AMA Response to Vendor Cancelation Request';
        amaAgreementObjectAsString = JSON.serialize(amaObj);
        CNT_TPA_AMA_Cancellation_Template.saveVendorCancelationReason(amaAgreementObjectAsString);
        CNT_TPA_AMA_Cancellation_Template.tpUsReqResendTOAMA(amaAgreementObjID );
        amaAgreementObjectAsString = JSON.serialize(amaObj);
        CNT_TPA_AMA_Cancellation_Template.saveAMAResponse('Not approved, reasons why',amaAgreementObjectAsString);
        test.stopTest();
        
    }
}