/**
 * Test class for the project log change event trigger
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 26 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_TGR_Project_Log_ChangeEvent {
    
    @isTest
    static void tstUtilEventDomainHelper() {
        //Program
        Program__c program = new Program__c(Name = 'Test Program');
        insert program;
        // initialize CDC!
        Test.enableChangeDataCapture();
        
        Test.startTest();
        
        // insert a project task object
        Project_Log__c projectLog = new Project_Log__c(Account__c = UTL_PSA_TestData.accounts[0].id);
        projectLog.Program__c = program.id;
        insert projectLog;
        
        // Trigger CDC Event (and event domain helper utility)
        Test.getEventBus().deliver();
        
        Test.stopTest();
        
        Audit_Log__c[] insertedLogs = [select id, name, operation__c, record_id__c from Audit_Log__c where record_id__c = :projectLog.Id and operation__c in ('INSERT')];
        system.assertNotEquals(0, insertedLogs.size(), 'Expected to have an INSERT operation');
        system.assertEquals('INSERT', insertedLogs[0].Operation__c, 'expected an INSERT operation');
    }
}
