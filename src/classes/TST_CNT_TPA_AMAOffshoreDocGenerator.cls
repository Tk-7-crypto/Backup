@isTest(seeAllData = false)
public class TST_CNT_TPA_AMAOffshoreDocGenerator {
    // private static TPA_Request__c testTpaRequest;   
    // private static TPA_Request__c testCpcAgreement;
    // private static AMA_Agreement_Detail__c amaObj;
    // private static CNT_TPA_AMAOffshoreDocGenerator amaOffshoreTemplateController;
    // private static String amaAgreementObjectAsString;
    // private static String amaAgreementObjID;
    // private static String AgrName;
    
    /**
    * Setup test data required to run tests in a data independent fashion
    */
    
    // static void setupTestDataForOffshore() {
        
    //     Address__c testNewClientAccount = UTL_TPA_SetupTestData.getAccount();
    //     testNewClientAccount.Name = 'test New Client';
    //     testNewClientAccount.is_TPA_Account__c = true;
    //     testNewClientAccount.Street__c = 'test';
    //     testNewClientAccount.City__c = 'test';
    //     testNewClientAccount.Country__c = 'test';
    //     testNewClientAccount.PostalCode__c = 'test';
    //     insert testNewClientAccount;
    //     TPA_Settings__c tpaSetting = new TPA_Settings__c(Is_Potential_Vendor_Submitted__c = true,
    //                                                      Base_Url__c = String.valueOf(URL.getOrgDomainUrl()), 
    //                                                      TPA_RequestSubmitted_Email__c = 'neha.bansal@metacube.com',
    //                                                      DBL_Contracts_Contact_Id__c = createContact('Tp-US',testNewClientAccount.Account__c).id,
    //                                                      Manual_Review_For_Special_Client_And_Use__c = '001c0000016NHg9~Prescriber List Match only for overlap analysis, no prescriber communication');
    //     insert tpaSetting;
        
    //     list<TPA_AMA_Settings__c> amaSettingList = new list<TPA_AMA_Settings__c>();//bulk List of custom setting object for bulk insert

    //     TPA_AMA_Settings__c amaSettingObj = new TPA_AMA_Settings__c(); //Custom Setting for Contact Fields
    //     amaSettingObj.Name='CreatedDate';//Static record 1 of custom setting
    //     amaSettingObj.Cancelation_Link_For_Vendor_Template_ID__c  = getEmailTemplate('AMA Email Notification: Vendor Cancelation Template to be completed by Vendor').id;
    //     amaSettingObj.CC_Address_For_Vendor_Cancelation_Mail__c = 'supriya.johari@metacube.com';
    //     amaSettingObj.CC_Address_For_DBL_Cancelation_Mail__c = 'supriya.johari@metacube.com';
    //     amaSettingObj.CC_Address_For_TP_US_Cancelation_Mail__c  = 'supriya.johari@metacube.com';
    //     amaSettingObj.Cancelation_Link_For_DBL_Template_ID__c  = getEmailTemplate('AMA Email Notification: Vendor Cancelation Template Completed by Vendor').Id;
    //     amaSettingObj.Cancelation_Noti_To_TPUS_Template_ID__c   = getEmailTemplate('AMA Email Notification: To TP-US regarding Termination Status of Cancelation Req').Id;
    //     amaSettingObj.Vendor_Contact_ID__c = createContact('vendor', testNewClientAccount.Account__c).id;
    //     amaSettingObj.To_Address_For_TP_US_Cancelation_Mail__c = createContact('Tp-US', testNewClientAccount.Account__c).id;
    //     amaSettingObj.CC_Address_For_TPUS_Offshore_Mail__c = 'testOffshoreMail@test.com';
    //     amaSettingObj.CC_Address_For_Vendor_Offshore_Mail__c = 'testVendOffShoreMail@test.com';
    //     amaSettingObj.Offshore_Noti_To_TPUS_Template_ID__c = UTL_TPA_SetupTestData.getTestEmailTemplateId();
    //     amaSettingObj.Offshore_Vendor_Notification_Template_ID__c = UTL_TPA_SetupTestData.getTestEmailTemplateId();
        
    //     amaSettingList.add(amaSettingObj);

    //     insert amaSettingList;
        
    //     // Create test Tpa Request
    //     testTpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
    //     testTpaRequest.OwnerId = UserInfo.getUserId();
    //     testTpaRequest.AMA_USPrescriberData__c = 'Yes';
    //     testTpaRequest.Service_Provider_Address__c = testNewClientAccount.Id;
    //     testTpaRequest.Client_Address__c = testNewClientAccount.Id;
    //     testTpaRequest.Vendor_Company_Name__c = 'Test company';
    //     testTpaRequest.data_access_start_date__c = Date.newInstance(2016, 10, 20);
    //     testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
    //     testTpaRequest.IMS_Data_Country_Location__c = 'United States';
    //     testTpaRequest.Employee_Accessing_Data_Location__c = 'United States';
    //     testTpaRequest.data_access_start_date__c = Date.newInstance(2016, 10, 20);
    //     testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
    //     testTpaRequest.Vendor_Company_Name__c = 'AMA Vendor SB II';
    //     testTpaRequest.Vendor_Contact_Name_f__c = 'JEREMY';
    //     testTpaRequest.Vendor_Contact_Last_Name__c = 'MAYORS';
    //     testTpaRequest.TP_Processor_Email__c = 'supriya.johari@metacube.com';
    //     testTpaRequest.Vendor_Contact_e_mail__c = 'supriya.johari@metacube.com';
    //     testTpaRequest.Vendor_Contact_Email_Client__c = 'supriya.johari@metacube.com';
    //     insert testTpaRequest;
        
    //     amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
    //     amaObj.Agreement_Start_Date__c = Date.newInstance(2016, 10, 20);
    //     amaObj.Agreement_End_Date__c = Date.newInstance(2017, 12, 31);
    //     amaObj.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
    //     amaObj.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
    //     amaObj.AMA_TypeOfPrescriberLevelData__c='Birth Year;Gender Code';
    //     amaObj.AMA_Services_Provided__c='Telemarketing;Labeling';
    //     insert amaObj; 
    //     amaAgreementObjID = amaObj.Id;
    //     AgrName = testTpaRequest.Agreement_Name__c;
    //     amaOffshoreTemplateController = new CNT_TPA_AMAOffshoreDocGenerator();
    // }
    
    // public static Contact createContact(String name, id AccountID){
    //     Contact c1 = UTL_TPA_SetupTestData.getContact();
    //     c1.firstName= name;
    //     c1.lastName = name + '12';       
    //     c1.Accountid= AccountID;
    //     insert c1;
        
    //     return c1;
    // }
    
    // public static EmailTemplate getEmailTemplate(String name)
    // {
    //     EmailTemplate emailTemp = UTL_TPA_SetupTestData.accessEmailTemplate(name);
    //     return emailTemp;
    // }
    
    /*
     * Name: testcase1
     * 
     */
    public static testMethod void testcases1(){ 
        test.startTest();
        // setupTestDataForOffshore();
        CNT_TPA_AMAOffshoreDocGenerator obj = new CNT_TPA_AMAOffshoreDocGenerator();
        // CNT_TPA_AMAOffshoreDocGenerator.amaAgreementID = amaObj.id;
        // amaAgreementObjectAsString = amaOffshoreTemplateController.amaAgreementDetailAsString;
        // CNT_TPA_AMAOffshoreDocGenerator.saveOffshoreQuestionnaire(amaAgreementObjectAsString);
        // CNT_TPA_AMAOffshoreDocGenerator.tpUsReqSendQuesTOVendor(amaAgreementObjID);
        // amaOffshoreTemplateController.getPrintView();
        // amaOffshoreTemplateController.getWordStyle();
        // CNT_TPA_AMAOffshoreDocGenerator.generateDocument(amaAgreementObjID, AgrName);
        // amaObj.Status_of_Offshore_Questionnaire__c = 'Awaiting Vendor Response: AMA Offshore Questionnaire has been sent to Vendor';
        // update amaObj;
        
        // Blob b = Blob.valueOf('Test Data');            
        // Attachment attachment = new Attachment();  
        // attachment.ParentId = amaObj.Id;  
        // attachment.Name = 'Temp Connection Diagram';  
        // attachment.Body = b;            
        // insert attachment;  
        
        // amaAgreementObjectAsString = amaOffshoreTemplateController.amaAgreementDetailAsString;
        // CNT_TPA_AMAOffshoreDocGenerator.saveOffshoreQuestionnaire(amaAgreementObjectAsString);
        
        test.stopTest();
    }  
}