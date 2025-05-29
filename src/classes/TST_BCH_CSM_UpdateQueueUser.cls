@isTest
private class TST_BCH_CSM_UpdateQueueUser {

    @isTest
    public static void testUpdateQueueUser(){
        
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c();
        queues1.Name ='RnD - Global Account Management';
        queues1.QueueName__c ='RnD - Global Account Management';
        queues1.Type__c ='Queue';
        queues1.AFU_Queue_Email__c = 'dummymail@mail.com'; 
        insert queues1;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c();
        queueUser1.Name ='RnD - Global Account Management';
        queueUser1.QueueName__c ='RnD - Global Account Management';
        queueUser1.Type__c ='User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        
        Test.startTest();
        BCH_CSM_UpdateQueueUser bchUser = new BCH_CSM_UpdateQueueUser();
        Database.executeBatch(bchUser);
        Test.stopTest();
    }
}