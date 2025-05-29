@isTest
private class TST_SLT_ApttusDocuSignEnvelope{

	@testSetup
	static void dataSetup() {
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        testAgreement.Apttus__Status__c = 'Other party Signatures';
        insert testAgreement;
        
		Apttus_DocuApi__DocuSignEnvelope__c docusignEnvelope = new Apttus_DocuApi__DocuSignEnvelope__c();
		docusignEnvelope.Apttus_DocuApi__Status__c = 'Sent';
        docuSignEnvelope.Apttus_CMDSign__Agreement__c = testAgreement.Id;
		insert docusignEnvelope;		
	}
		
	@isTest
	private static void testgetDocuSignEnvelopeByIdAndStatus(){
		Set<String> fieldSet = new Set<String>{'Id', 'Apttus_DocuApi__Status__c'};
		Apttus_DocuApi__DocuSignEnvelope__c docusignEnvelope1 = [Select Id, Apttus_DocuApi__Status__c From Apttus_DocuApi__DocuSignEnvelope__c LIMIT 1];		
		Test.startTest();
		List<Apttus_DocuApi__DocuSignEnvelope__c> Envelope = new SLT_ApttusDocuSignEnvelope().getDocuSignEnvelopeByIdAndStatus(docusignEnvelope1.Apttus_DocuApi__Status__c, new Set<Id>{docusignEnvelope1.Id}, fieldSet);
		Test.stopTest();		
		
		System.assertEquals(1, Envelope.size(), 'Should return Envelope');
	}
	
    @isTest
    private static void testGetDocusignEnvelopeByCondition() {
        String condition = 'Apttus_DocuApi__Status__c =: secondParam';
        
        Test.startTest();
            List<Apttus_DocuApi__DocuSignEnvelope__c> result = new SLT_ApttusDocuSignEnvelope().getDocusignEnvelopeByCondition(condition, null, 
                CON_CLM.ENVELOPE_STATUS_SENT, new Set<String>{'Id', 'Apttus_DocuApi__Status__c'}, 'Name', 'ASC', 1);
        Test.stopTest();  
        
        System.assertNotEquals(0, result.size(), 'The list should not be null');
    }
    
    @isTest
    private static void testGetDocusignEnvelopeByConditionAndAgreementIds() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM Apttus__APTS_Agreement__c LIMIT 1];
        String condition = 'Apttus_CMDSign__Agreement__c =: agreementIds And Apttus_DocuApi__Status__c = \'Sent\'';
        
        Test.startTest();
            List<Apttus_DocuApi__DocuSignEnvelope__c> result = new SLT_ApttusDocuSignEnvelope().
                getDocusignEnvelopeByConditionAndAgreementIds(condition, new Set<Id>{agreement.Id}, new Set<String>{'Id'});
        Test.stopTest();  
        
        System.assertNotEquals(0, result.size(), 'The list should not be null');
    }
}