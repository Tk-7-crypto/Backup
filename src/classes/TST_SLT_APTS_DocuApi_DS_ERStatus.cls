/*
 * Version       : 1.0
 * Description   : This Apex class is test class for SLT_Apttus_DocuApi_DocuSignEnvelopeRecipientStatus
 */
@isTest
private class TST_SLT_APTS_DocuApi_DS_ERStatus {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() 
	{
        Apttus_DocuApi__DocuSignEnvelope__c docuApiEnvelope = new Apttus_DocuApi__DocuSignEnvelope__c();
        insert docuApiEnvelope;

        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c();
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__DocuSignEnvelopeId__c = docuApiEnvelope.Id;
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__Email__c = 'testcontactRec1@example.com';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__RoleName__c = 'Signer';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__RecipientName__c = 'Test';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__SignedDateTime__c = System.now();
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__Status__c = 'Completed';
        insert docuApiDocuSignEnvelopeReciStatus;
    }
    
    @isTest
    private static void testGetDocuSignEnvelopeByIdAndStatus() {
        SLT_APTS_DocuApi_DS_EnvRecipientStatus sltDSEnvRecipient = new SLT_APTS_DocuApi_DS_EnvRecipientStatus();
        List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>  lstDocuApiDocuSignEnvelopeReciStatus = new List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>();
        Apttus_DocuApi__DocuSignEnvelope__c docuApiEnvelope = new Apttus_DocuApi__DocuSignEnvelope__c();
        insert docuApiEnvelope;

        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c();
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__DocuSignEnvelopeId__c = docuApiEnvelope.Id;
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__Email__c = 'testcontactRec1@example.com';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__RoleName__c = 'Signer';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__RecipientName__c = 'Test';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__SignedDateTime__c = System.now();
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__Status__c = 'Completed';
        insert docuApiDocuSignEnvelopeReciStatus;

        Test.startTest();
            lstDocuApiDocuSignEnvelopeReciStatus = sltDSEnvRecipient.getDocuSignEnvelopeByIdAndStatus(new Set<Id>{docuApiDocuSignEnvelopeReciStatus.Id}, new Set<String>{'Id'});
        Test.stopTest();
        
        system.assertEquals(1, lstDocuApiDocuSignEnvelopeReciStatus.size(), 'Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c not returned as expected.');
    }
    
    @isTest
    private static void testGetDSEnvelopeRecipientStatusByEnvelopeId() {
        Apttus_DocuApi__DocuSignEnvelope__c docuApiEnvelope = [SELECT Id FROM Apttus_DocuApi__DocuSignEnvelope__c LIMIT 1][0];
        List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>  lstDSEnvelopeRecipientStatus = new List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>();
        Test.startTest();
            lstDSEnvelopeRecipientStatus = new SLT_APTS_DocuApi_DS_EnvRecipientStatus().getDSEnvelopeRecipientStatusByEnvelopeId(
                docuApiEnvelope.Id, new Set<String>{'Id'});
        Test.stopTest();
        
        system.assertEquals(1, lstDSEnvelopeRecipientStatus.size(), 'Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c not returned as expected.');
    }
}