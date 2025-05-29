/**
 * Test class for the project task change event DAO
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 22 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_DAO_Project_Task_ChangeEvent {

  @isTest
  static void tstUtilEventDomainHelper() {
    // initialize CDC!
    Test.enableChangeDataCapture();

    Test.startTest();

    // insert a project task object
    insert UTL_PSA_TestData.createProjectTaskTestSubject();

    // Trigger CDC Event (and event domain helper utility)
    Test.getEventBus().deliver();

    Test.stopTest();
  }


}