@isTest
private class TST_UTL_CPQ_FileServices {
    @testSetup
    static void setupTestData() {
        Document doc = new Document(
            Name = 'Test Document',
            Body = Blob.valueOf('Sample file content'),
            FolderId = UserInfo.getUserId()
        );
        insert doc;
       	Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.Id);
        insert testOpportunity;    
        Quote__c quoteData = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, null, CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, false);
        quoteData.Approval_Stage__c = CON_CPQ.DRAFT;
        quoteData.Tool_Launched_Already__c = false;
        insert quoteData;
    }
    @isTest
    static void testCreateContentVersion() {
        Blob sampleBlob = Blob.valueOf('Sample content');
        String filename = 'TestFile.txt';
        Id contentVersionId = UTL_CPQ_FileServices.createContentVersion(sampleBlob, filename);
        Assert.areNotEqual(null, contentVersionId, 'ContentVersion creation failed');
    }
    @isTest
    static void testCreateContentLink() {
        Blob sampleBlob = Blob.valueOf('Sample content');
        String filename = 'TestFile.txt';
        Id contentVersionId = UTL_CPQ_FileServices.createContentVersion(sampleBlob, filename);
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Id contentLinkId1 = UTL_CPQ_FileServices.createContentLink(contentVersionId, quote.Id);
        Id contentLinkId2 = UTL_CPQ_FileServices.createContentLink(null, null);
        Assert.areNotEqual(null, contentLinkId1, 'ContentLink creation failed');
    }
}