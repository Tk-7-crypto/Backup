/**
* This test class is used to test Credit_Control_Threshold Trigger.
* version : 1.0
*/
@isTest
private class TST_DAO_CreditControlThreshold {

    @testSetup
    static void setUpData() {
        Group grp = new Group(name='Super Credit Control Admins');
        insert grp;  
        Id userId = UserInfo.getUserId();
        User testUser = [Select id, Name from User where id = :userId];
        System.runAs(testUser) {
            GroupMember grpMember = new GroupMember(GroupId = grp.Id, UserOrGroupId = userId);
            insert grpMember;
        }
        Account account = UTL_TestData.createAccount();
        insert account;
    }
    
    static testMethod void testValidateSuperCreditControlGroup() {
        Test.startTest();
        Account account = [SELECT Id FROM Account WHERE Name = 'TestAccount' Limit 1];
        Credit_Control_Threshold__c cct = new Credit_Control_Threshold__c(Account__c=account.Id, Threshold_value_USD__c=200, Description__c='test');
        insert cct;
		cct.Threshold_value_USD__c = 500;
        upsert cct;
        delete cct;
        Test.stopTest();
    }
}