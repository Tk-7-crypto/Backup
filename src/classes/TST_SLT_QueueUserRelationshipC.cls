@isTest
private class TST_SLT_QueueUserRelationshipC {

    static testMethod void testQueueUserRelationship(){
        Id userId = UserInfo.getUserId();
        Queue_User_Relationship__c qr = new Queue_User_Relationship__c();
        qr.Name = 'RnD - Global Investigator Services';
        qr.QueueName__c ='RnD - Global Investigator Services';
        qr.Type__c ='Queue';
        qr.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
        insert qr;
        Queue_User_Relationship__c qur = new Queue_User_Relationship__c();
        qur.Name ='RnD - Global Investigator Services';
        qur.QueueName__c = 'RnD - Global Investigator Services';
        qur.Type__c ='User';
        qur.User__c = userId;
        qur.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
        insert qur;
        SLT_QueueUserRelationshipC qu = new SLT_QueueUserRelationshipC();
        qu.getUserQueueRecords();
        qu.selectAllTechQueue(new Set<String>{'Id'});
        qu.selectAllRnDQueues();
        qu.selectByGroupIdSet(new Set<Id>{userId});
        qu.selectByGroupOLA(new Set<Id>{userId});
        qu.selectByQueueId(new Set<Id>{userId}, new Set<String>{'Id'});
        qu.selectByQueueIdSet(new Set<Id>{userId}, new Set<String>{'Id'});
        qu.selectByQueueName('RnD - Global Investigator Services', new Set<String>{'Id'}, userId);
        qu.selectByUserGrop(new Set<Id>{userId});
        qu.selectByUserQueueName(new Set<Id>{userId}, new Set<String>{'RnD - Global Investigator Services'});
        qu.selectBasedOnQueueId(new Set<Id>{qur.Id});
        qu.selectBasedOnUserGroup(new Set<Id>{userId});
        qu.selectBasedOnUserGroupTOwner(new Set<Id>{userId});
        qu.selectByQueueName(new Set<String>{'RnD - Global Investigator Services'});
    }
}