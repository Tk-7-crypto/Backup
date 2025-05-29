/*
 @author : Supriya johari
 Related To: ER-2906
*/
@isTest(seeAllData = false)
private class TST_CNT_TPA_AMA_OffshoreUploadAttachment {
    // private static TPA_Request__c testTpaRequest;
    // private static AMA_Agreement_Detail__c amaObj;
        
    // Test data setup        
    // public static void setupTestDataForOffshore() {
        
    //     Address__c testNewClientAccount = UTL_TPA_SetupTestData.getAccount();
    //     testNewClientAccount.Name = 'test New Client';
    //     testNewClientAccount.is_TPA_Account__c = true;
    //     testNewClientAccount.Street__c = 'test';
    //     testNewClientAccount.City__c = 'test';
    //     testNewClientAccount.Country__c = 'test';
    //     testNewClientAccount.PostalCode__c = 'test';
    //     insert testNewClientAccount;
    //     // Create test Tpa Request
    //     testTpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
    //     testTpaRequest.OwnerId = UserInfo.getUserId();
    //     testTpaRequest.AMA_USPrescriberData__c = 'Yes';
    //     testTpaRequest.Service_Provider_Address__c = testNewClientAccount.Id;
    //     testTpaRequest.Client_Address__c = testNewClientAccount.Id;
    //     testTpaRequest.Vendor_Company_Name__c = 'Test company';
    //     testTpaRequest.data_access_start_date__c = Date.newInstance(2016, 10 ,20);
    //     testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
    //     testTpaRequest.IMS_Data_Country_Location__c = 'United States';
    //     testTpaRequest.Employee_Accessing_Data_Location__c = 'United States';
    //     testTpaRequest.Vendor_Company_Name__c = 'AMA Vendor SB II';
    //     testTpaRequest.Vendor_Contact_Name_f__c = 'JEREMY';
    //     testTpaRequest.Vendor_Contact_Last_Name__c = 'MAYORS';
    //     testTpaRequest.TP_Processor_Email__c = 'supriya.johari@metacube.com';
    //     testTpaRequest.Vendor_Contact_e_mail__c = 'supriya.johari@metacube.com';
    //     testTpaRequest.Vendor_Contact_Email_Client__c = 'supriya.johari@metacube.com';
    //     insert testTpaRequest;       
        
    //     amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
    //     amaObj.Agreement_Start_Date__c = Date.newInstance(2016, 10 ,20);
    //     amaObj.Agreement_End_Date__c = Date.newInstance(2017, 12 ,31);
    //     amaObj.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
    //     amaObj.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
    //     amaObj.AMA_TypeOfPrescriberLevelData__c='Birth Year;Gender Code';
    //     amaObj.AMA_Services_Provided__c='Telemarketing;Labeling';
    //     insert amaObj;
    // }    
    
    @isTest static void TestOffshoreUploadProcess() {        
        
        // set up test data for Upload attachment
        // setupTestDataForOffshore();
        Test.startTest();
        CNT_TPA_AMA_OffshoreUploadAttachment amaOffshoreUploadController = new CNT_TPA_AMA_OffshoreUploadAttachment();
        // amaOffshoreUploadController.amaAgreementID = amaObj.Id;
        // amaOffshoreUploadController.fileName = 'TestingFile.png'; 
        // amaOffshoreUploadController.AttachDocument();
        Test.stopTest();

    }        
}