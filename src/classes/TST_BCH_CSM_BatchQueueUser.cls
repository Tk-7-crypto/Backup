@IsTest
private class TST_BCH_CSM_BatchQueueUser {
    @testSetup
    static void setup() {
        
        User u = new User (
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@accenture.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            EmployeeNumber = '09873898',
            LocaleSidKey = 'en_US',
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description'
        );
        
        insert u;
        u.EmployeeNumber = '887866';
        
        Group testQueue = new Group(Name = 'Test Queue', Type = 'Queue');
        insert testQueue;
        
        QueuesObject q1 = new QueueSObject(QueueID = testQueue.id, SobjectType = 'Case');
        insert q1;
        
        GroupMember grpUser = new GroupMember (
            UserOrGroupId = u.Id,
            GroupId = testQueue.Id);
        
        insert grpUser;
    }
    
    @IsTest
    private static void testBatchQueueUser() {
        Test.startTest();
            Database.executeBatch(new BCH_CSM_BatchQueueUser(), 1);
        Test.stopTest();
    }
}