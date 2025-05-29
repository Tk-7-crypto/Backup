/*
 * Version       : 1.0
 * Description   : This Apex class is test class for SLT_Apttus_DocuApi_DocuSignEnvelopeRecipientStatus
 */
@isTest
private class TST_SLT_IQ_DS_ERStatus {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() 
	{
        IQ_DocuSignEnvelope__c docuApiEnvelope = new IQ_DocuSignEnvelope__c();
        insert docuApiEnvelope;

        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new IQ_DocuSignEnvelopeRecipientStatus__c();
        docuApiDocuSignEnvelopeReciStatus.DocuSignEnvelopeId__c = docuApiEnvelope.Id;
        docuApiDocuSignEnvelopeReciStatus.Email__c = 'testcontactRec1@example.com';
        docuApiDocuSignEnvelopeReciStatus.RoleName__c = 'Signer';
        docuApiDocuSignEnvelopeReciStatus.RecipientName__c = 'Test';
        docuApiDocuSignEnvelopeReciStatus.SignedDateTime__c = System.now();
        docuApiDocuSignEnvelopeReciStatus.Status__c = CON_CLM.COMPLETED_STATUS;
        insert docuApiDocuSignEnvelopeReciStatus;
    }
    
    @isTest
    private static void testGetDocuSignEnvelopeByIdAndStatus() {
        List<IQ_DocuSignEnvelopeRecipientStatus__c>  lstDocuApiDocuSignEnvelopeReciStatus = new List<IQ_DocuSignEnvelopeRecipientStatus__c>();
        IQ_DocuSignEnvelope__c docuApiEnvelope = new IQ_DocuSignEnvelope__c();
        insert docuApiEnvelope;

        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new IQ_DocuSignEnvelopeRecipientStatus__c();
        docuApiDocuSignEnvelopeReciStatus.DocuSignEnvelopeId__c = docuApiEnvelope.Id;
        docuApiDocuSignEnvelopeReciStatus.Email__c = 'testcontactRec1@example.com';
        docuApiDocuSignEnvelopeReciStatus.RoleName__c = 'Signer';
        docuApiDocuSignEnvelopeReciStatus.RecipientName__c = 'Test';
        docuApiDocuSignEnvelopeReciStatus.SignedDateTime__c = System.now();
        docuApiDocuSignEnvelopeReciStatus.Status__c = CON_CLM.COMPLETED_STATUS;
        insert docuApiDocuSignEnvelopeReciStatus;

        Test.startTest();
            lstDocuApiDocuSignEnvelopeReciStatus = new SLT_IQ_DS_EnvRecipientStatus().getDocuSignEnvelopeByIdAndStatus(new Set<Id>{docuApiDocuSignEnvelopeReciStatus.Id}, new Set<String>{'Id'});
        Test.stopTest();
        
        system.assertEquals(1, lstDocuApiDocuSignEnvelopeReciStatus.size(), 'IQ_DocuSignEnvelopeRecipientStatus__c not returned as expected.');
    }
    
    @isTest
    private static void testGetDSEnvelopeRecipientStatusByEnvelopeId() {
        IQ_DocuSignEnvelope__c docuApiEnvelope = [SELECT Id FROM IQ_DocuSignEnvelope__c LIMIT 1][0];
        List<IQ_DocuSignEnvelopeRecipientStatus__c>  lstDSEnvelopeRecipientStatus = new List<IQ_DocuSignEnvelopeRecipientStatus__c>();
        Test.startTest();
            lstDSEnvelopeRecipientStatus = new SLT_IQ_DS_EnvRecipientStatus().getDSEnvelopeRecipientStatusByEnvelopeId(
                docuApiEnvelope.Id, new Set<String>{'Id'});
        Test.stopTest();
        
        system.assertEquals(1, lstDSEnvelopeRecipientStatus.size(), 'IQ_DocuSignEnvelopeRecipientStatus__c not returned as expected.');
    }
}