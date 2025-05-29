/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Topic
 */
@isTest
private class TST_SLT_Topic {
    
    @testSetup
    static void dataSetup() {
        Topic topic = new Topic(Name = 'Test Topic');
        insert topic;
    }
    
    @isTest
    static void testSelectById() {
        List<Topic> topicList = new List<Topic>();
        Set<Id> topicIdSet = new Set<Id>();
        Topic topic = [SELECT Id FROM Topic LIMIT 1];
        topicIdSet.add(topic.Id);
        Test.startTest();
        topicList = new SLT_Topic().selectById(topicIdSet);
        Test.stopTest();
        System.assertEquals('Test Topic', topicList[0].Name);
    }
    
    @isTest
    static void testSelectAll() {
        List<Topic> topicList = new List<Topic>();
        Test.startTest();
        topicList = new SLT_Topic().selectAll();
        Test.stopTest();
        System.assertEquals('Test Topic', topicList[0].Name);
    }
    
    @isTest
    static void testGetTopicsName() {
        List<Topic> topicList = new List<Topic>();
        Set<String> topicsNameSet = new Set<String>();
        topicsNameSet.add('Test Topic');
        Test.startTest();
        topicList = new SLT_Topic().selectByName(topicsNameSet);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = topicList.size();
        System.assertEquals(expected, actual);
    }
    
    @isTest
    static void testSelectByTopicId() {
        Map<Id, Topic> topicMap = new Map<Id,Topic>();
        Set<Id> topicIdSet = new Set<Id>();
        Set<String> fieldSet = new Set<String>{'Id', 'Name'};
        Topic topic = [SELECT Id FROM Topic LIMIT 1];
        topicIdSet.add(topic.Id);
        Test.startTest();
        topicMap = new SLT_Topic().selectByTopicId(topicIdSet, fieldSet);
        Test.stopTest();
        System.assertEquals('Test Topic', topicMap.get(topic.Id).Name);
    } 
}