@isTest
public class TST_CNT_PEP_AccountLogo {

    @TestSetup
    private static void makeData(){
        Account acct = new Account();
        acct.Name = 'Test Account1';
        acct.CustomerSegment__c = 'GOVERNMENT';
        acct.Sub_Industry__c = 'STATE';
        insert acct;

        ContentVersion cv=new Contentversion();
        cv.title='title_TEST';
        cv.PathOnClient ='test.jpg';
        Blob b=Blob.valueOf('Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Test Attachment Body');
        cv.IsMajorVersion = true;
        insert cv;

        List<ContentDocument> documents = [SELECT Id FROM ContentDocument];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = acct.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }   
    
    @isTest
    private static void testAppendFileNameMethod(){
        List<ContentDocument> documents = [SELECT Id FROM ContentDocument];

        Test.startTest();
        CNT_PEP_AccountLogo.appendFileName(documents[0].Id, '_LOGO');
        Test.stopTest();

        List<ContentDocument> resDocuments = [SELECT Id, Title FROM ContentDocument];
        System.assert(resDocuments[0].Title == 'title_TEST_LOGO', 'Logo title not changed.');
    }

    @isTest
    private static void testIsLogoAvailableMethod(){
        List<Account> accounts = [SELECT Id FROM Account];

        String documentId;

        Test.startTest();
        documentId = CNT_PEP_AccountLogo.isLogoAvailable(accounts[0].Id);
        Test.stopTest();

        System.assert(documentId != null || documentId != '', 'No logo document id returned.');
    }

    @isTest
    private static void testGetLogoContentVersionIdMethod(){
        List<ContentDocument> documents = [SELECT Id FROM ContentDocument];
        String docVersionId;

        Test.startTest();
        docVersionId = CNT_PEP_AccountLogo.getLogoContentVersionId(documents[0].Id);
        Test.stopTest();

        System.assert(docVersionId != null && docVersionId != '', 'No logo version id returned.');
    }

    @isTest
    private static void testDeleteLogoById(){
        List<ContentDocument> documents = [SELECT Id FROM ContentDocument];

        Test.startTest();
        CNT_PEP_AccountLogo.deleteLogoById(documents[0].Id);
        Test.stopTest();

        documents = [SELECT Id FROM ContentDocument];
        System.assert(documents.size() == 0, 'Document not deleted.');
    }
}
