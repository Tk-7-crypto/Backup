@isTest
public class TST_CSM_Knowledge_UpdDocLink {
    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createAccount();
        acc.Website='http://www.iqvia.com';
        insert acc;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        Account account = UTL_TestData.createAccount();
        account.Website='http://www.iqvia.com';
        insert account;
        Contact contact = UTL_TestData.createContact(account.Id);
        insert contact;    
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', Pillar__c = 'Technology Solutions');
        insert knowledge;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = knowledge.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge.Id];
        KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
    }

    @IsTest
    static void testUpdateContentDocumentLinkKnowledgeRecord() {
        Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Title = 'TestTitle'][0];
        List<String> kIds = new  List<String>();
        kIds.add(k.Id);
        Test.startTest();
        CSM_Knowledge_UpdDocLink.updateContentDocumentLinkKnowledgeRecord(kIds);
        Test.stopTest();
    }
}