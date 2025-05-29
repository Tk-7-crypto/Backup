@isTest
public class TST_SCH_CLM_IQ_BulkCheckESignatureStatus {
    
    @testSetup
    static void dataSetup() {
        IQVIA_Agreement__c testAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        insert testAgreement;    
    }
    
    @isTest
    private static void testDocusignScheduler() {
        String query = 'SELECT Id, DocuSign_Envelope_Id__c FROM IQVIA_Agreement__c LIMIT 1';
        SCH_CLM_IQ_BulkCheckESignatureStatus scheduler = new SCH_CLM_IQ_BulkCheckESignatureStatus(query);
        String CRON_EXP = '0 0 0 22 9 ? '+ (Date.Today().year() + 1);
        
        Test.startTest();
            String jobId = System.schedule('TST_SCH_IQ_CLM_DocusignSendForESignatures', CRON_EXP, scheduler);
        Test.stopTest();  
        
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id =: jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression, 'The cron expression should be same after scheduling');
    }
}