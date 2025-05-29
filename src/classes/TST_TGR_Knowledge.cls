@isTest
public class TST_TGR_Knowledge {
    
    static testMethod void testInsertKnowledgeArticle() {
        test.startTest();
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,IsVisibleInPrm=false, Partner_Type__c = '');
        insert knowledge;
        test.stopTest();
    }
    
    static testMethod void testUpdateKnowledgeArticle() {
        test.startTest();
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle1', language = 'en_US',UrlName='TestUrlName1', IsVisibleInCsp= true, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,IsVisibleInPrm=false, Partner_Type__c = '');
        insert knowledge;
        knowledge.IsVisibleInCsp = true;
        update knowledge;
        test.stopTest();
    }

}