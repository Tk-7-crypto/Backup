@isTest
private class TST_BCH_CSM_SendEmailRnDKBAccountMgmt {
    @isTest
    private static void testRnDAccountMgmtSendEmail(){
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Pillar__c='R&D' , ProductName__c ='Account Management', IsVisibleInPrm=false, Partner_Type__c = '');
        insert knowledge;
        Knowledge__kav knowRecord  = [select KnowledgeArticleId from Knowledge__kav];
        String articleId = knowRecord.KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c();
        queues1.Name ='RnD - Account Management';
        queues1.QueueName__c ='Q1';
        queues1.Type__c ='Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c();
        queueUser1.Name ='RnD - Account Management';
        queueUser1.QueueName__c ='Q1';
        queueUser1.Type__c ='User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        Test.startTest();
        BCH_CSM_SendEmailRnDKBAccountMgmt obj = new BCH_CSM_SendEmailRnDKBAccountMgmt();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }
    

}