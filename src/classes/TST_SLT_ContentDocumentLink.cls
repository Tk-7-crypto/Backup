/**
* Test class for SLT_ContentDocumentLink
*/
@isTest
public class TST_SLT_ContentDocumentLink {

    @testSetup
    public static void dataSetup() {
        Apttus__APTS_Agreement__c psaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;
        
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title= 'Test Content'];
        
        ContentDocumentLink contentLink=new ContentDocumentLink();
        contentLink.LinkedEntityId = psaAgreement.Id; 
        contentLink.ContentDocumentId = contDocs[0].Id;
        insert contentLink;
    }

    @isTest
    private static void testGetContentDocumentLinkDetailByContentDocumentId() {
        List<ContentDocument> contDoc = [SELECT Id FROM ContentDocument WHERE Title= 'Test Content'];
        Set<Id> contentDocumentIds = new Set<Id>{contDoc[0].Id};
        Set<String> fieldSet = new Set<String>{'Id'};
                
        Test.startTest();
            List<ContentDocumentLink> lstContDocLink = new SLT_ContentDocumentLink()
                .getContentDocumentLinkDetailByContentDocumentId(contentDocumentIds, fieldSet);
        Test.stopTest();
        
        System.assertNotEquals(0, lstContDocLink.size(), 'The size of list should not be 0');
    }
    
    @isTest
    static void testGetContentDocumentBasedOnLinkedEntity(){
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        List<Account> actlist = new List<Account>();
        Account sponsorAccount = new Account(RecordTypeId = mdmValidAccount, AccountCountry__c = 'US', Name = 'Techno Sponsor Portal', RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        actlist.add(sponsorAccount);
        Account siteAccount = new Account(RecordTypeId = mdmValidAccount, AccountCountry__c = 'US', Name = 'Techno Site Portal', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        actlist.add(siteAccount);
        insert actlist;
        
        Contact contactRecord = new Contact(AccountId = sponsorAccount.Id, FirstName = 'Sponsor', LastName = 'Contact', Email = 'noreply@dummy.com', PreferredLanguage__c = 'en_US');
        insert contactRecord;
        
        Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c();
        queueRecord.Name ='Q1';
        queueRecord.QueueName__c ='Q1';
        queueRecord.Type__c ='Queue'; 
        insert queueRecord;
        Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c();
        queueUserRecord.Name ='Q1';
        queueUserRecord.QueueName__c ='Q1';
        queueUserRecord.Type__c ='User';
        queueUserRecord.User__c = UserInfo.getUserId();
        insert queueUserRecord;
        
        Study__c studyRecord = new Study__c(Name = 'Sponsor Study', Sponsor__c = sponsorAccount.Id);
        insert studyRecord;
        StudySiteContactRelationship__c sscRecord = new StudySiteContactRelationship__c(Study__c = studyRecord.Id, Site_Name__c = siteAccount.Id, SiteNumber__c = 'SITE01');
        insert sscRecord;
        
        Id RD_RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        Case caseRecord = new Case(AccountId = sponsorAccount.Id, ContactId = contactRecord.Id, Study__c = studyRecord.Id,
                                   Site_Related_to_the_Study__c = sscRecord.Id, CurrentQueue__c = queueUserRecord.Id, Origin = 'Email', AssignCaseToCurrentUser__c = false,
                                   Status = 'New', Subject = 'Parent Case', RandD_Location__c = 'Dalian', OwnerId = UserInfo.getUserId(), RecordTypeId = RD_RecordTypeId);
        insert caseRecord;
        Activity__c actRecord = new Activity__c(Case__c = caseRecord.Id, Site__c = siteAccount.Id, Study__c = studyRecord.Id, PassFail__c = 'Pass', 
                                               LOS__c = 'Account Management', Type__c = 'Quality Check', EscalationType__c = 'Compliant');
        insert actRecord;
        
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion contentVersionRecord = new ContentVersion();
        contentVersionRecord.title = 'Penguins';
        contentVersionRecord.PathOnClient ='Penguins.jpg';
        contentVersionRecord.IsMajorVersion = True;
        contentVersionRecord.VersionData =beforeblob;
        insert contentVersionRecord;
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title= 'Penguins'];
        
        ContentDocumentLink linkRecord = new ContentDocumentLink(LinkedEntityId = actRecord.Id, ContentDocumentId = contDocs[0].Id);
        insert linkRecord;
        
        Test.startTest();
        new SLT_ContentDocumentLink().getContentDocumentBasedOnLinkedEntity(new Set<Id>{actRecord.Id});
        new SLT_ContentDocumentLink().getContentDocumentLinkDetailByLinkedEntityId(actRecord.Id, new Set<String>{'Id'});
        new SLT_ContentDocumentLink().getContentDocumentLinkByLinkedEntityAndTitle(new Set<String>{actRecord.Id+''}, 'Penguins', new Set<String>{'Id'});
        Test.stopTest();
    }

    @isTest
    private static void testGetContentDocumentLinkWithLimitAndOrder() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c][0];
        Set<String> fieldSet = new Set<String>{'Id'};
                
        Test.startTest();
            List<ContentDocumentLink> lstContDocLink = new SLT_ContentDocumentLink()
                .getCDLByLinkedEntityWithLimitAndOrder(fieldSet, new Set<Id>{agreement.Id}, 1, 'ContentDocument.CreatedDate');
        Test.stopTest();
        
        System.assertNotEquals(0, lstContDocLink.size(), 'The size of list should not be 0');
    }
}