@isTest
public class TST_DAOH_CLM_IQ_DocuSignEnvelope {
    /**
    *This method is used to setup data for all methods. 
    */
    @testSetup
    static void dataSetup() {
        IQVIA_Agreement__c agreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement';
        agreement.Other_Party_Does_Not_Need_To_Sign__c = false;
        agreement.Other_Party_Signed_Date__c = System.today();
        agreement.Company_Signed_Date__c = System.today();
        insert agreement;

        IQ_DocuSignEnvelope__c docuSignEnvelope = new IQ_DocuSignEnvelope__c();
        docuSignEnvelope.Name = 'Test DocuSign Envelope';
        docuSignEnvelope.Status__c = CON_CLM.DRAFT;
        docuSignEnvelope.Send_As_User_Email__c = 'abc@example.com';
        docuSignEnvelope.Docusign_AccountId__c = '12345';
        docuSignEnvelope.Agreement__c = agreement.Id;
        docuSignEnvelope.DocumentName__c = '["Test Document.docx"]';
        insert docuSignEnvelope;
    }
    
    @isTest
    private static void testUpdateAgreementStatus() {
        IQVIA_Agreement__c agreement = [SELECT Id, RecordTypeId FROM IQVIA_Agreement__c WHERE Name = 'Test Agreement' LIMIT 1];
        IQ_DocuSignEnvelope__c docusignEnv = [SELECT Id, Status__c, Agreement__c, Docusign_Envelope_Info__c 
            FROM IQ_DocuSignEnvelope__c WHERE Agreement__c =: agreement.Id LIMIT 1];
        Map<Id, IQ_DocuSignEnvelope__c> oldMap = new Map<Id, IQ_DocuSignEnvelope__c>();
        oldMap.put(docusignEnv.Id, docusignEnv);
        IQ_DocuSignEnvelope__c newDocusignEnv = docusignEnv.clone(true, false, false, false);
        newDocusignEnv.Status__c = CON_CLM.COMPLETED_STATUS;
        
        Test.startTest();
            DAOH_CLM_IQ_DocuSignEnvelope.updateAgreementStatus(new List<IQ_DocuSignEnvelope__c>{newDocusignEnv}, oldMap);
        Test.stopTest();
        
        IQVIA_Agreement__c updatedAgreement = [SELECT Id, Status__c FROM IQVIA_Agreement__c WHERE Name = 'Test Agreement' LIMIT 1];
        System.assertEquals(CON_CLM.FULLY_SIGNED, updatedAgreement.Status__c, 'Status must be updated to Fully Signed.');
    }
}