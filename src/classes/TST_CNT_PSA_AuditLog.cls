/**
 * Test class for the psa audit log controller
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 22 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_CNT_PSA_AuditLog 
{

  	@testSetup
    static void dataSetup() 
    {
        Audit_Log__c[] auditLogs = new Audit_Log__c[]{};
        auditLogs.add(new Audit_Log__c(
          Object__c = 'Program__c',
          User__c = UserInfo.getUserId(),
          Time__c = DateTime.now(),
          Field__c = 'bogus__c',
          New_Value__c  = 'bogus',
          Operation__c = 'Update',
          Record_Id__c = UTL_PSA_TestData.programs[0].id,
          Replay_Id__c = UTL_PSA_TestData.programs[0].id
        ));
        auditLogs.add(new Audit_Log__c(
          Object__c = 'Program__c',
          User__c = UserInfo.getUserId(),
          Time__c = DateTime.now(),
          Field__c = 'other_bogus__c',
          New_Value__c  = 'bogus',
          Operation__c = 'Update',
          Record_Id__c = UTL_PSA_TestData.programs[0].id,
          Replay_Id__c = UTL_PSA_TestData.programs[0].id
        ));
        insert auditLogs;
    }
	
    /*
    static {
    setupTestData();
  	}
    */
    
  @isTest
  static void itGetsSobjectDetails () {
    test.startTest();

    CNT_PSA_AuditLog.AuraResult auraResult = CNT_PSA_AuditLog.getSobjectDetails(UTL_PSA_TestData.programs[0].id);
    system.assertNotEquals(null, auraResult);
    system.assertNotEquals(null, auraResult.items);

    test.stopTest();
  }

  @isTest
  static void itGetAuditLogsByRecordId () {
    test.startTest();

    CNT_PSA_AuditLog.AuraResult auraResult = CNT_PSA_AuditLog.getAuditLogsByRecordId(UTL_PSA_TestData.programs[0].id);
    system.assertNotEquals(null, auraResult);
    system.assertNotEquals(null, auraResult.records);

    test.stopTest();
  }

  @isTest
  static void itGetAuditLogsByReplayId () {
    test.startTest();

    CNT_PSA_AuditLog.AuraResult auraResult = CNT_PSA_AuditLog.getAuditLogsByReplayId(UTL_PSA_TestData.programs[0].id);
    system.assertNotEquals(null, auraResult);
    system.assertNotEquals(null, auraResult.records);

    test.stopTest();
  }

  @isTest
  static void itSavesAuditLogs () {

    // stub up wrappers and build payload!
    CNT_PSA_AuditLog.AuditLogWrapper auditLogWrapper = new CNT_PSA_AuditLog.AuditLogWrapper();
    auditLogWrapper.objectType = 'Project_Log__c';
    auditLogWrapper.userId = UserInfo.getUserId();
    auditLogWrapper.logTimestamp = String.valueOf(DateTime.now().getTime());
    auditLogWrapper.operation = 'UPDATE';
    auditLogWrapper.field = 'Name';
    auditLogWrapper.newValue = 'New Name';
    auditLogWrapper.recordId = UTL_PSA_TestData.programs[0].id;
    auditLogWrapper.replayId = '567';

    CNT_PSA_AuditLog.AuditLogWrapper auditLogWrapper1 = new CNT_PSA_AuditLog.AuditLogWrapper();
    auditLogWrapper1.objectType = 'Project_Log__c';
    auditLogWrapper1.userId = UserInfo.getUserId();
    auditLogWrapper1.logTimestamp = String.valueOf(DateTime.now().getTime());
    auditLogWrapper1.operation = 'UPDATE';
    auditLogWrapper1.field = 'Name';
    auditLogWrapper1.newValue = 'New Name';
    auditLogWrapper1.recordId = UTL_PSA_TestData.programs[0].id;
    auditLogWrapper1.replayId = UTL_PSA_TestData.programs[0].id;

    String payload = JSON.serialize(new CNT_PSA_AuditLog.AuditLogWrapper[]{auditLogWrapper, auditLogWrapper1});

    test.startTest();

    CNT_PSA_AuditLog.AuraResult auraResult = CNT_PSA_AuditLog.saveReplayedEvents(payload);
    system.assertNotEquals(null, auraResult);

    test.stopTest();
  }
// public static AuraResult saveReplayedEvents (String auditLogWrapperJSON) {

  /*  
  static void setupTestData () {
    Audit_Log__c[] auditLogs = new Audit_Log__c[]{};
    auditLogs.add(new Audit_Log__c(
      Object__c = 'Program__c',
      User__c = UserInfo.getUserId(),
      Time__c = DateTime.now(),
      Field__c = 'bogus__c',
      New_Value__c  = 'bogus',
      Operation__c = 'Update',
      Record_Id__c = UTL_PSA_TestData.programs[0].id,
      Replay_Id__c = UTL_PSA_TestData.programs[0].id
    ));
    auditLogs.add(new Audit_Log__c(
      Object__c = 'Program__c',
      User__c = UserInfo.getUserId(),
      Time__c = DateTime.now(),
      Field__c = 'other_bogus__c',
      New_Value__c  = 'bogus',
      Operation__c = 'Update',
      Record_Id__c = UTL_PSA_TestData.programs[0].id,
      Replay_Id__c = UTL_PSA_TestData.programs[0].id
    ));
    insert auditLogs;
  }
	*/
}