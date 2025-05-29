/**
 * Test class for the project log change event DAO
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 26 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_DAO_Project_Log_ChangeEvent {
    
    @isTest
    static void tstUtilEventDomainHelper() {
        //Program
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;  
        
        // initialize CDC!
        Test.enableChangeDataCapture();
        
        Test.startTest();
        
        // insert a project task object and trigger cdc event
        Project_Log__c projectLog = new Project_Log__c(Account__c = UTL_PSA_TestData.accounts[0].id);
        projectLog.Program__c = program.id;  
        insert projectLog;
        Test.getEventBus().deliver();
        
        // update and trigger cdc event
        projectLog.Reason_For_Deletion__c = 'Test Class';
        update projectLog;
        Test.getEventBus().deliver();
        
        // delete and trigger cdc event
        delete projectLog;
        Test.getEventBus().deliver();
        
        Test.stopTest();
        
        Audit_Log__c[] insertedLogs = [select id, name, operation__c, record_id__c,Transaction_Key__c from Audit_Log__c where record_id__c = :projectLog.Id and operation__c in ('INSERT') and Transaction_Key__c != ''];
        system.assertNotEquals(0, insertedLogs.size(), 'Expected to have an INSERT operation');
        system.assertEquals('INSERT', insertedLogs[0].Operation__c, 'expected an INSERT operation');
        
        Audit_Log__c[] updatedLogs  = [select id, name, operation__c, record_id__c,Transaction_Key__c from Audit_Log__c where record_id__c = :projectLog.Id and operation__c in ('UPDATE') and Transaction_Key__c != ''];
        system.assertNotEquals(0, updatedLogs.size(), 'Expected to have an UPDATED operation');
        system.assertEquals('UPDATE', updatedLogs[0].Operation__c, 'expected an UPDATE operation');
        
        Audit_Log__c[] deleteddLogs  = [select id, name, operation__c, record_id__c,Transaction_Key__c from Audit_Log__c where record_id__c = :projectLog.Id and operation__c in ('DELETE') and Transaction_Key__c != ''];
        system.assertNotEquals(0, deleteddLogs.size(), 'Expected to have a DELETED operation');
        system.assertEquals('DELETE', deleteddLogs[0].Operation__c, 'expected a DELETE operation');
    }
}
