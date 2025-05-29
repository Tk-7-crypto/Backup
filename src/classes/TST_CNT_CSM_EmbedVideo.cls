@isTest
public class TST_CNT_CSM_EmbedVideo {
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserPermissionsKnowledgeUser = true, employeeNumber= '080808081');
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
        insert accOwner;
        System.runAs (accOwner) {
            Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName');
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge.Id];
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
                );
            insert contentVersion;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = knowledge.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
        }
    }

    @IsTest
    static void testCNT_CSM_EmbedVideo() {
        List<Knowledge__kav> k = [Select Id, KnowledgeArticleId from Knowledge__kav];
        List<ContentDocumentLink> d = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: k[0].Id];
        Test.startTest();
        CNT_CSM_EmbedVideo.getVideos(k[0].id);
        CNT_CSM_EmbedVideo.updateContentDocumentLinkVisibility(d[0].ContentDocumentId, k[0].Id);
        Test.stopTest();
    }
}
