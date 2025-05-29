@isTest
public class TST_SCH_CLM_DocusignSendForESignatures {
    
    @testSetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        testAgreement.Execution_Order__c = CON_CLM.EXTERNAL_ONLY;
        insert testAgreement;    
    }
    
    @isTest
    private static void testDocusignScheduler() {
        String query = 'SELECT Id, DocuSign_Envelope_Id__c FROM Apttus__APTS_Agreement__c LIMIT 1';
        SCH_CLM_DocusignSendForESignatures scheduler = new SCH_CLM_DocusignSendForESignatures(query);
        String CRON_EXP = '0 0 0 22 9 ? '+ (Date.Today().year() + 1);
        
        Test.startTest();
            String jobId = System.schedule('TST_SCH_CLM_DocusignSendForESignatures', CRON_EXP, scheduler);
        Test.stopTest();  
        
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id =: jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression, 'The cron expression should be same after scheduling');
    }
}