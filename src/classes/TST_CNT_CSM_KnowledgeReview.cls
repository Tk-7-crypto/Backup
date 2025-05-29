@isTest
private class TST_CNT_CSM_KnowledgeReview {
    
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'sub',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber='070707078', Email = 'john122@iqvia.com',IsActive =true,Username ='john122@iqvia.com', LastName= 'test12LastName', CommunityNickname ='test12SuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserPermissionsKnowledgeUser = true);
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
        insert accOwner;
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
            Community_topic__c ct = new Community_topic__c(Name='topicName');
            insert ct;
            Product2 product = UTL_TestData.createProduct();
            product.Community_topic__c = ct.Id;
            product.SpecificToCSM__c = True;
            insert product;
            Asset asset = new Asset(Name='TestAsset', AccountId = account.Id, Product2Id = product.id);
            insert asset;
            Contact contact = UTL_TestData.createContact(account.Id);
            insert contact;
            Knowledge__kav knowledge = new Knowledge__kav(Title = 'TestTitle12', language = 'en_US',UrlName='TestUrlName12', IsVisibleInCsp= true, Product__c= product.Id, ProductName__c='TestProduct', Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            Knowledge_Account_RelationShip__c kar = new Knowledge_Account_RelationShip__c(Knowledge__c = knowledge.Id, Account__c = account.Id);
            insert kar;
            Knowledge__kav knowledge2 = new Knowledge__kav(Title = 'TestTitle22', language = 'en_US',UrlName='TestUrlName22', IsVisibleInCsp= true, Product__c= product.Id, ProductName__c='TestProduct', Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert knowledge2;
            Knowledge__kav k2 = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge2.Id];
            KbManagement.PublishingService.publishArticle(k2.KnowledgeArticleId, true);
            CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='Please Specify', SubType2__c='Please Specify', Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert categorization;
        }
    }
    
    @IsTest
    static void tstGetAllKnowledgeReviewList(){
        List<Knowledge__kav> kList = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav limit 5];
        for(Knowledge__kav k : kList){
            CNT_CSM_KnowledgeReview.insertKnowledgeReview(k.Id,Date.today(),'test'+k.Id);
        }
        
    }

}