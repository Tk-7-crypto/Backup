@isTest
public class TST_DAOH_CLM_ContentDocument {
    
	@testSetup
    static void dataSetup() {
        User salesUser = UTL_TestData.createUser('Sales User', 1).get(0);
        insert salesUser;

        List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>();
        lstPSA.add(UTL_TestData.createPermissionSetAssignmentRecord('CLM_IQVIA_Base', salesUser.Id));
        lstPSA.add(UTL_TestData.createPermissionSetAssignmentRecord('CLM_USBU', salesUser.Id));
        insert lstPSA;
    }
    
    @isTest
    private static void testValidateCDForIQAGR() {
        User salesUser = [SELECT Id FROM User WHERE CompanyName = 'TEST' AND LastName = 'lastName123'];
        IQVIA_Agreement__c iqagreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqagreement.Name = 'Test USBU';
        iqagreement.Status_Category__c = 'Request';
        iqagreement.Status__c = 'Request';
        iqagreement.Subtype__c = 'SOW';
        iqagreement.Perpetual__c = true;
        iqagreement.OwnerId = salesUser.Id;
        insert iqagreement;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;
        
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title = 'Test Content'];
        ContentDocumentLink contentDocLink = new ContentDocumentLink();
        contentDocLink.LinkedEntityId = iqagreement.Id; 
        contentDocLink.ContentDocumentId = contDocs[0].Id; 
        insert contentDocLink;
        
        iqagreement.Status_Category__c = 'In Effect';
        iqagreement.Status__c = 'Activated';
        update iqagreement; 
        
        Test.startTest();
        try{
            System.runAs(salesUser) {
        	    DAOH_CLM_ContentDocument.validateCDForIQAGR(contDocs);
            }
        }catch(Exception e) {
            System.assertEquals(true, e.getMessage().contains(System.Label.CLM_CL001_Validation_File_IQ_AGR), e.getMessage() );
        }
        Test.stopTest();
    }
}