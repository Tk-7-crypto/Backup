@isTest
public class TST_SRV_CLM_ContentDocumentLink {
    @testSetup
    public static void dataSetup() {
        Apttus__APTS_Agreement__c gsaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        Apttus__APTS_Agreement__c paAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, true);
        
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
    private static void testGetContentDocumentBasedOnLinkedEntity() {
        Apttus__APTS_Agreement__c gceAgreement = [Select id from Apttus__APTS_Agreement__c where 
            RecordTypeId = :CON_CLM.PSA_RECORDTYPEID][0];
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        
        Test.startTest();
            contentDocumentLinkList = SRV_CLM_ContentDocumentLink.getContentDocumentBasedOnLinkedEntity(
                new Set<Id>{gceAgreement.Id});
        Test.stopTest();
        
        System.assertEquals(1, contentDocumentLinkList.size(), 'contentDocumentLinkList should not be empty.');
    }
    
    @isTest
    private static void testInsertContentDocumentLink() {
        Apttus__APTS_Agreement__c paAgreement = [Select id from Apttus__APTS_Agreement__c where 
            RecordTypeId = :CON_CLM.PRELIMINARY_RECORDTYPEID][0];
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;
        
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument 
            WHERE Title= 'Test Content'];
        
        ContentDocumentLink contentLink=new ContentDocumentLink();
        contentLink.LinkedEntityId = paAgreement.Id; 
        contentLink.ContentDocumentId = contDocs[0].Id;
        
        Test.startTest();
            contentLink = SRV_CLM_ContentDocumentLink.insertContentDocumentLink(contentLink);
        Test.stopTest();
        
        System.assertNotEquals(null, contentLink.id, 'contentDocumentLink should be created.');
    }
}