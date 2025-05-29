/**
 * Test class for the psa audit log selector
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 22 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_SLT_Audit_Log {

  static {
    setupTestData();
  }

  @isTest
  static void itSelectsAuditLogsByRecordId () {
    test.startTest();
    SLT_Audit_Log subject = new SLT_Audit_Log();
    List<Schema.SObjectField> sobjFields =  subject.getSObjectFieldList();
    system.assertNotEquals(null, sobjFields);

    // # load all audit log records
    Set<String> auditLogFields = new Set<String> {'Id','Object__c','Record_ID__c'};
    List<Audit_Log__c> alList = subject.selectAuditLogsByRecordId(new Set<Id>{UTL_PSA_TestData.programs[0].id}, auditLogFields);
    system.assertEquals(2, alList.size());

    // cover limit
    alList = subject.selectAuditLogsByRecordId(new Set<Id>{UTL_PSA_TestData.programs[0].id}, auditLogFields, 1);
    system.assertEquals(1, alList.size());

    test.stopTest();
  }

  @isTest
  static void itSelectsAuditLogsByReplayId () {
    test.startTest();
    SLT_Audit_Log subject = new SLT_Audit_Log();
    List<Schema.SObjectField> sobjFields =  subject.getSObjectFieldList();
    system.assertNotEquals(null, sobjFields);

    // # load all audit log records by  replay  id
    Set<String> auditLogFields = new Set<String> {'Id','Object__c','Record_ID__c'};
    Set<String> replayIds = new Set<String>{ String.valueOf(UTL_PSA_TestData.programs[0].id) };
    Map<String, Audit_Log__c[]> amap = subject.selectAuditLogsByReplayId(replayIds, auditLogFields);
    system.assertEquals(1, amap.size());

    test.stopTest();
  }

//    public Map<String, Audit_Log__c[]> selectAuditLogsByReplayId(Set<String> replayIds, Set<String> fieldNames) {


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

}