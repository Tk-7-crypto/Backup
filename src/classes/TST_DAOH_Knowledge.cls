@istest
public class TST_DAOH_Knowledge {
    @testSetup
    static void dataSetup() {
        Knowledge__kav knowledgeRecord = new Knowledge__kav();
        knowledgeRecord.Title = 'Test1:CSM_Knowledge_PublishedArticle_AND_ReviewDate';
        knowledgeRecord.RecordTypeId ='0126A000000hC38QAE';
        knowledgeRecord.UrlName ='Test1PublishedArticle';
        knowledgeRecord.Pillar__c ='Information Offering';
        knowledgeRecord.ReviewDate__c = System.today();
        insert knowledgeRecord;
        Knowledge__kav knowRecord  = [select KnowledgeArticleId from Knowledge__kav];
        String articleId = knowRecord.KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle:CSM_Knowledge_PublishedArticle_AND_ReviewDate', language = 'en_US',UrlName='TestUrlNameReviewDate', IsVisibleInCsp= true, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,IsVisibleInPrm=false, Partner_Type__c = '');
        insert knowledge;
    }
    @isTest
    static void addAccountKnowledgeRecordTest(){
       Knowledge__kav kv = [Select id,KnowledgeArticleId, PublishStatus, ArticleNumber from Knowledge__kav WHERE Title = 'Test1:CSM_Knowledge_PublishedArticle_AND_ReviewDate'];
       String articleId = kv.KnowledgeArticleId;
       KbManagement.PublishingService.editOnlineArticle(articleId, true);
       Account acc = CSM_TestDataFactory.createAccount();
       insert acc;
       Knowledge__kav kvNew = [Select id,KnowledgeArticleId, PublishStatus, ArticleNumber from Knowledge__kav order by createddate desc limit 1];
       KbManagement.PublishingService.publishArticle(kvNew.KnowledgeArticleId, true);
       Knowledge_Account_RelationShip__c kar = new Knowledge_Account_RelationShip__c(Knowledge__c = kvNew.Id, Account__c = acc.Id);
       insert kar;
       Knowledge_Account_RelationShip__c kar2 = new Knowledge_Account_RelationShip__c(Knowledge__c = kv.Id, Account__c = acc.Id);
       insert kar2;
       Knowledge__kav knowledgeRecord2 = new Knowledge__kav();
       knowledgeRecord2.Title = 'Test1:CSM_Knowledge_PublishedArticle_AND_ReviewDate';
       knowledgeRecord2.RecordTypeId ='0126A000000hC38QAE';
       knowledgeRecord2.UrlName ='Test1PublishedArticle2';
       knowledgeRecord2.Pillar__c ='Information Offering';
       knowledgeRecord2.ReviewDate__c = System.today();
       insert knowledgeRecord2;
       try{
           Knowledge__kav kvNew2 = [Select id,KnowledgeArticleId, PublishStatus, ArticleNumber from Knowledge__kav order by createddate desc limit 1];
           KbManagement.PublishingService.publishArticle(kvNew2.KnowledgeArticleId, true);
           Knowledge_Account_RelationShip__c kar3 = new Knowledge_Account_RelationShip__c(Knowledge__c = kvNew2.Id, Account__c = acc.Id);
           insert kar3;
           DAOH_Knowledge.addAccountKnowledgeRecord(new List<Knowledge__kav>{kvNew, kv, kvNew2});
        }catch(Exception e){           
      }       
    }
    
    @isTest
    static void testUpdateVisibleToPartner(){
       Knowledge__kav kv = [Select id,KnowledgeArticleId from Knowledge__kav WHERE Title = 'TestTitle:CSM_Knowledge_PublishedArticle_AND_ReviewDate'];
       kv.IsVisibleInCsp = true;
       update kv;
    }

    @isTest
    static void testEmailForArchived(){
        knowledge__kav kv = [Select Id, IsDeleted, PublishStatus, KnowledgeArticleId FROM Knowledge__kav WHERE Title = 'TestTitle:CSM_Knowledge_PublishedArticle_AND_ReviewDate'];
        String articleId = kv.KnowledgeArticleId;
        Datetime scheduledDate = null;
        KbManagement.PublishingService.publishArticle(articleId, true);
        KbManagement.PublishingService.archiveOnlineArticle(articleId, scheduledDate);
    }

}