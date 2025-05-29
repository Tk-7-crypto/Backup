@isTest
private class TST_SLT_ContentDocument {

    @testSetup
    static void dataSetup(){
        Profile profileRecord = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        UserRole userRoleRecord = [Select Id From UserRole Where DeveloperName = 'CSM' Limit 1];
        User serviceUser = New User(Alias='s12ru', UserRoleId=userRoleRecord.Id, ProfileId=profileRecord.Id, Email='dummyTSLTCDuser@iqvia.com', 
                                    IsActive=true, Username='dummyTSLTCDuser@iqvia.com.dev', LastName='testTSLTCDLastName', CommunityNickname='testTSLTCDSUNickname',EmployeeNumber = '0707045756', 
                                    TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US',
                                    Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert serviceUser;
        
        PermissionSet permissionRecord = [SELECT Id FROM PermissionSet WHERE Name = 'Advanced_Administrator'];
        PermissionSetAssignment assignmentRecord = new PermissionSetAssignment();
        assignmentRecord.PermissionSetId = permissionRecord.Id;
        assignmentRecord.AssigneeId = serviceUser.Id;
        insert assignmentRecord;
        
        System.runAs(serviceUser){
            Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
            Account accountRecord = new Account();
            accountRecord.RecordTypeId = mdmValidAccount;
            accountRecord.AccountCountry__c = 'US';
            accountRecord.Name = 'Techno Portal';
            accountRecord.RDCategorization__c = 'Sponsor';
            accountRecord.Website = 'https://www.test.com';
            accountRecord.CustomerSegment__c = 'GOVERNMENT';
            accountRecord.Sub_Industry__c = 'STATE';
            insert accountRecord;
            
            Contact contactRecord = new Contact();
            contactRecord.AccountId = accountRecord.Id;
            contactRecord.FirstName = 'Saurabh';
            contactRecord.LastName = 'Sharma';
            contactRecord.Salutation = 'Eng';
            contactRecord.Email = 'noreply@dummy.com';
            insert contactRecord;
            
            CSM_Case_Details_Global_Setting__c caseSettingRecord = new CSM_Case_Details_Global_Setting__c();
            caseSettingRecord.Name = 'ET TECH EN Case New Attachment';
            caseSettingRecord.Setting_Type__c = 'Email Template';
            caseSettingRecord.Country__c = 'Attachment Default';
            caseSettingRecord.Component_Id__c = '00X2g000000LwMN';
            caseSettingRecord.Other_Details__c = 'New';
            caseSettingRecord.RecordTypeId__c = '0126A000000hC35QAE';
            caseSettingRecord.Origin__c = 'Customer Portal';
            insert caseSettingRecord;
            
            CSM_Case_Details_Global_Setting__c orgWideSettingRecord = new CSM_Case_Details_Global_Setting__c();
            orgWideSettingRecord.Name = 'Org Wide No-Reply';
            orgWideSettingRecord.Setting_Type__c = 'Org Wide';
            orgWideSettingRecord.Component_Id__c = '0D26A000000L1W5';
            orgWideSettingRecord.Other_Details__c = 'Customer Portal';
            orgWideSettingRecord.Origin__c = 'Customer Portal';
            insert orgWideSettingRecord;
            
            Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c();
            queueRecord.Name ='Q1';
            queueRecord.QueueName__c ='Q1';
            queueRecord.Type__c ='Queue'; 
            insert queueRecord;
            Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c();
            queueUserRecord.Name ='Q1';
            queueUserRecord.QueueName__c ='Q1';
            queueUserRecord.Type__c ='User';
            queueUserRecord.User__c = serviceUser.Id;
            insert queueUserRecord;
            
            Product2 productRecord = UTL_TestData.createProduct();
            productRecord.Name = 'Nexxus MI';
            productRecord.SpecificToCSM__c = True;
            insert productRecord;
            Asset assetRecord = new Asset(Name = 'Nexxus MI', AccountId = accountRecord.Id, Product2Id = productRecord.Id, Status ='Installed');
            insert assetRecord;
            CSM_QI_Case_Categorization__c caseCatRecord = new CSM_QI_Case_Categorization__c();
            caseCatRecord.Product__c= productRecord.Id;
            caseCatRecord.SubType1__c = 'Incident-Module';
            caseCatRecord.SubType2__c = 'Formularies';  
            caseCatRecord.SubType3__c = '--none--';
            caseCatRecord.Active__c = true;
            caseCatRecord.Pillar__c = 'Information Offering';
            insert caseCatRecord;
            
            Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case caseRecord = new Case();
            caseRecord.ContactId = contactRecord.Id;
            caseRecord.AccountId = accountRecord.Id;
            caseRecord.AssignCaseToCurrentUser__c = false;
            caseRecord.OwnerId = serviceUser.Id;
            caseRecord.RecordTypeId = recordTypeIdTechno;
            caseRecord.Priority = 'Medium';
            caseRecord.Origin = 'Customer Portal';
            caseRecord.Mail_CC_List__c = 'nodata@info.com';
            caseRecord.Subject = 'Test case subject';
            caseRecord.Description = 'Test case description for new case creation';
            caseRecord.Status = 'New';
            caseRecord.CurrentQueue__c = queueUserRecord.Id;
            caseRecord.AssetId = assetRecord.Id;
            caseRecord.Case_CategorizationId__c = caseCatRecord.Id;
            caseRecord.ProductName__c= 'Nexxus MI';
            caseRecord.SubType1__c = 'Incident-Module';
            caseRecord.SubType2__c = 'Formularies';  
            caseRecord.SubType3__c = '--none--';
            caseRecord.PhoneVerification__c = True;
            insert caseRecord;
        }
    }
    
    @isTest
    static void testSelectById(){
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion contentVersionRecord = new ContentVersion();
        contentVersionRecord.title = 'Penguins';
        contentVersionRecord.PathOnClient ='Penguins.jpg';
        contentVersionRecord.IsMajorVersion = True;
        contentVersionRecord.VersionData =beforeblob;
        insert contentVersionRecord;
   
        List<ContentDocument> documents = new List<ContentDocument>();
        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Test.startTest();
            documents = new SLT_ContentDocument().selectById(new Set<Id>{document.id});
        Test.stopTest();
    }
    
    @isTest
    static void testGetDocumentsOnContentIdAndLinkedId(){
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion contentVersionRecord = new ContentVersion();
        contentVersionRecord.title = 'Penguins';
        contentVersionRecord.PathOnClient ='Penguins.jpg';
        contentVersionRecord.IsMajorVersion = True;
        contentVersionRecord.VersionData =beforeblob;
        insert contentVersionRecord;
        
        Case caseRecord = [SELECT Id, caseNumber FROM Case];
        ContentDocument documentRecord = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> documentList = new List<ContentDocumentLink>();
        Test.startTest();
        documentList = new SLT_ContentDocument().getDocumentsOnContentIdAndLinkedId(new List<Id>{caseRecord.Id}, new List<Id>{documentRecord.Id});
        Test.stopTest();
    }

    @isTest
    static void testSelectByIdWithCondition(){
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion contentVersionRecord = new ContentVersion();
        contentVersionRecord.title = 'Test Title';
        contentVersionRecord.PathOnClient ='Penguins.jpg';
        contentVersionRecord.IsMajorVersion = True;
        contentVersionRecord.VersionData =beforeblob;
        insert contentVersionRecord;
   
        List<ContentDocument> documents = new List<ContentDocument>();
        Map<Id,ContentDocument> documentsMap = new Map<Id,ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title =: contentVersionRecord.title]);

        Test.startTest();
            documents = new SLT_ContentDocument().selectById(new Set<String>{'Id'},  ' Title = \'Test Title\'', documentsMap.keySet());
             List<List<ContentDocument>> resultF = new SLT_ContentDocument().getSearchResultsContentDocument('Test Title',1, 3);
        Test.stopTest();

        System.assertNotEquals(0,documents.size(), 'Document list coming empty when not expected');
    }
}