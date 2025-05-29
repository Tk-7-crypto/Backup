/*
 * Author		: 
 * Purpose		: Test class for BCH_CRM_RevenueAnalystSBSQueueSync
 */
@isTest
public class TST_BCH_CRM_RevenueAnalystSBSQueueSync {
    
    @testSetup 
    static void setupTestData() {
        String profileName = 'System Administrator';
        List<User> userList = UTL_TestData.createUser(profileName, 10);
        insert userlist;        
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Revenue_Analyst__c');
        insert q1;
        GroupMember gp = new GroupMember(UserorGroupId = UserInfo.getUserId(), GroupId=g1.Id);
        insert gp;   
    }
    
    //Test Batch
    public static testmethod void t1() {       
        Group g = [select id from group where name= 'group name' Limit 1];
        Revenue_Analyst__c revenueAnalyst = new Revenue_Analyst__c(OwnerId = g.Id, Name='TstAnalyst1',Revenue_Analyst_Email__c='test1@xyz.com' ,User__c=UserInfo.getUserId(), User_2__c=UserInfo.getUserId());
        insert revenueAnalyst;
        revenueAnalyst.Name = 'TestAnalyst';
        update revenueAnalyst;
        Test.startTest();
        BCH_CRM_RevenueAnalystSBSQueueSync obj = new BCH_CRM_RevenueAnalystSBSQueueSync();
        DataBase.executeBatch(obj);                
        Test.stopTest();
    }
    
    //Test Batch for Exception
    public static testmethod void t2() {
        Test.startTest();
        BCH_CRM_RevenueAnalystSBSQueueSync obj = new BCH_CRM_RevenueAnalystSBSQueueSync();
        obj.exception_List.add('Demo Exception');
        DataBase.executeBatch(obj);
        Test.stopTest();
    } 
}