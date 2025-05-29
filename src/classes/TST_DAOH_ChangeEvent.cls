/**
 * Test class for the Change Event Helper
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 22 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_DAOH_ChangeEvent {

  @isTest
  static void tstUtilEventDomainHelper() {
    //  initialize CDC
    Test.enableChangeDataCapture();

    // stub up a project task to trigger a  change event
    pse__Project_Task__c testSubject = UTL_PSA_TestData.createProjectTaskTestSubject();

    Test.startTest();

    // # insert and deliver a CREATE change event
    insert testSubject;
    Test.getEventBus().deliver();

    // # update and deliver a UPDATE change event
    testSubject.Quantity__c = 101;
    testSubject.Reason_For_Deletion__c = 'Test Class';
    update testSubject;
    Test.getEventBus().deliver();

    // delete and deliver a DELETE change event
    delete testSubject;
    Test.getEventBus().deliver();


    // undelete and deliver a unDELETE change event
   undelete testSubject;
   Test.getEventBus().deliver();

    Test.stopTest();

    Audit_Log__c[] insertedLogs = [select id, name, Transaction_Key__c, operation__c, record_id__c from Audit_Log__c where record_id__c = :testSubject.Id and Transaction_Key__c != '' and operation__c in ('INSERT')];
    system.assertNotEquals(0, insertedLogs.size(), 'Expected to have an INSERT operation');
    system.assertEquals('INSERT', insertedLogs[0].Operation__c, 'expected an INSERT operation');
    system.assertNotEquals(null, insertedLogs[0].Transaction_Key__c, 'expected an INSERT operation with a transaction');

    Audit_Log__c[] updatedLogs  = [select id, Transaction_Key__c, name, operation__c, record_id__c from Audit_Log__c where record_id__c = :testSubject.Id and Transaction_Key__c != '' and operation__c in ('UPDATE') ];
    system.assertNotEquals(0, updatedLogs.size(), 'Expected to have an UPDATED operation');
    system.assertEquals('UPDATE', updatedLogs[0].Operation__c, 'expected an UPDATE operation');
    system.assertNotEquals(null, updatedLogs[0].Transaction_Key__c, 'expected an UPDATE operation with a transaction');

    Audit_Log__c[] deleteddLogs  = [select id, Transaction_Key__c, name, operation__c, record_id__c from Audit_Log__c where record_id__c = :testSubject.Id and Transaction_Key__c != '' and operation__c in ('DELETE') ];
    system.assertNotEquals(0, deleteddLogs.size(), 'Expected to have a DELETED operation');
    system.assertEquals('DELETE', deleteddLogs[0].Operation__c, 'expected a DELETE operation');
    system.assertNotEquals(null, deleteddLogs[0].Transaction_Key__c, 'expected an DELETE operation with a transaction');
  }
}