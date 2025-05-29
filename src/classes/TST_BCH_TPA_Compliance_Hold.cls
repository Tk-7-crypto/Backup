@isTest
public class TST_BCH_TPA_Compliance_Hold {
	
    @TestSetup static void setup() {
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
		
		Account acc = new Account(Name = 'Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test_Acc';
        testAccount1.Account__c = acc.Id;
        insert testAccount1;

        Address__c testAccountparant1 = UTL_TPA_SetupTestData.getAddress();
        testAccountparant1.Name = 'ABC Acc Patent1';
        testAccountparant1.Vendor_Registration_Number__c = 1241;
        testAccountparant1.Primary_Vendor_Address__c = true;
        insert testAccountparant1;

        testAccount1.Parent_Vendor_Name__c = testAccountparant1.id;
        update testAccount1;


        Contact testContact = UTL_TPA_SetupTestData.getContact();
        testContact.AccountId = testAccount1.Account__c;
        insert testContact;
        
        Address__c testAccount2 = UTL_TPA_SetupTestData.getAddress();
        testAccount2.Name = 'ABC Acc';
        testAccount2.Vendor_Registration_Number__c = 124;
        insert testAccount2;

        Address__c testAccountparant = UTL_TPA_SetupTestData.getAddress();
        testAccountparant.Name = 'ABC Acc Patent';
        testAccountparant.Vendor_Registration_Number__c = 1242;
        testAccountparant.Primary_Vendor_Address__c = true;
        insert testAccountparant;

        testAccount2.Parent_Vendor_Name__c = testAccountparant.id;
        update testAccount2;

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
        tpaRequest1.isVendorOnComplianceHold__c = true;
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


        insert tpaRequestList;
    }
    
    @isTest static void testComplianceHoldonTPARequests(){
        List<Account> accountsTest = [Select Id,Name From Account where Name Like 'Test%'];
        Account_Compliance__c accComp = new Account_Compliance__c();
        accComp.Account__c = accountsTest[0].Id;
        accComp.Vendor_TPA_Compliance_Hold__c = true;
        accComp.Client_TPA_Compliance_Hold__c = true;
        insert accComp;
        List<Id> accounts = new List<Id>();
        accounts.add(accountsTest[0].Id);
        Test.startTest();
        BCH_TPA_Compliance_Hold bchObj = new BCH_TPA_Compliance_Hold();
        bchObj.accountsOnHold = accounts;
        bchObj.type = 'PutOnHold';
    	Database.executebatch(bchObj, 10);
        Test.stopTest();
    }
   @isTest static void testRemoveComplianceHoldonTPARequests(){
       List<Account> accountsTest = [Select Id,Name From Account where Name Like 'Test%'];
       Account_Compliance__c accComp = new Account_Compliance__c();
       accComp.Account__c = accountsTest[0].Id;
       accComp.Vendor_TPA_Compliance_Hold__c = true;
       accComp.Client_TPA_Compliance_Hold__c = true;
       insert accComp;
       List<Id> accounts = new List<Id>();
       accounts.add(accountsTest[0].Id);
       Test.startTest();
       BCH_TPA_Compliance_Hold bchObj = new BCH_TPA_Compliance_Hold();
       bchObj.accountsOnHold = accounts;
       bchObj.type = 'PutOnHold';
       Database.executebatch(bchObj, 10);
       
       Account testAccount = [select id, Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold__c from Account where Name = 'Test Account'];
       testAccount.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold__c = false;
       update testAccount;
       TPA_Request__c testRequest = [select id, isVendorOnComplianceHold__c from TPA_Request__c where Request_Status__c = 'Awaiting Vendor Signature'];
       testRequest.isVendorOnComplianceHold__c = true;
       update testRequest;
       accComp.Vendor_TPA_Compliance_Hold__c = false;
       accComp.Client_TPA_Compliance_Hold__c = false;
       update accComp;
       bchObj.type = 'RemoveFromHold';
       Database.executebatch(bchObj, 10);
       Test.stopTest();
    }
}