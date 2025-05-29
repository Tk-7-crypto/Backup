/*
 * Version       : 1.0
 * Description   : Test Class for DAOH_Revenue_Analyst 
 */
@isTest
private class TST_DAOH_Revenue_Analyst {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        List<User> userList = UTL_TestData.createUser('Sales User', 10);
        insert userList;
        Group groupRecord = UTL_TestData.createGroup('Sales User Group Test', 'Queue');
        insert groupRecord;
        QueuesObject q1 = new QueueSObject(QueueID = groupRecord.id, SobjectType = 'Revenue_Analyst__c');
        insert q1;
        List<GroupMember> groupMemberList = new List<GroupMember>();
        for(User user : userList) {
            groupMemberList.add(UTL_TestData.createGroupMember(groupRecord.Id, user.Id));
        }
        insert groupMemberList;
    }
    
    static testMethod void testRevenueAnalyst() {
        Group groupRecord = [SELECT Id FROM Group WHERE Name = 'Sales User Group Test'];
        Test.startTest();
        Current_Release_Version__c crv = new Current_Release_Version__c();
		crv.Current_Release__c = '3000.01';
        upsert crv;
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        upsert bs;
        Mulesoft_Integration_Control__c mulesoft = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        upsert mulesoft;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        revenueAnalyst.OwnerId = groupRecord.Id;
        revenueAnalyst.Revenue_Analyst_Email__c = 'test123@metacube.com';
        insert revenueAnalyst;
        Test.stopTest();
    }
    
    static testMethod void testRevenueAnalyst1() {
        Test.startTest();
        Current_Release_Version__c crv = new Current_Release_Version__c();
		crv.Current_Release__c = '3000.01';
        upsert crv;
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        upsert bs;
        Mulesoft_Integration_Control__c mulesoft = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        upsert mulesoft;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        Test.stopTest();
    }
}