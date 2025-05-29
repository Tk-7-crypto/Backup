@isTest(seeAllData = false)
public class TST_TGRH_TPAMasterExtensionInformation { 
    @TestSetup static void setup() {
        
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createTPASettingsData();
        Date todayDate = Date.today();
        
        Account testAccount1 = new Account();
        testAccount1.Name = 'Test Acc';
        testAccount1.CustomerSegment__c = 'GOVERNMENT';
        testAccount1.Sub_Industry__c = 'STATE';
        insert testAccount1;
        
        Address__c testNewClientAccount = UTL_TPA_SetupTestData.getAddress();
        testNewClientAccount.Name = 'test New Client';
        testNewClientAccount.is_TPA_Account__c = true;
        testNewClientAccount.Account__c = testAccount1.Id;
        testNewClientAccount.Street__c = 'test';
        testNewClientAccount.City__c = 'test';
        testNewClientAccount.Country__c = 'test';
        testNewClientAccount.PostalCode__c = 'test';
        insert testNewClientAccount;
        
        
        Contact testContact = UTL_TPA_SetupTestData.getContact();
        testContact.AccountId = testNewClientAccount.Account__r.Id;
        insert testContact;
        
        List<TPA_Request__c> tpaRequestList = new List<TPA_Request__c>();
        
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testNewClientAccount.Id;
        tpaRequest1.Client_Address__c = testNewClientAccount.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Request_Status__c = 'Pending Vendor Response on Data Destruction from Prior TPAs';
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(-1);
        tpaRequest1.ClientContact__c = testContact.Id;
        tpaRequest1.Is_Renewed__c = false;
        tpaRequest1.Purpose_List__c = 'Test Purpose List';
        tpaRequest1.Data_Asset_List__c = 'AAN';
        tpaRequest1.IMS_Legal_Entity_List__c = 'test';
        tpaRequest1.Secondary_Data_Asset_List__c = 'Test';
        tpaRequest1.Client_Request_Submission__c = todayDate.addDays(2);
        tpaRequest1.TP_Processor_Email__c = 'test@mail.com';
        tpaRequest1.Data_access_end_date__c = (Date.today()).addDays(3);
        tpaRequest1.Vendor_Language__c =  'English';
        //tpaRequestList.add(tpaRequest1);
        
        insert tpaRequest1;
        
        AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(tpaRequest1.id);
        amaAgg.AMA_Manual_Review__c = false;
        amaAgg.Is_AMA_License_Required__c = true;
        amaAgg.Current_Year_Fees__c  = 21000;
        amaAgg.Contract_Type__c = 'Service Bureau II';
        amaAgg.Agreement_Start_Date__c = Date.newInstance(2016 , 10 ,20);
        amaAgg.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaAgg.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaAgg.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaAgg.AMA_TypeOfPrescriberLevelData__c='Birth Year;Gender Code';
        amaAgg.AMA_Services_Provided__c='Telemarketing;Labeling';
        amaAgg.Invoice_Contact_Email__c='testinvoice@gmail.com';
        insert amaAgg;
        
        TPA_Request__c reqObj = [Select id,name from TPA_Request__c];
        TPA_Master_Extension_Information__c vendorOffRetAckObj = new TPA_Master_Extension_Information__c(
            TPA_Accounts_Address__c = testNewClientAccount.Id,
            DDN_Ack_Pending_Requests__c = reqObj.name,
            Return_Destruction_Ack_Outstanding__c = true);
        
        insert vendorOffRetAckObj;
        
        update reqObj;
    }
    
    @isTest static void test_tgrh_TPAMasterExtensionInformation() {
        Test.StartTest();
        //TGRH_TPARequest.isOnHoldFieldUpdate = true;
        List<TPA_Master_Extension_Information__c> tpaMasterExtLst = [SELECT Id FROM TPA_Master_Extension_Information__c LIMIT 1];
        if(tpaMasterExtLst.size() > 0) {
            
            tpaMasterExtLst[0].DDN_Ack_Pending_Requests__c = '';
            tpaMasterExtLst[0].Return_Destruction_Ack_Outstanding__c = false;
            update tpaMasterExtLst[0];
        }
    }
}