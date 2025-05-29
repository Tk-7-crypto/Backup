@isTest(seeAllData = false)
public class TST_TGRH_VendorOfferingReturnAck {
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
        tpaRequest1.Request_Status__c = 'Expired';
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(-1);
        tpaRequest1.ClientContact__c = testContact.Id;
        tpaRequest1.Is_Renewed__c = false;
        tpaRequest1.Purpose_List__c = 'Test Purpose List';
        tpaRequest1.Data_Asset_List__c = 'AAN';
        tpaRequest1.IMS_Legal_Entity_List__c = 'test';
        tpaRequest1.Secondary_Data_Asset_List__c = 'Test';
        tpaRequest1.Client_Request_Submission__c = todayDate.addDays(2);
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.TP_Processor_Email__c = 'test@mail.com';
        tpaRequest1.Data_access_end_date__c = (Date.today()).addDays(3);
        tpaRequest1.Vendor_Language__c =  'English';
        tpaRequest1.Is_DDN_Pending_Request__c = true;
        
        tpaRequestList.add(tpaRequest1);
     
        insert tpaRequestList;
     
        TPA_Request__c reqObj = [Select id,name from TPA_Request__c];
        TPA_Master_Extension_Information__c vendorOffRetAckObj = new TPA_Master_Extension_Information__c(
            TPA_Accounts_Address__c = testNewClientAccount.Id,
            DDN_Ack_Pending_Requests__c = reqObj.name,
            Return_Destruction_Ack_Outstanding__c = true);
        
        insert vendorOffRetAckObj;

        update reqObj;
    }

    @isTest static void test_tgrh_VendorOfferingReturnAck() {
        Test.StartTest();
        List<TPA_Request__c> requestList = [select Id, Client_Email__c, vendor_language__c,  TP_Processor_Email__c, Is_Partially_Renewed__c, Renewed_As__r.Is_Partially_Renewed__c, Request_status__c, Renewed_As__c, Client_Address__c,Parent_Request__c, Name, Agreement_Name__c, Is_TPA_Send_DDN_Button_Enabled__c, (select id,Is_AMA_License_Required__c  from AMA_Agreement_Details__r) from TPA_Request__c LIMIT 1];
        if(requestList.size() > 0) {
            
            Vendor_Offering_Return_Acknowledgment__c vendorOffRetAckObj = new Vendor_Offering_Return_Acknowledgment__c(Vendor_Destruction_Confirmation_FName__c = 'test First name',
                                                                                                                       Vendor_Destruction_Confirmation_LName__c = 'test LAst Name',
                                                                                                                       Vendor_Destruction_Confirmation_Title__c = 'test vendor title',
                                                                                                                       Vendor_Destruction_Confirmation_Email__c = 'test@mail.com',
                                                                                                                       TPA_Request__c = requestList[0].Id,
                                                                                                                       ActionTaken__c = 'Returned');


            insert vendorOffRetAckObj;
			
            TGRH_VendorOfferingReturnAck.sendClientNotificationForNotSharingExcludedOfferings(requestList[0]);
        }
    }
}