@isTest
private class TST_TGR_TopicAssignment {
	@testSetup
    static void setup() {
        Knowledge__kav article = New Knowledge__kav(Title = 'TestTitle1', language = 'en_US', UrlName = 'TestUrlName1', 
                                                    IsVisibleInCsp = true, Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS,
                                                    Partner_Type__c = 'Integrator Partner', IsVisibleInPrm = true);
        insert article;
        Knowledge__kav k1 = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id =: article.Id];
        KbManagement.PublishingService.publishArticle(k1.KnowledgeArticleId, true);
    }
    @isTest
    static void testBeforeInsertTopicAssignment(){
        Knowledge__kav k1 = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Title = 'TestTitle1' LIMIT 1];
        Topic t1 = new Topic(Name='Test Topic',Description='Test Topic Descrition');
        insert t1;
        
        TopicAssignment ta = new TopicAssignment(TopicId=t1.Id,EntityId=k1.Id);
        Test.startTest();
            insert ta;
        Test.stopTest();
    }
}