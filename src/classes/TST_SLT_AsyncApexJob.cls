/**
 * Test class for the SLT_AsyncApexJob
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 72 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_SLT_AsyncApexJob implements Database.Batchable<sObject> {

// public AsyncApexJob getJobFieldsForId(Id jobId, Set<String> fieldSet) {
  @isTest
  static void testGetJobFieldsForId () {
    Test.startTest();
    TST_SLT_AsyncApexJob tb = new TST_SLT_AsyncApexJob();
    Id batchId = Database.executeBatch(tb);
    AsyncApexJob job = new SLT_AsyncApexJob().getJobFieldsForId(batchId, new Set<String> {'Id', 'ApexClass.Name'});
    Test.stopTest();
    system.assertEquals(batchId, job.Id);
  }

  @isTest
  static void testFindJobs () {
    Test.startTest();
    TST_SLT_AsyncApexJob tb = new TST_SLT_AsyncApexJob();
    Id batchId = Database.executeBatch(tb);
    Map<Id, AsyncApexJob> jobs =  new SLT_AsyncApexJob().findJobs(new Set<Id>{batchId}, new Set<String> {'Id', 'ApexClass.Name'});
    Test.stopTest();
    system.assertEquals(1,jobs.size());
  }

  // mock up an account  for  the test batch
  static Account account = UTL_PSA_TestData.accounts[0];

  /*
   * Mocked up batch job for SLT_AsyncApexJob testing
   */
  public Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator('SELECT Id FROM Account');
  }
  public void execute(Database.BatchableContext BC, List<SObject> scope){
    system.debug(scope);
  }
  public void finish(Database.BatchableContext BC){
  }


}