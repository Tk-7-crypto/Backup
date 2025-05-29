@isTest
private class TST_TGR_ContentDocumentLink {
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup(){
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        insert adminUser;

        Id prmCtrRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_CTR_RECORDTYPE).getRecordTypeId();

        System.runAs(adminUser){
            Account acc = TST_PEP_TestDataFactory.createAccount('Digitas');
            insert acc;
            Contract ctr = TST_PEP_TestDataFactory.createContract('Contract1', acc.Id );
            insert ctr;
        }
        
        Profile profileRecord = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        UserRole userRoleRecord = [Select Id From UserRole Where DeveloperName = 'CSM' Limit 1];
        User serviceUser = New User(Alias='sa12u', UserRoleId=userRoleRecord.Id, ProfileId=profileRecord.Id, Email='dummyTGRDluser@iqvia.com', 
                                    IsActive=true, Username='dummyTGRDluser@iqvia.com.dev', LastName='testTGRDlLastName', CommunityNickname='testTGRDlSUNickname', 
                                    TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US',
                                    Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber ='08080808');
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

    static testMethod void defineSharingRule() {
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        Account acc = [SELECT id, Name FROM Account WHERE Name = 'Digitas'];
        Contract contrt = [SELECT id from Contract WHERE AccountId = :acc.Id limit 1 ];
        
        System.runAs(adminUser){ 
            Test.startTest(); 
            ContentDocumentLink cdl = TST_PEP_TestDataFactory.createContentDocLink(contrt.Id);
            insert cdl;
            Test.stopTest();
            ContentDocumentLink cntDocLnk = [SELECT Id, Visibility, ShareType FROM ContentDocumentLink where LinkedEntityId =: contrt.Id Limit 1];
            system.assertEquals('AllUsers', cntDocLnk.Visibility);
            system.assertEquals('I', cntDocLnk.ShareType);
        }   
    }
    
    @isTest
    static void testSendEmailNotificationOnNewAttachment(){
        User serviceUser = [SELECT Id FROM User WHERE email = 'dummyTGRDluser@iqvia.com' LIMIT 1];
        Case caseRecord = [SELECT Id FROM Case WHERE Origin = 'Customer Portal' LIMIT 1];
        
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion contentVersionRecord = new ContentVersion();
        contentVersionRecord.title = 'Penguins';
        contentVersionRecord.PathOnClient ='Penguins.jpg';
        contentVersionRecord.IsMajorVersion = True;
        contentVersionRecord.VersionData =beforeblob;
        insert contentVersionRecord;
   
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> documentList = new List<ContentDocumentLink>();
        
        ContentDocumentLink contentDocumentRecordOne = new ContentDocumentLink();
        contentDocumentRecordOne.LinkedEntityId = caseRecord.Id;
        contentDocumentRecordOne.ContentDocumentId = documents[0].Id;
        contentDocumentRecordOne.ShareType = 'V';
        contentDocumentRecordOne.Visibility = 'AllUsers';
        documentList.add(contentDocumentRecordOne);
        ContentDocumentLink contentDocumentRecordTwo = new ContentDocumentLink();
        contentDocumentRecordTwo.LinkedEntityId = serviceUser.Id;
        contentDocumentRecordTwo.ContentDocumentId = documents[0].Id;
        contentDocumentRecordTwo.ShareType = 'V';
        contentDocumentRecordTwo.Visibility = 'AllUsers';
        documentList.add(contentDocumentRecordTwo);
        
        System.runAs(serviceUser){
            Test.startTest();
            insert documentList;
            Test.stopTest();
        }
    }
}