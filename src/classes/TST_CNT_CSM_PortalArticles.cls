/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_PortalArticles
 */
@isTest
public class TST_CNT_CSM_PortalArticles {
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Pillar__c = 'Technology Solutions');
        insert knowledge;
        Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id=:knowledge.Id];
        KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
        Topic topic = New Topic(Name = 'TopicsName');
        insert topic;
        TopicAssignment ta = New TopicAssignment(EntityId=knowledge.Id,TopicId=topic.Id);
        insert ta;
    }
    
    /**
     * This method used to get a List<Knowledge__kav> by topics
     */    
    @IsTest
    static void testGetArticlesByTopic() {
        List<Knowledge__kav> articles = new  List<Knowledge__kav>();
        List<Topic> topics =[SELECT Id FROM Topic WHERE Name='TopicsName'];
        Test.startTest();
        articles = CNT_CSM_PortalArticles.getArticlesByTopic(topics[0].Id);  
        Test.stopTest();
        Integer expected = 1;
        Integer actual = articles.size();
        System.assertEquals(expected, actual);
    }
}