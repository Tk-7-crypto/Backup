/**
 * Test class for the Batch Apex Error Event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 25 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_DAOH_BatchApexErrorEvent implements Database.Batchable<sObject>, Database.RaisesPlatformEvents {
  /*
   * Test the batch job (this class) fails, fires a batch apex error event, and handled by trigger
   */
  @isTest
  static void tstBatchApexErrorEvent() {
    // configure our test class to be monitored
    DAOH_BatchApexErrorEvent.MONITOR_APP_LOG_JOBS.add('TST_DAOH_BatchApexErrorEvent');

    // mock up an account!
    Account account = UTL_PSA_TestData.accounts[0];

    // run the batch job designed to fail
    try {
      Test.startTest();
      TST_DAOH_BatchApexErrorEvent tb = new TST_DAOH_BatchApexErrorEvent();
      Database.executeBatch(tb);
      Test.getEventBus().deliver();
      Test.stopTest();
    } catch(Exception e){
    }
    // Trigger BatchApexErrorEvent (and event domain helper utility)
    Test.getEventBus().deliver();

    // Verify error event is logged
    System.assertEquals(1, [SELECT Id FROM appirio_core__App_Log__c].size());
  }

  /*
   * Batch job setup to fail! for triggering and testing batch apex error events
   */
  public Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator('SELECT Id FROM Account');
  }
  public void execute(Database.BatchableContext BC, List<SObject> scope){
    // raise dml exception
    DmlException e  = new DmlException();
    e.setMessage('TESTING. This is a constructed DmlException!');
    throw e;
  }
  public void finish(Database.BatchableContext BC){
  }

}