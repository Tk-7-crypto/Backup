@isTest
public class TST_CNT_CLM_EnhancedFileRelatedList {

    @testsetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        agreement.Name = 'Test RWS';
        agreement.Apttus__Status_Category__c = 'Request';
        agreement.Apttus__Status__c = 'Request';
        agreement.Apttus__Subtype__c = 'ATP';
        insert agreement;

        IQVIA_Agreement__c iqAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqAgreement.Name = 'Test IQ USBU';
        iqAgreement.Status_Category__c = 'In Effect';
        iqAgreement.Status__c = 'Activated';
        iqAgreement.Subtype__c = 'SOW';
        insert iqAgreement;

        ContentVersion cv = TST_CLM_TestDataFactory.createContentVersionWithLink(agreement.Id, 'Test Document');
        ContentVersion cv1 = TST_CLM_TestDataFactory.createContentVersionWithLink(iqAgreement.Id, 'Test Document - IQ AGR');
    }
    
    @isTest
    private static void testGetUploadedFiles() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
        
        Test.startTest();
            List<CNT_CLM_EnhancedFileRelatedList.FileWrapper> resultFilesList = CNT_CLM_EnhancedFileRelatedList.getUploadedFiles(agreement.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, resultFilesList, 'The files should not be null');
    }
    
    @isTest
    private static void testDeleteContentDocumentWithoutSharing() {
        ContentDocument cd = [SELECT ID FROM ContentDocument LIMIT 1];
        
        Test.startTest();
        	CNT_CLM_EnhancedFileRelatedList.deleteContentDocument(cd.Id);
        Test.stopTest();
        
        List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id = :cd.Id];
        System.assertEquals(0, cdList.size(), 'File Not Deleted');
    }

    @isTest
    private static void testUpdateContentDocument() {
        ContentDocument cd = [SELECT ID FROM ContentDocument LIMIT 1];
    
        Test.startTest();
        	CNT_CLM_EnhancedFileRelatedList.updateContentDocument(cd.Id,'Test Description','title');
        Test.stopTest();
        
        ContentDocument updatedCD = [SELECT Id,Description FROM ContentDocument WHERE Id = :cd.Id Limit 1];
        System.assertEquals('Test Description', updatedCD.Description, 'File Not Deleted');
    }

    @isTest
    private static void testIsEditDeleteAllowed() {
        ContentDocument cd = [SELECT ID FROM ContentDocument WHERE Title = 'Test Document - IQ AGR' LIMIT 1]; 
        
        Test.startTest();
        		Boolean isEditDeleteAllowed = CNT_CLM_EnhancedFileRelatedList.isEditDeleteAllowed(cd.Id);
        Test.stopTest();
        
        System.assertEquals(false, isEditDeleteAllowed, 'edit/delete not allowed');
    }
}