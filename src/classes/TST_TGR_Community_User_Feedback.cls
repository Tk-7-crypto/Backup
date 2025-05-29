@isTest
private with sharing class TST_TGR_Community_User_Feedback {
    @IsTest
    static void testInsertRecords(){
        
        List<User> userList = UTL_TestData.createUser('Sales User', 1);
        userList[0].LastName = 'Abdulaev';
        userList[0].Email = 'chirag.chanana@metacube.com';  
        userList[0].EmployeeNumber = '12334';
        try{
            insert userList;
        }
        catch(Exception E)
        {
            system.debug('debug ' +e.getMessage());
        }
        //system.runAs(userList[0]){
        Knowledge__kav knowObj = new Knowledge__kav();
        knowObj.Title ='test';
        // knowObj.PublishStatus = 'Draft';
        knowObj.UrlName = 'Test1TABC';
        insert knowObj;
        system.debug(knowObj);
        
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId,ArticleNumber FROM knowledge__kav WHERE id =: knowObj.Id];
        KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, false);
        system.debug(obj1);
        Community_User_Feedback__c ComUserFeedObj = new Community_User_Feedback__c();
        ComUserFeedObj.ArticleNumber__c = Obj1.ArticleNumber; 
        insert ComUserFeedObj; 
        system.debug(ComUserFeedObj);
        
        
        //}
    }


}
