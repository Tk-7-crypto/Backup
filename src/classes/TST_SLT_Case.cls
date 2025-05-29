/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Case
 */
@isTest
private class  TST_SLT_Case {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber='07070707', Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', UserPermissionsKnowledgeUser = true);
        insert accOwner;
        System.runAs (accOwner) {
            Account acc = CSM_Util.createAccount();
            acc.Website='http://www.iqvia.com';
            insert acc;
            Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
            cnt.PreferredLanguage__c = 'en_US';
            insert cnt;
        
            /*Audit trail Log Added Start */
            Account acct2 = CSM_Util.createRDAccount();
            acct2.Website='http://www.iqvia.com';
            insert acct2;
        
        
            /*Audit trail Log Added End */
            
            Account account = UTL_TestData.createAccount();
            account.Website='http://www.iqvia.com';
            insert account;
            Contact contact = UTL_TestData.createContact(account.Id);
            contact.PreferredLanguage__c = 'en_US';
            insert contact;
            Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
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
            insert c;
        }
        
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topics__c='OneKey';
            product.SpecificToCSM__c = True;
            insert product;
            Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,Partner_Type__c='Integrator Partner',IsVisibleInPrm = true, PRM_Sales_Collateral__c = true);
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            
            
            Id prmProfileId = [select id from profile where name =: CON_PEP.S_P_PEP_COMMUNITY ].id;
            Account ac = new Account(name ='Acme',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE') ;
            ac.AccountCountry__c = 'BM' ;
            insert ac;
            
            Contact con = new Contact(FirstName = 'TestFirstName1', LastName ='testCon',AccountId = ac.Id,Email='partneruser@iqvia.partner.com');
            con.Partner_Type__c = 'Integrator Partner';
            con.Portal_Case_Type__c = 'Technology Solutions';
            insert con;
            
            User partnerUser = new User(alias = 'test123', email='partneruser@iqvia.partner.com',
                                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                        localesidkey='en_US', profileid = prmProfileId, country='United States',IsActive =true,
                                        ContactId = con.Id,PortalRole='Manager',
                                        timezonesidkey='America/Los_Angeles', username='xyz123490@iqviaTestPartner.com');
            insert partnerUser;
        }
    }
    
     /**
     * This method used to get Case by ID
     */    
    @IsTest
    static void testSelectById() {
        List<Case> cases = new  List<Case>();
        Case c = [SELECT id FROM Case WHERE Subject = 'TestCase'];
        Test.startTest();
        cases = new SLT_Case().selectById(new Set<Id> {c.Id});
        new SLT_Case().selectByCaseId(new Set<Id> {c.Id}, new Set<String> {'Id','CaseNumber'});
        cases = new SLT_Case().selectByCaseIdList(new Set<Id> {c.Id}, new Set<String> {'Id','CaseNumber'});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = cases.size();
        System.assertEquals(expected, actual);
    }
    
    /**
    * This test method used for insert and update Case record
    */ 
    static testMethod void testAuditforCase() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseTestAccount' LIMIT 1];
        Account acct2= [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt2;
        Study__c study = CSM_Util.createStudy(acct2.Id);
        study.Name ='STUDY1';
        study.StudyID__c ='PROJ001';
        study.LabProjectCode__c ='LABPROJ001';
        insert study;
        Study__c study2 = CSM_Util.createStudy(acct2.Id);
        insert study2;
        Product2 product = CSM_Util.createProduct2();
        product.Name = 'SLTCaseProd';
        insert product;
        Asset aset = CSM_Util.createAsset('SLTCaseProd',product.Id,acc.Id,cnt.Id,study.Id);
        insert aset;
        ServiceNow_Group__c service=new ServiceNow_Group__c();
        service.Group_ID__c='GRP123';
        service.Name = 'Service GRP123';
        insert service;
        
        BusinessHours bHours = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acc.Id,Type = 'R_D',
                                          BusinessHoursId = bHours.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        
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
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='Q2';
        queues2.QueueName__c ='Q2';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='Q2';
        queueUser2.QueueName__c ='Q2';
        queueUser2.Type__c ='User';
        queueUser2.User__c = UserInfo.getUserId();
        insert queueUser2;
        
        Id RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        StudySiteContactRelationship__c siteConR=new StudySiteContactRelationship__c(Study__c = study.Id,Investigator_Name__c = cnt.Id,Site_Name__c = acc.Id);
        siteConR.SiteNumber__c = 'SITE01';
        siteConR.Lab_Site_Number__c = 'LABSITE01';
        insert siteConR;
        
        List<Case> csList=new List<Case>();
        Case cse =null,cseParent=null;
        
        cse = new Case(
            AccountId = acc.Id,
            ContactId = cnt.Id,
            Study__c =study.Id,
            Sponsor__c = acct2.Id,
            Site_Related_to_the_Study__c = siteConR.Id,
            ServiceNow_Group__c=service.Id,
            CurrentQueue__c=queues.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeId
        );
               
        
        
        SLT_Case slt=new SLT_Case();
        List<String> currentParent = new List<String>{String.valueOf(cse.Id)};
        Test.startTest();
        insert cse;
        slt.getCaseById(new Set<Id>{cse.Id}, new Set<String>{'Id','CaseNumber'});
        slt.selectByCaseQueueList('Q1', new Set<String>{'Id','CaseNumber'});
        slt.selectByEmailMessage(new Set<Id>{cse.Id});
        slt.selectByContactId(new Set<Id>{cse.Id});
        slt.selectByStatusAndParentId(new Set<Id>{cse.Id});
        slt.selectByParentId(new Set<Id>{cse.Id});
        slt.getCaseListForActivity(new Set<Id>{cse.Id});
        slt.selectByCaseId(new Set<Id>{cse.Id}, new Set<String>{'Id','CaseNumber'});
        slt.selectByCaseIdList(new Set<Id>{cse.Id}, new Set<String>{'Id','CaseNumber'});
        slt.selectByStudyStudySiteContactIdList(new Set<Id>{cse.Id}, new Set<String>{CON_CSM.S_ID,CON_CSM.S_CASENUM,CON_CSM.CS_SITENUM_C,CON_CSM.CS_LABSITENUM_C,CON_CSM.S_STUDY_SITE_RELATED_TO_STUDY_C});
        slt.selectByStudyIdList(new Set<Id>{cse.Id}, new Set<String>{CON_CSM.S_ID,CON_CSM.CS_STUDYPROTOCOLNAME_C,CON_CSM.CS_LABPROJECTCODE_C,CON_CSM.CS_PROJECTCODE_C,CON_CSM.S_STUDYC});
        slt.getCaseListHierarchy('Id', currentParent, null);
        slt.getCaseListHierarchy('ParentId', currentParent, null);
        slt.getCaseListHierarchy('Id', currentParent, new List<String>{'Customer'});
        slt.getCaseListHierarchy('ParentId', currentParent, new List<String>{'Customer'});
        slt.getParentCaseHierarchy(String.valueOf(cse.Id));
        slt.getParentChildCase(new Set<Id>{cse.Id},new Set<Id>{cse.Id});
        Test.stopTest();
    }
	
    @IsTest
    static void testGetCaseByCaseNumber() {
        case newCase = [SELECT Id, caseNumber FROM Case limit 1];
        SLT_Case slt=new SLT_Case();
        
        Test.startTest();
            List<Case> result = slt.getCaseByCaseNumber(newCase.caseNumber);
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(),'case is not fetched by case number');
        System.assertEquals(1, result.size(), 'Case is not fetched by case number');
    }
    
    @IsTest
    static void testGetCaseByCaseNumberShouldNotReturnResult() {
        SLT_Case slt=new SLT_Case();
        
        Test.startTest();
            List<Case> result = slt.getCaseByCaseNumber('tesststs');
        Test.stopTest();
        
        System.assertEquals(true, result.isEmpty(),'case is not fetched by case number');
    }
    
    @IsTest
    static void testGetCaseByCaseNumberAndStatus() {
        case newCase = [SELECT Id, caseNumber,status FROM Case limit 1];
        SLT_Case slt=new SLT_Case();
        
        Test.startTest();
        List<Case> result = slt.getCaseByIdAndStatus(new List<Id>{newCase.Id}, newCase.status);
        Test.stopTest();
        
        System.assertEquals(true, result.isEmpty(),'case is not fetched by case number');
    }
	
    @IsTest
    static void testSelectByCaseByContact() {
        Id contactId= [Select Id from contact where lastName = 'TestContact' limit 1].Id;
        SLT_Case slt=new SLT_Case();
        
        Test.startTest();
        List<Case> result = slt.selectByCaseByContact(new Set<String>{contactId}, new Set<String>{'Id'});
        Test.stopTest();
        
        System.assertEquals(true, result.isEmpty(),'case is fetched by contact');
    }

    @IsTest
    static void testGetSearchResults() {
        User partnerUser = [SELECT Id FROM User WHERE email='partneruser@iqvia.partner.com'];
        Contact con = [SELECT Id, Portal_Case_Type__c, Partner_Type__c FROM Contact Where FirstName = 'TestFirstName1'];
        String partnerType = con.Partner_Type__c;
        partnerType = partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String searchText='TestCase';
        Set<String> pillar = new Set<String>(con.Portal_Case_Type__c.split(';'));
        Set<String> ids = new Set<String>();
        System.runAs(partnerUser){
        Test.startTest();
        List<List<SObject>> results = new SLT_Case().getSearchResults(searchText, pillar, '',ids, partnerType,10,0);
        Test.stopTest();
        }
    }
}