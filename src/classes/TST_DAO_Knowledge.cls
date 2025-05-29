@istest
public class TST_DAO_Knowledge {
    @testSetup
    static void dataSetup() {
        Knowledge__kav knowledgeRecord = new Knowledge__kav();
        knowledgeRecord.Title = 'Test1DAOKnow';
        knowledgeRecord.RecordTypeId ='0126A000000hC38QAE';
        knowledgeRecord.UrlName ='Test1DAOKnow';
        knowledgeRecord.Pillar__c ='Information Offering';
        insert knowledgeRecord;
        Knowledge__kav knowRecord  = [select KnowledgeArticleId from Knowledge__kav];
        String articleId = knowRecord.KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);
        Knowledge_Account_RelationShip__c knowledegeAccount = new Knowledge_Account_RelationShip__c();
        knowledegeAccount.Knowledge__c = knowledgeRecord.id;
        insert knowledegeAccount;
    }
    @isTest
    static void addAccountKnowledgeRecordTest(){
       Knowledge__kav kv = [Select id,KnowledgeArticleId from Knowledge__kav];
       String articleId = kv.KnowledgeArticleId;
       KbManagement.PublishingService.editOnlineArticle(articleId, false);
       
    }

}