@isTest
public class TST_QUE_CLM_BoxMigration {
    
    @testSetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        insert agreement;
        
        box__FRUP__c frupRecord = new box__FRUP__c(); 
        frupRecord.box__Object_Name__c = 'Apttus__APTS_Agreement__c';
        frupRecord.box__Record_ID__c = agreement.Id;  
        frupRecord.box__Folder_ID__c = '128739764476';
        insert frupRecord;
    }
    
    @isTest
    private static void testBoxMigrationQueueable() {
        List<box__FRUP__c> lstFRUP = [SELECT box__Record_ID__c, box__Folder_ID__c FROM box__FRUP__c LIMIT 1]; 
    
        Test.startTest();
            ID jobID = System.enqueueJob(new QUE_CLM_BoxMigration(lstFRUP));
        Test.stopTest();
        
        System.assertNotEquals(null, jobID, 'The id of queueable job should not be null');
    }
}