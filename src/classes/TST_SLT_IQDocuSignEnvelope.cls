@isTest
private class TST_SLT_IQDocuSignEnvelope{

	@testSetup
	static void dataSetup() {
        IQVIA_Agreement__c testAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        testAgreement.Status__c = 'Other party Signatures';
        insert testAgreement;
        
		IQ_DocuSignEnvelope__c docusignEnvelope = new IQ_DocuSignEnvelope__c();
		docusignEnvelope.Status__c = 'Sent';
        docuSignEnvelope.Agreement__c = testAgreement.Id;
		insert docusignEnvelope;		
	}
		
	@isTest
	private static void testgetDocuSignEnvelopeByIdAndStatus(){
		Set<String> fieldSet = new Set<String>{'Id', 'Status__c'};
		IQ_DocuSignEnvelope__c docusignEnvelope1 = [Select Id, Status__c From IQ_DocuSignEnvelope__c LIMIT 1];		
		Test.startTest();
		List<IQ_DocuSignEnvelope__c> Envelope = new SLT_IQDocuSignEnvelope().getDocuSignEnvelopeByIdAndStatus(docusignEnvelope1.Status__c, new Set<Id>{docusignEnvelope1.Id}, fieldSet);
		Test.stopTest();		
		
		System.assertEquals(1, Envelope.size(), 'Should return Envelope');
	}
	
    @isTest
    private static void testGetDocusignEnvelopeByCondition() {
        String condition = 'Status__c =: secondParam';
        
        Test.startTest();
            List<IQ_DocuSignEnvelope__c> result = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(condition, null, 
                CON_CLM.SENT_STATUS, new Set<String>{'Id', 'Status__c'}, 'Name', 'ASC', 1);
        Test.stopTest();  
        
        System.assertNotEquals(0, result.size(), 'The list should not be null');
    }
    
    @isTest
    private static void testGetDocusignEnvelopeByConditionAndAgreementIds() {
        IQVIA_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM IQVIA_Agreement__c LIMIT 1];
        String condition = 'Agreement__c =: agreementIds And Status__c = \'Sent\'';
        
        Test.startTest();
            List<IQ_DocuSignEnvelope__c> result = new SLT_IQDocuSignEnvelope().
                getDocusignEnvelopeByConditionAndAgreementIds(condition, new Set<Id>{agreement.Id}, new Set<String>{'Id'});
        Test.stopTest();  
        
        System.assertNotEquals(0, result.size(), 'The list should not be null');
    }
}