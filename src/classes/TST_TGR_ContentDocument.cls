@isTest
private class TST_TGR_ContentDocument {
	@isTest
    private static void testContentDocumentTrigger() {
        Apttus__APTS_Agreement__c gceAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        gceAgreement.Name = 'Test Agreement';
        insert gceAgreement;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;
        
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink contentDocLink = new ContentDocumentLink();
        contentDocLink.LinkedEntityId = gceAgreement.Id; 
        contentDocLink.ContentDocumentId = contDocs[0].Id;
        contentDocLink.ShareType = 'V';
        contentDocLink.Visibility = 'AllUsers'; 
        insert contentDocLink;
        
        Test.startTest();
            delete contDocs;
        Test.stopTest();
        
        List<ContentDocument> contDocsAfterDelete = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(0, contDocsAfterDelete.size(), 'Size of list is not 0');
    }
	
}