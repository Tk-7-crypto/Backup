/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_CaseCategorization
 */
@isTest
private class TST_CNT_CSM_CaseCategorization {
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Product2 product = UTL_TestData.createProduct();
        product.SpecificToCSM__c = true;
        product.Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS;
        insert product;
        Account account = UTL_TestData.createAccount();
        insert account;
        Asset asset = new Asset(Name = 'TestAsset', AccountId = account.Id, Product2Id = product.id);
        insert asset;
        Contact contact = UTL_TestData.createContact(account.Id);
        contact.Contact_User_Type__c = 'HO User';
        insert contact;

        Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
       
        CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='TestSubtype1', SubType2__c='TestSubtype2 1',SubType3__c='TestSubtype3 1',RecordTypeId__c=recordType,Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS, Type__c = 'Categorization', Milestone_Type__c='Milestone type 1');
        insert categorization;
        categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='TestSubtype1', SubType2__c='TestSubtype2 2',SubType3__c='TestSubtype3 2',RecordTypeId__c=recordType,Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS, Type__c = 'Categorization', Milestone_Type__c='Milestone type 2');
        insert categorization;
        
        categorization = new CSM_QI_Case_Categorization__c(Los__c ='Los' ,SubType1__c='TestSubtype1', SubType2__c='TestSubtype22',SubType3__c='TestSubtype33',RecordTypeId__c='0126A000000hC34QAE',Pillar__c = CON_CSM.S_R_D, Type__c = 'Categorization');
        insert categorization;

        categorization = new CSM_QI_Case_Categorization__c(Los__c ='Los' ,Activitties__c='Activity1',RnD_Template__c='Template1' ,Pillar__c = CON_CSM.S_R_D, Type__c = 'Activity', Active__c = true);
        insert categorization;

        categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, Affects_Version__c='Version_Test',Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,Type__c = 'Affects Version', Active__c = true);
        insert categorization;

        categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,Article_Chapter__c='TestChapter',Article_Chapter_Order__c=1, Type__c = 'Knowledge', Active__c = true);
        insert categorization;

        Id createRecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('DATA CREATE Service').getRecordTypeId();
        categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c = 'TestSubtype1', SubType2__c = 'TestSubtype2 2', SubType3__c = 'TestSubtype3 2', RecordTypeId__c = createRecordTypeId, Pillar__c = CON_CSM.S_INFORMATION_OFFERING, Type__c = 'Categorization', CaseType__c= 'caseType', Active__c = true);
        insert categorization;

        CSM_QI_CREATE_Media_Date__c mediaDate = new CSM_QI_CREATE_Media_Date__c(
            ProductName__c = 'TestProduct',
            SubType2__c = 'TestSubtype2 1',
            Media_Date_Label__c = 'mdl1',
            Media_Date__c = Date.newInstance(2050, 12, 31),
            Download_Date__c = Date.newInstance(2050, 12, 31),
            Maint_Due_Date__c = Date.newInstance(2050, 12, 31)
        );
        insert mediaDate;

        
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId();
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        Case c = New Case(Subject = 'TestCase',RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,InitialQueue__c = 'Q1');
        c.Case_Type__c = 'Problem';
        c.Number_of_Article__c = 0;
        insert c;
        Knowledge__kav knowledge2 = New Knowledge__kav(Title = 'TestTitle2', language = 'en_US',UrlName='TestUrlName2',Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS, Product__c = product.Id, ProductName__c='TestProduct', Article_Chapter__c='TestChapter');
        insert knowledge2;
        knowledge2 = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :knowledge2.Id];
        KbManagement.PublishingService.publishArticle(knowledge2.KnowledgeArticleId, true);
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName',Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS, Product__c = product.Id);
        insert knowledge;
        knowledge = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :knowledge.Id];
        CaseArticle caseArticle = new CaseArticle(CaseId = c.Id, KnowledgeArticleId=knowledge.KnowledgeArticleId);
        insert caseArticle;
        CNT_CSM_CaseCategorization.getTimeSheetRecord(c.Id);

    }
    
     /**
     * This method used to get Case by recordId
     */    
    @IsTest
    static void testGetCaseRecord() {
        List<SObject> objects = new List<SObject>();  
        String objName ='Case';
        Case c = [SELECT id FROM Case WHERE Subject='TestCase'];
        String caseId = c.Id;
        Test.startTest();
        objects = CNT_CSM_CaseCategorization.getRecord(objName,caseId);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = objects.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get List<CaseArticle> by caseId
     */    
    @IsTest
    static void testGetCaseArticles() {
        List<CaseArticle> caseArticles = new List<CaseArticle>();  
        String objName ='Case';
        Case c = [SELECT id FROM Case WHERE Subject='TestCase'];
        String caseId = c.Id;
        Test.startTest();
        caseArticles = CNT_CSM_CaseCategorization.getCaseArticles(caseId);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = caseArticles.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get Knowledge by recordId
     */    
    @IsTest
    static void testGetKnowledgeRecord() {
        List<SObject> objects = new List<SObject>();  
        String objName ='Knowledge__kav';
        Knowledge__kav knowledge = [SELECT id FROM Knowledge__kav WHERE Title = 'TestTitle' and PublishStatus='Draft' and language='en_US'];
        Test.startTest();
        objects = CNT_CSM_CaseCategorization.getRecord(objName,knowledge.Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = objects.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get List<AggregateResult> of  Product__r.Name Categorization by given CaseId
     */    
    @IsTest
    static void testGetProductCategorizationForCase() {
        List<AggregateResult> products = new  List<AggregateResult>();
        Case c = [SELECT id FROM Case WHERE Subject='TestCase'];
        Test.startTest();
        products = CNT_CSM_CaseCategorization.getProductCategorizationForCase(c.Id, CON_CSM.S_TECHNOLOGY_SOLUTIONS);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = products.size();
        //System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get List<AggregateResult> of  Product__r.Name
     */    
    @IsTest
    static void testGetProductCategorization1() {
        List<AggregateResult> products = new  List<AggregateResult>();
        Test.startTest();
        products = CNT_CSM_CaseCategorization.getProductCategorization(CON_CSM.S_TECHNOLOGY_SOLUTIONS);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = products.size();
        System.assertEquals(expected, actual);
    }

        @IsTest
    static void testGetProductCategorization2() {
        List<AggregateResult> products = new  List<AggregateResult>();
        Test.startTest();
        products = CNT_CSM_CaseCategorization.getProductCategorization(CON_CSM.S_INFORMATION_OFFERING);
        Test.stopTest();
    }

    /**
     * This method used to get List<Product2> by given CaseId
     */    
    @IsTest
    static void testGetProductsCategorizationForData() {
        List<Product2> products = new  List<Product2>();
        Case c = [SELECT id FROM Case WHERE Subject='TestCase'];
        Test.startTest();
        products = CNT_CSM_CaseCategorization.getProductsCategorizationForData(c.Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = products.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get List<AggregateResult>
     */    
    @IsTest
    static void testGetQuery() {
        List<AggregateResult> cases = new  List<AggregateResult>();
        Test.startTest();
        cases = CNT_CSM_CaseCategorization.getCategorizationWithAggregate('select Subject from Case group by Subject');
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateObjectCategorization() {
        Test.startTest();
        CSM_QI_CREATE_Media_Date__c mediaDate = null;
        Product2 p = [Select Id, Name from Product2 LIMIT 1];
        case c = [select Id,AccountId,ContactId,Case_CategorizationId__c,ProductName__c,SubType1__c,SubType2__c,SubType3__c,Case_Type__c,Number_of_Article__c,TaskMilestone__c from Case LIMIT 1];
        CNT_CSM_CaseCategorization.updateObjectCategorization(c, p.Name,'TestSubtype1','TestSubtype2 1','TestSubtype3 1','',CON_CSM.S_TECHNOLOGY_SOLUTIONS,'Artical','Version_Test', mediaDate, null ,null, '');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateObjectCategorization2() {
        Test.startTest();
        CSM_QI_CREATE_Media_Date__c mediaDate = null;
        Product2 p = [Select Id, Name from Product2 LIMIT 1];
        case c = [select Id,AccountId,ContactId,Case_CategorizationId__c,ProductName__c,SubType1__c,SubType2__c,SubType3__c,Case_Type__c,Number_of_Article__c,TaskMilestone__c from Case LIMIT 1];
        c.Number_of_Article__c = 1;
        update c;
        CNT_CSM_CaseCategorization.updateObjectCategorization(c, p.Name,'TestSubtype1','TestSubtype2 1','TestSubtype3 1','',CON_CSM.S_TECHNOLOGY_SOLUTIONS,'Artical','Version_Test', mediaDate, null ,null, '');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateObjectCategorization3() {
        Test.startTest();
        CSM_QI_CREATE_Media_Date__c mediaDate = null;
        Product2 p = [Select Id, Name from Product2 LIMIT 1];
        case c = [select Id,AccountId,ContactId,Case_CategorizationId__c,ProductName__c,SubType1__c,SubType2__c,SubType3__c,Case_Type__c,Number_of_Article__c, RecordTypeName__c from Case LIMIT 1];
        c.Number_of_Article__c = 1;
        update c;
        CNT_CSM_CaseCategorization.updateObjectCategorization(c, p.Name,'TestSubtype1','TestSubtype2 1','TestSubtype3 1','',CON_CSM.S_INFORMATION_OFFERING,'Artical','Version_Test', mediaDate, null ,null, '');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateCase() {
        Test.startTest();
        case c = [select Id,AccountId,ContactId,Case_CategorizationId__c,ProductName__c,SubType1__c,SubType2__c,SubType3__c,Case_Type__c,Number_of_Article__c from Case LIMIT 1];
        c.Number_of_Article__c = 1;
        CNT_CSM_CaseCategorization.updateCase(c);
        Test.stopTest();
    }
    
    /**
     * This method used to get cases
     */    
    @IsTest
    static void testGetQueryCasesRD() {
        Test.startTest();
        CSM_QI_CREATE_Media_Date__c mediaDate = null;
        Product2 p = [Select Id, Name from Product2 LIMIT 1];
        case cases = [select Id,AccountId,ContactId,Case_CategorizationId__c,ProductName__c,SubType1__c,SubType2__c,SubType3__c,Case_Type__c,RecordTypeId from Case LIMIT 1];
        Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        CNT_CSM_CaseCategorization.updateObjectCategorization(cases, 'Los','TestSubtype1','TestSubtype22','TestSubtype33','Los', CON_CSM.S_R_D,'Artical','Version_Test', mediaDate, null, null, '');
        Test.stopTest();
        
    }
    
    @IsTest
    static void testGetQueryKnowledge() {
        Test.startTest();
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle123', language = 'en_US',UrlName='TestUrlName123', Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS);
        insert knowledge;
        CSM_QI_CREATE_Media_Date__c mediaDate = null;
        Product2 p = [Select Id, Name from Product2 LIMIT 1];
        Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        CNT_CSM_CaseCategorization.updateObjectCategorization(knowledge, p.Name,'TestSubtype1','TestSubtype2 1','TestSubtype3 1','', '','','Version_Test', mediaDate, null, null, '');
        Test.stopTest();
        
    }
    
    @IsTest
    static void testGetQueryControlField() {
        Test.startTest();
        CNT_CSM_CaseCategorization.getDependentOptionsImpl('Case' , 'Status' , 'SubStatus__c');
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetAutomationRecord(){
        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        Product2 proRecord = [Select Id, Name from Product2 LIMIT 1];
        UserRole portalRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSM' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = New User(Alias = 'su', UserRoleId = portalRole.Id, ProfileId = adminProfile.Id, Email = 'adminUser@iqvia.com', IsActive =true , Username ='adminUser@iqvia.com.csm', 
                              LastName= 'testLastName', EmployeeNumber='4345701', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                              LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert adminUser;
        System.runAs(adminUser){
            Queue_User_Relationship__c queue = new Queue_User_Relationship__c();
            queue.Name ='Tech Queue';
            queue.QueueName__c ='Tech Queue';
            queue.Type__c ='Queue';
            insert queue;
            Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c();
            queueUser1.Name ='Tech Queue';
            queueUser1.QueueName__c ='Tech Queue';
            queueUser1.Type__c ='User';
            queueUser1.User__c = UserInfo.getUserId();
            insert queueUser1;
            Queue_User_Relationship__c queueUser2 = new Queue_User_Relationship__c();
            queueUser2.Name ='Tech Queue';
            queueUser2.QueueName__c ='Tech Queue';
            queueUser2.Type__c ='User';
            queueUser2.User__c = adminUser.Id;
            insert queueUser2;
            
            CSM_QI_CaseAutomationScheduler__c caseAutoRecord = new CSM_QI_CaseAutomationScheduler__c();
            caseAutoRecord.Account_Name__c = accRecord.Id;
            caseAutoRecord.Frequency__c = 'Daily';
            caseAutoRecord.Subject__c = 'Test subject';
            caseAutoRecord.Description__c = 'Test description';
            caseAutoRecord.Primary_Owner__c = UserInfo.getUserId();
            caseAutoRecord.Secondary_Owner__c = adminUser.Id;
            caseAutoRecord.Start_Date__c = Date.today();
            insert caseAutoRecord;
            CSM_QI_CREATE_Media_Date__c mediaDate = null;
            Test.startTest();
            CNT_CSM_CaseCategorization.getRecord('CSM_QI_CaseAutomationScheduler__c', caseAutoRecord.Id);
            CNT_CSM_CaseCategorization.updateObjectCategorization(caseAutoRecord, proRecord.Name, 'TestSubtype1', 'TestSubtype2 1', 'TestSubtype3 1','', CON_CSM.S_TECHNOLOGY_SOLUTIONS, 'Article','Version_Test', mediaDate, null, null, '');
            CNT_CSM_CaseCategorization.getProductCategorizationForAutomation(caseAutoRecord.Id, CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            CNT_CSM_CaseCategorization.getProductCategorizationForAutomation(caseAutoRecord.Id, CON_CSM.S_INFORMATION_OFFERING);
            Test.stopTest();
        }
    }

    @IsTest
    static void testGetAffectsVersion() {
        Test.startTest();
        CNT_CSM_CaseCategorization.getAffectsVersion('TestProduct');
        Test.stopTest();
    }

    @IsTest
    static void testGetTemplate() {
        Test.startTest();
        CNT_CSM_CaseCategorization.getTemplate('Los');
        Test.stopTest();
    }

    @IsTest
    static void testGetMediaDates() {
        Test.startTest();
        CNT_CSM_CaseCategorization.getMediaDates('TestProduct','TestSubtype1','TestSubtype2 1');
        Test.stopTest();
        
    }
    
    @IsTest
    static void testGetKnowledgeArticleChapterList() {
        Test.startTest();
        CNT_CSM_CaseCategorization.getKnowledgeArticleChapterList('TestProduct');
        Test.stopTest();
    }

    @IsTest
    static void testGetPicklistValues() {
        Test.startTest();
        CNT_CSM_CaseCategorization.getPicklistValues('Case', 'Reason_for_Late_Request_Re_Run__c');
        Test.stopTest();
    }

    @IsTest
    static void testArticleWrappers() {
        List<CNT_CSM_CaseCategorization.KnowledgeArticleWrapper> articleWrappers = new List<CNT_CSM_CaseCategorization.KnowledgeArticleWrapper>();
        Test.startTest();
        articleWrappers.add(new CNT_CSM_CaseCategorization.KnowledgeArticleWrapper());
        Test.stopTest();
    }

    @IsTest
    static void testGetArticleChapters() {
        Test.startTest();
        CNT_CSM_CaseCategorization.getArticleChapters();
        Test.stopTest();
        
    }

    @IsTest
    static void testGetAvailableProductsForAddArticleChapters() {
        Test.startTest();
        CNT_CSM_CaseCategorization.getAvailableProductsForAddArticleChapters(CON_CSM.S_TECHNOLOGY_SOLUTIONS);
        Test.stopTest();
        
    }

    @IsTest
    static void testGetKnowledgeArticles() {
        Test.startTest();
        CNT_CSM_CaseCategorization.getKnowledgeArticles('TestChapter','TestProduct',CON_CSM.S_TECHNOLOGY_SOLUTIONS);
        Test.stopTest();
        
    }

    @IsTest
    static void testGetReasonLateList() {
        Test.startTest();
        CNT_CSM_CaseCategorization.getReasonLateList();
        Test.stopTest();
    }
    
    @IsTest
    static void testSaveArticleOrder() {
        List<CNT_CSM_CaseCategorization.KnowledgeArticleWrapper> articleWrappers = new List<CNT_CSM_CaseCategorization.KnowledgeArticleWrapper>();
        Knowledge__kav article = [SELECT Id, ArticleNumber FROM Knowledge__kav WHERE Title = 'TestTitle2'];
        articleWrappers.add(new CNT_CSM_CaseCategorization.KnowledgeArticleWrapper(article, 1));

        Test.startTest();
        CNT_CSM_CaseCategorization.saveArticleOrder(articleWrappers);
        Test.stopTest();
        
    }

    @IsTest
    static void testGetCategorizationOptions() {
        List<Asset> assets = [SELECT Id, Product2Id FROM Asset WHERE Account.Name = 'TestAccount'];
        List<String> assetProductIds = new List<String>();
        for (Asset asset : assets) {
            if (asset.Product2Id != null) {
                assetProductIds.add(asset.Product2Id);
            }
        }
        Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('DATA CREATE Service').getRecordTypeId();
        Test.startTest();
        CNT_CSM_CaseCategorization.getCategorizationOptions(assetProductIds, recordTypeId, 'caseType');
        Test.stopTest();
        
    }

    @IsTest
    static void testGetAssetsForAccount() {
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' Limit 1];
        Test.startTest();
        CNT_CSM_CaseCategorization.getAssetsForAccount(a.Id);
        Test.stopTest();
        
    }
    
}
