@isTest
public class TST_TGR_SWAT_Intake {
    @testSetup
    static void dataSetup() {
        Account acc1 = UTL_TestData.createAccount();
        acc1.Name = 'Test Parent Acc';
        insert acc1;
        upsert new  Mulesoft_Integration_Control__c(name = 'testSetting', Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        Account acc = UTL_TestData.createAccount();
        acc.ParentId = acc1.Id;
        insert acc;
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 2);
        userList.addall(UTL_TestData.createUser('Sales User', 1));
        userList[0].PIC_Eligible__c = true;
        userList[0].IsActive = true;
        userList[1].PIC_Eligible__c = true;
        userList[1].IsActive = true;
        insert userList;
        upsert new Email_Notification_To_User__c(User_Ids__c = userList[0].Id,Account_Ids__c = acc1.Id);
        upsert new SWAT_Intake_alert__c(Users_Email__c = userList[0].Email);
        Contact cnt = UTL_TestData.createContact(acc.Id);
        cnt.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt.Salesforce_User__c = userList[0].Id;
        insert cnt;
        Account acc2 = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc2.Id);
        Test.startTest();
        insert opp;
        SWAT_Intake__c swt = new SWAT_Intake__c();
		swt.Opportunity__c = opp.Id;
        swt.Submit_Form_To_SWAT_Team__c = true;
        insert swt;
    }
    /**
    * This test method used for insert and update SWAT Intake record
    */ 
    static testMethod void test2() {
        SWAT_Intake__c swt = [SELECT Id, Name FROM SWAT_Intake__c limit 1];
        swt.Submit_Form_To_SWAT_Team__c = true;
        update swt;
    }
}