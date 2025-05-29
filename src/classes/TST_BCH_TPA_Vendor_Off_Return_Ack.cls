/**
* @Author: Babita Dadarwal
* @Description: Test class for BCH_TPA_Vendor_Off_Return_Ack Batch which sends offering Expiration mail to the vendors who haven't confirmed the offering return acknowledgment.
*/
@isTest(SeeAllData=false)
private class TST_BCH_TPA_Vendor_Off_Return_Ack { 

    @TestSetup static void setup() {
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
        
        Account acc = new Account(Name = 'Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        Test.setCreatedDate(acc.id, system.now().addDays(-730));
        
        List<Address__c> testAccounts = new List<Address__c>();
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test_Acc';
        testAccount1.Account__c = acc.Id;
        testAccount1.Is_TPA_Account__c = true;
        testAccounts.add(testAccount1);
        

        Address__c testAccountparant1 = UTL_TPA_SetupTestData.getAddress();
        testAccountparant1.Name = 'ABC Acc Patent1';
        testAccountparant1.Vendor_Registration_Number__c = 1241;
        testAccountparant1.Primary_Vendor_Address__c = true;
        testAccountparant1.Is_TPA_Account__c = true;
        testAccountparant1.Account__c = acc.Id;
        testAccounts.add(testAccountparant1);
        
        Address__c testAccount2 = UTL_TPA_SetupTestData.getAddress();
        testAccount2.Name = 'ABC Acc';
        testAccount2.Vendor_Registration_Number__c = 124;
        testAccount2.Is_TPA_Account__c = true;
        testAccounts.add(testAccount2);
        
        Address__c testAccountparant = UTL_TPA_SetupTestData.getAddress();
        testAccountparant.Name = 'ABC Acc Patent';
        testAccountparant.Vendor_Registration_Number__c = 1242;
        testAccountparant.Primary_Vendor_Address__c = true;
        testAccountparant.Is_TPA_Account__c = true;
        testAccounts.add(testAccountparant);
        
        insert testAccounts;
        Test.setCreatedDate(testAccount1.id, System.now().addDays(-720));
        Test.setCreatedDate(testAccountparant1.id, System.now().addDays(-720));
        Test.setCreatedDate(testAccount2.id, System.now().addDays(-720));
        Test.setCreatedDate(testAccountparant.id, System.now().addDays(-720));

        testAccount1.Parent_Vendor_Name__c = testAccountparant1.id;
        update testAccount1;
        testAccount2.Parent_Vendor_Name__c = testAccountparant.id;
        update testAccount2;
        
        
        Contact testContact = UTL_TPA_SetupTestData.getContact();
        testContact.AccountId = testAccount1.Account__c;
        insert testContact;
        Test.setCreatedDate(testContact.id, System.now().addDays(-720));

        List<TPA_Request__c> tpaRequestList = new List<TPA_Request__c>();

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.Global_Branding_Vendor_Address__c = testAccountparant1.Id;
        tpaRequest1.Request_Status__c = 'Expired';
        tpaRequest1.Data_Access_End_Date__c = Date.today().addDays(-10);
        tpaRequest1.Expired_Date__c =  Date.today().addDays(-1);
        tpaRequest1.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest1.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest1.ClientContact__c = testContact.Id;
        tpaRequest1.Is_Renewed__c = false;
        tpaRequest1.In_Effect_Date__c = Date.today().addDays(-50);
        tpaRequestList.add(tpaRequest1);

        TPA_Request__c tpaRequest2 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest2.OwnerId = UserInfo.getUserId();
        tpaRequest2.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest2.Global_Branding_Vendor_Address__c = testAccountparant1.Id;
        tpaRequest2.Request_Status__c = 'Expired';
        tpaRequest2.Data_Access_End_Date__c = Date.today().addDays(-20);
        tpaRequest2.Expired_Date__c =  Date.today().addDays(-8);
        tpaRequest2.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest2.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest2.ClientContact__c = testContact.Id;
        tpaRequest2.Is_Renewed__c = false;
        tpaRequest2.In_Effect_Date__c = Date.today().addDays(-50);
        tpaRequest2.Early_Contract_Expiry_Date__c = null;
        tpaRequestList.add(tpaRequest2);
        
        TPA_Request__c tpaRequest4 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest4.OwnerId = UserInfo.getUserId();
        tpaRequest4.Request_Status__c = 'Expired';
        tpaRequest4.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest4.Global_Branding_Vendor_Address__c = testAccountparant1.Id;
        tpaRequest4.Data_Access_End_Date__c = Date.today().addDays(-31);
        tpaRequest4.Expired_Date__c =  Date.today().addDays(-9);
        tpaRequest4.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest4.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest4.ClientContact__c = testContact.Id;
        tpaRequest4.In_Effect_Date__c = Date.today().addDays(-50);
        tpaRequest4.Early_Contract_Expiry_Date__c = Date.today().addDays(-5);
        tpaRequestList.add(tpaRequest4);
        
        TPA_Request__c tpaRequest5 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest5.OwnerId = UserInfo.getUserId();
        tpaRequest5.Request_Status__c = 'cancelled';
        tpaRequest5.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest5.Global_Branding_Vendor_Address__c = testAccountparant1.Id;
        tpaRequest5.Data_Access_End_Date__c = Date.today().addDays(-31);
        tpaRequest5.Cancelled__c =  Date.today().addDays(-3);
        tpaRequest5.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest5.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest5.ClientContact__c = testContact.Id;
        tpaRequest5.Is_Renewed__c = false;
        tpaRequest5.In_Effect_Date__c = Date.today().addDays(-50);
        tpaRequest5.Request_termination_time__c = DateTime.now();
        tpaRequest5.Early_Contract_Expiry_Date__c = Date.today().addDays(-5);
        tpaRequestList.add(tpaRequest5);

        TPA_Request__c tpaRequest6 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest6.OwnerId = UserInfo.getUserId();
        tpaRequest6.Request_Status__c = 'Expired';
        tpaRequest6.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest6.Global_Branding_Vendor_Address__c = testAccountparant1.Id;
        tpaRequest6.Data_Access_End_Date__c = Date.today().addDays(-31);
        tpaRequest6.Expired_Date__c =  Date.today().addDays(-6);
        tpaRequest6.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest6.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest6.ClientContact__c = testContact.Id;
        tpaRequest6.In_Effect_Date__c = Date.today().addDays(-50);
        tpaRequestList.add(tpaRequest6);

        TPA_Request__c tpaRequest7 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest7.OwnerId = UserInfo.getUserId();
        tpaRequest7.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest7.Global_Branding_Vendor_Address__c = testAccountparant.Id;
        tpaRequest7.Client_Address__c = testAccount1.Id;
        tpaRequest7.Request_Status__c = 'Awaiting Vendor Signature';
        tpaRequest7.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest7.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest7.ClientContact__c = testContact.Id;
        tpaRequest7.Is_Renewed__c = false;
        tpaRequestList.add(tpaRequest7);
        
        TPA_Request__c tpaRequest9 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest9.OwnerId = UserInfo.getUserId();
        tpaRequest9.Request_Status__c = 'In Review by IQVIA';
        tpaRequest9.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest9.Global_Branding_Vendor_Address__c = testAccountparant1.Id;
        tpaRequest9.Data_Access_End_Date__c = Date.today().addDays(-31);
        tpaRequest9.Cancelled__c =  Date.today().addDays(-3);
        tpaRequest9.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest9.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest9.ClientContact__c = testContact.Id;
        tpaRequest9.Is_Renewed__c = false;
        tpaRequest9.Is_Partially_Renewed__c = true;
        tpaRequest9.In_Effect_Date__c = Date.today().addDays(-50);
        tpaRequest9.Request_termination_time__c = DateTime.now();
        tpaRequestList.add(tpaRequest9);

        insert tpaRequestList;
        
        TPA_Request__c tpaRequest8 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest8.OwnerId = UserInfo.getUserId();
        tpaRequest8.Request_Status__c = 'Expired';
        tpaRequest8.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest8.Global_Branding_Vendor_Address__c = testAccountparant1.Id;
        tpaRequest8.Data_Access_End_Date__c = Date.today().addDays(-31);
        tpaRequest8.Expired_Date__c =  Date.today().addDays(-6);
        tpaRequest8.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest8.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest8.ClientContact__c = testContact.Id;
        tpaRequest8.Is_Renewed__c = true;
        tpaRequest8.Renewed_As__c = tpaRequest9.Id;
        tpaRequest8.In_Effect_Date__c = Date.today().addDays(-50);
        tpaRequest5.Partially_Renewed_Date__c = DateTime.now();
        insert tpaRequest8;
        
        List<TPA_Contact__c> contacts = new List<TPA_Contact__c>();
        for(TPA_Request__c req: tpaRequestList){
            contacts.add(new TPA_Contact__c(Name='Vijay',Type__c='Additional Vendor Contact',Email__c = 'a@a.in',TPA_Request__c=req.Id));
            Test.setCreatedDate(req.id, System.now().addDays(-720));
        }
        
        insert contacts;
        for(TPA_Contact__c con: contacts){
            Test.setCreatedDate(con.id, System.now().addDays(-720));
        }
        tpaRequest4.Renewed_As__c = tpaRequest5.Id;
        update tpaRequest4;
        

        TPA_Contact__c tpaContact3 = UTL_TPA_SetupTestData.getTPAContactByReqId(tpaRequest1);
        TPA_Contact__c tpaContact1 = UTL_TPA_SetupTestData.getTPAContactByReqId(tpaRequest2);
       
         List<TPA_Agreement_Additional_Field__c> agrList = new List<TPA_Agreement_Additional_Field__c>();

        TPA_Agreement_Additional_Field__c aggAdditionalFieldObj1 = UTL_TPA_SetupTestData.returnTPAAgreementAdditionalFieldObj(tpaRequest1);
        agrList.add(aggAdditionalFieldObj1);
        TPA_Agreement_Additional_Field__c aggAdditionalFieldObj2 = UTL_TPA_SetupTestData.returnTPAAgreementAdditionalFieldObj(tpaRequest2);
        aggAdditionalFieldObj2.Early_Contract_Expiry_Date__c = null;
        agrList.add(aggAdditionalFieldObj2);
        
        TPA_Agreement_Additional_Field__c aggAdditionalFieldObj4 = UTL_TPA_SetupTestData.returnTPAAgreementAdditionalFieldObj(tpaRequest4);
        aggAdditionalFieldObj4.Early_Contract_Expiry_Date__c = Date.today().addDays(-5);
        agrList.add(aggAdditionalFieldObj4);
        TPA_Agreement_Additional_Field__c aggAdditionalFieldObj5 = UTL_TPA_SetupTestData.returnTPAAgreementAdditionalFieldObj(tpaRequest5);
        aggAdditionalFieldObj5.Early_Contract_Expiry_Date__c = Date.today().addDays(-5);
        agrList.add(aggAdditionalFieldObj5);
        TPA_Agreement_Additional_Field__c aggAdditionalFieldObj6 = UTL_TPA_SetupTestData.returnTPAAgreementAdditionalFieldObj(tpaRequest6);
        agrList.add(aggAdditionalFieldObj6);

        insert agrList;
        for(TPA_Agreement_Additional_Field__c AAF:agrList){
            Test.setCreatedDate(AAF.id, System.now().addDays(-720));
        }
    }

    @isTest static void test_SendVendorOffRetAckNotificationMailFORNonTestRcrd() {
      

        Contact testContact = [select id from Contact where firstName = 'testfirstname'];
        Address__c testAccount2 = [select id from Address__c where name = 'ABC Acc'];
        Address__c testAccountparant = [select id from Address__c where name = 'ABC Acc Patent'];


        List<TPA_Request__c> tpaRequestList = new List<TPA_Request__c>();

        TPA_Request__c tpaRequest3 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest3.OwnerId = UserInfo.getUserId();
        tpaRequest3.Service_Provider_Address__c = testAccount2.Id;
        tpaRequest3.Global_Branding_Vendor_Address__c = testAccountparant.Id;
        tpaRequest3.Client_Address__c = testAccount2.Id;
        tpaRequest3.Request_Status__c = 'Expired';
        tpaRequest3.Data_Access_End_Date__c = Date.today().addDays(-10);
        tpaRequest3.Expired_Date__c =  Date.today().addDays(-19);
        tpaRequest3.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest3.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest3.ClientContact__c = testContact.Id;
        tpaRequest3.Is_Renewed__c = false;
        tpaRequest3.In_Effect_Date__c = Date.today().addDays(-50);
        tpaRequest3.Request_termination_time__c = Date.today().addDays(-19);
        tpaRequestList.add(tpaRequest3);

        TPA_Request__c tpaRequest2 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest2.OwnerId = UserInfo.getUserId();
        tpaRequest2.Service_Provider_Address__c = testAccount2.Id;
        tpaRequest2.Global_Branding_Vendor_Address__c = testAccountparant.Id;
        tpaRequest2.Client_Address__c = testAccount2.Id;
        tpaRequest2.Request_Status__c = 'Awaiting Vendor Signature';
        tpaRequest2.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest2.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest2.ClientContact__c = testContact.Id;
        tpaRequest2.Is_Renewed__c = false;
        tpaRequestList.add(tpaRequest2);

        TPA_Request__c tpaRequest8 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest8.OwnerId = UserInfo.getUserId();
        tpaRequest8.Service_Provider_Address__c = testAccount2.Id;
        tpaRequest8.Client_Address__c = testAccount2.Id;
        tpaRequest8.Global_Branding_Vendor_Address__c = testAccountparant.Id;
        tpaRequest8.Request_Status__c = 'Expired';
        tpaRequest8.Data_Access_End_Date__c = Date.today().addDays(-10);
        tpaRequest8.Expired_Date__c =  Date.today().addDays(-30);
        tpaRequest8.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest8.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest8.ClientContact__c = testContact.Id;
        tpaRequest8.Is_Renewed__c = false;
        tpaRequest8.In_Effect_Date__c = Date.today().addDays(-50);
        tpaRequest8.Request_termination_time__c = Date.today().addDays(-30);
        tpaRequestList.add(tpaRequest8);

        TPA_Request__c tpaRequest9 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest9.OwnerId = UserInfo.getUserId();
        tpaRequest9.Service_Provider_Address__c = testAccount2.Id;
        tpaRequest9.Client_Address__c = testAccount2.Id;
        tpaRequest9.Global_Branding_Vendor_Address__c = testAccountparant.Id;
        tpaRequest9.Request_Status__c = 'Expired';
        tpaRequest9.Data_Access_End_Date__c = Date.today().addDays(-10);
        tpaRequest9.Expired_Date__c =  Date.today().addDays(-91);
        tpaRequest9.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest9.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest9.ClientContact__c = testContact.Id;
        tpaRequest9.Is_Renewed__c = false;
        tpaRequest9.In_Effect_Date__c = Date.today().addDays(-50);
        tpaRequest9.Request_termination_time__c = Date.today().addDays(-91);
        tpaRequestList.add(tpaRequest9);

        insert tpaRequestList;
        for(TPA_Request__c tpaRequest:tpaRequestList){
            test.setCreatedDate(tpaRequest.id, system.now().addDays(-720));
        }
        Test.startTest();
        

        List<TPA_Request__c> tpaRequestList1 = [Select id,
                                                createdDate,
                                                   Service_Provider_f__c,
                                                   Client_First_Name__c,
                                                   Expired_Date__c,
                                                   vendor_language__c,
                                                   name,
                                                   request_termination_time__c,
                                                   Request_Status__c,
                                                   Vendor_e_mail__c,
                                                   Authorized_Signer_Email__c,
                                                   TP_Processor_Email__c,
                                                   ClientContact__r.Email,
                                                   Vendor_App_Submitted__c,
                                                   Early_Contract_Expiry_Date__c,
                                                   (select id, Email__c from TPA_Request_Contacts__r),
                                                   
                                                   (select id, Name, Early_Contract_Expiry_Date__c  from TPA_Agreement_Additional_Fields__r),
                                                   data_access_end_date__c
                                               from TPA_Request__c
                                               where ( Request_Status__c IN ( 'Expired', 'AMA Discontinued', 'AMA Discontinued', 'AMA Cancelled', 'Client Discontinued') )
                                               and Is_Submitted__c = true
                                               and (Is_Renewed__c = false OR (Is_Renewed__c = true AND Renewed_As__r.Request_Status__c = 'cancelled'))
                                               and In_Effect_Date__c != null
                                               and ((not Client_Address__r.Name Like 'Test_') AND (not Service_Provider_f__c Like 'Test_') )
                                               and id not in (select TPA_Request__c from Vendor_Offering_Return_Acknowledgment__c)];
        for(TPA_Request__c req : tpaRequestList1) {
            system.debug('@@@@@@@@@@@' + req);
        }
        BCH_TPA_Vendor_Off_Return_Ack vendorOffRetAck = new BCH_TPA_Vendor_Off_Return_Ack();
        Database.executebatch(vendorOffRetAck, 10);
        
        
        BCH_TPA_Vendor_Off_Return_Ack.updateRequest(tpaRequestList1[0]);
        Test.stopTest();
  }

  @isTest static void test_SendVendorOffRetAckNotificationMailFORTestRcrd() {
    Test.startTest();
    
    

    List<TPA_Request__c> tpaRequestList1 = [Select id,
                                            Createddate,
                                               Service_Provider_f__c,
                                               Client_First_Name__c,
                                               Expired_Date__c,
                                               vendor_language__c,
                                               name,
                                               request_termination_time__c,
                                               Request_Status__c,
                                               Vendor_e_mail__c,
                                               Authorized_Signer_Email__c,
                                               TP_Processor_Email__c,
                                               ClientContact__r.Email,
                                               Early_Contract_Expiry_Date__c,
                                               (select id, Email__c from TPA_Request_Contacts__r),
                                               
                                               (select id, Name, Early_Contract_Expiry_Date__c  from TPA_Agreement_Additional_Fields__r),
                                               data_access_end_date__c
                                           from TPA_Request__c
                                           where ( Request_Status__c IN ( 'Expired', 'AMA Discontinued', 'AMA Discontinued', 'AMA Cancelled', 'Client Discontinued') )
                                           and Is_Submitted__c = true
                                           and (Is_Renewed__c = false OR (Is_Renewed__c = true AND Renewed_As__r.Request_Status__c = 'cancelled'))
                                           and In_Effect_Date__c != null
                                           and (Client_Address__r.Name Like 'Test_' OR Service_Provider_f__c Like 'Test_' )
                                           and id not in (select TPA_Request__c from Vendor_Offering_Return_Acknowledgment__c)];
    for(TPA_Request__c req : tpaRequestList1) {
        system.debug('@@@@@@@@@@@' + req);
    }
    BCH_TPA_Vendor_Off_Return_Ack vendorOffRetAck = new BCH_TPA_Vendor_Off_Return_Ack();
    Database.executebatch(vendorOffRetAck, 10);
      
    Test.stopTest();
}
    @isTest static void test_SendVendorOffRetAckNotificationMailFORNonTestRcrd2(){
        Contact testContact = [select id from Contact where firstName = 'testfirstname'];
        Address__c testAccount2 = [select id from Address__c where name = 'ABC Acc'];
        Address__c testAccountparant = [select id from Address__c where name = 'ABC Acc Patent'];

        //List<TPA_Request__c> tpaRequestList = new List<TPA_Request__c>();

        TPA_Request__c tpaRequest0 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest0.OwnerId = UserInfo.getUserId();
        tpaRequest0.Service_Provider_Address__c = testAccount2.Id;
        tpaRequest0.Global_Branding_Vendor_Address__c = testAccountparant.Id;
        tpaRequest0.Client_Address__c = testAccount2.Id;
        tpaRequest0.Request_Status__c = 'cancelled';
        tpaRequest0.Data_Access_End_Date__c = Date.today().addDays(-20);
        tpaRequest0.Cancelled__c = datetime.now().addDays(-2);
        tpaRequest0.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest0.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest0.ClientContact__c = testContact.Id;
        tpaRequest0.Is_Renewed__c = true;
        tpaRequest0.In_Effect_Date__c = Date.today().addDays(-50);
        tpaRequest0.Request_Termination_Time__c = Datetime.now().addDays(-10);
       insert tpaRequest0;
        
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Renewed_As__c = tpaRequest0.id;
        tpaRequest1.Service_Provider_Address__c = testAccount2.Id;
        tpaRequest1.Global_Branding_Vendor_Address__c = testAccountparant.Id;
        tpaRequest1.Client_Address__c = testAccount2.Id;
        tpaRequest1.Request_Status__c = 'Expired';
        tpaRequest1.Data_Access_End_Date__c = Date.today().addDays(-2);
        tpaRequest1.Expired_Date__c =  Date.today().addDays(-6);
        tpaRequest1.Vendor_e_mail__c = 'test1@mail.com';
        tpaRequest1.TP_Processor_Email__c = 'tptest@mail.com';
        tpaRequest1.ClientContact__c = testContact.Id;
        tpaRequest1.Is_Renewed__c = false;
        tpaRequest1.In_Effect_Date__c = Date.today().addDays(-10);
        tpaRequest1.Request_termination_time__c = Date.today().addDays(-3);
        insert tparequest1;

        Test.setCreatedDate(tpaRequest0.id, Datetime.now().addDays(-50));
        Test.setCreatedDate(tpaRequest1.id, Datetime.now().AddDays(-10));
        Test.startTest();
        List<TPA_Request__c> tpaRequestList1 = [Select id,
                                                createdDate,
                                                   Service_Provider_f__c,
                                                   Client_First_Name__c,
                                                   Expired_Date__c,
                                                   vendor_language__c,
                                                   name,
                                                   request_termination_time__c,
                                                   Request_Status__c,
                                                   Vendor_e_mail__c,
                                                   Authorized_Signer_Email__c,
                                                   TP_Processor_Email__c,
                                                   ClientContact__r.Email,
                                                   Vendor_App_Submitted__c,
                                                   Early_Contract_Expiry_Date__c,
                                                   (select id, Email__c from TPA_Request_Contacts__r),
                                                   (select id, Name, Early_Contract_Expiry_Date__c  from TPA_Agreement_Additional_Fields__r),
                                                   data_access_end_date__c
                                               from TPA_Request__c
                                               where ( Request_Status__c IN ( 'Expired', 'AMA Discontinued', 'AMA Discontinued', 'AMA Cancelled', 'Client Discontinued') )
                                               and Is_Submitted__c = true
                                               and (Is_Renewed__c = false OR (Is_Renewed__c = true AND Renewed_As__r.Request_Status__c = 'cancelled'))
                                               and In_Effect_Date__c != null
                                               and ((not Client_Address__r.Name Like 'Test_') AND (not Service_Provider_f__c Like 'Test_') )
                                               and id not in (select TPA_Request__c from Vendor_Offering_Return_Acknowledgment__c)];
        BCH_TPA_Vendor_Off_Return_Ack vendorOffRetAck = new BCH_TPA_Vendor_Off_Return_Ack();
        Database.executebatch(vendorOffRetAck, 10);
        BCH_TPA_Vendor_Off_Return_Ack.updateRequest(tpaRequestList1[0]);
        Test.stopTest();
    }

}
