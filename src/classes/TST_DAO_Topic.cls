@isTest
private class TST_DAO_Topic {
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
        User usr = UTL_TestData.createUser('Service User',1)[0];
        insert usr;
        Knowledge__kav k1 = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Title = 'TestTitle1' LIMIT 1];
        Topic t1 = new Topic(Name='Test Topic',Description='Test Topic Descrition');
        Test.startTest();
            insert t1;
            t1.Description = 'Update';
        	update t1;
        Test.stopTest();
    }
}