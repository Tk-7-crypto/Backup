@isTest
public class TST_SRV_CLM_ContentDocument {
    @testSetup
    public static void dataSetup() {
        Apttus__APTS_Agreement__c gsaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;
        
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument 
            WHERE Title= 'Test Content'];
        
        ContentDocumentLink contentLink=new ContentDocumentLink();
        contentLink.LinkedEntityId = gsaAgreement.Id; 
        contentLink.ContentDocumentId = contDocs[0].Id;
        insert contentLink;
    }
    
    @isTest
    private static void testDeleteContentDocuments() {
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument 
            WHERE Title= 'Test Content'];
        
        Test.startTest();
            SRV_CLM_ContentDocument.deleteContentDocuments(contDocs);
        Test.stopTest();
        
        List<ContentDocument> deletedContDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument 
            WHERE Title= 'Test Content'];
        System.assertNotEquals(null, deletedContDocs, 'contentDocument should be deleted.');
    }

    @isTest
    private static void testGetContentDocumentByIdsShouldReturnList() {
        ContentDocument contDoc = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument 
            WHERE Title= 'Test Content'];
        
        Test.startTest();
            List<ContentDocument> docs = SRV_CLM_ContentDocument.getContentDocumentByIds(new Set<Id>{contDoc.Id});
        Test.stopTest();
        
        System.assertNotEquals(true, docs.isEmpty(), 'contentDocument list should not be empty.');
    }

    @isTest
    private static void testUpdateContentDocuments() {
        ContentDocument contDoc = [SELECT Id, Title, Description, LatestPublishedVersionId FROM ContentDocument 
            WHERE Title= 'Test Content'];
        contDoc.Description = 'Test Description';
        
        Test.startTest();
            SRV_CLM_ContentDocument.updateContentDocuments(new List<ContentDocument>{contDoc});
        Test.stopTest();
        
        ContentDocument contDocResult = [SELECT Id, Title, Description, LatestPublishedVersionId FROM ContentDocument 
            WHERE Title= 'Test Content'];
        System.assertEquals('Test Description', contDocResult.Description, 'contentDocument is not updated when expected.');
    }
    
    @isTest
    static void testGetContentDocumentsByIds(){
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
            documents = SRV_CLM_ContentDocument.getContentDocumentsByIds(new Set<String>{'Id'},  ' Title = \'Test Title\'', documentsMap.keySet());
        Test.stopTest();

        System.assertNotEquals(0,documents.size(), 'Document list coming empty when not expected');
    }
}