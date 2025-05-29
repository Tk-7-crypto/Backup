@isTest
public class TST_CNT_CPQ_PreviewDocumentController {
    static Opportunity setOpportunityData(Id accountId) {
        
        Opportunity testOpportunity = UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert testOpportunity;
        return testOpportunity;
    }
    
    static Account setAccountData() {
        
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }
    
    static Contract setContractData(Opportunity opp, String recordTypeDevName) {
        
        Contract testContract = UTL_TestData.createContract(opp, recordTypeDevName);
        insert testContract;
        return testContract;
    }
    @isTest
    static void testFetchContentDocument() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Contract testContract = setContractData(testOpportunity, 'Generic_Contract');
        testContract.Opportunity__c = testOpportunity.Id;
        update testContract;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title= 'Test Document' Limit 1];
        ContentDocumentLink linkRecord = new ContentDocumentLink(LinkedEntityId = testContract.Id, ContentDocumentId = contDocs[0].Id, shareType = 'V');
        insert linkRecord;
        
        List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        Test.startTest();
            CNT_CPQ_PreviewDocumentController.ContractDetails contractDetailsObj = CNT_CPQ_PreviewDocumentController.fetchContentDocument(testContract.Id);
            contentDocList.add(contractDetailsObj.documentList[0]);
        Test.stopTest();
        System.assertEquals(contentDocList.size(), 1, 'Document Present');
    }
}