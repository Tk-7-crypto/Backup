/**
 * Test class for the Reconciliation change event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 29 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_TGR_Reconciliation_ChangeEvent {

  @isTest
  static void tstUtilEventDomainHelper() 
  {
    // initialize CDC!
    Test.enableChangeDataCapture();
    Reconciliation__c subject = createReconciliation();
    Test.startTest();
      
    subject.Comments__c='Test Section INSERT';
    insert subject;
      
    Test.getEventBus().deliver();
    subject.Comments__c='Test Section UPDATE';
    update subject;
      
    Test.getEventBus().deliver();
    subject.Comments__c='Test DELETE';
    delete subject;
      
    Test.getEventBus().deliver();
    Test.stopTest();

    Audit_Log__c[] insertedLogs = [select id, name, operation__c, record_id__c from Audit_Log__c where record_id__c = :subject.Id and operation__c in ('INSERT')];
    system.assertNotEquals(0, insertedLogs.size(), 'Expected to have an INSERT operation');
    system.assertEquals('INSERT', insertedLogs[0].Operation__c, 'expected an INSERT operation');
    system.assertEquals(subject.id, insertedLogs[0].record_id__c, 'expected to have logged the sobject');

    Audit_Log__c[] updatedLogs  = [select id, name, operation__c, record_id__c from Audit_Log__c where record_id__c = :subject.Id and operation__c in ('UPDATE') ];
    system.assertNotEquals(0, updatedLogs.size(), 'Expected to have an UPDATED operation');
    system.assertEquals('UPDATE', updatedLogs[0].Operation__c, 'expected an UPDATE operation');

    Audit_Log__c[] deleteddLogs  = [select id, name, operation__c, record_id__c from Audit_Log__c where record_id__c = :subject.Id and operation__c in ('DELETE') ];
    system.assertNotEquals(0, deleteddLogs.size(), 'Expected to have a DELETED operation');
    system.assertEquals('DELETE', deleteddLogs[0].Operation__c, 'expected a DELETE operation');
  }

  static Reconciliation__c createReconciliation () {
		Target__c target = new Target__c(
			RecordTypeId = [SELECT Id from RecordType where Name='PV Agreement'].Id,
			Program__c = UTL_PSA_TestData.programs[0].id
    );
    insert target;

    return new Reconciliation__c(PV_Agreement__c = target.id);
  }
}