/**
 * This test class is used to test the CNT_CLM_LoadSchedule1 class
 * version : 1.0
 */
@IsTest
public class TST_CNT_CLM_LoadSchedule1 {

    @testSetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.SOW_RECORDTYPEID, false);
        agreement.Name = 'Test SOW Agreement';
        insert agreement;
            
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        cv.FirstPublishLocationId = agreement.Id;
        cv.Description = 'Test Description';
        insert cv;
    }

    @IsTest
    static void testCreateAgreementLineItemWithInvalidAgreement() {
        Test.startTest();
        	Id result = CNT_CLM_LoadSchedule1.createAgreementLineItem(null, null);
        	System.assertEquals(null, result);
        Test.stopTest();

    }
    
    @isTest
    private static void testCreateNewAgreementLineItem() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE Name = 'Test SOW Agreement'];  
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument 
            WHERE Title = 'Test Content'];
        
        Test.startTest();
            Id agreementLineItemId = CNT_CLM_LoadSchedule1.createAgreementLineItem(agreement.Id, contDocs.get(0).Id);
        Test.stopTest();
        
        System.assertNotEquals(null, agreementLineItemId, 'The AgreementLineItem Id value should not be null');
    }
    
    @isTest
    private static void testConvertContentDocumentToAttachment() {
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument 
            WHERE Title = 'Test Content'];
        
        Test.startTest();
            Id attachmentId = CNT_CLM_LoadSchedule1.convertContentDocumentToAttachment(contDocs.get(0).Id);
        Test.stopTest();
        
        System.assertNotEquals(null, attachmentId, 'The attachment Id obtained should not be null');
        
        List<ContentDocument> contDocsAfterDelete = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument 
            WHERE Title = 'Test Content'];
        System.assertEquals(0, contDocsAfterDelete.size(), 'The ContentDocument should be null');
    }
}