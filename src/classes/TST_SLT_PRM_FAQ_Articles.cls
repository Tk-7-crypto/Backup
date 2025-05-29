@isTest
public class TST_SLT_PRM_FAQ_Articles {
    @testSetup
    static void dataSetup() {
        PRM_FAQ_Articles__c faqArticles = new PRM_FAQ_Articles__c();
        faqArticles.Name = 'Test Article';
        faqArticles.Article_Link__c = 'Test-Article';
        faqArticles.IsActive__c = true;
        faqArticles.Order__c = 1;
        insert faqArticles;
    }
    
    @IsTest
    static void testGetFAQArticles() {
        List<PRM_FAQ_Articles__c> faq = [SELECT Name, Article_Link__c FROM PRM_FAQ_Articles__c];
        List<PRM_FAQ_Articles__c> faqArticles = new List<PRM_FAQ_Articles__c>();
        Test.startTest();
        faqArticles = new SLT_PRM_FAQ_Articles().getFAQArticles();
        Test.stopTest();
        System.assertEquals(faq[0].Name, faqArticles[0].Name);
    }
}